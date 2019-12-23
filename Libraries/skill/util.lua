util = {}

local enemies = ParentObject.find("enemies", "vanilla")
local lineCollider = Object()
lineCollider.sprite = Sprite("Libraries/skill/linecollider.png", 1, 0, 1)

util.checkLine = function(player, rot, dist)
	local c = lineCollider:create(player.x, player.y)
	c.xscale = dist
	c.yscale = 1
	c.angle = rot or 0
	if util.collidesEnemy(c, c.x, c.y, player:get("team")) then
		c:destroy()
		return true
	end
	c:destroy()
	return false
end

util.collidesEnemy = function(inst, x, y, team)
	for _, enemy in ipairs(enemies:findMatchingOp("team", "~=", team)) do
		if inst:collidesWith(enemy, inst.x, inst.y) then
			return enemy
		end
	end
	return nil
end

util.outsideRoom = function(inst)
	local w, h = Stage.getDimensions()
	return inst.x < -100 or inst.y < -100 or inst.x > w + 100 or inst.y > h + 100
end

util.distance = function(x1, y1, x2, y2)
	return math.sqrt(math.pow(x2 - x1, 2) + math.pow(y2 - y1, 2))
end

util.pointDirection = function(x1, y1, x2, y2)
	return math.atan2(x1 - x2, y1 - y2) * (180/math.pi) + 90
end

util.lengthDir = function(length, dir)
	return math.cos(dir) * length, math.sin(dir) * length
end

-- util.moveDown = function(inst, maxLength)
	-- local my = inst.y + maxLength
	-- local tx, ty = inst.x, inst.y
	-- local inc = (inst.mask or inst.sprite).height * inst.yscale
	-- while not inst:collidesMap(tx, ty) do
		-- ty = ty + inc
		-- if ty > my then
			-- inst.y = my
			-- return
		-- end
	-- end
	-- local lastcoll = true
	-- while true do
		-- local c = inst:collidesMap(tx, ty)
		-- if not c and lastColl and inc == 1 then
			-- break
		-- end
		-- inc = math.ceil(inc / 2)
		-- ty = ty + (inc * (c and -1 or 1))
		-- lastcoll = c
	-- end
-- end

local emptyAnims = {}

util.emptyAnim = function(frames)
	if not emptyAnims[frames] then 
		emptyAnims[frames] = Sprite.load("empty_"..frames, "Graphics/empty.png", frames, 0, 0)
	end
	return emptyAnims[frames]
end