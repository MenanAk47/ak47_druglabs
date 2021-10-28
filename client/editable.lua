function isPlayerDead()
    return IsEntityDead(GetPlayerPed(-1))
end

function showNotification(text, eType, time)
	local message = text
	if eType == 'error' then
		message = '~r~'..message
	elseif eType == 'inform' then
		message = '~y~'..message
	elseif eType == 'success' then
		message = '~g~'..message
	end
	ShowNotificationDefault(message)
end

RegisterNetEvent('ak47_druglabs:showNotification')
AddEventHandler('ak47_druglabs:showNotification', function(text, eType, time)
    showNotification(text, eType, time)
end)

function ShowNotificationDefault(msg)
    SetNotificationTextEntry('STRING')
	AddTextComponentSubstringPlayerName(msg)
	DrawNotification(false, true)
end

function ShowHelpNotification(msg)
    BeginTextCommandDisplayHelp('STRING')
    AddTextComponentSubstringPlayerName(msg)
    EndTextCommandDisplayHelp(0, false, true, -1)
end