

return function(instance)
local env = instance.env

--- Notification library enums
-- @name builtins_library.NOTIFY
-- @class table
-- @field GENERIC
-- @field ERROR
-- @field UNDO
-- @field HINT
-- @field CLEANUP
env.NOTIFY = {
	["GENERIC"] = NOTIFY_GENERIC,
	["ERROR"] = NOTIFY_ERROR,
	["UNDO"] = NOTIFY_UNDO,
	["HINT"] = NOTIFY_HINT,
	["CLEANUP"] = NOTIFY_CLEANUP
}

--- Align enum for drawing text
-- @name builtins_library.TEXT_ALIGN
-- @class table
-- @field LEFT Align the text on the left
-- @field CENTER Align the text in center
-- @field RIGHT Align the text on the right
-- @field TOP Align the text on the top
-- @field BOTTOM Align the text on the bottom
env.TEXT_ALIGN = {
	["LEFT"] = TEXT_ALIGN_LEFT,
	["CENTER"] = TEXT_ALIGN_CENTER,
	["RIGHT"] = TEXT_ALIGN_RIGHT,
	["TOP"] = TEXT_ALIGN_TOP,
	["BOTTOM"] = TEXT_ALIGN_BOTTOM
}

--- ENUMs of keyboard keys for use with input library
-- @name builtins_library.KEY
-- @class table
-- @field FIRST
-- @field NONE
-- @field 0
-- @field KEY0
-- @field 1
-- @field KEY1
-- @field 2
-- @field KEY2
-- @field 3
-- @field KEY3
-- @field 4
-- @field KEY4
-- @field 5
-- @field KEY5
-- @field 6
-- @field KEY6
-- @field 7
-- @field KEY7
-- @field 8
-- @field KEY8
-- @field 9
-- @field KEY9
-- @field A
-- @field B
-- @field C
-- @field D
-- @field E
-- @field F
-- @field G
-- @field H
-- @field I
-- @field J
-- @field K
-- @field L
-- @field M
-- @field N
-- @field O
-- @field P
-- @field Q
-- @field R
-- @field S
-- @field T
-- @field U
-- @field V
-- @field W
-- @field X
-- @field Y
-- @field Z
-- @field KP_INS
-- @field PAD_0
-- @field KP_END
-- @field PAD_1
-- @field KP_DOWNARROW
-- @field PAD_2
-- @field KP_PGDN
-- @field PAD_3
-- @field KP_LEFTARROW
-- @field PAD_4
-- @field KP_5
-- @field PAD_5
-- @field KP_RIGHTARROW
-- @field PAD_6
-- @field KP_HOME
-- @field PAD_7
-- @field KP_UPARROW
-- @field PAD_8
-- @field KP_PGUP
-- @field PAD_9
-- @field PAD_DIVIDE
-- @field KP_SLASH
-- @field KP_MULTIPLY
-- @field PAD_MULTIPLY
-- @field KP_MINUS
-- @field PAD_MINUS
-- @field KP_PLUS
-- @field PAD_PLUS
-- @field KP_ENTER
-- @field PAD_ENTER
-- @field KP_DEL
-- @field PAD_DECIMAL
-- @field LBRACKET
-- @field RBRACKET
-- @field SEMICOLON
-- @field APOSTROPHE
-- @field BACKQUOTE
-- @field COMMA
-- @field PERIOD
-- @field SLASH
-- @field BACKSLASH
-- @field MINUS
-- @field EQUAL
-- @field ENTER
-- @field SPACE
-- @field BACKSPACE
-- @field TAB
-- @field CAPSLOCK
-- @field NUMLOCK
-- @field ESCAPE
-- @field SCROLLLOCK
-- @field INS
-- @field INSERT
-- @field DEL
-- @field DELETE
-- @field HOME
-- @field END
-- @field PGUP
-- @field PAGEUP
-- @field PGDN
-- @field PAGEDOWN
-- @field PAUSE
-- @field BREAK
-- @field SHIFT
-- @field LSHIFT
-- @field RSHIFT
-- @field ALT
-- @field LALT
-- @field RALT
-- @field CTRL
-- @field LCONTROL
-- @field RCTRL
-- @field RCONTROL
-- @field LWIN
-- @field RWIN
-- @field APP
-- @field UPARROW
-- @field UP
-- @field LEFTARROW
-- @field LEFT
-- @field DOWNARROW
-- @field DOWN
-- @field RIGHTARROW
-- @field RIGHT
-- @field F1
-- @field F2
-- @field F3
-- @field F4
-- @field F5
-- @field F6
-- @field F7
-- @field F8
-- @field F9
-- @field F10
-- @field F11
-- @field F12
-- @field CAPSLOCKTOGGLE
-- @field NUMLOCKTOGGLE
-- @field SCROLLLOCKTOGGLE
-- @field LAST
-- @field COUNT
env.KEY = {
	["FIRST"] = 0,
	["NONE"] = 0,
	["0"] = 1, ["KEY0"] = 1,
	["1"] = 2, ["KEY1"] = 2,
	["2"] = 3, ["KEY2"] = 3,
	["3"] = 4, ["KEY3"] = 4,
	["4"] = 5, ["KEY4"] = 5,
	["5"] = 6, ["KEY5"] = 6,
	["6"] = 7, ["KEY6"] = 7,
	["7"] = 8, ["KEY7"] = 8,
	["8"] = 9, ["KEY8"] = 9,
	["9"] = 10, ["KEY9"] = 10,
	["A"] = 11,
	["B"] = 12,
	["C"] = 13,
	["D"] = 14,
	["E"] = 15,
	["F"] = 16,
	["G"] = 17,
	["H"] = 18,
	["I"] = 19,
	["J"] = 20,
	["K"] = 21,
	["L"] = 22,
	["M"] = 23,
	["N"] = 24,
	["O"] = 25,
	["P"] = 26,
	["Q"] = 27,
	["R"] = 28,
	["S"] = 29,
	["T"] = 30,
	["U"] = 31,
	["V"] = 32,
	["W"] = 33,
	["X"] = 34,
	["Y"] = 35,
	["Z"] = 36,
	["KP_INS"] = 37,
	["PAD_0"] = 37,
	["KP_END"] = 38,
	["PAD_1"] = 38,
	["KP_DOWNARROW"] = 39,
	["PAD_2"] = 39,
	["KP_PGDN"] = 40,
	["PAD_3"] = 40,
	["KP_LEFTARROW"] = 41,
	["PAD_4"] = 41,
	["KP_5"] = 42,
	["PAD_5"] = 42,
	["KP_RIGHTARROW"] = 43,
	["PAD_6"] = 43,
	["KP_HOME"] = 44,
	["PAD_7"] = 44,
	["KP_UPARROW"] = 45,
	["PAD_8"] = 45,
	["KP_PGUP"] = 46,
	["PAD_9"] = 46,
	["PAD_DIVIDE"] = 47,
	["KP_SLASH"] = 47,
	["KP_MULTIPLY"] = 48,
	["PAD_MULTIPLY"] = 48,
	["KP_MINUS"] = 49,
	["PAD_MINUS"] = 49,
	["KP_PLUS"] = 50,
	["PAD_PLUS"] = 50,
	["KP_ENTER"] = 51,
	["PAD_ENTER"] = 51,
	["KP_DEL"] = 52,
	["PAD_DECIMAL"] = 52,
	["["] = 53,
	["LBRACKET"] = 53,
	["]"] = 54,
	["RBRACKET"] = 54,
	["SEMICOLON"] = 55,
	["'"] = 56,
	["APOSTROPHE"] = 56,
	["`"] = 57,
	["BACKQUOTE"] = 57,
	[","] = 58,
	["COMMA"] = 58,
	["."] = 59,
	["PERIOD"] = 59,
	["/"] = 60,
	["SLASH"] = 60,
	["\\"] = 61,
	["BACKSLASH"] = 61,
	["-"] = 62,
	["MINUS"] = 62,
	["="] = 63,
	["EQUAL"] = 63,
	["ENTER"] = 64,
	["SPACE"] = 65,
	["BACKSPACE"] = 66,
	["TAB"] = 67,
	["CAPSLOCK"] = 68,
	["NUMLOCK"] = 69,
	["ESCAPE"] = 70,
	["SCROLLLOCK"] = 71,
	["INS"] = 72,
	["INSERT"] = 72,
	["DEL"] = 73,
	["DELETE"] = 73,
	["HOME"] = 74,
	["END"] = 75,
	["PGUP"] = 76,
	["PAGEUP"] = 76,
	["PGDN"] = 77,
	["PAGEDOWN"] = 77,
	["PAUSE"] = 78,
	["BREAK"] = 78,
	["SHIFT"] = 79,
	["LSHIFT"] = 79,
	["RSHIFT"] = 80,
	["ALT"] = 81,
	["LALT"] = 81,
	["RALT"] = 82,
	["CTRL"] = 83,
	["LCONTROL"] = 83,
	["RCTRL"] = 84,
	["RCONTROL"] = 84,
	["LWIN"] = 85,
	["RWIN"] = 86,
	["APP"] = 87,
	["UPARROW"] = 88,
	["UP"] = 88,
	["LEFTARROW"] = 89,
	["LEFT"] = 89,
	["DOWNARROW"] = 90,
	["DOWN"] = 90,
	["RIGHTARROW"] = 91,
	["RIGHT"] = 91,
	["F1"] = 92,
	["F2"] = 93,
	["F3"] = 94,
	["F4"] = 95,
	["F5"] = 96,
	["F6"] = 97,
	["F7"] = 98,
	["F8"] = 99,
	["F9"] = 100,
	["F10"] = 101,
	["F11"] = 102,
	["F12"] = 103,
	["CAPSLOCKTOGGLE"] = 104,
	["NUMLOCKTOGGLE"] = 105,
	["SCROLLLOCKTOGGLE"] = 106,
	["LAST"] = 106,
	["COUNT"] = 106
}

