SF.Docs={["classes"]={};["directives"]={[1]="author";[2]="client";[3]="clientmain";[4]="include";[5]="includedir";[6]="model";[7]="name";[8]="server";["author"]={["class"]="directive";["classForced"]=true;["description"]="\
Set the author of the script. \
This will set the author that will be shown on the overlay of the processor";["name"]="author";["param"]={[1]="author";["author"]="Author of the script";};["summary"]="\
Set the author of the script.";["usage"]="\
--@author TheAuthor \
-- CODE";};["client"]={["class"]="directive";["classForced"]=true;["description"]="\
Set the current file to only run on the client. Shared is default";["name"]="client";["param"]={};["summary"]="\
Set the current file to only run on the client.";["usage"]="\
--@client \
-- CODE";};["clientmain"]={["class"]="directive";["classForced"]=true;["description"]="\
Set the client file to run as main. Can only be used in the main file.";["name"]="clientmain";["param"]={};["summary"]="\
Set the client file to run as main.";["usage"]="\
--@clientmain somefile.txt \
-- CODE";};["include"]={["class"]="directive";["classForced"]=true;["description"]="\
Mark a file to be included in the upload. \
This is required to use the file in require() and dofile()";["name"]="include";["param"]={[1]="path";["path"]="Path to the file";};["summary"]="\
Mark a file to be included in the upload.";["usage"]="\
--@include lib/someLibrary.txt \
 \
require( \"lib/someLibrary.txt\" ) \
-- CODE";};["includedir"]={["class"]="directive";["classForced"]=true;["description"]="\
Mark a directory to be included in the upload. \
This is optional to include all files in the directory in require() and dofile()";["name"]="includedir";["param"]={[1]="path";["path"]="Path to the directory";};["summary"]="\
Mark a directory to be included in the upload.";["usage"]="\
--@includedir lib \
 \
require( \"lib/someLibraryInLib.txt\" ) \
require( \"lib/someOtherLibraryInLib.txt\" ) \
-- CODE";};["model"]={["class"]="directive";["classForced"]=true;["description"]="\
Set the model of the processor entity.";["name"]="model";["param"]={[1]="model";["model"]="String of the model";};["summary"]="\
Set the model of the processor entity.";["usage"]="\
--@model models/props_junk/watermelon01.mdl \
-- CODE";};["name"]={["class"]="directive";["classForced"]=true;["description"]="\
Set the name of the script. \
This will become the name of the tab and will show on the overlay of the processor";["name"]="name";["param"]={[1]="name";["name"]="Name of the script";};["summary"]="\
Set the name of the script.";["usage"]="\
--@name Awesome script \
-- CODE";};["server"]={["class"]="directive";["classForced"]=true;["description"]="\
Set the current file to only run on the server. Shared is default";["name"]="server";["param"]={};["summary"]="\
Set the current file to only run on the server.";["usage"]="\
--@server \
-- CODE";};};["hooks"]={[1]="Dupefinished";[10]="KeyPress";[11]="KeyRelease";[12]="NetworkEntityCreated";[13]="OnEntityCreated";[14]="OnPhysgunFreeze";[15]="OnPhysgunReload";[16]="PhysgunDrop";[17]="PhysgunPickup";[18]="PlayerCanPickupWeapon";[19]="PlayerChat";[2]="EndEntityDriving";[20]="PlayerDeath";[21]="PlayerDisconnected";[22]="PlayerEnteredVehicle";[23]="PlayerHurt";[24]="PlayerInitialSpawn";[25]="PlayerLeaveVehicle";[26]="PlayerNoClip";[27]="PlayerSay";[28]="PlayerSpawn";[29]="PlayerSpray";[3]="EntityFireBullets";[30]="PlayerSwitchFlashlight";[31]="PlayerSwitchWeapon";[32]="PlayerUse";[33]="PropBreak";[34]="Removed";[35]="StartChat";[36]="StartEntityDriving";[37]="calcview";[38]="drawhud";[39]="hologrammatrix";[4]="EntityRemoved";[40]="hudconnected";[41]="huddisconnected";[42]="hudshoulddraw";[43]="input";[44]="inputPressed";[45]="inputReleased";[46]="mouseWheeled";[47]="mousemoved";[48]="net";[49]="permissionrequest";[5]="EntityTakeDamage";[50]="postdrawhud";[51]="postdrawopaquerenderables";[52]="predrawhud";[53]="predrawopaquerenderables";[54]="readcell";[55]="remote";[56]="render";[57]="renderoffscreen";[58]="starfallUsed";[59]="think";[6]="FinishChat";[60]="tick";[61]="writecell";[62]="xinputConnected";[63]="xinputDisconnected";[64]="xinputPressed";[65]="xinputReleased";[66]="xinputStick";[67]="xinputTrigger";[7]="GravGunOnDropped";[8]="GravGunOnPickedUp";[9]="GravGunPunt";["Dupefinished"]={["class"]="hook";["classForced"]=true;["description"]="\
Called after the starfall chip is duplicated and the duplication is finished.";["name"]="Dupefinished";["param"]={[1]="entTbl";["entTbl"]="A table of entities duped with the chip mapped to their previous indices.";};["realm"]="sv";["server"]=true;["summary"]="\
Called after the starfall chip is duplicated and the duplication is finished.";};["EndEntityDriving"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Called when a player stops driving an entity";["name"]="EndEntityDriving";["param"]={[1]="ent";[2]="ply";["ent"]="Entity that had been driven";["ply"]="Player that drove the entity";};["realm"]="sh";["server"]=true;["summary"]="\
Called when a player stops driving an entity ";};["EntityFireBullets"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Called every time a bullet is fired from an entity";["name"]="EntityFireBullets";["param"]={[1]="ent";[2]="data";["data"]="The bullet data. See http://wiki.garrysmod.com/page/Structures/Bullet";["ent"]="The entity that fired the bullet";};["realm"]="sh";["server"]=true;["summary"]="\
Called every time a bullet is fired from an entity ";};["EntityRemoved"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Called when an entity is removed";["name"]="EntityRemoved";["param"]={[1]="ent";["ent"]="Entity being removed";};["realm"]="sh";["server"]=true;["summary"]="\
Called when an entity is removed ";};["EntityTakeDamage"]={["class"]="hook";["classForced"]=true;["description"]="\
Called when an entity is damaged";["name"]="EntityTakeDamage";["param"]={[1]="target";[2]="attacker";[3]="inflictor";[4]="amount";[5]="type";[6]="position";[7]="force";["amount"]="How much damage";["attacker"]="Entity that attacked";["force"]="Force of the damage";["inflictor"]="Entity that inflicted the damage";["position"]="Position of the damage";["target"]="Entity that is hurt";["type"]="Type of the damage";};["realm"]="sv";["server"]=true;["summary"]="\
Called when an entity is damaged ";};["FinishChat"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Called when the local player closes their chat window.";["name"]="FinishChat";["param"]={};["realm"]="cl";["summary"]="\
Called when the local player closes their chat window.";};["GravGunOnDropped"]={["class"]="hook";["classForced"]=true;["description"]="\
Called when an entity is being dropped by a gravity gun";["name"]="GravGunOnDropped";["param"]={[1]="ply";[2]="ent";["ent"]="Entity being dropped";["ply"]="Player dropping the object";};["realm"]="sv";["server"]=true;["summary"]="\
Called when an entity is being dropped by a gravity gun ";};["GravGunOnPickedUp"]={["class"]="hook";["classForced"]=true;["description"]="\
Called when an entity is being picked up by a gravity gun";["name"]="GravGunOnPickedUp";["param"]={[1]="ply";[2]="ent";["ent"]="Entity being picked up";["ply"]="Player picking up an object";};["realm"]="sv";["server"]=true;["summary"]="\
Called when an entity is being picked up by a gravity gun ";};["GravGunPunt"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Called when a player punts with the gravity gun";["name"]="GravGunPunt";["param"]={[1]="ply";[2]="ent";["ent"]="Entity being punted";["ply"]="Player punting the gravgun";};["realm"]="sh";["server"]=true;["summary"]="\
Called when a player punts with the gravity gun ";};["KeyPress"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Called when a player presses a key";["name"]="KeyPress";["param"]={[1]="ply";[2]="key";["key"]="The key being pressed";["ply"]="Player pressing the key";};["realm"]="sh";["server"]=true;["summary"]="\
Called when a player presses a key ";};["KeyRelease"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Called when a player releases a key";["name"]="KeyRelease";["param"]={[1]="ply";[2]="key";["key"]="The key being released";["ply"]="Player releasing the key";};["realm"]="sh";["server"]=true;["summary"]="\
Called when a player releases a key ";};["NetworkEntityCreated"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Called when a clientside entity gets created or re-created via lag/PVS";["name"]="NetworkEntityCreated";["param"]={[1]="ent";["ent"]="New entity";};["realm"]="cl";["summary"]="\
Called when a clientside entity gets created or re-created via lag/PVS ";};["OnEntityCreated"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Called when an entity gets created";["name"]="OnEntityCreated";["param"]={[1]="ent";["ent"]="New entity";};["realm"]="sh";["server"]=true;["summary"]="\
Called when an entity gets created ";};["OnPhysgunFreeze"]={["class"]="hook";["classForced"]=true;["description"]="\
Called when an entity is being frozen";["name"]="OnPhysgunFreeze";["param"]={[1]="physgun";[2]="physobj";[3]="ent";[4]="ply";["ent"]="Entity being frozen";["physgun"]="Entity of the physgun";["physobj"]="PhysObj of the entity";["ply"]="Player freezing the entity";};["realm"]="sv";["server"]=true;["summary"]="\
Called when an entity is being frozen ";};["OnPhysgunReload"]={["class"]="hook";["classForced"]=true;["description"]="\
Called when a player reloads his physgun";["name"]="OnPhysgunReload";["param"]={[1]="physgun";[2]="ply";["physgun"]="Entity of the physgun";["ply"]="Player reloading the physgun";};["realm"]="sv";["server"]=true;["summary"]="\
Called when a player reloads his physgun ";};["PhysgunDrop"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Called when an entity being held by a physgun gets dropped";["name"]="PhysgunDrop";["param"]={[1]="ply";[2]="ent";["ent"]="Entity being dropped";["ply"]="Player droppig the entity";};["realm"]="sh";["server"]=true;["summary"]="\
Called when an entity being held by a physgun gets dropped ";};["PhysgunPickup"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Called when an entity gets picked up by a physgun";["name"]="PhysgunPickup";["param"]={[1]="ply";[2]="ent";["ent"]="Entity being picked up";["ply"]="Player picking up the entity";};["realm"]="sh";["server"]=true;["summary"]="\
Called when an entity gets picked up by a physgun ";};["PlayerCanPickupWeapon"]={["class"]="hook";["classForced"]=true;["description"]="\
Called when a wants to pick up a weapon";["name"]="PlayerCanPickupWeapon";["param"]={[1]="ply";[2]="wep";["ply"]="Player";["wep"]="Weapon";};["realm"]="sv";["server"]=true;["summary"]="\
Called when a wants to pick up a weapon ";};["PlayerChat"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Called when a player's chat message is printed to the chat window";["name"]="PlayerChat";["param"]={[1]="ply";[2]="text";[3]="team";[4]="isdead";["isdead"]="Whether the message was send from a dead player";["ply"]="Player that said the message";["team"]="Whether the message was team only";["text"]="The message";};["realm"]="cl";["summary"]="\
Called when a player's chat message is printed to the chat window ";};["PlayerDeath"]={["class"]="hook";["classForced"]=true;["description"]="\
Called when a player dies";["name"]="PlayerDeath";["param"]={[1]="ply";[2]="inflictor";[3]="attacker";["attacker"]="Entity that killed the player";["inflictor"]="Entity used to kill the player";["ply"]="Player who died";};["realm"]="sv";["server"]=true;["summary"]="\
Called when a player dies ";};["PlayerDisconnected"]={["class"]="hook";["classForced"]=true;["description"]="\
Called when a player disconnects";["name"]="PlayerDisconnected";["param"]={[1]="ply";["ply"]="Player that disconnected";};["realm"]="sv";["server"]=true;["summary"]="\
Called when a player disconnects ";};["PlayerEnteredVehicle"]={["class"]="hook";["classForced"]=true;["description"]="\
Called when a players enters a vehicle";["name"]="PlayerEnteredVehicle";["param"]={[1]="ply";[2]="vehicle";[3]="num";["num"]="Role";["ply"]="Player who entered a vehicle";["vehicle"]="Vehicle that was entered";};["realm"]="sv";["server"]=true;["summary"]="\
Called when a players enters a vehicle ";};["PlayerHurt"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Called when a player gets hurt";["name"]="PlayerHurt";["param"]={[1]="ply";[2]="attacker";[3]="newHealth";[4]="damageTaken";["attacker"]="Entity causing damage to the player";["damageTaken"]="Amount of damage the player has taken";["newHealth"]="New health of the player";["ply"]="Player being hurt";};["realm"]="sh";["server"]=true;["summary"]="\
Called when a player gets hurt ";};["PlayerInitialSpawn"]={["class"]="hook";["classForced"]=true;["description"]="\
Called when a player spawns for the first time";["name"]="PlayerInitialSpawn";["param"]={[1]="ply";["ply"]="Player who spawned";};["realm"]="sv";["server"]=true;["summary"]="\
Called when a player spawns for the first time ";};["PlayerLeaveVehicle"]={["class"]="hook";["classForced"]=true;["description"]="\
Called when a players leaves a vehicle";["name"]="PlayerLeaveVehicle";["param"]={[1]="ply";[2]="vehicle";["ply"]="Player who left a vehicle";["vehicle"]="Vehicle that was left";};["realm"]="sv";["server"]=true;["summary"]="\
Called when a players leaves a vehicle ";};["PlayerNoClip"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Called when a player toggles noclip";["name"]="PlayerNoClip";["param"]={[1]="ply";[2]="newState";["newState"]="New noclip state. True if on.";["ply"]="Player toggling noclip";};["realm"]="sh";["server"]=true;["summary"]="\
Called when a player toggles noclip ";};["PlayerSay"]={["class"]="hook";["classForced"]=true;["description"]="\
Called when a player sends a chat message";["name"]="PlayerSay";["param"]={[1]="ply";[2]="text";[3]="teamChat";["ply"]="Player that sent the message";["teamChat"]="True if team chat";["text"]="Content of the message";};["realm"]="sv";["ret"]="New text. \"\" to stop from displaying. Nil to keep original.";["server"]=true;["summary"]="\
Called when a player sends a chat message ";};["PlayerSpawn"]={["class"]="hook";["classForced"]=true;["description"]="\
Called when a player spawns";["name"]="PlayerSpawn";["param"]={[1]="ply";["ply"]="Player who spawned";};["realm"]="sv";["server"]=true;["summary"]="\
Called when a player spawns ";};["PlayerSpray"]={["class"]="hook";["classForced"]=true;["description"]="\
Called when a players sprays his logo";["name"]="PlayerSpray";["param"]={[1]="ply";["ply"]="Player that sprayed";};["realm"]="sv";["server"]=true;["summary"]="\
Called when a players sprays his logo ";};["PlayerSwitchFlashlight"]={["class"]="hook";["classForced"]=true;["description"]="\
Called when a players turns their flashlight on or off";["name"]="PlayerSwitchFlashlight";["param"]={[1]="ply";[2]="state";["ply"]="Player switching flashlight";["state"]="New flashlight state. True if on.";};["realm"]="sv";["server"]=true;["summary"]="\
Called when a players turns their flashlight on or off ";};["PlayerSwitchWeapon"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Called when a player switches their weapon";["name"]="PlayerSwitchWeapon";["param"]={[1]="ply";[2]="oldwep";[3]="newweapon";["newweapon"]="New weapon";["oldwep"]="Old weapon";["ply"]="Player droppig the entity";};["realm"]="sh";["server"]=true;["summary"]="\
Called when a player switches their weapon ";};["PlayerUse"]={["class"]="hook";["classForced"]=true;["description"]="\
Called when a player holds their use key and looks at an entity. \
Will continuously run.";["name"]="PlayerUse";["param"]={[1]="ply";[2]="ent";["ent"]="Entity being used";["ply"]="Player using the entity";};["realm"]="sv";["server"]=true;["summary"]="\
Called when a player holds their use key and looks at an entity.";};["PropBreak"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Called when an entity is broken";["name"]="PropBreak";["param"]={[1]="ply";[2]="ent";["ent"]="Entity broken";["ply"]="Player who broke it";};["realm"]="sh";["server"]=true;["summary"]="\
Called when an entity is broken ";};["Removed"]={["class"]="hook";["classForced"]=true;["description"]="\
Called when the starfall chip is removed";["name"]="Removed";["param"]={};["realm"]="sv";["server"]=true;["summary"]="\
Called when the starfall chip is removed ";};["StartChat"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Called when the local player opens their chat window.";["name"]="StartChat";["param"]={};["realm"]="cl";["summary"]="\
Called when the local player opens their chat window.";};["StartEntityDriving"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Called when a player starts driving an entity";["name"]="StartEntityDriving";["param"]={[1]="ent";[2]="ply";["ent"]="Entity being driven";["ply"]="Player that is driving the entity";};["realm"]="sh";["server"]=true;["summary"]="\
Called when a player starts driving an entity ";};["calcview"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Called when the engine wants to calculate the player's view";["name"]="calcview";["param"]={[1]="pos";[2]="ang";[3]="fov";[4]="znear";[5]="zfar";["ang"]="Current angles of the camera";["fov"]="Current fov of the camera";["pos"]="Current position of the camera";["zfar"]="Current far plane of the camera";["znear"]="Current near plane of the camera";};["realm"]="cl";["ret"]="table Table containing information for the camera. {origin=camera origin, angles=camera angles, fov=camera fov, znear=znear, zfar=zfar, drawviewer=drawviewer, ortho=ortho table}";["summary"]="\
Called when the engine wants to calculate the player's view ";};["drawhud"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Called when a frame is requested to be drawn on hud. (2D Context)";["name"]="drawhud";["param"]={};["realm"]="cl";["summary"]="\
Called when a frame is requested to be drawn on hud.";};["hologrammatrix"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Called before entities are drawn. You can't render anything, but you can edit hologram matrices before they are drawn.";["name"]="hologrammatrix";["param"]={};["realm"]="cl";["summary"]="\
Called before entities are drawn.";};["hudconnected"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Called when the player connects to a HUD component linked to the Starfall Chip";["name"]="hudconnected";["param"]={};["realm"]="cl";["summary"]="\
Called when the player connects to a HUD component linked to the Starfall Chip ";};["huddisconnected"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Called when the player disconnects from a HUD component linked to the Starfall Chip";["name"]="huddisconnected";["param"]={};["realm"]="cl";["summary"]="\
Called when the player disconnects from a HUD component linked to the Starfall Chip ";};["hudshoulddraw"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Called when a hud element is attempting to be drawn";["name"]="hudshoulddraw";["param"]={[1]="string";["string"]="The name of the hud element trying to be drawn";};["realm"]="cl";["summary"]="\
Called when a hud element is attempting to be drawn ";};["input"]={["class"]="hook";["classForced"]=true;["description"]="\
Called when an input on a wired SF chip is written to";["name"]="input";["param"]={[1]="input";[2]="value";["input"]="The input name";["value"]="The value of the input";};["realm"]="sv";["summary"]="\
Called when an input on a wired SF chip is written to ";};["inputPressed"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Called when a button is pressed";["name"]="inputPressed";["param"]={[1]="button";["button"]="Number of the button";};["realm"]="cl";["summary"]="\
Called when a button is pressed ";};["inputReleased"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Called when a button is released";["name"]="inputReleased";["param"]={[1]="button";["button"]="Number of the button";};["realm"]="cl";["summary"]="\
Called when a button is released ";};["mouseWheeled"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Called when the mouse wheel is rotated";["name"]="mouseWheeled";["param"]={[1]="delta";["delta"]="Rotate delta";};["realm"]="cl";["summary"]="\
Called when the mouse wheel is rotated ";};["mousemoved"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Called when the mouse is moved";["name"]="mousemoved";["param"]={[1]="x";[2]="y";["x"]="X coordinate moved";["y"]="Y coordinate moved";};["realm"]="cl";["summary"]="\
Called when the mouse is moved ";};["net"]={["class"]="hook";["classForced"]=true;["description"]="\
Called when a net message arrives";["name"]="net";["param"]={[1]="name";[2]="len";[3]="ply";["len"]="Length of the arriving net message in bits";["name"]="Name of the arriving net message";["ply"]="On server, the player that sent the message. Nil on client.";};["realm"]="sh";["summary"]="\
Called when a net message arrives ";};["permissionrequest"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Called when local client changed instance permissions";["name"]="permissionrequest";["param"]={};["realm"]="cl";["summary"]="\
Called when local client changed instance permissions ";};["postdrawhud"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Called after drawing HUD (2D Context)";["name"]="postdrawhud";["param"]={};["realm"]="cl";["summary"]="\
Called after drawing HUD (2D Context) ";};["postdrawopaquerenderables"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Called after opaque entities are drawn. (Only works with HUD) (3D context)";["name"]="postdrawopaquerenderables";["param"]={[1]="boolean";["boolean"]="isDrawSkybox Whether the current draw is drawing the skybox.";};["realm"]="cl";["summary"]="\
Called after opaque entities are drawn.";};["predrawhud"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Called before drawing HUD (2D Context)";["name"]="predrawhud";["param"]={};["realm"]="cl";["summary"]="\
Called before drawing HUD (2D Context) ";};["predrawopaquerenderables"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Called before opaque entities are drawn. (Only works with HUD) (3D context)";["name"]="predrawopaquerenderables";["param"]={[1]="boolean";["boolean"]="isDrawSkybox Whether the current draw is drawing the skybox.";};["realm"]="cl";["summary"]="\
Called before opaque entities are drawn.";};["readcell"]={["class"]="hook";["classForced"]=true;["description"]="\
Called when a high speed device reads from a wired SF chip";["name"]="readcell";["param"]={[1]="address";["address"]="The address requested";};["realm"]="sv";["ret"]="The value read";["server"]=true;["summary"]="\
Called when a high speed device reads from a wired SF chip ";};["remote"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Remote hook. \
This hook can be called from other instances";["name"]="remote";["param"]={["..."]="The payload that was supplied when calling the hook";[1]="sender";[2]="owner";[3]="...";["owner"]="The owner of the sender";["sender"]="The entity that caused the hook to run";};["realm"]="sh";["server"]=true;["summary"]="\
Remote hook.";};["render"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Called when a frame is requested to be drawn on screen. (2D/3D Context)";["name"]="render";["param"]={};["realm"]="cl";["summary"]="\
Called when a frame is requested to be drawn on screen.";};["renderoffscreen"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Called when a frame is requested to be drawn. Doesn't require a screen or HUD but only works on rendertargets. (2D Context)";["name"]="renderoffscreen";["param"]={};["realm"]="cl";["summary"]="\
Called when a frame is requested to be drawn.";};["starfallUsed"]={["class"]="hook";["classForced"]=true;["description"]="\
Called when a player uses the screen";["name"]="starfallUsed";["param"]={[1]="activator";[2]="used";["activator"]="Player who used the screen or chip";["used"]="The screen or chip entity that was used";};["realm"]="cl";["summary"]="\
Called when a player uses the screen ";};["think"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Think hook. Called each frame on the client and each game tick on the server.";["name"]="think";["param"]={};["realm"]="sh";["server"]=true;["summary"]="\
Think hook.";};["tick"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Tick hook. Called each game tick on both the server and client.";["name"]="tick";["param"]={};["realm"]="sh";["server"]=true;["summary"]="\
Tick hook.";};["writecell"]={["class"]="hook";["classForced"]=true;["description"]="\
Called when a high speed device writes to a wired SF chip";["name"]="writecell";["param"]={[1]="address";[2]="data";["address"]="The address written to";["data"]="The data being written";};["realm"]="sv";["summary"]="\
Called when a high speed device writes to a wired SF chip ";};["xinputConnected"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Called when a controller has been connected. Client must have XInput Lua binary installed.";["name"]="xinputConnected";["param"]={[1]="id";[2]="when";["id"]="Controller number. Starts at 0";["when"]="The timer.realtime() at which this event occurred.";};["realm"]="cl";["summary"]="\
Called when a controller has been connected.";};["xinputDisconnected"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Called when a controller has been disconnected. Client must have XInput Lua binary installed.";["name"]="xinputDisconnected";["param"]={[1]="id";[2]="when";["id"]="Controller number. Starts at 0";["when"]="The timer.realtime() at which this event occurred.";};["realm"]="cl";["summary"]="\
Called when a controller has been disconnected.";};["xinputPressed"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Called when a controller button has been pressed. Client must have XInput Lua binary installed.";["name"]="xinputPressed";["param"]={[1]="id";[2]="button";[3]="when";["button"]="The button that was pushed. See https://github.com/mitterdoo/garrysmod-xinput#xinput_gamepad_";["id"]="Controller number. Starts at 0";["when"]="The timer.realtime() at which this event occurred.";};["realm"]="cl";["summary"]="\
Called when a controller button has been pressed.";};["xinputReleased"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Called when a controller button has been released. Client must have XInput Lua binary installed.";["name"]="xinputReleased";["param"]={[1]="id";[2]="button";[3]="when";["button"]="The button that was released. See https://github.com/mitterdoo/garrysmod-xinput#xinput_gamepad_";["id"]="Controller number. Starts at 0";["when"]="The timer.realtime() at which this event occurred.";};["realm"]="cl";["summary"]="\
Called when a controller button has been released.";};["xinputStick"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Called when a stick on the controller has moved. Client must have XInput Lua binary installed.";["name"]="xinputStick";["param"]={[1]="id";[2]="x";[3]="y";[4]="stick";[5]="when";["id"]="Controller number. Starts at 0";["stick"]="The stick that was moved. 0 is left";["when"]="The timer.realtime() at which this event occurred.";["x"]="The X coordinate of the trigger. -32768 - 32767 inclusive";["y"]="The Y coordinate of the trigger. -32768 - 32767 inclusive";};["realm"]="cl";["summary"]="\
Called when a stick on the controller has moved.";};["xinputTrigger"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Called when a trigger on the controller has moved. Client must have XInput Lua binary installed.";["name"]="xinputTrigger";["param"]={[1]="id";[2]="value";[3]="trigger";[4]="when";["id"]="Controller number. Starts at 0";["trigger"]="The trigger that was moved. 0 is left";["value"]="The position of the trigger. 0-255 inclusive";["when"]="The timer.realtime() at which this event occurred.";};["realm"]="cl";["summary"]="\
Called when a trigger on the controller has moved.";};};["libraries"]={[1]="builtin";["builtin"]={["class"]="library";["classForced"]=true;["client"]=true;["description"]="\
Built in values. These don't need to be loaded; they are in the default environment.";["fields"]={[1]="CLIENT";[2]="SERVER";["CLIENT"]={["class"]="field";["classForced"]=true;["description"]="\
Constant that denotes whether the code is executed on the client";["library"]="builtin";["name"]="Environment.CLIENT";["param"]={};["summary"]="\
Constant that denotes whether the code is executed on the client ";};["SERVER"]={["class"]="field";["classForced"]=true;["description"]="\
Constant that denotes whether the code is executed on the server";["library"]="builtin";["name"]="Environment.SERVER";["param"]={};["summary"]="\
Constant that denotes whether the code is executed on the server ";};};["functions"]={[1]="assert";[10]="error";[11]="eyeAngles";[12]="eyePos";[13]="eyeVector";[14]="getLibraries";[15]="getMethods";[16]="getScripts";[17]="getUserdata";[18]="getfenv";[19]="getmetatable";[2]="chip";[20]="hasPermission";[21]="ipairs";[22]="isFirstTimePredicted";[23]="isValid";[24]="loadstring";[25]="localToWorld";[26]="next";[27]="owner";[28]="pairs";[29]="pcall";[3]="class";[30]="permissionRequestSatisfied";[31]="player";[32]="printMessage";[33]="printTable";[34]="quotaAverage";[35]="quotaMax";[36]="quotaTotalAverage";[37]="quotaTotalUsed";[38]="quotaUsed";[39]="ramAverage";[4]="concmd";[40]="ramUsed";[41]="rawget";[42]="rawset";[43]="require";[44]="requiredir";[45]="select";[46]="setClipboardText";[47]="setName";[48]="setSoftQuota";[49]="setUserdata";[5]="crc";[50]="setfenv";[51]="setmetatable";[52]="setupPermissionRequest";[53]="throw";[54]="tonumber";[55]="tostring";[56]="try";[57]="type";[58]="unpack";[59]="version";[6]="debugGetInfo";[60]="worldToLocal";[61]="xpcall";[7]="dodir";[8]="dofile";[9]="entity";["assert"]={["class"]="function";["classForced"]=true;["description"]="\
If the result of the first argument is false or nil, an error is thrown with the second argument as the message.";["fname"]="assert";["library"]="builtin";["name"]="Environment.assert";["param"]={[1]="condition";[2]="msg";["condition"]="";["msg"]="";};["private"]=false;["realm"]="sh";["summary"]="\
If the result of the first argument is false or nil, an error is thrown with the second argument as the message.";};["chip"]={["class"]="function";["description"]="\
Returns the entity representing a processor that this script is running on.";["fname"]="chip";["library"]="builtin";["name"]="Environment.chip";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Starfall entity";["summary"]="\
Returns the entity representing a processor that this script is running on.";};["class"]={["class"]="function";["classForced"]=true;["description"]="\
Creates a 'middleclass' class object that can be used similarly to Java/C++ classes. See https://github.com/kikito/middleclass for examples.";["fname"]="class";["library"]="builtin";["name"]="Environment.class";["param"]={[1]="name";[2]="super";["name"]="The string name of the class";["super"]="The (optional) parent class to inherit from";};["realm"]="sh";["summary"]="\
Creates a 'middleclass' class object that can be used similarly to Java/C++ classes.";};["concmd"]={["class"]="function";["client"]=true;["description"]="\
Execute a console command";["fname"]="concmd";["library"]="builtin";["name"]="Environment.concmd";["param"]={[1]="cmd";["cmd"]="Command to execute";};["private"]=false;["realm"]="sh";["server"]=true;["summary"]="\
Execute a console command ";};["crc"]={["class"]="function";["classForced"]=true;["description"]="\
Generates the CRC checksum of the specified string. (https://en.wikipedia.org/wiki/Cyclic_redundancy_check)";["fname"]="crc";["library"]="builtin";["name"]="Environment.crc";["param"]={[1]="stringToHash";["stringToHash"]="The string to calculate the checksum of";};["realm"]="sh";["ret"]="The unsigned 32 bit checksum as a string";["summary"]="\
Generates the CRC checksum of the specified string.";};["debugGetInfo"]={["class"]="function";["description"]="\
GLua's getinfo() \
Returns a DebugInfo structure containing the passed function's info (https://wiki.garrysmod.com/page/Structures/DebugInfo)";["fname"]="debugGetInfo";["library"]="builtin";["name"]="Environment.debugGetInfo";["param"]={[1]="funcOrStackLevel";[2]="fields";["fields"]="A string that specifies the information to be retrieved. Defaults to all (flnSu).";["funcOrStackLevel"]="Function or stack level to get info about. Defaults to stack level 0.";};["private"]=false;["realm"]="sh";["ret"]="DebugInfo table";["summary"]="\
GLua's getinfo() \
Returns a DebugInfo structure containing the passed function's info (https://wiki.garrysmod.com/page/Structures/DebugInfo) ";};["dodir"]={["class"]="function";["description"]="\
Runs an included directory, but does not cache the result.";["fname"]="dodir";["library"]="builtin";["name"]="Environment.dodir";["param"]={[1]="dir";[2]="loadpriority";["dir"]="The directory to include. Make sure to --@includedir it";["loadpriority"]="Table of files that should be loaded before any others in the directory";};["private"]=false;["realm"]="sh";["ret"]="Table of return values of the scripts";["summary"]="\
Runs an included directory, but does not cache the result.";};["dofile"]={["class"]="function";["description"]="\
Runs an included script, but does not cache the result. \
Pretty much like standard Lua dofile()";["fname"]="dofile";["library"]="builtin";["name"]="Environment.dofile";["param"]={[1]="file";["file"]="The file to include. Make sure to --@include it";};["private"]=false;["realm"]="sh";["ret"]="Return value of the script";["summary"]="\
Runs an included script, but does not cache the result.";};["entity"]={["class"]="function";["description"]="\
Returns the entity with index 'num'";["fname"]="entity";["library"]="builtin";["name"]="Environment.entity";["param"]={[1]="num";["num"]="Entity index";};["private"]=false;["realm"]="sh";["ret"]="entity";["summary"]="\
Returns the entity with index 'num' ";};["error"]={["class"]="function";["description"]="\
Throws a raw exception.";["fname"]="error";["library"]="builtin";["name"]="Environment.error";["param"]={[1]="msg";[2]="level";["level"]="Which level in the stacktrace to blame. Defaults to 1";["msg"]="Exception message";};["private"]=false;["realm"]="sh";["summary"]="\
Throws a raw exception.";};["eyeAngles"]={["class"]="function";["client"]=true;["description"]="\
Returns the local player's camera angles";["fname"]="eyeAngles";["library"]="builtin";["name"]="Environment.eyeAngles";["param"]={};["private"]=false;["realm"]="cl";["ret"]="The local player's camera angles";["summary"]="\
Returns the local player's camera angles ";};["eyePos"]={["class"]="function";["client"]=true;["description"]="\
Returns the local player's camera position";["fname"]="eyePos";["library"]="builtin";["name"]="Environment.eyePos";["param"]={};["private"]=false;["realm"]="cl";["ret"]="The local player's camera position";["summary"]="\
Returns the local player's camera position ";};["eyeVector"]={["class"]="function";["client"]=true;["description"]="\
Returns the local player's camera forward vector";["fname"]="eyeVector";["library"]="builtin";["name"]="Environment.eyeVector";["param"]={};["private"]=false;["realm"]="cl";["ret"]="The local player's camera forward vector";["summary"]="\
Returns the local player's camera forward vector ";};["getLibraries"]={["class"]="function";["description"]="\
Gets all libraries";["fname"]="getLibraries";["library"]="builtin";["name"]="Environment.getLibraries";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Table where each key is the library name and value is table of the library";["summary"]="\
Gets all libraries ";};["getMethods"]={["class"]="function";["description"]="\
Gets an SF type's methods table";["fname"]="getMethods";["library"]="builtin";["name"]="Environment.getMethods";["param"]={[1]="sfType";["sfType"]="Name of SF type";};["private"]=false;["realm"]="sh";["ret"]="Table of the type's methods which can be edited or iterated";["summary"]="\
Gets an SF type's methods table ";};["getScripts"]={["class"]="function";["description"]="\
Returns the table of scripts used by the chip";["fname"]="getScripts";["library"]="builtin";["name"]="Environment.getScripts";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Table of scripts used by the chip";["summary"]="\
Returns the table of scripts used by the chip ";};["getUserdata"]={["class"]="function";["description"]="\
Gets the chip's userdata that the duplicator tool loads";["fname"]="getUserdata";["library"]="builtin";["name"]="Environment.getUserdata";["param"]={};["private"]=false;["realm"]="sv";["ret"]="String data";["server"]=true;["summary"]="\
Gets the chip's userdata that the duplicator tool loads ";};["getfenv"]={["class"]="function";["description"]="\
Simple version of Lua's getfenv \
Returns the current environment";["fname"]="getfenv";["library"]="builtin";["name"]="Environment.getfenv";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Current environment";["summary"]="\
Simple version of Lua's getfenv \
Returns the current environment ";};["getmetatable"]={["class"]="function";["description"]="\
Returns the metatable of an object. Doesn't work on most internal metatables";["fname"]="getmetatable";["library"]="builtin";["name"]="Environment.getmetatable";["param"]={[1]="tbl";["tbl"]="Table to get metatable of";};["private"]=false;["realm"]="sh";["ret"]="The metatable of tbl";["summary"]="\
Returns the metatable of an object.";};["hasPermission"]={["class"]="function";["description"]="\
Checks if the chip is capable of performing an action.";["fname"]="hasPermission";["library"]="builtin";["name"]="Environment.hasPermission";["param"]={[1]="perm";[2]="obj";["obj"]="Optional object to pass to the permission system.";["perm"]="The permission id to check";};["private"]=false;["realm"]="sh";["summary"]="\
Checks if the chip is capable of performing an action.";};["ipairs"]={["class"]="function";["classForced"]=true;["description"]="\
Returns an iterator function for a for loop, to return ordered key-value pairs from a table.";["fname"]="ipairs";["library"]="builtin";["name"]="Environment.ipairs";["param"]={[1]="tbl";["tbl"]="Table to iterate over";};["realm"]="sh";["ret"]={[1]="Iterator function";[2]="Table tbl";[3]="0 as current index";};["summary"]="\
Returns an iterator function for a for loop, to return ordered key-value pairs from a table.";};["isFirstTimePredicted"]={["class"]="function";["classForced"]=true;["description"]="\
Returns if this is the first time this hook was predicted.";["fname"]="isFirstTimePredicted";["library"]="builtin";["name"]="Environment.isFirstTimePredicted";["param"]={};["realm"]="sh";["ret"]="Boolean";["summary"]="\
Returns if this is the first time this hook was predicted.";};["isValid"]={["class"]="function";["description"]="\
Returns if the table has an isValid function and isValid returns true.";["fname"]="isValid";["library"]="builtin";["name"]="Environment.isValid";["param"]={[1]="object";["object"]="Table to check";};["private"]=false;["realm"]="sh";["ret"]="If it is valid";["summary"]="\
Returns if the table has an isValid function and isValid returns true.";};["loadstring"]={["class"]="function";["description"]="\
GLua's loadstring \
Works like loadstring, except that it executes by default in the main environment";["fname"]="loadstring";["library"]="builtin";["name"]="Environment.loadstring";["param"]={[1]="str";[2]="name";["str"]="String to execute";};["private"]=false;["realm"]="sh";["ret"]="Function of str";["summary"]="\
GLua's loadstring \
Works like loadstring, except that it executes by default in the main environment ";};["localToWorld"]={["class"]="function";["description"]="\
Translates the specified position and angle from the specified local coordinate system";["fname"]="localToWorld";["library"]="builtin";["name"]="Environment.localToWorld";["param"]={[1]="localPos";[2]="localAng";[3]="originPos";[4]="originAngle";["localAng"]="The angle that should be converted to a world angle";["localPos"]="The position vector that should be translated to world coordinates";["originAngle"]="The angles of the source coordinate system, as a world angle";["originPos"]="The origin point of the source coordinate system, in world coordinates";};["private"]=false;["realm"]="sh";["ret"]={[1]="worldPos";[2]="worldAngles";};["summary"]="\
Translates the specified position and angle from the specified local coordinate system ";};["next"]={["class"]="function";["classForced"]=true;["description"]="\
Returns the next key and value pair in a table.";["fname"]="next";["library"]="builtin";["name"]="Environment.next";["param"]={[1]="tbl";[2]="k";["k"]="Previous key (can be nil)";["tbl"]="Table to get the next key-value pair of";};["realm"]="sh";["ret"]={[1]="Key or nil";[2]="Value or nil";};["summary"]="\
Returns the next key and value pair in a table.";};["owner"]={["class"]="function";["classForced"]=true;["description"]="\
Returns whoever created the chip";["fname"]="owner";["library"]="builtin";["name"]="Environment.owner";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Owner entity";["summary"]="\
Returns whoever created the chip ";};["pairs"]={["class"]="function";["classForced"]=true;["description"]="\
Returns an iterator function for a for loop that will return the values of the specified table in an arbitrary order.";["fname"]="pairs";["library"]="builtin";["name"]="Environment.pairs";["param"]={[1]="tbl";["tbl"]="Table to iterate over";};["realm"]="sh";["ret"]={[1]="Iterator function";[2]="Table tbl";[3]="nil as current index";};["summary"]="\
Returns an iterator function for a for loop that will return the values of the specified table in an arbitrary order.";};["pcall"]={["class"]="function";["description"]="\
Lua's pcall with SF throw implementation \
Calls a function and catches an error that can be thrown while the execution of the call.";["fname"]="pcall";["library"]="builtin";["name"]="Environment.pcall";["param"]={[1]="func";[2]="...";[3]="arguments";["arguments"]="Arguments to call the function with.";["func"]="Function to be executed and of which the errors should be caught of";};["private"]=false;["realm"]="sh";["ret"]={[1]="If the function had no errors occur within it.";[2]="If an error occurred, this will be a string containing the error message. Otherwise, this will be the return values of the function passed in.";};["summary"]="\
Lua's pcall with SF throw implementation \
Calls a function and catches an error that can be thrown while the execution of the call.";};["permissionRequestSatisfied"]={["class"]="function";["client"]=true;["description"]="\
Is permission request fully satisfied.";["fname"]="permissionRequestSatisfied";["library"]="builtin";["name"]="Environment.permissionRequestSatisfied";["param"]={};["private"]=false;["realm"]="cl";["ret"]="Boolean of whether the client gave all permissions specified in last request or not.";["summary"]="\
Is permission request fully satisfied.";};["player"]={["class"]="function";["description"]="\
Same as owner() on the server. On the client, returns the local player";["fname"]="player";["library"]="builtin";["name"]="Environment.player";["param"]={[1]="num";};["private"]=false;["realm"]="sh";["ret"]="Returns player with given UserID or if none specified then returns either the owner (server) or the local player (client)";["summary"]="\
Same as owner() on the server.";};["printMessage"]={["class"]="function";["description"]="\
Prints a message to your chat, console, or the center of your screen.";["fname"]="printMessage";["library"]="builtin";["name"]="Environment.printMessage";["param"]={[1]="mtype";[2]="text";["mtype"]="How the message should be displayed. See http://wiki.garrysmod.com/page/Enums/HUD";["text"]="The message text.";};["private"]=false;["realm"]="sh";["summary"]="\
Prints a message to your chat, console, or the center of your screen.";};["printTable"]={["class"]="function";["description"]="\
Prints a table to player's chat";["fname"]="printTable";["library"]="builtin";["name"]="Environment.printTable";["param"]={[1]="tbl";["tbl"]="Table to print";};["private"]=false;["realm"]="sh";["summary"]="\
Prints a table to player's chat ";};["quotaAverage"]={["class"]="function";["description"]="\
Gets the Average CPU Time in the buffer";["fname"]="quotaAverage";["library"]="builtin";["name"]="Environment.quotaAverage";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Average CPU Time of the buffer.";["summary"]="\
Gets the Average CPU Time in the buffer ";};["quotaMax"]={["class"]="function";["description"]="\
Gets the CPU Time max. \
CPU Time is stored in a buffer of N elements, if the average of this exceeds quotaMax, the chip will error.";["fname"]="quotaMax";["library"]="builtin";["name"]="Environment.quotaMax";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Max SysTime allowed to take for execution of the chip in a Think.";["summary"]="\
Gets the CPU Time max.";};["quotaTotalAverage"]={["class"]="function";["description"]="\
Returns the total average time for all chips by the player.";["fname"]="quotaTotalAverage";["library"]="builtin";["name"]="Environment.quotaTotalAverage";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Total average CPU Time of all your chips.";["summary"]="\
Returns the total average time for all chips by the player.";};["quotaTotalUsed"]={["class"]="function";["description"]="\
Returns the total used time for all chips by the player.";["fname"]="quotaTotalUsed";["library"]="builtin";["name"]="Environment.quotaTotalUsed";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Total used CPU time of all your chips.";["summary"]="\
Returns the total used time for all chips by the player.";};["quotaUsed"]={["class"]="function";["description"]="\
Returns the current count for this Think's CPU Time. \
This value increases as more executions are done, may not be exactly as you want. \
If used on screens, will show 0 if only rendering is done. Operations must be done in the Think loop for them to be counted.";["fname"]="quotaUsed";["library"]="builtin";["name"]="Environment.quotaUsed";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Current quota used this Think";["summary"]="\
Returns the current count for this Think's CPU Time.";};["ramAverage"]={["class"]="function";["description"]="\
Gets the moving average of ram usage of the lua environment";["fname"]="ramAverage";["library"]="builtin";["name"]="Environment.ramAverage";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The ram used in bytes";["summary"]="\
Gets the moving average of ram usage of the lua environment ";};["ramUsed"]={["class"]="function";["description"]="\
Gets the current ram usage of the lua environment";["fname"]="ramUsed";["library"]="builtin";["name"]="Environment.ramUsed";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The ram used in bytes";["summary"]="\
Gets the current ram usage of the lua environment ";};["rawget"]={["class"]="function";["description"]="\
Gets the value of a table index without invoking a metamethod";["fname"]="rawget";["library"]="builtin";["name"]="Environment.rawget";["param"]={[1]="table";[2]="key";[3]="value";["key"]="The index of the table";["table"]="The table to get the value from";};["private"]=false;["realm"]="sh";["ret"]="The value of the index";["summary"]="\
Gets the value of a table index without invoking a metamethod ";};["rawset"]={["class"]="function";["description"]="\
Set the value of a table index without invoking a metamethod";["fname"]="rawset";["library"]="builtin";["name"]="Environment.rawset";["param"]={[1]="table";[2]="key";[3]="value";["key"]="The index of the table";["table"]="The table to modify";["value"]="The value to set the index equal to";};["private"]=false;["realm"]="sh";["summary"]="\
Set the value of a table index without invoking a metamethod ";};["require"]={["class"]="function";["description"]="\
Runs an included script and caches the result. \
Works pretty much like standard Lua require()";["fname"]="require";["library"]="builtin";["name"]="Environment.require";["param"]={[1]="file";["file"]="The file to include. Make sure to --@include it";};["private"]=false;["realm"]="sh";["ret"]="Return value of the script";["summary"]="\
Runs an included script and caches the result.";};["requiredir"]={["class"]="function";["description"]="\
Runs an included script and caches the result. \
Works pretty much like standard Lua require()";["fname"]="requiredir";["library"]="builtin";["name"]="Environment.requiredir";["param"]={[1]="dir";[2]="loadpriority";["dir"]="The directory to include. Make sure to --@includedir it";["loadpriority"]="Table of files that should be loaded before any others in the directory";};["private"]=false;["realm"]="sh";["ret"]="Table of return values of the scripts";["summary"]="\
Runs an included script and caches the result.";};["select"]={["class"]="function";["classForced"]=true;["description"]="\
Used to select single values from a vararg or get the count of values in it.";["fname"]="select";["library"]="builtin";["name"]="Environment.select";["param"]={[1]="parameter";[2]="vararg";["parameter"]="";["vararg"]="";};["realm"]="sh";["ret"]="Returns a number or vararg, depending on the select method.";["summary"]="\
Used to select single values from a vararg or get the count of values in it.";};["setClipboardText"]={["class"]="function";["description"]="\
Sets clipboard text. Only works on the owner of the chip.";["fname"]="setClipboardText";["library"]="builtin";["name"]="Environment.setClipboardText";["param"]={[1]="txt";["txt"]="Text to set to the clipboard";};["private"]=false;["realm"]="sh";["summary"]="\
Sets clipboard text.";};["setName"]={["class"]="function";["client"]=true;["description"]="\
Sets the chip's display name";["fname"]="setName";["library"]="builtin";["name"]="Environment.setName";["param"]={[1]="name";["name"]="Name";};["private"]=false;["realm"]="cl";["summary"]="\
Sets the chip's display name ";};["setSoftQuota"]={["class"]="function";["description"]="\
Sets a CPU soft quota which will trigger a catchable error if the cpu goes over a certain amount.";["fname"]="setSoftQuota";["library"]="builtin";["name"]="Environment.setSoftQuota";["param"]={[1]="quota";["quota"]="The threshold where the soft error will be thrown. Ratio of current cpu to the max cpu usage. 0.5 is 50%";};["private"]=false;["realm"]="sh";["summary"]="\
Sets a CPU soft quota which will trigger a catchable error if the cpu goes over a certain amount.";};["setUserdata"]={["class"]="function";["description"]="\
Sets the chip's userdata that the duplicator tool saves. max 1MiB; can be changed with convar sf_userdata_max";["fname"]="setUserdata";["library"]="builtin";["name"]="Environment.setUserdata";["param"]={[1]="str";["str"]="String data";};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Sets the chip's userdata that the duplicator tool saves.";};["setfenv"]={["class"]="function";["description"]="\
Lua's setfenv \
Works like setfenv, but is restricted on functions";["fname"]="setfenv";["library"]="builtin";["name"]="Environment.setfenv";["param"]={[1]="func";[2]="tbl";["func"]="Function to change environment of";["tbl"]="New environment";};["private"]=false;["realm"]="sh";["ret"]="func with environment set to tbl";["summary"]="\
Lua's setfenv \
Works like setfenv, but is restricted on functions ";};["setmetatable"]={["class"]="function";["classForced"]=true;["description"]="\
Sets, changes or removes a table's metatable. Doesn't work on most internal metatables";["fname"]="setmetatable";["library"]="builtin";["name"]="Environment.setmetatable";["param"]={[1]="tbl";[2]="meta";["meta"]="The metatable to use";["tbl"]="The table to set the metatable of";};["realm"]="sh";["ret"]="tbl with metatable set to meta";["summary"]="\
Sets, changes or removes a table's metatable.";};["setupPermissionRequest"]={["class"]="function";["client"]=true;["description"]="\
Setups request for overriding permissions.";["fname"]="setupPermissionRequest";["library"]="builtin";["name"]="Environment.setupPermissionRequest";["param"]={[1]="perms";[2]="desc";[3]="showOnUse";["desc"]="Description attached to request.";["perms"]="Table of overridable permissions' names.";["showOnUse"]="Whether request will popup when player uses chip or linked screen.";};["private"]=false;["realm"]="cl";["summary"]="\
Setups request for overriding permissions.";};["throw"]={["class"]="function";["description"]="\
Throws an exception";["fname"]="throw";["library"]="builtin";["name"]="Environment.throw";["param"]={[1]="msg";[2]="level";[3]="uncatchable";["level"]="Which level in the stacktrace to blame. Defaults to 1";["msg"]="Message string";["uncatchable"]="Makes this exception uncatchable";};["private"]=false;["realm"]="sh";["summary"]="\
Throws an exception ";};["tonumber"]={["class"]="function";["classForced"]=true;["description"]="\
Attempts to convert the value to a number.";["fname"]="tonumber";["library"]="builtin";["name"]="Environment.tonumber";["param"]={[1]="obj";["obj"]="";};["realm"]="sh";["ret"]="obj as number";["summary"]="\
Attempts to convert the value to a number.";};["tostring"]={["class"]="function";["classForced"]=true;["description"]="\
Attempts to convert the value to a string.";["fname"]="tostring";["library"]="builtin";["name"]="Environment.tostring";["param"]={[1]="obj";["obj"]="";};["realm"]="sh";["ret"]="obj as string";["summary"]="\
Attempts to convert the value to a string.";};["try"]={["class"]="function";["description"]="\
Try to execute a function and catch possible exceptions \
Similar to xpcall, but a bit more in-depth";["fname"]="try";["library"]="builtin";["name"]="Environment.try";["param"]={[1]="func";[2]="catch";["catch"]="Optional function to execute in case func fails";["func"]="Function to execute";};["private"]=false;["realm"]="sh";["summary"]="\
Try to execute a function and catch possible exceptions \
Similar to xpcall, but a bit more in-depth ";};["type"]={["class"]="function";["classForced"]=true;["description"]="\
Returns a string representing the name of the type of the passed object.";["fname"]="type";["library"]="builtin";["name"]="Environment.type";["param"]={[1]="obj";["obj"]="Object to get type of";};["private"]=false;["realm"]="sh";["ret"]="The name of the object's type.";["summary"]="\
Returns a string representing the name of the type of the passed object.";};["unpack"]={["class"]="function";["classForced"]=true;["description"]="\
This function takes a numeric indexed table and return all the members as a vararg.";["fname"]="unpack";["library"]="builtin";["name"]="Environment.unpack";["param"]={[1]="tbl";["tbl"]="";};["realm"]="sh";["ret"]="Elements of tbl";["summary"]="\
This function takes a numeric indexed table and return all the members as a vararg.";};["version"]={["class"]="function";["description"]="\
Gets the starfall version";["fname"]="version";["library"]="builtin";["name"]="Environment.version";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Starfall version";["summary"]="\
Gets the starfall version ";};["worldToLocal"]={["class"]="function";["description"]="\
Translates the specified position and angle into the specified coordinate system";["fname"]="worldToLocal";["library"]="builtin";["name"]="Environment.worldToLocal";["param"]={[1]="pos";[2]="ang";[3]="newSystemOrigin";[4]="newSystemAngles";["ang"]="The angles that should be translated from the current to the new system";["newSystemAngles"]="The angles of the system to translate to";["newSystemOrigin"]="The origin of the system to translate to";["pos"]="The position that should be translated from the current to the new system";};["private"]=false;["realm"]="sh";["ret"]={[1]="localPos";[2]="localAngles";};["summary"]="\
Translates the specified position and angle into the specified coordinate system ";};["xpcall"]={["class"]="function";["description"]="\
Lua's xpcall with SF throw implementation, and a traceback for debugging. \
Attempts to call the first function. If the execution succeeds, this returns true followed by the returns of the function. \
If execution fails, this returns false and the second function is called with the error message, and the stack trace.";["fname"]="xpcall";["library"]="builtin";["name"]="Environment.xpcall";["param"]={["..."]="Varargs to pass to the initial function.";[1]="func";[2]="callback";[3]="...";["callback"]="The function to be called if execution of the first fails; the error message and stack trace are passed.";["func"]="The function to call initially.";};["private"]=false;["realm"]="sh";["ret"]={[1]="Status of the execution; true for success, false for failure.";[2]="The returns of the first function if execution succeeded, otherwise the return values of the error callback.";};["summary"]="\
Lua's xpcall with SF throw implementation, and a traceback for debugging.";};};["libtbl"]="Environment";["name"]="builtin";["server"]=true;["summary"]="\
Built in values.";["tables"]={[1]="math";[2]="os";[3]="string";[4]="table";["math"]={["class"]="table";["classForced"]=true;["description"]="\
The math library. http://wiki.garrysmod.com/page/Category:math";["library"]="builtin";["name"]="Environment.math";["param"]={};["summary"]="\
The math library.";["tname"]="math";};["os"]={["class"]="table";["classForced"]=true;["description"]="\
The os library. http://wiki.garrysmod.com/page/Category:os";["library"]="builtin";["name"]="Environment.os";["param"]={};["summary"]="\
The os library.";["tname"]="os";};["string"]={["class"]="table";["classForced"]=true;["description"]="\
String library http://wiki.garrysmod.com/page/Category:string";["library"]="builtin";["name"]="Environment.string";["param"]={};["summary"]="\
String library http://wiki.garrysmod.com/page/Category:string ";["tname"]="string";};["table"]={["class"]="table";["classForced"]=true;["description"]="\
Table library. http://wiki.garrysmod.com/page/Category:table";["library"]="builtin";["name"]="Environment.table";["param"]={};["summary"]="\
Table library.";["tname"]="table";};};};};};