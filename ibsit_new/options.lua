function default()
	SetInt("savegame.mod.ibsit.dust_amt", 50)
	SetInt("savegame.mod.ibsit.wood_size", 100)
	SetInt("savegame.mod.ibsit.stone_size", 75)
	SetInt("savegame.mod.ibsit.metal_size", 50)
	SetInt("savegame.mod.ibsit.momentum", 12)
	SetBool("savegame.mod.ibsit.haptic", true)
	SetBool("savegame.mod.ibsit.sounds", true)
	SetBool("savegame.mod.ibsit.particles", true)
	SetBool("savegame.mod.ibsit.vehicle", false)
	SetBool("savegame.mod.ibsit.joint", false)
	SetBool("savegame.mod.ibsit.protection", false)
	SetFloat("savegame.mod.ibsit.volume", 0.7)
	SetInt("savegame.mod.ibsit.particle_quality", 2)
	-- New gravity collapse settings
	SetBool("savegame.mod.ibsit.gravity_collapse", true)
	SetFloat("savegame.mod.ibsit.collapse_threshold", 0.3)
	SetFloat("savegame.mod.ibsit.gravity_force", 2.0)
	-- New debris cleanup settings
	SetBool("savegame.mod.ibsit.debris_cleanup", true)
	SetFloat("savegame.mod.ibsit.cleanup_delay", 30.0)
	SetBool("savegame.mod.ibsit.fps_optimization", true)
	SetInt("savegame.mod.ibsit.target_fps", 30)
	SetFloat("savegame.mod.ibsit.performance_scale", 1.0)
end

function init()
	if not HasKey("savegame.mod.ibsit") then
		default()
	end
end

-- Enhanced slider with new UI features
function enhancedSlider(key, min, max, cap, label, description)
	UiPush()
		UiTranslate(0, -8)
		local value = (GetInt(key) - min) / (max - min)
		local width = 140  -- Increased from 120 to 140
		UiRect(width * (cap / max), 4)
		UiAlign("center middle")
		value = UiSlider("ui/common/dot.png", "x", value * width, 0, width * (cap / max)) / width
		value = math.floor(value * (max - min) + min)
		SetInt(key, value)
		UiTranslate(0, -20)
		UiFont("bold.ttf", 22)
		UiText(label)
		UiTranslate(0, 16)
		UiFont("regular.ttf", 16)
		UiColor(0.8, 0.8, 0.8)
		UiText(description)
		UiTranslate(0, 24)
	UiPop()
	return value
end

-- Enhanced toggle button with new UI features
function enhancedToggle(key, label, description)
	local value = GetBool(key)
	UiPush()
		UiTranslate(-140, 0)  -- Increased from -120 to -140 for more space
		UiFont("bold.ttf", 22)
		UiText(label)
		UiTranslate(0, 16)
		UiFont("regular.ttf", 16)
		UiColor(0.8, 0.8, 0.8)
		UiText(description)
		UiTranslate(280, -12)  -- Increased from 240 to 280 for wider layout
		UiButtonImageBox("ui/common/box-outline-6.png", 6, 6)
		if value then
			UiPush()
				UiColor(0.2, 0.8, 0.2, 0.3)
				UiImageBox("ui/common/box-solid-6.png", 280, 50, 6, 6)  -- Increased width from 240 to 280
			UiPop()
		end
		if UiTextButton(value and "Enabled" or "Disabled", 280, 50) then  -- Increased width from 240 to 280
			SetBool(key, not value)
		end
	UiPop()
end

-- Volume slider
function volumeSlider()
	UiPush()
		UiTranslate(0, -8)
		local value = GetFloat("savegame.mod.ibsit.volume")
		local width = 140  -- Increased from 120 to 140 to match other sliders
		UiRect(width * value, 4)
		UiAlign("center middle")
		value = UiSlider("ui/common/dot.png", "x", value * width, 0, width) / width
		SetFloat("savegame.mod.ibsit.volume", value)
		UiTranslate(0, -20)
		UiFont("bold.ttf", 22)
		UiText("Sound Volume")
		UiTranslate(0, 16)
		UiFont("regular.ttf", 16)
		UiColor(0.8, 0.8, 0.8)
		UiText("Adjust sound effect volume")
		UiTranslate(0, 24)
	UiPop()
	return value
