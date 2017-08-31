--@name MusicPlayer
--@author Sparky
--@model models/props_lab/citizenradio.mdl

if SERVER then 
	hook.add("PlayerSay", "Hey", function(ply, txt)
		if ply==entities.owner() and txt:sub(1, 6)=="!song " then
			net.start("playSong")
			net.writeString(txt:sub(7))
			net.send()
			
			return ""
		end
	end)
else
	hook.add("net", "songs", function(name, len, pl)
		if name~="playSong" then return end
		
		if song then song:stop() end
		bass.loadURL(net.readString(), "3d noblock", function(snd, err, errtxt)
			if snd then
				song = snd
				snd:setFade(500, 100000)
				snd:setLooping(true)
				snd:setVolume(2)
				hook.add("think", "snd", function()
					snd:setPos(chip():getPos())
				end)
			else
				print(errtxt)
			end
		end)
	end)
end
