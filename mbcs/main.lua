--[[
#include "slimerand.lua"
#include "slimegcfunc.lua"
--]]

--prelude(){
	local random, sqrt = math.random, math.sqrt
	local co_create, co_resume, co_yield = coroutine.create, coroutine.resume, coroutine.yield
	--localize some math function
	math.randomseed(tonumber(tostring(newproxy(false)):sub(19, -2), 16))
	local addrndVec, addrangedVec = Fastrnd.AddNewBall.UnitVec, Fastrnd.IterateBall.RangedVec
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

--optionals(){
	if not HasKey("savegame.mod") then
		SetInt("savegame.mod.dust_amt", 50)
		SetInt("savegame.mod.wood_size", 100)
		SetInt("savegame.mod.stone_size", 75)
		SetInt("savegame.mod.metal_size", 50)
		SetInt("savegame.mod.mass", 8)
		SetInt("savegame.mod.distance", 4)
	end
	local wb, mb, hb = GetInt("savegame.mod.wood_size") / 100, GetInt("savegame.mod.stone_size") / 100, GetInt("savegame.mod.metal_size") / 100
	local dist = GetInt("savegame.mod.distance")
	local threshold = 2 ^ GetInt("savegame.mod.mass")
	local rthreshold = 5 / threshold
	local dust = 4096 / GetInt("savegame.mod.dust_amt")
	local rdust = 1 / dust
	local fdust = GetInt("savegame.mod.dust_amt")
	local angle = 0.707 * dist
--}

local function GetBodyVoxelCount(body)
	local count = 0
	body = GetBodyShapes(body)
	for i = #body, 1, -1 do
		count = count + GetShapeVoxelCount(body[i])
	end
	return count
end

function init()
	-- acquire voxels for static shapes
	local shapes = GetBodyShapes(GetWorldBody())
	for shape = #shapes, 1, -1 do
		shape = shapes[shape]
		if not IsShapeDisconnected(shape) then
			SetTag(shape, "inherittags")
			SetTag(shape, "parent_shape", shape)
		end
	end
end

--vars(){
	local triggered, name = false, "MBCS Enabled"
	local shp, breaklist, gcl = {}, {}, {}
	local ind = nil
	local cached_breaksize, cached_breakpoint, available_breaksize, available_breakpoint, last_frame
	-- init values
--}

function upongc()
	for body = #gcl, 1, -1 do
		body = gcl[body]
		if not IsBodyActive(body) and IsHandleValid(body) then
			SetTag(body, "val", "gc")
		end
	end
end

--[[local function CheckShape(shape)
	if HasTag(shape, "nopass") then return end
	local count, coef = GetShapeVoxelCount(shape), tonumber(GetTagValue(shape, "coefficient"))
	if count > threshold and coef > 0.2 then
		return true
	end
	return SetTag(shape, "nopass")
end]]

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

local function central_largebreak(c, r)
	local d, tc = 0
	for i = r, 0, -5 do
		if tc then
			tc = VecAdd(c, rangedVec(r - i))
		else
			tc = c
		end
		d = d + MakeHole(tc, wb * i, mb * i, hb * i)
	end
	return d
end

local function spread_largebreak(c, r)
	local d, tc = 0
	for i = r, 0, -5 do
		if tc then
			tc = VecAdd(tc, rangedVec(i))
		else
			tc = c
		end
		d = d + MakeHole(tc, wb * i, mb * i, hb * i)
	end
	return d
end]]

function tick()
	if PauseMenuButton(name) then
		triggered = not triggered
		name = triggered and "MBCS Disabled" or "MBCS Enabled"
		SetPaused(false)
	end
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
	local watch, list = {}
	local min, max = {breakpoint[1] - breaksize, breakpoint[2] - breaksize, breakpoint[3] - breaksize}, {breakpoint[1] + breaksize, breakpoint[2] + breaksize, breakpoint[3] + breaksize}
	QueryRequire("physical static large")
	list = QueryAabbShapes(min, max)
	for shape = #list, 1, -1 do
		shape = list[shape]
		breaksize = tonumber(GetTagValue(shape, "parent_shape"))
		if not breaksize or breaksize ~= shape then
			SetTag(shape, "parent_shape", shape)
			SetTag(shape, "inherittags")
		else
			watch[shape] = IsShapeBroken(shape)
		end
	end
	QueryRequire("physical dynamic large")
	list = QueryAabbBodies(min, max)
	for body = #list, 1, -1 do
		body = list[body]
		if shp[body] == nil and IsBodyBroken(body) and IsBodyActive(body) and VecLength(GetBodyVelocity(body)) < 5 then
			breaksize, breakpoint = false, GetEntityChildren(body, "parent_shape", true, "shape")
			for shape = #breakpoint, 1, -1 do
				shape = breakpoint[shape]
				local tgt = tonumber(GetTagValue(shape, "parent_shape"))
				if watch[tgt] then
					breaksize, shp[shape], shp[tgt] = true, tgt, GetShapeBody(tgt)
				end
			end
			if breaksize then
				shp[body], ind = TransformToParentPoint(GetBodyTransform(body), GetBodyCenterOfMass(body)), true
				SetTag(body, "val", "uninit")
			else
				shp[body] = false
			end
		end
	end
