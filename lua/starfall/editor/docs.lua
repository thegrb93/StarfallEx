SF.Docs={["classes"]={[1]="Angle";[10]="Mesh";[11]="Npc";[12]="Particle";[13]="PhysObj";[14]="Player";[15]="Quaternion";[16]="Sound";[17]="StringStream";[18]="VMatrix";[19]="Vector";[2]="Bass";[20]="Vehicle";[21]="Weapon";[22]="Wirelink";[3]="Color";[4]="Effect";[5]="Entity";[6]="File";[7]="Hologram";[8]="Light";[9]="Material";["Angle"]={["class"]="class";["client"]=true;["description"]="\
Angle Type";["fields"]={};["methods"]={[1]="clone";[10]="setP";[11]="setR";[12]="setY";[13]="setZero";[2]="getForward";[3]="getNormalized";[4]="getRight";[5]="getUp";[6]="isZero";[7]="normalize";[8]="rotateAroundAxis";[9]="set";["clone"]={["class"]="function";["classlib"]="Angle";["description"]="\
Copies p,y,r from angle and returns a new angle";["fname"]="clone";["name"]="ang_methods:clone";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The copy of the angle";["summary"]="\
Copies p,y,r from angle and returns a new angle ";};["getForward"]={["class"]="function";["classlib"]="Angle";["description"]="\
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
Copies p,y,r from angle to another.";["fname"]="set";["name"]="ang_methods:set";["param"]={[1]="b";["b"]="The angle to copy from.";};["private"]=false;["realm"]="sh";["ret"]="nil";["summary"]="\
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
For playing music there is `Bass` type. You can pause and set current playback time in it. If you're looking to apply DSP effects on present game sounds, use `Sound` instead.";["fields"]={};["methods"]={[1]="destroy";[10]="setFade";[11]="setLooping";[12]="setPitch";[13]="setPos";[14]="setTime";[15]="setVolume";[16]="stop";[2]="getFFT";[3]="getLength";[4]="getLevels";[5]="getTime";[6]="isOnline";[7]="isValid";[8]="pause";[9]="play";["destroy"]={["class"]="function";["classlib"]="Bass";["description"]="\
Removes the sound from the game so new one can be created if limit is reached";["fname"]="destroy";["name"]="bass_methods:destroy";["param"]={};["private"]=false;["realm"]="cl";["summary"]="\
Removes the sound from the game so new one can be created if limit is reached ";};["getFFT"]={["class"]="function";["classlib"]="Bass";["description"]="\
Perform fast Fourier transform algorithm to compute the DFT of the sound channel.";["fname"]="getFFT";["name"]="bass_methods:getFFT";["param"]={[1]="n";["n"]="Number of consecutive audio samples, between 0 and 7. Depending on this parameter you will get 256*2^n samples.";};["private"]=false;["realm"]="cl";["ret"]="Table containing DFT magnitudes, each between 0 and 1.";["summary"]="\
Perform fast Fourier transform algorithm to compute the DFT of the sound channel.";};["getLength"]={["class"]="function";["classlib"]="Bass";["description"]="\
Gets the length of a sound channel.";["fname"]="getLength";["name"]="bass_methods:getLength";["param"]={};["private"]=false;["realm"]="cl";["ret"]="Sound channel length in seconds.";["summary"]="\
Gets the length of a sound channel.";};["getLevels"]={["class"]="function";["classlib"]="Bass";["description"]="\
Gets the left and right levels of the audio channel";["fname"]="getLevels";["name"]="bass_methods:getLevels";["param"]={};["private"]=false;["realm"]="cl";["ret"]={[1]="The left sound level, a value between 0 and 1.";[2]="The right sound level, a value between 0 and 1.";};["summary"]="\
Gets the left and right levels of the audio channel ";};["getTime"]={["class"]="function";["classlib"]="Bass";["description"]="\
Gets the current playback time of the sound channel. Requires the 'noblock' flag";["fname"]="getTime";["name"]="bass_methods:getTime";["param"]={};["private"]=false;["realm"]="cl";["ret"]="Sound channel playback time in seconds.";["summary"]="\
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
Sets whether the sound channel should loop. Requires the 'noblock' flag";["fname"]="setLooping";["name"]="bass_methods:setLooping";["param"]={[1]="loop";["loop"]="Boolean of whether the sound channel should loop.";};["private"]=false;["realm"]="cl";["summary"]="\
Sets whether the sound channel should loop.";};["setPitch"]={["class"]="function";["classlib"]="Bass";["description"]="\
Sets the pitch of the sound channel.";["fname"]="setPitch";["name"]="bass_methods:setPitch";["param"]={[1]="pitch";["pitch"]="Pitch to set to, between 0 and 3.";};["private"]=false;["realm"]="cl";["summary"]="\
Sets the pitch of the sound channel.";};["setPos"]={["class"]="function";["classlib"]="Bass";["description"]="\
Sets the position of the sound in 3D space. Must have `3d` flag to get this work on.";["fname"]="setPos";["name"]="bass_methods:setPos";["param"]={[1]="pos";["pos"]="Where to position the sound.";};["private"]=false;["realm"]="cl";["summary"]="\
Sets the position of the sound in 3D space.";};["setTime"]={["class"]="function";["classlib"]="Bass";["description"]="\
Sets the current playback time of the sound channel. Requires the 'noblock' flag";["fname"]="setTime";["name"]="bass_methods:setTime";["param"]={[1]="time";["time"]="Sound channel playback time in seconds.";};["private"]=false;["realm"]="cl";["summary"]="\
Sets the current playback time of the sound channel.";};["setVolume"]={["class"]="function";["classlib"]="Bass";["description"]="\
Sets the volume of the sound channel.";["fname"]="setVolume";["name"]="bass_methods:setVolume";["param"]={[1]="vol";["vol"]="Volume multiplier (1 is normal), between 0x and 10x.";};["private"]=false;["realm"]="cl";["summary"]="\
Sets the volume of the sound channel.";};["stop"]={["class"]="function";["classlib"]="Bass";["description"]="\
Stops playing the sound.";["fname"]="stop";["name"]="bass_methods:stop";["param"]={};["private"]=false;["realm"]="cl";["summary"]="\
Stops playing the sound.";};};["name"]="Bass";["summary"]="\
For playing music there is `Bass` type.";["typtbl"]="bass_methods";};["Color"]={["class"]="class";["client"]=true;["description"]="\
Color type";["fields"]={};["methods"]={[1]="clone";[2]="hsvToRGB";[3]="rgbToHSV";[4]="set";[5]="setA";[6]="setB";[7]="setG";[8]="setR";["clone"]={["class"]="function";["classlib"]="Color";["description"]="\
Copies r,g,b,a from color and returns a new color";["fname"]="clone";["name"]="color_methods:clone";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The copy of the color";["summary"]="\
Copies r,g,b,a from color and returns a new color ";};["hsvToRGB"]={["class"]="function";["classlib"]="Color";["client"]=true;["description"]="\
Converts the color from HSV to RGB.";["fname"]="hsvToRGB";["name"]="color_methods:hsvToRGB";["param"]={};["private"]=false;["realm"]="sh";["ret"]="A triplet of numbers representing HSV.";["server"]=true;["summary"]="\
Converts the color from HSV to RGB.";};["rgbToHSV"]={["class"]="function";["classlib"]="Color";["client"]=true;["description"]="\
Converts the color from RGB to HSV.";["fname"]="rgbToHSV";["name"]="color_methods:rgbToHSV";["param"]={};["private"]=false;["realm"]="sh";["ret"]="A triplet of numbers representing HSV.";["server"]=true;["summary"]="\
Converts the color from RGB to HSV.";};["set"]={["class"]="function";["classlib"]="Color";["description"]="\
Copies r,g,b,a from color to another.";["fname"]="set";["name"]="color_methods:set";["param"]={[1]="b";["b"]="The color to copy from.";};["private"]=false;["realm"]="sh";["ret"]="nil";["summary"]="\
Copies r,g,b,a from color to another.";};["setA"]={["class"]="function";["classlib"]="Color";["description"]="\
Set's the color's alpha and returns it.";["fname"]="setA";["name"]="color_methods:setA";["param"]={[1]="a";["a"]="The alpha";};["private"]=false;["realm"]="sh";["ret"]="The modified color";["summary"]="\
Set's the color's alpha and returns it.";};["setB"]={["class"]="function";["classlib"]="Color";["description"]="\
Set's the color's blue and returns it.";["fname"]="setB";["name"]="color_methods:setB";["param"]={[1]="b";["b"]="The blue";};["private"]=false;["realm"]="sh";["ret"]="The modified color";["summary"]="\
Set's the color's blue and returns it.";};["setG"]={["class"]="function";["classlib"]="Color";["description"]="\
Set's the color's green and returns it.";["fname"]="setG";["name"]="color_methods:setG";["param"]={[1]="g";["g"]="The green";};["private"]=false;["realm"]="sh";["ret"]="The modified color";["summary"]="\
Set's the color's green and returns it.";};["setR"]={["class"]="function";["classlib"]="Color";["description"]="\
Set's the color's red channel and returns it.";["fname"]="setR";["name"]="color_methods:setR";["param"]={[1]="r";["r"]="The red";};["private"]=false;["realm"]="sh";["ret"]="The modified color";["summary"]="\
Set's the color's red channel and returns it.";};};["name"]="Color";["server"]=true;["summary"]="\
Color type ";["typtbl"]="color_methods";};["Effect"]={["class"]="class";["client"]=true;["description"]="\
Effect type";["fields"]={};["methods"]={[1]="getAngles";[10]="getMaterialIndex";[11]="getNormal";[12]="getOrigin";[13]="getRadius";[14]="getScale";[15]="getStart";[16]="getSurfaceProp";[17]="play";[18]="setAngles";[19]="setAttachment";[2]="getAttachment";[20]="setColor";[21]="setDamageType";[22]="setEntIndex";[23]="setEntity";[24]="setFlags";[25]="setHitBox";[26]="setMagnitude";[27]="setMaterialIndex";[28]="setNormal";[29]="setOrigin";[3]="getColor";[30]="setRadius";[31]="setScale";[32]="setStart";[33]="setSurfaceProp";[4]="getDamageType";[5]="getEntIndex";[6]="getEntity";[7]="getFlags";[8]="getHitBox";[9]="getMagnitude";["getAngles"]={["class"]="function";["classlib"]="Effect";["description"]="\
Returns the effect's angle";["fname"]="getAngles";["name"]="effect_methods:getAngles";["param"]={};["private"]=false;["realm"]="sh";["ret"]="the effect's angle";["summary"]="\
Returns the effect's angle ";};["getAttachment"]={["class"]="function";["classlib"]="Effect";["description"]="\
Returns the effect's attachment";["fname"]="getAttachment";["name"]="effect_methods:getAttachment";["param"]={};["private"]=false;["realm"]="sh";["ret"]="the effect's attachment";["summary"]="\
Returns the effect's attachment ";};["getColor"]={["class"]="function";["classlib"]="Effect";["description"]="\
Returns the effect's color";["fname"]="getColor";["name"]="effect_methods:getColor";["param"]={};["private"]=false;["realm"]="sh";["ret"]="the effect's color";["summary"]="\
Returns the effect's color ";};["getDamageType"]={["class"]="function";["classlib"]="Effect";["description"]="\
Returns the effect's damagetype";["fname"]="getDamageType";["name"]="effect_methods:getDamageType";["param"]={};["private"]=false;["realm"]="sh";["ret"]="the effect's damagetype";["summary"]="\
Returns the effect's damagetype ";};["getEntIndex"]={["class"]="function";["classlib"]="Effect";["description"]="\
Returns the effect's entindex";["fname"]="getEntIndex";["name"]="effect_methods:getEntIndex";["param"]={};["private"]=false;["realm"]="sh";["ret"]="the effect's entindex";["summary"]="\
Returns the effect's entindex ";};["getEntity"]={["class"]="function";["classlib"]="Effect";["description"]="\
Returns the effect's entity";["fname"]="getEntity";["name"]="effect_methods:getEntity";["param"]={};["private"]=false;["realm"]="sh";["ret"]="the effect's entity";["summary"]="\
Returns the effect's entity ";};["getFlags"]={["class"]="function";["classlib"]="Effect";["description"]="\
Returns the effect's flags";["fname"]="getFlags";["name"]="effect_methods:getFlags";["param"]={};["private"]=false;["realm"]="sh";["ret"]="the effect's flags";["summary"]="\
Returns the effect's flags ";};["getHitBox"]={["class"]="function";["classlib"]="Effect";["description"]="\
Returns the effect's hitbox";["fname"]="getHitBox";["name"]="effect_methods:getHitBox";["param"]={};["private"]=false;["realm"]="sh";["ret"]="the effect's hitbox";["summary"]="\
Returns the effect's hitbox ";};["getMagnitude"]={["class"]="function";["classlib"]="Effect";["description"]="\
Returns the effect's magnitude";["fname"]="getMagnitude";["name"]="effect_methods:getMagnitude";["param"]={};["private"]=false;["realm"]="sh";["ret"]="the effect's magnitude";["summary"]="\
Returns the effect's magnitude ";};["getMaterialIndex"]={["class"]="function";["classlib"]="Effect";["description"]="\
Returns the effect's material index";["fname"]="getMaterialIndex";["name"]="effect_methods:getMaterialIndex";["param"]={};["private"]=false;["realm"]="sh";["ret"]="the effect's material index";["summary"]="\
Returns the effect's material index ";};["getNormal"]={["class"]="function";["classlib"]="Effect";["description"]="\
Returns the effect's normal";["fname"]="getNormal";["name"]="effect_methods:getNormal";["param"]={};["private"]=false;["realm"]="sh";["ret"]="the effect's normal";["summary"]="\
Returns the effect's normal ";};["getOrigin"]={["class"]="function";["classlib"]="Effect";["description"]="\
Returns the effect's origin";["fname"]="getOrigin";["name"]="effect_methods:getOrigin";["param"]={};["private"]=false;["realm"]="sh";["ret"]="the effect's origin";["summary"]="\
Returns the effect's origin ";};["getRadius"]={["class"]="function";["classlib"]="Effect";["description"]="\
Returns the effect's radius";["fname"]="getRadius";["name"]="effect_methods:getRadius";["param"]={};["private"]=false;["realm"]="sh";["ret"]="the effect's radius";["summary"]="\
Returns the effect's radius ";};["getScale"]={["class"]="function";["classlib"]="Effect";["description"]="\
Returns the effect's scale";["fname"]="getScale";["name"]="effect_methods:getScale";["param"]={};["private"]=false;["realm"]="sh";["ret"]="the effect's scale";["summary"]="\
Returns the effect's scale ";};["getStart"]={["class"]="function";["classlib"]="Effect";["description"]="\
Returns the effect's start position";["fname"]="getStart";["name"]="effect_methods:getStart";["param"]={};["private"]=false;["realm"]="sh";["ret"]="the effect's start position";["summary"]="\
Returns the effect's start position ";};["getSurfaceProp"]={["class"]="function";["classlib"]="Effect";["description"]="\
Returns the effect's surface prop";["fname"]="getSurfaceProp";["name"]="effect_methods:getSurfaceProp";["param"]={};["private"]=false;["realm"]="sh";["ret"]="the effect's surface prop";["summary"]="\
Returns the effect's surface prop ";};["play"]={["class"]="function";["classlib"]="Effect";["description"]="\
Plays the effect";["fname"]="play";["name"]="effect_methods:play";["param"]={[1]="eff";["eff"]="The effect type to play";};["private"]=false;["realm"]="sh";["summary"]="\
Plays the effect ";};["setAngles"]={["class"]="function";["classlib"]="Effect";["description"]="\
Sets the effect's angles";["fname"]="setAngles";["name"]="effect_methods:setAngles";["param"]={[1]="ang";["ang"]="The angles";};["private"]=false;["realm"]="sh";["summary"]="\
Sets the effect's angles ";};["setAttachment"]={["class"]="function";["classlib"]="Effect";["description"]="\
Sets the effect's attachment";["fname"]="setAttachment";["name"]="effect_methods:setAttachment";["param"]={[1]="attachment";["attachment"]="The attachment";};["private"]=false;["realm"]="sh";["summary"]="\
Sets the effect's attachment ";};["setColor"]={["class"]="function";["classlib"]="Effect";["description"]="\
Sets the effect's color";["fname"]="setColor";["name"]="effect_methods:setColor";["param"]={[1]="color";["color"]="The color represented by a byte 0-255. wtf?";};["private"]=false;["realm"]="sh";["summary"]="\
Sets the effect's color ";};["setDamageType"]={["class"]="function";["classlib"]="Effect";["description"]="\
Sets the effect's damage type";["fname"]="setDamageType";["name"]="effect_methods:setDamageType";["param"]={[1]="dmgtype";["dmgtype"]="The damage type";};["private"]=false;["realm"]="sh";["summary"]="\
Sets the effect's damage type ";};["setEntIndex"]={["class"]="function";["classlib"]="Effect";["description"]="\
Sets the effect's entity index";["fname"]="setEntIndex";["name"]="effect_methods:setEntIndex";["param"]={[1]="index";["index"]="The entity index";};["private"]=false;["realm"]="sh";["summary"]="\
Sets the effect's entity index ";};["setEntity"]={["class"]="function";["classlib"]="Effect";["description"]="\
Sets the effect's entity";["fname"]="setEntity";["name"]="effect_methods:setEntity";["param"]={[1]="ent";["ent"]="The entity";};["private"]=false;["realm"]="sh";["summary"]="\
Sets the effect's entity ";};["setFlags"]={["class"]="function";["classlib"]="Effect";["description"]="\
Sets the effect's flags";["fname"]="setFlags";["name"]="effect_methods:setFlags";["param"]={[1]="flags";["flags"]="The flags";};["private"]=false;["realm"]="sh";["summary"]="\
Sets the effect's flags ";};["setHitBox"]={["class"]="function";["classlib"]="Effect";["description"]="\
Sets the effect's hitbox";["fname"]="setHitBox";["name"]="effect_methods:setHitBox";["param"]={[1]="hitbox";["hitbox"]="The hitbox";};["private"]=false;["realm"]="sh";["summary"]="\
Sets the effect's hitbox ";};["setMagnitude"]={["class"]="function";["classlib"]="Effect";["description"]="\
Sets the effect's magnitude";["fname"]="setMagnitude";["name"]="effect_methods:setMagnitude";["param"]={[1]="magnitude";["magnitude"]="The magnitude";};["private"]=false;["realm"]="sh";["summary"]="\
Sets the effect's magnitude ";};["setMaterialIndex"]={["class"]="function";["classlib"]="Effect";["description"]="\
Sets the effect's material index";["fname"]="setMaterialIndex";["name"]="effect_methods:setMaterialIndex";["param"]={[1]="mat";["mat"]="The material index";};["private"]=false;["realm"]="sh";["summary"]="\
Sets the effect's material index ";};["setNormal"]={["class"]="function";["classlib"]="Effect";["description"]="\
Sets the effect's normal";["fname"]="setNormal";["name"]="effect_methods:setNormal";["param"]={[1]="normal";["normal"]="The vector normal";};["private"]=false;["realm"]="sh";["summary"]="\
Sets the effect's normal ";};["setOrigin"]={["class"]="function";["classlib"]="Effect";["description"]="\
Sets the effect's origin";["fname"]="setOrigin";["name"]="effect_methods:setOrigin";["param"]={[1]="origin";["origin"]="The vector origin";};["private"]=false;["realm"]="sh";["summary"]="\
Sets the effect's origin ";};["setRadius"]={["class"]="function";["classlib"]="Effect";["description"]="\
Sets the effect's radius";["fname"]="setRadius";["name"]="effect_methods:setRadius";["param"]={[1]="radius";["radius"]="The radius";};["private"]=false;["realm"]="sh";["summary"]="\
Sets the effect's radius ";};["setScale"]={["class"]="function";["classlib"]="Effect";["description"]="\
Sets the effect's scale";["fname"]="setScale";["name"]="effect_methods:setScale";["param"]={[1]="scale";["scale"]="The number scale";};["private"]=false;["realm"]="sh";["summary"]="\
Sets the effect's scale ";};["setStart"]={["class"]="function";["classlib"]="Effect";["description"]="\
Sets the effect's start";["fname"]="setStart";["name"]="effect_methods:setStart";["param"]={[1]="start";["start"]="The vector start";};["private"]=false;["realm"]="sh";["summary"]="\
Sets the effect's start ";};["setSurfaceProp"]={["class"]="function";["classlib"]="Effect";["description"]="\
Sets the effect's surface property";["fname"]="setSurfaceProp";["name"]="effect_methods:setSurfaceProp";["param"]={[1]="prop";["prop"]="The surface property";};["private"]=false;["realm"]="sh";["summary"]="\
Sets the effect's surface property ";};};["name"]="Effect";["server"]=true;["summary"]="\
Effect type ";["typtbl"]="effect_methods";};["Entity"]={["class"]="class";["classForced"]=true;["description"]="\
Entity type";["fields"]={};["methods"]={[1]="addAngleVelocity";[10]="enableDrag";[100]="setMass";[101]="setMaterial";[102]="setMesh";[103]="setMeshMaterial";[104]="setNoDraw";[105]="setNocollideAll";[106]="setParent";[107]="setPhysMaterial";[108]="setPos";[109]="setPose";[11]="enableGravity";[110]="setRenderBounds";[111]="setRenderFX";[112]="setRenderMode";[113]="setSkin";[114]="setSolid";[115]="setSubMaterial";[116]="setTrails";[117]="setUnbreakable";[118]="setVelocity";[119]="stopSound";[12]="enableMotion";[120]="testPVS";[121]="toHologram";[122]="translateBoneToPhysBone";[123]="translatePhysBoneToBone";[124]="unparent";[125]="worldToLocal";[126]="worldToLocalAngles";[13]="enableSphere";[14]="entIndex";[15]="extinguish";[16]="getAllConstrained";[17]="getAngleVelocity";[18]="getAngleVelocityAngle";[19]="getAngles";[2]="addCollisionListener";[20]="getAttachment";[21]="getAttachmentParent";[22]="getAttachments";[23]="getBoneCount";[24]="getBoneMatrix";[25]="getBoneName";[26]="getBoneParent";[27]="getBonePosition";[28]="getChildren";[29]="getChipName";[3]="applyAngForce";[30]="getClass";[31]="getColor";[32]="getEyeAngles";[33]="getEyePos";[34]="getFlexes";[35]="getForward";[36]="getHealth";[37]="getInertia";[38]="getLinkedComponents";[39]="getMass";[4]="applyDamage";[40]="getMassCenter";[41]="getMassCenterW";[42]="getMaterial";[43]="getMaterials";[44]="getMatrix";[45]="getMaxHealth";[46]="getModel";[47]="getOwner";[48]="getParent";[49]="getPhysMaterial";[5]="applyForceCenter";[50]="getPhysicsObject";[51]="getPhysicsObjectCount";[52]="getPhysicsObjectNum";[53]="getPos";[54]="getPose";[55]="getRight";[56]="getSkin";[57]="getSubMaterial";[58]="getUp";[59]="getVelocity";[6]="applyForceOffset";[60]="getWaterLevel";[61]="ignite";[62]="isFrozen";[63]="isNPC";[64]="isOnFire";[65]="isOnGround";[66]="isPlayer";[67]="isPlayerHolding";[68]="isValid";[69]="isValidPhys";[7]="applyTorque";[70]="isVehicle";[71]="isWeapon";[72]="isWeldedTo";[73]="linkComponent";[74]="localToWorld";[75]="localToWorldAngles";[76]="lookupAttachment";[77]="lookupBone";[78]="lookupSequence";[79]="manipulateBoneAngles";[8]="breakEnt";[80]="manipulateBonePosition";[81]="manipulateBoneScale";[82]="obbCenter";[83]="obbCenterW";[84]="obbMaxs";[85]="obbMins";[86]="obbSize";[87]="remove";[88]="removeCollisionListener";[89]="removeTrails";[9]="emitSound";[90]="sequenceDuration";[91]="setAngleVelocity";[92]="setAngles";[93]="setBodygroup";[94]="setColor";[95]="setDrawShadow";[96]="setFlexScale";[97]="setFlexWeight";[98]="setFrozen";[99]="setInertia";["addAngleVelocity"]={["class"]="function";["classlib"]="Entity";["description"]="\
Applys a angular velocity to an object";["fname"]="addAngleVelocity";["name"]="ents_methods:addAngleVelocity";["param"]={[1]="angvel";["angvel"]="The local angvel vector to apply";};["private"]=false;["realm"]="sv";["summary"]="\
Applys a angular velocity to an object ";};["addCollisionListener"]={["class"]="function";["classlib"]="Entity";["description"]="\
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
Plays a sound on the entity";["fname"]="emitSound";["name"]="ents_methods:emitSound";["param"]={[1]="snd";[2]="lvl";[3]="pitch";[4]="volume";[5]="channel";["channel"]="channel=CHAN_AUTO";["lvl"]="number soundLevel=75";["pitch"]="pitchPercent=100";["snd"]="string Sound path";["volume"]="volume=1";};["private"]=false;["realm"]="sh";["summary"]="\
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
Extinguishes an entity ";};["getAllConstrained"]={["class"]="function";["classlib"]="Entity";["description"]="\
Gets a table of all constrained entities to each other";["fname"]="getAllConstrained";["name"]="ents_methods:getAllConstrained";["param"]={[1]="filter";["filter"]="Optional constraint type filter table where keys are the type name and values are 'true'. \"Wire\" and \"Parent\" are used for wires and parents.";};["private"]=false;["realm"]="sv";["summary"]="\
Gets a table of all constrained entities to each other ";};["getAngleVelocity"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Returns the angular velocity of the entity";["fname"]="getAngleVelocity";["name"]="ents_methods:getAngleVelocity";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The angular velocity as a vector";["server"]=true;["summary"]="\
Returns the angular velocity of the entity ";};["getAngleVelocityAngle"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Returns the angular velocity of the entity";["fname"]="getAngleVelocityAngle";["name"]="ents_methods:getAngleVelocityAngle";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The angular velocity as an angle";["server"]=true;["summary"]="\
Returns the angular velocity of the entity ";};["getAngles"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Returns the angle of the entity";["fname"]="getAngles";["name"]="ents_methods:getAngles";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The angle";["server"]=true;["summary"]="\
Returns the angle of the entity ";};["getAttachment"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Gets the position and angle of an attachment";["fname"]="getAttachment";["name"]="ents_methods:getAttachment";["param"]={[1]="index";["index"]="The index of the attachment";};["private"]=false;["realm"]="sh";["ret"]="vector position, and angle orientation";["server"]=true;["summary"]="\
Gets the position and angle of an attachment ";};["getAttachmentParent"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Gets the attachment index the entity is parented to";["fname"]="getAttachmentParent";["name"]="ents_methods:getAttachmentParent";["param"]={};["private"]=false;["realm"]="sh";["ret"]="number index of the attachment the entity is parented to or 0";["server"]=true;["summary"]="\
Gets the attachment index the entity is parented to ";};["getAttachments"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Returns a table of attachments";["fname"]="getAttachments";["name"]="ents_methods:getAttachments";["param"]={};["private"]=false;["realm"]="sh";["ret"]="table of attachment id and attachment name or nil";["server"]=true;["summary"]="\
Returns a table of attachments ";};["getBoneCount"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Returns the number of an entity's bones";["fname"]="getBoneCount";["name"]="ents_methods:getBoneCount";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Number of bones";["server"]=true;["summary"]="\
Returns the number of an entity's bones ";};["getBoneMatrix"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Returns the matrix of the entity's bone. Note: this method is slow/doesnt work well if the entity isn't animated.";["fname"]="getBoneMatrix";["name"]="ents_methods:getBoneMatrix";["param"]={[1]="bone";["bone"]="Bone index. (def 0)";};["private"]=false;["realm"]="sh";["ret"]="The matrix";["server"]=true;["summary"]="\
Returns the matrix of the entity's bone.";};["getBoneName"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Returns the name of an entity's bone";["fname"]="getBoneName";["name"]="ents_methods:getBoneName";["param"]={[1]="bone";["bone"]="Bone index. (def 0)";};["private"]=false;["realm"]="sh";["ret"]="Name of the bone";["server"]=true;["summary"]="\
Returns the name of an entity's bone ";};["getBoneParent"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Returns the parent index of an entity's bone";["fname"]="getBoneParent";["name"]="ents_methods:getBoneParent";["param"]={[1]="bone";["bone"]="Bone index. (def 0)";};["private"]=false;["realm"]="sh";["ret"]="Parent index of the bone";["server"]=true;["summary"]="\
Returns the parent index of an entity's bone ";};["getBonePosition"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Returns the bone's position and angle in world coordinates";["fname"]="getBonePosition";["name"]="ents_methods:getBonePosition";["param"]={[1]="bone";["bone"]="Bone index. (def 0)";};["private"]=false;["realm"]="sh";["ret"]={[1]="Position of the bone";[2]="Angle of the bone";};["server"]=true;["summary"]="\
Returns the bone's position and angle in world coordinates ";};["getChildren"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Gets the children (the parented entities) of an entity";["fname"]="getChildren";["name"]="ents_methods:getChildren";["param"]={};["private"]=false;["realm"]="sh";["ret"]="table of parented children";["server"]=true;["summary"]="\
Gets the children (the parented entities) of an entity ";};["getChipName"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns the chip's name of E2s or starfalls";["fname"]="getChipName";["name"]="ents_methods:getChipName";["param"]={};["private"]=false;["realm"]="sh";["summary"]="\
Returns the chip's name of E2s or starfalls ";};["getClass"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Returns the class of the entity";["fname"]="getClass";["name"]="ents_methods:getClass";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The string class name";["server"]=true;["summary"]="\
Returns the class of the entity ";};["getColor"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Gets the color of an entity";["fname"]="getColor";["name"]="ents_methods:getColor";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Color";["server"]=true;["summary"]="\
Gets the color of an entity ";};["getEyeAngles"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Gets the entitiy's eye angles";["fname"]="getEyeAngles";["name"]="ents_methods:getEyeAngles";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Angles of the entity's eyes";["server"]=true;["summary"]="\
Gets the entitiy's eye angles ";};["getEyePos"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Gets the entity's eye position";["fname"]="getEyePos";["name"]="ents_methods:getEyePos";["param"]={};["private"]=false;["realm"]="sh";["ret"]={[1]="Eye position of the entity";[2]="In case of a ragdoll, the position of the second eye";};["server"]=true;["summary"]="\
Gets the entity's eye position ";};["getFlexes"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns a table of flexname -> flexid pairs for use in flex functions.";["fname"]="getFlexes";["name"]="ents_methods:getFlexes";["param"]={};["private"]=false;["realm"]="sh";["summary"]="\
Returns a table of flexname -> flexid pairs for use in flex functions.";};["getForward"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Gets the entity's forward vector";["fname"]="getForward";["name"]="ents_methods:getForward";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Vector forward";["server"]=true;["summary"]="\
Gets the entity's forward vector ";};["getHealth"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Gets the health of an entity";["fname"]="getHealth";["name"]="ents_methods:getHealth";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Health of the entity";["server"]=true;["summary"]="\
Gets the health of an entity ";};["getInertia"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Returns the principle moments of inertia of the entity";["fname"]="getInertia";["name"]="ents_methods:getInertia";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The principle moments of inertia as a vector";["server"]=true;["summary"]="\
Returns the principle moments of inertia of the entity ";};["getLinkedComponents"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns a list of entities linked to a processor";["fname"]="getLinkedComponents";["name"]="ents_methods:getLinkedComponents";["param"]={};["private"]=false;["realm"]="sv";["ret"]="A list of components linked to the entity";["summary"]="\
Returns a list of entities linked to a processor ";};["getMass"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Returns the mass of the entity";["fname"]="getMass";["name"]="ents_methods:getMass";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The numerical mass";["server"]=true;["summary"]="\
Returns the mass of the entity ";};["getMassCenter"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Returns the local position of the entity's mass center";["fname"]="getMassCenter";["name"]="ents_methods:getMassCenter";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The position vector of the mass center";["server"]=true;["summary"]="\
Returns the local position of the entity's mass center ";};["getMassCenterW"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Returns the world position of the entity's mass center";["fname"]="getMassCenterW";["name"]="ents_methods:getMassCenterW";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The position vector of the mass center";["server"]=true;["summary"]="\
Returns the world position of the entity's mass center ";};["getMaterial"]={["class"]="function";["classForced"]=true;["classlib"]="Entity";["client"]=true;["description"]="\
Gets an entities' material";["fname"]="getMaterial";["name"]="ents_methods:getMaterial";["param"]={};["private"]=false;["realm"]="sh";["ret"]="String material";["server"]=true;["summary"]="\
Gets an entities' material ";};["getMaterials"]={["class"]="function";["classForced"]=true;["classlib"]="Entity";["client"]=true;["description"]="\
Gets an entities' material list";["fname"]="getMaterials";["name"]="ents_methods:getMaterials";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Material";["server"]=true;["summary"]="\
Gets an entities' material list ";};["getMatrix"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Returns the world transform matrix of the entity";["fname"]="getMatrix";["name"]="ents_methods:getMatrix";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The matrix";["server"]=true;["summary"]="\
Returns the world transform matrix of the entity ";};["getMaxHealth"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
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
Returns the position of the entity ";};["getPose"]={["class"]="function";["classlib"]="Entity";["description"]="\
Get the pose value of an animation";["fname"]="getPose";["name"]="ents_methods:getPose";["param"]={[1]="pose";["pose"]="Pose parameter name";};["private"]=false;["realm"]="sh";["ret"]="Value of the pose parameter";["summary"]="\
Get the pose value of an animation ";};["getRight"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
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
Checks if an entity is an npc.";};["isOnFire"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Returns if the entity is ignited";["fname"]="isOnFire";["name"]="ents_methods:isOnFire";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Boolean if the entity is on fire or not";["server"]=true;["summary"]="\
Returns if the entity is ignited ";};["isOnGround"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Checks if the entity ONGROUND flag is set";["fname"]="isOnGround";["name"]="ents_methods:isOnGround";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Boolean if it's flag is set or not";["server"]=true;["summary"]="\
Checks if the entity ONGROUND flag is set ";};["isPlayer"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Checks if an entity is a player.";["fname"]="isPlayer";["name"]="ents_methods:isPlayer";["param"]={};["private"]=false;["realm"]="sh";["ret"]="True if player, false if not";["server"]=true;["summary"]="\
Checks if an entity is a player.";};["isPlayerHolding"]={["class"]="function";["classlib"]="Entity";["description"]="\
Returns true if the entity is being held by a player. Either by Physics gun, Gravity gun or Use-key.";["fname"]="isPlayerHolding";["name"]="ents_methods:isPlayerHolding";["param"]={};["private"]=false;["realm"]="sv";["ret"]="Boolean if the entity is being held or not";["server"]=true;["summary"]="\
Returns true if the entity is being held by a player.";};["isValid"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Checks if an entity is valid.";["fname"]="isValid";["name"]="ents_methods:isValid";["param"]={};["private"]=false;["realm"]="sh";["ret"]="True if valid, false if not";["server"]=true;["summary"]="\
Checks if an entity is valid.";};["isValidPhys"]={["class"]="function";["classlib"]="Entity";["description"]="\
Checks whether entity has physics";["fname"]="isValidPhys";["name"]="ents_methods:isValidPhys";["param"]={};["private"]=false;["realm"]="sv";["ret"]="True if entity has physics";["summary"]="\
Checks whether entity has physics ";};["isVehicle"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Checks if an entity is a vehicle.";["fname"]="isVehicle";["name"]="ents_methods:isVehicle";["param"]={};["private"]=false;["realm"]="sh";["ret"]="True if vehicle, false if not";["server"]=true;["summary"]="\
Checks if an entity is a vehicle.";};["isWeapon"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Checks if an entity is a weapon.";["fname"]="isWeapon";["name"]="ents_methods:isWeapon";["param"]={};["private"]=false;["realm"]="sh";["ret"]="True if weapon, false if not";["server"]=true;["summary"]="\
Checks if an entity is a weapon.";};["isWeldedTo"]={["class"]="function";["classlib"]="Entity";["description"]="\
Gets what the entity is welded to. If the entity is parented, returns the parent.";["fname"]="isWeldedTo";["name"]="ents_methods:isWeldedTo";["param"]={};["private"]=false;["realm"]="sv";["ret"]="The first welded/parent entity";["summary"]="\
Gets what the entity is welded to.";};["linkComponent"]={["class"]="function";["classlib"]="Entity";["description"]="\
Links starfall components to a starfall processor or vehicle. Screen can only connect to processor. HUD can connect to processor and vehicle.";["fname"]="linkComponent";["name"]="ents_methods:linkComponent";["param"]={[1]="e";["e"]="Entity to link the component to. nil to clear links.";};["private"]=false;["realm"]="sv";["summary"]="\
Links starfall components to a starfall processor or vehicle.";};["localToWorld"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Converts a vector in entity local space to world space";["fname"]="localToWorld";["name"]="ents_methods:localToWorld";["param"]={[1]="data";["data"]="Local space vector";};["private"]=false;["realm"]="sh";["ret"]="data as world space vector";["server"]=true;["summary"]="\
Converts a vector in entity local space to world space ";};["localToWorldAngles"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Converts an angle in entity local space to world space";["fname"]="localToWorldAngles";["name"]="ents_methods:localToWorldAngles";["param"]={[1]="data";["data"]="Local space angle";};["private"]=false;["realm"]="sh";["ret"]="data as world space angle";["server"]=true;["summary"]="\
Converts an angle in entity local space to world space ";};["lookupAttachment"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Gets the attachment index via the entity and it's attachment name";["fname"]="lookupAttachment";["name"]="ents_methods:lookupAttachment";["param"]={[1]="name";["name"]="";};["private"]=false;["realm"]="sh";["ret"]="number of the attachment index, or 0 if it doesn't exist";["server"]=true;["summary"]="\
Gets the attachment index via the entity and it's attachment name ";};["lookupBone"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Returns the ragdoll bone index given a bone name";["fname"]="lookupBone";["name"]="ents_methods:lookupBone";["param"]={[1]="name";["name"]="The bone's string name";};["private"]=false;["realm"]="sh";["ret"]="The bone index";["server"]=true;["summary"]="\
Returns the ragdoll bone index given a bone name ";};["lookupSequence"]={["class"]="function";["classlib"]="Entity";["description"]="\
Gets the animation number from the animation name";["fname"]="lookupSequence";["name"]="ents_methods:lookupSequence";["param"]={[1]="animation";["animation"]="Name of the animation";};["private"]=false;["realm"]="sh";["ret"]="Animation index or -1 if invalid";["summary"]="\
Gets the animation number from the animation name ";};["manipulateBoneAngles"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Allows manipulation of an entity's bones' angles";["fname"]="manipulateBoneAngles";["name"]="ents_methods:manipulateBoneAngles";["param"]={[1]="bone";[2]="ang";["ang"]="The angle it should be manipulated to";["bone"]="The bone ID";};["private"]=false;["realm"]="cl";["summary"]="\
Allows manipulation of an entity's bones' angles ";};["manipulateBonePosition"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Allows manipulation of an entity's bones' positions";["fname"]="manipulateBonePosition";["name"]="ents_methods:manipulateBonePosition";["param"]={[1]="bone";[2]="vec";["bone"]="The bone ID";["vec"]="The position it should be manipulated to";};["private"]=false;["realm"]="cl";["summary"]="\
Allows manipulation of an entity's bones' positions ";};["manipulateBoneScale"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Allows manipulation of an entity's bones' scale";["fname"]="manipulateBoneScale";["name"]="ents_methods:manipulateBoneScale";["param"]={[1]="bone";[2]="vec";["bone"]="The bone ID";["vec"]="The scale it should be manipulated to";};["private"]=false;["realm"]="cl";["summary"]="\
Allows manipulation of an entity's bones' scale ";};["obbCenter"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Returns the local position of the entity's outer bounding box";["fname"]="obbCenter";["name"]="ents_methods:obbCenter";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The position vector of the outer bounding box center";["server"]=true;["summary"]="\
Returns the local position of the entity's outer bounding box ";};["obbCenterW"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Returns the world position of the entity's outer bounding box";["fname"]="obbCenterW";["name"]="ents_methods:obbCenterW";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The position vector of the outer bounding box center";["server"]=true;["summary"]="\
Returns the world position of the entity's outer bounding box ";};["obbMaxs"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Returns max local bounding box vector of the entity";["fname"]="obbMaxs";["name"]="ents_methods:obbMaxs";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The max bounding box vector";["server"]=true;["summary"]="\
Returns max local bounding box vector of the entity ";};["obbMins"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Returns min local bounding box vector of the entity";["fname"]="obbMins";["name"]="ents_methods:obbMins";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The min bounding box vector";["server"]=true;["summary"]="\
Returns min local bounding box vector of the entity ";};["obbSize"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Returns the x, y, z size of the entity's outer bounding box (local to the entity)";["fname"]="obbSize";["name"]="ents_methods:obbSize";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The outer bounding box size";["server"]=true;["summary"]="\
Returns the x, y, z size of the entity's outer bounding box (local to the entity) ";};["remove"]={["class"]="function";["classlib"]="Entity";["description"]="\
Removes an entity";["fname"]="remove";["name"]="ents_methods:remove";["param"]={};["private"]=false;["realm"]="sv";["summary"]="\
Removes an entity ";};["removeCollisionListener"]={["class"]="function";["classlib"]="Entity";["description"]="\
Removes a collision listening hook from the entity so that a new one can be added";["fname"]="removeCollisionListener";["name"]="ents_methods:removeCollisionListener";["param"]={};["private"]=false;["realm"]="sv";["summary"]="\
Removes a collision listening hook from the entity so that a new one can be added ";};["removeTrails"]={["class"]="function";["classlib"]="Entity";["description"]="\
Removes trails from the entity";["fname"]="removeTrails";["name"]="ents_methods:removeTrails";["param"]={};["private"]=false;["realm"]="sv";["summary"]="\
Removes trails from the entity ";};["sequenceDuration"]={["class"]="function";["classlib"]="Entity";["description"]="\
Get the length of an animation";["fname"]="sequenceDuration";["name"]="ents_methods:sequenceDuration";["param"]={[1]="id";["id"]="(Optional) The id of the sequence, or will default to the currently playing sequence";};["private"]=false;["realm"]="sh";["ret"]="Length of the animation in seconds";["summary"]="\
Get the length of an animation ";};["setAngleVelocity"]={["class"]="function";["classlib"]="Entity";["description"]="\
Set the angular velocity of an object";["fname"]="setAngleVelocity";["name"]="ents_methods:setAngleVelocity";["param"]={[1]="angvel";["angvel"]="The local angvel vector to set";};["private"]=false;["realm"]="sv";["summary"]="\
Set the angular velocity of an object ";};["setAngles"]={["class"]="function";["classlib"]="Entity";["description"]="\
Sets the entity's angles";["fname"]="setAngles";["name"]="ents_methods:setAngles";["param"]={[1]="ang";["ang"]="New angles";};["private"]=false;["realm"]="sv";["summary"]="\
Sets the entity's angles ";};["setBodygroup"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Sets the bodygroup of the entity";["fname"]="setBodygroup";["name"]="ents_methods:setBodygroup";["param"]={[1]="bodygroup";[2]="value";["bodygroup"]="Number, The ID of the bodygroup you're setting.";["value"]="Number, The value you're setting the bodygroup to.";};["private"]=false;["realm"]="sh";["server"]=true;["summary"]="\
Sets the bodygroup of the entity ";};["setColor"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Sets the color of the entity";["fname"]="setColor";["name"]="ents_methods:setColor";["param"]={[1]="clr";["clr"]="New color";};["private"]=false;["realm"]="sh";["server"]=true;["summary"]="\
Sets the color of the entity ";};["setDrawShadow"]={["class"]="function";["classlib"]="Entity";["description"]="\
Sets whether an entity's shadow should be drawn";["fname"]="setDrawShadow";["name"]="ents_methods:setDrawShadow";["param"]={[1]="draw";[2]="ply";["ply"]="Optional player argument to set only for that player. Can also be table of players.";};["private"]=false;["realm"]="sv";["summary"]="\
Sets whether an entity's shadow should be drawn ";};["setFlexScale"]={["class"]="function";["classlib"]="Entity";["description"]="\
Sets the scale of all flexes of an entity";["fname"]="setFlexScale";["name"]="ents_methods:setFlexScale";["param"]={[1]="scale";};["private"]=false;["realm"]="sh";["summary"]="\
Sets the scale of all flexes of an entity ";};["setFlexWeight"]={["class"]="function";["classlib"]="Entity";["description"]="\
Sets the weight (value) of a flex.";["fname"]="setFlexWeight";["name"]="ents_methods:setFlexWeight";["param"]={[1]="flexid";[2]="weight";["flexid"]="The id of the flex";["weight"]="The weight of the flex";};["private"]=false;["realm"]="sh";["summary"]="\
Sets the weight (value) of a flex.";};["setFrozen"]={["class"]="function";["classlib"]="Entity";["description"]="\
Sets the entity frozen state";["fname"]="setFrozen";["name"]="ents_methods:setFrozen";["param"]={[1]="freeze";["freeze"]="Should the entity be frozen?";};["private"]=false;["realm"]="sv";["summary"]="\
Sets the entity frozen state ";};["setInertia"]={["class"]="function";["classlib"]="Entity";["description"]="\
Sets the entity's inertia";["fname"]="setInertia";["name"]="ents_methods:setInertia";["param"]={[1]="vec";["vec"]="Inertia tensor";};["private"]=false;["realm"]="sv";["summary"]="\
Sets the entity's inertia ";};["setMass"]={["class"]="function";["classlib"]="Entity";["description"]="\
Sets the entity's mass";["fname"]="setMass";["name"]="ents_methods:setMass";["param"]={[1]="mass";["mass"]="number mass";};["private"]=false;["realm"]="sv";["summary"]="\
Sets the entity's mass ";};["setMaterial"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Sets the material of the entity";["fname"]="setMaterial";["name"]="ents_methods:setMaterial";["param"]={[1]="material";["material"]=", string, New material name.";};["private"]=false;["realm"]="sh";["server"]=true;["summary"]="\
Sets the material of the entity ";};["setMesh"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Sets a hologram or custom_prop model to a custom Mesh";["fname"]="setMesh";["name"]="ents_methods:setMesh";["param"]={[1]="mesh";["mesh"]="The mesh to set it to or nil to set back to normal";};["private"]=false;["realm"]="cl";["summary"]="\
Sets a hologram or custom_prop model to a custom Mesh ";};["setMeshMaterial"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Sets a hologram or custom_prop's custom mesh material";["fname"]="setMeshMaterial";["name"]="ents_methods:setMeshMaterial";["param"]={[1]="material";["material"]="The material to set it to or nil to set back to default";};["private"]=false;["realm"]="cl";["summary"]="\
Sets a hologram or custom_prop's custom mesh material ";};["setNoDraw"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Sets the whether an entity should be drawn or not";["fname"]="setNoDraw";["name"]="ents_methods:setNoDraw";["param"]={[1]="draw";["draw"]="Whether to draw the entity or not.";};["private"]=false;["realm"]="sh";["server"]=true;["summary"]="\
Sets the whether an entity should be drawn or not ";};["setNocollideAll"]={["class"]="function";["classlib"]="Entity";["description"]="\
Set's the entity to collide with nothing but the world";["fname"]="setNocollideAll";["name"]="ents_methods:setNocollideAll";["param"]={[1]="nocollide";["nocollide"]="Whether to collide with nothing except world or not.";};["private"]=false;["realm"]="sv";["summary"]="\
Set's the entity to collide with nothing but the world ";};["setParent"]={["class"]="function";["classlib"]="Entity";["description"]="\
Parents the entity to another entity";["fname"]="setParent";["name"]="ents_methods:setParent";["param"]={[1]="ent";[2]="attachment";["attachment"]="Optional string attachment name to parent to";["ent"]="Entity to parent to. nil to unparent";};["private"]=false;["realm"]="sv";["summary"]="\
Parents the entity to another entity ";};["setPhysMaterial"]={["class"]="function";["classlib"]="Entity";["description"]="\
Sets the physical material of the entity";["fname"]="setPhysMaterial";["name"]="ents_methods:setPhysMaterial";["param"]={[1]="mat";["mat"]="Material to use";};["private"]=false;["realm"]="sv";["summary"]="\
Sets the physical material of the entity ";};["setPos"]={["class"]="function";["classlib"]="Entity";["description"]="\
Sets the entitiy's position. No interpolation will occur clientside, use physobj.setPos to have interpolation.";["fname"]="setPos";["name"]="ents_methods:setPos";["param"]={[1]="vec";["vec"]="New position";};["private"]=false;["realm"]="sv";["summary"]="\
Sets the entitiy's position.";};["setPose"]={["class"]="function";["classlib"]="Entity";["description"]="\
Set the pose value of an animation. Turret/Head angles for example.";["fname"]="setPose";["name"]="ents_methods:setPose";["param"]={[1]="pose";[2]="value";["pose"]="Name of the pose parameter";["value"]="Value to set it to.";};["private"]=false;["realm"]="sh";["summary"]="\
Set the pose value of an animation.";};["setRenderBounds"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Sets a hologram or custom_prop's renderbounds";["fname"]="setRenderBounds";["name"]="ents_methods:setRenderBounds";["param"]={[1]="mins";[2]="maxs";["maxs"]="The upper bounding corner coordinate local to the hologram";["mins"]="The lower bounding corner coordinate local to the hologram";};["private"]=false;["realm"]="cl";["summary"]="\
Sets a hologram or custom_prop's renderbounds ";};["setRenderFX"]={["class"]="function";["classForced"]=true;["classlib"]="Entity";["client"]=true;["description"]="\
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
Adds a trail to the entity with the specified attributes.";};["setUnbreakable"]={["class"]="function";["classlib"]="Entity";["description"]="\
Sets a prop_physics to be unbreakable";["fname"]="setUnbreakable";["name"]="ents_methods:setUnbreakable";["param"]={[1]="on";["on"]="Whether to make the prop unbreakable";};["private"]=false;["realm"]="sv";["summary"]="\
Sets a prop_physics to be unbreakable ";};["setVelocity"]={["class"]="function";["classlib"]="Entity";["description"]="\
Sets the entity's linear velocity";["fname"]="setVelocity";["name"]="ents_methods:setVelocity";["param"]={[1]="vel";["vel"]="New velocity";};["private"]=false;["realm"]="sv";["summary"]="\
Sets the entity's linear velocity ";};["stopSound"]={["class"]="function";["classlib"]="Entity";["description"]="\
Stops a sound on the entity";["fname"]="stopSound";["name"]="ents_methods:stopSound";["param"]={[1]="snd";["snd"]="string Soundscript path. See http://wiki.garrysmod.com/page/Entity/StopSound";};["private"]=false;["realm"]="sh";["summary"]="\
Stops a sound on the entity ";};["testPVS"]={["class"]="function";["classlib"]="Entity";["description"]="\
Check if the given Entity or Vector is within this entity's PVS (Potentially Visible Set). See: https://developer.valvesoftware.com/wiki/PVS";["fname"]="testPVS";["name"]="ents_methods:testPVS";["param"]={[1]="other";["other"]="Entity or Vector to test";};["private"]=false;["realm"]="sv";["ret"]="bool True/False";["summary"]="\
Check if the given Entity or Vector is within this entity's PVS (Potentially Visible Set).";};["toHologram"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Casts a hologram entity into the hologram type";["fname"]="toHologram";["name"]="ents_methods:toHologram";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Hologram type";["server"]=true;["summary"]="\
Casts a hologram entity into the hologram type ";};["translateBoneToPhysBone"]={["class"]="function";["classlib"]="Entity";["description"]="\
Converts a ragdoll bone id to the corresponding physobject id";["fname"]="translateBoneToPhysBone";["name"]="ents_methods:translateBoneToPhysBone";["param"]={[1]="boneid";["boneid"]="The ragdoll boneid";};["private"]=false;["realm"]="sh";["ret"]="The physobj id";["summary"]="\
Converts a ragdoll bone id to the corresponding physobject id ";};["translatePhysBoneToBone"]={["class"]="function";["classlib"]="Entity";["description"]="\
Converts a physobject id to the corresponding ragdoll bone id";["fname"]="translatePhysBoneToBone";["name"]="ents_methods:translatePhysBoneToBone";["param"]={[1]="boneid";["boneid"]="The physobject id";};["private"]=false;["realm"]="sh";["ret"]="The ragdoll bone id";["summary"]="\
Converts a physobject id to the corresponding ragdoll bone id ";};["unparent"]={["class"]="function";["classlib"]="Entity";["description"]="\
Unparents the entity from another entity";["fname"]="unparent";["name"]="ents_methods:unparent";["param"]={};["private"]=false;["realm"]="sv";["summary"]="\
Unparents the entity from another entity ";};["worldToLocal"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Converts a vector in world space to entity local space";["fname"]="worldToLocal";["name"]="ents_methods:worldToLocal";["param"]={[1]="data";["data"]="World space vector";};["private"]=false;["realm"]="sh";["ret"]="data as local space vector";["server"]=true;["summary"]="\
Converts a vector in world space to entity local space ";};["worldToLocalAngles"]={["class"]="function";["classlib"]="Entity";["client"]=true;["description"]="\
Converts an angle in world space to entity local space";["fname"]="worldToLocalAngles";["name"]="ents_methods:worldToLocalAngles";["param"]={[1]="data";["data"]="World space angle";};["private"]=false;["realm"]="sh";["ret"]="data as local space angle";["server"]=true;["summary"]="\
Converts an angle in world space to entity local space ";};};["name"]="Entity";["param"]={};["summary"]="\
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
Hologram type";["fields"]={};["methods"]={[1]="getScale";[10]="setParent";[11]="setPos";[12]="setRenderMatrix";[13]="setScale";[14]="setVel";[15]="suppressEngineLighting";[2]="remove";[3]="setAngVel";[4]="setAngles";[5]="setAnimation";[6]="setClip";[7]="setFilterMag";[8]="setFilterMin";[9]="setModel";["getScale"]={["class"]="function";["classlib"]="Hologram";["client"]=true;["description"]="\
Gets the hologram scale.";["fname"]="getScale";["name"]="hologram_methods:getScale";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Vector scale";["server"]=true;["summary"]="\
Gets the hologram scale.";};["remove"]={["class"]="function";["classlib"]="Hologram";["description"]="\
Removes a hologram";["fname"]="remove";["name"]="hologram_methods:remove";["param"]={};["private"]=false;["realm"]="sh";["summary"]="\
Removes a hologram ";};["setAngVel"]={["class"]="function";["classlib"]="Hologram";["description"]="\
Sets the hologram's angular velocity.";["fname"]="setAngVel";["name"]="hologram_methods:setAngVel";["param"]={[1]="angvel";["angvel"]="*Vector* angular velocity.";};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Sets the hologram's angular velocity.";};["setAngles"]={["class"]="function";["classlib"]="Hologram";["client"]=true;["description"]="\
Sets the hologram's angles.";["fname"]="setAngles";["name"]="hologram_methods:setAngles";["param"]={[1]="ang";["ang"]="New angles";};["private"]=false;["realm"]="sh";["server"]=true;["summary"]="\
Sets the hologram's angles.";};["setAnimation"]={["class"]="function";["classlib"]="Hologram";["description"]="\
Animates a hologram";["fname"]="setAnimation";["name"]="hologram_methods:setAnimation";["param"]={[1]="animation";[2]="frame";[3]="rate";["animation"]="number or string name";["frame"]="The starting frame number";["rate"]="Frame speed. (1 is normal)";};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Animates a hologram ";};["setClip"]={["class"]="function";["classlib"]="Hologram";["client"]=true;["description"]="\
Updates a clip plane";["fname"]="setClip";["name"]="hologram_methods:setClip";["param"]={[1]="index";[2]="enabled";[3]="origin";[4]="normal";[5]="entity";["enabled"]="Whether the clip is enabled";["entity"]="(Optional) The entity to make coordinates local to, otherwise the world is used";["index"]="Whatever number you want the clip to be";["normal"]="The the direction of the clip plane in world coordinates, or local to entity if it is specified";["origin"]="The center of the clip plane in world coordinates, or local to entity if it is specified";};["private"]=false;["realm"]="cl";["summary"]="\
Updates a clip plane ";};["setFilterMag"]={["class"]="function";["classlib"]="Hologram";["client"]=true;["description"]="\
Sets the texture filtering function when viewing a close texture";["fname"]="setFilterMag";["name"]="hologram_methods:setFilterMag";["param"]={[1]="val";["val"]="The filter function to use http://wiki.garrysmod.com/page/Enums/TEXFILTER";};["private"]=false;["realm"]="cl";["summary"]="\
Sets the texture filtering function when viewing a close texture ";};["setFilterMin"]={["class"]="function";["classlib"]="Hologram";["client"]=true;["description"]="\
Sets the texture filtering function when viewing a far texture";["fname"]="setFilterMin";["name"]="hologram_methods:setFilterMin";["param"]={[1]="val";["val"]="The filter function to use http://wiki.garrysmod.com/page/Enums/TEXFILTER";};["private"]=false;["realm"]="cl";["summary"]="\
Sets the texture filtering function when viewing a far texture ";};["setModel"]={["class"]="function";["classlib"]="Hologram";["description"]="\
Sets the model of a hologram";["fname"]="setModel";["name"]="hologram_methods:setModel";["param"]={[1]="model";["model"]="string model path";};["private"]=false;["realm"]="sh";["summary"]="\
Sets the model of a hologram ";};["setParent"]={["class"]="function";["classlib"]="Hologram";["description"]="\
Parents a hologram";["fname"]="setParent";["name"]="hologram_methods:setParent";["param"]={[1]="ent";[2]="attachment";["attachment"]="Optional attachment ID";["ent"]="Entity parent (nil to unparent)";};["private"]=false;["realm"]="sh";["summary"]="\
Parents a hologram ";};["setPos"]={["class"]="function";["classlib"]="Hologram";["client"]=true;["description"]="\
Sets the hologram's position.";["fname"]="setPos";["name"]="hologram_methods:setPos";["param"]={[1]="vec";["vec"]="New position";};["private"]=false;["realm"]="sh";["server"]=true;["summary"]="\
Sets the hologram's position.";};["setRenderMatrix"]={["class"]="function";["classlib"]="Hologram";["client"]=true;["description"]="\
Sets a hologram entity's rendermatrix";["fname"]="setRenderMatrix";["name"]="hologram_methods:setRenderMatrix";["param"]={[1]="mat";["mat"]="Starfall matrix to use";};["private"]=false;["realm"]="cl";["summary"]="\
Sets a hologram entity's rendermatrix ";};["setScale"]={["class"]="function";["classlib"]="Hologram";["client"]=true;["description"]="\
Sets the hologram scale. Basically the same as setRenderMatrix() with a scaled matrix";["fname"]="setScale";["name"]="hologram_methods:setScale";["param"]={[1]="scale";["scale"]="Vector new scale";};["private"]=false;["realm"]="sh";["server"]=true;["summary"]="\
Sets the hologram scale.";};["setVel"]={["class"]="function";["classlib"]="Hologram";["description"]="\
Sets the hologram linear velocity";["fname"]="setVel";["name"]="hologram_methods:setVel";["param"]={[1]="vel";["vel"]="New velocity";};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Sets the hologram linear velocity ";};["suppressEngineLighting"]={["class"]="function";["classlib"]="Hologram";["client"]=true;["description"]="\
Suppress Engine Lighting of a hologram. Disabled by default.";["fname"]="suppressEngineLighting";["name"]="hologram_methods:suppressEngineLighting";["param"]={[1]="suppress";["suppress"]="Boolean to represent if shading should be set or not.";};["private"]=false;["realm"]="sh";["server"]=true;["summary"]="\
Suppress Engine Lighting of a hologram.";};};["name"]="Hologram";["summary"]="\
Hologram type ";["typtbl"]="hologram_methods";};["Light"]={["class"]="class";["client"]=true;["description"]="\
Light type";["fields"]={};["methods"]={[1]="draw";[10]="setNoWorld";[11]="setOuterAngle";[12]="setPos";[13]="setSize";[14]="setStyle";[2]="setBrightness";[3]="setColor";[4]="setDecay";[5]="setDieTime";[6]="setDirection";[7]="setInnerAngle";[8]="setMinLight";[9]="setNoModel";["draw"]={["class"]="function";["classlib"]="Light";["description"]="\
Draws the light. Typically used in the think hook. Will throw an error if it fails (use pcall)";["fname"]="draw";["name"]="light_methods:draw";["param"]={};["private"]=false;["realm"]="cl";["summary"]="\
Draws the light.";};["setBrightness"]={["class"]="function";["classlib"]="Light";["description"]="\
Sets the light brightness";["fname"]="setBrightness";["name"]="light_methods:setBrightness";["param"]={[1]="brightness";["brightness"]="The light's brightness";};["private"]=false;["realm"]="cl";["summary"]="\
Sets the light brightness ";};["setColor"]={["class"]="function";["classlib"]="Light";["description"]="\
Sets the color of the light";["fname"]="setColor";["name"]="light_methods:setColor";["param"]={[1]="color";["color"]="The color of the light";};["private"]=false;["realm"]="cl";["summary"]="\
Sets the color of the light ";};["setDecay"]={["class"]="function";["classlib"]="Light";["description"]="\
Sets the light decay speed in thousandths per second. 1000 lasts for 1 second, 2000 lasts for 0.5 seconds";["fname"]="setDecay";["name"]="light_methods:setDecay";["param"]={[1]="decay";["decay"]="The light's decay speed";};["private"]=false;["realm"]="cl";["summary"]="\
Sets the light decay speed in thousandths per second.";};["setDieTime"]={["class"]="function";["classlib"]="Light";["description"]="\
Sets the light lifespan (Required for fade effect i.e. decay)";["fname"]="setDieTime";["name"]="light_methods:setDieTime";["param"]={[1]="dietime";["dietime"]="The how long the light will stay alive after turning it off.";};["private"]=false;["realm"]="cl";["summary"]="\
Sets the light lifespan (Required for fade effect i.e.";};["setDirection"]={["class"]="function";["classlib"]="Light";["description"]="\
Sets the light direction (used with setInnerAngle and setOuterAngle)";["fname"]="setDirection";["name"]="light_methods:setDirection";["param"]={[1]="dir";["dir"]="Direction of the light";};["private"]=false;["realm"]="cl";["summary"]="\
Sets the light direction (used with setInnerAngle and setOuterAngle) ";};["setInnerAngle"]={["class"]="function";["classlib"]="Light";["description"]="\
Sets the light inner angle (used with setDirection and setOuterAngle)";["fname"]="setInnerAngle";["name"]="light_methods:setInnerAngle";["param"]={[1]="ang";["ang"]="Number inner angle of the light";};["private"]=false;["realm"]="cl";["summary"]="\
Sets the light inner angle (used with setDirection and setOuterAngle) ";};["setMinLight"]={["class"]="function";["classlib"]="Light";["description"]="\
Sets the minimum light amount";["fname"]="setMinLight";["name"]="light_methods:setMinLight";["param"]={[1]="min";["min"]="The minimum light";};["private"]=false;["realm"]="cl";["summary"]="\
Sets the minimum light amount ";};["setNoModel"]={["class"]="function";["classlib"]="Light";["description"]="\
Sets whether the light should cast onto models or not";["fname"]="setNoModel";["name"]="light_methods:setNoModel";["param"]={[1]="on";["on"]="Whether the light shouldn't cast onto the models";};["private"]=false;["realm"]="cl";["summary"]="\
Sets whether the light should cast onto models or not ";};["setNoWorld"]={["class"]="function";["classlib"]="Light";["description"]="\
Sets whether the light should cast onto the world or not";["fname"]="setNoWorld";["name"]="light_methods:setNoWorld";["param"]={[1]="on";["on"]="Whether the light shouldn't cast onto the world";};["private"]=false;["realm"]="cl";["summary"]="\
Sets whether the light should cast onto the world or not ";};["setOuterAngle"]={["class"]="function";["classlib"]="Light";["description"]="\
Sets the light outer angle (used with setDirection and setInnerAngle)";["fname"]="setOuterAngle";["name"]="light_methods:setOuterAngle";["param"]={[1]="ang";["ang"]="Number outer angle of the light";};["private"]=false;["realm"]="cl";["summary"]="\
Sets the light outer angle (used with setDirection and setInnerAngle) ";};["setPos"]={["class"]="function";["classlib"]="Light";["description"]="\
Sets the light position";["fname"]="setPos";["name"]="light_methods:setPos";["param"]={[1]="pos";["pos"]="The position of the light";};["private"]=false;["realm"]="cl";["summary"]="\
Sets the light position ";};["setSize"]={["class"]="function";["classlib"]="Light";["description"]="\
Sets the size of the light (max is sf_light_maxsize)";["fname"]="setSize";["name"]="light_methods:setSize";["param"]={[1]="size";["size"]="The size of the light";};["private"]=false;["realm"]="cl";["summary"]="\
Sets the size of the light (max is sf_light_maxsize) ";};["setStyle"]={["class"]="function";["classlib"]="Light";["description"]="\
Sets the flicker style of the light https://developer.valvesoftware.com/wiki/Light_dynamic#Appearances";["fname"]="setStyle";["name"]="light_methods:setStyle";["param"]={[1]="style";["style"]="The number of the flicker style";};["private"]=false;["realm"]="cl";["summary"]="\
Sets the flicker style of the light https://developer.valvesoftware.com/wiki/Light_dynamic#Appearances ";};};["name"]="Light";["summary"]="\
Light type ";["typtbl"]="light_methods";};["Material"]={["class"]="class";["client"]=true;["description"]="\
The `Material` type is used to control shaders in rendering. \
For a list of shader parameters, see https://developer.valvesoftware.com/wiki/Category:List_of_Shader_Parameters \
For a list of $flags and $flags2, see https://developer.valvesoftware.com/wiki/Material_Flags";["fields"]={};["methods"]={[1]="destroy";[10]="getString";[11]="getTexture";[12]="getVector";[13]="getVectorLinear";[14]="getWidth";[15]="recompute";[16]="setFloat";[17]="setInt";[18]="setMatrix";[19]="setString";[2]="getColor";[20]="setTexture";[21]="setTextureRenderTarget";[22]="setTextureURL";[23]="setUndefined";[24]="setVector";[3]="getFloat";[4]="getHeight";[5]="getInt";[6]="getKeyValues";[7]="getMatrix";[8]="getName";[9]="getShader";["destroy"]={["class"]="function";["classlib"]="Material";["description"]="\
Free's a user created material allowing you to create others";["fname"]="destroy";["name"]="material_methods:destroy";["param"]={};["private"]=false;["realm"]="cl";["summary"]="\
Free's a user created material allowing you to create others ";};["getColor"]={["class"]="function";["classlib"]="Material";["description"]="\
Returns a color pixel value of the $basetexture of a .png or .jpg material.";["fname"]="getColor";["name"]="material_methods:getColor";["param"]={[1]="x";[2]="y";["x"]="The x coordinate of the pixel";["y"]="The y coordinate of the pixel";};["private"]=false;["realm"]="cl";["ret"]="The color value";["summary"]="\
Returns a color pixel value of the $basetexture of a .png or .jpg material.";};["getFloat"]={["class"]="function";["classlib"]="Material";["description"]="\
Returns a float keyvalue";["fname"]="getFloat";["name"]="material_methods:getFloat";["param"]={[1]="key";["key"]="The key to get the float from";};["private"]=false;["realm"]="cl";["ret"]="The float value or nil if it doesn't exist";["summary"]="\
Returns a float keyvalue ";};["getHeight"]={["class"]="function";["classlib"]="Material";["description"]="\
Gets the base texture set to the material's height";["fname"]="getHeight";["name"]="material_methods:getHeight";["param"]={};["private"]=false;["realm"]="cl";["ret"]="The basetexture's height";["summary"]="\
Gets the base texture set to the material's height ";};["getInt"]={["class"]="function";["classlib"]="Material";["description"]="\
Returns an int keyvalue";["fname"]="getInt";["name"]="material_methods:getInt";["param"]={[1]="key";["key"]="The key to get the int from";};["private"]=false;["realm"]="cl";["ret"]="The int value or nil if it doesn't exist";["summary"]="\
Returns an int keyvalue ";};["getKeyValues"]={["class"]="function";["classlib"]="Material";["description"]="\
Returns a table of material keyvalues";["fname"]="getKeyValues";["name"]="material_methods:getKeyValues";["param"]={};["private"]=false;["realm"]="cl";["ret"]="The table of keyvalues";["summary"]="\
Returns a table of material keyvalues ";};["getMatrix"]={["class"]="function";["classlib"]="Material";["description"]="\
Returns a matrix keyvalue";["fname"]="getMatrix";["name"]="material_methods:getMatrix";["param"]={[1]="key";["key"]="The key to get the matrix from";};["private"]=false;["realm"]="cl";["ret"]="The matrix value or nil if it doesn't exist";["summary"]="\
Returns a matrix keyvalue ";};["getName"]={["class"]="function";["classlib"]="Material";["description"]="\
Returns the material's engine name";["fname"]="getName";["name"]="material_methods:getName";["param"]={};["private"]=false;["realm"]="cl";["ret"]="The name of the material. If this material is user created, add ! to the beginning of this to use it with entity.setMaterial";["summary"]="\
Returns the material's engine name ";};["getShader"]={["class"]="function";["classlib"]="Material";["description"]="\
Returns the shader name of the material";["fname"]="getShader";["name"]="material_methods:getShader";["param"]={};["private"]=false;["realm"]="cl";["ret"]="The shader name of the material";["summary"]="\
Returns the shader name of the material ";};["getString"]={["class"]="function";["classlib"]="Material";["description"]="\
Returns a string keyvalue";["fname"]="getString";["name"]="material_methods:getString";["param"]={[1]="key";["key"]="The key to get the string from";};["private"]=false;["realm"]="cl";["ret"]="The string value or nil if it doesn't exist";["summary"]="\
Returns a string keyvalue ";};["getTexture"]={["class"]="function";["classlib"]="Material";["description"]="\
Returns a texture id keyvalue";["fname"]="getTexture";["name"]="material_methods:getTexture";["param"]={[1]="key";["key"]="The key to get the texture from";};["private"]=false;["realm"]="cl";["ret"]="The string id of the texture or nil if it doesn't exist";["summary"]="\
Returns a texture id keyvalue ";};["getVector"]={["class"]="function";["classlib"]="Material";["description"]="\
Returns a vector keyvalue";["fname"]="getVector";["name"]="material_methods:getVector";["param"]={[1]="key";["key"]="The key to get the vector from";};["private"]=false;["realm"]="cl";["ret"]="The string id of the texture";["summary"]="\
Returns a vector keyvalue ";};["getVectorLinear"]={["class"]="function";["classlib"]="Material";["description"]="\
Returns a linear color-corrected vector keyvalue";["fname"]="getVectorLinear";["name"]="material_methods:getVectorLinear";["param"]={[1]="key";["key"]="The key to get the vector from";};["private"]=false;["realm"]="cl";["ret"]="The vector value or nil if it doesn't exist";["summary"]="\
Returns a linear color-corrected vector keyvalue ";};["getWidth"]={["class"]="function";["classlib"]="Material";["description"]="\
Gets the base texture set to the material's width";["fname"]="getWidth";["name"]="material_methods:getWidth";["param"]={};["private"]=false;["realm"]="cl";["ret"]="The basetexture's width";["summary"]="\
Gets the base texture set to the material's width ";};["recompute"]={["class"]="function";["classlib"]="Material";["description"]="\
Refreshes the material. Sometimes needed for certain parameters to update";["fname"]="recompute";["name"]="material_methods:recompute";["param"]={};["private"]=false;["realm"]="cl";["summary"]="\
Refreshes the material.";};["setFloat"]={["class"]="function";["classlib"]="Material";["description"]="\
Sets a float keyvalue";["fname"]="setFloat";["name"]="material_methods:setFloat";["param"]={[1]="key";[2]="v";["key"]="The key name to set";["v"]="The value to set it to";};["private"]=false;["realm"]="cl";["summary"]="\
Sets a float keyvalue ";};["setInt"]={["class"]="function";["classlib"]="Material";["description"]="\
Sets an int keyvalue";["fname"]="setInt";["name"]="material_methods:setInt";["param"]={[1]="key";[2]="v";["key"]="The key name to set";["v"]="The value to set it to";};["private"]=false;["realm"]="cl";["summary"]="\
Sets an int keyvalue ";};["setMatrix"]={["class"]="function";["classlib"]="Material";["description"]="\
Sets a matrix keyvalue";["fname"]="setMatrix";["name"]="material_methods:setMatrix";["param"]={[1]="key";[2]="v";["key"]="The key name to set";["v"]="The value to set it to";};["private"]=false;["realm"]="cl";["summary"]="\
Sets a matrix keyvalue ";};["setString"]={["class"]="function";["classlib"]="Material";["description"]="\
Sets a string keyvalue";["fname"]="setString";["name"]="material_methods:setString";["param"]={[1]="key";[2]="v";["key"]="The key name to set";["v"]="The value to set it to";};["private"]=false;["realm"]="cl";["summary"]="\
Sets a string keyvalue ";};["setTexture"]={["class"]="function";["classlib"]="Material";["description"]="\
Sets a texture keyvalue";["fname"]="setTexture";["name"]="material_methods:setTexture";["param"]={[1]="key";[2]="v";["key"]="The key name to set. $basetexture is the key name for most purposes.";["v"]="The texture name to set it to.";};["private"]=false;["realm"]="cl";["summary"]="\
Sets a texture keyvalue ";};["setTextureRenderTarget"]={["class"]="function";["classlib"]="Material";["description"]="\
Sets a rendertarget texture to the specified texture key";["fname"]="setTextureRenderTarget";["name"]="material_methods:setTextureRenderTarget";["param"]={[1]="key";[2]="name";["key"]="The key name to set. $basetexture is the key name for most purposes.";["name"]="The name of the rendertarget";};["private"]=false;["realm"]="cl";["summary"]="\
Sets a rendertarget texture to the specified texture key ";};["setTextureURL"]={["class"]="function";["classlib"]="Material";["description"]="\
Loads an online image or base64 data to the specified texture key";["fname"]="setTextureURL";["name"]="material_methods:setTextureURL";["param"]={[1]="key";[2]="url";[3]="cb";[4]="done";["cb"]="An optional callback called when image is loaded. Passes nil if it fails or Passes the material, url, width, height, and layout function which can be called with x, y, w, h to reposition the image in the texture";["done"]="An optional callback called when the image is done loading. Passes the material, url";["key"]="The key name to set. $basetexture is the key name for most purposes.";["url"]="The url or base64 data";};["private"]=false;["realm"]="cl";["summary"]="\
Loads an online image or base64 data to the specified texture key ";};["setUndefined"]={["class"]="function";["classlib"]="Material";["description"]="\
Sets a keyvalue to be undefined";["fname"]="setUndefined";["name"]="material_methods:setUndefined";["param"]={[1]="key";["key"]="The key name to set";};["private"]=false;["realm"]="cl";["summary"]="\
Sets a keyvalue to be undefined ";};["setVector"]={["class"]="function";["classlib"]="Material";["description"]="\
Sets a vector keyvalue";["fname"]="setVector";["name"]="material_methods:setVector";["param"]={[1]="key";[2]="v";["key"]="The key name to set";["v"]="The value to set it to";};["private"]=false;["realm"]="cl";["summary"]="\
Sets a vector keyvalue ";};};["name"]="Material";["summary"]="\
The `Material` type is used to control shaders in rendering.";["typtbl"]="material_methods";};["Mesh"]={["class"]="class";["client"]=true;["description"]="\
Mesh type";["fields"]={};["methods"]={[1]="destroy";[2]="draw";["destroy"]={["class"]="function";["classlib"]="Mesh";["description"]="\
Frees the mesh from memory";["fname"]="destroy";["name"]="mesh_methods:destroy";["param"]={};["private"]=false;["realm"]="sh";["summary"]="\
Frees the mesh from memory ";};["draw"]={["class"]="function";["classlib"]="Mesh";["description"]="\
Draws the mesh. Must be in a 3D rendering context.";["fname"]="draw";["name"]="mesh_methods:draw";["param"]={};["private"]=false;["realm"]="sh";["summary"]="\
Draws the mesh.";};};["name"]="Mesh";["summary"]="\
Mesh type ";["typtbl"]="mesh_methods";};["Npc"]={["class"]="class";["description"]="\
Npc type";["fields"]={};["methods"]={[1]="addEntityRelationship";[10]="setEnemy";[11]="stop";[2]="addRelationship";[3]="attackMelee";[4]="attackRange";[5]="getEnemy";[6]="getRelationship";[7]="giveWeapon";[8]="goRun";[9]="goWalk";["addEntityRelationship"]={["class"]="function";["classlib"]="Npc";["description"]="\
Adds a relationship to the npc with an entity";["fname"]="addEntityRelationship";["name"]="npc_methods:addEntityRelationship";["param"]={[1]="ent";[2]="disp";[3]="priority";["disp"]="String of the relationship. (hate fear like neutral)";["ent"]="The target entity";["priority"]="number how strong the relationship is. Higher number is stronger";};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Adds a relationship to the npc with an entity ";};["addRelationship"]={["class"]="function";["classlib"]="Npc";["description"]="\
Adds a relationship to the npc";["fname"]="addRelationship";["name"]="npc_methods:addRelationship";["param"]={[1]="str";["str"]="The relationship string. http://wiki.garrysmod.com/page/NPC/AddRelationship";};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Adds a relationship to the npc ";};["attackMelee"]={["class"]="function";["classlib"]="Npc";["description"]="\
Makes the npc do a melee attack";["fname"]="attackMelee";["name"]="npc_methods:attackMelee";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Makes the npc do a melee attack ";};["attackRange"]={["class"]="function";["classlib"]="Npc";["description"]="\
Makes the npc do a ranged attack";["fname"]="attackRange";["name"]="npc_methods:attackRange";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Makes the npc do a ranged attack ";};["getEnemy"]={["class"]="function";["classlib"]="Npc";["description"]="\
Gets what the npc is fighting";["fname"]="getEnemy";["name"]="npc_methods:getEnemy";["param"]={};["private"]=false;["realm"]="sv";["ret"]="Entity the npc is fighting";["server"]=true;["summary"]="\
Gets what the npc is fighting ";};["getRelationship"]={["class"]="function";["classlib"]="Npc";["description"]="\
Gets the npc's relationship to the target";["fname"]="getRelationship";["name"]="npc_methods:getRelationship";["param"]={[1]="ent";["ent"]="Target entity";};["private"]=false;["realm"]="sv";["ret"]="string relationship of the npc with the target";["server"]=true;["summary"]="\
Gets the npc's relationship to the target ";};["giveWeapon"]={["class"]="function";["classlib"]="Npc";["description"]="\
Gives the npc a weapon";["fname"]="giveWeapon";["name"]="npc_methods:giveWeapon";["param"]={[1]="wep";["wep"]="The classname of the weapon";};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Gives the npc a weapon ";};["goRun"]={["class"]="function";["classlib"]="Npc";["description"]="\
Makes the npc run to a destination";["fname"]="goRun";["name"]="npc_methods:goRun";["param"]={[1]="vec";["vec"]="The position of the destination";};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Makes the npc run to a destination ";};["goWalk"]={["class"]="function";["classlib"]="Npc";["description"]="\
Makes the npc walk to a destination";["fname"]="goWalk";["name"]="npc_methods:goWalk";["param"]={[1]="vec";["vec"]="The position of the destination";};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Makes the npc walk to a destination ";};["setEnemy"]={["class"]="function";["classlib"]="Npc";["description"]="\
Tell the npc to fight this";["fname"]="setEnemy";["name"]="npc_methods:setEnemy";["param"]={[1]="ent";["ent"]="Target entity";};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Tell the npc to fight this ";};["stop"]={["class"]="function";["classlib"]="Npc";["description"]="\
Stops the npc";["fname"]="stop";["name"]="npc_methods:stop";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
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
PhysObj Type";["fields"]={};["methods"]={[1]="addAngleVelocity";[10]="getEntity";[11]="getInertia";[12]="getMass";[13]="getMassCenter";[14]="getMaterial";[15]="getMatrix";[16]="getMesh";[17]="getMeshConvexes";[18]="getPos";[19]="getVelocity";[2]="applyForceCenter";[20]="getVelocityAtPoint";[21]="isValid";[22]="localToWorld";[23]="localToWorldVector";[24]="setAngleVelocity";[25]="setInertia";[26]="setMass";[27]="setMaterial";[28]="setPos";[29]="setVelocity";[3]="applyForceOffset";[30]="wake";[31]="worldToLocal";[32]="worldToLocalVector";[4]="applyTorque";[5]="enableDrag";[6]="enableGravity";[7]="enableMotion";[8]="getAngleVelocity";[9]="getAngles";["addAngleVelocity"]={["class"]="function";["classlib"]="PhysObj";["description"]="\
Applys a angular velocity to an object";["fname"]="addAngleVelocity";["name"]="physobj_methods:addAngleVelocity";["param"]={[1]="angvel";["angvel"]="The local angvel vector to apply";};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Applys a angular velocity to an object ";};["applyForceCenter"]={["class"]="function";["classlib"]="PhysObj";["description"]="\
Applys a force to the center of the physics object";["fname"]="applyForceCenter";["name"]="physobj_methods:applyForceCenter";["param"]={[1]="force";["force"]="The force vector to apply";};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Applys a force to the center of the physics object ";};["applyForceOffset"]={["class"]="function";["classlib"]="PhysObj";["description"]="\
Applys an offset force to a physics object";["fname"]="applyForceOffset";["name"]="physobj_methods:applyForceOffset";["param"]={[1]="force";[2]="position";["force"]="The force vector to apply";["position"]="The position in world coordinates";};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Applys an offset force to a physics object ";};["applyTorque"]={["class"]="function";["classlib"]="PhysObj";["description"]="\
Applys a torque to a physics object";["fname"]="applyTorque";["name"]="physobj_methods:applyTorque";["param"]={[1]="torque";["torque"]="The world torque vector to apply";};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
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
Gets the material of the physics object ";};["getMatrix"]={["class"]="function";["classlib"]="PhysObj";["client"]=true;["description"]="\
Returns the world transform matrix of the physobj";["fname"]="getMatrix";["name"]="physobj_methods:getMatrix";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The matrix";["server"]=true;["summary"]="\
Returns the world transform matrix of the physobj ";};["getMesh"]={["class"]="function";["classlib"]="PhysObj";["description"]="\
Returns a table of MeshVertex structures where each 3 vertices represent a triangle. See: http://wiki.garrysmod.com/page/Structures/MeshVertex";["fname"]="getMesh";["name"]="physobj_methods:getMesh";["param"]={};["private"]=false;["realm"]="sh";["ret"]="table of MeshVertex structures";["summary"]="\
Returns a table of MeshVertex structures where each 3 vertices represent a triangle.";};["getMeshConvexes"]={["class"]="function";["classlib"]="PhysObj";["description"]="\
Returns a structured table, the physics mesh of the physics object. See: http://wiki.garrysmod.com/page/Structures/MeshVertex";["fname"]="getMeshConvexes";["name"]="physobj_methods:getMeshConvexes";["param"]={};["private"]=false;["realm"]="sh";["ret"]="table of MeshVertex structures";["summary"]="\
Returns a structured table, the physics mesh of the physics object.";};["getPos"]={["class"]="function";["classlib"]="PhysObj";["client"]=true;["description"]="\
Gets the position of the physics object";["fname"]="getPos";["name"]="physobj_methods:getPos";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Vector position of the physics object";["server"]=true;["summary"]="\
Gets the position of the physics object ";};["getVelocity"]={["class"]="function";["classlib"]="PhysObj";["client"]=true;["description"]="\
Gets the velocity of the physics object";["fname"]="getVelocity";["name"]="physobj_methods:getVelocity";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Vector velocity of the physics object";["server"]=true;["summary"]="\
Gets the velocity of the physics object ";};["getVelocityAtPoint"]={["class"]="function";["classlib"]="PhysObj";["client"]=true;["description"]="\
Gets the velocity of the physics object at an arbitrary point in its local reference frame \
This includes velocity at the point induced by rotational velocity";["fname"]="getVelocityAtPoint";["name"]="physobj_methods:getVelocityAtPoint";["param"]={[1]="vec";["vec"]="The point to get velocity of in local reference frame";};["private"]=false;["realm"]="sh";["ret"]="Vector Local velocity of the physics object at the point";["server"]=true;["summary"]="\
Gets the velocity of the physics object at an arbitrary point in its local reference frame \
This includes velocity at the point induced by rotational velocity ";};["isValid"]={["class"]="function";["classlib"]="PhysObj";["client"]=true;["description"]="\
Checks if the physics object is valid";["fname"]="isValid";["name"]="physobj_methods:isValid";["param"]={};["private"]=false;["realm"]="sh";["ret"]="boolean if the physics object is valid";["server"]=true;["summary"]="\
Checks if the physics object is valid ";};["localToWorld"]={["class"]="function";["classlib"]="PhysObj";["description"]="\
Returns a vector in the reference frame of the world from the local frame of the physicsobject";["fname"]="localToWorld";["name"]="physobj_methods:localToWorld";["param"]={[1]="vec";["vec"]="The vector to transform";};["private"]=false;["realm"]="sh";["ret"]="The transformed vector";["summary"]="\
Returns a vector in the reference frame of the world from the local frame of the physicsobject ";};["localToWorldVector"]={["class"]="function";["classlib"]="PhysObj";["description"]="\
Returns a normal vector in the reference frame of the world from the local frame of the physicsobject";["fname"]="localToWorldVector";["name"]="physobj_methods:localToWorldVector";["param"]={[1]="vec";["vec"]="The normal vector to transform";};["private"]=false;["realm"]="sh";["ret"]="The transformed vector";["summary"]="\
Returns a normal vector in the reference frame of the world from the local frame of the physicsobject ";};["setAngleVelocity"]={["class"]="function";["classlib"]="PhysObj";["description"]="\
Sets the angular velocity of an object";["fname"]="setAngleVelocity";["name"]="physobj_methods:setAngleVelocity";["param"]={[1]="angvel";["angvel"]="The local angvel vector to set";};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Sets the angular velocity of an object ";};["setInertia"]={["class"]="function";["classlib"]="PhysObj";["description"]="\
Sets the inertia of a physics object";["fname"]="setInertia";["name"]="physobj_methods:setInertia";["param"]={[1]="inertia";["inertia"]="The inertia vector to set it to";};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Sets the inertia of a physics object ";};["setMass"]={["class"]="function";["classlib"]="PhysObj";["description"]="\
Sets the mass of a physics object";["fname"]="setMass";["name"]="physobj_methods:setMass";["param"]={[1]="mass";["mass"]="The mass to set it to";};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Sets the mass of a physics object ";};["setMaterial"]={["class"]="function";["classlib"]="PhysObj";["description"]="\
Sets the physical material of a physics object";["fname"]="setMaterial";["name"]="physobj_methods:setMaterial";["param"]={[1]="material";["material"]="The physical material to set it to";};["private"]=false;["realm"]="sh";["summary"]="\
Sets the physical material of a physics object ";};["setPos"]={["class"]="function";["classlib"]="PhysObj";["description"]="\
Sets the position of the physics object. Will cause interpolation of the entity in clientside, use entity.setPos to avoid this.";["fname"]="setPos";["name"]="physobj_methods:setPos";["param"]={[1]="pos";["pos"]="The position vector to set it to";};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Sets the position of the physics object.";};["setVelocity"]={["class"]="function";["classlib"]="PhysObj";["description"]="\
Sets the velocity of the physics object";["fname"]="setVelocity";["name"]="physobj_methods:setVelocity";["param"]={[1]="vel";["vel"]="The velocity vector to set it to";};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Sets the velocity of the physics object ";};["wake"]={["class"]="function";["classlib"]="PhysObj";["description"]="\
Makes a sleeping physobj wakeup";["fname"]="wake";["name"]="physobj_methods:wake";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Makes a sleeping physobj wakeup ";};["worldToLocal"]={["class"]="function";["classlib"]="PhysObj";["description"]="\
Returns a vector in the local reference frame of the physicsobject from the world frame";["fname"]="worldToLocal";["name"]="physobj_methods:worldToLocal";["param"]={[1]="vec";["vec"]="The vector to transform";};["private"]=false;["realm"]="sh";["ret"]="The transformed vector";["summary"]="\
Returns a vector in the local reference frame of the physicsobject from the world frame ";};["worldToLocalVector"]={["class"]="function";["classlib"]="PhysObj";["description"]="\
Returns a normal vector in the local reference frame of the physicsobject from the world frame";["fname"]="worldToLocalVector";["name"]="physobj_methods:worldToLocalVector";["param"]={[1]="vec";["vec"]="The normal vector to transform";};["private"]=false;["realm"]="sh";["ret"]="The transformed vector";["summary"]="\
Returns a normal vector in the local reference frame of the physicsobject from the world frame ";};};["name"]="PhysObj";["server"]=true;["summary"]="\
PhysObj Type ";["typtbl"]="physobj_methods";};["Player"]={["class"]="class";["description"]="\
Player type";["fields"]={};["methods"]={[1]="getActiveWeapon";[10]="getGroundEntity";[11]="getJumpPower";[12]="getMaxSpeed";[13]="getName";[14]="getPing";[15]="getRunSpeed";[16]="getShootPos";[17]="getSteamID";[18]="getSteamID64";[19]="getTeam";[2]="getAimVector";[20]="getTeamName";[21]="getUniqueID";[22]="getUserID";[23]="getVehicle";[24]="getViewEntity";[25]="getWeapon";[26]="getWeapons";[27]="hasGodMode";[28]="inVehicle";[29]="isAdmin";[3]="getAmmoCount";[30]="isAlive";[31]="isBot";[32]="isConnected";[33]="isCrouching";[34]="isFlashlightOn";[35]="isFrozen";[36]="isMuted";[37]="isNPC";[38]="isNoclipped";[39]="isPlayer";[4]="getArmor";[40]="isSpeaking";[41]="isSprinting";[42]="isSuperAdmin";[43]="isTyping";[44]="isUserGroup";[45]="keyDown";[46]="setViewEntity";[47]="voiceVolume";[5]="getDeaths";[6]="getEyeTrace";[7]="getFOV";[8]="getFrags";[9]="getFriendStatus";["getActiveWeapon"]={["class"]="function";["classlib"]="Player";["client"]=true;["description"]="\
Returns the name of the player's active weapon";["fname"]="getActiveWeapon";["name"]="player_methods:getActiveWeapon";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The weapon";["server"]=true;["summary"]="\
Returns the name of the player's active weapon ";};["getAimVector"]={["class"]="function";["classlib"]="Player";["client"]=true;["description"]="\
Returns the player's aim vector";["fname"]="getAimVector";["name"]="player_methods:getAimVector";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Aim vector";["server"]=true;["summary"]="\
Returns the player's aim vector ";};["getAmmoCount"]={["class"]="function";["classlib"]="Player";["client"]=true;["description"]="\
Gets the amount of ammo the player has.";["fname"]="getAmmoCount";["name"]="player_methods:getAmmoCount";["param"]={[1]="id";["id"]="The string or number id of the ammo";};["private"]=false;["realm"]="sh";["ret"]="The amount of ammo player has in reserve.";["server"]=true;["summary"]="\
Gets the amount of ammo the player has.";};["getArmor"]={["class"]="function";["classlib"]="Player";["client"]=true;["description"]="\
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
Returns the relationship of the player to the local client ";};["getGroundEntity"]={["class"]="function";["classlib"]="Player";["client"]=true;["description"]="\
Returns the entity that the player is standing on";["fname"]="getGroundEntity";["name"]="player_methods:getGroundEntity";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Ground entity";["server"]=true;["summary"]="\
Returns the entity that the player is standing on ";};["getJumpPower"]={["class"]="function";["classlib"]="Player";["client"]=true;["description"]="\
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
Returns the player's user ID ";};["getVehicle"]={["class"]="function";["classlib"]="Player";["client"]=true;["description"]="\
Returns the vehicle the player is driving";["fname"]="getVehicle";["name"]="player_methods:getVehicle";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Vehicle if player in vehicle or nil";["server"]=true;["summary"]="\
Returns the vehicle the player is driving ";};["getViewEntity"]={["class"]="function";["classlib"]="Player";["client"]=true;["description"]="\
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
Returns whether the player is a player ";};["isSpeaking"]={["class"]="function";["classlib"]="Player";["client"]=true;["description"]="\
Returns whether the player is heard by the local player.";["fname"]="isSpeaking";["name"]="player_methods:isSpeaking";["param"]={};["private"]=false;["realm"]="cl";["ret"]="bool true/false";["summary"]="\
Returns whether the player is heard by the local player.";};["isSprinting"]={["class"]="function";["classlib"]="Player";["client"]=true;["description"]="\
Returns whether the player is sprinting";["fname"]="isSprinting";["name"]="player_methods:isSprinting";["param"]={};["private"]=false;["realm"]="sh";["ret"]="bool true/false";["server"]=true;["summary"]="\
Returns whether the player is sprinting ";};["isSuperAdmin"]={["class"]="function";["classlib"]="Player";["client"]=true;["description"]="\
Returns whether the player is a super admin";["fname"]="isSuperAdmin";["name"]="player_methods:isSuperAdmin";["param"]={};["private"]=false;["realm"]="sh";["ret"]="True if player is super admin";["server"]=true;["summary"]="\
Returns whether the player is a super admin ";};["isTyping"]={["class"]="function";["classlib"]="Player";["client"]=true;["description"]="\
Returns whether the player is typing in their chat";["fname"]="isTyping";["name"]="player_methods:isTyping";["param"]={};["private"]=false;["realm"]="sh";["ret"]="bool true/false";["server"]=true;["summary"]="\
Returns whether the player is typing in their chat ";};["isUserGroup"]={["class"]="function";["classlib"]="Player";["client"]=true;["description"]="\
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
Sets the view entity of the player.";};["voiceVolume"]={["class"]="function";["classlib"]="Player";["client"]=true;["description"]="\
Returns the voice volume of the player";["fname"]="voiceVolume";["name"]="player_methods:voiceVolume";["param"]={};["private"]=false;["realm"]="cl";["ret"]="Returns the players voice volume, how loud the player's voice communication currently is, as a normal number. Doesn't work on local player unless the voice_loopback convar is set to 1.";["summary"]="\
Returns the voice volume of the player ";};};["name"]="Player";["summary"]="\
Player type ";["typtbl"]="player_methods";};["Quaternion"]={["class"]="class";["description"]="\
Quaternion type";["fields"]={};["methods"]={[1]="clone";[10]="set";[11]="up";[2]="conj";[3]="forward";[4]="i";[5]="j";[6]="k";[7]="r";[8]="real";[9]="right";["clone"]={["class"]="function";["classlib"]="Quaternion";["description"]="\
Copies from quaternion and returns a new quaternion";["fname"]="clone";["name"]="quat_methods:clone";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The copy of the quaternion";["summary"]="\
Copies from quaternion and returns a new quaternion ";};["conj"]={["class"]="function";["classlib"]="Quaternion";["description"]="\
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
Returns vector pointing right for <this> ";};["set"]={["class"]="function";["classlib"]="Quaternion";["description"]="\
Copies a quaternion to another.";["fname"]="set";["name"]="quat_methods:set";["param"]={[1]="b";["b"]="The quaternion to copy from.";};["private"]=false;["realm"]="sh";["ret"]="nil";["summary"]="\
Copies a quaternion to another.";};["up"]={["class"]="function";["classlib"]="Quaternion";["description"]="\
Returns vector pointing up for <this>";["fname"]="up";["name"]="quat_methods:up";["param"]={};["private"]=false;["realm"]="sh";["summary"]="\
Returns vector pointing up for <this> ";};};["name"]="Quaternion";["summary"]="\
Quaternion type ";["typtbl"]="quat_methods";};["Sound"]={["class"]="class";["client"]=true;["description"]="\
Sound type";["fields"]={};["methods"]={[1]="destroy";[2]="isPlaying";[3]="play";[4]="setPitch";[5]="setSoundLevel";[6]="setVolume";[7]="stop";["destroy"]={["class"]="function";["classlib"]="Sound";["description"]="\
Removes the sound from the game so new one can be created if limit is reached";["fname"]="destroy";["name"]="sound_methods:destroy";["param"]={};["private"]=false;["realm"]="sh";["summary"]="\
Removes the sound from the game so new one can be created if limit is reached ";};["isPlaying"]={["class"]="function";["classlib"]="Sound";["description"]="\
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
Sound type ";["typtbl"]="sound_methods";};["StringStream"]={["class"]="class";["description"]="\
StringStream type";["fields"]={};["methods"]={[1]="getBuffer";[10]="readUInt16";[11]="readUInt32";[12]="readUInt8";[13]="readUntil";[14]="seek";[15]="setEndian";[16]="size";[17]="skip";[18]="tell";[19]="write";[2]="getString";[20]="writeDouble";[21]="writeFloat";[22]="writeInt16";[23]="writeInt32";[24]="writeInt8";[25]="writeString";[3]="read";[4]="readDouble";[5]="readFloat";[6]="readInt16";[7]="readInt32";[8]="readInt8";[9]="readString";["getBuffer"]={["class"]="function";["classlib"]="StringStream";["description"]="\
Returns the internal buffer";["fname"]="getBuffer";["name"]="ss_methods:getBuffer";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The buffer table";["summary"]="\
Returns the internal buffer ";};["getString"]={["class"]="function";["classlib"]="StringStream";["description"]="\
Returns the buffer as a string";["fname"]="getString";["name"]="ss_methods:getString";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The buffer as a string";["summary"]="\
Returns the buffer as a string ";};["read"]={["class"]="function";["classlib"]="StringStream";["description"]="\
Reads the specified number of bytes from the buffer and advances the buffer pointer.";["fname"]="read";["name"]="ss_methods:read";["param"]={[1]="n";["n"]="How many bytes to read";};["private"]=false;["realm"]="sh";["ret"]="A string containing the bytes";["summary"]="\
Reads the specified number of bytes from the buffer and advances the buffer pointer.";};["readDouble"]={["class"]="function";["classlib"]="StringStream";["description"]="\
Reads a 4 byte IEEE754 float from the byte stream and advances the buffer pointer.";["fname"]="readDouble";["name"]="ss_methods:readDouble";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The float32 at this position";["summary"]="\
Reads a 4 byte IEEE754 float from the byte stream and advances the buffer pointer.";};["readFloat"]={["class"]="function";["classlib"]="StringStream";["description"]="\
Reads a 4 byte IEEE754 float from the byte stream and advances the buffer pointer.";["fname"]="readFloat";["name"]="ss_methods:readFloat";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The float32 at this position";["summary"]="\
Reads a 4 byte IEEE754 float from the byte stream and advances the buffer pointer.";};["readInt16"]={["class"]="function";["classlib"]="StringStream";["description"]="\
Reads a signed 16-bit (two byte) integer from the byte stream and advances the buffer pointer.";["fname"]="readInt16";["name"]="ss_methods:readInt16";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The int16 at this position";["summary"]="\
Reads a signed 16-bit (two byte) integer from the byte stream and advances the buffer pointer.";};["readInt32"]={["class"]="function";["classlib"]="StringStream";["description"]="\
Reads a signed 32-bit (four byte) integer from the byte stream and advances the buffer pointer.";["fname"]="readInt32";["name"]="ss_methods:readInt32";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The int32 at this position";["summary"]="\
Reads a signed 32-bit (four byte) integer from the byte stream and advances the buffer pointer.";};["readInt8"]={["class"]="function";["classlib"]="StringStream";["description"]="\
Reads a signed 8-bit (one byte) integer from the byte stream and advances the buffer pointer.";["fname"]="readInt8";["name"]="ss_methods:readInt8";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The int8 at this position";["summary"]="\
Reads a signed 8-bit (one byte) integer from the byte stream and advances the buffer pointer.";};["readString"]={["class"]="function";["classlib"]="StringStream";["description"]="\
returns a null terminated string, reads until \"\\x00\" and advances the buffer pointer.";["fname"]="readString";["name"]="ss_methods:readString";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The string of bytes read";["summary"]="\
returns a null terminated string, reads until \"\\x00\" and advances the buffer pointer.";};["readUInt16"]={["class"]="function";["classlib"]="StringStream";["description"]="\
Reads an unsigned 16 bit (two byte) integer from the byte stream and advances the buffer pointer.";["fname"]="readUInt16";["name"]="ss_methods:readUInt16";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The uint16 at this position";["summary"]="\
Reads an unsigned 16 bit (two byte) integer from the byte stream and advances the buffer pointer.";};["readUInt32"]={["class"]="function";["classlib"]="StringStream";["description"]="\
Reads an unsigned 32 bit (four byte) integer from the byte stream and advances the buffer pointer.";["fname"]="readUInt32";["name"]="ss_methods:readUInt32";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The uint32 at this position";["summary"]="\
Reads an unsigned 32 bit (four byte) integer from the byte stream and advances the buffer pointer.";};["readUInt8"]={["class"]="function";["classlib"]="StringStream";["description"]="\
Reads an unsigned 8-bit (one byte) integer from the byte stream and advances the buffer pointer.";["fname"]="readUInt8";["name"]="ss_methods:readUInt8";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The uint8 at this position";["summary"]="\
Reads an unsigned 8-bit (one byte) integer from the byte stream and advances the buffer pointer.";};["readUntil"]={["class"]="function";["classlib"]="StringStream";["description"]="\
Reads until the given byte and advances the buffer pointer.";["fname"]="readUntil";["name"]="ss_methods:readUntil";["param"]={[1]="byte";["byte"]="The byte to read until (in number form)";};["private"]=false;["realm"]="sh";["ret"]="The string of bytes read";["summary"]="\
Reads until the given byte and advances the buffer pointer.";};["seek"]={["class"]="function";["classlib"]="StringStream";["description"]="\
Sets internal pointer to i. The position will be clamped to [1, buffersize+1]";["fname"]="seek";["name"]="ss_methods:seek";["param"]={[1]="i";["i"]="The position";};["private"]=false;["realm"]="sh";["summary"]="\
Sets internal pointer to i.";};["setEndian"]={["class"]="function";["classlib"]="StringStream";["description"]="\
Sets the endianness of the string stream";["fname"]="setEndian";["name"]="ss_methods:setEndian";["param"]={[1]="endian";["endian"]="The endianness of number types. \"big\" or \"little\" (default \"little\")";};["private"]=false;["realm"]="sh";["summary"]="\
Sets the endianness of the string stream ";};["size"]={["class"]="function";["classlib"]="StringStream";["description"]="\
Tells the size of the byte stream.";["fname"]="size";["name"]="ss_methods:size";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The buffer size";["summary"]="\
Tells the size of the byte stream.";};["skip"]={["class"]="function";["classlib"]="StringStream";["description"]="\
Move the internal pointer by amount i";["fname"]="skip";["name"]="ss_methods:skip";["param"]={[1]="i";["i"]="The offset";};["private"]=false;["realm"]="sh";["summary"]="\
Move the internal pointer by amount i ";};["tell"]={["class"]="function";["classlib"]="StringStream";["description"]="\
Returns the internal position of the byte reader.";["fname"]="tell";["name"]="ss_methods:tell";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The buffer position";["summary"]="\
Returns the internal position of the byte reader.";};["write"]={["class"]="function";["classlib"]="StringStream";["description"]="\
Writes the given string and advances the buffer pointer.";["fname"]="write";["name"]="ss_methods:write";["param"]={[1]="bytes";["bytes"]="A string of bytes to write";};["private"]=false;["realm"]="sh";["summary"]="\
Writes the given string and advances the buffer pointer.";};["writeDouble"]={["class"]="function";["classlib"]="StringStream";["description"]="\
Writes a 8 byte IEEE754 double to the byte stream and advances the buffer pointer.";["fname"]="writeDouble";["name"]="ss_methods:writeDouble";["param"]={[1]="x";["x"]="The double to write";};["private"]=false;["realm"]="sh";["summary"]="\
Writes a 8 byte IEEE754 double to the byte stream and advances the buffer pointer.";};["writeFloat"]={["class"]="function";["classlib"]="StringStream";["description"]="\
Writes a 4 byte IEEE754 float to the byte stream and advances the buffer pointer.";["fname"]="writeFloat";["name"]="ss_methods:writeFloat";["param"]={[1]="x";["x"]="The float to write";};["private"]=false;["realm"]="sh";["summary"]="\
Writes a 4 byte IEEE754 float to the byte stream and advances the buffer pointer.";};["writeInt16"]={["class"]="function";["classlib"]="StringStream";["description"]="\
Writes a short to the buffer and advances the buffer pointer.";["fname"]="writeInt16";["name"]="ss_methods:writeInt16";["param"]={[1]="x";["x"]="An int16 to write";};["private"]=false;["realm"]="sh";["summary"]="\
Writes a short to the buffer and advances the buffer pointer.";};["writeInt32"]={["class"]="function";["classlib"]="StringStream";["description"]="\
Writes an int to the buffer and advances the buffer pointer.";["fname"]="writeInt32";["name"]="ss_methods:writeInt32";["param"]={[1]="x";["x"]="An int32 to write";};["private"]=false;["realm"]="sh";["summary"]="\
Writes an int to the buffer and advances the buffer pointer.";};["writeInt8"]={["class"]="function";["classlib"]="StringStream";["description"]="\
Writes a byte to the buffer and advances the buffer pointer.";["fname"]="writeInt8";["name"]="ss_methods:writeInt8";["param"]={[1]="x";["x"]="An int8 to write";};["private"]=false;["realm"]="sh";["summary"]="\
Writes a byte to the buffer and advances the buffer pointer.";};["writeString"]={["class"]="function";["classlib"]="StringStream";["description"]="\
Writes a string to the buffer putting a null at the end and advances the buffer pointer.";["fname"]="writeString";["name"]="ss_methods:writeString";["param"]={[1]="string";["string"]="The string of bytes to write";};["private"]=false;["realm"]="sh";["summary"]="\
Writes a string to the buffer putting a null at the end and advances the buffer pointer.";};};["name"]="StringStream";["summary"]="\
StringStream type ";["typtbl"]="ss_methods";};["VMatrix"]={["class"]="class";["description"]="\
VMatrix type";["fields"]={};["methods"]={[1]="clone";[10]="getTranslation";[11]="getTransposed";[12]="getUp";[13]="invert";[14]="invertTR";[15]="isIdentity";[16]="isRotationMatrix";[17]="rotate";[18]="scale";[19]="scaleTranslation";[2]="getAngles";[20]="set";[21]="setAngles";[22]="setField";[23]="setForward";[24]="setIdentity";[25]="setRight";[26]="setScale";[27]="setTranslation";[28]="setUp";[29]="toTable";[3]="getAxisAngle";[30]="translate";[31]="transpose";[4]="getField";[5]="getForward";[6]="getInverse";[7]="getInverseTR";[8]="getRight";[9]="getScale";["clone"]={["class"]="function";["classlib"]="VMatrix";["description"]="\
Copies The matrix and returns a new matrix";["fname"]="clone";["name"]="vmatrix_methods:clone";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The copy of the matrix";["summary"]="\
Copies The matrix and returns a new matrix ";};["getAngles"]={["class"]="function";["classlib"]="VMatrix";["description"]="\
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
Vector type";["fields"]={};["methods"]={[1]="add";[10]="getLength";[11]="getLength2D";[12]="getLength2DSqr";[13]="getLengthSqr";[14]="getNormalized";[15]="isEqualTol";[16]="isInWorld";[17]="isZero";[18]="mul";[19]="normalize";[2]="clone";[20]="rotate";[21]="rotateAroundAxis";[22]="set";[23]="setX";[24]="setY";[25]="setZ";[26]="setZero";[27]="sub";[28]="toScreen";[29]="vdiv";[3]="cross";[30]="vmul";[31]="withinAABox";[4]="div";[5]="dot";[6]="getAngle";[7]="getAngleEx";[8]="getDistance";[9]="getDistanceSqr";["add"]={["class"]="function";["classlib"]="Vector";["description"]="\
Add vector - Modifies self.";["fname"]="add";["name"]="vec_methods:add";["param"]={[1]="v";["v"]="Vector to add";};["private"]=false;["realm"]="sh";["ret"]="nil";["summary"]="\
Add vector - Modifies self.";};["clone"]={["class"]="function";["classlib"]="Vector";["description"]="\
Copies x,y,z from a vector and returns a new vector";["fname"]="clone";["name"]="vec_methods:clone";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The copy of the vector";["summary"]="\
Copies x,y,z from a vector and returns a new vector ";};["cross"]={["class"]="function";["classlib"]="Vector";["description"]="\
Calculates the cross product of the 2 vectors, creates a unique perpendicular vector to both input vectors.";["fname"]="cross";["name"]="vec_methods:cross";["param"]={[1]="v";["v"]="Second Vector";};["private"]=false;["realm"]="sh";["ret"]="Vector";["summary"]="\
Calculates the cross product of the 2 vectors, creates a unique perpendicular vector to both input vectors.";};["div"]={["class"]="function";["classlib"]="Vector";["description"]="\
\"Scalar Division\" of the vector. Self-Modifies.";["fname"]="div";["name"]="vec_methods:div";["param"]={[1]="n";["n"]="Scalar to divide by.";};["private"]=false;["realm"]="sh";["ret"]="nil";["summary"]="\
\"Scalar Division\" of the vector.";};["dot"]={["class"]="function";["classlib"]="Vector";["description"]="\
Dot product is the cosine of the angle between both vectors multiplied by their lengths. A.B = ||A||||B||cosA.";["fname"]="dot";["name"]="vec_methods:dot";["param"]={[1]="v";["v"]="Second Vector";};["private"]=false;["realm"]="sh";["ret"]="Number";["summary"]="\
Dot product is the cosine of the angle between both vectors multiplied by their lengths.";};["getAngle"]={["class"]="function";["classlib"]="Vector";["description"]="\
Get the vector's angle.";["fname"]="getAngle";["name"]="vec_methods:getAngle";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Angle";["summary"]="\
Get the vector's angle.";};["getAngleEx"]={["class"]="function";["classlib"]="Vector";["description"]="\
Returns the vector's euler angle with respect to the other vector as if it were the new vertical axis.";["fname"]="getAngleEx";["name"]="vec_methods:getAngleEx";["param"]={[1]="v";["v"]="Second Vector";};["private"]=false;["realm"]="sh";["ret"]="Angle";["summary"]="\
Returns the vector's euler angle with respect to the other vector as if it were the new vertical axis.";};["getDistance"]={["class"]="function";["classlib"]="Vector";["description"]="\
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
Is this vector and v equal within tolerance t.";};["isInWorld"]={["class"]="function";["classlib"]="Vector";["description"]="\
Returns whether the vector is in world";["fname"]="isInWorld";["name"]="vec_methods:isInWorld";["param"]={};["private"]=false;["realm"]="sv";["ret"]="bool True/False.";["server"]=true;["summary"]="\
Returns whether the vector is in world ";};["isZero"]={["class"]="function";["classlib"]="Vector";["description"]="\
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
Vehicle type";["fields"]={};["methods"]={[1]="ejectDriver";[2]="getDriver";[3]="getPassenger";[4]="killDriver";[5]="lock";[6]="stripDriver";[7]="unlock";["ejectDriver"]={["class"]="function";["classlib"]="Vehicle";["description"]="\
Ejects the driver of the vehicle";["fname"]="ejectDriver";["name"]="vehicle_methods:ejectDriver";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Ejects the driver of the vehicle ";};["getDriver"]={["class"]="function";["classlib"]="Vehicle";["description"]="\
Returns the driver of the vehicle";["fname"]="getDriver";["name"]="vehicle_methods:getDriver";["param"]={};["private"]=false;["realm"]="sv";["ret"]="Driver of vehicle";["server"]=true;["summary"]="\
Returns the driver of the vehicle ";};["getPassenger"]={["class"]="function";["classlib"]="Vehicle";["description"]="\
Returns a passenger of a vehicle";["fname"]="getPassenger";["name"]="vehicle_methods:getPassenger";["param"]={[1]="n";["n"]="The index of the passenger to get";};["private"]=false;["realm"]="sv";["ret"]="The passenger or NULL if empty";["server"]=true;["summary"]="\
Returns a passenger of a vehicle ";};["killDriver"]={["class"]="function";["classlib"]="Vehicle";["description"]="\
Kills the driver of the vehicle";["fname"]="killDriver";["name"]="vehicle_methods:killDriver";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Kills the driver of the vehicle ";};["lock"]={["class"]="function";["classlib"]="Vehicle";["description"]="\
Will lock the vehicle preventing players from entering or exiting the vehicle.";["fname"]="lock";["name"]="vehicle_methods:lock";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Will lock the vehicle preventing players from entering or exiting the vehicle.";};["stripDriver"]={["class"]="function";["classlib"]="Vehicle";["description"]="\
Strips weapons of the driver";["fname"]="stripDriver";["name"]="vehicle_methods:stripDriver";["param"]={[1]="class";["class"]="Optional weapon class to strip. Otherwise all are stripped.";};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Strips weapons of the driver ";};["unlock"]={["class"]="function";["classlib"]="Vehicle";["description"]="\
Will unlock the vehicle.";["fname"]="unlock";["name"]="vehicle_methods:unlock";["param"]={};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Will unlock the vehicle.";};};["name"]="Vehicle";["summary"]="\
Vehicle type ";["typtbl"]="vehicle_methods";};["Weapon"]={["class"]="class";["description"]="\
Weapon type";["fields"]={};["methods"]={[1]="clip1";[10]="getToolMode";[11]="isCarriedByLocalPlayer";[12]="isWeaponVisible";[13]="lastShootTime";[2]="clip2";[3]="getActivity";[4]="getHoldType";[5]="getNextPrimaryFire";[6]="getNextSecondaryFire";[7]="getPrimaryAmmoType";[8]="getPrintName";[9]="getSecondaryAmmoType";["clip1"]={["class"]="function";["classlib"]="Weapon";["client"]=true;["description"]="\
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
Gets the secondary ammo type of the given weapon.";};["getToolMode"]={["class"]="function";["classlib"]="Weapon";["client"]=true;["description"]="\
Returns the tool mode of the toolgun";["fname"]="getToolMode";["name"]="weapon_methods:getToolMode";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The tool mode of the toolgun";["server"]=true;["summary"]="\
Returns the tool mode of the toolgun ";};["isCarriedByLocalPlayer"]={["class"]="function";["classlib"]="Weapon";["client"]=true;["description"]="\
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
-- CODE";};};["hooks"]={[1]="Dupefinished";[10]="KeyPress";[11]="KeyRelease";[12]="NetworkEntityCreated";[13]="OnEntityCreated";[14]="OnPhysgunFreeze";[15]="OnPhysgunReload";[16]="PhysgunDrop";[17]="PhysgunPickup";[18]="PlayerCanPickupWeapon";[19]="PlayerChat";[2]="EndEntityDriving";[20]="PlayerDeath";[21]="PlayerDisconnected";[22]="PlayerEnteredVehicle";[23]="PlayerHurt";[24]="PlayerInitialSpawn";[25]="PlayerLeaveVehicle";[26]="PlayerNoClip";[27]="PlayerSay";[28]="PlayerSpawn";[29]="PlayerSpray";[3]="EntityFireBullets";[30]="PlayerSwitchFlashlight";[31]="PlayerSwitchWeapon";[32]="PlayerUse";[33]="PropBreak";[34]="Removed";[35]="StartChat";[36]="StartEntityDriving";[37]="calcview";[38]="drawhud";[39]="hologrammatrix";[4]="EntityRemoved";[40]="hudconnected";[41]="huddisconnected";[42]="input";[43]="inputPressed";[44]="inputReleased";[45]="mouseWheeled";[46]="mousemoved";[47]="net";[48]="permissionrequest";[49]="postdrawhud";[5]="EntityTakeDamage";[50]="postdrawopaquerenderables";[51]="predrawhud";[52]="predrawopaquerenderables";[53]="readcell";[54]="remote";[55]="render";[56]="renderoffscreen";[57]="starfallUsed";[58]="think";[59]="tick";[6]="FinishChat";[60]="writecell";[61]="xinputConnected";[62]="xinputDisconnected";[63]="xinputPressed";[64]="xinputReleased";[65]="xinputStick";[66]="xinputTrigger";[7]="GravGunOnDropped";[8]="GravGunOnPickedUp";[9]="GravGunPunt";["Dupefinished"]={["class"]="hook";["classForced"]=true;["description"]="\
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
Called when the engine wants to calculate the player's view";["name"]="calcview";["param"]={[1]="pos";[2]="ang";[3]="fov";[4]="znear";[5]="zfar";["ang"]="Current angles of the camera";["fov"]="Current fov of the camera";["pos"]="Current position of the camera";["zfar"]="Current far plane of the camera";["znear"]="Current near plane of the camera";};["realm"]="cl";["ret"]="table Table containing information for the camera. {origin=camera origin, angles=camera angles, fov=camera fov, znear=znear, zfar=zfar, drawviewer=drawviewer}";["summary"]="\
Called when the engine wants to calculate the player's view ";};["drawhud"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Called when a frame is requested to be drawn on hud. (2D Context)";["name"]="drawhud";["param"]={};["realm"]="cl";["summary"]="\
Called when a frame is requested to be drawn on hud.";};["hologrammatrix"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Called before entities are drawn. You can't render anything, but you can edit hologram matrices before they are drawn.";["name"]="hologrammatrix";["param"]={};["realm"]="cl";["summary"]="\
Called before entities are drawn.";};["hudconnected"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Called when the player connects to a HUD component linked to the Starfall Chip";["name"]="hudconnected";["param"]={};["realm"]="cl";["summary"]="\
Called when the player connects to a HUD component linked to the Starfall Chip ";};["huddisconnected"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Called when the player disconnects from a HUD component linked to the Starfall Chip";["name"]="huddisconnected";["param"]={};["realm"]="cl";["summary"]="\
Called when the player disconnects from a HUD component linked to the Starfall Chip ";};["input"]={["class"]="hook";["classForced"]=true;["description"]="\
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
Called when a player uses the screen";["name"]="starfallUsed";["param"]={[1]="activator";["activator"]="Player using the screen";};["realm"]="cl";["summary"]="\
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
Called when a stick on the controller has moved. Client must have XInput Lua binary installed.";["name"]="xinputStick";["param"]={[1]="id";[2]="stick";[3]="x";[4]="y";[5]="when";["id"]="Controller number. Starts at 0";["stick"]="The stick that was moved. 0 is left";["when"]="The timer.realtime() at which this event occurred.";["x"]="The X coordinate of the trigger. -32768 - 32767 inclusive";["y"]="The Y coordinate of the trigger. -32768 - 32767 inclusive";};["realm"]="cl";["summary"]="\
Called when a stick on the controller has moved.";};["xinputTrigger"]={["class"]="hook";["classForced"]=true;["client"]=true;["description"]="\
Called when a trigger on the controller has moved. Client must have XInput Lua binary installed.";["name"]="xinputTrigger";["param"]={[1]="id";[2]="trigger";[3]="value";[4]="when";["id"]="Controller number. Starts at 0";["trigger"]="The trigger that was moved. 0 is left";["value"]="The position of the trigger. 0-255 inclusive";["when"]="The timer.realtime() at which this event occurred.";};["realm"]="cl";["summary"]="\
Called when a trigger on the controller has moved.";};};["libraries"]={[1]="bass";[10]="game";[11]="holograms";[12]="hook";[13]="http";[14]="input";[15]="joystick";[16]="json";[17]="light";[18]="material";[19]="mesh";[2]="bit";[20]="net";[21]="particle";[22]="physenv";[23]="prop";[24]="quaternion";[25]="render";[26]="sounds";[27]="sql";[28]="team";[29]="timer";[3]="builtin";[30]="trace";[31]="von";[32]="wire";[33]="xinput";[4]="constraint";[5]="coroutine";[6]="effect";[7]="fastlz";[8]="file";[9]="find";["bass"]={["class"]="library";["client"]=true;["description"]="\
`bass` library is intended to be used only on client side. It's good for streaming local and remote sound files and playing them directly in player's \"2D\" context.";["fields"]={};["functions"]={[1]="loadFile";[2]="loadURL";[3]="soundsLeft";["loadFile"]={["class"]="function";["description"]="\
Loads a sound channel from a file.";["fname"]="loadFile";["library"]="bass";["name"]="bass_library.loadFile";["param"]={[1]="path";[2]="flags";[3]="callback";["callback"]="Function which is called when the sound channel is loaded. It'll get 3 arguments: `Bass` object, error number and name.";["flags"]="Flags for the sound (`3d`, `mono`, `noplay`, `noblock`).";["path"]="File path to play from.";};["private"]=false;["realm"]="cl";["summary"]="\
Loads a sound channel from a file.";};["loadURL"]={["class"]="function";["description"]="\
Loads a sound channel from an URL.";["fname"]="loadURL";["library"]="bass";["name"]="bass_library.loadURL";["param"]={[1]="path";[2]="flags";[3]="callback";["callback"]="Function which is called when the sound channel is loaded. It'll get 3 arguments: `Bass` object, error number and name.";["flags"]="Flags for the sound (`3d`, `mono`, `noplay`, `noblock`).";["path"]="URL path to play from.";};["private"]=false;["realm"]="cl";["summary"]="\
Loads a sound channel from an URL.";};["soundsLeft"]={["class"]="function";["description"]="\
Returns the number of sounds left that can be created";["fname"]="soundsLeft";["library"]="bass";["name"]="bass_library.soundsLeft";["param"]={};["private"]=false;["realm"]="cl";["ret"]="The number of sounds left";["summary"]="\
Returns the number of sounds left that can be created ";};};["libtbl"]="bass_library";["name"]="bass";["summary"]="\
`bass` library is intended to be used only on client side.";["tables"]={};};["bit"]={["class"]="library";["client"]=true;["description"]="\
Bit library http://wiki.garrysmod.com/page/Category:bit";["fields"]={};["functions"]={[1]="stringstream";["stringstream"]={["class"]="function";["description"]="\
Creates a StringStream object";["fname"]="stringstream";["library"]="bit";["name"]="bit_library.stringstream";["param"]={[1]="stream";[2]="i";[3]="endian";["endian"]="The endianness of number types. \"big\" or \"little\" (default \"little\")";["i"]="The initial buffer pointer (default 1)";["stream"]="A string to set the initial buffer to (default \"\")";};["private"]=false;["realm"]="sh";["summary"]="\
Creates a StringStream object ";};};["libtbl"]="bit_library";["name"]="bit";["server"]=true;["summary"]="\
Bit library http://wiki.garrysmod.com/page/Category:bit ";["tables"]={};};["builtin"]={["class"]="library";["classForced"]=true;["client"]=true;["description"]="\
Built in values. These don't need to be loaded; they are in the default environment.";["fields"]={[1]="CLIENT";[2]="SERVER";["CLIENT"]={["class"]="field";["classForced"]=true;["description"]="\
Constant that denotes whether the code is executed on the client";["library"]="builtin";["name"]="SF.DefaultEnvironment.CLIENT";["param"]={};["summary"]="\
Constant that denotes whether the code is executed on the client ";};["SERVER"]={["class"]="field";["classForced"]=true;["description"]="\
Constant that denotes whether the code is executed on the server";["library"]="builtin";["name"]="SF.DefaultEnvironment.SERVER";["param"]={};["summary"]="\
Constant that denotes whether the code is executed on the server ";};};["functions"]={[1]="assert";[10]="error";[11]="eyeAngles";[12]="eyePos";[13]="eyeVector";[14]="getLibraries";[15]="getScripts";[16]="getUserdata";[17]="getfenv";[18]="getmetatable";[19]="hasPermission";[2]="chip";[20]="ipairs";[21]="isFirstTimePredicted";[22]="isValid";[23]="loadstring";[24]="localToWorld";[25]="next";[26]="owner";[27]="pairs";[28]="pcall";[29]="permissionRequestSatisfied";[3]="class";[30]="player";[31]="printMessage";[32]="printTable";[33]="quotaAverage";[34]="quotaMax";[35]="quotaTotalAverage";[36]="quotaTotalUsed";[37]="quotaUsed";[38]="ramAverage";[39]="ramUsed";[4]="concmd";[40]="rawget";[41]="rawset";[42]="require";[43]="requiredir";[44]="select";[45]="setClipboardText";[46]="setName";[47]="setSoftQuota";[48]="setUserdata";[49]="setfenv";[5]="crc";[50]="setmetatable";[51]="setupPermissionRequest";[52]="throw";[53]="tonumber";[54]="tostring";[55]="try";[56]="type";[57]="unpack";[58]="version";[59]="worldToLocal";[6]="debugGetInfo";[60]="xpcall";[7]="dodir";[8]="dofile";[9]="entity";["assert"]={["class"]="function";["classForced"]=true;["description"]="\
If the result of the first argument is false or nil, an error is thrown with the second argument as the message.";["fname"]="assert";["library"]="builtin";["name"]="SF.DefaultEnvironment.assert";["param"]={[1]="condition";[2]="msg";["condition"]="";["msg"]="";};["private"]=false;["realm"]="sh";["summary"]="\
If the result of the first argument is false or nil, an error is thrown with the second argument as the message.";};["chip"]={["class"]="function";["classForced"]=true;["description"]="\
Returns the entity representing a processor that this script is running on.";["fname"]="chip";["library"]="builtin";["name"]="SF.DefaultEnvironment.chip";["param"]={};["realm"]="sh";["ret"]="Starfall entity";["summary"]="\
Returns the entity representing a processor that this script is running on.";};["class"]={["class"]="function";["description"]="\
Creates a 'middleclass' class object that can be used similarly to Java/C++ classes. See https://github.com/kikito/middleclass for examples.";["fname"]="class";["library"]="builtin";["name"]="SF.DefaultEnvironment.class";["param"]={[1]="name";[2]="super";["name"]="The string name of the class";["super"]="The (optional) parent class to inherit from";};["private"]=false;["realm"]="sh";["summary"]="\
Creates a 'middleclass' class object that can be used similarly to Java/C++ classes.";};["concmd"]={["class"]="function";["client"]=true;["description"]="\
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
Throws a raw exception.";};["eyeAngles"]={["class"]="function";["client"]=true;["description"]="\
Returns the local player's camera angles";["fname"]="eyeAngles";["library"]="builtin";["name"]="SF.DefaultEnvironment.eyeAngles";["param"]={};["private"]=false;["realm"]="cl";["ret"]="The local player's camera angles";["summary"]="\
Returns the local player's camera angles ";};["eyePos"]={["class"]="function";["client"]=true;["description"]="\
Returns the local player's camera position";["fname"]="eyePos";["library"]="builtin";["name"]="SF.DefaultEnvironment.eyePos";["param"]={};["private"]=false;["realm"]="cl";["ret"]="The local player's camera position";["summary"]="\
Returns the local player's camera position ";};["eyeVector"]={["class"]="function";["client"]=true;["description"]="\
Returns the local player's camera forward vector";["fname"]="eyeVector";["library"]="builtin";["name"]="SF.DefaultEnvironment.eyeVector";["param"]={};["private"]=false;["realm"]="cl";["ret"]="The local player's camera forward vector";["summary"]="\
Returns the local player's camera forward vector ";};["getLibraries"]={["class"]="function";["description"]="\
Gets a list of all libraries";["fname"]="getLibraries";["library"]="builtin";["name"]="SF.DefaultEnvironment.getLibraries";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Table containing the names of each available library";["summary"]="\
Gets a list of all libraries ";};["getScripts"]={["class"]="function";["description"]="\
Returns the table of scripts used by the chip";["fname"]="getScripts";["library"]="builtin";["name"]="SF.DefaultEnvironment.getScripts";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Table of scripts used by the chip";["summary"]="\
Returns the table of scripts used by the chip ";};["getUserdata"]={["class"]="function";["description"]="\
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
Returns an iterator function for a for loop, to return ordered key-value pairs from a table.";};["isFirstTimePredicted"]={["class"]="function";["classForced"]=true;["description"]="\
Returns if this is the first time this hook was predicted.";["fname"]="isFirstTimePredicted";["library"]="builtin";["name"]="SF.DefaultEnvironment.isFirstTimePredicted";["param"]={};["realm"]="sh";["ret"]="Boolean";["summary"]="\
Returns if this is the first time this hook was predicted.";};["isValid"]={["class"]="function";["description"]="\
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
Returns the current count for this Think's CPU Time.";};["ramAverage"]={["class"]="function";["description"]="\
Gets the moving average of ram usage of the lua environment";["fname"]="ramAverage";["library"]="builtin";["name"]="SF.DefaultEnvironment.ramAverage";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The ram used in bytes";["summary"]="\
Gets the moving average of ram usage of the lua environment ";};["ramUsed"]={["class"]="function";["description"]="\
Gets the current ram usage of the lua environment";["fname"]="ramUsed";["library"]="builtin";["name"]="SF.DefaultEnvironment.ramUsed";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The ram used in bytes";["summary"]="\
Gets the current ram usage of the lua environment ";};["rawget"]={["class"]="function";["description"]="\
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
Sets the chip's userdata that the duplicator tool saves. max 1MiB; can be changed with convar sf_userdata_max";["fname"]="setUserdata";["library"]="builtin";["name"]="SF.DefaultEnvironment.setUserdata";["param"]={[1]="str";["str"]="String data";};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
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
This function takes a numeric indexed table and return all the members as a vararg.";};["version"]={["class"]="function";["description"]="\
Gets the starfall version";["fname"]="version";["library"]="builtin";["name"]="SF.DefaultEnvironment.version";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Starfall version";["summary"]="\
Gets the starfall version ";};["worldToLocal"]={["class"]="function";["description"]="\
Translates the specified position and angle into the specified coordinate system";["fname"]="worldToLocal";["library"]="builtin";["name"]="SF.DefaultEnvironment.worldToLocal";["param"]={[1]="pos";[2]="ang";[3]="newSystemOrigin";[4]="newSystemAngles";["ang"]="The angles that should be translated from the current to the new system";["newSystemAngles"]="The angles of the system to translate to";["newSystemOrigin"]="The origin of the system to translate to";["pos"]="The position that should be translated from the current to the new system";};["private"]=false;["realm"]="sh";["ret"]={[1]="localPos";[2]="localAngles";};["summary"]="\
Translates the specified position and angle into the specified coordinate system ";};["xpcall"]={["class"]="function";["description"]="\
Lua's xpcall with SF throw implementation, and a traceback for debugging. \
Attempts to call the first function. If the execution succeeds, this returns true followed by the returns of the function. \
If execution fails, this returns false and the second function is called with the error message, and the stack trace.";["fname"]="xpcall";["library"]="builtin";["name"]="SF.DefaultEnvironment.xpcall";["param"]={["..."]="Varargs to pass to the initial function.";[1]="func";[2]="callback";[3]="...";["callback"]="The function to be called if execution of the first fails; the error message and stack trace are passed.";["func"]="The function to call initially.";};["private"]=false;["realm"]="sh";["ret"]={[1]="Status of the execution; true for success, false for failure.";[2]="The returns of the first function if execution succeeded, otherwise the return values of the error callback.";};["summary"]="\
Lua's xpcall with SF throw implementation, and a traceback for debugging.";};};["libtbl"]="SF.DefaultEnvironment";["name"]="builtin";["server"]=true;["summary"]="\
Built in values.";["tables"]={[1]="math";[2]="os";[3]="string";[4]="table";["math"]={["class"]="table";["classForced"]=true;["description"]="\
The math library. http://wiki.garrysmod.com/page/Category:math";["library"]="builtin";["name"]="SF.DefaultEnvironment.math";["param"]={};["summary"]="\
The math library.";["tname"]="math";};["os"]={["class"]="table";["classForced"]=true;["description"]="\
The os library. http://wiki.garrysmod.com/page/Category:os";["library"]="builtin";["name"]="SF.DefaultEnvironment.os";["param"]={};["summary"]="\
The os library.";["tname"]="os";};["string"]={["class"]="table";["classForced"]=true;["description"]="\
String library http://wiki.garrysmod.com/page/Category:string";["library"]="builtin";["name"]="SF.DefaultEnvironment.string";["param"]={};["summary"]="\
String library http://wiki.garrysmod.com/page/Category:string ";["tname"]="string";};["table"]={["class"]="table";["classForced"]=true;["description"]="\
Table library. http://wiki.garrysmod.com/page/Category:table";["library"]="builtin";["name"]="SF.DefaultEnvironment.table";["param"]={};["summary"]="\
Table library.";["tname"]="table";};};};["constraint"]={["class"]="library";["description"]="\
Library for creating and manipulating constraints.";["fields"]={};["functions"]={[1]="axis";[10]="rope";[11]="setConstraintClean";[12]="setElasticLength";[13]="setRopeLength";[14]="slider";[15]="weld";[2]="ballsocket";[3]="ballsocketadv";[4]="breakAll";[5]="breakType";[6]="constraintsLeft";[7]="elastic";[8]="getTable";[9]="nocollide";["axis"]={["class"]="function";["description"]="\
Axis two entities";["fname"]="axis";["library"]="constraint";["name"]="constraint_library.axis";["param"]={[1]="e1";[10]="nocollide";[11]="laxis";[2]="e2";[3]="bone1";[4]="bone2";[5]="v1";[6]="v2";[7]="force_lim";[8]="torque_lim";[9]="friction";};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Axis two entities ";};["ballsocket"]={["class"]="function";["description"]="\
Ballsocket two entities";["fname"]="ballsocket";["library"]="constraint";["name"]="constraint_library.ballsocket";["param"]={[1]="e1";[2]="e2";[3]="bone1";[4]="bone2";[5]="v1";[6]="force_lim";[7]="torque_lim";[8]="nocollide";};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Ballsocket two entities ";};["ballsocketadv"]={["class"]="function";["description"]="\
Advanced Ballsocket two entities";["fname"]="ballsocketadv";["library"]="constraint";["name"]="constraint_library.ballsocketadv";["param"]={[1]="e1";[10]="maxv";[11]="frictionv";[12]="rotateonly";[13]="nocollide";[2]="e2";[3]="bone1";[4]="bone2";[5]="v1";[6]="v2";[7]="force_lim";[8]="torque_lim";[9]="minv";};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Advanced Ballsocket two entities ";};["breakAll"]={["class"]="function";["description"]="\
Breaks all constraints on an entity";["fname"]="breakAll";["library"]="constraint";["name"]="constraint_library.breakAll";["param"]={[1]="e";};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Breaks all constraints on an entity ";};["breakType"]={["class"]="function";["description"]="\
Breaks all constraints of a certain type on an entity";["fname"]="breakType";["library"]="constraint";["name"]="constraint_library.breakType";["param"]={[1]="e";[2]="typename";};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Breaks all constraints of a certain type on an entity ";};["constraintsLeft"]={["class"]="function";["description"]="\
Checks how many constraints can be spawned";["fname"]="constraintsLeft";["library"]="constraint";["name"]="constraint_library.constraintsLeft";["param"]={};["private"]=false;["realm"]="sv";["ret"]="number of constraints able to be spawned";["server"]=true;["summary"]="\
Checks how many constraints can be spawned ";};["elastic"]={["class"]="function";["description"]="\
Elastic two entities";["fname"]="elastic";["library"]="constraint";["name"]="constraint_library.elastic";["param"]={[1]="index";[10]="rdamp";[11]="width";[12]="strech";[2]="e1";[3]="e2";[4]="bone1";[5]="bone2";[6]="v1";[7]="v2";[8]="const";[9]="damp";};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Elastic two entities ";};["getTable"]={["class"]="function";["description"]="\
Returns the table of constraints on an entity";["fname"]="getTable";["library"]="constraint";["name"]="constraint_library.getTable";["param"]={[1]="ent";["ent"]="The entity";};["private"]=false;["realm"]="sv";["ret"]="Table of entity constraints";["summary"]="\
Returns the table of constraints on an entity ";};["nocollide"]={["class"]="function";["description"]="\
Nocollides two entities";["fname"]="nocollide";["library"]="constraint";["name"]="constraint_library.nocollide";["param"]={[1]="e1";[2]="e2";[3]="bone1";[4]="bone2";};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Nocollides two entities ";};["rope"]={["class"]="function";["description"]="\
Ropes two entities";["fname"]="rope";["library"]="constraint";["name"]="constraint_library.rope";["param"]={[1]="index";[10]="force_lim";[11]="width";[12]="material";[13]="rigid";[2]="e1";[3]="e2";[4]="bone1";[5]="bone2";[6]="v1";[7]="v2";[8]="length";[9]="addlength";};["private"]=false;["realm"]="sv";["server"]=true;["summary"]="\
Ropes two entities ";};["setConstraintClean"]={["class"]="function";["description"]="\
Sets whether the chip should remove created constraints when the chip is removed";["fname"]="setConstraintClean";["library"]="constraint";["name"]="constraint_library.setConstraintClean";["param"]={[1]="on";["on"]="Boolean whether the constraints should be cleaned or not";};["private"]=false;["realm"]="sv";["summary"]="\
Sets whether the chip should remove created constraints when the chip is removed ";};["setElasticLength"]={["class"]="function";["description"]="\
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
Coroutine library ";["tables"]={};};["effect"]={["class"]="library";["client"]=true;["description"]="\
Effects library.";["fields"]={};["functions"]={[1]="create";[2]="effectsLeft";["create"]={["class"]="function";["description"]="\
Creates an effect data structure";["fname"]="create";["library"]="effect";["name"]="effect_library.create";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Effect Object";["summary"]="\
Creates an effect data structure ";};["effectsLeft"]={["class"]="function";["description"]="\
Returns number of effects able to be created";["fname"]="effectsLeft";["library"]="effect";["name"]="effect_library.effectsLeft";["param"]={};["private"]=false;["realm"]="sh";["ret"]="number of effects able to be created";["summary"]="\
Returns number of effects able to be created ";};};["libtbl"]="effect_library";["name"]="effect";["server"]=true;["summary"]="\
Effects library.";["tables"]={};};["fastlz"]={["class"]="library";["client"]=true;["description"]="\
FastLZ library";["fields"]={};["functions"]={[1]="compress";[2]="decompress";["compress"]={["class"]="function";["description"]="\
Compress string using FastLZ";["fname"]="compress";["library"]="fastlz";["name"]="fastlz_library.compress";["param"]={[1]="s";["s"]="String to compress";};["private"]=false;["realm"]="sh";["ret"]="FastLZ compressed string";["summary"]="\
Compress string using FastLZ ";};["decompress"]={["class"]="function";["description"]="\
Decompress using FastLZ";["fname"]="decompress";["library"]="fastlz";["name"]="fastlz_library.decompress";["param"]={[1]="s";["s"]="FastLZ compressed string to decode";};["private"]=false;["realm"]="sh";["ret"]="Decompressed string";["summary"]="\
Decompress using FastLZ ";};};["libtbl"]="fastlz_library";["name"]="fastlz";["server"]=true;["summary"]="\
FastLZ library ";["tables"]={};};["file"]={["class"]="library";["client"]=true;["description"]="\
File functions. Allows modification of files.";["fields"]={};["functions"]={[1]="append";[2]="createDir";[3]="delete";[4]="exists";[5]="find";[6]="open";[7]="read";[8]="write";["append"]={["class"]="function";["description"]="\
Appends a string to the end of a file";["fname"]="append";["library"]="file";["name"]="file_library.append";["param"]={[1]="path";[2]="data";["data"]="String that will be appended to the file.";["path"]="Filepath relative to data/sf_filedata/.";};["private"]=false;["realm"]="cl";["summary"]="\
Appends a string to the end of a file ";};["createDir"]={["class"]="function";["description"]="\
Creates a directory";["fname"]="createDir";["library"]="file";["name"]="file_library.createDir";["param"]={[1]="path";["path"]="Filepath relative to data/sf_filedata/.";};["private"]=false;["realm"]="cl";["summary"]="\
Creates a directory ";};["delete"]={["class"]="function";["description"]="\
Deletes a file";["fname"]="delete";["library"]="file";["name"]="file_library.delete";["param"]={[1]="path";["path"]="Filepath relative to data/sf_filedata/.";};["private"]=false;["realm"]="cl";["ret"]="True if successful, nil if it wasn't found";["summary"]="\
Deletes a file ";};["exists"]={["class"]="function";["description"]="\
Checks if a file exists";["fname"]="exists";["library"]="file";["name"]="file_library.exists";["param"]={[1]="path";["path"]="Filepath relative to data/sf_filedata/.";};["private"]=false;["realm"]="cl";["ret"]="True if exists, false if not, nil if error";["summary"]="\
Checks if a file exists ";};["find"]={["class"]="function";["description"]="\
Enumerates a directory";["fname"]="find";["library"]="file";["name"]="file_library.find";["param"]={[1]="path";[2]="sorting";["path"]="The folder to enumerate, relative to data/sf_filedata/.";["sorting"]="Optional sorting arguement. Either nameasc, namedesc, dateasc, datedesc";};["private"]=false;["realm"]="cl";["ret"]={[1]="Table of file names";[2]="Table of directory names";};["summary"]="\
Enumerates a directory ";};["open"]={["class"]="function";["description"]="\
Opens and returns a file";["fname"]="open";["library"]="file";["name"]="file_library.open";["param"]={[1]="path";[2]="mode";["mode"]="The file mode to use. See lua manual for explaination";["path"]="Filepath relative to data/sf_filedata/.";};["private"]=false;["realm"]="cl";["ret"]="File object or nil if it failed";["summary"]="\
Opens and returns a file ";};["read"]={["class"]="function";["description"]="\
Reads a file from path";["fname"]="read";["library"]="file";["name"]="file_library.read";["param"]={[1]="path";["path"]="Filepath relative to data/sf_filedata/.";};["private"]=false;["realm"]="cl";["ret"]="Contents, or nil if error";["summary"]="\
Reads a file from path ";};["write"]={["class"]="function";["description"]="\
Writes to a file";["fname"]="write";["library"]="file";["name"]="file_library.write";["param"]={[1]="path";[2]="data";["path"]="Filepath relative to data/sf_filedata/.";};["private"]=false;["realm"]="cl";["ret"]="True if OK, nil if error";["summary"]="\
Writes to a file ";};};["libtbl"]="file_library";["name"]="file";["summary"]="\
File functions.";["tables"]={};};["find"]={["class"]="library";["client"]=true;["description"]="\
Find library. Finds entities in various shapes.";["fields"]={};["functions"]={[1]="all";[10]="sortByClosest";[2]="allPlayers";[3]="byClass";[4]="byModel";[5]="closest";[6]="inBox";[7]="inCone";[8]="inPVS";[9]="inSphere";["all"]={["class"]="function";["description"]="\
Finds all entitites";["fname"]="all";["library"]="find";["name"]="find_library.all";["param"]={[1]="filter";["filter"]="Optional function to filter results";};["private"]=false;["realm"]="sh";["ret"]="An array of found entities";["summary"]="\
Finds all entitites ";};["allPlayers"]={["class"]="function";["description"]="\
Finds all players (including bots)";["fname"]="allPlayers";["library"]="find";["name"]="find_library.allPlayers";["param"]={[1]="filter";["filter"]="Optional function to filter results";};["private"]=false;["realm"]="sh";["ret"]="An array of found entities";["summary"]="\
Finds all players (including bots) ";};["byClass"]={["class"]="function";["description"]="\
Finds entities by class name";["fname"]="byClass";["library"]="find";["name"]="find_library.byClass";["param"]={[1]="class";[2]="filter";["class"]="The class name";["filter"]="Optional function to filter results";};["private"]=false;["realm"]="sh";["ret"]="An array of found entities";["summary"]="\
Finds entities by class name ";};["byModel"]={["class"]="function";["description"]="\
Finds entities by model";["fname"]="byModel";["library"]="find";["name"]="find_library.byModel";["param"]={[1]="model";[2]="filter";["filter"]="Optional function to filter results";["model"]="The model file";};["private"]=false;["realm"]="sh";["ret"]="An array of found entities";["summary"]="\
Finds entities by model ";};["closest"]={["class"]="function";["description"]="\
Finds the closest entity to a point";["fname"]="closest";["library"]="find";["name"]="find_library.closest";["param"]={[1]="ents";[2]="pos";["ents"]="The array of entities";["pos"]="The position";};["private"]=false;["realm"]="sh";["ret"]="The closest entity";["summary"]="\
Finds the closest entity to a point ";};["inBox"]={["class"]="function";["description"]="\
Finds entities in a box";["fname"]="inBox";["library"]="find";["name"]="find_library.inBox";["param"]={[1]="min";[2]="max";[3]="filter";["filter"]="Optional function to filter results";["max"]="Top corner";["min"]="Bottom corner";};["private"]=false;["realm"]="sh";["ret"]="An array of found entities";["summary"]="\
Finds entities in a box ";};["inCone"]={["class"]="function";["description"]="\
Finds entities in a cone";["fname"]="inCone";["library"]="find";["name"]="find_library.inCone";["param"]={[1]="pos";[2]="dir";[3]="distance";[4]="radius";[5]="filter";["dir"]="The direction to project the cone";["distance"]="The length to project the cone";["filter"]="Optional function to filter results";["pos"]="The cone vertex position";["radius"]="The cosine of angle of the cone. 1 makes a 0° cone, 0.707 makes approximately 90°, 0 makes 180°, and so on.";};["private"]=false;["realm"]="sh";["ret"]="An array of found entities";["summary"]="\
Finds entities in a cone ";};["inPVS"]={["class"]="function";["description"]="\
Finds entities that are in the PVS (Potentially Visible Set). See: https://developer.valvesoftware.com/wiki/PVS";["fname"]="inPVS";["library"]="find";["name"]="find_library.inPVS";["param"]={[1]="pos";[2]="filter";["filter"]="Optional function to filter results";["pos"]="Vector view point";};["private"]=false;["realm"]="sv";["ret"]="An array of found entities";["server"]=true;["summary"]="\
Finds entities that are in the PVS (Potentially Visible Set).";};["inSphere"]={["class"]="function";["description"]="\
Finds entities in a sphere";["fname"]="inSphere";["library"]="find";["name"]="find_library.inSphere";["param"]={[1]="center";[2]="radius";[3]="filter";["center"]="Center of the sphere";["filter"]="Optional function to filter results";["radius"]="Sphere radius";};["private"]=false;["realm"]="sh";["ret"]="An array of found entities";["summary"]="\
Finds entities in a sphere ";};["sortByClosest"]={["class"]="function";["description"]="\
Sorts an array of entities by how close they are to a point";["fname"]="sortByClosest";["library"]="find";["name"]="find_library.sortByClosest";["param"]={[1]="ents";[2]="pos";["ents"]="The array of entities";["pos"]="The position";};["private"]=false;["realm"]="sh";["ret"]="A table of the closest entities";["summary"]="\
Sorts an array of entities by how close they are to a point ";};};["libtbl"]="find_library";["name"]="find";["server"]=true;["summary"]="\
Find library.";["tables"]={};};["game"]={["class"]="library";["client"]=true;["description"]="\
Game functions";["fields"]={};["functions"]={[1]="getHostname";[2]="getMap";[3]="getMaxPlayers";[4]="isDedicated";[5]="isLan";[6]="isSinglePlayer";["getHostname"]={["class"]="function";["description"]="\
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
Game functions ";["tables"]={};};["holograms"]={["class"]="library";["client"]=true;["description"]="\
Library for creating and manipulating physics-less models AKA \"Holograms\".";["fields"]={};["functions"]={[1]="canSpawn";[2]="create";[3]="hologramsLeft";["canSpawn"]={["class"]="function";["description"]="\
Checks if a user can spawn anymore holograms.";["fname"]="canSpawn";["library"]="holograms";["name"]="holograms_library.canSpawn";["param"]={};["private"]=false;["realm"]="sh";["ret"]="True if user can spawn holograms, False if not.";["summary"]="\
Checks if a user can spawn anymore holograms.";};["create"]={["class"]="function";["description"]="\
Creates a hologram.";["fname"]="create";["library"]="holograms";["name"]="holograms_library.create";["param"]={[1]="pos";[2]="ang";[3]="model";[4]="scale";};["private"]=false;["realm"]="sh";["ret"]="The hologram object";["summary"]="\
Creates a hologram.";};["hologramsLeft"]={["class"]="function";["description"]="\
Checks how many holograms can be spawned";["fname"]="hologramsLeft";["library"]="holograms";["name"]="holograms_library.hologramsLeft";["param"]={};["private"]=false;["realm"]="sh";["ret"]="number of holograms able to be spawned";["summary"]="\
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
Runs a new http POST request";["fname"]="post";["library"]="http";["name"]="http_library.post";["param"]={[1]="url";[2]="payload";[3]="callbackSuccess";[4]="callbackFail";[5]="headers";["callbackFail"]="optional function to be called on request fail, taking the failing reason as an argument";["callbackSuccess"]="optional function to be called on request success, taking the arguments body (string), length (number), headers (table) and code (number)";["headers"]="optional POST headers to be sent";["payload"]="optional POST payload to be sent, can be both table and string. When table is used, the request body is encoded as application/x-www-form-urlencoded";["url"]="http target url";};["private"]=false;["realm"]="sh";["summary"]="\
Runs a new http POST request ";};};["libtbl"]="http_library";["name"]="http";["server"]=true;["summary"]="\
Http library.";["tables"]={};};["input"]={["class"]="library";["client"]=true;["description"]="\
Input library.";["fields"]={};["functions"]={[1]="enableCursor";[2]="getCursorPos";[3]="getCursorVisible";[4]="getKeyName";[5]="isControlDown";[6]="isKeyDown";[7]="isShiftDown";[8]="lookupBinding";[9]="screenToVector";["enableCursor"]={["class"]="function";["client"]=true;["description"]="\
Sets the state of the mouse cursor";["fname"]="enableCursor";["library"]="input";["name"]="input_methods.enableCursor";["param"]={[1]="enabled";["enabled"]="Whether or not the cursor should be enabled";};["private"]=false;["realm"]="cl";["summary"]="\
Sets the state of the mouse cursor ";};["getCursorPos"]={["class"]="function";["client"]=true;["description"]="\
Gets the position of the mouse";["fname"]="getCursorPos";["library"]="input";["name"]="input_methods.getCursorPos";["param"]={};["private"]=false;["realm"]="cl";["ret"]={[1]="The x position of the mouse";[2]="The y position of the mouse";};["summary"]="\
Gets the position of the mouse ";};["getCursorVisible"]={["class"]="function";["client"]=true;["description"]="\
Gets whether the cursor is visible on the screen";["fname"]="getCursorVisible";["library"]="input";["name"]="input_methods.getCursorVisible";["param"]={};["private"]=false;["realm"]="cl";["ret"]="The cursor's visibility";["summary"]="\
Gets whether the cursor is visible on the screen ";};["getKeyName"]={["class"]="function";["client"]=true;["description"]="\
Gets the name of a key from the id";["fname"]="getKeyName";["library"]="input";["name"]="input_methods.getKeyName";["param"]={[1]="key";["key"]="The key id, see input";};["private"]=false;["realm"]="cl";["ret"]="The name of the key";["summary"]="\
Gets the name of a key from the id ";};["isControlDown"]={["class"]="function";["client"]=true;["description"]="\
Gets whether the control key is down";["fname"]="isControlDown";["library"]="input";["name"]="input_methods.isControlDown";["param"]={};["private"]=false;["realm"]="cl";["ret"]="True if the control key is down";["summary"]="\
Gets whether the control key is down ";};["isKeyDown"]={["class"]="function";["client"]=true;["description"]="\
Gets whether a key is down";["fname"]="isKeyDown";["library"]="input";["name"]="input_methods.isKeyDown";["param"]={[1]="key";["key"]="The key id, see input";};["private"]=false;["realm"]="cl";["ret"]="True if the key is down";["summary"]="\
Gets whether a key is down ";};["isShiftDown"]={["class"]="function";["client"]=true;["description"]="\
Gets whether the shift key is down";["fname"]="isShiftDown";["library"]="input";["name"]="input_methods.isShiftDown";["param"]={};["private"]=false;["realm"]="cl";["ret"]="True if the shift key is down";["summary"]="\
Gets whether the shift key is down ";};["lookupBinding"]={["class"]="function";["client"]=true;["description"]="\
Gets the first key that is bound to the command passed";["fname"]="lookupBinding";["library"]="input";["name"]="input_methods.lookupBinding";["param"]={[1]="binding";["binding"]="The name of the bind";};["private"]=false;["realm"]="cl";["ret"]={[1]="The id of the first key bound";[2]="The name of the first key bound";};["summary"]="\
Gets the first key that is bound to the command passed ";};["screenToVector"]={["class"]="function";["client"]=true;["description"]="\
Translates position on player's screen to aim vector";["fname"]="screenToVector";["library"]="input";["name"]="input_methods.screenToVector";["param"]={[1]="x";[2]="y";["x"]="X coordinate on the screen";["y"]="Y coordinate on the screen";};["private"]=false;["realm"]="cl";["ret"]="Aim vector";["summary"]="\
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
Convert table to JSON string";["fname"]="encode";["library"]="json";["name"]="json_library.encode";["param"]={[1]="tbl";[2]="prettyPrint";["prettyPrint"]="Optional. If true, formats and indents the resulting JSON";["tbl"]="Table to encode";};["private"]=false;["realm"]="sh";["ret"]="JSON encoded string representation of the table";["summary"]="\
Convert table to JSON string ";};};["libtbl"]="json_library";["name"]="json";["server"]=true;["summary"]="\
JSON library ";["tables"]={};};["light"]={["class"]="library";["client"]=true;["description"]="\
Light library.";["fields"]={};["functions"]={[1]="create";["create"]={["class"]="function";["description"]="\
Creates a dynamic light";["fname"]="create";["library"]="light";["name"]="light_library.create";["param"]={[1]="pos";[2]="size";[3]="brightness";[4]="color";["brightness"]="The brightness of the light";["color"]="The color of the light";["pos"]="The position of the light";["size"]="The size of the light. Must be lower than sf_light_maxsize";};["private"]=false;["realm"]="cl";["summary"]="\
Creates a dynamic light ";};};["libtbl"]="light_library";["name"]="light";["summary"]="\
Light library.";["tables"]={};};["material"]={["class"]="library";["client"]=true;["description"]="\
`material` library is allows creating material objects which are used for controlling shaders in rendering.";["fields"]={};["functions"]={[1]="create";[10]="getShader";[11]="getString";[12]="getTexture";[13]="getVector";[14]="getVectorLinear";[15]="getWidth";[16]="load";[2]="createFromImage";[3]="getColor";[4]="getFloat";[5]="getHeight";[6]="getInt";[7]="getKeyValues";[8]="getMatrix";[9]="getName";["create"]={["class"]="function";["description"]="\
Creates a new blank material";["fname"]="create";["library"]="material";["name"]="material_library.create";["param"]={[1]="shader";["shader"]="The shader of the material. Must be one of \
UnlitGeneric \
VertexLitGeneric \
Refract_DX90 \
Water_DX90 \
Sky_DX9 \
gmodscreenspace \
Modulate_DX9";};["private"]=false;["realm"]="cl";["summary"]="\
Creates a new blank material ";};["createFromImage"]={["class"]="function";["description"]="\
Creates a .jpg or .png material from file \
Can't be modified";["fname"]="createFromImage";["library"]="material";["name"]="material_library.createFromImage";["param"]={[1]="path";[2]="params";["params"]="The shader parameters to apply to the material. See http://wiki.garrysmod.com/page/Material_Parameters";["path"]="The path to the image file";};["private"]=false;["realm"]="cl";["summary"]="\
Creates a .jpg or .png material from file \
Can't be modified ";};["getColor"]={["class"]="function";["description"]="\
Returns a color pixel value of the $basetexture of a .png or .jpg material.";["fname"]="getColor";["library"]="material";["name"]="material_library.getColor";["param"]={[1]="path";[2]="x";[3]="y";["path"]="The path of the material (don't include .vmt in the path)";["x"]="The x coordinate of the pixel";["y"]="The y coordinate of the pixel";};["private"]=false;["realm"]="cl";["ret"]="The color value";["summary"]="\
Returns a color pixel value of the $basetexture of a .png or .jpg material.";};["getFloat"]={["class"]="function";["description"]="\
Returns a float keyvalue of a material";["fname"]="getFloat";["library"]="material";["name"]="material_library.getFloat";["param"]={[1]="path";[2]="key";["key"]="The key to get the float from";["path"]="The path of the material (don't include .vmt in the path)";};["private"]=false;["realm"]="cl";["ret"]="The float value or nil if it doesn't exist";["summary"]="\
Returns a float keyvalue of a material ";};["getHeight"]={["class"]="function";["description"]="\
Returns the height of the member texture set for $basetexture of a material";["fname"]="getHeight";["library"]="material";["name"]="material_library.getHeight";["param"]={[1]="path";["path"]="The path of the material (don't include .vmt in the path)";};["private"]=false;["realm"]="cl";["ret"]="The basetexture's height";["summary"]="\
Returns the height of the member texture set for $basetexture of a material ";};["getInt"]={["class"]="function";["description"]="\
Returns an int keyvalue of a material";["fname"]="getInt";["library"]="material";["name"]="material_library.getInt";["param"]={[1]="path";[2]="key";["key"]="The key to get the int from";["path"]="The path of the material (don't include .vmt in the path)";};["private"]=false;["realm"]="cl";["ret"]="The int value or nil if it doesn't exist";["summary"]="\
Returns an int keyvalue of a material ";};["getKeyValues"]={["class"]="function";["description"]="\
Returns a table of keyvalues from a material";["fname"]="getKeyValues";["library"]="material";["name"]="material_library.getKeyValues";["param"]={[1]="path";["path"]="The path of the material (don't include .vmt in the path)";};["private"]=false;["realm"]="cl";["ret"]="The table of keyvalues";["summary"]="\
Returns a table of keyvalues from a material ";};["getMatrix"]={["class"]="function";["description"]="\
Returns a matrix keyvalue of a material";["fname"]="getMatrix";["library"]="material";["name"]="material_library.getMatrix";["param"]={[1]="path";[2]="key";["key"]="The key to get the matrix from";["path"]="The path of the material (don't include .vmt in the path)";};["private"]=false;["realm"]="cl";["ret"]="The matrix value or nil if it doesn't exist";["summary"]="\
Returns a matrix keyvalue of a material ";};["getName"]={["class"]="function";["description"]="\
Returns a material's engine name";["fname"]="getName";["library"]="material";["name"]="material_library.getName";["param"]={[1]="path";["path"]="The path of the material (don't include .vmt in the path)";};["private"]=false;["realm"]="cl";["ret"]="The name of a material. If this material is user created, add ! to the beginning of this to use it with entity.setMaterial";["summary"]="\
Returns a material's engine name ";};["getShader"]={["class"]="function";["description"]="\
Returns the shader name of a material";["fname"]="getShader";["library"]="material";["name"]="material_library.getShader";["param"]={[1]="path";["path"]="The path of the material (don't include .vmt in the path)";};["private"]=false;["realm"]="cl";["ret"]="The shader name of the material";["summary"]="\
Returns the shader name of a material ";};["getString"]={["class"]="function";["description"]="\
Returns a string keyvalue";["fname"]="getString";["library"]="material";["name"]="material_library.getString";["param"]={[1]="path";[2]="key";["key"]="The key to get the string from";["path"]="The path of the material (don't include .vmt in the path)";};["private"]=false;["realm"]="cl";["ret"]="The string value or nil if it doesn't exist";["summary"]="\
Returns a string keyvalue ";};["getTexture"]={["class"]="function";["description"]="\
Gets a texture from a material";["fname"]="getTexture";["library"]="material";["name"]="material_library.getTexture";["param"]={[1]="path";[2]="texture";["path"]="The path of the material (don't include .vmt in the path)";["texture"]="The texture key to get";};["private"]=false;["realm"]="cl";["ret"]="The texture's name";["summary"]="\
Gets a texture from a material ";};["getVector"]={["class"]="function";["description"]="\
Returns a vector keyvalue of a material";["fname"]="getVector";["library"]="material";["name"]="material_library.getVector";["param"]={[1]="path";[2]="key";["key"]="The key to get the vector from";["path"]="The path of the material (don't include .vmt in the path)";};["private"]=false;["realm"]="cl";["ret"]="The string id of the texture";["summary"]="\
Returns a vector keyvalue of a material ";};["getVectorLinear"]={["class"]="function";["description"]="\
Returns a linear color-corrected vector keyvalue of a material";["fname"]="getVectorLinear";["library"]="material";["name"]="material_library.getVectorLinear";["param"]={[1]="path";[2]="key";["key"]="The key to get the vector from";["path"]="The path of the material (don't include .vmt in the path)";};["private"]=false;["realm"]="cl";["ret"]="The vector value or nil if it doesn't exist";["summary"]="\
Returns a linear color-corrected vector keyvalue of a material ";};["getWidth"]={["class"]="function";["description"]="\
Returns the width of the member texture set for $basetexture of a material";["fname"]="getWidth";["library"]="material";["name"]="material_library.getWidth";["param"]={[1]="path";["path"]="The path of the material (don't include .vmt in the path)";};["private"]=false;["realm"]="cl";["ret"]="The basetexture's width";["summary"]="\
Returns the width of the member texture set for $basetexture of a material ";};["load"]={["class"]="function";["description"]="\
Loads a .vmt material or existing material. Throws an error if the material fails to load \
Existing created materials can be loaded with ! prepended to the name \
Can't be modified";["fname"]="load";["library"]="material";["name"]="material_library.load";["param"]={[1]="path";["path"]="The path of the material (don't include .vmt in the path)";};["private"]=false;["realm"]="cl";["ret"]="The material object. Can't be modified.";["summary"]="\
Loads a .vmt material or existing material.";};};["libtbl"]="material_library";["name"]="material";["summary"]="\
`material` library is allows creating material objects which are used for controlling shaders in rendering.";["tables"]={};};["mesh"]={["class"]="library";["client"]=true;["description"]="\
Mesh library.";["fields"]={};["functions"]={[1]="createFromObj";[2]="createFromTable";[3]="getModelMeshes";[4]="parseObj";[5]="trianglesLeft";[6]="trianglesLeftRender";["createFromObj"]={["class"]="function";["description"]="\
Creates a mesh from an obj file. Only supports triangular meshes with normals and texture coordinates.";["fname"]="createFromObj";["library"]="mesh";["name"]="mesh_library.createFromObj";["param"]={[1]="obj";[2]="thread";[3]="triangulate";["obj"]="The obj file data";["thread"]="An optional thread object that can be used to load the mesh over time to prevent hitting quota limit";["triangulate"]="Whether to triangulate faces. (Consumes more CPU)";};["private"]=false;["realm"]="sh";["ret"]="Mesh object";["summary"]="\
Creates a mesh from an obj file.";};["createFromTable"]={["class"]="function";["description"]="\
Creates a mesh from vertex data.";["fname"]="createFromTable";["library"]="mesh";["name"]="mesh_library.createFromTable";["param"]={[1]="verteces";[2]="thread";["thread"]="An optional thread object that can be used to load the mesh over time to prevent hitting quota limit";["verteces"]="Table containing vertex data. http://wiki.garrysmod.com/page/Structures/MeshVertex";};["private"]=false;["realm"]="sh";["ret"]="Mesh object";["summary"]="\
Creates a mesh from vertex data.";};["getModelMeshes"]={["class"]="function";["description"]="\
Returns a table of visual meshes of given model or nil if the model is invalid";["fname"]="getModelMeshes";["library"]="mesh";["name"]="mesh_library.getModelMeshes";["param"]={[1]="model";[2]="lod";[3]="bodygroupMask";["bodygroupMask"]="The bodygroupMask of the model to use.";["lod"]="The lod of the model to use.";["model"]="The full path to a model to get the visual meshes of.";};["private"]=false;["realm"]="sh";["ret"]="A table of tables with the following format:<br><br>string material - The material of the specific mesh<br>table triangles - A table of MeshVertex structures ready to be fed into IMesh:BuildFromTriangles<br>table verticies - A table of MeshVertex structures representing all the vertexes of the mesh. This table is used internally to generate the \"triangles\" table.<br>Each MeshVertex structure returned also has an extra table of tables field called \"weights\" with the following data:<br><br>number boneID - The bone this vertex is attached to<br>number weight - How \"strong\" this vertex is attached to the bone. A vertex can be attached to multiple bones at once.";["summary"]="\
Returns a table of visual meshes of given model or nil if the model is invalid ";};["parseObj"]={["class"]="function";["description"]="\
Parses obj data into a table of vertices, normals, texture coordinates, colors, and tangents";["fname"]="parseObj";["library"]="mesh";["name"]="mesh_library.parseObj";["param"]={[1]="obj";[2]="thread";[3]="triangulate";["obj"]="The obj data";["thread"]="An optional thread object to gradually parse the data to prevent exceeding cpu";["triangulate"]="Whether to triangulate the faces";};["private"]=false;["realm"]="sh";["ret"]={[1]="The table of vertices that can be passed to mesh.buildFromTriangles";[2]="The table of obj data. table.positions can be given to prop.createCustom";};["summary"]="\
Parses obj data into a table of vertices, normals, texture coordinates, colors, and tangents ";};["trianglesLeft"]={["class"]="function";["description"]="\
Returns how many triangles can be created";["fname"]="trianglesLeft";["library"]="mesh";["name"]="mesh_library.trianglesLeft";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Number of triangles that can be created";["summary"]="\
Returns how many triangles can be created ";};["trianglesLeftRender"]={["class"]="function";["description"]="\
Returns how many triangles can be rendered";["fname"]="trianglesLeftRender";["library"]="mesh";["name"]="mesh_library.trianglesLeftRender";["param"]={};["private"]=false;["realm"]="sh";["ret"]="Number of triangles that can be rendered";["summary"]="\
Returns how many triangles can be rendered ";};};["libtbl"]="mesh_library";["name"]="mesh";["server"]=true;["summary"]="\
Mesh library.";["tables"]={};};["net"]={["class"]="library";["description"]="\
Net message library. Used for sending data from the server to the client and back";["fields"]={};["functions"]={[1]="cancelStream";[10]="readDouble";[11]="readEntity";[12]="readFloat";[13]="readInt";[14]="readMatrix";[15]="readStream";[16]="readString";[17]="readTable";[18]="readType";[19]="readUInt";[2]="getBitsLeft";[20]="readVector";[21]="receive";[22]="send";[23]="start";[24]="writeAngle";[25]="writeBit";[26]="writeColor";[27]="writeData";[28]="writeDouble";[29]="writeEntity";[3]="getBytesLeft";[30]="writeFloat";[31]="writeInt";[32]="writeMatrix";[33]="writeStream";[34]="writeString";[35]="writeTable";[36]="writeType";[37]="writeUInt";[38]="writeVector";[4]="getStreamProgress";[5]="isStreaming";[6]="readAngle";[7]="readBit";[8]="readColor";[9]="readData";["cancelStream"]={["class"]="function";["client"]=true;["description"]="\
Cancels a currently running readStream";["fname"]="cancelStream";["library"]="net";["name"]="net_library.cancelStream";["param"]={};["private"]=false;["realm"]="sh";["server"]=true;["summary"]="\
Cancels a currently running readStream ";};["getBitsLeft"]={["class"]="function";["description"]="\
Returns available bandwidth in bits";["fname"]="getBitsLeft";["library"]="net";["name"]="net_library.getBitsLeft";["param"]={};["private"]=false;["realm"]="sh";["ret"]="number of bits that can be sent";["summary"]="\
Returns available bandwidth in bits ";};["getBytesLeft"]={["class"]="function";["description"]="\
Returns available bandwidth in bytes";["fname"]="getBytesLeft";["library"]="net";["name"]="net_library.getBytesLeft";["param"]={};["private"]=false;["realm"]="sh";["ret"]="number of bytes that can be sent";["summary"]="\
Returns available bandwidth in bytes ";};["getStreamProgress"]={["class"]="function";["client"]=true;["description"]="\
Returns the progress of a running readStream";["fname"]="getStreamProgress";["library"]="net";["name"]="net_library.getStreamProgress";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The progress ratio 0-1";["server"]=true;["summary"]="\
Returns the progress of a running readStream ";};["isStreaming"]={["class"]="function";["description"]="\
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
Reads a large string stream from the net message.";["fname"]="readStream";["library"]="net";["name"]="net_library.readStream";["param"]={[1]="cb";["cb"]="Callback to run when the stream is finished. The first parameter in the callback is the data. Will be nil if transfer fails or is cancelled";};["private"]=false;["realm"]="sh";["server"]=true;["summary"]="\
Reads a large string stream from the net message.";};["readString"]={["class"]="function";["client"]=true;["description"]="\
Reads a string from the net message";["fname"]="readString";["library"]="net";["name"]="net_library.readString";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The string that was read";["server"]=true;["summary"]="\
Reads a string from the net message ";};["readTable"]={["class"]="function";["client"]=true;["description"]="\
Reads an object from a net message automatically typing it \
Will throw an error if invalid type is read. Make sure to pcall it";["fname"]="readTable";["library"]="net";["name"]="net_library.readTable";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The object";["server"]=true;["summary"]="\
Reads an object from a net message automatically typing it \
Will throw an error if invalid type is read.";};["readType"]={["class"]="function";["client"]=true;["description"]="\
Reads an object from a net message automatically typing it \
Will throw an error if invalid type is read. Make sure to pcall it";["fname"]="readType";["library"]="net";["name"]="net_library.readType";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The object";["server"]=true;["summary"]="\
Reads an object from a net message automatically typing it \
Will throw an error if invalid type is read.";};["readUInt"]={["class"]="function";["client"]=true;["description"]="\
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
Writes a string to the net message.";};["writeTable"]={["class"]="function";["client"]=true;["description"]="\
Writes a table to a net message automatically typing it.";["fname"]="writeTable";["library"]="net";["name"]="net_library.writeTable";["param"]={[1]="t";[2]="v";["v"]="The object to write";};["private"]=false;["realm"]="sh";["server"]=true;["summary"]="\
Writes a table to a net message automatically typing it.";};["writeType"]={["class"]="function";["client"]=true;["description"]="\
Writes an object to a net message automatically typing it";["fname"]="writeType";["library"]="net";["name"]="net_library.writeType";["param"]={[1]="v";["v"]="The object to write";};["private"]=false;["realm"]="sh";["server"]=true;["summary"]="\
Writes an object to a net message automatically typing it ";};["writeUInt"]={["class"]="function";["client"]=true;["description"]="\
Writes an unsigned integer to the net message";["fname"]="writeUInt";["library"]="net";["name"]="net_library.writeUInt";["param"]={[1]="t";[2]="n";["n"]="The amount of bits the integer consists of. Should not be greater than 32";["t"]="The integer to be written";};["private"]=false;["realm"]="sh";["server"]=true;["summary"]="\
Writes an unsigned integer to the net message ";};["writeVector"]={["class"]="function";["client"]=true;["description"]="\
Writes an vector to the net message. Has significantly lower precision than writeFloat";["fname"]="writeVector";["library"]="net";["name"]="net_library.writeVector";["param"]={[1]="t";["t"]="The vector to be written";};["private"]=false;["realm"]="sh";["server"]=true;["summary"]="\
Writes an vector to the net message.";};};["libtbl"]="net_library";["name"]="net";["summary"]="\
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
Library for creating and manipulating physics-less models AKA \"Props\".";["fields"]={};["functions"]={[1]="canCreateCustom";[10]="spawnRate";[2]="canSpawn";[3]="create";[4]="createComponent";[5]="createCustom";[6]="createSent";[7]="propsLeft";[8]="setPropClean";[9]="setPropUndo";["canCreateCustom"]={["class"]="function";["description"]="\
Returns if it is possible to create a custom prop yet";["fname"]="canCreateCustom";["library"]="prop";["name"]="props_library.canCreateCustom";["param"]={};["private"]=false;["realm"]="sv";["ret"]="boolean if a custom prop can be created";["summary"]="\
Returns if it is possible to create a custom prop yet ";};["canSpawn"]={["class"]="function";["description"]="\
Checks if a user can spawn anymore props.";["fname"]="canSpawn";["library"]="prop";["name"]="props_library.canSpawn";["param"]={};["private"]=false;["realm"]="sv";["ret"]="True if user can spawn props, False if not.";["server"]=true;["summary"]="\
Checks if a user can spawn anymore props.";};["create"]={["class"]="function";["description"]="\
Creates a prop.";["fname"]="create";["library"]="prop";["name"]="props_library.create";["param"]={[1]="pos";[2]="ang";[3]="model";[4]="frozen";};["private"]=false;["realm"]="sv";["ret"]="The prop object";["server"]=true;["summary"]="\
Creates a prop.";};["createComponent"]={["class"]="function";["description"]="\
Creates starfall component.\\n Allowed components:\\n starfall_hud\\n starfall_screen";["fname"]="createComponent";["library"]="prop";["name"]="props_library.createComponent";["param"]={[1]="pos";[2]="ang";[3]="class";[4]="model";[5]="frozen";["ang"]="Angle of created component";["class"]="Class of created component";["frozen"]="True to spawn frozen";["model"]="Model of created component";["pos"]="Position of created component";};["private"]=false;["realm"]="sv";["ret"]="Component entity";["server"]=true;["summary"]="\
Creates starfall component.\\n Allowed components:\\n starfall_hud\\n starfall_screen ";};["createCustom"]={["class"]="function";["description"]="\
Creates a custom prop.";["fname"]="createCustom";["library"]="prop";["name"]="props_library.createCustom";["param"]={[1]="pos";[2]="ang";[3]="vertices";[4]="frozen";["ang"]="The angles to spawn the prop";["frozen"]="Whether the prop starts frozen";["pos"]="The position to spawn the prop";};["private"]=false;["realm"]="sv";["ret"]="The prop object";["server"]=true;["summary"]="\
Creates a custom prop.";};["createSent"]={["class"]="function";["description"]="\
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
thrown. +x is right, +y is down";["entity"]="starfall_screen";["field"]={[1]="TEXT_ALIGN_LEFT";[2]="TEXT_ALIGN_CENTER";[3]="TEXT_ALIGN_RIGHT";[4]="TEXT_ALIGN_TOP";[5]="TEXT_ALIGN_BOTTOM";["TEXT_ALIGN_BOTTOM"]="";["TEXT_ALIGN_CENTER"]="";["TEXT_ALIGN_LEFT"]="";["TEXT_ALIGN_RIGHT"]="";["TEXT_ALIGN_TOP"]="";};["fields"]={};["functions"]={[1]="capturePixels";[10]="destroyRenderTarget";[11]="destroyTexture";[12]="disableScissorRect";[13]="draw3DBeam";[14]="draw3DBox";[15]="draw3DLine";[16]="draw3DQuad";[17]="draw3DQuadUV";[18]="draw3DSphere";[19]="draw3DSprite";[2]="clear";[20]="draw3DWireframeBox";[21]="draw3DWireframeSphere";[22]="drawCircle";[23]="drawLine";[24]="drawPoly";[25]="drawRect";[26]="drawRectFast";[27]="drawRectOutline";[28]="drawRoundedBox";[29]="drawRoundedBoxEx";[3]="clearBuffersObeyStencil";[30]="drawSimpleText";[31]="drawText";[32]="drawTexturedRect";[33]="drawTexturedRectFast";[34]="drawTexturedRectRotated";[35]="drawTexturedRectRotatedFast";[36]="drawTexturedRectUV";[37]="drawTexturedRectUVFast";[38]="enableClipping";[39]="enableDepth";[4]="clearDepth";[40]="enableScissorRect";[41]="getDefaultFont";[42]="getGameResolution";[43]="getResolution";[44]="getScreenEntity";[45]="getScreenInfo";[46]="getTextSize";[47]="getTextureID";[48]="isHUDActive";[49]="isInRenderView";[5]="clearStencil";[50]="overrideBlend";[51]="parseMarkup";[52]="popCustomClipPlane";[53]="popMatrix";[54]="popViewMatrix";[55]="pushCustomClipPlane";[56]="pushMatrix";[57]="pushViewMatrix";[58]="readPixel";[59]="renderView";[6]="clearStencilBufferRectangle";[60]="renderViewsLeft";[61]="selectRenderTarget";[62]="setBackgroundColor";[63]="setColor";[64]="setCullMode";[65]="setFilterMag";[66]="setFilterMin";[67]="setFont";[68]="setMaterial";[69]="setRGBA";[7]="createFont";[70]="setRenderTargetTexture";[71]="setStencilCompareFunction";[72]="setStencilEnable";[73]="setStencilFailOperation";[74]="setStencilPassOperation";[75]="setStencilReferenceValue";[76]="setStencilTestMask";[77]="setStencilWriteMask";[78]="setStencilZFailOperation";[79]="setTexture";[8]="createRenderTarget";[80]="setTextureFromScreen";[81]="traceSurfaceColor";[9]="cursorPos";["capturePixels"]={["class"]="function";["description"]="\
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
Gets a 2D cursor position where ply is aiming at the current rendered screen or nil if they aren't aiming at it.";["fname"]="cursorPos";["library"]="render";["name"]="render_library.cursorPos";["param"]={[1]="ply";[2]="screen";["ply"]="player to get cursor position from (default: player())";["screen"]="An explicit screen to get the cursor pos of (default: The current rendering screen using 'render' hook)";};["private"]=false;["realm"]="cl";["ret"]={[1]="x position";[2]="y position";};["summary"]="\
Gets a 2D cursor position where ply is aiming at the current rendered screen or nil if they aren't aiming at it.";};["destroyRenderTarget"]={["class"]="function";["description"]="\
Releases the rendertarget. Required if you reach the maximum rendertargets.";["fname"]="destroyRenderTarget";["library"]="render";["name"]="render_library.destroyRenderTarget";["param"]={[1]="name";["name"]="Rendertarget name";};["private"]=false;["realm"]="cl";["summary"]="\
Releases the rendertarget.";};["destroyTexture"]={["class"]="function";["description"]="\
Releases the texture. Required if you reach the maximum url textures.";["fname"]="destroyTexture";["library"]="render";["name"]="render_library.destroyTexture";["param"]={[1]="mat";["mat"]="The material object";};["private"]=false;["realm"]="cl";["summary"]="\
Releases the texture.";};["disableScissorRect"]={["class"]="function";["description"]="\
Disables a scissoring rect which limits the drawing area.";["fname"]="disableScissorRect";["library"]="render";["name"]="render_library.disableScissorRect";["param"]={};["private"]=false;["realm"]="cl";["summary"]="\
Disables a scissoring rect which limits the drawing area.";};["draw3DBeam"]={["class"]="function";["description"]="\
Draws textured beam.";["fname"]="draw3DBeam";["library"]="render";["name"]="render_library.draw3DBeam";["param"]={[1]="startPos";[2]="endPos";[3]="width";[4]="textureStart";[5]="textureEnd";["endPos"]="Beam end position.";["startPos"]="Beam start position.";["textureEnd"]="The end coordinate of the texture used.";["textureStart"]="The start coordinate of the texture used.";["width"]="The width of the beam.";};["private"]=false;["realm"]="cl";["summary"]="\
Draws textured beam.";};["draw3DBox"]={["class"]="function";["description"]="\
Draws a box in 3D space";["fname"]="draw3DBox";["library"]="render";["name"]="render_library.draw3DBox";["param"]={[1]="origin";[2]="angle";[3]="mins";[4]="maxs";["angle"]="Orientation of the box";["maxs"]="End position of the box, relative to origin.";["mins"]="Start position of the box, relative to origin.";["origin"]="Origin of the box.";};["private"]=false;["realm"]="cl";["summary"]="\
Draws a box in 3D space ";};["draw3DLine"]={["class"]="function";["description"]="\
Draws a 3D Line";["fname"]="draw3DLine";["library"]="render";["name"]="render_library.draw3DLine";["param"]={[1]="startPos";[2]="endPos";["endPos"]="Ending position";["startPos"]="Starting position";};["private"]=false;["realm"]="cl";["summary"]="\
Draws a 3D Line ";};["draw3DQuad"]={["class"]="function";["description"]="\
Draws 2 connected triangles.";["fname"]="draw3DQuad";["library"]="render";["name"]="render_library.draw3DQuad";["param"]={[1]="vert1";[2]="vert2";[3]="vert3";[4]="vert4";["vert1"]="First vertex.";["vert2"]="The second vertex.";["vert3"]="The third vertex.";["vert4"]="The fourth vertex.";};["private"]=false;["realm"]="cl";["summary"]="\
Draws 2 connected triangles.";};["draw3DQuadUV"]={["class"]="function";["description"]="\
Draws 2 connected triangles with custom UVs.";["fname"]="draw3DQuadUV";["library"]="render";["name"]="render_library.draw3DQuadUV";["param"]={[1]="vert1";[2]="vert2";[3]="vert3";[4]="vert4";["vert1"]="First vertex. {x, y, z, u, v}";["vert2"]="The second vertex.";["vert3"]="The third vertex.";["vert4"]="The fourth vertex.";};["private"]=false;["realm"]="cl";["summary"]="\
Draws 2 connected triangles with custom UVs.";};["draw3DSphere"]={["class"]="function";["description"]="\
Draws a sphere";["fname"]="draw3DSphere";["library"]="render";["name"]="render_library.draw3DSphere";["param"]={[1]="pos";[2]="radius";[3]="longitudeSteps";[4]="latitudeSteps";["latitudeSteps"]="The amount of latitude steps. The larger this number is, the smoother the sphere is";["longitudeSteps"]="The amount of longitude steps. The larger this number is, the smoother the sphere is";["pos"]="Position of the sphere";["radius"]="Radius of the sphere";};["private"]=false;["realm"]="cl";["summary"]="\
Draws a sphere ";};["draw3DSprite"]={["class"]="function";["description"]="\
Draws a sprite in 3d space.";["fname"]="draw3DSprite";["library"]="render";["name"]="render_library.draw3DSprite";["param"]={[1]="pos";[2]="width";[3]="height";["height"]="Height of the sprite.";["pos"]="Position of the sprite.";["width"]="Width of the sprite.";};["private"]=false;["realm"]="cl";["summary"]="\
Draws a sprite in 3d space.";};["draw3DWireframeBox"]={["class"]="function";["description"]="\
Draws a wireframe box in 3D space";["fname"]="draw3DWireframeBox";["library"]="render";["name"]="render_library.draw3DWireframeBox";["param"]={[1]="origin";[2]="angle";[3]="mins";[4]="maxs";["angle"]="Orientation of the box";["maxs"]="End position of the box, relative to origin.";["mins"]="Start position of the box, relative to origin.";["origin"]="Origin of the box.";};["private"]=false;["realm"]="cl";["summary"]="\
Draws a wireframe box in 3D space ";};["draw3DWireframeSphere"]={["class"]="function";["description"]="\
Draws a wireframe sphere";["fname"]="draw3DWireframeSphere";["library"]="render";["name"]="render_library.draw3DWireframeSphere";["param"]={[1]="pos";[2]="radius";[3]="longitudeSteps";[4]="latitudeSteps";["latitudeSteps"]="The amount of latitude steps. The larger this number is, the smoother the sphere is";["longitudeSteps"]="The amount of longitude steps. The larger this number is, the smoother the sphere is";["pos"]="Position of the sphere";["radius"]="Radius of the sphere";};["private"]=false;["realm"]="cl";["summary"]="\
Draws a wireframe sphere ";};["drawCircle"]={["class"]="function";["description"]="\
Draws a circle outline";["fname"]="drawCircle";["library"]="render";["name"]="render_library.drawCircle";["param"]={[1]="x";[2]="y";[3]="r";["r"]="Radius";["x"]="Center x coordinate";["y"]="Center y coordinate";};["private"]=false;["realm"]="cl";["summary"]="\
Draws a circle outline ";};["drawLine"]={["class"]="function";["description"]="\
Draws a line. Use 3D functions for float coordinates";["fname"]="drawLine";["library"]="render";["name"]="render_library.drawLine";["param"]={[1]="x1";[2]="y1";[3]="x2";[4]="y2";["x1"]="X start integer coordinate";["x2"]="X end interger coordinate";["y1"]="Y start integer coordinate";["y2"]="Y end integer coordinate";};["private"]=false;["realm"]="cl";["summary"]="\
Draws a line.";};["drawPoly"]={["class"]="function";["description"]="\
Draws a polygon.";["fname"]="drawPoly";["library"]="render";["name"]="render_library.drawPoly";["param"]={[1]="poly";["poly"]="Table of polygon vertices. Texture coordinates are optional. {{x=x1, y=y1, u=u1, v=v1}, ... }";};["private"]=false;["realm"]="cl";["summary"]="\
Draws a polygon.";};["drawRect"]={["class"]="function";["description"]="\
Draws a rectangle using the current color";["fname"]="drawRect";["library"]="render";["name"]="render_library.drawRect";["param"]={[1]="x";[2]="y";[3]="w";[4]="h";["h"]="Height";["w"]="Width";["x"]="Top left corner x";["y"]="Top left corner y";};["private"]=false;["realm"]="cl";["summary"]="\
Draws a rectangle using the current color ";};["drawRectFast"]={["class"]="function";["description"]="\
Draws a rectangle using the current color \
Faster, but uses integer coordinates and will get clipped by user's screen resolution";["fname"]="drawRectFast";["library"]="render";["name"]="render_library.drawRectFast";["param"]={[1]="x";[2]="y";[3]="w";[4]="h";["h"]="Height";["w"]="Width";["x"]="Top left corner x";["y"]="Top left corner y";};["private"]=false;["realm"]="cl";["summary"]="\
Draws a rectangle using the current color \
Faster, but uses integer coordinates and will get clipped by user's screen resolution ";};["drawRectOutline"]={["class"]="function";["description"]="\
Draws a rectangle outline using the current color.";["fname"]="drawRectOutline";["library"]="render";["name"]="render_library.drawRectOutline";["param"]={[1]="x";[2]="y";[3]="w";[4]="h";["h"]="Height";["w"]="Width";["x"]="Top left corner x integer coordinate";["y"]="Top left corner y integer coordinate";};["private"]=false;["realm"]="cl";["summary"]="\
Draws a rectangle outline using the current color.";};["drawRoundedBox"]={["class"]="function";["description"]="\
Draws a rounded rectangle using the current color";["fname"]="drawRoundedBox";["library"]="render";["name"]="render_library.drawRoundedBox";["param"]={[1]="r";[2]="x";[3]="y";[4]="w";[5]="h";["h"]="Height";["r"]="The corner radius";["w"]="Width";["x"]="Top left corner x coordinate";["y"]="Top left corner y coordinate";};["private"]=false;["realm"]="cl";["summary"]="\
Draws a rounded rectangle using the current color ";};["drawRoundedBoxEx"]={["class"]="function";["description"]="\
Draws a rounded rectangle using the current color";["fname"]="drawRoundedBoxEx";["library"]="render";["name"]="render_library.drawRoundedBoxEx";["param"]={[1]="r";[2]="x";[3]="y";[4]="w";[5]="h";[6]="tl";[7]="tr";[8]="bl";[9]="br";["bl"]="Boolean Bottom left corner";["br"]="Boolean Bottom right corner";["h"]="Height";["r"]="The corner radius";["tl"]="Boolean Top left corner";["tr"]="Boolean Top right corner";["w"]="Width";["x"]="Top left corner x coordinate";["y"]="Top left corner y coordinate";};["private"]=false;["realm"]="cl";["summary"]="\
Draws a rounded rectangle using the current color ";};["drawSimpleText"]={["class"]="function";["description"]="\
Draws text more easily and quickly but no new lines or tabs.";["fname"]="drawSimpleText";["library"]="render";["name"]="render_library.drawSimpleText";["param"]={[1]="x";[2]="y";[3]="text";[4]="xalign";[5]="yalign";["text"]="Text to draw";["x"]="X coordinate";["xalign"]="Text x alignment";["y"]="Y coordinate";["yalign"]="Text y alignment";};["private"]=false;["realm"]="cl";["summary"]="\
Draws text more easily and quickly but no new lines or tabs.";};["drawText"]={["class"]="function";["description"]="\
Draws text with newlines and tabs";["fname"]="drawText";["library"]="render";["name"]="render_library.drawText";["param"]={[1]="x";[2]="y";[3]="text";[4]="alignment";["alignment"]="Text alignment";["text"]="Text to draw";["x"]="X coordinate";["y"]="Y coordinate";};["private"]=false;["realm"]="cl";["summary"]="\
Draws text with newlines and tabs ";};["drawTexturedRect"]={["class"]="function";["description"]="\
Draws a textured rectangle";["fname"]="drawTexturedRect";["library"]="render";["name"]="render_library.drawTexturedRect";["param"]={[1]="x";[2]="y";[3]="w";[4]="h";["h"]="Height";["w"]="Width";["x"]="Top left corner x";["y"]="Top left corner y";};["private"]=false;["realm"]="cl";["summary"]="\
Draws a textured rectangle ";};["drawTexturedRectFast"]={["class"]="function";["description"]="\
Draws a textured rectangle \
Faster, but uses integer coordinates and will get clipped by user's screen resolution";["fname"]="drawTexturedRectFast";["library"]="render";["name"]="render_library.drawTexturedRectFast";["param"]={[1]="x";[2]="y";[3]="w";[4]="h";["h"]="Height";["w"]="Width";["x"]="Top left corner x";["y"]="Top left corner y";};["private"]=false;["realm"]="cl";["summary"]="\
Draws a textured rectangle \
Faster, but uses integer coordinates and will get clipped by user's screen resolution ";};["drawTexturedRectRotated"]={["class"]="function";["description"]="\
Draws a rotated, textured rectangle.";["fname"]="drawTexturedRectRotated";["library"]="render";["name"]="render_library.drawTexturedRectRotated";["param"]={[1]="x";[2]="y";[3]="w";[4]="h";[5]="rot";["h"]="Height";["rot"]="Rotation in degrees";["w"]="Width";["x"]="X coordinate of center of rect";["y"]="Y coordinate of center of rect";};["private"]=false;["realm"]="cl";["summary"]="\
Draws a rotated, textured rectangle.";};["drawTexturedRectRotatedFast"]={["class"]="function";["description"]="\
Draws a rotated, textured rectangle. \
Faster, but uses integer coordinates and will get clipped by user's screen resolution";["fname"]="drawTexturedRectRotatedFast";["library"]="render";["name"]="render_library.drawTexturedRectRotatedFast";["param"]={[1]="x";[2]="y";[3]="w";[4]="h";[5]="rot";["h"]="Height";["rot"]="Rotation in degrees";["w"]="Width";["x"]="X coordinate of center of rect";["y"]="Y coordinate of center of rect";};["private"]=false;["realm"]="cl";["summary"]="\
Draws a rotated, textured rectangle.";};["drawTexturedRectUV"]={["class"]="function";["description"]="\
Draws a textured rectangle with UV coordinates";["fname"]="drawTexturedRectUV";["library"]="render";["name"]="render_library.drawTexturedRectUV";["param"]={[1]="x";[2]="y";[3]="w";[4]="h";[5]="startU";[6]="startV";[7]="endU";[8]="endV";["endV"]="Texture mapping at rectangle end";["h"]="Height";["startU"]="Texture mapping at rectangle origin";["startV"]="Texture mapping at rectangle origin";["w"]="Width";["x"]="Top left corner x";["y"]="Top left corner y";};["private"]=false;["realm"]="cl";["summary"]="\
Draws a textured rectangle with UV coordinates ";};["drawTexturedRectUVFast"]={["class"]="function";["description"]="\
Draws a textured rectangle with UV coordinates \
Faster, but uses integer coordinates and will get clipped by user's screen resolution";["fname"]="drawTexturedRectUVFast";["library"]="render";["name"]="render_library.drawTexturedRectUVFast";["param"]={[1]="x";[2]="y";[3]="w";[4]="h";[5]="startU";[6]="startV";[7]="endU";[8]="endV";[9]="UVHack";["UVHack"]="If enabled, will scale the UVs to compensate for internal bug. Should be true for user created materials.";["endV"]="Texture mapping at rectangle end";["h"]="Height";["startU"]="Texture mapping at rectangle origin";["startV"]="Texture mapping at rectangle origin";["w"]="Width";["x"]="Top left corner x";["y"]="Top left corner y";};["private"]=false;["realm"]="cl";["summary"]="\
Draws a textured rectangle with UV coordinates \
Faster, but uses integer coordinates and will get clipped by user's screen resolution ";};["enableClipping"]={["class"]="function";["description"]="\
Sets the status of the clip renderer, returning previous state.";["fname"]="enableClipping";["library"]="render";["name"]="render_library.enableClipping";["param"]={[1]="state";["state"]="New clipping state.";};["private"]=false;["realm"]="cl";["ret"]="Previous clipping state.";["summary"]="\
Sets the status of the clip renderer, returning previous state.";};["enableDepth"]={["class"]="function";["description"]="\
Enables or disables Depth Buffer";["fname"]="enableDepth";["library"]="render";["name"]="render_library.enableDepth";["param"]={[1]="enable";["enable"]="true to enable";};["private"]=false;["realm"]="cl";["summary"]="\
Enables or disables Depth Buffer ";};["enableScissorRect"]={["class"]="function";["description"]="\
Enables a scissoring rect which limits the drawing area. Only works 2D contexts such as HUD or render targets.";["fname"]="enableScissorRect";["library"]="render";["name"]="render_library.enableScissorRect";["param"]={[1]="startX";[2]="startY";[3]="endX";[4]="endY";["endX"]="Y end coordinate of the scissor rect.";["startX"]="X start coordinate of the scissor rect.";["startY"]="Y start coordinate of the scissor rect.";};["private"]=false;["realm"]="cl";["summary"]="\
Enables a scissoring rect which limits the drawing area.";};["getDefaultFont"]={["class"]="function";["description"]="\
Gets the default font";["fname"]="getDefaultFont";["library"]="render";["name"]="render_library.getDefaultFont";["param"]={};["private"]=false;["realm"]="cl";["ret"]="Default font";["summary"]="\
Gets the default font ";};["getGameResolution"]={["class"]="function";["classForced"]=true;["description"]="\
Returns width and height of the game window";["fname"]="getGameResolution";["library"]="render";["name"]="render_library.getGameResolution";["param"]={};["private"]=false;["realm"]="cl";["ret"]={[1]="the X size of the game window";[2]="the Y size of the game window";};["summary"]="\
Returns width and height of the game window ";};["getResolution"]={["class"]="function";["classForced"]=true;["description"]="\
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
Make sure to store the texture to use it rather than calling this slow function repeatedly. \
NOTE: This no longer supports material names. Use texture names instead (Textures are .vtf, material are .vmt)";["fname"]="getTextureID";["library"]="render";["name"]="render_library.getTextureID";["param"]={[1]="tx";[2]="cb";[3]="done";["cb"]="An optional callback called when loading is done. Passes nil if it fails or Passes the material, url, width, height, and layout function which can be called with x, y, w, h to reposition the image in the texture.";["done"]="An optional callback called when the image is done loading. Passes the material, url";["tx"]="Texture file path, a http url, or image data: https://en.wikipedia.org/wiki/Data_URI_scheme";};["private"]=false;["realm"]="cl";["ret"]="The material. Use it with render.setTexture";["summary"]="\
Looks up a texture by file name.";};["isHUDActive"]={["class"]="function";["description"]="\
Checks if a hud component is connected to the Starfall Chip";["fname"]="isHUDActive";["library"]="render";["name"]="render_library.isHUDActive";["param"]={};["private"]=false;["realm"]="cl";["summary"]="\
Checks if a hud component is connected to the Starfall Chip ";};["isInRenderView"]={["class"]="function";["description"]="\
Returns whether render.renderView is being executed.";["fname"]="isInRenderView";["library"]="render";["name"]="render_library.isInRenderView";["param"]={};["private"]=false;["realm"]="cl";["summary"]="\
Returns whether render.renderView is being executed.";};["overrideBlend"]={["class"]="function";["description"]="\
Enables blend mode control. Read OpenGL or DirectX docs for more info";["fname"]="overrideBlend";["library"]="render";["name"]="render_library.overrideBlend";["param"]={[1]="on";[2]="srcBlend";[3]="destBlend";[4]="blendFunc";[5]="srcBlendAlpha";[6]="destBlendAlpha";[7]="blendFuncAlpha";["blendFunc"]="Number http://wiki.garrysmod.com/page/Enums/BLENDFUNC";["blendFuncAlpha"]="Optional Number http://wiki.garrysmod.com/page/Enums/BLENDFUNC";["destBlend"]="Number";["destBlendAlpha"]="Optional Number";["on"]="Whether to control the blend mode of upcoming rendering";["srcBlend"]="Number http://wiki.garrysmod.com/page/Enums/BLEND";["srcBlendAlpha"]="Optional Number http://wiki.garrysmod.com/page/Enums/BLEND";};["private"]=false;["realm"]="cl";["summary"]="\
Enables blend mode control.";};["parseMarkup"]={["class"]="function";["description"]="\
Constructs a markup object for quick styled text drawing.";["fname"]="parseMarkup";["library"]="render";["name"]="render_library.parseMarkup";["param"]={[1]="str";[2]="maxsize";["maxsize"]="The max width of the markup";["str"]="The markup string to parse";};["private"]=false;["realm"]="cl";["ret"]="The markup object. See https://wiki.garrysmod.com/page/Category:MarkupObject";["summary"]="\
Constructs a markup object for quick styled text drawing.";};["popCustomClipPlane"]={["class"]="function";["description"]="\
Removes the current active clipping plane from the clip plane stack.";["fname"]="popCustomClipPlane";["library"]="render";["name"]="render_library.popCustomClipPlane";["param"]={};["private"]=false;["realm"]="cl";["summary"]="\
Removes the current active clipping plane from the clip plane stack.";};["popMatrix"]={["class"]="function";["description"]="\
Pops a matrix from the matrix stack.";["fname"]="popMatrix";["library"]="render";["name"]="render_library.popMatrix";["param"]={};["private"]=false;["realm"]="cl";["summary"]="\
Pops a matrix from the matrix stack.";};["popViewMatrix"]={["class"]="function";["description"]="\
Pops a view matrix from the matrix stack.";["fname"]="popViewMatrix";["library"]="render";["name"]="render_library.popViewMatrix";["param"]={};["private"]=false;["realm"]="cl";["summary"]="\
Pops a view matrix from the matrix stack.";};["pushCustomClipPlane"]={["class"]="function";["description"]="\
Pushes a new clipping plane of the clip plane stack.";["fname"]="pushCustomClipPlane";["library"]="render";["name"]="render_library.pushCustomClipPlane";["param"]={[1]="normal";[2]="distance";["distance"]="The normal of the clipping plane.";["normal"]="The normal of the clipping plane.";};["private"]=false;["realm"]="cl";["summary"]="\
Pushes a new clipping plane of the clip plane stack.";};["pushMatrix"]={["class"]="function";["description"]="\
Pushes a matrix onto the matrix stack.";["fname"]="pushMatrix";["library"]="render";["name"]="render_library.pushMatrix";["param"]={[1]="m";[2]="world";["m"]="The matrix";["world"]="Should the transformation be relative to the screen or world?";};["private"]=false;["realm"]="cl";["summary"]="\
Pushes a matrix onto the matrix stack.";};["pushViewMatrix"]={["class"]="function";["description"]="\
Pushes a perspective matrix onto the view matrix stack.";["fname"]="pushViewMatrix";["library"]="render";["name"]="render_library.pushViewMatrix";["param"]={[1]="tbl";["tbl"]="The view matrix data. See http://wiki.garrysmod.com/page/Structures/RenderCamData";};["private"]=false;["realm"]="cl";["summary"]="\
Pushes a perspective matrix onto the view matrix stack.";};["readPixel"]={["class"]="function";["description"]="\
Reads the color of the specified pixel.";["fname"]="readPixel";["library"]="render";["name"]="render_library.readPixel";["param"]={[1]="x";[2]="y";["x"]="Pixel x-coordinate.";["y"]="Pixel y-coordinate.";};["private"]=false;["realm"]="cl";["ret"]="Color object with ( r, g, b, 255 ) from the specified pixel.";["summary"]="\
Reads the color of the specified pixel.";};["renderView"]={["class"]="function";["description"]="\
Renders the scene with the specified viewData to the current active render target.";["fname"]="renderView";["library"]="render";["name"]="render_library.renderView";["param"]={[1]="tbl";[2]="view";["view"]="The view data to be used in the rendering. See http://wiki.garrysmod.com/page/Structures/ViewData. There's an additional key drawviewer used to tell the engine whether the local player model should be rendered.";};["private"]=false;["realm"]="cl";["summary"]="\
Renders the scene with the specified viewData to the current active render target.";};["renderViewsLeft"]={["class"]="function";["description"]="\
Returns how many render.renderView calls can be done in the current frame.";["fname"]="renderViewsLeft";["library"]="render";["name"]="render_library.renderViewsLeft";["param"]={};["private"]=false;["realm"]="cl";["summary"]="\
Returns how many render.renderView calls can be done in the current frame.";};["selectRenderTarget"]={["class"]="function";["description"]="\
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
- DermaLarge";};["setMaterial"]={["class"]="function";["description"]="\
Sets the current render material";["fname"]="setMaterial";["library"]="render";["name"]="render_library.setMaterial";["param"]={[1]="mat";["mat"]="The material object";};["private"]=false;["realm"]="cl";["summary"]="\
Sets the current render material ";};["setRGBA"]={["class"]="function";["description"]="\
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
Sets the current render material";["fname"]="setTexture";["library"]="render";["name"]="render_library.setTexture";["param"]={[1]="mat";["mat"]="The material object";};["private"]=false;["realm"]="cl";["summary"]="\
Sets the current render material ";};["setTextureFromScreen"]={["class"]="function";["description"]="\
Sets the texture of a screen entity";["fname"]="setTextureFromScreen";["library"]="render";["name"]="render_library.setTextureFromScreen";["param"]={[1]="ent";["ent"]="Screen entity";};["private"]=false;["realm"]="cl";["summary"]="\
Sets the texture of a screen entity ";};["traceSurfaceColor"]={["class"]="function";["description"]="\
Does a trace and returns the color of the textel the trace hits.";["fname"]="traceSurfaceColor";["library"]="render";["name"]="render_library.traceSurfaceColor";["param"]={[1]="vec1";[2]="vec2";["vec1"]="The starting vector";["vec2"]="The ending vector";};["private"]=false;["realm"]="cl";["ret"]="The color";["summary"]="\
Does a trace and returns the color of the textel the trace hits.";};};["libtbl"]="render_library";["name"]="render";["summary"]="\
Render library.";["tables"]={};};["sounds"]={["class"]="library";["client"]=true;["description"]="\
Sounds library.";["fields"]={};["functions"]={[1]="canCreate";[2]="create";[3]="soundsLeft";["canCreate"]={["class"]="function";["description"]="\
Returns if a sound is able to be created";["fname"]="canCreate";["library"]="sounds";["name"]="sound_library.canCreate";["param"]={};["private"]=false;["realm"]="sh";["ret"]="If it is possible to make a sound";["summary"]="\
Returns if a sound is able to be created ";};["create"]={["class"]="function";["description"]="\
Creates a sound and attaches it to an entity";["fname"]="create";["library"]="sounds";["name"]="sound_library.create";["param"]={[1]="ent";[2]="path";["ent"]="Entity to attach sound to.";["path"]="Filepath to the sound file.";};["private"]=false;["realm"]="sh";["ret"]="Sound Object";["summary"]="\
Creates a sound and attaches it to an entity ";};["soundsLeft"]={["class"]="function";["description"]="\
Returns the number of sounds left that can be created";["fname"]="soundsLeft";["library"]="sounds";["name"]="sound_library.soundsLeft";["param"]={};["private"]=false;["realm"]="sh";["ret"]="The number of sounds left";["summary"]="\
Returns the number of sounds left that can be created ";};};["libtbl"]="sound_library";["name"]="sounds";["server"]=true;["summary"]="\
Sounds library.";["tables"]={};};["sql"]={["class"]="library";["client"]=true;["description"]="\
SQL library.";["fields"]={};["functions"]={[1]="SQLStr";[2]="query";[3]="tableExists";[4]="tableRemove";["SQLStr"]={["class"]="function";["description"]="\
Escapes dangerous characters and symbols from user input used in an SQLite SQL Query.";["fname"]="SQLStr";["library"]="sql";["name"]="sql_library.SQLStr";["param"]={[1]="str";[2]="bNoQuotes";["bNoQuotes"]="Set this as true, and the function will not wrap the input string in apostrophes.";["str"]="The string to be escaped.";};["private"]=false;["realm"]="cl";["ret"]="The escaped input.";["summary"]="\
Escapes dangerous characters and symbols from user input used in an SQLite SQL Query.";};["query"]={["class"]="function";["description"]="\
Performs a query on the local SQLite database.";["fname"]="query";["library"]="sql";["name"]="sql_library.query";["param"]={[1]="query";["query"]="The query to execute.";};["private"]=false;["realm"]="cl";["ret"]="Query results as a table, nil if the query returned no data.";["summary"]="\
Performs a query on the local SQLite database.";};["tableExists"]={["class"]="function";["description"]="\
Checks if a table exists within the local SQLite database.";["fname"]="tableExists";["library"]="sql";["name"]="sql_library.tableExists";["param"]={[1]="tabname";["tabname"]="The table to check for.";};["private"]=false;["realm"]="cl";["ret"]="False if the table does not exist, true if it does.";["summary"]="\
Checks if a table exists within the local SQLite database.";};["tableRemove"]={["class"]="function";["description"]="\
Removes a table within the local SQLite database.";["fname"]="tableRemove";["library"]="sql";["name"]="sql_library.tableRemove";["param"]={[1]="tabname";["tabname"]="The table to remove.";};["private"]=false;["realm"]="cl";["ret"]="True if the table was successfully removed, false if not.";["summary"]="\
Removes a table within the local SQLite database.";};};["libtbl"]="sql_library";["name"]="sql";["summary"]="\
SQL library.";["tables"]={};};["team"]={["class"]="library";["client"]=true;["description"]="\
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
Provides functions for doing line/AABB traces";["field"]={[1]="MAT_ANTLION";[10]="MAT_METAL";[11]="MAT_SAND";[12]="MAT_FOLIAGE";[13]="MAT_COMPUTER";[14]="MAT_SLOSH";[15]="MAT_TILE";[16]="MAT_GRASS";[17]="MAT_VENT";[18]="MAT_WOOD";[19]="MAT_DEFAULT";[2]="MAT_BLOODYFLESH";[20]="MAT_GLASS";[21]="HITGROUP_GENERIC";[22]="HITGROUP_HEAD";[23]="HITGROUP_CHEST";[24]="HITGROUP_STOMACH";[25]="HITGROUP_LEFTARM";[26]="HITGROUP_RIGHTARM";[27]="HITGROUP_LEFTLEG";[28]="HITGROUP_RIGHTLEG";[29]="HITGROUP_GEAR";[3]="MAT_CONCRETE";[30]="MASK_SPLITAREAPORTAL";[31]="MASK_SOLID_BRUSHONLY";[32]="MASK_WATER";[33]="MASK_BLOCKLOS";[34]="MASK_OPAQUE";[35]="MASK_VISIBLE";[36]="MASK_DEADSOLID";[37]="MASK_PLAYERSOLID_BRUSHONLY";[38]="MASK_NPCWORLDSTATIC";[39]="MASK_NPCSOLID_BRUSHONLY";[4]="MAT_DIRT";[40]="MASK_CURRENT";[41]="MASK_SHOT_PORTAL";[42]="MASK_SOLID";[43]="MASK_BLOCKLOS_AND_NPCS";[44]="MASK_OPAQUE_AND_NPCS";[45]="MASK_VISIBLE_AND_NPCS";[46]="MASK_PLAYERSOLID";[47]="MASK_NPCSOLID";[48]="MASK_SHOT_HULL";[49]="MASK_SHOT";[5]="MAT_FLESH";[50]="MASK_ALL";[51]="CONTENTS_EMPTY";[52]="CONTENTS_SOLID";[53]="CONTENTS_WINDOW";[54]="CONTENTS_AUX";[55]="CONTENTS_GRATE";[56]="CONTENTS_SLIME";[57]="CONTENTS_WATER";[58]="CONTENTS_BLOCKLOS";[59]="CONTENTS_OPAQUE";[6]="MAT_GRATE";[60]="CONTENTS_TESTFOGVOLUME";[61]="CONTENTS_TEAM4";[62]="CONTENTS_TEAM3";[63]="CONTENTS_TEAM1";[64]="CONTENTS_TEAM2";[65]="CONTENTS_IGNORE_NODRAW_OPAQUE";[66]="CONTENTS_MOVEABLE";[67]="CONTENTS_AREAPORTAL";[68]="CONTENTS_PLAYERCLIP";[69]="CONTENTS_MONSTERCLIP";[7]="MAT_ALIENFLESH";[70]="CONTENTS_CURRENT_0";[71]="CONTENTS_CURRENT_90";[72]="CONTENTS_CURRENT_180";[73]="CONTENTS_CURRENT_270";[74]="CONTENTS_CURRENT_UP";[75]="CONTENTS_CURRENT_DOWN";[76]="CONTENTS_ORIGIN";[77]="CONTENTS_MONSTER";[78]="CONTENTS_DEBRIS";[79]="CONTENTS_DETAIL";[8]="MAT_CLIP";[80]="CONTENTS_TRANSLUCENT";[81]="CONTENTS_LADDER";[82]="CONTENTS_HITBOX";[9]="MAT_PLASTIC";["CONTENTS_AREAPORTAL"]="";["CONTENTS_AUX"]="";["CONTENTS_BLOCKLOS"]="";["CONTENTS_CURRENT_0"]="";["CONTENTS_CURRENT_180"]="";["CONTENTS_CURRENT_270"]="";["CONTENTS_CURRENT_90"]="";["CONTENTS_CURRENT_DOWN"]="";["CONTENTS_CURRENT_UP"]="";["CONTENTS_DEBRIS"]="";["CONTENTS_DETAIL"]="";["CONTENTS_EMPTY"]="";["CONTENTS_GRATE"]="";["CONTENTS_HITBOX"]="";["CONTENTS_IGNORE_NODRAW_OPAQUE"]="";["CONTENTS_LADDER"]="";["CONTENTS_MONSTER"]="";["CONTENTS_MONSTERCLIP"]="";["CONTENTS_MOVEABLE"]="";["CONTENTS_OPAQUE"]="";["CONTENTS_ORIGIN"]="";["CONTENTS_PLAYERCLIP"]="";["CONTENTS_SLIME"]="";["CONTENTS_SOLID"]="";["CONTENTS_TEAM1"]="";["CONTENTS_TEAM2"]="";["CONTENTS_TEAM3"]="";["CONTENTS_TEAM4"]="";["CONTENTS_TESTFOGVOLUME"]="";["CONTENTS_TRANSLUCENT"]="";["CONTENTS_WATER"]="";["CONTENTS_WINDOW"]="";["HITGROUP_CHEST"]="";["HITGROUP_GEAR"]="";["HITGROUP_GENERIC"]="";["HITGROUP_HEAD"]="";["HITGROUP_LEFTARM"]="";["HITGROUP_LEFTLEG"]="";["HITGROUP_RIGHTARM"]="";["HITGROUP_RIGHTLEG"]="";["HITGROUP_STOMACH"]="";["MASK_ALL"]="";["MASK_BLOCKLOS"]="";["MASK_BLOCKLOS_AND_NPCS"]="";["MASK_CURRENT"]="";["MASK_DEADSOLID"]="";["MASK_NPCSOLID"]="";["MASK_NPCSOLID_BRUSHONLY"]="";["MASK_NPCWORLDSTATIC"]="";["MASK_OPAQUE"]="";["MASK_OPAQUE_AND_NPCS"]="";["MASK_PLAYERSOLID"]="";["MASK_PLAYERSOLID_BRUSHONLY"]="";["MASK_SHOT"]="";["MASK_SHOT_HULL"]="";["MASK_SHOT_PORTAL"]="";["MASK_SOLID"]="";["MASK_SOLID_BRUSHONLY"]="";["MASK_SPLITAREAPORTAL"]="";["MASK_VISIBLE"]="";["MASK_VISIBLE_AND_NPCS"]="";["MASK_WATER"]="";["MAT_ALIENFLESH"]="";["MAT_ANTLION"]="";["MAT_BLOODYFLESH"]="";["MAT_CLIP"]="";["MAT_COMPUTER"]="";["MAT_CONCRETE"]="";["MAT_DEFAULT"]="";["MAT_DIRT"]="";["MAT_FLESH"]="";["MAT_FOLIAGE"]="";["MAT_GLASS"]="";["MAT_GRASS"]="";["MAT_GRATE"]="";["MAT_METAL"]="";["MAT_PLASTIC"]="";["MAT_SAND"]="";["MAT_SLOSH"]="";["MAT_TILE"]="";["MAT_VENT"]="";["MAT_WOOD"]="";};["fields"]={};["functions"]={[1]="intersectRayWithOBB";[2]="intersectRayWithPlane";[3]="trace";[4]="traceHull";["intersectRayWithOBB"]={["class"]="function";["description"]="\
Does a ray box intersection returning the position hit, normal, and trace fraction, or nil if not hit.";["fname"]="intersectRayWithOBB";["library"]="trace";["name"]="trace_library.intersectRayWithOBB";["param"]={[1]="rayStart";[2]="rayDelta";[3]="boxOrigin";[4]="boxAngles";[5]="boxMins";[6]="boxMaxs";["boxAngles"]="The box's angles";["boxMaxs"]="The box max bounding vector";["boxMins"]="The box min bounding vector";["boxOrigin"]="The origin of the box";["rayDelta"]="The direction and length of the ray";["rayStart"]="The origin of the ray";};["private"]=false;["realm"]="sh";["ret"]={[1]="Hit position or nil if not hit";[2]="Hit normal or nil if not hit";[3]="Hit fraction or nil if not hit";};["summary"]="\
Does a ray box intersection returning the position hit, normal, and trace fraction, or nil if not hit.";};["intersectRayWithPlane"]={["class"]="function";["description"]="\
Does a ray plane intersection returning the position hit or nil if not hit";["fname"]="intersectRayWithPlane";["library"]="trace";["name"]="trace_library.intersectRayWithPlane";["param"]={[1]="rayStart";[2]="rayDelta";[3]="planeOrigin";[4]="planeNormal";["planeNormal"]="The normal of the plane";["planeOrigin"]="The origin of the plane";["rayDelta"]="The direction and length of the ray";["rayStart"]="The origin of the ray";};["private"]=false;["realm"]="sh";["ret"]="Hit position or nil if not hit";["summary"]="\
Does a ray plane intersection returning the position hit or nil if not hit ";};["trace"]={["class"]="function";["description"]="\
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
Wires two entities together";["fname"]="create";["library"]="wire";["name"]="wire_library.create";["param"]={[1]="entI";[2]="entO";[3]="inputname";[4]="outputname";[5]="width";[6]="color";[7]="material";["color"]="Color of the wire(optional)";["entI"]="Entity with input";["entO"]="Entity with output";["inputname"]="Input to be wired";["material"]="Material of the wire(optional), Valid materials are cable/rope, cable/cable2, cable/xbeam, cable/redlaser, cable/blue_elec, cable/physbeam, cable/hydra, arrowire/arrowire, arrowire/arrowire2";["outputname"]="Output to be wired";["width"]="Width of the wire(optional)";};["private"]=false;["realm"]="sv";["summary"]="\
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
Ports table.";["tname"]="ports";};};};["xinput"]={["class"]="library";["client"]=true;["description"]="\
A simpler, hook-based, and more-powerful controller input library. Inputs are not lost between rendered frames, and there is support for rumble. Note: the client must have the XInput lua binary module installed in order to access this library. See more at https://github.com/mitterdoo/garrysmod-xinput";["fields"]={};["functions"]={[1]="getBatteryLevel";[2]="getButton";[3]="getControllers";[4]="getState";[5]="getStick";[6]="getTrigger";[7]="setRumble";["getBatteryLevel"]={["class"]="function";["classForced"]=true;["description"]="\
Attempts to check the battery level of the controller.";["fname"]="getBatteryLevel";["library"]="xinput";["name"]="xinput_library.getBatteryLevel";["param"]={[1]="id";["id"]="Controller number. Starts at 0";};["realm"]="cl";["ret"]="If successful: a number between 0.0-1.0 inclusive. If unsuccessful: false, and a string error message";["summary"]="\
Attempts to check the battery level of the controller.";};["getButton"]={["class"]="function";["classForced"]=true;["description"]="\
Gets whether the button on the controller is currently pushed down.";["fname"]="getButton";["library"]="xinput";["name"]="xinput_library.getButton";["param"]={[1]="id";[2]="button";["button"]="The button to check for. See https://github.com/mitterdoo/garrysmod-xinput#xinput_gamepad_";["id"]="Controller number. Starts at 0";};["realm"]="cl";["ret"]="bool";["summary"]="\
Gets whether the button on the controller is currently pushed down.";};["getControllers"]={["class"]="function";["classForced"]=true;["description"]="\
Gets all of the connected controllers.";["fname"]="getControllers";["library"]="xinput";["name"]="xinput_library.getControllers";["param"]={};["realm"]="cl";["ret"]="A table where each key is the ID of the controller that is connected. Disconnected controllers are not placed in the table.";["summary"]="\
Gets all of the connected controllers.";};["getState"]={["class"]="function";["classForced"]=true;["description"]="\
Gets the state of the controller.";["fname"]="getState";["library"]="xinput";["name"]="xinput_library.getState";["param"]={[1]="id";["id"]="Controller number. Starts at 0";};["realm"]="cl";["ret"]="Table containing all input data of the controller, or false if the controller is not connected. The table uses this struct: https://github.com/mitterdoo/garrysmod-xinput#xinput_gamepad";["summary"]="\
Gets the state of the controller.";};["getStick"]={["class"]="function";["classForced"]=true;["description"]="\
Gets the current coordinates of the stick on the controller.";["fname"]="getStick";["library"]="xinput";["name"]="xinput_library.getStick";["param"]={[1]="id";[2]="stick";["id"]="Controller number. Starts at 0";["stick"]="Which stick to use. 0 is left";};["realm"]="cl";["ret"]="Two numbers for the X and Y coordinates, respectively, each being between -32768 - 32767 inclusive";["summary"]="\
Gets the current coordinates of the stick on the controller.";};["getTrigger"]={["class"]="function";["classForced"]=true;["description"]="\
Gets the current position of the trigger on the controller.";["fname"]="getTrigger";["library"]="xinput";["name"]="xinput_library.getTrigger";["param"]={[1]="id";[2]="trigger";["id"]="Controller number. Starts at 0";["trigger"]="Which trigger to use. 0 is left";};["realm"]="cl";["ret"]="0-255 inclusive";["summary"]="\
Gets the current position of the trigger on the controller.";};["setRumble"]={["class"]="function";["description"]="\
Sets the rumble on the controller.";["fname"]="setRumble";["library"]="xinput";["name"]="xinput_library.setRumble";["param"]={[1]="id";[2]="softPercent";[3]="hardPercent";["hardPercent"]="A number between 0.0-1.0 for how much the hard rumble motor should vibrate.";["id"]="Controller number. Starts at 0";["softPercent"]="A number between 0.0-1.0 for how much the soft rumble motor should vibrate.";};["private"]=false;["realm"]="cl";["summary"]="\
Sets the rumble on the controller.";};};["libtbl"]="xinput_library";["name"]="xinput";["summary"]="\
A simpler, hook-based, and more-powerful controller input library.";["tables"]={};};};};