local checkluatype = SF.CheckLuaType
local registerprivilege = SF.Permissions.registerPrivilege
local math_sqrt = math.sqrt

-- Register privileges
registerprivilege("bass.loadFile", "Play local sound files with `bass`.", "Allows users to create sound channels by file path.", { client = {} })
registerprivilege("bass.loadURL", "Play remote sound files with `bass`.", "Allows users to create sound channels by URL.", { client = {}, urlwhitelist = {} })
registerprivilege("bass.play2D", "Play sounds in global game context with `bass`.", "Allows users to create sound channels which play in global game context (without `3d` flag).", { client = { default = 5 } })

local plyCount = SF.LimitObject("bass", "bass sounds", 20, "The number of sounds allowed to be playing via Starfall client at once")
SF.ResourceCounters.Bass = {icon = "icon16/sound_add.png", count = function(ply) return plyCount:get(ply) end}

local bassSounds = {} -- { [IGModAudioChannel] = baseSound, ... } -- Contains extra data for each starfall sound.
local bassSimpleFadeSounds = {} -- { [IGModAudioChannel] = baseSound, ... } -- A list of sounds that need to be manually controlled through 'simple fading'.

--- Returns a bass sound with custom fading capability
local bassSound = {
	__index = {
		calcFade = function(self)
			local fadeMult
			local distSqr = self.sound:GetPos():DistToSqr(EyePos())
			if distSqr <= self.fadeMin * self.fadeMin then
				fadeMult = 1
			elseif distSqr >= self.fadeMax * self.fadeMax then
				fadeMult = 0
			else
				-- Sounds falls off with dist^2. Unfortunately, we still have to do the square root inbetween.
				fadeMult = ((self.fadeMax - math_sqrt(distSqr)) / (self.fadeMax - self.fadeMin)) ^ 2
			end
		
			if self.fadeMult ~= fadeMult then
				self.fadeMult = fadeMult
				self.sound:SetVolume(self.targetVolume * fadeMult)
			end
		end,

		setFade = function(self, min, max, useSimpleFading)
			if useSimpleFading then
				self.fadeMin = math.Clamp(min, 50, 1000)
				self.fadeMax = math.Clamp(max, min, 20000)

				if self.simpleFade ~= useSimpleFading then
					self.simpleFade = useSimpleFading
					local snd = self.sound
					snd:Set3DFadeDistance(200, 200)
					self.fadeMult = -1 -- Force the SetVolume in calcFade
					self:calcFade()
					self:addSoundToSimpleFade()
				end
			else
				self.fadeMin = math.Clamp(min, 50, 1000)
				self.fadeMax = math.Clamp(max, 5000, 200000)

				if self.simpleFade ~= useSimpleFading then
					self.simpleFade = useSimpleFading
					local snd = self.sound
					snd:Set3DFadeDistance(self.fadeMin, self.fadeMax)
					snd:SetVolume(self.targetVolume) -- Remove manual fading, reset to target volume.
					self:removeSoundFromSimpleFade()
				end
			end
		end,

		addSoundToSimpleFade = function(self)
			if next(bassSimpleFadeSounds)==nil then
				hook.Add("Think", "SF_Bass_SimpleFade", self.think)
			end
			bassSimpleFadeSounds[self.sound] = self
		end,

		removeSoundFromSimpleFade = function(self)
			bassSimpleFadeSounds[self.sound] = nil
			if next(bassSimpleFadeSounds)==nil then
				hook.Remove("Think", "SF_Bass_SimpleFade")
			end
		end,

		think = function()
			for snd, sndData in pairs(bassSimpleFadeSounds) do
				if snd:IsValid() then
					if snd:GetState() == GMOD_CHANNEL_PLAYING then
						sndData:calcFade()
					end
				else
					sndData:removeSoundFromSimpleFade()
				end
			end
		end,
	},

	__call = function(p, sound, flags, is3D)
		local newsound = setmetatable({
			sound = sound,
			flags = flags,
			is3D = is3D,
			simpleFade = false,
			targetVolume = 1,
			fadeMult = 1,
			fadeMin = 200,
			fadeMax = 5000,
		}, p)

		if is3D then
			newsound:setFade(200, 5000, true)
		end

		return newsound
	end,
}
setmetatable(bassSound, bassSound)

