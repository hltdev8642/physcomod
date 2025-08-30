--[[
#include "slimerand.lua"
#include "slimegcfunc.lua"
--]]

--prelude(){
	local random, sqrt = math.random, math.sqrt
	--localize some math function
	math.randomseed(tonumber(tostring(newproxy(false)):sub(19, -2), 16))
	local rndVec, rangedVec = Fastrnd.Ball.UnitVec, Fastrnd.Ball.RangedVec
	local sratio = 3 / 4096
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
	local shp, gcl = {}, {}
	local ind = nil
	-- init values
--}

function upongc(t)
	for body = #gcl, 1, -1 do
		body = gcl[body]
		if not IsBodyActive(body) then
			t = GetBodyShapes(body)
			for shape = #t, 1, -1 do
				RemoveTag(t[shape], "parent_shape")
			end
			RemoveTag(body, "val")
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

--[[local function check(shape)
	local lcount = tonumber(GetTagValue(shape, "val"))
	if not lcount then return SetTag(shape, "val", GetShapeVoxelCount(shape)) end
	local count = GetShapeVoxelCount(shape)
	if lcount == count then return end
	SetTag(shape, "val", count)
	lcount = lcount - count
	if lcount < threshold then return end
	lcount = ln(lcount)
	_, count = GetShapeClosestPoint(shape, VecAdd(breakpoint, rangedVec(lcount)))
	local sr, sg, sb, sa
	for i = lcount * ratio - lnthreshold + 1, 1, -5 do
		DebugPrint(i)
		_, count, n = GetShapeClosestPoint(shape, VecAdd(breakpoint, rangedVec(i)))
		_, sr, sg, sb, sa, lcount = GetShapeMaterialAtPosition(shape, c)
		if lcount ~= 0 then
			ParticleColor((sr + 0.6) * 0.5, (sg + 0.55) * 0.5, (sb + 0.5) * 0.5)
			ParticleAlpha(sa, 0, "easein")
		else
			ParticleColor(0.6, 0.55, 0.5)
			ParticleAlpha(1, 0, "easein")
		end
		i = MakeHole(i, wb * lcount, mb * lcount, hb * lcount)
		-- only large breakage will spawn particles
		if i > dust then
			-- clamp multiplier
			if i > 4096 then i = 4096 end
			for _ = i * rdust, 1, -1 do
				SpawnParticle(VecAdd(c, rndVec()), s, random() * 5)
			end	
		end
	end
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
	if triggered or not HasKey("game.break") then return end
	local breaksize = GetFloat("game.break.size")
	local breakpoint, list, watch = {GetFloat("game.break.x"), GetFloat("game.break.y"), GetFloat("game.break.z")}, {breaksize, breaksize, breaksize}, {}
	local min, max = VecSub(breakpoint, list), VecAdd(breakpoint, list)
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
		if shp[body] == nil and IsBodyBroken(body) and IsBodyActive(body) then
			breaksize, breakpoint = false, GetEntityChildren(body, "parent_shape", true, "shape")
			for shape = #breakpoint, 1, -1 do
				shape = breakpoint[shape]
				local tgt = tonumber(GetTagValue(shape, "parent_shape"))
				if watch[tgt] then
					breaksize, shp[shape] = true, tgt
				end
			end
			if breaksize then
				shp[body], ind = TransformToParentPoint(GetBodyTransform(body), GetBodyCenterOfMass(body)), true
				SetTag(body, "val")
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
	ParticleType("smoke")
	ParticleDrag(0, 1, "easeout")
    ParticleStretch(1, 0, "easein")
    ParticleGravity(-0.1)
	ParticleColor(0.6, 0.55, 0.5)
	ParticleAlpha(1, 0, "easein")
	for body = #gcl, 1, -1 do
		body = gcl[body]
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
				RemoveTag(n, "parent_shape")
				local a = shp[n]
				if not IsBodyDynamic(GetShapeBody(a)) then
					TrimShape(a)
 					_, c, n = GetShapeClosestPoint(a, shp[body])
					local x = VecDot(d, n)
					if x > angle then
						x = x * m
						if x > threshold then
							x = sqrt(x * rthreshold)
							local sr, sg, sb, sa, e, tc
							for i = x, 0, -5 do
								if tc then
									_, tc, n = GetShapeClosestPoint(a, VecAdd(tc, rangedVec(5)))
								else
									tc = c
								end
								_, sr, sg, sb, sa, e = GetShapeMaterialAtPosition(a, tc)
								x = MakeHole(tc, wb * x, mb * x, hb * x)
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
							end
						end
					end
				end
			end
			shp[body] = RemoveTag(body, "val")
		end
	end
end