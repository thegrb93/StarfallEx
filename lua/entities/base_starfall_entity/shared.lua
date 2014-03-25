DEFINE_BASECLASS( "base_gmodentity" )
ENT.Type            = "anim"
ENT.Base            = "base_gmodentity"

ENT.Author          = "Radon"
ENT.Contact         = ""
ENT.Purpose         = ""
ENT.Instructions    = ""

ENT.Spawnable       = false
ENT.AdminSpawnable  = false

function ENT:Error ( msg, traceback )
	if type( msg ) == "table" then
		if msg.message then
			local line= msg.line
			local file = msg.file

			msg = ( file and ( file .. ":" ) or "" ) .. ( line and ( line .. ": " ) or "" ) .. msg.message
		end
	end
	msg = tostring( msg )
	if SERVER then
		ErrorNoHalt( "Processor of " .. self.owner:Nick() .. " errored: " .. msg .. "\n" )
	end

	SF.AddNotify( self.owner, msg, NOTIFY_ERROR, 7, NOTIFYSOUND_ERROR1 )
	if self.instance then
		self.instance:deinitialize()
		self.instance = nil
	end

	if traceback then
		if SERVER then
			SF.Print( self.owner, traceback )
		else
			print( traceback )
		end
	end

	return msg
end
