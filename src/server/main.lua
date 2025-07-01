RegisterNetEvent("MrNewbPawn_V2:Server:SellPawn", function(item, amount)
    local src = source
    local verified = Config.PawnItems[item]
    if not verified then return NotifyPlayer(src, locale("Warnings.InvalidItem"), "error", 6000) end
    local itemCheck = GetItemCount(src, item)
    if itemCheck < amount then return NotifyPlayer(src, locale("Warnings.DoNotHave"), "error", 6000) end
    RemoveItem(src, item, amount)
    local price = verified * amount
    AddAccountBalance(src, "money", price)
end)

RegisterNetEvent('MrNewbPawn_V2:Server:Scrapping', function(itemName, amount)
    local src = source
    local meltableItems = Config.MeltableItems[itemName]
    if not meltableItems then return NotifyPlayer(src, locale("Warnings.InvalidItem"), "error", 6000) end
    local itemCheck = GetItemCount(src, itemName)
    if itemCheck < amount then return NotifyPlayer(src, locale("Warnings.DoNotHave"), "error", 6000) end
    RemoveItem(src, itemName, amount)
    for _, reward in pairs(meltableItems) do
        local rewardCount = reward.count * amount
        AddItem(src, reward.itemName, rewardCount)
    end
    NotifyPlayer(src, locale("Smelting.SmeltingSuccess"), "success", 6000)
end)

