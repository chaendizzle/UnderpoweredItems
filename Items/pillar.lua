--Pillar Of Power
--pillar.lua

local pillar = Item("Pillar Of Power")
pillar.pickupText = "Chance to enchant the ground on kill."

pillar.sprite = Sprite.load("Items/pillar.png", 1, 16, 16)
pillar:setTier("uncommon")

if modloader.checkFlag("EVANS_DEBUG_ENABLE") or true then
    registercallback("onPlayerInit", function(player)
        player:giveItem(pillar, 1)
    end)
end

pillar:setLog{
    group = "uncommon",
    description = "Killing enemies near the ground can drop pillars, which boost nearby survivors' stats.",
    story = "Anything can be a ***** if you're brave enough.",
    destination = "Suspicious Pillar,\nObelisk,\nMars",
    date = "06/09/2069"
}

local sprites = {
    idle = Sprite.load("Items/pillarObj.png", 1, 50, 23),
}

local sounds = {
    pillar = Sound.load("Items/pillar.ogg")
}

-- buff
local pillarBuff = Buff.new("pillarBuff")
pillarBuff.sprite = Sprite.load("EfBuffPillar", "Items/pillarBuff", 1, 9, 7.5)

local pillarFX = ParticleType.new("Pillar Dust")
pillarFX:color(Color.PURPLE, Color.darken(Color.PURPLE, 0.25))
pillarFX:additive(true)
pillarFX:alpha(0, 1, 0)
pillarFX:life(15, 15)

pillarBuff:addCallback("start", function(player)
    -- Scaling: 20% base (for 0 pillars) + 15% per pillar item
    local baseBuff = 0.2
    local scalingBuff = 0.15
    player:set("pillarOfPowerBuff", player:get("damage") * (baseBuff + player:countItem(pillar) * scalingBuff))
    player:set("damage", player:get("damage") + player:get("pillarOfPowerBuff"))
end)

pillarBuff:addCallback("step", function(player)
    pillarFX:sprite(player.sprite, false, false, false)
    pillarFX:scale(player.xscale + math.random(-0.2, 0.2), player.yscale + math.random(-0.2, 0.2))
    pillarFX:burst("middle", player.x, player.y, 1)
end)
pillarBuff:addCallback("end", function(player)
    player:set("damage", player:get("damage") - player:get("pillarOfPowerBuff"))
end)

local actors = ParentObject.find("actors", "vanilla")

local pillarObj = Object.new("pillarObj")
pillarObj.sprite = sprites.idle

pillarObj:addCallback("create", function(self)
    self.spriteSpeed = 0
    self:set("life", 8*60)
end)

pillarObj:addCallback("step", function(self)
    if self:get("life") <= 0 then
        self.alpha = self.alpha - 0.01
        if self.alpha <= 0 then
            self:destroy()
        end
    else
        self:set("life", self:get("life") - 1)
        for _, actor in ipairs(actors:findAllEllipse(self.x - 60, self.y - 60, self.x + 60, self.y + 60)) do
            if isa(actor, "PlayerInstance") then
                if self:isValid() then
                    -- refresh pillar buff (1 second refresh rate)
                    if not actor:hasBuff(pillarBuff) then
                        actor:applyBuff(pillarBuff, 1*60)
                    end
                end
            end
        end
    end
end)

local SyncPillar = net.Packet.new("Sync Pillar of Power", function(player, x, y)
    local inst = pillarObj:create(x, y)
end)

registercallback("onNPCDeathProc", function(npc, actor)
    if actor:isValid() then
        if actor:countItem(pillar) > 0 then
            if net.host then
                local chance = 0.15
                local downward_dist = 200
                if math.random() <= chance then
                    local pillarInst = pillarObj:create(npc.x, npc.y)
                    local pillarY = pillarInst.y
                    -- Search for ground under the kill point
                    for i=0,downward_dist,1 do
                        if pillarInst:collidesMap(pillarInst.x, pillarInst.y + i) then
                            pillarY = pillarInst.y + i
                            break
                        end
                    end
                    if not pillarInst:collidesMap(pillarInst.x, pillarY) then
                        pillarInst:destroy()
                    else
                        pillarInst.y = pillarY
                        if net.online then
                            SyncPillar:sendAsHost(net.ALL, nil, pillarInst.x, pillarInst.y)
                        end
                        sounds.pillar:play(1, 2.5)
                    end
                end
            end
        end
    end
end)
