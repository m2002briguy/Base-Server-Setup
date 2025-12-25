<?php
session_start();

const JSON_FILE = "dice_baseball_season.json";

// Initialize season JSON storage
if (!file_exists(JSON_FILE)) {
    $initial = [
        "season" => ["year" => date("Y"), "games" => []],
        "leaders" => ["batting" => [], "pitching" => []],
        "history" => []
    ];
    file_put_contents(JSON_FILE, json_encode($initial, JSON_PRETTY_PRINT));
}
$seasonData = json_decode(file_get_contents(JSON_FILE), true);

// Dice → result chart
$hitChart = [
    2 => "Home Run",
    3 => "Triple",
    4 => "Double",
    5 => "Single",
    6 => "Walk",
    7 => "Strikeout",
    8 => "Flyout",
    9 => "Groundout",
    10 => "Single",
    11 => "Double",
    12 => "Grand Slam"
];

// Start new game session
if (!isset($_SESSION["game"])) {
    $_SESSION["game"] = [
        "inning" => 1,
        "half" => "top",
        "outs" => 0,
        "bases" => [0, 0, 0], // 1B, 2B, 3B
        "score" => ["away" => 0, "home" => 0],
        "innings" => ["away" => [], "home" => []], // per inning run storage
        "batting" => "away",
        "pitching" => "home",
        "lineupIndex" => ["away" => 0, "home" => 0],
        "players" => ["away" => [], "home" => []],
        "pbp" => []
    ];

    // Random name pools
    $first = ["Jake","Omar","Luis","Ken","Travis","Naz","Mike","Julius","Ja","Chris","Brian","Tony","Miguel"];
    $last  = ["Reid","Carlson","Hayes","Conley","Navarro","Randle","Morant","Gonzalez","Thompson","Rivers","Clark"];

    // Generate 9 batters + 1 pitcher per team
    for ($i = 0; $i < 9; $i++) {
        $_SESSION["game"]["players"]["away"][] = [
            "name" => $first[array_rand($first)] . " " . $last[array_rand($last)],
            "pos" => "BAT",
            "stats" => ["AB"=>0,"H"=>0,"2B"=>0,"3B"=>0,"HR"=>0,"BB"=>0,"SB"=>0,"R"=>0,"RBI"=>0,"K"=>0,"OUT"=>0]
        ];
        $_SESSION["game"]["players"]["home"][] = [
            "name" => $first[array_rand($first)] . " " . $last[array_rand($last)],
            "pos" => "BAT",
            "stats" => ["AB"=>0,"H"=>0,"2B"=>0,"3B"=>0,"HR"=>0,"BB"=>0,"SB"=>0,"R"=>0,"RBI"=>0,"K"=>0,"OUT"=>0]
        ];
    }

    // Insert pitcher at slot 0 for each team
    array_unshift($_SESSION["game"]["players"]["away"], [
        "name" => $first[array_rand($first)] . " " . $last[array_rand($last)],
        "pos" => "P",
        "stats" => ["IP"=>0,"ER"=>0,"K"=>0,"SB"=>0,"PICKOFF"=>0]
    ]);
    array_unshift($_SESSION["game"]["players"]["home"], [
        "name" => $first[array_rand($first)] . " " . $last[array_rand($last)],
        "pos" => "P",
        "stats" => ["IP"=>0,"ER"=>0,"K"=>0,"SB"=>0,"PICKOFF"=>0]
    ]);
}

$game = &$_SESSION["game"];

// Roll 2d6 + 1d6 event die
function rollDice(): array {
    return ["2d6" => rand(1,6) + rand(1,6), "event" => rand(1,6)];
}

