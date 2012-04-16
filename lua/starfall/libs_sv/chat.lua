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
	for instance, tbl in pairs(callbacks) do
		for _, func in pairs(tbl) do
			local wrapped_player = SF.Entities.Wrap(ply)
			local success, hide = pcall( 
					instance.runFunction,
					instance,
					func, 
					msg, 
					wrapped_player 
			)
			
			if hide and ply == instance.player then
				hidden = true
			end
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
-- @param func the function that will listen to chat
function chat.listen( func )
	local instance = SF.instance
	if not callbacks[instance] then callbacks[instance] = {} end
	
	callbacks[SF.instance][func] = func
end

--- Removes listener from listening to chat.
-- @param func the function getting removed
function chat.stop( func )
	callback[SF.instance][func] = nil
end