-- Variables for zoom settings
local zoomFov = 20.0
local defaultFOV = GetGameplayCamFov() -- Default FOV from gameplay camera
local customCam = nil -- Custom camera variable

local blockZoom = false

local function DebugCoords(coords)

    local model = 'prop_alien_egg_01'
    lib.requestModel(model)
    CreateObject(model, coords.x, coords.y, coords.z, false, false, false)

end

-- Function to create a custom camera at the player's current position
local function CreateCustomCamera()
    -- Get the player's current position and heading
    local camCoords = GetGameplayCamCoord() -- Start from where the current camera is
    local camRot = GetGameplayCamRot(2) -- Start with the current camera rotation

    -- Create the zoom camera at the player's gameplay camera position and rotation

    customCam = CreateCamWithParams(
        "DEFAULT_SCRIPTED_CAMERA",
        camCoords.x, camCoords.y, camCoords.z,
        camRot.x, camRot.y, camRot.z,
        zoomFov,
        false, 
        0      
    )

    -- Activate the custom camera
    SetCamActive(customCam, true)
    RenderScriptCams(true, true, 150, true, true)

end

-- Function to destroy the custom camera and revert to gameplay camera
local function DestroyCustomCamera()
    if customCam then
        -- Deactivate the custom camera
        SetCamActive(customCam, false)
        RenderScriptCams(false, true, 150, true, true)

        -- Destroy the custom camera
        DestroyCam(customCam, false)
        customCam = nil
    end
end

-- Main thread for handling zoom
CreateThread(function()
    while true do
        -- Check if the player is aiming a weapon
        if not IsPlayerFreeAiming(PlayerId()) then
            -- Detect scroll wheel up (zoom in)
            if not blockZoom and IsControlJustPressed(0, 241) then -- INPUT_CELLPHONE_UP (scroll wheel up)
                if not customCam then
                    CreateCustomCamera()
                end
            end

            -- Detect scroll wheel down (zoom out)
            if not blockZoom and IsControlJustPressed(0, 242) then -- INPUT_CELLPHONE_DOWN (scroll wheel down)

                -- Create the custom camera if not already active
                if customCam then
                    DestroyCustomCamera()
                end

            end

            -- Dynamically update the custom camera position to follow the player
            if customCam then
                local gpcCoords = GetGameplayCamCoord()
                local camRot = GetGameplayCamRot(2)

                -- Set the camera position slightly above the player's current position
                SetCamCoord(customCam, gpcCoords.x, gpcCoords.y, gpcCoords.z)
                SetCamRot(customCam, camRot.x, camRot.y, camRot.z, 2)
            end

        else
            -- Reset the FOV and destroy the custom camera when aiming
            if customCam then
                DestroyCustomCamera()
            end
        end

        Wait(0) -- Wait for the next frame
    end
end)

RegisterNetEvent('zoom:updateBlock', function(blockUpdate)
	blockZoom = blockUpdate
    if blockUpdate and customCam then
        DestroyCustomCamera()
    end
end)
