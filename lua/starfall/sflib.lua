-------------------------------------------------------------------------------
-- The main Starfall library
-------------------------------------------------------------------------------
SF.Modules = {}
SF.Types = {}
SF.Libraries = {}
SF.ResourceCounters = {}
SF.Superuser = {IsValid = function() return false end, SteamID64 = function() return "Superuser" end}
local dgetmeta = debug.getmetatable
local TypeID = TypeID
local IsValid = FindMetaTable("Entity").IsValid

-- Make sure this is done after metatables have been set
hook.Add("InitPostEntity","SF_SanitizeTypeMetatables",function()
	local function sanitizeTypeMeta(theType, myMeta)
		local meta = debug.getmetatable(theType)
		if meta then
			for k, v in pairs(meta) do
				if isfunction(v) then
					local myMetaFunc = myMeta and myMeta[k]
					if myMetaFunc then
						meta[k] = function(...)
							if SF.runningOps then return myMetaFunc(...) else return v(...) end
						end
					else
						meta[k] = function(...)
							if not SF.runningOps then return v(...) end
						end
					end
				elseif istable(v) and k=="__index" then
					local myMetaFunc = myMeta and myMeta[k]
					if myMetaFunc then
						meta[k] = function(t,k)
							if SF.runningOps then return myMetaFunc(t,k) else return rawget(t,k) end
						end
					else
						meta[k] = function(t,k)
							if not SF.runningOps then return rawget(t,k) end
						end
					end
				end
			end
		end
	end

	sanitizeTypeMeta(nil)
	sanitizeTypeMeta(true)
	sanitizeTypeMeta(0)
	sanitizeTypeMeta(function() end)
	sanitizeTypeMeta(coroutine.create(function() end))

	local string_library = SF.SafeStringLib
	local function sf_string_index(self, key)
		local val = string_library[key]
		if val then
			return val
		else
			local n = tonumber(key)
			if n then
				return string_library.sub(self, n, n)
			end
		end
	end
	sanitizeTypeMeta("", {__index = sf_string_index})
	
	if not (WireLib and WireLib.PatchedDuplicator) then
		if WireLib then WireLib.PatchedDuplicator = true end

		local localPos

		local oldSetLocalPos = duplicator.SetLocalPos
		function duplicator.SetLocalPos(pos, ...)
			localPos = pos
			return oldSetLocalPos(pos, ...)
		end

		local oldPaste = duplicator.Paste
		function duplicator.Paste(player, entityList, constraintList, ...)
			local result = { oldPaste(player, entityList, constraintList, ...) }
			local createdEntities, createdConstraints = result[1], result[2]
			local data = {
				EntityList = entityList, ConstraintList = constraintList,
				CreatedEntities = createdEntities, CreatedConstraints = createdConstraints,
				Player = player, HitPos = localPos,
			}
			hook.Run("AdvDupe_FinishPasting", {data}, 1)
			return unpack(result)
		end
	end
end)

local removedHooks = setmetatable({}, {__index=function(t,k) local r={} t[k]=r return r end})
hook.Add("EntityRemoved","SF_CallOnRemove",function(ent)
	local hooks = removedHooks[ent]
	if hooks then
		for k, v in pairs(hooks) do
			if v[1] then v[1](ent) end
		end
		if CLIENT then
			timer.Simple(0, function()
				if not IsValid(ent) then
					for k, v in pairs(hooks) do
						if v[2] then v[2](ent) end
					end
					removedHooks[ent] = nil
				end
			end)
		elseif SERVER then
			removedHooks[ent] = nil
		end
	end
end)
function SF.CallOnRemove(ent, key, func, deferedfunc)
	removedHooks[ent][key] = {func, deferedfunc}
end
function SF.RemoveCallOnRemove(ent, key)
	removedHooks[ent][key] = nil
	if next(removedHooks[ent])==nil then removedHooks[ent] = nil end
end

-------------------------------------------------------------------------------
-- Declare Basic Starfall Types
-------------------------------------------------------------------------------

-- Returns a class that manages a table of entity keys
function SF.EntityTable(key, destructor, dontwait)
	return setmetatable({}, {
		__newindex = function(t, e, v)
			rawset(t, e, v)
			if e ~= SF.Superuser then
				local function ondestroy()
					if t[e] then
						if destructor then destructor(e, v) end
						t[e] = nil
					end
				end
				if SERVER or dontwait then
					SF.CallOnRemove(e, key, ondestroy)
				else
					SF.CallOnRemove(e, key, nil, ondestroy)
				end
			end
		end
	})
end

--- Returns a class that wraps a structure and caches indexes
SF.StructWrapper = {
	__call = function(p, instance, data, name)
		local cache = {}
		return setmetatable({}, {
			__index = function(t, k)
				if cache[k] then
					return cache[k]
				else
					local ret = instance.WrapObject(data[k])
					cache[k] = ret
					return ret
				end
			end,
			__newindex = function(t, k, v)
				cache[k] = v
			end,
			__metatable = name,
			__tostring = function() return name end,
			__printtable = function()
				for k, v in pairs(data) do
					if not cache[k] then
						cache[k] = instance.WrapObject(v)
					end
				end
				return cache
			end,
		})
	end
}
setmetatable(SF.StructWrapper, SF.StructWrapper)

--- Returns a class that can manage burst objects
SF.BurstObject = {
	__index = {
		calc = function(self, obj)
			local ret = math.min(obj.val + (CurTime() - obj.lasttick) * self.rate, self.max)
			obj.lasttick = CurTime()
			return ret
		end,
		use = function(self, ply, amount)
			local obj = self:get(ply)
			local new = self:calc(obj) - amount
			if new < 0 and ply~=SF.Superuser then
				SF.Throw("The ".. self.name .." burst limit has been exceeded.", 3)
			end
			obj.val = new
		end,
		check = function(self, ply)
			local obj = self:get(ply)
			obj.val = self:calc(obj)
			return obj.val
		end,
		get = function(self, ply)
			if ply~=SF.Superuser and not IsValid(ply) then SF.Throw("Invalid starfall user", 4) end
			local obj = self.objects[ply]
			if not obj then
				obj = {
					val = self.max,
					lasttick = 0
				}
				self.objects[ply] = obj
			end
			return obj
		end,
	},
	__call = function(p, cvarname, limitname, rate, max, ratehelp, maxhelp, scale)
		scale = scale or 1

		local t = {
			name = limitname,
			objects = SF.EntityTable("burst"..cvarname)
		}

		local ratename = "sf_"..cvarname.."_burstrate"..(CLIENT and "_cl" or "")
		local ratecvar = CreateConVar(ratename, tostring(rate), FCVAR_ARCHIVE, ratehelp)
		t.rate = ratecvar:GetFloat()*scale
		cvars.AddChangeCallback(ratename, function() t.rate = ratecvar:GetFloat()*scale end)

		local maxname = "sf_"..cvarname.."_burstmax"..(CLIENT and "_cl" or "")
		local maxcvar = CreateConVar(maxname, tostring(max), FCVAR_ARCHIVE, maxhelp)
		t.max = maxcvar:GetFloat()*scale
		cvars.AddChangeCallback(maxname, function() t.max = maxcvar:GetFloat()*scale end)

		return setmetatable(t, p)
	end
}
setmetatable(SF.BurstObject, SF.BurstObject)

--- Returns a class that limits the number of something per player
SF.LimitObject = {
	__index = {
		use = function(self, ply, amount)
			if ply==SF.Superuser then return end
			if IsValid(ply) then
				local new = self.counters[ply] + amount
				if new > self.max then
					SF.Throw("The ".. self.name .." limit has been reached. (".. self.max ..")", 3)
				end
				self.counters[ply] = new
			else
				SF.Throw("Invalid starfall user", 3)
			end
		end,
		checkuse = function(self, ply, amount)
			if ply==SF.Superuser then return end
			if IsValid(ply) then
				if self.counters[ply] + amount > self.max then
					SF.Throw("The ".. self.name .." limit has been reached. (".. self.max ..")", 3)
				end
			else
				SF.Throw("Invalid starfall user", 3)
			end
		end,
		check = function(self, ply)
			if ply==SF.Superuser then return self.max end
			if IsValid(ply) then
				return self.max - self.counters[ply]
			else
				SF.Throw("Invalid starfall user", 3)
			end
		end,
		free = function(self, ply, amount)
			if ply==SF.Superuser then return end
			if IsValid(ply) then
				self.counters[ply] = math.Clamp(self.counters[ply] - amount, 0, self.max)
			end
		end,
		get = function(self, ply)
			if ply==SF.Superuser then return 0 end
			if IsValid(ply) then
				return self.counters[ply]
			else
				return 0
			end
		end,
	},
	__call = function(p, cvarname, limitname, max, maxhelp, scale)
		local t = {
			name = limitname,
			counters = SF.EntityTable("limit"..cvarname)
		}
		getmetatable(t.counters).__index = function(t,k) t[k]=0 return 0 end

		local maxname = "sf_"..cvarname.."_max"..(CLIENT and "_cl" or "")
		local maxcvar = CreateConVar(maxname, tostring(max), FCVAR_ARCHIVE, maxhelp)
		scale = scale or 1
		local function calcMax()
			t.max = maxcvar:GetFloat()*scale
			if t.max<0 then t.max = math.huge end
		end
		calcMax()
		cvars.AddChangeCallback(maxname, calcMax)

		return setmetatable(t, p)
	end
}
setmetatable(SF.LimitObject, SF.LimitObject)

