
-- Constants
local fireLimit;
SetBool("savegame.mod.progdest.dust_DustMeth", false)

function resetSettings()
	SetBool("savegame.mod.progdest.Tog_FPSC", false); -- Toggle/Title for FPS Control section.
	SetBool("savegame.mod.progdest.Tog_DUST", false); -- Toggle/Title for Dust Control section.
	SetBool("savegame.mod.progdest.Tog_CRUMBLE", true); -- Toggle/Title for Crumble section.
	SetBool("savegame.mod.progdest.Tog_RUMBLE", false); -- Toggle/Title for Explosives section.	
	SetBool("savegame.mod.progdest.Tog_FORCE", false); -- Toggle/Title for Force section.
	SetBool("savegame.mod.progdest.Tog_FIRE", false);	-- Toggle/Title for Force section.
	SetBool("savegame.mod.progdest.Tog_VIOL", false);	-- Toggle/Title for Force section.
	SetBool("savegame.mod.progdest.Tog_DAMSTAT", false);	-- Toggle/Title for Force section.
	SetBool("savegame.mod.progdest.Tog_JOINTS", false);	-- Toggle/Title for Force section.
	--SetInt("savegame.mod.options_page", 1); -- Variable storing what page of the options USER is on.
	-- FPS Control Section
	SetBool("savegame.mod.progdest.FPS_DynLights", true);	
	SetBool("savegame.mod.progdest.Tog_SDF", true);
	SetBool("savegame.mod.progdest.Tog_LFF", false);
	SetBool("savegame.mod.progdest.Tog_DBF", false);
	SetInt("savegame.mod.progdest.FPS_SDF", 7);	
	SetInt("savegame.mod.progdest.FPS_LFF", 0);	
	SetInt("savegame.mod.progdest.FPS_DBF", 0);	
	SetInt("savegame.mod.progdest.FPS_DBF_size", 35);
	SetBool("savegame.mod.progdest.FPS_DBF_FPSB", true); -- Set DBF to only trigger when FPS is low.
	SetInt("savegame.mod.progdest.FPS_SDF_agg", 3);	
	SetInt("savegame.mod.progdest.FPS_LFF_agg", 1);	
	SetInt("savegame.mod.progdest.FPS_DBF_agg", 1);
	SetInt("savegame.mod.progdest.FPS_Targ", 1);	
	SetInt("savegame.mod.progdest.FPS_Agg", 1);
	SetBool("savegame.mod.progdest.FPS_GLOB_agg", false);
	SetInt("savegame.mod.progdest.FPS_GLOB_aggfac", 0);
	
	
	-- DUST Control Section
	SetInt("savegame.mod.progdest.dust_amt", 1);
	SetInt("savegame.mod.progdest.dust_size", 2);  -- REMEMBER - ALWAYS * 0.5
	SetInt("savegame.mod.progdest.dust_sizernd", 2);
	SetInt("savegame.mod.progdest.dust_MsBsSz", 2); --mass based size factor.
	SetInt("savegame.mod.progdest.dust_grav", 0.35);
	SetInt("savegame.mod.progdest.dust_drag", 0.15);
	SetInt("savegame.mod.progdest.dust_life", 8); -- REMEMBER - ALWAYS * 0.5
	SetInt("savegame.mod.progdest.dust_lifernd", 0.1);
	SetInt("savegame.mod.progdest.dust_MsBsLf", 0.2); --mass based life factor
	SetInt("savegame.mod.progdest.dust_minMass", 3); --Lower Cutoff
	SetInt("savegame.mod.progdest.dust_minSpeed", 3); --Lower Cutoff
	SetBool("savegame.mod.progdest.dust_DustMeth", false); -- false = on crumble, true = pure RNG.
	SetInt("savegame.mod.progdest.dust_MethRNG_Chance", 1); --Lower Cutoff
	SetInt("savegame.mod.progdest.dust_startsize", 10)
	SetInt("savegame.mod.progdest.dust_fader", 5)
	
	-- COLORS A NEW FEATURE TO DELAY THE LAUNCH!
	SetInt("savegame.mod.progdest.dust_ColMode", 0); --ColourMode (1 colour , 2 color , 3 color , randomized, greyscale)
	SetInt("savegame.mod.progdest.dust_Col1_R", 10);
	SetInt("savegame.mod.progdest.dust_Col1_G", 10);
	SetInt("savegame.mod.progdest.dust_Col1_B", 10);
	SetInt("savegame.mod.progdest.dust_Col2_R", 100);
	SetInt("savegame.mod.progdest.dust_Col2_G", 20);
	SetInt("savegame.mod.progdest.dust_Col2_B", 100);
	SetInt("savegame.mod.progdest.dust_Col3_R", 0.2);
	SetInt("savegame.mod.progdest.dust_Col3_G", 0.2);
	SetInt("savegame.mod.progdest.dust_Col3_B", 0.2);

	
	--Crumbling
	SetBool("savegame.mod.progdest.tog_crum", true);
	SetInt("savegame.mod.progdest.tog_crum_MODE", 0);  -- Mode - interval (0) or randomized (1).
	SetInt("savegame.mod.progdest.tog_crum_Source", 0);  -- Mode - Debris Only (0) or all phys (1).	
	SetInt("savegame.mod.progdest.crum_DMGLight", 50);
	SetInt("savegame.mod.progdest.crum_DMGMed", 50);
	SetInt("savegame.mod.progdest.crum_DMGHeavy", 50);
	SetInt("savegame.mod.progdest.crum_spd", 2);
	SetFloat("savegame.mod.progdest.crum_spdRND", 0.01);
	SetInt("savegame.mod.progdest.crum_dist", 8);
	SetBool("savegame.mod.progdest.vehicles_crumble", false);
	
	SetInt("savegame.mod.progdest.crum_HoleControl", 4);
	SetFloat("savegame.mod.progdest.crum_BreakTime", 2.5); --DIV BY 2
	SetInt("savegame.mod.progdest.crum_distFromPlyr", 40);
	SetInt("savegame.mod.progdest.crum_MinMass", 1);
	SetInt("savegame.mod.progdest.crum_MaxMass", 1000);
	SetFloat("savegame.mod.progdest.crum_MinSpd", 0.0025); -- RAW VALUE IS DIV BY 1000
	SetFloat("savegame.mod.progdest.crum_MaxSpd", 8);
		
	-- Explosions! I like explosions
	SetFloat("savegame.mod.progdest.xplo_szBase", 0.35);
	SetFloat("savegame.mod.progdest.xplo_szRnd", 0.15);
	SetFloat("savegame.mod.progdest.xplo_szMBV", 0.15);  --Mass Based Explosion Variation.
	SetInt("savegame.mod.progdest.xplo_chance", 4);  --Chance to explode. Store as int, but div by 100 to make percentage.
	
	SetInt("savegame.mod.progdest.xplo_Control", 4);
	SetFloat("savegame.mod.progdest.xplo_BreakTime", 2.5);
	SetInt("savegame.mod.progdest.xplo_distFromPlyr", 40);
	SetInt("savegame.mod.progdest.xplo_MinMass", 1);
	SetInt("savegame.mod.progdest.xplo_MaxMass", 10000);
	SetFloat("savegame.mod.progdest.xplo_MinSpd", 0.0025);
	SetFloat("savegame.mod.progdest.xplo_MaxSpd", 8);
	SetInt("savegame.mod.progdest.xplo_SmokeAMT", 2);
	SetInt("savegame.mod.progdest.xplo_LifeAMT", 2);
	SetInt("savegame.mod.progdest.xplo_Pressure", 4);
	SetInt("savegame.mod.progdest.xplo_mode", 1);  --explosion mode 1=debris only, 2=all dynamic, 3= vehicles only
	
	SetInt("savegame.mod.progdest.xplo_ColMode", 1); --ColourMode (1 colour , 2 color , 3 color , randomized, greyscale)
	SetInt("savegame.mod.progdest.xplo_Col1_R", 100);
	SetInt("savegame.mod.progdest.xplo_Col1_G", 95);
	SetInt("savegame.mod.progdest.xplo_Col1_B", 16);
	SetInt("savegame.mod.progdest.xplo_Col2_R", 84);
	SetInt("savegame.mod.progdest.xplo_Col2_G", 51);
	SetInt("savegame.mod.progdest.xplo_Col2_B", 0);
	SetInt("savegame.mod.progdest.xplo_Col3_R", 17);
	SetInt("savegame.mod.progdest.xplo_Col3_G", 16);
	SetInt("savegame.mod.progdest.xplo_Col3_B", 18);
	
	-- Force and Fire
	SetInt("savegame.mod.progdest.4ce_method", 1); 
	-- 1 - Force from player (pull or push away)
	-- 2 - Random jitter.
	-- 3 - Horizontal rotating (+/- for CW and ACW)	
	-- 4 - Vertical rotating Clockwise (+/- for CW and ACW)
	-- 5 - Cradle rocking (E/W)
	-- 6 - Cradle rocking (N/S)
	-- 7 - Up / Down
	-- 8 - East/West wind
	-- 9 - North/South wind.

	SetInt("savegame.mod.progdest.4ce_gamecontrols", 0.35); -- toggle in game controls on or off
	SetInt("savegame.mod.progdest.4ce_radius", 0.35); -- toggle in game controls on or off
	SetInt("savegame.mod.progdest.4ce_maxmass", 0.35); -- toggle in game controls on or off
	SetInt("savegame.mod.progdest.4ce_minmass", 0.35); -- toggle in game controls on or off
	SetInt("savegame.mod.progdest.4ce_strength", 0.35); -- toggle in game controls on or off
	SetInt("savegame.mod.progdest.4ce_boost", 0.35)
	SetBool("savegame.mod.progdest.4ce_EdgeFade", true);
	SetBool("savegame.mod.progdest.4ce_START_ON", false);
	SetBool("savegame.mod.progdest.4ce_ENABLE_CONTROLS", false);
	SetBool("savegame.mod.progdest.4ce_Showcross", false);
	SetBool("savegame.mod.progdest.4ce_CONTROL_TIPS", false);
	-- math.sin(GetTime()) --apparently takes 6.28 seconds for a full rotation
	SetInt("savegame.mod.progdest.4ce_cycle", 0.35); -- OPTIONAL Rotating/Rocking cycle time.
	SetInt("savegame.mod.progdest.4ce_largemass_accellerator", 0.35); -- Use to either amplify or soften scaler at higher masses.
	SetInt("savegame.mod.progdest.4ce_upforce", 0.35); -- Custom Upforce to counter friction.
	SetInt("savegame.mod.progdest.4ce_effect_on_player",0)

	-- MISCELLANEOUS SETTINGS
	-- Fire
	SetInt("savegame.mod.progdest.fyr_mode", 1); 
	SetInt("savegame.mod.progdest.fyr_maxrad", 15); -- maximum radius of the effect
	SetInt("savegame.mod.progdest.fyr_minrad", 4); -- Minimum radius of the effect
	SetInt("savegame.mod.progdest.fyr_chance", 1); -- should make sense, if not go get a lobotomy.
	SetInt("savegame.mod.progdest.fyr_maxmass", 4000); -- THE MAXIMUM MASS OF AN OBJECT WHICH COULD CATCH FIRE. WOW! THESE COMMENTS ARE REALLY NEEDED!
	SetInt("savegame.mod.progdest.fyr_minmass", 2); -- kys
	-- VIOLENCE
	SetInt("savegame.mod.progdest.VIOL_mode", 1); 
	-- 1 - Debris_only
	-- 2 - Any dynamic body (no vehicles)
	-- 3 - Vehicles only
	-- 4 - All of the above
	-- VIOLENCE
	SetInt("savegame.mod.progdest.VIOL_Chance", 1); 
	SetInt("savegame.mod.progdest.VIOL_mover", 2); -- maximum radius of the effect
	SetInt("savegame.mod.progdest.VIOL_turnr", 2);
	SetInt("savegame.mod.progdest.VIOL_minmass", 5);
	SetInt("savegame.mod.progdest.VIOL_maxmass", 2000);
	-- JOINT BREAKAGE
	SetInt("savegame.mod.progdest.JOINT_Source", 1);  -- 1=Debris chunks // 2=player
	SetInt("savegame.mod.progdest.JOINT_Range", 5); -- radius to check for joints from the source.
	SetInt("savegame.mod.progdest.JOINT_Chance", 5); -- percent chance to break in radius.
	
end

function optionsSlider(key, default, min, max, incri)    
        local steps = incri or 1
        local value = (GetInt(key) - min) / (max - min);
        local width = 100;
		UiTranslate(50, 0);
        UiRect(width, 3);
		UiTranslate(-50, 0);
        value = UiSlider("ui/common/dot.png", "x", value*width, 0, width)/width;
        value = math.floor((value*(max-min)+min)/steps+0.5)*steps;
        SetInt(key, value);
    return value;
end

function optionsSliderLarge(key, default, min, max, incri)    
        local steps = incri or 1
        local value = (GetInt(key) - min) / (max - min);
        local width = 200;
		UiTranslate(100, 0);
        UiRect(width, 3);
		UiTranslate(-100, 0);
        value = UiSlider("ui/common/dot.png", "x", value*width, 0, width)/width;
        value = math.floor((value*(max-min)+min)/steps+0.5)*steps;
        SetInt(key, value);
    return value;
end

function optionsSliderYuge(key, default, min, max, incri)    
        local steps = incri or 1
        local value = (GetInt(key) - min) / (max - min);
        local width = 500;
		UiTranslate(250, 0);
        UiRect(width, 3);
		UiTranslate(-250, 0);
        value = UiSlider("ui/common/dot.png", "x", value*width, 0, width)/width;
        value = math.floor((value*(max-min)+min)/steps+0.5)*steps;
        SetInt(key, value);
    return value;
end

function drawButton(title, key, value)
		if UiTextButton(title .. " (" .. (GetBool(key) and "enabled" or "disabled") .. ")", 340, 32) then
			SetBool(key, not GetBool(key));	
		end
		if GetBool(key) then
			UiColor(0.5, 1, 0.5);
			UiTranslate(-145, 0);
			UiImage("ui/menu/mod-active.png");
		else
			UiTranslate(-145, 0);
			UiImage("ui/menu/mod-inactive.png");
		end
end

function init()
	if(GetBool("savegame.mod.performance.launch")) then
		fireLimit = GetInt("savegame.mod.performance.fire_limit");
	end
	--SetInt("savegame.mod.options_page", 1);
	SetBool("savegame.mod.launch", false);
end

function page_selector()
		UiFont("regular.ttf", 34)
		UiButtonImageBox("ui/common/box-outline-6.png", 6, 6)	
--		UiAlign("left top");
		UiPush();	SetPos(-0.70,-0.7);
		col=0.5+(math.sin(GetTime()*4)/2)
		if GetInt("savegame.mod.options_page")==1 then
			UiColor(col,col*2,col)		
			if UiTextButton(">PRESETS<", 320, 50) then
				SetInt("savegame.mod.options_page", 1);
			end
			else
			if UiTextButton("PRESETS", 320, 50) then
				SetInt("savegame.mod.options_page", 1);
			end
			UiColor(1,1,1)
		end	
		UiPop();
		UiPush();	SetPos(-0.35,-0.7);
		if GetInt("savegame.mod.options_page")==2 then
			UiColor(col,col*2,col)		
			if UiTextButton(">Debris and Dust<", 320, 50) then
				SetInt("savegame.mod.options_page", 2);
			end
			else
			if UiTextButton("Debris and Dust", 320, 50) then
				SetInt("savegame.mod.options_page", 2);
			end
			UiColor(1,1,1)
		end	
		UiPop();
		UiPush();	SetPos(0.0,-0.7);
		if GetInt("savegame.mod.options_page")==3 then
			UiColor(col,col*2,col)		
			if UiTextButton(">Crumble and Rumble<", 320, 50) then
				SetInt("savegame.mod.options_page", 3);
			end
			else
			if UiTextButton("Crumble and Rumble", 320, 50) then
				SetInt("savegame.mod.options_page", 3);
			end
			UiColor(1,1,1)
		end	
		UiPop();	
		UiPush();	SetPos(0.35,-0.7);
		if GetInt("savegame.mod.options_page")==4 then
			UiColor(col,col*2,col)		
			if UiTextButton(">Force and Fire<", 320, 50) then
				SetInt("savegame.mod.options_page", 4);
			end
			else
			if UiTextButton("Force and Fire", 320, 50) then
				SetInt("savegame.mod.options_page", 4);
			end
			UiColor(1,1,1)
		end	
		UiPop();			
		UiPush();	SetPos(0.70,-0.7);
		if GetInt("savegame.mod.options_page")==5 then
			UiColor(col,col*2,col)		
			if UiTextButton(">Options Help<", 320, 50) then
				SetInt("savegame.mod.options_page", 5);
			end
			else
			if UiTextButton("Options Help", 320, 50) then
				SetInt("savegame.mod.options_page", 5);
			end	
			UiColor(1,1,1)
		end	
		UiPop();	
end

function SetPos(x,y)  --micro made this function, god rest his soul
  local cx = UiWidth() / 2
  local cy = UiHeight() / 2
  UiTranslate(cx + cx * x, cy + cy * y)
end

function Rectangle(sx,sy,ex,ey)  --micro made this function, god rest his soul
  local cx = UiWidth() / 2
  local cy = UiHeight() / 2
  UiTranslate(cx + cx * sx, cy + cy * sy)
  UiRect((cx + cx * ex)-(cx + cx * sx),(cy + cy * ey)-(cy + cy * sy))
end



function draw()
	-- TITLE SECTION
	if math.random()>0.8 then
		DebugPrint("") -- clear the debug log to stop it being annoying.
	end
	
	UiColor(1,1,1);
	UiAlign("center middle");	
	UiFont("bold.ttf", 48);
	UiPush();	SetPos(0,-0.9);	UiText("Progressive Destruction Mod (V0.86)");
	UiPop();

	UiFont("regular.ttf", 24);
	UiPush();	SetPos(0,-0.8); 	UiText("Be Very Careful about adjusting these settings. Game crash can result, if game forced to do too much at once!");
	UiPop();


	UiButtonImageBox("ui/common/box-outline-6.png", 6, 6);
	UiColor(0.35+(math.random()*0.5),0.35+(math.random()*0.5),0.35+(math.random()*0.5));
	UiPush();	SetPos(-0.5,0.88); 	
	if UiTextButton("Close", 80, 40) or InputPressed("esc") then
		SetInt("options.gfx.renderscale", math.max(GetInt("savegame.mod.performance.renderscale"), 1));
		Menu();
	end	
	UiPop();	
	UiPush();	SetPos(0.5,0.88); 	
	if UiTextButton("Reset", 80, 40) then
		resetSettings();
	end
	UiPop();
	UiFont("regular.ttf", 18);
	UiPush();	SetPos(0.75,0.88);	UiText("<< WARNING, RESETS ENTIRE MOD.");
	UiPop();
	
	UiColor(1,1,1);
	UiPush();	SetPos(0,0.88);	UiText("PLEASE NOTE THAT THERE IS AN EMERGENCY KEY, PRESS '-' TO DELETE ALL DEBRIS INSTANTLY");
	UiPop();
	page_selector()
	UiFont("regular.ttf", 24);
	-- the following checks if global aggression is enabled, and if so, sets all controlled values


	if GetInt("savegame.mod.options_page")==1 then
		DrawPage1()
	end
	if GetInt("savegame.mod.options_page")==2 then
		DrawPage2()
	end
	if GetInt("savegame.mod.options_page")==3 then
		DrawPage3()
	end
	if GetInt("savegame.mod.options_page")==4 then
		DrawPage4()
	end
	if GetInt("savegame.mod.options_page")==5 then
		DrawPage5()
	end	
end

