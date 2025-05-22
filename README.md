# ConfigOverrideGenerator (Arma 3)

**ConfigOverrideGenerator** is a script-based tool for **Arma 3** modders and mission makers. It generates class-based attribute override instructions for config files, making it easier to mass-modify attributes like `containerClass` or `mass` on uniforms, backpacks, and other gear items.

## 💡 Features

- Scans game config entries (`CfgWeapons`, `CfgVehicles`, etc.)
- Filters classes based on type (e.g. uniforms or backpacks)
- Compares attribute values (e.g. container capacity, mass)
- Automatically generates override instructions
- Fully customizable via user-friendly settings
- Designed for compatibility with Python post-processing

## 🚀 Usage

1. Drop the project into your Arma 3 mission folder.
2. Edit the `init.sqf` to configure desired parameters.
3. Run the scenario or execute `[ ] execVM "init.sqf"` from debug console.
4. Use the output from the clipboard (via `copyToClipboard`) or log.

## ⚙️ Customization

You can edit the following configuration values in `init.sqf`:

- `COG_itemCategory`: `"uniform"` or `"backpack"`
- `COG_attributePaths`: Array of config paths to modify
- `COG_finalValues`: Target values for each attribute
- `COG_valueSetTypes`: `"raiseTo"`, `"lowerTo"`, or `"setTo"`

You can also plug in your own filter logic using `COG_customFilter`.

## 🐞 Debugging

- Set `COG_debugLog = true` to enable verbose output via `diag_log`.
- Use `COG_debugLimit` to restrict how many classes are processed.

## 📋 Output Format

The script generates an array of entries like this:

```sqf
[
  "ClassName",
  "ParentClass",
  [
    ["AttributePath", "AttributeName", FinalValue],
    ...
  ]
]
