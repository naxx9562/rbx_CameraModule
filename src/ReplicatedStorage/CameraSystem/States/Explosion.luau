local csExplosion = {}

local MINSTRENGH = 1 / 10^9

local function getStableRandom(stable)
    local sign = math.random(0, 1) == 0 and -1 or 1 -- -1 or 1
    local magnitude = stable + math.random() * (1-stable)
    return sign * magnitude
end

function csExplosion.new()
    local camera = workspace.CurrentCamera

    local repl = game:GetService("ReplicatedStorage")
    local self = require(repl.CameraSystem.BaseCameraState).new()
    local SpringModule = require(repl.SpringModule)

    local spr = SpringModule.new(Vector3.new())
    spr.Damper = 0
    spr.Speed = 15

    self.name = "Explosion"

    self.Strength = 1
    self.RollStrength = 1
    self.RegenSpeed = 5
    self.DirectionSwapSpeed = 30

    local dirChooser = task.spawn(function()
        local DT = 1 / self.DirectionSwapSpeed
        while task.wait(DT) do
            local rotationDir = Vector3.new(
                math.random() - 0.5,
                math.random() - 0.5,
                0
            ).Unit

            local rollDir = Vector3.new(0, 0, getStableRandom(0.7) * self.RollStrength)

            spr.Velocity = (rotationDir + rollDir) * self.Strength
        end
    end)

    function self:purge()
        task.cancel(dirChooser)
        self:deactivate()
    end

    local lastPos = Vector3.new()
    function self.onRenderStepped(deltaTime : number)
        if not self.isActive then
            return
        end

        if self.Strength <= MINSTRENGH then
            self.onSelfPurge()
            return
        end

        self.Strength = math.lerp(self.Strength, 0, deltaTime * self.RegenSpeed)

        camera.CFrame *= CFrame.Angles(
            (spr.Position.X - lastPos.X),
            (spr.Position.Y - lastPos.Y),
            (spr.Position.Z - lastPos.Z)
        )
        lastPos = spr.Position
    end

    return self
end

return csExplosion