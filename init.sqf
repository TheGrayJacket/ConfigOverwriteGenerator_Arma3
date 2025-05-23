private _configStr = preprocessFileLineNumbers "config.cpp";
call compile _configStr;

_supportedTypes = [
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
private _cfgMeta = _supportedTypes select { (_x#0) == toLower COG_itemCategory };
if ((count _cfgMeta) == 0) exitWith { diag_log format ["[ERROR] Unsupported COG_itemCategory: %1", COG_itemCategory]; };
if (COG_debugLog) then { diag_log format ["COG_itemCategory (_cfgMeta): %1", _cfgMeta];};
						 

private _cfgClass = (_cfgMeta#0)#1#0;
private _cfgFilter = (_cfgMeta#0)#1#1;
private _cfgEntries = "true" configClasses (configFile >> _cfgClass);
private _useCustomFilter = false;

if (!isNil "COG_customFilter") then {
	if (typeName COG_customFilter != "CODE") then {
		diag_log "⚠️ [ConfigOverrideGenerator] COG_customFilter is defined but not a code block. It will be ignored.";
	} else {
		private _test = try { true call COG_customFilter } catch { diag_log "⚠️ [ConfigOverrideGenerator] COG_customFilter failed test call. It will be ignored."; false };
		if (_test isEqualType true) then {
			_useCustomFilter = true;
		} else {
			diag_log "⚠️ [ConfigOverrideGenerator] COG_customFilter did not return a boolean value. It will be ignored.";
		};
	};
};

{
    private _idx = _forEachIndex;
    if (COG_debugLimit && {_idx < COG_skipXLoops}) then { continue };
    if (COG_debugLimit && {_idx >= COG_skipXLoops + COG_displayXLoops}) exitWith {};
	if (COG_debugLog) then { diag_log "====================================";};
	if (COG_debugLog) then { diag_log format ["[DEBUG] Loop %1 started",_forEachIndex + 1];};

    private _classCfg = _x;
    private _className = configName _classCfg;

    if ([_classCfg, _className, _cfgFilter, _useCustomFilter] call COG_fnc_shouldSkip) then { continue };
    private _parent = configName (inheritsFrom _classCfg);
    private _patch = [_className, _parent, _cfgClass] call COG_fnc_generateAttributePatch;

	if (COG_debugLog) then { diag_log format ["Loop %1 output: %2 | %3 | %4", _forEachIndex + 1, _patch#0, _patch#1, _patch#2];};

    _output pushBack _patch;
	
	if (COG_debugLog) then { diag_log format ["Iteration %1: %2", _forEachIndex + 1, _x];};
	if (COG_debugLog) then { diag_log format ["[DEBUG] Loop %1 finished",_forEachIndex + 1];};
} forEach _cfgEntries;


if ((count _output) == 0) then {
	private _msg = "[INFO] COG: No classnames matched the filters. Check config values or input data.";
	copyToClipboard _msg;
	diag_log _msg;
} else {
	private _addNewLines = _output joinString endl;
	private _msg = format ["STEP 1 OUTPUT:%1%2", endl, _addNewLines];
	copyToClipboard _msg;
	diag_log _msg;
};