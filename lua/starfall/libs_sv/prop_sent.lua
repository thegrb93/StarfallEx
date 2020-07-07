-- Simple helper function that provides model if it doesnt exist
local function registerSent(class, data)
	list.Set("starfall_creatable_sent", class, data)
end

-- Function to generate some docs, it aint fancy but works i guess
local function genDocs()
	local tostr = {
		table = table.ToString,
		Vector = function(x) return string.format("Vector(%s, %s, %s)", x[1], x[2], x[3]) end,
		Angle = function(x) return string.format("Angle(%s, %s, %s)", x[1], x[2], x[3]) end,
	}

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
			local typ = SF.TypeName(org[2])
			table.insert(str, string.format("-- %s %s = %q", typ, param, tostr[typ] and tostr[typ](org[3]) or org[3]))
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
}

----------------------------------------
-- Sent registering
local checkluatype = SF.CheckLuaType

-- Basic Gmod sents
registerSent("gmod_balloon", {{
	["Model"] = {TYPE_STRING, "models/maxofs2d/balloon_classic.mdl"},
	["force"] = {TYPE_NUMBER, 500},
	["r"] = {TYPE_NUMBER, 255},
	["g"] = {TYPE_NUMBER, 255},
	["b"] = {TYPE_NUMBER, 255},
}})

registerSent("gmod_button", {{
	["Model"] = {TYPE_STRING, "models/maxofs2d/button_05.mdl"},
	["description"] = {TYPE_STRING, ""},
	["key"] = {TYPE_NUMBER, -1},
	["toggle"] = {TYPE_BOOL, true},
}})

registerSent("gmod_cameraprop", {{
	["Model"] = {TYPE_STRING, "models/dav0r/camera.mdl"},
	["controlkey"] = {TYPE_NUMBER, -1},
	["locked"] = {TYPE_BOOL, false},
	["toggle"] = {TYPE_BOOL, true},
}})

registerSent("gmod_dynamite", {{
	["Model"] = {TYPE_STRING, "models/dav0r/tnt/tnt.mdl"},
	["key"] = {TYPE_NUMBER, -1},
	["Damage"] = {TYPE_NUMBER, 200},
	["delay"] = {TYPE_NUMBER, 0},
	["remove"] = {TYPE_BOOL, false},
}})

registerSent("gmod_emitter", {{
	["Model"] = {TYPE_STRING, "models/props_lab/tpplug.mdl"},
	["effect"] = {TYPE_STRING, "sparks"},
	["key"] = {TYPE_NUMBER, -1},
	["delay"] = {TYPE_NUMBER, 0},
	["scale"] = {TYPE_NUMBER, 1},
	["toggle"] = {TYPE_BOOL, true},
	["starton"] = {TYPE_BOOL, false},
}})

registerSent("gmod_hoverball", {{
	["Model"] = {TYPE_STRING, "models/dav0r/hoverball.mdl"},
	["key_u"] = {TYPE_NUMBER, -1},
	["key_d"] = {TYPE_NUMBER, -1},
	["speed"] = {TYPE_NUMBER, 1},
	["resistance"] = {TYPE_NUMBER, 0},
	["strength"] = {TYPE_NUMBER, 1},
}})

registerSent("gmod_lamp", {{
	["Model"] = {TYPE_STRING, "models/lamps/torch.mdl"},
	["Texture"] = {TYPE_STRING, "effects/flashlight001"},
	["KeyDown"] = {TYPE_NUMBER, -1},
	["fov"] = {TYPE_NUMBER, 90},
	["distance"] = {TYPE_NUMBER, 1024},
	["brightness"] = {TYPE_NUMBER, 4},
	["toggle"] = {TYPE_BOOL, true},
	["on"] = {TYPE_BOOL, false},
	["r"] = {TYPE_NUMBER, 255},
	["g"] = {TYPE_NUMBER, 255},
	["b"] = {TYPE_NUMBER, 255},
}})

registerSent("gmod_light", {{
	["Model"] = {TYPE_STRING, "models/maxofs2d/light_tubular.mdl"},
	["KeyDown"] = {TYPE_NUMBER, -1},
	["Size"] = {TYPE_NUMBER, 256},
	["Brightness"] = {TYPE_NUMBER, 2},
	["toggle"] = {TYPE_BOOL, true},
	["on"] = {TYPE_BOOL, false},
	["lightr"] = {TYPE_NUMBER, 255},
	["lightg"] = {TYPE_NUMBER, 255},
	["lightb"] = {TYPE_NUMBER, 255},
}})

registerSent("gmod_thruster", {{
	["Model"] = {TYPE_STRING, "models/props_phx2/garbage_metalcan001a.mdl"},
	["effect"] = {TYPE_STRING, "fire"},
	["soundname"] = {TYPE_STRING, "PhysicsCannister.ThrusterLoop"},
	["key"] = {TYPE_NUMBER, -1},
	["key_bck"] = {TYPE_NUMBER, -1},
	["force"] = {TYPE_NUMBER, 1500},
	["toggle"] = {TYPE_BOOL, false},
	["damageable"] = {TYPE_BOOL, false},
}})

----------------------------------------
-- Wiremod

