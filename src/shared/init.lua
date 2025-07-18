Bridge = exports.community_bridge:Bridge()

function locale(message)
    return Bridge.Language.Locale(message)
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
    function NotifyPlayer(src, message, _type, time)
        if not message or not _type then return end
        return Bridge.Notify.SendNotify(src, message, _type, time)
    end

    function GetItemCount(src, itemName)
        return Bridge.Inventory.GetItemCount(src, itemName)
    end

    function RemoveItem(src, itemName, count)
        return Bridge.Inventory.RemoveItem(src, itemName, count)
    end

    function AddItem(src, itemName, count)
        return Bridge.Inventory.AddItem(src, itemName, count)
    end

    function AddAccountBalance(src, _type, amount)
        return Bridge.Framework.AddAccountBalance(src, _type, amount)
    end

    CreateThread(function()
        Wait(1000)
        Bridge.Version.VersionChecker("MrNewb/MrNewbPawn", false)
    end)
else
    function GetItemInfo(itemName)
        return Bridge.Inventory.GetItemInfo(itemName)
    end

    function GetItemCount(itemName)
        return Bridge.Inventory.GetItemCount(itemName)
    end

    function NotifyPlayer(message, _type, time)
        if not message or not _type then return end
        return Bridge.Notify.SendNotify(message, _type, time)
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
        Bridge.ProgressBar.Open({
            duration = duration,
            label = label,
            disable = {
                move = true,
                combat = true
            },
            anim = {
                dict = "amb@prop_human_bum_bin@idle_b",
                clip = "idle_d",
                flag = 49,
            }
        }, function(cancelled)
            if not cancelled then return true end
            return false
        end)
    end

    function GenerateLocalEntityTarget(entity, options)
        return Bridge.Target.AddLocalEntity(entity, options)
    end

    function RemoveLocalEntityTarget(entity, optionName)
        return Bridge.Target.RemoveLocalEntity(entity, optionName)
    end

    RegisterNetEvent("community_bridge:Client:OnPlayerLoaded", function()
        RegisterPawnPoints()
        RegisterGoldMeltPoints()
    end)

    RegisterNetEvent("community_bridge:Client:OnPlayerUnload", function()
        MaidService()
    end)
end