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

1. Start Arma 3 with the desired mods.
2. Go to the Editor and open the Config Viewer.
3. Find an example of the item type you want to adjust:
   - `CfgVehicles`: characters, backpacks, vehicles, ammoboxes, ground holders
   - `CfgWeapons`: weapons, accessories, headgear, uniforms, vests
4. Refer to the [Arma 3 Characters & Gear Encoding Guide](https://community.bistudio.com/wiki/Arma_3:_Characters_And_Gear_Encoding_Guide#Uniform_Configuration) to understand class inheritance.
5. Drop this project into your Arma 3 mission folder.
6. Edit `init.sqf` to configure parameters.
7. Run the scenario or use `[ ] execVM "init.sqf"` from the debug console.
8. Copy the output from the clipboard or retrieve it from the log.

---

## ⚙️ Configuration

Edit the following values in `init.sqf`:

\`\`\`sqf
// Type of object to adjust
COG_itemCategory = "uniform"; // "uniform", "backpack", etc.

// Config path to attributes (must match COG_itemCategory)
COG_attributePaths = [[["ItemInfo", true], "containerClass"], [["ItemInfo", true], "mass"]];

// Target values for each attribute
COG_finalValues = ["Supply80", 40];

// Adjustment method for each attribute
COG_valueSetTypes = ["raiseTo", "lowerTo"]; // "raiseTo", "lowerTo", "setTo"
\`\`\`

Each config path element is either:
- `["ClassName", requiresParentClass?]`
- `"attributeName"` (as the final leaf)

Examples:

\`\`\`sqf
[["ItemInfo", true], "mass"]
[["HitpointsProtectionInfo", false], ["Body", false], "armor"]
\`\`\`

> You can output multiple elements when arrays are of the same size.

---

## 🔍 Additional Filtering

\`\`\`sqf
// Skip specific classnames
COG_exceptions = ["Uniform_Base"];

// Add custom filter logic (must return TRUE or FALSE)
COG_customFilter = {
    true // Replace with your filtering condition
};
\`\`\`

---

## 🐞 Debugging

\`\`\`sqf
COG_debugLog = true;     // Enable verbose logging via diag_log
COG_debugLimit = true;   // Limit the number of processed classes
COG_skipXLoops = 400;    // Skip initial X loops
COG_displayXLoops = 3;   // Display every X loops
\`\`\`

---

## 📋 Output Format

The script outputs an array for each matching class:

\`\`\`sqf
[
  "ClassName",
  "ParentClass",
  [
    ["AttributePath", "AttributeName", FinalValue],
    ...
  ]
]
\`\`\`

This format is compatible with post-processing tools, such as a Python script that generates final `config.cpp` files.

---

## 📌 Planned Improvements

1. Expand support for vehicles, backpacks, and vests (by extending `_supportedTypes`)
2. Build a standalone executable to convert `output.txt` into `code.txt`
3. Refactor `config.cpp`: move inline comments to this README and add step-by-step instructions with screenshots
4. Create test configs in a `/configs` folder for each supported item type

---

## 🧩 Contributing

Have a filter idea, bug fix, or enhancement suggestion? Feel free to fork and contribute via pull request or open an issue.

---

## 📜 License

This project is open-source and available under the MIT License.


## 🛠️ Variable Reference

This section provides a quick overview of all configurable variables used in `init.sqf`.

```sqf
// Object category to target: "uniform", "backpack", etc.
COG_itemCategory = "uniform";

// Array of config paths leading to attributes to modify
COG_attributePaths = [[["ItemInfo", true], "containerClass"], [["ItemInfo", true], "mass"]];

// Target values for each corresponding attribute
COG_finalValues = ["Supply80", 40];

// Behavior for modifying values: "raiseTo", "lowerTo", or "setTo"
COG_valueSetTypes = ["raiseTo", "lowerTo"];

// List of classnames to ignore
COG_exceptions = ["Uniform_Base"];

// Custom filter function - must return true/false based on classname logic
COG_customFilter = {
    true
};

// Debugging options
COG_debugLog = true;       // Enable detailed logs
COG_debugLimit = true;     // Limit how many entries are processed
COG_skipXLoops = 400;      // Skip first X entries (for faster testing)
COG_displayXLoops = 3;     // Show a log every X entries
```
