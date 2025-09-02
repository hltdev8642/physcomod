-- Combined Physics Destruction Mod Options
-- Unified options for PDM, IBSIT, and MBCS features

-- Constants
local fireLimit
SetBool("savegame.mod.combined.dust_DustMeth", false)

function resetSettings()
	-- Main toggles
	SetBool("savegame.mod.combined.Tog_FPSC", false)
	SetBool("savegame.mod.combined.Tog_DUST", false)
	SetBool("savegame.mod.combined.Tog_CRUMBLE", true)
	SetBool("savegame.mod.combined.Tog_RUMBLE", false)
	SetBool("savegame.mod.combined.Tog_FORCE", false)
	SetBool("savegame.mod.combined.Tog_FIRE", false)
	SetBool("savegame.mod.combined.Tog_VIOLENCE", false)
	SetBool("savegame.mod.combined.Tog_DAMSTAT", false)
	SetBool("savegame.mod.combined.Tog_JOINTS", false)
	SetBool("savegame.mod.combined.Tog_IMPACT", true)
	SetBool("savegame.mod.combined.Tog_MASS", true)

	-- FPS Control Section
	SetBool("savegame.mod.combined.FPS_DynLights", true)
	SetBool("savegame.mod.combined.Tog_SDF", true)
	SetBool("savegame.mod.combined.Tog_LFF", false)
	SetBool("savegame.mod.combined.Tog_DBF", false)
	SetInt("savegame.mod.combined.FPS_SDF", 7)
	SetInt("savegame.mod.combined.FPS_LFF", 0)
	SetInt("savegame.mod.combined.FPS_DBF", 0)
	SetInt("savegame.mod.combined.FPS_DBF_size", 35)
	SetBool("savegame.mod.combined.FPS_DBF_FPSB", true)
	SetInt("savegame.mod.combined.FPS_SDF_agg", 3)
	SetInt("savegame.mod.combined.FPS_LFF_agg", 1)
	SetInt("savegame.mod.combined.FPS_DBF_agg", 1)
	SetInt("savegame.mod.combined.FPS_Targ", 30)
	SetInt("savegame.mod.combined.FPS_Agg", 1)
	SetBool("savegame.mod.combined.FPS_GLOB_agg", false)
	SetInt("savegame.mod.combined.FPS_GLOB_aggfac", 0)

	-- Dust Control Section
	SetInt("savegame.mod.combined.dust_amt", 50)
	SetInt("savegame.mod.combined.dust_size", 100)
	SetInt("savegame.mod.combined.dust_sizernd", 50)
	SetInt("savegame.mod.combined.dust_MsBsSz", 50)
	SetInt("savegame.mod.combined.dust_grav", 35)
	SetInt("savegame.mod.combined.dust_drag", 15)
	SetInt("savegame.mod.combined.dust_life", 16)
	SetInt("savegame.mod.combined.dust_lifernd", 10)
	SetInt("savegame.mod.combined.dust_MsBsLf", 20)
	SetInt("savegame.mod.combined.dust_minMass", 3)
	SetInt("savegame.mod.combined.dust_minSpeed", 3)
	SetInt("savegame.mod.combined.dust_startsize", 10)
	SetInt("savegame.mod.combined.dust_fader", 5)

	-- Crumbling Section
	SetBool("savegame.mod.combined.tog_crum", true)
	SetInt("savegame.mod.combined.tog_crum_MODE", 0)
	SetInt("savegame.mod.combined.tog_crum_Source", 0)
	SetInt("savegame.mod.combined.crum_DMGLight", 50)
	SetInt("savegame.mod.combined.crum_DMGMed", 50)
	SetInt("savegame.mod.combined.crum_DMGHeavy", 50)
	SetInt("savegame.mod.combined.crum_spd", 2)
	SetFloat("savegame.mod.combined.crum_spdRND", 0.01)
	SetInt("savegame.mod.combined.crum_dist", 8)
	SetBool("savegame.mod.combined.vehicles_crumble", false)
	SetInt("savegame.mod.combined.crum_HoleControl", 4)
	SetFloat("savegame.mod.combined.crum_BreakTime", 2.5)
	SetInt("savegame.mod.combined.crum_distFromPlyr", 40)
	SetInt("savegame.mod.combined.crum_MinMass", 1)
	SetInt("savegame.mod.combined.crum_MaxMass", 1000)
	SetFloat("savegame.mod.combined.crum_MinSpd", 0.0025)
	SetFloat("savegame.mod.combined.crum_MaxSpd", 8)

	-- Explosions Section
	SetFloat("savegame.mod.combined.xplo_szBase", 0.35)
	SetFloat("savegame.mod.combined.xplo_szRND", 0.15)
	SetFloat("savegame.mod.combined.xplo_szMBV", 0.15)
	SetInt("savegame.mod.combined.xplo_chance", 4)
	SetInt("savegame.mod.combined.xplo_HoleControl", 4)
	SetFloat("savegame.mod.combined.xplo_BreakTime", 2.5)
	SetInt("savegame.mod.combined.xplo_distFromPlyr", 40)
	SetInt("savegame.mod.combined.xplo_MinMass", 1)
	SetInt("savegame.mod.combined.xplo_MaxMass", 10000)
	SetFloat("savegame.mod.combined.xplo_MinSpd", 0.0025)
	SetFloat("savegame.mod.combined.xplo_MaxSpd", 8)
	SetInt("savegame.mod.combined.xplo_SmokeAMT", 2)
	SetInt("savegame.mod.combined.xplo_LifeAMT", 2)
	SetInt("savegame.mod.combined.xplo_Pressure", 4)
	SetInt("savegame.mod.combined.xplo_mode", 1)

	-- IBSIT Settings
	SetInt("savegame.mod.combined.ibsit_momentum", 12)
	SetInt("savegame.mod.combined.ibsit_dust_amt", 50)
	SetInt("savegame.mod.combined.ibsit_wood_size", 100)
	SetInt("savegame.mod.combined.ibsit_stone_size", 75)
	SetInt("savegame.mod.combined.ibsit_metal_size", 50)

	-- IBSIT v2.0 Enhanced Settings
	SetBool("savegame.mod.combined.ibsit_haptic", true)
	SetBool("savegame.mod.combined.ibsit_sounds", true)
	SetBool("savegame.mod.combined.ibsit_particles", true)
	SetBool("savegame.mod.combined.ibsit_vehicle", false)
	SetBool("savegame.mod.combined.ibsit_joint", false)
	SetBool("savegame.mod.combined.ibsit_protection", false)
	SetFloat("savegame.mod.combined.ibsit_volume", 0.7)
	SetInt("savegame.mod.combined.ibsit_particle_quality", 2)
	SetBool("savegame.mod.combined.ibsit_gravity_collapse", true)
	SetFloat("savegame.mod.combined.ibsit_collapse_threshold", 0.3)
	SetFloat("savegame.mod.combined.ibsit_gravity_force", 2.0)
	SetBool("savegame.mod.combined.ibsit_debris_cleanup", true)
	SetFloat("savegame.mod.combined.ibsit_cleanup_delay", 30.0)
	SetBool("savegame.mod.combined.ibsit_fps_optimization", true)
	SetInt("savegame.mod.combined.ibsit_target_fps", 30)
	SetFloat("savegame.mod.combined.ibsit_performance_scale", 1.0)

	-- MBCS Settings
	SetInt("savegame.mod.combined.mbcs_mass", 8)
	SetInt("savegame.mod.combined.mbcs_distance", 4)
	SetInt("savegame.mod.combined.mbcs_dust_amt", 50)
	SetInt("savegame.mod.combined.mbcs_wood_size", 100)
	SetInt("savegame.mod.combined.mbcs_stone_size", 75)
	SetInt("savegame.mod.combined.mbcs_metal_size", 50)

	-- Force and Wind Section
	SetInt("savegame.mod.combined.force_method", 1)
	SetInt("savegame.mod.combined.force_gamecontrols", 0.35)
	SetInt("savegame.mod.combined.force_radius", 0.35)
	SetInt("savegame.mod.combined.force_maxmass", 0.35)
	SetInt("savegame.mod.combined.force_minmass", 0.35)
	SetInt("savegame.mod.combined.force_strength", 0.35)
	SetInt("savegame.mod.combined.force_boost", 0.35)
	SetBool("savegame.mod.combined.force_EdgeFade", true)
	SetBool("savegame.mod.combined.force_START_ON", false)
	SetBool("savegame.mod.combined.force_ENABLE_CONTROLS", false)
	SetBool("savegame.mod.combined.force_Showcross", false)
	SetBool("savegame.mod.combined.force_CONTROL_TIPS", false)
	SetInt("savegame.mod.combined.force_cycle", 0.35)
	SetInt("savegame.mod.combined.force_largemass_accellerator", 0.35)
	SetInt("savegame.mod.combined.force_upforce", 0.35)
	SetInt("savegame.mod.combined.force_effect_on_player", 0)
	SetInt("savegame.mod.combined.force_rotational", 0)
	SetInt("savegame.mod.combined.force_warmup", 1)

	-- Fire Section
	SetInt("savegame.mod.combined.fyr_mode", 1)
	SetInt("savegame.mod.combined.fyr_maxrad", 15)
	SetInt("savegame.mod.combined.fyr_minrad", 4)
	SetInt("savegame.mod.combined.fyr_chance", 1)
	SetInt("savegame.mod.combined.fyr_maxmass", 4000)
	SetInt("savegame.mod.combined.fyr_minmass", 2)

	-- Violence Section
	SetInt("savegame.mod.combined.VIOL_mode", 1)
	SetInt("savegame.mod.combined.VIOL_Chance", 1)
	SetInt("savegame.mod.combined.VIOL_mover", 2)
	SetInt("savegame.mod.combined.VIOL_turnr", 2)
	SetInt("savegame.mod.combined.VIOL_minmass", 5)
	SetInt("savegame.mod.combined.VIOL_maxmass", 2000)
	SetInt("savegame.mod.combined.VIOL_maxdist", 50)

	-- Joint Breakage Section
	SetInt("savegame.mod.combined.JOINT_Source", 1)
	SetInt("savegame.mod.combined.JOINT_Range", 5)
	SetInt("savegame.mod.combined.JOINT_Chance", 5)

	-- Damage Statistics Section
	SetInt("savegame.mod.combined.DAMSTAT_Currency", 1)
