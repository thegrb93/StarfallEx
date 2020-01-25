local Docs = {}
SF.Docs = Docs

local curfile

local function process(data, nextline)
end

local parseAttributes = {
	["client"] = function(parsing)
		parsing.realm = "client",
	end
	["server"] = function(parsing)
		parsing.realm = "server",
	end
	["shared"] = function(parsing)
		parsing.realm = "shared",
	end,
	["class"] = function(parsing, value)
		parsing.class = value,
	end
}
local function parse(parsing, data)
	local attribute, value = string.match(data, "%s*@(%w+)%s*(.*)")
	if attribute then
		local parser = parseAttributes[attribute]
		if parser then
			parser(parsing, value)
		else
			ErrorNoHalt("Invalid attribute (" .. attribute .. ") in file: " .. curfile)
		end
	else
		local t = parsing[parsing.lastattrb]
		if not t then t = {} parsing[parsing.lastattrb] = t end
		t[#t+1] = value
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
				while line and string.match(line, "%s*") do -- Find next non-empty line
					line = lines()
				end
				local gotonewparsing = string.match(line, "^%s*%-%-%-.+")
				process(parsing, (not gotonewparsing) and line or "")
				parsing = nil
				if gotonewparsing then
					goto newparsing
				end
			end
		else
			::newparsing::
			local desc = string.match(line, "^%s*%-%-%-(.+)")
			if desc then
				parsing = {
					lastattrb = "description",
					description = {desc},
					realm = realm
				}
			end
		end
	end
end

local function realm(filename)
	if string.match(filename, ".*_sv%.lua$") then
		return "server"
	elseif string.match(filename, ".*_sh%.lua$") then
		return "shared"
	elseif string.match(filename, ".*_cl%.lua$") then
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
