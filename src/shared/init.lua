Bridge = exports.community_bridge:Bridge()

function locale(message)
    return Bridge.Language.Locale(message)
end

function GenerateRandomString()
    return Bridge.Ids.RandomLower(nil, 8)
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
end