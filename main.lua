#include "umf/umf_meta.lua"
#include "slimerand.lua"
#include "slimegcfunc.lua"
#include "tools/integrity_scanner.lua"
#include "tools/gravity_collapse.lua"
#include "defaults.lua"

-- Combined Physics Destruction Mod
-- Merges features from PDM (Progressive Destruction), IBSIT (Impact Based), and MBCS (Mass Based)

-- Constants
local abs = math.abs
local min, max = Vec(-math.huge, -math.huge, -math.huge), Vec(math.huge, math.huge, math.huge)
local functions = {
	bodies = {},
	shapes = {}
}
local statics = {}
local last_broken_time = GetTime() + 5

-- FPS counter
local framesPerSecond = 0
local frames = 0
local perry = 1
local FPS_marker = 0
-- Other
local hideHud = false

-- Pause menu integration
local optionsVisible = false

-- Math functions
local random, sqrt, log = math.random, math.sqrt, math.log
local co_create, co_resume, co_yield = coroutine.create, coroutine.resume, coroutine.yield

-- IBSIT/MBCS random seed
math.randomseed(tonumber(tostring(newproxy(false)):sub(19, -2), 16))
local addrndVec, addrangedVec = Fastrnd.AddNewBall.UnitVec, Fastrnd.IterateBall.RangedVec
local sratio = 3 / 4096

-- Material switches for particles
local switches = {
	foliage = 8,
	glass = 8,
	ice = 8,
	wood = 8,
	dirt = 3,
	masonry = 0,
	plaster = 0,
	hardmasonry = 3,
	plastic = 8,
	metal = 4,
	hardmetal = 6
}

-- Enhanced IBSIT v2.0 material damage multipliers
local materialMultipliers = {
	foliage = 2.0,
	glass = 1.5,
	ice = 1.3,
	wood = 1.0,
	dirt = 0.8,
	masonry = 0.6,
	plaster = 0.7,
	hardmasonry = 0.4,
	plastic = 1.2,
	metal = 0.5,
	hardmetal = 0.3
}

-- Enhanced IBSIT variables
local ibsit_triggered = false
local ibsit_vel, ibsit_pos, ibsit_time, ibsit_breaklist, ibsit_gcl = {}, {}, {}, {}, {}
local ibsit_ind = nil
local ibsit_cached_breaksize, ibsit_cached_breakpoint, ibsit_last_frame
local ibsit_performanceStats = {bodies_processed = 0, holes_created = 0, particles_spawned = 0}

-- Gravity collapse variables
local ibsit_gravityCollapse = ibsit_gravity_collapse
local ibsit_collapseThreshold = ibsit_collapse_threshold
local ibsit_gravityForce = ibsit_gravity_force
local ibsit_structuralIntegrity = {} -- Track integrity per body

-- Debris cleanup variables
local ibsit_debrisCleanup = ibsit_debris_cleanup
local ibsit_cleanupDelay = ibsit_cleanup_delay
local ibsit_fpsOptimization = ibsit_fps_optimization
local ibsit_targetFPS = ibsit_target_fps
local ibsit_performanceScale = ibsit_performance_scale
local ibsit_debrisTimers = {} -- Track cleanup timers
local ibsit_lastFrameTime = 0
local ibsit_currentFPS = 60

-- Registry key prefixes to avoid conflicts
SetBool("savegame.mod.combined.launch", true)

-- Load main control variables
local TOG_FPSC = GetBool("savegame.mod.combined.Tog_FPSC")
local TOG_DUST = GetBool("savegame.mod.combined.Tog_DUST")
local TOG_CRUMBLE = GetBool("savegame.mod.combined.Tog_CRUMBLE")
local TOG_RUMBLE = GetBool("savegame.mod.combined.Tog_RUMBLE")
local TOG_FORCE = GetBool("savegame.mod.combined.Tog_FORCE")
local TOG_FIRE = GetBool("savegame.mod.combined.Tog_FIRE")
local TOG_VIOLENCE = GetBool("savegame.mod.combined.Tog_VIOLENCE")
local TOG_DAMSTAT = GetBool("savegame.mod.combined.Tog_DAMSTAT")
local TOG_JOINTS = GetBool("savegame.mod.combined.Tog_JOINTS")
local TOG_IMPACT = GetBool("savegame.mod.combined.Tog_IMPACT")  -- IBSIT impact detection
local TOG_MASS = GetBool("savegame.mod.combined.Tog_MASS")      -- MBCS mass-based

-- FPS Control Settings
local TOG_SDF = GetBool("savegame.mod.combined.Tog_SDF")
local TOG_LFF = GetBool("savegame.mod.combined.Tog_LFF")
local TOG_DBF = GetBool("savegame.mod.combined.Tog_DBF")
local FPS_DynLights = GetBool("savegame.mod.combined.FPS_DynLights")
local FPS_SDF = GetInt("savegame.mod.combined.FPS_SDF")
local FPS_LFF = GetInt("savegame.mod.combined.FPS_LFF")
local FPS_DBF = GetInt("savegame.mod.combined.FPS_DBF")
local FPS_DBF_FPSB = GetBool("savegame.mod.combined.FPS_DBF_FPSB")
local FPS_Targ = GetInt("savegame.mod.combined.FPS_Targ")
local FPS_Agg = GetInt("savegame.mod.combined.FPS_Agg")

-- Dust Settings
local dust_amt = GetInt("savegame.mod.combined.dust_amt")
local dust_size = GetInt("savegame.mod.combined.dust_size")
local dust_szvar = GetInt("savegame.mod.combined.dust_sizernd")
local dust_szMB = GetInt("savegame.mod.combined.dust_MsBsSz")
local dust_grav = GetInt("savegame.mod.combined.dust_grav")
local dust_drag = GetInt("savegame.mod.combined.dust_drag")
local dust_life = GetInt("savegame.mod.combined.dust_life")
local dust_lifernd = GetInt("savegame.mod.combined.dust_lifernd")
local dust_MsBsLf = GetInt("savegame.mod.combined.dust_MsBsLf")
local dust_minMass = GetInt("savegame.mod.combined.dust_minMass")
local dust_minSpeed = GetInt("savegame.mod.combined.dust_minSpeed")

-- Crumble Settings
local crum_dist = GetInt("savegame.mod.combined.crum_dist")
local crum_speed = GetInt("savegame.mod.combined.crum_spd")
local crum_DMGLight = GetInt("savegame.mod.combined.crum_DMGLight")
local crum_DMGMed = GetInt("savegame.mod.combined.crum_DMGMed")
local crum_DMGHeavy = GetInt("savegame.mod.combined.crum_DMGHeavy")
local crum_HoleControl = GetInt("savegame.mod.combined.crum_HoleControl")
local crum_BreakTime = GetFloat("savegame.mod.combined.crum_BreakTime")
local crum_distFromPlyr = GetInt("savegame.mod.combined.crum_distFromPlyr")
local crum_MinMass = GetInt("savegame.mod.combined.crum_MinMass")
local crum_MaxMass = GetInt("savegame.mod.combined.crum_MaxMass")
local crum_MinSpd = GetFloat("savegame.mod.combined.crum_MinSpd")
local crum_MaxSpd = GetFloat("savegame.mod.combined.crum_MaxSpd")

-- Explosion Settings
local xplo_szBase = GetFloat("savegame.mod.combined.xplo_szBase")
local xplo_szRnd = GetFloat("savegame.mod.combined.xplo_szRND")
local xplo_chance = GetInt("savegame.mod.combined.xplo_chance")
local xplo_HoleControl = GetInt("savegame.mod.combined.xplo_HoleControl")
local xplo_BreakTime = GetFloat("savegame.mod.combined.xplo_BreakTime")
local xplo_distFromPlyr = GetInt("savegame.mod.combined.xplo_distFromPlyr")
local xplo_MinMass = GetInt("savegame.mod.combined.xplo_MinMass")
local xplo_MaxMass = GetInt("savegame.mod.combined.xplo_MaxMass")
local xplo_MinSpd = GetFloat("savegame.mod.combined.xplo_MinSpd")
local xplo_MaxSpd = GetFloat("savegame.mod.combined.xplo_MaxSpd")

-- IBSIT Settings (Enhanced v2.0)
local ibsit_momentum = GetInt("savegame.mod.combined.ibsit_momentum")
local ibsit_dust_amt = GetInt("savegame.mod.combined.ibsit_dust_amt")
local ibsit_wood_size = GetInt("savegame.mod.combined.ibsit_wood_size")
local ibsit_stone_size = GetInt("savegame.mod.combined.ibsit_stone_size")
local ibsit_metal_size = GetInt("savegame.mod.combined.ibsit_metal_size")

-- Enhanced IBSIT v2.0 features
local ibsit_haptic = GetBool("savegame.mod.combined.ibsit_haptic")
local ibsit_sounds = GetBool("savegame.mod.combined.ibsit_sounds")
local ibsit_particles = GetBool("savegame.mod.combined.ibsit_particles")
local ibsit_vehicle = GetBool("savegame.mod.combined.ibsit_vehicle")
local ibsit_joint = GetBool("savegame.mod.combined.ibsit_joint")
local ibsit_protection = GetBool("savegame.mod.combined.ibsit_protection")
local ibsit_volume = GetFloat("savegame.mod.combined.ibsit_volume")
local ibsit_particle_quality = GetInt("savegame.mod.combined.ibsit_particle_quality")

-- Gravity collapse features
local ibsit_gravity_collapse = GetBool("savegame.mod.combined.ibsit_gravity_collapse")
local ibsit_collapse_threshold = GetFloat("savegame.mod.combined.ibsit_collapse_threshold")
local ibsit_gravity_force = GetFloat("savegame.mod.combined.ibsit_gravity_force")

-- Debris cleanup features
local ibsit_debris_cleanup = GetBool("savegame.mod.combined.ibsit_debris_cleanup")
local ibsit_cleanup_delay = GetFloat("savegame.mod.combined.ibsit_cleanup_delay")
local ibsit_fps_optimization = GetBool("savegame.mod.combined.ibsit_fps_optimization")
local ibsit_target_fps = GetInt("savegame.mod.combined.ibsit_target_fps")
local ibsit_performance_scale = GetFloat("savegame.mod.combined.ibsit_performance_scale")

-- MBCS Settings
local mbcs_mass = GetInt("savegame.mod.combined.mbcs_mass")
local mbcs_distance = GetInt("savegame.mod.combined.mbcs_distance")
local mbcs_dust_amt = GetInt("savegame.mod.combined.mbcs_dust_amt")
local mbcs_wood_size = GetInt("savegame.mod.combined.mbcs_wood_size")
local mbcs_stone_size = GetInt("savegame.mod.combined.mbcs_stone_size")
local mbcs_metal_size = GetInt("savegame.mod.combined.mbcs_metal_size")

-- Force/Wind Settings
local force_method = GetInt("savegame.mod.combined.force_method")
local force_strength = GetInt("savegame.mod.combined.force_strength")
local force_radius = GetInt("savegame.mod.combined.force_radius")
local force_minmass = GetInt("savegame.mod.combined.force_minmass")
local force_maxmass = GetInt("savegame.mod.combined.force_maxmass")

-- Violence Settings
local viol_chance = GetInt("savegame.mod.combined.viol_chance")
local viol_mover = GetInt("savegame.mod.combined.viol_mover")
local viol_turnr = GetInt("savegame.mod.combined.viol_turnr")
local viol_minmass = GetInt("savegame.mod.combined.viol_minmass")
local viol_maxmass = GetInt("savegame.mod.combined.viol_maxmass")

-- Debris cleaner
local SDF_Size = GetInt("savegame.mod.combined.FPS_SDF")
local LFF_Size = GetInt("savegame.mod.combined.FPS_LFF")

-- Performance limits
local max_smokes_per_tick = dust_amt
local max_explodes_per_tick = 1
local max_crumble_per_tick = (14 - crum_HoleControl) * 1

-- IBSIT/MBCS variables
local ibsit_triggered = false
local mbcs_triggered = false
local vel, pos, time, breaklist, gcl = {}, {}, {}, {}, {}
local shp, mbcs_breaklist = {}, {}
local ind_ibsit = nil
local ind_mbcs = nil

-- Calculated values
local radegast_12 = 23 - crum_speed
local hole_control = crum_HoleControl
local hole_breaktime = crum_BreakTime
local boom_control = xplo_HoleControl
local boom_breaktime = xplo_BreakTime

-- IBSIT calculated values (Enhanced v2.0)
local wb_ibsit, mb_ibsit, hb_ibsit = ibsit_wood_size / 100, ibsit_stone_size / 100, ibsit_metal_size / 100
local threshold_ibsit = 2 ^ ibsit_momentum
local rthreshold_ibsit = 5 / threshold_ibsit
local dust_ibsit = 4096 / ibsit_dust_amt
local rdust_ibsit = 1 / dust_ibsit
local fdust_ibsit = ibsit_dust_amt

-- Enhanced IBSIT calculated values
local ibsit_vehicle_enabled = not ibsit_vehicle
local ibsit_joint_enabled = not ibsit_joint
local ibsit_protect_enabled = not ibsit_protection
local ibsit_haptic_enabled = ibsit_haptic
local ibsit_sounds_enabled = ibsit_sounds
local ibsit_particles_enabled = ibsit_particles
local ibsit_volume_level = ibsit_volume
local ibsit_particleQuality = ibsit_particle_quality

-- MBCS calculated values
local wb_mbcs, mb_mbcs, hb_mbcs = mbcs_wood_size / 100, mbcs_stone_size / 100, mbcs_metal_size / 100
local threshold_mbcs = 2 ^ mbcs_mass
local rthreshold_mbcs = 5 / threshold_mbcs
local dust_mbcs = 4096 / mbcs_dust_amt
local rdust_mbcs = 1 / dust_mbcs
local fdust_mbcs = mbcs_dust_amt
local angle_mbcs = 0.707 * mbcs_distance

-- PDM calculated values
local dust = 4096 / dust_amt
local rdust = 1 / dust
local fdust = dust_amt

-- Turn off all lights in the world to minimize light ray tracing
local function disableLight(shape)
	local lights = GetShapeLights(shape)
	for j = 1, #lights do
		SetLightEnabled(lights[j], false)
	end
end

-- PDM: Small Debris Filter
function destroyObjects(body)
	if framesPerSecond < (FPS_Targ + 1) and TOG_SDF then
		if GetBodyMass(body) < SDF_Size and (math.random()*400) > (397 - GetInt("savegame.mod.combined.FPS_SDF_agg") - FPS_Agg) then
			Delete(body)
		end
	end
end

