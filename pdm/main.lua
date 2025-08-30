#include "umf/umf_meta.lua"

-- Constants
--local debug = false
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

SetBool("savegame.mod.progdest.launch", true)

-- Load the main variables in which will control if subroutines trigger.
local PD_TOG_FPSC = GetBool("savegame.mod.progdest.Tog_FPSC")
local PD_TOG_Dust = GetBool("savegame.mod.progdest.Tog_DUST")
local PD_TOG_Crum = GetBool("savegame.mod.progdest.Tog_CRUMBLE")
local PD_TOG_Rum = GetBool("savegame.mod.progdest.Tog_RUMBLE")

local PD_TOG_SDF = GetBool("savegame.mod.progdest.Tog_SDF")
local PD_TOG_LFF = GetBool("savegame.mod.progdest.Tog_LFF")
local PD_TOG_DBF = GetBool("savegame.mod.progdest.Tog_DBF")

local PD_TOG_FPS = GetBool("savegame.mod.progdest.FPS_Counter")
local PD_light = GetBool("savegame.mod.progdest.FPS_DynLights")
local PD_SDF = GetInt("savegame.mod.progdest.FPS_SDF")
local PD_LFF = GetInt("savegame.mod.progdest.FPS_LFF")
local PD_DBF = GetInt("savegame.mod.progdest.FPS_DBF")
local PD_DBF_FPSB = GetBool("savegame.mod.progdest.FPS_DBF_FPSB")

local dust_amt = GetInt("savegame.mod.progdest.dust_amt") 
local dust_size = GetInt("savegame.mod.progdest.dust_size") 
local dust_szvar = GetInt("savegame.mod.progdest.dust_sizernd")
local dust_szMB = GetInt("savegame.mod.progdest.dust_MsBsSz")

local crum_dist = GetInt("savegame.mod.progdest.crum_dist")
local crum_speed = GetInt("savegame.mod.progdest.crum_spd")
local radegast_12 = 23-crum_speed -- i put this check so often made it its own variable.

local hole_control = GetInt("savegame.mod.progdest.crum_HoleControl")
local hole_breaktime = GetFloat("savegame.mod.progdest.crum_BreakTime")
local boom_control = GetInt("savegame.mod.progdest.xplo_HoleControl")
local boom_breaktime = GetFloat("savegame.mod.progdest.xplo_BreakTime")

-- Debris cleaner
local SDF_Size = GetInt("savegame.mod.progdest.FPS_SDF")
local LFF_Size = GetInt("savegame.mod.progdest.FPS_LFF")
local FPS_Targ = GetInt("savegame.mod.progdest.FPS_Targ")
local FPS_Agg = GetInt("savegame.mod.progdest.FPS_Agg")

local PD_Explode_Size = GetInt("savegame.mod.progdest.xplo_szBase")
local PD_Explode_Chance = GetInt("savegame.mod.progdest.xplo_chance")
local Dlights_have_been_disabled=0
local no_more_holes_until=0
local next_FPS_check =GetTime()
local automode=false

local windrotstop = false
local windrotoffset = 0
local windstoptime = 0
local CURR="AUD"
local Ratio=1  --Ratio currency scaler for damage stats.

-- Turn off all lights in the world to minimize light ray tracing.
local function disableLight(shape)
	local lights = GetShapeLights(shape)
	for j = 1, #lights do
		SetLightEnabled(lights[j], false)
	end
end

function destroyObjects(body)  -- THE SMALL DEBRIS FILTER
if framesPerSecond < ( FPS_Targ +1 ) and GetBool("savegame.mod.progdest.Tog_SDF") then
	if GetBodyMass(body) < SDF_Size and (math.random()*400) > ( 397 - GetInt("savegame.mod.progdest.FPS_SDF_agg") - GetInt("savegame.mod.progdest.FPS_Agg")) then
		--DebugPrint("Small Debris Filter - Stuff deleted.")
		Delete(body)
	end
	end
end

function dynamicObjects(body)
	--DebugPrint("Entered dyn obj routine")
	dysta = (VecLength(VecSub(GetBodyTransform(body).pos,GetPlayerTransform().pos)))*0.85
	--We're measuring FPS every 1/4 second
	--DebugPrint("FPS = " .. framesPerSecond .. " FPS target is " .. FPS_Targ)
	if (framesPerSecond < (FPS_Targ)) or (framesPerSecond<32 and math.random()<(0.3+((100-GetInt("savegame.mod.progdest.FPS_SDF_agg"))*0.01))) then			
		--DebugPrint("LOW FPS" .. (framesPerSecond) .. "and target is: " .. FPS_Targ )	
		if (math.random()*400) > ( 397 - ((GetInt("savegame.mod.progdest.FPS_LFF_agg") + GetInt("savegame.mod.progdest.FPS_Agg"))*0.5)) and GetBodyMass(body)<LFF_Size and GetBool("savegame.mod.progdest.Tog_LFF") then -- added extra math random as for some reason this one is quite sensitive.
			--DebugPrint("LFF: Deleted cuz FPS:" .. framesPerSecond .. "and target is: " .. FPS_Targ )
			Delete(body)
		end
		if PD_DBF_FPSB==true then -- Distance based filter - if is triggered by low FPS
			if (math.random()*400) > ( 397 - GetInt("savegame.mod.progdest.FPS_DBF_agg"))  and (dysta < PD_DBF) then
				--DebugPrint("DISTANCE FILTER, things deleted.")
				Delete(body)
			end
		end
	end
	
	if GetBool("savegame.mod.progdest.Tog_DBF") and not GetBool("savegame.mod.progdest.Tog_DBF_FPSB") then -- Distance based filter - When not FPS Controlled
		if (dysta > PD_DBF) and (math.random()*400) > ( 397 - GetInt("savegame.mod.progdest.FPS_DBF_agg")) and GetBodyMass(body) < LFF_Size then					
			--DebugPrint("Things deleted. Distance:" .. outputt)
			Delete(body)
		end

	end	
end

function igniteObjects(body)
	fire_loc = GetBodyTransform(body).pos
	local portliness = GetBodyMass(body)
	max_dist = 1
	dyst = (VecLength(VecSub(fire_loc,GetPlayerTransform().pos)))
	if (math.random()*100)<(GetInt("savegame.mod.progdest.fyr_chance")) and dyst>GetInt("savegame.mod.progdest.fyr_minrad")/2 and dyst<GetInt("savegame.mod.progdest.fyr_maxrad") and portliness > GetInt("savegame.mod.progdest.fyr_minmass") and portliness < GetInt("savegame.mod.progdest.fyr_maxmass") then
		offset = Vec((0.5 - math.random())*max_dist,(0.5 - math.random())*3,(0.5 - math.random())*max_dist)
		--DebugPrint("Pyro time!")
		loc = VecAdd(fire_loc , offset)		
		SpawnFire(fire_loc)
	end
