unit Brightness.Providers.Physical;

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.MultiMon,
  System.SysUtils, System.Classes,
  System.Generics.Collections, System.Generics.Defaults,
  Brightness, Brightness.Api,
  Versions.Helpers;

type
  TPhysicalMonitor = class(TBrightnessMonitorBase)
  private const
    DelayMin    = DWORD(50);
    DelayMax    = DWORD(1000);
  private
    FHandle: THandle;
    FDescription: string;
    FLogicalIndex: Integer;
    FPhysicalIndex: Integer;
    FActive: Boolean;
    FLevels: TBrightnessLevels;
    FLevel: Integer;
    FDelay: DWORD;
  protected
    function GetMonitorType: TBrightnessMonitorType; override;
    function GetDescription: string; override;
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
  public
    constructor Create(hPhysicalMonitor: THandle;
      Description: string; LogicalIndex, PhysicalIndex: Integer;
      AlwaysActive: Boolean); reintroduce;
    destructor Destroy; override;

    function GetDefaultConfig: TBrightnessConfig; override;

    property Handle: THandle read FHandle;
  end;

  TLogicalMonitor = class(TList<IBrightnessMonitor>)
  private
    FHandle: HMONITOR;
    FIndex: Integer;
    FPhysicalMonitorArraySize: DWORD;
    FPhysicalMonitorArray: array of PHYSICAL_MONITOR;
  public
    constructor Create(hLogicalMonitor: HMONITOR; Index: Integer;
      AlwaysActiveMonitors: Boolean); reintroduce;
    destructor Destroy; override;

    property Handle: HMONITOR read FHandle;
  end;

  TLogicalMonitors = class(TList<TLogicalMonitor>)
  private
    FAlwaysActiveMonitors: Boolean;
    class function EnumMonitorsProc(hm: HMONITOR; dc: HDC; r: PRect; Data: LPARAM): BOOL; stdcall; static;
  public
    constructor Create(AlwaysActiveMonitors: Boolean); reintroduce;
    destructor Destroy; override;
  end;

  TPhysicalBrightnessProvider = class(TInterfacedObject, IBrightnessProvider)
  protected
    FAlwaysActiveMonitors: Boolean;
    FLogicalMonitors: TLogicalMonitors;
    FOnNeedUpdate: TProviderNeedUpdateEvent;
    FMonitors: TList<IBrightnessMonitor>;
    function GetMonitors: TList<IBrightnessMonitor>;
    function GetOnNeedUpdate: TProviderNeedUpdateEvent;
    procedure SetOnNeedUpdate(const Value: TProviderNeedUpdateEvent);

    procedure MonitorError(Sender: TObject);
  public
    constructor Create(AlwaysActiveMonitors: Boolean = False); reintroduce;
    destructor Destroy; override;

    function Load: TList<IBrightnessMonitor>;
    procedure Clean;

    property Monitors: TList<IBrightnessMonitor> read GetMonitors;
  end;
implementation

{ TPhysicalMonitor }

constructor TPhysicalMonitor.Create(hPhysicalMonitor: THandle;
  Description: string; LogicalIndex, PhysicalIndex: Integer;
  AlwaysActive: Boolean);
var
  Minimum: DWORD;
  Current: DWORD;
  Maximum: DWORD;
  I: Integer;
begin
  inherited Create(AlwaysActive);

  FEnable := True;
  FHandle := hPhysicalMonitor;
  FDescription := Description;
  FLogicalIndex := LogicalIndex;
  FPhysicalIndex := PhysicalIndex;
  FActive := True;
  FDelay := DelayMin;

  if not GetMonitorBrightness(FHandle, Minimum, Current, Maximum) then
    raise TBrightnessMonitorException.Create;

  FLevels := TBrightnessLevels.Create;
  FLevels.Capacity := Maximum - Minimum + 1;
  for I := 0 to Maximum - Minimum do
    FLevels.Add(Byte(I) + Minimum);

  FLevel := Current - Minimum;
end;

destructor TPhysicalMonitor.Destroy;
begin
  FLevels.Free;

  inherited;
end;

function TPhysicalMonitor.GetDefaultConfig: TBrightnessConfig;
begin
  Result := TBrightnessConfig.Create(True, True, [], False);
end;

function TPhysicalMonitor.GetMonitorType: TBrightnessMonitorType;
begin
  Result := bmtExternal;
end;

function TPhysicalMonitor.GetDescription: string;
begin
  Result := FDescription;
end;

function TPhysicalMonitor.GetLevels: TBrightnessLevels;
begin
  Result := FLevels;
end;

function TPhysicalMonitor.GetLevel: Integer;
begin
  Result := FLevel;
end;

function TPhysicalMonitor.GetNormalizedBrightness(Level: Integer): Byte;
begin
  if FLevels.Last > 100 then
    Result := NormalizeBrightness(FLevels, Level)
  else
    Result := FLevels[Level];
