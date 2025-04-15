Bridge = exports.community_bridge:Bridge()

function locale(message)
    return Bridge.Language.Locale(message)
end

function GenerateRandomString()
    return Bridge.Ids.RandomLower(nil, 8)
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
else
    function NotifyPlayer(message, _type, time)
        if not message or not _type then return end
        return Bridge.Notify.SendNotify(message, _type, time)
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
end