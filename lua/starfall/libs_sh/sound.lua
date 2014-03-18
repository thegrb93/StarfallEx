
--- Sound functions. Plays and manipulates sounds, optionally
-- attaching them to an entity.

local sound_library, _ = SF.Libraries.Register("sounds")

--- Sound type
local sound_methods, sound_metamethods = SF.Typedef("Sound")
local wrap, unwrap = SF.CreateWrapper(sound_metamethods,true,false)

--- Creates a sound and attaches it to an entity. You need to do sound:Play() before
-- the sound will play however.
-- @param path Filepath to the sound file
-- @param entity Entity playing the sound
-- @return The sound object. Keep this around to ensure it isn't GC'd (and thus stopped)
-- before it is done playing.
function sound_library.create(entity, path)
	SF.CheckType(path, "string")
	SF.CheckType(entity, SF.Entities.Metatable)
	if path:match('["?]') then SF.throw( "Invalid sound path: " .. path, 2 ) end
	
	entity = SF.Entities.Unwrap(entity)
	if not (entity and entity:IsValid()) then return end
	return wrap(CreateSound(entity, path))
end

--- Plays a sound from a fixed point in the world.
-- @param amplitude (Optinal) Loudness of the sound, from 0 to 255
-- @param pitch (Optional) Pitch percent, from 0 to 255
function sound_library.emitWorld(origin, path, amplitude, pitch)
	SF.CheckType(path, "string")
	SF.CheckType(origin, "Vector")
	if amplitude then
		SF.CheckType(amplitude, "number")
		amplitude = math.Clamp(amplitude, 0, 255)
	end
	if pitch then
		SF.CheckType(pitch, "number")
		pitch = math.Clamp(pitch, 0, 255)
	end
	if path:match('["?]') then SF.throw( "Invalid sound path: " .. path, 2 ) end
	
	WorldSound(path, origin, amplitude, pitch)
end

--- Plays a sound from an entity. Quick alternative to sounds.create if you don't
-- need the extra bit of control
-- @param soundlevel (Optional) The sound level. See sound:setLevel() for more info
-- @param pitch (Optional) Pitch percent, from 0 to 255
function sound_library.emitEntity(entity, path, soundlevel, pitch)
	SF.CheckType(entity, SF.Entities.Metatable)
	SF.CheckType(path, "string")
	if soundlevel then
		SF.CheckType(soundlevel, "number")
		soundlevel = math.Clamp(soundlevel, 0, 511)
	end
	if pitch then
		SF.CheckType(pitch, "number")
		pitch = math.Clamp(pitch, 0, 255)
	end
	if path:match('["?]') then SF.throw( "Invalid sound path: " .. path, 2 ) end
	
	entity = SF.Entities.Unwrap(entity)
	if not (entity and entity:IsValid()) then return end
	entity:EmitSound(path, soundlevel, pitch)
end

--- Returns the duration of the sound in seconds. Only works on .wav files,
-- and there are other issues as well.
-- @return Sound duration
function sound_library.duration(path)
	SF.CheckType(path, "string")
	return SoundDuration(path)
end

-- ------------------------------------------------------------- --

--- Plays the sound.
function sound_methods:play()
	SF.CheckType(self, sound_metamethods)
	unwrap(self):Play()
end

--- Sets the sound pitch
-- @param pitch The sound pitch as a percent from 0 to 255
-- @param delta (Optinal) The transition time between the current pitch and the new one
function sound_methods:setPitch(pitch, delta)
	SF.CheckType(self, sound_metamethods)
	SF.CheckType(pitch, "number")
	if delta then
		SF.CheckType(delta, "number")
		if delta < 0 then delta = nil end
	end
	unwrap(self):ChangePitch(math.Clamp(pitch,0,255), delta)
end

--- Sets the sound volume
-- @param vol Volume as a percent between 0 and 1
function sound_methods:setVolume(vol)
	SF.CheckType(self, sound_metamethods)
	SF.CheckType(vol, "number")
	unwrap(self):ChangeVolume(math.Clamp(vol,0,1))
end

--- Sets the sound level. This determines the sound attenuation. Only works when the sound is not playing.
-- See https://developer.valvesoftware.com/wiki/Soundscripts#SoundLevel for values and more info
-- (use decibel value from the 'code' column, not the actual enum or 'value' column).
-- @param level New level
function sound_methods:setLevel(level)
	SF.CheckType(self, sound_metamethods)
	SF.CheckType(level, "number")
	unwrap(self):SetSoundLevel(math.Clamp(level, 0, 511))
end

--- Stops or fades out the sound.
-- @param fade (Optional) Time, in seconds, to fade out the sound. Not given = stop immediately
function sound_methods:stop(fade)
	SF.CheckType(self, sound_metamethods)
	if fade then
		SF.CheckType(fade, "number")
		unwrap(self):FadeOut(math.max(fade,0))
	else
		unwrap(self):Stop()
	end
end

--- Checks if the sound is playing
-- @return True if the sound is playing
function sound_methods:isPlaying()
	SF.CheckType(self, sound_metamethods)
	return unwrap(self):isPlaying()
end
