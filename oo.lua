-- simple class-like system
-- features:
--   - inheritance (sublasses, is_a, "super")
--   - static (just put stuff in the class table)
--   - base class Object
-- notes:
--   - do not use self.super.method(self)
--     it only works on one level!
--     use Class.super.method(self) instead

local Object = {}
Object.class = Object
Object.className = 'Object'

function Object:subclass(new, name)
  local super = self
  local new = new or {}
  name = name or 'Sub'..super.className

  -- if something is not found in the class, search in the parent class
  setmetatable(new, {
    __index = super,
    __tostring = function()
      return '[class '..name..']'
    end
  })
  new.class = new
  new.super = super
  new.className = name
  return new
end

function Object:new(...)
  local instance = {}
  -- if something is not found in the instance, search in the class
  setmetatable(instance, {
    __index = self,
    __tostring  = function()
        return '[object '..self.className..']'
    end
  })
  instance:constructor(...)
  return instance
end

function Object:constructor()
end

function Object:apply(properties)
  if properties then
    for property, value in pairs(properties) do
      self[property] = value
    end
  end
end

function Object:is_a(Class)
  local class = self.class
  while class do
    if class == Class then
      return true
    end
    class = class.super
  end
  return false
end

function Object:hasOwnProperty(property)
    local mt = getmetatable(self)
    setmetatable(self, nil)
    local has = (self[property] ~= nil)
    setmetatable(self, mt)
    return has
end

return Object
