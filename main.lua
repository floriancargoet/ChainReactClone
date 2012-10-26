local Game  = require 'game'
local utils = require 'utils'
local loveutils = require 'loveutils'

utils.noglobal('global', 'fail') -- use global.name = value to create a global

global.global = {
    width  = love.graphics.getWidth(),
    height = love.graphics.getHeight()
}

math.randomseed( os.time() )

local game     = Game:new()
local showFPS  = false
local showMore = false

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
    loveutils.print() -- reset
    game:draw()
    if showFPS then
        loveutils.print('FPS: '..love.timer.getFPS())
    end
    if showMore then
        local x, y = love.mouse.getPosition()
        loveutils.print('Mouse: '..x..', '..y)
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
