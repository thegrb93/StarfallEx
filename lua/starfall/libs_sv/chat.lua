---------------------------------------------------------------------
-- SF chat parsing library
-- @author Daranable
---------------------------------------------------------------------
-- @server
local chat, _ = SF.Libraries.Register("chat") 

local callbacks = {}

---------------------------------------------------------------------
-- Internal Function
---------------------------------------------------------------------

hook.Add( "PlayerSay", "starfall_chat_receive", function( ply, msg, toall )
    local hidden
    local steamid = ply:SteamID()
    local wrapped_player = SF.Entities.Wrap(ply)
    
    local function call_handler (instance, handler)
        local success, hide = pcall(
                instance.runFunction,
                instance,
                handler,
                msg,
                wrapped_player
        )
        
        if success and hide and ply == instance.player then
            hidden = true
        end
    end

    for instance, tbl in pairs(callbacks) do
        for _, func in pairs(tbl.global) do
            call_handler( instance, handler )
        end
        for _, func in pairs(tbl[steamid]) do
            call_handler( instance, handler )
        end
    end
    
    if hidden then
        return ""
    else
        return msg
    end
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
	
	if not ply then
		callbacks[instance]["global"][func] = func
	else
		local steamid = ply:SteamID()
		if not callbacks[instance][steamid] then
			callbacks[instance][steamid] = {}
		end
		
		callbacks[instance][steamid][func] = func
	end
end

--- Removes listener from listening to chat.
-- @param func the function getting removed
-- @param ply the player that you are no longer listening to.
function chat.stop( func, ply )
	local instance = SF.instance
	if not ply then
		callback[instance]["global"][func] = nil
	else
		local steamid = SF.Entities.Unwrap(ply):SteamID()
		callback[instance][steamid][func] = nil
	end
end