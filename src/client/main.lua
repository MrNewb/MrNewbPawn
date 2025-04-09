ActivePoints = {}
ShopBlips = {}
CreatedPeds = {}
CreatedZones = {}

local function maidService()
    for k, v in pairs(ActivePoints) do
        Bridge.Point.Remove(k)
    end
    for k, v in pairs(ShopBlips) do
        Bridge.Utility.RemoveBlip(tonumber(v))
    end
    for k, v in pairs(CreatedPeds) do
        SetEntityAsMissionEntity(v, false, true)
        DeleteEntity(v)
    end
    for k, v in pairs(CreatedZones) do
        Bridge.Target.RemoveZone(v)
    end
    ActivePoints = {}
    ShopBlips = {}
    CreatedPeds = {}
    CreatedZones = {}
end

AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    RegisterPawnPoints()
    RegisterGoldMeltPoints()
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    maidService()
end)