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
    -- draw circle
    love.graphics.setColor(unpack(self.color))
    love.graphics.setLineWidth(1.5)
    love.graphics.circle('line', self.x, self.y, self.radius, 30)
    love.graphics.circle('line', self.x, self.y, self.radius - 5, 30)
    -- restore state
    love.graphics.setColor(r, g, b, a)
    love.graphics.setLineWidth(w)
end
