local Object = require('oo')

local Particle = Object:subclass({
    width = 5,
    opacity = 1
}, 'Particle')

function Particle:constructor(parent, angle)
    self.parent = parent
    self.angle = angle
    self.origX = parent.x
    self.origY = parent.y
    self.rotation = math.random() * 2 * math.pi
    self.origR = parent.radius
    self:update(0)
end

function Particle:update(dt)
    local r = self.parent.radius

    -- completly empirical formula
    local d =  r / self.origR - 1
    d = 5 + r * (1 + d/4)

    self.x = self.origX + math.cos(self.angle) * d
    self.y = self.origY + math.sin(self.angle) * d

    if self.opacity > 0.5 then
        self.opacity = self.opacity - dt
    end
end

function Particle:draw()
    local r, g, b, a = love.graphics.getColor()

    local x, y, w = self.x, self.y, self.width
    local dx, dy = w * math.cos(r), w * math.sin(self.rotation)
    local x1, y1, x2, y2 = x - dx, y - dy, x + dx, y + dy

    love.graphics.setColor(r, g, b, self.opacity * 255)
    love.graphics.line(x1, y1, x2, y2)

    love.graphics.setColor(r, g, b, a)
end

return Particle
