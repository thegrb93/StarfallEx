local checkluatype = SF.CheckLuaType
local registerprivilege = SF.Permissions.registerPrivilege

-- Register privileges
registerprivilege("bass.loadFile", "Play local sound files with `bass`.", "Allows users to create sound channels by file path.", { client = {} })
registerprivilege("bass.loadURL", "Play remote sound files with `bass`.", "Allows users to create sound channels by URL.", { client = {}, urlwhitelist = {} })
registerprivilege("bass.play2D", "Play sounds in global game context with `bass`.", "Allows users to create sound channels which play in global game context (without `3d` flag).", { client = { default = 1 } })

local plyCount = SF.LimitObject("bass", "bass sounds", 20, "The number of sounds allowed to be playing via Starfall client at once")

SF.ResourceCounters.Bass = {icon = "icon16/sound_add.png", count = function(ply) return plyCount:get(ply).val end}

local function deleteSound(ply, sound)
	if sound:IsValid() then sound:Stop() end
	plyCount:free(ply, 1)
end

--- `bass` library is intended to be used only on client side. It's good for streaming local and remote sound files and playing them directly in player's "2D" context.
-- @name bass
-- @class library
-- @libtbl bass_library
SF.RegisterLibrary("bass")

--- For playing music there is `Bass` type. You can pause and set current playback time in it. If you're looking to apply DSP effects on present game sounds, use `Sound` instead.
-- @name Bass
-- @class type
-- @libtbl bass_methods
SF.RegisterType("Bass", true, false)


return function(instance)
local checkpermission = instance.player ~= SF.Superuser and SF.Permissions.check or function() end

-- Register functions to be called when the chip is initialised and deinitialised
local sounds = {}
instance:AddHook("deinitialize", function()
	for s in pairs(sounds) do
		deleteSound(instance.player, s)
	end
end)


local bass_library = instance.Libraries.bass
local bass_methods, bass_meta, wrap, unwrap = instance.Types.Bass.Methods, instance.Types.Bass, instance.Types.Bass.Wrap, instance.Types.Bass.Unwrap
local vec_meta, vwrap, vunwrap = instance.Types.Vector, instance.Types.Vector.Wrap, instance.Types.Vector.Unwrap

local function getsnd(self)
	local snd = unwrap(self)
	local isValid = snd.IsValid
	return isValid and isValid(snd) and snd or SF.Throw("Sound is not valid.", 3)
end


local function not3D(flags)
	for flag in string.gmatch(string.lower(flags), "%S+") do if flag=="3d" then return false end end
	if SF.IsHUDActive(instance.entity) then return false end
	return true
end

--- Loads a sound channel from a file.
-- @param string path File path to play from.
-- @param string flags Flags for the sound (`3d`, `mono`, `noplay`, `noblock`).
-- @param function callback Function which is called when the sound channel is loaded. It'll get 3 arguments: `Bass` object, error number and name.
function bass_library.loadFile(path, flags, callback)
	checkpermission(instance, nil, "bass.loadFile")

	checkluatype(path, TYPE_STRING)
	checkluatype(flags, TYPE_STRING)
	checkluatype(callback, TYPE_FUNCTION)

	if path:match('["?]') then
		SF.Throw("Invalid sound path: " .. path, 2)
	end

	if not3D(flags) then
		checkpermission(instance, nil, "bass.play2D")
	end

	plyCount:use(instance.player, 1)

	sound.PlayFile(path, flags, function(snd, er, name)
		if er then
			instance:runFunction(callback, nil, er, name)
			plyCount:free(instance.player, 1)
		else
			if instance.error then
				snd:Stop()
				plyCount:free(instance.player, 1)
			else
				sounds[snd] = true
				instance:runFunction(callback, wrap(snd), 0, "")
			end
		end
	end)
end

--- Loads a sound channel from an URL.
-- @param string path URL path to play from.
-- @param string flags Flags for the sound (`3d`, `mono`, `noplay`, `noblock`). noblock will fail if the webserver doesn't provide file length.
-- @param function callback Function which is called when the sound channel is loaded. It'll get 3 arguments: `Bass` object, error number and name.
function bass_library.loadURL(path, flags, callback)
	checkpermission(instance, path, "bass.loadURL")

	checkluatype(path, TYPE_STRING)
	checkluatype(flags, TYPE_STRING)
	checkluatype(callback, TYPE_FUNCTION)

	if #path > 2000 then SF.Throw("URL is too long!", 2) end
	if not3D(flags) then
		checkpermission(instance, nil, "bass.play2D")
	end

	plyCount:use(instance.player, 1)

	SF.HTTPNotify(instance.player, path)
	sound.PlayURL(path, flags, function(snd, er, name)
		if er then
			instance:runFunction(callback, nil, er, name)
			plyCount:free(instance.player, 1)
		else
			if instance.error then
				snd:Stop()
				plyCount:free(instance.player, 1)
			else
				sounds[snd] = true
				instance:runFunction(callback, wrap(snd), 0, "")
			end
		end
	end)
end

--- Returns the number of sounds left that can be created
-- @return number The number of sounds left
function bass_library.soundsLeft()
	return plyCount:check(instance.player)
