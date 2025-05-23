// === USER CONFIG (Minimal Input Required) ===  
private _COG_itemCategory = "uniform"; // "uniform", "backpack"
//private _targetAttr   = ["containerClass", "mass"]; // Attributes to modify
private _COG_attributePaths = [[["ItemInfo",true], "containerClass"],[["ItemInfo",true], "mass"]]; // REQUIRED and Case-Sensitive
private _COG_finalValues   	= ["Supply80", 40]; // REQUIRED and Case-Sensitive
private _COG_valueSetTypes 	= ["raiseTo", "lowerTo"]; // "raiseTo", "lowerTo" or "setTo". // REQUIRED and Case-insensitive
private _COG_exceptions   	= ["U_B_CombatUniform_mcam"]; // Classes to skip  
private _COG_debugLog     	= true; 
private _COG_debugLimit	  	= true; 


// === VALIDATION ===  
if (count _COG_attributePaths != count _COG_finalValues ||
	count _COG_attributePaths != count _COG_valueSetTypes)
	exitWith {  
    diag_log "[ERROR] COG: Config arrays mismatched! Check _COG_attributePaths/_COG_finalValues/_COG_valueSetTypes.";  
};  

// === INIT ===  
private _output = [];
private _cfgClass = "";
private _cfgEntries = [];  // Initialize empty, populate later


if (_COG_debugLog) then { diag_log format ["_COG_itemCategory: %1", _COG_itemCategory];};

