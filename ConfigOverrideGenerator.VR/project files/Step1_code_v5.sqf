// === USER CONFIG (Minimal Input Required) ===  
COG_itemCategory = "uniform"; // "uniform", "backpack"
//private _targetAttr   = ["containerClass", "mass"]; // Attributes to modify
COG_attributePaths = [[["ItemInfo",true], "containerClass"],[["ItemInfo",true], "mass"]]; // REQUIRED and Case-Sensitive
COG_finalValues   	= ["Supply80", 40]; // REQUIRED and Case-Sensitive
COG_valueSetTypes 	= ["raiseTo", "lowerTo"]; // "raiseTo", "lowerTo" or "setTo". // REQUIRED and Case-insensitive

// === ADDITIONAL FILTERING ===  
COG_exceptions   	= ["U_B_CombatUniform_mcam"]; // Classes to skip  
// WARNING: Custom Filter is provided with object classname under 'configFile >> CfgWeapons/CfgVehicles' and MUST return BOOL (true or false)
COG_customFilter = {
    // Must return boolean. `_x` refers to the config entry (e.g. configFile >> CfgWeapons >> className)
    true
};

// === DEBUGGING OPTIONS ===
// Turning debug_logs ON and OFF
COG_debugLog     	= true; // Handles display of information regarding flow of the code within 'for "_i"' and 'forEach' loops - creates a massive amount of diag logs when true 
COG_debugLimit	  	= true; // When TRUE, the logging and output will start on loop number defined in _skipXLoops
private _skipXLoops = 400; // Set the amount of skipped iterations (for debugging)  
private _displayXLoops = 3; // After skipping amount of loops defined in _skipXLoops, display this many loops

// ====== CODE ======
// === VALIDATION ===  
if (count COG_attributePaths != count COG_finalValues ||
	count COG_attributePaths != count COG_valueSetTypes)
	exitWith {  
    diag_log "[ERROR] COG: Config arrays mismatched! Check COG_attributePaths/COG_finalValues/COG_valueSetTypes.";  
};  

// === INIT ===
private _output = [];
private _cfgClass = switch (COG_itemCategory) do {
    case "uniform": { "CfgWeapons" };
    case "backpack": { "CfgVehicles" };
    default {
        diag_log format ["[ERROR] Unsupported COG_itemCategory: %1", COG_itemCategory];
        ""
    };
};

if (_cfgClass isEqualTo "") exitWith {};
if (isNull (configFile >> _cfgClass)) exitWith {
    diag_log format ["[ERROR] Invalid config class: %1", _cfgClass];
};
private _cfgEntries = [];


if (COG_debugLog) then { diag_log format ["COG_itemCategory: %1", COG_itemCategory];};

