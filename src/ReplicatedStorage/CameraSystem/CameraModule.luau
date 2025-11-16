--[[
    Note: cameraModule.createStateWithName is an alternative to cameraModule.createStateWithPointer
    Both methods provide the same functionality, offering flexibility in coding style

    Examples:
    -- Quick access by name
    local state = cameraModule.createStateWithName("Explosion", "Effect1")

    -- Explicit module reference
    local state = cameraModule.createStateWithPointer(ReplicatedStorage.CameraSystem.States.Explosion, "Effect1")

    -- Useful for working with state collections or loops:
    for stateName, stateModule in pairs(STATES) do
        cameraModule.createStateWithPointer(stateModule, stateName)
    end
]]

local CameraModule = {}

local Folder = script.Parent
local stateModules = Folder.States
local BaseCameraStateModule = require(Folder.BaseCameraState)

export type BaseState = typeof(BaseCameraStateModule.new())
local activeStates : {BaseState} = {}

function CameraModule.getActiveState(stateId : string)
    if activeStates[stateId] then
        return activeStates[stateId]
    end
end

function CameraModule.safeSwitchState(stateId : string, value : boolean) : nil
    local target = activeStates[stateId]
    if not target then
        return warn(`There is no '{stateId}' stateId`)
    end

    if target.isActive == value then
        return
    end

    if value then
        target:activate()
    else
        target:deactivate()
    end
end

function CameraModule.purgeState(stateId : string) : nil
    local target = activeStates[stateId]
    if not target then
        warn(`There is no '{stateId}' stateId`)
        return
    end

    target:purge()
end

function CameraModule.forceStateParams(stateId : string, params : {[any] : any})
    for i, v in pairs(params) do
        activeStates[stateId][i] = v
    end
end

local function initState(module : BaseState, forceId : string)
    local MODULE : BaseState = module.new()
    activeStates[forceId] = MODULE
    MODULE.onSelfPurge = function()
        MODULE:purge()
        activeStates[forceId] = nil
    end

    return MODULE
end

function CameraModule.createStateWithName(stateName : string, forceId : string?) : BaseState
    if not forceId then forceId = stateName end

    if activeStates[forceId] then
        warn(`State '{stateName}'({forceId}) already inited`)
        return
    end

    if not stateModules:FindFirstChild(stateName) then
        warn(`StateModule '{stateName}' doesn't exists`)
        return
    end

    return initState(require(stateModules[stateName]), forceId)
end

function CameraModule.createStateWithPointer(moduleScript : ModuleScript, forceId : string?)
    if not moduleScript then
        warn(`There is no moduleScript -> {forceId}`)
        return
    end

    if not forceId then forceId = moduleScript.Name end

    if activeStates[forceId] then
        warn(`State '{forceId}' already inited`)
        return
    end

    return initState(require(moduleScript), forceId)
end

function CameraModule.init()
    game:GetService("RunService").RenderStepped:Connect(function(deltaTime)
        deltaTime = math.min(deltaTime, 1)

        for _, v in pairs(activeStates) do
            v.onRenderStepped(deltaTime)
        end
    end)
end

return CameraModule