end

--------------------------------------------------

--- Starts to play the sound.
function bass_methods:play()
	getsnd(self):Play()
end

--- Stops playing the sound and destroys it. Use pause instead if you don't want it destroyed
function bass_methods:stop()
	local snd = getsnd(self)
	deleteSound(instance.player, snd)
	sounds[snd] = nil

	-- This makes the sound no longer unwrap
	local sensitive2sf, sf2sensitive = bass_meta.sensitive2sf, bass_meta.sf2sensitive
	sensitive2sf[snd] = nil
	sf2sensitive[self] = nil
end

--- Pauses the sound.
function bass_methods:pause()
	getsnd(self):Pause()
end

--- Sets the volume of the sound channel.
-- @param number vol Volume multiplier (1 is normal), between 0x and 10x.
function bass_methods:setVolume(vol)
	checkluatype(vol, TYPE_NUMBER)
	getsnd(self):SetVolume(math.Clamp(vol, 0, 10))
end

--- Sets the pitch of the sound channel.
-- @param number pitch Pitch to set to. (0-100) 1 is normal pitch.
function bass_methods:setPitch(pitch)
	checkluatype(pitch, TYPE_NUMBER)
	getsnd(self):SetPlaybackRate(math.Clamp(pitch, 0, 100))
end

--- Sets the position of the sound in 3D space. Must have `3d` flag to get this work on.
-- @param Vector pos Where to position the sound.
function bass_methods:setPos(pos)
	getsnd(self):SetPos(vunwrap(pos))
end

--- Sets the fade distance of the sound in 3D space. Must have `3d` flag to get this work on.
-- @param number min The channel's volume is at maximum when the listener is within this distance (50-1000)
-- @param number max The channel's volume stops decreasing when the listener is beyond this distance. (10,000-200,000)
function bass_methods:setFade(min, max)
	getsnd(self):Set3DFadeDistance(math.Clamp(min, 50, 1000), math.Clamp(max, 10000, 200000))
end

--- Sets whether the sound channel should loop. Requires the 'noblock' flag
-- @param boolean loop Whether the sound channel should loop.
function bass_methods:setLooping(loop)
	getsnd(self):EnableLooping(loop)
end

--- Gets the length of a sound channel.
-- @return number Sound channel length in seconds.
function bass_methods:getLength()
	return getsnd(self):GetLength()
end

--- Sets the current playback time of the sound channel. Requires the 'noblock' flag
-- @param number time Sound channel playback time in seconds.
-- @param boolean? dontDecode Skip decoding to set time, which is much faster but less accurate. True by default.
function bass_methods:setTime(time, dontDecode)
	checkluatype(time, TYPE_NUMBER)
	getsnd(self):SetTime(time, dontDecode ~= false)
end

--- Gets the current playback time of the sound channel. Requires the 'noblock' flag
-- @return number Sound channel playback time in seconds.
function bass_methods:getTime()
	return getsnd(self):GetTime()
end

--- Perform fast Fourier transform algorithm to compute the DFT of the sound channel.
-- @param number n Number of consecutive audio samples, between 0 and 7. Depending on this parameter you will get 256*2^n samples.
-- @return table Table containing DFT magnitudes, each between 0 and 1.
function bass_methods:getFFT(n)
	local arr = {}
	getsnd(self):FFT(arr, n)
	return arr
end

--- Gets whether the sound channel is streamed online.
-- @return boolean Boolean of whether the sound channel is streamed online.
function bass_methods:isOnline()
	return getsnd(self):IsOnline()
end

--- Gets whether the bass is valid.
-- @return boolean Boolean of whether the bass is valid.
function bass_methods:isValid()
	local uw = unwrap(self)
	local isValid = uw.IsValid
	return isValid and isValid(uw) or false
end

--- Gets the left and right levels of the audio channel
-- @return number The left sound level, a value between 0 and 1.
-- @return number The right sound level, a value between 0 and 1.
function bass_methods:getLevels()
	return getsnd(self):GetLevel()
end

--- Gets the relative volume between the left and right audio channels.
-- @return number The pan. -1 to 1 for relative left to right
function bass_methods:getPan()
	return getsnd(self):GetPan()
end

--- Sets the relative volume of the left and right channels.
-- @param number Relative integer volume between the left and right channels. Values must be -1 to 1 for relative left to right
function bass_methods:setPan(pan)
	checkluatype(pan, TYPE_NUMBER)

	local uw = getsnd(self)
	-- If we ever use / add Set3DEnabled to SF, remember to change this Is3D to Get3DEnabled
	if uw:Is3D() then SF.Throw("You cannot set the pan of a 3D Bass Object!", 2) end
	uw:SetPan( pan )
end

--- Retrieves the number of bits per sample of the sound channel.
-- Doesn't work for mp3 and ogg files.
-- @return number Floating point number of bits per sample, or 0 if unknown.
function bass_methods:getBitsPerSample()
	return getsnd(self):GetBitsPerSample()
end

--- Returns the average bit rate of the sound channel.
-- @return number The average bit rate of the sound channel.
function bass_methods:getAverageBitRate()
	return getsnd(self):GetAverageBitRate()
end

end
