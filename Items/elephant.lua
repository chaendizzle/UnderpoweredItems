--Festive Elephant
--elephant.lua

local elephant = Item("Festive Elephant")
elephant.pickupText = "Swaps use items with another player."

elephant.sprite = Sprite.load("Items/elephant.png", 2, 16, 16)
elephant:setTier("use")

elephant.isUseItem = true
elephant.useCooldown = 0.5
local minCooldown = elephant.useCooldown * 60

if modloader.checkFlag("EVANS_DEBUG_ENABLE") or true then
    registercallback("onPlayerInit", function(player)
        player:set("TEST_SETUP", 1)
    end)
end

elephant:setLog{
    group = "use",
    description = "Swaps use items with another player.",
    story = "Anything can be a ***** if you're brave enough.",
    destination = "XCOM,\nThe Bureau Declassified,\nEarth",
    date = "06/09/2069"
}

local sounds = {
    use = Sound.find("Pickup", "vanilla")
}

local actors = ParentObject.find("actors", "vanilla")

local usePool = {
    Item.find("Thqwib", "vanilla"),
    Item.find("Dynamite Plunger", "vanilla"),
    Item.find("Gigantic Amethyst", "vanilla"),
    Item.find("Glowing Meteorite", "vanilla"),
    Item.find("Carrara Marble", "vanilla"),
    Item.find("Crudely Drawn Buddy", "vanilla"),
    Item.find("Rotten Brain", "vanilla"),
    Item.find("Gold-plated Bomb", "vanilla"),
    Item.find("Snowglobe", "vanilla"),
    Item.find("Sawmerang", "vanilla"),
    Item.find("Captain’s Brooch", "vanilla"),
    Item.find("Drone Repair Kit", "vanilla"),
    Item.find("The Back-up", "vanilla"),
    Item.find("Jar of Souls", "vanilla"),
    Item.find("Safeguard Lantern", "vanilla"),
    Item.find("Unstable Watch", "vanilla"),
    Item.find("Shattered Mirror", "vanilla"),
    Item.find("Shield Generator", "vanilla"),
    Item.find("Prescriptions", "vanilla"),
    Item.find("Massive Leech", "vanilla"),
    Item.find("Instant Minefield", "vanilla"),
    Item.find("Disposable Missile Launcher", "vanilla"),
    Item.find("Pillaged Gold", "vanilla"),
    Item.find("Lost Doll", "vanilla"),
    Item.find("Foreign Fruit", "vanilla"),
    Item.find("Explorer's Key", "vanilla"),
}

registercallback("onPlayerStep", function(player)
    if player:get("TEST_SETUP") == 1 then
        if player.playerIndex == 1 then
            player.useItem = elephant
        end
        player:set("TEST_SETUP", 0)
    end
    if player.useItem == elephant then
        if player:get("elephantCooldown") == nil then
            player:set("elephantCooldown", minCooldown)
        end
        player:set("elephantCooldown", math.max(minCooldown, player:get("elephantCooldown")))
    end
end)

elephant:addCallback("use", function(player, embryo)
    local next = nil
    local prev = nil
    for _, p in ipairs(misc.players) do
        -- init
        if next == nil then
            next = p
        end
        -- if prev player is the player, we are at the next
        if prev == player then
            next = p
            break
        end
        -- update prev
        prev = p
    end
    -- decrease use item cooldown when used
    local cooldown_decrease = 10
    if embryo then
        cooldown_decrease = 20
    end
    if player == next then
        -- if one player, replace with random use item
        local index = math.random(#usePool)
        player.useItem = usePool[index]
    else
        -- if more than one player, swap
        -- store use item cooldown
        next:set("elephantCooldown", next:getAlarm(0))
        next:set("elephantCooldown", math.max(minCooldown, next:get("elephantCooldown") - cooldown_decrease * 60))
        next:setAlarm(0, minCooldown)
        local useItem = next.useItem
        if useItem == nil then
            local index = math.random(#usePool)
            useItem = usePool[index]
        end
        next.useItem = player.useItem
        player.useItem = useItem
        -- set use item cooldown
        if player:get("elephantCooldown") == nil then
            player:set("elephantCooldown", minCooldown)
        end
        player:setAlarm(0, player:get("elephantCooldown"))
    end
    sounds.use:play(1, 3)
end)
