//fn_shouldSkip.sqf

params ["_classCfg", "_className", "_cfgFilter", "_useCustomFilter"];
if (_className in COG_exceptions) exitWith { true };
if (!(_classCfg call _cfgFilter)) exitWith { true };
if (_useCustomFilter && {!(_classCfg call COG_customFilter)}) exitWith { true };
if (COG_debugLog) then { diag_log format ["[DEBUG] COG: %1 = PASS", _className]};
false
