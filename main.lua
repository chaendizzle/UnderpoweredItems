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
require("Items.micromissiles")
require("Items.forcefield")
require("Items.anvil")
require("Items.elephant")

--Artifacts
