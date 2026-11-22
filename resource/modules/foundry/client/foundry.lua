local foundries = {}
local maxMeltDuration = 30000
local defaultMeltProp = 'prop_cs_cardbox_01'

local activeMeltProp
local activeTravelId = 0

local function getWaypointPathLength(waypoints)
	local pathLength = 0.0
	for waypointIndex = 1, #waypoints - 1 do
		pathLength = pathLength + #(waypoints[waypointIndex + 1] - waypoints[waypointIndex])
	end
	return pathLength
end

local function getMeltDuration(foundry, progressDuration)
	local lerpProp = foundry.lerpProp
	local waypoints = lerpProp and lerpProp.waypoints
	if not waypoints or #waypoints < 2 or progressDuration <= 0 then
		return progressDuration
	end

	local lerpSpeed = lerpProp.lerpSpeed
	if lerpSpeed <= 0 then return progressDuration end

	local travelDurationMs = (getWaypointPathLength(waypoints) / lerpSpeed) * 1000
	return math.max(progressDuration, travelDurationMs)
end

local function deleteMeltProp(entity)
	if entity and DoesEntityExist(entity) then
		DeleteEntity(entity)
	end
end

local function startMeltPropTravel(foundry, durationMs, itemName)
	local waypoints = foundry.lerpProp and foundry.lerpProp.waypoints
	if not waypoints or #waypoints < 2 or durationMs <= 0 then return end

	local propModel = Config.MeltableItems[itemName].prop or defaultMeltProp

	activeTravelId = activeTravelId + 1
	local thisTravelId = activeTravelId

	CreateThread(function()
		local modelHash = lib.requestModel(propModel)

		local startCoords = waypoints[1]
		local meltProp = CreateObject(modelHash, startCoords.x, startCoords.y, startCoords.z, false, false, false)
		SetModelAsNoLongerNeeded(modelHash)
		if meltProp == 0 or not DoesEntityExist(meltProp) then return end

		activeMeltProp = meltProp
		SetEntityAsMissionEntity(meltProp, true, true)
		FreezeEntityPosition(meltProp, true)
		SetEntityCollision(meltProp, false, false)
		SetEntityCoords(meltProp, startCoords.x, startCoords.y, startCoords.z, false, false, false, false)

		local pathLength = getWaypointPathLength(waypoints)
		for waypointIndex = 1, #waypoints - 1 do
			local fromCoords = waypoints[waypointIndex]
			local toCoords = waypoints[waypointIndex + 1]
			local segmentDurationMs = pathLength > 0 and (durationMs * (#(toCoords - fromCoords) / pathLength)) or 0
			local segmentStartedAt = GetGameTimer()

			while GetGameTimer() - segmentStartedAt < segmentDurationMs do
				if thisTravelId ~= activeTravelId then
					if DoesEntityExist(meltProp) and meltProp ~= activeMeltProp then
						deleteMeltProp(meltProp)
					end
					return
				end
				local segmentProgress = (GetGameTimer() - segmentStartedAt) / segmentDurationMs
				SetEntityCoords(meltProp, fromCoords.x + (toCoords.x - fromCoords.x) * segmentProgress, fromCoords.y + (toCoords.y - fromCoords.y) * segmentProgress, fromCoords.z + (toCoords.z - fromCoords.z) * segmentProgress, false, false, false, false)
				Wait(0)
			end

			SetEntityCoords(meltProp, toCoords.x, toCoords.y, toCoords.z, false, false, false, false)
		end

		if thisTravelId == activeTravelId then
			deleteMeltProp(meltProp)
			activeMeltProp = nil
		end
	end)

	return function(cancelled)
		if not cancelled then return end
		activeTravelId = activeTravelId + 1
		deleteMeltProp(activeMeltProp)
		activeMeltProp = nil
	end
end

local function startMelting(foundryId, itemName)
	local foundry = Config.FoundryLocations[foundryId]

	local ownedCount = bridge.inventory.getItemCount(itemName)
	if ownedCount < 1 then
		bridge.notifications.notify({ description = locale('Warnings.DoNotHave'), type = 'error', duration = 6000 })
		return
	end

	local itemLabel = GetItemLabelAndIcon(itemName)
	local amount = AskItemAmount(itemLabel, locale('Smelting.AmountToSmelt'), math.min(ownedCount, MAX_MELT_COUNT))
	if not amount then return end

	local durationMs = math.min(amount * 1000, maxMeltDuration)
	durationMs = getMeltDuration(foundry, durationMs)

	local cancelMeltTravel = startMeltPropTravel(foundry, durationMs, itemName)
	local success = bridge.progressbar.openprogressbar({
		duration = durationMs,
		label = locale('Smelting.ProgressBarLabel', amount, itemLabel),
		disable = { move = true, combat = true },
		anim = { dict = 'amb@prop_human_bum_bin@idle_b', clip = 'idle_d', flag = 49 },
		canCancel = true,
	})

	if cancelMeltTravel then
		cancelMeltTravel(not success)
	end

	if not success then
		bridge.notifications.notify({ description = locale('Warnings.Canceled'), type = 'error', duration = 3000 })
		return
	end

	TriggerServerEvent('MrNewbPawn:server:smeltedItem', itemName, amount, foundryId)
end

local function openFoundryMenu(foundryId)
	local menuOptions = {
		{
			title = locale('Smelting.MenuTitle'),
			description = locale('Smelting.MenuDescription'),
			icon = locale('Smelting.MenuIcon'),
			iconColor = locale('Smelting.MenuIconColor'),
		},
	}

	for itemName in pairs(Config.MeltableItems) do
		local rewards = GetMeltRewards(itemName)
		if rewards then
			local itemLabel, itemIcon = GetItemLabelAndIcon(itemName)
			local rewardText = {}
			for rewardIndex = 1, #rewards do
				local reward = rewards[rewardIndex]
				local rewardLabel = GetItemLabelAndIcon(reward.itemName)
				rewardText[#rewardText + 1] = ('%d x %s'):format(reward.count, rewardLabel)
			end

			menuOptions[#menuOptions + 1] = {
				title = itemLabel,
				description = table.concat(rewardText, ', '),
				icon = itemIcon,
				iconColor = locale('Smelting.MenuIconColor'),
				onSelect = function()
					startMelting(foundryId, itemName)
				end,
			}
		end
	end

	bridge.menu.openMenu({
		id = 'MrNewbPawn:foundry',
		title = locale('Smelting.MenuTitle'),
		options = menuOptions,
	})
end

function CreateFoundries()
	for foundryId, foundry in pairs(Config.FoundryLocations) do
		if not foundries[foundryId] then
			local zone = foundry.Zone
			local blip
			if foundry.Blip then
				blip = AddBlipForCoord(zone.coords.x, zone.coords.y, zone.coords.z)
				SetBlipSprite(blip, foundry.Blip.sprite)
				SetBlipColour(blip, foundry.Blip.color)
				SetBlipScale(blip, foundry.Blip.scale)
				SetBlipAsShortRange(blip, true)
				SetBlipDisplay(blip, 4)
				BeginTextCommandSetBlipName('STRING')
				AddTextComponentSubstringPlayerName(foundry.Blip.label)
				EndTextCommandSetBlipName(blip)
			end

			local zoneId = bridge.target.addBoxZone({
				name = ('MrNewbPawn:foundry:%s'):format(foundryId),
				coords = zone.coords,
				size = zone.size,
				rotation = zone.rotation,
				debug = Config.Debug,
				options = {
					{
						name = ('MrNewbPawn:foundry:%s'):format(foundryId),
						label = locale('Smelting.TargetLabel'),
						icon = locale('Smelting.TargetIcon'),
						distance = 5.0,
						onSelect = function()
							openFoundryMenu(foundryId)
						end,
					},
				},
			})

			foundries[foundryId] = { blip = blip, zoneId = zoneId }
		end
	end
end

function RemoveFoundries()
	activeTravelId = activeTravelId + 1
	deleteMeltProp(activeMeltProp)
	activeMeltProp = nil

	for foundryId, foundry in pairs(foundries) do
		if foundry.zoneId then
			bridge.target.removeZone(foundry.zoneId)
		end
		if foundry.blip and DoesBlipExist(foundry.blip) then
			RemoveBlip(foundry.blip)
		end
		foundries[foundryId] = nil
	end
end

AddEventHandler('Newb_Bridge:client:playerLoaded', function()
	CreateFoundries()
end)

AddEventHandler('Newb_Bridge:client:playerUnloaded', function()
	RemoveFoundries()
end)

AddEventHandler('onResourceStop', function(resourceName)
	if cache.resource ~= resourceName then return end
	RemoveFoundries()
end)
