local pawnShops = {}
local lastTradeAt = {}

for shopId, shop in pairs(Config.PawnShops) do
	pawnShops[shopId] = { coords = shop.position, itemlist = shop.itemlist, stock = {} }
end

local function getBuybackPrice(sellPrice)
	if Config.PurchaseMarkup <= 0 then return sellPrice end
	return math.ceil(sellPrice * (100 + Config.PurchaseMarkup) / 100)
end

local function isPlayerNearShop(src, shop)
	local ped = GetPlayerPed(src)
	if ped == 0 then return false end
	return #(GetEntityCoords(ped) - vector3(shop.coords.x, shop.coords.y, shop.coords.z)) <= 6.0
end

local function sellPawnItem(src, shop, itemName, count)
	local failKey
	local payout = shop.itemlist[itemName] * count

	if not bridge.inventory.removeItem(src, itemName, count) then
		failKey = 'Warnings.DoNotHave'
	elseif not bridge.framework.addMoney(src, 'cash', payout) then
		bridge.inventory.addItem(src, itemName, count)
		failKey = 'Warnings.SellFailed'
	end

	if failKey then
		return bridge.notifications.notify(src, { description = locale(failKey), type = 'error', duration = 6000 })
	end

	if Config.PurchaseStock then
		shop.stock[itemName] = (shop.stock[itemName] or 0) + count
	end

	LogPawnAction(src, 'LogMessages.SoldItem', count, itemName, payout)
	bridge.notifications.notify(src, { description = locale('PawnShop.SoldItem', count, itemName, payout), type = 'success', duration = 6000 })
end

local function buyPawnedItem(src, shop, itemName, count)
	local stockCount = shop.stock[itemName] or 0
	if stockCount < count then
		return bridge.notifications.notify(src, { description = locale('PawnShop.NoStock'), type = 'error', duration = 6000 })
	end

	-- take the stock before anything yields so two buyers cannot spend the same units
	shop.stock[itemName] = stockCount - count

	local failKey
	local totalCost = getBuybackPrice(shop.itemlist[itemName]) * count

	if bridge.framework.getMoney(src, 'cash') < totalCost then
		failKey = 'Warnings.NotEnoughMoney'
	elseif not bridge.inventory.canCarryItem(src, itemName, count) then
		failKey = 'Warnings.NotEnoughSpace'
	elseif not bridge.framework.removeMoney(src, 'cash', totalCost) then
		failKey = 'Warnings.NotEnoughMoney'
	elseif not bridge.inventory.addItem(src, itemName, count) then
		bridge.framework.addMoney(src, 'cash', totalCost)
		failKey = 'Warnings.NotEnoughSpace'
	end

	if failKey then
		shop.stock[itemName] = (shop.stock[itemName] or 0) + count
		return bridge.notifications.notify(src, { description = locale(failKey), type = 'error', duration = 6000 })
	end

	if shop.stock[itemName] <= 0 then
		shop.stock[itemName] = nil
	end

	LogPawnAction(src, 'LogMessages.PurchasedItem', count, itemName, totalCost)
	bridge.notifications.notify(src, { description = locale('PawnShop.PurchasedPawnedItem', count, itemName, totalCost), type = 'success', duration = 6000 })
end

local function requestedStock(src, shopId)
	if not Config.PurchaseStock or not IsValidId(shopId) then return {} end

	local shop = pawnShops[shopId]
	if not shop or not isPlayerNearShop(src, shop) then return {} end

	local stock = {}
	for itemName, count in pairs(shop.stock) do
		stock[itemName] = { count = count, price = getBuybackPrice(shop.itemlist[itemName]) }
	end
	return stock
end

local function soldPawnItem(shopId, itemName, count)
	local src = source
	if src == '' or not IsValidId(shopId) or not IsValidId(itemName) then return end

	count = ParseWholeNumber(count, MAX_TRADE_COUNT)
	if not count or IsOnCooldown(lastTradeAt, src) then return end

	local shop = pawnShops[shopId]
	local failKey
	if not shop then
		failKey = 'Warnings.InvalidShop'
	elseif not shop.itemlist[itemName] then
		failKey = 'Warnings.InvalidItem'
	elseif not isPlayerNearShop(src, shop) then
		failKey = 'Warnings.TooFarFromShop'
	end

	if failKey then
		return bridge.notifications.notify(src, { description = locale(failKey), type = 'error', duration = 6000 })
	end

	sellPawnItem(src, shop, itemName, count)
end

local function purchasedPawnedItem(shopId, itemName, count)
	local src = source
	if src == '' or not Config.PurchaseStock or not IsValidId(shopId) or not IsValidId(itemName) then return end

	count = ParseWholeNumber(count, MAX_TRADE_COUNT)
	if not count or IsOnCooldown(lastTradeAt, src) then return end

	local shop = pawnShops[shopId]
	local failKey
	if not shop then
		failKey = 'Warnings.InvalidShop'
	elseif not isPlayerNearShop(src, shop) then
		failKey = 'Warnings.TooFarFromShop'
	end

	if failKey then
		return bridge.notifications.notify(src, { description = locale(failKey), type = 'error', duration = 6000 })
	end

	buyPawnedItem(src, shop, itemName, count)
end

lib.callback.register('MrNewbPawn:server:requestedStock', requestedStock)
RegisterNetEvent('MrNewbPawn:server:soldPawnItem', soldPawnItem)
RegisterNetEvent('MrNewbPawn:server:purchasedPawnedItem', purchasedPawnedItem)

AddEventHandler('playerDropped', function()
	lastTradeAt[source] = nil
end)

AddEventHandler('onResourceStart', function(resourceName)
	if cache.resource ~= resourceName then return end
	Wait(100)
	exports[bridge.name]:VersionCheck('MrNewb/patchnotes', resourceName)
end)