-- PDM: Dynamic Objects Filter
function dynamicObjects(body)
	local dysta = (VecLength(VecSub(GetBodyTransform(body).pos, GetPlayerTransform().pos))) * 0.85
	if (framesPerSecond < FPS_Targ) or (framesPerSecond < 32 and math.random() < (0.3 + ((100 - GetInt("savegame.mod.combined.FPS_SDF_agg")) * 0.01))) then
		if (math.random()*400) > (397 - ((GetInt("savegame.mod.combined.FPS_LFF_agg") + FPS_Agg) * 0.5)) and GetBodyMass(body) < LFF_Size and TOG_LFF then
			Delete(body)
		end
		if FPS_DBF_FPSB == true then
			if (math.random()*400) > (397 - GetInt("savegame.mod.combined.FPS_DBF_agg")) and (dysta < FPS_DBF) then
				Delete(body)
			end
		end
	end

	if TOG_DBF and not FPS_DBF_FPSB then
		if (dysta > FPS_DBF) and (math.random()*400) > (397 - GetInt("savegame.mod.combined.FPS_DBF_agg")) and GetBodyMass(body) < LFF_Size then
			Delete(body)
		end
	end
end

-- PDM: Fire Objects
function igniteObjects(body)
	local fire_loc = GetBodyTransform(body).pos
	local portliness = GetBodyMass(body)
	local max_dist = 1
	local dyst = (VecLength(VecSub(fire_loc, GetPlayerTransform().pos)))
	if (math.random()*100) < (GetInt("savegame.mod.combined.fyr_chance")) and dyst > GetInt("savegame.mod.combined.fyr_minrad")/2 and dyst < GetInt("savegame.mod.combined.fyr_maxrad") and portliness > GetInt("savegame.mod.combined.fyr_minmass") and portliness < GetInt("savegame.mod.combined.fyr_maxmass") then
		local offset = Vec((0.5 - math.random())*max_dist, (0.5 - math.random())*3, (0.5 - math.random())*max_dist)
		local loc = VecAdd(fire_loc, offset)
		SpawnFire(fire_loc)
	end
end

-- IBSIT: Get Body Voxel Count
local function GetBodyVoxelCount(body)
	local count = 0
	local shapes = GetBodyShapes(body)
	for i = #shapes, 1, -1 do
		count = count + GetShapeVoxelCount(shapes[i])
	end
	return count
end

-- IBSIT: Random Point
local function rndPnt(a, b)
	return {a[1] + (b[1] - a[1]) * random(), a[2] + (b[2] - a[2]) * random(), a[3] + (b[3] - a[3]) * random()}
end

-- IBSIT: Garbage Collection
function upongc_ibsit()
	for body = #gcl, 1, -1 do
		body = gcl[body]
		if IsHandleValid(body) then
			if not IsBodyActive(body) then
				SetTag(body, "spd", "gc")
			end
		elseif time[-body] then
			vel[body], vel[-body], time[body], time[-body], pos[body], pos[-body] = nil, nil, nil, nil, nil, nil
		end
	end
end

-- MBCS: Garbage Collection
function upongc_mbcs()
	for body = #gcl, 1, -1 do
		body = gcl[body]
		if not IsBodyActive(body) and IsHandleValid(body) then
			SetTag(body, "val", "gc")
		end
	end
end

-- PDM: Main Functions Call
function callFunctions()
	local fps_waz_checked = 0
	local a4ce_start = 1
	if GetInt("savegame.mod.combined.force_warmup") > 0 then
		if GetTime() < GetInt("savegame.mod.combined.force_warmup") then
			a4ce_start = GetTime() / GetInt("savegame.mod.combined.force_warmup")
		end
	end

	if TOG_FORCE or TOG_JOINTS then
		local maxMass = force_maxmass
		local minMass = force_minmass
		local maxDist = force_radius
		local strength = force_strength / 75

		local PLAYER_AFFECTED_BY_WIND = 0
		local t = GetPlayerCameraTransform()
		local c = TransformToParentPoint(t, Vec(0, 0, 0))
		local mi = VecAdd(c, Vec(-maxDist*2, -maxDist*2, -maxDist*2))
		local ma = VecAdd(c, Vec(maxDist*2, maxDist*2, maxDist*2))
		local angle1 = math.sin(GetTime() / GetInt("savegame.mod.combined.force_cycle"))
		local angle2 = math.cos(GetTime() / GetInt("savegame.mod.combined.force_cycle"))
		local super_dooper_debris_booster = GetInt("savegame.mod.combined.force_boost") / 10

		QueryRequire("physical dynamic")
		local bodies = QueryAabbBodies(mi, ma)
		for i = 1, #bodies do
			local b = bodies[i]
			local body = GetShapeBody(b)

			local broken = IsBodyBroken(b)
			local mass = GetBodyMass(b)
			local vector_vel = GetBodyVelocity(b)
			local vector_len = VecLength(vector_vel)

			if broken == true then
				local chance = GetInt("savegame.mod.combined.joint_chance") / 100
				if last_broken_time < GetTime() and math.random() < chance and TOG_JOINTS then
					local dyst = GetInt("savegame.mod.combined.joint_range")
					dyst = dyst / 2
					QueryRequire("physical")
					local camloc = GetBodyTransform(b)
					local jist = QueryAabbShapes(Vec(camloc.pos[1] - dyst, camloc.pos[2] - dyst, camloc.pos[3] - dyst), Vec(camloc.pos[1] + dyst, camloc.pos[2] + dyst, camloc.pos[3] + dyst))
					for ez = 1, #jist do
						local shaype = jist[ez]
						local hinges = GetShapeJoints(shaype)
						for ii = 1, #hinges do
							local joint = hinges[ii]
							Delete(joint)
						end
					end
					last_broken_time = GetTime() + 0.25
				end
			end

			if automode and TOG_FORCE then
				local bmi, bma = GetBodyBounds(b)
				local bc = VecLerp(bmi, bma, 0.5)
				local dir = VecSub(bc, t.pos)
				local dist = VecLength(dir)
				dir = VecScale(dir, 1.0/dist)

				local mass = GetBodyMass(b)
				local scaler = 1 + (mass * 0.00025)

				if mass > (maxMass * 0.50) then
					scaler = scaler * GetInt("savegame.mod.combined.force_largemass_accellerator")
				end

				if dist < maxDist and mass > minMass and mass < maxMass then
					local add = VecScale(dir, (((strength * scaler) * (1 + super_dooper_debris_booster)) * a4ce_start))
					local vel = GetBodyVelocity(b)
					local screw_quaternions = GetBodyAngularVelocity(b)
					local angle_force = GetInt("savegame.mod.combined.force_rotational")
					local they_are_evil = Vec(((0.5-math.random())*angle_force)*a4ce_start, ((0.5-math.random())*angle_force)*a4ce_start, ((0.5-math.random())*angle_force)*a4ce_start)
					local AnglesForever = VecAdd(screw_quaternions, they_are_evil)
					SetBodyAngularVelocity(b, AnglesForever)
					vel = VecAdd(vel, add)
					SetBodyVelocity(b, vel)
				end
			end
		end

		if PLAYER_AFFECTED_BY_WIND == 0 and automode then
			local scaler = strength * (GetInt("savegame.mod.combined.force_effect_on_player") / 50)
			local add = VecScale(Vec(0, 0, 0), scaler * a4ce_start)
			local vel_player = GetPlayerVelocity()
			local vel = VecAdd(vel_player, add)
			SetPlayerVelocity(vel)
		end
	end

	local maxDist = 500
	local mi = VecAdd(c, Vec(-maxDist*2, -maxDist*2, -maxDist*2))
	local ma = VecAdd(c, Vec(maxDist*2, maxDist*2, maxDist*2))
	QueryRequire("physical dynamic")
	local bodies = QueryAabbBodies(mi, ma)
	for i = 1, #bodies do
		local b = bodies[i]
		if IsBodyBroken(b) and TOG_FPSC and GetTime() > next_FPS_check then
			destroyObjects(b)
			dynamicObjects(b)
			if TOG_FIRE then
				igniteObjects(b)
			end
			fps_waz_checked = 1
		end
	end

	if Dlights_have_been_disabled == 0 then
		local shapes = QueryAabbShapes(min, max)
		for j = 1, #shapes do
			local shape = shapes[j]
			if FPS_DynLights then
				disableLight(shape)
			end
		end
		Dlights_have_been_disabled = 1
	end

	if fps_waz_checked == 1 then
		local new_delay = 0.6 - (GetInt("savegame.mod.combined.FPS_SDF_agg") * 0.0015) - (GetInt("savegame.mod.combined.FPS_DBF_agg") * 0.0015) - (GetInt("savegame.mod.combined.FPS_DBF_agg") * 0.0015)
		if crum_speed > 17 then
			new_delay = new_delay * 0.5
		end
		next_FPS_check = GetTime() + new_delay
	end
end

-- IBSIT: Breaks function
local function breaks_ibsit(body, c, s, a)
	local sr, sg, sb, tc, shape
	for i = sqrt(a), 0, -5 do
		_, tc, _, shape = GetBodyClosestPoint(body, tc and addrangedVec(tc, 5.5) or c)
		shape, sr, sg, sb, sa = GetShapeMaterialAtPosition(shape, tc)
		a = MakeHole(tc, wb_ibsit * i, mb_ibsit * i, hb_ibsit * i)
		if a > dust_ibsit then
			local x
			if a < 4096 then
				x, c = a * rdust_ibsit, a * sratio
			else
				x, c = fdust_ibsit, 3
			end
			ParticleReset()
			if shape ~= "" then
				if shape == "metal" or shape == "hardmetal" then
					ParticleAlpha(1, 0)
					ParticleRadius(0.03, 0.0, "easein")
					ParticleEmissive(5, 0, "easeout")
					ParticleColor(1, 0.4, 0.3)
					ParticleGravity(-10)
					ParticleSticky(0.2)
					ParticleStretch(0)
					x = x * 0.25
					c = c * 4
				else
					ParticleType("smoke")
					ParticleGravity(-0.1)
					ParticleDrag(0, 1, "easeout")
					ParticleStretch(1, 0, "easein")
					ParticleColor(sr * 0.5 + 0.3, sg * 0.5 + 0.275, sb * 0.5 + 0.25)
					ParticleAlpha(sa, 0, "easein")
					ParticleRadius(0.1, c, "easeout")
					c = c * 2
				end
				ParticleTile(switches[shape] or 0)
			else
				ParticleType("smoke")
				ParticleDrag(0, 1, "easeout")
				ParticleStretch(1, 0, "easein")
				ParticleGravity(-0.1)
				ParticleColor(0.6, 0.55, 0.5)
				ParticleAlpha(1, 0, "easein")
				ParticleRadius(0.1, c, "easeout")
				c = c * 2
			end
			for _ = x, 1, -1 do
				SpawnParticle(addrndVec(tc), s, random() * c)
			end
		end
		if not IsHandleValid(body) then return end
		if a < 128 and i > 1.5 then return SetTag(body, "likely_unbreakable", GetBodyVoxelCount(body)) end
		if i > 5 then
			co_yield(true)
			s = GetBodyVelocity(body)
		end
	end
end

-- Enhanced IBSIT v2.0 Functions

-- Calculate structural integrity percentage
local function calculateStructuralIntegrity_ibsit(body)
    if not IsHandleValid(body) then return 0 end

    local originalVoxelCount = GetBodyVoxelCount(body)
    local currentVoxelCount = 0

    -- Count remaining voxels in all shapes
    local shapes = GetBodyShapes(body)
    for i = 1, #shapes do
        currentVoxelCount = currentVoxelCount + GetShapeVoxelCount(shapes[i])
    end

    -- Store original count if not already stored
    if not ibsit_structuralIntegrity[body] then
        ibsit_structuralIntegrity[body] = {original = originalVoxelCount, current = currentVoxelCount}
    else
        ibsit_structuralIntegrity[body].current = currentVoxelCount
    end

    local integrity = currentVoxelCount / ibsit_structuralIntegrity[body].original
    return math.max(0, math.min(1, integrity)) -- Clamp between 0 and 1
end

-- Apply gravity collapse forces
local function applyGravityCollapse_ibsit(body, integrity)
    if not ibsit_gravityCollapse or integrity > ibsit_collapseThreshold then return end

    local collapseSeverity = (ibsit_collapseThreshold - integrity) / ibsit_collapseThreshold
    local force = VecScale({0, -1, 0}, ibsit_gravityForce * collapseSeverity * 1000)

    -- Apply force at multiple points for realistic collapse
    local bounds = GetBodyBounds(body)
    local center = GetBodyCenterOfMass(body)

    -- Apply force at center and corners for structural failure simulation
    ApplyBodyImpulse(body, center, force)

    -- Additional forces at structural weak points
    local corners = {
        {bounds[1], bounds[2], bounds[3]},
        {bounds[4], bounds[2], bounds[3]},
        {bounds[1], bounds[5], bounds[3]},
        {bounds[4], bounds[5], bounds[3]}
    }

    for i = 1, #corners do
        local cornerForce = VecScale(force, 0.3) -- Reduced force at corners
        ApplyBodyImpulse(body, corners[i], cornerForce)
    end

    -- Add cascading damage for severe structural failure
    if integrity < ibsit_collapseThreshold * 0.5 then
        SetTag(body, "cascade_damage", "true")
    end
end

-- Debris cleanup system
local function cleanupDebris_ibsit()
    if not ibsit_debrisCleanup then return end

    local currentTime = GetTime()

    -- Find and tag debris for cleanup
    local debrisBodies = FindBodies(nil, true)
    for i = 1, #debrisBodies do
        local body = debrisBodies[i]
        if IsHandleValid(body) and not IsBodyActive(body) then
            if not ibsit_debrisTimers[body] then
                ibsit_debrisTimers[body] = currentTime
            elseif currentTime - ibsit_debrisTimers[body] > ibsit_cleanupDelay then
                -- Mark for removal
                SetTag(body, "cleanup", "true")
                ibsit_debrisTimers[body] = nil
            end
        end
    end

    -- Remove marked debris
    local cleanupBodies = FindBodies("cleanup", true)
    for i = 1, #cleanupBodies do
        if IsHandleValid(cleanupBodies[i]) then
            Delete(cleanupBodies[i])
        end
    end
end

-- FPS-based performance optimization
local function optimizePerformance_ibsit()
    if not ibsit_fpsOptimization then return end

    local frameTime = GetTime() - ibsit_lastFrameTime
    ibsit_currentFPS = 1 / frameTime
    ibsit_lastFrameTime = GetTime()

    -- Adjust performance scale based on FPS
    if ibsit_currentFPS < ibsit_targetFPS then
        ibsit_performanceScale = math.max(0.1, ibsit_performanceScale * 0.95) -- Reduce performance
    elseif ibsit_currentFPS > ibsit_targetFPS + 5 then
        ibsit_performanceScale = math.min(1.0, ibsit_performanceScale * 1.02) -- Increase performance
    end

    -- Apply performance scaling
    if ibsit_performanceScale < 0.8 then
        -- Reduce particle effects
        ibsit_particleQuality = math.max(0, ibsit_particleQuality - 1)
    elseif ibsit_performanceScale > 0.9 then
        -- Restore particle effects
        ibsit_particleQuality = math.min(2, ibsit_particleQuality + 1)
    end
