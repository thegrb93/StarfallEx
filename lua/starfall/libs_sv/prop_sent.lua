-- Simple helper function that provides model if it doesnt exist
local function registerSent(class, data)
	list.Set("starfall_creatable_sent", class, data)
end

----------------------------------------
-- Sent registering
local checkluatype = SF.CheckLuaType

-- Basic Gmod sents
registerSent("gmod_balloon", {{
	["Model"] = {TYPE_STRING, "models/maxofs2d/balloon_classic.mdl"},
	["force"] = {TYPE_NUMBER},
	["r"] = {TYPE_NUMBER, 255},
	["g"] = {TYPE_NUMBER, 255},
	["b"] = {TYPE_NUMBER, 255},
}})

registerSent("gmod_button", {{
	["Model"] = {TYPE_STRING, "models/maxofs2d/button_05.mdl"},
	["description"] = {TYPE_STRING, ""},
	["key"] = {TYPE_NUMBER},
	["toggle"] = {TYPE_BOOL, true},
}})

registerSent("gmod_cameraprop", {{
	["Model"] = {TYPE_STRING, "models/dav0r/camera.mdl"},
	["controlkey"] = {TYPE_NUMBER},
	["locked"] = {TYPE_BOOL, false},
	["toggle"] = {TYPE_BOOL, true},
}})

registerSent("gmod_dynamite", {{
	["Model"] = {TYPE_STRING, "models/dav0r/tnt/tnt.mdl"},
	["key"] = {TYPE_NUMBER},
	["Damage"] = {TYPE_NUMBER, 200},
	["delay"] = {TYPE_NUMBER, 0},
	["remove"] = {TYPE_BOOL, false},
}})