end

function callFunctions()
	fps_waz_checked = 0
	if GetTime() < GetInt("savegame.mod.progdest.4ce_warmup") then
		a4ce_start = GetTime()/GetInt("savegame.mod.progdest.4ce_warmup")
		else
		a4ce_start = 1
	end
	if GetBool("savegame.mod.progdest.Tog_FORCE")==true or GetBool("savegame.mod.progdest.Tog_JOINTS")==true then		
		maxMass = GetInt("savegame.mod.progdest.4ce_maxmass")	--The maximum mass for a body to be affected
		minMass = GetInt("savegame.mod.progdest.4ce_minmass")	--The maximum mass for a body to be affected
		maxDist = GetInt("savegame.mod.progdest.4ce_radius")	--The maximum distance for bodies to be affected
		if GetInt("savegame.mod.progdest.4ce_method")~=6 and GetInt("savegame.mod.progdest.4ce_method")~=5 and GetInt("savegame.mod.progdest.4ce_method")~=1 then
			strength = GetInt("savegame.mod.progdest.4ce_strength")/75
			else
			strength = ((120+GetInt("savegame.mod.progdest.4ce_strength"))/200)
		end
		if GetInt("savegame.mod.progdest.4ce_method")==3 and GetBool("savegame.mod.progdest.Tog_FORCE") then
			local pos = GetPlayerTransform().pos
			PlayLoop(WindSound, pos, (15)*a4ce_start)				
		end
		strength = GetInt("savegame.mod.progdest.4ce_strength")/75
		local PLAYER_AFFECTED_BY_WIND = 0
		local t = GetPlayerCameraTransform()
		local c = TransformToParentPoint(t, Vec(0, 0, 0) )--maxDist/2))
		local mi = VecAdd(c, Vec(-maxDist*2, -maxDist*2, -maxDist*2))
		local ma = VecAdd(c, Vec(maxDist*2, maxDist*2, maxDist*2))	
		local angle1 = math.sin(GetTime()/(GetInt("savegame.mod.progdest.4ce_cycle")))
		local angle2 = math.cos(GetTime()/(GetInt("savegame.mod.progdest.4ce_cycle")))
		local super_dooper_debris_booster = GetInt("savegame.mod.progdest.4ce_boost") / 10
		if windstoptime>0 then
			angle1 = math.sin(windstoptime*0.08)
			angle2 = math.cos(windstoptime*0.08)		
		end
		QueryRequire("physical dynamic")
		local bodies = QueryAabbBodies(mi, ma)
		for i=1,#bodies do
			local b = bodies[i]
			body = GetShapeBody(b)
			
			local broken = IsBodyBroken(b)
			local mass = GetBodyMass(b)	
			local vector_vel = GetBodyVelocity(b)
			local vector_len = VecLength(vector_vel)
			
			if GetBool("savegame.mod.progdest.Tog_XPLO_outline") and GetBool("savegame.mod.progdest.Tog_RUMBLE") then
				--DebugPrint("MODES CORRECT!")
				diist = VecLength(VecSub(GetBodyTransform(b).pos,GetPlayerTransform().pos))
				if mass>GetInt("savegame.mod.progdest.xplo_MinMass")*2 and mass<GetInt("savegame.mod.progdest.xplo_MaxMass") and vector_len>0.01 and diist<(GetInt("savegame.mod.progdest.xplo_distFromPlyr")*4) then
					DrawBodyOutline(b,1)
					--DebugPrint("SHHOULD DRAW!")
				end
			end
			if broken==true then
				chance = GetInt("savegame.mod.progdest.JOINT_Chance")/100
				if last_broken_time < GetTime() and math.random() < chance and GetBool("savegame.mod.progdest.Tog_JOINTS") then
					dyst = GetInt("savegame.mod.progdest.JOINT_Range")
					dyst = dyst/2
					QueryRequire("physical")
					if GetInt("savegame.mod.progdest.JOINT_Source")==1 then
						camloc = GetBodyTransform(b)
						else
						camloc = GetPlayerTransform()
					end
					local jist = QueryAabbShapes( Vec(camloc.pos[1] - dyst, camloc.pos[2] - dyst, camloc.pos[3] - dyst) , Vec(camloc.pos[1] + dyst, camloc.pos[2] + dyst, camloc.pos[3] + dyst) )
					for ez=1, #jist do
				--		DebugPrint("got in the loop")
						local shaype = jist[ez]                                        
						local hinges = GetShapeJoints(shaype)    
				--		DebugPrint(VecStr(max_up) .. " to " .. VecStr(max_dn))		
						--DebugPrint("hinges" .. hinges)
						for ii=1, #hinges do
							local joint = hinges[ii]
							Delete(joint)
							--DebugPrint("JOINTS BROKE!")
						end    
					end	
					last_broken_time = GetTime() + 0.25
				end						
			end					
				
				-- if either of the above are not correct (e.g the physical object isnt a vehicle, or doesnt have a body)
				-- the variables will return 0
			if automode==true and GetBool("savegame.mod.progdest.Tog_FORCE") then
				--Compute body center point and distance
				local bmi, bma = GetBodyBounds(b)
				local bc = VecLerp(bmi, bma, 0.5)
				local dir = VecSub(bc, t.pos)
				local dist = VecLength(dir)
				dir = VecScale(dir, 1.0/dist)
				--Get body mass
				local mass = GetBodyMass(b)					
				-- INJECTED CODE:
				--DebugPrint(math.random())				
				local scaler = 1 + (mass*0.00025) --+(math.sin(GetTime()*0.05)*(maas*0.35))
				-- below: a really crappy way to do falloff, but im tired and dont know how to do it
				if mass > (maxMass * 0.50 )then
					scaler = scaler * GetInt("savegame.mod.progdest.4ce_largemass_accellerator")
				end
				-- END OF INJECTED CODE
				--Check if body is should be affected
				if dist < maxDist and mass>minMass and mass<maxMass then					
					--Make sure direction is always pointing slightly upwards					
					--DebugPrint(GetInt("savegame.mod.progdest.4ce_method"));
					if GetInt("savegame.mod.progdest.4ce_method")==1 then
						scaler = strength * 10
						dir = Vec((-.5+math.random())*scaler,(-.5+math.random())*scaler,(-.5+math.random())*scaler)
					end
					if GetInt("savegame.mod.progdest.4ce_method")==2 then
						dir = VecNormalize(dir) 
						dir[2] = GetInt("savegame.mod.progdest.4ce_upforce")
					end
					langle1 = (angle1 * scaler * (GetInt("savegame.mod.progdest.4ce_strength")/100)) 
					langle2 = (angle2 * scaler * (GetInt("savegame.mod.progdest.4ce_strength")/100))
					if GetInt("savegame.mod.progdest.4ce_method")==3 then								
						dir = Vec(langle1 , GetInt("savegame.mod.progdest.4ce_upforce")/20 , langle2 )
					end
					if GetInt("savegame.mod.progdest.4ce_method")==4 then	
						dir = Vec( 0 , langle1  , langle2 )
					end			
					if GetInt("savegame.mod.progdest.4ce_method")==5 then	
						dir = Vec(langle1 , GetInt("savegame.mod.progdest.4ce_upforce")/20 , 0 )
					end		
					if GetInt("savegame.mod.progdest.4ce_method")==6 then	
						dir = Vec(0 , GetInt("savegame.mod.progdest.4ce_upforce")/20 , langle1 )
					end	
					if GetInt("savegame.mod.progdest.4ce_method")==7 then	
						dir = Vec(0 , 1 , 0 )
					end								
					if GetInt("savegame.mod.progdest.4ce_method")==8 then	
						dir = Vec(GetInt("savegame.mod.progdest.4ce_strength")/100 , GetInt("savegame.mod.progdest.4ce_upforce")/10 , 0 )
					end								
					if GetInt("savegame.mod.progdest.4ce_method")==9 then	
						dir = Vec( 0 , GetInt("savegame.mod.progdest.4ce_upforce")/20 , GetInt("savegame.mod.progdest.4ce_strength")/100  )
					end	
					--DebugPrint("Applying sauce!")
					massScale = 1
					distScale = 1
					local add = VecScale(dir, (((strength * massScale * distScale) * (1+super_dooper_debris_booster))*a4ce_start))
					--local add = VecScale(dir, (((strength * massScale * distScale) * (1+super_dooper_debris_booster))*a4ce_start) )
					--DebugPrint("Applying force!")
					

					--Add velocity to body
					local vel = GetBodyVelocity(b)
					local screw_quaternions = GetBodyAngularVelocity(b)	
					local angle_force = GetInt("savegame.mod.progdest.4ce_rotational")
					they_are_evil = Vec(((0.5-math.random())*angle_force)*a4ce_start,((0.5-math.random())*angle_force)*a4ce_start,((0.5-math.random())*angle_force)*a4ce_start)
					AnglesForever = VecAdd(screw_quaternions , they_are_evil)
					SetBodyAngularVelocity(b, AnglesForever)
					vel = VecAdd(vel, add)
					SetBodyVelocity(b, vel)						
				end									
			end					
		end
		
		if PLAYER_AFFECTED_BY_WIND == 0 and automode==true then
			scaler = strength * (GetInt("savegame.mod.progdest.4ce_effect_on_player")/50)			
			if GetInt("savegame.mod.progdest.4ce_method")==1 then
				dir = Vec((-.5+math.random())*scaler,(-.5+math.random())*scaler,(-.5+math.random())*scaler)
			end
			if GetInt("savegame.mod.progdest.4ce_method")==2 then
				dir = VecNormalize(dir) 
			end
			langle1 = (angle1 * scaler * (GetInt("savegame.mod.progdest.4ce_strength")/100)) 
			langle2 = (angle2 * scaler * (GetInt("savegame.mod.progdest.4ce_strength")/100))
			if GetInt("savegame.mod.progdest.4ce_method")==3 then								
				dir = Vec(langle1 , GetInt("savegame.mod.progdest.4ce_upforce") , langle2 )
			end
			if GetInt("savegame.mod.progdest.4ce_method")==4 then	
				dir = Vec( 0 , langle1  , langle2 )
			end			
			if GetInt("savegame.mod.progdest.4ce_method")==5 then	
				dir = Vec(langle1 , GetInt("savegame.mod.progdest.4ce_upforce") , 0 )
			end		
			if GetInt("savegame.mod.progdest.4ce_method")==6 then	
				dir = Vec(0 , GetInt("savegame.mod.progdest.4ce_upforce") , langle1 )			
			end	
			if GetInt("savegame.mod.progdest.4ce_method")==7 then	
				dir = Vec(0 , 1 , 0 )
			end								
			if GetInt("savegame.mod.progdest.4ce_method")==8 then	
				dir = Vec(GetInt("savegame.mod.progdest.4ce_strength")/100 , GetInt("savegame.mod.progdest.4ce_upforce") , 0 )
			end								
			if GetInt("savegame.mod.progdest.4ce_method")==9 then	
				dir = Vec( 0 , GetInt("savegame.mod.progdest.4ce_upforce") , GetInt("savegame.mod.progdest.4ce_strength")/100  )
			end	
			--DebugPrint("Force ramp:" .. a4ce_start)		
			local add = VecScale(dir, scaler * a4ce_start)
			max_speed = 0.62
			leen= VecLength(add)
			if leen>max_speed then
				add = VecScale(add,  max_speed / leen)
			end
			local vel_player = GetPlayerVelocity()
			vel = VecAdd(vel_player, add)
			SetPlayerVelocity(vel)
		end			
		if GetBool("savegame.mod.progdest.4ce_Showcross")==true then
			if GetInt("savegame.mod.progdest.4ce_method")==3 then												
				CrossPoint = Vec(angle1 , 0 , angle2 )				
			end
			if GetInt("savegame.mod.progdest.4ce_method")==4 then	
				CrossPoint = Vec(0 , angle1 , angle2 )
			end			
			if GetInt("savegame.mod.progdest.4ce_method")==5 then
				CrossPoint = Vec(angle1*2 , 0 , 0 )
			end		
			if GetInt("savegame.mod.progdest.4ce_method")==6 then
				CrossPoint = Vec(0 , 0 , angle1*2 )
				
			end	
			if GetInt("savegame.mod.progdest.4ce_method")==7 then	
				CrossPoint = Vec(0 , 1 * scaler , 0)
			end								
			if GetInt("savegame.mod.progdest.4ce_method")==8 then	
				CrossPoint = Vec( (GetInt("savegame.mod.progdest.4ce_strength")/100 * scaler) , 0 , 0)
			end								
			if GetInt("savegame.mod.progdest.4ce_method")==9 then	
				CrossPoint = Vec( 0 , 0 , (GetInt("savegame.mod.progdest.4ce_strength")/100 * scaler))
			end				
			windmarker_position = VecAdd(GetCameraTransform().pos, CrossPoint)
			DebugCross(windmarker_position, 5)
			
		end
	end -- end of the Joints + Force tog check.
	maxDist=100
	local mi = VecAdd(c, Vec(-maxDist*2, -maxDist*2, -maxDist*2))
	local ma = VecAdd(c, Vec(maxDist*2, maxDist*2, maxDist*2))	
	QueryRequire("physical dynamic")
	local bodies = QueryAabbBodies(mi, ma)
	for i=1,#bodies do
		local b = bodies[i]
		if IsBodyBroken(b) and GetBool("savegame.mod.progdest.Tog_FPSC") and GetTime()>next_FPS_check then
			destroyObjects(b)
			dynamicObjects(b)		
			if GetBool("savegame.mod.progdest.Tog_FIRE") then
				--DebugPrint("Pyro time!")
				igniteObjects(b)
			end		
			fps_waz_checked = 1
		end	
	end
				
	if Dlights_have_been_disabled == 0 then
		local shapes = QueryAabbShapes(min, max)
		for j = 1, #shapes do			
			local shape = shapes[j]							
			if GetBool("savegame.mod.progdest.FPS_DynLights") then
				disableLight(shape)
			end
		end
		Dlights_have_been_disabled=1
	end
	if fps_waz_checked == 1 then
		new_delay = 0.6-(GetInt("savegame.mod.progdest.FPS_SDF_agg")*0.0015)-(GetInt("savegame.mod.progdest.FPS_DBF_agg")*0.0015)-(GetInt("savegame.mod.progdest.FPS_DBF_agg")*0.0015)
		if crum_speed> 17 then
			-- if high crumble speed, make filter agg twice as effective.
			new_delay = new_delay *0.5
		end
		next_FPS_check = GetTime()+new_delay -- Dont run these functions again for 0.5s
		-- As actual FPS updates only once a second, and 60 frames (no matter how long it takes to render them)
		-- is in a second, gotta limit the checks to prevent the LFF kicking in and destroying all the
		-- Debris in a single moment
	end
