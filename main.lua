#include "umf/umf_meta.lua"
#include "slimerand.lua"
#include "slimegcfunc.lua"

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
local perry = 1

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

-- IBSIT Settings
local ibsit_momentum = GetInt("savegame.mod.combined.ibsit_momentum")
local ibsit_dust_amt = GetInt("savegame.mod.combined.ibsit_dust_amt")
local ibsit_wood_size = GetInt("savegame.mod.combined.ibsit_wood_size")
local ibsit_stone_size = GetInt("savegame.mod.combined.ibsit_stone_size")
local ibsit_metal_size = GetInt("savegame.mod.combined.ibsit_metal_size")

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

-- IBSIT calculated values
local wb_ibsit, mb_ibsit, hb_ibsit = ibsit_wood_size / 100, ibsit_stone_size / 100, ibsit_metal_size / 100
local threshold_ibsit = 2 ^ ibsit_momentum
local rthreshold_ibsit = 5 / threshold_ibsit
local dust_ibsit = 4096 / ibsit_dust_amt
local rdust_ibsit = 1 / dust_ibsit
local fdust_ibsit = ibsit_dust_amt

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

	-- IBSIT initialization
	if TOG_IMPACT then
		local shapes = GetBodyShapes(GetWorldBody())
		for shape = #shapes, 1, -1 do
			shape = shapes[shape]
			if not IsShapeDisconnected(shape) then
				SetTag(shape, "inherittags")
				SetTag(shape, "parent_shape", shape)
			end
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

	-- IBSIT processing
	if TOG_IMPACT and not ibsit_triggered then
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

			QueryRequire("physical dynamic large")
			local bodies = QueryAabbBodies({breakpoint[1] - breaksize, breakpoint[2] - breaksize, breakpoint[3] - breaksize}, {breakpoint[1] + breaksize, breakpoint[2] + breaksize, breakpoint[3] + breaksize})
			for body = #bodies, 1, -1 do
				body = bodies[body]
				if not time[body] and IsBodyBroken(body) and IsBodyActive(body) then
					local dist = GetBodyVoxelCount(body)
					local lp = tonumber(GetTagValue(body, "likely_unbreakable"))
					if lp then
						if lp ~= dist then
							lp = SetTag(body, "likely_unbreakable", dist)
						end
					end
					if not lp then
						if dist > 1024 or VecLength(GetBodyVelocity(body)) * GetBodyMass(body) > threshold_ibsit then
							SetTag(body, "spd")
							dist = log(dist + 1)
							local tr = GetBodyTransform(body)
							lp = TransformToParentPoint(tr, breakpoint)
							dist = VecLength(VecSub(lp, GetBodyCenterOfMass(body))) < dist
							pos[body], pos[-body], vel[-body], time[body], time[-body], ind_ibsit = lp, dist and tr.pos or breakpoint, dist, true, 1, true
						end
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
							if (mass > (crum_MinMass / 8)) and (vector_len > ((crum_MinSpd) / 20))) and vector_len < ((crum_MaxSpd)) then
								if ((wood_breakage * crum_dist / 500) + (stone_breakage * crum_dist / 500) + (metal_breakage * crum_dist / 500)) > (0.25 * crum_dist) then
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
	if ind_ibsit then
		gcl = FindBodies("spd", true)
		if #gcl == 0 then vel, pos, time, ind_ibsit = {}, {}, {}, false; return end
		for i = #gcl, 1, -1 do
			local body = gcl[i]
			local val = GetTagValue(body, "spd")
			if val == "uninit" then
				local val_pos = vel[-body] and GetBodyTransform(body).pos or TransformToParentPoint(GetBodyTransform(body), pos[body])
				if VecLength(VecSub(val_pos, pos[-body])) > 0.125 then
					vel[body] = vel[-body] and GetBodyVelocity(body) or GetBodyVelocityAtPos(body, val_pos)
					SetTag(body, "spd", "calc")
				end
			elseif val == "" then
				SetTag(body, "spd", "uninit")
			elseif val == "gc" then
				vel[body], vel[-body], time[body], time[-body], pos[body], pos[-body], val = RemoveTag(body, "spd"), nil, nil, nil, nil, nil, #gcl
				gcl[i] = gcl[val]
				gcl[val] = nil
			end
		end
		for co = #breaklist, 1, -1 do
			local _, ret = coroutine.resume(breaklist[co])
			if ret ~= true then
				ret = #breaklist
				breaklist[co] = breaklist[ret]
				breaklist[ret] = nil
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
end

