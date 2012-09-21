require 'game'

global = {
    width  = love.graphics.getWidth(),
    height = love.graphics.getHeight()
}

math.randomseed( os.time() )

local game     = Game:new()
local showFPS  = true
local showMore = true
local maxDt    = 16 -- ~= 1000/60

-- delegate love callbacks to the game instance
function love.load()
    game:start('welcome') -- load the first screen
end

function love.keyreleased(key)
    if key == 'escape' then
        game:quit()
    elseif key == 'f3' then
        showFPS = not showFPS
    elseif key == 'f4' then
        showMore = not showMore
    else
        game:keyreleased(key)
    end
end

function love.draw()
    game:draw()
    if showFPS then
        love.graphics.print('FPS: '..love.timer.getFPS(), 0, 0)
    end
    if showMore then
        local x, y = love.mouse.getPosition()
        love.graphics.print('Mouse: '..x..', '..y, 0, 20)
    end

    --max 60 fps
    local dt = love.timer.getDelta()/1000
    if dt < maxDt then
        love.timer.sleep(maxDt - dt)
    end
end

-- delegate everything else
local callbacks = {
    'keypressed',
    'keyreleased',
    'mousepressed',
    'mousereleased',
    'update',
    'draw'
}

for i, method in ipairs(callbacks) do
    if not love[method] then
        love[method] = function(...)
            game[method](game, ...)
        end
    end
end