function DrawPage2()
	-- Draw content (sliders and buttons).
	UiFont("regular.ttf", 38);
	UiPush();	SetPos(-0.5,-0.55); 	UiText("FRAMERATE CONTROL SETTINGS:");
	UiPop();
	UiPush();	SetPos(0.5,-0.55); 	UiText("DUST CONTROL SETTINGS:");
	UiPop();	
	UiColor(0.65,0.65,1);
	UiPush();	SetPos(0,0.1); UiRect(2,600);
	UiPop();
	UiPush();	SetPos(0,-0.50); UiRect(3000,3);
	UiPop();	
	UiPush();	SetPos(0,0.70); UiRect(3000,3);
	UiPop();	
	UiColor(1,1,1);	
	
	UiFont("bold.ttf", 20);
	UiButtonImageBox("ui/common/box-outline-6.png", 6, 6);
	UiPush();	SetPos(-0.7,-0.45); 	drawButton("Enable FPS Control?", "savegame.mod.progdest.Tog_FPSC");
	UiPop();
	if GetBool("savegame.mod.progdest.Tog_FPSC") then -- If FPS Control is on, draw all the shizzle...
		UiPush();	SetPos(-0.7,-0.37); drawButton("NO Dynamic Lights", "savegame.mod.progdest.FPS_DynLights");
		UiPop();
		UiPush();	SetPos(-0.7,-0.26); drawButton("Small Debris Filter-er", "savegame.mod.progdest.Tog_SDF");
		UiPop();
		UiPush();	SetPos(-0.7,-0.11); drawButton("Low FPS filter-er.", "savegame.mod.progdest.Tog_LFF");
		UiPop();
		UiPush();	SetPos(-0.7,0.04); drawButton("Distance Based Filter", "savegame.mod.progdest.Tog_DBF");
		UiPop();		
		UiPush();	SetPos(-0.7,0.19); drawButton("DBF Framerate Linked", "savegame.mod.progdest.FPS_DBF_FPSB");
		UiPop();
		UiPush();	SetPos(-0.7,0.39); drawButton("Global Agression Factor", "savegame.mod.progdest.FPS_GLOB_agg");
		UiPop();		
		
		UiFont("bold.ttf", 18);
		UiColor(0.15,0.65,1);
--		UiColor(0,0,0);
		UiPush();	SetPos(-0.28,-0.38);	UiText("If a level has a lot of lights, or your computer is trash, turning off");
		UiPop();
		UiPush();	SetPos(-0.28,-0.35);	UiText("dynamic lights can increase your Frames Per Second.");
		UiPop();

		UiPush();	SetPos(-0.50,-0.21);	UiText("The SDF will slowly over time remove bits of debris smaller than this. This has a low chance but is frequently checked.");
		UiPop();
		UiPush();	SetPos(-0.50,-0.18);	UiText("This method keeps FPS stable, rather than 100% chance, lower frequency, which tends to cause micro-freezes in FPS.");
		UiPop();
		UiPush();	SetPos(-0.5,-0.06);	UiText("The LFF is a SEPERATE function to the SDF. When your FPS goes UNDER the FPS target below, the game will start to");
		UiPop();
		UiPush();	SetPos(-0.5,-0.03);	UiText("remove debris, up to the LFF Max Debris Size. Also low chance, rapid checking to dilute FPS impact.");
		UiPop();
		UiPush();	SetPos(-0.50,0.09);	UiText("Use the slider to set the MINIMUM distance away something must be, before the game will have a small chance to remove");
		UiPop();
		UiPush();	SetPos(-0.50,0.12);	UiText("it. Use the FRAMERATE LINKED button below, to set this to only occur when the framerate falls below the FPS target.");
		UiPop();
		UiPush();	SetPos(-0.48,0.44);	UiText("The GAF overrides individual Debris Filter, Dust Life Control, and FPS Target sliders.");
		UiPop();
		UiPush();	SetPos(-0.48,0.47);	UiText("Use this to set one setting for all, if you dont want each setting to be different.");
		UiPop();	
		UiPush();	SetPos(-0.48,0.29);	UiText("The only way to grab FPS is through a function which lies if FPS is less than 30, and says it's 30fps. So a `target` function");
		UiPop();			
		UiPush();	SetPos(-0.48,0.32);	UiText("must start at 35fps. Use this (with its agression high) to boost debris removal ONLY when fps goes below this amount.");
		UiPop();
		
		UiColor(1,1,1);
		UiFont("bold.ttf", 24);		
		UiPush();	SetPos(-0.8,0.25);	UiText("FPS TARGET:");
		UiPop();
		UiPush();	SetPos(-0.7,0.25);	local value = optionsSlider("savegame.mod.progdest.FPS_Targ", 30, 30, 144,5);
		UiPop();
		UiPush();	SetPos(-0.55,0.25);	
			if GetInt("savegame.mod.progdest.FPS_Targ")<35 then
				UiText("Off");
				else
				UiText(value);
			end
		UiPop();
		if GetInt("savegame.mod.progdest.FPS_Targ") > 30 then
			UiPush();	SetPos(-0.37,0.25);	UiText("FPS AGGRESSION:");
			UiPop();
			UiPush();	SetPos(-0.25,0.25); local value = optionsSlider("savegame.mod.progdest.FPS_Agg", 1, 1, 100);
			UiPop();
			UiPush();	SetPos(-0.08,0.25); UiText(value);
			UiPop();
		end
		if GetBool("savegame.mod.progdest.FPS_GLOB_agg") then
			UiPush();	SetPos(-0.40,0.39);	UiText("GLOBAL AGGRESSION:");
			UiPop();
			UiPush();	SetPos(-0.25,0.39); local value = optionsSlider("savegame.mod.progdest.FPS_GLOB_aggfac", 1, 1, 100);
			UiPop();
			UiPush();	SetPos(-0.08,0.39); UiText(value);
			UiPop();
			if value>0 then
				SetInt("savegame.mod.progdest.FPS_SDF_agg", value);
				SetInt("savegame.mod.progdest.FPS_DBF_agg", value);
				SetInt("savegame.mod.progdest.FPS_LFF_agg", value);
				SetInt("savegame.mod.progdest.FPS_Agg", value);
			end
		end

		
		UiFont("regular.ttf", 24);
		UiColor(1,0.5,0.5);
		UiPush();	SetPos(0,0.8); 	UiText("The AGRESSION mentioned in the sliders above control the severity of removal routines. 1 means very slowly over time, 100 means very quickly and noticeably");
		UiPop();
		UiFont("bold.ttf", 16);
		UiColor(1,1,1);
		if GetBool("savegame.mod.progdest.Tog_SDF") then
			UiPush();	SetPos(-0.48,-0.26);	UiText("Filter Size:");
			UiPop();
			UiPush();	SetPos(-0.43,-0.26); local value = optionsSlider("savegame.mod.progdest.FPS_SDF", 10, 0, 100);
			UiPop();
			UiPush();	SetPos(-0.30,-0.26); UiText(value);
			UiPop();
			UiPush();	SetPos(-0.20,-0.26);	UiText("AGGRESSION:");
			UiPop();
			UiPush();	SetPos(-0.15,-0.26); local value = optionsSlider("savegame.mod.progdest.FPS_SDF_agg", 1, 1, 100);
			UiPop();
			UiPush();	SetPos(-0.02,-0.26); UiText(value);
			UiPop();
		end
		if GetBool("savegame.mod.progdest.Tog_LFF") then		
			UiPush();	SetPos(-0.48,-0.11);	UiText("Filter Size:");
			UiPop();
			UiPush();	SetPos(-0.43,-0.11); local value = optionsSlider("savegame.mod.progdest.FPS_LFF", 10, 5, 3000);
			UiPop();
			UiPush();	SetPos(-0.30,-0.11); UiText(value);
			UiPop();
			UiPush();	SetPos(-0.20,-0.11);	UiText("AGGRESSION:");
			UiPop();
			UiPush();	SetPos(-0.15,-0.11); local value = optionsSlider("savegame.mod.progdest.FPS_LFF_agg", 1, 1, 100);
			UiPop();
			UiPush();	SetPos(-0.02,-0.11); UiText(value);
			UiPop();		
		end
		if GetBool("savegame.mod.progdest.Tog_DBF") then	
			UiPush();	SetPos(-0.48,0.04);	UiText("Distance:");
			UiPop();
			UiPush();	SetPos(-0.43,0.04); local value = optionsSlider("savegame.mod.progdest.FPS_DBF", 10, 0, 300,5);
			UiPop();
			UiPush();	SetPos(-0.30,0.04); UiText(value);
			UiPop();		
			UiPush();	SetPos(-0.20,0.04);	UiText("AGGRESSION:");
			UiPop();
			UiPush();	SetPos(-0.15,0.04); local value = optionsSlider("savegame.mod.progdest.FPS_DBF_agg", 1, 1, 100);
			UiPop();
			UiPush();	SetPos(-0.02,0.04); UiText(value);
			UiPop();
		end	
	end -- End of FPS Controls Drawing.
	UiColor(0.65,0.65,1);
	UiPush();	SetPos(0,0.1); UiRect(2,600);
	UiPop();
	UiPush();	SetPos(0,-0.50); UiRect(3000,3);
	UiPop();	
	UiPush();	SetPos(0,0.70); UiRect(3000,3);
	UiPop();	
	UiColor(1,1,1);
	-- START OF **DUST** Section
	UiFont("bold.ttf", 20);
	UiColor(1,1,1);
	UiButtonImageBox("ui/common/box-outline-6.png", 6, 6);
	UiPush();	SetPos(0.25,-0.45); 	drawButton("Enable Dust/Smoke?", "savegame.mod.progdest.Tog_DUST");
	UiPop();
	if GetBool("savegame.mod.progdest.Tog_DUST") then		
		
		UiPush();	SetPos(0.50,-0.40);	UiText("NOTE: Dust will not appear unless CRUMBLE is enabled (Unless `METHOD` on crumble page is `Fully Random`)");
		UiPop();
		UiPush();	SetPos(0.15,-0.30);	UiText("Base Dust amount:");
		UiPop();
		UiPush();	SetPos(0.25,-0.30); local value = optionsSlider("savegame.mod.progdest.dust_amt", 0, 1, 200);
		UiPop();
		UiPush();	SetPos(0.40,-0.30); UiText(value);
		UiPop();
		UiPush();	SetPos(0.10,-0.20);	UiText("Dust weight:");
		UiPop();
		UiPush();	SetPos(0.16,-0.20); local value = optionsSliderLarge("savegame.mod.progdest.dust_grav", 17, -1200, 1200,5);
		UiPop();
		UiPush();	SetPos(0.40,-0.20); UiText(value*0.01);
		UiPop();
		
		UiPush();	SetPos(0.52,-0.30);	UiText("Fade-in time:");
		UiPop();	
		UiPush();	SetPos(0.62,-0.30); local value = optionsSlider("savegame.mod.progdest.dust_fader", 0, 1, 400);
		UiPop();
		UiPush();	SetPos(0.76,-0.30); UiText(value/1000);
		UiPop();

		UiPush();	SetPos(0.17,-0.25);	UiText("Dust air-drag:");
		UiPop();
		UiPush();	SetPos(0.25,-0.25); local value = optionsSlider("savegame.mod.progdest.dust_drag", 0.13, -44, 44);
		UiPop();
		UiPush();	SetPos(0.40,-0.25); UiText(value*0.01);
		UiPop();
		
		-- SIZE Section
		UiPush();	SetPos(0.15,-0.12);	UiText("Base Dust Size:");
		UiPop();
		UiPush();	SetPos(0.25,-0.12); local value = optionsSlider("savegame.mod.progdest.dust_size", 1, 1, 20);
		UiPop();
		UiPush();	SetPos(0.40,-0.12); UiText(value*0.25);
		UiPop();
		UiPush();	SetPos(0.15,-0.07);	UiText("Randomize Size:");
		UiPop();
		UiPush();	SetPos(0.25,-0.07); local value = optionsSlider("savegame.mod.progdest.dust_sizernd", 1, 1, 200,5);
		UiPop();
		UiPush();	SetPos(0.40,-0.07); UiText(value);
		UiPop();
		UiPush();	SetPos(0.42,-0.07); UiText("%");
		UiPop();
		UiPush();	SetPos(0.15,-0.02);	UiText("MASS Based Size:");
		UiPop();
		UiPush();	SetPos(0.25,-0.02); local value = optionsSlider("savegame.mod.progdest.dust_MsBsSz", 1, 1, 100,5);
		UiPop();
		UiPush();	SetPos(0.40,-0.02); UiText(value);
		UiPop();
		UiPush();	SetPos(0.42,-0.02); UiText("%");
		UiPop();
		
		UiPush();	SetPos(0.15,0.08);	UiText("Starting Size %");
		UiPop();
		UiPush();	SetPos(0.25,0.08); local value = optionsSlider("savegame.mod.progdest.dust_startsize", 1, 1, 100,1);
		UiPop();
		UiPush();	SetPos(0.40,0.08); UiText(value*10);
		UiPop();
		UiPush();	SetPos(0.43,0.08); UiText("%");
		UiPop();
		
		-- LIFETIME section
		UiPush();	SetPos(0.15,0.33);	UiText("Sust Lifetime:");
		UiPop();
		UiPush();	SetPos(0.25,0.33); local value = optionsSlider("savegame.mod.progdest.dust_life", 1, 1, 60);
		UiPop();
		UiPush();	SetPos(0.40,0.33); UiText(value*0.5);
		UiPop();
		UiPush();	SetPos(0.455,0.33); UiText("Seconds");
		UiPop();
		UiPush();	SetPos(0.15,0.38);	UiText("Randomize Life:");
		UiPop();
		UiPush();	SetPos(0.25,0.38); local value = optionsSlider("savegame.mod.progdest.dust_lifernd", 1, 1, 100);
		UiPop();
		UiPush();	SetPos(0.40,0.38); UiText(value);
		UiPop();
		UiPush();	SetPos(0.42,0.38); UiText("%");
		UiPop();
		UiPush();	SetPos(0.15,0.43);	UiText("MASS Based Life:");
		UiPop();
		UiPush();	SetPos(0.25,0.43); local value = optionsSlider("savegame.mod.progdest.dust_MsBsLf", 1, 1, 100);
		UiPop();
		UiPush();	SetPos(0.40,0.43); UiText(value);
		UiPop();
		UiPush();	SetPos(0.42,0.43); UiText("%");
		UiPop();
		UiPush();	SetPos(0.15,0.53);	UiText("Minimum Mass:");
		UiPop();
		UiPush();	SetPos(0.25,0.53); local value = optionsSlider("savegame.mod.progdest.dust_minMass", 3, 0, 100);
		UiPop();
		UiPush();	SetPos(0.40,0.53); UiText(value);
		UiPop();
		UiPush();	SetPos(0.15,0.58);	UiText("Minimum Speed:");
		UiPop();
		UiPush();	SetPos(0.25,0.58); local value = optionsSlider("savegame.mod.progdest.dust_minSpeed", 3, 0, 100);
		UiPop();
		UiPush();	SetPos(0.40,0.58); UiText(value/5);
		UiPop();
		-- Helpful Guides
		UiColor(0.15,0.65,1);
		-- ORIGINAL / DEFAULT SIZE
		UiPush();	SetPos(0.20,0.03); UiText("Dust Size will be between:");
		UiPop();		
		UiPush();	SetPos(0.32,0.03); UiText(GetInt("savegame.mod.progdest.dust_size")*0.25);
		UiPop();		
		UiPush();	SetPos(0.355,0.03); UiText("and");
		UiPop();				
		val = (GetInt("savegame.mod.progdest.dust_size")*0.25) * (1+(GetInt("savegame.mod.progdest.dust_sizernd")*0.01)) * (1+(GetInt("savegame.mod.progdest.dust_MsBsSz")*0.01));
		UiPush();	SetPos(0.40,0.03); UiText(val);
		UiPop();	
		-- STARTING SIDE
		UiPush();	SetPos(0.20,0.12); UiText("After starting at");
		UiPop();		
		UiPush();	SetPos(0.32,0.12); UiText((GetInt("savegame.mod.progdest.dust_size")*0.25)*(GetInt("savegame.mod.progdest.dust_startsize")/10));
		UiPop();		
		UiPush();	SetPos(0.355,0.12); UiText("and");
		UiPop();				
		val = ((GetInt("savegame.mod.progdest.dust_size")*0.25) * (1+(GetInt("savegame.mod.progdest.dust_sizernd")*0.01)) * (1+(GetInt("savegame.mod.progdest.dust_MsBsSz")*0.01)))*(GetInt("savegame.mod.progdest.dust_startsize")/10);
		UiPush();	SetPos(0.40,0.12); UiText(val);
		UiPop();	
		
		UiPush();	SetPos(0.16,0.48); UiText("Dust Life will be between:");
		UiPop();		
		UiPush();	SetPos(0.28,0.48); UiText(GetInt("savegame.mod.progdest.dust_life")*0.5);
		UiPop();		
		UiPush();	SetPos(0.315,0.48); UiText("and");
		UiPop();				
		val = (GetInt("savegame.mod.progdest.dust_life")*0.5) * (1+(GetInt("savegame.mod.progdest.dust_lifernd")*0.01)) * (1+(GetInt("savegame.mod.progdest.dust_MsBsLf")*0.01));
		UiPush();	SetPos(0.36,0.48); UiText(val);
		UiPop();			

		UiPush();	SetPos(0.42,0.48); UiText("seconds");
		UiPop();	
		UiPush();	SetPos(0.27,0.63);	UiText("Min mass/speed sets minimums, below which no smoke is made.");
		UiPop();		
		UiPush();	SetPos(0.27,0.66);	UiText("This stops tiny/stationary bits of debris farting out smoke.");
		UiPop();
		UiPush();	SetPos(0.68,-0.26);	UiText("Fade In Time stops smoke just suddely appearing full and");
		UiPop();
		UiPush();	SetPos(0.68,-0.22);	UiText("thick. Value is based on life, so full setting of 0.40");
		UiPop();
		UiPush();	SetPos(0.68,-0.18);	UiText("means it takes 40% of smoke's life, to finish fading in.");
		UiPop();
		UiPush();	SetPos(0.23,-0.17);	UiText("Negative weight makes smoke fall");
		UiPop();		
		UiColor(1,1,0);
		UiPush();	SetPos(0.27,0.18);	UiText("The game scales smoke between 0.0 and 1.0. But the mod will scale");
		UiPop();
		UiPush();	SetPos(0.27,0.22);	UiText("the options above to try and fit into this. Beware of trying to");
		UiPop();
		UiPush();	SetPos(0.27,0.26);	UiText("make massive smoke... there is an upper limit, which is enforced.");
		UiPop();
		-- COLOUR OPTIONS
		-- COLOUR OPTIONS
			
		-- the sick multi-click multi-mode selectatron
		UiColor(1,1-math.random(),1)
		UiPush();	SetPos(0.585,-0.10);	
		if UiTextButton("COLOR MODE", 128, 40) then
			SetInt("savegame.mod.progdest.dust_ColMode",GetInt("savegame.mod.progdest.dust_ColMode")+1);
		end	
		UiPop();
		if GetInt("savegame.mod.progdest.dust_ColMode")>6 then	
			SetInt("savegame.mod.progdest.dust_ColMode", 1);
		end
		-- Single Color mode
		UiColor(1,1,1)
		if GetInt("savegame.mod.progdest.dust_ColMode")==1 then
		
			UiPush();	SetPos(0.75,-0.10);	UiText("Single Color Mode");
			UiPop();

		end
		if GetInt("savegame.mod.progdest.dust_ColMode")==2 then
		
			UiPush();	SetPos(0.75,-0.10);	UiText("Dual Color Mode");
			UiPop();

		end	
		if GetInt("savegame.mod.progdest.dust_ColMode")==3 then
		
			UiPush();	SetPos(0.75,-0.10);	UiText("Three Color Mode");
			UiPop();

		end		
		if GetInt("savegame.mod.progdest.dust_ColMode")==4 then
		
			UiPush();	SetPos(0.75,-0.10);	UiText("Randomized Rainbow");
			UiPop();

		end	
		if GetInt("savegame.mod.progdest.dust_ColMode")==5 then
		
			UiPush();	SetPos(0.75,-0.10);	UiText("Shifting Rainbow");
			UiPop();
			UiPush();	SetPos(0.58,0.0);	UiText("Color change speed:");
			UiPop();	
			UiPush();	SetPos(0.74,0.0); local value = optionsSlider("savegame.mod.progdest.rainbow_spd", 0, 1, 200);
			UiPop();
			UiPush();	SetPos(0.88,0.0); UiText(value/1000);
			UiPop();			

		end				
		if GetInt("savegame.mod.progdest.dust_ColMode")==6 then
		
			UiPush();	SetPos(0.75,-0.10);	UiText("GreyScale");
			UiPop();

		end		
		if GetInt("savegame.mod.progdest.dust_ColMode") < 4 then -- If it's 1,2 or 3, draw color selector 1
		
			UiPush();	SetPos(0.63,-0.03);	UiText("Colour 1:");
			UiPop();
			
			UiPush();	SetPos(0.585,0.02);	UiText("RED");
			UiPop();
			UiPush();	SetPos(0.64,0.02); local value = optionsSlider("savegame.mod.progdest.dust_Col1_R", 1, -100, 100);
			UiPop();
			UiPush();	SetPos(0.77,0.02); UiText(value);
			UiPop();
			UiPush();	SetPos(0.585,0.06);	UiText("GREEN");
			UiPop();
			UiPush();	SetPos(0.64,0.06); local value = optionsSlider("savegame.mod.progdest.dust_Col1_G", 1, -100, 100);
			UiPop();
			UiPush();	SetPos(0.77,0.06); UiText(value);
			UiPop();
			UiPush();	SetPos(0.585,0.10);	UiText("BLUE");
			UiPop();
			UiPush();	SetPos(0.64,0.10); local value = optionsSlider("savegame.mod.progdest.dust_Col1_B", 1, -100, 100);
			UiPop();
			UiPush();	SetPos(0.77,0.10); UiText(value);					
			UiPop();
			UiPush();	SetPos(0.87,0.06); 
				UiColor(GetInt("savegame.mod.progdest.dust_Col1_R")/100,GetInt("savegame.mod.progdest.dust_Col1_G")/100,GetInt("savegame.mod.progdest.dust_Col1_B")/100);
				UiRect(32,32)
			UiPop();
		end	
		if GetInt("savegame.mod.progdest.dust_ColMode") > 1 and GetInt("savegame.mod.progdest.dust_ColMode") < 4 then -- If it's 2 or 3, draw color selector 2
		
			UiPush();	SetPos(0.63,0.15);	UiText("Colour 2:");
			UiPop();
			
			UiPush();	SetPos(0.585,0.20);	UiText("RED");
			UiPop();
			UiPush();	SetPos(0.64,0.20); local value = optionsSlider("savegame.mod.progdest.dust_Col2_R", 1, -100, 100);
			UiPop();
			UiPush();	SetPos(0.77,0.20); UiText(value);
			UiPop();
			UiPush();	SetPos(0.585,0.24);	UiText("GREEN");
			UiPop();
			UiPush();	SetPos(0.64,0.24); local value = optionsSlider("savegame.mod.progdest.dust_Col2_G", 1, -100, 100);
			UiPop();
			UiPush();	SetPos(0.77,0.24); UiText(value);
			UiPop();
			UiPush();	SetPos(0.585,0.28);	UiText("BLUE");
			UiPop();
			UiPush();	SetPos(0.64,0.28); local value = optionsSlider("savegame.mod.progdest.dust_Col2_B", 1, -100, 100);
			UiPop();
			UiPush();	SetPos(0.77,0.28); UiText(value);					
			UiPop();
			UiPush();	SetPos(0.87,0.24); 
				UiColor(GetInt("savegame.mod.progdest.dust_Col2_R")/100,GetInt("savegame.mod.progdest.dust_Col2_G")/100,GetInt("savegame.mod.progdest.dust_Col2_B")/100);
				UiRect(32,32)
			UiPop();
		end		
		if GetInt("savegame.mod.progdest.dust_ColMode") == 3  then -- If it's 2 or 3, draw color selector 2
		
			UiPush();	SetPos(0.63,0.33);	UiText("Colour 2:");
			UiPop();
			
			UiPush();	SetPos(0.585,0.38);	UiText("RED");
			UiPop();
			UiPush();	SetPos(0.64,0.38); local value = optionsSlider("savegame.mod.progdest.dust_Col3_R", 1, -100, 100);
			UiPop();
			UiPush();	SetPos(0.77,0.38); UiText(value);
			UiPop();
			UiPush();	SetPos(0.585,0.42);	UiText("GREEN");
			UiPop();
			UiPush();	SetPos(0.64,0.42); local value = optionsSlider("savegame.mod.progdest.dust_Col3_G", 1, -100, 100);
			UiPop();
			UiPush();	SetPos(0.77,0.42); UiText(value);
			UiPop();
			UiPush();	SetPos(0.585,0.46);	UiText("BLUE");
			UiPop();
			UiPush();	SetPos(0.64,0.46); local value = optionsSlider("savegame.mod.progdest.dust_Col3_B", 1, -100, 100);
			UiPop();
			UiPush();	SetPos(0.77,0.46); UiText(value);					
			UiPop();
			UiPush();	SetPos(0.87,0.42); 
				UiColor(GetInt("savegame.mod.progdest.dust_Col3_R")/100,GetInt("savegame.mod.progdest.dust_Col3_G")/100,GetInt("savegame.mod.progdest.dust_Col3_B")/100);
				UiRect(32,32)
			UiPop();
		end			
	end	
