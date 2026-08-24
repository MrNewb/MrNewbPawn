local foundries = {}
local lastMeltAt = {}
local maxMeltCount = 50
local maxFoundryDistance = 10.0

local function getMeltRewards(itemName)
	local meltItem = Config.MeltableItems and Config.MeltableItems[itemName]
	if not meltItem then return end
	return meltItem.rewards or (meltItem[1] and meltItem)
end

local function isPlayerNearFoundry(src, foundry)
	local playerPed = GetPlayerPed(src)
	if playerPed == 0 or not DoesEntityExist(playerPed) then return false end
	return #(GetEntityCoords(playerPed) - foundry.coords) <= maxFoundryDistance
end

local function canCarryMeltRewards(src, rewards, amount)
	for rewardIndex = 1, #rewards do
		local reward = rewards[rewardIndex]
		if type(reward.itemName) ~= 'string' or reward.itemName == '' then return false end
		local rewardCount = math.floor(tonumber(reward.count) or 0) * amount
		if rewardCount < 1 then return false end
		if not bridge.inventory.canCarryItem(src, reward.itemName, rewardCount) then
			return false
		end
	end
	return true
end

RegisterNetEvent('MrNewbPawn:Server:SmeltItem', function(itemName, amount, foundryId)
	local src = source
	local playerPed = GetPlayerPed(src)
	if playerPed == 0 or not DoesEntityExist(playerPed) then return end
	if type(itemName) ~= 'string' or itemName == '' or #itemName > 64 then return end
	if type(foundryId) ~= 'string' or foundryId == '' or #foundryId > 64 then return end

	amount = tonumber(amount)
	if not amount or amount ~= amount or amount % 1 ~= 0 or amount < 1 or amount > maxMeltCount then
		bridge.notifications.notify(src, { description = locale('Warnings.MaxSmeltBatch', maxMeltCount), type = 'error', duration = 6000 })
		return
	end

	local gameTime = GetGameTimer()
	if lastMeltAt[src] and gameTime - lastMeltAt[src] < 1000 then return end

	local foundry = foundries[foundryId]
	if not foundry or not isPlayerNearFoundry(src, foundry) then
		bridge.notifications.notify(src, { description = locale('Warnings.Canceled'), type = 'error', duration = 6000 })
		return
	end

	local rewards = getMeltRewards(itemName)
	if not rewards or #rewards < 1 then
		bridge.notifications.notify(src, { description = locale('Warnings.InvalidItem'), type = 'error', duration = 6000 })
		return
	end

	if bridge.inventory.getItemCount(src, itemName) < amount then
		bridge.notifications.notify(src, { description = locale('Warnings.DoNotHave'), type = 'error', duration = 6000 })
		return
	end

	if not canCarryMeltRewards(src, rewards, amount) then
		bridge.notifications.notify(src, { description = locale('Warnings.NotEnoughSpace'), type = 'error', duration = 6000 })
		return
	end

	lastMeltAt[src] = gameTime

	if not bridge.inventory.removeItem(src, itemName, amount) then return end

	local grantedRewards = {}
	for rewardIndex = 1, #rewards do
		local reward = rewards[rewardIndex]
		local rewardCount = math.floor(tonumber(reward.count) or 0) * amount
		if not bridge.inventory.addItem(src, reward.itemName, rewardCount) then
			for grantedIndex = 1, #grantedRewards do
				local grantedReward = grantedRewards[grantedIndex]
				bridge.inventory.removeItem(src, grantedReward.itemName, grantedReward.count)
			end
			bridge.inventory.addItem(src, itemName, amount)
			bridge.notifications.notify(src, { description = locale('Warnings.NotEnoughSpace'), type = 'error', duration = 6000 })
			return
		end
		grantedRewards[#grantedRewards + 1] = { itemName = reward.itemName, count = rewardCount }
	end

	if Config.Logging then
		local identifier = bridge.framework.getIdentifier(src)
		local characterName = identifier and bridge.framework.getCharacterName(identifier) or 'Unknown'
		print(('[MrNewbPawn] %s'):format(locale('LogMessages.SmeltedItem', characterName, amount, itemName)))
	end

	bridge.notifications.notify(src, { description = locale('Smelting.SmeltingSuccess'), type = 'success', duration = 6000 })
end)

AddEventHandler('playerDropped', function()
	lastMeltAt[source] = nil
end)

AddEventHandler('onResourceStart', function(resourceName)
	if GetCurrentResourceName() ~= resourceName then return end

	for foundryId, foundry in pairs(Config.FoundryLocations or {}) do
		local zone = foundry.Zone
		if zone and zone.coords then
			foundries[foundryId] = { coords = zone.coords }
		end
	end
end)

AddEventHandler('onResourceStop', function(resourceName)
	if GetCurrentResourceName() ~= resourceName then return end
	foundries = {}
end)
