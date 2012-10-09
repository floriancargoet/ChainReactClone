require 'state'
require 'basictarget'
require 'generator'

local level = State:new()

function level:init()
    self.targets = {}

    self.generator = Generator:new({
        maxPopulation = 200,
        growth = 5,
        population = self.targets
    })

    self.generator:init()
    self.score = 0
    self.maxdepth = 0
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
    local source = BasicTarget:new({
        x = x,
        y = y,
        points = 0,
        explodingColor = {0, 255, 0}
    })
    table.insert(self.targets, source)
    source:explode()
end

function level:update(dt)
    self.generator:update(dt)
    local toRemove = {}
    for i, t in ipairs(self.targets) do
        t:update(dt)
        -- remove dead targets
        if t.dead then
            table.insert(toRemove, i)
            self.score = self.score + t:getPoints()
            self.maxdepth = math.max(self.maxdepth, t.depth)
        end
        -- propagate explosion
        if t.exploding and not t.dead then
            t:propagate(self.targets)
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
    love.graphics.print('Max Depth: '..tostring(self.maxdepth), 0, 60)
    love.graphics.print('Population: '..tostring(#self.targets), 0, 80)

end

return level