local function deleteSound(ply, snd)
	if snd:IsValid() then snd:Stop() end

	local sndData = bassSounds[snd]
	if sndData then
		bassSounds[snd] = nil
		plyCount:free(ply, 1)
	end
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

local bass_library = instance.Libraries.bass
local bass_methods, bass_meta, wrap, unwrap = instance.Types.Bass.Methods, instance.Types.Bass, instance.Types.Bass.Wrap, instance.Types.Bass.Unwrap
local vec_meta, vwrap, vunwrap = instance.Types.Vector, instance.Types.Vector.Wrap, instance.Types.Vector.Unwrap

local instanceSounds = {} -- A lookup table of sounds created by this instance.

local vunwrap1
instance:AddHook("initialize", function()
	vunwrap1 = vec_meta.QuickUnwrap1
end)
instance:AddHook("deinitialize", function()
	for snd in pairs(instanceSounds) do
		deleteSound(instance.player, snd)
	end
end)

local function getsnd(self)
	local snd = unwrap(self)
	if snd:IsValid() then
		return snd
	else
		SF.Throw("Sound is not valid.", 3)
	end
end

local function not3D(flags)
	for flag in string.gmatch(string.lower(flags), "%S+") do if flag=="3d" then return false end end
	return true
end

local function loadSound(path, flags, callback, loadFunc)
	local is2D = not3D(flags)

	if is2D then
		checkpermission(instance, nil, "bass.play2D")
	end

	plyCount:use(instance.player, 1)

	loadFunc(path, flags, function(snd, er, name)
		if er then
			instance:runFunction(callback, nil, er, name)
			plyCount:free(instance.player, 1)
		else
			if instance.error then
				snd:Stop()
				plyCount:free(instance.player, 1)
			else
				instanceSounds[snd] = true
				bassSounds[snd] = bassSound(snd, flags, not is2D)
				instance:runFunction(callback, wrap(snd), 0, "")
			end
		end
	end)
end


--- Loads a sound as a Bass object from a file.
-- 2D sounds require a HUD connection.
-- @param string path File path to play from.
-- @param string flags Flags for the sound (`3d`, `mono`, `noplay`, `noblock`).
-- @param function callback Function which is called when the sound is loaded. It'll get 3 arguments: `Bass` object, error number and name.
function bass_library.loadFile(path, flags, callback)
	checkpermission(instance, nil, "bass.loadFile")

	checkluatype(path, TYPE_STRING)
	checkluatype(flags, TYPE_STRING)
	checkluatype(callback, TYPE_FUNCTION)

	if #path>260 then SF.Throw("Sound path too long!") end
	if string.match(path, "[\"?]") then SF.Throw("Sound path contains invalid characters!") end

	loadSound(path, flags, callback, sound.PlayFile)
end

--- Loads a sound as a Bass object from a URL.
-- 2D sounds require a HUD connection.
-- @param string path URL path to play from.
-- @param string flags Flags for the sound (`3d`, `mono`, `noplay`, `noblock`). noblock will fail if the webserver doesn't provide file length.
-- @param function callback Function which is called when the sound is loaded. It'll get 3 arguments: `Bass` object, error number and name.
function bass_library.loadURL(path, flags, callback)
	checkpermission(instance, path, "bass.loadURL")

	checkluatype(path, TYPE_STRING)
	checkluatype(flags, TYPE_STRING)
	checkluatype(callback, TYPE_FUNCTION)

	if #path > 2000 then SF.Throw("URL is too long!", 2) end

	loadSound(path, flags, callback, sound.PlayURL)
	SF.HTTPNotify(instance.player, path)
