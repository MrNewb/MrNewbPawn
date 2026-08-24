local pawnShops = {}
local lastTradeAt = {}
local maxTradeCount = 100
local maxShopDistance = 6.0

local function getBuybackPrice(sellPrice)
	local markupPercent = Config.PurchaseMarkup or 20
	if type(markupPercent) ~= 'number' or markupPercent <= 0 then return sellPrice end
	return math.ceil(sellPrice * (100 + markupPercent) / 100)
end

local function getPlayerCharacterName(src)
	local identifier = bridge.framework.getIdentifier(src)
	if not identifier then return 'Unknown' end
	return bridge.framework.getCharacterName(identifier) or 'Unknown'
end

local function isPlayerNearShop(src, shop)
	local playerPed = GetPlayerPed(src)
	if playerPed == 0 or not DoesEntityExist(playerPed) then return false end
	local shopCoords = shop.coords
	if not shopCoords then return false end
	local x, y, z = shopCoords.x, shopCoords.y, shopCoords.z
	if type(x) ~= 'number' or type(y) ~= 'number' or type(z) ~= 'number' then return false end
	return #(GetEntityCoords(playerPed) - vector3(x, y, z)) <= maxShopDistance
end

local function sellPawnItem(src, shop, itemName, count)
	local sellPrice = shop.itemlist[itemName]
	if type(sellPrice) ~= 'number' or sellPrice < 1 then return false end

	if bridge.inventory.getItemCount(src, itemName) < count then
		bridge.notifications.notify(src, { description = locale('Warnings.DoNotHave'), type = 'error', duration = 6000 })
		return false
	end

	if not bridge.inventory.removeItem(src, itemName, count) then
		bridge.notifications.notify(src, { description = locale('Warnings.DoNotHave'), type = 'error', duration = 6000 })
		return false
	end

	local payout = sellPrice * count
	if not bridge.framework.addMoney(src, 'cash', payout) then
		bridge.inventory.addItem(src, itemName, count)
		bridge.notifications.notify(src, { description = locale('Warnings.SellFailed'), type = 'error', duration = 6000 })
		return false
	end

	if Config.PurchaseStock then
		shop.stock[itemName] = (shop.stock[itemName] or 0) + count
	end

	if Config.Logging then
		print(('[MrNewbPawn] %s'):format(locale('LogMessages.SoldItem', getPlayerCharacterName(src), count, itemName, payout)))
	end
	bridge.notifications.notify(src, { description = locale('PawnShop.SoldItem', count, itemName, payout), type = 'success', duration = 6000 })
	return true
end

local function buyPawnedItem(src, shop, itemName, count)
	local stockCount = shop.stock[itemName] or 0
	if stockCount < count then
		bridge.notifications.notify(src, { description = locale('PawnShop.NoStock'), type = 'error', duration = 6000 })
		return false
	end

	local sellPrice = shop.itemlist[itemName]
	if type(sellPrice) ~= 'number' or sellPrice < 1 then return false end

	local totalCost = getBuybackPrice(sellPrice) * count
	if totalCost < 1 then return false end

	local cashBalance = tonumber(bridge.framework.getMoney(src, 'cash')) or 0
	-- Some frameworks return a wrapped uint32 when cash is negative.
	if cashBalance >= 0x80000000 then
		cashBalance = cashBalance - 0x100000000
	end
	if cashBalance < totalCost then
		bridge.notifications.notify(src, { description = locale('Warnings.NotEnoughMoney'), type = 'error', duration = 6000 })
		return false
	end

	if not bridge.inventory.canCarryItem(src, itemName, count) then
		bridge.notifications.notify(src, { description = locale('Warnings.NotEnoughSpace'), type = 'error', duration = 6000 })
		return false
	end

	if not bridge.framework.removeMoney(src, 'cash', totalCost) then return false end

	if not bridge.inventory.addItem(src, itemName, count) then
		bridge.framework.addMoney(src, 'cash', totalCost)
		bridge.notifications.notify(src, { description = locale('Warnings.NotEnoughSpace'), type = 'error', duration = 6000 })
		return false
	end

	-- Read stock again after money so a yielding money hook cannot sell the same units twice.
	shop.stock[itemName] = (shop.stock[itemName] or 0) - count
	if shop.stock[itemName] <= 0 then
		shop.stock[itemName] = nil
	end

	if Config.Logging then
		print(('[MrNewbPawn] %s'):format(locale('LogMessages.PurchasedItem', getPlayerCharacterName(src), count, itemName, totalCost)))
	end
	bridge.notifications.notify(src, { description = locale('PawnShop.PurchasedPawnedItem', count, itemName, totalCost), type = 'success', duration = 6000 })
	return true
