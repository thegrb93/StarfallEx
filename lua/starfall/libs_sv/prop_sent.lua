-- Simple helper function that provides model if it doesnt exist
local function registerSent(class, data)
	if not data[1].model then
		data[1].model = {"Model", TYPE_STRING, "models/props_junk/watermelon01.mdl"}
	end
	
	list.Set("starfall_creatable_sent", class, data)
end

local function castColor(tbl, allow_alpha)
	return tonumber(tbl[1] or tbl.r) or 255,
	       tonumber(tbl[2] or tbl.g) or 255,
	       tonumber(tbl[3] or tbl.b) or 255,
	       allow_alpha and tonumber(tbl[4] or tbl.a) or 255
end

-- Function to generate some docs, it aint fancy but works i guess
local function genDocs()
	local classes = {"--- "}
	
	--
	
	local sorted = {}
	for class, data in pairs(list.Get("starfall_creatable_sent")) do
		local undercount = 0
		for i = 1, #class do
			if class[i] == "_" then
				undercount = undercount + 1
			end
		end
		
		table.insert(sorted, {class = class, class_length = #class, undercount = undercount, data = data})
	end
	
	table.sort(sorted, function(a, b)
		if a.undercount < b.undercount then
			return true
		elseif a.undercount == b.undercount then
			for i = 1, a.class_length do
				local ab, bb = string.byte(a.class[i]), string.byte(b.class[i])
				
				if ab < bb then
					return true
				elseif ab > bb then
					return false
				end
			end
			
			return a.class_length < b.class_length
		end
		
		return false
	end)
	
	for _, data in pairs(sorted) do
		local str = {"-- > " .. data.class}
		for param, org in pairs(data.data[1]) do
			local typ = type(org[3])
			table.insert(str, string.format("-- %s %s = %q", typ, param, typ == "table" and table.ToString(org[3]) or org[3]))
		end
		
		table.insert(str, "-- ")
		table.insert(classes, table.concat(str, "\n"))
	end
	
	--
	
	table.insert(classes, "-- @name props_library.SENT_Data_Structures\n-- @class table")
	
	for _, str in ipairs(classes) do
		print(str)
	end
end

-- Make them accessable globally
SF.PROPSENT = {
	RegisterSent = registerSent,
	GenerateDocs = genDocs,
	CastColor    = castColor,
}

----------------------------------------
-- Sent registering
local checkluatype = SF.CheckLuaType

-- Basic Gmod sents
registerSent("gmod_balloon", {
	_preFactory = function(ply, self)
		self.r, self.g, self.b = castColor(self._color)
	end,
	
	{
		model = {"Model",  TYPE_STRING, "models/maxofs2d/balloon_classic.mdl"},
		force = {"force",  TYPE_NUMBER, 500},
		color = {"_color", TYPE_TABLE,  {255, 255, 255}},
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
	model   = {"Model",   TYPE_STRING, "models/props_lab/tpplug.mdl"},
	effect  = {"effect",  TYPE_STRING, "sparks"},
	key     = {"key",     TYPE_NUMBER, -1},
	delay   = {"delay",   TYPE_NUMBER, 0},
	scale   = {"scale",   TYPE_NUMBER, 1},
	toggle  = {"toggle",  TYPE_BOOL,   true},
	starton = {"starton", TYPE_BOOL,   false},
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
	_preFactory = function(ply, self)
		self.r, self.g, self.b = castColor(self._color)
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
		color      = {"_color",     TYPE_TABLE,  {255, 255, 255}},
	}
})

registerSent("gmod_light", {
	_preFactory = function(ply, self)
		self.lightr, self.lightg, self.lightb = castColor(self._color)
	end,
	
	{
		model      = {"Model",      TYPE_STRING, "models/maxofs2d/light_tubular.mdl"},
		key        = {"KeyDown",    TYPE_NUMBER, -1},
		radius     = {"Size",       TYPE_NUMBER, 256},
		brightness = {"Brightness", TYPE_NUMBER, 2},
		toggle     = {"toggle",     TYPE_BOOL,   true},
		starton    = {"on",         TYPE_BOOL,   false},
		color      = {"_color",     TYPE_TABLE,  {255, 255, 255}},
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
-- Wiremod

-- Timer so that we are sure to check after wiremod initialized, if wire has a hook.run / call when it initialized change this
timer.Simple(0, function()
if WireLib then

registerSent("gmod_wire_spawner", {
	_preFactory = function(ply, self)
		self.r, self.g, self.b, self.a = castColor(self._color, true)
	end,
	
	{
		delay        = {"delay",        TYPE_NUMBER, 0},
		undo_delay   = {"undo_delay",   TYPE_NUMBER, 0},
		spawn_effect = {"spawn_effect", TYPE_NUMBER, 0},
		mat          = {"mat",          TYPE_STRING, ""},
		color        = {"_color",       TYPE_TABLE,  {255, 255, 255, 255}},
		skin         = {"skin",         TYPE_NUMBER, 0},
	}
})

registerSent("gmod_wire_emarker", {{
	model = {"Model", TYPE_STRING, "models/jaanus/wiretool/wiretool_siren.mdl"},
}})

registerSent("gmod_wire_forcer", {{
	model    = {"Model",    TYPE_STRING, "models/jaanus/wiretool/wiretool_siren.mdl"},
	force    = {"Force",    TYPE_NUMBER, 1},
	length   = {"Length",   TYPE_NUMBER, 100},
	showbeam = {"ShowBeam", TYPE_BOOL,   true},
	reaction = {"Reaction", TYPE_BOOL,   false},
}})

registerSent("gmod_wire_adv_input", {{
	model       = {"Model",       TYPE_STRING, "models/beer/wiremod/numpad.mdl"},
	keymore     = {"keymore",     TYPE_NUMBER, 3},
	keyless     = {"keyless",     TYPE_NUMBER, 1},
	toggle      = {"toggle",      TYPE_BOOL,   false},
	value_min   = {"value_min",   TYPE_NUMBER, 0},
	value_max   = {"value_max",   TYPE_NUMBER, 10},
	value_start = {"value_start", TYPE_NUMBER, 5},
	speed       = {"speed",       TYPE_NUMBER, 1},
}})

registerSent("gmod_wire_oscilloscope", {{
	model = {"Model", TYPE_STRING, "models/props_lab/monitor01b.mdl"},
}})

registerSent("gmod_wire_dhdd", {{
}})

registerSent("gmod_wire_friendslist", {{
	model          = {"Model",          TYPE_STRING, "models/kobilica/value.mdl"},
	save_on_entity = {"save_on_entity", TYPE_BOOL,   false},
}})

registerSent("gmod_wire_nailer", {{
	model    = {"Model",    TYPE_STRING, "models/jaanus/wiretool/wiretool_siren.mdl"},
	flim     = {"Flim",     TYPE_NUMBER, 0},
	range    = {"Range",    TYPE_NUMBER, 100},
	showbeam = {"ShowBeam", TYPE_BOOL,   true},
}})

registerSent("gmod_wire_grabber", {{
	model   = {"Model",   TYPE_STRING, "models/jaanus/wiretool/wiretool_range.mdl"},
	range   = {"Range",   TYPE_NUMBER, 100},
	gravity = {"Gravity", TYPE_BOOL,   true},
}})

registerSent("gmod_wire_weight", {{
	model = {"Model", TYPE_STRING, "models/props_interiors/pot01a.mdl"},
}})

registerSent("gmod_wire_exit_point", {{
	model = {"Model", TYPE_STRING, "models/jaanus/wiretool/wiretool_range.mdl"},
}})

registerSent("gmod_wire_latch", {{
	model = {"Model", TYPE_STRING, "models/jaanus/wiretool/wiretool_siren.mdl"},
}})

registerSent("gmod_wire_dataport", {{
	model = {"Model", TYPE_STRING, "models/jaanus/wiretool/wiretool_gate.mdl"},
}})

registerSent("gmod_wire_colorer", {{
	model    = {"Model",    TYPE_STRING, "models/jaanus/wiretool/wiretool_siren.mdl"},
	outcolor = {"outColor", TYPE_BOOL,   false},
	range    = {"Range",    TYPE_NUMBER, 2000},
}})

registerSent("gmod_wire_addressbus", {{
	model  = {"Model",  TYPE_STRING, "models/jaanus/wiretool/wiretool_gate.mdl"},
	mem1st = {"Mem1st", TYPE_NUMBER, 0},
	mem2st = {"Mem2st", TYPE_NUMBER, 0},
	mem3st = {"Mem3st", TYPE_NUMBER, 0},
	mem4st = {"Mem4st", TYPE_NUMBER, 0},
	mem1sz = {"Mem1sz", TYPE_NUMBER, 0},
	mem2sz = {"Mem2sz", TYPE_NUMBER, 0},
	mem3sz = {"Mem3sz", TYPE_NUMBER, 0},
	mem4sz = {"Mem4sz", TYPE_NUMBER, 0},
}})

registerSent("gmod_wire_cd_disk", {{
	model     = {"Model",     TYPE_STRING, "models/venompapa/wirecd_medium.mdl"},
	precision = {"Precision", TYPE_NUMBER, 4},
	iradius   = {"IRadius",   TYPE_NUMBER, 10},
	skin      = {"Skin",      TYPE_NUMBER, 0},
}})

registerSent("gmod_wire_las_receiver", {{
	model = {"Model", TYPE_STRING, "models/jaanus/wiretool/wiretool_range.mdl"},
}})

registerSent("gmod_wire_lever", {{
	min = {"Min", TYPE_NUMBER, 0},
	max = {"Max", TYPE_NUMBER, 1},
}})

registerSent("gmod_wire_waypoint", {{
	model = {"Model", TYPE_STRING, "models/props_lab/powerbox02d.mdl"},
	range = {"range", TYPE_NUMBER, 150},
}})

registerSent("gmod_wire_vehicle", {{
	model = {"Model", TYPE_STRING, "models/jaanus/wiretool/wiretool_siren.mdl"},
}})

registerSent("gmod_wire_vectorthruster", {{
	model       = {"Model",       TYPE_STRING, "models/jaanus/wiretool/wiretool_speed.mdl"},
	force       = {"force",       TYPE_NUMBER, 1500},
	force_min   = {"force_min",   TYPE_NUMBER, 0},
	force_max   = {"force_max",   TYPE_NUMBER, 10000},
	oweffect    = {"oweffect",    TYPE_STRING, "fire"},
	uweffect    = {"uweffect",    TYPE_STRING, "same"},
	owater      = {"owater",      TYPE_BOOL,   true},
	uwater      = {"uwater",      TYPE_BOOL,   true},
	bidir       = {"bidir",       TYPE_BOOL,   true},
	soundname   = {"soundname",   TYPE_STRING, ""},
	mode        = {"mode",        TYPE_NUMBER, 0},
	angleinputs = {"angleinputs", TYPE_BOOL,   false},
	lengthismul = {"lengthismul", TYPE_BOOL,   false},
}})

registerSent("gmod_wire_user", {{
	model = {"Model", TYPE_STRING, "models/jaanus/wiretool/wiretool_siren.mdl"},
	range = {"Range", TYPE_NUMBER, 200},
}})

registerSent("gmod_wire_twoway_radio", {{
	model = {"Model", TYPE_STRING, "models/props_lab/binderblue.mdl"},
}})

registerSent("gmod_wire_numpad", {{
	model     = {"Model",     TYPE_STRING, "models/beer/wiremod/numpad.mdl"},
	toggle    = {"toggle",    TYPE_BOOL,   false},
	value_off = {"value_off", TYPE_NUMBER, 0},
	value_on  = {"value_on",  TYPE_NUMBER, 0},
}})

registerSent("gmod_wire_turret", {{
	model      = {"Model",      TYPE_STRING, "models/weapons/w_smg1.mdl"},
	delay      = {"delay",      TYPE_NUMBER, 0.05},
	damage     = {"damage",     TYPE_NUMBER, 10},
	force      = {"force",      TYPE_NUMBER, 1},
	sound      = {"sound",      TYPE_STRING, "0"},
	numbullets = {"numbullets", TYPE_NUMBER, 1},
	spread     = {"spread",     TYPE_NUMBER, 0},
	tracer     = {"tracer",     TYPE_STRING, "Tracer"},
	tracernum  = {"tracernum",  TYPE_NUMBER, 1},
}})

registerSent("gmod_wire_soundemitter", {{
	model = {"Model", TYPE_STRING, "models/cheeze/wires/speaker.mdl"},
	sound = {"sound", TYPE_STRING, "synth/square.wav"},
}})

registerSent("gmod_wire_textscreen", {
	_preFactory = function(ply, self)
		self.fgcolor = Color(castColor(self._fgcolor))
		self.bgcolor = Color(castColor(self._bgcolor))
	end,
	
	{
		model      = {"Model",      TYPE_STRING, "models/kobilica/wiremonitorbig.mdl"},
		text       = {"text",       TYPE_STRING, ""},
		chrperline = {"chrPerLine", TYPE_NUMBER, 6},
		textjust   = {"textJust",   TYPE_NUMBER, 1},
		valign     = {"valign",     TYPE_NUMBER, 0},
		tfont      = {"tfont",      TYPE_STRING, "Arial"},
		fgcolor    = {"_fgcolor",   TYPE_TABLE,  {255, 255, 255}},
		bgcolor    = {"_bgcolor",   TYPE_TABLE,  {0, 0, 0}},
	}
})

registerSent("gmod_wire_holoemitter", {{
	model = {"Model", TYPE_STRING, "models/jaanus/wiretool/wiretool_range.mdl"},
}})

registerSent("gmod_wire_textreceiver", {
	_preFactory = function(ply, self)
		self.Matches = {}
		
		for i, str in ipairs(self._matches) do
			checkluatype(str, TYPE_STRING, 2, "Parameter: matches[" .. i .. "]")
			self.Matches[i] = str
		end
	end,
	
	{
		model           = {"Model",           TYPE_STRING, "models/jaanus/wiretool/wiretool_range.mdl"},
		useluapatterns  = {"UseLuaPatterns",  TYPE_BOOL,   false},
		matches         = {"_matches",        TYPE_TABLE,  {"Hello World"}},
		caseinsensitive = {"CaseInsensitive", TYPE_BOOL,   true},
	}
})

registerSent("gmod_wire_textentry", {{
	model = {"Model", TYPE_STRING, "models/beer/wiremod/keyboard.mdl"},
}})

registerSent("gmod_wire_teleporter", {{
	model      = {"Model",      TYPE_STRING, "models/props_c17/utilityconducter001.mdl"},
	usesounds  = {"UseSounds",  TYPE_BOOL,   true},
	useeffects = {"UseEffects", TYPE_BOOL,   true},
}})

registerSent("gmod_wire_target_finder", {
	_preFactory = function(ply, self)
		self.pcolR, self.pcolG, self.pcolB, self.pcolA = castColor(self._pcolor, true)
	end,
	
	{
		model          = {"Model",          TYPE_STRING, "models/beer/wiremod/targetfinder.mdl"},
		range          = {"range",          TYPE_NUMBER, 1000},
		players        = {"players",        TYPE_BOOL,   false},
		npcs           = {"npcs",           TYPE_BOOL,   true},
		npcname        = {"npcname",        TYPE_STRING, ""},
		beacons        = {"beacons",        TYPE_BOOL,   false},
		hoverballs     = {"hoverballs",     TYPE_BOOL,   false},
		thrusters      = {"thrusters",      TYPE_BOOL,   false},
		props          = {"props",          TYPE_BOOL,   false},
		propmodel      = {"propmodel",      TYPE_STRING, ""},
		vehicles       = {"vehicles",       TYPE_BOOL,   false},
		playername     = {"playername",     TYPE_STRING, ""},
		casesen        = {"casesen",        TYPE_BOOL,   false},
		rpgs           = {"rpgs",           TYPE_BOOL,   false},
		painttarget    = {"painttarget",    TYPE_BOOL,   true},
		minrange       = {"minrange",       TYPE_NUMBER, 1},
		maxtargets     = {"maxtargets",     TYPE_NUMBER, 1},
		maxbogeys      = {"maxbogeys",      TYPE_NUMBER, 1},
		notargetowner  = {"notargetowner",  TYPE_BOOL,   false},
		entity         = {"entity",         TYPE_STRING, ""},
		notownersstuff = {"notownersstuff", TYPE_BOOL,   false},
		steamname      = {"steamname",      TYPE_STRING, ""},
		colorcheck     = {"colorcheck",     TYPE_BOOL,   false},
		colortarget    = {"colortarget",    TYPE_BOOL,   false},
		pcolor         = {"_pcolor",        TYPE_TABLE,  {255, 255, 255, 255}},
		checkbuddylist = {"checkbuddylist", TYPE_BOOL,   false},
		onbuddylist    = {"onbuddylist",    TYPE_BOOL,   false},
	}
})

registerSent("gmod_wire_digitalscreen", {{
	model  = {"Model",        TYPE_STRING, "models/props_lab/monitor01b.mdl"},
	width  = {"ScreenWidth",  TYPE_NUMBER, 32},
	height = {"ScreenHeight", TYPE_NUMBER, 32},
}})

registerSent("gmod_wire_trail", {
	_preFactory = function(ply, self)
		self.Trail = {}
	end,
	
	_postFactory = function(ply, self, enttbl)
		self.Trail = {
			Color     = Color(castColor(enttbl._color, true)),
			Length    = enttbl._length,
			StartSize = enttbl._start_size,
			EndSize   = enttbl._end_size,
			Material  = enttbl._material
		}
	end,

	{
		color      = {"_color",      TYPE_TABLE,  {255, 255, 255, 255}},
		length     = {"_length",     TYPE_NUMBER, 5},
		start_size = {"_start_size", TYPE_NUMBER, 32},
		end_size   = {"_end_size",   TYPE_NUMBER, 0},
		material   = {"_material",   TYPE_STRING, "trails/lol"},
	}
})

registerSent("gmod_wire_egp", {
	_preFactory = function(ply, self)
		self.model = self.Model
	end,
	
	{
		model = {"Model", TYPE_STRING, "models/kobilica/wiremonitorbig.mdl"},
	}
})

registerSent("gmod_wire_egp_hud", {{
	model = {"Model", TYPE_STRING, "models/bull/dynamicbutton.mdl"},
}})

registerSent("gmod_wire_egp_emitter", {{
	model = {"Model", TYPE_STRING, "models/bull/dynamicbutton.mdl"},
}})

registerSent("gmod_wire_speedometer", {{
	xyz_mode = {"z_only", TYPE_BOOL, false},
	angvel   = {"AngVel", TYPE_BOOL, false},
}})

registerSent("gmod_wire_trigger", {
	_preFactory = function(ply, self)
		self.model = self.Model
	end,
	
	{
		model     = {"Model",     TYPE_STRING, "models/jaanus/wiretool/wiretool_siren.mdl"},
		filter    = {"filter",    TYPE_NUMBER, 0},
		owneronly = {"owneronly", TYPE_BOOL,   false},
		sizex     = {"sizex",     TYPE_NUMBER, 64},
		sizey     = {"sizey",     TYPE_NUMBER, 64},
		sizez     = {"sizez",     TYPE_NUMBER, 64},
		offsetx   = {"offsetx",   TYPE_NUMBER, 0},
		offsety   = {"offsety",   TYPE_NUMBER, 0},
		offsetz   = {"offsetz",   TYPE_NUMBER, 0},
	}
})

registerSent("gmod_wire_socket", {{
	model       = {"Model",       TYPE_STRING, "models/props_lab/tpplugholder_single.mdl"},
	arrayinput  = {"ArrayInput",  TYPE_BOOL,   false},
	weldforce   = {"WeldForce",   TYPE_NUMBER, 5000},
	attachrange = {"AttachRange", TYPE_NUMBER, 5},
}})

registerSent("gmod_wire_simple_explosive", {{
	model       = {"Model",       TYPE_STRING, "models/props_c17/oildrum001_explosive.mdl"},
	trigger     = {"key",         TYPE_NUMBER, 1},
	damage      = {"damage",      TYPE_NUMBER, 200},
	removeafter = {"removeafter", TYPE_BOOL,   false},
	radius      = {"radius",      TYPE_NUMBER, 300},
}})

registerSent("gmod_wire_sensor", {{
	xyz_mode             = {"xyz_mode",             TYPE_BOOL, false},
	outdist              = {"outdist",              TYPE_BOOL, true},
	outbrng              = {"outbrng",              TYPE_BOOL, false},
	gpscord              = {"gpscord",              TYPE_BOOL, false},
	direction_vector     = {"direction_vector",     TYPE_BOOL, false},
	direction_normalized = {"direction_normalized", TYPE_BOOL, false},
	target_velocity      = {"target_velocity",      TYPE_BOOL, false},
	velocity_normalized  = {"velocity_normalized",  TYPE_BOOL, false},
}})

registerSent("gmod_wire_screen", {{
	model         = {"Model",         TYPE_STRING, "models/props_lab/monitor01b.mdl"},
	singlevalue   = {"SingleValue",   TYPE_BOOL,   false},
	singlebigfont = {"SingleBigFont", TYPE_BOOL,   true},
	texta         = {"TextA",         TYPE_STRING, "Value A"},
	textb         = {"TextB",         TYPE_STRING, "Value B"},
	leftalign     = {"LeftAlign",     TYPE_BOOL,   false},
	floor         = {"Floor",         TYPE_BOOL,   false},
	formatnumber  = {"FormatNumber",  TYPE_BOOL,   false},
	formattime    = {"FormatTime",    TYPE_BOOL,   false},
}})

registerSent("gmod_wire_detonator", {{
	model  = {"Model",  TYPE_STRING, "models/props_combine/breenclock.mdl"},
	damage = {"damage", TYPE_NUMBER, 1},
}})

registerSent("gmod_wire_relay", {{
	model       = {"Model",       TYPE_STRING, "models/kobilica/relay.mdl"},
	keygroup1   = {"keygroup1",   TYPE_NUMBER, 1},
	keygroup2   = {"keygroup2",   TYPE_NUMBER, 2},
	keygroup3   = {"keygroup3",   TYPE_NUMBER, 3},
	keygroup4   = {"keygroup4",   TYPE_NUMBER, 4},
	keygroup5   = {"keygroup5",   TYPE_NUMBER, 5},
	keygroupoff = {"keygroupoff", TYPE_NUMBER, 0},
	toggle      = {"toggle",      TYPE_BOOL,   true},
	normclose   = {"normclose",   TYPE_NUMBER, 0},
	poles       = {"poles",       TYPE_NUMBER, 1},
	throws      = {"throws",      TYPE_NUMBER, 2},
	nokey       = {"nokey",       TYPE_BOOL,   false},
}})

registerSent("gmod_wire_ranger", {{
	model        = {"Model",        TYPE_STRING, "models/jaanus/wiretool/wiretool_range.mdl"},
	range        = {"range",        TYPE_NUMBER, 1500},
	default_zero = {"default_zero", TYPE_BOOL,   true},
	show_beam    = {"show_beam",    TYPE_BOOL,   true},
	ignore_world = {"ignore_world", TYPE_BOOL,   false},
	trace_water  = {"trace_water",  TYPE_BOOL,   false},
	out_dist     = {"out_dist",     TYPE_BOOL,   true},
	out_pos      = {"out_pos",      TYPE_BOOL,   false},
	out_vel      = {"out_vel",      TYPE_BOOL,   false},
	out_ang      = {"out_ang",      TYPE_BOOL,   false},
	out_col      = {"out_col",      TYPE_BOOL,   false},
	out_val      = {"out_val",      TYPE_BOOL,   false},
	out_sid      = {"out_sid",      TYPE_BOOL,   false},
	out_uid      = {"out_uid",      TYPE_BOOL,   false},
	out_eid      = {"out_eid",      TYPE_BOOL,   false},
	out_hnrm     = {"out_hnrm",     TYPE_BOOL,   false},
	hires        = {"hires",        TYPE_BOOL,   false},
}})

registerSent("gmod_wire_radio", {{
	model   = {"Model",   TYPE_STRING, "models/props_lab/binderblue.mdl"},
	channel = {"Channel", TYPE_STRING, "1"},
	values  = {"values",  TYPE_NUMBER, 4},
	secure  = {"Secure",  TYPE_BOOL,   false},
}})

registerSent("gmod_wire_thruster", {{
	model     = {"Model",     TYPE_STRING, "models/props_c17/lampShade001a.mdl"},
	force     = {"force",     TYPE_NUMBER, 1500},
	force_min = {"force_min", TYPE_NUMBER, 0},
	force_max = {"force_max", TYPE_NUMBER, 10000},
	oweffect  = {"oweffect",  TYPE_STRING, "fire"},
	uweffect  = {"uweffect",  TYPE_STRING, "same"},
	owater    = {"owater",    TYPE_BOOL,   true},
	uwater    = {"uwater",    TYPE_BOOL,   true},
	bidir     = {"bidir",     TYPE_BOOL,   true},
	soundname = {"soundname", TYPE_STRING, ""},
}})

registerSent("gmod_wire_pod", {{
	model = {"Model", TYPE_STRING, "models/jaanus/wiretool/wiretool_siren.mdl"},
}})

registerSent("gmod_wire_data_satellitedish", {{
	model = {"Model", TYPE_STRING, "models/props_wasteland/prison_lamp001c.mdl"},
}})

registerSent("gmod_wire_consolescreen", {{
	model = {"Model", TYPE_STRING, "models/props_lab/monitor01b.mdl"},
}})

registerSent("gmod_wire_pixel", {{
	model = {"Model", TYPE_STRING, "models/jaanus/wiretool/wiretool_siren.mdl"},
}})

registerSent("gmod_wire_output", {{
	model = {"Model", TYPE_STRING, "models/beer/wiremod/numpad.mdl"},
	key   = {"key",   TYPE_NUMBER, 1},
}})

-- TODO: gmod_wire_motor, dont wanna deal with constraints atm

registerSent("gmod_wire_explosive", {{
	model           = {"Model",           TYPE_STRING, "models/props_c17/oildrum001_explosive.mdl"},
	key             = {"key",             TYPE_NUMBER, 1},
	damage          = {"damage",          TYPE_NUMBER, 200},
	delaytime       = {"delaytime",       TYPE_NUMBER, 0},
	removeafter     = {"removeafter",     TYPE_BOOL,   false},
	radius          = {"radius",          TYPE_NUMBER, 300},
	affectother     = {"affectother",     TYPE_BOOL,   false},
	notaffected     = {"notaffected",     TYPE_BOOL,   false},
	delayreloadtime = {"delayreloadtime", TYPE_NUMBER, 0},
	maxhealth       = {"maxhealth",       TYPE_NUMBER, 100},
	bulletproof     = {"bulletproof",     TYPE_BOOL,   false},
	explosionproof  = {"explosionproof",  TYPE_BOOL,   false},
	fallproof       = {"fallproof",       TYPE_BOOL,   false},
	explodeatzero   = {"explodeatzero",   TYPE_BOOL,   true},
	resetatexplode  = {"resetatexplode",  TYPE_BOOL,   true},
	fireeffect      = {"fireeffect",      TYPE_BOOL,   true},
	coloreffect     = {"coloreffect",     TYPE_BOOL,   true},
	invisibleatzero = {"invisibleatzero", TYPE_BOOL,   false},
}})

registerSent("gmod_wire_light", {
	_preFactory = function(ply, self)
		self.R, self.G, self.B = castColor(self._color)
	end,
	
	{
		model       = {"Model",       TYPE_STRING, "models/jaanus/wiretool/wiretool_siren.mdl"},
		directional = {"directional", TYPE_BOOL,   false},
		radiant     = {"radiant",     TYPE_BOOL,   false},
		glow        = {"glow",        TYPE_BOOL,   false},
		brightness  = {"brightness",  TYPE_NUMBER, 2},
		size        = {"size",        TYPE_NUMBER, 256},
		color       = {"_color",      TYPE_TABLE,  {255, 255, 255}},
	}
})

registerSent("gmod_wire_lamp", {
	_preFactory = function(ply, self)
		self.r, self.g, self.b = castColor(self._color)
	end,
	
	{
		model      = {"Model",      TYPE_STRING, "models/lamps/torch.mdl"},
		color      = {"_color",     TYPE_TABLE,  {255, 255, 255}},
		texture    = {"Texture",    TYPE_STRING, "effects/flashlight001"},
		fov        = {"FOV",        TYPE_NUMBER, 90},
		dist       = {"Dist",       TYPE_NUMBER, 1024},
		brightness = {"Brightness", TYPE_NUMBER, 8},
		on         = {"on",         TYPE_BOOL,   false},
	}
})

registerSent("gmod_wire_keypad", {
	_preFactory = function(ply, self)
		self.Password = util.CRC(self._password)
	end,
	
	{
		model    = {"Model",     TYPE_STRING, "models/props_lab/keypad.mdl"},
		password = {"_password", TYPE_STRING, ""},
		secure   = {"Secure",    TYPE_BOOL,   false},
	}
})

registerSent("gmod_wire_data_store", {{
	model = {"Model", TYPE_STRING, "models/jaanus/wiretool/wiretool_range.mdl"},
}})

registerSent("gmod_wire_gpulib_controller", {{
	model = {"Model", TYPE_STRING, "models/jaanus/wiretool/wiretool_siren.mdl"},
}})

registerSent("gmod_wire_clutch", {{
	model = {"Model", TYPE_STRING, "models/jaanus/wiretool/wiretool_siren.mdl"},
}})

registerSent("gmod_wire_input", {{
	model     = {"Model",     TYPE_STRING, "models/beer/wiremod/numpad.mdl"},
	keygroup  = {"keygroup",  TYPE_NUMBER, 7},
	toggle    = {"toggle",    TYPE_BOOL,   false},
	value_off = {"value_off", TYPE_NUMBER, 0},
	value_on  = {"value_on",  TYPE_NUMBER, 1},
}})

registerSent("gmod_wire_indicator", {
	_preFactory = function(ply, self)
		self.ar, self.ag, self.ab, self.aa = castColor(self._acolor, true)
		self.br, self.bg, self.bb, self.ba = castColor(self._bcolor, true)
	end,
	
	{
		model  = {"Model",   TYPE_STRING, "models/segment.mdl"},
		a      = {"a",       TYPE_NUMBER, 0},
		acolor = {"_acolor", TYPE_TABLE,  {255, 0, 0, 255}},
		b      = {"b",       TYPE_NUMBER, 1},
		bcolor = {"_bcolor", TYPE_TABLE,  {0, 255, 0, 255}},
	}
})

registerSent("gmod_wire_igniter", {{
	model         = {"Model",         TYPE_STRING, "models/jaanus/wiretool/wiretool_siren.mdl"},
	targetplayers = {"TargetPlayers", TYPE_BOOL,   false},
	range         = {"Range",         TYPE_NUMBER, 2048},
}})

-- TODO: gmod_wire_hydraulic, it do be constraint thing

registerSent("gmod_wire_hudindicator", {
	_preFactory = function(ply, self)
		self.ar, self.ag, self.ab, self.aa = castColor(self._acolor, true)
		self.br, self.bg, self.bb, self.ba = castColor(self._bcolor, true)
	end,
	
	{
		model           = {"Model",           TYPE_STRING, "models/jaanus/wiretool/wiretool_siren.mdl"},
		a               = {"a",               TYPE_NUMBER, 0},
		acolor          = {"_acolor",         TYPE_TABLE,  {255, 0, 0, 255}},
		b               = {"b",               TYPE_NUMBER, 1},
		bcolor          = {"_bcolor",         TYPE_TABLE,  {0, 255, 0, 255}},
		material        = {"material",        TYPE_STRING, "models/debug/debugwhite"},
		showinhud       = {"showinhud",       TYPE_BOOL,   false},
		huddesc         = {"huddesc",         TYPE_STRING, ""},
		hudaddname      = {"hudaddname",      TYPE_BOOL,   false},
		hudshowvalue    = {"hudshowvalue",    TYPE_NUMBER, 0},
		hudstyle        = {"hudstyle",        TYPE_NUMBER, 0},
		allowhook       = {"allowhook",       TYPE_BOOL,   true},
		fullcircleangle = {"fullcircleangle", TYPE_NUMBER, 0},
	}
})

registerSent("gmod_wire_hoverball", {{
	model      = {"Model",      TYPE_STRING, "models/dav0r/hoverball.mdl"},
	speed      = {"speed",      TYPE_NUMBER, 1},
	resistance = {"resistance", TYPE_NUMBER, 0},
	strength   = {"strength",   TYPE_NUMBER, 1},
	starton    = {"starton",    TYPE_BOOL,   true},
}})

registerSent("gmod_wire_fx_emitter", {
	_preFactory = function(ply, self)
		self.effect = ComboBox_Wire_FX_Emitter_Options[self._effect]
	end,
	
	{
		model  = {"Model",   TYPE_STRING, "models/props_lab/tpplug.mdl"},
		delay  = {"delay",   TYPE_NUMBER, 0.07},
		effect = {"_effect", TYPE_STRING, "sparks"},
	}
})

registerSent("gmod_wire_hologrid", {{
	model  = {"Model",  TYPE_STRING, "models/jaanus/wiretool/wiretool_siren.mdl"},
	usegps = {"usegps", TYPE_BOOL,   false},
}})

registerSent("gmod_wire_data_transferer", {{
	model       = {"Model",       TYPE_STRING, "models/jaanus/wiretool/wiretool_siren.mdl"},
	range       = {"Range",       TYPE_NUMBER, 25000},
	defaultzero = {"DefaultZero", TYPE_BOOL,   false},
	ignorezero  = {"IgnoreZero",  TYPE_BOOL,   false},
}})

registerSent("gmod_wire_graphics_tablet", {{
	model           = {"Model",           TYPE_STRING, "models/kobilica/wiremonitorbig.mdl"},
	cursor_mode     = {"gmode",           TYPE_BOOL,   false},
	draw_background = {"draw_background", TYPE_BOOL,   true},
}})

registerSent("gmod_wire_gps", {{
	model = {"Model", TYPE_STRING, "models/beer/wiremod/gps.mdl"},
}})

registerSent("gmod_wire_gimbal", {{
	model = {"Model", TYPE_STRING, "models/props_c17/canister01a.mdl"},
}})

registerSent("gmod_wire_button", {{
	model       = {"Model",       TYPE_STRING, "models/props_c17/clock01.mdl"},
	toggle      = {"toggle",      TYPE_BOOL,   false},
	value_off   = {"value_off",   TYPE_NUMBER, 0},
	value_on    = {"value_on",    TYPE_NUMBER, 1},
	description = {"description", TYPE_STRING, ""},
	entityout   = {"entityout",   TYPE_BOOL,   false},
}})

registerSent("gmod_wire_extbus", {{
	model = {"Model", TYPE_STRING, "models/jaanus/wiretool/wiretool_gate.mdl"},
}})

registerSent("gmod_wire_locator", {{
	model = {"Model", TYPE_STRING, "models/props_lab/powerbox02d.mdl"},
}})

registerSent("gmod_wire_cameracontroller", {{
	model                  = {"Model",                  TYPE_STRING, "models/jaanus/wiretool/wiretool_siren.mdl"},
	parentlocal            = {"ParentLocal",            TYPE_BOOL,   false},
	automove               = {"AutoMove",               TYPE_BOOL,   false},
	freemove               = {"FreeMove",               TYPE_BOOL,   false},
	localmove              = {"LocalMove",              TYPE_BOOL,   false},
	allowzoom              = {"AllowZoom",              TYPE_BOOL,   false},
	autounclip             = {"AutoUnclip",             TYPE_BOOL,   false},
	drawplayer             = {"DrawPlayer",             TYPE_BOOL,   true},
	autounclip_ignorewater = {"AutoUnclip_IgnoreWater", TYPE_BOOL,   false},
	drawparent             = {"DrawParent",             TYPE_BOOL,   true},
}})

registerSent("gmod_wire_dual_input", {{
	model     = {"Model",     TYPE_STRING, "models/beer/wiremod/numpad.mdl"},
	keygroup  = {"keygroup",  TYPE_NUMBER, 7},
	keygroup2 = {"keygroup2", TYPE_NUMBER, 4},
	toggle    = {"toggle",    TYPE_BOOL,   false},
	value_off = {"value_off", TYPE_NUMBER, 0},
	value_on  = {"value_on",  TYPE_NUMBER, 1},
	value_on2 = {"value_on2", TYPE_NUMBER, -1},
}})

registerSent("gmod_wire_cd_ray", {{
	model       = {"Model",       TYPE_STRING, "models/jaanus/wiretool/wiretool_beamcaster.mdl"},
	range       = {"Range",       TYPE_NUMBER, 64},
	defaultzero = {"DefaultZero", TYPE_BOOL,   false},
}})

registerSent("gmod_wire_datarate", {{
	model = {"Model", TYPE_STRING, "models/jaanus/wiretool/wiretool_gate.mdl"},
}})

registerSent("gmod_wire_keyboard", {{
	model         = {"Model",         TYPE_STRING, "models/jaanus/wiretool/wiretool_input.mdl"},
	autobuffer    = {"AutoBuffer",    TYPE_BOOL,   true},
	synchronous   = {"Synchronous",   TYPE_BOOL,   true},
	enterkeyascii = {"EnterKeyAscii", TYPE_BOOL,   true},
}})

registerSent("gmod_wire_dynamic_button", {
	_preFactory = function(ply, self)
		self.on_r,  self.on_g,  self.on_b  = castColor(self._color_on)
		self.off_r, self.off_g, self.off_b = castColor(self._color_off)
	end,
	
	{
		model        = {"Model",        TYPE_STRING, "models/bull/ranger.mdl"},
		toggle       = {"toggle",       TYPE_BOOL,   false},
		value_on     = {"value_on",     TYPE_NUMBER, 1},
		value_off    = {"value_off",    TYPE_NUMBER, 0},
		description  = {"description",  TYPE_STRING, ""},
		entityout    = {"entityout",    TYPE_BOOL,   false},
		material_on  = {"material_on",  TYPE_STRING, "bull/dynamic_button_1"},
		material_off = {"material_off", TYPE_STRING, "bull/dynamic_button_0"},
		color_on     = {"_color_on",    TYPE_TABLE,  {0, 255, 0, 255}},
		color_off    = {"_color_off",   TYPE_TABLE,  {255, 0, 0, 255}},
	}
})

registerSent("gmod_wire_damage_detector", {{
	model              = {"Model",              TYPE_STRING, "models/jaanus/wiretool/wiretool_siren.mdl"},
	includeconstrained = {"includeconstrained", TYPE_BOOL,   false},
}})

registerSent("gmod_wire_hdd", {{
	model    = {"Model",    TYPE_STRING, "models/jaanus/wiretool/wiretool_gate.mdl"},
	driveid  = {"DriveID",  TYPE_NUMBER, 0},
	drivecap = {"DriveCap", TYPE_NUMBER, 128},
}})

registerSent("gmod_wire_watersensor", {{
	model = {"Model", TYPE_STRING, "models/beer/wiremod/watersensor.mdl"},
}})

registerSent("gmod_wire_value", {
	_preFactory = function(ply, self)
		self.value = {}
		
		local valid_types = {
			NORMAL  = true,
			VECTOR  = true,
			VECTOR2 = true,
			VECTOR4 = true,
			ANGLE   = true,
			STRING  = true,
		}
		
		for i, val in ipairs(self._value) do
			checkluatype(val, TYPE_TABLE, 2, "Parameter: value[" .. i .. "]")
			checkluatype(val[1], TYPE_STRING, 2, "Parameter: value[" .. i .. "][1]")
			
			local typ = string.upper(val[1])
			if not valid_types[typ] then
				SF.Throw("value[" .. i .. "] type is invalid " .. typ, 2)
			end
			
			checkluatype(val[2], TYPE_STRING, 2, "Parameter: value[" .. i .. "][2]")
			
			self.value[i] = {
				DataType = typ,
				Value = val[2]
			}
		end
	end,
	
	{
		model = {"Model", TYPE_STRING, "models/kobilica/value.mdl"},
		value = {"_value", TYPE_TABLE,  {{"NORMAL", "123"}, {"VECTOR4", "1, 2, 3, 4"}}},
	}
})

registerSent("gmod_wire_adv_emarker", {{
	model = {"Model", TYPE_STRING, "models/jaanus/wiretool/wiretool_siren.mdl"},
}})

-- TODO: gmod_wire_wheel, same thing, constraint stuff

registerSent("gmod_wire_gyroscope", {{
	model  = {"Model",  TYPE_STRING, "models/bull/various/gyroscope.mdl"},
	out180 = {"out180", TYPE_BOOL,   false},
}})

registerSent("gmod_wire_datasocket", {{
	model       = {"Model",       TYPE_STRING, "models/hammy/pci_slot.mdl"},
	weldforce   = {"WeldForce",   TYPE_NUMBER, 5000},
	attachrange = {"AttachRange", TYPE_NUMBER, 5},
}})

registerSent("gmod_wire_eyepod", {{
	model            = {"Model",            TYPE_STRING, "models/jaanus/wiretool/wiretool_siren.mdl"},
	defaulttozero    = {"DefaultToZero",    TYPE_NUMBER, 1},
	showrateofchange = {"ShowRateOfChange", TYPE_NUMBER, 1},
	clampxmin        = {"ClampXMin",        TYPE_NUMBER, 0},
	clampxmax        = {"ClampXMax",        TYPE_NUMBER, 0},
	clampymin        = {"ClampYMin",        TYPE_NUMBER, 0},
	clampymax        = {"ClampYMax",        TYPE_NUMBER, 0},
	clampx           = {"ClampX",           TYPE_NUMBER, 0},
	clampy           = {"ClampY",           TYPE_NUMBER, 0},
}})

registerSent("gmod_wire_gate", {{
	model  = {"Model",  TYPE_STRING, "models/jaanus/wiretool/wiretool_gate.mdl"},
	action = {"action", TYPE_STRING, "+"},
}})

registerSent("gmod_wire_freezer", {{
	model = {"Model", TYPE_STRING, "models/jaanus/wiretool/wiretool_siren.mdl"},
}})

-- Chip bois
registerSent("gmod_wire_expression2", {
	_preFactory = function(ply, self)
		self._name = "Generic" -- Can be changed with e2 itself anyways
		self._inputs = {{}, {}}
		self._outputs = {{}, {}}
		self._vars = {}
		self.inc_files = {}
		self.filepath = "generic_starfall.txt"
		
		for path, code in pairs(self._includes) do
			checkluatype(path, TYPE_STRING, 2, "Parameter: includes[" .. path .. "]")
			checkluatype(code, TYPE_STRING, 2, "Parameter: includes[" .. path .. "]")
			
			self.inc_files[path] = code
		end
	end,
	
	{
		model     = {"Model",     TYPE_STRING, "models/beer/wiremod/gate_e2.mdl"},
		code      = {"_original", TYPE_STRING, "print(\"Hello World!\")"},
		includes  = {"_includes", TYPE_TABLE,  {}},
	}
})

end
end)

----------------------------------------
-- So the library doesn't produce an error when loaded

return function() end

----------------------------------------
-- Docs

--- 
-- > gmod_balloon
-- string model = "models/maxofs2d/balloon_classic.mdl"
-- number force = "500"
-- table color = "{255,255,255,}"
-- 
-- > gmod_button
-- number key = "-1"
-- string model = "models/maxofs2d/button_05.mdl"
-- boolean toggle = "true"
-- string label = ""
-- 
-- > gmod_cameraprop
-- boolean locked = "false"
-- string model = "models/dav0r/camera.mdl"
-- boolean toggle = "true"
-- number key = "-1"
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
-- > gmod_hoverball
-- number keyup = "-1"
-- number speed = "1"
-- number keydown = "-1"
-- string model = "models/dav0r/hoverball.mdl"
-- number strength = "1"
-- number resistance = "0"
-- 
-- > gmod_lamp
-- number fov = "90"
-- boolean toggle = "true"
-- table color = "{255,255,255,}"
-- string model = "models/lamps/torch.mdl"
-- boolean starton = "false"
-- number brightness = "4"
-- number distance = "1024"
-- number key = "-1"
-- string texture = "effects/flashlight001"
-- 
-- > gmod_light
-- boolean starton = "false"
-- boolean toggle = "true"
-- table color = "{255,255,255,}"
-- number radius = "256"
-- string model = "models/maxofs2d/light_tubular.mdl"
-- number key = "-1"
-- number brightness = "2"
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
-- > gmod_wire_addressbus
-- number mem2st = "0"
-- number mem4sz = "0"
-- string model = "models/jaanus/wiretool/wiretool_gate.mdl"
-- number mem3sz = "0"
-- number mem1st = "0"
-- number mem2sz = "0"
-- number mem4st = "0"
-- number mem3st = "0"
-- number mem1sz = "0"
-- 
-- > gmod_wire_button
-- number value_off = "0"
-- boolean toggle = "false"
-- number value_on = "1"
-- string model = "models/props_c17/clock01.mdl"
-- boolean entityout = "false"
-- string description = ""
-- 
-- > gmod_wire_cameracontroller
-- boolean allowzoom = "false"
-- boolean localmove = "false"
-- boolean autounclip_ignorewater = "false"
-- boolean freemove = "false"
-- boolean drawparent = "true"
-- boolean parentlocal = "false"
-- boolean drawplayer = "true"
-- string model = "models/jaanus/wiretool/wiretool_siren.mdl"
-- boolean automove = "false"
-- boolean autounclip = "false"
-- 
-- > gmod_wire_clutch
-- string model = "models/jaanus/wiretool/wiretool_siren.mdl"
-- 
-- > gmod_wire_colorer
-- boolean outcolor = "false"
-- number range = "2000"
-- string model = "models/jaanus/wiretool/wiretool_siren.mdl"
-- 
-- > gmod_wire_consolescreen
-- string model = "models/props_lab/monitor01b.mdl"
-- 
-- > gmod_wire_dataport
-- string model = "models/jaanus/wiretool/wiretool_gate.mdl"
-- 
-- > gmod_wire_datarate
-- string model = "models/jaanus/wiretool/wiretool_gate.mdl"
-- 
-- > gmod_wire_datasocket
-- number attachrange = "5"
-- number weldforce = "5000"
-- string model = "models/hammy/pci_slot.mdl"
-- 
-- > gmod_wire_detonator
-- string model = "models/props_combine/breenclock.mdl"
-- number damage = "1"
-- 
-- > gmod_wire_dhdd
-- string model = "models/props_junk/watermelon01.mdl"
-- 
-- > gmod_wire_digitalscreen
-- number width = "32"
-- number height = "32"
-- string model = "models/props_lab/monitor01b.mdl"
-- 
-- > gmod_wire_egp
-- string model = "models/kobilica/wiremonitorbig.mdl"
-- 
-- > gmod_wire_emarker
-- string model = "models/jaanus/wiretool/wiretool_siren.mdl"
-- 
-- > gmod_wire_explosive
-- boolean explosionproof = "false"
-- boolean explodeatzero = "true"
-- number delayreloadtime = "0"
-- boolean resetatexplode = "true"
-- boolean bulletproof = "false"
-- number damage = "200"
-- boolean coloreffect = "true"
-- boolean removeafter = "false"
-- number maxhealth = "100"
-- boolean fallproof = "false"
-- string model = "models/props_c17/oildrum001_explosive.mdl"
-- boolean invisibleatzero = "false"
-- number key = "1"
-- number delaytime = "0"
-- boolean fireeffect = "true"
-- boolean notaffected = "false"
-- number radius = "300"
-- boolean affectother = "false"
-- 
-- > gmod_wire_extbus
-- string model = "models/jaanus/wiretool/wiretool_gate.mdl"
-- 
-- > gmod_wire_eyepod
-- number clampy = "0"
-- number showrateofchange = "1"
-- number clampx = "0"
-- number clampymax = "0"
-- number clampxmax = "0"
-- number clampxmin = "0"
-- number clampymin = "0"
-- number defaulttozero = "1"
-- string model = "models/jaanus/wiretool/wiretool_siren.mdl"
-- 
-- > gmod_wire_forcer
-- number force = "1"
-- number length = "100"
-- string model = "models/jaanus/wiretool/wiretool_siren.mdl"
-- boolean reaction = "false"
-- boolean showbeam = "true"
-- 
-- > gmod_wire_freezer
-- string model = "models/jaanus/wiretool/wiretool_siren.mdl"
-- 
-- > gmod_wire_friendslist
-- string model = "models/kobilica/value.mdl"
-- boolean save_on_entity = "false"
-- 
-- > gmod_wire_gate
-- string model = "models/jaanus/wiretool/wiretool_gate.mdl"
-- string action = "+"
-- 
-- > gmod_wire_gimbal
-- string model = "models/props_c17/canister01a.mdl"
-- 
-- > gmod_wire_gps
-- string model = "models/beer/wiremod/gps.mdl"
-- 
-- > gmod_wire_grabber
-- string model = "models/jaanus/wiretool/wiretool_range.mdl"
-- number range = "100"
-- boolean gravity = "true"
-- 
-- > gmod_wire_gyroscope
-- boolean out180 = "false"
-- string model = "models/bull/various/gyroscope.mdl"
-- 
-- > gmod_wire_hdd
-- string model = "models/jaanus/wiretool/wiretool_gate.mdl"
-- number driveid = "0"
-- number drivecap = "128"
-- 
-- > gmod_wire_holoemitter
-- string model = "models/jaanus/wiretool/wiretool_range.mdl"
-- 
-- > gmod_wire_hologrid
-- string model = "models/jaanus/wiretool/wiretool_siren.mdl"
-- boolean usegps = "false"
-- 
-- > gmod_wire_hoverball
-- number strength = "1"
-- number resistance = "0"
-- string model = "models/dav0r/hoverball.mdl"
-- boolean starton = "true"
-- number speed = "1"
-- 
-- > gmod_wire_hudindicator
-- string huddesc = ""
-- boolean hudaddname = "false"
-- number fullcircleangle = "0"
-- table bcolor = "{0,255,0,255,}"
-- boolean showinhud = "false"
-- number b = "1"
-- string material = "models/debug/debugwhite"
-- number hudshowvalue = "0"
-- boolean allowhook = "true"
-- number hudstyle = "0"
-- number a = "0"
-- table acolor = "{255,0,0,255,}"
-- string model = "models/jaanus/wiretool/wiretool_siren.mdl"
-- 
-- > gmod_wire_igniter
-- string model = "models/jaanus/wiretool/wiretool_siren.mdl"
-- number range = "2048"
-- boolean targetplayers = "false"
-- 
-- > gmod_wire_indicator
-- number b = "1"
-- table acolor = "{255,0,0,255,}"
-- string model = "models/segment.mdl"
-- table bcolor = "{0,255,0,255,}"
-- number a = "0"
-- 
-- > gmod_wire_input
-- number value_off = "0"
-- boolean toggle = "false"
-- number keygroup = "7"
-- string model = "models/beer/wiremod/numpad.mdl"
-- number value_on = "1"
-- 
-- > gmod_wire_keyboard
-- boolean autobuffer = "true"
-- string model = "models/jaanus/wiretool/wiretool_input.mdl"
-- boolean synchronous = "true"
-- boolean enterkeyascii = "true"
-- 
-- > gmod_wire_keypad
-- string password = ""
-- string model = "models/props_lab/keypad.mdl"
-- boolean secure = "false"
-- 
-- > gmod_wire_lamp
-- number dist = "1024"
-- number fov = "90"
-- table color = "{255,255,255,}"
-- string texture = "effects/flashlight001"
-- string model = "models/lamps/torch.mdl"
-- boolean on = "false"
-- number brightness = "8"
-- 
-- > gmod_wire_latch
-- string model = "models/jaanus/wiretool/wiretool_siren.mdl"
-- 
-- > gmod_wire_lever
-- number max = "1"
-- string model = "models/props_junk/watermelon01.mdl"
-- number min = "0"
-- 
-- > gmod_wire_light
-- boolean directional = "false"
-- number size = "256"
-- table color = "{255,255,255,}"
-- boolean radiant = "false"
-- string model = "models/jaanus/wiretool/wiretool_siren.mdl"
-- boolean glow = "false"
-- number brightness = "2"
-- 
-- > gmod_wire_locator
-- string model = "models/props_lab/powerbox02d.mdl"
-- 
-- > gmod_wire_nailer
-- number flim = "0"
-- string model = "models/jaanus/wiretool/wiretool_siren.mdl"
-- number range = "100"
-- boolean showbeam = "true"
-- 
-- > gmod_wire_numpad
-- number value_off = "0"
-- string model = "models/beer/wiremod/numpad.mdl"
-- boolean toggle = "false"
-- number value_on = "0"
-- 
-- > gmod_wire_oscilloscope
-- string model = "models/props_lab/monitor01b.mdl"
-- 
-- > gmod_wire_output
-- number key = "1"
-- string model = "models/beer/wiremod/numpad.mdl"
-- 
-- > gmod_wire_pixel
-- string model = "models/jaanus/wiretool/wiretool_siren.mdl"
-- 
-- > gmod_wire_pod
-- string model = "models/jaanus/wiretool/wiretool_siren.mdl"
-- 
-- > gmod_wire_radio
-- boolean secure = "false"
-- string channel = "1"
-- number values = "4"
-- string model = "models/props_lab/binderblue.mdl"
-- 
-- > gmod_wire_ranger
-- boolean out_vel = "false"
-- boolean hires = "false"
-- boolean show_beam = "true"
-- number range = "1500"
-- boolean out_ang = "false"
-- boolean default_zero = "true"
-- boolean out_uid = "false"
-- string model = "models/jaanus/wiretool/wiretool_range.mdl"
-- boolean out_pos = "false"
-- boolean out_col = "false"
-- boolean out_val = "false"
-- boolean out_eid = "false"
-- boolean out_hnrm = "false"
-- boolean out_sid = "false"
-- boolean ignore_world = "false"
-- boolean out_dist = "true"
-- boolean trace_water = "false"
-- 
-- > gmod_wire_relay
-- number keygroup2 = "2"
-- boolean nokey = "false"
-- boolean toggle = "true"
-- number keygroup4 = "4"
-- string model = "models/kobilica/relay.mdl"
-- number keygroup1 = "1"
-- number keygroup3 = "3"
-- number keygroupoff = "0"
-- number normclose = "0"
-- number poles = "1"
-- number keygroup5 = "5"
-- number throws = "2"
-- 
-- > gmod_wire_screen
-- boolean singlevalue = "false"
-- string textb = "Value B"
-- boolean formatnumber = "false"
-- string model = "models/props_lab/monitor01b.mdl"
-- string texta = "Value A"
-- boolean singlebigfont = "true"
-- boolean leftalign = "false"
-- boolean floor = "false"
-- boolean formattime = "false"
-- 
-- > gmod_wire_sensor
-- boolean velocity_normalized = "false"
-- boolean outdist = "true"
-- boolean direction_vector = "false"
-- string model = "models/props_junk/watermelon01.mdl"
-- boolean target_velocity = "false"
-- boolean outbrng = "false"
-- boolean xyz_mode = "false"
-- boolean direction_normalized = "false"
-- boolean gpscord = "false"
-- 
-- > gmod_wire_socket
-- number attachrange = "5"
-- boolean arrayinput = "false"
-- string model = "models/props_lab/tpplugholder_single.mdl"
-- number weldforce = "5000"
-- 
-- > gmod_wire_soundemitter
-- string sound = "synth/square.wav"
-- string model = "models/cheeze/wires/speaker.mdl"
-- 
-- > gmod_wire_spawner
-- string mat = ""
-- number skin = "0"
-- number delay = "0"
-- number spawn_effect = "0"
-- string model = "models/props_junk/watermelon01.mdl"
-- table color = "{255,255,255,255,}"
-- number undo_delay = "0"
-- 
-- > gmod_wire_speedometer
-- string model = "models/props_junk/watermelon01.mdl"
-- boolean xyz_mode = "false"
-- boolean angvel = "false"
-- 
-- > gmod_wire_teleporter
-- string model = "models/props_c17/utilityconducter001.mdl"
-- boolean usesounds = "true"
-- boolean useeffects = "true"
-- 
-- > gmod_wire_textentry
-- string model = "models/beer/wiremod/keyboard.mdl"
-- 
-- > gmod_wire_textreceiver
-- boolean caseinsensitive = "true"
-- boolean useluapatterns = "false"
-- string model = "models/jaanus/wiretool/wiretool_range.mdl"
-- table matches = "{\"Hello World\",}"
-- 
-- > gmod_wire_textscreen
-- number textjust = "1"
-- table bgcolor = "{255,255,255,}"
-- number chrperline = "6"
-- string tfont = "Arial"
-- number valign = "0"
-- string model = "models/kobilica/wiremonitorbig.mdl"
-- table fgcolor = "{255,255,255,}"
-- string text = ""
-- 
-- > gmod_wire_thruster
-- string soundname = ""
-- string uweffect = "same"
-- boolean bidir = "true"
-- string oweffect = "fire"
-- boolean uwater = "true"
-- string model = "models/props_c17/lampShade001a.mdl"
-- boolean owater = "true"
-- number force_max = "10000"
-- number force = "1500"
-- number force_min = "0"
-- 
-- > gmod_wire_trail
-- string material = "trails/lol"
-- table color = "{255,255,255,255,}"
-- string model = "models/props_junk/watermelon01.mdl"
-- number end_size = "0"
-- number length = "5"
-- number start_size = "32"
-- 
-- > gmod_wire_trigger
-- number sizey = "64"
-- number sizez = "64"
-- boolean owneronly = "false"
-- number offsety = "0"
-- number offsetz = "0"
-- number filter = "0"
-- number offsetx = "0"
-- number sizex = "64"
-- string model = "models/jaanus/wiretool/wiretool_siren.mdl"
-- 
-- > gmod_wire_turret
-- number force = "1"
-- string model = "models/weapons/w_smg1.mdl"
-- number spread = "0"
-- number tracernum = "1"
-- string tracer = "Tracer"
-- string sound = "0"
-- number damage = "10"
-- number numbullets = "1"
-- number delay = "0.05"
-- 
-- > gmod_wire_user
-- number range = "200"
-- string model = "models/jaanus/wiretool/wiretool_siren.mdl"
-- 
-- > gmod_wire_vectorthruster
-- string soundname = ""
-- number force = "1500"
-- boolean bidir = "true"
-- string model = "models/jaanus/wiretool/wiretool_speed.mdl"
-- number mode = "0"
-- boolean uwater = "true"
-- boolean angleinputs = "false"
-- string uweffect = "same"
-- boolean lengthismul = "false"
-- boolean owater = "true"
-- number force_max = "10000"
-- string oweffect = "fire"
-- number force_min = "0"
-- 
-- > gmod_wire_vehicle
-- string model = "models/jaanus/wiretool/wiretool_siren.mdl"
-- 
-- > gmod_wire_watersensor
-- string model = "models/beer/wiremod/watersensor.mdl"
-- 
-- > gmod_wire_waypoint
-- number range = "150"
-- string model = "models/props_lab/powerbox02d.mdl"
-- 
-- > gmod_wire_weight
-- string model = "models/props_interiors/pot01a.mdl"
-- 
-- > gmod_wire_adv_emarker
-- string model = "models/jaanus/wiretool/wiretool_siren.mdl"
-- 
-- > gmod_wire_adv_input
-- number value_min = "0"
-- number keyless = "1"
-- boolean toggle = "false"
-- number value_start = "5"
-- number value_max = "10"
-- number keymore = "3"
-- string model = "models/beer/wiremod/numpad.mdl"
-- number speed = "1"
-- 
-- > gmod_wire_cd_disk
-- string model = "models/venompapa/wirecd_medium.mdl"
-- number precision = "4"
-- number skin = "0"
-- number iradius = "10"
-- 
-- > gmod_wire_cd_ray
-- boolean defaultzero = "false"
-- string model = "models/jaanus/wiretool/wiretool_beamcaster.mdl"
-- number range = "64"
-- 
-- > gmod_wire_damage_detector
-- boolean includeconstrained = "false"
-- string model = "models/jaanus/wiretool/wiretool_siren.mdl"
-- 
-- > gmod_wire_data_satellitedish
-- string model = "models/props_wasteland/prison_lamp001c.mdl"
-- 
-- > gmod_wire_data_store
-- string model = "models/jaanus/wiretool/wiretool_range.mdl"
-- 
-- > gmod_wire_data_transferer
-- boolean defaultzero = "false"
-- string model = "models/jaanus/wiretool/wiretool_siren.mdl"
-- number range = "25000"
-- boolean ignorezero = "false"
-- 
-- > gmod_wire_dual_input
-- number keygroup2 = "4"
-- boolean toggle = "false"
-- string model = "models/beer/wiremod/numpad.mdl"
-- number value_off = "0"
-- number value_on2 = "-1"
-- number keygroup = "7"
-- number value_on = "1"
-- 
-- > gmod_wire_dynamic_button
-- number value_off = "0"
-- boolean toggle = "false"
-- string model = "models/bull/ranger.mdl"
-- string description = ""
-- string material_off = "bull/dynamic_button_0"
-- table color_off = "{255,0,0,255,}"
-- table color_on = "{0,255,0,255,}"
-- string material_on = "bull/dynamic_button_1"
-- boolean entityout = "false"
-- number value_on = "1"
-- 
-- > gmod_wire_egp_emitter
-- string model = "models/bull/dynamicbutton.mdl"
-- 
-- > gmod_wire_egp_hud
-- string model = "models/bull/dynamicbutton.mdl"
-- 
-- > gmod_wire_exit_point
-- string model = "models/jaanus/wiretool/wiretool_range.mdl"
-- 
-- > gmod_wire_fx_emitter
-- string model = "models/props_lab/tpplug.mdl"
-- string effect = "sparks"
-- number delay = "0.07"
-- 
-- > gmod_wire_gpulib_controller
-- string model = "models/jaanus/wiretool/wiretool_siren.mdl"
-- 
-- > gmod_wire_graphics_tablet
-- boolean cursor_mode = "false"
-- string model = "models/kobilica/wiremonitorbig.mdl"
-- boolean draw_background = "true"
-- 
-- > gmod_wire_las_receiver
-- string model = "models/jaanus/wiretool/wiretool_range.mdl"
-- 
-- > gmod_wire_simple_explosive
-- number trigger = "1"
-- boolean removeafter = "false"
-- number damage = "200"
-- number radius = "300"
-- string model = "models/props_c17/oildrum001_explosive.mdl"
-- 
-- > gmod_wire_target_finder
-- string propmodel = ""
-- boolean onbuddylist = "false"
-- boolean colortarget = "false"
-- number maxbogeys = "1"
-- boolean checkbuddylist = "false"
-- string playername = ""
-- boolean npcs = "true"
-- boolean rpgs = "false"
-- boolean thrusters = "false"
-- boolean casesen = "false"
-- number minrange = "1"
-- number range = "1000"
-- boolean hoverballs = "false"
-- boolean players = "false"
-- boolean beacons = "false"
-- string entity = ""
-- string model = "models/beer/wiremod/targetfinder.mdl"
-- string steamname = ""
-- boolean props = "false"
-- boolean colorcheck = "false"
-- string npcname = ""
-- boolean notownersstuff = "false"
-- boolean notargetowner = "false"
-- number maxtargets = "1"
-- boolean painttarget = "true"
-- table pcolor = "{255,255,255,255,}"
-- boolean vehicles = "false"
-- 
-- > gmod_wire_twoway_radio
-- string model = "models/props_lab/binderblue.mdl"
-- 
-- @name props_library.SENT_Data_Structures
-- @class table
