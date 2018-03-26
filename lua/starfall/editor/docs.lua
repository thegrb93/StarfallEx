SF.Docs={["classes"]={[1]="Angle";[10]="PhysObj";[11]="Player";[12]="Quaternion";[13]="Sound";[14]="VMatrix";[15]="Vector";[16]="Vehicle";[17]="Weapon";[18]="Wirelink";[2]="Bass";[3]="Color";[4]="Entity";[5]="File";[6]="Hologram";[7]="Mesh";[8]="Npc";[9]="Particle";["Angle"]={["class"]="class";["client"]=true;["description"]="\
Angle Type";["fields"]={};["methods"]={[1]="getForward";[10]="setR";[11]="setY";[12]="setZero";[2]="getNormalized";[3]="getRight";[4]="getUp";[5]="isZero";[6]="normalize";[7]="rotateAroundAxis";[8]="set";[9]="setP";["getForward"]={["class"]="function";["classlib"]="Angle";["description"]="\
Return the Forward Vector ( direction the angle points ).";["fname"]="getForward";["name"]="ang_methods:getForward";["param"]={};["private"]=false;["realm"]="sh";["ret"]="vector normalised.";["summary"]="\
Return the Forward Vector ( direction the angle points ).";};["getNormalized"]={["class"]="function";["classlib"]="Angle";["description"]="\
Returnes a normalized angle";["fname"]="getNormalized";["name"]="ang_methods:getNormalized";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Normalized angle table";["summary"]="\
Returnes a normalized angle ";};["getRight"]={["class"]="function";["classlib"]="Angle";["description"]="\
Return the Right Vector relative to the angle dir.";["fname"]="getRight";["name"]="ang_methods:getRight";["param"]={};["private"]=false;["realm"]="sh";["ret"]="vector normalised.";["summary"]="\
Return the Right Vector relative to the angle dir.";};["getUp"]={["class"]="function";["classlib"]="Angle";["description"]="\
Return the Up Vector relative to the angle dir.";["fname"]="getUp";["name"]="ang_methods:getUp";["param"]={};["private"]=false;["realm"]="sh";["ret"]="vector normalised.";["summary"]="\
Return the Up Vector relative to the angle dir.";};["isZero"]={["class"]="function";["classlib"]="Angle";["description"]="\
Returns if p,y,r are all 0.";["fname"]="isZero";["name"]="ang_methods:isZero";["param"]={};["private"]=false;["realm"]="sh";["ret"]="boolean";["summary"]="\
Returns if p,y,r are all 0.";};["normalize"]={["class"]="function";["classlib"]="Angle";["description"]="\
Normalise angles eg (0,181,1) -> (0,-179,1).";["fname"]="normalize";["name"]="ang_methods:normalize";["param"]={};["private"]=false;["realm"]="sh";["ret"]="nil";["summary"]="\
Normalise angles eg (0,181,1) -> (0,-179,1).";};["rotateAroundAxis"]={["class"]="function";["classlib"]="Angle";["description"]="\
Return Rotated angle around the specified axis.";["fname"]="rotateAroundAxis";["name"]="ang_methods:rotateAroundAxis";["param"]={[1]="v";[2]="deg";[3]="rad";["deg"]="Number of degrees or nil if radians.";["rad"]="Number of radians or nil if degrees.";["v"]="Vector axis";};["private"]=false;["realm"]="sh";["ret"]="The modified angle";["summary"]="\
Return Rotated angle around the specified axis.";};["set"]={["class"]="function";["classlib"]="Angle";["description"]="\
Copies p,y,r from angle to another.";["fname"]="set";["name"]="ang_methods:set";["param"]={[1]="b";["b"]="Angle to copy from.";};["private"]=false;["realm"]="sh";["ret"]="nil";["summary"]="\
Copies p,y,r from angle to another.";};["setP"]={["class"]="function";["classlib"]="Angle";["description"]="\
Set's the angle's pitch and returns it.";["fname"]="setP";["name"]="ang_methods:setP";["param"]={[1]="p";["p"]="The pitch";};["private"]=false;["realm"]="sh";["ret"]="The modified angle";["summary"]="\
Set's the angle's pitch and returns it.";};["setR"]={["class"]="function";["classlib"]="Angle";["description"]="\
Set's the angle's roll and returns it.";["fname"]="setR";["name"]="ang_methods:setR";["param"]={[1]="r";["r"]="The roll";};["private"]=false;["realm"]="sh";["ret"]="The modified angle";["summary"]="\
Set's the angle's roll and returns it.";};["setY"]={["class"]="function";["classlib"]="Angle";["description"]="\
Set's the angle's yaw and returns it.";["fname"]="setY";["name"]="ang_methods:setY";["param"]={[1]="y";["y"]="The yaw";};["private"]=false;["realm"]="sh";["ret"]="The modified angle";["summary"]="\
Set's the angle's yaw and returns it.";};["setZero"]={["class"]="function";["classlib"]="Angle";["description"]="\
Sets p,y,r to 0. This is faster than doing it manually.";["fname"]="setZero";["name"]="ang_methods:setZero";["param"]={};["private"]=false;["realm"]="sh";["ret"]="nil";["summary"]="\
Sets p,y,r to 0.";};};["name"]="Angle";["server"]=true;["summary"]="\
Angle Type ";["typtbl"]="ang_methods";};["Bass"]={["class"]="class";["client"]=true;["description"]="\
For playing music there is `Bass` type. You can pause and set current playback time in it. If you're looking to apply DSP effects on present game sounds, use `Sound` instead.";["fields"]={};["methods"]={[1]="getFFT";[10]="setPitch";[11]="setPos";[12]="setTime";[13]="setVolume";[14]="stop";[2]="getLength";[3]="getTime";[4]="isOnline";[5]="isValid";[6]="pause";[7]="play";[8]="setFade";[9]="setLooping";["getFFT"]={["class"]="function";["classlib"]="Bass";["description"]="\
Perform fast Fourier transform algorithm to compute the DFT of the sound channel.";["fname"]="getFFT";["name"]="bass_methods:getFFT";["param"]={[1]="n";["n"]="Number of consecutive audio samples, between 0 and 7. Depending on this parameter you will get 256*2^n samples.";};["private"]=false;["realm"]="cl";["ret"]="Table containing DFT magnitudes, each between 0 and 1.";["summary"]="\
Perform fast Fourier transform algorithm to compute the DFT of the sound channel.";};["getLength"]={["class"]="function";["classlib"]="Bass";["description"]="\
Gets the length of a sound channel.";["fname"]="getLength";["name"]="bass_methods:getLength";["param"]={};["private"]=false;["realm"]="cl";["ret"]="Sound channel length in seconds.";["summary"]="\
Gets the length of a sound channel.";};["getTime"]={["class"]="function";["classlib"]="Bass";["description"]="\
Gets the current playback time of the sound channel.";["fname"]="getTime";["name"]="bass_methods:getTime";["param"]={};["private"]=false;["realm"]="cl";["ret"]="Sound channel playback time in seconds.";["summary"]="\
Gets the current playback time of the sound channel.";};["isOnline"]={["class"]="function";["classlib"]="Bass";["description"]="\
Gets whether the sound channel is streamed online.";["fname"]="isOnline";["name"]="bass_methods:isOnline";["param"]={};["private"]=false;["realm"]="cl";["ret"]="Boolean of whether the sound channel is streamed online.";["summary"]="\
Gets whether the sound channel is streamed online.";};["isValid"]={["class"]="function";["classlib"]="Bass";["description"]="\
Gets whether the bass is valid.";["fname"]="isValid";["name"]="bass_methods:isValid";["param"]={};["private"]=false;["realm"]="cl";["ret"]="Boolean of whether the bass is valid.";["summary"]="\
Gets whether the bass is valid.";};["pause"]={["class"]="function";["classlib"]="Bass";["description"]="\
Pauses the sound.";["fname"]="pause";["name"]="bass_methods:pause";["param"]={};["private"]=false;["realm"]="cl";["summary"]="\
Pauses the sound.";};["play"]={["class"]="function";["classlib"]="Bass";["description"]="\
Starts to play the sound.";["fname"]="play";["name"]="bass_methods:play";["param"]={};["private"]=false;["realm"]="cl";["summary"]="\
Starts to play the sound.";};["setFade"]={["class"]="function";["classlib"]="Bass";["description"]="\
Sets the fade distance of the sound in 3D space. Must have `3d` flag to get this work on.";["fname"]="setFade";["name"]="bass_methods:setFade";["param"]={[1]="min";[2]="max";["max"]="The channel's volume stops decreasing when the listener is beyond this distance.";["min"]="The channel's volume is at maximum when the listener is within this distance";};["private"]=false;["realm"]="cl";["summary"]="\
Sets the fade distance of the sound in 3D space.";};["setLooping"]={["class"]="function";["classlib"]="Bass";["description"]="\
Sets whether the sound channel should loop.";["fname"]="setLooping";["name"]="bass_methods:setLooping";["param"]={[1]="loop";["loop"]="Boolean of whether the sound channel should loop.";};["private"]=false;["realm"]="cl";["summary"]="\
Sets whether the sound channel should loop.";};["setPitch"]={["class"]="function";["classlib"]="Bass";["description"]="\
Sets the pitch of the sound channel.";["fname"]="setPitch";["name"]="bass_methods:setPitch";["param"]={[1]="pitch";["pitch"]="Pitch to set to, between 0 and 3.";};["private"]=false;["realm"]="cl";["summary"]="\
Sets the pitch of the sound channel.";};["setPos"]={["class"]="function";["classlib"]="Bass";["description"]="\
Sets the position of the sound in 3D space. Must have `3d` flag to get this work on.";["fname"]="setPos";["name"]="bass_methods:setPos";["param"]={[1]="pos";["pos"]="Where to position the sound.";};["private"]=false;["realm"]="cl";["summary"]="\
Sets the position of the sound in 3D space.";};["setTime"]={["class"]="function";["classlib"]="Bass";["description"]="\
Sets the current playback time of the sound channel.";["fname"]="setTime";["name"]="bass_methods:setTime";["param"]={[1]="time";["time"]="Sound channel playback time in seconds.";};["private"]=false;["realm"]="cl";["summary"]="\
Sets the current playback time of the sound channel.";};["setVolume"]={["class"]="function";["classlib"]="Bass";["description"]="\
Sets the volume of the sound channel.";["fname"]="setVolume";["name"]="bass_methods:setVolume";["param"]={[1]="vol";["vol"]="Volume to set to, between 0 and 1.";};["private"]=false;["realm"]="cl";["summary"]="\
Sets the volume of the sound channel.";};["stop"]={["class"]="function";["classlib"]="Bass";["description"]="\
Stops playing the sound.";["fname"]="stop";["name"]="bass_methods:stop";["param"]={};["private"]=false;["realm"]="cl";["summary"]="\
Stops playing the sound.";};};["name"]="Bass";["summary"]="\
For playing music there is `Bass` type.";["typtbl"]="bass_methods";};["Color"]={["class"]="class";["client"]=true;["description"]="\
Color type";["fields"]={};["methods"]={[1]="hsvToRGB";[2]="rgbToHSV";[3]="setA";[4]="setB";[5]="setG";[6]="setR";["hsvToRGB"]={["class"]="function";["classlib"]="Color";["client"]=true;["description"]="\
Converts the color from HSV to RGB.";["fname"]="hsvToRGB";["name"]="color_methods:hsvToRGB";["param"]={};["private"]=false;["realm"]="sh";["ret"]="A triplet of numbers representing HSV.";["server"]=true;["summary"]="\
Converts the color from HSV to RGB.";};["rgbToHSV"]={["class"]="function";["classlib"]="Color";["client"]=true;["description"]="\
Converts the color from RGB to HSV.";["fname"]="rgbToHSV";["name"]="color_methods:rgbToHSV";["param"]={};["private"]=false;["realm"]="sh";["ret"]="A triplet of numbers representing HSV.";["server"]=true;["summary"]="\
Converts the color from RGB to HSV.";};["setA"]={["class"]="function";["classlib"]="Color";["description"]="\
Set's the color's alpha and returns it.";["fname"]="setA";["name"]="color_methods:setA";["param"]={[1]="a";["a"]="The alpha";};["private"]=false;["realm"]="sh";["ret"]="The modified color";["summary"]="\
Set's the color's alpha and returns it.";};["setB"]={["class"]="function";["classlib"]="Color";["description"]="\
Set's the color's blue and returns it.";["fname"]="setB";["name"]="color_methods:setB";["param"]={[1]="b";["b"]="The blue";};["private"]=false;["realm"]="sh";["ret"]="The modified color";["summary"]="\
Set's the color's blue and returns it.";};["setG"]={["class"]="function";["classlib"]="Color";["description"]="\
Set's the color's green and returns it.";["fname"]="setG";["name"]="color_methods:setG";["param"]={[1]="g";["g"]="The green";};["private"]=false;["realm"]="sh";["ret"]="The modified color";["summary"]="\
Set's the color's green and returns it.";};["setR"]={["class"]="function";["classlib"]="Color";["description"]="\
Set's the color's red channel and returns it.";["fname"]="setR";["name"]="color_methods:setR";["param"]={[1]="r";["r"]="The red";};["private"]=false;["realm"]="sh";["ret"]="The modified color";["summary"]="\
Set's the color's red channel and returns it.";};};["name"]="Color";["server"]=true;["summary"]="\
Color type ";["typtbl"]="color_methods";};["Entity"]={["class"]="class";["client"]=true;["description"]="\
Entity type";["fields"]={};["methods"]={[1]="addCollisionListener";[10]="enableGravity";[100]="translatePhysBoneToBone";[101]="unparent";[102]="worldToLocal";[103]="worldToLocalAngles";[11]="enableMotion";[12]="enableSphere";[13]="entIndex";[14]="extinguish";[15]="getAngleVelocity";[16]="getAngleVelocityAngle";[17]="getAngles";[18]="getAttachment";[19]="getAttachmentParent";[2]="applyAngForce";[20]="getBoneCount";[21]="getBoneMatrix";[22]="getBoneName";[23]="getBoneParent";[24]="getBonePosition";[25]="getClass";[26]="getColor";[27]="getEyeAngles";[28]="getEyePos";[29]="getForward";[3]="applyDamage";[30]="getHealth";[31]="getInertia";[32]="getMass";[33]="getMassCenter";[34]="getMassCenterW";[35]="getMaterial";[36]="getMaterials";[37]="getMaxHealth";[38]="getModel";[39]="getOwner";[4]="applyForceCenter";[40]="getParent";[41]="getPhysMaterial";[42]="getPhysicsObject";[43]="getPhysicsObjectCount";[44]="getPhysicsObjectNum";[45]="getPos";[46]="getRight";[47]="getSkin";[48]="getSubMaterial";[49]="getUp";[5]="applyForceOffset";[50]="getVelocity";[51]="getWaterLevel";[52]="ignite";[53]="isFrozen";[54]="isNPC";[55]="isOnGround";[56]="isPlayer";[57]="isValid";[58]="isValidPhys";[59]="isVehicle";[6]="applyTorque";[60]="isWeapon";[61]="isWeldedTo";[62]="linkComponent";[63]="localToWorld";[64]="localToWorldAngles";[65]="lookupAttachment";[66]="lookupBone";[67]="manipulateBoneAngles";[68]="manipulateBonePosition";[69]="manipulateBoneScale";[7]="breakEnt";[70]="obbCenter";[71]="obbCenterW";[72]="obbSize";[73]="remove";[74]="removeCollisionListener";[75]="removeTrails";[76]="setAngles";[77]="setBodygroup";[78]="setColor";[79]="setDrawShadow";[8]="emitSound";[80]="setFrozen";[81]="setHologramMesh";[82]="setHologramRenderBounds";[83]="setHologramRenderMatrix";[84]="setInertia";[85]="setMass";[86]="setMaterial";[87]="setNoDraw";[88]="setNocollideAll";[89]="setParent";[9]="enableDrag";[90]="setPhysMaterial";[91]="setPos";[92]="setRenderFX";[93]="setRenderMode";[94]="setSkin";[95]="setSolid";[96]="setSubMaterial";[97]="setTrails";[98]="setVelocity";[99]="translateBoneToPhysBone";["addCollisionListener"]={["class"]="function";["classlib"]="Entity";["description"]="\
Allows detecting collisions on an entity. You can only do this once for the entity's entire lifespan so use it wisely.";["fname"]="addCollisionListener";["name"]="ents_methods:addCollisionListener";["param"]={[1]="func";["func"]="The callback function with argument, table collsiondata, http://wiki.garrysmod.com/page/Structures/CollisionData";};["private"]=false;["realm"]="sv";["summary"]="\
Allows detecting collisions on an entity.";};["applyAngForce"]={["class"]="function";["classlib"]="Entity";["description"]="\
Applies angular force to the entity";["fname"]="applyAngForce";["name"]="ents_methods:applyAngForce";["param"]={[1]="ang";["ang"]="The force angle";};["private"]=false;["realm"]="sv";["summary"]="\
Applies angular force to the entity ";};["applyDamage"]={["class"]="function";["classlib"]="Entity";["description"]="\
Applies damage to an entity";["fname"]="applyDamage";["name"]="ents_methods:applyDamage";["param"]={[1]="amt";[2]="attacker";[3]="inflictor";["amt"]="damage amount";["attacker"]="damage attacker";["inflictor"]="damage inflictor";};["private"]=false;["realm"]="sv";["summary"]="\
Applies damage to an entity ";};["applyForceCenter"]={["class"]="function";["classlib"]="Entity";["description"]="\
Applies linear force to the entity";["fname"]="applyForceCenter";["name"]="ents_methods:applyForceCenter";["param"]={[1]="vec";["vec"]="The force vector";};["private"]=false;["realm"]="sv";["summary"]="\
Applies linear force to the entity ";};["applyForceOffset"]={["class"]="function";["classlib"]="Entity";["description"]="\
Applies linear force to the entity with an offset";["fname"]="applyForceOffset";["name"]="ents_methods:applyForceOffset";["param"]={[1]="vec";[2]="offset";["offset"]="An optional offset position";["vec"]="The force vector";};["private"]=false;["realm"]="sv";["summary"]="\
Applies linear force to the entity with an offset ";};["applyTorque"]={["class"]="function";["classlib"]="Entity";["description"]="\
Applies torque";["fname"]="applyTorque";["name"]="ents_methods:applyTorque";["param"]={[1]="torque";["torque"]="The torque vector";};["private"]=false;["realm"]="sv";["summary"]="\
Applies torque ";};["breakEnt"]={["class"]="function";["classlib"]="Entity";["description"]="\
Invokes the entity's breaking animation and removes it.";["fname"]="breakEnt";["name"]="ents_methods:breakEnt";["param"]={};["private"]=false;["realm"]="sv";["summary"]="\
Invokes the entity's breaking animation and removes it.";};["emitSound"]={["class"]="function";["classlib"]="Entity";["description"]="\
Plays a sound on the entity";["fname"]="emitSound";["name"]="ents_methods:emitSound";["param"]={[1]="snd";[2]="lvl";[3]="pitch";[4]="volume";[5]="channel";["channel"]="channel=CHAN_AUTO";["lvl"]="number soundLevel=75";["pitch"]="pitchPercent=100";["snd"]="string Sound path";["volume"]="volume=1";};["private"]=false;["realm"]="sv";["summary"]="\
Plays a sound on the entity ";};["enableDrag"]={["class"]="function";["classlib"]="Entity";["description"]="\
Sets the entity drag state";["fname"]="enableDrag";["name"]="ents_methods:enableDrag";["param"]={[1]="drag";["drag"]="Bool should the entity have air resistence?";};["private"]=false;["realm"]="sv";["summary"]="\
Sets the entity drag state ";};["enableGravity"]={["class"]="function";["classlib"]="Entity";["description"]="\
Sets entity gravity";["fname"]="enableGravity";["name"]="ents_methods:enableGravity";["param"]={[1]="grav";["grav"]="Bool should the entity respect gravity?";};["private"]=false;["realm"]="sv";["summary"]="\
Sets entity gravity ";};["enableMotion"]={["class"]="function";["classlib"]="Entity";["description"]="\
Sets the entity movement state";["fname"]="enableMotion";["name"]="ents_methods:enableMotion";["param"]={[1]="move";["move"]="Bool should the entity move?";};["private"]=false;["realm"]="sv";["summary"]="\
Sets the entity movement state ";};["enableSphere"]={["class"]="function";["classlib"]="Entity";["description"]="\
Sets the physics of an entity to be a sphere";["fname"]="enableSphere";["name"]="ents_methods:enableSphere";["param"]={[1]="enabled";["enabled"]="Bool should the entity be spherical?";};["private"]=false;["realm"]="sv";["summary"]="\
Sets the physics of an entity to be a sphere ";};["entIndex"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Returns the EntIndex of the entity";["fname"]="entIndex";["name"]="ents_methods:entIndex";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The numerical index of the entity";["server"]=true;["summary"]="\
Returns the EntIndex of the entity ";};["extinguish"]={["class"]="function";["classlib"]="Entity";["description"]="\
Extinguishes an entity";["fname"]="extinguish";["name"]="ents_methods:extinguish";["param"]={};["private"]=false;["realm"]="sv";["summary"]="\
Extinguishes an entity ";};["getAngleVelocity"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Returns the angular velocity of the entity";["fname"]="getAngleVelocity";["name"]="ents_methods:getAngleVelocity";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The angular velocity as a vector";["server"]=true;["summary"]="\
Returns the angular velocity of the entity ";};["getAngleVelocityAngle"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Returns the angular velocity of the entity";["fname"]="getAngleVelocityAngle";["name"]="ents_methods:getAngleVelocityAngle";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The angular velocity as an angle";["server"]=true;["summary"]="\
Returns the angular velocity of the entity ";};["getAngles"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Returns the angle of the entity";["fname"]="getAngles";["name"]="ents_methods:getAngles";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The angle";["server"]=true;["summary"]="\
Returns the angle of the entity ";};["getAttachment"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Gets the position and angle of an attachment";["fname"]="getAttachment";["name"]="ents_methods:getAttachment";["param"]={[1]="index";["index"]="The index of the attachment";};["private"]=false;["realm"]="sh";["ret"]="vector position, and angle orientation";["server"]=true;["summary"]="\
Gets the position and angle of an attachment ";};["getAttachmentParent"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Gets the attachment index the entity is parented to";["fname"]="getAttachmentParent";["name"]="ents_methods:getAttachmentParent";["param"]={};["private"]=false;["realm"]="sh";["ret"]="number index of the attachment the entity is parented to or 0";["server"]=true;["summary"]="\
Gets the attachment index the entity is parented to ";};["getBoneCount"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Returns the number of an entity's bones";["fname"]="getBoneCount";["name"]="ents_methods:getBoneCount";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Number of bones";["server"]=true;["summary"]="\
Returns the number of an entity's bones ";};["getBoneMatrix"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Returns the matrix of the entity's bone";["fname"]="getBoneMatrix";["name"]="ents_methods:getBoneMatrix";["param"]={[1]="bone";["bone"]="Bone index. (def 0)";};["private"]=false;["realm"]="sh";["ret"]="The matrix";["server"]=true;["summary"]="\
Returns the matrix of the entity's bone ";};["getBoneName"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Returns the name of an entity's bone";["fname"]="getBoneName";["name"]="ents_methods:getBoneName";["param"]={[1]="bone";["bone"]="Bone index. (def 0)";};["private"]=false;["realm"]="sh";["ret"]="Name of the bone";["server"]=true;["summary"]="\
Returns the name of an entity's bone ";};["getBoneParent"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Returns the parent index of an entity's bone";["fname"]="getBoneParent";["name"]="ents_methods:getBoneParent";["param"]={[1]="bone";["bone"]="Bone index. (def 0)";};["private"]=false;["realm"]="sh";["ret"]="Parent index of the bone";["server"]=true;["summary"]="\
Returns the parent index of an entity's bone ";};["getBonePosition"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Returns the bone's position and angle in world coordinates";["fname"]="getBonePosition";["name"]="ents_methods:getBonePosition";["param"]={[1]="bone";["bone"]="Bone index. (def 0)";};["private"]=false;["realm"]="sh";["ret"]={[1]="Position of the bone";[2]="Angle of the bone";};["server"]=true;["summary"]="\
Returns the bone's position and angle in world coordinates ";};["getClass"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Returns the class of the entity";["fname"]="getClass";["name"]="ents_methods:getClass";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The string class name";["server"]=true;["summary"]="\
Returns the class of the entity ";};["getColor"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Gets the color of an entity";["fname"]="getColor";["name"]="ents_methods:getColor";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Color";["server"]=true;["summary"]="\
Gets the color of an entity ";};["getEyeAngles"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Gets the entitiy's eye angles";["fname"]="getEyeAngles";["name"]="ents_methods:getEyeAngles";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Angles of the entity's eyes";["server"]=true;["summary"]="\
Gets the entitiy's eye angles ";};["getEyePos"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Gets the entity's eye position";["fname"]="getEyePos";["name"]="ents_methods:getEyePos";["param"]={};["private"]=false;["realm"]="sh";["ret"]={[1]="Eye position of the entity";[2]="In case of a ragdoll, the position of the second eye";};["server"]=true;["summary"]="\
Gets the entity's eye position ";};["getForward"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Gets the entity's forward vector";["fname"]="getForward";["name"]="ents_methods:getForward";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Vector forward";["server"]=true;["summary"]="\
Gets the entity's forward vector ";};["getHealth"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Gets the health of an entity";["fname"]="getHealth";["name"]="ents_methods:getHealth";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Health of the entity";["server"]=true;["summary"]="\
Gets the health of an entity ";};["getInertia"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Returns the principle moments of inertia of the entity";["fname"]="getInertia";["name"]="ents_methods:getInertia";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The principle moments of inertia as a vector";["server"]=true;["summary"]="\
Returns the principle moments of inertia of the entity ";};["getMass"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Returns the mass of the entity";["fname"]="getMass";["name"]="ents_methods:getMass";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The numerical mass";["server"]=true;["summary"]="\
Returns the mass of the entity ";};["getMassCenter"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Returns the local position of the entity's mass center";["fname"]="getMassCenter";["name"]="ents_methods:getMassCenter";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The position vector of the mass center";["server"]=true;["summary"]="\
Returns the local position of the entity's mass center ";};["getMassCenterW"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Returns the world position of the entity's mass center";["fname"]="getMassCenterW";["name"]="ents_methods:getMassCenterW";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The position vector of the mass center";["server"]=true;["summary"]="\
Returns the world position of the entity's mass center ";};["getMaterial"]={["class"]="function";["classForced"]=true;["classlib"]="Entity";["client"]=true;["description"]="\
Gets an entities' material";["fname"]="getMaterial";["name"]="ents_methods:getMaterial";["param"]={};["private"]=false;["realm"]="sh";["ret"]="String material";["server"]=true;["summary"]="\
Gets an entities' material ";};["getMaterials"]={["class"]="function";["classForced"]=true;["classlib"]="Entity";["client"]=true;["description"]="\
Gets an entities' material list";["fname"]="getMaterials";["name"]="ents_methods:getMaterials";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Material";["server"]=true;["summary"]="\
Gets an entities' material list ";};["getMaxHealth"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Gets the max health of an entity";["fname"]="getMaxHealth";["name"]="ents_methods:getMaxHealth";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Max Health of the entity";["server"]=true;["summary"]="\
Gets the max health of an entity ";};["getModel"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Gets the model of an entity";["fname"]="getModel";["name"]="ents_methods:getModel";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Model of the entity";["server"]=true;["summary"]="\
Gets the model of an entity ";};["getOwner"]={["class"]="function";["classlib"]="Entity";["description"]="\
Gets the owner of the entity";["fname"]="getOwner";["name"]="ents_methods:getOwner";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Owner";["summary"]="\
Gets the owner of the entity ";};["getParent"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Gets the parent of an entity";["fname"]="getParent";["name"]="ents_methods:getParent";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Entity's parent or nil";["server"]=true;["summary"]="\
Gets the parent of an entity ";};["getPhysMaterial"]={["class"]="function";["classlib"]="Entity";["description"]="\
Get the physical material of the entity";["fname"]="getPhysMaterial";["name"]="ents_methods:getPhysMaterial";["param"]={};["private"]=false;["realm"]="sv";["ret"]="the physical material";["summary"]="\
Get the physical material of the entity ";};["getPhysicsObject"]={["class"]="function";["classlib"]="Entity";["description"]="\
Gets the main physics objects of an entity";["fname"]="getPhysicsObject";["name"]="ents_methods:getPhysicsObject";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The main physics object of the entity";["summary"]="\
Gets the main physics objects of an entity ";};["getPhysicsObjectCount"]={["class"]="function";["classlib"]="Entity";["description"]="\
Gets the number of physicsobjects of an entity";["fname"]="getPhysicsObjectCount";["name"]="ents_methods:getPhysicsObjectCount";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The number of physics objects on the entity";["summary"]="\
Gets the number of physicsobjects of an entity ";};["getPhysicsObjectNum"]={["class"]="function";["classlib"]="Entity";["description"]="\
Gets a physics objects of an entity";["fname"]="getPhysicsObjectNum";["name"]="ents_methods:getPhysicsObjectNum";["param"]={[1]="id";["id"]="The physics object id (starts at 0)";};["private"]=false;["realm"]="sh";["ret"]="The physics object of the entity";["summary"]="\
Gets a physics objects of an entity ";};["getPos"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Returns the position of the entity";["fname"]="getPos";["name"]="ents_methods:getPos";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The position vector";["server"]=true;["summary"]="\
Returns the position of the entity ";};["getRight"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Gets the entity's right vector";["fname"]="getRight";["name"]="ents_methods:getRight";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Vector right";["server"]=true;["summary"]="\
Gets the entity's right vector ";};["getSkin"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Gets the skin number of the entity";["fname"]="getSkin";["name"]="ents_methods:getSkin";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Skin number";["server"]=true;["summary"]="\
Gets the skin number of the entity ";};["getSubMaterial"]={["class"]="function";["classForced"]=true;["classlib"]="Entity";["client"]=true;["description"]="\
Gets an entities' submaterial";["fname"]="getSubMaterial";["name"]="ents_methods:getSubMaterial";["param"]={[1]="index";};["private"]=false;["realm"]="sh";["ret"]="String material";["server"]=true;["summary"]="\
Gets an entities' submaterial ";};["getUp"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Gets the entity's up vector";["fname"]="getUp";["name"]="ents_methods:getUp";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Vector up";["server"]=true;["summary"]="\
Gets the entity's up vector ";};["getVelocity"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Returns the velocity of the entity";["fname"]="getVelocity";["name"]="ents_methods:getVelocity";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The velocity vector";["server"]=true;["summary"]="\
Returns the velocity of the entity ";};["getWaterLevel"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Returns how submerged the entity is in water";["fname"]="getWaterLevel";["name"]="ents_methods:getWaterLevel";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The water level. 0 none, 1 slightly, 2 at least halfway, 3 all the way";["server"]=true;["summary"]="\
Returns how submerged the entity is in water ";};["ignite"]={["class"]="function";["classlib"]="Entity";["description"]="\
Ignites an entity";["fname"]="ignite";["name"]="ents_methods:ignite";["param"]={[1]="length";[2]="radius";["length"]="How long the fire lasts";["radius"]="(optional) How large the fire hitbox is (entity obb is the max)";};["private"]=false;["realm"]="sv";["summary"]="\
Ignites an entity ";};["isFrozen"]={["class"]="function";["classlib"]="Entity";["description"]="\
Checks the entities frozen state";["fname"]="isFrozen";["name"]="ents_methods:isFrozen";["param"]={};["private"]=false;["realm"]="sv";["ret"]="True if entity is frozen";["summary"]="\
Checks the entities frozen state ";};["isNPC"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Checks if an entity is an npc.";["fname"]="isNPC";["name"]="ents_methods:isNPC";["param"]={};["private"]=false;["realm"]="sh";["ret"]="True if npc, false if not";["server"]=true;["summary"]="\
Checks if an entity is an npc.";};["isOnGround"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Checks if the entity ONGROUND flag is set";["fname"]="isOnGround";["name"]="ents_methods:isOnGround";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Boolean if it's flag is set or not";["server"]=true;["summary"]="\
Checks if the entity ONGROUND flag is set ";};["isPlayer"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Checks if an entity is a player.";["fname"]="isPlayer";["name"]="ents_methods:isPlayer";["param"]={};["private"]=false;["realm"]="sh";["ret"]="True if player, false if not";["server"]=true;["summary"]="\
Checks if an entity is a player.";};["isValid"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Checks if an entity is valid.";["fname"]="isValid";["name"]="ents_methods:isValid";["param"]={};["private"]=false;["realm"]="sh";["ret"]="True if valid, false if not";["server"]=true;["summary"]="\
Checks if an entity is valid.";};["isValidPhys"]={["class"]="function";["classlib"]="Entity";["description"]="\
Checks whether entity has physics";["fname"]="isValidPhys";["name"]="ents_methods:isValidPhys";["param"]={};["private"]=false;["realm"]="sv";["ret"]="True if entity has physics";["summary"]="\
Checks whether entity has physics ";};["isVehicle"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Checks if an entity is a vehicle.";["fname"]="isVehicle";["name"]="ents_methods:isVehicle";["param"]={};["private"]=false;["realm"]="sh";["ret"]="True if vehicle, false if not";["server"]=true;["summary"]="\
Checks if an entity is a vehicle.";};["isWeapon"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Checks if an entity is a weapon.";["fname"]="isWeapon";["name"]="ents_methods:isWeapon";["param"]={};["private"]=false;["realm"]="sh";["ret"]="True if weapon, false if not";["server"]=true;["summary"]="\
Checks if an entity is a weapon.";};["isWeldedTo"]={["class"]="function";["classlib"]="Entity";["description"]="\
Gets what the entity is welded to";["fname"]="isWeldedTo";["name"]="ents_methods:isWeldedTo";["param"]={};["private"]=false;["realm"]="sv";["summary"]="\
Gets what the entity is welded to ";};["linkComponent"]={["class"]="function";["classlib"]="Entity";["description"]="\
Links starfall components to a starfall processor or vehicle. Screen can only connect to processor. HUD can connect to processor and vehicle.";["fname"]="linkComponent";["name"]="ents_methods:linkComponent";["param"]={[1]="e";["e"]="Entity to link the component to. nil to clear links.";};["private"]=false;["realm"]="sv";["summary"]="\
Links starfall components to a starfall processor or vehicle.";};["localToWorld"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Converts a vector in entity local space to world space";["fname"]="localToWorld";["name"]="ents_methods:localToWorld";["param"]={[1]="data";["data"]="Local space vector";};["private"]=false;["realm"]="sh";["ret"]="data as world space vector";["server"]=true;["summary"]="\
Converts a vector in entity local space to world space ";};["localToWorldAngles"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Converts an angle in entity local space to world space";["fname"]="localToWorldAngles";["name"]="ents_methods:localToWorldAngles";["param"]={[1]="data";["data"]="Local space angle";};["private"]=false;["realm"]="sh";["ret"]="data as world space angle";["server"]=true;["summary"]="\
Converts an angle in entity local space to world space ";};["lookupAttachment"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Gets the attachment index via the entity and it's attachment name";["fname"]="lookupAttachment";["name"]="ents_methods:lookupAttachment";["param"]={[1]="name";["name"]="";};["private"]=false;["realm"]="sh";["ret"]="number of the attachment index, or 0 if it doesn't exist";["server"]=true;["summary"]="\
Gets the attachment index via the entity and it's attachment name ";};["lookupBone"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Returns the ragdoll bone index given a bone name";["fname"]="lookupBone";["name"]="ents_methods:lookupBone";["param"]={[1]="name";["name"]="The bone's string name";};["private"]=false;["realm"]="sh";["ret"]="The bone index";["server"]=true;["summary"]="\
Returns the ragdoll bone index given a bone name ";};["manipulateBoneAngles"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Allows manipulation of a hologram's bones' angles";["fname"]="manipulateBoneAngles";["name"]="ents_methods:manipulateBoneAngles";["param"]={[1]="bone";[2]="ang";["ang"]="The angle it should be manipulated to";["bone"]="The bone ID";};["private"]=false;["realm"]="cl";["summary"]="\
Allows manipulation of a hologram's bones' angles ";};["manipulateBonePosition"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Allows manipulation of a hologram's bones' positions";["fname"]="manipulateBonePosition";["name"]="ents_methods:manipulateBonePosition";["param"]={[1]="bone";[2]="vec";["bone"]="The bone ID";["vec"]="The position it should be manipulated to";};["private"]=false;["realm"]="cl";["summary"]="\
Allows manipulation of a hologram's bones' positions ";};["manipulateBoneScale"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Allows manipulation of a hologram's bones' scale";["fname"]="manipulateBoneScale";["name"]="ents_methods:manipulateBoneScale";["param"]={[1]="bone";[2]="vec";["bone"]="The bone ID";["vec"]="The scale it should be manipulated to";};["private"]=false;["realm"]="cl";["summary"]="\
Allows manipulation of a hologram's bones' scale ";};["obbCenter"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Returns the local position of the entity's outer bounding box";["fname"]="obbCenter";["name"]="ents_methods:obbCenter";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The position vector of the outer bounding box center";["server"]=true;["summary"]="\
Returns the local position of the entity's outer bounding box ";};["obbCenterW"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Returns the world position of the entity's outer bounding box";["fname"]="obbCenterW";["name"]="ents_methods:obbCenterW";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The position vector of the outer bounding box center";["server"]=true;["summary"]="\
Returns the world position of the entity's outer bounding box ";};["obbSize"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Returns the x, y, z size of the entity's outer bounding box (local to the entity)";["fname"]="obbSize";["name"]="ents_methods:obbSize";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The outer bounding box size";["server"]=true;["summary"]="\
Returns the x, y, z size of the entity's outer bounding box (local to the entity) ";};["remove"]={["class"]="function";["classlib"]="Entity";["description"]="\
Removes an entity";["fname"]="remove";["name"]="ents_methods:remove";["param"]={};["private"]=false;["realm"]="sv";["summary"]="\
Removes an entity ";};["removeCollisionListener"]={["class"]="function";["classlib"]="Entity";["description"]="\
Removes a collision listening hook from the entity so that a new one can be added";["fname"]="removeCollisionListener";["name"]="ents_methods:removeCollisionListener";["param"]={};["private"]=false;["realm"]="sv";["summary"]="\
Removes a collision listening hook from the entity so that a new one can be added ";};["removeTrails"]={["class"]="function";["classlib"]="Entity";["description"]="\
Removes trails from the entity";["fname"]="removeTrails";["name"]="ents_methods:removeTrails";["param"]={};["private"]=false;["realm"]="sv";["summary"]="\
Removes trails from the entity ";};["setAngles"]={["class"]="function";["classlib"]="Entity";["description"]="\
Sets the entity's angles";["fname"]="setAngles";["name"]="ents_methods:setAngles";["param"]={[1]="ang";["ang"]="New angles";};["private"]=false;["realm"]="sv";["summary"]="\
Sets the entity's angles ";};["setBodygroup"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Sets the bodygroup of the entity";["fname"]="setBodygroup";["name"]="ents_methods:setBodygroup";["param"]={[1]="bodygroup";[2]="value";["bodygroup"]="Number, The ID of the bodygroup you're setting.";["value"]="Number, The value you're setting the bodygroup to.";};["private"]=false;["realm"]="sh";["server"]=true;["summary"]="\
Sets the bodygroup of the entity ";};["setColor"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Sets the color of the entity";["fname"]="setColor";["name"]="ents_methods:setColor";["param"]={[1]="clr";["clr"]="New color";};["private"]=false;["realm"]="sh";["server"]=true;["summary"]="\
Sets the color of the entity ";};["setDrawShadow"]={["class"]="function";["classlib"]="Entity";["description"]="\
Sets whether an entity's shadow should be drawn";["fname"]="setDrawShadow";["name"]="ents_methods:setDrawShadow";["param"]={[1]="draw";[2]="ply";["ply"]="Optional player argument to set only for that player. Can also be table of players.";};["private"]=false;["realm"]="sv";["summary"]="\
Sets whether an entity's shadow should be drawn ";};["setFrozen"]={["class"]="function";["classlib"]="Entity";["description"]="\
Sets the entity frozen state";["fname"]="setFrozen";["name"]="ents_methods:setFrozen";["param"]={[1]="freeze";["freeze"]="Should the entity be frozen?";};["private"]=false;["realm"]="sv";["summary"]="\
Sets the entity frozen state ";};["setHologramMesh"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Sets a hologram entity's model to a custom Mesh";["fname"]="setHologramMesh";["name"]="ents_methods:setHologramMesh";["param"]={[1]="mesh";["mesh"]="The mesh to set it to or nil to set back to normal";};["private"]=false;["realm"]="cl";["summary"]="\
Sets a hologram entity's model to a custom Mesh ";};["setHologramRenderBounds"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Sets a hologram entity's renderbounds";["fname"]="setHologramRenderBounds";["name"]="ents_methods:setHologramRenderBounds";["param"]={[1]="mins";[2]="maxs";["maxs"]="The upper bounding corner coordinate local to the hologram";["mins"]="The lower bounding corner coordinate local to the hologram";};["private"]=false;["realm"]="cl";["summary"]="\
Sets a hologram entity's renderbounds ";};["setHologramRenderMatrix"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Sets a hologram entity's rendermatrix";["fname"]="setHologramRenderMatrix";["name"]="ents_methods:setHologramRenderMatrix";["param"]={[1]="mat";["mat"]="VMatrix to use";};["private"]=false;["realm"]="cl";["summary"]="\
Sets a hologram entity's rendermatrix ";};["setInertia"]={["class"]="function";["classlib"]="Entity";["description"]="\
Sets the entity's inertia";["fname"]="setInertia";["name"]="ents_methods:setInertia";["param"]={[1]="vec";["vec"]="Inertia tensor";};["private"]=false;["realm"]="sv";["summary"]="\
Sets the entity's inertia ";};["setMass"]={["class"]="function";["classlib"]="Entity";["description"]="\
Sets the entity's mass";["fname"]="setMass";["name"]="ents_methods:setMass";["param"]={[1]="mass";["mass"]="number mass";};["private"]=false;["realm"]="sv";["summary"]="\
Sets the entity's mass ";};["setMaterial"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Sets the material of the entity";["fname"]="setMaterial";["name"]="ents_methods:setMaterial";["param"]={[1]="material";["material"]=", string, New material name.";};["private"]=false;["realm"]="sh";["server"]=true;["summary"]="\
Sets the material of the entity ";};["setNoDraw"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Sets the whether an entity should be drawn or not";["fname"]="setNoDraw";["name"]="ents_methods:setNoDraw";["param"]={[1]="draw";["draw"]="Whether to draw the entity or not.";};["private"]=false;["realm"]="sh";["server"]=true;["summary"]="\
Sets the whether an entity should be drawn or not ";};["setNocollideAll"]={["class"]="function";["classlib"]="Entity";["description"]="\
Set's the entity to collide with nothing but the world";["fname"]="setNocollideAll";["name"]="ents_methods:setNocollideAll";["param"]={[1]="nocollide";["nocollide"]="Whether to collide with nothing except world or not.";};["private"]=false;["realm"]="sv";["summary"]="\
Set's the entity to collide with nothing but the world ";};["setParent"]={["class"]="function";["classlib"]="Entity";["description"]="\
Parents the entity to another entity";["fname"]="setParent";["name"]="ents_methods:setParent";["param"]={[1]="ent";[2]="attachment";["attachment"]="Optional string attachment name to parent to";["ent"]="Entity to parent to";};["private"]=false;["realm"]="sv";["summary"]="\
Parents the entity to another entity ";};["setPhysMaterial"]={["class"]="function";["classlib"]="Entity";["description"]="\
Sets the physical material of the entity";["fname"]="setPhysMaterial";["name"]="ents_methods:setPhysMaterial";["param"]={[1]="mat";["mat"]="Material to use";};["private"]=false;["realm"]="sv";["summary"]="\
Sets the physical material of the entity ";};["setPos"]={["class"]="function";["classlib"]="Entity";["description"]="\
Sets the entitiy's position";["fname"]="setPos";["name"]="ents_methods:setPos";["param"]={[1]="vec";["vec"]="New position";};["private"]=false;["realm"]="sv";["summary"]="\
Sets the entitiy's position ";};["setRenderFX"]={["class"]="function";["classForced"]=true;["classlib"]="Entity";["client"]=true;["description"]="\
Sets the renderfx of the entity";["fname"]="setRenderFX";["name"]="ents_methods:setRenderFX";["param"]={[1]="renderfx";["renderfx"]="Number, renderfx to use. http://wiki.garrysmod.com/page/Enums/kRenderFx";};["private"]=false;["realm"]="sh";["server"]=true;["summary"]="\
Sets the renderfx of the entity ";};["setRenderMode"]={["class"]="function";["classForced"]=true;["classlib"]="Entity";["client"]=true;["description"]="\
Sets the render mode of the entity";["fname"]="setRenderMode";["name"]="ents_methods:setRenderMode";["param"]={[1]="rendermode";["rendermode"]="Number, rendermode to use. http://wiki.garrysmod.com/page/Enums/RENDERMODE";};["private"]=false;["realm"]="sh";["server"]=true;["summary"]="\
Sets the render mode of the entity ";};["setSkin"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Sets the skin of the entity";["fname"]="setSkin";["name"]="ents_methods:setSkin";["param"]={[1]="skinIndex";["skinIndex"]="Number, Index of the skin to use.";};["private"]=false;["realm"]="sh";["server"]=true;["summary"]="\
Sets the skin of the entity ";};["setSolid"]={["class"]="function";["classlib"]="Entity";["description"]="\
Sets the entity to be Solid or not. \
For more information please refer to GLua function http://wiki.garrysmod.com/page/Entity/SetNotSolid";["fname"]="setSolid";["name"]="ents_methods:setSolid";["param"]={[1]="solid";["solid"]="Boolean, Should the entity be solid?";};["private"]=false;["realm"]="sv";["summary"]="\
Sets the entity to be Solid or not.";};["setSubMaterial"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Sets the submaterial of the entity";["fname"]="setSubMaterial";["name"]="ents_methods:setSubMaterial";["param"]={[1]="index";[2]="material";["index"]=", number, submaterial index.";["material"]=", string, New material name.";};["private"]=false;["realm"]="sh";["server"]=true;["summary"]="\
Sets the submaterial of the entity ";};["setTrails"]={["class"]="function";["classlib"]="Entity";["description"]="\
Adds a trail to the entity with the specified attributes.";["fname"]="setTrails";["name"]="ents_methods:setTrails";["param"]={[1]="startSize";[2]="endSize";[3]="length";[4]="material";[5]="color";[6]="attachmentID";[7]="additive";["additive"]="If the trail's rendering is additive";["attachmentID"]="Optional attachmentid the trail should attach to";["color"]="The color of the trail";["endSize"]="The end size of the trail";["length"]="The length size of the trail";["material"]="The material of the trail";["startSize"]="The start size of the trail";};["private"]=false;["realm"]="sv";["summary"]="\
Adds a trail to the entity with the specified attributes.";};["setVelocity"]={["class"]="function";["classlib"]="Entity";["description"]="\
Sets the entity's linear velocity";["fname"]="setVelocity";["name"]="ents_methods:setVelocity";["param"]={[1]="vel";["vel"]="New velocity";};["private"]=false;["realm"]="sv";["summary"]="\
Sets the entity's linear velocity ";};["translateBoneToPhysBone"]={["class"]="function";["classlib"]="Entity";["description"]="\
Converts a ragdoll bone id to the corresponding physobject id";["fname"]="translateBoneToPhysBone";["name"]="ents_methods:translateBoneToPhysBone";["param"]={[1]="boneid";["boneid"]="The ragdoll boneid";};["private"]=false;["realm"]="sh";["ret"]="The physobj id";["summary"]="\
Converts a ragdoll bone id to the corresponding physobject id ";};["translatePhysBoneToBone"]={["class"]="function";["classlib"]="Entity";["description"]="\
Converts a physobject id to the corresponding ragdoll bone id";["fname"]="translatePhysBoneToBone";["name"]="ents_methods:translatePhysBoneToBone";["param"]={[1]="boneid";["boneid"]="The physobject id";};["private"]=false;["realm"]="sh";["ret"]="The ragdoll bone id";["summary"]="\
Converts a physobject id to the corresponding ragdoll bone id ";};["unparent"]={["class"]="function";["classlib"]="Entity";["description"]="\
Unparents the entity from another entity";["fname"]="unparent";["name"]="ents_methods:unparent";["param"]={};["private"]=false;["realm"]="sv";["summary"]="\
Unparents the entity from another entity ";};["worldToLocal"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Converts a vector in world space to entity local space";["fname"]="worldToLocal";["name"]="ents_methods:worldToLocal";["param"]={[1]="data";["data"]="World space vector";};["private"]=false;["realm"]="sh";["ret"]="data as local space vector";["server"]=true;["summary"]="\
Converts a vector in world space to entity local space ";};["worldToLocalAngles"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Converts an angle in world space to entity local space";["fname"]="worldToLocalAngles";["name"]="ents_methods:worldToLocalAngles";["param"]={[1]="data";["data"]="World space angle";};["private"]=false;["realm"]="sh";["ret"]="data as local space angle";["server"]=true;["summary"]="\
Converts an angle in world space to entity local space ";};};["name"]="Entity";["server"]=true;["summary"]="\
Entity type ";["typtbl"]="ents_methods";};["File"]={["class"]="class";["client"]=true;["description"]="\
File type";["fields"]={};["methods"]={[1]="close";[10]="readShort";[11]="seek";[12]="size";[13]="skip";[14]="tell";[15]="write";[16]="writeBool";[17]="writeByte";[18]="writeDouble";[19]="writeFloat";[2]="flush";[20]="writeLong";[21]="writeShort";[3]="read";[4]="readBool";[5]="readByte";[6]="readDouble";[7]="readFloat";[8]="readLine";[9]="readLong";["close"]={["class"]="function";["classlib"]="File";["description"]="\
Flushes and closes the file. The file must be opened again to use a new file object.";["fname"]="close";["name"]="file_methods:close";["param"]={};["private"]=false;["realm"]="cl";["summary"]="\
Flushes and closes the file.";};["flush"]={["class"]="function";["classlib"]="File";["description"]="\
Wait until all changes to the file are complete";["fname"]="flush";["name"]="file_methods:flush";["param"]={};["private"]=false;["realm"]="cl";["summary"]="\
Wait until all changes to the file are complete ";};["read"]={["class"]="function";["classlib"]="File";["description"]="\
Reads a certain length of the file's bytes";["fname"]="read";["name"]="file_methods:read";["param"]={[1]="n";["n"]="The length to read";};["private"]=false;["realm"]="cl";["ret"]="The data";["summary"]="\
Reads a certain length of the file's bytes ";};["readBool"]={["class"]="function";["classlib"]="File";["description"]="\
Reads a boolean and advances the file position";["fname"]="readBool";["name"]="file_methods:readBool";["param"]={};["private"]=false;["realm"]="cl";["ret"]="The data";["summary"]="\
Reads a boolean and advances the file position ";};["readByte"]={["class"]="function";["classlib"]="File";["description"]="\
Reads a byte and advances the file position";["fname"]="readByte";["name"]="file_methods:readByte";["param"]={};["private"]=false;["realm"]="cl";["ret"]="The data";["summary"]="\
Reads a byte and advances the file position ";};["readDouble"]={["class"]="function";["classlib"]="File";["description"]="\
Reads a double and advances the file position";["fname"]="readDouble";["name"]="file_methods:readDouble";["param"]={};["private"]=false;["realm"]="cl";["ret"]="The data";["summary"]="\
Reads a double and advances the file position ";};["readFloat"]={["class"]="function";["classlib"]="File";["description"]="\
Reads a float and advances the file position";["fname"]="readFloat";["name"]="file_methods:readFloat";["param"]={};["private"]=false;["realm"]="cl";["ret"]="The data";["summary"]="\
Reads a float and advances the file position ";};["readLine"]={["class"]="function";["classlib"]="File";["description"]="\
Reads a line and advances the file position";["fname"]="readLine";["name"]="file_methods:readLine";["param"]={};["private"]=false;["realm"]="cl";["ret"]="The data";["summary"]="\
Reads a line and advances the file position ";};["readLong"]={["class"]="function";["classlib"]="File";["description"]="\
Reads a long and advances the file position";["fname"]="readLong";["name"]="file_methods:readLong";["param"]={};["private"]=false;["realm"]="cl";["ret"]="The data";["summary"]="\
Reads a long and advances the file position ";};["readShort"]={["class"]="function";["classlib"]="File";["description"]="\
Reads a short and advances the file position";["fname"]="readShort";["name"]="file_methods:readShort";["param"]={};["private"]=false;["realm"]="cl";["ret"]="The data";["summary"]="\
Reads a short and advances the file position ";};["seek"]={["class"]="function";["classlib"]="File";["description"]="\
Sets the file position";["fname"]="seek";["name"]="file_methods:seek";["param"]={[1]="n";["n"]="The position to set it to";};["private"]=false;["realm"]="cl";["summary"]="\
Sets the file position ";};["size"]={["class"]="function";["classlib"]="File";["description"]="\
Returns the file's size in bytes";["fname"]="size";["name"]="file_methods:size";["param"]={};["private"]=false;["realm"]="cl";["ret"]="The file's size";["summary"]="\
Returns the file's size in bytes ";};["skip"]={["class"]="function";["classlib"]="File";["description"]="\
Moves the file position relative to its current position";["fname"]="skip";["name"]="file_methods:skip";["param"]={[1]="n";["n"]="How much to move the position";};["private"]=false;["realm"]="cl";["ret"]="The resulting position";["summary"]="\
Moves the file position relative to its current position ";};["tell"]={["class"]="function";["classlib"]="File";["description"]="\
Returns the current file position";["fname"]="tell";["name"]="file_methods:tell";["param"]={};["private"]=false;["realm"]="cl";["ret"]="The current file position";["summary"]="\
Returns the current file position ";};["write"]={["class"]="function";["classlib"]="File";["description"]="\
Writes a string to the file and advances the file position";["fname"]="write";["name"]="file_methods:write";["param"]={[1]="str";["str"]="The data to write";};["private"]=false;["realm"]="cl";["summary"]="\
Writes a string to the file and advances the file position ";};["writeBool"]={["class"]="function";["classlib"]="File";["description"]="\
Writes a boolean and advances the file position";["fname"]="writeBool";["name"]="file_methods:writeBool";["param"]={[1]="x";["x"]="The boolean to write";};["private"]=false;["realm"]="cl";["summary"]="\
Writes a boolean and advances the file position ";};["writeByte"]={["class"]="function";["classlib"]="File";["description"]="\
Writes a byte and advances the file position";["fname"]="writeByte";["name"]="file_methods:writeByte";["param"]={[1]="x";["x"]="The byte to write";};["private"]=false;["realm"]="cl";["summary"]="\
Writes a byte and advances the file position ";};["writeDouble"]={["class"]="function";["classlib"]="File";["description"]="\
Writes a double and advances the file position";["fname"]="writeDouble";["name"]="file_methods:writeDouble";["param"]={[1]="x";["x"]="The double to write";};["private"]=false;["realm"]="cl";["summary"]="\
Writes a double and advances the file position ";};["writeFloat"]={["class"]="function";["classlib"]="File";["description"]="\
Writes a float and advances the file position";["fname"]="writeFloat";["name"]="file_methods:writeFloat";["param"]={[1]="x";["x"]="The float to write";};["private"]=false;["realm"]="cl";["summary"]="\
Writes a float and advances the file position ";};["writeLong"]={["class"]="function";["classlib"]="File";["description"]="\
Writes a long and advances the file position";["fname"]="writeLong";["name"]="file_methods:writeLong";["param"]={[1]="x";["x"]="The long to write";};["private"]=false;["realm"]="cl";["summary"]="\
Writes a long and advances the file position ";};["writeShort"]={["class"]="function";["classlib"]="File";["description"]="\
Writes a short and advances the file position";["fname"]="writeShort";["name"]="file_methods:writeShort";["param"]={[1]="x";["x"]="The short to write";};["private"]=false;["realm"]="cl";["summary"]="\
Writes a short and advances the file position ";};};["name"]="File";["summary"]="\
File type ";["typtbl"]="file_methods";};["Hologram"]={["class"]="class";["description"]="\
Hologram type";["fields"]={};["methods"]={[1]="getAnimationLength";[10]="setModel";[11]="setPose";[12]="setScale";[13]="setVel";[14]="suppressEngineLighting";[2]="getAnimationNumber";[3]="getFlexes";[4]="getPose";[5]="setAngVel";[6]="setAnimation";[7]="setClip";[8]="setFlexScale";[9]="setFlexWeight";["getAnimationLength"]={["class"]="function";["classForced"]=true;["classlib"]="Hologram";["description"]="\
Get the length of the current animation";["fname"]="getAnimationLength";["name"]="hologram_methods:getAnimationLength";["param"]={};["private"]=false;["realm"]="sv";["ret"]="Length of current animation in seconds";["server"]=true;["summary"]="\
Get the length of the current animation ";};["getAnimationNumber"]={["class"]="function";["classlib"]="Hologram";["description"]="\
Convert animation name into animation number";["fname"]="getAnimationNumber";["name"]="hologram_methods:getAnimationNumber";["param"]={[1]="animation";["animation"]="Name of the animation";};["private"]=false;["realm"]="sv";["ret"]="Animation index";["server"]=true;["summary"]="\
Convert animation name into animation number ";};["getFlexes"]={["class"]="function";["classlib"]="Hologram";["description"]="\
Returns a table of flexname -> flexid pairs for use in flex functions. \
These IDs become invalid when the hologram's model changes.";["fname"]="getFlexes";["name"]="hologram_methods:getFlexes";["param"]={};["private"]=false;["realm"]="sv";["summary"]="\
Returns a table of flexname -> flexid pairs for use in flex functions.";};["getPose"]={["class"]="function";["classForced"]=true;["classlib"]="Hologram";["description"]="\
Get the pose value of an animation";["fname"]="getPose";["name"]="hologram_methods:getPose";["param"]={[1]="pose";["pose"]="Pose parameter name";};["private"]=false;["realm"]="sv";["ret"]="Value of the pose parameter";["server"]=true;["summary"]="\
Get the pose value of an animation ";};["setAngVel"]={["class"]="function";["classlib"]="Hologram";["description"]="\
Sets the hologram's angular velocity.";["fname"]="setAngVel";["name"]="hologram_methods:setAngVel";["param"]={[1]="angvel";["angvel"]="*Vector* angular velocity.";};["private"]=false;["realm"]="sv";["summary"]="\
Sets the hologram's angular velocity.";};["setAnimation"]={["class"]="function";["classForced"]=true;["classlib"]="Hologram";["description"]="\
Animates a hologram";["fname"]="setAnimation";["name"]="hologram_methods:setAnimation";["param"]={[1]="animation";[2]="frame";[3]="rate";["animation"]="number or string name";["frame"]="The starting frame number";["rate"]="Frame speed. (1 is normal)";};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Animates a hologram ";};["setClip"]={["class"]="function";["classlib"]="Hologram";["description"]="\
Updates a clip plane";["fname"]="setClip";["name"]="hologram_methods:setClip";["param"]={[1]="index";[2]="enabled";[3]="origin";[4]="normal";[5]="islocal";};["private"]=false;["realm"]="sv";["summary"]="\
Updates a clip plane ";};["setFlexScale"]={["class"]="function";["classlib"]="Hologram";["description"]="\
Sets the scale of all flexes of a hologram";["fname"]="setFlexScale";["name"]="hologram_methods:setFlexScale";["param"]={[1]="scale";};["private"]=false;["realm"]="sv";["summary"]="\
Sets the scale of all flexes of a hologram ";};["setFlexWeight"]={["class"]="function";["classlib"]="Hologram";["description"]="\
Sets the weight (value) of a flex.";["fname"]="setFlexWeight";["name"]="hologram_methods:setFlexWeight";["param"]={[1]="flexid";[2]="weight";};["private"]=false;["realm"]="sv";["summary"]="\
Sets the weight (value) of a flex.";};["setModel"]={["class"]="function";["classForced"]=true;["classlib"]="Hologram";["description"]="\
Sets the model of a hologram";["fname"]="setModel";["name"]="hologram_methods:setModel";["param"]={[1]="model";["model"]="string model path";};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Sets the model of a hologram ";};["setPose"]={["class"]="function";["classForced"]=true;["classlib"]="Hologram";["description"]="\
Set the pose value of an animation. Turret/Head angles for example.";["fname"]="setPose";["name"]="hologram_methods:setPose";["param"]={[1]="pose";[2]="value";["pose"]="Name of the pose parameter";["value"]="Value to set it to.";};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Set the pose value of an animation.";};["setScale"]={["class"]="function";["classlib"]="Hologram";["description"]="\
Sets the hologram scale";["fname"]="setScale";["name"]="hologram_methods:setScale";["param"]={[1]="scale";["scale"]="Vector new scale";};["private"]=false;["realm"]="sv";["summary"]="\
Sets the hologram scale ";};["setVel"]={["class"]="function";["classlib"]="Hologram";["description"]="\
Sets the hologram linear velocity";["fname"]="setVel";["name"]="hologram_methods:setVel";["param"]={[1]="vel";["vel"]="New velocity";};["private"]=false;["realm"]="sv";["summary"]="\
Sets the hologram linear velocity ";};["suppressEngineLighting"]={["class"]="function";["classForced"]=true;["classlib"]="Hologram";["description"]="\
Suppress Engine Lighting of a hologram. Disabled by default.";["fname"]="suppressEngineLighting";["name"]="hologram_methods:suppressEngineLighting";["param"]={[1]="suppress";["suppress"]="Boolean to represent if shading should be set or not.";};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Suppress Engine Lighting of a hologram.";};};["name"]="Hologram";["summary"]="\
Hologram type ";["typtbl"]="hologram_methods";};["Mesh"]={["class"]="class";["client"]=true;["description"]="\
Mesh type";["fields"]={};["methods"]={[1]="destroy";[2]="draw";["destroy"]={["class"]="function";["classlib"]="Mesh";["description"]="\
Frees the mesh from memory";["fname"]="destroy";["name"]="mesh_methods:destroy";["param"]={};["private"]=false;["realm"]="cl";["summary"]="\
Frees the mesh from memory ";};["draw"]={["class"]="function";["classlib"]="Mesh";["description"]="\
Draws the mesh. Must be in a 3D rendering context.";["fname"]="draw";["name"]="mesh_methods:draw";["param"]={};["private"]=false;["realm"]="cl";["summary"]="\
Draws the mesh.";};};["name"]="Mesh";["summary"]="\
Mesh type ";["typtbl"]="mesh_methods";};["Npc"]={["class"]="class";["description"]="\
Npc type";["fields"]={};["methods"]={[1]="addEntityRelationship";[10]="setEnemy";[11]="stop";[2]="addRelationship";[3]="attackMelee";[4]="attackRange";[5]="getEnemy";[6]="getRelationship";[7]="giveWeapon";[8]="goRun";[9]="goWalk";["addEntityRelationship"]={["class"]="function";["classlib"]="Npc";["description"]="\
Adds a relationship to the npc with an entity";["fname"]="addEntityRelationship";["name"]="npc_methods:addEntityRelationship";["param"]={[1]="ent";[2]="disp";[3]="priority";["disp"]="String of the relationship. (hate fear like neutral)";["ent"]="The target entity";["priority"]="number how strong the relationship is. Higher number is stronger";};["private"]=false;["realm"]="sv";["summary"]="\
Adds a relationship to the npc with an entity ";};["addRelationship"]={["class"]="function";["classlib"]="Npc";["description"]="\
Adds a relationship to the npc";["fname"]="addRelationship";["name"]="npc_methods:addRelationship";["param"]={[1]="str";["str"]="The relationship string. http://wiki.garrysmod.com/page/NPC/AddRelationship";};["private"]=false;["realm"]="sv";["summary"]="\
Adds a relationship to the npc ";};["attackMelee"]={["class"]="function";["classlib"]="Npc";["description"]="\
Makes the npc do a melee attack";["fname"]="attackMelee";["name"]="npc_methods:attackMelee";["param"]={};["private"]=false;["realm"]="sv";["summary"]="\
Makes the npc do a melee attack ";};["attackRange"]={["class"]="function";["classlib"]="Npc";["description"]="\
Makes the npc do a ranged attack";["fname"]="attackRange";["name"]="npc_methods:attackRange";["param"]={};["private"]=false;["realm"]="sv";["summary"]="\
Makes the npc do a ranged attack ";};["getEnemy"]={["class"]="function";["classlib"]="Npc";["description"]="\
Gets what the npc is fighting";["fname"]="getEnemy";["name"]="npc_methods:getEnemy";["param"]={};["private"]=false;["realm"]="sv";["ret"]="Entity the npc is fighting";["summary"]="\
Gets what the npc is fighting ";};["getRelationship"]={["class"]="function";["classlib"]="Npc";["description"]="\
Gets the npc's relationship to the target";["fname"]="getRelationship";["name"]="npc_methods:getRelationship";["param"]={[1]="ent";["ent"]="Target entity";};["private"]=false;["realm"]="sv";["ret"]="string relationship of the npc with the target";["summary"]="\
Gets the npc's relationship to the target ";};["giveWeapon"]={["class"]="function";["classlib"]="Npc";["description"]="\
Gives the npc a weapon";["fname"]="giveWeapon";["name"]="npc_methods:giveWeapon";["param"]={[1]="wep";["wep"]="The classname of the weapon";};["private"]=false;["realm"]="sv";["summary"]="\
Gives the npc a weapon ";};["goRun"]={["class"]="function";["classlib"]="Npc";["description"]="\
Makes the npc run to a destination";["fname"]="goRun";["name"]="npc_methods:goRun";["param"]={[1]="vec";["vec"]="The position of the destination";};["private"]=false;["realm"]="sv";["summary"]="\
Makes the npc run to a destination ";};["goWalk"]={["class"]="function";["classlib"]="Npc";["description"]="\
Makes the npc walk to a destination";["fname"]="goWalk";["name"]="npc_methods:goWalk";["param"]={[1]="vec";["vec"]="The position of the destination";};["private"]=false;["realm"]="sv";["summary"]="\
Makes the npc walk to a destination ";};["setEnemy"]={["class"]="function";["classlib"]="Npc";["description"]="\
Tell the npc to fight this";["fname"]="setEnemy";["name"]="npc_methods:setEnemy";["param"]={[1]="ent";["ent"]="Target entity";};["private"]=false;["realm"]="sv";["summary"]="\
Tell the npc to fight this ";};["stop"]={["class"]="function";["classlib"]="Npc";["description"]="\
Stops the npc";["fname"]="stop";["name"]="npc_methods:stop";["param"]={};["private"]=false;["realm"]="sv";["summary"]="\
Stops the npc ";};};["name"]="Npc";["summary"]="\
Npc type ";["typtbl"]="npc_methods";};["Particle"]={["class"]="class";["client"]=true;["description"]="\
Particle type";["fields"]={};["methods"]={[1]="destroy";[10]="setSortOrigin";[11]="setUpVector";[12]="startEmission";[13]="stopEmission";[2]="isFinished";[3]="isValid";[4]="restart";[5]="setControlPoint";[6]="setControlPointEntity";[7]="setControlPointParent";[8]="setForwardVector";[9]="setRightVector";["destroy"]={["class"]="function";["classlib"]="Particle";["description"]="\
Stops emission of the particle and destroys the object.";["fname"]="destroy";["name"]="particle_methods:destroy";["param"]={};["private"]=false;["realm"]="cl";["summary"]="\
Stops emission of the particle and destroys the object.";};["isFinished"]={["class"]="function";["classlib"]="Particle";["description"]="\
Restarts emission of the particle.";["fname"]="isFinished";["name"]="particle_methods:isFinished";["param"]={};["private"]=false;["realm"]="cl";["ret"]="bool finished";["summary"]="\
Restarts emission of the particle.";};["isValid"]={["class"]="function";["classlib"]="Particle";["description"]="\
Gets if the particle is valid or not.";["fname"]="isValid";["name"]="particle_methods:isValid";["param"]={};["private"]=false;["realm"]="cl";["ret"]="Is valid or not";["summary"]="\
Gets if the particle is valid or not.";};["restart"]={["class"]="function";["classlib"]="Particle";["description"]="\
Restarts emission of the particle.";["fname"]="restart";["name"]="particle_methods:restart";["param"]={};["private"]=false;["realm"]="cl";["summary"]="\
Restarts emission of the particle.";};["setControlPoint"]={["class"]="function";["classlib"]="Particle";["description"]="\
Sets a value for given control point.";["fname"]="setControlPoint";["name"]="particle_methods:setControlPoint";["param"]={[1]="id";[2]="value";[3]="number";[4]="vector";["number"]="Control Point ID (0-63)";["vector"]="Value";};["private"]=false;["realm"]="cl";["summary"]="\
Sets a value for given control point.";};["setControlPointEntity"]={["class"]="function";["classlib"]="Particle";["description"]="\
Essentially makes child control point follow the parent entity.";["fname"]="setControlPointEntity";["name"]="particle_methods:setControlPointEntity";["param"]={[1]="id";[2]="entity";[3]="number";["entity"]="Entity parent";["number"]="Child Control Point ID (0-63)";};["private"]=false;["realm"]="cl";["summary"]="\
Essentially makes child control point follow the parent entity.";};["setControlPointParent"]={["class"]="function";["classlib"]="Particle";["description"]="\
Sets the forward direction for given control point.";["fname"]="setControlPointParent";["name"]="particle_methods:setControlPointParent";["param"]={[1]="id";[2]="value";[3]="number";["number"]="Parent";};["private"]=false;["realm"]="cl";["summary"]="\
Sets the forward direction for given control point.";};["setForwardVector"]={["class"]="function";["classlib"]="Particle";["description"]="\
Sets the forward direction for given control point.";["fname"]="setForwardVector";["name"]="particle_methods:setForwardVector";["param"]={[1]="id";[2]="value";[3]="number";[4]="vector";["number"]="Control Point ID (0-63)";["vector"]="Forward";};["private"]=false;["realm"]="cl";["summary"]="\
Sets the forward direction for given control point.";};["setRightVector"]={["class"]="function";["classlib"]="Particle";["description"]="\
Sets the right direction for given control point.";["fname"]="setRightVector";["name"]="particle_methods:setRightVector";["param"]={[1]="id";[2]="value";[3]="number";[4]="vector";["number"]="Control Point ID (0-63)";["vector"]="Right";};["private"]=false;["realm"]="cl";["summary"]="\
Sets the right direction for given control point.";};["setSortOrigin"]={["class"]="function";["classlib"]="Particle";["description"]="\
Sets the sort origin for given particle system. This is used as a helper to determine which particles are in front of which.";["fname"]="setSortOrigin";["name"]="particle_methods:setSortOrigin";["param"]={[1]="origin";[2]="vector";["vector"]="Sort Origin";};["private"]=false;["realm"]="cl";["summary"]="\
Sets the sort origin for given particle system.";};["setUpVector"]={["class"]="function";["classlib"]="Particle";["description"]="\
Sets the right direction for given control point.";["fname"]="setUpVector";["name"]="particle_methods:setUpVector";["param"]={[1]="id";[2]="value";[3]="number";[4]="vector";["number"]="Control Point ID (0-63)";["vector"]="Right";};["private"]=false;["realm"]="cl";["summary"]="\
Sets the right direction for given control point.";};["startEmission"]={["class"]="function";["classlib"]="Particle";["description"]="\
Starts emission of the particle.";["fname"]="startEmission";["name"]="particle_methods:startEmission";["param"]={};["private"]=false;["realm"]="cl";["summary"]="\
Starts emission of the particle.";};["stopEmission"]={["class"]="function";["classlib"]="Particle";["description"]="\
Stops emission of the particle.";["fname"]="stopEmission";["name"]="particle_methods:stopEmission";["param"]={};["private"]=false;["realm"]="cl";["summary"]="\
Stops emission of the particle.";};};["name"]="Particle";["summary"]="\
Particle type ";["typtbl"]="particle_methods";};["PhysObj"]={["class"]="class";["client"]=true;["description"]="\
PhysObj Type";["fields"]={};["methods"]={[1]="applyForceCenter";[10]="getInertia";[11]="getMass";[12]="getMassCenter";[13]="getMaterial";[14]="getMesh";[15]="getMeshConvexes";[16]="getPos";[17]="getVelocity";[18]="isValid";[19]="localToWorld";[2]="applyForceOffset";[20]="localToWorldVector";[21]="setInertia";[22]="setMass";[23]="setMaterial";[24]="setPos";[25]="setVelocity";[26]="wake";[27]="worldToLocal";[28]="worldToLocalVector";[3]="applyTorque";[4]="enableDrag";[5]="enableGravity";[6]="enableMotion";[7]="getAngleVelocity";[8]="getAngles";[9]="getEntity";["applyForceCenter"]={["class"]="function";["classlib"]="PhysObj";["description"]="\
Applys a force to the center of the physics object";["fname"]="applyForceCenter";["name"]="physobj_methods:applyForceCenter";["param"]={[1]="force";["force"]="The force vector to apply";};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Applys a force to the center of the physics object ";};["applyForceOffset"]={["class"]="function";["classlib"]="PhysObj";["description"]="\
Applys an offset force to a physics object";["fname"]="applyForceOffset";["name"]="physobj_methods:applyForceOffset";["param"]={[1]="force";[2]="position";["force"]="The force vector to apply";["position"]="The position in world coordinates";};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Applys an offset force to a physics object ";};["applyTorque"]={["class"]="function";["classlib"]="PhysObj";["description"]="\
Applys a torque to a physics object";["fname"]="applyTorque";["name"]="physobj_methods:applyTorque";["param"]={[1]="torque";["torque"]="The local torque vector to apply";};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Applys a torque to a physics object ";};["enableDrag"]={["class"]="function";["classlib"]="PhysObj";["description"]="\
Sets the bone drag state";["fname"]="enableDrag";["name"]="physobj_methods:enableDrag";["param"]={[1]="drag";["drag"]="Bool should the bone have air resistence?";};["private"]=false;["realm"]="sh";["summary"]="\
Sets the bone drag state ";};["enableGravity"]={["class"]="function";["classlib"]="PhysObj";["description"]="\
Sets bone gravity";["fname"]="enableGravity";["name"]="physobj_methods:enableGravity";["param"]={[1]="grav";["grav"]="Bool should the bone respect gravity?";};["private"]=false;["realm"]="sh";["summary"]="\
Sets bone gravity ";};["enableMotion"]={["class"]="function";["classlib"]="PhysObj";["description"]="\
Sets the bone movement state";["fname"]="enableMotion";["name"]="physobj_methods:enableMotion";["param"]={[1]="move";["move"]="Bool should the bone move?";};["private"]=false;["realm"]="sh";["summary"]="\
Sets the bone movement state ";};["getAngleVelocity"]={["class"]="function";["classlib"]="PhysObj";["client"]=true;["description"]="\
Gets the angular velocity of the physics object";["fname"]="getAngleVelocity";["name"]="physobj_methods:getAngleVelocity";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Vector angular velocity of the physics object";["server"]=true;["summary"]="\
Gets the angular velocity of the physics object ";};["getAngles"]={["class"]="function";["classlib"]="PhysObj";["client"]=true;["description"]="\
Gets the angles of the physics object";["fname"]="getAngles";["name"]="physobj_methods:getAngles";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Angle angles of the physics object";["server"]=true;["summary"]="\
Gets the angles of the physics object ";};["getEntity"]={["class"]="function";["classlib"]="PhysObj";["client"]=true;["description"]="\
Gets the entity attached to the physics object";["fname"]="getEntity";["name"]="physobj_methods:getEntity";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The entity attached to the physics object";["server"]=true;["summary"]="\
Gets the entity attached to the physics object ";};["getInertia"]={["class"]="function";["classlib"]="PhysObj";["client"]=true;["description"]="\
Gets the inertia of the physics object";["fname"]="getInertia";["name"]="physobj_methods:getInertia";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Vector Inertia of the physics object";["server"]=true;["summary"]="\
Gets the inertia of the physics object ";};["getMass"]={["class"]="function";["classlib"]="PhysObj";["client"]=true;["description"]="\
Gets the mass of the physics object";["fname"]="getMass";["name"]="physobj_methods:getMass";["param"]={};["private"]=false;["realm"]="sh";["ret"]="mass of the physics object";["server"]=true;["summary"]="\
Gets the mass of the physics object ";};["getMassCenter"]={["class"]="function";["classlib"]="PhysObj";["client"]=true;["description"]="\
Gets the center of mass of the physics object in the local reference frame.";["fname"]="getMassCenter";["name"]="physobj_methods:getMassCenter";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Center of mass vector in the physobject's local reference frame.";["server"]=true;["summary"]="\
Gets the center of mass of the physics object in the local reference frame.";};["getMaterial"]={["class"]="function";["classlib"]="PhysObj";["client"]=true;["description"]="\
Gets the material of the physics object";["fname"]="getMaterial";["name"]="physobj_methods:getMaterial";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The physics material of the physics object";["server"]=true;["summary"]="\
Gets the material of the physics object ";};["getMesh"]={["class"]="function";["classlib"]="PhysObj";["description"]="\
Returns a table of MeshVertex structures where each 3 vertices represent a triangle. See: http://wiki.garrysmod.com/page/Structures/MeshVertex";["fname"]="getMesh";["name"]="physobj_methods:getMesh";["param"]={};["private"]=false;["realm"]="sh";["ret"]="table of MeshVertex structures";["summary"]="\
Returns a table of MeshVertex structures where each 3 vertices represent a triangle.";};["getMeshConvexes"]={["class"]="function";["classlib"]="PhysObj";["description"]="\
Returns a structured table, the physics mesh of the physics object. See: http://wiki.garrysmod.com/page/Structures/MeshVertex";["fname"]="getMeshConvexes";["name"]="physobj_methods:getMeshConvexes";["param"]={};["private"]=false;["realm"]="sh";["ret"]="table of MeshVertex structures";["summary"]="\
Returns a structured table, the physics mesh of the physics object.";};["getPos"]={["class"]="function";["classlib"]="PhysObj";["client"]=true;["description"]="\
Gets the position of the physics object";["fname"]="getPos";["name"]="physobj_methods:getPos";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Vector position of the physics object";["server"]=true;["summary"]="\
Gets the position of the physics object ";};["getVelocity"]={["class"]="function";["classlib"]="PhysObj";["client"]=true;["description"]="\
Gets the velocity of the physics object";["fname"]="getVelocity";["name"]="physobj_methods:getVelocity";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Vector velocity of the physics object";["server"]=true;["summary"]="\
Gets the velocity of the physics object ";};["isValid"]={["class"]="function";["classlib"]="PhysObj";["client"]=true;["description"]="\
Checks if the physics object is valid";["fname"]="isValid";["name"]="physobj_methods:isValid";["param"]={};["private"]=false;["realm"]="sh";["ret"]="boolean if the physics object is valid";["server"]=true;["summary"]="\
Checks if the physics object is valid ";};["localToWorld"]={["class"]="function";["classlib"]="PhysObj";["description"]="\
Returns a vector in the reference frame of the world from the local frame of the physicsobject";["fname"]="localToWorld";["name"]="physobj_methods:localToWorld";["param"]={[1]="vec";["vec"]="The vector to transform";};["private"]=false;["realm"]="sh";["ret"]="The transformed vector";["summary"]="\
Returns a vector in the reference frame of the world from the local frame of the physicsobject ";};["localToWorldVector"]={["class"]="function";["classlib"]="PhysObj";["description"]="\
Returns a normal vector in the reference frame of the world from the local frame of the physicsobject";["fname"]="localToWorldVector";["name"]="physobj_methods:localToWorldVector";["param"]={[1]="vec";["vec"]="The normal vector to transform";};["private"]=false;["realm"]="sh";["ret"]="The transformed vector";["summary"]="\
Returns a normal vector in the reference frame of the world from the local frame of the physicsobject ";};["setInertia"]={["class"]="function";["classlib"]="PhysObj";["description"]="\
Sets the inertia of a physics object";["fname"]="setInertia";["name"]="physobj_methods:setInertia";["param"]={[1]="inertia";["inertia"]="The inertia vector to set it to";};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Sets the inertia of a physics object ";};["setMass"]={["class"]="function";["classlib"]="PhysObj";["description"]="\
Sets the mass of a physics object";["fname"]="setMass";["name"]="physobj_methods:setMass";["param"]={[1]="mass";["mass"]="The mass to set it to";};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Sets the mass of a physics object ";};["setMaterial"]={["class"]="function";["classlib"]="PhysObj";["description"]="\
Sets the physical material of a physics object";["fname"]="setMaterial";["name"]="physobj_methods:setMaterial";["param"]={[1]="material";["material"]="The physical material to set it to";};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Sets the physical material of a physics object ";};["setPos"]={["class"]="function";["classlib"]="PhysObj";["description"]="\
Sets the position of the physics object";["fname"]="setPos";["name"]="physobj_methods:setPos";["param"]={[1]="pos";["pos"]="The position vector to set it to";};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Sets the position of the physics object ";};["setVelocity"]={["class"]="function";["classlib"]="PhysObj";["description"]="\
Sets the velocity of the physics object";["fname"]="setVelocity";["name"]="physobj_methods:setVelocity";["param"]={[1]="vel";["vel"]="The velocity vector to set it to";};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Sets the velocity of the physics object ";};["wake"]={["class"]="function";["classlib"]="PhysObj";["description"]="\
Makes a sleeping physobj wakeup";["fname"]="wake";["name"]="physobj_methods:wake";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Makes a sleeping physobj wakeup ";};["worldToLocal"]={["class"]="function";["classlib"]="PhysObj";["description"]="\
Returns a vector in the local reference frame of the physicsobject from the world frame";["fname"]="worldToLocal";["name"]="physobj_methods:worldToLocal";["param"]={[1]="vec";["vec"]="The vector to transform";};["private"]=false;["realm"]="sh";["ret"]="The transformed vector";["summary"]="\
Returns a vector in the local reference frame of the physicsobject from the world frame ";};["worldToLocalVector"]={["class"]="function";["classlib"]="PhysObj";["description"]="\
Returns a normal vector in the local reference frame of the physicsobject from the world frame";["fname"]="worldToLocalVector";["name"]="physobj_methods:worldToLocalVector";["param"]={[1]="vec";["vec"]="The normal vector to transform";};["private"]=false;["realm"]="sh";["ret"]="The transformed vector";["summary"]="\
Returns a normal vector in the local reference frame of the physicsobject from the world frame ";};};["name"]="PhysObj";["server"]=true;["summary"]="\
PhysObj Type ";["typtbl"]="physobj_methods";};["Player"]={["class"]="class";["description"]="\
Player type";["fields"]={};["methods"]={[1]="getActiveWeapon";[10]="getMaxSpeed";[11]="getName";[12]="getPing";[13]="getRunSpeed";[14]="getShootPos";[15]="getSteamID";[16]="getSteamID64";[17]="getTeam";[18]="getTeamName";[19]="getUniqueID";[2]="getAimVector";[20]="getUserID";[21]="getViewEntity";[22]="getWeapon";[23]="getWeapons";[24]="hasGodMode";[25]="inVehicle";[26]="isAdmin";[27]="isAlive";[28]="isBot";[29]="isConnected";[3]="getArmor";[30]="isCrouching";[31]="isFlashlightOn";[32]="isFrozen";[33]="isMuted";[34]="isNPC";[35]="isNoclipped";[36]="isPlayer";[37]="isSuperAdmin";[38]="isUserGroup";[39]="keyDown";[4]="getDeaths";[40]="setViewEntity";[5]="getEyeTrace";[6]="getFOV";[7]="getFrags";[8]="getFriendStatus";[9]="getJumpPower";["getActiveWeapon"]={["class"]="function";["classlib"]="Player";["client"]=true;["description"]="\
Returns the name of the player's active weapon";["fname"]="getActiveWeapon";["name"]="player_methods:getActiveWeapon";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The weapon";["server"]=true;["summary"]="\
Returns the name of the player's active weapon ";};["getAimVector"]={["class"]="function";["classlib"]="Player";["client"]=true;["description"]="\
Returns the player's aim vector";["fname"]="getAimVector";["name"]="player_methods:getAimVector";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Aim vector";["server"]=true;["summary"]="\
Returns the player's aim vector ";};["getArmor"]={["class"]="function";["classlib"]="Player";["client"]=true;["description"]="\
Returns the players armor";["fname"]="getArmor";["name"]="player_methods:getArmor";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Armor";["server"]=true;["summary"]="\
Returns the players armor ";};["getDeaths"]={["class"]="function";["classlib"]="Player";["client"]=true;["description"]="\
Returns the amount of deaths of the player";["fname"]="getDeaths";["name"]="player_methods:getDeaths";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Amount of deaths";["server"]=true;["summary"]="\
Returns the amount of deaths of the player ";};["getEyeTrace"]={["class"]="function";["classlib"]="Player";["client"]=true;["description"]="\
Returns a table with information of what the player is looking at";["fname"]="getEyeTrace";["name"]="player_methods:getEyeTrace";["param"]={};["private"]=false;["realm"]="sh";["ret"]="table trace data https://wiki.garrysmod.com/page/Structures/TraceResult";["server"]=true;["summary"]="\
Returns a table with information of what the player is looking at ";};["getFOV"]={["class"]="function";["classlib"]="Player";["client"]=true;["description"]="\
Returns the player's field of view";["fname"]="getFOV";["name"]="player_methods:getFOV";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Field of view";["server"]=true;["summary"]="\
Returns the player's field of view ";};["getFrags"]={["class"]="function";["classlib"]="Player";["client"]=true;["description"]="\
Returns the amount of kills of the player";["fname"]="getFrags";["name"]="player_methods:getFrags";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Amount of kills";["server"]=true;["summary"]="\
Returns the amount of kills of the player ";};["getFriendStatus"]={["class"]="function";["classlib"]="Player";["description"]="\
Returns the relationship of the player to the local client";["fname"]="getFriendStatus";["name"]="player_methods:getFriendStatus";["param"]={};["private"]=false;["realm"]="sh";["ret"]="One of: \"friend\", \"blocked\", \"none\", \"requested\"";["summary"]="\
Returns the relationship of the player to the local client ";};["getJumpPower"]={["class"]="function";["classlib"]="Player";["client"]=true;["description"]="\
Returns the player's jump power";["fname"]="getJumpPower";["name"]="player_methods:getJumpPower";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Jump power";["server"]=true;["summary"]="\
Returns the player's jump power ";};["getMaxSpeed"]={["class"]="function";["classlib"]="Player";["client"]=true;["description"]="\
Returns the player's maximum speed";["fname"]="getMaxSpeed";["name"]="player_methods:getMaxSpeed";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Maximum speed";["server"]=true;["summary"]="\
Returns the player's maximum speed ";};["getName"]={["class"]="function";["classlib"]="Player";["client"]=true;["description"]="\
Returns the player's name";["fname"]="getName";["name"]="player_methods:getName";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Name";["server"]=true;["summary"]="\
Returns the player's name ";};["getPing"]={["class"]="function";["classlib"]="Player";["client"]=true;["description"]="\
Returns the player's current ping";["fname"]="getPing";["name"]="player_methods:getPing";["param"]={};["private"]=false;["realm"]="sh";["ret"]="ping";["server"]=true;["summary"]="\
Returns the player's current ping ";};["getRunSpeed"]={["class"]="function";["classlib"]="Player";["client"]=true;["description"]="\
Returns the player's running speed";["fname"]="getRunSpeed";["name"]="player_methods:getRunSpeed";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Running speed";["server"]=true;["summary"]="\
Returns the player's running speed ";};["getShootPos"]={["class"]="function";["classlib"]="Player";["client"]=true;["description"]="\
Returns the player's shoot position";["fname"]="getShootPos";["name"]="player_methods:getShootPos";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Shoot position";["server"]=true;["summary"]="\
Returns the player's shoot position ";};["getSteamID"]={["class"]="function";["classlib"]="Player";["client"]=true;["description"]="\
Returns the player's steam ID";["fname"]="getSteamID";["name"]="player_methods:getSteamID";["param"]={};["private"]=false;["realm"]="sh";["ret"]="steam ID";["server"]=true;["summary"]="\
Returns the player's steam ID ";};["getSteamID64"]={["class"]="function";["classlib"]="Player";["client"]=true;["description"]="\
Returns the player's community ID";["fname"]="getSteamID64";["name"]="player_methods:getSteamID64";["param"]={};["private"]=false;["realm"]="sh";["ret"]="community ID";["server"]=true;["summary"]="\
Returns the player's community ID ";};["getTeam"]={["class"]="function";["classlib"]="Player";["client"]=true;["description"]="\
Returns the player's current team";["fname"]="getTeam";["name"]="player_methods:getTeam";["param"]={};["private"]=false;["realm"]="sh";["ret"]="team";["server"]=true;["summary"]="\
Returns the player's current team ";};["getTeamName"]={["class"]="function";["classlib"]="Player";["client"]=true;["description"]="\
Returns the name of the player's current team";["fname"]="getTeamName";["name"]="player_methods:getTeamName";["param"]={};["private"]=false;["realm"]="sh";["ret"]="team name";["server"]=true;["summary"]="\
Returns the name of the player's current team ";};["getUniqueID"]={["class"]="function";["classlib"]="Player";["client"]=true;["description"]="\
Returns the player's unique ID";["fname"]="getUniqueID";["name"]="player_methods:getUniqueID";["param"]={};["private"]=false;["realm"]="sh";["ret"]="unique ID";["server"]=true;["summary"]="\
Returns the player's unique ID ";};["getUserID"]={["class"]="function";["classlib"]="Player";["client"]=true;["description"]="\
Returns the player's user ID";["fname"]="getUserID";["name"]="player_methods:getUserID";["param"]={};["private"]=false;["realm"]="sh";["ret"]="user ID";["server"]=true;["summary"]="\
Returns the player's user ID ";};["getViewEntity"]={["class"]="function";["classlib"]="Player";["client"]=true;["description"]="\
Returns the player's current view entity";["fname"]="getViewEntity";["name"]="player_methods:getViewEntity";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Player's current view entity";["server"]=true;["summary"]="\
Returns the player's current view entity ";};["getWeapon"]={["class"]="function";["classlib"]="Player";["client"]=true;["description"]="\
Returns the specified weapon or nil if the player doesn't have it";["fname"]="getWeapon";["name"]="player_methods:getWeapon";["param"]={[1]="wep";["wep"]="String weapon class";};["private"]=false;["realm"]="sh";["ret"]="weapon";["server"]=true;["summary"]="\
Returns the specified weapon or nil if the player doesn't have it ";};["getWeapons"]={["class"]="function";["classlib"]="Player";["client"]=true;["description"]="\
Returns a table of weapons the player is carrying";["fname"]="getWeapons";["name"]="player_methods:getWeapons";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Table of weapons";["server"]=true;["summary"]="\
Returns a table of weapons the player is carrying ";};["hasGodMode"]={["class"]="function";["classlib"]="Player";["description"]="\
Returns whether or not the player has godmode";["fname"]="hasGodMode";["name"]="player_methods:hasGodMode";["param"]={};["private"]=false;["realm"]="sv";["ret"]="True if the player has godmode";["server"]=true;["summary"]="\
Returns whether or not the player has godmode ";};["inVehicle"]={["class"]="function";["classlib"]="Player";["client"]=true;["description"]="\
Returns whether the player is in a vehicle";["fname"]="inVehicle";["name"]="player_methods:inVehicle";["param"]={};["private"]=false;["realm"]="sh";["ret"]="True if player in vehicle";["server"]=true;["summary"]="\
Returns whether the player is in a vehicle ";};["isAdmin"]={["class"]="function";["classlib"]="Player";["client"]=true;["description"]="\
Returns whether the player is an admin";["fname"]="isAdmin";["name"]="player_methods:isAdmin";["param"]={};["private"]=false;["realm"]="sh";["ret"]="True if player is admin";["server"]=true;["summary"]="\
Returns whether the player is an admin ";};["isAlive"]={["class"]="function";["classlib"]="Player";["client"]=true;["description"]="\
Returns whether the player is alive";["fname"]="isAlive";["name"]="player_methods:isAlive";["param"]={};["private"]=false;["realm"]="sh";["ret"]="True if player alive";["server"]=true;["summary"]="\
Returns whether the player is alive ";};["isBot"]={["class"]="function";["classlib"]="Player";["client"]=true;["description"]="\
Returns whether the player is a bot";["fname"]="isBot";["name"]="player_methods:isBot";["param"]={};["private"]=false;["realm"]="sh";["ret"]="True if player is a bot";["server"]=true;["summary"]="\
Returns whether the player is a bot ";};["isConnected"]={["class"]="function";["classlib"]="Player";["client"]=true;["description"]="\
Returns whether the player is connected";["fname"]="isConnected";["name"]="player_methods:isConnected";["param"]={};["private"]=false;["realm"]="sh";["ret"]="True if player is connected";["server"]=true;["summary"]="\
Returns whether the player is connected ";};["isCrouching"]={["class"]="function";["classlib"]="Player";["client"]=true;["description"]="\
Returns whether the player is crouching";["fname"]="isCrouching";["name"]="player_methods:isCrouching";["param"]={};["private"]=false;["realm"]="sh";["ret"]="True if player crouching";["server"]=true;["summary"]="\
Returns whether the player is crouching ";};["isFlashlightOn"]={["class"]="function";["classlib"]="Player";["client"]=true;["description"]="\
Returns whether the player's flashlight is on";["fname"]="isFlashlightOn";["name"]="player_methods:isFlashlightOn";["param"]={};["private"]=false;["realm"]="sh";["ret"]="True if player has flashlight on";["server"]=true;["summary"]="\
Returns whether the player's flashlight is on ";};["isFrozen"]={["class"]="function";["classlib"]="Player";["client"]=true;["description"]="\
Returns whether the player is frozen";["fname"]="isFrozen";["name"]="player_methods:isFrozen";["param"]={};["private"]=false;["realm"]="sh";["ret"]="True if player is frozen";["server"]=true;["summary"]="\
Returns whether the player is frozen ";};["isMuted"]={["class"]="function";["classlib"]="Player";["description"]="\
Returns whether the local player has muted the player";["fname"]="isMuted";["name"]="player_methods:isMuted";["param"]={};["private"]=false;["realm"]="sh";["ret"]="True if the player was muted";["summary"]="\
Returns whether the local player has muted the player ";};["isNPC"]={["class"]="function";["classlib"]="Player";["client"]=true;["description"]="\
Returns whether the player is an NPC";["fname"]="isNPC";["name"]="player_methods:isNPC";["param"]={};["private"]=false;["realm"]="sh";["ret"]="True if player is an NPC";["server"]=true;["summary"]="\
Returns whether the player is an NPC ";};["isNoclipped"]={["class"]="function";["classlib"]="Player";["client"]=true;["description"]="\
Returns true if the player is noclipped";["fname"]="isNoclipped";["name"]="player_methods:isNoclipped";["param"]={};["private"]=false;["realm"]="sh";["ret"]="true if the player is noclipped";["server"]=true;["summary"]="\
Returns true if the player is noclipped ";};["isPlayer"]={["class"]="function";["classlib"]="Player";["client"]=true;["description"]="\
Returns whether the player is a player";["fname"]="isPlayer";["name"]="player_methods:isPlayer";["param"]={};["private"]=false;["realm"]="sh";["ret"]="True if player is player";["server"]=true;["summary"]="\
Returns whether the player is a player ";};["isSuperAdmin"]={["class"]="function";["classlib"]="Player";["client"]=true;["description"]="\
Returns whether the player is a super admin";["fname"]="isSuperAdmin";["name"]="player_methods:isSuperAdmin";["param"]={};["private"]=false;["realm"]="sh";["ret"]="True if player is super admin";["server"]=true;["summary"]="\
Returns whether the player is a super admin ";};["isUserGroup"]={["class"]="function";["classlib"]="Player";["client"]=true;["description"]="\
Returns whether the player belongs to a usergroup";["fname"]="isUserGroup";["name"]="player_methods:isUserGroup";["param"]={[1]="group";["group"]="Group to check against";};["private"]=false;["realm"]="sh";["ret"]="True if player belongs to group";["server"]=true;["summary"]="\
Returns whether the player belongs to a usergroup ";};["keyDown"]={["class"]="function";["classlib"]="Player";["client"]=true;["description"]="\
Returns whether or not the player is pushing the key.";["fname"]="keyDown";["name"]="player_methods:keyDown";["param"]={[1]="key";["key"]="Key to check. \
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
IN_KEY.RUN";};["private"]=false;["realm"]="sh";["ret"]="True or false";["server"]=true;["summary"]="\
Returns whether or not the player is pushing the key.";};["setViewEntity"]={["class"]="function";["classlib"]="Player";["description"]="\
Sets the view entity of the player. Only works if they are linked to a hud.";["fname"]="setViewEntity";["name"]="player_methods:setViewEntity";["param"]={[1]="ent";["ent"]="Entity to set the player's view entity to, or nothing to reset it";};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Sets the view entity of the player.";};};["name"]="Player";["summary"]="\
Player type ";["typtbl"]="player_methods";};["Quaternion"]={["class"]="class";["description"]="\
Quaternion type";["fields"]={};["methods"]={[1]="conj";[2]="forward";[3]="i";[4]="j";[5]="k";[6]="r";[7]="real";[8]="right";[9]="up";["conj"]={["class"]="function";["classlib"]="Quaternion";["description"]="\
Returns the conj of self";["fname"]="conj";["name"]="quat_methods:conj";["param"]={};["private"]=false;["realm"]="sh";["summary"]="\
Returns the conj of self ";};["forward"]={["class"]="function";["classlib"]="Quaternion";["description"]="\
Returns vector pointing forward for <this>";["fname"]="forward";["name"]="quat_methods:forward";["param"]={};["private"]=false;["realm"]="sh";["summary"]="\
Returns vector pointing forward for <this> ";};["i"]={["class"]="function";["classlib"]="Quaternion";["description"]="\
Returns the i component of the quaternion";["fname"]="i";["name"]="quat_methods:i";["param"]={};["private"]=false;["realm"]="sh";["summary"]="\
Returns the i component of the quaternion ";};["j"]={["class"]="function";["classlib"]="Quaternion";["description"]="\
Returns the j component of the quaternion";["fname"]="j";["name"]="quat_methods:j";["param"]={};["private"]=false;["realm"]="sh";["summary"]="\
Returns the j component of the quaternion ";};["k"]={["class"]="function";["classlib"]="Quaternion";["description"]="\
Returns the k component of the quaternion";["fname"]="k";["name"]="quat_methods:k";["param"]={};["private"]=false;["realm"]="sh";["summary"]="\
Returns the k component of the quaternion ";};["r"]={["class"]="function";["classlib"]="Quaternion";["description"]="\
Alias for :real() as r is easier";["fname"]="r";["name"]="quat_methods:r";["param"]={};["private"]=false;["realm"]="sh";["summary"]="\
Alias for :real() as r is easier ";};["real"]={["class"]="function";["classlib"]="Quaternion";["description"]="\
Returns the real component of the quaternion";["fname"]="real";["name"]="quat_methods:real";["param"]={};["private"]=false;["realm"]="sh";["summary"]="\
Returns the real component of the quaternion ";};["right"]={["class"]="function";["classlib"]="Quaternion";["description"]="\
Returns vector pointing right for <this>";["fname"]="right";["name"]="quat_methods:right";["param"]={};["private"]=false;["realm"]="sh";["summary"]="\
Returns vector pointing right for <this> ";};["up"]={["class"]="function";["classlib"]="Quaternion";["description"]="\
Returns vector pointing up for <this>";["fname"]="up";["name"]="quat_methods:up";["param"]={};["private"]=false;["realm"]="sh";["summary"]="\
Returns vector pointing up for <this> ";};};["name"]="Quaternion";["summary"]="\
Quaternion type ";["typtbl"]="quat_methods";};["Sound"]={["class"]="class";["client"]=true;["description"]="\
Sound type";["fields"]={};["methods"]={[1]="isPlaying";[2]="play";[3]="setPitch";[4]="setSoundLevel";[5]="setVolume";[6]="stop";["isPlaying"]={["class"]="function";["classlib"]="Sound";["description"]="\
Returns whether the sound is being played.";["fname"]="isPlaying";["name"]="sound_methods:isPlaying";["param"]={};["private"]=false;["realm"]="sh";["summary"]="\
Returns whether the sound is being played.";};["play"]={["class"]="function";["classlib"]="Sound";["description"]="\
Starts to play the sound.";["fname"]="play";["name"]="sound_methods:play";["param"]={};["private"]=false;["realm"]="sh";["summary"]="\
Starts to play the sound.";};["setPitch"]={["class"]="function";["classlib"]="Sound";["description"]="\
Sets the pitch of the sound.";["fname"]="setPitch";["name"]="sound_methods:setPitch";["param"]={[1]="pitch";[2]="fade";["fade"]="Time in seconds to transition to this new pitch.";["pitch"]="Pitch to set to, between 0 and 255.";};["private"]=false;["realm"]="sh";["summary"]="\
Sets the pitch of the sound.";};["setSoundLevel"]={["class"]="function";["classlib"]="Sound";["description"]="\
Sets the sound level in dB.";["fname"]="setSoundLevel";["name"]="sound_methods:setSoundLevel";["param"]={[1]="level";["level"]="dB level, see <a href='https://developer.valvesoftware.com/wiki/Soundscripts#SoundLevel'> Vale Dev Wiki</a>, for information on the value to use.";};["private"]=false;["realm"]="sh";["summary"]="\
Sets the sound level in dB.";};["setVolume"]={["class"]="function";["classlib"]="Sound";["description"]="\
Sets the volume of the sound.";["fname"]="setVolume";["name"]="sound_methods:setVolume";["param"]={[1]="vol";[2]="fade";["fade"]="Time in seconds to transition to this new volume.";["vol"]="Volume to set to, between 0 and 1.";};["private"]=false;["realm"]="sh";["summary"]="\
Sets the volume of the sound.";};["stop"]={["class"]="function";["classlib"]="Sound";["description"]="\
Stops the sound from being played.";["fname"]="stop";["name"]="sound_methods:stop";["param"]={[1]="fade";["fade"]="Time in seconds to fade out, if nil or 0 the sound stops instantly.";};["private"]=false;["realm"]="sh";["summary"]="\
Stops the sound from being played.";};};["name"]="Sound";["server"]=true;["summary"]="\
Sound type ";["typtbl"]="sound_methods";};["VMatrix"]={["class"]="class";["description"]="\
VMatrix type";["fields"]={};["methods"]={[1]="getAngles";[10]="getTransposed";[11]="getUp";[12]="invert";[13]="invertTR";[14]="isIdentity";[15]="isRotationMatrix";[16]="rotate";[17]="scale";[18]="scaleTranslation";[19]="set";[2]="getAxisAngle";[20]="setAngles";[21]="setField";[22]="setForward";[23]="setIdentity";[24]="setRight";[25]="setScale";[26]="setTranslation";[27]="setUp";[28]="toTable";[29]="translate";[3]="getField";[30]="transpose";[4]="getForward";[5]="getInverse";[6]="getInverseTR";[7]="getRight";[8]="getScale";[9]="getTranslation";["getAngles"]={["class"]="function";["classlib"]="VMatrix";["description"]="\
Returns angles";["fname"]="getAngles";["name"]="vmatrix_methods:getAngles";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Angles";["summary"]="\
Returns angles ";};["getAxisAngle"]={["class"]="function";["classlib"]="VMatrix";["description"]="\
Gets the rotation axis and angle of rotation of the rotation matrix";["fname"]="getAxisAngle";["name"]="vmatrix_methods:getAxisAngle";["param"]={};["private"]=false;["realm"]="sh";["ret"]={[1]="The axis of rotation";[2]="The angle of rotation";};["summary"]="\
Gets the rotation axis and angle of rotation of the rotation matrix ";};["getField"]={["class"]="function";["classlib"]="VMatrix";["description"]="\
Returns a specific field in the matrix";["fname"]="getField";["name"]="vmatrix_methods:getField";["param"]={[1]="row";[2]="column";["column"]="A number from 1 to 4";["row"]="A number from 1 to 4";};["private"]=false;["realm"]="sh";["ret"]="Value of the specified field";["summary"]="\
Returns a specific field in the matrix ";};["getForward"]={["class"]="function";["classlib"]="VMatrix";["description"]="\
Returns forward vector of matrix. First matrix column";["fname"]="getForward";["name"]="vmatrix_methods:getForward";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Translation";["summary"]="\
Returns forward vector of matrix.";};["getInverse"]={["class"]="function";["classlib"]="VMatrix";["description"]="\
Returns an inverted matrix. Inverting the matrix will fail if its determinant is 0 or close to 0";["fname"]="getInverse";["name"]="vmatrix_methods:getInverse";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Inverted matrix";["summary"]="\
Returns an inverted matrix.";};["getInverseTR"]={["class"]="function";["classlib"]="VMatrix";["description"]="\
Returns an inverted matrix. Efficiently for translations and rotations";["fname"]="getInverseTR";["name"]="vmatrix_methods:getInverseTR";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Inverted matrix";["summary"]="\
Returns an inverted matrix.";};["getRight"]={["class"]="function";["classlib"]="VMatrix";["description"]="\
Returns right vector of matrix. Negated second matrix column";["fname"]="getRight";["name"]="vmatrix_methods:getRight";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Translation";["summary"]="\
Returns right vector of matrix.";};["getScale"]={["class"]="function";["classlib"]="VMatrix";["description"]="\
Returns scale";["fname"]="getScale";["name"]="vmatrix_methods:getScale";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Scale";["summary"]="\
Returns scale ";};["getTranslation"]={["class"]="function";["classlib"]="VMatrix";["description"]="\
Returns translation";["fname"]="getTranslation";["name"]="vmatrix_methods:getTranslation";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Translation";["summary"]="\
Returns translation ";};["getTransposed"]={["class"]="function";["classlib"]="VMatrix";["description"]="\
Returns the transposed matrix";["fname"]="getTransposed";["name"]="vmatrix_methods:getTransposed";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Transposed matrix";["summary"]="\
Returns the transposed matrix ";};["getUp"]={["class"]="function";["classlib"]="VMatrix";["description"]="\
Returns up vector of matrix. Third matrix column";["fname"]="getUp";["name"]="vmatrix_methods:getUp";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Translation";["summary"]="\
Returns up vector of matrix.";};["invert"]={["class"]="function";["classlib"]="VMatrix";["description"]="\
Inverts the matrix. Inverting the matrix will fail if its determinant is 0 or close to 0";["fname"]="invert";["name"]="vmatrix_methods:invert";["param"]={};["private"]=false;["realm"]="sh";["ret"]="bool Whether the matrix was inverted or not";["summary"]="\
Inverts the matrix.";};["invertTR"]={["class"]="function";["classlib"]="VMatrix";["description"]="\
Inverts the matrix efficiently for translations and rotations";["fname"]="invertTR";["name"]="vmatrix_methods:invertTR";["param"]={};["private"]=false;["realm"]="sh";["summary"]="\
Inverts the matrix efficiently for translations and rotations ";};["isIdentity"]={["class"]="function";["classlib"]="VMatrix";["description"]="\
Returns whether the matrix is equal to Identity matrix or not";["fname"]="isIdentity";["name"]="vmatrix_methods:isIdentity";["param"]={};["private"]=false;["realm"]="sh";["ret"]="bool True/False";["summary"]="\
Returns whether the matrix is equal to Identity matrix or not ";};["isRotationMatrix"]={["class"]="function";["classlib"]="VMatrix";["description"]="\
Returns whether the matrix is a rotation matrix or not. Checks if the forward, right and up vectors are orthogonal and normalized.";["fname"]="isRotationMatrix";["name"]="vmatrix_methods:isRotationMatrix";["param"]={};["private"]=false;["realm"]="sh";["ret"]="bool True/False";["summary"]="\
Returns whether the matrix is a rotation matrix or not.";};["rotate"]={["class"]="function";["classlib"]="VMatrix";["description"]="\
Rotate the matrix";["fname"]="rotate";["name"]="vmatrix_methods:rotate";["param"]={[1]="ang";["ang"]="Angle to rotate by";};["private"]=false;["realm"]="sh";["summary"]="\
Rotate the matrix ";};["scale"]={["class"]="function";["classlib"]="VMatrix";["description"]="\
Scale the matrix";["fname"]="scale";["name"]="vmatrix_methods:scale";["param"]={[1]="vec";["vec"]="Vector to scale by";};["private"]=false;["realm"]="sh";["summary"]="\
Scale the matrix ";};["scaleTranslation"]={["class"]="function";["classlib"]="VMatrix";["description"]="\
Scales the absolute translation";["fname"]="scaleTranslation";["name"]="vmatrix_methods:scaleTranslation";["param"]={[1]="num";["num"]="Amount to scale by";};["private"]=false;["realm"]="sh";["summary"]="\
Scales the absolute translation ";};["set"]={["class"]="function";["classlib"]="VMatrix";["description"]="\
Copies the values from the second matrix to the first matrix. Self-Modifies";["fname"]="set";["name"]="vmatrix_methods:set";["param"]={[1]="src";["src"]="Second matrix";};["private"]=false;["realm"]="sh";["summary"]="\
Copies the values from the second matrix to the first matrix.";};["setAngles"]={["class"]="function";["classlib"]="VMatrix";["description"]="\
Sets the angles";["fname"]="setAngles";["name"]="vmatrix_methods:setAngles";["param"]={[1]="ang";["ang"]="New angles";};["private"]=false;["realm"]="sh";["summary"]="\
Sets the angles ";};["setField"]={["class"]="function";["classlib"]="VMatrix";["description"]="\
Sets a specific field in the matrix";["fname"]="setField";["name"]="vmatrix_methods:setField";["param"]={[1]="row";[2]="column";[3]="value";["column"]="A number from 1 to 4";["row"]="A number from 1 to 4";["value"]="Value to set";};["private"]=false;["realm"]="sh";["summary"]="\
Sets a specific field in the matrix ";};["setForward"]={["class"]="function";["classlib"]="VMatrix";["description"]="\
Sets the forward direction of the matrix. First column";["fname"]="setForward";["name"]="vmatrix_methods:setForward";["param"]={[1]="forward";["forward"]="The forward vector";};["private"]=false;["realm"]="sh";["summary"]="\
Sets the forward direction of the matrix.";};["setIdentity"]={["class"]="function";["classlib"]="VMatrix";["description"]="\
Initializes the matrix as Identity matrix";["fname"]="setIdentity";["name"]="vmatrix_methods:setIdentity";["param"]={};["private"]=false;["realm"]="sh";["summary"]="\
Initializes the matrix as Identity matrix ";};["setRight"]={["class"]="function";["classlib"]="VMatrix";["description"]="\
Sets the right direction of the matrix. Negated second column";["fname"]="setRight";["name"]="vmatrix_methods:setRight";["param"]={[1]="right";["right"]="The right vector";};["private"]=false;["realm"]="sh";["summary"]="\
Sets the right direction of the matrix.";};["setScale"]={["class"]="function";["classlib"]="VMatrix";["description"]="\
Sets the scale";["fname"]="setScale";["name"]="vmatrix_methods:setScale";["param"]={[1]="vec";["vec"]="New scale";};["private"]=false;["realm"]="sh";["summary"]="\
Sets the scale ";};["setTranslation"]={["class"]="function";["classlib"]="VMatrix";["description"]="\
Sets the translation";["fname"]="setTranslation";["name"]="vmatrix_methods:setTranslation";["param"]={[1]="vec";["vec"]="New translation";};["private"]=false;["realm"]="sh";["summary"]="\
Sets the translation ";};["setUp"]={["class"]="function";["classlib"]="VMatrix";["description"]="\
Sets the up direction of the matrix. Third column";["fname"]="setUp";["name"]="vmatrix_methods:setUp";["param"]={[1]="up";["up"]="The up vector";};["private"]=false;["realm"]="sh";["summary"]="\
Sets the up direction of the matrix.";};["toTable"]={["class"]="function";["classlib"]="VMatrix";["description"]="\
Converts the matrix to a 4x4 table";["fname"]="toTable";["name"]="vmatrix_methods:toTable";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The 4x4 table";["summary"]="\
Converts the matrix to a 4x4 table ";};["translate"]={["class"]="function";["classlib"]="VMatrix";["description"]="\
Translate the matrix";["fname"]="translate";["name"]="vmatrix_methods:translate";["param"]={[1]="vec";["vec"]="Vector to translate by";};["private"]=false;["realm"]="sh";["summary"]="\
Translate the matrix ";};["transpose"]={["class"]="function";["classlib"]="VMatrix";["description"]="\
Transposes the matrix";["fname"]="transpose";["name"]="vmatrix_methods:transpose";["param"]={};["private"]=false;["realm"]="sh";["summary"]="\
Transposes the matrix ";};};["name"]="VMatrix";["summary"]="\
VMatrix type ";["typtbl"]="vmatrix_methods";};["Vector"]={["class"]="class";["client"]=true;["description"]="\
Vector type";["fields"]={};["methods"]={[1]="add";[10]="getLength2D";[11]="getLength2DSqr";[12]="getLengthSqr";[13]="getNormalized";[14]="isEqualTol";[15]="isZero";[16]="mul";[17]="normalize";[18]="rotate";[19]="rotateAroundAxis";[2]="cross";[20]="set";[21]="setX";[22]="setY";[23]="setZ";[24]="setZero";[25]="sub";[26]="toScreen";[27]="vdiv";[28]="vmul";[29]="withinAABox";[3]="div";[4]="dot";[5]="getAngle";[6]="getAngleEx";[7]="getDistance";[8]="getDistanceSqr";[9]="getLength";["add"]={["class"]="function";["classlib"]="Vector";["description"]="\
Add vector - Modifies self.";["fname"]="add";["name"]="vec_methods:add";["param"]={[1]="v";["v"]="Vector to add";};["private"]=false;["realm"]="sh";["ret"]="nil";["summary"]="\
Add vector - Modifies self.";};["cross"]={["class"]="function";["classlib"]="Vector";["description"]="\
Calculates the cross product of the 2 vectors, creates a unique perpendicular vector to both input vectors.";["fname"]="cross";["name"]="vec_methods:cross";["param"]={[1]="v";["v"]="Second Vector";};["private"]=false;["realm"]="sh";["ret"]="Vector";["summary"]="\
Calculates the cross product of the 2 vectors, creates a unique perpendicular vector to both input vectors.";};["div"]={["class"]="function";["classlib"]="Vector";["description"]="\
\"Scalar Division\" of the vector. Self-Modifies.";["fname"]="div";["name"]="vec_methods:div";["param"]={[1]="n";["n"]="Scalar to divide by.";};["private"]=false;["realm"]="sh";["ret"]="nil";["summary"]="\
\"Scalar Division\" of the vector.";};["dot"]={["class"]="function";["classlib"]="Vector";["description"]="\
Dot product is the cosine of the angle between both vectors multiplied by their lengths. A.B = ||A||||B||cosA.";["fname"]="dot";["name"]="vec_methods:dot";["param"]={[1]="v";["v"]="Second Vector";};["private"]=false;["realm"]="sh";["ret"]="Number";["summary"]="\
Dot product is the cosine of the angle between both vectors multiplied by their lengths.";};["getAngle"]={["class"]="function";["classlib"]="Vector";["description"]="\
Get the vector's angle.";["fname"]="getAngle";["name"]="vec_methods:getAngle";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Angle";["summary"]="\
Get the vector's angle.";};["getAngleEx"]={["class"]="function";["classlib"]="Vector";["description"]="\
Returns the Angle between two vectors.";["fname"]="getAngleEx";["name"]="vec_methods:getAngleEx";["param"]={[1]="v";["v"]="Second Vector";};["private"]=false;["realm"]="sh";["ret"]="Angle";["summary"]="\
Returns the Angle between two vectors.";};["getDistance"]={["class"]="function";["classlib"]="Vector";["description"]="\
Returns the pythagorean distance between the vector and the other vector.";["fname"]="getDistance";["name"]="vec_methods:getDistance";["param"]={[1]="v";["v"]="Second Vector";};["private"]=false;["realm"]="sh";["ret"]="Number";["summary"]="\
Returns the pythagorean distance between the vector and the other vector.";};["getDistanceSqr"]={["class"]="function";["classlib"]="Vector";["description"]="\
Returns the squared distance of 2 vectors, this is faster Vector:getDistance as calculating the square root is an expensive process.";["fname"]="getDistanceSqr";["name"]="vec_methods:getDistanceSqr";["param"]={[1]="v";["v"]="Second Vector";};["private"]=false;["realm"]="sh";["ret"]="Number";["summary"]="\
Returns the squared distance of 2 vectors, this is faster Vector:getDistance as calculating the square root is an expensive process.";};["getLength"]={["class"]="function";["classlib"]="Vector";["description"]="\
Get the vector's Length.";["fname"]="getLength";["name"]="vec_methods:getLength";["param"]={};["private"]=false;["realm"]="sh";["ret"]="number Length.";["summary"]="\
Get the vector's Length.";};["getLength2D"]={["class"]="function";["classlib"]="Vector";["description"]="\
Returns the length of the vector in two dimensions, without the Z axis.";["fname"]="getLength2D";["name"]="vec_methods:getLength2D";["param"]={};["private"]=false;["realm"]="sh";["ret"]="number length";["summary"]="\
Returns the length of the vector in two dimensions, without the Z axis.";};["getLength2DSqr"]={["class"]="function";["classlib"]="Vector";["description"]="\
Returns the length squared of the vector in two dimensions, without the Z axis. ( Saves computation by skipping the square root )";["fname"]="getLength2DSqr";["name"]="vec_methods:getLength2DSqr";["param"]={};["private"]=false;["realm"]="sh";["ret"]="number length squared.";["summary"]="\
Returns the length squared of the vector in two dimensions, without the Z axis.";};["getLengthSqr"]={["class"]="function";["classlib"]="Vector";["description"]="\
Get the vector's length squared ( Saves computation by skipping the square root ).";["fname"]="getLengthSqr";["name"]="vec_methods:getLengthSqr";["param"]={};["private"]=false;["realm"]="sh";["ret"]="number length squared.";["summary"]="\
Get the vector's length squared ( Saves computation by skipping the square root ).";};["getNormalized"]={["class"]="function";["classlib"]="Vector";["description"]="\
Returns a new vector with the same direction by length of 1.";["fname"]="getNormalized";["name"]="vec_methods:getNormalized";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Vector Normalised";["summary"]="\
Returns a new vector with the same direction by length of 1.";};["isEqualTol"]={["class"]="function";["classlib"]="Vector";["description"]="\
Is this vector and v equal within tolerance t.";["fname"]="isEqualTol";["name"]="vec_methods:isEqualTol";["param"]={[1]="v";[2]="t";["t"]="Tolerance number.";["v"]="Second Vector";};["private"]=false;["realm"]="sh";["ret"]="bool True/False.";["summary"]="\
Is this vector and v equal within tolerance t.";};["isZero"]={["class"]="function";["classlib"]="Vector";["description"]="\
Are all fields zero.";["fname"]="isZero";["name"]="vec_methods:isZero";["param"]={};["private"]=false;["realm"]="sh";["ret"]="bool True/False";["summary"]="\
Are all fields zero.";};["mul"]={["class"]="function";["classlib"]="Vector";["description"]="\
Scalar Multiplication of the vector. Self-Modifies.";["fname"]="mul";["name"]="vec_methods:mul";["param"]={[1]="n";["n"]="Scalar to multiply with.";};["private"]=false;["realm"]="sh";["ret"]="nil";["summary"]="\
Scalar Multiplication of the vector.";};["normalize"]={["class"]="function";["classlib"]="Vector";["description"]="\
Normalise the vector, same direction, length 1. Self-Modifies.";["fname"]="normalize";["name"]="vec_methods:normalize";["param"]={};["private"]=false;["realm"]="sh";["ret"]="nil";["summary"]="\
Normalise the vector, same direction, length 1.";};["rotate"]={["class"]="function";["classlib"]="Vector";["description"]="\
Rotate the vector by Angle b. Self-Modifies.";["fname"]="rotate";["name"]="vec_methods:rotate";["param"]={[1]="b";["b"]="Angle to rotate by.";};["private"]=false;["realm"]="sh";["ret"]="nil.";["summary"]="\
Rotate the vector by Angle b.";};["rotateAroundAxis"]={["class"]="function";["classlib"]="Vector";["description"]="\
Return rotated vector by an axis";["fname"]="rotateAroundAxis";["name"]="vec_methods:rotateAroundAxis";["param"]={[1]="axis";[2]="degrees";[3]="radians";["axis"]="Axis the rotate around";["degrees"]="Angle to rotate by in degrees or nil if radians.";["radians"]="Angle to rotate by in radians or nil if degrees.";};["private"]=false;["realm"]="sh";["ret"]="Rotated vector";["summary"]="\
Return rotated vector by an axis ";};["set"]={["class"]="function";["classlib"]="Vector";["description"]="\
Copies the values from the second vector to the first vector. Self-Modifies.";["fname"]="set";["name"]="vec_methods:set";["param"]={[1]="v";["v"]="Second Vector";};["private"]=false;["realm"]="sh";["ret"]="nil";["summary"]="\
Copies the values from the second vector to the first vector.";};["setX"]={["class"]="function";["classlib"]="Vector";["description"]="\
Set's the vector's x coordinate and returns it.";["fname"]="setX";["name"]="vec_methods:setX";["param"]={[1]="x";["x"]="The x coordinate";};["private"]=false;["realm"]="sh";["ret"]="The modified vector";["summary"]="\
Set's the vector's x coordinate and returns it.";};["setY"]={["class"]="function";["classlib"]="Vector";["description"]="\
Set's the vector's y coordinate and returns it.";["fname"]="setY";["name"]="vec_methods:setY";["param"]={[1]="y";["y"]="The y coordinate";};["private"]=false;["realm"]="sh";["ret"]="The modified vector";["summary"]="\
Set's the vector's y coordinate and returns it.";};["setZ"]={["class"]="function";["classlib"]="Vector";["description"]="\
Set's the vector's z coordinate and returns it.";["fname"]="setZ";["name"]="vec_methods:setZ";["param"]={[1]="z";["z"]="The z coordinate";};["private"]=false;["realm"]="sh";["ret"]="The modified vector";["summary"]="\
Set's the vector's z coordinate and returns it.";};["setZero"]={["class"]="function";["classlib"]="Vector";["description"]="\
Set's all vector fields to 0.";["fname"]="setZero";["name"]="vec_methods:setZero";["param"]={};["private"]=false;["realm"]="sh";["ret"]="nil";["summary"]="\
Set's all vector fields to 0.";};["sub"]={["class"]="function";["classlib"]="Vector";["description"]="\
Subtract v from this Vector. Self-Modifies.";["fname"]="sub";["name"]="vec_methods:sub";["param"]={[1]="v";["v"]="Second Vector.";};["private"]=false;["realm"]="sh";["ret"]="nil";["summary"]="\
Subtract v from this Vector.";};["toScreen"]={["class"]="function";["classlib"]="Vector";["description"]="\
Translates the vectors position into 2D user screen coordinates.";["fname"]="toScreen";["name"]="vec_methods:toScreen";["param"]={};["private"]=false;["realm"]="sh";["ret"]="A table {x=screenx,y=screeny,visible=visible}";["summary"]="\
Translates the vectors position into 2D user screen coordinates.";};["vdiv"]={["class"]="function";["classlib"]="Vector";["description"]="\
Divide self by a Vector. Self-Modifies. ( convenience function )";["fname"]="vdiv";["name"]="vec_methods:vdiv";["param"]={[1]="v";["v"]="Vector to divide by";};["private"]=false;["realm"]="sh";["summary"]="\
Divide self by a Vector.";};["vmul"]={["class"]="function";["classlib"]="Vector";["description"]="\
Multiply self with a Vector. Self-Modifies. ( convenience function )";["fname"]="vmul";["name"]="vec_methods:vmul";["param"]={[1]="v";["v"]="Vector to multiply with";};["private"]=false;["realm"]="sh";["summary"]="\
Multiply self with a Vector.";};["withinAABox"]={["class"]="function";["classlib"]="Vector";["description"]="\
Returns whenever the given vector is in a box created by the 2 other vectors.";["fname"]="withinAABox";["name"]="vec_methods:withinAABox";["param"]={[1]="v1";[2]="v2";["v1"]="Vector used to define AABox";["v2"]="Second Vector to define AABox";};["private"]=false;["realm"]="sh";["ret"]="bool True/False.";["summary"]="\
Returns whenever the given vector is in a box created by the 2 other vectors.";};};["name"]="Vector";["server"]=true;["summary"]="\
Vector type ";["typtbl"]="vec_methods";};["Vehicle"]={["class"]="class";["description"]="\
Vehicle type";["fields"]={};["methods"]={[1]="ejectDriver";[2]="getDriver";[3]="getPassenger";["ejectDriver"]={["class"]="function";["classlib"]="Vehicle";["description"]="\
Ejects the driver of the vehicle";["fname"]="ejectDriver";["name"]="vehicle_methods:ejectDriver";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Ejects the driver of the vehicle ";};["getDriver"]={["class"]="function";["classlib"]="Vehicle";["description"]="\
Returns the driver of the vehicle";["fname"]="getDriver";["name"]="vehicle_methods:getDriver";["param"]={};["private"]=false;["realm"]="sv";["ret"]="Driver of vehicle";["server"]=true;["summary"]="\
Returns the driver of the vehicle ";};["getPassenger"]={["class"]="function";["classlib"]="Vehicle";["description"]="\
Returns a passenger of a vehicle";["fname"]="getPassenger";["name"]="vehicle_methods:getPassenger";["param"]={[1]="n";["n"]="The index of the passenger to get";};["private"]=false;["realm"]="sv";["ret"]="amount of ammo";["server"]=true;["summary"]="\
Returns a passenger of a vehicle ";};};["name"]="Vehicle";["summary"]="\
Vehicle type ";["typtbl"]="vehicle_methods";};["Weapon"]={["class"]="class";["description"]="\
Weapon type";["fields"]={};["methods"]={[1]="clip1";[10]="isCarriedByLocalPlayer";[11]="isWeaponVisible";[12]="lastShootTime";[2]="clip2";[3]="getActivity";[4]="getHoldType";[5]="getNextPrimaryFire";[6]="getNextSecondaryFire";[7]="getPrimaryAmmoType";[8]="getPrintName";[9]="getSecondaryAmmoType";["clip1"]={["class"]="function";["classlib"]="Weapon";["client"]=true;["description"]="\
Returns Ammo in primary clip";["fname"]="clip1";["name"]="weapon_methods:clip1";["param"]={};["private"]=false;["realm"]="sh";["ret"]="amount of ammo";["server"]=true;["summary"]="\
Returns Ammo in primary clip ";};["clip2"]={["class"]="function";["classlib"]="Weapon";["client"]=true;["description"]="\
Returns Ammo in secondary clip";["fname"]="clip2";["name"]="weapon_methods:clip2";["param"]={};["private"]=false;["realm"]="sh";["ret"]="amount of ammo";["server"]=true;["summary"]="\
Returns Ammo in secondary clip ";};["getActivity"]={["class"]="function";["classlib"]="Weapon";["client"]=true;["description"]="\
Returns the sequence enumeration number that the weapon is playing. Must be used on a view model.";["fname"]="getActivity";["name"]="weapon_methods:getActivity";["param"]={};["private"]=false;["realm"]="sh";["ret"]="number Current activity";["server"]=true;["summary"]="\
Returns the sequence enumeration number that the weapon is playing.";};["getHoldType"]={["class"]="function";["classlib"]="Weapon";["client"]=true;["description"]="\
Returns the hold type of the weapon.";["fname"]="getHoldType";["name"]="weapon_methods:getHoldType";["param"]={};["private"]=false;["realm"]="sh";["ret"]="string Holdtype";["server"]=true;["summary"]="\
Returns the hold type of the weapon.";};["getNextPrimaryFire"]={["class"]="function";["classlib"]="Weapon";["client"]=true;["description"]="\
Gets the next time the weapon can primary fire.";["fname"]="getNextPrimaryFire";["name"]="weapon_methods:getNextPrimaryFire";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The time, relative to CurTime";["server"]=true;["summary"]="\
Gets the next time the weapon can primary fire.";};["getNextSecondaryFire"]={["class"]="function";["classlib"]="Weapon";["client"]=true;["description"]="\
Gets the next time the weapon can secondary fire.";["fname"]="getNextSecondaryFire";["name"]="weapon_methods:getNextSecondaryFire";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The time, relative to CurTime";["server"]=true;["summary"]="\
Gets the next time the weapon can secondary fire.";};["getPrimaryAmmoType"]={["class"]="function";["classlib"]="Weapon";["client"]=true;["description"]="\
Gets the primary ammo type of the given weapon.";["fname"]="getPrimaryAmmoType";["name"]="weapon_methods:getPrimaryAmmoType";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Ammo number type";["server"]=true;["summary"]="\
Gets the primary ammo type of the given weapon.";};["getPrintName"]={["class"]="function";["classlib"]="Weapon";["client"]=true;["description"]="\
Gets Display name of weapon";["fname"]="getPrintName";["name"]="weapon_methods:getPrintName";["param"]={};["private"]=false;["realm"]="cl";["ret"]="string Display name of weapon";["summary"]="\
Gets Display name of weapon ";};["getSecondaryAmmoType"]={["class"]="function";["classlib"]="Weapon";["client"]=true;["description"]="\
Gets the secondary ammo type of the given weapon.";["fname"]="getSecondaryAmmoType";["name"]="weapon_methods:getSecondaryAmmoType";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Ammo number type";["server"]=true;["summary"]="\
Gets the secondary ammo type of the given weapon.";};["isCarriedByLocalPlayer"]={["class"]="function";["classlib"]="Weapon";["client"]=true;["description"]="\
Returns if the weapon is carried by the local player.";["fname"]="isCarriedByLocalPlayer";["name"]="weapon_methods:isCarriedByLocalPlayer";["param"]={};["private"]=false;["realm"]="cl";["ret"]="whether or not the weapon is carried by the local player";["summary"]="\
Returns if the weapon is carried by the local player.";};["isWeaponVisible"]={["class"]="function";["classlib"]="Weapon";["client"]=true;["description"]="\
Returns whether the weapon is visible";["fname"]="isWeaponVisible";["name"]="weapon_methods:isWeaponVisible";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Whether the weapon is visble or not";["server"]=true;["summary"]="\
Returns whether the weapon is visible ";};["lastShootTime"]={["class"]="function";["classlib"]="Weapon";["client"]=true;["description"]="\
Returns the time since a weapon was last fired at a float variable";["fname"]="lastShootTime";["name"]="weapon_methods:lastShootTime";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Time the weapon was last shot";["server"]=true;["summary"]="\
Returns the time since a weapon was last fired at a float variable ";};};["name"]="Weapon";["summary"]="\
Weapon type ";["typtbl"]="weapon_methods";};["Wirelink"]={["class"]="class";["description"]="\
Wirelink type";["fields"]={};["methods"]={[1]="entity";[2]="getWiredTo";[3]="getWiredToName";[4]="inputType";[5]="inputs";[6]="isValid";[7]="isWired";[8]="outputType";[9]="outputs";["entity"]={["class"]="function";["classlib"]="Wirelink";["description"]="\
Returns the entity that the wirelink represents";["fname"]="entity";["name"]="wirelink_methods:entity";["param"]={};["private"]=false;["realm"]="sv";["summary"]="\
Returns the entity that the wirelink represents ";};["getWiredTo"]={["class"]="function";["classlib"]="Wirelink";["description"]="\
Returns what an input of the wirelink is wired to.";["fname"]="getWiredTo";["name"]="wirelink_methods:getWiredTo";["param"]={[1]="name";["name"]="Name of the input";};["private"]=false;["realm"]="sv";["ret"]="The entity the wirelink is wired to";["summary"]="\
Returns what an input of the wirelink is wired to.";};["getWiredToName"]={["class"]="function";["classlib"]="Wirelink";["description"]="\
Returns the name of the output an input of the wirelink is wired to.";["fname"]="getWiredToName";["name"]="wirelink_methods:getWiredToName";["param"]={[1]="name";["name"]="Name of the input of the wirelink.";};["private"]=false;["realm"]="sv";["ret"]="String name of the output that the input is wired to.";["summary"]="\
Returns the name of the output an input of the wirelink is wired to.";};["inputType"]={["class"]="function";["classlib"]="Wirelink";["description"]="\
Returns the type of input name, or nil if it doesn't exist";["fname"]="inputType";["name"]="wirelink_methods:inputType";["param"]={[1]="name";};["private"]=false;["realm"]="sv";["summary"]="\
Returns the type of input name, or nil if it doesn't exist ";};["inputs"]={["class"]="function";["classlib"]="Wirelink";["description"]="\
Returns a table of all of the wirelink's inputs";["fname"]="inputs";["name"]="wirelink_methods:inputs";["param"]={};["private"]=false;["realm"]="sv";["summary"]="\
Returns a table of all of the wirelink's inputs ";};["isValid"]={["class"]="function";["classlib"]="Wirelink";["description"]="\
Checks if a wirelink is valid. (ie. doesn't point to an invalid entity)";["fname"]="isValid";["name"]="wirelink_methods:isValid";["param"]={};["private"]=false;["realm"]="sv";["summary"]="\
Checks if a wirelink is valid.";};["isWired"]={["class"]="function";["classlib"]="Wirelink";["description"]="\
Checks if an input is wired.";["fname"]="isWired";["name"]="wirelink_methods:isWired";["param"]={[1]="name";["name"]="Name of the input to check";};["private"]=false;["realm"]="sv";["summary"]="\
Checks if an input is wired.";};["outputType"]={["class"]="function";["classlib"]="Wirelink";["description"]="\
Returns the type of output name, or nil if it doesn't exist";["fname"]="outputType";["name"]="wirelink_methods:outputType";["param"]={[1]="name";};["private"]=false;["realm"]="sv";["summary"]="\
Returns the type of output name, or nil if it doesn't exist ";};["outputs"]={["class"]="function";["classlib"]="Wirelink";["description"]="\
Returns a table of all of the wirelink's outputs";["fname"]="outputs";["name"]="wirelink_methods:outputs";["param"]={};["private"]=false;["realm"]="sv";["summary"]="\
Returns a table of all of the wirelink's outputs ";};};["name"]="Wirelink";["server"]=true;["summary"]="\
Wirelink type ";["typtbl"]="wirelink_methods";};};["directives"]={[1]="client";[2]="include";[3]="includedir";[4]="model";[5]="name";[6]="server";["client"]={["class"]="directive";["classForced"]=true;["description"]="\
Set the processor to only run on the client. Shared is default";["name"]="client";["param"]={};["summary"]="\
Set the processor to only run on the client.";["usage"]="\
--@client \
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
Set the model of the processor entity. \
This does not set the model of the screen entity";["name"]="model";["param"]={[1]="model";["model"]="String of the model";};["summary"]="\
Set the model of the processor entity.";["usage"]="\
--@model models/props_junk/watermelon01.mdl \
-- CODE";};["name"]={["class"]="directive";["classForced"]=true;["description"]="\
Set the name of the script. \
This will become the name of the tab and will show on the overlay of the processor";["name"]="name";["param"]={[1]="name";["name"]="Name of the script";};["summary"]="\
Set the name of the script.";["usage"]="\
--@name Awesome script \
-- CODE";};["server"]={["class"]="directive";["classForced"]=true;["description"]="\
Set the processor to only run on the server. Shared is default";["name"]="server";["param"]={};["summary"]="\
Set the processor to only run on the server.";["usage"]="\
--@server \
-- CODE";};};["hooks"]={[1]="EndEntityDriving";[10]="KeyRelease";[11]="OnEntityCreated";[12]="OnPhysgunFreeze";[13]="OnPhysgunReload";[14]="PhysgunDrop";[15]="PhysgunPickup";[16]="PlayerCanPickupWeapon";[17]="PlayerChat";[18]="PlayerDeath";[19]="PlayerDisconnected";[2]="EntityRemoved";[20]="PlayerEnteredVehicle";[21]="PlayerHurt";[22]="PlayerInitialSpawn";[23]="PlayerLeaveVehicle";[24]="PlayerNoClip";[25]="PlayerSay";[26]="PlayerSpawn";[27]="PlayerSpray";[28]="PlayerSwitchFlashlight";[29]="PlayerSwitchWeapon";[3]="EntityTakeDamage";[30]="PlayerUse";[31]="PropBreak";[32]="Removed";[33]="StartChat";[34]="StartEntityDriving";[35]="calcview";[36]="drawhud";[37]="hudconnected";[38]="huddisconnected";[39]="input";[4]="FinishChat";[40]="inputPressed";[41]="inputReleased";[42]="mousemoved";[43]="net";[44]="permissionrequest";[45]="postdrawhud";[46]="postdrawopaquerenderables";[47]="predrawhud";[48]="predrawopaquerenderables";[49]="readcell";[5]="GravGunOnDropped";[50]="remote";[51]="render";[52]="renderoffscreen";[53]="starfallUsed";[54]="think";[55]="tick";[56]="writecell";[6]="GravGunOnPickedUp";[7]="GravGunPunt";[8]="Initialize";[9]="KeyPress";["EndEntityDriving"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Called when a player stops driving an entity";["name"]="EndEntityDriving";["param"]={[1]="ent";[2]="ply";["ent"]="Entity that had been driven";["ply"]="Player that drove the entity";};["realm"]="sh";["server"]=true;["summary"]="\
Called when a player stops driving an entity ";};["EntityRemoved"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Called when an entity is removed";["name"]="EntityRemoved";["param"]={[1]="ent";["ent"]="Entity being removed";};["realm"]="sh";["server"]=true;["summary"]="\
Called when an entity is removed ";};["EntityTakeDamage"]={["class"]="hook";["classForced"]=true;["description"]="\
Called when an entity is damaged";["name"]="EntityTakeDamage";["param"]={[1]="target";[2]="attacker";[3]="inflictor";[4]="amount";[5]="type";[6]="position";[7]="force";["amount"]="How much damage";["attacker"]="Entity that attacked";["force"]="Force of the damage";["inflictor"]="Entity that inflicted the damage";["position"]="Position of the damage";["target"]="Entity that is hurt";["type"]="Type of the damage";};["realm"]="sh";["server"]=true;["summary"]="\
Called when an entity is damaged ";};["FinishChat"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Called when the local player closes their chat window.";["name"]="FinishChat";["param"]={};["realm"]="sh";["summary"]="\
Called when the local player closes their chat window.";};["GravGunOnDropped"]={["class"]="hook";["classForced"]=true;["description"]="\
Called when an entity is being dropped by a gravity gun";["name"]="GravGunOnDropped";["param"]={[1]="ply";[2]="ent";["ent"]="Entity being dropped";["ply"]="Player dropping the object";};["realm"]="sh";["server"]=true;["summary"]="\
Called when an entity is being dropped by a gravity gun ";};["GravGunOnPickedUp"]={["class"]="hook";["classForced"]=true;["description"]="\
Called when an entity is being picked up by a gravity gun";["name"]="GravGunOnPickedUp";["param"]={[1]="ply";[2]="ent";["ent"]="Entity being picked up";["ply"]="Player picking up an object";};["realm"]="sh";["server"]=true;["summary"]="\
Called when an entity is being picked up by a gravity gun ";};["GravGunPunt"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Called when a player punts with the gravity gun";["name"]="GravGunPunt";["param"]={[1]="ply";[2]="ent";["ent"]="Entity being punted";["ply"]="Player punting the gravgun";};["realm"]="sh";["server"]=true;["summary"]="\
Called when a player punts with the gravity gun ";};["Initialize"]={["class"]="hook";["classForced"]=true;["description"]="\
Called after the starfall chip is placed/reloaded with the toolgun or duplicated and the duplication is finished.";["name"]="Initialize";["param"]={};["realm"]="sh";["server"]=true;["summary"]="\
Called after the starfall chip is placed/reloaded with the toolgun or duplicated and the duplication is finished.";};["KeyPress"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Called when a player presses a key";["name"]="KeyPress";["param"]={[1]="ply";[2]="key";["key"]="The key being pressed";["ply"]="Player pressing the key";};["realm"]="sh";["server"]=true;["summary"]="\
Called when a player presses a key ";};["KeyRelease"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Called when a player releases a key";["name"]="KeyRelease";["param"]={[1]="ply";[2]="key";["key"]="The key being released";["ply"]="Player releasing the key";};["realm"]="sh";["server"]=true;["summary"]="\
Called when a player releases a key ";};["OnEntityCreated"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Called when an entity gets created";["name"]="OnEntityCreated";["param"]={[1]="ent";["ent"]="New entity";};["realm"]="sh";["server"]=true;["summary"]="\
Called when an entity gets created ";};["OnPhysgunFreeze"]={["class"]="hook";["classForced"]=true;["description"]="\
Called when an entity is being frozen";["name"]="OnPhysgunFreeze";["param"]={[1]="physgun";[2]="physobj";[3]="ent";[4]="ply";["ent"]="Entity being frozen";["physgun"]="Entity of the physgun";["physobj"]="PhysObj of the entity";["ply"]="Player freezing the entity";};["realm"]="sh";["server"]=true;["summary"]="\
Called when an entity is being frozen ";};["OnPhysgunReload"]={["class"]="hook";["classForced"]=true;["description"]="\
Called when a player reloads his physgun";["name"]="OnPhysgunReload";["param"]={[1]="physgun";[2]="ply";["physgun"]="Entity of the physgun";["ply"]="Player reloading the physgun";};["realm"]="sh";["server"]=true;["summary"]="\
Called when a player reloads his physgun ";};["PhysgunDrop"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Called when an entity being held by a physgun gets dropped";["name"]="PhysgunDrop";["param"]={[1]="ply";[2]="ent";["ent"]="Entity being dropped";["ply"]="Player droppig the entity";};["realm"]="sh";["server"]=true;["summary"]="\
Called when an entity being held by a physgun gets dropped ";};["PhysgunPickup"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Called when an entity gets picked up by a physgun";["name"]="PhysgunPickup";["param"]={[1]="ply";[2]="ent";["ent"]="Entity being picked up";["ply"]="Player picking up the entity";};["realm"]="sh";["server"]=true;["summary"]="\
Called when an entity gets picked up by a physgun ";};["PlayerCanPickupWeapon"]={["class"]="hook";["classForced"]=true;["description"]="\
Called when a wants to pick up a weapon";["name"]="PlayerCanPickupWeapon";["param"]={[1]="ply";[2]="wep";["ply"]="Player";["wep"]="Weapon";};["realm"]="sh";["server"]=true;["summary"]="\
Called when a wants to pick up a weapon ";};["PlayerChat"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Called when a player's chat message is printed to the chat window";["name"]="PlayerChat";["param"]={[1]="ply";[2]="text";[3]="team";[4]="isdead";["isdead"]="Whether the message was send from a dead player";["ply"]="Player that said the message";["team"]="Whether the message was team only";["text"]="The message";};["realm"]="sh";["summary"]="\
Called when a player's chat message is printed to the chat window ";};["PlayerDeath"]={["class"]="hook";["classForced"]=true;["description"]="\
Called when a player dies";["name"]="PlayerDeath";["param"]={[1]="ply";[2]="inflictor";[3]="attacker";["attacker"]="Entity that killed the player";["inflictor"]="Entity used to kill the player";["ply"]="Player who died";};["realm"]="sh";["server"]=true;["summary"]="\
Called when a player dies ";};["PlayerDisconnected"]={["class"]="hook";["classForced"]=true;["description"]="\
Called when a player disconnects";["name"]="PlayerDisconnected";["param"]={[1]="ply";["ply"]="Player that disconnected";};["realm"]="sh";["server"]=true;["summary"]="\
Called when a player disconnects ";};["PlayerEnteredVehicle"]={["class"]="hook";["classForced"]=true;["description"]="\
Called when a players enters a vehicle";["name"]="PlayerEnteredVehicle";["param"]={[1]="ply";[2]="vehicle";[3]="num";["num"]="Role";["ply"]="Player who entered a vehicle";["vehicle"]="Vehicle that was entered";};["realm"]="sh";["server"]=true;["summary"]="\
Called when a players enters a vehicle ";};["PlayerHurt"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Called when a player gets hurt";["name"]="PlayerHurt";["param"]={[1]="ply";[2]="attacker";[3]="newHealth";[4]="damageTaken";["attacker"]="Entity causing damage to the player";["damageTaken"]="Amount of damage the player has taken";["newHealth"]="New health of the player";["ply"]="Player being hurt";};["realm"]="sh";["server"]=true;["summary"]="\
Called when a player gets hurt ";};["PlayerInitialSpawn"]={["class"]="hook";["classForced"]=true;["description"]="\
Called when a player spawns for the first time";["name"]="PlayerInitialSpawn";["param"]={[1]="ply";["ply"]="Player who spawned";};["realm"]="sh";["server"]=true;["summary"]="\
Called when a player spawns for the first time ";};["PlayerLeaveVehicle"]={["class"]="hook";["classForced"]=true;["description"]="\
Called when a players leaves a vehicle";["name"]="PlayerLeaveVehicle";["param"]={[1]="ply";[2]="vehicle";["ply"]="Player who left a vehicle";["vehicle"]="Vehicle that was left";};["realm"]="sh";["server"]=true;["summary"]="\
Called when a players leaves a vehicle ";};["PlayerNoClip"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Called when a player toggles noclip";["name"]="PlayerNoClip";["param"]={[1]="ply";[2]="newState";["newState"]="New noclip state. True if on.";["ply"]="Player toggling noclip";};["realm"]="sh";["server"]=true;["summary"]="\
Called when a player toggles noclip ";};["PlayerSay"]={["class"]="hook";["classForced"]=true;["description"]="\
Called when a player sends a chat message";["name"]="PlayerSay";["param"]={[1]="ply";[2]="text";[3]="teamChat";["ply"]="Player that sent the message";["teamChat"]="True if team chat";["text"]="Content of the message";};["realm"]="sh";["ret"]="New text. \"\" to stop from displaying. Nil to keep original.";["server"]=true;["summary"]="\
Called when a player sends a chat message ";};["PlayerSpawn"]={["class"]="hook";["classForced"]=true;["description"]="\
Called when a player spawns";["name"]="PlayerSpawn";["param"]={[1]="ply";["ply"]="Player who spawned";};["realm"]="sh";["server"]=true;["summary"]="\
Called when a player spawns ";};["PlayerSpray"]={["class"]="hook";["classForced"]=true;["description"]="\
Called when a players sprays his logo";["name"]="PlayerSpray";["param"]={[1]="ply";["ply"]="Player that sprayed";};["realm"]="sh";["server"]=true;["summary"]="\
Called when a players sprays his logo ";};["PlayerSwitchFlashlight"]={["class"]="hook";["classForced"]=true;["description"]="\
Called when a players turns their flashlight on or off";["name"]="PlayerSwitchFlashlight";["param"]={[1]="ply";[2]="state";["ply"]="Player switching flashlight";["state"]="New flashlight state. True if on.";};["realm"]="sh";["server"]=true;["summary"]="\
Called when a players turns their flashlight on or off ";};["PlayerSwitchWeapon"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Called when a player switches their weapon";["name"]="PlayerSwitchWeapon";["param"]={[1]="ply";[2]="oldwep";[3]="newweapon";["newweapon"]="New weapon";["oldwep"]="Old weapon";["ply"]="Player droppig the entity";};["realm"]="sh";["server"]=true;["summary"]="\
Called when a player switches their weapon ";};["PlayerUse"]={["class"]="hook";["classForced"]=true;["description"]="\
Called when a player holds their use key and looks at an entity. \
Will continuously run.";["name"]="PlayerUse";["param"]={[1]="ply";[2]="ent";["ent"]="Entity being used";["ply"]="Player using the entity";};["realm"]="sh";["server"]=true;["summary"]="\
Called when a player holds their use key and looks at an entity.";};["PropBreak"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Called when an entity is broken";["name"]="PropBreak";["param"]={[1]="ply";[2]="ent";["ent"]="Entity broken";["ply"]="Player who broke it";};["realm"]="sh";["server"]=true;["summary"]="\
Called when an entity is broken ";};["Removed"]={["class"]="hook";["classForced"]=true;["description"]="\
Called when the starfall chip is removed";["name"]="Removed";["param"]={};["realm"]="sh";["server"]=true;["summary"]="\
Called when the starfall chip is removed ";};["StartChat"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Called when the local player opens their chat window.";["name"]="StartChat";["param"]={};["realm"]="sh";["summary"]="\
Called when the local player opens their chat window.";};["StartEntityDriving"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Called when a player starts driving an entity";["name"]="StartEntityDriving";["param"]={[1]="ent";[2]="ply";["ent"]="Entity being driven";["ply"]="Player that is driving the entity";};["realm"]="sh";["server"]=true;["summary"]="\
Called when a player starts driving an entity ";};["calcview"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Called when the engine wants to calculate the player's view";["name"]="calcview";["param"]={[1]="pos";[2]="ang";[3]="fov";[4]="znear";[5]="zfar";["ang"]="Current angles of the camera";["fov"]="Current fov of the camera";["pos"]="Current position of the camera";["zfar"]="Current far plane of the camera";["znear"]="Current near plane of the camera";};["realm"]="cl";["ret"]="table Table containing information for the camera. {origin=camera origin, angles=camera angles, fov=camera fov, znear=znear, zfar=zfar, drawviewer=drawviewer}";["summary"]="\
Called when the engine wants to calculate the player's view ";};["drawhud"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Called when a frame is requested to be drawn on hud. (2D Context)";["name"]="drawhud";["param"]={};["realm"]="cl";["summary"]="\
Called when a frame is requested to be drawn on hud.";};["hudconnected"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Called when the player connects to a HUD component linked to the Starfall Chip";["name"]="hudconnected";["param"]={};["realm"]="cl";["summary"]="\
Called when the player connects to a HUD component linked to the Starfall Chip ";};["huddisconnected"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Called when the player disconnects from a HUD component linked to the Starfall Chip";["name"]="huddisconnected";["param"]={};["realm"]="cl";["summary"]="\
Called when the player disconnects from a HUD component linked to the Starfall Chip ";};["input"]={["class"]="hook";["classForced"]=true;["description"]="\
Called when an input on a wired SF chip is written to";["name"]="input";["param"]={[1]="input";[2]="value";["input"]="The input name";["value"]="The value of the input";};["realm"]="sv";["summary"]="\
Called when an input on a wired SF chip is written to ";};["inputPressed"]={["class"]="hook";["classForced"]=true;["description"]="\
Called when a button is pressed";["name"]="inputPressed";["param"]={[1]="button";["button"]="Number of the button";};["realm"]="sh";["summary"]="\
Called when a button is pressed ";};["inputReleased"]={["class"]="hook";["classForced"]=true;["description"]="\
Called when a button is released";["name"]="inputReleased";["param"]={[1]="button";["button"]="Number of the button";};["realm"]="sh";["summary"]="\
Called when a button is released ";};["mousemoved"]={["class"]="hook";["classForced"]=true;["description"]="\
Called when the mouse is moved";["name"]="mousemoved";["param"]={[1]="x";[2]="y";["x"]="X coordinate moved";["y"]="Y coordinate moved";};["realm"]="sh";["summary"]="\
Called when the mouse is moved ";};["net"]={["class"]="hook";["classForced"]=true;["description"]="\
Called when a net message arrives";["name"]="net";["param"]={[1]="name";[2]="len";[3]="ply";["len"]="Length of the arriving net message in bytes";["name"]="Name of the arriving net message";["ply"]="On server, the player that sent the message. Nil on client.";};["realm"]="sh";["summary"]="\
Called when a net message arrives ";};["permissionrequest"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Called when local client changed instance permissions";["name"]="permissionrequest";["param"]={};["realm"]="sh";["summary"]="\
Called when local client changed instance permissions ";};["postdrawhud"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Called after drawing HUD (2D Context)";["name"]="postdrawhud";["param"]={};["realm"]="cl";["summary"]="\
Called after drawing HUD (2D Context) ";};["postdrawopaquerenderables"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Called after opaque entities are drawn. (Only works with HUD) (3D context)";["name"]="postdrawopaquerenderables";["param"]={[1]="boolean";["boolean"]="isDrawSkybox  Whether the current draw is drawing the skybox.";};["realm"]="cl";["summary"]="\
Called after opaque entities are drawn.";};["predrawhud"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Called before drawing HUD (2D Context)";["name"]="predrawhud";["param"]={};["realm"]="cl";["summary"]="\
Called before drawing HUD (2D Context) ";};["predrawopaquerenderables"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Called before opaque entities are drawn. (Only works with HUD) (3D context)";["name"]="predrawopaquerenderables";["param"]={[1]="boolean";["boolean"]="isDrawSkybox  Whether the current draw is drawing the skybox.";};["realm"]="cl";["summary"]="\
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
Called when a player uses the screen";["name"]="starfallUsed";["param"]={[1]="activator";["activator"]="Player using the screen";};["realm"]="cl";["summary"]="\
Called when a player uses the screen ";};["think"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Think hook. Called each frame on the client and each game tick on the server.";["name"]="think";["param"]={};["realm"]="sh";["server"]=true;["summary"]="\
Think hook.";};["tick"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Tick hook. Called each game tick on both the server and client.";["name"]="tick";["param"]={};["realm"]="sh";["server"]=true;["summary"]="\
Tick hook.";};["writecell"]={["class"]="hook";["classForced"]=true;["description"]="\
Called when a high speed device writes to a wired SF chip";["name"]="writecell";["param"]={[1]="address";[2]="data";["address"]="The address written to";["data"]="The data being written";};["realm"]="sv";["summary"]="\
Called when a high speed device writes to a wired SF chip ";};};["libraries"]={[1]="bass";[10]="hook";[11]="http";[12]="input";[13]="joystick";[14]="json";[15]="mesh";[16]="net";[17]="particle";[18]="physenv";[19]="prop";[2]="builtin";[20]="quaternion";[21]="render";[22]="sounds";[23]="team";[24]="timer";[25]="trace";[26]="von";[27]="wire";[3]="constraint";[4]="coroutine";[5]="fastlz";[6]="file";[7]="find";[8]="game";[9]="holograms";["bass"]={["class"]="library";["client"]=true;["description"]="\
`bass` library is intended to be used only on client side. It's good for streaming local and remote sound files and playing them directly in player's \"2D\" context.";["fields"]={};["functions"]={[1]="loadFile";[2]="loadURL";["loadFile"]={["class"]="function";["description"]="\
Loads a sound channel from a file.";["fname"]="loadFile";["library"]="bass";["name"]="bass_library.loadFile";["param"]={[1]="path";[2]="flags";[3]="callback";["callback"]="Function which is called when the sound channel is loaded. It'll get 3 arguments: `Bass` object, error number and name.";["flags"]="Flags for the sound (`3d`, `mono`, `noplay`, `noblock`).";["path"]="File path to play from.";};["private"]=false;["realm"]="cl";["summary"]="\
Loads a sound channel from a file.";};["loadURL"]={["class"]="function";["description"]="\
Loads a sound channel from an URL.";["fname"]="loadURL";["library"]="bass";["name"]="bass_library.loadURL";["param"]={[1]="path";[2]="flags";[3]="callback";["callback"]="Function which is called when the sound channel is loaded. It'll get 3 arguments: `Bass` object, error number and name.";["flags"]="Flags for the sound (`3d`, `mono`, `noplay`, `noblock`).";["path"]="URL path to play from.";};["private"]=false;["realm"]="cl";["summary"]="\
Loads a sound channel from an URL.";};};["libtbl"]="bass_library";["name"]="bass";["summary"]="\
`bass` library is intended to be used only on client side.";["tables"]={};};["builtin"]={["class"]="library";["classForced"]=true;["client"]=true;["description"]="\
Built in values. These don't need to be loaded; they are in the default environment.";["fields"]={[1]="CLIENT";[2]="SERVER";["CLIENT"]={["class"]="field";["classForced"]=true;["description"]="\
Constant that denotes whether the code is executed on the client";["library"]="builtin";["name"]="SF.DefaultEnvironment.CLIENT";["param"]={};["summary"]="\
Constant that denotes whether the code is executed on the client ";};["SERVER"]={["class"]="field";["classForced"]=true;["description"]="\
Constant that denotes whether the code is executed on the server";["library"]="builtin";["name"]="SF.DefaultEnvironment.SERVER";["param"]={};["summary"]="\
Constant that denotes whether the code is executed on the server ";};};["functions"]={[1]="assert";[10]="eyeAngles";[11]="eyePos";[12]="eyeVector";[13]="getLibraries";[14]="getUserdata";[15]="getfenv";[16]="getmetatable";[17]="hasPermission";[18]="ipairs";[19]="isValid";[2]="chip";[20]="loadstring";[21]="localToWorld";[22]="next";[23]="owner";[24]="pairs";[25]="pcall";[26]="permissionRequestSatisfied";[27]="player";[28]="printMessage";[29]="printTable";[3]="concmd";[30]="quotaAverage";[31]="quotaMax";[32]="quotaTotalAverage";[33]="quotaTotalUsed";[34]="quotaUsed";[35]="rawget";[36]="rawset";[37]="require";[38]="requiredir";[39]="select";[4]="crc";[40]="setClipboardText";[41]="setName";[42]="setSoftQuota";[43]="setUserdata";[44]="setfenv";[45]="setmetatable";[46]="setupPermissionRequest";[47]="throw";[48]="tonumber";[49]="tostring";[5]="debugGetInfo";[50]="try";[51]="type";[52]="unpack";[53]="worldToLocal";[54]="xpcall";[6]="dodir";[7]="dofile";[8]="entity";[9]="error";["assert"]={["class"]="function";["classForced"]=true;["description"]="\
If the result of the first argument is false or nil, an error is thrown with the second argument as the message.";["fname"]="assert";["library"]="builtin";["name"]="SF.DefaultEnvironment.assert";["param"]={[1]="condition";[2]="msg";["condition"]="";["msg"]="";};["private"]=false;["realm"]="sh";["summary"]="\
If the result of the first argument is false or nil, an error is thrown with the second argument as the message.";};["chip"]={["class"]="function";["classForced"]=true;["description"]="\
Returns the entity representing a processor that this script is running on.";["fname"]="chip";["library"]="builtin";["name"]="SF.DefaultEnvironment.chip";["param"]={};["realm"]="sh";["ret"]="Starfall entity";["summary"]="\
Returns the entity representing a processor that this script is running on.";};["concmd"]={["class"]="function";["client"]=true;["description"]="\
Execute a console command";["fname"]="concmd";["library"]="builtin";["name"]="SF.DefaultEnvironment.concmd";["param"]={[1]="cmd";["cmd"]="Command to execute";};["private"]=false;["realm"]="sh";["server"]=true;["summary"]="\
Execute a console command ";};["crc"]={["class"]="function";["classForced"]=true;["description"]="\
Generates the CRC checksum of the specified string. (https://en.wikipedia.org/wiki/Cyclic_redundancy_check)";["fname"]="crc";["library"]="builtin";["name"]="SF.DefaultEnvironment.crc";["param"]={[1]="stringToHash";["stringToHash"]="The string to calculate the checksum of";};["realm"]="sh";["ret"]="The unsigned 32 bit checksum as a string";["summary"]="\
Generates the CRC checksum of the specified string.";};["debugGetInfo"]={["class"]="function";["description"]="\
GLua's getinfo() \
Returns a DebugInfo structure containing the passed function's info (https://wiki.garrysmod.com/page/Structures/DebugInfo)";["fname"]="debugGetInfo";["library"]="builtin";["name"]="SF.DefaultEnvironment.debugGetInfo";["param"]={[1]="funcOrStackLevel";[2]="fields";["fields"]="A string that specifies the information to be retrieved. Defaults to all (flnSu).";["funcOrStackLevel"]="Function or stack level to get info about. Defaults to stack level 0.";};["private"]=false;["realm"]="sh";["ret"]="DebugInfo table";["summary"]="\
GLua's getinfo() \
Returns a DebugInfo structure containing the passed function's info (https://wiki.garrysmod.com/page/Structures/DebugInfo) ";};["dodir"]={["class"]="function";["description"]="\
Runs an included directory, but does not cache the result.";["fname"]="dodir";["library"]="builtin";["name"]="SF.DefaultEnvironment.dodir";["param"]={[1]="dir";[2]="loadpriority";["dir"]="The directory to include. Make sure to --@includedir it";["loadpriority"]="Table of files that should be loaded before any others in the directory";};["private"]=false;["realm"]="sh";["ret"]="Table of return values of the scripts";["summary"]="\
Runs an included directory, but does not cache the result.";};["dofile"]={["class"]="function";["description"]="\
Runs an included script, but does not cache the result. \
Pretty much like standard Lua dofile()";["fname"]="dofile";["library"]="builtin";["name"]="SF.DefaultEnvironment.dofile";["param"]={[1]="file";["file"]="The file to include. Make sure to --@include it";};["private"]=false;["realm"]="sh";["ret"]="Return value of the script";["summary"]="\
Runs an included script, but does not cache the result.";};["entity"]={["class"]="function";["classForced"]=true;["description"]="\
Returns the entity with index 'num'";["fname"]="entity";["library"]="builtin";["name"]="SF.DefaultEnvironment.entity";["param"]={[1]="num";["num"]="Entity index";};["realm"]="sh";["ret"]="entity";["summary"]="\
Returns the entity with index 'num' ";};["error"]={["class"]="function";["description"]="\
Throws a raw exception.";["fname"]="error";["library"]="builtin";["name"]="SF.DefaultEnvironment.error";["param"]={[1]="msg";[2]="level";["level"]="Which level in the stacktrace to blame. Defaults to 1";["msg"]="Exception message";};["private"]=false;["realm"]="sh";["summary"]="\
Throws a raw exception.";};["eyeAngles"]={["class"]="function";["description"]="\
Returns the local player's camera angles";["fname"]="eyeAngles";["library"]="builtin";["name"]="SF.DefaultEnvironment.eyeAngles";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The local player's camera angles";["summary"]="\
Returns the local player's camera angles ";};["eyePos"]={["class"]="function";["description"]="\
Returns the local player's camera position";["fname"]="eyePos";["library"]="builtin";["name"]="SF.DefaultEnvironment.eyePos";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The local player's camera position";["summary"]="\
Returns the local player's camera position ";};["eyeVector"]={["class"]="function";["description"]="\
Returns the local player's camera forward vector";["fname"]="eyeVector";["library"]="builtin";["name"]="SF.DefaultEnvironment.eyeVector";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The local player's camera forward vector";["summary"]="\
Returns the local player's camera forward vector ";};["getLibraries"]={["class"]="function";["description"]="\
Gets a list of all libraries";["fname"]="getLibraries";["library"]="builtin";["name"]="SF.DefaultEnvironment.getLibraries";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Table containing the names of each available library";["summary"]="\
Gets a list of all libraries ";};["getUserdata"]={["class"]="function";["description"]="\
Gets the chip's userdata that the duplicator tool loads";["fname"]="getUserdata";["library"]="builtin";["name"]="SF.DefaultEnvironment.getUserdata";["param"]={};["private"]=false;["realm"]="sv";["ret"]="String data";["server"]=true;["summary"]="\
Gets the chip's userdata that the duplicator tool loads ";};["getfenv"]={["class"]="function";["description"]="\
Simple version of Lua's getfenv \
Returns the current environment";["fname"]="getfenv";["library"]="builtin";["name"]="SF.DefaultEnvironment.getfenv";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Current environment";["summary"]="\
Simple version of Lua's getfenv \
Returns the current environment ";};["getmetatable"]={["class"]="function";["description"]="\
Returns the metatable of an object. Doesn't work on most internal metatables";["fname"]="getmetatable";["library"]="builtin";["name"]="SF.DefaultEnvironment.getmetatable";["param"]={[1]="tbl";["tbl"]="Table to get metatable of";};["private"]=false;["realm"]="sh";["ret"]="The metatable of tbl";["summary"]="\
Returns the metatable of an object.";};["hasPermission"]={["class"]="function";["description"]="\
Checks if the chip is capable of performing an action.";["fname"]="hasPermission";["library"]="builtin";["name"]="SF.DefaultEnvironment.hasPermission";["param"]={[1]="perm";[2]="obj";["obj"]="Optional object to pass to the permission system.";["perm"]="The permission id to check";};["private"]=false;["realm"]="sh";["summary"]="\
Checks if the chip is capable of performing an action.";};["ipairs"]={["class"]="function";["classForced"]=true;["description"]="\
Returns an iterator function for a for loop, to return ordered key-value pairs from a table.";["fname"]="ipairs";["library"]="builtin";["name"]="SF.DefaultEnvironment.ipairs";["param"]={[1]="tbl";["tbl"]="Table to iterate over";};["realm"]="sh";["ret"]={[1]="Iterator function";[2]="Table tbl";[3]="0 as current index";};["summary"]="\
Returns an iterator function for a for loop, to return ordered key-value pairs from a table.";};["isValid"]={["class"]="function";["description"]="\
Returns if the table has an isValid function and isValid returns true.";["fname"]="isValid";["library"]="builtin";["name"]="SF.DefaultEnvironment.isValid";["param"]={[1]="object";["object"]="Table to check";};["private"]=false;["realm"]="sh";["ret"]="If it is valid";["summary"]="\
Returns if the table has an isValid function and isValid returns true.";};["loadstring"]={["class"]="function";["description"]="\
GLua's loadstring \
Works like loadstring, except that it executes by default in the main environment";["fname"]="loadstring";["library"]="builtin";["name"]="SF.DefaultEnvironment.loadstring";["param"]={[1]="str";[2]="name";["str"]="String to execute";};["private"]=false;["realm"]="sh";["ret"]="Function of str";["summary"]="\
GLua's loadstring \
Works like loadstring, except that it executes by default in the main environment ";};["localToWorld"]={["class"]="function";["description"]="\
Translates the specified position and angle from the specified local coordinate system";["fname"]="localToWorld";["library"]="builtin";["name"]="SF.DefaultEnvironment.localToWorld";["param"]={[1]="localPos";[2]="localAng";[3]="originPos";[4]="originAngle";["localAng"]="The angle that should be converted to a world angle";["localPos"]="The position vector that should be translated to world coordinates";["originAngle"]="The angles of the source coordinate system, as a world angle";["originPos"]="The origin point of the source coordinate system, in world coordinates";};["private"]=false;["realm"]="sh";["ret"]={[1]="worldPos";[2]="worldAngles";};["summary"]="\
Translates the specified position and angle from the specified local coordinate system ";};["next"]={["class"]="function";["classForced"]=true;["description"]="\
Returns the next key and value pair in a table.";["fname"]="next";["library"]="builtin";["name"]="SF.DefaultEnvironment.next";["param"]={[1]="tbl";[2]="k";["k"]="Previous key (can be nil)";["tbl"]="Table to get the next key-value pair of";};["realm"]="sh";["ret"]={[1]="Key or nil";[2]="Value or nil";};["summary"]="\
Returns the next key and value pair in a table.";};["owner"]={["class"]="function";["classForced"]=true;["description"]="\
Returns whoever created the chip";["fname"]="owner";["library"]="builtin";["name"]="SF.DefaultEnvironment.owner";["param"]={};["realm"]="sh";["ret"]="Owner entity";["summary"]="\
Returns whoever created the chip ";};["pairs"]={["class"]="function";["classForced"]=true;["description"]="\
Returns an iterator function for a for loop that will return the values of the specified table in an arbitrary order.";["fname"]="pairs";["library"]="builtin";["name"]="SF.DefaultEnvironment.pairs";["param"]={[1]="tbl";["tbl"]="Table to iterate over";};["realm"]="sh";["ret"]={[1]="Iterator function";[2]="Table tbl";[3]="nil as current index";};["summary"]="\
Returns an iterator function for a for loop that will return the values of the specified table in an arbitrary order.";};["pcall"]={["class"]="function";["description"]="\
Lua's pcall with SF throw implementation \
Calls a function and catches an error that can be thrown while the execution of the call.";["fname"]="pcall";["library"]="builtin";["name"]="SF.DefaultEnvironment.pcall";["param"]={[1]="func";[2]="...";[3]="arguments";["arguments"]="Arguments to call the function with.";["func"]="Function to be executed and of which the errors should be caught of";};["private"]=false;["realm"]="sh";["ret"]={[1]="If the function had no errors occur within it.";[2]="If an error occurred, this will be a string containing the error message. Otherwise, this will be the return values of the function passed in.";};["summary"]="\
Lua's pcall with SF throw implementation \
Calls a function and catches an error that can be thrown while the execution of the call.";};["permissionRequestSatisfied"]={["class"]="function";["client"]=true;["description"]="\
Is permission request fully satisfied.";["fname"]="permissionRequestSatisfied";["library"]="builtin";["name"]="SF.DefaultEnvironment.permissionRequestSatisfied";["param"]={};["private"]=false;["realm"]="cl";["ret"]="Boolean of whether the client gave all permissions specified in last request or not.";["summary"]="\
Is permission request fully satisfied.";};["player"]={["class"]="function";["classForced"]=true;["description"]="\
Same as owner() on the server. On the client, returns the local player";["fname"]="player";["library"]="builtin";["name"]="SF.DefaultEnvironment.player";["param"]={};["realm"]="sh";["ret"]="Returns player with given UserID or if none specified then returns either the owner (server) or the local player (client)";["summary"]="\
Same as owner() on the server.";};["printMessage"]={["class"]="function";["description"]="\
Prints a message to your chat, console, or the center of your screen.";["fname"]="printMessage";["library"]="builtin";["name"]="SF.DefaultEnvironment.printMessage";["param"]={[1]="mtype";[2]="text";["mtype"]="How the message should be displayed. See http://wiki.garrysmod.com/page/Enums/HUD";["text"]="The message text.";};["private"]=false;["realm"]="sh";["summary"]="\
Prints a message to your chat, console, or the center of your screen.";};["printTable"]={["class"]="function";["description"]="\
Prints a table to player's chat";["fname"]="printTable";["library"]="builtin";["name"]="SF.DefaultEnvironment.printTable";["param"]={[1]="tbl";["tbl"]="Table to print";};["private"]=false;["realm"]="sh";["summary"]="\
Prints a table to player's chat ";};["quotaAverage"]={["class"]="function";["description"]="\
Gets the Average CPU Time in the buffer";["fname"]="quotaAverage";["library"]="builtin";["name"]="SF.DefaultEnvironment.quotaAverage";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Average CPU Time of the buffer.";["summary"]="\
Gets the Average CPU Time in the buffer ";};["quotaMax"]={["class"]="function";["description"]="\
Gets the CPU Time max. \
CPU Time is stored in a buffer of N elements, if the average of this exceeds quotaMax, the chip will error.";["fname"]="quotaMax";["library"]="builtin";["name"]="SF.DefaultEnvironment.quotaMax";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Max SysTime allowed to take for execution of the chip in a Think.";["summary"]="\
Gets the CPU Time max.";};["quotaTotalAverage"]={["class"]="function";["description"]="\
Returns the total average time for all chips by the player.";["fname"]="quotaTotalAverage";["library"]="builtin";["name"]="SF.DefaultEnvironment.quotaTotalAverage";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Total average CPU Time of all your chips.";["summary"]="\
Returns the total average time for all chips by the player.";};["quotaTotalUsed"]={["class"]="function";["description"]="\
Returns the total used time for all chips by the player.";["fname"]="quotaTotalUsed";["library"]="builtin";["name"]="SF.DefaultEnvironment.quotaTotalUsed";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Total used CPU time of all your chips.";["summary"]="\
Returns the total used time for all chips by the player.";};["quotaUsed"]={["class"]="function";["description"]="\
Returns the current count for this Think's CPU Time. \
This value increases as more executions are done, may not be exactly as you want. \
If used on screens, will show 0 if only rendering is done. Operations must be done in the Think loop for them to be counted.";["fname"]="quotaUsed";["library"]="builtin";["name"]="SF.DefaultEnvironment.quotaUsed";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Current quota used this Think";["summary"]="\
Returns the current count for this Think's CPU Time.";};["rawget"]={["class"]="function";["description"]="\
Gets the value of a table index without invoking a metamethod";["fname"]="rawget";["library"]="builtin";["name"]="SF.DefaultEnvironment.rawget";["param"]={[1]="table";[2]="key";[3]="value";["key"]="The index of the table";["table"]="The table to get the value from";};["private"]=false;["realm"]="sh";["ret"]="The value of the index";["summary"]="\
Gets the value of a table index without invoking a metamethod ";};["rawset"]={["class"]="function";["description"]="\
Set the value of a table index without invoking a metamethod";["fname"]="rawset";["library"]="builtin";["name"]="SF.DefaultEnvironment.rawset";["param"]={[1]="table";[2]="key";[3]="value";["key"]="The index of the table";["table"]="The table to modify";["value"]="The value to set the index equal to";};["private"]=false;["realm"]="sh";["summary"]="\
Set the value of a table index without invoking a metamethod ";};["require"]={["class"]="function";["description"]="\
Runs an included script and caches the result. \
Works pretty much like standard Lua require()";["fname"]="require";["library"]="builtin";["name"]="SF.DefaultEnvironment.require";["param"]={[1]="file";["file"]="The file to include. Make sure to --@include it";};["private"]=false;["realm"]="sh";["ret"]="Return value of the script";["summary"]="\
Runs an included script and caches the result.";};["requiredir"]={["class"]="function";["description"]="\
Runs an included script and caches the result. \
Works pretty much like standard Lua require()";["fname"]="requiredir";["library"]="builtin";["name"]="SF.DefaultEnvironment.requiredir";["param"]={[1]="dir";[2]="loadpriority";["dir"]="The directory to include. Make sure to --@includedir it";["loadpriority"]="Table of files that should be loaded before any others in the directory";};["private"]=false;["realm"]="sh";["ret"]="Table of return values of the scripts";["summary"]="\
Runs an included script and caches the result.";};["select"]={["class"]="function";["classForced"]=true;["description"]="\
Used to select single values from a vararg or get the count of values in it.";["fname"]="select";["library"]="builtin";["name"]="SF.DefaultEnvironment.select";["param"]={[1]="parameter";[2]="vararg";["parameter"]="";["vararg"]="";};["realm"]="sh";["ret"]="Returns a number or vararg, depending on the select method.";["summary"]="\
Used to select single values from a vararg or get the count of values in it.";};["setClipboardText"]={["class"]="function";["description"]="\
Sets clipboard text. Only works on the owner of the chip.";["fname"]="setClipboardText";["library"]="builtin";["name"]="SF.DefaultEnvironment.setClipboardText";["param"]={[1]="txt";["txt"]="Text to set to the clipboard";};["private"]=false;["realm"]="sh";["summary"]="\
Sets clipboard text.";};["setName"]={["class"]="function";["client"]=true;["description"]="\
Sets the chip's display name";["fname"]="setName";["library"]="builtin";["name"]="SF.DefaultEnvironment.setName";["param"]={[1]="name";["name"]="Name";};["private"]=false;["realm"]="cl";["summary"]="\
Sets the chip's display name ";};["setSoftQuota"]={["class"]="function";["description"]="\
Sets a CPU soft quota which will trigger a catchable error if the cpu goes over a certain amount.";["fname"]="setSoftQuota";["library"]="builtin";["name"]="SF.DefaultEnvironment.setSoftQuota";["param"]={[1]="quota";["quota"]="The threshold where the soft error will be thrown. Ratio of current cpu to the max cpu usage. 0.5 is 50%";};["private"]=false;["realm"]="sh";["summary"]="\
Sets a CPU soft quota which will trigger a catchable error if the cpu goes over a certain amount.";};["setUserdata"]={["class"]="function";["description"]="\
Sets the chip's userdata that the duplicator tool saves. max 1MiB";["fname"]="setUserdata";["library"]="builtin";["name"]="SF.DefaultEnvironment.setUserdata";["param"]={[1]="str";["str"]="String data";};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Sets the chip's userdata that the duplicator tool saves.";};["setfenv"]={["class"]="function";["description"]="\
Lua's setfenv \
Works like setfenv, but is restricted on functions";["fname"]="setfenv";["library"]="builtin";["name"]="SF.DefaultEnvironment.setfenv";["param"]={[1]="func";[2]="tbl";["func"]="Function to change environment of";["tbl"]="New environment";};["private"]=false;["realm"]="sh";["ret"]="func with environment set to tbl";["summary"]="\
Lua's setfenv \
Works like setfenv, but is restricted on functions ";};["setmetatable"]={["class"]="function";["classForced"]=true;["description"]="\
Sets, changes or removes a table's metatable. Doesn't work on most internal metatables";["fname"]="setmetatable";["library"]="builtin";["name"]="SF.DefaultEnvironment.setmetatable";["param"]={[1]="tbl";[2]="meta";["meta"]="The metatable to use";["tbl"]="The table to set the metatable of";};["realm"]="sh";["ret"]="tbl with metatable set to meta";["summary"]="\
Sets, changes or removes a table's metatable.";};["setupPermissionRequest"]={["class"]="function";["client"]=true;["description"]="\
Setups request for overriding permissions.";["fname"]="setupPermissionRequest";["library"]="builtin";["name"]="SF.DefaultEnvironment.setupPermissionRequest";["param"]={[1]="perms";[2]="desc";[3]="showOnUse";["desc"]="Description attached to request.";["perms"]="Table of overridable permissions' names.";["showOnUse"]="Whether request will popup when player uses chip or linked screen.";};["private"]=false;["realm"]="cl";["summary"]="\
Setups request for overriding permissions.";};["throw"]={["class"]="function";["description"]="\
Throws an exception";["fname"]="throw";["library"]="builtin";["name"]="SF.DefaultEnvironment.throw";["param"]={[1]="msg";[2]="level";[3]="uncatchable";["level"]="Which level in the stacktrace to blame. Defaults to 1";["msg"]="Message string";["uncatchable"]="Makes this exception uncatchable";};["private"]=false;["realm"]="sh";["summary"]="\
Throws an exception ";};["tonumber"]={["class"]="function";["classForced"]=true;["description"]="\
Attempts to convert the value to a number.";["fname"]="tonumber";["library"]="builtin";["name"]="SF.DefaultEnvironment.tonumber";["param"]={[1]="obj";["obj"]="";};["realm"]="sh";["ret"]="obj as number";["summary"]="\
Attempts to convert the value to a number.";};["tostring"]={["class"]="function";["classForced"]=true;["description"]="\
Attempts to convert the value to a string.";["fname"]="tostring";["library"]="builtin";["name"]="SF.DefaultEnvironment.tostring";["param"]={[1]="obj";["obj"]="";};["realm"]="sh";["ret"]="obj as string";["summary"]="\
Attempts to convert the value to a string.";};["try"]={["class"]="function";["description"]="\
Try to execute a function and catch possible exceptions \
Similar to xpcall, but a bit more in-depth";["fname"]="try";["library"]="builtin";["name"]="SF.DefaultEnvironment.try";["param"]={[1]="func";[2]="catch";["catch"]="Optional function to execute in case func fails";["func"]="Function to execute";};["private"]=false;["realm"]="sh";["summary"]="\
Try to execute a function and catch possible exceptions \
Similar to xpcall, but a bit more in-depth ";};["type"]={["class"]="function";["classForced"]=true;["description"]="\
Returns a string representing the name of the type of the passed object.";["fname"]="type";["library"]="builtin";["name"]="SF.DefaultEnvironment.type";["param"]={[1]="obj";["obj"]="Object to get type of";};["private"]=false;["realm"]="sh";["ret"]="The name of the object's type.";["summary"]="\
Returns a string representing the name of the type of the passed object.";};["unpack"]={["class"]="function";["classForced"]=true;["description"]="\
This function takes a numeric indexed table and return all the members as a vararg.";["fname"]="unpack";["library"]="builtin";["name"]="SF.DefaultEnvironment.unpack";["param"]={[1]="tbl";["tbl"]="";};["realm"]="sh";["ret"]="Elements of tbl";["summary"]="\
This function takes a numeric indexed table and return all the members as a vararg.";};["worldToLocal"]={["class"]="function";["description"]="\
Translates the specified position and angle into the specified coordinate system";["fname"]="worldToLocal";["library"]="builtin";["name"]="SF.DefaultEnvironment.worldToLocal";["param"]={[1]="pos";[2]="ang";[3]="newSystemOrigin";[4]="newSystemAngles";["ang"]="The angles that should be translated from the current to the new system";["newSystemAngles"]="The angles of the system to translate to";["newSystemOrigin"]="The origin of the system to translate to";["pos"]="The position that should be translated from the current to the new system";};["private"]=false;["realm"]="sh";["ret"]={[1]="localPos";[2]="localAngles";};["summary"]="\
Translates the specified position and angle into the specified coordinate system ";};["xpcall"]={["class"]="function";["description"]="\
Lua's xpcall with SF throw implementation \
Attempts to call the first function. If the execution succeeds, this returns true followed by the returns of the function. \
If execution fails, this returns false and the second function is called with the error message.";["fname"]="xpcall";["library"]="builtin";["name"]="SF.DefaultEnvironment.xpcall";["param"]={[1]="func";[2]="callback";[3]="...";[4]="funcThe";[5]="The";[6]="arguments";["The"]="function to be called if execution of the first fails; the error message is passed as a string.";["arguments"]="Arguments to pass to the initial function.";["funcThe"]="function to call initially.";};["private"]=false;["realm"]="sh";["ret"]={[1]="Status of the execution; true for success, false for failure.";[2]="The returns of the first function if execution succeeded, otherwise the first return value of the error callback.";};["summary"]="\
Lua's xpcall with SF throw implementation \
Attempts to call the first function.";};};["libtbl"]="SF.DefaultEnvironment";["name"]="builtin";["server"]=true;["summary"]="\
Built in values.";["tables"]={[1]="bit";[2]="math";[3]="os";[4]="string";[5]="table";["bit"]={["class"]="table";["classForced"]=true;["description"]="\
Bit library. http://wiki.garrysmod.com/page/Category:bit";["library"]="builtin";["name"]="SF.DefaultEnvironment.bit";["param"]={};["summary"]="\
Bit library.";["tname"]="bit";};["math"]={["class"]="table";["classForced"]=true;["description"]="\
The math library. http://wiki.garrysmod.com/page/Category:math";["library"]="builtin";["name"]="SF.DefaultEnvironment.math";["param"]={};["summary"]="\
The math library.";["tname"]="math";};["os"]={["class"]="table";["classForced"]=true;["description"]="\
The os library. http://wiki.garrysmod.com/page/Category:os";["library"]="builtin";["name"]="SF.DefaultEnvironment.os";["param"]={};["summary"]="\
The os library.";["tname"]="os";};["string"]={["class"]="table";["classForced"]=true;["description"]="\
String library http://wiki.garrysmod.com/page/Category:string";["library"]="builtin";["name"]="SF.DefaultEnvironment.string";["param"]={};["summary"]="\
String library http://wiki.garrysmod.com/page/Category:string ";["tname"]="string";};["table"]={["class"]="table";["classForced"]=true;["description"]="\
Table library. http://wiki.garrysmod.com/page/Category:table";["library"]="builtin";["name"]="SF.DefaultEnvironment.table";["param"]={};["summary"]="\
Table library.";["tname"]="table";};};};["constraint"]={["class"]="library";["description"]="\
Library for creating and manipulating constraints.";["fields"]={};["functions"]={[1]="axis";[10]="setElasticLength";[11]="setRopeLength";[12]="slider";[13]="weld";[2]="ballsocket";[3]="ballsocketadv";[4]="breakAll";[5]="breakType";[6]="elastic";[7]="getTable";[8]="nocollide";[9]="rope";["axis"]={["class"]="function";["description"]="\
Axis two entities";["fname"]="axis";["library"]="constraint";["name"]="constraint_library.axis";["param"]={[1]="e1";[10]="nocollide";[11]="laxis";[2]="e2";[3]="bone1";[4]="bone2";[5]="v1";[6]="v2";[7]="force_lim";[8]="torque_lim";[9]="friction";};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Axis two entities ";};["ballsocket"]={["class"]="function";["description"]="\
Ballsocket two entities";["fname"]="ballsocket";["library"]="constraint";["name"]="constraint_library.ballsocket";["param"]={[1]="e1";[2]="e2";[3]="bone1";[4]="bone2";[5]="v1";[6]="force_lim";[7]="torque_lim";[8]="nocollide";};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Ballsocket two entities ";};["ballsocketadv"]={["class"]="function";["description"]="\
Advanced Ballsocket two entities";["fname"]="ballsocketadv";["library"]="constraint";["name"]="constraint_library.ballsocketadv";["param"]={[1]="e1";[10]="maxv";[11]="frictionv";[12]="rotateonly";[13]="nocollide";[2]="e2";[3]="bone1";[4]="bone2";[5]="v1";[6]="v2";[7]="force_lim";[8]="torque_lim";[9]="minv";};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Advanced Ballsocket two entities ";};["breakAll"]={["class"]="function";["description"]="\
Breaks all constraints on an entity";["fname"]="breakAll";["library"]="constraint";["name"]="constraint_library.breakAll";["param"]={[1]="e";};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Breaks all constraints on an entity ";};["breakType"]={["class"]="function";["description"]="\
Breaks all constraints of a certain type on an entity";["fname"]="breakType";["library"]="constraint";["name"]="constraint_library.breakType";["param"]={[1]="e";[2]="typename";};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Breaks all constraints of a certain type on an entity ";};["elastic"]={["class"]="function";["description"]="\
Elastic two entities";["fname"]="elastic";["library"]="constraint";["name"]="constraint_library.elastic";["param"]={[1]="index";[10]="rdamp";[11]="width";[12]="strech";[2]="e1";[3]="e2";[4]="bone1";[5]="bone2";[6]="v1";[7]="v2";[8]="const";[9]="damp";};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Elastic two entities ";};["getTable"]={["class"]="function";["description"]="\
Returns the table of constraints on an entity";["fname"]="getTable";["library"]="constraint";["name"]="constraint_library.getTable";["param"]={[1]="ent";["ent"]="The entity";};["private"]=false;["realm"]="sv";["ret"]="Table of entity constraints";["summary"]="\
Returns the table of constraints on an entity ";};["nocollide"]={["class"]="function";["description"]="\
Nocollides two entities";["fname"]="nocollide";["library"]="constraint";["name"]="constraint_library.nocollide";["param"]={[1]="e1";[2]="e2";[3]="bone1";[4]="bone2";};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Nocollides two entities ";};["rope"]={["class"]="function";["description"]="\
Ropes two entities";["fname"]="rope";["library"]="constraint";["name"]="constraint_library.rope";["param"]={[1]="index";[10]="force_lim";[11]="width";[12]="material";[13]="rigid";[2]="e1";[3]="e2";[4]="bone1";[5]="bone2";[6]="v1";[7]="v2";[8]="length";[9]="addlength";};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Ropes two entities ";};["setElasticLength"]={["class"]="function";["description"]="\
Sets the length of an elastic attached to the entity";["fname"]="setElasticLength";["library"]="constraint";["name"]="constraint_library.setElasticLength";["param"]={[1]="index";[2]="e";[3]="length";};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Sets the length of an elastic attached to the entity ";};["setRopeLength"]={["class"]="function";["description"]="\
Sets the length of a rope attached to the entity";["fname"]="setRopeLength";["library"]="constraint";["name"]="constraint_library.setRopeLength";["param"]={[1]="index";[2]="e";[3]="length";};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Sets the length of a rope attached to the entity ";};["slider"]={["class"]="function";["description"]="\
Sliders two entities";["fname"]="slider";["library"]="constraint";["name"]="constraint_library.slider";["param"]={[1]="e1";[2]="e2";[3]="bone1";[4]="bone2";[5]="v1";[6]="v2";[7]="width";};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Sliders two entities ";};["weld"]={["class"]="function";["description"]="\
Welds two entities";["fname"]="weld";["library"]="constraint";["name"]="constraint_library.weld";["param"]={[1]="e1";[2]="e2";[3]="bone1";[4]="bone2";[5]="force_lim";[6]="nocollide";["bone1"]="Number bone of the first entity";["bone2"]="Number bone of the second entity";["e1"]="The first entity";["e2"]="The second entity";["force_lim"]="Max force the weld can take before breaking";["nocollide"]="Bool whether or not to nocollide the two entities";};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Welds two entities ";};};["libtbl"]="constraint_library";["name"]="constraint";["server"]=true;["summary"]="\
Library for creating and manipulating constraints.";["tables"]={};};["coroutine"]={["class"]="library";["client"]=true;["description"]="\
Coroutine library";["fields"]={};["functions"]={[1]="create";[2]="resume";[3]="running";[4]="status";[5]="wait";[6]="wrap";[7]="yield";["create"]={["class"]="function";["description"]="\
Creates a new coroutine.";["fname"]="create";["library"]="coroutine";["name"]="coroutine_library.create";["param"]={[1]="func";["func"]="Function of the coroutine";};["private"]=false;["realm"]="sh";["ret"]="coroutine";["summary"]="\
Creates a new coroutine.";};["resume"]={["class"]="function";["description"]="\
Resumes a suspended coroutine. Note that, in contrast to Lua's native coroutine.resume function, it will not run in protected mode and can throw an error.";["fname"]="resume";["library"]="coroutine";["name"]="coroutine_library.resume";["param"]={["..."]="optional parameters that will be passed to the coroutine";[1]="thread";[2]="...";["thread"]="coroutine to resume";};["private"]=false;["realm"]="sh";["ret"]="Any values the coroutine is returning to the main thread";["summary"]="\
Resumes a suspended coroutine.";};["running"]={["class"]="function";["description"]="\
Returns the coroutine that is currently running.";["fname"]="running";["library"]="coroutine";["name"]="coroutine_library.running";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Currently running coroutine";["summary"]="\
Returns the coroutine that is currently running.";};["status"]={["class"]="function";["description"]="\
Returns the status of the coroutine.";["fname"]="status";["library"]="coroutine";["name"]="coroutine_library.status";["param"]={[1]="thread";["thread"]="The coroutine";};["private"]=false;["realm"]="sh";["ret"]="Either \"suspended\", \"running\", \"normal\" or \"dead\"";["summary"]="\
Returns the status of the coroutine.";};["wait"]={["class"]="function";["description"]="\
Suspends the coroutine for a number of seconds. Note that the coroutine will not resume automatically, but any attempts to resume the coroutine while it is waiting will not resume the coroutine and act as if the coroutine suspended itself immediately.";["fname"]="wait";["library"]="coroutine";["name"]="coroutine_library.wait";["param"]={[1]="time";["time"]="Time in seconds to suspend the coroutine";};["private"]=false;["realm"]="sh";["summary"]="\
Suspends the coroutine for a number of seconds.";};["wrap"]={["class"]="function";["description"]="\
Creates a new coroutine.";["fname"]="wrap";["library"]="coroutine";["name"]="coroutine_library.wrap";["param"]={[1]="func";["func"]="Function of the coroutine";};["private"]=false;["realm"]="sh";["ret"]="A function that, when called, resumes the created coroutine. Any parameters to that function will be passed to the coroutine.";["summary"]="\
Creates a new coroutine.";};["yield"]={["class"]="function";["description"]="\
Suspends the currently running coroutine. May not be called outside a coroutine.";["fname"]="yield";["library"]="coroutine";["name"]="coroutine_library.yield";["param"]={["..."]="optional parameters that will be returned to the main thread";[1]="...";};["private"]=false;["realm"]="sh";["ret"]="Any values passed to the coroutine";["summary"]="\
Suspends the currently running coroutine.";};};["libtbl"]="coroutine_library";["name"]="coroutine";["server"]=true;["summary"]="\
Coroutine library ";["tables"]={};};["fastlz"]={["class"]="library";["client"]=true;["description"]="\
FastLZ library";["fields"]={};["functions"]={[1]="compress";[2]="decompress";["compress"]={["class"]="function";["description"]="\
Compress string using FastLZ";["fname"]="compress";["library"]="fastlz";["name"]="fastlz_library.compress";["param"]={[1]="s";["s"]="String to compress";};["private"]=false;["realm"]="sh";["ret"]="FastLZ compressed string";["summary"]="\
Compress string using FastLZ ";};["decompress"]={["class"]="function";["description"]="\
Decompress using FastLZ";["fname"]="decompress";["library"]="fastlz";["name"]="fastlz_library.decompress";["param"]={[1]="s";["s"]="FastLZ compressed string to decode";};["private"]=false;["realm"]="sh";["ret"]="Decompressed string";["summary"]="\
Decompress using FastLZ ";};};["libtbl"]="fastlz_library";["name"]="fastlz";["server"]=true;["summary"]="\
FastLZ library ";["tables"]={};};["file"]={["class"]="library";["client"]=true;["description"]="\
File functions. Allows modification of files.";["fields"]={};["functions"]={[1]="append";[2]="createDir";[3]="delete";[4]="exists";[5]="find";[6]="open";[7]="read";[8]="write";["append"]={["class"]="function";["description"]="\
Appends a string to the end of a file";["fname"]="append";["library"]="file";["name"]="file_library.append";["param"]={[1]="path";[2]="data";["data"]="String that will be appended to the file.";["path"]="Filepath relative to data/sf_filedata/. Cannot contain '..'";};["private"]=false;["realm"]="cl";["summary"]="\
Appends a string to the end of a file ";};["createDir"]={["class"]="function";["description"]="\
Creates a directory";["fname"]="createDir";["library"]="file";["name"]="file_library.createDir";["param"]={[1]="path";["path"]="Filepath relative to data/sf_filedata/. Cannot contain '..'";};["private"]=false;["realm"]="cl";["summary"]="\
Creates a directory ";};["delete"]={["class"]="function";["description"]="\
Deletes a file";["fname"]="delete";["library"]="file";["name"]="file_library.delete";["param"]={[1]="path";["path"]="Filepath relative to data/sf_filedata/. Cannot contain '..'";};["private"]=false;["realm"]="cl";["ret"]="True if successful, nil if error";["summary"]="\
Deletes a file ";};["exists"]={["class"]="function";["description"]="\
Checks if a file exists";["fname"]="exists";["library"]="file";["name"]="file_library.exists";["param"]={[1]="path";["path"]="Filepath relative to data/sf_filedata/. Cannot contain '..'";};["private"]=false;["realm"]="cl";["ret"]="True if exists, false if not, nil if error";["summary"]="\
Checks if a file exists ";};["find"]={["class"]="function";["description"]="\
Enumerates a directory";["fname"]="find";["library"]="file";["name"]="file_library.find";["param"]={[1]="path";[2]="sorting";["path"]="The folder to enumerate, relative to data/sf_filedata/. Cannot contain '..'";["sorting"]="Optional sorting arguement. Either nameasc, namedesc, dateasc, datedesc";};["private"]=false;["realm"]="cl";["ret"]={[1]="Table of file names";[2]="Table of directory names";};["summary"]="\
Enumerates a directory ";};["open"]={["class"]="function";["description"]="\
Opens and returns a file";["fname"]="open";["library"]="file";["name"]="file_library.open";["param"]={[1]="path";[2]="mode";["mode"]="The file mode to use. See lua manual for explaination";["path"]="Filepath relative to data/sf_filedata/. Cannot contain '..'";};["private"]=false;["realm"]="cl";["ret"]="File object or nil if it failed";["summary"]="\
Opens and returns a file ";};["read"]={["class"]="function";["description"]="\
Reads a file from path";["fname"]="read";["library"]="file";["name"]="file_library.read";["param"]={[1]="path";["path"]="Filepath relative to data/sf_filedata/. Cannot contain '..'";};["private"]=false;["realm"]="cl";["ret"]="Contents, or nil if error";["summary"]="\
Reads a file from path ";};["write"]={["class"]="function";["description"]="\
Writes to a file";["fname"]="write";["library"]="file";["name"]="file_library.write";["param"]={[1]="path";[2]="data";["path"]="Filepath relative to data/sf_filedata/. Cannot contain '..'";};["private"]=false;["realm"]="cl";["ret"]="True if OK, nil if error";["summary"]="\
Writes to a file ";};};["libtbl"]="file_library";["name"]="file";["summary"]="\
File functions.";["tables"]={};};["find"]={["class"]="library";["client"]=true;["description"]="\
Find library. Finds entities in various shapes.";["fields"]={};["functions"]={[1]="all";[2]="allPlayers";[3]="byClass";[4]="byModel";[5]="inBox";[6]="inCone";[7]="inSphere";["all"]={["class"]="function";["description"]="\
Finds all entitites";["fname"]="all";["library"]="find";["name"]="find_library.all";["param"]={[1]="filter";["filter"]="Optional function to filter results";};["private"]=false;["realm"]="sh";["ret"]="An array of found entities";["summary"]="\
Finds all entitites ";};["allPlayers"]={["class"]="function";["description"]="\
Finds all players (including bots)";["fname"]="allPlayers";["library"]="find";["name"]="find_library.allPlayers";["param"]={[1]="filter";["filter"]="Optional function to filter results";};["private"]=false;["realm"]="sh";["ret"]="An array of found entities";["summary"]="\
Finds all players (including bots) ";};["byClass"]={["class"]="function";["description"]="\
Finds entities by class name";["fname"]="byClass";["library"]="find";["name"]="find_library.byClass";["param"]={[1]="class";[2]="filter";["class"]="The class name";["filter"]="Optional function to filter results";};["private"]=false;["realm"]="sh";["ret"]="An array of found entities";["summary"]="\
Finds entities by class name ";};["byModel"]={["class"]="function";["description"]="\
Finds entities by model";["fname"]="byModel";["library"]="find";["name"]="find_library.byModel";["param"]={[1]="model";[2]="filter";["filter"]="Optional function to filter results";["model"]="The model file";};["private"]=false;["realm"]="sh";["ret"]="An array of found entities";["summary"]="\
Finds entities by model ";};["inBox"]={["class"]="function";["description"]="\
Finds entities in a box";["fname"]="inBox";["library"]="find";["name"]="find_library.inBox";["param"]={[1]="min";[2]="max";[3]="filter";["filter"]="Optional function to filter results";["max"]="Top corner";["min"]="Bottom corner";};["private"]=false;["realm"]="sh";["ret"]="An array of found entities";["summary"]="\
Finds entities in a box ";};["inCone"]={["class"]="function";["description"]="\
Finds entities in a cone";["fname"]="inCone";["library"]="find";["name"]="find_library.inCone";["param"]={[1]="pos";[2]="dir";[3]="distance";[4]="radius";[5]="filter";["dir"]="The direction to project the cone";["distance"]="The length to project the cone";["filter"]="Optional function to filter results";["pos"]="The cone vertex position";["radius"]="The angle of the cone";};["private"]=false;["realm"]="sh";["ret"]="An array of found entities";["summary"]="\
Finds entities in a cone ";};["inSphere"]={["class"]="function";["description"]="\
Finds entities in a sphere";["fname"]="inSphere";["library"]="find";["name"]="find_library.inSphere";["param"]={[1]="center";[2]="radius";[3]="filter";["center"]="Center of the sphere";["filter"]="Optional function to filter results";["radius"]="Sphere radius";};["private"]=false;["realm"]="sh";["ret"]="An array of found entities";["summary"]="\
Finds entities in a sphere ";};};["libtbl"]="find_library";["name"]="find";["server"]=true;["summary"]="\
Find library.";["tables"]={};};["game"]={["class"]="library";["client"]=true;["description"]="\
Game functions";["fields"]={};["functions"]={[1]="getGamemode";[2]="getHostname";[3]="getMap";[4]="getMaxPlayers";[5]="isDedicated";[6]="isLan";[7]="isSinglePlayer";["getGamemode"]={["class"]="function";["description"]="\
Returns the gamemode as a String";["fname"]="getGamemode";["library"]="game";["name"]="game_lib.getGamemode";["param"]={};["private"]=false;["realm"]="sh";["summary"]="\
Returns the gamemode as a String ";};["getHostname"]={["class"]="function";["description"]="\
Returns The hostname";["fname"]="getHostname";["library"]="game";["name"]="game_lib.getHostname";["param"]={};["private"]=false;["realm"]="sh";["summary"]="\
Returns The hostname ";};["getMap"]={["class"]="function";["description"]="\
Returns the map name";["fname"]="getMap";["library"]="game";["name"]="game_lib.getMap";["param"]={};["private"]=false;["realm"]="sh";["summary"]="\
Returns the map name ";};["getMaxPlayers"]={["class"]="function";["description"]="\
Returns the maximum player limit";["fname"]="getMaxPlayers";["library"]="game";["name"]="game_lib.getMaxPlayers";["param"]={};["private"]=false;["realm"]="sh";["summary"]="\
Returns the maximum player limit ";};["isDedicated"]={["class"]="function";["description"]="\
Returns whether or not the server is a dedicated server";["fname"]="isDedicated";["library"]="game";["name"]="game_lib.isDedicated";["param"]={};["private"]=false;["realm"]="sh";["summary"]="\
Returns whether or not the server is a dedicated server ";};["isLan"]={["class"]="function";["deprecated"]="Possibly add ConVar retrieval for users in future. Could implement with SF Script.";["description"]="\
Returns true if the server is on a LAN";["fname"]="isLan";["library"]="game";["name"]="game_lib.isLan";["param"]={};["private"]=false;["realm"]="sh";["summary"]="\
Returns true if the server is on a LAN ";};["isSinglePlayer"]={["class"]="function";["description"]="\
Returns whether or not the current game is single player";["fname"]="isSinglePlayer";["library"]="game";["name"]="game_lib.isSinglePlayer";["param"]={};["private"]=false;["realm"]="sh";["summary"]="\
Returns whether or not the current game is single player ";};};["libtbl"]="game_lib";["name"]="game";["server"]=true;["summary"]="\
Game functions ";["tables"]={};};["holograms"]={["class"]="library";["description"]="\
Library for creating and manipulating physics-less models AKA \"Holograms\".";["fields"]={};["functions"]={[1]="canSpawn";[2]="create";[3]="hologramsLeft";["canSpawn"]={["class"]="function";["description"]="\
Checks if a user can spawn anymore holograms.";["fname"]="canSpawn";["library"]="holograms";["name"]="holograms_library.canSpawn";["param"]={};["private"]=false;["realm"]="sv";["ret"]="True if user can spawn holograms, False if not.";["server"]=true;["summary"]="\
Checks if a user can spawn anymore holograms.";};["create"]={["class"]="function";["description"]="\
Creates a hologram.";["fname"]="create";["library"]="holograms";["name"]="holograms_library.create";["param"]={[1]="pos";[2]="ang";[3]="model";[4]="scale";};["private"]=false;["realm"]="sv";["ret"]="The hologram object";["server"]=true;["summary"]="\
Creates a hologram.";};["hologramsLeft"]={["class"]="function";["description"]="\
Checks how many holograms can be spawned";["fname"]="hologramsLeft";["library"]="holograms";["name"]="holograms_library.hologramsLeft";["param"]={};["private"]=false;["realm"]="sv";["ret"]="number of holograms able to be spawned";["server"]=true;["summary"]="\
Checks how many holograms can be spawned ";};};["libtbl"]="holograms_library";["name"]="holograms";["server"]=true;["summary"]="\
Library for creating and manipulating physics-less models AKA \"Holograms\".";["tables"]={};};["hook"]={["class"]="library";["client"]=true;["description"]="\
Deals with hooks";["fields"]={};["functions"]={[1]="add";[2]="remove";[3]="run";[4]="runRemote";["add"]={["class"]="function";["description"]="\
Sets a hook function";["fname"]="add";["library"]="hook";["name"]="hook_library.add";["param"]={[1]="hookname";[2]="name";[3]="func";["func"]="Function to run";["hookname"]="Name of the event";["name"]="Unique identifier";};["private"]=false;["realm"]="sh";["summary"]="\
Sets a hook function ";};["remove"]={["class"]="function";["client"]=true;["description"]="\
Remove a hook";["fname"]="remove";["library"]="hook";["name"]="hook_library.remove";["param"]={[1]="hookname";[2]="name";["hookname"]="The hook name";["name"]="The unique name for this hook";};["private"]=false;["realm"]="sh";["server"]=true;["summary"]="\
Remove a hook ";};["run"]={["class"]="function";["client"]=true;["description"]="\
Run a hook";["fname"]="run";["library"]="hook";["name"]="hook_library.run";["param"]={["..."]="arguments";[1]="hookname";[2]="...";["hookname"]="The hook name";};["private"]=false;["realm"]="sh";["server"]=true;["summary"]="\
Run a hook ";};["runRemote"]={["class"]="function";["client"]=true;["description"]="\
Run a hook remotely. \
This will call the hook \"remote\" on either a specified entity or all instances on the server/client";["fname"]="runRemote";["library"]="hook";["name"]="hook_library.runRemote";["param"]={["..."]="Payload. These parameters will be used to call the hook functions";[1]="recipient";[2]="...";["recipient"]="Starfall entity to call the hook on. Nil to run on every starfall entity";};["private"]=false;["realm"]="sh";["ret"]="tbl A list of the resultset of each called hook";["server"]=true;["summary"]="\
Run a hook remotely.";};};["libtbl"]="hook_library";["name"]="hook";["server"]=true;["summary"]="\
Deals with hooks ";["tables"]={};};["http"]={["class"]="library";["client"]=true;["description"]="\
Http library. Requests content from urls.";["fields"]={};["functions"]={[1]="base64Encode";[2]="canRequest";[3]="get";[4]="post";["base64Encode"]={["class"]="function";["description"]="\
Converts data into base64 format or nil if the string is 0 length";["fname"]="base64Encode";["library"]="http";["name"]="http_library.base64Encode";["param"]={[1]="data";["data"]="The data to convert";};["private"]=false;["realm"]="sh";["ret"]="The converted data";["summary"]="\
Converts data into base64 format or nil if the string is 0 length ";};["canRequest"]={["class"]="function";["description"]="\
Checks if a new http request can be started";["fname"]="canRequest";["library"]="http";["name"]="http_library.canRequest";["param"]={};["private"]=false;["realm"]="sh";["summary"]="\
Checks if a new http request can be started ";};["get"]={["class"]="function";["description"]="\
Runs a new http GET request";["fname"]="get";["library"]="http";["name"]="http_library.get";["param"]={[1]="url";[2]="callbackSuccess";[3]="callbackFail";[4]="headers";["callbackFail"]="the function to be called on request fail, taking the failing reason as an argument";["callbackSuccess"]="the function to be called on request success, taking the arguments body (string), length (number), headers (table) and code (number)";["headers"]="GET headers to be sent";["url"]="http target url";};["private"]=false;["realm"]="sh";["summary"]="\
Runs a new http GET request ";};["post"]={["class"]="function";["description"]="\
Runs a new http POST request";["fname"]="post";["library"]="http";["name"]="http_library.post";["param"]={[1]="url";[2]="params";[3]="callbackSuccess";[4]="callbackFail";[5]="headers";["callbackFail"]="the function to be called on request fail, taking the failing reason as an argument";["callbackSuccess"]="the function to be called on request success, taking the arguments body (string), length (number), headers (table) and code (number)";["headers"]="POST headers to be sent";["params"]="POST parameters to be sent";["url"]="http target url";};["private"]=false;["realm"]="sh";["summary"]="\
Runs a new http POST request ";};};["libtbl"]="http_library";["name"]="http";["server"]=true;["summary"]="\
Http library.";["tables"]={};};["input"]={["class"]="library";["client"]=true;["description"]="\
Input library.";["fields"]={};["functions"]={[1]="enableCursor";[2]="getCursorPos";[3]="getKeyName";[4]="isControlDown";[5]="isKeyDown";[6]="isShiftDown";[7]="lookupBinding";[8]="screenToVector";["enableCursor"]={["class"]="function";["description"]="\
Sets the state of the mouse cursor";["fname"]="enableCursor";["library"]="input";["name"]="input_methods.enableCursor";["param"]={[1]="enabled";["enabled"]="Whether or not the cursor should be enabled";};["private"]=false;["realm"]="sh";["summary"]="\
Sets the state of the mouse cursor ";};["getCursorPos"]={["class"]="function";["description"]="\
Gets the position of the mouse";["fname"]="getCursorPos";["library"]="input";["name"]="input_methods.getCursorPos";["param"]={};["private"]=false;["realm"]="sh";["ret"]={[1]="The x position of the mouse";[2]="The y position of the mouse";};["summary"]="\
Gets the position of the mouse ";};["getKeyName"]={["class"]="function";["description"]="\
Gets the name of a key from the id";["fname"]="getKeyName";["library"]="input";["name"]="input_methods.getKeyName";["param"]={[1]="key";["key"]="The key id, see input";};["private"]=false;["realm"]="sh";["ret"]="The name of the key";["summary"]="\
Gets the name of a key from the id ";};["isControlDown"]={["class"]="function";["description"]="\
Gets whether the control key is down";["fname"]="isControlDown";["library"]="input";["name"]="input_methods.isControlDown";["param"]={};["private"]=false;["realm"]="sh";["ret"]="True if the control key is down";["summary"]="\
Gets whether the control key is down ";};["isKeyDown"]={["class"]="function";["description"]="\
Gets whether a key is down";["fname"]="isKeyDown";["library"]="input";["name"]="input_methods.isKeyDown";["param"]={[1]="key";["key"]="The key id, see input";};["private"]=false;["realm"]="sh";["ret"]="True if the key is down";["summary"]="\
Gets whether a key is down ";};["isShiftDown"]={["class"]="function";["description"]="\
Gets whether the shift key is down";["fname"]="isShiftDown";["library"]="input";["name"]="input_methods.isShiftDown";["param"]={};["private"]=false;["realm"]="sh";["ret"]="True if the shift key is down";["summary"]="\
Gets whether the shift key is down ";};["lookupBinding"]={["class"]="function";["description"]="\
Gets the first key that is bound to the command passed";["fname"]="lookupBinding";["library"]="input";["name"]="input_methods.lookupBinding";["param"]={[1]="binding";["binding"]="The name of the bind";};["private"]=false;["realm"]="sh";["ret"]={[1]="The id of the first key bound";[2]="The name of the first key bound";};["summary"]="\
Gets the first key that is bound to the command passed ";};["screenToVector"]={["class"]="function";["description"]="\
Translates position on player's screen to aim vector";["fname"]="screenToVector";["library"]="input";["name"]="input_methods.screenToVector";["param"]={[1]="x";[2]="y";["x"]="X coordinate on the screen";["y"]="Y coordinate on the screen";};["private"]=false;["realm"]="sh";["ret"]="Aim vector";["summary"]="\
Translates position on player's screen to aim vector ";};};["libtbl"]="input_methods";["name"]="input";["summary"]="\
Input library.";["tables"]={};};["joystick"]={["class"]="library";["client"]=true;["description"]="\
Joystick library.";["fields"]={};["functions"]={[1]="getAxis";[2]="getButton";[3]="getName";[4]="getPov";[5]="numAxes";[6]="numButtons";[7]="numJoysticks";[8]="numPovs";["getAxis"]={["class"]="function";["description"]="\
Gets the axis data value.";["fname"]="getAxis";["library"]="joystick";["name"]="joystick_library.getAxis";["param"]={[1]="enum";[2]="axis";["axis"]="Joystick axis number. Ranges from 0 to 7.";["enum"]="Joystick number. Starts at 0";};["private"]=false;["realm"]="cl";["ret"]="0 - 65535 where 32767 is the middle.";["summary"]="\
Gets the axis data value.";};["getButton"]={["class"]="function";["description"]="\
Returns if the button is pushed or not";["fname"]="getButton";["library"]="joystick";["name"]="joystick_library.getButton";["param"]={[1]="enum";[2]="button";["button"]="Joystick button number. Starts at 0";["enum"]="Joystick number. Starts at 0";};["private"]=false;["realm"]="cl";["ret"]="0 or 1";["summary"]="\
Returns if the button is pushed or not ";};["getName"]={["class"]="function";["description"]="\
Gets the hardware name of the joystick";["fname"]="getName";["library"]="joystick";["name"]="joystick_library.getName";["param"]={[1]="enum";["enum"]="Joystick number. Starts at 0";};["private"]=false;["realm"]="cl";["ret"]="Name of the device";["summary"]="\
Gets the hardware name of the joystick ";};["getPov"]={["class"]="function";["description"]="\
Gets the pov data value.";["fname"]="getPov";["library"]="joystick";["name"]="joystick_library.getPov";["param"]={[1]="enum";[2]="pov";["enum"]="Joystick number. Starts at 0";["pov"]="Joystick pov number. Ranges from 0 to 7.";};["private"]=false;["realm"]="cl";["ret"]="0 - 65535 where 32767 is the middle.";["summary"]="\
Gets the pov data value.";};["numAxes"]={["class"]="function";["description"]="\
Gets the number of detected axes on a joystick";["fname"]="numAxes";["library"]="joystick";["name"]="joystick_library.numAxes";["param"]={[1]="enum";["enum"]="Joystick number. Starts at 0";};["private"]=false;["realm"]="cl";["ret"]="Number of axes";["summary"]="\
Gets the number of detected axes on a joystick ";};["numButtons"]={["class"]="function";["description"]="\
Gets the number of detected buttons on a joystick";["fname"]="numButtons";["library"]="joystick";["name"]="joystick_library.numButtons";["param"]={[1]="enum";["enum"]="Joystick number. Starts at 0";};["private"]=false;["realm"]="cl";["ret"]="Number of buttons";["summary"]="\
Gets the number of detected buttons on a joystick ";};["numJoysticks"]={["class"]="function";["description"]="\
Gets the number of detected joysticks.";["fname"]="numJoysticks";["library"]="joystick";["name"]="joystick_library.numJoysticks";["param"]={};["private"]=false;["realm"]="cl";["ret"]="Number of joysticks";["summary"]="\
Gets the number of detected joysticks.";};["numPovs"]={["class"]="function";["description"]="\
Gets the number of detected povs on a joystick";["fname"]="numPovs";["library"]="joystick";["name"]="joystick_library.numPovs";["param"]={[1]="enum";["enum"]="Joystick number. Starts at 0";};["private"]=false;["realm"]="cl";["ret"]="Number of povs";["summary"]="\
Gets the number of detected povs on a joystick ";};};["libtbl"]="joystick_library";["name"]="joystick";["summary"]="\
Joystick library.";["tables"]={};};["json"]={["class"]="library";["client"]=true;["description"]="\
JSON library";["fields"]={};["functions"]={[1]="decode";[2]="encode";["decode"]={["class"]="function";["description"]="\
Convert JSON string to table";["fname"]="decode";["library"]="json";["name"]="json_library.decode";["param"]={[1]="s";["s"]="String to decode";};["private"]=false;["realm"]="sh";["ret"]="Table representing the JSON object";["summary"]="\
Convert JSON string to table ";};["encode"]={["class"]="function";["description"]="\
Convert table to JSON string";["fname"]="encode";["library"]="json";["name"]="json_library.encode";["param"]={[1]="tbl";["tbl"]="Table to encode";};["private"]=false;["realm"]="sh";["ret"]="JSON encoded string representation of the table";["summary"]="\
Convert table to JSON string ";};};["libtbl"]="json_library";["name"]="json";["server"]=true;["summary"]="\
JSON library ";["tables"]={};};["mesh"]={["class"]="library";["client"]=true;["description"]="\
Mesh library.";["fields"]={};["functions"]={[1]="createFromObj";[2]="createFromTable";[3]="trianglesLeft";["createFromObj"]={["class"]="function";["description"]="\
Creates a mesh from an obj file. Only supports triangular meshes with normals and texture coordinates.";["fname"]="createFromObj";["library"]="mesh";["name"]="mesh_library.createFromObj";["param"]={[1]="obj";["obj"]="The obj file data";};["private"]=false;["realm"]="cl";["ret"]="Mesh object";["summary"]="\
Creates a mesh from an obj file.";};["createFromTable"]={["class"]="function";["description"]="\
Creates a mesh from vertex data.";["fname"]="createFromTable";["library"]="mesh";["name"]="mesh_library.createFromTable";["param"]={[1]="verteces";["verteces"]="Table containing vertex data. http://wiki.garrysmod.com/page/Structures/MeshVertex";};["private"]=false;["realm"]="cl";["ret"]="Mesh object";["summary"]="\
Creates a mesh from vertex data.";};["trianglesLeft"]={["class"]="function";["description"]="\
Returns how many triangles can be created";["fname"]="trianglesLeft";["library"]="mesh";["name"]="mesh_library.trianglesLeft";["param"]={};["private"]=false;["realm"]="cl";["ret"]="Number of triangles that can be created";["summary"]="\
Returns how many triangles can be created ";};};["libtbl"]="mesh_library";["name"]="mesh";["summary"]="\
Mesh library.";["tables"]={};};["net"]={["class"]="library";["description"]="\
Net message library. Used for sending data from the server to the client and back";["fields"]={};["functions"]={[1]="getBytesLeft";[10]="readInt";[11]="readMatrix";[12]="readStream";[13]="readString";[14]="readUInt";[15]="readVector";[16]="receive";[17]="send";[18]="start";[19]="writeAngle";[2]="isStreaming";[20]="writeBit";[21]="writeColor";[22]="writeData";[23]="writeDouble";[24]="writeEntity";[25]="writeFloat";[26]="writeInt";[27]="writeMatrix";[28]="writeStream";[29]="writeString";[3]="readAngle";[30]="writeUInt";[31]="writeVector";[4]="readBit";[5]="readColor";[6]="readData";[7]="readDouble";[8]="readEntity";[9]="readFloat";["getBytesLeft"]={["class"]="function";["description"]="\
Returns available bandwidth in bytes";["fname"]="getBytesLeft";["library"]="net";["name"]="net_library.getBytesLeft";["param"]={};["private"]=false;["realm"]="sh";["ret"]="number of bytes that can be sent";["summary"]="\
Returns available bandwidth in bytes ";};["isStreaming"]={["class"]="function";["description"]="\
Returns whether or not the library is currently reading data from a stream";["fname"]="isStreaming";["library"]="net";["name"]="net_library.isStreaming";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Boolean";["summary"]="\
Returns whether or not the library is currently reading data from a stream ";};["readAngle"]={["class"]="function";["client"]=true;["description"]="\
Reads an angle from the net message";["fname"]="readAngle";["library"]="net";["name"]="net_library.readAngle";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The angle that was read";["server"]=true;["summary"]="\
Reads an angle from the net message ";};["readBit"]={["class"]="function";["client"]=true;["description"]="\
Reads a bit from the net message";["fname"]="readBit";["library"]="net";["name"]="net_library.readBit";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The bit that was read. (0 for false, 1 for true)";["server"]=true;["summary"]="\
Reads a bit from the net message ";};["readColor"]={["class"]="function";["client"]=true;["description"]="\
Reads a color from the net message";["fname"]="readColor";["library"]="net";["name"]="net_library.readColor";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The color that was read";["server"]=true;["summary"]="\
Reads a color from the net message ";};["readData"]={["class"]="function";["client"]=true;["description"]="\
Reads a string from the net message";["fname"]="readData";["library"]="net";["name"]="net_library.readData";["param"]={[1]="n";["n"]="How many characters are in the data";};["private"]=false;["realm"]="sh";["ret"]="The string that was read";["server"]=true;["summary"]="\
Reads a string from the net message ";};["readDouble"]={["class"]="function";["client"]=true;["description"]="\
Reads a double from the net message";["fname"]="readDouble";["library"]="net";["name"]="net_library.readDouble";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The double that was read";["server"]=true;["summary"]="\
Reads a double from the net message ";};["readEntity"]={["class"]="function";["client"]=true;["description"]="\
Reads a entity from the net message";["fname"]="readEntity";["library"]="net";["name"]="net_library.readEntity";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The entity that was read";["server"]=true;["summary"]="\
Reads a entity from the net message ";};["readFloat"]={["class"]="function";["client"]=true;["description"]="\
Reads a float from the net message";["fname"]="readFloat";["library"]="net";["name"]="net_library.readFloat";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The float that was read";["server"]=true;["summary"]="\
Reads a float from the net message ";};["readInt"]={["class"]="function";["client"]=true;["description"]="\
Reads an integer from the net message";["fname"]="readInt";["library"]="net";["name"]="net_library.readInt";["param"]={[1]="n";["n"]="The amount of bits to read";};["private"]=false;["realm"]="sh";["ret"]="The integer that was read";["server"]=true;["summary"]="\
Reads an integer from the net message ";};["readMatrix"]={["class"]="function";["client"]=true;["description"]="\
Reads a matrix from the net message";["fname"]="readMatrix";["library"]="net";["name"]="net_library.readMatrix";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The matrix that was read";["server"]=true;["summary"]="\
Reads a matrix from the net message ";};["readStream"]={["class"]="function";["client"]=true;["description"]="\
Reads a large string stream from the net message";["fname"]="readStream";["library"]="net";["name"]="net_library.readStream";["param"]={[1]="cb";["cb"]="Callback to run when the stream is finished. The first parameter in the callback is the data.";};["private"]=false;["realm"]="sh";["server"]=true;["summary"]="\
Reads a large string stream from the net message ";};["readString"]={["class"]="function";["client"]=true;["description"]="\
Reads a string from the net message";["fname"]="readString";["library"]="net";["name"]="net_library.readString";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The string that was read";["server"]=true;["summary"]="\
Reads a string from the net message ";};["readUInt"]={["class"]="function";["client"]=true;["description"]="\
Reads an unsigned integer from the net message";["fname"]="readUInt";["library"]="net";["name"]="net_library.readUInt";["param"]={[1]="n";["n"]="The amount of bits to read";};["private"]=false;["realm"]="sh";["ret"]="The unsigned integer that was read";["server"]=true;["summary"]="\
Reads an unsigned integer from the net message ";};["readVector"]={["class"]="function";["client"]=true;["description"]="\
Reads a vector from the net message";["fname"]="readVector";["library"]="net";["name"]="net_library.readVector";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The vector that was read";["server"]=true;["summary"]="\
Reads a vector from the net message ";};["receive"]={["class"]="function";["client"]=true;["description"]="\
Like glua net.Receive, adds a callback that is called when a net message with the matching name is received. If this happens, the net hook won't be called.";["fname"]="receive";["library"]="net";["name"]="net_library.receive";["param"]={[1]="name";[2]="func";["func"]="The callback or nil to remove callback. (len - length of the net message, ply - player that sent it or nil if clientside)";["name"]="The name of the net message";};["private"]=false;["realm"]="sh";["server"]=true;["summary"]="\
Like glua net.Receive, adds a callback that is called when a net message with the matching name is received.";};["send"]={["class"]="function";["client"]=true;["description"]="\
Send a net message from client->server, or server->client.";["fname"]="send";["library"]="net";["name"]="net_library.send";["param"]={[1]="target";[2]="unreliable";["target"]="Optional target location to send the net message.";["unreliable"]="Optional choose whether it's more important for the message to actually reach its destination (false) or reach it as fast as possible (true).";};["private"]=false;["realm"]="sh";["server"]=true;["summary"]="\
Send a net message from client->server, or server->client.";};["start"]={["class"]="function";["client"]=true;["description"]="\
Starts the net message";["fname"]="start";["library"]="net";["name"]="net_library.start";["param"]={[1]="name";["name"]="The message name";};["private"]=false;["realm"]="sh";["server"]=true;["summary"]="\
Starts the net message ";};["writeAngle"]={["class"]="function";["client"]=true;["description"]="\
Writes an angle to the net message";["fname"]="writeAngle";["library"]="net";["name"]="net_library.writeAngle";["param"]={[1]="t";["t"]="The angle to be written";};["private"]=false;["realm"]="sh";["server"]=true;["summary"]="\
Writes an angle to the net message ";};["writeBit"]={["class"]="function";["client"]=true;["description"]="\
Writes a bit to the net message";["fname"]="writeBit";["library"]="net";["name"]="net_library.writeBit";["param"]={[1]="t";["t"]="The bit to be written. (boolean)";};["private"]=false;["realm"]="sh";["server"]=true;["summary"]="\
Writes a bit to the net message ";};["writeColor"]={["class"]="function";["client"]=true;["description"]="\
Writes an color to the net message";["fname"]="writeColor";["library"]="net";["name"]="net_library.writeColor";["param"]={[1]="t";["t"]="The color to be written";};["private"]=false;["realm"]="sh";["server"]=true;["summary"]="\
Writes an color to the net message ";};["writeData"]={["class"]="function";["client"]=true;["description"]="\
Writes string containing null characters to the net message";["fname"]="writeData";["library"]="net";["name"]="net_library.writeData";["param"]={[1]="t";[2]="n";["n"]="How much of the string to write";["t"]="The string to be written";};["private"]=false;["realm"]="sh";["server"]=true;["summary"]="\
Writes string containing null characters to the net message ";};["writeDouble"]={["class"]="function";["client"]=true;["description"]="\
Writes a double to the net message";["fname"]="writeDouble";["library"]="net";["name"]="net_library.writeDouble";["param"]={[1]="t";["t"]="The double to be written";};["private"]=false;["realm"]="sh";["server"]=true;["summary"]="\
Writes a double to the net message ";};["writeEntity"]={["class"]="function";["client"]=true;["description"]="\
Writes an entity to the net message";["fname"]="writeEntity";["library"]="net";["name"]="net_library.writeEntity";["param"]={[1]="t";["t"]="The entity to be written";};["private"]=false;["realm"]="sh";["server"]=true;["summary"]="\
Writes an entity to the net message ";};["writeFloat"]={["class"]="function";["client"]=true;["description"]="\
Writes a float to the net message";["fname"]="writeFloat";["library"]="net";["name"]="net_library.writeFloat";["param"]={[1]="t";["t"]="The float to be written";};["private"]=false;["realm"]="sh";["server"]=true;["summary"]="\
Writes a float to the net message ";};["writeInt"]={["class"]="function";["client"]=true;["description"]="\
Writes an integer to the net message";["fname"]="writeInt";["library"]="net";["name"]="net_library.writeInt";["param"]={[1]="t";[2]="n";["n"]="The amount of bits the integer consists of";["t"]="The integer to be written";};["private"]=false;["realm"]="sh";["server"]=true;["summary"]="\
Writes an integer to the net message ";};["writeMatrix"]={["class"]="function";["client"]=true;["description"]="\
Writes an matrix to the net message";["fname"]="writeMatrix";["library"]="net";["name"]="net_library.writeMatrix";["param"]={[1]="t";["t"]="The matrix to be written";};["private"]=false;["realm"]="sh";["server"]=true;["summary"]="\
Writes an matrix to the net message ";};["writeStream"]={["class"]="function";["client"]=true;["description"]="\
Streams a large 20MB string.";["fname"]="writeStream";["library"]="net";["name"]="net_library.writeStream";["param"]={[1]="str";["str"]="The string to be written";};["private"]=false;["realm"]="sh";["server"]=true;["summary"]="\
Streams a large 20MB string.";};["writeString"]={["class"]="function";["client"]=true;["description"]="\
Writes a string to the net message. Null characters will terminate the string.";["fname"]="writeString";["library"]="net";["name"]="net_library.writeString";["param"]={[1]="t";["t"]="The string to be written";};["private"]=false;["realm"]="sh";["server"]=true;["summary"]="\
Writes a string to the net message.";};["writeUInt"]={["class"]="function";["client"]=true;["description"]="\
Writes an unsigned integer to the net message";["fname"]="writeUInt";["library"]="net";["name"]="net_library.writeUInt";["param"]={[1]="t";[2]="n";["n"]="The amount of bits the integer consists of. Should not be greater than 32";["t"]="The integer to be written";};["private"]=false;["realm"]="sh";["server"]=true;["summary"]="\
Writes an unsigned integer to the net message ";};["writeVector"]={["class"]="function";["client"]=true;["description"]="\
Writes an vector to the net message";["fname"]="writeVector";["library"]="net";["name"]="net_library.writeVector";["param"]={[1]="t";["t"]="The vector to be written";};["private"]=false;["realm"]="sh";["server"]=true;["summary"]="\
Writes an vector to the net message ";};};["libtbl"]="net_library";["name"]="net";["summary"]="\
Net message library.";["tables"]={};};["particle"]={["class"]="library";["client"]=true;["description"]="\
Particle library.";["fields"]={};["functions"]={[1]="attach";["attach"]={["class"]="function";["description"]="\
Attaches a particle to an entity.";["fname"]="attach";["library"]="particle";["name"]="particle_library.attach";["param"]={[1]="entity";[2]="particle";[3]="pattach";[4]="options";["entity"]="Entity to attach to";["options"]="Table of options";["particle"]="Name of the particle";["pattach"]="PATTACH enum";};["private"]=false;["realm"]="cl";["ret"]="Particle type.";["summary"]="\
Attaches a particle to an entity.";};};["libtbl"]="particle_library";["name"]="particle";["summary"]="\
Particle library.";["tables"]={};};["physenv"]={["class"]="library";["client"]=true;["description"]="\
Physenv functions";["fields"]={};["functions"]={[1]="getAirDensity";[2]="getGravity";[3]="getPerformanceSettings";["getAirDensity"]={["class"]="function";["description"]="\
Gets the air density.";["fname"]="getAirDensity";["library"]="physenv";["name"]="physenv_lib.getAirDensity";["param"]={};["private"]=false;["realm"]="sh";["ret"]="number Air Density";["summary"]="\
Gets the air density.";};["getGravity"]={["class"]="function";["description"]="\
Gets the gravity vector";["fname"]="getGravity";["library"]="physenv";["name"]="physenv_lib.getGravity";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Vector Gravity Vector ( eg Vector(0,0,-600) )";["summary"]="\
Gets the gravity vector ";};["getPerformanceSettings"]={["class"]="function";["description"]="\
Gets the performance settings.</br> \
See <a href=\"http://wiki.garrysmod.com/page/Structures/PhysEnvPerformanceSettings\">PhysEnvPerformance Settings Table Structure</a> for table structure.";["fname"]="getPerformanceSettings";["library"]="physenv";["name"]="physenv_lib.getPerformanceSettings";["param"]={};["private"]=false;["realm"]="sh";["ret"]="table Performance Settings Table.";["summary"]="\
Gets the performance settings.</br> \
See <a href=\"http://wiki.garrysmod.com/page/Structures/PhysEnvPerformanceSettings\">PhysEnvPerformance Settings Table Structure</a> for table structure.";};};["libtbl"]="physenv_lib";["name"]="physenv";["server"]=true;["summary"]="\
Physenv functions ";["tables"]={};};["prop"]={["class"]="library";["client"]=true;["description"]="\
Library for creating and manipulating physics-less models AKA \"Props\".";["fields"]={};["functions"]={[1]="canSpawn";[2]="create";[3]="createComponent";[4]="createSent";[5]="propsLeft";[6]="setPropClean";[7]="setPropUndo";[8]="spawnRate";["canSpawn"]={["class"]="function";["description"]="\
Checks if a user can spawn anymore props.";["fname"]="canSpawn";["library"]="prop";["name"]="props_library.canSpawn";["param"]={};["private"]=false;["realm"]="sv";["ret"]="True if user can spawn props, False if not.";["server"]=true;["summary"]="\
Checks if a user can spawn anymore props.";};["create"]={["class"]="function";["description"]="\
Creates a prop.";["fname"]="create";["library"]="prop";["name"]="props_library.create";["param"]={[1]="pos";[2]="ang";[3]="model";[4]="frozen";};["private"]=false;["realm"]="sv";["ret"]="The prop object";["server"]=true;["summary"]="\
Creates a prop.";};["createComponent"]={["class"]="function";["description"]="\
Creates starfall component.\\n Allowed components:\\n starfall_hud\\n starfall_screen";["fname"]="createComponent";["library"]="prop";["name"]="props_library.createComponent";["param"]={[1]="pos";[2]="ang";[3]="class";[4]="model";[5]="frozen";["ang"]="Angle of created component";["class"]="Class of created component";["frozen"]="True to spawn frozen";["model"]="Model of created component";["pos"]="Position of created component";};["private"]=false;["realm"]="sv";["ret"]="Component entity";["server"]=true;["summary"]="\
Creates starfall component.\\n Allowed components:\\n starfall_hud\\n starfall_screen ";};["createSent"]={["class"]="function";["description"]="\
Creates a sent.";["fname"]="createSent";["library"]="prop";["name"]="props_library.createSent";["param"]={[1]="pos";[2]="ang";[3]="class";[4]="frozen";["ang"]="Angle of created sent";["class"]="Class of created sent";["frozen"]="True to spawn frozen";["pos"]="Position of created sent";};["private"]=false;["realm"]="sv";["ret"]="The sent object";["server"]=true;["summary"]="\
Creates a sent.";};["propsLeft"]={["class"]="function";["description"]="\
Checks how many props can be spawned";["fname"]="propsLeft";["library"]="prop";["name"]="props_library.propsLeft";["param"]={};["private"]=false;["realm"]="sv";["ret"]="number of props able to be spawned";["server"]=true;["summary"]="\
Checks how many props can be spawned ";};["setPropClean"]={["class"]="function";["description"]="\
Sets whether the chip should remove created props when the chip is removed";["fname"]="setPropClean";["library"]="prop";["name"]="props_library.setPropClean";["param"]={[1]="on";["on"]="Boolean whether the props should be cleaned or not";};["private"]=false;["realm"]="sv";["summary"]="\
Sets whether the chip should remove created props when the chip is removed ";};["setPropUndo"]={["class"]="function";["description"]="\
Sets whether the props should be undo-able";["fname"]="setPropUndo";["library"]="prop";["name"]="props_library.setPropUndo";["param"]={[1]="on";["on"]="Boolean whether the props should be undo-able";};["private"]=false;["realm"]="sv";["summary"]="\
Sets whether the props should be undo-able ";};["spawnRate"]={["class"]="function";["description"]="\
Returns how many props per second the user can spawn";["fname"]="spawnRate";["library"]="prop";["name"]="props_library.spawnRate";["param"]={};["private"]=false;["realm"]="sv";["ret"]="Number of props per second the user can spawn";["server"]=true;["summary"]="\
Returns how many props per second the user can spawn ";};};["libtbl"]="props_library";["name"]="prop";["server"]=true;["summary"]="\
Library for creating and manipulating physics-less models AKA \"Props\".";["tables"]={};};["quaternion"]={["class"]="library";["client"]=true;["description"]="\
Quaternion library";["fields"]={};["functions"]={[1]="New";[10]="qi";[11]="qj";[12]="qk";[13]="rotationAngle";[14]="rotationAxis";[15]="rotationEulerAngle";[16]="rotationVector";[17]="slerp";[18]="vec";[2]="abs";[3]="conj";[4]="exp";[5]="inv";[6]="log";[7]="qMod";[8]="qRotation";[9]="qRotation";["New"]={["class"]="function";["description"]="\
Creates a new Quaternion given a variety of inputs";["fname"]="New";["library"]="quaternion";["name"]="quat_lib.New";["param"]={["..."]="A series of arguments which lead to valid generation of a quaternion. \
See argTypesToQuat table for examples of acceptable inputs.";[1]="self";[2]="...";};["private"]=false;["realm"]="sh";["summary"]="\
Creates a new Quaternion given a variety of inputs ";};["abs"]={["class"]="function";["description"]="\
Returns absolute value of <q>";["fname"]="abs";["library"]="quaternion";["name"]="quat_lib.abs";["param"]={[1]="q";};["private"]=false;["realm"]="sh";["summary"]="\
Returns absolute value of <q> ";};["conj"]={["class"]="function";["description"]="\
Returns the conjugate of <q>";["fname"]="conj";["library"]="quaternion";["name"]="quat_lib.conj";["param"]={[1]="q";};["private"]=false;["realm"]="sh";["summary"]="\
Returns the conjugate of <q> ";};["exp"]={["class"]="function";["description"]="\
Raises Euler's constant e to the power <q>";["fname"]="exp";["library"]="quaternion";["name"]="quat_lib.exp";["param"]={[1]="q";};["private"]=false;["realm"]="sh";["summary"]="\
Raises Euler's constant e to the power <q> ";};["inv"]={["class"]="function";["description"]="\
Returns the inverse of <q>";["fname"]="inv";["library"]="quaternion";["name"]="quat_lib.inv";["param"]={[1]="q";};["private"]=false;["realm"]="sh";["summary"]="\
Returns the inverse of <q> ";};["log"]={["class"]="function";["description"]="\
Calculates natural logarithm of <q>";["fname"]="log";["library"]="quaternion";["name"]="quat_lib.log";["param"]={[1]="q";};["private"]=false;["realm"]="sh";["summary"]="\
Calculates natural logarithm of <q> ";};["qMod"]={["class"]="function";["description"]="\
Changes quaternion <q> so that the represented rotation is by an angle between 0 and 180 degrees (by coder0xff)";["fname"]="qMod";["library"]="quaternion";["name"]="quat_lib.qMod";["param"]={[1]="q";};["private"]=false;["realm"]="sh";["summary"]="\
Changes quaternion <q> so that the represented rotation is by an angle between 0 and 180 degrees (by coder0xff) ";};["qRotation"]={["class"]="function";["description"]="\
Construct a quaternion from the rotation vector <rv1>. Vector direction is axis of rotation, magnitude is angle in degress (by coder0xff)";["fname"]="qRotation";["library"]="quaternion";["name"]="quat_lib.qRotation";["param"]={[1]="rv1";};["private"]=false;["realm"]="sh";["summary"]="\
Construct a quaternion from the rotation vector <rv1>.";};["qi"]={["class"]="function";["description"]="\
Returns Quaternion <n>*i";["fname"]="qi";["library"]="quaternion";["name"]="quat_lib.qi";["param"]={[1]="n";};["private"]=false;["realm"]="sh";["summary"]="\
Returns Quaternion <n>*i ";};["qj"]={["class"]="function";["description"]="\
Returns Quaternion <n>*j";["fname"]="qj";["library"]="quaternion";["name"]="quat_lib.qj";["param"]={[1]="n";};["private"]=false;["realm"]="sh";["summary"]="\
Returns Quaternion <n>*j ";};["qk"]={["class"]="function";["description"]="\
Returns Quaternion <n>*k";["fname"]="qk";["library"]="quaternion";["name"]="quat_lib.qk";["param"]={[1]="n";};["private"]=false;["realm"]="sh";["summary"]="\
Returns Quaternion <n>*k ";};["rotationAngle"]={["class"]="function";["description"]="\
Returns the angle of rotation in degrees (by coder0xff)";["fname"]="rotationAngle";["library"]="quaternion";["name"]="quat_lib.rotationAngle";["param"]={[1]="q";};["private"]=false;["realm"]="sh";["summary"]="\
Returns the angle of rotation in degrees (by coder0xff) ";};["rotationAxis"]={["class"]="function";["description"]="\
Returns the axis of rotation (by coder0xff)";["fname"]="rotationAxis";["library"]="quaternion";["name"]="quat_lib.rotationAxis";["param"]={[1]="q";};["private"]=false;["realm"]="sh";["summary"]="\
Returns the axis of rotation (by coder0xff) ";};["rotationEulerAngle"]={["class"]="function";["description"]="\
Returns the euler angle of rotation in degrees";["fname"]="rotationEulerAngle";["library"]="quaternion";["name"]="quat_lib.rotationEulerAngle";["param"]={[1]="q";};["private"]=false;["realm"]="sh";["summary"]="\
Returns the euler angle of rotation in degrees ";};["rotationVector"]={["class"]="function";["description"]="\
Returns the rotation vector - rotation axis where magnitude is the angle of rotation in degress (by coder0xff)";["fname"]="rotationVector";["library"]="quaternion";["name"]="quat_lib.rotationVector";["param"]={[1]="q";};["private"]=false;["realm"]="sh";["summary"]="\
Returns the rotation vector - rotation axis where magnitude is the angle of rotation in degress (by coder0xff) ";};["slerp"]={["class"]="function";["description"]="\
Performs spherical linear interpolation between <q0> and <q1>. Returns <q0> for <t>=0, <q1> for <t>=1";["fname"]="slerp";["library"]="quaternion";["name"]="quat_lib.slerp";["param"]={[1]="q0";[2]="q1";[3]="t";};["private"]=false;["realm"]="sh";["summary"]="\
Performs spherical linear interpolation between <q0> and <q1>.";};["vec"]={["class"]="function";["description"]="\
Converts <q> to a vector by dropping the real component";["fname"]="vec";["library"]="quaternion";["name"]="quat_lib.vec";["param"]={[1]="q";};["private"]=false;["realm"]="sh";["summary"]="\
Converts <q> to a vector by dropping the real component ";};};["libtbl"]="quat_lib";["name"]="quaternion";["server"]=true;["summary"]="\
Quaternion library ";["tables"]={};};["render"]={["class"]="library";["description"]="\
Render library. Screens are 512x512 units. Most functions require \
that you be in the rendering hook to call, otherwise an error is \
thrown. +x is right, +y is down";["entity"]="starfall_screen";["field"]={[1]="TEXT_ALIGN_LEFT";[2]="TEXT_ALIGN_CENTER";[3]="TEXT_ALIGN_RIGHT";[4]="TEXT_ALIGN_TOP";[5]="TEXT_ALIGN_BOTTOM";["TEXT_ALIGN_BOTTOM"]="";["TEXT_ALIGN_CENTER"]="";["TEXT_ALIGN_LEFT"]="";["TEXT_ALIGN_RIGHT"]="";["TEXT_ALIGN_TOP"]="";};["fields"]={};["functions"]={[1]="capturePixels";[10]="destroyRenderTarget";[11]="destroyTexture";[12]="disableScissorRect";[13]="draw3DBeam";[14]="draw3DBox";[15]="draw3DLine";[16]="draw3DQuad";[17]="draw3DSphere";[18]="draw3DSprite";[19]="draw3DWireframeBox";[2]="clear";[20]="draw3DWireframeSphere";[21]="drawCircle";[22]="drawLine";[23]="drawPoly";[24]="drawRect";[25]="drawRectOutline";[26]="drawRoundedBox";[27]="drawRoundedBoxEx";[28]="drawSimpleText";[29]="drawText";[3]="clearBuffersObeyStencil";[30]="drawTexturedRect";[31]="drawTexturedRectRotated";[32]="drawTexturedRectUV";[33]="enableDepth";[34]="enableScissorRect";[35]="getDefaultFont";[36]="getGameResolution";[37]="getRenderTargetMaterial";[38]="getResolution";[39]="getScreenEntity";[4]="clearDepth";[40]="getScreenInfo";[41]="getTextSize";[42]="getTextureID";[43]="isHUDActive";[44]="parseMarkup";[45]="popMatrix";[46]="popViewMatrix";[47]="pushMatrix";[48]="pushViewMatrix";[49]="readPixel";[5]="clearStencil";[50]="selectRenderTarget";[51]="setBackgroundColor";[52]="setColor";[53]="setCullMode";[54]="setFilterMag";[55]="setFilterMin";[56]="setFont";[57]="setRGBA";[58]="setRenderTargetTexture";[59]="setStencilCompareFunction";[6]="clearStencilBufferRectangle";[60]="setStencilEnable";[61]="setStencilFailOperation";[62]="setStencilPassOperation";[63]="setStencilReferenceValue";[64]="setStencilTestMask";[65]="setStencilWriteMask";[66]="setStencilZFailOperation";[67]="setTexture";[68]="setTextureFromScreen";[69]="traceSurfaceColor";[7]="createFont";[8]="createRenderTarget";[9]="cursorPos";["capturePixels"]={["class"]="function";["description"]="\
Dumps the current render target and allows the pixels to be accessed by render.readPixel.";["fname"]="capturePixels";["library"]="render";["name"]="render_library.capturePixels";["param"]={};["private"]=false;["realm"]="cl";["summary"]="\
Dumps the current render target and allows the pixels to be accessed by render.readPixel.";};["clear"]={["class"]="function";["description"]="\
Clears the active render target";["fname"]="clear";["library"]="render";["name"]="render_library.clear";["param"]={[1]="clr";[2]="depth";["clr"]="Color type to clear with";["depth"]="Boolean if should clear depth";};["private"]=false;["realm"]="cl";["summary"]="\
Clears the active render target ";};["clearBuffersObeyStencil"]={["class"]="function";["description"]="\
Clears the current rendertarget for obeying the current stencil buffer conditions.";["fname"]="clearBuffersObeyStencil";["library"]="render";["name"]="render_library.clearBuffersObeyStencil";["param"]={[1]="r";[2]="g";[3]="b";[4]="a";[5]="depth";["b"]="Value of the blue channel to clear the current rt with.";["depth"]="Clear the depth buffer.";["g"]="Value of the green channel to clear the current rt with.";["r"]="Value of the red channel to clear the current rt with.";};["private"]=false;["realm"]="cl";["summary"]="\
Clears the current rendertarget for obeying the current stencil buffer conditions.";};["clearDepth"]={["class"]="function";["description"]="\
Resets the depth buffer";["fname"]="clearDepth";["library"]="render";["name"]="render_library.clearDepth";["param"]={};["private"]=false;["realm"]="cl";["summary"]="\
Resets the depth buffer ";};["clearStencil"]={["class"]="function";["description"]="\
Resets all values in the stencil buffer to zero.";["fname"]="clearStencil";["library"]="render";["name"]="render_library.clearStencil";["param"]={};["private"]=false;["realm"]="cl";["summary"]="\
Resets all values in the stencil buffer to zero.";};["clearStencilBufferRectangle"]={["class"]="function";["description"]="\
Sets the stencil value in a specified rect.";["fname"]="clearStencilBufferRectangle";["library"]="render";["name"]="render_library.clearStencilBufferRectangle";["param"]={[1]="originX";[2]="originY";[3]="endX";[4]="endY";[5]="stencilValue";["endX"]="The end X coordinate of the rectangle.";["endY"]="The end Y coordinate of the rectangle.";["originX"]="X origin of the rectangle.";["originY"]="Y origin of the rectangle.";["stencilValue"]="Value to set cleared stencil buffer to.";};["private"]=false;["realm"]="cl";["summary"]="\
Sets the stencil value in a specified rect.";};["createFont"]={["class"]="function";["description"]="\
Creates a font. Does not require rendering hook";["fname"]="createFont";["library"]="render";["name"]="render_library.createFont";["param"]={[1]="font";[2]="size";[3]="weight";[4]="antialias";[5]="additive";[6]="shadow";[7]="outline";[8]="blur";[9]="extended";["additive"]="If true, adds brightness to pixels behind it rather than drawing over them.";["antialias"]="Antialias font?";["blur"]="Enable blur?";["extended"]="Allows the font to display glyphs outside of Latin-1 range. Unicode code points above 0xFFFF are not supported. Required to use FontAwesome";["font"]="Base font to use";["outline"]="Enable outline?";["shadow"]="Enable drop shadow?";["size"]="Font size";["weight"]="Font weight (default: 400)";};["private"]=false;["realm"]="cl";["summary"]="\
Creates a font.";["usage"]="\
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
- Times New Roman";};["createRenderTarget"]={["class"]="function";["description"]="\
Creates a new render target to draw onto. \
The dimensions will always be 1024x1024";["fname"]="createRenderTarget";["library"]="render";["name"]="render_library.createRenderTarget";["param"]={[1]="name";["name"]="The name of the render target";};["private"]=false;["realm"]="cl";["summary"]="\
Creates a new render target to draw onto.";};["cursorPos"]={["class"]="function";["description"]="\
Gets a 2D cursor position where ply is aiming.";["fname"]="cursorPos";["library"]="render";["name"]="render_library.cursorPos";["param"]={[1]="ply";["ply"]="player to get cursor position from(optional)";};["private"]=false;["realm"]="cl";["ret"]={[1]="x position";[2]="y position";};["summary"]="\
Gets a 2D cursor position where ply is aiming.";};["destroyRenderTarget"]={["class"]="function";["description"]="\
Releases the rendertarget. Required if you reach the maximum rendertargets.";["fname"]="destroyRenderTarget";["library"]="render";["name"]="render_library.destroyRenderTarget";["param"]={[1]="name";["name"]="Rendertarget name";};["private"]=false;["realm"]="cl";["summary"]="\
Releases the rendertarget.";};["destroyTexture"]={["class"]="function";["description"]="\
Releases the texture. Required if you reach the maximum url textures.";["fname"]="destroyTexture";["library"]="render";["name"]="render_library.destroyTexture";["param"]={[1]="id";["id"]="Texture table. Aquired with render.getTextureID";};["private"]=false;["realm"]="cl";["summary"]="\
Releases the texture.";};["disableScissorRect"]={["class"]="function";["description"]="\
Disables a scissoring rect which limits the drawing area.";["fname"]="disableScissorRect";["library"]="render";["name"]="render_library.disableScissorRect";["param"]={};["private"]=false;["realm"]="cl";["summary"]="\
Disables a scissoring rect which limits the drawing area.";};["draw3DBeam"]={["class"]="function";["description"]="\
Draws textured beam.";["fname"]="draw3DBeam";["library"]="render";["name"]="render_library.draw3DBeam";["param"]={[1]="startPos";[2]="endPos";[3]="width";[4]="textureStart";[5]="textureEnd";["endPos"]="Beam end position.";["startPos"]="Beam start position.";["textureEnd"]="The end coordinate of the texture used.";["textureStart"]="The start coordinate of the texture used.";["width"]="The width of the beam.";};["private"]=false;["realm"]="cl";["summary"]="\
Draws textured beam.";};["draw3DBox"]={["class"]="function";["description"]="\
Draws a box in 3D space";["fname"]="draw3DBox";["library"]="render";["name"]="render_library.draw3DBox";["param"]={[1]="origin";[2]="angle";[3]="mins";[4]="maxs";["angle"]="Orientation  of the box";["maxs"]="End position of the box, relative to origin.";["mins"]="Start position of the box, relative to origin.";["origin"]="Origin of the box.";};["private"]=false;["realm"]="cl";["summary"]="\
Draws a box in 3D space ";};["draw3DLine"]={["class"]="function";["description"]="\
Draws a 3D Line";["fname"]="draw3DLine";["library"]="render";["name"]="render_library.draw3DLine";["param"]={[1]="startPos";[2]="endPos";["endPos"]="Ending position";["startPos"]="Starting position";};["private"]=false;["realm"]="cl";["summary"]="\
Draws a 3D Line ";};["draw3DQuad"]={["class"]="function";["description"]="\
Draws 2 connected triangles.";["fname"]="draw3DQuad";["library"]="render";["name"]="render_library.draw3DQuad";["param"]={[1]="vert1";[2]="vert2";[3]="vert3";[4]="vert4";["vert1"]="First vertex.";["vert2"]="The second vertex.";["vert3"]="The third vertex.";["vert4"]="The fourth vertex.";};["private"]=false;["realm"]="cl";["summary"]="\
Draws 2 connected triangles.";};["draw3DSphere"]={["class"]="function";["description"]="\
Draws a sphere";["fname"]="draw3DSphere";["library"]="render";["name"]="render_library.draw3DSphere";["param"]={[1]="pos";[2]="radius";[3]="longitudeSteps";[4]="latitudeSteps";["latitudeSteps"]="The amount of latitude steps. The larger this number is, the smoother the sphere is";["longitudeSteps"]="The amount of longitude steps. The larger this number is, the smoother the sphere is";["pos"]="Position of the sphere";["radius"]="Radius of the sphere";};["private"]=false;["realm"]="cl";["summary"]="\
Draws a sphere ";};["draw3DSprite"]={["class"]="function";["description"]="\
Draws a sprite in 3d space.";["fname"]="draw3DSprite";["library"]="render";["name"]="render_library.draw3DSprite";["param"]={[1]="pos";[2]="width";[3]="height";["height"]="Height of the sprite.";["pos"]="Position of the sprite.";["width"]="Width of the sprite.";};["private"]=false;["realm"]="cl";["summary"]="\
Draws a sprite in 3d space.";};["draw3DWireframeBox"]={["class"]="function";["description"]="\
Draws a wireframe box in 3D space";["fname"]="draw3DWireframeBox";["library"]="render";["name"]="render_library.draw3DWireframeBox";["param"]={[1]="origin";[2]="angle";[3]="mins";[4]="maxs";["angle"]="Orientation  of the box";["maxs"]="End position of the box, relative to origin.";["mins"]="Start position of the box, relative to origin.";["origin"]="Origin of the box.";};["private"]=false;["realm"]="cl";["summary"]="\
Draws a wireframe box in 3D space ";};["draw3DWireframeSphere"]={["class"]="function";["description"]="\
Draws a wireframe sphere";["fname"]="draw3DWireframeSphere";["library"]="render";["name"]="render_library.draw3DWireframeSphere";["param"]={[1]="pos";[2]="radius";[3]="longitudeSteps";[4]="latitudeSteps";["latitudeSteps"]="The amount of latitude steps. The larger this number is, the smoother the sphere is";["longitudeSteps"]="The amount of longitude steps. The larger this number is, the smoother the sphere is";["pos"]="Position of the sphere";["radius"]="Radius of the sphere";};["private"]=false;["realm"]="cl";["summary"]="\
Draws a wireframe sphere ";};["drawCircle"]={["class"]="function";["description"]="\
Draws a circle outline";["fname"]="drawCircle";["library"]="render";["name"]="render_library.drawCircle";["param"]={[1]="x";[2]="y";[3]="r";["r"]="Radius";["x"]="Center x coordinate";["y"]="Center y coordinate";};["private"]=false;["realm"]="cl";["summary"]="\
Draws a circle outline ";};["drawLine"]={["class"]="function";["description"]="\
Draws a line";["fname"]="drawLine";["library"]="render";["name"]="render_library.drawLine";["param"]={[1]="x1";[2]="y1";[3]="x2";[4]="y2";["x1"]="X start coordinate";["x2"]="X end coordinate";["y1"]="Y start coordinate";["y2"]="Y end coordinate";};["private"]=false;["realm"]="cl";["summary"]="\
Draws a line ";};["drawPoly"]={["class"]="function";["description"]="\
Draws a polygon.";["fname"]="drawPoly";["library"]="render";["name"]="render_library.drawPoly";["param"]={[1]="poly";["poly"]="Table of polygon vertices. Texture coordinates are optional. {{x=x1, y=y1, u=u1, v=v1}, ... }";};["private"]=false;["realm"]="cl";["summary"]="\
Draws a polygon.";};["drawRect"]={["class"]="function";["description"]="\
Draws a rectangle using the current color.";["fname"]="drawRect";["library"]="render";["name"]="render_library.drawRect";["param"]={[1]="x";[2]="y";[3]="w";[4]="h";["h"]="Height";["w"]="Width";["x"]="Top left corner x coordinate";["y"]="Top left corner y coordinate";};["private"]=false;["realm"]="cl";["summary"]="\
Draws a rectangle using the current color.";};["drawRectOutline"]={["class"]="function";["description"]="\
Draws a rectangle outline using the current color.";["fname"]="drawRectOutline";["library"]="render";["name"]="render_library.drawRectOutline";["param"]={[1]="x";[2]="y";[3]="w";[4]="h";["h"]="Height";["w"]="Width";["x"]="Top left corner x coordinate";["y"]="Top left corner y coordinate";};["private"]=false;["realm"]="cl";["summary"]="\
Draws a rectangle outline using the current color.";};["drawRoundedBox"]={["class"]="function";["description"]="\
Draws a rounded rectangle using the current color";["fname"]="drawRoundedBox";["library"]="render";["name"]="render_library.drawRoundedBox";["param"]={[1]="r";[2]="x";[3]="y";[4]="w";[5]="h";["h"]="Height";["r"]="The corner radius";["w"]="Width";["x"]="Top left corner x coordinate";["y"]="Top left corner y coordinate";};["private"]=false;["realm"]="cl";["summary"]="\
Draws a rounded rectangle using the current color ";};["drawRoundedBoxEx"]={["class"]="function";["description"]="\
Draws a rounded rectangle using the current color";["fname"]="drawRoundedBoxEx";["library"]="render";["name"]="render_library.drawRoundedBoxEx";["param"]={[1]="r";[2]="x";[3]="y";[4]="w";[5]="h";[6]="tl";[7]="tr";[8]="bl";[9]="br";["bl"]="Boolean Bottom left corner";["br"]="Boolean Bottom right corner";["h"]="Height";["r"]="The corner radius";["tl"]="Boolean Top left corner";["tr"]="Boolean Top right corner";["w"]="Width";["x"]="Top left corner x coordinate";["y"]="Top left corner y coordinate";};["private"]=false;["realm"]="cl";["summary"]="\
Draws a rounded rectangle using the current color ";};["drawSimpleText"]={["class"]="function";["description"]="\
Draws text more easily and quickly but no new lines or tabs.";["fname"]="drawSimpleText";["library"]="render";["name"]="render_library.drawSimpleText";["param"]={[1]="x";[2]="y";[3]="text";[4]="xalign";[5]="yalign";["text"]="Text to draw";["x"]="X coordinate";["xalign"]="Text x alignment";["y"]="Y coordinate";["yalign"]="Text y alignment";};["private"]=false;["realm"]="cl";["summary"]="\
Draws text more easily and quickly but no new lines or tabs.";};["drawText"]={["class"]="function";["description"]="\
Draws text with newlines and tabs";["fname"]="drawText";["library"]="render";["name"]="render_library.drawText";["param"]={[1]="x";[2]="y";[3]="text";[4]="alignment";["alignment"]="Text alignment";["text"]="Text to draw";["x"]="X coordinate";["y"]="Y coordinate";};["private"]=false;["realm"]="cl";["summary"]="\
Draws text with newlines and tabs ";};["drawTexturedRect"]={["class"]="function";["description"]="\
Draws a textured rectangle.";["fname"]="drawTexturedRect";["library"]="render";["name"]="render_library.drawTexturedRect";["param"]={[1]="x";[2]="y";[3]="w";[4]="h";["h"]="Height";["w"]="Width";["x"]="Top left corner x coordinate";["y"]="Top left corner y coordinate";};["private"]=false;["realm"]="cl";["summary"]="\
Draws a textured rectangle.";};["drawTexturedRectRotated"]={["class"]="function";["description"]="\
Draws a rotated, textured rectangle.";["fname"]="drawTexturedRectRotated";["library"]="render";["name"]="render_library.drawTexturedRectRotated";["param"]={[1]="x";[2]="y";[3]="w";[4]="h";[5]="rot";["h"]="Height";["rot"]="Rotation in degrees";["w"]="Width";["x"]="X coordinate of center of rect";["y"]="Y coordinate of center of rect";};["private"]=false;["realm"]="cl";["summary"]="\
Draws a rotated, textured rectangle.";};["drawTexturedRectUV"]={["class"]="function";["description"]="\
Draws a textured rectangle with UV coordinates";["fname"]="drawTexturedRectUV";["library"]="render";["name"]="render_library.drawTexturedRectUV";["param"]={[1]="x";[2]="y";[3]="w";[4]="h";[5]="startU";[6]="startV";[7]="endU";[8]="endV";["endV"]="Texture mapping at rectangle end";["h"]="Height";["startU"]="Texture mapping at rectangle origin";["startV"]="Texture mapping at rectangle origin";["w"]="Width";["x"]="Top left corner x coordinate";["y"]="Top left corner y coordinate";};["private"]=false;["realm"]="cl";["summary"]="\
Draws a textured rectangle with UV coordinates ";};["enableDepth"]={["class"]="function";["description"]="\
Enables or disables Depth Buffer";["fname"]="enableDepth";["library"]="render";["name"]="render_library.enableDepth";["param"]={[1]="enable";["enable"]="true to enable";};["private"]=false;["realm"]="cl";["summary"]="\
Enables or disables Depth Buffer ";};["enableScissorRect"]={["class"]="function";["description"]="\
Enables a scissoring rect which limits the drawing area. Only works 2D contexts such as HUD or render targets.";["fname"]="enableScissorRect";["library"]="render";["name"]="render_library.enableScissorRect";["param"]={[1]="startX";[2]="startY";[3]="endX";[4]="endY";["endX"]="Y end coordinate of the scissor rect.";["startX"]="X start coordinate of the scissor rect.";["startY"]="Y start coordinate of the scissor rect.";};["private"]=false;["realm"]="cl";["summary"]="\
Enables a scissoring rect which limits the drawing area.";};["getDefaultFont"]={["class"]="function";["description"]="\
Gets the default font";["fname"]="getDefaultFont";["library"]="render";["name"]="render_library.getDefaultFont";["param"]={};["private"]=false;["realm"]="cl";["ret"]="Default font";["summary"]="\
Gets the default font ";};["getGameResolution"]={["class"]="function";["classForced"]=true;["description"]="\
Returns width and height of the game window";["fname"]="getGameResolution";["library"]="render";["name"]="render_library.getGameResolution";["param"]={};["private"]=false;["realm"]="cl";["ret"]={[1]="the X size of the game window";[2]="the Y size of the game window";};["summary"]="\
Returns width and height of the game window ";};["getRenderTargetMaterial"]={["class"]="function";["description"]="\
Returns the model material name that uses the render target.";["fname"]="getRenderTargetMaterial";["library"]="render";["name"]="render_library.getRenderTargetMaterial";["param"]={[1]="name";["name"]="Render target name";};["private"]=false;["realm"]="cl";["ret"]="Model material name. use ent:setMaterial in clientside to set the entity's material to this";["summary"]="\
Returns the model material name that uses the render target.";};["getResolution"]={["class"]="function";["classForced"]=true;["description"]="\
Returns the render context's width and height";["fname"]="getResolution";["library"]="render";["name"]="render_library.getResolution";["param"]={};["private"]=false;["realm"]="cl";["ret"]={[1]="the X size of the current render context";[2]="the Y size of the current render context";};["summary"]="\
Returns the render context's width and height ";};["getScreenEntity"]={["class"]="function";["description"]="\
Returns the entity currently being rendered to";["fname"]="getScreenEntity";["library"]="render";["name"]="render_library.getScreenEntity";["param"]={};["private"]=false;["realm"]="cl";["ret"]="Entity of the screen or hud being rendered";["summary"]="\
Returns the entity currently being rendered to ";};["getScreenInfo"]={["class"]="function";["description"]="\
Returns information about the screen, such as world offsets, dimentions, and rotation. \
Note: this does a table copy so move it out of your draw hook";["fname"]="getScreenInfo";["library"]="render";["name"]="render_library.getScreenInfo";["param"]={[1]="e";["e"]="The screen to get info from.";};["private"]=false;["realm"]="cl";["ret"]="A table describing the screen.";["summary"]="\
Returns information about the screen, such as world offsets, dimentions, and rotation.";};["getTextSize"]={["class"]="function";["description"]="\
Gets the size of the specified text. Don't forget to use setFont before calling this function";["fname"]="getTextSize";["library"]="render";["name"]="render_library.getTextSize";["param"]={[1]="text";["text"]="Text to get the size of";};["private"]=false;["realm"]="cl";["ret"]={[1]="width of the text";[2]="height of the text";};["summary"]="\
Gets the size of the specified text.";};["getTextureID"]={["class"]="function";["description"]="\
Looks up a texture by file name. Use with render.setTexture to draw with it. \
Make sure to store the texture to use it rather than calling this slow function repeatedly.";["fname"]="getTextureID";["library"]="render";["name"]="render_library.getTextureID";["param"]={[1]="tx";[2]="cb";[3]="alignment";[4]="skip_hack";["alignment"]="Optional alignment for the url texture. Default: \"center\", See http://www.w3schools.com/cssref/pr_background-position.asp";["cb"]="Optional callback for when a url texture finishes loading. param1 - The texture table, param2 - The texture url";["skip_hack"]="Turns off texture hack so you can use UVs on 3D objects";["tx"]="Texture file path, a http url, or image data: https://en.wikipedia.org/wiki/Data_URI_scheme";};["private"]=false;["realm"]="cl";["ret"]="Texture table. Use it with render.setTexture. Returns nil if max url textures is reached.";["summary"]="\
Looks up a texture by file name.";};["isHUDActive"]={["class"]="function";["description"]="\
Checks if a hud component is connected to the Starfall Chip";["fname"]="isHUDActive";["library"]="render";["name"]="render_library.isHUDActive";["param"]={};["private"]=false;["realm"]="cl";["summary"]="\
Checks if a hud component is connected to the Starfall Chip ";};["parseMarkup"]={["class"]="function";["description"]="\
Constructs a markup object for quick styled text drawing.";["fname"]="parseMarkup";["library"]="render";["name"]="render_library.parseMarkup";["param"]={[1]="str";[2]="maxsize";["maxsize"]="The max width of the markup";["str"]="The markup string to parse";};["private"]=false;["realm"]="cl";["ret"]="The markup object. See https://wiki.garrysmod.com/page/Category:MarkupObject";["summary"]="\
Constructs a markup object for quick styled text drawing.";};["popMatrix"]={["class"]="function";["description"]="\
Pops a matrix from the matrix stack.";["fname"]="popMatrix";["library"]="render";["name"]="render_library.popMatrix";["param"]={};["private"]=false;["realm"]="cl";["summary"]="\
Pops a matrix from the matrix stack.";};["popViewMatrix"]={["class"]="function";["description"]="\
Pops a view matrix from the matrix stack.";["fname"]="popViewMatrix";["library"]="render";["name"]="render_library.popViewMatrix";["param"]={};["private"]=false;["realm"]="cl";["summary"]="\
Pops a view matrix from the matrix stack.";};["pushMatrix"]={["class"]="function";["description"]="\
Pushes a matrix onto the matrix stack.";["fname"]="pushMatrix";["library"]="render";["name"]="render_library.pushMatrix";["param"]={[1]="m";[2]="world";["m"]="The matrix";["world"]="Should the transformation be relative to the screen or world?";};["private"]=false;["realm"]="cl";["summary"]="\
Pushes a matrix onto the matrix stack.";};["pushViewMatrix"]={["class"]="function";["description"]="\
Pushes a perspective matrix onto the view matrix stack.";["fname"]="pushViewMatrix";["library"]="render";["name"]="render_library.pushViewMatrix";["param"]={[1]="tbl";["tbl"]="The view matrix data. See http://wiki.garrysmod.com/page/Structures/RenderCamData";};["private"]=false;["realm"]="cl";["summary"]="\
Pushes a perspective matrix onto the view matrix stack.";};["readPixel"]={["class"]="function";["description"]="\
Reads the color of the specified pixel.";["fname"]="readPixel";["library"]="render";["name"]="render_library.readPixel";["param"]={[1]="x";[2]="y";["x"]="Pixel x-coordinate.";["y"]="Pixel y-coordinate.";};["private"]=false;["realm"]="cl";["ret"]="Color object with ( r, g, b, 255 ) from the specified pixel.";["summary"]="\
Reads the color of the specified pixel.";};["selectRenderTarget"]={["class"]="function";["description"]="\
Selects the render target to draw on. \
Nil for the visible RT.";["fname"]="selectRenderTarget";["library"]="render";["name"]="render_library.selectRenderTarget";["param"]={[1]="name";["name"]="Name of the render target to use";};["private"]=false;["realm"]="cl";["summary"]="\
Selects the render target to draw on.";};["setBackgroundColor"]={["class"]="function";["description"]="\
Sets background color of screen";["fname"]="setBackgroundColor";["library"]="render";["name"]="render_library.setBackgroundColor";["param"]={[1]="col";[2]="screen";["col"]="Color of background";};["private"]=false;["realm"]="cl";["summary"]="\
Sets background color of screen ";};["setColor"]={["class"]="function";["description"]="\
Sets the draw color";["fname"]="setColor";["library"]="render";["name"]="render_library.setColor";["param"]={[1]="clr";["clr"]="Color type";};["private"]=false;["realm"]="cl";["summary"]="\
Sets the draw color ";};["setCullMode"]={["class"]="function";["description"]="\
Changes the cull mode";["fname"]="setCullMode";["library"]="render";["name"]="render_library.setCullMode";["param"]={[1]="mode";["mode"]="Cull mode. 0 for counter clock wise, 1 for clock wise";};["private"]=false;["realm"]="cl";["summary"]="\
Changes the cull mode ";};["setFilterMag"]={["class"]="function";["description"]="\
Sets the texture filtering function when viewing a close texture";["fname"]="setFilterMag";["library"]="render";["name"]="render_library.setFilterMag";["param"]={[1]="val";["val"]="The filter function to use http://wiki.garrysmod.com/page/Enums/TEXFILTER";};["private"]=false;["realm"]="cl";["summary"]="\
Sets the texture filtering function when viewing a close texture ";};["setFilterMin"]={["class"]="function";["description"]="\
Sets the texture filtering function when viewing a far texture";["fname"]="setFilterMin";["library"]="render";["name"]="render_library.setFilterMin";["param"]={[1]="val";["val"]="The filter function to use http://wiki.garrysmod.com/page/Enums/TEXFILTER";};["private"]=false;["realm"]="cl";["summary"]="\
Sets the texture filtering function when viewing a far texture ";};["setFont"]={["class"]="function";["description"]="\
Sets the font";["fname"]="setFont";["library"]="render";["name"]="render_library.setFont";["param"]={[1]="font";["font"]="The font to use";};["private"]=false;["realm"]="cl";["summary"]="\
Sets the font ";["usage"]="Use a font created by render.createFont or use one of these already defined fonts: \
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
- DermaLarge";};["setRGBA"]={["class"]="function";["description"]="\
Sets the draw color by RGBA values";["fname"]="setRGBA";["library"]="render";["name"]="render_library.setRGBA";["param"]={[1]="r";[2]="g";[3]="b";[4]="a";};["private"]=false;["realm"]="cl";["summary"]="\
Sets the draw color by RGBA values ";};["setRenderTargetTexture"]={["class"]="function";["description"]="\
Sets the active texture to the render target with the specified name. \
Nil to reset.";["fname"]="setRenderTargetTexture";["library"]="render";["name"]="render_library.setRenderTargetTexture";["param"]={[1]="name";["name"]="Name of the render target to use";};["private"]=false;["realm"]="cl";["summary"]="\
Sets the active texture to the render target with the specified name.";};["setStencilCompareFunction"]={["class"]="function";["description"]="\
Sets the compare function of the stencil. More: http://wiki.garrysmod.com/page/render/SetStencilCompareFunction";["fname"]="setStencilCompareFunction";["library"]="render";["name"]="render_library.setStencilCompareFunction";["param"]={[1]="compareFunction";["compareFunction"]="";};["private"]=false;["realm"]="cl";["summary"]="\
Sets the compare function of the stencil.";};["setStencilEnable"]={["class"]="function";["description"]="\
Sets whether stencil tests are carried out for each rendered pixel. Only pixels passing the stencil test are written to the render target.";["fname"]="setStencilEnable";["library"]="render";["name"]="render_library.setStencilEnable";["param"]={[1]="enable";["enable"]="true to enable, false to disable";};["private"]=false;["realm"]="cl";["summary"]="\
Sets whether stencil tests are carried out for each rendered pixel.";};["setStencilFailOperation"]={["class"]="function";["description"]="\
Sets the operation to be performed on the stencil buffer values if the compare function was not successful. More: http://wiki.garrysmod.com/page/render/SetStencilFailOperation";["fname"]="setStencilFailOperation";["library"]="render";["name"]="render_library.setStencilFailOperation";["param"]={[1]="operation";["operation"]="";};["private"]=false;["realm"]="cl";["summary"]="\
Sets the operation to be performed on the stencil buffer values if the compare function was not successful.";};["setStencilPassOperation"]={["class"]="function";["description"]="\
Sets the operation to be performed on the stencil buffer values if the compare function was successful. More: http://wiki.garrysmod.com/page/render/SetStencilPassOperation";["fname"]="setStencilPassOperation";["library"]="render";["name"]="render_library.setStencilPassOperation";["param"]={[1]="operation";["operation"]="";};["private"]=false;["realm"]="cl";["summary"]="\
Sets the operation to be performed on the stencil buffer values if the compare function was successful.";};["setStencilReferenceValue"]={["class"]="function";["description"]="\
Sets the reference value which will be used for all stencil operations. This is an unsigned integer.";["fname"]="setStencilReferenceValue";["library"]="render";["name"]="render_library.setStencilReferenceValue";["param"]={[1]="referenceValue";["referenceValue"]="Reference value.";};["private"]=false;["realm"]="cl";["summary"]="\
Sets the reference value which will be used for all stencil operations.";};["setStencilTestMask"]={["class"]="function";["description"]="\
Sets the unsigned 8-bit test bitflag mask to be used for any stencil testing.";["fname"]="setStencilTestMask";["library"]="render";["name"]="render_library.setStencilTestMask";["param"]={[1]="mask";["mask"]="The mask bitflag.";};["private"]=false;["realm"]="cl";["summary"]="\
Sets the unsigned 8-bit test bitflag mask to be used for any stencil testing.";};["setStencilWriteMask"]={["class"]="function";["description"]="\
Sets the unsigned 8-bit write bitflag mask to be used for any writes to the stencil buffer.";["fname"]="setStencilWriteMask";["library"]="render";["name"]="render_library.setStencilWriteMask";["param"]={[1]="mask";["mask"]="The mask bitflag.";};["private"]=false;["realm"]="cl";["summary"]="\
Sets the unsigned 8-bit write bitflag mask to be used for any writes to the stencil buffer.";};["setStencilZFailOperation"]={["class"]="function";["description"]="\
Sets the operation to be performed on the stencil buffer values if the stencil test is passed but the depth buffer test fails. More: http://wiki.garrysmod.com/page/render/SetStencilZFailOperation";["fname"]="setStencilZFailOperation";["library"]="render";["name"]="render_library.setStencilZFailOperation";["param"]={[1]="operation";["operation"]="";};["private"]=false;["realm"]="cl";["summary"]="\
Sets the operation to be performed on the stencil buffer values if the stencil test is passed but the depth buffer test fails.";};["setTexture"]={["class"]="function";["description"]="\
Sets the texture";["fname"]="setTexture";["library"]="render";["name"]="render_library.setTexture";["param"]={[1]="id";["id"]="Texture table. Aquired with render.getTextureID";};["private"]=false;["realm"]="cl";["summary"]="\
Sets the texture ";};["setTextureFromScreen"]={["class"]="function";["description"]="\
Sets the texture of a screen entity";["fname"]="setTextureFromScreen";["library"]="render";["name"]="render_library.setTextureFromScreen";["param"]={[1]="ent";["ent"]="Screen entity";};["private"]=false;["realm"]="cl";["summary"]="\
Sets the texture of a screen entity ";};["traceSurfaceColor"]={["class"]="function";["description"]="\
Does a trace and returns the color of the textel the trace hits.";["fname"]="traceSurfaceColor";["library"]="render";["name"]="render_library.traceSurfaceColor";["param"]={[1]="vec1";[2]="vec2";["vec1"]="The starting vector";["vec2"]="The ending vector";};["private"]=false;["realm"]="cl";["ret"]="The color vector. use vector:toColor to convert it to a color.";["summary"]="\
Does a trace and returns the color of the textel the trace hits.";};};["libtbl"]="render_library";["name"]="render";["summary"]="\
Render library.";["tables"]={};};["sounds"]={["class"]="library";["client"]=true;["description"]="\
Sounds library.";["fields"]={};["functions"]={[1]="canCreate";[2]="create";["canCreate"]={["class"]="function";["description"]="\
Returns if a sound is able to be created";["fname"]="canCreate";["library"]="sounds";["name"]="sound_library.canCreate";["param"]={};["private"]=false;["realm"]="sh";["ret"]="If it is possible to make a sound";["summary"]="\
Returns if a sound is able to be created ";};["create"]={["class"]="function";["description"]="\
Creates a sound and attaches it to an entity";["fname"]="create";["library"]="sounds";["name"]="sound_library.create";["param"]={[1]="ent";[2]="path";["ent"]="Entity to attach sound to.";["path"]="Filepath to the sound file.";};["private"]=false;["realm"]="sh";["ret"]="Sound Object";["summary"]="\
Creates a sound and attaches it to an entity ";};};["libtbl"]="sound_library";["name"]="sounds";["server"]=true;["summary"]="\
Sounds library.";["tables"]={};};["team"]={["class"]="library";["client"]=true;["description"]="\
Library for retreiving information about teams";["fields"]={};["functions"]={[1]="bestAutoJoinTeam";[10]="getPlayers";[11]="getScore";[2]="exists";[3]="getAllTeams";[4]="getColor";[5]="getJoinable";[6]="getName";[7]="getNumDeaths";[8]="getNumFrags";[9]="getNumPlayers";["bestAutoJoinTeam"]={["class"]="function";["classForced"]=true;["description"]="\
Returns team with least players";["fname"]="bestAutoJoinTeam";["library"]="team";["name"]="team_library.bestAutoJoinTeam";["param"]={};["realm"]="sh";["ret"]="index of the best team to join";["summary"]="\
Returns team with least players ";};["exists"]={["class"]="function";["classForced"]=true;["description"]="\
Returns whether or not the team exists";["fname"]="exists";["library"]="team";["name"]="team_library.exists";["param"]={[1]="ind";["ind"]="Index of the team";};["realm"]="sh";["ret"]="boolean";["summary"]="\
Returns whether or not the team exists ";};["getAllTeams"]={["class"]="function";["description"]="\
Returns a table containing team information";["fname"]="getAllTeams";["library"]="team";["name"]="team_library.getAllTeams";["param"]={};["private"]=false;["realm"]="sh";["ret"]="table containing team information";["summary"]="\
Returns a table containing team information ";};["getColor"]={["class"]="function";["description"]="\
Returns the color of a team";["fname"]="getColor";["library"]="team";["name"]="team_library.getColor";["param"]={[1]="ind";["ind"]="Index of the team";};["private"]=false;["realm"]="sh";["ret"]="Color of the team";["summary"]="\
Returns the color of a team ";};["getJoinable"]={["class"]="function";["classForced"]=true;["description"]="\
Returns whether or not a team can be joined";["fname"]="getJoinable";["library"]="team";["name"]="team_library.getJoinable";["param"]={[1]="ind";["ind"]="Index of the team";};["realm"]="sh";["ret"]="boolean";["summary"]="\
Returns whether or not a team can be joined ";};["getName"]={["class"]="function";["classForced"]=true;["description"]="\
Returns the name of a team";["fname"]="getName";["library"]="team";["name"]="team_library.getName";["param"]={[1]="ind";["ind"]="Index of the team";};["realm"]="sh";["ret"]="String name of the team";["summary"]="\
Returns the name of a team ";};["getNumDeaths"]={["class"]="function";["classForced"]=true;["description"]="\
Returns number of deaths of all players on a team";["fname"]="getNumDeaths";["library"]="team";["name"]="team_library.getNumDeaths";["param"]={[1]="ind";["ind"]="Index of the team";};["realm"]="sh";["ret"]="number of deaths";["summary"]="\
Returns number of deaths of all players on a team ";};["getNumFrags"]={["class"]="function";["classForced"]=true;["description"]="\
Returns number of frags of all players on a team";["fname"]="getNumFrags";["library"]="team";["name"]="team_library.getNumFrags";["param"]={[1]="ind";["ind"]="Index of the team";};["realm"]="sh";["ret"]="number of frags";["summary"]="\
Returns number of frags of all players on a team ";};["getNumPlayers"]={["class"]="function";["classForced"]=true;["description"]="\
Returns number of players on a team";["fname"]="getNumPlayers";["library"]="team";["name"]="team_library.getNumPlayers";["param"]={[1]="ind";["ind"]="Index of the team";};["realm"]="sh";["ret"]="number of players";["summary"]="\
Returns number of players on a team ";};["getPlayers"]={["class"]="function";["description"]="\
Returns the table of players on a team";["fname"]="getPlayers";["library"]="team";["name"]="team_library.getPlayers";["param"]={[1]="ind";["ind"]="Index of the team";};["private"]=false;["realm"]="sh";["ret"]="Table of players";["summary"]="\
Returns the table of players on a team ";};["getScore"]={["class"]="function";["classForced"]=true;["description"]="\
Returns the score of a team";["fname"]="getScore";["library"]="team";["name"]="team_library.getScore";["param"]={[1]="ind";["ind"]="Index of the team";};["realm"]="sh";["ret"]="Number score of the team";["summary"]="\
Returns the score of a team ";};};["libtbl"]="team_library";["name"]="team";["server"]=true;["summary"]="\
Library for retreiving information about teams ";["tables"]={};};["timer"]={["class"]="library";["client"]=true;["description"]="\
Deals with time and timers.";["fields"]={};["functions"]={[1]="adjust";[10]="repsleft";[11]="simple";[12]="start";[13]="stop";[14]="systime";[15]="timeleft";[16]="toggle";[17]="unpause";[2]="create";[3]="curtime";[4]="exists";[5]="frametime";[6]="getTimersLeft";[7]="pause";[8]="realtime";[9]="remove";["adjust"]={["class"]="function";["description"]="\
Adjusts a timer";["fname"]="adjust";["library"]="timer";["name"]="timer_library.adjust";["param"]={[1]="name";[2]="delay";[3]="reps";[4]="func";["delay"]="The time, in seconds, to set the timer to.";["func"]="The function to call when the tiemr is fired";["name"]="The timer name";["reps"]="The repititions of the tiemr. 0 = infinte, nil = 1";};["private"]=false;["realm"]="sh";["ret"]="true if succeeded";["summary"]="\
Adjusts a timer ";};["create"]={["class"]="function";["description"]="\
Creates (and starts) a timer";["fname"]="create";["library"]="timer";["name"]="timer_library.create";["param"]={[1]="name";[2]="delay";[3]="reps";[4]="func";[5]="simple";["delay"]="The time, in seconds, to set the timer to.";["func"]="The function to call when the timer is fired";["name"]="The timer name";["reps"]="The repititions of the tiemr. 0 = infinte, nil = 1";};["private"]=false;["realm"]="sh";["summary"]="\
Creates (and starts) a timer ";};["curtime"]={["class"]="function";["description"]="\
Returns the uptime of the server in seconds (to at least 4 decimal places)";["fname"]="curtime";["library"]="timer";["name"]="timer_library.curtime";["param"]={};["private"]=false;["realm"]="sh";["summary"]="\
Returns the uptime of the server in seconds (to at least 4 decimal places) ";};["exists"]={["class"]="function";["description"]="\
Checks if a timer exists";["fname"]="exists";["library"]="timer";["name"]="timer_library.exists";["param"]={[1]="name";["name"]="The timer name";};["private"]=false;["realm"]="sh";["ret"]="bool if the timer exists";["summary"]="\
Checks if a timer exists ";};["frametime"]={["class"]="function";["description"]="\
Returns time between frames on client and ticks on server. Same thing as G.FrameTime in GLua";["fname"]="frametime";["library"]="timer";["name"]="timer_library.frametime";["param"]={};["private"]=false;["realm"]="sh";["summary"]="\
Returns time between frames on client and ticks on server.";};["getTimersLeft"]={["class"]="function";["description"]="\
Returns number of available timers";["fname"]="getTimersLeft";["library"]="timer";["name"]="timer_library.getTimersLeft";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Number of available timers";["summary"]="\
Returns number of available timers ";};["pause"]={["class"]="function";["description"]="\
Pauses a timer";["fname"]="pause";["library"]="timer";["name"]="timer_library.pause";["param"]={[1]="name";["name"]="The timer name";};["private"]=false;["realm"]="sh";["ret"]="false if the timer didn't exist or was already paused, true otherwise.";["summary"]="\
Pauses a timer ";};["realtime"]={["class"]="function";["description"]="\
Returns the uptime of the game/server in seconds (to at least 4 decimal places)";["fname"]="realtime";["library"]="timer";["name"]="timer_library.realtime";["param"]={};["private"]=false;["realm"]="sh";["summary"]="\
Returns the uptime of the game/server in seconds (to at least 4 decimal places) ";};["remove"]={["class"]="function";["description"]="\
Stops and removes the timer.";["fname"]="remove";["library"]="timer";["name"]="timer_library.remove";["param"]={[1]="name";["name"]="The timer name";};["private"]=false;["realm"]="sh";["summary"]="\
Stops and removes the timer.";};["repsleft"]={["class"]="function";["description"]="\
Returns amount of repetitions/executions left before the timer destroys itself.";["fname"]="repsleft";["library"]="timer";["name"]="timer_library.repsleft";["param"]={[1]="name";[2]="The";["The"]="timer name";};["private"]=false;["realm"]="sh";["ret"]="The amount of executions left. Nil if timer doesnt exist";["summary"]="\
Returns amount of repetitions/executions left before the timer destroys itself.";};["simple"]={["class"]="function";["description"]="\
Creates a simple timer, has no name, can't be stopped, paused, or destroyed.";["fname"]="simple";["library"]="timer";["name"]="timer_library.simple";["param"]={[1]="delay";[2]="func";["delay"]="the time, in second, to set the timer to";["func"]="the function to call when the timer is fired";};["private"]=false;["realm"]="sh";["summary"]="\
Creates a simple timer, has no name, can't be stopped, paused, or destroyed.";};["start"]={["class"]="function";["description"]="\
Starts a timer";["fname"]="start";["library"]="timer";["name"]="timer_library.start";["param"]={[1]="name";["name"]="The timer name";};["private"]=false;["realm"]="sh";["ret"]="true if the timer exists, false if it doesn't.";["summary"]="\
Starts a timer ";};["stop"]={["class"]="function";["description"]="\
Stops a timer";["fname"]="stop";["library"]="timer";["name"]="timer_library.stop";["param"]={[1]="name";["name"]="The timer name";};["private"]=false;["realm"]="sh";["ret"]="false if the timer didn't exist or was already stopped, true otherwise.";["summary"]="\
Stops a timer ";};["systime"]={["class"]="function";["description"]="\
Returns a highly accurate time in seconds since the start up, ideal for benchmarking.";["fname"]="systime";["library"]="timer";["name"]="timer_library.systime";["param"]={};["private"]=false;["realm"]="sh";["summary"]="\
Returns a highly accurate time in seconds since the start up, ideal for benchmarking.";};["timeleft"]={["class"]="function";["description"]="\
Returns amount of time left (in seconds) before the timer executes its function.";["fname"]="timeleft";["library"]="timer";["name"]="timer_library.timeleft";["param"]={[1]="name";[2]="The";["The"]="timer name";};["private"]=false;["realm"]="sh";["ret"]="The amount of time left (in seconds). If the timer is paused, the amount will be negative. Nil if timer doesnt exist";["summary"]="\
Returns amount of time left (in seconds) before the timer executes its function.";};["toggle"]={["class"]="function";["description"]="\
Runs either timer.pause or timer.unpause based on the timer's current status.";["fname"]="toggle";["library"]="timer";["name"]="timer_library.toggle";["param"]={[1]="name";["name"]="The timer name";};["private"]=false;["realm"]="sh";["ret"]="status of the timer.";["summary"]="\
Runs either timer.pause or timer.unpause based on the timer's current status.";};["unpause"]={["class"]="function";["description"]="\
Unpauses a timer";["fname"]="unpause";["library"]="timer";["name"]="timer_library.unpause";["param"]={[1]="name";["name"]="The timer name";};["private"]=false;["realm"]="sh";["ret"]="false if the timer didn't exist or was already running, true otherwise.";["summary"]="\
Unpauses a timer ";};};["libtbl"]="timer_library";["name"]="timer";["server"]=true;["summary"]="\
Deals with time and timers.";["tables"]={};};["trace"]={["class"]="library";["client"]=true;["description"]="\
Provides functions for doing line/AABB traces";["field"]={[1]="MAT_ANTLION";[10]="MAT_METAL";[11]="MAT_SAND";[12]="MAT_FOLIAGE";[13]="MAT_COMPUTER";[14]="MAT_SLOSH";[15]="MAT_TILE";[16]="MAT_GRASS";[17]="MAT_VENT";[18]="MAT_WOOD";[19]="MAT_DEFAULT";[2]="MAT_BLOODYFLESH";[20]="MAT_GLASS";[21]="HITGROUP_GENERIC";[22]="HITGROUP_HEAD";[23]="HITGROUP_CHEST";[24]="HITGROUP_STOMACH";[25]="HITGROUP_LEFTARM";[26]="HITGROUP_RIGHTARM";[27]="HITGROUP_LEFTLEG";[28]="HITGROUP_RIGHTLEG";[29]="HITGROUP_GEAR";[3]="MAT_CONCRETE";[30]="MASK_SPLITAREAPORTAL";[31]="MASK_SOLID_BRUSHONLY";[32]="MASK_WATER";[33]="MASK_BLOCKLOS";[34]="MASK_OPAQUE";[35]="MASK_VISIBLE";[36]="MASK_DEADSOLID";[37]="MASK_PLAYERSOLID_BRUSHONLY";[38]="MASK_NPCWORLDSTATIC";[39]="MASK_NPCSOLID_BRUSHONLY";[4]="MAT_DIRT";[40]="MASK_CURRENT";[41]="MASK_SHOT_PORTAL";[42]="MASK_SOLID";[43]="MASK_BLOCKLOS_AND_NPCS";[44]="MASK_OPAQUE_AND_NPCS";[45]="MASK_VISIBLE_AND_NPCS";[46]="MASK_PLAYERSOLID";[47]="MASK_NPCSOLID";[48]="MASK_SHOT_HULL";[49]="MASK_SHOT";[5]="MAT_FLESH";[50]="MASK_ALL";[51]="CONTENTS_EMPTY";[52]="CONTENTS_SOLID";[53]="CONTENTS_WINDOW";[54]="CONTENTS_AUX";[55]="CONTENTS_GRATE";[56]="CONTENTS_SLIME";[57]="CONTENTS_WATER";[58]="CONTENTS_BLOCKLOS";[59]="CONTENTS_OPAQUE";[6]="MAT_GRATE";[60]="CONTENTS_TESTFOGVOLUME";[61]="CONTENTS_TEAM4";[62]="CONTENTS_TEAM3";[63]="CONTENTS_TEAM1";[64]="CONTENTS_TEAM2";[65]="CONTENTS_IGNORE_NODRAW_OPAQUE";[66]="CONTENTS_MOVEABLE";[67]="CONTENTS_AREAPORTAL";[68]="CONTENTS_PLAYERCLIP";[69]="CONTENTS_MONSTERCLIP";[7]="MAT_ALIENFLESH";[70]="CONTENTS_CURRENT_0";[71]="CONTENTS_CURRENT_90";[72]="CONTENTS_CURRENT_180";[73]="CONTENTS_CURRENT_270";[74]="CONTENTS_CURRENT_UP";[75]="CONTENTS_CURRENT_DOWN";[76]="CONTENTS_ORIGIN";[77]="CONTENTS_MONSTER";[78]="CONTENTS_DEBRIS";[79]="CONTENTS_DETAIL";[8]="MAT_CLIP";[80]="CONTENTS_TRANSLUCENT";[81]="CONTENTS_LADDER";[82]="CONTENTS_HITBOX";[9]="MAT_PLASTIC";["CONTENTS_AREAPORTAL"]="";["CONTENTS_AUX"]="";["CONTENTS_BLOCKLOS"]="";["CONTENTS_CURRENT_0"]="";["CONTENTS_CURRENT_180"]="";["CONTENTS_CURRENT_270"]="";["CONTENTS_CURRENT_90"]="";["CONTENTS_CURRENT_DOWN"]="";["CONTENTS_CURRENT_UP"]="";["CONTENTS_DEBRIS"]="";["CONTENTS_DETAIL"]="";["CONTENTS_EMPTY"]="";["CONTENTS_GRATE"]="";["CONTENTS_HITBOX"]="";["CONTENTS_IGNORE_NODRAW_OPAQUE"]="";["CONTENTS_LADDER"]="";["CONTENTS_MONSTER"]="";["CONTENTS_MONSTERCLIP"]="";["CONTENTS_MOVEABLE"]="";["CONTENTS_OPAQUE"]="";["CONTENTS_ORIGIN"]="";["CONTENTS_PLAYERCLIP"]="";["CONTENTS_SLIME"]="";["CONTENTS_SOLID"]="";["CONTENTS_TEAM1"]="";["CONTENTS_TEAM2"]="";["CONTENTS_TEAM3"]="";["CONTENTS_TEAM4"]="";["CONTENTS_TESTFOGVOLUME"]="";["CONTENTS_TRANSLUCENT"]="";["CONTENTS_WATER"]="";["CONTENTS_WINDOW"]="";["HITGROUP_CHEST"]="";["HITGROUP_GEAR"]="";["HITGROUP_GENERIC"]="";["HITGROUP_HEAD"]="";["HITGROUP_LEFTARM"]="";["HITGROUP_LEFTLEG"]="";["HITGROUP_RIGHTARM"]="";["HITGROUP_RIGHTLEG"]="";["HITGROUP_STOMACH"]="";["MASK_ALL"]="";["MASK_BLOCKLOS"]="";["MASK_BLOCKLOS_AND_NPCS"]="";["MASK_CURRENT"]="";["MASK_DEADSOLID"]="";["MASK_NPCSOLID"]="";["MASK_NPCSOLID_BRUSHONLY"]="";["MASK_NPCWORLDSTATIC"]="";["MASK_OPAQUE"]="";["MASK_OPAQUE_AND_NPCS"]="";["MASK_PLAYERSOLID"]="";["MASK_PLAYERSOLID_BRUSHONLY"]="";["MASK_SHOT"]="";["MASK_SHOT_HULL"]="";["MASK_SHOT_PORTAL"]="";["MASK_SOLID"]="";["MASK_SOLID_BRUSHONLY"]="";["MASK_SPLITAREAPORTAL"]="";["MASK_VISIBLE"]="";["MASK_VISIBLE_AND_NPCS"]="";["MASK_WATER"]="";["MAT_ALIENFLESH"]="";["MAT_ANTLION"]="";["MAT_BLOODYFLESH"]="";["MAT_CLIP"]="";["MAT_COMPUTER"]="";["MAT_CONCRETE"]="";["MAT_DEFAULT"]="";["MAT_DIRT"]="";["MAT_FLESH"]="";["MAT_FOLIAGE"]="";["MAT_GLASS"]="";["MAT_GRASS"]="";["MAT_GRATE"]="";["MAT_METAL"]="";["MAT_PLASTIC"]="";["MAT_SAND"]="";["MAT_SLOSH"]="";["MAT_TILE"]="";["MAT_VENT"]="";["MAT_WOOD"]="";};["fields"]={};["functions"]={[1]="trace";[2]="traceHull";["trace"]={["class"]="function";["description"]="\
Does a line trace";["fname"]="trace";["library"]="trace";["name"]="trace_library.trace";["param"]={[1]="start";[2]="endpos";[3]="filter";[4]="mask";[5]="colgroup";[6]="ignworld";["colgroup"]="The collision group of the trace";["endpos"]="End position";["filter"]="Entity/array of entities to filter, or a function callback with an entity arguement that returns whether the trace should hit";["ignworld"]="Whether the trace should ignore world";["mask"]="Trace mask";["start"]="Start position";};["private"]=false;["realm"]="sh";["ret"]="Result of the trace https://wiki.garrysmod.com/page/Structures/TraceResult";["summary"]="\
Does a line trace ";};["traceHull"]={["class"]="function";["description"]="\
Does a swept-AABB trace";["fname"]="traceHull";["library"]="trace";["name"]="trace_library.traceHull";["param"]={[1]="start";[2]="endpos";[3]="minbox";[4]="maxbox";[5]="filter";[6]="mask";[7]="colgroup";[8]="ignworld";["colgroup"]="The collision group of the trace";["endpos"]="End position";["filter"]="Entity/array of entities to filter, or a function callback with an entity arguement that returns whether the trace should hit";["ignworld"]="Whether the trace should ignore world";["mask"]="Trace mask";["maxbox"]="Upper box corner";["minbox"]="Lower box corner";["start"]="Start position";};["private"]=false;["realm"]="sh";["ret"]="Result of the trace https://wiki.garrysmod.com/page/Structures/TraceResult";["summary"]="\
Does a swept-AABB trace ";};};["libtbl"]="trace_library";["name"]="trace";["server"]=true;["summary"]="\
Provides functions for doing line/AABB traces ";["tables"]={};};["von"]={["class"]="library";["client"]=true;["description"]="\
vON Library";["fields"]={};["functions"]={[1]="deserialize";[2]="serialize";["deserialize"]={["class"]="function";["classForced"]=true;["client"]=true;["description"]="\
Deserialize a string";["fname"]="deserialize";["library"]="von";["name"]="von.deserialize";["param"]={[1]="str";["str"]="String to deserialize";};["realm"]="sh";["ret"]="Table";["server"]=true;["summary"]="\
Deserialize a string ";};["serialize"]={["class"]="function";["classForced"]=true;["client"]=true;["description"]="\
Serialize a table";["fname"]="serialize";["library"]="von";["name"]="von.serialize";["param"]={[1]="tbl";["tbl"]="Table to serialize";};["realm"]="sh";["ret"]="String";["server"]=true;["summary"]="\
Serialize a table ";};};["libtbl"]="von";["name"]="von";["server"]=true;["summary"]="\
vON Library ";["tables"]={};};["wire"]={["class"]="library";["description"]="\
Wire library. Handles wire inputs/outputs, wirelinks, etc.";["fields"]={};["functions"]={[1]="adjustInputs";[2]="adjustOutputs";[3]="create";[4]="delete";[5]="getInputs";[6]="getOutputs";[7]="getWirelink";[8]="self";[9]="serverUUID";["adjustInputs"]={["class"]="function";["description"]="\
Creates/Modifies wire inputs. All wire ports must begin with an uppercase \
letter and contain only alphabetical characters.";["fname"]="adjustInputs";["library"]="wire";["name"]="wire_library.adjustInputs";["param"]={[1]="names";[2]="types";["names"]="An array of input names. May be modified by the function.";["types"]="An array of input types. Can be shortcuts. May be modified by the function.";};["private"]=false;["realm"]="sv";["summary"]="\
Creates/Modifies wire inputs.";};["adjustOutputs"]={["class"]="function";["description"]="\
Creates/Modifies wire outputs. All wire ports must begin with an uppercase \
letter and contain only alphabetical characters.";["fname"]="adjustOutputs";["library"]="wire";["name"]="wire_library.adjustOutputs";["param"]={[1]="names";[2]="types";["names"]="An array of output names. May be modified by the function.";["types"]="An array of output types. Can be shortcuts. May be modified by the function.";};["private"]=false;["realm"]="sv";["summary"]="\
Creates/Modifies wire outputs.";};["create"]={["class"]="function";["description"]="\
Wires two entities together";["fname"]="create";["library"]="wire";["name"]="wire_library.create";["param"]={[1]="entI";[2]="entO";[3]="inputname";[4]="outputname";["entI"]="Entity with input";["entO"]="Entity with output";["inputname"]="Input to be wired";["outputname"]="Output to be wired";};["private"]=false;["realm"]="sv";["summary"]="\
Wires two entities together ";};["delete"]={["class"]="function";["description"]="\
Unwires an entity's input";["fname"]="delete";["library"]="wire";["name"]="wire_library.delete";["param"]={[1]="entI";[2]="inputname";["entI"]="Entity with input";["inputname"]="Input to be un-wired";};["private"]=false;["realm"]="sv";["summary"]="\
Unwires an entity's input ";};["getInputs"]={["class"]="function";["description"]="\
Returns a table of entity's inputs";["fname"]="getInputs";["library"]="wire";["name"]="wire_library.getInputs";["param"]={[1]="entI";["entI"]="Entity with input(s)";};["private"]=false;["realm"]="sv";["ret"]="Table of entity's inputs";["summary"]="\
Returns a table of entity's inputs ";};["getOutputs"]={["class"]="function";["description"]="\
Returns a table of entity's outputs";["fname"]="getOutputs";["library"]="wire";["name"]="wire_library.getOutputs";["param"]={[1]="entO";["entO"]="Entity with output(s)";};["private"]=false;["realm"]="sv";["ret"]="Table of entity's outputs";["summary"]="\
Returns a table of entity's outputs ";};["getWirelink"]={["class"]="function";["description"]="\
Returns a wirelink to a wire entity";["fname"]="getWirelink";["library"]="wire";["name"]="wire_library.getWirelink";["param"]={[1]="ent";["ent"]="Wire entity";};["private"]=false;["realm"]="sv";["ret"]="Wirelink of the entity";["summary"]="\
Returns a wirelink to a wire entity ";};["self"]={["class"]="function";["description"]="\
Returns the wirelink representing this entity.";["fname"]="self";["library"]="wire";["name"]="wire_library.self";["param"]={};["private"]=false;["realm"]="sv";["summary"]="\
Returns the wirelink representing this entity.";};["serverUUID"]={["class"]="function";["description"]="\
Returns the server's UUID.";["fname"]="serverUUID";["library"]="wire";["name"]="wire_library.serverUUID";["param"]={};["private"]=false;["realm"]="sv";["ret"]="UUID as string";["summary"]="\
Returns the server's UUID.";};};["libtbl"]="wire_library";["name"]="wire";["summary"]="\
Wire library.";["tables"]={[1]="ports";["ports"]={["class"]="table";["classForced"]=true;["description"]="\
Ports table. Reads from this table will read from the wire input \
of the same name. Writes will write to the wire output of the same name.";["library"]="wire";["name"]="wire_library.ports";["param"]={};["summary"]="\
Ports table.";["tname"]="ports";};};};};};