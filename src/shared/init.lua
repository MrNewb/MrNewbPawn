Bridge = exports.community_bridge:Bridge()

function locale(message, ...)
    return Bridge.Language.Locale(message, ...)
end

function GenerateRandomString()
    local prefix = "MrNewbPawn_"
    local randomString = Bridge.Ids.RandomLower(nil, 8)
    return prefix .. randomString
end

function DebugInfo(message)
    if not Config.Utility.Debug then return end
    Bridge.Prints.Debug(message)
end

if IsDuplicityVersion() then
    NotifyPlayer = Bridge.Notify.SendNotify

    GetItemCount = Bridge.Inventory.GetItemCount

    RemoveItem = Bridge.Inventory.RemoveItem

    AddItem = Bridge.Inventory.AddItem

    AddAccountBalance = Bridge.Framework.AddAccountBalance

    AddEventHandler('onResourceStart', function(resource)
        if resource ~= GetCurrentResourceName() then return end
        Bridge.Version.AdvancedVersionChecker("MrNewb/patchnotes", resource)
    end)
else

    GetItemInfo = Bridge.Inventory.GetItemInfo

    GetItemCount = Bridge.Inventory.GetItemCount

    NotifyPlayer = Bridge.Notify.SendNotify

    function OpenInputMenu(label, options)
        return Bridge.Input.Open(label, options, false, locale("SubmitText"))
    end

    function VerifyDayTime(storeName)
        local currenthour = GetClockHours()
        if Config.PawnShops[storeName] and Config.PawnShops[storeName].StoreHours then
            local storeHours = Config.PawnShops[storeName].StoreHours
            if storeHours.open <= currenthour and storeHours.close >= currenthour then return true end
            return false
        end
        return true
    end

    function BeginProgressBar(duration, label)
        local success = Bridge.ProgressBar.Open({
            duration = duration,
            label = label,
            disable = { move = true, combat = true },
            anim = { dict = "amb@prop_human_bum_bin@idle_b", clip = "idle_d", flag = 49,},
            canCancel = true,
        })
        return success
    end

    GenerateLocalEntityTarget = Bridge.Target.AddLocalEntity

    RemoveLocalEntityTarget = Bridge.Target.RemoveLocalEntity

    RegisterNetEvent("community_bridge:Client:OnPlayerLoaded", function()
        RegisterPawnPoints()
        RegisterGoldMeltPoints()
    end)

    RegisterNetEvent("community_bridge:Client:OnPlayerUnload", function()
        MaidService()
    end)
end