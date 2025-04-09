local function sliderSelect(item)
    if not item then return end
    local itemSearch = Config.PawnItems[item]
    if not itemSearch then return NotifyPlayer(locale("Warnings.DoNotHave"), "error", 6000) end
    local itemLabel = Bridge.Inventory.GetItemInfo(item).label
    local itemCount = Bridge.Inventory.GetItemCount(item)
    if itemCount <= 0 then return NotifyPlayer(locale("Warnings.DoNotHave"), "error", 6000) end
    local maxAmount = itemCount
    local input = lib.inputDialog(itemLabel,{
        { type = 'slider', label = locale("PawnShop.AmountToSell"), min = 1, max = maxAmount, step = 1 },
	})

	if not input or not input[1] then return end
    TriggerServerEvent("MrNewbPawn_V2:Server:SellPawn", item, input[1])
end

function GeneratePawnMenus(shop)
    local menuOptions = {
        {
            title = shop,
            description = locale("PawnShop.Description"),
            icon = locale("PawnShop.MenuIcon"),
            iconColor = locale("PawnShop.color"),
        },
    }
    local menuID = GenerateRandomString()

    for k, v in pairs(Config.PawnItems) do
        local itemLabel = Bridge.Inventory.GetItemInfo(k).label
        table.insert(menuOptions, {
            title = itemLabel,
            description = string.format(locale("PawnShop.SellItems") .. " $%d", v),
            icon = Bridge.Inventory.GetItemInfo(k).image,
            iconColor = locale("PawnShop.color"),
            onSelect = function()
                sliderSelect(k)
            end,
        })
    end
    Wait(500)
    Bridge.Menu.Open({ id = menuID, title = locale("PawnShop.Title"), options = menuOptions }, false)
end