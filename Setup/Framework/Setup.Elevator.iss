#ifndef _SetupElevator
	#define _SetupElevator

#include "Windows.Api.iss"
#include "Setup.Params.iss"

[Code]

//
// Elevated Runner
//

function IsRegularUser(): Boolean;
begin
	Result := not (IsAdminLoggedOn or IsPowerUserLoggedOn);
end;

function IsElevated(): Boolean;
begin
	Result := ParamExists('/ELEVATED');
end;

function RunElevated(Params: array of String; RemoveParams: array of String): Boolean;
var
	Count: Longint;
	RunParams: String;
	RetVal: HINSTANCE;
begin
	Count := GetArrayLength(Params);
	SetArrayLength(Params, Count + 2);
	Params[Count] := ParamAddOrSetValue('/LANG', ExpandConstant('{language}'));
	Params[Count + 1] := '/ELEVATED';
	
	Count := GetArrayLength(RemoveParams);
	SetArrayLength(RemoveParams, Count + 1);
	RemoveParams[Count] := '/SL5';
	
	RunParams := ParamsUpdate(Params, RemoveParams);
	
	RetVal := ShellExecute(WizardForm.Handle, 'runas',
		ExpandConstant('{srcexe}'), RunParams, '', SW_SHOW);
	
	Result := RetVal > 32;
	
	if Result then
		Log('Elevated instance successfully runned.')
	else
		Log(Format('Elevated instance not running. Exit code: %d', [RetVal]));
end;

#endif
