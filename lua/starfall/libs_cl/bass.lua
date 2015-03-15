SF.Bass = {}

--- Bass type
-- @shared
local bass_methods, sound_metamethods = SF.Typedef( "Bass" )
local wrap, unwrap = SF.CreateWrapper( sound_metamethods, true, false, debug.getregistry().IGModAudioChannel )

--- Bass library.
-- @shared
local bass_library, _ = SF.Libraries.Register( "bass" )

SF.Bass.Wrap = wrap
SF.Bass.Unwrap = unwrap
SF.Bass.Methods = bass_methods
SF.Bass.Metatable = sound_metamethods


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
		unwrap( s ):Stop()
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
	if not SF.Permissions.check( SF.instance.player, unwrap( self ), "sound.modify" ) then SF.throw( "Insufficient permissions", 2 ) end
	SF.CheckType( self, sound_metamethods )
	unwrap( self ):Play()
end

--- Stops the sound from being played.
-- @param fade Time in seconds to fade out, if nil or 0 the sound stops instantly.
function bass_methods:stop ( )
	if not SF.Permissions.check( SF.instance.player, unwrap( self ), "sound.modify" ) then SF.throw( "Insufficient permissions", 2 ) end
	unwrap( self ):Stop()
end

--- Sets the volume of the sound.
-- @param vol Volume to set to, between 0 and 1.
-- @param dt Time in seconds to transition to this new volume.
function bass_methods:setVolume ( vol )
	if not SF.Permissions.check( SF.instance.player, unwrap( self ), "sound.modify" ) then SF.throw( "Insufficient permissions", 2 ) end
	SF.CheckType( vol, "number" )

	vol = math.Clamp( vol, 0, 1 )
	unwrap( self ):SetVolume( vol )
end

--- Sets the pitch of the sound.
-- @param pitch Pitch to set to, between 0 and 255.
-- @param dt Time in seconds to transition to this new pitch.
function bass_methods:setPitch ( pitch )
	if not SF.Permissions.check( SF.instance.player, unwrap( self ), "sound.modify" ) then SF.throw( "Insufficient permissions", 2 ) end
	SF.CheckType( pitch, "number" )

	pitch = math.Clamp( pitch, 0, 3 )
	unwrap( self ):SetPlaybackRate( pitch )
end

--- Sets the position of the sound
-- @param position
function bass_methods:setPos ( pos )
	if not SF.Permissions.check( SF.instance.player, unwrap( self ), "sound.modify" ) then SF.throw( "Insufficient permissions", 2 ) end
	SF.CheckType( pos, SF.Types[ "Vector" ] )

	unwrap( self ):SetPos( SF.UnwrapObject( pos ) )
end


