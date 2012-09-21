require 'oo'

BasicTarget = Object:subclass({
    points    = 1,
    x         = 0,
    y         = 0,
    radius    = 10,
    maxRadius = 30,
    speedX    = 0,
    speedY    = 0,
    color     = {255, 255, 255}
})

function BasicTarget:constructor(config)
    self:apply(config)
end

function BasicTarget:contains(x, y, tolerance)
    local r = self.radius + (tolerance or 0)

    local dx, dy = self.x - x, self.y - y
    return dx * dx + dy * dy <= r * r
end

function BasicTarget:touches(target)
    local dx, dy = self.x - target.x, self.y - target.y
    local d = self.radius + target.radius
    return dx * dx + dy * dy <= d * d
end

function BasicTarget:explode()
    if not self.exploding then
        self.exploding = true
        self.speedX = 0
        self.speedY = 0
        self.color = {255, 0, 0}
    end
end

function BasicTarget:update(dt)
    self:updateExplosion(dt)
    self:updatePosition(dt)
    self:updateCollisions(dt)
end

function BasicTarget:updateExplosion(dt)
    if self.exploding then
        self.radius = self.radius + self.maxRadius * dt / 0.8 -- 0.8 seconds
        if self.radius > self.maxRadius then
            -- container will iterate on targets and remove them when necessary
            self.dead = true
        end
    end
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
    -- save state
    local r, g, b, a = love.graphics.getColor()
    local w = love.graphics.getLineWidth()
    -- draw circle
    love.graphics.setColor(unpack(self.color))
    love.graphics.setLineWidth(1.5)
    love.graphics.circle('line', self.x, self.y, self.radius, 30)
    -- restore state
    love.graphics.setColor(r, g, b, a)
    love.graphics.setLineWidth(w)
end
