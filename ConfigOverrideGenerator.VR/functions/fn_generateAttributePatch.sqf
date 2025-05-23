////fn_generateAttributePatch.sqf

params ["_className", "_parent", "_cfgClass"];
private _attributes = [];

for "_i" from 0 to (count COG_finalValues - 1) do {
	if (COG_debugLog) then { diag_log format ["[DEBUG] Checking %1 index array in this loop: %2",_i, COG_attributePaths#_i];  }; 

    private _path = COG_attributePaths#_i;
    private _desired = COG_finalValues#_i;
    private _mode = COG_valueSetTypes#_i;
	
	if (COG_debugLog) then { diag_log format ["[DEBUG] Desired value (_desired): %1", _desired];  };
	
    private _cfgPath = configFile >> _cfgClass >> _className;
    {
        private _seg = _x;
        private _segName = if (_seg isEqualType []) then { _seg#0 } else { _seg };
        _cfgPath = _cfgPath >> _segName;
		if (COG_debugLog) then { diag_log format ["[DEBUG] Added segment (_segName) to Complete Path: %1", _segName];  }; 
    } forEach _path;
	if (COG_debugLog) then { diag_log format ["[DEBUG] Full Path: %1", _cfgPath];  }; 

	if (isNull _cfgPath) exitWith {
		if (COG_debugLog) then {
			diag_log format ["[ERROR] Null path for class %1, attrPath %2", _className, COG_attributePaths select _i];
		};
	};
	
	private _desiredText1 = "";
	private _desiredText2 = -1;

	private _splitDesired = _desired call COG_fnc_splitTextWithNumber;
	if (COG_debugLog) then { diag_log format ["[DEBUG] [SplitText] fnc call result for Desired value (_desired): %1", _splitDesired];  }; 
	if (_splitDesired isEqualType [] && {count _splitDesired == 2}) then {
		_desiredText1 = _splitDesired#0;
		_desiredText2 = _splitDesired#1;
		_desired = _desiredText2;
	};
	
	private _cfgPathText = getText _cfgPath;
	
	if (COG_debugLog) then {
		if (_cfgPathText isNotEqualTo "") then {
			diag_log format ["[DEBUG] Current Value (_cfgPathText): %1", _cfgPathText];
		} else {
			private _cfgPathNumber = getNumber _cfgPath;
			if (!isNil "_cfgPathNumber" && {_cfgPathNumber != 0 || {getText _cfgPath == ""}}) then {
				diag_log format ["[DEBUG] Full Text Value (_cfgPathText) is NOT text, is a number: %1", _cfgPathNumber];
			} else {
				diag_log "[DEBUG] Full Text Value (_cfgPathText) is neither a valid string nor a number.";
			};
		};
	};
	
	private _currentText1 = "";
	private _currentText2 = -1;
	private _current = -1;
	
	private _splitCurrent = _cfgPathText call COG_fnc_splitTextWithNumber;
	if (COG_debugLog) then { diag_log format ["[DEBUG] [SplitText] fnc call result for Current value (_cfgPathText): %1", _splitCurrent];  }; 
	
	if (_splitCurrent isEqualType [] && {count _splitCurrent == 2}) then {
		_currentText1 = _splitCurrent#0;
		_currentText2 = _splitCurrent#1;
		_current = _currentText2;
	} else {
		private _valueType = typeName _desired;
		_current = switch (_valueType) do {
			case "STRING": { _cfgPathText };
			case "SCALAR": { getNumber _cfgPath };
			default { nil };
		};
	};

	if (COG_debugLog) then {diag_log format ["[DEBUG] Current Value (_current): %1", _current];};

	if (COG_debugLog) then { diag_log format ["[DEBUG] TypeName of Desired value (_desired): %1", typeName _desired];  }; 

	if (COG_debugLog) then { diag_log format ["[DEBUG] Value Set Mode (_mode): %1", _mode];  }; 

    private _final = [_current, _desired, _mode] call COG_fnc_adjustValue;
	
	if (!isNil "_currentText1" && !isNil "_currentText2" && {_currentText1 == _desiredText1}) then {
		_final = [_desiredText1, _final] call COG_fnc_joinTextWithNumber;
	};
	
	if (COG_debugLog) then { diag_log format ["[DEBUG] Final adjusted value (_final): %1", _final]; };
	
    private _pathDescriptor = +_path;
	
	if ((count _pathDescriptor) == 0) exitWith {
		diag_log format ["[ERROR] Empty COG_attributePaths at index %1: %2", _i, _pathDescriptor];
	};
	
	private _attributeName = _pathDescriptor deleteAt ((count _pathDescriptor) - 1);


    if ((count _pathDescriptor) == 0) then {
        _attributes pushBack [_attributeName, _final];
		if (COG_debugLog) then { diag_log format ["[DEBUG] Root pushBack: %1", [_attributeName, _final]]; };
    } else {
        {
            private _pathStep = _x;
            private _stepIndex = _forEachIndex;

            private _stepName = _pathStep#0;
            private _needsParentClass = _pathStep#1;

            if (_needsParentClass isEqualTo true) then {
				if (COG_debugLog) then {
					diag_log format ["[DEBUG] Parent Class needed for %1", _stepName];
				};
				
                private _currentStep = configFile >> _cfgClass >> _className;
				
                for "_j" from 0 to _stepIndex do {
                    _currentStep = _currentStep >> (_pathDescriptor select _j)#0;
                };

                if (!isClass _currentStep) exitWith {
                    _currentStep = configNull;
                    diag_log format ["[ERROR] Missing config: %1", COG_attributePaths#_i#_k];
                };

                private _parentClass = configName (inheritsFrom _currentStep);
				
				if (COG_debugLog) then {
					diag_log format ["[DEBUG] Parent Class: %1", _parentClass];
				};
				
                (_pathDescriptor select _stepIndex) set [1, _parentClass];
            } else {
                _pathDescriptor set [_stepIndex, [ _stepName ]];
            }
        } forEach _pathDescriptor;

        _attributes pushBack [_pathDescriptor, _attributeName, _final];
    };
};

[_className, _parent, _attributes]