--- Returns a class that handles entities spawned by an instance
SF.EntManager = {
	__index = {
		register = function(self, instance, ent, onremove)
			if not self.nocallonremove then
				local function sf_on_remove()
					self:onremove(instance, ent)
					if onremove then onremove() end
				end
				ent.sf_on_remove = sf_on_remove
				SF.CallOnRemove(ent, "entmanager", sf_on_remove)
			end

			self.entsByInstance[instance][ent] = true
			self:free(instance.player, -1)
		end,
		remove = function(self, instance, ent)
			-- ent:IsValid() used since not all types this class supports are entity
			if not (ent and ent:IsValid()) then return end
			if self.nocallonremove then
				self:onremove(instance, ent)
			else
				-- The die function is called the next frame after 'Remove' which is too slow so call it ourself
				SF.RemoveCallOnRemove(ent, "entmanager")
				ent.sf_on_remove()
			end
			ent:Remove()
		end,
		onremove = function(self, instance, ent)
			self.entsByInstance[instance][ent] = nil
			self:free(instance.player, 1)
		end,
		clear = function(self, instance)
			for ent in pairs(self.entsByInstance[instance]) do
				self:remove(instance, ent)
			end
		end,
		deinitialize = function(self, instance, shouldclear)
			if shouldclear then
				self:clear(instance)
			end
			self.entsByInstance[instance] = nil
		end
	},
	__call = function(p, cvarname, limitname, max, maxhelp, scale, nocallonremove)
		local t = SF.LimitObject(cvarname, limitname, max, maxhelp, scale)
		t.nocallonremove = nocallonremove or false
		t.entsByInstance = setmetatable({},{__index = function(t,k) local r = {} t[k]=r return r end})
		return setmetatable(t, p)
	end
}
setmetatable(SF.EntManager, SF.EntManager)
setmetatable(SF.EntManager.__index, SF.LimitObject)

--- Returns a class that can limit per player and recycle a indestructable resource
SF.ResourceHandler = {
	__index = {
		use = function(self, ply, key)
			if not key then key = 1 end
			self.limit:use(ply, 1)
			local obj = next(self.objects[key])
			if obj then
				self.objects[key][obj] = nil
			else
				self.n = self.n + 1
				obj = self.allocator(key, self.n)
			end
			if self.initializer then self.initializer(key, obj) end
			return obj
		end,
		check = function(self, ply)
			return self.limit:check(ply)
		end,
		free = function(self, ply, obj, key)
			if not key then key = 1 end
			if not self.objects[key][obj] then
				self.limit:free(ply, 1)
				self.objects[key][obj] = true
				if self.destructor then self.destructor(key, obj) end
			end
		end
	},
	__call = function(p, cvarname, limitname, max, maxhelp, allocator, initializer, destructor)
		local t = {
			n = 0,
			allocator = allocator,
			initializer = initializer,
			destructor = destructor,
			objects = setmetatable({}, {__index = function(t,k) local r={} t[k]=r return r end}),
			limit = SF.LimitObject(cvarname, limitname, max, maxhelp),
		}
		return setmetatable(t, p)
	end
}
setmetatable(SF.ResourceHandler, SF.ResourceHandler)


--- Returns a class that can whitelist/blacklist strings
SF.StringRestrictor = {
	__index = {
		check = function(self, value)
			for k,v in pairs(self.blacklist) do
				if string.match(value, v) then
					return false
				end
			end
			for k,v in pairs(self.whitelist) do
				if string.match(value, v) then
					return  true
				end
			end
			return self.default
		end,
		addWhitelistEntry = function(self, value)
			table.insert(self.whitelist, value)
		end,
		addBlacklistEntry = function(self, value)
			table.insert(self.blacklist, value)
		end
	},
	__call = function(p, allowbydefault)
		local t = {
			whitelist = {}, -- patterns
			blacklist = {}, -- patterns
			default = allowbydefault or false,
		}
		return setmetatable(t, p)
	end
}
setmetatable(SF.StringRestrictor, SF.StringRestrictor)

SF.NetValidator = {
	Players = {},
	__index = {
		receive = function(self)
			if net.ReadDouble() == self.validation then
				self.successes = self.successes + 1
				if self.successes == 5 then
					self.success()
					self:remove()
				end
			end
		end,
		tick = function(self)
			if IsValid(self.player) then
				self.validation = math.random()
				net.Start("starfall_net_validate")
				net.WriteDouble(self.validation)
				net.Send(self.player)
			else
				self:remove()
			end
		end,
		remove = function(self)
			SF.NetValidator.Players[self.player] = nil
			timer.Remove(self.timername)
		end
	},
	__call = function(p, ply, success)
		local t = setmetatable({
			player = ply,
			timername = "sf_net_validate"..ply:EntIndex(),
			successes = 0,
			success = success,
		}, p)
		SF.NetValidator.Players[ply] = t
		timer.Create(t.timername, 2, 0, function() t:tick() end)
	end
}
setmetatable(SF.NetValidator, SF.NetValidator)

if SERVER then
	util.AddNetworkString("starfall_net_validate")
	net.Receive("starfall_net_validate", function(len, ply)
		if SF.NetValidator.Players[ply] then
			SF.NetValidator.Players[ply]:receive()
		end
	end)
else
	net.Receive("starfall_net_validate", function()
		net.Start("starfall_net_validate")
		net.WriteDouble(net.ReadDouble())
		net.SendToServer()
	end)
end

local function steamIdToConsoleSafeName(steamid)
	local ply = player.GetBySteamID(steamid)
	return IsValid(ply) and string.gsub(ply:Nick(), '[%z\x01-\x1f\x7f;"\']', "") or ""
end

--- Returns a class that can keep a list of blocked users
SF.BlockedList = {
	__index = {
		toline = function(self, steamid, name)
			return steamid..","..name.."\n"
		end,
		block = function(self, steamid)
			if self.list[steamid] then return end
			local name = steamIdToConsoleSafeName(steamid)
			self.list[steamid] = name

			if self.filename then
				local f = file.Open(self.filename,"a","DATA")
				f:Write(self:toline(steamid, name))
				f:Close()
			end

			if self.onblock then
				self.onblock(steamid)
			end
		end,
		unblock = function(self, steamid)
			if not self.list[steamid] then return end
			self.list[steamid] = nil

			if self.filename then
				local f = file.Open(self.filename,"w","DATA")
				for steamid, name in pairs(self.list) do
					f:Write(self:toline(steamid, name))
				end
				f:Close()
			end

			if self.onunblock then
				self.onunblock(steamid)
			end
		end,
		isBlocked = function(self, steamid)
			return self.list[steamid] ~= nil
		end,
		readFile = function(self)
			local f = file.Open(self.filename,"r","DATA")
			if f then
				while not f:EndOfFile() do
					local steamid, name = string.match(f:ReadLine(), "([^,%s]+),?([^\n]*)")
					if steamid then
						self.list[steamid] = name
					end
				end
				f:Close()
			end
		end
	},
	__call = function(p, prefix, desc, filename, onblock, onunblock)
		local blocked = setmetatable({
			list = {},
			filename = filename,
			onblock = onblock,
			onunblock = onunblock
		}, p)

		if filename then
			blocked:readFile()
		end

		SF.SteamIDConcommand("sf_"..prefix.."_block", function(executor, id)
			blocked:block(id)
		end, "Block a user from " .. desc, false)

		SF.SteamIDConcommand("sf_"..prefix.."_unblock", function(executor, id)
			blocked:unblock(id)
		end, "Unblock a user from " .. desc, false,
		function(cmd)
			local tbl = {}
			for steamid, name in pairs(blocked.list) do
				table.insert(tbl, cmd.." \""..steamid.."\" // \""..name.."\"")
			end
			return tbl
		end)

		concommand.Add("sf_"..prefix.."_blocklist", function(executor, cmd, args)
			local n = 0
			for steamid, name in pairs(blocked.list) do
				print("\""..steamid.."\" // \""..name.."\"")
				n = n + 1
			end
			print("You have blocked "..n.." players from "..desc)
		end, nil, "List players you have blocked from " .. desc)

		return blocked
	end
}
setmetatable(SF.BlockedList, SF.BlockedList)


