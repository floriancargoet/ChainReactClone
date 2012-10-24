local BasicTarget = require('basictarget')

local TimeTarget = BasicTarget:subclass({
    radius = 5,
    color  = {0, 0, 255},
    time   = 1
})

TimeTarget.count = 0

function TimeTarget:constructor(...)
    TimeTarget.super.constructor(self, ...)
    TimeTarget.count = TimeTarget.count + 1
end

function TimeTarget:die()
    if not self.dead then
        TimeTarget.count = TimeTarget.count - 1
        self.dead = true
    end
end

return TimeTarget