--- ENUMs of mouse buttons for use with input library
-- @name builtins_library.MOUSE
-- @class table
-- @field MOUSE1
-- @field LEFT
-- @field MOUSE2
-- @field RIGHT
-- @field MOUSE3
-- @field MIDDLE
-- @field MOUSE4
-- @field 4
-- @field MOUSE5
-- @field 5
-- @field MWHEELUP
-- @field WHEEL_UP
-- @field MWHEELDOWN
-- @field WHEEL_DOWN
-- @field COUNT
-- @field FIRST
-- @field LAST
env.MOUSE = {
	["MOUSE1"] = 107,
	["LEFT"] = 107,
	["MOUSE2"] = 108,
	["RIGHT"] = 108,
	["MOUSE3"] = 109,
	["MIDDLE"] = 109,
	["MOUSE4"] = 110,
	["4"] = 110,
	["MOUSE5"] = 111,
	["5"] = 111,
	["MWHEELUP"] = 112,
	["WHEEL_UP"] = 112,
	["MWHEELDOWN"] = 113,
	["WHEEL_DOWN"] = 113,
	["COUNT"] = 7,
	["FIRST"] = 107,
	["LAST"] = 113
}

--- PATTACH enum for particle library
-- @name builtins_library.PATTACH
-- @class table
-- @field ABSORIGIN
-- @field ABSORIGIN_FOLLOW
-- @field CUSTOMORIGIN
-- @field POINT
-- @field POINT_FOLLOW
-- @field WORLDORIGIN
env.PATTACH = {
	["ABSORIGIN"] = PATTACH_ABSORIGIN,
	["ABSORIGIN_FOLLOW"] =  PATTACH_ABSORIGIN_FOLLOW,
	["CUSTOMORIGIN"] =  PATTACH_CUSTOMORIGIN,
	["POINT"] = PATTACH_POINT,
	["POINT_FOLLOW"] = PATTACH_POINT_FOLLOW,
	["WORLDORIGIN"] =  PATTACH_WORLDORIGIN,
}

--- ENUMs of ef for use with hologram:addEffects hologram:removeEffects entity:isEffectActive
-- @name builtins_library.EF
-- @class table
-- @field BONEMERGE
-- @field BONEMERGE_FASTCULL
-- @field BRIGHTLIGHT
-- @field DIMLIGHT
-- @field NOINTERP
-- @field NOSHADOW
-- @field NODRAW
-- @field NORECEIVESHADOW
-- @field ITEM_BLINK
-- @field PARENT_ANIMATES
-- @field FOLLOWBONE
env.EF = {
	BONEMERGE = EF_BONEMERGE,
	BONEMERGE_FASTCULL = EF_BONEMERGE_FASTCULL,
	BRIGHTLIGHT = EF_BRIGHTLIGHT,
	DIMLIGHT = EF_DIMLIGHT,
	NOINTERP = EF_NOINTERP,
	NOSHADOW = EF_NOSHADOW,
	NODRAW = EF_NODRAW,
	NORECEIVESHADOW = EF_NORECEIVESHADOW,
	ITEM_BLINK = EF_ITEM_BLINK,
	PARENT_ANIMATES = EF_PARENT_ANIMATES,
	FOLLOWBONE = EF_FOLLOWBONE
}

