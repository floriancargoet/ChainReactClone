require 'state'
require 'basictarget'

local level = State:new()

local makeTarget = function()
    return  BasicTarget:new({
        x      = math.random(global.width),
        y      = math.random(global.height),
        speedX = math.random(-100, 100),
        speedY = math.random(-100, 100)
    })
end

function level:init()
    self.targets = {
        makeTarget(),
        makeTarget(),
        makeTarget(),
        makeTarget()
    }
    self.maxPop = 50
end

function level:reset()
    self:init()
end

function level:draw()
    for i, t in ipairs(self.targets) do
        t:draw()
    end
end

function level:keyreleased(key)
    if key == 'q' then
        self:exit() -- back to main screen
    end
end

function level:mousereleased

function level:update(dt)
    for i, t in ipairs(self.targets) do
        t:update(dt)
    end
end

return level
