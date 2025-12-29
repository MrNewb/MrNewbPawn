local function sliderSelect(item, id)
    if not item then return end
    local sliderData = SliderInput("smelter", item, "melt", locale("Smelting.AmountToSmelt"))
    if not sliderData then return end

    local itemLabel = Bridge.Inventory.GetItemInfo(item).label
    local success = Bridge.ProgressBar.Open({
        duration = sliderData * 1000,
        label = itemLabel,
        disable = { move = true, combat = true },
        anim = { dict = "amb@prop_human_bum_bin@idle_b", clip = "idle_d", flag = 49,},
        canCancel = true,
    })
    if not success then return Bridge.Notify.SendNotify(locale("Warnings.Canceled"), "error", 3000) end

    TriggerServerEvent('MrNewbPawn:Server:SmeltItem', item, sliderData, id)
end

function GenerateMeltMenu(id)
    local populatedOptions = {{
        title = locale("Smelting.MenuTitle"),
        description = locale("Smelting.MenuDescription"),
        icon = locale("Smelting.MenuIcon"),
        iconColor = locale("Smelting.MenuIconColor"),
    }}

    for k, v in pairs(Config.MeltableItems) do
        local itemInfo = Bridge.Inventory.GetItemInfo(k)
        local rewardDescriptions = {}

        for _, reward in ipairs(v) do
            local rewardInfo = Bridge.Inventory.GetItemInfo(reward.itemName)
            table.insert(rewardDescriptions, string.format("%d x %s", reward.count, rewardInfo.label))
        end

        table.insert(populatedOptions, {
            title = itemInfo.label,
            description = table.concat(rewardDescriptions, ", "),
            icon = itemInfo.image,
            iconColor = locale("Smelting.MenuIconColor"),
            onSelect = function()
                sliderSelect(k, id)
			end,
        })
    end

    Wait(500)
    local menuID = GenerateRandomString()
    Bridge.Menu.Open({ id = menuID, title = locale("Smelting.MenuTitle"), options = populatedOptions }, false)
end