--- ENUMs of physics object flags
-- @name builtins_library.FVPHYSICS
-- @class table
-- @field CONSTRAINT_STATIC
-- @field DMG_DISSOLVE
-- @field DMG_SLICE
-- @field HEAVY_OBJECT
-- @field MULTIOBJECT_ENTITY
-- @field NO_IMPACT_DMG
-- @field NO_NPC_IMPACT_DMG
-- @field NO_PLAYER_PICKUP
-- @field NO_SELF_COLLISIONS
-- @field PART_OF_RAGDOLL
-- @field PENETRATING
-- @field PLAYER_HELD
-- @field WAS_THROWN
env.FVPHYSICS = {
	["CONSTRAINT_STATIC"] = FVPHYSICS_CONSTRAINT_STATIC,
	["DMG_DISSOLVE"] = FVPHYSICS_DMG_DISSOLVE,
	["DMG_SLICE"] = FVPHYSICS_DMG_SLICE,
	["HEAVY_OBJECT"] = FVPHYSICS_HEAVY_OBJECT,
	["MULTIOBJECT_ENTITY"] = FVPHYSICS_MULTIOBJECT_ENTITY,
	["NO_IMPACT_DMG"] = FVPHYSICS_NO_IMPACT_DMG,
	["NO_NPC_IMPACT_DMG"] = FVPHYSICS_NO_NPC_IMPACT_DMG,
	["NO_PLAYER_PICKUP"] = FVPHYSICS_NO_PLAYER_PICKUP,
	["NO_SELF_COLLISIONS"] = FVPHYSICS_NO_SELF_COLLISIONS,
	["PART_OF_RAGDOLL"] = FVPHYSICS_PART_OF_RAGDOLL,
	["PENETRATING"] = FVPHYSICS_PENETRATING,
	["PLAYER_HELD"] = FVPHYSICS_PLAYER_HELD,
	["WAS_THROWN"] = FVPHYSICS_WAS_THROWN,
}

--- ENUMs of entity move types
-- @name builtins_library.MOVETYPE
-- @class table
-- @field NONE
-- @field ISOMETRIC
-- @field WALK
-- @field STEP
-- @field FLY
-- @field FLYGRAVITY
-- @field VPHYSICS
-- @field PUSH
-- @field NOCLIP
-- @field LADDER
-- @field OBSERVER
-- @field CUSTOM
env.MOVETYPE = {
	NONE = MOVETYPE_NONE,
	ISOMETRIC = MOVETYPE_ISOMETRIC,
	WALK = MOVETYPE_WALK,
	STEP = MOVETYPE_STEP,
	FLY = MOVETYPE_FLY,
	FLYGRAVITY = MOVETYPE_FLYGRAVITY,
	VPHYSICS = MOVETYPE_VPHYSICS,
	PUSH = MOVETYPE_PUSH,
	NOCLIP = MOVETYPE_NOCLIP,
	LADDER = MOVETYPE_LADDER,
	OBSERVER = MOVETYPE_OBSERVER,
	CUSTOM = MOVETYPE_CUSTOM,
}

--- ENUMs of in_keys for use with player:keyDown
-- @name builtins_library.IN_KEY
-- @class table
-- @field ALT1
-- @field ALT2
-- @field ATTACK
-- @field ATTACK2
-- @field BACK
-- @field DUCK
-- @field FORWARD
-- @field JUMP
-- @field LEFT
-- @field MOVELEFT
-- @field MOVERIGHT
-- @field RELOAD
-- @field RIGHT
-- @field SCORE
-- @field SPEED
-- @field USE
-- @field WALK
-- @field ZOOM
-- @field GRENADE1
-- @field GRENADE2
-- @field WEAPON1
-- @field WEAPON2
-- @field BULLRUSH
-- @field CANCEL
-- @field RUN
env.IN_KEY = {
	["ALT1"] = IN_ALT1,
	["ALT2"] = IN_ALT2,
	["ATTACK"] = IN_ATTACK,
	["ATTACK2"] = IN_ATTACK2,
	["BACK"] = IN_BACK,
	["DUCK"] = IN_DUCK,
	["FORWARD"] = IN_FORWARD,
	["JUMP"] = IN_JUMP,
	["LEFT"] = IN_LEFT,
	["MOVELEFT"] = IN_MOVELEFT,
	["MOVERIGHT"] = IN_MOVERIGHT,
	["RELOAD"] = IN_RELOAD,
	["RIGHT"] = IN_RIGHT,
	["SCORE"] = IN_SCORE,
	["SPEED"] = IN_SPEED,
	["USE"] = IN_USE,
	["WALK"] = IN_WALK,
	["ZOOM"] = IN_ZOOM,
	["GRENADE1"] = IN_GRENADE1,
	["GRENADE2"] = IN_GRENADE2,
	["WEAPON1"] = IN_WEAPON1,
	["WEAPON2"] = IN_WEAPON2,
	["BULLRUSH"] = IN_BULLRUSH,
	["CANCEL"] = IN_CANCEL,
	["RUN"] = IN_RUN,
}

--- ENUMs of gesture_slot for use with player:playGesture player:resetGesture
-- @name builtins_library.GESTURE_SLOT
-- @class table
-- @field ATTACK_AND_RELOAD
-- @field GRENADE
-- @field JUMP
-- @field SWIM
-- @field FLINCH
-- @field VCD
-- @field CUSTOM
env.GESTURE_SLOT = {
	["ATTACK_AND_RELOAD"] = GESTURE_SLOT_ATTACK_AND_RELOAD,
	["GRENADE"] = GESTURE_SLOT_GRENADE,
	["JUMP"] = GESTURE_SLOT_JUMP,
	["SWIM"] = GESTURE_SLOT_SWIM,
	["FLINCH"] = GESTURE_SLOT_FLINCH,
	["VCD"] = GESTURE_SLOT_VCD,
	["CUSTOM"] = GESTURE_SLOT_CUSTOM
}

