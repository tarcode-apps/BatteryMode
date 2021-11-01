unit Versions.Helpers;

interface

uses
  Winapi.Windows;

const
  _WIN32_WINNT_WIN10 = $0A00;

function IsWindowsVersionOrGreater(dwMajorVersion: DWORD; dwMinorVersion: DWORD; wServicePackMajor: WORD): Boolean; overload;
function IsWindowsVersionOrGreater(dwMajorVersion: DWORD; dwMinorVersion: DWORD; dwBuildNumber: DWORD; wServicePackMajor: WORD): Boolean; overload;
function IsWindowsXPOrGreater: Boolean;
function IsWindowsXPSP1OrGreater: Boolean;
function IsWindowsXPSP2OrGreater: Boolean;
function IsWindowsXPSP3OrGreater: Boolean;
function IsWindowsVistaOrGreater: Boolean;
function IsWindowsVistaSP1OrGreater: Boolean;
function IsWindowsVistaSP2OrGreater: Boolean;
function IsWindows7OrGreater: Boolean;
function IsWindows7SP1OrGreater: Boolean;
function IsWindows8OrGreater: Boolean;
function IsWindows8Point1OrGreater: Boolean;
function IsWindows10OrGreater: Boolean;
function IsWindows10Update1607OrGreater: Boolean;
function IsWindows10FallCreatorsOrGreater: Boolean;
function IsWindows10Update1803OrGreater: Boolean;
function IsWindows10Update1809OrGreater: Boolean;
function IsWindows10Update1903OrGreater: Boolean;
function IsWindows10Update1909OrGreater: Boolean;
function IsWindows11OrGreater: Boolean;
function IsWindowsServer: Boolean;
function IsWindows64Bit: Boolean;

function GetWindowsVersion(out VersionInformation: TOSVersionInfo): Boolean; overload;
function GetWindowsVersion(out VersionInformation: TOSVersionInfoEx): Boolean; overload;

implementation

const
  NTDLL = 'ntdll.dll';

type
  {$EXTERNALSYM NTSTATUS}
  NTSTATUS = UINT_PTR;

  {$EXTERNALSYM RTL_OSVERSIONINFOW}
  RTL_OSVERSIONINFOW = _OSVERSIONINFOW;
  {$EXTERNALSYM PRTL_OSVERSIONINFOW}
  PRTL_OSVERSIONINFOW = ^RTL_OSVERSIONINFOW;

  {$EXTERNALSYM RTL_OSVERSIONINFOEXW}
  RTL_OSVERSIONINFOEXW = _OSVERSIONINFOEXW;
  {$EXTERNALSYM PRTL_OSVERSIONINFOEXW}
  PRTL_OSVERSIONINFOEXW = ^RTL_OSVERSIONINFOEXW;

const
  STATUS_SUCCESS = NTSTATUS($00000000);

{$WARN SYMBOL_PLATFORM OFF}
  {$EXTERNALSYM RtlGetVersion}
function RtlGetVersion(
  out lpVersionInformation: RTL_OSVERSIONINFOW): NTSTATUS; stdcall; overload; external NTDLL delayed;

  {$EXTERNALSYM RtlGetVersion}
function RtlGetVersion(
  out lpVersionInformation: RTL_OSVERSIONINFOEXW): NTSTATUS; stdcall; overload; external NTDLL delayed;
{$WARN SYMBOL_PLATFORM ON}

type
  TTrilean = record
  private
    FValue: Boolean;
    FKnown: Boolean;

    procedure SetValue(Value: Boolean); inline;
  public
    class function Empty: TTrilean; static;

    class operator Implicit(const Some: TTrilean): Boolean; inline;
    class operator Implicit(const Some: Boolean): TTrilean; inline;

    property IsKnown: Boolean read FKnown;
    property Value: Boolean read FValue write SetValue;
  end;

