require 'oo'

BasicTarget = Object:subclass({
    x      = 0,
    y      = 0,
    radius = 10,
    maxRadius = 20,
    speedX = 0,
    speedY = 0,
    color  = {255, 255, 255}
})

function BasicTarget:constructor(config)
    self:apply(config)
end

function BasicTarget:contains(x, y)
    local dx, dy = self.x - x, self.y - y
    return dx * dx + dy * dy <= self.radius * self.radius
end

function BasicTarget:explode()
    self.exploding = true
    self.color = {255, 0, 0}
end

function BasicTarget:update(dt)
    if self.exploding then
        self.radius = self.radius + 10 * dt
        if self.radius > self.maxRadius then
            -- container will iterate on targets and remove them when necessary
            self.dead = true
        end
    end
    self:updatePosition(dt)
    self:updateCollisions(dt)
end

function BasicTarget:updatePosition(dt)
    self.x = self.x + self.speedX * dt
    self.y = self.y + self.speedY * dt
end

function BasicTarget:updateCollisions(dt)
    if self.x < self.radius or global.width - self.radius < self.x then
        self.speedX = - self.speedX
        self.x = self.x + 2 * self.speedX * dt
    end
    if self.y < self.radius or global.height - self.radius < self.y then
        self.speedY = - self.speedY
        self.y = self.y + 2 * self.speedY * dt
    end
end

function BasicTarget:draw()
    -- save color
    local r, g, b, a = love.graphics.getColor()
    -- draw circle
    love.graphics.setColor(unpack(self.color))
    love.graphics.circle('line', self.x, self.y, self.radius, 20)
    -- restore color
    love.graphics.setColor(r, g, b, a)
end
