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

    if not self:hasOwnProperty('_events') then
        if self ~= self.class then
        end
        self._events = {}
    end
    self._events[event] = self._events[event] or {}
    table.insert(self._events[event], {handler = handler, context = context})
end

function Observable:removeListener(event, handler)
    if self:hasOwnProperty('_events') then
        local handlers = self._events[event]
        if handlers then
            local idx
            for i, hc in ipairs(handlers) do
                if hc.handler == handler then
                    idx = i
                    break
                end
            end
            if idx then
                table.remove(handlers, idx)
            end
        end
    end
end

function Observable:trigger(event, ...) -- type: any, ...
    if self:hasOwnProperty('_stopEvents') and self._stopEvents[event] then
        return
    end
    --print_err('Triggering '..event..' on '..tostring(self))

    local handlers
    if self:hasOwnProperty('_events') then
        handlers = self._events[event]
    end
    if handlers then
        for _, hc in ipairs(handlers) do
            if hc.context then -- handler requires a 'self' value
                hc.handler(hc.context, ...)
            else
                hc.handler(...)
            end
        end
    end
    -- if self is an instance, trigger on class
    if self ~= self.class then
        self.class:trigger(event, ...)
    elseif self.super and self.super.trigger then-- else trigger on parent class
        self.super:trigger(event, ...)
    end
    --]]
end

function Observable:stopEvents(events)
    self._stopEvents = events
end

function Observable:resumeEvents()
    self._stopEvents = {}
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
            local msg = 'Global found "'..k..'"'
            if fail then
                error(msg, 2)
            else
                print_err(msg)
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

local print_orig = print
function print_err(...)
    local stringed_args = {}
    for _, v in ipairs(arg) do
        table.insert(stringed_args, tostring(v))
    end
    local str = table.concat(stringed_args, '\t')

    local info = debug.getinfo(2, 'Sl')
    -- We substring because love 0.8.0 adds an @ before the filename
    print_orig(string.format('%s:%d: >>>\t%s', info.source:sub(2), info.currentline, str))
end

return {
    Observable = Observable,
    Mixin      = Mixin,
    noglobal   = noglobal,
    copy       = copy,
    print_err  = print_err
}