SF.Parent = {
	__index = {
		updateTransform = function(self)
			self.pos, self.ang = WorldToLocal(self.ent:GetPos(), self.ent:GetAngles(), self.parent:GetPos(), self.parent:GetAngles())
		end,

		applyTransform = function(self)
			local pos, ang = LocalToWorld(self.pos, self.ang, self.parent:GetPos(), self.parent:GetAngles())
			self.ent:SetPos(pos)
			self.ent:SetAngles(ang)
		end,
		
		parentTypes = {
			entity = {
				function(self)
					self.ent:SetParent(self.parent)
				end,
				function(self)
					local ent = self.ent
					ent:SetParent()
					ent:SetLocalVelocity(ent.targetLocalVelocity or vector_origin)
				end
			},
			attachment = {
				function(self)
					self.ent:SetParent(self.parent)
					self.ent:Fire("SetParentAttachmentMaintainOffset", self.param, 0.01)
				end,
				function(self)
					self.ent:SetParent()
				end
			},
			bone = {
				function(self)
					self.ent:FollowBone(self.parent, self.param)
				end,
				function(self)
					local ent = self.ent
					ent:FollowBone(NULL, 0)
					ent:SetLocalVelocity(ent.targetLocalVelocity or vector_origin)
				end
			}
		},

		setParent = function(self, parent, type, param)
			if IsValid(self.parent) then
				self.parent.sfParent.children[self.ent] = nil
				self:removeParent()
			end
			if parent then
				self.parent = parent
				self.param = param
				self.applyParent, self.removeParent = unpack(self.parentTypes[type])

				parent.sfParent.children[self.ent] = self
				self:updateTransform()
				self:applyParent()
			else
				self.parent = nil
				self.param = nil
				self.applyParent = nil
				self.removeParent = nil
			end
		end,

		fix = function(self)
			local cleanup = true
			if IsValid(self.parent) then
				cleanup = false
			end
			for child, data in pairs(self.children) do
				if IsValid(child) then
					data:applyTransform()
					data:applyParent()
					cleanup = false
					
					if child.sfParent then
						child.sfParent:fix()
					end
				else
					self.children[child] = nil
				end
			end
			if cleanup then
				self.ent.sfParent = nil
			end
		end,
	},

	__call = function(meta, child, parent, type, param)
		if parent then
			if SF.ParentChainTooLong(parent, child) then SF.Throw("Parenting chain cannot exceed 16 or crash may occur", 3) end

			if not parent.sfParent then
				parent.sfParent = setmetatable({
					ent = parent,
					children = {}
				}, meta)
			end

			local sfParent = child.sfParent
			if not sfParent then
				sfParent = setmetatable({
					ent = child,
					children = {}
				}, meta)
				child.sfParent = sfParent
			end

			sfParent:setParent(parent, type, param)
		elseif child.sfParent then
			child.sfParent:setParent()
		else
			child:SetParent()
		end
	end
}
setmetatable(SF.Parent, SF.Parent)

if CLIENT then
	-- When parent is retransmitted, it loses it's children
	hook.Add("NotifyShouldTransmit", "SF_HologramParentFix", function(ent)
		local sfParent = ent.sfParent
		if sfParent then sfParent:fix() end
	end)
end

