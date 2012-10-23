require 'oo'
require 'basictarget'
require 'bigtarget'
require 'bonustarget'


-- Generator class
Generator = Object:subclass({
    -- config
    maxPopulation = 100,
    growth = 10, -- per second

    -- internal
    toAdd = 0
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
end

function Generator:init()
    for i = 1, self.maxPopulation/2 do
        table.insert(self.population, make(BasicTarget))
    end
end

function Generator:addOne()
    local t
    local r = math.random()
    if r < 0.05 and BigTarget.count < 3 then
        t = make(BigTarget)
    elseif r < 0.1 and BonusTarget.count < 3 then
        t = make(BonusTarget)
    else
        t = make(BasicTarget)
    end
    table.insert(self.population, t)
end

function Generator:update(dt)
    if #self.population >= self.maxPopulation then
        self.toAdd = 0
        return
    end

    self.toAdd = self.toAdd + self.growth * dt
    while self.toAdd > 1.0 do
        self:addOne()
        self.toAdd = self.toAdd - 1
    end
end
