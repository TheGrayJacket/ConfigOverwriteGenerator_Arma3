// === USER CONFIG (Minimal Input Required) ===  
private _itemCategory = "uniform"; // "uniform", "backpack"
private _targetAttr   = ["containerClass", "mass"]; // Attributes to modify
private _cfgPath      = [["ItemInfo", "containerClass"],["ItemInfo", "mass"]];
private _finalValue   = ["Supply80", 40]; // New values (order1 matches _targetAttr)  
private _valueSetType = ["raiseTo", "lowerTo"]; // "raiseTo", "lowerTo", "equalizeTo"  
private _exceptions   = ["U_B_CombatUniform_mcam"]; // Classes to skip  
private _debugLog     = true; 
private _debugLimit	  = true; 

// COMMENT: To generate code, we need item classname, parent class of classname, _targetAttr, name of directory that contains _targetAttr, parent of  name of directory that contains _targetAttr and _finalValue.
// COMMENT: But in order to determine logic behind _valueSetType, we need to get inside those configs and check those values.
// _itemCategory - attribute naming and directory depends on the category - which is why we need to create separate code for each type of item
// _targetAttr - needed to create code
// _cfgPath - needed to verify current value. But what if the value is a string?, like "Supply80"? Since this is the part that is meant to check values in order to pass them through logic of _valueSetType, let's first verify if a value is a string, and if yes, do something else (and since we can't really apply too much logic to strings, maybe just output them as a comment, eg. containerClass = "Supply80"; // was "Supply100". Hell, let's do that for numerical values as well - it's informative)
// _finalValue - needed to create code
// _valueSetType - as mentioned before, this logic should apply only to numeric values. so there should be an if condition. for strings, it should always behive like equalizeTo - override it no matter the original value.
// _exceptions - nice to have. easy to implement

// === VALIDATION ===  
if (count _targetAttr != count _cfgPath ||
	count _targetAttr != count _finalValue ||
	count _targetAttr != count _valueSetType)
	exitWith {  
    diag_log "[ERROR] COG: Config arrays mismatched! Check _targetAttr/_cfgPath/_finalValue/_valueSetType.";  
};  

// === INIT ===  
private _output = [];
private _cfgClass = "";
private _cfgEntries = [];  // Initialize empty, populate later


if (_debugLog) then { diag_log format ["_itemCategory: %1", _itemCategory];};