-- PostUpdate function
function postUpdate()
	if ind_ibsit then
		for body = #gcl, 1, -1 do
			body = gcl[body]
			if IsHandleValid(body) then
				local val = GetTagValue(body, "spd")
				if val == "calc" then
					local c, s
					if vel[-body] then
						c, s = GetBodyTransform(body).pos, GetBodyVelocity(body)
					else
						c = TransformToParentPoint(GetBodyTransform(body), pos[body])
						s = GetBodyVelocityAtPos(body, c)
					end
					if VecLength(s) < 32 then
						local a = VecSub(vel[body], s)
						if VecDot(a, vel[body]) > 0.0678 then
							local sa = GetBodyMass(body)
							a, val = VecLength(a) * sa, GetBodyVoxelCount(body)
							if sa < val * 0.5 or val * 10 < sa then
								a = a * 0.015625
							end
							if pos[-body] then
								sa = VecLength(VecSub(c, pos[-body]))
								if sa < 0.5 then
									a = a * sa * 2
								else
									pos[-body] = nil
								end
							end
							if a > threshold_ibsit then
								if vel[-body] then
									c = TransformToParentPoint(GetBodyTransform(body), pos[body])
								end
								sa = co_create(breaks_ibsit)
								_, val = co_resume(sa, body, c, s, a * rthreshold_ibsit - 4)
								if val == true then
									breaklist[#breaklist + 1] = sa
									val = GetBodyVoxelCount(body)
									if val > 1024 * time[-body] or VecLength(s) * GetBodyMass(body) > threshold_ibsit * time[-body] then
										sa = VecLerp(c, rndPnt(GetBodyBounds(body)), math.random())
										val = log(val + 1)
										c = GetBodyTransform(body)
										s = TransformToParentPoint(c, sa)
										val = VecLength(VecSub(s, GetBodyCenterOfMass(body))) < val
										pos[body], pos[-body], vel[-body], time[body], time[-body] = s, val and c.pos or sa, val, true, time[-body] + 1
										SetTag(body, "spd", "uninit")
										sa = nil
									end
								end
								if sa then
									SetTag(body, "spd", "gc")
								end
							else
								vel[body] = s
							end
						else
							vel[body], time[body] = s, false
						end
					else
						SetTag(body, "autobreak")
						SetTag(body, "spd", "hs")
						time[body] = true
						vel[body] = s
					end
				elseif val == "hs" then
					val = vel[-body] and GetBodyVelocity(body) or GetBodyVelocityAtPos(body, TransformToParentPoint(GetBodyTransform(body), pos[body]))
					if VecLength(val) < 32 then
						RemoveTag(body, "autobreak")
						SetTag(body, "spd", "calc")
					end
					vel[body] = val
				end
			else
				vel[body], vel[-body], time[body], time[-body], pos[body], pos[-body] = nil, nil, nil, nil, nil, nil
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

    local pages = {"Main", "FPS&Dust", "Crumble", "Explosions", "Force&Fire", "Advanced"}
    local currentPage = GetInt("savegame.mod.combined.options_page") or 1

    for i, pageName in ipairs(pages) do
        UiPush()
        UiTranslate((i - 3.5) * 120, 0)

        if currentPage == i then
            UiColor(0.5, 1, 0.5)
        else
            UiColor(0.7, 0.7, 0.7)
        end

        if UiTextButton(pageName, 100, 40) then
            SetInt("savegame.mod.combined.options_page", i)
        end
        UiPop()
    end

    -- Draw current page content
    UiTranslate(0, 50)
    DrawPageContent(currentPage)
end

function DrawPageContent(page)
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
    local newFps = math.floor(UiSlider("dot", "x", (fps - 30) / 54, 0, 100) * 54 + 30)
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
    local newDust = math.floor(UiSlider("dot", "x", dust / 200, 0, 100) * 200)
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
        local newValue = math.floor(UiSlider("dot", "x", value / setting[3], 0, 100) * setting[3])
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
        local newValue = math.floor(UiSlider("dot", "x", value / setting[4], 0, 100) * setting[4])
        if newValue ~= value then
            SetInt(setting[2], newValue)
        end

        UiPop()
    end
end

function DrawForceFirePage()
    UiTranslate(-200, -100)

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
    local newForce = math.floor(UiSlider("dot", "x", force / 240, 0, 100) * 240)
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
        local newValue = math.floor(UiSlider("dot", "x", value / setting[3], 0, 100) * setting[3])
        if newValue ~= value then
            SetInt(setting[2], newValue)
        end

        UiPop()
    end

    -- Reset button
    UiTranslate(0, 200)
    if UiTextButton("Reset All Settings", 200, 40) then
        ResetAllSettings()
    end
end

function ResetAllSettings()
    -- Reset main toggles
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

    -- Reset key settings to defaults
    SetInt("savegame.mod.combined.FPS_Targ", 30)
    SetInt("savegame.mod.combined.dust_amt", 50)
    SetInt("savegame.mod.combined.dust_size", 100)
    SetInt("savegame.mod.combined.crum_DMGLight", 50)
    SetInt("savegame.mod.combined.crum_DMGMed", 50)
    SetInt("savegame.mod.combined.crum_DMGHeavy", 50)
    SetInt("savegame.mod.combined.xplo_szBase", 35)
    SetInt("savegame.mod.combined.xplo_chance", 4)
    SetInt("savegame.mod.combined.force_strength", 35)
    SetInt("savegame.mod.combined.fyr_chance", 1)
    SetInt("savegame.mod.combined.ibsit_momentum", 12)
    SetInt("savegame.mod.combined.mbcs_mass", 8)
end
