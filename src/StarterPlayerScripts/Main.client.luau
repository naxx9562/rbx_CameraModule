local repl = game:GetService("ReplicatedStorage")
local cameraModule = require(repl.CameraSystem.CameraModule) cameraModule.init()

local player = game:GetService("Players").LocalPlayer
local swapStates : {cameraModule.BaseState} = {
    moveState = cameraModule.createStateWithName("Move"),
    idleState = cameraModule.createStateWithName("Idle")
}

local stdParams = {
    ["SmallExplosion"] = {
        ["Strength"] = 5,
        ["RollStrength"] = 2,
        ["RegenSpeed"] = 8,
        ["DirectionSwapSpeed"] = 30
    },

    ["HugeExplosion"] = {
        ["Strength"] = 10,
        ["RollStrength"] = 4,
        ["RegenSpeed"] = 4,
        ["DirectionSwapSpeed"] = 30
    },

    ["Walking"] = {
        ["Amplitude"] = 1
    },

    ["Running"] = { -- example only!!!
        ["Amplitude"] = 1.3
    }
}

--binding
local lastBinds : {RBXScriptConnection} = {}
local function moveStateLogic(WalkSpeed)
    if WalkSpeed > 20 then
        return stdParams.Running
    end
    return stdParams.Walking
end

local function bindChar(char) -- Passive example: State machine
    local humanoid : Humanoid = char:WaitForChild("Humanoid")
    local root : Part = char:WaitForChild("HumanoidRootPart")

    if lastBinds.RunService then
        lastBinds.RunService:Disconnect()
        lastBinds.Humanoid:Disconnect()
    end
    --[[
        Note:
        There's no explicit binding specifically to Humanoid / RunService.
        Feel free to use other binds.
    ]]

    lastBinds.RunService = game:GetService("RunService").RenderStepped:Connect(function(deltaTime)
        if humanoid.Health <= 0 then
            cameraModule.safeSwitchState("Move", false)
            cameraModule.safeSwitchState("Idle", false)
        end
        
        local rootVelocity = root.AssemblyLinearVelocity
        local isStanding = humanoid.MoveDirection.Magnitude < 0.05

        if isStanding or rootVelocity.Magnitude < 1 then
            cameraModule.safeSwitchState("Move", false)
            cameraModule.safeSwitchState("Idle", true)
            return
        end

        cameraModule.safeSwitchState("Move", true)
        cameraModule.safeSwitchState("Idle", false)

        cameraModule.forceStateParams("Move", moveStateLogic(humanoid.WalkSpeed))
        swapStates.moveState.Speed = math.min(humanoid.WalkSpeed, rootVelocity.Magnitude)
        --[[
            math.min prevents desync between animation speed and actual movement velocity.
            When walking against walls or obstacles, rootPart velocity decreases
            while WalkSpeed remains high, causing inconsistencies
        ]]
    end)

    lastBinds.Humanoid = humanoid.Changed:Connect(function(property)
        --[[
            Humanoid properties that could trigger camera effects:
            
            - "Health" - screen shake when low health, damage effects
            - "Jump" - camera bounce when jumping/landing
            - "Sit" - transition to seated camera
            - "PlatformStand" - special effects for platform standing
            and others.

            Small example for health-based effects:
            elseif property == "Health" and humanoid.Health < 50 then
                cameraModule:forceStateParams("Health", stdParams.LowHealth)
            end
        ]]
    end)
end

if player.Character then bindChar(player.Character) end
player.CharacterAdded:Connect(bindChar)
--binding ends

--event simulation: Active examples
local expNum = 0
game:GetService("UserInputService").InputBegan:Connect(function(input, gameProcessedEvent)
    if input.KeyCode == Enum.KeyCode.One then
        print("First example: Chained method calls")
        expNum += 1

        local curId = `Explosion_{expNum}`
        cameraModule.createStateWithName("Explosion", curId)
        cameraModule.forceStateParams(curId, stdParams.SmallExplosion)
        cameraModule.safeSwitchState(curId, true)
    elseif input.KeyCode == Enum.KeyCode.Two then
        print("Second example: Object-oriented approach")
        expNum += 1

        local state = cameraModule.createStateWithName("Explosion", `Explosion_{expNum}`)
        state.Strength = 5
        state.RollStrength = 2
        state.RegenSpeed = 8
        state.DirectionSwapSpeed = 30
        state:activate()    -- <- May be unstable for some states.
                            -- It's better to use cameraModule.safeSwitchState
    end
end)