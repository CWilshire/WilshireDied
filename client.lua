--[[
Made by C. Wilshire#5885 for use on fivem server DHSRP (discord.gg/BrmN6EA)
Use/modification is permitted with proper credit.
Credits for project are found in README.md
]]

RegisterNetEvent('wd:allowRespawn')
RegisterNetEvent('wd:allowRevive') 
RegisterNetEvent('wd:toggleDeath')
RegisterNetEvent('wd:staffrevive')
RegisterNetEvent('wd:reviveallcheck')
RegisterNetEvent('wd:reviveall')

local reviveWaitPeriod = 360 -- How many seconds to wait before allowing player to revive themselves
local knockedOutTime = 90 -- How long to have the played be knocked out in seconds
local displayKOEffects = 120 -- How long to display the Knocked Out effects
local WDEnabled = true  -- DO NOT CHANGE. Was a depreciated toggle, and was removed.


-- Turn off automatic respawn here instead of updating FiveM file.
AddEventHandler('onClientMapStart', function()

	exports.spawnmanager:spawnPlayer() -- Ensure player spawns into server.
	Citizen.Wait(2500)
	exports.spawnmanager:setAutoSpawn(false)

end)

 
local allowRespawn = false
local allowRevive = false
local diedTime = nil
local adminReviveCommand = false
local wasKnockedOut = false
local reviveGood = false



AddEventHandler('wd:allowRespawn', function(from)
	TriggerEvent('chatMessage', "WILSHDIED", {200,0,0}, "Respawned")
	allowRespawn = true
end)






AddEventHandler('wd:allowRevive', function(from)
	if(not IsEntityDead(GetPlayerPed(-1)))then
		-- You are alive, do nothing.
		return
	end

	-- Trying to revive themselves?
	if(GetPlayerServerId(PlayerId()) == from and diedTime ~= nil and wasKnockedOut == false)then
		local waitPeriod = diedTime + (reviveWaitPeriod * 1000)
		if(GetGameTimer() < waitPeriod)then
			local seconds = math.ceil((waitPeriod - GetGameTimer()) / 1000)
			local message = ""
			if(seconds > 60)then
				local minutes = math.floor((seconds / 60))
				seconds = math.ceil(seconds-(minutes*60))
				message = minutes.." minutes "
			end
			message = message..seconds.." seconds"
			TriggerEvent('chatMessage', "WILSHDIED", {200,0,0}, "You must wait before reviving yourself, you have ^5"..message.."^0 remaining.")
			return		
		end
	end
	if wasKnockedOut then
		TriggerEvent('chatMessage', "WILSHDIED", {200,0,0}, "You must wait out the timer. You will be automatically stood up.")
		return
	end
	-- Revive the player.
	TriggerEvent('chatMessage', "WILSHDIED", {200,0,0}, "Revived")
	allowRevive = true

end)


AddEventHandler('wd:toggleDeath', function(from)
	WDEnabled = not WDEnabled
	if (WDEnabled) then
		TriggerEvent('chatMessage', "WILSHDIED", {200,0,0}, "WDEnabled enabled.")
	else
		TriggerEvent('chatMessage', "WILSHDIED", {200,0,0}, "WDEnabled disabled.")
	end
end)




function revivePed(ped)
	local playerPos = GetEntityCoords(ped, true)
	NetworkResurrectLocalPlayer(playerPos, true, true, false)
	SetPlayerInvincible(ped, false)
	ClearPedBloodDamage(ped)
	if not adminReviveCommand then 
		Citizen.Wait(10)
		SetPedToRagdoll(ped, 1000, 1000, 0, 0, 0, 0)
	end
end


function respawnPed(ped,coords)
	SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false, true)
	NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, coords.heading, true, false) 

	SetPlayerInvincible(ped, false) 

	TriggerEvent('playerSpawned', coords.x, coords.y, coords.z, coords.heading)
	ClearPedBloodDamage(ped)
end

-- This is a flaw by design to catch roleplay cheaters. You can patch it if you wish.
AddEventHandler('wd:staffrevive', function(from)
	TriggerServerEvent('messageveryonexd')
	allowRevive = true
	wasKnockedOut = false
	adminReviveCommand = true

	
	ClearPedTasksImmediately(GetPlayerPed(-1))
	ShakeGameplayCam("FAMILY5_DRUG_TRIP_SHAKE", 0)
	SetPedIsDrunk(GetPlayerPed(-1), false)
	SetPedConfigFlag(GetPlayerPed(-1), 100, false)
	ResetPedMovementClipset(GetPlayerPed(-1), 0)
	
end)

