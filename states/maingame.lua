require 'state'
require 'triggertarget'
require 'generator'

local level = State:new()

function level:init()
    -- all targets
    self.targets = {}
    -- exploding trees
    self.roots = {}

    self.generator = Generator:new({
        maxPopulation = 200,
        growth = 5,
        population = self.targets
    })

    self.generator:init()
    self.score = 0
    self.maxDepth = 0
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
    local source = TriggerTarget:new({
        x = x,
        y = y
    })
    table.insert(self.targets, source)
    table.insert(self.roots,   source)

    source:explode()
end

function level:update(dt)
    self.generator:update(dt)

    -- mark targets belongind to finished trees
    for i, t in ipairs(self.roots) do
        if t:allDead() then
            t:markAllToBeRemoved()
        end
    end

    local toRemove = {}

    for i, t in ipairs(self.targets) do
        t:update(dt)
        -- collect targets to remove
        if t.toRemove then
            table.insert(toRemove, i)
        end
        if t.dead then
            self.score = self.score + t:getPoints()
            self.maxDepth = math.max(self.maxDepth, t.depth)
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
    love.graphics.print('Max Depth: '..tostring(self.maxDepth), 0, 60)
    love.graphics.print('Population: '..tostring(#self.targets), 0, 80)

end

return level
