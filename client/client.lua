ESX = exports["es_extended"]:getSharedObject()
DoScreenFadeIn(100)

local CameraProp = {}
local CountCamera = 0
local UsingPanel = false
local PlacingCamera = false

local PropTablet = nil
local AnimationTabletDict = "amb@code_human_in_bus_passenger_idles@female@tablet@base"
local PropTabletModel = `prop_cs_tablet`
local TabletOffSetProp = vector3(0.03, 0.002, -0.0)
local TabletRotProp = vector3(10.0, 160.0, 0.0)

RegisterCommand("putcamera", function(source, args, rawCommand)
    if not PlacingCamera then
        ESX.TriggerServerCallback('kim-camera:checkinventoryitem',function(hasItem)
            if hasItem then
                TriggerEvent("kim-camera:client:PlaceCamera")
            else
                ESX.ShowNotification(Locale('NoCameraItem'))
            end
        end)
    else
        ESX.ShowNotification(Locale('CannotPlace'))
    end
end)

RegisterCommand("accespanel", function(source, args, rawCommand)
    a, ListCameras = ipairs(CameraProp)

    if json.encode(ListCameras) == "[]" then
        ESX.ShowNotification(Locale("NoCamera"))
    else
        if not PlacingCamera then 
            if #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(CameraProp[1])) < Config.DistanceToConnect then
                GoPanelCamera()
            else
                ESX.ShowNotification(Locale("NotClose"))
            end
        else
            ESX.ShowNotification(Locale("NotWhilePlacing"))
        end
    end
end)

function AnimTablet()
    
    Citizen.CreateThread(function()
        RequestAnimDict(AnimationTabletDict)

        while not HasAnimDictLoaded(AnimationTabletDict) do
            Citizen.Wait(150)
        end

        RequestModel(PropTabletModel)

        while not HasModelLoaded(PropTabletModel) do
            Citizen.Wait(150)
        end

        local playerPed = PlayerPedId()
        PropTablet = CreateObject(PropTabletModel, 0.0, 0.0, 0.0, true, true, false)
        local tabletBoneIndex = GetPedBoneIndex(playerPed, 60309)

        SetCurrentPedWeapon(playerPed, 'weapon_unarmed', true)
        AttachEntityToEntity(PropTablet, playerPed, tabletBoneIndex, TabletOffSetProp.x, TabletOffSetProp.y, TabletOffSetProp.z, TabletRotProp.x, TabletRotProp.y, TabletRotProp.z, true, false, false, false, 2, true)
        SetModelAsNoLongerNeeded(PropTabletModel)
        
        form = setupScaleform("instructional_buttons")

        Citizen.CreateThread(function()
            while UsingPanel do
                DrawScaleformMovieFullscreen(form, 255, 255, 255, 255, 0)
                Citizen.Wait(1)
            end
        end)

        while UsingPanel do
            if not IsEntityPlayingAnim(playerPed, AnimationTabletDict, "base", 3) then
                FreezeEntityPosition(PlayerPedId(), true)
                TaskPlayAnim(playerPed, AnimationTabletDict, "base", 3.0, 3.0, -1, 49, 0, 0, 0, 0)
            end
            Citizen.Wait(150)
        end
    end)
end

function MakeInvProp()
    Citizen.CreateThread(function()
        while UsingPanel do
            SetEntityLocallyInvisible(CameraProp[ActualCamera])
            Citizen.Wait(1)
        end
    end)
end

