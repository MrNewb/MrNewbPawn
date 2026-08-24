if not Config.Debug then return end

AddEventHandler('onClientResourceStart', function(resourceName)
	if resourceName ~= GetCurrentResourceName() then return end

	Wait(2000)
	RemovePawnShops()
	CreatePawnShops()
	RemoveFoundries()
	CreateFoundries()
	print('[MrNewbPawn] Debug reload: shops and foundries were rebuilt.')
end)
