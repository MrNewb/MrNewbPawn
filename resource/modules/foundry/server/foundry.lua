local foundries = {}
local lastMeltAt = {}

for foundryId, foundry in pairs(Config.FoundryLocations) do
	foundries[foundryId] = foundry.Zone.coords
end

local function isPlayerNearFoundry(src, foundryCoords)
	local ped = GetPlayerPed(src)
	if ped == 0 then return false end
	return #(GetEntityCoords(ped) - foundryCoords) <= 10.0
end

local function canCarryMeltRewards(src, rewards, amount)
	for rewardIndex = 1, #rewards do
		local reward = rewards[rewardIndex]
		if not bridge.inventory.canCarryItem(src, reward.itemName, reward.count * amount) then
			return false
		end
	end
	return true
end

local function grantMeltRewards(src, rewards, amount)
	local granted = {}
	for rewardIndex = 1, #rewards do
		local reward = rewards[rewardIndex]
		local rewardCount = reward.count * amount
		if not bridge.inventory.addItem(src, reward.itemName, rewardCount) then
			for grantedIndex = 1, #granted do
				bridge.inventory.removeItem(src, granted[grantedIndex].itemName, granted[grantedIndex].count)
			end
			return false
		end
		granted[#granted + 1] = { itemName = reward.itemName, count = rewardCount }
	end
	return true
end

local function smeltedItem(itemName, amount, foundryId)
	local src = source
	if src == '' or not IsValidId(itemName) or not IsValidId(foundryId) then return end

	amount = ParseWholeNumber(amount, MAX_MELT_COUNT)
	if not amount then
		return bridge.notifications.notify(src, { description = locale('Warnings.MaxSmeltBatch', MAX_MELT_COUNT), type = 'error', duration = 6000 })
	end
	if IsOnCooldown(lastMeltAt, src) then return end

	local foundryCoords = foundries[foundryId]
	local rewards = GetMeltRewards(itemName)
	local failKey
	if not foundryCoords or not isPlayerNearFoundry(src, foundryCoords) then
		failKey = 'Warnings.Canceled'
	elseif not rewards then
		failKey = 'Warnings.InvalidItem'
	elseif not canCarryMeltRewards(src, rewards, amount) then
		failKey = 'Warnings.NotEnoughSpace'
	elseif not bridge.inventory.removeItem(src, itemName, amount) then
		failKey = 'Warnings.DoNotHave'
	elseif not grantMeltRewards(src, rewards, amount) then
		bridge.inventory.addItem(src, itemName, amount)
		failKey = 'Warnings.NotEnoughSpace'
	end

	if failKey then
		return bridge.notifications.notify(src, { description = locale(failKey), type = 'error', duration = 6000 })
	end

	LogPawnAction(src, 'LogMessages.SmeltedItem', amount, itemName)
	bridge.notifications.notify(src, { description = locale('Smelting.SmeltingSuccess'), type = 'success', duration = 6000 })
end

RegisterNetEvent('MrNewbPawn:server:smeltedItem', smeltedItem)

AddEventHandler('playerDropped', function()
	lastMeltAt[source] = nil
end)
