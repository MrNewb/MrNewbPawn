Foundry = {}
FoundrysClass = {}
FoundrysClass.__index = FoundrysClass

function FoundrysClass:new(id, position)
    local obj = {
        id = id,
        coords = position,
        itemlist = Config.MeltableItems,
    }
    setmetatable(obj, self)
    Foundry[id] = obj
    return obj
end

function FoundrysClass:HandleScrapping(src, itemName, amount)
    local ped = GetPlayerPed(src)
    local pedCoords = GetEntityCoords(ped)
    local dist = #(pedCoords - vector3(self.coords.x, self.coords.y, self.coords.z))
    if dist > 10.0 then return Bridge.Notify.SendNotify(src, locale("Warnings.Canceled"), "error", 6000) end
    local itemCount = Bridge.Inventory.GetItemCount(src, itemName, nil)
    if itemCount < amount then return Bridge.Notify.SendNotify(src, locale("Warnings.NotEnoughItem"), "error", 6000) end

    local foundData = self.itemlist[itemName]
    if not foundData then return Bridge.Notify.SendNotify(src, locale("Smelting.CannotMelt"), "error", 6000) end

    local success = Bridge.Inventory.RemoveItem(src, itemName, amount)
    if not success then return end

    for _, reward in pairs(foundData) do
        Bridge.Inventory.AddItem(src, reward.itemName, (reward.count * amount))
    end
    Bridge.Notify.SendNotify(src, locale("Smelting.SmeltingSuccess"), "success", 6000)
end

RegisterNetEvent('MrNewbPawn:Server:SmeltItem', function(itemName, amount, foundryId)
    local src = source
    if not itemName or not amount or not foundryId then return end
    amount = tonumber(amount)
    if amount <= 0 then return end
    local foundry = Foundry[foundryId]
    if not foundry then return end
    foundry:HandleScrapping(src, itemName, amount)
end)

AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    for id, data in pairs(Config.FoundryLocations) do
        FoundrysClass:new(id, data.position)
    end
end)