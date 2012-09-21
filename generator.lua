require 'oo'
require 'basictarget'

-- Generator class
Generator = Object:subclass()

local makeTarget = function()
    local a = math.random() * 2 * math.pi
    local t = BasicTarget:new({
        x      = BasicTarget.radius + math.random(global.width  - 2*BasicTarget.radius),
        y      = BasicTarget.radius + math.random(global.height - 2*BasicTarget.radius),
        speedX = 40 * math.cos(a),
        speedY = 40 * math.sin(a)
    })
    return t
end

function Generator:constructor(o)
    self:apply(o)
end

function Generator:init()
    for i = 1, self.maxPopulation do
        table.insert(self.population, makeTarget())
    end
    
end