end

-- Enhanced particle system with new API features
local function createEnhancedParticles_ibsit(material, position, velocity, intensity)
    if not ibsit_particles_enabled then return end

    ParticleReset()

    if material == "metal" or material == "hardmetal" then
        ParticleType("plain")
        ParticleColor(1, 0.4, 0.3)
        ParticleAlpha(1, 0, "easein")
        ParticleRadius(0.03, 0.08, "easeout")
        ParticleEmissive(5, 0, "easeout")
        ParticleGravity(-15)
        ParticleSticky(0.3)
        ParticleStretch(0)
        intensity = intensity * 0.25
    elseif material == "wood" or material == "foliage" then
        ParticleType("smoke")
        ParticleColor(0.4, 0.3, 0.2)
        ParticleAlpha(0.8, 0, "easein")
        ParticleRadius(0.1, 0.3, "easeout")
        ParticleGravity(-0.2)
        ParticleDrag(0, 1, "easeout")
        ParticleStretch(1, 0, "easein")
    else
        ParticleType("smoke")
        ParticleColor(0.6, 0.55, 0.5)
        ParticleAlpha(1, 0, "easein")
        ParticleRadius(0.1, 0.25, "easeout")
        ParticleGravity(-0.1)
        ParticleDrag(0, 1, "easeout")
        ParticleStretch(1, 0, "easein")
    end

    -- Quality-based particle count
    local particleCount = intensity * (ibsit_particleQuality + 1)
    for i = 1, particleCount do
        SpawnParticle(
            VecAdd(position, addrangedVec(0.5)),
            velocity,
            random() * 2
        )
    end

    ibsit_performanceStats.particles_spawned = ibsit_performanceStats.particles_spawned + particleCount
end

-- Enhanced sound system
local function playStructuralSound_ibsit(intensity, material)
    if not ibsit_sounds_enabled then return end

    local soundType
    if intensity > 1000 then
        soundType = "collapse_heavy"
    elseif intensity > 500 then
        soundType = "structure_stress"
    else
        soundType = "collapse_light"
    end

    PlaySound("MOD/sounds/" .. soundType .. ".ogg", ibsit_volume_level)
end

-- Enhanced haptic feedback
local function triggerHapticFeedback_ibsit(intensity)
    if not ibsit_haptic_enabled then return end

    if intensity > 1000 then
        PlayHaptic("MOD/haptic/impact_heavy.xml", 1.0)
    else
        PlayHaptic("MOD/haptic/impact_light.xml", 0.7)
    end
end

-- Enhanced breaking function with new shape manipulation
local function enhancedBreaks_ibsit(body, c, s, a)
    local sr, sg, sb, sa, tc, shape
    local totalHoles = 0

    for i = sqrt(a), 0, -5 do
        _, tc = GetBodyClosestPoint(body, tc and addrangedVec(tc, 5.5) or c)

        -- Use new shape material detection
        shape, sr, sg, sb, sa = GetShapeMaterialAtPosition(GetBodyShapes(body)[1], tc)

        -- Enhanced hole creation with material-specific damage
        local materialMult = materialMultipliers[shape] or 1.0
        local holeSize = MakeHole(tc, wb_ibsit * i * materialMult, mb_ibsit * i * materialMult, hb_ibsit * i * materialMult)

        if holeSize > dust_ibsit then
            local x
            if holeSize < 4096 then
                x = holeSize * rdust_ibsit
            else
                x = fdust_ibsit
            end

            -- Enhanced particle effects
            createEnhancedParticles_ibsit(shape, tc, s, x)

            -- Play appropriate sound
            playStructuralSound_ibsit(holeSize, shape)

            -- Trigger haptic feedback
            triggerHapticFeedback_ibsit(holeSize)
        end

        totalHoles = totalHoles + 1
        ibsit_performanceStats.holes_created = ibsit_performanceStats.holes_created + 1

        if not IsHandleValid(body) then return end
        if holeSize < 128 and i > 1.5 then return end

        if i > 5 then
            co_yield(true)
            s = GetBodyVelocity(body)
        end
    end
end

-- MBCS: Breaks function
local function breaks_mbcs(shape, x, n, c)
	local sr, sg, sb, sa, e, tc
	for i = sqrt(x * rthreshold_mbcs), 0, -5 do
		if tc then
			_, tc, n = GetShapeClosestPoint(shape, addrangedVec(tc, 5.5))
		else
			tc = c
		end
		e, sr, sg, sb, sa = GetShapeMaterialAtPosition(shape, tc)
		x = MakeHole(tc, wb_mbcs * i, mb_mbcs * i, hb_mbcs * i)
		if x > dust_mbcs then
			if x < 4096 then
				x, c = x * rdust_mbcs, x * sratio
			else
				x, c = fdust_mbcs, 3
			end
			ParticleReset()
			if e ~= "" then
				if e == "metal" or e == "hardmetal" then
					ParticleAlpha(1, 0)
					ParticleRadius(0.03, 0.0, "easein")
					ParticleEmissive(5, 0, "easeout")
					ParticleColor(1, 0.4, 0.3)
					ParticleGravity(-10)
					ParticleSticky(0.2)
					ParticleStretch(0)
					x = x * 0.25
					c = 10
				else
					ParticleType("smoke")
					ParticleGravity(-0.1)
					ParticleDrag(0, 1, "easeout")
					ParticleStretch(1, 0, "easein")
					ParticleColor(sr * 0.5 + 0.3, sg * 0.5 + 0.275, sb * 0.5 + 0.25)
					ParticleAlpha(sa, 0, "easein")
					ParticleRadius(0.1, c, "easeout")
					c = 5
				end
				ParticleTile(switches[e] or 0)
			else
				ParticleType("smoke")
				ParticleDrag(0, 1, "easeout")
				ParticleStretch(1, 0, "easein")
				ParticleGravity(-0.1)
				ParticleColor(0.6, 0.55, 0.5)
				ParticleAlpha(1, 0, "easein")
				ParticleRadius(0.1, c, "easeout")
				c = 5
			end
			for _ = x, 1, -1 do
				SpawnParticle(addrndVec(tc), addrndVec(n), random() * c)
			end
		end
		if not IsHandleValid(shape) then return end
		if i > 5 then
			co_yield(true)
		end
	end
end

-- PDM: Violence function
function Violence(body)
	local vector_vel = GetBodyVelocity(body)
	local vector_len = VecLength(vector_vel)
	if vector_len > -1 and vector_len < 100 then
		local mass = GetBodyMass(body)
		if mass > (viol_minmass / 8) and mass < (viol_maxmass * 10) then
			if math.random() < (viol_chance / 600) then
				local screw_quaternions = GetBodyVelocity(body)
				local angle_force = viol_mover
				angle_force = angle_force * angle_force
				angle_force = angle_force * 0.02
				local they_are_evil = Vec((0.5-math.random())*angle_force, (0.5-math.random())*angle_force, (0.5-math.random())*angle_force)
				local AnglesForever = VecAdd(screw_quaternions, they_are_evil)
				SetBodyVelocity(body, AnglesForever)

				local screw_quaternions2 = GetBodyAngularVelocity(body)
				local angle_force2 = viol_turnr
				angle_force2 = angle_force2 * angle_force2
				angle_force2 = angle_force2 * 0.02
				local they_are_evil2 = Vec((0.5-math.random())*angle_force2, (0.5-math.random())*angle_force2, (0.5-math.random())*angle_force2)
				local AnglesForever2 = VecAdd(screw_quaternions2, they_are_evil2)
				SetBodyAngularVelocity(body, AnglesForever2)
			end
		end
	end
end

-- Initialize function
function init()
	-- Initialize additional tools
	if integrity_scanner_init then integrity_scanner_init() end

	if not HasKey("savegame.mod.combined") then
		-- Set default values for combined mod
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
	end

	-- Initialize all settings to defaults if first time
	if not HasKey("savegame.mod.combined") then
		ResetAllSettings()
	end

	-- IBSIT initialization (Enhanced v2.0)
	if TOG_IMPACT then
		local shapes = GetBodyShapes(GetWorldBody())
		for shape = #shapes, 1, -1 do
			shape = shapes[shape]
			if not IsShapeDisconnected(shape) then
				SetTag(shape, "inherittags")
				SetTag(shape, "parent_shape", shape)
			end
		end

		-- Load enhanced sound effects
		if ibsit_sounds_enabled then
			LoadSound("MOD/sounds/collapse_heavy.ogg")
			LoadSound("MOD/sounds/collapse_light.ogg")
			LoadSound("MOD/sounds/structure_stress.ogg")
		end

		-- Load haptic effects
		if ibsit_haptic_enabled then
			LoadHaptic("MOD/haptic/impact_light.xml")
			LoadHaptic("MOD/haptic/impact_heavy.xml")
		end
	end

	-- MBCS initialization
	if TOG_MASS then
		local shapes = GetBodyShapes(GetWorldBody())
		for shape = #shapes, 1, -1 do
			shape = shapes[shape]
			if not IsShapeDisconnected(shape) then
				SetTag(shape, "inherittags")
				SetTag(shape, "parent_shape", shape)
			end
		end
	end

	collapse_timer = 0.0
	automode = false
	if TOG_FORCE then
		if GetBool("savegame.mod.combined.force_START_ON") then
			automode = true
		end
	end

	CurrencyPick()

	-- gravity collapse init (safe if module absent)
	if gravity_collapse_init then pcall(gravity_collapse_init) end
end

-- Utility functions
function rndVec(length)
	local v = VecNormalize(Vec(math.random(-100,100), math.random(-100,100), math.random(-100,100)))
	return VecScale(v, length)
end

function rnd(mi, ma)
	return math.random(1000)/1000*(ma-mi) + mi
end

function financial_roundup(var)
	var = math.floor(0.5 + (var))
	var = var / 100
	return var
end

function CurrencyPick()
	local CURR = "£"
	local Ratio = 1
	if GetInt("savegame.mod.combined.DAMSTAT_Currency") == 2 then
		CURR = "EUR"
		Ratio = 1.17
	elseif GetInt("savegame.mod.combined.DAMSTAT_Currency") == 3 then
		CURR = "JPY"
		Ratio = 151.81
	end
	-- Add more currencies as needed
end

-- Draw function
function draw(dt)
	UiFont("bold.ttf", 20)
	UiAlign("right middle")
	UiColor(1,1,1)
	if GetBool("savegame.mod.combined.force_CONTROL_TIPS") then
		UiPush()
		UiTranslate(UiWidth() - 10, UiHeight() - 100)
		UiText("Force: use . to turn off/on and M to freeze position")
		UiPop()
		UiPush()
		UiTranslate(UiWidth() - 10, UiHeight() - 75)
		UiText("(also use , to show/hide the direction marker)")
		UiPop()
	end

	-- Draw options menu if visible
	if optionsVisible then
		UiMakeInteractive()
		DrawOptionsMenu()
	end

	-- Draw scanner visuals if provided
	if integrity_scanner_draw then integrity_scanner_draw() end

	-- Draw gravity collapse debug overlay if provided
	if gravity_collapse_draw then pcall(gravity_collapse_draw) end

	-- Debug overlay for gravity collapse integrity
	if GetBool("savegame.mod.combined.gravitycollapse_debug") then
		local bodies = FindBodies()
		for i = 1, #bodies do
			local body = bodies[i]
			if IsHandleValid(body) and IsBodyActive(body) then
				local integrity = calculateStructuralIntegrity_ibsit(body)
				if integrity < 0.9 then
					local center = GetBodyCenterOfMass(body)
					if center then
						UiPush()
						UiTranslate(UiWidth() / 2, UiHeight() / 2)
						local screenPos = UiWorldToScreen(center)
						if screenPos then
							UiTranslate(screenPos.x - UiWidth() / 2, screenPos.y - UiHeight() / 2)
							UiColor(1, 0, 0)
							UiText(string.format("Integrity: %.2f", integrity))
						end
						UiPop()
					end
				end
			end
		end
	end
end

