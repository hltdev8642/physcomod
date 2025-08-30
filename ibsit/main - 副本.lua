--[[
#include "slimerand.lua"
--]]

--prelude(){
	local random, ln = math.random, math.log
	--localize some math function
	math.randomseed(tonumber(tostring(newproxy(false)):sub(19, -2), 16))
	local rndVec, rangedVec = Fastrnd.Ball.UnitVec, Fastrnd.Ball.RangedVec
	local ratio = 4 / ln(5) -- log[5](a) = ln(a)/ln(5)
--}

function init()
	-- acquire voxel list for static shapes
	if not HasKey("savegame.mod") then
		SetInt("savegame.mod.dust_amt", 50)
		SetInt("savegame.mod.wood_size", 100)
		SetInt("savegame.mod.stone_size", 75)
		SetInt("savegame.mod.metal_size", 50)
		SetInt("savegame.mod.momentum", 12)
		SetBool("savegame.mod.vehicle", false)
		SetBool("savegame.mod.joint", false)
		SetBool("savegame.mod.protection", false)
	end
	if not GetBool("savegame.mod.joint") then
		local bodies = FindBodies(nil, true)
		for body = #bodies, 1, -1 do
			body = bodies[body]
			if IsBodyDynamic(body) and IsBodyJointedToStatic(body) then
				SetTag(body, "tgt")
			end
		end
	end
end

--optionals(){
	local wb, mb, hb = GetInt("savegame.mod.wood_size") / 100, GetInt("savegame.mod.stone_size") / 100, GetInt("savegame.mod.metal_size") / 100
	local threshold = 2 ^ GetInt("savegame.mod.momentum")
	local lnthreshold = ln(threshold) * ratio - 1 -- ln(a / b) = ln(a) - ln(b), here is log[5](threshold) - 1
	local dust = 4096 / GetInt("savegame.mod.dust_amt")
	local rdust = 1 / dust
	local vehicle = not GetBool("savegame.mod.vehicle")
	local joint = not GetBool("savegame.mod.joint")
	local protect = not GetBool("savegame.mod.protection")
--}

--vars(){
	-- weird way to get random seed, probably ub
	local triggered, name = false, "IBSIT Enabled"
	local vel, lpos, wpos = {}, {}, {}
--}

local function CheckBody(body)
	if HasTag(body, "nopass") then return end
	local count = tonumber(GetTagValue(body, "spd"))
	if count and count < 60 then return end
	count = 0
	local list = GetBodyShapes(body)
	for i = #list, 1, -1 do
		count = count + GetShapeVoxelCount(list[i])
	end
	if count > 1024 then
		list = GetBodyMass(body)
		if list > 100000 or count * 0.5 < list and count * 10 > list then -- 0.5 < rho < 10
			return IsBodyBroken(body) and IsBodyActive(body)
		end
	end
	return SetTag(body, "nopass") -- memorize false bodies to save performance
end

function tick()
	if PauseMenuButton(name) then
		triggered = not triggered
		name = triggered and "IBSIT Disabled" or "IBSIT Enabled"
		SetPaused(false)
	end
	if triggered then return end
	local breaksize = GetFloat("game.break.size")
	if breaksize < 0.5 then return end
	local breakpoint, list = {GetFloat("game.break.x"), GetFloat("game.break.y"), GetFloat("game.break.z")}
	if protect then
		list = FindBodies("leave me alone", true)
		for i = #list, 1, -1 do
			QueryRejectBody(list[i])
		end
	end
	if vehicle then
		list = FindVehicles(nil, true)
		for i = #list, 1, -1 do
			QueryRejectVehicle(list[i])
		end
	end
	if joint then
		list = FindBodies("tgt", true)
		for body = #list, 1, -1 do
			body = list[body]
			if IsBodyActive(body) then
				if IsBodyJointedToStatic(body) then
					QueryRejectBody(body)
				else
					RemoveTag(body, "tgt")
				end
			end
		end
	end
	-- update object list in map around break position
	list = {breaksize, breaksize, breaksize}
	QueryRequire("physical dynamic large visible")
	list = QueryAabbBodies(VecSub(breakpoint, list), VecAdd(breakpoint, list))
	for body = #list, 1, -1 do
		body = list[body]
		if CheckBody(body) then
			SetTag(body, "spd", 0)
			-- speed properties and break position
			vel[body], lpos[body], wpos[body] = GetBodyVelocityAtPos(body, breakpoint), TransformToLocalPoint(GetBodyTransform(body), breakpoint), breakpoint
		end
	end
end

local function check(body)
	local c = TransformToParentPoint(GetBodyTransform(body), lpos[body])
	local s = GetBodyVelocityAtPos(body, c)
	-- speed calculations
	if VecLength(s) < 32 then
		RemoveTag(body, "autobreak")
	else
		SetTag(body, "autobreak")
	end
	local a = VecSub(vel[body], s)
	if VecDot(a, vel[body]) > 0.015625 and VecLength(VecSub(wpos[body], c)) > 0.015625 then
		a = VecLength(a) * GetBodyMass(body)
		if a > threshold then
			local sr, sg, sb, sa, se, tc
			_, c, _, se = GetBodyClosestPoint(body, VecAdd(c, rndVec()))
			_, sr, sg, sb, sa, se = GetShapeMaterialAtPosition(se, c)
			if se ~= 0 then
				ParticleColor((sr + 0.6) * 0.5, (sg + 0.55) * 0.5, (sb + 0.5) * 0.5)
				ParticleAlpha(sa, 0, "easein")
			else
				ParticleColor(0.6, 0.55, 0.5)
				ParticleAlpha(1, 0, "easein")
			end
			-- scale impulse to percentage, crash and burn
			-- use pre-calculated fractions instead of dividing which costs more performance
			a = ln(a) * ratio - lnthreshold -- 4 * log[5](a / threshold) + 1, real break radius
			for i = a, 1, -5 do
				if i ~= a then
					if random() < 0.5 then
						tc = VecAdd(c, rangedVec(a - i))
					else
						tc = VecAdd(tc, rangedVec(i))
					end
				else
					tc = c
				end
				i = MakeHole(tc, wb * i, mb * i, hb * i)
				-- only large breakage will spawn particles
				if i > dust then
					if i > 4096 then i = 4096 end
					for _ = i * rdust, 1, -1 do
						SpawnParticle(VecAdd(tc, rndVec()), s, random() * 5)
					end	
				end
			end
			lpos[body], wpos[body], vel[body] = TransformToLocalPoint(GetBodyTransform(body), c), c, GetBodyVelocityAtPos(body, c)
			return SetTag(body, "spd", 0)
		end
	else
		wpos[body], vel[body] = c, s
		return SetTag(body, "spd", tonumber(GetTagValue(body, "spd")) + 1)
	end
end

function update()
	-- iterate through every single one
	local list = FindBodies("spd", true)
	if #list == 0 then return end
	ParticleType("smoke")
	ParticleDrag(0, 1, "easeout")
    ParticleStretch(1, 0, "easein")
    ParticleGravity(-0.1)
	ParticleRadius(0.1, 3, "easeout")
	ParticleColor(0.6, 0.55, 0.5)
	ParticleAlpha(1, 0, "easein")
	for body = #list, 1, -1 do
		body = list[body]
		if IsBodyActive(body) then
			check(body)
		else
			vel[body], lpos[body], wpos[body] = RemoveTag(body, "spd"), nil, nil
		end
	end
end
