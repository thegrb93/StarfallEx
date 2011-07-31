
include("autorun/server/libtransfer.lua")

--------------------------- Variables ---------------------------

local files_module = {}
SF_Compiler.AddModule("files",files_module)

local fdata = setmetatable({},{__mode="k"})


--------------------------- Settings ---------------------------

local fileuploadtime = CreateConVar("sf_file_upload_cooldown", "3", {FCVAR_REPLICATED, FCVAR_ARCHIVE, FCVAR_DONTRECORD})

--------------------------- Hooks ---------------------------

local function init(context)
	local ply = context.ply
	
	if not fdata[ply] then
		fdata[ply] = {expecting = {}, cooldown = 0}
	end
end
SF_Compiler.AddInternalHook("init", init)

local function recieve(ply,data)
	local path = data.path
	if not (fdata[ply].expecting and fdata[ply].expecting[path]) then
		MsgN("SF: Didn't expect a file upload from "..ply:GetName().." (Path: "..path..")")
	else
		local chips = fdata[ply].expecting[path]
		for chip in pairs(chips) do
			chip:RunHook("FileRecieved",path,data.contents)
		end
		fdata[ply].expecting[path] = nil
	end
end
LibTransfer:SetCallback("sf_file_upload",recieve)

--------------------------- Module Functions ---------------------------

function files_module.download(path)
	SF_Compiler.CheckType(path,"string")
	
	if string.find(path,"..",1,true) then
		error("Filepath cannot contain '..'",2)
	end
	
	if #path > 240 then
		error("Filepath too long ("..#path.." characters)",2)
	end
	
	local context = SF_Compiler.currentChip
	local ply = context.ply
	local curtime = CurTime()
	
	if fdata[ply].cooldown >= curtime then
		error("Attempted a file transfer during cooldown period",2)
	end
	
	if not fdata[ply].expecting[path] then
		fdata[ply].expecting[path] = {}
	end
	fdata[ply].expecting[path][context.ent] = true
	
	umsg.Start("sf_files_uploadreq",ply)
		umsg.String(path)
	umsg.End()
	fdata[ply].cooldown = curtime + fileuploadtime:GetFloat()
end

function files_module.upload(path,data)
	SF_Compiler.CheckType(path,"string")
	SF_Compiler.CheckType(data,"string")
	
	if string.find(path,"..",1,true) then
		error("Filepath cannot contain '..'",2)
	end
	
	if #path > 240 then
		error("Filepath too long ("..#path.." characters)",2)
	end
	
	local context = SF_Compiler.currentChip
	local ply = context.ply
	local curtime = CurTime()
	
	if fdata[ply].cooldown >= curtime then
		error("Attempted a file transfer during cooldown period",2)
	end
	
	LibTransfer:QueueTask(ply, "sf_files_download", {path = path, contents = data})
	
	fdata[ply].cooldown = curtime + fileuploadtime:GetFloat()
end

function files_module.canTransfer()
	local context = SF_Compiler.currentChip
	return fdata[context.ply].cooldown <= CurTime()
end