local State = require 'state'
local loveutils = require 'loveutils'

local print = loveutils.print
local welcome = State:new()



function welcome:draw()
    print('When the game starts, click anywhere to trigger a chain reaction')
    print('Each target gives you 1 point')
    print('Each yellow target gives you 5 points and propagates this effect')
    print('Red targets have a bigger explosion (proportional to the depth of the chain reaction)')
    print('Blue targets gives you time (proportional to the distance between the target and beginning of the chain reaction)')
    print('')
    print('Click anywhere to start the game')

end

function welcome:keyreleased(key)
    if key == 'q' then
        self.game:quit()
    end
end

function welcome:mousereleased()
    self.game:pushState('maingame')
end

return welcome