end

--- Returns the number of sounds left that can be created.
-- @return number The number of sounds left.
function bass_library.soundsLeft()
	return plyCount:check(instance.player)
end

--------------------------------------------------

--- Starts to play the sound.
function bass_methods:play()
	getsnd(self):Play()
end

--- Stops playing the sound and destroys it. Use pause instead if you don't want it destroyed.
function bass_methods:stop()
	local snd = getsnd(self)
	deleteSound(instance.player, snd)
	instanceSounds[snd] = nil
end

--- Pauses the sound.
function bass_methods:pause()
	getsnd(self):Pause()
end

--- Sets the volume of the sound.
-- @param number vol Volume multiplier (1 is normal), between 0x and 10x.
function bass_methods:setVolume(vol)
	checkluatype(vol, TYPE_NUMBER)

	local snd = getsnd(self)
	local sndData = bassSounds[snd]

	vol = math.Clamp(vol, 0, 10)
	sndData.targetVolume = vol

	if sndData.simpleFade then
		snd:SetVolume(vol * sndData.fadeMult)
	else
		snd:SetVolume(vol)
	end
end

--- Gets the base volume of the sound.
-- This is the volume before distance fading is applied on 3D sounds.
-- @return number Volume multiplier (1 is normal), between 0x and 10x.
function bass_methods:getVolume()
	return bassSounds[getsnd(self)].targetVolume
end

--- Gets the distance-based fade multiplier of the sound.
-- Bass:getVolume() * Bass:getFadeMultiplier() is the effective volume of the sound.
-- Always 1 for 2D sounds.
-- Always 1 for 3D sounds that don't use simple fading. See Bass:setFade().
-- Only updates once per frame while the sound is playing.
-- @return number Volume fade multiplier (1 is normal), between 0x and 10x.
function bass_methods:getFadeMultiplier()
	return bassSounds[getsnd(self)].fadeMult
end

--- Sets the pitch of the sound.
-- @param number pitch Pitch to set to. (0-100) 1 is normal pitch.
function bass_methods:setPitch(pitch)
	checkluatype(pitch, TYPE_NUMBER)
	getsnd(self):SetPlaybackRate(math.Clamp(pitch, 0, 100))
end

--- Gets the pitch of the sound.
-- @return number The current pitch of the sound.
function bass_methods:getPitch()
	return getsnd(self):GetPlaybackRate()
end

--- Sets the position of the sound in 3D space. Must have `3d` flag for this to have any effect.
-- @param Vector pos Where to position the sound.
function bass_methods:setPos(pos)
	getsnd(self):SetPos(vunwrap1(pos))
end

--- Gets the position of the sound in 3D space.
-- @return Vector The position of the sound.
function bass_methods:getPos()
	return vwrap(getsnd(self):GetPos())
end

--- Sets the fade distance of the sound in 3D space. Must have `3d` flag for this to have any effect.
-- For both fading styles, the sound will be at full volume (the value of :setVolume()) at distances between 0 and min.
-- If simple fading is enabled, the sound will fade towards 0 until the max distance is reached, becoming inaudible.
-- If simple fading is disabled, the sound will start to fade, then lock its volume once max distance is reached. It will almost always be faintly heard.
-- @param number min The distance where the sound starts to fade. (50-1,000)
-- @param number max The maximal distance, as described above. (min-20,000 for simple fading, 5,000-200,000 for non-simple fading)
-- @param boolean? useSimpleFading Whether to use simple fading for this sound. True by default.
function bass_methods:setFade(min, max, useSimpleFading)
	checkluatype(min, TYPE_NUMBER)
	checkluatype(max, TYPE_NUMBER)
	if useSimpleFading ~= nil then checkluatype(useSimpleFading, TYPE_BOOL) else useSimpleFading = true end

	local soundData = bassSounds[getsnd(self)]
	if not soundData.is3D then SF.Throw("Can't set the fade of 2D sounds", 2) end

	soundData:setFade(min, max, useSimpleFading)