switch (toLower COG_itemCategory) do
{
	case "uniform":
	{
		_cfgClass = "CfgWeapons";
		private _cfgEntries = "true" configClasses (configFile >> _cfgClass);  
		{  
			if (COG_debugLimit && _forEachIndex < _skipXLoops) then { continue }; // Skip iterations  
			if (COG_debugLimit && _forEachIndex >= _skipXLoops + _displayXLoops) exitWith {}; // Stop after + number iterations  
			if (COG_debugLog) then { diag_log "====================================";};
			if (COG_debugLog) then { diag_log format ["[DEBUG] Loop %1 started",_forEachIndex + 1];};

			//  == INIT == 
			private _className = configName _x;  
			
			//  == FILTERING == 
			// Check if class is excluded in COG_exceptions
			if (_className in COG_exceptions) then { continue };  
			
			// Check for ItemInfo type (for Uniforms and Vests)
			private _itemInfo = _x >> "ItemInfo";
			if (!isClass _itemInfo) then { continue };

			// 801 is for Uniforms
			private _itemType = getNumber (_itemInfo >> "type");
			if (_itemType != 801) then { continue };
			
			// Custom Filter
			if (!isNil "COG_customFilter" && {!(_x call COG_customFilter)}) then { continue };
			
			if (COG_debugLog) then { diag_log format ["[DEBUG] COG: %1 = PASS", _className]};
			//  == FILTERING END == 
			
			//  == IN-LOOP INIT & RESET == 
			private _classNameConfig = configFile >> "CfgWeapons" >> _className;
			private _classNameParent = configName (inheritsFrom _classNameConfig);
			private _attributes = [];

			//  == IN-LOOP INIT & RESET END == 


			// Cycle through arrays  
			for "_i" from 0 to (count COG_finalValues - 1) do {  
				if (COG_debugLog) then { diag_log format ["[DEBUG] Checking %1 index array in this loop: %2",_i, COG_attributePaths#_i];  }; 
								
				// ==== _attribute and _newValue ====
				// == INIT and RESET VALUES ==
				private _desiredValue = COG_finalValues select _i;  
				private _currentText1 = "";
				private _currentText2 = -1;
				private _desiredText1 = "";
				private _desiredText2 = -1;
				private _currentValue = -1;
				
				if (COG_debugLog) then { diag_log format ["[DEBUG] _desiredValue: %1", _desiredValue];  }; 
				// Prepare full config path to an attribute and its value
				private _fullPath = configFile >> "CfgWeapons" >> _className;
				{
					private _segment = _x;
					private _segmentName = if (_segment isEqualType []) then {_segment#0} else {_segment};
					_fullPath = _fullPath >> _segmentName;
					if (COG_debugLog) then { diag_log format ["[DEBUG] Added segment to _fullPath: %1", _segmentName];  }; 
				} forEach (COG_attributePaths select _i);
				if (COG_debugLog) then { diag_log format ["[DEBUG] _fullPath: %1", _fullPath];  }; 


				if (isNull _fullPath) exitWith {
					if (COG_debugLog) then {
						diag_log format ["[ERROR] Null path for class %1, attrPath %2", _className, COG_attributePaths select _i];
					};
				};
				
				// Split desired value if possible
				private _splitDesired = _desiredValue call COG_fnc_splitTextWithNumber;
				if (COG_debugLog) then { diag_log format ["[DEBUG] Split-text fnc call result for _desiredValue: %1", _splitDesired];  }; 
				if (_splitDesired isEqualTo "any" ) exitWith { diag_log format ["[ERROR] COG_fnc_splitTextWithNumber does not work!"];  }; 
				if (_splitDesired isEqualType [] && {count _splitDesired == 2}) then {
					_desiredText1 = _splitDesired#0;
					_desiredText2 = _splitDesired#1;
					_desiredValue = _desiredText2;
					if (COG_debugLog) then { diag_log format ["[DEBUG] [Split-check] TRUE for FinalValue: %1", _splitDesired]; };
				};


				// Split current value if it’s a string and follows the format
				private _fullTextValue = getText _fullPath;
				
				if (COG_debugLog) then {
					if (_fullTextValue isNotEqualTo "") then {
						diag_log format ["[DEBUG] _fullTextValue: %1", _fullTextValue];
					} else {
						private _fullNumberValue = getNumber _fullPath;
						if (!isNil "_fullNumberValue" && {_fullNumberValue != 0 || {getText _fullPath == ""}}) then {
							diag_log format ["[DEBUG] _fullTextValue is NOT text, number is: %1", _fullNumberValue];
						} else {
							diag_log "[DEBUG] _fullTextValue is neither a valid string nor a number.";
						};
					};
				};
				
				private _splitCurrent = _fullTextValue call COG_fnc_splitTextWithNumber;
				if (COG_debugLog) then { diag_log format ["[DEBUG] Split-text fnc call result for _currentValue: %1", _splitCurrent];  }; 
				
				if (_splitCurrent isEqualType [] && {count _splitCurrent == 2}) then {
					_currentText1 = _splitCurrent#0;
					_currentText2 = _splitCurrent#1;
					_currentValue = _currentText2;
					if (COG_debugLog) then { diag_log format ["[DEBUG] [Split-check] TRUE for CurrentValue: %1", _splitCurrent]; };
				} else {
					// Fallback if split failed — assume scalar or normal string
					private _valueType = typeName _desiredValue;
					_currentValue = switch (_valueType) do {
						case "STRING": { _fullTextValue };
						case "SCALAR": { getNumber _fullPath };
						default { nil };
					};
				};
				
				if (COG_debugLog) then {diag_log format ["[DEBUG] _currentValue: %1", _currentValue];};

				if (COG_debugLog) then { diag_log format ["[DEBUG] typeName _desiredValue: %1", typeName _desiredValue];  }; 

				// Value adjustment logic
				private _mode = toLower (COG_valueSetTypes select _i);  
				private _finalAdjustedValue = switch (true) do {
					case (typeName _desiredValue == "STRING"): { _desiredValue };
					case (_mode == "raiseto" && {_currentValue < _desiredValue}): { _desiredValue };
					case (_mode == "lowerto" && {_currentValue > _desiredValue}): { _desiredValue };
					case (_mode == "setto"): { _desiredValue };
					default { _currentValue };
				};

				if (COG_debugLog) then { diag_log format ["[DEBUG] _mode : %1", _mode];  }; 
				
				// Determine whether to glue result back
				if (!isNil "_currentText1" && !isNil "_currentText2" && {_currentText1 == _desiredText1}) then {
					_finalAdjustedValue = [_desiredText1, _finalAdjustedValue] call COG_fnc_joinTextWithNumber;
				};

				if (COG_debugLog) then { diag_log format ["[DEBUG] Final adjusted value: %1", _finalAdjustedValue]; };

				if (COG_debugLog) then {  
					diag_log format [  
						"[DEBUG] [Summary] Current: %1 | Desired: %2 | Mode: %3 | Final: %4",  
						_currentValue, _desiredValue, _mode, _finalAdjustedValue  
					]; 
				};
				
				// Collect attribute after determining _finalAdjustedValue
				private _pathDescriptor = +(COG_attributePaths select _i);
				private _value = _finalAdjustedValue; // not an array!
				
				if ((count _pathDescriptor) == 0) exitWith {
					diag_log format ["[ERROR] Empty COG_attributePaths at index %1: %2", _i, _pathDescriptor];
				};

				private _attributeName = _pathDescriptor deleteAt ((count _pathDescriptor) - 1);	// 4-1=3, so "armor"

				//Now, the _pathDescriptor array might be empty now. Let's make sure if we want to extract a _path

				//private _count = count _pathDescriptor; // 4

				if ((count _pathDescriptor) == 0) then {
					_attributes pushBack [_attributeName, _value];
					if (COG_debugLog) then { diag_log format ["[DEBUG] Root pushBack: %1", [_attributeName, _value]]; };
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

							private _currentStep = configFile >> "CfgWeapons" >> _className;

							// Build full path up to current index
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

							// Replace boolean TRUE with parent class name
							(_pathDescriptor select _stepIndex) set [1, _parentClass];

						} else {
							// FALSE → reduce to just the path name (wrap in array to maintain structure)
							_pathDescriptor set [_stepIndex, [ _stepName ]];
						}
					} forEach _pathDescriptor;

					// Now you can safely push back _pathDescriptor as the path
					_attributes pushBack [_pathDescriptor, _attributeName, _value];

					if (COG_debugLog) then {
						diag_log format ["[DEBUG] Nested pushBack: %1", [_pathDescriptor, _attributeName, _value]];
					};
				};

				if (typeName _currentValue != typeName _desiredValue) then {
					diag_log format ["[WARNING] Type mismatch for class %1 attr %2: %3 vs %4", _className, _attributeName, typeName _currentValue, typeName _desiredValue];
				};

			};  

			_output pushback [_className, _classNameParent, _attributes];
			

			if (COG_debugLog) then { diag_log format ["Iteration %1: %2", _forEachIndex + 1, _x];};
			if (COG_debugLog) then { diag_log format ["[DEBUG] Loop %1 finished",_forEachIndex + 1];};
		} forEach _cfgEntries;
		diag_log _output;		
	};
	case "backpack":
	{
		
		
	};
	default	{diag_log format ["%1 is not acceptable COG_itemCategory",COG_itemCategory];};
};


