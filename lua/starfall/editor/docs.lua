local Docs = {}
SF.Docs = Docs

Docs.Version = SF.Version or "master"
Docs.Directives = {}
Docs.Types = {}
Docs.Libraries = {}
Docs.Hooks = {}

local curfile
local methodstolib = {}
local members = {}

local string_match, string_find, string_sub = string.match, string.find, string.sub

function SF.GetLines(str)
	local current_pos = 1
	local lineN = 0
	return function()
		local start_pos, end_pos = string_find( str, "\r?\n", current_pos )
		if start_pos then
			local ret = string_sub( str, current_pos, start_pos - 1 )
			current_pos = end_pos + 1
			lineN = lineN + 1
			return lineN, ret
		else
			return nil
		end
	end
end

local generic_lua_types = {
	["boolean"] = true,
	["number"]  = true,
	["string"]  = true,
	["table"] = true,
	["function"] = true,
	["thread"] = true,
	["..."] = true, -- Any type of multiple values or no values potentially.

	["any"] = true, -- Can be any type, only one value

	["nil"] = true -- For nullable / optional values
}

local sf_types = Docs.Types -- Get the types from documentation rather than the lua state
local function valid_sftype(type1)
	if sf_types[type1] or generic_lua_types[type1] then return true end

	if string_find(type1, "|", 1, true) then
		for str in type1:gmatch("[^|]+") do
			-- Note that we shouldn't use nullables / variadics in a multi-type <type>|<type2> so we don't support it here.
			-- Just use the variadic since it can equal nil or add |nil to it.

			if not (sf_types[str] or generic_lua_types[str]) then
				return false
			end
		end
	end

	local type2 = type1:match("%.%.%.(%w+)%??") -- ...<number>(?)

	if sf_types[type2] or generic_lua_types[type2] then return true end

	local type3 = type1:match("(%w+)%??") -- <Vector>?

	return sf_types[type3] or generic_lua_types[type3]
end

local function processMembers()
	for k, data in ipairs(members) do
		local libtblname, funcname = string_match(data.name, "([%w_]+)%s*[%.%:]%s*([%w_]+)")
		if libtblname then
			data.name = funcname
			local lib = methodstolib[libtblname]
			if lib then
				local tblindex
				if data.class == "table" then tblindex = "tables"
				elseif data.class == "field" then tblindex = "fields"
				elseif data.class == "function" then
					tblindex = "methods"

					if data.params then
						for _, param in ipairs(data.params) do
							if not valid_sftype(param.type) then
								-- No valid type found, revert to old untyped documentation
								param.type = nil -- SFHelper will turn this into "any". (Any type, including nil)
								param.name, param.description = string_match(param.value, "%s*([%w_%.]+)%s*(.*)")
								if param.name==nil then
									ErrorNoHalt("Invalid param doc (" .. param.value .. ") in file: " .. curfile .. "\n")
								end
								param.value = nil
							end
						end
					end
					if data.returns then
						for _, ret in ipairs(data.returns) do
							if not valid_sftype(ret.type) then
								ret.type = nil
								ret.description = ret.value
								ret.value = nil
							end
						end
					end
				end
				if Docs.Types[lib] then
					Docs.Types[lib][tblindex][funcname] = data
				elseif Docs.Libraries[lib] then
					Docs.Libraries[lib][tblindex][funcname] = data
				else
					ErrorNoHalt("Invalid function lib name!\n" .. libtblname .. "\n" .. funcname .. "\n")
				end
			else
				ErrorNoHalt("Invalid function lib name!\n" .. libtblname .. "\n" .. funcname .. "\n")
			end
		else
			ErrorNoHalt("Couldn't extract lib/function name from function!\n" .. data.name .. "\n")
		end
	end
end

