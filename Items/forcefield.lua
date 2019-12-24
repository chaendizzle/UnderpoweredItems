--Leaky Forcefield
--forcefield.lua

local forcefield = Item("Leaky Forcefield")
forcefield.pickupText = "Harmlessly stuns and knocks back enemies."

forcefield.sprite = Sprite.load("Items/forcefield.png", 2, 16, 16)
forcefield:setTier("use")

forcefield.isUseItem = true
forcefield.useCooldown = 8

if modloader.checkFlag("EVANS_DEBUG_ENABLE") or true then
    registercallback("onPlayerInit", function(player)
        player.useItem = forcefield
    end)
end

forcefield:setLog{
    group = "use",
    description = "Releases a harmless blast that stuns and knocks back enemies.",
    story = "Anything can be a ***** if you're brave enough.",
    destination = "The Shower,\nMy Apartment,\nEarth",
    date = "06/09/2069"
}

local sprites = {
    forcefield = Sprite.load("Items/forcefieldObj.png", 1, 200, 200),
}

local sounds = {
    shield = Sound.find("BubbleShield", "vanilla")
}

local actors = ParentObject.find("actors", "vanilla")

local forcefieldRadius = 400

local forcefieldObj = Object.new("forcefield")
forcefieldObj.sprite = sprites.forcefield

forcefieldObj:addCallback("create", function(self)
    self.spriteSpeed = 0
    self.alpha = 0.8
    self.xscale = 0
    self.yscale = 0
end)

local SyncForceField = net.Packet.new("Sync ForceField", function(player, x, y)
    local inst = forcefieldObj:create(x, y)
end)

forcefield:addCallback("use", function(player, embryo)
    local ff = player:fireExplosion(player.x, player.y, forcefieldRadius / 19.0, forcefieldRadius / 4.0, 0, nil, nil, DAMAGER_NO_PROC + DAMAGER_NO_RECALC)
    ff:getAccessor().stun = 2
    ff:getAccessor().knockback = 20
    ff:getAccessor().slow_on_hit = 10
    if embryo then
        ff:getAccessor().stun = 4
        ff:getAccessor().knockback = 28
        ff:getAccessor().slow_on_hit = 20
    end
    if net.online then
        if net.host then
            local forcefieldInst = forcefieldObj:create(player.x, player.y)
            SyncForceField:sendAsHost(net.ALL, nil, forcefieldInst.x, forcefieldInst.y)
            if embryo then
                local forcefieldInst = forcefieldObj:create(player.x, player.y)
                SyncForceField:sendAsHost(net.ALL, nil, forcefieldInst.x, forcefieldInst.y)
            end
        end
    else
        local forcefieldInst = forcefieldObj:create(player.x, player.y)
        if embryo then
            local forcefieldInst = forcefieldObj:create(player.x, player.y)
        end
    end
    sounds.shield:play(1, 3)
end)

-- heat blast visual effect
forcefieldObj:addCallback("step", function(self)
    self.alpha = self.alpha - 0.055
    self.xscale = self.xscale + 0.08
    self.yscale = self.yscale + 0.08
    if self.alpha <= 0 then
        self:destroy()
    end
end)
