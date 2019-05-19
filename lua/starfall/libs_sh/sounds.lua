SF.Sounds = {}

--- Sound type
-- @shared
local sound_methods, sound_metamethods = SF.RegisterType("Sound")
local wrap, unwrap = SF.CreateWrapper(sound_metamethods, true, false)
local checktype = SF.CheckType
local checkluatype = SF.CheckLuaType
local checkpermission = SF.Permissions.check

--- Sounds library.
-- @shared
local sound_library = SF.RegisterLibrary("sounds")

SF.Sounds.Wrap = wrap
SF.Sounds.Unwrap = unwrap
SF.Sounds.Methods = sound_methods
SF.Sounds.Metatable = sound_metamethods

-- Register Privileges
do
	local P = SF.Permissions
	P.registerPrivilege("sound.create", "Sound", "Allows the user to create sounds", { client = {} })
	P.registerPrivilege("sound.modify", "Sound", "Allows the user to modify created sounds", { client = {} })
end
local plyMaxSounds
if SERVER then
	plyMaxSounds = CreateConVar("sf_sounds_personalquota", "20", FCVAR_ARCHIVE, "The number of sounds allowed to be playing via Starfall server at once")
else
	plyMaxSounds = CreateConVar("sf_sounds_personalquota_cl", "20", FCVAR_ARCHIVE, "The number of sounds allowed to be playing via Starfall client at once")
end
local plyCount = SF.EntityTable("playerSounds")
local plySoundBurst = SF.EntityTable("playerSoundBurst")
local plySoundBurstGen = SF.BurstGenObject("sounds", 10, 5, "The rate at which the burst regenerates per second.", "The number of sounds allowed to be made in a short interval of time via Starfall scripts for a single instance ( burst )")

local soundsByEntity = SF.EntityTable("soundsByEntity", function(e, t)
	for snd, _ in pairs(t) do
		snd:Stop()
	end
end)

local function soundsLeft(ply)
	return plyMaxSounds:GetInt()<0 and -1 or (plyMaxSounds:GetInt() - plyCount[ply])
end

local function deleteSound(ply, ent, sound)
	sound:Stop()
	if plyCount[ply] then plyCount[ply] = plyCount[ply] - 1 end
	if soundsByEntity[ent] then
		soundsByEntity[ent][sound] = nil
	end
end

-- Register functions to be called when the chip is initialised and deinitialised
SF.AddHook("initialize", function(instance)
	instance.data.sounds = {sounds = {}}
	if not plySoundBurst[instance.player] then plySoundBurst[instance.player] = plySoundBurstGen:create() end
	if not plyCount[instance.player] then plyCount[instance.player] = 0 end
end)

SF.AddHook("deinitialize", function(instance)
	for s, ent in pairs(instance.data.sounds.sounds) do
		deleteSound(instance.player, ent, s)
	end
end)

--- Creates a sound and attaches it to an entity
-- @param ent Entity to attach sound to.
-- @param path Filepath to the sound file.
-- @return Sound Object
function sound_library.create(ent, path)
	local instance = SF.instance
	checkpermission(instance, { ent, path }, "sound.create")
	if soundsLeft(instance.player)==0 then SF.Throw("Reached the sounds limit: (" .. plyMaxSounds:GetInt() .. ")", 2) end
	if not plySoundBurst[instance.player]:use(1) then SF.Throw("Can't create sounds that often", 2) end

	checktype(ent, SF.Types["Entity"])
	checkluatype (path, TYPE_STRING)

	if path:match('["?]') then
		SF.Throw("Invalid sound path: " .. path, 2)
	end

	local e = SF.UnwrapObject(ent)
	if not (e or e:IsValid()) then
		SF.Throw("Invalid Entity", 2)
	end

	local soundPatch = CreateSound(e, path)
	local snds = soundsByEntity[e]
	if not snds then snds = {} soundsByEntity[e] = snds end
	snds[soundPatch] = true
	instance.data.sounds.sounds[soundPatch] = e
	plyCount[instance.player] = plyCount[instance.player] + 1

	return wrap(soundPatch)
end


--- Returns if a sound is able to be created
-- @return If it is possible to make a sound
function sound_library.canCreate()
	return soundsLeft(SF.instance.player) ~= 0 and plySoundBurst[SF.instance.player]:check()>1
end

--- Returns the number of sounds left that can be created
-- @return The number of sounds left
function sound_library.soundsLeft()
	return soundsLeft(SF.instance.player)
end

--------------------------------------------------

--- Starts to play the sound.
function sound_methods:play()
	checkpermission(SF.instance, nil, "sound.modify")
	unwrap(self):Play()
end

--- Stops the sound from being played.
-- @param fade Time in seconds to fade out, if nil or 0 the sound stops instantly.
function sound_methods:stop(fade)
	checkpermission(SF.instance, nil, "sound.modify")
	if fade then
		checkluatype(fade, TYPE_NUMBER)
		unwrap(self):FadeOut(math.max(fade, 0))
	else
		unwrap(self):Stop()
	end
end

--- Removes the sound from the game so new one can be created if limit is reached
function sound_methods:destroy()
	local snd = unwrap(self)
	local sounds = SF.instance.data.sounds.sounds
	if snd and sounds[snd] then
		deleteSound(SF.instance.player, sounds[snd], snd)
		sounds[snd] = nil
		local sensitive2sf, sf2sensitive = SF.GetWrapperTables(sound_metamethods)
		sensitive2sf[snd] = nil
		sf2sensitive[self] = nil
		debug.setmetatable(self, nil)
	else
		SF.Throw("Tried to destroy invalid sound", 2)
	end
end

--- Sets the volume of the sound.
-- @param vol Volume to set to, between 0 and 1.
-- @param fade Time in seconds to transition to this new volume.
function sound_methods:setVolume(vol, fade)
	checkpermission(SF.instance, nil, "sound.modify")
	checkluatype(vol, TYPE_NUMBER)

	if fade then
		checkluatype (fade, TYPE_NUMBER)
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
function sound_methods:setPitch(pitch, fade)
	checkpermission(SF.instance, nil, "sound.modify")
	checkluatype(pitch, TYPE_NUMBER)

	if fade then
		checkluatype (fade, TYPE_NUMBER)
		fade = math.max(fade, 0)
	else
		fade = 0
	end

	pitch = math.Clamp(pitch, 0, 255)
	unwrap(self):ChangePitch(pitch, fade)
end

--- Returns whether the sound is being played.
function sound_methods:isPlaying()
	return unwrap(self):IsPlaying()
end

--- Sets the sound level in dB.
-- @param level dB level, see <a href='https://developer.valvesoftware.com/wiki/Soundscripts#SoundLevel'> Vale Dev Wiki</a>, for information on the value to use.
function sound_methods:setSoundLevel(level)
	checkpermission(SF.instance, nil, "sound.modify")
	checkluatype(level, TYPE_NUMBER)
	unwrap(self):SetSoundLevel(math.Clamp(level, 0, 511))
end
