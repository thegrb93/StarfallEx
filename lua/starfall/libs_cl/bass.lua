SF.Bass = {}

-- Register privileges
do
	local P = SF.Permissions
	P.registerPrivilege("bass.loadFile", "Play local sound files with `bass`.", "Allows users to create sound channels by file path.", { client = {} })
	P.registerPrivilege("bass.loadURL", "Play remote sound files with `bass`.", "Allows users to create sound channels by URL.", { client = {}, urlwhitelist = {} })
	P.registerPrivilege("bass.play2D", "Play sounds in global game context with `bass`.", "Allows users to create sound channels which play in global game context (without `3d` flag).", { client = { default = 1 } })

end

--- For playing music there is `Bass` type. You can pause and set current playback time in it. If you're looking to apply DSP effects on present game sounds, use `Sound` instead.
-- @client
local bass_methods, bass_metamethods = SF.RegisterType("Bass")
local wrap, unwrap = SF.CreateWrapper(bass_metamethods, true, false, debug.getregistry().IGModAudioChannel)
local checktype = SF.CheckType
local checkluatype = SF.CheckLuaType
local checkpermission = SF.Permissions.check

--- `bass` library is intended to be used only on client side. It's good for streaming local and remote sound files and playing them directly in player's "2D" context.
-- @client
local bass_library = SF.RegisterLibrary("bass")

SF.Bass.Wrap = wrap
SF.Bass.Unwrap = unwrap
SF.Bass.Methods = bass_methods
SF.Bass.Metatable = bass_metamethods


-- Register functions to be called when the chip is initialised and deinitialised
SF.AddHook("initialize", function (inst)
	inst.data.bass = {
		sounds = {}
	}
end)

SF.AddHook("deinitialize", function (inst)
	local sounds = inst.data.bass.sounds
	local s = next(sounds)
	while s do
		if s:IsValid() then
			s:Stop()
		end
		sounds[s] = nil
		s = next(sounds)
	end
end)

local function not3D(flags)
	for flag in string.gmatch(string.lower(flags), "%S+") do if flag=="3d" then return false end end
	return true
end

--- Loads a sound channel from a file.
-- @param path File path to play from.
-- @param flags Flags for the sound (`3d`, `mono`, `noplay`, `noblock`).
-- @param callback Function which is called when the sound channel is loaded. It'll get 3 arguments: `Bass` object, error number and name.
function bass_library.loadFile (path, flags, callback)
	checkpermission(SF.instance, nil, "bass.loadFile")

	checkluatype(path, TYPE_STRING)
	checkluatype(flags, TYPE_STRING)
	checkluatype(callback, TYPE_FUNCTION)

	if path:match('["?]') then
		SF.Throw("Invalid sound path: " .. path, 2)
	end

	local instance = SF.instance
	if not3D(flags) then
		checkpermission(instance, nil, "bass.play2D")
	end

	sound.PlayFile(path, flags, function(snd, er, name)
		if er then
			instance:runFunction(callback, nil, er, name)
		else
			if instance.error then
				snd:Stop()
			else
				instance.data.bass.sounds[snd] = true
				instance:runFunction(callback, wrap(snd), 0, "")
			end
		end
	end)
end

--- Loads a sound channel from an URL.
-- @param path URL path to play from.
-- @param flags Flags for the sound (`3d`, `mono`, `noplay`, `noblock`).
-- @param callback Function which is called when the sound channel is loaded. It'll get 3 arguments: `Bass` object, error number and name.
function bass_library.loadURL (path, flags, callback)
	checkpermission(SF.instance, path, "bass.loadURL")

	checkluatype(path, TYPE_STRING)
	checkluatype(flags, TYPE_STRING)
	checkluatype(callback, TYPE_FUNCTION)

	local instance = SF.instance
	if #path > 2000 then SF.Throw("URL is too long!", 2) end
	if not3D(flags) then
		checkpermission(instance, nil, "bass.play2D")
	end

	SF.HTTPNotify(instance.player, path)

	sound.PlayURL(path, flags, function(snd, er, name)
		if er then
			instance:runFunction(callback, nil, er, name)
		else
			if instance.error then
				snd:Stop()
			else
				instance.data.bass.sounds[snd] = true
				instance:runFunction(callback, wrap(snd), 0, "")
			end
		end
	end)
end

--------------------------------------------------

--- Starts to play the sound.
function bass_methods:play ()
	checktype(self, bass_metamethods)
	local uw = unwrap(self)

	checkpermission(SF.instance, nil, "sound.modify")

	if IsValid(uw) then
		uw:Play()
	end
end

--- Stops playing the sound.
function bass_methods:stop ()
	checktype(self, bass_metamethods)
	local uw =  unwrap(self)

	checkpermission(SF.instance, nil, "sound.modify")

	if IsValid(uw) then
		uw:Stop()
	end
