-- DCS - Simple Range Script
-- Version 1.1
-- By Ciribob - https://github.com/ciribob/DCS-SimpleRangeScript
--
-- Change log:
--      - Added more accuracte target distance measurement
--      - Added weapon name for bombing range to scoreboard
--
-- Requires MIST 4.0.57 or newer!
-- Inspired by Original Script by SNAFU http://forums.eagle.ru/showthread.php?t=109174

range  = {}

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


function range.displayMyStrafePitResults(_unitName)
    local _unit = Unit.getByName(_unitName)

    if _unit and _unit:getPlayerName() then
        local _message = "My Top 10 Strafe Pit Results: \n"

        local _results = range.strafePlayerResults[_unit:getPlayerName()]

        if _results == nil then
            _message = _unit:getPlayerName()..": No Score yet"
        else

            local _sort = function( a,b ) return a.hits > b.hits end
            table.sort(_results,_sort)

            local _bestMsg = ""
            local _count = 1
            for _,_result in pairs(_results) do

                _message = _message.."\n"..string.format("%s - Hits %i - %s",_result.zone.name,_result.hits,_result.text)

                if _bestMsg == "" then

                    _bestMsg = string.format("%s - Hits %i - %s",_result.zone.name,_result.hits,_result.text)
                end

                -- 10 runs
                if _count == 10 then
                    break
                end

                _count = _count+1
            end

            _message = _message .."\n\nBEST: ".._bestMsg

        end

        range.displayMessageToGroup(_unit, _message, 10,false)
    end

end

function range.displayStrafePitResults(_unitName)
    local _unit = Unit.getByName(_unitName)

    local _playerResults = {}
    if _unit and _unit:getPlayerName() then

        local _message = "Strafe Pit Results - Top 10:\n"

        for _playerName,_results in pairs(range.strafePlayerResults) do

            local _best = nil
            for _,_result in pairs(_results) do

                if _best == nil or _result.hits > _best.hits then
                    _best = _result
                end
            end

            if _best ~= nil then
                table.insert(_playerResults,{msg = string.format("%s: %s - Hits %i - %s",_playerName,_best.zone.name,_best.hits,_best.text),hits = _best.hits})
            end

        end

        --sort list!

        local _sort = function( a,b ) return a.hits > b.hits end

        table.sort(_playerResults,_sort)

        for _i = 1, #_playerResults do

            _message = _message.."\n[".._i.."]".._playerResults[_i].msg

            --top 10
            if _i > 10 then
                break
            end
        end

        range.displayMessageToGroup(_unit, _message, 10,false)
    end

end

function range.resetRangeStats(_unitName)
    local _unit = Unit.getByName(_unitName)

    if _unit and _unit:getPlayerName() then

        range.strafePlayerResults[_unit:getPlayerName()] = nil
        range.bombingTargets[_unit:getPlayerName()] = nil
        range.displayMessageToGroup(_unit, "Range Stats Cleared", 10,false)
    end
end

function range.displayMyBombingResults(_unitName)
    local _unit = Unit.getByName(_unitName)

    if _unit and _unit:getPlayerName() then
        local _message = "My Top 20 Bombing Results: \n"

        local _results = range.bombPlayerResults[_unit:getPlayerName()]

        if _results == nil then
            _message = _unit:getPlayerName()..": No Score yet"
        else

            local _sort = function( a,b ) return a.distance < b.distance end

            table.sort(_results,_sort)

            local _bestMsg = ""
            local _count = 1
            for _,_result in pairs(_results) do

                _message = _message.."\n"..string.format("%s - %s - %i m",_result.name,_result.weapon,_result.distance)

                if _bestMsg == "" then

                    _bestMsg = string.format("%s - %s - %i m",_result.name,_result.weapon,_result.distance)
                end

                -- 20 runs
                if _count == 20 then
                    break
                end

                _count = _count+1
            end

            _message = _message .."\n\nBEST: ".._bestMsg

        end

        range.displayMessageToGroup(_unit, _message, 10,false)
    end

end

