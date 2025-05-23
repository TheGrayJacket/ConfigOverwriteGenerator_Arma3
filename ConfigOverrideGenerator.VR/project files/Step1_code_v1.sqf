// CONFIG
private _expectedItemType = 701;  // 701 = Uniform, 801 = Vest, 605 = Headgear, etc.
private _targetAttr       = ["containerClass", "mass"];
private _cfgPath          = [["ItemInfo", "containerClass"], ["ItemInfo", "mass"]];
private _finalValue       = ["Supply80", 40];
private _valueSetType     = ["raiseTo", "lowerTo"];
private _overrideExceptions = ["Skip_this_class", "Skip_that_class"];
private _debugLog = true;
// CONFIG END

// VALIDATE CONFIG
private _arraySize = count _targetAttr;
if (
    (count _cfgPath != _arraySize) ||
    (count _finalValue != _arraySize) ||
    (count _valueSetType != _arraySize)
) exitWith {
    private _msg = format [
        "[ERROR] COG: Config arrays are mismatched:\n targetAttr: %1\n cfgPath: %2\n finalValue: %3\n valueSetType: %4",
        count _targetAttr, count _cfgPath, count _finalValue, count _valueSetType
    ];
    copyToClipboard _msg;
    diag_log _msg;
};

// INIT
private _outputArray = [];
private _cfgWeapons = "true" configClasses (configFile >> "CfgWeapons");
// MAIN LOOP
										   
{
    private _className = configName _x;
	
	
    // Skip if in exceptions
    if (_className in _overrideExceptions) then { continue };

    // Check for ItemInfo type
    private _itemInfo = _x >> "ItemInfo";
    if (!isClass _itemInfo) then { continue };

    private _itemType = getNumber (_itemInfo >> "type");
    if (_itemType != _expectedItemType) then { continue };
	
	if (_debugLog) then { diag_log format ["[DEBUG] COG: Checking class %1", _className]};
	if (_debugLog) then { diag_log format ["[DEBUG] COG: type = %1 (expected %2)", _itemType, _expectedItemType]};
	
    private _shouldAdd = false;

						 
    for "_i" from 0 to (_arraySize - 1) do {
        private _path = _cfgPath select _i;
        private _desired = _finalValue select _i;
        private _mode = _valueSetType select _i;

        // Traverse the path
        private _cfgStep = _x;
	
        { _cfgStep = _cfgStep >> _x } forEach _path;
						  

								  
        if (isNull _cfgStep) then { continue };  // Missing value, skip check

        // Evaluate based on type
        private _type = typeName _desired;
        private _actual = switch (_type) do {
            case "STRING": { getText _cfgStep };
            case "SCALAR": { getNumber _cfgStep };
            default { "" };
        };
		
		if (_debugLog) then { diag_log format ["[DEBUG] COG: Class: %1 | Attr: %2 | Current: %3 | Target: %4 | Type: %5",
			_className,
			_path,
			_actual,
			_desired,
			_mode
		]};
		
        private _needsUpdate = switch (_mode) do {
            case "raiseTo":    { _actual < _desired };
            case "lowerTo":    { _actual > _desired };
            case "equalizeTo": { _actual != _desired };
            default { false };
        };

        if (_needsUpdate) then {
            _shouldAdd = true;
        };
    };

    if (_shouldAdd) then {
        _outputArray pushBack _className;
    };

} forEach _cfgWeapons;
  

// OUTPUT
if ((count _outputArray) == 0) then {
	private _msg = "[INFO] COG: No classnames matched the filters. Check config values or input data.";
	copyToClipboard _msg;
	diag_log _msg;
} else {
	private _addNewLines = _outputArray joinString endl;
	private _msg = format ["STEP 1 OUTPUT:%1%2", endl, _addNewLines];
	copyToClipboard _msg;
	diag_log _msg;
};