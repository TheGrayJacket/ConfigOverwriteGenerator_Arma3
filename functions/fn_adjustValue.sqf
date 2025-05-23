//fn_adjustValue.sqf

params ["_current", "_desired", "_mode"];
_mode = toLower _mode;
switch true do {
    case (typeName _desired == "STRING"): { _desired };
    case (_mode == "raiseto" && {_current < _desired}): { _desired };
    case (_mode == "lowerto" && {_current > _desired}): { _desired };
    case (_mode == "setto"): { _desired };
    default { _current };
};