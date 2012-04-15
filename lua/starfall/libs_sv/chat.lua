---------------------------------------------------------------------
-- SF chat parsing library
-- @author Daranable
---------------------------------------------------------------------
-- @server
local chat, _ = SF.Libraries.Register("chat") 

local cb_instances = {}

cb_instances.global = SF.Callback.new()

---------------------------------------------------------------------
-- Internal Function
---------------------------------------------------------------------

hook.Add( "PlayerSay", "starfall_chat_receive", function( ply, msg, toall )
	local hidden
	for _, func in pairs(cb_instances.global.listeners) do
		local success, hide = pcall( func, msg, ply )
		local instance = func("STARFALL_GET_INSTANCE")
		
		if not success then MsgN(hide) end
		
		if hide and ply == instance.player then
			hidden = true
		end
	end
	
	if hidden then 
		return "" 
	else
		return msg
	end
end)

SF.Libraries.AddHook( "deinitialize", function( instance ) 
	for _, v in pairs( instance.data.publicfuncs ) do
		cb_instances.global:removeListener( v )
	end
end
)


---------------------------------------------------------------------
-- Library functions
---------------------------------------------------------------------

--- Registers a new listener function to chat
-- @param func the function that will listen to chat
function chat.listen( func )
	cb_instances.global:addListener( SF.WrapFunction(func) )
end

--- Removes listener from listening to chat
-- @param func the function getting removed
function chat.stop( func )
	cb_instances.global:removeListener( SF.WrapFunction(func) )
end