end

-- Dedicated IBSIT v2 Options Page
function DrawPage7()
	UiFont("regular.ttf", 38)
	UiPush()
	SetPos(-0.5,-0.55)
	UiText("IBSIT v2.0 Settings")
	UiPop()

	-- Use two-column layout; columns will adapt because positions are relative to UiWidth/UiHeight via SetPos
	local leftX = -0.7
	local rightX = -0.05
	local y = -0.40
	local rowH = 0.07

	UiFont("bold.ttf", 18)

	-- Left column (toggles & core sliders)
	UiPush(); SetPos(leftX, y); drawButton("Enable IBSIT Haptics", "savegame.mod.combined.ibsit_haptic"); UiPop()
	UiPush(); SetPos(leftX, y + rowH); drawButton("Enable IBSIT Sounds", "savegame.mod.combined.ibsit_sounds"); UiPop()
	UiPush(); SetPos(leftX, y + rowH*2); drawButton("Enable IBSIT Particles", "savegame.mod.combined.ibsit_particles"); UiPop()
	UiPush(); SetPos(leftX, y + rowH*3); drawButton("Vehicle Protection", "savegame.mod.combined.ibsit_vehicle"); UiPop()
	UiPush(); SetPos(leftX, y + rowH*4); drawButton("Joint Protection", "savegame.mod.combined.ibsit_joint"); UiPop()
	UiPush(); SetPos(leftX, y + rowH*5); drawButton("General Protection", "savegame.mod.combined.ibsit_protection"); UiPop()

	UiPush(); SetPos(leftX, y + rowH*6); UiText("IBSIT Volume"); UiPop()
	UiPush(); SetPos(leftX + 0.12, y + rowH*6); local vvol = optionsSliderFloat("savegame.mod.combined.ibsit_volume", 0.7, 0.0, 1.0, 0.01); UiPop()
	UiPush(); SetPos(leftX + 0.36, y + rowH*6); UiText(string.format("%.2f", vvol)); UiPop()

	UiPush(); SetPos(leftX, y + rowH*7); UiText("Particle Quality"); UiPop()
	UiPush(); SetPos(leftX + 0.22, y + rowH*7); local pqual = optionsSlider("savegame.mod.combined.ibsit_particle_quality", 2, 0, 3); UiPop()
	UiPush(); SetPos(leftX + 0.42, y + rowH*7); UiText(pqual); UiPop()

	-- Right column (collapse, cleanup, fps optimization)
	UiPush(); SetPos(rightX, y); drawButton("Gravity Collapse", "savegame.mod.combined.ibsit_gravity_collapse"); UiPop()
	if GetBool("savegame.mod.combined.ibsit_gravity_collapse") then
		UiPush(); SetPos(rightX, y + rowH); UiText("Collapse Threshold"); UiPop()
		UiPush(); SetPos(rightX + 0.18, y + rowH); local cth = optionsSliderFloat("savegame.mod.combined.ibsit_collapse_threshold", 0.3, 0.0, 1.0, 0.01); UiPop()
		UiPush(); SetPos(rightX + 0.40, y + rowH); UiText(string.format("%.2f", cth)); UiPop()

		UiPush(); SetPos(rightX, y + rowH*2); UiText("Gravity Force"); UiPop()
		UiPush(); SetPos(rightX + 0.24, y + rowH*2); local gforce = optionsSliderFloat("savegame.mod.combined.ibsit_gravity_force", 2.0, 0.0, 10.0, 0.1); UiPop()
		UiPush(); SetPos(rightX + 0.48, y + rowH*2); UiText(string.format("%.2f", gforce)); UiPop()
	end

	UiPush(); SetPos(rightX, y + rowH*3); drawButton("Debris Cleanup", "savegame.mod.combined.ibsit_debris_cleanup"); UiPop()
	if GetBool("savegame.mod.combined.ibsit_debris_cleanup") then
		UiPush(); SetPos(rightX, y + rowH*4); UiText("Cleanup Delay (s)"); UiPop()
		UiPush(); SetPos(rightX + 0.28, y + rowH*4); local cd = optionsSliderFloat("savegame.mod.combined.ibsit_cleanup_delay", 30.0, 0.0, 300.0, 1.0); UiPop()
		UiPush(); SetPos(rightX + 0.56, y + rowH*4); UiText(string.format("%.0f", cd)); UiPop()
	end

	UiPush(); SetPos(rightX, y + rowH*5); drawButton("FPS Optimization", "savegame.mod.combined.ibsit_fps_optimization"); UiPop()
	if GetBool("savegame.mod.combined.ibsit_fps_optimization") then
		UiPush(); SetPos(rightX, y + rowH*6); UiText("Target FPS"); UiPop()
		UiPush(); SetPos(rightX + 0.18, y + rowH*6); local tf = optionsSlider("savegame.mod.combined.ibsit_target_fps", 30, 15, 144, 1); UiPop()
		UiPush(); SetPos(rightX + 0.36, y + rowH*6); UiText(tf); UiPop()

		UiPush(); SetPos(rightX, y + rowH*7); UiText("Performance Scale"); UiPop()
		UiPush(); SetPos(rightX + 0.36, y + rowH*7); local ps = optionsSliderFloat("savegame.mod.combined.ibsit_performance_scale", 1.0, 0.1, 2.0, 0.01); UiPop()
		UiPush(); SetPos(rightX + 0.66, y + rowH*7); UiText(string.format("%.2f", ps)); UiPop()
	end

	-- Small screen protection: draw hint if UiWidth is narrow
	if UiWidth() < 1200 then
		UiFont("regular.ttf", 16)
		UiColor(1,0.6,0.15)
		UiPush(); SetPos(0, 0.8); UiText("Tip: If controls overlap, increase your game resolution or use UI scaling in game settings."); UiPop()
		UiColor(1,1,1)
	end
