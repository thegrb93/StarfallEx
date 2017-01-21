SF.Bass = {}

-- Register privileges
do
	local P = SF.Permissions
	P.registerPrivilege( "bass.loadFile", "Play sound files with bass", "Allows users to create sound objects that use the bass library.", {"Client"} )
	P.registerPrivilege( "bass.loadURL", "Play web sound files with bass", "Allows users to create sound objects that use the bass library.", {"Client"} )
end

--- Bass type
-- @client
local bass_methods, bass_metamethods = SF.Typedef( "Bass" )
local wrap, unwrap = SF.CreateWrapper( bass_metamethods, true, false, debug.getregistry().IGModAudioChannel )

--- Bass library.
-- @client
local bass_library, _ = SF.Libraries.Register( "bass" )

SF.Bass.Wrap = wrap
SF.Bass.Unwrap = unwrap
SF.Bass.Methods = bass_methods
SF.Bass.Metatable = bass_metamethods


-- Register functions to be called when the chip is initialised and deinitialised
SF.Libraries.AddHook( "initialize", function ( inst )
	inst.data.bass = {
		sounds = {}
	}
end )

SF.Libraries.AddHook( "deinitialize", function ( inst )
	local sounds = inst.data.bass.sounds
	local s = next( sounds )
	while s do
		if s:IsValid() then
			s:Stop()
		end
		sounds[ s ] = nil
		s = next( sounds )
	end
end )

--- Loads a sound object from a file
-- @param path Filepath to the sound file.
-- @param flags that will control the sound
-- @param callback to run when the sound is loaded
function bass_library.loadFile ( path, flags, callback )
	SF.Permissions.check( SF.instance.player, { ent, path }, "bass.loadFile" )

	SF.CheckType( path, "string" )
	SF.CheckType( flags, "string" )
	SF.CheckType( callback, "function" )

	if path:match( '["?]' ) then
		SF.throw( "Invalid sound path: " .. path, 2 )
	end
	
	local instance = SF.instance

	sound.PlayFile( path, flags, function(snd, er, name)
		if er then
			instance:runFunction( callback, nil, er, name )
		else
			if instance.error then
				snd:Stop()
			else
				instance.data.bass.sounds[ snd ] = true
				instance:runFunction( callback, wrap( snd ), 0, "" )
			end
		end
	end)
end

--- Loads a sound object from a url
-- @param path url to the sound file.
-- @param flags that will control the sound
-- @param callback to run when the sound is loaded
function bass_library.loadURL ( path, flags, callback )
	SF.Permissions.check( SF.instance.player, { ent, path }, "bass.loadURL" )

	SF.CheckType( path, "string" )
	SF.CheckType( flags, "string" )
	SF.CheckType( callback, "function" )

	local instance = SF.instance

	sound.PlayURL( path, flags, function(snd, er, name)
		if er then
			instance:runFunction( callback, nil, er, name )
		else
			if instance.error then
				snd:Stop()
			else
				instance.data.bass.sounds[ snd ] = true
				instance:runFunction( callback, wrap( snd ), 0, "" )
			end
		end
	end)
end

--------------------------------------------------

--- Starts to play the sound.
function bass_methods:play ()
	SF.CheckType( self, bass_metamethods )
	local uw = unwrap( self )
		
	SF.Permissions.check( SF.instance.player, uw, "sound.modify" )
	
	if IsValid(uw) then
		uw:Play()
	end
end

--- Stops playing the sound.
function bass_methods:stop ( )
	SF.CheckType( self, bass_metamethods )
	local uw =  unwrap( self )
		
	SF.Permissions.check( SF.instance.player, uw, "sound.modify" )
	
	if IsValid(uw) then
		uw:Stop()
	end
end

--- Sets the volume of the sound.
-- @param vol Volume to set to, between 0 and 1.
function bass_methods:setVolume ( vol )
	SF.CheckType( self, bass_metamethods )
	SF.CheckType( vol, "number" )
	local uw = unwrap( self )
		
	SF.Permissions.check( SF.instance.player, uw, "sound.modify" )

	if IsValid(uw) then
		uw:SetVolume( math.Clamp( vol, 0, 1 ) )
	end
end

--- Sets the pitch of the sound.
-- @param pitch Pitch to set to, between 0 and 3.
function bass_methods:setPitch ( pitch )
	SF.CheckType( self, bass_metamethods )
	SF.CheckType( pitch, "number" )
	local uw = unwrap( self )
		
	SF.Permissions.check( SF.instance.player, uw, "sound.modify" )

	if IsValid(uw) then
		uw:SetPlaybackRate( math.Clamp( pitch, 0, 3 ) )
	end
end

--- Sets the position of the sound
-- @param pos Where to position the sound
function bass_methods:setPos ( pos )
	SF.CheckType( self, bass_metamethods )
	SF.CheckType( pos, SF.Types[ "Vector" ] )
	local uw = unwrap( self )
		
	SF.Permissions.check( SF.instance.player, uw, "sound.modify" )

	if IsValid(uw) then
		uw:SetPos( SF.UnwrapObject( pos ) )
	end
end

--- Sets the fade distance of the sound
-- @param min The channel's volume is at maximum when the listener is within this distance
-- @param max The channel's volume stops decreasing when the listener is beyond this distance.
function bass_methods:setFade ( min, max )
	SF.CheckType( self, bass_metamethods )
	local uw = unwrap( self )
		
	SF.Permissions.check( SF.instance.player, uw, "sound.modify" )

	if IsValid(uw) then
		uw:Set3DFadeDistance( math.Clamp(min,50,1000), math.Clamp(max,10000,200000) )
	end
end

--- Sets if the sound should loop or not.
-- @param loop Boolean if the sound should loop or not.
function bass_methods:setLooping ( loop )
	SF.CheckType( self, bass_metamethods )
	local uw = unwrap( self )
		
	SF.Permissions.check( SF.instance.player, uw, "sound.modify" )

	if IsValid(uw) then
		uw:EnableLooping( loop )
	end
end

--- Gets the length of a sound
-- @return Length in seconds of the sound
function bass_methods:getLength ()
	SF.CheckType( self, bass_metamethods )
	local uw = unwrap( self )
		
	SF.Permissions.check( SF.instance.player, uw, "sound.modify" )

	if IsValid(uw) then
		return uw:GetLength()
	end
end

--- Sets the current time of a sound
-- @param time Time to set a sound in seconds
function bass_methods:setTime ( time )
	SF.CheckType( self, bass_metamethods )
	SF.CheckType( time, "number" )
	local uw = unwrap( self )
		
	SF.Permissions.check( SF.instance.player, uw, "sound.modify" )

	if IsValid(uw) then
		uw:SetTime( time )
	end
end

--- Gets the current time of a sound
-- @return Current time in seconds of the sound
function bass_methods:getTime ()
	SF.CheckType( self, bass_metamethods )
	local uw = unwrap( self )
		
	SF.Permissions.check( SF.instance.player, uw, "sound.modify" )

	if IsValid(uw) then
		return uw:GetTime()
	end
end

--- Gets the FFT of a sound
-- @param n Sample size of the hamming window. Must be power of 2
-- @return FFT table of the sound
function bass_methods:getFFT ( n )
	SF.CheckType( self, bass_metamethods )
	local uw = unwrap( self )
		
	SF.Permissions.check( SF.instance.player, uw, "sound.modify" )

	if IsValid(uw) then
		local arr = {}
		uw:FFT( arr, n )
		return arr
	end
end


