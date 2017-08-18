--- VGUI library. Used to create derma interfaces.
-- @client
local vgui_library, _ = SF.Libraries.Register( "vgui" )

--- Panel type
-- Note that methods are generated from the panel object itself, use the garrysmod wiki documentation on panels to find them.
-- @client
-- @externaldocs http://wiki.garrysmod.com/page/Category:Panel
local _, PanelMeta = SF.Typedef("Panel")
SF.CreateWrapper( PanelMeta, true, true, debug.getregistry().Panel )

local WrapObject = SF.WrapObject
local UnwrapObject = SF.UnwrapObject

local BlockedKeys = {
	SetAllowLua = true
}

function PanelMeta:__index( key )
	key = tostring( key ):gsub( "^%l", string.upper )
	
	if BlockedKeys[key] then return nil end
	
	local instance = SF.instance
	local this = UnwrapObject( self )
	local v = this[ key ]
	
	if type( v ) == "function" then
		return function( _, ... )
			args = SF.Unsanitize( {...} )
			ret = { v( this, unpack( args ) ) }
			return unpack( SF.Sanitize( ret ) )
		end
	else
		return WrapObject( v )
	end
end

function PanelMeta:__newindex( key, value )
	key = tostring( key ):gsub( "^%l", string.upper )
	
	if BlockedKeys[key] then return nil end
	
	local instance = SF.instance
	local this = UnwrapObject( self )
	
	if type( value ) == "function" then
		this[ key ] = function( ... )
			local args = SF.Sanitize( { ... } )
			local oldInstance = SF.instance
			SF.instance = instance
			
			if key == "paint" then
				SF.instance.data.render.isRendering = true
			end
			
			local ret = {value( unpack( args ) )}
			
			if key == "paint" then
				SF.instance.data.render.isRendering = false
			end
			
			SF.instance = oldInstance
			
			return unpack( SF.Sanitize( ret ) )
		end
	else
		this[ key ] = UnwrapObject( value )
	end
end

SF.Libraries.AddHook("initialize",function( inst )
	inst.data.panels = {
		panels = {},
		count = 0
	}
end)

local function cleanup( inst )
	local panels = inst.data.panels.panels
	for panel, _ in pairs( panels ) do
		if IsValid( panel ) then
			panel:Remove( )
		end
		panels[ panel ] = nil
	end
end

SF.Libraries.AddHook( "deinitialize", cleanup )

local vgui = vgui

--- FILL for docking
-- @name VGUI.FILL
-- @class field
vgui_library.FILL = FILL
--- LEFT for docking
-- @name VGUI.LEFT
-- @class field
vgui_library.LEFT = LEFT
--- RIGHT for docking
-- @name VGUI.RIGHT
-- @class field
vgui_library.RIGHT = RIGHT
--- TOP for docking
-- @name VGUI.TOP
-- @class field
vgui_library.TOP = TOP
--- BOTTOM for docking
-- @name VGUI.BOTTOM
-- @class field
vgui_library.BOTTOM = BOTTOM
--- NODOCK for docking
-- @name VGUI.NODOCK
-- @class field
vgui_library.NODOCK = NODOCK

--- Creates and returns a derma panel.
-- @client
-- @param class The class name of the control you want to create.
-- @param parent Optional parent panel.
-- @return The created object, or nil if it could not be created.
function vgui_library.create( class, parent)
	local instance = SF.instance
	if not instance:isHUDActive() then
		return nil
	end
	
	SF.CheckType( class, "string" )
	if class:sub( 1, 1 ) ~= "D" then class = "D" .. class end
	
	local data = instance.data.panels
	
	if parent then
		SF.CheckType( parent, PanelMeta )
		parent = UnwrapObject( parent )
	end
	
	local Panel = vgui.Create( class, parent )
	if not IsValid( Panel ) then
		return nil
	end
	
	data.panels[ Panel ] = true
	return WrapObject( Panel )
end