end

-- Quality selector
function qualitySelector()
	local quality = GetInt("savegame.mod.ibsit.particle_quality")
	UiPush()
		UiTranslate(-140, 0)  -- Increased from -120 to -140 to match toggle layout
		UiFont("bold.ttf", 22)
		UiText("Particle Quality")
		UiTranslate(0, 16)  -- Reduced from 20 to 16
		UiFont("regular.ttf", 16)
		UiColor(0.8, 0.8, 0.8)
		UiText("Higher quality = more particles")
		UiTranslate(280, -12)  -- Increased from 240 to 280 to match toggle layout
		UiButtonImageBox("ui/common/box-outline-6.png", 6, 6)

		local qualityText = {"Low", "Medium", "High"}
		if UiTextButton(qualityText[quality + 1], 280, 50) then  -- Increased width from 240 to 280
			SetInt("savegame.mod.ibsit.particle_quality", (quality + 1) % 3)
		end
	UiPop()
end

-- Gravity collapse settings
function gravityCollapseSettings()
	UiPush()
		UiTranslate(-140, 0)
		UiFont("bold.ttf", 22)
		UiText("Gravity Collapse")
		UiTranslate(0, 16)
		UiFont("regular.ttf", 16)
		UiColor(0.8, 0.8, 0.8)
		UiText("Structures collapse under gravity when damaged")
		UiTranslate(280, -12)
		UiButtonImageBox("ui/common/box-outline-6.png", 6, 6)
		if UiTextButton(GetBool("savegame.mod.ibsit.gravity_collapse") and "Enabled" or "Disabled", 280, 50) then
			SetBool("savegame.mod.ibsit.gravity_collapse", not GetBool("savegame.mod.ibsit.gravity_collapse"))
		end
	UiPop()

	if GetBool("savegame.mod.ibsit.gravity_collapse") then
		UiTranslate(0, 60)
		UiPush()
			UiTranslate(0, -8)
			local value = GetFloat("savegame.mod.ibsit.collapse_threshold")
			local width = 140
			UiRect(width * value, 4)
			UiAlign("center middle")
			value = UiSlider("ui/common/dot.png", "x", value * width, 0, width) / width
			SetFloat("savegame.mod.ibsit.collapse_threshold", value)
			UiTranslate(0, -20)
			UiFont("bold.ttf", 22)
			UiText("Collapse Threshold")
			UiTranslate(0, 16)
			UiFont("regular.ttf", 16)
			UiColor(0.8, 0.8, 0.8)
			UiText(string.format("Collapse when integrity below %.0f%%", value * 100))
			UiTranslate(0, 24)
		UiPop()

		UiTranslate(0, 60)
		UiPush()
			UiTranslate(0, -8)
			local value = GetFloat("savegame.mod.ibsit.gravity_force")
			local width = 140
			UiRect(width * (value / 5), 4)  -- Scale for max 5.0
			UiAlign("center middle")
			value = UiSlider("ui/common/dot.png", "x", value * (width / 5), 0, width) / (width / 5)
			SetFloat("savegame.mod.ibsit.gravity_force", value)
			UiTranslate(0, -20)
			UiFont("bold.ttf", 22)
			UiText("Gravity Force")
			UiTranslate(0, 16)
			UiFont("regular.ttf", 16)
			UiColor(0.8, 0.8, 0.8)
			UiText(string.format("Collapse force multiplier: %.1f", value))
			UiTranslate(0, 24)
		UiPop()
	end
end

