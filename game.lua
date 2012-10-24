local Object = require 'oo'

-- Game class
local Game = Object:subclass()

function Game:constructor()
    self.loadedStates = {}
    self.stateStack   = {}
    self.currentState = nil -- quick access to the top state
end

function Game:start(stateName)
    self:pushState(stateName)
end

function Game:pushState(stateName)
    local state = self:getState(stateName)
    table.insert(self.stateStack, state)
    self.currentState = state
end

function Game:popState(stateName)
    table.remove(self.stateStack)
    self.currentState = self.stateStack[#self.stateStack]
end

-- State loader
function Game:loadState(stateName)
    return dofile('states/'..stateName..'.lua')
end

-- private - returns states, create and init if needed
function Game:getState(stateName)
    local state = self.loadedStates[stateName]
    if not state then
        state = self:loadState(stateName)
        if not state then
            error("State '"..stateName.."' does not exists", 3)
        end
        state.game = self
        state:init()
        state:on('exit', self.popState, self)
        self.loadedStates[stateName] = state
    else
        state:reset()
    end
    return state
end

-- quit shortcut
function Game:quit()
    if love.event.quit then
        love.event.quit() -- löve >= 0.8
    else
        love.event.push('q') -- löve < 0.8
    end
end

-- love callbacks
local callbacks = {
    'keypressed',
    'keyreleased',
    'mousepressed',
    'mousereleased',
    'update',
    'draw'
}

for i, method in ipairs(callbacks) do
    Game[method] = function(self, ...)
        self.currentState[method](self.currentState, ...)
    end
end

return Game
