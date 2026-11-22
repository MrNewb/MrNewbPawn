function GetItemLabelAndIcon(itemName)
	local itemInfo = bridge.inventory.getItemInfo(itemName) or {}
	return itemInfo.label or itemName, itemInfo.image or 'fa-solid fa-box'
end

function AskItemAmount(heading, label, maxCount)
	if maxCount < 1 then return end

	local input = bridge.inputs.inputdialog(heading, {
		{ type = 'slider', label = label, min = 1, max = maxCount, step = 1 },
	})
	if not input or not input[1] then return end

	return math.floor(input[1])
end