end

local maxDist = 500

local hole_count = 0
local historical_hole_count = 0
local historical_boom_count = 0
local reee_counter = 0
local xcount = 0
local frames = 0
local FPS_marker=0
local debug_clearance = GetTime()
local no_more_boom_until=GetTime()
-- THIS_TICK vars for if non-crumble_locked explosions, smoke and crums
local crumbled_this_tick = 0
local exploded_this_tick = 0
local smoked_this_tick = 0

-- limits, to stop armageddon.
local max_smokes_per_tick = GetInt("savegame.mod.progdest.dust_amt")
local max_explodes_per_tick = 1
local max_crumble_per_tick = (14 - hole_control) * 1
local max_dyst_vio = GetInt("savegame.mod.progdest.VIOL_maxdist")
local alternate_crumble_min_frequency = GetTime()+0.05
local collapse_timer = 0.0

crum_moed = GetInt("savegame.mod.progdest.tog_crum_MODE") -- Mode - interval (0) or randomized (1).	


function init()
	-- runs code every second
	if GetInt("savegame.mod.progdest.4ce_method")==3 and GetBool("savegame.mod.progdest.Tog_FORCE") then
		WindSound = LoadLoop("MOD/data/WindNoise/WindOgg.ogg")
	end
	
	collapse_timer = 0.0
	
	-- checks if it should run right now
	local count = 0
	local lastcount =count
	
	tot_voxels = 0
	local shapes = FindShapes(nil,true)
	for i=1, #shapes do
		tot_voxels = tot_voxels + GetShapeVoxelCount(shapes[i])
	end
	SetFloat("savegame.mod.progdest.RB_RED",1)
	SetFloat("savegame.mod.progdest.RB_GRN",0)
	SetFloat("savegame.mod.progdest.RB_BLU",0)
	health = 1
	
	if GetBool("savegame.mod.progdest.Tog_FORCE") then
		if GetBool("savegame.mod.progdest.4ce_START_ON") then
			
			automode = true
		else
			automode = false
		end
	end	
	CurrencyPick()