--- ENUMs of collision groups for use with entity:setCollisionGroup
-- @name builtins_library.COLLISION_GROUP
-- @class table
-- @field NONE
-- @field DEBRIS
-- @field DEBRIS_TRIGGER
-- @field INTERACTIVE_DEBRIS
-- @field INTERACTIVE
-- @field PLAYER
-- @field BREAKABLE_GLASS
-- @field VEHICLE
-- @field PLAYER_MOVEMENT
-- @field NPC
-- @field IN_VEHICLE
-- @field WEAPON
-- @field VEHICLE_CLIP
-- @field PROJECTILE
-- @field DOOR_BLOCKER
-- @field PASSABLE_DOOR
-- @field DISSOLVING
-- @field PUSHAWAY
-- @field NPC_ACTOR
-- @field NPC_SCRIPTED
-- @field WORLD
env.COLLISION_GROUP = {
	["NONE"] = COLLISION_GROUP_NONE,
	["DEBRIS"] = COLLISION_GROUP_DEBRIS,
	["DEBRIS_TRIGGER"] = COLLISION_GROUP_DEBRIS_TRIGGER,
	["INTERACTIVE_DEBRIS"] = COLLISION_GROUP_INTERACTIVE_DEBRIS,
	["INTERACTIVE"] = COLLISION_GROUP_INTERACTIVE,
	["PLAYER"] = COLLISION_GROUP_PLAYER,
	["BREAKABLE_GLASS"] = COLLISION_GROUP_BREAKABLE_GLASS,
	["VEHICLE"] = COLLISION_GROUP_VEHICLE,
	["PLAYER_MOVEMENT"] = COLLISION_GROUP_PLAYER_MOVEMENT,
	["NPC"] = COLLISION_GROUP_NPC,
	["IN_VEHICLE"] = COLLISION_GROUP_IN_VEHICLE,
	["WEAPON"] = COLLISION_GROUP_WEAPON,
	["VEHICLE_CLIP"] = COLLISION_GROUP_VEHICLE_CLIP,
	["PROJECTILE"] = COLLISION_GROUP_PROJECTILE,
	["DOOR_BLOCKER"] = COLLISION_GROUP_DOOR_BLOCKER,
	["PASSABLE_DOOR"] = COLLISION_GROUP_PASSABLE_DOOR,
	["DISSOLVING"] = COLLISION_GROUP_DISSOLVING,
	["PUSHAWAY"] = COLLISION_GROUP_PUSHAWAY,
	["NPC_ACTOR"] = COLLISION_GROUP_NPC_ACTOR,
	["NPC_SCRIPTED"] = COLLISION_GROUP_NPC_SCRIPTED,
	["WORLD"] = COLLISION_GROUP_WORLD
}


--- ENUMs of solid for use with entity:getSolid
-- @name builtins_library.SOLID
-- @class table
-- @field NONE
-- @field BSP
-- @field BBOX
-- @field OBB
-- @field OBB_YAW
-- @field CUSTOM
-- @field VPHYSICS

env.SOLID = {
	["NONE"] = SOLID_NONE,
	["BSP"] = SOLID_BSP,
	["BBOX"] = SOLID_BBOX,
	["OBB"] = SOLID_OBB,
	["OBB_YAW"] = SOLID_OBB_YAW,
	["CUSTOM"] = SOLID_CUSTOM,
	["VPHYSICS"] = SOLID_VPHYSICS
}

--- ENUMs of solid flags for use with entity:getSolidFlags
-- @name builtins_library.FSOLID
-- @class table
-- @field CUSTOMRAYTEST
-- @field CUSTOMBOXTEST
-- @field NOT_SOLID
-- @field TRIGGER
-- @field NOT_STANDABLE
-- @field VOLUME_CONTENTS
-- @field FORCE_WORLD_ALIGNED
-- @field USE_TRIGGER_BOUNDS
-- @field ROOT_PARENT_ALIGNED
-- @field TRIGGER_TOUCH_DEBRIS
env.FSOLID = {
	["CUSTOMRAYTEST"] = FSOLID_CUSTOMRAYTEST,
	["CUSTOMBOXTEST"] = FSOLID_CUSTOMBOXTEST,
	["NOT_SOLID"] = FSOLID_NOT_SOLID,
	["TRIGGER"] = FSOLID_TRIGGER,
	["NOT_STANDABLE"] = FSOLID_NOT_STANDABLE,
	["VOLUME_CONTENTS"] = FSOLID_VOLUME_CONTENTS,
	["FORCE_WORLD_ALIGNED"] = FSOLID_FORCE_WORLD_ALIGNED,
	["USE_TRIGGER_BOUNDS"] = FSOLID_USE_TRIGGER_BOUNDS,
	["ROOT_PARENT_ALIGNED"] = FSOLID_ROOT_PARENT_ALIGNED,
	["TRIGGER_TOUCH_DEBRIS"] = FSOLID_TRIGGER_TOUCH_DEBRIS
}

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
	["POINTS"] = MATERIAL_POINTS or 0,
	["LINES"] = MATERIAL_LINES or 1,
	["TRIANGLES"] = MATERIAL_TRIANGLES or 2,
	["TRIANGLE_STRIP"] = MATERIAL_TRIANGLE_STRIP or 3,
	["LINE_STRIP"] = MATERIAL_LINE_STRIP or 4,
	["LINE_LOOP"] = MATERIAL_LINE_LOOP or 5,
	["POLYGON"] = MATERIAL_POLYGON or 6,
	["QUADS"] = MATERIAL_QUADS or 7
}

--- ENUMs of fog modes to use with render.setFogMode.
-- @name builtins_library.MATERIAL_FOG
-- @class table
-- @field NONE
-- @field LINEAR
-- @field LINEAR_BELOW_FOG_Z
env.MATERIAL_FOG = {
	["NONE"] = MATERIAL_FOG_NONE or 0,
	["LINEAR"] = MATERIAL_FOG_LINEAR or 1,
	["LINEAR_BELOW_FOG_Z"] = MATERIAL_FOG_LINEAR_BELOW_FOG_Z or 2
}

