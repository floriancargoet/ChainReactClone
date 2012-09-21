require 'oo'
require 'utils'

State = Object:subclass()

Observable:mixin(State)

function State:exit()
    self:trigger('exit')
end

-- called before push if first time
function State:init()
end

-- called before push if not first time
function State:reset()
end

local callbacks = {
    'keypressed',
    'keyreleased',
    'mousepressed',
    'mousereleased',
    'update',
    'draw'
}

for i, method in ipairs(callbacks) do
    State[method] = function()
    end
end