end

--- Gets the fade distance of the sound in 3D space. 
-- @return number The distance before the sound starts to fade.
-- @return number The distance before the sound stops fading.
-- @return boolean Whether or not this sound uses simple fading.
function bass_methods:getFade()
	local sndData = bassSounds[getsnd(self)]

	return sndData.fadeMin, sndData.fadeMax, sndData.simpleFade
end

--- Sets whether the sound should loop. Requires the 'noblock' flag.
-- @param boolean loop Whether the sound should loop.
function bass_methods:setLooping(loop)
	getsnd(self):EnableLooping(loop)
end

--- Gets whether the sound loops.
-- @return boolean Whether the sound loops.
function bass_methods:isLooping()
	return getsnd(self):IsLooping()
end

--- Gets the length of a sound.
-- @return number Sound length in seconds.
function bass_methods:getLength()
	return getsnd(self):GetLength()
end

--- Sets the current playback time of the sound. Requires the 'noblock' flag.
-- @param number time Sound playback time in seconds.
-- @param boolean? dontDecode Skip decoding to set time, which is much faster but less accurate. True by default.
function bass_methods:setTime(time, dontDecode)
	checkluatype(time, TYPE_NUMBER)
	getsnd(self):SetTime(time, dontDecode ~= false)
end

--- Gets the current playback time of the sound. Requires the 'noblock' flag.
-- @return number Sound playback time in seconds.
function bass_methods:getTime()
	return getsnd(self):GetTime()
end

--- Returns the filename for the sound channel.
-- @return string The file name. This will not be always what you have put into the Bass:loadURL() as first argument.
function bass_methods:getFileName()
	return getsnd(self):GetFileName()
end

--- Perform fast Fourier transform algorithm to compute the DFT of the sound.
-- @param number n Number of consecutive audio samples, between 0 and 7. Depending on this parameter you will get 256*2^n samples.
-- @return table Table containing DFT magnitudes, each between 0 and 1.
function bass_methods:getFFT(n)
	local arr = {}
	getsnd(self):FFT(arr, n)
	return arr
end

--- Returns whether the audio stream is block streamed or not.
-- @return boolean Is the audio stream block streamed or not.
function bass_methods:isBlockStreamed()
	local uw = getsnd(self)
	if not uw:IsOnline() then SF.Throw("The Bass Object isn't playing an online audio stream!", 2) end
	return uw:IsBlockStreamed()
end

--- Gets whether the sound is streamed online.
-- @return boolean Boolean of whether the sound is streamed online.
function bass_methods:isOnline()
	return getsnd(self):IsOnline()
end

--- Gets whether the bass is valid.
-- @return boolean Boolean of whether the bass is valid.
function bass_methods:isValid()
	return unwrap(self):IsValid()
end

--- Gets the left and right audio channel levels.
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
-- @param number pan Relative integer volume between the left and right channels. Values must be -1 to 1 for relative left to right.
function bass_methods:setPan(pan)
	checkluatype(pan, TYPE_NUMBER)

	local uw = getsnd(self)
	-- If we ever use / add Set3DEnabled to SF, remember to change this Is3D to Get3DEnabled.
	if uw:Is3D() then SF.Throw("You cannot set the pan of a 3D Bass Object!", 2) end
	uw:SetPan( pan )
end

--- Retrieves the number of bits per sample of the sound.
-- Doesn't work for mp3 and ogg files.
-- @return number Floating point number of bits per sample, or 0 if unknown.
function bass_methods:getBitsPerSample()
	return getsnd(self):GetBitsPerSample()
end

--- Returns the average bit rate of the sound.
-- @return number The average bit rate of the sound.
function bass_methods:getAverageBitRate()
	return getsnd(self):GetAverageBitRate()
