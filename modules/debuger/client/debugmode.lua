if not Config.Utility.Debug then return end

AddEventHandler('onResourceStart', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    Wait(2000)
    DestroyAllPawnShops()
    RegisterPawnPoints()
    RemoveAllSmelters()
    RegisterSmeltPoints()
    DebugInfo("Resource started in debug mode: " .. resource)
    DebugInfo("Debug mode is enabled.")
    DebugInfo("Registering pawn points and smelting points.")
    DebugInfo("This is not for production use in this mode, it is here for prints and testing of tweaks.")
    DebugInfo("Please disable debug mode before going live.")
end)