// Handle dice roll + game logic
if (isset($_POST["roll"])) {
    $roll = rollDice();
    $result = $hitChart[$roll["2d6"]];
    $event  = $roll["event"];

    $batter  = &$game["players"][$game["batting"]][$game["lineupIndex"][$game["batting"]]];
    $pitcher = &$game["players"][$game["pitching"]][0];

    $batter["stats"]["AB"]++;

    $pbp = "{$game['half']} {$game['inning']}: {$batter['name']} vs {$pitcher['name']} rolled {$roll['2d6']} + event {$event} → ";

    switch ($result) {
        case "Single":
            $batter["stats"]["H"]++;
            $batter["stats"]["RBI"] += $game["bases"][2];
            $game["score"][$game["batting"]] += $game["bases"][2];
            if ($game["bases"][2]) $batter["stats"]["R"]++;
            $game["bases"] = [1, $game["bases"][0], $game["bases"][1]];
            $pbp .= "Single";
            break;

        case "Double":
            $batter["stats"]["2B"]++;
            $batter["stats"]["H"]++;
            $batter["stats"]["RBI"] += $game["bases"][1] + $game["bases"][2];
            $game["score"][$game["batting"]] += $game["bases"][1] + $game["bases"][2];
            if ($game["bases"][1] || $game["bases"][2]) $batter["stats"]["R"]++;
            $game["bases"] = [0, 1, $game["bases"][0]];
            $pbp .= "Double";
            break;

        case "Triple":
            $batter["stats"]["3B"]++;
            $batter["stats"]["H"]++;
            $runs = array_sum($game["bases"]);
            $batter["stats"]["RBI"] += $runs;
            $game["score"][$game["batting"]] += $runs;
            $game["bases"] = [0,0,1];
            $pbp .= "Triple (+{$runs} runs)";
            break;

        case "Home Run":
        case "Grand Slam":
            $batter["stats"]["HR"]++;
            $batter["stats"]["H"]++;
            $runs = array_sum($game["bases"]) + 1;
            $batter["stats"]["RBI"] += $runs - 1;
            $game["score"][$game["batting"]] += $runs;
            $game["bases"] = [0,0,0];
            $pbp .= "{$result} (+{$runs} runs)";
            break;

        case "Walk":
            $batter["stats"]["BB"]++;
            $pbp .= "Walk";
            $game["bases"][0] = 1;
            break;

        case "Strikeout":
            $game["outs"]++;
            $batter["stats"]["K"]++;
            $batter["stats"]["OUT"]++;
            $pitcher["stats"]["K"]++;
            $pbp .= "Strikeout (OUT)";
            break;

        case "Flyout":
        case "Groundout":
            $game["outs"]++;
            $batter["stats"]["OUT"]++;
            $pitcher["stats"]["OUT"]++;
            $pbp .= "{$result} (OUT)";
            break;
    }

    // Event die secondary outcomes
    if ($event === 2 && $game["outs"] < 3) {
        if ($game["bases"][0]) {
            $batter["stats"]["SB"]++; $pitcher["stats"]["SB"]++;
            $game["bases"][0]=0; $game["bases"][1]=1;
            $pbp .= " | Stolen Base 2nd SUCCESS";
        } elseif ($game["bases"][1]) {
            $batter["stats"]["SB"]++;
            $game["bases"][1]=0; $game["bases"][2]=1;
            $pbp .= " | Stolen Base 3rd SUCCESS";
        }
    }

    if ($event === 3) {
        $game["score"][$game["batting"]] += $game["bases"][2];
        if ($game["bases"][2]) $batter["stats"]["R"]++;
        $game["bases"] = [0, $game["bases"][0], $game["bases"][1]];
        $pbp .= " | Wild pitch: runners advance";
    }

    if ($event === 4 && $game["bases"][2]) {
        $game["score"][$game["batting"]]++;
        $batter["stats"]["R"]++;
        $game["bases"][2]=0;
        $pbp .= " | Passed ball: runner SCORES";
    }

    if ($event === 6 && array_sum($game["bases"]) > 0) {
        $lead = array_search(1, $game["bases"]);
        $game["bases"][$lead]=0; $game["outs"]++;
        $pitcher["stats"]["PICKOFF"]++;
        $pbp .= " | Pickoff: lead runner OUT";
    }

    $game["pbp"][] = $pbp;

    // Cycle lineup
    $game["lineupIndex"][$game["batting"]] = ($game["lineupIndex"][$game["batting"]] + 1) % 9;

    // End half inning if 3 outs
    if ($game["outs"] >= 3) {
        $game["innings"][$game["batting"]][$game["inning"]] = ($game["innings"][$game["batting"]][$game["inning"]] ?? 0) + 0;
        $game["pbp"][] = "--- Half inning over ---";
        $game["outs"] = 0;
        $game["bases"] = [0,0,0];

        // Swap sides
        $game["half"] = $game["half"] === "top" ? "bottom" : "top";
        [$game["batting"], $game["pitching"]] = [$game["pitching"], $game["batting"]];

        if ($game["half"] === "top") $game["inning"]++;
    }

    // Persist PBP history
    $seasonData["history"][] = ["pbp" => $pbp];
    file_put_contents(JSON_FILE, json_encode($seasonData, JSON_PRETTY_PRINT));
}
?>
<html>
<head>
<style>
.field{width:500px;height:500px;background:#2e8b57;position:relative;border-radius:50%;margin:auto;overflow:hidden}
.diamond{width:250px;height:250px;background:#d2b48c;position:absolute;bottom:120px;left:125px;transform:rotate(45deg);border:4px solid white}
.base{width:18px;height:18px;background:white;position:absolute;transform:rotate(-45deg)}
#hp{width:22px;height:22px;background:white;position:absolute;bottom:150px;left:239px;border-radius:50%}
.runner{width:14px;height:14px;background:red;position:absolute;border-radius:50%}
.mound{width:20px;height:20px;background:white;position:absolute;bottom:260px;left:239px;border-radius:50%}
.fence{width:500px;height:50px;background:white;position:absolute;top:0}
</style>
</head>
<body>

<h2>Dice Baseball Game</h2>

<h3>Scoreboard</h3>
<p><strong>Pitching:</strong> <?= $game["players"][$game["pitching"]][0]["name"] ?> <==</p>
<p><strong>Batting:</strong> <?= $game["players"][$game["batting"]][$game["lineupIndex"][$game["batting"]]]["name"] ?> <==</p>

<p>Inning: <?= $game["inning"] ?> (<?= ucfirst($game["half"]) ?>) | Outs: <?= $game["outs"] ?></p>
<p>Away: <?= $game["score"]["away"] ?> — Home: <?= $game["score"]["home"] ?></p>

<table border="1">
<tr><th>Inning</th><th>Away Runs</th><th>Home Runs</th></tr>
<?php for($i=1;$i<=9;$i++): ?>
<tr><td><?= $i ?></td><td><?= $game["innings"]["away"][$i] ?? 0 ?></td><td><?= $game["innings"]["home"][$i] ?? 0 ?></td></tr>
<?php endfor; ?>
</table>

<div class="field">
  <div class="fence"></div>
  <div class="diamond"></div>
  <div class="mound"></div>
  <div id="hp"></div>

  <?php
  if($game["bases"][0]) echo '<div class="runner" style="bottom:210px;right:150px"></div>';
  if($game["bases"][1]) echo '<div class="runner" style="bottom:295px;left:240px"></div>';
  if($game["bases"][2]) echo '<div class="runner" style="bottom:210px;left:150px"></div>';
  ?>
</div>

<form method="post">
  <button name="roll">Roll 3 Dice</button>
</form>

<h3>Play by Play</h3>
<div>
<?php foreach($game["pbp"] as $line) echo $line."<br>"; ?>
</div>

<h3>Player Stats</h3>
<pre><?php print_r($game["players"]); ?></pre>

</body>
</html>