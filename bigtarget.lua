require('oo')
require('basictarget')

BigTarget = BasicTarget:subclass({
    radius    = 5,
    maxRadius = 80,
    color     = {255, 0, 0},
    explosionSpeed = 60
})

BigTarget.count = 0

function BigTarget:constructor(...)
    BigTarget.super.constructor(self, ...)
    BigTarget.count = BigTarget.count + 1
end

function BigTarget:die()
    BigTarget.count = BigTarget.count - 1
    self.dead = true
end


function BigTarget:explode(depth)
    if not self.exploding then
        self.maxRadius = math.min(50 + 10 * (depth or 1), 200)
        BigTarget.super.explode(self, depth)
    end
end