end

function optionsSlider(key, default, min, max, incri)
	local steps = incri or 1
	local value = (GetInt(key) - min) / (max - min)
	local width = 100
	UiTranslate(50, 0)
	UiRect(width, 3)
	UiTranslate(-50, 0)
	value = UiSlider("ui/common/dot.png", "x", value*width, 0, width)/width
	value = math.floor((value*(max-min)+min)/steps+0.5)*steps
	SetInt(key, value)
	return value
end

function optionsSliderLarge(key, default, min, max, incri)
	local steps = incri or 1
	local value = (GetInt(key) - min) / (max - min)
	local width = 200
	UiTranslate(100, 0)
	UiRect(width, 3)
	UiTranslate(-100, 0)
	value = UiSlider("ui/common/dot.png", "x", value*width, 0, width)/width
	value = math.floor((value*(max-min)+min)/steps+0.5)*steps
	SetInt(key, value)
	return value
end

function optionsSliderFloat(key, default, min, max, step)
	local steps = step or 0.01
	local v = (GetFloat and GetFloat(key) or GetInt(key)) or default
	-- normalize
	local value = (v - min) / (max - min)
	local width = 200
	UiTranslate(100, 0)
	UiRect(width, 3)
	UiTranslate(-100, 0)
	value = UiSlider("ui/common/dot.png", "x", value*width, 0, width)/width
	value = math.floor((value*(max-min)/steps)+0.5)*steps + min
	SetFloat(key, value)
	return value
end

function optionsSliderYuge(key, default, min, max, incri)
	local steps = incri or 1
	local value = (GetInt(key) - min) / (max - min)
	local width = 500
	UiTranslate(250, 0)
	UiRect(width, 3)
	UiTranslate(-250, 0)
	value = UiSlider("ui/common/dot.png", "x", value*width, 0, width)/width
	value = math.floor((value*(max-min)+min)/steps+0.5)*steps
	SetInt(key, value)
	return value
end

function drawButton(title, key, value)
	if UiTextButton(title .. " (" .. (GetBool(key) and "enabled" or "disabled") .. ")", 340, 32) then
		SetBool(key, not GetBool(key))
	end
	if GetBool(key) then
		UiColor(0.5, 1, 0.5)
		UiTranslate(-145, 0)
		UiImage("ui/menu/mod-active.png")
	else
		UiTranslate(-145, 0)
		UiImage("ui/menu/mod-inactive.png")
	end
end

function init()
	if(GetBool("savegame.mod.performance.launch")) then
		fireLimit = GetInt("savegame.mod.performance.fire_limit")
	end
	SetBool("savegame.mod.combined.launch", false)
end

