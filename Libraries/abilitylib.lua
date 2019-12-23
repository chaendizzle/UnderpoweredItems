--RoR2 Demake Project
--Made by N4K0
--abilitylib.lua
--File created 2019/04/08

--[[
    NOTE: This library contains a few key functions I thought might be important to explain
    to use this library in any of your files, or multiple, use
    require("abilitylib")

]]

Abilities =
{
--Variables used to control the player's abilities
--These will be our cooldown numbers after we find them
["zCooldown"] = -1,
["xCooldown"] = -1,
["cCooldown"] = -1,
["vCooldown"] = -1,
["useCooldown"] = -1,
--These are our internal cooldown timers
["zCurrent"] = -1,
["xCurrent"] = -1,
["cCurrent"] = -1,
["vCurrent"] = -1,
["useCurrent"] = -1,
--Alarm variables pertaining to the alarm number of each skill
["zAlarm"] = 2,
["xAlarm"] = 3,
["cAlarm"] = 4,
["vAlarm"] = 5,
["useAlarm"] = 0,
--Some extra variables for obfuscation
["defaultUseCount"] = 1,
["zeroAlarm"] = -1,
}

--This is a table indexing all our cooldown values with the above table, use like this to assign a variable in Abilities: Abilities[cooldownTimers[index]]
local cooldownTimers =
{
    "zCooldown",
    "xCooldown",
    "cCooldown",
    "vCooldown",
    "useCooldown"
}

--This is a table that assigns a variable UseCount to our playerInstance, use like this: player:set(useCounts[index], value)
local useCounts =
{
    "zUseCount",
    "xUseCount",
    "cUseCount",
    "vUseCount",
    "useUseCount"
}

--This is a table indexing all our key values with the above table, use like this to assign a variable in Abilities: Abilities[alarmValues[index]]
local alarmValues =
{
    "zAlarm",
    "xAlarm",
    "cAlarm",
    "vAlarm",
    "useAlarm"
}

registercallback("onPlayerInit",
function(player)
    Abilities.initCooldowns(player)
    Abilities.initUseCount(player)
end)

registercallback("onPlayerDeath",
function(player)
    Abilities.resetAllCooldowns()
end)

--NOTE: This function initializes all cooldowns on the player, use only in the "onPlayerInit" callback
--PARAMETERS: {playerInstance}
function Abilities.initCooldowns(player)
    for i = 1, 4 do
        player:activateSkillCooldown(i)
        Abilities[cooldownTimers[i]] = player:getAlarm(Abilities[alarmValues[i]])
        player:setAlarm(Abilities[alarmValues[i]], Abilities.zeroAlarm)
    end
end

--NOTE: This function initializes the amount of uses the player has.  Do not call this unless you want to reset their uses back to 1!
--PARAMETERS: {playerInstance}
function Abilities.initUseCount(player)
    for i = 1, 5 do
        player:set(useCounts[i], Abilities.defaultUseCount)
    end
end

--NOTE: This function resets all our cooldown timers
function Abilities.resetAllCooldowns()
    for i = 1, 5 do
        Abilities[cooldownTimers[i]] = Abilities.zeroAlarm
    end
end

--NOTE: This function will override the relevant cooldown timer saved in the variable, only change this after initialization or it will get reset!
--PARAMETERS: {playerInstance, 1 2 3 4 5 nil, number}
function Abilities.cooldownOverride(player, skill, value)
    Abilities[cooldownTimers[skill]] = value
end

--NOTE: This function resets the player's given skill cooldown, skill must be a number 1 to 5
--PARAMETERS: {playerInstance, 1 2 3 4 5 nil}
function Abilities.resetCooldown(player, skill)
    if skill == nil then
        for i = 1, 5 do
            player:setAlarm(Abilities[alarmValues[i]], Abilities.zeroAlarm)
        end
    else
            player:setAlarm(Abilities[alarmValues[skill]], Abilities.zeroAlarm)
    end
end

--NOTE: This function sets the player's cooldown to the given number, if you want the cooldown to be the new number every time, use cooldownOverride instead
--PARAMETERS: {playerInstance, 1 2 3 4 5 nil, number}
function Abilities.setCooldown(player, skill, value)
    if skill == nil then
        for i = 1, 5 do
            player:setAlarm(Abilities[alarmValues[i]], value)
        end
    else
        player:setAlarm(Abilities[alarmValues[skill]], value)
    end
end

--NOTE: Increases player's use count by the given value on the given skill, pass nil to increase all use counts
--PARAMETERS: {playerInstance, 1 2 3 4 5 nil, number}
function Abilities.incrementUseCount(player, skill, value)
    if skill == nil then
        for i = 1, 5 do
            player:set(Abilities[useCounts[i]], player:get(Abilities[useCounts[i]] + value))
        end
    else
        player:set(Abilities[useCounts[skill]], player:get(Abilities[useCounts[skill]] + value))
    end
end