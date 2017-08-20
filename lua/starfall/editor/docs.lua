SF.Docs = { ["hooks"] = { [1] = "EndEntityDriving";[2] = "EntityRemoved";[3] = "EntityTakeDamage";[4] = "FinishChat";[5] = "GravGunOnDropped";[6] = "GravGunOnPickedUp";[7] = "GravGunPunt";[8] = "Initialize";[9] = "KeyPress";[10] = "KeyRelease";[11] = "OnEntityCreated";[12] = "OnPhysgunFreeze";[13] = "OnPhysgunReload";[14] = "PhysgunDrop";[15] = "PhysgunPickup";[16] = "PlayerCanPickupWeapon";[17] = "PlayerChat";[18] = "PlayerDeath";[19] = "PlayerDisconnected";[20] = "PlayerEnteredVehicle";[21] = "PlayerHurt";[22] = "PlayerInitialSpawn";[23] = "PlayerLeaveVehicle";[24] = "PlayerNoClip";[25] = "PlayerSay";[26] = "PlayerSpawn";[27] = "PlayerSpray";[28] = "PlayerSwitchFlashlight";[29] = "PlayerSwitchWeapon";[30] = "PlayerUse";[31] = "PropBreak";[32] = "Removed";[33] = "StartChat";[34] = "StartEntityDriving";[35] = "calcview";[36] = "drawhud";[37] = "hudconnected";[38] = "huddisconnected";[39] = "input";[40] = "inputPressed";[41] = "inputReleased";[42] = "mousemoved";[43] = "net";[44] = "postdrawhud";[45] = "postdrawopaquerenderables";[46] = "predrawhud";[47] = "predrawopaquerenderables";[48] = "readcell";[49] = "remote";[50] = "render";[51] = "renderoffscreen";[52] = "starfallUsed";[53] = "think";[54] = "tick";[55] = "writecell";["render"] = { ["description"] = "\
Called when a frame is requested to be drawn on screen. (2D/3D Context)";["class"] = "hook";["classForced"] = true;["name"] = "render";["realm"] = "cl";["summary"] = "\
Called when a frame is requested to be drawn on screen.";["client"] = true;["param"] = {}; };["PhysgunPickup"] = { ["description"] = "\
Called when an entity gets picked up by a physgun";["class"] = "hook";["classForced"] = true;["realm"] = "sh";["name"] = "PhysgunPickup";["summary"] = "\
Called when an entity gets picked up by a physgun ";["server"] = true;["client"] = true;["param"] = { [1] = "ply";[2] = "ent";["ply"] = "Player picking up the entity";["ent"] = "Entity being picked up"; }; };["hudconnected"] = { ["description"] = "\
Called when the player connects to a HUD component linked to the Starfall Chip";["class"] = "hook";["classForced"] = true;["name"] = "hudconnected";["realm"] = "cl";["summary"] = "\
Called when the player connects to a HUD component linked to the Starfall Chip ";["client"] = true;["param"] = {}; };["GravGunOnPickedUp"] = { ["description"] = "\
Called when an entity is being picked up by a gravity gun";["class"] = "hook";["classForced"] = true;["name"] = "GravGunOnPickedUp";["realm"] = "sh";["summary"] = "\
Called when an entity is being picked up by a gravity gun ";["server"] = true;["param"] = { [1] = "ply";[2] = "ent";["ply"] = "Player picking up an object";["ent"] = "Entity being picked up"; }; };["PlayerCanPickupWeapon"] = { ["description"] = "\
Called when a wants to pick up a weapon";["class"] = "hook";["classForced"] = true;["name"] = "PlayerCanPickupWeapon";["realm"] = "sh";["summary"] = "\
Called when a wants to pick up a weapon ";["server"] = true;["param"] = { [1] = "ply";[2] = "wep";["ply"] = "Player";["wep"] = "Weapon"; }; };["calcview"] = { ["ret"] = "table Table containing information for the camera. {origin=camera origin, angles=camera angles, fov=camera fov, znear=znear, zfar=zfar, drawviewer=drawviewer}";["description"] = "\
Called when the engine wants to calculate the player's view";["class"] = "hook";["classForced"] = true;["name"] = "calcview";["realm"] = "cl";["summary"] = "\
Called when the engine wants to calculate the player's view ";["client"] = true;["param"] = { [1] = "pos";[2] = "ang";[3] = "fov";[4] = "znear";[5] = "zfar";["fov"] = "Current fov of the camera";["ang"] = "Current angles of the camera";["zfar"] = "Current far plane of the camera";["znear"] = "Current near plane of the camera";["pos"] = "Current position of the camera"; }; };["PlayerSpray"] = { ["description"] = "\
Called when a players sprays his logo";["class"] = "hook";["classForced"] = true;["name"] = "PlayerSpray";["realm"] = "sh";["summary"] = "\
Called when a players sprays his logo ";["server"] = true;["param"] = { [1] = "ply";["ply"] = "Player that sprayed"; }; };["KeyRelease"] = { ["description"] = "\
Called when a player releases a key";["class"] = "hook";["classForced"] = true;["realm"] = "sh";["name"] = "KeyRelease";["summary"] = "\
Called when a player releases a key ";["server"] = true;["client"] = true;["param"] = { [1] = "ply";[2] = "key";["ply"] = "Player releasing the key";["key"] = "The key being released"; }; };["KeyPress"] = { ["description"] = "\
Called when a player presses a key";["class"] = "hook";["classForced"] = true;["realm"] = "sh";["name"] = "KeyPress";["summary"] = "\
Called when a player presses a key ";["server"] = true;["client"] = true;["param"] = { [1] = "ply";[2] = "key";["ply"] = "Player pressing the key";["key"] = "The key being pressed"; }; };["FinishChat"] = { ["description"] = "\
Called when the local player closes their chat window.";["class"] = "hook";["classForced"] = true;["name"] = "FinishChat";["realm"] = "sh";["summary"] = "\
Called when the local player closes their chat window.";["client"] = true;["param"] = {}; };["mousemoved"] = { ["classForced"] = true;["name"] = "mousemoved";["realm"] = "sh";["description"] = "\
Called when the mouse is moved";["class"] = "hook";["summary"] = "\
Called when the mouse is moved ";["param"] = { [1] = "x";[2] = "y";["y"] = "Y coordinate moved";["x"] = "X coordinate moved"; }; };["EntityTakeDamage"] = { ["description"] = "\
Called when an entity is damaged";["class"] = "hook";["classForced"] = true;["name"] = "EntityTakeDamage";["realm"] = "sh";["summary"] = "\
Called when an entity is damaged ";["server"] = true;["param"] = { [1] = "target";[2] = "attacker";[3] = "inflictor";[4] = "amount";[5] = "type";[6] = "position";[7] = "force";["inflictor"] = "Entity that inflicted the damage";["type"] = "Type of the damage";["amount"] = "How much damage";["target"] = "Entity that is hurt";["force"] = "Force of the damage";["attacker"] = "Entity that attacked";["position"] = "Position of the damage"; }; };["PlayerInitialSpawn"] = { ["description"] = "\
Called when a player spawns for the first time";["class"] = "hook";["classForced"] = true;["name"] = "PlayerInitialSpawn";["realm"] = "sh";["summary"] = "\
Called when a player spawns for the first time ";["server"] = true;["param"] = { [1] = "ply";["ply"] = "Player who spawned"; }; };["PlayerSpawn"] = { ["description"] = "\
Called when a player spawns";["class"] = "hook";["classForced"] = true;["name"] = "PlayerSpawn";["realm"] = "sh";["summary"] = "\
Called when a player spawns ";["server"] = true;["param"] = { [1] = "ply";["ply"] = "Player who spawned"; }; };["OnPhysgunFreeze"] = { ["description"] = "\
Called when an entity is being frozen";["class"] = "hook";["classForced"] = true;["name"] = "OnPhysgunFreeze";["realm"] = "sh";["summary"] = "\
Called when an entity is being frozen ";["server"] = true;["param"] = { [1] = "physgun";[2] = "physobj";[3] = "ent";[4] = "ply";["physgun"] = "Entity of the physgun";["physobj"] = "PhysObj of the entity";["ent"] = "Entity being frozen";["ply"] = "Player freezing the entity"; }; };["remote"] = { ["description"] = "\
Remote hook. \
This hook can be called from other instances";["class"] = "hook";["classForced"] = true;["realm"] = "sh";["name"] = "remote";["summary"] = "\
Remote hook.";["server"] = true;["client"] = true;["param"] = { [1] = "sender";[2] = "owner";[3] = "...";["owner"] = "The owner of the sender";["..."] = "The payload that was supplied when calling the hook";["sender"] = "The entity that caused the hook to run"; }; };["huddisconnected"] = { ["description"] = "\
Called when the player disconnects from a HUD component linked to the Starfall Chip";["class"] = "hook";["classForced"] = true;["name"] = "huddisconnected";["realm"] = "cl";["summary"] = "\
Called when the player disconnects from a HUD component linked to the Starfall Chip ";["client"] = true;["param"] = {}; };["PlayerSwitchWeapon"] = { ["description"] = "\
Called when a player switches their weapon";["class"] = "hook";["classForced"] = true;["realm"] = "sh";["name"] = "PlayerSwitchWeapon";["summary"] = "\
Called when a player switches their weapon ";["server"] = true;["client"] = true;["param"] = { [1] = "ply";[2] = "oldwep";[3] = "newweapon";["oldwep"] = "Old weapon";["ply"] = "Player droppig the entity";["newweapon"] = "New weapon"; }; };["OnPhysgunReload"] = { ["description"] = "\
Called when a player reloads his physgun";["class"] = "hook";["classForced"] = true;["name"] = "OnPhysgunReload";["realm"] = "sh";["summary"] = "\
Called when a player reloads his physgun ";["server"] = true;["param"] = { [1] = "physgun";[2] = "ply";["physgun"] = "Entity of the physgun";["ply"] = "Player reloading the physgun"; }; };["PlayerSwitchFlashlight"] = { ["description"] = "\
Called when a players turns their flashlight on or off";["class"] = "hook";["classForced"] = true;["name"] = "PlayerSwitchFlashlight";["realm"] = "sh";["summary"] = "\
Called when a players turns their flashlight on or off ";["server"] = true;["param"] = { [1] = "ply";[2] = "state";["state"] = "New flashlight state. True if on.";["ply"] = "Player switching flashlight"; }; };["PlayerUse"] = { ["description"] = "\
Called when a player holds their use key and looks at an entity. \
Will continuously run.";["class"] = "hook";["classForced"] = true;["name"] = "PlayerUse";["realm"] = "sh";["summary"] = "\
Called when a player holds their use key and looks at an entity.";["param"] = { [1] = "ply";[2] = "ent";["ply"] = "Player using the entity";["ent"] = "Entity being used"; };["server"] = true; };["GravGunPunt"] = { ["description"] = "\
Called when a player punts with the gravity gun";["class"] = "hook";["classForced"] = true;["realm"] = "sh";["name"] = "GravGunPunt";["summary"] = "\
Called when a player punts with the gravity gun ";["server"] = true;["client"] = true;["param"] = { [1] = "ply";[2] = "ent";["ply"] = "Player punting the gravgun";["ent"] = "Entity being punted"; }; };["renderoffscreen"] = { ["description"] = "\
Called when a frame is requested to be drawn. Doesn't require a screen or HUD but only works on rendertargets. (2D Context)";["class"] = "hook";["classForced"] = true;["name"] = "renderoffscreen";["realm"] = "cl";["summary"] = "\
Called when a frame is requested to be drawn.";["client"] = true;["param"] = {}; };["writecell"] = { ["classForced"] = true;["description"] = "\
Called when a high speed device writes to a wired SF chip";["realm"] = "sv";["name"] = "writecell";["class"] = "hook";["summary"] = "\
Called when a high speed device writes to a wired SF chip ";["param"] = { [1] = "address";[2] = "data";["data"] = "The data being written";["address"] = "The address written to"; }; };["EndEntityDriving"] = { ["description"] = "\
Called when a player stops driving an entity";["class"] = "hook";["classForced"] = true;["realm"] = "sh";["name"] = "EndEntityDriving";["summary"] = "\
Called when a player stops driving an entity ";["server"] = true;["client"] = true;["param"] = { [1] = "ent";[2] = "ply";["ent"] = "Entity that had been driven";["ply"] = "Player that drove the entity"; }; };["OnEntityCreated"] = { ["description"] = "\
Called when an entity gets created";["class"] = "hook";["classForced"] = true;["realm"] = "sh";["name"] = "OnEntityCreated";["summary"] = "\
Called when an entity gets created ";["server"] = true;["client"] = true;["param"] = { [1] = "ent";["ent"] = "New entity"; }; };["readcell"] = { ["ret"] = "The value read";["description"] = "\
Called when a high speed device reads from a wired SF chip";["class"] = "hook";["classForced"] = true;["name"] = "readcell";["realm"] = "sv";["summary"] = "\
Called when a high speed device reads from a wired SF chip ";["server"] = true;["param"] = { [1] = "address";["address"] = "The address requested"; }; };["StartChat"] = { ["description"] = "\
Called when the local player opens their chat window.";["class"] = "hook";["classForced"] = true;["name"] = "StartChat";["realm"] = "sh";["summary"] = "\
Called when the local player opens their chat window.";["client"] = true;["param"] = {}; };["GravGunOnDropped"] = { ["description"] = "\
Called when an entity is being dropped by a gravity gun";["class"] = "hook";["classForced"] = true;["name"] = "GravGunOnDropped";["realm"] = "sh";["summary"] = "\
Called when an entity is being dropped by a gravity gun ";["server"] = true;["param"] = { [1] = "ply";[2] = "ent";["ply"] = "Player dropping the object";["ent"] = "Entity being dropped"; }; };["net"] = { ["classForced"] = true;["description"] = "\
Called when a net message arrives";["realm"] = "sh";["name"] = "net";["class"] = "hook";["summary"] = "\
Called when a net message arrives ";["param"] = { [1] = "name";[2] = "len";[3] = "ply";["len"] = "Length of the arriving net message in bytes";["name"] = "Name of the arriving net message";["ply"] = "On server, the player that sent the message. Nil on client."; }; };["PlayerHurt"] = { ["description"] = "\
Called when a player gets hurt";["class"] = "hook";["classForced"] = true;["realm"] = "sh";["name"] = "PlayerHurt";["summary"] = "\
Called when a player gets hurt ";["server"] = true;["client"] = true;["param"] = { [1] = "ply";[2] = "attacker";[3] = "newHealth";[4] = "damageTaken";["newHealth"] = "New health of the player";["damageTaken"] = "Amount of damage the player has taken";["ply"] = "Player being hurt";["attacker"] = "Entity causing damage to the player"; }; };["inputReleased"] = { ["classForced"] = true;["description"] = "\
Called when a button is released";["realm"] = "sh";["name"] = "inputReleased";["class"] = "hook";["summary"] = "\
Called when a button is released ";["param"] = { [1] = "button";["button"] = "Number of the button"; }; };["inputPressed"] = { ["classForced"] = true;["description"] = "\
Called when a button is pressed";["realm"] = "sh";["name"] = "inputPressed";["class"] = "hook";["summary"] = "\
Called when a button is pressed ";["param"] = { [1] = "button";["button"] = "Number of the button"; }; };["PlayerChat"] = { ["description"] = "\
Called when a player's chat message is printed to the chat window";["class"] = "hook";["classForced"] = true;["name"] = "PlayerChat";["realm"] = "sh";["summary"] = "\
Called when a player's chat message is printed to the chat window ";["client"] = true;["param"] = {}; };["Initialize"] = { ["description"] = "\
Called after the starfall chip is placed/reloaded with the toolgun or duplicated and the duplication is finished.";["class"] = "hook";["classForced"] = true;["name"] = "Initialize";["realm"] = "sh";["summary"] = "\
Called after the starfall chip is placed/reloaded with the toolgun or duplicated and the duplication is finished.";["server"] = true;["param"] = {}; };["Removed"] = { ["description"] = "\
Called when the starfall chip is removed";["class"] = "hook";["classForced"] = true;["name"] = "Removed";["realm"] = "sh";["summary"] = "\
Called when the starfall chip is removed ";["server"] = true;["param"] = {}; };["tick"] = { ["description"] = "\
Tick hook. Called each game tick on both the server and client.";["class"] = "hook";["classForced"] = true;["realm"] = "sh";["name"] = "tick";["summary"] = "\
Tick hook.";["server"] = true;["client"] = true;["param"] = {}; };["PropBreak"] = { ["description"] = "\
Called when an entity is broken";["class"] = "hook";["classForced"] = true;["realm"] = "sh";["name"] = "PropBreak";["summary"] = "\
Called when an entity is broken ";["server"] = true;["client"] = true;["param"] = { [1] = "ply";[2] = "ent";["ply"] = "Player who broke it";["ent"] = "Entity broken"; }; };["PlayerNoClip"] = { ["description"] = "\
Called when a player toggles noclip";["class"] = "hook";["classForced"] = true;["realm"] = "sh";["name"] = "PlayerNoClip";["summary"] = "\
Called when a player toggles noclip ";["server"] = true;["client"] = true;["param"] = { [1] = "ply";[2] = "newState";["newState"] = "New noclip state. True if on.";["ply"] = "Player toggling noclip"; }; };["think"] = { ["description"] = "\
Think hook. Called each frame on the client and each game tick on the server.";["class"] = "hook";["classForced"] = true;["realm"] = "sh";["name"] = "think";["summary"] = "\
Think hook.";["server"] = true;["client"] = true;["param"] = {}; };["predrawopaquerenderables"] = { ["description"] = "\
Called before opaque entities are drawn. (Only works with HUD) (3D context)";["class"] = "hook";["classForced"] = true;["name"] = "predrawopaquerenderables";["realm"] = "cl";["summary"] = "\
Called before opaque entities are drawn.";["client"] = true;["param"] = { [1] = "boolean";["boolean"] = "isDrawSkybox  Whether the current draw is drawing the skybox."; }; };["StartEntityDriving"] = { ["description"] = "\
Called when a player starts driving an entity";["class"] = "hook";["classForced"] = true;["realm"] = "sh";["name"] = "StartEntityDriving";["summary"] = "\
Called when a player starts driving an entity ";["server"] = true;["client"] = true;["param"] = { [1] = "ent";[2] = "ply";["ent"] = "Entity being driven";["ply"] = "Player that is driving the entity"; }; };["EntityRemoved"] = { ["description"] = "\
Called when an entity is removed";["class"] = "hook";["classForced"] = true;["realm"] = "sh";["name"] = "EntityRemoved";["summary"] = "\
Called when an entity is removed ";["server"] = true;["client"] = true;["param"] = { [1] = "ent";["ent"] = "Entity being removed"; }; };["postdrawhud"] = { ["description"] = "\
Called after drawing HUD (2D Context)";["class"] = "hook";["classForced"] = true;["name"] = "postdrawhud";["realm"] = "cl";["summary"] = "\
Called after drawing HUD (2D Context) ";["client"] = true;["param"] = {}; };["predrawhud"] = { ["description"] = "\
Called before drawing HUD (2D Context)";["class"] = "hook";["classForced"] = true;["name"] = "predrawhud";["realm"] = "cl";["summary"] = "\
Called before drawing HUD (2D Context) ";["client"] = true;["param"] = {}; };["PlayerLeaveVehicle"] = { ["description"] = "\
Called when a players leaves a vehicle";["class"] = "hook";["classForced"] = true;["name"] = "PlayerLeaveVehicle";["realm"] = "sh";["summary"] = "\
Called when a players leaves a vehicle ";["server"] = true;["param"] = { [1] = "ply";[2] = "vehicle";["vehicle"] = "Vehicle that was left";["ply"] = "Player who left a vehicle"; }; };["PlayerSay"] = { ["ret"] = "New text. \"\" to stop from displaying. Nil to keep original.";["description"] = "\
Called when a player sends a chat message";["class"] = "hook";["classForced"] = true;["name"] = "PlayerSay";["realm"] = "sh";["summary"] = "\
Called when a player sends a chat message ";["server"] = true;["param"] = { [1] = "ply";[2] = "text";[3] = "teamChat";["text"] = "Content of the message";["ply"] = "Player that sent the message";["teamChat"] = "True if team chat"; }; };["PlayerEnteredVehicle"] = { ["description"] = "\
Called when a players enters a vehicle";["class"] = "hook";["classForced"] = true;["name"] = "PlayerEnteredVehicle";["realm"] = "sh";["summary"] = "\
Called when a players enters a vehicle ";["server"] = true;["param"] = { [1] = "ply";[2] = "vehicle";[3] = "num";["vehicle"] = "Vehicle that was entered";["ply"] = "Player who entered a vehicle";["num"] = "Role"; }; };["postdrawopaquerenderables"] = { ["description"] = "\
Called after opaque entities are drawn. (Only works with HUD) (3D context)";["class"] = "hook";["classForced"] = true;["name"] = "postdrawopaquerenderables";["realm"] = "cl";["summary"] = "\
Called after opaque entities are drawn.";["client"] = true;["param"] = { [1] = "boolean";["boolean"] = "isDrawSkybox  Whether the current draw is drawing the skybox."; }; };["drawhud"] = { ["description"] = "\
Called when a frame is requested to be drawn on hud. (2D Context)";["class"] = "hook";["classForced"] = true;["name"] = "drawhud";["realm"] = "cl";["summary"] = "\
Called when a frame is requested to be drawn on hud.";["client"] = true;["param"] = {}; };["PhysgunDrop"] = { ["description"] = "\
Called when an entity being held by a physgun gets dropped";["class"] = "hook";["classForced"] = true;["realm"] = "sh";["name"] = "PhysgunDrop";["summary"] = "\
Called when an entity being held by a physgun gets dropped ";["server"] = true;["client"] = true;["param"] = { [1] = "ply";[2] = "ent";["ply"] = "Player droppig the entity";["ent"] = "Entity being dropped"; }; };["input"] = { ["classForced"] = true;["description"] = "\
Called when an input on a wired SF chip is written to";["realm"] = "sv";["name"] = "input";["class"] = "hook";["summary"] = "\
Called when an input on a wired SF chip is written to ";["param"] = { [1] = "input";[2] = "value";["value"] = "The value of the input";["input"] = "The input name"; }; };["starfallUsed"] = { ["classForced"] = true;["description"] = "\
Called when a player uses the screen";["realm"] = "cl";["name"] = "starfallUsed";["class"] = "hook";["summary"] = "\
Called when a player uses the screen ";["param"] = { [1] = "activator";["activator"] = "Player using the screen"; }; };["PlayerDeath"] = { ["description"] = "\
Called when a player dies";["class"] = "hook";["classForced"] = true;["name"] = "PlayerDeath";["realm"] = "sh";["summary"] = "\
Called when a player dies ";["server"] = true;["param"] = { [1] = "ply";[2] = "inflictor";[3] = "attacker";["inflictor"] = "Entity used to kill the player";["ply"] = "Player who died";["attacker"] = "Entity that killed the player"; }; };["PlayerDisconnected"] = { ["description"] = "\
Called when a player disconnects";["class"] = "hook";["classForced"] = true;["name"] = "PlayerDisconnected";["realm"] = "sh";["summary"] = "\
Called when a player disconnects ";["server"] = true;["param"] = { [1] = "ply";["ply"] = "Player that disconnected"; }; }; };["libraries"] = { [1] = "bass";[2] = "builtin";[3] = "constraint";[4] = "coroutine";[5] = "fastlz";[6] = "file";[7] = "find";[8] = "game";[9] = "holograms";[10] = "hook";[11] = "http";[12] = "input";[13] = "joystick";[14] = "json";[15] = "mesh";[16] = "net";[17] = "physenv";[18] = "prop";[19] = "quaternion";[20] = "render";[21] = "sounds";[22] = "team";[23] = "timer";[24] = "trace";[25] = "von";[26] = "wire";["render"] = { ["functions"] = { [1] = "capturePixels";[2] = "clear";[3] = "clearDepth";[4] = "createFont";[5] = "createRenderTarget";[6] = "cursorPos";[7] = "destroyRenderTarget";[8] = "destroyTexture";[9] = "disableScissorRect";[10] = "draw3DBeam";[11] = "draw3DBox";[12] = "draw3DLine";[13] = "draw3DQuad";[14] = "draw3DSphere";[15] = "draw3DSprite";[16] = "draw3DWireframeBox";[17] = "draw3DWireframeSphere";[18] = "drawCircle";[19] = "drawLine";[20] = "drawPoly";[21] = "drawRect";[22] = "drawRectOutline";[23] = "drawRoundedBox";[24] = "drawRoundedBoxEx";[25] = "drawSimpleText";[26] = "drawText";[27] = "drawTexturedRect";[28] = "drawTexturedRectRotated";[29] = "drawTexturedRectUV";[30] = "enableDepth";[31] = "enableScissorRect";[32] = "getDefaultFont";[33] = "getRenderTargetMaterial";[34] = "getResolution";[35] = "getScreenEntity";[36] = "getScreenInfo";[37] = "getTextSize";[38] = "getTextureID";[39] = "isHUDActive";[40] = "parseMarkup";[41] = "popMatrix";[42] = "popViewMatrix";[43] = "pushMatrix";[44] = "pushViewMatrix";[45] = "readPixel";[46] = "selectRenderTarget";[47] = "setBackgroundColor";[48] = "setColor";[49] = "setFilterMag";[50] = "setFilterMin";[51] = "setFont";[52] = "setRGBA";[53] = "setRenderTargetTexture";[54] = "setTexture";[55] = "setTextureFromScreen";[56] = "traceSurfaceColor";["drawTexturedRectUV"] = { ["class"] = "function";["fname"] = "drawTexturedRectUV";["realm"] = "cl";["name"] = "render_library.drawTexturedRectUV";["summary"] = "\
Draws a textured rectangle with UV coordinates ";["private"] = false;["library"] = "render";["description"] = "\
Draws a textured rectangle with UV coordinates";["param"] = { [1] = "x";[2] = "y";[3] = "w";[4] = "h";[5] = "startU";[6] = "startV";[7] = "endU";[8] = "endV";["startV"] = "Texture mapping at rectangle origin";["x"] = "Top left corner x coordinate";["endV"] = "Texture mapping at rectangle end";["startU"] = "Texture mapping at rectangle origin";["y"] = "Top left corner y coordinate";["w"] = "Width";["h"] = "Height"; }; };["drawTexturedRect"] = { ["class"] = "function";["fname"] = "drawTexturedRect";["realm"] = "cl";["name"] = "render_library.drawTexturedRect";["summary"] = "\
Draws a textured rectangle.";["private"] = false;["library"] = "render";["description"] = "\
Draws a textured rectangle.";["param"] = { [1] = "x";[2] = "y";[3] = "w";[4] = "h";["y"] = "Top left corner y coordinate";["h"] = "Height";["w"] = "Width";["x"] = "Top left corner x coordinate"; }; };["pushMatrix"] = { ["class"] = "function";["fname"] = "pushMatrix";["realm"] = "cl";["name"] = "render_library.pushMatrix";["summary"] = "\
Pushes a matrix onto the matrix stack.";["private"] = false;["library"] = "render";["description"] = "\
Pushes a matrix onto the matrix stack.";["param"] = { [1] = "m";[2] = "world";["m"] = "The matrix";["world"] = "Should the transformation be relative to the screen or world?"; }; };["drawRoundedBoxEx"] = { ["class"] = "function";["fname"] = "drawRoundedBoxEx";["realm"] = "cl";["name"] = "render_library.drawRoundedBoxEx";["summary"] = "\
Draws a rounded rectangle using the current color ";["private"] = false;["library"] = "render";["description"] = "\
Draws a rounded rectangle using the current color";["param"] = { [1] = "r";[2] = "x";[3] = "y";[4] = "w";[5] = "h";[6] = "tl";[7] = "tr";[8] = "bl";[9] = "br";["tr"] = "Boolean Top right corner";["tl"] = "Boolean Top left corner";["r"] = "The corner radius";["w"] = "Width";["y"] = "Top left corner y coordinate";["h"] = "Height";["x"] = "Top left corner x coordinate";["br"] = "Boolean Bottom right corner";["bl"] = "Boolean Bottom left corner"; }; };["createFont"] = { ["class"] = "function";["realm"] = "cl";["fname"] = "createFont";["summary"] = "\
Creates a font.";["name"] = "render_library.createFont";["library"] = "render";["private"] = false;["usage"] = "\
Base font can be one of (keep in mind that these may not exist on all clients if they are not shipped with starfall): \
- Akbar \
- Coolvetica \
- Roboto \
- Roboto Mono \
- FontAwesome \
- Courier New \
- Verdana \
- Arial \
- HalfLife2 \
- hl2mp \
- csd \
- Tahoma \
- Trebuchet \
- Trebuchet MS \
- DejaVu Sans Mono \
- Lucida Console \
- Times New Roman";["description"] = "\
Creates a font. Does not require rendering hook";["param"] = { [1] = "font";[2] = "size";[3] = "weight";[4] = "antialias";[5] = "additive";[6] = "shadow";[7] = "outline";[8] = "blur";[9] = "extended";["outline"] = "Enable outline?";["shadow"] = "Enable drop shadow?";["blur"] = "Enable blur?";["additive"] = "If true, adds brightness to pixels behind it rather than drawing over them.";["font"] = "Base font to use";["weight"] = "Font weight (default: 400)";["extended"] = "Allows the font to display glyphs outside of Latin-1 range. Unicode code points above 0xFFFF are not supported. Required to use FontAwesome";["antialias"] = "Antialias font?";["size"] = "Font size"; }; };["draw3DBox"] = { ["class"] = "function";["fname"] = "draw3DBox";["realm"] = "cl";["name"] = "render_library.draw3DBox";["summary"] = "\
Draws a box in 3D space ";["private"] = false;["library"] = "render";["description"] = "\
Draws a box in 3D space";["param"] = { [1] = "origin";[2] = "angle";[3] = "mins";[4] = "maxs";["origin"] = "Origin of the box.";["maxs"] = "End position of the box, relative to origin.";["angle"] = "Orientation  of the box";["mins"] = "Start position of the box, relative to origin."; }; };["createRenderTarget"] = { ["class"] = "function";["fname"] = "createRenderTarget";["realm"] = "cl";["name"] = "render_library.createRenderTarget";["summary"] = "\
Creates a new render target to draw onto.";["private"] = false;["library"] = "render";["description"] = "\
Creates a new render target to draw onto. \
The dimensions will always be 1024x1024";["param"] = { [1] = "name";["name"] = "The name of the render target"; }; };["isHUDActive"] = { ["class"] = "function";["fname"] = "isHUDActive";["realm"] = "cl";["name"] = "render_library.isHUDActive";["summary"] = "\
Checks if a hud component is connected to the Starfall Chip ";["private"] = false;["library"] = "render";["description"] = "\
Checks if a hud component is connected to the Starfall Chip";["param"] = {}; };["traceSurfaceColor"] = { ["ret"] = "The color vector. use vector:toColor to convert it to a color.";["class"] = "function";["fname"] = "traceSurfaceColor";["realm"] = "cl";["name"] = "render_library.traceSurfaceColor";["summary"] = "\
Does a trace and returns the color of the textel the trace hits.";["private"] = false;["library"] = "render";["description"] = "\
Does a trace and returns the color of the textel the trace hits.";["param"] = { [1] = "vec1";[2] = "vec2";["vec1"] = "The starting vector";["vec2"] = "The ending vector"; }; };["getResolution"] = { ["ret"] = { [1] = "the X size of the current render context";[2] = "the Y size of the current render context"; };["class"] = "function";["realm"] = "cl";["classForced"] = true;["summary"] = "\
Returns the render context's width and height ";["name"] = "render_library.getResolution";["fname"] = "getResolution";["private"] = false;["library"] = "render";["description"] = "\
Returns the render context's width and height";["param"] = {}; };["disableScissorRect"] = { ["class"] = "function";["fname"] = "disableScissorRect";["realm"] = "cl";["name"] = "render_library.disableScissorRect";["summary"] = "\
Disables a scissoring rect which limits the drawing area.";["private"] = false;["library"] = "render";["description"] = "\
Disables a scissoring rect which limits the drawing area.";["param"] = {}; };["readPixel"] = { ["ret"] = "Color object with ( r, g, b, 255 ) from the specified pixel.";["class"] = "function";["fname"] = "readPixel";["realm"] = "cl";["name"] = "render_library.readPixel";["summary"] = "\
Reads the color of the specified pixel.";["private"] = false;["library"] = "render";["description"] = "\
Reads the color of the specified pixel.";["param"] = { [1] = "x";[2] = "y";["y"] = "Pixel y-coordinate.";["x"] = "Pixel x-coordinate."; }; };["setTexture"] = { ["class"] = "function";["fname"] = "setTexture";["realm"] = "cl";["name"] = "render_library.setTexture";["summary"] = "\
Sets the texture ";["private"] = false;["library"] = "render";["description"] = "\
Sets the texture";["param"] = { [1] = "id";["id"] = "Texture table. Aquired with render.getTextureID"; }; };["capturePixels"] = { ["class"] = "function";["fname"] = "capturePixels";["realm"] = "cl";["name"] = "render_library.capturePixels";["summary"] = "\
Dumps the current render target and allows the pixels to be accessed by render.readPixel.";["private"] = false;["library"] = "render";["description"] = "\
Dumps the current render target and allows the pixels to be accessed by render.readPixel.";["param"] = {}; };["drawPoly"] = { ["class"] = "function";["fname"] = "drawPoly";["realm"] = "cl";["name"] = "render_library.drawPoly";["summary"] = "\
Draws a polygon.";["private"] = false;["library"] = "render";["description"] = "\
Draws a polygon.";["param"] = { [1] = "poly";["poly"] = "Table of polygon vertices. Texture coordinates are optional. {{x=x1, y=y1, u=u1, v=v1}, ... }"; }; };["destroyRenderTarget"] = { ["class"] = "function";["fname"] = "destroyRenderTarget";["realm"] = "cl";["name"] = "render_library.destroyRenderTarget";["summary"] = "\
Releases the rendertarget.";["private"] = false;["library"] = "render";["description"] = "\
Releases the rendertarget. Required if you reach the maximum rendertargets.";["param"] = { [1] = "name";["name"] = "Rendertarget name"; }; };["drawTexturedRectRotated"] = { ["class"] = "function";["fname"] = "drawTexturedRectRotated";["realm"] = "cl";["name"] = "render_library.drawTexturedRectRotated";["summary"] = "\
Draws a rotated, textured rectangle.";["private"] = false;["library"] = "render";["description"] = "\
Draws a rotated, textured rectangle.";["param"] = { [1] = "x";[2] = "y";[3] = "w";[4] = "h";[5] = "rot";["y"] = "Y coordinate of center of rect";["h"] = "Height";["rot"] = "Rotation in degrees";["w"] = "Width";["x"] = "X coordinate of center of rect"; }; };["parseMarkup"] = { ["ret"] = "The markup object. See https://wiki.garrysmod.com/page/Category:MarkupObject";["class"] = "function";["fname"] = "parseMarkup";["realm"] = "cl";["name"] = "render_library.parseMarkup";["summary"] = "\
Constructs a markup object for quick styled text drawing.";["private"] = false;["library"] = "render";["description"] = "\
Constructs a markup object for quick styled text drawing.";["param"] = { [1] = "str";[2] = "maxsize";["str"] = "The markup string to parse";["maxsize"] = "The max width of the markup"; }; };["cursorPos"] = { ["ret"] = { [1] = "x position";[2] = "y position"; };["class"] = "function";["fname"] = "cursorPos";["realm"] = "cl";["name"] = "render_library.cursorPos";["summary"] = "\
Gets a 2D cursor position where ply is aiming.";["private"] = false;["library"] = "render";["description"] = "\
Gets a 2D cursor position where ply is aiming.";["param"] = { [1] = "ply";["ply"] = "player to get cursor position from(optional)"; }; };["getTextSize"] = { ["ret"] = { [1] = "width of the text";[2] = "height of the text"; };["class"] = "function";["fname"] = "getTextSize";["realm"] = "cl";["name"] = "render_library.getTextSize";["summary"] = "\
Gets the size of the specified text.";["private"] = false;["library"] = "render";["description"] = "\
Gets the size of the specified text. Don't forget to use setFont before calling this function";["param"] = { [1] = "text";["text"] = "Text to get the size of"; }; };["drawRect"] = { ["class"] = "function";["fname"] = "drawRect";["realm"] = "cl";["name"] = "render_library.drawRect";["summary"] = "\
Draws a rectangle using the current color.";["private"] = false;["library"] = "render";["description"] = "\
Draws a rectangle using the current color.";["param"] = { [1] = "x";[2] = "y";[3] = "w";[4] = "h";["y"] = "Top left corner y coordinate";["h"] = "Height";["w"] = "Width";["x"] = "Top left corner x coordinate"; }; };["setRGBA"] = { ["class"] = "function";["fname"] = "setRGBA";["realm"] = "cl";["name"] = "render_library.setRGBA";["summary"] = "\
Sets the draw color by RGBA values ";["private"] = false;["library"] = "render";["description"] = "\
Sets the draw color by RGBA values";["param"] = { [1] = "r";[2] = "g";[3] = "b";[4] = "a"; }; };["draw3DBeam"] = { ["class"] = "function";["fname"] = "draw3DBeam";["realm"] = "cl";["name"] = "render_library.draw3DBeam";["summary"] = "\
Draws textured beam.";["private"] = false;["library"] = "render";["description"] = "\
Draws textured beam.";["param"] = { [1] = "startPos";[2] = "endPos";[3] = "width";[4] = "textureStart";[5] = "textureEnd";["endPos"] = "Beam end position.";["textureStart"] = "The start coordinate of the texture used.";["textureEnd"] = "The end coordinate of the texture used.";["startPos"] = "Beam start position.";["width"] = "The width of the beam."; }; };["drawText"] = { ["class"] = "function";["fname"] = "drawText";["realm"] = "cl";["name"] = "render_library.drawText";["summary"] = "\
Draws text with newlines and tabs ";["private"] = false;["library"] = "render";["description"] = "\
Draws text with newlines and tabs";["param"] = { [1] = "x";[2] = "y";[3] = "text";[4] = "alignment";["y"] = "Y coordinate";["x"] = "X coordinate";["alignment"] = "Text alignment";["text"] = "Text to draw"; }; };["setColor"] = { ["class"] = "function";["fname"] = "setColor";["realm"] = "cl";["name"] = "render_library.setColor";["summary"] = "\
Sets the draw color ";["private"] = false;["library"] = "render";["description"] = "\
Sets the draw color";["param"] = { [1] = "clr";["clr"] = "Color type"; }; };["getDefaultFont"] = { ["ret"] = "Default font";["class"] = "function";["fname"] = "getDefaultFont";["realm"] = "cl";["name"] = "render_library.getDefaultFont";["summary"] = "\
Gets the default font ";["private"] = false;["library"] = "render";["description"] = "\
Gets the default font";["param"] = {}; };["setFilterMin"] = { ["class"] = "function";["fname"] = "setFilterMin";["realm"] = "cl";["name"] = "render_library.setFilterMin";["summary"] = "\
Sets the texture filtering function when viewing a far texture ";["private"] = false;["library"] = "render";["description"] = "\
Sets the texture filtering function when viewing a far texture";["param"] = { [1] = "val";["val"] = "The filter function to use http://wiki.garrysmod.com/page/Enums/TEXFILTER"; }; };["drawSimpleText"] = { ["class"] = "function";["fname"] = "drawSimpleText";["realm"] = "cl";["name"] = "render_library.drawSimpleText";["summary"] = "\
Draws text more easily and quickly but no new lines or tabs.";["private"] = false;["library"] = "render";["description"] = "\
Draws text more easily and quickly but no new lines or tabs.";["param"] = { [1] = "x";[2] = "y";[3] = "text";[4] = "xalign";[5] = "yalign";["y"] = "Y coordinate";["x"] = "X coordinate";["text"] = "Text to draw";["yalign"] = "Text y alignment";["xalign"] = "Text x alignment"; }; };["drawRoundedBox"] = { ["class"] = "function";["fname"] = "drawRoundedBox";["realm"] = "cl";["name"] = "render_library.drawRoundedBox";["summary"] = "\
Draws a rounded rectangle using the current color ";["private"] = false;["library"] = "render";["description"] = "\
Draws a rounded rectangle using the current color";["param"] = { [1] = "r";[2] = "x";[3] = "y";[4] = "w";[5] = "h";["y"] = "Top left corner y coordinate";["x"] = "Top left corner x coordinate";["r"] = "The corner radius";["w"] = "Width";["h"] = "Height"; }; };["drawCircle"] = { ["class"] = "function";["fname"] = "drawCircle";["realm"] = "cl";["name"] = "render_library.drawCircle";["summary"] = "\
Draws a circle outline ";["private"] = false;["library"] = "render";["description"] = "\
Draws a circle outline";["param"] = { [1] = "x";[2] = "y";[3] = "r";["y"] = "Center y coordinate";["x"] = "Center x coordinate";["r"] = "Radius"; }; };["draw3DWireframeBox"] = { ["class"] = "function";["fname"] = "draw3DWireframeBox";["realm"] = "cl";["name"] = "render_library.draw3DWireframeBox";["summary"] = "\
Draws a wireframe box in 3D space ";["private"] = false;["library"] = "render";["description"] = "\
Draws a wireframe box in 3D space";["param"] = { [1] = "origin";[2] = "angle";[3] = "mins";[4] = "maxs";["origin"] = "Origin of the box.";["maxs"] = "End position of the box, relative to origin.";["angle"] = "Orientation  of the box";["mins"] = "Start position of the box, relative to origin."; }; };["draw3DLine"] = { ["class"] = "function";["fname"] = "draw3DLine";["realm"] = "cl";["name"] = "render_library.draw3DLine";["summary"] = "\
Draws a 3D Line ";["private"] = false;["library"] = "render";["description"] = "\
Draws a 3D Line";["param"] = { [1] = "startPos";[2] = "endPos";["endPos"] = "Ending position";["startPos"] = "Starting position"; }; };["setFilterMag"] = { ["class"] = "function";["fname"] = "setFilterMag";["realm"] = "cl";["name"] = "render_library.setFilterMag";["summary"] = "\
Sets the texture filtering function when viewing a close texture ";["private"] = false;["library"] = "render";["description"] = "\
Sets the texture filtering function when viewing a close texture";["param"] = { [1] = "val";["val"] = "The filter function to use http://wiki.garrysmod.com/page/Enums/TEXFILTER"; }; };["draw3DWireframeSphere"] = { ["class"] = "function";["fname"] = "draw3DWireframeSphere";["realm"] = "cl";["name"] = "render_library.draw3DWireframeSphere";["summary"] = "\
Draws a wireframe sphere ";["private"] = false;["library"] = "render";["description"] = "\
Draws a wireframe sphere";["param"] = { [1] = "pos";[2] = "radius";[3] = "longitudeSteps";[4] = "latitudeSteps";["radius"] = "Radius of the sphere";["latitudeSteps"] = "The amount of latitude steps. The larger this number is, the smoother the sphere is";["longitudeSteps"] = "The amount of longitude steps. The larger this number is, the smoother the sphere is";["pos"] = "Position of the sphere"; }; };["draw3DSphere"] = { ["class"] = "function";["fname"] = "draw3DSphere";["realm"] = "cl";["name"] = "render_library.draw3DSphere";["summary"] = "\
Draws a sphere ";["private"] = false;["library"] = "render";["description"] = "\
Draws a sphere";["param"] = { [1] = "pos";[2] = "radius";[3] = "longitudeSteps";[4] = "latitudeSteps";["radius"] = "Radius of the sphere";["latitudeSteps"] = "The amount of latitude steps. The larger this number is, the smoother the sphere is";["longitudeSteps"] = "The amount of longitude steps. The larger this number is, the smoother the sphere is";["pos"] = "Position of the sphere"; }; };["setRenderTargetTexture"] = { ["class"] = "function";["fname"] = "setRenderTargetTexture";["realm"] = "cl";["name"] = "render_library.setRenderTargetTexture";["summary"] = "\
Sets the active texture to the render target with the specified name.";["private"] = false;["library"] = "render";["description"] = "\
Sets the active texture to the render target with the specified name. \
Nil to reset.";["param"] = { [1] = "name";["name"] = "Name of the render target to use"; }; };["enableScissorRect"] = { ["class"] = "function";["fname"] = "enableScissorRect";["realm"] = "cl";["name"] = "render_library.enableScissorRect";["summary"] = "\
Enables a scissoring rect which limits the drawing area.";["private"] = false;["library"] = "render";["description"] = "\
Enables a scissoring rect which limits the drawing area. Only works 2D contexts such as HUD or render targets.";["param"] = { [1] = "startX";[2] = "startY";[3] = "endX";[4] = "endY";["endX"] = "Y end coordinate of the scissor rect.";["startY"] = "Y start coordinate of the scissor rect.";["startX"] = "X start coordinate of the scissor rect."; }; };["draw3DSprite"] = { ["class"] = "function";["fname"] = "draw3DSprite";["realm"] = "cl";["name"] = "render_library.draw3DSprite";["summary"] = "\
Draws a sprite in 3d space.";["private"] = false;["library"] = "render";["description"] = "\
Draws a sprite in 3d space.";["param"] = { [1] = "pos";[2] = "width";[3] = "height";["height"] = "Height of the sprite.";["width"] = "Width of the sprite.";["pos"] = "Position of the sprite."; }; };["getRenderTargetMaterial"] = { ["ret"] = "Model material name. Send this to the server to set the entity's material.";["class"] = "function";["fname"] = "getRenderTargetMaterial";["realm"] = "cl";["name"] = "render_library.getRenderTargetMaterial";["summary"] = "\
Returns the model material name that uses the render target.";["private"] = false;["library"] = "render";["description"] = "\
Returns the model material name that uses the render target.";["param"] = { [1] = "name";["name"] = "Render target name"; }; };["clearDepth"] = { ["class"] = "function";["fname"] = "clearDepth";["realm"] = "cl";["name"] = "render_library.clearDepth";["summary"] = "\
Resets the depth buffer ";["private"] = false;["library"] = "render";["description"] = "\
Resets the depth buffer";["param"] = {}; };["clear"] = { ["class"] = "function";["fname"] = "clear";["realm"] = "cl";["name"] = "render_library.clear";["summary"] = "\
Clears the active render target ";["private"] = false;["library"] = "render";["description"] = "\
Clears the active render target";["param"] = { [1] = "clr";[2] = "depth";["depth"] = "Boolean if should clear depth";["clr"] = "Color type to clear with"; }; };["enableDepth"] = { ["class"] = "function";["fname"] = "enableDepth";["realm"] = "cl";["name"] = "render_library.enableDepth";["summary"] = "\
Enables or disables Depth Buffer ";["private"] = false;["library"] = "render";["description"] = "\
Enables or disables Depth Buffer";["param"] = { [1] = "enable";["enable"] = "true to enable"; }; };["drawLine"] = { ["class"] = "function";["fname"] = "drawLine";["realm"] = "cl";["name"] = "render_library.drawLine";["summary"] = "\
Draws a line ";["private"] = false;["library"] = "render";["description"] = "\
Draws a line";["param"] = { [1] = "x1";[2] = "y1";[3] = "x2";[4] = "y2";["x2"] = "X end coordinate";["y2"] = "Y end coordinate";["y1"] = "Y start coordinate";["x1"] = "X start coordinate"; }; };["getTextureID"] = { ["ret"] = "Texture table. Use it with render.setTexture. Returns nil if max url textures is reached.";["class"] = "function";["fname"] = "getTextureID";["realm"] = "cl";["name"] = "render_library.getTextureID";["summary"] = "\
Looks up a texture by file name.";["private"] = false;["library"] = "render";["description"] = "\
Looks up a texture by file name. Use with render.setTexture to draw with it. \
Make sure to store the texture to use it rather than calling this slow function repeatedly.";["param"] = { [1] = "tx";[2] = "cb";[3] = "alignment";[4] = "skip_hack";["skip_hack"] = "Turns off texture hack so you can use UVs on 3D objects";["alignment"] = "Optional alignment for the url texture. Default: \"center\", See http://www.w3schools.com/cssref/pr_background-position.asp";["cb"] = "Optional callback for when a url texture finishes loading. param1 - The texture table, param2 - The texture url";["tx"] = "Texture file path, a http url, or image data: https://en.wikipedia.org/wiki/Data_URI_scheme"; }; };["getScreenEntity"] = { ["ret"] = "Entity of the screen or hud being rendered";["class"] = "function";["fname"] = "getScreenEntity";["realm"] = "cl";["name"] = "render_library.getScreenEntity";["summary"] = "\
Returns the entity currently being rendered to ";["private"] = false;["library"] = "render";["description"] = "\
Returns the entity currently being rendered to";["param"] = {}; };["setFont"] = { ["class"] = "function";["realm"] = "cl";["fname"] = "setFont";["summary"] = "\
Sets the font ";["name"] = "render_library.setFont";["library"] = "render";["private"] = false;["usage"] = "Use a font created by render.createFont or use one of these already defined fonts: \
- DebugFixed \
- DebugFixedSmall \
- Default \
- Marlett \
- Trebuchet18 \
- Trebuchet24 \
- HudHintTextLarge \
- HudHintTextSmall \
- CenterPrintText \
- HudSelectionText \
- CloseCaption_Normal \
- CloseCaption_Bold \
- CloseCaption_BoldItalic \
- ChatFont \
- TargetID \
- TargetIDSmall \
- HL2MPTypeDeath \
- BudgetLabel \
- HudNumbers \
- DermaDefault \
- DermaDefaultBold \
- DermaLarge";["description"] = "\
Sets the font";["param"] = { [1] = "font";["font"] = "The font to use"; }; };["popViewMatrix"] = { ["class"] = "function";["fname"] = "popViewMatrix";["realm"] = "cl";["name"] = "render_library.popViewMatrix";["summary"] = "\
Pops a view matrix from the matrix stack.";["private"] = false;["library"] = "render";["description"] = "\
Pops a view matrix from the matrix stack.";["param"] = {}; };["getScreenInfo"] = { ["ret"] = "A table describing the screen.";["class"] = "function";["fname"] = "getScreenInfo";["realm"] = "cl";["name"] = "render_library.getScreenInfo";["summary"] = "\
Returns information about the screen, such as world offsets, dimentions, and rotation.";["private"] = false;["library"] = "render";["description"] = "\
Returns information about the screen, such as world offsets, dimentions, and rotation. \
Note: this does a table copy so move it out of your draw hook";["param"] = { [1] = "e";["e"] = "The screen to get info from."; }; };["draw3DQuad"] = { ["class"] = "function";["fname"] = "draw3DQuad";["realm"] = "cl";["name"] = "render_library.draw3DQuad";["summary"] = "\
Draws 2 connected triangles.";["private"] = false;["library"] = "render";["description"] = "\
Draws 2 connected triangles.";["param"] = { [1] = "vert1";[2] = "vert2";[3] = "vert3";[4] = "vert4";["vert3"] = "The third vertex.";["vert4"] = "The fourth vertex.";["vert2"] = "The second vertex.";["vert1"] = "First vertex."; }; };["destroyTexture"] = { ["class"] = "function";["fname"] = "destroyTexture";["realm"] = "cl";["name"] = "render_library.destroyTexture";["summary"] = "\
Releases the texture.";["private"] = false;["library"] = "render";["description"] = "\
Releases the texture. Required if you reach the maximum url textures.";["param"] = { [1] = "id";["id"] = "Texture table. Aquired with render.getTextureID"; }; };["selectRenderTarget"] = { ["class"] = "function";["fname"] = "selectRenderTarget";["realm"] = "cl";["name"] = "render_library.selectRenderTarget";["summary"] = "\
Selects the render target to draw on.";["private"] = false;["library"] = "render";["description"] = "\
Selects the render target to draw on. \
Nil for the visible RT.";["param"] = { [1] = "name";["name"] = "Name of the render target to use"; }; };["pushViewMatrix"] = { ["class"] = "function";["fname"] = "pushViewMatrix";["realm"] = "cl";["name"] = "render_library.pushViewMatrix";["summary"] = "\
Pushes a perspective matrix onto the view matrix stack.";["private"] = false;["library"] = "render";["description"] = "\
Pushes a perspective matrix onto the view matrix stack.";["param"] = { [1] = "tbl";["tbl"] = "The view matrix data. See http://wiki.garrysmod.com/page/Structures/RenderCamData"; }; };["popMatrix"] = { ["class"] = "function";["fname"] = "popMatrix";["realm"] = "cl";["name"] = "render_library.popMatrix";["summary"] = "\
Pops a matrix from the matrix stack.";["private"] = false;["library"] = "render";["description"] = "\
Pops a matrix from the matrix stack.";["param"] = {}; };["drawRectOutline"] = { ["class"] = "function";["fname"] = "drawRectOutline";["realm"] = "cl";["name"] = "render_library.drawRectOutline";["summary"] = "\
Draws a rectangle outline using the current color.";["private"] = false;["library"] = "render";["description"] = "\
Draws a rectangle outline using the current color.";["param"] = { [1] = "x";[2] = "y";[3] = "w";[4] = "h";["y"] = "Top left corner y coordinate";["h"] = "Height";["w"] = "Width";["x"] = "Top left corner x coordinate"; }; };["setBackgroundColor"] = { ["class"] = "function";["fname"] = "setBackgroundColor";["realm"] = "cl";["name"] = "render_library.setBackgroundColor";["summary"] = "\
Sets the draw color ";["private"] = false;["library"] = "render";["description"] = "\
Sets the draw color";["param"] = { [1] = "col";[2] = "screen";["col"] = "Color of background"; }; };["setTextureFromScreen"] = { ["class"] = "function";["fname"] = "setTextureFromScreen";["realm"] = "cl";["name"] = "render_library.setTextureFromScreen";["summary"] = "\
Sets the texture of a screen entity ";["private"] = false;["library"] = "render";["description"] = "\
Sets the texture of a screen entity";["param"] = { [1] = "ent";["ent"] = "Screen entity"; }; }; };["class"] = "library";["summary"] = "\
Render library.";["fields"] = {};["name"] = "render";["description"] = "\
Render library. Screens are 512x512 units. Most functions require \
that you be in the rendering hook to call, otherwise an error is \
thrown. +x is right, +y is down";["entity"] = "starfall_screen";["libtbl"] = "render_library";["tables"] = {};["field"] = { [1] = "TEXT_ALIGN_LEFT";[2] = "TEXT_ALIGN_CENTER";[3] = "TEXT_ALIGN_RIGHT";[4] = "TEXT_ALIGN_TOP";[5] = "TEXT_ALIGN_BOTTOM";["TEXT_ALIGN_CENTER"] = "";["TEXT_ALIGN_TOP"] = "";["TEXT_ALIGN_BOTTOM"] = "";["TEXT_ALIGN_LEFT"] = "";["TEXT_ALIGN_RIGHT"] = ""; }; };["quaternion"] = { ["functions"] = { [1] = "New";[2] = "abs";[3] = "conj";[4] = "exp";[5] = "inv";[6] = "log";[7] = "qMod";[8] = "qRotation";[9] = "qRotation";[10] = "qi";[11] = "qj";[12] = "qk";[13] = "rotationAngle";[14] = "rotationAxis";[15] = "rotationEulerAngle";[16] = "rotationVector";[17] = "slerp";[18] = "vec";["conj"] = { ["class"] = "function";["fname"] = "conj";["realm"] = "sh";["name"] = "quat_lib.conj";["summary"] = "\
Returns the conjugate of <q> ";["private"] = false;["library"] = "quaternion";["description"] = "\
Returns the conjugate of <q>";["param"] = { [1] = "q"; }; };["log"] = { ["class"] = "function";["fname"] = "log";["realm"] = "sh";["name"] = "quat_lib.log";["summary"] = "\
Calculates natural logarithm of <q> ";["private"] = false;["library"] = "quaternion";["description"] = "\
Calculates natural logarithm of <q>";["param"] = { [1] = "q"; }; };["exp"] = { ["class"] = "function";["fname"] = "exp";["realm"] = "sh";["name"] = "quat_lib.exp";["summary"] = "\
Raises Euler's constant e to the power <q> ";["private"] = false;["library"] = "quaternion";["description"] = "\
Raises Euler's constant e to the power <q>";["param"] = { [1] = "q"; }; };["slerp"] = { ["class"] = "function";["fname"] = "slerp";["realm"] = "sh";["name"] = "quat_lib.slerp";["summary"] = "\
Performs spherical linear interpolation between <q0> and <q1>.";["private"] = false;["library"] = "quaternion";["description"] = "\
Performs spherical linear interpolation between <q0> and <q1>. Returns <q0> for <t>=0, <q1> for <t>=1";["param"] = { [1] = "q0";[2] = "q1";[3] = "t"; }; };["qRotation"] = { ["class"] = "function";["fname"] = "qRotation";["realm"] = "sh";["name"] = "quat_lib.qRotation";["summary"] = "\
Construct a quaternion from the rotation vector <rv1>.";["private"] = false;["library"] = "quaternion";["description"] = "\
Construct a quaternion from the rotation vector <rv1>. Vector direction is axis of rotation, magnitude is angle in degress (by coder0xff)";["param"] = { [1] = "rv1"; }; };["qMod"] = { ["class"] = "function";["fname"] = "qMod";["realm"] = "sh";["name"] = "quat_lib.qMod";["summary"] = "\
Changes quaternion <q> so that the represented rotation is by an angle between 0 and 180 degrees (by coder0xff) ";["private"] = false;["library"] = "quaternion";["description"] = "\
Changes quaternion <q> so that the represented rotation is by an angle between 0 and 180 degrees (by coder0xff)";["param"] = { [1] = "q"; }; };["rotationEulerAngle"] = { ["class"] = "function";["fname"] = "rotationEulerAngle";["realm"] = "sh";["name"] = "quat_lib.rotationEulerAngle";["summary"] = "\
Returns the euler angle of rotation in degrees ";["private"] = false;["library"] = "quaternion";["description"] = "\
Returns the euler angle of rotation in degrees";["param"] = { [1] = "q"; }; };["New"] = { ["class"] = "function";["fname"] = "New";["realm"] = "sh";["name"] = "quat_lib.New";["summary"] = "\
Creates a new Quaternion given a variety of inputs ";["private"] = false;["library"] = "quaternion";["description"] = "\
Creates a new Quaternion given a variety of inputs";["param"] = { [1] = "self";[2] = "...";["..."] = "A series of arguments which lead to valid generation of a quaternion. \
See argTypesToQuat table for examples of acceptable inputs."; }; };["qi"] = { ["class"] = "function";["fname"] = "qi";["realm"] = "sh";["name"] = "quat_lib.qi";["summary"] = "\
Returns Quaternion <n>*i ";["private"] = false;["library"] = "quaternion";["description"] = "\
Returns Quaternion <n>*i";["param"] = { [1] = "n"; }; };["qk"] = { ["class"] = "function";["fname"] = "qk";["realm"] = "sh";["name"] = "quat_lib.qk";["summary"] = "\
Returns Quaternion <n>*k ";["private"] = false;["library"] = "quaternion";["description"] = "\
Returns Quaternion <n>*k";["param"] = { [1] = "n"; }; };["qj"] = { ["class"] = "function";["fname"] = "qj";["realm"] = "sh";["name"] = "quat_lib.qj";["summary"] = "\
Returns Quaternion <n>*j ";["private"] = false;["library"] = "quaternion";["description"] = "\
Returns Quaternion <n>*j";["param"] = { [1] = "n"; }; };["abs"] = { ["class"] = "function";["fname"] = "abs";["realm"] = "sh";["name"] = "quat_lib.abs";["summary"] = "\
Returns absolute value of <q> ";["private"] = false;["library"] = "quaternion";["description"] = "\
Returns absolute value of <q>";["param"] = { [1] = "q"; }; };["rotationAxis"] = { ["class"] = "function";["fname"] = "rotationAxis";["realm"] = "sh";["name"] = "quat_lib.rotationAxis";["summary"] = "\
Returns the axis of rotation (by coder0xff) ";["private"] = false;["library"] = "quaternion";["description"] = "\
Returns the axis of rotation (by coder0xff)";["param"] = { [1] = "q"; }; };["inv"] = { ["class"] = "function";["fname"] = "inv";["realm"] = "sh";["name"] = "quat_lib.inv";["summary"] = "\
Returns the inverse of <q> ";["private"] = false;["library"] = "quaternion";["description"] = "\
Returns the inverse of <q>";["param"] = { [1] = "q"; }; };["rotationAngle"] = { ["class"] = "function";["fname"] = "rotationAngle";["realm"] = "sh";["name"] = "quat_lib.rotationAngle";["summary"] = "\
Returns the angle of rotation in degrees (by coder0xff) ";["private"] = false;["library"] = "quaternion";["description"] = "\
Returns the angle of rotation in degrees (by coder0xff)";["param"] = { [1] = "q"; }; };["vec"] = { ["class"] = "function";["fname"] = "vec";["realm"] = "sh";["name"] = "quat_lib.vec";["summary"] = "\
Converts <q> to a vector by dropping the real component ";["private"] = false;["library"] = "quaternion";["description"] = "\
Converts <q> to a vector by dropping the real component";["param"] = { [1] = "q"; }; };["rotationVector"] = { ["class"] = "function";["fname"] = "rotationVector";["realm"] = "sh";["name"] = "quat_lib.rotationVector";["summary"] = "\
Returns the rotation vector - rotation axis where magnitude is the angle of rotation in degress (by coder0xff) ";["private"] = false;["library"] = "quaternion";["description"] = "\
Returns the rotation vector - rotation axis where magnitude is the angle of rotation in degress (by coder0xff)";["param"] = { [1] = "q"; }; }; };["class"] = "library";["summary"] = "\
Quaternion library ";["fields"] = {};["name"] = "quaternion";["client"] = true;["description"] = "\
Quaternion library";["libtbl"] = "quat_lib";["tables"] = {};["server"] = true; };["bass"] = { ["functions"] = { [1] = "loadFile";[2] = "loadURL";["loadFile"] = { ["class"] = "function";["fname"] = "loadFile";["realm"] = "cl";["name"] = "bass_library.loadFile";["summary"] = "\
Loads a sound object from a file ";["private"] = false;["library"] = "bass";["description"] = "\
Loads a sound object from a file";["param"] = { [1] = "path";[2] = "flags";[3] = "callback";["flags"] = "that will control the sound";["path"] = "Filepath to the sound file.";["callback"] = "to run when the sound is loaded"; }; };["loadURL"] = { ["class"] = "function";["fname"] = "loadURL";["realm"] = "cl";["name"] = "bass_library.loadURL";["summary"] = "\
Loads a sound object from a url ";["private"] = false;["library"] = "bass";["description"] = "\
Loads a sound object from a url";["param"] = { [1] = "path";[2] = "flags";[3] = "callback";["flags"] = "that will control the sound";["path"] = "url to the sound file.";["callback"] = "to run when the sound is loaded"; }; }; };["class"] = "library";["summary"] = "\
Bass library.";["fields"] = {};["name"] = "bass";["client"] = true;["description"] = "\
Bass library.";["libtbl"] = "bass_library";["tables"] = {}; };["json"] = { ["functions"] = { [1] = "decode";[2] = "encode";["encode"] = { ["ret"] = "JSON encoded string representation of the table";["class"] = "function";["fname"] = "encode";["realm"] = "sh";["name"] = "json_library.encode";["summary"] = "\
Convert table to JSON string ";["private"] = false;["library"] = "json";["description"] = "\
Convert table to JSON string";["param"] = { [1] = "tbl";["tbl"] = "Table to encode"; }; };["decode"] = { ["ret"] = "Table representing the JSON object";["class"] = "function";["fname"] = "decode";["realm"] = "sh";["name"] = "json_library.decode";["summary"] = "\
Convert JSON string to table ";["private"] = false;["library"] = "json";["description"] = "\
Convert JSON string to table";["param"] = { [1] = "s";["s"] = "String to decode"; }; }; };["class"] = "library";["summary"] = "\
JSON library ";["fields"] = {};["name"] = "json";["client"] = true;["description"] = "\
JSON library";["libtbl"] = "json_library";["tables"] = {};["server"] = true; };["prop"] = { ["functions"] = { [1] = "canSpawn";[2] = "create";[3] = "createSent";[4] = "propsLeft";[5] = "setPropClean";[6] = "setPropUndo";[7] = "spawnRate";["setPropUndo"] = { ["class"] = "function";["fname"] = "setPropUndo";["realm"] = "sv";["name"] = "props_library.setPropUndo";["summary"] = "\
Sets whether the props should be undo-able ";["private"] = false;["library"] = "prop";["description"] = "\
Sets whether the props should be undo-able";["param"] = { [1] = "on";["on"] = "Boolean whether the props should be undo-able"; }; };["canSpawn"] = { ["ret"] = "True if user can spawn props, False if not.";["class"] = "function";["realm"] = "sv";["fname"] = "canSpawn";["summary"] = "\
Checks if a user can spawn anymore props.";["name"] = "props_library.canSpawn";["library"] = "prop";["private"] = false;["server"] = true;["description"] = "\
Checks if a user can spawn anymore props.";["param"] = {}; };["createSent"] = { ["ret"] = "The sent object";["class"] = "function";["realm"] = "sv";["fname"] = "createSent";["summary"] = "\
Creates a sent.";["name"] = "props_library.createSent";["library"] = "prop";["private"] = false;["server"] = true;["description"] = "\
Creates a sent.";["param"] = { [1] = "pos";[2] = "ang";[3] = "class";[4] = "frozen"; }; };["spawnRate"] = { ["ret"] = "Number of props per second the user can spawn";["class"] = "function";["realm"] = "sv";["fname"] = "spawnRate";["summary"] = "\
Returns how many props per second the user can spawn ";["name"] = "props_library.spawnRate";["library"] = "prop";["private"] = false;["server"] = true;["description"] = "\
Returns how many props per second the user can spawn";["param"] = {}; };["propsLeft"] = { ["ret"] = "number of props able to be spawned";["class"] = "function";["realm"] = "sv";["fname"] = "propsLeft";["summary"] = "\
Checks how many props can be spawned ";["name"] = "props_library.propsLeft";["library"] = "prop";["private"] = false;["server"] = true;["description"] = "\
Checks how many props can be spawned";["param"] = {}; };["create"] = { ["ret"] = "The prop object";["class"] = "function";["realm"] = "sv";["fname"] = "create";["summary"] = "\
Creates a prop.";["name"] = "props_library.create";["library"] = "prop";["private"] = false;["server"] = true;["description"] = "\
Creates a prop.";["param"] = { [1] = "pos";[2] = "ang";[3] = "model";[4] = "frozen"; }; };["setPropClean"] = { ["class"] = "function";["fname"] = "setPropClean";["realm"] = "sv";["name"] = "props_library.setPropClean";["summary"] = "\
Sets whether the chip should remove created props when the chip is removed ";["private"] = false;["library"] = "prop";["description"] = "\
Sets whether the chip should remove created props when the chip is removed";["param"] = { [1] = "on";["on"] = "Boolean whether the props should be cleaned or not"; }; }; };["class"] = "library";["summary"] = "\
Library for creating and manipulating physics-less models AKA \"Props\".";["fields"] = {};["name"] = "prop";["client"] = true;["description"] = "\
Library for creating and manipulating physics-less models AKA \"Props\".";["libtbl"] = "props_library";["tables"] = {};["server"] = true; };["sounds"] = { ["functions"] = { [1] = "create";["create"] = { ["ret"] = "Sound Object";["class"] = "function";["fname"] = "create";["realm"] = "sh";["name"] = "sound_library.create";["summary"] = "\
Creates a sound and attaches it to an entity ";["private"] = false;["library"] = "sounds";["description"] = "\
Creates a sound and attaches it to an entity";["param"] = { [1] = "ent";[2] = "path";["path"] = "Filepath to the sound file.";["ent"] = "Entity to attach sound to."; }; }; };["class"] = "library";["summary"] = "\
Sounds library.";["fields"] = {};["name"] = "sounds";["client"] = true;["description"] = "\
Sounds library.";["libtbl"] = "sound_library";["tables"] = {};["server"] = true; };["team"] = { ["functions"] = { [1] = "bestAutoJoinTeam";[2] = "exists";[3] = "getAllTeams";[4] = "getColor";[5] = "getJoinable";[6] = "getName";[7] = "getNumDeaths";[8] = "getNumFrags";[9] = "getNumPlayers";[10] = "getPlayers";[11] = "getScore";["bestAutoJoinTeam"] = { ["ret"] = "index of the best team to join";["description"] = "\
Returns team with least players";["class"] = "function";["classForced"] = true;["realm"] = "sh";["name"] = "team_library.bestAutoJoinTeam";["summary"] = "\
Returns team with least players ";["fname"] = "bestAutoJoinTeam";["library"] = "team";["param"] = {}; };["getScore"] = { ["ret"] = "Number score of the team";["description"] = "\
Returns the score of a team";["class"] = "function";["classForced"] = true;["realm"] = "sh";["name"] = "team_library.getScore";["summary"] = "\
Returns the score of a team ";["fname"] = "getScore";["library"] = "team";["param"] = { [1] = "ind";["ind"] = "Index of the team"; }; };["getNumDeaths"] = { ["ret"] = "number of deaths";["description"] = "\
Returns number of deaths of all players on a team";["class"] = "function";["classForced"] = true;["realm"] = "sh";["name"] = "team_library.getNumDeaths";["summary"] = "\
Returns number of deaths of all players on a team ";["fname"] = "getNumDeaths";["library"] = "team";["param"] = { [1] = "ind";["ind"] = "Index of the team"; }; };["getAllTeams"] = { ["ret"] = "table containing team information";["class"] = "function";["fname"] = "getAllTeams";["realm"] = "sh";["name"] = "team_library.getAllTeams";["summary"] = "\
Returns a table containing team information ";["private"] = false;["library"] = "team";["description"] = "\
Returns a table containing team information";["param"] = {}; };["getJoinable"] = { ["ret"] = "boolean";["description"] = "\
Returns whether or not a team can be joined";["class"] = "function";["classForced"] = true;["realm"] = "sh";["name"] = "team_library.getJoinable";["summary"] = "\
Returns whether or not a team can be joined ";["fname"] = "getJoinable";["library"] = "team";["param"] = { [1] = "ind";["ind"] = "Index of the team"; }; };["exists"] = { ["ret"] = "boolean";["description"] = "\
Returns whether or not the team exists";["class"] = "function";["classForced"] = true;["realm"] = "sh";["name"] = "team_library.exists";["summary"] = "\
Returns whether or not the team exists ";["fname"] = "exists";["library"] = "team";["param"] = { [1] = "ind";["ind"] = "Index of the team"; }; };["getColor"] = { ["ret"] = "Color of the team";["class"] = "function";["fname"] = "getColor";["realm"] = "sh";["name"] = "team_library.getColor";["summary"] = "\
Returns the color of a team ";["private"] = false;["library"] = "team";["description"] = "\
Returns the color of a team";["param"] = { [1] = "ind";["ind"] = "Index of the team"; }; };["getNumFrags"] = { ["ret"] = "number of frags";["description"] = "\
Returns number of frags of all players on a team";["class"] = "function";["classForced"] = true;["realm"] = "sh";["name"] = "team_library.getNumFrags";["summary"] = "\
Returns number of frags of all players on a team ";["fname"] = "getNumFrags";["library"] = "team";["param"] = { [1] = "ind";["ind"] = "Index of the team"; }; };["getNumPlayers"] = { ["ret"] = "number of players";["description"] = "\
Returns number of players on a team";["class"] = "function";["classForced"] = true;["realm"] = "sh";["name"] = "team_library.getNumPlayers";["summary"] = "\
Returns number of players on a team ";["fname"] = "getNumPlayers";["library"] = "team";["param"] = { [1] = "ind";["ind"] = "Index of the team"; }; };["getPlayers"] = { ["ret"] = "Table of players";["class"] = "function";["fname"] = "getPlayers";["realm"] = "sh";["name"] = "team_library.getPlayers";["summary"] = "\
Returns the table of players on a team ";["private"] = false;["library"] = "team";["description"] = "\
Returns the table of players on a team";["param"] = { [1] = "ind";["ind"] = "Index of the team"; }; };["getName"] = { ["ret"] = "String name of the team";["description"] = "\
Returns the name of a team";["class"] = "function";["classForced"] = true;["realm"] = "sh";["name"] = "team_library.getName";["summary"] = "\
Returns the name of a team ";["fname"] = "getName";["library"] = "team";["param"] = { [1] = "ind";["ind"] = "Index of the team"; }; }; };["class"] = "library";["summary"] = "\
Library for retreiving information about teams ";["fields"] = {};["name"] = "team";["client"] = true;["description"] = "\
Library for retreiving information about teams";["libtbl"] = "team_library";["tables"] = {};["server"] = true; };["trace"] = { ["functions"] = { [1] = "trace";[2] = "traceHull";["traceHull"] = { ["ret"] = "Result of the trace https://wiki.garrysmod.com/page/Structures/TraceResult";["class"] = "function";["fname"] = "traceHull";["realm"] = "sh";["name"] = "trace_library.traceHull";["summary"] = "\
Does a swept-AABB trace ";["private"] = false;["library"] = "trace";["description"] = "\
Does a swept-AABB trace";["param"] = { [1] = "start";[2] = "endpos";[3] = "minbox";[4] = "maxbox";[5] = "filter";[6] = "mask";[7] = "colgroup";[8] = "ignworld";["colgroup"] = "The collision group of the trace";["mask"] = "Trace mask";["endpos"] = "End position";["ignworld"] = "Whether the trace should ignore world";["maxbox"] = "Upper box corner";["start"] = "Start position";["filter"] = "Entity/array of entities to filter, or a function callback with an entity arguement that returns whether the trace should hit";["minbox"] = "Lower box corner"; }; };["trace"] = { ["ret"] = "Result of the trace https://wiki.garrysmod.com/page/Structures/TraceResult";["class"] = "function";["fname"] = "trace";["realm"] = "sh";["name"] = "trace_library.trace";["summary"] = "\
Does a line trace ";["private"] = false;["library"] = "trace";["description"] = "\
Does a line trace";["param"] = { [1] = "start";[2] = "endpos";[3] = "filter";[4] = "mask";[5] = "colgroup";[6] = "ignworld";["colgroup"] = "The collision group of the trace";["ignworld"] = "Whether the trace should ignore world";["filter"] = "Entity/array of entities to filter, or a function callback with an entity arguement that returns whether the trace should hit";["start"] = "Start position";["mask"] = "Trace mask";["endpos"] = "End position"; }; }; };["class"] = "library";["summary"] = "\
Provides functions for doing line/AABB traces ";["field"] = { [1] = "MAT_ANTLION";[2] = "MAT_BLOODYFLESH";[3] = "MAT_CONCRETE";[4] = "MAT_DIRT";[5] = "MAT_FLESH";[6] = "MAT_GRATE";[7] = "MAT_ALIENFLESH";[8] = "MAT_CLIP";[9] = "MAT_PLASTIC";[10] = "MAT_METAL";[11] = "MAT_SAND";[12] = "MAT_FOLIAGE";[13] = "MAT_COMPUTER";[14] = "MAT_SLOSH";[15] = "MAT_TILE";[16] = "MAT_VENT";[17] = "MAT_WOOD";[18] = "MAT_GLASS";[19] = "HITGROUP_GENERIC";[20] = "HITGROUP_HEAD";[21] = "HITGROUP_CHEST";[22] = "HITGROUP_STOMACH";[23] = "HITGROUP_LEFTARM";[24] = "HITGROUP_RIGHTARM";[25] = "HITGROUP_LEFTLEG";[26] = "HITGROUP_RIGHTLEG";[27] = "HITGROUP_GEAR";[28] = "MASK_SPLITAREAPORTAL";[29] = "MASK_SOLID_BRUSHONLY";[30] = "MASK_WATER";[31] = "MASK_BLOCKLOS";[32] = "MASK_OPAQUE";[33] = "MASK_VISIBLE";[34] = "MASK_DEADSOLID";[35] = "MASK_PLAYERSOLID_BRUSHONLY";[36] = "MASK_NPCWORLDSTATIC";[37] = "MASK_NPCSOLID_BRUSHONLY";[38] = "MASK_CURRENT";[39] = "MASK_SHOT_PORTAL";[40] = "MASK_SOLID";[41] = "MASK_BLOCKLOS_AND_NPCS";[42] = "MASK_OPAQUE_AND_NPCS";[43] = "MASK_VISIBLE_AND_NPCS";[44] = "MASK_PLAYERSOLID";[45] = "MASK_NPCSOLID";[46] = "MASK_SHOT_HULL";[47] = "MASK_SHOT";[48] = "MASK_ALL";[49] = "CONTENTS_EMPTY";[50] = "CONTENTS_SOLID";[51] = "CONTENTS_WINDOW";[52] = "CONTENTS_AUX";[53] = "CONTENTS_GRATE";[54] = "CONTENTS_SLIME";[55] = "CONTENTS_WATER";[56] = "CONTENTS_BLOCKLOS";[57] = "CONTENTS_OPAQUE";[58] = "CONTENTS_TESTFOGVOLUME";[59] = "CONTENTS_TEAM4";[60] = "CONTENTS_TEAM3";[61] = "CONTENTS_TEAM1";[62] = "CONTENTS_TEAM2";[63] = "CONTENTS_IGNORE_NODRAW_OPAQUE";[64] = "CONTENTS_MOVEABLE";[65] = "CONTENTS_AREAPORTAL";[66] = "CONTENTS_PLAYERCLIP";[67] = "CONTENTS_MONSTERCLIP";[68] = "CONTENTS_CURRENT_0";[69] = "CONTENTS_CURRENT_90";[70] = "CONTENTS_CURRENT_180";[71] = "CONTENTS_CURRENT_270";[72] = "CONTENTS_CURRENT_UP";[73] = "CONTENTS_CURRENT_DOWN";[74] = "CONTENTS_ORIGIN";[75] = "CONTENTS_MONSTER";[76] = "CONTENTS_DEBRIS";[77] = "CONTENTS_DETAIL";[78] = "CONTENTS_TRANSLUCENT";[79] = "CONTENTS_LADDER";[80] = "CONTENTS_HITBOX";["MASK_DEADSOLID"] = "";["MASK_BLOCKLOS"] = "";["CONTENTS_EMPTY"] = "";["MASK_OPAQUE"] = "";["CONTENTS_IGNORE_NODRAW_OPAQUE"] = "";["MASK_VISIBLE"] = "";["HITGROUP_LEFTLEG"] = "";["MASK_PLAYERSOLID_BRUSHONLY"] = "";["HITGROUP_RIGHTARM"] = "";["CONTENTS_CURRENT_DOWN"] = "";["CONTENTS_OPAQUE"] = "";["MAT_TILE"] = "";["MAT_FOLIAGE"] = "";["HITGROUP_HEAD"] = "";["MASK_SHOT"] = "";["MAT_COMPUTER"] = "";["CONTENTS_TEAM3"] = "";["MASK_SPLITAREAPORTAL"] = "";["CONTENTS_CURRENT_UP"] = "";["MAT_CONCRETE"] = "";["MAT_CLIP"] = "";["MAT_WOOD"] = "";["MAT_ANTLION"] = "";["MASK_NPCSOLID_BRUSHONLY"] = "";["CONTENTS_DEBRIS"] = "";["MASK_SHOT_PORTAL"] = "";["HITGROUP_STOMACH"] = "";["MAT_SLOSH"] = "";["CONTENTS_PLAYERCLIP"] = "";["MASK_NPCWORLDSTATIC"] = "";["MASK_OPAQUE_AND_NPCS"] = "";["MAT_BLOODYFLESH"] = "";["MASK_BLOCKLOS_AND_NPCS"] = "";["CONTENTS_TEAM1"] = "";["HITGROUP_CHEST"] = "";["CONTENTS_AREAPORTAL"] = "";["HITGROUP_GENERIC"] = "";["MAT_METAL"] = "";["HITGROUP_GEAR"] = "";["MAT_VENT"] = "";["MAT_PLASTIC"] = "";["CONTENTS_CURRENT_180"] = "";["MAT_ALIENFLESH"] = "";["MAT_FLESH"] = "";["MAT_GLASS"] = "";["CONTENTS_HITBOX"] = "";["CONTENTS_LADDER"] = "";["CONTENTS_MONSTER"] = "";["CONTENTS_ORIGIN"] = "";["CONTENTS_TEAM2"] = "";["CONTENTS_DETAIL"] = "";["CONTENTS_GRATE"] = "";["MASK_NPCSOLID"] = "";["CONTENTS_MOVEABLE"] = "";["CONTENTS_TRANSLUCENT"] = "";["CONTENTS_CURRENT_270"] = "";["MASK_VISIBLE_AND_NPCS"] = "";["CONTENTS_SOLID"] = "";["CONTENTS_MONSTERCLIP"] = "";["MAT_SAND"] = "";["CONTENTS_SLIME"] = "";["CONTENTS_CURRENT_0"] = "";["CONTENTS_WINDOW"] = "";["MASK_PLAYERSOLID"] = "";["MASK_ALL"] = "";["CONTENTS_BLOCKLOS"] = "";["MASK_WATER"] = "";["MASK_SOLID_BRUSHONLY"] = "";["HITGROUP_RIGHTLEG"] = "";["CONTENTS_CURRENT_90"] = "";["CONTENTS_AUX"] = "";["MASK_CURRENT"] = "";["MAT_DIRT"] = "";["CONTENTS_TEAM4"] = "";["CONTENTS_TESTFOGVOLUME"] = "";["CONTENTS_WATER"] = "";["MASK_SOLID"] = "";["MASK_SHOT_HULL"] = "";["HITGROUP_LEFTARM"] = "";["MAT_GRATE"] = ""; };["fields"] = {};["name"] = "trace";["client"] = true;["description"] = "\
Provides functions for doing line/AABB traces";["libtbl"] = "trace_library";["tables"] = {};["server"] = true; };["mesh"] = { ["functions"] = { [1] = "createFromObj";[2] = "createFromTable";[3] = "trianglesLeft";["trianglesLeft"] = { ["ret"] = "Number of triangles that can be created";["class"] = "function";["fname"] = "trianglesLeft";["realm"] = "cl";["name"] = "mesh_library.trianglesLeft";["summary"] = "\
Returns how many triangles can be created ";["private"] = false;["library"] = "mesh";["description"] = "\
Returns how many triangles can be created";["param"] = {}; };["createFromObj"] = { ["ret"] = "Mesh object";["class"] = "function";["fname"] = "createFromObj";["realm"] = "cl";["name"] = "mesh_library.createFromObj";["summary"] = "\
Creates a mesh from an obj file.";["private"] = false;["library"] = "mesh";["description"] = "\
Creates a mesh from an obj file. Only supports triangular meshes with normals and texture coordinates.";["param"] = { [1] = "obj";["obj"] = "The obj file data"; }; };["createFromTable"] = { ["ret"] = "Mesh object";["class"] = "function";["fname"] = "createFromTable";["realm"] = "cl";["name"] = "mesh_library.createFromTable";["summary"] = "\
Creates a mesh from vertex data.";["private"] = false;["library"] = "mesh";["description"] = "\
Creates a mesh from vertex data.";["param"] = { [1] = "verteces";["verteces"] = "Table containing vertex data. http://wiki.garrysmod.com/page/Structures/MeshVertex"; }; }; };["class"] = "library";["summary"] = "\
Mesh library.";["fields"] = {};["name"] = "mesh";["client"] = true;["description"] = "\
Mesh library.";["libtbl"] = "mesh_library";["tables"] = {}; };["wire"] = { ["functions"] = { [1] = "adjustInputs";[2] = "adjustOutputs";[3] = "create";[4] = "delete";[5] = "getInputs";[6] = "getOutputs";[7] = "getWirelink";[8] = "self";[9] = "serverUUID";["self"] = { ["class"] = "function";["fname"] = "self";["realm"] = "sv";["name"] = "wire_library.self";["summary"] = "\
Returns the wirelink representing this entity.";["private"] = false;["library"] = "wire";["description"] = "\
Returns the wirelink representing this entity.";["param"] = {}; };["serverUUID"] = { ["ret"] = "UUID as string";["class"] = "function";["fname"] = "serverUUID";["realm"] = "sv";["name"] = "wire_library.serverUUID";["summary"] = "\
Returns the server's UUID.";["private"] = false;["library"] = "wire";["description"] = "\
Returns the server's UUID.";["param"] = {}; };["getOutputs"] = { ["ret"] = "Table of entity's outputs";["class"] = "function";["fname"] = "getOutputs";["realm"] = "sv";["name"] = "wire_library.getOutputs";["summary"] = "\
Returns a table of entity's outputs ";["private"] = false;["library"] = "wire";["description"] = "\
Returns a table of entity's outputs";["param"] = { [1] = "entO";["entO"] = "Entity with output(s)"; }; };["create"] = { ["class"] = "function";["fname"] = "create";["realm"] = "sv";["name"] = "wire_library.create";["summary"] = "\
Wires two entities together ";["private"] = false;["library"] = "wire";["description"] = "\
Wires two entities together";["param"] = { [1] = "entI";[2] = "entO";[3] = "inputname";[4] = "outputname";["entI"] = "Entity with input";["inputname"] = "Input to be wired";["outputname"] = "Output to be wired";["entO"] = "Entity with output"; }; };["getWirelink"] = { ["ret"] = "Wirelink of the entity";["class"] = "function";["fname"] = "getWirelink";["realm"] = "sv";["name"] = "wire_library.getWirelink";["summary"] = "\
Returns a wirelink to a wire entity ";["private"] = false;["library"] = "wire";["description"] = "\
Returns a wirelink to a wire entity";["param"] = { [1] = "ent";["ent"] = "Wire entity"; }; };["adjustOutputs"] = { ["class"] = "function";["fname"] = "adjustOutputs";["realm"] = "sv";["name"] = "wire_library.adjustOutputs";["summary"] = "\
Creates/Modifies wire outputs.";["private"] = false;["library"] = "wire";["description"] = "\
Creates/Modifies wire outputs. All wire ports must begin with an uppercase \
letter and contain only alphabetical characters.";["param"] = { [1] = "names";[2] = "types";["types"] = "An array of output types. Can be shortcuts. May be modified by the function.";["names"] = "An array of output names. May be modified by the function."; }; };["delete"] = { ["class"] = "function";["fname"] = "delete";["realm"] = "sv";["name"] = "wire_library.delete";["summary"] = "\
Unwires an entity's input ";["private"] = false;["library"] = "wire";["description"] = "\
Unwires an entity's input";["param"] = { [1] = "entI";[2] = "inputname";["entI"] = "Entity with input";["inputname"] = "Input to be un-wired"; }; };["getInputs"] = { ["ret"] = "Table of entity's inputs";["class"] = "function";["fname"] = "getInputs";["realm"] = "sv";["name"] = "wire_library.getInputs";["summary"] = "\
Returns a table of entity's inputs ";["private"] = false;["library"] = "wire";["description"] = "\
Returns a table of entity's inputs";["param"] = { [1] = "entI";["entI"] = "Entity with input(s)"; }; };["adjustInputs"] = { ["class"] = "function";["fname"] = "adjustInputs";["realm"] = "sv";["name"] = "wire_library.adjustInputs";["summary"] = "\
Creates/Modifies wire inputs.";["private"] = false;["library"] = "wire";["description"] = "\
Creates/Modifies wire inputs. All wire ports must begin with an uppercase \
letter and contain only alphabetical characters.";["param"] = { [1] = "names";[2] = "types";["types"] = "An array of input types. Can be shortcuts. May be modified by the function.";["names"] = "An array of input names. May be modified by the function."; }; }; };["class"] = "library";["fields"] = {};["name"] = "wire";["summary"] = "\
Wire library.";["description"] = "\
Wire library. Handles wire inputs/outputs, wirelinks, etc.";["libtbl"] = "wire_library";["tables"] = { [1] = "ports";["ports"] = { ["description"] = "\
Ports table. Reads from this table will read from the wire input \
of the same name. Writes will write to the wire output of the same name.";["class"] = "table";["classForced"] = true;["name"] = "wire_library.ports";["summary"] = "\
Ports table.";["library"] = "wire";["param"] = {}; }; }; };["joystick"] = { ["functions"] = { [1] = "getAxis";[2] = "getButton";[3] = "getName";[4] = "getPov";[5] = "numAxes";[6] = "numButtons";[7] = "numJoysticks";[8] = "numPovs";["numJoysticks"] = { ["ret"] = "Number of joysticks";["class"] = "function";["fname"] = "numJoysticks";["realm"] = "cl";["name"] = "joystick_library.numJoysticks";["summary"] = "\
Gets the number of detected joysticks.";["private"] = false;["library"] = "joystick";["description"] = "\
Gets the number of detected joysticks.";["param"] = {}; };["getAxis"] = { ["ret"] = "0 - 65535 where 32767 is the middle.";["class"] = "function";["fname"] = "getAxis";["realm"] = "cl";["name"] = "joystick_library.getAxis";["summary"] = "\
Gets the axis data value.";["private"] = false;["library"] = "joystick";["description"] = "\
Gets the axis data value.";["param"] = { [1] = "enum";[2] = "axis";["enum"] = "Joystick number. Starts at 0";["axis"] = "Joystick axis number. Ranges from 0 to 7."; }; };["numAxes"] = { ["ret"] = "Number of axes";["class"] = "function";["fname"] = "numAxes";["realm"] = "cl";["name"] = "joystick_library.numAxes";["summary"] = "\
Gets the number of detected axes on a joystick ";["private"] = false;["library"] = "joystick";["description"] = "\
Gets the number of detected axes on a joystick";["param"] = { [1] = "enum";["enum"] = "Joystick number. Starts at 0"; }; };["getName"] = { ["ret"] = "Name of the device";["class"] = "function";["fname"] = "getName";["realm"] = "cl";["name"] = "joystick_library.getName";["summary"] = "\
Gets the hardware name of the joystick ";["private"] = false;["library"] = "joystick";["description"] = "\
Gets the hardware name of the joystick";["param"] = { [1] = "enum";["enum"] = "Joystick number. Starts at 0"; }; };["getButton"] = { ["ret"] = "0 or 1";["class"] = "function";["fname"] = "getButton";["realm"] = "cl";["name"] = "joystick_library.getButton";["summary"] = "\
Returns if the button is pushed or not ";["private"] = false;["library"] = "joystick";["description"] = "\
Returns if the button is pushed or not";["param"] = { [1] = "enum";[2] = "button";["button"] = "Joystick button number. Starts at 0";["enum"] = "Joystick number. Starts at 0"; }; };["numPovs"] = { ["ret"] = "Number of povs";["class"] = "function";["fname"] = "numPovs";["realm"] = "cl";["name"] = "joystick_library.numPovs";["summary"] = "\
Gets the number of detected povs on a joystick ";["private"] = false;["library"] = "joystick";["description"] = "\
Gets the number of detected povs on a joystick";["param"] = { [1] = "enum";["enum"] = "Joystick number. Starts at 0"; }; };["numButtons"] = { ["ret"] = "Number of buttons";["class"] = "function";["fname"] = "numButtons";["realm"] = "cl";["name"] = "joystick_library.numButtons";["summary"] = "\
Gets the number of detected buttons on a joystick ";["private"] = false;["library"] = "joystick";["description"] = "\
Gets the number of detected buttons on a joystick";["param"] = { [1] = "enum";["enum"] = "Joystick number. Starts at 0"; }; };["getPov"] = { ["ret"] = "0 - 65535 where 32767 is the middle.";["class"] = "function";["fname"] = "getPov";["realm"] = "cl";["name"] = "joystick_library.getPov";["summary"] = "\
Gets the pov data value.";["private"] = false;["library"] = "joystick";["description"] = "\
Gets the pov data value.";["param"] = { [1] = "enum";[2] = "pov";["pov"] = "Joystick pov number. Ranges from 0 to 7.";["enum"] = "Joystick number. Starts at 0"; }; }; };["class"] = "library";["summary"] = "\
Joystick library.";["fields"] = {};["name"] = "joystick";["client"] = true;["description"] = "\
Joystick library.";["libtbl"] = "joystick_library";["tables"] = {}; };["fastlz"] = { ["functions"] = { [1] = "compress";[2] = "decompress";["decompress"] = { ["ret"] = "Decompressed string";["class"] = "function";["fname"] = "decompress";["realm"] = "sh";["name"] = "fastlz_library.decompress";["summary"] = "\
Decompress using FastLZ ";["private"] = false;["library"] = "fastlz";["description"] = "\
Decompress using FastLZ";["param"] = { [1] = "s";["s"] = "FastLZ compressed string to decode"; }; };["compress"] = { ["ret"] = "FastLZ compressed string";["class"] = "function";["fname"] = "compress";["realm"] = "sh";["name"] = "fastlz_library.compress";["summary"] = "\
Compress string using FastLZ ";["private"] = false;["library"] = "fastlz";["description"] = "\
Compress string using FastLZ";["param"] = { [1] = "s";["s"] = "String to compress"; }; }; };["class"] = "library";["summary"] = "\
FastLZ library ";["fields"] = {};["name"] = "fastlz";["client"] = true;["description"] = "\
FastLZ library";["libtbl"] = "fastlz_library";["tables"] = {};["server"] = true; };["holograms"] = { ["functions"] = { [1] = "canSpawn";[2] = "create";[3] = "hologramsLeft";["canSpawn"] = { ["ret"] = "True if user can spawn holograms, False if not.";["class"] = "function";["realm"] = "sv";["fname"] = "canSpawn";["summary"] = "\
Checks if a user can spawn anymore holograms.";["name"] = "holograms_library.canSpawn";["library"] = "holograms";["private"] = false;["server"] = true;["description"] = "\
Checks if a user can spawn anymore holograms.";["param"] = {}; };["create"] = { ["ret"] = "The hologram object";["class"] = "function";["realm"] = "sv";["fname"] = "create";["summary"] = "\
Creates a hologram.";["name"] = "holograms_library.create";["library"] = "holograms";["private"] = false;["server"] = true;["description"] = "\
Creates a hologram.";["param"] = { [1] = "pos";[2] = "ang";[3] = "model";[4] = "scale"; }; };["hologramsLeft"] = { ["ret"] = "number of holograms able to be spawned";["class"] = "function";["realm"] = "sv";["fname"] = "hologramsLeft";["summary"] = "\
Checks how many holograms can be spawned ";["name"] = "holograms_library.hologramsLeft";["library"] = "holograms";["private"] = false;["server"] = true;["description"] = "\
Checks how many holograms can be spawned";["param"] = {}; }; };["class"] = "library";["summary"] = "\
Library for creating and manipulating physics-less models AKA \"Holograms\".";["fields"] = {};["name"] = "holograms";["description"] = "\
Library for creating and manipulating physics-less models AKA \"Holograms\".";["libtbl"] = "holograms_library";["tables"] = {};["server"] = true; };["game"] = { ["functions"] = { [1] = "getGamemode";[2] = "getHostname";[3] = "getMap";[4] = "getMaxPlayers";[5] = "isDedicated";[6] = "isLan";[7] = "isSinglePlayer";["getMaxPlayers"] = { ["class"] = "function";["fname"] = "getMaxPlayers";["realm"] = "sh";["name"] = "game_lib.getMaxPlayers";["summary"] = "\
Returns the maximum player limit ";["private"] = false;["library"] = "game";["description"] = "\
Returns the maximum player limit";["param"] = {}; };["getGamemode"] = { ["class"] = "function";["fname"] = "getGamemode";["realm"] = "sh";["name"] = "game_lib.getGamemode";["summary"] = "\
Returns the gamemode as a String ";["private"] = false;["library"] = "game";["description"] = "\
Returns the gamemode as a String";["param"] = {}; };["getMap"] = { ["class"] = "function";["fname"] = "getMap";["realm"] = "sh";["name"] = "game_lib.getMap";["summary"] = "\
Returns the map name ";["private"] = false;["library"] = "game";["description"] = "\
Returns the map name";["param"] = {}; };["isLan"] = { ["deprecated"] = "Possibly add ConVar retrieval for users in future. Could implement with SF Script.";["class"] = "function";["fname"] = "isLan";["realm"] = "sh";["name"] = "game_lib.isLan";["summary"] = "\
Returns true if the server is on a LAN ";["private"] = false;["library"] = "game";["description"] = "\
Returns true if the server is on a LAN";["param"] = {}; };["isSinglePlayer"] = { ["class"] = "function";["fname"] = "isSinglePlayer";["realm"] = "sh";["name"] = "game_lib.isSinglePlayer";["summary"] = "\
Returns whether or not the current game is single player ";["private"] = false;["library"] = "game";["description"] = "\
Returns whether or not the current game is single player";["param"] = {}; };["isDedicated"] = { ["class"] = "function";["fname"] = "isDedicated";["realm"] = "sh";["name"] = "game_lib.isDedicated";["summary"] = "\
Returns whether or not the server is a dedicated server ";["private"] = false;["library"] = "game";["description"] = "\
Returns whether or not the server is a dedicated server";["param"] = {}; };["getHostname"] = { ["class"] = "function";["fname"] = "getHostname";["realm"] = "sh";["name"] = "game_lib.getHostname";["summary"] = "\
Returns The hostname ";["private"] = false;["library"] = "game";["description"] = "\
Returns The hostname";["param"] = {}; }; };["class"] = "library";["summary"] = "\
Game functions ";["fields"] = {};["name"] = "game";["client"] = true;["description"] = "\
Game functions";["libtbl"] = "game_lib";["tables"] = {};["server"] = true; };["net"] = { ["functions"] = { [1] = "getBytesLeft";[2] = "isStreaming";[3] = "readAngle";[4] = "readBit";[5] = "readColor";[6] = "readData";[7] = "readDouble";[8] = "readEntity";[9] = "readFloat";[10] = "readInt";[11] = "readMatrix";[12] = "readStream";[13] = "readString";[14] = "readUInt";[15] = "readVector";[16] = "send";[17] = "start";[18] = "writeAngle";[19] = "writeBit";[20] = "writeColor";[21] = "writeData";[22] = "writeDouble";[23] = "writeEntity";[24] = "writeFloat";[25] = "writeInt";[26] = "writeMatrix";[27] = "writeStream";[28] = "writeString";[29] = "writeUInt";[30] = "writeVector";["writeVector"] = { ["class"] = "function";["realm"] = "sh";["summary"] = "\
Writes an vector to the net message ";["fname"] = "writeVector";["library"] = "net";["name"] = "net_library.writeVector";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Writes an vector to the net message";["param"] = { [1] = "t";["t"] = "The vector to be written"; }; };["readColor"] = { ["ret"] = "The color that was read";["class"] = "function";["realm"] = "sh";["summary"] = "\
Reads a color from the net message ";["fname"] = "readColor";["library"] = "net";["name"] = "net_library.readColor";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Reads a color from the net message";["param"] = {}; };["readDouble"] = { ["ret"] = "The double that was read";["class"] = "function";["realm"] = "sh";["summary"] = "\
Reads a double from the net message ";["fname"] = "readDouble";["library"] = "net";["name"] = "net_library.readDouble";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Reads a double from the net message";["param"] = {}; };["send"] = { ["class"] = "function";["realm"] = "sh";["summary"] = "\
Send a net message from client->server, or server->client.";["fname"] = "send";["library"] = "net";["name"] = "net_library.send";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Send a net message from client->server, or server->client.";["param"] = { [1] = "target";[2] = "unreliable";["unreliable"] = "Optional choose whether it's more important for the message to actually reach its destination (false) or reach it as fast as possible (true).";["target"] = "Optional target location to send the net message."; }; };["writeAngle"] = { ["class"] = "function";["realm"] = "sh";["summary"] = "\
Writes an angle to the net message ";["fname"] = "writeAngle";["library"] = "net";["name"] = "net_library.writeAngle";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Writes an angle to the net message";["param"] = { [1] = "t";["t"] = "The angle to be written"; }; };["writeStream"] = { ["class"] = "function";["realm"] = "sh";["summary"] = "\
Streams a large 20MB string.";["fname"] = "writeStream";["library"] = "net";["name"] = "net_library.writeStream";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Streams a large 20MB string.";["param"] = { [1] = "str";["str"] = "The string to be written"; }; };["readFloat"] = { ["ret"] = "The float that was read";["class"] = "function";["realm"] = "sh";["summary"] = "\
Reads a float from the net message ";["fname"] = "readFloat";["library"] = "net";["name"] = "net_library.readFloat";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Reads a float from the net message";["param"] = {}; };["writeBit"] = { ["class"] = "function";["realm"] = "sh";["summary"] = "\
Writes a bit to the net message ";["fname"] = "writeBit";["library"] = "net";["name"] = "net_library.writeBit";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Writes a bit to the net message";["param"] = { [1] = "t";["t"] = "The bit to be written. (boolean)"; }; };["writeMatrix"] = { ["class"] = "function";["realm"] = "sh";["summary"] = "\
Writes an matrix to the net message ";["fname"] = "writeMatrix";["library"] = "net";["name"] = "net_library.writeMatrix";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Writes an matrix to the net message";["param"] = { [1] = "t";["t"] = "The matrix to be written"; }; };["isStreaming"] = { ["ret"] = "Boolean";["class"] = "function";["fname"] = "isStreaming";["realm"] = "sh";["name"] = "net_library.isStreaming";["summary"] = "\
Returns whether or not the library is currently reading data from a stream ";["private"] = false;["library"] = "net";["description"] = "\
Returns whether or not the library is currently reading data from a stream";["param"] = {}; };["readUInt"] = { ["ret"] = "The unsigned integer that was read";["class"] = "function";["realm"] = "sh";["summary"] = "\
Reads an unsigned integer from the net message ";["fname"] = "readUInt";["library"] = "net";["name"] = "net_library.readUInt";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Reads an unsigned integer from the net message";["param"] = { [1] = "n";["n"] = "The amount of bits to read"; }; };["readBit"] = { ["ret"] = "The bit that was read. (0 for false, 1 for true)";["class"] = "function";["realm"] = "sh";["summary"] = "\
Reads a bit from the net message ";["fname"] = "readBit";["library"] = "net";["name"] = "net_library.readBit";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Reads a bit from the net message";["param"] = {}; };["getBytesLeft"] = { ["ret"] = "number of bytes that can be sent";["class"] = "function";["fname"] = "getBytesLeft";["realm"] = "sh";["name"] = "net_library.getBytesLeft";["summary"] = "\
Returns available bandwidth in bytes ";["private"] = false;["library"] = "net";["description"] = "\
Returns available bandwidth in bytes";["param"] = {}; };["readEntity"] = { ["ret"] = "The entity that was read";["class"] = "function";["realm"] = "sh";["summary"] = "\
Reads a entity from the net message ";["fname"] = "readEntity";["library"] = "net";["name"] = "net_library.readEntity";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Reads a entity from the net message";["param"] = {}; };["writeEntity"] = { ["class"] = "function";["realm"] = "sh";["summary"] = "\
Writes an entity to the net message ";["fname"] = "writeEntity";["library"] = "net";["name"] = "net_library.writeEntity";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Writes an entity to the net message";["param"] = { [1] = "t";["t"] = "The entity to be written"; }; };["readString"] = { ["ret"] = "The string that was read";["class"] = "function";["realm"] = "sh";["summary"] = "\
Reads a string from the net message ";["fname"] = "readString";["library"] = "net";["name"] = "net_library.readString";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Reads a string from the net message";["param"] = {}; };["writeColor"] = { ["class"] = "function";["realm"] = "sh";["summary"] = "\
Writes an color to the net message ";["fname"] = "writeColor";["library"] = "net";["name"] = "net_library.writeColor";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Writes an color to the net message";["param"] = { [1] = "t";["t"] = "The color to be written"; }; };["readInt"] = { ["ret"] = "The integer that was read";["class"] = "function";["realm"] = "sh";["summary"] = "\
Reads an integer from the net message ";["fname"] = "readInt";["library"] = "net";["name"] = "net_library.readInt";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Reads an integer from the net message";["param"] = { [1] = "n";["n"] = "The amount of bits to read"; }; };["writeInt"] = { ["class"] = "function";["realm"] = "sh";["summary"] = "\
Writes an integer to the net message ";["fname"] = "writeInt";["library"] = "net";["name"] = "net_library.writeInt";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Writes an integer to the net message";["param"] = { [1] = "t";[2] = "n";["t"] = "The integer to be written";["n"] = "The amount of bits the integer consists of"; }; };["readVector"] = { ["ret"] = "The vector that was read";["class"] = "function";["realm"] = "sh";["summary"] = "\
Reads a vector from the net message ";["fname"] = "readVector";["library"] = "net";["name"] = "net_library.readVector";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Reads a vector from the net message";["param"] = {}; };["readStream"] = { ["class"] = "function";["realm"] = "sh";["summary"] = "\
Reads a large string stream from the net message ";["fname"] = "readStream";["library"] = "net";["name"] = "net_library.readStream";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Reads a large string stream from the net message";["param"] = { [1] = "cb";["cb"] = "Callback to run when the stream is finished. The first parameter in the callback is the data."; }; };["writeString"] = { ["class"] = "function";["realm"] = "sh";["summary"] = "\
Writes a string to the net message.";["fname"] = "writeString";["library"] = "net";["name"] = "net_library.writeString";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Writes a string to the net message. Null characters will terminate the string.";["param"] = { [1] = "t";["t"] = "The string to be written"; }; };["readAngle"] = { ["ret"] = "The angle that was read";["class"] = "function";["realm"] = "sh";["summary"] = "\
Reads an angle from the net message ";["fname"] = "readAngle";["library"] = "net";["name"] = "net_library.readAngle";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Reads an angle from the net message";["param"] = {}; };["writeUInt"] = { ["class"] = "function";["realm"] = "sh";["summary"] = "\
Writes an unsigned integer to the net message ";["fname"] = "writeUInt";["library"] = "net";["name"] = "net_library.writeUInt";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Writes an unsigned integer to the net message";["param"] = { [1] = "t";[2] = "n";["t"] = "The integer to be written";["n"] = "The amount of bits the integer consists of. Should not be greater than 32"; }; };["writeFloat"] = { ["class"] = "function";["realm"] = "sh";["summary"] = "\
Writes a float to the net message ";["fname"] = "writeFloat";["library"] = "net";["name"] = "net_library.writeFloat";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Writes a float to the net message";["param"] = { [1] = "t";["t"] = "The float to be written"; }; };["writeDouble"] = { ["class"] = "function";["realm"] = "sh";["summary"] = "\
Writes a double to the net message ";["fname"] = "writeDouble";["library"] = "net";["name"] = "net_library.writeDouble";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Writes a double to the net message";["param"] = { [1] = "t";["t"] = "The double to be written"; }; };["start"] = { ["class"] = "function";["realm"] = "sh";["summary"] = "\
Starts the net message ";["fname"] = "start";["library"] = "net";["name"] = "net_library.start";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Starts the net message";["param"] = { [1] = "name";["name"] = "The message name"; }; };["writeData"] = { ["class"] = "function";["realm"] = "sh";["summary"] = "\
Writes string containing null characters to the net message ";["fname"] = "writeData";["library"] = "net";["name"] = "net_library.writeData";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Writes string containing null characters to the net message";["param"] = { [1] = "t";[2] = "n";["t"] = "The string to be written";["n"] = "How much of the string to write"; }; };["readData"] = { ["ret"] = "The string that was read";["class"] = "function";["realm"] = "sh";["summary"] = "\
Reads a string from the net message ";["fname"] = "readData";["library"] = "net";["name"] = "net_library.readData";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Reads a string from the net message";["param"] = { [1] = "n";["n"] = "How many characters are in the data"; }; };["readMatrix"] = { ["ret"] = "The matrix that was read";["class"] = "function";["realm"] = "sh";["summary"] = "\
Reads a matrix from the net message ";["fname"] = "readMatrix";["library"] = "net";["name"] = "net_library.readMatrix";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Reads a matrix from the net message";["param"] = {}; }; };["class"] = "library";["fields"] = {};["name"] = "net";["summary"] = "\
Net message library.";["description"] = "\
Net message library. Used for sending data from the server to the client and back";["libtbl"] = "net_library";["tables"] = {}; };["von"] = { ["functions"] = { [1] = "deserialize";[2] = "serialize";["serialize"] = { ["ret"] = "String";["description"] = "\
Serialize a table";["class"] = "function";["realm"] = "sh";["summary"] = "\
Serialize a table ";["classForced"] = true;["fname"] = "serialize";["name"] = "von.serialize";["library"] = "von";["client"] = true;["server"] = true;["param"] = { [1] = "tbl";["tbl"] = "Table to serialize"; }; };["deserialize"] = { ["ret"] = "Table";["description"] = "\
Deserialize a string";["class"] = "function";["realm"] = "sh";["summary"] = "\
Deserialize a string ";["classForced"] = true;["fname"] = "deserialize";["name"] = "von.deserialize";["library"] = "von";["client"] = true;["server"] = true;["param"] = { [1] = "str";["str"] = "String to deserialize"; }; }; };["class"] = "library";["summary"] = "\
vON Library ";["fields"] = {};["name"] = "von";["client"] = true;["description"] = "\
vON Library";["libtbl"] = "von";["tables"] = {};["server"] = true; };["builtin"] = { ["description"] = "\
Built in values. These don't need to be loaded; they are in the default environment.";["class"] = "library";["summary"] = "\
Built in values.";["tables"] = { [1] = "bit";[2] = "math";[3] = "os";[4] = "string";[5] = "table";["string"] = { ["description"] = "\
String library http://wiki.garrysmod.com/page/Category:string";["class"] = "table";["classForced"] = true;["name"] = "SF.DefaultEnvironment.string";["summary"] = "\
String library http://wiki.garrysmod.com/page/Category:string ";["library"] = "builtin";["param"] = {}; };["os"] = { ["description"] = "\
The os library. http://wiki.garrysmod.com/page/Category:os";["class"] = "table";["classForced"] = true;["name"] = "SF.DefaultEnvironment.os";["summary"] = "\
The os library.";["library"] = "builtin";["param"] = {}; };["table"] = { ["description"] = "\
Table library. http://wiki.garrysmod.com/page/Category:table";["class"] = "table";["classForced"] = true;["name"] = "SF.DefaultEnvironment.table";["summary"] = "\
Table library.";["library"] = "builtin";["param"] = {}; };["math"] = { ["description"] = "\
The math library. http://wiki.garrysmod.com/page/Category:math";["class"] = "table";["classForced"] = true;["name"] = "SF.DefaultEnvironment.math";["summary"] = "\
The math library.";["library"] = "builtin";["param"] = {}; };["bit"] = { ["description"] = "\
Bit library. http://wiki.garrysmod.com/page/Category:bit";["class"] = "table";["classForced"] = true;["name"] = "SF.DefaultEnvironment.bit";["summary"] = "\
Bit library.";["library"] = "builtin";["param"] = {}; }; };["classForced"] = true;["fields"] = { [1] = "CLIENT";[2] = "SERVER";["CLIENT"] = { ["description"] = "\
Constant that denotes whether the code is executed on the client";["class"] = "field";["classForced"] = true;["name"] = "SF.DefaultEnvironment.CLIENT";["summary"] = "\
Constant that denotes whether the code is executed on the client ";["library"] = "builtin";["param"] = {}; };["SERVER"] = { ["description"] = "\
Constant that denotes whether the code is executed on the server";["class"] = "field";["classForced"] = true;["name"] = "SF.DefaultEnvironment.SERVER";["summary"] = "\
Constant that denotes whether the code is executed on the server ";["library"] = "builtin";["param"] = {}; }; };["name"] = "builtin";["functions"] = { [1] = "assert";[2] = "chip";[3] = "concmd";[4] = "crc";[5] = "debugGetInfo";[6] = "dodir";[7] = "dofile";[8] = "entity";[9] = "error";[10] = "eyeAngles";[11] = "eyePos";[12] = "eyeVector";[13] = "getLibraries";[14] = "getUserdata";[15] = "getfenv";[16] = "getmetatable";[17] = "hasPermission";[18] = "ipairs";[19] = "isValid";[20] = "loadstring";[21] = "next";[22] = "owner";[23] = "pairs";[24] = "pcall";[25] = "player";[26] = "printMessage";[27] = "printTable";[28] = "quotaAverage";[29] = "quotaMax";[30] = "quotaTotalAverage";[31] = "quotaTotalUsed";[32] = "quotaUsed";[33] = "rawget";[34] = "rawset";[35] = "require";[36] = "requiredir";[37] = "select";[38] = "setClipboardText";[39] = "setName";[40] = "setSoftQuota";[41] = "setUserdata";[42] = "setfenv";[43] = "setmetatable";[44] = "throw";[45] = "tonumber";[46] = "tostring";[47] = "try";[48] = "type";[49] = "unpack";[50] = "xpcall";["xpcall"] = { ["ret"] = { [1] = "Status of the execution; true for success, false for failure.";[2] = "The returns of the first function if execution succeeded, otherwise the first return value of the error callback."; };["class"] = "function";["fname"] = "xpcall";["realm"] = "sh";["name"] = "SF.DefaultEnvironment.xpcall";["summary"] = "\
Lua's xpcall with SF throw implementation \
Attempts to call the first function.";["private"] = false;["library"] = "builtin";["description"] = "\
Lua's xpcall with SF throw implementation \
Attempts to call the first function. If the execution succeeds, this returns true followed by the returns of the function. \
If execution fails, this returns false and the second function is called with the error message.";["param"] = { [1] = "func";[2] = "callback";[3] = "...";[4] = "funcThe";[5] = "The";[6] = "arguments";["funcThe"] = "function to call initially.";["arguments"] = "Arguments to pass to the initial function.";["The"] = "function to be called if execution of the first fails; the error message is passed as a string."; }; };["chip"] = { ["ret"] = "Starfall entity";["description"] = "\
Returns the entity representing a processor that this script is running on.";["class"] = "function";["classForced"] = true;["realm"] = "sh";["name"] = "SF.DefaultEnvironment.chip";["summary"] = "\
Returns the entity representing a processor that this script is running on.";["fname"] = "chip";["library"] = "builtin";["param"] = {}; };["hasPermission"] = { ["class"] = "function";["fname"] = "hasPermission";["realm"] = "sh";["name"] = "SF.DefaultEnvironment.hasPermission";["summary"] = "\
Checks if the chip is capable of performing an action.";["private"] = false;["library"] = "builtin";["description"] = "\
Checks if the chip is capable of performing an action.";["param"] = { [1] = "perm";["perm"] = "The permission id to check"; }; };["tostring"] = { ["ret"] = "obj as string";["description"] = "\
Attempts to convert the value to a string.";["class"] = "function";["classForced"] = true;["realm"] = "sh";["name"] = "SF.DefaultEnvironment.tostring";["summary"] = "\
Attempts to convert the value to a string.";["fname"] = "tostring";["library"] = "builtin";["param"] = { [1] = "obj";["obj"] = ""; }; };["setClipboardText"] = { ["class"] = "function";["fname"] = "setClipboardText";["realm"] = "sh";["name"] = "SF.DefaultEnvironment.setClipboardText";["summary"] = "\
Sets clipboard text.";["private"] = false;["library"] = "builtin";["description"] = "\
Sets clipboard text. Only works on the owner of the chip.";["param"] = { [1] = "txt";["txt"] = "Text to set to the clipboard"; }; };["unpack"] = { ["ret"] = "Elements of tbl";["description"] = "\
This function takes a numeric indexed table and return all the members as a vararg.";["class"] = "function";["classForced"] = true;["realm"] = "sh";["name"] = "SF.DefaultEnvironment.unpack";["summary"] = "\
This function takes a numeric indexed table and return all the members as a vararg.";["fname"] = "unpack";["library"] = "builtin";["param"] = { [1] = "tbl";["tbl"] = ""; }; };["printMessage"] = { ["class"] = "function";["fname"] = "printMessage";["realm"] = "sh";["name"] = "SF.DefaultEnvironment.printMessage";["summary"] = "\
Prints a message to your chat, console, or the center of your screen.";["private"] = false;["library"] = "builtin";["description"] = "\
Prints a message to your chat, console, or the center of your screen.";["param"] = { [1] = "mtype";[2] = "text";["text"] = "The message text.";["mtype"] = "How the message should be displayed. See http://wiki.garrysmod.com/page/Enums/HUD"; }; };["quotaUsed"] = { ["ret"] = "Current quota used this Think";["class"] = "function";["fname"] = "quotaUsed";["realm"] = "sh";["name"] = "SF.DefaultEnvironment.quotaUsed";["summary"] = "\
Returns the current count for this Think's CPU Time.";["private"] = false;["library"] = "builtin";["description"] = "\
Returns the current count for this Think's CPU Time. \
This value increases as more executions are done, may not be exactly as you want. \
If used on screens, will show 0 if only rendering is done. Operations must be done in the Think loop for them to be counted.";["param"] = {}; };["isValid"] = { ["ret"] = "If it is valid";["class"] = "function";["fname"] = "isValid";["realm"] = "sh";["name"] = "SF.DefaultEnvironment.isValid";["summary"] = "\
Returns if the table has an isValid function and isValid returns true.";["private"] = false;["library"] = "builtin";["description"] = "\
Returns if the table has an isValid function and isValid returns true.";["param"] = { [1] = "object";["object"] = "Table to check"; }; };["pairs"] = { ["ret"] = { [1] = "Iterator function";[2] = "Table tbl";[3] = "nil as current index"; };["description"] = "\
Returns an iterator function for a for loop that will return the values of the specified table in an arbitrary order.";["class"] = "function";["classForced"] = true;["realm"] = "sh";["name"] = "SF.DefaultEnvironment.pairs";["summary"] = "\
Returns an iterator function for a for loop that will return the values of the specified table in an arbitrary order.";["fname"] = "pairs";["library"] = "builtin";["param"] = { [1] = "tbl";["tbl"] = "Table to iterate over"; }; };["next"] = { ["ret"] = { [1] = "Key or nil";[2] = "Value or nil"; };["description"] = "\
Returns the next key and value pair in a table.";["class"] = "function";["classForced"] = true;["realm"] = "sh";["name"] = "SF.DefaultEnvironment.next";["summary"] = "\
Returns the next key and value pair in a table.";["fname"] = "next";["library"] = "builtin";["param"] = { [1] = "tbl";[2] = "k";["tbl"] = "Table to get the next key-value pair of";["k"] = "Previous key (can be nil)"; }; };["assert"] = { ["class"] = "function";["realm"] = "sh";["classForced"] = true;["summary"] = "\
If the result of the first argument is false or nil, an error is thrown with the second argument as the message.";["name"] = "SF.DefaultEnvironment.assert";["fname"] = "assert";["private"] = false;["library"] = "builtin";["description"] = "\
If the result of the first argument is false or nil, an error is thrown with the second argument as the message.";["param"] = { [1] = "condition";[2] = "msg";["msg"] = "";["condition"] = ""; }; };["eyePos"] = { ["ret"] = "The local player's camera position";["class"] = "function";["fname"] = "eyePos";["realm"] = "sh";["name"] = "SF.DefaultEnvironment.eyePos";["summary"] = "\
Returns the local player's camera position ";["private"] = false;["library"] = "builtin";["description"] = "\
Returns the local player's camera position";["param"] = {}; };["ipairs"] = { ["ret"] = { [1] = "Iterator function";[2] = "Table tbl";[3] = "0 as current index"; };["description"] = "\
Returns an iterator function for a for loop, to return ordered key-value pairs from a table.";["class"] = "function";["classForced"] = true;["realm"] = "sh";["name"] = "SF.DefaultEnvironment.ipairs";["summary"] = "\
Returns an iterator function for a for loop, to return ordered key-value pairs from a table.";["fname"] = "ipairs";["library"] = "builtin";["param"] = { [1] = "tbl";["tbl"] = "Table to iterate over"; }; };["player"] = { ["ret"] = "Returns player with given UserID or if none specified then returns either the owner (server) or the local player (client)";["description"] = "\
Same as owner() on the server. On the client, returns the local player";["class"] = "function";["classForced"] = true;["realm"] = "sh";["name"] = "SF.DefaultEnvironment.player";["summary"] = "\
Same as owner() on the server.";["fname"] = "player";["library"] = "builtin";["param"] = {}; };["quotaTotalAverage"] = { ["ret"] = "Total average CPU Time of all your chips.";["class"] = "function";["fname"] = "quotaTotalAverage";["realm"] = "sh";["name"] = "SF.DefaultEnvironment.quotaTotalAverage";["summary"] = "\
Returns the total average time for all chips by the player.";["private"] = false;["library"] = "builtin";["description"] = "\
Returns the total average time for all chips by the player.";["param"] = {}; };["throw"] = { ["class"] = "function";["fname"] = "throw";["realm"] = "sh";["name"] = "SF.DefaultEnvironment.throw";["summary"] = "\
Throws an exception ";["private"] = false;["library"] = "builtin";["description"] = "\
Throws an exception";["param"] = { [1] = "msg";[2] = "level";[3] = "uncatchable";["msg"] = "Message string";["uncatchable"] = "Makes this exception uncatchable";["level"] = "Which level in the stacktrace to blame. Defaults to 1"; }; };["quotaMax"] = { ["ret"] = "Max SysTime allowed to take for execution of the chip in a Think.";["class"] = "function";["fname"] = "quotaMax";["realm"] = "sh";["name"] = "SF.DefaultEnvironment.quotaMax";["summary"] = "\
Gets the CPU Time max.";["private"] = false;["library"] = "builtin";["description"] = "\
Gets the CPU Time max. \
CPU Time is stored in a buffer of N elements, if the average of this exceeds quotaMax, the chip will error.";["param"] = {}; };["getmetatable"] = { ["ret"] = "The metatable of tbl";["class"] = "function";["fname"] = "getmetatable";["realm"] = "sh";["name"] = "SF.DefaultEnvironment.getmetatable";["summary"] = "\
Returns the metatable of an object.";["private"] = false;["library"] = "builtin";["description"] = "\
Returns the metatable of an object. Doesn't work on most internal metatables";["param"] = { [1] = "tbl";["tbl"] = "Table to get metatable of"; }; };["concmd"] = { ["class"] = "function";["realm"] = "sh";["summary"] = "\
Execute a console command ";["fname"] = "concmd";["library"] = "builtin";["name"] = "SF.DefaultEnvironment.concmd";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Execute a console command";["param"] = { [1] = "cmd";["cmd"] = "Command to execute"; }; };["getLibraries"] = { ["ret"] = "Table containing the names of each available library";["class"] = "function";["fname"] = "getLibraries";["realm"] = "sh";["name"] = "SF.DefaultEnvironment.getLibraries";["summary"] = "\
Gets a list of all libraries ";["private"] = false;["library"] = "builtin";["description"] = "\
Gets a list of all libraries";["param"] = {}; };["debugGetInfo"] = { ["ret"] = "DebugInfo table";["class"] = "function";["fname"] = "debugGetInfo";["realm"] = "sh";["name"] = "SF.DefaultEnvironment.debugGetInfo";["summary"] = "\
GLua's getinfo() \
Returns a DebugInfo structure containing the passed function's info (https://wiki.garrysmod.com/page/Structures/DebugInfo) ";["private"] = false;["library"] = "builtin";["description"] = "\
GLua's getinfo() \
Returns a DebugInfo structure containing the passed function's info (https://wiki.garrysmod.com/page/Structures/DebugInfo)";["param"] = { [1] = "funcOrStackLevel";[2] = "fields";["fields"] = "A string that specifies the information to be retrieved. Defaults to all (flnSu).";["funcOrStackLevel"] = "Function or stack level to get info about. Defaults to stack level 0."; }; };["crc"] = { ["ret"] = "The unsigned 32 bit checksum as a string";["description"] = "\
Generates the CRC checksum of the specified string. (https://en.wikipedia.org/wiki/Cyclic_redundancy_check)";["class"] = "function";["classForced"] = true;["realm"] = "sh";["name"] = "SF.DefaultEnvironment.crc";["summary"] = "\
Generates the CRC checksum of the specified string.";["fname"] = "crc";["library"] = "builtin";["param"] = { [1] = "stringToHash";["stringToHash"] = "The string to calculate the checksum of"; }; };["rawset"] = { ["class"] = "function";["fname"] = "rawset";["realm"] = "sh";["name"] = "SF.DefaultEnvironment.rawset";["summary"] = "\
Set the value of a table index without invoking a metamethod ";["private"] = false;["library"] = "builtin";["description"] = "\
Set the value of a table index without invoking a metamethod";["param"] = { [1] = "table";[2] = "key";[3] = "value";["value"] = "The value to set the index equal to";["key"] = "The index of the table";["table"] = "The table to modify"; }; };["dodir"] = { ["ret"] = "Table of return values of the scripts";["class"] = "function";["fname"] = "dodir";["realm"] = "sh";["name"] = "SF.DefaultEnvironment.dodir";["summary"] = "\
Runs an included directory, but does not cache the result.";["private"] = false;["library"] = "builtin";["description"] = "\
Runs an included directory, but does not cache the result.";["param"] = { [1] = "dir";[2] = "loadpriority";["loadpriority"] = "Table of files that should be loaded before any others in the directory";["dir"] = "The directory to include. Make sure to --@includedir it"; }; };["eyeAngles"] = { ["ret"] = "The local player's camera angles";["class"] = "function";["fname"] = "eyeAngles";["realm"] = "sh";["name"] = "SF.DefaultEnvironment.eyeAngles";["summary"] = "\
Returns the local player's camera angles ";["private"] = false;["library"] = "builtin";["description"] = "\
Returns the local player's camera angles";["param"] = {}; };["requiredir"] = { ["ret"] = "Table of return values of the scripts";["class"] = "function";["fname"] = "requiredir";["realm"] = "sh";["name"] = "SF.DefaultEnvironment.requiredir";["summary"] = "\
Runs an included script and caches the result.";["private"] = false;["library"] = "builtin";["description"] = "\
Runs an included script and caches the result. \
Works pretty much like standard Lua require()";["param"] = { [1] = "dir";[2] = "loadpriority";["loadpriority"] = "Table of files that should be loaded before any others in the directory";["dir"] = "The directory to include. Make sure to --@includedir it"; }; };["getfenv"] = { ["ret"] = "Current environment";["class"] = "function";["fname"] = "getfenv";["realm"] = "sh";["name"] = "SF.DefaultEnvironment.getfenv";["summary"] = "\
Simple version of Lua's getfenv \
Returns the current environment ";["private"] = false;["library"] = "builtin";["description"] = "\
Simple version of Lua's getfenv \
Returns the current environment";["param"] = {}; };["setfenv"] = { ["ret"] = "func with environment set to tbl";["class"] = "function";["fname"] = "setfenv";["realm"] = "sh";["name"] = "SF.DefaultEnvironment.setfenv";["summary"] = "\
Lua's setfenv \
Works like setfenv, but is restricted on functions ";["private"] = false;["library"] = "builtin";["description"] = "\
Lua's setfenv \
Works like setfenv, but is restricted on functions";["param"] = { [1] = "func";[2] = "tbl";["tbl"] = "New environment";["func"] = "Function to change environment of"; }; };["printTable"] = { ["class"] = "function";["fname"] = "printTable";["realm"] = "sh";["name"] = "SF.DefaultEnvironment.printTable";["summary"] = "\
Prints a table to player's chat ";["private"] = false;["library"] = "builtin";["description"] = "\
Prints a table to player's chat";["param"] = { [1] = "tbl";["tbl"] = "Table to print"; }; };["entity"] = { ["ret"] = "entity";["description"] = "\
Returns the entity with index 'num'";["class"] = "function";["classForced"] = true;["realm"] = "sh";["name"] = "SF.DefaultEnvironment.entity";["summary"] = "\
Returns the entity with index 'num' ";["fname"] = "entity";["library"] = "builtin";["param"] = { [1] = "num";["num"] = "Entity index"; }; };["tonumber"] = { ["ret"] = "obj as number";["description"] = "\
Attempts to convert the value to a number.";["class"] = "function";["classForced"] = true;["realm"] = "sh";["name"] = "SF.DefaultEnvironment.tonumber";["summary"] = "\
Attempts to convert the value to a number.";["fname"] = "tonumber";["library"] = "builtin";["param"] = { [1] = "obj";["obj"] = ""; }; };["pcall"] = { ["ret"] = { [1] = "If the function had no errors occur within it.";[2] = "If an error occurred, this will be a string containing the error message. Otherwise, this will be the return values of the function passed in."; };["class"] = "function";["fname"] = "pcall";["realm"] = "sh";["name"] = "SF.DefaultEnvironment.pcall";["summary"] = "\
Lua's pcall with SF throw implementation \
Calls a function and catches an error that can be thrown while the execution of the call.";["private"] = false;["library"] = "builtin";["description"] = "\
Lua's pcall with SF throw implementation \
Calls a function and catches an error that can be thrown while the execution of the call.";["param"] = { [1] = "func";[2] = "...";[3] = "arguments";["arguments"] = "Arguments to call the function with.";["func"] = "Function to be executed and of which the errors should be caught of"; }; };["require"] = { ["ret"] = "Return value of the script";["class"] = "function";["fname"] = "require";["realm"] = "sh";["name"] = "SF.DefaultEnvironment.require";["summary"] = "\
Runs an included script and caches the result.";["private"] = false;["library"] = "builtin";["description"] = "\
Runs an included script and caches the result. \
Works pretty much like standard Lua require()";["param"] = { [1] = "file";["file"] = "The file to include. Make sure to --@include it"; }; };["eyeVector"] = { ["ret"] = "The local player's camera forward vector";["class"] = "function";["fname"] = "eyeVector";["realm"] = "sh";["name"] = "SF.DefaultEnvironment.eyeVector";["summary"] = "\
Returns the local player's camera forward vector ";["private"] = false;["library"] = "builtin";["description"] = "\
Returns the local player's camera forward vector";["param"] = {}; };["type"] = { ["ret"] = "The name of the object's type.";["class"] = "function";["realm"] = "sh";["classForced"] = true;["summary"] = "\
Returns a string representing the name of the type of the passed object.";["name"] = "SF.DefaultEnvironment.type";["fname"] = "type";["private"] = false;["library"] = "builtin";["description"] = "\
Returns a string representing the name of the type of the passed object.";["param"] = { [1] = "obj";["obj"] = "Object to get type of"; }; };["try"] = { ["class"] = "function";["fname"] = "try";["realm"] = "sh";["name"] = "SF.DefaultEnvironment.try";["summary"] = "\
Try to execute a function and catch possible exceptions \
Similar to xpcall, but a bit more in-depth ";["private"] = false;["library"] = "builtin";["description"] = "\
Try to execute a function and catch possible exceptions \
Similar to xpcall, but a bit more in-depth";["param"] = { [1] = "func";[2] = "catch";["catch"] = "Optional function to execute in case func fails";["func"] = "Function to execute"; }; };["getUserdata"] = { ["ret"] = "String data";["class"] = "function";["realm"] = "sh";["fname"] = "getUserdata";["summary"] = "\
Gets the chip's userdata that the duplicator tool loads ";["name"] = "SF.DefaultEnvironment.getUserdata";["library"] = "builtin";["private"] = false;["server"] = true;["description"] = "\
Gets the chip's userdata that the duplicator tool loads";["param"] = {}; };["select"] = { ["ret"] = "Returns a number or vararg, depending on the select method.";["description"] = "\
Used to select single values from a vararg or get the count of values in it.";["class"] = "function";["classForced"] = true;["realm"] = "sh";["name"] = "SF.DefaultEnvironment.select";["summary"] = "\
Used to select single values from a vararg or get the count of values in it.";["fname"] = "select";["library"] = "builtin";["param"] = { [1] = "parameter";[2] = "vararg";["parameter"] = "";["vararg"] = ""; }; };["owner"] = { ["ret"] = "Owner entity";["description"] = "\
Returns whoever created the chip";["class"] = "function";["classForced"] = true;["realm"] = "sh";["name"] = "SF.DefaultEnvironment.owner";["summary"] = "\
Returns whoever created the chip ";["fname"] = "owner";["library"] = "builtin";["param"] = {}; };["setUserdata"] = { ["class"] = "function";["realm"] = "sh";["fname"] = "setUserdata";["summary"] = "\
Sets the chip's userdata that the duplicator tool saves.";["name"] = "SF.DefaultEnvironment.setUserdata";["library"] = "builtin";["private"] = false;["server"] = true;["description"] = "\
Sets the chip's userdata that the duplicator tool saves. max 1MiB";["param"] = { [1] = "str";["str"] = "String data"; }; };["quotaAverage"] = { ["ret"] = "Average CPU Time of the buffer.";["class"] = "function";["fname"] = "quotaAverage";["realm"] = "sh";["name"] = "SF.DefaultEnvironment.quotaAverage";["summary"] = "\
Gets the Average CPU Time in the buffer ";["private"] = false;["library"] = "builtin";["description"] = "\
Gets the Average CPU Time in the buffer";["param"] = {}; };["loadstring"] = { ["ret"] = "Function of str";["class"] = "function";["fname"] = "loadstring";["realm"] = "sh";["name"] = "SF.DefaultEnvironment.loadstring";["summary"] = "\
GLua's loadstring \
Works like loadstring, except that it executes by default in the main environment ";["private"] = false;["library"] = "builtin";["description"] = "\
GLua's loadstring \
Works like loadstring, except that it executes by default in the main environment";["param"] = { [1] = "str";[2] = "name";["str"] = "String to execute"; }; };["rawget"] = { ["ret"] = "The value of the index";["class"] = "function";["fname"] = "rawget";["realm"] = "sh";["name"] = "SF.DefaultEnvironment.rawget";["summary"] = "\
Gets the value of a table index without invoking a metamethod ";["private"] = false;["library"] = "builtin";["description"] = "\
Gets the value of a table index without invoking a metamethod";["param"] = { [1] = "table";[2] = "key";[3] = "value";["key"] = "The index of the table";["table"] = "The table to get the value from"; }; };["setName"] = { ["class"] = "function";["realm"] = "sh";["fname"] = "setName";["summary"] = "\
Sets the chip's display name ";["name"] = "SF.DefaultEnvironment.setName";["library"] = "builtin";["private"] = false;["client"] = true;["description"] = "\
Sets the chip's display name";["param"] = { [1] = "name";["name"] = "Name"; }; };["dofile"] = { ["ret"] = "Return value of the script";["class"] = "function";["fname"] = "dofile";["realm"] = "sh";["name"] = "SF.DefaultEnvironment.dofile";["summary"] = "\
Runs an included script, but does not cache the result.";["private"] = false;["library"] = "builtin";["description"] = "\
Runs an included script, but does not cache the result. \
Pretty much like standard Lua dofile()";["param"] = { [1] = "file";["file"] = "The file to include. Make sure to --@include it"; }; };["quotaTotalUsed"] = { ["ret"] = "Total used CPU time of all your chips.";["class"] = "function";["fname"] = "quotaTotalUsed";["realm"] = "sh";["name"] = "SF.DefaultEnvironment.quotaTotalUsed";["summary"] = "\
Returns the total used time for all chips by the player.";["private"] = false;["library"] = "builtin";["description"] = "\
Returns the total used time for all chips by the player.";["param"] = {}; };["setmetatable"] = { ["ret"] = "tbl with metatable set to meta";["description"] = "\
Sets, changes or removes a table's metatable. Doesn't work on most internal metatables";["class"] = "function";["classForced"] = true;["realm"] = "sh";["name"] = "SF.DefaultEnvironment.setmetatable";["summary"] = "\
Sets, changes or removes a table's metatable.";["fname"] = "setmetatable";["library"] = "builtin";["param"] = { [1] = "tbl";[2] = "meta";["meta"] = "The metatable to use";["tbl"] = "The table to set the metatable of"; }; };["error"] = { ["class"] = "function";["fname"] = "error";["realm"] = "sh";["name"] = "SF.DefaultEnvironment.error";["summary"] = "\
Throws a raw exception.";["private"] = false;["library"] = "builtin";["description"] = "\
Throws a raw exception.";["param"] = { [1] = "msg";[2] = "level";["level"] = "Which level in the stacktrace to blame. Defaults to 1";["msg"] = "Exception message"; }; };["setSoftQuota"] = { ["class"] = "function";["fname"] = "setSoftQuota";["realm"] = "sh";["name"] = "SF.DefaultEnvironment.setSoftQuota";["summary"] = "\
Sets a CPU soft quota which will trigger a catchable error if the cpu goes over a certain amount.";["private"] = false;["library"] = "builtin";["description"] = "\
Sets a CPU soft quota which will trigger a catchable error if the cpu goes over a certain amount.";["param"] = { [1] = "quota";["quota"] = "The threshold where the soft error will be thrown. Ratio of current cpu to the max cpu usage. 0.5 is 50%"; }; }; };["libtbl"] = "SF.DefaultEnvironment";["client"] = true;["server"] = true; };["timer"] = { ["functions"] = { [1] = "adjust";[2] = "create";[3] = "curtime";[4] = "exists";[5] = "frametime";[6] = "getTimersLeft";[7] = "pause";[8] = "realtime";[9] = "remove";[10] = "repsleft";[11] = "simple";[12] = "start";[13] = "stop";[14] = "systime";[15] = "timeleft";[16] = "toggle";[17] = "unpause";["getTimersLeft"] = { ["ret"] = "Number of available timers";["class"] = "function";["fname"] = "getTimersLeft";["realm"] = "sh";["name"] = "timer_library.getTimersLeft";["summary"] = "\
Returns number of available timers ";["private"] = false;["library"] = "timer";["description"] = "\
Returns number of available timers";["param"] = {}; };["frametime"] = { ["class"] = "function";["fname"] = "frametime";["realm"] = "sh";["name"] = "timer_library.frametime";["summary"] = "\
Returns time between frames on client and ticks on server.";["private"] = false;["library"] = "timer";["description"] = "\
Returns time between frames on client and ticks on server. Same thing as G.FrameTime in GLua";["param"] = {}; };["systime"] = { ["class"] = "function";["fname"] = "systime";["realm"] = "sh";["name"] = "timer_library.systime";["summary"] = "\
Returns a highly accurate time in seconds since the start up, ideal for benchmarking.";["private"] = false;["library"] = "timer";["description"] = "\
Returns a highly accurate time in seconds since the start up, ideal for benchmarking.";["param"] = {}; };["adjust"] = { ["ret"] = "true if succeeded";["class"] = "function";["fname"] = "adjust";["realm"] = "sh";["name"] = "timer_library.adjust";["summary"] = "\
Adjusts a timer ";["private"] = false;["library"] = "timer";["description"] = "\
Adjusts a timer";["param"] = { [1] = "name";[2] = "delay";[3] = "reps";[4] = "func";["name"] = "The timer name";["func"] = "The function to call when the tiemr is fired";["delay"] = "The time, in seconds, to set the timer to.";["reps"] = "The repititions of the tiemr. 0 = infinte, nil = 1"; }; };["remove"] = { ["class"] = "function";["fname"] = "remove";["realm"] = "sh";["name"] = "timer_library.remove";["summary"] = "\
Stops and removes the timer.";["private"] = false;["library"] = "timer";["description"] = "\
Stops and removes the timer.";["param"] = { [1] = "name";["name"] = "The timer name"; }; };["unpause"] = { ["ret"] = "false if the timer didn't exist or was already running, true otherwise.";["class"] = "function";["fname"] = "unpause";["realm"] = "sh";["name"] = "timer_library.unpause";["summary"] = "\
Unpauses a timer ";["private"] = false;["library"] = "timer";["description"] = "\
Unpauses a timer";["param"] = { [1] = "name";["name"] = "The timer name"; }; };["toggle"] = { ["ret"] = "status of the timer.";["class"] = "function";["fname"] = "toggle";["realm"] = "sh";["name"] = "timer_library.toggle";["summary"] = "\
Runs either timer.pause or timer.unpause based on the timer's current status.";["private"] = false;["library"] = "timer";["description"] = "\
Runs either timer.pause or timer.unpause based on the timer's current status.";["param"] = { [1] = "name";["name"] = "The timer name"; }; };["simple"] = { ["class"] = "function";["fname"] = "simple";["realm"] = "sh";["name"] = "timer_library.simple";["summary"] = "\
Creates a simple timer, has no name, can't be stopped, paused, or destroyed.";["private"] = false;["library"] = "timer";["description"] = "\
Creates a simple timer, has no name, can't be stopped, paused, or destroyed.";["param"] = { [1] = "delay";[2] = "func";["delay"] = "the time, in second, to set the timer to";["func"] = "the function to call when the timer is fired"; }; };["create"] = { ["class"] = "function";["fname"] = "create";["realm"] = "sh";["name"] = "timer_library.create";["summary"] = "\
Creates (and starts) a timer ";["private"] = false;["library"] = "timer";["description"] = "\
Creates (and starts) a timer";["param"] = { [1] = "name";[2] = "delay";[3] = "reps";[4] = "func";[5] = "simple";["name"] = "The timer name";["func"] = "The function to call when the timer is fired";["delay"] = "The time, in seconds, to set the timer to.";["reps"] = "The repititions of the tiemr. 0 = infinte, nil = 1"; }; };["timeleft"] = { ["ret"] = "The amount of time left (in seconds). If the timer is paused, the amount will be negative. Nil if timer doesnt exist";["class"] = "function";["fname"] = "timeleft";["realm"] = "sh";["name"] = "timer_library.timeleft";["summary"] = "\
Returns amount of time left (in seconds) before the timer executes its function.";["private"] = false;["library"] = "timer";["description"] = "\
Returns amount of time left (in seconds) before the timer executes its function.";["param"] = { [1] = "name";[2] = "The";["The"] = "timer name"; }; };["repsleft"] = { ["ret"] = "The amount of executions left. Nil if timer doesnt exist";["class"] = "function";["fname"] = "repsleft";["realm"] = "sh";["name"] = "timer_library.repsleft";["summary"] = "\
Returns amount of repetitions/executions left before the timer destroys itself.";["private"] = false;["library"] = "timer";["description"] = "\
Returns amount of repetitions/executions left before the timer destroys itself.";["param"] = { [1] = "name";[2] = "The";["The"] = "timer name"; }; };["exists"] = { ["ret"] = "bool if the timer exists";["class"] = "function";["fname"] = "exists";["realm"] = "sh";["name"] = "timer_library.exists";["summary"] = "\
Checks if a timer exists ";["private"] = false;["library"] = "timer";["description"] = "\
Checks if a timer exists";["param"] = { [1] = "name";["name"] = "The timer name"; }; };["stop"] = { ["ret"] = "false if the timer didn't exist or was already stopped, true otherwise.";["class"] = "function";["fname"] = "stop";["realm"] = "sh";["name"] = "timer_library.stop";["summary"] = "\
Stops a timer ";["private"] = false;["library"] = "timer";["description"] = "\
Stops a timer";["param"] = { [1] = "name";["name"] = "The timer name"; }; };["realtime"] = { ["class"] = "function";["fname"] = "realtime";["realm"] = "sh";["name"] = "timer_library.realtime";["summary"] = "\
Returns the uptime of the game/server in seconds (to at least 4 decimal places)";["private"] = false;["library"] = "timer";["description"] = "\
Returns the uptime of the game/server in seconds (to at least 4 decimal places)";["param"] = {}; };["curtime"] = { ["class"] = "function";["fname"] = "curtime";["realm"] = "sh";["name"] = "timer_library.curtime";["summary"] = "\
Returns the uptime of the server in seconds (to at least 4 decimal places)";["private"] = false;["library"] = "timer";["description"] = "\
Returns the uptime of the server in seconds (to at least 4 decimal places)";["param"] = {}; };["pause"] = { ["ret"] = "false if the timer didn't exist or was already paused, true otherwise.";["class"] = "function";["fname"] = "pause";["realm"] = "sh";["name"] = "timer_library.pause";["summary"] = "\
Pauses a timer ";["private"] = false;["library"] = "timer";["description"] = "\
Pauses a timer";["param"] = { [1] = "name";["name"] = "The timer name"; }; };["start"] = { ["ret"] = "true if the timer exists, false if it doesn't.";["class"] = "function";["fname"] = "start";["realm"] = "sh";["name"] = "timer_library.start";["summary"] = "\
Starts a timer ";["private"] = false;["library"] = "timer";["description"] = "\
Starts a timer";["param"] = { [1] = "name";["name"] = "The timer name"; }; }; };["class"] = "library";["summary"] = "\
Deals with time and timers.";["fields"] = {};["name"] = "timer";["client"] = true;["description"] = "\
Deals with time and timers.";["libtbl"] = "timer_library";["tables"] = {};["server"] = true; };["hook"] = { ["functions"] = { [1] = "add";[2] = "remove";[3] = "run";[4] = "runRemote";["remove"] = { ["class"] = "function";["realm"] = "sh";["summary"] = "\
Remove a hook ";["fname"] = "remove";["library"] = "hook";["name"] = "hook_library.remove";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Remove a hook";["param"] = { [1] = "hookname";[2] = "name";["name"] = "The unique name for this hook";["hookname"] = "The hook name"; }; };["runRemote"] = { ["ret"] = "tbl A list of the resultset of each called hook";["class"] = "function";["realm"] = "sh";["summary"] = "\
Run a hook remotely.";["fname"] = "runRemote";["library"] = "hook";["name"] = "hook_library.runRemote";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Run a hook remotely. \
This will call the hook \"remote\" on either a specified entity or all instances on the server/client";["param"] = { [1] = "recipient";[2] = "...";["recipient"] = "Starfall entity to call the hook on. Nil to run on every starfall entity";["..."] = "Payload. These parameters will be used to call the hook functions"; }; };["run"] = { ["class"] = "function";["realm"] = "sh";["summary"] = "\
Run a hook ";["fname"] = "run";["library"] = "hook";["name"] = "hook_library.run";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Run a hook";["param"] = { [1] = "hookname";[2] = "...";["..."] = "arguments";["hookname"] = "The hook name"; }; };["add"] = { ["class"] = "function";["fname"] = "add";["realm"] = "sh";["name"] = "hook_library.add";["summary"] = "\
Sets a hook function ";["private"] = false;["library"] = "hook";["description"] = "\
Sets a hook function";["param"] = { [1] = "hookname";[2] = "name";[3] = "func";["func"] = "Function to run";["name"] = "Unique identifier";["hookname"] = "Name of the event"; }; }; };["class"] = "library";["summary"] = "\
Deals with hooks ";["fields"] = {};["name"] = "hook";["client"] = true;["description"] = "\
Deals with hooks";["libtbl"] = "hook_library";["tables"] = {};["server"] = true; };["find"] = { ["functions"] = { [1] = "all";[2] = "allPlayers";[3] = "byClass";[4] = "byModel";[5] = "inBox";[6] = "inCone";[7] = "inSphere";["inBox"] = { ["ret"] = "An array of found entities";["class"] = "function";["fname"] = "inBox";["realm"] = "sh";["name"] = "find_library.inBox";["summary"] = "\
Finds entities in a box ";["private"] = false;["library"] = "find";["description"] = "\
Finds entities in a box";["param"] = { [1] = "min";[2] = "max";[3] = "filter";["min"] = "Bottom corner";["max"] = "Top corner";["filter"] = "Optional function to filter results"; }; };["inSphere"] = { ["ret"] = "An array of found entities";["class"] = "function";["fname"] = "inSphere";["realm"] = "sh";["name"] = "find_library.inSphere";["summary"] = "\
Finds entities in a sphere ";["private"] = false;["library"] = "find";["description"] = "\
Finds entities in a sphere";["param"] = { [1] = "center";[2] = "radius";[3] = "filter";["radius"] = "Sphere radius";["center"] = "Center of the sphere";["filter"] = "Optional function to filter results"; }; };["byClass"] = { ["ret"] = "An array of found entities";["class"] = "function";["fname"] = "byClass";["realm"] = "sh";["name"] = "find_library.byClass";["summary"] = "\
Finds entities by class name ";["private"] = false;["library"] = "find";["description"] = "\
Finds entities by class name";["param"] = { [1] = "class";[2] = "filter";["class"] = "The class name";["filter"] = "Optional function to filter results"; }; };["allPlayers"] = { ["ret"] = "An array of found entities";["class"] = "function";["fname"] = "allPlayers";["realm"] = "sh";["name"] = "find_library.allPlayers";["summary"] = "\
Finds all players (including bots) ";["private"] = false;["library"] = "find";["description"] = "\
Finds all players (including bots)";["param"] = { [1] = "filter";["filter"] = "Optional function to filter results"; }; };["all"] = { ["ret"] = "An array of found entities";["class"] = "function";["fname"] = "all";["realm"] = "sh";["name"] = "find_library.all";["summary"] = "\
Finds all entitites ";["private"] = false;["library"] = "find";["description"] = "\
Finds all entitites";["param"] = { [1] = "filter";["filter"] = "Optional function to filter results"; }; };["byModel"] = { ["ret"] = "An array of found entities";["class"] = "function";["fname"] = "byModel";["realm"] = "sh";["name"] = "find_library.byModel";["summary"] = "\
Finds entities by model ";["private"] = false;["library"] = "find";["description"] = "\
Finds entities by model";["param"] = { [1] = "model";[2] = "filter";["filter"] = "Optional function to filter results";["model"] = "The model file"; }; };["inCone"] = { ["ret"] = "An array of found entities";["class"] = "function";["fname"] = "inCone";["realm"] = "sh";["name"] = "find_library.inCone";["summary"] = "\
Finds entities in a cone ";["private"] = false;["library"] = "find";["description"] = "\
Finds entities in a cone";["param"] = { [1] = "pos";[2] = "dir";[3] = "distance";[4] = "radius";[5] = "filter";["radius"] = "The angle of the cone";["dir"] = "The direction to project the cone";["distance"] = "The length to project the cone";["filter"] = "Optional function to filter results";["pos"] = "The cone vertex position"; }; }; };["class"] = "library";["summary"] = "\
Find library.";["fields"] = {};["name"] = "find";["client"] = true;["description"] = "\
Find library. Finds entities in various shapes.";["libtbl"] = "find_library";["tables"] = {};["server"] = true; };["physenv"] = { ["functions"] = { [1] = "getAirDensity";[2] = "getGravity";[3] = "getPerformanceSettings";["getGravity"] = { ["ret"] = "Vector Gravity Vector ( eg Vector(0,0,-600) )";["class"] = "function";["fname"] = "getGravity";["realm"] = "sh";["name"] = "physenv_lib.getGravity";["summary"] = "\
Gets the gravity vector ";["private"] = false;["library"] = "physenv";["description"] = "\
Gets the gravity vector";["param"] = {}; };["getPerformanceSettings"] = { ["ret"] = "table Performance Settings Table.";["class"] = "function";["fname"] = "getPerformanceSettings";["realm"] = "sh";["name"] = "physenv_lib.getPerformanceSettings";["summary"] = "\
Gets the performance settings.</br> \
See <a href=\"http://wiki.garrysmod.com/page/Structures/PhysEnvPerformanceSettings\">PhysEnvPerformance Settings Table Structure</a> for table structure.";["private"] = false;["library"] = "physenv";["description"] = "\
Gets the performance settings.</br> \
See <a href=\"http://wiki.garrysmod.com/page/Structures/PhysEnvPerformanceSettings\">PhysEnvPerformance Settings Table Structure</a> for table structure.";["param"] = {}; };["getAirDensity"] = { ["ret"] = "number Air Density";["class"] = "function";["fname"] = "getAirDensity";["realm"] = "sh";["name"] = "physenv_lib.getAirDensity";["summary"] = "\
Gets the air density.";["private"] = false;["library"] = "physenv";["description"] = "\
Gets the air density.";["param"] = {}; }; };["class"] = "library";["summary"] = "\
Physenv functions ";["fields"] = {};["name"] = "physenv";["client"] = true;["description"] = "\
Physenv functions";["libtbl"] = "physenv_lib";["tables"] = {};["server"] = true; };["coroutine"] = { ["functions"] = { [1] = "create";[2] = "resume";[3] = "running";[4] = "status";[5] = "wait";[6] = "wrap";[7] = "yield";["resume"] = { ["ret"] = "Any values the coroutine is returning to the main thread";["class"] = "function";["fname"] = "resume";["realm"] = "sh";["name"] = "coroutine_library.resume";["summary"] = "\
Resumes a suspended coroutine.";["private"] = false;["library"] = "coroutine";["description"] = "\
Resumes a suspended coroutine. Note that, in contrast to Lua's native coroutine.resume function, it will not run in protected mode and can throw an error.";["param"] = { [1] = "thread";[2] = "...";["..."] = "optional parameters that will be passed to the coroutine";["thread"] = "coroutine to resume"; }; };["yield"] = { ["ret"] = "Any values passed to the coroutine";["class"] = "function";["fname"] = "yield";["realm"] = "sh";["name"] = "coroutine_library.yield";["summary"] = "\
Suspends the currently running coroutine.";["private"] = false;["library"] = "coroutine";["description"] = "\
Suspends the currently running coroutine. May not be called outside a coroutine.";["param"] = { [1] = "...";["..."] = "optional parameters that will be returned to the main thread"; }; };["running"] = { ["ret"] = "Currently running coroutine";["class"] = "function";["fname"] = "running";["realm"] = "sh";["name"] = "coroutine_library.running";["summary"] = "\
Returns the coroutine that is currently running.";["private"] = false;["library"] = "coroutine";["description"] = "\
Returns the coroutine that is currently running.";["param"] = {}; };["status"] = { ["ret"] = "Either \"suspended\", \"running\", \"normal\" or \"dead\"";["class"] = "function";["fname"] = "status";["realm"] = "sh";["name"] = "coroutine_library.status";["summary"] = "\
Returns the status of the coroutine.";["private"] = false;["library"] = "coroutine";["description"] = "\
Returns the status of the coroutine.";["param"] = { [1] = "thread";["thread"] = "The coroutine"; }; };["wrap"] = { ["ret"] = "A function that, when called, resumes the created coroutine. Any parameters to that function will be passed to the coroutine.";["class"] = "function";["fname"] = "wrap";["realm"] = "sh";["name"] = "coroutine_library.wrap";["summary"] = "\
Creates a new coroutine.";["private"] = false;["library"] = "coroutine";["description"] = "\
Creates a new coroutine.";["param"] = { [1] = "func";["func"] = "Function of the coroutine"; }; };["create"] = { ["ret"] = "coroutine";["class"] = "function";["fname"] = "create";["realm"] = "sh";["name"] = "coroutine_library.create";["summary"] = "\
Creates a new coroutine.";["private"] = false;["library"] = "coroutine";["description"] = "\
Creates a new coroutine.";["param"] = { [1] = "func";["func"] = "Function of the coroutine"; }; };["wait"] = { ["class"] = "function";["fname"] = "wait";["realm"] = "sh";["name"] = "coroutine_library.wait";["summary"] = "\
Suspends the coroutine for a number of seconds.";["private"] = false;["library"] = "coroutine";["description"] = "\
Suspends the coroutine for a number of seconds. Note that the coroutine will not resume automatically, but any attempts to resume the coroutine while it is waiting will not resume the coroutine and act as if the coroutine suspended itself immediately.";["param"] = { [1] = "time";["time"] = "Time in seconds to suspend the coroutine"; }; }; };["class"] = "library";["summary"] = "\
Coroutine library ";["fields"] = {};["name"] = "coroutine";["client"] = true;["description"] = "\
Coroutine library";["libtbl"] = "coroutine_library";["tables"] = {};["server"] = true; };["input"] = { ["functions"] = { [1] = "enableCursor";[2] = "getCursorPos";[3] = "getKeyName";[4] = "isControlDown";[5] = "isKeyDown";[6] = "isShiftDown";[7] = "lookupBinding";[8] = "screenToVector";["getCursorPos"] = { ["ret"] = { [1] = "The x position of the mouse";[2] = "The y position of the mouse"; };["class"] = "function";["fname"] = "getCursorPos";["realm"] = "sh";["name"] = "input_methods.getCursorPos";["summary"] = "\
Gets the position of the mouse ";["private"] = false;["library"] = "input";["description"] = "\
Gets the position of the mouse";["param"] = {}; };["lookupBinding"] = { ["ret"] = { [1] = "The id of the first key bound";[2] = "The name of the first key bound"; };["class"] = "function";["fname"] = "lookupBinding";["realm"] = "sh";["name"] = "input_methods.lookupBinding";["summary"] = "\
Gets the first key that is bound to the command passed ";["private"] = false;["library"] = "input";["description"] = "\
Gets the first key that is bound to the command passed";["param"] = { [1] = "binding";["binding"] = "The name of the bind"; }; };["getKeyName"] = { ["ret"] = "The name of the key";["class"] = "function";["fname"] = "getKeyName";["realm"] = "sh";["name"] = "input_methods.getKeyName";["summary"] = "\
Gets the name of a key from the id ";["private"] = false;["library"] = "input";["description"] = "\
Gets the name of a key from the id";["param"] = { [1] = "key";["key"] = "The key id, see input"; }; };["enableCursor"] = { ["class"] = "function";["fname"] = "enableCursor";["realm"] = "sh";["name"] = "input_methods.enableCursor";["summary"] = "\
Sets the state of the mouse cursor ";["private"] = false;["library"] = "input";["description"] = "\
Sets the state of the mouse cursor";["param"] = { [1] = "enabled";["enabled"] = "Whether or not the cursor should be enabled"; }; };["screenToVector"] = { ["ret"] = "Aim vector";["class"] = "function";["fname"] = "screenToVector";["realm"] = "sh";["name"] = "input_methods.screenToVector";["summary"] = "\
Translates position on player's screen to aim vector ";["private"] = false;["library"] = "input";["description"] = "\
Translates position on player's screen to aim vector";["param"] = { [1] = "x";[2] = "y";["y"] = "Y coordinate on the screen";["x"] = "X coordinate on the screen"; }; };["isShiftDown"] = { ["ret"] = "True if the shift key is down";["class"] = "function";["fname"] = "isShiftDown";["realm"] = "sh";["name"] = "input_methods.isShiftDown";["summary"] = "\
Gets whether the shift key is down ";["private"] = false;["library"] = "input";["description"] = "\
Gets whether the shift key is down";["param"] = {}; };["isKeyDown"] = { ["ret"] = "True if the key is down";["class"] = "function";["fname"] = "isKeyDown";["realm"] = "sh";["name"] = "input_methods.isKeyDown";["summary"] = "\
Gets whether a key is down ";["private"] = false;["library"] = "input";["description"] = "\
Gets whether a key is down";["param"] = { [1] = "key";["key"] = "The key id, see input"; }; };["isControlDown"] = { ["ret"] = "True if the control key is down";["class"] = "function";["fname"] = "isControlDown";["realm"] = "sh";["name"] = "input_methods.isControlDown";["summary"] = "\
Gets whether the control key is down ";["private"] = false;["library"] = "input";["description"] = "\
Gets whether the control key is down";["param"] = {}; }; };["class"] = "library";["summary"] = "\
Input library.";["fields"] = {};["name"] = "input";["client"] = true;["description"] = "\
Input library.";["libtbl"] = "input_methods";["tables"] = {}; };["file"] = { ["functions"] = { [1] = "append";[2] = "createDir";[3] = "delete";[4] = "exists";[5] = "find";[6] = "open";[7] = "read";[8] = "write";["delete"] = { ["ret"] = "True if successful, nil if error";["class"] = "function";["fname"] = "delete";["realm"] = "cl";["name"] = "file_library.delete";["summary"] = "\
Deletes a file ";["private"] = false;["library"] = "file";["description"] = "\
Deletes a file";["param"] = { [1] = "path";["path"] = "Filepath relative to data/sf_filedata/. Cannot contain '..'"; }; };["createDir"] = { ["class"] = "function";["fname"] = "createDir";["realm"] = "cl";["name"] = "file_library.createDir";["summary"] = "\
Creates a directory ";["private"] = false;["library"] = "file";["description"] = "\
Creates a directory";["param"] = { [1] = "path";["path"] = "Filepath relative to data/sf_filedata/. Cannot contain '..'"; }; };["open"] = { ["ret"] = "File object or nil if it failed";["class"] = "function";["fname"] = "open";["realm"] = "cl";["name"] = "file_library.open";["summary"] = "\
Opens and returns a file ";["private"] = false;["library"] = "file";["description"] = "\
Opens and returns a file";["param"] = { [1] = "path";[2] = "mode";["mode"] = "The file mode to use. See lua manual for explaination";["path"] = "Filepath relative to data/sf_filedata/. Cannot contain '..'"; }; };["read"] = { ["ret"] = "Contents, or nil if error";["class"] = "function";["fname"] = "read";["realm"] = "cl";["name"] = "file_library.read";["summary"] = "\
Reads a file from path ";["private"] = false;["library"] = "file";["description"] = "\
Reads a file from path";["param"] = { [1] = "path";["path"] = "Filepath relative to data/sf_filedata/. Cannot contain '..'"; }; };["exists"] = { ["ret"] = "True if exists, false if not, nil if error";["class"] = "function";["fname"] = "exists";["realm"] = "cl";["name"] = "file_library.exists";["summary"] = "\
Checks if a file exists ";["private"] = false;["library"] = "file";["description"] = "\
Checks if a file exists";["param"] = { [1] = "path";["path"] = "Filepath relative to data/sf_filedata/. Cannot contain '..'"; }; };["append"] = { ["class"] = "function";["fname"] = "append";["realm"] = "cl";["name"] = "file_library.append";["summary"] = "\
Appends a string to the end of a file ";["private"] = false;["library"] = "file";["description"] = "\
Appends a string to the end of a file";["param"] = { [1] = "path";[2] = "data";["path"] = "Filepath relative to data/sf_filedata/. Cannot contain '..'";["data"] = "String that will be appended to the file."; }; };["find"] = { ["ret"] = { [1] = "Table of file names";[2] = "Table of directory names"; };["class"] = "function";["fname"] = "find";["realm"] = "cl";["name"] = "file_library.find";["summary"] = "\
Enumerates a directory ";["private"] = false;["library"] = "file";["description"] = "\
Enumerates a directory";["param"] = { [1] = "path";[2] = "sorting";["path"] = "The folder to enumerate, relative to data/sf_filedata/. Cannot contain '..'";["sorting"] = "Optional sorting arguement. Either nameasc, namedesc, dateasc, datedesc"; }; };["write"] = { ["ret"] = "True if OK, nil if error";["class"] = "function";["fname"] = "write";["realm"] = "cl";["name"] = "file_library.write";["summary"] = "\
Writes to a file ";["private"] = false;["library"] = "file";["description"] = "\
Writes to a file";["param"] = { [1] = "path";[2] = "data";["path"] = "Filepath relative to data/sf_filedata/. Cannot contain '..'"; }; }; };["class"] = "library";["summary"] = "\
File functions.";["fields"] = {};["name"] = "file";["client"] = true;["description"] = "\
File functions. Allows modification of files.";["libtbl"] = "file_library";["tables"] = {}; };["constraint"] = { ["functions"] = { [1] = "axis";[2] = "ballsocket";[3] = "ballsocketadv";[4] = "breakAll";[5] = "breakType";[6] = "elastic";[7] = "getTable";[8] = "nocollide";[9] = "rope";[10] = "setElasticLength";[11] = "setRopeLength";[12] = "slider";[13] = "weld";["ballsocketadv"] = { ["class"] = "function";["realm"] = "sv";["fname"] = "ballsocketadv";["summary"] = "\
Advanced Ballsocket two entities ";["name"] = "constraint_library.ballsocketadv";["library"] = "constraint";["private"] = false;["server"] = true;["description"] = "\
Advanced Ballsocket two entities";["param"] = { [1] = "e1";[2] = "e2";[3] = "bone1";[4] = "bone2";[5] = "v1";[6] = "v2";[7] = "force_lim";[8] = "torque_lim";[9] = "minv";[10] = "maxv";[11] = "frictionv";[12] = "rotateonly";[13] = "nocollide"; }; };["nocollide"] = { ["class"] = "function";["realm"] = "sv";["fname"] = "nocollide";["summary"] = "\
Nocollides two entities ";["name"] = "constraint_library.nocollide";["library"] = "constraint";["private"] = false;["server"] = true;["description"] = "\
Nocollides two entities";["param"] = { [1] = "e1";[2] = "e2";[3] = "bone1";[4] = "bone2"; }; };["elastic"] = { ["class"] = "function";["realm"] = "sv";["fname"] = "elastic";["summary"] = "\
Elastic two entities ";["name"] = "constraint_library.elastic";["library"] = "constraint";["private"] = false;["server"] = true;["description"] = "\
Elastic two entities";["param"] = { [1] = "index";[2] = "e1";[3] = "e2";[4] = "bone1";[5] = "bone2";[6] = "v1";[7] = "v2";[8] = "const";[9] = "damp";[10] = "rdamp";[11] = "width";[12] = "strech"; }; };["getTable"] = { ["ret"] = "Table of entity constraints";["class"] = "function";["fname"] = "getTable";["realm"] = "sv";["name"] = "constraint_library.getTable";["summary"] = "\
Returns the table of constraints on an entity ";["private"] = false;["library"] = "constraint";["description"] = "\
Returns the table of constraints on an entity";["param"] = { [1] = "ent";["ent"] = "The entity"; }; };["axis"] = { ["class"] = "function";["realm"] = "sv";["fname"] = "axis";["summary"] = "\
Axis two entities ";["name"] = "constraint_library.axis";["library"] = "constraint";["private"] = false;["server"] = true;["description"] = "\
Axis two entities";["param"] = { [1] = "e1";[2] = "e2";[3] = "bone1";[4] = "bone2";[5] = "v1";[6] = "v2";[7] = "force_lim";[8] = "torque_lim";[9] = "friction";[10] = "nocollide";[11] = "laxis"; }; };["setElasticLength"] = { ["class"] = "function";["realm"] = "sv";["fname"] = "setElasticLength";["summary"] = "\
Sets the length of an elastic attached to the entity ";["name"] = "constraint_library.setElasticLength";["library"] = "constraint";["private"] = false;["server"] = true;["description"] = "\
Sets the length of an elastic attached to the entity";["param"] = { [1] = "index";[2] = "e";[3] = "length"; }; };["breakType"] = { ["class"] = "function";["realm"] = "sv";["fname"] = "breakType";["summary"] = "\
Breaks all constraints of a certain type on an entity ";["name"] = "constraint_library.breakType";["library"] = "constraint";["private"] = false;["server"] = true;["description"] = "\
Breaks all constraints of a certain type on an entity";["param"] = { [1] = "e";[2] = "typename"; }; };["weld"] = { ["class"] = "function";["realm"] = "sv";["fname"] = "weld";["summary"] = "\
Welds two entities ";["name"] = "constraint_library.weld";["library"] = "constraint";["private"] = false;["server"] = true;["description"] = "\
Welds two entities";["param"] = { [1] = "e1";[2] = "e2";[3] = "bone1";[4] = "bone2";[5] = "force_lim";[6] = "nocollide";["e2"] = "The second entity";["e1"] = "The first entity";["bone2"] = "Number bone of the second entity";["nocollide"] = "Bool whether or not to nocollide the two entities";["bone1"] = "Number bone of the first entity";["force_lim"] = "Max force the weld can take before breaking"; }; };["rope"] = { ["class"] = "function";["realm"] = "sv";["fname"] = "rope";["summary"] = "\
Ropes two entities ";["name"] = "constraint_library.rope";["library"] = "constraint";["private"] = false;["server"] = true;["description"] = "\
Ropes two entities";["param"] = { [1] = "index";[2] = "e1";[3] = "e2";[4] = "bone1";[5] = "bone2";[6] = "v1";[7] = "v2";[8] = "length";[9] = "addlength";[10] = "force_lim";[11] = "width";[12] = "material";[13] = "rigid"; }; };["breakAll"] = { ["class"] = "function";["realm"] = "sv";["fname"] = "breakAll";["summary"] = "\
Breaks all constraints on an entity ";["name"] = "constraint_library.breakAll";["library"] = "constraint";["private"] = false;["server"] = true;["description"] = "\
Breaks all constraints on an entity";["param"] = { [1] = "e"; }; };["setRopeLength"] = { ["class"] = "function";["realm"] = "sv";["fname"] = "setRopeLength";["summary"] = "\
Sets the length of a rope attached to the entity ";["name"] = "constraint_library.setRopeLength";["library"] = "constraint";["private"] = false;["server"] = true;["description"] = "\
Sets the length of a rope attached to the entity";["param"] = { [1] = "index";[2] = "e";[3] = "length"; }; };["ballsocket"] = { ["class"] = "function";["realm"] = "sv";["fname"] = "ballsocket";["summary"] = "\
Ballsocket two entities ";["name"] = "constraint_library.ballsocket";["library"] = "constraint";["private"] = false;["server"] = true;["description"] = "\
Ballsocket two entities";["param"] = { [1] = "e1";[2] = "e2";[3] = "bone1";[4] = "bone2";[5] = "v1";[6] = "force_lim";[7] = "torque_lim";[8] = "nocollide"; }; };["slider"] = { ["class"] = "function";["realm"] = "sv";["fname"] = "slider";["summary"] = "\
Sliders two entities ";["name"] = "constraint_library.slider";["library"] = "constraint";["private"] = false;["server"] = true;["description"] = "\
Sliders two entities";["param"] = { [1] = "e1";[2] = "e2";[3] = "bone1";[4] = "bone2";[5] = "v1";[6] = "v2";[7] = "width"; }; }; };["class"] = "library";["summary"] = "\
Library for creating and manipulating constraints.";["fields"] = {};["name"] = "constraint";["description"] = "\
Library for creating and manipulating constraints.";["libtbl"] = "constraint_library";["tables"] = {};["server"] = true; };["http"] = { ["functions"] = { [1] = "base64Encode";[2] = "canRequest";[3] = "get";[4] = "post";["post"] = { ["class"] = "function";["fname"] = "post";["realm"] = "sh";["name"] = "http_library.post";["summary"] = "\
Runs a new http POST request ";["private"] = false;["library"] = "http";["description"] = "\
Runs a new http POST request";["param"] = { [1] = "url";[2] = "params";[3] = "callbackSuccess";[4] = "callbackFail";["callbackFail"] = "the function to be called on request fail, taking the failing reason as an argument";["callbackSuccess"] = "the function to be called on request success, taking the arguments body (string), length (number), headers (table) and code (number)";["url"] = "http target url";["params"] = "POST parameters to be sent"; }; };["base64Encode"] = { ["ret"] = "The converted data";["class"] = "function";["fname"] = "base64Encode";["realm"] = "sh";["name"] = "http_library.base64Encode";["summary"] = "\
Converts data into base64 format or nil if the string is 0 length ";["private"] = false;["library"] = "http";["description"] = "\
Converts data into base64 format or nil if the string is 0 length";["param"] = { [1] = "data";["data"] = "The data to convert"; }; };["canRequest"] = { ["class"] = "function";["fname"] = "canRequest";["realm"] = "sh";["name"] = "http_library.canRequest";["summary"] = "\
Checks if a new http request can be started ";["private"] = false;["library"] = "http";["description"] = "\
Checks if a new http request can be started";["param"] = {}; };["get"] = { ["class"] = "function";["fname"] = "get";["realm"] = "sh";["name"] = "http_library.get";["summary"] = "\
Runs a new http GET request ";["private"] = false;["library"] = "http";["description"] = "\
Runs a new http GET request";["param"] = { [1] = "url";[2] = "callbackSuccess";[3] = "callbackFail";["url"] = "http target url";["callbackSuccess"] = "the function to be called on request success, taking the arguments body (string), length (number), headers (table) and code (number)";["callbackFail"] = "the function to be called on request fail, taking the failing reason as an argument"; }; }; };["class"] = "library";["summary"] = "\
Http library.";["fields"] = {};["name"] = "http";["client"] = true;["description"] = "\
Http library. Requests content from urls.";["libtbl"] = "http_library";["tables"] = {};["server"] = true; }; };["classes"] = { [1] = "Angle";[2] = "Bass";[3] = "Color";[4] = "Entity";[5] = "File";[6] = "Hologram";[7] = "Mesh";[8] = "Npc";[9] = "PhysObj";[10] = "Player";[11] = "Quaternion";[12] = "Sound";[13] = "VMatrix";[14] = "Vector";[15] = "Vehicle";[16] = "Weapon";[17] = "Wirelink";["Quaternion"] = { ["typtbl"] = "quat_methods";["fields"] = {};["name"] = "Quaternion";["summary"] = "\
Quaternion type ";["description"] = "\
Quaternion type";["class"] = "class";["methods"] = { [1] = "conj";[2] = "forward";[3] = "i";[4] = "j";[5] = "k";[6] = "r";[7] = "real";[8] = "right";[9] = "up";["conj"] = { ["class"] = "function";["fname"] = "conj";["realm"] = "sh";["name"] = "quat_methods:conj";["summary"] = "\
Returns the conj of self ";["private"] = false;["classlib"] = "Quaternion";["description"] = "\
Returns the conj of self";["param"] = {}; };["r"] = { ["class"] = "function";["fname"] = "r";["realm"] = "sh";["name"] = "quat_methods:r";["summary"] = "\
Alias for :real() as r is easier ";["private"] = false;["classlib"] = "Quaternion";["description"] = "\
Alias for :real() as r is easier";["param"] = {}; };["right"] = { ["class"] = "function";["fname"] = "right";["realm"] = "sh";["name"] = "quat_methods:right";["summary"] = "\
Returns vector pointing right for <this> ";["private"] = false;["classlib"] = "Quaternion";["description"] = "\
Returns vector pointing right for <this>";["param"] = {}; };["real"] = { ["class"] = "function";["fname"] = "real";["realm"] = "sh";["name"] = "quat_methods:real";["summary"] = "\
Returns the real component of the quaternion ";["private"] = false;["classlib"] = "Quaternion";["description"] = "\
Returns the real component of the quaternion";["param"] = {}; };["i"] = { ["class"] = "function";["fname"] = "i";["realm"] = "sh";["name"] = "quat_methods:i";["summary"] = "\
Returns the i component of the quaternion ";["private"] = false;["classlib"] = "Quaternion";["description"] = "\
Returns the i component of the quaternion";["param"] = {}; };["k"] = { ["class"] = "function";["fname"] = "k";["realm"] = "sh";["name"] = "quat_methods:k";["summary"] = "\
Returns the k component of the quaternion ";["private"] = false;["classlib"] = "Quaternion";["description"] = "\
Returns the k component of the quaternion";["param"] = {}; };["j"] = { ["class"] = "function";["fname"] = "j";["realm"] = "sh";["name"] = "quat_methods:j";["summary"] = "\
Returns the j component of the quaternion ";["private"] = false;["classlib"] = "Quaternion";["description"] = "\
Returns the j component of the quaternion";["param"] = {}; };["forward"] = { ["class"] = "function";["fname"] = "forward";["realm"] = "sh";["name"] = "quat_methods:forward";["summary"] = "\
Returns vector pointing forward for <this> ";["private"] = false;["classlib"] = "Quaternion";["description"] = "\
Returns vector pointing forward for <this>";["param"] = {}; };["up"] = { ["class"] = "function";["fname"] = "up";["realm"] = "sh";["name"] = "quat_methods:up";["summary"] = "\
Returns vector pointing up for <this> ";["private"] = false;["classlib"] = "Quaternion";["description"] = "\
Returns vector pointing up for <this>";["param"] = {}; }; }; };["PhysObj"] = { ["typtbl"] = "physobj_methods";["summary"] = "\
PhysObj Type ";["fields"] = {};["name"] = "PhysObj";["server"] = true;["description"] = "\
PhysObj Type";["client"] = true;["class"] = "class";["methods"] = { [1] = "applyForceCenter";[2] = "applyForceOffset";[3] = "applyTorque";[4] = "getAngleVelocity";[5] = "getAngles";[6] = "getEntity";[7] = "getInertia";[8] = "getMass";[9] = "getMassCenter";[10] = "getMaterial";[11] = "getMesh";[12] = "getMeshConvexes";[13] = "getPos";[14] = "getVelocity";[15] = "isValid";[16] = "localToWorld";[17] = "localToWorldVector";[18] = "setInertia";[19] = "setMass";[20] = "setMaterial";[21] = "setPos";[22] = "setVelocity";[23] = "worldToLocal";[24] = "worldToLocalVector";["applyTorque"] = { ["class"] = "function";["realm"] = "sh";["fname"] = "applyTorque";["summary"] = "\
Applys a torque to a physics object ";["name"] = "physobj_methods:applyTorque";["classlib"] = "PhysObj";["private"] = false;["server"] = true;["description"] = "\
Applys a torque to a physics object";["param"] = { [1] = "torque";["torque"] = "The local torque vector to apply"; }; };["localToWorld"] = { ["ret"] = "The transformed vector";["class"] = "function";["fname"] = "localToWorld";["realm"] = "sh";["name"] = "physobj_methods:localToWorld";["summary"] = "\
Returns a vector in the reference frame of the world from the local frame of the physicsobject ";["private"] = false;["classlib"] = "PhysObj";["description"] = "\
Returns a vector in the reference frame of the world from the local frame of the physicsobject";["param"] = { [1] = "vec";["vec"] = "The vector to transform"; }; };["getMass"] = { ["ret"] = "mass of the physics object";["class"] = "function";["realm"] = "sh";["summary"] = "\
Gets the mass of the physics object ";["fname"] = "getMass";["classlib"] = "PhysObj";["name"] = "physobj_methods:getMass";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Gets the mass of the physics object";["param"] = {}; };["worldToLocalVector"] = { ["ret"] = "The transformed vector";["class"] = "function";["fname"] = "worldToLocalVector";["realm"] = "sh";["name"] = "physobj_methods:worldToLocalVector";["summary"] = "\
Returns a normal vector in the local reference frame of the physicsobject from the world frame ";["private"] = false;["classlib"] = "PhysObj";["description"] = "\
Returns a normal vector in the local reference frame of the physicsobject from the world frame";["param"] = { [1] = "vec";["vec"] = "The normal vector to transform"; }; };["setPos"] = { ["class"] = "function";["realm"] = "sh";["fname"] = "setPos";["summary"] = "\
Sets the position of the physics object ";["name"] = "physobj_methods:setPos";["classlib"] = "PhysObj";["private"] = false;["server"] = true;["description"] = "\
Sets the position of the physics object";["param"] = { [1] = "pos";["pos"] = "The position vector to set it to"; }; };["getMeshConvexes"] = { ["ret"] = "table of MeshVertex structures";["class"] = "function";["fname"] = "getMeshConvexes";["realm"] = "sh";["name"] = "physobj_methods:getMeshConvexes";["summary"] = "\
Returns a structured table, the physics mesh of the physics object.";["private"] = false;["classlib"] = "PhysObj";["description"] = "\
Returns a structured table, the physics mesh of the physics object. See: http://wiki.garrysmod.com/page/Structures/MeshVertex";["param"] = {}; };["getInertia"] = { ["ret"] = "Vector Inertia of the physics object";["class"] = "function";["realm"] = "sh";["summary"] = "\
Gets the inertia of the physics object ";["fname"] = "getInertia";["classlib"] = "PhysObj";["name"] = "physobj_methods:getInertia";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Gets the inertia of the physics object";["param"] = {}; };["setMaterial"] = { ["class"] = "function";["realm"] = "sh";["fname"] = "setMaterial";["summary"] = "\
Sets the physical material of a physics object ";["name"] = "physobj_methods:setMaterial";["classlib"] = "PhysObj";["private"] = false;["server"] = true;["description"] = "\
Sets the physical material of a physics object";["param"] = { [1] = "material";["material"] = "The physical material to set it to"; }; };["setInertia"] = { ["class"] = "function";["realm"] = "sh";["fname"] = "setInertia";["summary"] = "\
Sets the inertia of a physics object ";["name"] = "physobj_methods:setInertia";["classlib"] = "PhysObj";["private"] = false;["server"] = true;["description"] = "\
Sets the inertia of a physics object";["param"] = { [1] = "inertia";["inertia"] = "The inertia vector to set it to"; }; };["isValid"] = { ["ret"] = "boolean if the physics object is valid";["class"] = "function";["realm"] = "sh";["summary"] = "\
Checks if the physics object is valid ";["fname"] = "isValid";["classlib"] = "PhysObj";["name"] = "physobj_methods:isValid";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Checks if the physics object is valid";["param"] = {}; };["getMaterial"] = { ["ret"] = "The physics material of the physics object";["class"] = "function";["realm"] = "sh";["summary"] = "\
Gets the material of the physics object ";["fname"] = "getMaterial";["classlib"] = "PhysObj";["name"] = "physobj_methods:getMaterial";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Gets the material of the physics object";["param"] = {}; };["localToWorldVector"] = { ["ret"] = "The transformed vector";["class"] = "function";["fname"] = "localToWorldVector";["realm"] = "sh";["name"] = "physobj_methods:localToWorldVector";["summary"] = "\
Returns a normal vector in the reference frame of the world from the local frame of the physicsobject ";["private"] = false;["classlib"] = "PhysObj";["description"] = "\
Returns a normal vector in the reference frame of the world from the local frame of the physicsobject";["param"] = { [1] = "vec";["vec"] = "The normal vector to transform"; }; };["applyForceOffset"] = { ["class"] = "function";["realm"] = "sh";["fname"] = "applyForceOffset";["summary"] = "\
Applys an offset force to a physics object ";["name"] = "physobj_methods:applyForceOffset";["classlib"] = "PhysObj";["private"] = false;["server"] = true;["description"] = "\
Applys an offset force to a physics object";["param"] = { [1] = "force";[2] = "position";["force"] = "The force vector to apply";["position"] = "The position in world coordinates"; }; };["getPos"] = { ["ret"] = "Vector position of the physics object";["class"] = "function";["realm"] = "sh";["summary"] = "\
Gets the position of the physics object ";["fname"] = "getPos";["classlib"] = "PhysObj";["name"] = "physobj_methods:getPos";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Gets the position of the physics object";["param"] = {}; };["applyForceCenter"] = { ["class"] = "function";["realm"] = "sh";["fname"] = "applyForceCenter";["summary"] = "\
Applys a force to the center of the physics object ";["name"] = "physobj_methods:applyForceCenter";["classlib"] = "PhysObj";["private"] = false;["server"] = true;["description"] = "\
Applys a force to the center of the physics object";["param"] = { [1] = "force";["force"] = "The force vector to apply"; }; };["getMassCenter"] = { ["ret"] = "Center of mass vector in the physobject's local reference frame.";["class"] = "function";["realm"] = "sh";["summary"] = "\
Gets the center of mass of the physics object in the local reference frame.";["fname"] = "getMassCenter";["classlib"] = "PhysObj";["name"] = "physobj_methods:getMassCenter";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Gets the center of mass of the physics object in the local reference frame.";["param"] = {}; };["getAngleVelocity"] = { ["ret"] = "Vector angular velocity of the physics object";["class"] = "function";["realm"] = "sh";["summary"] = "\
Gets the angular velocity of the physics object ";["fname"] = "getAngleVelocity";["classlib"] = "PhysObj";["name"] = "physobj_methods:getAngleVelocity";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Gets the angular velocity of the physics object";["param"] = {}; };["setVelocity"] = { ["class"] = "function";["realm"] = "sh";["fname"] = "setVelocity";["summary"] = "\
Sets the velocity of the physics object ";["name"] = "physobj_methods:setVelocity";["classlib"] = "PhysObj";["private"] = false;["server"] = true;["description"] = "\
Sets the velocity of the physics object";["param"] = { [1] = "vel";["vel"] = "The velocity vector to set it to"; }; };["worldToLocal"] = { ["ret"] = "The transformed vector";["class"] = "function";["fname"] = "worldToLocal";["realm"] = "sh";["name"] = "physobj_methods:worldToLocal";["summary"] = "\
Returns a vector in the local reference frame of the physicsobject from the world frame ";["private"] = false;["classlib"] = "PhysObj";["description"] = "\
Returns a vector in the local reference frame of the physicsobject from the world frame";["param"] = { [1] = "vec";["vec"] = "The vector to transform"; }; };["setMass"] = { ["class"] = "function";["realm"] = "sh";["fname"] = "setMass";["summary"] = "\
Sets the mass of a physics object ";["name"] = "physobj_methods:setMass";["classlib"] = "PhysObj";["private"] = false;["server"] = true;["description"] = "\
Sets the mass of a physics object";["param"] = { [1] = "mass";["mass"] = "The mass to set it to"; }; };["getMesh"] = { ["ret"] = "table of MeshVertex structures";["class"] = "function";["fname"] = "getMesh";["realm"] = "sh";["name"] = "physobj_methods:getMesh";["summary"] = "\
Returns a table of MeshVertex structures where each 3 vertices represent a triangle.";["private"] = false;["classlib"] = "PhysObj";["description"] = "\
Returns a table of MeshVertex structures where each 3 vertices represent a triangle. See: http://wiki.garrysmod.com/page/Structures/MeshVertex";["param"] = {}; };["getVelocity"] = { ["ret"] = "Vector velocity of the physics object";["class"] = "function";["realm"] = "sh";["summary"] = "\
Gets the velocity of the physics object ";["fname"] = "getVelocity";["classlib"] = "PhysObj";["name"] = "physobj_methods:getVelocity";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Gets the velocity of the physics object";["param"] = {}; };["getAngles"] = { ["ret"] = "Angle angles of the physics object";["class"] = "function";["realm"] = "sh";["summary"] = "\
Gets the angles of the physics object ";["fname"] = "getAngles";["classlib"] = "PhysObj";["name"] = "physobj_methods:getAngles";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Gets the angles of the physics object";["param"] = {}; };["getEntity"] = { ["ret"] = "The entity attached to the physics object";["class"] = "function";["realm"] = "sh";["summary"] = "\
Gets the entity attached to the physics object ";["fname"] = "getEntity";["classlib"] = "PhysObj";["name"] = "physobj_methods:getEntity";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Gets the entity attached to the physics object";["param"] = {}; }; }; };["Hologram"] = { ["typtbl"] = "hologram_methods";["fields"] = {};["name"] = "Hologram";["summary"] = "\
Hologram type ";["description"] = "\
Hologram type";["class"] = "class";["methods"] = { [1] = "getAnimationLength";[2] = "getAnimationNumber";[3] = "getFlexes";[4] = "getPose";[5] = "setAngVel";[6] = "setAnimation";[7] = "setClip";[8] = "setFlexScale";[9] = "setFlexWeight";[10] = "setModel";[11] = "setPose";[12] = "setScale";[13] = "setVel";[14] = "suppressEngineLighting";["setScale"] = { ["class"] = "function";["fname"] = "setScale";["realm"] = "sv";["name"] = "hologram_methods:setScale";["summary"] = "\
Sets the hologram scale ";["private"] = false;["classlib"] = "Hologram";["description"] = "\
Sets the hologram scale";["param"] = { [1] = "scale";["scale"] = "Vector new scale"; }; };["getFlexes"] = { ["class"] = "function";["fname"] = "getFlexes";["realm"] = "sv";["name"] = "hologram_methods:getFlexes";["summary"] = "\
Returns a table of flexname -> flexid pairs for use in flex functions.";["private"] = false;["classlib"] = "Hologram";["description"] = "\
Returns a table of flexname -> flexid pairs for use in flex functions. \
These IDs become invalid when the hologram's model changes.";["param"] = {}; };["setFlexWeight"] = { ["class"] = "function";["fname"] = "setFlexWeight";["realm"] = "sv";["name"] = "hologram_methods:setFlexWeight";["summary"] = "\
Sets the weight (value) of a flex.";["private"] = false;["classlib"] = "Hologram";["description"] = "\
Sets the weight (value) of a flex.";["param"] = { [1] = "flexid";[2] = "weight"; }; };["getPose"] = { ["ret"] = "Value of the pose parameter";["class"] = "function";["realm"] = "sv";["summary"] = "\
Get the pose value of an animation ";["classForced"] = true;["fname"] = "getPose";["name"] = "hologram_methods:getPose";["classlib"] = "Hologram";["private"] = false;["server"] = true;["description"] = "\
Get the pose value of an animation";["param"] = { [1] = "pose";["pose"] = "Pose parameter name"; }; };["setAngVel"] = { ["class"] = "function";["fname"] = "setAngVel";["realm"] = "sv";["name"] = "hologram_methods:setAngVel";["summary"] = "\
Sets the hologram's angular velocity.";["private"] = false;["classlib"] = "Hologram";["description"] = "\
Sets the hologram's angular velocity.";["param"] = { [1] = "angvel";["angvel"] = "*Vector* angular velocity."; }; };["getAnimationNumber"] = { ["ret"] = "Animation index";["class"] = "function";["realm"] = "sv";["fname"] = "getAnimationNumber";["summary"] = "\
Convert animation name into animation number ";["name"] = "hologram_methods:getAnimationNumber";["classlib"] = "Hologram";["private"] = false;["server"] = true;["description"] = "\
Convert animation name into animation number";["param"] = { [1] = "animation";["animation"] = "Name of the animation"; }; };["setAnimation"] = { ["class"] = "function";["realm"] = "sv";["summary"] = "\
Animates a hologram ";["classForced"] = true;["fname"] = "setAnimation";["name"] = "hologram_methods:setAnimation";["classlib"] = "Hologram";["private"] = false;["server"] = true;["description"] = "\
Animates a hologram";["param"] = { [1] = "animation";[2] = "frame";[3] = "rate";["frame"] = "The starting frame number";["rate"] = "Frame speed. (1 is normal)";["animation"] = "number or string name"; }; };["setFlexScale"] = { ["class"] = "function";["fname"] = "setFlexScale";["realm"] = "sv";["name"] = "hologram_methods:setFlexScale";["summary"] = "\
Sets the scale of all flexes of a hologram ";["private"] = false;["classlib"] = "Hologram";["description"] = "\
Sets the scale of all flexes of a hologram";["param"] = { [1] = "scale"; }; };["setPose"] = { ["class"] = "function";["realm"] = "sv";["summary"] = "\
Set the pose value of an animation.";["classForced"] = true;["fname"] = "setPose";["name"] = "hologram_methods:setPose";["classlib"] = "Hologram";["private"] = false;["server"] = true;["description"] = "\
Set the pose value of an animation. Turret/Head angles for example.";["param"] = { [1] = "pose";[2] = "value";["value"] = "Value to set it to.";["pose"] = "Name of the pose parameter"; }; };["setVel"] = { ["class"] = "function";["fname"] = "setVel";["realm"] = "sv";["name"] = "hologram_methods:setVel";["summary"] = "\
Sets the hologram linear velocity ";["private"] = false;["classlib"] = "Hologram";["description"] = "\
Sets the hologram linear velocity";["param"] = { [1] = "vel";["vel"] = "New velocity"; }; };["getAnimationLength"] = { ["ret"] = "Length of current animation in seconds";["class"] = "function";["realm"] = "sv";["summary"] = "\
Get the length of the current animation ";["classForced"] = true;["fname"] = "getAnimationLength";["name"] = "hologram_methods:getAnimationLength";["classlib"] = "Hologram";["private"] = false;["server"] = true;["description"] = "\
Get the length of the current animation";["param"] = {}; };["suppressEngineLighting"] = { ["class"] = "function";["realm"] = "sv";["summary"] = "\
Suppress Engine Lighting of a hologram.";["classForced"] = true;["fname"] = "suppressEngineLighting";["name"] = "hologram_methods:suppressEngineLighting";["classlib"] = "Hologram";["private"] = false;["server"] = true;["description"] = "\
Suppress Engine Lighting of a hologram. Disabled by default.";["param"] = { [1] = "suppress";["suppress"] = "Boolean to represent if shading should be set or not."; }; };["setModel"] = { ["class"] = "function";["realm"] = "sv";["summary"] = "\
Sets the model of a hologram ";["classForced"] = true;["fname"] = "setModel";["name"] = "hologram_methods:setModel";["classlib"] = "Hologram";["private"] = false;["server"] = true;["description"] = "\
Sets the model of a hologram";["param"] = { [1] = "model";["model"] = "string model path"; }; };["setClip"] = { ["class"] = "function";["fname"] = "setClip";["realm"] = "sv";["name"] = "hologram_methods:setClip";["summary"] = "\
Updates a clip plane ";["private"] = false;["classlib"] = "Hologram";["description"] = "\
Updates a clip plane";["param"] = { [1] = "index";[2] = "enabled";[3] = "origin";[4] = "normal";[5] = "islocal"; }; }; }; };["Bass"] = { ["typtbl"] = "bass_methods";["fields"] = {};["name"] = "Bass";["summary"] = "\
Bass type ";["description"] = "\
Bass type";["client"] = true;["class"] = "class";["methods"] = { [1] = "getFFT";[2] = "getLength";[3] = "getTime";[4] = "isOnline";[5] = "isValid";[6] = "pause";[7] = "play";[8] = "setFade";[9] = "setLooping";[10] = "setPitch";[11] = "setPos";[12] = "setTime";[13] = "setVolume";[14] = "stop";["isValid"] = { ["ret"] = "Is valid or not";["class"] = "function";["fname"] = "isValid";["realm"] = "cl";["name"] = "bass_methods:isValid";["summary"] = "\
Gets if the sound is valid or not ";["private"] = false;["classlib"] = "Bass";["description"] = "\
Gets if the sound is valid or not";["param"] = {}; };["setLooping"] = { ["class"] = "function";["fname"] = "setLooping";["realm"] = "cl";["name"] = "bass_methods:setLooping";["summary"] = "\
Sets if the sound should loop or not.";["private"] = false;["classlib"] = "Bass";["description"] = "\
Sets if the sound should loop or not.";["param"] = { [1] = "loop";["loop"] = "Boolean if the sound should loop or not."; }; };["isOnline"] = { ["ret"] = "Is online or not";["class"] = "function";["fname"] = "isOnline";["realm"] = "cl";["name"] = "bass_methods:isOnline";["summary"] = "\
Gets if the sound is streamed or not ";["private"] = false;["classlib"] = "Bass";["description"] = "\
Gets if the sound is streamed or not";["param"] = {}; };["setFade"] = { ["class"] = "function";["fname"] = "setFade";["realm"] = "cl";["name"] = "bass_methods:setFade";["summary"] = "\
Sets the fade distance of the sound ";["private"] = false;["classlib"] = "Bass";["description"] = "\
Sets the fade distance of the sound";["param"] = { [1] = "min";[2] = "max";["max"] = "The channel's volume stops decreasing when the listener is beyond this distance.";["min"] = "The channel's volume is at maximum when the listener is within this distance"; }; };["getFFT"] = { ["ret"] = "FFT table of the sound";["class"] = "function";["fname"] = "getFFT";["realm"] = "cl";["name"] = "bass_methods:getFFT";["summary"] = "\
Gets the FFT of a sound ";["private"] = false;["classlib"] = "Bass";["description"] = "\
Gets the FFT of a sound";["param"] = { [1] = "n";["n"] = "Sample size of the hamming window. Must be power of 2"; }; };["getTime"] = { ["ret"] = "Current time in seconds of the sound";["class"] = "function";["fname"] = "getTime";["realm"] = "cl";["name"] = "bass_methods:getTime";["summary"] = "\
Gets the current time of a sound ";["private"] = false;["classlib"] = "Bass";["description"] = "\
Gets the current time of a sound";["param"] = {}; };["setTime"] = { ["class"] = "function";["fname"] = "setTime";["realm"] = "cl";["name"] = "bass_methods:setTime";["summary"] = "\
Sets the current time of a sound ";["private"] = false;["classlib"] = "Bass";["description"] = "\
Sets the current time of a sound";["param"] = { [1] = "time";["time"] = "Time to set a sound in seconds"; }; };["setPos"] = { ["class"] = "function";["fname"] = "setPos";["realm"] = "cl";["name"] = "bass_methods:setPos";["summary"] = "\
Sets the position of the sound ";["private"] = false;["classlib"] = "Bass";["description"] = "\
Sets the position of the sound";["param"] = { [1] = "pos";["pos"] = "Where to position the sound"; }; };["stop"] = { ["class"] = "function";["fname"] = "stop";["realm"] = "cl";["name"] = "bass_methods:stop";["summary"] = "\
Stops playing the sound.";["private"] = false;["classlib"] = "Bass";["description"] = "\
Stops playing the sound.";["param"] = {}; };["getLength"] = { ["ret"] = "Length in seconds of the sound";["class"] = "function";["fname"] = "getLength";["realm"] = "cl";["name"] = "bass_methods:getLength";["summary"] = "\
Gets the length of a sound ";["private"] = false;["classlib"] = "Bass";["description"] = "\
Gets the length of a sound";["param"] = {}; };["setPitch"] = { ["class"] = "function";["fname"] = "setPitch";["realm"] = "cl";["name"] = "bass_methods:setPitch";["summary"] = "\
Sets the pitch of the sound.";["private"] = false;["classlib"] = "Bass";["description"] = "\
Sets the pitch of the sound.";["param"] = { [1] = "pitch";["pitch"] = "Pitch to set to, between 0 and 3."; }; };["setVolume"] = { ["class"] = "function";["fname"] = "setVolume";["realm"] = "cl";["name"] = "bass_methods:setVolume";["summary"] = "\
Sets the volume of the sound.";["private"] = false;["classlib"] = "Bass";["description"] = "\
Sets the volume of the sound.";["param"] = { [1] = "vol";["vol"] = "Volume to set to, between 0 and 1."; }; };["play"] = { ["class"] = "function";["fname"] = "play";["realm"] = "cl";["name"] = "bass_methods:play";["summary"] = "\
Starts to play the sound.";["private"] = false;["classlib"] = "Bass";["description"] = "\
Starts to play the sound.";["param"] = {}; };["pause"] = { ["class"] = "function";["fname"] = "pause";["realm"] = "cl";["name"] = "bass_methods:pause";["summary"] = "\
Pauses the sound.";["private"] = false;["classlib"] = "Bass";["description"] = "\
Pauses the sound.";["param"] = {}; }; }; };["Npc"] = { ["typtbl"] = "npc_methods";["fields"] = {};["name"] = "Npc";["summary"] = "\
Npc type ";["description"] = "\
Npc type";["class"] = "class";["methods"] = { [1] = "addEntityRelationship";[2] = "addRelationship";[3] = "attackMelee";[4] = "attackRange";[5] = "getEnemy";[6] = "getRelationship";[7] = "giveWeapon";[8] = "goRun";[9] = "goWalk";[10] = "setEnemy";[11] = "stop";["goWalk"] = { ["class"] = "function";["fname"] = "goWalk";["realm"] = "sv";["name"] = "npc_methods:goWalk";["summary"] = "\
Makes the npc walk to a destination ";["private"] = false;["classlib"] = "Npc";["description"] = "\
Makes the npc walk to a destination";["param"] = { [1] = "vec";["vec"] = "The position of the destination"; }; };["addEntityRelationship"] = { ["class"] = "function";["fname"] = "addEntityRelationship";["realm"] = "sv";["name"] = "npc_methods:addEntityRelationship";["summary"] = "\
Adds a relationship to the npc with an entity ";["private"] = false;["classlib"] = "Npc";["description"] = "\
Adds a relationship to the npc with an entity";["param"] = { [1] = "ent";[2] = "disp";[3] = "priority";["priority"] = "number how strong the relationship is. Higher number is stronger";["disp"] = "String of the relationship. (hate fear like neutral)";["ent"] = "The target entity"; }; };["attackMelee"] = { ["class"] = "function";["fname"] = "attackMelee";["realm"] = "sv";["name"] = "npc_methods:attackMelee";["summary"] = "\
Makes the npc do a melee attack ";["private"] = false;["classlib"] = "Npc";["description"] = "\
Makes the npc do a melee attack";["param"] = {}; };["attackRange"] = { ["class"] = "function";["fname"] = "attackRange";["realm"] = "sv";["name"] = "npc_methods:attackRange";["summary"] = "\
Makes the npc do a ranged attack ";["private"] = false;["classlib"] = "Npc";["description"] = "\
Makes the npc do a ranged attack";["param"] = {}; };["getRelationship"] = { ["ret"] = "string relationship of the npc with the target";["class"] = "function";["fname"] = "getRelationship";["realm"] = "sv";["name"] = "npc_methods:getRelationship";["summary"] = "\
Gets the npc's relationship to the target ";["private"] = false;["classlib"] = "Npc";["description"] = "\
Gets the npc's relationship to the target";["param"] = { [1] = "ent";["ent"] = "Target entity"; }; };["stop"] = { ["class"] = "function";["fname"] = "stop";["realm"] = "sv";["name"] = "npc_methods:stop";["summary"] = "\
Stops the npc ";["private"] = false;["classlib"] = "Npc";["description"] = "\
Stops the npc";["param"] = {}; };["giveWeapon"] = { ["class"] = "function";["fname"] = "giveWeapon";["realm"] = "sv";["name"] = "npc_methods:giveWeapon";["summary"] = "\
Gives the npc a weapon ";["private"] = false;["classlib"] = "Npc";["description"] = "\
Gives the npc a weapon";["param"] = { [1] = "wep";["wep"] = "The classname of the weapon"; }; };["goRun"] = { ["class"] = "function";["fname"] = "goRun";["realm"] = "sv";["name"] = "npc_methods:goRun";["summary"] = "\
Makes the npc run to a destination ";["private"] = false;["classlib"] = "Npc";["description"] = "\
Makes the npc run to a destination";["param"] = { [1] = "vec";["vec"] = "The position of the destination"; }; };["getEnemy"] = { ["ret"] = "Entity the npc is fighting";["class"] = "function";["fname"] = "getEnemy";["realm"] = "sv";["name"] = "npc_methods:getEnemy";["summary"] = "\
Gets what the npc is fighting ";["private"] = false;["classlib"] = "Npc";["description"] = "\
Gets what the npc is fighting";["param"] = {}; };["addRelationship"] = { ["class"] = "function";["fname"] = "addRelationship";["realm"] = "sv";["name"] = "npc_methods:addRelationship";["summary"] = "\
Adds a relationship to the npc ";["private"] = false;["classlib"] = "Npc";["description"] = "\
Adds a relationship to the npc";["param"] = { [1] = "str";["str"] = "The relationship string. http://wiki.garrysmod.com/page/NPC/AddRelationship"; }; };["setEnemy"] = { ["class"] = "function";["fname"] = "setEnemy";["realm"] = "sv";["name"] = "npc_methods:setEnemy";["summary"] = "\
Tell the npc to fight this ";["private"] = false;["classlib"] = "Npc";["description"] = "\
Tell the npc to fight this";["param"] = { [1] = "ent";["ent"] = "Target entity"; }; }; }; };["Vector"] = { ["typtbl"] = "vec_methods";["summary"] = "\
Vector type ";["fields"] = {};["name"] = "Vector";["server"] = true;["description"] = "\
Vector type";["client"] = true;["class"] = "class";["methods"] = { [1] = "add";[2] = "cross";[3] = "div";[4] = "dot";[5] = "getAngle";[6] = "getAngleEx";[7] = "getDistance";[8] = "getDistanceSqr";[9] = "getLength";[10] = "getLength2D";[11] = "getLength2DSqr";[12] = "getLengthSqr";[13] = "getNormalized";[14] = "isEqualTol";[15] = "isZero";[16] = "mul";[17] = "normalize";[18] = "rotate";[19] = "rotateAroundAxis";[20] = "set";[21] = "setX";[22] = "setY";[23] = "setZ";[24] = "setZero";[25] = "sub";[26] = "toScreen";[27] = "vdiv";[28] = "vmul";[29] = "withinAABox";["isEqualTol"] = { ["ret"] = "bool True/False.";["class"] = "function";["fname"] = "isEqualTol";["realm"] = "sh";["name"] = "vec_methods:isEqualTol";["summary"] = "\
Is this vector and v equal within tolerance t.";["private"] = false;["classlib"] = "Vector";["description"] = "\
Is this vector and v equal within tolerance t.";["param"] = { [1] = "v";[2] = "t";["t"] = "Tolerance number.";["v"] = "Second Vector"; }; };["getAngle"] = { ["ret"] = "Angle";["class"] = "function";["fname"] = "getAngle";["realm"] = "sh";["name"] = "vec_methods:getAngle";["summary"] = "\
Get the vector's angle.";["private"] = false;["classlib"] = "Vector";["description"] = "\
Get the vector's angle.";["param"] = {}; };["getLength2D"] = { ["ret"] = "number length";["class"] = "function";["fname"] = "getLength2D";["realm"] = "sh";["name"] = "vec_methods:getLength2D";["summary"] = "\
Returns the length of the vector in two dimensions, without the Z axis.";["private"] = false;["classlib"] = "Vector";["description"] = "\
Returns the length of the vector in two dimensions, without the Z axis.";["param"] = {}; };["withinAABox"] = { ["ret"] = "bool True/False.";["class"] = "function";["fname"] = "withinAABox";["realm"] = "sh";["name"] = "vec_methods:withinAABox";["summary"] = "\
Returns whenever the given vector is in a box created by the 2 other vectors.";["private"] = false;["classlib"] = "Vector";["description"] = "\
Returns whenever the given vector is in a box created by the 2 other vectors.";["param"] = { [1] = "v1";[2] = "v2";["v1"] = "Vector used to define AABox";["v2"] = "Second Vector to define AABox"; }; };["mul"] = { ["ret"] = "nil";["class"] = "function";["fname"] = "mul";["realm"] = "sh";["name"] = "vec_methods:mul";["summary"] = "\
Scalar Multiplication of the vector.";["private"] = false;["classlib"] = "Vector";["description"] = "\
Scalar Multiplication of the vector. Self-Modifies.";["param"] = { [1] = "n";["n"] = "Scalar to multiply with."; }; };["sub"] = { ["ret"] = "nil";["class"] = "function";["fname"] = "sub";["realm"] = "sh";["name"] = "vec_methods:sub";["summary"] = "\
Subtract v from this Vector.";["private"] = false;["classlib"] = "Vector";["description"] = "\
Subtract v from this Vector. Self-Modifies.";["param"] = { [1] = "v";["v"] = "Second Vector."; }; };["getLength"] = { ["ret"] = "number Length.";["class"] = "function";["fname"] = "getLength";["realm"] = "sh";["name"] = "vec_methods:getLength";["summary"] = "\
Get the vector's Length.";["private"] = false;["classlib"] = "Vector";["description"] = "\
Get the vector's Length.";["param"] = {}; };["normalize"] = { ["ret"] = "nil";["class"] = "function";["fname"] = "normalize";["realm"] = "sh";["name"] = "vec_methods:normalize";["summary"] = "\
Normalise the vector, same direction, length 1.";["private"] = false;["classlib"] = "Vector";["description"] = "\
Normalise the vector, same direction, length 1. Self-Modifies.";["param"] = {}; };["dot"] = { ["ret"] = "Number";["class"] = "function";["fname"] = "dot";["realm"] = "sh";["name"] = "vec_methods:dot";["summary"] = "\
Dot product is the cosine of the angle between both vectors multiplied by their lengths.";["private"] = false;["classlib"] = "Vector";["description"] = "\
Dot product is the cosine of the angle between both vectors multiplied by their lengths. A.B = ||A||||B||cosA.";["param"] = { [1] = "v";["v"] = "Second Vector"; }; };["getDistance"] = { ["ret"] = "Number";["class"] = "function";["fname"] = "getDistance";["realm"] = "sh";["name"] = "vec_methods:getDistance";["summary"] = "\
Returns the pythagorean distance between the vector and the other vector.";["private"] = false;["classlib"] = "Vector";["description"] = "\
Returns the pythagorean distance between the vector and the other vector.";["param"] = { [1] = "v";["v"] = "Second Vector"; }; };["setZero"] = { ["ret"] = "nil";["class"] = "function";["fname"] = "setZero";["realm"] = "sh";["name"] = "vec_methods:setZero";["summary"] = "\
Set's all vector fields to 0.";["private"] = false;["classlib"] = "Vector";["description"] = "\
Set's all vector fields to 0.";["param"] = {}; };["getLength2DSqr"] = { ["ret"] = "number length squared.";["class"] = "function";["fname"] = "getLength2DSqr";["realm"] = "sh";["name"] = "vec_methods:getLength2DSqr";["summary"] = "\
Returns the length squared of the vector in two dimensions, without the Z axis.";["private"] = false;["classlib"] = "Vector";["description"] = "\
Returns the length squared of the vector in two dimensions, without the Z axis. ( Saves computation by skipping the square root )";["param"] = {}; };["rotateAroundAxis"] = { ["ret"] = "Rotated vector";["class"] = "function";["fname"] = "rotateAroundAxis";["realm"] = "sh";["name"] = "vec_methods:rotateAroundAxis";["summary"] = "\
Return rotated vector by an axis ";["private"] = false;["classlib"] = "Vector";["description"] = "\
Return rotated vector by an axis";["param"] = { [1] = "axis";[2] = "degrees";[3] = "radians";["degrees"] = "Angle to rotate by in degrees or nil if radians.";["radians"] = "Angle to rotate by in radians or nil if degrees.";["axis"] = "Axis the rotate around"; }; };["setZ"] = { ["ret"] = "The modified vector";["class"] = "function";["fname"] = "setZ";["realm"] = "sh";["name"] = "vec_methods:setZ";["summary"] = "\
Set's the vector's z coordinate and returns it.";["private"] = false;["classlib"] = "Vector";["description"] = "\
Set's the vector's z coordinate and returns it.";["param"] = { [1] = "z";["z"] = "The z coordinate"; }; };["set"] = { ["ret"] = "nil";["class"] = "function";["fname"] = "set";["realm"] = "sh";["name"] = "vec_methods:set";["summary"] = "\
Copies the values from the second vector to the first vector.";["private"] = false;["classlib"] = "Vector";["description"] = "\
Copies the values from the second vector to the first vector. Self-Modifies.";["param"] = { [1] = "v";["v"] = "Second Vector"; }; };["toScreen"] = { ["ret"] = "A table {x=screenx,y=screeny,visible=visible}";["class"] = "function";["fname"] = "toScreen";["realm"] = "sh";["name"] = "vec_methods:toScreen";["summary"] = "\
Translates the vectors position into 2D user screen coordinates.";["private"] = false;["classlib"] = "Vector";["description"] = "\
Translates the vectors position into 2D user screen coordinates.";["param"] = {}; };["setY"] = { ["ret"] = "The modified vector";["class"] = "function";["fname"] = "setY";["realm"] = "sh";["name"] = "vec_methods:setY";["summary"] = "\
Set's the vector's y coordinate and returns it.";["private"] = false;["classlib"] = "Vector";["description"] = "\
Set's the vector's y coordinate and returns it.";["param"] = { [1] = "y";["y"] = "The y coordinate"; }; };["isZero"] = { ["ret"] = "bool True/False";["class"] = "function";["fname"] = "isZero";["realm"] = "sh";["name"] = "vec_methods:isZero";["summary"] = "\
Are all fields zero.";["private"] = false;["classlib"] = "Vector";["description"] = "\
Are all fields zero.";["param"] = {}; };["getNormalized"] = { ["ret"] = "Vector Normalised";["class"] = "function";["fname"] = "getNormalized";["realm"] = "sh";["name"] = "vec_methods:getNormalized";["summary"] = "\
Returns a new vector with the same direction by length of 1.";["private"] = false;["classlib"] = "Vector";["description"] = "\
Returns a new vector with the same direction by length of 1.";["param"] = {}; };["setX"] = { ["ret"] = "The modified vector";["class"] = "function";["fname"] = "setX";["realm"] = "sh";["name"] = "vec_methods:setX";["summary"] = "\
Set's the vector's x coordinate and returns it.";["private"] = false;["classlib"] = "Vector";["description"] = "\
Set's the vector's x coordinate and returns it.";["param"] = { [1] = "x";["x"] = "The x coordinate"; }; };["vdiv"] = { ["class"] = "function";["fname"] = "vdiv";["realm"] = "sh";["name"] = "vec_methods:vdiv";["summary"] = "\
Divide self by a Vector.";["private"] = false;["classlib"] = "Vector";["description"] = "\
Divide self by a Vector. Self-Modifies. ( convenience function )";["param"] = { [1] = "v";["v"] = "Vector to divide by"; }; };["div"] = { ["ret"] = "nil";["class"] = "function";["fname"] = "div";["realm"] = "sh";["name"] = "vec_methods:div";["summary"] = "\
\"Scalar Division\" of the vector.";["private"] = false;["classlib"] = "Vector";["description"] = "\
\"Scalar Division\" of the vector. Self-Modifies.";["param"] = { [1] = "n";["n"] = "Scalar to divide by."; }; };["getLengthSqr"] = { ["ret"] = "number length squared.";["class"] = "function";["fname"] = "getLengthSqr";["realm"] = "sh";["name"] = "vec_methods:getLengthSqr";["summary"] = "\
Get the vector's length squared ( Saves computation by skipping the square root ).";["private"] = false;["classlib"] = "Vector";["description"] = "\
Get the vector's length squared ( Saves computation by skipping the square root ).";["param"] = {}; };["vmul"] = { ["class"] = "function";["fname"] = "vmul";["realm"] = "sh";["name"] = "vec_methods:vmul";["summary"] = "\
Multiply self with a Vector.";["private"] = false;["classlib"] = "Vector";["description"] = "\
Multiply self with a Vector. Self-Modifies. ( convenience function )";["param"] = { [1] = "v";["v"] = "Vector to multiply with"; }; };["cross"] = { ["ret"] = "Vector";["class"] = "function";["fname"] = "cross";["realm"] = "sh";["name"] = "vec_methods:cross";["summary"] = "\
Calculates the cross product of the 2 vectors, creates a unique perpendicular vector to both input vectors.";["private"] = false;["classlib"] = "Vector";["description"] = "\
Calculates the cross product of the 2 vectors, creates a unique perpendicular vector to both input vectors.";["param"] = { [1] = "v";["v"] = "Second Vector"; }; };["getAngleEx"] = { ["ret"] = "Angle";["class"] = "function";["fname"] = "getAngleEx";["realm"] = "sh";["name"] = "vec_methods:getAngleEx";["summary"] = "\
Returns the Angle between two vectors.";["private"] = false;["classlib"] = "Vector";["description"] = "\
Returns the Angle between two vectors.";["param"] = { [1] = "v";["v"] = "Second Vector"; }; };["rotate"] = { ["ret"] = "nil.";["class"] = "function";["fname"] = "rotate";["realm"] = "sh";["name"] = "vec_methods:rotate";["summary"] = "\
Rotate the vector by Angle b.";["private"] = false;["classlib"] = "Vector";["description"] = "\
Rotate the vector by Angle b. Self-Modifies.";["param"] = { [1] = "b";["b"] = "Angle to rotate by."; }; };["getDistanceSqr"] = { ["ret"] = "Number";["class"] = "function";["fname"] = "getDistanceSqr";["realm"] = "sh";["name"] = "vec_methods:getDistanceSqr";["summary"] = "\
Returns the squared distance of 2 vectors, this is faster Vector:getDistance as calculating the square root is an expensive process.";["private"] = false;["classlib"] = "Vector";["description"] = "\
Returns the squared distance of 2 vectors, this is faster Vector:getDistance as calculating the square root is an expensive process.";["param"] = { [1] = "v";["v"] = "Second Vector"; }; };["add"] = { ["ret"] = "nil";["class"] = "function";["fname"] = "add";["realm"] = "sh";["name"] = "vec_methods:add";["summary"] = "\
Add vector - Modifies self.";["private"] = false;["classlib"] = "Vector";["description"] = "\
Add vector - Modifies self.";["param"] = { [1] = "v";["v"] = "Vector to add"; }; }; }; };["Entity"] = { ["typtbl"] = "ents_methods";["summary"] = "\
Entity type ";["fields"] = {};["name"] = "Entity";["server"] = true;["description"] = "\
Entity type";["client"] = true;["class"] = "class";["methods"] = { [1] = "addCollisionListener";[2] = "applyAngForce";[3] = "applyDamage";[4] = "applyForceCenter";[5] = "applyForceOffset";[6] = "applyTorque";[7] = "breakEnt";[8] = "emitSound";[9] = "enableDrag";[10] = "enableGravity";[11] = "enableMotion";[12] = "enableSphere";[13] = "entIndex";[14] = "extinguish";[15] = "getAngleVelocity";[16] = "getAngleVelocityAngle";[17] = "getAngles";[18] = "getAttachment";[19] = "getAttachmentParent";[20] = "getBoneCount";[21] = "getBoneMatrix";[22] = "getBoneName";[23] = "getBoneParent";[24] = "getBonePosition";[25] = "getClass";[26] = "getColor";[27] = "getEyeAngles";[28] = "getEyePos";[29] = "getForward";[30] = "getHealth";[31] = "getInertia";[32] = "getMass";[33] = "getMassCenter";[34] = "getMassCenterW";[35] = "getMaterial";[36] = "getMaterials";[37] = "getMaxHealth";[38] = "getModel";[39] = "getOwner";[40] = "getParent";[41] = "getPhysicsObject";[42] = "getPhysicsObjectCount";[43] = "getPhysicsObjectNum";[44] = "getPos";[45] = "getRight";[46] = "getSkin";[47] = "getSubMaterial";[48] = "getUp";[49] = "getVelocity";[50] = "ignite";[51] = "isFrozen";[52] = "isNPC";[53] = "isOnGround";[54] = "isPlayer";[55] = "isValid";[56] = "isValidPhys";[57] = "isVehicle";[58] = "isWeapon";[59] = "isWeldedTo";[60] = "linkComponent";[61] = "localToWorld";[62] = "localToWorldAngles";[63] = "lookupAttachment";[64] = "lookupBone";[65] = "manipulateBoneAngles";[66] = "manipulateBonePosition";[67] = "manipulateBoneScale";[68] = "obbCenter";[69] = "obbCenterW";[70] = "obbSize";[71] = "remove";[72] = "removeCollisionListener";[73] = "removeTrails";[74] = "setAngles";[75] = "setBodygroup";[76] = "setColor";[77] = "setDrawShadow";[78] = "setFrozen";[79] = "setHologramMesh";[80] = "setHologramRenderBounds";[81] = "setInertia";[82] = "setMass";[83] = "setMaterial";[84] = "setNoDraw";[85] = "setNocollideAll";[86] = "setParent";[87] = "setPhysMaterial";[88] = "setPos";[89] = "setRenderFX";[90] = "setRenderMode";[91] = "setSkin";[92] = "setSolid";[93] = "setSubMaterial";[94] = "setTrails";[95] = "setVelocity";[96] = "translateBoneToPhysBone";[97] = "translatePhysBoneToBone";[98] = "unparent";[99] = "worldToLocal";[100] = "worldToLocalAngles";["getRight"] = { ["ret"] = "Vector right";["class"] = "function";["realm"] = "sh";["summary"] = "\
Gets the entity's right vector ";["fname"] = "getRight";["classlib"] = "Entity";["name"] = "ents_methods:getRight";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Gets the entity's right vector";["param"] = {}; };["applyTorque"] = { ["class"] = "function";["fname"] = "applyTorque";["realm"] = "sv";["name"] = "ents_methods:applyTorque";["summary"] = "\
Applies torque ";["private"] = false;["classlib"] = "Entity";["description"] = "\
Applies torque";["param"] = { [1] = "torque";["torque"] = "The torque vector"; }; };["getPhysicsObjectCount"] = { ["ret"] = "The number of physics objects on the entity";["class"] = "function";["fname"] = "getPhysicsObjectCount";["realm"] = "sh";["name"] = "ents_methods:getPhysicsObjectCount";["summary"] = "\
Gets the number of physicsobjects of an entity ";["private"] = false;["classlib"] = "Entity";["description"] = "\
Gets the number of physicsobjects of an entity";["param"] = {}; };["setSubMaterial"] = { ["class"] = "function";["realm"] = "sv";["summary"] = "\
Sets an entities' submaterial ";["classForced"] = true;["fname"] = "setSubMaterial";["name"] = "ents_methods:setSubMaterial";["classlib"] = "Entity";["private"] = false;["server"] = true;["description"] = "\
Sets an entities' submaterial";["param"] = { [1] = "index";[2] = "material";[3] = "ply";["material"] = ", string, New material name.";["index"] = ", number, submaterial index.";["ply"] = "Optional player argument to set only for that player. Can also be table of players."; }; };["setNocollideAll"] = { ["class"] = "function";["fname"] = "setNocollideAll";["realm"] = "sv";["name"] = "ents_methods:setNocollideAll";["summary"] = "\
Set's the entity to collide with nothing but the world ";["private"] = false;["classlib"] = "Entity";["description"] = "\
Set's the entity to collide with nothing but the world";["param"] = { [1] = "nocollide";["nocollide"] = "Whether to collide with nothing except world or not."; }; };["setPos"] = { ["class"] = "function";["fname"] = "setPos";["realm"] = "sv";["name"] = "ents_methods:setPos";["summary"] = "\
Sets the entitiy's position ";["private"] = false;["classlib"] = "Entity";["description"] = "\
Sets the entitiy's position";["param"] = { [1] = "vec";["vec"] = "New position"; }; };["translatePhysBoneToBone"] = { ["ret"] = "The ragdoll bone id";["class"] = "function";["fname"] = "translatePhysBoneToBone";["realm"] = "sh";["name"] = "ents_methods:translatePhysBoneToBone";["summary"] = "\
Converts a physobject id to the corresponding ragdoll bone id ";["private"] = false;["classlib"] = "Entity";["description"] = "\
Converts a physobject id to the corresponding ragdoll bone id";["param"] = { [1] = "boneid";["boneid"] = "The physobject id"; }; };["applyForceCenter"] = { ["class"] = "function";["fname"] = "applyForceCenter";["realm"] = "sv";["name"] = "ents_methods:applyForceCenter";["summary"] = "\
Applies linear force to the entity ";["private"] = false;["classlib"] = "Entity";["description"] = "\
Applies linear force to the entity";["param"] = { [1] = "vec";["vec"] = "The force vector"; }; };["isValid"] = { ["ret"] = "True if valid, false if not";["class"] = "function";["realm"] = "sh";["summary"] = "\
Checks if an entity is valid.";["fname"] = "isValid";["classlib"] = "Entity";["name"] = "ents_methods:isValid";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Checks if an entity is valid.";["param"] = {}; };["manipulateBonePosition"] = { ["class"] = "function";["realm"] = "sh";["fname"] = "manipulateBonePosition";["summary"] = "\
Allows manipulation of a hologram's bones' positions ";["name"] = "ents_methods:manipulateBonePosition";["classlib"] = "Entity";["private"] = false;["client"] = true;["description"] = "\
Allows manipulation of a hologram's bones' positions";["param"] = { [1] = "bone";[2] = "vec";["vec"] = "The position it should be manipulated to";["bone"] = "The bone ID"; }; };["getBonePosition"] = { ["ret"] = { [1] = "Position of the bone";[2] = "Angle of the bone"; };["class"] = "function";["realm"] = "sh";["summary"] = "\
Returns the bone's position and angle in world coordinates ";["fname"] = "getBonePosition";["classlib"] = "Entity";["name"] = "ents_methods:getBonePosition";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Returns the bone's position and angle in world coordinates";["param"] = { [1] = "bone";["bone"] = "Bone index. (def 0)"; }; };["getAngleVelocity"] = { ["ret"] = "The angular velocity as a vector";["class"] = "function";["realm"] = "sh";["summary"] = "\
Returns the angular velocity of the entity ";["fname"] = "getAngleVelocity";["classlib"] = "Entity";["name"] = "ents_methods:getAngleVelocity";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Returns the angular velocity of the entity";["param"] = {}; };["getSkin"] = { ["ret"] = "Skin number";["class"] = "function";["realm"] = "sh";["summary"] = "\
Gets the skin number of the entity ";["fname"] = "getSkin";["classlib"] = "Entity";["name"] = "ents_methods:getSkin";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Gets the skin number of the entity";["param"] = {}; };["getAttachmentParent"] = { ["ret"] = "number index of the attachment the entity is parented to or 0";["class"] = "function";["realm"] = "sh";["summary"] = "\
Gets the attachment index the entity is parented to ";["fname"] = "getAttachmentParent";["classlib"] = "Entity";["name"] = "ents_methods:getAttachmentParent";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Gets the attachment index the entity is parented to";["param"] = {}; };["getClass"] = { ["ret"] = "The string class name";["class"] = "function";["realm"] = "sh";["summary"] = "\
Returns the class of the entity ";["fname"] = "getClass";["classlib"] = "Entity";["name"] = "ents_methods:getClass";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Returns the class of the entity";["param"] = {}; };["getBoneName"] = { ["ret"] = "Name of the bone";["class"] = "function";["realm"] = "sh";["summary"] = "\
Returns the name of an entity's bone ";["fname"] = "getBoneName";["classlib"] = "Entity";["name"] = "ents_methods:getBoneName";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Returns the name of an entity's bone";["param"] = { [1] = "bone";["bone"] = "Bone index. (def 0)"; }; };["obbCenter"] = { ["ret"] = "The position vector of the outer bounding box center";["class"] = "function";["realm"] = "sh";["summary"] = "\
Returns the local position of the entity's outer bounding box ";["fname"] = "obbCenter";["classlib"] = "Entity";["name"] = "ents_methods:obbCenter";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Returns the local position of the entity's outer bounding box";["param"] = {}; };["getModel"] = { ["ret"] = "Model of the entity";["class"] = "function";["realm"] = "sh";["summary"] = "\
Gets the model of an entity ";["fname"] = "getModel";["classlib"] = "Entity";["name"] = "ents_methods:getModel";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Gets the model of an entity";["param"] = {}; };["getOwner"] = { ["ret"] = "Owner";["class"] = "function";["fname"] = "getOwner";["realm"] = "sv";["name"] = "ents_methods:getOwner";["summary"] = "\
Gets the owner of the entity ";["private"] = false;["classlib"] = "Entity";["description"] = "\
Gets the owner of the entity";["param"] = {}; };["getBoneCount"] = { ["ret"] = "Number of bones";["class"] = "function";["realm"] = "sh";["summary"] = "\
Returns the number of an entity's bones ";["fname"] = "getBoneCount";["classlib"] = "Entity";["name"] = "ents_methods:getBoneCount";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Returns the number of an entity's bones";["param"] = {}; };["setSolid"] = { ["class"] = "function";["fname"] = "setSolid";["realm"] = "sv";["name"] = "ents_methods:setSolid";["summary"] = "\
Sets the entity to be Solid or not.";["private"] = false;["classlib"] = "Entity";["description"] = "\
Sets the entity to be Solid or not. \
For more information please refer to GLua function http://wiki.garrysmod.com/page/Entity/SetNotSolid";["param"] = { [1] = "solid";["solid"] = "Boolean, Should the entity be solid?"; }; };["getEyePos"] = { ["ret"] = { [1] = "Eye position of the entity";[2] = "In case of a ragdoll, the position of the second eye"; };["class"] = "function";["realm"] = "sh";["summary"] = "\
Gets the entity's eye position ";["fname"] = "getEyePos";["classlib"] = "Entity";["name"] = "ents_methods:getEyePos";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Gets the entity's eye position";["param"] = {}; };["getColor"] = { ["ret"] = "Color";["class"] = "function";["realm"] = "sh";["summary"] = "\
Gets the color of an entity ";["fname"] = "getColor";["classlib"] = "Entity";["name"] = "ents_methods:getColor";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Gets the color of an entity";["param"] = {}; };["entIndex"] = { ["ret"] = "The numerical index of the entity";["class"] = "function";["realm"] = "sh";["summary"] = "\
Returns the EntIndex of the entity ";["fname"] = "entIndex";["classlib"] = "Entity";["name"] = "ents_methods:entIndex";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Returns the EntIndex of the entity";["param"] = {}; };["setHologramMesh"] = { ["class"] = "function";["realm"] = "sh";["fname"] = "setHologramMesh";["summary"] = "\
Sets a hologram entity's model to a custom Mesh ";["name"] = "ents_methods:setHologramMesh";["classlib"] = "Entity";["private"] = false;["client"] = true;["description"] = "\
Sets a hologram entity's model to a custom Mesh";["param"] = { [1] = "mesh";["mesh"] = "The mesh to set it to or nil to set back to normal"; }; };["getInertia"] = { ["ret"] = "The principle moments of inertia as a vector";["class"] = "function";["realm"] = "sh";["summary"] = "\
Returns the principle moments of inertia of the entity ";["fname"] = "getInertia";["classlib"] = "Entity";["name"] = "ents_methods:getInertia";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Returns the principle moments of inertia of the entity";["param"] = {}; };["isPlayer"] = { ["ret"] = "True if player, false if not";["class"] = "function";["realm"] = "sh";["summary"] = "\
Checks if an entity is a player.";["fname"] = "isPlayer";["classlib"] = "Entity";["name"] = "ents_methods:isPlayer";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Checks if an entity is a player.";["param"] = {}; };["setInertia"] = { ["class"] = "function";["fname"] = "setInertia";["realm"] = "sv";["name"] = "ents_methods:setInertia";["summary"] = "\
Sets the entity's inertia ";["private"] = false;["classlib"] = "Entity";["description"] = "\
Sets the entity's inertia";["param"] = { [1] = "vec";["vec"] = "Inertia tensor"; }; };["linkComponent"] = { ["class"] = "function";["fname"] = "linkComponent";["realm"] = "sv";["name"] = "ents_methods:linkComponent";["summary"] = "\
Links starfall components to a starfall processor or vehicle.";["private"] = false;["classlib"] = "Entity";["description"] = "\
Links starfall components to a starfall processor or vehicle. Screen can only connect to processor. HUD can connect to processor and vehicle.";["param"] = { [1] = "e";["e"] = "Entity to link the component to. nil to clear links."; }; };["isWeapon"] = { ["ret"] = "True if weapon, false if not";["class"] = "function";["realm"] = "sh";["summary"] = "\
Checks if an entity is a weapon.";["fname"] = "isWeapon";["classlib"] = "Entity";["name"] = "ents_methods:isWeapon";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Checks if an entity is a weapon.";["param"] = {}; };["setRenderFX"] = { ["class"] = "function";["realm"] = "sv";["summary"] = "\
Sets the renderfx of the entity ";["classForced"] = true;["fname"] = "setRenderFX";["name"] = "ents_methods:setRenderFX";["classlib"] = "Entity";["private"] = false;["server"] = true;["description"] = "\
Sets the renderfx of the entity";["param"] = { [1] = "renderfx";[2] = "ply";["renderfx"] = "Number, renderfx to use. http://wiki.garrysmod.com/page/Enums/kRenderFx";["ply"] = "Optional player argument to set only for that player. Can also be table of players."; }; };["obbSize"] = { ["ret"] = "The outer bounding box size";["class"] = "function";["realm"] = "sh";["summary"] = "\
Returns the x, y, z size of the entity's outer bounding box (local to the entity) ";["fname"] = "obbSize";["classlib"] = "Entity";["name"] = "ents_methods:obbSize";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Returns the x, y, z size of the entity's outer bounding box (local to the entity)";["param"] = {}; };["breakEnt"] = { ["class"] = "function";["fname"] = "breakEnt";["realm"] = "sv";["name"] = "ents_methods:breakEnt";["summary"] = "\
Invokes the entity's breaking animation and removes it.";["private"] = false;["classlib"] = "Entity";["description"] = "\
Invokes the entity's breaking animation and removes it.";["param"] = {}; };["getAngleVelocityAngle"] = { ["ret"] = "The angular velocity as an angle";["class"] = "function";["realm"] = "sh";["summary"] = "\
Returns the angular velocity of the entity ";["fname"] = "getAngleVelocityAngle";["classlib"] = "Entity";["name"] = "ents_methods:getAngleVelocityAngle";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Returns the angular velocity of the entity";["param"] = {}; };["applyDamage"] = { ["class"] = "function";["fname"] = "applyDamage";["realm"] = "sv";["name"] = "ents_methods:applyDamage";["summary"] = "\
Applies damage to an entity ";["private"] = false;["classlib"] = "Entity";["description"] = "\
Applies damage to an entity";["param"] = { [1] = "amt";[2] = "attacker";[3] = "inflictor";["inflictor"] = "damage inflictor";["attacker"] = "damage attacker";["amt"] = "damage amount"; }; };["getHealth"] = { ["ret"] = "Health of the entity";["class"] = "function";["realm"] = "sh";["summary"] = "\
Gets the health of an entity ";["fname"] = "getHealth";["classlib"] = "Entity";["name"] = "ents_methods:getHealth";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Gets the health of an entity";["param"] = {}; };["getBoneParent"] = { ["ret"] = "Parent index of the bone";["class"] = "function";["realm"] = "sh";["summary"] = "\
Returns the parent index of an entity's bone ";["fname"] = "getBoneParent";["classlib"] = "Entity";["name"] = "ents_methods:getBoneParent";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Returns the parent index of an entity's bone";["param"] = { [1] = "bone";["bone"] = "Bone index. (def 0)"; }; };["getAttachment"] = { ["ret"] = "vector position, and angle orientation";["class"] = "function";["realm"] = "sh";["summary"] = "\
Gets the position and angle of an attachment ";["fname"] = "getAttachment";["classlib"] = "Entity";["name"] = "ents_methods:getAttachment";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Gets the position and angle of an attachment";["param"] = { [1] = "index";["index"] = "The index of the attachment"; }; };["getUp"] = { ["ret"] = "Vector up";["class"] = "function";["realm"] = "sh";["summary"] = "\
Gets the entity's up vector ";["fname"] = "getUp";["classlib"] = "Entity";["name"] = "ents_methods:getUp";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Gets the entity's up vector";["param"] = {}; };["emitSound"] = { ["class"] = "function";["fname"] = "emitSound";["realm"] = "sv";["name"] = "ents_methods:emitSound";["summary"] = "\
Plays a sound on the entity ";["private"] = false;["classlib"] = "Entity";["description"] = "\
Plays a sound on the entity";["param"] = { [1] = "snd";[2] = "lvl";[3] = "pitch";[4] = "volume";[5] = "channel";["pitch"] = "pitchPercent=100";["snd"] = "string Sound path";["lvl"] = "number soundLevel=75";["channel"] = "channel=CHAN_AUTO";["volume"] = "volume=1"; }; };["unparent"] = { ["class"] = "function";["fname"] = "unparent";["realm"] = "sv";["name"] = "ents_methods:unparent";["summary"] = "\
Unparents the entity from another entity ";["private"] = false;["classlib"] = "Entity";["description"] = "\
Unparents the entity from another entity";["param"] = {}; };["ignite"] = { ["class"] = "function";["fname"] = "ignite";["realm"] = "sv";["name"] = "ents_methods:ignite";["summary"] = "\
Ignites an entity ";["private"] = false;["classlib"] = "Entity";["description"] = "\
Ignites an entity";["param"] = { [1] = "length";[2] = "radius";["radius"] = "(optional) How large the fire hitbox is (entity obb is the max)";["length"] = "How long the fire lasts"; }; };["localToWorldAngles"] = { ["ret"] = "data as world space angle";["class"] = "function";["realm"] = "sh";["summary"] = "\
Converts an angle in entity local space to world space ";["fname"] = "localToWorldAngles";["classlib"] = "Entity";["name"] = "ents_methods:localToWorldAngles";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Converts an angle in entity local space to world space";["param"] = { [1] = "data";["data"] = "Local space angle"; }; };["getAngles"] = { ["ret"] = "The angle";["class"] = "function";["realm"] = "sh";["summary"] = "\
Returns the angle of the entity ";["fname"] = "getAngles";["classlib"] = "Entity";["name"] = "ents_methods:getAngles";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Returns the angle of the entity";["param"] = {}; };["applyForceOffset"] = { ["class"] = "function";["fname"] = "applyForceOffset";["realm"] = "sv";["name"] = "ents_methods:applyForceOffset";["summary"] = "\
Applies linear force to the entity with an offset ";["private"] = false;["classlib"] = "Entity";["description"] = "\
Applies linear force to the entity with an offset";["param"] = { [1] = "vec";[2] = "offset";["offset"] = "An optional offset position";["vec"] = "The force vector"; }; };["remove"] = { ["class"] = "function";["fname"] = "remove";["realm"] = "sv";["name"] = "ents_methods:remove";["summary"] = "\
Removes an entity ";["private"] = false;["classlib"] = "Entity";["description"] = "\
Removes an entity";["param"] = {}; };["isValidPhys"] = { ["ret"] = "True if entity has physics";["class"] = "function";["fname"] = "isValidPhys";["realm"] = "sv";["name"] = "ents_methods:isValidPhys";["summary"] = "\
Checks whether entity has physics ";["private"] = false;["classlib"] = "Entity";["description"] = "\
Checks whether entity has physics";["param"] = {}; };["enableGravity"] = { ["class"] = "function";["fname"] = "enableGravity";["realm"] = "sv";["name"] = "ents_methods:enableGravity";["summary"] = "\
Sets entity gravity ";["private"] = false;["classlib"] = "Entity";["description"] = "\
Sets entity gravity";["param"] = { [1] = "grav";["grav"] = "Bool should the entity respect gravity?"; }; };["enableDrag"] = { ["class"] = "function";["fname"] = "enableDrag";["realm"] = "sv";["name"] = "ents_methods:enableDrag";["summary"] = "\
Sets the entity drag state ";["private"] = false;["classlib"] = "Entity";["description"] = "\
Sets the entity drag state";["param"] = { [1] = "drag";["drag"] = "Bool should the entity have air resistence?"; }; };["lookupAttachment"] = { ["ret"] = "number of the attachment index, or 0 if it doesn't exist";["class"] = "function";["realm"] = "sh";["summary"] = "\
Gets the attachment index via the entity and it's attachment name ";["fname"] = "lookupAttachment";["classlib"] = "Entity";["name"] = "ents_methods:lookupAttachment";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Gets the attachment index via the entity and it's attachment name";["param"] = { [1] = "name";["name"] = ""; }; };["getBoneMatrix"] = { ["ret"] = "The matrix";["class"] = "function";["realm"] = "sh";["summary"] = "\
Returns the matrix of the entity's bone ";["fname"] = "getBoneMatrix";["classlib"] = "Entity";["name"] = "ents_methods:getBoneMatrix";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Returns the matrix of the entity's bone";["param"] = { [1] = "bone";["bone"] = "Bone index. (def 0)"; }; };["setTrails"] = { ["class"] = "function";["fname"] = "setTrails";["realm"] = "sv";["name"] = "ents_methods:setTrails";["summary"] = "\
Adds a trail to the entity with the specified attributes.";["private"] = false;["classlib"] = "Entity";["description"] = "\
Adds a trail to the entity with the specified attributes.";["param"] = { [1] = "startSize";[2] = "endSize";[3] = "length";[4] = "material";[5] = "color";[6] = "attachmentID";[7] = "additive";["startSize"] = "The start size of the trail";["attachmentID"] = "Optional attachmentid the trail should attach to";["length"] = "The length size of the trail";["color"] = "The color of the trail";["material"] = "The material of the trail";["endSize"] = "The end size of the trail";["additive"] = "If the trail's rendering is additive"; }; };["removeCollisionListener"] = { ["class"] = "function";["fname"] = "removeCollisionListener";["realm"] = "sv";["name"] = "ents_methods:removeCollisionListener";["summary"] = "\
Removes a collision listening hook from the entity so that a new one can be added ";["private"] = false;["classlib"] = "Entity";["description"] = "\
Removes a collision listening hook from the entity so that a new one can be added";["param"] = {}; };["isOnGround"] = { ["ret"] = "Boolean if it's flag is set or not";["class"] = "function";["realm"] = "sh";["summary"] = "\
Checks if the entity ONGROUND flag is set ";["fname"] = "isOnGround";["classlib"] = "Entity";["name"] = "ents_methods:isOnGround";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Checks if the entity ONGROUND flag is set";["param"] = {}; };["enableMotion"] = { ["class"] = "function";["fname"] = "enableMotion";["realm"] = "sv";["name"] = "ents_methods:enableMotion";["summary"] = "\
Sets the entity movement state ";["private"] = false;["classlib"] = "Entity";["description"] = "\
Sets the entity movement state";["param"] = { [1] = "move";["move"] = "Bool should the entity move?"; }; };["enableSphere"] = { ["class"] = "function";["fname"] = "enableSphere";["realm"] = "sv";["name"] = "ents_methods:enableSphere";["summary"] = "\
Sets the physics of an entity to be a sphere ";["private"] = false;["classlib"] = "Entity";["description"] = "\
Sets the physics of an entity to be a sphere";["param"] = { [1] = "enabled";["enabled"] = "Bool should the entity be spherical?"; }; };["getPhysicsObjectNum"] = { ["ret"] = "The physics object of the entity";["class"] = "function";["fname"] = "getPhysicsObjectNum";["realm"] = "sh";["name"] = "ents_methods:getPhysicsObjectNum";["summary"] = "\
Gets a physics objects of an entity ";["private"] = false;["classlib"] = "Entity";["description"] = "\
Gets a physics objects of an entity";["param"] = { [1] = "id";["id"] = "The physics object id (starts at 0)"; }; };["isFrozen"] = { ["ret"] = "True if entity is frozen";["class"] = "function";["fname"] = "isFrozen";["realm"] = "sv";["name"] = "ents_methods:isFrozen";["summary"] = "\
Checks the entities frozen state ";["private"] = false;["classlib"] = "Entity";["description"] = "\
Checks the entities frozen state";["param"] = {}; };["setDrawShadow"] = { ["class"] = "function";["fname"] = "setDrawShadow";["realm"] = "sv";["name"] = "ents_methods:setDrawShadow";["summary"] = "\
Sets whether an entity's shadow should be drawn ";["private"] = false;["classlib"] = "Entity";["description"] = "\
Sets whether an entity's shadow should be drawn";["param"] = { [1] = "draw";[2] = "ply";["ply"] = "Optional player argument to set only for that player. Can also be table of players."; }; };["getEyeAngles"] = { ["ret"] = "Angles of the entity's eyes";["class"] = "function";["realm"] = "sh";["summary"] = "\
Gets the entitiy's eye angles ";["fname"] = "getEyeAngles";["classlib"] = "Entity";["name"] = "ents_methods:getEyeAngles";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Gets the entitiy's eye angles";["param"] = {}; };["applyAngForce"] = { ["class"] = "function";["fname"] = "applyAngForce";["realm"] = "sv";["name"] = "ents_methods:applyAngForce";["summary"] = "\
Applies angular force to the entity ";["private"] = false;["classlib"] = "Entity";["description"] = "\
Applies angular force to the entity";["param"] = { [1] = "ang";["ang"] = "The force angle"; }; };["getMaterials"] = { ["ret"] = "Material";["realm"] = "sh";["class"] = "function";["summary"] = "\
Gets an entities' material list ";["fname"] = "getMaterials";["classForced"] = true;["classlib"] = "Entity";["name"] = "ents_methods:getMaterials";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Gets an entities' material list";["param"] = {}; };["isWeldedTo"] = { ["class"] = "function";["fname"] = "isWeldedTo";["realm"] = "sv";["name"] = "ents_methods:isWeldedTo";["summary"] = "\
Gets what the entity is welded to ";["private"] = false;["classlib"] = "Entity";["description"] = "\
Gets what the entity is welded to";["param"] = {}; };["getForward"] = { ["ret"] = "Vector forward";["class"] = "function";["realm"] = "sh";["summary"] = "\
Gets the entity's forward vector ";["fname"] = "getForward";["classlib"] = "Entity";["name"] = "ents_methods:getForward";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Gets the entity's forward vector";["param"] = {}; };["worldToLocalAngles"] = { ["ret"] = "data as local space angle";["class"] = "function";["realm"] = "sh";["summary"] = "\
Converts an angle in world space to entity local space ";["fname"] = "worldToLocalAngles";["classlib"] = "Entity";["name"] = "ents_methods:worldToLocalAngles";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Converts an angle in world space to entity local space";["param"] = { [1] = "data";["data"] = "World space angle"; }; };["getVelocity"] = { ["ret"] = "The velocity vector";["class"] = "function";["realm"] = "sh";["summary"] = "\
Returns the velocity of the entity ";["fname"] = "getVelocity";["classlib"] = "Entity";["name"] = "ents_methods:getVelocity";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Returns the velocity of the entity";["param"] = {}; };["manipulateBoneAngles"] = { ["class"] = "function";["realm"] = "sh";["fname"] = "manipulateBoneAngles";["summary"] = "\
Allows manipulation of a hologram's bones' angles ";["name"] = "ents_methods:manipulateBoneAngles";["classlib"] = "Entity";["private"] = false;["client"] = true;["description"] = "\
Allows manipulation of a hologram's bones' angles";["param"] = { [1] = "bone";[2] = "ang";["ang"] = "The angle it should be manipulated to";["bone"] = "The bone ID"; }; };["setColor"] = { ["class"] = "function";["realm"] = "sv";["fname"] = "setColor";["summary"] = "\
Sets the color of the entity ";["name"] = "ents_methods:setColor";["classlib"] = "Entity";["private"] = false;["server"] = true;["description"] = "\
Sets the color of the entity";["param"] = { [1] = "clr";[2] = "ply";["clr"] = "New color";["ply"] = "Optional player argument to set only for that player. Can also be table of players."; }; };["isNPC"] = { ["ret"] = "True if npc, false if not";["class"] = "function";["realm"] = "sh";["summary"] = "\
Checks if an entity is an npc.";["fname"] = "isNPC";["classlib"] = "Entity";["name"] = "ents_methods:isNPC";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Checks if an entity is an npc.";["param"] = {}; };["setBodygroup"] = { ["class"] = "function";["realm"] = "sv";["summary"] = "\
Sets an entities' bodygroup ";["classForced"] = true;["fname"] = "setBodygroup";["name"] = "ents_methods:setBodygroup";["classlib"] = "Entity";["private"] = false;["server"] = true;["description"] = "\
Sets an entities' bodygroup";["param"] = { [1] = "bodygroup";[2] = "value";[3] = "ply";["bodygroup"] = "Number, The ID of the bodygroup you're setting.";["ply"] = "Optional player argument to set only for that player. Can also be table of players.";["value"] = "Number, The value you're setting the bodygroup to."; }; };["setFrozen"] = { ["class"] = "function";["fname"] = "setFrozen";["realm"] = "sv";["name"] = "ents_methods:setFrozen";["summary"] = "\
Sets the entity frozen state ";["private"] = false;["classlib"] = "Entity";["description"] = "\
Sets the entity frozen state";["param"] = { [1] = "freeze";["freeze"] = "Should the entity be frozen?"; }; };["isVehicle"] = { ["ret"] = "True if vehicle, false if not";["class"] = "function";["realm"] = "sh";["summary"] = "\
Checks if an entity is a vehicle.";["fname"] = "isVehicle";["classlib"] = "Entity";["name"] = "ents_methods:isVehicle";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Checks if an entity is a vehicle.";["param"] = {}; };["setHologramRenderBounds"] = { ["class"] = "function";["realm"] = "sh";["fname"] = "setHologramRenderBounds";["summary"] = "\
Sets a hologram entity's renderbounds ";["name"] = "ents_methods:setHologramRenderBounds";["classlib"] = "Entity";["private"] = false;["client"] = true;["description"] = "\
Sets a hologram entity's renderbounds";["param"] = { [1] = "mins";[2] = "maxs";["maxs"] = "The upper bounding corner coordinate local to the hologram";["mins"] = "The lower bounding corner coordinate local to the hologram"; }; };["manipulateBoneScale"] = { ["class"] = "function";["realm"] = "sh";["fname"] = "manipulateBoneScale";["summary"] = "\
Allows manipulation of a hologram's bones' scale ";["name"] = "ents_methods:manipulateBoneScale";["classlib"] = "Entity";["private"] = false;["client"] = true;["description"] = "\
Allows manipulation of a hologram's bones' scale";["param"] = { [1] = "bone";[2] = "vec";["vec"] = "The scale it should be manipulated to";["bone"] = "The bone ID"; }; };["setMaterial"] = { ["class"] = "function";["realm"] = "sv";["summary"] = "\
Sets an entities' material ";["classForced"] = true;["fname"] = "setMaterial";["name"] = "ents_methods:setMaterial";["classlib"] = "Entity";["private"] = false;["server"] = true;["description"] = "\
Sets an entities' material";["param"] = { [1] = "material";[2] = "ply";["material"] = ", string, New material name.";["ply"] = "Optional player argument to set only for that player. Can also be table of players."; }; };["getMass"] = { ["ret"] = "The numerical mass";["class"] = "function";["realm"] = "sh";["summary"] = "\
Returns the mass of the entity ";["fname"] = "getMass";["classlib"] = "Entity";["name"] = "ents_methods:getMass";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Returns the mass of the entity";["param"] = {}; };["getMaxHealth"] = { ["ret"] = "Max Health of the entity";["class"] = "function";["realm"] = "sh";["summary"] = "\
Gets the max health of an entity ";["fname"] = "getMaxHealth";["classlib"] = "Entity";["name"] = "ents_methods:getMaxHealth";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Gets the max health of an entity";["param"] = {}; };["extinguish"] = { ["class"] = "function";["fname"] = "extinguish";["realm"] = "sv";["name"] = "ents_methods:extinguish";["summary"] = "\
Extinguishes an entity ";["private"] = false;["classlib"] = "Entity";["description"] = "\
Extinguishes an entity";["param"] = {}; };["setAngles"] = { ["class"] = "function";["fname"] = "setAngles";["realm"] = "sv";["name"] = "ents_methods:setAngles";["summary"] = "\
Sets the entity's angles ";["private"] = false;["classlib"] = "Entity";["description"] = "\
Sets the entity's angles";["param"] = { [1] = "ang";["ang"] = "New angles"; }; };["translateBoneToPhysBone"] = { ["ret"] = "The physobj id";["class"] = "function";["fname"] = "translateBoneToPhysBone";["realm"] = "sh";["name"] = "ents_methods:translateBoneToPhysBone";["summary"] = "\
Converts a ragdoll bone id to the corresponding physobject id ";["private"] = false;["classlib"] = "Entity";["description"] = "\
Converts a ragdoll bone id to the corresponding physobject id";["param"] = { [1] = "boneid";["boneid"] = "The ragdoll boneid"; }; };["setSkin"] = { ["class"] = "function";["realm"] = "sv";["summary"] = "\
Sets the skin of the entity ";["classForced"] = true;["fname"] = "setSkin";["name"] = "ents_methods:setSkin";["classlib"] = "Entity";["private"] = false;["server"] = true;["description"] = "\
Sets the skin of the entity";["param"] = { [1] = "skinIndex";[2] = "ply";["skinIndex"] = "Number, Index of the skin to use.";["ply"] = "Optional player argument to set only for that player. Can also be table of players."; }; };["addCollisionListener"] = { ["class"] = "function";["fname"] = "addCollisionListener";["realm"] = "sv";["name"] = "ents_methods:addCollisionListener";["summary"] = "\
Allows detecting collisions on an entity.";["private"] = false;["classlib"] = "Entity";["description"] = "\
Allows detecting collisions on an entity. You can only do this once for the entity's entire lifespan so use it wisely.";["param"] = { [1] = "func";["func"] = "The callback function with argument, table collsiondata, http://wiki.garrysmod.com/page/Structures/CollisionData"; }; };["setNoDraw"] = { ["class"] = "function";["realm"] = "sv";["fname"] = "setNoDraw";["summary"] = "\
Sets the whether an entity should be drawn or not ";["name"] = "ents_methods:setNoDraw";["classlib"] = "Entity";["private"] = false;["server"] = true;["description"] = "\
Sets the whether an entity should be drawn or not";["param"] = { [1] = "draw";[2] = "ply";["draw"] = "Whether to draw the entity or not.";["ply"] = "Optional player argument to set only for that player. Can also be table of players."; }; };["setVelocity"] = { ["class"] = "function";["fname"] = "setVelocity";["realm"] = "sv";["name"] = "ents_methods:setVelocity";["summary"] = "\
Sets the entity's linear velocity ";["private"] = false;["classlib"] = "Entity";["description"] = "\
Sets the entity's linear velocity";["param"] = { [1] = "vel";["vel"] = "New velocity"; }; };["localToWorld"] = { ["ret"] = "data as world space vector";["class"] = "function";["realm"] = "sh";["summary"] = "\
Converts a vector in entity local space to world space ";["fname"] = "localToWorld";["classlib"] = "Entity";["name"] = "ents_methods:localToWorld";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Converts a vector in entity local space to world space";["param"] = { [1] = "data";["data"] = "Local space vector"; }; };["setPhysMaterial"] = { ["class"] = "function";["fname"] = "setPhysMaterial";["realm"] = "sv";["name"] = "ents_methods:setPhysMaterial";["summary"] = "\
Sets the physical material of the entity ";["private"] = false;["classlib"] = "Entity";["description"] = "\
Sets the physical material of the entity";["param"] = { [1] = "mat";["mat"] = "Material to use"; }; };["getMaterial"] = { ["ret"] = "String material";["realm"] = "sh";["class"] = "function";["summary"] = "\
Gets an entities' material ";["fname"] = "getMaterial";["classForced"] = true;["classlib"] = "Entity";["name"] = "ents_methods:getMaterial";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Gets an entities' material";["param"] = {}; };["getSubMaterial"] = { ["ret"] = "String material";["realm"] = "sh";["class"] = "function";["summary"] = "\
Gets an entities' submaterial ";["fname"] = "getSubMaterial";["classForced"] = true;["classlib"] = "Entity";["name"] = "ents_methods:getSubMaterial";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Gets an entities' submaterial";["param"] = { [1] = "index"; }; };["lookupBone"] = { ["ret"] = "The bone index";["class"] = "function";["realm"] = "sh";["summary"] = "\
Returns the ragdoll bone index given a bone name ";["fname"] = "lookupBone";["classlib"] = "Entity";["name"] = "ents_methods:lookupBone";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Returns the ragdoll bone index given a bone name";["param"] = { [1] = "name";["name"] = "The bone's string name"; }; };["getPos"] = { ["ret"] = "The position vector";["class"] = "function";["realm"] = "sh";["summary"] = "\
Returns the position of the entity ";["fname"] = "getPos";["classlib"] = "Entity";["name"] = "ents_methods:getPos";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Returns the position of the entity";["param"] = {}; };["removeTrails"] = { ["class"] = "function";["fname"] = "removeTrails";["realm"] = "sv";["name"] = "ents_methods:removeTrails";["summary"] = "\
Removes trails from the entity ";["private"] = false;["classlib"] = "Entity";["description"] = "\
Removes trails from the entity";["param"] = {}; };["getMassCenter"] = { ["ret"] = "The position vector of the mass center";["class"] = "function";["realm"] = "sh";["summary"] = "\
Returns the local position of the entity's mass center ";["fname"] = "getMassCenter";["classlib"] = "Entity";["name"] = "ents_methods:getMassCenter";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Returns the local position of the entity's mass center";["param"] = {}; };["worldToLocal"] = { ["ret"] = "data as local space vector";["class"] = "function";["realm"] = "sh";["summary"] = "\
Converts a vector in world space to entity local space ";["fname"] = "worldToLocal";["classlib"] = "Entity";["name"] = "ents_methods:worldToLocal";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Converts a vector in world space to entity local space";["param"] = { [1] = "data";["data"] = "World space vector"; }; };["setParent"] = { ["class"] = "function";["fname"] = "setParent";["realm"] = "sv";["name"] = "ents_methods:setParent";["summary"] = "\
Parents the entity to another entity ";["private"] = false;["classlib"] = "Entity";["description"] = "\
Parents the entity to another entity";["param"] = { [1] = "ent";[2] = "attachment";["attachment"] = "Optional string attachment name to parent to";["ent"] = "Entity to parent to"; }; };["obbCenterW"] = { ["ret"] = "The position vector of the outer bounding box center";["class"] = "function";["realm"] = "sh";["summary"] = "\
Returns the world position of the entity's outer bounding box ";["fname"] = "obbCenterW";["classlib"] = "Entity";["name"] = "ents_methods:obbCenterW";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Returns the world position of the entity's outer bounding box";["param"] = {}; };["setMass"] = { ["class"] = "function";["fname"] = "setMass";["realm"] = "sv";["name"] = "ents_methods:setMass";["summary"] = "\
Sets the entity's mass ";["private"] = false;["classlib"] = "Entity";["description"] = "\
Sets the entity's mass";["param"] = { [1] = "mass";["mass"] = "number mass"; }; };["getMassCenterW"] = { ["ret"] = "The position vector of the mass center";["class"] = "function";["realm"] = "sh";["summary"] = "\
Returns the world position of the entity's mass center ";["fname"] = "getMassCenterW";["classlib"] = "Entity";["name"] = "ents_methods:getMassCenterW";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Returns the world position of the entity's mass center";["param"] = {}; };["getParent"] = { ["ret"] = "Entity's parent or nil";["class"] = "function";["realm"] = "sh";["summary"] = "\
Gets the parent of an entity ";["fname"] = "getParent";["classlib"] = "Entity";["name"] = "ents_methods:getParent";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Gets the parent of an entity";["param"] = {}; };["setRenderMode"] = { ["class"] = "function";["realm"] = "sv";["summary"] = "\
Sets the rende mode of the entity ";["classForced"] = true;["fname"] = "setRenderMode";["name"] = "ents_methods:setRenderMode";["classlib"] = "Entity";["private"] = false;["server"] = true;["description"] = "\
Sets the rende mode of the entity";["param"] = { [1] = "rendermode";[2] = "ply";["ply"] = "Optional player argument to set only for that player. Can also be table of players.";["rendermode"] = "Number, rendermode to use. http://wiki.garrysmod.com/page/Enums/RENDERMODE"; }; };["getPhysicsObject"] = { ["ret"] = "The main physics object of the entity";["class"] = "function";["fname"] = "getPhysicsObject";["realm"] = "sh";["name"] = "ents_methods:getPhysicsObject";["summary"] = "\
Gets the main physics objects of an entity ";["private"] = false;["classlib"] = "Entity";["description"] = "\
Gets the main physics objects of an entity";["param"] = {}; }; }; };["Vehicle"] = { ["typtbl"] = "vehicle_methods";["fields"] = {};["name"] = "Vehicle";["summary"] = "\
Vehicle type ";["description"] = "\
Vehicle type";["class"] = "class";["methods"] = { [1] = "ejectDriver";[2] = "getDriver";[3] = "getPassenger";["getDriver"] = { ["ret"] = "Driver of vehicle";["class"] = "function";["realm"] = "sh";["fname"] = "getDriver";["summary"] = "\
Returns the driver of the vehicle ";["name"] = "vehicle_methods:getDriver";["classlib"] = "Vehicle";["private"] = false;["server"] = true;["description"] = "\
Returns the driver of the vehicle";["param"] = {}; };["getPassenger"] = { ["ret"] = "amount of ammo";["class"] = "function";["realm"] = "sh";["fname"] = "getPassenger";["summary"] = "\
Returns a passenger of a vehicle ";["name"] = "vehicle_methods:getPassenger";["classlib"] = "Vehicle";["private"] = false;["server"] = true;["description"] = "\
Returns a passenger of a vehicle";["param"] = { [1] = "n";["n"] = "The index of the passenger to get"; }; };["ejectDriver"] = { ["class"] = "function";["realm"] = "sh";["fname"] = "ejectDriver";["summary"] = "\
Ejects the driver of the vehicle ";["name"] = "vehicle_methods:ejectDriver";["classlib"] = "Vehicle";["private"] = false;["server"] = true;["description"] = "\
Ejects the driver of the vehicle";["param"] = {}; }; }; };["Mesh"] = { ["typtbl"] = "mesh_methods";["fields"] = {};["name"] = "Mesh";["summary"] = "\
Mesh type ";["description"] = "\
Mesh type";["client"] = true;["class"] = "class";["methods"] = { [1] = "destroy";[2] = "draw";["destroy"] = { ["class"] = "function";["fname"] = "destroy";["realm"] = "cl";["name"] = "mesh_methods:destroy";["summary"] = "\
Frees the mesh from memory ";["private"] = false;["classlib"] = "Mesh";["description"] = "\
Frees the mesh from memory";["param"] = {}; };["draw"] = { ["class"] = "function";["fname"] = "draw";["realm"] = "cl";["name"] = "mesh_methods:draw";["summary"] = "\
Draws the mesh.";["private"] = false;["classlib"] = "Mesh";["description"] = "\
Draws the mesh. Must be in a 3D rendering context.";["param"] = {}; }; }; };["Wirelink"] = { ["typtbl"] = "wirelink_methods";["fields"] = {};["name"] = "Wirelink";["summary"] = "\
Wirelink type ";["server"] = true;["description"] = "\
Wirelink type";["class"] = "class";["methods"] = { [1] = "entity";[2] = "getWiredTo";[3] = "getWiredToName";[4] = "inputType";[5] = "inputs";[6] = "isValid";[7] = "isWired";[8] = "outputType";[9] = "outputs";["isValid"] = { ["class"] = "function";["fname"] = "isValid";["realm"] = "sv";["name"] = "wirelink_methods:isValid";["summary"] = "\
Checks if a wirelink is valid.";["private"] = false;["classlib"] = "Wirelink";["description"] = "\
Checks if a wirelink is valid. (ie. doesn't point to an invalid entity)";["param"] = {}; };["outputType"] = { ["class"] = "function";["fname"] = "outputType";["realm"] = "sv";["name"] = "wirelink_methods:outputType";["summary"] = "\
Returns the type of output name, or nil if it doesn't exist ";["private"] = false;["classlib"] = "Wirelink";["description"] = "\
Returns the type of output name, or nil if it doesn't exist";["param"] = { [1] = "name"; }; };["getWiredTo"] = { ["ret"] = "The entity the wirelink is wired to";["class"] = "function";["fname"] = "getWiredTo";["realm"] = "sv";["name"] = "wirelink_methods:getWiredTo";["summary"] = "\
Returns what an input of the wirelink is wired to.";["private"] = false;["classlib"] = "Wirelink";["description"] = "\
Returns what an input of the wirelink is wired to.";["param"] = { [1] = "name";["name"] = "Name of the input"; }; };["inputType"] = { ["class"] = "function";["fname"] = "inputType";["realm"] = "sv";["name"] = "wirelink_methods:inputType";["summary"] = "\
Returns the type of input name, or nil if it doesn't exist ";["private"] = false;["classlib"] = "Wirelink";["description"] = "\
Returns the type of input name, or nil if it doesn't exist";["param"] = { [1] = "name"; }; };["isWired"] = { ["class"] = "function";["fname"] = "isWired";["realm"] = "sv";["name"] = "wirelink_methods:isWired";["summary"] = "\
Checks if an input is wired.";["private"] = false;["classlib"] = "Wirelink";["description"] = "\
Checks if an input is wired.";["param"] = { [1] = "name";["name"] = "Name of the input to check"; }; };["entity"] = { ["class"] = "function";["fname"] = "entity";["realm"] = "sv";["name"] = "wirelink_methods:entity";["summary"] = "\
Returns the entity that the wirelink represents ";["private"] = false;["classlib"] = "Wirelink";["description"] = "\
Returns the entity that the wirelink represents";["param"] = {}; };["getWiredToName"] = { ["ret"] = "String name of the output that the input is wired to.";["class"] = "function";["fname"] = "getWiredToName";["realm"] = "sv";["name"] = "wirelink_methods:getWiredToName";["summary"] = "\
Returns the name of the output an input of the wirelink is wired to.";["private"] = false;["classlib"] = "Wirelink";["description"] = "\
Returns the name of the output an input of the wirelink is wired to.";["param"] = { [1] = "name";["name"] = "Name of the input of the wirelink."; }; };["inputs"] = { ["class"] = "function";["fname"] = "inputs";["realm"] = "sv";["name"] = "wirelink_methods:inputs";["summary"] = "\
Returns a table of all of the wirelink's inputs ";["private"] = false;["classlib"] = "Wirelink";["description"] = "\
Returns a table of all of the wirelink's inputs";["param"] = {}; };["outputs"] = { ["class"] = "function";["fname"] = "outputs";["realm"] = "sv";["name"] = "wirelink_methods:outputs";["summary"] = "\
Returns a table of all of the wirelink's outputs ";["private"] = false;["classlib"] = "Wirelink";["description"] = "\
Returns a table of all of the wirelink's outputs";["param"] = {}; }; }; };["Player"] = { ["typtbl"] = "player_methods";["fields"] = {};["name"] = "Player";["summary"] = "\
Player type ";["description"] = "\
Player type";["class"] = "class";["methods"] = { [1] = "getActiveWeapon";[2] = "getAimVector";[3] = "getArmor";[4] = "getDeaths";[5] = "getEyeTrace";[6] = "getFOV";[7] = "getFrags";[8] = "getFriendStatus";[9] = "getJumpPower";[10] = "getMaxSpeed";[11] = "getName";[12] = "getPing";[13] = "getRunSpeed";[14] = "getShootPos";[15] = "getSteamID";[16] = "getSteamID64";[17] = "getTeam";[18] = "getTeamName";[19] = "getUniqueID";[20] = "getUserID";[21] = "getViewEntity";[22] = "getWeapon";[23] = "getWeapons";[24] = "hasGodMode";[25] = "inVehicle";[26] = "isAdmin";[27] = "isAlive";[28] = "isBot";[29] = "isConnected";[30] = "isCrouching";[31] = "isFlashlightOn";[32] = "isFrozen";[33] = "isMuted";[34] = "isNPC";[35] = "isNoclipped";[36] = "isPlayer";[37] = "isSuperAdmin";[38] = "isUserGroup";[39] = "keyDown";[40] = "setViewEntity";["isUserGroup"] = { ["ret"] = "True if player belongs to group";["class"] = "function";["realm"] = "sh";["summary"] = "\
Returns whether the player belongs to a usergroup ";["fname"] = "isUserGroup";["classlib"] = "Player";["name"] = "player_methods:isUserGroup";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Returns whether the player belongs to a usergroup";["param"] = { [1] = "group";["group"] = "Group to check against"; }; };["isBot"] = { ["ret"] = "True if player is a bot";["class"] = "function";["realm"] = "sh";["summary"] = "\
Returns whether the player is a bot ";["fname"] = "isBot";["classlib"] = "Player";["name"] = "player_methods:isBot";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Returns whether the player is a bot";["param"] = {}; };["setViewEntity"] = { ["class"] = "function";["realm"] = "sh";["fname"] = "setViewEntity";["summary"] = "\
Sets the view entity of the player.";["name"] = "player_methods:setViewEntity";["classlib"] = "Player";["private"] = false;["server"] = true;["description"] = "\
Sets the view entity of the player. Only works if they are linked to a hud.";["param"] = { [1] = "ent";["ent"] = "Entity to set the player's view entity to, or nothing to reset it"; }; };["isNoclipped"] = { ["ret"] = "true if the player is noclipped";["class"] = "function";["realm"] = "sh";["summary"] = "\
Returns true if the player is noclipped ";["fname"] = "isNoclipped";["classlib"] = "Player";["name"] = "player_methods:isNoclipped";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Returns true if the player is noclipped";["param"] = {}; };["getJumpPower"] = { ["ret"] = "Jump power";["class"] = "function";["realm"] = "sh";["summary"] = "\
Returns the player's jump power ";["fname"] = "getJumpPower";["classlib"] = "Player";["name"] = "player_methods:getJumpPower";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Returns the player's jump power";["param"] = {}; };["inVehicle"] = { ["ret"] = "True if player in vehicle";["class"] = "function";["realm"] = "sh";["summary"] = "\
Returns whether the player is in a vehicle ";["fname"] = "inVehicle";["classlib"] = "Player";["name"] = "player_methods:inVehicle";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Returns whether the player is in a vehicle";["param"] = {}; };["keyDown"] = { ["ret"] = "True or false";["class"] = "function";["realm"] = "sh";["summary"] = "\
Returns whether or not the player is pushing the key.";["fname"] = "keyDown";["classlib"] = "Player";["name"] = "player_methods:keyDown";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Returns whether or not the player is pushing the key.";["param"] = { [1] = "key";["key"] = "Key to check. \
IN_KEY.ALT1 \
IN_KEY.ALT2 \
IN_KEY.ATTACK \
IN_KEY.ATTACK2 \
IN_KEY.BACK \
IN_KEY.DUCK \
IN_KEY.FORWARD \
IN_KEY.JUMP \
IN_KEY.LEFT \
IN_KEY.MOVELEFT \
IN_KEY.MOVERIGHT \
IN_KEY.RELOAD \
IN_KEY.RIGHT \
IN_KEY.SCORE \
IN_KEY.SPEED \
IN_KEY.USE \
IN_KEY.WALK \
IN_KEY.ZOOM \
IN_KEY.GRENADE1 \
IN_KEY.GRENADE2 \
IN_KEY.WEAPON1 \
IN_KEY.WEAPON2 \
IN_KEY.BULLRUSH \
IN_KEY.CANCEL \
IN_KEY.RUN"; }; };["getFOV"] = { ["ret"] = "Field of view";["class"] = "function";["realm"] = "sh";["summary"] = "\
Returns the player's field of view ";["fname"] = "getFOV";["classlib"] = "Player";["name"] = "player_methods:getFOV";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Returns the player's field of view";["param"] = {}; };["getShootPos"] = { ["ret"] = "Shoot position";["class"] = "function";["realm"] = "sh";["summary"] = "\
Returns the player's shoot position ";["fname"] = "getShootPos";["classlib"] = "Player";["name"] = "player_methods:getShootPos";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Returns the player's shoot position";["param"] = {}; };["getTeam"] = { ["ret"] = "team";["class"] = "function";["realm"] = "sh";["summary"] = "\
Returns the player's current team ";["fname"] = "getTeam";["classlib"] = "Player";["name"] = "player_methods:getTeam";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Returns the player's current team";["param"] = {}; };["getViewEntity"] = { ["ret"] = "Player's current view entity";["class"] = "function";["realm"] = "sh";["summary"] = "\
Returns the player's current view entity ";["fname"] = "getViewEntity";["classlib"] = "Player";["name"] = "player_methods:getViewEntity";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Returns the player's current view entity";["param"] = {}; };["getArmor"] = { ["ret"] = "Armor";["class"] = "function";["realm"] = "sh";["summary"] = "\
Returns the players armor ";["fname"] = "getArmor";["classlib"] = "Player";["name"] = "player_methods:getArmor";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Returns the players armor";["param"] = {}; };["getSteamID"] = { ["ret"] = "steam ID";["class"] = "function";["realm"] = "sh";["summary"] = "\
Returns the player's steam ID ";["fname"] = "getSteamID";["classlib"] = "Player";["name"] = "player_methods:getSteamID";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Returns the player's steam ID";["param"] = {}; };["isConnected"] = { ["ret"] = "True if player is connected";["class"] = "function";["realm"] = "sh";["summary"] = "\
Returns whether the player is connected ";["fname"] = "isConnected";["classlib"] = "Player";["name"] = "player_methods:isConnected";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Returns whether the player is connected";["param"] = {}; };["getUserID"] = { ["ret"] = "user ID";["class"] = "function";["realm"] = "sh";["summary"] = "\
Returns the player's user ID ";["fname"] = "getUserID";["classlib"] = "Player";["name"] = "player_methods:getUserID";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Returns the player's user ID";["param"] = {}; };["getMaxSpeed"] = { ["ret"] = "Maximum speed";["class"] = "function";["realm"] = "sh";["summary"] = "\
Returns the player's maximum speed ";["fname"] = "getMaxSpeed";["classlib"] = "Player";["name"] = "player_methods:getMaxSpeed";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Returns the player's maximum speed";["param"] = {}; };["getSteamID64"] = { ["ret"] = "community ID";["class"] = "function";["realm"] = "sh";["summary"] = "\
Returns the player's community ID ";["fname"] = "getSteamID64";["classlib"] = "Player";["name"] = "player_methods:getSteamID64";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Returns the player's community ID";["param"] = {}; };["getRunSpeed"] = { ["ret"] = "Running speed";["class"] = "function";["realm"] = "sh";["summary"] = "\
Returns the player's running speed ";["fname"] = "getRunSpeed";["classlib"] = "Player";["name"] = "player_methods:getRunSpeed";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Returns the player's running speed";["param"] = {}; };["getAimVector"] = { ["ret"] = "Aim vector";["class"] = "function";["realm"] = "sh";["summary"] = "\
Returns the player's aim vector ";["fname"] = "getAimVector";["classlib"] = "Player";["name"] = "player_methods:getAimVector";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Returns the player's aim vector";["param"] = {}; };["getUniqueID"] = { ["ret"] = "unique ID";["class"] = "function";["realm"] = "sh";["summary"] = "\
Returns the player's unique ID ";["fname"] = "getUniqueID";["classlib"] = "Player";["name"] = "player_methods:getUniqueID";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Returns the player's unique ID";["param"] = {}; };["getFriendStatus"] = { ["ret"] = "One of: \"friend\", \"blocked\", \"none\", \"requested\"";["class"] = "function";["fname"] = "getFriendStatus";["realm"] = "sh";["name"] = "player_methods:getFriendStatus";["summary"] = "\
Returns the relationship of the player to the local client ";["private"] = false;["classlib"] = "Player";["description"] = "\
Returns the relationship of the player to the local client";["param"] = {}; };["getFrags"] = { ["ret"] = "Amount of kills";["class"] = "function";["realm"] = "sh";["summary"] = "\
Returns the amount of kills of the player ";["fname"] = "getFrags";["classlib"] = "Player";["name"] = "player_methods:getFrags";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Returns the amount of kills of the player";["param"] = {}; };["isMuted"] = { ["ret"] = "True if the player was muted";["class"] = "function";["fname"] = "isMuted";["realm"] = "sh";["name"] = "player_methods:isMuted";["summary"] = "\
Returns whether the local player has muted the player ";["private"] = false;["classlib"] = "Player";["description"] = "\
Returns whether the local player has muted the player";["param"] = {}; };["isFrozen"] = { ["ret"] = "True if player is frozen";["class"] = "function";["realm"] = "sh";["summary"] = "\
Returns whether the player is frozen ";["fname"] = "isFrozen";["classlib"] = "Player";["name"] = "player_methods:isFrozen";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Returns whether the player is frozen";["param"] = {}; };["isPlayer"] = { ["ret"] = "True if player is player";["class"] = "function";["realm"] = "sh";["summary"] = "\
Returns whether the player is a player ";["fname"] = "isPlayer";["classlib"] = "Player";["name"] = "player_methods:isPlayer";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Returns whether the player is a player";["param"] = {}; };["getPing"] = { ["ret"] = "ping";["class"] = "function";["realm"] = "sh";["summary"] = "\
Returns the player's current ping ";["fname"] = "getPing";["classlib"] = "Player";["name"] = "player_methods:getPing";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Returns the player's current ping";["param"] = {}; };["getWeapon"] = { ["ret"] = "weapon";["class"] = "function";["realm"] = "sh";["summary"] = "\
Returns the specified weapon or nil if the player doesn't have it ";["fname"] = "getWeapon";["classlib"] = "Player";["name"] = "player_methods:getWeapon";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Returns the specified weapon or nil if the player doesn't have it";["param"] = { [1] = "wep";["wep"] = "String weapon class"; }; };["getWeapons"] = { ["ret"] = "Table of weapons";["class"] = "function";["realm"] = "sh";["summary"] = "\
Returns a table of weapons the player is carrying ";["fname"] = "getWeapons";["classlib"] = "Player";["name"] = "player_methods:getWeapons";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Returns a table of weapons the player is carrying";["param"] = {}; };["isAlive"] = { ["ret"] = "True if player alive";["class"] = "function";["realm"] = "sh";["summary"] = "\
Returns whether the player is alive ";["fname"] = "isAlive";["classlib"] = "Player";["name"] = "player_methods:isAlive";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Returns whether the player is alive";["param"] = {}; };["isFlashlightOn"] = { ["ret"] = "True if player has flashlight on";["class"] = "function";["realm"] = "sh";["summary"] = "\
Returns whether the player's flashlight is on ";["fname"] = "isFlashlightOn";["classlib"] = "Player";["name"] = "player_methods:isFlashlightOn";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Returns whether the player's flashlight is on";["param"] = {}; };["getName"] = { ["ret"] = "Name";["class"] = "function";["realm"] = "sh";["summary"] = "\
Returns the player's name ";["fname"] = "getName";["classlib"] = "Player";["name"] = "player_methods:getName";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Returns the player's name";["param"] = {}; };["isNPC"] = { ["ret"] = "True if player is an NPC";["class"] = "function";["realm"] = "sh";["summary"] = "\
Returns whether the player is an NPC ";["fname"] = "isNPC";["classlib"] = "Player";["name"] = "player_methods:isNPC";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Returns whether the player is an NPC";["param"] = {}; };["isAdmin"] = { ["ret"] = "True if player is admin";["class"] = "function";["realm"] = "sh";["summary"] = "\
Returns whether the player is an admin ";["fname"] = "isAdmin";["classlib"] = "Player";["name"] = "player_methods:isAdmin";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Returns whether the player is an admin";["param"] = {}; };["isSuperAdmin"] = { ["ret"] = "True if player is super admin";["class"] = "function";["realm"] = "sh";["summary"] = "\
Returns whether the player is a super admin ";["fname"] = "isSuperAdmin";["classlib"] = "Player";["name"] = "player_methods:isSuperAdmin";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Returns whether the player is a super admin";["param"] = {}; };["getTeamName"] = { ["ret"] = "team name";["class"] = "function";["realm"] = "sh";["summary"] = "\
Returns the name of the player's current team ";["fname"] = "getTeamName";["classlib"] = "Player";["name"] = "player_methods:getTeamName";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Returns the name of the player's current team";["param"] = {}; };["isCrouching"] = { ["ret"] = "True if player crouching";["class"] = "function";["realm"] = "sh";["summary"] = "\
Returns whether the player is crouching ";["fname"] = "isCrouching";["classlib"] = "Player";["name"] = "player_methods:isCrouching";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Returns whether the player is crouching";["param"] = {}; };["getEyeTrace"] = { ["ret"] = "table trace data https://wiki.garrysmod.com/page/Structures/TraceResult";["class"] = "function";["realm"] = "sh";["summary"] = "\
Returns a table with information of what the player is looking at ";["fname"] = "getEyeTrace";["classlib"] = "Player";["name"] = "player_methods:getEyeTrace";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Returns a table with information of what the player is looking at";["param"] = {}; };["getDeaths"] = { ["ret"] = "Amount of deaths";["class"] = "function";["realm"] = "sh";["summary"] = "\
Returns the amount of deaths of the player ";["fname"] = "getDeaths";["classlib"] = "Player";["name"] = "player_methods:getDeaths";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Returns the amount of deaths of the player";["param"] = {}; };["hasGodMode"] = { ["ret"] = "True if the player has godmode";["class"] = "function";["realm"] = "sh";["fname"] = "hasGodMode";["summary"] = "\
Returns whether or not the player has godmode ";["name"] = "player_methods:hasGodMode";["classlib"] = "Player";["private"] = false;["server"] = true;["description"] = "\
Returns whether or not the player has godmode";["param"] = {}; };["getActiveWeapon"] = { ["ret"] = "The weapon";["class"] = "function";["realm"] = "sh";["summary"] = "\
Returns the name of the player's active weapon ";["fname"] = "getActiveWeapon";["classlib"] = "Player";["name"] = "player_methods:getActiveWeapon";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Returns the name of the player's active weapon";["param"] = {}; }; }; };["VMatrix"] = { ["typtbl"] = "vmatrix_methods";["fields"] = {};["name"] = "VMatrix";["summary"] = "\
VMatrix type ";["description"] = "\
VMatrix type";["class"] = "class";["methods"] = { [1] = "getAngles";[2] = "getField";[3] = "getForward";[4] = "getInverse";[5] = "getInverseTR";[6] = "getRight";[7] = "getScale";[8] = "getTranslation";[9] = "getUp";[10] = "rotate";[11] = "scale";[12] = "scaleTranslation";[13] = "setAngles";[14] = "setField";[15] = "setScale";[16] = "setTranslation";[17] = "translate";["getRight"] = { ["ret"] = "Translation";["class"] = "function";["fname"] = "getRight";["realm"] = "sh";["name"] = "vmatrix_methods:getRight";["summary"] = "\
Returns right vector of matrix ";["private"] = false;["classlib"] = "VMatrix";["description"] = "\
Returns right vector of matrix";["param"] = {}; };["getUp"] = { ["ret"] = "Translation";["class"] = "function";["fname"] = "getUp";["realm"] = "sh";["name"] = "vmatrix_methods:getUp";["summary"] = "\
Returns up vector of matrix ";["private"] = false;["classlib"] = "VMatrix";["description"] = "\
Returns up vector of matrix";["param"] = {}; };["scale"] = { ["class"] = "function";["fname"] = "scale";["realm"] = "sh";["name"] = "vmatrix_methods:scale";["summary"] = "\
Scale the matrix ";["private"] = false;["classlib"] = "VMatrix";["description"] = "\
Scale the matrix";["param"] = { [1] = "vec";["vec"] = "Vector to scale by"; }; };["getScale"] = { ["ret"] = "Scale";["class"] = "function";["fname"] = "getScale";["realm"] = "sh";["name"] = "vmatrix_methods:getScale";["summary"] = "\
Returns scale ";["private"] = false;["classlib"] = "VMatrix";["description"] = "\
Returns scale";["param"] = {}; };["getAngles"] = { ["ret"] = "Angles";["class"] = "function";["fname"] = "getAngles";["realm"] = "sh";["name"] = "vmatrix_methods:getAngles";["summary"] = "\
Returns angles ";["private"] = false;["classlib"] = "VMatrix";["description"] = "\
Returns angles";["param"] = {}; };["getInverse"] = { ["ret"] = "inverted matrix";["class"] = "function";["fname"] = "getInverse";["realm"] = "sh";["name"] = "vmatrix_methods:getInverse";["summary"] = "\
Inverts the matrix ";["private"] = false;["classlib"] = "VMatrix";["description"] = "\
Inverts the matrix";["param"] = {}; };["setTranslation"] = { ["class"] = "function";["fname"] = "setTranslation";["realm"] = "sh";["name"] = "vmatrix_methods:setTranslation";["summary"] = "\
Sets the translation ";["private"] = false;["classlib"] = "VMatrix";["description"] = "\
Sets the translation";["param"] = { [1] = "vec";["vec"] = "New translation"; }; };["scaleTranslation"] = { ["class"] = "function";["fname"] = "scaleTranslation";["realm"] = "sh";["name"] = "vmatrix_methods:scaleTranslation";["summary"] = "\
Scales the absolute translation ";["private"] = false;["classlib"] = "VMatrix";["description"] = "\
Scales the absolute translation";["param"] = { [1] = "num";["num"] = "Amount to scale by"; }; };["setScale"] = { ["class"] = "function";["fname"] = "setScale";["realm"] = "sh";["name"] = "vmatrix_methods:setScale";["summary"] = "\
Sets the scale ";["private"] = false;["classlib"] = "VMatrix";["description"] = "\
Sets the scale";["param"] = { [1] = "vec";["vec"] = "New scale"; }; };["translate"] = { ["class"] = "function";["fname"] = "translate";["realm"] = "sh";["name"] = "vmatrix_methods:translate";["summary"] = "\
Translate the matrix ";["private"] = false;["classlib"] = "VMatrix";["description"] = "\
Translate the matrix";["param"] = { [1] = "vec";["vec"] = "Vector to translate by"; }; };["getTranslation"] = { ["ret"] = "Translation";["class"] = "function";["fname"] = "getTranslation";["realm"] = "sh";["name"] = "vmatrix_methods:getTranslation";["summary"] = "\
Returns translation ";["private"] = false;["classlib"] = "VMatrix";["description"] = "\
Returns translation";["param"] = {}; };["setField"] = { ["class"] = "function";["fname"] = "setField";["realm"] = "sh";["name"] = "vmatrix_methods:setField";["summary"] = "\
Sets a specific field in the matrix ";["private"] = false;["classlib"] = "VMatrix";["description"] = "\
Sets a specific field in the matrix";["param"] = { [1] = "row";[2] = "column";[3] = "value";["value"] = "Value to set";["row"] = "A number from 1 to 4";["column"] = "A number from 1 to 4"; }; };["getForward"] = { ["ret"] = "Translation";["class"] = "function";["fname"] = "getForward";["realm"] = "sh";["name"] = "vmatrix_methods:getForward";["summary"] = "\
Returns forward vector of matrix ";["private"] = false;["classlib"] = "VMatrix";["description"] = "\
Returns forward vector of matrix";["param"] = {}; };["getField"] = { ["ret"] = "Value of the specified field";["class"] = "function";["fname"] = "getField";["realm"] = "sh";["name"] = "vmatrix_methods:getField";["summary"] = "\
Returns a specific field in the matrix ";["private"] = false;["classlib"] = "VMatrix";["description"] = "\
Returns a specific field in the matrix";["param"] = { [1] = "row";[2] = "column";["column"] = "A number from 1 to 4";["row"] = "A number from 1 to 4"; }; };["rotate"] = { ["class"] = "function";["fname"] = "rotate";["realm"] = "sh";["name"] = "vmatrix_methods:rotate";["summary"] = "\
Rotate the matrix ";["private"] = false;["classlib"] = "VMatrix";["description"] = "\
Rotate the matrix";["param"] = { [1] = "ang";["ang"] = "Angle to rotate by"; }; };["getInverseTR"] = { ["ret"] = "inverted matrix";["class"] = "function";["fname"] = "getInverseTR";["realm"] = "sh";["name"] = "vmatrix_methods:getInverseTR";["summary"] = "\
Inverts the matrix efficiently for translations and rotations ";["private"] = false;["classlib"] = "VMatrix";["description"] = "\
Inverts the matrix efficiently for translations and rotations";["param"] = {}; };["setAngles"] = { ["class"] = "function";["fname"] = "setAngles";["realm"] = "sh";["name"] = "vmatrix_methods:setAngles";["summary"] = "\
Sets the angles ";["private"] = false;["classlib"] = "VMatrix";["description"] = "\
Sets the angles";["param"] = { [1] = "ang";["ang"] = "New angles"; }; }; }; };["Color"] = { ["typtbl"] = "color_methods";["summary"] = "\
Color type ";["fields"] = {};["name"] = "Color";["server"] = true;["description"] = "\
Color type";["client"] = true;["class"] = "class";["methods"] = { [1] = "hsvToRGB";[2] = "rgbToHSV";[3] = "setA";[4] = "setB";[5] = "setG";[6] = "setR";["setA"] = { ["ret"] = "The modified color";["class"] = "function";["fname"] = "setA";["realm"] = "sh";["name"] = "color_methods:setA";["summary"] = "\
Set's the color's alpha and returns it.";["private"] = false;["classlib"] = "Color";["description"] = "\
Set's the color's alpha and returns it.";["param"] = { [1] = "a";["a"] = "The alpha"; }; };["setR"] = { ["ret"] = "The modified color";["class"] = "function";["fname"] = "setR";["realm"] = "sh";["name"] = "color_methods:setR";["summary"] = "\
Set's the color's red channel and returns it.";["private"] = false;["classlib"] = "Color";["description"] = "\
Set's the color's red channel and returns it.";["param"] = { [1] = "r";["r"] = "The red"; }; };["rgbToHSV"] = { ["ret"] = "A triplet of numbers representing HSV.";["class"] = "function";["realm"] = "sh";["summary"] = "\
Converts the color from RGB to HSV.";["fname"] = "rgbToHSV";["classlib"] = "Color";["name"] = "color_methods:rgbToHSV";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Converts the color from RGB to HSV.";["param"] = {}; };["setG"] = { ["ret"] = "The modified color";["class"] = "function";["fname"] = "setG";["realm"] = "sh";["name"] = "color_methods:setG";["summary"] = "\
Set's the color's green and returns it.";["private"] = false;["classlib"] = "Color";["description"] = "\
Set's the color's green and returns it.";["param"] = { [1] = "g";["g"] = "The green"; }; };["hsvToRGB"] = { ["ret"] = "A triplet of numbers representing HSV.";["class"] = "function";["realm"] = "sh";["summary"] = "\
Converts the color from HSV to RGB.";["fname"] = "hsvToRGB";["classlib"] = "Color";["name"] = "color_methods:hsvToRGB";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Converts the color from HSV to RGB.";["param"] = {}; };["setB"] = { ["ret"] = "The modified color";["class"] = "function";["fname"] = "setB";["realm"] = "sh";["name"] = "color_methods:setB";["summary"] = "\
Set's the color's blue and returns it.";["private"] = false;["classlib"] = "Color";["description"] = "\
Set's the color's blue and returns it.";["param"] = { [1] = "b";["b"] = "The blue"; }; }; }; };["Angle"] = { ["typtbl"] = "ang_methods";["summary"] = "\
Angle Type ";["fields"] = {};["name"] = "Angle";["server"] = true;["description"] = "\
Angle Type";["client"] = true;["class"] = "class";["methods"] = { [1] = "getForward";[2] = "getNormalized";[3] = "getRight";[4] = "getUp";[5] = "isZero";[6] = "normalize";[7] = "rotateAroundAxis";[8] = "set";[9] = "setP";[10] = "setR";[11] = "setY";[12] = "setZero";["getRight"] = { ["ret"] = "vector normalised.";["class"] = "function";["fname"] = "getRight";["realm"] = "sh";["name"] = "ang_methods:getRight";["summary"] = "\
Return the Right Vector relative to the angle dir.";["private"] = false;["classlib"] = "Angle";["description"] = "\
Return the Right Vector relative to the angle dir.";["param"] = {}; };["getUp"] = { ["ret"] = "vector normalised.";["class"] = "function";["fname"] = "getUp";["realm"] = "sh";["name"] = "ang_methods:getUp";["summary"] = "\
Return the Up Vector relative to the angle dir.";["private"] = false;["classlib"] = "Angle";["description"] = "\
Return the Up Vector relative to the angle dir.";["param"] = {}; };["isZero"] = { ["ret"] = "boolean";["class"] = "function";["fname"] = "isZero";["realm"] = "sh";["name"] = "ang_methods:isZero";["summary"] = "\
Returns if p,y,r are all 0.";["private"] = false;["classlib"] = "Angle";["description"] = "\
Returns if p,y,r are all 0.";["param"] = {}; };["getNormalized"] = { ["ret"] = "Normalized angle table";["class"] = "function";["fname"] = "getNormalized";["realm"] = "sh";["name"] = "ang_methods:getNormalized";["summary"] = "\
Returnes a normalized angle ";["private"] = false;["classlib"] = "Angle";["description"] = "\
Returnes a normalized angle";["param"] = {}; };["setP"] = { ["ret"] = "The modified angle";["class"] = "function";["fname"] = "setP";["realm"] = "sh";["name"] = "ang_methods:setP";["summary"] = "\
Set's the angle's pitch and returns it.";["private"] = false;["classlib"] = "Angle";["description"] = "\
Set's the angle's pitch and returns it.";["param"] = { [1] = "p";["p"] = "The pitch"; }; };["setR"] = { ["ret"] = "The modified angle";["class"] = "function";["fname"] = "setR";["realm"] = "sh";["name"] = "ang_methods:setR";["summary"] = "\
Set's the angle's roll and returns it.";["private"] = false;["classlib"] = "Angle";["description"] = "\
Set's the angle's roll and returns it.";["param"] = { [1] = "r";["r"] = "The roll"; }; };["normalize"] = { ["ret"] = "nil";["class"] = "function";["fname"] = "normalize";["realm"] = "sh";["name"] = "ang_methods:normalize";["summary"] = "\
Normalise angles eg (0,181,1) -> (0,-179,1).";["private"] = false;["classlib"] = "Angle";["description"] = "\
Normalise angles eg (0,181,1) -> (0,-179,1).";["param"] = {}; };["getForward"] = { ["ret"] = "vector normalised.";["class"] = "function";["fname"] = "getForward";["realm"] = "sh";["name"] = "ang_methods:getForward";["summary"] = "\
Return the Forward Vector ( direction the angle points ).";["private"] = false;["classlib"] = "Angle";["description"] = "\
Return the Forward Vector ( direction the angle points ).";["param"] = {}; };["setY"] = { ["ret"] = "The modified angle";["class"] = "function";["fname"] = "setY";["realm"] = "sh";["name"] = "ang_methods:setY";["summary"] = "\
Set's the angle's yaw and returns it.";["private"] = false;["classlib"] = "Angle";["description"] = "\
Set's the angle's yaw and returns it.";["param"] = { [1] = "y";["y"] = "The yaw"; }; };["setZero"] = { ["ret"] = "nil";["class"] = "function";["fname"] = "setZero";["realm"] = "sh";["name"] = "ang_methods:setZero";["summary"] = "\
Sets p,y,r to 0.";["private"] = false;["classlib"] = "Angle";["description"] = "\
Sets p,y,r to 0. This is faster than doing it manually.";["param"] = {}; };["set"] = { ["ret"] = "nil";["class"] = "function";["fname"] = "set";["realm"] = "sh";["name"] = "ang_methods:set";["summary"] = "\
Copies p,y,r from angle to another.";["private"] = false;["classlib"] = "Angle";["description"] = "\
Copies p,y,r from angle to another.";["param"] = { [1] = "b";["b"] = "Angle to copy from."; }; };["rotateAroundAxis"] = { ["ret"] = "The modified angle";["class"] = "function";["fname"] = "rotateAroundAxis";["realm"] = "sh";["name"] = "ang_methods:rotateAroundAxis";["summary"] = "\
Return Rotated angle around the specified axis.";["private"] = false;["classlib"] = "Angle";["description"] = "\
Return Rotated angle around the specified axis.";["param"] = { [1] = "v";[2] = "deg";[3] = "rad";["rad"] = "Number of radians or nil if degrees.";["deg"] = "Number of degrees or nil if radians.";["v"] = "Vector axis"; }; }; }; };["File"] = { ["typtbl"] = "file_methods";["fields"] = {};["name"] = "File";["summary"] = "\
File type ";["description"] = "\
File type";["client"] = true;["class"] = "class";["methods"] = { [1] = "close";[2] = "flush";[3] = "read";[4] = "readBool";[5] = "readByte";[6] = "readDouble";[7] = "readFloat";[8] = "readLine";[9] = "readLong";[10] = "readShort";[11] = "seek";[12] = "size";[13] = "skip";[14] = "tell";[15] = "write";[16] = "writeBool";[17] = "writeByte";[18] = "writeDouble";[19] = "writeFloat";[20] = "writeLong";[21] = "writeShort";["readDouble"] = { ["ret"] = "The data";["class"] = "function";["fname"] = "readDouble";["realm"] = "cl";["name"] = "file_methods:readDouble";["summary"] = "\
Reads a double and advances the file position ";["private"] = false;["classlib"] = "File";["description"] = "\
Reads a double and advances the file position";["param"] = {}; };["readLine"] = { ["ret"] = "The data";["class"] = "function";["fname"] = "readLine";["realm"] = "cl";["name"] = "file_methods:readLine";["summary"] = "\
Reads a line and advances the file position ";["private"] = false;["classlib"] = "File";["description"] = "\
Reads a line and advances the file position";["param"] = {}; };["readLong"] = { ["ret"] = "The data";["class"] = "function";["fname"] = "readLong";["realm"] = "cl";["name"] = "file_methods:readLong";["summary"] = "\
Reads a long and advances the file position ";["private"] = false;["classlib"] = "File";["description"] = "\
Reads a long and advances the file position";["param"] = {}; };["readFloat"] = { ["ret"] = "The data";["class"] = "function";["fname"] = "readFloat";["realm"] = "cl";["name"] = "file_methods:readFloat";["summary"] = "\
Reads a float and advances the file position ";["private"] = false;["classlib"] = "File";["description"] = "\
Reads a float and advances the file position";["param"] = {}; };["readShort"] = { ["ret"] = "The data";["class"] = "function";["fname"] = "readShort";["realm"] = "cl";["name"] = "file_methods:readShort";["summary"] = "\
Reads a short and advances the file position ";["private"] = false;["classlib"] = "File";["description"] = "\
Reads a short and advances the file position";["param"] = {}; };["writeShort"] = { ["class"] = "function";["fname"] = "writeShort";["realm"] = "cl";["name"] = "file_methods:writeShort";["summary"] = "\
Writes a short and advances the file position ";["private"] = false;["classlib"] = "File";["description"] = "\
Writes a short and advances the file position";["param"] = { [1] = "x";["x"] = "The short to write"; }; };["size"] = { ["ret"] = "The file's size";["class"] = "function";["fname"] = "size";["realm"] = "cl";["name"] = "file_methods:size";["summary"] = "\
Returns the file's size in bytes ";["private"] = false;["classlib"] = "File";["description"] = "\
Returns the file's size in bytes";["param"] = {}; };["skip"] = { ["ret"] = "The resulting position";["class"] = "function";["fname"] = "skip";["realm"] = "cl";["name"] = "file_methods:skip";["summary"] = "\
Moves the file position relative to its current position ";["private"] = false;["classlib"] = "File";["description"] = "\
Moves the file position relative to its current position";["param"] = { [1] = "n";["n"] = "How much to move the position"; }; };["write"] = { ["class"] = "function";["fname"] = "write";["realm"] = "cl";["name"] = "file_methods:write";["summary"] = "\
Writes a string to the file and advances the file position ";["private"] = false;["classlib"] = "File";["description"] = "\
Writes a string to the file and advances the file position";["param"] = { [1] = "str";["str"] = "The data to write"; }; };["writeBool"] = { ["class"] = "function";["fname"] = "writeBool";["realm"] = "cl";["name"] = "file_methods:writeBool";["summary"] = "\
Writes a boolean and advances the file position ";["private"] = false;["classlib"] = "File";["description"] = "\
Writes a boolean and advances the file position";["param"] = { [1] = "x";["x"] = "The boolean to write"; }; };["flush"] = { ["class"] = "function";["fname"] = "flush";["realm"] = "cl";["name"] = "file_methods:flush";["summary"] = "\
Wait until all changes to the file are complete ";["private"] = false;["classlib"] = "File";["description"] = "\
Wait until all changes to the file are complete";["param"] = {}; };["writeLong"] = { ["class"] = "function";["fname"] = "writeLong";["realm"] = "cl";["name"] = "file_methods:writeLong";["summary"] = "\
Writes a long and advances the file position ";["private"] = false;["classlib"] = "File";["description"] = "\
Writes a long and advances the file position";["param"] = { [1] = "x";["x"] = "The long to write"; }; };["readBool"] = { ["ret"] = "The data";["class"] = "function";["fname"] = "readBool";["realm"] = "cl";["name"] = "file_methods:readBool";["summary"] = "\
Reads a boolean and advances the file position ";["private"] = false;["classlib"] = "File";["description"] = "\
Reads a boolean and advances the file position";["param"] = {}; };["writeFloat"] = { ["class"] = "function";["fname"] = "writeFloat";["realm"] = "cl";["name"] = "file_methods:writeFloat";["summary"] = "\
Writes a float and advances the file position ";["private"] = false;["classlib"] = "File";["description"] = "\
Writes a float and advances the file position";["param"] = { [1] = "x";["x"] = "The float to write"; }; };["read"] = { ["ret"] = "The data";["class"] = "function";["fname"] = "read";["realm"] = "cl";["name"] = "file_methods:read";["summary"] = "\
Reads a certain length of the file's bytes ";["private"] = false;["classlib"] = "File";["description"] = "\
Reads a certain length of the file's bytes";["param"] = { [1] = "n";["n"] = "The length to read"; }; };["readByte"] = { ["ret"] = "The data";["class"] = "function";["fname"] = "readByte";["realm"] = "cl";["name"] = "file_methods:readByte";["summary"] = "\
Reads a byte and advances the file position ";["private"] = false;["classlib"] = "File";["description"] = "\
Reads a byte and advances the file position";["param"] = {}; };["writeByte"] = { ["class"] = "function";["fname"] = "writeByte";["realm"] = "cl";["name"] = "file_methods:writeByte";["summary"] = "\
Writes a byte and advances the file position ";["private"] = false;["classlib"] = "File";["description"] = "\
Writes a byte and advances the file position";["param"] = { [1] = "x";["x"] = "The byte to write"; }; };["tell"] = { ["ret"] = "The current file position";["class"] = "function";["fname"] = "tell";["realm"] = "cl";["name"] = "file_methods:tell";["summary"] = "\
Returns the current file position ";["private"] = false;["classlib"] = "File";["description"] = "\
Returns the current file position";["param"] = {}; };["seek"] = { ["class"] = "function";["fname"] = "seek";["realm"] = "cl";["name"] = "file_methods:seek";["summary"] = "\
Sets the file position ";["private"] = false;["classlib"] = "File";["description"] = "\
Sets the file position";["param"] = { [1] = "n";["n"] = "The position to set it to"; }; };["writeDouble"] = { ["class"] = "function";["fname"] = "writeDouble";["realm"] = "cl";["name"] = "file_methods:writeDouble";["summary"] = "\
Writes a double and advances the file position ";["private"] = false;["classlib"] = "File";["description"] = "\
Writes a double and advances the file position";["param"] = { [1] = "x";["x"] = "The double to write"; }; };["close"] = { ["class"] = "function";["fname"] = "close";["realm"] = "cl";["name"] = "file_methods:close";["summary"] = "\
Flushes and closes the file.";["private"] = false;["classlib"] = "File";["description"] = "\
Flushes and closes the file. The file must be opened again to use a new file object.";["param"] = {}; }; }; };["Sound"] = { ["typtbl"] = "sound_methods";["summary"] = "\
Sound type ";["fields"] = {};["name"] = "Sound";["server"] = true;["description"] = "\
Sound type";["client"] = true;["class"] = "class";["methods"] = { [1] = "isPlaying";[2] = "play";[3] = "setPitch";[4] = "setSoundLevel";[5] = "setVolume";[6] = "stop";["setSoundLevel"] = { ["class"] = "function";["fname"] = "setSoundLevel";["realm"] = "sh";["name"] = "sound_methods:setSoundLevel";["summary"] = "\
Sets the sound level in dB.";["private"] = false;["classlib"] = "Sound";["description"] = "\
Sets the sound level in dB.";["param"] = { [1] = "level";["level"] = "dB level, see <a href='https://developer.valvesoftware.com/wiki/Soundscripts#SoundLevel'> Vale Dev Wiki</a>, for information on the value to use."; }; };["stop"] = { ["class"] = "function";["fname"] = "stop";["realm"] = "sh";["name"] = "sound_methods:stop";["summary"] = "\
Stops the sound from being played.";["private"] = false;["classlib"] = "Sound";["description"] = "\
Stops the sound from being played.";["param"] = { [1] = "fade";["fade"] = "Time in seconds to fade out, if nil or 0 the sound stops instantly."; }; };["isPlaying"] = { ["class"] = "function";["fname"] = "isPlaying";["realm"] = "sh";["name"] = "sound_methods:isPlaying";["summary"] = "\
Returns whether the sound is being played.";["private"] = false;["classlib"] = "Sound";["description"] = "\
Returns whether the sound is being played.";["param"] = {}; };["setVolume"] = { ["class"] = "function";["fname"] = "setVolume";["realm"] = "sh";["name"] = "sound_methods:setVolume";["summary"] = "\
Sets the volume of the sound.";["private"] = false;["classlib"] = "Sound";["description"] = "\
Sets the volume of the sound.";["param"] = { [1] = "vol";[2] = "fade";["vol"] = "Volume to set to, between 0 and 1.";["fade"] = "Time in seconds to transition to this new volume."; }; };["play"] = { ["class"] = "function";["fname"] = "play";["realm"] = "sh";["name"] = "sound_methods:play";["summary"] = "\
Starts to play the sound.";["private"] = false;["classlib"] = "Sound";["description"] = "\
Starts to play the sound.";["param"] = {}; };["setPitch"] = { ["class"] = "function";["fname"] = "setPitch";["realm"] = "sh";["name"] = "sound_methods:setPitch";["summary"] = "\
Sets the pitch of the sound.";["private"] = false;["classlib"] = "Sound";["description"] = "\
Sets the pitch of the sound.";["param"] = { [1] = "pitch";[2] = "fade";["pitch"] = "Pitch to set to, between 0 and 255.";["fade"] = "Time in seconds to transition to this new pitch."; }; }; }; };["Weapon"] = { ["typtbl"] = "weapon_methods";["fields"] = {};["name"] = "Weapon";["summary"] = "\
Weapon type ";["description"] = "\
Weapon type";["class"] = "class";["methods"] = { [1] = "clip1";[2] = "clip2";[3] = "getActivity";[4] = "getHoldType";[5] = "getNextPrimaryFire";[6] = "getNextSecondaryFire";[7] = "getPrimaryAmmoType";[8] = "getPrintName";[9] = "getSecondaryAmmoType";[10] = "isCarriedByLocalPlayer";[11] = "isWeaponVisible";[12] = "lastShootTime";["lastShootTime"] = { ["ret"] = "Time the weapon was last shot";["class"] = "function";["realm"] = "sh";["summary"] = "\
Returns the time since a weapon was last fired at a float variable ";["fname"] = "lastShootTime";["classlib"] = "Weapon";["name"] = "weapon_methods:lastShootTime";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Returns the time since a weapon was last fired at a float variable";["param"] = {}; };["getNextPrimaryFire"] = { ["ret"] = "The time, relative to CurTime";["class"] = "function";["realm"] = "sh";["summary"] = "\
Gets the next time the weapon can primary fire.";["fname"] = "getNextPrimaryFire";["classlib"] = "Weapon";["name"] = "weapon_methods:getNextPrimaryFire";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Gets the next time the weapon can primary fire.";["param"] = {}; };["clip2"] = { ["ret"] = "amount of ammo";["class"] = "function";["realm"] = "sh";["summary"] = "\
Returns Ammo in secondary clip ";["fname"] = "clip2";["classlib"] = "Weapon";["name"] = "weapon_methods:clip2";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Returns Ammo in secondary clip";["param"] = {}; };["isCarriedByLocalPlayer"] = { ["ret"] = "whether or not the weapon is carried by the local player";["class"] = "function";["realm"] = "sh";["fname"] = "isCarriedByLocalPlayer";["summary"] = "\
Returns if the weapon is carried by the local player.";["name"] = "weapon_methods:isCarriedByLocalPlayer";["classlib"] = "Weapon";["private"] = false;["client"] = true;["description"] = "\
Returns if the weapon is carried by the local player.";["param"] = {}; };["getSecondaryAmmoType"] = { ["ret"] = "Ammo number type";["class"] = "function";["realm"] = "sh";["summary"] = "\
Gets the secondary ammo type of the given weapon.";["fname"] = "getSecondaryAmmoType";["classlib"] = "Weapon";["name"] = "weapon_methods:getSecondaryAmmoType";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Gets the secondary ammo type of the given weapon.";["param"] = {}; };["clip1"] = { ["ret"] = "amount of ammo";["class"] = "function";["realm"] = "sh";["summary"] = "\
Returns Ammo in primary clip ";["fname"] = "clip1";["classlib"] = "Weapon";["name"] = "weapon_methods:clip1";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Returns Ammo in primary clip";["param"] = {}; };["getActivity"] = { ["ret"] = "number Current activity";["class"] = "function";["realm"] = "sh";["summary"] = "\
Returns the sequence enumeration number that the weapon is playing.";["fname"] = "getActivity";["classlib"] = "Weapon";["name"] = "weapon_methods:getActivity";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Returns the sequence enumeration number that the weapon is playing. Must be used on a view model.";["param"] = {}; };["getPrintName"] = { ["ret"] = "string Display name of weapon";["class"] = "function";["realm"] = "sh";["fname"] = "getPrintName";["summary"] = "\
Gets Display name of weapon ";["name"] = "weapon_methods:getPrintName";["classlib"] = "Weapon";["private"] = false;["client"] = true;["description"] = "\
Gets Display name of weapon";["param"] = {}; };["getPrimaryAmmoType"] = { ["ret"] = "Ammo number type";["class"] = "function";["realm"] = "sh";["summary"] = "\
Gets the primary ammo type of the given weapon.";["fname"] = "getPrimaryAmmoType";["classlib"] = "Weapon";["name"] = "weapon_methods:getPrimaryAmmoType";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Gets the primary ammo type of the given weapon.";["param"] = {}; };["getNextSecondaryFire"] = { ["ret"] = "The time, relative to CurTime";["class"] = "function";["realm"] = "sh";["summary"] = "\
Gets the next time the weapon can secondary fire.";["fname"] = "getNextSecondaryFire";["classlib"] = "Weapon";["name"] = "weapon_methods:getNextSecondaryFire";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Gets the next time the weapon can secondary fire.";["param"] = {}; };["getHoldType"] = { ["ret"] = "string Holdtype";["class"] = "function";["realm"] = "sh";["summary"] = "\
Returns the hold type of the weapon.";["fname"] = "getHoldType";["classlib"] = "Weapon";["name"] = "weapon_methods:getHoldType";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Returns the hold type of the weapon.";["param"] = {}; };["isWeaponVisible"] = { ["ret"] = "Whether the weapon is visble or not";["class"] = "function";["realm"] = "sh";["summary"] = "\
Returns whether the weapon is visible ";["fname"] = "isWeaponVisible";["classlib"] = "Weapon";["name"] = "weapon_methods:isWeaponVisible";["server"] = true;["private"] = false;["client"] = true;["description"] = "\
Returns whether the weapon is visible";["param"] = {}; }; }; }; };["directives"] = { [1] = "client";[2] = "include";[3] = "includedir";[4] = "model";[5] = "name";[6] = "server";["include"] = { ["description"] = "\
Mark a file to be included in the upload. \
This is required to use the file in require() and dofile()";["class"] = "directive";["classForced"] = true;["name"] = "include";["summary"] = "\
Mark a file to be included in the upload.";["usage"] = "\
--@include lib/someLibrary.txt \
 \
require( \"lib/someLibrary.txt\" ) \
-- CODE";["param"] = { [1] = "path";["path"] = "Path to the file"; }; };["includedir"] = { ["description"] = "\
Mark a directory to be included in the upload. \
This is optional to include all files in the directory in require() and dofile()";["class"] = "directive";["classForced"] = true;["name"] = "includedir";["summary"] = "\
Mark a directory to be included in the upload.";["usage"] = "\
--@includedir lib \
 \
require( \"lib/someLibraryInLib.txt\" ) \
require( \"lib/someOtherLibraryInLib.txt\" ) \
-- CODE";["param"] = { [1] = "path";["path"] = "Path to the directory"; }; };["model"] = { ["description"] = "\
Set the model of the processor entity. \
This does not set the model of the screen entity";["class"] = "directive";["classForced"] = true;["name"] = "model";["summary"] = "\
Set the model of the processor entity.";["usage"] = "\
--@model models/props_junk/watermelon01.mdl \
-- CODE";["param"] = { [1] = "model";["model"] = "String of the model"; }; };["client"] = { ["description"] = "\
Set the processor to only run on the client. Shared is default";["class"] = "directive";["classForced"] = true;["name"] = "client";["summary"] = "\
Set the processor to only run on the client.";["usage"] = "\
--@client \
-- CODE";["param"] = {}; };["name"] = { ["description"] = "\
Set the name of the script. \
This will become the name of the tab and will show on the overlay of the processor";["class"] = "directive";["classForced"] = true;["name"] = "name";["summary"] = "\
Set the name of the script.";["usage"] = "\
--@name Awesome script \
-- CODE";["param"] = { [1] = "name";["name"] = "Name of the script"; }; };["server"] = { ["description"] = "\
Set the processor to only run on the server. Shared is default";["class"] = "directive";["classForced"] = true;["name"] = "server";["summary"] = "\
Set the processor to only run on the server.";["usage"] = "\
--@server \
-- CODE";["param"] = {}; }; }; };
