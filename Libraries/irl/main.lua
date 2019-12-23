local removal_functions = {}

itemremover = {}

function itemremover.setRemoval(item, func)
	if type(item) ~= "Item" then error("First argument of itemremover.setRemoval must be an Item.") end
	if type(func) ~= "function" then error("Second argument of itemremover.setRemoval must be a function.") end
	removal_functions[item] = func
end

function itemremover.getRemoval(item)
	if type(item) ~= "Item" then error("The argument of itemremover.getRemoval must be an Item.") end
	return removal_functions[item]
end

function itemremover.removeItem(player, item, force)
	if type(player) ~= "PlayerInstance" then error("First argument of itemremover.removeItem must be a PlayerInstance.") end
	if type(item) ~= "Item" then error("Second argument of itemremover.removeItem must be an Item.") end
	if force ~= nil and type(force) ~= "boolean" then error("Third argument of itemremover.removeItem must be a boolean or nil.") end
	
	local count = player:countItem(item)
	if count > 0 then
		if removal_functions[item] then
			player:removeItem(item)
			removal_functions[item](player, count - 1)
			return true
		elseif force then
			player:removeItem(item)
			return true
		else
			error("Item '"..item:getName().."' from '"..item:getOrigin().."' does not have a removal function set.")
		end
	else
		return false
	end
end

export("itemremover")

function removal(name, func)
	local i = Item.find(name, "vanilla")
	if i then
		itemremover.setRemoval(i, func)
	else
		log("Item '"..name.."' does not exist.")
	end
end

function adjust(player, var, amt)
	player:set(var, player:get(var) + amt)
end

require "Libraries.irl.common"
require "Libraries.irl.uncommon"
require "Libraries.irl.rare"
require "Libraries.irl.other"

return itemremover