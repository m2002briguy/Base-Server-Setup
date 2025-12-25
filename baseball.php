<?php
session_start();

// storage file
$jsonFile = "dice_baseball_season.json";

// initialize storage if not existing
if (!file_exists($jsonFile)) {
    file_put_contents($jsonFile, json_encode([
        "season" => [
            "teams" => ["away" => [], "home" => []],
            "games" => []
        ],
        "history" => []
    ], JSON_PRETTY_PRINT));
}

// load file data
$fileData = json_decode(file_get_contents($jsonFile), true);

// hit result chart for 2d6 (2–12)
$hitChart = [
    2=>"Home Run",3=>"Triple",4=>"Double",5=>"Single",6=>"Walk",
    7=>"Strikeout",8=>"Flyout",9=>"Groundout",10=>"Single",11=>"Double",12=>"Grand Slam"
];

// start a new game if not in session
if (!isset($_SESSION["game"])) {
    $_SESSION["game"] = [
        "inning" => 1,
        "half" => "top",
        "outs" => 0,
        "bases" => [0,0,0], // 1B, 2B, 3B
        "score" => ["away"=>0, "home"=>0],
        "batting" => "away",
        "teams" => ["away"=>"Away Team", "home"=>"Home Team"],
        "players" => ["away"=>[], "home"=>[]]
    ];

    // generate random player names
    $firstNames = ["Jake","Omar","Luis","Ken","Travis","Naz","Mike","Julius","Ja","Chris","Brian","Tony","Miguel"];
    $lastNames  = ["Reid","Carlson","Hayes","Conley","Navarro","Randle","Morant","Gonzalez","Thompson","Rivers","Clark"];

    for ($i=0; $i<9; $i++) {
        $_SESSION["game"]["players"]["away"][] =
            $firstNames[array_rand($firstNames)] . " " . $lastNames[array_rand($lastNames)];
        $_SESSION["game"]["players"]["home"][] =
            $firstNames[array_rand($firstNames)] . " " . $lastNames[array_rand($lastNames)];
    }
}

$game = &$_SESSION["game"];

// dice roll function (2d6 primary + 1d6 event)
function rollDice() {
    return [
        "2d6" => rand(1,6) + rand(1,6),
        "event" => rand(1,6)
    ];
}

