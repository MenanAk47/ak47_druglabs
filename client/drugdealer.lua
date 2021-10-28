ESX = nil
local menuOpen = false
local wasOpen = false

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent(Config.SharedObjectName, function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(100)
	end
	while ESX.GetPlayerData().job.name == nil do
		Citizen.Wait(100)
	end
	ESX.PlayerData = ESX.GetPlayerData()
end)

local inDealer = false
local sleep = 1000
AddEventHandler('ak47_druglabs:startDealerInArea', function(zone)
    sleep = 0
    while inDealer do
        Citizen.Wait(0)
        local coords = GetEntityCoords(PlayerPedId())
        if GetDistanceBetweenCoords(coords, zone, true) > 20 then
            sleep = 1000
            inDealer = false
        end
    end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(sleep)
		local playerPed = PlayerPedId()
		local coords = GetEntityCoords(playerPed)
		for i = 1, #Config.DrugDealerItems, 1 do
			if GetDistanceBetweenCoords(coords, Config.DrugDealerItems[i].pos, true) < 2.0  and not menuOpen then
				if not inDealer then
					inDealer = true
					TriggerEvent('ak47_druglabs:startDealerInArea',Config.DrugDealerItems[i].pos)
				end
				ShowHelpNotification(string.format(Locales['dealer_prompt']))
				if IsControlJustReleased(0, 38) then
					OpenDrugShop(i, Config.DrugDealerItems[i].items, Config.DrugDealerItems[i].pos)
				end
			end
		end
	end
end)

function OpenDrugShop(id, items, coord)
	ESX.UI.Menu.CloseAll()
	local elements = {}
	menuOpen = true
	Citizen.CreateThread(function( ... )
		while menuOpen do
			Citizen.Wait(0)
			local playerPed = PlayerPedId()
			local coords = GetEntityCoords(playerPed)
			if GetDistanceBetweenCoords(coords, coord, true) > 2.0 then
				menuOpen = false
				ESX.UI.Menu.CloseAll()
			end
		end
	end)
	for k, v in pairs(ESX.GetPlayerData().inventory) do
		local price = Config.DrugDealerItems[id].items[v.name]
		if price and v.count > 0 then
			table.insert(elements, {
				label = ('%s - <span style="color:red;">%s</span>'):format(v.label,string.format(Locales['dealer_item'],ESX.Math.GroupDigits(price), v.count)),
				name = v.name,
				price = price,
			})
		end
	end

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'drug_shop', {
		title    = Config.DrugDealerItems[id].name,
		align    = 'top-left',
		elements = elements
	}, function(data, menu)
		ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'drug_shop_sell', {
		    title = 'How much whould you like to sell?'
        }, function(data2, menu2)
			local amount = tonumber(data2.value)
			TriggerServerEvent('ak47_druglabs:sellDrug', data.current.name, amount, data.current.price * amount)
			menu.close()
			menu2.close()
			Citizen.Wait(1000)
			OpenDrugShop(id,items)
		end,function(data2, menu2)
			menu.close()
			menu2.close()
			OpenDrugShop(id,items)
		end)
	end, function(data, menu)
		menu.close()
		menuOpen = false
	end)
end

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		if menuOpen then
			ESX.UI.Menu.CloseAll()
		end
	end
end)

function CreateBlipCircle(coords, text, color, sprite, radius, size)
	local blip = AddBlipForRadius(coords, radius)
	SetBlipHighDetail(blip, true)
	SetBlipColour(blip, color)
	SetBlipAlpha (blip, 128)
	blip = AddBlipForCoord(coords)
	SetBlipHighDetail(blip, true)
	SetBlipSprite (blip, sprite)
	SetBlipScale  (blip, size)
	SetBlipColour (blip, color)
	SetBlipAsShortRange(blip, true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString(text)
	EndTextCommandSetBlipName(blip)
end

Citizen.CreateThread(function()
	for i = 1, #Config.Blips, 1 do
		local zone = Config.Blips[i]
		CreateBlipCircle(zone.pos, zone.name, zone.color, zone.sprite, zone.radius, zone.size)
	end
end)