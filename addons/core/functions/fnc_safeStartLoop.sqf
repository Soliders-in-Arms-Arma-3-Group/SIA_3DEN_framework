#include "script_component.hpp"

/*
 * Author: McKendrick, Siege
 * Make player invincible and stop them from shooting, throwing grenades, and planting explosives until mission start.
 *
 * Arguments:
 * 0: Player <OBJECT>.
 *
 * Return Value:
 * None
 *
 * Example:
 * [player] call sia3f_core_fnc_safeStartLoop
*/

if (!GET_CONFIG(enableSafestartSafety,true)) exitWith {
	LOG_FUNC_END_ERROR("function disabled by mission settings");
};

LOG_FUNC_START;
params [
   ["_unit", player, [objNull]]
];

_unit allowDamage false;

if (_unit in (allCurators apply { getAssignedCuratorUnit _x })) exitWith { LOG_FUNC_END_ERROR("unit is a curator (zeus)"); };

if ("@ace" call FUNC(checkModPresence)) then {
	{ [_unit, _x, true] call ace_safemode_fnc_setWeaponSafety } forEach (weapons _unit);
	_unit setVariable ["ace_common_effect_blockThrow", 1]; // force use vanilla throwing so the event handler works (need to make ensure that another function doesn't set it to 0)
	_unit setVariable ["ace_explosives_PlantingExplosive", true]; // This is the only way to stop planting of explosives that I could find
};

private _FiredMan_EH = _unit addEventHandler ["FiredMan", {
	deleteVehicle (_this # 6);

	if (_this # 1 == "Throw") then {
		(_this # 0) addItem (_this # 5); // replace lost grenades, smokes, etc.
	};
}];

//temp fix to ACE safety issue
waitUntil { missionNamespace getVariable [QGVAR(missionStarted), false] };
/*
if ("@ace" call FUNC(checkModPresence)) then {
	while { !(missionNamespace getVariable [QGVAR(missionStarted), false]) } do { 
		waitUntil { (_unit getVariable ["ace_safemode_safedWeapons", []]) isNotEqualTo (weapons _unit) || (missionNamespace getVariable [QGVAR(missionStarted), false]) };
		if (!(missionNamespace getVariable [QGVAR(missionStarted), false])) then {
			{ [_unit, _x, true] call ace_safemode_fnc_setWeaponSafety } forEach ((weapons _unit) - (_unit getVariable "ace_safemode_safedWeapons"));
		};
	};
} else {
	waitUntil { missionNamespace getVariable [QGVAR(missionStarted), false] };
};
*/

// reset everything to their proper states
_unit allowDamage true;
_unit removeEventHandler ["FiredMan", _FiredMan_EH];

if ("@ace" call FUNC(checkModPresence)) then {
	{ [_unit, _x, false] call ace_safemode_fnc_setWeaponSafety } forEach (weapons _unit);
	_unit setVariable ["ace_common_effect_blockThrow", 0];
	_unit setVariable ["ace_explosives_PlantingExplosive", false];
};

LOG_FUNC_END;
