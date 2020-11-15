unit MemoryDirector;

interface

uses
  Winapi.Windows, Versions.Helpers;

const
  // The working set may fall below the minimum working set limit if memory demands are high.
  // This flag cannot be used with QUOTA_LIMITS_HARDWS_MIN_ENABLE.
  QUOTA_LIMITS_HARDWS_MIN_DISABLE = $00000002;

  // The working set will not fall below the minimum working set limit.
  // This flag cannot be used with QUOTA_LIMITS_HARDWS_MIN_DISABLE.
  QUOTA_LIMITS_HARDWS_MIN_ENABLE = $00000001;

  // The working set may exceed the maximum working set limit if there is abundant memory.
  // This flag cannot be used with QUOTA_LIMITS_HARDWS_MAX_ENABLE.
  QUOTA_LIMITS_HARDWS_MAX_DISABLE = $00000008;

  // The working set will not exceed the maximum working set limit.
  // This flag cannot be used with QUOTA_LIMITS_HARDWS_MAX_DISABLE
  QUOTA_LIMITS_HARDWS_MAX_ENABLE = $00000004;

type
  TMemoryDirector = class
  private
    class var FInitialized: Boolean;
    class var FProcess: THandle;
    class var FOuotaLimitMinEnable: Boolean;
    class var FOuotaLimitMaxEnable: Boolean;
    class var FMinimumWorkingSetSize: SIZE_T;
    class var FMaximumWorkingSetSize: SIZE_T;

    class procedure SetProcess(const Value: THandle); static;
    class procedure SetOuotaLimitMinEnable(const Value: Boolean); static;
    class procedure SetOuotaLimitMaxEnable(const Value: Boolean); static;
    class procedure SetMinimumWorkingSetSize(const Value: SIZE_T); static;
    class procedure SetMaximumWorkingSetSize(const Value: SIZE_T); static;

    class function GetProcessWorkingSet: Boolean;
    class function SetProcessWorkingSet: Boolean;

    class constructor Create;
  public
    class procedure Update;
    class function SetWorkingSetSize(MinimumSize: SIZE_T; MaximumSize: SIZE_T): Boolean;
    class property Initialized: Boolean read FInitialized;
    class property Process: THandle read FProcess write SetProcess;
    class property OuotaLimitMinEnable: Boolean read FOuotaLimitMinEnable write SetOuotaLimitMinEnable;
    class property OuotaLimitMaxEnable: Boolean read FOuotaLimitMaxEnable write SetOuotaLimitMaxEnable;
    class property MinimumWorkingSetSize: SIZE_T read FMinimumWorkingSetSize write SetMinimumWorkingSetSize;
    class property MaximumWorkingSetSize: SIZE_T read FMaximumWorkingSetSize write SetMaximumWorkingSetSize;
  end;

implementation

{$WARN SYMBOL_PLATFORM OFF}
{$EXTERNALSYM GetProcessWorkingSetSizeEx}
function GetProcessWorkingSetSizeEx(
  hProcess: THandle;
  out lpMinimumWorkingSetSize: SIZE_T;
  out lpMaximumWorkingSetSize: SIZE_T;
  out Flags: DWORD): Boolean; stdcall; external kernel32 delayed;

{$EXTERNALSYM SetProcessWorkingSetSizeEx}
function SetProcessWorkingSetSizeEx(
  hProcess: THandle;
  lpMinimumWorkingSetSize: SIZE_T;
  lpMaximumWorkingSetSize: SIZE_T;
  Flags: DWORD): Boolean; stdcall; external kernel32 delayed;
{$WARN SYMBOL_PLATFORM ON}

{ TMemoryDirector }

class procedure TMemoryDirector.SetProcess(const Value: THandle);
begin
  FProcess := Value;
  Update;
end;

class procedure TMemoryDirector.SetOuotaLimitMinEnable(const Value: Boolean);
begin
  FOuotaLimitMinEnable := Value;
  SetProcessWorkingSet;
end;

class procedure TMemoryDirector.SetOuotaLimitMaxEnable(const Value: Boolean);
begin
  FOuotaLimitMaxEnable := Value;
  SetProcessWorkingSet;
end;

class procedure TMemoryDirector.SetMinimumWorkingSetSize(const Value: SIZE_T);
begin
  FMinimumWorkingSetSize := Value;
  SetProcessWorkingSet;
end;

class procedure TMemoryDirector.SetMaximumWorkingSetSize(const Value: SIZE_T);
begin
  FMaximumWorkingSetSize := Value;
  SetProcessWorkingSet;
end;

class function TMemoryDirector.GetProcessWorkingSet: Boolean;
var
  Flags: DWORD;
begin
  Flags := 0;

  if IsWindowsVistaOrGreater then
    Result := GetProcessWorkingSetSizeEx(FProcess, FMinimumWorkingSetSize,
      FMaximumWorkingSetSize, Flags)
  else
    Result := GetProcessWorkingSetSize(FProcess, FMinimumWorkingSetSize,
      FMaximumWorkingSetSize);

  if Result then begin
    FOuotaLimitMinEnable := (Flags and QUOTA_LIMITS_HARDWS_MIN_ENABLE) <> 0;
    FOuotaLimitMaxEnable := (Flags and QUOTA_LIMITS_HARDWS_MAX_ENABLE) <> 0;
  end;
end;

class function TMemoryDirector.SetProcessWorkingSet: Boolean;
begin
  Result := SetWorkingSetSize(FMinimumWorkingSetSize, FMaximumWorkingSetSize);
end;

class function TMemoryDirector.SetWorkingSetSize(MinimumSize,
  MaximumSize: SIZE_T): Boolean;
var
  Flags: DWORD;
begin
  Result := False;
  Flags := 0;
  if FOuotaLimitMinEnable then
    Flags := Flags or QUOTA_LIMITS_HARDWS_MIN_ENABLE
  else
    Flags := Flags or QUOTA_LIMITS_HARDWS_MIN_DISABLE;

  if FOuotaLimitMaxEnable then
    Flags := Flags or QUOTA_LIMITS_HARDWS_MAX_ENABLE
  else
    Flags := Flags or QUOTA_LIMITS_HARDWS_MAX_DISABLE;

  if FInitialized then
    if IsWindowsVistaOrGreater then
      Result := SetProcessWorkingSetSizeEx(FProcess, MinimumSize, MaximumSize, Flags)
    else
      Result := SetProcessWorkingSetSize(FProcess, MinimumSize, MaximumSize);
end;

class procedure TMemoryDirector.Update;
begin
  FInitialized := GetProcessWorkingSet;
end;

class constructor TMemoryDirector.Create;
begin
  FProcess := GetCurrentProcess;
  Update;
end;

end.
