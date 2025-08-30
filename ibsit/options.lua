function default()
	SetInt("savegame.mod.dust_amt", 50)
	SetInt("savegame.mod.wood_size", 100)
	SetInt("savegame.mod.stone_size", 75)
	SetInt("savegame.mod.metal_size", 50)
	SetInt("savegame.mod.momentum", 12)
	SetBool("savegame.mod.vehicle", false)
	SetBool("savegame.mod.joint", false)
	SetBool("savegame.mod.protection", false)
end

function init()
	if not HasKey("savegame.mod") then
		default()
	end
end

function optionsSlider(key, min, max, cap)
	UiPush();
		UiTranslate(0, -8);
		local value = (GetInt(key) - min) / (max - min);
		local width = 100;
		UiRect(width * (cap / max), 3);
		UiAlign("center middle");
		value = UiSlider("ui/common/dot.png", "x", value * width, 0, width * (cap / max)) / width;
		value = math.floor(value * (max - min) + min);
		SetInt(key, value);
	UiPop();
	return value;
end

function draw()
	UiTranslate(UiCenter(), 150)
	UiAlign("center middle")

	--Title
	UiFont("bold.ttf", 48)
	UiText("Options")
	
	--Draw buttons
	UiTranslate(0, 80)
	UiFont("regular.ttf", 26)
	UiPush();
		UiTranslate(-100, 0);
		UiText("Dust amount");
		UiAlign("left");
		UiTranslate(130, 8);
		local value = optionsSlider("savegame.mod.dust_amt", 0, 100, 100);
		UiTranslate(120, 0);
		UiText(value);
	UiPop();
	
	--slider
	UiPush();
		UiTranslate(0, 60);
		UiText("Material damage, Set to 0 to disable")
	UiPop();
	
	UiPush();
		UiTranslate(-100, 100);
		UiText("Soft Material Damage");
		UiAlign("left");
		UiTranslate(130, 8);
		local value = optionsSlider("savegame.mod.wood_size", 0, 200, 200);
		UiTranslate(120, 0);
		UiText(value);
	UiPop();
	
	UiPush();
		UiTranslate(-100, 130);
		UiText("Medium Material Damage");
		UiAlign("left");
		UiTranslate(130, 8);
		local value = optionsSlider("savegame.mod.stone_size", 0, 200, GetInt("savegame.mod.wood_size"));
		UiTranslate(120, 0);
		UiText(value);
	UiPop();
	
	UiPush();
		UiTranslate(-100, 160);
		UiText("Hard Material Damage");
		UiAlign("left");
		UiTranslate(130, 8);
		local value = optionsSlider("savegame.mod.metal_size", 0, 200, GetInt("savegame.mod.stone_size"));
		UiTranslate(120, 0);
		UiText(value);
	UiPop();

	UiPush();
		UiTranslate(0, 220);
		UiText("Threshold for momentum, lower value means more damage\nWarning! Low value may cause massive chain reaction!")
	UiPop();

	UiPush();
		UiTranslate(-100, 260);
		UiText("Momentum threshold");
		UiAlign("left");
		UiTranslate(130, 8);
		local value = optionsSlider("savegame.mod.momentum", 0, 20, 20);
		UiTranslate(120, 0);
		UiText(value);
	UiPop();

	UiPush();
		UiTranslate(0, 300);
		UiText("Should collapse work on vehicles?")
	UiPop();

	UiTranslate(0, 340)
	UiFont("regular.ttf", 26)
	UiButtonImageBox("ui/common/box-outline-6.png", 6, 6)
	UiPush()
		UiTranslate(-110, 0)
		if GetBool("savegame.mod.vehicle") then
			UiPush()
				UiColor(0.5, 1, 0.5, 0.2)
				UiImageBox("ui/common/box-solid-6.png", 200, 40, 6, 6)
			UiPop()
		end
		if UiTextButton("Yup", 200, 40) then
			SetBool("savegame.mod.vehicle", true)
		end
		UiTranslate(220, 0)
		if not GetBool("savegame.mod.vehicle") then
			UiPush()
				UiColor(0.5, 1, 0.5, 0.2)
				UiImageBox("ui/common/box-solid-6.png", 200, 40, 6, 6)
			UiPop()
		end
		if UiTextButton("Nope", 200, 40) then
			SetBool("savegame.mod.vehicle", false)
		end
	UiPop();
	
	UiPush();
		UiTranslate(0, 50);
		UiText("[WIP]Should collapse work on excluded stuff in other mods?")
	UiPop();

	UiTranslate(0, 90)
	UiFont("regular.ttf", 26)
	UiButtonImageBox("ui/common/box-outline-6.png", 6, 6)
	UiPush()
		UiTranslate(-110, 0)
		if GetBool("savegame.mod.protection") then
			UiPush()
				UiColor(0.5, 1, 0.5, 0.2)
				UiImageBox("ui/common/box-solid-6.png", 200, 40, 6, 6)
			UiPop()
		end
		if UiTextButton("Yes", 200, 40) then
			SetBool("savegame.mod.protection", true)
		end
		UiTranslate(220, 0)
		if not GetBool("savegame.mod.protection") then
			UiPush()
				UiColor(0.5, 1, 0.5, 0.2)
				UiImageBox("ui/common/box-solid-6.png", 200, 40, 6, 6)
			UiPop()
		end
		if UiTextButton("No", 200, 40) then
			SetBool("savegame.mod.protection", false)
		end
	UiPop()

	UiPush();
	UiTranslate(0, 50);
	UiText("Should collapse work on jointed things, such as doors/elevators?")
	UiPop();

	UiTranslate(0, 90)
	UiFont("regular.ttf", 26)
	UiButtonImageBox("ui/common/box-outline-6.png", 6, 6)
	UiPush()
		UiTranslate(-110, 0)
		if GetBool("savegame.mod.joint") then
			UiPush()
				UiColor(0.5, 1, 0.5, 0.2)
				UiImageBox("ui/common/box-solid-6.png", 200, 40, 6, 6)
			UiPop()
		end
		if UiTextButton("Yes", 200, 40) then
			SetBool("savegame.mod.joint", true)
		end
		UiTranslate(220, 0)
		if not GetBool("savegame.mod.joint") then
			UiPush()
				UiColor(0.5, 1, 0.5, 0.2)
				UiImageBox("ui/common/box-solid-6.png", 200, 40, 6, 6)
			UiPop()
		end
		if UiTextButton("No", 200, 40) then
			SetBool("savegame.mod.joint", false)
		end
	UiPop()
	
	UiTranslate(0, 100)
	if UiTextButton("Reset to default", 200, 40) then
		default()
	end
	
	UiTranslate(0, 50)
	if UiTextButton("Close", 200, 40) then
		Menu()
	end
end
