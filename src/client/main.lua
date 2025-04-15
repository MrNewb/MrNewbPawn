ActivePoints = {}
ShopBlips = {}
CreatedPeds = {}
CreatedZones = {}

local function maidService()
    DebugInfo("Cleaning up...")
    for k, v in pairs(ActivePoints) do
        Bridge.Point.Remove(k)
        DebugInfo("Removing point: " .. k)
    end
    for k, v in pairs(ShopBlips) do
        Bridge.Utility.RemoveBlip(tonumber(v))
        DebugInfo("Removing blip: " .. v)
    end
    for k, v in pairs(CreatedPeds) do
        SetEntityAsMissionEntity(v, false, true)
        DeleteEntity(v)
        DebugInfo("Removing ped: " .. v)
    end
    for k, v in pairs(CreatedZones) do
        Bridge.Target.RemoveZone(v)
        DebugInfo("Removing zone: " .. v)
    end
    ActivePoints = {}
    ShopBlips = {}
    CreatedPeds = {}
    CreatedZones = {}
    DebugInfo("Cleanup complete.")
end

RegisterNetEvent("community_bridge:Client:OnPlayerLoaded", function()
    RegisterPawnPoints()
    RegisterGoldMeltPoints()
end)

RegisterNetEvent("community_bridge:Client:OnPlayerUnload", function()
    maidService()
end)

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
        maidService()
    end)
end