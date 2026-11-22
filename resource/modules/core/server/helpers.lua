function IsOnCooldown(lastUseBySource, src)
	local now = GetGameTimer()
	if lastUseBySource[src] and now - lastUseBySource[src] < 1000 then return true end
	lastUseBySource[src] = now
	return false
end

function ParseWholeNumber(value, maxValue)
	local number = tonumber(value)
	if not number or number % 1 ~= 0 or number < 1 or number > maxValue then return end
	return number
end

function LogPawnAction(src, key, ...)
	local _, firstName, lastName = bridge.framework.getCharacterName(bridge.framework.getIdentifier(src))
	local message = locale(key, ('%s %s'):format(firstName or '', lastName or ''), ...)
	lib.logger(src, 'pawn', message)
	if Config.Logging then print(('[MrNewbPawn] %s'):format(message)) end
end
