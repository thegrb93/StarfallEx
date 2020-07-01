-- Simple helper function that provides model if it doesnt exist
local function registerSent(class, data)
	data[1].model = data[1].model or {"Model", TYPE_STRING, "models/props_junk/watermelon01.mdl"}
	
	list.Set("starfall_creatable_sent", class, data)
end

-- Function to generate some docs, it aint fancy but works i guess
local function genDocs()
	local classes = {"--- "}
	for class, data in pairs(list.Get("starfall_creatable_sent")) do
		local str = {"-- > " .. class}
		for param, org in pairs(data[1]) do
			local typ = type(org[3])
			table.insert(str, string.format("-- %s %s = %q", typ, param, typ == "table" and table.ToString(org[3]) or org[3]))
		end
		
		table.insert(str, "-- ")
		table.insert(classes, table.concat(str, "\n"))
	end
	
	table.insert(classes, "-- @name props_library.SENT_Data_Structures\n-- @class table")
	
	return table.concat(classes, "\n")
end

-- Make them accessable globally
SF.PROPSENT = {
	RegisterSent = registerSent,
	GenerateDocs = genDocs
}

----------------------------------------
-- Basic Gmod sents

registerSent("gmod_balloon", {
	_preFactory = function(self)
		self.r = 255
		self.g = 255
		self.b = 255
	end,
	
	{
		model = {"Model",  TYPE_STRING, "models/maxofs2d/balloon_classic.mdl"},
		force = {"force",  TYPE_NUMBER, 500},
	}
})

registerSent("gmod_button", {{
	model     = {"Model",       TYPE_STRING, "models/maxofs2d/button_05.mdl"},
	label     = {"description", TYPE_STRING, ""},
	key       = {"key",         TYPE_NUMBER, -1},
	toggle    = {"toggle",      TYPE_BOOL,   true},
}})

registerSent("gmod_cameraprop", {{
	model  = {"Model",      TYPE_STRING, "models/dav0r/camera.mdl"},
	key    = {"controlkey", TYPE_NUMBER, -1},
	locked = {"locked",     TYPE_BOOL,   false},
	toggle = {"toggle",     TYPE_BOOL,   true},
}})

registerSent("gmod_dynamite", {{
	model  = {"Model",  TYPE_STRING, "models/dav0r/tnt/tnt.mdl"},
	key    = {"key",    TYPE_NUMBER, -1},
	damage = {"Damage", TYPE_NUMBER, 200},
	delay  = {"delay",  TYPE_NUMBER, 0},
	remove = {"remove", TYPE_BOOL,   false},
}})

registerSent("gmod_emitter", {{
	model     = {"Model",     TYPE_STRING, "models/props_lab/tpplug.mdl"},
	effect    = {"effect",    TYPE_STRING, "sparks"},
	key       = {"key",       TYPE_NUMBER, -1},
	delay     = {"delay",     TYPE_NUMBER, 0},
	scale     = {"scale",     TYPE_NUMBER, 1},
	toggle    = {"toggle",    TYPE_BOOL,   true},
	starton   = {"starton",   TYPE_BOOL,   false},
}})

registerSent("gmod_hoverball", {{
	model      = {"Model",      TYPE_STRING, "models/dav0r/hoverball.mdl"},
	keyup      = {"key_u",      TYPE_NUMBER, -1},
	keydown    = {"key_d",      TYPE_NUMBER, -1},
	speed      = {"speed",      TYPE_NUMBER, 1},
	resistance = {"resistance", TYPE_NUMBER, 0},
	strength   = {"strength",   TYPE_NUMBER, 1},
}})

