require 'state'

local welcome = State:new()

function welcome:init()
    self.bg = love.graphics.newImage('img/welcome.png')
end

function welcome:draw()
    love.graphics.draw(self.bg, 0, 0)
end

function welcome:keyreleased(key)
    if key == 'q' then
        self.game:quit()
    else
        self.game:pushState('maingame')
    end
end

function welcome:mousereleased()
    self.game:pushState('maingame')
end

return welcome
