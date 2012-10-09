require('oo')

BigTarget = BasicTarget:subclass({
    maxRadius = 80,
    color     = {255, 0, 0}
})

function BigTarget:explode(depth)
    self.maxRadius = 30 + 20 * (depth or 1)
    BigTarget.super.explode(self, depth)
end
