package dev_toolbox;

import flixel.util.FlxCollision;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.ui.FlxUIDropDownMenu.FlxUIDropDownHeader;
import sys.FileSystem;
import flixel.FlxSprite;
import flixel.text.FlxText.FlxTextAlign;
import flixel.util.FlxColor;
import flixel.addons.ui.*;
import flixel.FlxG;
import flixel.FlxState;

class ToolboxMain extends MusicBeatState {
    var modName:FlxUIText = null;
    var modDesc:FlxUIText = null;
    var modIcon:FlxSprite = null;
    var selectButton:FlxUIButton = null;

    var nonEditableMods:Array<String> = ["Friday Night Funkin'", "YoshiEngine"];

    var selectedMod:String = "Friday Night Funkin'";

    public override function new(?mod:String) {
        if (mod != null) selectedMod = mod;
        if (!Std.is(FlxG.state, MainMenuState) && !Std.is(FlxG.state, ToolboxHome)) {
            FlxTransitionableState.skipNextTransIn = true;
            FlxTransitionableState.skipNextTransOut = true;
        }
        super();
        CoolUtil.addBG(this);
        var tabs = [
			{name: "main", label: 'Select a mod...'}
		];
        var UI_Main = new FlxUITabMenu(null, tabs, true);
        UI_Main.resize(640, 282);
        UI_Main.screenCenter();
        add(UI_Main);

        
		var tab = new FlxUI(null, UI_Main);
		tab.name = "main";
        
		var label = new FlxUIText(10, 10, 620, "Select a mod to begin, or click on \"Create a new mod\".");

        selectButton = new FlxUIButton(10, 232, "Edit mod...", function() {
            #if toolboxBypass
            #else
            if (nonEditableMods.contains(selectedMod)) return;
            #end
            FlxG.switchState(new ToolboxHome(selectedMod));
        });
        var closeButton = new FlxUIButton(UI_Main.x + UI_Main.width - 23, UI_Main.y + 3, "X", function() {
            FlxG.switchState(new MainMenuState());
        });
        closeButton.color = 0xFFFF4444;
        closeButton.resize(20, 20);
        closeButton.label.color = FlxColor.WHITE;
        add(closeButton);
        var createButton = new FlxUIButton(selectButton.x + selectButton.width + 10, 232, "Create a new mod", function() {
            FlxG.switchState(new NewModWizard());
        });
        createButton.resize(140, 20);
        var deleteMod = new FlxUIButton(createButton.x + createButton.width + 10, 232, "Delete this mod", function() {
            var mName = ModSupport.modConfig[selectedMod].name;
            if (mName == null || mName == "") mName = selectedMod;
            if (nonEditableMods.contains(selectedMod)) {
                openSubState(ToolboxMessage.showMessage("Error", '$mName is an essential mod since the engine relies on it. It can\'t be deleted.\r\nAnd if you\'re curious, deleting it would result in an engine crash.'));
                return;
            }
            openSubState(new ToolboxMessage("Delete a mod", 'Are you sure you want to delete $mName ? This operation cannot be cancelled.', 
            [
                {
                    label: "Yes",
                    onClick: function(t) {
                        try {
                            CoolUtil.deleteFolder('${Paths.getModsFolder()}\\$selectedMod');
                            FileSystem.deleteDirectory('${Paths.getModsFolder()}\\$selectedMod');
                            ModSupport.reloadModsConfig();
                            openSubState(new ToolboxMessage("Success", '$selectedMod was successfully deleted.', [
                                {
                                    label: "OK",
                                    onClick: function(t) {
                                        FlxG.resetState();
                                    }
                                }
                            ]));
                        } catch(e) {
                            openSubState(ToolboxMessage.showMessage("Error", 'Couldn\'t delete $selectedMod.'));
                        }
                    }
                },
                {
                    label: "No",
                    onClick: function(t) {}
                }
            ]
            ));
        });
        deleteMod.resize(100, 20);
        deleteMod.color = 0xFFFF4444;
        deleteMod.label.color = FlxColor.WHITE;

        modName = new FlxUIText(10, label.y + label.height + 10, 620);
        // modName.alignment = FlxTextAlign.CENTER;
        modName.size *= 2;
        modName.text = "Select a mod...";

        modIcon = new FlxUISprite(10, modName.y + modName.height + 10);
        modIcon.antialiasing = true;

        var mods:Array<StrNameLabel> = [];
        var it = ModSupport.modConfig.keys();
        while (it.hasNext()) {
            var k = it.next();
            if (k == null || k == "null") continue;
            var mName = ModSupport.modConfig[k].name;
            if (mName == null || mName == "") mName = k;
            mods.push(new StrNameLabel(k, mName));
        }

        var modDropDown = new FlxUIDropDownMenu(630, 10, mods, function(label:String) {
            selectedMod = label;
            updateModData();
        }, new FlxUIDropDownHeader(250));
        modDropDown.selectedId = "Friday Night Funkin'";
        modDropDown.x -= modDropDown.width;

        modDesc = new FlxUIText(170, modName.y + modName.height + 10, 460, "");
        updateModData();
		tab.add(label);
		tab.add(selectButton);
		tab.add(createButton);
		tab.add(deleteMod);
		tab.add(modName);
		tab.add(modDesc);
		tab.add(modIcon);
		tab.add(modDropDown);
		UI_Main.addGroup(tab);
    }

    public function updateModData() {
        modName.text = ModSupport.modConfig[selectedMod].name != null ? ModSupport.modConfig[selectedMod].name : selectedMod;
        modDesc.text = ModSupport.modConfig[selectedMod].description != null ? ModSupport.modConfig[selectedMod].description : "(No description)";
        if (FileSystem.exists('${Paths.getModsFolder()}\\$selectedMod\\modIcon.png')) {
            modIcon.loadGraphic(Paths.getBitmapOutsideAssets('${Paths.getModsFolder()}\\$selectedMod\\modIcon.png'));
        } else {
            modIcon.loadGraphic(Paths.image("modEmptyIcon", "preload"));
        }
        modIcon.setGraphicSize(150, 150);
        modIcon.updateHitbox();
        
        selectButton.color = nonEditableMods.contains(selectedMod) ? FlxColor.GRAY : FlxColor.WHITE;
    }
}