// process a roll
if (isset($_POST["roll"])) {
    $r = rollDice();
    $primary = $hitChart[$r["2d6"]];
    $event   = $r["event"];
    $bases   = &$game["bases"];
    $log = [
        "timestamp" => date("c"),
        "inning" => $game["inning"],
        "half" => $game["half"],
        "batting" => $game["batting"],
        "roll2d6" => $r["2d6"],
        "primary" => $primary,
        "eventDie" => $event,
        "basesBefore" => $bases,
        "scoreBefore" => $game["score"],
        "outsBefore" => $game["outs"]
    ];

    // OUT logic
    if (in_array($primary, ["Strikeout","Flyout","Groundout"])) {
        $game["outs"]++;
        $log["action"] = $primary;
    }

    // WALK logic → batter to 1st, force advance if needed
    if ($primary == "Walk") {
        if ($bases[0]) {
            if ($bases[1]) {
                if ($bases[2]) {
                    $game["score"][$game["batting"]=="away"?"away":"home"]++;
                    $log["eventAction"] = "Walk forces run";
                } else {
                    $bases[2] = 1;
                }
            } else {
                $bases[1] = 1;
            }
        }
        $bases[0] = 1;
        $log["action"] = "Walk";
    }

    // HIT logic (Single/Double/Triple/Home Run/Grand Slam)
    if ($primary == "Single") {
        if ($bases[2]) { $game["score"][$game["batting"]=="away"?"away":"home"]++; }
        $bases[2] = $bases[1];
        $bases[1] = $bases[0];
        $bases[0] = 1;
        $log["action"] = "Single";
    }

    if ($primary == "Double") {
        if ($bases[2]) { $game["score"][$game["batting"]=="away"?"away":"home"]++; }
        if ($bases[1]) { $game["score"][$game["batting"]=="away"?"away":"home"]++; }
        $bases[2] = $bases[0];
        $bases[1] = 1;
        $bases[0] = 0;
        $log["action"] = "Double";
    }

    if ($primary == "Triple") {
        $runs = array_sum($bases);
        $game["score"][$game["batting"]=="away"?"away":"home"] += $runs;
        $bases = [0,0,1];
        $log["action"] = "Triple (+$runs runs)";
    }

    if ($primary == "Home Run") {
        $runs = array_sum($bases) + 1;
        $game["score"][$game["batting"]=="away"?"away":"home"] += $runs;
        $bases = [0,0,0];
        $log["action"] = "Home Run (+$runs runs)";
    }

    if ($primary == "Grand Slam") {
        $runs = array_sum($bases)==3 ? 4 : 1;
        $game["score"][$game["batting"]=="away"?"away":"home"] += $runs;
        $bases = [0,0,0];
        $log["action"] = "Grand Slam (+$runs runs)";
    }

    // 3rd die events
    if ($event == 2 && $game["outs"] < 3) { // stolen base attempt
        if ($bases[0]) {
            $success = rand(1,6) >= 4;
            if ($success) { $bases[0]=0; $bases[1]=1; }
            else { $game["outs"]++; }
            $log["eventAction"] = "Steal 2nd: " . ($success?"SUCCESS":"CAUGHT");
        } elseif ($bases[1]) {
            $success = rand(1,6) >= 3;
            if ($success) { $bases[1]=0; $bases[2]=1; }
            else { $game["outs"]++; }
            $log["eventAction"] = "Steal 3rd: " . ($success?"SUCCESS":"CAUGHT");
        }
    }

    if ($event == 3) { // wild pitch
        if ($bases[2]) {
            $game["score"][$game["batting"]=="away"?"away":"home"]++;
        }
        $bases[2]=$bases[1]; $bases[1]=$bases[0]; $bases[0]=0;
        $log["eventAction"] = "Wild pitch: runners advance";
    }

    if ($event == 4) { // passed ball → 3rd scores
        if ($bases[2]) {
            $game["score"][$game["batting"]=="away"?"away":"home"]++;
            $bases[2]=0;
            $log["eventAction"] = "Passed ball: runner scores";
        }
    }

    if ($event == 6 && array_sum($bases) > 0) { // pickoff/pickoff-style lead runner out
        $lead = array_search(1, $bases);
        $bases[$lead]=0;
        $game["outs"]++;
        $log["eventAction"] = "Pickoff: lead runner OUT";
    }

    // half-inning flip if 3 outs
    if ($game["outs"] >= 3) {
        $winner = null;
        if ($game["inning"] >= 9 && $game["half"] == "bottom") {
            $winner = $game["score"]["away"] > $game["score"]["home"] ? "away" : "home";
            $gameResult = [
                "inningFinal" => $game["inning"],
                "scoreFinal"  => $game["score"],
                "winner"      => $winner,
                "playedAt"    => date("c")
            ];
            $fileData["season"]["games"][] = $gameResult;
            $fileData["season"]["games"]   = $fileData["season"]["games"];
            $fileData["season"]["games"][] = $gameResult;
            $fileData["season"]["games"]   = array_slice($fileData["season"]["games"], 0);
            $fileData["season"]["games"][] = $gameResult;
            $fileData["season"]["games"]   = array_values($fileData["season"]["games"]);
            $fileData["season"]["games"]   = array_slice($fileData["season"]["games"], 0);
            $fileData["season"]["games"][] = $gameResult;
            $fileData["season"]["games"]   = array_values($fileData["season"]["games"]);
            $fileData["season"]["games"][] = $gameResult;
            $fileData["season"]["games"]   = array_values($fileData["season"]["games"]);
            $fileData["season"]["games"][] = $gameResult;
            $fileData["season"]["games"]   = array_values($fileData["season"]["games"]);
            $fileData["season"]["games"][] = $gameResult;
            $fileData["season"]["games"]   = array_values($fileData["season"]["games"]);
            $fileData["season"]["games"][] = $gameResult;
            $fileData["season"]["games"]   = array_values($fileData["season"]["games"]);

            $fileData["season"]["games"][] = $gameResult;
            $fileData["season"]["games"]   = array_values($fileData["season"]["games"]);

            // reset for next game
            $_SESSION["game"] = null;
            session_destroy();
        } else {
            $game["outs"] = 0;
            $game["bases"] = [0,0,0];
            $game["half"] = $game["half"]=="top"?"bottom":"top";
            $game["batting"] = $game["batting"]=="away"?"home":"away";
            if ($game["half"]=="top") $game["inning"]++;
            $log["inningFlip"] = true;
        }
    }

    // append to JSON history
    $fileData["history"][] = $log;
    file_put_contents($jsonFile, json_encode($fileData, JSON_PRETTY_PRINT));
    $_SESSION["last"] = $log;
}
?>
<!DOCTYPE html>
<html>
<head>
<title>Dice Baseball Game</title>
<style>
body { font-family: Arial, sans-serif; }
.field {
    width:500px; height:500px; background:#2e8b57;
    position:relative; border-radius:50%; margin:20px auto; overflow:hidden;
}
.diamond {
    width:250px; height:250px; background:#d2b48c;
    position:absolute; bottom:120px; left:125px; transform:rotate(45deg);
    border:4px solid white;
}
.base { width:18px; height:18px; background:white; position:absolute; transform:rotate(-45deg); }
#b1 { bottom:210px; right:150px; }
#b2 { bottom:295px; left:240px; }
#b3 { bottom:210px; left:150px; }
.runner {
    width:14px; height:14px; background:red; position:absolute; border-radius:50%;
}
.mound { width:22px; height:22px; background:white; position:absolute; bottom:260px; left:239px; border-radius:50%; }
.fence { width:500px; height:60px; background:white; position:absolute; top:0; left:0; }
.ball {
    width:10px; height:10px; background:white; position:absolute; border-radius:50%;
    bottom:200px; left:245px; display:none;
}
</style>
</head>
<body>

