local State     = require 'state'
local loveutils = require 'loveutils'

local print = loveutils.print

local gameover = State:new()

function gameover:init()
end

function gameover:setScore(value)
    self.score = value
end

function gameover:draw()
    print('Score: '..tostring(self.score))
    print('Press R to replay, Q to quit')
end

function gameover:keyreleased(key)
    if key == 'q' then
        self.game:quit()
    elseif key == 'r' then
        self:replay()
    end
end

function gameover:replay()
    self:exit()
end

return gameover
