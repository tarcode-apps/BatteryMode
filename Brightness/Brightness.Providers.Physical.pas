unit Brightness.Providers.Physical;

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.MultiMon,
  System.SysUtils, System.Classes,
  System.Generics.Collections, System.Generics.Defaults,
  Brightness, Brightness.Api;

type
  TPhysicalMonitor = class(TInterfacedObject, IBrightnessMonitor)
  private const
    DelayMin    = DWORD(50);
    DelayMax    = DWORD(1000);
  private
    FHandle: THandle;
    FDescription: string;
    FLogicalIndex: Integer;
    FPhysicalIndex: Integer;
    FAlwaysActive: Boolean;
    FActive: Boolean;
    FEnable: Boolean;
    FLevels: TBrightnessLevels;
    FLevel: Integer;
    FManagementMethods: TBrightnessMonitorManagementMethods;
    FConfig: TBrightnessConfig;
    FDelay: DWORD;

    FOnChangeLevel: TBrightnessChangeLevelEvent;
    FOnChangeActive: TBrightnessChangeActiveEvent;
    FOnChangeEnable: TBrightnessChangeEnableEvent;
    FOnChangeEnable2: TBrightnessChangeEnableEvent;
    FOnChangeAdaptiveBrightness: TBrightnessChangeAdaptiveBrightnessEvent;
    FOnChangeManagementMethods: TBrightnessChangeManagementMethodsEvent;
    FOnError: TNotifyEvent;
  protected
    function GetMonitorType: TBrightnessMonitorType;
    function GetDescription: string;
    function GetEnable: Boolean;
    procedure SetEnable(const Value: Boolean);
    function GetLevels: TBrightnessLevels;
    function GetLevel: Integer;
    procedure SetLevel(const Value: Integer);
    function GetNormalizedBrightness(Level: Integer): Byte;
    function GetUniqueString: string;
    function GetSlowMonitor: Boolean;
    function GetActive: Boolean;
    procedure SetActive(const Value: Boolean);
    function GetAdaptiveBrightness: Boolean;
    procedure SetAdaptiveBrightness(const Value: Boolean);
    function GetAdaptiveBrightnessAvalible: Boolean;
    function GetManagementMethods: TBrightnessMonitorManagementMethods;
    procedure SetManagementMethods(const Value: TBrightnessMonitorManagementMethods);

    function GetOnChangeLevel: TBrightnessChangeLevelEvent;
    procedure SetOnChangeLevel(const Value: TBrightnessChangeLevelEvent);
    function GetOnChangeActive: TBrightnessChangeActiveEvent;
    procedure SetOnChangeActive(const Value: TBrightnessChangeActiveEvent);
    function GetOnChangeEnable: TBrightnessChangeEnableEvent;
    procedure SetOnChangeEnable(const Value: TBrightnessChangeEnableEvent);
    function GetOnChangeEnable2: TBrightnessChangeEnableEvent;
    procedure SetOnChangeEnable2(const Value: TBrightnessChangeEnableEvent);
    function GetOnChangeAdaptiveBrightness: TBrightnessChangeAdaptiveBrightnessEvent;
    procedure SetOnChangeAdaptiveBrightness(const Value: TBrightnessChangeAdaptiveBrightnessEvent);
    function GetOnChangeManagementMethods: TBrightnessChangeManagementMethodsEvent;
    procedure SetOnChangeManagementMethods(const Value: TBrightnessChangeManagementMethodsEvent);
  public
    constructor Create(hPhysicalMonitor: THandle;
      Description: string; LogicalIndex, PhysicalIndex: Integer;
      AlwaysActive: Boolean); reintroduce;
    destructor Destroy; override;

    procedure LoadConfig(Config: TBrightnessConfig);
    function GetDefaultConfig: TBrightnessConfig;

    property MonitorType: TBrightnessMonitorType read GetMonitorType;
    property Description: string read GetDescription;
    property Enable: Boolean read GetEnable write SetEnable;
    property Levels: TBrightnessLevels read GetLevels;
    property Level: Integer read GetLevel write SetLevel;
    property NormalizedBrightness[Level: Integer]: Byte read GetNormalizedBrightness;
    property UniqueString: string read GetUniqueString;
    property SlowMonitor: Boolean read GetSlowMonitor;
    property Active: Boolean read GetActive write SetActive;
    property AdaptiveBrightness: Boolean read GetAdaptiveBrightness write SetAdaptiveBrightness;
    property AdaptiveBrightnessAvalible: Boolean read GetAdaptiveBrightnessAvalible;
    property ManagementMethods: TBrightnessMonitorManagementMethods read GetManagementMethods write SetManagementMethods;

    property Handle: THandle read FHandle;
    property OnError: TNotifyEvent read FOnError write FOnError;
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
  FEnable := True;
  FHandle := hPhysicalMonitor;
  FDescription := Description;
  FLogicalIndex := LogicalIndex;
  FPhysicalIndex := PhysicalIndex;
  FAlwaysActive := AlwaysActive;
  FActive := True;
  FManagementMethods := [];
  FDelay := DelayMin;

  if not GetMonitorBrightness(FHandle, Minimum, Current, Maximum) then
    raise TBrightnessMonitorException.Create;

  inherited Create;

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

