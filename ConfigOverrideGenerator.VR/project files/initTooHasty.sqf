#include "config.cpp";

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

private _cfgClass = (_cfgMeta#0)#1#0;
private _cfgFilter = (_cfgMeta#0)#1#1;
private _cfgEntries = "true" configClasses (configFile >> _cfgClass);

private _shouldSkip = [_classCfg, _className] call COG_fnc_shouldSkip;

private _adjustValue = [_current, _desired, _mode] call COG_fnc_adjustValue;

private _generateAttributePatch = [_className, _parent, _cfgClass] call COG_fnc_generateAttributePatch;

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

copyToClipboard (_output joinString (toString [10]));

{
    diag_log format ["%1", _x];
} forEach _output;
