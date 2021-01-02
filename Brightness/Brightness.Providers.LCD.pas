unit Brightness.Providers.LCD;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Classes,
  System.Generics.Collections, System.Generics.Defaults,
  Brightness;

const
  IOCTL_VIDEO_QUERY_SUPPORTED_BRIGHTNESS =
    FILE_DEVICE_VIDEO shl 16 or
    $125 shl 2 or
    METHOD_BUFFERED shl 14 or
    FILE_ANY_ACCESS;

  IOCTL_VIDEO_QUERY_DISPLAY_BRIGHTNESS =
    FILE_DEVICE_VIDEO shl 16 or
    $126 shl 2 or
    METHOD_BUFFERED shl 14 or
    FILE_ANY_ACCESS;

  IOCTL_VIDEO_SET_DISPLAY_BRIGHTNESS =
    FILE_DEVICE_VIDEO shl 16 or
    $127 shl 2 or
    METHOD_BUFFERED shl 14 or
    FILE_ANY_ACCESS;

type
  {$MinEnumSize 1}
  TDisplayPolicy = (
    DISPLAYPOLICY_AC    = $01,  // AC power.
    DISPLAYPOLICY_DC    = $02,  // DC power.
    DISPLAYPOLICY_BOTH  = $03   //Both AC and DC power.
  );

  {$EXTERNALSYM _DISPLAY_BRIGHTNESS}
  _DISPLAY_BRIGHTNESS = packed record
    ucDisplayPolicy: TDisplayPolicy;
    ucACBrightness: UCHAR;
    ucDCBrightness: UCHAR;
  end;
  {$EXTERNALSYM DISPLAY_BRIGHTNESS}
  DISPLAY_BRIGHTNESS = _DISPLAY_BRIGHTNESS;
  {$EXTERNALSYM PDISPLAY_BRIGHTNESS}
  PDISPLAY_BRIGHTNESS = ^DISPLAY_BRIGHTNESS;
  TDisplayBrightness = DISPLAY_BRIGHTNESS;
  PisplayBrightness = ^TDisplayBrightness;

  TLCDMonitor = class(TBrightnessMonitorBase)
  strict private const
    LCDDevice = '\\.\LCD';
    TimerCheckBrightness = 1;
  strict private
    FMsgWnd: HWND;
    FHandle: THandle;
    FDisplayPolicy: TDisplayPolicy;
    FActive: Boolean;
    FEnable: Boolean;
    FLevels: TBrightnessLevels;
    FLevel: Integer;
  protected
    function GetMonitorType: TBrightnessMonitorType; override;
    function GetDescription: string; override;
    function GetEnable: Boolean; override;
    procedure SetEnable(const Value: Boolean); override;
    function GetLevels: TBrightnessLevels; override;
    function GetLevel: Integer; override;
    procedure SetLevel(const Value: Integer); override;
    function GetNormalizedBrightness(Level: Integer): Byte; override;
    function GetUniqueString: string; override;
    function GetSlowMonitor: Boolean; override;
    function GetActive: Boolean; override;
    procedure SetActive(const Value: Boolean); override;
    function GetAdaptiveBrightness: Boolean; override;
    procedure SetAdaptiveBrightness(const Value: Boolean); override;
    function GetAdaptiveBrightnessAvalible: Boolean; override;
  strict private
    function GetDisplayBrightness(out Brightness: Byte): Boolean;
    function SetDisplayBrightness(Brightness: Byte; Both: Boolean = False): Boolean;

    function ACLineStatusToDisplayPolicy(ACLineStatus : Byte): TDisplayPolicy;

    procedure MsgWndHandle(var Msg: TMessage);
  public
    constructor Create(AlwaysActive: Boolean); reintroduce;
    destructor Destroy; override;
  public
    function GetDefaultConfig: TBrightnessConfig; override;

    property Handle: THandle read FHandle;
  end;

  TLCDBrightnessProvider = class(TInterfacedObject, IBrightnessProvider)
  strict private
    FAlwaysActiveMonitors: Boolean;
    FMonitors: TList<IBrightnessMonitor>;
    FOnNeedUpdate: TProviderNeedUpdateEvent;
  strict private
    function GetMonitors: TList<IBrightnessMonitor>;
    function GetOnNeedUpdate: TProviderNeedUpdateEvent;
    procedure SetOnNeedUpdate(const Value: TProviderNeedUpdateEvent);
  public
    constructor Create(AlwaysActiveMonitors: Boolean = False);
    destructor Destroy; override;

    procedure MonitorError(Sender: TObject);
  public
    function Load: TList<IBrightnessMonitor>;
    procedure Clean;

    property Monitors: TList<IBrightnessMonitor> read GetMonitors;
    property OnNeedUpdate: TProviderNeedUpdateEvent read GetOnNeedUpdate write SetOnNeedUpdate;
  end;

implementation

{ TLCDMonitor }

constructor TLCDMonitor.Create(AlwaysActive: Boolean);
var
  SystemPowerStatus: TSystemPowerStatus;
  SupportedLevels: array of Byte;
  SupportedLevelCount: DWORD;
  Brightness: Byte;
  I: Integer;
