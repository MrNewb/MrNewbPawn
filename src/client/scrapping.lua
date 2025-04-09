local function sliderSelect(item)
    if not item then return end
    local itemSearch = Config.MeltableItems[item]
    if not itemSearch then return NotifyPlayer(locale("Warnings.DoNotHave"), "error", 6000) end
    local itemLabel = Bridge.Inventory.GetItemInfo(item).label
    local itemCount = Bridge.Inventory.GetItemCount(item)
    if itemCount <= 0 then return NotifyPlayer(locale("Warnings.DoNotHave"), "error", 6000) end
    local maxAmount = itemCount
    local input = lib.inputDialog(itemLabel,{
        { type = 'slider', label = locale("Smelting.AmountToSmelt"), min = 1, max = maxAmount, step = 1 },
	})

	if not input or not input[1] then return end
    TriggerServerEvent('MrNewbPawn_V2:Server:Scrapping', item, input[1])
end

function GenerateMeltMenu()
    local populatedOptions = {{
        title = locale("Smelting.MenuTitle"),
        description = locale("Smelting.MenuDescription"),
        icon = locale("Smelting.MenuIcon"),
        iconColor = locale("Smelting.MenuIconColor"),
    }}
    local menuID = GenerateRandomString()

    for k, v in pairs(Config.MeltableItems) do
        local keyInfo = Bridge.Inventory.GetItemInfo(k)
        local rewardDescriptions = {}

        for _, reward in ipairs(v) do
            local rewardInfo = Bridge.Inventory.GetItemInfo(reward.itemName)
            table.insert(rewardDescriptions, string.format("%d x %s", reward.count, rewardInfo.label))
        end

        table.insert(populatedOptions, {
            title = keyInfo.label,
            description = table.concat(rewardDescriptions, ", "),
            icon = keyInfo.image,
            iconColor = locale("Smelting.MenuIconColor"),
            onSelect = function()
                sliderSelect(k)
			end,
        })
    end

    Wait(500)
    Bridge.Menu.Open({ id = menuID, title = locale("Smelting.MenuTitle"), options = populatedOptions }, false)
end

function RegisterGoldMeltPoints()
    for _, v in pairs(Config.FoundryLocations) do
        if v.blip then
            Bridge.Utility.CreateBlip(v.position, v.blip.sprite, v.blip.color, v.blip.scale, v.name, true, 4)
        end
        Bridge.Target.AddBoxZone(v.name, v.position, vector3(2.0, 2.0, 2.0), 0.0, {
            {
                name = 'Melting '..v.name,
                label = locale("Smelting.TargetLabel"),
                icon = locale("Smelting.TargetIcon"),
                distance = 5,
                onSelect = function()
                    GenerateMeltMenu()
                end
            },
        })
        table.insert(CreatedZones, v.name)
    end
end