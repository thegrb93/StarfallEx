--@name Console
--@author Sparky
--@server

wire.adjustInputs({ "Keyboard", "Console" }, { "Wirelink", "Wirelink" })

hook.add("input", "getwirelinks", function(name, val)
	if name == "Console" then
		Console = val
	elseif name == "Keyboard" then
		Keyboard = val
	end
end)

local ConsolePos = 0
local ConsoleRow = 0
local ConsoleInit = false

local function updateCursor()
	Console[2045] = ConsolePos
	Console[2046] = 1
end
local function cls()
	Console[2041] = 1
	ConsolePos = 0
	ConsoleRow = 0
	updateCursor()
end
local cincb, cinstart
local function scrollScreen(amount)
	Console[2038] = amount
	cinstart = cinstart - 60
end
local function cout(str, color)
	for I = 1, #str do
		if str[I] == "\n" then
			if ConsoleRow >= 17 then
				scrollScreen(1)
				ConsolePos = ConsolePos - ConsolePos%60
			else
				local lastpos = ConsolePos - 2
				ConsolePos = lastpos + 60 - lastpos%60
				ConsoleRow = ConsoleRow + 1
			end
		else
			Console[ConsolePos] = str:byte(I)
			Console[ConsolePos + 1] = color or 999
			ConsolePos = ConsolePos + 2

			local newline = ConsolePos%60 == 0

			if newline then
				if ConsoleRow >= 17 then
					scrollScreen(1)
					ConsolePos = ConsolePos - 60
				else
					ConsoleRow = ConsoleRow + 1
				end
			end
		end
	end

	updateCursor()
end
local function cin(cb)
	cinstart = ConsolePos
	cincb = cb
end
local function getcin()
	local chars = {}
	for I = cinstart, ConsolePos-2, 2 do
		chars[#chars + 1] = string.char(Console[I])
	end
	return table.concat(chars)
end

key_funcs = {
	[127] = function()
		ConsolePos = math.max(ConsolePos - 2, cinstart)

		if ConsolePos%60 == 0 then
			ConsoleRow = ConsoleRow - 1
		end

		Console[ConsolePos] = 0
		updateCursor()
	end,

	[13] = function()
		if cincb then
			local str = getcin()
			cout("\n")
			cincb(str)
			cincb = nil
		end
	end
}
key_funcs[10] = key_funcs[13]
key_funcs[142] = key_funcs[13]

local function main_loop()
	if not Keyboard or not Console then
		Initialized = false
	else
		if not Initialized then
			Initialized = true
			cls()
			main()
		end
		while Keyboard[0] > 0 do
			local keycode = Keyboard[1]
			if cincb then
				if key_funcs[keycode] then
					key_funcs[keycode]()
				elseif keycode > 31 and keycode < 127 then
					cout(string.char(keycode))
					updateCursor()
				end
			end

			Keyboard[0] = 0
		end
	end
end
hook.add("Think", "Mainloop", main_loop)

function main()
	cout("Type hello: ")
	cin(function(str)
		if str == "hello" then
			cout("Hi!\n")
		else
			cout("WRONG!!!\n", 800999)
		end
		timer.simple(0, main)
	end)
end
