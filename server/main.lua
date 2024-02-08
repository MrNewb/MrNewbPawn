
ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local dwebhook = "Pleace a webhook link here"

function sendToDiscord (name,message)
local embeds = {
    {
        ["title"]=message,
        ["type"]="rich",
        ["color"] =2061822,
        ["footer"]=  {
        ["text"]= "Server Name",
       },
    }
}

  if message == nil or message == '' then return FALSE end
  PerformHttpRequest(dwebhook, function(err, text, headers) end, 'POST', json.encode({ username = name,embeds = embeds}), { ['Content-Type'] = 'application/json' })
end

    RegisterServerEvent('MrNewbspawnshop:sell')
    AddEventHandler('MrNewbspawnshop:sell', function(itemName, amount, storenumber)
        local price = 0
        local xPlayer = ESX.GetPlayerFromId(source)
        for i, v in pairs(Config.Items) do
            if v.name == itemName and v.storenumber == storenumber then
                price = v.price
                break
            end
        end
        local xItem = xPlayer.getInventoryItem(itemName)


        if xItem.count < amount then
            TriggerClientEvent('esx:showNotification', source, _U('not_enough'))
            return
        end

        price = ESX.Math.Round(price * amount)

        if Config.GiveBlack then
            xPlayer.addAccountMoney('black_money', price)
        else
            xPlayer.addMoney(price)
        end

        xPlayer.removeInventoryItem(xItem.name, amount)

        TriggerClientEvent('esx:showNotification', source, _U('sold', amount, xItem.label, ESX.Math.GroupDigits(price)))
		sendToDiscord('MrNewbPawn log', xPlayer.name .. ' with steam id '.. xPlayer.getIdentifier().. ' Sold ' .. amount .. '  ' .. itemName .. ' for '  .. price.. ' total inventory weight is '..xPlayer.getWeight())
    end)
