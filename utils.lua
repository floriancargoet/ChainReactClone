-- a Mixin class
-- Usage:
--  * create a new mixin with methods
--     Closable = Mixin.create()
--     function Closable:close() print('close') end
--  * apply the mixin to a "class" or an instance
--     Closable.mixin(Window)
--     w = Window:create()
--     w:close() --> prints 'close'
--
-- mixin() fails if method names conflict

local Mixin = {}

function Mixin:create(mixin) -- type: table
    -- here self = class
    mixin = mixin or {}
    setmetatable(mixin, self)
    self.__index = self
    return mixin
end

function Mixin:mixin(class) -- type: table
    for name, method in pairs(self) do
        if class[name] then
            error("Method "..name.." already exists!", 2)
        else
            class[name] = method
        end
    end
    return class
end



-- an Observable mixin

local Observable = Mixin:create()

function Observable:on(event, handler, context) -- type: any, function, table
    if not event then
        error('event cannot be nil', 2)
    end
    if not handler then
        error('handler cannot be nil', 2)
    end
    if not self:hasOwnProperty('events') then
        self.events = {}
    end
    self.events[event] = self.events[event] or {}
    table.insert(self.events[event], {handler = handler, context = context})
end

function Observable:trigger(event, ...) -- type: any, ...
    local handlers = self.events and self.events[event]
    if handlers then
        for _, hc in ipairs(handlers) do
            if hc.context then -- handler requires a 'self' value
                hc.handler(hc.context, ...)
            else
                hc.handler(...)
            end
        end
    end
    self.class:trigger(event, ...)
end

-- Prevent from using globals
function noglobal(name, mode)
    local fail = (mode == 'fail')
    local global = {}
    _G[name] = global

    setmetatable(global, {
        __newindex = function(t, k, v)
            rawset(_G, k, v)
        end
    })
    setmetatable(_G, {
        __newindex = function(t,k,v)
            local info = debug.getinfo(2, 'Sl')

            if fail then
                error('Global found "'..k..'"', 2)
            else
                -- We substring because love 0.8.0 adds an @ before the filename
                print(string.format('%s:%d:  Global found "%s"', info.source:sub(2), info.currentline, k))
                rawset(_G,k,v)
            end
        end
    })
end

function copy(source, target)
    for property, value in pairs(source) do
        target[property] = value
    end
end

return {
    Observable = Observable,
    Mixin      = Mixin,
    noglobal   = noglobal,
    copy       = copy
}
