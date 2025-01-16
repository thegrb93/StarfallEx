
local draw, surface = draw, surface
local math_rand, math_random = math.Rand, math.random
local math_cos, math_sin = math.cos, math.sin
local math_abs, math_clamp = math.abs, math.Clamp
local math_normalize_angle = math.NormalizeAngle

surface.CreateFont("StarfallToolBig", { font = "Roboto-Bold.ttf", size = 36 })
surface.CreateFont("StarfallToolSmall", { font = "Roboto-Italic.ttf", size = 32, shadow = true })

local simulation_fps = CreateClientConVar("starfall_toolscreen_fps", "120", true, false, "Maximum FPS of the stars animation", 30, 300):GetInt()
cvars.AddChangeCallback("starfall_toolscreen_fps", function(_, _, value)
	simulation_fps = tonumber(value) or 120
end)

-- Tuning vars
local color_background       = Color(41, 38, 52)                  -- Background color
local color_text             = Color(240, 240, 253, 255)          -- Text color for subtitle and scrolling text
local color_text_outline     = ColorAlpha(color_background, 80)   -- Outline text color for subtitle and scrolling text
local star_count             = 8                                  -- Amount of stars to render
local star_deceleration      = 0.35                               -- How much velocity to retain
local star_velocity_bump     = 300                                -- Random velocity towards the center when resetting star
local star_velocity_max      = 800                                -- Maximum velocity of a star
local star_ang_velocity_min  = 100                                -- Minimum angle velocity of a star
local star_ang_velocity_max  = 350                                -- Maximum angle velocity of a star
local star_ply_movement_mul  = 2000                               -- Player movement influence multiplier
local star_ply_angle_mul     = 25                                 -- Player eye angle influence multiplier
local star_reset_radius      = 200                                -- Distance to which teleport the star when flipping
local star_reset_radius_sqr  = star_reset_radius ^ 2 + 10         -- Distance squared and offset at which to teleport the star
local star_random_offset     = math.pi / 8                        -- Random angle offset to set when flipping the star
local star_error_color_time  = 6                                  -- How long for stars to be error color

-- Globals
local last_error_time = 0
local last_frame = 0
local curtime = 0
local dt = 0
local ply_local_vel, ply_eye_yaw, ply_eye_pitch, deceleration

local function star_randomize(star)
	star.size = math_rand(40, 120)
	star.gravity = math_rand(200, 600)
	star.ang_dir = math.random() < 0.5 and 1 or -1

	if last_error_time < RealTime() then
		star.color = HSVToColor(190 + math.random() * 30, math_rand(0.6, 1), 0.9)
	else
		star.color = HSVToColor(350 + math_random() * 20, math_rand(0.6, 1), 0.9)
	end

	return star
end

local function star_init()
	return star_randomize({
		x = math_rand(-128, 128),
		y = math_rand(-128, 128),
		x_vel = math_rand(-star_velocity_max, star_velocity_max),
		y_vel = star_velocity_max,
		ang = 0,
		ang_vel = 0,
	})
end

local function star_reset(star)
	local offset_ang = math.atan2(-star.y, -star.x) + math_rand(-star_random_offset, star_random_offset)
	local offset_x, offset_y = math_cos(offset_ang), math_sin(offset_ang)
	star.x = offset_x * star_reset_radius
	star.y = offset_y * star_reset_radius

	local towards_center = math_rand(-star_velocity_bump, star_velocity_bump)
	star.x_vel = star.x_vel - offset_x * towards_center * 2
	star.y_vel = star.y_vel - offset_y * towards_center

	star_randomize(star)
end

