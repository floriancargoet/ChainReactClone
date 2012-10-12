require 'oo'

BasicTarget = Object:subclass({
    points    = 1,
    depth     = 1,
    x         = 0,
    y         = 0,
    radius    = 10,
    maxRadius = 30,
    speedX    = 0,
    speedY    = 0,
    stopOnPropagate = false,
    explosionSpeed  = 30,
    color           = {255, 255, 255},
    explodingColor  = {255, 0, 0}
})

function BasicTarget:constructor(config)
    self:apply(config)
end

function BasicTarget:die()
    self.dead = true
end

function BasicTarget:getPoints()
    return self.points * self.depth
end

function BasicTarget:getNeighborsIPairs(all)
    local n = {}
    for _, t in ipairs(all) do
        if self:touches(t) and not t.exploding then
            table.insert(n, t)
        end
    end
    return ipairs(n)
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

function BasicTarget:explode(depth)
    if not self.exploding then
        self.depth = depth or 1
        self.exploding = true
        self.speedX = 0
        self.speedY = 0
        self.color = self.explodingColor
    end
end

function BasicTarget:propagate(all)
    local hasPropagated = false
    for _, n in self:getNeighborsIPairs(all) do
        if not n.exploding then
            n:explode(self.depth + 1)
            hasPropagated = true
        end
    end
    if self.stopOnPropagate and hasPropagated then
        self:die()
    end
end

function BasicTarget:update(dt)
    self:updateExplosion(dt)
    self:updatePosition(dt)
    self:updateCollisions(dt)
end

function BasicTarget:updateExplosion(dt)
    if self.exploding then
        self.radius = self.radius + self.explosionSpeed * dt
        if self.radius > self.maxRadius then
            -- container will iterate on targets and remove them when necessary
            self:die()
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
    love.graphics.circle('line', self.x, self.y, self.radius, math.max(3*self.radius, 100))
    -- restore state
    love.graphics.setColor(r, g, b, a)
    love.graphics.setLineWidth(w)
end
