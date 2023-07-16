local megaphoneRange = 30.0 -- Adjust this value to change the range of the raycast
local isStopped = false -- Variable to track the stop state

function IsPlayerInEmergencyVehicle()
    local playerPed = GetPlayerPed(-1)
    local playerVehicle = GetVehiclePedIsIn(playerPed, false)
    local vehicleClass = GetVehicleClass(playerVehicle)
    
    return IsPedInAnyVehicle(playerPed) and (vehicleClass == 18 or vehicleClass == 19 or vehicleClass == 20)
end

function StopPedsInFrontOfVehicle()
    local playerPed = GetPlayerPed(-1)
    local playerVehicle = GetVehiclePedIsIn(playerPed, false)
    
    if IsPlayerInEmergencyVehicle() then
        local coords = GetEntityCoords(playerVehicle)
        local forwardVector = GetEntityForwardVector(playerVehicle)
		local rayStart = coords + forwardVector * 1.0
		local rayEnd = coords + forwardVector * 20.0 -- Adjust the value (e.g., 20.0) to extend the range


        local rayhandle = StartShapeTestRay(rayStart.x, rayStart.y, rayStart.z, rayEnd.x, rayEnd.y, rayEnd.z, 10, playerVehicle, 0)
        local _, hit, _, _, entityHit = GetShapeTestResult(rayhandle)

        if hit and IsEntityAPed(entityHit) then
            if isStopped then
                ClearPedTasks(entityHit)
                SetEntityAsNoLongerNeeded(entityHit)
                TaskClearLookAt(entityHit)
                TriggerEvent("chatMessage", "^2Pedestrians resumed.")
            else
                SetBlockingOfNonTemporaryEvents(entityHit, true)
                TaskTurnPedToFaceCoord(entityHit, GetEntityCoords(playerPed), -1)
                TaskStandStill(entityHit, -1)
                TaskLookAtEntity(entityHit, playerPed, -1, 0, 2)
                TriggerEvent("chatMessage", "^1Pedestrians stopped.")
				TriggerEvent('InteractSound_CL:PlayOnOne', 'stopped', 10.0)
				TriggerServerEvent('InteractSound_SV:PlayWithinDistance', 0.5, 'stopped', 10.0)
            end
            isStopped = not isStopped
        end
    end
end

RegisterCommand("stop", function(source, args, rawCommand)
    StopPedsInFrontOfVehicle()
end)

RegisterKeyMapping('stop', 'Toggle Stop Pedestrians', 'keyboard', 'L')

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        
        if IsControlJustReleased(0, 74) then -- Keybind for "L" (Stop)
            StopPedsInFrontOfVehicle()
        end
    end
end)