-- Tick function - Main game loop
function tick(dt)
	-- PANIC BUTTON
	if InputDown("-") then
		local maxDist = 100
		local mi = VecAdd(GetPlayerTransform().pos, Vec(-maxDist*2, -maxDist*2, -maxDist*2))
		local ma = VecAdd(GetPlayerTransform().pos, Vec(maxDist*2, maxDist*2, maxDist*2))
		QueryRequire("physical dynamic")
		local bodies = QueryAabbBodies(mi, ma)
		for i = 1, #bodies do
			local b = bodies[i]
			if IsBodyBroken(b) then
				Delete(b)
			end
		end
	end

	-- Reset tick counters
	crumbled_this_tick = 0
	smoked_this_tick = 0
	exploded_this_tick = 0

	frames = frames + 1
	local seconds_now = GetTime()
	if seconds_now - FPS_marker > 1 then
		FPS_marker = seconds_now
		framesPerSecond = frames
		frames = 1
	end

	-- Handle force controls
	if InputPressed(".") and GetBool("savegame.mod.combined.force_ENABLE_CONTROLS") then
		automode = not automode
	end
	if InputPressed("m") and GetBool("savegame.mod.combined.force_ENABLE_CONTROLS") then
		windrotstop = not windrotstop
		if windstoptime == 0 then
			windstoptime = GetTime()
			windrotoffset = windrotoffset + GetTime()
		end
	end

	if windrotstop == false then
		windstoptime = 0
	end

	-- Add pause menu button for options
	if PauseMenuButton("Physics Mod Settings") then
		optionsVisible = true
		SetPaused(true)  -- Keep game paused while in options
	end

	-- Call main functions
	callFunctions()

	-- gravity collapse tick
	if gravity_collapse_tick then pcall(gravity_collapse_tick, dt) end

	-- saved popup timer update
	if savedPopupTimer and savedPopupTimer > 0 then
		savedPopupTimer = savedPopupTimer - dt
	end

	-- Run scanner tick
	if integrity_scanner_tick then integrity_scanner_tick(dt) end

	-- IBSIT processing (Enhanced v2.0)
	if TOG_IMPACT and not ibsit_triggered then
		if ibsit_last_frame then
			ibsit_cached_breaksize, ibsit_cached_breakpoint, ibsit_last_frame = ibsit_cached_breaksize, ibsit_cached_breakpoint, false
		end
		if HasKey("game.explosion") then
			ibsit_cached_breaksize, ibsit_cached_breakpoint, ibsit_last_frame = GetFloat("game.explosion.strength") * 2.2, {GetFloat("game.explosion.x"), GetFloat("game.explosion.y"), GetFloat("game.explosion.z")}, true
		end
		if HasKey("game.break") then
			local breaksize, breakpoint = GetFloat("game.break.size")
			if ibsit_cached_breaksize then
				if ibsit_cached_breaksize > breaksize then
					breaksize, breakpoint = ibsit_cached_breaksize, ibsit_cached_breakpoint
				else
					breakpoint = {GetFloat("game.break.x"), GetFloat("game.break.y"), GetFloat("game.break.z")}
				end
				ibsit_cached_breaksize = nil
			else
				breakpoint = {GetFloat("game.break.x"), GetFloat("game.break.y"), GetFloat("game.break.z")}
			end

			-- Enhanced query system
			if ibsit_vehicle_enabled then
				local vehList = GetPlayerVehicle()
				if vehList ~= 0 then
					vehList = GetVehicleBodies(vehList)
					for i = #vehList, 1, -1 do
						QueryRequire("physical dynamic large")
						vehList[i] = QueryAabbBodies(GetBodyBounds(vehList[i]))
					end
					for i = #vehList, 1, -1 do
						QueryRejectBodies(vehList[i])
					end
				end
				vehList = FindVehicles(nil, true)
				for i = #vehList, 1, -1 do
					QueryRejectVehicle(vehList[i])
				end
			end

			if ibsit_protect_enabled then QueryRejectBodies(FindBodies("leave_me_alone", true)) end

			-- Update object list with enhanced bounds
			QueryRequire("physical dynamic large")
			local bodies = QueryAabbBodies(
				{breakpoint[1] - breaksize, breakpoint[2] - breaksize, breakpoint[3] - breaksize},
				{breakpoint[1] + breaksize, breakpoint[2] + breaksize, breakpoint[3] + breaksize}
			)

			for body = #bodies, 1, -1 do
				body = bodies[body]
				if not ibsit_time[body] and IsBodyBroken(body) and IsBodyActive(body) then
					local dist = GetBodyVoxelCount(body)
					local tr = GetBodyTransform(body)
					local lp = TransformToLocalPoint(tr, breakpoint)
					dist = VecLength(VecSub(lp, GetBodyCenterOfMass(body))) < dist

					if dist or VecLength(GetBodyVelocity(body)) * GetBodyMass(body) > threshold_ibsit then
						SetTag(body, "spd")
						ibsit_pos[body], ibsit_pos[-body], ibsit_vel[-body], ibsit_time[body], ibsit_time[-body], ibsit_ind = lp, dist and tr.pos or breakpoint, dist, true, 1, true
					end
				end
			end
		end
	end

	-- MBCS processing
	if TOG_MASS and not mbcs_triggered then
		if last_frame then
			available_breaksize, available_breakpoint, last_frame = cached_breaksize, cached_breakpoint, false
		end
		if HasKey("game.explosion") then
			cached_breaksize, cached_breakpoint, last_frame = GetFloat("game.explosion.strength") * 2.2, {GetFloat("game.explosion.x"), GetFloat("game.explosion.y"), GetFloat("game.explosion.z")}, true
		end
		if HasKey("game.break") then
			local breaksize, breakpoint = GetFloat("game.break.size")
			if available_breaksize then
				if available_breaksize > breaksize then
					breaksize, breakpoint = available_breaksize, available_breakpoint
				else
					breakpoint = {GetFloat("game.break.x"), GetFloat("game.break.y"), GetFloat("game.break.z")}
				end
				available_breaksize = nil
			else
				breakpoint = {GetFloat("game.break.x"), GetFloat("game.break.y"), GetFloat("game.break.z")}
			end

			local watch, bodies = {}
			local min, max = {breakpoint[1] - breaksize, breakpoint[2] - breaksize, breakpoint[3] - breaksize}, {breakpoint[1] + breaksize, breakpoint[2] + breaksize, breakpoint[3] + breaksize}
			QueryRequire("physical static large")
			local shapes = QueryAabbShapes(min, max)
			for shape = #shapes, 1, -1 do
				shape = shapes[shape]
				local breaksize_tag = tonumber(GetTagValue(shape, "parent_shape"))
				if not breaksize_tag or breaksize_tag ~= shape then
					SetTag(shape, "parent_shape", shape)
					SetTag(shape, "inherittags")
				else
					watch[shape] = IsShapeBroken(shape)
				end
			end
			QueryRequire("physical dynamic large")
			bodies = QueryAabbBodies(min, max)
			for body = #bodies, 1, -1 do
				body = bodies[body]
				if shp[body] == nil and IsBodyBroken(body) and IsBodyActive(body) and VecLength(GetBodyVelocity(body)) < 5 then
					local breaksize_found, breakpoint_shapes = false, GetEntityChildren(body, "parent_shape", true, "shape")
					for shape = #breakpoint_shapes, 1, -1 do
						shape = breakpoint_shapes[shape]
						local tgt = tonumber(GetTagValue(shape, "parent_shape"))
						if watch[tgt] then
							breaksize_found, shp[shape], shp[tgt] = true, tgt, GetShapeBody(tgt)
						end
					end
					if breaksize_found then
						shp[body], ind_mbcs = TransformToParentPoint(GetBodyTransform(body), GetBodyCenterOfMass(body)), true
						SetTag(body, "val", "uninit")
					else
						shp[body] = false
					end
				end
			end
		end
	end

	-- Performance and damage statistics
	if reee_counter > 2 and TOG_DAMSTAT then
		for a = 1, 25 do
			DebugPrint(" ")
		end
		local d = GetInt("game.brokenvoxels")
		d = d * 20
		local destroyed_level_percentage = financial_roundup(d)
		local act_DMG = destroyed_level_percentage
		local dmg_this_update = destroyed_level_percentage - old_dam
		old_dam = destroyed_level_percentage
		if (destroyed_level_percentage * Ratio) < 1000000 then
			DebugPrint("Cost of all damage: £ " .. destroyed_level_percentage)
		end
		reee_counter = 0
	end

	hole_count = 0
	collapse_timer = collapse_timer - (((0.4 - ((radegast_12) * 0.006))) * (dt))

	-- Main processing loop
	if GetTime() > 2 and (TOG_CRUMBLE or TOG_RUMBLE or TOG_DUST or TOG_VIOLENCE) then
		if ((collapse_timer <= 0.0) and (GetInt("savegame.mod.combined.crum_MODE") == 0)) or ((GetInt("savegame.mod.combined.crum_MODE") == 1) and (alternate_crumble_min_frequency < GetTime())) then
			if crum_speed > 15 then
				alternate_crumble_min_frequency = GetTime() + (0.02 * ((23 - crum_speed)))
			end
			if crum_speed < 16 then
				alternate_crumble_min_frequency = GetTime() + (0.03 * ((23 - crum_speed)))
			end
			if crum_speed < 8 then
				alternate_crumble_min_frequency = GetTime() + (0.04 * ((23 - crum_speed)))
			end
			if crum_speed < -2 then
				alternate_crumble_min_frequency = GetTime() + (0.5 * ((23 - crum_speed)))
			end

			collapse_timer = ((radegast_12) * 0.013) * (1 + (0.5 - math.random()) * (GetInt("savegame.mod.combined.crum_spdRND") * 0.015))

			QueryRequire("physical dynamic")
			local list = QueryAabbShapes(Vec(-maxDist, -maxDist, -maxDist), Vec(maxDist, maxDist, maxDist))
			local count = 0

			for i = 1, #list do
				local shape = list[i]
				local body = GetShapeBody(shape)
				local is_vehicle = GetBodyVehicle(body)

				local dir = VecLength(VecSub(GetBodyTransform(body).pos, GetPlayerTransform().pos))
				local body_dyst_from_plyr = dir
				local mode = GetInt("savegame.mod.combined.viol_mode")

				if TOG_VIOLENCE and body_dyst_from_plyr < GetInt("savegame.mod.combined.viol_maxdist") then
					if is_vehicle == 0 then
						if body and IsBodyBroken(body) and mode == 1 then
							Violence(body)
						end
						if body and mode == 2 then
							Violence(body)
						end
					end
					if body and is_vehicle > 0 and mode == 3 then
						Violence(body)
					end
					if body and mode == 4 then
						Violence(body)
					end
				end

				if body then
					local mass = GetBodyMass(body)
					local broken = IsBodyBroken(body)
					local vector_vel = GetBodyVelocity(body)
					local vector_len = VecLength(vector_vel)

					if TOG_CRUMBLE and no_more_holes_until < GetTime() then
						local wood_breakage = (crum_DMGLight * (mass * 0.008))
						local stone_breakage = (crum_DMGMed * (mass * 0.008))
						local metal_breakage = (crum_DMGHeavy * (mass * 0.008))

						if (broken == true or GetInt("savegame.mod.combined.crum_Source") == 1) then
							if ((mass > (crum_MinMass / 8)) and (vector_len > ((crum_MinSpd) / 20)) and (vector_len < ((crum_MaxSpd)))) then
								if (((wood_breakage * crum_dist / 500) + (stone_breakage * crum_dist / 500) + (metal_breakage * crum_dist / 500)) > (0.25 * crum_dist)) then
									crumbled_this_tick = crumbled_this_tick + 1
									MakeHole(GetBodyTransform(body).pos, wood_breakage * crum_dist / 500, stone_breakage * crum_dist / 500, metal_breakage * crum_dist / 500)
									hole_count = hole_count + 1
								end
							end
						end
					end

					if TOG_RUMBLE and (mass * 1) > crum_MinMass and mass < crum_MaxMass and vector_len > crum_MinSpd and vector_len < crum_MaxSpd and no_more_boom_until < GetTime() and exploded_this_tick == 0 then
						if (GetInt("savegame.mod.combined.xplo_mode") == 1 and broken == true) or GetInt("savegame.mod.combined.xplo_mode") == 2 or (GetInt("savegame.mod.combined.xplo_mode") == 3 and is_vehicle > 0) then
							if (math.random() < (xplo_chance / 200)) then
								if body_dyst_from_plyr < xplo_distFromPlyr then
									exploded_this_tick = exploded_this_tick + 1
									local BOOM_SIZE = (xplo_szBase / 5) + (math.random() * (xplo_szRnd / 5))
									Explosion(GetBodyTransform(body).pos, BOOM_SIZE)
								end
							end
						end
					end

					if dust_amt > 0 and TOG_DUST and mass > dust_minMass and (vector_len > dust_minSpeed / 2) then
						if crum_speed < 17 or (crum_speed > 16 and (math.random() < (0.5 - ((crum_speed - 16) * 0.02)))) then
							if (GetInt("savegame.mod.combined.crum_MODE") == 1 and smoked_this_tick < max_smokes_per_tick) or GetInt("savegame.mod.combined.crum_MODE") == 0 then
								local mi, ma = GetShapeBounds(shape)
								local c = VecLerp(mi, ma, math.random() / 1)
								ParticleReset()
								ParticleType("smoke")
								ParticleColor(.5, .5, .5)
								ParticleDrag(dust_drag * 0.01)
								ParticleGravity(dust_grav * 0.01)
								for i = dust_amt, 1, -1 do
									if (math.random() * 100) < (25 + (radegast_12)) then
										local val = dust_size * 0.25
										if dust_szvar > 0 then
											val = val * (1 + (math.random() * (dust_szvar * 0.01)))
										end
										if dust_szMB > 0 then
											val = val * (1 + ((mass / 12000) * (1 + (dust_szMB * 0.01))))
										end
										local spread = math.floor(math.random() * (1000 - 1) + 1000) / 10000
										local v = VecScale(VecAdd(spread, rndVec(0.2)), 2)
										v = VecAdd(v, VecScale(GetBodyVelocityAtPos(body, c)))
										local val2 = dust_life * 0.5
										if dust_lifernd > 0 then
											val2 = val2 + ((dust_life * 0.5) * (math.random() * (dust_lifernd / 100)))
										end
										if dust_MsBsLf >= 1 then
											local MassBased = (dust_MsBsLf * 0.01)
											if MassBased > 1 then
												MassBased = 1
											end
											val2 = val2 + MassBased
										end
										ParticleRadius((val / 2) * (GetInt("savegame.mod.combined.dust_startsize") / 10), (val / 2))
										ParticleAlpha(1, 0, "linear", (GetInt("savegame.mod.combined.dust_fader") / 1000), 0.05)
										SpawnParticle(c, v, val2)
										if GetInt("savegame.mod.combined.crum_MODE") == 1 then
											smoked_this_tick = smoked_this_tick + 1
										end
									end
								end
							end
						end
					end
				end
			end
		end
	end

	if collapse_timer <= 0.0 and not GetBool("savegame.mod.combined.instant") then
		collapse_timer = 0
	end
	historical_hole_count = historical_hole_count + hole_count
	historical_boom_count = historical_boom_count + exploded_this_tick
	hole_count = 0
end

-- Update function
function update()
	if ibsit_ind then
		ibsit_gcl = FindBodies("spd", true)
		if #ibsit_gcl == 0 then
			ibsit_vel, ibsit_pos, ibsit_time, ibsit_ind = {}, {}, {}, false
			return
		end

		for i = #ibsit_gcl, 1, -1 do
			local body = ibsit_gcl[i]
			if IsHandleValid(body) then
				local val = GetTagValue(body, "spd")
				if val == "uninit" then
					val = ibsit_vel[-body] and GetBodyTransform(body).pos or TransformToParentPoint(GetBodyTransform(body), ibsit_pos[body])
					if VecLength(VecSub(val, ibsit_pos[-body])) > 0.125 then
						ibsit_vel[body] = ibsit_vel[-body] and GetBodyVelocity(body) or GetBodyVelocityAtPos(body, val)
						SetTag(body, "spd", "calc")
					end
				elseif val == "" then
					SetTag(body, "spd", "uninit")
				elseif val == "gc" then
					ibsit_vel[body], ibsit_vel[-body], ibsit_time[body], ibsit_time[-body], ibsit_pos[body], ibsit_pos[-body], val = RemoveTag(body, "spd"), nil, nil, nil, nil, nil, #ibsit_gcl
					ibsit_gcl[i] = ibsit_gcl[val]
					ibsit_gcl[val] = nil
				end
			else
				ibsit_vel[body], ibsit_vel[-body], ibsit_time[body], ibsit_time[-body], ibsit_pos[body], ibsit_pos[-body] = nil, nil, nil, nil, nil, nil
			end
		end

		-- Process coroutines
		for co = #ibsit_breaklist, 1, -1 do
			local _, ret = co_resume(ibsit_breaklist[co])
			if ret ~= true then
				ret = #ibsit_breaklist
				ibsit_breaklist[co] = ibsit_breaklist[ret]
				ibsit_breaklist[ret] = nil
			end
		end
	end

	if ind_mbcs then
		gcl = FindBodies("val", true)
		if #gcl == 0 then shp, ind_mbcs = {}, false; return end
		for i = #gcl, 1, -1 do
			local body = gcl[i]
			local val = GetTagValue(body, "val")
			if val == "uninit" then
				shp[body], ind_mbcs = TransformToParentPoint(GetBodyTransform(body), GetBodyCenterOfMass(body)), true
				SetTag(body, "val", "calc")
			elseif val == "gc" then
				local val_shapes = GetEntityChildren(body, "parent_shape", true, "shape")
				for shape = #val_shapes, 1, -1 do
					RemoveTag(val_shapes[shape], "parent_shape")
				end
				shp[body], val = RemoveTag(body, "val"), gcl
				gcl[i] = gcl[val]
				gcl[val] = nil
			end
		end
		for co = #mbcs_breaklist, 1, -1 do
			local _, ret = coroutine.resume(mbcs_breaklist[co])
			if ret ~= true then
				ret = #mbcs_breaklist
				mbcs_breaklist[co] = mbcs_breaklist[ret]
				mbcs_breaklist[ret] = nil
			end
		end
	end

	-- gravity collapse update
	if gravity_collapse_update then pcall(gravity_collapse_update, dt) end