--- ENUMs used as trace masks in the trace library. These are simply combinations of the CONTENTS enums.
-- @name builtins_library.MASK
-- @class table
-- @field OPAQUE_AND_NPCS
-- @field SOLID
-- @field OPAQUE
-- @field PLAYERSOLID_BRUSHONLY
-- @field BLOCKLOS
-- @field SHOT_HULL
-- @field ALL
-- @field VISIBLE
-- @field NPCWORLDSTATIC
-- @field DEADSOLID
-- @field SPLITAREAPORTAL
-- @field CURRENT
-- @field BLOCKLOS_AND_NPCS
-- @field SHOT
-- @field NPCSOLID
-- @field SOLID_BRUSHONLY
-- @field VISIBLE_AND_NPCS
-- @field NPCSOLID_BRUSHONLY
-- @field SHOT_PORTAL
-- @field WATER
-- @field PLAYERSOLID
env.MASK = {
	["OPAQUE_AND_NPCS"] = MASK_OPAQUE_AND_NPCS,
	["SOLID"] = MASK_SOLID,
	["OPAQUE"] = MASK_OPAQUE,
	["PLAYERSOLID_BRUSHONLY"] = MASK_PLAYERSOLID_BRUSHONLY,
	["BLOCKLOS"] = MASK_BLOCKLOS,
	["SHOT_HULL"] = MASK_SHOT_HULL,
	["ALL"] = MASK_ALL,
	["VISIBLE"] = MASK_VISIBLE,
	["NPCWORLDSTATIC"] = MASK_NPCWORLDSTATIC,
	["DEADSOLID"] = MASK_DEADSOLID,
	["SPLITAREAPORTAL"] = MASK_SPLITAREAPORTAL,
	["CURRENT"] = MASK_CURRENT,
	["BLOCKLOS_AND_NPCS"] = MASK_BLOCKLOS_AND_NPCS,
	["SHOT"] = MASK_SHOT,
	["NPCSOLID"] = MASK_NPCSOLID,
	["SOLID_BRUSHONLY"] = MASK_SOLID_BRUSHONLY,
	["VISIBLE_AND_NPCS"] = MASK_VISIBLE_AND_NPCS,
	["NPCSOLID_BRUSHONLY"] = MASK_NPCSOLID_BRUSHONLY,
	["SHOT_PORTAL"] = MASK_SHOT_PORTAL,
	["WATER"] = MASK_WATER,
	["PLAYERSOLID"] = MASK_PLAYERSOLID
}

--- ENUMs used as masks in the trace library.
-- @name builtins_library.CONTENTS
-- @class table
-- @field CURRENT_270
-- @field DETAIL
-- @field IGNORE_NODRAW_OPAQUE
-- @field BLOCKLOS
-- @field GRATE
-- @field CURRENT_0
-- @field AREAPORTAL
-- @field DEBRIS
-- @field MONSTERCLIP
-- @field SLIME
-- @field WINDOW
-- @field LADDER
-- @field CURRENT_180
-- @field TRANSLUCENT
-- @field EMPTY
-- @field TEAM2
-- @field CURRENT_UP
-- @field TESTFOGVOLUME
-- @field TEAM1
-- @field AUX
-- @field CURRENT_DOWN
-- @field ORIGIN
-- @field TEAM3
-- @field MOVEABLE
-- @field PLAYERCLIP
-- @field SOLID
-- @field TEAM4
-- @field MONSTER
-- @field HITBOX
-- @field CURRENT_90
-- @field OPAQUE
-- @field WATER
env.CONTENTS = {
	["CURRENT_270"] = CONTENTS_CURRENT_270,
	["DETAIL"] = CONTENTS_DETAIL,
	["IGNORE_NODRAW_OPAQUE"] = CONTENTS_IGNORE_NODRAW_OPAQUE,
	["BLOCKLOS"] = CONTENTS_BLOCKLOS,
	["GRATE"] = CONTENTS_GRATE,
	["CURRENT_0"] = CONTENTS_CURRENT_0,
	["AREAPORTAL"] = CONTENTS_AREAPORTAL,
	["DEBRIS"] = CONTENTS_DEBRIS,
	["MONSTERCLIP"] = CONTENTS_MONSTERCLIP,
	["SLIME"] = CONTENTS_SLIME,
	["WINDOW"] = CONTENTS_WINDOW,
	["LADDER"] = CONTENTS_LADDER,
	["CURRENT_180"] = CONTENTS_CURRENT_180,
	["TRANSLUCENT"] = CONTENTS_TRANSLUCENT,
	["EMPTY"] = CONTENTS_EMPTY,
	["TEAM2"] = CONTENTS_TEAM2,
	["CURRENT_UP"] = CONTENTS_CURRENT_UP,
	["TESTFOGVOLUME"] = CONTENTS_TESTFOGVOLUME,
	["TEAM1"] = CONTENTS_TEAM1,
	["AUX"] = CONTENTS_AUX,
	["CURRENT_DOWN"] = CONTENTS_CURRENT_DOWN,
	["ORIGIN"] = CONTENTS_ORIGIN,
	["TEAM3"] = CONTENTS_TEAM3,
	["MOVEABLE"] = CONTENTS_MOVEABLE,
	["PLAYERCLIP"] = CONTENTS_PLAYERCLIP,
	["SOLID"] = CONTENTS_SOLID,
	["TEAM4"] = CONTENTS_TEAM4,
	["MONSTER"] = CONTENTS_MONSTER,
	["HITBOX"] = CONTENTS_HITBOX,
	["CURRENT_90"] = CONTENTS_CURRENT_90,
	["OPAQUE"] = CONTENTS_OPAQUE,
	["WATER"] = CONTENTS_WATER
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
	["NEVER"] = STENCIL_NEVER or 1,
	["LESS"] = STENCIL_LESS or 2,
	["EQUAL"] = STENCIL_EQUAL or 3,
	["LESSEQUAL"] = STENCIL_LESSEQUAL or 4,
	["GREATER"] = STENCIL_GREATER or 5,
	["NOTEQUAL"] = STENCIL_NOTEQUAL or 6,
	["GREATEREQUAL"] = STENCIL_GREATEREQUAL or 7,
	["ALWAYS"] = STENCIL_ALWAYS or 8,
	["KEEP"] = STENCIL_KEEP or 1,
	["ZERO"] = STENCIL_ZERO or 2,
	["REPLACE"] = STENCIL_REPLACE or 3,
	["INCRSAT"] = STENCIL_INCRSAT or 4,
	["DECRSAT"] = STENCIL_DECRSAT or 5,
	["INVERT"] = STENCIL_INVERT or 6,
	["INCR"] = STENCIL_INCR or 7,
	["DECR"] = STENCIL_DECR or 8
}
	
--- ENUMs used by render.SetModelLighting
-- @name builtins_library.BOX
-- @class table
-- @field FRONT
-- @field BACK
-- @field RIGHT
-- @field LEFT
-- @field TOP
-- @field BOTTOM
env.BOX = {
	FRONT = 0,
	BACK = 1,
	RIGHT = 2,
	LEFT = 3,
	TOP = 4,
	BOTTOM = 5
}

--- ENUMs of texture filtering modes
-- @name builtins_library.TEXFILTER
-- @class table
-- @field NONE
-- @field POINT
-- @field LINEAR
-- @field ANISOTROPIC
env.TEXFILTER = {
	NONE = TEXFILTER.NONE,
	POINT = TEXFILTER.POINT,
	LINEAR = TEXFILTER.LINEAR,
	ANISOTROPIC = TEXFILTER.ANISOTROPIC
}

