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
        if self ~= self.class then
        end
        self.events = {}
    end
    self.events[event] = self.events[event] or {}
    table.insert(self.events[event], {handler = handler, context = context})
end

function Observable:removeListener(event, handler)
    if self:hasOwnProperty('events') then
        local handlers = self.events[event]
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

function Observable:removeAllListeners(event)
    if not self:hasOwnProperty('events') then
        return
    end

    if event then
        events[event] = nil
    else
        self.events = nil
    end
end

function Observable:trigger(event, ...) -- type: any, ...
    local handlers
    if self:hasOwnProperty('events') then
        handlers = self.events[event]
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
    if self ~= self.class then
        self.class:trigger(event, ...)
    end
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
function print_err(str)
    local info = debug.getinfo(2, 'Sl')
    -- We substring because love 0.8.0 adds an @ before the filename
    print_orig(string.format('%s:%d: >>> %s', info.source:sub(2), info.currentline, tostring(str)))
end

return {
    Observable = Observable,
    Mixin      = Mixin,
    noglobal   = noglobal,
    copy       = copy,
    print_err  = print_err
}