local function star_update_and_draw(star)
	if star.x ^ 2 + star.y ^ 2 > star_reset_radius_sqr then
		star_reset(star)
	end

	star.x_vel = star.x_vel + ((ply_local_vel.y) * star_ply_movement_mul * dt) + ply_eye_yaw
	star.x_vel = math_clamp(star.x_vel * deceleration, -star_velocity_max, star_velocity_max)

	star.y_vel = star.y_vel + ((ply_local_vel.x + ply_local_vel.z) * star_ply_movement_mul * dt) - ply_eye_pitch + star.gravity * dt
	star.y_vel = math_clamp(star.y_vel * deceleration, -star_velocity_max, star_velocity_max)

	star.ang_vel = star.ang_vel + (math_abs(star.x_vel) * 2 + math_abs(star.y_vel) / 2) * dt
	star.ang_vel = math_clamp(star.ang_vel * deceleration, star_ang_velocity_min, star_ang_velocity_max)

	star.x = star.x + star.x_vel * dt
	star.y = star.y + star.y_vel * dt
	star.ang = star.ang + star.ang_dir * star.ang_vel * dt

	surface.SetDrawColor(star.color.r, star.color.g, star.color.b, 230)
	surface.DrawTexturedRectRotated(128 + star.x, 128 + star.y, star.size, star.size, star.ang)
end


-------------------------------------------

local stars = {}
for i = 1, star_count do
	stars[i] = star_init()
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
	star_canvas_material:SetInt("$flags", 0x8000 + 0x0010)
	render.ClearRenderTarget(star_canvas, color_background)
	hook.Remove("PreRender", "StarfallToolscreenPrepare")
end)

hook.Add("StarfallError", "StarfallToolscreenError", function(_, owner, client)
	local local_player = LocalPlayer()
	if owner ~= local_player then return end
	if client and client ~= local_player then return end
	last_error_time = RealTime() + star_error_color_time
end)

-------------------------------------------

local ply_eye_ang_prev = Angle()
function SF.DrawToolgunScreen(w, h, title, scroll_text)
	curtime = RealTime()
	dt = curtime - last_frame
	if dt > 1 / simulation_fps then
		last_frame = curtime
		local ply = LocalPlayer()

		local ply_eye_ang = ply:EyeAngles()
		local ply_eye_ang_delta = ply_eye_ang - ply_eye_ang_prev

		ply_eye_pitch = math_normalize_angle(ply_eye_ang_delta[1]) * star_ply_angle_mul
		ply_eye_yaw = math_normalize_angle(ply_eye_ang_delta[2]) * star_ply_angle_mul
		ply_eye_ang_prev = ply_eye_ang
		deceleration = star_deceleration ^ dt

		ply_local_vel = WorldToLocal(ply:GetVelocity():GetNormalized(), angle_zero, vector_origin, Angle(0, ply_eye_ang.y, 0))

		render.PushRenderTarget(star_canvas)
		local blur = math_clamp(8 + 600 * dt, 12, 30)
		render.BlurRenderTarget(star_canvas, blur, blur, 1)

		surface.SetDrawColor(color_background.r, color_background.g, color_background.b, math_clamp(2500 * dt + 20, 30, 100))
		surface.DrawRect(0, 0, w, h)

		surface.SetMaterial(star_material)
		for _, star in ipairs(stars) do
			star_update_and_draw(star)
		end
		render.PopRenderTarget()
	end

	surface.SetDrawColor(255, 255, 255, 255)
	surface.SetMaterial(star_canvas_material)
	surface.DrawTexturedRect(0, 0, w, h)

	-- Overlay
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

local function toggle_toolscreen(enabled)
	for _, tool_name in pairs({ "starfall_processor", "starfall_component" }) do
		local stored_tool = weapons.GetStored("gmod_tool").Tool[tool_name]
		stored_tool.DrawToolScreen = enabled and stored_tool.DrawStarfallToolScreen or nil

		local carried = LocalPlayer():GetWeapon("gmod_tool")
		if carried:IsValid() then
			local carried_tool = carried.Tool[tool_name]
			carried_tool.DrawToolScreen = enabled and carried_tool.DrawStarfallToolScreen or nil
		end
	end
end
CreateClientConVar("starfall_toolscreen", "1", true, false, "Enable Starfall custom toolgun screen animation", 0, 1)
cvars.AddChangeCallback("starfall_toolscreen", function(_, _, value)
	toggle_toolscreen(value == "1")
end)
