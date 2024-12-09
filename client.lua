
local zoomFov = 20.0
local defaultFOV = GetGameplayCamFov() 
local zoomCam = nil
local zoomActive = false
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
    RenderScriptCams(true, true, 150, true, true)
end

local function EnableZoom()
    if zoomCam then
        SetCamFov(zoomCam, zoomFov)
        SetCamActive(zoomCam, true)
        RenderScriptCams(true, true, 150, true, true)
    else
        CreateZoomCamera()
    end
end

local function DisableZoom()
    if zoomCam then
        SetCamActive(zoomCam, false)
        RenderScriptCams(false, true, 150, true, true)
    end
end

local zoomInKeybind = lib.addKeybind({
    name = 'zoom_in',
    description = 'Zoom In',
    defaultKey = 'IOM_WHEEL_UP',
    defaultMapper = 'MOUSE_WHEEL',
    onPressed = function(self)
        if not IsPlayerFreeAiming(cache.playerId) and not blockZoom then
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
        if not IsPlayerFreeAiming(cache.playerId) and not blockZoom then
            DisableZoom()
        end
    end,
})

-- Main thread for handling zoom
CreateThread(function()
    local wait = 100
    while true do
        if zoomCam then
            local gpcCoords = GetGameplayCamCoord()
            local gpcRot = GetGameplayCamRot(2)
            SetCamCoord(zoomCam, gpcCoords.x, gpcCoords.y, gpcCoords.z)
            SetCamRot(zoomCam, gpcRot.x, gpcRot.y, gpcRot.z, 2)
            wait = 0
        else
            wait = 100
        end
        Wait(wait)
    end
end)

--
--  You will need to disable the zoom functionality in certain cases. i.e. no clip
--
RegisterNetEvent('zoom:updateBlock', function(blockUpdate)
	blockZoom = blockUpdate
    if blockUpdate and zoomCam then
        DisableZoom()
    end
end)


--[[

    Note there is only 1 level of zoom, if you want to have
    incremental zoom you may wish to apply this to the camera:

    InterpolateCamWithParams(activeCam, 
                        camPos.x, camPos.y, camPos.z, 
                        camRot.x, camRot.y, camRot.z, 
                        newFov, timeToZoom,
                        1, 1, 2, 1)

]]