end;

procedure TPhysicalMonitor.SetLevel(const Value: Integer);
begin
  FLevel := Value;
  if FLevel < 0 then FLevel := 0;
  if FLevel >= FLevels.Count then FLevel := FLevels.Count - 1;

  if not FEnable then Exit;

  while not SetMonitorBrightness(FHandle, FLevels[FLevel]) do
  begin
    if FDelay <= DelayMax then
    begin
      Sleep(FDelay); // Ожидание отклика старых мониторов
      FDelay := 2 * FDelay;
    end
    else
    begin
      FDelay := DelayMin;
      if Assigned(FOnError) then
        FOnError(Self);
      Exit;
    end;
  end;
  if FDelay > DelayMax then
    FDelay := DelayMax;

  if Assigned(FOnChangeLevel) then
    FOnChangeLevel(Self, FLevel);
end;

function TPhysicalMonitor.GetUniqueString: string;
const
  UniqueStringFmt = '%0:s; T=%1:d; LI=%2:d; PI=%3:d';
  MonType: array [TBrightnessMonitorType] of Integer = (0, 1);
begin
  Result := Format(UniqueStringFmt, [FDescription, MonType[MonitorType], FLogicalIndex, FPhysicalIndex]);
end;

function TPhysicalMonitor.GetSlowMonitor: Boolean;
begin
  Result := True;
end;

function TPhysicalMonitor.GetActive: Boolean;
begin
  Result := FActive;
end;

procedure TPhysicalMonitor.SetActive(const Value: Boolean);
begin
  if FActive = Value then Exit;
  if not FEnable then Exit;

  FActive := Value or FAlwaysActive;
  if Assigned(FConfig) then
    FConfig.Active := FActive;

  if Assigned(FOnChangeActive) then
    FOnChangeActive(Self, FActive);
end;

function TPhysicalMonitor.GetAdaptiveBrightness: Boolean;
begin
  Result := False;
end;

procedure TPhysicalMonitor.SetAdaptiveBrightness(const Value: Boolean);
begin
end;

function TPhysicalMonitor.GetAdaptiveBrightnessAvalible: Boolean;
begin
  Result := False;
end;

{ TLogicalMonitor }

constructor TLogicalMonitor.Create(hLogicalMonitor: HMONITOR; Index: Integer;
  AlwaysActiveMonitors: Boolean);
var
  I: Integer;
  Monitor: IBrightnessMonitor;
  MonitorInfo: TMonitorInfoEx;
  iPath: UInt32;
  iMode: UInt32;
  aPath: array of DISPLAYCONFIG_PATH_INFO;
  aMode: array of DISPLAYCONFIG_MODE_INFO;
  vName: DISPLAYCONFIG_TARGET_DEVICE_NAME;
  vAdapterName: DISPLAYCONFIG_ADAPTER_NAME;
  Name: string;
  Path: string;
  Device: string;
  DisplayDevice: TDisplayDevice;
  DeviceID: string;
begin
  inherited Create;

  FHandle := hLogicalMonitor;
  FIndex := Index;

  if not GetNumberOfPhysicalMonitorsFromHMONITOR(FHandle, FPhysicalMonitorArraySize) then Exit;

  SetLength(FPhysicalMonitorArray, FPhysicalMonitorArraySize);
  if not GetPhysicalMonitorsFromHMONITOR(FHandle, FPhysicalMonitorArraySize, @FPhysicalMonitorArray[0]) then Exit;

  ZeroMemory(@MonitorInfo, SizeOf(MonitorInfo));
  MonitorInfo.cbSize := SizeOf(MonitorInfo);
  GetMonitorInfo(hLogicalMonitor, @MonitorInfo);
  Device := string(MonitorInfo.szDevice);

  I := 0;
  DisplayDevice.cb := SizeOf(DisplayDevice);
  while EnumDisplayDevices(@MonitorInfo.szDevice[0], I, DisplayDevice, EDD_GET_DEVICE_INTERFACE_NAME) do
  begin
    DeviceID := string(DisplayDevice.DeviceID);
    I := I + 1;
    if DisplayDevice.StateFlags = DISPLAY_DEVICE_ACTIVE then Break;
  end;



  if IsWindows7OrGreater then
  begin
    if GetDisplayConfigBufferSizes(QDC_ALL_PATHS, iPath, iMode) = ERROR_SUCCESS then
    begin
      SetLength(aPath, iPath);
      SetLength(aMode, iMode);

      if QueryDisplayConfig(QDC_ALL_PATHS, iPath, @aPath[0], iMode, @aMode[0], nil) = ERROR_SUCCESS then
      begin
        for I := 0 to Integer(iMode) - 1 do
        begin
          if (aMode[i].infoType and DISPLAYCONFIG_MODE_INFO_TYPE_TARGET) = DISPLAYCONFIG_MODE_INFO_TYPE_TARGET then
          begin
            vName.header.size := SizeOf(DISPLAYCONFIG_TARGET_DEVICE_NAME);
            vName.header.adapterId := aMode[i].adapterId;
            vName.header.id := aMode[i].id;
            vName.header.typ := DISPLAYCONFIG_DEVICE_INFO_TYPE.DISPLAYCONFIG_DEVICE_INFO_GET_TARGET_NAME;
            if (DisplayConfigGetDeviceInfo(@vName)) = ERROR_SUCCESS then
            begin
              if DeviceID = string(vName.monitorDevicePath) then
              begin
                Name := string(vName.monitorFriendlyDeviceName);
              end;
            end;
          end;
        end;
      end;
    end;
  end;

  for I := 0 to FPhysicalMonitorArraySize - 1 do begin
    try
      Monitor := TPhysicalMonitor.Create(
        FPhysicalMonitorArray[I].hPhysicalMonitor,
        FPhysicalMonitorArray[I].szPhysicalMonitorDescription,
        FIndex, I, AlwaysActiveMonitors);
    except
      Continue;
    end;

    Add(Monitor);
  end;