--- ENUMs of blend functions
-- @name builtins_library.BLEND
-- @class table
-- @field ZERO
-- @field ONE
-- @field DST_COLOR
-- @field ONE_MINUS_DST_COLOR
-- @field SRC_ALPHA
-- @field ONE_MINUS_SRC_ALPHA
-- @field DST_ALPHA
-- @field ONE_MINUS_DST_ALPHA
-- @field SRC_ALPHA_SATURATE
-- @field SRC_COLOR
-- @field ONE_MINUS_SRC_COLOR
env.BLEND = {
	ZERO = BLEND_ZERO,
	ONE = BLEND_ONE,
	DST_COLOR = BLEND_DST_COLOR,
	ONE_MINUS_DST_COLOR = BLEND_ONE_MINUS_DST_COLOR,
	SRC_ALPHA = BLEND_SRC_ALPHA,
	ONE_MINUS_SRC_ALPHA = BLEND_ONE_MINUS_SRC_ALPHA,
	DST_ALPHA = BLEND_DST_ALPHA,
	ONE_MINUS_DST_ALPHA = BLEND_ONE_MINUS_DST_ALPHA,
	SRC_ALPHA_SATURATE = BLEND_SRC_ALPHA_SATURATE,
	SRC_COLOR = BLEND_SRC_COLOR,
	ONE_MINUS_SRC_COLOR = BLEND_ONE_MINUS_SRC_COLOR
}

--- ENUMs of blend modes
-- @name builtins_library.BLENDFUNC
-- @class table
-- @field ADD
-- @field SUBTRACT
-- @field REVERSE_SUBTRACT
-- @field MIN
-- @field MAX
env.BLENDFUNC = {
	ADD = BLENDFUNC_ADD,
	SUBTRACT = BLENDFUNC_SUBTRACT,
	REVERSE_SUBTRACT = BLENDFUNC_REVERSE_SUBTRACT,
	MIN = BLENDFUNC_MIN,
	MAX = BLENDFUNC_MAX,
}

--- ENUMs of entity render modes to be used with Entity.setRenderMode
-- @name builtins_library.RENDERMODE
-- @class table
-- @field NORMAL
-- @field TRANSCOLOR
-- @field TRANSTEXTURE
-- @field GLOW
-- @field TRANSALPHA
-- @field TRANSADD
-- @field ENVIROMENTAL
-- @field TRANSADDFRAMEBLEND
-- @field TRANSALPHADD
-- @field WORLDGLOW
-- @field NONE
env.RENDERMODE = {
	NORMAL = RENDERMODE_NORMAL,
	TRANSCOLOR = RENDERMODE_TRANSCOLOR,
	TRANSTEXTURE = RENDERMODE_TRANSTEXTURE,
	GLOW = RENDERMODE_GLOW,
	TRANSALPHA = RENDERMODE_TRANSALPHA,
	TRANSADD = RENDERMODE_TRANSADD,
	ENVIROMENTAL = RENDERMODE_ENVIROMENTAL,
	TRANSADDFRAMEBLEND = RENDERMODE_TRANSADDFRAMEBLEND,
	TRANSALPHADD = RENDERMODE_TRANSALPHADD,
	WORLDGLOW = RENDERMODE_WORLDGLOW,
	NONE = RENDERMODE_NONE
}

--- ENUMs of entity renderfx to be used with Entity.setRenderFX
-- @name builtins_library.RENDERFX
-- @class table
-- @field NONE
-- @field PULSESLOW
-- @field PULSEFAST
-- @field PULSESLOWWIDE
-- @field PULSEFASTWIDE
-- @field FADESLOW
-- @field FADEFAST
-- @field SOLIDSLOW
-- @field SOLIDFAST
-- @field STROBESLOW
-- @field STROBEFAST
-- @field STROBEFASTER
-- @field FLICKERSLOW
-- @field FLICKERFAST
-- @field NODISSIPATION
-- @field DISTORT
-- @field HOLOGRAM
-- @field EXPLODE
-- @field GLOWSHELL
-- @field CLAMPMINSCALE
-- @field RAIN
-- @field SNOW
-- @field SPOTLIGHT
-- @field RAGDOLL
-- @field PULSEFASTWIDER
env.RENDERFX = {
	NONE = kRenderFxNone,
	PULSESLOW = kRenderFxPulseSlow,
	PULSEFAST = kRenderFxPulseFast,
	PULSESLOWWIDE = kRenderFxPulseSlowWide,
	PULSEFASTWIDE = kRenderFxPulseFastWide,
	FADESLOW = kRenderFxFadeSlow,
	FADEFAST = kRenderFxFadeFast,
	SOLIDSLOW = kRenderFxSolidSlow,
	SOLIDFAST = kRenderFxSolidFast,
	STROBESLOW = kRenderFxStrobeSlow,
	STROBEFAST = kRenderFxStrobeFast,
	STROBEFASTER = kRenderFxStrobeFaster,
	FLICKERSLOW = kRenderFxFlickerSlow,
	FLICKERFAST = kRenderFxFlickerFast,
	NODISSIPATION = kRenderFxNoDissipation,
	DISTORT = kRenderFxDistort,
	HOLOGRAM = kRenderFxHologram,
	EXPLODE = kRenderFxExplode,
	GLOWSHELL = kRenderFxGlowShell,
	CLAMPMINSCALE = kRenderFxClampMinScale,
	RAIN = kRenderFxEnvRain,
	SNOW = kRenderFxEnvSnow,
	SPOTLIGHT = kRenderFxSpotlight,
	RAGDOLL = kRenderFxRagdoll,
	PULSEFASTWIDER = kRenderFxPulseFastWider
}