var
  WindowsXPOrGreater              : TTrilean;
  WindowsXPSP1OrGreater           : TTrilean;
  WindowsXPSP2OrGreater           : TTrilean;
  WindowsXPSP3OrGreater           : TTrilean;
  WindowsVistaOrGreater           : TTrilean;
  WindowsVistaSP1OrGreater        : TTrilean;
  WindowsVistaSP2OrGreater        : TTrilean;
  Windows7OrGreater               : TTrilean;
  Windows7SP1OrGreater            : TTrilean;
  Windows8OrGreater               : TTrilean;
  Windows8Point1OrGreater         : TTrilean;
  Windows10OrGreater              : TTrilean;
  Windows10Update1607OrGreater    : TTrilean;
  Windows10FallCreatorsOrGreater  : TTrilean;
  Windows10Update1803OrGreater    : TTrilean;
  Windows10Update1809OrGreater    : TTrilean;
  Windows10Update1903OrGreater    : TTrilean;
  Windows10Update1909OrGreater    : TTrilean;
  Windows11OrGreater              : TTrilean;
  WindowsServer                   : TTrilean;
  Windows64Bit                    : TTrilean;

function IsWindowsVersionOrGreater(dwMajorVersion: DWORD; dwMinorVersion: DWORD; wServicePackMajor: WORD): Boolean;
var
  OsInfoEx: TOSVersionInfoEx;
  dwlConditionMask: DWORDLONG;
begin
  ZeroMemory(@OsInfoEx, SizeOf(OsInfoEx));
  OsInfoEx.dwOSVersionInfoSize := SizeOf(OsInfoEx);
  OsInfoEx.dwMajorVersion := dwMajorVersion;
  OsInfoEx.dwMinorVersion := dwMinorVersion;
  OsInfoEx.wServicePackMajor := wServicePackMajor;

  dwlConditionMask := 0;
  dwlConditionMask := VerSetConditionMask(dwlConditionMask, VER_MAJORVERSION, VER_GREATER_EQUAL);
  dwlConditionMask := VerSetConditionMask(dwlConditionMask, VER_MINORVERSION, VER_GREATER_EQUAL);
  dwlConditionMask := VerSetConditionMask(dwlConditionMask, VER_SERVICEPACKMAJOR, VER_GREATER_EQUAL);

  Result := VerifyVersionInfo(OsInfoEx, VER_MAJORVERSION or VER_MINORVERSION or VER_SERVICEPACKMAJOR, dwlConditionMask);
end;

function IsWindowsVersionOrGreater(dwMajorVersion: DWORD; dwMinorVersion: DWORD; dwBuildNumber: DWORD; wServicePackMajor: WORD): Boolean;
var
  OsInfoEx: TOSVersionInfoEx;
  dwlConditionMask: DWORDLONG;
begin
  ZeroMemory(@OsInfoEx, SizeOf(OsInfoEx));
  OsInfoEx.dwOSVersionInfoSize := SizeOf(OsInfoEx);
  OsInfoEx.dwMajorVersion := dwMajorVersion;
  OsInfoEx.dwMinorVersion := dwMinorVersion;
  OsInfoEx.dwBuildNumber  := dwBuildNumber;
  OsInfoEx.wServicePackMajor := wServicePackMajor;

  dwlConditionMask := 0;
  dwlConditionMask := VerSetConditionMask(dwlConditionMask, VER_MAJORVERSION, VER_GREATER_EQUAL);
  dwlConditionMask := VerSetConditionMask(dwlConditionMask, VER_MINORVERSION, VER_GREATER_EQUAL);
  dwlConditionMask := VerSetConditionMask(dwlConditionMask, VER_BUILDNUMBER, VER_GREATER_EQUAL);
  dwlConditionMask := VerSetConditionMask(dwlConditionMask, VER_SERVICEPACKMAJOR, VER_GREATER_EQUAL);

  Result := VerifyVersionInfo(OsInfoEx, VER_MAJORVERSION or VER_MINORVERSION or VER_BUILDNUMBER or VER_SERVICEPACKMAJOR, dwlConditionMask);
end;

