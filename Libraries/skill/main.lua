require "Libraries.skill.util"

Skill = {}

local skill_event_isvalid = {init = true, all = true, postAll = true, last = true, draw = true}
local skills = {}
local activeSkill = {}
local prevFrame = {}
local playerSkills = {}
local placeholderIcon = Sprite("Libraries/skill/placeholder.png", 1, 0, 0)

local errors = {
	setEvent = "Invalid event for skill:setEvent, must be one of 'init', 'all', 'postAll', 'last', or a number.",
}

local function genericError(where, what)
	error("Invalid type for "..where..", must be '"..what.."'.")
end

registercallback("onGameStart", function()
	playerSkills = {}
	activeSkill = {}
	prevFrame = {}
end)

local function updatePlayerSkill(player, index, skill)
	player:setSkill(index, skill.displayName, skill.description, skill.icon, skill.iconIndex, skill.cooldown)
end

local function fireEvent(skill, event, player)
	if skills[skill].events[event] then
		skills[skill].events[event](player)
	end
end

local function activatePlayerSkill(player, index)
	local skill = playerSkills[player][index]
	if skill then
		local events = skills[skill].events
		if events.init and events.init(player, index) then 
			activeSkill[player] = {skill = skill, index = index}
		end
	end
end

Skill.set = function(player, index, skill)
	if not playerSkills[player] then playerSkills[player] = {} end
	playerSkills[player][index] = skill
	updatePlayerSkill(player, index, skill)
end

Skill.get = function(player, index)
	if playerSkills[player] then
		return playerSkills[player][index]
	end 
	return nil
end

Skill.activate = function(player, index)
	activatePlayerSkill(player, index)
end

Skill.init = function(survivor)
	if not type(survivor) == "survivor" then genericError("Skill.init", "survivor") end
	survivor:addCallback("useSkill", activatePlayerSkill)
	survivor:addCallback("step", function(player, index)
		-- print("onSkil Subimage:", player.subimage, player:get("activity"))
		local aSkill = activeSkill[player]
		if aSkill then
			local events = skills[aSkill.skill].events
			local frame = math.floor(player.subimage)
			if frame > (prevFrame[player] or 0) and events[frame] then
				events[frame](player, aSkill.index)
			end
			if events.all then events.all(player, aSkill.index) end
			if events.postAll then events.postAll(player, aSkill.index) end
			if math.floor(player.subimage) == player.sprite.frames then
				if events.last then
					events.last(player, aSkill.index)
				end
				activeSkill[player] = nil
				prevFrame[player] = nil
			else
				prevFrame[player] = frame
			end
		end
	end)
	survivor:addCallback("draw", function(player)
		local aSkill = activeSkill[player]
		if aSkill and skills[aSkill.skill].events.draw then
			skills[aSkill.skill].events.draw(player)
		end
	end)
end

-- Skill.activate = function(player, skill, speed)
	-- activeSkill[player] = {skill = skill, speed = speed or skills[skill].speed, progress = 1}
-- end

-- registercallback("postStep", function()
	-- for _, player in ipairs(misc.players) do
		-- local a = activeSkill[player]
		-- print("ha")
		-- if a then
			-- local prev = math.floor(a.progress)
			-- a.progress = a.progress + a.speed
			-- local curr = math.floor(a.progress)
			-- print(prev, curr)
			-- while curr > prev do
				-- fireEvent(a.skill, prev, player)
				-- prev = prev + 1
			-- end
			-- fireEvent(a.skill, "all", player)
			-- fireEvent(a.skill, "postAll", player)
			-- if a.progress > a.skill.duration then
				-- fireEvent(a.skill, "last", player)
				-- activeSkill[player] = nil
			-- end
		-- end
	-- end
-- end)

Skill.new, skill_mt = newtype("Skill")

function skill_mt:__init()
	skills[self] = {}
	skills[self].events = {}
	skills[self].displayName = ""
	skills[self].description = ""
	skills[self].icon = placeholderIcon
	skills[self].duration = 0
	skills[self].speed = 1
	skills[self].iconIndex = 1
	skills[self].cooldown = 60
end

local skill_lookup = {
	displayName = {
		get = function(self)
			return skills[self].displayName
		end,
		set = function(self, v)
			if not type(v) == "string" then genericError("displayName", "string") end
			skills[self].displayName = v
		end
	},
	description = {
		get = function(self)
			return skills[self].description
		end,
		set = function(self, v)
			if not type(v) == "string" then genericError("description", "string") end
			skills[self].description = v
		end
	},
	icon = {
		get = function(self)
			return skills[self].icon
		end,
		set = function(self, v)
			if not type(v) == "Sprite" then genericError("icon", "Sprite") end
			skills[self].icon = v
		end
	},
	-- duration = {
		-- get = function(self)
			-- return skills[self].duration
		-- end,
		-- set = function(self, v)
			-- if not type(v) == "number" then genericError("duration", "number") end
			-- skills[self].duration = v
		-- end
	-- },
	-- speed = {
		-- get = function(self)
			-- return skills[self].speed
		-- end,
		-- set = function(self, v)
			-- if not type(v) == "number" then genericError("speed", "number") end
			-- skills[self].speed = v
		-- end
	-- },
	iconIndex = {
		get = function(self)
			return skills[self].iconIndex
		end,
		set = function(self, v)
			if not type(v) == "number" then genericError("iconIndex", "number") end
			skills[self].iconIndex = v
		end
	},
	cooldown = {
		get = function(self)
			return skills[self].cooldown
		end,
		set = function(self, v)
			if not type(v) == "number" then genericError("cooldown", "number") end
			skills[self].cooldown = v
		end
	},
	setEvent = function(s, event, func)
		if type(event) == "string" then
			if not skill_event_isvalid[event] then
				error(errors.setEvent)
			end
		elseif type(event) ~= "number" then
			error(errors.setEvent)
		end
		skills[s].events[event] = func
	end, 
	refresh = function(s)
		for player, skills in pairs(playerSkills) do
			for index, skill in pairs(player) do
				if skill == s then
					updatePlayerSkill(player, index, skill)
				end
			end
		end
	end
}

skill_mt.__index = function(t, k)
	local s = skill_lookup[k]
	if s then
		if type(s) == "table" then
			return s.get(t)
		else
			return s
		end
	else
		error(string.format("Skill does not contain a field '%s'", tostring(k)), 2)
	end
end
	
skill_mt.__newindex = function(t, k, v)
	local s = skill_lookup[k]
	if type(s) == "table" then
		s.set(t, v)
	else
		error(string.format("Skill does not contain a field '%s'", tostring(k)), 2)
	end
end

export("Skill")