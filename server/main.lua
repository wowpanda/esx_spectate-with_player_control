ESX = nil

TriggerEvent('esx:getSharedObject', function(obj)ESX = obj end)

TriggerEvent('es:addGroupCommand', 'spec', "admin", function(source, args, user)
    TriggerClientEvent('esx_spectate:spectate', source, target)
end, function(source, args, user)
    TriggerClientEvent('chatMessage', source, "SYSTEM", {255, 0, 0}, "Insufficienct permissions!")
end)

ESX.RegisterServerCallback('esx_spectate:getPlayerData', function(source, cb, id)
    local xPlayer = ESX.GetPlayerFromId(id)
    if xPlayer ~= nil then
        cb(xPlayer)
    end
end)

RegisterServerEvent('esx_spectate:kick')
AddEventHandler('esx_spectate:kick', function(target, msg)
	local xPlayer = ESX.GetPlayerFromId(source)

	if xPlayer.getGroup() ~= 'user' then
		DropPlayer(target, msg)
	else
		print(('esx_spectate: %s attempted to kick a player!'):format(xPlayer.identifier))
		DropPlayer(source, "esx_spectate: you're not authorized to kick people dummy.")
	end
end)

ESX.RegisterServerCallback('esx_spectate:getOtherPlayerData', function(source, cb, target)
    local xPlayer = ESX.GetPlayerFromId(target)
    local result = MySQL.Sync.fetchAll("SELECT * FROM users WHERE identifier = @identifier", {
        ['@identifier'] = GetLicense(target, "license")
    })
    
    local user = result[1]
    local firstname = user['firstname']
    local lastname = user['lastname']
    local sex = user['sex']
    local dob = user['dateofbirth']
    local height = user['height'] .. " Centimetri"
    local money = user['money']
    local bank = user['bank']
    
    local data = {
        name = GetPlayerName(target),
        job = xPlayer.job,
        inventory = xPlayer.inventory,
        accounts = xPlayer.accounts,
        weapons = xPlayer.loadout,
        firstname = firstname,
        lastname = lastname,
        sex = sex,
        dob = dob,
        height = height,
        money = money,
        bank = bank
    }
    
    TriggerEvent('esx_license:getLicenses', target, function(licenses)
        data.licenses = licenses
    end)
    cb(data)
end)

GetLicense = function (src, type)
    -- Types: steam, license, ip
    for k,v in ipairs(GetPlayerIdentifiers(src)) do
        if string.sub(v, 1, string.len(type)) == string.lower(type) then
            return string.sub(v, 9, string.len(v))
        end
    end
    return false
end