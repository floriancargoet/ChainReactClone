local State         = require 'state'
local TimeTarget    = require 'timetarget'
local TriggerTarget = require 'triggertarget'
local Generator     = require 'generator'
local loveutils     = require 'loveutils'

local print = loveutils.print

local level = State:new()

local function formatTime(time)
    return tostring(math.floor(time*10)/10)
end

function level:init()
    -- all targets
    self.targets = {}
    -- exploding trees
    self.roots = {}
    -- messages quickly displayed on screen
    self.flashMessages = {}

    self.generator = Generator:new({
        maxPopulation = 200,
        growth = 5,
        population = self.targets
    })

    self.generator:init()
    self.score = 0
    self.maxDepth = 0
    self.maxTotal = 0
    self.remainingTime = 15

    -- register on  events
    TimeTarget:on('explode', self.onTimeExplode, self)
end

function level:onTimeExplode(target)
    local time = target:getTime()
    self.remainingTime = self.remainingTime + time
    self:flash({
        x = target.x,
        y = target.y,
        text = '+ '..formatTime(time)..' s!'
    })
end

function level:reset()
    self:init()
end

function level:restore()
    -- replay
    if self.remainingTime < 0 then
        self.generator:destroy()
        TimeTarget:removeListener('explode', self.onTimeExplode)
        self:init()
    end
end

function level:over()
    local gameover = self.game:pushState('gameover')
    gameover:setScore(self.score)
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
    self:updateTargets(dt)
    self.remainingTime = self.remainingTime - dt

    if self.remainingTime < 0 then
        self:over()
    end
end

function level:updateTargets(dt)
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
            --[[
            self:flash({
                x = t.x,
                y = t.y,
                text = 'S: '..tostring(score)..' T: '..tostring(total)..' D: '..tostring(depth)
            })
            --]]
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
    print('Score: '..tostring(self.score))
    print('Max Depth: '..tostring(self.maxDepth))
    print('Max Total: '..tostring(self.maxTotal))
    print('Population: '..tostring(self.generator.count))
    print('Time: '..formatTime(self.remainingTime))

    for _, flash in ipairs(self.flashMessages) do
        love.graphics.print(flash.text, flash.x, flash.y)
    end
end

return level
