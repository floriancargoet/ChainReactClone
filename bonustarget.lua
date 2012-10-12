require('oo')
require('basictarget')

BonusTarget = BasicTarget:subclass({
    points = 5,
    radius = 5,
    color  = {255, 255, 0},
    explodingColor = {255, 255, 0}
})

BonusTarget.count = 0

function BonusTarget:constructor(...)
    BonusTarget.super.constructor(self, ...) 
    BonusTarget.count = BonusTarget.count + 1
end

function BonusTarget:die()
    BonusTarget.count = BonusTarget.count - 1
    self.dead = true
end

function BonusTarget:propagate(all)
    for _, n in self:getNeighborsIPairs(all) do
        if not n.exploding then
            -- propagate the bonus
            -- convert the touched target into a bonus target
            n.points = n.points * 5
            n.propagate = BonusTarget.propagate
            n.explodingColor = BonusTarget.explodingColor
            
            n:explode(self.depth + 1)
        end
    end
end