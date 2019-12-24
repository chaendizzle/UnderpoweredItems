--Unstable Battery (AKA Heat Blast)
--heatblast.lua

local heatblast = Item("Unstable Battery")
heatblast.pickupText = "Attacking charges up a powerful blast."

heatblast.sprite = Sprite.load("Items/heatblast.png", 1, 16, 16)
heatblast:setTier("uncommon")

if modloader.checkFlag("EVANS_DEBUG_ENABLE") or true then
    registercallback("onPlayerInit", function(player)
        player:giveItem(heatblast, 1)
    end)
end

heatblast:setLog{
    group = "uncommon",
    description = "Attacks fill up a charge bar. When the bar fills, it creates a heat blast which damages nearby enemies.",
    story = "Anything can be a ***** if you're brave enough.",
    destination = "Argent Tower,\nArgent Facility,\nMars",
    date = "06/09/2069"
}

local heatblast_charge = 9
local heatblast_charge_time = 1

local sprites = {
    indicator = Sprite.load("Items/heatblastUI.png", heatblast_charge, 16, 16),
    blast = Sprite.load("Items/heatblastObj.png", 1, 48, 48),
}

local sounds = {
    blast = Sound.load("Items/heatblast.ogg")
}

local actors = ParentObject.find("actors", "vanilla")

local heatblastObj = Object.new("heatblast")
heatblastObj.sprite = sprites.blast

local SyncHeatBlast = net.Packet.new("Sync Heat Blast", function(player, x, y)
    local inst = heatblastObj:create(x, y)
end)

heatblastObj:addCallback("create", function(self)
    self.spriteSpeed = 0
    self.alpha = 0.8
    self.xscale = 0
    self.yscale = 0
end)

local heatblastRadius = 52

registercallback("onPlayerInit", function(player)
    player:set("heatblastCharge", 0)
end)

-- increase charge on basic attack
registercallback("onPlayerStep", function(player)
    if player:countItem(heatblast) > 0 then
        if player:get("heatblastCharge") == nil then
            player:set("heatblastCharge", 0)
        end
        -- base 100% charge speed (1 item) + 50% per item
        local baseChargeSpeed = 0.5
        local scalingChargeSpeed = 0.5
        local playerZ = player:getAlarm(2) == -1 and player:get("z_skill") == 1
        local playerX = player:getAlarm(3) == -1 and player:get("x_skill") == 1
        local playerC = player:getAlarm(4) == -1 and player:get("c_skill") == 1
        local playerV = player:getAlarm(5) == -1 and player:get("v_skill") == 1
        -- if player is able to use skills and is using one
        if player:get("activity_type") == 0 and (playerZ or playerX or playerC or playerV) then
            -- log("SKILLS: " .. tostring(playerZ) .. ", " .. tostring(playerX) .. ", " .. tostring(playerC) .. ", " .. tostring(playerV))
            player:set("heatblastCharge", player:get("heatblastCharge") + (baseChargeSpeed + scalingChargeSpeed * player:countItem(heatblast)))
        end
        if player:get("heatblastCharge") >= heatblast_charge * heatblast_charge_time then
            -- Damage: 250% base (1 item) + 150% per item
            local baseDamage = 1.0
            local scalingDamage = 1.5
            player:fireExplosion(player.x, player.y, heatblastRadius / 19.0, heatblastRadius / 4.0, baseDamage + scalingDamage * player:countItem(heatblast), nil, nil, DAMAGER_NO_PROC + DAMAGER_NO_RECALC)
            player:set("heatblastCharge", player:get("heatblastCharge") - (heatblast_charge * heatblast_charge_time))
            if net.online then
                if net.host then
                    local heatblastInst = heatblastObj:create(player.x, player.y)
                    SyncHeatBlast:sendAsHost(net.ALL, nil, heatblastInst.x, heatblastInst.y)
                end
            else
                local heatblastInst = heatblastObj:create(player.x, player.y)
            end
            sounds.blast:play(1, 2.5)
        end
    end
end)

-- draw heat blast UI indicator around player
registercallback("onPlayerDrawAbove", function(player)
    if player:countItem(heatblast) > 0 then
        graphics.drawImage{
            image = sprites.indicator,
            x = player.x,
            y = player.y,
            subimage = (player:get("heatblastCharge") / heatblast_charge_time) + 1,
            alpha = 0.5,
        }
    end
end)

-- heat blast visual effect
heatblastObj:addCallback("step", function(self)
    self.alpha = self.alpha - 0.055
    self.xscale = self.xscale + 0.08
    self.yscale = self.yscale + 0.08
    if self.alpha <= 0 then
        self:destroy()
    end
end)

