--Micro-missiles
--micromissiles.lua

local micromissiles = Item("Micro-Missiles")
micromissiles.pickupText = "Charge up missiles by not attacking."

micromissiles.sprite = Sprite.load("Items/micromissiles.png", 1, 16, 16)
micromissiles:setTier("common")

if modloader.checkFlag("EVANS_DEBUG_ENABLE") or true then
    registercallback("onPlayerInit", function(player)
        player:giveItem(micromissiles, 1)
    end)
end

micromissiles:setLog{
    group = "common",
    description = "Charge up missiles by not attacking. Launches a series of missiles on the next attack.",
    story = "Anything can be a ***** if you're brave enough.",
    destination = "Missile Testing Area,\nArea 51,\nEarth",
    date = "06/09/2069"
}

local actors = ParentObject.find("actors", "vanilla")

local micromissileObj = Object.find("EfMissile", "vanilla")

local SyncMicroMissiles = net.Packet.new("Sync Micro Missiles", function(player, x, y, damage)
    local missileInst = micromissileObj:create(x, y)
    missileInst:set("team", "playerproc")
    missileInst:set("damage", damage)
end)

-- increase charge on basic attack
registercallback("onPlayerStep", function(player)
    if player:countItem(micromissiles) > 0 then
        if player:get("micromissilesCharge") == nil then
            player:set("micromissilesCharge", 0)
            player:set("micromissilesQueued", 0)
        end
        -- base 360 charge time (1 item), -30 per item down to 120
        local baseChargeTime = 390
        local scalingChargeTime = 30
        local chargeTime = math.max(120, baseChargeTime - player:countItem(micromissiles) * scalingChargeTime)
        -- if player is able to use skills and is using one
        local playerZ = player:getAlarm(2) == -1 and player:get("z_skill") == 1
        local playerX = player:getAlarm(3) == -1 and player:get("x_skill") == 1
        local playerC = player:getAlarm(4) == -1 and player:get("c_skill") == 1
        local playerV = player:getAlarm(5) == -1 and player:get("v_skill") == 1
        -- reset micro missiles
        if player:get("activity_type") == 0 and (playerZ or playerX or playerC or playerV) then
            -- base 6 missiles at max charge (1 item), +3 per item
            local baseMissileNum = 3
            local scalingMissileNum = 3
            local chargeScale = math.min(1, player:get("micromissilesCharge") / chargeTime)
            local maxMissiles = (baseMissileNum + player:countItem(micromissiles) * scalingMissileNum)
            local numMissiles = math.floor(chargeScale * maxMissiles)
            -- if enough to launch missiles, queue them for launch
            player:set("micromissilesQueued", player:get("micromissilesQueued") + numMissiles)
            -- reset charge
            player:set("micromissilesCharge", 0)
        else
            -- charge micro missiles, up to chargeTime
            player:set("micromissilesCharge", math.min(chargeTime, player:get("micromissilesCharge") + 1))
        end
        -- if we have a missile queued for launch, fire it
        if player:get("micromissilesQueued") > 0 then
            player:set("micromissilesQueued", player:get("micromissilesQueued") - 1)
            -- base 100% damage (item), +10% per item
            local baseMissileDamage = 1.0
            local scalingMissileDamage = 0.5
            local missileDamage = player:get("damage") * (baseMissileDamage + player:countItem(micromissiles) * scalingMissileDamage)
            if net.online then
                if net.host then
                    local missileInst = micromissileObj:create(x, y)
                    missileInst:set("team", "playerproc")
                    missileInst:set("damage", missileDamage)
                    SyncMicroMissiles:sendAsHost(net.ALL, nil, missileInst.x, missileInst.y, missileDamage)
                end
            else
                local missileInst = micromissileObj:create(player.x, player.y)
            end
        end
    end
end)