end

-- PostUpdate function
function postUpdate()
	if ibsit_ind then
		-- Run performance optimization
		optimizePerformance_ibsit()

		-- Run debris cleanup
		cleanupDebris_ibsit()

		for body = #ibsit_gcl, 1, -1 do
			body = ibsit_gcl[body]
			if IsHandleValid(body) then
				local val = GetTagValue(body, "spd")
				if val == "calc" then
					local c, s
					if ibsit_vel[-body] then
						c, s = GetBodyTransform(body).pos, GetBodyVelocity(body)
					else
						c = TransformToParentPoint(GetBodyTransform(body), ibsit_pos[body])
						s = GetBodyVelocityAtPos(body, c)
					end

					if VecLength(s) < 32 then
						local a = VecSub(ibsit_vel[body], s)
						if VecDot(a, ibsit_vel[body]) > 0.0678 then
							local sa = GetBodyMass(body)
							a, val = VecLength(a) * sa, GetBodyVoxelCount(body)

							if sa < val * 0.5 or val * 10 < sa then
								a = a * 0.015625
							end

							if ibsit_pos[-body] then
								sa = VecLength(VecSub(c, ibsit_pos[-body]))
								if sa < 0.5 then
									a = a * sa * 2
								else
									ibsit_pos[-body] = nil
								end
							end

							if a > threshold_ibsit then
								if ibsit_vel[-body] then
									c = TransformToParentPoint(GetBodyTransform(body), ibsit_pos[body])
								end

								sa = co_create(enhancedBreaks_ibsit)
								_, val = co_resume(sa, body, c, s, a * rthreshold_ibsit - 4)
								if val == true then
									ibsit_breaklist[#ibsit_breaklist + 1] = sa
									val = GetBodyVoxelCount(body)
									if val > 1024 * ibsit_time[-body] or VecLength(s) * GetBodyMass(body) > threshold_ibsit * ibsit_time[-body] then
										sa = VecLerp(c, rndPnt(GetBodyBounds(body)), random())
										val = log(val + 1)
										c = GetBodyTransform(body)
										s = TransformToLocalPoint(c, sa)
										val = VecLength(VecSub(s, GetBodyCenterOfMass(body))) < val
										ibsit_pos[body], ibsit_pos[-body], ibsit_vel[-body], ibsit_time[body], ibsit_time[-body] = s, val and c.pos or sa, val, true, ibsit_time[-body] + 1
										SetTag(body, "spd", "uninit")
										sa = nil
									end
								end
								if sa then
									SetTag(body, "spd", "gc")
								end
							else
								ibsit_vel[body] = s
							end
						else
							ibsit_vel[body], ibsit_time[body] = s, false
						end
					else
						SetTag(body, "autobreak")
						SetTag(body, "spd", "hs")
						ibsit_vel[body] = s
					end

					-- Apply gravity collapse effects
					local integrity = calculateStructuralIntegrity_ibsit(body)
					applyGravityCollapse_ibsit(body, integrity)

				elseif val == "hs" then
					val = ibsit_vel[-body] and GetBodyVelocity(body) or GetBodyVelocityAtPos(body, TransformToParentPoint(GetBodyTransform(body), ibsit_pos[body]))
					if VecLength(val) < 32 then
						RemoveTag(body, "autobreak")
						SetTag(body, "spd", "calc")
					end
					ibsit_vel[body] = val
				end
			else
				ibsit_vel[body], ibsit_vel[-body], ibsit_time[body], ibsit_time[-body], ibsit_pos[body], ibsit_pos[-body] = nil, nil, nil, nil, nil, nil
			end
		end
	end

	-- Scanner-driven progressive collapse integration
	-- If scanner tags a body with scanner_stress and scanner_autobreak is enabled,
	-- call IBSIT collapse logic so material-aware breaking and gravity collapse happens.
	if GetBool("savegame.mod.combined.scanner_autobreak") then
		local tagged = FindBodies("scanner_stress", true)
		for i = #tagged, 1, -1 do
			local b = tagged[i]
			if IsHandleValid(b) and IsBodyActive(b) then
				local stressStr = GetTagValue(b, "scanner_stress")
				if stressStr then
					local stressVal = tonumber(stressStr) or 0
					-- Only trigger collapse if stress is above threshold (use scanner_threshold)
					local thresh = GetFloat("savegame.mod.combined.scanner_threshold") or 0.9
					if stressVal >= thresh then
						-- compute integrity and apply collapse forces
						local integrity = calculateStructuralIntegrity_ibsit(b)
						applyGravityCollapse_ibsit(b, integrity)
						-- Debug: report scanner-triggered collapse
						if DebugPrint then pcall(DebugPrint, string.format("Scanner-trigger collapse: body=%s stress=%.3f integrity=%.3f", tostring(b), stressVal, integrity)) end
						-- Additionally attempt enhanced breaking coroutine if impact heuristics apply
						if IsBodyBroken(b) and IsBodyActive(b) then
							local c = GetBodyCenterOfMass(b)
							local s = GetBodyVelocity(b)
							local a = VecLength(s) * GetBodyMass(b)
							if a > threshold_ibsit then
								local co = co_create(enhancedBreaks_ibsit)
								_, val = co_resume(co, b, c, s, a * rthreshold_ibsit - 4)
								if val == true then
									ibsit_breaklist[#ibsit_breaklist + 1] = co
								end
							end
						end
					end
					-- clear scanner tags to avoid re-triggering until scanner updates them again
					RemoveTag(b, "scanner_stress")
					RemoveTag(b, "scanner_center")
					RemoveTag(b, "scanner_last")
				end
			end
		end
	end

	if ind_mbcs then
		for body = #gcl, 1, -1 do
			body = gcl[body]
			local val = GetTagValue(body, "val")
			if val == "calc" then
				local c = TransformToParentPoint(GetBodyTransform(body), GetBodyCenterOfMass(body))
				local d = VecSub(c, shp[body])
				if VecLength(d) > mbcs_distance then
					local v, m = GetBodyVoxelCount(body), GetBodyMass(body)
					if m < v * 0.5 or v * 10 < m then
						m = m * 0.5
					end
					local val_shapes = GetEntityChildren(body, "parent_shape", true, "shape")
					for n = #val_shapes, 1, -1 do
						n = val_shapes[n]
						local a = shp[n]
						if GetShapeBody(a) == shp[a] then
							_, c, n = GetShapeClosestPoint(a, shp[body])
							local x = VecDot(d, n)
							if x > angle_mbcs then
								x = x * m
								if x > threshold_mbcs then
									val = co_create(breaks_mbcs)
									_, x = co_resume(val, a, x, n, c)
									if x == true then
										mbcs_breaklist[#mbcs_breaklist + 1] = val
									end
								end
							end
						elseif shp[a] then
							shp[a] = RemoveTag(a, "parent_shape")
						end
					end
					SetTag(body, "val", "gc")
				end
			end
		end
	end
end

function DrawOptionsMenu()
    -- Options menu background
    UiColor(0, 0, 0, 0.8)
    UiRect(UiWidth(), UiHeight())

    -- Close button
    UiColor(1, 1, 1)
    UiAlign("right top")
    UiTranslate(UiWidth() - 10, 10)
    if UiTextButton("X", 30, 30) then
        optionsVisible = false
        SetPaused(false)
    end

    -- Main options content
    UiAlign("center middle")
    UiTranslate(UiWidth() / 2, UiHeight() / 2)

    -- Title
    UiFont("bold.ttf", 48)
    UiColor(1, 1, 1)
    UiText("Combined Physics Mod Settings")

    -- Page selector buttons
    UiFont("regular.ttf", 24)
    UiTranslate(0, 100)

    local pages = {"Main", "FPS&Dust", "Crumble", "Explosions", "Force&Fire", "Advanced", "IBSIT v2.0"}
    local currentPage = GetInt("savegame.mod.combined.options_page") or 1

    for i, pageName in ipairs(pages) do
        UiPush()
        -- UiTranslate((i - 3.5) * 120, 0)
        UiTranslate((i - 4.0) * 100, 0)
        if currentPage == i then
            UiColor(0.5, 1, 0.5)
        else
            UiColor(0.7, 0.7, 0.7)
        end

        -- if UiTextButton(pageName, 100, 40) then
        if UiTextButton(pageName, 90, 40) then
            SetInt("savegame.mod.combined.options_page", i)
        end
        UiPop()
    end

    -- Draw current page content
    UiTranslate(0, 50)
    DrawPageContent(currentPage)
end

function DrawPageContent(page)

	-- Caching and profiler controls
	UiTranslate(0, 40)
	UiText("Raycast Cache TTL:")
	UiTranslate(150, 0)
	local ttl = GetFloat("savegame.mod.combined.gravitycollapse_cache_ttl")
	UiText(string.format("%.2fs", ttl))
	UiTranslate(-150, 30)
	UiPush()
	UiTranslate(-100, 0)
	local newTtl = UiSlider("ui/common/dot.png", "x", (ttl - 0.1) / 9.9, 0, 1) * 9.9 + 0.1
	if math.abs(newTtl - ttl) > 0.001 then SetFloat("savegame.mod.combined.gravitycollapse_cache_ttl", newTtl) end
	UiPop()

	UiTranslate(0, 30)
	UiText("Profiler Overlay:")
	UiTranslate(150, 0)
	local prof = GetBool("savegame.mod.combined.gravitycollapse_profiler")
	if prof then UiColor(0.5,1,0.5) else UiColor(0.7,0.7,0.7) end
	if UiTextButton("Profiler: " .. (prof and "ON" or "OFF"), 160, 28) then SetBool("savegame.mod.combined.gravitycollapse_profiler", not prof) end
	UiColor(1,1,1)
	UiTranslate(-150, 30)
    UiColor(1, 1, 1)
    UiFont("regular.ttf", 20)

    if page == 1 then
        DrawMainPage()
    elseif page == 2 then
        DrawFPSDustPage()
    elseif page == 3 then
        DrawCrumblePage()
    elseif page == 4 then
        DrawExplosionsPage()
    elseif page == 5 then
        DrawForceFirePage()
    elseif page == 6 then
        DrawAdvancedPage()
    elseif page == 7 then
        DrawIBSITPage()
    end
end

function DrawMainPage()
    UiTranslate(-200, -100)

    -- Feature toggles
    local features = {
        {"FPS Control", "savegame.mod.combined.Tog_FPSC"},
        {"Dust/Smoke", "savegame.mod.combined.Tog_DUST"},
        {"Crumbling", "savegame.mod.combined.Tog_CRUMBLE"},
        {"Explosions", "savegame.mod.combined.Tog_RUMBLE"},
        {"Force/Wind", "savegame.mod.combined.Tog_FORCE"},
        {"Fire Effects", "savegame.mod.combined.Tog_FIRE"},
        {"Violence", "savegame.mod.combined.Tog_VIOLENCE"},
        {"Impact Detection", "savegame.mod.combined.Tog_IMPACT"},
        {"Mass-Based Damage", "savegame.mod.combined.Tog_MASS"},
        {"Damage Statistics", "savegame.mod.combined.Tog_DAMSTAT"}
    }

    for i, feature in ipairs(features) do
        UiPush()
        UiTranslate(0, (i-1) * 35)

        local enabled = GetBool(feature[2])
        if enabled then
            UiColor(0.5, 1, 0.5)
        else
            UiColor(0.7, 0.7, 0.7)
        end

        if UiTextButton(feature[1] .. " (" .. (enabled and "ON" or "OFF") .. ")", 300, 30) then
            SetBool(feature[2], not enabled)
        end
        UiPop()
    end
end

function DrawFPSDustPage()
    UiTranslate(-250, -150)

    -- FPS Target
    UiText("FPS Target:")
    UiTranslate(150, 0)
    local fps = GetInt("savegame.mod.combined.FPS_Targ")
    UiText(tostring(fps))
    UiTranslate(-150, 30)

    -- Dust Amount
    UiText("Dust Amount:")
    UiTranslate(150, 0)
    local dust = GetInt("savegame.mod.combined.dust_amt")
    UiText(tostring(dust))
    UiTranslate(-150, 30)

    -- Dust Size
    UiText("Dust Size:")
    UiTranslate(150, 0)
    local size = GetInt("savegame.mod.combined.dust_size")
    UiText(string.format("%.2f", size/25))
    UiTranslate(-150, 30)

    -- Simple sliders for key settings
    UiTranslate(0, 50)
    UiText("Quick Adjust:")
    UiTranslate(0, 30)

    -- FPS Target slider
    UiPush()
    UiTranslate(-100, 0)
    UiText("FPS:")
    UiTranslate(50, 0)
    local newFps = math.floor(UiSlider("dot",  "x", (fps - 30) / 54, 0, 100) * 54 + 30)
    if newFps ~= fps then
        SetInt("savegame.mod.combined.FPS_Targ", newFps)
    end
    UiTranslate(60, 0)
    UiText(tostring(newFps))
    UiPop()

    UiTranslate(0, 40)

    -- Dust slider
    UiPush()
    UiTranslate(-100, 0)
    UiText("Dust:")
    UiTranslate(50, 0)
    local newDust = math.floor(UiSlider("dot",  "x", dust / 200, 0, 100) * 200)
    if newDust ~= dust then
        SetInt("savegame.mod.combined.dust_amt", newDust)
    end
    UiTranslate(60, 0)
    UiText(tostring(newDust))
    UiPop()
end

function DrawCrumblePage()
    UiTranslate(-200, -100)

    -- Crumble settings
    local settings = {
        {"Light Damage", "savegame.mod.combined.crum_DMGLight", 200},
        {"Medium Damage", "savegame.mod.combined.crum_DMGMed", 200},
        {"Heavy Damage", "savegame.mod.combined.crum_DMGHeavy", 200},
        {"Crumble Size", "savegame.mod.combined.crum_dist", 10},
        {"Min Mass", "savegame.mod.combined.crum_MinMass", 1000}
    }

    for i, setting in ipairs(settings) do
        UiPush()
        UiTranslate(0, (i-1) * 35)

        UiText(setting[1] .. ":")
        UiTranslate(150, 0)
        local value = GetInt(setting[2])
        UiText(tostring(value))

        UiTranslate(-150, 20)
        local newValue = math.floor(UiSlider("dot",  "x", value / setting[3], 0, 100) * setting[3])
        if newValue ~= value then
            SetInt(setting[2], newValue)
        end

        UiPop()
    end
end

function DrawExplosionsPage()
    UiTranslate(-200, -100)

    -- Explosion settings
    local settings = {
        {"Explosion Size", "savegame.mod.combined.xplo_szBase", 10},
        {"Explosion Chance", "savegame.mod.combined.xplo_chance", 100},
        {"Max Distance", "savegame.mod.combined.xplo_distFromPlyr", 50},
        {"Min Mass", "savegame.mod.combined.xplo_MinMass", 1000}
    }

    for i, setting in ipairs(settings) do
        UiPush()
        UiTranslate(0, (i-1) * 35)

        UiText(setting[1] .. ":")
        UiTranslate(150, 0)
        local value = GetInt(setting[2])
        UiText(tostring(value))

        UiTranslate(-150, 20)
        local newValue = math.floor(UiSlider("dot",  "x", value / setting[4], 0, 100) * setting[4])
        if newValue ~= value then
            SetInt(setting[2], newValue)
        end

        UiPop()
    end
end

function DrawForceFirePage()
    UiTranslate(-200, -100)

-- include centralized defaults
#include "defaults.lua"

	-- Force settings
    UiText("Force Strength:")
    UiTranslate(150, 0)
    local force = GetInt("savegame.mod.combined.force_strength")
    UiText(string.format("%.1f", force/50))
    UiTranslate(-150, 30)

    -- Force Radius
    UiText("Force Radius:")
    UiTranslate(150, 0)
    local radius = GetInt("savegame.mod.combined.force_radius")
    UiText(tostring(radius))
    UiTranslate(-150, 30)

    -- Fire Chance
    UiText("Fire Chance:")
    UiTranslate(150, 0)
    local fire = GetInt("savegame.mod.combined.fyr_chance")
    UiText(tostring(fire) .. "%")
    UiTranslate(-150, 30)

    -- Sliders
    UiTranslate(0, 50)
    UiText("Adjust:")

    UiTranslate(0, 30)
    UiPush()
    UiTranslate(-100, 0)
    UiText("Force:")
    UiTranslate(50, 0)
    local newForce = math.floor(UiSlider("dot",  "x", force / 240, 0, 100) * 240)
    if newForce ~= force then
        SetInt("savegame.mod.combined.force_strength", newForce)
    end
    UiTranslate(60, 0)
    UiText(string.format("%.1f", newForce/50))
    UiPop()
end

function DrawAdvancedPage()
    UiTranslate(-200, -100)

    -- Advanced settings
    local settings = {
        {"Momentum Threshold", "savegame.mod.combined.ibsit_momentum", 20},
        {"Mass Threshold", "savegame.mod.combined.mbcs_mass", 20},
        {"Violence Chance", "savegame.mod.combined.VIOL_Chance", 200},
        {"Joint Break Chance", "savegame.mod.combined.JOINT_Chance", 100}
    }

    for i, setting in ipairs(settings) do
        UiPush()
        UiTranslate(0, (i-1) * 35)

        UiText(setting[1] .. ":")
        UiTranslate(150, 0)
        local value = GetInt(setting[2])
        UiText(tostring(value))

        UiTranslate(-150, 20)
        local newValue = math.floor(UiSlider("dot",  "x", value / setting[3], 0, 100) * setting[3])
        if newValue ~= value then
            SetInt(setting[2], newValue)
        end

        UiPop()
    end

    -- Reset button
    UiTranslate(0, 200)
	UiPush()
	UiTranslate(-110, 200)
	if UiTextButton("Reset All Settings", 200, 40) then
		ResetAllSettings()
	end
	UiPop()

	UiPush()
	UiTranslate(130, 200)
	if UiTextButton("Save Settings", 200, 40) then
		SaveAllSettings()
	end
	UiPop()

	-- Saved popup
	if savedPopupTimer and savedPopupTimer > 0 then
		UiPush()
		UiTranslate(-100, 260)
		UiColor(0,0,0,0.75)
		UiRect(220, 40)
		UiColor(1,1,1)
		UiTranslate(10, 10)
		UiText("Saved!")
		UiPop()
	end
end

-- Reset all settings to sane defaults for this mod
function ResetAllSettings()
	-- Delegate to centralized defaults if available
	if ApplyDefaultSettings then
		pcall(ApplyDefaultSettings)
		return
	end
end

-- transient popup timer for saved confirmation
local savedPopupTimer = 0

-- SaveAllSettings: explicitly write current UI/read values to registry
function SaveAllSettings()
	-- write core toggles (read back current values where applicable)
	SetBool("savegame.mod.combined.Tog_FPSC", GetBool("savegame.mod.combined.Tog_FPSC"))
	SetBool("savegame.mod.combined.Tog_DUST", GetBool("savegame.mod.combined.Tog_DUST"))
	SetBool("savegame.mod.combined.Tog_CRUMBLE", GetBool("savegame.mod.combined.Tog_CRUMBLE"))
	SetBool("savegame.mod.combined.Tog_RUMBLE", GetBool("savegame.mod.combined.Tog_RUMBLE"))
	SetBool("savegame.mod.combined.Tog_FORCE", GetBool("savegame.mod.combined.Tog_FORCE"))
	SetBool("savegame.mod.combined.Tog_FIRE", GetBool("savegame.mod.combined.Tog_FIRE"))
	SetBool("savegame.mod.combined.Tog_VIOLENCE", GetBool("savegame.mod.combined.Tog_VIOLENCE"))
	SetBool("savegame.mod.combined.Tog_DAMSTAT", GetBool("savegame.mod.combined.Tog_DAMSTAT"))
	SetBool("savegame.mod.combined.Tog_JOINTS", GetBool("savegame.mod.combined.Tog_JOINTS"))
	SetBool("savegame.mod.combined.Tog_IMPACT", GetBool("savegame.mod.combined.Tog_IMPACT"))
	SetBool("savegame.mod.combined.Tog_MASS", GetBool("savegame.mod.combined.Tog_MASS"))
	SetBool("savegame.mod.combined.Tog_SDF", GetBool("savegame.mod.combined.Tog_SDF"))
	SetBool("savegame.mod.combined.Tog_LFF", GetBool("savegame.mod.combined.Tog_LFF"))
	SetBool("savegame.mod.combined.Tog_DBF", GetBool("savegame.mod.combined.Tog_DBF"))

	-- FPS / performance toggles
	SetBool("savegame.mod.combined.FPS_DynLights", GetBool("savegame.mod.combined.FPS_DynLights"))
	SetInt("savegame.mod.combined.FPS_SDF", GetInt("savegame.mod.combined.FPS_SDF"))
	SetInt("savegame.mod.combined.FPS_LFF", GetInt("savegame.mod.combined.FPS_LFF"))
	SetInt("savegame.mod.combined.FPS_DBF", GetInt("savegame.mod.combined.FPS_DBF"))
	SetBool("savegame.mod.combined.FPS_DBF_FPSB", GetBool("savegame.mod.combined.FPS_DBF_FPSB"))
	SetInt("savegame.mod.combined.FPS_Targ", GetInt("savegame.mod.combined.FPS_Targ"))
	SetInt("savegame.mod.combined.FPS_Agg", GetInt("savegame.mod.combined.FPS_Agg"))

	-- IBSIT settings
	SetInt("savegame.mod.combined.ibsit_momentum", GetInt("savegame.mod.combined.ibsit_momentum"))
	SetInt("savegame.mod.combined.ibsit_dust_amt", GetInt("savegame.mod.combined.ibsit_dust_amt"))
	SetInt("savegame.mod.combined.ibsit_wood_size", GetInt("savegame.mod.combined.ibsit_wood_size"))
	SetInt("savegame.mod.combined.ibsit_stone_size", GetInt("savegame.mod.combined.ibsit_stone_size"))
	SetInt("savegame.mod.combined.ibsit_metal_size", GetInt("savegame.mod.combined.ibsit_metal_size"))
	SetBool("savegame.mod.combined.ibsit_haptic", GetBool("savegame.mod.combined.ibsit_haptic"))
	SetBool("savegame.mod.combined.ibsit_sounds", GetBool("savegame.mod.combined.ibsit_sounds"))
	SetBool("savegame.mod.combined.ibsit_particles", GetBool("savegame.mod.combined.ibsit_particles"))
	SetBool("savegame.mod.combined.ibsit_vehicle", GetBool("savegame.mod.combined.ibsit_vehicle"))
	SetBool("savegame.mod.combined.ibsit_joint", GetBool("savegame.mod.combined.ibsit_joint"))
	SetBool("savegame.mod.combined.ibsit_protection", GetBool("savegame.mod.combined.ibsit_protection"))
	SetFloat("savegame.mod.combined.ibsit_volume", GetFloat("savegame.mod.combined.ibsit_volume"))
	SetInt("savegame.mod.combined.ibsit_particle_quality", GetInt("savegame.mod.combined.ibsit_particle_quality"))
	SetBool("savegame.mod.combined.ibsit_debris_cleanup", GetBool("savegame.mod.combined.ibsit_debris_cleanup"))
	SetFloat("savegame.mod.combined.ibsit_cleanup_delay", GetFloat("savegame.mod.combined.ibsit_cleanup_delay"))

	-- Gravity collapse settings
	SetBool("savegame.mod.combined.ibsit_gravity_collapse", GetBool("savegame.mod.combined.ibsit_gravity_collapse"))
	SetFloat("savegame.mod.combined.ibsit_collapse_threshold", GetFloat("savegame.mod.combined.ibsit_collapse_threshold"))
	SetFloat("savegame.mod.combined.ibsit_gravity_force", GetFloat("savegame.mod.combined.ibsit_gravity_force"))
	SetInt("savegame.mod.combined.gravitycollapse_sample_count", GetInt("savegame.mod.combined.gravitycollapse_sample_count"))
	SetFloat("savegame.mod.combined.gravitycollapse_check_interval", GetFloat("savegame.mod.combined.gravitycollapse_check_interval"))
	SetInt("savegame.mod.combined.gravitycollapse_min_mass", GetInt("savegame.mod.combined.gravitycollapse_min_mass"))
	SetBool("savegame.mod.combined.gravitycollapse_debug", GetBool("savegame.mod.combined.gravitycollapse_debug"))
	SetBool("savegame.mod.combined.gravitycollapse_joint_credit", GetBool("savegame.mod.combined.gravitycollapse_joint_credit"))
	SetInt("savegame.mod.combined.gravitycollapse_joint_depth", GetInt("savegame.mod.combined.gravitycollapse_joint_depth"))
	SetInt("savegame.mod.combined.gravitycollapse_joint_mass_threshold", GetInt("savegame.mod.combined.gravitycollapse_joint_mass_threshold"))
	SetInt("savegame.mod.combined.gravitycollapse_min_samples", GetInt("savegame.mod.combined.gravitycollapse_min_samples"))
	SetInt("savegame.mod.combined.gravitycollapse_max_samples", GetInt("savegame.mod.combined.gravitycollapse_max_samples"))
	SetFloat("savegame.mod.combined.gravitycollapse_cache_grid", GetFloat("savegame.mod.combined.gravitycollapse_cache_grid"))
	SetFloat("savegame.mod.combined.gravitycollapse_cache_ttl", GetFloat("savegame.mod.combined.gravitycollapse_cache_ttl"))
	SetBool("savegame.mod.combined.gravitycollapse_cache_invalidate_on_check", GetBool("savegame.mod.combined.gravitycollapse_cache_invalidate_on_check"))
	SetFloat("savegame.mod.combined.gravitycollapse_cache_invalidate_pad", GetFloat("savegame.mod.combined.gravitycollapse_cache_invalidate_pad"))
	SetBool("savegame.mod.combined.gravitycollapse_profiler", GetBool("savegame.mod.combined.gravitycollapse_profiler"))
	SetFloat("savegame.mod.combined.gravitycollapse_profile_interval", GetFloat("savegame.mod.combined.gravitycollapse_profile_interval"))

	-- Advanced / miscellaneous keys used in UI pages
	SetInt("savegame.mod.combined.mbcs_mass", GetInt("savegame.mod.combined.mbcs_mass"))
	SetInt("savegame.mod.combined.mbcs_distance", GetInt("savegame.mod.combined.mbcs_distance"))
	SetInt("savegame.mod.combined.mbcs_dust_amt", GetInt("savegame.mod.combined.mbcs_dust_amt"))
	SetInt("savegame.mod.combined.mbcs_wood_size", GetInt("savegame.mod.combined.mbcs_wood_size"))
	SetInt("savegame.mod.combined.mbcs_stone_size", GetInt("savegame.mod.combined.mbcs_stone_size"))
	SetInt("savegame.mod.combined.mbcs_metal_size", GetInt("savegame.mod.combined.mbcs_metal_size"))

	SetInt("savegame.mod.combined.force_method", GetInt("savegame.mod.combined.force_method"))
	SetInt("savegame.mod.combined.force_strength", GetInt("savegame.mod.combined.force_strength"))
	SetInt("savegame.mod.combined.force_radius", GetInt("savegame.mod.combined.force_radius"))
	SetInt("savegame.mod.combined.force_minmass", GetInt("savegame.mod.combined.force_minmass"))
	SetInt("savegame.mod.combined.force_maxmass", GetInt("savegame.mod.combined.force_maxmass"))

	SetInt("savegame.mod.combined.viol_chance", GetInt("savegame.mod.combined.viol_chance"))
	SetInt("savegame.mod.combined.viol_mover", GetInt("savegame.mod.combined.viol_mover"))
	SetInt("savegame.mod.combined.viol_turnr", GetInt("savegame.mod.combined.viol_turnr"))
	SetInt("savegame.mod.combined.viol_minmass", GetInt("savegame.mod.combined.viol_minmass"))
	SetInt("savegame.mod.combined.viol_maxmass", GetInt("savegame.mod.combined.viol_maxmass"))

	SetInt("savegame.mod.combined.fyr_chance", GetInt("savegame.mod.combined.fyr_chance"))
	SetInt("savegame.mod.combined.fyr_minrad", GetInt("savegame.mod.combined.fyr_minrad"))
	SetInt("savegame.mod.combined.fyr_maxrad", GetInt("savegame.mod.combined.fyr_maxrad"))
	SetInt("savegame.mod.combined.fyr_minmass", GetInt("savegame.mod.combined.fyr_minmass"))
	SetInt("savegame.mod.combined.fyr_maxmass", GetInt("savegame.mod.combined.fyr_maxmass"))

	-- Dust specifics
	SetInt("savegame.mod.combined.dust_amt", GetInt("savegame.mod.combined.dust_amt"))
	SetInt("savegame.mod.combined.dust_size", GetInt("savegame.mod.combined.dust_size"))
	SetInt("savegame.mod.combined.dust_sizernd", GetInt("savegame.mod.combined.dust_sizernd"))
	SetInt("savegame.mod.combined.dust_MsBsSz", GetInt("savegame.mod.combined.dust_MsBsSz"))
	SetInt("savegame.mod.combined.dust_grav", GetInt("savegame.mod.combined.dust_grav"))
	SetInt("savegame.mod.combined.dust_drag", GetInt("savegame.mod.combined.dust_drag"))
	SetInt("savegame.mod.combined.dust_life", GetInt("savegame.mod.combined.dust_life"))
	SetInt("savegame.mod.combined.dust_lifernd", GetInt("savegame.mod.combined.dust_lifernd"))
	SetInt("savegame.mod.combined.dust_MsBsLf", GetInt("savegame.mod.combined.dust_MsBsLf"))
	SetInt("savegame.mod.combined.dust_minMass", GetInt("savegame.mod.combined.dust_minMass"))
	SetInt("savegame.mod.combined.dust_minSpeed", GetInt("savegame.mod.combined.dust_minSpeed"))

	-- Crumble / explosion keys
	SetInt("savegame.mod.combined.crum_dist", GetInt("savegame.mod.combined.crum_dist"))
	SetInt("savegame.mod.combined.crum_spd", GetInt("savegame.mod.combined.crum_spd"))
	SetInt("savegame.mod.combined.crum_DMGLight", GetInt("savegame.mod.combined.crum_DMGLight"))
	SetInt("savegame.mod.combined.crum_DMGMed", GetInt("savegame.mod.combined.crum_DMGMed"))
	SetInt("savegame.mod.combined.crum_DMGHeavy", GetInt("savegame.mod.combined.crum_DMGHeavy"))
	SetInt("savegame.mod.combined.crum_HoleControl", GetInt("savegame.mod.combined.crum_HoleControl"))
	SetFloat("savegame.mod.combined.crum_BreakTime", GetFloat("savegame.mod.combined.crum_BreakTime"))
	SetInt("savegame.mod.combined.crum_distFromPlyr", GetInt("savegame.mod.combined.crum_distFromPlyr"))
	SetInt("savegame.mod.combined.crum_MinMass", GetInt("savegame.mod.combined.crum_MinMass"))
	SetInt("savegame.mod.combined.crum_MaxMass", GetInt("savegame.mod.combined.crum_MaxMass"))
	SetFloat("savegame.mod.combined.crum_MinSpd", GetFloat("savegame.mod.combined.crum_MinSpd"))
	SetFloat("savegame.mod.combined.crum_MaxSpd", GetFloat("savegame.mod.combined.crum_MaxSpd"))

	SetFloat("savegame.mod.combined.xplo_szBase", GetFloat("savegame.mod.combined.xplo_szBase"))
	SetFloat("savegame.mod.combined.xplo_szRND", GetFloat("savegame.mod.combined.xplo_szRND"))
	SetInt("savegame.mod.combined.xplo_chance", GetInt("savegame.mod.combined.xplo_chance"))
	SetInt("savegame.mod.combined.xplo_HoleControl", GetInt("savegame.mod.combined.xplo_HoleControl"))
	SetFloat("savegame.mod.combined.xplo_BreakTime", GetFloat("savegame.mod.combined.xplo_BreakTime"))
	SetInt("savegame.mod.combined.xplo_distFromPlyr", GetInt("savegame.mod.combined.xplo_distFromPlyr"))
	SetInt("savegame.mod.combined.xplo_MinMass", GetInt("savegame.mod.combined.xplo_MinMass"))
	SetInt("savegame.mod.combined.xplo_MaxMass", GetInt("savegame.mod.combined.xplo_MaxMass"))
	SetFloat("savegame.mod.combined.xplo_MinSpd", GetFloat("savegame.mod.combined.xplo_MinSpd"))
	SetFloat("savegame.mod.combined.xplo_MaxSpd", GetFloat("savegame.mod.combined.xplo_MaxSpd"))

	-- FPS Control
	SetBool("savegame.mod.combined.FPS_DynLights", GetBool("savegame.mod.combined.FPS_DynLights"))
	SetBool("savegame.mod.combined.Tog_SDF", GetBool("savegame.mod.combined.Tog_SDF"))
	SetBool("savegame.mod.combined.Tog_LFF", GetBool("savegame.mod.combined.Tog_LFF"))
	SetBool("savegame.mod.combined.Tog_DBF", GetBool("savegame.mod.combined.Tog_DBF"))
	SetInt("savegame.mod.combined.FPS_SDF", GetInt("savegame.mod.combined.FPS_SDF"))
	SetInt("savegame.mod.combined.FPS_LFF", GetInt("savegame.mod.combined.FPS_LFF"))
	SetInt("savegame.mod.combined.FPS_DBF", GetInt("savegame.mod.combined.FPS_DBF"))
	SetInt("savegame.mod.combined.FPS_DBF_size", GetInt("savegame.mod.combined.FPS_DBF_size"))
	SetBool("savegame.mod.combined.FPS_DBF_FPSB", GetBool("savegame.mod.combined.FPS_DBF_FPSB"))
	SetInt("savegame.mod.combined.FPS_SDF_agg", GetInt("savegame.mod.combined.FPS_SDF_agg"))
	SetInt("savegame.mod.combined.FPS_LFF_agg", GetInt("savegame.mod.combined.FPS_LFF_agg"))
	SetInt("savegame.mod.combined.FPS_DBF_agg", GetInt("savegame.mod.combined.FPS_DBF_agg"))
	SetInt("savegame.mod.combined.FPS_Targ", GetInt("savegame.mod.combined.FPS_Targ"))
	SetInt("savegame.mod.combined.FPS_Agg", GetInt("savegame.mod.combined.FPS_Agg"))
	SetBool("savegame.mod.combined.FPS_GLOB_agg", GetBool("savegame.mod.combined.FPS_GLOB_agg"))
	SetInt("savegame.mod.combined.FPS_GLOB_aggfac", GetInt("savegame.mod.combined.FPS_GLOB_aggfac"))

	-- Dust Control
	SetInt("savegame.mod.combined.dust_amt", GetInt("savegame.mod.combined.dust_amt"))
	SetInt("savegame.mod.combined.dust_size", GetInt("savegame.mod.combined.dust_size"))
	SetInt("savegame.mod.combined.dust_sizernd", GetInt("savegame.mod.combined.dust_sizernd"))
	SetInt("savegame.mod.combined.dust_MsBsSz", GetInt("savegame.mod.combined.dust_MsBsSz"))
	SetInt("savegame.mod.combined.dust_grav", GetInt("savegame.mod.combined.dust_grav"))
	SetInt("savegame.mod.combined.dust_drag", GetInt("savegame.mod.combined.dust_drag"))
	SetInt("savegame.mod.combined.dust_life", GetInt("savegame.mod.combined.dust_life"))
	SetInt("savegame.mod.combined.dust_lifernd", GetInt("savegame.mod.combined.dust_lifernd"))
	SetInt("savegame.mod.combined.dust_MsBsLf", GetInt("savegame.mod.combined.dust_MsBsLf"))
	SetInt("savegame.mod.combined.dust_minMass", GetInt("savegame.mod.combined.dust_minMass"))
	SetInt("savegame.mod.combined.dust_minSpeed", GetInt("savegame.mod.combined.dust_minSpeed"))
	SetInt("savegame.mod.combined.dust_startsize", GetInt("savegame.mod.combined.dust_startsize"))
	SetInt("savegame.mod.combined.dust_fader", GetInt("savegame.mod.combined.dust_fader"))

	-- Crumbling
	SetBool("savegame.mod.combined.tog_crum", GetBool("savegame.mod.combined.tog_crum"))
	SetInt("savegame.mod.combined.tog_crum_MODE", GetInt("savegame.mod.combined.tog_crum_MODE"))
	SetInt("savegame.mod.combined.tog_crum_Source", GetInt("savegame.mod.combined.tog_crum_Source"))
	SetInt("savegame.mod.combined.crum_DMGLight", GetInt("savegame.mod.combined.crum_DMGLight"))
	SetInt("savegame.mod.combined.crum_DMGMed", GetInt("savegame.mod.combined.crum_DMGMed"))
	SetInt("savegame.mod.combined.crum_DMGHeavy", GetInt("savegame.mod.combined.crum_DMGHeavy"))
	SetInt("savegame.mod.combined.crum_spd", GetInt("savegame.mod.combined.crum_spd"))
	SetFloat("savegame.mod.combined.crum_spdRND", GetFloat("savegame.mod.combined.crum_spdRND"))
	SetInt("savegame.mod.combined.crum_dist", GetInt("savegame.mod.combined.crum_dist"))
	SetBool("savegame.mod.combined.vehicles_crumble", GetBool("savegame.mod.combined.vehicles_crumble"))
	SetInt("savegame.mod.combined.crum_HoleControl", GetInt("savegame.mod.combined.crum_HoleControl"))
	SetFloat("savegame.mod.combined.crum_BreakTime", GetFloat("savegame.mod.combined.crum_BreakTime"))
	SetInt("savegame.mod.combined.crum_distFromPlyr", GetInt("savegame.mod.combined.crum_distFromPlyr"))
	SetInt("savegame.mod.combined.crum_MinMass", GetInt("savegame.mod.combined.crum_MinMass"))
	SetInt("savegame.mod.combined.crum_MaxMass", GetInt("savegame.mod.combined.crum_MaxMass"))
	SetFloat("savegame.mod.combined.crum_MinSpd", GetFloat("savegame.mod.combined.crum_MinSpd"))
	SetFloat("savegame.mod.combined.crum_MaxSpd", GetFloat("savegame.mod.combined.crum_MaxSpd"))

	-- Explosions
	SetFloat("savegame.mod.combined.xplo_szBase", GetFloat("savegame.mod.combined.xplo_szBase"))
	SetFloat("savegame.mod.combined.xplo_szRND", GetFloat("savegame.mod.combined.xplo_szRND"))
	SetFloat("savegame.mod.combined.xplo_szMBV", GetFloat("savegame.mod.combined.xplo_szMBV"))
	SetInt("savegame.mod.combined.xplo_chance", GetInt("savegame.mod.combined.xplo_chance"))
	SetInt("savegame.mod.combined.xplo_HoleControl", GetInt("savegame.mod.combined.xplo_HoleControl"))
	SetFloat("savegame.mod.combined.xplo_BreakTime", GetFloat("savegame.mod.combined.xplo_BreakTime"))
	SetInt("savegame.mod.combined.xplo_distFromPlyr", GetInt("savegame.mod.combined.xplo_distFromPlyr"))
	SetInt("savegame.mod.combined.xplo_MinMass", GetInt("savegame.mod.combined.xplo_MinMass"))
	SetInt("savegame.mod.combined.xplo_MaxMass", GetInt("savegame.mod.combined.xplo_MaxMass"))
	SetFloat("savegame.mod.combined.xplo_MinSpd", GetFloat("savegame.mod.combined.xplo_MinSpd"))
	SetFloat("savegame.mod.combined.xplo_MaxSpd", GetFloat("savegame.mod.combined.xplo_MaxSpd"))
	SetInt("savegame.mod.combined.xplo_SmokeAMT", GetInt("savegame.mod.combined.xplo_SmokeAMT"))
	SetInt("savegame.mod.combined.xplo_LifeAMT", GetInt("savegame.mod.combined.xplo_LifeAMT"))
	SetInt("savegame.mod.combined.xplo_Pressure", GetInt("savegame.mod.combined.xplo_Pressure"))
	SetInt("savegame.mod.combined.xplo_mode", GetInt("savegame.mod.combined.xplo_mode"))

	-- Force & Wind
	SetInt("savegame.mod.combined.force_method", GetInt("savegame.mod.combined.force_method"))
	SetFloat("savegame.mod.combined.force_gamecontrols", GetFloat("savegame.mod.combined.force_gamecontrols"))
	SetFloat("savegame.mod.combined.force_radius", GetFloat("savegame.mod.combined.force_radius"))
	SetFloat("savegame.mod.combined.force_maxmass", GetFloat("savegame.mod.combined.force_maxmass"))
	SetFloat("savegame.mod.combined.force_minmass", GetFloat("savegame.mod.combined.force_minmass"))
	SetFloat("savegame.mod.combined.force_strength", GetFloat("savegame.mod.combined.force_strength"))
	SetFloat("savegame.mod.combined.force_boost", GetFloat("savegame.mod.combined.force_boost"))
	SetBool("savegame.mod.combined.force_EdgeFade", GetBool("savegame.mod.combined.force_EdgeFade"))
	SetBool("savegame.mod.combined.force_START_ON", GetBool("savegame.mod.combined.force_START_ON"))
	SetBool("savegame.mod.combined.force_ENABLE_CONTROLS", GetBool("savegame.mod.combined.force_ENABLE_CONTROLS"))
	SetBool("savegame.mod.combined.force_Showcross", GetBool("savegame.mod.combined.force_Showcross"))
	SetBool("savegame.mod.combined.force_CONTROL_TIPS", GetBool("savegame.mod.combined.force_CONTROL_TIPS"))
	SetFloat("savegame.mod.combined.force_cycle", GetFloat("savegame.mod.combined.force_cycle"))
	SetFloat("savegame.mod.combined.force_largemass_accellerator", GetFloat("savegame.mod.combined.force_largemass_accellerator"))
	SetFloat("savegame.mod.combined.force_upforce", GetFloat("savegame.mod.combined.force_upforce"))
	SetFloat("savegame.mod.combined.force_effect_on_player", GetFloat("savegame.mod.combined.force_effect_on_player"))
	SetFloat("savegame.mod.combined.force_rotational", GetFloat("savegame.mod.combined.force_rotational"))
	SetFloat("savegame.mod.combined.force_warmup", GetFloat("savegame.mod.combined.force_warmup"))

	-- Fire
	SetInt("savegame.mod.combined.fyr_mode", GetInt("savegame.mod.combined.fyr_mode"))
	SetInt("savegame.mod.combined.fyr_maxrad", GetInt("savegame.mod.combined.fyr_maxrad"))
	SetInt("savegame.mod.combined.fyr_minrad", GetInt("savegame.mod.combined.fyr_minrad"))
	SetInt("savegame.mod.combined.fyr_chance", GetInt("savegame.mod.combined.fyr_chance"))
	SetInt("savegame.mod.combined.fyr_maxmass", GetInt("savegame.mod.combined.fyr_maxmass"))
	SetInt("savegame.mod.combined.fyr_minmass", GetInt("savegame.mod.combined.fyr_minmass"))

	-- Violence / Joint / Damage stats
	SetInt("savegame.mod.combined.VIOL_mode", GetInt("savegame.mod.combined.VIOL_mode"))
	SetInt("savegame.mod.combined.VIOL_Chance", GetInt("savegame.mod.combined.VIOL_Chance"))
	SetInt("savegame.mod.combined.VIOL_mover", GetInt("savegame.mod.combined.VIOL_mover"))
	SetInt("savegame.mod.combined.VIOL_turnr", GetInt("savegame.mod.combined.VIOL_turnr"))
	SetInt("savegame.mod.combined.VIOL_minmass", GetInt("savegame.mod.combined.VIOL_minmass"))
	SetInt("savegame.mod.combined.VIOL_maxmass", GetInt("savegame.mod.combined.VIOL_maxmass"))
	SetInt("savegame.mod.combined.VIOL_maxdist", GetInt("savegame.mod.combined.VIOL_maxdist"))
	SetInt("savegame.mod.combined.JOINT_Source", GetInt("savegame.mod.combined.JOINT_Source"))
	SetInt("savegame.mod.combined.JOINT_Range", GetInt("savegame.mod.combined.JOINT_Range"))
	SetInt("savegame.mod.combined.JOINT_Chance", GetInt("savegame.mod.combined.JOINT_Chance"))
	SetInt("savegame.mod.combined.DAMSTAT_Currency", GetInt("savegame.mod.combined.DAMSTAT_Currency"))

	-- Scanner defaults & extras
	SetFloat("savegame.mod.combined.scanner_cell", GetFloat("savegame.mod.combined.scanner_cell"))
	SetInt("savegame.mod.combined.scanner_iter", GetInt("savegame.mod.combined.scanner_iter"))
	SetFloat("savegame.mod.combined.scanner_factor", GetFloat("savegame.mod.combined.scanner_factor"))
	SetFloat("savegame.mod.combined.scanner_pad", GetFloat("savegame.mod.combined.scanner_pad"))
	SetFloat("savegame.mod.combined.scanner_threshold", GetFloat("savegame.mod.combined.scanner_threshold"))
	SetBool("savegame.mod.combined.scanner_autobreak", GetBool("savegame.mod.combined.scanner_autobreak"))
	SetFloat("savegame.mod.combined.scanner_cooldown", GetFloat("savegame.mod.combined.scanner_cooldown"))
	SetBool("savegame.mod.combined.scanner_show_legend", GetBool("savegame.mod.combined.scanner_show_legend"))
	SetBool("savegame.mod.combined.scanner_show_numbers", GetBool("savegame.mod.combined.scanner_show_numbers"))
	SetInt("savegame.mod.combined.scanner_max_breaks_per_tick", GetInt("savegame.mod.combined.scanner_max_breaks_per_tick"))
end

function DrawIBSITPage()
    UiTranslate(-250, -150)

    -- IBSIT Core Settings
    UiText("Momentum Threshold:")
    UiTranslate(180, 0)
    local momentum = GetInt("savegame.mod.combined.ibsit_momentum")
    UiText(tostring(momentum))
    UiTranslate(-180, 30)

    UiText("Dust Amount:")
    UiTranslate(180, 0)
    local dust = GetInt("savegame.mod.combined.ibsit_dust_amt")
    UiText(tostring(dust))
    UiTranslate(-180, 30)

    -- Material Size Multipliers
    UiText("Wood Size:")
    UiTranslate(180, 0)
    local wood = GetInt("savegame.mod.combined.ibsit_wood_size")
    UiText(string.format("%.1f", wood/100))
    UiTranslate(-180, 30)

    UiText("Stone Size:")
    UiTranslate(180, 0)
    local stone = GetInt("savegame.mod.combined.ibsit_stone_size")
    UiText(string.format("%.1f", stone/100))
    UiTranslate(-180, 30)

    UiText("Metal Size:")
    UiTranslate(180, 0)
    local metal = GetInt("savegame.mod.combined.ibsit_metal_size")
    UiText(string.format("%.1f", metal/100))
    UiTranslate(-180, 30)

    -- Feature toggles
    UiTranslate(0, 50)
    UiText("Enhanced Features:")
    UiTranslate(0, 30)

    local features = {
        {"Haptic Feedback", "savegame.mod.combined.ibsit_haptic"},
        {"Sound Effects", "savegame.mod.combined.ibsit_sounds"},
        {"Enhanced Particles", "savegame.mod.combined.ibsit_particles"},
        {"Vehicle Protection", "savegame.mod.combined.ibsit_vehicle"},
        {"Joint Protection", "savegame.mod.combined.ibsit_joint"},
        {"Protection Mode", "savegame.mod.combined.ibsit_protection"}
    }

    for i, feature in ipairs(features) do
        UiPush()
        UiTranslate(0, (i-1) * 35)

        local enabled = GetBool(feature[2])
        if enabled then
            UiColor(0.5, 1, 0.5)
        else
            UiColor(0.7, 0.7, 0.7)
        end

        if UiTextButton(feature[1] .. " (" .. (enabled and "ON" or "OFF") .. ")", 250, 30) then
            SetBool(feature[2], not enabled)
        end
        UiPop()
    end

    -- Advanced settings
    UiTranslate(300, -150)
    UiText("Advanced Settings:")
    UiTranslate(0, 30)

    UiText("Particle Quality:")
    UiTranslate(150, 0)
    local quality = GetInt("savegame.mod.combined.ibsit_particle_quality")
    local qualityNames = {"Low", "Medium", "High"}
    UiText(qualityNames[quality + 1] or "Medium")
    UiTranslate(-150, 30)

    UiText("Volume:")
    UiTranslate(150, 0)
    local volume = GetFloat("savegame.mod.combined.ibsit_volume")
    UiText(string.format("%.1f", volume))
    UiTranslate(-150, 30)

    -- Gravity collapse settings
    UiTranslate(0, 50)
    UiText("Gravity Collapse:")
    UiTranslate(0, 30)

    local collapseEnabled = GetBool("savegame.mod.combined.ibsit_gravity_collapse")
    if collapseEnabled then
        UiColor(0.5, 1, 0.5)
    else
        UiColor(0.7, 0.7, 0.7)
    end
    if UiTextButton("Gravity Collapse (" .. (collapseEnabled and "ON" or "OFF") .. ")", 200, 30) then
        SetBool("savegame.mod.combined.ibsit_gravity_collapse", not collapseEnabled)
    end

    UiTranslate(0, 40)
    UiColor(1, 1, 1)
    UiText("Collapse Threshold:")
    UiTranslate(150, 0)
    local threshold = GetFloat("savegame.mod.combined.ibsit_collapse_threshold")
    UiText(string.format("%.1f", threshold))
    UiTranslate(-150, 30)
    UiPush()
    UiTranslate(-100, 0)
    local newThreshold = UiSlider("dot", "x", (threshold - 0.1) / 0.9, 0, 1) * 0.9 + 0.1
    if math.abs(newThreshold - threshold) > 0.001 then SetFloat("savegame.mod.combined.ibsit_collapse_threshold", newThreshold) end
    UiPop()

    UiText("Gravity Force:")
    UiTranslate(150, 0)
    local force = GetFloat("savegame.mod.combined.ibsit_gravity_force")
    UiText(string.format("%.1f", force))

	-- Gravity collapse advanced tunables (prototype)
	UiTranslate(0, 40)
	UiText("Sample Count:")
	UiTranslate(150, 0)
	local sc = GetInt("savegame.mod.combined.gravitycollapse_sample_count")
	UiText(tostring(sc))
	UiTranslate(-150, 30)
	UiPush()
	UiTranslate(-100, 0)
	local newSc = math.floor(UiSlider("dot",  "x", sc / 128, 0, 128) * 128)
	if newSc ~= sc then SetInt("savegame.mod.combined.gravitycollapse_sample_count", newSc) end
	UiPop()

	UiTranslate(0, 30)
	UiText("Check Interval (s):")
	UiTranslate(150, 0)
	local ci = GetFloat("savegame.mod.combined.gravitycollapse_check_interval")
	UiText(string.format("%.2f", ci))
	UiTranslate(-150, 30)
	UiPush()
	UiTranslate(-100, 0)
	local newCi = UiSlider("dot", "x", (ci - 0.1) / 4.9, 0, 1) * 4.9 + 0.1
	if math.abs(newCi - ci) > 0.001 then SetFloat("savegame.mod.combined.gravitycollapse_check_interval", newCi) end
	UiPop()

	UiTranslate(0, 30)
	UiText("Min Body Mass:")
	UiTranslate(150, 0)
	local mm = GetInt("savegame.mod.combined.gravitycollapse_min_mass")
	UiText(tostring(mm))
	UiTranslate(-150, 30)
	UiPush()
	UiTranslate(-100, 0)
	local newMm = math.floor(UiSlider("dot",  "x", mm / 5000, 0, 1) * 5000)
	if newMm ~= mm then SetInt("savegame.mod.combined.gravitycollapse_min_mass", newMm) end
	UiPop()

	UiTranslate(0, 30)
	UiText("Debug Overlay:")
	UiTranslate(150, 0)
	local dbg = GetBool("savegame.mod.combined.gravitycollapse_debug")
	if dbg then UiColor(0.5, 1, 0.5) else UiColor(0.7,0.7,0.7) end
	if UiTextButton("Debug: " .. (dbg and "ON" or "OFF"), 160, 28) then SetBool("savegame.mod.combined.gravitycollapse_debug", not dbg) end
	UiColor(1,1,1)
	UiTranslate(-150, 30)

	UiTranslate(0, 10)
	UiText("Joint Support Credit:")
	UiTranslate(150, 0)
	local jc = GetBool("savegame.mod.combined.gravitycollapse_joint_credit")
	if jc then UiColor(0.5,1,0.5) else UiColor(0.7,0.7,0.7) end
	if UiTextButton("Joint Credit: " .. (jc and "ON" or "OFF"), 160, 28) then SetBool("savegame.mod.combined.gravitycollapse_joint_credit", not jc) end
	UiColor(1,1,1)
	UiTranslate(-150, 30)

	UiTranslate(0, 0)
	UiText("Min Samples:")
	UiTranslate(150, 0)
	local mins = GetInt("savegame.mod.combined.gravitycollapse_min_samples")
	UiText(tostring(mins))
	UiTranslate(-150, 30)
	UiPush()
	UiTranslate(-100, 0)
	local newMin = math.floor(UiSlider("dot",  "x", mins / 64, 0, 64) * 64)
	if newMin ~= mins then SetInt("savegame.mod.combined.gravitycollapse_min_samples", newMin) end
	UiPop()

	UiTranslate(0, 0)
	UiText("Max Samples:")
	UiTranslate(150, 0)
	local maxs = GetInt("savegame.mod.combined.gravitycollapse_max_samples")
	UiText(tostring(maxs))
	UiTranslate(-150, 30)
	UiPush()
	UiTranslate(-100, 0)
	local newMax = math.floor(UiSlider("dot",  "x", maxs / 256, 0, 256) * 256)
	if newMax ~= maxs then SetInt("savegame.mod.combined.gravitycollapse_max_samples", newMax) end
	UiPop()

	UiTranslate(0, 0)
	UiText("Cache Grid (m):")
	UiTranslate(150, 0)
	local grid = GetFloat("savegame.mod.combined.gravitycollapse_cache_grid")
	UiText(string.format("%.2f", grid))
	UiTranslate(-150, 30)
	UiPush()
	UiTranslate(-100, 0)
	local newGrid = UiSlider("dot", "x", (grid - 0.05) / 1.95, 0, 1) * 1.95 + 0.05
	if math.abs(newGrid - grid) > 0.001 then SetFloat("savegame.mod.combined.gravitycollapse_cache_grid", newGrid) end
	UiPop()

	UiTranslate(0, 0)
	UiText("Cache TTL (s):")
	UiTranslate(150, 0)
	local ttl = GetFloat("savegame.mod.combined.gravitycollapse_cache_ttl")
	UiText(string.format("%.2f", ttl))
	UiTranslate(-150, 30)
	UiPush()
	UiTranslate(-100, 0)
	local newTtl = UiSlider("dot", "x", (ttl - 0.1) / 9.9, 0, 1) * 9.9 + 0.1
	if math.abs(newTtl - ttl) > 0.001 then SetFloat("savegame.mod.combined.gravitycollapse_cache_ttl", newTtl) end
	UiPop()

	UiTranslate(0, 0)
	UiText("Invalidate Cache on Check:")
	UiTranslate(150, 0)
	local inv = GetBool("savegame.mod.combined.gravitycollapse_cache_invalidate_on_check")
	if inv then UiColor(0.5,1,0.5) else UiColor(0.7,0.7,0.7) end
	if UiTextButton("Invalidate: " .. (inv and "ON" or "OFF"), 160, 28) then SetBool("savegame.mod.combined.gravitycollapse_cache_invalidate_on_check", not inv) end
	UiColor(1,1,1)
	UiTranslate(-150, 30)

	UiTranslate(0, 0)
	UiText("Profiler Overlay:")
	UiTranslate(150, 0)
	local prof = GetBool("savegame.mod.combined.gravitycollapse_profiler")
	if prof then UiColor(0.5,1,0.5) else UiColor(0.7,0.7,0.7) end
	if UiTextButton("Profiler: " .. (prof and "ON" or "OFF"), 160, 28) then SetBool("savegame.mod.combined.gravitycollapse_profiler", not prof) end
	UiColor(1,1,1)
	UiTranslate(-150, 30)

    -- Debris cleanup settings
    UiTranslate(0, 50)
    UiText("Debris Cleanup:")
    UiTranslate(0, 30)

    local cleanupEnabled = GetBool("savegame.mod.combined.ibsit_debris_cleanup")
    if cleanupEnabled then
        UiColor(0.5, 1, 0.5)
    else
        UiColor(0.7, 0.7, 0.7)
    end
    if UiTextButton("Auto Cleanup (" .. (cleanupEnabled and "ON" or "OFF") .. ")", 200, 30) then
        SetBool("savegame.mod.combined.ibsit_debris_cleanup", not cleanupEnabled)
    end

    UiTranslate(0, 40)
    UiColor(1, 1, 1)
    UiText("Cleanup Delay:")
    UiTranslate(150, 0)
    local delay = GetFloat("savegame.mod.combined.ibsit_cleanup_delay")
    UiText(string.format("%.1f", delay) .. "s")

    -- FPS optimization settings
    UiTranslate(0, 50)
    UiText("Performance:")
    UiTranslate(0, 30)

    local fpsEnabled = GetBool("savegame.mod.combined.ibsit_fps_optimization")
    if fpsEnabled then
        UiColor(0.5, 1, 0.5)
    else
        UiColor(0.7, 0.7, 0.7)
    end
    if UiTextButton("FPS Optimization (" .. (fpsEnabled and "ON" or "OFF") .. ")", 200, 30) then
        SetBool("savegame.mod.combined.ibsit_fps_optimization", not fpsEnabled)
    end

    UiTranslate(0, 40)
    UiColor(1, 1, 1)
    UiText("Target FPS:")
    UiTranslate(150, 0)
    local targetFps = GetInt("savegame.mod.combined.ibsit_target_fps")
    UiText(tostring(targetFps))
end