-- Timer so that we are sure to check after wiremod initialized, if wire has a hook.run / call when it initialized change this
timer.Simple(0, function()
if WireLib then

registerSent("gmod_wire_spawner", {{
	["Model"] = {TYPE_STRING},
	["delay"] = {TYPE_NUMBER, 0},
	["undo_delay"] = {TYPE_NUMBER, 0},
	["spawn_effect"] = {TYPE_NUMBER, 0},
	["mat"] = {TYPE_STRING, ""},
	["skin"] = {TYPE_NUMBER, 0},
	["r"] = {TYPE_NUMBER, 255},
	["g"] = {TYPE_NUMBER, 255},
	["b"] = {TYPE_NUMBER, 255},
	["a"] = {TYPE_NUMBER, 255},
}})

registerSent("gmod_wire_emarker", {{
	["Model"] = {TYPE_STRING, "models/jaanus/wiretool/wiretool_siren.mdl"},
}})

registerSent("gmod_wire_forcer", {{
	["Model"] = {TYPE_STRING, "models/jaanus/wiretool/wiretool_siren.mdl"},
	["Force"] = {TYPE_NUMBER, 1},
	["Length"] = {TYPE_NUMBER, 100},
	["ShowBeam"] = {TYPE_BOOL, true},
	["Reaction"] = {TYPE_BOOL, false},
}})

registerSent("gmod_wire_adv_input", {{
	["Model"] = {TYPE_STRING, "models/beer/wiremod/numpad.mdl"},
	["keymore"] = {TYPE_NUMBER, 3},
	["keyless"] = {TYPE_NUMBER, 1},
	["toggle"] = {TYPE_BOOL, false},
	["value_min"] = {TYPE_NUMBER, 0},
	["value_max"] = {TYPE_NUMBER, 10},
	["value_start"] = {TYPE_NUMBER, 5},
	["speed"] = {TYPE_NUMBER, 1},
}})

registerSent("gmod_wire_oscilloscope", {{
	["Model"] = {TYPE_STRING, "models/props_lab/monitor01b.mdl"},
}})

registerSent("gmod_wire_dhdd", {{
	["Model"] = {TYPE_STRING},
}})

registerSent("gmod_wire_friendslist", {{
	["Model"] = {TYPE_STRING, "models/kobilica/value.mdl"},
	["save_on_entity"] = {TYPE_BOOL, false},
}})

registerSent("gmod_wire_nailer", {{
	["Model"] = {TYPE_STRING, "models/jaanus/wiretool/wiretool_siren.mdl"},
	["Flim"] = {TYPE_NUMBER, 0},
	["Range"] = {TYPE_NUMBER, 100},
	["ShowBeam"] = {TYPE_BOOL, true},
}})

registerSent("gmod_wire_grabber", {{
	["Model"] = {TYPE_STRING, "models/jaanus/wiretool/wiretool_range.mdl"},
	["Range"] = {TYPE_NUMBER, 100},
	["Gravity"] = {TYPE_BOOL, true},
}})

registerSent("gmod_wire_weight", {{
	["Model"] = {TYPE_STRING, "models/props_interiors/pot01a.mdl"},
}})

registerSent("gmod_wire_exit_point", {{
	["Model"] = {TYPE_STRING, "models/jaanus/wiretool/wiretool_range.mdl"},
}})

registerSent("gmod_wire_latch", {{
	["Model"] = {TYPE_STRING, "models/jaanus/wiretool/wiretool_siren.mdl"},
}})

registerSent("gmod_wire_dataport", {{
	["Model"] = {TYPE_STRING, "models/jaanus/wiretool/wiretool_gate.mdl"},
}})

registerSent("gmod_wire_colorer", {{
	["Model"] = {TYPE_STRING, "models/jaanus/wiretool/wiretool_siren.mdl"},
	["outColor"] = {TYPE_BOOL, false},
	["Range"] = {TYPE_NUMBER, 2000},
}})

registerSent("gmod_wire_addressbus", {{
	["Model"] = {TYPE_STRING, "models/jaanus/wiretool/wiretool_gate.mdl"},
	["Mem1st"] = {TYPE_NUMBER, 0},
	["Mem2st"] = {TYPE_NUMBER, 0},
	["Mem3st"] = {TYPE_NUMBER, 0},
	["Mem4st"] = {TYPE_NUMBER, 0},
	["Mem1sz"] = {TYPE_NUMBER, 0},
	["Mem2sz"] = {TYPE_NUMBER, 0},
	["Mem3sz"] = {TYPE_NUMBER, 0},
	["Mem4sz"] = {TYPE_NUMBER, 0},
}})

registerSent("gmod_wire_cd_disk", {{
	["Model"] = {TYPE_STRING, "models/venompapa/wirecd_medium.mdl"},
	["Precision"] = {TYPE_NUMBER, 4},
	["IRadius"] = {TYPE_NUMBER, 10},
	["Skin"] = {TYPE_NUMBER, 0},
}})

registerSent("gmod_wire_las_receiver", {{
	["Model"] = {TYPE_STRING, "models/jaanus/wiretool/wiretool_range.mdl"},
}})

registerSent("gmod_wire_lever", {{
	["Min"] = {TYPE_NUMBER, 0},
	["Max"] = {TYPE_NUMBER, 1},
}})

registerSent("gmod_wire_waypoint", {{
	["Model"] = {TYPE_STRING, "models/props_lab/powerbox02d.mdl"},
	["range"] = {TYPE_NUMBER, 150},
}})

registerSent("gmod_wire_vehicle", {{
	["Model"] = {TYPE_STRING, "models/jaanus/wiretool/wiretool_siren.mdl"},
}})

registerSent("gmod_wire_vectorthruster", {{
	["Model"] = {TYPE_STRING, "models/jaanus/wiretool/wiretool_speed.mdl"},
	["force"] = {TYPE_NUMBER, 1500},
	["force_min"] = {TYPE_NUMBER, 0},
	["force_max"] = {TYPE_NUMBER, 10000},
	["oweffect"] = {TYPE_STRING, "fire"},
	["uweffect"] = {TYPE_STRING, "same"},
	["owater"] = {TYPE_BOOL, true},
	["uwater"] = {TYPE_BOOL, true},
	["bidir"] = {TYPE_BOOL, true},
	["soundname"] = {TYPE_STRING, ""},
	["mode"] = {TYPE_NUMBER, 0},
	["angleinputs"] = {TYPE_BOOL, false},
	["lengthismul"] = {TYPE_BOOL, false},
}})

registerSent("gmod_wire_user", {{
	["Model"] = {TYPE_STRING, "models/jaanus/wiretool/wiretool_siren.mdl"},
	["Range"] = {TYPE_NUMBER, 200},
}})

registerSent("gmod_wire_twoway_radio", {{
	["Model"] = {TYPE_STRING, "models/props_lab/binderblue.mdl"},
}})

registerSent("gmod_wire_numpad", {{
	["Model"] = {TYPE_STRING, "models/beer/wiremod/numpad.mdl"},
	["toggle"] = {TYPE_BOOL, false},
	["value_off"] = {TYPE_NUMBER, 0},
	["value_on"] = {TYPE_NUMBER, 0},
}})

registerSent("gmod_wire_turret", {{
	["Model"] = {TYPE_STRING, "models/weapons/w_smg1.mdl"},
	["delay"] = {TYPE_NUMBER, 0.05},
	["damage"] = {TYPE_NUMBER, 10},
	["force"] = {TYPE_NUMBER, 1},
	["sound"] = {TYPE_STRING, "0"},
	["numbullets"] = {TYPE_NUMBER, 1},
	["spread"] = {TYPE_NUMBER, 0},
	["tracer"] = {TYPE_STRING, "Tracer"},
	["tracernum"] = {TYPE_NUMBER, 1},
}})

registerSent("gmod_wire_soundemitter", {{
	["Model"] = {TYPE_STRING, "models/cheeze/wires/speaker.mdl"},
	["sound"] = {TYPE_STRING, "synth/square.wav"},
}})

registerSent("gmod_wire_textscreen", {{
	["Model"] = {TYPE_STRING, "models/kobilica/wiremonitorbig.mdl"},
	["text"] = {TYPE_STRING, ""},
	["chrPerLine"] = {TYPE_NUMBER, 6},
	["textJust"] = {TYPE_NUMBER, 1},
	["valign"] = {TYPE_NUMBER, 0},
	["tfont"] = {TYPE_STRING, "Arial"},
	["fgcolor"] = {TYPE_COLOR, Color(255, 255, 255)},
	["bgcolor"] = {TYPE_COLOR, Color(0, 0, 0)},
}})

registerSent("gmod_wire_holoemitter", {{
	["Model"] = {TYPE_STRING, "models/jaanus/wiretool/wiretool_range.mdl"},
}})

registerSent("gmod_wire_textreceiver", {
	_preFactory = function(ply, self)
		local matches = {}
		for k, v in pairs(self.Matches) do
			checkluatype(v, TYPE_STRING, 3, "Parameter: Matches[" .. k .. "]")
			matches[k] = v
		end
		self.Matches = matches
	end,

	{
		["Model"] = {TYPE_STRING, "models/jaanus/wiretool/wiretool_range.mdl"},
		["UseLuaPatterns"] = {TYPE_BOOL, false},
		["Matches"] = {TYPE_TABLE},
		["CaseInsensitive"] = {TYPE_BOOL, true},
	}
})

registerSent("gmod_wire_textentry", {{
	["Model"] = {TYPE_STRING, "models/beer/wiremod/keyboard.mdl"},
}})

registerSent("gmod_wire_teleporter", {{
	["Model"] = {TYPE_STRING, "models/props_c17/utilityconducter001.mdl"},
	["UseSounds"] = {TYPE_BOOL, true},
	["UseEffects"] = {TYPE_BOOL, true},
}})

registerSent("gmod_wire_target_finder", {{
	["Model"] = {TYPE_STRING, "models/beer/wiremod/targetfinder.mdl"},
	["range"] = {TYPE_NUMBER, 1000},
	["players"] = {TYPE_BOOL, false},
	["npcs"] = {TYPE_BOOL, true},
	["npcname"] = {TYPE_STRING, ""},
	["beacons"] = {TYPE_BOOL, false},
	["hoverballs"] = {TYPE_BOOL, false},
	["thrusters"] = {TYPE_BOOL, false},
	["props"] = {TYPE_BOOL, false},
	["propmodel"] = {TYPE_STRING, ""},
	["vehicles"] = {TYPE_BOOL, false},
	["playername"] = {TYPE_STRING, ""},
	["casesen"] = {TYPE_BOOL, false},
	["rpgs"] = {TYPE_BOOL, false},
	["painttarget"] = {TYPE_BOOL, true},
	["minrange"] = {TYPE_NUMBER, 1},
	["maxtargets"] = {TYPE_NUMBER, 1},
	["maxbogeys"] = {TYPE_NUMBER, 1},
	["notargetowner"] = {TYPE_BOOL, false},
	["entity"] = {TYPE_STRING, ""},
	["notownersstuff"] = {TYPE_BOOL, false},
	["steamname"] = {TYPE_STRING, ""},
	["colorcheck"] = {TYPE_BOOL, false},
	["colortarget"] = {TYPE_BOOL, false},
	["checkbuddylist"] = {TYPE_BOOL, false},
	["onbuddylist"] = {TYPE_BOOL, false},
	["pcolR"] = {TYPE_NUMBER, 255},
	["pcolG"] = {TYPE_NUMBER, 255},
	["pcolB"] = {TYPE_NUMBER, 255},
	["pcolA"] = {TYPE_NUMBER, 255},
}})

registerSent("gmod_wire_digitalscreen", {{
	["Model"] = {TYPE_STRING, "models/props_lab/monitor01b.mdl"},
	["ScreenWidth"] = {TYPE_NUMBER, 32},
	["ScreenHeight"] = {TYPE_NUMBER, 32},
}})

registerSent("gmod_wire_trail", {
	_preFactory = function(ply, self)
		self.Trail = {}
	end,

	_postFactory = function(ply, self, enttbl)
		self.Trail = {
			Color = enttbl.Color,
			Length = enttbl.Length,
			StartSize = enttbl.StartSize,
			EndSize = enttbl.EndSize,
			Material = enttbl.Material
		}
	end,

	{
		["Color"] = {TYPE_COLOR, Color(255, 255, 255)},
		["Length"] = {TYPE_NUMBER, 5},
		["StartSize"] = {TYPE_NUMBER, 32},
		["EndSize"] = {TYPE_NUMBER, 0},
		["Material"] = {TYPE_STRING, "trails/lol"},
	}
})

registerSent("gmod_wire_egp", {
	_preFactory = function(ply, self)
		self.model = self.Model
	end,

	{
		["Model"] = {TYPE_STRING, "models/kobilica/wiremonitorbig.mdl"},
	}
})

registerSent("gmod_wire_egp_hud", {{
	["Model"] = {TYPE_STRING, "models/bull/dynamicbutton.mdl"},
}})

registerSent("gmod_wire_egp_emitter", {{
	["Model"] = {TYPE_STRING, "models/bull/dynamicbutton.mdl"},
}})

registerSent("gmod_wire_speedometer", {{
	["Model"] = {TYPE_STRING},
	["z_only"] = {TYPE_BOOL, false},
	["AngVel"] = {TYPE_BOOL, false},
}})

registerSent("gmod_wire_trigger", {
	_preFactory = function(ply, self)
		self.model = self.Model
	end,

	{
		["Model"] = {TYPE_STRING, "models/jaanus/wiretool/wiretool_siren.mdl"},
		["filter"] = {TYPE_NUMBER, 0},
		["owneronly"] = {TYPE_BOOL, false},
		["sizex"] = {TYPE_NUMBER, 64},
		["sizey"] = {TYPE_NUMBER, 64},
		["sizez"] = {TYPE_NUMBER, 64},
		["offsetx"] = {TYPE_NUMBER, 0},
		["offsety"] = {TYPE_NUMBER, 0},
		["offsetz"] = {TYPE_NUMBER, 0},
	}
})

registerSent("gmod_wire_socket", {{
	["Model"] = {TYPE_STRING, "models/props_lab/tpplugholder_single.mdl"},
	["ArrayInput"] = {TYPE_BOOL, false},
	["WeldForce"] = {TYPE_NUMBER, 5000},
	["AttachRange"] = {TYPE_NUMBER, 5},
}})

registerSent("gmod_wire_simple_explosive", {{
	["Model"] = {TYPE_STRING, "models/props_c17/oildrum001_explosive.mdl"},
	["key"] = {TYPE_NUMBER, 1},
	["damage"] = {TYPE_NUMBER, 200},
	["removeafter"] = {TYPE_BOOL, false},
	["radius"] = {TYPE_NUMBER, 300},
}})

registerSent("gmod_wire_sensor", {{
	["Model"] = {TYPE_STRING},
	["xyz_mode"] = {TYPE_BOOL, false},
	["outdist"] = {TYPE_BOOL, true},
	["outbrng"] = {TYPE_BOOL, false},
	["gpscord"] = {TYPE_BOOL, false},
	["direction_vector"] = {TYPE_BOOL, false},
	["direction_normalized"] = {TYPE_BOOL, false},
	["target_velocity"] = {TYPE_BOOL, false},
	["velocity_normalized"] = {TYPE_BOOL, false},
}})

registerSent("gmod_wire_screen", {{
	["Model"] = {TYPE_STRING, "models/props_lab/monitor01b.mdl"},
	["SingleValue"] = {TYPE_BOOL, false},
	["SingleBigFont"] = {TYPE_BOOL, true},
	["TextA"] = {TYPE_STRING, "Value A"},
	["TextB"] = {TYPE_STRING, "Value B"},
	["LeftAlign"] = {TYPE_BOOL, false},
	["Floor"] = {TYPE_BOOL, false},
	["FormatNumber"] = {TYPE_BOOL, false},
	["FormatTime"] = {TYPE_BOOL, false},
}})

registerSent("gmod_wire_detonator", {{
	["Model"] = {TYPE_STRING, "models/props_combine/breenclock.mdl"},
	["damage"] = {TYPE_NUMBER, 1},
}})

registerSent("gmod_wire_relay", {{
	["Model"] = {TYPE_STRING, "models/kobilica/relay.mdl"},
	["keygroup1"] = {TYPE_NUMBER, 1},
	["keygroup2"] = {TYPE_NUMBER, 2},
	["keygroup3"] = {TYPE_NUMBER, 3},
	["keygroup4"] = {TYPE_NUMBER, 4},
	["keygroup5"] = {TYPE_NUMBER, 5},
	["keygroupoff"] = {TYPE_NUMBER, 0},
	["toggle"] = {TYPE_BOOL, true},
	["normclose"] = {TYPE_NUMBER, 0},
	["poles"] = {TYPE_NUMBER, 1},
	["throws"] = {TYPE_NUMBER, 2},
	["nokey"] = {TYPE_BOOL, false},
}})

registerSent("gmod_wire_ranger", {{
	["Model"] = {TYPE_STRING, "models/jaanus/wiretool/wiretool_range.mdl"},
	["range"] = {TYPE_NUMBER, 1500},
	["default_zero"] = {TYPE_BOOL, true},
	["show_beam"] = {TYPE_BOOL, true},
	["ignore_world"] = {TYPE_BOOL, false},
	["trace_water"] = {TYPE_BOOL, false},
	["out_dist"] = {TYPE_BOOL, true},
	["out_pos"] = {TYPE_BOOL, false},
	["out_vel"] = {TYPE_BOOL, false},
	["out_ang"] = {TYPE_BOOL, false},
	["out_col"] = {TYPE_BOOL, false},
	["out_val"] = {TYPE_BOOL, false},
	["out_sid"] = {TYPE_BOOL, false},
	["out_uid"] = {TYPE_BOOL, false},
	["out_eid"] = {TYPE_BOOL, false},
	["out_hnrm"] = {TYPE_BOOL, false},
	["hires"] = {TYPE_BOOL, false},
}})

registerSent("gmod_wire_radio", {{
	["Model"] = {TYPE_STRING, "models/props_lab/binderblue.mdl"},
	["Channel"] = {TYPE_STRING, "1"},
	["values"] = {TYPE_NUMBER, 4},
	["Secure"] = {TYPE_BOOL, false},
}})

registerSent("gmod_wire_thruster", {{
	["Model"] = {TYPE_STRING, "models/props_c17/lampShade001a.mdl"},
	["force"] = {TYPE_NUMBER, 1500},
	["force_min"] = {TYPE_NUMBER, 0},
	["force_max"] = {TYPE_NUMBER, 10000},
	["oweffect"] = {TYPE_STRING, "fire"},
	["uweffect"] = {TYPE_STRING, "same"},
	["owater"] = {TYPE_BOOL, true},
	["uwater"] = {TYPE_BOOL, true},
	["bidir"] = {TYPE_BOOL, true},
	["soundname"] = {TYPE_STRING, ""},
}})

registerSent("gmod_wire_pod", {{
	["Model"] = {TYPE_STRING, "models/jaanus/wiretool/wiretool_siren.mdl"},
}})

registerSent("gmod_wire_data_satellitedish", {{
	["Model"] = {TYPE_STRING, "models/props_wasteland/prison_lamp001c.mdl"},
}})

registerSent("gmod_wire_consolescreen", {{
	["Model"] = {TYPE_STRING, "models/props_lab/monitor01b.mdl"},
}})

registerSent("gmod_wire_pixel", {{
	["Model"] = {TYPE_STRING, "models/jaanus/wiretool/wiretool_siren.mdl"},
}})

registerSent("gmod_wire_output", {{
	["Model"] = {TYPE_STRING, "models/beer/wiremod/numpad.mdl"},
	["key"] = {TYPE_NUMBER, 1},
}})

registerSent("gmod_wire_motor", {
	_preFactory = function(ply, self)
		if not IsValid(self.Ent1) then SF.Throw("Invalid Entity, Parameter: ent1", 3) end
		if not IsValid(self.Ent2) then SF.Throw("Invalid Entity, Parameter: ent2", 3) end

		self.model = self.Model
		self.MyId = "starfall_createsent"
	end,

	_postFactory = function(ply, self, enttbl)
		MakeWireMotor(
			ply,
			enttbl.Ent1,
			enttbl.Ent2,
			enttbl.Bone1,
			enttbl.Bone2,
			enttbl.LPos1,
			enttbl.LPos2,
			enttbl.friction,
			enttbl.torque,
			0,
			enttbl.torque,
			enttbl.MyId
		)
	end,

	{
		["Model"] = {TYPE_STRING, "models/jaanus/wiretool/wiretool_siren.mdl"},
		["Ent1"] = {TYPE_ENTITY, nil},
		["Ent2"] = {TYPE_ENTITY, nil},
		["Bone1"] = {TYPE_NUMBER, 0},
		["Bone2"] = {TYPE_NUMBER, 0},
		["LPos1"] = {TYPE_VECTOR, Vector()},
		["LPos2"] = {TYPE_VECTOR, Vector()},
		["friction"] = {TYPE_NUMBER, 1},
		["torque"] = {TYPE_NUMBER, 500},
		["forcelimit"] = {TYPE_NUMBER, 0},
	}
})

registerSent("gmod_wire_explosive", {{
	["Model"] = {TYPE_STRING, "models/props_c17/oildrum001_explosive.mdl"},
	["key"] = {TYPE_NUMBER, 1},
	["damage"] = {TYPE_NUMBER, 200},
	["delaytime"] = {TYPE_NUMBER, 0},
	["removeafter"] = {TYPE_BOOL, false},
	["radius"] = {TYPE_NUMBER, 300},
	["affectother"] = {TYPE_BOOL, false},
	["notaffected"] = {TYPE_BOOL, false},
	["delayreloadtime"] = {TYPE_NUMBER, 0},
	["maxhealth"] = {TYPE_NUMBER, 100},
	["bulletproof"] = {TYPE_BOOL, false},
	["explosionproof"] = {TYPE_BOOL, false},
	["fallproof"] = {TYPE_BOOL, false},
	["explodeatzero"] = {TYPE_BOOL, true},
	["resetatexplode"] = {TYPE_BOOL, true},
	["fireeffect"] = {TYPE_BOOL, true},
	["coloreffect"] = {TYPE_BOOL, true},
	["invisibleatzero"] = {TYPE_BOOL, false},
}})

registerSent("gmod_wire_light", {{
	["Model"] = {TYPE_STRING, "models/jaanus/wiretool/wiretool_siren.mdl"},
	["directional"] = {TYPE_BOOL, false},
	["radiant"] = {TYPE_BOOL, false},
	["glow"] = {TYPE_BOOL, false},
	["brightness"] = {TYPE_NUMBER, 2},
	["size"] = {TYPE_NUMBER, 256},
	["R"] = {TYPE_NUMBER, 255},
	["G"] = {TYPE_NUMBER, 255},
	["B"] = {TYPE_NUMBER, 255},
}})

registerSent("gmod_wire_lamp", {{
	["Model"] = {TYPE_STRING, "models/lamps/torch.mdl"},
	["Texture"] = {TYPE_STRING, "effects/flashlight001"},
	["FOV"] = {TYPE_NUMBER, 90},
	["Dist"] = {TYPE_NUMBER, 1024},
	["Brightness"] = {TYPE_NUMBER, 8},
	["on"] = {TYPE_BOOL, false},
	["r"] = {TYPE_NUMBER, 255},
	["g"] = {TYPE_NUMBER, 255},
	["b"] = {TYPE_NUMBER, 255},
}})

registerSent("gmod_wire_keypad", {
	_preFactory = function(ply, self)
		self.Password = util.CRC(self.Password)
	end,

	{
		["Model"] = {TYPE_STRING, "models/props_lab/keypad.mdl"},
		["Password"] = {TYPE_STRING},
		["Secure"] = {TYPE_BOOL},
	}
})

registerSent("gmod_wire_data_store", {{
	["Model"] = {TYPE_STRING, "models/jaanus/wiretool/wiretool_range.mdl"},
}})

registerSent("gmod_wire_gpulib_controller", {{
	["Model"] = {TYPE_STRING, "models/jaanus/wiretool/wiretool_siren.mdl"},
}})

registerSent("gmod_wire_clutch", {{
	["Model"] = {TYPE_STRING, "models/jaanus/wiretool/wiretool_siren.mdl"},
}})

registerSent("gmod_wire_input", {{
	["Model"] = {TYPE_STRING, "models/beer/wiremod/numpad.mdl"},
	["keygroup"] = {TYPE_NUMBER, 7},
	["toggle"] = {TYPE_BOOL, false},
	["value_off"] = {TYPE_NUMBER, 0},
	["value_on"] = {TYPE_NUMBER, 1},
}})

registerSent("gmod_wire_indicator", {{
	["Model"] = {TYPE_STRING, "models/segment.mdl"},
	["a"] = {TYPE_NUMBER, 0},
	["b"] = {TYPE_NUMBER, 1},
	["ar"] = {TYPE_NUMBER, 255},
	["ag"] = {TYPE_NUMBER, 0},
	["ab"] = {TYPE_NUMBER, 0},
	["aa"] = {TYPE_NUMBER, 255},
	["br"] = {TYPE_NUMBER, 0},
	["bg"] = {TYPE_NUMBER, 255},
	["bb"] = {TYPE_NUMBER, 0},
	["ba"] = {TYPE_NUMBER, 255},
}})

registerSent("gmod_wire_igniter", {{
	["Model"] = {TYPE_STRING, "models/jaanus/wiretool/wiretool_siren.mdl"},
	["TargetPlayers"] = {TYPE_BOOL, false},
	["Range"] = {TYPE_NUMBER, 2048},
}})

registerSent("gmod_wire_hydraulic", {
	_preFactory = function(ply, self)
		if not IsValid(self.Ent1) then SF.Throw("Invalid Entity, Parameter: ent1", 3) end
		if not IsValid(self.Ent2) then SF.Throw("Invalid Entity, Parameter: ent2", 3) end

		self.model = self.Model
		self.MyId = "starfall_createsent"
	end,

	_postFactory = function(ply, self, enttbl)
		MakeWireHydraulic(
			ply,
			enttbl.Ent1,
			enttbl.Ent2,
			enttbl.Bone1,
			enttbl.Bone2,
			enttbl.LPos1,
			enttbl.LPos2,
			enttbl.width,
			enttbl.material,
			enttbl.speed,
			enttbl.fixed,
			enttbl.stretchonly,
			enttbl.MyId
		)
	end,

	{
		["Model"] = {TYPE_STRING, "models/beer/wiremod/hydraulic.mdl"},
		["Ent1"] = {TYPE_ENTITY, nil},
		["Ent2"] = {TYPE_ENTITY, nil},
		["Bone1"] = {TYPE_NUMBER, 0},
		["Bone2"] = {TYPE_NUMBER, 0},
		["LPos1"] = {TYPE_VECTOR, Vector()},
		["LPos2"] = {TYPE_VECTOR, Vector()},
		["width"] = {TYPE_NUMBER, 3},
		["material"] = {TYPE_STRING, "cable/rope"},
		["speed"] = {TYPE_NUMBER, 16},
		["fixed"] = {TYPE_NUMBER, 0},
		["stretchonly"] = {TYPE_BOOL, false},
	}
})

registerSent("gmod_wire_hudindicator", {{
	["Model"] = {TYPE_STRING, "models/jaanus/wiretool/wiretool_siren.mdl"},
	["a"] = {TYPE_NUMBER, 0},
	["b"] = {TYPE_NUMBER, 1},
	["material"] = {TYPE_STRING, "models/debug/debugwhite"},
	["showinhud"] = {TYPE_BOOL, false},
	["huddesc"] = {TYPE_STRING, ""},
	["hudaddname"] = {TYPE_BOOL, false},
	["hudshowvalue"] = {TYPE_NUMBER, 0},
	["hudstyle"] = {TYPE_NUMBER, 0},
	["allowhook"] = {TYPE_BOOL, true},
	["fullcircleangle"] = {TYPE_NUMBER, 0},
	["ar"] = {TYPE_NUMBER, 255},
	["ag"] = {TYPE_NUMBER, 0},
	["ab"] = {TYPE_NUMBER, 0},
	["aa"] = {TYPE_NUMBER, 255},
	["br"] = {TYPE_NUMBER, 0},
	["bg"] = {TYPE_NUMBER, 255},
	["bb"] = {TYPE_NUMBER, 0},
	["ba"] = {TYPE_NUMBER, 255},
}})

registerSent("gmod_wire_hoverball", {{
	["Model"] = {TYPE_STRING, "models/dav0r/hoverball.mdl"},
	["speed"] = {TYPE_NUMBER, 1},
	["resistance"] = {TYPE_NUMBER, 0},
	["strength"] = {TYPE_NUMBER, 1},
	["starton"] = {TYPE_BOOL, true},
}})

registerSent("gmod_wire_fx_emitter", {
	_preFactory = function(ply, self)
		self.effect = ComboBox_Wire_FX_Emitter_Options[self.effect]
	end,

	{
		["Model"] = {TYPE_STRING, "models/props_lab/tpplug.mdl"},
		["delay"] = {TYPE_NUMBER, 0.07},
		["effect"] = {TYPE_STRING, "sparks"},
	}
})

registerSent("gmod_wire_hologrid", {{
	["Model"] = {TYPE_STRING, "models/jaanus/wiretool/wiretool_siren.mdl"},
	["usegps"] = {TYPE_BOOL, false},
}})

registerSent("gmod_wire_data_transferer", {{
	["Model"] = {TYPE_STRING, "models/jaanus/wiretool/wiretool_siren.mdl"},
	["Range"] = {TYPE_NUMBER, 25000},
	["DefaultZero"] = {TYPE_BOOL, false},
	["IgnoreZero"] = {TYPE_BOOL, false},
}})

registerSent("gmod_wire_graphics_tablet", {{
	["Model"] = {TYPE_STRING, "models/kobilica/wiremonitorbig.mdl"},
	["gmode"] = {TYPE_BOOL, false},
	["draw_background"] = {TYPE_BOOL, true},
}})

registerSent("gmod_wire_gps", {{
	["Model"] = {TYPE_STRING, "models/beer/wiremod/gps.mdl"},
}})

registerSent("gmod_wire_gimbal", {{
	["Model"] = {TYPE_STRING, "models/props_c17/canister01a.mdl"},
}})

registerSent("gmod_wire_button", {{
	["Model"] = {TYPE_STRING, "models/props_c17/clock01.mdl"},
	["toggle"] = {TYPE_BOOL, false},
	["value_off"] = {TYPE_NUMBER, 0},
	["value_on"] = {TYPE_NUMBER, 1},
	["description"] = {TYPE_STRING, ""},
	["entityout"] = {TYPE_BOOL, false},
}})

registerSent("gmod_wire_extbus", {{
	["Model"] = {TYPE_STRING, "models/jaanus/wiretool/wiretool_gate.mdl"},
}})

registerSent("gmod_wire_locator", {{
	["Model"] = {TYPE_STRING, "models/props_lab/powerbox02d.mdl"},
}})

registerSent("gmod_wire_cameracontroller", {{
	["Model"] = {TYPE_STRING, "models/jaanus/wiretool/wiretool_siren.mdl"},
	["ParentLocal"] = {TYPE_BOOL, false},
	["AutoMove"] = {TYPE_BOOL, false},
	["FreeMove"] = {TYPE_BOOL, false},
	["LocalMove"] = {TYPE_BOOL, false},
	["AllowZoom"] = {TYPE_BOOL, false},
	["AutoUnclip"] = {TYPE_BOOL, false},
	["DrawPlayer"] = {TYPE_BOOL, true},
	["AutoUnclip_IgnoreWater"] = {TYPE_BOOL, false},
	["DrawParent"] = {TYPE_BOOL, true},
}})

registerSent("gmod_wire_dual_input", {{
	["Model"] = {TYPE_STRING, "models/beer/wiremod/numpad.mdl"},
	["keygroup"] = {TYPE_NUMBER, 7},
	["keygroup2"] = {TYPE_NUMBER, 4},
	["toggle"] = {TYPE_BOOL, false},
	["value_off"] = {TYPE_NUMBER, 0},
	["value_on"] = {TYPE_NUMBER, 1},
	["value_on2"] = {TYPE_NUMBER, -1},
}})

registerSent("gmod_wire_cd_ray", {{
	["Model"] = {TYPE_STRING, "models/jaanus/wiretool/wiretool_beamcaster.mdl"},
	["Range"] = {TYPE_NUMBER, 64},
	["DefaultZero"] = {TYPE_BOOL, false},
}})

registerSent("gmod_wire_datarate", {{
	["Model"] = {TYPE_STRING, "models/jaanus/wiretool/wiretool_gate.mdl"},
}})

registerSent("gmod_wire_keyboard", {{
	["Model"] = {TYPE_STRING, "models/jaanus/wiretool/wiretool_input.mdl"},
	["AutoBuffer"] = {TYPE_BOOL, true},
	["Synchronous"] = {TYPE_BOOL, true},
	["EnterKeyAscii"] = {TYPE_BOOL, true},
}})

registerSent("gmod_wire_dynamic_button", {{
	["Model"] = {TYPE_STRING, "models/bull/ranger.mdl"},
	["toggle"] = {TYPE_BOOL, false},
	["value_on"] = {TYPE_NUMBER, 1},
	["value_off"] = {TYPE_NUMBER, 0},
	["description"] = {TYPE_STRING, ""},
	["entityout"] = {TYPE_BOOL, false},
	["material_on"] = {TYPE_STRING, "bull/dynamic_button_1"},
	["material_off"] = {TYPE_STRING, "bull/dynamic_button_0"},
	["on_r"] = {TYPE_NUMBER, 255},
	["on_g"] = {TYPE_NUMBER, 255},
	["on_b"] = {TYPE_NUMBER, 255},
	["off_r"] = {TYPE_NUMBER, 255},
	["off_g"] = {TYPE_NUMBER, 255},
	["off_b"] = {TYPE_NUMBER, 255},
}})

registerSent("gmod_wire_damage_detector", {{
	["Model"] = {TYPE_STRING, "models/jaanus/wiretool/wiretool_siren.mdl"},
	["includeconstrained"] = {TYPE_BOOL, false},
}})

registerSent("gmod_wire_hdd", {{
	["Model"] = {TYPE_STRING, "models/jaanus/wiretool/wiretool_gate.mdl"},
	["DriveID"] = {TYPE_NUMBER, 0},
	["DriveCap"] = {TYPE_NUMBER, 128},
}})

registerSent("gmod_wire_watersensor", {{
	["Model"] = {TYPE_STRING, "models/beer/wiremod/watersensor.mdl"},
}})

registerSent("gmod_wire_value", {
	_preFactory = function(ply, self)
		local valid_types = {
			NORMAL = true,
			VECTOR = true,
			VECTOR2 = true,
			VECTOR4 = true,
			ANGLE = true,
			STRING = true,
		}

		local value = {}
		for i, val in ipairs(self.value) do
			checkluatype(val, TYPE_TABLE, 3, "Parameter: value[" .. i .. "]")
			checkluatype(val[1], TYPE_STRING, 3, "Parameter: value[" .. i .. "][1]")

			local typ = string.upper(val[1])
			if not valid_types[typ] then SF.Throw("value[" .. i .. "] type is invalid " .. typ, 3) end

			checkluatype(val[2], TYPE_STRING, 3, "Parameter: value[" .. i .. "][2]")

			value[i] = {
				DataType = typ,
				Value = val[2]
			}
		end
		self.value = value
	end,

	{
		["Model"] = {TYPE_STRING, "models/kobilica/value.mdl"},
		["value"] = {TYPE_TABLE},
	}
})

registerSent("gmod_wire_adv_emarker", {{
	["Model"] = {TYPE_STRING, "models/jaanus/wiretool/wiretool_siren.mdl"},
}})

registerSent("gmod_wire_wheel", {
	_preFactory = function(ply, self)
		if not IsValid(self.Base) then SF.Throw("Invalid Entity, Parameter: base", 3) end
	end,

	_postFactory = function(ply, self, enttbl)
		local motor, axis = constraint.Motor(self, enttbl.Base, 0, enttbl.Bone, Vector(), enttbl.LPos, enttbl.friction, 1000, 0, 0, false, ply, enttbl.forcelimit)
		self:SetWheelBase(enttbl.Base)
		self:SetMotor(motor)
		self:SetDirection(motor.direction)
		local axis = Vector(enttbl.LAxis[1], enttbl.LAxis[2], enttbl.LAxis[3])
		axis:Rotate(self:GetAngles())
		self:SetAxis(axis)
		self:DoDirectionEffect()
	end,

	{
		["Model"] = {TYPE_STRING, "models/props_vehicles/carparts_wheel01a.mdl"},
		["Base"] = {TYPE_ENTITY, nil},
		["Bone"] = {TYPE_NUMBER, 0},
		["LPos"] = {TYPE_VECTOR, Vector()},
		["LAxis"] = {TYPE_VECTOR, Vector(0, 1, 0)},
		["fwd"] = {TYPE_NUMBER, 1},
		["bck"] = {TYPE_NUMBER, -1},
		["stop"] = {TYPE_NUMBER, 0},
		["BaseTorque"] = {TYPE_NUMBER, 3000},
		["friction"] = {TYPE_NUMBER, 1},
		["forcelimit"] = {TYPE_NUMBER, 0},
	}
})

registerSent("gmod_wire_gyroscope", {{
	["Model"] = {TYPE_STRING, "models/bull/various/gyroscope.mdl"},
	["out180"] = {TYPE_BOOL, false},
}})

registerSent("gmod_wire_datasocket", {{
	["Model"] = {TYPE_STRING, "models/hammy/pci_slot.mdl"},
	["WeldForce"] = {TYPE_NUMBER, 5000},
	["AttachRange"] = {TYPE_NUMBER, 5},
}})

registerSent("gmod_wire_eyepod", {{
	["Model"] = {TYPE_STRING, "models/jaanus/wiretool/wiretool_siren.mdl"},
	["DefaultToZero"] = {TYPE_NUMBER, 1},
	["ShowRateOfChange"] = {TYPE_NUMBER, 1},
	["ClampXMin"] = {TYPE_NUMBER, 0},
	["ClampXMax"] = {TYPE_NUMBER, 0},
	["ClampYMin"] = {TYPE_NUMBER, 0},
	["ClampYMax"] = {TYPE_NUMBER, 0},
	["ClampX"] = {TYPE_NUMBER, 0},
	["ClampY"] = {TYPE_NUMBER, 0},
}})

registerSent("gmod_wire_gate", {{
	["Model"] = {TYPE_STRING, "models/jaanus/wiretool/wiretool_gate.mdl"},
	["action"] = {TYPE_STRING, "+"},
}})

registerSent("gmod_wire_freezer", {{
	["Model"] = {TYPE_STRING, "models/jaanus/wiretool/wiretool_siren.mdl"},
}})

-- Chip bois
registerSent("gmod_wire_expression2", {
	_preFactory = function(ply, self)
		self._inputs = {{}, {}}
		self._outputs = {{}, {}}
		self._vars = {}
		self.filepath = "generic_starfall.txt"

		local inc_files = {}
		for path, code in pairs(self.inc_files) do
			checkluatype(path, TYPE_STRING, 3, "Parameter: inc_files[" .. path .. "]")
			checkluatype(code, TYPE_STRING, 3, "Parameter: inc_files[" .. path .. "]")

			inc_files[path] = code
		end
		self.inc_files = inc_files
	end,
	{
		["Model"] = {TYPE_STRING, "models/beer/wiremod/gate_e2.mdl"},
		["_name"] = {TYPE_STRING, "Generic"},
		["_original"] = {TYPE_STRING, "print(\"Hello World!\")"},
		["inc_files"] = {TYPE_TABLE, {}},
	}
})

end
end)

----------------------------------------
-- So the library doesn't produce an error when loaded

return function() end