AddEventHandler('wd:reviveall', function(from)
	allowRevive = true
	wasKnockedOut = false
	adminReviveCommand = true

	
	ClearPedTasksImmediately(GetPlayerPed(-1))
	ShakeGameplayCam("FAMILY5_DRUG_TRIP_SHAKE", 0)
	SetPedIsDrunk(GetPlayerPed(-1), false)
	SetPedConfigFlag(GetPlayerPed(-1), 100, false)
	ResetPedMovementClipset(GetPlayerPed(-1), 0)
end)


Citizen.CreateThread(function()
	local respawnCount = 0
	local spawnPoints = {}
	local playerIndex = NetworkGetPlayerIndex(-1) or 0


	math.randomseed(playerIndex)

	function createSpawnPoint(x1,x2,y1,y2,z,heading)
		local xValue = math.random(x1,x2) + 0.0001
		local yValue = math.random(y1,y2) + 0.0001

		local newObject = {
			x = xValue,
			y = yValue,
			z = z + 0.0001,
			heading = heading + 0.0001
		}
		table.insert(spawnPoints,newObject)
	end

	createSpawnPoint(-448, -448, -340, -329, 35.5, 0) -- Mount Zonah
	createSpawnPoint(372, 375, -596, -594, 30.0, 0)   -- Pillbox Hill
	createSpawnPoint(335, 340, -1400, -1390, 34.0, 0) -- Central Los Santos
	createSpawnPoint(1850, 1854, 3700, 3704, 35.0, 0) -- Sandy Shores
	createSpawnPoint(-247, -245, 6328, 6332, 33.5, 0) -- Paleto
	--createSpawnPoint(1152, 1156, -1525, -1521, 34.9, 0) -- St. Fiacre
	
	
	while true do
		Wait(0)
		local ped = GetPlayerPed(-1)
		
		if (WDEnabled) then
	if (IsEntityDead(ped)) then
				if(diedTime == nil)then
					diedTime = GetGameTimer()
				end
			
				
				if tostring(GetPedCauseOfDeath(PlayerPedId())) == tostring(-1569615261) or --unarmed
				tostring(GetPedCauseOfDeath(PlayerPedId())) == tostring(1737195953) or --nightstick
				tostring(GetPedCauseOfDeath(PlayerPedId())) == tostring(-656458692) or --knuckleduster
				tostring(GetPedCauseOfDeath(PlayerPedId())) == tostring(-37975472) or --Tear Gas
				tostring(GetPedCauseOfDeath(PlayerPedId())) == tostring(911657153) or --Taser
				tostring(GetPedCauseOfDeath(PlayerPedId())) == tostring(-1951375401) then --flashlight
					TriggerEvent('chatMessage', "WILSHDIED", {200,0,0}, "You've been knocked out for ".. knockedOutTime .. " seconds.")
						local allowSync = false
						local previousSyncNum = 0
						wasKnockedOut = true
						local hasFirstTimePlayed = false
						local waitPeriod = diedTime + (knockedOutTime * 1000)
						--exports['progressBars']:startUI((knockedOutTime * 1000), " ")
						
						
						while (not adminReviveCommand) and (GetGameTimer() < waitPeriod) and (not allowRevive) do 
							Citizen.Wait(0)
							
							if ((math.ceil((waitPeriod - GetGameTimer()) /1000) % 30 == 0) and (not allowSync) and (math.ceil((waitPeriod - GetGameTimer()) /1000) ~= knockedOutTime) and (previousSyncNum ~= math.ceil((waitPeriod - GetGameTimer()) /1000))) then
								allowSync = true
							else
								allowSync = false
							end
							if (allowSync and (math.floor(GetEntitySpeed(GetPlayerPed(-1))) == 0) and (not IsPedInAnyVehicle(GetPlayerPed(-1),1))) then
								local plyCoords = GetEntityCoords(PlayerPedId(), true)
								ResurrectPed(PlayerPedId())
								SetEntityHealth(PlayerPedId(), 200)
								SetEntityCoords(PlayerPedId(), plyCoords.x, plyCoords.y, plyCoords.z, 0, 0, 0, 0)
								SetEntityHealth(PlayerPedId(), 0)
								TriggerEvent('chatMessage', "WILSHDIED", {200,0,0}, "Player location synced.")
								previousSyncNum = math.ceil((waitPeriod - GetGameTimer()) /1000)
							end
							
							DrawTextCustom(0.9, 1.265, 1.0,1.0,0.45, "You have " .. math.ceil((waitPeriod-GetGameTimer()) / 1000)..  " more seconds of being knocked out. ", 255, 25, 0, 255)
						end
						allowRevive = true
						adminReviveCommand = false
						TriggerEvent('chatMessage', "WILSHDIED", {200,0,0}, "You've stood up from being knocked out.")
						
				else
					SetPlayerInvincible(ped, true)
					SetEntityHealth(ped, 1)	

					if (diedTime == GetGameTimer()) and (not wasKnockedOut) then
						traditionalDeath(reviveWaitPeriod)
					end


				end
				
				
				if (allowRespawn) then 
					local coords = spawnPoints[math.random(1,#spawnPoints)]

					respawnPed(ped, coords)

			  		allowRespawn = false
			  		diedTime = nil
					respawnCount = respawnCount + 1
					math.randomseed( playerIndex * respawnCount )

				elseif (allowRevive) then
				
					revivePed(ped)
					if not wasKnockedOut then
						TriggerEvent('chatMessage', "WILSHDIED RULE", {200,0,0}, "^12.11 NLR - New Life Rule. If you are declared dead you cannot return to the situation you were involved in, nor can you partake in it for 15 minutes. You can return with another character but may not get involved. If the situation moves location and you accidentally get caught up in it you must make all efforts to leave.")
					end
					allowRevive = false	
		  			diedTime = nil
					Wait(0)
					if (wasKnockedOut) then
						displayAfterEffects(displayKOEffects)
						wasKnockedOut = false
					end
					
				else
		  			Wait(0)
				end
			else
		  		allowRespawn = false
		  		allowRevive = false	
				adminReviveCommand = false
		  		diedTime = nil		
				Wait(0)
			end


		else 
			if IsEntityDead(ped) then
				Wait(3000) 

				local coords = spawnPoints[math.random(1,#spawnPoints)]

				respawnPed(ped,coords)

				respawnCount = respawnCount + 1
				math.randomseed( playerIndex * respawnCount )
				
			end
		end

	end
end)

function displayAfterEffects(timeToEffect)

	if not HasAnimSetLoaded("MOVE_M@DRUNK@VERYDRUNK") then
		RequestAnimSet("MOVE_M@DRUNK@VERYDRUNK")
		while not HasAnimSetLoaded("MOVE_M@DRUNK@VERYDRUNK") do
			Citizen.Wait(0)
		end
	end
	StartScreenEffect("Dont_tazeme_bro",0,true)
	local resurrectTime = GetGameTimer()
	local waitPeriod = resurrectTime + (timeToEffect * 1000)
	SetPedToRagdoll(GetPlayerPed(-1), 1000, 1000, 0, 0, 0, 0)
	ShakeGameplayCam("FAMILY5_DRUG_TRIP_SHAKE", 1.0)
	while ((GetGameTimer() < waitPeriod) and (not IsEntityDead(GetPlayerPed(-1))) and (not adminReviveCommand)) do
		SetPedIsDrunk(GetPlayerPed(-1), true)
		SetPedConfigFlag(GetPlayerPed(-1), 100, true)
		SetPedMovementClipset(GetPlayerPed(-1), "MOVE_M@DRUNK@VERYDRUNK", 1.0)
		Citizen.Wait(0)
	end
	ShakeGameplayCam("FAMILY5_DRUG_TRIP_SHAKE", 0)
	SetPedIsDrunk(GetPlayerPed(-1), false)
	SetPedConfigFlag(GetPlayerPed(-1), 100, false)
	ResetPedMovementClipset(GetPlayerPed(-1), 0)
	StopScreenEffect("Dont_tazeme_bro")
end

function loadAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Citizen.Wait(5)
    end
end

function traditionalDeath(deathTime)
	local allowSync = false
	local previousSyncNum = 0
	reviveGood = false
	local waitPeriod1 = diedTime + (reviveWaitPeriod * 1000)

	while (not adminReviveCommand) and (GetGameTimer() < waitPeriod1) and (not allowRevive) do 
		Citizen.Wait(0)
		
		if ((math.ceil((waitPeriod1 - GetGameTimer()) /1000) % 30 == 0) and (not allowSync) and (math.ceil((waitPeriod1 - GetGameTimer()) /1000) ~= reviveWaitPeriod) and (previousSyncNum ~= math.ceil((waitPeriod1 - GetGameTimer()) /1000))) then

			allowSync = true
		else
			allowSync = false
		end

		if (allowSync and (math.floor(GetEntitySpeed(GetPlayerPed(-1))) == 0) and (not IsPedInAnyVehicle(GetPlayerPed(-1),1))) then
			local plyCoords = GetEntityCoords(PlayerPedId(), true)
			ResurrectPed(PlayerPedId())
			SetEntityHealth(PlayerPedId(), 200)
			SetEntityCoords(PlayerPedId(), plyCoords.x, plyCoords.y, plyCoords.z, 0, 0, 0, 0)
			SetEntityHealth(PlayerPedId(), 0)
			TriggerEvent('chatMessage', "WILSHDIED", {200,0,0}, "Player location synced.")
			previousSyncNum = math.ceil((waitPeriod1 - GetGameTimer()) /1000)
		end
		DrawTextCustom(0.88, 1.265, 1.0,1.0,0.45, "You have " .. math.ceil((waitPeriod1-GetGameTimer()) / 1000) .. " more seconds until you can do /revive. ", 255, 25, 0, 255)
	end
	while (IsEntityDead(GetPlayerPed(-1))) and (not allowRevive) do
		Citizen.Wait(1)
		reviveGood = true
	end

end

AddEventHandler('wd:reviveallcheck', function(from)
local plys = GetPlayers()

for _,i in ipairs(plys) do
	local ped = GetPlayerPed(i)
	if IsPedDeadOrDying(ped) then
	TriggerServerEvent('reviveallserver', GetPlayerServerId(i))
	end
end

end)

function GetPlayers()
    local players = {}

    for i = 0, 255 do
        if NetworkIsPlayerActive(i) then
            table.insert(players, i)
        end
    end

    return players
end


function DrawTextCustom(x,y ,width,height,scale, text, r,g,b,a)
    SetTextFont(4)
    SetTextProportional(0)
    SetTextScale(scale+.1, scale+.1)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextEdge(2, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x - width/2, y - height/2 + 0.005)
end

locksound = false

Citizen.CreateThread(function()
   while true do
       Citizen.Wait(0)      
            if IsEntityDead(PlayerPedId()) then 
			
					StartScreenEffect("DeathFailOut", 0, true)
					if not locksound then
                    PlaySoundFrontend(-1, "Bed", "WastedSounds", 1)
					locksound = true
					end
					ShakeGameplayCam("DEATH_FAIL_IN_EFFECT_SHAKE", 1.0)
					
					local scaleform = RequestScaleformMovie("MP_BIG_MESSAGE_FREEMODE")
					
					if HasScaleformMovieLoaded(scaleform) then
						Citizen.Wait(0)
						
						PushScaleformMovieFunction(scaleform, "SHOW_SHARD_WASTED_MP_MESSAGE")
						BeginTextComponent("STRING")
						AddTextComponentString("~r~you've been killed")
						EndTextComponent()
						PopScaleformMovieFunctionVoid()
						

				    Citizen.Wait(500)

					PlaySoundFrontend(-1, "TextHit", "WastedSounds", 1)
                    while IsEntityDead(PlayerPedId()) do
						
						if(reviveGood) and (not wasKnockedOut) then
							PushScaleformMovieFunction(scaleform, "SHOW_SHARD_WASTED_MP_MESSAGE")
						BeginTextComponent("STRING")
						AddTextComponentString("~g~you may /revive")
						EndTextComponent()
						PopScaleformMovieFunctionVoid()
						elseif (not reviveGood) and (not wasKnockedOut) then
							PushScaleformMovieFunction(scaleform, "SHOW_SHARD_WASTED_MP_MESSAGE")
						BeginTextComponent("STRING")
						AddTextComponentString("~r~you've been killed")
						EndTextComponent()
						PopScaleformMovieFunctionVoid()
						elseif wasKnockedOut then
							PushScaleformMovieFunction(scaleform, "SHOW_SHARD_WASTED_MP_MESSAGE")
						BeginTextComponent("STRING")
						AddTextComponentString("~r~knocked out")
						EndTextComponent()
						PopScaleformMovieFunctionVoid()
						end
						DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255)
						Citizen.Wait(0)
                     end
					 
				  StopScreenEffect("DeathFailOut")
				  locksound = false
			end
		end
    end
end)

