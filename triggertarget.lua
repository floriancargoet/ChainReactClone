require('oo')
require('basictarget')

TriggerTarget = BasicTarget:subclass({
    points          = 0,
    maxRadius       = math.huge,
    stopOnPropagate = true,
    explodingColor  = {0, 255, 0}
})

function TriggerTarget:draw()
    -- save state
    local r, g, b, a = love.graphics.getColor()
    local w = love.graphics.getLineWidth()

    if not self.dead then
        -- draw circle
        love.graphics.setColor(unpack(self.color))
        love.graphics.setLineWidth(1.5)
        local sides = math.max(3*self.radius, 100)
        love.graphics.circle('line', self.x, self.y, self.radius, sides)
        love.graphics.circle('line', self.x, self.y, self.radius - 5, sides)
    end
    -- restore state
    love.graphics.setColor(r, g, b, a)
    love.graphics.setLineWidth(w)
end

function TriggerTarget:explode()
    TriggerTarget.super.explode(self, 0)
end