local processTypes = {
	["type"] = function(data)
		for k, v in ipairs(data.libtbl) do
			methodstolib[v] = data.name
		end
		Docs.Types[data.name] = data
		data.methods = {}
	end,
	["library"] = function(data)
		for k, v in ipairs(data.libtbl) do
			methodstolib[v] = data.name
		end
		Docs.Libraries[data.name] = data
		data.tables = {}
		data.methods = {}
		data.fields = {}
	end,
	["hook"] = function(data)
		Docs.Hooks[data.name] = data
	end,
	["directive"] = function(data)
		Docs.Directives[data.name] = data
	end,
	["function"] = function(data)
		members[#members+1] = data
	end,
	["table"] = function(data)
		members[#members+1] = data
	end,
	["field"] = function(data)
		members[#members+1] = data
	end
}

local function process(data, nextline, lineN)
	if not data.class then
		if string_find(nextline, "function", 1, true) then
			data.class = "function"
		else
			return
		end
	end
	if not data.name then
		if data.class=="function" or data.class=="table" then
			data.name = nextline
		else
			ErrorNoHalt("Invalid doc name for class (" .. data.class .. ") in file: " .. curfile .. "\n")
			return
		end
	end
	local processFunc = processTypes[data.class]
	if processFunc then
		data.description = table.concat(data.description, "\n")
		processFunc(data, nextline, lineN)
	else
		ErrorNoHalt("Invalid doc class (" .. data.class .. ") in file: " .. curfile .. "\n")
	end
end

local parseAttributes = {
	["client"] = function(parsing)
		parsing.realm = "client"
	end,
	["server"] = function(parsing)
		parsing.realm = "server"
	end,
	["shared"] = function(parsing)
		parsing.realm = "shared"
	end,
	["class"] = function(parsing, value)
		parsing.class = value
	end,
	["name"] = function(parsing, value)
		parsing.name = value
	end,
	["libtbl"] = function(parsing, value)
		local t = parsing.libtbl
		if not t then t = {} parsing.libtbl = t end
		t[#t+1] = value
	end,
	["param"] = function(parsing, value)
		local type, name, description = string_match(value, "%s*([%w%.%?|]+)%s*([%w_%.]+)%s*(.*)")
		if type then
			local t = parsing.params
			if not t then t = {} parsing.params = t end
			t[#t+1] = {
				name = name,
				description = description,
				type = type,
				value = value -- We need this in case the type isn't valid. Will be deleted after.
 			}
		else
			ErrorNoHalt("Invalid param doc (" .. value .. ") in file: " .. curfile .. "\n")
		end
	end,
	["return"] = function(parsing, value)
		local type, description = string_match(value, "%s*([%w_%.%?|]+)%s*(.*)")
		if type then
			local t = parsing.returns
			if not t then t = {} parsing.returns = t end
			t[#t+1] = {
				type = type,
				description = description,
				value = value
			}
		else
			ErrorNoHalt("Invalid return doc (" .. value .. ") in file: " .. curfile .. "\n")
		end
	end,
	["field"] = function(parsing, value)
		local name, description = string_match(value, "%s*([%w_]+)%s*(.*)")
		if name then
			local t = parsing.fields
			if not t then t = {} parsing.fields = t end
			t[#t+1] = {name = name, description = description}
		else
			ErrorNoHalt("Invalid field doc (" .. value .. ") in file: " .. curfile .. "\n")
		end
	end,

	--- Overrides the [src] link which would normally go to the SF github.
	-- This would be for addons extending SF and wanting to link to their repos.
	-- The links would be something like https://github.com/User/Repo/.../file.lua
	-- It will be a direct link to a page and the line number that SF finds will be appended to it.
	-- Only github links are allowed.
	["src"] = function(parsing, value)
		local link = string_match(value, "https://github.com/(.+)")
		if link then
			parsing.path = link .. string_match(parsing.path, "(#L[%d%-]+)")
		else
			ErrorNoHalt("Invalid src override (" .. value .. ") in file: " .. curfile .. ", make sure it's a github link!\n")
		end
	end
}

local function parse(parsing, data, lineN)
	local attribute, value = string_match(data, "^%s*@(%w+)%s*(.*)")

	if attribute then
		local parser = parseAttributes[attribute]
		if parser then
			parser(parsing, value, lineN)
		else
			ErrorNoHalt("Invalid attribute (" .. attribute .. ") in file: " .. curfile .. "\n")
		end
	else
		local t = parsing.description
		t[#t+1] = data
	end
end

--- Scan function
-- @param string src Source code
-- @param string file_name Source file name.
local function scan(src, realm)
	-- https://github.com/thegrb93/StarfallEx/blob/master/lua/starfall/...
	local filePath = string_match(curfile, "starfall/(libs_.+/.*)") -- libs_sh/... path that will be used for links with [src] on the sfhelper to the github.
	local parsing
	local lines = SF.GetLines(src)
	for lineN, line in lines do
		if parsing then
			local data = string_match(line, "^%s*%-%-%-*(.*)")
			if data then
				parse(parsing, data, lineN)
			else
				while line and not string.find(line, "%S") do -- Find next non-empty line
					lineN, line = lines()
				end
				process(parsing, line or "", lineN)
				parsing = nil
				if line == nil then break end
			end
		end
		if not parsing then
			local desc = string_match(line, "^%s*%-%-%-(.*)")
			if desc then
				parsing = {
					description = {desc},
					realm = realm,
					path = filePath.."#L"..lineN
				}
			end
		end
	end
	if parsing then
		local lineN = lines()
		process(parsing, "", lineN)
	end
end

local function realm(filename)
	if string_match(filename, ".*_sv/[^/]+$") then
		return "server"
	elseif string_match(filename, ".*_sh/[^/]+$") then
		return "shared"
	elseif string_match(filename, ".*_cl/[^/]+$") then
		return "client"
	else
		error("Couldn't figure out the realm! " .. filename)
	end
end


-- First, go over all of the types so we have them in Docs.Types ready for typed docs.
for name, mod in pairs(SF.Modules) do
	for filename, data in pairs(mod) do
		curfile = filename
		scan(data.source, realm(filename))
	end
end


processMembers()