function IsWindowsXPOrGreater: Boolean;
begin
  if WindowsXPOrGreater.IsKnown then
    Result := WindowsXPOrGreater
  else
  begin
    Result := IsWindowsVersionOrGreater(HIBYTE(_WIN32_WINNT_WINXP), LOBYTE(_WIN32_WINNT_WINXP), 0);
    WindowsXPOrGreater := Result;
  end;
end;

function IsWindowsXPSP1OrGreater: Boolean;
begin
  if WindowsXPSP1OrGreater.IsKnown then
    Result := WindowsXPSP1OrGreater
  else
  begin
    Result := IsWindowsVersionOrGreater(HIBYTE(_WIN32_WINNT_WINXP), LOBYTE(_WIN32_WINNT_WINXP), 1);
    WindowsXPSP1OrGreater := Result;
  end;
end;

function IsWindowsXPSP2OrGreater: Boolean;
begin
  if WindowsXPSP2OrGreater.IsKnown then
    Result := WindowsXPSP2OrGreater
  else
  begin
    Result := IsWindowsVersionOrGreater(HIBYTE(_WIN32_WINNT_WINXP), LOBYTE(_WIN32_WINNT_WINXP), 2);
    WindowsXPSP2OrGreater := Result;
  end;
end;

function IsWindowsXPSP3OrGreater: Boolean;
begin
  if WindowsXPSP3OrGreater.IsKnown then
    Result := WindowsXPSP3OrGreater
  else
  begin
    Result := IsWindowsVersionOrGreater(HIBYTE(_WIN32_WINNT_WINXP), LOBYTE(_WIN32_WINNT_WINXP), 3);
    WindowsXPSP3OrGreater := Result;
  end;
end;

function IsWindowsVistaOrGreater: Boolean;
begin
  if WindowsVistaOrGreater.IsKnown then
    Result := WindowsVistaOrGreater
  else
  begin
    Result := IsWindowsVersionOrGreater(HIBYTE(_WIN32_WINNT_VISTA), LOBYTE(_WIN32_WINNT_VISTA), 0);
    WindowsVistaOrGreater := Result;
  end;
end;

function IsWindowsVistaSP1OrGreater: Boolean;
begin
  if WindowsVistaSP1OrGreater.IsKnown then
    Result := WindowsVistaSP1OrGreater
  else
  begin
    Result := IsWindowsVersionOrGreater(HIBYTE(_WIN32_WINNT_VISTA), LOBYTE(_WIN32_WINNT_VISTA), 1);
    WindowsVistaSP1OrGreater := Result;
  end;
end;

function IsWindowsVistaSP2OrGreater: Boolean;
begin
  if WindowsVistaSP2OrGreater.IsKnown then
    Result := WindowsVistaSP2OrGreater
  else
  begin
    Result := IsWindowsVersionOrGreater(HIBYTE(_WIN32_WINNT_VISTA), LOBYTE(_WIN32_WINNT_VISTA), 2);
    WindowsVistaSP2OrGreater := Result;
  end;
end;

function IsWindows7OrGreater: Boolean;
begin
  if Windows7OrGreater.IsKnown then
    Result := Windows7OrGreater
  else
  begin
    Result := IsWindowsVersionOrGreater(HIBYTE(_WIN32_WINNT_WIN7), LOBYTE(_WIN32_WINNT_WIN7), 0);
    Windows7OrGreater := Result;
  end;
end;

function IsWindows7SP1OrGreater: Boolean;
begin
  if Windows7SP1OrGreater.IsKnown then
    Result := Windows7SP1OrGreater
  else
  begin
    Result := IsWindowsVersionOrGreater(HIBYTE(_WIN32_WINNT_WIN7), LOBYTE(_WIN32_WINNT_WIN7), 1);
    Windows7SP1OrGreater := Result;
  end;
end;

function IsWindows8OrGreater: Boolean;
begin
  if Windows8OrGreater.IsKnown then
    Result := Windows8OrGreater
  else
  begin
    Result := IsWindowsVersionOrGreater(HIBYTE(_WIN32_WINNT_WIN8), LOBYTE(_WIN32_WINNT_WIN8), 0);
    Windows8OrGreater := Result;
  end;
