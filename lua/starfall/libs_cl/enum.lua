return function(instance)
local env = instance.env

--- ENUMs of mesh types. To be used with mesh.generate.
-- @name builtins_library.MATERIAL
-- @class table
-- @field LINES
-- @field LINE_LOOP
-- @field LINE_STRIP
-- @field POINTS
-- @field POLYGON
-- @field QUADS
-- @field TRIANGLES
-- @field TRIANGLE_STRIP
env.MATERIAL = {
	["LINES"] = MATERIAL_LINES,
	["LINE_LOOP"] = MATERIAL_LINE_LOOP,
	["LINE_STRIP"] = MATERIAL_LINE_STRIP,
	["POINTS"] = MATERIAL_POINTS,
	["POLYGON"] = MATERIAL_POLYGON,
	["QUADS"] = MATERIAL_QUADS,
	["TRIANGLES"] = MATERIAL_TRIANGLES,
	["TRIANGLE_STRIP"] = MATERIAL_TRIANGLE_STRIP
}

--- ENUMs of fog modes to use with render.setFogMode.
-- @name builtins_library.MATERIAL_FOG
-- @class table
-- @field NONE
-- @field LINEAR
-- @field LINEAR_BELOW_FOG_Z
env.MATERIAL_FOG = {
	["NONE"] = MATERIAL_FOG_NONE,
	["LINEAR"] = MATERIAL_FOG_LINEAR,
	["LINEAR_BELOW_FOG_Z"] = MATERIAL_FOG_LINEAR_BELOW_FOG_Z
}

--- ENUMs of stencil comparisons and operations
-- @name builtins_library.STENCIL
-- @class table
-- @field NEVER
-- @field LESS
-- @field EQUAL
-- @field LESSEQUAL
-- @field GREATER
-- @field NOTEQUAL
-- @field GREATEREQUAL
-- @field ALWAYS
-- @field KEEP
-- @field ZERO
-- @field REPLACE
-- @field INCRSAT
-- @field DECRSAT
-- @field INVERT
-- @field INCR
-- @field DECR
env.STENCIL = {
	NEVER = STENCIL_NEVER,
	LESS = STENCIL_LESS,
	EQUAL = STENCIL_EQUAL,
	LESSEQUAL = STENCIL_LESSEQUAL,
	GREATER = STENCIL_GREATER,
	NOTEQUAL = STENCIL_NOTEQUAL,
	GREATEREQUAL = STENCIL_GREATEREQUAL,
	ALWAYS = STENCIL_ALWAYS,
	KEEP = STENCIL_KEEP,
	ZERO = STENCIL_ZERO,
	REPLACE = STENCIL_REPLACE,
	INCRSAT = STENCIL_INCRSAT,
	DECRSAT = STENCIL_DECRSAT,
	INVERT = STENCIL_INVERT,
	INCR = STENCIL_INCR,
	DECR = STENCIL_DECR
}

--- Midi Command ENUMS
-- @name midi_library.MIDI
-- @class table
-- @field NOTE_OFF
-- @field NOTE_ON
-- @field AFTERTOUCH
-- @field CONTINUOUS_CONTROLLER
-- @field PATCH_CHANGE
-- @field CHANNEL_PRESSURE
-- @field PITCH_BEND
env.MIDI = {
	NOTE_OFF = 0x80,
	NOTE_ON = 0x90,
	AFTERTOUCH = 0xA0,
	CONTINUOUS_CONTROLLER = 0xB0,
	PATCH_CHANGE = 0xC0,
	CHANNEL_PRESSURE = 0xD0,
	PITCH_BEND = 0xE0
}

end
