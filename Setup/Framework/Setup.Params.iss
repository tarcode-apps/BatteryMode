#ifndef _SetupParams
	#define _SetupParams

[Code]

//
// Command Line Parameters Helper
//

const
	ParamDelim = '=';

function ParamKey(Param: String): String;
var
	DelimPos: Integer;
begin
	DelimPos := Pos(ParamDelim, Param);
	if DelimPos <> 0 then
		Delete(Param, DelimPos, Length(Param) - DelimPos + 1);

	Result := Param;
end;

function ParamValueExists(const Param: String): Boolean;
begin
	Result := Pos(ParamDelim, Param) <> 0;
end;

function ParamValue(Param: String): String;
var
	DelimPos: Integer;
begin
	DelimPos := Pos(ParamDelim, Param);
	if DelimPos <> 0 then
	begin
		Delete(Param, 1, Length(Param) - DelimPos + 1);
		Result := RemoveQuotes(Param);
	end
	else
		Result := '';
end;

function ParamAddOrSetValue(Param, NewValue: String): String;
begin
	Result := ParamKey(Param) + ParamDelim + AddQuotes(NewValue);
end;

function ParamSetValue(Param, NewValue: String): String;
begin
	if ParamValueExists(Param) then
		Result := ParamAddOrSetValue(Param, NewValue)
	else
		Result := Param;
end;

function ParamExists(const Param: String): Boolean;
var
	I: Integer;  
begin
	Result := False;
	for I := 1 to ParamCount do
	if CompareText(ParamKey(ParamStr(I)), ParamKey(Param)) = 0 then
	begin
		Result := True;
		Exit;
	end;
end;

function ParamsUpdate(UpdateParams: array of String; RemoveParams: array of String): String;
var
	I, J, UpdatedCount, RemovedCount: Longint;
	Removed, Updated: Boolean;
begin
	Result := '';
	
	UpdatedCount := GetArrayLength(UpdateParams);
	RemovedCount := GetArrayLength(RemoveParams);
	for I := 1 to ParamCount do
	begin
		Removed := False;
		for J := 0 to RemovedCount - 1 do
			if CompareText(ParamKey(ParamStr(I)), ParamKey(RemoveParams[J])) = 0 then
			begin
				Removed := True;
				Break;
			end;
			
		if Removed then Continue;
		
		Updated := False;
		for J := 0 to UpdatedCount - 1 do
			if CompareText(ParamKey(ParamStr(I)), ParamKey(UpdateParams[J])) = 0 then
			begin
				Result := Result + ' ' + UpdateParams[J];
				Updated := True;
				Break;
			end;
			
		if not Updated then
			Result := Result + ' ' + ParamStr(I);
	end;
	
	for J := 0 to UpdatedCount - 1 do
		if not ParamExists(UpdateParams[J]) then
			Result := Result + ' ' + UpdateParams[J];
end;

#endif