end

--- Pauses the sound.
function bass_methods:pause ()
	checktype(self, bass_metamethods)
	local uw =  unwrap(self)

	checkpermission(SF.instance, nil, "sound.modify")

	if IsValid(uw) then
		uw:Pause()
	end
end

--- Sets the volume of the sound channel.
-- @param vol Volume to set to, between 0 and 1.
function bass_methods:setVolume (vol)
	checktype(self, bass_metamethods)
	checkluatype(vol, TYPE_NUMBER)
	local uw = unwrap(self)

	checkpermission(SF.instance, nil, "sound.modify")

	if IsValid(uw) then
		uw:SetVolume(math.Clamp(vol, 0, 1))
	end
end

--- Sets the pitch of the sound channel.
-- @param pitch Pitch to set to, between 0 and 3.
function bass_methods:setPitch (pitch)
	checktype(self, bass_metamethods)
	checkluatype(pitch, TYPE_NUMBER)
	local uw = unwrap(self)

	checkpermission(SF.instance, nil, "sound.modify")

	if IsValid(uw) then
		uw:SetPlaybackRate(math.Clamp(pitch, 0, 3))
	end
end

--- Sets the position of the sound in 3D space. Must have `3d` flag to get this work on.
-- @param pos Where to position the sound.
function bass_methods:setPos (pos)
	checktype(self, bass_metamethods)
	checktype(pos, SF.Types["Vector"])
	local uw = unwrap(self)

	checkpermission(SF.instance, nil, "sound.modify")

	if IsValid(uw) then
		uw:SetPos(SF.UnwrapObject(pos))
	end
end

--- Sets the fade distance of the sound in 3D space. Must have `3d` flag to get this work on.
-- @param min The channel's volume is at maximum when the listener is within this distance
-- @param max The channel's volume stops decreasing when the listener is beyond this distance.
function bass_methods:setFade (min, max)
	checktype(self, bass_metamethods)
	local uw = unwrap(self)

	checkpermission(SF.instance, nil, "sound.modify")

	if IsValid(uw) then
		uw:Set3DFadeDistance(math.Clamp(min, 50, 1000), math.Clamp(max, 10000, 200000))
	end
end

--- Sets whether the sound channel should loop.
-- @param loop Boolean of whether the sound channel should loop.
function bass_methods:setLooping (loop)
	checktype(self, bass_metamethods)
	local uw = unwrap(self)

	checkpermission(SF.instance, nil, "sound.modify")

	if IsValid(uw) then
		uw:EnableLooping(loop)
	end
end

--- Gets the length of a sound channel.
-- @return Sound channel length in seconds.
function bass_methods:getLength ()
	checktype(self, bass_metamethods)
	local uw = unwrap(self)

	checkpermission(SF.instance, nil, "sound.modify")

	if IsValid(uw) then
		return uw:GetLength()
	end
end

--- Sets the current playback time of the sound channel.
-- @param time Sound channel playback time in seconds.
function bass_methods:setTime (time)
	checktype(self, bass_metamethods)
	checkluatype(time, TYPE_NUMBER)
	local uw = unwrap(self)

	checkpermission(SF.instance, nil, "sound.modify")

	if IsValid(uw) then
		uw:SetTime(time)
	end
end

--- Gets the current playback time of the sound channel.
-- @return Sound channel playback time in seconds.
function bass_methods:getTime ()
	checktype(self, bass_metamethods)
	local uw = unwrap(self)

	checkpermission(SF.instance, nil, "sound.modify")

	if IsValid(uw) then
		return uw:GetTime()
	end
end

--- Perform fast Fourier transform algorithm to compute the DFT of the sound channel.
-- @param n Number of consecutive audio samples, between 0 and 7. Depending on this parameter you will get 256*2^n samples.
-- @return Table containing DFT magnitudes, each between 0 and 1.
function bass_methods:getFFT (n)
	checktype(self, bass_metamethods)
	local uw = unwrap(self)

	checkpermission(SF.instance, nil, "sound.modify")

	if IsValid(uw) then
		local arr = {}
		uw:FFT(arr, n)
		return arr
	end
end

--- Gets whether the sound channel is streamed online.
-- @return Boolean of whether the sound channel is streamed online.
function bass_methods:isOnline()
	checktype(self, bass_metamethods)
	local uw = unwrap(self)

	checkpermission(SF.instance, nil, "sound.modify")

	if IsValid(uw) then
		return uw:IsOnline()
	end

	return false
end

--- Gets whether the bass is valid.
-- @return Boolean of whether the bass is valid.
function bass_methods:isValid()
	checktype(self, bass_metamethods)
	local uw = unwrap(self)

	return IsValid(uw)
end
