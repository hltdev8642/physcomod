function default()
	SetInt("savegame.mod.dust_amt", 50)
	SetInt("savegame.mod.wood_size", 100)
	SetInt("savegame.mod.stone_size", 75)
	SetInt("savegame.mod.metal_size", 50)
	SetInt("savegame.mod.mass", 8)
	SetInt("savegame.mod.distance", 4)
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
	UiTranslate(UiCenter(), 200)
	UiAlign("center middle")

	--Title
	UiFont("bold.ttf", 48)
	UiText("Options")
	
	--Draw buttons
	UiTranslate(0, 180)
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
		UiTranslate(0, 90);
		UiText("Material damage, Set to 0 to disable")
	UiPop();
	
	UiPush();
		UiTranslate(-100, 120);
		UiText("Soft Material Damage");
		UiAlign("left");
		UiTranslate(130, 8);
		local value = optionsSlider("savegame.mod.wood_size", 0, 200, 200);
		UiTranslate(120, 0);
		UiText(value);
	UiPop();
	
	UiPush();
		UiTranslate(-100, 150);
		UiText("Medium Material Damage");
		UiAlign("left");
		UiTranslate(130, 8);
		local value = optionsSlider("savegame.mod.stone_size", 0, 200, GetInt("savegame.mod.wood_size"));
		UiTranslate(120, 0);
		UiText(value);
	UiPop();
	
	UiPush();
		UiTranslate(-100, 180);
		UiText("Hard Material Damage");
		UiAlign("left");
		UiTranslate(130, 8);
		local value = optionsSlider("savegame.mod.metal_size", 0, 200, GetInt("savegame.mod.stone_size"));
		UiTranslate(120, 0);
		UiText(value);
	UiPop();

	UiPush();
		UiTranslate(0, 250);
		UiText("Threshold for mass, lower value means more damage\nWarning! Low value may cause massive chain reaction!")
	UiPop();

	UiPush();
		UiTranslate(-100, 300);
		UiText("Mass threshold");
		UiAlign("left");
		UiTranslate(130, 8);
		local value = optionsSlider("savegame.mod.mass", 0, 20, 20);
		UiTranslate(120, 0);
		UiText(value);
	UiPop();

	UiPush();
		UiTranslate(0, 350);
		UiText("Objects must be this far(in meters) before collapsing can happen")
	UiPop();

	UiPush();
		UiTranslate(-100, 380);
		UiText("Fall distance");
		UiAlign("left");
		UiTranslate(130, 8);
		local value = optionsSlider("savegame.mod.distance", 0, 16, 16);
		UiTranslate(120, 0);
		UiText(value);
	UiPop();
	
	UiTranslate(0, 450)
	if UiTextButton("Reset to default", 200, 40) then
		default()
	end
	
	UiTranslate(0, 50)
	if UiTextButton("Close", 200, 40) then
		Menu()
	end
end