function page_selector()
	UiFont("regular.ttf", 34)
	UiButtonImageBox("ui/common/box-outline-6.png", 6, 6)
	UiPush()
	SetPos(-0.85,-0.7)
	local col=0.5+(math.sin(GetTime()*4)/2)
	if GetInt("savegame.mod.combined.options_page")==1 then
		UiColor(col,col*2,col)
		if UiTextButton(">Main<", 200, 50) then
			SetInt("savegame.mod.combined.options_page", 1)
		end
		else
		if UiTextButton("Main", 200, 50) then
			SetInt("savegame.mod.combined.options_page", 1)
		end
		UiColor(1,1,1)
	end
	UiPop()
	UiPush()
	SetPos(-0.55,-0.7)
	if GetInt("savegame.mod.combined.options_page")==2 then
		UiColor(col,col*2,col)
		if UiTextButton(">FPS&Dust<", 200, 50) then
			SetInt("savegame.mod.combined.options_page", 2)
		end
		else
		if UiTextButton("FPS&Dust", 200, 50) then
			SetInt("savegame.mod.combined.options_page", 2)
		end
		UiColor(1,1,1)
	end
	UiPop()
	UiPush()
	SetPos(-0.25,-0.7)
	if GetInt("savegame.mod.combined.options_page")==3 then
		UiColor(col,col*2,col)
		if UiTextButton(">Crumble<", 200, 50) then
			SetInt("savegame.mod.combined.options_page", 3)
		end
		else
		if UiTextButton("Crumble", 200, 50) then
			SetInt("savegame.mod.combined.options_page", 3)
		end
		UiColor(1,1,1)
	end
	UiPop()
	UiPush()
	SetPos(0.05,-0.7)
	if GetInt("savegame.mod.combined.options_page")==4 then
		UiColor(col,col*2,col)
		if UiTextButton(">Explosions<", 200, 50) then
			SetInt("savegame.mod.combined.options_page", 4)
		end
		else
		if UiTextButton("Explosions", 200, 50) then
			SetInt("savegame.mod.combined.options_page", 4)
		end
		UiColor(1,1,1)
	end
	UiPop()
	UiPush()
	SetPos(0.35,-0.7)
	if GetInt("savegame.mod.combined.options_page")==5 then
		UiColor(col,col*2,col)
		if UiTextButton(">Force&Fire<", 200, 50) then
			SetInt("savegame.mod.combined.options_page", 5)
		end
		else
		if UiTextButton("Force&Fire", 200, 50) then
			SetInt("savegame.mod.combined.options_page", 5)
		end
		UiColor(1,1,1)
	end
	UiPop()
	UiPush()
	SetPos(0.65,-0.7)
	if GetInt("savegame.mod.combined.options_page")==6 then
		UiColor(col,col*2,col)
		if UiTextButton(">Advanced<", 200, 50) then
			SetInt("savegame.mod.combined.options_page", 6)
		end
		else
		if UiTextButton("Advanced", 200, 50) then
			SetInt("savegame.mod.combined.options_page", 6)
		end
		UiColor(1,1,1)
	end
	UiPop()
	UiPush()
	SetPos(0.95,-0.7)
	if GetInt("savegame.mod.combined.options_page")==7 then
		UiColor(col,col*2,col)
		if UiTextButton(">IBSIT v2<", 160, 50) then
			SetInt("savegame.mod.combined.options_page", 7)
		end
		else
		if UiTextButton("IBSIT v2", 160, 50) then
			SetInt("savegame.mod.combined.options_page", 7)
		end
		UiColor(1,1,1)
	end
	UiPop()
end

function SetPos(x,y)
	local cx = UiWidth() / 2
	local cy = UiHeight() / 2
	UiTranslate(cx + cx * x, cy + cy * y)
end

function Rectangle(sx,sy,ex,ey)
	local cx = UiWidth() / 2
	local cy = UiHeight() / 2
	UiTranslate(cx + cx * sx, cy + cy * sy)
	UiRect((cx + cx * ex)-(cx + cx * sx),(cy + cy * ey)-(cy + cy * sy))
end

function draw()
	if math.random()>0.8 then
		DebugPrint("")
	end

	UiColor(1,1,1)
	UiAlign("center middle")
	UiFont("bold.ttf", 48)
	UiPush()
	SetPos(0,-0.9)
	UiText("Combined Physics Destruction Mod")
	UiPop()

	UiFont("regular.ttf", 24)
	UiPush()
	SetPos(0,-0.8)
	UiText("Unified mod combining PDM, IBSIT, and MBCS features")
	UiPop()

	UiButtonImageBox("ui/common/box-outline-6.png", 6, 6)
	UiColor(0.35+(math.random()*0.5),0.35+(math.random()*0.5),0.35+(math.random()*0.5))
	UiPush()
	SetPos(-0.5,0.88)
	if UiTextButton("Close", 80, 40) or InputPressed("esc") then
		SetInt("options.gfx.renderscale", math.max(GetInt("savegame.mod.performance.renderscale"), 1))
		Menu()
	end
	UiPop()
	UiPush()
	SetPos(0.5,0.88)
	if UiTextButton("Reset", 80, 40) then
		resetSettings()
	end
	UiPop()
	UiFont("regular.ttf", 18)
	UiPush()
	SetPos(0.75,0.88)
	UiText("<< WARNING, RESETS ALL")
	UiPop()

	UiColor(1,1,1)
	UiPush()
	SetPos(0,0.88)
	UiText("PRESS '-' TO DELETE ALL DEBRIS INSTANTLY")
	UiPop()

	page_selector()
	UiFont("regular.ttf", 24)

	if GetInt("savegame.mod.combined.options_page")==1 then
		DrawPage1()
	elseif GetInt("savegame.mod.combined.options_page")==2 then
		DrawPage2()
	elseif GetInt("savegame.mod.combined.options_page")==3 then
		DrawPage3()
	elseif GetInt("savegame.mod.combined.options_page")==4 then
		DrawPage4()
	elseif GetInt("savegame.mod.combined.options_page")==5 then
		DrawPage5()
	elseif GetInt("savegame.mod.combined.options_page")==6 then
		DrawPage6()
	elseif GetInt("savegame.mod.combined.options_page")==7 then
		DrawPage7()
	end
end

