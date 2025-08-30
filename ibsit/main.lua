--[[
#include "slimerand.lua"
#include "slimegcfunc.lua"
--]]

--prelude(){
	-- localize some math function
	local random, sqrt, log = math.random, math.sqrt, math.log
	local co_create, co_resume, co_yield = coroutine.create, coroutine.resume, coroutine.yield
	-- weird way to get random seed, probably ub
	math.randomseed(tonumber(tostring(newproxy(false)):sub(19, -2), 16))
	local addrndVec, addrangedVec = Fastrnd.AddNewBall.UnitVec, Fastrnd.IterateBall.RangedVec
	--local vratio = 1 / 16384
	--local dratio = 2 / 3
	local sratio = 3 / 4096
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
	--[[if not GetBool("savegame.mod.joint") then
		local foo = FindJoints(nil, true)
		for bar = #foo, 1, -1 do
			bar = GetJointShapes(foo[bar])
			for baz = #bar, 1, -1 do
				baz = GetShapeBody(bar[baz])
				if IsBodyDynamic(baz) and IsBodyJointedToStatic(baz) then
					SetTag(baz, "tgt")
				end
			end
		end
	end]]
end

--[[
	tag values for update check
	"uninit"
	"calc"
	"hs"
	"gc"
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
	local triggered, name = false, "IBSIT Enabled"
	-- neg vel = time, neg pos = wpos
	local vel, pos, time, breaklist, gcl = {}, {}, {}, {}, {}
	local ind = nil
	local cached_breaksize, cached_breakpoint, available_breaksize, available_breakpoint, last_frame
--}

local function GetBodyVoxelCount(body)
	local count = 0
	body = GetBodyShapes(body)
	for i = #body, 1, -1 do
		count = count + GetShapeVoxelCount(body[i])
	end
	return count
end

local function rndPnt(a, b)
	return {a[1] + (b[1] - a[1]) * random(), a[2] + (b[2] - a[2]) * random(), a[3] + (b[3] - a[3]) * random()}
end

function upongc()
	--t = FindBodies("spd", true)
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

function tick()
	if PauseMenuButton(name) then
		triggered = not triggered
		name = triggered and "IBSIT Disabled" or "IBSIT Enabled"
		SetPaused(false)
	end
	if triggered then return end
	if last_frame then
		available_breaksize, available_breakpoint, last_frame = cached_breaksize, cached_breakpoint, false
	end
	if HasKey("game.explosion") then
		cached_breaksize, cached_breakpoint, last_frame = GetFloat("game.explosion.strength") * 2.2, {GetFloat("game.explosion.x"), GetFloat("game.explosion.y"), GetFloat("game.explosion.z")}, true
	end
	if not HasKey("game.break") then return end
	local breaksize, breakpoint, list = GetFloat("game.break.size")
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
	if vehicle then
		list = GetPlayerVehicle()
		if list ~= 0 then
			list = GetVehicleBodies(list)
			for i = #list, 1, -1 do
				QueryRequire("physical dynamic large")
				list[i] = QueryAabbBodies(GetBodyBounds(list[i]))
			end
			for i = #list, 1, -1 do
				QueryRejectBodies(list[i])
			end
		end
		list = FindVehicles(nil, true)
		for i = #list, 1, -1 do
			QueryRejectVehicle(list[i])
		end
	end
	if protect then QueryRejectBodies(FindBodies("leave_me_alone", true)) end
	--[[if joint then
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
	end]]
	-- update object list in map around break position
	QueryRequire("physical dynamic large")
	list = QueryAabbBodies({breakpoint[1] - breaksize, breakpoint[2] - breaksize, breakpoint[3] - breaksize}, {breakpoint[1] + breaksize, breakpoint[2] + breaksize, breakpoint[3] + breaksize})
	for body = #list, 1, -1 do
		body = list[body]
		if not time[body] and IsBodyBroken(body) and IsBodyActive(body) then
			-- speed properties and break position
			local dist = GetBodyVoxelCount(body)
			local lp = tonumber(GetTagValue(body, "likely_unbreakable"))
			if lp then
				if lp ~= dist then
					lp = SetTag(body, "likely_unbreakable", dist)
				end
			end
			if not lp then
				if dist > 1024 or VecLength(GetBodyVelocity(body)) * GetBodyMass(body) > threshold and (joint and IsBodyJointedToStatic(body)) then
					SetTag(body, "spd") -- intentional to postpone it to next update
					dist = log(dist + 1)
					local tr = GetBodyTransform(body)
					lp = TransformToLocalPoint(tr, breakpoint)
					dist = VecLength(VecSub(lp, GetBodyCenterOfMass(body))) < dist
					pos[body], pos[-body], vel[-body], time[body], time[-body], ind = lp, dist and tr.pos or breakpoint, dist, true, 1, true
				end
			end
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

function update()
	if not ind then return end
	-- iterate through every single one
	gcl = FindBodies("spd", true)
	if #gcl == 0 then vel, pos, time, ind = {}, {}, {}, false; return end
	for i = #gcl, 1, -1 do
		local body = gcl[i]
		--[[if vel[-body] then
			DrawBodyOutline(body, 1)
		end]]
		if time[-body] then
			local val = GetTagValue(body, "spd")
			if val == "uninit" then
				val = vel[-body] and GetBodyTransform(body).pos or TransformToParentPoint(GetBodyTransform(body), pos[body])
				if VecLength(VecSub(val, pos[-body])) > 0.125 then
					vel[body] = vel[-body] and GetBodyVelocity(body) or GetBodyVelocityAtPos(body, val)
					SetTag(body, "spd", "calc")
				end
			elseif val == "" then
				SetTag(body, "spd", "uninit")
			elseif val == "gc" then
				vel[body], vel[-body], time[body], time[-body], pos[body], pos[-body], val = RemoveTag(body, "spd"), nil, nil, nil, nil, nil, #gcl
				gcl[i] = gcl[val]
				gcl[val] = nil
			end
		else
			local v = #gcl
			gcl[i] = gcl[val]
			gcl[val] = RemoveTag(body, "spd")
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

local function breaks(body, c, s, a)
	local sr, sg, sb, tc, shape
	--[[repeat

	until i < 0]]
	for i = sqrt(a), 0, -5 do
		_, tc, _, shape = GetBodyClosestPoint(body, tc and addrangedVec(tc, 5.5) or c)
		shape, sr, sg, sb, sa = GetShapeMaterialAtPosition(shape, tc)
		a = MakeHole(tc, wb * i, mb * i, hb * i)
		if a > dust then
			local x
			if a < 4096 then
				x, c = a * rdust, a * sratio
			else
				x, c = fdust, 3
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
			--[[ParticleColor(0.6, 0.55, 0.5)
			ParticleAlpha(1, 0, "easein")
			ParticleColor(sr, sg, sb)
			ParticleAlpha(sa, 0, "easein")]]
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

function postUpdate()
	if not ind then return end
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
					-- speed calculations
					local a = VecSub(vel[body], s)
					if VecDot(a, vel[body]) > 0.0678 then
						local sa = GetBodyMass(body)
						a, val = VecLength(a) * sa, GetBodyVoxelCount(body)
						--[[if val < 16384 then
							a = a * val * vratio
						end]]
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
						if a > threshold then
							-- scale impulse to percentage, crash and burn
							-- use pre-calculated fractions instead of dividing which costs more performance
							if vel[-body] then
								c = TransformToParentPoint(GetBodyTransform(body), pos[body])
							end
							sa = co_create(breaks)
							_, val = co_resume(sa, body, c, s, a * rthreshold - 4) -- lifetime of all local vars ends here
							if val == true then
								breaklist[#breaklist + 1] = sa
								val = GetBodyVoxelCount(body)
								if val > 1024 * time[-body] or VecLength(s) * GetBodyMass(body) > threshold * time[-body] then
									sa = VecLerp(c, rndPnt(GetBodyBounds(body)), random())
									val = log(val + 1)
									c = GetBodyTransform(body)
									s = TransformToLocalPoint(c, sa)
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