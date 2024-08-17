-- Global to all starfalls
local checkluatype = SF.CheckLuaType
local registerprivilege = SF.Permissions.registerPrivilege

-- Register Privileges
registerprivilege("sound.create", "Sound", "Allows the user to create sounds", { client = {} })

local plyCount = SF.LimitObject("sounds", "sounds", 20, "The number of sounds allowed to be playing via Starfall client at once")
local plySoundBurst = SF.BurstObject("sounds", "sounds", 10, 5, "The rate at which the burst regenerates per second.", "The number of sounds allowed to be made in a short interval of time via Starfall scripts for a single instance ( burst )")

SF.ResourceCounters.Sounds = {icon = "icon16/sound.png", count = function(ply) return plyCount:get(ply) end}

local soundsByEntity = SF.EntityTable("soundsByEntity", function(e, t)
	for snd, _ in pairs(t) do
		snd:Stop()
	end
end)

--- Sound library.
-- @name sound
-- @class library
-- @libtbl sound_library
SF.RegisterLibrary("sound")

--- Sound type
-- @name Sound
-- @class type
-- @libtbl sound_methods
SF.RegisterType("Sound", true, false)


return function(instance)
local checkpermission = instance.player ~= SF.Superuser and SF.Permissions.check or function() end

local sound_library = instance.Libraries.sound
local sound_methods, sound_meta, wrap, unwrap = instance.Types.Sound.Methods, instance.Types.Sound, instance.Types.Sound.Wrap, instance.Types.Sound.Unwrap
local ent_meta, ewrap, eunwrap = instance.Types.Entity, instance.Types.Entity.Wrap, instance.Types.Entity.Unwrap

local sounds = {}
local function registerSound(ent, sound)
	local sndsByEnt = soundsByEntity[ent]
	if not sndsByEnt then sndsByEnt = {} soundsByEntity[ent] = sndsByEnt end
	sndsByEnt[sound] = true
	sounds[sound] = ent
end

local function destroySound(sound)
	sound:Stop()
	local ent = sounds[sound]
	if ent then
		sounds[sound] = nil
		plyCount:free(instance.player, 1)
		if soundsByEntity[ent] then
			soundsByEntity[ent][sound] = nil
		end
	end
end

local getent
instance:AddHook("initialize", function()
	getent = instance.Types.Entity.GetEntity
end)

instance:AddHook("deinitialize", function()
	for s in pairs(sounds) do
		destroySound(s)
	end
end)

--- Creates a sound and attaches it to an entity
-- @param Entity ent Entity to attach sound to.
-- @param string path Filepath to the sound file.
-- @param boolean? nofilter (Optional) Boolean Make the sound play for everyone regardless of range or location. Only affects Server-side sounds.
-- @return Sound Sound Object
function sound_library.create(ent, path, nofilter)
	checkluatype(path, TYPE_STRING)
	if nofilter~=nil then checkluatype(nofilter, TYPE_BOOL) end

	if #path>260 then SF.Throw("Sound path too long!") end
	if string.match(path, "[\"?]") then SF.Throw("Sound path contains invalid characters!") end

	checkpermission(instance, { ent, path }, "sound.create")

	local e = getent(ent)

	plySoundBurst:use(instance.player, 1)
	plyCount:use(instance.player, 1)

	local filter
	if nofilter and SERVER then
		filter = RecipientFilter()
		filter:AddAllPlayers()
	end

	local sound = CreateSound(e, path, filter)
	registerSound(e, sound)
	return wrap(sound)
end


--- Returns if a sound is able to be created
-- @return boolean If it is possible to make a sound
function sound_library.canCreate()
	return plyCount:check(instance.player) > 0 and plySoundBurst:check(instance.player) >= 1
end

--- Returns the number of sounds left that can be created
-- @return number The number of sounds left
function sound_library.soundsLeft()
	return math.min(plyCount:check(instance.player), plySoundBurst:check(instance.player))
end

--- Returns the sound duration in seconds. May not work for all file-types on linux/macos
-- @param string path String path to the sound file
-- @return number Number duration in seconds
function sound_library.duration(path)
    checkluatype(path, TYPE_STRING)
    return SoundDuration(path)
end

--------------------------------------------------

--- Starts to play the sound.
function sound_methods:play()
	unwrap(self):Play()
end

--- Stops the sound from being played.
-- @param number? fade Time in seconds to fade out, if nil or 0 the sound stops instantly.
function sound_methods:stop(fade)
	if fade~=nil then
		checkluatype(fade, TYPE_NUMBER)
		unwrap(self):FadeOut(math.max(fade, 0))
	else
		unwrap(self):Stop()
	end
end

--- Removes the sound from the game so new one can be created if limit is reached
function sound_methods:destroy()
	local snd = unwrap(self)
	destroySound(snd)
	sound_meta.sf2sensitive[self] = nil
	sound_meta.sensitive2sf[snd] = nil
end

--- Sets the volume of the sound. Won't work unless the sound is playing.
-- @param number vol Volume to set to, between 0 and 1.
-- @param number? fade Time in seconds to transition to this new volume. Default 0
function sound_methods:setVolume(vol, fade)
	checkluatype(vol, TYPE_NUMBER)

	if fade~=nil then
		checkluatype (fade, TYPE_NUMBER)
		fade = math.abs(fade, 0)
	else
		fade = 0
	end

	vol = math.Clamp(vol, 0, 1)
	unwrap(self):ChangeVolume(vol, fade)
end

--- Sets the pitch of the sound. Won't work unless the sound is playing.
-- @param number pitch Pitch to set to, between 0 and 255.
-- @param number? fade Time in seconds to transition to this new pitch. Default 0
function sound_methods:setPitch(pitch, fade)
	checkluatype(pitch, TYPE_NUMBER)

	if fade~=nil then
		checkluatype (fade, TYPE_NUMBER)
		fade = math.max(fade, 0)
	else
		fade = 0
	end

	pitch = math.Clamp(pitch, 0, 255)
	unwrap(self):ChangePitch(pitch, fade)
end

--- Returns whether the sound is being played.
-- @return boolean Whether the sound is playing or not
function sound_methods:isPlaying()
	return unwrap(self):IsPlaying()
end

--- Sets the sound level in dB. Won't work if the sound is already playing.
-- @param number level dB level, for information on the value to use see https://developer.valvesoftware.com/wiki/Soundscripts#SoundLevel
function sound_methods:setSoundLevel(level)
	checkluatype(level, TYPE_NUMBER)
	unwrap(self):SetSoundLevel(math.Clamp(level, 0, 511))
end

--- Returns the current sound level in dB.
-- @return number Level in dB
function sound_methods:getSoundLevel()
	return unwrap(self):GetSoundLevel()
end

--- Sets the sound dsp value
-- @param number dsp (0 - 133) DSP values. List can be found here https://developer.valvesoftware.com/wiki/Dsp_presets
function sound_methods:setDSP(dsp)
	checkluatype(dsp, TYPE_NUMBER)
	unwrap(self):SetDSP(math.Clamp(dsp, 0, 133))
end

--- Gets the sound dsp value
-- @return number (0 - 133) DSP value.
function sound_methods:getDSP()
	return unwrap(self):GetDSP()
end

end
