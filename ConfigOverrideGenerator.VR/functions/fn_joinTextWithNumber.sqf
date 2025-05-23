/*
  Joins a text and number into a single string.
  - Input: [STRING, SCALAR, OPTIONAL: BOOL (addSpace)]
  - Output: STRING (e.g., "Supply80" or "Med 25")
*/

params ["_textPart", "_numPart", ["_addSpace", false]];

if (typeName _textPart != "STRING" || {typeName _numPart != "SCALAR"}) exitWith {
    diag_log "[ERROR] fnc_joinTextWithNumber: Invalid input types.";
    ""
};

private _result = if (_addSpace) then {
    format ["%1 %2", _textPart, _numPart]
} else {
    format ["%1%2", _textPart, _numPart]
};

_result
