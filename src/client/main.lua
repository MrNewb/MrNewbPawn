ActivePoints = {}
ShopBlips = {}
CreatedPeds = {}
CreatedZones = {}

function MaidService()
    for k, _ in pairs(ActivePoints) do
        Bridge.Point.Remove(k)
    end
    for _, v in pairs(ShopBlips) do
        Bridge.Utility.RemoveBlip(tonumber(v))
    end
    for _, v in pairs(CreatedPeds) do
        SetEntityAsMissionEntity(v, false, true)
        DeleteEntity(v)
    end
    for _, v in pairs(CreatedZones) do
        Bridge.Target.RemoveZone(v)
    end
    ActivePoints = {}
    ShopBlips = {}
    CreatedPeds = {}
    CreatedZones = {}
end

if Config.Utility.Debug then
    AddEventHandler('onResourceStart', function(resource)
        if resource ~= GetCurrentResourceName() then return end
        RegisterPawnPoints()
        RegisterGoldMeltPoints()
        DebugInfo("Resource started in debug mode: " .. resource)
        DebugInfo("Debug mode is enabled.")
        DebugInfo("Registering pawn points and gold melt points.")
        DebugInfo("This is not for production use in this mode, it is here for prints and testing of tweaks.")
        DebugInfo("Please disable debug mode before going live.")
    end)

    AddEventHandler('onResourceStop', function(resource)
        if resource ~= GetCurrentResourceName() then return end
        MaidService()
    end)
end