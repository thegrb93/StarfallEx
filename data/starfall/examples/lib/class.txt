--@name Class
--@author Xandaros

--Class library, most recent version can be found here: https://gist.github.com/Xandaros/ea8756e4c4ba00218855

local function callConstructor(class, obj, ...)
    local meta = getmetatable(class)
    if meta.__super then
        if class.superArgs then
            callConstructor(meta.__super, obj, class.superArgs(...))
        else
            callConstructor(meta.__super, obj)
        end
    end
    if class.constructor then
        class.constructor(obj, ...)
    end
end

local function instantiate(class, ...)
    local ret = setmetatable({}, {
        __index = class
    })
    callConstructor(class, ret, ...)
    return ret
end

function Class(name, superclass)
    local ret = {}
    setmetatable(ret, {
        __index = function(self, key)
            if key ~= "constructor" and superclass then
                return superclass[key]
            end
            return nil
        end,
        __super = superclass,
        __call = instantiate,
        __tostring = function() return name or "unknown" end
    })
    return ret
end