end

function DrawPage3()

	-- Draw content (sliders and buttons).
	UiFont("regular.ttf", 38);
	UiPush();	SetPos(-0.5,-0.55); 	UiText("CRUMBLE SETTINGS:");
	UiPop();
	UiPush();	SetPos(0.5,-0.55); 	UiText("RUMBLE (explosion) SETTINGS:");
	UiPop();	
	UiColor(0.65,0.65,1);
	UiPush();	SetPos(0,0.1); UiRect(2,600);
	UiPop();
	UiPush();	SetPos(0,-0.50); UiRect(3000,3);
	UiPop();	
	UiPush();	SetPos(0,0.70); UiRect(3000,3);
	UiPop();	
	UiColor(1,1,1);	

	UiFont("bold.ttf", 20);
	UiButtonImageBox("ui/common/box-outline-6.png", 6, 6);
	UiPush();	SetPos(-0.7,-0.45); 	drawButton("Enable Crumbling?", "savegame.mod.progdest.Tog_CRUMBLE");
	UiPop();	
	if GetBool("savegame.mod.progdest.Tog_CRUMBLE") then
		UiFont("bold.ttf", 20)	
		UiPush();	SetPos(-0.8,-0.35);	UiText("Crumble damage to LIGHT materials:");
		UiPop();
		UiPush();	SetPos(-0.61,-0.35); local value = optionsSlider("savegame.mod.progdest.crum_DMGLight", 10, 0, 200,5);
		UiPop();
		UiPush();	SetPos(-0.46,-0.35); UiText(value);
		UiPop();
		UiPush();	SetPos(-0.8,-0.30);	UiText("Crumble damage to MEDIUM materials:");
		UiPop();
		UiPush();	SetPos(-0.61,-0.30); local value = optionsSlider("savegame.mod.progdest.crum_DMGMed", 10, 0, 200,5);
		UiPop();
		UiPush();	SetPos(-0.46,-0.30); UiText(value);
		UiPop();	
		UiPush();	SetPos(-0.8,-0.25);	UiText("Crumble damage to HEAVY materials:");
		UiPop();
		UiPush();	SetPos(-0.61,-0.25); local value = optionsSlider("savegame.mod.progdest.crum_DMGHeavy", 10, 0, 200,5);
		UiPop();
		UiPush();	SetPos(-0.46,-0.25); UiText(value);
		UiPop();			
		UiPush();	SetPos(-0.30,-0.25); UiText("Interval Randomness:");
		UiPop();
		UiPush();	SetPos(-0.20,-0.25); local value = optionsSlider("savegame.mod.progdest.crum_spdRND", 1, 0,20);
		UiPop();
		UiPush();	SetPos(-0.07,-0.25); UiText(value);
		UiPop();
		UiPush();	SetPos(-0.30,-0.15); UiText("Crumble SIZE:");
		UiPop();
		UiPush();	SetPos(-0.20,-0.15); local value = optionsSlider("savegame.mod.progdest.crum_dist", 1, 1,10);
		UiPop();
		UiPush();	SetPos(-0.07,-0.15); UiText(value);
		UiPop();
		UiPush();	SetPos(-0.7,0.00); 	drawButton("Vehicles Crumble?", "savegame.mod.progdest.vehicles_crumble");
		UiPop();		
		UiPush();	SetPos(-0.8,0.10);	UiText("HOLE CONTROL:");
		UiPop();
		UiPush();	SetPos(-0.66,0.10); local value = optionsSlider("savegame.mod.progdest.crum_HoleControl", 10, 0, 10);
		UiPop();
		UiPush();	SetPos(-0.52,0.10); UiText(value);
		UiPop();
		UiPush();	SetPos(-0.40,0.10);	UiText("BREAKTIME:");
		UiPop();
		UiPush();	SetPos(-0.31,0.10); local value = optionsSlider("savegame.mod.progdest.crum_BreakTime", 2.5, 5, 40);
		UiPop();
		UiPush();	SetPos(-0.17,0.10); UiText(value/2);
		UiPop();
		UiPush();	SetPos(-0.10,0.10); UiText("Seconds");
		UiPop();
		
		UiPush();	SetPos(-0.8,0.20);	UiText("Max Distance From Player:");
		UiPop();
		UiPush();	SetPos(-0.66,0.20); local value = optionsSlider("savegame.mod.progdest.crum_distFromPlyr", 2.5, 5, 60);
		UiPop();
		UiPush();	SetPos(-0.52,0.20); UiText(value);
		UiPop();
		-- Mass / Speed Limits
		UiPush();	SetPos(-0.8,0.35);	UiText("Minimum Mass:");
		UiPop();
		UiPush();	SetPos(-0.66,0.35); local value = optionsSlider("savegame.mod.progdest.crum_MinMass", 1, 0, 80,1);
		UiPop();
		UiPush();	SetPos(-0.52,0.35); UiText(value/4);
		UiPop();		
		UiPush();	SetPos(-0.40,0.35);	UiText("Maximum Mass:");
		UiPop();
		UiPush();	SetPos(-0.31,0.35); local value = optionsSlider("savegame.mod.progdest.crum_MaxMass", 1, 20, 80000);
		UiPop();
		UiPush();	SetPos(-0.17,0.35); UiText(value);
		UiPop();
		UiPush();	SetPos(-0.8,0.45);	UiText("Minimum Speed:");
		UiPop();
		UiPush();	SetPos(-0.66,0.45); local value = optionsSlider("savegame.mod.progdest.crum_MinSpd", 1, 0, 150,2);
		UiPop();
		UiPush();	SetPos(-0.52,0.45); UiText(value/10);
		UiPop();		
		UiPush();	SetPos(-0.40,0.45);	UiText("Maximum Speed:");
		UiPop();
		UiPush();	SetPos(-0.31,0.45); local value = optionsSlider("savegame.mod.progdest.crum_MaxSpd", 1, 1, 100);
		UiPop();
		UiPush();	SetPos(-0.17,0.45); UiText(value);
		UiPop();	
		
		-- TOOL TIghtS
		UiColor(0.15,0.65,1);