function GoPanelCamera()
    UsingPanel = true
    AnimTablet()
    Citizen.Wait(2000)

    NumberCameras = 0
    ActualCamera = 1

    for i,Cameras in ipairs(CameraProp) do
        NumberCameras = NumberCameras + 1
    end
    local CoordsCameraVirtual = GetEntityCoords(CameraProp[1])

    local CamTemporal = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", CoordsCameraVirtual.x, CoordsCameraVirtual.y, CoordsCameraVirtual.z - 0.3 , 0, 0.0, GetEntityHeading(CameraProp[ActualCamera]) - 180, 90.0)
    
    DoScreenFadeOut(500)
    Citizen.Wait(500)

    SetTimecycleModifier("scanline_cam_cheap")
    SetTimecycleModifierStrength(2.5)

    SetCamActive(CamTemporal, true)
    RenderScriptCams(true, false, 100, true, false)
    MakeInvProp()

    Citizen.Wait(500)
    DoScreenFadeIn(500)

    Citizen.CreateThread(function()
        while true do
            if IsControlJustPressed(0, 35) then

                if ActualCamera < NumberCameras then
                    if #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(CameraProp[ActualCamera + 1])) < Config.DistanceToConnect then
                        ActualCamera = ActualCamera + 1

                        DoScreenFadeOut(500)
                        Citizen.Wait(500)

                        CoordsCameraVirtual = GetEntityCoords(CameraProp[ActualCamera])
                        SetCamCoord(CamTemporal, CoordsCameraVirtual + vector3(0.0, 0.0, -0.3))
                        SetCamRot(CamTemporal, 0.0, 0.0, GetEntityHeading(CameraProp[ActualCamera]) - 180)

                        Citizen.Wait(200)
                        DoScreenFadeIn(500)
                    else
                        ESX.ShowNotification(Locale("NotClose"))
                    end
                else
                    ESX.ShowNotification(Locale("NoCamerasMore"))
                end

            end
            if IsControlJustPressed(0, 34) then

                if ActualCamera > 1 then
                    if #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(CameraProp[ActualCamera - 1])) < Config.DistanceToConnect then
                    ActualCamera = ActualCamera - 1
                    
                    DoScreenFadeOut(500)
                    Citizen.Wait(500)

                    CoordsCameraVirtual = GetEntityCoords(CameraProp[ActualCamera])
                    SetCamCoord(CamTemporal, CoordsCameraVirtual + vector3(0.0, 0.0, -0.3))
                    SetCamRot(CamTemporal, 0.0, 0.0, GetEntityHeading(CameraProp[ActualCamera]) - 180, 1)

                    Citizen.Wait(200)
                    DoScreenFadeIn(500)
                    else
                        ESX.ShowNotification(Locale("NotClose"))
                    end
                else
                    ESX.ShowNotification(Locale("NoCamerasMore"))
                end
            end

            if IsControlJustPressed(0, 174) then
                local RotationCamera = GetCamRot(CamTemporal)
                SetCamRot(CamTemporal, RotationCamera.x, RotationCamera.y, RotationCamera.z + 10)
                SetEntityHeading(CameraProp[ActualCamera], GetEntityHeading(CameraProp[ActualCamera]) + 10)
            end

            if IsControlJustPressed(0, 175) then
                local RotationCamera = GetCamRot(CamTemporal)
                SetCamRot(CamTemporal, RotationCamera.x, RotationCamera.y, RotationCamera.z - 10)
                SetEntityHeading(CameraProp[ActualCamera], GetEntityHeading(CameraProp[ActualCamera]) - 10)
            end

            if IsControlJustPressed(0, 173) then
                local RotationCamera = GetCamRot(CamTemporal)

                if RotationCamera.x > -30 then
                    SetCamRot(CamTemporal, RotationCamera.x - 10, RotationCamera.y, RotationCamera.z)
                end
            end

            if IsControlJustPressed(0, 172) then
                local RotationCamera = GetCamRot(CamTemporal)

                if RotationCamera.x < 30 then
                    SetCamRot(CamTemporal, RotationCamera.x + 10, RotationCamera.y, RotationCamera.z)
                end
            end

            if IsControlJustPressed(1, 194) then
                ExitMenuCamera()
                break
            end

            if IsControlJustPressed(1, 48) then
                if GetCamFov(CamTemporal) > 50 then 
                    SetCamFov(CamTemporal, GetCamFov(CamTemporal) - 5.0)
                end
            end

            if IsControlJustPressed(1, 73) then
                if GetCamFov(CamTemporal) < 100 then 
                    SetCamFov(CamTemporal, GetCamFov(CamTemporal) + 5.0)
                end
            end

            Citizen.Wait(5)
        end
    end)
end

function ExitMenuCamera()
    DoScreenFadeOut(500)
    Citizen.Wait(500)

    UsingPanel = false
    DetachEntity(PropTablet, true, false)
    DeleteEntity(PropTablet)
    FreezeEntityPosition(PlayerPedId(), false)
    ClearPedSecondaryTask(PlayerPedId())

    ClearTimecycleModifier("scanline_cam_cheap")
    DestroyCam(CamTemporal)
    RenderScriptCams(0, 0, 1, 1, 1)

    Citizen.Wait(500)
    DoScreenFadeIn(500)
end

AddEventHandler("kim-camera:client:PlaceCamera", function()
        PlacingCamera = true
        CountCamera = CountCamera + 1
        CameraProp[CountCamera] = CreateObject(GetHashKey("prop_cctv_cam_06a"), 0, 0, 0, true, true, true)

        Citizen.CreateThread(function()
            while true do
                ESX.ShowHelpNotification(Locale("PlaceCamera"))
                PlayerCoords = GetEntityCoords(PlayerPedId())
                a, CoordsCamera, c = RayCastGamePlayCamera(7)
                SetEntityCoords(CameraProp[CountCamera], CoordsCamera + vector3(0, 0.5, 0))

                if GetEntityCoords(CameraProp[CountCamera]) == vector3(0, 0.5, 0) then
                    if IsControlJustPressed(0, 38) then
                        ESX.ShowNotification(Locale("InvalidTerrain"))
                    end
                else
                    DrawLine(CoordsCamera.x, CoordsCamera.y + 0.5, CoordsCamera.z - 0.3, PlayerCoords.x, PlayerCoords.y, PlayerCoords.z, 255, 255, 255, 255)
                    if IsControlJustPressed(0, 174) then
                        SetEntityRotation(CameraProp[CountCamera], 0, 0, GetEntityHeading(CameraProp[CountCamera]) + 10, 2, true)
                    end
        
                    if IsControlJustPressed(0, 175) then
                        SetEntityRotation(CameraProp[CountCamera], 0, 0, GetEntityHeading(CameraProp[CountCamera]) - 10, 2, true)
                    end
        
                    if IsControlJustPressed(0, 38) then
                        PlacingCamera = false
                        ESX.ShowNotification(Locale('PlaceCameraSuccesfuly'))
                        break
                    end
                end

                Citizen.Wait(3)
            end
        end)
end)

