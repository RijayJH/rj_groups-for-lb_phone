local identifier = "rj_groups"

local QBCore = exports['qb-core']:GetCoreObject()
local GroupStage

local FinishedNotify

CreateThread(function ()
    while GetResourceState("lb-phone") ~= "started" do
        Wait(500)
    end

    local function AddApp()
        local added, errorMessage = exports["lb-phone"]:AddCustomApp({
            identifier = identifier,
            name = "Groups",
            description = "Groups App for Users to do stuff together",
            developer = "RijayJH",
            defaultApp = true, -- OPTIONAL if set to true, app should be added without having to download it,
            -- price = 0, -- OPTIONAL, Make players pay with in-game money to download the app
            images = {"https://example.com/photo.jpg"}, -- OPTIONAL array of images for the app on the app store
            ui = GetCurrentResourceName() .. "/ui/index.html", -- this is the path to the HTML file, can also be a URL
            icon = "https://cfx-nui-" .. GetCurrentResourceName() .. "/ui/assets/icon.png"
        })

        if not added then
            print("Could not add app:", errorMessage)
        end
    end

    AddApp()

    AddEventHandler("onResourceStart", function(resource)
        if resource == "lb-phone" or resource == GetCurrentResourceName() then
            AddApp()
        end
    end)
end)

local inJob = false
local GroupBlips = {}

local function FindBlipByName(name)
    for i=1, #GroupBlips do
        if GroupBlips[i] and GroupBlips[i].name == name then
            return i
        end
    end
end

RegisterNetEvent("groups:removeBlip", function(name)
    local i = FindBlipByName(name)
    if i then
        local blip = GroupBlips[i]["blip"]
        SetBlipRoute(blip, false)
        RemoveBlip(blip)
        GroupBlips[i] = nil
    end
end)

local function PhoneNotification(title, description, accept, deny)
    exports["lb-phone"]:SendCustomAppMessage(identifier, {
        action = "PhoneNotification",
        PhoneNotify = {
            title = title,
            text = description,
            accept = accept,
            deny = deny,
        },
    })
    FinishedNotify = nil
    local timeout = 500
    while not FinishedNotify and timeout > 0 do
        Wait(100)
        timeout -= 1
    end
    if not FinishedNotify then return false end
    return FinishedNotify == 'success' or false
end

RegisterNetEvent("groups:createBlip", function(name, data)
    if not data then return print("Invalid Data was passed to the create blip event") end

    if FindBlipByName(name) then
        TriggerEvent("groups:removeBlip", name)
    end

    local blip
    if data.entity then
        blip = AddBlipForEntity(data.entity)
    elseif data.netId then
        blip = AddBlipForEntity(NetworkGetEntityFromNetworkId(data.netId))
    elseif data.radius then
        blip = AddBlipForRadius(data.coords.x, data.coords.y, data.coords.z, data.radius)
    else
        blip = AddBlipForCoord(data.coords)
    end

    if not data.color then data.color = 1 end
    if not data.alpha then data.alpha = 255 end

    if not data.radius then
        if not data.sprite then data.sprite = 1 end
        if not data.scale then data.scale = 0.7 end
        if not data.label then data.label = "NO LABEL FOUND" end

        SetBlipSprite(blip, data.sprite)
        SetBlipScale(blip, data.scale)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName(data.label)
        EndTextCommandSetBlipName(blip)
    end

    SetBlipColour(blip, data.color)
    SetBlipAlpha(blip, data.alpha)

    if data.route then
        SetBlipRoute(blip, true)
        SetBlipRouteColour(blip, data.routeColor)
    end
    GroupBlips[#GroupBlips+1] = {name = name, blip = blip}
end)

RegisterNUICallback('GetGroupsApp', function (_, cb)
    QBCore.Functions.TriggerCallback('rj_groups:server:getAllGroups', function (getGroups)
        cb(getGroups)
    end)
end)

RegisterNetEvent('rj_groups:client:RefreshGroupsApp', function(Groups, finish)
    if finish then inJob = false end
    if inJob then return end
    exports["lb-phone"]:SendCustomAppMessage(identifier, {
        action = "refreshApp",
        data = Groups,
    })
end)


RegisterNetEvent('rj_groups:client:AddGroupStage', function(status, stage)
    inJob = true
    GroupStage = stage
    exports["lb-phone"]:SendCustomAppMessage(identifier, {
        action = "addGroupStage",
        status =  stage
    })
end)


RegisterNUICallback('jobcenter_CreateJobGroup', function(data, cb) --employment
    TriggerServerEvent('rj_groups:server:jobcenter_CreateJobGroup', data)
    cb("ok")
end)

RegisterNUICallback('AnswerdNotify', function(data, cb) --employment
    FinishedNotify = data.type
    cb("ok")
end)

RegisterNUICallback('onStartup', function(data, cb)
    exports["lb-phone"]:SendCustomAppMessage(identifier, {
        action = "LoadPhoneData",
        PlayerData = QBCore.Functions.GetPlayerData(),
    })
    if not inJob then
        exports["lb-phone"]:SendCustomAppMessage(identifier, {
            action = "LoadJobCenterApp",
        })
    else
        exports["lb-phone"]:SendCustomAppMessage(identifier, {
            action = "addGroupStage",
            status =  GroupStage
        })
    end
    cb("ok")
end)

RegisterNUICallback('jobcenter_JoinTheGroup', function(data, cb) --employment
    TriggerServerEvent('rj_groups:server:jobcenter_JoinTheGroup', data)
    cb("ok")
end)

RegisterNetEvent('rj_groups:client:CustomNotification', function(header, msg)
    exports["lb-phone"]:SendNotification({
        app = identifier, -- the app to send the notification to (optional)
        title = header, -- the title of the notification
        content = msg, -- the description of the notification
    })
end)

RegisterNUICallback('jobcenter_leave_grouped', function(data, cb) --employment
    if not data then return end
    local success = PhoneNotification("Job Center", 'Are you sure you want to leave the group?', 'Accept', 'Deny')
    if success then
        TriggerServerEvent('rj_groups:server:jobcenter_leave_grouped', data)
    end
    cb("ok")
end)

RegisterNUICallback('jobcenter_DeleteGroup', function(data, cb) --employment
    TriggerServerEvent('rj_groups:server:jobcenter_DeleteGroup', data)
    cb("ok")
end)


RegisterNUICallback('jobcenter_CheckPlayerNames', function(data, cb) --employment
    QBCore.Functions.TriggerCallback('rj_groups:server:jobcenter_CheckPlayerNames', function(HasName)
        cb(HasName)
    end, data.id)
end)

RegisterCommand('testpass', function()
    exports["lb-phone"]:SendCustomAppMessage(identifier, {
        action = "testPassword"
    })
end, false)