procedure TPhysicalMonitor.LoadConfig(Config: TBrightnessConfig);
begin
  FConfig := Config;
  Enable := FConfig.Enable;
  Active := FConfig.Active or FAlwaysActive;
  ManagementMethods := FConfig.ManagementMethods;
end;

function TPhysicalMonitor.GetDefaultConfig: TBrightnessConfig;
begin
  Result := TBrightnessConfig.Create(True, True, []);
end;

function TPhysicalMonitor.GetMonitorType: TBrightnessMonitorType;
begin
  Result := bmtExternal;
end;

function TPhysicalMonitor.GetDescription: string;
begin
  Result := FDescription;
end;

function TPhysicalMonitor.GetEnable: Boolean;
begin
  Result := FEnable;
end;

procedure TPhysicalMonitor.SetEnable(const Value: Boolean);
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

function TPhysicalMonitor.GetManagementMethods: TBrightnessMonitorManagementMethods;
begin
  Result := FManagementMethods;
end;

procedure TPhysicalMonitor.SetManagementMethods(
  const Value: TBrightnessMonitorManagementMethods);
begin
  if FManagementMethods = Value then Exit;

  FManagementMethods := Value;

  if Assigned(FConfig) then
    FConfig.ManagementMethods := FManagementMethods;

  if Assigned(FOnChangeManagementMethods) then
    FOnChangeManagementMethods(Self, FManagementMethods);
end;

{$REGION 'Event Get/Set'}
function TPhysicalMonitor.GetOnChangeLevel: TBrightnessChangeLevelEvent;
begin
  Result := FOnChangeLevel;
end;

procedure TPhysicalMonitor.SetOnChangeLevel(const Value: TBrightnessChangeLevelEvent);
begin
  FOnChangeLevel := Value;
end;

function TPhysicalMonitor.GetOnChangeActive: TBrightnessChangeActiveEvent;
begin
  Result := FOnChangeActive;
end;

procedure TPhysicalMonitor.SetOnChangeActive(const Value: TBrightnessChangeActiveEvent);
begin
  FOnChangeActive := Value;
end;

function TPhysicalMonitor.GetOnChangeEnable: TBrightnessChangeEnableEvent;
begin
  Result := FOnChangeEnable;
end;

procedure TPhysicalMonitor.SetOnChangeEnable(const Value: TBrightnessChangeEnableEvent);
begin
  FOnChangeEnable := Value;
end;

function TPhysicalMonitor.GetOnChangeEnable2: TBrightnessChangeEnableEvent;
begin
  Result := FOnChangeEnable2;
end;

procedure TPhysicalMonitor.SetOnChangeEnable2(const Value: TBrightnessChangeEnableEvent);
begin
  FOnChangeEnable2 := Value;
end;

function TPhysicalMonitor.GetOnChangeAdaptiveBrightness: TBrightnessChangeAdaptiveBrightnessEvent;
begin
  Result := FOnChangeAdaptiveBrightness;
end;

procedure TPhysicalMonitor.SetOnChangeAdaptiveBrightness(
  const Value: TBrightnessChangeAdaptiveBrightnessEvent);
begin
  FOnChangeAdaptiveBrightness := Value;
end;

function TPhysicalMonitor.GetOnChangeManagementMethods: TBrightnessChangeManagementMethodsEvent;
begin
  Result := FOnChangeManagementMethods;
end;

procedure TPhysicalMonitor.SetOnChangeManagementMethods(
  const Value: TBrightnessChangeManagementMethodsEvent);
begin
  FOnChangeManagementMethods := Value;
end;
{$ENDREGION}

{ TLogicalMonitor }

constructor TLogicalMonitor.Create(hLogicalMonitor: HMONITOR; Index: Integer;
  AlwaysActiveMonitors: Boolean);
var
  I: Integer;
  Monitor: IBrightnessMonitor;
begin
  inherited Create;

  FHandle := hLogicalMonitor;
  FIndex := Index;

  if not GetNumberOfPhysicalMonitorsFromHMONITOR(FHandle, FPhysicalMonitorArraySize) then Exit;

  SetLength(FPhysicalMonitorArray, FPhysicalMonitorArraySize);
  if not GetPhysicalMonitorsFromHMONITOR(FHandle, FPhysicalMonitorArraySize, @FPhysicalMonitorArray[0]) then Exit;

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
begin
  Self := TLogicalMonitors(Data);
  Self.Add(TLogicalMonitor.Create(hm, Self.Count, Self.FAlwaysActiveMonitors));
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