SF.RenderStack = {
	__index = {
		create = function(self, data)
			return setmetatable({
				run = self.runDirty,
				data = data,
			}, self.objindex)
		end,

		runDirty = function(self, flags)
			local pushes = {self.maincode[1]}
			local pops = {self.maincode[3]}
			for _, v in ipairs(self.properties) do
				pushes[#pushes+1], pops[#pops+1] = v(self.data)
			end

			local code = {}
			for i=1, #pushes do
				code[#code + 1] = pushes[i]
			end
			code[#code + 1] = self.maincode[2]
			for i=#pops, 1, -1 do
				code[#code + 1] = pops[i]
			end

			self.renderfunc = CompileString(table.concat(code, " "), "RenderStack")()
			self.run = self.runClean
			self:run(flags)
		end,

		runClean = function(self, flags)
			self.renderfunc(self.data, flags)
		end,

		makeDirty = function(self)
			self.run = self.runDirty
		end,
	},
	__call = function(p, maincode, properties)
		local ret = setmetatable({
			maincode = maincode,
			properties = properties
		}, p)
		ret.objindex = {__index = ret}
		return ret
	end
}
setmetatable(SF.RenderStack, SF.RenderStack)


-- Error type containing error info
SF.Errormeta = {
	__tostring = function(t) return t.message end,
	__metatable = "SFError"
}


--- Builds an error type to that contains line numbers, file name, and traceback
-- @param msg Message
-- @param level Which level in the stacktrace to blame
-- @param uncatchable Makes this exception uncatchable
-- @param prependinfo The error message needs file and line number info
-- @param userdata User's own error data that starfall's pcall will return if it exists
function SF.MakeError(msg, level, uncatchable, prependinfo, userdata)
	level = 1 + (level or 1)
	local info = debug.getinfo(level, "Sl")
	if not info then
		info = { short_src = "", currentline = 0 }
		prependinfo = false
	end
	if not isstring(msg) then msg = "(error object is not a string)" end

	local traceback = debug.traceback("", level)
	local lines = {}
	for v in string.gmatch(traceback, "[^\n]+") do
		if string.find(v, "[C]: in function 'xpcall'", 1, true) then break end
		lines[#lines+1] = v
	end
	traceback = table.concat(lines, "\n")

	return setmetatable({
		uncatchable = false,
		file = info.short_src,
		line = info.currentline,
		message = prependinfo and (info.short_src..":"..info.currentline..": "..msg) or msg,
		uncatchable = uncatchable,
		traceback = traceback,
		userdata = userdata
	}, SF.Errormeta)
end

function SF.GetLines(str)
	local current_pos = 1
	local lineN = 0
	return function()
		local start_pos, end_pos = string.find( str, "\r?\n", current_pos )
		if start_pos then
			local ret = string.sub( str, current_pos, start_pos - 1 )
			current_pos = end_pos + 1
			lineN = lineN + 1
			return lineN, ret
		else
			return nil
		end
	end
end

-------------------------------------------------------------------------------
-- Starfall instance hook management
-------------------------------------------------------------------------------

do
	local registered_instances = {}
	local gmod_hooks = {}

	local function getHookFunc(instances, hookname, customargfunc, customretfunc)
		--- There are 4 varients of hookfunc depending on if there are custom callbacks
		if customargfunc then
			if customretfunc then
				return function(...)
					local result
					for instance, _ in pairs(instances) do
						local canrun, customargs = customargfunc(instance, ...)
						if canrun then
							local tbl = instance:runScriptHookForResult(hookname, unpack(customargs))
							local sane = {customretfunc(instance, tbl, ...)}
							if #sane > 0 then result = sane end
						end
					end
					if result then
						return unpack(result)
					end
				end
			else
				return function(...)
					for instance, _ in pairs(instances) do
						local canrun, customargs = customargfunc(instance, ...)
						if canrun then
							instance:runScriptHook(hookname, unpack(customargs))
						end
					end
				end
			end
		else
			if customretfunc then
				return function(...)
					local result
					for instance, _ in pairs(instances) do
						local tbl = instance:runScriptHookForResult(hookname, unpack(instance.Sanitize({...})))
						local sane = {customretfunc(instance, tbl, ...)}
						if #sane > 0 then result = sane end
					end
					if result then
						return unpack(result)
					end
				end
			else
				return function(...)
					for instance, _ in pairs(instances) do
						instance:runScriptHook(hookname, unpack(instance.Sanitize({...})))
					end
				end
			end
		end
	end

	--- Returns a class that can manage hooks. Required because adding to a table being iterated with pairs is undefined behavior.
	SF.HookTable = {
		__index = {
			add = function(self, index, func)
				if not (self.hooks[index] or self.hookstoadd[index]) or self.hookstoremove[index] then
					if self.n>=128 then SF.Throw("Max hooks limit reached", 3) end
					self.n = self.n + 1
					self.hookstoremove[index] = nil
				end
				self.hookstoadd[index] = func
				self.pairs = self.dirtyPairs
			end,
			remove = function(self, index)
				if (self.hooks[index] or self.hookstoadd[index]) and not self.hookstoremove[index] then
					self.n = self.n - 1
					self.hookstoadd[index] = nil
					self.hookstoremove[index] = true
					self.pairs = self.dirtyPairs
				end
			end,
			exists = function(self, index)
				return self.hooks[index]~=nil or self.hookstoadd[index]~=nil
			end,
			isEmpty = function(self)
				return self.n==0
			end,
			dirtyPairs = function(self)
				for k, v in pairs(self.hookstoremove) do
					self.hooks[k] = nil
					self.hookstoremove[k] = nil
				end
				for k, v in pairs(self.hookstoadd) do
					self.hooks[k] = v
					self.hookstoadd[k] = nil
				end
				self.pairs = self.cleanPairs
				return pairs(self.hooks)
			end,
			cleanPairs = function(self)
				return pairs(self.hooks)
			end,
			run = function(self, instance, ...)
				for _, v in self:pairs() do
					instance:runFunction(v, ...)
				end
			end
		},
		__call = function(p)
			return setmetatable({
				hooks = {},
				hookstoadd = {},
				hookstoremove = {},
				n = 0,
				pairs = p.cleanPairs
			}, p)
		end
	}
	setmetatable(SF.HookTable, SF.HookTable)

	--- Add a GMod hook so that SF gets access to it
	-- @shared
	-- @param hookname The hook name. In-SF hookname will be lowercased
	-- @param customargfunc Optional custom function
	-- Returns true if the hook should be called, then extra arguements to be passed to the starfall hooks
	-- @param customretfunc Optional custom function
	-- Takes values returned from starfall hook and returns what should be passed to the gmod hook
	-- @param gmoverride Whether this hook should override the gamemode function (makes the hook run last, but adds a little overhead)
	function SF.hookAdd(realname, hookname, customargfunc, customretfunc, gmoverride)
		hookname = hookname or realname:lower()
		registered_instances[hookname] = {}
		if gmoverride then
			local function override(again)
				local hookfunc = getHookFunc(registered_instances[hookname], hookname, customargfunc, customretfunc)

				local gmfunc
				if again then
					gmfunc = GAMEMODE["SF"..realname]
				else
					gmfunc = GAMEMODE[realname]
					GAMEMODE["SF"..realname] = gmfunc
				end

				if gmfunc then
					GAMEMODE[realname] = function(gm, ...)
						local a,b,c,d,e,f = hookfunc(...)
						if a~= nil then return a,b,c,d,e,f
						else return gmfunc(gm, ...) end
					end
				else
					GAMEMODE[realname] = function(gm, ...)
						return hookfunc(...)
					end
				end
			end
			if GAMEMODE then
				override(true)
			else
				hook.Add("Initialize", "SF_Hook_Override"..hookname, override)
			end
		else
			gmod_hooks[hookname] = { realname, customargfunc, customretfunc }
		end
	end

	function SF.HookAddInstance(instance, hookname)
		local instances = registered_instances[hookname]
		if instances then
			if next(instances)==nil then
				local gmod_hook = gmod_hooks[hookname]
				if gmod_hook then
					local realname, customargfunc, customretfunc = unpack(gmod_hook)
					local hookfunc = getHookFunc(instances, hookname, customargfunc, customretfunc)
					hook.Add(realname, "SF_Hook_"..hookname, hookfunc)
				end
			end
			instances[instance] = true
		end
	end
	
	function SF.HookRemoveInstance(instance, hookname)
		local instances = registered_instances[hookname]
		if instances and instances[instance] then
			instances[instance] = nil
			if not next(instances) then
				local gmod_hook = gmod_hooks[hookname]
				if gmod_hook then
					hook.Remove(gmod_hook[1], "SF_Hook_" .. hookname)
				end
			end
		end
	end

	function SF.HookDestroyInstance(instance)
		for hookname, instances in pairs(registered_instances) do
			if instances[instance] then
				instances[instance] = nil
				if not next(instances) then
					local gmod_hook = gmod_hooks[hookname]
					if gmod_hook then
						hook.Remove(gmod_hook[1], "SF_Hook_" .. hookname)
					end
				end
			end
		end
	end
end


-------------------------------------------------------------------------------
-- Utility functions
-------------------------------------------------------------------------------

function SF.SteamIDConcommand(name, callback, helptext, findplayer, completionlist)
	concommand.Add(name, function(executor, cmd, arg)
		local retval = arg[1]
		if not retval then
			executor:PrintMessage( HUD_PRINTCONSOLE, "Missing steam id\n" )
			return
		end
		if not string.match(retval, "%D") then
			retval = util.SteamIDFrom64(retval) or ""
		end
		if not string.match(retval, "^STEAM_") then
			executor:PrintMessage( HUD_PRINTCONSOLE, "Invalid steam id\n" )
			return
		end
		if findplayer then
			retval = player.GetBySteamID( retval )
			if not retval then
				executor:PrintMessage( HUD_PRINTCONSOLE, "Player not found\n" )
				return
			end
		end

		callback(executor, retval)

	end, completionlist or function(cmd)
		local tbl = {}
		for _, ply in pairs(player.GetHumans()) do
			local steamid = ply:SteamID()
			table.insert(tbl, cmd.." \""..steamid.."\" // \""..steamIdToConsoleSafeName(steamid).."\"")
		end
		return tbl
	end, helptext)
end

--- Require .dll but doesn't throw an error. Returns true if success or false if fail.
function SF.Require(moduleName)
	local realmPrefix = SERVER and "sv" or "cl"
	local osSuffix
	if system.IsWindows() then
		osSuffix = (jit.arch~="x64" and "win32" or "win64")
	elseif system.IsLinux() then
		osSuffix = (jit.arch~="x64" and "linux" or "linux64")
	elseif system.IsOSX() then 
		osSuffix = (jit.arch~="x64" and "osx" or "osx64")
	else
		error("couldn't determine system type?")
	end

	if file.Exists("lua/bin/gm"..realmPrefix.."_"..moduleName.."_"..osSuffix..".dll", "GAME") then
		local ok, err = pcall(require, moduleName)
		if ok then
			return true
		else
			ErrorNoHalt(err)
			return false
		end
	end
	return false
end

--- Compile String but fix a compile error.
function SF.CompileString(script, identifier, handle_error)
	if string.match(script, "%f[%w_]repeat%f[^%w_].*%f[%w_]continue%f[^%w_].*%f[%w_]until%f[^%w_]") then
		return "Using 'continue' in a repeat-until loop has been banned due to a glua bug."
	end
	return CompileString(script, identifier, handle_error)
end

--- The safest write file function
function SF.FileWrite(path, data)
	path = SF.NormalizePath(path)
	file.CreateDir(string.GetPathFromFilename( path ))
	file.Write(path, data)
	return file.Read(path)==data
end

function SF.DeleteFolder(folder)
	local folders = {folder}
	while #folders > 0 do
		local folder = folders[#folders]
		local files, directories = file.Find(folder.."/*", "DATA")
		for I = 1, #files do
			file.Delete(folder .. "/" .. files[I])
		end
		if #directories == 0 then
			file.Delete(folder)
			folders[#folders] = nil
		else
			for I = 1, #directories do
				folders[#folders + 1] = folder .. "/" .. directories[I]
			end
		end
	end
end

--- Throws an error like the throw function in builtins
-- @param msg Message
-- @param level Which level in the stacktrace to blame
-- @param uncatchable Makes this exception uncatchable
function SF.Throw(msg, level, uncatchable, userdata)
	local level = 1 + (level or 1)
	error(SF.MakeError(msg, level, uncatchable, true, userdata), level)
end

--- Throws a type error
-- @param expected The expected type name
-- @param got The type name that was provided
-- @param level The stack level
-- @param msg Optional error message
function SF.ThrowTypeError(expected, got, level, msg)
	local level = 1 + (level or 1)
	local funcname = debug.getinfo(level-1, "n").name or "<unnamed>"
	SF.Throw((msg and #msg>0 and (msg .. " ") or "") .. "Type mismatch (Expected " .. expected .. ", got " .. got .. ") in function " .. funcname, level)
end

--- Lookup table of TYPE > name
SF.TYPENAME = {
	[TYPE_NONE]             = "Invalid type",
	[TYPE_NIL]              = "nil",
	[TYPE_BOOL]             = "boolean",
	[TYPE_LIGHTUSERDATA]    = "light userdata",
	[TYPE_NUMBER]           = "number",
	[TYPE_STRING]           = "string",
	[TYPE_TABLE]            = "table",
	[TYPE_FUNCTION]         = "function",
	[TYPE_USERDATA]         = "userdata",
	[TYPE_THREAD]           = "thread",
	[TYPE_ENTITY]           = "Entity",
	[TYPE_VECTOR]           = "Vector",
	[TYPE_ANGLE]            = "Angle",
	[TYPE_PHYSOBJ]          = "PhysObj",
	[TYPE_SAVE]             = "ISave",
	[TYPE_RESTORE]          = "IRestore",
	[TYPE_DAMAGEINFO]       = "CTakeDamageInfo",
	[TYPE_EFFECTDATA]       = "CEffectData",
	[TYPE_RECIPIENTFILTER]  = "CUserCmd",
	[TYPE_SCRIPTEDVEHICLE]  = "ScriptedVehicle", -- Depricated, also TYPE Enum doesnt specify the name so this it is
	[TYPE_MATERIAL]         = "IMaterial",
	[TYPE_PANEL]            = "Panel",
	[TYPE_PARTICLE]         = "CLuaParticle",
	[TYPE_PARTICLEEMITTER]  = "CLuaEmitter",
	[TYPE_TEXTURE]          = "ITexture",
	[TYPE_USERMSG]          = "bf_read",
	[TYPE_CONVAR]           = "ConVar",
	[TYPE_IMESH]            = "IMesh",
	[TYPE_MATRIX]           = "VMatrix",
	[TYPE_SOUND]            = "CSoundPatch",
	[TYPE_PIXELVISHANDLE]   = "pixelvis_handle_t",
	[TYPE_DLIGHT]           = "dlight_t",
	[TYPE_VIDEO]            = "IVideoWriter",
	[TYPE_FILE]             = "File",
	[TYPE_LOCOMOTION]       = "CLuaLocomotion",
	[TYPE_PATH]             = "PathFollower",
	[TYPE_NAVAREA]          = "CNavArea",
	[TYPE_SOUNDHANDLE]      = "IGModAudioChannel",
	[TYPE_NAVLADDER]        = "CNavLadder",
	[TYPE_PARTICLESYSTEM]   = "CNewParticleEffect",
	[TYPE_PROJECTEDTEXTURE] = "ProjectedTexture",
	[TYPE_PHYSCOLLIDE]      = "PhysCollide",
	[TYPE_SURFACEINFO]      = "SurfaceInfo",
	[TYPE_COLOR]            = "Color" -- TypeID doesnt return this but lets still add it
}

--- Returns corresponding name of the TypeID
-- @param typeid The TYPE
-- @return String name
function SF.TypeName(typeid)
	return assert(SF.TYPENAME[typeid], "Type not defined")
end

--- Checks the lua type of val. Errors if the types don't match
-- @param val The value to be checked.
-- @param typ A string type or metatable.
-- @param level Level at which to error at. 2 is added to this value. Default is 1.
-- @param msg Optional error message
function SF.CheckLuaType(val, typ, level, msg)
	if TypeID(val) ~= typ then
		assert(isnumber(typ))
		level = (level or 1) + 2
		SF.ThrowTypeError(SF.TypeName(typ), SF.GetType(val), level, msg)
	end
end

--- Checks that the value is a non-nan number
-- @param val The value to be checked.
-- @param level Level at which to error at. 2 is added to this value. Default is 1.
-- @param msg Optional error message
function SF.CheckValidNumber(val, level, msg)
	if TypeID(val) ~= TYPE_NUMBER then SF.ThrowTypeError(SF.TypeName(TYPE_NUMBER), SF.GetType(val), (level or 1) + 2, msg) end
	if val ~= val then SF.Throw((msg and #msg>0 and (msg .. " ") or "") .. "Input number is nan!", (level or 1) + 2) end
end

function SF.EntIsReady(ent)
	if ent:IsWorld() then return true end
	if not IsValid(ent) then return false end

	-- https://github.com/Facepunch/garrysmod-issues/issues/3127
	local class = ent:GetClass()
	if class=="player" then
		return ent:IsPlayer()
	elseif class=="starfall_processor" then
		return ent.Compile~=nil
	elseif class=="starfall_hologram" then
		return ent.SetClip~=nil
	elseif class=="starfall_prop" then
		return ent.BuildPhysics~=nil
	elseif class=="starfall_screen" or class=="starfall_hud" then
		return ent:IsScripted()
	else
		return true
	end
end

local waitingConditions = {}
function SF.WaitForConditions(callback, timeoutcallback, timeout)
	if not callback() then
		if #waitingConditions == 0 then
			hook.Add("Think", "SF_WaitingForConditions", function()
				local time = CurTime()
				local i = 1
				while i <= #waitingConditions do
					local v = waitingConditions[i]
					if v.callback() then
						table.remove(waitingConditions, i)
					elseif time>v.timeout then
						if v.timeoutcallback then v.timeoutcallback() end
						table.remove(waitingConditions, i)
					else
						i = i + 1
					end
				end
				if #waitingConditions == 0 then hook.Remove("Think", "SF_WaitingForConditions") end
			end)
		end
		waitingConditions[#waitingConditions+1] = {callback = callback, timeoutcallback = timeoutcallback, timeout = CurTime()+timeout}
	end
end

function SF.WaitForEntity(index, creationIndex, callback)
	SF.WaitForConditions(function()
		local ent=Entity(index)
		if SF.EntIsReady(ent) and ent:GetCreationID()==creationIndex then
			ProtectedCall(callback, ent)
			return true
		end
	end, callback, 10)
end


local playerinithooks = {}
hook.Add("PlayerInitialSpawn","SF_PlayerInitialize",function(ply)
	SF.NetValidator(ply, function()
		for _, v in ipairs(playerinithooks) do v(ply) end
	end)
end)
function SF.WaitForPlayerInit(func)
	playerinithooks[#playerinithooks+1] = func
end

-- Table networking
do
	local TYPE_TABLEREF = 50
	local TYPE_TABLESEQ = 51
	local TYPE_TABLEHASH = 52
	local TYPE_NUMBER8 = 53
	local TYPE_NUMBER8NEG = 54
	local TYPE_NUMBER16 = 55
	local TYPE_NUMBER16NEG = 56
	local TYPE_NUMBER32 = 57
	local TYPE_NUMBER32NEG = 58
	
	local pairs_, instance_, tableLoopupCtr, tableLookup, ss

	local typetostringfuncs = {}
	local function typeToString(val)
		typetostringfuncs[TypeID(val)](val)
	end

	local function errorType(x) error("Invalid type " .. SF.GetType(x)) end
	for i=0, 255 do typetostringfuncs[i] = errorType end
	typetostringfuncs[TYPE_NUMBER] = function(x)
		if math.floor(x)==x then
			local typeoffset
			if x<0 then typeoffset = 1 x = -x else typeoffset = 0 end
			if x<0x100 then ss:writeInt8(TYPE_NUMBER8 + typeoffset) ss:writeInt8(x)
			elseif x<0x10000 then ss:writeInt8(TYPE_NUMBER16 + typeoffset) ss:writeInt16(x)
			elseif x<0x100000000 then ss:writeInt8(TYPE_NUMBER32 + typeoffset) ss:writeInt32(x)
			else ss:writeInt8(TYPE_NUMBER) ss:writeDouble(x)
			end
		else
			ss:writeInt8(TYPE_NUMBER) ss:writeDouble(x)
		end
	end
	typetostringfuncs[TYPE_STRING] = function(x) ss:writeInt8(TYPE_STRING) ss:writeInt32(#x) ss:write(x) end
	typetostringfuncs[TYPE_BOOL] = function(x) ss:writeInt8(TYPE_BOOL) ss:writeInt8(x and 1 or 0) end
	typetostringfuncs[TYPE_ENTITY] = function(x) ss:writeInt8(TYPE_ENTITY) ss:writeInt16(x:EntIndex()) end
	typetostringfuncs[TYPE_VECTOR] = function(x) ss:writeInt8(TYPE_VECTOR) for i=1, 3 do ss:writeFloat(x[i]) end end
	typetostringfuncs[TYPE_ANGLE] = function(x) ss:writeInt8(TYPE_ANGLE) for i=1, 3 do ss:writeFloat(x[i]) end end
	typetostringfuncs[TYPE_COLOR] = function(x) ss:writeInt8(TYPE_COLOR) ss:writeInt8(x.r) ss:writeInt8(x.g) ss:writeInt8(x.b) ss:writeInt8(x.a) end
	typetostringfuncs[TYPE_MATRIX] = function(x) ss:writeInt8(TYPE_MATRIX) for k, v in ipairs{x:Unpack()} do ss:writeFloat(v) end end
	typetostringfuncs[TYPE_TABLE] = function(val)
		if instance_ then
			local unwrapped = instance_.UnwrapObject(val)
			if unwrapped then return typeToString(unwrapped) end
		end

		if IsColor(val) then return typetostringfuncs[TYPE_COLOR](val) end

		local lookup = tableLookup[val]
		if lookup then
			ss:writeInt8(TYPE_TABLEREF)
			ss:writeInt32(lookup)
			return
		end
		tableLookup[val] = tableLoopupCtr
		tableLoopupCtr = tableLoopupCtr + 1

		local nseq = 1
		local nhash = 0
		for key, value in pairs(val) do
			if key==nseq then nseq = nseq + 1
			else nhash = nhash + 1
			end
		end

		if nseq>1 then
			if nhash>0 then
				ss:writeInt8(TYPE_TABLE)
				ss:writeInt32(nseq - 1)
				for i=1, nseq-1 do
					typeToString(val[i])
				end
				nseq = 1
				ss:writeInt32(nhash)
				for key, value in pairs_(val) do
					if key==nseq then nseq = nseq + 1 else
						typeToString(key)
						typeToString(value)
					end
				end
			else
				ss:writeInt8(TYPE_TABLESEQ)
				ss:writeInt32(nseq - 1)
				for i=1, nseq-1 do
					typeToString(val[i])
				end
			end
		else
			if nhash>0 then
				ss:writeInt8(TYPE_TABLEHASH)
				nseq = 1
				ss:writeInt32(nhash)
				for key, value in pairs_(val) do
					if key==nseq then nseq = nseq + 1 else
						typeToString(key)
						typeToString(value)
					end
				end
			else
				ss:writeInt8(TYPE_TABLESEQ)
				ss:writeInt32(0)
			end
		end
	end

	local stringtotypefuncs = {}
	local stringToType

	local function errorType() error("Invalid type while decoding!") end
	for i=0, 255 do stringtotypefuncs[i] = errorType end
	stringtotypefuncs[TYPE_NUMBER] = function() return ss:readDouble() end
	stringtotypefuncs[TYPE_STRING] = function() return ss:read(ss:readUInt32()) end
	stringtotypefuncs[TYPE_BOOL] = function() return ss:readUInt8() == 1 end
	stringtotypefuncs[TYPE_ENTITY] = function() return Entity(ss:readUInt16()) end
	stringtotypefuncs[TYPE_VECTOR] = function() return Vector(ss:readFloat(), ss:readFloat(), ss:readFloat()) end
	stringtotypefuncs[TYPE_ANGLE] = function() return Angle(ss:readFloat(), ss:readFloat(), ss:readFloat()) end
	stringtotypefuncs[TYPE_COLOR] = function() return Color(ss:readUInt8(), ss:readUInt8(), ss:readUInt8(), ss:readUInt8()) end
	stringtotypefuncs[TYPE_MATRIX] = function()
		local t = {} for i=1, 16 do t[i] = ss:readFloat() end
		local m = Matrix() m:SetUnpacked(unpack(t))
		return m
	end
	stringtotypefuncs[TYPE_TABLE] = function()
		local t = {}
		for i=1, ss:readUInt32() do
			t[i] = stringToType()
		end
		for i=1, ss:readUInt32() do
			local key, val = stringToType(), stringToType()
			t[key] = val
		end
		tableLookup[#tableLookup + 1] = t
		return t
	end
	stringtotypefuncs[TYPE_TABLEREF] = function()
		return tableLookup[ss:readUInt32()]
	end
	stringtotypefuncs[TYPE_TABLESEQ] = function()
		local t = {}
		for i=1, ss:readUInt32() do
			t[i] = stringToType()
		end
		tableLookup[#tableLookup + 1] = t
		return t
	end
	stringtotypefuncs[TYPE_TABLEHASH] = function()
		local t = {}
		for i=1, ss:readUInt32() do
			local key, val = stringToType(), stringToType()
			t[key] = val
		end
		tableLookup[#tableLookup + 1] = t
		return t
	end
	stringtotypefuncs[TYPE_NUMBER8] = function() return ss:readUInt8() end
	stringtotypefuncs[TYPE_NUMBER8NEG] = function() return -ss:readUInt8() end
	stringtotypefuncs[TYPE_NUMBER16] = function() return ss:readUInt16() end
	stringtotypefuncs[TYPE_NUMBER16NEG] = function() return -ss:readUInt16() end
	stringtotypefuncs[TYPE_NUMBER32] = function() return ss:readUInt32() end
	stringtotypefuncs[TYPE_NUMBER32NEG] = function() return -ss:readUInt32() end
	
	--- Convert table to string data.
	-- Only works with strings, numbers, tables, bools, 
	function SF.TableToString(tbl, instance, sorted)
		pairs_ = sorted and SortedPairs or pairs
		instance_ = instance
		tableLoopupCtr = 1
		tableLookup = {}
		ss = SF.StringStream()

		typeToString(tbl)

		local ret = ss:getString()
		tableLookup = nil
		ss = nil
		return ret
	end

	--- Convert string data to table
	function SF.StringToTable(str, instance)
		instance_ = instance
		tableLookup = {}
		ss = SF.StringStream(str)

		if instance then
			function stringToType()
				local val = stringtotypefuncs[ss:readUInt8()]()
				return instance.WrapObject(val) or val
			end
		else
			function stringToType()
				return stringtotypefuncs[ss:readUInt8()]()
			end
		end

		local ret = stringToType()
		tableLookup = nil
		ss = nil
		return ret
	end
end

--- Gets the type of val.
-- @param val The value to be checked.
function SF.GetType(val)
	local meta = dgetmeta(val)
	return meta and isstring(meta.__metatable) and meta.__metatable or type(val)
end

local shaderBlacklist = {
	["LightmappedGeneric"] = true,
}
local materialBlacklist = {
	["pp/copy"] = true,
	["debug/debugluxels"] = true,
	["effects/ar2_altfire1"] = true,
}
SF.allowedRenderGroups = {
	[RENDERGROUP_OPAQUE]=true,
	[RENDERGROUP_TRANSLUCENT]=true,
	[RENDERGROUP_BOTH]=true,
	[RENDERGROUP_VIEWMODEL]=true,
	[RENDERGROUP_VIEWMODEL_TRANSLUCENT]=true,
	[RENDERGROUP_OPAQUE_BRUSH]=true,
}

--- Checks that the material isn't malicious
-- @param Material The path to the material
-- @return The material object or false if it's invalid
function SF.CheckMaterial(material)
	if material == "" then return end
	if #material > 260 then return false end
	material = string.StripExtension(SF.NormalizePath(string.lower(material)))
	if materialBlacklist[material] then return false end
	local mat = Material(material)
	if shaderBlacklist[mat:GetShader() or ""] then return false end
	return mat
end

function SF.CheckModel(model, player, prop)
	if #model > 260 then SF.Throw("Model path too long!", 3) end
	model = SF.NormalizePath(string.lower(model))
	if string.GetExtensionFromFilename(model) ~= "mdl" or (SERVER and (not util.IsValidModel(model) or (prop and not util.IsValidProp(model)))) then SF.Throw("Invalid model: "..model, 3) end
	if player~=SF.Superuser and hook.Run("PlayerSpawnObject", player, model)==false then SF.Throw("Not allowed to use model: "..model, 3) end
	return model
end

SF.UniqueSounds = setmetatable({}, {__index=function(t,k) local r={[1]=0} t[k]=r return r end})
local maxUniqueSounds = CreateConVar("sf_sounds_unique_max"..(CLIENT and "_cl" or ""), "200", FCVAR_ARCHIVE, "The maximum number of unique sounds paths allowed")

function SF.CheckSound(ply, path)
	-- Limit length and remove invalid chars
	if #path>260 then SF.Throw("Sound path too long!", 3) end
	if string.match(path, "[\"?']") then SF.Throw("Sound path contains invalid characters!", 3) end

	-- Extract sound flags. Only allowed flags are '@' '#' '<', '>', '^', ')'
	local flags, checkpath = string.match(path, "^([^%w_/%.]*)(.*)")
	if #flags>2 or string.match(flags, "[^@#<>%^%)]") then
		SF.Throw("Invalid sound flags! "..flags, 3)
	end

	local UserUniqueSounds = SF.UniqueSounds[ply:SteamID()]
	if not UserUniqueSounds[checkpath] then
		if UserUniqueSounds[1] >= maxUniqueSounds:GetInt() then
			SF.Throw("The unique sounds limit has been reached.", 3)
		end
		UserUniqueSounds[checkpath] = true
		UserUniqueSounds[1] = UserUniqueSounds[1] + 1
	end
end

function SF.CheckRagdoll(model)
	if #model > 260 then return false end
	model = SF.NormalizePath(string.lower(model))
	if util.IsValidRagdoll(model) then
		return model
	end
	return false
end

local drawEntityClasses = {
	["starfall_prop"] = true,
	["prop_physics"] = true,
	["prop_ragdoll"] = true,
	["prop_vehicle_jeep"] = true,
	["prop_vehicle_airboat"] = true,
	["prop_vehicle_prisoner_pod"] = true,
}
function SF.CanDrawEntity(ent)
	return drawEntityClasses[ent:GetClass()] and not IsValid(ent:GetParent()) and ent.RenderOverride==nil
end

--- Chooses whether to use absolute or relative path
function SF.ChoosePath(path, curpath, testfunc)
	if string.sub(path, 1, 1)=="/" then
		path = SF.NormalizePath(path)
		if testfunc(path) then return path end
	else
		local relativepath = SF.NormalizePath(curpath .. path)
		if testfunc(relativepath) then
			return relativepath
		else
			path = SF.NormalizePath(path)
			if testfunc(path) then return path end
		end
	end
end

--- Returns a path with all .. accounted for
function SF.NormalizePath(path)
	local null = string.find(path, "\x00", 1, true)
	if null then path = string.sub(path, 1, null-1) end

	local pathtbl = {}
	for s in string.gmatch(path, "[^/\\]+") do
		if s ~= "." and s~="" then
			if s == ".." then
				pathtbl[#pathtbl] = nil
			else
				pathtbl[#pathtbl + 1] = s
			end
		end
	end
	return table.concat(pathtbl, "/")
end

function SF.GetExecutingPath()
	local curdir
	local stackLevel = 3
	repeat
		local info = debug.getinfo(stackLevel, "S")
		if not info then break end

		curdir = string.match(info.short_src, "^SF:(.*)")
		stackLevel = stackLevel + 1
	until curdir
	return curdir
end

--- Returns True if parent chain length is going to exceed 16. Also check for cyclic parenting
function SF.ParentChainTooLong(parent, child)
	local index = parent
	local parentLength = 0
	while IsValid(index) do
		if index == child then return true end
		parentLength = parentLength + 1
		index = index:GetParent()
	end

	local function getChildLength(curchild, count)
		if count > 16 then return count end
		local max = count
		for k, v in pairs(curchild:GetChildren()) do
			if v == parent then return 17 end
			max = math.max(max, getChildLength(v, count + 1))
		end
		return max
	end
	local childLength = getChildLength(child, 1)

	return parentLength + childLength > 16
end

-- This function clamps the position before moving the entity
local minx, miny, minz = -16384, -16384, -16384
local maxx, maxy, maxz = 16384, 16384, 16384
local clamp = math.Clamp
function SF.clampPos(pos)
	pos.x = clamp(pos.x, minx, maxx)
	pos.y = clamp(pos.y, miny, maxy)
	pos.z = clamp(pos.z, minz, maxz)
	return pos
end

local dumbtrace = {
	FractionLeftSolid = 0,
	HitNonWorld       = true,
	Fraction          = 0,
	Entity            = NULL,
	HitPos            = Vector(0, 0, 0),
	HitNormal         = Vector(0, 0, 0),
	HitBox            = 0,
	Normal            = Vector(1, 0, 0),
	Hit               = true,
	HitGroup          = 0,
	MatType           = 0,
	StartPos          = Vector(0, 0, 0),
	PhysicsBone       = 0,
	WorldToLocal      = Vector(0, 0, 0),
}
function SF.dumbTrace(entity, pos)
	if entity then dumbtrace.Entity = entity end
	if pos then dumbtrace.HitPos = pos end
	return dumbtrace
end

function SF.IsHUDActive(ent, ply)
	local tbl = ent.ActiveHuds
	return tbl and tbl[SERVER and (ply or error("Missing player arg")) or LocalPlayer()]
end

-- ------------------------------------------------------------------------- --
--- Legacy deserializes an instance's code.
-- @return The table of filename = source entries
-- @return The main filename
function SF.LegacyDeserializeCode(tbl)
	local sources = {}
	for filename, source in pairs(tbl.source) do
		sources[filename] = string.gsub(source, "[" .. string.char(5) .. string.char(4) .. "]", { [string.char(5)[1]] = "\n", [string.char(4)[1]] = '"' })
	end
	return sources, tbl.mainfile
end

local soundsMap = {
	["DRIP1"] = 0, [0] = "ambient/water/drip1.wav",
	["DRIP2"] = 1,	[1] = "ambient/water/drip2.wav",
	["DRIP3"] = 2,	[2] = "ambient/water/drip3.wav",
	["DRIP4"] = 3,	[3] = "ambient/water/drip4.wav",
	["DRIP5"] = 4,	[4] = "ambient/water/drip5.wav",
	["ERROR1"] = 5,	[5] = "buttons/button10.wav",
	["CONFIRM1"] = 6,	[6] = "buttons/button3.wav",
	["CONFIRM2"] = 7,	[7] = "buttons/button14.wav",
	["CONFIRM3"] = 8,	[8] = "buttons/button15.wav",
	["CONFIRM4"] = 9,	[9] = "buttons/button17.wav",
	["SILENT"] = 10,
}
local notificationsMap = {
	["GENERIC"] = 0,
	["ERROR"] = 1,
	["UNDO"] = 2,
	["HINT"] = 3,
	["CLEANUP"] = 4,
}
-- ------------------------------------------------------------------------- --

if SERVER then
	util.AddNetworkString("starfall_addnotify")
	util.AddNetworkString("starfall_print")

	function SF.AddNotify(ply, msg, notifyType, duration, sound)
		if not IsValid(ply) then return end

		net.Start("starfall_addnotify")
		net.WriteString(string.sub(msg, 1, 1024))
		net.WriteUInt(notificationsMap[notifyType], 8)
		net.WriteFloat(duration)
		net.WriteUInt(soundsMap[sound], 8)
		if ply then
			net.Send(ply)
		else
			net.Broadcast()
		end
	end

	function SF.Print(ply, msg)
		net.Start("starfall_print")
			net.WriteBool(true)
			net.WriteUInt(1, 32)
			net.WriteType(msg)
		if ply then net.Send(ply) else net.Broadcast() end
	end

else

	function SF.AddNotify(ply, msg, type, duration, sound)
		if ply == LocalPlayer() then
			print(msg)
			GAMEMODE:AddNotify(msg, notificationsMap[type], duration)
			if soundsMap[sound] then
				local path = soundsMap[soundsMap[sound]]
				if path then
					surface.PlaySound(path)
				end
			end
		end
	end

	net.Receive("starfall_addnotify", function ()
		local msg, type, duration, sound = net.ReadString(), net.ReadUInt(8), net.ReadFloat(), net.ReadUInt(8)
		print(msg)
		GAMEMODE:AddNotify(msg, type, duration)
		if soundsMap[sound] then
			local path = soundsMap[soundsMap[sound]]
			if path then
				surface.PlaySound(path)
			end
		end
	end)

	function SF.HTTPNotify(ply, url)
		local plyStr
		if ply == SF.Superuser then
			plyStr = "Superuser"
		elseif IsValid(ply) then
			plyStr = ply:Nick() .. " [" .. ply:SteamID() .. "]"
		else
			plyStr = "Invalid user"
		end
		MsgC(Color(255, 255, 0), "SF HTTP: " .. plyStr .. ": requested url ", Color(255,255,255), url, "\n")
	end

	net.Receive("starfall_print", function ()
		local console = net.ReadBool()
		local recv = {}
		for i = 1, net.ReadUInt(32) do
			recv[i] = net.ReadType()
		end
		if console then
			table.insert(recv, "\n")
			MsgC(unpack(recv))
		else
			chat.AddText(unpack(recv))
		end
	end)
end


do
	local middleclass = {
		_VERSION     = 'middleclass v4.1.1',
		_DESCRIPTION = 'Object Orientation for Lua',
		_URL         = 'https://github.com/kikito/middleclass',
		_LICENSE     = [[
		MIT LICENSE

		Copyright (c) 2011 Enrique García Cota

		Permission is hereby granted, free of charge, to any person obtaining a
		copy of this software and associated documentation files (the
		"Software"), to deal in the Software without restriction, including
		without limitation the rights to use, copy, modify, merge, publish,
		distribute, sublicense, and/or sell copies of the Software, and to
		permit persons to whom the Software is furnished to do so, subject to
		the following conditions:

		The above copyright notice and this permission notice shall be included
		in all copies or substantial portions of the Software.

		THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
		OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
		MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
		IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
		CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
		TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
		SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
		]]
	}

	local function _createIndexWrapper(aClass, f)
		if f == nil then
		return aClass.__instanceDict
		else
		return function(self, name)
			local value = aClass.__instanceDict[name]

			if value ~= nil then
			return value
			elseif isfunction(f) then
			return (f(self, name))
			else
			return f[name]
			end
		end
		end
	end

	local function _propagateInstanceMethod(aClass, name, f)
		f = name == "__index" and _createIndexWrapper(aClass, f) or f
		aClass.__instanceDict[name] = f

		for subclass in pairs(aClass.subclasses) do
		if rawget(subclass.__declaredMethods, name) == nil then
			_propagateInstanceMethod(subclass, name, f)
		end
		end
	end

	local function _declareInstanceMethod(aClass, name, f)
		aClass.__declaredMethods[name] = f

		if f == nil and aClass.super then
		f = aClass.super.__instanceDict[name]
		end

		_propagateInstanceMethod(aClass, name, f)
	end

	local function _tostring(self) return "class " .. self.name end
	local function _call(self, ...) return self:new(...) end

	local function _createClass(name, super)
		local dict = {}
		dict.__index = dict

		local aClass = { name = name, super = super, static = {},
						 __instanceDict = dict, __declaredMethods = {},
						 subclasses = setmetatable({}, {__mode='k'})  }

		if super then
		setmetatable(aClass.static, {
			__index = function(_,k)
			local result = rawget(dict,k)
			if result == nil then
				return super.static[k]
			end
			return result
			end
		})
		else
		setmetatable(aClass.static, { __index = function(_,k) return rawget(dict,k) end })
		end

		setmetatable(aClass, { __index = aClass.static, __tostring = _tostring,
							 __call = _call, __newindex = _declareInstanceMethod })

		return aClass
	end

	local function _includeMixin(aClass, mixin)
		assert(istable(mixin), "mixin must be a table")

		for name,method in pairs(mixin) do
		if name ~= "included" and name ~= "static" then aClass[name] = method end
		end

		for name,method in pairs(mixin.static or {}) do
		aClass.static[name] = method
		end

		if isfunction(mixin.included) then mixin:included(aClass) end
		return aClass
	end

	local DefaultMixin = {
		__tostring   = function(self) return "instance of " .. tostring(self.class) end,

		initialize   = function(self, ...) end,

		isInstanceOf = function(self, aClass)
		return istable(aClass)
			 and istable(self)
			 and (self.class == aClass
				or istable(self.class)
				and isfunction(self.class.isSubclassOf)
				and self.class:isSubclassOf(aClass))
		end,

		static = {
		allocate = function(self)
			assert(istable(self), "Make sure that you are using 'Class:allocate' instead of 'Class.allocate'")
			return setmetatable({ class = self }, self.__instanceDict)
		end,

		new = function(self, ...)
			assert(istable(self), "Make sure that you are using 'Class:new' instead of 'Class.new'")
			local instance = self:allocate()
			instance:initialize(...)
			return instance
		end,

		subclass = function(self, name)
			assert(istable(self), "Make sure that you are using 'Class:subclass' instead of 'Class.subclass'")
			assert(isstring(name), "You must provide a name(string) for your class")

			local subclass = _createClass(name, self)

			for methodName, f in pairs(self.__instanceDict) do
			_propagateInstanceMethod(subclass, methodName, f)
			end
			subclass.initialize = function(instance, ...) return self.initialize(instance, ...) end

			self.subclasses[subclass] = true
			self:subclassed(subclass)

			return subclass
		end,

		subclassed = function(self, other) end,

		isSubclassOf = function(self, other)
			return istable(other) and
				istable(self.super) and
				( self.super == other or self.super:isSubclassOf(other) )
		end,

		include = function(self, ...)
			assert(istable(self), "Make sure you that you are using 'Class:include' instead of 'Class.include'")
			for _,mixin in ipairs({...}) do _includeMixin(self, mixin) end
			return self
		end
		}
	}

	local checkluatype = SF.CheckLuaType
	function SF.Class(name, super)
		checkluatype(name, TYPE_STRING)
		if super~=nil then checkluatype(super, TYPE_TABLE) end
		return super and super:subclass(name) or _includeMixin(_createClass(name), DefaultMixin)
	end
end


do
	-- Some more optimized path regex until gmod pulls them
	function string.GetExtensionFromFilename( path )
		return string.match( path, "%.([^%.]+)$" )
	end
	function string.StripExtension( path )
		return string.match( path, "(.+)%." ) or path
	end
	function string.GetPathFromFilename( path )
		return string.match( path, "(.*[/\\])" ) or ""
	end
	function string.GetFileFromFilename( path )
		return string.match( path, "[\\/]([^/\\]+)$" ) or path
	end

	local function checkregex(data, pattern)
		local limits = {[0] = 50000000, 15000, 500, 150, 70, 40} -- Worst case is about 200ms
		local stripped, nrepl, nrepl2
		-- strip escaped things
		stripped, nrepl = string.gsub(pattern, "%%.", "")
		-- strip bracketed things
		stripped, nrepl2 = string.gsub(stripped, "%[.-%]", "")
		-- strip captures
		stripped = string.gsub(stripped, "[()]", "")
		-- Find extenders
		local n = 0 for i in string.gmatch(stripped, "[%+%-%*]") do n = n + 1 end
		local msg
		if n<=#limits then
			if #data*(#stripped + nrepl - n + nrepl2)>limits[n] then msg = n.." ext search length too long ("..limits[n].." max)" else return end
		else
			msg = "too many extenders"
		end
		SF.Throw("Regex is too complex! " .. msg, 3)
	end
	SF.CheckPattern = checkregex

	local checkluatype = SF.CheckLuaType
	local string_library = {}
	string_library.byte = string.byte
	string_library.char = string.char
	string_library.comma = string.Comma string_library.Comma = string.Comma
	string_library.dump = string.dump
	string_library.endsWith = string.EndsWith string_library.EndsWith = string.EndsWith
	function string_library.format(s, ...)
		checkluatype(s, TYPE_STRING)
		for i=1, select("#",...) do
			if istable(select(i, ...)) then SF.Throw("Cannot use table in string.format!", 2) end
		end
		return string.format(s, ...)
	end
	string_library.formattedTime = string.FormattedTime string_library.FormattedTime = string.FormattedTime
	string_library.getChar = string.GetChar string_library.GetChar = string.GetChar
	string_library.getExtensionFromFilename = string.GetExtensionFromFilename string_library.GetExtensionFromFilename = string.GetExtensionFromFilename
	string_library.getFileFromFilename = string.GetFileFromFilename string_library.GetFileFromFilename = string.GetFileFromFilename
	string_library.getPathFromFilename = string.GetPathFromFilename string_library.GetPathFromFilename = string.GetPathFromFilename
	function string_library.explode(pattern, data, withpattern)
		if withpattern then
			checkluatype(data, TYPE_STRING)
			checkluatype(pattern, TYPE_STRING)
			checkregex(data, pattern)
		end
		return string.Explode(pattern, data, withpattern)
	end
	string_library.Explode = string_library.explode
	function string_library.find(data, pattern, start, noPatterns)
		if not noPatterns then
			checkluatype(data, TYPE_STRING)
			checkluatype(pattern, TYPE_STRING)
			checkregex(data, pattern)
		end
		return string.find(data, pattern, start, noPatterns)
	end
	function string_library.match(data, pattern, start)
		checkluatype(data, TYPE_STRING)
		checkluatype(pattern, TYPE_STRING)
		checkregex(data, pattern)
		return string.match(data, pattern, start)
	end
	function string_library.gmatch(data, pattern)
		checkluatype(data, TYPE_STRING)
		checkluatype(pattern, TYPE_STRING)
		checkregex(data, pattern)
		return string.gmatch(data, pattern)
	end
	string_library.gfind = string_library.gmatch
	function string_library.gsub(data, pattern, replacement, max)
		if debug.getinfo(128) then error("stack overflow") end
		checkluatype(data, TYPE_STRING)
		checkluatype(pattern, TYPE_STRING)
		checkregex(data, pattern)
		return string.gsub(data, pattern, replacement, max)
	end
	string_library.implode = string.Implode string_library.Implode = string.Implode
	local function javascriptSafe(str)
		checkluatype(str, TYPE_STRING)
		return string.JavascriptSafe(str)
	end
	string_library.replace = string.Replace string_library.Replace = string.Replace
	string_library.javascriptSafe = javascriptSafe string_library.JavascriptSafe = javascriptSafe
	string_library.left = string.Left string_library.Left = string.Left
	string_library.len = string.len
	string_library.lower = string.lower
	string_library.niceSize = string.NiceSize string_library.NiceSize = string.NiceSize
	string_library.niceTime = string.NiceTime string_library.NiceTime = string.NiceTime
	local function patternSafe(str)
		checkluatype(str, TYPE_STRING)
		return string.PatternSafe(str)
	end
	string_library.patternSafe = patternSafe string_library.PatternSafe = patternSafe
	string_library.reverse = string.reverse
	string_library.right = string.Right string_library.Right = string.Right
	string_library.setChar = string.SetChar string_library.SetChar = string.SetChar
	string_library.split = string.Split string_library.Split = string.Split
	string_library.startWith = string.StartWith string_library.StartWith = string.StartWith
	string_library.startsWith = string.StartsWith string_library.StartsWith = string.StartsWith
	string_library.stripExtension = string.StripExtension string_library.StripExtension = string.StripExtension
	string_library.sub = string.sub
	string_library.toMinutesSeconds = string.ToMinutesSeconds string_library.ToMinutesSeconds = string.ToMinutesSeconds
	string_library.toMinutesSecondsMilliseconds = string.ToMinutesSecondsMilliseconds string_library.ToMinutesSecondsMilliseconds = string.ToMinutesSecondsMilliseconds
	string_library.toTable = string.ToTable string_library.ToTable = string.ToTable
	string_library.trim = string.Trim string_library.Trim = string.Trim
	string_library.trimLeft = string.TrimLeft string_library.TrimLeft = string.TrimLeft
	string_library.trimRight = string.TrimRight string_library.TrimRight = string.TrimRight
	string_library.upper = string.upper
	string_library.normalizePath = SF.NormalizePath

	--UTF8 part
	string_library.utf8char = utf8.char
	string_library.utf8codepoint = utf8.codepoint
	string_library.utf8codes = utf8.codes
	string_library.utf8force = utf8.force
	string_library.utf8len = utf8.len
	string_library.utf8offset = utf8.offset

	local max_rep = 1000000
	function string_library.rep(str, rep, sep)
		if #str*rep+(sep and #sep or 0)*rep > max_rep then SF.Throw("Max string.rep length is " .. max_rep, 2) end

		return string.rep(str, rep, sep)
	end
	SF.SafeStringLib = string_library
end


-------------------------------------------------------------------------------
-- Includes
-------------------------------------------------------------------------------

include("instance.lua")
include("preprocessor.lua")
include("permissions/core.lua")
include("editor/editor.lua")
include("transfer.lua")
if CLIENT then
	include("toolscreen.lua")
end

do
	local function compileModule(source, path)
		local ok, init = xpcall(function() local r = (source and CompileString(source, path) or CompileFile(path)) r=r and r() return r end, debug.traceback)
		if not ok then
			ErrorNoHalt("[SF] Attempt to load bad module: " .. path .. "\n" .. init .. "\n")
			init = nil
		end
		return init
	end
	
	local function addModule(name, path, shouldrun)
		local source, init
		if SERVER then
			AddCSLuaFile(path)
			source = file.Read(path, "LUA")
			if shouldrun then
				init = compileModule(source, path)
			end
		else
			if shouldrun then
				init = compileModule(nil, path)
			end
		end
		local tbl = SF.Modules[name]
		if not tbl then tbl = {} SF.Modules[name] = tbl end
		tbl[path] = {source = source, init = init}
	end

	local function loadModules(folder, shouldrun)
		local l = file.Find(folder.."*.lua", "LUA")
		for _, filename in pairs(l) do
			local path = folder..filename
			addModule(string.StripExtension(filename), path, shouldrun)
		end
	end

	loadModules("starfall/libs_sh/", SERVER or CLIENT)
	loadModules("starfall/libs_sv/", SERVER)
	loadModules("starfall/libs_cl/", CLIENT)
	SF.Permissions.loadPermissions()

	if SERVER then
		util.AddNetworkString("sf_receivelibrary")
		include("starfall/editor/docs.lua")
		SF.Docs = util.Compress(SF.TableToString(SF.Docs, nil, true))
		SF.DocsCRC = util.CRC(SF.Docs)

		-- Command to reload the libraries
		concommand.Add("sf_reloadlibrary", function(ply, com, arg)
			if IsValid(ply) and not ply:IsSuperAdmin() then return end
			local name = arg[1]
			if not name then return end
			name = string.lower(name)

			local sv_filename = "starfall/libs_sv/"..name..".lua"
			local sh_filename = "starfall/libs_sh/"..name..".lua"
			local cl_filename = "starfall/libs_cl/"..name..".lua"

			local sendToClientTbl = {}
			if file.Exists(sh_filename, "LUA") or file.Exists(sv_filename, "LUA") then
				print("Reloaded library: " .. name)
				SF.Modules[name] = {}
				if file.Exists(sh_filename, "LUA") then
					addModule(name, sh_filename, true)
					sendToClientTbl[#sendToClientTbl+1] = sh_filename
				end
				if file.Exists(sv_filename, "LUA") then
					addModule(name, sv_filename, true)
				end
				SF.Permissions.loadPermissions()
			end
			if file.Exists(cl_filename, "LUA") then
				addModule(name, cl_filename, false)
				sendToClientTbl[#sendToClientTbl+1] = cl_filename
			end
			if #sendToClientTbl>0 then
				local files = {}
				for k, path in pairs(sendToClientTbl) do
					files[name..":"..path] = file.Read(path, "LUA")
				end
				net.Start("sf_receivelibrary")
				net.WriteStarfall({files = files, mainfile = name, proc = Entity(0), owner = Entity(0)})
				net.Broadcast()
			end
		end)

	else
		net.Receive("sf_receivelibrary", function(len)
			net.ReadStarfall(nil, function(ok, data)
				if ok then
					SF.Modules[data.mainfile] = {}
					print("Reloaded library: " .. data.mainfile)
					for k, code in pairs(data.files) do
						local modname, path = string.match(k, "(.+):(.+)")
						local t = SF.Modules[modname]
						if not t then t = {} SF.Modules[modname] = t end
						local shouldrun
						if string.find(path, "starfall/libs_sv", 1, true) then
							shouldrun = SERVER
						elseif string.find(path, "starfall/libs_sh", 1, true) then
							shouldrun = true
						elseif string.find(path, "starfall/libs_cl", 1, true) then
							shouldrun = CLIENT
						end
						local t2 = t[path]
						if not t2 then t2 = {} t[path] = t2 end
						t2.source = code
						if shouldrun then
							t2.init = compileModule(code, path)
							SF.Permissions.loadPermissions()
						end
					end
				end
			end)
		end)
	end
end
