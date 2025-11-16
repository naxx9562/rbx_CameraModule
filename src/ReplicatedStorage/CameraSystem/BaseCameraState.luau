local BaseState = {}

function BaseState.new()
    local self = setmetatable({}, {__index = BaseState})
    self.name = "Unknown"
    self.isActive = false

    function self:activate() 
        self.isActive = true
    end

    function self:deactivate() 
        self.isActive = false
    end

    function self:purge()
        self:deactivate()
    end

    function self.onRenderStepped(deltaTime : number) end

    -- PTR ONLY
    function self.onSelfPurge() end

    return self
end

return BaseState