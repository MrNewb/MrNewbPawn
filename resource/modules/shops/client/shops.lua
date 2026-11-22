local pawnShops = {}
local sellDurationMs = 3000

local function isShopOpen(shop)
	local storeHours = shop.storeHours
	if not storeHours then return true end

	local clockHour = GetClockHours()
	local openHour, closeHour = storeHours.open, storeHours.close
	if openHour == closeHour then return true end
	if openHour < closeHour then
		return clockHour >= openHour and clockHour <= closeHour
	end
	return clockHour >= openHour or clockHour <= closeHour
end

local function playClerkHandoff(shopId)
	local shop = pawnShops[shopId]
	local clerkPed = shop and shop.entity
	if not clerkPed or not DoesEntityExist(clerkPed) then return end

	CreateThread(function()
		if DoesEntityExist(cache.ped) then
			TaskTurnPedToFaceEntity(clerkPed, cache.ped, 400)
		end

		ClearPedTasks(clerkPed)
		lib.requestAnimDict('mp_common')
		if DoesEntityExist(clerkPed) then
			TaskPlayAnim(clerkPed, 'mp_common', 'givetake1_b', 3.0, 3.0, sellDurationMs, 49, 0.0, false, false, false)
			Wait(sellDurationMs)
			if DoesEntityExist(clerkPed) then
				StopAnimTask(clerkPed, 'mp_common', 'givetake1_b', 1.0)
				ClearPedTasks(clerkPed)
				TaskStartScenarioInPlace(clerkPed, 'WORLD_HUMAN_SMOKING', 0, true)
			end
		end
		RemoveAnimDict('mp_common')
	end)
end

local function startSellProgress(shopId, itemName, count, itemLabel)
	playClerkHandoff(shopId)
	local success = bridge.progressbar.openprogressbar({
		duration = sellDurationMs,
		label = locale('PawnShop.SellingProgress', count, itemLabel),
		disable = { move = true, combat = true },
		anim = { dict = 'mp_common', clip = 'givetake1_a', flag = 49 },
		canCancel = true,
	})
	if not success then return bridge.notifications.notify({ description = locale('Warnings.Canceled'), type = 'error', duration = 3000 }) end
	TriggerServerEvent('MrNewbPawn:server:soldPawnItem', shopId, itemName, count)
end

local function itemSellAmount(shopId, itemName, itemLabel)
	local ownedCount = bridge.inventory.getItemCount(itemName)
	if ownedCount < 1 then return bridge.notifications.notify({ description = locale('Warnings.DoNotHave'), type = 'error', duration = 6000 }) end
	local count = AskItemAmount(itemLabel, locale('PawnShop.AmountToSell'), math.min(ownedCount, MAX_TRADE_COUNT))
	if not count then return end
	startSellProgress(shopId, itemName, count, itemLabel)
end

local function openSellMenu(shopId)
	local menuOptions = {}
	for itemName, sellPrice in pairs(Config.PawnShops[shopId].itemlist) do
		local itemLabel, itemIcon = GetItemLabelAndIcon(itemName)
		menuOptions[#menuOptions + 1] = {
			title = itemLabel,
			description = locale('PawnShop.SellItems', sellPrice),
			icon = itemIcon,
			iconColor = locale('PawnShop.color'),
			onSelect = function()
				itemSellAmount(shopId, itemName, itemLabel)
			end,
		}
	end

	bridge.menu.openMenu({
		id = 'MrNewbPawn:shop:sell',
		title = locale('PawnShop.Title'),
		options = menuOptions,
	})
end

local function openBuyMenu(shopId)
	local stockItems = lib.callback.await('MrNewbPawn:server:requestedStock', false, shopId)
	if not next(stockItems) then
		bridge.notifications.notify({ description = locale('PawnShop.NoPawnedItems'), type = 'error', duration = 3000 })
		return
	end

	local menuOptions = {}
	for itemName, stock in pairs(stockItems) do
		local itemLabel, itemIcon = GetItemLabelAndIcon(itemName)
		menuOptions[#menuOptions + 1] = {
			title = itemLabel,
			description = locale('PawnShop.PawnedItemDescription', stock.count, stock.price),
			icon = itemIcon,
			iconColor = locale('PawnShop.color'),
			onSelect = function()
				local amount = AskItemAmount(locale('PawnShop.AmountToPurchase'), locale('PawnShop.AmountToPurchase'), math.min(stock.count, MAX_TRADE_COUNT))
				if not amount then return end
				TriggerServerEvent('MrNewbPawn:server:purchasedPawnedItem', shopId, itemName, amount)
			end,
		}
	end

	bridge.menu.openMenu({
		id = 'MrNewbPawn:shop:buy',
		title = locale('PawnShop.Title'),
		options = menuOptions,
	})
