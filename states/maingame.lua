require 'state'
require 'basictarget'

local level = State:new()

local makeTarget = function()
    local t = BasicTarget:new({
        x      = BasicTarget.radius + math.random(global.width  - 2*BasicTarget.radius),
        y      = BasicTarget.radius + math.random(global.height - 2*BasicTarget.radius),
        speedX = math.random(-100, 100),
        speedY = math.random(-100, 100)
    })
    return t
end

function level:init()
    self.targets = {
        makeTarget(),
        makeTarget(),
        makeTarget(),
        makeTarget(),
        makeTarget(),
        makeTarget(),
        makeTarget(),
        makeTarget(),
        makeTarget(),
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


function level:keyreleased(key)
    if key == 'q' then
        self:exit() -- back to main screen
    end
end

function level:mousepressed(x, y, button)
    for i, t in ipairs(self.targets) do
        if t:contains(x, y, 5) then
            t:explode()
        end
    end
end

function level:update(dt)
    local toRemove = {}
    for i, t in ipairs(self.targets) do
        t:update(dt)
        if t.dead then
            table.insert(toRemove, i)
        end
    end

    local correction = 0
    for _, idx in ipairs(toRemove) do
        table.remove(self.targets, idx - correction)
        -- correct the index shift
        correction = correction + 1
    end
end

function level:draw()
    for i, t in ipairs(self.targets) do
        t:draw()
    end
end

return level
