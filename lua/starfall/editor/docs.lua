local Docs = {}
SF.Docs = Docs

local curfile

local function process(data, nextline)
	PrintTable(data)
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
		parsing.libtbl = value
	end,
	["param"] = function(parsing, value)
		local name, desc = string.match(value, "%s*([%w_]+)%s*(.*)")
		if name then
			local t = parsing.params
			if not t then t = {} parsing.params = t end
			t[#t+1] = {name = name, desc = desc}
		else
			ErrorNoHalt("Invalid param doc (" .. value .. ") in file: " .. curfile .. "\n")
		end
	end,
	["return"] = function(parsing, value)
		local t = parsing.returns
		if not t then t = {} parsing.returns = t end
		t[#t+1] = value
	end,
}
local function parse(parsing, data)
	local attribute, value = string.match(data, "%s*@(%w+)%s*(.*)")
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
	local lines = string.gmatch(src, "[^\r\n]+")
	local parsing
	for line in lines do
		if parsing then
			local data = string.match(line, "^%s*%-%-%-*(.+)")
			if data then
				parse(parsing, data)
			else
				while line and not string.find(line, "%S") do -- Find next non-empty line
					line = lines()
				end
				process(parsing, line or "")
				parsing = nil
				if line == nil then break end
			end
		end
		if not parsing then
			local desc = string.match(line, "^%s*%-%-%-(.+)")
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
	if string.match(filename, ".*_sv/[^/]+$") then
		return "server"
	elseif string.match(filename, ".*_sh/[^/]+$") then
		return "shared"
	elseif string.match(filename, ".*_cl/[^/]+$") then
		return "client"
	else
		error("Couldn't figure out the realm! " .. filename)
	end
end

for name, mod in pairs(SF.Modules) do
	for filename, data in pairs(mod) do
		curfile = filename
		scan(data.source, realm(filename))
	end
end