function DrawPage1()
	UiFont("regular.ttf", 38)
	UiPush()
	SetPos(-0.5,-0.55)
	UiText("MAIN FEATURE TOGGLES")
	UiPop()

	UiFont("bold.ttf", 20)
	UiButtonImageBox("ui/common/box-outline-6.png", 6, 6)

	-- Left Column
	UiPush()
	SetPos(-0.7,-0.45)
	drawButton("FPS Control", "savegame.mod.combined.Tog_FPSC")
	UiPop()

	UiPush()
	SetPos(-0.7,-0.35)
	drawButton("Dust/Smoke", "savegame.mod.combined.Tog_DUST")
	UiPop()

	UiPush()
	SetPos(-0.7,-0.25)
	drawButton("Crumbling", "savegame.mod.combined.Tog_CRUMBLE")
	UiPop()

	UiPush()
	SetPos(-0.7,-0.15)
	drawButton("Explosions", "savegame.mod.combined.Tog_RUMBLE")
	UiPop()

	UiPush()
	SetPos(-0.7,-0.05)
	drawButton("Force/Wind", "savegame.mod.combined.Tog_FORCE")
	UiPop()

	-- Right Column
	UiPush()
	SetPos(0.3,-0.45)
	drawButton("Fire Effects", "savegame.mod.combined.Tog_FIRE")
	UiPop()

	UiPush()
	SetPos(0.3,-0.35)
	drawButton("Violence", "savegame.mod.combined.Tog_VIOLENCE")
	UiPop()

	UiPush()
	SetPos(0.3,-0.25)
	drawButton("Impact Detection", "savegame.mod.combined.Tog_IMPACT")
	UiPop()

	UiPush()
	SetPos(0.3,-0.15)
	drawButton("Mass-Based Damage", "savegame.mod.combined.Tog_MASS")
	UiPop()

	UiPush()
	SetPos(0.3,-0.05)
	drawButton("Damage Statistics", "savegame.mod.combined.Tog_DAMSTAT")
	UiPop()

	UiColor(0.15,0.65,1)
	UiFont("regular.ttf", 18)
	UiPush()
	SetPos(-0.5,0.1)
	UiText("Enable/disable major mod features. FPS Control helps maintain performance.")
	UiPop()
	UiPush()
	SetPos(-0.5,0.15)
	UiText("Impact Detection (IBSIT) and Mass-Based Damage (MBCS) provide different destruction styles.")
	UiPop()
end

function DrawPage2()
	UiFont("regular.ttf", 38)
	UiPush()
	SetPos(-0.5,-0.55)
	UiText("FPS CONTROL & DUST SETTINGS")
	UiPop()

	UiColor(0.65,0.65,1)
	UiPush()
	SetPos(0,0.1)
	UiRect(2,600)
	UiPop()

	-- FPS Controls (Left Side)
	UiFont("bold.ttf", 20)
	UiButtonImageBox("ui/common/box-outline-6.png", 6, 6)
	UiPush()
	SetPos(-0.7,-0.45)
	drawButton("Enable FPS Control?", "savegame.mod.combined.Tog_FPSC")
	UiPop()

	if GetBool("savegame.mod.combined.Tog_FPSC") then
		UiPush()
		SetPos(-0.7,-0.37)
		drawButton("NO Dynamic Lights", "savegame.mod.combined.FPS_DynLights")
		UiPop()

		UiPush()
		SetPos(-0.7,-0.26)
		drawButton("Small Debris Filter", "savegame.mod.combined.Tog_SDF")
		UiPop()

		UiPush()
		SetPos(-0.7,-0.11)
		drawButton("Low FPS Filter", "savegame.mod.combined.Tog_LFF")
		UiPop()

		UiPush()
		SetPos(-0.7,0.04)
		drawButton("Distance Based Filter", "savegame.mod.combined.Tog_DBF")
		UiPop()

		UiPush()
		SetPos(-0.7,0.19)
		drawButton("DBF Framerate Linked", "savegame.mod.combined.FPS_DBF_FPSB")
		UiPop()

		UiPush()
		SetPos(-0.7,0.39)
		drawButton("Global Aggression", "savegame.mod.combined.FPS_GLOB_agg")
		UiPop()

		UiFont("regular.ttf", 24)
		UiColor(1,0.5,0.5)
		UiPush()
		SetPos(0,0.8)
		UiText("Higher aggression = faster debris removal but more noticeable")
		UiPop()

		UiFont("bold.ttf", 16)
		UiColor(1,1,1)
		if GetBool("savegame.mod.combined.Tog_SDF") then
			UiPush()
			SetPos(-0.48,-0.26)
			UiText("Filter Size:")
			UiPop()
			UiPush()
			SetPos(-0.43,-0.26)
			local value = optionsSlider("savegame.mod.combined.FPS_SDF", 10, 0, 100)
			UiPop()
			UiPush()
			SetPos(-0.30,-0.26)
			UiText(value)
			UiPop()
		end

		if GetBool("savegame.mod.combined.Tog_DBF") then
			UiPush()
			SetPos(-0.48,0.04)
			UiText("Distance:")
			UiPop()
			UiPush()
			SetPos(-0.43,0.04)
			local value = optionsSlider("savegame.mod.combined.FPS_DBF", 10, 0, 300,5)
			UiPop()
			UiPush()
			SetPos(-0.30,0.04)
			UiText(value)
			UiPop()
		end

		UiPush()
		SetPos(-0.8,0.25)
		UiText("FPS TARGET:")
		UiPop()
		UiPush()
		SetPos(-0.7,0.25)
		local value = optionsSlider("savegame.mod.combined.FPS_Targ", 30, 30, 144,5)
		UiPop()
		UiPush()
		SetPos(-0.55,0.25)
		if GetInt("savegame.mod.combined.FPS_Targ")<35 then
			UiText("Off")
		else
			UiText(value)
		end
		UiPop()
	end

	-- Dust Controls (Right Side)
	UiFont("bold.ttf", 20)
	UiColor(1,1,1)
	UiButtonImageBox("ui/common/box-outline-6.png", 6, 6)
	UiPush()
	SetPos(0.25,-0.45)
	drawButton("Enable Dust/Smoke?", "savegame.mod.combined.Tog_DUST")
	UiPop()

	if GetBool("savegame.mod.combined.Tog_DUST") then
		UiPush()
		SetPos(0.15,-0.30)
		UiText("Base Dust amount:")
		UiPop()
		UiPush()
		SetPos(0.25,-0.30)
		local value = optionsSlider("savegame.mod.combined.dust_amt", 0, 1, 200)
		UiPop()
		UiPush()
		SetPos(0.40,-0.30)
		UiText(value)
		UiPop()

		UiPush()
		SetPos(0.15,-0.20)
		UiText("Dust Size:")
		UiPop()
		UiPush()
		SetPos(0.25,-0.20)
		local value = optionsSlider("savegame.mod.combined.dust_size", 1, 1, 20)
		UiPop()
		UiPush()
		SetPos(0.40,-0.20)
		UiText(value*0.25)
		UiPop()

		UiPush()
		SetPos(0.15,-0.12)
		UiText("Dust Life:")
		UiPop()
		UiPush()
		SetPos(0.25,-0.12)
		local value = optionsSlider("savegame.mod.combined.dust_life", 1, 1, 60)
		UiPop()
		UiPush()
		SetPos(0.40,-0.12)
		UiText(value*0.5)
		UiPop()
		UiPush()
		SetPos(0.455,-0.12)
		UiText("Seconds")
		UiPop()
	end
end