switch (toLower _itemCategory) do
{
	case "uniform":
	{
		_cfgClass = "CfgWeapons";
		private _cfgEntries = "true" configClasses (configFile >> _cfgClass);  
		{  
			private _skipXLoops = 315; // Set the amount of skipped iterations (for debugging)  
			if (_debugLimit && _forEachIndex < _skipXLoops) then { continue }; // Skip iterations  
			if (_debugLimit && _forEachIndex >= _skipXLoops + 3) exitWith {}; // Stop after + number iterations  
			if (_debugLog) then { diag_log format ["[DEBUG] Loop %1 started",_forEachIndex + 1];};

			//  == FILTERING == 
			private _className = configName _x;  
			if (_className in _exceptions) then { continue };  
			
			// Check for ItemInfo type
			private _itemInfo = _x >> "ItemInfo";
			if (!isClass _itemInfo) then { continue };

			private _itemType = getNumber (_itemInfo >> "type");
			if (_itemType != 801) then { continue };
			
			//  == FILTERING END == 
			if (_debugLog) then { diag_log format ["[DEBUG] COG: %1 = PASS)", _className]};
			
			//  == IN-LOOP INIT == 
			private _classNameConfig = configFile >> "CfgWeapons" >> _className;
			private _classNameParent = configName (inheritsFrom _classNameConfig);
			private _childClass = [];  
			private _childClassParent = [];
			private _attributes = [];
			//private _newValue = [];
			//  == IN-LOOP INIT END == 

			// Check each attribute  
			for "_i" from 0 to (count _targetAttr - 1) do {  
				
				
				// Reminder: We need the following for this to work: _className, _classNameParent, _childClass[], _childClassParent[], _attribute[], _newValue[]
				// We already got _className and _classNameParent, so
				// _childClass and _childClassParent
				//_childClass set [_i, []];			// Do not use along with _childClass pushBack
				//_childClassParent set [_i, []];	// Do not use along with _childClassParent pushBack

				// Traverse _cfgPath for the current _targetAttr  
				for "_j" from 0 to (count (_cfgPath#_i) - 2) do {  
					private _currentStep = configFile >> "CfgWeapons" >> _className;  
					// Navigate through the path (e.g., ["ItemInfo", "containerClass"])  
					for "_k" from 0 to _j do {  
						_currentStep = _currentStep >> (_cfgPath#_i#_k);  
						if (!isClass _currentStep) exitWith {  
							_currentStep = configNull; // Ensure termination 
							diag_log format ["[ERROR] Missing config: %1", _cfgPath#_i#_k];  
						};  
					};  
					if (isNull _currentStep) then {
						diag_log format ["_currentStep is null! '%1' Exiting loop... ", _currentStep];
						continue;
					}; // Skip if path failed  
					
					// Store class and its parent  
					_childClass pushBack configName _currentStep;  
					_childClassParent pushBack configName (inheritsFrom _currentStep);  
				};  
				
				
				if (_debugLog) then { diag_log format ["_childClass[%1]: %2", _i, _childClass#_i];  };
				if (_debugLog) then { diag_log format ["_childClassParent[%1]: %2", _i, _childClassParent#_i];  }; 
				
				//_attribute and _newValue
				// Get current attribute and desired value  
				private _currentAttr = _targetAttr select _i;  
				private _desiredValue = _finalValue select _i;  
				private _mode = _valueSetType select _i;  
				
				if (_debugLog) then { diag_log format ["typeName _desiredValue: %1", typeName _desiredValue];  }; 
				
				private _fullPath = configFile >> "CfgWeapons" >> _className;
				{
					_fullPath = _fullPath >> _x;
				} forEach (_cfgPath select _i);

				if (isNull _fullPath) exitWith {
					if (_debugLog) then {
						diag_log format ["[WARN] Null path for class %1, attrPath %2", _className, _cfgPath select _i];
					};
				};
				
				private _currentText1 = "";
				private _currentText2 = -1;
				private _desiredText1 = "";
				private _desiredText2 = -1;
				private _currentValue = -1;
				private _glueBack = false;

				// Split desired value if possible
				private _splitDesired = _desiredValue call compile preprocessFileLineNumbers "fnc_splitTextWithNumber.sqf";
				if (_splitDesired isEqualType [] && {count _splitDesired == 2}) then {
					_desiredText1 = _splitDesired#0;
					_desiredText2 = _splitDesired#1;
					_desiredValue = _desiredText2;
					if (_debugLog) then { diag_log format ["[DEBUG] _splitText detected!: %1", _splitDesired]; };
				};

				// Split current value if it’s a string and follows the format
				private _fullTextValue = getText _fullPath;
				private _splitCurrent = _fullTextValue call compile preprocessFileLineNumbers "fnc_splitTextWithNumber.sqf";
				if (_splitCurrent isEqualType [] && {count _splitCurrent == 2}) then {
					_currentText1 = _splitCurrent#0;
					_currentText2 = _splitCurrent#1;
					_currentValue = _currentText2;
					if (_debugLog) then { diag_log format ["[DEBUG] Current split value: %1", _splitCurrent]; };
				} else {
					// Fallback if split failed — assume scalar or normal string
					private _valueType = typeName _desiredValue;
					_currentValue = switch (_valueType) do {
						case "STRING": { _fullTextValue };
						case "SCALAR": { getNumber _fullPath };
						default { nil };
					};
				};

				// Determine whether to glue result back
				if (!isNil "_currentText1" && !isNil "_currentText2" && {_currentText1 == _desiredText1}) then {
					_glueBack = true;
				};

				// Value adjustment logic
				private _finalAdjustedValue = switch (true) do {
					case (typeName _desiredValue == "STRING"): { _desiredValue };
					case (_mode == "raiseTo" && {_currentValue < _desiredValue}): { _desiredValue };
					case (_mode == "lowerTo" && {_currentValue > _desiredValue}): { _desiredValue };
					case (_mode == "equalizeTo"): { _desiredValue };
					default { _currentValue };
				};

				// Rebuild the string if needed
				if (_glueBack) then {
					_finalAdjustedValue = [_desiredText1, _finalAdjustedValue] call compile preprocessFileLineNumbers "fnc_joinTextWithNumber.sqf";
				};

				if (_debugLog) then { diag_log format ["[DEBUG] Final adjusted value: %1", _finalAdjustedValue]; };

				if (_debugLog) then {  
					diag_log format [  
						"Attr: %1 | Current: %2 | Desired: %3 | Mode: %4 | Final: %5",  
						_currentAttr, _currentValue, _desiredValue, _mode, _finalAdjustedValue  
					]; 
				};
				
				// Collect attribute after determining _finalAdjustedValue


				private _cfg = _cfgPath select _i;
				private _value = _finalAdjustedValue; // not an array!

				private _count = count _cfg;

				if ((count _cfg) == 0) exitWith {
					diag_log format ["[ERROR] Empty _cfgPath at index %1: %2", _i, _cfg];
				};

				private _attr = _cfg deleteAt ((count _cfg) - 1);
				private _path = _cfg; // now just the class path
				private _isNested = (count _path) > 0;
				if (_debugLog) then { diag_log format ["[DEBUG] _attributes pushback sanity check: %1, %2, %3", _path, _attr, _value];};


				if (_isNested) then {
					_attributes pushBack [_path, _attr, _value];
					if (_debugLog) then { diag_log format ["[DEBUG] Nested pushBack: %1", [_path, _attr, _value]]; };
				} else {
					_attributes pushBack [_attr, _value];
					if (_debugLog) then { diag_log format ["[DEBUG] Root pushBack: %1", [_attr, _value]]; };
				};


			};  

			_output pushback [_className, _classNameParent, _attributes];
			

			if (_debugLog) then { diag_log format ["Iteration %1: %2", _forEachIndex + 1, _x];};
			if (_debugLog) then { diag_log format ["[DEBUG] Loop %1 finished",_forEachIndex + 1];};
		} forEach _cfgEntries;
		diag_log _output;		
	};
	case "backpack":
	{
		
		
	};
	default	{diag_log format ["%1 is not acceptable _itemCategory",_itemCategory];};
};