-- Debris cleanup settings
function debrisCleanupSettings()
	UiPush()
		UiTranslate(-140, 0)
		UiFont("bold.ttf", 22)
		UiText("Debris Cleanup")
		UiTranslate(0, 16)
		UiFont("regular.ttf", 16)
		UiColor(0.8, 0.8, 0.8)
		UiText("Automatically remove debris after delay")
		UiTranslate(280, -12)
		UiButtonImageBox("ui/common/box-outline-6.png", 6, 6)
		if UiTextButton(GetBool("savegame.mod.ibsit.debris_cleanup") and "Enabled" or "Disabled", 280, 50) then
			SetBool("savegame.mod.ibsit.debris_cleanup", not GetBool("savegame.mod.ibsit.debris_cleanup"))
		end
	UiPop()

	if GetBool("savegame.mod.ibsit.debris_cleanup") then
		UiTranslate(0, 60)
		UiPush()
			UiTranslate(0, -8)
			local value = GetFloat("savegame.mod.ibsit.cleanup_delay")
			local width = 140
			UiRect(width * (value / 120), 4)  -- Scale for max 120 seconds
			UiAlign("center middle")
			value = UiSlider("ui/common/dot.png", "x", value * (width / 120), 0, width) / (width / 120)
			SetFloat("savegame.mod.ibsit.cleanup_delay", value)
			UiTranslate(0, -20)
			UiFont("bold.ttf", 22)
			UiText("Cleanup Delay")
			UiTranslate(0, 16)
			UiFont("regular.ttf", 16)
			UiColor(0.8, 0.8, 0.8)
			UiText(string.format("Remove debris after %.1f seconds", value))
			UiTranslate(0, 24)
		UiPop()
	end

	UiTranslate(0, 60)
	UiPush()
		UiTranslate(-140, 0)
		UiFont("bold.ttf", 22)
		UiText("FPS Optimization")
		UiTranslate(0, 16)
		UiFont("regular.ttf", 16)
		UiColor(0.8, 0.8, 0.8)
		UiText("Automatically adjust performance for target FPS")
		UiTranslate(280, -12)
		UiButtonImageBox("ui/common/box-outline-6.png", 6, 6)
		if UiTextButton(GetBool("savegame.mod.ibsit.fps_optimization") and "Enabled" or "Disabled", 280, 50) then
			SetBool("savegame.mod.ibsit.fps_optimization", not GetBool("savegame.mod.ibsit.fps_optimization"))
		end
	UiPop()

	if GetBool("savegame.mod.ibsit.fps_optimization") then
		UiTranslate(0, 60)
		UiPush()
			UiTranslate(0, -8)
			local value = GetInt("savegame.mod.ibsit.target_fps")
			local width = 140
			UiRect(width * (value / 60), 4)  -- Scale for max 60 FPS
			UiAlign("center middle")
			value = UiSlider("ui/common/dot.png", "x", value * (width / 60), 0, width) / (width / 60)
			value = math.floor(value)
			SetInt("savegame.mod.ibsit.target_fps", value)
			UiTranslate(0, -20)
			UiFont("bold.ttf", 22)
			UiText("Target FPS")
			UiTranslate(0, 16)
			UiFont("regular.ttf", 16)
			UiColor(0.8, 0.8, 0.8)
			UiText(string.format("Maintain %d FPS", value))
			UiTranslate(0, 24)
		UiPop()
	end
end