begin
  inherited Create(AlwaysActive);

  FEnable := True;
  FActive := True;
  FLevels := TBrightnessLevels.Create;

  try
    FHandle := CreateFile(
      LCDDevice,
      GENERIC_READ or GENERIC_WRITE,
      FILE_SHARE_READ or FILE_SHARE_WRITE,
      nil,
      OPEN_EXISTING,
      FILE_ATTRIBUTE_NORMAL,
      0);
    if FHandle = INVALID_HANDLE_VALUE then
      raise TBrightnessMonitorException.Create;

    SupportedLevelCount := 0;
    SetLength(SupportedLevels, 256);
    if not DeviceIoControl(FHandle, IOCTL_VIDEO_QUERY_SUPPORTED_BRIGHTNESS, nil, 0,
        @SupportedLevels[0], 256, SupportedLevelCount, nil) then
      raise TBrightnessMonitorException.Create;

    if SupportedLevelCount = 0 then
      raise TBrightnessMonitorException.Create('Not supported');

    FLevels.Capacity := SupportedLevelCount;
    for I := 0 to SupportedLevelCount - 1 do
      FLevels.Add(SupportedLevels[I]);

    if not GetDisplayBrightness(Brightness) then
      raise TBrightnessMonitorException.Create;

    FLevel := FLevels.IndexOf(Brightness);
    if FLevel = -1 then
      raise TBrightnessMonitorException.Create('Level not found');

    if not GetSystemPowerStatus(SystemPowerStatus) then
      raise TBrightnessMonitorException.Create;

    FDisplayPolicy := ACLineStatusToDisplayPolicy(SystemPowerStatus.ACLineStatus);
    FMsgWnd := AllocateHWnd(MsgWndHandle);

    SetTimer(FMsgWnd, TimerCheckBrightness, 1000, nil);
  except
    FLevels.Free;
    raise;
  end;
end;

destructor TLCDMonitor.Destroy;
begin
  KillTimer(FMsgWnd, TimerCheckBrightness);
  DeallocateHWnd(FMsgWnd);
  CloseHandle(FHandle);

  inherited;
end;

function TLCDMonitor.GetDisplayBrightness(out Brightness: Byte): Boolean;
var
  BufSize: DWORD;
  DispBrightness: TDisplayBrightness;
Begin
  BufSize := SizeOf(DispBrightness);
  Result := DeviceIoControl(FHandle, IOCTL_VIDEO_QUERY_DISPLAY_BRIGHTNESS, nil, 0,
    @DispBrightness, BufSize, BufSize, nil);

  if Result then
    case DispBrightness.ucDisplayPolicy of
      DISPLAYPOLICY_AC : Brightness := DispBrightness.ucACBrightness;
      DISPLAYPOLICY_DC : Brightness := DispBrightness.ucDCBrightness;
      else Brightness := DispBrightness.ucACBrightness;
    end;
end;

function TLCDMonitor.SetDisplayBrightness(Brightness: Byte; Both: Boolean = False): Boolean;
var
  BytesReturned: DWORD;
  DispBrightness: TDisplayBrightness;
begin
  ZeroMemory(@DispBrightness, SizeOf(DispBrightness));

  DispBrightness.ucDisplayPolicy := FDisplayPolicy;
  if Both then
    DispBrightness.ucDisplayPolicy := DISPLAYPOLICY_BOTH;
  DispBrightness.ucACBrightness := Brightness;
  DispBrightness.ucDCBrightness := Brightness;

  Result := DeviceIoControl(FHandle, IOCTL_VIDEO_SET_DISPLAY_BRIGHTNESS,
    @DispBrightness, SizeOf(DispBrightness), nil, 0, BytesReturned, nil);
end;

function TLCDMonitor.ACLineStatusToDisplayPolicy(
  ACLineStatus: Byte): TDisplayPolicy;
begin
  case ACLineStatus of
    AC_LINE_OFFLINE       : Exit(DISPLAYPOLICY_DC);
    AC_LINE_ONLINE        : Exit(DISPLAYPOLICY_AC);
    AC_LINE_BACKUP_POWER  : Exit(DISPLAYPOLICY_AC);
    else Exit(DISPLAYPOLICY_AC);
  end;
end;

procedure TLCDMonitor.MsgWndHandle(var Msg: TMessage);
var
  SystemPowerStatus: TSystemPowerStatus;
  DisplayPolicy: TDisplayPolicy;
  Brightness: Byte;
  Level: Integer;
