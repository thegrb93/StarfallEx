--@name Console
--@author Sparky

if SERVER then
	
	wire.adjustInputs({"Keyboard","Console"},{"Wirelink","Wirelink"})
	
	hook.add("input","getwirelinks",function(name, val)
		if name == "Console" then
			Console = val
		elseif name == "Keyboard" then
			Keyboard = val
		end
	end)
	
	local ConsolePos = 0
	local ConsoleInit = false
	
	local function updateCursor()
		Console[2045] = ConsolePos
		Console[2046] = 1
	end
	local function cls()
		Console[2041] = 1
		ConsolePos = 0
		updateCursor()
	end
	local function cout(str, color)
		for I=1, #str do
			if str[I] == "\n" then
				while ConsolePos % 60 != 0 do
					Console[ConsolePos] = 0
					ConsolePos = ConsolePos + 2
				end
			else
				Console[ConsolePos] = str:byte(I)
				Console[ConsolePos+1] = color or 999
				ConsolePos = ConsolePos + 2
			end
		end
		updateCursor()
	end
	local cincb, cinstart
	local function cin(cb)
		cinstart = ConsolePos
		cincb = cb
	end
	local function getcin()
		local chars = {}
		for I=cinstart, ConsolePos-2, 2 do
			chars[#chars + 1] = string.char(Console[I])
		end
		return table.concat(chars)
	end
	
	key_funcs = {
		[127] = function()
			Console[ConsolePos] = 0
			updateCursor()
			ConsolePos = math.max(ConsolePos - 2, cinstart)
		end,
		[9] = function() end,
		[13] = function() 
			if cincb then
				local str = getcin()
				cout("\n")
				cincb(str)
				cincb = nil
			end
		end,
		[154] = function() end,
		[155] = function() end,
		[158] = function() end,
		[159] = function() end,
	}
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
				if cincb then
					if key_funcs[Keyboard[1]] then key_funcs[Keyboard[1]]()
					else
						--print(Keyboard[1])
						Console[ConsolePos] = Keyboard[1]
						Console[ConsolePos+1] = 999
						
						ConsolePos = ConsolePos + 2
						updateCursor()
					end
				end
			
				Keyboard[0] = 0
			end
		end
	end
	hook.add("Think","Mainloop",main_loop)

	function main()
		cout("Type hello: ")
		cin(function(str)
			if str == "hello" then
				cout("Hi!\n")
			else
				cout("WRONG!!!\n",800999)
			end
			timer.simple(0,main)
		end)
	end
end