end;

function IsWindows8Point1OrGreater: Boolean;
begin
  if Windows8Point1OrGreater.IsKnown then
    Result := Windows8Point1OrGreater
  else
  begin
    Result := IsWindowsVersionOrGreater(HIBYTE(_WIN32_WINNT_WINBLUE), LOBYTE(_WIN32_WINNT_WINBLUE), 0);
    Windows8Point1OrGreater := Result;
  end;
end;

function IsWindows10OrGreater: Boolean;
begin
  if Windows10OrGreater.IsKnown then
    Result := Windows10OrGreater
  else
  begin
    Result := IsWindowsVersionOrGreater(HIBYTE(_WIN32_WINNT_WIN10), LOBYTE(_WIN32_WINNT_WIN10), 0);
    Windows10OrGreater := Result;
  end;
end;

function IsWindows10Update1607OrGreater: Boolean;
begin
  if Windows10Update1803OrGreater.IsKnown then
    Result := Windows10Update1803OrGreater
  else
  begin
    Result := IsWindowsVersionOrGreater(HIBYTE(_WIN32_WINNT_WIN10), LOBYTE(_WIN32_WINNT_WIN10), 14393, 0);
    Windows10Update1803OrGreater := Result;
  end;
end;

function IsWindows10FallCreatorsOrGreater: Boolean;
begin
  if Windows10FallCreatorsOrGreater.IsKnown then
    Result := Windows10FallCreatorsOrGreater
  else
  begin
    Result := IsWindowsVersionOrGreater(HIBYTE(_WIN32_WINNT_WIN10), LOBYTE(_WIN32_WINNT_WIN10), 16299, 0);
    Windows10FallCreatorsOrGreater := Result;
  end;
end;

function IsWindows10Update1803OrGreater: Boolean;
begin
  if Windows10Update1803OrGreater.IsKnown then
    Result := Windows10Update1803OrGreater
  else
  begin
    Result := IsWindowsVersionOrGreater(HIBYTE(_WIN32_WINNT_WIN10), LOBYTE(_WIN32_WINNT_WIN10), 17134, 0);
    Windows10Update1803OrGreater := Result;
  end;
end;

function IsWindows10Update1809OrGreater: Boolean;
begin
  if Windows10Update1809OrGreater.IsKnown then
    Result := Windows10Update1809OrGreater
  else
  begin
    Result := IsWindowsVersionOrGreater(HIBYTE(_WIN32_WINNT_WIN10), LOBYTE(_WIN32_WINNT_WIN10), 17763, 0);
    Windows10Update1809OrGreater := Result;
  end;
end;

function IsWindows10Update1903OrGreater: Boolean;
begin
  if Windows10Update1903OrGreater.IsKnown then
    Result := Windows10Update1903OrGreater
  else
  begin
    Result := IsWindowsVersionOrGreater(HIBYTE(_WIN32_WINNT_WIN10), LOBYTE(_WIN32_WINNT_WIN10), 18362, 0);
    Windows10Update1903OrGreater := Result;
  end;
end;

function IsWindows10Update1909OrGreater: Boolean;
begin
  if Windows10Update1909OrGreater.IsKnown then
    Result := Windows10Update1909OrGreater
  else
  begin
    Result := IsWindowsVersionOrGreater(HIBYTE(_WIN32_WINNT_WIN10), LOBYTE(_WIN32_WINNT_WIN10), 18363, 0);
    Windows10Update1909OrGreater := Result;
  end;
end;

function IsWindows11OrGreater: Boolean;
begin
  if Windows11OrGreater.IsKnown then
    Result := Windows11OrGreater
  else
  begin
    Result := IsWindowsVersionOrGreater(HIBYTE(_WIN32_WINNT_WIN10), LOBYTE(_WIN32_WINNT_WIN10), 22000, 0);
    Windows11OrGreater := Result;
  end;
end;

function IsWindowsServer: Boolean;
var
  OsInfoEx: TOSVersionInfoEx;
  dwlConditionMask: DWORDLONG;
