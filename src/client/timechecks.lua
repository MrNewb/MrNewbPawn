function VerifyDayTime(storeName)
    local currenthour = GetClockHours()
    if Config.PawnShops[storeName] and Config.PawnShops[storeName].StoreHours then
        local storeHours = Config.PawnShops[storeName].StoreHours
        if storeHours.open <= currenthour and storeHours.close >= currenthour then
            return true
        end
        return false
    end

    return true
end