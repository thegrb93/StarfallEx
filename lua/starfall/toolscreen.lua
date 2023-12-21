
if SERVER then

	util.AddNetworkString("sf_notify_tool_error")
	hook.Add("StarfallChipError", "StarfallToolscreenError", function(chip)
		if chip.instance.player.IsPlayer then -- Superuser check
			net.Start("sf_notify_tool_error")
			net.Send(chip.instance.player)
		end
	end)

else

	local draw, surface = draw, surface
	local math_rand, math_random = math.Rand, math.random
	local math_cos, math_sin = math.cos, math.sin
	local math_abs, math_clamp = math.abs, math.Clamp
	local math_normalize_angle = math.NormalizeAngle

	surface.CreateFont("StarfallToolBig", { font = "Roboto-Bold.ttf", size = 36 })
	surface.CreateFont("StarfallToolSmall", { font = "Roboto-Italic.ttf", size = 32, shadow = true })

	CreateClientConVar("starfall_toolscreen", "1", true, false, "Enable Starfall custom toolgun screen animation. Requires reconnect!", 0, 1)
	local simulation_fps = CreateClientConVar("starfall_toolscreen_fps", "120", true, false, "Maximum FPS of the stars animation", 30, 300):GetInt()
	cvars.AddChangeCallback("starfall_toolscreen_fps", function(_, _, value)
		simulation_fps = value
	end)

	local color_background       = Color(33, 33, 40, 30)              -- Background color, alpha controls how fast the stars fade out
	local color_background_solid = ColorAlpha(color_background, 255)  -- Solid version of the background color for the Linux fix
	local color_text             = Color(240, 240, 253, 255)          -- Text color for subtitle and scrolling text
	local color_text_outline     = ColorAlpha(color_background, 80)   -- Outline text color for subtitle and scrolling text
	local star_count             = 8                                  -- Amount of stars to render
	local star_deceleration      = 0.35                               -- How much velocity to retain
	local star_velocity_bump     = 300                                -- Random velocity towards the center when resetting star
	local star_velocity_max      = 1000                               -- Maximum velocity of a star
	local star_ang_velocity_min  = 100                                -- Minimum angle velocity of a star
	local star_ang_velocity_max  = 350                                -- Maximum angle velocity of a star
	local star_ply_movement_mul  = 10                                 -- Player movement influence multiplier
	local star_ply_angle_mul     = 25                                 -- Player eye angle influence multiplier
	local star_reset_radius      = 200                                -- Distance to which teleport the star when flipping
	local star_reset_radius_sqr  = star_reset_radius ^ 2 + 10         -- Distance squared and offset at which to teleport the star
	local star_random_offset     = math.pi / 8                        -- Random angle offset to set when flipping the star
	local function get_random_star_properties()
		return
			HSVToColor(math_rand(190, 220), math_rand(0.6, 1), 0.9),  -- Color
			math_rand(40, 120),                                       -- Size
			math_rand(200, 600),                                      -- Gravity
			math_rand(0.3, 1) * (math_random() > 0.5 and 1 or -1)     -- Rotation direction
	end

	-------------------------------------------

	local stars = {}
	for _ = 1, star_count do
		local color, size, gravity, ang_dir = get_random_star_properties()
		stars[#stars+1] = {
			x       = math_rand(-128, 128),
			y       = math_rand(-128, 128),
			x_vel   = math_rand(-star_velocity_max, star_velocity_max),
			y_vel   = star_velocity_max,
			ang     = 0,
			ang_vel = 0,
			ang_dir = ang_dir,
			color   = color,
			size    = size,
			gravity = gravity,
		}
	end

	local overlay_material = Material("radon/starfall_tool_overlay.png", "smooth")
	overlay_material:SetInt("$flags", 0x8000 + 0x0020)

	local star_material = Material("radon/starfall_tool_star.png", "smooth")
	star_material:SetInt("$flags", 0x8000 + 0x0080 + 0x0020 + 0x0010)

	-- RenderTargets created before rendering is ready suffer from depth related issues
	local star_canvas, star_canvas_material
	hook.Add("PreRender", "StarfallToolscreenPrepare", function()
		star_canvas = GetRenderTarget("starfall_tool_canvas", 256, 256)
		star_canvas_material = CreateMaterial("starfall_tool_material", "UnlitGeneric", { ["$basetexture"] = star_canvas:GetName() })
		star_canvas_material:SetInt("$flags", 0x8000 + 0x0020 + 0x0010)
		star_canvas_material:SetInt("$ignorez", 1)
		hook.Remove("PreRender", "StarfallToolscreenPrepare")
	end)

	local stars_errored_delay = 0
	local function starfall_chip_errored()
		if stars_errored_delay <= 0 then
			for _, star in ipairs(stars) do
				star.color = HSVToColor(350 + math_random() * 20, 0.7, 0.85)
			end
		end
		stars_errored_delay = 3 -- How long should the stars remain red after an error
	end
	net.Receive("sf_notify_tool_error", starfall_chip_errored)
	hook.Add("StarfallChipError", "StarfallToolscreenError", function(chip)
		if chip.instance.player == LocalPlayer() then
			starfall_chip_errored()
		end
	end)

	-------------------------------------------

	local last_frame = 0
	local is_linux = system.IsLinux()
	local ply_eye_ang_prev = Angle()
	local function draw_stars(w, h)
		local curtime = RealTime()
		local dt = curtime - last_frame
		if dt > 1 / simulation_fps then
			last_frame = curtime
			stars_errored_delay = stars_errored_delay - dt
			local deceleration = star_deceleration ^ dt

			local ply = LocalPlayer()
			local ply_world_vel = ply:GetVelocity()
			local ply_local_vel = ply:WorldToLocal(ply:GetPos() + Vector(ply_world_vel.x, ply_world_vel.y, 0))

			local ply_eye_ang = ply:EyeAngles()
			local ply_eye_ang_delta = ply_eye_ang - ply_eye_ang_prev
			local ply_eye_pitch = math_normalize_angle(ply_eye_ang_delta[1]) * star_ply_angle_mul
			local ply_eye_yaw = math_normalize_angle(ply_eye_ang_delta[2]) * star_ply_angle_mul
			ply_eye_ang_prev = ply_eye_ang

			render.PushRenderTarget(star_canvas)
			local blur = math_clamp(8 + 600 * dt, 12, 30)
			render.BlurRenderTarget(star_canvas, blur, blur, 1)

			surface.SetMaterial(star_canvas_material)
			surface.SetDrawColor(color_background.r, color_background.g, color_background.b, math_clamp(3000 * dt + 20, 40, 120))
			surface.DrawTexturedRect(0, 0, w, h)

			surface.SetMaterial(star_material)
			for _, star in ipairs(stars) do
				local size = star.size
				local x, y = star.x, star.y
				local x_vel, y_vel = star.x_vel, star.y_vel
				local ang, ang_vel, ang_dir = star.ang, star.ang_vel, star.ang_dir
				local color, gravity = star.color, star.gravity

				if x ^ 2 + y ^ 2 > star_reset_radius_sqr then
					local offset_ang = math.atan2(-star.y, -star.x) + math_rand(-star_random_offset, star_random_offset)
					local offset_x, offset_y = math_cos(offset_ang), math_sin(offset_ang)
					x = offset_x * star_reset_radius
					y = offset_y * star_reset_radius

					local towards_center = math_rand(-star_velocity_bump, star_velocity_bump)
					x_vel = x_vel - offset_x * towards_center * 2
					y_vel = y_vel - offset_y * towards_center

					color, size, gravity, ang_dir = get_random_star_properties()
					star.size, star.gravity, star.ang_dir = size, gravity, ang_dir

					if stars_errored_delay < 0 then
						star.color = color
					end
				end

				x_vel = x_vel + ((ply_local_vel.y) * star_ply_movement_mul * dt) + ply_eye_yaw
				x_vel = math_clamp(x_vel * deceleration, -star_velocity_max, star_velocity_max)

				y_vel = y_vel + ((ply_local_vel.x + ply_world_vel.z) * star_ply_movement_mul * dt) - ply_eye_pitch + gravity * dt
				y_vel = math_clamp(y_vel * deceleration, -star_velocity_max, star_velocity_max)

				ang_vel = ang_vel + (math_abs(x_vel) * 2 + math_abs(y_vel) / 2) * dt
				ang_vel = math_clamp(ang_vel * deceleration, star_ang_velocity_min, star_ang_velocity_max)

				-------------------------------------------

				x = x + x_vel * dt
				y = y + y_vel * dt
				ang = ang + ang_dir * ang_vel * dt

				surface.SetDrawColor(color.r, color.g, color.b, 230)
				surface.DrawTexturedRectRotated(128 + x, 128 + y, size, size, ang)

				star.x, star.y = x, y
				star.x_vel, star.y_vel = x_vel, y_vel
				star.ang, star.ang_vel = ang, ang_vel
			end
			render.PopRenderTarget()
		end

		if is_linux then -- On Linux the original tool background is still visible
			surface.SetDrawColor(color_background_solid)
			surface.DrawRect(0, 0, w, h)
		end

		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(star_canvas_material)
		surface.DrawTexturedRect(0, 0, w, h)
	end

	local function draw_overlay(w, h, title, scroll_text)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(overlay_material)
		surface.DrawTexturedRect(0, 0, w, h)
		draw.SimpleTextOutlined(title, "StarfallToolBig", 128, 90, color_text, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, color_text_outline)

		if scroll_text then
			surface.SetFont("StarfallToolSmall")
			local text_width = surface.GetTextSize(scroll_text) + 60
			local x = RealTime() * 100 % text_width * -1
			while x < 256 do
				draw.SimpleTextOutlined(scroll_text, "StarfallToolSmall", x, 226, color_text, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER, 2, color_text_outline)
				x = x + text_width
			end
		end
	end

	function SF.DrawToolgunScreen(w, h, subtitle, scroll_text)
		draw_stars(w, h)
		draw_overlay(w, h, subtitle, scroll_text)
	end

end
