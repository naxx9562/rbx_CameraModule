local csIdle = {}

function csIdle.new()
    local repl = game:GetService("ReplicatedStorage")
    local self = require(repl.CameraSystem.BaseCameraState).new()
    local camera = workspace.CurrentCamera

    self.MaxStrength = 0.01
    local Strength = 0

    self.onRenderStepped = function(deltaTime : number)
        if self.isActive then
            Strength = math.lerp(Strength, 1, deltaTime * 15)
        else
            Strength = math.lerp(Strength, 0, deltaTime * 15)
        end

        local t = time() * 2
        local kk = Strength * self.MaxStrength
        camera.CFrame *= CFrame.Angles(
            math.sin(t) * 0.8 * kk * deltaTime,
            0,
            math.sin(t) * 0.1 * kk
        )
    end

    return self
end

return csIdle