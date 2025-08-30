--[[
#include "slimerand.lua"
#include "slimegcfunc.lua"
--]]

--prelude(){
	local random, sqrt = math.random, math.sqrt
	--localize some math function
	math.randomseed(tonumber(tostring(newproxy(false)):sub(19, -2), 16))
	local rndVec, rangedVec = Fastrnd.Ball.UnitVec, Fastrnd.Sphere.RangedVec
	local vratio = 1 / 16384
	local sratio = 3 / 4096
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
			if IsBodyJointedToStatic(body) and IsBodyDynamic(body) then
				SetTag(body, "tgt")
			end
		end
	end
end

--[[
	tag values for update check
	"uninit"
	"calc"
	"hs"
	
--]]

--optionals(){
	local wb, mb, hb = GetInt("savegame.mod.wood_size") / 100, GetInt("savegame.mod.stone_size") / 100, GetInt("savegame.mod.metal_size") / 100
	local threshold = 2 ^ GetInt("savegame.mod.momentum")
	local rthreshold = 5 / threshold
	local dust = 4096 / GetInt("savegame.mod.dust_amt")
	local fdust = GetInt("savegame.mod.dust_amt")
	local rdust = 1 / dust
	local vehicle = not GetBool("savegame.mod.vehicle")
	local joint = not GetBool("savegame.mod.joint")
	local protect = not GetBool("savegame.mod.protection")
--}

--vars(){
	-- weird way to get random seed, probably ub
	local triggered, name = false, "IBSIT Enabled"
	-- neg vel = time, neg pos = wpos
	local vel, pos, time, gcl = {}, {}, {}, {}
	local ind = nil
--}

local function GetBodyVoxelCount(body)
	local count = 0
	body = GetBodyShapes(body)
	for i = #body, 1, -1 do
		count = count + GetShapeVoxelCount(body[i])
	end
	return count
end

function upongc()
	for body = #gcl, 1, -1 do
		body = gcl[body]
		if not IsBodyActive(body) then
			SetTag(body, "spd", "gc")
		end
	end
end

function tick()
	if PauseMenuButton(name) then
		triggered = not triggered
		name = triggered and "IBSIT Disabled" or "IBSIT Enabled"
		SetPaused(false)
	end
	if triggered or not HasKey("game.break") then return end
	local breaksize, breakpoint, list = GetFloat("game.break.size"), {GetFloat("game.break.x"), GetFloat("game.break.y"), GetFloat("game.break.z")}
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
	QueryRequire("physical dynamic large")
	list = QueryAabbBodies(VecSub(breakpoint, list), VecAdd(breakpoint, list))
	for body = #list, 1, -1 do
		body = list[body]
		if not time[body] and IsBodyBroken(body) and IsBodyActive(body) then
			SetTag(body, "spd", "uninit")
			-- speed properties and break position
			pos[body], ind = TransformToLocalPoint(GetBodyTransform(body), breakpoint), true
		end
	end
end

--[[local function largebreak(c, r)
	local d, tc = 0
	for i = r, 0, -5 do
		if tc then
			if random() < 0.5 then
				tc = VecAdd(c, rangedVec(r - i))
			else
				tc = VecAdd(tc, rangedVec(i))
			end
		else
			tc = c
		end
		d = d + MakeHole(tc, wb * i, mb * i, hb * i)
	end
	return d
end

local function central_largebreak(body, c, r)
	local d, tc = 0
	for i = r, 0, -5 do
		if tc then
			_, tc = GetBodyClosestPoint(body, VecAdd(c, rangedVec(r - i)))
		else
			tc = c
		end
		d = d + MakeHole(tc, wb * i, mb * i, hb * i)
	end
	return d
end

local function spread_largebreak(body, c, r)
	local d, tc = 0
	for i = r, 0, -5 do
		if tc then
			_, tc = GetBodyClosestPoint(body, VecAdd(tc, rangedVec(5)))
		else
			tc = c
		end
		d = d + MakeHole(tc, wb * i, mb * i, hb * i)
	end
	return d
end]]

--[[local function check(body)
	local c, a = TransformToParentPoint(GetBodyTransform(body), pos[body]), VecLength(vel[body])
	local s, d = GetBodyVelocityAtPos(body, c), VecLength(VecSub(pos[-body], c))
	-- speed calculations
	if HasTag(body, "autobreak") then
		if a < 32 or d < 0.015625 then
			RemoveTag(body, "autobreak")
		end
	else
		if d > 0.015625 then
			if a > 32 then
				SetTag(body, "autobreak")
			else
				a = VecSub(vel[body], s)
				if VecDot(a, vel[body]) > 0.015625 then
					a = VecLength(a) * GetBodyMass(body)
					if d < 0.03125 then a = a * d * 32 end
					if a > threshold then
						_, c, _, d = GetBodyClosestPoint(body, VecAdd(c, rndVec()))
						-- scale impulse to percentage, crash and burn
						-- use pre-calculated fractions instead of dividing which costs more performance
						a = largebreak(c, ln(a) * ratio - lnthreshold)  -- 4 * log[5](a / threshold) + 1, real break radius
						if a > dust then
							local sr, sg, sb, sa
							_, sr, sg, sb, sa, d = GetShapeMaterialAtPosition(d, c)
							if a < 4096 then
								a = a * rdust
							else
								a = fdust
							end
							if d ~= 0 then
								sr, sg, sb = (sr + 0.6) * 0.5, (sg + 0.55) * 0.5, (sb + 0.5) * 0.5
							else
								sr, sg, sb, sa = 0.6, 0.55, 0.5, 1
							end
							ParticleColor(sr, sg, sb)
							ParticleAlpha(sa, 0, "easein")
							for _ = a, 1, -1 do
								SpawnParticle(VecAdd(c, rndVec()), s, random() * 5)
							end	
						end
						pos[body], pos[-body], vel[body], time[body] = TransformToLocalPoint(GetBodyTransform(body), c), c, GetBodyVelocityAtPos(body, c), 0
						return
					end
				end
			end
		end
	end
	if time[body] then
		pos[-body], vel[body], time[body] = c, s, time[body] + 1
	end
end]]

function update()
	if not ind then return end
	-- iterate through every single one
	gcl = FindBodies("spd", true)
	if #gcl == 0 then vel, pos, time, ind = {}, {}, {}, false; return end
	for body = #gcl, 1, -1 do
		body = gcl[body]
		local val = GetTagValue(body, "spd")
		if val == "uninit" then
			vel[body], time[body] = GetBodyVelocityAtPos(body, TransformToParentPoint(GetBodyTransform(body), pos[body])), true
			if VecLength(vel[body]) < 32 then
				SetTag(body, "spd", "calc")
			else
				SetTag(body, "autobreak")
				SetTag(body, "spd", "hs")
			end
		elseif val == "gc" then
			vel[body], time[body], pos[body] = RemoveTag(body, "spd"), nil, nil
		end
	end
end

function postPhysicsUpdate()
	if not ind then return end
	ParticleType("smoke")
	ParticleDrag(0, 1, "easeout")
    ParticleStretch(1, 0, "easein")
    ParticleGravity(-0.1)
	ParticleColor(0.6, 0.55, 0.5)
	ParticleAlpha(1, 0, "easein")
	for body = #gcl, 1, -1 do
		body = gcl[body]
		local val = GetTagValue(body, "spd")
		if val == "calc" then
			local c = TransformToParentPoint(GetBodyTransform(body), pos[body])
			local s = GetBodyVelocityAtPos(body, c)
			-- speed calculations
			if VecLength(vel[body]) < 32 then
				local a = VecSub(vel[body], s)
				if VecDot(a, vel[body]) > 0.0678 then
					local sa = GetBodyMass(body)
					a, val = VecLength(a) * sa, GetBodyVoxelCount(body)
					if val < 16384 then
						a = a * val * vratio
					end
					if sa < val * 0.5 or val * 10 < sa then
						a = a * 0.015625
					end
					if a > threshold then
						-- scale impulse to percentage, crash and burn
						-- use pre-calculated fractions instead of dividing which costs more performance
						--[[a = sqrt(a * rthreshold)
						if a > 5 then
							Shoot(c, rndUnit(), "shotgun", ln(a) * ratio, 0.015625)
							a = MakeHole(c, wb * a, mb * a, hb * a) * a * 0.125
						else
							a = MakeHole(c, wb * a, mb * a, hb * a)
						end]]
						local sr, sg, sb, tc
						for i = sqrt(a * rthreshold), 0, -5 do
							_, tc, _, val = GetBodyClosestPoint(body, tc and VecAdd(tc, rangedVec(5)) or c)
							_, sr, sg, sb, sa, val = GetShapeMaterialAtPosition(val, tc)
							a = MakeHole(tc, wb * i, mb * i, hb * i)
							if a > dust then
								if val ~= 0 then
									sr, sg, sb = sr * 0.5 + 0.3, sg * 0.5 + 0.275, sb * 0.5 + 0.25
								else
									sr, sg, sb, sa = 0.6, 0.55, 0.5, 1
								end
								if a < 4096 then
									a, val = a * rdust, a * sratio
								else
									a, val = fdust, 3
								end
								ParticleColor(sr, sg, sb)
								ParticleAlpha(sa, 0, "easein")
								ParticleRadius(0.1, val, "easeout")
								for _ = a, 1, -1 do
									SpawnParticle(VecAdd(tc, rndVec()), s, random() * 5)
								end
							end
						end
						--a = spread_largebreak(body, c, sqrt(a * rthreshold))
						pos[body] = TransformToLocalPoint(GetBodyTransform(body), tc)
						SetTag(body, "spd", "uninit")
					else
						vel[body] = s
					end
				else
					vel[body], time[body] = s, false
				end
			else
				vel[body] = s
				SetTag(body, "autobreak")
				SetTag(body, "spd", "hs")
			end
		elseif val == "hs" then
			if VecLength(vel[body]) < 32 then
				RemoveTag(body, "autobreak")
				SetTag(body, "spd", "calc")
			end
			vel[body] = GetBodyVelocityAtPos(body, TransformToParentPoint(GetBodyTransform(body), pos[body]))
		end
	end
end