end

function update()
	if not ind then return end
	-- iterate through every single one
	gcl = FindBodies("val", true)
	if #gcl == 0 then shp, ind = {}, false; return end
	for i = #gcl, 1, -1 do
		local body = gcl[i]
		local val = GetTagValue(body, "val")
		if val == "uninit" then
			shp[body], ind = TransformToParentPoint(GetBodyTransform(body), GetBodyCenterOfMass(body)), true
			SetTag(body, "val", "calc")
		elseif val == "gc" then
			val = GetEntityChildren(body, "parent_shape", true, "shape")
			for shape = #val, 1, -1 do
				RemoveTag(val[shape], "parent_shape")
			end
			shp[body], val = RemoveTag(body, "val"), gcl
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

local function breaks(shape, x, n, c)
	local sr, sg, sb, sa, e, tc
	for i = sqrt(x * rthreshold), 0, -5 do
		if tc then
			_, tc, n = GetShapeClosestPoint(shape, addrangedVec(tc, 5.5))
		else
			tc = c
		end
		e, sr, sg, sb, sa = GetShapeMaterialAtPosition(shape, tc)
		x = MakeHole(tc, wb * i, mb * i, hb * i)
		if x > dust then
			if x < 4096 then
				x, c = x * rdust, x * sratio
			else
				x, c = fdust, 3
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
					a = a * 0.25
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

function postUpdate()
	if not ind then return end
	for body = #gcl, 1, -1 do
		body = gcl[body]
		local val = GetTagValue(body, "val")
		if val == "calc" then
			local c = TransformToParentPoint(GetBodyTransform(body), GetBodyCenterOfMass(body))
			local d = VecSub(c, shp[body])
			if VecLength(d) > dist then
				local v, m = GetBodyVoxelCount(body), GetBodyMass(body)
				if m < v * 0.5 or v * 10 < m then
					m = m * 0.5
				end
				v = GetEntityChildren(body, "parent_shape", true, "shape")
				for n = #v, 1, -1 do
					n = v[n]
					local a = shp[n]
					if GetShapeBody(a) == shp[a] then
						 _, c, n = GetShapeClosestPoint(a, shp[body])
						local x = VecDot(d, n)
						if x > angle then
							x = x * m
							if x > threshold then
								val = co_create(breaks)
								_, x = co_resume(val, a, x, n, c)
								if x == true then
									breaklist[#breaklist + 1] = val
								end
								--[[local sr, sg, sb, sa, e, tc
								for i = sqrt(x * rthreshold), 0, -5 do
									if tc then
										_, tc, n = GetShapeClosestPoint(a, VecAdd(tc, rangedVec(5)))
									else
										tc = c
									end
									_, sr, sg, sb, sa, e = GetShapeMaterialAtPosition(a, tc)
									x = MakeHole(tc, wb * i, mb * i, hb * i)
									if x > dust then
										if e ~= 0 then
											sr, sg, sb = sr * 0.5 + 0.3, sg * 0.5 + 0.275, sb * 0.5 + 0.25
										else
											sr, sg, sb, sa = 0.6, 0.55, 0.5, 1
										end
										if x < 4096 then
											x, e = x * rdust, x * sratio
										else
											x, e = fdust, 3
										end
										ParticleColor(sr, sg, sb)
										ParticleAlpha(sa, 0, "easein")
										ParticleRadius(0.1, e, "easeout")
										for _ = x, 1, -1 do
											SpawnParticle(VecAdd(tc, rndVec()), VecAdd(n, rndVec()), random() * 5)
										end
									end
								end]]
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