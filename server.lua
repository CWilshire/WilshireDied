--[[
Made by C. Wilshire#5885 for use on fivem server discord.gg/BrmN6EA
Use/modification is permitted with proper credit.
Credits for project are found in README.md
]]
AddEventHandler('chatMessage', function(from,name,message)
	if(message:sub(1,1) == "/") then

		local args = stringsplit(message, " ")
		local cmd = args[1]


		if (cmd == "/reviveself") then
			CancelEvent()
			TriggerClientEvent('chatMessage', from, "WILSHDIED", {200,0,0} , "This command was removed. Please use /revive once the timer is up.")
		end
		
		if (cmd == "/staffrevive") then
			CancelEvent()
			TriggerClientEvent('wd:staffrevive', from)
		end
		
		if (cmd == "/respawn") then
			CancelEvent()
			TriggerClientEvent('chatMessage', from, "WILSHDIED", {200,0,0} , "This command was removed. Please use /revive once the timer is up.")
		end
		if (cmd == "/adminrevive") then
			CancelEvent()
			TriggerClientEvent('chatMessage', from, "WILSHDIED", {200,0,0} , "This command was removed. Please use /staffrevive. This command removes effects from being knocked out. ^1DO NOT USE UNLESS YOU'RE STAFF, OTHERWISE YOU WILL BE PERMANENTLY BANNED. This command is logged and displayed.")
		end
		
		if (cmd == "/cpr") then
			CancelEvent()
			TriggerClientEvent('chatMessage', from, "WILSHDIED", {200,0,0} , "This command was removed. Please use /revive <ID> to revive the other player. ^1DO NOT ABUSE OR YOU WILL BE PERMANENTLY BANNED. This command is logged and displayed.")
		end
		
		if (cmd == "/adminselfrevive") then
			CancelEvent()
			TriggerClientEvent('chatMessage', from, "WILSHDIED", {200,0,0} , "This command was removed. Please use /staffrevive. This command removes effects from being knocked out. ^1DO NOT USE UNLESS YOU'RE STAFF, OTHERWISE YOU WILL BE PERMANENTLY BANNED. This command is logged and displayed.")
		end

		
		if (cmd == "/reviveall") then
			CancelEvent()
			if IsPlayerAceAllowed(from, "wd.reviveall") then
				TriggerClientEvent('chatMessage', -1 , "WILSHDIED STAFF", {200,0,0} , GetPlayerName(from) .. " has just revived the whole server.")
				TriggerClientEvent('wd:allowRevive', -1)
			else 
				TriggerClientEvent('chatMessage', from, "WILSHDIED STAFF", {200,0,0} , "You cannot use this command.")
			end
		end
	
		if (cmd == "/revive") then
			CancelEvent()

			if (args[2] ~= nil) then
				
				local playerID = tonumber(args[2])

				if(playerID == nil or playerID == 0 or GetPlayerName(playerID) == nil) then
					TriggerClientEvent('chatMessage', from, "WILSHDIED", {200,0,0} , "Invalid PlayerID")
					return
				end
				
				TriggerClientEvent('wd:allowRevive', playerID, from)
				if from ~= playerID then
				TriggerClientEvent('chatMessage', -1, "WILSHDIED", {200,0,0} , GetPlayerName(from) .. " got " .. GetPlayerName(playerID) .. " up from the ground.")
				TriggerClientEvent('chatMessage', from, "WILSHDIED", {200,0,0} , "^1/revive <ID> is logged and displayed. Abuse will result result in a permanent ban.")
				end
				
			else
				TriggerClientEvent('wd:allowRevive', from, from)
			end
		end

	end
end)

RegisterServerEvent('messageveryonexd')
AddEventHandler('messageveryonexd', function()
    local Source = source
    TriggerClientEvent('chatMessage', -1, '', {255, 255, 255}, '^8WILSHDIED^7 ' .. GetPlayerName(Source) .. ' just used the staff revive command')
end)

RegisterServerEvent('reviveallserver')
AddEventHandler('reviveallserver', function(id)
	TriggerClientEvent('wd:reviveall',id)
end)

-- String splits by the separator.
function stringsplit(inputstr, sep)
    if sep == nil then
            sep = "%s"
    end
    local t={} ; i=1
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            t[i] = str
            i = i + 1
    end
    return t
end



RegisterCommand("consolerevall", function(source, args, rawCommand)
	if source == 0 then

		TriggerClientEvent('chatMessage', -1 , "WILSHDIED STAFF", {200,0,0} , "Console has just revived the whole server.")
		TriggerClientEvent('wd:allowRevive',-1)
		
	else
		TriggerClientEvent('chatMessage', source , "WILSHDIED STAFF", {200,0,0} , "You are not console!")
	end
end)