function draw()
	UiTranslate(UiCenter(), 80)  -- Reduced from 120 to 80
	UiAlign("center middle")

	-- Enhanced title with gradient
	UiPush()
		UiColor(0.2, 0.6, 1.0)
		UiFont("bold.ttf", 48)
		UiText("IBSIT v2.0 Options")
	UiPop()

	-- Main settings
	UiTranslate(0, 70)  -- Reduced from 100 to 70
	UiFont("regular.ttf", 26)

	-- Damage settings section
	UiPush()
		UiColor(1, 1, 1)
		UiFont("bold.ttf", 28)
		UiText("Damage Settings")
	UiPop()

	UiTranslate(0, 40)  -- Reduced from 50 to 40
	enhancedSlider("savegame.mod.ibsit.dust_amt", 0, 100, 100, "Dust Amount", "Amount of debris particles")

	UiTranslate(0, 65)  -- Reduced from 80 to 65
	enhancedSlider("savegame.mod.ibsit.wood_size", 0, 200, 200, "Soft Material Damage", "Wood, foliage, plastic damage multiplier")

	UiTranslate(0, 65)  -- Reduced from 80 to 65
	enhancedSlider("savegame.mod.ibsit.stone_size", 0, 200, GetInt("savegame.mod.ibsit.wood_size"), "Medium Material Damage", "Stone, concrete damage multiplier")

	UiTranslate(0, 65)  -- Reduced from 80 to 65
	enhancedSlider("savegame.mod.ibsit.metal_size", 0, 200, GetInt("savegame.mod.ibsit.stone_size"), "Hard Material Damage", "Metal damage multiplier")

	UiTranslate(0, 65)  -- Reduced from 80 to 65
	enhancedSlider("savegame.mod.ibsit.momentum", 0, 20, 20, "Momentum Threshold", "Lower = more sensitive (warning: may cause chain reactions!)")

	-- Feature toggles section
	UiTranslate(0, 50)  -- Reduced from 60 to 50
	UiPush()
		UiColor(1, 1, 1)
		UiFont("bold.ttf", 28)
		UiText("Features")
	UiPop()

	UiTranslate(0, 40)  -- Reduced from 50 to 40
	enhancedToggle("savegame.mod.ibsit.particles", "Enhanced Particles", "Improved particle effects with material-specific visuals")

	UiTranslate(0, 60)  -- Reduced from 70 to 60
	enhancedToggle("savegame.mod.ibsit.sounds", "Sound Effects", "Play sounds for structural failures and impacts")

	if GetBool("savegame.mod.ibsit.sounds") then
		UiTranslate(0, 60)  -- Reduced from 70 to 60
		volumeSlider()
	end

	UiTranslate(0, 60)  -- Reduced from 70 to 60
	enhancedToggle("savegame.mod.ibsit.haptic", "Haptic Feedback", "Vibration feedback for impacts (requires compatible controller)")

	UiTranslate(0, 60)  -- Reduced from 70 to 60
	qualitySelector()

	-- Gravity Collapse section
	UiTranslate(0, 65)  -- Reduced from 80 to 65
	UiPush()
		UiColor(1, 1, 1)
		UiFont("bold.ttf", 28)
		UiText("Gravity Collapse")
	UiPop()

	UiTranslate(0, 40)  -- Reduced from 50 to 40
	gravityCollapseSettings()

	-- Performance section
	UiTranslate(0, 65)  -- Reduced from 80 to 65
	UiPush()
		UiColor(1, 1, 1)
		UiFont("bold.ttf", 28)
		UiText("Performance")
	UiPop()

	UiTranslate(0, 40)  -- Reduced from 50 to 40
	debrisCleanupSettings()

	-- Advanced settings section
	UiTranslate(0, 65)  -- Reduced from 80 to 65
	UiPush()
		UiColor(1, 1, 1)
		UiFont("bold.ttf", 28)
		UiText("Advanced Settings")
	UiPop()

	UiTranslate(0, 40)  -- Reduced from 50 to 40
	enhancedToggle("savegame.mod.ibsit.vehicle", "Affect Vehicles", "Should structural integrity affect vehicles?")

	UiTranslate(0, 60)  -- Reduced from 70 to 60
	enhancedToggle("savegame.mod.ibsit.joint", "Affect Joints", "Should structural integrity affect elevators/doors?")

	UiTranslate(0, 60)  -- Reduced from 70 to 60
	enhancedToggle("savegame.mod.ibsit.protection", "Protection Mode", "Protect objects tagged 'leave_me_alone'")

	-- Action buttons
	UiTranslate(0, 70)  -- Reduced from 100 to 70
	UiPush()
		UiTranslate(-180, 0)  -- Increased from -150 to -180 for wider spacing
		if UiTextButton("Reset to Default", 160, 50) then  -- Increased width from 140 to 160
			default()
		end
		UiTranslate(200, 0)  -- Increased from 160 to 200 for wider spacing
		if UiTextButton("Close", 160, 50) then  -- Increased width from 140 to 160
			Menu()
		end
	UiPop()

	-- Version info
	UiTranslate(0, 60)  -- Reduced from 80 to 60
	UiPush()
		UiFont("regular.ttf", 16)
		UiColor(0.6, 0.6, 0.6)
		UiText("IBSIT v2.0 - Enhanced Structural Integrity")
		UiTranslate(0, 20)
		UiText("Compatible with Teardown 1.7.0+")
	UiPop()
end
