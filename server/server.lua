ESX = exports["es_extended"]:getSharedObject()
local stashes = {}

local function LoadStashes()
    local file = LoadResourceFile(GetCurrentResourceName(), "json/stash.json")
    if file then
        stashes = json.decode(file)
    else
        stashes = {}
    end
end

local function SaveStashes()
    SaveResourceFile(
        GetCurrentResourceName(),
        "json/stash.json",
        json.encode(stashes, { indent = true }),
        -1
    )
end

local function IsAdmin(identifier)
    for _, v in pairs(Config.Licences) do
        if v == identifier then return true end
    end
    return false
end

ESX.RegisterServerCallback("earth:getajStashove", function(_, cb)
    cb(stashes)
end)

RegisterNetEvent("jure:addCustomStash", function(name, slots, kg, accessType, accessValue, coords, heading)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    if IsAdmin(xPlayer.identifier) then
        local stashData = {
            stashName = name,
            stashSlots = tonumber(slots),
            stashKG = tonumber(kg),
            accessType = accessType,
            accessValue = accessValue,
            stashCoords = coords,
            heading = heading,
            creator = xPlayer.identifier
        }

        table.insert(stashes, stashData)
        SaveStashes()

        exports.ox_inventory:RegisterStash(
            name,
            name,
            tonumber(slots),
            tonumber(kg),
            false,
            accessType == "job" and accessValue or nil
        )

        TriggerClientEvent("jure:spawnSingleStash", -1, stashData)
    else
        DropPlayer(src, ":)")
    end
end)

RegisterCommand("createstash", function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    if IsAdmin(xPlayer.identifier) then
        TriggerClientEvent("jure:stashCreator", source)
    else
        xPlayer.showNotification("No permission")
    end
end)

AddEventHandler("onResourceStart", function(res)
    if res == GetCurrentResourceName() then
        LoadStashes()
    end
end)