function DrawPage3()
	UiFont("regular.ttf", 38)
	UiPush()
	SetPos(-0.5,-0.55)
	UiText("CRUMBLING SETTINGS")
	UiPop()

	UiFont("bold.ttf", 20)
	UiButtonImageBox("ui/common/box-outline-6.png", 6, 6)
	UiPush()
	SetPos(-0.7,-0.45)
	drawButton("Enable Crumbling?", "savegame.mod.combined.Tog_CRUMBLE")
	UiPop()

	if GetBool("savegame.mod.combined.Tog_CRUMBLE") then
		UiPush()
		SetPos(-0.8,-0.35)
		UiText("Light Material Damage:")
		UiPop()
		UiPush()
		SetPos(-0.61,-0.35)
		local value = optionsSlider("savegame.mod.combined.crum_DMGLight", 10, 0, 200,5)
		UiPop()
		UiPush()
		SetPos(-0.46,-0.35)
		UiText(value)
		UiPop()

		UiPush()
		SetPos(-0.8,-0.25)
		UiText("Medium Material Damage:")
		UiPop()
		UiPush()
		SetPos(-0.61,-0.25)
		local value = optionsSlider("savegame.mod.combined.crum_DMGMed", 10, 0, 200,5)
		UiPop()
		UiPush()
		SetPos(-0.46,-0.25)
		UiText(value)
		UiPop()

		UiPush()
		SetPos(-0.8,-0.15)
		UiText("Heavy Material Damage:")
		UiPop()
		UiPush()
		SetPos(-0.61,-0.15)
		local value = optionsSlider("savegame.mod.combined.crum_DMGHeavy", 10, 0, 200,5)
		UiPop()
		UiPush()
		SetPos(-0.46,-0.15)
		UiText(value)
		UiPop()

		UiPush()
		SetPos(-0.30,-0.15)
		UiText("Crumble Size:")
		UiPop()
		UiPush()
		SetPos(-0.20,-0.15)
		local value = optionsSlider("savegame.mod.combined.crum_dist", 1, 1,10)
		UiPop()
		UiPush()
		SetPos(-0.07,-0.15)
		UiText(value)
		UiPop()

		UiPush()
		SetPos(-0.8,0.10)
		UiText("HOLE CONTROL:")
		UiPop()
		UiPush()
		SetPos(-0.66,0.10)
		local value = optionsSlider("savegame.mod.combined.crum_HoleControl", 10, 0, 10)
		UiPop()
		UiPush()
		SetPos(-0.52,0.10)
		UiText(value)
		UiPop()

		UiPush()
		SetPos(-0.8,0.20)
		UiText("Max Distance From Player:")
		UiPop()
		UiPush()
		SetPos(-0.66,0.20)
		local value = optionsSlider("savegame.mod.combined.crum_distFromPlyr", 2.5, 5, 60)
		UiPop()
		UiPush()
		SetPos(-0.52,0.20)
		UiText(value)
		UiPop()

		UiPush()
		SetPos(-0.8,0.35)
		UiText("Minimum Mass:")
		UiPop()
		UiPush()
		SetPos(-0.66,0.35)
		local value = optionsSlider("savegame.mod.combined.crum_MinMass", 1, 0, 80,1)
		UiPop()
		UiPush()
		SetPos(-0.52,0.35)
		UiText(value/4)
		UiPop()

		UiPush()
		SetPos(-0.8,0.45)
		UiText("Minimum Speed:")
		UiPop()
		UiPush()
		SetPos(-0.66,0.45)
		local value = optionsSlider("savegame.mod.combined.crum_MinSpd", 1, 0, 150,2)
		UiPop()
		UiPush()
		SetPos(-0.52,0.45)
		UiText(value/10)
		UiPop()

		UiColor(0.15,0.65,1)
		UiPush()
		SetPos(-0.70,-0.05)
		UiText("Higher damage values = more destructive crumbling")
		UiPop()
		UiPush()
		SetPos(-0.70,0.0)
		UiText("Hole control prevents too many holes from forming")
		UiPop()
	end

	-- IBSIT Settings (Right Side)
	UiFont("bold.ttf", 20)
	UiColor(1,1,1)
	UiButtonImageBox("ui/common/box-outline-6.png", 6, 6)
	UiPush()
	SetPos(0.25,-0.45)
	drawButton("Impact Detection", "savegame.mod.combined.Tog_IMPACT")
	UiPop()

	if GetBool("savegame.mod.combined.Tog_IMPACT") then
		UiPush()
		SetPos(0.15,-0.30)
		UiText("Momentum Threshold:")
		UiPop()
		UiPush()
		SetPos(0.25,-0.30)
		local value = optionsSlider("savegame.mod.combined.ibsit_momentum", 1, 0, 20)
		UiPop()
		UiPush()
		SetPos(0.40,-0.30)
		UiText(value)
		UiPop()

		UiPush()
		SetPos(0.15,-0.20)
		UiText("Wood Damage:")
		UiPop()
		UiPush()
		SetPos(0.25,-0.20)
		local value = optionsSlider("savegame.mod.combined.ibsit_wood_size", 1, 1, 200)
		UiPop()
		UiPush()
		SetPos(0.40,-0.20)
		UiText(value/100)
		UiPop()

		UiPush()
		SetPos(0.15,-0.10)
		UiText("Stone Damage:")
		UiPop()
		UiPush()
		SetPos(0.25,-0.10)
		local value = optionsSlider("savegame.mod.combined.ibsit_stone_size", 1, 1, 200)
		UiPop()
		UiPush()
		SetPos(0.40,-0.10)
		UiText(value/100)
		UiPop()

		UiColor(0.15,0.65,1)
		UiPush()
		SetPos(0.2,0.1)
		UiText("Impact-based destruction with momentum calculations")
		UiPop()
	end


	-- IBSIT v2 moved to its own page (IBSIT v2). Use the IBSIT v2 page button at the top-right to configure advanced IBSIT options.
end

