
local zoomFov = 20.0
local defaultFOV = GetGameplayCamFov() 
local zoomCam = nil
local transitionTime = 150 -- The longer the transition time the more the camera will 'lag behind' when perpendicular to the player
local zoomActive = false
local zoomInProgress = false -- Not necessary to wait for zoom in / out to finish but may result in unfavourable results if spammed too quickly
local blockZoom = false

local function CreateZoomCamera()
    local gpcCoords = GetGameplayCamCoord() 
    local gpcRot = GetGameplayCamRot(2)
    zoomCam = CreateCamWithParams(
        "DEFAULT_SCRIPTED_CAMERA",
        gpcCoords.x, gpcCoords.y, gpcCoords.z,
        gpcRot.x, gpcRot.y, gpcRot.z,
        zoomFov,
        true, 
        2      
    )
    RenderScriptCams(true, true, transitionTime, true, true)
end

local function EnableZoom()
    zoomActive = true
    if zoomCam then
        SetCamFov(zoomCam, zoomFov)
        SetCamActive(zoomCam, true)
        RenderScriptCams(true, true, transitionTime, true, true)
        zoomInProgress = true
        Wait(transitionTime)
        zoomInProgress = false
    else
        CreateZoomCamera()
    end
end

local function DisableZoom()
    zoomActive = false
    if zoomCam then
        SetCamActive(zoomCam, false)
        RenderScriptCams(false, true, transitionTime, true, true)
        zoomInProgress = true
        Wait(transitionTime)
        zoomInProgress = false
    end
end

local zoomInKeybind = lib.addKeybind({
    name = 'zoom_in',
    description = 'Zoom In',
    defaultKey = 'IOM_WHEEL_UP',
    defaultMapper = 'MOUSE_WHEEL',
    onPressed = function(self)
        if not IsPlayerFreeAiming(cache.playerId) and not blockZoom and not zoomInProgress then
            EnableZoom()
        end
    end,
})

local zoomOutKeybind = lib.addKeybind({
    name = 'zoom_out',
    description = 'Zoom Out',
    defaultKey = 'IOM_WHEEL_DOWN',
    defaultMapper = 'MOUSE_WHEEL',
    onPressed = function(self)
        if not IsPlayerFreeAiming(cache.playerId) and not blockZoom and not zoomInProgress then
            DisableZoom()
        end
    end,
})

CreateThread(function()
    local wait = 100
    while true do

        if zoomCam then
            local gpcCoords = GetGameplayCamCoord()
            local gpcRot = GetGameplayCamRot(2)
            SetCamCoord(zoomCam, gpcCoords.x, gpcCoords.y, gpcCoords.z)
            SetCamRot(zoomCam, gpcRot.x, gpcRot.y, gpcRot.z, 2)
        end

        if IsPlayerFreeAiming(cache.playerId) and zoomActive then
            DisableZoom()
        end

        if zoomActive then
            wait = 0
        else
            wait = 100
        end
        
        Wait(wait)
    end
end)

--
--  You will need to disable the zoom functionality in certain cases. i.e. no clip
--  An export would be better but meh good enough for now
--
RegisterNetEvent('zoom:updateBlock', function(blockUpdate)
	blockZoom = blockUpdate
    if blockUpdate and zoomCam then
        DisableZoom()
    end
end)


--[[

    Note there is only 1 level of zoom, if you want to have
    incremental zoom you may wish to apply this to the camera
    for each increment of zoom level:

    InterpolateCamWithParams(activeCam, 
                        camPos.x, camPos.y, camPos.z, 
                        camRot.x, camRot.y, camRot.z, 
                        newFov, timeToZoom,
                        1, 1, 2, 1)

]]