switch (toLower _COG_itemCategory) do
{
	case "uniform":
	{
		_cfgClass = "CfgWeapons";
		private _cfgEntries = "true" configClasses (configFile >> _cfgClass);  
		{  
			private _skipXLoops = 315; // Set the amount of skipped iterations (for debugging)  
			if (_COG_debugLimit && _forEachIndex < _skipXLoops) then { continue }; // Skip iterations  
			if (_COG_debugLimit && _forEachIndex >= _skipXLoops + 3) exitWith {}; // Stop after + number iterations  
			if (_COG_debugLog) then { diag_log format ["[DEBUG] Loop %1 started",_forEachIndex + 1];};

			//  == FILTERING == 
			private _className = configName _x;  
			if (_className in _COG_exceptions) then { continue };  
			
			// Check for ItemInfo type
			private _itemInfo = _x >> "ItemInfo";
			if (!isClass _itemInfo) then { continue };

			private _itemType = getNumber (_itemInfo >> "type");
			if (_itemType != 801) then { continue };
			
			//  == FILTERING END == 
			if (_COG_debugLog) then { diag_log format ["[DEBUG] COG: %1 = PASS)", _className]};
			
			//  == IN-LOOP INIT & RESET == 
			private _classNameConfig = configFile >> "CfgWeapons" >> _className;
			private _classNameParent = configName (inheritsFrom _classNameConfig);
			private _attributes = [];

			//  == IN-LOOP INIT & RESET END == 


			// Cycle through arrays  
			for "_i" from 0 to (count _COG_finalValues - 1) do {  

				// ==== _attribute and _newValue ====
				// == INIT and RESET VALUES ==
				private _desiredValue = _COG_finalValues select _i;  
				private _currentText1 = "";
				private _currentText2 = -1;
				private _desiredText1 = "";
				private _desiredText2 = -1;
				private _currentValue = -1;
				
				if (_COG_debugLog) then { diag_log format ["[DEBUG] _desiredValue: %1", _desiredValue];  }; 

				// Prepare full config path to an attribute and its value
				private _fullPath = configFile >> "CfgWeapons" >> _className;
				{
					private _segment = _x;
					private _segmentName = if (_segment isEqualType []) then {_segment#0} else {_segment};
					_fullPath = _fullPath >> _segmentName;
				} forEach (_COG_attributePaths select _i);


				if (isNull _fullPath) exitWith {
					if (_COG_debugLog) then {
						diag_log format ["[ERROR] Null path for class %1, attrPath %2", _className, _COG_attributePaths select _i];
					};
				};

				// Split desired value if possible
				private _splitDesired = _desiredValue call compile preprocessFileLineNumbers "fnc_splitTextWithNumber.sqf";
				if (_splitDesired isEqualType [] && {count _splitDesired == 2}) then {
					_desiredText1 = _splitDesired#0;
					_desiredText2 = _splitDesired#1;
					_desiredValue = _desiredText2;
					if (_COG_debugLog) then { diag_log format ["[DEBUG] [Split-check] TRUE for FinalValue: %1", _splitDesired]; };
				};


				// Split current value if it’s a string and follows the format
				private _fullTextValue = getText _fullPath;
				private _splitCurrent = _fullTextValue call compile preprocessFileLineNumbers "fnc_splitTextWithNumber.sqf";
				if (_splitCurrent isEqualType [] && {count _splitCurrent == 2}) then {
					_currentText1 = _splitCurrent#0;
					_currentText2 = _splitCurrent#1;
					_currentValue = _currentText2;
					if (_COG_debugLog) then { diag_log format ["[DEBUG] [Split-check] TRUE for CurrentValue: %1", _splitCurrent]; };
				} else {
					// Fallback if split failed — assume scalar or normal string
					private _valueType = typeName _desiredValue;
					_currentValue = switch (_valueType) do {
						case "STRING": { _fullTextValue };
						case "SCALAR": { getNumber _fullPath };
						default { nil };
					};
				};

				if (_COG_debugLog) then { diag_log format ["[DEBUG] typeName _desiredValue: %1", typeName _desiredValue];  }; 

				// Value adjustment logic
				private _mode = toLower (_COG_valueSetTypes select _i);  
				private _finalAdjustedValue = switch (true) do {
					case (typeName _desiredValue == "STRING"): { _desiredValue };
					case (_mode == "raiseto" && {_currentValue < _desiredValue}): { _desiredValue };
					case (_mode == "lowerto" && {_currentValue > _desiredValue}): { _desiredValue };
					case (_mode == "setto"): { _desiredValue };
					default { _currentValue };
				};

				if (_COG_debugLog) then { diag_log format ["[DEBUG] _mode : %1", _mode];  }; 
				
				// Determine whether to glue result back
				if (!isNil "_currentText1" && !isNil "_currentText2" && {_currentText1 == _desiredText1}) then {
					_finalAdjustedValue = [_desiredText1, _finalAdjustedValue] call compile preprocessFileLineNumbers "fnc_joinTextWithNumber.sqf";
				};

				if (_COG_debugLog) then { diag_log format ["[DEBUG] Final adjusted value: %1", _finalAdjustedValue]; };

				if (_COG_debugLog) then {  
					diag_log format [  
						"[DEBUG] [Summary] Current: %1 | Desired: %2 | Mode: %3 | Final: %4",  
						_currentValue, _desiredValue, _mode, _finalAdjustedValue  
					]; 
				};
				
				// Collect attribute after determining _finalAdjustedValue
				
				// remember to re-add
				//if (_COG_debugLog) then { diag_log format ["_childClass[%1]: %2", _i, _childClass#_i];  };
				//if (_COG_debugLog) then { diag_log format ["_childClassParent[%1]: %2", _i, _childClassParent#_i];  }; 

				//test: _COG_attributePaths = [[["ItemInfo",true], "containerClass"],[["ItemInfo",true], "mass"],[["ItemInfo",true], ["HitpointsProtectionInfo", false], ["Body", false], "armor"]];
				private _pathDescriptor = _COG_attributePaths select _i; // when _i=2 => [["ItemInfo",true], ["HitpointsProtectionInfo", false], ["Body", false], "armor"]
				private _value = _finalAdjustedValue; // not an array!

				//private _count = count _pathDescriptor; // 4

				if ((count _pathDescriptor) == 0) exitWith {
					diag_log format ["[ERROR] Empty _COG_attributePaths at index %1: %2", _i, _pathDescriptor];
				};

				private _attributeName = _pathDescriptor deleteAt ((count _pathDescriptor) - 1);	// 4-1=3, so "armor"
				
				//Now, the _pathDescriptor array might be empty now. Let's make sure if we want to extract a _path

				if ((count _pathDescriptor) == 0) then {
					_attributes pushBack [_attributeName, _value];
					if (_COG_debugLog) then { diag_log format ["[DEBUG] Root pushBack: %1", [_attributeName, _value]]; };

				} else {	
					//Please note that despite checking twice if (count _pathDescriptor) == 0, we did remove last index inbetween.
					//So we determined that count 0 is bad and should forceexit the code and count 1 (currently 0) is just an attribute in this array. Anything else are nested classes, so we need to find out which ones need a parent class
					// But we need to create a config path to that location in order to use 'inheritsFrom'
					// _pathDescriptor; // now just the class path // [["ItemInfo",true], ["HitpointsProtectionInfo", false], ["Body", false]]

					// Assign parent classes to _pathDescriptor arrays that contain TRUE in their first index
					// else, replace [<path>,false] with just <path>
					{
						if (_pathDescriptor select [_forEachIndex,1]) then {	//that would be TRUE for _forEachIndex=0
							if (_COG_debugLog) then { diag_log format ["[DEBUG] Parent Class needed for %1", (_pathDescriptor select [_forEachIndex,1])]; };
							// We need full config path, and it starts with:
							private _currentStep = configFile >> "CfgWeapons" >> _className;
							// Then, we need to reach [_forEachIndex,0], which is nested 1-deep for ItemInfo, 2-deep for HitpointsProtectionInfo etc
							// Basically, if we want to create full config, we will always have to iterate through all of the previous steps
							if (isNull _currentStep) then {
								diag_log format ["_currentStep is null! '%1' Exiting loop... ", _currentStep];
								continue;
							}; // Skip if path failed  
							for "_j" from 0 to _forEachIndex do {
								_currentStep = _currentStep >> (_pathDescriptor select [_j,0])	// _currentStep >> "ItemInfo"
							};
							if (!isClass _currentStep) exitWith {  
								_currentStep = configNull; // Ensure termination 
								diag_log format ["[ERROR] Missing config: %1", _COG_attributePaths#_i#_k];  
							};
							if (_COG_debugLog) then { diag_log format ["[DEBUG] Config Path: %1", _currentStep]; };
							// config path is now made. Time to extract parent class
							private _parentClass = configName (inheritsFrom _currentStep);
							if (_COG_debugLog) then { diag_log format ["[DEBUG] Parent Class: %1", _parentClass]; };
							// Now that we have _parentClass - we need to (_pathDescriptor select [_forEachIndex,1]) with _parentClass
							_pathDescriptor set [[_forEachIndex,1], _parentClass];
							// Now, the _pathDescriptor = [["ItemInfo","UniformItem"], ["HitpointsProtectionInfo", false], ["Body", false]]
							// Let's deal with [_forEachIndex,1] == FALSE now
							} else {
							
							
							

							};
						};
					} forEach _pathDescriptor;

				};
				
				
				
				
				
				private _isNested = (count _path) > 0;
				if (_isNested) then {
					_attributes pushBack [_path, _attributeName, _value];
					if (_COG_debugLog) then { diag_log format ["[DEBUG] Nested pushBack: %1", [_path, _attributeName, _value]]; };
				} else {
				};

				if (typeName _currentValue != typeName _desiredValue) then {
					diag_log format ["[WARNING] Type mismatch for class %1 attr %2: %3 vs %4", _className, _attributeName, typeName _currentValue, typeName _desiredValue];
				};

			};  

			_output pushback [_className, _classNameParent, _attributes];
			

			if (_COG_debugLog) then { diag_log format ["Iteration %1: %2", _forEachIndex + 1, _x];};
			if (_COG_debugLog) then { diag_log format ["[DEBUG] Loop %1 finished",_forEachIndex + 1];};
		} forEach _cfgEntries;
		diag_log _output;		
	};
	case "backpack":
	{
		
		
	};
	default	{diag_log format ["%1 is not acceptable _COG_itemCategory",_COG_itemCategory];};
};


