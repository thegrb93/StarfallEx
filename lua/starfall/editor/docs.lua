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

local string_match, string_find = string.match, string.find


local function processMembers()
	for k, data in ipairs(members) do
		local _1, _2, libtblname, funcname = string_find(data.name, "([%w_]+)%s*[%.%:]%s*([%w_]+)")
		if libtblname then
			data.name = funcname
			local lib = methodstolib[libtblname]
			if lib then
				local tblindex
				if data.class == "table" then tblindex = "tables"
				elseif data.class == "field" then tblindex = "fields"
				elseif data.class == "function" then tblindex = "methods"
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
local function process(data, nextline)
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
		processFunc(data, nextline)
	else
		ErrorNoHalt("Invalid doc class (" .. data.class .. ") in file: " .. curfile .. "\n")
	end
end

local generic_lua_types = {
	["boolean"] = true,
	["number"] = true,
	["string"] = true,
	["table"] = true,
	["..."] = true,
	["any"] = true,
	["function"] = true,
}

local sf_types = SF.Types

local function valid_sftype(type1)
	if sf_types[type1] or generic_lua_types[type1] then return true end

	if string_find(type1, "|", 1, true) then
		for _, match in next, type1:Split("|") do
			if not (sf_types[match] or generic_lua_types[match]) then
				return false
			end
		end
	end

	local type2 = type1:match("%.%.%.(%w+)%??") -- ...(number)?

	if sf_types[type2] or generic_lua_types[type2] then return true end

	local type3 = type1:match("(%w+)%??") -- (vector)?

	return sf_types[type3] or generic_lua_types[type3]
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
		local type, name, description = string_match(value, "%s*([%w_%.%?|]+)%s*([%w_%.]+)%s*(.*)")
		if type then
			if not valid_sftype(type) then
				-- No type found, revert to old untyped documentation
				type = "any?"
				name, description = string_match(value, "%s*([%w_%.]+)%s*(.*)")
				if name==nil then
					ErrorNoHalt("Invalid param doc (" .. value .. ") in file: " .. curfile .. "\n")
				end
			end

			local t = parsing.params
			if not t then t = {} parsing.params = t end
			t[#t+1] = {
				name = name,
				description = description,
				type = type
 			}
		else
			ErrorNoHalt("Invalid param doc (" .. value .. ") in file: " .. curfile .. "\n")
		end
	end,
	["return"] = function(parsing, value)
		local type, description = string_match(value, "%s*([%w_%.%?|]+)%s*(.*)")
		if type then
			if not valid_sftype(type) then
				-- No type found, revert to old untyped documentation
				type = "any?"
				description = value
			end
			local t = parsing.returns
			if not t then t = {} parsing.returns = t end
			t[#t+1] = { type = type, description = description }
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
	end
}
local function parse(parsing, data)
	local attribute, value = string_match(data, "^%s*@(%w+)%s*(.*)")
	if attribute then
		local parser = parseAttributes[attribute]
		if parser then
			parser(parsing, value)
		else
			ErrorNoHalt("Invalid attribute (" .. attribute .. ") in file: " .. curfile .. "\n")
		end
	else
		local t = parsing.description
		t[#t+1] = data
	end
end

local function scan(src, realm)
	local linetbl = string.Explode("\r?\n", src, true)
	local i = 0
	local function lines() i=i+1 return linetbl[i] end
	local parsing
	for line in lines do
		if parsing then
			local data = string_match(line, "^%s*%-%-%-*(.*)")
			if data then
				parse(parsing, data)
			else
				while line and not string_find(line, "%S") do -- Find next non-empty line
					line = lines()
				end
				process(parsing, line or "")
				parsing = nil
				if line == nil then break end
			end
		end
		if not parsing then
			local desc = string_match(line, "^%s*%-%-%-(.*)")
			if desc then
				parsing = {
					description = {desc},
					realm = realm
				}
			end
		end
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

for name, mod in pairs(SF.Modules) do
	for filename, data in pairs(mod) do
		curfile = filename
		scan(data.source, realm(filename))
		data.source = nil
	end
end

processMembers()
