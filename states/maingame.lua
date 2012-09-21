require 'state'
require 'basictarget'
require 'generator'

local level = State:new()

local neighbors = function(target)
    local n = {}
    for _, t in ipairs(level.targets) do
        if target:touches(t) and not t.exploding then
            table.insert(n, t)
        end
    end
    return ipairs(n)
end

function level:init()
    self.targets = {}

    self.generator = Generator:new({
        maxPopulation = 200,
        population = self.targets
    })

    self.generator:init()
    self.score = 0
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
        if not t.exploding and t:contains(x, y, 10) then
            t:explode()
            self.score = self.score + t.points
        end
    end
end

function level:update(dt)
    local toRemove = {}
    for i, t in ipairs(self.targets) do
        t:update(dt)
        -- remove dead targets
        if t.dead then
            table.insert(toRemove, i)
        end
        -- propagate explosion
        if t.exploding and not t.dead then
            for _, n in neighbors(t) do
                if not n.exploding then
                    n:explode()
                    self.score = self.score + n.points
                end
            end
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
    love.graphics.print('Score: '..tostring(self.score), 0, 40)
end

return level
