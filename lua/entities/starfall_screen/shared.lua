ENT.Type            = "anim"
ENT.Base            = "base_gmodentity"

ENT.PrintName       = "Starfall Screen"
ENT.Author          = "Colonel Thirty Two"
ENT.Contact         = "initrd.gz@gmail.com"
ENT.Purpose         = ""
ENT.Instructions    = ""

ENT.Spawnable       = false


function ENT:LinkEnt(ent, transmit)
	local changed = self.link ~= ent
	if changed then
		local oldlink = self.link
		self.link = ent

		if oldlink and oldlink:IsValid() then
			local instance = oldlink.instance
			if instance then
				instance:runScriptHook("componentunlinked", instance.WrapObject(self))
			end
		end
		if ent and ent:IsValid() then
			local instance = ent.instance
			if instance then
				instance:runScriptHook("componentlinked", instance.WrapObject(self))
			end
		end
	end
	if SERVER and (changed or transmit) then
		net.Start("starfall_processor_link")
		net.WriteUInt(self:EntIndex(), 16)
		net.WriteUInt(ent and ent:IsValid() and ent:EntIndex() or 0, 16)
		if transmit then net.Send(transmit) else net.Broadcast() end
	end
end
