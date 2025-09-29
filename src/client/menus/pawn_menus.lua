local function stupidHaggleAnimationShit(id, item, count, label)
    local success = Bridge.ProgressBar.Open({
        duration = 3000,
        label = locale("PawnShop.SellingProgress", count, label),
        disable = { move = true, combat = true },
        --anim = { dict = "amb@prop_human_bum_bin@idle_b", clip = "idle_d", flag = 49,},
        canCancel = true,
    })
    if not success then return Bridge.Notify.SendNotify(locale("Warnings.Canceled"), "error", 3000) end
    TriggerServerEvent("MrNewbPawn_V2:Server:SellPawn", id, item, count)
end

local function itemSellAmount(id, item)
    if not item or not id then return end
    local count = SliderInput(id, item, "pawn", locale("PawnShop.AmountToSell"))
    if not count then return end
    if count <= 0 then return end
    local label = Bridge.Inventory.GetItemInfo(item).label
    if not label then return end
    stupidHaggleAnimationShit(id, item, count, label)
end

local function inputPurchaseAmount(id, itemCount, itemLabel)
    if not itemCount or itemCount <= 0 then return end
    local input = Bridge.Input.Open(itemLabel, {
        { type = 'slider', label = locale("PawnShop.AmountToPurchase"), min = 1, max = itemCount, step = 1 },
	}, false)

	if not input or not input[1] then return end
    if tonumber(input[1]) <= 0 then return end
    TriggerServerEvent("MrNewbPawn_V2:Server:PurchasePawnedItem", id, itemLabel, input[1])
end

local function openPurchaseMenu(id)
    local menuOptions = {}
    local items = Bridge.Callback.Trigger('MrNewbPawn_V2:Callback:GetPawnedStock', id)
    if next(items) == nil then return Bridge.Notify.SendNotify(locale("PawnShop.NoPawnedItems"), "error", 3000) end
    for k, v in pairs(items) do
        local itemInfo = Bridge.Inventory.GetItemInfo(k)
        table.insert(menuOptions, {
            title = itemInfo.label,
            description = locale("PawnShop.PawnedItemDescription", v.count, v.price),
            icon = itemInfo.image,
            iconColor = locale("PawnShop.color"),
            onSelect = function()
                inputPurchaseAmount(id, v.count, k)
            end,
        })
    end
    local menuID = GenerateRandomString()
    Wait(500)
    Bridge.Menu.Open({ id = menuID, title = locale("PawnShop.Title"), options = menuOptions }, false)
end

local function openSellingMenu(id)
    local menuOptions = {}
    for k, v in pairs(Config.PawnShops[id].itemlist) do
        local itemInfo = Bridge.Inventory.GetItemInfo(k)
        table.insert(menuOptions, {
            title = itemInfo.label,
            description = locale("PawnShop.SellItems", v),
            icon = itemInfo.image,
            iconColor = locale("PawnShop.color"),
            onSelect = function()
                itemSellAmount(id, k)
            end,
        })
    end
    local menuID = GenerateRandomString()
    Wait(500)
    Bridge.Menu.Open({ id = menuID, title = locale("PawnShop.Title"), options = menuOptions }, false)
end

function GeneratePawnMenus(id)
    local menuOptions = {
        {
            title = id,
            description = locale("PawnShop.Description"),
            icon = locale("PawnShop.MenuIcon"),
            iconColor = locale("PawnShop.color"),
        },
        {
            title = locale("PawnShop.SellTitle"),
            description = locale("PawnShop.SellDescription"),
            icon = locale("PawnShop.MenuIcon"),
            iconColor = locale("PawnShop.color"),
            onSelect = function()
                openSellingMenu(id)
            end,
        },
    }
    if Config.Settings.PurchasePawnedItems then
        table.insert(menuOptions, {
            title = locale("PawnShop.PawnedTitle"),
            description = locale("PawnShop.PawnedDescription"),
            icon = locale("PawnShop.MenuIcon"),
            iconColor = locale("PawnShop.color"),
            onSelect = function()
                openPurchaseMenu(id)
            end,
        })
    end
    local menuID = GenerateRandomString()
    Wait(500)
    Bridge.Menu.Open({ id = menuID, title = locale("PawnShop.Title"), options = menuOptions }, false)
end