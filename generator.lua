require 'oo'
require 'basictarget'
require 'bigtarget'

-- Generator class
Generator = Object:subclass({
    maxPopulation = 100,
    growth = 10, -- per second
    toAdd = 0
})

local makeBasicTarget = function()
    local a = math.random() * 2 * math.pi
    local t = BasicTarget:new({
        x      = BasicTarget.radius + math.random(global.width  - 2*BasicTarget.radius),
        y      = BasicTarget.radius + math.random(global.height - 2*BasicTarget.radius),
        speedX = 40 * math.cos(a),
        speedY = 40 * math.sin(a)
    })
    return t
end

local makeBigTarget = function()
    local a = math.random() * 2 * math.pi
    local t = BigTarget:new({
        x      = BigTarget.radius + math.random(global.width  - 2*BigTarget.radius),
        y      = BigTarget.radius + math.random(global.height - 2*BigTarget.radius),
        speedX = 40 * math.cos(a),
        speedY = 40 * math.sin(a)
    })
    return t
end


function Generator:constructor(o)
    self:apply(o)
end

function Generator:init()
    for i = 1, self.maxPopulation/2 do
        table.insert(self.population, makeBasicTarget())
    end
end

function Generator:addOne()
    local t
    if math.random() < 0.1 then
        t = makeBigTarget()
    else
        t = makeBasicTarget()
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