end

--- Returns the buffered time of the sound channel in seconds, for online streaming sound channels (Bass:loadURL()). For offline channels this will be equivalent to Bass:getLength().
-- @return number The current buffered time of the stream, in seconds.
function bass_methods:getBufferedTime()
	local uw = getsnd(self)
	if uw:IsOnline() then
		return uw:GetBufferedTime()
	else return uw:GetLength() end
end

--- Returns the sample rate for currently playing sound.
-- @return number The sample rate in Hz. This should always be 44100.
function bass_methods:getSamplingRate()
	return getsnd(self):GetSamplingRate()
end

--- Retrieves HTTP headers from a bass stream channel created by Bass:loadURL(), if available.
--- Of special interest here are headers such as icy-name, icy-br, ice-audio-info, icy-genre.
--- CRITICAL NOTE: Tags aren't available immediately! Must use a timer to wait 100-500ms for BASS to parse metadata during stream init!!
-- @return table A list of HTTP headers or nil if no information is available.
function bass_methods:getTagsHTTP()
	return getsnd(self):GetTagsHTTP()
end

--- Retrieves the ID3 version 1 info from a bass channel created by Bass:loadFile or Bass:loadURL, if available. ID3v2 is not supported.
--- CRITICAL NOTE: Tags aren't available immediately! Must use a timer to wait 100-500ms for BASS to parse metadata during stream init!!
-- @return table A table containing the information, or nil if no information is available.
-- (The table will always have the following keys, filled out based on what is available: "album", "artist", "comment", "genre", "id", "title", "year")
function bass_methods:getTagsID3()
	return getsnd(self):GetTagsID3()
end

--- Retrieves ICY metadata from a bass stream channel created by Bass:loadURL, if available.
--- CRITICAL NOTE: Tags aren't available immediately! Must use a timer to wait 100-500ms for BASS to parse metadata during stream init!!
-- @return string The meta information, or nil if no information is available.
function bass_methods:getTagsMeta()
	return getsnd(self):GetTagsMeta()
end

--- Retrieves .m4a media info, from a bass channel created by Bass:loadFile or Bass:loadURL, if available.
--- CRITICAL NOTE: Tags aren't available immediately! Must use a timer to wait 100-500ms for BASS to parse metadata during stream init!!
-- @return table A list of available information in no particular order, or nil if no information is available.
function bass_methods:getTagsMP4()
	return getsnd(self):GetTagsMP4()
end

--- Retrieves OGG media info tag, from a bass channel created by Bass:loadFile or Bass:loadURL, if available.
--- CRITICAL NOTE: Tags aren't available immediately! Must use a timer to wait 100-500ms for BASS to parse metadata during stream init!!
-- @return table A list of available information in no particular order, or nil if no information is available. 
function bass_methods:getTagsOGG()
	return getsnd(self):GetTagsOGG()
end

--- Retrieves OGG Vendor tag, usually containing the application that created the file, from a bass channel created by Bass:loadFile or Bass:loadURL, if available.
--- CRITICAL NOTE: Tags aren't available immediately! Must use a timer to wait 100-500ms for BASS to parse metadata during stream init!!
-- @return string The OGG vendor tag, or nil if no information is available.
function bass_methods:getTagsVendor()
	return getsnd(self):GetTagsVendor()
end

--- Retrieves .WMA media info, from a bass channel created by Bass:loadFile or Bass:loadURL, if available.
--- CRITICAL NOTE: Tags aren't available immediately! Must use a timer to wait 100-500ms for BASS to parse metadata during stream init!!
-- @return table A list of available information in no particular order, or nil if no information is available.
function bass_methods:getTagsWMA()
	return getsnd(self):GetTagsWMA()
end

--- Returns the flags used to create the sound.
-- @return string The flags of the sound (`3d`, `mono`, `noplay`, `noblock`).
function bass_methods:getFlags()
	return bassSounds[getsnd(self)].flags