begin
  if WindowsServer.IsKnown then
    Result := WindowsServer
  else
  begin
    ZeroMemory(@OsInfoEx, SizeOf(OsInfoEx));
    OsInfoEx.dwOSVersionInfoSize := SizeOf(OsInfoEx);
    OsInfoEx.wProductType := VER_NT_WORKSTATION;

    dwlConditionMask := VerSetConditionMask(0, VER_PRODUCT_TYPE, VER_EQUAL);

    Result := not VerifyVersionInfoW(OsInfoEx, VER_PRODUCT_TYPE, dwlConditionMask);

    WindowsServer := Result;
  end;
end;

function IsWindows64Bit: Boolean;
var
  lpSystemInformation: TSystemInfo;
begin
  if Windows64Bit.IsKnown then
    Result := Windows64Bit
  else
  begin
    GetNativeSystemInfo(lpSystemInformation);
    Result := (lpSystemInformation.wProcessorArchitecture = PROCESSOR_ARCHITECTURE_AMD64) or
      (lpSystemInformation.wProcessorArchitecture = PROCESSOR_ARCHITECTURE_IA64);
    Windows64Bit := Result;
  end;
end;

function GetWindowsVersion(out VersionInformation: TOSVersionInfo): Boolean;
begin
  ZeroMemory(@VersionInformation, SizeOf(VersionInformation));
  VersionInformation.dwOSVersionInfoSize := SizeOf(VersionInformation);

  if IsWindows8Point1OrGreater then
    Result := RtlGetVersion(RTL_OSVERSIONINFOW(VersionInformation)) = STATUS_SUCCESS
  else
    Result := GetVersionEx(VersionInformation);
end;

function GetWindowsVersion(out VersionInformation: TOSVersionInfoEx): Boolean;
begin
  ZeroMemory(@VersionInformation, SizeOf(VersionInformation));
  VersionInformation.dwOSVersionInfoSize := SizeOf(VersionInformation);

  if IsWindows8Point1OrGreater then
    Result := RtlGetVersion(RTL_OSVERSIONINFOEXW(VersionInformation)) = STATUS_SUCCESS
  else
    Result := GetVersionEx(VersionInformation);
end;

{ TTrilean }

class function TTrilean.Empty: TTrilean;
begin
  Result.FValue := False;
  Result.FKnown := False;
end;

class operator TTrilean.Implicit(const Some: TTrilean): Boolean;
begin
  Result := Some.Value;
end;

class operator TTrilean.Implicit(const Some: Boolean): TTrilean;
begin
  Result.Value := Some;
end;

procedure TTrilean.SetValue(Value: Boolean);
begin
  FValue := Value;
  FKnown := True;
end;

initialization
  WindowsXPOrGreater              := TTrilean.Empty;
  WindowsXPSP1OrGreater           := TTrilean.Empty;
  WindowsXPSP2OrGreater           := TTrilean.Empty;
  WindowsXPSP3OrGreater           := TTrilean.Empty;
  WindowsVistaOrGreater           := TTrilean.Empty;
  WindowsVistaSP1OrGreater        := TTrilean.Empty;
  WindowsVistaSP2OrGreater        := TTrilean.Empty;
  Windows7OrGreater               := TTrilean.Empty;
  Windows7SP1OrGreater            := TTrilean.Empty;
  Windows8OrGreater               := TTrilean.Empty;
  Windows8Point1OrGreater         := TTrilean.Empty;
  Windows10OrGreater              := TTrilean.Empty;
  Windows10Update1607OrGreater    := TTrilean.Empty;
  Windows10FallCreatorsOrGreater  := TTrilean.Empty;
  Windows10Update1803OrGreater    := TTrilean.Empty;
  Windows10Update1809OrGreater    := TTrilean.Empty;
  Windows10Update1903OrGreater    := TTrilean.Empty;
  Windows10Update1909OrGreater    := TTrilean.Empty;
  Windows11OrGreater              := TTrilean.Empty;
  WindowsServer                   := TTrilean.Empty;
  Windows64Bit                    := TTrilean.Empty;

end.