--		UiColor(0,0,0);
		UiPush();	SetPos(-0.70,-0.21);	UiText("NOTE - TearDown internal code limits MEDIUM and HEAVY damage");
		UiPop();
		UiPush();	SetPos(-0.70,-0.18);	UiText("to a MAXIMUM of whatever LIGHT damage is. So MED and HEAVY");
		UiPop();
		UiPush();	SetPos(-0.70,-0.15);	UiText("damage of 200 when light is 0 would do nothing. Likewise");
		UiPop();
		UiPush();	SetPos(-0.70,-0.12);	UiText("is limited to either LIGHT or MEDIUM (whichever highest)");
		UiPop();	
		UiPush();	SetPos(-0.21,-0.21);	UiText("alters the regular crumble delay to make things");
		UiPop();
		UiPush();	SetPos(-0.21,-0.18);	UiText("less predictable.");
		UiPop(); 
		UiPush();	SetPos(-0.21,-0.11);	UiText("I advise keeping small if using high FREQUENCY");
		UiPop(); 
		UiPush();	SetPos(-0.26,-0.01);	UiText("<< Use this to make vehicles crumble when you get in them or");
		UiPop(); 
		UiPush();	SetPos(-0.26,0.02);	UiText("touch them. Vehicles can always get caught in nearby crumble.");
		UiPop(); 
		UiPush();	SetPos(-0.70,0.13);	UiText("This will BREAK the crumbling if too many holes are");
		UiPop();
		UiPush();	SetPos(-0.70,0.16);	UiText("made. 10 = more likely to BREAK.");
		UiPop();
		UiPush();	SetPos(-0.21,0.13);	UiText("This is linked to HOLE CONTROL in some way. Hard");
		UiPop();	
		UiPush();	SetPos(-0.21,0.16);	UiText("to explain, but maybe you can figure it out? :D");
		UiPop();
		UiPush();	SetPos(-0.48,0.24);	UiText("MAX DISTANCE can stop the crumble chain-reactions from `wandering off` and eating up the level far away");
		UiPop();		
		UiPush();	SetPos(-0.48,0.27);	UiText("from the player. Which is boring, and means the player constantly chasing the chain reaction.");
		UiPop();		
		UiPush();	SetPos(-0.48,0.38);	UiText("Note that a high MAX MASS limit can make large chunks of stuff (like a building thats disconnected)");
		UiPop();	
		UiPush();	SetPos(-0.48,0.41);	UiText("suddenly crumble totally into a jigsaw puzzle. Cool, but might crash your PC.");
		UiPop();
		UiPush();	SetPos(-0.48,0.49);	UiText("The MASS and SPEED sliders set limits on when something may crumble.");
		UiPop();			
		-- Crumble mode
		UiFont("bold.ttf", 20)	
		-- the sick multi-click multi-mode selectatron
		UiColor(1,1-math.random(),1)
		UiPush();	SetPos(-0.8,0.64);	
		if UiTextButton("Source of Crumble", 160, 40) then
			SetInt("savegame.mod.progdest.tog_crum_Source",GetInt("savegame.mod.progdest.tog_crum_Source")+1);
		end	
		UiPop();
		if GetInt("savegame.mod.progdest.tog_crum_Source")>1 then	
			SetInt("savegame.mod.progdest.tog_crum_Source", 0);
		end
		-- Single Color mode
		UiColor(1,1,1)
		if GetInt("savegame.mod.progdest.tog_crum_Source")==0 then
		
			UiPush();	SetPos(-0.65,0.64);	UiText("Debris Only");
			UiPop();

		end		
		if GetInt("savegame.mod.progdest.tog_crum_Source")==1 then
		
			UiPush();	SetPos(-0.5,0.64);	UiText("All Physics (except Vehicls, click above for that");
			UiPop();

		end		
	end
		UiColor(1,1-(math.random()*0.8),1)
		UiPush();	SetPos(-0.30,-0.35);	
		if GetBool("savegame.mod.progdest.Tog_CRUMBLE") then
			UiText("Crumble Frequency:");
			else
			UiText("METHOD Frequency:");
		end
		UiPop();
		UiColor(0.15,0.65,1);
		UiPush();	SetPos(-0.21,-0.32);	UiText("High frequency mean less time between effects.");
		UiPop();		
		UiPush();	SetPos(-0.21,-0.28);	UiText("(and thus, puts more strain on your PC)");
		UiPop();
		UiColor(1,1,1)
		UiPush();	SetPos(-0.20,-0.35); local value = optionsSlider("savegame.mod.progdest.crum_spd", 1, -20,22);
		UiPop();
		UiPush();	SetPos(-0.07,-0.35); UiText(value);
		UiPop();
	
		-- Crumble mode
		UiFont("bold.ttf", 20)	
		-- the sick multi-click multi-mode selectatron
		UiColor(1,1-math.random(),1)
		UiPush();	SetPos(-0.7,0.55);	
		if UiTextButton("CRUMBLE/DUST/EXPLOSION/FIRE METHOD", 360, 40) then
			SetInt("savegame.mod.progdest.tog_crum_MODE",GetInt("savegame.mod.progdest.tog_crum_MODE")+1);
		end	
		UiPop();
		if GetInt("savegame.mod.progdest.tog_crum_MODE")>1 then	
			SetInt("savegame.mod.progdest.tog_crum_MODE", 0);
		end
		-- Single Color mode
		UiColor(1,1,1)
		if GetInt("savegame.mod.progdest.tog_crum_MODE")==0 then
		
			UiPush();	SetPos(-0.4,0.55);	UiText("Grouped");
			UiPop();

		end		
		if GetInt("savegame.mod.progdest.tog_crum_MODE")==1 then
		
			UiPush();	SetPos(-0.4,0.55);	UiText("Fully Random");
			UiPop();

		end
	
	UiFont("regular.ttf", 24);
	UiColor(1,0.5,0.5);
	UiPush();	SetPos(0,0.8); 	UiText("NOTE that a very high 'FREQUENCY' regardless of whether crumbling itself is on or off, will likely cause FPS drop (depending on the level)");
	UiPop();
	
	UiFont("bold.ttf", 20);
	UiColor(1,1,1);
	UiButtonImageBox("ui/common/box-outline-6.png", 6, 6);
	UiPush();	SetPos(0.25,-0.45); 	drawButton("Enable Explosions?", "savegame.mod.progdest.Tog_RUMBLE");
	UiPop();
	
	if GetBool("savegame.mod.progdest.Tog_RUMBLE") then
		UiFont("bold.ttf", 20)	
		UiPush();	SetPos(0.15,-0.35);	UiText("Explosion Base Size:");
		UiPop();
		UiPush();	SetPos(0.25,-0.35); local value = optionsSlider("savegame.mod.progdest.xplo_szBase", 0, 1, 40);
		UiPop();
		UiPush();	SetPos(0.40,-0.35); UiText(value/4);
		UiPop();
		UiPush();	SetPos(0.52,-0.35);	UiText("Random sizing");
		UiPop();
		UiPush();	SetPos(0.62,-0.35); local value = optionsSlider("savegame.mod.progdest.xplo_szRND", 0, 1, 20);
		UiPop();
		UiPush();	SetPos(0.76,-0.35); UiText(value/5);
		UiPop();		
		UiPush();	SetPos(0.15,-0.25);	UiText("Explosion Chance:");
		UiPop();
		UiPush();	SetPos(0.25,-0.25); local value = optionsSlider("savegame.mod.progdest.xplo_chance", 0, 1, 100,1);
		UiPop();
		UiPush();	SetPos(0.40,-0.25); UiText(value);
		UiPop();	
		UiPush();	SetPos(0.52,-0.25);	UiText("Max dist from player:");
		UiPop();
		UiPush();	SetPos(0.62,-0.25); local value = optionsSlider("savegame.mod.progdest.xplo_distFromPlyr", 0, 1, 50);
		UiPop();
		UiPush();	SetPos(0.76,-0.25); UiText(value);
		UiPop();	
		UiPush();	SetPos(0.15,-0.15);	UiText("Explode Control:");
		UiPop();
		UiPush();	SetPos(0.25,-0.15); local value = optionsSlider("savegame.mod.progdest.xplo_HoleControl", 10, 0, 10);
		UiPop();
		UiPush();	SetPos(0.40,-0.15); UiText(value);
		UiPop();
		UiPush();	SetPos(0.15,-0.05);	UiText("BREAKTIME:");
		UiPop();
		UiPush();	SetPos(0.25,-0.05); local value = optionsSlider("savegame.mod.progdest.xplo_BreakTime", 2.5, 5, 40);
		UiPop();
		UiPush();	SetPos(0.38,-0.05); UiText(value/2);
		UiPop();
		UiPush();	SetPos(0.435,-0.05); UiText("Seconds");
		UiPop();
		
		-- Mass / Speed Limits
		UiPush();	SetPos(0.15,0.05);	UiText("Minimum Mass:");
		UiPop();
		UiPush();	SetPos(0.25,0.05); local value = optionsSlider("savegame.mod.progdest.xplo_MinMass", 1, 0, 500, 5 );
		UiPop();
		UiPush();	SetPos(0.40,0.05); UiText(value);
		UiPop();		
		UiPush();	SetPos(0.15,0.10);	UiText("Maximum Mass:");
		UiPop();
		UiPush();	SetPos(0.25,0.10); local value = optionsSlider("savegame.mod.progdest.xplo_MaxMass", 1, 20, 8000);
		UiPop();
		UiPush();	SetPos(0.40,0.10); UiText(value);
		UiPop();
		UiPush();	SetPos(0.15,0.20);	UiText("Minimum Speed:");
		UiPop();
		UiPush();	SetPos(0.25,0.20); local value = optionsSlider("savegame.mod.progdest.xplo_MinSpd", 1, 0, 200,2);
		UiPop();
		UiPush();	SetPos(0.40,0.20); UiText(value/10);
		UiPop();		
		UiPush();	SetPos(0.15,0.25);	UiText("Maximum Speed:");
		UiPop();
		UiPush();	SetPos(0.25,0.25); local value = optionsSlider("savegame.mod.progdest.xplo_MaxSpd", 1, 1, 100);
		UiPop();
		UiPush();	SetPos(0.40,0.25); UiText(value);		
		UiPop();
		UiPush();	SetPos(0.2,0.65); 	drawButton("Outline Explosives", "savegame.mod.progdest.Tog_XPLO_outline");
		UiPop();
		-- Helpful Guides
		UiColor(0.15,0.65,1);			
		UiPush();	SetPos(0.44,-0.31); UiText("Base size is the lowest explosion size. Random sizing adds variation on top of this.");
		UiPop();		
		UiPush();	SetPos(0.41,-0.21); UiText("CHANCE sets the probability, that during the FREQUENCY (crumble section) a explosion occurs.");
		UiPop();
		UiPush();	SetPos(0.24,-0.11); UiText("sets chance of breaks between rapid explosions");
		UiPop();		
		UiPush();	SetPos(0.24,-0.01); UiText("sets the length of those breaks");
		UiPop();	
		UiPush();	SetPos(0.24,0.14); UiText("Set weight limits for what will explode.");
		UiPop();
		UiPush();	SetPos(0.24,0.28); UiText("Set speed limits for what explodes.");
		UiPop();		
		UiFont("bold.ttf", 20)	
		-- the sick multi-click multi-mode selectatron
		UiColor(1,1-math.random(),1)
		UiPush();	SetPos(0.52, 0.65);	
		if UiTextButton("What explodes:", 128, 40) then
			SetInt("savegame.mod.progdest.xplo_mode",GetInt("savegame.mod.progdest.xplo_mode")+1);
		end	
		UiPop();
		if GetInt("savegame.mod.progdest.xplo_mode")>3 then	
			SetInt("savegame.mod.progdest.xplo_mode", 1);
		end
		-- Single Color mode
		UiColor(1,1,1)
		if GetInt("savegame.mod.progdest.xplo_mode")==1 then
		
			UiPush();	SetPos(0.66, 0.65);	UiText("Debris Only (Best)");
			UiPop();

		end		
		if GetInt("savegame.mod.progdest.xplo_mode")==2 then
		
			UiPush();	SetPos(0.79, 0.65);	UiText("All dynamic objects (utter chaos and low FPS)");
			UiPop();

		end			
		if GetInt("savegame.mod.progdest.xplo_mode")==3 then
		
			UiPush();	SetPos(0.77, 0.65);	UiText("Vehicles Only (funny for about 2 minutes)");
			UiPop();

		end			
	end
		UiColor(1,1,0);
		UiPush();	SetPos(0.67,-0.47);	UiText("These settings control ALL explosions in the game.");
		UiPop();
		UiPush();	SetPos(0.67,-0.44);	UiText("Yes, even from the RPG and explosive props!");
		UiPop();
		UiPush();	SetPos(0.44,-0.40);	UiText("(but note that `ENABLING` controls only debris chunks exploding)");
		UiPop();	
		if GetBool("savegame.mod.progdest.Tog_RUMBLE")==false then
			UiPush();	SetPos(0.24,-0.10);	UiText("These remaining settings are visible as they");
			UiPop();	
			UiPush();	SetPos(0.24,-0.05);	UiText("also affect any normal (RPG,Pipebomb,etc)");
			UiPop();	
			UiPush();	SetPos(0.24,0.0);	UiText("explosions in the game. Have fun! :)");
			UiPop();	
			UiPush();	SetPos(0.24,0.10);	UiText("HOWEVER due to game's default code being");
			UiPop();
			UiPush();	SetPos(0.24,0.15);	UiText("loaded AFTER mod code (ON THE VANILLA MAPS),");
			UiPop();
			UiPush();	SetPos(0.24,0.20);	UiText("the game overrides these settings with default explosions");
			UiPop();

		end
		UiColor(1,1,1);
		UiPush();	SetPos(0.22,0.35);	UiText("Per-explosion smoke amount scaler:");
		UiPop();
		UiPush();	SetPos(0.15,0.38); local value = optionsSlider("savegame.mod.progdest.xplo_SmokeAMT", 1, 1, 12);
		UiPop();
		UiPush();	SetPos(0.30,0.38); UiText(value/4);		
		UiPop();
		UiPush();	SetPos(0.22,0.42);	UiText("Per-explosion smoke life scaler:");
		UiPop();
		UiPush();	SetPos(0.15,0.46); local value = optionsSlider("savegame.mod.progdest.xplo_LifeAMT", 1, 1, 24);
		UiPop();
		UiPush();	SetPos(0.30,0.46); UiText(value/4);		
		UiPop();	
		UiPush();	SetPos(0.22,0.50);	UiText("Per-explosion pressure:");
		UiPop();
		UiPush();	SetPos(0.15,0.53); local value = optionsSlider("savegame.mod.progdest.xplo_Pressure", 4, 1, 30);
		UiPop();
		UiPush();	SetPos(0.30,0.53); UiText(value/4);		
		UiPop();
		-- Helpful Guides
		UiColor(0.15,0.65,1);			
		UiPush();	SetPos(0.24,0.56); UiText("These scalers control the amount, speed and lifetime");
		UiPop();
		UiPush();	SetPos(0.24,0.59); UiText("Of ALL explosion smoke in the game.");
		UiPop();		

		-- the sick multi-click multi-mode selectatron
		-- the sick multi-click multi-mode selectatron
		UiColor(1,1-math.random(),1)
		UiPush();	SetPos(0.585,-0.10);	
		if UiTextButton("COLOR MODE", 128, 40) then
			SetInt("savegame.mod.progdest.xplo_ColMode",GetInt("savegame.mod.progdest.xplo_ColMode")+1);
		end	
		UiPop();
		if GetInt("savegame.mod.progdest.xplo_ColMode")>7 then	
			SetInt("savegame.mod.progdest.xplo_ColMode", 1);
		end
		-- Single Color mode
		UiColor(1,1,1)
		if GetInt("savegame.mod.progdest.xplo_ColMode")==1 then
		
			UiPush();	SetPos(0.75,-0.10);	UiText("Game Default Settings");
			UiPop();

		end		
		if GetInt("savegame.mod.progdest.xplo_ColMode")==2 then
		
			UiPush();	SetPos(0.75,-0.10);	UiText("Single Color Mode");
			UiPop();

		end
		if GetInt("savegame.mod.progdest.xplo_ColMode")==3 then
		
			UiPush();	SetPos(0.75,-0.10);	UiText("Dual Color Mode");
			UiPop();

		end	
		if GetInt("savegame.mod.progdest.xplo_ColMode")==4 then
		
			UiPush();	SetPos(0.75,-0.10);	UiText("Three Color Mode");
			UiPop();

		end		
		if GetInt("savegame.mod.progdest.xplo_ColMode")==5 then
		
			UiPush();	SetPos(0.75,-0.10);	UiText("Randomized Rainbow");
			UiPop();

		end	
		if GetInt("savegame.mod.progdest.xplo_ColMode")==6 then
		
			UiPush();	SetPos(0.75,-0.10);	UiText("Shifting Rainbow");
			UiPop();

		end		
		if GetInt("savegame.mod.progdest.xplo_ColMode")==7 then
		
			UiPush();	SetPos(0.75,-0.10);	UiText("GreyScale");
			UiPop();

		end		
		if GetInt("savegame.mod.progdest.xplo_ColMode") < 5 and GetInt("savegame.mod.progdest.xplo_ColMode") > 1 then -- If it's 1,2 or 3, draw color selector 1
		
			UiPush();	SetPos(0.73,-0.03);	UiText("Colour 1: (This is always the flash color)");
			UiPop();
			
			UiPush();	SetPos(0.585,0.02);	UiText("RED");
			UiPop();
			UiPush();	SetPos(0.64,0.02); local value = optionsSlider("savegame.mod.progdest.xplo_Col1_R", 1, 0, 100);
			UiPop();
			UiPush();	SetPos(0.77,0.02); UiText(value);
			UiPop();
			UiPush();	SetPos(0.585,0.06);	UiText("GREEN");
			UiPop();
			UiPush();	SetPos(0.64,0.06); local value = optionsSlider("savegame.mod.progdest.xplo_Col1_G", 1, 0, 100);
			UiPop();
			UiPush();	SetPos(0.77,0.06); UiText(value);
			UiPop();
			UiPush();	SetPos(0.585,0.10);	UiText("BLUE");
			UiPop();
			UiPush();	SetPos(0.64,0.10); local value = optionsSlider("savegame.mod.progdest.xplo_Col1_B", 1, 0, 100);
			UiPop();
			UiPush();	SetPos(0.77,0.10); UiText(value);					
			UiPop();
			UiPush();	SetPos(0.87,0.06); 
				UiColor(GetInt("savegame.mod.progdest.xplo_Col1_R")/100,GetInt("savegame.mod.progdest.xplo_Col1_G")/100,GetInt("savegame.mod.progdest.xplo_Col1_B")/100);
				UiRect(32,32)
			UiPop();
		end	
		if GetInt("savegame.mod.progdest.xplo_ColMode") > 2 and GetInt("savegame.mod.progdest.xplo_ColMode") < 5 then -- If it's 2 or 3, draw color selector 2
		
			UiPush();	SetPos(0.63,0.15);	UiText("Colour 2:");
			UiPop();
			
			UiPush();	SetPos(0.585,0.20);	UiText("RED");
			UiPop();
			UiPush();	SetPos(0.64,0.20); local value = optionsSlider("savegame.mod.progdest.xplo_Col2_R", 1, 0, 100);
			UiPop();
			UiPush();	SetPos(0.77,0.20); UiText(value);
			UiPop();
			UiPush();	SetPos(0.585,0.24);	UiText("GREEN");
			UiPop();
			UiPush();	SetPos(0.64,0.24); local value = optionsSlider("savegame.mod.progdest.xplo_Col2_G", 1, 0, 100);
			UiPop();
			UiPush();	SetPos(0.77,0.24); UiText(value);
			UiPop();
			UiPush();	SetPos(0.585,0.28);	UiText("BLUE");
			UiPop();
			UiPush();	SetPos(0.64,0.28); local value = optionsSlider("savegame.mod.progdest.xplo_Col2_B", 1, 0, 100);
			UiPop();
			UiPush();	SetPos(0.77,0.28); UiText(value);					
			UiPop();
			UiPush();	SetPos(0.87,0.24); 
				UiColor(GetInt("savegame.mod.progdest.xplo_Col2_R")/100,GetInt("savegame.mod.progdest.xplo_Col2_G")/100,GetInt("savegame.mod.progdest.xplo_Col2_B")/100);
				UiRect(32,32)
			UiPop();
		end		
		if GetInt("savegame.mod.progdest.xplo_ColMode") == 4  then -- If it's 2 or 3, draw color selector 2
		
			UiPush();	SetPos(0.63,0.33);	UiText("Colour 3:");
			UiPop();		
			UiPush();	SetPos(0.585,0.38);	UiText("RED");
			UiPop();
			UiPush();	SetPos(0.64,0.38); local value = optionsSlider("savegame.mod.progdest.xplo_Col3_R", 1, 0, 100);
			UiPop();
			UiPush();	SetPos(0.77,0.38); UiText(value);
			UiPop();
			UiPush();	SetPos(0.585,0.42);	UiText("GREEN");
			UiPop();
			UiPush();	SetPos(0.64,0.42); local value = optionsSlider("savegame.mod.progdest.xplo_Col3_G", 1, 0, 100);
			UiPop();
			UiPush();	SetPos(0.77,0.42); UiText(value);
			UiPop();
			UiPush();	SetPos(0.585,0.46);	UiText("BLUE");
			UiPop();
			UiPush();	SetPos(0.64,0.46); local value = optionsSlider("savegame.mod.progdest.xplo_Col3_B", 1, 0, 100);
			UiPop();
			UiPush();	SetPos(0.77,0.46); UiText(value);					
			UiPop();
			UiPush();	SetPos(0.87,0.42); 
			UiColor(GetInt("savegame.mod.progdest.xplo_Col3_R")/100,GetInt("savegame.mod.progdest.xplo_Col3_G")/100,GetInt("savegame.mod.progdest.xplo_Col3_B")/100);
			UiRect(32,32)
			UiPop();
			
			UiColor(0.15,0.65,1);			
			UiPush();	SetPos(0.74,0.55); UiText("Note that COLOR 3, when used for explosion SMOKE,");
			UiPop();
			UiPush();	SetPos(0.74,0.58); UiText("Lasts 20% more time than the other smoke.");
			UiPop();
		end	
		
end