end

local old_dam = 0

--RNG stuff
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

function draw(dt)
	UiFont("bold.ttf", 20);
	UiAlign("right middle");
	UiColor(1,1,1)
	if GetBool("savegame.mod.progdest.4ce_CONTROL_TIPS")== true then
		UiPush();	SetPos(0.98,0.94);	UiText("Force: use . to turn off/on and M to freeze position");
		UiPop();
		UiPush();	SetPos(0.98,0.97);	UiText("(also use , to show/hide the direction marker)");
		UiPop();
	end 
end	

function tick(dt)
	-- PANIC BUTTON
	if InputDown("-") then	
		-- If the key is pressed. delete EVERY piece of debris.
		maxDist=100
		local mi = VecAdd(c, Vec(-maxDist*2, -maxDist*2, -maxDist*2))
		local ma = VecAdd(c, Vec(maxDist*2, maxDist*2, maxDist*2))	
		QueryRequire("physical dynamic")
		local bodies = QueryAabbBodies(mi, ma)
		for i=1,#bodies do
			local b = bodies[i]
			if IsBodyBroken(b) then
				Delete(b)
			end	
		end
	end	


	-- these are set to cap the respective effect at no more than the limits
	crumbled_this_tick = 0
	smoked_this_tick = 0
	exploded_this_tick = 0
	SweetAssRainbowColors(dt)
	-- redundant?
	--if debug_clearance < GetTime() then
	--	debug_clearance = GetTime() + 2.5
	--	DebugPrint(" ")
	--end
	frames = frames + 1
	seconds_now = GetTime()
	if seconds_now - FPS_marker > 1 then
		--DebugPrint( math.floor(GetTime()))
		FPS_marker = seconds_now
		framesPerSecond = frames
		frames = 1	-- has to be set to 1 because the current frame is not a joke to us.
	end
	
	if InputPressed(".") and GetBool("savegame.mod.progdest.4ce_ENABLE_CONTROLS")==true then
		automode = not automode
		DebugPrint("Wind/Force" .. automode)
	end
	if InputPressed(",") and GetBool("savegame.mod.progdest.4ce_ENABLE_CONTROLS")==true then
		crossoff = not GetBool("savegame.mod.progdest.4ce_Showcross")
		SetBool("savegame.mod.progdest.4ce_Showcross", crossoff)
	end
	if InputPressed("m") and GetBool("savegame.mod.progdest.4ce_ENABLE_CONTROLS")==true then
		windrotstop = not windrotstop
		if windstoptime==0 then 
			windstoptime = GetTime()
			windrotoffset = windrotoffset + GetTime()
		end
	end		
	
	if windrotstop == false then
		windstoptime = 0
	end
	--DebugPrint(" Cross:" .. GetBool("savegame.mod.progdest.4ce_Showcross"))
	--DebugPrint("Windstoptime:" .. windstoptime )
	--if frames == 0 then
		callFunctions()			
	--end
	xcount = xcount + 1
	exploded = 0
	hole_max=(((12-hole_control)*4)*6.7)
	if historical_hole_count > hole_max then -- performance halter. If holes have been made full speed (for last 9 ticks)
		--DebugPrint("TOO MANY HOLES - CALM DOWN!")	
		historical_hole_count = 0 -- also reset counter	
		if crum_moed==0 then
			collapse_timer = collapse_timer + hole_breaktime -- 1.5s break to calm things down.	
		else
			no_more_holes_until=GetTime()+hole_breaktime
		end
		
		hole_count = 0		
	end

	if historical_boom_count > ((11-boom_control)*(0.8+(math.random()*0.2))) then -- as there can only be one explosion per tick, no fancy formula needed.
		no_more_boom_until=GetTime()+boom_breaktime	
		collapse_timer = collapse_timer +boom_breaktime	
		--DebugPrint("BOOMERS ARE BREAKING!")	
		historical_boom_count = 0
	end
	if xcount > 10 then		
		--DebugPrint("Time now:" .. math.floor(GetTime()) .. " Next deb check at " .. next_FPS_check)
		--DebugPrint("Countdown" .. collapse_timer )	
		historical_hole_count = 0	
		historical_boom_count = 0
		xcount = 0
		reee_counter = reee_counter + 1
		--DebugPrint(" ")
	end
	if reee_counter > 2 and GetBool("savegame.mod.progdest.Tog_DAMSTAT") then
		for a=1, 25 do
			DebugPrint(" ")
		end
		d = GetInt("game.brokenvoxels") 
		d = d * 20
		destroyed_level_percentage = financial_roundup(d)
		act_DMG = destroyed_level_percentage
				
		dmg_this_update = destroyed_level_percentage - old_dam
		old_dam = destroyed_level_percentage
		if (destroyed_level_percentage*Ratio) < 1000000 then
			if GetInt("savegame.mod.progdest.DAMSTAT_Currency")==1 then
				DebugPrint("Cost of all damage: £ " .. destroyed_level_percentage)
			else
				DebugPrint("Cost of all damage: " .. (destroyed_level_percentage*Ratio) .. " " .. CURR)
			end
		end		
		if (destroyed_level_percentage*Ratio) > 1000000 then
			destroyed_level_percentage = destroyed_level_percentage / 10000
			destroyed_level_percentage = financial_roundup(destroyed_level_percentage)
			if GetInt("savegame.mod.progdest.DAMSTAT_Currency")==1 then
				DebugPrint("Cost of all damage: £" .. destroyed_level_percentage .. " MILLION")
			else
				DebugPrint("Cost of all damage: " .. (destroyed_level_percentage*Ratio) .. " MILLION " .. CURR)
			end
			
		end
		if GetInt("savegame.mod.progdest.DAMSTAT_Currency")==1 then
			DebugPrint("DMG since last update: + £" .. dmg_this_update)
		else
			DebugPrint("DMG since last update: +" .. (dmg_this_update*Ratio) .. " " .. CURR)
		end		
		average = financial_roundup((act_DMG / GetTime()))
		average = average * 100
		if GetInt("savegame.mod.progdest.DAMSTAT_Currency")==1 then
			DebugPrint("Average DMG per second: £" .. average .. "/sec")
		else
			DebugPrint("Average DMG per second: " .. (average*Ratio) .. CURR .. "/sec")
		end
		reee_counter = 0
	end
	hole_count = 0
	--in "grouped" crumble mode, the following counts down the time until the next drumble check.
	collapse_timer = collapse_timer - (((0.4-((radegast_12)*0.006)))*(dt))

	-- if timer hit 0 and voxels destroyed
	--DebugPrint("We made it to this point " .. crum_moed)
	if GetTime()>2 and (GetBool("savegame.mod.progdest.Tog_CRUMBLE") or GetBool("savegame.mod.progdest.Tog_RUMBLE") or GetBool("savegame.mod.progdest.Tog_DUST")) or GetBool("savegame.mod.progdest.Tog_VIOL") then  -- GETTIME introduced to stop crumbles on rapid settings when objects are settling down, at level start.
	if ((collapse_timer <= 0.0) and (crum_moed==0)) or ((crum_moed==1) and (alternate_crumble_min_frequency<GetTime())) then 		
	 --	DebugPrint("We broke In")
		re_check_multi = 5
		if GetBool("savegame.mod.progdest.Tog_CRUMBLE") then
			re_check_multi = re_check_multi - 1
		end
		if GetBool("savegame.mod.progdest.Tog_RUMBLE") then
			re_check_multi = re_check_multi - 1
		end
		if GetBool("savegame.mod.progdest.Tog_DUST") then
			re_check_multi = re_check_multi - 1
		end
		if GetBool("savegame.mod.progdest.Tog_Viol") then
			re_check_multi = re_check_multi - 1
		end			
		if crum_speed > 15 then
			alternate_crumble_min_frequency = GetTime()+(0.02*((23-crum_speed)))
		end
		if crum_speed <16 then
			alternate_crumble_min_frequency = GetTime()+(0.03*((23-crum_speed)))
		end
 		if crum_speed < 8 then
			alternate_crumble_min_frequency = GetTime()+(0.04*((23-crum_speed)))
		end
 		if crum_speed < -2 then
			alternate_crumble_min_frequency = GetTime()+(0.5*((23-crum_speed)))
		end
		-- reset timer once something broke if enabled. Also take randomized crumble into account for up to 30% difference in crumble time
		collapse_timer = ((radegast_12)*0.013)*(1+(0.5-math.random())*(GetInt("savegame.mod.progdest.crum_spdRND")*0.015))
		vec_add = 0
		vec_add2 = 0
		QueryRequire("physical dynamic")
		local list = QueryAabbShapes(Vec(-maxDist, -maxDist, -maxDist), Vec(maxDist, maxDist, maxDist))
		local count = 0
		
		for i=1, #list do			
			if InputDown("-") and broken==true and math.random()<0.6 then
				Delete(b)
			end	

			-- the following code will abandon this cumbersome loop if any of the max values are reached, prevents FPS drop and also too much CPU waste,
			local shape = list[i]
			
			local body = GetShapeBody(shape)
			local is_vehicle = GetBodyVehicle(body)		

					-- local dir = VecSub(bc, t.pos)
					-- local dist = VecLength(dir)
			local dir = VecLength(VecSub(GetBodyTransform(body).pos,GetPlayerTransform().pos))
			local body_dyst_from_plyr = dir
			local mode = GetInt("savegame.mod.progdest.VIOL_mode")
			--DebugPrint("VMODE" .. mode)
			-- violence checks
			if GetBool("savegame.mod.progdest.Tog_VIOL") and body_dyst_from_plyr < max_dyst_vio then
				if is_vehicle==0 then
					if body and IsBodyBroken(body) and mode==1 then
						Violence(body)
					end					
					if body and mode==2 then
						Violence(body)
					end
				end
				if body and is_vehicle>0 and mode==3 then
					Violence(body)			
				end
				if body and mode==4 then
					Violence(body)			
				end				
			end
			
			if body then 			
				
				local mass = GetBodyMass(body)
				local broken = IsBodyBroken(body)
				local vector_vel = GetBodyVelocity(body)
				local vector_len = VecLength(vector_vel)
				-- exclude vehicles
				
				--if is_vehicle == 0 then									-- (mass < GetInt("savegame.mod.progdest.crum_MaxMass")*100000) and
					if mass > 0.01 then
							local bodyTransform = GetBodyTransform(body)
							if broken==true then
								count = count + 1 -- ABSOLUTELY IMPORTANT LIMITER! <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<																	
							end	
							how_big_is_the_chungus = 1+math.floor((mass/50000)) -- For every 50000 mass, an extra chungus/crumble will be made, because we generous.
							if how_big_is_the_chungus >2 then 
								--DebugPrint("BIG BIG CHUNGUS, BIG CHUNGUS" .. how_big_is_the_chungus)
							end
							for big_chungus=1, how_big_is_the_chungus do
								
								local mi,ma = GetShapeBounds(shape)
								--local c = VecLerp(mi, ma, math.random() / 1) --old mode, just does a line.
								xpos = math.random(mi[1] , ma[1])
								zpos = math.random(mi[2] , ma[2])
								ypos = math.random(mi[3] , ma[3])
								local c = Vec(xpos , zpos, ypos)
								-- choosa completely random place between the top and bum corner.
								--local C = Vec((math.random() * width),(math.random() * breadth),(math.random() * height))
								
								
								-- hacky way to scale damage with mass
								local big_slicer = 0.2 + (math.random()*0.70)
								local size_multi = (crum_dist/500) * (0.8 + big_slicer)
								if big_slicer > 0.28 or hole_count > 30 then
									--collapse_timer = collapse_timer + (0.005*(hole_control*0.01))
									--DebugPrint("BUGCHECK: BIG TIMER SET!")
								end						
								-- prepare to crumble.
								if GetBool("savegame.mod.progdest.Tog_CRUMBLE") and no_more_holes_until<GetTime() then 					
									wood_breakage = (GetFloat("savegame.mod.progdest.crum_DMGLight") * (mass * 0.008 ))
									stone_breakage = (GetFloat("savegame.mod.progdest.crum_DMGMed") * (mass * 0.008))
									metal_breakage = (GetFloat("savegame.mod.progdest.crum_DMGHeavy") * (mass * 0.008))
									--DebugPrint("Entered crumble loop")
									
									-- no return value? dust may be emitted even if nothing broke. and hole_count < ((12-hole_control)*3)
									if (broken==true or GetInt("savegame.mod.progdest.tog_crum_Source")==1) then --and ((crumbled_this_tick < max_crumble_per_tick) or (crum_moed==0)) then
										if (mass > (GetInt("savegame.mod.progdest.crum_MinMass")/8)) and (vector_len > ((GetInt("savegame.mod.progdest.crum_MinSpd")/20))) and vector_len < ((GetInt("savegame.mod.progdest.crum_MaxSpd"))) then
											--DebugPrint("PASSED LAST IF STATEMENT")
											-- last check is to make sure game doesnt use up hole allocation with holes so tiny they can't be seen.
											if ((wood_breakage * size_multi)+(stone_breakage * size_multi)+(metal_breakage * size_multi))>(0.25*crum_dist) then
												crumbled_this_tick = crumbled_this_tick + 1
												MakeHole(c, wood_breakage * size_multi, stone_breakage * size_multi, metal_breakage * size_multi)
												hole_count = hole_count + 1
											end
										end	
									end
								end
								
								-- perform all the filter checks
								if GetBool("savegame.mod.progdest.Tog_RUMBLE") and (mass*1)>GetInt("savegame.mod.progdest.xplo_MinMass") and mass<GetInt("savegame.mod.progdest.xplo_MaxMass") and vector_len>GetInt("savegame.mod.progdest.xplo_MinSpd") and vector_len<GetInt("savegame.mod.progdest.xplo_MaxSpd") and no_more_boom_until<GetTime() and exploded_this_tick ==0 then
									-- check that the body kind is what we're looking for.
									--DebugPrint("Considering Exploding...")
									if (GetInt("savegame.mod.progdest.xplo_mode")==1 and broken==true) or GetInt("savegame.mod.progdest.xplo_mode")==2 or (GetInt("savegame.mod.progdest.xplo_mode")==3 and is_vehicle>0) then
										--DebugPrint("still thinkin about it...")
										--one last distance and randomizer check.
										if (math.random()<(PD_Explode_Chance/200)) then
											--DebugPrint("Exploded object " .. body_dyst_from_plyr .. " limit is " .. GetInt("savegame.mod.progdest.xplo_distFromPlyr"))
											
											if body_dyst_from_plyr < GetInt("savegame.mod.progdest.xplo_distFromPlyr") then												
												exploded_this_tick = exploded_this_tick + 1
												BOOM_SIZE=(GetInt("savegame.mod.progdest.xplo_szBase")/5) + (math.random()*(GetInt("savegame.mod.progdest.xplo_szRND")/5))
												Explosion(c,(BOOM_SIZE))
												--DebugPrint("Exploded")
												
											end
										end
									end
								end
			
							end -- end of the big chungus
							--DebugPrint("Reached smoke bit")
							if GetInt("savegame.mod.progdest.dust_amt") > 0 and GetBool("savegame.mod.progdest.Tog_DUST") and mass > (GetInt("savegame.mod.progdest.dust_minMass")) and (vector_len > GetInt("savegame.mod.progdest.dust_minSpeed")/2) then -- or ((smoked_this_tick >= max_smokes_per_tick) and crum_moed )then
								if crum_speed<17 or (crum_speed > 16 and (math.random()<(0.5-((crum_speed-16)*0.02)))) then
									if (crum_moed==1 and smoked_this_tick < max_smokes_per_tick) or crum_moed==0 then
										--DebugPrint("Mass:" .. mass .. "  threshold:" .. GetInt("savegame.mod.progdest.dust_minMass"))							
										--DebugPrint("Smoke Spawned!")
										local mi,ma = GetShapeBounds(shape)
										local c = VecLerp(mi, ma, math.random() / 1) --old mode, just does a line.									
										ParticleReset()
										ParticleType("smoke")
										ParticleColor(.5,.5,.5)
										ParticleDrag(GetInt("savegame.mod.progdest.dust_drag")*0.01)
										ParticleGravity(GetInt("savegame.mod.progdest.dust_grav")*0.01)
										for i = GetInt("savegame.mod.progdest.dust_amt"),1,-1
										do									

											if (math.random()*100) < (25+(radegast_12)) then	
											
												random_shade=(1-(math.random()/5))
												-- SMOKE: NOW WITH SICK COLOURS, BLOOD!
												--DebugPrint("ColourMode:" .. GetInt("savegame.mod.progdest.dust_ColMode"))
												if GetInt("savegame.mod.progdest.dust_ColMode")==1 then
													ParticleColor(GetInt("savegame.mod.progdest.dust_Col1_R")/100*random_shade,GetInt("savegame.mod.progdest.dust_Col1_G")/100*random_shade,GetInt("savegame.mod.progdest.dust_Col1_B")/100*random_shade)
												end
												if GetInt("savegame.mod.progdest.dust_ColMode")==2 then
													ParticleColor(GetInt("savegame.mod.progdest.dust_Col1_R")/100*random_shade,GetInt("savegame.mod.progdest.dust_Col1_G")/100*random_shade,GetInt("savegame.mod.progdest.dust_Col1_B")/100*random_shade)
													if math.random() > 0.5 then
														ParticleColor(GetInt("savegame.mod.progdest.dust_Col2_R")/100*random_shade,GetInt("savegame.mod.progdest.dust_Col2_G")/100*random_shade,GetInt("savegame.mod.progdest.dust_Col2_B")/100*random_shade)
													end
												end
												if GetInt("savegame.mod.progdest.dust_ColMode")==3 then
													ParticleColor(GetInt("savegame.mod.progdest.dust_Col1_R")/100*random_shade,GetInt("savegame.mod.progdest.dust_Col1_G")/100*random_shade,GetInt("savegame.mod.progdest.dust_Col1_B")/100*random_shade)
													if math.random() > 0.333 then
														ParticleColor(GetInt("savegame.mod.progdest.dust_Col2_R")/100*random_shade,GetInt("savegame.mod.progdest.dust_Col2_G")/100*random_shade,GetInt("savegame.mod.progdest.dust_Col2_B")/100*random_shade)
													end
													if math.random() > 0.666 then
														ParticleColor(GetInt("savegame.mod.progdest.dust_Col3_R")/100,GetInt("savegame.mod.progdest.dust_Col3_G")/100,GetInt("savegame.mod.progdest.dust_Col3_B")/100)
													end									
												end	
												if GetInt("savegame.mod.progdest.dust_ColMode")==4 then
													ParticleColor(math.random(),math.random(),math.random())
												end	
												if GetInt("savegame.mod.progdest.dust_ColMode")==5 then
													rid = GetFloat("savegame.mod.progdest.RB_RED")
													gran = GetFloat("savegame.mod.progdest.RB_GRN")
													bliw = GetFloat("savegame.mod.progdest.RB_BLU")
													ParticleColor(rid,gran,bliw,rid/2,gran/2,bliw/2)
												end	
												if GetInt("savegame.mod.progdest.dust_ColMode")==6 then
													theGreyscaleColour = 0.25+(math.random()*.65)
													ParticleColor(theGreyscaleColour,theGreyscaleColour,theGreyscaleColour)
												end									
											
												val=dust_size * 0.25 -- Base Dust Size
												if dust_szvar > 0 then
													val = val * (1+(math.random()*(dust_szvar*0.01))) -- Randomized amount
												end
												if dust_szMB > 0 then
													-- Weight would have to be over 12000 for it to add more than 200%
													val=val * (1+((mass / 12000) * (1+(dust_szMB*0.01)))) --mass based amount
												end									
												local spread = math.floor(math.random() * (1000 - 1) + 1000) / 10000
												local v = VecScale(VecAdd(spread, rndVec(0.2)), 2)
												v = VecAdd(v, VecScale(GetBodyVelocityAtPos(body, c)))
												val2=GetInt("savegame.mod.progdest.dust_life")*0.5 -- Base Dust Life
												if GetInt("savegame.mod.progdest.dust_lifernd") > 0 then
													val2 = val2 + ((GetInt("savegame.mod.progdest.dust_life")*0.5) * (math.random()*(GetInt("savegame.mod.progdest.dust_lifernd")/100))) -- Randomized amount
												end
												if GetInt("savegame.mod.progdest.dust_lifernd") > 0 then
													val2 = val2 + ((GetInt("savegame.mod.progdest.dust_life")*0.5) * (math.random()*(GetInt("savegame.mod.progdest.dust_lifernd")/100))) -- Randomized amount
												end
												
												if GetInt("savegame.mod.progdest.dust_MsBsLf") >= 1 then
													MassBased = (GetInt("savegame.mod.progdest.dust_MsBsLf")*0.01)
													if MassBased > 1 then
														MassBased=1
													end
													val2=val2 + MassBased --mass based amount
												end
												ParticleRadius( (val/2)*(GetInt("savegame.mod.progdest.dust_startsize")/10) , (val/2) ) --(val*100))
												ParticleAlpha(1, 0, "linear", (GetInt("savegame.mod.progdest.dust_fader")/1000) , 0.05)
												SpawnParticle(c, v, val2)	
												if crum_moed==1 then -- Smoked var only increase in correct mode (lazy coding btw)
													smoked_this_tick = smoked_this_tick +1										
												end
											end
										end
									end
								end

							end					

				end			
			end
			--DebugPrint("Parts:" .. count)
			lastCount = count
			
		end
		-- disable algo when finished
		--broken_lasttick = false
	end	
	end -- GetTime()>2 end
	
	if collapse_timer <= 0.0 and not GetBool("savegame.mod.instant") then
		collapse_timer = 0
	end
	historical_hole_count = historical_hole_count + hole_count
	historical_boom_count = historical_boom_count + exploded_this_tick
	hole_count = 0