registerSent("gmod_emitter", {{
	["Model"] = {TYPE_STRING, "models/props_lab/tpplug.mdl"},
	["effect"] = {TYPE_STRING},
	["key"] = {TYPE_NUMBER},
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

registerSent("gmod_wire_friendslist", {
	_preFactory = function(ply, self)
		for k, steamid in pairs(self.steamids) do
			checkluatype(steamid, TYPE_STRING, 3, "Parameter: steamids[" .. k .. "]")
		end
	end,

	{
		["Model"] = {TYPE_STRING, "models/kobilica/value.mdl"},
		["save_on_entity"] = {TYPE_BOOL, false},
		["steamids"] = {TYPE_TABLE, {}}
	}
})

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

function SF.PrintCustomSENTDocs()
	local tostr = {
		string = function(x) return "\"" .. x .. "\"" end,
		table = table.ToString,
		Vector = function(x) return string.format("Vector(%s, %s, %s)", x[1], x[2], x[3]) end,
		Angle = function(x) return string.format("Angle(%s, %s, %s)", x[1], x[2], x[3]) end,
		Color = function(x) return string.format("Color(%s, %s, %s)", x.r, x.g, x.b) end,
	}

	local sorted = {}
	for class, data in pairs(list.GetForEdit("starfall_creatable_sent")) do
		local params = {}
		for param, org in pairs(data[1]) do
			params[#params+1] = {paramlower = string.lower(param), param = param, org = org}
		end
		sorted[#sorted+1] = {class = class, classlower = string.lower(class), params = params}
	end

	local classes = {"--- "}
	for _, data in SortedPairsByMemberValue(sorted, "classlower") do
		local str = {"-- > " .. data.class}
		for _, params in SortedPairsByMemberValue(data.params, "paramlower") do
			local param, org = params.param, params.org
			local typ = SF.TypeName(org[1])
			local def
			if org[2]~=nil then
				def = " = " .. (tostr[typ] and tostr[typ](org[2]) or tostring(org[2]))
			else
				def = ""
			end
			table.insert(str, "-- " .. typ .. " " .. param .. def)
		end

		table.insert(str, "-- ")
		table.insert(classes, table.concat(str, "\n"))
	end

	table.insert(classes, "-- @name props_library.SENT_Data_Structures\n-- @class table")

	for _, str in ipairs(classes) do
		print(str)
	end
end

return function() end

--- 
-- > gmod_balloon
-- number b = 255
-- number force
-- number g = 255
-- string Model = "models/maxofs2d/balloon_classic.mdl"
-- number r = 255
-- 
-- > gmod_button
-- string description = ""
-- number key
-- string Model = "models/maxofs2d/button_05.mdl"
-- boolean toggle = true
-- 
-- > gmod_cameraprop
-- number controlkey
-- boolean locked = false
-- string Model = "models/dav0r/camera.mdl"
-- boolean toggle = true
-- 
-- > gmod_dynamite
-- number Damage = 200
-- number delay = 0
-- number key
-- string Model = "models/dav0r/tnt/tnt.mdl"
-- boolean remove = false
-- 
-- > gmod_emitter
-- number delay = 0
-- string effect
-- number key
-- string Model = "models/props_lab/tpplug.mdl"
-- number scale = 1
-- boolean starton = false
-- boolean toggle = true
-- 
-- > gmod_hoverball
-- number key_d = -1
-- number key_u = -1
-- string Model = "models/dav0r/hoverball.mdl"
-- number resistance = 0
-- number speed = 1
-- number strength = 1
-- 
-- > gmod_lamp
-- number b = 255
-- number brightness = 4
-- number distance = 1024
-- number fov = 90
-- number g = 255
-- number KeyDown = -1
-- string Model = "models/lamps/torch.mdl"
-- boolean on = false
-- number r = 255
-- string Texture = "effects/flashlight001"
-- boolean toggle = true
-- 
-- > gmod_light
-- number Brightness = 2
-- number KeyDown = -1
-- number lightb = 255
-- number lightg = 255
-- number lightr = 255
-- string Model = "models/maxofs2d/light_tubular.mdl"
-- boolean on = false
-- number Size = 256
-- boolean toggle = true
-- 
-- > gmod_thruster
-- boolean damageable = false
-- string effect = "fire"
-- number force = 1500
-- number key = -1
-- number key_bck = -1
-- string Model = "models/props_phx2/garbage_metalcan001a.mdl"
-- string soundname = "PhysicsCannister.ThrusterLoop"
-- boolean toggle = false
-- 
-- > gmod_wire_addressbus
-- number Mem1st = 0
-- number Mem1sz = 0
-- number Mem2st = 0
-- number Mem2sz = 0
-- number Mem3st = 0
-- number Mem3sz = 0
-- number Mem4st = 0
-- number Mem4sz = 0
-- string Model = "models/jaanus/wiretool/wiretool_gate.mdl"
-- 
-- > gmod_wire_adv_emarker
-- string Model = "models/jaanus/wiretool/wiretool_siren.mdl"
-- 
-- > gmod_wire_adv_input
-- number keyless = 1
-- number keymore = 3
-- string Model = "models/beer/wiremod/numpad.mdl"
-- number speed = 1
-- boolean toggle = false
-- number value_max = 10
-- number value_min = 0
-- number value_start = 5
-- 
-- > gmod_wire_button
-- string description = ""
-- boolean entityout = false
-- string Model = "models/props_c17/clock01.mdl"
-- boolean toggle = false
-- number value_off = 0
-- number value_on = 1
-- 
-- > gmod_wire_cameracontroller
-- boolean AllowZoom = false
-- boolean AutoMove = false
-- boolean AutoUnclip = false
-- boolean AutoUnclip_IgnoreWater = false
-- boolean DrawParent = true
-- boolean DrawPlayer = true
-- boolean FreeMove = false
-- boolean LocalMove = false
-- string Model = "models/jaanus/wiretool/wiretool_siren.mdl"
-- boolean ParentLocal = false
-- 
-- > gmod_wire_cd_disk
-- number IRadius = 10
-- string Model = "models/venompapa/wirecd_medium.mdl"
-- number Precision = 4
-- number Skin = 0
-- 
-- > gmod_wire_cd_ray
-- boolean DefaultZero = false
-- string Model = "models/jaanus/wiretool/wiretool_beamcaster.mdl"
-- number Range = 64
-- 
-- > gmod_wire_clutch
-- string Model = "models/jaanus/wiretool/wiretool_siren.mdl"
-- 
-- > gmod_wire_colorer
-- string Model = "models/jaanus/wiretool/wiretool_siren.mdl"
-- boolean outColor = false
-- number Range = 2000
-- 
-- > gmod_wire_consolescreen
-- string Model = "models/props_lab/monitor01b.mdl"
-- 
-- > gmod_wire_damage_detector
-- boolean includeconstrained = false
-- string Model = "models/jaanus/wiretool/wiretool_siren.mdl"
-- 
-- > gmod_wire_data_satellitedish
-- string Model = "models/props_wasteland/prison_lamp001c.mdl"
-- 
-- > gmod_wire_data_store
-- string Model = "models/jaanus/wiretool/wiretool_range.mdl"
-- 
-- > gmod_wire_data_transferer
-- boolean DefaultZero = false
-- boolean IgnoreZero = false
-- string Model = "models/jaanus/wiretool/wiretool_siren.mdl"
-- number Range = 25000
-- 
-- > gmod_wire_dataport
-- string Model = "models/jaanus/wiretool/wiretool_gate.mdl"
-- 
-- > gmod_wire_datarate
-- string Model = "models/jaanus/wiretool/wiretool_gate.mdl"
-- 
-- > gmod_wire_datasocket
-- number AttachRange = 5
-- string Model = "models/hammy/pci_slot.mdl"
-- number WeldForce = 5000
-- 
-- > gmod_wire_detonator
-- number damage = 1
-- string Model = "models/props_combine/breenclock.mdl"
-- 
-- > gmod_wire_dhdd
-- string Model
-- 
-- > gmod_wire_digitalscreen
-- string Model = "models/props_lab/monitor01b.mdl"
-- number ScreenHeight = 32
-- number ScreenWidth = 32
-- 
-- > gmod_wire_dual_input
-- number keygroup = 7
-- number keygroup2 = 4
-- string Model = "models/beer/wiremod/numpad.mdl"
-- boolean toggle = false
-- number value_off = 0
-- number value_on = 1
-- number value_on2 = -1
-- 
-- > gmod_wire_dynamic_button
-- string description = ""
-- boolean entityout = false
-- string material_off = "bull/dynamic_button_0"
-- string material_on = "bull/dynamic_button_1"
-- string Model = "models/bull/ranger.mdl"
-- number off_b = 255
-- number off_g = 255
-- number off_r = 255
-- number on_b = 255
-- number on_g = 255
-- number on_r = 255
-- boolean toggle = false
-- number value_off = 0
-- number value_on = 1
-- 
-- > gmod_wire_egp
-- string Model = "models/kobilica/wiremonitorbig.mdl"
-- 
-- > gmod_wire_egp_emitter
-- string Model = "models/bull/dynamicbutton.mdl"
-- 
-- > gmod_wire_egp_hud
-- string Model = "models/bull/dynamicbutton.mdl"
-- 
-- > gmod_wire_emarker
-- string Model = "models/jaanus/wiretool/wiretool_siren.mdl"
-- 
-- > gmod_wire_exit_point
-- string Model = "models/jaanus/wiretool/wiretool_range.mdl"
-- 
-- > gmod_wire_explosive
-- boolean affectother = false
-- boolean bulletproof = false
-- boolean coloreffect = true
-- number damage = 200
-- number delayreloadtime = 0
-- number delaytime = 0
-- boolean explodeatzero = true
-- boolean explosionproof = false
-- boolean fallproof = false
-- boolean fireeffect = true
-- boolean invisibleatzero = false
-- number key = 1
-- number maxhealth = 100
-- string Model = "models/props_c17/oildrum001_explosive.mdl"
-- boolean notaffected = false
-- number radius = 300
-- boolean removeafter = false
-- boolean resetatexplode = true
-- 
-- > gmod_wire_expression2
-- string _name = "Generic"
-- string _original = "print("Hello World!")"
-- table inc_files = {}
-- string Model = "models/beer/wiremod/gate_e2.mdl"
-- 
-- > gmod_wire_extbus
-- string Model = "models/jaanus/wiretool/wiretool_gate.mdl"
-- 
-- > gmod_wire_eyepod
-- number ClampX = 0
-- number ClampXMax = 0
-- number ClampXMin = 0
-- number ClampY = 0
-- number ClampYMax = 0
-- number ClampYMin = 0
-- number DefaultToZero = 1
-- string Model = "models/jaanus/wiretool/wiretool_siren.mdl"
-- number ShowRateOfChange = 1
-- 
-- > gmod_wire_forcer
-- number Force = 1
-- number Length = 100
-- string Model = "models/jaanus/wiretool/wiretool_siren.mdl"
-- boolean Reaction = false
-- boolean ShowBeam = true
-- 
-- > gmod_wire_freezer
-- string Model = "models/jaanus/wiretool/wiretool_siren.mdl"
-- 
-- > gmod_wire_friendslist
-- string Model = "models/kobilica/value.mdl"
-- boolean save_on_entity = false
-- table steamids = {}
-- 
-- > gmod_wire_fx_emitter
-- number delay = 0.07
-- string effect = "sparks"
-- string Model = "models/props_lab/tpplug.mdl"
-- 
-- > gmod_wire_gate
-- string action = "+"
-- string Model = "models/jaanus/wiretool/wiretool_gate.mdl"
-- 
-- > gmod_wire_gimbal
-- string Model = "models/props_c17/canister01a.mdl"
-- 
-- > gmod_wire_gps
-- string Model = "models/beer/wiremod/gps.mdl"
-- 
-- > gmod_wire_gpulib_controller
-- string Model = "models/jaanus/wiretool/wiretool_siren.mdl"
-- 
-- > gmod_wire_grabber
-- boolean Gravity = true
-- string Model = "models/jaanus/wiretool/wiretool_range.mdl"
-- number Range = 100
-- 
-- > gmod_wire_graphics_tablet
-- boolean draw_background = true
-- boolean gmode = false
-- string Model = "models/kobilica/wiremonitorbig.mdl"
-- 
-- > gmod_wire_gyroscope
-- string Model = "models/bull/various/gyroscope.mdl"
-- boolean out180 = false
-- 
-- > gmod_wire_hdd
-- number DriveCap = 128
-- number DriveID = 0
-- string Model = "models/jaanus/wiretool/wiretool_gate.mdl"
-- 
-- > gmod_wire_holoemitter
-- string Model = "models/jaanus/wiretool/wiretool_range.mdl"
-- 
-- > gmod_wire_hologrid
-- string Model = "models/jaanus/wiretool/wiretool_siren.mdl"
-- boolean usegps = false
-- 
-- > gmod_wire_hoverball
-- string Model = "models/dav0r/hoverball.mdl"
-- number resistance = 0
-- number speed = 1
-- boolean starton = true
-- number strength = 1
-- 
-- > gmod_wire_hudindicator
-- number a = 0
-- number aa = 255
-- number ab = 0
-- number ag = 0
-- boolean allowhook = true
-- number ar = 255
-- number b = 1
-- number ba = 255
-- number bb = 0
-- number bg = 255
-- number br = 0
-- number fullcircleangle = 0
-- boolean hudaddname = false
-- string huddesc = ""
-- number hudshowvalue = 0
-- number hudstyle = 0
-- string material = "models/debug/debugwhite"
-- string Model = "models/jaanus/wiretool/wiretool_siren.mdl"
-- boolean showinhud = false
-- 
-- > gmod_wire_hydraulic
-- number Bone1 = 0
-- number Bone2 = 0
-- Entity Ent1
-- Entity Ent2
-- number fixed = 0
-- Vector LPos1 = Vector(0, 0, 0)
-- Vector LPos2 = Vector(0, 0, 0)
-- string material = "cable/rope"
-- string Model = "models/beer/wiremod/hydraulic.mdl"
-- number speed = 16
-- boolean stretchonly = false
-- number width = 3
-- 
-- > gmod_wire_igniter
-- string Model = "models/jaanus/wiretool/wiretool_siren.mdl"
-- number Range = 2048
-- boolean TargetPlayers = false
-- 
-- > gmod_wire_indicator
-- number a = 0
-- number aa = 255
-- number ab = 0
-- number ag = 0
-- number ar = 255
-- number b = 1
-- number ba = 255
-- number bb = 0
-- number bg = 255
-- number br = 0
-- string Model = "models/segment.mdl"
-- 
-- > gmod_wire_input
-- number keygroup = 7
-- string Model = "models/beer/wiremod/numpad.mdl"
-- boolean toggle = false
-- number value_off = 0
-- number value_on = 1
-- 
-- > gmod_wire_keyboard
-- boolean AutoBuffer = true
-- boolean EnterKeyAscii = true
-- string Model = "models/jaanus/wiretool/wiretool_input.mdl"
-- boolean Synchronous = true
-- 
-- > gmod_wire_keypad
-- string Model = "models/props_lab/keypad.mdl"
-- string Password
-- boolean Secure
-- 
-- > gmod_wire_lamp
-- number b = 255
-- number Brightness = 8
-- number Dist = 1024
-- number FOV = 90
-- number g = 255
-- string Model = "models/lamps/torch.mdl"
-- boolean on = false
-- number r = 255
-- string Texture = "effects/flashlight001"
-- 
-- > gmod_wire_las_receiver
-- string Model = "models/jaanus/wiretool/wiretool_range.mdl"
-- 
-- > gmod_wire_latch
-- string Model = "models/jaanus/wiretool/wiretool_siren.mdl"
-- 
-- > gmod_wire_lever
-- number Max = 1
-- number Min = 0
-- 
-- > gmod_wire_light
-- number B = 255
-- number brightness = 2
-- boolean directional = false
-- number G = 255
-- boolean glow = false
-- string Model = "models/jaanus/wiretool/wiretool_siren.mdl"
-- number R = 255
-- boolean radiant = false
-- number size = 256
-- 
-- > gmod_wire_locator
-- string Model = "models/props_lab/powerbox02d.mdl"
-- 
-- > gmod_wire_motor
-- number Bone1 = 0
-- number Bone2 = 0
-- Entity Ent1
-- Entity Ent2
-- number forcelimit = 0
-- number friction = 1
-- Vector LPos1 = Vector(0, 0, 0)
-- Vector LPos2 = Vector(0, 0, 0)
-- string Model = "models/jaanus/wiretool/wiretool_siren.mdl"
-- number torque = 500
-- 
-- > gmod_wire_nailer
-- number Flim = 0
-- string Model = "models/jaanus/wiretool/wiretool_siren.mdl"
-- number Range = 100
-- boolean ShowBeam = true
-- 
-- > gmod_wire_numpad
-- string Model = "models/beer/wiremod/numpad.mdl"
-- boolean toggle = false
-- number value_off = 0
-- number value_on = 0
-- 
-- > gmod_wire_oscilloscope
-- string Model = "models/props_lab/monitor01b.mdl"
-- 
-- > gmod_wire_output
-- number key = 1
-- string Model = "models/beer/wiremod/numpad.mdl"
-- 
-- > gmod_wire_pixel
-- string Model = "models/jaanus/wiretool/wiretool_siren.mdl"
-- 
-- > gmod_wire_pod
-- string Model = "models/jaanus/wiretool/wiretool_siren.mdl"
-- 
-- > gmod_wire_radio
-- string Channel = "1"
-- string Model = "models/props_lab/binderblue.mdl"
-- boolean Secure = false
-- number values = 4
-- 
-- > gmod_wire_ranger
-- boolean default_zero = true
-- boolean hires = false
-- boolean ignore_world = false
-- string Model = "models/jaanus/wiretool/wiretool_range.mdl"
-- boolean out_ang = false
-- boolean out_col = false
-- boolean out_dist = true
-- boolean out_eid = false
-- boolean out_hnrm = false
-- boolean out_pos = false
-- boolean out_sid = false
-- boolean out_uid = false
-- boolean out_val = false
-- boolean out_vel = false
-- number range = 1500
-- boolean show_beam = true
-- boolean trace_water = false
-- 
-- > gmod_wire_relay
-- number keygroup1 = 1
-- number keygroup2 = 2
-- number keygroup3 = 3
-- number keygroup4 = 4
-- number keygroup5 = 5
-- number keygroupoff = 0
-- string Model = "models/kobilica/relay.mdl"
-- boolean nokey = false
-- number normclose = 0
-- number poles = 1
-- number throws = 2
-- boolean toggle = true
-- 
-- > gmod_wire_screen
-- boolean Floor = false
-- boolean FormatNumber = false
-- boolean FormatTime = false
-- boolean LeftAlign = false
-- string Model = "models/props_lab/monitor01b.mdl"
-- boolean SingleBigFont = true
-- boolean SingleValue = false
-- string TextA = "Value A"
-- string TextB = "Value B"
-- 
-- > gmod_wire_sensor
-- boolean direction_normalized = false
-- boolean direction_vector = false
-- boolean gpscord = false
-- string Model
-- boolean outbrng = false
-- boolean outdist = true
-- boolean target_velocity = false
-- boolean velocity_normalized = false
-- boolean xyz_mode = false
-- 
-- > gmod_wire_simple_explosive
-- number damage = 200
-- number key = 1
-- string Model = "models/props_c17/oildrum001_explosive.mdl"
-- number radius = 300
-- boolean removeafter = false
-- 
-- > gmod_wire_socket
-- boolean ArrayInput = false
-- number AttachRange = 5
-- string Model = "models/props_lab/tpplugholder_single.mdl"
-- number WeldForce = 5000
-- 
-- > gmod_wire_soundemitter
-- string Model = "models/cheeze/wires/speaker.mdl"
-- string sound = "synth/square.wav"
-- 
-- > gmod_wire_spawner
-- number a = 255
-- number b = 255
-- number delay = 0
-- number g = 255
-- string mat = ""
-- string Model
-- number r = 255
-- number skin = 0
-- number spawn_effect = 0
-- number undo_delay = 0
-- 
-- > gmod_wire_speedometer
-- boolean AngVel = false
-- string Model
-- boolean z_only = false
-- 
-- > gmod_wire_target_finder
-- boolean beacons = false
-- boolean casesen = false
-- boolean checkbuddylist = false
-- boolean colorcheck = false
-- boolean colortarget = false
-- string entity = ""
-- boolean hoverballs = false
-- number maxbogeys = 1
-- number maxtargets = 1
-- number minrange = 1
-- string Model = "models/beer/wiremod/targetfinder.mdl"
-- boolean notargetowner = false
-- boolean notownersstuff = false
-- string npcname = ""
-- boolean npcs = true
-- boolean onbuddylist = false
-- boolean painttarget = true
-- number pcolA = 255
-- number pcolB = 255
-- number pcolG = 255
-- number pcolR = 255
-- string playername = ""
-- boolean players = false
-- string propmodel = ""
-- boolean props = false
-- number range = 1000
-- boolean rpgs = false
-- string steamname = ""
-- boolean thrusters = false
-- boolean vehicles = false
-- 
-- > gmod_wire_teleporter
-- string Model = "models/props_c17/utilityconducter001.mdl"
-- boolean UseEffects = true
-- boolean UseSounds = true
-- 
-- > gmod_wire_textentry
-- string Model = "models/beer/wiremod/keyboard.mdl"
-- 
-- > gmod_wire_textreceiver
-- boolean CaseInsensitive = true
-- table Matches
-- string Model = "models/jaanus/wiretool/wiretool_range.mdl"
-- boolean UseLuaPatterns = false
-- 
-- > gmod_wire_textscreen
-- Color bgcolor = Color(0, 0, 0)
-- number chrPerLine = 6
-- Color fgcolor = Color(255, 255, 255)
-- string Model = "models/kobilica/wiremonitorbig.mdl"
-- string text = ""
-- number textJust = 1
-- string tfont = "Arial"
-- number valign = 0
-- 
-- > gmod_wire_thruster
-- boolean bidir = true
-- number force = 1500
-- number force_max = 10000
-- number force_min = 0
-- string Model = "models/props_c17/lampShade001a.mdl"
-- boolean owater = true
-- string oweffect = "fire"
-- string soundname = ""
-- boolean uwater = true
-- string uweffect = "same"
-- 
-- > gmod_wire_trail
-- Color Color = Color(255, 255, 255)
-- number EndSize = 0
-- number Length = 5
-- string Material = "trails/lol"
-- number StartSize = 32
-- 
-- > gmod_wire_trigger
-- number filter = 0
-- string Model = "models/jaanus/wiretool/wiretool_siren.mdl"
-- number offsetx = 0
-- number offsety = 0
-- number offsetz = 0
-- boolean owneronly = false
-- number sizex = 64
-- number sizey = 64
-- number sizez = 64
-- 
-- > gmod_wire_turret
-- number damage = 10
-- number delay = 0.05
-- number force = 1
-- string Model = "models/weapons/w_smg1.mdl"
-- number numbullets = 1
-- string sound = "0"
-- number spread = 0
-- string tracer = "Tracer"
-- number tracernum = 1
-- 
-- > gmod_wire_twoway_radio
-- string Model = "models/props_lab/binderblue.mdl"
-- 
-- > gmod_wire_user
-- string Model = "models/jaanus/wiretool/wiretool_siren.mdl"
-- number Range = 200
-- 
-- > gmod_wire_value
-- string Model = "models/kobilica/value.mdl"
-- table value
-- 
-- > gmod_wire_vectorthruster
-- boolean angleinputs = false
-- boolean bidir = true
-- number force = 1500
-- number force_max = 10000
-- number force_min = 0
-- boolean lengthismul = false
-- number mode = 0
-- string Model = "models/jaanus/wiretool/wiretool_speed.mdl"
-- boolean owater = true
-- string oweffect = "fire"
-- string soundname = ""
-- boolean uwater = true
-- string uweffect = "same"
-- 
-- > gmod_wire_vehicle
-- string Model = "models/jaanus/wiretool/wiretool_siren.mdl"
-- 
-- > gmod_wire_watersensor
-- string Model = "models/beer/wiremod/watersensor.mdl"
-- 
-- > gmod_wire_waypoint
-- string Model = "models/props_lab/powerbox02d.mdl"
-- number range = 150
-- 
-- > gmod_wire_weight
-- string Model = "models/props_interiors/pot01a.mdl"
-- 
-- > gmod_wire_wheel
-- Entity Base
-- number BaseTorque = 3000
-- number bck = -1
-- number Bone = 0
-- number forcelimit = 0
-- number friction = 1
-- number fwd = 1
-- Vector LAxis = Vector(0, 1, 0)
-- Vector LPos = Vector(0, 0, 0)
-- string Model = "models/props_vehicles/carparts_wheel01a.mdl"
-- number stop = 0
-- 
-- @name props_library.SENT_Data_Structures
-- @class table
