SF.Bass = {}

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
	if not SF.Permissions.check( SF.instance.player, { ent, path }, "sound.create" ) then SF.throw( "Insufficient permissions", 2 ) end

	SF.CheckType( path, "string" )
	SF.CheckType( flags, "string" )
	SF.CheckType( callback, "function" )

	if path:match( '["?]' ) then
		SF.throw( "Invalid sound path: " .. path, 2 )
	end
	
	local instance = SF.instance

	sound.PlayFile( path, flags, function(snd, er, name)
		SF.instance = instance
		if er then
			callback( nil, er, name )
		else
			instance.data.bass.sounds[ snd ] = true
			callback( wrap( snd ), nil, nil )
		end
		SF.instance = nil
	end)
end

--- Loads a sound object from a url
-- @param path url to the sound file.
-- @param flags that will control the sound
-- @param callback to run when the sound is loaded
function bass_library.loadURL ( path, flags, callback )
	if not SF.Permissions.check( SF.instance.player, { ent, path }, "sound.create" ) then SF.throw( "Insufficient permissions", 2 ) end

	SF.CheckType( path, "string" )
	SF.CheckType( flags, "string" )
	SF.CheckType( callback, "function" )

	local instance = SF.instance
	
	sound.PlayURL( path, flags, function(snd, er, name)
		SF.instance = instance
		if er then
			callback( nil, er, name )
		else
			instance.data.bass.sounds[ snd ] = true
			callback( wrap( snd ), nil, nil )
		end
		SF.instance = nil
	end)
end

--------------------------------------------------

--- Starts to play the sound.
function bass_methods:play ()
	local uw = unwrap( self )
	SF.CheckType( self, bass_metamethods )
		
	if not SF.Permissions.check( SF.instance.player, uw, "sound.modify" ) then SF.throw( "Insufficient permissions", 2 ) end
	
	if IsValid(uw) then
		uw:Play()
	end
end

--- Stops playing the sound.
function bass_methods:stop ( )
	local uw =  unwrap( self )
	SF.CheckType( self, bass_metamethods )
		
	if not SF.Permissions.check( SF.instance.player, uw, "sound.modify" ) then SF.throw( "Insufficient permissions", 2 ) end
	
	if IsValid(uw) then
		uw:Stop()
	end
end

--- Sets the volume of the sound.
-- @param vol Volume to set to, between 0 and 1.
function bass_methods:setVolume ( vol )
	local uw = unwrap( self )
	SF.CheckType( self, bass_metamethods )
	SF.CheckType( vol, "number" )
		
	if not SF.Permissions.check( SF.instance.player, uw, "sound.modify" ) then SF.throw( "Insufficient permissions", 2 ) end

	if IsValid(uw) then
		uw:SetVolume( math.Clamp( vol, 0, 1 ) )
	end
end

--- Sets the pitch of the sound.
-- @param pitch Pitch to set to, between 0 and 3.
function bass_methods:setPitch ( pitch )
	local uw = unwrap( self )
	SF.CheckType( self, bass_metamethods )
	SF.CheckType( pitch, "number" )
		
	if not SF.Permissions.check( SF.instance.player, uw, "sound.modify" ) then SF.throw( "Insufficient permissions", 2 ) end

	if IsValid(uw) then
		uw:SetPlaybackRate( math.Clamp( pitch, 0, 3 ) )
	end
end

--- Sets the position of the sound
-- @param pos Where to position the sound
function bass_methods:setPos ( pos )
	local uw = unwrap( self )
	SF.CheckType( self, bass_metamethods )
	SF.CheckType( pos, SF.Types[ "Vector" ] )
		
	if not SF.Permissions.check( SF.instance.player, uw, "sound.modify" ) then SF.throw( "Insufficient permissions", 2 ) end

	if IsValid(uw) then
		uw:SetPos( SF.UnwrapObject( pos ) )
	end
end