<h2 style="text-align:center">Dice Baseball Game</h2>

<div style="text-align:center">
<p>Inning: <?= $game["inning"] ?> (<?= ucfirst($game["half"]) ?>)</p>
<p>Batting: <?= ucfirst($game["batting"]) ?></p>
<p>Outs: <?= $game["outs"] ?></p>
<p>Score: Away <?= $game["score"]["away"] ?> - Home <?= $game["score"]["home"] ?></p>
<p>Lineup:</p>
<p><strong>Away:</strong> <?= implode(", ", $game["players"]["away"]) ?></p>
<p><strong>Home:</strong> <?= implode(", ", $game["players"]["home"]) ?></p>
</div>

<div class="field">
  <div class="fence"></div>
  <div class="diamond"></div>
  <div class="mound"></div>
  <div class="base" id="b1"></div>
  <div class="base" id="b2"></div>
  <div class="base" id="b3"></div>
  <div class="ball" id="ball"></div>

  <?php
  // render runners on bases
  if ($game["bases"][0]) echo '<div class="runner" style="bottom:210px;right:150px"></div>';
  if ($game["bases"][1]) echo '<div class="runner" style="bottom:295px;left:240px"></div>';
  if ($game["bases"][2]) echo '<div class="runner" style="bottom:210px;left:150px"></div>';
  ?>
</div>

<div style="text-align:center">
<form method="post">
  <button name="roll" style="padding:10px 20px;font-size:18px;">Roll Dice</button>
</form>
</div>

<script>
const last = <?= json_encode($_SESSION["last"] ?? null) ?>;
if (last) triggerAnimations(last.primary, last.eventDie, last.action, last.eventAction);

function triggerAnimations(primary, eventDie, action, eventAction) {
    const ball = document.getElementById("ball");

    if (primary.includes("Home")) {
        ball.style.display="block";
        ball.style.bottom="460px";
        setTimeout(()=>ball.style.display="none",1500);
    }

    if (eventAction && eventAction.includes("Steal")) {
        document.querySelectorAll(".runner").forEach(r=>{
            r.style.transform="scale(1.6)";
            setTimeout(()=>r.style.transform="scale(1)",800);
        });
    }

    if (action && action.includes("out")) {
        const batter = document.createElement("div");
        batter.className="runner";
        batter.style.bottom="50px";
        batter.style.left="240px";
        document.body.appendChild(batter);
        setTimeout(()=>batter.remove(),1000);
    }
}
</script>

</body>
</html>