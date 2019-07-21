include("shared.lua")
ENT.RenderGroup = RENDERGROUP_BOTH

ENT.DefaultMaterial = Material( "models/wireframe" )
ENT.Material = ENT.DefaultMaterial

function ENT:Initialize()
	self.rendermesh = Mesh(self.Material)
end

function ENT:Draw()
	self:DrawModel()
end

function ENT:GetRenderMesh()
	return { Mesh = self.rendermesh, Material = self.Material--[[, Matrix = self.render_matrix]] }
end

net.Receive("starfall_custom_prop", function()
	local index = net.ReadUInt(16)
	local self

	local function getEnt(e)
		if e:IsValid() and e:GetClass()=="starfall_prop" then
			self = e
			return true
		end
		return false
	end

	local function findEnt(f)
		local timeout = CurTime()+5
		local name = "SF_CustomPropUpdate"..index
		hook.Add("Think", name, function()
			if getEnt(Entity(index)) then
				f()
				hook.Remove("Think", name)
			elseif CurTime()>timeout then
				hook.Remove("Think", name)
			end
		end)
	end
	findEnt(function() end)

	local function applyData(data)
		local stream = SF.StringStream(data)
		local mesh = {}
		local mins, maxs = Vector(math.huge, math.huge, math.huge), Vector(-math.huge, -math.huge, -math.huge)
		for i=1, stream:readUInt32() do
			for j=1, stream:readUInt32() do
				local x, y, z = stream:readFloat(), stream:readFloat(), stream:readFloat()
				if x>maxs.x then maxs.x = x end
				if y>maxs.y then maxs.y = y end
				if z>maxs.z then maxs.z = z end
				if x<mins.x then mins.x = x end
				if y<mins.y then mins.y = y end
				if z<mins.z then mins.z = z end
				mesh[#mesh+1] = {pos = Vector(x,y,z)}
			end
		end
		self.rendermesh:BuildFromTriangles(mesh)
		self:SetRenderBounds(mins, maxs)
	end

	net.ReadStream(nil, function(data)
		if data then
			if self then
				if self:IsValid() then
					applyData(data)
				end
			else
				findEnt(function() applyData(data) end)
			end
		end
	end)
end)