function DrawPage4()
	-- Draw content (sliders and buttons).
	UiFont("regular.ttf", 38);
	UiPush();	SetPos(-0.5,-0.55); 	UiText("FORCE/WIND SETTINGS:");
	UiPop();
	UiPush();	SetPos(0.5,-0.55); 	UiText("MISC SETTINGS:");
	UiPop();	
	UiColor(0.65,0.65,1);
	UiPush();	SetPos(0,0.1); UiRect(2,600);
	UiPop();
	UiPush();	SetPos(0,-0.50); UiRect(3000,3);
	UiPop();	
	UiPush();	SetPos(0,0.70); UiRect(3000,3);
	UiPop();	
	UiColor(1,1,1);	
	
	UiFont("bold.ttf", 20);
	UiButtonImageBox("ui/common/box-outline-6.png", 6, 6);
	UiPush();	SetPos(-0.7,-0.45); 	drawButton("Enable force?", "savegame.mod.progdest.Tog_FORCE");
	UiPop();
	UiPush();
	UiFont("bold.ttf", 20);
	UiColor(1,1,1);
	UiButtonImageBox("ui/common/box-outline-6.png", 6, 6);
	UiPush();	SetPos(0.25,-0.45); 	drawButton("Enable Crazy Fire?", "savegame.mod.progdest.Tog_FIRE");
	UiPop();
	UiColor(1,1,1);
	UiButtonImageBox("ui/common/box-outline-6.png", 6, 6);
	UiPush();	SetPos(0.25,-0.15); 	drawButton("Physics Violence?", "savegame.mod.progdest.Tog_VIOL");
	UiPop();	
	UiColor(1,1,1);
	UiButtonImageBox("ui/common/box-outline-6.png", 6, 6);
	UiPush();	SetPos(0.25,0.25); 	drawButton("Damage cost Statistics", "savegame.mod.progdest.Tog_DAMSTAT");
	UiPop();
	UiColor(1,1,1);
	UiButtonImageBox("ui/common/box-outline-6.png", 6, 6);
	UiPush();	SetPos(0.25,0.40); 	drawButton("Joint Breakage", "savegame.mod.progdest.Tog_JOINTS");
	UiPop();	
	-- FORCE SELECTION SYSTEM	
	if GetBool("savegame.mod.progdest.Tog_FORCE") then
		UiColor(1,1-math.random(),1)
		UiPush();	SetPos(-0.80,-0.35);	
		if UiTextButton("Force Type>>", 128, 40) then
			SetInt("savegame.mod.progdest.4ce_method",GetInt("savegame.mod.progdest.4ce_method")+1);
		end	
		UiPop();
		if GetInt("savegame.mod.progdest.4ce_method")>9 then	
			SetInt("savegame.mod.progdest.4ce_method", 1);
		end
		-- Single Color mode
		UiColor(1,1,1)
		if GetInt("savegame.mod.progdest.4ce_method")==1 then
		
			UiPush();	SetPos(-0.50,-0.35);	UiText("Random Jitters");
			UiPop();	
			UiFont("bold.ttf", 18);
			
			UiColor(0.15,0.65,1);
			UiPush();	SetPos(-0.40,-0.31);	UiText("Physics objects + debris will be constantly fed randomized impulses to move, or rotate.");
			UiPop();
			UiPush();	SetPos(-0.40,-0.28);	UiText("Note that if rotating the object makes it hit something, it will then move anyway!");
			UiPop();			
			UiFont("bold.ttf", 20);
			UiColor(1,1,1);

		end
		if GetInt("savegame.mod.progdest.4ce_method")==2 then
			UiPush();	SetPos(-0.50,-0.35);	UiText("Push from / Pull towards player");
			UiPop();
			UiPush();	SetPos(-0.60,-0.15);	UiText("Pull to");
			UiPop();
			UiPush();	SetPos(-0.20,-0.15);	UiText("push from");
			UiPop();		

			UiColor(0.15,0.65,1);
			UiPush();	SetPos(-0.40,-0.31);	UiText("Pretty self explanitary really? (it's basically like leafblower mod)");
			UiPop();		
			UiFont("bold.ttf", 20);
			UiColor(1,1,1);

		end	
		if GetInt("savegame.mod.progdest.4ce_method")==3 then
		
			UiPush();	SetPos(-0.50,-0.35);	UiText("Horizontal rotating around CW/ACW");
			UiPop();
			UiPush();	SetPos(-0.60,-0.15);	UiText("Anti-Clockwise");
			UiPop();
			UiPush();	SetPos(-0.20,-0.15);	UiText("Clockwise");
			UiPop();	

			UiColor(0.15,0.65,1);
			UiPush();	SetPos(-0.40,-0.31);	UiText("It's like a wind, or hurricane, but the direction keeps shifting slightly");
			UiPop();		
			UiFont("bold.ttf", 20);
			UiColor(1,1,1);

		end		
		if GetInt("savegame.mod.progdest.4ce_method")==4 then
		
			UiPush();	SetPos(-0.50,-0.35);	UiText("Vertical rotation CW/ACW");
			UiPop();
			UiPush();	SetPos(-0.60,-0.15);	UiText("Anti-Clockwise");
			UiPop();
			UiPush();	SetPos(-0.20,-0.15);	UiText("Clockwise");
			UiPop();

			UiColor(0.15,0.65,1);
			UiPush();	SetPos(-0.40,-0.31);	UiText("Physics objects behave like gravity is rotating around and up the cieling.");
			UiPop();		
			UiFont("bold.ttf", 20);
			UiColor(1,1,1);
			
		end			
		if GetInt("savegame.mod.progdest.4ce_method")==5 then
		
			UiPush();	SetPos(-0.50,-0.35);	UiText("Bi-directional rocking. East/West");
			UiPop();
			
			UiColor(0.15,0.65,1);
			UiPush();	SetPos(-0.40,-0.31);	UiText("A wind keeps oscillating between two opposing directions");		
			UiPop();		
			UiPush();	SetPos(-0.40,-0.28);	UiText("(gives the effect of rocking like on a ship)");		
			UiPop();		

			UiFont("bold.ttf", 20);
			UiColor(1,1,1);


		end			
			if GetInt("savegame.mod.progdest.4ce_method")==6 then
		
			UiPush();	SetPos(-0.50,-0.35);	UiText("Bi-directional rocking North/South");
			UiPop();	

			UiColor(0.15,0.65,1);
			UiPush();	SetPos(-0.40,-0.31);	UiText("A wind keeps oscillating between two opposing directions");		
			UiPop();		
			UiPush();	SetPos(-0.40,-0.28);	UiText("(gives the effect of rocking like on a ship)");		
			UiPop();		

			UiFont("bold.ttf", 20);
			UiColor(1,1,1);

		end	
		if GetInt("savegame.mod.progdest.4ce_method")==7 then
		
			UiPush();	SetPos(-0.50,-0.35);	UiText("Up or Down");
			UiPop();
			UiPush();	SetPos(-0.60,-0.15);	UiText("DOWN");
			UiPop();
			UiPush();	SetPos(-0.20,-0.15);	UiText("UP");
			UiPop();
			
			UiColor(0.15,0.65,1);
			UiPush();	SetPos(-0.40,-0.31);	UiText("Can be used to set super high gravity, crushing objects,");		
			UiPop();		
			UiPush();	SetPos(-0.40,-0.28);	UiText("or invert gravity, so things fly into the air");		
			UiPop();		

			UiFont("bold.ttf", 20);
			UiColor(1,1,1);
			
		end		
		if GetInt("savegame.mod.progdest.4ce_method")==8 then
		
			UiPush();	SetPos(-0.50,-0.35);	UiText("East or West");
			UiPop();
			UiPush();	SetPos(-0.60,-0.15);	UiText("East");
			UiPop();
			UiPush();	SetPos(-0.20,-0.15);	UiText("West");
			UiPop();
			
			UiColor(0.15,0.65,1);
			UiPush();	SetPos(-0.40,-0.31);	UiText("Two wind directions, which do not move.");		
			UiPop();		
			UiFont("bold.ttf", 20);
			UiColor(1,1,1);			

		end			
		if GetInt("savegame.mod.progdest.4ce_method")==9 then
		
			UiPush();	SetPos(-0.50,-0.35);	UiText("North or South.");
			UiPop();
			UiPush();	SetPos(-0.60,-0.15);	UiText("North");
			UiPop();
			UiPush();	SetPos(-0.20,-0.15);	UiText("South");
			UiPop();	

			UiColor(0.15,0.65,1);
			UiPush();	SetPos(-0.40,-0.31);	UiText("Two wind directions, which do not move.");		
			UiPop();		
			UiFont("bold.ttf", 20);
			UiColor(1,1,1);	
			
		end	
		if GetInt("savegame.mod.progdest.4ce_method")~=6 and GetInt("savegame.mod.progdest.4ce_method")~=5 and GetInt("savegame.mod.progdest.4ce_method")~=1 then
			UiPush();	SetPos(-0.06,-0.20);	
			UiText(GetInt("savegame.mod.progdest.4ce_strength")/50);
			UiPop();	
			else
				UiPush();	SetPos(-0.06,-0.20);	
				ValYue = ((121+GetInt("savegame.mod.progdest.4ce_strength"))/50)
				UiText(ValYue);
				UiPop();		
			end
		UiPush();	SetPos(-0.80,-0.20);	UiText("Force Direction/Strength:");
		UiPop();
		UiPush();	SetPos(-0.66,-0.20); local value = optionsSliderYuge("savegame.mod.progdest.4ce_strength", 17, -120, 120,2);
		UiPop();
		UiPush();	SetPos(-0.80,-0.10);	UiText("Rotational force");
		UiPop();
		UiPush();	SetPos(-0.66,-0.10); local value = optionsSliderYuge("savegame.mod.progdest.4ce_rotational", 17, 0, 120,2);
		UiPop();		
		UiPush();	SetPos(-0.06,-0.10); UiText(value/10);	
		UiPop();		
		UiPush();	SetPos(-0.78,0.05);	UiText("Direction booster:");
		UiPop();
		UiPush();	SetPos(-0.66,0.05); local value = optionsSlider("savegame.mod.progdest.4ce_boost", 1, 0, 30);
		UiPop();
		UiPush();	SetPos(-0.52,0.05); UiText(value/10);	
		UiPop();
		UiPush();	SetPos(-0.80,0.15);	UiText("Effect on player");
		UiPop();
		UiPush();	SetPos(-0.66,0.15); local value = optionsSlider("savegame.mod.progdest.4ce_effect_on_player", 1, 1, 200);
		UiPop();
		UiPush();	SetPos(-0.52,0.15); UiText(value);	
		UiPop();	
		UiPush();	SetPos(-0.48,0.15); UiText("%");	
		UiPop();		

		if GetInt("savegame.mod.progdest.4ce_method") > 1 then --no point drawing if is jitter.
		
			UiPush();	SetPos(-0.45,0.05); UiText("Time to cycle:");
			UiPop();
			UiPush();	SetPos(-0.38,0.05); local value = optionsSliderLarge("savegame.mod.progdest.4ce_cycle", 8, 1, 30);
			UiPop();
			UiPush();	SetPos(-0.12,0.05); UiText(value*3.28);			
			UiPop();
			UiPush();	SetPos(-0.05,0.05); UiText("Seconds");			
			UiPop();
		end
		UiPush();	SetPos(-0.38,0.14);	UiText("Radius From Player");
		UiPop();
		UiPush();	SetPos(-0.27,0.14); local value = optionsSlider("savegame.mod.progdest.4ce_radius", 1, 2, 60);
		UiPop();
		UiPush();	SetPos(-0.12,0.14); UiText(value);	
		UiPop();		
		UiPush();	SetPos(-0.78,0.26);	UiText("Heavy boost");
		UiPop();
		UiPush();	SetPos(-0.66,0.26); local value = optionsSlider("savegame.mod.progdest.4ce_largemass_accellerator", 1, 2, 20);
		UiPop();
		UiPush();	SetPos(-0.52,0.26); UiText(value/10);	
		UiPop();		
		UiPush();	SetPos(-0.38,0.26);	UiText("Extra Upforce");
		UiPop();
		UiPush();	SetPos(-0.27,0.26); local value = optionsSlider("savegame.mod.progdest.4ce_upforce", 1, 0, 20);
		UiPop();
		UiPush();	SetPos(-0.12,0.26); UiText(value);	
		UiPop();		
		UiPush();	SetPos(-0.78,0.37);	UiText("MINIMUM Mass");
		UiPop();
		UiPush();	SetPos(-0.66,0.37); local value = optionsSlider("savegame.mod.progdest.4ce_minmass", 0, 0, 500,5);
		UiPop();
		UiPush();	SetPos(-0.52,0.37); UiText(value);	
		UiPop();		
		UiPush();	SetPos(-0.38,0.37);	UiText("MAXIMUM MASS");
		UiPop();
		UiPush();	SetPos(-0.27,0.37); local value = optionsSlider("savegame.mod.progdest.4ce_maxmass", 1, 10, 25000, 50);
		UiPop();
		UiPush();	SetPos(-0.12,0.37); UiText(value);	
		UiPop();	

		-- tool tights
		UiFont("bold.ttf", 18);
		UiColor(0.15,0.65,1);
		UiPush();	SetPos(-0.40,-0.05);	UiText("High rotation speeds not a great idea!");
		UiPop();
		UiPush();	SetPos(-0.68,0.08);	UiText("Booster can add more speed!");
		UiPop();
		UiPush();	SetPos(-0.28,0.08);	UiText("For the rotating/oscillating forces. Is the time needed to make one full cycle.");
		UiPop();
		UiPush();	SetPos(-0.68,0.18);	UiText("Yes, wind can directly effect the player.");
		UiPop();
		UiPush();	SetPos(-0.28,0.18);	UiText("Increase the radius of things caught by the wind");
		UiPop();		
		UiPush();	SetPos(-0.28,0.21);	UiText("This will drop the framerate quickly if too big!");
		UiPop();
		UiPush();	SetPos(-0.68,0.29);	UiText("Set a boost/dampner for heavy objects!");
		UiPop();
		UiPush();	SetPos(-0.68,0.32);	UiText("`HEAVY` = anything over 50% OF MAX MASS");
		UiPop();
		UiPush();	SetPos(-0.28,0.29);	UiText("Up force can stop things hardly moving in low winds.");
		UiPop();		
		UiPush();	SetPos(-0.28,0.32);	UiText("(Due to friction with the ground)");
		UiPop();
		UiPush();	SetPos(-0.49,0.41);	UiText("MIN/MAX mass sets the mass range in which objects are blown around.");
		UiPop();
		UiPush();	SetPos(-0.4, 0.47);	UiText("<<Set this to have the effect start up after a 2 second delay");
		UiPop();		
		UiPush();	SetPos(-0.363, 0.60);	UiText("<<Allow the use of stop force (.) and pause direction (m) keys in game");
		UiPop();
		UiPush();	SetPos(-0.374, 0.65);	UiText("<<Show a reminder of the keys in a small text box, inside the game");
		UiPop();		
		UiColor(1,1,1);
		UiButtonImageBox("ui/common/box-outline-6.png", 6, 6);
		UiPush();	SetPos(-0.8, 0.47); 	drawButton("Force starts on?", "savegame.mod.progdest.4ce_START_ON");
		UiPop();
		UiPush();	SetPos(-0.8, 0.60); 	drawButton("Allow hotkeys?", "savegame.mod.progdest.4ce_ENABLE_CONTROLS");
		UiPop();		
		UiPush();	SetPos(-0.8, 0.65); 	drawButton("Hotkey help?", "savegame.mod.progdest.4ce_CONTROL_TIPS");
		UiPop();
		if GetBool("savegame.mod.progdest.4ce_START_ON") then
			UiPush();	SetPos(-0.80,0.53);	UiText("FORCE WARM-UP TIME (Seconds)");
			UiPop();
			UiPush();	SetPos(-0.66,0.53); local value = optionsSlider("savegame.mod.progdest.4ce_warmup", 1, 1, 120, 2);
			UiPop();
			UiPush();	SetPos(-0.52,0.53); UiText(value);	
			UiPop();
		end
	end
	if GetBool("savegame.mod.progdest.Tog_FIRE") then
		UiFont("bold.ttf", 20)	
		-- the sick multi-click multi-mode selectatron
		UiColor(1,1-math.random(),1)
		UiPush();	SetPos(0.585,-0.43);	
		if UiTextButton("BURN MODE", 128, 40) then
			SetInt("savegame.mod.progdest.fyr_mode",GetInt("savegame.mod.progdest.fyr_mode")+1);
		end	
		UiPop();
		if GetInt("savegame.mod.progdest.fyr_mode")>2 then	
			SetInt("savegame.mod.progdest.fyr_mode", 1);
		end
		-- Single Color mode
		UiColor(1,1,1)
		if GetInt("savegame.mod.progdest.fyr_mode")==1 then
		
			UiPush();	SetPos(0.75,-0.43);	UiText("Debris Only (Best)");
			UiPop();

		end		
		if GetInt("savegame.mod.progdest.fyr_mode")==2 then
		
			UiPush();	SetPos(0.75,-0.43);	UiText("Any Dynamic Body");
			UiPop();

		end			
		UiPush();	SetPos(0.06,-0.35);	UiText("Min Radius:");
		UiPop();
		UiPush();	SetPos(0.16,-0.35); local value = optionsSlider("savegame.mod.progdest.fyr_minrad", 2, 1, 15);
		UiPop();
		UiPush();	SetPos(0.31,-0.35); UiText(value);
		UiPop();
		if value > GetInt("savegame.mod.progdest.fyr_maxrad") then 
			SetInt("savegame.mod.progdest.fyr_maxrad", value)
		end
		UiPush();	SetPos(0.43,-0.35);	UiText("Max Radius:");
		UiPop();	
		UiPush();	SetPos(0.53,-0.35); local value = optionsSlider("savegame.mod.progdest.fyr_maxrad", 10, 6, 70);
		UiPop();
		UiPush();	SetPos(0.67,-0.35); UiText(value);
		UiPop();
		UiPush();	SetPos(0.06,-0.25);	UiText("Min Mass:");
		UiPop();
		UiPush();	SetPos(0.16,-0.25); local value = optionsSlider("savegame.mod.progdest.fyr_minmass", 1, 1, 40);
		UiPop();
		UiPush();	SetPos(0.31,-0.25); UiText(value);
		UiPop();
		UiPush();	SetPos(0.43,-0.25);	UiText("Max Mass:");
		UiPop();	
		UiPush();	SetPos(0.53,-0.25); local value = optionsSlider("savegame.mod.progdest.fyr_maxmass", 40, 40, 8000, 10);
		UiPop();
		UiPush();	SetPos(0.67,-0.25); UiText(value);	
		UiPop();		
		UiPush();	SetPos(0.70,-0.30);	UiText("Chance to burn");  -- This so happens to be the last slider added to this mod before initial release.
		UiPop();	
		UiPush();	SetPos(0.78,-0.30); local value = optionsSlider("savegame.mod.progdest.fyr_chance", 1, 1, 100, 2);
		UiPop();
		UiPush();	SetPos(0.91,-0.30); UiText(value);	
		UiPop();			
		UiPush();	SetPos(0.935,-0.30); UiText("%");	
		UiPop();			

	-- THE FINAL TOOL TYPS SECTION
		UiColor(0.15,0.65,1);	
		UiPush();	SetPos(0.35,-0.31); UiText("Min/Max Radius (from player) that stuff burns in.");
		UiPop();
		UiPush();	SetPos(0.35,-0.22); UiText("Min/Max mass burning objects must have.");
		UiPop();		

	end
	if GetBool("savegame.mod.progdest.Tog_VIOL") then
		UiFont("bold.ttf", 20)	
		-- the sick multi-click multi-mode selectatron
		UiColor(1,1-math.random(),1)
		UiPush();	SetPos(0.525,-0.15);	
		if UiTextButton("Violence Mode", 128, 40) then
			SetInt("savegame.mod.progdest.VIOL_mode",GetInt("savegame.mod.progdest.VIOL_mode")+1);
		end	
		UiPop();
		if GetInt("savegame.mod.progdest.VIOL_mode")>4 then	
			SetInt("savegame.mod.progdest.VIOL_mode", 1);
		end
		-- Single Color mode
		UiColor(1,1,1)
		if GetInt("savegame.mod.progdest.VIOL_mode")==1 then
		
			UiPush();	SetPos(0.685,-0.15);	UiText("Debris Only (Best)");
			UiPop();

		end		
		if GetInt("savegame.mod.progdest.VIOL_mode")==2 then
		
			UiPush();	SetPos(0.775,-0.15);	UiText("Any Dynamic Body (Except vehicles)");
			UiPop();

		end			
		if GetInt("savegame.mod.progdest.VIOL_mode")==3 then
		
			UiPush();	SetPos(0.685,-0.15);	UiText("Vehicles Only");
			UiPop();

		end	
		if GetInt("savegame.mod.progdest.VIOL_mode")==4 then
		
			UiPush();	SetPos(0.685,-0.15);	UiText("All of the above");
			UiPop();

		end					
		UiPush();	SetPos(0.15,-0.05);	UiText("Chance of Violence:");
		UiPop();
		UiPush();	SetPos(0.25,-0.05); local value = optionsSlider("savegame.mod.progdest.VIOL_Chance", 1, 1, 200);
		UiPop();
		UiPush();	SetPos(0.40,-0.05); UiText(value/10);
		UiPop();
		UiPush();	SetPos(0.52,-0.05);	UiText("Max Distance:");
		UiPop();
		UiPush();	SetPos(0.62,-0.05); local value = optionsSlider("savegame.mod.progdest.VIOL_maxdist", 10, 5, 100);
		UiPop();
		UiPush();	SetPos(0.76,-0.05); UiText(value);
		UiPop();		
		UiPush();	SetPos(0.15,0.05);	UiText("Movement Force:");
		UiPop();
		UiPush();	SetPos(0.25,0.05); local value = optionsSlider("savegame.mod.progdest.VIOL_mover", 0, 0, 100);
		UiPop();
		UiPush();	SetPos(0.40,0.05); UiText(value);
		UiPop();		
		UiPush();	SetPos(0.52,0.05);	UiText("Rotational Force:");
		UiPop();	
		UiPush();	SetPos(0.62,0.05); local value = optionsSlider("savegame.mod.progdest.VIOL_turnr", 0, 0, 300, 10);
		UiPop();
		UiPush();	SetPos(0.76,0.05); UiText(value);	
		UiPop();
		UiPush();	SetPos(0.15,0.15);	UiText("Min Mass:");
		UiPop();
		UiPush();	SetPos(0.25,0.15); local value = optionsSlider("savegame.mod.progdest.VIOL_minmass", 0, 0, 50);
		UiPop();
		UiPush();	SetPos(0.40,0.15); UiText(value);
		UiPop();
		if value > GetInt("savegame.mod.progdest.VIOL_maxmass") then 
			SetInt("savegame.mod.progdest.VIOL_maxmass", value)
		end
		UiPush();	SetPos(0.52,0.15);	UiText("Max Mass:");
		UiPop();	
		UiPush();	SetPos(0.62,0.15); local value = optionsSliderLarge("savegame.mod.progdest.VIOL_maxmass", 50, 50, 50050, 1000);
		UiPop();
		UiPush();	SetPos(0.86,0.15); UiText(value);
		UiPop();
	-- THE FINAL TOOL TYPS SECTION
		UiColor(0.15,0.65,1);	
		UiPush();	SetPos(0.64,-0.02); UiText("Max dist from the player that debris gets violent in");
		UiPop();
		UiPush();	SetPos(0.47,0.09); UiText("The FORCE settings above determine in what way debris gets voilent.");
		UiPop();		
		UiPush();	SetPos(0.47,0.18); UiText("Sets the Minimum and max mass that a physics object needs to get voilent");
		UiPop();			
	end	
	if GetBool("savegame.mod.progdest.Tog_DAMSTAT") then
		UiFont("bold.ttf", 20)	
		-- the sick multi-click multi-mode selectatron
		UiColor(1,1-math.random(),1)
		UiPush();	SetPos(0.55,0.25);	
		if UiTextButton("Currency:", 170, 40) then
			SetInt("savegame.mod.progdest.DAMSTAT_Currency",GetInt("savegame.mod.progdest.DAMSTAT_Currency")+1);
		end	
		UiPop();
		if GetInt("savegame.mod.progdest.DAMSTAT_Currency")>30 then	
			SetInt("savegame.mod.progdest.DAMSTAT_Currency", 1);
		end
		-- Single Color mode
		UiColor(1,1,1)
		if GetInt("savegame.mod.progdest.DAMSTAT_Currency")==1 then
		
			UiPush();	SetPos(0.74,0.25);	UiText("£ (british pounds)");
			UiPop();

		end	
		if GetInt("savegame.mod.progdest.DAMSTAT_Currency")==2 then
		
			UiPush();	SetPos(0.74,0.25);	UiText("EUR (Euros)");
			UiPop();

		end			
		if GetInt("savegame.mod.progdest.DAMSTAT_Currency")==3 then
		
			UiPush();	SetPos(0.74,0.25);	UiText("JPY (Japanese Yen)");
			UiPop();

		end	
		if GetInt("savegame.mod.progdest.DAMSTAT_Currency")==4 then
		
			UiPush();	SetPos(0.74,0.25);	UiText("RUB (Russian Ruble)");
			UiPop();

		end
		if GetInt("savegame.mod.progdest.DAMSTAT_Currency")==5 then
		
			UiPush();	SetPos(0.74,0.25);	UiText("INR (Rupee)");
			UiPop();

		end			
		if GetInt("savegame.mod.progdest.DAMSTAT_Currency")==6 then
		
			UiPush();	SetPos(0.74,0.25);	UiText("IQD (Iraqui Dinar)");
			UiPop();

		end			
		if GetInt("savegame.mod.progdest.DAMSTAT_Currency")==7 then
		
			UiPush();	SetPos(0.74,0.25);	UiText("PLN (Polish Zloty)");
			UiPop();

		end	
		if GetInt("savegame.mod.progdest.DAMSTAT_Currency")==8 then
		
			UiPush();	SetPos(0.74,0.25);	UiText("Baljits (Baljeet Bucks)");
			UiPop();

		end
		if GetInt("savegame.mod.progdest.DAMSTAT_Currency")==9 then
		
			UiPush();	SetPos(0.74,0.25);	UiText("ZAR (South African rand)");
			UiPop();

		end	
		if GetInt("savegame.mod.progdest.DAMSTAT_Currency")==10 then
		
			UiPush();	SetPos(0.74,0.25);	UiText("VND (vietnamese dong)");
			UiPop();

		end
		if GetInt("savegame.mod.progdest.DAMSTAT_Currency")==11 then
		
			UiPush();	SetPos(0.74,0.25);	UiText("BTC (Bitcoin)");
			UiPop();

		end				
		if GetInt("savegame.mod.progdest.DAMSTAT_Currency")==12 then
		
			UiPush();	SetPos(0.74,0.25);	UiText("ETH (Etherium)");
			UiPop();

		end
		if GetInt("savegame.mod.progdest.DAMSTAT_Currency")==13 then
		
			UiPush();	SetPos(0.74,0.25);	UiText("DoGe (DogeCoin)");
			UiPop();

		end			
		if GetInt("savegame.mod.progdest.DAMSTAT_Currency")==14 then
		
			UiPush();	SetPos(0.74,0.25);	UiText("AMD (Armenian Dram)");
			UiPop();

		end
		if GetInt("savegame.mod.progdest.DAMSTAT_Currency")==15 then
		
			UiPush();	SetPos(0.74,0.25);	UiText("AZN (Azerbaijani manat)");
			UiPop();

		end
		if GetInt("savegame.mod.progdest.DAMSTAT_Currency")==16 then
		
			UiPush();	SetPos(0.74,0.25);	UiText("GOLD (Gold Bars)");
			UiPop();

		end			
		if GetInt("savegame.mod.progdest.DAMSTAT_Currency")==17 then
		
			UiPush();	SetPos(0.74,0.25);	UiText("SVR (lbs of silver)");
			UiPop();

		end			
		if GetInt("savegame.mod.progdest.DAMSTAT_Currency")==18 then
		
			UiPush();	SetPos(0.74,0.25);	UiText("KgCpr (KG of copper)");
			UiPop();

		end			
		if GetInt("savegame.mod.progdest.DAMSTAT_Currency")==19 then
		
			UiPush();	SetPos(0.74,0.25);	UiText("FChk (Fresh Chickens)");
			UiPop();

		end	
		if GetInt("savegame.mod.progdest.DAMSTAT_Currency")==20 then
		
			UiPush();	SetPos(0.74,0.25);	UiText("KFCh (Fried Chickens)");
			UiPop();

		end				
		if GetInt("savegame.mod.progdest.DAMSTAT_Currency")==21 then
		
			UiPush();	SetPos(0.74,0.25);	UiText("GvFks (Giveable F***s)");
			UiPop();

		end			
		if GetInt("savegame.mod.progdest.DAMSTAT_Currency")==22 then
		
			UiPush();	SetPos(0.74,0.25);	UiText("CAP (Bottlecaps)");
			UiPop();

		end			
		if GetInt("savegame.mod.progdest.DAMSTAT_Currency")==23 then
		
			UiPush();	SetPos(0.74,0.25);	UiText("POT (Potatoes)");
			UiPop();

		end	
		if GetInt("savegame.mod.progdest.DAMSTAT_Currency")==24 then
		
			UiPush();	SetPos(0.74,0.25);	UiText("Cr (Credits)");
			UiPop();

		end			
		if GetInt("savegame.mod.progdest.DAMSTAT_Currency")==25 then
		
			UiPush();	SetPos(0.74,0.25);	UiText("Edd (Euro Dollars)");
			UiPop();

		end			
		if GetInt("savegame.mod.progdest.DAMSTAT_Currency")==26 then
		
			UiPush();	SetPos(0.74,0.25);	UiText("d (old english six-pence)");
			UiPop();

		end			
		if GetInt("savegame.mod.progdest.DAMSTAT_Currency")==27 then
		
			UiPush();	SetPos(0.74,0.25);	UiText("Robux (Roblocks Bucks)");
			UiPop();

		end			
		if GetInt("savegame.mod.progdest.DAMSTAT_Currency")==30 then --AUSTRALIAN DOLLAS - GOIN IN IF THEY EVAH FIX ROTAYTED TEKST MAYTE
		
			UiPush();	SetPos(0.74,0.25);	UiText("AUD");
			UiPop();
			UiPush();	SetPos(0.84,0.25);	
			UiRotate(180)
			UiText("Australian Dollars");
			UiRotate(180)
			UiPop();
			

		end			

	-- THE FINAL TOOL TYPS SECTION
		UiColor(0.15,0.65,1);	
		UiPush();	SetPos(0.64,0.31); UiText("Choose one of the most popular currencies");
		UiPop();
		UiPush();	SetPos(0.64,0.34); UiText("To display damage statistics in.");
		UiPop();

	end
	if GetBool("savegame.mod.progdest.Tog_JOINTS") then
		UiFont("bold.ttf", 20)	
		-- the sick multi-click multi-mode selectatron
		UiColor(1,1-math.random(),1)
		UiPush();	SetPos(0.16,0.50);	
		if UiTextButton("Source of Breakage", 170, 40) then
			SetInt("savegame.mod.progdest.JOINT_Source",GetInt("savegame.mod.progdest.JOINT_Source")+1);
		end	
		UiPop();
		if GetInt("savegame.mod.progdest.JOINT_Source")>2 then	
			SetInt("savegame.mod.progdest.JOINT_Source", 1);
		end
		-- Single Color mode
		UiColor(1,1,1)
		if GetInt("savegame.mod.progdest.JOINT_Source")==1 then
		
			UiPush();	SetPos(0.33,0.50);	UiText("Pieces of Debris");
			UiPop();

		end	
		if GetInt("savegame.mod.progdest.JOINT_Source")==2 then
		
			UiPush();	SetPos(0.30,0.50);	UiText("Player");
			UiPop();

		end			
		UiPush();	SetPos(0.52,0.50);	UiText("Radius of breaks:");
		UiPop();	
		UiPush();	SetPos(0.62,0.50); local value = optionsSlider("savegame.mod.progdest.JOINT_Range", 5, 1, 100);
		UiPop();
		UiPush();	SetPos(0.76,0.50); UiText(value/2);
		UiPop();
		
		UiPush();	SetPos(0.52,0.40);	UiText("CHANCE to break:");
		UiPop();	
		UiPush();	SetPos(0.62,0.40); local value = optionsSlider("savegame.mod.progdest.JOINT_Chance", 5, 1, 100);
		UiPop();
		UiPush();	SetPos(0.76,0.40); UiText(value/100);
		UiPop();
	-- THE FINAL TOOL TYPS SECTION
		UiColor(0.15,0.65,1);	
		UiPush();	SetPos(0.48,0.55); UiText("Joints near debris pieces may break. Meaning doors stop working, hanging things");
		UiPop();
		UiPush();	SetPos(0.48,0.58); UiText("fall down, and dynamic buildings fall like a pack of cards.");
		UiPop();		
	
	end
