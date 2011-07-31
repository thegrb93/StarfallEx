
include("autorun/client/cl_libtransfer.lua")

--------------------------- Uploading/Downloading ---------------------------

local function umsg_cbk(msg)
	local path = msg:ReadString()
	local contents = file.Read(path)
	LibTransfer:QueueTask("sf_file_upload",{path = path, contents = contents})
end
usermessage.Hook("sf_files_uploadreq",umsg_cbk)

local function download_cbk(data)
	file.Write(data.path, data.contents)
end
LibTransfer:SetCallback("sf_files_download",download_cbk)

local function download_multi_cbk(data)
	for _,f in pairs(data) do
		download_cbk(f)
	end
end
LibTransfer:SetCallback("sf_files_download_multi",download_cbk)