function range.displayBombingResults(_unitName)
    local _unit = Unit.getByName(_unitName)

    local _playerResults = {}
    if _unit and _unit:getPlayerName() then

        local _message = "Bombing Results - Top 15:\n"

        for _playerName,_results in pairs(range.bombPlayerResults) do

            local _best = nil
            for _,_result in pairs(_results) do

                if _best == nil or _result.distance < _best.distance then
                    _best = _result
                end
            end

            if _best ~= nil then
                table.insert(_playerResults,{msg = string.format("%s: %s - %s - %i m",_playerName,_best.name,_best.weapon,_best.distance),distance = _best.distance})
            end

        end

        --sort list!

        local _sort = function( a,b ) return a.distance < b.distance end

        table.sort(_playerResults,_sort)

        for _i = 1, #_playerResults do

            _message = _message.."\n[".._i.."] ".._playerResults[_i].msg

            --top 15
            if _i > 15 then
                break
            end
        end

        range.displayMessageToGroup(_unit, _message, 10,false)
    end

end

-- Handles all world events
range.eventHandler = {}
function range.eventHandler:onEvent(_eventDCS)

    if _eventDCS == nil or _eventDCS.initiator == nil then
        return true
    end


    local status, err = pcall(function(_event)


        if _event.id == 15 then --player entered unit

        -- env.info("Player entered unit")
        if  _event.initiator:getPlayerName() then

            -- reset current status
            range.strafeStatus[_event.initiator:getID()] = nil

            range.addF10Commands(_event.initiator:getName())

            if  range.planes[_event.initiator:getID()] ~= true then

                range.planes[_event.initiator:getID()] = true

                range.checkInZone(_event.initiator:getName())
            end

        end

        return true
        elseif  _event.id == world.event.S_EVENT_HIT and  _event.target  then

            --     env.info("HIT! ".._event.target:getName().." with ".._event.weapon:getTypeName())

            --_event.weapon is currently broken for clients

            --   env.info(_event.initiator:getPlayerName().."HIT! ".._event.target:getName().." with ".._event.weapon:getTypeName())

            --    trigger.action.outText("HIT! ".._event.target:getName().." with ".._event.weapon:getTypeName(),10,false)
            local _currentTarget = range.strafeStatus[_event.initiator:getID()]

            if _currentTarget then

                for _, _targetName in pairs(_currentTarget.zone.targets) do

                    if _targetName == _event.target:getName() then

                        _currentTarget.hits =  _currentTarget.hits + 1

                        return true
                    end
                end
            end

        elseif _event.id == world.event.S_EVENT_SHOT then

            local _weapon = _event.weapon:getTypeName()
            local _weaponStrArray = range.split(_weapon,"%.")

            local _weaponName = _weaponStrArray[#_weaponStrArray]
            if string.match(_weapon, "weapons.bombs") --all bombs
                    or string.match(_weapon, "weapons.nurs") --all rockets
                --                    or _weapon == "weapons.bombs.BDU_50HD"
                --                    or _weapon == "weapons.bombs.BDU_50LD"
                --                    or _weapon == "weapons.nurs.HYDRA_70_M274"
                --                    or _weapon == "weapons.bombs.BDU_33"
            then


                local _ordnance =  _event.weapon

                env.info("Tracking ".._weapon.." - ".._ordnance:getName())
                local _lastBombPos = {x=0,y=0,z=0}

                local _unitName = _event.initiator:getName()
                local trackBomb = function(_previousPos)

                    local _unit = Unit.getByName(_unitName)

                    --    env.info("Checking...")
                    if _unit ~= nil and _unit:getPlayerName() ~= nil then


                        -- when the pcall returns a failure the weapon has hit
                        local _status,_bombPos =  pcall(function()
                            -- env.info("protected")
                            return _ordnance:getPoint()
                        end)

                        if  _status then
                            --ok! still in the air
                            _lastBombPos = {x = _bombPos.x, y = _bombPos.y, z= _bombPos.z }

                            return timer.getTime() + 0.005 -- check again !
                        else
                            --hit
                            -- get closet target to last position
                            local _closetTarget = nil
                            local _distance = nil

                            for _,_targetZone in pairs(range.bombingTargets) do

                                local _temp = range.getDistance(_targetZone.point, _lastBombPos)

                                if _distance == nil or _temp < _distance then

                                    _distance = _temp
                                    _closetTarget = _targetZone
                                end
                            end

                            --   env.info(_distance.." from ".._closetTarget.name)

                            if _distance < 1000 then

                                if not range.bombPlayerResults[_unit:getPlayerName()] then
                                    range.bombPlayerResults[_unit:getPlayerName()]  = {}
                                end

                                local _results =  range.bombPlayerResults[_unit:getPlayerName()]

                                table.insert(_results,{name=_closetTarget.name, distance =_distance, weapon = _weaponName })

                                local _message = string.format("%s - %i m from bullseye of %s",_unit:getPlayerName(), _distance,_closetTarget.name)

                                trigger.action.outText(_message,10,false)

                            end
                        end

                    end

                    return
                end

                timer.scheduleFunction(trackBomb, nil, timer.getTime() + 1)
            end
        end


        return true

    end, _eventDCS)

    if (not status) then
        env.error(string.format("Error while handling event %s", err),false)
    end
end


function range.checkInZone(_unitName)

    --check if we're in any zone
    -- if we're in a zone, start looking for hits on target
    -- if we're no longer in a zone but were previously, list the result and store the run
    local _unit = Unit.getByName(_unitName)

    if _unit and _unit:getPlayerName() then

        timer.scheduleFunction(range.checkInZone, _unitName, timer.getTime() + 1)

        local _unitPos = _unit:getPosition().p

        -- currently strafing?
        local _currentStrafeRun =  range.strafeStatus[_unit:getID()]

        if _currentStrafeRun ~= nil then
            if _currentStrafeRun.zone.polygon~=nil and mist.pointInPolygon(_unitPos,_currentStrafeRun.zone.polygon,_currentStrafeRun.zone.maxAlt) then
                --still in zone, do nothing
                _currentStrafeRun.time = _currentStrafeRun.time+1
            elseif _currentStrafeRun.zone.polygon~=nil then

                _currentStrafeRun.time = _currentStrafeRun.time+1

                if _currentStrafeRun.time <= 3 then
                    range.strafeStatus[_unit:getID()] = nil

                    local _msg = _unit:getPlayerName()..": left ".._currentStrafeRun.zone.."  too quickly. No Score. "
                    range.displayMessageToGroup(_unit, _msg, 10,true)
                else
                    local _result = range.strafeStatus[_unit:getID()]

                    local _msg = _unit:getPlayerName().." "

                    if _result.hits >= _result.zone.goodPass then
                        _msg  = _msg .."GOOD PASS with ".._result.hits.." on "
                        _result.text = "GOOD PASS"
                    else
                        _msg  = _msg .."INEFFECTIVE PASS with ".._result.hits.." on "
                        _result.text = "INEFFECTIVE PASS"
                    end

                    _msg = _msg .._result.zone.name

                    trigger.action.outText(_msg,10,false)

                    range.strafeStatus[_unit:getID()] = nil

                    --  Save so the player can retrieve them
                    local _stats = range.strafePlayerResults[_unit:getPlayerName()] or {}

                    table.insert(_stats,_result)

                    range.strafePlayerResults[_unit:getPlayerName()] = _stats
                end

            end

        else
            -- check to see if we're in a zone
            for _,_targetZone in pairs(range.strafeTargets) do

                if  _targetZone.polygon~=nil and mist.pointInPolygon(_unitPos,_targetZone.polygon,_targetZone.maxAlt) then

                    if  range.strafeStatus[_unit:getID()] == nil then

                        range.strafeStatus[_unit:getID()] = {hits = 0, zone = _targetZone, time = 1 }

                        local _msg = _unit:getPlayerName().." rolling in on ".._targetZone.name
                        range.displayMessageToGroup(_unit, _msg, 10,true)

                    end

                    break
                end
            end
        end
    else

        timer.scheduleFunction(range.checkInZone, _unitName, timer.getTime() + 5)
    end
end

function range.getGroupId(_unit)

    local _unitDB =  mist.DBs.unitsById[tonumber(_unit:getID())]
    if _unitDB ~= nil and _unitDB.groupId then
        return _unitDB.groupId
    end

    return nil
end

function range.displayMessageToGroup(_unit, _text, _time,_clear)

    local _groupId = range.getGroupId(_unit)
    if _groupId then
        if _clear == true then
            trigger.action.outTextForGroup(_groupId, _text, _time,_clear)
        else
            trigger.action.outTextForGroup(_groupId, _text, _time)
        end
    end
end

--range.gunTypes ={"weapons.shells.GAU8_30_AP","weapons.shells.GAU8_30_HE","weapons.shells.GAU8_30_TP","weapons.shells.M61_20_HE","weapons.shells.M61_20_AP","weapons.shells.M2_12_7_t","weapons.shells.7_62x51","weapons.shells.M134_7_62_T","weapons.shells.M134_7_62x51",
--    "weapons.shells.M20_50_aero_APIT","weapons.shells.M20_50_aero_APIT","weapons.shells.GSH301_30_HE","weapons.shells.GSH301_30_AP","weapons.shells.GSH23_23_HE_T","weapons.shells.2A42_30_HE","weapons.shells.2A42_30_AP","weapons.shells.GSH23_23_HE_T",
--    "weapons.shells.YakB_12_7_T","weapons.shells.YakB_12_7","weapons.shells.PKT_7_62_T","weapons.shells.PKT_7_62","weapons.shells.VOG17"}

range.addedTo = {}
function range.addF10Commands(_unitName)

    local _unit = Unit.getByName(_unitName)
    if _unit then

        local _group =  mist.DBs.unitsById[tonumber(_unit:getID())]

        if _group  then

            local _gid =  _group.groupId
            if not range.addedTo[_gid] then
                range.addedTo[_gid] = true

                local _rootPath = missionCommands.addSubMenuForGroup(_gid, "Range")

                missionCommands.addCommandForGroup(_gid,"My Strafe results", _rootPath, range.displayMyStrafePitResults, _unitName)
                missionCommands.addCommandForGroup(_gid,"All Strafe results", _rootPath, range.displayStrafePitResults, _unitName)
                missionCommands.addCommandForGroup(_gid,"My Bombing results", _rootPath, range.displayMyBombingResults, _unitName)
                missionCommands.addCommandForGroup(_gid,"All Bombing results", _rootPath, range.displayBombingResults, _unitName)
                missionCommands.addCommandForGroup(_gid,"Reset Stats", _rootPath, range.resetRangeStats, _unitName)
            end

        end
    end

end



--get distance in meters assuming a Flat world
function range.getDistance(_point1, _point2)

    local xUnit = _point1.x
    local yUnit = _point1.z
    local xZone = _point2.x
    local yZone = _point2.z

    local xDiff = xUnit - xZone
    local yDiff = yUnit - yZone

    return math.sqrt(xDiff * xDiff + yDiff * yDiff)
end

--http://stackoverflow.com/questions/1426954/split-string-in-lua
function range.split(str, sep)
    local result = {}
    local regex = ("([^%s]+)"):format(sep)
    for each in str:gmatch(regex) do
        table.insert(result, each)
    end
    return result
end

--init

range.strafeStatus = {}
range.strafePlayerResults = {}
range.bombPlayerResults = {}
range.planes = {}


for _,_targetZone in pairs(range.strafeTargets) do

    if Group.getByName(_targetZone.name) then
        local _points = mist.getGroupPoints(_targetZone.name)

        env.info("Done for: ".._targetZone.name)
        _targetZone.polygon = _points
    else
        env.info("Couldn't find: ".._targetZone.name)
        _targetZone.polygon = nil
    end


end


local _tempTargets = range.bombingTargets

range.bombingTargets = {}

for _,_targetZone in pairs(_tempTargets) do

    local _triggerZone = trigger.misc.getZone(_targetZone)

    if _triggerZone then
        table.insert(range.bombingTargets,{name=_targetZone,point=_triggerZone.point})
        env.info("Done for: ".._targetZone)
    else
        env.info("Failed for: ".._targetZone)

    end

end


world.addEventHandler(range.eventHandler)

