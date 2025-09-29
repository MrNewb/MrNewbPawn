RegisterNetEvent("community_bridge:Client:OnPlayerLoaded", function()
end)

RegisterNetEvent("community_bridge:Client:OnPlayerUnload", function()
end)

function SliderInput(id, item, _type, inputLabel)
    if not item then return false end
    if not _type or (_type ~= "melt" and _type ~= "pawn") then return false end
    if not id then return false end
    local itemLabel = Bridge.Inventory.GetItemInfo(item).label
    local itemCount = Bridge.Inventory.GetItemCount(item)

    if itemCount <= 0 then return false, Bridge.Notify.SendNotify(locale("Warnings.DoNotHave"), "error", 6000) end

    if _type == "melt" then
        local itemSearch = Config.MeltableItems[item]
        if not itemSearch then return false, Bridge.Notify.SendNotify(locale("Warnings.DoNotHave"), "error", 6000) end
    end

    if _type == "pawn" then
        local shop = Config.PawnShops[id]
        if not shop or not shop.itemlist[item] then return false, Bridge.Notify.SendNotify(locale("Warnings.DoNotHave"), "error", 6000) end
    end

    local input = Bridge.Input.Open(itemLabel, {
        { type = 'slider', label = inputLabel, min = 1, max = itemCount, step = 1 },
    })

    if not input or not input[1] then return false end
    local amount = tonumber(input[1])
    if not amount or amount <= 0 then return false end
    return amount
end

if not Config.Utility.Debug then return end
AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    RegisterPawnPoints()
    RegisterSmeltPoints()
    DebugInfo("Resource started in debug mode: " .. resource)
    DebugInfo("Debug mode is enabled.")
    DebugInfo("Registering pawn points and smelting points.")
    DebugInfo("This is not for production use in this mode, it is here for prints and testing of tweaks.")
    DebugInfo("Please disable debug mode before going live.")
end)