-- Functions --

function RayCastGamePlayCamera(distance)
    local cameraRotation = GetGameplayCamRot()
    local cameraCoord = GetGameplayCamCoord()
    local direction = RotationToDirection(cameraRotation)
    local destination =
    {
        x = cameraCoord.x + direction.x * distance,
        y = cameraCoord.y + direction.y * distance,
        z = cameraCoord.z + direction.z * distance
    }
    local a, b, c, d, e = GetShapeTestResult(StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x, destination.y, destination.z, -1, PlayerPedId(), 0))
    return b, c, e
end

function RotationToDirection(rotation)
    local adjustedRotation = 
    { 
        x = (math.pi / 180) * rotation.x, 
        y = (math.pi / 180) * rotation.y, 
        z = (math.pi / 180) * rotation.z 
    }
    local direction = 
    {
        x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)), 
        y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)), 
        z = math.sin(adjustedRotation.x)
    }
    return direction
end

function RayCastPed(pos,distance,ped)
    local cameraRotation = GetGameplayCamRot()
    local direction = RotationToDirection(cameraRotation)
    local destination = 
    { 
        x = pos.x + direction.x * distance, 
        y = pos.y + direction.y * distance, 
        z = pos.z + direction.z * distance 
    }

    local a, b, c, d, e = GetShapeTestResult(StartShapeTestRay(pos.x, pos.y, pos.z, destination.x, destination.y, destination.z, -1, ped, 1))
    return b, c
end

function ButtonMessage(text)
    BeginTextCommandScaleformString("STRING")
    AddTextComponentScaleform(text)
    EndTextCommandScaleformString()
end

function Button(ControlButton)
    N_0xe83a3e3557a56640(ControlButton)
end

function setupScaleform(scaleform)
    local scaleform = RequestScaleformMovie(scaleform)
    while not HasScaleformMovieLoaded(scaleform) do
        Citizen.Wait(0)
    end

    -- draw it once to set up layout
    --DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 0, 0)

    PushScaleformMovieFunction(scaleform, "CLEAR_ALL")
    PopScaleformMovieFunctionVoid()
    
    PushScaleformMovieFunction(scaleform, "SET_CLEAR_SPACE")
    PushScaleformMovieFunctionParameterInt(200)
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(0)
    Button(GetControlInstructionalButton(2, 194, true)) -- The button to display
    ButtonMessage(Locale("ExitPanel")) -- the message to display next to it
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(1)
    Button(GetControlInstructionalButton(2, 35, true))
    ButtonMessage(Locale("NextCamera"))
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(2)
    Button(GetControlInstructionalButton(2, 34, true))
    ButtonMessage(Locale("PreviusCamera"))
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(3)
    Button(GetControlInstructionalButton(2, 173, true))
    ButtonMessage(Locale("Down"))
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(4)
    Button(GetControlInstructionalButton(2, 172, true))
    ButtonMessage(Locale("Up"))
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(5)
    Button(GetControlInstructionalButton(2, 174, true))
    ButtonMessage(Locale("Left"))
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(6)
    Button(GetControlInstructionalButton(2, 175, true))
    ButtonMessage(Locale("Right"))
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(7)
    Button(GetControlInstructionalButton(2, 48, true))
    ButtonMessage(Locale("Zoom"))
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(8)
    Button(GetControlInstructionalButton(2, 105, true))
    ButtonMessage(Locale("NoZoom"))
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
    PopScaleformMovieFunctionVoid()

    PushScaleformMovieFunction(scaleform, "SET_BACKGROUND_COLOUR")
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(80)
    PopScaleformMovieFunctionVoid()

    return scaleform
end

RegisterKeyMapping('putcamera', 'Place camera button', 'keyboard', 'u')
RegisterKeyMapping('accespanel', 'Enter the panel cameras', 'keyboard', 'i')
print("¡Script started succsefully! Made By: kim")

AddEventHandler('onResourceStop', function(resourceName)    
    FreezeEntityPosition(PlayerPedId(), false)
    ClearTimecycleModifier("scanline_cam_cheap")
    for i,Prop in ipairs(CameraProp) do
        DeleteEntity(Prop)
    end
end)