ESX = nil
local playersHealing = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


function inarray( array , value )
	for k,v in ipairs(array) do
		if ( v == value ) then
			return k
		end
	end
	return nil
end

function afkPalyer (playerId)
	local xPlayer = ESX.GetPlayerFromId(playerId)
	local job = xPlayer.job.name
	local grade = xPlayer.job.grade

	if inarray(Config.offDutyJobs , job) ~= nil then
		xPlayer.setJob('off' ..job, grade)
	end
	TriggerClientEvent('erf_afk:isGoingOnAfk', playerId )
	TriggerClientEvent('chat:addMessage', -1, { args = { '^1'..GetPlayerName(playerId) , Config.startAfkMassage } })
end


function unafkPalyer (playerId)
	TriggerClientEvent('erf_afk:completedAfk', playerId )
	TriggerClientEvent('chat:addMessage', -1, { args = { '^1'..GetPlayerName(playerId) , Config.endAfkMassage } })
end


RegisterServerEvent('erf_afk:kickPlayer')
AddEventHandler('erf_afk:kickPlayer', function()
	if ( Config.kickAftherMassage ~= nil ) then
	local reason = Config.kickAftherMassage
	TriggerClientEvent('chat:addMessage', -1, {
		args = {"^1SYSTEM", "Player ^2" .. GetPlayerName(source) .. "^0 has been kicked(^2" .. reason .. "^0)"}
	})
	DropPlayer(source, reason)
	else
		DropPlayer(source, 'please rejoin.')
	end
end)


RegisterServerEvent('erf_afk:startafk')
AddEventHandler('erf_afk:startafk', function()
	afkPalyer(source)
end)

TriggerEvent('es:addCommand', 'afk', function(source, args, user)
	afkPalyer(source)
end, {help = 'start Afk and game stop for you' })


TriggerEvent('es:addCommand', 'unafk', function(source, args, user)
	unafkPalyer(source)
end, {help = 'ending Afk andreturn too game.' })


TriggerEvent('es:addGroupCommand', 'aafk', "mod", function(source, args, user)
	if args[1] then
		if(tonumber(args[1]) and GetPlayerName(tonumber(args[1])) ~= nil )then
			local player = tonumber(args[1])
			afkPalyer(player)
		else
			TriggerClientEvent('chat:addMessage', source, { args = {"^1SYSTEM", "Incorrect player ID"}})
		end
	else
		TriggerClientEvent('chat:addMessage', source, { args = {"^1SYSTEM", "Incorrect player ID"}})
	end
end, function(source, args, user)
	TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Insufficient Permissions.' } })
end, {help = 'afk player', params = {{name = "userid", help = "The ID of the player"}}})


TriggerEvent('es:addGroupCommand', 'aunafk', "mod", function(source, args, user)
	if args[1] then
		if(tonumber(args[1]) and GetPlayerName(tonumber(args[1])) ~= nil )then
			local player = tonumber(args[1])
			unafkPalyer(player)
		else
			TriggerClientEvent('chat:addMessage', source, { args = {"^1SYSTEM", "Incorrect player ID"}})
		end
	else
		TriggerClientEvent('chat:addMessage', source, { args = {"^1SYSTEM", "Incorrect player ID"}})
	end
end, function(source, args, user)
	TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Insufficient Permissions.' } })
end, {help = 'un afk player', params = {{name = "userid", help = "The ID of the player"}}})
