
local clamp = math.Clamp

SF_Compiler.AddFunction("print",function(msg)
	if msg == nil or type(msg) ~= "string" then error("print() called with nonstring argument.") end
	SF_Compiler.currentChip.ply:PrintMessage(HUD_PRINTTALK, msg)
end)

SF_Compiler.AddFunction("notify",function(msg, duration)
	if msg == nil or type(msg) ~= "string" or
		duration == nil or type(duration) ~= "number" then error("notify() called with illegal arguments.") end
	WireLib.AddNotify(SF_Compiler.currentChip.ply,msg,NOTIFY_GENERIC,clamp(duration,0.7,7),NOTIFYSOUND_DRIP1)
end)