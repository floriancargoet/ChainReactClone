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
    self.maxTotal = 0
    self.flashMessages = {}
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
    self:updateFlashMessages(dt)

    -- mark targets belonging to finished trees as to be removed
    local toRemove = {}
    for i, t in ipairs(self.roots) do
        if t:allDead() then

            local depth = 0
            local total = - 1 -- do not count the trigger
            local score = 0

            t:cascade(function(target)
                target.toRemove = true
                depth = math.max(depth, target.depth)
                total = total + 1
                score = score + target:getPoints()
            end)

            table.insert(toRemove, i)

            self.score = self.score + score
            self.maxDepth = math.max(depth, self.maxDepth)
            self.maxTotal = math.max(total, self.maxTotal)
            self:flash({
                x = t.x,
                y = t.y,
                text = 'S: '..tostring(score)..' T: '..tostring(total)..' D: '..tostring(depth)
            })
        end
    end

    local correction = 0
    for _, idx in ipairs(toRemove) do
        table.remove(self.roots, idx - correction)
        -- correct the index shift
        correction = correction + 1
    end

    toRemove = {}
    for i, t in ipairs(self.targets) do
        t:update(dt)
        -- collect targets to remove
        if t.toRemove then
            table.insert(toRemove, i)
        end
        -- propagate explosion
        if t.exploding and not t.dead then
            t:propagate(self.targets)
        end

    end

    correction = 0
    for _, idx in ipairs(toRemove) do
        table.remove(self.targets, idx - correction)
        -- correct the index shift
        correction = correction + 1
    end
end

function level:flash(flash)
    flash.duration = flash.duration or 1
    table.insert(self.flashMessages, flash)
end

function level:updateFlashMessages(dt)
    local toRemove = {}
    for i, flash in ipairs(self.flashMessages) do
        flash.duration = flash.duration - dt
        if flash.duration <= 0 then
            table.insert(toRemove, i)
        end
    end

    local correction = 0
    for _, idx in ipairs(toRemove) do
        table.remove(self.flashMessages, idx - correction)
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
    love.graphics.print('Max Total: '..tostring(self.maxTotal), 0, 80)
    love.graphics.print('Population: '..tostring(#self.targets), 0, 100)

    for _, flash in ipairs(self.flashMessages) do
        love.graphics.print(flash.text, flash.x, flash.y)
    end
end

return level
