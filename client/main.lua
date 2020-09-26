Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}
local isAFK = false
local lastCordinate = nil
local prevPos = nil
local ESX = nil
local tempTime = nil
local tempTimeKick = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

end)

function FastTravel(coords, heading)
	local playerPed = PlayerPedId()

	DoScreenFadeOut(500)

	while not IsScreenFadedOut() do
		Citizen.Wait(500)
	end

	ESX.Game.Teleport(playerPed, coords, function()
		DoScreenFadeIn(500)

		if heading then
			SetEntityHeading(playerPed, heading)
		end
	end)
end

RegisterNetEvent('erf_afk:showError')
AddEventHandler('erf_afk:showError', function(error)
	PlaySound(-1, "Menu_Accept", "Phone_SoundSet_Default", 0, 0, 1)
	ESX.ShowNotification(_U('error_'..error))
end)


RegisterNetEvent('erf_afk:isGoingOnAfk')
AddEventHandler('erf_afk:isGoingOnAfk', function()
	if not isAFK then
		local playerPed = GetPlayerPed(-1)
		lastCordinate = GetEntityCoords(playerPed, true)
		isAFK = true
		tempTimeKick = Config.maxAfkTime * 60
		local indexRandom = math.random(1, #Config.Points)
		local coords = vector3(Config.Points[indexRandom].x , Config.Points[indexRandom].y , Config.Points[indexRandom].z )
		FastTravel(coords , Config.Points[indexRandom].h )

		local player = PlayerId()
		local ped = PlayerPedId()

		SetEntityCollision(ped, false)
		FreezeEntityPosition(ped, true)
		SetPlayerInvincible(player, true)
		if not IsPedFatallyInjured(ped) then
			ClearPedTasksImmediately(ped)
		end
	end
end)

RegisterNetEvent('erf_afk:completedAfk')
AddEventHandler('erf_afk:completedAfk', function()
	local playerPed = GetPlayerPed(-1)
	local player = PlayerId()
	local ped = PlayerPedId()
	isAFK = false
	tempTimeKick = nil
	FastTravel(lastCordinate,0)
	if not IsEntityVisible(ped) then
		SetEntityVisible(ped, true)
	end

	if not IsPedInAnyVehicle(ped) then
		SetEntityCollision(ped, true)
	end

	FreezeEntityPosition(ped, false)
	SetPlayerInvincible(player, false)
end)


AddEventHandler('esx:onPlayerDeath', function(data)
	if isAFK then
		TriggerEvent('esx_erfan_ambulancejobErfan:revive', PlayerPedId())
	end
end)

Citizen.CreateThread(function()
	while true   do
		if isAFK then
			Wait(10000)
			local playerPed = GetPlayerPed(-1)
			if playerPed and tempTimeKick ~= nil  then
				ESX.ShowNotification(Config.unAFKHelp)
				if tempTimeKick > 0  then
					tempTimeKick = tempTimeKick - 10
				else
					FastTravel(lastCordinate,0)
					if not IsEntityVisible(ped) then
						SetEntityVisible(ped, true)
					end

					if not IsPedInAnyVehicle(ped) then
						SetEntityCollision(ped, true)
					end

					FreezeEntityPosition(ped, false)
					SetPlayerInvincible(player, false)
					TriggerEvent('esx_erfan_ambulancejobErfan:revive', PlayerPedId())
					TriggerServerEvent("erf_afk:kickPlayer")
				end
			end
		elseif Config.autoAFkAftherTime > 0 then
			Wait(5000)

			local playerPed = GetPlayerPed(-1)
			if playerPed and not IsPlayerDead(PlayerId()) then
				local currentPos = GetEntityCoords(playerPed, true)

				if currentPos == prevPos then
					if tempTime > 0 then
						if Config.kickWarning and tempTime <= 30 then
							TriggerEvent("chatMessage", "WARNING", {255, 0, 0}, "^1You'll be Freeze in " .. tempTime .. " seconds for being AFK!")
						end
						tempTime = tempTime - 5
					else
						lastCordinate = GetEntityCoords(playerPed, true)
						TriggerServerEvent("erf_afk:startafk")
					end
				else
					tempTime = Config.autoAFkAftherTime * 60
				end
				prevPos = currentPos
			end
		end
	end
end)


