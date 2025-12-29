ActiveShops = {}
PawnShopsClass = {}
PawnShopsClass.__index = PawnShopsClass

function PawnShopsClass:new(id, position)
    local obj = {
        id = id,
        coords = position,
        itemlist = Config.PawnShops[id].itemlist,
        pawnedItems = {}
    }
    setmetatable(obj, self)
    ActiveShops[id] = obj
    return obj
end

function PawnShopsClass:sendLog(message)
    Bridge.Logs.CreateLog(message)
    return self
end

function PawnShopsClass:sellItem(src, item, count)
    if count <= 0 then return false end
    local itemCount = Bridge.Inventory.GetItemCount(src, item, nil)
    if itemCount < count then return false end

    local price = self.itemlist[item]
    if not price then return false end

    local success = Bridge.Inventory.RemoveItem(src, item, count, nil)
    if not success then return false end

    if not self.pawnedItems[item] then self.pawnedItems[item] = {count = 0, price = (self.itemlist[item] or 0) * 20} end
    self.pawnedItems[item].count = (self.pawnedItems[item].count or 0) + count

    local firstName, lastName = Bridge.Framework.GetPlayerName(src)
    local formattedName = string.format("%s %s", firstName, lastName)
    self:sendLog(locale("LogMessages.SoldItem", formattedName, tostring(count), item, tostring(price * count)))
    Bridge.Framework.AddAccountBalance(src, "money", price * count)
    return true, Bridge.Notify.SendNotify(src, locale("PawnShop.SoldItem", count, item, price * count), "success", 6000)
end

function PawnShopsClass:buyItem(src, item, count)
    if count <= 0 then return false end
    local itemData = self.pawnedItems[item]
    if not itemData then return false end
    if itemData.count < count then return false end

    local balance = Bridge.Framework.GetAccountBalance(src, "money")
    if balance <= 0 then return false, Bridge.Notify.SendNotify(src, locale("Warnings.NotEnoughMoney"), "error", 6000) end
    if balance < (itemData.price * count) then return false, Bridge.Notify.SendNotify(src, locale("Warnings.NotEnoughMoney"), "error", 6000) end

    Bridge.Framework.RemoveAccountBalance(src, "money", itemData.price * count)
    Bridge.Inventory.AddItem(src, item, count, nil)
    self.pawnedItems[item].count = self.pawnedItems[item].count - count
    if self.pawnedItems[item].count <= 0 then self.pawnedItems[item] = nil end

    local firstName, lastName = Bridge.Framework.GetPlayerName(src)
    local formattedName = string.format("%s %s", firstName, lastName)
    self:sendLog(locale("LogMessages.PurchasedItem", formattedName, tostring(count), item, tostring(itemData.price * count)))
    return true
end

Bridge.Callback.Register('MrNewbPawn_V2:Callback:GetPawnedStock', function(src, id)
    if not ActiveShops[id] then return {} end
    local shopObj = ActiveShops[id]
    return shopObj.pawnedItems
end)

RegisterNetEvent("MrNewbPawn_V2:Server:SellPawn", function(id, item, count)
    local src = source
    local shopObj = ActiveShops[id]
    if not shopObj then return Bridge.Notify.SendNotify(src, locale("Warnings.InvalidShop"), "error", 6000) end
    if not shopObj.itemlist[item] then return Bridge.Notify.SendNotify(src, locale("Warnings.InvalidItem"), "error", 6000) end
    shopObj:sellItem(src, item, count)
end)

RegisterNetEvent("MrNewbPawn_V2:Server:PurchasePawnedItem", function(id, item, count)
    local src = source
    local shop = ActiveShops[id]
    if not shop then return Bridge.Notify.SendNotify(src, locale("Warnings.InvalidShop"), "error", 6000) end
    if not shop.pawnedItems[item] then return Bridge.Notify.SendNotify(src, locale("Warnings.InvalidItem"), "error", 6000) end

    local pedCoords = GetEntityCoords(GetPlayerPed(src))
    local shopCoords = vector3(shop.coords.x, shop.coords.y, shop.coords.z)
    if #(pedCoords - shopCoords) > 5.0 then return Bridge.Notify.SendNotify(src, locale("Warnings.TooFarFromShop"), "error", 6000) end

    shop:buyItem(src, item, count)
end)

AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    Bridge.Version.AdvancedVersionChecker("MrNewb/patchnotes", "community_bridge")
    Bridge.Version.AdvancedVersionChecker("MrNewb/patchnotes", resource)
    for shopName, shopData in pairs(Config.PawnShops) do
        PawnShopsClass:new(shopName, shopData.position)
    end
end)