--- VRmod library enums
-- @name vr_library.VR
-- @class table
-- @client
-- @field BOOLEAN_PRIMARYFIRE
-- @field VECTOR1_PRIMARYFIRE
-- @field BOOLEAN_SECONDARYFIRE
-- @field BOOLEAN_CHANGEWEAPON
-- @field BOOLEAN_USE
-- @field BOOLEAN_SPAWNMENU
-- @field VECTOR2_WALKDIRECTION
-- @field BOOLEAN_WALK
-- @field BOOLEAN_FLASHLIGHT
-- @field BOOLEAN_TURNLEFT
-- @field BOOLEAN_TURNRIGHT
-- @field VECTOR2_SMOOTHTURN
-- @field BOOLEAN_CHAT
-- @field BOOLEAN_RELOAD
-- @field BOOLEAN_JUMP
-- @field BOOLEAN_LEFT_PICKUP
-- @field BOOLEAN_RIGHT_PICKUP
-- @field BOOLEAN_UNDO
-- @field BOOLEAN_SPRINT
-- @field VECTOR1_FORWARD
-- @field VECTOR1_REVERSE
-- @field BOOLEAN_TURBO
-- @field VECTOR2_STEER
-- @field BOOLEAN_HANDBRAKE
-- @field BOOLEAN_EXIT
-- @field BOOLEAN_TURRET
env.VR = {
	["BOOLEAN_PRIMARYFIRE"] = "boolean_primaryfire",
	["VECTOR1_PRIMARYFIRE"] = "vector1_primaryfire",
	["BOOLEAN_SECONDARYFIRE"] = "boolean_secondaryfire",
	["BOOLEAN_CHANGEWEAPON"] = "boolean_changeweapon",
	["BOOLEAN_USE"] = "boolean_use",
	["BOOLEAN_SPAWNMENU"] = "boolean_spawnmenu",
	["VECTOR2_WALKDIRECTION"] = "vector2_walkdirection",
	["BOOLEAN_WALK"] = "boolean_walk",
	["BOOLEAN_FLASHLIGHT"] = "boolean_flashlight",
	["BOOLEAN_TURNLEFT"] = "boolean_turnleft",
	["BOOLEAN_TURNRIGHT"] = "boolean_turnright",
	["VECTOR2_SMOOTHTURN"] = "vector2_smoothturn",
	["BOOLEAN_CHAT"] = "boolean_chat",
	["BOOLEAN_RELOAD"] = "boolean_reload",
	["BOOLEAN_JUMP"] = "boolean_jump",
	["BOOLEAN_LEFT_PICKUP"] = "boolean_left_pickup",
	["BOOLEAN_RIGHT_PICKUP"] = "boolean_right_pickup",
	["BOOLEAN_UNDO"] = "boolean_undo",
	["BOOLEAN_SPRINT"] = "boolean_sprint",
	["VECTOR1_FORWARD"] = "vector1_forward",
	["VECTOR1_REVERSE"] = "vector1_reverse",
	["BOOLEAN_TURBO"] = "boolean_turbo",
	["VECTOR2_STEER"] = "vector2_steer",
	["BOOLEAN_HANDBRAKE"] = "boolean_handbrake",
	["BOOLEAN_EXIT"] = "boolean_exit",
	["BOOLEAN_TURRET"] = "boolean_turret",
}

--- ENUMs describing surface material. Used in TraceResult
-- @name builtins_library.MAT
-- @class table
-- @field ANTLION
-- @field BLOODYFLESH
-- @field CONCRETE
-- @field DIRT
-- @field EGGSHELL
-- @field FLESH
-- @field GRATE
-- @field ALIENFLESH
-- @field CLIP
-- @field SNOW
-- @field PLASTIC
-- @field METAL
-- @field SAND
-- @field FOLIAGE
-- @field COMPUTER
-- @field SLOSH
-- @field TILE
-- @field GRASS
-- @field VENT
-- @field WOOD
-- @field DEFAULT
-- @field GLASS
-- @field WARPSHIELD
env.MAT = {
	ANTLION = MAT_ANTLION,
	BLOODYFLESH = MAT_BLOODYFLESH,
	CONCRETE = MAT_CONCRETE,
	DIRT = MAT_DIRT,
	EGGSHELL = MAT_EGGSHELL,
	FLESH = MAT_FLESH,
	GRATE = MAT_GRATE,
	ALIENFLESH = MAT_ALIENFLESH,
	CLIP = MAT_CLIP,
	SNOW = MAT_SNOW,
	PLASTIC = MAT_PLASTIC,
	METAL = MAT_METAL,
	SAND = MAT_SAND,
	FOLIAGE = MAT_FOLIAGE,
	COMPUTER = MAT_COMPUTER,
	SLOSH = MAT_SLOSH,
	TILE = MAT_TILE,
	GRASS = MAT_GRASS,
	VENT = MAT_VENT,
	WOOD = MAT_WOOD,
	DEFAULT = MAT_DEFAULT,
	GLASS = MAT_GLASS,
	WARPSHIELD = MAT_WARPSHIELD,
}

--- Player and NPC hitgroup ENUMs
-- @name builtins_library.HITGROUP
-- @class table
-- @field GENERIC
-- @field HEAD
-- @field CHEST
-- @field STOMACH
-- @field LEFTARM
-- @field RIGHTARM
-- @field LEFTLEG
-- @field RIGHTLEG
-- @field GEAR
env.HITGROUP = {
	GENERIC = HITGROUP_GENERIC,
	HEAD = HITGROUP_HEAD,
	CHEST = HITGROUP_CHEST,
	STOMACH = HITGROUP_STOMACH,
	LEFTARM = HITGROUP_LEFTARM,
	RIGHTARM = HITGROUP_RIGHTARM,
	LEFTLEG = HITGROUP_LEFTLEG,
	RIGHTLEG = HITGROUP_RIGHTLEG,
	GEAR = HITGROUP_GEAR,
}

