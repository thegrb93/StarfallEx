SF.Sounds = {}

--- Sound type
-- @shared
local sound_methods, sound_metamethods = SF.Typedef("Sound")
local wrap, unwrap = SF.CreateWrapper(sound_metamethods, true, false, debug.getregistry().CSoundPatch)

--- Sounds library.
-- @shared
local sound_library = SF.Libraries.Register("sounds")

SF.Sounds.Wrap = wrap
SF.Sounds.Unwrap = unwrap
SF.Sounds.Methods = sound_methods
SF.Sounds.Metatable = sound_metamethods

SF.Sounds.burstmax = CreateConVar("sf_sounds_burstmax", "20", { FCVAR_ARCHIVE, FCVAR_REPLICATED },
	"The number of sounds allowed to be made in a short interval of time via Starfall scripts for a single instance ( burst )")
	
SF.Sounds.burstrate = CreateConVar("sf_sounds_burstrate", "10", { FCVAR_ARCHIVE, FCVAR_REPLICATED },
	"The rate at which the burst regenerates per second.")

-- Register Privileges
do
	local P = SF.Permissions
	P.registerPrivilege("sound.create", "Sound", "Allows the user to create sounds", { ["Client"] = {} })
	P.registerPrivilege("sound.modify", "Sound", "Allows the user to modify created sounds", { ["Client"] = {} })
end

-- Register functions to be called when the chip is initialised and deinitialised
SF.Libraries.AddHook("initialize", function (inst)
	inst.data.sounds = {
		sounds = {},
		burst = SF.BurstObject(SF.Sounds.burstrate:GetFloat(), SF.Sounds.burstmax:GetFloat())
	}
end)

SF.Libraries.AddHook("deinitialize", function (inst)
	local sounds = inst.data.sounds.sounds
	local s = next(sounds)
	while s do
		unwrap(s):Stop()
		sounds[s] = nil
		s = next(sounds)
	end
end)

--- Creates a sound and attaches it to an entity
-- @param ent Entity to attach sound to.
-- @param path Filepath to the sound file.
-- @return Sound Object
function sound_library.create (ent, path)
	SF.Permissions.check(SF.instance.player, { ent, path }, "sound.create")
	if not SF.instance.data.sounds.burst:use(1) then SF.Throw("Can't create sounds that often", 2) end

	SF.CheckType(ent, SF.Types["Entity"])
	SF.CheckLuaType(path, TYPE_STRING)

	if path:match('["?]') then
		SF.Throw("Invalid sound path: " .. path, 2)
	end

	local e = SF.UnwrapObject(ent)
	if not (e or e:IsValid()) then
		SF.Throw("Invalid Entity", 2)
	end

	local s = wrap(CreateSound(e, path))
	local i = SF.instance.data.sounds.sounds
	i[s] = s

	return i[s]
end


--- Returns if a sound is able to be created
-- @return If it is possible to make a sound
function sound_library.canCreate()
	return SF.instance.data.sounds.burst:check()>1
end

--------------------------------------------------

--- Starts to play the sound.
function sound_methods:play ()
	SF.Permissions.check(SF.instance.player, unwrap(self), "sound.modify")
	SF.CheckType(self, sound_metamethods)
	unwrap(self):Play()
end

--- Stops the sound from being played.
-- @param fade Time in seconds to fade out, if nil or 0 the sound stops instantly.
function sound_methods:stop (fade)
	SF.Permissions.check(SF.instance.player, unwrap(self), "sound.modify")
	if fade then
		SF.CheckLuaType(fade, TYPE_NUMBER)
		unwrap(self):FadeOut(math.max(fade, 0))
	else
		unwrap(self):Stop()
	end
end

--- Sets the volume of the sound.
-- @param vol Volume to set to, between 0 and 1.
-- @param fade Time in seconds to transition to this new volume.
function sound_methods:setVolume (vol, fade)
	SF.Permissions.check(SF.instance.player, unwrap(self), "sound.modify")
	SF.CheckLuaType(vol, TYPE_NUMBER)

	if fade then
		SF.CheckLuaType(fade, TYPE_NUMBER)
		fade = math.abs(fade, 0)
	else	
		fade = 0
	end

	vol = math.Clamp(vol, 0, 1)
	unwrap(self):ChangeVolume(vol, fade)
end

--- Sets the pitch of the sound.
-- @param pitch Pitch to set to, between 0 and 255.
-- @param fade Time in seconds to transition to this new pitch.
function sound_methods:setPitch (pitch, fade)
	SF.Permissions.check(SF.instance.player, unwrap(self), "sound.modify")
	SF.CheckLuaType(pitch, TYPE_NUMBER)
	
	if fade then
		SF.CheckLuaType(fade, TYPE_NUMBER)
		fade = math.max(fade, 0)
	else	
		fade = 0
	end

	pitch = math.Clamp(pitch, 0, 255)
	unwrap(self):ChangePitch(pitch, fade)
end

--- Returns whether the sound is being played.
function sound_methods:isPlaying ()
	return unwrap(self):IsPlaying()	
end

--- Sets the sound level in dB.
-- @param level dB level, see <a href='https://developer.valvesoftware.com/wiki/Soundscripts#SoundLevel'> Vale Dev Wiki</a>, for information on the value to use.
function sound_methods:setSoundLevel (level)
	SF.Permissions.check(SF.instance.player, unwrap(self), "sound.modify")
	SF.CheckLuaType(level, TYPE_NUMBER)
	unwrap(self):SetSoundLevel(math.Clamp(level, 0, 511))
end