end

function Violence(body)
	local vector_vel = GetBodyVelocity(body)
	local vector_len = VecLength(vector_vel)
	if vector_len > -1 and vector_len < 100 then
		-- debris violence
		-- Check the main togggle but also add up the turnr and mover values, because if both add up to 0, no point running the code.	
		mass = GetBodyMass(body)
		if mass > (GetInt("savegame.mod.progdest.VIOL_minmass")/8) and mass < (GetInt("savegame.mod.progdest.VIOL_maxmass")*10) then		
			if math.random()<(GetInt("savegame.mod.progdest.VIOL_Chance")/600) then
				--DebugPrint("Got in the fun zone")
				screw_quaternions=GetBodyVelocity(body)
				angle_force = GetInt("savegame.mod.progdest.VIOL_mover")
				--square number, for more power
				angle_force	= angle_force * angle_force
				--scale down to 1/50th in case user wanted low number.
				angle_force	= angle_force *0.02			
				they_are_evil = Vec((0.5-math.random())*angle_force, (0.5-math.random())*angle_force,(0.5-math.random())*angle_force)
				AnglesForever = VecAdd(screw_quaternions , they_are_evil)
				SetBodyVelocity(body, AnglesForever)

				screw_quaternions2=GetBodyAngularVelocity(body)
				angle_force = GetInt("savegame.mod.progdest.VIOL_turnr")
				--square number, for more power
				angle_force	= angle_force * angle_force
				--scale down to 1/50th in case user wanted low number.
				angle_force	= angle_force *0.02					
				they_are_evil = Vec((0.5-math.random())*angle_force, (0.5-math.random())*angle_force,(0.5-math.random())*angle_force)
				AnglesForever2 = VecAdd(screw_quaternions2 , they_are_evil)
				SetBodyAngularVelocity(body, AnglesForever2)
				--DebugPrint("VIOLENCE BREEDS VIOLENCE")		
			end
		end

	end	
