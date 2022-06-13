--@name Basic Bone Manipulation
--@author Name
--@shared

-- USAGE:
-- Place the chip on the ground, G-Man NPC will be spawned, networked to the clients and it's bones modified

if SERVER then -- Only execute code in this block on the `serverside`
	
	-- Spawn a G-Man NPC at the chip's world position
	local ent = prop.createSent(chip():getPos(), Angle(), "npc_gman")
	
	-- Wait for each client before starting and sending a network message
	hook.add("ClientInitialized", "", function(ply)
		net.start("npc") -- Initialize a new network message called `npc`
		net.writeEntity(ent) -- Attach our entity to the net message
		net.send(ply) -- Send the message only to the player which has already loaded the script on their client
	end)
	
else -- Only execute the code in this block on the `clientside`
	
	-- Catch the 'npc' network message sent to the current client from the server
	net.receive("npc", function()
		net.readEntity(function(ent) -- Use one of Starfall's coolest features, a callback that runs when the entity becomes valid on our client
			if not ent then return end -- This can still obviously not return anything in rare circumstances, but this check alone is sufficient
			
			local head_bone = ent:lookupBone("ValveBiped.Bip01_Head1") -- Grab the head bone (read: https://wiki.facepunch.com/gmod/ValveBiped_Bones)
			ent:manipulateBoneScale(head_bone, Vector(3)) -- Scale the head bone 3 times ( Vector(3) being short for Vector(3,3,3) )
			
			-- Loop through all entity bones, note that bones start at index 0
			for i = 0, ent:getBoneCount() - 1 do
				ent:manipulateBoneJiggle(i, true) -- Make them jiggly wiggly :)
			end
			
		end)
	end)
	
end
