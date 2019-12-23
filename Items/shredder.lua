--Shredder Rounds
--shredder.lua

local shredder = Item("Shredder Rounds")
shredder.pickupText = "Dealing damage temporarily shreds armor."

shredder.sprite = Sprite.load("Items/shredder.png", 1, 16, 16)
shredder:setTier("common")

if modloader.checkFlag("EVANS_DEBUG_ENABLE") or true then
    registercallback("onPlayerInit", function(player)
        player:giveItem(shredder, 1)
    end)
end

shredder:setLog{
    group = "common",
    description = "Dealing damage temporarily shreds armor. More hits shred more armor.",
    story = "Anything can be a ***** if you're brave enough.",
    destination = "Shredded Cheese,\nKraft Singles Production Facility,\nEarth",
    date = "06/09/2069"
}

local sprites = {
}

local sounds = {
}

-- buff
local shredderBuff = Buff.new("shredderBuff")
shredderBuff.sprite = Sprite.load("Items/shredderBuff.png", 1, 9, 7.5)

local c = 0

shredderBuff:addCallback("start", function(actor)
end)

shredderBuff:addCallback("end", function(actor)
    -- remove armor shred
    -- log("BEFORE RESET - ARMOR: " .. tostring(actor:get("armor")) .. ", COUNT: " .. tostring(actor:get("shredderCount")) .. ", SHREDDED: " .. tostring(actor:get("shredderArmor")) .. ", INDEX: " .. tostring(c))
    actor:set("armor", actor:get("armor") + actor:get("shredderArmor"))
    actor:set("shredderArmor", 0)
    -- log("AFTER RESET - ARMOR: " .. tostring(actor:get("armor")) .. ", COUNT: " .. tostring(actor:get("shredderCount")) .. ", SHREDDED: " .. tostring(actor:get("shredderArmor")) .. ", INDEX: " .. tostring(c))
end)

local actors = ParentObject.find("actors", "vanilla")

-- add shredder buff on hit
registercallback("onHit",
function(bullet, actor, hitx, hity)
    local parent = bullet:getParent()
    if type(parent) == "PlayerInstance" then
        local count = parent:countItem(shredder)
        if count > 0 then
            if actor:get("shredderArmor") == nil then
                actor:set("shredderArmor", 0)
            end
            -- let buff know how much armor to shred
            actor:set("shredderCount", count)
            -- remove old buff, but keep value of 'shredderArmor'
            -- this tells us how much we've shredded so far
            local shredderArmor = actor:get("shredderArmor")
            if actor:hasBuff(shredderBuff) then
                actor:removeBuff(shredderBuff)
            end
            actor:set("shredderArmor", shredderArmor)
            -- Armor shred scaling: 10 armor shred base (for 0 items) + 10 per item
            local baseBuff = 10
            local scalingBuff = 10
            local minArmor = -40
            -- log("BEFORE - ARMOR: " .. tostring(actor:get("armor")) .. ", COUNT: " .. tostring(actor:get("shredderCount")) .. ", SHREDDED: " .. tostring(actor:get("shredderArmor")) .. ", INDEX: " .. tostring(c))
            local shred = baseBuff + scalingBuff * actor:get("shredderCount")
            -- can't shred more armor than the unit has
            actor:set("shredderArmor", math.min(actor:get("shredderArmor") + shred, actor:get("armor") - minArmor))
            actor:set("armor", actor:get("armor") - actor:get("shredderArmor"))
            -- log("AFTER - ARMOR: " .. tostring(actor:get("armor")) .. ", COUNT: " .. tostring(actor:get("shredderCount")) .. ", SHREDDED: " .. tostring(actor:get("shredderArmor")) .. ", INDEX: " .. tostring(c))
            -- Duration scaling: 75 steps base (0 items) + 45 per item
            actor:applyBuff(shredderBuff, 75 + 45 * count)
        end
    end
end)
