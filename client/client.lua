ESX = exports["es_extended"]:getSharedObject()
local Objects = {}

Citizen.CreateThread(function()
    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end

    PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
  PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
  PlayerData.job = job
end)

AddEventHandler("onResourceStop", function(res)
    if res == GetCurrentResourceName() then
        for _, obj in pairs(Objects) do DeleteObject(obj) end
    end
end)

local function SpawnStash(pos, heading)
    local model = `prop_box_wood05a`
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end

    local obj = CreateObject(model, pos.x, pos.y, pos.z - 1.0, false, true)
    SetEntityHeading(obj, heading)
    FreezeEntityPosition(obj, true)
    SetEntityInvincible(obj, true)
    PlaceObjectOnGroundProperly(obj)

    Objects[#Objects + 1] = obj
end

local function AddStash(v)
    SpawnStash(v.stashCoords, v.heading)

    exports.qtarget:AddBoxZone(
        "Stash-" .. v.stashName,
        vector3(v.stashCoords.x, v.stashCoords.y, v.stashCoords.z - 1),
        3.4, 3.4,
        {
            name = "Stash-" .. v.stashName,
            heading = v.heading,
            minZ = v.stashCoords.z - 2,
            maxZ = v.stashCoords.z,
        },
        {
            options = {
                {
                    icon = "fas fa-box",
                    label = "Open Stash",
                    canInteract = function()
                        if v.accessType == "job" then
                            return PlayerData.job and PlayerData.job.name == v.accessValue
                        end
                        if v.accessType == "identifier" then
                            return PlayerData.identifier == v.accessValue
                        end
                        return false
                    end,
                    action = function()
                        exports.ox_inventory:openInventory('stash', v.stashName)
                    end
                }
            },
            distance = 2.0
        }
    )
end

RegisterNetEvent('jure:stashCreator', function()
    local ped = PlayerPedId()
    local pos = GetOffsetFromEntityInWorldCoords(ped, 0.0, 1.0, 0.0)

    local input = lib.inputDialog('Create Stash', {
        {type = 'input', label = "Stash name", required = true},
        {type = 'number', label = "Slots", required = true},
        {type = 'number', label = "KG", required = true},
        {
            type = 'select',
            label = "Access type",
            options = {
                {label = "Job", value = "job"},
                {label = "Identifier", value = "identifier"}
            },
            required = true
        },
        {type = 'input', label = "Job name / Identifier", required = true},
    })

    if not input then return end

    TriggerServerEvent(
        "jure:addCustomStash",
        input[1], input[2], input[3], input[4], input[5],
        vector3(pos.x, pos.y, pos.z),
        GetEntityHeading(ped)
    )
end)

CreateThread(function()
    Wait(500)
    ESX.TriggerServerCallback("earth:getajStashove", function(stashes)
        for _, v in pairs(stashes) do
            AddStash(v)
        end
    end)
end)

RegisterNetEvent("jure:spawnSingleStash", function(v)
    AddStash(v)
end)
