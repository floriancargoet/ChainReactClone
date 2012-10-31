local BasicTarget = require('basictarget')

local TimeTarget = BasicTarget:subclass({
    radius = 5,
    color  = {50, 50, 255},
    time   = 1
}, 'TimeTarget')

TimeTarget.count = 0

function TimeTarget:constructor(...)
    TimeTarget.super.constructor(self, ...)
    TimeTarget.count = TimeTarget.count + 1
end

function TimeTarget:die()
    if not self.dead then
        TimeTarget.count = TimeTarget.count - 1
        TimeTarget.super.die(self)
    end
end

function TimeTarget:getTime()
    local root = self
    while root.parent do
        root = root.parent
    end
    local dx, dy = self.x - root.x, self.y - root.y
    local d = math.sqrt(dx*dx + dy*dy)
    return self.time * d / 20
end

return TimeTarget