end	


-- local rainbow_red = 1.0
-- local rainbow_blu = 0.0
-- local rainbow_grin = 0.0

function SweetAssRainbowColors(dt)
	speed_of_shift = (GetInt("savegame.mod.progdest.rainbow_spd")/100)*dt
	local rainbow_red = GetFloat("savegame.mod.progdest.RB_RED")
	local rainbow_grin = GetFloat("savegame.mod.progdest.RB_GRN")
	local rainbow_blu = GetFloat("savegame.mod.progdest.RB_BLU")		
	if rainbow_red > 0.999 then
		if rainbow_grin > 0 then
			rainbow_grin=rainbow_grin-speed_of_shift
			else
			rainbow_blu=rainbow_blu+speed_of_shift
		end	
	end
	if rainbow_blu > 0.999 then
		if rainbow_red > 0 then
			rainbow_red=rainbow_red-speed_of_shift
			else
			rainbow_grin=rainbow_grin+speed_of_shift
		end	
	end
	if rainbow_grin > 0.999 then
		if rainbow_blu > 0 then
			rainbow_blu=rainbow_blu-speed_of_shift
			else
			rainbow_red=rainbow_red+speed_of_shift
		end	
	end
	--limits checked
	if rainbow_red > 1 then 
	rainbow_red = 1 
	end
	if rainbow_blu > 1 then 
	rainbow_blu = 1 
	end
	if rainbow_grin > 1 then
	rainbow_grin = 1
	end
	if rainbow_red < 0 then 
	rainbow_red = 0
	end
	if rainbow_blu < 0 then 
	rainbow_blu = 0
	end
	if rainbow_grin < 0 then 
	rainbow_grin = 0
	end
	SetFloat("savegame.mod.progdest.RB_RED", rainbow_red)
	SetFloat("savegame.mod.progdest.RB_GRN", rainbow_grin)
	SetFloat("savegame.mod.progdest.RB_BLU", rainbow_blu)
