
# DCS-SimpleRangeScript

A simple range script giving a per user and server wide scoreboard for bomb / rocket accuracy as well as shots on a target e.g. a strafe pit.

A complete test mission is included.

You can also edit the rangescript.lua file to change some configuration options. Make sure you re-add the lua file to the mission after editing by deleting the trigger that loads the file, then readding the trigger and the DO SCRIPT FILE action. 

## Setup in Mission Editor

### Initial Script Setup
**This script requires MIST version 4.0.57 or above: https://github.com/mrSkortch/MissionScriptingTools**

**I recommend using these Range Targets:  http://www.476vfightergroup.com/downloads.php?do=file&id=287**

First make sure MIST is loaded, either as an Initialization Script  for the mission or the first DO SCRIPT with a "TIME MORE" of 1. "TIME MORE" means run the actions after X seconds into the mission.

Load the rangescript.lua a few seconds after MIST using a second trigger with a "TIME MORE" and a DO SCRIPT of rangescript.lua. 

When testing in the mission editor, you'll need to jump into your aircraft or another slot, wait for the rangescript.lua to be loaded and then jump back into your aircraft again.

You'll know its activated when you can see the F10 Radio Option "Range". 

### Script Configuration

The script has two different configuration sections, range.strafeTargets which sets up the strafe pits and their targets and range.bombingTargets for bombing targets.

#### Strafe Pit Setup
```lua

range.strafeTargets = {

    {
        -- GROUP NAME for the unit whos waypoints enclose the target
        name = "left_zone",
        maxAlt = 1500,
        goodPass = 20,
        targets = {'Strafe pit Left 3','Strafe pit Left 2','Strafe pit Left 1'}, -- which target(s) are valid for this zone - Unit Names
    },
    {
        name = "right_zone", -- GROUP NAME for the unit whos waypoints enclose the target
        maxAlt = 1500,
        goodPass = 20,
        targets = {'Strafe pit Right 3','Strafe pit Right 2','Strafe pit Right 1'}, -- which target(s) are valid for this zone - Unit Names
    }
}
```

The configuration above allows the mission to have two strafe pits, each with up to 3 targets. When the player aircraft is within the zone containing by waypoints of the UNIT named "left_zone", shots onto the target UNITS 'Strafe pit Left 3','Strafe pit Left 2' or'Strafe pit Left 1' are counted and added to the player score.

An example setup of one strafe pit and target is shown below. The left_zone UNIT is set to late activated so that it doesnt actually appear when we run the mission. You can see the waypoints setting out the strafe pit zone. 

![alt text](http://i1056.photobucket.com/albums/t379/cfisher881/Range%20Zone_zpspf7gpap4.jpg~original "Strafe Pit Container")

Next the strafe pit target is setup, I recommend you use this mod pack: http://www.476vfightergroup.com/downloads.php?do=file&id=287 for the strafe pits as the one in the sample mission will only survive one or two passes! Make sure the unit name is set to one of the names allowed for that strafe pit e.g. 'Strafe pit Left 1'

![alt text](http://i1056.photobucket.com/albums/t379/cfisher881/Range%20Zone_zpspf7gpap4.jpg~original "Strafe Pit Unit")

#### Bombing Targets

Bombing targets are just trigger zones. Place a trigger zone on the map and name it one of the names in the list below or add your own names to the list.

Bombs / Rockets are only counted if they're in flight for 1 second or longer and need to be within 1000m of the target to count.

```lua
-- Zone Names
range.bombingTargets = {

    "target1",
    "target2",
    "target3",
    "target4",
    "target5",
    "target6",
    "target7",
    "target8",
    "target9",
    "target10",
    "target11",
    "target12",
    "target13",
    "target14",
    "target15",

}
```



