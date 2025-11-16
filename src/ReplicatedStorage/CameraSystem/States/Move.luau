local csMove = {}

function csMove.new()
    local repl = game:GetService("ReplicatedStorage")
    local self = require(repl.CameraSystem.BaseCameraState).new()
    local camera = workspace.CurrentCamera

    self.Amplitude = 1
    self.Speed = 1
    self.MaxStrength = 0.005

    local Strength = 0
    local lastPos = Vector3.new()

    local t = 0
    self.onRenderStepped = function(deltaTime : number)
        if self.isActive then
            Strength = math.lerp(Strength, 1, deltaTime * 15)
        else
            Strength = math.lerp(Strength, 0, deltaTime * 15)
        end

        t += deltaTime * self.Speed * Strength

        local curSth = Strength * self.MaxStrength
        local kk = self.Amplitude * curSth

        local curPos = Vector3.new(
            math.sin(t) * kk,
            math.sin(t * 0.5) * 0.5 * kk,
            math.cos(t * 0.5) * 0.05 * curSth
        )
        
        camera.CFrame *= CFrame.Angles(
            curPos.X - lastPos.X,
            curPos.Y - lastPos.Y,
            curPos.Z - lastPos.Z
        )

        lastPos = curPos
    end

    return self
end

return csMove