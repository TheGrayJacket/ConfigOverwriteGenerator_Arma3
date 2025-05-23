// === USER CONFIG (Minimal Input Required) ===
COG_itemCategory = "uniform"; // "uniform", "backpack"
COG_attributePaths = [[["ItemInfo", true], "containerClass"], [["ItemInfo", true], "mass"]];
COG_finalValues = ["Supply80", 40];
COG_valueSetTypes = ["raiseTo", "lowerTo"];

// === ADDITIONAL FILTERING ===
COG_exceptions = ["Uniform_Base"];
COG_customFilter = {
    // Must return boolean. `_x` refers to the config entry (e.g. configFile >> CfgWeapons >> className)
    true // Replace with your custom condition
};

// === DEBUGGING OPTIONS ===
COG_debugLog = true;
COG_debugLimit = true;
private _skipXLoops = 400;
private _displayXLoops = 3;

COG_supportedTypes = [
    ["uniform", ["CfgWeapons", { getNumber (_x >> "ItemInfo" >> "type") == 801 }]],
    ["backpack", ["CfgVehicles", { getText (_x >> "vehicleClass") == "Backpacks" }]]
];

// === VALIDATION ===
if ((count COG_attributePaths != count COG_finalValues) ||
    (count COG_attributePaths != count COG_valueSetTypes)) exitWith {
    diag_log "[ERROR] COG: Config arrays mismatched! Check COG_attributePaths/COG_finalValues/COG_valueSetTypes.";
};

// === INIT ===
private _output = [];

// === MAIN ===
private _cfgMeta = COG_supportedTypes select { (_x#0) == toLower COG_itemCategory };
if ((count _cfgMeta) == 0) exitWith { diag_log format ["[ERROR] Unsupported COG_itemCategory: %1", COG_itemCategory]; };

private _cfgClass = (_cfgMeta#0)#1#0;
if (_COG_debugLog) then { diag_log format ["[DEBUG] _cfgClass: %1", _cfgClass]};
private _cfgFilter = (_cfgMeta#0)#1#1;
if (_COG_debugLog) then { diag_log format ["[DEBUG] _cfgFilter: %1", _cfgFilter]};
private _cfgEntries = "true" configClasses (configFile >> _cfgClass);
if (_COG_debugLog) then { diag_log format ["[DEBUG] _cfgEntries: %1", _cfgEntries]};

private _shouldSkip = {
    params ["_classCfg", "_className"];
    if (_className in COG_exceptions) exitWith { true };
    if (!(_classCfg call _cfgFilter)) exitWith { true };
    if (!isNil "COG_customFilter" && {!(_classCfg call COG_customFilter)}) exitWith { true };
    false
};

private _adjustValue = {
    params ["_current", "_desired", "_mode"];
    _mode = toLower _mode;
    switch true do {
        case (typeName _desired == "STRING"): { _desired };
        case (_mode == "raiseto" && {_current < _desired}): { _desired };
        case (_mode == "lowerto" && {_current > _desired}): { _desired };
        case (_mode == "setto"): { _desired };
        default { _current };
    }
};

private _generateAttributePatch = {
    params ["_className", "_parent", "_cfgClass"];
    private _attributes = [];

    for "_i" from 0 to (count COG_finalValues - 1) do {
        private _path = COG_attributePaths#_i;
        private _desired = COG_finalValues#_i;
        private _mode = COG_valueSetTypes#_i;

        private _cfgPath = configFile >> _cfgClass >> _className;
        {
            private _seg = _x;
            private _segName = if (_seg isEqualType []) then { _seg#0 } else { _seg };
            _cfgPath = _cfgPath >> _segName;
        } forEach _path;

        if (isNull _cfgPath) exitWith {};

        private _current = switch (typeName _desired) do {
            case "STRING": { getText _cfgPath };
            case "SCALAR": { getNumber _cfgPath };
            default { nil };
        };

        private _final = [_current, _desired, _mode] call _adjustValue;
        private _pathDescriptor = +_path;
        private _attributeName = _pathDescriptor deleteAt ((count _pathDescriptor) - 1);

        if ((count _pathDescriptor) == 0) then {
            _attributes pushBack [_attributeName, _final];
        } else {
            _attributes pushBack [_pathDescriptor, _attributeName, _final];
        };
    };
    [_className, _parent, _attributes]
};

{
    private _idx = _forEachIndex;
    if (COG_debugLimit && {_idx < _skipXLoops}) then { continue };
    if (COG_debugLimit && {_idx >= _skipXLoops + _displayXLoops}) exitWith {};

    private _classCfg = _x;
    private _className = configName _classCfg;

    if ([_classCfg, _className] call _shouldSkip) then { continue };

    private _parent = configName (inheritsFrom _classCfg);
    private _patch = [_className, _parent, _cfgClass] call _generateAttributePatch;
    _output pushBack _patch;
} forEach _cfgEntries;

diag_log _output;