end

function SetPos(x,y)  --micro made this function, god rest his soul
  local cx = UiWidth() / 2
  local cy = UiHeight() / 2
  UiTranslate(cx + cx * x, cy + cy * y)
end

function CurrencyPick()
		if GetInt("savegame.mod.progdest.DAMSTAT_Currency")==1 then	
			CURR="£"
			Ratio=1
		end	
		if GetInt("savegame.mod.progdest.DAMSTAT_Currency")==2 then
			CURR="EUR"
			Ratio=1.17
		end			
		if GetInt("savegame.mod.progdest.DAMSTAT_Currency")==3 then
			CURR="JPY"
			Ratio=151.81
		end	
		if GetInt("savegame.mod.progdest.DAMSTAT_Currency")==4 then
			CURR="RUB"
			Ratio=101.81
		end
		if GetInt("savegame.mod.progdest.DAMSTAT_Currency")==5 then
			CURR="INR"
			Ratio=103.281
		end			
		if GetInt("savegame.mod.progdest.DAMSTAT_Currency")==6 then
			CURR="IQD"
			Ratio=2026.91
		end			
		if GetInt("savegame.mod.progdest.DAMSTAT_Currency")==7 then
			CURR="PLN"
			Ratio=5.3
		end	
		if GetInt("savegame.mod.progdest.DAMSTAT_Currency")==8 then
			CURR="Baljeets"
			Ratio=151.81
		end
		if GetInt("savegame.mod.progdest.DAMSTAT_Currency")==9 then
			CURR="ZAR"
			Ratio=20.08
		end	
		if GetInt("savegame.mod.progdest.DAMSTAT_Currency")==10 then
			CURR="VND"
			Ratio=21870.30
		end
		if GetInt("savegame.mod.progdest.DAMSTAT_Currency")==11 then
			CURR="BTC"
			Ratio=0.0000243
		end				
		if GetInt("savegame.mod.progdest.DAMSTAT_Currency")==12 then
			CURR="ETH"
			Ratio=0.000526
		end
		if GetInt("savegame.mod.progdest.DAMSTAT_Currency")==13 then
			CURR="Doge"
			Ratio=7.15
		end			
		if GetInt("savegame.mod.progdest.DAMSTAT_Currency")==14 then
			CURR="AMD"
			Ratio=675.16
		end
		if GetInt("savegame.mod.progdest.DAMSTAT_Currency")==15 then
			CURR="AZN"
			Ratio=2.35919
		end
		if GetInt("savegame.mod.progdest.DAMSTAT_Currency")==16 then
			CURR="GOLD"
			Ratio=0.000032154
		end			
		if GetInt("savegame.mod.progdest.DAMSTAT_Currency")==17 then
			CURR="SVR"
			Ratio=0.0037043897017966293
		end			
		if GetInt("savegame.mod.progdest.DAMSTAT_Currency")==18 then
			CURR="KgCop"
			Ratio=0.27397
		end			
		if GetInt("savegame.mod.progdest.DAMSTAT_Currency")==19 then
			CURR="Chik"
			Ratio=0.04
		end	
		if GetInt("savegame.mod.progdest.DAMSTAT_Currency")==20 then
			CURR="KFCh"
			Ratio=0.32
			
		end				
		if GetInt("savegame.mod.progdest.DAMSTAT_Currency")==21 then
			CURR="GVF"
			Ratio=0
		end			
		if GetInt("savegame.mod.progdest.DAMSTAT_Currency")==22 then
			CURR="CAP"
			Ratio=27
		end			
		if GetInt("savegame.mod.progdest.DAMSTAT_Currency")==23 then
			CURR="POT"
			Ratio=0.32
		end	
		if GetInt("savegame.mod.progdest.DAMSTAT_Currency")==24 then
			CURR="Cr"
			Ratio=0.0256
		end			
		if GetInt("savegame.mod.progdest.DAMSTAT_Currency")==25 then
			CURR="Edd"
			Ratio=65
		end			
		if GetInt("savegame.mod.progdest.DAMSTAT_Currency")==26 then
			CURR="d"
			Ratio=25.16
		end			
		if GetInt("savegame.mod.progdest.DAMSTAT_Currency")==27 then
			CURR="ROBUX"
			Ratio=87
		end			
		if GetInt("savegame.mod.progdest.DAMSTAT_Currency")==30 then --AUSTRALIAN DOLLAS - GOIN IN IF THEY EVAH FIX ROTAYTED TEKST MAYTE
			CURR="AUD"
			Ratio=1.88
		end	
end