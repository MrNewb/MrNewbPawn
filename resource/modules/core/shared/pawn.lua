MAX_TRADE_COUNT = 100
MAX_MELT_COUNT = 50

function IsValidId(value)
	return type(value) == 'string' and value ~= '' and #value <= 64
end

function GetMeltRewards(itemName)
	local meltItem = Config.MeltableItems[itemName]
	if not meltItem then return end
	return meltItem.rewards or (meltItem[1] and meltItem)
end
