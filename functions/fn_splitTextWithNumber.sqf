////fn_splitTextWithNumber.sqf
//	Splits a string into [textPart, numberPart] if it matches pattern like "Supply80" or "Med 25".
//	- Input: STRING (e.g., "Supply80", "Med 25")
//	- Output: [STRING, SCALAR] or false if not matched

params ["_input"];

if (typeName _input != "STRING") exitWith { false };

private _str = trim _input;
private _length = count _str;

private _numStart = _length;
for "_i" from (_length - 1) to 0 step -1 do {
	private _char = _str select [_i, 1];
	if (!(_char in ["0","1","2","3","4","5","6","7","8","9"])) exitWith {
		_numStart = _i + 1;
	};
};

if (_numStart == _length) exitWith { false };

private _textPart = trim (_str select [0, _numStart]);
private _numPartText = _str select [_numStart];
private _numPart = parseNumber _numPartText;

if (_numPartText == "" || {isNil "_numPart"} || {typeName _numPart != "SCALAR"}) exitWith { false };

[_textPart, _numPart]
