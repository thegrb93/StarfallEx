SF.Docs={["hooks"]={[1]="EndEntityDriving";[2]="EntityRemoved";[3]="EntityTakeDamage";[4]="FinishChat";[5]="GravGunOnDropped";[6]="GravGunOnPickedUp";[7]="GravGunPunt";[8]="Initialize";[9]="KeyPress";[10]="KeyRelease";[11]="OnEntityCreated";[12]="OnPhysgunFreeze";[13]="OnPhysgunReload";[14]="PhysgunDrop";[15]="PhysgunPickup";[16]="PlayerCanPickupWeapon";[17]="PlayerChat";[18]="PlayerDeath";[19]="PlayerDisconnected";[20]="PlayerEnteredVehicle";[21]="PlayerHurt";[22]="PlayerInitialSpawn";[23]="PlayerLeaveVehicle";[24]="PlayerNoClip";[25]="PlayerSay";[26]="PlayerSpawn";[27]="PlayerSpray";[28]="PlayerSwitchFlashlight";[29]="PlayerSwitchWeapon";[30]="PlayerUse";[31]="PropBreak";[32]="Removed";[33]="StartChat";[34]="StartEntityDriving";[35]="calcview";[36]="drawhud";[37]="hudconnected";[38]="huddisconnected";[39]="input";[40]="inputPressed";[41]="inputReleased";[42]="mousemoved";[43]="net";[44]="permissionrequest";[45]="postdrawhud";[46]="postdrawopaquerenderables";[47]="predrawhud";[48]="predrawopaquerenderables";[49]="readcell";[50]="remote";[51]="render";[52]="renderoffscreen";[53]="starfallUsed";[54]="think";[55]="tick";[56]="writecell";["render"]={["description"]="\
Called when a frame is requested to be drawn on screen. (2D/3D Context)";["class"]="hook";["summary"]="\
Called when a frame is requested to be drawn on screen.";["classForced"]=true;["name"]="render";["realm"]="cl";["client"]=true;["param"]={};};["PhysgunPickup"]={["description"]="\
Called when an entity gets picked up by a physgun";["class"]="hook";["server"]=true;["classForced"]=true;["realm"]="sh";["name"]="PhysgunPickup";["summary"]="\
Called when an entity gets picked up by a physgun ";["client"]=true;["param"]={[1]="ply";[2]="ent";["ent"]="Entity being picked up";["ply"]="Player picking up the entity";};};["hudconnected"]={["description"]="\
Called when the player connects to a HUD component linked to the Starfall Chip";["class"]="hook";["summary"]="\
Called when the player connects to a HUD component linked to the Starfall Chip ";["classForced"]=true;["name"]="hudconnected";["realm"]="cl";["client"]=true;["param"]={};};["GravGunOnPickedUp"]={["description"]="\
Called when an entity is being picked up by a gravity gun";["class"]="hook";["summary"]="\
Called when an entity is being picked up by a gravity gun ";["classForced"]=true;["name"]="GravGunOnPickedUp";["realm"]="sh";["server"]=true;["param"]={[1]="ply";[2]="ent";["ent"]="Entity being picked up";["ply"]="Player picking up an object";};};["PlayerCanPickupWeapon"]={["description"]="\
Called when a wants to pick up a weapon";["class"]="hook";["summary"]="\
Called when a wants to pick up a weapon ";["classForced"]=true;["name"]="PlayerCanPickupWeapon";["realm"]="sh";["server"]=true;["param"]={[1]="ply";[2]="wep";["ply"]="Player";["wep"]="Weapon";};};["calcview"]={["ret"]="table Table containing information for the camera. {origin=camera origin, angles=camera angles, fov=camera fov, znear=znear, zfar=zfar, drawviewer=drawviewer}";["description"]="\
Called when the engine wants to calculate the player's view";["class"]="hook";["summary"]="\
Called when the engine wants to calculate the player's view ";["classForced"]=true;["name"]="calcview";["realm"]="cl";["client"]=true;["param"]={[1]="pos";[2]="ang";[3]="fov";[4]="znear";[5]="zfar";["znear"]="Current near plane of the camera";["fov"]="Current fov of the camera";["ang"]="Current angles of the camera";["zfar"]="Current far plane of the camera";["pos"]="Current position of the camera";};};["PlayerSpray"]={["description"]="\
Called when a players sprays his logo";["class"]="hook";["summary"]="\
Called when a players sprays his logo ";["classForced"]=true;["name"]="PlayerSpray";["realm"]="sh";["server"]=true;["param"]={[1]="ply";["ply"]="Player that sprayed";};};["KeyRelease"]={["description"]="\
Called when a player releases a key";["class"]="hook";["server"]=true;["classForced"]=true;["realm"]="sh";["name"]="KeyRelease";["summary"]="\
Called when a player releases a key ";["client"]=true;["param"]={[1]="ply";[2]="key";["key"]="The key being released";["ply"]="Player releasing the key";};};["KeyPress"]={["description"]="\
Called when a player presses a key";["class"]="hook";["server"]=true;["classForced"]=true;["realm"]="sh";["name"]="KeyPress";["summary"]="\
Called when a player presses a key ";["client"]=true;["param"]={[1]="ply";[2]="key";["key"]="The key being pressed";["ply"]="Player pressing the key";};};["FinishChat"]={["description"]="\
Called when the local player closes their chat window.";["class"]="hook";["summary"]="\
Called when the local player closes their chat window.";["classForced"]=true;["name"]="FinishChat";["realm"]="sh";["client"]=true;["param"]={};};["mousemoved"]={["classForced"]=true;["name"]="mousemoved";["description"]="\
Called when the mouse is moved";["realm"]="sh";["summary"]="\
Called when the mouse is moved ";["class"]="hook";["param"]={[1]="x";[2]="y";["y"]="Y coordinate moved";["x"]="X coordinate moved";};};["writecell"]={["classForced"]=true;["description"]="\
Called when a high speed device writes to a wired SF chip";["name"]="writecell";["realm"]="sv";["summary"]="\
Called when a high speed device writes to a wired SF chip ";["class"]="hook";["param"]={[1]="address";[2]="data";["data"]="The data being written";["address"]="The address written to";};};["EntityTakeDamage"]={["description"]="\
Called when an entity is damaged";["class"]="hook";["summary"]="\
Called when an entity is damaged ";["classForced"]=true;["name"]="EntityTakeDamage";["realm"]="sh";["server"]=true;["param"]={[1]="target";[2]="attacker";[3]="inflictor";[4]="amount";[5]="type";[6]="position";[7]="force";["inflictor"]="Entity that inflicted the damage";["type"]="Type of the damage";["amount"]="How much damage";["target"]="Entity that is hurt";["force"]="Force of the damage";["attacker"]="Entity that attacked";["position"]="Position of the damage";};};["PlayerInitialSpawn"]={["description"]="\
Called when a player spawns for the first time";["class"]="hook";["summary"]="\
Called when a player spawns for the first time ";["classForced"]=true;["name"]="PlayerInitialSpawn";["realm"]="sh";["server"]=true;["param"]={[1]="ply";["ply"]="Player who spawned";};};["PlayerSpawn"]={["description"]="\
Called when a player spawns";["class"]="hook";["summary"]="\
Called when a player spawns ";["classForced"]=true;["name"]="PlayerSpawn";["realm"]="sh";["server"]=true;["param"]={[1]="ply";["ply"]="Player who spawned";};};["OnPhysgunFreeze"]={["description"]="\
Called when an entity is being frozen";["class"]="hook";["summary"]="\
Called when an entity is being frozen ";["classForced"]=true;["name"]="OnPhysgunFreeze";["realm"]="sh";["server"]=true;["param"]={[1]="physgun";[2]="physobj";[3]="ent";[4]="ply";["physgun"]="Entity of the physgun";["physobj"]="PhysObj of the entity";["ent"]="Entity being frozen";["ply"]="Player freezing the entity";};};["remote"]={["description"]="\
Remote hook. \
This hook can be called from other instances";["class"]="hook";["server"]=true;["classForced"]=true;["realm"]="sh";["name"]="remote";["summary"]="\
Remote hook.";["client"]=true;["param"]={[1]="sender";[2]="owner";[3]="...";["sender"]="The entity that caused the hook to run";["..."]="The payload that was supplied when calling the hook";["owner"]="The owner of the sender";};};["huddisconnected"]={["description"]="\
Called when the player disconnects from a HUD component linked to the Starfall Chip";["class"]="hook";["summary"]="\
Called when the player disconnects from a HUD component linked to the Starfall Chip ";["classForced"]=true;["name"]="huddisconnected";["realm"]="cl";["client"]=true;["param"]={};};["PlayerSwitchWeapon"]={["description"]="\
Called when a player switches their weapon";["class"]="hook";["server"]=true;["classForced"]=true;["realm"]="sh";["name"]="PlayerSwitchWeapon";["summary"]="\
Called when a player switches their weapon ";["client"]=true;["param"]={[1]="ply";[2]="oldwep";[3]="newweapon";["oldwep"]="Old weapon";["ply"]="Player droppig the entity";["newweapon"]="New weapon";};};["OnPhysgunReload"]={["description"]="\
Called when a player reloads his physgun";["class"]="hook";["summary"]="\
Called when a player reloads his physgun ";["classForced"]=true;["name"]="OnPhysgunReload";["realm"]="sh";["server"]=true;["param"]={[1]="physgun";[2]="ply";["ply"]="Player reloading the physgun";["physgun"]="Entity of the physgun";};};["net"]={["classForced"]=true;["description"]="\
Called when a net message arrives";["name"]="net";["realm"]="sh";["summary"]="\
Called when a net message arrives ";["class"]="hook";["param"]={[1]="name";[2]="len";[3]="ply";["len"]="Length of the arriving net message in bytes";["name"]="Name of the arriving net message";["ply"]="On server, the player that sent the message. Nil on client.";};};["PlayerSwitchFlashlight"]={["description"]="\
Called when a players turns their flashlight on or off";["class"]="hook";["summary"]="\
Called when a players turns their flashlight on or off ";["classForced"]=true;["name"]="PlayerSwitchFlashlight";["realm"]="sh";["server"]=true;["param"]={[1]="ply";[2]="state";["state"]="New flashlight state. True if on.";["ply"]="Player switching flashlight";};};["PlayerUse"]={["description"]="\
Called when a player holds their use key and looks at an entity. \
Will continuously run.";["class"]="hook";["summary"]="\
Called when a player holds their use key and looks at an entity.";["classForced"]=true;["name"]="PlayerUse";["realm"]="sh";["param"]={[1]="ply";[2]="ent";["ent"]="Entity being used";["ply"]="Player using the entity";};["server"]=true;};["GravGunPunt"]={["description"]="\
Called when a player punts with the gravity gun";["class"]="hook";["server"]=true;["classForced"]=true;["realm"]="sh";["name"]="GravGunPunt";["summary"]="\
Called when a player punts with the gravity gun ";["client"]=true;["param"]={[1]="ply";[2]="ent";["ent"]="Entity being punted";["ply"]="Player punting the gravgun";};};["readcell"]={["ret"]="The value read";["description"]="\
Called when a high speed device reads from a wired SF chip";["class"]="hook";["classForced"]=true;["summary"]="\
Called when a high speed device reads from a wired SF chip ";["name"]="readcell";["realm"]="sv";["server"]=true;["param"]={[1]="address";["address"]="The address requested";};};["EndEntityDriving"]={["description"]="\
Called when a player stops driving an entity";["class"]="hook";["server"]=true;["classForced"]=true;["realm"]="sh";["name"]="EndEntityDriving";["summary"]="\
Called when a player stops driving an entity ";["client"]=true;["param"]={[1]="ent";[2]="ply";["ply"]="Player that drove the entity";["ent"]="Entity that had been driven";};};["OnEntityCreated"]={["description"]="\
Called when an entity gets created";["class"]="hook";["server"]=true;["classForced"]=true;["realm"]="sh";["name"]="OnEntityCreated";["summary"]="\
Called when an entity gets created ";["client"]=true;["param"]={[1]="ent";["ent"]="New entity";};};["PlayerDisconnected"]={["description"]="\
Called when a player disconnects";["class"]="hook";["summary"]="\
Called when a player disconnects ";["classForced"]=true;["name"]="PlayerDisconnected";["realm"]="sh";["server"]=true;["param"]={[1]="ply";["ply"]="Player that disconnected";};};["StartChat"]={["description"]="\
Called when the local player opens their chat window.";["class"]="hook";["summary"]="\
Called when the local player opens their chat window.";["classForced"]=true;["name"]="StartChat";["realm"]="sh";["client"]=true;["param"]={};};["GravGunOnDropped"]={["description"]="\
Called when an entity is being dropped by a gravity gun";["class"]="hook";["summary"]="\
Called when an entity is being dropped by a gravity gun ";["classForced"]=true;["name"]="GravGunOnDropped";["realm"]="sh";["server"]=true;["param"]={[1]="ply";[2]="ent";["ent"]="Entity being dropped";["ply"]="Player dropping the object";};};["inputReleased"]={["classForced"]=true;["description"]="\
Called when a button is released";["name"]="inputReleased";["realm"]="sh";["summary"]="\
Called when a button is released ";["class"]="hook";["param"]={[1]="button";["button"]="Number of the button";};};["PlayerHurt"]={["description"]="\
Called when a player gets hurt";["class"]="hook";["server"]=true;["classForced"]=true;["realm"]="sh";["name"]="PlayerHurt";["summary"]="\
Called when a player gets hurt ";["client"]=true;["param"]={[1]="ply";[2]="attacker";[3]="newHealth";[4]="damageTaken";["newHealth"]="New health of the player";["damageTaken"]="Amount of damage the player has taken";["ply"]="Player being hurt";["attacker"]="Entity causing damage to the player";};};["inputPressed"]={["classForced"]=true;["description"]="\
Called when a button is pressed";["name"]="inputPressed";["realm"]="sh";["summary"]="\
Called when a button is pressed ";["class"]="hook";["param"]={[1]="button";["button"]="Number of the button";};};["PlayerChat"]={["description"]="\
Called when a player's chat message is printed to the chat window";["class"]="hook";["summary"]="\
Called when a player's chat message is printed to the chat window ";["classForced"]=true;["name"]="PlayerChat";["realm"]="sh";["client"]=true;["param"]={[1]="ply";[2]="text";[3]="team";[4]="isdead";["isdead"]="Whether the message was send from a dead player";["text"]="The message";["ply"]="Player that said the message";["team"]="Whether the message was team only";};};["Initialize"]={["description"]="\
Called after the starfall chip is placed/reloaded with the toolgun or duplicated and the duplication is finished.";["class"]="hook";["summary"]="\
Called after the starfall chip is placed/reloaded with the toolgun or duplicated and the duplication is finished.";["classForced"]=true;["name"]="Initialize";["realm"]="sh";["server"]=true;["param"]={};};["Removed"]={["description"]="\
Called when the starfall chip is removed";["class"]="hook";["summary"]="\
Called when the starfall chip is removed ";["classForced"]=true;["name"]="Removed";["realm"]="sh";["server"]=true;["param"]={};};["tick"]={["description"]="\
Tick hook. Called each game tick on both the server and client.";["class"]="hook";["server"]=true;["classForced"]=true;["realm"]="sh";["name"]="tick";["summary"]="\
Tick hook.";["client"]=true;["param"]={};};["think"]={["description"]="\
Think hook. Called each frame on the client and each game tick on the server.";["class"]="hook";["server"]=true;["classForced"]=true;["realm"]="sh";["name"]="think";["summary"]="\
Think hook.";["client"]=true;["param"]={};};["PropBreak"]={["description"]="\
Called when an entity is broken";["class"]="hook";["server"]=true;["classForced"]=true;["realm"]="sh";["name"]="PropBreak";["summary"]="\
Called when an entity is broken ";["client"]=true;["param"]={[1]="ply";[2]="ent";["ent"]="Entity broken";["ply"]="Player who broke it";};};["PlayerNoClip"]={["description"]="\
Called when a player toggles noclip";["class"]="hook";["server"]=true;["classForced"]=true;["realm"]="sh";["name"]="PlayerNoClip";["summary"]="\
Called when a player toggles noclip ";["client"]=true;["param"]={[1]="ply";[2]="newState";["newState"]="New noclip state. True if on.";["ply"]="Player toggling noclip";};};["StartEntityDriving"]={["description"]="\
Called when a player starts driving an entity";["class"]="hook";["server"]=true;["classForced"]=true;["realm"]="sh";["name"]="StartEntityDriving";["summary"]="\
Called when a player starts driving an entity ";["client"]=true;["param"]={[1]="ent";[2]="ply";["ply"]="Player that is driving the entity";["ent"]="Entity being driven";};};["predrawopaquerenderables"]={["description"]="\
Called before opaque entities are drawn. (Only works with HUD) (3D context)";["class"]="hook";["summary"]="\
Called before opaque entities are drawn.";["classForced"]=true;["name"]="predrawopaquerenderables";["realm"]="cl";["client"]=true;["param"]={[1]="boolean";["boolean"]="isDrawSkybox  Whether the current draw is drawing the skybox.";};};["EntityRemoved"]={["description"]="\
Called when an entity is removed";["class"]="hook";["server"]=true;["classForced"]=true;["realm"]="sh";["name"]="EntityRemoved";["summary"]="\
Called when an entity is removed ";["client"]=true;["param"]={[1]="ent";["ent"]="Entity being removed";};};["PlayerLeaveVehicle"]={["description"]="\
Called when a players leaves a vehicle";["class"]="hook";["summary"]="\
Called when a players leaves a vehicle ";["classForced"]=true;["name"]="PlayerLeaveVehicle";["realm"]="sh";["server"]=true;["param"]={[1]="ply";[2]="vehicle";["vehicle"]="Vehicle that was left";["ply"]="Player who left a vehicle";};};["postdrawhud"]={["description"]="\
Called after drawing HUD (2D Context)";["class"]="hook";["summary"]="\
Called after drawing HUD (2D Context) ";["classForced"]=true;["name"]="postdrawhud";["realm"]="cl";["client"]=true;["param"]={};};["predrawhud"]={["description"]="\
Called before drawing HUD (2D Context)";["class"]="hook";["summary"]="\
Called before drawing HUD (2D Context) ";["classForced"]=true;["name"]="predrawhud";["realm"]="cl";["client"]=true;["param"]={};};["PlayerEnteredVehicle"]={["description"]="\
Called when a players enters a vehicle";["class"]="hook";["summary"]="\
Called when a players enters a vehicle ";["classForced"]=true;["name"]="PlayerEnteredVehicle";["realm"]="sh";["server"]=true;["param"]={[1]="ply";[2]="vehicle";[3]="num";["num"]="Role";["ply"]="Player who entered a vehicle";["vehicle"]="Vehicle that was entered";};};["PlayerSay"]={["ret"]="New text. \"\" to stop from displaying. Nil to keep original.";["description"]="\
Called when a player sends a chat message";["class"]="hook";["summary"]="\
Called when a player sends a chat message ";["classForced"]=true;["name"]="PlayerSay";["realm"]="sh";["server"]=true;["param"]={[1]="ply";[2]="text";[3]="teamChat";["text"]="Content of the message";["ply"]="Player that sent the message";["teamChat"]="True if team chat";};};["drawhud"]={["description"]="\
Called when a frame is requested to be drawn on hud. (2D Context)";["class"]="hook";["summary"]="\
Called when a frame is requested to be drawn on hud.";["classForced"]=true;["name"]="drawhud";["realm"]="cl";["client"]=true;["param"]={};};["postdrawopaquerenderables"]={["description"]="\
Called after opaque entities are drawn. (Only works with HUD) (3D context)";["class"]="hook";["summary"]="\
Called after opaque entities are drawn.";["classForced"]=true;["name"]="postdrawopaquerenderables";["realm"]="cl";["client"]=true;["param"]={[1]="boolean";["boolean"]="isDrawSkybox  Whether the current draw is drawing the skybox.";};};["renderoffscreen"]={["description"]="\
Called when a frame is requested to be drawn. Doesn't require a screen or HUD but only works on rendertargets. (2D Context)";["class"]="hook";["summary"]="\
Called when a frame is requested to be drawn.";["classForced"]=true;["name"]="renderoffscreen";["realm"]="cl";["client"]=true;["param"]={};};["PhysgunDrop"]={["description"]="\
Called when an entity being held by a physgun gets dropped";["class"]="hook";["server"]=true;["classForced"]=true;["realm"]="sh";["name"]="PhysgunDrop";["summary"]="\
Called when an entity being held by a physgun gets dropped ";["client"]=true;["param"]={[1]="ply";[2]="ent";["ent"]="Entity being dropped";["ply"]="Player droppig the entity";};};["input"]={["classForced"]=true;["description"]="\
Called when an input on a wired SF chip is written to";["name"]="input";["realm"]="sv";["summary"]="\
Called when an input on a wired SF chip is written to ";["class"]="hook";["param"]={[1]="input";[2]="value";["input"]="The input name";["value"]="The value of the input";};};["starfallUsed"]={["classForced"]=true;["description"]="\
Called when a player uses the screen";["name"]="starfallUsed";["realm"]="cl";["summary"]="\
Called when a player uses the screen ";["class"]="hook";["param"]={[1]="activator";["activator"]="Player using the screen";};};["PlayerDeath"]={["description"]="\
Called when a player dies";["class"]="hook";["summary"]="\
Called when a player dies ";["classForced"]=true;["name"]="PlayerDeath";["realm"]="sh";["server"]=true;["param"]={[1]="ply";[2]="inflictor";[3]="attacker";["inflictor"]="Entity used to kill the player";["attacker"]="Entity that killed the player";["ply"]="Player who died";};};["permissionrequest"]={["description"]="\
Called when local client changed instance permissions";["class"]="hook";["summary"]="\
Called when local client changed instance permissions ";["classForced"]=true;["name"]="permissionrequest";["realm"]="sh";["client"]=true;["param"]={};};};["libraries"]={[1]="bass";[2]="builtin";[3]="constraint";[4]="coroutine";[5]="fastlz";[6]="file";[7]="find";[8]="game";[9]="holograms";[10]="hook";[11]="http";[12]="input";[13]="joystick";[14]="json";[15]="mesh";[16]="net";[17]="particle";[18]="physenv";[19]="prop";[20]="quaternion";[21]="render";[22]="sounds";[23]="team";[24]="timer";[25]="trace";[26]="von";[27]="wire";["render"]={["tables"]={};["functions"]={[1]="capturePixels";[2]="clear";[3]="clearBuffersObeyStencil";[4]="clearDepth";[5]="clearStencil";[6]="clearStencilBufferRectangle";[7]="createFont";[8]="createRenderTarget";[9]="cursorPos";[10]="destroyRenderTarget";[11]="destroyTexture";[12]="disableScissorRect";[13]="draw3DBeam";[14]="draw3DBox";[15]="draw3DLine";[16]="draw3DQuad";[17]="draw3DSphere";[18]="draw3DSprite";[19]="draw3DWireframeBox";[20]="draw3DWireframeSphere";[21]="drawCircle";[22]="drawLine";[23]="drawPoly";[24]="drawRect";[25]="drawRectOutline";[26]="drawRoundedBox";[27]="drawRoundedBoxEx";[28]="drawSimpleText";[29]="drawText";[30]="drawTexturedRect";[31]="drawTexturedRectRotated";[32]="drawTexturedRectUV";[33]="enableDepth";[34]="enableScissorRect";[35]="getDefaultFont";[36]="getGameResolution";[37]="getRenderTargetMaterial";[38]="getResolution";[39]="getScreenEntity";[40]="getScreenInfo";[41]="getTextSize";[42]="getTextureID";[43]="isHUDActive";[44]="parseMarkup";[45]="popMatrix";[46]="popViewMatrix";[47]="pushMatrix";[48]="pushViewMatrix";[49]="readPixel";[50]="selectRenderTarget";[51]="setBackgroundColor";[52]="setColor";[53]="setCullMode";[54]="setFilterMag";[55]="setFilterMin";[56]="setFont";[57]="setRGBA";[58]="setRenderTargetTexture";[59]="setStencilCompareFunction";[60]="setStencilEnable";[61]="setStencilFailOperation";[62]="setStencilPassOperation";[63]="setStencilReferenceValue";[64]="setStencilTestMask";[65]="setStencilWriteMask";[66]="setStencilZFailOperation";[67]="setTexture";[68]="setTextureFromScreen";[69]="traceSurfaceColor";["drawTexturedRectUV"]={["class"]="function";["description"]="\
Draws a textured rectangle with UV coordinates";["fname"]="drawTexturedRectUV";["realm"]="cl";["name"]="render_library.drawTexturedRectUV";["summary"]="\
Draws a textured rectangle with UV coordinates ";["private"]=false;["library"]="render";["param"]={[1]="x";[2]="y";[3]="w";[4]="h";[5]="startU";[6]="startV";[7]="endU";[8]="endV";["startV"]="Texture mapping at rectangle origin";["x"]="Top left corner x coordinate";["endV"]="Texture mapping at rectangle end";["startU"]="Texture mapping at rectangle origin";["y"]="Top left corner y coordinate";["w"]="Width";["h"]="Height";};};["clearDepth"]={["class"]="function";["description"]="\
Resets the depth buffer";["fname"]="clearDepth";["realm"]="cl";["name"]="render_library.clearDepth";["summary"]="\
Resets the depth buffer ";["private"]=false;["library"]="render";["param"]={};};["pushMatrix"]={["class"]="function";["description"]="\
Pushes a matrix onto the matrix stack.";["fname"]="pushMatrix";["realm"]="cl";["name"]="render_library.pushMatrix";["summary"]="\
Pushes a matrix onto the matrix stack.";["private"]=false;["library"]="render";["param"]={[1]="m";[2]="world";["m"]="The matrix";["world"]="Should the transformation be relative to the screen or world?";};};["drawRoundedBoxEx"]={["class"]="function";["description"]="\
Draws a rounded rectangle using the current color";["fname"]="drawRoundedBoxEx";["realm"]="cl";["name"]="render_library.drawRoundedBoxEx";["summary"]="\
Draws a rounded rectangle using the current color ";["private"]=false;["library"]="render";["param"]={[1]="r";[2]="x";[3]="y";[4]="w";[5]="h";[6]="tl";[7]="tr";[8]="bl";[9]="br";["tr"]="Boolean Top right corner";["tl"]="Boolean Top left corner";["r"]="The corner radius";["w"]="Width";["y"]="Top left corner y coordinate";["h"]="Height";["x"]="Top left corner x coordinate";["br"]="Boolean Bottom right corner";["bl"]="Boolean Bottom left corner";};};["setStencilPassOperation"]={["class"]="function";["description"]="\
Sets the operation to be performed on the stencil buffer values if the compare function was successful. More: http://wiki.garrysmod.com/page/render/SetStencilPassOperation";["fname"]="setStencilPassOperation";["realm"]="cl";["name"]="render_library.setStencilPassOperation";["summary"]="\
Sets the operation to be performed on the stencil buffer values if the compare function was successful.";["private"]=false;["library"]="render";["param"]={[1]="operation";["operation"]="";};};["clearBuffersObeyStencil"]={["class"]="function";["description"]="\
Clears the current rendertarget for obeying the current stencil buffer conditions.";["fname"]="clearBuffersObeyStencil";["realm"]="cl";["name"]="render_library.clearBuffersObeyStencil";["summary"]="\
Clears the current rendertarget for obeying the current stencil buffer conditions.";["private"]=false;["library"]="render";["param"]={[1]="r";[2]="g";[3]="b";[4]="a";[5]="depth";["r"]="Value of the red channel to clear the current rt with.";["depth"]="Clear the depth buffer.";["g"]="Value of the green channel to clear the current rt with.";["b"]="Value of the blue channel to clear the current rt with.";};};["setStencilFailOperation"]={["class"]="function";["description"]="\
Sets the operation to be performed on the stencil buffer values if the compare function was not successful. More: http://wiki.garrysmod.com/page/render/SetStencilFailOperation";["fname"]="setStencilFailOperation";["realm"]="cl";["name"]="render_library.setStencilFailOperation";["summary"]="\
Sets the operation to be performed on the stencil buffer values if the compare function was not successful.";["private"]=false;["library"]="render";["param"]={[1]="operation";["operation"]="";};};["setTexture"]={["class"]="function";["description"]="\
Sets the texture";["fname"]="setTexture";["realm"]="cl";["name"]="render_library.setTexture";["summary"]="\
Sets the texture ";["private"]=false;["library"]="render";["param"]={[1]="id";["id"]="Texture table. Aquired with render.getTextureID";};};["setCullMode"]={["class"]="function";["description"]="\
Changes the cull mode";["fname"]="setCullMode";["realm"]="cl";["name"]="render_library.setCullMode";["summary"]="\
Changes the cull mode ";["private"]=false;["library"]="render";["param"]={[1]="mode";["mode"]="Cull mode. 0 for counter clock wise, 1 for clock wise";};};["draw3DSprite"]={["class"]="function";["description"]="\
Draws a sprite in 3d space.";["fname"]="draw3DSprite";["realm"]="cl";["name"]="render_library.draw3DSprite";["summary"]="\
Draws a sprite in 3d space.";["private"]=false;["library"]="render";["param"]={[1]="pos";[2]="width";[3]="height";["height"]="Height of the sprite.";["width"]="Width of the sprite.";["pos"]="Position of the sprite.";};};["traceSurfaceColor"]={["ret"]="The color vector. use vector:toColor to convert it to a color.";["class"]="function";["description"]="\
Does a trace and returns the color of the textel the trace hits.";["fname"]="traceSurfaceColor";["realm"]="cl";["name"]="render_library.traceSurfaceColor";["summary"]="\
Does a trace and returns the color of the textel the trace hits.";["private"]=false;["library"]="render";["param"]={[1]="vec1";[2]="vec2";["vec1"]="The starting vector";["vec2"]="The ending vector";};};["setRGBA"]={["class"]="function";["description"]="\
Sets the draw color by RGBA values";["fname"]="setRGBA";["realm"]="cl";["name"]="render_library.setRGBA";["summary"]="\
Sets the draw color by RGBA values ";["private"]=false;["library"]="render";["param"]={[1]="r";[2]="g";[3]="b";[4]="a";};};["drawText"]={["class"]="function";["description"]="\
Draws text with newlines and tabs";["fname"]="drawText";["realm"]="cl";["name"]="render_library.drawText";["summary"]="\
Draws text with newlines and tabs ";["private"]=false;["library"]="render";["param"]={[1]="x";[2]="y";[3]="text";[4]="alignment";["y"]="Y coordinate";["x"]="X coordinate";["alignment"]="Text alignment";["text"]="Text to draw";};};["enableDepth"]={["class"]="function";["description"]="\
Enables or disables Depth Buffer";["fname"]="enableDepth";["realm"]="cl";["name"]="render_library.enableDepth";["summary"]="\
Enables or disables Depth Buffer ";["private"]=false;["library"]="render";["param"]={[1]="enable";["enable"]="true to enable";};};["getDefaultFont"]={["ret"]="Default font";["class"]="function";["description"]="\
Gets the default font";["fname"]="getDefaultFont";["realm"]="cl";["name"]="render_library.getDefaultFont";["summary"]="\
Gets the default font ";["private"]=false;["library"]="render";["param"]={};};["setFilterMin"]={["class"]="function";["description"]="\
Sets the texture filtering function when viewing a far texture";["fname"]="setFilterMin";["realm"]="cl";["name"]="render_library.setFilterMin";["summary"]="\
Sets the texture filtering function when viewing a far texture ";["private"]=false;["library"]="render";["param"]={[1]="val";["val"]="The filter function to use http://wiki.garrysmod.com/page/Enums/TEXFILTER";};};["drawRect"]={["class"]="function";["description"]="\
Draws a rectangle using the current color.";["fname"]="drawRect";["realm"]="cl";["name"]="render_library.drawRect";["summary"]="\
Draws a rectangle using the current color.";["private"]=false;["library"]="render";["param"]={[1]="x";[2]="y";[3]="w";[4]="h";["y"]="Top left corner y coordinate";["h"]="Height";["w"]="Width";["x"]="Top left corner x coordinate";};};["draw3DBeam"]={["class"]="function";["description"]="\
Draws textured beam.";["fname"]="draw3DBeam";["realm"]="cl";["name"]="render_library.draw3DBeam";["summary"]="\
Draws textured beam.";["private"]=false;["library"]="render";["param"]={[1]="startPos";[2]="endPos";[3]="width";[4]="textureStart";[5]="textureEnd";["endPos"]="Beam end position.";["textureStart"]="The start coordinate of the texture used.";["textureEnd"]="The end coordinate of the texture used.";["startPos"]="Beam start position.";["width"]="The width of the beam.";};};["setStencilZFailOperation"]={["class"]="function";["description"]="\
Sets the operation to be performed on the stencil buffer values if the stencil test is passed but the depth buffer test fails. More: http://wiki.garrysmod.com/page/render/SetStencilZFailOperation";["fname"]="setStencilZFailOperation";["realm"]="cl";["name"]="render_library.setStencilZFailOperation";["summary"]="\
Sets the operation to be performed on the stencil buffer values if the stencil test is passed but the depth buffer test fails.";["private"]=false;["library"]="render";["param"]={[1]="operation";["operation"]="";};};["setRenderTargetTexture"]={["class"]="function";["description"]="\
Sets the active texture to the render target with the specified name. \
Nil to reset.";["fname"]="setRenderTargetTexture";["realm"]="cl";["name"]="render_library.setRenderTargetTexture";["summary"]="\
Sets the active texture to the render target with the specified name.";["private"]=false;["library"]="render";["param"]={[1]="name";["name"]="Name of the render target to use";};};["enableScissorRect"]={["class"]="function";["description"]="\
Enables a scissoring rect which limits the drawing area. Only works 2D contexts such as HUD or render targets.";["fname"]="enableScissorRect";["realm"]="cl";["name"]="render_library.enableScissorRect";["summary"]="\
Enables a scissoring rect which limits the drawing area.";["private"]=false;["library"]="render";["param"]={[1]="startX";[2]="startY";[3]="endX";[4]="endY";["endX"]="Y end coordinate of the scissor rect.";["startY"]="Y start coordinate of the scissor rect.";["startX"]="X start coordinate of the scissor rect.";};};["clear"]={["class"]="function";["description"]="\
Clears the active render target";["fname"]="clear";["realm"]="cl";["name"]="render_library.clear";["summary"]="\
Clears the active render target ";["private"]=false;["library"]="render";["param"]={[1]="clr";[2]="depth";["depth"]="Boolean if should clear depth";["clr"]="Color type to clear with";};};["getTextureID"]={["ret"]="Texture table. Use it with render.setTexture. Returns nil if max url textures is reached.";["class"]="function";["description"]="\
Looks up a texture by file name. Use with render.setTexture to draw with it. \
Make sure to store the texture to use it rather than calling this slow function repeatedly.";["fname"]="getTextureID";["realm"]="cl";["name"]="render_library.getTextureID";["summary"]="\
Looks up a texture by file name.";["private"]=false;["library"]="render";["param"]={[1]="tx";[2]="cb";[3]="alignment";[4]="skip_hack";["skip_hack"]="Turns off texture hack so you can use UVs on 3D objects";["alignment"]="Optional alignment for the url texture. Default: \"center\", See http://www.w3schools.com/cssref/pr_background-position.asp";["cb"]="Optional callback for when a url texture finishes loading. param1 - The texture table, param2 - The texture url";["tx"]="Texture file path, a http url, or image data: https://en.wikipedia.org/wiki/Data_URI_scheme";};};["clearStencilBufferRectangle"]={["class"]="function";["description"]="\
Sets the stencil value in a specified rect.";["fname"]="clearStencilBufferRectangle";["realm"]="cl";["name"]="render_library.clearStencilBufferRectangle";["summary"]="\
Sets the stencil value in a specified rect.";["private"]=false;["library"]="render";["param"]={[1]="originX";[2]="originY";[3]="endX";[4]="endY";[5]="stencilValue";["originY"]="Y origin of the rectangle.";["originX"]="X origin of the rectangle.";["endX"]="The end X coordinate of the rectangle.";["endY"]="The end Y coordinate of the rectangle.";["stencilValue"]="Value to set cleared stencil buffer to.";};};["destroyTexture"]={["class"]="function";["description"]="\
Releases the texture. Required if you reach the maximum url textures.";["fname"]="destroyTexture";["realm"]="cl";["name"]="render_library.destroyTexture";["summary"]="\
Releases the texture.";["private"]=false;["library"]="render";["param"]={[1]="id";["id"]="Texture table. Aquired with render.getTextureID";};};["pushViewMatrix"]={["class"]="function";["description"]="\
Pushes a perspective matrix onto the view matrix stack.";["fname"]="pushViewMatrix";["realm"]="cl";["name"]="render_library.pushViewMatrix";["summary"]="\
Pushes a perspective matrix onto the view matrix stack.";["private"]=false;["library"]="render";["param"]={[1]="tbl";["tbl"]="The view matrix data. See http://wiki.garrysmod.com/page/Structures/RenderCamData";};};["popMatrix"]={["class"]="function";["description"]="\
Pops a matrix from the matrix stack.";["fname"]="popMatrix";["realm"]="cl";["name"]="render_library.popMatrix";["summary"]="\
Pops a matrix from the matrix stack.";["private"]=false;["library"]="render";["param"]={};};["setStencilEnable"]={["class"]="function";["description"]="\
Sets whether stencil tests are carried out for each rendered pixel. Only pixels passing the stencil test are written to the render target.";["fname"]="setStencilEnable";["realm"]="cl";["name"]="render_library.setStencilEnable";["summary"]="\
Sets whether stencil tests are carried out for each rendered pixel.";["private"]=false;["library"]="render";["param"]={[1]="enable";["enable"]="true to enable, false to disable";};};["cursorPos"]={["ret"]={[1]="x position";[2]="y position";};["class"]="function";["description"]="\
Gets a 2D cursor position where ply is aiming.";["fname"]="cursorPos";["realm"]="cl";["name"]="render_library.cursorPos";["summary"]="\
Gets a 2D cursor position where ply is aiming.";["private"]=false;["library"]="render";["param"]={[1]="ply";["ply"]="player to get cursor position from(optional)";};};["createFont"]={["description"]="\
Creates a font. Does not require rendering hook";["class"]="function";["realm"]="cl";["fname"]="createFont";["summary"]="\
Creates a font.";["name"]="render_library.createFont";["library"]="render";["private"]=false;["usage"]="\
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
- Times New Roman";["param"]={[1]="font";[2]="size";[3]="weight";[4]="antialias";[5]="additive";[6]="shadow";[7]="outline";[8]="blur";[9]="extended";["outline"]="Enable outline?";["shadow"]="Enable drop shadow?";["blur"]="Enable blur?";["additive"]="If true, adds brightness to pixels behind it rather than drawing over them.";["font"]="Base font to use";["weight"]="Font weight (default: 400)";["extended"]="Allows the font to display glyphs outside of Latin-1 range. Unicode code points above 0xFFFF are not supported. Required to use FontAwesome";["antialias"]="Antialias font?";["size"]="Font size";};};["disableScissorRect"]={["class"]="function";["description"]="\
Disables a scissoring rect which limits the drawing area.";["fname"]="disableScissorRect";["realm"]="cl";["name"]="render_library.disableScissorRect";["summary"]="\
Disables a scissoring rect which limits the drawing area.";["private"]=false;["library"]="render";["param"]={};};["setStencilCompareFunction"]={["class"]="function";["description"]="\
Sets the compare function of the stencil. More: http://wiki.garrysmod.com/page/render/SetStencilCompareFunction";["fname"]="setStencilCompareFunction";["realm"]="cl";["name"]="render_library.setStencilCompareFunction";["summary"]="\
Sets the compare function of the stencil.";["private"]=false;["library"]="render";["param"]={[1]="compareFunction";["compareFunction"]="";};};["isHUDActive"]={["class"]="function";["description"]="\
Checks if a hud component is connected to the Starfall Chip";["fname"]="isHUDActive";["realm"]="cl";["name"]="render_library.isHUDActive";["summary"]="\
Checks if a hud component is connected to the Starfall Chip ";["private"]=false;["library"]="render";["param"]={};};["parseMarkup"]={["ret"]="The markup object. See https://wiki.garrysmod.com/page/Category:MarkupObject";["class"]="function";["description"]="\
Constructs a markup object for quick styled text drawing.";["fname"]="parseMarkup";["realm"]="cl";["name"]="render_library.parseMarkup";["summary"]="\
Constructs a markup object for quick styled text drawing.";["private"]=false;["library"]="render";["param"]={[1]="str";[2]="maxsize";["str"]="The markup string to parse";["maxsize"]="The max width of the markup";};};["getTextSize"]={["ret"]={[1]="width of the text";[2]="height of the text";};["class"]="function";["description"]="\
Gets the size of the specified text. Don't forget to use setFont before calling this function";["fname"]="getTextSize";["realm"]="cl";["name"]="render_library.getTextSize";["summary"]="\
Gets the size of the specified text.";["private"]=false;["library"]="render";["param"]={[1]="text";["text"]="Text to get the size of";};};["drawRectOutline"]={["class"]="function";["description"]="\
Draws a rectangle outline using the current color.";["fname"]="drawRectOutline";["realm"]="cl";["name"]="render_library.drawRectOutline";["summary"]="\
Draws a rectangle outline using the current color.";["private"]=false;["library"]="render";["param"]={[1]="x";[2]="y";[3]="w";[4]="h";["y"]="Top left corner y coordinate";["h"]="Height";["w"]="Width";["x"]="Top left corner x coordinate";};};["setColor"]={["class"]="function";["description"]="\
Sets the draw color";["fname"]="setColor";["realm"]="cl";["name"]="render_library.setColor";["summary"]="\
Sets the draw color ";["private"]=false;["library"]="render";["param"]={[1]="clr";["clr"]="Color type";};};["getGameResolution"]={["ret"]={[1]="the X size of the game window";[2]="the Y size of the game window";};["description"]="\
Returns width and height of the game window";["class"]="function";["realm"]="cl";["classForced"]=true;["summary"]="\
Returns width and height of the game window ";["name"]="render_library.getGameResolution";["fname"]="getGameResolution";["private"]=false;["library"]="render";["param"]={};};["getResolution"]={["ret"]={[1]="the X size of the current render context";[2]="the Y size of the current render context";};["description"]="\
Returns the render context's width and height";["class"]="function";["realm"]="cl";["classForced"]=true;["summary"]="\
Returns the render context's width and height ";["name"]="render_library.getResolution";["fname"]="getResolution";["private"]=false;["library"]="render";["param"]={};};["drawSimpleText"]={["class"]="function";["description"]="\
Draws text more easily and quickly but no new lines or tabs.";["fname"]="drawSimpleText";["realm"]="cl";["name"]="render_library.drawSimpleText";["summary"]="\
Draws text more easily and quickly but no new lines or tabs.";["private"]=false;["library"]="render";["param"]={[1]="x";[2]="y";[3]="text";[4]="xalign";[5]="yalign";["yalign"]="Text y alignment";["x"]="X coordinate";["y"]="Y coordinate";["text"]="Text to draw";["xalign"]="Text x alignment";};};["readPixel"]={["ret"]="Color object with ( r, g, b, 255 ) from the specified pixel.";["class"]="function";["description"]="\
Reads the color of the specified pixel.";["fname"]="readPixel";["realm"]="cl";["name"]="render_library.readPixel";["summary"]="\
Reads the color of the specified pixel.";["private"]=false;["library"]="render";["param"]={[1]="x";[2]="y";["y"]="Pixel y-coordinate.";["x"]="Pixel x-coordinate.";};};["drawRoundedBox"]={["class"]="function";["description"]="\
Draws a rounded rectangle using the current color";["fname"]="drawRoundedBox";["realm"]="cl";["name"]="render_library.drawRoundedBox";["summary"]="\
Draws a rounded rectangle using the current color ";["private"]=false;["library"]="render";["param"]={[1]="r";[2]="x";[3]="y";[4]="w";[5]="h";["y"]="Top left corner y coordinate";["h"]="Height";["r"]="The corner radius";["w"]="Width";["x"]="Top left corner x coordinate";};};["drawCircle"]={["class"]="function";["description"]="\
Draws a circle outline";["fname"]="drawCircle";["realm"]="cl";["name"]="render_library.drawCircle";["summary"]="\
Draws a circle outline ";["private"]=false;["library"]="render";["param"]={[1]="x";[2]="y";[3]="r";["y"]="Center y coordinate";["x"]="Center x coordinate";["r"]="Radius";};};["draw3DWireframeBox"]={["class"]="function";["description"]="\
Draws a wireframe box in 3D space";["fname"]="draw3DWireframeBox";["realm"]="cl";["name"]="render_library.draw3DWireframeBox";["summary"]="\
Draws a wireframe box in 3D space ";["private"]=false;["library"]="render";["param"]={[1]="origin";[2]="angle";[3]="mins";[4]="maxs";["origin"]="Origin of the box.";["maxs"]="End position of the box, relative to origin.";["angle"]="Orientation  of the box";["mins"]="Start position of the box, relative to origin.";};};["drawTexturedRect"]={["class"]="function";["description"]="\
Draws a textured rectangle.";["fname"]="drawTexturedRect";["realm"]="cl";["name"]="render_library.drawTexturedRect";["summary"]="\
Draws a textured rectangle.";["private"]=false;["library"]="render";["param"]={[1]="x";[2]="y";[3]="w";[4]="h";["y"]="Top left corner y coordinate";["h"]="Height";["w"]="Width";["x"]="Top left corner x coordinate";};};["setFilterMag"]={["class"]="function";["description"]="\
Sets the texture filtering function when viewing a close texture";["fname"]="setFilterMag";["realm"]="cl";["name"]="render_library.setFilterMag";["summary"]="\
Sets the texture filtering function when viewing a close texture ";["private"]=false;["library"]="render";["param"]={[1]="val";["val"]="The filter function to use http://wiki.garrysmod.com/page/Enums/TEXFILTER";};};["popViewMatrix"]={["class"]="function";["description"]="\
Pops a view matrix from the matrix stack.";["fname"]="popViewMatrix";["realm"]="cl";["name"]="render_library.popViewMatrix";["summary"]="\
Pops a view matrix from the matrix stack.";["private"]=false;["library"]="render";["param"]={};};["capturePixels"]={["class"]="function";["description"]="\
Dumps the current render target and allows the pixels to be accessed by render.readPixel.";["fname"]="capturePixels";["realm"]="cl";["name"]="render_library.capturePixels";["summary"]="\
Dumps the current render target and allows the pixels to be accessed by render.readPixel.";["private"]=false;["library"]="render";["param"]={};};["setStencilWriteMask"]={["class"]="function";["description"]="\
Sets the unsigned 8-bit write bitflag mask to be used for any writes to the stencil buffer.";["fname"]="setStencilWriteMask";["realm"]="cl";["name"]="render_library.setStencilWriteMask";["summary"]="\
Sets the unsigned 8-bit write bitflag mask to be used for any writes to the stencil buffer.";["private"]=false;["library"]="render";["param"]={[1]="mask";["mask"]="The mask bitflag.";};};["draw3DWireframeSphere"]={["class"]="function";["description"]="\
Draws a wireframe sphere";["fname"]="draw3DWireframeSphere";["realm"]="cl";["name"]="render_library.draw3DWireframeSphere";["summary"]="\
Draws a wireframe sphere ";["private"]=false;["library"]="render";["param"]={[1]="pos";[2]="radius";[3]="longitudeSteps";[4]="latitudeSteps";["radius"]="Radius of the sphere";["latitudeSteps"]="The amount of latitude steps. The larger this number is, the smoother the sphere is";["longitudeSteps"]="The amount of longitude steps. The larger this number is, the smoother the sphere is";["pos"]="Position of the sphere";};};["selectRenderTarget"]={["class"]="function";["description"]="\
Selects the render target to draw on. \
Nil for the visible RT.";["fname"]="selectRenderTarget";["realm"]="cl";["name"]="render_library.selectRenderTarget";["summary"]="\
Selects the render target to draw on.";["private"]=false;["library"]="render";["param"]={[1]="name";["name"]="Name of the render target to use";};};["getRenderTargetMaterial"]={["ret"]="Model material name. use ent:setMaterial in clientside to set the entity's material to this";["class"]="function";["description"]="\
Returns the model material name that uses the render target.";["fname"]="getRenderTargetMaterial";["realm"]="cl";["name"]="render_library.getRenderTargetMaterial";["summary"]="\
Returns the model material name that uses the render target.";["private"]=false;["library"]="render";["param"]={[1]="name";["name"]="Render target name";};};["draw3DLine"]={["class"]="function";["description"]="\
Draws a 3D Line";["fname"]="draw3DLine";["realm"]="cl";["name"]="render_library.draw3DLine";["summary"]="\
Draws a 3D Line ";["private"]=false;["library"]="render";["param"]={[1]="startPos";[2]="endPos";["endPos"]="Ending position";["startPos"]="Starting position";};};["createRenderTarget"]={["class"]="function";["description"]="\
Creates a new render target to draw onto. \
The dimensions will always be 1024x1024";["fname"]="createRenderTarget";["realm"]="cl";["name"]="render_library.createRenderTarget";["summary"]="\
Creates a new render target to draw onto.";["private"]=false;["library"]="render";["param"]={[1]="name";["name"]="The name of the render target";};};["draw3DBox"]={["class"]="function";["description"]="\
Draws a box in 3D space";["fname"]="draw3DBox";["realm"]="cl";["name"]="render_library.draw3DBox";["summary"]="\
Draws a box in 3D space ";["private"]=false;["library"]="render";["param"]={[1]="origin";[2]="angle";[3]="mins";[4]="maxs";["origin"]="Origin of the box.";["maxs"]="End position of the box, relative to origin.";["angle"]="Orientation  of the box";["mins"]="Start position of the box, relative to origin.";};};["drawLine"]={["class"]="function";["description"]="\
Draws a line";["fname"]="drawLine";["realm"]="cl";["name"]="render_library.drawLine";["summary"]="\
Draws a line ";["private"]=false;["library"]="render";["param"]={[1]="x1";[2]="y1";[3]="x2";[4]="y2";["x2"]="X end coordinate";["y2"]="Y end coordinate";["y1"]="Y start coordinate";["x1"]="X start coordinate";};};["drawTexturedRectRotated"]={["class"]="function";["description"]="\
Draws a rotated, textured rectangle.";["fname"]="drawTexturedRectRotated";["realm"]="cl";["name"]="render_library.drawTexturedRectRotated";["summary"]="\
Draws a rotated, textured rectangle.";["private"]=false;["library"]="render";["param"]={[1]="x";[2]="y";[3]="w";[4]="h";[5]="rot";["y"]="Y coordinate of center of rect";["x"]="X coordinate of center of rect";["rot"]="Rotation in degrees";["w"]="Width";["h"]="Height";};};["getScreenEntity"]={["ret"]="Entity of the screen or hud being rendered";["class"]="function";["description"]="\
Returns the entity currently being rendered to";["fname"]="getScreenEntity";["realm"]="cl";["name"]="render_library.getScreenEntity";["summary"]="\
Returns the entity currently being rendered to ";["private"]=false;["library"]="render";["param"]={};};["setFont"]={["description"]="\
Sets the font";["class"]="function";["realm"]="cl";["fname"]="setFont";["summary"]="\
Sets the font ";["name"]="render_library.setFont";["library"]="render";["private"]=false;["usage"]="Use a font created by render.createFont or use one of these already defined fonts: \
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
- DermaLarge";["param"]={[1]="font";["font"]="The font to use";};};["draw3DSphere"]={["class"]="function";["description"]="\
Draws a sphere";["fname"]="draw3DSphere";["realm"]="cl";["name"]="render_library.draw3DSphere";["summary"]="\
Draws a sphere ";["private"]=false;["library"]="render";["param"]={[1]="pos";[2]="radius";[3]="longitudeSteps";[4]="latitudeSteps";["radius"]="Radius of the sphere";["latitudeSteps"]="The amount of latitude steps. The larger this number is, the smoother the sphere is";["longitudeSteps"]="The amount of longitude steps. The larger this number is, the smoother the sphere is";["pos"]="Position of the sphere";};};["getScreenInfo"]={["ret"]="A table describing the screen.";["class"]="function";["description"]="\
Returns information about the screen, such as world offsets, dimentions, and rotation. \
Note: this does a table copy so move it out of your draw hook";["fname"]="getScreenInfo";["realm"]="cl";["name"]="render_library.getScreenInfo";["summary"]="\
Returns information about the screen, such as world offsets, dimentions, and rotation.";["private"]=false;["library"]="render";["param"]={[1]="e";["e"]="The screen to get info from.";};};["draw3DQuad"]={["class"]="function";["description"]="\
Draws 2 connected triangles.";["fname"]="draw3DQuad";["realm"]="cl";["name"]="render_library.draw3DQuad";["summary"]="\
Draws 2 connected triangles.";["private"]=false;["library"]="render";["param"]={[1]="vert1";[2]="vert2";[3]="vert3";[4]="vert4";["vert3"]="The third vertex.";["vert4"]="The fourth vertex.";["vert2"]="The second vertex.";["vert1"]="First vertex.";};};["clearStencil"]={["class"]="function";["description"]="\
Resets all values in the stencil buffer to zero.";["fname"]="clearStencil";["realm"]="cl";["name"]="render_library.clearStencil";["summary"]="\
Resets all values in the stencil buffer to zero.";["private"]=false;["library"]="render";["param"]={};};["destroyRenderTarget"]={["class"]="function";["description"]="\
Releases the rendertarget. Required if you reach the maximum rendertargets.";["fname"]="destroyRenderTarget";["realm"]="cl";["name"]="render_library.destroyRenderTarget";["summary"]="\
Releases the rendertarget.";["private"]=false;["library"]="render";["param"]={[1]="name";["name"]="Rendertarget name";};};["setStencilTestMask"]={["class"]="function";["description"]="\
Sets the unsigned 8-bit test bitflag mask to be used for any stencil testing.";["fname"]="setStencilTestMask";["realm"]="cl";["name"]="render_library.setStencilTestMask";["summary"]="\
Sets the unsigned 8-bit test bitflag mask to be used for any stencil testing.";["private"]=false;["library"]="render";["param"]={[1]="mask";["mask"]="The mask bitflag.";};};["setTextureFromScreen"]={["class"]="function";["description"]="\
Sets the texture of a screen entity";["fname"]="setTextureFromScreen";["realm"]="cl";["name"]="render_library.setTextureFromScreen";["summary"]="\
Sets the texture of a screen entity ";["private"]=false;["library"]="render";["param"]={[1]="ent";["ent"]="Screen entity";};};["drawPoly"]={["class"]="function";["description"]="\
Draws a polygon.";["fname"]="drawPoly";["realm"]="cl";["name"]="render_library.drawPoly";["summary"]="\
Draws a polygon.";["private"]=false;["library"]="render";["param"]={[1]="poly";["poly"]="Table of polygon vertices. Texture coordinates are optional. {{x=x1, y=y1, u=u1, v=v1}, ... }";};};["setBackgroundColor"]={["class"]="function";["description"]="\
Sets the draw color";["fname"]="setBackgroundColor";["realm"]="cl";["name"]="render_library.setBackgroundColor";["summary"]="\
Sets the draw color ";["private"]=false;["library"]="render";["param"]={[1]="col";[2]="screen";["col"]="Color of background";};};["setStencilReferenceValue"]={["class"]="function";["description"]="\
Sets the reference value which will be used for all stencil operations. This is an unsigned integer.";["fname"]="setStencilReferenceValue";["realm"]="cl";["name"]="render_library.setStencilReferenceValue";["summary"]="\
Sets the reference value which will be used for all stencil operations.";["private"]=false;["library"]="render";["param"]={[1]="referenceValue";["referenceValue"]="Reference value.";};};};["class"]="library";["summary"]="\
Render library.";["fields"]={};["name"]="render";["description"]="\
Render library. Screens are 512x512 units. Most functions require \
that you be in the rendering hook to call, otherwise an error is \
thrown. +x is right, +y is down";["entity"]="starfall_screen";["libtbl"]="render_library";["field"]={[1]="TEXT_ALIGN_LEFT";[2]="TEXT_ALIGN_CENTER";[3]="TEXT_ALIGN_RIGHT";[4]="TEXT_ALIGN_TOP";[5]="TEXT_ALIGN_BOTTOM";["TEXT_ALIGN_CENTER"]="";["TEXT_ALIGN_TOP"]="";["TEXT_ALIGN_BOTTOM"]="";["TEXT_ALIGN_LEFT"]="";["TEXT_ALIGN_RIGHT"]="";};};["quaternion"]={["tables"]={};["functions"]={[1]="New";[2]="abs";[3]="conj";[4]="exp";[5]="inv";[6]="log";[7]="qMod";[8]="qRotation";[9]="qRotation";[10]="qi";[11]="qj";[12]="qk";[13]="rotationAngle";[14]="rotationAxis";[15]="rotationEulerAngle";[16]="rotationVector";[17]="slerp";[18]="vec";["conj"]={["class"]="function";["description"]="\
Returns the conjugate of <q>";["fname"]="conj";["realm"]="sh";["name"]="quat_lib.conj";["summary"]="\
Returns the conjugate of <q> ";["private"]=false;["library"]="quaternion";["param"]={[1]="q";};};["log"]={["class"]="function";["description"]="\
Calculates natural logarithm of <q>";["fname"]="log";["realm"]="sh";["name"]="quat_lib.log";["summary"]="\
Calculates natural logarithm of <q> ";["private"]=false;["library"]="quaternion";["param"]={[1]="q";};};["exp"]={["class"]="function";["description"]="\
Raises Euler's constant e to the power <q>";["fname"]="exp";["realm"]="sh";["name"]="quat_lib.exp";["summary"]="\
Raises Euler's constant e to the power <q> ";["private"]=false;["library"]="quaternion";["param"]={[1]="q";};};["slerp"]={["class"]="function";["description"]="\
Performs spherical linear interpolation between <q0> and <q1>. Returns <q0> for <t>=0, <q1> for <t>=1";["fname"]="slerp";["realm"]="sh";["name"]="quat_lib.slerp";["summary"]="\
Performs spherical linear interpolation between <q0> and <q1>.";["private"]=false;["library"]="quaternion";["param"]={[1]="q0";[2]="q1";[3]="t";};};["qRotation"]={["class"]="function";["description"]="\
Construct a quaternion from the rotation vector <rv1>. Vector direction is axis of rotation, magnitude is angle in degress (by coder0xff)";["fname"]="qRotation";["realm"]="sh";["name"]="quat_lib.qRotation";["summary"]="\
Construct a quaternion from the rotation vector <rv1>.";["private"]=false;["library"]="quaternion";["param"]={[1]="rv1";};};["qMod"]={["class"]="function";["description"]="\
Changes quaternion <q> so that the represented rotation is by an angle between 0 and 180 degrees (by coder0xff)";["fname"]="qMod";["realm"]="sh";["name"]="quat_lib.qMod";["summary"]="\
Changes quaternion <q> so that the represented rotation is by an angle between 0 and 180 degrees (by coder0xff) ";["private"]=false;["library"]="quaternion";["param"]={[1]="q";};};["rotationEulerAngle"]={["class"]="function";["description"]="\
Returns the euler angle of rotation in degrees";["fname"]="rotationEulerAngle";["realm"]="sh";["name"]="quat_lib.rotationEulerAngle";["summary"]="\
Returns the euler angle of rotation in degrees ";["private"]=false;["library"]="quaternion";["param"]={[1]="q";};};["New"]={["class"]="function";["description"]="\
Creates a new Quaternion given a variety of inputs";["fname"]="New";["realm"]="sh";["name"]="quat_lib.New";["summary"]="\
Creates a new Quaternion given a variety of inputs ";["private"]=false;["library"]="quaternion";["param"]={[1]="self";[2]="...";["..."]="A series of arguments which lead to valid generation of a quaternion. \
See argTypesToQuat table for examples of acceptable inputs.";};};["qi"]={["class"]="function";["description"]="\
Returns Quaternion <n>*i";["fname"]="qi";["realm"]="sh";["name"]="quat_lib.qi";["summary"]="\
Returns Quaternion <n>*i ";["private"]=false;["library"]="quaternion";["param"]={[1]="n";};};["qk"]={["class"]="function";["description"]="\
Returns Quaternion <n>*k";["fname"]="qk";["realm"]="sh";["name"]="quat_lib.qk";["summary"]="\
Returns Quaternion <n>*k ";["private"]=false;["library"]="quaternion";["param"]={[1]="n";};};["qj"]={["class"]="function";["description"]="\
Returns Quaternion <n>*j";["fname"]="qj";["realm"]="sh";["name"]="quat_lib.qj";["summary"]="\
Returns Quaternion <n>*j ";["private"]=false;["library"]="quaternion";["param"]={[1]="n";};};["abs"]={["class"]="function";["description"]="\
Returns absolute value of <q>";["fname"]="abs";["realm"]="sh";["name"]="quat_lib.abs";["summary"]="\
Returns absolute value of <q> ";["private"]=false;["library"]="quaternion";["param"]={[1]="q";};};["rotationAxis"]={["class"]="function";["description"]="\
Returns the axis of rotation (by coder0xff)";["fname"]="rotationAxis";["realm"]="sh";["name"]="quat_lib.rotationAxis";["summary"]="\
Returns the axis of rotation (by coder0xff) ";["private"]=false;["library"]="quaternion";["param"]={[1]="q";};};["inv"]={["class"]="function";["description"]="\
Returns the inverse of <q>";["fname"]="inv";["realm"]="sh";["name"]="quat_lib.inv";["summary"]="\
Returns the inverse of <q> ";["private"]=false;["library"]="quaternion";["param"]={[1]="q";};};["rotationAngle"]={["class"]="function";["description"]="\
Returns the angle of rotation in degrees (by coder0xff)";["fname"]="rotationAngle";["realm"]="sh";["name"]="quat_lib.rotationAngle";["summary"]="\
Returns the angle of rotation in degrees (by coder0xff) ";["private"]=false;["library"]="quaternion";["param"]={[1]="q";};};["vec"]={["class"]="function";["description"]="\
Converts <q> to a vector by dropping the real component";["fname"]="vec";["realm"]="sh";["name"]="quat_lib.vec";["summary"]="\
Converts <q> to a vector by dropping the real component ";["private"]=false;["library"]="quaternion";["param"]={[1]="q";};};["rotationVector"]={["class"]="function";["description"]="\
Returns the rotation vector - rotation axis where magnitude is the angle of rotation in degress (by coder0xff)";["fname"]="rotationVector";["realm"]="sh";["name"]="quat_lib.rotationVector";["summary"]="\
Returns the rotation vector - rotation axis where magnitude is the angle of rotation in degress (by coder0xff) ";["private"]=false;["library"]="quaternion";["param"]={[1]="q";};};};["description"]="\
Quaternion library";["class"]="library";["summary"]="\
Quaternion library ";["fields"]={};["name"]="quaternion";["client"]=true;["libtbl"]="quat_lib";["server"]=true;};["bass"]={["functions"]={[1]="loadFile";[2]="loadURL";["loadFile"]={["class"]="function";["description"]="\
Loads a sound channel from a file.";["fname"]="loadFile";["realm"]="cl";["name"]="bass_library.loadFile";["summary"]="\
Loads a sound channel from a file.";["private"]=false;["library"]="bass";["param"]={[1]="path";[2]="flags";[3]="callback";["flags"]="Flags for the sound (`3d`, `mono`, `noplay`, `noblock`).";["path"]="File path to play from.";["callback"]="Function which is called when the sound channel is loaded. It'll get 3 arguments: `Bass` object, error number and name.";};};["loadURL"]={["class"]="function";["description"]="\
Loads a sound channel from an URL.";["fname"]="loadURL";["realm"]="cl";["name"]="bass_library.loadURL";["summary"]="\
Loads a sound channel from an URL.";["private"]=false;["library"]="bass";["param"]={[1]="path";[2]="flags";[3]="callback";["flags"]="Flags for the sound (`3d`, `mono`, `noplay`, `noblock`).";["path"]="URL path to play from.";["callback"]="Function which is called when the sound channel is loaded. It'll get 3 arguments: `Bass` object, error number and name.";};};};["tables"]={};["class"]="library";["description"]="\
`bass` library is intended to be used only on client side. It's good for streaming local and remote sound files and playing them directly in player's \"2D\" context.";["summary"]="\
`bass` library is intended to be used only on client side.";["fields"]={};["name"]="bass";["client"]=true;["libtbl"]="bass_library";};["json"]={["tables"]={};["functions"]={[1]="decode";[2]="encode";["encode"]={["ret"]="JSON encoded string representation of the table";["class"]="function";["description"]="\
Convert table to JSON string";["fname"]="encode";["realm"]="sh";["name"]="json_library.encode";["summary"]="\
Convert table to JSON string ";["private"]=false;["library"]="json";["param"]={[1]="tbl";["tbl"]="Table to encode";};};["decode"]={["ret"]="Table representing the JSON object";["class"]="function";["description"]="\
Convert JSON string to table";["fname"]="decode";["realm"]="sh";["name"]="json_library.decode";["summary"]="\
Convert JSON string to table ";["private"]=false;["library"]="json";["param"]={[1]="s";["s"]="String to decode";};};};["description"]="\
JSON library";["class"]="library";["summary"]="\
JSON library ";["fields"]={};["name"]="json";["client"]=true;["libtbl"]="json_library";["server"]=true;};["prop"]={["tables"]={};["functions"]={[1]="canSpawn";[2]="create";[3]="createComponent";[4]="createSent";[5]="propsLeft";[6]="setPropClean";[7]="setPropUndo";[8]="spawnRate";["spawnRate"]={["ret"]="Number of props per second the user can spawn";["description"]="\
Returns how many props per second the user can spawn";["class"]="function";["realm"]="sv";["fname"]="spawnRate";["summary"]="\
Returns how many props per second the user can spawn ";["name"]="props_library.spawnRate";["library"]="prop";["private"]=false;["server"]=true;["param"]={};};["create"]={["ret"]="The prop object";["description"]="\
Creates a prop.";["class"]="function";["realm"]="sv";["fname"]="create";["summary"]="\
Creates a prop.";["name"]="props_library.create";["library"]="prop";["private"]=false;["server"]=true;["param"]={[1]="pos";[2]="ang";[3]="model";[4]="frozen";};};["canSpawn"]={["ret"]="True if user can spawn props, False if not.";["description"]="\
Checks if a user can spawn anymore props.";["class"]="function";["realm"]="sv";["fname"]="canSpawn";["summary"]="\
Checks if a user can spawn anymore props.";["name"]="props_library.canSpawn";["library"]="prop";["private"]=false;["server"]=true;["param"]={};};["setPropUndo"]={["class"]="function";["description"]="\
Sets whether the props should be undo-able";["fname"]="setPropUndo";["realm"]="sv";["name"]="props_library.setPropUndo";["summary"]="\
Sets whether the props should be undo-able ";["private"]=false;["library"]="prop";["param"]={[1]="on";["on"]="Boolean whether the props should be undo-able";};};["createSent"]={["ret"]="The sent object";["description"]="\
Creates a sent.";["class"]="function";["realm"]="sv";["fname"]="createSent";["summary"]="\
Creates a sent.";["name"]="props_library.createSent";["library"]="prop";["private"]=false;["server"]=true;["param"]={[1]="pos";[2]="ang";[3]="class";[4]="frozen";["frozen"]="True to spawn frozen";["ang"]="Angle of created sent";["class"]="Class of created sent";["pos"]="Position of created sent";};};["createComponent"]={["ret"]="Component entity";["description"]="\
Creates starfall component.\\n Allowed components:\\n starfall_hud\\n starfall_screen";["class"]="function";["realm"]="sv";["fname"]="createComponent";["summary"]="\
Creates starfall component.\\n Allowed components:\\n starfall_hud\\n starfall_screen ";["name"]="props_library.createComponent";["library"]="prop";["private"]=false;["server"]=true;["param"]={[1]="pos";[2]="ang";[3]="class";[4]="model";[5]="frozen";["frozen"]="True to spawn frozen";["model"]="Model of created component";["ang"]="Angle of created component";["class"]="Class of created component";["pos"]="Position of created component";};};["setPropClean"]={["class"]="function";["description"]="\
Sets whether the chip should remove created props when the chip is removed";["fname"]="setPropClean";["realm"]="sv";["name"]="props_library.setPropClean";["summary"]="\
Sets whether the chip should remove created props when the chip is removed ";["private"]=false;["library"]="prop";["param"]={[1]="on";["on"]="Boolean whether the props should be cleaned or not";};};["propsLeft"]={["ret"]="number of props able to be spawned";["description"]="\
Checks how many props can be spawned";["class"]="function";["realm"]="sv";["fname"]="propsLeft";["summary"]="\
Checks how many props can be spawned ";["name"]="props_library.propsLeft";["library"]="prop";["private"]=false;["server"]=true;["param"]={};};};["description"]="\
Library for creating and manipulating physics-less models AKA \"Props\".";["class"]="library";["summary"]="\
Library for creating and manipulating physics-less models AKA \"Props\".";["fields"]={};["name"]="prop";["client"]=true;["libtbl"]="props_library";["server"]=true;};["sounds"]={["tables"]={};["functions"]={[1]="canCreate";[2]="create";["canCreate"]={["ret"]="If it is possible to make a sound";["class"]="function";["description"]="\
Returns if a sound is able to be created";["fname"]="canCreate";["realm"]="sh";["name"]="sound_library.canCreate";["summary"]="\
Returns if a sound is able to be created ";["private"]=false;["library"]="sounds";["param"]={};};["create"]={["ret"]="Sound Object";["class"]="function";["description"]="\
Creates a sound and attaches it to an entity";["fname"]="create";["realm"]="sh";["name"]="sound_library.create";["summary"]="\
Creates a sound and attaches it to an entity ";["private"]=false;["library"]="sounds";["param"]={[1]="ent";[2]="path";["path"]="Filepath to the sound file.";["ent"]="Entity to attach sound to.";};};};["description"]="\
Sounds library.";["class"]="library";["summary"]="\
Sounds library.";["fields"]={};["name"]="sounds";["client"]=true;["libtbl"]="sound_library";["server"]=true;};["wire"]={["functions"]={[1]="adjustInputs";[2]="adjustOutputs";[3]="create";[4]="delete";[5]="getInputs";[6]="getOutputs";[7]="getWirelink";[8]="self";[9]="serverUUID";["self"]={["class"]="function";["description"]="\
Returns the wirelink representing this entity.";["fname"]="self";["realm"]="sv";["name"]="wire_library.self";["summary"]="\
Returns the wirelink representing this entity.";["private"]=false;["library"]="wire";["param"]={};};["serverUUID"]={["ret"]="UUID as string";["class"]="function";["description"]="\
Returns the server's UUID.";["fname"]="serverUUID";["realm"]="sv";["name"]="wire_library.serverUUID";["summary"]="\
Returns the server's UUID.";["private"]=false;["library"]="wire";["param"]={};};["getOutputs"]={["ret"]="Table of entity's outputs";["class"]="function";["description"]="\
Returns a table of entity's outputs";["fname"]="getOutputs";["realm"]="sv";["name"]="wire_library.getOutputs";["summary"]="\
Returns a table of entity's outputs ";["private"]=false;["library"]="wire";["param"]={[1]="entO";["entO"]="Entity with output(s)";};};["create"]={["class"]="function";["description"]="\
Wires two entities together";["fname"]="create";["realm"]="sv";["name"]="wire_library.create";["summary"]="\
Wires two entities together ";["private"]=false;["library"]="wire";["param"]={[1]="entI";[2]="entO";[3]="inputname";[4]="outputname";["entI"]="Entity with input";["inputname"]="Input to be wired";["outputname"]="Output to be wired";["entO"]="Entity with output";};};["getWirelink"]={["ret"]="Wirelink of the entity";["class"]="function";["description"]="\
Returns a wirelink to a wire entity";["fname"]="getWirelink";["realm"]="sv";["name"]="wire_library.getWirelink";["summary"]="\
Returns a wirelink to a wire entity ";["private"]=false;["library"]="wire";["param"]={[1]="ent";["ent"]="Wire entity";};};["adjustOutputs"]={["class"]="function";["description"]="\
Creates/Modifies wire outputs. All wire ports must begin with an uppercase \
letter and contain only alphabetical characters.";["fname"]="adjustOutputs";["realm"]="sv";["name"]="wire_library.adjustOutputs";["summary"]="\
Creates/Modifies wire outputs.";["private"]=false;["library"]="wire";["param"]={[1]="names";[2]="types";["types"]="An array of output types. Can be shortcuts. May be modified by the function.";["names"]="An array of output names. May be modified by the function.";};};["getInputs"]={["ret"]="Table of entity's inputs";["class"]="function";["description"]="\
Returns a table of entity's inputs";["fname"]="getInputs";["realm"]="sv";["name"]="wire_library.getInputs";["summary"]="\
Returns a table of entity's inputs ";["private"]=false;["library"]="wire";["param"]={[1]="entI";["entI"]="Entity with input(s)";};};["delete"]={["class"]="function";["description"]="\
Unwires an entity's input";["fname"]="delete";["realm"]="sv";["name"]="wire_library.delete";["summary"]="\
Unwires an entity's input ";["private"]=false;["library"]="wire";["param"]={[1]="entI";[2]="inputname";["entI"]="Entity with input";["inputname"]="Input to be un-wired";};};["adjustInputs"]={["class"]="function";["description"]="\
Creates/Modifies wire inputs. All wire ports must begin with an uppercase \
letter and contain only alphabetical characters.";["fname"]="adjustInputs";["realm"]="sv";["name"]="wire_library.adjustInputs";["summary"]="\
Creates/Modifies wire inputs.";["private"]=false;["library"]="wire";["param"]={[1]="names";[2]="types";["types"]="An array of input types. Can be shortcuts. May be modified by the function.";["names"]="An array of input names. May be modified by the function.";};};};["class"]="library";["tables"]={[1]="ports";["ports"]={["description"]="\
Ports table. Reads from this table will read from the wire input \
of the same name. Writes will write to the wire output of the same name.";["class"]="table";["classForced"]=true;["summary"]="\
Ports table.";["name"]="wire_library.ports";["library"]="wire";["param"]={};};};["description"]="\
Wire library. Handles wire inputs/outputs, wirelinks, etc.";["fields"]={};["name"]="wire";["summary"]="\
Wire library.";["libtbl"]="wire_library";};["team"]={["tables"]={};["functions"]={[1]="bestAutoJoinTeam";[2]="exists";[3]="getAllTeams";[4]="getColor";[5]="getJoinable";[6]="getName";[7]="getNumDeaths";[8]="getNumFrags";[9]="getNumPlayers";[10]="getPlayers";[11]="getScore";["bestAutoJoinTeam"]={["ret"]="index of the best team to join";["description"]="\
Returns team with least players";["class"]="function";["fname"]="bestAutoJoinTeam";["classForced"]=true;["realm"]="sh";["name"]="team_library.bestAutoJoinTeam";["summary"]="\
Returns team with least players ";["library"]="team";["param"]={};};["getPlayers"]={["ret"]="Table of players";["class"]="function";["description"]="\
Returns the table of players on a team";["fname"]="getPlayers";["realm"]="sh";["name"]="team_library.getPlayers";["summary"]="\
Returns the table of players on a team ";["private"]=false;["library"]="team";["param"]={[1]="ind";["ind"]="Index of the team";};};["getScore"]={["ret"]="Number score of the team";["description"]="\
Returns the score of a team";["class"]="function";["fname"]="getScore";["classForced"]=true;["realm"]="sh";["name"]="team_library.getScore";["summary"]="\
Returns the score of a team ";["library"]="team";["param"]={[1]="ind";["ind"]="Index of the team";};};["getNumDeaths"]={["ret"]="number of deaths";["description"]="\
Returns number of deaths of all players on a team";["class"]="function";["fname"]="getNumDeaths";["classForced"]=true;["realm"]="sh";["name"]="team_library.getNumDeaths";["summary"]="\
Returns number of deaths of all players on a team ";["library"]="team";["param"]={[1]="ind";["ind"]="Index of the team";};};["getAllTeams"]={["ret"]="table containing team information";["class"]="function";["description"]="\
Returns a table containing team information";["fname"]="getAllTeams";["realm"]="sh";["name"]="team_library.getAllTeams";["summary"]="\
Returns a table containing team information ";["private"]=false;["library"]="team";["param"]={};};["getJoinable"]={["ret"]="boolean";["description"]="\
Returns whether or not a team can be joined";["class"]="function";["fname"]="getJoinable";["classForced"]=true;["realm"]="sh";["name"]="team_library.getJoinable";["summary"]="\
Returns whether or not a team can be joined ";["library"]="team";["param"]={[1]="ind";["ind"]="Index of the team";};};["exists"]={["ret"]="boolean";["description"]="\
Returns whether or not the team exists";["class"]="function";["fname"]="exists";["classForced"]=true;["realm"]="sh";["name"]="team_library.exists";["summary"]="\
Returns whether or not the team exists ";["library"]="team";["param"]={[1]="ind";["ind"]="Index of the team";};};["getColor"]={["ret"]="Color of the team";["class"]="function";["description"]="\
Returns the color of a team";["fname"]="getColor";["realm"]="sh";["name"]="team_library.getColor";["summary"]="\
Returns the color of a team ";["private"]=false;["library"]="team";["param"]={[1]="ind";["ind"]="Index of the team";};};["getNumFrags"]={["ret"]="number of frags";["description"]="\
Returns number of frags of all players on a team";["class"]="function";["fname"]="getNumFrags";["classForced"]=true;["realm"]="sh";["name"]="team_library.getNumFrags";["summary"]="\
Returns number of frags of all players on a team ";["library"]="team";["param"]={[1]="ind";["ind"]="Index of the team";};};["getNumPlayers"]={["ret"]="number of players";["description"]="\
Returns number of players on a team";["class"]="function";["fname"]="getNumPlayers";["classForced"]=true;["realm"]="sh";["name"]="team_library.getNumPlayers";["summary"]="\
Returns number of players on a team ";["library"]="team";["param"]={[1]="ind";["ind"]="Index of the team";};};["getName"]={["ret"]="String name of the team";["description"]="\
Returns the name of a team";["class"]="function";["fname"]="getName";["classForced"]=true;["realm"]="sh";["name"]="team_library.getName";["summary"]="\
Returns the name of a team ";["library"]="team";["param"]={[1]="ind";["ind"]="Index of the team";};};};["description"]="\
Library for retreiving information about teams";["class"]="library";["summary"]="\
Library for retreiving information about teams ";["fields"]={};["name"]="team";["client"]=true;["libtbl"]="team_library";["server"]=true;};["trace"]={["tables"]={};["description"]="\
Provides functions for doing line/AABB traces";["functions"]={[1]="trace";[2]="traceHull";["trace"]={["ret"]="Result of the trace https://wiki.garrysmod.com/page/Structures/TraceResult";["class"]="function";["description"]="\
Does a line trace";["fname"]="trace";["realm"]="sh";["name"]="trace_library.trace";["summary"]="\
Does a line trace ";["private"]=false;["library"]="trace";["param"]={[1]="start";[2]="endpos";[3]="filter";[4]="mask";[5]="colgroup";[6]="ignworld";["colgroup"]="The collision group of the trace";["ignworld"]="Whether the trace should ignore world";["filter"]="Entity/array of entities to filter, or a function callback with an entity arguement that returns whether the trace should hit";["start"]="Start position";["mask"]="Trace mask";["endpos"]="End position";};};["traceHull"]={["ret"]="Result of the trace https://wiki.garrysmod.com/page/Structures/TraceResult";["class"]="function";["description"]="\
Does a swept-AABB trace";["fname"]="traceHull";["realm"]="sh";["name"]="trace_library.traceHull";["summary"]="\
Does a swept-AABB trace ";["private"]=false;["library"]="trace";["param"]={[1]="start";[2]="endpos";[3]="minbox";[4]="maxbox";[5]="filter";[6]="mask";[7]="colgroup";[8]="ignworld";["colgroup"]="The collision group of the trace";["mask"]="Trace mask";["endpos"]="End position";["filter"]="Entity/array of entities to filter, or a function callback with an entity arguement that returns whether the trace should hit";["ignworld"]="Whether the trace should ignore world";["maxbox"]="Upper box corner";["start"]="Start position";["minbox"]="Lower box corner";};};};["class"]="library";["summary"]="\
Provides functions for doing line/AABB traces ";["field"]={[1]="MAT_ANTLION";[2]="MAT_BLOODYFLESH";[3]="MAT_CONCRETE";[4]="MAT_DIRT";[5]="MAT_FLESH";[6]="MAT_GRATE";[7]="MAT_ALIENFLESH";[8]="MAT_CLIP";[9]="MAT_PLASTIC";[10]="MAT_METAL";[11]="MAT_SAND";[12]="MAT_FOLIAGE";[13]="MAT_COMPUTER";[14]="MAT_SLOSH";[15]="MAT_TILE";[16]="MAT_GRASS";[17]="MAT_VENT";[18]="MAT_WOOD";[19]="MAT_DEFAULT";[20]="MAT_GLASS";[21]="HITGROUP_GENERIC";[22]="HITGROUP_HEAD";[23]="HITGROUP_CHEST";[24]="HITGROUP_STOMACH";[25]="HITGROUP_LEFTARM";[26]="HITGROUP_RIGHTARM";[27]="HITGROUP_LEFTLEG";[28]="HITGROUP_RIGHTLEG";[29]="HITGROUP_GEAR";[30]="MASK_SPLITAREAPORTAL";[31]="MASK_SOLID_BRUSHONLY";[32]="MASK_WATER";[33]="MASK_BLOCKLOS";[34]="MASK_OPAQUE";[35]="MASK_VISIBLE";[36]="MASK_DEADSOLID";[37]="MASK_PLAYERSOLID_BRUSHONLY";[38]="MASK_NPCWORLDSTATIC";[39]="MASK_NPCSOLID_BRUSHONLY";[40]="MASK_CURRENT";[41]="MASK_SHOT_PORTAL";[42]="MASK_SOLID";[43]="MASK_BLOCKLOS_AND_NPCS";[44]="MASK_OPAQUE_AND_NPCS";[45]="MASK_VISIBLE_AND_NPCS";[46]="MASK_PLAYERSOLID";[47]="MASK_NPCSOLID";[48]="MASK_SHOT_HULL";[49]="MASK_SHOT";[50]="MASK_ALL";[51]="CONTENTS_EMPTY";[52]="CONTENTS_SOLID";[53]="CONTENTS_WINDOW";[54]="CONTENTS_AUX";[55]="CONTENTS_GRATE";[56]="CONTENTS_SLIME";[57]="CONTENTS_WATER";[58]="CONTENTS_BLOCKLOS";[59]="CONTENTS_OPAQUE";[60]="CONTENTS_TESTFOGVOLUME";[61]="CONTENTS_TEAM4";[62]="CONTENTS_TEAM3";[63]="CONTENTS_TEAM1";[64]="CONTENTS_TEAM2";[65]="CONTENTS_IGNORE_NODRAW_OPAQUE";[66]="CONTENTS_MOVEABLE";[67]="CONTENTS_AREAPORTAL";[68]="CONTENTS_PLAYERCLIP";[69]="CONTENTS_MONSTERCLIP";[70]="CONTENTS_CURRENT_0";[71]="CONTENTS_CURRENT_90";[72]="CONTENTS_CURRENT_180";[73]="CONTENTS_CURRENT_270";[74]="CONTENTS_CURRENT_UP";[75]="CONTENTS_CURRENT_DOWN";[76]="CONTENTS_ORIGIN";[77]="CONTENTS_MONSTER";[78]="CONTENTS_DEBRIS";[79]="CONTENTS_DETAIL";[80]="CONTENTS_TRANSLUCENT";[81]="CONTENTS_LADDER";[82]="CONTENTS_HITBOX";["MASK_DEADSOLID"]="";["MASK_BLOCKLOS"]="";["CONTENTS_EMPTY"]="";["MASK_OPAQUE"]="";["MASK_PLAYERSOLID"]="";["MASK_VISIBLE"]="";["HITGROUP_LEFTLEG"]="";["MASK_PLAYERSOLID_BRUSHONLY"]="";["HITGROUP_RIGHTARM"]="";["CONTENTS_CURRENT_DOWN"]="";["CONTENTS_OPAQUE"]="";["MAT_TILE"]="";["MAT_FOLIAGE"]="";["HITGROUP_HEAD"]="";["MASK_SHOT"]="";["MAT_COMPUTER"]="";["CONTENTS_TEAM3"]="";["MASK_SPLITAREAPORTAL"]="";["CONTENTS_CURRENT_UP"]="";["MAT_CONCRETE"]="";["MAT_CLIP"]="";["MAT_WOOD"]="";["MAT_ANTLION"]="";["MASK_NPCSOLID_BRUSHONLY"]="";["MAT_DEFAULT"]="";["CONTENTS_DEBRIS"]="";["MASK_SHOT_PORTAL"]="";["HITGROUP_LEFTARM"]="";["MAT_SLOSH"]="";["CONTENTS_PLAYERCLIP"]="";["MASK_NPCWORLDSTATIC"]="";["MASK_OPAQUE_AND_NPCS"]="";["MAT_BLOODYFLESH"]="";["MASK_BLOCKLOS_AND_NPCS"]="";["MASK_WATER"]="";["HITGROUP_CHEST"]="";["CONTENTS_AREAPORTAL"]="";["CONTENTS_WINDOW"]="";["MAT_METAL"]="";["HITGROUP_GEAR"]="";["MAT_VENT"]="";["MAT_PLASTIC"]="";["CONTENTS_CURRENT_180"]="";["MAT_ALIENFLESH"]="";["MAT_FLESH"]="";["CONTENTS_HITBOX"]="";["MAT_GLASS"]="";["CONTENTS_LADDER"]="";["CONTENTS_CURRENT_270"]="";["CONTENTS_DETAIL"]="";["CONTENTS_ORIGIN"]="";["CONTENTS_TEAM2"]="";["CONTENTS_MONSTER"]="";["CONTENTS_GRATE"]="";["MASK_NPCSOLID"]="";["CONTENTS_MOVEABLE"]="";["CONTENTS_TRANSLUCENT"]="";["MASK_VISIBLE_AND_NPCS"]="";["CONTENTS_IGNORE_NODRAW_OPAQUE"]="";["CONTENTS_SOLID"]="";["CONTENTS_MONSTERCLIP"]="";["MAT_SAND"]="";["CONTENTS_SLIME"]="";["CONTENTS_CURRENT_0"]="";["CONTENTS_TEAM1"]="";["MASK_ALL"]="";["CONTENTS_BLOCKLOS"]="";["CONTENTS_WATER"]="";["CONTENTS_TEAM4"]="";["MASK_SOLID_BRUSHONLY"]="";["HITGROUP_RIGHTLEG"]="";["CONTENTS_CURRENT_90"]="";["CONTENTS_AUX"]="";["HITGROUP_GENERIC"]="";["MASK_CURRENT"]="";["CONTENTS_TESTFOGVOLUME"]="";["MAT_GRASS"]="";["MAT_DIRT"]="";["MASK_SOLID"]="";["MASK_SHOT_HULL"]="";["HITGROUP_STOMACH"]="";["MAT_GRATE"]="";};["fields"]={};["name"]="trace";["client"]=true;["libtbl"]="trace_library";["server"]=true;};["mesh"]={["functions"]={[1]="createFromObj";[2]="createFromTable";[3]="trianglesLeft";["trianglesLeft"]={["ret"]="Number of triangles that can be created";["class"]="function";["description"]="\
Returns how many triangles can be created";["fname"]="trianglesLeft";["realm"]="cl";["name"]="mesh_library.trianglesLeft";["summary"]="\
Returns how many triangles can be created ";["private"]=false;["library"]="mesh";["param"]={};};["createFromObj"]={["ret"]="Mesh object";["class"]="function";["description"]="\
Creates a mesh from an obj file. Only supports triangular meshes with normals and texture coordinates.";["fname"]="createFromObj";["realm"]="cl";["name"]="mesh_library.createFromObj";["summary"]="\
Creates a mesh from an obj file.";["private"]=false;["library"]="mesh";["param"]={[1]="obj";["obj"]="The obj file data";};};["createFromTable"]={["ret"]="Mesh object";["class"]="function";["description"]="\
Creates a mesh from vertex data.";["fname"]="createFromTable";["realm"]="cl";["name"]="mesh_library.createFromTable";["summary"]="\
Creates a mesh from vertex data.";["private"]=false;["library"]="mesh";["param"]={[1]="verteces";["verteces"]="Table containing vertex data. http://wiki.garrysmod.com/page/Structures/MeshVertex";};};};["tables"]={};["class"]="library";["description"]="\
Mesh library.";["summary"]="\
Mesh library.";["fields"]={};["name"]="mesh";["client"]=true;["libtbl"]="mesh_library";};["holograms"]={["functions"]={[1]="canSpawn";[2]="create";[3]="hologramsLeft";["canSpawn"]={["ret"]="True if user can spawn holograms, False if not.";["description"]="\
Checks if a user can spawn anymore holograms.";["class"]="function";["realm"]="sv";["fname"]="canSpawn";["summary"]="\
Checks if a user can spawn anymore holograms.";["name"]="holograms_library.canSpawn";["library"]="holograms";["private"]=false;["server"]=true;["param"]={};};["create"]={["ret"]="The hologram object";["description"]="\
Creates a hologram.";["class"]="function";["realm"]="sv";["fname"]="create";["summary"]="\
Creates a hologram.";["name"]="holograms_library.create";["library"]="holograms";["private"]=false;["server"]=true;["param"]={[1]="pos";[2]="ang";[3]="model";[4]="scale";};};["hologramsLeft"]={["ret"]="number of holograms able to be spawned";["description"]="\
Checks how many holograms can be spawned";["class"]="function";["realm"]="sv";["fname"]="hologramsLeft";["summary"]="\
Checks how many holograms can be spawned ";["name"]="holograms_library.hologramsLeft";["library"]="holograms";["private"]=false;["server"]=true;["param"]={};};};["tables"]={};["class"]="library";["description"]="\
Library for creating and manipulating physics-less models AKA \"Holograms\".";["summary"]="\
Library for creating and manipulating physics-less models AKA \"Holograms\".";["fields"]={};["name"]="holograms";["libtbl"]="holograms_library";["server"]=true;};["joystick"]={["functions"]={[1]="getAxis";[2]="getButton";[3]="getName";[4]="getPov";[5]="numAxes";[6]="numButtons";[7]="numJoysticks";[8]="numPovs";["numJoysticks"]={["ret"]="Number of joysticks";["class"]="function";["description"]="\
Gets the number of detected joysticks.";["fname"]="numJoysticks";["realm"]="cl";["name"]="joystick_library.numJoysticks";["summary"]="\
Gets the number of detected joysticks.";["private"]=false;["library"]="joystick";["param"]={};};["getAxis"]={["ret"]="0 - 65535 where 32767 is the middle.";["class"]="function";["description"]="\
Gets the axis data value.";["fname"]="getAxis";["realm"]="cl";["name"]="joystick_library.getAxis";["summary"]="\
Gets the axis data value.";["private"]=false;["library"]="joystick";["param"]={[1]="enum";[2]="axis";["enum"]="Joystick number. Starts at 0";["axis"]="Joystick axis number. Ranges from 0 to 7.";};};["numAxes"]={["ret"]="Number of axes";["class"]="function";["description"]="\
Gets the number of detected axes on a joystick";["fname"]="numAxes";["realm"]="cl";["name"]="joystick_library.numAxes";["summary"]="\
Gets the number of detected axes on a joystick ";["private"]=false;["library"]="joystick";["param"]={[1]="enum";["enum"]="Joystick number. Starts at 0";};};["getName"]={["ret"]="Name of the device";["class"]="function";["description"]="\
Gets the hardware name of the joystick";["fname"]="getName";["realm"]="cl";["name"]="joystick_library.getName";["summary"]="\
Gets the hardware name of the joystick ";["private"]=false;["library"]="joystick";["param"]={[1]="enum";["enum"]="Joystick number. Starts at 0";};};["getButton"]={["ret"]="0 or 1";["class"]="function";["description"]="\
Returns if the button is pushed or not";["fname"]="getButton";["realm"]="cl";["name"]="joystick_library.getButton";["summary"]="\
Returns if the button is pushed or not ";["private"]=false;["library"]="joystick";["param"]={[1]="enum";[2]="button";["button"]="Joystick button number. Starts at 0";["enum"]="Joystick number. Starts at 0";};};["numPovs"]={["ret"]="Number of povs";["class"]="function";["description"]="\
Gets the number of detected povs on a joystick";["fname"]="numPovs";["realm"]="cl";["name"]="joystick_library.numPovs";["summary"]="\
Gets the number of detected povs on a joystick ";["private"]=false;["library"]="joystick";["param"]={[1]="enum";["enum"]="Joystick number. Starts at 0";};};["numButtons"]={["ret"]="Number of buttons";["class"]="function";["description"]="\
Gets the number of detected buttons on a joystick";["fname"]="numButtons";["realm"]="cl";["name"]="joystick_library.numButtons";["summary"]="\
Gets the number of detected buttons on a joystick ";["private"]=false;["library"]="joystick";["param"]={[1]="enum";["enum"]="Joystick number. Starts at 0";};};["getPov"]={["ret"]="0 - 65535 where 32767 is the middle.";["class"]="function";["description"]="\
Gets the pov data value.";["fname"]="getPov";["realm"]="cl";["name"]="joystick_library.getPov";["summary"]="\
Gets the pov data value.";["private"]=false;["library"]="joystick";["param"]={[1]="enum";[2]="pov";["enum"]="Joystick number. Starts at 0";["pov"]="Joystick pov number. Ranges from 0 to 7.";};};};["tables"]={};["class"]="library";["description"]="\
Joystick library.";["summary"]="\
Joystick library.";["fields"]={};["name"]="joystick";["client"]=true;["libtbl"]="joystick_library";};["fastlz"]={["tables"]={};["functions"]={[1]="compress";[2]="decompress";["decompress"]={["ret"]="Decompressed string";["class"]="function";["description"]="\
Decompress using FastLZ";["fname"]="decompress";["realm"]="sh";["name"]="fastlz_library.decompress";["summary"]="\
Decompress using FastLZ ";["private"]=false;["library"]="fastlz";["param"]={[1]="s";["s"]="FastLZ compressed string to decode";};};["compress"]={["ret"]="FastLZ compressed string";["class"]="function";["description"]="\
Compress string using FastLZ";["fname"]="compress";["realm"]="sh";["name"]="fastlz_library.compress";["summary"]="\
Compress string using FastLZ ";["private"]=false;["library"]="fastlz";["param"]={[1]="s";["s"]="String to compress";};};};["description"]="\
FastLZ library";["class"]="library";["summary"]="\
FastLZ library ";["fields"]={};["name"]="fastlz";["client"]=true;["libtbl"]="fastlz_library";["server"]=true;};["game"]={["tables"]={};["functions"]={[1]="getGamemode";[2]="getHostname";[3]="getMap";[4]="getMaxPlayers";[5]="isDedicated";[6]="isLan";[7]="isSinglePlayer";["isDedicated"]={["class"]="function";["description"]="\
Returns whether or not the server is a dedicated server";["fname"]="isDedicated";["realm"]="sh";["name"]="game_lib.isDedicated";["summary"]="\
Returns whether or not the server is a dedicated server ";["private"]=false;["library"]="game";["param"]={};};["getGamemode"]={["class"]="function";["description"]="\
Returns the gamemode as a String";["fname"]="getGamemode";["realm"]="sh";["name"]="game_lib.getGamemode";["summary"]="\
Returns the gamemode as a String ";["private"]=false;["library"]="game";["param"]={};};["isLan"]={["deprecated"]="Possibly add ConVar retrieval for users in future. Could implement with SF Script.";["class"]="function";["description"]="\
Returns true if the server is on a LAN";["fname"]="isLan";["realm"]="sh";["name"]="game_lib.isLan";["summary"]="\
Returns true if the server is on a LAN ";["private"]=false;["library"]="game";["param"]={};};["getMap"]={["class"]="function";["description"]="\
Returns the map name";["fname"]="getMap";["realm"]="sh";["name"]="game_lib.getMap";["summary"]="\
Returns the map name ";["private"]=false;["library"]="game";["param"]={};};["getMaxPlayers"]={["class"]="function";["description"]="\
Returns the maximum player limit";["fname"]="getMaxPlayers";["realm"]="sh";["name"]="game_lib.getMaxPlayers";["summary"]="\
Returns the maximum player limit ";["private"]=false;["library"]="game";["param"]={};};["isSinglePlayer"]={["class"]="function";["description"]="\
Returns whether or not the current game is single player";["fname"]="isSinglePlayer";["realm"]="sh";["name"]="game_lib.isSinglePlayer";["summary"]="\
Returns whether or not the current game is single player ";["private"]=false;["library"]="game";["param"]={};};["getHostname"]={["class"]="function";["description"]="\
Returns The hostname";["fname"]="getHostname";["realm"]="sh";["name"]="game_lib.getHostname";["summary"]="\
Returns The hostname ";["private"]=false;["library"]="game";["param"]={};};};["description"]="\
Game functions";["class"]="library";["summary"]="\
Game functions ";["fields"]={};["name"]="game";["client"]=true;["libtbl"]="game_lib";["server"]=true;};["von"]={["tables"]={};["functions"]={[1]="deserialize";[2]="serialize";["serialize"]={["ret"]="String";["server"]=true;["description"]="\
Serialize a table";["class"]="function";["realm"]="sh";["summary"]="\
Serialize a table ";["classForced"]=true;["fname"]="serialize";["name"]="von.serialize";["library"]="von";["client"]=true;["param"]={[1]="tbl";["tbl"]="Table to serialize";};};["deserialize"]={["ret"]="Table";["server"]=true;["description"]="\
Deserialize a string";["class"]="function";["realm"]="sh";["summary"]="\
Deserialize a string ";["classForced"]=true;["fname"]="deserialize";["name"]="von.deserialize";["library"]="von";["client"]=true;["param"]={[1]="str";["str"]="String to deserialize";};};};["description"]="\
vON Library";["class"]="library";["summary"]="\
vON Library ";["fields"]={};["name"]="von";["client"]=true;["libtbl"]="von";["server"]=true;};["net"]={["functions"]={[1]="getBytesLeft";[2]="isStreaming";[3]="readAngle";[4]="readBit";[5]="readColor";[6]="readData";[7]="readDouble";[8]="readEntity";[9]="readFloat";[10]="readInt";[11]="readMatrix";[12]="readStream";[13]="readString";[14]="readUInt";[15]="readVector";[16]="receive";[17]="send";[18]="start";[19]="writeAngle";[20]="writeBit";[21]="writeColor";[22]="writeData";[23]="writeDouble";[24]="writeEntity";[25]="writeFloat";[26]="writeInt";[27]="writeMatrix";[28]="writeStream";[29]="writeString";[30]="writeUInt";[31]="writeVector";["receive"]={["description"]="\
Like glua net.Receive, adds a callback that is called when a net message with the matching name is received. If this happens, the net hook won't be called.";["class"]="function";["realm"]="sh";["summary"]="\
Like glua net.Receive, adds a callback that is called when a net message with the matching name is received.";["fname"]="receive";["library"]="net";["name"]="net_library.receive";["server"]=true;["private"]=false;["client"]=true;["param"]={[1]="name";[2]="func";["func"]="The callback or nil to remove callback. (len - length of the net message, ply - player that sent it or nil if clientside)";["name"]="The name of the net message";};};["writeVector"]={["description"]="\
Writes an vector to the net message";["class"]="function";["realm"]="sh";["summary"]="\
Writes an vector to the net message ";["fname"]="writeVector";["library"]="net";["name"]="net_library.writeVector";["server"]=true;["private"]=false;["client"]=true;["param"]={[1]="t";["t"]="The vector to be written";};};["readColor"]={["ret"]="The color that was read";["description"]="\
Reads a color from the net message";["class"]="function";["realm"]="sh";["summary"]="\
Reads a color from the net message ";["fname"]="readColor";["library"]="net";["name"]="net_library.readColor";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["readDouble"]={["ret"]="The double that was read";["description"]="\
Reads a double from the net message";["class"]="function";["realm"]="sh";["summary"]="\
Reads a double from the net message ";["fname"]="readDouble";["library"]="net";["name"]="net_library.readDouble";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["readEntity"]={["ret"]="The entity that was read";["description"]="\
Reads a entity from the net message";["class"]="function";["realm"]="sh";["summary"]="\
Reads a entity from the net message ";["fname"]="readEntity";["library"]="net";["name"]="net_library.readEntity";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["writeAngle"]={["description"]="\
Writes an angle to the net message";["class"]="function";["realm"]="sh";["summary"]="\
Writes an angle to the net message ";["fname"]="writeAngle";["library"]="net";["name"]="net_library.writeAngle";["server"]=true;["private"]=false;["client"]=true;["param"]={[1]="t";["t"]="The angle to be written";};};["writeStream"]={["description"]="\
Streams a large 20MB string.";["class"]="function";["realm"]="sh";["summary"]="\
Streams a large 20MB string.";["fname"]="writeStream";["library"]="net";["name"]="net_library.writeStream";["server"]=true;["private"]=false;["client"]=true;["param"]={[1]="str";["str"]="The string to be written";};};["readFloat"]={["ret"]="The float that was read";["description"]="\
Reads a float from the net message";["class"]="function";["realm"]="sh";["summary"]="\
Reads a float from the net message ";["fname"]="readFloat";["library"]="net";["name"]="net_library.readFloat";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["writeBit"]={["description"]="\
Writes a bit to the net message";["class"]="function";["realm"]="sh";["summary"]="\
Writes a bit to the net message ";["fname"]="writeBit";["library"]="net";["name"]="net_library.writeBit";["server"]=true;["private"]=false;["client"]=true;["param"]={[1]="t";["t"]="The bit to be written. (boolean)";};};["writeColor"]={["description"]="\
Writes an color to the net message";["class"]="function";["realm"]="sh";["summary"]="\
Writes an color to the net message ";["fname"]="writeColor";["library"]="net";["name"]="net_library.writeColor";["server"]=true;["private"]=false;["client"]=true;["param"]={[1]="t";["t"]="The color to be written";};};["send"]={["description"]="\
Send a net message from client->server, or server->client.";["class"]="function";["realm"]="sh";["summary"]="\
Send a net message from client->server, or server->client.";["fname"]="send";["library"]="net";["name"]="net_library.send";["server"]=true;["private"]=false;["client"]=true;["param"]={[1]="target";[2]="unreliable";["target"]="Optional target location to send the net message.";["unreliable"]="Optional choose whether it's more important for the message to actually reach its destination (false) or reach it as fast as possible (true).";};};["readUInt"]={["ret"]="The unsigned integer that was read";["description"]="\
Reads an unsigned integer from the net message";["class"]="function";["realm"]="sh";["summary"]="\
Reads an unsigned integer from the net message ";["fname"]="readUInt";["library"]="net";["name"]="net_library.readUInt";["server"]=true;["private"]=false;["client"]=true;["param"]={[1]="n";["n"]="The amount of bits to read";};};["readBit"]={["ret"]="The bit that was read. (0 for false, 1 for true)";["description"]="\
Reads a bit from the net message";["class"]="function";["realm"]="sh";["summary"]="\
Reads a bit from the net message ";["fname"]="readBit";["library"]="net";["name"]="net_library.readBit";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["writeEntity"]={["description"]="\
Writes an entity to the net message";["class"]="function";["realm"]="sh";["summary"]="\
Writes an entity to the net message ";["fname"]="writeEntity";["library"]="net";["name"]="net_library.writeEntity";["server"]=true;["private"]=false;["client"]=true;["param"]={[1]="t";["t"]="The entity to be written";};};["writeMatrix"]={["description"]="\
Writes an matrix to the net message";["class"]="function";["realm"]="sh";["summary"]="\
Writes an matrix to the net message ";["fname"]="writeMatrix";["library"]="net";["name"]="net_library.writeMatrix";["server"]=true;["private"]=false;["client"]=true;["param"]={[1]="t";["t"]="The matrix to be written";};};["readAngle"]={["ret"]="The angle that was read";["description"]="\
Reads an angle from the net message";["class"]="function";["realm"]="sh";["summary"]="\
Reads an angle from the net message ";["fname"]="readAngle";["library"]="net";["name"]="net_library.readAngle";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["readString"]={["ret"]="The string that was read";["description"]="\
Reads a string from the net message";["class"]="function";["realm"]="sh";["summary"]="\
Reads a string from the net message ";["fname"]="readString";["library"]="net";["name"]="net_library.readString";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["isStreaming"]={["ret"]="Boolean";["class"]="function";["description"]="\
Returns whether or not the library is currently reading data from a stream";["fname"]="isStreaming";["realm"]="sh";["name"]="net_library.isStreaming";["summary"]="\
Returns whether or not the library is currently reading data from a stream ";["private"]=false;["library"]="net";["param"]={};};["readInt"]={["ret"]="The integer that was read";["description"]="\
Reads an integer from the net message";["class"]="function";["realm"]="sh";["summary"]="\
Reads an integer from the net message ";["fname"]="readInt";["library"]="net";["name"]="net_library.readInt";["server"]=true;["private"]=false;["client"]=true;["param"]={[1]="n";["n"]="The amount of bits to read";};};["getBytesLeft"]={["ret"]="number of bytes that can be sent";["class"]="function";["description"]="\
Returns available bandwidth in bytes";["fname"]="getBytesLeft";["realm"]="sh";["name"]="net_library.getBytesLeft";["summary"]="\
Returns available bandwidth in bytes ";["private"]=false;["library"]="net";["param"]={};};["readVector"]={["ret"]="The vector that was read";["description"]="\
Reads a vector from the net message";["class"]="function";["realm"]="sh";["summary"]="\
Reads a vector from the net message ";["fname"]="readVector";["library"]="net";["name"]="net_library.readVector";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["writeInt"]={["description"]="\
Writes an integer to the net message";["class"]="function";["realm"]="sh";["summary"]="\
Writes an integer to the net message ";["fname"]="writeInt";["library"]="net";["name"]="net_library.writeInt";["server"]=true;["private"]=false;["client"]=true;["param"]={[1]="t";[2]="n";["t"]="The integer to be written";["n"]="The amount of bits the integer consists of";};};["writeString"]={["description"]="\
Writes a string to the net message. Null characters will terminate the string.";["class"]="function";["realm"]="sh";["summary"]="\
Writes a string to the net message.";["fname"]="writeString";["library"]="net";["name"]="net_library.writeString";["server"]=true;["private"]=false;["client"]=true;["param"]={[1]="t";["t"]="The string to be written";};};["readStream"]={["description"]="\
Reads a large string stream from the net message";["class"]="function";["realm"]="sh";["summary"]="\
Reads a large string stream from the net message ";["fname"]="readStream";["library"]="net";["name"]="net_library.readStream";["server"]=true;["private"]=false;["client"]=true;["param"]={[1]="cb";["cb"]="Callback to run when the stream is finished. The first parameter in the callback is the data.";};};["writeUInt"]={["description"]="\
Writes an unsigned integer to the net message";["class"]="function";["realm"]="sh";["summary"]="\
Writes an unsigned integer to the net message ";["fname"]="writeUInt";["library"]="net";["name"]="net_library.writeUInt";["server"]=true;["private"]=false;["client"]=true;["param"]={[1]="t";[2]="n";["t"]="The integer to be written";["n"]="The amount of bits the integer consists of. Should not be greater than 32";};};["writeFloat"]={["description"]="\
Writes a float to the net message";["class"]="function";["realm"]="sh";["summary"]="\
Writes a float to the net message ";["fname"]="writeFloat";["library"]="net";["name"]="net_library.writeFloat";["server"]=true;["private"]=false;["client"]=true;["param"]={[1]="t";["t"]="The float to be written";};};["writeDouble"]={["description"]="\
Writes a double to the net message";["class"]="function";["realm"]="sh";["summary"]="\
Writes a double to the net message ";["fname"]="writeDouble";["library"]="net";["name"]="net_library.writeDouble";["server"]=true;["private"]=false;["client"]=true;["param"]={[1]="t";["t"]="The double to be written";};};["start"]={["description"]="\
Starts the net message";["class"]="function";["realm"]="sh";["summary"]="\
Starts the net message ";["fname"]="start";["library"]="net";["name"]="net_library.start";["server"]=true;["private"]=false;["client"]=true;["param"]={[1]="name";["name"]="The message name";};};["writeData"]={["description"]="\
Writes string containing null characters to the net message";["class"]="function";["realm"]="sh";["summary"]="\
Writes string containing null characters to the net message ";["fname"]="writeData";["library"]="net";["name"]="net_library.writeData";["server"]=true;["private"]=false;["client"]=true;["param"]={[1]="t";[2]="n";["t"]="The string to be written";["n"]="How much of the string to write";};};["readData"]={["ret"]="The string that was read";["description"]="\
Reads a string from the net message";["class"]="function";["realm"]="sh";["summary"]="\
Reads a string from the net message ";["fname"]="readData";["library"]="net";["name"]="net_library.readData";["server"]=true;["private"]=false;["client"]=true;["param"]={[1]="n";["n"]="How many characters are in the data";};};["readMatrix"]={["ret"]="The matrix that was read";["description"]="\
Reads a matrix from the net message";["class"]="function";["realm"]="sh";["summary"]="\
Reads a matrix from the net message ";["fname"]="readMatrix";["library"]="net";["name"]="net_library.readMatrix";["server"]=true;["private"]=false;["client"]=true;["param"]={};};};["class"]="library";["tables"]={};["description"]="\
Net message library. Used for sending data from the server to the client and back";["fields"]={};["name"]="net";["summary"]="\
Net message library.";["libtbl"]="net_library";};["timer"]={["tables"]={};["functions"]={[1]="adjust";[2]="create";[3]="curtime";[4]="exists";[5]="frametime";[6]="getTimersLeft";[7]="pause";[8]="realtime";[9]="remove";[10]="repsleft";[11]="simple";[12]="start";[13]="stop";[14]="systime";[15]="timeleft";[16]="toggle";[17]="unpause";["getTimersLeft"]={["ret"]="Number of available timers";["class"]="function";["description"]="\
Returns number of available timers";["fname"]="getTimersLeft";["realm"]="sh";["name"]="timer_library.getTimersLeft";["summary"]="\
Returns number of available timers ";["private"]=false;["library"]="timer";["param"]={};};["frametime"]={["class"]="function";["description"]="\
Returns time between frames on client and ticks on server. Same thing as G.FrameTime in GLua";["fname"]="frametime";["realm"]="sh";["name"]="timer_library.frametime";["summary"]="\
Returns time between frames on client and ticks on server.";["private"]=false;["library"]="timer";["param"]={};};["systime"]={["class"]="function";["description"]="\
Returns a highly accurate time in seconds since the start up, ideal for benchmarking.";["fname"]="systime";["realm"]="sh";["name"]="timer_library.systime";["summary"]="\
Returns a highly accurate time in seconds since the start up, ideal for benchmarking.";["private"]=false;["library"]="timer";["param"]={};};["adjust"]={["ret"]="true if succeeded";["class"]="function";["description"]="\
Adjusts a timer";["fname"]="adjust";["realm"]="sh";["name"]="timer_library.adjust";["summary"]="\
Adjusts a timer ";["private"]=false;["library"]="timer";["param"]={[1]="name";[2]="delay";[3]="reps";[4]="func";["name"]="The timer name";["func"]="The function to call when the tiemr is fired";["delay"]="The time, in seconds, to set the timer to.";["reps"]="The repititions of the tiemr. 0 = infinte, nil = 1";};};["remove"]={["class"]="function";["description"]="\
Stops and removes the timer.";["fname"]="remove";["realm"]="sh";["name"]="timer_library.remove";["summary"]="\
Stops and removes the timer.";["private"]=false;["library"]="timer";["param"]={[1]="name";["name"]="The timer name";};};["unpause"]={["ret"]="false if the timer didn't exist or was already running, true otherwise.";["class"]="function";["description"]="\
Unpauses a timer";["fname"]="unpause";["realm"]="sh";["name"]="timer_library.unpause";["summary"]="\
Unpauses a timer ";["private"]=false;["library"]="timer";["param"]={[1]="name";["name"]="The timer name";};};["toggle"]={["ret"]="status of the timer.";["class"]="function";["description"]="\
Runs either timer.pause or timer.unpause based on the timer's current status.";["fname"]="toggle";["realm"]="sh";["name"]="timer_library.toggle";["summary"]="\
Runs either timer.pause or timer.unpause based on the timer's current status.";["private"]=false;["library"]="timer";["param"]={[1]="name";["name"]="The timer name";};};["simple"]={["class"]="function";["description"]="\
Creates a simple timer, has no name, can't be stopped, paused, or destroyed.";["fname"]="simple";["realm"]="sh";["name"]="timer_library.simple";["summary"]="\
Creates a simple timer, has no name, can't be stopped, paused, or destroyed.";["private"]=false;["library"]="timer";["param"]={[1]="delay";[2]="func";["func"]="the function to call when the timer is fired";["delay"]="the time, in second, to set the timer to";};};["create"]={["class"]="function";["description"]="\
Creates (and starts) a timer";["fname"]="create";["realm"]="sh";["name"]="timer_library.create";["summary"]="\
Creates (and starts) a timer ";["private"]=false;["library"]="timer";["param"]={[1]="name";[2]="delay";[3]="reps";[4]="func";[5]="simple";["name"]="The timer name";["func"]="The function to call when the timer is fired";["delay"]="The time, in seconds, to set the timer to.";["reps"]="The repititions of the tiemr. 0 = infinte, nil = 1";};};["timeleft"]={["ret"]="The amount of time left (in seconds). If the timer is paused, the amount will be negative. Nil if timer doesnt exist";["class"]="function";["description"]="\
Returns amount of time left (in seconds) before the timer executes its function.";["fname"]="timeleft";["realm"]="sh";["name"]="timer_library.timeleft";["summary"]="\
Returns amount of time left (in seconds) before the timer executes its function.";["private"]=false;["library"]="timer";["param"]={[1]="name";[2]="The";["The"]="timer name";};};["repsleft"]={["ret"]="The amount of executions left. Nil if timer doesnt exist";["class"]="function";["description"]="\
Returns amount of repetitions/executions left before the timer destroys itself.";["fname"]="repsleft";["realm"]="sh";["name"]="timer_library.repsleft";["summary"]="\
Returns amount of repetitions/executions left before the timer destroys itself.";["private"]=false;["library"]="timer";["param"]={[1]="name";[2]="The";["The"]="timer name";};};["exists"]={["ret"]="bool if the timer exists";["class"]="function";["description"]="\
Checks if a timer exists";["fname"]="exists";["realm"]="sh";["name"]="timer_library.exists";["summary"]="\
Checks if a timer exists ";["private"]=false;["library"]="timer";["param"]={[1]="name";["name"]="The timer name";};};["stop"]={["ret"]="false if the timer didn't exist or was already stopped, true otherwise.";["class"]="function";["description"]="\
Stops a timer";["fname"]="stop";["realm"]="sh";["name"]="timer_library.stop";["summary"]="\
Stops a timer ";["private"]=false;["library"]="timer";["param"]={[1]="name";["name"]="The timer name";};};["realtime"]={["class"]="function";["description"]="\
Returns the uptime of the game/server in seconds (to at least 4 decimal places)";["fname"]="realtime";["realm"]="sh";["name"]="timer_library.realtime";["summary"]="\
Returns the uptime of the game/server in seconds (to at least 4 decimal places) ";["private"]=false;["library"]="timer";["param"]={};};["curtime"]={["class"]="function";["description"]="\
Returns the uptime of the server in seconds (to at least 4 decimal places)";["fname"]="curtime";["realm"]="sh";["name"]="timer_library.curtime";["summary"]="\
Returns the uptime of the server in seconds (to at least 4 decimal places) ";["private"]=false;["library"]="timer";["param"]={};};["pause"]={["ret"]="false if the timer didn't exist or was already paused, true otherwise.";["class"]="function";["description"]="\
Pauses a timer";["fname"]="pause";["realm"]="sh";["name"]="timer_library.pause";["summary"]="\
Pauses a timer ";["private"]=false;["library"]="timer";["param"]={[1]="name";["name"]="The timer name";};};["start"]={["ret"]="true if the timer exists, false if it doesn't.";["class"]="function";["description"]="\
Starts a timer";["fname"]="start";["realm"]="sh";["name"]="timer_library.start";["summary"]="\
Starts a timer ";["private"]=false;["library"]="timer";["param"]={[1]="name";["name"]="The timer name";};};};["description"]="\
Deals with time and timers.";["class"]="library";["summary"]="\
Deals with time and timers.";["fields"]={};["name"]="timer";["client"]=true;["libtbl"]="timer_library";["server"]=true;};["builtin"]={["libtbl"]="SF.DefaultEnvironment";["description"]="\
Built in values. These don't need to be loaded; they are in the default environment.";["class"]="library";["summary"]="\
Built in values.";["tables"]={[1]="bit";[2]="math";[3]="os";[4]="string";[5]="table";["string"]={["description"]="\
String library http://wiki.garrysmod.com/page/Category:string";["class"]="table";["classForced"]=true;["summary"]="\
String library http://wiki.garrysmod.com/page/Category:string ";["name"]="SF.DefaultEnvironment.string";["library"]="builtin";["param"]={};};["os"]={["description"]="\
The os library. http://wiki.garrysmod.com/page/Category:os";["class"]="table";["classForced"]=true;["summary"]="\
The os library.";["name"]="SF.DefaultEnvironment.os";["library"]="builtin";["param"]={};};["table"]={["description"]="\
Table library. http://wiki.garrysmod.com/page/Category:table";["class"]="table";["classForced"]=true;["summary"]="\
Table library.";["name"]="SF.DefaultEnvironment.table";["library"]="builtin";["param"]={};};["math"]={["description"]="\
The math library. http://wiki.garrysmod.com/page/Category:math";["class"]="table";["classForced"]=true;["summary"]="\
The math library.";["name"]="SF.DefaultEnvironment.math";["library"]="builtin";["param"]={};};["bit"]={["description"]="\
Bit library. http://wiki.garrysmod.com/page/Category:bit";["class"]="table";["classForced"]=true;["summary"]="\
Bit library.";["name"]="SF.DefaultEnvironment.bit";["library"]="builtin";["param"]={};};};["classForced"]=true;["fields"]={[1]="CLIENT";[2]="SERVER";["CLIENT"]={["description"]="\
Constant that denotes whether the code is executed on the client";["class"]="field";["classForced"]=true;["summary"]="\
Constant that denotes whether the code is executed on the client ";["name"]="SF.DefaultEnvironment.CLIENT";["library"]="builtin";["param"]={};};["SERVER"]={["description"]="\
Constant that denotes whether the code is executed on the server";["class"]="field";["classForced"]=true;["summary"]="\
Constant that denotes whether the code is executed on the server ";["name"]="SF.DefaultEnvironment.SERVER";["library"]="builtin";["param"]={};};};["name"]="builtin";["functions"]={[1]="assert";[2]="chip";[3]="concmd";[4]="crc";[5]="debugGetInfo";[6]="dodir";[7]="dofile";[8]="entity";[9]="error";[10]="eyeAngles";[11]="eyePos";[12]="eyeVector";[13]="getLibraries";[14]="getUserdata";[15]="getfenv";[16]="getmetatable";[17]="hasPermission";[18]="ipairs";[19]="isValid";[20]="loadstring";[21]="localToWorld";[22]="next";[23]="owner";[24]="pairs";[25]="pcall";[26]="permissionRequestSatisfied";[27]="player";[28]="printMessage";[29]="printTable";[30]="quotaAverage";[31]="quotaMax";[32]="quotaTotalAverage";[33]="quotaTotalUsed";[34]="quotaUsed";[35]="rawget";[36]="rawset";[37]="require";[38]="requiredir";[39]="select";[40]="setClipboardText";[41]="setName";[42]="setSoftQuota";[43]="setUserdata";[44]="setfenv";[45]="setmetatable";[46]="setupPermissionRequest";[47]="throw";[48]="tonumber";[49]="tostring";[50]="try";[51]="type";[52]="unpack";[53]="worldToLocal";[54]="xpcall";["xpcall"]={["ret"]={[1]="Status of the execution; true for success, false for failure.";[2]="The returns of the first function if execution succeeded, otherwise the first return value of the error callback.";};["class"]="function";["description"]="\
Lua's xpcall with SF throw implementation \
Attempts to call the first function. If the execution succeeds, this returns true followed by the returns of the function. \
If execution fails, this returns false and the second function is called with the error message.";["fname"]="xpcall";["realm"]="sh";["name"]="SF.DefaultEnvironment.xpcall";["summary"]="\
Lua's xpcall with SF throw implementation \
Attempts to call the first function.";["private"]=false;["library"]="builtin";["param"]={[1]="func";[2]="callback";[3]="...";[4]="funcThe";[5]="The";[6]="arguments";["The"]="function to be called if execution of the first fails; the error message is passed as a string.";["arguments"]="Arguments to pass to the initial function.";["funcThe"]="function to call initially.";};};["chip"]={["ret"]="Starfall entity";["description"]="\
Returns the entity representing a processor that this script is running on.";["class"]="function";["fname"]="chip";["classForced"]=true;["realm"]="sh";["name"]="SF.DefaultEnvironment.chip";["summary"]="\
Returns the entity representing a processor that this script is running on.";["library"]="builtin";["param"]={};};["hasPermission"]={["class"]="function";["description"]="\
Checks if the chip is capable of performing an action.";["fname"]="hasPermission";["realm"]="sh";["name"]="SF.DefaultEnvironment.hasPermission";["summary"]="\
Checks if the chip is capable of performing an action.";["private"]=false;["library"]="builtin";["param"]={[1]="perm";[2]="obj";["perm"]="The permission id to check";["obj"]="Optional object to pass to the permission system.";};};["tostring"]={["ret"]="obj as string";["description"]="\
Attempts to convert the value to a string.";["class"]="function";["fname"]="tostring";["classForced"]=true;["realm"]="sh";["name"]="SF.DefaultEnvironment.tostring";["summary"]="\
Attempts to convert the value to a string.";["library"]="builtin";["param"]={[1]="obj";["obj"]="";};};["localToWorld"]={["ret"]={[1]="worldPos";[2]="worldAngles";};["class"]="function";["description"]="\
Translates the specified position and angle from the specified local coordinate system";["fname"]="localToWorld";["realm"]="sh";["name"]="SF.DefaultEnvironment.localToWorld";["summary"]="\
Translates the specified position and angle from the specified local coordinate system ";["private"]=false;["library"]="builtin";["param"]={[1]="localPos";[2]="localAng";[3]="originPos";[4]="originAngle";["originAngle"]="The angles of the source coordinate system, as a world angle";["originPos"]="The origin point of the source coordinate system, in world coordinates";["localPos"]="The position vector that should be translated to world coordinates";["localAng"]="The angle that should be converted to a world angle";};};["setClipboardText"]={["class"]="function";["description"]="\
Sets clipboard text. Only works on the owner of the chip.";["fname"]="setClipboardText";["realm"]="sh";["name"]="SF.DefaultEnvironment.setClipboardText";["summary"]="\
Sets clipboard text.";["private"]=false;["library"]="builtin";["param"]={[1]="txt";["txt"]="Text to set to the clipboard";};};["unpack"]={["ret"]="Elements of tbl";["description"]="\
This function takes a numeric indexed table and return all the members as a vararg.";["class"]="function";["fname"]="unpack";["classForced"]=true;["realm"]="sh";["name"]="SF.DefaultEnvironment.unpack";["summary"]="\
This function takes a numeric indexed table and return all the members as a vararg.";["library"]="builtin";["param"]={[1]="tbl";["tbl"]="";};};["printMessage"]={["class"]="function";["description"]="\
Prints a message to your chat, console, or the center of your screen.";["fname"]="printMessage";["realm"]="sh";["name"]="SF.DefaultEnvironment.printMessage";["summary"]="\
Prints a message to your chat, console, or the center of your screen.";["private"]=false;["library"]="builtin";["param"]={[1]="mtype";[2]="text";["text"]="The message text.";["mtype"]="How the message should be displayed. See http://wiki.garrysmod.com/page/Enums/HUD";};};["quotaUsed"]={["ret"]="Current quota used this Think";["class"]="function";["description"]="\
Returns the current count for this Think's CPU Time. \
This value increases as more executions are done, may not be exactly as you want. \
If used on screens, will show 0 if only rendering is done. Operations must be done in the Think loop for them to be counted.";["fname"]="quotaUsed";["realm"]="sh";["name"]="SF.DefaultEnvironment.quotaUsed";["summary"]="\
Returns the current count for this Think's CPU Time.";["private"]=false;["library"]="builtin";["param"]={};};["isValid"]={["ret"]="If it is valid";["class"]="function";["description"]="\
Returns if the table has an isValid function and isValid returns true.";["fname"]="isValid";["realm"]="sh";["name"]="SF.DefaultEnvironment.isValid";["summary"]="\
Returns if the table has an isValid function and isValid returns true.";["private"]=false;["library"]="builtin";["param"]={[1]="object";["object"]="Table to check";};};["pairs"]={["ret"]={[1]="Iterator function";[2]="Table tbl";[3]="nil as current index";};["description"]="\
Returns an iterator function for a for loop that will return the values of the specified table in an arbitrary order.";["class"]="function";["fname"]="pairs";["classForced"]=true;["realm"]="sh";["name"]="SF.DefaultEnvironment.pairs";["summary"]="\
Returns an iterator function for a for loop that will return the values of the specified table in an arbitrary order.";["library"]="builtin";["param"]={[1]="tbl";["tbl"]="Table to iterate over";};};["next"]={["ret"]={[1]="Key or nil";[2]="Value or nil";};["description"]="\
Returns the next key and value pair in a table.";["class"]="function";["fname"]="next";["classForced"]=true;["realm"]="sh";["name"]="SF.DefaultEnvironment.next";["summary"]="\
Returns the next key and value pair in a table.";["library"]="builtin";["param"]={[1]="tbl";[2]="k";["tbl"]="Table to get the next key-value pair of";["k"]="Previous key (can be nil)";};};["assert"]={["description"]="\
If the result of the first argument is false or nil, an error is thrown with the second argument as the message.";["class"]="function";["realm"]="sh";["classForced"]=true;["summary"]="\
If the result of the first argument is false or nil, an error is thrown with the second argument as the message.";["name"]="SF.DefaultEnvironment.assert";["fname"]="assert";["private"]=false;["library"]="builtin";["param"]={[1]="condition";[2]="msg";["msg"]="";["condition"]="";};};["eyePos"]={["ret"]="The local player's camera position";["class"]="function";["description"]="\
Returns the local player's camera position";["fname"]="eyePos";["realm"]="sh";["name"]="SF.DefaultEnvironment.eyePos";["summary"]="\
Returns the local player's camera position ";["private"]=false;["library"]="builtin";["param"]={};};["ipairs"]={["ret"]={[1]="Iterator function";[2]="Table tbl";[3]="0 as current index";};["description"]="\
Returns an iterator function for a for loop, to return ordered key-value pairs from a table.";["class"]="function";["fname"]="ipairs";["classForced"]=true;["realm"]="sh";["name"]="SF.DefaultEnvironment.ipairs";["summary"]="\
Returns an iterator function for a for loop, to return ordered key-value pairs from a table.";["library"]="builtin";["param"]={[1]="tbl";["tbl"]="Table to iterate over";};};["getUserdata"]={["ret"]="String data";["description"]="\
Gets the chip's userdata that the duplicator tool loads";["class"]="function";["realm"]="sv";["fname"]="getUserdata";["summary"]="\
Gets the chip's userdata that the duplicator tool loads ";["name"]="SF.DefaultEnvironment.getUserdata";["library"]="builtin";["private"]=false;["server"]=true;["param"]={};};["player"]={["ret"]="Returns player with given UserID or if none specified then returns either the owner (server) or the local player (client)";["description"]="\
Same as owner() on the server. On the client, returns the local player";["class"]="function";["fname"]="player";["classForced"]=true;["realm"]="sh";["name"]="SF.DefaultEnvironment.player";["summary"]="\
Same as owner() on the server.";["library"]="builtin";["param"]={};};["quotaTotalAverage"]={["ret"]="Total average CPU Time of all your chips.";["class"]="function";["description"]="\
Returns the total average time for all chips by the player.";["fname"]="quotaTotalAverage";["realm"]="sh";["name"]="SF.DefaultEnvironment.quotaTotalAverage";["summary"]="\
Returns the total average time for all chips by the player.";["private"]=false;["library"]="builtin";["param"]={};};["throw"]={["class"]="function";["description"]="\
Throws an exception";["fname"]="throw";["realm"]="sh";["name"]="SF.DefaultEnvironment.throw";["summary"]="\
Throws an exception ";["private"]=false;["library"]="builtin";["param"]={[1]="msg";[2]="level";[3]="uncatchable";["level"]="Which level in the stacktrace to blame. Defaults to 1";["uncatchable"]="Makes this exception uncatchable";["msg"]="Message string";};};["setmetatable"]={["ret"]="tbl with metatable set to meta";["description"]="\
Sets, changes or removes a table's metatable. Doesn't work on most internal metatables";["class"]="function";["fname"]="setmetatable";["classForced"]=true;["realm"]="sh";["name"]="SF.DefaultEnvironment.setmetatable";["summary"]="\
Sets, changes or removes a table's metatable.";["library"]="builtin";["param"]={[1]="tbl";[2]="meta";["tbl"]="The table to set the metatable of";["meta"]="The metatable to use";};};["quotaMax"]={["ret"]="Max SysTime allowed to take for execution of the chip in a Think.";["class"]="function";["description"]="\
Gets the CPU Time max. \
CPU Time is stored in a buffer of N elements, if the average of this exceeds quotaMax, the chip will error.";["fname"]="quotaMax";["realm"]="sh";["name"]="SF.DefaultEnvironment.quotaMax";["summary"]="\
Gets the CPU Time max.";["private"]=false;["library"]="builtin";["param"]={};};["getmetatable"]={["ret"]="The metatable of tbl";["class"]="function";["description"]="\
Returns the metatable of an object. Doesn't work on most internal metatables";["fname"]="getmetatable";["realm"]="sh";["name"]="SF.DefaultEnvironment.getmetatable";["summary"]="\
Returns the metatable of an object.";["private"]=false;["library"]="builtin";["param"]={[1]="tbl";["tbl"]="Table to get metatable of";};};["concmd"]={["description"]="\
Execute a console command";["class"]="function";["realm"]="sh";["summary"]="\
Execute a console command ";["fname"]="concmd";["library"]="builtin";["name"]="SF.DefaultEnvironment.concmd";["server"]=true;["private"]=false;["client"]=true;["param"]={[1]="cmd";["cmd"]="Command to execute";};};["getLibraries"]={["ret"]="Table containing the names of each available library";["class"]="function";["description"]="\
Gets a list of all libraries";["fname"]="getLibraries";["realm"]="sh";["name"]="SF.DefaultEnvironment.getLibraries";["summary"]="\
Gets a list of all libraries ";["private"]=false;["library"]="builtin";["param"]={};};["debugGetInfo"]={["ret"]="DebugInfo table";["class"]="function";["description"]="\
GLua's getinfo() \
Returns a DebugInfo structure containing the passed function's info (https://wiki.garrysmod.com/page/Structures/DebugInfo)";["fname"]="debugGetInfo";["realm"]="sh";["name"]="SF.DefaultEnvironment.debugGetInfo";["summary"]="\
GLua's getinfo() \
Returns a DebugInfo structure containing the passed function's info (https://wiki.garrysmod.com/page/Structures/DebugInfo) ";["private"]=false;["library"]="builtin";["param"]={[1]="funcOrStackLevel";[2]="fields";["fields"]="A string that specifies the information to be retrieved. Defaults to all (flnSu).";["funcOrStackLevel"]="Function or stack level to get info about. Defaults to stack level 0.";};};["crc"]={["ret"]="The unsigned 32 bit checksum as a string";["description"]="\
Generates the CRC checksum of the specified string. (https://en.wikipedia.org/wiki/Cyclic_redundancy_check)";["class"]="function";["fname"]="crc";["classForced"]=true;["realm"]="sh";["name"]="SF.DefaultEnvironment.crc";["summary"]="\
Generates the CRC checksum of the specified string.";["library"]="builtin";["param"]={[1]="stringToHash";["stringToHash"]="The string to calculate the checksum of";};};["eyeVector"]={["ret"]="The local player's camera forward vector";["class"]="function";["description"]="\
Returns the local player's camera forward vector";["fname"]="eyeVector";["realm"]="sh";["name"]="SF.DefaultEnvironment.eyeVector";["summary"]="\
Returns the local player's camera forward vector ";["private"]=false;["library"]="builtin";["param"]={};};["rawset"]={["class"]="function";["description"]="\
Set the value of a table index without invoking a metamethod";["fname"]="rawset";["realm"]="sh";["name"]="SF.DefaultEnvironment.rawset";["summary"]="\
Set the value of a table index without invoking a metamethod ";["private"]=false;["library"]="builtin";["param"]={[1]="table";[2]="key";[3]="value";["value"]="The value to set the index equal to";["key"]="The index of the table";["table"]="The table to modify";};};["dodir"]={["ret"]="Table of return values of the scripts";["class"]="function";["description"]="\
Runs an included directory, but does not cache the result.";["fname"]="dodir";["realm"]="sh";["name"]="SF.DefaultEnvironment.dodir";["summary"]="\
Runs an included directory, but does not cache the result.";["private"]=false;["library"]="builtin";["param"]={[1]="dir";[2]="loadpriority";["loadpriority"]="Table of files that should be loaded before any others in the directory";["dir"]="The directory to include. Make sure to --@includedir it";};};["getfenv"]={["ret"]="Current environment";["class"]="function";["description"]="\
Simple version of Lua's getfenv \
Returns the current environment";["fname"]="getfenv";["realm"]="sh";["name"]="SF.DefaultEnvironment.getfenv";["summary"]="\
Simple version of Lua's getfenv \
Returns the current environment ";["private"]=false;["library"]="builtin";["param"]={};};["setfenv"]={["ret"]="func with environment set to tbl";["class"]="function";["description"]="\
Lua's setfenv \
Works like setfenv, but is restricted on functions";["fname"]="setfenv";["realm"]="sh";["name"]="SF.DefaultEnvironment.setfenv";["summary"]="\
Lua's setfenv \
Works like setfenv, but is restricted on functions ";["private"]=false;["library"]="builtin";["param"]={[1]="func";[2]="tbl";["tbl"]="New environment";["func"]="Function to change environment of";};};["printTable"]={["class"]="function";["description"]="\
Prints a table to player's chat";["fname"]="printTable";["realm"]="sh";["name"]="SF.DefaultEnvironment.printTable";["summary"]="\
Prints a table to player's chat ";["private"]=false;["library"]="builtin";["param"]={[1]="tbl";["tbl"]="Table to print";};};["tonumber"]={["ret"]="obj as number";["description"]="\
Attempts to convert the value to a number.";["class"]="function";["fname"]="tonumber";["classForced"]=true;["realm"]="sh";["name"]="SF.DefaultEnvironment.tonumber";["summary"]="\
Attempts to convert the value to a number.";["library"]="builtin";["param"]={[1]="obj";["obj"]="";};};["requiredir"]={["ret"]="Table of return values of the scripts";["class"]="function";["description"]="\
Runs an included script and caches the result. \
Works pretty much like standard Lua require()";["fname"]="requiredir";["realm"]="sh";["name"]="SF.DefaultEnvironment.requiredir";["summary"]="\
Runs an included script and caches the result.";["private"]=false;["library"]="builtin";["param"]={[1]="dir";[2]="loadpriority";["loadpriority"]="Table of files that should be loaded before any others in the directory";["dir"]="The directory to include. Make sure to --@includedir it";};};["entity"]={["ret"]="entity";["description"]="\
Returns the entity with index 'num'";["class"]="function";["fname"]="entity";["classForced"]=true;["realm"]="sh";["name"]="SF.DefaultEnvironment.entity";["summary"]="\
Returns the entity with index 'num' ";["library"]="builtin";["param"]={[1]="num";["num"]="Entity index";};};["require"]={["ret"]="Return value of the script";["class"]="function";["description"]="\
Runs an included script and caches the result. \
Works pretty much like standard Lua require()";["fname"]="require";["realm"]="sh";["name"]="SF.DefaultEnvironment.require";["summary"]="\
Runs an included script and caches the result.";["private"]=false;["library"]="builtin";["param"]={[1]="file";["file"]="The file to include. Make sure to --@include it";};};["pcall"]={["ret"]={[1]="If the function had no errors occur within it.";[2]="If an error occurred, this will be a string containing the error message. Otherwise, this will be the return values of the function passed in.";};["class"]="function";["description"]="\
Lua's pcall with SF throw implementation \
Calls a function and catches an error that can be thrown while the execution of the call.";["fname"]="pcall";["realm"]="sh";["name"]="SF.DefaultEnvironment.pcall";["summary"]="\
Lua's pcall with SF throw implementation \
Calls a function and catches an error that can be thrown while the execution of the call.";["private"]=false;["library"]="builtin";["param"]={[1]="func";[2]="...";[3]="arguments";["arguments"]="Arguments to call the function with.";["func"]="Function to be executed and of which the errors should be caught of";};};["eyeAngles"]={["ret"]="The local player's camera angles";["class"]="function";["description"]="\
Returns the local player's camera angles";["fname"]="eyeAngles";["realm"]="sh";["name"]="SF.DefaultEnvironment.eyeAngles";["summary"]="\
Returns the local player's camera angles ";["private"]=false;["library"]="builtin";["param"]={};};["permissionRequestSatisfied"]={["ret"]="Boolean of whether the client gave all permissions specified in last request or not.";["description"]="\
Is permission request fully satisfied.";["class"]="function";["realm"]="cl";["fname"]="permissionRequestSatisfied";["summary"]="\
Is permission request fully satisfied.";["name"]="SF.DefaultEnvironment.permissionRequestSatisfied";["library"]="builtin";["private"]=false;["client"]=true;["param"]={};};["type"]={["ret"]="The name of the object's type.";["description"]="\
Returns a string representing the name of the type of the passed object.";["class"]="function";["realm"]="sh";["classForced"]=true;["summary"]="\
Returns a string representing the name of the type of the passed object.";["name"]="SF.DefaultEnvironment.type";["fname"]="type";["private"]=false;["library"]="builtin";["param"]={[1]="obj";["obj"]="Object to get type of";};};["try"]={["class"]="function";["description"]="\
Try to execute a function and catch possible exceptions \
Similar to xpcall, but a bit more in-depth";["fname"]="try";["realm"]="sh";["name"]="SF.DefaultEnvironment.try";["summary"]="\
Try to execute a function and catch possible exceptions \
Similar to xpcall, but a bit more in-depth ";["private"]=false;["library"]="builtin";["param"]={[1]="func";[2]="catch";["catch"]="Optional function to execute in case func fails";["func"]="Function to execute";};};["setUserdata"]={["description"]="\
Sets the chip's userdata that the duplicator tool saves. max 1MiB";["class"]="function";["realm"]="sv";["fname"]="setUserdata";["summary"]="\
Sets the chip's userdata that the duplicator tool saves.";["name"]="SF.DefaultEnvironment.setUserdata";["library"]="builtin";["private"]=false;["server"]=true;["param"]={[1]="str";["str"]="String data";};};["select"]={["ret"]="Returns a number or vararg, depending on the select method.";["description"]="\
Used to select single values from a vararg or get the count of values in it.";["class"]="function";["fname"]="select";["classForced"]=true;["realm"]="sh";["name"]="SF.DefaultEnvironment.select";["summary"]="\
Used to select single values from a vararg or get the count of values in it.";["library"]="builtin";["param"]={[1]="parameter";[2]="vararg";["vararg"]="";["parameter"]="";};};["owner"]={["ret"]="Owner entity";["description"]="\
Returns whoever created the chip";["class"]="function";["fname"]="owner";["classForced"]=true;["realm"]="sh";["name"]="SF.DefaultEnvironment.owner";["summary"]="\
Returns whoever created the chip ";["library"]="builtin";["param"]={};};["setupPermissionRequest"]={["description"]="\
Setups request for overriding permissions.";["class"]="function";["realm"]="cl";["fname"]="setupPermissionRequest";["summary"]="\
Setups request for overriding permissions.";["name"]="SF.DefaultEnvironment.setupPermissionRequest";["library"]="builtin";["private"]=false;["client"]=true;["param"]={[1]="perms";[2]="desc";[3]="showOnUse";["perms"]="Table of overridable permissions' names.";["showOnUse"]="Whether request will popup when player uses chip or linked screen.";["desc"]="Description attached to request.";};};["quotaAverage"]={["ret"]="Average CPU Time of the buffer.";["class"]="function";["description"]="\
Gets the Average CPU Time in the buffer";["fname"]="quotaAverage";["realm"]="sh";["name"]="SF.DefaultEnvironment.quotaAverage";["summary"]="\
Gets the Average CPU Time in the buffer ";["private"]=false;["library"]="builtin";["param"]={};};["loadstring"]={["ret"]="Function of str";["class"]="function";["description"]="\
GLua's loadstring \
Works like loadstring, except that it executes by default in the main environment";["fname"]="loadstring";["realm"]="sh";["name"]="SF.DefaultEnvironment.loadstring";["summary"]="\
GLua's loadstring \
Works like loadstring, except that it executes by default in the main environment ";["private"]=false;["library"]="builtin";["param"]={[1]="str";[2]="name";["str"]="String to execute";};};["rawget"]={["ret"]="The value of the index";["class"]="function";["description"]="\
Gets the value of a table index without invoking a metamethod";["fname"]="rawget";["realm"]="sh";["name"]="SF.DefaultEnvironment.rawget";["summary"]="\
Gets the value of a table index without invoking a metamethod ";["private"]=false;["library"]="builtin";["param"]={[1]="table";[2]="key";[3]="value";["key"]="The index of the table";["table"]="The table to get the value from";};};["setName"]={["description"]="\
Sets the chip's display name";["class"]="function";["realm"]="cl";["fname"]="setName";["summary"]="\
Sets the chip's display name ";["name"]="SF.DefaultEnvironment.setName";["library"]="builtin";["private"]=false;["client"]=true;["param"]={[1]="name";["name"]="Name";};};["dofile"]={["ret"]="Return value of the script";["class"]="function";["description"]="\
Runs an included script, but does not cache the result. \
Pretty much like standard Lua dofile()";["fname"]="dofile";["realm"]="sh";["name"]="SF.DefaultEnvironment.dofile";["summary"]="\
Runs an included script, but does not cache the result.";["private"]=false;["library"]="builtin";["param"]={[1]="file";["file"]="The file to include. Make sure to --@include it";};};["quotaTotalUsed"]={["ret"]="Total used CPU time of all your chips.";["class"]="function";["description"]="\
Returns the total used time for all chips by the player.";["fname"]="quotaTotalUsed";["realm"]="sh";["name"]="SF.DefaultEnvironment.quotaTotalUsed";["summary"]="\
Returns the total used time for all chips by the player.";["private"]=false;["library"]="builtin";["param"]={};};["worldToLocal"]={["ret"]={[1]="localPos";[2]="localAngles";};["class"]="function";["description"]="\
Translates the specified position and angle into the specified coordinate system";["fname"]="worldToLocal";["realm"]="sh";["name"]="SF.DefaultEnvironment.worldToLocal";["summary"]="\
Translates the specified position and angle into the specified coordinate system ";["private"]=false;["library"]="builtin";["param"]={[1]="pos";[2]="ang";[3]="newSystemOrigin";[4]="newSystemAngles";["newSystemAngles"]="The angles of the system to translate to";["newSystemOrigin"]="The origin of the system to translate to";["ang"]="The angles that should be translated from the current to the new system";["pos"]="The position that should be translated from the current to the new system";};};["error"]={["class"]="function";["description"]="\
Throws a raw exception.";["fname"]="error";["realm"]="sh";["name"]="SF.DefaultEnvironment.error";["summary"]="\
Throws a raw exception.";["private"]=false;["library"]="builtin";["param"]={[1]="msg";[2]="level";["msg"]="Exception message";["level"]="Which level in the stacktrace to blame. Defaults to 1";};};["setSoftQuota"]={["class"]="function";["description"]="\
Sets a CPU soft quota which will trigger a catchable error if the cpu goes over a certain amount.";["fname"]="setSoftQuota";["realm"]="sh";["name"]="SF.DefaultEnvironment.setSoftQuota";["summary"]="\
Sets a CPU soft quota which will trigger a catchable error if the cpu goes over a certain amount.";["private"]=false;["library"]="builtin";["param"]={[1]="quota";["quota"]="The threshold where the soft error will be thrown. Ratio of current cpu to the max cpu usage. 0.5 is 50%";};};};["client"]=true;["server"]=true;};["physenv"]={["tables"]={};["functions"]={[1]="getAirDensity";[2]="getGravity";[3]="getPerformanceSettings";["getAirDensity"]={["ret"]="number Air Density";["class"]="function";["description"]="\
Gets the air density.";["fname"]="getAirDensity";["realm"]="sh";["name"]="physenv_lib.getAirDensity";["summary"]="\
Gets the air density.";["private"]=false;["library"]="physenv";["param"]={};};["getPerformanceSettings"]={["ret"]="table Performance Settings Table.";["class"]="function";["description"]="\
Gets the performance settings.</br> \
See <a href=\"http://wiki.garrysmod.com/page/Structures/PhysEnvPerformanceSettings\">PhysEnvPerformance Settings Table Structure</a> for table structure.";["fname"]="getPerformanceSettings";["realm"]="sh";["name"]="physenv_lib.getPerformanceSettings";["summary"]="\
Gets the performance settings.</br> \
See <a href=\"http://wiki.garrysmod.com/page/Structures/PhysEnvPerformanceSettings\">PhysEnvPerformance Settings Table Structure</a> for table structure.";["private"]=false;["library"]="physenv";["param"]={};};["getGravity"]={["ret"]="Vector Gravity Vector ( eg Vector(0,0,-600) )";["class"]="function";["description"]="\
Gets the gravity vector";["fname"]="getGravity";["realm"]="sh";["name"]="physenv_lib.getGravity";["summary"]="\
Gets the gravity vector ";["private"]=false;["library"]="physenv";["param"]={};};};["description"]="\
Physenv functions";["class"]="library";["summary"]="\
Physenv functions ";["fields"]={};["name"]="physenv";["client"]=true;["libtbl"]="physenv_lib";["server"]=true;};["hook"]={["tables"]={};["functions"]={[1]="add";[2]="remove";[3]="run";[4]="runRemote";["remove"]={["description"]="\
Remove a hook";["class"]="function";["realm"]="sh";["summary"]="\
Remove a hook ";["fname"]="remove";["library"]="hook";["name"]="hook_library.remove";["server"]=true;["private"]=false;["client"]=true;["param"]={[1]="hookname";[2]="name";["name"]="The unique name for this hook";["hookname"]="The hook name";};};["runRemote"]={["ret"]="tbl A list of the resultset of each called hook";["description"]="\
Run a hook remotely. \
This will call the hook \"remote\" on either a specified entity or all instances on the server/client";["class"]="function";["realm"]="sh";["summary"]="\
Run a hook remotely.";["fname"]="runRemote";["library"]="hook";["name"]="hook_library.runRemote";["server"]=true;["private"]=false;["client"]=true;["param"]={[1]="recipient";[2]="...";["recipient"]="Starfall entity to call the hook on. Nil to run on every starfall entity";["..."]="Payload. These parameters will be used to call the hook functions";};};["run"]={["description"]="\
Run a hook";["class"]="function";["realm"]="sh";["summary"]="\
Run a hook ";["fname"]="run";["library"]="hook";["name"]="hook_library.run";["server"]=true;["private"]=false;["client"]=true;["param"]={[1]="hookname";[2]="...";["..."]="arguments";["hookname"]="The hook name";};};["add"]={["class"]="function";["description"]="\
Sets a hook function";["fname"]="add";["realm"]="sh";["name"]="hook_library.add";["summary"]="\
Sets a hook function ";["private"]=false;["library"]="hook";["param"]={[1]="hookname";[2]="name";[3]="func";["func"]="Function to run";["name"]="Unique identifier";["hookname"]="Name of the event";};};};["description"]="\
Deals with hooks";["class"]="library";["summary"]="\
Deals with hooks ";["fields"]={};["name"]="hook";["client"]=true;["libtbl"]="hook_library";["server"]=true;};["find"]={["tables"]={};["functions"]={[1]="all";[2]="allPlayers";[3]="byClass";[4]="byModel";[5]="inBox";[6]="inCone";[7]="inSphere";["inBox"]={["ret"]="An array of found entities";["class"]="function";["description"]="\
Finds entities in a box";["fname"]="inBox";["realm"]="sh";["name"]="find_library.inBox";["summary"]="\
Finds entities in a box ";["private"]=false;["library"]="find";["param"]={[1]="min";[2]="max";[3]="filter";["min"]="Bottom corner";["max"]="Top corner";["filter"]="Optional function to filter results";};};["inSphere"]={["ret"]="An array of found entities";["class"]="function";["description"]="\
Finds entities in a sphere";["fname"]="inSphere";["realm"]="sh";["name"]="find_library.inSphere";["summary"]="\
Finds entities in a sphere ";["private"]=false;["library"]="find";["param"]={[1]="center";[2]="radius";[3]="filter";["radius"]="Sphere radius";["center"]="Center of the sphere";["filter"]="Optional function to filter results";};};["byClass"]={["ret"]="An array of found entities";["class"]="function";["description"]="\
Finds entities by class name";["fname"]="byClass";["realm"]="sh";["name"]="find_library.byClass";["summary"]="\
Finds entities by class name ";["private"]=false;["library"]="find";["param"]={[1]="class";[2]="filter";["class"]="The class name";["filter"]="Optional function to filter results";};};["allPlayers"]={["ret"]="An array of found entities";["class"]="function";["description"]="\
Finds all players (including bots)";["fname"]="allPlayers";["realm"]="sh";["name"]="find_library.allPlayers";["summary"]="\
Finds all players (including bots) ";["private"]=false;["library"]="find";["param"]={[1]="filter";["filter"]="Optional function to filter results";};};["all"]={["ret"]="An array of found entities";["class"]="function";["description"]="\
Finds all entitites";["fname"]="all";["realm"]="sh";["name"]="find_library.all";["summary"]="\
Finds all entitites ";["private"]=false;["library"]="find";["param"]={[1]="filter";["filter"]="Optional function to filter results";};};["byModel"]={["ret"]="An array of found entities";["class"]="function";["description"]="\
Finds entities by model";["fname"]="byModel";["realm"]="sh";["name"]="find_library.byModel";["summary"]="\
Finds entities by model ";["private"]=false;["library"]="find";["param"]={[1]="model";[2]="filter";["filter"]="Optional function to filter results";["model"]="The model file";};};["inCone"]={["ret"]="An array of found entities";["class"]="function";["description"]="\
Finds entities in a cone";["fname"]="inCone";["realm"]="sh";["name"]="find_library.inCone";["summary"]="\
Finds entities in a cone ";["private"]=false;["library"]="find";["param"]={[1]="pos";[2]="dir";[3]="distance";[4]="radius";[5]="filter";["filter"]="Optional function to filter results";["radius"]="The angle of the cone";["dir"]="The direction to project the cone";["distance"]="The length to project the cone";["pos"]="The cone vertex position";};};};["description"]="\
Find library. Finds entities in various shapes.";["class"]="library";["summary"]="\
Find library.";["fields"]={};["name"]="find";["client"]=true;["libtbl"]="find_library";["server"]=true;};["coroutine"]={["tables"]={};["functions"]={[1]="create";[2]="resume";[3]="running";[4]="status";[5]="wait";[6]="wrap";[7]="yield";["resume"]={["ret"]="Any values the coroutine is returning to the main thread";["class"]="function";["description"]="\
Resumes a suspended coroutine. Note that, in contrast to Lua's native coroutine.resume function, it will not run in protected mode and can throw an error.";["fname"]="resume";["realm"]="sh";["name"]="coroutine_library.resume";["summary"]="\
Resumes a suspended coroutine.";["private"]=false;["library"]="coroutine";["param"]={[1]="thread";[2]="...";["..."]="optional parameters that will be passed to the coroutine";["thread"]="coroutine to resume";};};["yield"]={["ret"]="Any values passed to the coroutine";["class"]="function";["description"]="\
Suspends the currently running coroutine. May not be called outside a coroutine.";["fname"]="yield";["realm"]="sh";["name"]="coroutine_library.yield";["summary"]="\
Suspends the currently running coroutine.";["private"]=false;["library"]="coroutine";["param"]={[1]="...";["..."]="optional parameters that will be returned to the main thread";};};["running"]={["ret"]="Currently running coroutine";["class"]="function";["description"]="\
Returns the coroutine that is currently running.";["fname"]="running";["realm"]="sh";["name"]="coroutine_library.running";["summary"]="\
Returns the coroutine that is currently running.";["private"]=false;["library"]="coroutine";["param"]={};};["status"]={["ret"]="Either \"suspended\", \"running\", \"normal\" or \"dead\"";["class"]="function";["description"]="\
Returns the status of the coroutine.";["fname"]="status";["realm"]="sh";["name"]="coroutine_library.status";["summary"]="\
Returns the status of the coroutine.";["private"]=false;["library"]="coroutine";["param"]={[1]="thread";["thread"]="The coroutine";};};["wrap"]={["ret"]="A function that, when called, resumes the created coroutine. Any parameters to that function will be passed to the coroutine.";["class"]="function";["description"]="\
Creates a new coroutine.";["fname"]="wrap";["realm"]="sh";["name"]="coroutine_library.wrap";["summary"]="\
Creates a new coroutine.";["private"]=false;["library"]="coroutine";["param"]={[1]="func";["func"]="Function of the coroutine";};};["create"]={["ret"]="coroutine";["class"]="function";["description"]="\
Creates a new coroutine.";["fname"]="create";["realm"]="sh";["name"]="coroutine_library.create";["summary"]="\
Creates a new coroutine.";["private"]=false;["library"]="coroutine";["param"]={[1]="func";["func"]="Function of the coroutine";};};["wait"]={["class"]="function";["description"]="\
Suspends the coroutine for a number of seconds. Note that the coroutine will not resume automatically, but any attempts to resume the coroutine while it is waiting will not resume the coroutine and act as if the coroutine suspended itself immediately.";["fname"]="wait";["realm"]="sh";["name"]="coroutine_library.wait";["summary"]="\
Suspends the coroutine for a number of seconds.";["private"]=false;["library"]="coroutine";["param"]={[1]="time";["time"]="Time in seconds to suspend the coroutine";};};};["description"]="\
Coroutine library";["class"]="library";["summary"]="\
Coroutine library ";["fields"]={};["name"]="coroutine";["client"]=true;["libtbl"]="coroutine_library";["server"]=true;};["particle"]={["functions"]={[1]="attach";["attach"]={["ret"]="Particle type.";["class"]="function";["description"]="\
Attaches a particle to an entity.";["fname"]="attach";["realm"]="cl";["name"]="particle_library.attach";["summary"]="\
Attaches a particle to an entity.";["private"]=false;["library"]="particle";["param"]={[1]="entity";[2]="particle";[3]="pattach";[4]="options";["options"]="Table of options";["entity"]="Entity to attach to";["pattach"]="PATTACH enum";["particle"]="Name of the particle";};};};["tables"]={};["class"]="library";["description"]="\
Particle library.";["summary"]="\
Particle library.";["fields"]={};["name"]="particle";["client"]=true;["libtbl"]="particle_library";};["input"]={["functions"]={[1]="enableCursor";[2]="getCursorPos";[3]="getKeyName";[4]="isControlDown";[5]="isKeyDown";[6]="isShiftDown";[7]="lookupBinding";[8]="screenToVector";["getCursorPos"]={["ret"]={[1]="The x position of the mouse";[2]="The y position of the mouse";};["class"]="function";["description"]="\
Gets the position of the mouse";["fname"]="getCursorPos";["realm"]="sh";["name"]="input_methods.getCursorPos";["summary"]="\
Gets the position of the mouse ";["private"]=false;["library"]="input";["param"]={};};["lookupBinding"]={["ret"]={[1]="The id of the first key bound";[2]="The name of the first key bound";};["class"]="function";["description"]="\
Gets the first key that is bound to the command passed";["fname"]="lookupBinding";["realm"]="sh";["name"]="input_methods.lookupBinding";["summary"]="\
Gets the first key that is bound to the command passed ";["private"]=false;["library"]="input";["param"]={[1]="binding";["binding"]="The name of the bind";};};["getKeyName"]={["ret"]="The name of the key";["class"]="function";["description"]="\
Gets the name of a key from the id";["fname"]="getKeyName";["realm"]="sh";["name"]="input_methods.getKeyName";["summary"]="\
Gets the name of a key from the id ";["private"]=false;["library"]="input";["param"]={[1]="key";["key"]="The key id, see input";};};["enableCursor"]={["class"]="function";["description"]="\
Sets the state of the mouse cursor";["fname"]="enableCursor";["realm"]="sh";["name"]="input_methods.enableCursor";["summary"]="\
Sets the state of the mouse cursor ";["private"]=false;["library"]="input";["param"]={[1]="enabled";["enabled"]="Whether or not the cursor should be enabled";};};["screenToVector"]={["ret"]="Aim vector";["class"]="function";["description"]="\
Translates position on player's screen to aim vector";["fname"]="screenToVector";["realm"]="sh";["name"]="input_methods.screenToVector";["summary"]="\
Translates position on player's screen to aim vector ";["private"]=false;["library"]="input";["param"]={[1]="x";[2]="y";["y"]="Y coordinate on the screen";["x"]="X coordinate on the screen";};};["isShiftDown"]={["ret"]="True if the shift key is down";["class"]="function";["description"]="\
Gets whether the shift key is down";["fname"]="isShiftDown";["realm"]="sh";["name"]="input_methods.isShiftDown";["summary"]="\
Gets whether the shift key is down ";["private"]=false;["library"]="input";["param"]={};};["isKeyDown"]={["ret"]="True if the key is down";["class"]="function";["description"]="\
Gets whether a key is down";["fname"]="isKeyDown";["realm"]="sh";["name"]="input_methods.isKeyDown";["summary"]="\
Gets whether a key is down ";["private"]=false;["library"]="input";["param"]={[1]="key";["key"]="The key id, see input";};};["isControlDown"]={["ret"]="True if the control key is down";["class"]="function";["description"]="\
Gets whether the control key is down";["fname"]="isControlDown";["realm"]="sh";["name"]="input_methods.isControlDown";["summary"]="\
Gets whether the control key is down ";["private"]=false;["library"]="input";["param"]={};};};["tables"]={};["class"]="library";["description"]="\
Input library.";["summary"]="\
Input library.";["fields"]={};["name"]="input";["client"]=true;["libtbl"]="input_methods";};["file"]={["functions"]={[1]="append";[2]="createDir";[3]="delete";[4]="exists";[5]="find";[6]="open";[7]="read";[8]="write";["delete"]={["ret"]="True if successful, nil if error";["class"]="function";["description"]="\
Deletes a file";["fname"]="delete";["realm"]="cl";["name"]="file_library.delete";["summary"]="\
Deletes a file ";["private"]=false;["library"]="file";["param"]={[1]="path";["path"]="Filepath relative to data/sf_filedata/. Cannot contain '..'";};};["createDir"]={["class"]="function";["description"]="\
Creates a directory";["fname"]="createDir";["realm"]="cl";["name"]="file_library.createDir";["summary"]="\
Creates a directory ";["private"]=false;["library"]="file";["param"]={[1]="path";["path"]="Filepath relative to data/sf_filedata/. Cannot contain '..'";};};["open"]={["ret"]="File object or nil if it failed";["class"]="function";["description"]="\
Opens and returns a file";["fname"]="open";["realm"]="cl";["name"]="file_library.open";["summary"]="\
Opens and returns a file ";["private"]=false;["library"]="file";["param"]={[1]="path";[2]="mode";["path"]="Filepath relative to data/sf_filedata/. Cannot contain '..'";["mode"]="The file mode to use. See lua manual for explaination";};};["find"]={["ret"]={[1]="Table of file names";[2]="Table of directory names";};["class"]="function";["description"]="\
Enumerates a directory";["fname"]="find";["realm"]="cl";["name"]="file_library.find";["summary"]="\
Enumerates a directory ";["private"]=false;["library"]="file";["param"]={[1]="path";[2]="sorting";["path"]="The folder to enumerate, relative to data/sf_filedata/. Cannot contain '..'";["sorting"]="Optional sorting arguement. Either nameasc, namedesc, dateasc, datedesc";};};["read"]={["ret"]="Contents, or nil if error";["class"]="function";["description"]="\
Reads a file from path";["fname"]="read";["realm"]="cl";["name"]="file_library.read";["summary"]="\
Reads a file from path ";["private"]=false;["library"]="file";["param"]={[1]="path";["path"]="Filepath relative to data/sf_filedata/. Cannot contain '..'";};};["exists"]={["ret"]="True if exists, false if not, nil if error";["class"]="function";["description"]="\
Checks if a file exists";["fname"]="exists";["realm"]="cl";["name"]="file_library.exists";["summary"]="\
Checks if a file exists ";["private"]=false;["library"]="file";["param"]={[1]="path";["path"]="Filepath relative to data/sf_filedata/. Cannot contain '..'";};};["append"]={["class"]="function";["description"]="\
Appends a string to the end of a file";["fname"]="append";["realm"]="cl";["name"]="file_library.append";["summary"]="\
Appends a string to the end of a file ";["private"]=false;["library"]="file";["param"]={[1]="path";[2]="data";["path"]="Filepath relative to data/sf_filedata/. Cannot contain '..'";["data"]="String that will be appended to the file.";};};["write"]={["ret"]="True if OK, nil if error";["class"]="function";["description"]="\
Writes to a file";["fname"]="write";["realm"]="cl";["name"]="file_library.write";["summary"]="\
Writes to a file ";["private"]=false;["library"]="file";["param"]={[1]="path";[2]="data";["path"]="Filepath relative to data/sf_filedata/. Cannot contain '..'";};};};["tables"]={};["class"]="library";["description"]="\
File functions. Allows modification of files.";["summary"]="\
File functions.";["fields"]={};["name"]="file";["client"]=true;["libtbl"]="file_library";};["constraint"]={["functions"]={[1]="axis";[2]="ballsocket";[3]="ballsocketadv";[4]="breakAll";[5]="breakType";[6]="elastic";[7]="getTable";[8]="nocollide";[9]="rope";[10]="setElasticLength";[11]="setRopeLength";[12]="slider";[13]="weld";["ballsocketadv"]={["description"]="\
Advanced Ballsocket two entities";["class"]="function";["realm"]="sv";["fname"]="ballsocketadv";["summary"]="\
Advanced Ballsocket two entities ";["name"]="constraint_library.ballsocketadv";["library"]="constraint";["private"]=false;["server"]=true;["param"]={[1]="e1";[2]="e2";[3]="bone1";[4]="bone2";[5]="v1";[6]="v2";[7]="force_lim";[8]="torque_lim";[9]="minv";[10]="maxv";[11]="frictionv";[12]="rotateonly";[13]="nocollide";};};["nocollide"]={["description"]="\
Nocollides two entities";["class"]="function";["realm"]="sv";["fname"]="nocollide";["summary"]="\
Nocollides two entities ";["name"]="constraint_library.nocollide";["library"]="constraint";["private"]=false;["server"]=true;["param"]={[1]="e1";[2]="e2";[3]="bone1";[4]="bone2";};};["elastic"]={["description"]="\
Elastic two entities";["class"]="function";["realm"]="sv";["fname"]="elastic";["summary"]="\
Elastic two entities ";["name"]="constraint_library.elastic";["library"]="constraint";["private"]=false;["server"]=true;["param"]={[1]="index";[2]="e1";[3]="e2";[4]="bone1";[5]="bone2";[6]="v1";[7]="v2";[8]="const";[9]="damp";[10]="rdamp";[11]="width";[12]="strech";};};["getTable"]={["ret"]="Table of entity constraints";["class"]="function";["description"]="\
Returns the table of constraints on an entity";["fname"]="getTable";["realm"]="sv";["name"]="constraint_library.getTable";["summary"]="\
Returns the table of constraints on an entity ";["private"]=false;["library"]="constraint";["param"]={[1]="ent";["ent"]="The entity";};};["axis"]={["description"]="\
Axis two entities";["class"]="function";["realm"]="sv";["fname"]="axis";["summary"]="\
Axis two entities ";["name"]="constraint_library.axis";["library"]="constraint";["private"]=false;["server"]=true;["param"]={[1]="e1";[2]="e2";[3]="bone1";[4]="bone2";[5]="v1";[6]="v2";[7]="force_lim";[8]="torque_lim";[9]="friction";[10]="nocollide";[11]="laxis";};};["setElasticLength"]={["description"]="\
Sets the length of an elastic attached to the entity";["class"]="function";["realm"]="sv";["fname"]="setElasticLength";["summary"]="\
Sets the length of an elastic attached to the entity ";["name"]="constraint_library.setElasticLength";["library"]="constraint";["private"]=false;["server"]=true;["param"]={[1]="index";[2]="e";[3]="length";};};["breakType"]={["description"]="\
Breaks all constraints of a certain type on an entity";["class"]="function";["realm"]="sv";["fname"]="breakType";["summary"]="\
Breaks all constraints of a certain type on an entity ";["name"]="constraint_library.breakType";["library"]="constraint";["private"]=false;["server"]=true;["param"]={[1]="e";[2]="typename";};};["weld"]={["description"]="\
Welds two entities";["class"]="function";["realm"]="sv";["fname"]="weld";["summary"]="\
Welds two entities ";["name"]="constraint_library.weld";["library"]="constraint";["private"]=false;["server"]=true;["param"]={[1]="e1";[2]="e2";[3]="bone1";[4]="bone2";[5]="force_lim";[6]="nocollide";["nocollide"]="Bool whether or not to nocollide the two entities";["e1"]="The first entity";["force_lim"]="Max force the weld can take before breaking";["e2"]="The second entity";["bone1"]="Number bone of the first entity";["bone2"]="Number bone of the second entity";};};["rope"]={["description"]="\
Ropes two entities";["class"]="function";["realm"]="sv";["fname"]="rope";["summary"]="\
Ropes two entities ";["name"]="constraint_library.rope";["library"]="constraint";["private"]=false;["server"]=true;["param"]={[1]="index";[2]="e1";[3]="e2";[4]="bone1";[5]="bone2";[6]="v1";[7]="v2";[8]="length";[9]="addlength";[10]="force_lim";[11]="width";[12]="material";[13]="rigid";};};["breakAll"]={["description"]="\
Breaks all constraints on an entity";["class"]="function";["realm"]="sv";["fname"]="breakAll";["summary"]="\
Breaks all constraints on an entity ";["name"]="constraint_library.breakAll";["library"]="constraint";["private"]=false;["server"]=true;["param"]={[1]="e";};};["setRopeLength"]={["description"]="\
Sets the length of a rope attached to the entity";["class"]="function";["realm"]="sv";["fname"]="setRopeLength";["summary"]="\
Sets the length of a rope attached to the entity ";["name"]="constraint_library.setRopeLength";["library"]="constraint";["private"]=false;["server"]=true;["param"]={[1]="index";[2]="e";[3]="length";};};["ballsocket"]={["description"]="\
Ballsocket two entities";["class"]="function";["realm"]="sv";["fname"]="ballsocket";["summary"]="\
Ballsocket two entities ";["name"]="constraint_library.ballsocket";["library"]="constraint";["private"]=false;["server"]=true;["param"]={[1]="e1";[2]="e2";[3]="bone1";[4]="bone2";[5]="v1";[6]="force_lim";[7]="torque_lim";[8]="nocollide";};};["slider"]={["description"]="\
Sliders two entities";["class"]="function";["realm"]="sv";["fname"]="slider";["summary"]="\
Sliders two entities ";["name"]="constraint_library.slider";["library"]="constraint";["private"]=false;["server"]=true;["param"]={[1]="e1";[2]="e2";[3]="bone1";[4]="bone2";[5]="v1";[6]="v2";[7]="width";};};};["tables"]={};["class"]="library";["description"]="\
Library for creating and manipulating constraints.";["summary"]="\
Library for creating and manipulating constraints.";["fields"]={};["name"]="constraint";["libtbl"]="constraint_library";["server"]=true;};["http"]={["tables"]={};["functions"]={[1]="base64Encode";[2]="canRequest";[3]="get";[4]="post";["post"]={["class"]="function";["description"]="\
Runs a new http POST request";["fname"]="post";["realm"]="sh";["name"]="http_library.post";["summary"]="\
Runs a new http POST request ";["private"]=false;["library"]="http";["param"]={[1]="url";[2]="params";[3]="callbackSuccess";[4]="callbackFail";[5]="headers";["url"]="http target url";["headers"]="POST headers to be sent";["callbackFail"]="the function to be called on request fail, taking the failing reason as an argument";["callbackSuccess"]="the function to be called on request success, taking the arguments body (string), length (number), headers (table) and code (number)";["params"]="POST parameters to be sent";};};["base64Encode"]={["ret"]="The converted data";["class"]="function";["description"]="\
Converts data into base64 format or nil if the string is 0 length";["fname"]="base64Encode";["realm"]="sh";["name"]="http_library.base64Encode";["summary"]="\
Converts data into base64 format or nil if the string is 0 length ";["private"]=false;["library"]="http";["param"]={[1]="data";["data"]="The data to convert";};};["canRequest"]={["class"]="function";["description"]="\
Checks if a new http request can be started";["fname"]="canRequest";["realm"]="sh";["name"]="http_library.canRequest";["summary"]="\
Checks if a new http request can be started ";["private"]=false;["library"]="http";["param"]={};};["get"]={["class"]="function";["description"]="\
Runs a new http GET request";["fname"]="get";["realm"]="sh";["name"]="http_library.get";["summary"]="\
Runs a new http GET request ";["private"]=false;["library"]="http";["param"]={[1]="url";[2]="callbackSuccess";[3]="callbackFail";[4]="headers";["url"]="http target url";["callbackFail"]="the function to be called on request fail, taking the failing reason as an argument";["callbackSuccess"]="the function to be called on request success, taking the arguments body (string), length (number), headers (table) and code (number)";["headers"]="GET headers to be sent";};};};["description"]="\
Http library. Requests content from urls.";["class"]="library";["summary"]="\
Http library.";["fields"]={};["name"]="http";["client"]=true;["libtbl"]="http_library";["server"]=true;};};["classes"]={[1]="Angle";[2]="Bass";[3]="Color";[4]="Entity";[5]="File";[6]="Hologram";[7]="Mesh";[8]="Npc";[9]="Particle";[10]="PhysObj";[11]="Player";[12]="Quaternion";[13]="Sound";[14]="VMatrix";[15]="Vector";[16]="Vehicle";[17]="Weapon";[18]="Wirelink";["Quaternion"]={["typtbl"]="quat_methods";["class"]="class";["fields"]={};["name"]="Quaternion";["summary"]="\
Quaternion type ";["description"]="\
Quaternion type";["methods"]={[1]="conj";[2]="forward";[3]="i";[4]="j";[5]="k";[6]="r";[7]="real";[8]="right";[9]="up";["conj"]={["class"]="function";["description"]="\
Returns the conj of self";["fname"]="conj";["realm"]="sh";["name"]="quat_methods:conj";["summary"]="\
Returns the conj of self ";["private"]=false;["classlib"]="Quaternion";["param"]={};};["r"]={["class"]="function";["description"]="\
Alias for :real() as r is easier";["fname"]="r";["realm"]="sh";["name"]="quat_methods:r";["summary"]="\
Alias for :real() as r is easier ";["private"]=false;["classlib"]="Quaternion";["param"]={};};["right"]={["class"]="function";["description"]="\
Returns vector pointing right for <this>";["fname"]="right";["realm"]="sh";["name"]="quat_methods:right";["summary"]="\
Returns vector pointing right for <this> ";["private"]=false;["classlib"]="Quaternion";["param"]={};};["real"]={["class"]="function";["description"]="\
Returns the real component of the quaternion";["fname"]="real";["realm"]="sh";["name"]="quat_methods:real";["summary"]="\
Returns the real component of the quaternion ";["private"]=false;["classlib"]="Quaternion";["param"]={};};["i"]={["class"]="function";["description"]="\
Returns the i component of the quaternion";["fname"]="i";["realm"]="sh";["name"]="quat_methods:i";["summary"]="\
Returns the i component of the quaternion ";["private"]=false;["classlib"]="Quaternion";["param"]={};};["k"]={["class"]="function";["description"]="\
Returns the k component of the quaternion";["fname"]="k";["realm"]="sh";["name"]="quat_methods:k";["summary"]="\
Returns the k component of the quaternion ";["private"]=false;["classlib"]="Quaternion";["param"]={};};["j"]={["class"]="function";["description"]="\
Returns the j component of the quaternion";["fname"]="j";["realm"]="sh";["name"]="quat_methods:j";["summary"]="\
Returns the j component of the quaternion ";["private"]=false;["classlib"]="Quaternion";["param"]={};};["forward"]={["class"]="function";["description"]="\
Returns vector pointing forward for <this>";["fname"]="forward";["realm"]="sh";["name"]="quat_methods:forward";["summary"]="\
Returns vector pointing forward for <this> ";["private"]=false;["classlib"]="Quaternion";["param"]={};};["up"]={["class"]="function";["description"]="\
Returns vector pointing up for <this>";["fname"]="up";["realm"]="sh";["name"]="quat_methods:up";["summary"]="\
Returns vector pointing up for <this> ";["private"]=false;["classlib"]="Quaternion";["param"]={};};};};["PhysObj"]={["typtbl"]="physobj_methods";["class"]="class";["description"]="\
PhysObj Type";["summary"]="\
PhysObj Type ";["fields"]={};["name"]="PhysObj";["server"]=true;["client"]=true;["methods"]={[1]="applyForceCenter";[2]="applyForceOffset";[3]="applyTorque";[4]="enableDrag";[5]="enableGravity";[6]="enableMotion";[7]="getAngleVelocity";[8]="getAngles";[9]="getEntity";[10]="getInertia";[11]="getMass";[12]="getMassCenter";[13]="getMaterial";[14]="getMesh";[15]="getMeshConvexes";[16]="getPos";[17]="getVelocity";[18]="isValid";[19]="localToWorld";[20]="localToWorldVector";[21]="setInertia";[22]="setMass";[23]="setMaterial";[24]="setPos";[25]="setVelocity";[26]="wake";[27]="worldToLocal";[28]="worldToLocalVector";["getAngles"]={["ret"]="Angle angles of the physics object";["description"]="\
Gets the angles of the physics object";["class"]="function";["realm"]="sh";["summary"]="\
Gets the angles of the physics object ";["fname"]="getAngles";["classlib"]="PhysObj";["name"]="physobj_methods:getAngles";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["getMesh"]={["ret"]="table of MeshVertex structures";["class"]="function";["description"]="\
Returns a table of MeshVertex structures where each 3 vertices represent a triangle. See: http://wiki.garrysmod.com/page/Structures/MeshVertex";["fname"]="getMesh";["realm"]="sh";["name"]="physobj_methods:getMesh";["summary"]="\
Returns a table of MeshVertex structures where each 3 vertices represent a triangle.";["private"]=false;["classlib"]="PhysObj";["param"]={};};["applyTorque"]={["description"]="\
Applys a torque to a physics object";["class"]="function";["realm"]="sv";["fname"]="applyTorque";["summary"]="\
Applys a torque to a physics object ";["name"]="physobj_methods:applyTorque";["classlib"]="PhysObj";["private"]=false;["server"]=true;["param"]={[1]="torque";["torque"]="The local torque vector to apply";};};["wake"]={["description"]="\
Makes a sleeping physobj wakeup";["class"]="function";["realm"]="sv";["fname"]="wake";["summary"]="\
Makes a sleeping physobj wakeup ";["name"]="physobj_methods:wake";["classlib"]="PhysObj";["private"]=false;["server"]=true;["param"]={};};["localToWorld"]={["ret"]="The transformed vector";["class"]="function";["description"]="\
Returns a vector in the reference frame of the world from the local frame of the physicsobject";["fname"]="localToWorld";["realm"]="sh";["name"]="physobj_methods:localToWorld";["summary"]="\
Returns a vector in the reference frame of the world from the local frame of the physicsobject ";["private"]=false;["classlib"]="PhysObj";["param"]={[1]="vec";["vec"]="The vector to transform";};};["getMass"]={["ret"]="mass of the physics object";["description"]="\
Gets the mass of the physics object";["class"]="function";["realm"]="sh";["summary"]="\
Gets the mass of the physics object ";["fname"]="getMass";["classlib"]="PhysObj";["name"]="physobj_methods:getMass";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["worldToLocalVector"]={["ret"]="The transformed vector";["class"]="function";["description"]="\
Returns a normal vector in the local reference frame of the physicsobject from the world frame";["fname"]="worldToLocalVector";["realm"]="sh";["name"]="physobj_methods:worldToLocalVector";["summary"]="\
Returns a normal vector in the local reference frame of the physicsobject from the world frame ";["private"]=false;["classlib"]="PhysObj";["param"]={[1]="vec";["vec"]="The normal vector to transform";};};["setPos"]={["description"]="\
Sets the position of the physics object";["class"]="function";["realm"]="sv";["fname"]="setPos";["summary"]="\
Sets the position of the physics object ";["name"]="physobj_methods:setPos";["classlib"]="PhysObj";["private"]=false;["server"]=true;["param"]={[1]="pos";["pos"]="The position vector to set it to";};};["getMeshConvexes"]={["ret"]="table of MeshVertex structures";["class"]="function";["description"]="\
Returns a structured table, the physics mesh of the physics object. See: http://wiki.garrysmod.com/page/Structures/MeshVertex";["fname"]="getMeshConvexes";["realm"]="sh";["name"]="physobj_methods:getMeshConvexes";["summary"]="\
Returns a structured table, the physics mesh of the physics object.";["private"]=false;["classlib"]="PhysObj";["param"]={};};["setMaterial"]={["description"]="\
Sets the physical material of a physics object";["class"]="function";["realm"]="sv";["fname"]="setMaterial";["summary"]="\
Sets the physical material of a physics object ";["name"]="physobj_methods:setMaterial";["classlib"]="PhysObj";["private"]=false;["server"]=true;["param"]={[1]="material";["material"]="The physical material to set it to";};};["enableMotion"]={["class"]="function";["description"]="\
Sets the bone movement state";["fname"]="enableMotion";["realm"]="sh";["name"]="physobj_methods:enableMotion";["summary"]="\
Sets the bone movement state ";["private"]=false;["classlib"]="PhysObj";["param"]={[1]="move";["move"]="Bool should the bone move?";};};["enableDrag"]={["class"]="function";["description"]="\
Sets the bone drag state";["fname"]="enableDrag";["realm"]="sh";["name"]="physobj_methods:enableDrag";["summary"]="\
Sets the bone drag state ";["private"]=false;["classlib"]="PhysObj";["param"]={[1]="drag";["drag"]="Bool should the bone have air resistence?";};};["getInertia"]={["ret"]="Vector Inertia of the physics object";["description"]="\
Gets the inertia of the physics object";["class"]="function";["realm"]="sh";["summary"]="\
Gets the inertia of the physics object ";["fname"]="getInertia";["classlib"]="PhysObj";["name"]="physobj_methods:getInertia";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["enableGravity"]={["class"]="function";["description"]="\
Sets bone gravity";["fname"]="enableGravity";["realm"]="sh";["name"]="physobj_methods:enableGravity";["summary"]="\
Sets bone gravity ";["private"]=false;["classlib"]="PhysObj";["param"]={[1]="grav";["grav"]="Bool should the bone respect gravity?";};};["setInertia"]={["description"]="\
Sets the inertia of a physics object";["class"]="function";["realm"]="sv";["fname"]="setInertia";["summary"]="\
Sets the inertia of a physics object ";["name"]="physobj_methods:setInertia";["classlib"]="PhysObj";["private"]=false;["server"]=true;["param"]={[1]="inertia";["inertia"]="The inertia vector to set it to";};};["isValid"]={["ret"]="boolean if the physics object is valid";["description"]="\
Checks if the physics object is valid";["class"]="function";["realm"]="sh";["summary"]="\
Checks if the physics object is valid ";["fname"]="isValid";["classlib"]="PhysObj";["name"]="physobj_methods:isValid";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["getMaterial"]={["ret"]="The physics material of the physics object";["description"]="\
Gets the material of the physics object";["class"]="function";["realm"]="sh";["summary"]="\
Gets the material of the physics object ";["fname"]="getMaterial";["classlib"]="PhysObj";["name"]="physobj_methods:getMaterial";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["localToWorldVector"]={["ret"]="The transformed vector";["class"]="function";["description"]="\
Returns a normal vector in the reference frame of the world from the local frame of the physicsobject";["fname"]="localToWorldVector";["realm"]="sh";["name"]="physobj_methods:localToWorldVector";["summary"]="\
Returns a normal vector in the reference frame of the world from the local frame of the physicsobject ";["private"]=false;["classlib"]="PhysObj";["param"]={[1]="vec";["vec"]="The normal vector to transform";};};["applyForceOffset"]={["description"]="\
Applys an offset force to a physics object";["class"]="function";["realm"]="sv";["fname"]="applyForceOffset";["summary"]="\
Applys an offset force to a physics object ";["name"]="physobj_methods:applyForceOffset";["classlib"]="PhysObj";["private"]=false;["server"]=true;["param"]={[1]="force";[2]="position";["force"]="The force vector to apply";["position"]="The position in world coordinates";};};["getPos"]={["ret"]="Vector position of the physics object";["description"]="\
Gets the position of the physics object";["class"]="function";["realm"]="sh";["summary"]="\
Gets the position of the physics object ";["fname"]="getPos";["classlib"]="PhysObj";["name"]="physobj_methods:getPos";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["applyForceCenter"]={["description"]="\
Applys a force to the center of the physics object";["class"]="function";["realm"]="sv";["fname"]="applyForceCenter";["summary"]="\
Applys a force to the center of the physics object ";["name"]="physobj_methods:applyForceCenter";["classlib"]="PhysObj";["private"]=false;["server"]=true;["param"]={[1]="force";["force"]="The force vector to apply";};};["getMassCenter"]={["ret"]="Center of mass vector in the physobject's local reference frame.";["description"]="\
Gets the center of mass of the physics object in the local reference frame.";["class"]="function";["realm"]="sh";["summary"]="\
Gets the center of mass of the physics object in the local reference frame.";["fname"]="getMassCenter";["classlib"]="PhysObj";["name"]="physobj_methods:getMassCenter";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["getAngleVelocity"]={["ret"]="Vector angular velocity of the physics object";["description"]="\
Gets the angular velocity of the physics object";["class"]="function";["realm"]="sh";["summary"]="\
Gets the angular velocity of the physics object ";["fname"]="getAngleVelocity";["classlib"]="PhysObj";["name"]="physobj_methods:getAngleVelocity";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["setVelocity"]={["description"]="\
Sets the velocity of the physics object";["class"]="function";["realm"]="sv";["fname"]="setVelocity";["summary"]="\
Sets the velocity of the physics object ";["name"]="physobj_methods:setVelocity";["classlib"]="PhysObj";["private"]=false;["server"]=true;["param"]={[1]="vel";["vel"]="The velocity vector to set it to";};};["worldToLocal"]={["ret"]="The transformed vector";["class"]="function";["description"]="\
Returns a vector in the local reference frame of the physicsobject from the world frame";["fname"]="worldToLocal";["realm"]="sh";["name"]="physobj_methods:worldToLocal";["summary"]="\
Returns a vector in the local reference frame of the physicsobject from the world frame ";["private"]=false;["classlib"]="PhysObj";["param"]={[1]="vec";["vec"]="The vector to transform";};};["setMass"]={["description"]="\
Sets the mass of a physics object";["class"]="function";["realm"]="sv";["fname"]="setMass";["summary"]="\
Sets the mass of a physics object ";["name"]="physobj_methods:setMass";["classlib"]="PhysObj";["private"]=false;["server"]=true;["param"]={[1]="mass";["mass"]="The mass to set it to";};};["getVelocity"]={["ret"]="Vector velocity of the physics object";["description"]="\
Gets the velocity of the physics object";["class"]="function";["realm"]="sh";["summary"]="\
Gets the velocity of the physics object ";["fname"]="getVelocity";["classlib"]="PhysObj";["name"]="physobj_methods:getVelocity";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["getEntity"]={["ret"]="The entity attached to the physics object";["description"]="\
Gets the entity attached to the physics object";["class"]="function";["realm"]="sh";["summary"]="\
Gets the entity attached to the physics object ";["fname"]="getEntity";["classlib"]="PhysObj";["name"]="physobj_methods:getEntity";["server"]=true;["private"]=false;["client"]=true;["param"]={};};};};["Hologram"]={["typtbl"]="hologram_methods";["class"]="class";["fields"]={};["name"]="Hologram";["summary"]="\
Hologram type ";["description"]="\
Hologram type";["methods"]={[1]="getAnimationLength";[2]="getAnimationNumber";[3]="getFlexes";[4]="getPose";[5]="setAngVel";[6]="setAnimation";[7]="setClip";[8]="setFlexScale";[9]="setFlexWeight";[10]="setModel";[11]="setPose";[12]="setScale";[13]="setVel";[14]="suppressEngineLighting";["setAngVel"]={["class"]="function";["description"]="\
Sets the hologram's angular velocity.";["fname"]="setAngVel";["realm"]="sv";["name"]="hologram_methods:setAngVel";["summary"]="\
Sets the hologram's angular velocity.";["private"]=false;["classlib"]="Hologram";["param"]={[1]="angvel";["angvel"]="*Vector* angular velocity.";};};["getAnimationNumber"]={["ret"]="Animation index";["description"]="\
Convert animation name into animation number";["class"]="function";["realm"]="sv";["fname"]="getAnimationNumber";["summary"]="\
Convert animation name into animation number ";["name"]="hologram_methods:getAnimationNumber";["classlib"]="Hologram";["private"]=false;["server"]=true;["param"]={[1]="animation";["animation"]="Name of the animation";};};["getFlexes"]={["class"]="function";["description"]="\
Returns a table of flexname -> flexid pairs for use in flex functions. \
These IDs become invalid when the hologram's model changes.";["fname"]="getFlexes";["realm"]="sv";["name"]="hologram_methods:getFlexes";["summary"]="\
Returns a table of flexname -> flexid pairs for use in flex functions.";["private"]=false;["classlib"]="Hologram";["param"]={};};["getAnimationLength"]={["ret"]="Length of current animation in seconds";["description"]="\
Get the length of the current animation";["class"]="function";["realm"]="sv";["summary"]="\
Get the length of the current animation ";["classForced"]=true;["fname"]="getAnimationLength";["name"]="hologram_methods:getAnimationLength";["classlib"]="Hologram";["private"]=false;["server"]=true;["param"]={};};["getPose"]={["ret"]="Value of the pose parameter";["description"]="\
Get the pose value of an animation";["class"]="function";["realm"]="sv";["summary"]="\
Get the pose value of an animation ";["classForced"]=true;["fname"]="getPose";["name"]="hologram_methods:getPose";["classlib"]="Hologram";["private"]=false;["server"]=true;["param"]={[1]="pose";["pose"]="Pose parameter name";};};["setScale"]={["class"]="function";["description"]="\
Sets the hologram scale";["fname"]="setScale";["realm"]="sv";["name"]="hologram_methods:setScale";["summary"]="\
Sets the hologram scale ";["private"]=false;["classlib"]="Hologram";["param"]={[1]="scale";["scale"]="Vector new scale";};};["setModel"]={["description"]="\
Sets the model of a hologram";["class"]="function";["realm"]="sv";["summary"]="\
Sets the model of a hologram ";["classForced"]=true;["fname"]="setModel";["name"]="hologram_methods:setModel";["classlib"]="Hologram";["private"]=false;["server"]=true;["param"]={[1]="model";["model"]="string model path";};};["setFlexWeight"]={["class"]="function";["description"]="\
Sets the weight (value) of a flex.";["fname"]="setFlexWeight";["realm"]="sv";["name"]="hologram_methods:setFlexWeight";["summary"]="\
Sets the weight (value) of a flex.";["private"]=false;["classlib"]="Hologram";["param"]={[1]="flexid";[2]="weight";};};["setAnimation"]={["description"]="\
Animates a hologram";["class"]="function";["realm"]="sv";["summary"]="\
Animates a hologram ";["classForced"]=true;["fname"]="setAnimation";["name"]="hologram_methods:setAnimation";["classlib"]="Hologram";["private"]=false;["server"]=true;["param"]={[1]="animation";[2]="frame";[3]="rate";["frame"]="The starting frame number";["rate"]="Frame speed. (1 is normal)";["animation"]="number or string name";};};["setFlexScale"]={["class"]="function";["description"]="\
Sets the scale of all flexes of a hologram";["fname"]="setFlexScale";["realm"]="sv";["name"]="hologram_methods:setFlexScale";["summary"]="\
Sets the scale of all flexes of a hologram ";["private"]=false;["classlib"]="Hologram";["param"]={[1]="scale";};};["setPose"]={["description"]="\
Set the pose value of an animation. Turret/Head angles for example.";["class"]="function";["realm"]="sv";["summary"]="\
Set the pose value of an animation.";["classForced"]=true;["fname"]="setPose";["name"]="hologram_methods:setPose";["classlib"]="Hologram";["private"]=false;["server"]=true;["param"]={[1]="pose";[2]="value";["value"]="Value to set it to.";["pose"]="Name of the pose parameter";};};["setVel"]={["class"]="function";["description"]="\
Sets the hologram linear velocity";["fname"]="setVel";["realm"]="sv";["name"]="hologram_methods:setVel";["summary"]="\
Sets the hologram linear velocity ";["private"]=false;["classlib"]="Hologram";["param"]={[1]="vel";["vel"]="New velocity";};};["suppressEngineLighting"]={["description"]="\
Suppress Engine Lighting of a hologram. Disabled by default.";["class"]="function";["realm"]="sv";["summary"]="\
Suppress Engine Lighting of a hologram.";["classForced"]=true;["fname"]="suppressEngineLighting";["name"]="hologram_methods:suppressEngineLighting";["classlib"]="Hologram";["private"]=false;["server"]=true;["param"]={[1]="suppress";["suppress"]="Boolean to represent if shading should be set or not.";};};["setClip"]={["class"]="function";["description"]="\
Updates a clip plane";["fname"]="setClip";["realm"]="sv";["name"]="hologram_methods:setClip";["summary"]="\
Updates a clip plane ";["private"]=false;["classlib"]="Hologram";["param"]={[1]="index";[2]="enabled";[3]="origin";[4]="normal";[5]="islocal";};};};};["Bass"]={["typtbl"]="bass_methods";["class"]="class";["description"]="\
For playing music there is `Bass` type. You can pause and set current playback time in it. If you're looking to apply DSP effects on present game sounds, use `Sound` instead.";["fields"]={};["name"]="Bass";["summary"]="\
For playing music there is `Bass` type.";["client"]=true;["methods"]={[1]="getFFT";[2]="getLength";[3]="getTime";[4]="isOnline";[5]="isValid";[6]="pause";[7]="play";[8]="setFade";[9]="setLooping";[10]="setPitch";[11]="setPos";[12]="setTime";[13]="setVolume";[14]="stop";["isValid"]={["ret"]="Boolean of whether the bass is valid.";["class"]="function";["description"]="\
Gets whether the bass is valid.";["fname"]="isValid";["realm"]="cl";["name"]="bass_methods:isValid";["summary"]="\
Gets whether the bass is valid.";["private"]=false;["classlib"]="Bass";["param"]={};};["setLooping"]={["class"]="function";["description"]="\
Sets whether the sound channel should loop.";["fname"]="setLooping";["realm"]="cl";["name"]="bass_methods:setLooping";["summary"]="\
Sets whether the sound channel should loop.";["private"]=false;["classlib"]="Bass";["param"]={[1]="loop";["loop"]="Boolean of whether the sound channel should loop.";};};["isOnline"]={["ret"]="Boolean of whether the sound channel is streamed online.";["class"]="function";["description"]="\
Gets whether the sound channel is streamed online.";["fname"]="isOnline";["realm"]="cl";["name"]="bass_methods:isOnline";["summary"]="\
Gets whether the sound channel is streamed online.";["private"]=false;["classlib"]="Bass";["param"]={};};["setFade"]={["class"]="function";["description"]="\
Sets the fade distance of the sound in 3D space. Must have `3d` flag to get this work on.";["fname"]="setFade";["realm"]="cl";["name"]="bass_methods:setFade";["summary"]="\
Sets the fade distance of the sound in 3D space.";["private"]=false;["classlib"]="Bass";["param"]={[1]="min";[2]="max";["min"]="The channel's volume is at maximum when the listener is within this distance";["max"]="The channel's volume stops decreasing when the listener is beyond this distance.";};};["getFFT"]={["ret"]="Table containing DFT magnitudes, each between 0 and 1.";["class"]="function";["description"]="\
Perform fast Fourier transform algorithm to compute the DFT of the sound channel.";["fname"]="getFFT";["realm"]="cl";["name"]="bass_methods:getFFT";["summary"]="\
Perform fast Fourier transform algorithm to compute the DFT of the sound channel.";["private"]=false;["classlib"]="Bass";["param"]={[1]="n";["n"]="Number of consecutive audio samples, between 0 and 7. Depending on this parameter you will get 256*2^n samples.";};};["setPitch"]={["class"]="function";["description"]="\
Sets the pitch of the sound channel.";["fname"]="setPitch";["realm"]="cl";["name"]="bass_methods:setPitch";["summary"]="\
Sets the pitch of the sound channel.";["private"]=false;["classlib"]="Bass";["param"]={[1]="pitch";["pitch"]="Pitch to set to, between 0 and 3.";};};["getTime"]={["ret"]="Sound channel playback time in seconds.";["class"]="function";["description"]="\
Gets the current playback time of the sound channel.";["fname"]="getTime";["realm"]="cl";["name"]="bass_methods:getTime";["summary"]="\
Gets the current playback time of the sound channel.";["private"]=false;["classlib"]="Bass";["param"]={};};["setTime"]={["class"]="function";["description"]="\
Sets the current playback time of the sound channel.";["fname"]="setTime";["realm"]="cl";["name"]="bass_methods:setTime";["summary"]="\
Sets the current playback time of the sound channel.";["private"]=false;["classlib"]="Bass";["param"]={[1]="time";["time"]="Sound channel playback time in seconds.";};};["getLength"]={["ret"]="Sound channel length in seconds.";["class"]="function";["description"]="\
Gets the length of a sound channel.";["fname"]="getLength";["realm"]="cl";["name"]="bass_methods:getLength";["summary"]="\
Gets the length of a sound channel.";["private"]=false;["classlib"]="Bass";["param"]={};};["stop"]={["class"]="function";["description"]="\
Stops playing the sound.";["fname"]="stop";["realm"]="cl";["name"]="bass_methods:stop";["summary"]="\
Stops playing the sound.";["private"]=false;["classlib"]="Bass";["param"]={};};["setPos"]={["class"]="function";["description"]="\
Sets the position of the sound in 3D space. Must have `3d` flag to get this work on.";["fname"]="setPos";["realm"]="cl";["name"]="bass_methods:setPos";["summary"]="\
Sets the position of the sound in 3D space.";["private"]=false;["classlib"]="Bass";["param"]={[1]="pos";["pos"]="Where to position the sound.";};};["setVolume"]={["class"]="function";["description"]="\
Sets the volume of the sound channel.";["fname"]="setVolume";["realm"]="cl";["name"]="bass_methods:setVolume";["summary"]="\
Sets the volume of the sound channel.";["private"]=false;["classlib"]="Bass";["param"]={[1]="vol";["vol"]="Volume to set to, between 0 and 1.";};};["pause"]={["class"]="function";["description"]="\
Pauses the sound.";["fname"]="pause";["realm"]="cl";["name"]="bass_methods:pause";["summary"]="\
Pauses the sound.";["private"]=false;["classlib"]="Bass";["param"]={};};["play"]={["class"]="function";["description"]="\
Starts to play the sound.";["fname"]="play";["realm"]="cl";["name"]="bass_methods:play";["summary"]="\
Starts to play the sound.";["private"]=false;["classlib"]="Bass";["param"]={};};};};["Npc"]={["typtbl"]="npc_methods";["class"]="class";["fields"]={};["name"]="Npc";["summary"]="\
Npc type ";["description"]="\
Npc type";["methods"]={[1]="addEntityRelationship";[2]="addRelationship";[3]="attackMelee";[4]="attackRange";[5]="getEnemy";[6]="getRelationship";[7]="giveWeapon";[8]="goRun";[9]="goWalk";[10]="setEnemy";[11]="stop";["goWalk"]={["class"]="function";["description"]="\
Makes the npc walk to a destination";["fname"]="goWalk";["realm"]="sv";["name"]="npc_methods:goWalk";["summary"]="\
Makes the npc walk to a destination ";["private"]=false;["classlib"]="Npc";["param"]={[1]="vec";["vec"]="The position of the destination";};};["addEntityRelationship"]={["class"]="function";["description"]="\
Adds a relationship to the npc with an entity";["fname"]="addEntityRelationship";["realm"]="sv";["name"]="npc_methods:addEntityRelationship";["summary"]="\
Adds a relationship to the npc with an entity ";["private"]=false;["classlib"]="Npc";["param"]={[1]="ent";[2]="disp";[3]="priority";["priority"]="number how strong the relationship is. Higher number is stronger";["ent"]="The target entity";["disp"]="String of the relationship. (hate fear like neutral)";};};["addRelationship"]={["class"]="function";["description"]="\
Adds a relationship to the npc";["fname"]="addRelationship";["realm"]="sv";["name"]="npc_methods:addRelationship";["summary"]="\
Adds a relationship to the npc ";["private"]=false;["classlib"]="Npc";["param"]={[1]="str";["str"]="The relationship string. http://wiki.garrysmod.com/page/NPC/AddRelationship";};};["attackMelee"]={["class"]="function";["description"]="\
Makes the npc do a melee attack";["fname"]="attackMelee";["realm"]="sv";["name"]="npc_methods:attackMelee";["summary"]="\
Makes the npc do a melee attack ";["private"]=false;["classlib"]="Npc";["param"]={};};["attackRange"]={["class"]="function";["description"]="\
Makes the npc do a ranged attack";["fname"]="attackRange";["realm"]="sv";["name"]="npc_methods:attackRange";["summary"]="\
Makes the npc do a ranged attack ";["private"]=false;["classlib"]="Npc";["param"]={};};["getRelationship"]={["ret"]="string relationship of the npc with the target";["class"]="function";["description"]="\
Gets the npc's relationship to the target";["fname"]="getRelationship";["realm"]="sv";["name"]="npc_methods:getRelationship";["summary"]="\
Gets the npc's relationship to the target ";["private"]=false;["classlib"]="Npc";["param"]={[1]="ent";["ent"]="Target entity";};};["stop"]={["class"]="function";["description"]="\
Stops the npc";["fname"]="stop";["realm"]="sv";["name"]="npc_methods:stop";["summary"]="\
Stops the npc ";["private"]=false;["classlib"]="Npc";["param"]={};};["giveWeapon"]={["class"]="function";["description"]="\
Gives the npc a weapon";["fname"]="giveWeapon";["realm"]="sv";["name"]="npc_methods:giveWeapon";["summary"]="\
Gives the npc a weapon ";["private"]=false;["classlib"]="Npc";["param"]={[1]="wep";["wep"]="The classname of the weapon";};};["goRun"]={["class"]="function";["description"]="\
Makes the npc run to a destination";["fname"]="goRun";["realm"]="sv";["name"]="npc_methods:goRun";["summary"]="\
Makes the npc run to a destination ";["private"]=false;["classlib"]="Npc";["param"]={[1]="vec";["vec"]="The position of the destination";};};["getEnemy"]={["ret"]="Entity the npc is fighting";["class"]="function";["description"]="\
Gets what the npc is fighting";["fname"]="getEnemy";["realm"]="sv";["name"]="npc_methods:getEnemy";["summary"]="\
Gets what the npc is fighting ";["private"]=false;["classlib"]="Npc";["param"]={};};["setEnemy"]={["class"]="function";["description"]="\
Tell the npc to fight this";["fname"]="setEnemy";["realm"]="sv";["name"]="npc_methods:setEnemy";["summary"]="\
Tell the npc to fight this ";["private"]=false;["classlib"]="Npc";["param"]={[1]="ent";["ent"]="Target entity";};};};};["Vector"]={["typtbl"]="vec_methods";["class"]="class";["description"]="\
Vector type";["summary"]="\
Vector type ";["fields"]={};["name"]="Vector";["server"]=true;["client"]=true;["methods"]={[1]="add";[2]="cross";[3]="div";[4]="dot";[5]="getAngle";[6]="getAngleEx";[7]="getDistance";[8]="getDistanceSqr";[9]="getLength";[10]="getLength2D";[11]="getLength2DSqr";[12]="getLengthSqr";[13]="getNormalized";[14]="isEqualTol";[15]="isZero";[16]="mul";[17]="normalize";[18]="rotate";[19]="rotateAroundAxis";[20]="set";[21]="setX";[22]="setY";[23]="setZ";[24]="setZero";[25]="sub";[26]="toScreen";[27]="vdiv";[28]="vmul";[29]="withinAABox";["isEqualTol"]={["ret"]="bool True/False.";["class"]="function";["description"]="\
Is this vector and v equal within tolerance t.";["fname"]="isEqualTol";["realm"]="sh";["name"]="vec_methods:isEqualTol";["summary"]="\
Is this vector and v equal within tolerance t.";["private"]=false;["classlib"]="Vector";["param"]={[1]="v";[2]="t";["t"]="Tolerance number.";["v"]="Second Vector";};};["vdiv"]={["class"]="function";["description"]="\
Divide self by a Vector. Self-Modifies. ( convenience function )";["fname"]="vdiv";["realm"]="sh";["name"]="vec_methods:vdiv";["summary"]="\
Divide self by a Vector.";["private"]=false;["classlib"]="Vector";["param"]={[1]="v";["v"]="Vector to divide by";};};["getAngle"]={["ret"]="Angle";["class"]="function";["description"]="\
Get the vector's angle.";["fname"]="getAngle";["realm"]="sh";["name"]="vec_methods:getAngle";["summary"]="\
Get the vector's angle.";["private"]=false;["classlib"]="Vector";["param"]={};};["getLength2D"]={["ret"]="number length";["class"]="function";["description"]="\
Returns the length of the vector in two dimensions, without the Z axis.";["fname"]="getLength2D";["realm"]="sh";["name"]="vec_methods:getLength2D";["summary"]="\
Returns the length of the vector in two dimensions, without the Z axis.";["private"]=false;["classlib"]="Vector";["param"]={};};["withinAABox"]={["ret"]="bool True/False.";["class"]="function";["description"]="\
Returns whenever the given vector is in a box created by the 2 other vectors.";["fname"]="withinAABox";["realm"]="sh";["name"]="vec_methods:withinAABox";["summary"]="\
Returns whenever the given vector is in a box created by the 2 other vectors.";["private"]=false;["classlib"]="Vector";["param"]={[1]="v1";[2]="v2";["v1"]="Vector used to define AABox";["v2"]="Second Vector to define AABox";};};["mul"]={["ret"]="nil";["class"]="function";["description"]="\
Scalar Multiplication of the vector. Self-Modifies.";["fname"]="mul";["realm"]="sh";["name"]="vec_methods:mul";["summary"]="\
Scalar Multiplication of the vector.";["private"]=false;["classlib"]="Vector";["param"]={[1]="n";["n"]="Scalar to multiply with.";};};["sub"]={["ret"]="nil";["class"]="function";["description"]="\
Subtract v from this Vector. Self-Modifies.";["fname"]="sub";["realm"]="sh";["name"]="vec_methods:sub";["summary"]="\
Subtract v from this Vector.";["private"]=false;["classlib"]="Vector";["param"]={[1]="v";["v"]="Second Vector.";};};["getLength"]={["ret"]="number Length.";["class"]="function";["description"]="\
Get the vector's Length.";["fname"]="getLength";["realm"]="sh";["name"]="vec_methods:getLength";["summary"]="\
Get the vector's Length.";["private"]=false;["classlib"]="Vector";["param"]={};};["normalize"]={["ret"]="nil";["class"]="function";["description"]="\
Normalise the vector, same direction, length 1. Self-Modifies.";["fname"]="normalize";["realm"]="sh";["name"]="vec_methods:normalize";["summary"]="\
Normalise the vector, same direction, length 1.";["private"]=false;["classlib"]="Vector";["param"]={};};["getDistanceSqr"]={["ret"]="Number";["class"]="function";["description"]="\
Returns the squared distance of 2 vectors, this is faster Vector:getDistance as calculating the square root is an expensive process.";["fname"]="getDistanceSqr";["realm"]="sh";["name"]="vec_methods:getDistanceSqr";["summary"]="\
Returns the squared distance of 2 vectors, this is faster Vector:getDistance as calculating the square root is an expensive process.";["private"]=false;["classlib"]="Vector";["param"]={[1]="v";["v"]="Second Vector";};};["getDistance"]={["ret"]="Number";["class"]="function";["description"]="\
Returns the pythagorean distance between the vector and the other vector.";["fname"]="getDistance";["realm"]="sh";["name"]="vec_methods:getDistance";["summary"]="\
Returns the pythagorean distance between the vector and the other vector.";["private"]=false;["classlib"]="Vector";["param"]={[1]="v";["v"]="Second Vector";};};["setZero"]={["ret"]="nil";["class"]="function";["description"]="\
Set's all vector fields to 0.";["fname"]="setZero";["realm"]="sh";["name"]="vec_methods:setZero";["summary"]="\
Set's all vector fields to 0.";["private"]=false;["classlib"]="Vector";["param"]={};};["getLength2DSqr"]={["ret"]="number length squared.";["class"]="function";["description"]="\
Returns the length squared of the vector in two dimensions, without the Z axis. ( Saves computation by skipping the square root )";["fname"]="getLength2DSqr";["realm"]="sh";["name"]="vec_methods:getLength2DSqr";["summary"]="\
Returns the length squared of the vector in two dimensions, without the Z axis.";["private"]=false;["classlib"]="Vector";["param"]={};};["rotateAroundAxis"]={["ret"]="Rotated vector";["class"]="function";["description"]="\
Return rotated vector by an axis";["fname"]="rotateAroundAxis";["realm"]="sh";["name"]="vec_methods:rotateAroundAxis";["summary"]="\
Return rotated vector by an axis ";["private"]=false;["classlib"]="Vector";["param"]={[1]="axis";[2]="degrees";[3]="radians";["degrees"]="Angle to rotate by in degrees or nil if radians.";["radians"]="Angle to rotate by in radians or nil if degrees.";["axis"]="Axis the rotate around";};};["setZ"]={["ret"]="The modified vector";["class"]="function";["description"]="\
Set's the vector's z coordinate and returns it.";["fname"]="setZ";["realm"]="sh";["name"]="vec_methods:setZ";["summary"]="\
Set's the vector's z coordinate and returns it.";["private"]=false;["classlib"]="Vector";["param"]={[1]="z";["z"]="The z coordinate";};};["dot"]={["ret"]="Number";["class"]="function";["description"]="\
Dot product is the cosine of the angle between both vectors multiplied by their lengths. A.B = ||A||||B||cosA.";["fname"]="dot";["realm"]="sh";["name"]="vec_methods:dot";["summary"]="\
Dot product is the cosine of the angle between both vectors multiplied by their lengths.";["private"]=false;["classlib"]="Vector";["param"]={[1]="v";["v"]="Second Vector";};};["toScreen"]={["ret"]="A table {x=screenx,y=screeny,visible=visible}";["class"]="function";["description"]="\
Translates the vectors position into 2D user screen coordinates.";["fname"]="toScreen";["realm"]="sh";["name"]="vec_methods:toScreen";["summary"]="\
Translates the vectors position into 2D user screen coordinates.";["private"]=false;["classlib"]="Vector";["param"]={};};["setY"]={["ret"]="The modified vector";["class"]="function";["description"]="\
Set's the vector's y coordinate and returns it.";["fname"]="setY";["realm"]="sh";["name"]="vec_methods:setY";["summary"]="\
Set's the vector's y coordinate and returns it.";["private"]=false;["classlib"]="Vector";["param"]={[1]="y";["y"]="The y coordinate";};};["isZero"]={["ret"]="bool True/False";["class"]="function";["description"]="\
Are all fields zero.";["fname"]="isZero";["realm"]="sh";["name"]="vec_methods:isZero";["summary"]="\
Are all fields zero.";["private"]=false;["classlib"]="Vector";["param"]={};};["div"]={["ret"]="nil";["class"]="function";["description"]="\
\"Scalar Division\" of the vector. Self-Modifies.";["fname"]="div";["realm"]="sh";["name"]="vec_methods:div";["summary"]="\
\"Scalar Division\" of the vector.";["private"]=false;["classlib"]="Vector";["param"]={[1]="n";["n"]="Scalar to divide by.";};};["setX"]={["ret"]="The modified vector";["class"]="function";["description"]="\
Set's the vector's x coordinate and returns it.";["fname"]="setX";["realm"]="sh";["name"]="vec_methods:setX";["summary"]="\
Set's the vector's x coordinate and returns it.";["private"]=false;["classlib"]="Vector";["param"]={[1]="x";["x"]="The x coordinate";};};["set"]={["ret"]="nil";["class"]="function";["description"]="\
Copies the values from the second vector to the first vector. Self-Modifies.";["fname"]="set";["realm"]="sh";["name"]="vec_methods:set";["summary"]="\
Copies the values from the second vector to the first vector.";["private"]=false;["classlib"]="Vector";["param"]={[1]="v";["v"]="Second Vector";};};["getNormalized"]={["ret"]="Vector Normalised";["class"]="function";["description"]="\
Returns a new vector with the same direction by length of 1.";["fname"]="getNormalized";["realm"]="sh";["name"]="vec_methods:getNormalized";["summary"]="\
Returns a new vector with the same direction by length of 1.";["private"]=false;["classlib"]="Vector";["param"]={};};["getLengthSqr"]={["ret"]="number length squared.";["class"]="function";["description"]="\
Get the vector's length squared ( Saves computation by skipping the square root ).";["fname"]="getLengthSqr";["realm"]="sh";["name"]="vec_methods:getLengthSqr";["summary"]="\
Get the vector's length squared ( Saves computation by skipping the square root ).";["private"]=false;["classlib"]="Vector";["param"]={};};["vmul"]={["class"]="function";["description"]="\
Multiply self with a Vector. Self-Modifies. ( convenience function )";["fname"]="vmul";["realm"]="sh";["name"]="vec_methods:vmul";["summary"]="\
Multiply self with a Vector.";["private"]=false;["classlib"]="Vector";["param"]={[1]="v";["v"]="Vector to multiply with";};};["cross"]={["ret"]="Vector";["class"]="function";["description"]="\
Calculates the cross product of the 2 vectors, creates a unique perpendicular vector to both input vectors.";["fname"]="cross";["realm"]="sh";["name"]="vec_methods:cross";["summary"]="\
Calculates the cross product of the 2 vectors, creates a unique perpendicular vector to both input vectors.";["private"]=false;["classlib"]="Vector";["param"]={[1]="v";["v"]="Second Vector";};};["getAngleEx"]={["ret"]="Angle";["class"]="function";["description"]="\
Returns the Angle between two vectors.";["fname"]="getAngleEx";["realm"]="sh";["name"]="vec_methods:getAngleEx";["summary"]="\
Returns the Angle between two vectors.";["private"]=false;["classlib"]="Vector";["param"]={[1]="v";["v"]="Second Vector";};};["rotate"]={["ret"]="nil.";["class"]="function";["description"]="\
Rotate the vector by Angle b. Self-Modifies.";["fname"]="rotate";["realm"]="sh";["name"]="vec_methods:rotate";["summary"]="\
Rotate the vector by Angle b.";["private"]=false;["classlib"]="Vector";["param"]={[1]="b";["b"]="Angle to rotate by.";};};["add"]={["ret"]="nil";["class"]="function";["description"]="\
Add vector - Modifies self.";["fname"]="add";["realm"]="sh";["name"]="vec_methods:add";["summary"]="\
Add vector - Modifies self.";["private"]=false;["classlib"]="Vector";["param"]={[1]="v";["v"]="Vector to add";};};};};["Entity"]={["typtbl"]="ents_methods";["class"]="class";["description"]="\
Entity type";["summary"]="\
Entity type ";["fields"]={};["name"]="Entity";["server"]=true;["client"]=true;["methods"]={[1]="addCollisionListener";[2]="applyAngForce";[3]="applyDamage";[4]="applyForceCenter";[5]="applyForceOffset";[6]="applyTorque";[7]="breakEnt";[8]="emitSound";[9]="enableDrag";[10]="enableGravity";[11]="enableMotion";[12]="enableSphere";[13]="entIndex";[14]="extinguish";[15]="getAngleVelocity";[16]="getAngleVelocityAngle";[17]="getAngles";[18]="getAttachment";[19]="getAttachmentParent";[20]="getBoneCount";[21]="getBoneMatrix";[22]="getBoneName";[23]="getBoneParent";[24]="getBonePosition";[25]="getClass";[26]="getColor";[27]="getEyeAngles";[28]="getEyePos";[29]="getForward";[30]="getHealth";[31]="getInertia";[32]="getMass";[33]="getMassCenter";[34]="getMassCenterW";[35]="getMaterial";[36]="getMaterials";[37]="getMaxHealth";[38]="getModel";[39]="getOwner";[40]="getParent";[41]="getPhysMaterial";[42]="getPhysicsObject";[43]="getPhysicsObjectCount";[44]="getPhysicsObjectNum";[45]="getPos";[46]="getRight";[47]="getSkin";[48]="getSubMaterial";[49]="getUp";[50]="getVelocity";[51]="getWaterLevel";[52]="ignite";[53]="isFrozen";[54]="isNPC";[55]="isOnGround";[56]="isPlayer";[57]="isValid";[58]="isValidPhys";[59]="isVehicle";[60]="isWeapon";[61]="isWeldedTo";[62]="linkComponent";[63]="localToWorld";[64]="localToWorldAngles";[65]="lookupAttachment";[66]="lookupBone";[67]="manipulateBoneAngles";[68]="manipulateBonePosition";[69]="manipulateBoneScale";[70]="obbCenter";[71]="obbCenterW";[72]="obbSize";[73]="remove";[74]="removeCollisionListener";[75]="removeTrails";[76]="setAngles";[77]="setBodygroup";[78]="setColor";[79]="setDrawShadow";[80]="setFrozen";[81]="setHologramMesh";[82]="setHologramRenderBounds";[83]="setHologramRenderMatrix";[84]="setInertia";[85]="setMass";[86]="setMaterial";[87]="setNoDraw";[88]="setNocollideAll";[89]="setParent";[90]="setPhysMaterial";[91]="setPos";[92]="setRenderFX";[93]="setRenderMode";[94]="setSkin";[95]="setSolid";[96]="setSubMaterial";[97]="setTrails";[98]="setVelocity";[99]="translateBoneToPhysBone";[100]="translatePhysBoneToBone";[101]="unparent";[102]="worldToLocal";[103]="worldToLocalAngles";["getRight"]={["ret"]="Vector right";["description"]="\
Gets the entity's right vector";["class"]="function";["realm"]="sh";["summary"]="\
Gets the entity's right vector ";["fname"]="getRight";["classlib"]="Entity";["name"]="ents_methods:getRight";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["applyTorque"]={["class"]="function";["description"]="\
Applies torque";["fname"]="applyTorque";["realm"]="sv";["name"]="ents_methods:applyTorque";["summary"]="\
Applies torque ";["private"]=false;["classlib"]="Entity";["param"]={[1]="torque";["torque"]="The torque vector";};};["getPhysicsObjectCount"]={["ret"]="The number of physics objects on the entity";["class"]="function";["description"]="\
Gets the number of physicsobjects of an entity";["fname"]="getPhysicsObjectCount";["realm"]="sh";["name"]="ents_methods:getPhysicsObjectCount";["summary"]="\
Gets the number of physicsobjects of an entity ";["private"]=false;["classlib"]="Entity";["param"]={};};["setSubMaterial"]={["description"]="\
Sets the submaterial of the entity";["class"]="function";["realm"]="sh";["summary"]="\
Sets the submaterial of the entity ";["fname"]="setSubMaterial";["classlib"]="Entity";["name"]="ents_methods:setSubMaterial";["server"]=true;["private"]=false;["client"]=true;["param"]={[1]="index";[2]="material";["material"]=", string, New material name.";["index"]=", number, submaterial index.";};};["setNocollideAll"]={["class"]="function";["description"]="\
Set's the entity to collide with nothing but the world";["fname"]="setNocollideAll";["realm"]="sv";["name"]="ents_methods:setNocollideAll";["summary"]="\
Set's the entity to collide with nothing but the world ";["private"]=false;["classlib"]="Entity";["param"]={[1]="nocollide";["nocollide"]="Whether to collide with nothing except world or not.";};};["getSubMaterial"]={["ret"]="String material";["description"]="\
Gets an entities' submaterial";["server"]=true;["classlib"]="Entity";["realm"]="sh";["class"]="function";["classForced"]=true;["summary"]="\
Gets an entities' submaterial ";["name"]="ents_methods:getSubMaterial";["fname"]="getSubMaterial";["private"]=false;["client"]=true;["param"]={[1]="index";};};["translatePhysBoneToBone"]={["ret"]="The ragdoll bone id";["class"]="function";["description"]="\
Converts a physobject id to the corresponding ragdoll bone id";["fname"]="translatePhysBoneToBone";["realm"]="sh";["name"]="ents_methods:translatePhysBoneToBone";["summary"]="\
Converts a physobject id to the corresponding ragdoll bone id ";["private"]=false;["classlib"]="Entity";["param"]={[1]="boneid";["boneid"]="The physobject id";};};["applyForceCenter"]={["class"]="function";["description"]="\
Applies linear force to the entity";["fname"]="applyForceCenter";["realm"]="sv";["name"]="ents_methods:applyForceCenter";["summary"]="\
Applies linear force to the entity ";["private"]=false;["classlib"]="Entity";["param"]={[1]="vec";["vec"]="The force vector";};};["isValid"]={["ret"]="True if valid, false if not";["description"]="\
Checks if an entity is valid.";["class"]="function";["realm"]="sh";["summary"]="\
Checks if an entity is valid.";["fname"]="isValid";["classlib"]="Entity";["name"]="ents_methods:isValid";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["setHologramRenderMatrix"]={["description"]="\
Sets a hologram entity's rendermatrix";["class"]="function";["realm"]="cl";["fname"]="setHologramRenderMatrix";["summary"]="\
Sets a hologram entity's rendermatrix ";["name"]="ents_methods:setHologramRenderMatrix";["classlib"]="Entity";["private"]=false;["client"]=true;["param"]={[1]="mat";["mat"]="VMatrix to use";};};["manipulateBonePosition"]={["description"]="\
Allows manipulation of a hologram's bones' positions";["class"]="function";["realm"]="cl";["fname"]="manipulateBonePosition";["summary"]="\
Allows manipulation of a hologram's bones' positions ";["name"]="ents_methods:manipulateBonePosition";["classlib"]="Entity";["private"]=false;["client"]=true;["param"]={[1]="bone";[2]="vec";["vec"]="The position it should be manipulated to";["bone"]="The bone ID";};};["setSkin"]={["description"]="\
Sets the skin of the entity";["class"]="function";["realm"]="sh";["summary"]="\
Sets the skin of the entity ";["fname"]="setSkin";["classlib"]="Entity";["name"]="ents_methods:setSkin";["server"]=true;["private"]=false;["client"]=true;["param"]={[1]="skinIndex";["skinIndex"]="Number, Index of the skin to use.";};};["getAngleVelocity"]={["ret"]="The angular velocity as a vector";["description"]="\
Returns the angular velocity of the entity";["class"]="function";["realm"]="sh";["summary"]="\
Returns the angular velocity of the entity ";["fname"]="getAngleVelocity";["classlib"]="Entity";["name"]="ents_methods:getAngleVelocity";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["getSkin"]={["ret"]="Skin number";["description"]="\
Gets the skin number of the entity";["class"]="function";["realm"]="sh";["summary"]="\
Gets the skin number of the entity ";["fname"]="getSkin";["classlib"]="Entity";["name"]="ents_methods:getSkin";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["getAttachmentParent"]={["ret"]="number index of the attachment the entity is parented to or 0";["description"]="\
Gets the attachment index the entity is parented to";["class"]="function";["realm"]="sh";["summary"]="\
Gets the attachment index the entity is parented to ";["fname"]="getAttachmentParent";["classlib"]="Entity";["name"]="ents_methods:getAttachmentParent";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["getClass"]={["ret"]="The string class name";["description"]="\
Returns the class of the entity";["class"]="function";["realm"]="sh";["summary"]="\
Returns the class of the entity ";["fname"]="getClass";["classlib"]="Entity";["name"]="ents_methods:getClass";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["getBoneName"]={["ret"]="Name of the bone";["description"]="\
Returns the name of an entity's bone";["class"]="function";["realm"]="sh";["summary"]="\
Returns the name of an entity's bone ";["fname"]="getBoneName";["classlib"]="Entity";["name"]="ents_methods:getBoneName";["server"]=true;["private"]=false;["client"]=true;["param"]={[1]="bone";["bone"]="Bone index. (def 0)";};};["obbCenter"]={["ret"]="The position vector of the outer bounding box center";["description"]="\
Returns the local position of the entity's outer bounding box";["class"]="function";["realm"]="sh";["summary"]="\
Returns the local position of the entity's outer bounding box ";["fname"]="obbCenter";["classlib"]="Entity";["name"]="ents_methods:obbCenter";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["getWaterLevel"]={["ret"]="The water level. 0 none, 1 slightly, 2 at least halfway, 3 all the way";["description"]="\
Returns how submerged the entity is in water";["class"]="function";["realm"]="sh";["summary"]="\
Returns how submerged the entity is in water ";["fname"]="getWaterLevel";["classlib"]="Entity";["name"]="ents_methods:getWaterLevel";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["getModel"]={["ret"]="Model of the entity";["description"]="\
Gets the model of an entity";["class"]="function";["realm"]="sh";["summary"]="\
Gets the model of an entity ";["fname"]="getModel";["classlib"]="Entity";["name"]="ents_methods:getModel";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["getOwner"]={["ret"]="Owner";["class"]="function";["description"]="\
Gets the owner of the entity";["fname"]="getOwner";["realm"]="sh";["name"]="ents_methods:getOwner";["summary"]="\
Gets the owner of the entity ";["private"]=false;["classlib"]="Entity";["param"]={};};["getBoneCount"]={["ret"]="Number of bones";["description"]="\
Returns the number of an entity's bones";["class"]="function";["realm"]="sh";["summary"]="\
Returns the number of an entity's bones ";["fname"]="getBoneCount";["classlib"]="Entity";["name"]="ents_methods:getBoneCount";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["setSolid"]={["class"]="function";["description"]="\
Sets the entity to be Solid or not. \
For more information please refer to GLua function http://wiki.garrysmod.com/page/Entity/SetNotSolid";["fname"]="setSolid";["realm"]="sv";["name"]="ents_methods:setSolid";["summary"]="\
Sets the entity to be Solid or not.";["private"]=false;["classlib"]="Entity";["param"]={[1]="solid";["solid"]="Boolean, Should the entity be solid?";};};["getEyePos"]={["ret"]={[1]="Eye position of the entity";[2]="In case of a ragdoll, the position of the second eye";};["description"]="\
Gets the entity's eye position";["class"]="function";["realm"]="sh";["summary"]="\
Gets the entity's eye position ";["fname"]="getEyePos";["classlib"]="Entity";["name"]="ents_methods:getEyePos";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["getColor"]={["ret"]="Color";["description"]="\
Gets the color of an entity";["class"]="function";["realm"]="sh";["summary"]="\
Gets the color of an entity ";["fname"]="getColor";["classlib"]="Entity";["name"]="ents_methods:getColor";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["entIndex"]={["ret"]="The numerical index of the entity";["description"]="\
Returns the EntIndex of the entity";["class"]="function";["realm"]="sh";["summary"]="\
Returns the EntIndex of the entity ";["fname"]="entIndex";["classlib"]="Entity";["name"]="ents_methods:entIndex";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["setHologramMesh"]={["description"]="\
Sets a hologram entity's model to a custom Mesh";["class"]="function";["realm"]="cl";["fname"]="setHologramMesh";["summary"]="\
Sets a hologram entity's model to a custom Mesh ";["name"]="ents_methods:setHologramMesh";["classlib"]="Entity";["private"]=false;["client"]=true;["param"]={[1]="mesh";["mesh"]="The mesh to set it to or nil to set back to normal";};};["getInertia"]={["ret"]="The principle moments of inertia as a vector";["description"]="\
Returns the principle moments of inertia of the entity";["class"]="function";["realm"]="sh";["summary"]="\
Returns the principle moments of inertia of the entity ";["fname"]="getInertia";["classlib"]="Entity";["name"]="ents_methods:getInertia";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["isPlayer"]={["ret"]="True if player, false if not";["description"]="\
Checks if an entity is a player.";["class"]="function";["realm"]="sh";["summary"]="\
Checks if an entity is a player.";["fname"]="isPlayer";["classlib"]="Entity";["name"]="ents_methods:isPlayer";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["setInertia"]={["class"]="function";["description"]="\
Sets the entity's inertia";["fname"]="setInertia";["realm"]="sv";["name"]="ents_methods:setInertia";["summary"]="\
Sets the entity's inertia ";["private"]=false;["classlib"]="Entity";["param"]={[1]="vec";["vec"]="Inertia tensor";};};["linkComponent"]={["class"]="function";["description"]="\
Links starfall components to a starfall processor or vehicle. Screen can only connect to processor. HUD can connect to processor and vehicle.";["fname"]="linkComponent";["realm"]="sv";["name"]="ents_methods:linkComponent";["summary"]="\
Links starfall components to a starfall processor or vehicle.";["private"]=false;["classlib"]="Entity";["param"]={[1]="e";["e"]="Entity to link the component to. nil to clear links.";};};["emitSound"]={["class"]="function";["description"]="\
Plays a sound on the entity";["fname"]="emitSound";["realm"]="sv";["name"]="ents_methods:emitSound";["summary"]="\
Plays a sound on the entity ";["private"]=false;["classlib"]="Entity";["param"]={[1]="snd";[2]="lvl";[3]="pitch";[4]="volume";[5]="channel";["pitch"]="pitchPercent=100";["snd"]="string Sound path";["volume"]="volume=1";["lvl"]="number soundLevel=75";["channel"]="channel=CHAN_AUTO";};};["isWeapon"]={["ret"]="True if weapon, false if not";["description"]="\
Checks if an entity is a weapon.";["class"]="function";["realm"]="sh";["summary"]="\
Checks if an entity is a weapon.";["fname"]="isWeapon";["classlib"]="Entity";["name"]="ents_methods:isWeapon";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["setRenderFX"]={["description"]="\
Sets the renderfx of the entity";["realm"]="sh";["class"]="function";["summary"]="\
Sets the renderfx of the entity ";["fname"]="setRenderFX";["classForced"]=true;["classlib"]="Entity";["name"]="ents_methods:setRenderFX";["server"]=true;["private"]=false;["client"]=true;["param"]={[1]="renderfx";["renderfx"]="Number, renderfx to use. http://wiki.garrysmod.com/page/Enums/kRenderFx";};};["ignite"]={["class"]="function";["description"]="\
Ignites an entity";["fname"]="ignite";["realm"]="sv";["name"]="ents_methods:ignite";["summary"]="\
Ignites an entity ";["private"]=false;["classlib"]="Entity";["param"]={[1]="length";[2]="radius";["length"]="How long the fire lasts";["radius"]="(optional) How large the fire hitbox is (entity obb is the max)";};};["breakEnt"]={["class"]="function";["description"]="\
Invokes the entity's breaking animation and removes it.";["fname"]="breakEnt";["realm"]="sv";["name"]="ents_methods:breakEnt";["summary"]="\
Invokes the entity's breaking animation and removes it.";["private"]=false;["classlib"]="Entity";["param"]={};};["getAngleVelocityAngle"]={["ret"]="The angular velocity as an angle";["description"]="\
Returns the angular velocity of the entity";["class"]="function";["realm"]="sh";["summary"]="\
Returns the angular velocity of the entity ";["fname"]="getAngleVelocityAngle";["classlib"]="Entity";["name"]="ents_methods:getAngleVelocityAngle";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["isFrozen"]={["ret"]="True if entity is frozen";["class"]="function";["description"]="\
Checks the entities frozen state";["fname"]="isFrozen";["realm"]="sv";["name"]="ents_methods:isFrozen";["summary"]="\
Checks the entities frozen state ";["private"]=false;["classlib"]="Entity";["param"]={};};["worldToLocal"]={["ret"]="data as local space vector";["description"]="\
Converts a vector in world space to entity local space";["class"]="function";["realm"]="sh";["summary"]="\
Converts a vector in world space to entity local space ";["fname"]="worldToLocal";["classlib"]="Entity";["name"]="ents_methods:worldToLocal";["server"]=true;["private"]=false;["client"]=true;["param"]={[1]="data";["data"]="World space vector";};};["getBoneParent"]={["ret"]="Parent index of the bone";["description"]="\
Returns the parent index of an entity's bone";["class"]="function";["realm"]="sh";["summary"]="\
Returns the parent index of an entity's bone ";["fname"]="getBoneParent";["classlib"]="Entity";["name"]="ents_methods:getBoneParent";["server"]=true;["private"]=false;["client"]=true;["param"]={[1]="bone";["bone"]="Bone index. (def 0)";};};["isValidPhys"]={["ret"]="True if entity has physics";["class"]="function";["description"]="\
Checks whether entity has physics";["fname"]="isValidPhys";["realm"]="sv";["name"]="ents_methods:isValidPhys";["summary"]="\
Checks whether entity has physics ";["private"]=false;["classlib"]="Entity";["param"]={};};["getMassCenterW"]={["ret"]="The position vector of the mass center";["description"]="\
Returns the world position of the entity's mass center";["class"]="function";["realm"]="sh";["summary"]="\
Returns the world position of the entity's mass center ";["fname"]="getMassCenterW";["classlib"]="Entity";["name"]="ents_methods:getMassCenterW";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["enableGravity"]={["class"]="function";["description"]="\
Sets entity gravity";["fname"]="enableGravity";["realm"]="sv";["name"]="ents_methods:enableGravity";["summary"]="\
Sets entity gravity ";["private"]=false;["classlib"]="Entity";["param"]={[1]="grav";["grav"]="Bool should the entity respect gravity?";};};["enableDrag"]={["class"]="function";["description"]="\
Sets the entity drag state";["fname"]="enableDrag";["realm"]="sv";["name"]="ents_methods:enableDrag";["summary"]="\
Sets the entity drag state ";["private"]=false;["classlib"]="Entity";["param"]={[1]="drag";["drag"]="Bool should the entity have air resistence?";};};["getHealth"]={["ret"]="Health of the entity";["description"]="\
Gets the health of an entity";["class"]="function";["realm"]="sh";["summary"]="\
Gets the health of an entity ";["fname"]="getHealth";["classlib"]="Entity";["name"]="ents_methods:getHealth";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["localToWorld"]={["ret"]="data as world space vector";["description"]="\
Converts a vector in entity local space to world space";["class"]="function";["realm"]="sh";["summary"]="\
Converts a vector in entity local space to world space ";["fname"]="localToWorld";["classlib"]="Entity";["name"]="ents_methods:localToWorld";["server"]=true;["private"]=false;["client"]=true;["param"]={[1]="data";["data"]="Local space vector";};};["getAttachment"]={["ret"]="vector position, and angle orientation";["description"]="\
Gets the position and angle of an attachment";["class"]="function";["realm"]="sh";["summary"]="\
Gets the position and angle of an attachment ";["fname"]="getAttachment";["classlib"]="Entity";["name"]="ents_methods:getAttachment";["server"]=true;["private"]=false;["client"]=true;["param"]={[1]="index";["index"]="The index of the attachment";};};["applyForceOffset"]={["class"]="function";["description"]="\
Applies linear force to the entity with an offset";["fname"]="applyForceOffset";["realm"]="sv";["name"]="ents_methods:applyForceOffset";["summary"]="\
Applies linear force to the entity with an offset ";["private"]=false;["classlib"]="Entity";["param"]={[1]="vec";[2]="offset";["offset"]="An optional offset position";["vec"]="The force vector";};};["remove"]={["class"]="function";["description"]="\
Removes an entity";["fname"]="remove";["realm"]="sv";["name"]="ents_methods:remove";["summary"]="\
Removes an entity ";["private"]=false;["classlib"]="Entity";["param"]={};};["unparent"]={["class"]="function";["description"]="\
Unparents the entity from another entity";["fname"]="unparent";["realm"]="sv";["name"]="ents_methods:unparent";["summary"]="\
Unparents the entity from another entity ";["private"]=false;["classlib"]="Entity";["param"]={};};["getAngles"]={["ret"]="The angle";["description"]="\
Returns the angle of the entity";["class"]="function";["realm"]="sh";["summary"]="\
Returns the angle of the entity ";["fname"]="getAngles";["classlib"]="Entity";["name"]="ents_methods:getAngles";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["setPos"]={["class"]="function";["description"]="\
Sets the entitiy's position";["fname"]="setPos";["realm"]="sv";["name"]="ents_methods:setPos";["summary"]="\
Sets the entitiy's position ";["private"]=false;["classlib"]="Entity";["param"]={[1]="vec";["vec"]="New position";};};["lookupAttachment"]={["ret"]="number of the attachment index, or 0 if it doesn't exist";["description"]="\
Gets the attachment index via the entity and it's attachment name";["class"]="function";["realm"]="sh";["summary"]="\
Gets the attachment index via the entity and it's attachment name ";["fname"]="lookupAttachment";["classlib"]="Entity";["name"]="ents_methods:lookupAttachment";["server"]=true;["private"]=false;["client"]=true;["param"]={[1]="name";["name"]="";};};["getBoneMatrix"]={["ret"]="The matrix";["description"]="\
Returns the matrix of the entity's bone";["class"]="function";["realm"]="sh";["summary"]="\
Returns the matrix of the entity's bone ";["fname"]="getBoneMatrix";["classlib"]="Entity";["name"]="ents_methods:getBoneMatrix";["server"]=true;["private"]=false;["client"]=true;["param"]={[1]="bone";["bone"]="Bone index. (def 0)";};};["setTrails"]={["class"]="function";["description"]="\
Adds a trail to the entity with the specified attributes.";["fname"]="setTrails";["realm"]="sv";["name"]="ents_methods:setTrails";["summary"]="\
Adds a trail to the entity with the specified attributes.";["private"]=false;["classlib"]="Entity";["param"]={[1]="startSize";[2]="endSize";[3]="length";[4]="material";[5]="color";[6]="attachmentID";[7]="additive";["startSize"]="The start size of the trail";["attachmentID"]="Optional attachmentid the trail should attach to";["length"]="The length size of the trail";["color"]="The color of the trail";["material"]="The material of the trail";["endSize"]="The end size of the trail";["additive"]="If the trail's rendering is additive";};};["removeCollisionListener"]={["class"]="function";["description"]="\
Removes a collision listening hook from the entity so that a new one can be added";["fname"]="removeCollisionListener";["realm"]="sv";["name"]="ents_methods:removeCollisionListener";["summary"]="\
Removes a collision listening hook from the entity so that a new one can be added ";["private"]=false;["classlib"]="Entity";["param"]={};};["isOnGround"]={["ret"]="Boolean if it's flag is set or not";["description"]="\
Checks if the entity ONGROUND flag is set";["class"]="function";["realm"]="sh";["summary"]="\
Checks if the entity ONGROUND flag is set ";["fname"]="isOnGround";["classlib"]="Entity";["name"]="ents_methods:isOnGround";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["isWeldedTo"]={["class"]="function";["description"]="\
Gets what the entity is welded to";["fname"]="isWeldedTo";["realm"]="sv";["name"]="ents_methods:isWeldedTo";["summary"]="\
Gets what the entity is welded to ";["private"]=false;["classlib"]="Entity";["param"]={};};["enableSphere"]={["class"]="function";["description"]="\
Sets the physics of an entity to be a sphere";["fname"]="enableSphere";["realm"]="sv";["name"]="ents_methods:enableSphere";["summary"]="\
Sets the physics of an entity to be a sphere ";["private"]=false;["classlib"]="Entity";["param"]={[1]="enabled";["enabled"]="Bool should the entity be spherical?";};};["setNoDraw"]={["description"]="\
Sets the whether an entity should be drawn or not";["class"]="function";["realm"]="sh";["summary"]="\
Sets the whether an entity should be drawn or not ";["fname"]="setNoDraw";["classlib"]="Entity";["name"]="ents_methods:setNoDraw";["server"]=true;["private"]=false;["client"]=true;["param"]={[1]="draw";["draw"]="Whether to draw the entity or not.";};};["setFrozen"]={["class"]="function";["description"]="\
Sets the entity frozen state";["fname"]="setFrozen";["realm"]="sv";["name"]="ents_methods:setFrozen";["summary"]="\
Sets the entity frozen state ";["private"]=false;["classlib"]="Entity";["param"]={[1]="freeze";["freeze"]="Should the entity be frozen?";};};["setDrawShadow"]={["class"]="function";["description"]="\
Sets whether an entity's shadow should be drawn";["fname"]="setDrawShadow";["realm"]="sv";["name"]="ents_methods:setDrawShadow";["summary"]="\
Sets whether an entity's shadow should be drawn ";["private"]=false;["classlib"]="Entity";["param"]={[1]="draw";[2]="ply";["ply"]="Optional player argument to set only for that player. Can also be table of players.";};};["getEyeAngles"]={["ret"]="Angles of the entity's eyes";["description"]="\
Gets the entitiy's eye angles";["class"]="function";["realm"]="sh";["summary"]="\
Gets the entitiy's eye angles ";["fname"]="getEyeAngles";["classlib"]="Entity";["name"]="ents_methods:getEyeAngles";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["applyAngForce"]={["class"]="function";["description"]="\
Applies angular force to the entity";["fname"]="applyAngForce";["realm"]="sv";["name"]="ents_methods:applyAngForce";["summary"]="\
Applies angular force to the entity ";["private"]=false;["classlib"]="Entity";["param"]={[1]="ang";["ang"]="The force angle";};};["getMaterials"]={["ret"]="Material";["description"]="\
Gets an entities' material list";["server"]=true;["classlib"]="Entity";["realm"]="sh";["class"]="function";["classForced"]=true;["summary"]="\
Gets an entities' material list ";["name"]="ents_methods:getMaterials";["fname"]="getMaterials";["private"]=false;["client"]=true;["param"]={};};["extinguish"]={["class"]="function";["description"]="\
Extinguishes an entity";["fname"]="extinguish";["realm"]="sv";["name"]="ents_methods:extinguish";["summary"]="\
Extinguishes an entity ";["private"]=false;["classlib"]="Entity";["param"]={};};["getForward"]={["ret"]="Vector forward";["description"]="\
Gets the entity's forward vector";["class"]="function";["realm"]="sh";["summary"]="\
Gets the entity's forward vector ";["fname"]="getForward";["classlib"]="Entity";["name"]="ents_methods:getForward";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["worldToLocalAngles"]={["ret"]="data as local space angle";["description"]="\
Converts an angle in world space to entity local space";["class"]="function";["realm"]="sh";["summary"]="\
Converts an angle in world space to entity local space ";["fname"]="worldToLocalAngles";["classlib"]="Entity";["name"]="ents_methods:worldToLocalAngles";["server"]=true;["private"]=false;["client"]=true;["param"]={[1]="data";["data"]="World space angle";};};["getVelocity"]={["ret"]="The velocity vector";["description"]="\
Returns the velocity of the entity";["class"]="function";["realm"]="sh";["summary"]="\
Returns the velocity of the entity ";["fname"]="getVelocity";["classlib"]="Entity";["name"]="ents_methods:getVelocity";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["manipulateBoneAngles"]={["description"]="\
Allows manipulation of a hologram's bones' angles";["class"]="function";["realm"]="cl";["fname"]="manipulateBoneAngles";["summary"]="\
Allows manipulation of a hologram's bones' angles ";["name"]="ents_methods:manipulateBoneAngles";["classlib"]="Entity";["private"]=false;["client"]=true;["param"]={[1]="bone";[2]="ang";["ang"]="The angle it should be manipulated to";["bone"]="The bone ID";};};["setColor"]={["description"]="\
Sets the color of the entity";["class"]="function";["realm"]="sh";["summary"]="\
Sets the color of the entity ";["fname"]="setColor";["classlib"]="Entity";["name"]="ents_methods:setColor";["server"]=true;["private"]=false;["client"]=true;["param"]={[1]="clr";["clr"]="New color";};};["isNPC"]={["ret"]="True if npc, false if not";["description"]="\
Checks if an entity is an npc.";["class"]="function";["realm"]="sh";["summary"]="\
Checks if an entity is an npc.";["fname"]="isNPC";["classlib"]="Entity";["name"]="ents_methods:isNPC";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["setAngles"]={["class"]="function";["description"]="\
Sets the entity's angles";["fname"]="setAngles";["realm"]="sv";["name"]="ents_methods:setAngles";["summary"]="\
Sets the entity's angles ";["private"]=false;["classlib"]="Entity";["param"]={[1]="ang";["ang"]="New angles";};};["enableMotion"]={["class"]="function";["description"]="\
Sets the entity movement state";["fname"]="enableMotion";["realm"]="sv";["name"]="ents_methods:enableMotion";["summary"]="\
Sets the entity movement state ";["private"]=false;["classlib"]="Entity";["param"]={[1]="move";["move"]="Bool should the entity move?";};};["setBodygroup"]={["description"]="\
Sets the bodygroup of the entity";["class"]="function";["realm"]="sh";["summary"]="\
Sets the bodygroup of the entity ";["fname"]="setBodygroup";["classlib"]="Entity";["name"]="ents_methods:setBodygroup";["server"]=true;["private"]=false;["client"]=true;["param"]={[1]="bodygroup";[2]="value";["bodygroup"]="Number, The ID of the bodygroup you're setting.";["value"]="Number, The value you're setting the bodygroup to.";};};["setHologramRenderBounds"]={["description"]="\
Sets a hologram entity's renderbounds";["class"]="function";["realm"]="cl";["fname"]="setHologramRenderBounds";["summary"]="\
Sets a hologram entity's renderbounds ";["name"]="ents_methods:setHologramRenderBounds";["classlib"]="Entity";["private"]=false;["client"]=true;["param"]={[1]="mins";[2]="maxs";["maxs"]="The upper bounding corner coordinate local to the hologram";["mins"]="The lower bounding corner coordinate local to the hologram";};};["manipulateBoneScale"]={["description"]="\
Allows manipulation of a hologram's bones' scale";["class"]="function";["realm"]="cl";["fname"]="manipulateBoneScale";["summary"]="\
Allows manipulation of a hologram's bones' scale ";["name"]="ents_methods:manipulateBoneScale";["classlib"]="Entity";["private"]=false;["client"]=true;["param"]={[1]="bone";[2]="vec";["vec"]="The scale it should be manipulated to";["bone"]="The bone ID";};};["setMaterial"]={["description"]="\
Sets the material of the entity";["class"]="function";["realm"]="sh";["summary"]="\
Sets the material of the entity ";["fname"]="setMaterial";["classlib"]="Entity";["name"]="ents_methods:setMaterial";["server"]=true;["private"]=false;["client"]=true;["param"]={[1]="material";["material"]=", string, New material name.";};};["getMass"]={["ret"]="The numerical mass";["description"]="\
Returns the mass of the entity";["class"]="function";["realm"]="sh";["summary"]="\
Returns the mass of the entity ";["fname"]="getMass";["classlib"]="Entity";["name"]="ents_methods:getMass";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["getMaxHealth"]={["ret"]="Max Health of the entity";["description"]="\
Gets the max health of an entity";["class"]="function";["realm"]="sh";["summary"]="\
Gets the max health of an entity ";["fname"]="getMaxHealth";["classlib"]="Entity";["name"]="ents_methods:getMaxHealth";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["addCollisionListener"]={["class"]="function";["description"]="\
Allows detecting collisions on an entity. You can only do this once for the entity's entire lifespan so use it wisely.";["fname"]="addCollisionListener";["realm"]="sv";["name"]="ents_methods:addCollisionListener";["summary"]="\
Allows detecting collisions on an entity.";["private"]=false;["classlib"]="Entity";["param"]={[1]="func";["func"]="The callback function with argument, table collsiondata, http://wiki.garrysmod.com/page/Structures/CollisionData";};};["setVelocity"]={["class"]="function";["description"]="\
Sets the entity's linear velocity";["fname"]="setVelocity";["realm"]="sv";["name"]="ents_methods:setVelocity";["summary"]="\
Sets the entity's linear velocity ";["private"]=false;["classlib"]="Entity";["param"]={[1]="vel";["vel"]="New velocity";};};["translateBoneToPhysBone"]={["ret"]="The physobj id";["class"]="function";["description"]="\
Converts a ragdoll bone id to the corresponding physobject id";["fname"]="translateBoneToPhysBone";["realm"]="sh";["name"]="ents_methods:translateBoneToPhysBone";["summary"]="\
Converts a ragdoll bone id to the corresponding physobject id ";["private"]=false;["classlib"]="Entity";["param"]={[1]="boneid";["boneid"]="The ragdoll boneid";};};["applyDamage"]={["class"]="function";["description"]="\
Applies damage to an entity";["fname"]="applyDamage";["realm"]="sv";["name"]="ents_methods:applyDamage";["summary"]="\
Applies damage to an entity ";["private"]=false;["classlib"]="Entity";["param"]={[1]="amt";[2]="attacker";[3]="inflictor";["inflictor"]="damage inflictor";["attacker"]="damage attacker";["amt"]="damage amount";};};["getPhysMaterial"]={["ret"]="the physical material";["class"]="function";["description"]="\
Get the physical material of the entity";["fname"]="getPhysMaterial";["realm"]="sv";["name"]="ents_methods:getPhysMaterial";["summary"]="\
Get the physical material of the entity ";["private"]=false;["classlib"]="Entity";["param"]={};};["getUp"]={["ret"]="Vector up";["description"]="\
Gets the entity's up vector";["class"]="function";["realm"]="sh";["summary"]="\
Gets the entity's up vector ";["fname"]="getUp";["classlib"]="Entity";["name"]="ents_methods:getUp";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["getBonePosition"]={["ret"]={[1]="Position of the bone";[2]="Angle of the bone";};["description"]="\
Returns the bone's position and angle in world coordinates";["class"]="function";["realm"]="sh";["summary"]="\
Returns the bone's position and angle in world coordinates ";["fname"]="getBonePosition";["classlib"]="Entity";["name"]="ents_methods:getBonePosition";["server"]=true;["private"]=false;["client"]=true;["param"]={[1]="bone";["bone"]="Bone index. (def 0)";};};["localToWorldAngles"]={["ret"]="data as world space angle";["description"]="\
Converts an angle in entity local space to world space";["class"]="function";["realm"]="sh";["summary"]="\
Converts an angle in entity local space to world space ";["fname"]="localToWorldAngles";["classlib"]="Entity";["name"]="ents_methods:localToWorldAngles";["server"]=true;["private"]=false;["client"]=true;["param"]={[1]="data";["data"]="Local space angle";};};["setPhysMaterial"]={["class"]="function";["description"]="\
Sets the physical material of the entity";["fname"]="setPhysMaterial";["realm"]="sv";["name"]="ents_methods:setPhysMaterial";["summary"]="\
Sets the physical material of the entity ";["private"]=false;["classlib"]="Entity";["param"]={[1]="mat";["mat"]="Material to use";};};["getMaterial"]={["ret"]="String material";["description"]="\
Gets an entities' material";["server"]=true;["classlib"]="Entity";["realm"]="sh";["class"]="function";["classForced"]=true;["summary"]="\
Gets an entities' material ";["name"]="ents_methods:getMaterial";["fname"]="getMaterial";["private"]=false;["client"]=true;["param"]={};};["obbSize"]={["ret"]="The outer bounding box size";["description"]="\
Returns the x, y, z size of the entity's outer bounding box (local to the entity)";["class"]="function";["realm"]="sh";["summary"]="\
Returns the x, y, z size of the entity's outer bounding box (local to the entity) ";["fname"]="obbSize";["classlib"]="Entity";["name"]="ents_methods:obbSize";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["lookupBone"]={["ret"]="The bone index";["description"]="\
Returns the ragdoll bone index given a bone name";["class"]="function";["realm"]="sh";["summary"]="\
Returns the ragdoll bone index given a bone name ";["fname"]="lookupBone";["classlib"]="Entity";["name"]="ents_methods:lookupBone";["server"]=true;["private"]=false;["client"]=true;["param"]={[1]="name";["name"]="The bone's string name";};};["getPos"]={["ret"]="The position vector";["description"]="\
Returns the position of the entity";["class"]="function";["realm"]="sh";["summary"]="\
Returns the position of the entity ";["fname"]="getPos";["classlib"]="Entity";["name"]="ents_methods:getPos";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["removeTrails"]={["class"]="function";["description"]="\
Removes trails from the entity";["fname"]="removeTrails";["realm"]="sv";["name"]="ents_methods:removeTrails";["summary"]="\
Removes trails from the entity ";["private"]=false;["classlib"]="Entity";["param"]={};};["getMassCenter"]={["ret"]="The position vector of the mass center";["description"]="\
Returns the local position of the entity's mass center";["class"]="function";["realm"]="sh";["summary"]="\
Returns the local position of the entity's mass center ";["fname"]="getMassCenter";["classlib"]="Entity";["name"]="ents_methods:getMassCenter";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["obbCenterW"]={["ret"]="The position vector of the outer bounding box center";["description"]="\
Returns the world position of the entity's outer bounding box";["class"]="function";["realm"]="sh";["summary"]="\
Returns the world position of the entity's outer bounding box ";["fname"]="obbCenterW";["classlib"]="Entity";["name"]="ents_methods:obbCenterW";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["setParent"]={["class"]="function";["description"]="\
Parents the entity to another entity";["fname"]="setParent";["realm"]="sv";["name"]="ents_methods:setParent";["summary"]="\
Parents the entity to another entity ";["private"]=false;["classlib"]="Entity";["param"]={[1]="ent";[2]="attachment";["attachment"]="Optional string attachment name to parent to";["ent"]="Entity to parent to";};};["getPhysicsObjectNum"]={["ret"]="The physics object of the entity";["class"]="function";["description"]="\
Gets a physics objects of an entity";["fname"]="getPhysicsObjectNum";["realm"]="sh";["name"]="ents_methods:getPhysicsObjectNum";["summary"]="\
Gets a physics objects of an entity ";["private"]=false;["classlib"]="Entity";["param"]={[1]="id";["id"]="The physics object id (starts at 0)";};};["setMass"]={["class"]="function";["description"]="\
Sets the entity's mass";["fname"]="setMass";["realm"]="sv";["name"]="ents_methods:setMass";["summary"]="\
Sets the entity's mass ";["private"]=false;["classlib"]="Entity";["param"]={[1]="mass";["mass"]="number mass";};};["getParent"]={["ret"]="Entity's parent or nil";["description"]="\
Gets the parent of an entity";["class"]="function";["realm"]="sh";["summary"]="\
Gets the parent of an entity ";["fname"]="getParent";["classlib"]="Entity";["name"]="ents_methods:getParent";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["isVehicle"]={["ret"]="True if vehicle, false if not";["description"]="\
Checks if an entity is a vehicle.";["class"]="function";["realm"]="sh";["summary"]="\
Checks if an entity is a vehicle.";["fname"]="isVehicle";["classlib"]="Entity";["name"]="ents_methods:isVehicle";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["setRenderMode"]={["description"]="\
Sets the render mode of the entity";["realm"]="sh";["class"]="function";["summary"]="\
Sets the render mode of the entity ";["fname"]="setRenderMode";["classForced"]=true;["classlib"]="Entity";["name"]="ents_methods:setRenderMode";["server"]=true;["private"]=false;["client"]=true;["param"]={[1]="rendermode";["rendermode"]="Number, rendermode to use. http://wiki.garrysmod.com/page/Enums/RENDERMODE";};};["getPhysicsObject"]={["ret"]="The main physics object of the entity";["class"]="function";["description"]="\
Gets the main physics objects of an entity";["fname"]="getPhysicsObject";["realm"]="sh";["name"]="ents_methods:getPhysicsObject";["summary"]="\
Gets the main physics objects of an entity ";["private"]=false;["classlib"]="Entity";["param"]={};};};};["Vehicle"]={["typtbl"]="vehicle_methods";["class"]="class";["fields"]={};["name"]="Vehicle";["summary"]="\
Vehicle type ";["description"]="\
Vehicle type";["methods"]={[1]="ejectDriver";[2]="getDriver";[3]="getPassenger";["getDriver"]={["ret"]="Driver of vehicle";["description"]="\
Returns the driver of the vehicle";["class"]="function";["realm"]="sv";["fname"]="getDriver";["summary"]="\
Returns the driver of the vehicle ";["name"]="vehicle_methods:getDriver";["classlib"]="Vehicle";["private"]=false;["server"]=true;["param"]={};};["ejectDriver"]={["description"]="\
Ejects the driver of the vehicle";["class"]="function";["realm"]="sv";["fname"]="ejectDriver";["summary"]="\
Ejects the driver of the vehicle ";["name"]="vehicle_methods:ejectDriver";["classlib"]="Vehicle";["private"]=false;["server"]=true;["param"]={};};["getPassenger"]={["ret"]="amount of ammo";["description"]="\
Returns a passenger of a vehicle";["class"]="function";["realm"]="sv";["fname"]="getPassenger";["summary"]="\
Returns a passenger of a vehicle ";["name"]="vehicle_methods:getPassenger";["classlib"]="Vehicle";["private"]=false;["server"]=true;["param"]={[1]="n";["n"]="The index of the passenger to get";};};};};["Mesh"]={["typtbl"]="mesh_methods";["class"]="class";["description"]="\
Mesh type";["fields"]={};["name"]="Mesh";["summary"]="\
Mesh type ";["client"]=true;["methods"]={[1]="destroy";[2]="draw";["draw"]={["class"]="function";["description"]="\
Draws the mesh. Must be in a 3D rendering context.";["fname"]="draw";["realm"]="cl";["name"]="mesh_methods:draw";["summary"]="\
Draws the mesh.";["private"]=false;["classlib"]="Mesh";["param"]={};};["destroy"]={["class"]="function";["description"]="\
Frees the mesh from memory";["fname"]="destroy";["realm"]="cl";["name"]="mesh_methods:destroy";["summary"]="\
Frees the mesh from memory ";["private"]=false;["classlib"]="Mesh";["param"]={};};};};["Sound"]={["typtbl"]="sound_methods";["class"]="class";["description"]="\
Sound type";["summary"]="\
Sound type ";["fields"]={};["name"]="Sound";["server"]=true;["client"]=true;["methods"]={[1]="isPlaying";[2]="play";[3]="setPitch";[4]="setSoundLevel";[5]="setVolume";[6]="stop";["setSoundLevel"]={["class"]="function";["description"]="\
Sets the sound level in dB.";["fname"]="setSoundLevel";["realm"]="sh";["name"]="sound_methods:setSoundLevel";["summary"]="\
Sets the sound level in dB.";["private"]=false;["classlib"]="Sound";["param"]={[1]="level";["level"]="dB level, see <a href='https://developer.valvesoftware.com/wiki/Soundscripts#SoundLevel'> Vale Dev Wiki</a>, for information on the value to use.";};};["stop"]={["class"]="function";["description"]="\
Stops the sound from being played.";["fname"]="stop";["realm"]="sh";["name"]="sound_methods:stop";["summary"]="\
Stops the sound from being played.";["private"]=false;["classlib"]="Sound";["param"]={[1]="fade";["fade"]="Time in seconds to fade out, if nil or 0 the sound stops instantly.";};};["isPlaying"]={["class"]="function";["description"]="\
Returns whether the sound is being played.";["fname"]="isPlaying";["realm"]="sh";["name"]="sound_methods:isPlaying";["summary"]="\
Returns whether the sound is being played.";["private"]=false;["classlib"]="Sound";["param"]={};};["setVolume"]={["class"]="function";["description"]="\
Sets the volume of the sound.";["fname"]="setVolume";["realm"]="sh";["name"]="sound_methods:setVolume";["summary"]="\
Sets the volume of the sound.";["private"]=false;["classlib"]="Sound";["param"]={[1]="vol";[2]="fade";["vol"]="Volume to set to, between 0 and 1.";["fade"]="Time in seconds to transition to this new volume.";};};["setPitch"]={["class"]="function";["description"]="\
Sets the pitch of the sound.";["fname"]="setPitch";["realm"]="sh";["name"]="sound_methods:setPitch";["summary"]="\
Sets the pitch of the sound.";["private"]=false;["classlib"]="Sound";["param"]={[1]="pitch";[2]="fade";["pitch"]="Pitch to set to, between 0 and 255.";["fade"]="Time in seconds to transition to this new pitch.";};};["play"]={["class"]="function";["description"]="\
Starts to play the sound.";["fname"]="play";["realm"]="sh";["name"]="sound_methods:play";["summary"]="\
Starts to play the sound.";["private"]=false;["classlib"]="Sound";["param"]={};};};};["VMatrix"]={["typtbl"]="vmatrix_methods";["class"]="class";["fields"]={};["name"]="VMatrix";["summary"]="\
VMatrix type ";["description"]="\
VMatrix type";["methods"]={[1]="getAngles";[2]="getAxisAngle";[3]="getField";[4]="getForward";[5]="getInverse";[6]="getInverseTR";[7]="getRight";[8]="getScale";[9]="getTranslation";[10]="getTransposed";[11]="getUp";[12]="invert";[13]="invertTR";[14]="isIdentity";[15]="isRotationMatrix";[16]="rotate";[17]="scale";[18]="scaleTranslation";[19]="set";[20]="setAngles";[21]="setField";[22]="setForward";[23]="setIdentity";[24]="setRight";[25]="setScale";[26]="setTranslation";[27]="setUp";[28]="toTable";[29]="translate";[30]="transpose";["getTransposed"]={["ret"]="Transposed matrix";["class"]="function";["description"]="\
Returns the transposed matrix";["fname"]="getTransposed";["realm"]="sh";["name"]="vmatrix_methods:getTransposed";["summary"]="\
Returns the transposed matrix ";["private"]=false;["classlib"]="VMatrix";["param"]={};};["getUp"]={["ret"]="Translation";["class"]="function";["description"]="\
Returns up vector of matrix. Third matrix column";["fname"]="getUp";["realm"]="sh";["name"]="vmatrix_methods:getUp";["summary"]="\
Returns up vector of matrix.";["private"]=false;["classlib"]="VMatrix";["param"]={};};["scale"]={["class"]="function";["description"]="\
Scale the matrix";["fname"]="scale";["realm"]="sh";["name"]="vmatrix_methods:scale";["summary"]="\
Scale the matrix ";["private"]=false;["classlib"]="VMatrix";["param"]={[1]="vec";["vec"]="Vector to scale by";};};["getScale"]={["ret"]="Scale";["class"]="function";["description"]="\
Returns scale";["fname"]="getScale";["realm"]="sh";["name"]="vmatrix_methods:getScale";["summary"]="\
Returns scale ";["private"]=false;["classlib"]="VMatrix";["param"]={};};["getField"]={["ret"]="Value of the specified field";["class"]="function";["description"]="\
Returns a specific field in the matrix";["fname"]="getField";["realm"]="sh";["name"]="vmatrix_methods:getField";["summary"]="\
Returns a specific field in the matrix ";["private"]=false;["classlib"]="VMatrix";["param"]={[1]="row";[2]="column";["column"]="A number from 1 to 4";["row"]="A number from 1 to 4";};};["getAngles"]={["ret"]="Angles";["class"]="function";["description"]="\
Returns angles";["fname"]="getAngles";["realm"]="sh";["name"]="vmatrix_methods:getAngles";["summary"]="\
Returns angles ";["private"]=false;["classlib"]="VMatrix";["param"]={};};["getRight"]={["ret"]="Translation";["class"]="function";["description"]="\
Returns right vector of matrix. Negated second matrix column";["fname"]="getRight";["realm"]="sh";["name"]="vmatrix_methods:getRight";["summary"]="\
Returns right vector of matrix.";["private"]=false;["classlib"]="VMatrix";["param"]={};};["transpose"]={["class"]="function";["description"]="\
Transposes the matrix";["fname"]="transpose";["realm"]="sh";["name"]="vmatrix_methods:transpose";["summary"]="\
Transposes the matrix ";["private"]=false;["classlib"]="VMatrix";["param"]={};};["isIdentity"]={["ret"]="bool True/False";["class"]="function";["description"]="\
Returns whether the matrix is equal to Identity matrix or not";["fname"]="isIdentity";["realm"]="sh";["name"]="vmatrix_methods:isIdentity";["summary"]="\
Returns whether the matrix is equal to Identity matrix or not ";["private"]=false;["classlib"]="VMatrix";["param"]={};};["translate"]={["class"]="function";["description"]="\
Translate the matrix";["fname"]="translate";["realm"]="sh";["name"]="vmatrix_methods:translate";["summary"]="\
Translate the matrix ";["private"]=false;["classlib"]="VMatrix";["param"]={[1]="vec";["vec"]="Vector to translate by";};};["getAxisAngle"]={["ret"]={[1]="The axis of rotation";[2]="The angle of rotation";};["class"]="function";["description"]="\
Gets the rotation axis and angle of rotation of the rotation matrix";["fname"]="getAxisAngle";["realm"]="sh";["name"]="vmatrix_methods:getAxisAngle";["summary"]="\
Gets the rotation axis and angle of rotation of the rotation matrix ";["private"]=false;["classlib"]="VMatrix";["param"]={};};["setField"]={["class"]="function";["description"]="\
Sets a specific field in the matrix";["fname"]="setField";["realm"]="sh";["name"]="vmatrix_methods:setField";["summary"]="\
Sets a specific field in the matrix ";["private"]=false;["classlib"]="VMatrix";["param"]={[1]="row";[2]="column";[3]="value";["value"]="Value to set";["row"]="A number from 1 to 4";["column"]="A number from 1 to 4";};};["invert"]={["ret"]="bool Whether the matrix was inverted or not";["class"]="function";["description"]="\
Inverts the matrix. Inverting the matrix will fail if its determinant is 0 or close to 0";["fname"]="invert";["realm"]="sh";["name"]="vmatrix_methods:invert";["summary"]="\
Inverts the matrix.";["private"]=false;["classlib"]="VMatrix";["param"]={};};["scaleTranslation"]={["class"]="function";["description"]="\
Scales the absolute translation";["fname"]="scaleTranslation";["realm"]="sh";["name"]="vmatrix_methods:scaleTranslation";["summary"]="\
Scales the absolute translation ";["private"]=false;["classlib"]="VMatrix";["param"]={[1]="num";["num"]="Amount to scale by";};};["setIdentity"]={["class"]="function";["description"]="\
Initializes the matrix as Identity matrix";["fname"]="setIdentity";["realm"]="sh";["name"]="vmatrix_methods:setIdentity";["summary"]="\
Initializes the matrix as Identity matrix ";["private"]=false;["classlib"]="VMatrix";["param"]={};};["setScale"]={["class"]="function";["description"]="\
Sets the scale";["fname"]="setScale";["realm"]="sh";["name"]="vmatrix_methods:setScale";["summary"]="\
Sets the scale ";["private"]=false;["classlib"]="VMatrix";["param"]={[1]="vec";["vec"]="New scale";};};["getInverse"]={["ret"]="Inverted matrix";["class"]="function";["description"]="\
Returns an inverted matrix. Inverting the matrix will fail if its determinant is 0 or close to 0";["fname"]="getInverse";["realm"]="sh";["name"]="vmatrix_methods:getInverse";["summary"]="\
Returns an inverted matrix.";["private"]=false;["classlib"]="VMatrix";["param"]={};};["set"]={["class"]="function";["description"]="\
Copies the values from the second matrix to the first matrix. Self-Modifies";["fname"]="set";["realm"]="sh";["name"]="vmatrix_methods:set";["summary"]="\
Copies the values from the second matrix to the first matrix.";["private"]=false;["classlib"]="VMatrix";["param"]={[1]="src";["src"]="Second matrix";};};["isRotationMatrix"]={["ret"]="bool True/False";["class"]="function";["description"]="\
Returns whether the matrix is a rotation matrix or not. Checks if the forward, right and up vectors are orthogonal and normalized.";["fname"]="isRotationMatrix";["realm"]="sh";["name"]="vmatrix_methods:isRotationMatrix";["summary"]="\
Returns whether the matrix is a rotation matrix or not.";["private"]=false;["classlib"]="VMatrix";["param"]={};};["setRight"]={["class"]="function";["description"]="\
Sets the right direction of the matrix. Negated second column";["fname"]="setRight";["realm"]="sh";["name"]="vmatrix_methods:setRight";["summary"]="\
Sets the right direction of the matrix.";["private"]=false;["classlib"]="VMatrix";["param"]={[1]="right";["right"]="The right vector";};};["setAngles"]={["class"]="function";["description"]="\
Sets the angles";["fname"]="setAngles";["realm"]="sh";["name"]="vmatrix_methods:setAngles";["summary"]="\
Sets the angles ";["private"]=false;["classlib"]="VMatrix";["param"]={[1]="ang";["ang"]="New angles";};};["setForward"]={["class"]="function";["description"]="\
Sets the forward direction of the matrix. First column";["fname"]="setForward";["realm"]="sh";["name"]="vmatrix_methods:setForward";["summary"]="\
Sets the forward direction of the matrix.";["private"]=false;["classlib"]="VMatrix";["param"]={[1]="forward";["forward"]="The forward vector";};};["setTranslation"]={["class"]="function";["description"]="\
Sets the translation";["fname"]="setTranslation";["realm"]="sh";["name"]="vmatrix_methods:setTranslation";["summary"]="\
Sets the translation ";["private"]=false;["classlib"]="VMatrix";["param"]={[1]="vec";["vec"]="New translation";};};["getTranslation"]={["ret"]="Translation";["class"]="function";["description"]="\
Returns translation";["fname"]="getTranslation";["realm"]="sh";["name"]="vmatrix_methods:getTranslation";["summary"]="\
Returns translation ";["private"]=false;["classlib"]="VMatrix";["param"]={};};["toTable"]={["ret"]="The 4x4 table";["class"]="function";["description"]="\
Converts the matrix to a 4x4 table";["fname"]="toTable";["realm"]="sh";["name"]="vmatrix_methods:toTable";["summary"]="\
Converts the matrix to a 4x4 table ";["private"]=false;["classlib"]="VMatrix";["param"]={};};["getForward"]={["ret"]="Translation";["class"]="function";["description"]="\
Returns forward vector of matrix. First matrix column";["fname"]="getForward";["realm"]="sh";["name"]="vmatrix_methods:getForward";["summary"]="\
Returns forward vector of matrix.";["private"]=false;["classlib"]="VMatrix";["param"]={};};["invertTR"]={["class"]="function";["description"]="\
Inverts the matrix efficiently for translations and rotations";["fname"]="invertTR";["realm"]="sh";["name"]="vmatrix_methods:invertTR";["summary"]="\
Inverts the matrix efficiently for translations and rotations ";["private"]=false;["classlib"]="VMatrix";["param"]={};};["rotate"]={["class"]="function";["description"]="\
Rotate the matrix";["fname"]="rotate";["realm"]="sh";["name"]="vmatrix_methods:rotate";["summary"]="\
Rotate the matrix ";["private"]=false;["classlib"]="VMatrix";["param"]={[1]="ang";["ang"]="Angle to rotate by";};};["getInverseTR"]={["ret"]="Inverted matrix";["class"]="function";["description"]="\
Returns an inverted matrix. Efficiently for translations and rotations";["fname"]="getInverseTR";["realm"]="sh";["name"]="vmatrix_methods:getInverseTR";["summary"]="\
Returns an inverted matrix.";["private"]=false;["classlib"]="VMatrix";["param"]={};};["setUp"]={["class"]="function";["description"]="\
Sets the up direction of the matrix. Third column";["fname"]="setUp";["realm"]="sh";["name"]="vmatrix_methods:setUp";["summary"]="\
Sets the up direction of the matrix.";["private"]=false;["classlib"]="VMatrix";["param"]={[1]="up";["up"]="The up vector";};};};};["Particle"]={["typtbl"]="particle_methods";["class"]="class";["description"]="\
Particle type";["fields"]={};["name"]="Particle";["summary"]="\
Particle type ";["client"]=true;["methods"]={[1]="destroy";[2]="isFinished";[3]="isValid";[4]="restart";[5]="setControlPoint";[6]="setControlPointEntity";[7]="setControlPointParent";[8]="setForwardVector";[9]="setRightVector";[10]="setSortOrigin";[11]="setUpVector";[12]="startEmission";[13]="stopEmission";["destroy"]={["class"]="function";["description"]="\
Stops emission of the particle and destroys the object.";["fname"]="destroy";["realm"]="cl";["name"]="particle_methods:destroy";["summary"]="\
Stops emission of the particle and destroys the object.";["private"]=false;["classlib"]="Particle";["param"]={};};["isValid"]={["ret"]="Is valid or not";["class"]="function";["description"]="\
Gets if the particle is valid or not.";["fname"]="isValid";["realm"]="cl";["name"]="particle_methods:isValid";["summary"]="\
Gets if the particle is valid or not.";["private"]=false;["classlib"]="Particle";["param"]={};};["restart"]={["class"]="function";["description"]="\
Restarts emission of the particle.";["fname"]="restart";["realm"]="cl";["name"]="particle_methods:restart";["summary"]="\
Restarts emission of the particle.";["private"]=false;["classlib"]="Particle";["param"]={};};["setRightVector"]={["class"]="function";["description"]="\
Sets the right direction for given control point.";["fname"]="setRightVector";["realm"]="cl";["name"]="particle_methods:setRightVector";["summary"]="\
Sets the right direction for given control point.";["private"]=false;["classlib"]="Particle";["param"]={[1]="id";[2]="value";[3]="number";[4]="vector";["number"]="Control Point ID (0-63)";["vector"]="Right";};};["setUpVector"]={["class"]="function";["description"]="\
Sets the right direction for given control point.";["fname"]="setUpVector";["realm"]="cl";["name"]="particle_methods:setUpVector";["summary"]="\
Sets the right direction for given control point.";["private"]=false;["classlib"]="Particle";["param"]={[1]="id";[2]="value";[3]="number";[4]="vector";["number"]="Control Point ID (0-63)";["vector"]="Right";};};["startEmission"]={["class"]="function";["description"]="\
Starts emission of the particle.";["fname"]="startEmission";["realm"]="cl";["name"]="particle_methods:startEmission";["summary"]="\
Starts emission of the particle.";["private"]=false;["classlib"]="Particle";["param"]={};};["setControlPointParent"]={["class"]="function";["description"]="\
Sets the forward direction for given control point.";["fname"]="setControlPointParent";["realm"]="cl";["name"]="particle_methods:setControlPointParent";["summary"]="\
Sets the forward direction for given control point.";["private"]=false;["classlib"]="Particle";["param"]={[1]="id";[2]="value";[3]="number";["number"]="Parent";};};["isFinished"]={["ret"]="bool finished";["class"]="function";["description"]="\
Restarts emission of the particle.";["fname"]="isFinished";["realm"]="cl";["name"]="particle_methods:isFinished";["summary"]="\
Restarts emission of the particle.";["private"]=false;["classlib"]="Particle";["param"]={};};["setForwardVector"]={["class"]="function";["description"]="\
Sets the forward direction for given control point.";["fname"]="setForwardVector";["realm"]="cl";["name"]="particle_methods:setForwardVector";["summary"]="\
Sets the forward direction for given control point.";["private"]=false;["classlib"]="Particle";["param"]={[1]="id";[2]="value";[3]="number";[4]="vector";["number"]="Control Point ID (0-63)";["vector"]="Forward";};};["setControlPoint"]={["class"]="function";["description"]="\
Sets a value for given control point.";["fname"]="setControlPoint";["realm"]="cl";["name"]="particle_methods:setControlPoint";["summary"]="\
Sets a value for given control point.";["private"]=false;["classlib"]="Particle";["param"]={[1]="id";[2]="value";[3]="number";[4]="vector";["number"]="Control Point ID (0-63)";["vector"]="Value";};};["setControlPointEntity"]={["class"]="function";["description"]="\
Essentially makes child control point follow the parent entity.";["fname"]="setControlPointEntity";["realm"]="cl";["name"]="particle_methods:setControlPointEntity";["summary"]="\
Essentially makes child control point follow the parent entity.";["private"]=false;["classlib"]="Particle";["param"]={[1]="id";[2]="entity";[3]="number";["number"]="Child Control Point ID (0-63)";["entity"]="Entity parent";};};["setSortOrigin"]={["class"]="function";["description"]="\
Sets the sort origin for given particle system. This is used as a helper to determine which particles are in front of which.";["fname"]="setSortOrigin";["realm"]="cl";["name"]="particle_methods:setSortOrigin";["summary"]="\
Sets the sort origin for given particle system.";["private"]=false;["classlib"]="Particle";["param"]={[1]="origin";[2]="vector";["vector"]="Sort Origin";};};["stopEmission"]={["class"]="function";["description"]="\
Stops emission of the particle.";["fname"]="stopEmission";["realm"]="cl";["name"]="particle_methods:stopEmission";["summary"]="\
Stops emission of the particle.";["private"]=false;["classlib"]="Particle";["param"]={};};};};["Wirelink"]={["typtbl"]="wirelink_methods";["class"]="class";["server"]=true;["fields"]={};["name"]="Wirelink";["summary"]="\
Wirelink type ";["description"]="\
Wirelink type";["methods"]={[1]="entity";[2]="getWiredTo";[3]="getWiredToName";[4]="inputType";[5]="inputs";[6]="isValid";[7]="isWired";[8]="outputType";[9]="outputs";["isValid"]={["class"]="function";["description"]="\
Checks if a wirelink is valid. (ie. doesn't point to an invalid entity)";["fname"]="isValid";["realm"]="sv";["name"]="wirelink_methods:isValid";["summary"]="\
Checks if a wirelink is valid.";["private"]=false;["classlib"]="Wirelink";["param"]={};};["outputType"]={["class"]="function";["description"]="\
Returns the type of output name, or nil if it doesn't exist";["fname"]="outputType";["realm"]="sv";["name"]="wirelink_methods:outputType";["summary"]="\
Returns the type of output name, or nil if it doesn't exist ";["private"]=false;["classlib"]="Wirelink";["param"]={[1]="name";};};["getWiredTo"]={["ret"]="The entity the wirelink is wired to";["class"]="function";["description"]="\
Returns what an input of the wirelink is wired to.";["fname"]="getWiredTo";["realm"]="sv";["name"]="wirelink_methods:getWiredTo";["summary"]="\
Returns what an input of the wirelink is wired to.";["private"]=false;["classlib"]="Wirelink";["param"]={[1]="name";["name"]="Name of the input";};};["inputs"]={["class"]="function";["description"]="\
Returns a table of all of the wirelink's inputs";["fname"]="inputs";["realm"]="sv";["name"]="wirelink_methods:inputs";["summary"]="\
Returns a table of all of the wirelink's inputs ";["private"]=false;["classlib"]="Wirelink";["param"]={};};["inputType"]={["class"]="function";["description"]="\
Returns the type of input name, or nil if it doesn't exist";["fname"]="inputType";["realm"]="sv";["name"]="wirelink_methods:inputType";["summary"]="\
Returns the type of input name, or nil if it doesn't exist ";["private"]=false;["classlib"]="Wirelink";["param"]={[1]="name";};};["isWired"]={["class"]="function";["description"]="\
Checks if an input is wired.";["fname"]="isWired";["realm"]="sv";["name"]="wirelink_methods:isWired";["summary"]="\
Checks if an input is wired.";["private"]=false;["classlib"]="Wirelink";["param"]={[1]="name";["name"]="Name of the input to check";};};["entity"]={["class"]="function";["description"]="\
Returns the entity that the wirelink represents";["fname"]="entity";["realm"]="sv";["name"]="wirelink_methods:entity";["summary"]="\
Returns the entity that the wirelink represents ";["private"]=false;["classlib"]="Wirelink";["param"]={};};["getWiredToName"]={["ret"]="String name of the output that the input is wired to.";["class"]="function";["description"]="\
Returns the name of the output an input of the wirelink is wired to.";["fname"]="getWiredToName";["realm"]="sv";["name"]="wirelink_methods:getWiredToName";["summary"]="\
Returns the name of the output an input of the wirelink is wired to.";["private"]=false;["classlib"]="Wirelink";["param"]={[1]="name";["name"]="Name of the input of the wirelink.";};};["outputs"]={["class"]="function";["description"]="\
Returns a table of all of the wirelink's outputs";["fname"]="outputs";["realm"]="sv";["name"]="wirelink_methods:outputs";["summary"]="\
Returns a table of all of the wirelink's outputs ";["private"]=false;["classlib"]="Wirelink";["param"]={};};};};["Player"]={["typtbl"]="player_methods";["class"]="class";["fields"]={};["name"]="Player";["summary"]="\
Player type ";["description"]="\
Player type";["methods"]={[1]="getActiveWeapon";[2]="getAimVector";[3]="getArmor";[4]="getDeaths";[5]="getEyeTrace";[6]="getFOV";[7]="getFrags";[8]="getFriendStatus";[9]="getJumpPower";[10]="getMaxSpeed";[11]="getName";[12]="getPing";[13]="getRunSpeed";[14]="getShootPos";[15]="getSteamID";[16]="getSteamID64";[17]="getTeam";[18]="getTeamName";[19]="getUniqueID";[20]="getUserID";[21]="getViewEntity";[22]="getWeapon";[23]="getWeapons";[24]="hasGodMode";[25]="inVehicle";[26]="isAdmin";[27]="isAlive";[28]="isBot";[29]="isConnected";[30]="isCrouching";[31]="isFlashlightOn";[32]="isFrozen";[33]="isMuted";[34]="isNPC";[35]="isNoclipped";[36]="isPlayer";[37]="isSuperAdmin";[38]="isUserGroup";[39]="keyDown";[40]="setViewEntity";["isUserGroup"]={["ret"]="True if player belongs to group";["description"]="\
Returns whether the player belongs to a usergroup";["class"]="function";["realm"]="sh";["summary"]="\
Returns whether the player belongs to a usergroup ";["fname"]="isUserGroup";["classlib"]="Player";["name"]="player_methods:isUserGroup";["server"]=true;["private"]=false;["client"]=true;["param"]={[1]="group";["group"]="Group to check against";};};["isBot"]={["ret"]="True if player is a bot";["description"]="\
Returns whether the player is a bot";["class"]="function";["realm"]="sh";["summary"]="\
Returns whether the player is a bot ";["fname"]="isBot";["classlib"]="Player";["name"]="player_methods:isBot";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["setViewEntity"]={["description"]="\
Sets the view entity of the player. Only works if they are linked to a hud.";["class"]="function";["realm"]="sv";["fname"]="setViewEntity";["summary"]="\
Sets the view entity of the player.";["name"]="player_methods:setViewEntity";["classlib"]="Player";["private"]=false;["server"]=true;["param"]={[1]="ent";["ent"]="Entity to set the player's view entity to, or nothing to reset it";};};["isNoclipped"]={["ret"]="true if the player is noclipped";["description"]="\
Returns true if the player is noclipped";["class"]="function";["realm"]="sh";["summary"]="\
Returns true if the player is noclipped ";["fname"]="isNoclipped";["classlib"]="Player";["name"]="player_methods:isNoclipped";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["getJumpPower"]={["ret"]="Jump power";["description"]="\
Returns the player's jump power";["class"]="function";["realm"]="sh";["summary"]="\
Returns the player's jump power ";["fname"]="getJumpPower";["classlib"]="Player";["name"]="player_methods:getJumpPower";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["inVehicle"]={["ret"]="True if player in vehicle";["description"]="\
Returns whether the player is in a vehicle";["class"]="function";["realm"]="sh";["summary"]="\
Returns whether the player is in a vehicle ";["fname"]="inVehicle";["classlib"]="Player";["name"]="player_methods:inVehicle";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["keyDown"]={["ret"]="True or false";["description"]="\
Returns whether or not the player is pushing the key.";["class"]="function";["realm"]="sh";["summary"]="\
Returns whether or not the player is pushing the key.";["fname"]="keyDown";["classlib"]="Player";["name"]="player_methods:keyDown";["server"]=true;["private"]=false;["client"]=true;["param"]={[1]="key";["key"]="Key to check. \
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
IN_KEY.RUN";};};["getFOV"]={["ret"]="Field of view";["description"]="\
Returns the player's field of view";["class"]="function";["realm"]="sh";["summary"]="\
Returns the player's field of view ";["fname"]="getFOV";["classlib"]="Player";["name"]="player_methods:getFOV";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["getShootPos"]={["ret"]="Shoot position";["description"]="\
Returns the player's shoot position";["class"]="function";["realm"]="sh";["summary"]="\
Returns the player's shoot position ";["fname"]="getShootPos";["classlib"]="Player";["name"]="player_methods:getShootPos";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["getTeam"]={["ret"]="team";["description"]="\
Returns the player's current team";["class"]="function";["realm"]="sh";["summary"]="\
Returns the player's current team ";["fname"]="getTeam";["classlib"]="Player";["name"]="player_methods:getTeam";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["getViewEntity"]={["ret"]="Player's current view entity";["description"]="\
Returns the player's current view entity";["class"]="function";["realm"]="sh";["summary"]="\
Returns the player's current view entity ";["fname"]="getViewEntity";["classlib"]="Player";["name"]="player_methods:getViewEntity";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["getArmor"]={["ret"]="Armor";["description"]="\
Returns the players armor";["class"]="function";["realm"]="sh";["summary"]="\
Returns the players armor ";["fname"]="getArmor";["classlib"]="Player";["name"]="player_methods:getArmor";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["getSteamID"]={["ret"]="steam ID";["description"]="\
Returns the player's steam ID";["class"]="function";["realm"]="sh";["summary"]="\
Returns the player's steam ID ";["fname"]="getSteamID";["classlib"]="Player";["name"]="player_methods:getSteamID";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["isConnected"]={["ret"]="True if player is connected";["description"]="\
Returns whether the player is connected";["class"]="function";["realm"]="sh";["summary"]="\
Returns whether the player is connected ";["fname"]="isConnected";["classlib"]="Player";["name"]="player_methods:isConnected";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["getUserID"]={["ret"]="user ID";["description"]="\
Returns the player's user ID";["class"]="function";["realm"]="sh";["summary"]="\
Returns the player's user ID ";["fname"]="getUserID";["classlib"]="Player";["name"]="player_methods:getUserID";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["getMaxSpeed"]={["ret"]="Maximum speed";["description"]="\
Returns the player's maximum speed";["class"]="function";["realm"]="sh";["summary"]="\
Returns the player's maximum speed ";["fname"]="getMaxSpeed";["classlib"]="Player";["name"]="player_methods:getMaxSpeed";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["getSteamID64"]={["ret"]="community ID";["description"]="\
Returns the player's community ID";["class"]="function";["realm"]="sh";["summary"]="\
Returns the player's community ID ";["fname"]="getSteamID64";["classlib"]="Player";["name"]="player_methods:getSteamID64";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["getRunSpeed"]={["ret"]="Running speed";["description"]="\
Returns the player's running speed";["class"]="function";["realm"]="sh";["summary"]="\
Returns the player's running speed ";["fname"]="getRunSpeed";["classlib"]="Player";["name"]="player_methods:getRunSpeed";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["getAimVector"]={["ret"]="Aim vector";["description"]="\
Returns the player's aim vector";["class"]="function";["realm"]="sh";["summary"]="\
Returns the player's aim vector ";["fname"]="getAimVector";["classlib"]="Player";["name"]="player_methods:getAimVector";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["getUniqueID"]={["ret"]="unique ID";["description"]="\
Returns the player's unique ID";["class"]="function";["realm"]="sh";["summary"]="\
Returns the player's unique ID ";["fname"]="getUniqueID";["classlib"]="Player";["name"]="player_methods:getUniqueID";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["getEyeTrace"]={["ret"]="table trace data https://wiki.garrysmod.com/page/Structures/TraceResult";["description"]="\
Returns a table with information of what the player is looking at";["class"]="function";["realm"]="sh";["summary"]="\
Returns a table with information of what the player is looking at ";["fname"]="getEyeTrace";["classlib"]="Player";["name"]="player_methods:getEyeTrace";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["getFriendStatus"]={["ret"]="One of: \"friend\", \"blocked\", \"none\", \"requested\"";["class"]="function";["description"]="\
Returns the relationship of the player to the local client";["fname"]="getFriendStatus";["realm"]="sh";["name"]="player_methods:getFriendStatus";["summary"]="\
Returns the relationship of the player to the local client ";["private"]=false;["classlib"]="Player";["param"]={};};["getFrags"]={["ret"]="Amount of kills";["description"]="\
Returns the amount of kills of the player";["class"]="function";["realm"]="sh";["summary"]="\
Returns the amount of kills of the player ";["fname"]="getFrags";["classlib"]="Player";["name"]="player_methods:getFrags";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["isMuted"]={["ret"]="True if the player was muted";["class"]="function";["description"]="\
Returns whether the local player has muted the player";["fname"]="isMuted";["realm"]="sh";["name"]="player_methods:isMuted";["summary"]="\
Returns whether the local player has muted the player ";["private"]=false;["classlib"]="Player";["param"]={};};["isFrozen"]={["ret"]="True if player is frozen";["description"]="\
Returns whether the player is frozen";["class"]="function";["realm"]="sh";["summary"]="\
Returns whether the player is frozen ";["fname"]="isFrozen";["classlib"]="Player";["name"]="player_methods:isFrozen";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["isPlayer"]={["ret"]="True if player is player";["description"]="\
Returns whether the player is a player";["class"]="function";["realm"]="sh";["summary"]="\
Returns whether the player is a player ";["fname"]="isPlayer";["classlib"]="Player";["name"]="player_methods:isPlayer";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["getPing"]={["ret"]="ping";["description"]="\
Returns the player's current ping";["class"]="function";["realm"]="sh";["summary"]="\
Returns the player's current ping ";["fname"]="getPing";["classlib"]="Player";["name"]="player_methods:getPing";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["getWeapon"]={["ret"]="weapon";["description"]="\
Returns the specified weapon or nil if the player doesn't have it";["class"]="function";["realm"]="sh";["summary"]="\
Returns the specified weapon or nil if the player doesn't have it ";["fname"]="getWeapon";["classlib"]="Player";["name"]="player_methods:getWeapon";["server"]=true;["private"]=false;["client"]=true;["param"]={[1]="wep";["wep"]="String weapon class";};};["getWeapons"]={["ret"]="Table of weapons";["description"]="\
Returns a table of weapons the player is carrying";["class"]="function";["realm"]="sh";["summary"]="\
Returns a table of weapons the player is carrying ";["fname"]="getWeapons";["classlib"]="Player";["name"]="player_methods:getWeapons";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["isAlive"]={["ret"]="True if player alive";["description"]="\
Returns whether the player is alive";["class"]="function";["realm"]="sh";["summary"]="\
Returns whether the player is alive ";["fname"]="isAlive";["classlib"]="Player";["name"]="player_methods:isAlive";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["isFlashlightOn"]={["ret"]="True if player has flashlight on";["description"]="\
Returns whether the player's flashlight is on";["class"]="function";["realm"]="sh";["summary"]="\
Returns whether the player's flashlight is on ";["fname"]="isFlashlightOn";["classlib"]="Player";["name"]="player_methods:isFlashlightOn";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["getName"]={["ret"]="Name";["description"]="\
Returns the player's name";["class"]="function";["realm"]="sh";["summary"]="\
Returns the player's name ";["fname"]="getName";["classlib"]="Player";["name"]="player_methods:getName";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["isNPC"]={["ret"]="True if player is an NPC";["description"]="\
Returns whether the player is an NPC";["class"]="function";["realm"]="sh";["summary"]="\
Returns whether the player is an NPC ";["fname"]="isNPC";["classlib"]="Player";["name"]="player_methods:isNPC";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["isAdmin"]={["ret"]="True if player is admin";["description"]="\
Returns whether the player is an admin";["class"]="function";["realm"]="sh";["summary"]="\
Returns whether the player is an admin ";["fname"]="isAdmin";["classlib"]="Player";["name"]="player_methods:isAdmin";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["isSuperAdmin"]={["ret"]="True if player is super admin";["description"]="\
Returns whether the player is a super admin";["class"]="function";["realm"]="sh";["summary"]="\
Returns whether the player is a super admin ";["fname"]="isSuperAdmin";["classlib"]="Player";["name"]="player_methods:isSuperAdmin";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["getTeamName"]={["ret"]="team name";["description"]="\
Returns the name of the player's current team";["class"]="function";["realm"]="sh";["summary"]="\
Returns the name of the player's current team ";["fname"]="getTeamName";["classlib"]="Player";["name"]="player_methods:getTeamName";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["isCrouching"]={["ret"]="True if player crouching";["description"]="\
Returns whether the player is crouching";["class"]="function";["realm"]="sh";["summary"]="\
Returns whether the player is crouching ";["fname"]="isCrouching";["classlib"]="Player";["name"]="player_methods:isCrouching";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["getDeaths"]={["ret"]="Amount of deaths";["description"]="\
Returns the amount of deaths of the player";["class"]="function";["realm"]="sh";["summary"]="\
Returns the amount of deaths of the player ";["fname"]="getDeaths";["classlib"]="Player";["name"]="player_methods:getDeaths";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["hasGodMode"]={["ret"]="True if the player has godmode";["description"]="\
Returns whether or not the player has godmode";["class"]="function";["realm"]="sv";["fname"]="hasGodMode";["summary"]="\
Returns whether or not the player has godmode ";["name"]="player_methods:hasGodMode";["classlib"]="Player";["private"]=false;["server"]=true;["param"]={};};["getActiveWeapon"]={["ret"]="The weapon";["description"]="\
Returns the name of the player's active weapon";["class"]="function";["realm"]="sh";["summary"]="\
Returns the name of the player's active weapon ";["fname"]="getActiveWeapon";["classlib"]="Player";["name"]="player_methods:getActiveWeapon";["server"]=true;["private"]=false;["client"]=true;["param"]={};};};};["Angle"]={["typtbl"]="ang_methods";["class"]="class";["description"]="\
Angle Type";["summary"]="\
Angle Type ";["fields"]={};["name"]="Angle";["server"]=true;["client"]=true;["methods"]={[1]="getForward";[2]="getNormalized";[3]="getRight";[4]="getUp";[5]="isZero";[6]="normalize";[7]="rotateAroundAxis";[8]="set";[9]="setP";[10]="setR";[11]="setY";[12]="setZero";["set"]={["ret"]="nil";["class"]="function";["description"]="\
Copies p,y,r from angle to another.";["fname"]="set";["realm"]="sh";["name"]="ang_methods:set";["summary"]="\
Copies p,y,r from angle to another.";["private"]=false;["classlib"]="Angle";["param"]={[1]="b";["b"]="Angle to copy from.";};};["getRight"]={["ret"]="vector normalised.";["class"]="function";["description"]="\
Return the Right Vector relative to the angle dir.";["fname"]="getRight";["realm"]="sh";["name"]="ang_methods:getRight";["summary"]="\
Return the Right Vector relative to the angle dir.";["private"]=false;["classlib"]="Angle";["param"]={};};["getUp"]={["ret"]="vector normalised.";["class"]="function";["description"]="\
Return the Up Vector relative to the angle dir.";["fname"]="getUp";["realm"]="sh";["name"]="ang_methods:getUp";["summary"]="\
Return the Up Vector relative to the angle dir.";["private"]=false;["classlib"]="Angle";["param"]={};};["isZero"]={["ret"]="boolean";["class"]="function";["description"]="\
Returns if p,y,r are all 0.";["fname"]="isZero";["realm"]="sh";["name"]="ang_methods:isZero";["summary"]="\
Returns if p,y,r are all 0.";["private"]=false;["classlib"]="Angle";["param"]={};};["getNormalized"]={["ret"]="Normalized angle table";["class"]="function";["description"]="\
Returnes a normalized angle";["fname"]="getNormalized";["realm"]="sh";["name"]="ang_methods:getNormalized";["summary"]="\
Returnes a normalized angle ";["private"]=false;["classlib"]="Angle";["param"]={};};["setY"]={["ret"]="The modified angle";["class"]="function";["description"]="\
Set's the angle's yaw and returns it.";["fname"]="setY";["realm"]="sh";["name"]="ang_methods:setY";["summary"]="\
Set's the angle's yaw and returns it.";["private"]=false;["classlib"]="Angle";["param"]={[1]="y";["y"]="The yaw";};};["setP"]={["ret"]="The modified angle";["class"]="function";["description"]="\
Set's the angle's pitch and returns it.";["fname"]="setP";["realm"]="sh";["name"]="ang_methods:setP";["summary"]="\
Set's the angle's pitch and returns it.";["private"]=false;["classlib"]="Angle";["param"]={[1]="p";["p"]="The pitch";};};["setR"]={["ret"]="The modified angle";["class"]="function";["description"]="\
Set's the angle's roll and returns it.";["fname"]="setR";["realm"]="sh";["name"]="ang_methods:setR";["summary"]="\
Set's the angle's roll and returns it.";["private"]=false;["classlib"]="Angle";["param"]={[1]="r";["r"]="The roll";};};["normalize"]={["ret"]="nil";["class"]="function";["description"]="\
Normalise angles eg (0,181,1) -> (0,-179,1).";["fname"]="normalize";["realm"]="sh";["name"]="ang_methods:normalize";["summary"]="\
Normalise angles eg (0,181,1) -> (0,-179,1).";["private"]=false;["classlib"]="Angle";["param"]={};};["getForward"]={["ret"]="vector normalised.";["class"]="function";["description"]="\
Return the Forward Vector ( direction the angle points ).";["fname"]="getForward";["realm"]="sh";["name"]="ang_methods:getForward";["summary"]="\
Return the Forward Vector ( direction the angle points ).";["private"]=false;["classlib"]="Angle";["param"]={};};["setZero"]={["ret"]="nil";["class"]="function";["description"]="\
Sets p,y,r to 0. This is faster than doing it manually.";["fname"]="setZero";["realm"]="sh";["name"]="ang_methods:setZero";["summary"]="\
Sets p,y,r to 0.";["private"]=false;["classlib"]="Angle";["param"]={};};["rotateAroundAxis"]={["ret"]="The modified angle";["class"]="function";["description"]="\
Return Rotated angle around the specified axis.";["fname"]="rotateAroundAxis";["realm"]="sh";["name"]="ang_methods:rotateAroundAxis";["summary"]="\
Return Rotated angle around the specified axis.";["private"]=false;["classlib"]="Angle";["param"]={[1]="v";[2]="deg";[3]="rad";["rad"]="Number of radians or nil if degrees.";["deg"]="Number of degrees or nil if radians.";["v"]="Vector axis";};};};};["Color"]={["typtbl"]="color_methods";["class"]="class";["description"]="\
Color type";["summary"]="\
Color type ";["fields"]={};["name"]="Color";["server"]=true;["client"]=true;["methods"]={[1]="hsvToRGB";[2]="rgbToHSV";[3]="setA";[4]="setB";[5]="setG";[6]="setR";["setA"]={["ret"]="The modified color";["class"]="function";["description"]="\
Set's the color's alpha and returns it.";["fname"]="setA";["realm"]="sh";["name"]="color_methods:setA";["summary"]="\
Set's the color's alpha and returns it.";["private"]=false;["classlib"]="Color";["param"]={[1]="a";["a"]="The alpha";};};["setR"]={["ret"]="The modified color";["class"]="function";["description"]="\
Set's the color's red channel and returns it.";["fname"]="setR";["realm"]="sh";["name"]="color_methods:setR";["summary"]="\
Set's the color's red channel and returns it.";["private"]=false;["classlib"]="Color";["param"]={[1]="r";["r"]="The red";};};["hsvToRGB"]={["ret"]="A triplet of numbers representing HSV.";["description"]="\
Converts the color from HSV to RGB.";["class"]="function";["realm"]="sh";["summary"]="\
Converts the color from HSV to RGB.";["fname"]="hsvToRGB";["classlib"]="Color";["name"]="color_methods:hsvToRGB";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["rgbToHSV"]={["ret"]="A triplet of numbers representing HSV.";["description"]="\
Converts the color from RGB to HSV.";["class"]="function";["realm"]="sh";["summary"]="\
Converts the color from RGB to HSV.";["fname"]="rgbToHSV";["classlib"]="Color";["name"]="color_methods:rgbToHSV";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["setG"]={["ret"]="The modified color";["class"]="function";["description"]="\
Set's the color's green and returns it.";["fname"]="setG";["realm"]="sh";["name"]="color_methods:setG";["summary"]="\
Set's the color's green and returns it.";["private"]=false;["classlib"]="Color";["param"]={[1]="g";["g"]="The green";};};["setB"]={["ret"]="The modified color";["class"]="function";["description"]="\
Set's the color's blue and returns it.";["fname"]="setB";["realm"]="sh";["name"]="color_methods:setB";["summary"]="\
Set's the color's blue and returns it.";["private"]=false;["classlib"]="Color";["param"]={[1]="b";["b"]="The blue";};};};};["File"]={["typtbl"]="file_methods";["class"]="class";["description"]="\
File type";["fields"]={};["name"]="File";["summary"]="\
File type ";["client"]=true;["methods"]={[1]="close";[2]="flush";[3]="read";[4]="readBool";[5]="readByte";[6]="readDouble";[7]="readFloat";[8]="readLine";[9]="readLong";[10]="readShort";[11]="seek";[12]="size";[13]="skip";[14]="tell";[15]="write";[16]="writeBool";[17]="writeByte";[18]="writeDouble";[19]="writeFloat";[20]="writeLong";[21]="writeShort";["readDouble"]={["ret"]="The data";["class"]="function";["description"]="\
Reads a double and advances the file position";["fname"]="readDouble";["realm"]="cl";["name"]="file_methods:readDouble";["summary"]="\
Reads a double and advances the file position ";["private"]=false;["classlib"]="File";["param"]={};};["readLine"]={["ret"]="The data";["class"]="function";["description"]="\
Reads a line and advances the file position";["fname"]="readLine";["realm"]="cl";["name"]="file_methods:readLine";["summary"]="\
Reads a line and advances the file position ";["private"]=false;["classlib"]="File";["param"]={};};["readLong"]={["ret"]="The data";["class"]="function";["description"]="\
Reads a long and advances the file position";["fname"]="readLong";["realm"]="cl";["name"]="file_methods:readLong";["summary"]="\
Reads a long and advances the file position ";["private"]=false;["classlib"]="File";["param"]={};};["readFloat"]={["ret"]="The data";["class"]="function";["description"]="\
Reads a float and advances the file position";["fname"]="readFloat";["realm"]="cl";["name"]="file_methods:readFloat";["summary"]="\
Reads a float and advances the file position ";["private"]=false;["classlib"]="File";["param"]={};};["readShort"]={["ret"]="The data";["class"]="function";["description"]="\
Reads a short and advances the file position";["fname"]="readShort";["realm"]="cl";["name"]="file_methods:readShort";["summary"]="\
Reads a short and advances the file position ";["private"]=false;["classlib"]="File";["param"]={};};["writeShort"]={["class"]="function";["description"]="\
Writes a short and advances the file position";["fname"]="writeShort";["realm"]="cl";["name"]="file_methods:writeShort";["summary"]="\
Writes a short and advances the file position ";["private"]=false;["classlib"]="File";["param"]={[1]="x";["x"]="The short to write";};};["size"]={["ret"]="The file's size";["class"]="function";["description"]="\
Returns the file's size in bytes";["fname"]="size";["realm"]="cl";["name"]="file_methods:size";["summary"]="\
Returns the file's size in bytes ";["private"]=false;["classlib"]="File";["param"]={};};["skip"]={["ret"]="The resulting position";["class"]="function";["description"]="\
Moves the file position relative to its current position";["fname"]="skip";["realm"]="cl";["name"]="file_methods:skip";["summary"]="\
Moves the file position relative to its current position ";["private"]=false;["classlib"]="File";["param"]={[1]="n";["n"]="How much to move the position";};};["write"]={["class"]="function";["description"]="\
Writes a string to the file and advances the file position";["fname"]="write";["realm"]="cl";["name"]="file_methods:write";["summary"]="\
Writes a string to the file and advances the file position ";["private"]=false;["classlib"]="File";["param"]={[1]="str";["str"]="The data to write";};};["writeBool"]={["class"]="function";["description"]="\
Writes a boolean and advances the file position";["fname"]="writeBool";["realm"]="cl";["name"]="file_methods:writeBool";["summary"]="\
Writes a boolean and advances the file position ";["private"]=false;["classlib"]="File";["param"]={[1]="x";["x"]="The boolean to write";};};["flush"]={["class"]="function";["description"]="\
Wait until all changes to the file are complete";["fname"]="flush";["realm"]="cl";["name"]="file_methods:flush";["summary"]="\
Wait until all changes to the file are complete ";["private"]=false;["classlib"]="File";["param"]={};};["writeLong"]={["class"]="function";["description"]="\
Writes a long and advances the file position";["fname"]="writeLong";["realm"]="cl";["name"]="file_methods:writeLong";["summary"]="\
Writes a long and advances the file position ";["private"]=false;["classlib"]="File";["param"]={[1]="x";["x"]="The long to write";};};["readBool"]={["ret"]="The data";["class"]="function";["description"]="\
Reads a boolean and advances the file position";["fname"]="readBool";["realm"]="cl";["name"]="file_methods:readBool";["summary"]="\
Reads a boolean and advances the file position ";["private"]=false;["classlib"]="File";["param"]={};};["writeFloat"]={["class"]="function";["description"]="\
Writes a float and advances the file position";["fname"]="writeFloat";["realm"]="cl";["name"]="file_methods:writeFloat";["summary"]="\
Writes a float and advances the file position ";["private"]=false;["classlib"]="File";["param"]={[1]="x";["x"]="The float to write";};};["read"]={["ret"]="The data";["class"]="function";["description"]="\
Reads a certain length of the file's bytes";["fname"]="read";["realm"]="cl";["name"]="file_methods:read";["summary"]="\
Reads a certain length of the file's bytes ";["private"]=false;["classlib"]="File";["param"]={[1]="n";["n"]="The length to read";};};["readByte"]={["ret"]="The data";["class"]="function";["description"]="\
Reads a byte and advances the file position";["fname"]="readByte";["realm"]="cl";["name"]="file_methods:readByte";["summary"]="\
Reads a byte and advances the file position ";["private"]=false;["classlib"]="File";["param"]={};};["writeByte"]={["class"]="function";["description"]="\
Writes a byte and advances the file position";["fname"]="writeByte";["realm"]="cl";["name"]="file_methods:writeByte";["summary"]="\
Writes a byte and advances the file position ";["private"]=false;["classlib"]="File";["param"]={[1]="x";["x"]="The byte to write";};};["tell"]={["ret"]="The current file position";["class"]="function";["description"]="\
Returns the current file position";["fname"]="tell";["realm"]="cl";["name"]="file_methods:tell";["summary"]="\
Returns the current file position ";["private"]=false;["classlib"]="File";["param"]={};};["seek"]={["class"]="function";["description"]="\
Sets the file position";["fname"]="seek";["realm"]="cl";["name"]="file_methods:seek";["summary"]="\
Sets the file position ";["private"]=false;["classlib"]="File";["param"]={[1]="n";["n"]="The position to set it to";};};["writeDouble"]={["class"]="function";["description"]="\
Writes a double and advances the file position";["fname"]="writeDouble";["realm"]="cl";["name"]="file_methods:writeDouble";["summary"]="\
Writes a double and advances the file position ";["private"]=false;["classlib"]="File";["param"]={[1]="x";["x"]="The double to write";};};["close"]={["class"]="function";["description"]="\
Flushes and closes the file. The file must be opened again to use a new file object.";["fname"]="close";["realm"]="cl";["name"]="file_methods:close";["summary"]="\
Flushes and closes the file.";["private"]=false;["classlib"]="File";["param"]={};};};};["Weapon"]={["typtbl"]="weapon_methods";["class"]="class";["fields"]={};["name"]="Weapon";["summary"]="\
Weapon type ";["description"]="\
Weapon type";["methods"]={[1]="clip1";[2]="clip2";[3]="getActivity";[4]="getHoldType";[5]="getNextPrimaryFire";[6]="getNextSecondaryFire";[7]="getPrimaryAmmoType";[8]="getPrintName";[9]="getSecondaryAmmoType";[10]="isCarriedByLocalPlayer";[11]="isWeaponVisible";[12]="lastShootTime";["lastShootTime"]={["ret"]="Time the weapon was last shot";["description"]="\
Returns the time since a weapon was last fired at a float variable";["class"]="function";["realm"]="sh";["summary"]="\
Returns the time since a weapon was last fired at a float variable ";["fname"]="lastShootTime";["classlib"]="Weapon";["name"]="weapon_methods:lastShootTime";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["getNextPrimaryFire"]={["ret"]="The time, relative to CurTime";["description"]="\
Gets the next time the weapon can primary fire.";["class"]="function";["realm"]="sh";["summary"]="\
Gets the next time the weapon can primary fire.";["fname"]="getNextPrimaryFire";["classlib"]="Weapon";["name"]="weapon_methods:getNextPrimaryFire";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["getPrimaryAmmoType"]={["ret"]="Ammo number type";["description"]="\
Gets the primary ammo type of the given weapon.";["class"]="function";["realm"]="sh";["summary"]="\
Gets the primary ammo type of the given weapon.";["fname"]="getPrimaryAmmoType";["classlib"]="Weapon";["name"]="weapon_methods:getPrimaryAmmoType";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["clip2"]={["ret"]="amount of ammo";["description"]="\
Returns Ammo in secondary clip";["class"]="function";["realm"]="sh";["summary"]="\
Returns Ammo in secondary clip ";["fname"]="clip2";["classlib"]="Weapon";["name"]="weapon_methods:clip2";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["isCarriedByLocalPlayer"]={["ret"]="whether or not the weapon is carried by the local player";["description"]="\
Returns if the weapon is carried by the local player.";["class"]="function";["realm"]="cl";["fname"]="isCarriedByLocalPlayer";["summary"]="\
Returns if the weapon is carried by the local player.";["name"]="weapon_methods:isCarriedByLocalPlayer";["classlib"]="Weapon";["private"]=false;["client"]=true;["param"]={};};["getSecondaryAmmoType"]={["ret"]="Ammo number type";["description"]="\
Gets the secondary ammo type of the given weapon.";["class"]="function";["realm"]="sh";["summary"]="\
Gets the secondary ammo type of the given weapon.";["fname"]="getSecondaryAmmoType";["classlib"]="Weapon";["name"]="weapon_methods:getSecondaryAmmoType";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["clip1"]={["ret"]="amount of ammo";["description"]="\
Returns Ammo in primary clip";["class"]="function";["realm"]="sh";["summary"]="\
Returns Ammo in primary clip ";["fname"]="clip1";["classlib"]="Weapon";["name"]="weapon_methods:clip1";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["getActivity"]={["ret"]="number Current activity";["description"]="\
Returns the sequence enumeration number that the weapon is playing. Must be used on a view model.";["class"]="function";["realm"]="sh";["summary"]="\
Returns the sequence enumeration number that the weapon is playing.";["fname"]="getActivity";["classlib"]="Weapon";["name"]="weapon_methods:getActivity";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["getPrintName"]={["ret"]="string Display name of weapon";["description"]="\
Gets Display name of weapon";["class"]="function";["realm"]="cl";["fname"]="getPrintName";["summary"]="\
Gets Display name of weapon ";["name"]="weapon_methods:getPrintName";["classlib"]="Weapon";["private"]=false;["client"]=true;["param"]={};};["getNextSecondaryFire"]={["ret"]="The time, relative to CurTime";["description"]="\
Gets the next time the weapon can secondary fire.";["class"]="function";["realm"]="sh";["summary"]="\
Gets the next time the weapon can secondary fire.";["fname"]="getNextSecondaryFire";["classlib"]="Weapon";["name"]="weapon_methods:getNextSecondaryFire";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["getHoldType"]={["ret"]="string Holdtype";["description"]="\
Returns the hold type of the weapon.";["class"]="function";["realm"]="sh";["summary"]="\
Returns the hold type of the weapon.";["fname"]="getHoldType";["classlib"]="Weapon";["name"]="weapon_methods:getHoldType";["server"]=true;["private"]=false;["client"]=true;["param"]={};};["isWeaponVisible"]={["ret"]="Whether the weapon is visble or not";["description"]="\
Returns whether the weapon is visible";["class"]="function";["realm"]="sh";["summary"]="\
Returns whether the weapon is visible ";["fname"]="isWeaponVisible";["classlib"]="Weapon";["name"]="weapon_methods:isWeaponVisible";["server"]=true;["private"]=false;["client"]=true;["param"]={};};};};};["directives"]={[1]="client";[2]="include";[3]="includedir";[4]="model";[5]="name";[6]="server";["include"]={["description"]="\
Mark a file to be included in the upload. \
This is required to use the file in require() and dofile()";["class"]="directive";["classForced"]=true;["summary"]="\
Mark a file to be included in the upload.";["name"]="include";["usage"]="\
--@include lib/someLibrary.txt \
 \
require( \"lib/someLibrary.txt\" ) \
-- CODE";["param"]={[1]="path";["path"]="Path to the file";};};["name"]={["description"]="\
Set the name of the script. \
This will become the name of the tab and will show on the overlay of the processor";["class"]="directive";["classForced"]=true;["summary"]="\
Set the name of the script.";["name"]="name";["usage"]="\
--@name Awesome script \
-- CODE";["param"]={[1]="name";["name"]="Name of the script";};};["model"]={["description"]="\
Set the model of the processor entity. \
This does not set the model of the screen entity";["class"]="directive";["classForced"]=true;["summary"]="\
Set the model of the processor entity.";["name"]="model";["usage"]="\
--@model models/props_junk/watermelon01.mdl \
-- CODE";["param"]={[1]="model";["model"]="String of the model";};};["includedir"]={["description"]="\
Mark a directory to be included in the upload. \
This is optional to include all files in the directory in require() and dofile()";["class"]="directive";["classForced"]=true;["summary"]="\
Mark a directory to be included in the upload.";["name"]="includedir";["usage"]="\
--@includedir lib \
 \
require( \"lib/someLibraryInLib.txt\" ) \
require( \"lib/someOtherLibraryInLib.txt\" ) \
-- CODE";["param"]={[1]="path";["path"]="Path to the directory";};};["client"]={["description"]="\
Set the processor to only run on the client. Shared is default";["class"]="directive";["classForced"]=true;["summary"]="\
Set the processor to only run on the client.";["name"]="client";["usage"]="\
--@client \
-- CODE";["param"]={};};["server"]={["description"]="\
Set the processor to only run on the server. Shared is default";["class"]="directive";["classForced"]=true;["summary"]="\
Set the processor to only run on the server.";["name"]="server";["usage"]="\
--@server \
-- CODE";["param"]={};};};};