end;

destructor TLogicalMonitor.Destroy;
begin
  DestroyPhysicalMonitors(FPhysicalMonitorArraySize, @FPhysicalMonitorArray[0]);

  inherited;
end;


{ TLogicalMonitors }

constructor TLogicalMonitors.Create(AlwaysActiveMonitors: Boolean);
begin
  inherited Create;

  FAlwaysActiveMonitors := AlwaysActiveMonitors;
  EnumDisplayMonitors(0, nil, @EnumMonitorsProc, Winapi.Windows.LPARAM(Self));
end;

destructor TLogicalMonitors.Destroy;
var
  Monitor: TLogicalMonitor;
begin
  for Monitor in Self do
    Monitor.Free;

  inherited;
end;

class function TLogicalMonitors.EnumMonitorsProc(hm: HMONITOR; dc: HDC;
  r: PRect; Data: LPARAM): BOOL;
var
  Self: TLogicalMonitors;
  LogicalMonitor: TLogicalMonitor;
begin
  Self := TLogicalMonitors(Data);
  LogicalMonitor := TLogicalMonitor.Create(hm, Self.Count, Self.FAlwaysActiveMonitors);
  if LogicalMonitor.Count = 0 then
  begin
    LogicalMonitor.Free;
    LogicalMonitor := TLogicalMonitor.Create(hm, Self.Count, Self.FAlwaysActiveMonitors);
  end;
  if LogicalMonitor.Count = 0 then
    LogicalMonitor.Free
  else
    Self.Add(LogicalMonitor);

  Result := True;
end;

{ TPhysicalBrightnessProvider }

constructor TPhysicalBrightnessProvider.Create(AlwaysActiveMonitors: Boolean = False);
begin
  inherited Create;

  FAlwaysActiveMonitors := AlwaysActiveMonitors;

  FMonitors := TList<IBrightnessMonitor>.Create;
end;

destructor TPhysicalBrightnessProvider.Destroy;
begin
  FLogicalMonitors.Free;
  FMonitors.Free;

  inherited;
end;

function TPhysicalBrightnessProvider.Load: TList<IBrightnessMonitor>;
var
  LogicalMonitor: TLogicalMonitor;
  Monitor: IBrightnessMonitor;
begin
  FMonitors.Clear;
  if Assigned(FLogicalMonitors) then
    FreeAndNil(FLogicalMonitors);

  FLogicalMonitors := TLogicalMonitors.Create(FAlwaysActiveMonitors);

  for LogicalMonitor in FLogicalMonitors do
    for Monitor in LogicalMonitor do
    begin
      (Monitor as TPhysicalMonitor).OnError := MonitorError;
      FMonitors.Add(Monitor);
    end;

  Result := FMonitors;
end;

procedure TPhysicalBrightnessProvider.MonitorError(Sender: TObject);
begin
  if Assigned(FOnNeedUpdate) then
    FOnNeedUpdate(Self);
end;

procedure TPhysicalBrightnessProvider.Clean;
begin
  FreeAndNil(FLogicalMonitors);
  FMonitors.Clear;
end;

function TPhysicalBrightnessProvider.GetMonitors: TList<IBrightnessMonitor>;
begin
  Result := FMonitors;
end;

function TPhysicalBrightnessProvider.GetOnNeedUpdate: TProviderNeedUpdateEvent;
begin
  Result := FOnNeedUpdate;
end;

procedure TPhysicalBrightnessProvider.SetOnNeedUpdate(
  const Value: TProviderNeedUpdateEvent);
begin
  FOnNeedUpdate := Value;
end;

end.
