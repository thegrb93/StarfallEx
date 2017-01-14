ENT.Type            = "anim"
ENT.Base            = "base_gmodentity"

ENT.PrintName       = "Starfall"
ENT.Author          = "Colonel Thirty Two"
ENT.Contact         = "initrd.gz@gmail.com"
ENT.Purpose         = ""
ENT.Instructions    = ""

ENT.Spawnable       = false
ENT.AdminSpawnable  = false

ENT.States = {
	Normal = 1,
	Error = 2,
	None = 3,
}

function ENT:runScriptHook ( hook, ... )
	if self.instance then
		return self.instance:runScriptHook( hook, ... )
	end
end

function ENT:runScriptHookForResult ( hook, ... )
	if self.instance then
		return self.instance:runScriptHookForResult( hook, ... )
	end
end

function ENT:Error ( msg, traceback )
	if type( msg ) == "table" then
		self.error = table.Copy( msg )
		self.error.message = type( self.error.message )=="string" and self.error.message or tostring( msg )
	else
		self.error = {}
		self.error.source, self.error.line, self.error.message = string.match( tostring( msg ), "%[@?SF:(%a+):(%d+)](.+)$" )

		if not self.error.source or not self.error.line or not self.error.message then
			self.error.source, self.error.line, self.error.message = nil, nil, msg
		else
			self.error.message = string.TrimLeft( self.error.message )
		end
	end
	
	if SERVER then
		self:SetNWInt( "State", self.States.Error )
		self:SetColor( Color( 255, 0, 0, 255 ) )
		self:SetDTString( 0, traceback or self.error.message )
	end
	
	SF.AddNotify( self.owner, self.error.message, "ERROR", 7, "ERROR1" )
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

	return self.error.message
end

function ENT:OnRemove ()
	if not self.instance then return end
	
	self:runScriptHook( "removed" )
	self.instance:deinitialize()
	self.instance = nil
end