--- file.asyncRead ENUMs
-- @name builtins_library.FSASYNC
-- @class table
-- @field ERR_NOT_MINE
-- @field ERR_RETRY_LATER
-- @field ERR_ALIGNMENT
-- @field ERR_FAILURE
-- @field ERR_READING
-- @field ERR_NOMEMORY
-- @field ERR_UNKNOWNID
-- @field ERR_FILEOPEN
-- @field OK
-- @field STATUS_PENDING
-- @field STATUS_INPROGRESS
-- @field STATUS_ABORTED
-- @field STATUS_UNSERVICED
env.FSASYNC = {
	ERR_NOT_MINE = FSASYNC_ERR_NOT_MINE,
	ERR_RETRY_LATER = FSASYNC_ERR_RETRY_LATER,
	ERR_ALIGNMENT = FSASYNC_ERR_ALIGNMENT,
	ERR_FAILURE = FSASYNC_ERR_FAILURE,
	ERR_READING = FSASYNC_ERR_READING,
	ERR_NOMEMORY = FSASYNC_ERR_NOMEMORY,
	ERR_UNKNOWNID = FSASYNC_ERR_UNKNOWNID,
	ERR_FILEOPEN = FSASYNC_ERR_FILEOPEN,
	OK = FSASYNC_OK,
	STATUS_PENDING = FSASYNC_STATUS_PENDING,
	STATUS_INPROGRESS = FSASYNC_STATUS_INPROGRESS,
	STATUS_ABORTED = FSASYNC_STATUS_ABORTED,
	STATUS_UNSERVICED = FSASYNC_STATUS_UNSERVICED
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

--- NavArea direction ENUMs
-- @name navmesh_library.NAV_DIR
-- @class table
-- @field NORTH 0
-- @field SOUTH 1
-- @field EAST 2
-- @field WEST 3
env.NAV_DIR = {
	NORTH = 0,
	EAST = 1,
	SOUTH = 2,
	WEST = 3
}

--- ENUMs used by NavArea:getAttributes and NavArea:hasAttributes
-- @name navmesh_library.NAV_MESH
-- @class table
-- @field INVALID The nav area is invalid.
-- @field CROUCH Must crouch to use this node/area
-- @field JUMP Must jump to traverse this area (only used during generation)
-- @field PRECISE Do not adjust for obstacles, just move along area
-- @field NO_JUMP Inhibit discontinuity jumping
-- @field STOP Must stop when entering this area
-- @field RUN Must run to traverse this area
-- @field WALK Must walk to traverse this area
-- @field AVOID Avoid this area unless alternatives are too dangerous
-- @field TRANSIENT Area may become blocked, and should be periodically checked
-- @field DONT_HIDE Area should not be considered for hiding spot generation
-- @field STAND Bots hiding in this area should stand
-- @field NO_HOSTAGES Hostages shouldn't use this area
-- @field STAIRS This area represents stairs, do not attempt to climb or jump them - just walk up
-- @field NO_MERGE Don't merge this area with adjacent areas
-- @field OBSTACLE_TOP This nav area is the climb point on the tip of an obstacle
-- @field CLIFF This nav area is adjacent to a drop of at least CliffHeight
-- @field FUNC_COST Area has designer specified cost controlled by func_nav_cost entities
-- @field HAS_ELEVATOR Area is in an elevator's path
-- @field NAV_BLOCKER -2147483648
env.NAV_MESH = {
	INVALID = 0,
	CROUCH = 1,
	JUMP = 2,
	PRECISE = 4,
	NO_JUMP = 8,
	STOP = 16,
	RUN = 32,
	WALK = 64,
	AVOID = 128,
	TRANSIENT = 256,
	DONT_HIDE = 512,
	STAND = 1024,
	NO_HOSTAGES = 2048,
	STAIRS = 4096,
	NO_MERGE = 8192,
	OBSTACLE_TOP = 16384,
	CLIFF = 32768,
	FUNC_COST = 536870912,
	HAS_ELEVATOR = 1073741824,
	NAV_BLOCKER = -2147483648
}

--- ENUMs used by NavArea methods. These Enums correspond to each corner of a CNavArea
-- @name navmesh_library.NAV_CORNER
-- @class table
-- @field NORTH_WEST 0
-- @field NORTH_EAST 1
-- @field SOUTH_EAST 2
-- @field SOUTH_WEST 3
-- @field NUM_CORNERS Represents all corners, only applicable to certain functions, such as NavArea:placeOnGround.
env.NAV_CORNER = {
	NORTH_WEST = 0,
	NORTH_EAST = 1,
	SOUTH_EAST = 2,
	SOUTH_WEST = 3,
	NUM_CORNERS = 4
}

--- ENUMs used by NavArea:getParentHow.
-- @class table
-- @name navmesh_library.NAV_TRAVERSE_TYPE
-- @field GO_NORTH 0
-- @field GO_EAST 1
-- @field GO_SOUTH 2
-- @field GO_WEST 3
-- @field GO_LADDER_UP 4
-- @field GO_LADDER_DOWN 5
-- @field GO_JUMP 6
-- @field GO_ELEVATOR_UP 7
-- @field GO_ELEVATOR_DOWN 8
env.NAV_TRAVERSE_TYPE = {
	GO_NORTH = 0,
	GO_EAST = 1,
	GO_SOUTH = 2,
	GO_WEST = 3,
	GO_LADDER_UP = 4,
	GO_LADDER_DOWN = 5,
	GO_JUMP = 6,
	GO_ELEVATOR_UP = 7,
	GO_ELEVATOR_DOWN = 8
}

-- ENUMs used for anything that returns a damage type.
-- @name builtins_library.DAMAGE
-- @class table
-- @field GENERIC
-- @field CRUSH
-- @field BULLET
-- @field SPLASH
-- @field BURN
-- @field VEHICLE
-- @field FALL
-- @field BLAST
-- @field CLUB
-- @field SHOCK
-- @field SONIC
-- @field ENERGYBEAM
-- @field PREVENTPHYSICSFORCE
-- @field NEVERGIB
-- @field ALWAYSGIB
-- @field DROWN
-- @field PARALYZE
-- @field NERVEGAS
-- @field POISON
-- @field RADIATION
-- @field DROWNRECOVER
-- @field ACID
-- @field SLOWBURN
-- @field REMOVENORAGDOLL
-- @field PHYSGUN
-- @field PLASMA
-- @field AIRBOAT
-- @field DISSOLVE
-- @field BLASTSURFACE
-- @field DIRECT
-- @field BUCKSHOT
-- @field SNIPER
-- @field MISSILEDEFENSE
env.DAMAGE = {
	["GENERIC"] = 0,
	["CRUSH"] = 1,
	["BULLET"] = 2,
	["SLASH"] = 4,
	["BURN"] = 8,
	["VEHICLE"] = 16,
	["FALL"] = 32,
	["BLAST"] = 64,
	["CLUB"] = 128,
	["SHOCK"] = 256,
	["SONIC"] = 512,
	["ENERGYBEAM"] = 1024,
	["PREVENTPHYSICSFORCE"] = 2048,
	["NEVERGIB"] = 4096,
	["ALWAYSGIB"] = 8192,
	["DROWN"] = 16384,
	["PARALYZE"] = 32768,
	["NERVEGAS"] = 65536,
	["POISON"] = 131072,
	["RADIATION"] = 262144,
	["DROWNRECOVER"] = 524288,
	["ACID"] = 1048576,
	["SLOWBURN"] = 2097152,
	["REMOVENORAGDOLL"] = 4194304,
	["PHYSGUN"] = 8388608,
	["PLASMA"] = 16777216,
	["AIRBOAT"] = 33554432,
	["DISSOLVE"] = 67108864,
	["BLASTSURFACE"] = 134217728,
	["DIRECT"] = 268435456,
	["BUCKSHOT"] = 536870912,
	["SNIPER"] = 1073741824,
	["MISSILEDEFENSE"] = 2147483648
}

end
