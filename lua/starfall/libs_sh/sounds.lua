SF.Sounds = {}

--- Sound type
-- @shared
local sound_methods, sound_metamethods = SF.Typedef( "Sound" )
local wrap, unwrap = SF.CreateWrapper( sound_metamethods, true, false, debug.getregistry().CSoundPatch )

--- Sounds library.
-- @shared
local sound_library, _ = SF.Libraries.Register( "sounds" )

SF.Sounds.Wrap = wrap
SF.Sounds.Unwrap = unwrap
SF.Sounds.Methods = sound_methods
SF.Sounds.Metatable = sound_metamethods

-- Register Privileges
do
	local P = SF.Permissions
	P.registerPrivilege( "sound.create", "Sound", "Allows the user to create sounds" )
	P.registerPrivilege( "sound.modify", "Sound", "Allows the user to modify created sounds" )
end

-- Register functions to be called when the chip is initialised and deinitialised
SF.Libraries.AddHook( "initialize", function ( inst )
	inst.data.sounds = {
		sounds = {}
	}
end )

SF.Libraries.AddHook( "deinitialize", function ( inst )
	local sounds = inst.data.sounds.sounds
	local s = next( sounds )
	while s do
		unwrap( s ):Stop()
		sounds[ s ] = nil
		s = next( sounds )
	end
end )

--- Creates a sound and attaches it to an entity
-- @param ent Entity to attach sound to.
-- @param path Filepath to the sound file.
-- @return Sound Object
function sound_library.create ( ent, path )
	if not SF.Permissions.check( SF.instance.player, { ent, path }, "sound.create" ) then SF.throw( "Insufficient permissions", 2 ) end

	SF.CheckType( ent, SF.Types[ "Entity" ] )
	SF.CheckType( path, "string" )

	if path:match( '["?]' ) then
		SF.throw( "Invalid sound path: " .. path, 2 )
	end

	local e = SF.UnwrapObject( ent )
	if not ( e or e:IsValid() ) then
		SF.throw( "Invalid Entity", 2 )
	end

	local s = wrap( CreateSound( e, path ) )
	local i = SF.instance.data.sounds.sounds
	i[ s ] = s

	return i[ s ]
end

--------------------------------------------------

--- Starts to play the sound.
function sound_methods:play ()
	if not SF.Permissions.check( SF.instance.player, unwrap( self ), "sound.modify" ) then SF.throw( "Insufficient permissions", 2 ) end
	SF.CheckType( self, sound_metamethods )
	unwrap( self ):Play()
end

--- Stops the sound from being played.
-- @param fade Time in seconds to fade out, if nil or 0 the sound stops instantly.
function sound_methods:stop ( dt )
	if not SF.Permissions.check( SF.instance.player, unwrap( self ), "sound.modify" ) then SF.throw( "Insufficient permissions", 2 ) end
	if dt then
		SF.CheckType( dt, "number" )
		unwrap( self ):FadeOut( math.max( dt, 0 ) )
	else
		unwrap( self ):Stop()
	end
end

--- Sets the volume of the sound.
-- @param vol Volume to set to, between 0 and 1.
-- @param dt Time in seconds to transition to this new volume.
function sound_methods:setVolume ( vol, dt )
	if not SF.Permissions.check( SF.instance.player, unwrap( self ), "sound.modify" ) then SF.throw( "Insufficient permissions", 2 ) end
	SF.CheckType( vol, "number" )

	if dt then
		SF.CheckType( dt, "number" )
		dt = math.abs( dt, 0 )
	else	
		dt = 0
	end

	vol = math.Clamp( vol, 0, 1 )
	unwrap( self ):ChangeVolume( vol, dt )
end

--- Sets the pitch of the sound.
-- @param pitch Pitch to set to, between 0 and 255.
-- @param dt Time in seconds to transition to this new pitch.
function sound_methods:setPitch ( pitch, dt )
	if not SF.Permissions.check( SF.instance.player, unwrap( self ), "sound.modify" ) then SF.throw( "Insufficient permissions", 2 ) end
	SF.CheckType( pitch, "number" )
	
	if dt then
		SF.CheckType( dt, "number" )
		dt = math.max( dt, 0 )
	else	
		dt = 0
	end

	pitch = math.Clamp( pitch, 0, 255 )
	unwrap( self ):ChangePitch( pitch, dt )
end

--- Returns whether the sound is being played.
function sound_methods:isPlaying ()
	return unwrap( self ):IsPlaying()	
end

--- Sets the sound level in dB.
-- @param level dB level, see <a href='https://developer.valvesoftware.com/wiki/Soundscripts#SoundLevel'> Vale Dev Wiki</a>, for information on the value to use.
function sound_methods:setSoundLevel ( level )
	if not SF.Permissions.check( SF.instance.player, unwrap( self ), "sound.modify" ) then SF.throw( "Insufficient permissions", 2 ) end
	SF.CheckType( level, "number" )
	unwrap( self ):SetSoundLevel( math.Clamp( level, 0, 511 ) )
end