end

function presetButton(bText, bPx, bPy, wid, hei, preset)
	UiPush();	SetPos(bPx , bPy);	
	-- Preset list (can delete this but usefull to keep track of presets.)
	if UiTextButton(bText, wid, hei) then
		LoadPreset(preset,bText)
	end	
	UiPop();
end

function DrawPage1()
		UiFont("bold.ttf", 35);
		UiAlign("right middle")
		shader = math.random()*0.2
		UiColor(0.8-shader,0.8-shader,1)
		UiPush();	SetPos(-0.6,-0.6);	UiText("GLOBAL PRESETS:");
		UiPop();
		UiPush();	SetPos(-0.6,-0.4);	UiText("FPS Control Presets:");
		UiPop();		
		UiPush();	SetPos(-0.6,-0.25);	UiText("Dust Presets:");
		UiPop();
		UiPush();	SetPos(-0.6,-0.10);	UiText("Crumbling Presets:");
		UiPop();				
		UiPush();	SetPos(-0.6,0.05);	UiText("Explosion Presets:");
		UiPop();
		UiPush();	SetPos(-0.6,0.20);	UiText("Wind/force presets:");
		UiPop();
		UiPush();	SetPos(-0.6,0.35);	UiText("Fire Presets:");
		UiPop();
		UiPush();	SetPos(-0.6,0.50);	UiText("Violence Presets:");
		UiPop();
		UiPush();	SetPos(-0.6,0.65);	UiText("Damage stats Currency:");
		UiPop();
		UiPush();	SetPos(-0.6,0.70);	UiText("Joint Breakage:");
		UiPop();
		UiFont("bold.ttf", 30);
		-- preset index:
		-- globals: 0-"all off"		
		--seperate function made for the presets and loading them
		-- usage: presetButton("Button Text", position x , position y, width, height, preset_index)
		-- (where positions are from -1 to 1 on the screen.)
		-- globals
		UiColor(.6,.6,.6); presetButton("All Off", -0.45,-0.6, 128, 36, 0);					--0
		UiColor(.76,.76,.6); presetButton("A little crumble", -0.245,-0.6, 190, 36, 1);		--1
		UiColor(.86,.76,.6); presetButton("Frequent Crumble", -0.01,-0.6, 220, 36, 2);		--2
		UiColor(.99,.66,.66); presetButton("Dynamic Buildings", 0.220,-0.6, 220, 36, 3);	--3
		UiColor(.96,.26,.26); presetButton("Hurricane Bob", 0.42,-0.6, 190, 36, 4);			--4
		UiColor(.86,.56,.06); presetButton("Ultra Chaos mode", 0.645,-0.6, 210, 36, 5);		--5
		UiColor(.76,.26,.86); presetButton("Props o' Death", 0.875,-0.6, 220, 36, 6);		--6
		-- FPS section
		UiColor(.6,.6,.6); presetButton("All Off", -0.45,-0.4, 128, 36, 20);				--20
		UiColor(.6,.6,.7); presetButton("Gentle Deletion", -0.245,-0.4, 190, 36, 21);		--21
		UiColor(.5,.5,.8); presetButton("Ranged Deletion", -0.01,-0.4, 220, 36, 22);		--22
		UiColor(.4,.4,.9); presetButton("Moderate Deletion", 0.25,-0.4, 240, 36, 23);		--23
		UiColor(.3,.3,.9); presetButton("Severe Deletion", 0.465,-0.4, 198, 36, 24);		--24
		UiColor(.1,.1,1); presetButton("Debris-b-gone!", 0.68,-0.4, 198, 36, 25);			--25
		
		UiColor(1,1,0);
		UiAlign("middle center")
		UiPush();	SetPos(0,-0.1);	UiText("Sub-section presets coming soon-ish");
		UiPop();
		UiPush();	SetPos(0,0.1);	UiText("If you find some good settings, screenshot the settings for them");
		UiPop();
		UiPush();	SetPos(0,0.2);	UiText("and post them to the workshop item's DISCUSSION page. If people");
		UiPop();
		UiPush();	SetPos(0,0.3);	UiText("like them (and there's still space) I will add them as a preset");
		UiPop();
		UiPush();	SetPos(0,0.4);	UiText("Cementing your place in history forever! :)");
		UiPop();
		
end


function DrawPage5()  -- OPTIONS
		UiFont("bold.ttf", 22);
		UiAlign("center middle")
		UiPush();	SetPos(0,-0.6);	UiText("Thanks for trying out my mod, I hope it gives you fun. It wasnt really meant for release and the code is abysmal.");
		UiPop();
		UiPush();	SetPos(0,-0.55);	UiText("This mod started off from me modifying the parameters of two other mods: STRUCTURAL INTEGRITY TEST (by");
		UiPop();
		UiPush();	SetPos(0,-0.50);	UiText("STRUCTURAL INTEGRITY TEST (by Wwadlol) as well as also the PERFORMANCE MOD (v1.3) by CoolJWB who really is the coolest");
		UiPop();		

		UiPush();	SetPos(0,-0.40);	UiText("I noticed that the way those mods worked together was kinda fun, but wanted to make a whole range of options modifiable in game.");
		UiPop();		
		UiPush();	SetPos(0,-0.35);	UiText("Thus, I started making this mod, but never intended to release it, but then I kept discovering cool new things to add.");
		UiPop();			
		UiPush();	SetPos(0,-0.30);	UiText("Now, it's a horrible mess of code... BUT IT WORKS! There are a lot of options. The point of this was to explose to a regular player");
		UiPop();			
		UiPush();	SetPos(0,-0.25);	UiText("A whole host of settings to allow them to configure the cool crumbling and debris-related chaos however they wanted.");
		UiPop();			
		UiPush();	SetPos(0,-0.05);	UiText("The presets section needs filling out, maybe you can help? :D");
		UiPop();
		UiPush();	SetPos(0, 0.05);	UiText("If you discover some really cool settings for a section or a group of sections, make sure to mention in on the mod's page.");
		UiPop();		
		UiPush();	SetPos(0, 0.10);	UiText("If I try them settings out and its pretty good, I may add them to the mod, as your settings! How coold is that? REAL COOL");
		UiPop();
		UiPush();	SetPos(0, 0.15);	UiText("If you like this mod, feel free to send me some crypto. TO DA MOON BBABA!!!");
		UiPop();

		UiPush();	SetPos(0, 0.25);	UiText("If you find any bugs, they are probably features. However, feel free to mention them on the mod page. I probably can't fix");
		UiPop();
		UiPush();	SetPos(0, 0.30);	UiText("them, but I may try.");
		UiPop();
		UiPush();	SetPos(0, 0.35);	UiText("Stay safe and look after your loved ones. YOU'RE BREATHTAKING!");
		UiPop();

		UiPush();	SetPos(0, 0.40);	UiText("Also special mention to all the cretins from the TD Discord, who's help was invaluable in getting some of this code working.");
		UiPop();
		UiPush();	SetPos(0, 0.45);	UiText("Including (but not limited to):");
		UiPop();
		UiPush();	SetPos(0, 0.50);	UiText("Bingle, Borgerking, iobarder, Micro, HLferdiNL, Nolram, Please Pick Name, Thomasims");
		UiPop();
		UiPush();	SetPos(0, 0.55);	UiText("Also the devs for making a cool game! :D");
		UiPop();

		UiPush();	SetPos(0, 0.65);	UiText("Feel free to drop by the discord, or ask for help on your way to modding TD.");
		UiPop();
		UiPush();	SetPos(0, 0.70);	UiText("If a potato like me can do it, you can do it too!");
		UiPop();
		
		UiFont("bold.ttf", 20);
		UiColor(0.15,0.65,1);
		UiPush();	SetPos(0,-0.20);	UiText("Sections in blue like this are explanations for the options near them.");
		UiPop();
end

