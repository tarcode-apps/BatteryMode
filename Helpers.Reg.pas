unit Helpers.Reg;

interface

uses
  Winapi.Windows,
  System.SysUtils,
  Versions.Helpers;

type
  TReg = class
  public type
    TRegBits = (rbDef, rb32, rb64);
  private const
    KeyShortNames: array[HKEY_CLASSES_ROOT..HKEY_DYN_DATA] of string = (
      'HKCR', 'HKCU', 'HKLM', 'HKU', 'HKPD', 'HKCC', 'HKDD');
    RegBits: array[rbDef..rb64] of string = ('', ' /reg:32', ' /reg:64');

    REG_SUCCESS     = 0;
    REG_ERROR       = 1;

    REG_COMP_DIFF   = 0;
    REG_COMP_ERROR  = 1;
    REG_COMP_EQUAL  = 2;
  private
    class function Reg(Params: string): DWORD;
    class function IsRelative(const Value: string): Boolean;
  public
    class function Export(RootKey: HKEY; const Key, FileName: string; Bits: TRegBits = rbDef): Boolean;
    class function Import(const FileName: string; Bits: TRegBits = rbDef): Boolean;
  end;

implementation

{ TReg }

class function TReg.Reg(Params: string): DWORD;
var
  StartUpInfo : TStartUpInfo;
  ProcessInfo : TProcessInformation;
  CmdString: string;
  bRet: BOOL;
begin
  ZeroMemory(@StartUpInfo, SizeOf(StartUpInfo));
  StartUpInfo.cb := SizeOf(StartUpInfo);
  StartUpInfo.dwFlags := STARTF_USESHOWWINDOW;
  StartUpInfo.wShowWindow := SW_HIDE;

  CmdString := Format('REG %0:s', [Params]);
  bRet := CreateProcess(nil, LPTSTR(CmdString), nil, nil, True,
    GetPriorityClass(GetCurrentProcess), nil, nil, StartUpInfo, ProcessInfo);
  if not bRet then Exit(REG_ERROR);

  try
    WaitForSingleObject(ProcessInfo.hProcess, INFINITE);
    bRet := GetExitCodeProcess(ProcessInfo.hProcess, Result);
    if not bRet then Exit(REG_ERROR);
  finally
    CloseHandle(ProcessInfo.hProcess);
    CloseHandle(ProcessInfo.hThread);
  end;
end;

class function TReg.IsRelative(const Value: string): Boolean;
begin
  Result := not ((Value <> '') and (Value[1] = '\'));
end;

class function TReg.Export(RootKey: HKEY; const Key, FileName: string;
  Bits: TRegBits = rbDef): Boolean;
const
  ExportFmt = 'EXPORT "%0:s%1:s%2:s" "%3:s" /y%4:s';
  ExportFmtLegacy = 'EXPORT "%0:s%1:s%2:s" "%3:s"';
var
  S, ExportFormat: string;
begin
  S := Key;
  if not IsRelative(S) then Delete(S, 1, 1);

  if IsWindowsVistaOrGreater then
    ExportFormat := ExportFmt
  else
    ExportFormat := ExportFmtLegacy;

  Result := Reg(Format(ExportFormat,
    [KeyShortNames[RootKey], PathDelim, S, FileName, RegBits[Bits]])) = REG_SUCCESS;
end;

class function TReg.Import(const FileName: string; Bits: TRegBits): Boolean;
begin
  Result := Reg(Format('IMPORT "%0:s"%1:s',
    [FileName, RegBits[Bits]])) = REG_SUCCESS;
end;

end.