end

local function openShopMenu(shopId)
	local shop = Config.PawnShops[shopId]
	if not isShopOpen(shop) then return bridge.notifications.notify({ description = locale('PawnShop.ShopClosed'), type = 'error', duration = 3000 }) end

	local menuOptions = {
		{
			title = shopId,
			description = locale('PawnShop.Description'),
			icon = locale('PawnShop.MenuIcon'),
			iconColor = locale('PawnShop.color'),
		},
		{
			title = locale('PawnShop.SellTitle'),
			description = locale('PawnShop.SellDescription'),
			icon = locale('PawnShop.MenuIcon'),
			iconColor = locale('PawnShop.color'),
			onSelect = function()
				openSellMenu(shopId)
			end,
		},
	}

	if Config.PurchaseStock then
		menuOptions[#menuOptions + 1] = {
			title = locale('PawnShop.PawnedTitle'),
			description = locale('PawnShop.PawnedDescription'),
			icon = locale('PawnShop.MenuIcon'),
			iconColor = locale('PawnShop.color'),
			onSelect = function()
				openBuyMenu(shopId)
			end,
		}
	end

	bridge.menu.openMenu({
		id = 'MrNewbPawn:shop',
		title = locale('PawnShop.Title'),
		options = menuOptions,
	})
end

function CreatePawnShops()
	for shopId, shop in pairs(Config.PawnShops) do
		if not pawnShops[shopId] then
			local blip
			if shop.Blip then
				blip = AddBlipForCoord(shop.position.x, shop.position.y, shop.position.z)
				SetBlipSprite(blip, shop.Blip.sprite)
				SetBlipColour(blip, shop.Blip.color)
				SetBlipScale(blip, shop.Blip.scale)
				SetBlipAsShortRange(blip, true)
				SetBlipDisplay(blip, 4)
				BeginTextCommandSetBlipName('STRING')
				AddTextComponentSubstringPlayerName(shop.Blip.label)
				EndTextCommandSetBlipName(blip)
			end

			pawnShops[shopId] = { blip = blip, entity = nil }

			exports[bridge.name]:AddInteraction(('MrNewbPawn:shop:%s'):format(shopId), {
				model = shop.model,
				coords = vector3(shop.position.x, shop.position.y, shop.position.z),
				heading = shop.position.w,
				radius = shop.radius,
				scenario = 'WORLD_HUMAN_SMOKING',
				options = {
					{
						name = ('MrNewbPawn:shop:%s'):format(shopId),
						label = locale('PawnShop.TargetLabel'),
						icon = locale('PawnShop.TargetIcon'),
						distance = 5.0,
						onSelect = function()
							openShopMenu(shopId)
						end,
					},
				},
				onSpawn = function(interaction)
					if pawnShops[shopId] then
						pawnShops[shopId].entity = interaction.entity
					end
				end,
				onDespawn = function()
					if pawnShops[shopId] then
						pawnShops[shopId].entity = nil
					end
				end,
			})
		end
	end
end

function RemovePawnShops()
	for shopId, shop in pairs(pawnShops) do
		exports[bridge.name]:RemoveInteraction(('MrNewbPawn:shop:%s'):format(shopId))
		if shop.blip and DoesBlipExist(shop.blip) then
			RemoveBlip(shop.blip)
		end
		pawnShops[shopId] = nil
	end
end

AddEventHandler('Newb_Bridge:client:playerLoaded', function()
	CreatePawnShops()
end)

AddEventHandler('Newb_Bridge:client:playerUnloaded', function()
	RemovePawnShops()
end)

AddEventHandler('onResourceStop', function(resourceName)
	if cache.resource ~= resourceName then return end
	RemovePawnShops()
end)
