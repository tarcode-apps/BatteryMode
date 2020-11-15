#ifndef _SetupInstallType
	#define _SetupInstallType

[Code]

//
// Install Type Framework
//

type
	TInstallType = (itAllUser, itJustForMe, itPortable);

function InstallTypeToString(InstallType: TInstallType): string;
begin
	case InstallType of
		itAllUser:		Result := 'AllUser';
		itJustForMe:	Result := 'JustForMe';
		itPortable:		Result := 'Portable';
		else			Result := 'Auto';
	end;
end;

function StringToInstallType(InstallTypeStr: string): TInstallType;
begin
	if Uppercase(InstallTypeStr) = Uppercase('AllUser') then		Result := itAllUser
	else if Uppercase(InstallTypeStr) = Uppercase('JustForMe') then	Result := itJustForMe
	else if Uppercase(InstallTypeStr) = Uppercase('Portable') then	Result := itPortable
	else Result := itAllUser;
end;

#endif