end

--- Returns whether or not the sound is 2D.
-- @return boolean True if the sound is 2D.
function bass_methods:is2D()
	return not getsnd(self):Is3D()
end

--- Returns whether or not the sound is 3D.
-- @return boolean True if the sound is 3D.
function bass_methods:is3D()
	return getsnd(self):Is3D()
end

--- Sets the 3D mode of the channel. This will affect Bass:get3DEnabled() but not Bass:is3D().
--- This feature requires the channel to be initially created in 3D mode, i.e. Bass:is3D() should return true or this function will do nothing. 
-- @param boolean enable True or False to toggle 3D.
function bass_methods:set3DEnabled(enable)
	checkluatype(enable, TYPE_BOOLEAN)

	local uw = getsnd(self)
	if not uw:Is3D() then SF.Throw("You cannot set the mode of a Bass Object that isn't 3D! Please call is3D first!!", 2) end
	uw:Set3DEnabled(enable)
end

--- Returns if the sound channel is currently in 3D mode or not. This value will be affected by Bass:set3DEnabled().
-- @return boolean True or False depending on if the sound is currently 3D or not.
function bass_methods:get3DEnabled()
	return getsnd(self):Get3DEnabled()
end

--- Returns the state of the sound.
-- @return number The state enum of the sound. https://wiki.facepunch.com/gmod/Enums/GMOD_CHANNEL
function bass_methods:getState()
	return getsnd(self):GetState()
end

--- Returns whether or not the sound is stopped.
-- Only true if the `noplay` flag is used and Bass:play() hasn't been called yet, since Bass:stop() will destroy the sound channel.
-- @return boolean True if the sound is stopped.
function bass_methods:isStopped()
	return getsnd(self):GetState() == GMOD_CHANNEL_STOPPED
end

--- Returns whether or not the sound is playing.
-- @return boolean True if the sound is playing.
function bass_methods:isPlaying()
	return getsnd(self):GetState() == GMOD_CHANNEL_PLAYING
end

--- Returns whether or not the sound is paused.
-- @return boolean True if the sound is paused.
function bass_methods:isPaused()
	return getsnd(self):GetState() == GMOD_CHANNEL_PAUSED
end

--- Returns whether or not the sound is stalled.
-- @return boolean True if the sound is stalled.
function bass_methods:isStalled()
	return getsnd(self):GetState() == GMOD_CHANNEL_STALLED
end

--- Sets 3D cone of the sound channel.
-- @param number innerAngle The angle of the inside projection cone in degrees. Range is from 0 (no cone) to 360 (sphere), -1 = leave current.
-- @param number outerAngle The angle of the outside projection cone in degrees. Range is from 0 (no cone) to 360 (sphere), -1 = leave current.
-- @param number outerVolume The delta-volume outside the outer projection cone. Range is from 0 (silent) to 1 (same as inside the cone), less than 0 = leave current.
function bass_methods:set3DCone(innerAngle, outerAngle, outerVolume)
	checkluatype(innerAngle, TYPE_NUMBER)
	checkluatype(outerAngle, TYPE_NUMBER)
	checkluatype(outerVolume, TYPE_NUMBER)

	local uw = getsnd(self)
	-- If we ever use / add Set3DEnabled to SF, remember to change this Is3D to Get3DEnabled.
	if not uw:Is3D() then SF.Throw("You cannot set the cone of a Bass Object that isn't 3D!", 2) end
	uw:Set3DCone( innerAngle, outerAngle, outerVolume )
end

--- Returns 3D cone of the sound channel.
-- @return number The angle of the inside projection cone in degrees.
-- @return number The angle of the outside projection cone in degrees.
-- @return number The delta-volume outside the outer projection cone.
function bass_methods:get3DCone()
	return getsnd(self):Get3DCone()
end

end
