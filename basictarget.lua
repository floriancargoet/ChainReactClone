require 'oo'

BasicTarget = Object:subclass({
    x      = 0,
    y      = 0,
    radius = 20,
    speedX = 0,
    speedY = 0
})

function BasicTarget:constructor(config)
    self:apply(config)
end

function BasicTarget:update(dt)
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
    love.graphics.circle('line', self.x, self.y, self.radius, 20)
end