registerSent("gmod_lamp", {
	_preFactory = function(self)
		self.r = 255
		self.g = 255
		self.b = 255
	end,
	
	{
		model      = {"Model",      TYPE_STRING, "models/lamps/torch.mdl"},
		texture    = {"Texture",    TYPE_STRING, "effects/flashlight001"},
		key        = {"KeyDown",    TYPE_NUMBER, -1},
		fov        = {"fov",        TYPE_NUMBER, 90},
		distance   = {"distance",   TYPE_NUMBER, 1024},
		brightness = {"brightness", TYPE_NUMBER, 4},
		toggle     = {"toggle",     TYPE_BOOL,   true},
		starton    = {"on",         TYPE_BOOL,   false},
	}
})

registerSent("gmod_light", {
	_preFactory = function(self)
		self.lightr = 255
		self.lightg = 255
		self.lightb = 255
	end,
	
	{
		model      = {"Model",      TYPE_STRING, "models/maxofs2d/light_tubular.mdl"},
		key        = {"KeyDown",    TYPE_NUMBER, -1},
		radius     = {"Size",       TYPE_NUMBER, 256},
		brightness = {"Brightness", TYPE_NUMBER, 2},
		toggle     = {"toggle",     TYPE_BOOL,   true},
		starton    = {"on",         TYPE_BOOL,   false},
	}
})

registerSent("gmod_thruster", {{
	model      = {"Model",      TYPE_STRING, "models/props_phx2/garbage_metalcan001a.mdl"},
	effect     = {"effect",     TYPE_STRING, "fire"},
	sound      = {"soundname",  TYPE_STRING, "PhysicsCannister.ThrusterLoop"},
	keyforward = {"key",        TYPE_NUMBER, -1},
	keyback    = {"key_bck",    TYPE_NUMBER, -1},
	force      = {"force",      TYPE_NUMBER, 1500},
	toggle     = {"toggle",     TYPE_BOOL,   false},
	damageable = {"damageable", TYPE_BOOL,   false},
}})

----------------------------------------
-- Docs

--- 
-- > gmod_cameraprop
-- boolean locked = "false"
-- string model = "models/dav0r/camera.mdl"
-- boolean toggle = "true"
-- number key = "-1"
-- 
-- > gmod_button
-- number key = "-1"
-- string model = "models/maxofs2d/button_05.mdl"
-- boolean toggle = "true"
-- string label = ""
-- 
-- > gmod_light
-- boolean toggle = "true"
-- boolean starton = "false"
-- number radius = "256"
-- string model = "models/maxofs2d/light_tubular.mdl"
-- number key = "-1"
-- number brightness = "2"
-- 
-- > gmod_hoverball
-- number keyup = "-1"
-- number speed = "1"
-- number keydown = "-1"
-- string model = "models/dav0r/hoverball.mdl"
-- number strength = "1"
-- number resistance = "0"
-- 
-- > gmod_lamp
-- string texture = "effects/flashlight001"
-- number fov = "90"
-- boolean toggle = "true"
-- number key = "-1"
-- string model = "models/lamps/torch.mdl"
-- number distance = "1024"
-- boolean starton = "false"
-- number brightness = "4"
-- 
-- > gmod_balloon
-- string model = "models/maxofs2d/balloon_classic.mdl"
-- number force = "500"
-- 
-- > gmod_dynamite
-- boolean remove = "false"
-- number delay = "0"
-- number damage = "200"
-- number key = "-1"
-- string model = "models/dav0r/tnt/tnt.mdl"
-- 
-- > gmod_emitter
-- number scale = "1"
-- boolean toggle = "true"
-- number delay = "0"
-- string effect = "sparks"
-- string model = "models/props_lab/tpplug.mdl"
-- boolean starton = "false"
-- number key = "-1"
-- 
-- > gmod_thruster
-- number keyforward = "-1"
-- number keyback = "-1"
-- boolean toggle = "false"
-- number force = "1500"
-- string sound = "PhysicsCannister.ThrusterLoop"
-- string model = "models/props_phx2/garbage_metalcan001a.mdl"
-- string effect = "fire"
-- boolean damageable = "false"
-- 
-- @name props_library.SENT_Data_Structures
-- @class table
