AddCSLuaFile("sfpreprocessor.lua")

SF_PProcessor = SF_PProcessor or {}

local function FindComments( line )
	local ret, count, pos, found = {}, 0, 1
	repeat
		found = line:find( '["%-%[%]]', pos )
		if (found) then -- We found something
			local oldpos = pos
			
			local char = line:sub(found,found)
			if char == "-" then
				if line:sub(found,found+1) == "--" then
					-- Comment beginning
					if line:sub(found,found+3) == "--[[" then
						-- Block Comment beginning
						count = count + 1
						ret[count] = {type = "start", pos = found}
						pos = found + 4
					else
						-- Line comment beginning
						count = count + 1
						ret[count] = {type = "line", pos = found}
						pos = found + 2
					end
				else
					pos = found + 1
				end
			elseif char == "[" then
				if line:sub(found,found+1) == "[[" then
					-- Block string start
					count = count + 1
					ret[count] = {type = "stringblock", pos = found}
					pos = found + 2
				else
					pos = found + 1
				end
			elseif char == "]" then
				if line:sub(found,found+1) == "]]" then
					-- Ending
					count = count + 1
					ret[count] = {type = "end", pos = found}
					pos = found + 2
				else
					pos = found + 1
				end
			elseif char == "\"" and line:sub(found-1,found-1) ~= "\\" then
				-- String
				count = count + 1
				ret[count] = {type = "string", pos = found}
				pos = found + 1
			end
			
			if oldpos == pos then error("Regex found something, but nothing handled it") end
		end
	until not found
	return ret, count
end

local function findIncludeStatements(code)
	local includes = {}
	
	local ending = nil
	for lineno,line in ipairs(string.Explode("\n",code)) do
		for _,comment in ipairs(FindComments(line)) do
			if ending then
				if comment.type == ending then
					ending = nil
				end
			elseif comment.type == "start" then
				ending = "end"
			elseif comment.type == "string" then
				ending = "string"
			elseif comment.type == "stringblock" then
				ending = "end"
			elseif comment.type == "line" then
				if comment.pos == 1 and line:sub(1,10) == "--@include" then
					-- Found an include statement
					local path = line:sub(11):Trim()
					if path == "" then error("Empty include statement near line "..lineno,0) end
					includes[#includes+1] = path
				end
				ending = "newline"
			end
		end
		
		if ending == "newline" then ending = nil end
	end
	
	return includes
end

function SF_PProcessor.BuildSendList(mainpath, maincode)
	local aincludes = {}
	
	local function recursion(apath,acode)
		if aincludes[apath] then return end
		local f = {
			path = apath,
			code = acode,
			includes = findIncludeStatements(acode)
		}
		aincludes[apath] = f
		for _,inc in ipairs(f.includes) do
			if inc:sub(-4,-1) ~= ".txt" then error(apath..": Tried to include non-text file: "..inc,0) end
			local nextcode = file.Read("Starfall/"..inc)
			if nextcode == nil then error(apath..": Could not find file "..inc,0) end
			recursion(inc,nextcode)
		end
	end
	
	recursion(mainpath, maincode)
	return aincludes
end