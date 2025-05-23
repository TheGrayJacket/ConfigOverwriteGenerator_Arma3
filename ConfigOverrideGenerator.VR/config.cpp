//CONFIG

// This code when passed through an Arma 3 client will generate the list of classnames that pass the filters specified in this file. Each classname will have assigned specific parameters that will be used in <another step>.

//Instructions:
// 1. Start Arma 3 with desired mods.
// 2. Go to Editor
// 3. Open Config Viewer
// 4. Find any example of an item type you want to adjust. Please note:
// CfgVehicles – characters, backpacks, vehicles, ammoboxes, ground holders
// CfgWeapons – weapons, weapon accessories, headgear, uniforms, vests
// Refer to this page in the wiki to determine which classes need to be inherited
// https://community.bistudio.com/wiki/Arma_3:_Characters_And_Gear_Encoding_Guide#Uniform_Configuration

// Format: Each path element is either
//   ["ClassName", requiresParentClass?] OR
//   "attributeName" (as the final leaf node)
//
// Example:
//   [["ItemInfo", true], "mass"]  --> requires class ItemInfo with parent
//   [["HitpointsProtectionInfo", false], ["Body", false], "armor"] --> nested under 2 classes, no parentClass required


// === USER CONFIG (Minimal Input Required) ===

// You can output multiple elements when arrays are set up properly - make sure they are of the same size

// specify the type of an object you wish to adjust. Applicable strings:
// uniform
COG_itemCategory = "uniform"; // "uniform", "backpack"

// Type the name of the attribute(s) - please note that they should be of the same COG_itemCategory
// Set this array to reflect config path (after classname) which leads to _targetAttr
// eg. private _cfgPath = [["ItemInfo", "containerClass"], ["ItemInfo", "mass"]];
COG_attributePaths = [[["ItemInfo", true], "containerClass"], [["ItemInfo", true], "mass"]];
// Set the desired value
COG_finalValues = ["Supply80", 40];
// Specify the adjustment:
// If you want to raise the value only for classnames where value it is lower than your desired value (COG_finalValues), use: "raiseTo"
// If you want to lower the value only for classnames where value it is higher than your desired value (COG_finalValues), use: "lowerTo"
// If you want to set value of classname for any classname, use: "setTo"
// This does not work for strings (defaults to "setTo"), but if a string is a combination of text and number (eg. "Supply80") it should work.
COG_valueSetTypes = ["raiseTo", "lowerTo"];  // "raiseTo", "lowerTo", "setTo"

// === ADDITIONAL FILTERING ===
// If you want to skip specific objects, add their classnames to this array:
COG_exceptions = ["Uniform_Base"];
// If you want to add a specific filtering (eg. Trucks only, not all vehicles) add the logic in the function below
// WARNING: Custom Filter is provided with object classname under 'configFile >> CfgWeapons/CfgVehicles' and MUST return TRUE
COG_customFilter = {
    true // Replace with your custom condition
};

// === DEBUGGING OPTIONS ===
COG_debugLog = true;
COG_debugLimit = true;
COG_skipXLoops = 400;
COG_displayXLoops = 3;
// CONFIG END