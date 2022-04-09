ESX = exports["es_extended"]:getSharedObject()

ESX.RegisterServerCallback('kim-camera:checkinventoryitem', function(source,cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    local identifier = xPlayer.identifier

    if xPlayer.getInventoryItem(Config.ItemCamera).count >= 1 then
        xPlayer.removeInventoryItem(Config.ItemCamera, 1)
        cb(true)
    else
        cb(false)
    end
end)
