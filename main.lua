--Evans Mod
--main.lua

local debugMode = modloader.checkFlag("EVANS_DEBUG_ENABLE")

--[[if debugMode then
	require("debug")
end]]--

--Items
require("Items.pillar")
require("Items.heatblast")
require("Items.shredder")

--Artifacts
