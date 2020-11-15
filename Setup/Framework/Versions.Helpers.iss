#ifndef _VersionHelpers
	#define _VersionHelpers

[Code]

//
// Version Helpers
//

function IsWindowsXPOrGreater: Boolean;
begin
	Result := (GetWindowsVersion >= $05010000);
end;

function IsWindowsVistaOrGreater: Boolean;
begin
	Result := (GetWindowsVersion >= $06000000);
end;

function IsWindows10OrGreater: Boolean;
begin
	Result := (GetWindowsVersion >= $0A000000);
end;

function IsWindowsVersionOrGreater(MajorVersion: Byte; MinorVersion: Byte; BuildNumber: WORD): Boolean;
begin
	Result := (GetWindowsVersion >= ((DWORD(MajorVersion) shl 24) or (DWORD(MinorVersion) shl 16) or DWORD(BuildNumber)));
end;

#endif