begin
  Msg.Result := DefWindowProc(FMsgWnd, Msg.Msg, Msg.WParam, Msg.LParam);

  if (Msg.Msg = WM_TIMER) and (Msg.WParam = TimerCheckBrightness) then
  begin
    if GetDisplayBrightness(Brightness) then
    begin
      Level := FLevels.IndexOf(Brightness);
      if (FLevel <> Level) and (Level <> -1) then
      begin
        FLevel := Level;
        if Assigned(FOnChangeLevel) then
          FOnChangeLevel(Self, FLevel);
      end;
    end;

    Exit;
  end;

  if (Msg.Msg = WM_POWERBROADCAST) and (Msg.WParam = PBT_APMPOWERSTATUSCHANGE) then
  begin
    if not GetSystemPowerStatus(SystemPowerStatus) then Exit;

    DisplayPolicy := ACLineStatusToDisplayPolicy(SystemPowerStatus.ACLineStatus);
    if FDisplayPolicy <> DisplayPolicy then
    begin
      FDisplayPolicy := DisplayPolicy;
      if GetDisplayBrightness(Brightness) then
      begin
        Level := FLevels.IndexOf(Brightness);
        if (FLevel <> Level) and (Level <> -1) then
        begin
          FLevel := Level;
          if Assigned(FOnChangeLevel) then
            FOnChangeLevel(Self, FLevel);
        end;
      end;
    end;
  end;
end;

function TLCDMonitor.GetMonitorType: TBrightnessMonitorType;
begin
  Result := bmtInternal;
end;

function TLCDMonitor.GetDescription: string;
begin
  Result := 'LCD Display';
end;

function TLCDMonitor.GetEnable: Boolean;
begin
  Result := FEnable;
end;

procedure TLCDMonitor.SetEnable(const Value: Boolean);
begin
  if FEnable = Value then Exit;

  FEnable := Value;
  if Assigned(FConfig) then
    FConfig.Enable := FEnable;

  if Assigned(FOnChangeEnable) then
    FOnChangeEnable(Self, FEnable);

  if Assigned(FOnChangeEnable2) then
    FOnChangeEnable2(Self, FEnable);
end;

function TLCDMonitor.GetLevels: TBrightnessLevels;
begin
  Result := FLevels;
end;

function TLCDMonitor.GetLevel: Integer;
begin
  Result := FLevel;
end;

procedure TLCDMonitor.SetLevel(const Value: Integer);
begin
  if not FEnable then Exit;
  FLevel := Value;
  if FLevel < 0 then FLevel := 0;
  if FLevel >= FLevels.Count then FLevel := FLevels.Count - 1;

  if not SetDisplayBrightness(FLevels[FLevel]) then
  begin
    if Assigned(FOnError) then
      FOnError(Self);
    Exit;
  end;

  if Assigned(FOnChangeLevel) then
    FOnChangeLevel(Self, FLevel);
end;

function TLCDMonitor.GetNormalizedBrightness(Level: Integer): Byte;
begin
  Result := NormalizeBrightness(FLevels, Level);
end;

function TLCDMonitor.GetUniqueString: string;
begin
  Result := LCDDevice;
end;

function TLCDMonitor.GetSlowMonitor: Boolean;
begin
  Result := False;
end;

function TLCDMonitor.GetActive: Boolean;
begin
  Result := FActive;
end;

procedure TLCDMonitor.SetActive(const Value: Boolean);
begin
  if FActive = Value then Exit;
  if not FEnable then Exit;

  FActive := Value or FAlwaysActive;
  FConfig.Active := FActive;

  if Assigned(FOnChangeActive) then
    FOnChangeActive(Self, FActive);
end;

function TLCDMonitor.GetAdaptiveBrightness: Boolean;
begin
  Result := False;
end;

procedure TLCDMonitor.SetAdaptiveBrightness(const Value: Boolean);
begin
  // Not supported
end;

function TLCDMonitor.GetAdaptiveBrightnessAvalible: Boolean;
begin
  Result := False;
end;

function TLCDMonitor.GetDefaultConfig: TBrightnessConfig;
begin
  Result := TBrightnessConfig.Create(True, True, [], False);
end;

{ TLCDBrightnessProvider }

constructor TLCDBrightnessProvider.Create(AlwaysActiveMonitors: Boolean);
begin
  inherited Create;

  FAlwaysActiveMonitors := AlwaysActiveMonitors;
  FMonitors := TList<IBrightnessMonitor>.Create;
end;

destructor TLCDBrightnessProvider.Destroy;
begin
  FMonitors.Free;

  inherited;
end;

procedure TLCDBrightnessProvider.MonitorError(Sender: TObject);
begin
  if Assigned(FOnNeedUpdate) then
    FOnNeedUpdate(Self);
end;

function TLCDBrightnessProvider.GetMonitors: TList<IBrightnessMonitor>;
begin
  Result := FMonitors;
end;

function TLCDBrightnessProvider.GetOnNeedUpdate: TProviderNeedUpdateEvent;
begin
  Result := FOnNeedUpdate;
end;

procedure TLCDBrightnessProvider.SetOnNeedUpdate(const Value: TProviderNeedUpdateEvent);
begin
  FOnNeedUpdate := Value;
end;

function TLCDBrightnessProvider.Load: TList<IBrightnessMonitor>;
var
  Monitor: IBrightnessMonitor;
begin
  FMonitors.Clear;

  try
    Monitor := TLCDMonitor.Create(FAlwaysActiveMonitors);
    (Monitor as TLCDMonitor).OnError := MonitorError;
    FMonitors.Add(Monitor);
  except
  end;

  Result := FMonitors;
end;

procedure TLCDBrightnessProvider.Clean;
begin
  FMonitors.Clear;
end;

end.