end

lib.callback.register('MrNewbPawn:Callback:GetPawnedStock', function(src, shopId)
	local playerPed = GetPlayerPed(src)
	if playerPed == 0 or not DoesEntityExist(playerPed) or not Config.PurchaseStock then return {} end
	if type(shopId) ~= 'string' or shopId == '' or #shopId > 64 then return {} end

	local shop = pawnShops[shopId]
	if not shop or not isPlayerNearShop(src, shop) then return {} end

	local stock = {}
	for itemName, count in pairs(shop.stock) do
		local sellPrice = shop.itemlist[itemName]
		if type(sellPrice) == 'number' and sellPrice >= 1 and count > 0 then
			stock[itemName] = { count = count, price = getBuybackPrice(sellPrice) }
		end
	end
	return stock
end)

RegisterNetEvent('MrNewbPawn:Server:SellPawn', function(shopId, itemName, count)
	local src = source
	local playerPed = GetPlayerPed(src)
	if playerPed == 0 or not DoesEntityExist(playerPed) then return end
	if type(shopId) ~= 'string' or shopId == '' or #shopId > 64 then return end
	if type(itemName) ~= 'string' or itemName == '' or #itemName > 64 then return end

	count = tonumber(count)
	if not count or count ~= count or count % 1 ~= 0 or count < 1 or count > maxTradeCount then return end

	local gameTime = GetGameTimer()
	if lastTradeAt[src] and gameTime - lastTradeAt[src] < 1000 then return end

	local shop = pawnShops[shopId]
	if not shop then
		bridge.notifications.notify(src, { description = locale('Warnings.InvalidShop'), type = 'error', duration = 6000 })
		return
	end

	if not shop.itemlist[itemName] then
		bridge.notifications.notify(src, { description = locale('Warnings.InvalidItem'), type = 'error', duration = 6000 })
		return
	end

	if not isPlayerNearShop(src, shop) then
		bridge.notifications.notify(src, { description = locale('Warnings.TooFarFromShop'), type = 'error', duration = 6000 })
		return
	end

	lastTradeAt[src] = gameTime
	sellPawnItem(src, shop, itemName, count)
end)

RegisterNetEvent('MrNewbPawn:Server:PurchasePawnedItem', function(shopId, itemName, count)
	local src = source
	local playerPed = GetPlayerPed(src)
	if playerPed == 0 or not DoesEntityExist(playerPed) or not Config.PurchaseStock then return end
	if type(shopId) ~= 'string' or shopId == '' or #shopId > 64 then return end
	if type(itemName) ~= 'string' or itemName == '' or #itemName > 64 then return end

	count = tonumber(count)
	if not count or count ~= count or count % 1 ~= 0 or count < 1 or count > maxTradeCount then return end

	local gameTime = GetGameTimer()
	if lastTradeAt[src] and gameTime - lastTradeAt[src] < 1000 then return end

	local shop = pawnShops[shopId]
	if not shop then
		bridge.notifications.notify(src, { description = locale('Warnings.InvalidShop'), type = 'error', duration = 6000 })
		return
	end

	if not isPlayerNearShop(src, shop) then
		bridge.notifications.notify(src, { description = locale('Warnings.TooFarFromShop'), type = 'error', duration = 6000 })
		return
	end

	lastTradeAt[src] = gameTime
	buyPawnedItem(src, shop, itemName, count)
end)

AddEventHandler('playerDropped', function()
	lastTradeAt[source] = nil
end)

AddEventHandler('onResourceStart', function(resourceName)
	if GetCurrentResourceName() ~= resourceName then return end

	exports[bridge.name]:VersionCheck('MrNewb/patchnotes', resourceName)

	for shopId, shop in pairs(Config.PawnShops or {}) do
		pawnShops[shopId] = {
			coords = shop.position,
			itemlist = shop.itemlist or {},
			stock = {},
		}
	end
end)

AddEventHandler('onResourceStop', function(resourceName)
	if GetCurrentResourceName() ~= resourceName then return end
	pawnShops = {}
end)