function DrawPage4()
	UiFont("regular.ttf", 38)
	UiPush()
	SetPos(-0.5,-0.55)
	UiText("EXPLOSIONS SETTINGS")
	UiPop()

	UiFont("bold.ttf", 20)
	UiButtonImageBox("ui/common/box-outline-6.png", 6, 6)
	UiPush()
	SetPos(-0.7,-0.45)
	drawButton("Enable Explosions?", "savegame.mod.combined.Tog_RUMBLE")
	UiPop()

	if GetBool("savegame.mod.combined.Tog_RUMBLE") then
		UiPush()
		SetPos(-0.8,-0.35)
		UiText("Explosion Base Size:")
		UiPop()
		UiPush()
		SetPos(-0.61,-0.35)
		local value = optionsSlider("savegame.mod.combined.xplo_szBase", 0, 1, 40)
		UiPop()
		UiPush()
		SetPos(-0.46,-0.35)
		UiText(value/4)
		UiPop()

		UiPush()
		SetPos(-0.8,-0.25)
		UiText("Explosion Chance:")
		UiPop()
		UiPush()
		SetPos(-0.61,-0.25)
		local value = optionsSlider("savegame.mod.combined.xplo_chance", 0, 1, 100,1)
		UiPop()
		UiPush()
		SetPos(-0.46,-0.25)
		UiText(value)
		UiPop()

		UiPush()
		SetPos(-0.8,-0.15)
		UiText("Max Distance:")
		UiPop()
		UiPush()
		SetPos(-0.61,-0.15)
		local value = optionsSlider("savegame.mod.combined.xplo_distFromPlyr", 0, 1, 50)
		UiPop()
		UiPush()
		SetPos(-0.46,-0.15)
		UiText(value)
		UiPop()

		UiPush()
		SetPos(-0.8,-0.05)
		UiText("Min Mass:")
		UiPop()
		UiPush()
		SetPos(-0.61,-0.05)
		local value = optionsSlider("savegame.mod.combined.xplo_MinMass", 1, 0, 500, 5 )
		UiPop()
		UiPush()
		SetPos(-0.46,-0.05)
		UiText(value)
		UiPop()

		UiPush()
		SetPos(-0.8,0.05)
		UiText("Max Mass:")
		UiPop()
		UiPush()
		SetPos(-0.61,0.05)
		local value = optionsSlider("savegame.mod.combined.xplo_MaxMass", 1, 20, 8000)
		UiPop()
		UiPush()
		SetPos(-0.46,0.05)
		UiText(value)
		UiPop()

		UiColor(0.15,0.65,1)
		UiPush()
		SetPos(-0.5,0.2)
		UiText("Explosion settings affect all explosions in the game")
		UiPop()
	end

	-- MBCS Settings (Right Side)
	UiFont("bold.ttf", 20)
	UiColor(1,1,1)
	UiButtonImageBox("ui/common/box-outline-6.png", 6, 6)
	UiPush()
	SetPos(0.25,-0.45)
	drawButton("Mass-Based Damage", "savegame.mod.combined.Tog_MASS")
	UiPop()

	if GetBool("savegame.mod.combined.Tog_MASS") then
		UiPush()
		SetPos(0.15,-0.30)
		UiText("Mass Threshold:")
		UiPop()
		UiPush()
		SetPos(0.25,-0.30)
		local value = optionsSlider("savegame.mod.combined.mbcs_mass", 1, 0, 20)
		UiPop()
		UiPush()
		SetPos(0.40,-0.30)
		UiText(value)
		UiPop()

		UiPush()
		SetPos(0.15,-0.20)
		UiText("Fall Distance:")
		UiPop()
		UiPush()
		SetPos(0.25,-0.20)
		local value = optionsSlider("savegame.mod.combined.mbcs_distance", 1, 0, 16)
		UiPop()
		UiPush()
		SetPos(0.40,-0.20)
		UiText(value)
		UiPop()

		UiPush()
		SetPos(0.15,-0.10)
		UiText("Wood Damage:")
		UiPop()
		UiPush()
		SetPos(0.25,-0.10)
		local value = optionsSlider("savegame.mod.combined.mbcs_wood_size", 1, 1, 200)
		UiPop()
		UiPush()
		SetPos(0.40,-0.10)
		UiText(value/100)
		UiPop()

		UiColor(0.15,0.65,1)
		UiPush()
		SetPos(0.2,0.1)
		UiText("Mass-based collateral damage system")
		UiPop()
	end
end

function DrawPage5()
	UiFont("regular.ttf", 38)
	UiPush()
	SetPos(-0.5,-0.55)
	UiText("FORCE & FIRE SETTINGS")
	UiPop()

	-- Force Settings (Left Side)
	UiFont("bold.ttf", 20)
	UiButtonImageBox("ui/common/box-outline-6.png", 6, 6)
	UiPush()
	SetPos(-0.7,-0.45)
	drawButton("Enable Force?", "savegame.mod.combined.Tog_FORCE")
	UiPop()

	if GetBool("savegame.mod.combined.Tog_FORCE") then
		UiPush()
		SetPos(-0.8,-0.35)
		UiText("Force Strength:")
		UiPop()
		UiPush()
		SetPos(-0.61,-0.35)
		local value = optionsSliderYuge("savegame.mod.combined.force_strength", 17, -120, 120,2)
		UiPop()
		UiPush()
		SetPos(-0.46,-0.35)
		UiText(value/50)
		UiPop()

		UiPush()
		SetPos(-0.8,-0.25)
		UiText("Force Radius:")
		UiPop()
		UiPush()
		SetPos(-0.61,-0.25)
		local value = optionsSlider("savegame.mod.combined.force_radius", 1, 2, 60)
		UiPop()
		UiPush()
		SetPos(-0.46,-0.25)
		UiText(value)
		UiPop()

		UiPush()
		SetPos(-0.8,-0.15)
		UiText("Min Mass:")
		UiPop()
		UiPush()
		SetPos(-0.61,-0.15)
		local value = optionsSlider("savegame.mod.combined.force_minmass", 0, 0, 500,5)
		UiPop()
		UiPush()
		SetPos(-0.46,-0.15)
		UiText(value)
		UiPop()

		UiPush()
		SetPos(-0.8,-0.05)
		UiText("Max Mass:")
		UiPop()
		UiPush()
		SetPos(-0.61,-0.05)
		local value = optionsSlider("savegame.mod.combined.force_maxmass", 1, 10, 25000, 50)
		UiPop()
		UiPush()
		SetPos(-0.46,-0.05)
		UiText(value)
		UiPop()

		UiColor(0.15,0.65,1)
		UiPush()
		SetPos(-0.5,0.1)
		UiText("Force affects physics objects in the specified radius")
		UiPop()
	end

	-- Fire Settings (Right Side)
	UiFont("bold.ttf", 20)
	UiColor(1,1,1)
	UiButtonImageBox("ui/common/box-outline-6.png", 6, 6)
	UiPush()
	SetPos(0.25,-0.45)
	drawButton("Enable Fire?", "savegame.mod.combined.Tog_FIRE")
	UiPop()

	if GetBool("savegame.mod.combined.Tog_FIRE") then
		UiPush()
		SetPos(0.15,-0.30)
		UiText("Fire Chance:")
		UiPop()
		UiPush()
		SetPos(0.25,-0.30)
		local value = optionsSlider("savegame.mod.combined.fyr_chance", 1, 1, 100, 2)
		UiPop()
		UiPush()
		SetPos(0.40,-0.30)
		UiText(value)
		UiPop()
		UiPush()
		SetPos(0.43,-0.30)
		UiText("%")
		UiPop()

		UiPush()
		SetPos(0.15,-0.20)
		UiText("Min Radius:")
		UiPop()
		UiPush()
		SetPos(0.25,-0.20)
		local value = optionsSlider("savegame.mod.combined.fyr_minrad", 2, 1, 15)
		UiPop()
		UiPush()
		SetPos(0.40,-0.20)
		UiText(value)
		UiPop()

		UiPush()
		SetPos(0.15,-0.10)
		UiText("Max Radius:")
		UiPop()
		UiPush()
		SetPos(0.25,-0.10)
		local value = optionsSlider("savegame.mod.combined.fyr_maxrad", 10, 6, 70)
		UiPop()
		UiPush()
		SetPos(0.40,-0.10)
		UiText(value)
		UiPop()

		UiColor(0.15,0.65,1)
		UiPush()
		SetPos(0.2,0.1)
		UiText("Fire spreads from broken debris within radius")
		UiPop()
	end
