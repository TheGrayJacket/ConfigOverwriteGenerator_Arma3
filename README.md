# ConfigOverrideGenerator (Arma 3)

**ConfigOverrideGenerator** is a script-based tool for **Arma 3** modders and mission makers. It generates class-based attribute override instructions for config files, making it easier to mass-modify parameters like `containerClass`, `mass`, and others on uniforms, backpacks, vests, and more.

---

## 💡 Features

- Scans game config entries (`CfgWeapons`, `CfgVehicles`, etc.)
- Filters classes based on type (e.g. uniforms, backpacks, vests)
- Compares attribute values (e.g. container capacity, mass)
- Automatically generates override instructions
- Fully customizable via user-friendly settings
- Designed for compatibility with Python post-processing

---

## 🚀 Usage

1. Start Arma 3 with the desired set of mods (so you can find objects added by mods).
2. Go to the Editor (any map, recommended 'Virtual Reality") and open the Config Viewer.
3. Find an example of the item type you want to adjust:
   - `CfgVehicles`: characters, backpacks, vehicles, ammoboxes, ground holders
   - `CfgWeapons`: weapons, accessories, headgear, uniforms, vests
4. Refer to the [Arma 3 Characters & Gear Encoding Guide](https://community.bistudio.com/wiki/Arma_3:_Characters_And_Gear_Encoding_Guide#Uniform_Configuration) to understand class inheritance.
5. Download, unpack and drop this project into your Arma 3 mission folder (default path: C:\Users\<user>\Documents\Arma 3 - Other Profiles\<profile>\missions )
6. Edit `config.cpp` located in the project file (mentioned in 5.) to configure parameters.
7. Open 'ConfigOverrideGenerator' mission in Editor (if you can't see it, restart Arma) <br/>

![ConfigOverrideGenerator](https://drive.usercontent.google.com/download?id=1-pfGO6jN4Er6m6Fhsy3NVGe5TTp4HJiH)<br/>
8. Right click anywhere on the ground (in editor) and select "Play from here".<br/>
 
![ConfigOverrideGenerator](https://drive.usercontent.google.com/download?id=1-cXM53bmFRPJD8dB16_oUUVD6fZ1fswF)<br/>
9. Open 'output.txt' in 'Arma 3 - Other Profiles\<profile>\missions\ConfigOverrideGenerator.VR'
10. Paste the clipboard (CTRL+V)
	- If clipboard is empty, go back to editor, press ESC, run `[ ] execVM "init.sqf"` in the debug console and try pasting to 'output.txt' again.<br/>
 
![ConfigOverrideGenerator](https://drive.usercontent.google.com/download?id=1-ZCoZohJ06I2iEGPiDZJ5PVLmvV6Vp1A)<br/>
	- If clibboard is still empty, enable debugging options in 'config.cpp', run `[ ] execVM "init.sqf"` again and then check your latest RPT for errors (default path for client RPT storage: C:\Users\<user>\AppData\Local\Arma 3 )
11. Once you have your 'output.txt' set up, run 'convertToCode.exe' (antiviruses don't like this file. It's safe.)
12. You should now have a file with a complete code that you can use to override original values. All you need to do is to put it in your mod (and make sure your mod is loaded after all other mods that it can affect)


TROUBLESHOOTING: Make sure all lines in 'output.txt' are in similar format (eg. a rogue " can find its way to either beginning or end of the file)

---

## ⚙️ Configuration

Edit the following values in `config.cpp`:

```sqf

// Object category to target: "uniform", "backpack", etc.
COG_itemCategory = "uniform";

// Array of config paths leading to attributes to modify
COG_attributePaths = [[["ItemInfo", true], "containerClass"], [["ItemInfo", true], "mass"]];

// COG_attributePaths Format: Each path element starts with either
//   ["ClassName", requiresParentClass?] OR
//   ["attributeName"] (as the final leaf node)
//
// Example:
//   [["ItemInfo", true], "mass"]  --> requires class ItemInfo with parent
//   [["ItemInfo", true], ["HitpointsProtectionInfo", false], ["Body", false], "armor"] --> nested under 3 classes, 1 parentClass required

// Target values for each corresponding attribute
COG_finalValues = ["Supply80", 40];

// Behavior for modifying values: "raiseTo", "lowerTo", or "setTo"
COG_valueSetTypes = ["raiseTo", "lowerTo"];

// Note on COG_valueSetTypes:
// If you want to raise the value only for classnames where value it is lower than your desired value (COG_finalValues), use: "raiseTo"
// If you want to lower the value only for classnames where value it is higher than your desired value (COG_finalValues), use: "lowerTo"
// If you want to set value of classname for any classname, use: "setTo"
// This does not work for strings (defaults to "setTo"), but if a string is a combination of text and number (eg. "Supply80") it should work.

```

> You can output multiple elements when arrays are set up properly - make sure they are of the same size

---

## 🔍 Additional Filtering

```sqf
// If you want to skip specific objects, add their classnames to this array:
COG_exceptions = ["Uniform_Base"];

// If you want to add a specific filtering (eg. Trucks only, not all vehicles) add the logic in the function below
// WARNING: Custom Filter is provided with object classname under 'configFile >> CfgWeapons/CfgVehicles' and MUST return TRUE
COG_customFilter = {
    true // Replace with your custom condition
};
```

---

## 🐞 Debugging

```sqf
COG_debugLog = true;     // Enable verbose logging via diag_log
COG_debugLimit = true;   // Limit the number of processed classes
COG_skipXLoops = 400;    // Skip initial X loops
COG_displayXLoops = 3;   // Display only X loops (after COG_skipXLoops)
```

---

## 📋 Output Format

The script outputs an array for each matching class:

```sqf
[
  "ClassName",
  "ParentClass",
  [
    ["AttributePath", "AttributeName", FinalValue],
    ...
  ]
]
```

This format is compatible with post-processing tools, such as a Python script that generates final `code.txt` files.

---

## 📌 Planned Improvements

1. Expand support for vehicles, backpacks, and vests (by extending `_supportedTypes`)
2. Create test configs in a `/configs` folder for each supported item type

---

## 🧩 Contributing

Have a filter idea, bug fix, or enhancement suggestion? Feel free to fork and contribute via pull request or open an issue.

---

## 📜 License

This project is open-source and available under the MIT License.
