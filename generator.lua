local Object      = require 'oo'
local BasicTarget = require 'basictarget'
local BigTarget   = require 'bigtarget'
local BonusTarget = require 'bonustarget'
local TimeTarget  = require 'timetarget'


-- Generator class
local Generator = Object:subclass({
    -- config
    maxPopulation = 100,
    growth = 10, -- per second

    -- internal
    toAdd = 0,
    count = 0,
    timeCount  = 0,
    bonusCount = 0,
    bigCount   = 0
})

local make = function(Class)
    local a = math.random() * 2 * math.pi
    local speed = 30
    local t = Class:new({
        x      = Class.radius + math.random(global.width  - 2*Class.radius),
        y      = Class.radius + math.random(global.height - 2*Class.radius),
        speedX = speed * math.cos(a),
        speedY = speed * math.sin(a)
    })
    return t
end

function Generator:constructor(o)
    self:apply(o)
    BasicTarget:on('death', self.onBasicDeath, self)
    TimeTarget :on('death', self.onTimeDeath,  self)
    BonusTarget:on('death', self.onBonusDeath, self)
    BigTarget  :on('death', self.onBigDeath,   self)
end

function Generator:init()
    for i = 1, self.maxPopulation/2 do
        table.insert(self.population, make(BasicTarget))
        self.count = self.count + 1
    end
end

function Generator:destroy()
    BasicTarget:removeListener('death', self.onBasicDeath)
    BigTarget  :removeListener('death', self.onBigDeath)
    BonusTarget:removeListener('death', self.onBonusDeath)
    TimeTarget :removeListener('death', self.onTimeDeath)
end

function Generator:onBasicDeath()
    self.count = self.count - 1
end

function Generator:onBigDeath()
    self.bigCount = self.bigCount - 1
end

function Generator:onBonusDeath()
    self.bonusCount = self.bonusCount - 1
end

function Generator:onTimeDeath()
    self.timeCount = self.timeCount - 1
end


function Generator:addOne()
    local t
    local r = math.random()
    if r < 0.05 then
        if self.bigCount < 3 then
            t = make(BigTarget)
            self.bigCount = self.bigCount + 1
        end
    elseif r < 0.10 then
        if self.bonusCount < 3 then
            t = make(BonusTarget)
            self.bonusCount = self.bonusCount + 1
        end
    elseif r < 0.15 then
        if self.timeCount < 3 then
            t = make(TimeTarget)
            self.timeCount = self.timeCount + 1
        end
    end

    if not t then
        t = make(BasicTarget)
    end
    table.insert(self.population, t)
    self.count = self.count + 1
end

function Generator:update(dt)
    if self.count >= self.maxPopulation then
        self.toAdd = 0
        return
    end

    self.toAdd = self.toAdd + self.growth * dt
    while self.toAdd > 1.0 do
        self:addOne()
        self.toAdd = self.toAdd - 1
    end
end

return Generator