end

function DrawPage6()
	UiFont("regular.ttf", 38)
	UiPush()
	SetPos(-0.5,-0.55)
	UiText("ADVANCED SETTINGS")
	UiPop()

	-- Violence Settings (Left Side)
	UiFont("bold.ttf", 20)
	UiButtonImageBox("ui/common/box-outline-6.png", 6, 6)
	UiPush()
	SetPos(-0.7,-0.45)
	drawButton("Enable Violence?", "savegame.mod.combined.Tog_VIOLENCE")
	UiPop()

	if GetBool("savegame.mod.combined.Tog_VIOLENCE") then
		UiPush()
		SetPos(-0.8,-0.35)
		UiText("Violence Chance:")
		UiPop()
		UiPush()
		SetPos(-0.61,-0.35)
		local value = optionsSlider("savegame.mod.combined.VIOL_Chance", 1, 1, 200)
		UiPop()
		UiPush()
		SetPos(-0.46,-0.35)
		UiText(value/10)
		UiPop()

		UiPush()
		SetPos(-0.8,-0.25)
		UiText("Movement Force:")
		UiPop()
		UiPush()
		SetPos(-0.61,-0.25)
		local value = optionsSlider("savegame.mod.combined.VIOL_mover", 0, 0, 100)
		UiPop()
		UiPush()
		SetPos(-0.46,-0.25)
		UiText(value)
		UiPop()

		UiPush()
		SetPos(-0.8,-0.15)
		UiText("Rotational Force:")
		UiPop()
		UiPush()
		SetPos(-0.61,-0.15)
		local value = optionsSlider("savegame.mod.combined.VIOL_turnr", 0, 0, 300, 10)
		UiPop()
		UiPush()
		SetPos(-0.46,-0.15)
		UiText(value)
		UiPop()

		UiColor(0.15,0.65,1)
		UiPush()
		SetPos(-0.5,0.0)
		UiText("Adds random forces to debris for chaotic movement")
		UiPop()
	end

	-- Damage Statistics (Right Side)
	UiFont("bold.ttf", 20)
	UiColor(1,1,1)
	UiButtonImageBox("ui/common/box-outline-6.png", 6, 6)
	UiPush()
	SetPos(0.25,-0.45)
	drawButton("Damage Statistics", "savegame.mod.combined.Tog_DAMSTAT")
	UiPop()

	if GetBool("savegame.mod.combined.Tog_DAMSTAT") then
		UiPush()
		SetPos(0.15,-0.30)
		UiText("Currency:")
		UiPop()
		UiPush()
		SetPos(0.25,-0.30)
		local currencies = {"£", "EUR", "JPY", "RUB", "INR", "IQD", "PLN", "Baljeets", "ZAR", "VND", "BTC", "ETH", "Doge"}
		local curr_names = {"British Pounds", "Euros", "Japanese Yen", "Russian Ruble", "Indian Rupee", "Iraqi Dinar", "Polish Zloty", "Baljeet Bucks", "South African Rand", "Vietnamese Dong", "Bitcoin", "Ethereum", "Dogecoin"}
		local curr_idx = GetInt("savegame.mod.combined.DAMSTAT_Currency")
		if curr_idx < 1 then curr_idx = 1 end
		if curr_idx > #currencies then curr_idx = #currencies end
		if UiTextButton(currencies[curr_idx] .. " (" .. curr_names[curr_idx] .. ")", 200, 32) then
			curr_idx = curr_idx + 1
			if curr_idx > #currencies then curr_idx = 1 end
			SetInt("savegame.mod.combined.DAMSTAT_Currency", curr_idx)
		end
		UiPop()

		UiColor(0.15,0.65,1)
		UiPush()
		SetPos(0.2,0.0)
		UiText("Shows destruction cost in selected currency")
		UiPop()
	end

	-- Joint Breakage
	UiFont("bold.ttf", 20)
	UiColor(1,1,1)
	UiButtonImageBox("ui/common/box-outline-6.png", 6, 6)
	UiPush()
	SetPos(-0.7,0.15)
	drawButton("Joint Breakage", "savegame.mod.combined.Tog_JOINTS")
	UiPop()

	if GetBool("savegame.mod.combined.Tog_JOINTS") then
		UiPush()
		SetPos(-0.8,0.25)
		UiText("Break Chance:")
		UiPop()
		UiPush()
		SetPos(-0.61,0.25)
		local value = optionsSlider("savegame.mod.combined.JOINT_Chance", 5, 1, 100, 5)
		UiPop()
		UiPush()
		SetPos(-0.46,0.25)
		UiText(value)
		UiPop()
		UiPush()
		SetPos(-0.43,0.25)
		UiText("%")
		UiPop()

		UiPush()
		SetPos(-0.8,0.35)
		UiText("Break Radius:")
		UiPop()
		UiPush()
		SetPos(-0.61,0.35)
		local value = optionsSlider("savegame.mod.combined.JOINT_Range", 5, 1, 20)
		UiPop()
		UiPush()
		SetPos(-0.46,0.35)
		UiText(value)
		UiPop()

		UiColor(0.15,0.65,1)
		UiPush()
		SetPos(-0.5,0.5)
		UiText("Breaks joints near destroyed objects")
		UiPop()
	end
end
