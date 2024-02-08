ESX                             = nil
local PlayerData                = {}
local LastZone                  = nil
local CurrentAction             = nil
local CurrentActionMsg          = ''
local CurrentActionData         = {}
local isDead                    = false
local CurrentTask               = {}
local menuOpen 				    = false
local wasOpen 				    = 0
local alreadychecked 			= false


Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end

    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end

    PlayerData = ESX.GetPlayerData()
end)

AddEventHandler('esx:onPlayerDeath', function(data)
    isDead = true
end)

AddEventHandler('playerSpawned', function(spawn)
    isDead = false
end)

Citizen.CreateThread( function()
    while true do  
        Citizen.Wait(2500)

        istime = false
        currenthour = GetClockHours()

        if currenthour >= 8 and currenthour <= 19 and not alreadychecked then
           storeopen = true
            alreadychecked = true
        end

        if currenthour >= 20 or currenthour <= 7  and alreadychecked then
            storeopen = false
            alreadychecked = false
        end

    end
end)

function DrawText3Ds(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
end

Citizen.CreateThread(function()
    while true do
        sleep = 1000
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)

		for index,value in pairs(Config.Zones) do
            if GetDistanceBetweenCoords(coords, value.coords, true) < 3.0 then
                sleep = 0
				if storeopen then 
					
					DrawText3Ds(value.coords.x,value.coords.y,value.coords.z, value.opentext)

					if IsControlJustReleased(0, 38) then
						wasOpen = index
						OpenShop(index)
					end
				else
					DrawText3Ds(value.coords.x,value.coords.y,value.coords.z, value.closedtext)
				end
			else
				if wasOpen == index then
					wasOpen = 0
					ESX.UI.Menu.CloseAll()
				end

			end
        end
        Citizen.Wait(sleep)
    end
end)

function OpenShop(storenumber)
    local elements = {}
    menuOpen = true
    local currentinventory = ESX.GetPlayerData().inventory
    for i, v in pairs(Config.Items) do
        if v.storenumber == storenumber then
            for count, items in pairs(currentinventory) do
                 if items.name == v.name and items.count > 0 and v.storenumber == storenumber then
                    table.insert(elements, {
                        label = ('%s - <span style="color:green;">%s</span>'):format(items.label, _U('item', ESX.Math.GroupDigits(v.price))),
                        name = items.name,
                        price = v.price,
        
                        -- menu properties
                        type = 'slider',
                        value = 1,
                        min = 1,
                        max = items.count
                    })
                    break
                end
            end
        end
    end

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'car_shop', {
        title    = _U('shop_title'),
        align    = 'right',
        elements = elements
    }, function(data, menu)
        TriggerServerEvent('MrNewbspawnshop:sell', data.current.name, data.current.value, storenumber)
        ESX.UI.Menu.CloseAll()
    end, function(data, menu)
        menu.close()
        menuOpen = false
    end)
end

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        if menuOpen then
            ESX.UI.Menu.CloseAll()
        end
    end
end)

function CreateBlipCircle(coords, text, radius, color, sprite)
    local blip = AddBlipForCoord(coords)
    SetBlipSprite(blip, sprite)
    SetBlipColour(blip, color)
    SetBlipScale(blip, 0.8)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(text)
    EndTextCommandSetBlipName(blip)
end

Citizen.CreateThread(function()
    if Config.EnableBlips == true then
        for k,zone in pairs(Config.Zones) do
            CreateBlipCircle(zone.coords, zone.name, zone.radius, zone.color, zone.sprite)
        end
    end
end)

Citizen.CreateThread(function()
    if Config.NPCEnable == true then
        for i, v in pairs(Config.NPC) do
            RequestModel(v.npc)
            while not HasModelLoaded(v.npc) do
                Wait(1)
            end
            --PROVIDER
            meth_dealer_seller = CreatePed(1, v.npc, v.x, v.y, v.z, v.h, false, true)
            SetBlockingOfNonTemporaryEvents(meth_dealer_seller, true)
            SetPedDiesWhenInjured(meth_dealer_seller, false)
            SetPedCanPlayAmbientAnims(meth_dealer_seller, true)
            SetPedCanRagdollFromPlayerImpact(meth_dealer_seller, false)
            SetEntityInvincible(meth_dealer_seller, true)
            FreezeEntityPosition(meth_dealer_seller, true)
            TaskStartScenarioInPlace(meth_dealer_seller, "WORLD_HUMAN_SMOKING", 0, true);
        end
    end
end)


AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        if menuOpen then
            ESX.UI.Menu.CloseAll()
        end
    end
end)
