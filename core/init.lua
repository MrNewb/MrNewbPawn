Bridge = exports.community_bridge:Bridge()

function locale(message, ...)
    return Bridge.Language.Locale(message, ...)
end

function GenerateRandomString()
    local prefix = "MrNewbPawn_"
    local randomString = Bridge.Ids.RandomLower(nil, 8)
    return string.format("%s%s", prefix, randomString)
end

function DebugInfo(message)
    if not Config.Utility.Debug then return end
    Bridge.Prints.Debug(message)
end