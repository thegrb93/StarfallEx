include('shared.lua')

ENT.RenderGroup = RENDERGROUP_OPAQUE

include("starfall/SFLib.lua")
assert(SF, "Starfall didn't load correctly!")

local context = SF.CreateContext(nil, nil, nil, nil, SF.Libraries.CreateLocalTbl{"render"})
datastream.Hook("sf_screen_download",function(handler, id, encoded, decoded)
	for i=1,#decoded do
		data = decoded[i]
		local ent = data.ent
		if not ent or ent:GetClass() ~= "gmod_wire_starfall_screen" then
			ErrorNoHalt("SF Screen data sent to wrong entity: "..tostring(ent))
			return
		end
		
		ent:CodeSent(data.files, data.main, data.owner)
	end
end)

usermessage.Hook( "starfall_screen_used", function ( data )
	local screen = Entity( data:ReadShort() )
	local activator = Entity( data:ReadShort() )
	
	screen:runScriptHook( "starfall_used", SF.Entities.Wrap( activator ) )
	
	-- Error message copying
	if screen.error then
		SetClipboardText(string.format("%q", screen.error.orig))
	end
end)

function ENT:Initialize()
	self.GPU = GPULib.WireGPU(self)
end

function ENT:Think()
	self.BaseClass.Think(self)
	self:NextThink(CurTime())
	
	if self.instance and not self.instance.error then
		self.instance:resetOps()
		self:runScriptHook("think")
	end
end

function ENT:OnRemove()
	self.GPU:Finalize()
	if self.instance then
		self.instance:deinitialize()
	end
end

function ENT:Error(msg)
	-- Notice owner
	WireLib.AddNotify(self.owner, msg, NOTIFY_ERROR, 7, NOTIFYSOUND_ERROR1)
	
	-- Process error message
	self.error = {}
	self.error.orig = msg
	self.error.source, self.error.line, self.error.msg = string.match(msg, "%[@?SF:(%a+):(%d+)](.+)$")

	if not self.error.source or not self.error.line or not self.error.msg then
		self.error.source, self.error.line, self.error.msg = nil, nil, msg
	else
		self.error.msg = string.TrimLeft(self.error.msg)
	end
	
	if self.instance then
		self.instance:deinitialize()
		self.instance = nil
	end
	
	self:SetOverlayText("Starfall Screen\nInactive (Error)")
end

function ENT:CodeSent(files, main, owner)
	if self.instance then self.instance:deinitialize() end
	self.owner = owner
	local ok, instance = SF.Compiler.Compile(files,context,main,owner,{ent=self,render={}})
	if not ok then self:Error(instance) return end
	
	self.instance = instance
	instance.data.entity = self
	instance.data.render.gpu = self.GPU
	instance.data.render.matricies = 0
	local ok, msg = instance:initialize()
	if not ok then self:Error(msg) end
	
	local data = instance.data
	
	function self.renderfunc()
		if self.instance then
			data.render.isRendering = true
			self:runScriptHook("render")
			data.render.isRendering = nil
			
		elseif self.error then
			surface.SetTexture(0)
			surface.SetDrawColor(0, 0, 0, 120)
			surface.DrawRect(0, 0, 512, 512)
			
			surface.CreateFont("arial", 26, 200, true, false, "Starfall_ErrorFont")
			draw.DrawText("Error occurred in Starfall Screen:", "Starfall_ErrorFont", 32, 16, Color(0, 255, 255, 255)) -- Cyan
			draw.DrawText(tostring(self.error.msg), "Starfall_ErrorFont", 16, 80, Color(255, 0, 0, 255))
			if self.error.source and self.error.line then
				draw.DrawText("Line: "..tostring(self.error.line), "Starfall_ErrorFont", 16, 512-16*7, Color(255, 255, 255, 255))
				draw.DrawText("Source: "..self.error.source, "Starfall_ErrorFont", 16, 512-16*5, Color(255, 255, 255, 255))
			end
			draw.DrawText("Press USE to copy to your clipboard", "Starfall_ErrorFont", 512 - 16*25, 512-16*2, Color(255, 255, 255, 255))
			self.renderfunc = nil
		end
	end
end

function ENT:Draw()
	self:DrawModel()
	Wire_Render(self)
	
	if self.renderfunc then
		self.GPU:RenderToGPU(self.renderfunc)
	end
	
	self.GPU:Render()
end
