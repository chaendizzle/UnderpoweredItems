-- Suspicious Anvil
-- anvil.lua

local anvil = Item("Suspicious Anvil")
anvil.pickupText = "Drops an anvil on a grounded enemy."

anvil.sprite = Sprite.load("Items/anvil.png", 2, 16, 16)

anvil.isUseItem = true
anvil.useCooldown = 8

if modloader.checkFlag("EVANS_DEBUG_ENABLE") or true then
    registercallback("onPlayerInit", function(player)
        player.useItem = anvil
    end)
end

local reticule = Sprite.load("Items/anvilTarget.png", 2, 16, 16)
local anvilFX = Sprite.load("anvilStrike", "Items/anvilStrike.png", 12, 22, 153)
local anvilSound = Sound.load("Items/anvil.ogg")

local useSound = Sound.find("Pickup", "vanilla")

anvil:setTier("use")
anvil:setLog{
    group = "use",
    description = "Drops an anvil on the &b&most recently hit enemy&!& for &y&2000%&!& if it is near the ground.",
    story = "Anything can be an anvil if you're brave enough.",
    destination = "Extremely Funny Dog,\nFunny Dog,\nEarth",
    date = "06/09/2069"
}

local enemies = ParentObject.find("enemies", "vanilla")

anvil:addCallback("use", function(player, embryo)
    local playerA = player:getAccessor()
	local count = 1
	-- duplicate for embryo
	if embryo then
		count = 2
	end
	local successful = false
    for i = 1, count do
        for _, inst in ipairs(enemies:findMatching("id", playerA.lastHit)) do
            local target = inst
            if playerA.lastHit ~= nil and target:isValid() and player:get("anvilX") and player:get("anvilY") then
                anvilSound:play(0.95 + math.random() * 0.1)
                misc.shakeScreen(5)
                local bolt = player:fireExplosion(player:get("anvilX"), player:get("anvilY"), anvilFX.width/19, 16/4, 20, anvilFX, nil)
                bolt:set("stun", 2)
                successful = true
            end
        end
    end
    if not successful then
        player:setAlarm(0, -1)
        if useSound:isPlaying() then
            useSound:stop()
        end
    end
end)

registercallback("onPlayerStep", function(player)
    if player.useItem == anvil and player:getAlarm(0) <= 0 then
        local playerA = player:getAccessor()
        for _, inst in ipairs(enemies:findMatching("id", playerA.lastHit)) do
            local target = inst
            local targetY = -10000
            -- Search for ground under the target point
            local downward_dist = 16
            for i=0,downward_dist,1 do
                if target:collidesMap(target.x, target.y + i) then
                    targetY = target.y + i + (target.sprite.height * target.yscale * 0.5)
                    break
                end
            end
            if not target:collidesMap(target.x, targetY) then
                player:set("anvilX", nil)
                player:set("anvilY", nil)
            else
                player:set("anvilX", target.x)
                player:set("anvilY", targetY)
            end
        end
    end
end)

registercallback("onHit", function(damager, hit, x, y)
    if damager:getParent() ~= nil then
        if damager:getParent():isValid() then
            if damager:getParent():get("team") == "player" and isa(damager:getParent(), "PlayerInstance") then
                local player = damager:getParent()
                if player.useItem == anvil and player:getAlarm(0) <= 0 then
                    local playerA = player:getAccessor()
                    playerA.lastHit = hit.id
                end
            end
        end
    end
end)

registercallback("onPlayerDraw", function(player, x, y)
    if player.useItem == anvil and player:getAlarm(0) <= 0 then
        local playerA = player:getAccessor()
        for _, inst in ipairs(enemies:findMatching("id", playerA.lastHit)) do
            local target = inst
            local subimage = 1
            local anvilX = player:get("anvilX")
            local anvilY = player:get("anvilY")
            if player:get("anvilX") == nil or player:get("anvilY") == nil then
                subimage = 2
                anvilX = target.x
                anvilY = target.y
            end
            if playerA.lastHit ~= nil and target:isValid() then
                graphics.drawImage({
                    reticule,
                    anvilX,
                    anvilY,
                    subimage,
                })
            end
        end
    end
end)
