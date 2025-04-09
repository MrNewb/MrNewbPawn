RegisterNetEvent("MrNewbPawn_V2:Server:SellPawn", function(item, amount)
    local src = source
    local verified = Config.PawnItems[item]
    if not verified then return Bridge.Notify.SendNotify(src, locale("Warnings.InvalidItem"), "error", 6000) end
    local itemCheck = Bridge.Inventory.GetItemCount(src, item)
    if itemCheck < amount then return Bridge.Notify.SendNotify(src, locale("Warnings.DoNotHave"), "error", 6000) end
    Bridge.Inventory.RemoveItem(src, item, amount)
    local price = verified * amount
    Bridge.Framework.AddAccountBalance(src, "money", price)
end)

RegisterNetEvent('MrNewbPawn_V2:Server:Scrapping', function(itemName, amount)
    local src = source
    local meltableItems = Config.MeltableItems[itemName]
    if not meltableItems then return Bridge.Notify.SendNotify(src, locale("Warnings.InvalidItem"), "error", 6000) end
    local itemCheck = Bridge.Inventory.GetItemCount(src, itemName)
    if itemCheck < amount then return Bridge.Notify.SendNotify(src, locale("Warnings.DoNotHave"), "error", 6000) end
    Bridge.Inventory.RemoveItem(src, itemName, amount)
    for _, reward in pairs(meltableItems) do
        local rewardCount = reward.count * amount
        Bridge.Inventory.AddItem(src, reward.itemName, rewardCount)
    end
    Bridge.Notify.SendNotify(src, locale("Smelting.SmeltingSuccess"), "success", 6000)
end)

CreateThread(function()
    Wait(1000)
    Bridge.Version.VersionChecker("MrNewb/MrNewbPawn", false)
end)