function LoadPreset(selection, name)
	DebugPrint("Preset: " .. name .. "has been applied")
	if selection==0 then -- TURN THAT OFF.JPOG ****************************************************************************
		SetBool("savegame.mod.progdest.Tog_FPSC", false); -- Toggle/Title for FPS Control section.
		SetBool("savegame.mod.progdest.Tog_DUST", false); -- Toggle/Title for Dust Control section.
		SetBool("savegame.mod.progdest.Tog_CRUMBLE", false); -- Toggle/Title for Crumble section.
		SetBool("savegame.mod.progdest.Tog_RUMBLE", false); -- Toggle/Title for Explosives section.	
		SetBool("savegame.mod.progdest.Tog_FORCE", false); -- Toggle/Title for Force section.
		SetBool("savegame.mod.progdest.Tog_FIRE", false);	-- Toggle/Title for Force section.
		SetBool("savegame.mod.progdest.Tog_VIOL", false);	-- Toggle/Title for Force section.
		SetBool("savegame.mod.progdest.Tog_DAMSTAT", false);	-- Toggle/Title for Force section.
		SetBool("savegame.mod.progdest.Tog_JOINTS", false);	-- Toggle/Title for Force section.
	end	
	if selection==1 then -- GENTLE CRUMBLE ****************************************************************************
		SetBool("savegame.mod.progdest.Tog_FPSC", true); -- Toggle/Title for FPS Control section.
		SetBool("savegame.mod.progdest.Tog_DUST", true); -- Toggle/Title for Dust Control section.
		SetBool("savegame.mod.progdest.Tog_CRUMBLE", true); -- Toggle/Title for Crumble section.
		SetBool("savegame.mod.progdest.Tog_RUMBLE", false); -- Toggle/Title for Explosives section.	
		SetBool("savegame.mod.progdest.Tog_FORCE", false); -- Toggle/Title for Force section.
		SetBool("savegame.mod.progdest.Tog_FIRE", false);	-- Toggle/Title for Force section.
		SetBool("savegame.mod.progdest.Tog_VIOL", true);	-- Toggle/Title for Force section.
		SetBool("savegame.mod.progdest.Tog_DAMSTAT", false);	-- Toggle/Title for Force section.
		SetBool("savegame.mod.progdest.Tog_JOINTS", true);	-- Toggle/Title for Force section.
		-- FPS Control Section
		SetBool("savegame.mod.progdest.FPS_DynLights", false);	
		SetBool("savegame.mod.progdest.Tog_SDF", true);
		SetBool("savegame.mod.progdest.Tog_LFF", true);
		SetBool("savegame.mod.progdest.Tog_DBF", false);
		SetInt("savegame.mod.progdest.FPS_SDF", 4);	
		SetInt("savegame.mod.progdest.FPS_LFF", 119);	
		SetBool("savegame.mod.progdest.FPS_DBF_FPSB", false); -- Set DBF to only trigger when FPS is low.
		SetInt("savegame.mod.progdest.FPS_SDF_agg", 2);	
		SetInt("savegame.mod.progdest.FPS_LFF_agg", 3);	
		SetBool("savegame.mod.progdest.FPS_GLOB_agg", false);
		-- DUST Control Section
		SetInt("savegame.mod.progdest.dust_amt", 3);
		SetInt("savegame.mod.progdest.dust_size", 5);  -- REMEMBER - ALWAYS * 0.25
		SetInt("savegame.mod.progdest.dust_sizernd", 50);
		SetInt("savegame.mod.progdest.dust_MsBsSz", 10); --mass based size factor.
		SetInt("savegame.mod.progdest.dust_grav", 0.35);
		SetInt("savegame.mod.progdest.dust_drag", 0);
		SetInt("savegame.mod.progdest.dust_life", 8); -- REMEMBER - ALWAYS * 0.5
		SetInt("savegame.mod.progdest.dust_lifernd", 0.1);
		SetInt("savegame.mod.progdest.dust_MsBsLf", 0.2); --mass based life factor
		SetInt("savegame.mod.progdest.dust_minMass", 1); --Lower Cutoff 
		SetInt("savegame.mod.progdest.dust_minSpeed", 5); --Lower Cutoff div 5
		SetBool("savegame.mod.progdest.dust_DustMeth", false); -- false = on crumble, true = pure RNG.
		SetInt("savegame.mod.progdest.dust_MethRNG_Chance", 1); --Lower Cutoff
		SetInt("savegame.mod.progdest.dust_startsize", 5)
		SetInt("savegame.mod.progdest.dust_fader", 36)
		
		-- COLORS A NEW FEATURE TO DELAY THE LAUNCH!
		SetInt("savegame.mod.progdest.dust_ColMode", 6); --ColourMode (1 colour , 2 color , 3 color , randomized, greyscale)
		--Crumbling
		SetBool("savegame.mod.progdest.tog_crum", true);
		SetInt("savegame.mod.progdest.tog_crum_MODE", 0);  -- Mode - interval (0) or randomized (1).
		SetInt("savegame.mod.progdest.tog_crum_Source", 0);  -- Mode - Debris Only (0) or all phys (1).	
		SetInt("savegame.mod.progdest.crum_DMGLight", 200);
		SetInt("savegame.mod.progdest.crum_DMGMed", 200);
		SetInt("savegame.mod.progdest.crum_DMGHeavy", 200);
		SetInt("savegame.mod.progdest.crum_spd", -12);  -- can just use raw value
		SetFloat("savegame.mod.progdest.crum_spdRND", 0);
		SetInt("savegame.mod.progdest.crum_dist", 2);
		SetBool("savegame.mod.progdest.vehicles_crumble", false);
		
		SetInt("savegame.mod.progdest.crum_HoleControl", 4);
		SetFloat("savegame.mod.progdest.crum_BreakTime", 5); --DIV BY 2
		SetInt("savegame.mod.progdest.crum_distFromPlyr", 42);
		SetInt("savegame.mod.progdest.crum_MinMass", 4);
		SetInt("savegame.mod.progdest.crum_MaxMass", 18895);
		SetFloat("savegame.mod.progdest.crum_MinSpd", 2); -- RAW VALUE IS DIV BY 10
		SetFloat("savegame.mod.progdest.crum_MaxSpd", 44);
		
		-- Force and Fire
		SetBool("savegame.mod.progdest.4ce_ENABLE_CONTROLS", false);
		SetBool("savegame.mod.progdest.4ce_Showcross", false);
		SetBool("savegame.mod.progdest.4ce_CONTROL_TIPS", false);
		-- math.sin(GetTime()) --apparently takes 6.28 seconds for a full rotation

		-- MISCELLANEOUS SETTINGS
		-- VIOLENCE
		SetInt("savegame.mod.progdest.VIOL_mode", 1); 
		-- VIOLENCE
		SetInt("savegame.mod.progdest.VIOL_Chance", 25); 
		SetInt("savegame.mod.progdest.VIOL_mover", 1); -- maximum radius of the effect
		SetInt("savegame.mod.progdest.VIOL_turnr", 10);
		SetInt("savegame.mod.progdest.VIOL_minmass", 2);
		SetInt("savegame.mod.progdest.VIOL_maxmass", 3000);
		-- JOINT BREAKAGE
		SetInt("savegame.mod.progdest.JOINT_Source", 1);  -- 1=Debris chunks // 2=player
		SetInt("savegame.mod.progdest.JOINT_Range", 9); -- radius to check for joints from the source.
		SetInt("savegame.mod.progdest.JOINT_Chance", 6); -- percent chance to break in radius.	
	end
	if selection==2 then -- MORE CRUMBLE ****************************************************************************
		SetBool("savegame.mod.progdest.Tog_FPSC", true); -- Toggle/Title for FPS Control section.
		SetBool("savegame.mod.progdest.Tog_DUST", true); -- Toggle/Title for Dust Control section.
		SetBool("savegame.mod.progdest.Tog_CRUMBLE", true); -- Toggle/Title for Crumble section.
		SetBool("savegame.mod.progdest.Tog_RUMBLE", false); -- Toggle/Title for Explosives section.	
		SetBool("savegame.mod.progdest.Tog_FORCE", false); -- Toggle/Title for Force section.
		SetBool("savegame.mod.progdest.Tog_FIRE", false);	-- Toggle/Title for Force section.
		SetBool("savegame.mod.progdest.Tog_VIOL", true);	-- Toggle/Title for Force section.
		SetBool("savegame.mod.progdest.Tog_DAMSTAT", false);	-- Toggle/Title for Force section.
		SetBool("savegame.mod.progdest.Tog_JOINTS", true);	-- Toggle/Title for Force section.
		-- FPS Control Section
		SetBool("savegame.mod.progdest.FPS_DynLights", false);	
		SetBool("savegame.mod.progdest.Tog_SDF", true);
		SetBool("savegame.mod.progdest.Tog_LFF", true);
		SetBool("savegame.mod.progdest.Tog_DBF", false);
		SetInt("savegame.mod.progdest.FPS_SDF", 10);	
		SetInt("savegame.mod.progdest.FPS_LFF", 239);	
		SetBool("savegame.mod.progdest.FPS_DBF_FPSB", false); -- Set DBF to only trigger when FPS is low.
		SetInt("savegame.mod.progdest.FPS_SDF_agg", 9);	
		SetInt("savegame.mod.progdest.FPS_LFF_agg", 9);	
		SetBool("savegame.mod.progdest.FPS_GLOB_agg", true);
		SetInt("savegame.mod.progdest.FPS_GLOB_aggfac", 9);
		-- DUST Control Section
		SetInt("savegame.mod.progdest.dust_amt", 1);
		SetInt("savegame.mod.progdest.dust_size", 4);  -- CHKD - *0.25
		SetInt("savegame.mod.progdest.dust_sizernd", 50);  --CHKD raw 
		SetInt("savegame.mod.progdest.dust_MsBsSz", 10); -- CHKD raw
		SetInt("savegame.mod.progdest.dust_grav", -125); -- CHKD - IGV *100
		SetInt("savegame.mod.progdest.dust_drag", 16); -- CHKD - IGV *1000
		SetInt("savegame.mod.progdest.dust_life", 17); -- CHKD: IGV * 2
		SetInt("savegame.mod.progdest.dust_lifernd", 50); -- CHKD RAW
		SetInt("savegame.mod.progdest.dust_MsBsLf", 10); -- CHKD Raw
		SetInt("savegame.mod.progdest.dust_minMass", 1); --CHKD RAW
		SetInt("savegame.mod.progdest.dust_minSpeed", 1); --CHKD IGV * 5
		SetInt("savegame.mod.progdest.dust_startsize", 1) --CHKD IGV /10
		SetInt("savegame.mod.progdest.dust_fader", 124) --CHKD IGV *1000
		
		-- COLORS A NEW FEATURE TO DELAY THE LAUNCH!
		SetInt("savegame.mod.progdest.dust_ColMode", 6); --ColourMode (1 colour , 2 color , 3 color , randomized, greyscale)
		--Crumbling
		SetInt("savegame.mod.progdest.tog_crum_MODE", 0);  -- Mode - interval (0) or randomized (1).
		SetInt("savegame.mod.progdest.tog_crum_Source", 0);  -- Mode - Debris Only (0) or all phys (1).	
		SetInt("savegame.mod.progdest.crum_DMGLight", 200);  --RAW
		SetInt("savegame.mod.progdest.crum_DMGMed", 200);  --RAW
		SetInt("savegame.mod.progdest.crum_DMGHeavy", 200); -- RAW
		SetInt("savegame.mod.progdest.crum_spd", -6);  -- CHKD can just use raw value
		SetFloat("savegame.mod.progdest.crum_spdRND", 20); -- 20
		SetInt("savegame.mod.progdest.crum_dist", 1);  -- SIZE=Raw
		SetBool("savegame.mod.progdest.vehicles_crumble", false);
		
		SetInt("savegame.mod.progdest.crum_HoleControl", 6);
		SetFloat("savegame.mod.progdest.crum_BreakTime", 6); --DIV BY 2
		SetInt("savegame.mod.progdest.crum_distFromPlyr", 60);
		SetInt("savegame.mod.progdest.crum_MinMass", 1);  -- CHKD IGV*4
		SetInt("savegame.mod.progdest.crum_MaxMass", 80000);  -- RAW
		SetFloat("savegame.mod.progdest.crum_MinSpd", 2); -- CHKD IGV*10
		SetFloat("savegame.mod.progdest.crum_MaxSpd", 100);
		
		-- Force and Fire
		SetBool("savegame.mod.progdest.4ce_ENABLE_CONTROLS", false);
		SetBool("savegame.mod.progdest.4ce_Showcross", false);
		SetBool("savegame.mod.progdest.4ce_CONTROL_TIPS", false);
		-- math.sin(GetTime()) --apparently takes 6.28 seconds for a full rotation

		-- MISCELLANEOUS SETTINGS
		-- VIOLENCE
		SetInt("savegame.mod.progdest.VIOL_mode", 1); 
		-- VIOLENCE
		SetInt("savegame.mod.progdest.VIOL_Chance", 25); -- IGV * 10
		SetInt("savegame.mod.progdest.VIOL_mover", 1); -- RAW
		SetInt("savegame.mod.progdest.VIOL_turnr", 10); -- RAW
		SetInt("savegame.mod.progdest.VIOL_minmass", 2); -- RAW
		SetInt("savegame.mod.progdest.VIOL_maxmass", 50000); -- RAW
		-- JOINT BREAKAGE
		SetInt("savegame.mod.progdest.JOINT_Source", 1);  -- 1=Debris chunks // 2=player
		SetInt("savegame.mod.progdest.JOINT_Range", 12); -- IGV*2
		SetInt("savegame.mod.progdest.JOINT_Chance", 11); -- IGV*100
	end	
	if selection==3 then -- DYNAMIC BUILDINGS ****************************************************************************
		SetBool("savegame.mod.progdest.Tog_FPSC", true); -- Toggle/Title for FPS Control section.
		SetBool("savegame.mod.progdest.Tog_DUST", true); -- Toggle/Title for Dust Control section.
		SetBool("savegame.mod.progdest.Tog_CRUMBLE", true); -- Toggle/Title for Crumble section.
		SetBool("savegame.mod.progdest.Tog_RUMBLE", false); -- Toggle/Title for Explosives section.	
		SetBool("savegame.mod.progdest.Tog_FORCE", false); -- Toggle/Title for Force section.
		SetBool("savegame.mod.progdest.Tog_FIRE", false);	-- Toggle/Title for Force section.
		SetBool("savegame.mod.progdest.Tog_VIOL", true);	-- Toggle/Title for Force section.
		SetBool("savegame.mod.progdest.Tog_DAMSTAT", false);	-- Toggle/Title for Force section.
		SetBool("savegame.mod.progdest.Tog_JOINTS", true);	-- Toggle/Title for Force section.
		-- FPS Control Section
		SetBool("savegame.mod.progdest.FPS_DynLights", false);	
		SetBool("savegame.mod.progdest.Tog_SDF", true);
		SetBool("savegame.mod.progdest.Tog_LFF", true);
		SetBool("savegame.mod.progdest.Tog_DBF", false);
		SetInt("savegame.mod.progdest.FPS_SDF", 10);	
		SetInt("savegame.mod.progdest.FPS_LFF", 185);	
		SetInt("savegame.mod.progdest.FPS_SDF_agg", 38);	
		SetInt("savegame.mod.progdest.FPS_LFF_agg", 38);	
		SetBool("savegame.mod.progdest.FPS_GLOB_agg", true);
		SetInt("savegame.mod.progdest.FPS_GLOB_aggfac", 38);
		SetInt("savegame.mod.progdest.FPS_Targ", 40);
		SetInt("savegame.mod.progdest.FPS_agg", 38);
				-- DUST Control Section
		SetInt("savegame.mod.progdest.dust_amt", 3);
		SetInt("savegame.mod.progdest.dust_grav", -180); -- CHKD - IGV *100
		SetInt("savegame.mod.progdest.dust_drag", 11); -- CHKD - IGV *100
		SetInt("savegame.mod.progdest.dust_fader", 312) --CHKD IGV *1000
		SetInt("savegame.mod.progdest.dust_size", 7);  -- CHKD - IGV*4
		SetInt("savegame.mod.progdest.dust_sizernd", 20);  --CHKD raw 
		SetInt("savegame.mod.progdest.dust_MsBsSz", 0); -- CHKD raw
		SetInt("savegame.mod.progdest.dust_startsize", 60) --CHKD IGV /10
		SetInt("savegame.mod.progdest.dust_life", 12); -- CHKD: IGV * 2
		SetInt("savegame.mod.progdest.dust_lifernd", 100); -- CHKD RAW
		SetInt("savegame.mod.progdest.dust_MsBsLf", 10); -- CHKD Raw
		SetInt("savegame.mod.progdest.dust_minMass", 5); --CHKD RAW
		SetInt("savegame.mod.progdest.dust_minSpeed", 10); --CHKD IGV * 5
		SetInt("savegame.mod.progdest.dust_ColMode", 6); --ColourMode (1 colour , 2 color , 3 color , randomized, greyscale)
		
		--Crumbling
		SetInt("savegame.mod.progdest.tog_crum_MODE", 1);  -- Mode - interval (0) or randomized (1).
		SetInt("savegame.mod.progdest.tog_crum_Source", 0);  -- Mode - Debris Only (0) or all phys (1).	
		SetInt("savegame.mod.progdest.crum_DMGLight",60);  --RAW
		SetInt("savegame.mod.progdest.crum_DMGMed", 45);  --RAW
		SetInt("savegame.mod.progdest.crum_DMGHeavy", 25); -- RAW
		SetInt("savegame.mod.progdest.crum_spd", -16);  -- CHKD can just use raw value
		SetFloat("savegame.mod.progdest.crum_spdRND", 10); -- 20
		SetInt("savegame.mod.progdest.crum_dist", 2);  -- SIZE=Raw
		SetBool("savegame.mod.progdest.vehicles_crumble", false);
		
		SetInt("savegame.mod.progdest.crum_HoleControl", 4);
		SetFloat("savegame.mod.progdest.crum_BreakTime", 14); --DIV BY 2
		SetInt("savegame.mod.progdest.crum_distFromPlyr", 60);
		SetInt("savegame.mod.progdest.crum_MinMass", 5);  -- CHKD IGV*4
		SetInt("savegame.mod.progdest.crum_MaxMass", 42069);  -- RAW
		SetFloat("savegame.mod.progdest.crum_MinSpd", 8); -- CHKD IGV*10
		SetFloat("savegame.mod.progdest.crum_MaxSpd", 68); -- CHKD Raw
	
		-- MISCELLANEOUS SETTINGS
		-- VIOLENCE
		SetInt("savegame.mod.progdest.VIOL_mode", 1); 
		-- VIOLENCE
		SetInt("savegame.mod.progdest.VIOL_Chance", 63); -- IGV * 10
		SetInt("savegame.mod.progdest.VIOL_mover", 1); -- RAW
		SetInt("savegame.mod.progdest.VIOL_turnr", 10); -- RAW
		SetInt("savegame.mod.progdest.VIOL_minmass", 0); -- RAW
		SetInt("savegame.mod.progdest.VIOL_maxmass", 12346); -- RAW
		-- JOINT BREAKAGE
		SetInt("savegame.mod.progdest.JOINT_Source", 1);  -- 1=Debris chunks // 2=player
		SetInt("savegame.mod.progdest.JOINT_Range", 13); -- IGV*2
		SetInt("savegame.mod.progdest.JOINT_Chance", 75); -- IGV*100
	end		
	if selection==4 then -- HURRICANE BOB ****************************************************************************
		SetBool("savegame.mod.progdest.Tog_FPSC", true); -- Toggle/Title for FPS Control section.
		SetBool("savegame.mod.progdest.Tog_DUST", false); -- Toggle/Title for Dust Control section.
		SetBool("savegame.mod.progdest.Tog_CRUMBLE", false); -- Toggle/Title for Crumble section.
		SetBool("savegame.mod.progdest.Tog_RUMBLE", false); -- Toggle/Title for Explosives section.	
		SetBool("savegame.mod.progdest.Tog_FORCE", true); -- Toggle/Title for Force section.
		SetBool("savegame.mod.progdest.Tog_FIRE", false);	-- Toggle/Title for Force section.
		SetBool("savegame.mod.progdest.Tog_VIOL", true);	-- Toggle/Title for Force section.
		SetBool("savegame.mod.progdest.Tog_DAMSTAT", false);	-- Toggle/Title for Force section.
		SetBool("savegame.mod.progdest.Tog_JOINTS", true);	-- Toggle/Title for Force section.
		-- FPS Control Section
		SetBool("savegame.mod.progdest.FPS_DynLights", false);	
		SetBool("savegame.mod.progdest.Tog_SDF", true);
		SetBool("savegame.mod.progdest.Tog_LFF", true);
		SetBool("savegame.mod.progdest.Tog_DBF", true);
		SetInt("savegame.mod.progdest.FPS_SDF", 10);	
		SetInt("savegame.mod.progdest.FPS_LFF", 239);	
		SetInt("savegame.mod.progdest.FPS_DBF", 70);
		SetBool("savegame.mod.progdest.FPS_DBF_FPSB", false); -- Set DBF to only trigger when FPS is low.
		SetInt("savegame.mod.progdest.FPS_SDF_agg", 100);	
		SetInt("savegame.mod.progdest.FPS_LFF_agg", 100);	
		SetInt("savegame.mod.progdest.FPS_DBF_agg", 100);
		SetBool("savegame.mod.progdest.FPS_GLOB_agg", true);
		SetInt("savegame.mod.progdest.FPS_GLOB_aggfac", 100);
		SetInt("savegame.mod.progdest.FPS_Targ", 40);
		SetInt("savegame.mod.progdest.FPS_agg", 100);
		
	
		-- Force and Fire
		-- Force and Fire
		SetInt("savegame.mod.progdest.4ce_method", 3); 
		SetInt("savegame.mod.progdest.4ce_radius", 26); -- toggle in game controls on or off
		SetInt("savegame.mod.progdest.4ce_maxmass", 25000); -- toggle in game controls on or off
		SetInt("savegame.mod.progdest.4ce_minmass", 2); -- toggle in game controls on or off
		SetInt("savegame.mod.progdest.4ce_strength", 84); -- toggle in game controls on or off
		SetInt("savegame.mod.progdest.4ce_boost", 0)
		SetBool("savegame.mod.progdest.4ce_START_ON", true);
		SetBool("savegame.mod.progdest.4ce_ENABLE_CONTROLS", true);
		SetBool("savegame.mod.progdest.4ce_Showcross", false);
		SetBool("savegame.mod.progdest.4ce_CONTROL_TIPS", true);
		SetInt("savegame.mod.progdest.4ce_cycle", 18); -- OPTIONAL Rotating/Rocking cycle time.
		SetInt("savegame.mod.progdest.4ce_largemass_accellerator", 2); -- Use to either amplify or soften scaler at higher masses.
		SetInt("savegame.mod.progdest.4ce_upforce", 0); -- Custom Upforce to counter friction.
		SetInt("savegame.mod.progdest.4ce_effect_on_player",32)

		-- MISCELLANEOUS SETTINGS
		-- VIOLENCE
		SetInt("savegame.mod.progdest.VIOL_mode", 1); 
		-- VIOLENCE
		SetInt("savegame.mod.progdest.VIOL_Chance", 53); -- IGV * 10
		SetInt("savegame.mod.progdest.VIOL_mover", 27); -- RAW
		SetInt("savegame.mod.progdest.VIOL_turnr", 180); -- RAW
		SetInt("savegame.mod.progdest.VIOL_minmass", 7); -- RAW
		SetInt("savegame.mod.progdest.VIOL_maxmass", 12000); -- RAW
		-- JOINT BREAKAGE
		SetInt("savegame.mod.progdest.JOINT_Source", 1);  -- 1=Debris chunks // 2=player
		SetInt("savegame.mod.progdest.JOINT_Range", 13); -- IGV*2
		SetInt("savegame.mod.progdest.JOINT_Chance", 54); -- IGV*100
	end		
	if selection==5 then -- CHAOS MODE (the only thing crumbling here is the framerate) ****************************************************************************
		SetBool("savegame.mod.progdest.Tog_FPSC", true); -- Toggle/Title for FPS Control section.
		SetBool("savegame.mod.progdest.Tog_DUST", true); -- Toggle/Title for Dust Control section.
		SetBool("savegame.mod.progdest.Tog_CRUMBLE", false); -- Toggle/Title for Crumble section.
		SetBool("savegame.mod.progdest.Tog_RUMBLE", true); -- Toggle/Title for Explosives section.	
		SetBool("savegame.mod.progdest.Tog_FORCE", true); -- Toggle/Title for Force section.
		SetBool("savegame.mod.progdest.Tog_FIRE", true);	-- Toggle/Title for Force section.
		SetBool("savegame.mod.progdest.Tog_VIOL", true);	-- Toggle/Title for Force section.
		SetBool("savegame.mod.progdest.Tog_DAMSTAT", false);	-- Toggle/Title for Force section.
		SetBool("savegame.mod.progdest.Tog_JOINTS", false);	-- Toggle/Title for Force section.

		-- FPS Control Section
		SetBool("savegame.mod.progdest.FPS_DynLights", false);	
		SetBool("savegame.mod.progdest.Tog_SDF", true);
		SetBool("savegame.mod.progdest.Tog_LFF", true);
		SetBool("savegame.mod.progdest.Tog_DBF", true);
		SetInt("savegame.mod.progdest.FPS_SDF", 10);	
		SetInt("savegame.mod.progdest.FPS_LFF", 185);	
		SetInt("savegame.mod.progdest.FPS_DBF", 75);
		SetBool("savegame.mod.progdest.FPS_DBF_FPSB", false); -- Set DBF to only trigger when FPS is low.
		SetInt("savegame.mod.progdest.FPS_SDF_agg", 100);	
		SetInt("savegame.mod.progdest.FPS_LFF_agg", 100);	
		SetInt("savegame.mod.progdest.FPS_DBF_agg", 100);
		SetBool("savegame.mod.progdest.FPS_GLOB_agg", true);
		SetInt("savegame.mod.progdest.FPS_GLOB_aggfac", 100);
		SetInt("savegame.mod.progdest.FPS_Targ", 40);
		SetInt("savegame.mod.progdest.FPS_agg", 100);
		
		-- DUST
		SetInt("savegame.mod.progdest.dust_amt", 5);
		SetInt("savegame.mod.progdest.dust_grav", 1); -- CHKD - IGV *100
		SetInt("savegame.mod.progdest.dust_drag", 0); -- CHKD - IGV *100
		SetInt("savegame.mod.progdest.dust_fader", 109) --CHKD IGV *1000
		SetInt("savegame.mod.progdest.dust_size", 3);  -- CHKD - IGV*4
		SetInt("savegame.mod.progdest.dust_sizernd", 40);  --CHKD raw 
		SetInt("savegame.mod.progdest.dust_MsBsSz", 0); -- CHKD raw
		SetInt("savegame.mod.progdest.dust_startsize", 10) --CHKD IGV /10
		SetInt("savegame.mod.progdest.dust_life", 10); -- CHKD: IGV * 2
		SetInt("savegame.mod.progdest.dust_lifernd", 70); -- CHKD RAW
		SetInt("savegame.mod.progdest.dust_MsBsLf", 10); -- CHKD Raw
		SetInt("savegame.mod.progdest.dust_minMass", 5); --CHKD RAW
		SetInt("savegame.mod.progdest.dust_minSpeed", 2); --CHKD IGV * 5
		SetInt("savegame.mod.progdest.dust_ColMode", 5); --ColourMode (1 colour , 2 color , 3 color , randomized, greyscale)
		SetInt("savegame.mod.progdest.rainbow_spd", 108);
		SetInt("savegame.mod.progdest.crum_spd", 10);
		SetInt("savegame.mod.progdest.tog_crum_MODE",0)
		-- Explosions! I like explosions
		SetFloat("savegame.mod.progdest.xplo_szBase", 4);  --IGV*4
		SetFloat("savegame.mod.progdest.xplo_szRnd", 20); --IGV*5
		SetInt("savegame.mod.progdest.xplo_chance", 43);  --Raw
		
		SetInt("savegame.mod.progdest.xplo_Control", 8);
		SetFloat("savegame.mod.progdest.xplo_BreakTime", 15);
		SetInt("savegame.mod.progdest.xplo_distFromPlyr", 27);
		SetInt("savegame.mod.progdest.xplo_MinMass", 8);
		SetInt("savegame.mod.progdest.xplo_MaxMass", 8000);
		SetFloat("savegame.mod.progdest.xplo_MinSpd", 36); --IGV *10
		SetFloat("savegame.mod.progdest.xplo_MaxSpd", 100); 
		SetInt("savegame.mod.progdest.xplo_SmokeAMT", 4);  --IGV * 4
		SetInt("savegame.mod.progdest.xplo_LifeAMT", 1); -- IGV * 4
		SetInt("savegame.mod.progdest.xplo_Pressure", 16);  -- IGV * 4
		SetInt("savegame.mod.progdest.xplo_mode", 1);  --explosion mode 1=debris only, 2=all dynamic, 3= vehicles only	
		SetInt("savegame.mod.progdest.xplo_ColMode", 6); --ColourMode (1 colour , 2 color , 3 color , randomized, greyscale)
		
		-- Force and Fire
		SetInt("savegame.mod.progdest.4ce_method", 5); 
		SetInt("savegame.mod.progdest.4ce_radius", 20); 
		SetInt("savegame.mod.progdest.4ce_maxmass", 25000); -- raw
		SetInt("savegame.mod.progdest.4ce_minmass", 24); -- raw
		SetInt("savegame.mod.progdest.4ce_strength", -56); --(should be 1.3) if not 6 5 or 1, is IGV*50, else is (121+IGV)*50
		SetInt("savegame.mod.progdest.4ce_boost", 25)  -- IGV * 10
		SetBool("savegame.mod.progdest.4ce_START_ON", true); 
		SetBool("savegame.mod.progdest.4ce_ENABLE_CONTROLS", true);
		SetBool("savegame.mod.progdest.4ce_Showcross", false);
		SetBool("savegame.mod.progdest.4ce_CONTROL_TIPS", true);
		SetInt("savegame.mod.progdest.4ce_cycle", 7); -- IGV /3.28
		SetInt("savegame.mod.progdest.4ce_largemass_accellerator", 2); -- IGV*10
		SetInt("savegame.mod.progdest.4ce_upforce", 1); -- RAW
		SetInt("savegame.mod.progdest.4ce_effect_on_player",1) --RAW

		-- MISCELLANEOUS SETTINGS
		-- FIRE
		SetInt("savegame.mod.progdest.fyr_mode", 1); 
		SetInt("savegame.mod.progdest.fyr_maxrad", 15); -- maximum radius of the effect
		SetInt("savegame.mod.progdest.fyr_minrad", 3); -- Minimum radius of the effect
		SetInt("savegame.mod.progdest.fyr_maxmass", 2468); -- THE MAXIMUM MASS OF AN OBJECT WHICH COULD CATCH FIRE. WOW! THESE COMMENTS ARE REALLY NEEDED!
		SetInt("savegame.mod.progdest.fyr_minmass", 1); -- kys		
		-- VIOLENCE
		SetInt("savegame.mod.progdest.VIOL_mode", 1); 
		-- VIOLENCE
		SetInt("savegame.mod.progdest.VIOL_Chance", 108); -- IGV * 10
		SetInt("savegame.mod.progdest.VIOL_mover", 85); -- RAW
		SetInt("savegame.mod.progdest.VIOL_turnr", 270); -- RAW
		SetInt("savegame.mod.progdest.VIOL_minmass", 0); -- RAW
		SetInt("savegame.mod.progdest.VIOL_maxmass", 19000); -- RAW
	end		
	if selection==6 then -- PROPS O DEATH ****************************************************************************************************
		SetBool("savegame.mod.progdest.Tog_FPSC", true); -- Toggle/Title for FPS Control section.
		SetBool("savegame.mod.progdest.Tog_DUST", false); -- Toggle/Title for Dust Control section.
		SetBool("savegame.mod.progdest.Tog_CRUMBLE", false); -- Toggle/Title for Crumble section.
		SetBool("savegame.mod.progdest.Tog_RUMBLE", true); -- Toggle/Title for Explosives section.	
		SetBool("savegame.mod.progdest.Tog_FORCE", true); -- Toggle/Title for Force section.
		SetBool("savegame.mod.progdest.Tog_FIRE", true);	-- Toggle/Title for Force section.
		SetBool("savegame.mod.progdest.Tog_VIOL", true);	-- Toggle/Title for Force section.
		SetBool("savegame.mod.progdest.Tog_DAMSTAT", false);	-- Toggle/Title for Force section.
		SetBool("savegame.mod.progdest.Tog_JOINTS", false);	-- Toggle/Title for Force section.

		-- FPS Control Section
		SetBool("savegame.mod.progdest.FPS_DynLights", false);	
		SetBool("savegame.mod.progdest.Tog_SDF", true);
		SetBool("savegame.mod.progdest.Tog_LFF", true);
		SetBool("savegame.mod.progdest.Tog_DBF", true);
		SetInt("savegame.mod.progdest.FPS_SDF", 12);	
		SetInt("savegame.mod.progdest.FPS_LFF", 185);	
		SetInt("savegame.mod.progdest.FPS_DBF", 65);
		SetBool("savegame.mod.progdest.FPS_DBF_FPSB", false); -- Set DBF to only trigger when FPS is low.
		SetInt("savegame.mod.progdest.FPS_SDF_agg", 100);	
		SetInt("savegame.mod.progdest.FPS_LFF_agg", 8);	
		SetInt("savegame.mod.progdest.FPS_DBF_agg", 30);
		SetBool("savegame.mod.progdest.FPS_GLOB_agg", false);
		SetInt("savegame.mod.progdest.FPS_GLOB_aggfac", 0);
		SetInt("savegame.mod.progdest.FPS_Targ", 40);
		SetInt("savegame.mod.progdest.FPS_agg", 100);
		
		-- Explosions! I like explosions
		SetFloat("savegame.mod.progdest.xplo_szBase", 4);  --IGV*4
		SetFloat("savegame.mod.progdest.xplo_szRnd", 1); --IGV*5
		SetInt("savegame.mod.progdest.xplo_chance", 100);  --Raw
		
		SetInt("savegame.mod.progdest.xplo_Control", 6);
		SetFloat("savegame.mod.progdest.xplo_BreakTime", 11);
		SetInt("savegame.mod.progdest.xplo_distFromPlyr", 5);
		SetInt("savegame.mod.progdest.xplo_MinMass", 100);
		SetInt("savegame.mod.progdest.xplo_MaxMass", 4329);
		SetFloat("savegame.mod.progdest.xplo_MinSpd", 0); --IGV *10
		SetFloat("savegame.mod.progdest.xplo_MaxSpd", 21); 
		SetInt("savegame.mod.progdest.xplo_SmokeAMT", 12);  --IGV * 4
		SetInt("savegame.mod.progdest.xplo_LifeAMT", 24); -- IGV * 4
		SetInt("savegame.mod.progdest.xplo_Pressure", 14);  -- IGV * 4
		SetInt("savegame.mod.progdest.xplo_mode", 2);  --explosion mode 1=debris only, 2=all dynamic, 3= vehicles only	
		SetInt("savegame.mod.progdest.xplo_ColMode", 1); --ColourMode (1 colour , 2 color , 3 color , randomized, greyscale)
		SetInt("savegame.mod.progdest.xplo_Col1_R", 100);
		SetInt("savegame.mod.progdest.xplo_Col1_G", 18);
		SetInt("savegame.mod.progdest.xplo_Col1_B", 20);		
		
		-- Force and Fire
		SetInt("savegame.mod.progdest.4ce_method", 2); 
		SetInt("savegame.mod.progdest.4ce_radius", 20); 
		SetInt("savegame.mod.progdest.4ce_maxmass", 5150); -- raw
		SetInt("savegame.mod.progdest.4ce_minmass", 30); -- raw
		SetInt("savegame.mod.progdest.4ce_strength", -28); --(should be 1.3) if not 6 5 or 1, is IGV*50, else is (121+IGV)*50
		SetInt("savegame.mod.progdest.4ce_boost", 0)  -- IGV * 10
		SetBool("savegame.mod.progdest.4ce_START_ON", true); 
		SetBool("savegame.mod.progdest.4ce_ENABLE_CONTROLS", false);
		SetBool("savegame.mod.progdest.4ce_Showcross", false);
		SetBool("savegame.mod.progdest.4ce_CONTROL_TIPS", false);
		SetInt("savegame.mod.progdest.4ce_cycle", 7); -- IGV /3.28
		SetInt("savegame.mod.progdest.4ce_largemass_accellerator", 20); -- IGV*10
		SetInt("savegame.mod.progdest.4ce_upforce", 0); -- RAW
		SetInt("savegame.mod.progdest.4ce_effect_on_player",1) --RAW

		-- MISCELLANEOUS SETTINGS
		-- FIRE
		SetInt("savegame.mod.progdest.fyr_mode", 2); 
		SetInt("savegame.mod.progdest.fyr_maxrad", 26); -- RAW
		SetInt("savegame.mod.progdest.fyr_minrad", 10); -- RAW
		SetInt("savegame.mod.progdest.fyr_maxmass", 6000); -- RAW
		SetInt("savegame.mod.progdest.fyr_minmass", 20); -- RAW
		-- VIOLENCE
		SetInt("savegame.mod.progdest.VIOL_mode", 2); 
		-- VIOLENCE
		SetInt("savegame.mod.progdest.VIOL_Chance", 36); -- IGV * 10
		SetInt("savegame.mod.progdest.VIOL_mover", 76); -- RAW
		SetInt("savegame.mod.progdest.VIOL_turnr", 270); -- RAW
		SetInt("savegame.mod.progdest.VIOL_minmass", 20); -- RAW
		SetInt("savegame.mod.progdest.VIOL_maxmass", 39000); -- RAW
	end
	if selection==20 then -- FPS Controls off
		SetBool("savegame.mod.progdest.Tog_FPSC", false); -- Toggle/Title for FPS Control section.
		SetBool("savegame.mod.progdest.FPS_DynLights", false);	
		SetBool("savegame.mod.progdest.Tog_SDF", false);
		SetBool("savegame.mod.progdest.Tog_LFF", false);
		SetBool("savegame.mod.progdest.Tog_DBF", false);
		SetBool("savegame.mod.progdest.FPS_DBF_FPSB", false); -- Set DBF to only trigger when FPS is low.
		SetBool("savegame.mod.progdest.FPS_GLOB_agg", false);
	end
	if selection==21 then -- Gentle Deletion
		SetBool("savegame.mod.progdest.Tog_FPSC", true); -- Toggle/Title for FPS Control section.
		SetBool("savegame.mod.progdest.FPS_DynLights", false);	
		SetBool("savegame.mod.progdest.Tog_SDF", true);
		SetBool("savegame.mod.progdest.Tog_LFF", true);
		SetBool("savegame.mod.progdest.Tog_DBF", false);
		SetInt("savegame.mod.progdest.FPS_SDF", 9);	
		SetInt("savegame.mod.progdest.FPS_LFF", 169);	
		SetBool("savegame.mod.progdest.FPS_DBF_FPSB", false); -- Set DBF to only trigger when FPS is low.
		SetInt("savegame.mod.progdest.FPS_SDF_agg", 4);	
		SetInt("savegame.mod.progdest.FPS_LFF_agg", 9);	
		SetInt("savegame.mod.progdest.FPS_Targ", 35);
		SetInt("savegame.mod.progdest.FPS_agg", 8);
	end			
	if selection==22 then -- RANGED DELETION
		SetBool("savegame.mod.progdest.Tog_FPSC", true); -- Toggle/Title for FPS Control section.
		SetBool("savegame.mod.progdest.FPS_DynLights", false);	
		SetBool("savegame.mod.progdest.Tog_SDF", true);
		SetBool("savegame.mod.progdest.Tog_LFF", true);
		SetBool("savegame.mod.progdest.Tog_DBF", true);
		SetInt("savegame.mod.progdest.FPS_SDF", 12);	
		SetInt("savegame.mod.progdest.FPS_LFF", 185);	
		SetInt("savegame.mod.progdest.FPS_DBF", 45);
		SetBool("savegame.mod.progdest.FPS_DBF_FPSB", false); -- Set DBF to only trigger when FPS is low.
		SetInt("savegame.mod.progdest.FPS_SDF_agg", 8);	
		SetInt("savegame.mod.progdest.FPS_LFF_agg", 11);	
		SetInt("savegame.mod.progdest.FPS_DBF_agg", 15);
		SetBool("savegame.mod.progdest.FPS_GLOB_agg", false);
		SetInt("savegame.mod.progdest.FPS_GLOB_aggfac", 0);
		SetInt("savegame.mod.progdest.FPS_Targ", 35);
		SetInt("savegame.mod.progdest.FPS_agg", 10);
	end			
	if selection==23 then -- MODERATE DELETION
		SetBool("savegame.mod.progdest.Tog_FPSC", true); -- Toggle/Title for FPS Control section.
		SetBool("savegame.mod.progdest.FPS_DynLights", false);	
		SetBool("savegame.mod.progdest.Tog_SDF", true);
		SetBool("savegame.mod.progdest.Tog_LFF", true);
		SetBool("savegame.mod.progdest.Tog_DBF", true);
		SetInt("savegame.mod.progdest.FPS_SDF", 11);	
		SetInt("savegame.mod.progdest.FPS_LFF", 222);	
		SetInt("savegame.mod.progdest.FPS_DBF", 60);
		SetBool("savegame.mod.progdest.FPS_DBF_FPSB", false); -- Set DBF to only trigger when FPS is low.
		SetInt("savegame.mod.progdest.FPS_SDF_agg", 16);	
		SetInt("savegame.mod.progdest.FPS_LFF_agg", 22);	
		SetInt("savegame.mod.progdest.FPS_DBF_agg", 50);
		SetBool("savegame.mod.progdest.FPS_GLOB_agg", false);
		SetInt("savegame.mod.progdest.FPS_GLOB_aggfac", 0);
		SetInt("savegame.mod.progdest.FPS_Targ", 35);
		SetInt("savegame.mod.progdest.FPS_agg", 10);
	end
	if selection==24 then -- SEVERE DELETION
		SetBool("savegame.mod.progdest.Tog_FPSC", true); -- Toggle/Title for FPS Control section.
		-- FPS Control Section
		SetBool("savegame.mod.progdest.FPS_DynLights", false);	
		SetBool("savegame.mod.progdest.Tog_SDF", true);
		SetBool("savegame.mod.progdest.Tog_LFF", true);
		SetBool("savegame.mod.progdest.Tog_DBF", true);
		SetInt("savegame.mod.progdest.FPS_SDF", 15);	
		SetInt("savegame.mod.progdest.FPS_LFF", 246);	
		SetInt("savegame.mod.progdest.FPS_DBF", 40);
		SetBool("savegame.mod.progdest.FPS_DBF_FPSB", false); -- Set DBF to only trigger when FPS is low.
		SetInt("savegame.mod.progdest.FPS_SDF_agg", 35);	
		SetInt("savegame.mod.progdest.FPS_LFF_agg", 35);	
		SetInt("savegame.mod.progdest.FPS_DBF_agg", 35);
		SetBool("savegame.mod.progdest.FPS_GLOB_agg", true);
		SetInt("savegame.mod.progdest.FPS_GLOB_aggfac", 35);
		SetInt("savegame.mod.progdest.FPS_Targ", 40);
		SetInt("savegame.mod.progdest.FPS_agg", 35);
	end		
	if selection==23 then -- DESBRIS B GONE!
		SetBool("savegame.mod.progdest.Tog_FPSC", true); -- Toggle/Title for FPS Control section.
		SetBool("savegame.mod.progdest.FPS_DynLights", false);	
		SetBool("savegame.mod.progdest.Tog_SDF", true);
		SetBool("savegame.mod.progdest.Tog_LFF", true);
		SetBool("savegame.mod.progdest.Tog_DBF", true);
		SetInt("savegame.mod.progdest.FPS_SDF", 15);	
		SetInt("savegame.mod.progdest.FPS_LFF", 246);	
		SetInt("savegame.mod.progdest.FPS_DBF", 40);
		SetBool("savegame.mod.progdest.FPS_DBF_FPSB", false); -- Set DBF to only trigger when FPS is low.
		SetInt("savegame.mod.progdest.FPS_SDF_agg", 100);	
		SetInt("savegame.mod.progdest.FPS_LFF_agg", 100);	
		SetInt("savegame.mod.progdest.FPS_DBF_agg", 100);
		SetBool("savegame.mod.progdest.FPS_GLOB_agg", true);
		SetInt("savegame.mod.progdest.FPS_GLOB_aggfac", 100);
		SetInt("savegame.mod.progdest.FPS_Targ", 35);
		SetInt("savegame.mod.progdest.FPS_agg", 100);
	end			

end

