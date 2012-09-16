-------------------------------------------------------------------------------
-- Chat library
-------------------------------------------------------------------------------

-- Chat functions
-- @server
local chat, _ = SF.Libraries.Register("chat")

local callbacks = {}

---------------------------------------------------------------------
-- Internal Function
---------------------------------------------------------------------

hook.Add( "PlayerSay", "starfall_chat_receive", function( ply, msg, toall )
	print("hook executed")
    local hidden
    local steamid = ply:SteamID()
    local wrapped_player = SF.Entities.Wrap(ply)
    
    local function call_handler (instance, handler)
		if instance.error then return end
		local ok, rt, traceback = instance:runFunction(handler, msg, wrapped_player)
        
        if ok and rt and ply == instance.player then
            hidden = true
        elseif not ok then
			ErrorNoHalt("SF Instance of "..instance.player:Nick().." errored: "..tostring(rt).."\n"..traceback)
			print(traceback)
			WireLib.ClientError("SF: "..tostring(rt), instance.player)
		end
    end

    for inst, tbl in pairs(callbacks) do
        for _, func in pairs(tbl.global) do
            call_handler(inst, func)
        end
        
        local player_table = tbl[steamid]
        if player_table then
	        for _, func in pairs(player_table) do
	            call_handler(inst, func)
	        end
	    end
    end
    
	return hidden and "" or nil
end)

SF.Libraries.AddHook( "deinitialize", function( instance ) 
	callbacks[instance] = nil
end
)


---------------------------------------------------------------------
-- Library functions
---------------------------------------------------------------------

--- Registers a new listener function to chat.
-- When you register to listen to this, whenever a chat message is received
-- the callback will pass (message, player).  Message of course being the
-- chat message being sent to chat, and player being the player sending it.
-- If you return true to this and it is your chat, it will hide your chat 
-- for you.
-- @param func the function that will listen to chat
-- @param ply the specific player you want to listen for
function chat.listen( func, ply )
	local instance = SF.instance
	if not callbacks[instance] then 
		callbacks[instance] = {} 
		callbacks[instance]["global"] = {}
	end
	
	ply = SF.Entities.Unwrap( ply )
	
	if type(ply) ~= "Player" and nil ~= ply then
		error("Invalid player entity passed to chat.listen", 2)
	end
	
	local cbid = ply and ply:SteamID() or "global"
	if not callbacks[instance][cbid] then
		callbacks[instance][cbid] = {}
	end
	callbacks[instance][cbid][func] = func
end

--- Removes listener from listening to chat.
-- @param func the function getting removed
-- @param ply the player that you are no longer listening to.
function chat.stop( func, ply )
	local instance = SF.instance
	
	ply = SF.Entities.Unwrap(ply)
	
	local cbid = ply and ply:SteamID() or "global"
	callback[instance][cbid][func] = nil
end