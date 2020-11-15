unit Brightness.Providers.WMI;

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.ActiveX,
  System.SysUtils, System.Classes, System.Variants, System.SyncObjs,
  System.Generics.Collections, System.Generics.Defaults,
  Core.Language,
  Brightness,
  Power.WinApi.PowrProf,
  JwaWbemCli;

type
  TInstanceName = string;

  TSinkIndicateEvent = procedure(Sender: TObject; objWbemObject: IWbemClassObject) of object;

  TWmiEventListener = class(TThread)
  private
    FLocator: IWbemLocator;
    FServices: IWbemServices;
    FEventObject: IWbemClassObject;
    FOnIndicate: TSinkIndicateEvent;
  protected
    procedure Execute; override;
    procedure TerminatedSet; override;
    procedure CallOnIndicate;
  public
    constructor Create; overload;

    property OnIndicate: TSinkIndicateEvent read FOnIndicate write FOnIndicate;
  end;

  TWmiSetBrightnessThread = class
  private type
    TValueEvent = class(TEvent)
    public
      Result: Boolean;
      procedure SetEvent(EventResult: Boolean); overload;
    end;

    TThreadExecuteStartup = record
      ThreadAvalibleEvent: TValueEvent;
      InstanceName : TInstanceName;
    end;
  private const
    WM_SETBRIGHTNESS = WM_USER + 1;
  private
    FInstanceName : TInstanceName;
    ThreadID: DWORD;
    Handle: THandle;

    class function ThreadExecute(lpParameter: LPVOID): DWORD; stdcall; static;
  public
    constructor Create(InstanceName: TInstanceName); reintroduce;
    destructor Destroy; override;

    procedure Terminate;
    function SetBrightness(Brightness: Byte): Boolean;
  end;

  TWMIMonitor = class(TInterfacedObject, IBrightnessMonitor)
  public
    class var AdaptiveBrightnessForAllScheme: Boolean;
    class var BatterySaver: Boolean;
    class var EnergySaverBrightness: DWORD;
    class function ApplyAdaptiveBrightness(Value: Boolean): Boolean;
  private
    FInstanceName: TInstanceName;
    FWmiMonitorBrightness: IWbemClassObject;
    FServices: IWbemServices;
    FAlwaysActive: Boolean;
    FActive: Boolean;
    FEnable: Boolean;
    FLevels: TBrightnessLevels;
    FLevel: Integer;
    FDescription: string;
    FAdaptiveBrightness: Boolean;
    FManagementMethods: TBrightnessMonitorManagementMethods;
    FConfig: TBrightnessConfig;

    FWmiSetBrightnessThread: TWmiSetBrightnessThread;

    FOnChangeLevel: TBrightnessChangeLevelEvent;
    FOnChangeActive: TBrightnessChangeActiveEvent;
    FOnChangeEnable: TBrightnessChangeEnableEvent;
    FOnChangeEnable2: TBrightnessChangeEnableEvent;
    FOnChangeAdaptiveBrightness: TBrightnessChangeAdaptiveBrightnessEvent;
    FOnChangeManagementMethods: TBrightnessChangeManagementMethodsEvent;
    FOnError: TNotifyEvent;
  private
    class constructor Create;
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

    function DisplayNameFromInstanceName(InstanceName: TInstanceName): string;
  public
    constructor Create(Services: IWbemServices;
      WmiMonitorBrightness: IWbemClassObject;
      AlwaysActive: Boolean); reintroduce;
    destructor Destroy; override;

    procedure BrightnessChanged(Brightness: Byte);
    procedure AdaptiveBrightnessChanged(AdaptiveBrightness: Boolean);

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

    property InstanceName: TInstanceName read FInstanceName;

    property OnError: TNotifyEvent read FOnError write FOnError;
  end;

  TWMIBrightnessProvider = class(TInterfacedObject, IBrightnessProvider)
  protected
    FAlwaysActiveMonitors: Boolean;
    FOnNeedUpdate: TProviderNeedUpdateEvent;
    FMonitors: TList<IBrightnessMonitor>;
    FLocator: IWbemLocator;
    FServices: IWbemServices;
    FWmiEventListener: TWmiEventListener;
    FMsgWindow: THandle;
    FNotifyAdaptiveDisplayBrightness  : HPOWERNOTIFY;
    FNotifyPowerSavingStatus          : HPOWERNOTIFY;
    FNotifyEnergySaverBrightness      : HPOWERNOTIFY;
    FAdaptiveDisplayBrightness: Boolean;

    function GetMonitors: TList<IBrightnessMonitor>;
    function GetOnNeedUpdate: TProviderNeedUpdateEvent;
    procedure SetOnNeedUpdate(const Value: TProviderNeedUpdateEvent);
    function GetAdaptiveBrightnessForAllScheme: Boolean;
    procedure SetAdaptiveBrightnessForAllScheme(const Value: Boolean);

    function RegisterBrightnessEvent: Boolean;
    function UnregisterBrightnessEvent: Boolean;
    procedure BrightnessEvent(ASender: TObject; objWbemObject: IWbemClassObject);
    procedure MsgWindowProc(var Msg: TMessage);

    procedure UpdateAdaptiveDisplayBrightness(Value: BOOL);
    procedure UpdateBatterySaver(Value: Boolean);
    procedure UpdateEnergySaverBrightness(Value: DWORD);

    procedure MonitorError(Sender: TObject);
  public
    constructor Create(AlwaysActiveMonitors: Boolean = False); reintroduce;
    destructor Destroy; override;

    function Load: TList<IBrightnessMonitor>;
    procedure Clean;

    property Monitors: TList<IBrightnessMonitor> read GetMonitors;

    property AdaptiveBrightnessForAllScheme: Boolean read GetAdaptiveBrightnessForAllScheme write SetAdaptiveBrightnessForAllScheme;
  end;

implementation

const
  strServer     = WideString('.');
  strNamespace  = WideString('root\WMI');
  strUser       = WideString('');
  strPassword   = WideString('');

  WQLBrightness         = WideString('SELECT * FROM WmiMonitorBrightness WHERE Active = TRUE');
  WQLBrightnessMethods  = WideString('SELECT * FROM WmiMonitorBrightnessMethods');
  WQLBrightnessEvent    = WideString('SELECT * FROM WmiMonitorBrightnessEvent');

const
  RPC_C_AUTHN_LEVEL_DEFAULT = 0;
  RPC_C_IMP_LEVEL_IMPERSONATE = 3;
  RPC_C_AUTHN_WINNT = 10;
  RPC_C_AUTHZ_NONE = 0;
  RPC_C_AUTHN_LEVEL_CALL = 3;
  EOAC_NONE = 0;

{ TWMIMonitor }

constructor TWMIMonitor.Create(Services: IWbemServices;
  WmiMonitorBrightness: IWbemClassObject;
  AlwaysActive: Boolean);
var
  hr        : HRESULT;
  pVal      : OleVariant;
  pType     : Integer;
  plFlavor  : Integer;

  LevelArray      : OleVariant;
  LevelArraySize  : UInt32;
  I: Integer;
  Brightness  : UInt8;
begin
  inherited Create;

  FServices := Services;
  FWmiMonitorBrightness := WmiMonitorBrightness;

  FAlwaysActive := AlwaysActive;
  FEnable := True;
  FActive := True;
  FManagementMethods := [];

  hr := WmiMonitorBrightness.Get('Level', 0, pVal, pType, plFlavor);
  if hr <> WBEM_S_NO_ERROR then
    raise TBrightnessMonitorException.Create('Could not get Level');

  LevelArray  := pVal;
  LevelArraySize := VarArrayHighBound(LevelArray, 1) - VarArrayLowBound(LevelArray, 1) + 1;
  if LevelArraySize <= 0 then
    raise TBrightnessMonitorException.Create('Not supported');

  FLevels := TBrightnessLevels.Create;
  FLevels.Capacity := LevelArraySize;

  for I := 0 to LevelArraySize - 1 do
    FLevels.Add(UInt8(LevelArray[I]));

  VarClear(LevelArray);
  VarClear(pVal);

  hr := WmiMonitorBrightness.Get('CurrentBrightness', 0, pVal, pType, plFlavor);
  if hr <> WBEM_S_NO_ERROR then
    raise TBrightnessMonitorException.Create('Could not get CurrentBrightness');

  Brightness  := UInt8(pVal);
  VarClear(pVal);

  FLevel := FLevels.IndexOf(Brightness);
  if FLevel = -1 then
    raise TBrightnessMonitorException.Create('Level not found');

  hr := WmiMonitorBrightness.Get('InstanceName', 0, pVal, pType, plFlavor);
  if hr <> WBEM_S_NO_ERROR then
    raise TBrightnessMonitorException.Create('Could not get InstanceName');

  FInstanceName  := TInstanceName(pVal);
  VarClear(pVal);

  FDescription := DisplayNameFromInstanceName(FInstanceName);

  FWmiSetBrightnessThread := TWmiSetBrightnessThread.Create(FInstanceName);
end;

destructor TWMIMonitor.Destroy;
begin
  FWmiSetBrightnessThread.Free;

  FLevels.Free;
  FWmiMonitorBrightness := nil;
  FServices := nil;

  inherited;
end;

class function TWMIMonitor.ApplyAdaptiveBrightness(Value: Boolean): Boolean;
var
  dwValue: DWORD;
  Status: DWORD;
  SystemPowerStatus: TSystemPowerStatus;
  ActiveScheme: TGUID;

  function GetActiveScheme: TGUID;
  var
    Buffer: PGUID;
  begin
    if PowerGetActiveScheme(0, @Buffer) = ERROR_SUCCESS then begin
      Result := Buffer^;
      LocalFree(HLOCAL(Buffer));
    end else
      Result := TGUID.Empty;
  end;
begin
  if Value then dwValue := 1 else dwValue := 0;

  ActiveScheme := GetActiveScheme;
  if ActiveScheme = TGUID.Empty then Exit(False);

  if AdaptiveBrightnessForAllScheme then
  begin
    Result := True;

    Status := PowerWriteACValueIndex(0, @ALL_POWERSCHEMES_GUID,
      @GUID_VIDEO_SUBGROUP, @GUID_VIDEO_ADAPTIVE_DISPLAY_BRIGHTNESS,
      dwValue);
    Result := Result and (Status = ERROR_SUCCESS);

    Status := PowerWriteDCValueIndex(0, @ALL_POWERSCHEMES_GUID,
      @GUID_VIDEO_SUBGROUP, @GUID_VIDEO_ADAPTIVE_DISPLAY_BRIGHTNESS,
      dwValue);
    Result := Result and (Status = ERROR_SUCCESS);
  end
  else
  begin
    GetSystemPowerStatus(SystemPowerStatus);
    if SystemPowerStatus.ACLineStatus = AC_LINE_ONLINE then
      Status := PowerWriteACValueIndex(0, @ActiveScheme,
        @GUID_VIDEO_SUBGROUP, @GUID_VIDEO_ADAPTIVE_DISPLAY_BRIGHTNESS,
        dwValue)
    else
      Status := PowerWriteDCValueIndex(0, @ActiveScheme,
        @GUID_VIDEO_SUBGROUP, @GUID_VIDEO_ADAPTIVE_DISPLAY_BRIGHTNESS,
        dwValue);
    Result := (Status = ERROR_SUCCESS);
  end;

  if Result then
    PowerSetActiveScheme(0, @ActiveScheme);
end;

procedure TWMIMonitor.BrightnessChanged(Brightness: Byte);
begin
  FLevel := FLevels.IndexOf(Brightness);

  if Assigned(FOnChangeLevel) then
    FOnChangeLevel(Self, FLevel);
end;

procedure TWMIMonitor.AdaptiveBrightnessChanged(AdaptiveBrightness: Boolean);
begin
  FAdaptiveBrightness := AdaptiveBrightness;

  if Assigned(FOnChangeAdaptiveBrightness) then
    FOnChangeAdaptiveBrightness(Self, FAdaptiveBrightness);
end;

function TWMIMonitor.DisplayNameFromInstanceName(
  InstanceName: TInstanceName): string;
var
  AdapNum: DWORD;
  DispNum: DWORD;
  AdaptorDevice: TDisplayDevice;
  DisplayDevice: TDisplayDevice;

  function DeviceName(Instance: string): string;
  begin
    try
      Result := Instance.Split([PathDelim])[1];
    except
      Result := '';
    end;
  end;

  function EqualDevice(InstanceLeft, InstanceRight: string): Boolean;
  var
    NameLeft, NameRight: string;
  begin
    NameLeft  := DeviceName(InstanceLeft);
    NameRight := DeviceName(InstanceRight);
    Result := (not NameLeft.IsEmpty) and (string.CompareText(NameLeft, NameRight) = 0);
  end;
begin
  Result := TLang[52]; // Экран ноутбука
  AdapNum := 0;
  ZeroMemory(@AdaptorDevice, SizeOf(AdaptorDevice));
	AdaptorDevice.cb := SizeOf(AdaptorDevice);
  while EnumDisplayDevices(nil, AdapNum, AdaptorDevice, 0) do
    try
      DispNum := 0;
      ZeroMemory(@DisplayDevice, SizeOf(DisplayDevice));
      DisplayDevice.cb := SizeOf(DisplayDevice);

      while EnumDisplayDevices(LPCTSTR(@AdaptorDevice.DeviceName[0]), DispNum, DisplayDevice, 0) do
        try
          if EqualDevice(DisplayDevice.DeviceID, InstanceName) then
          begin
            if string(DisplayDevice.DeviceString) <> 'Generic PnP Monitor' then
              Result := string(DisplayDevice.DeviceString);

            Exit(Result);
          end;
        finally
          ZeroMemory(@DisplayDevice, SizeOf(DisplayDevice));
          DisplayDevice.cb := SizeOf(DisplayDevice);
          Inc(DispNum);
        end;
    finally
      ZeroMemory(@AdaptorDevice, SizeOf(AdaptorDevice));
      AdaptorDevice.cb := SizeOf(AdaptorDevice);
      Inc(AdapNum);
    end;
end;

procedure TWMIMonitor.LoadConfig(Config: TBrightnessConfig);
begin
  FConfig := Config;
  Enable := FConfig.Enable;
  Active := FConfig.Active or FAlwaysActive;
  ManagementMethods := FConfig.ManagementMethods;
end;

function TWMIMonitor.GetDefaultConfig: TBrightnessConfig;
begin
  Result := TBrightnessConfig.Create(True, True, []);
end;

function TWMIMonitor.GetMonitorType: TBrightnessMonitorType;
begin
  Result := bmtInternal;
end;

function TWMIMonitor.GetDescription: string;
begin
  Result := FDescription;
end;

function TWMIMonitor.GetEnable: Boolean;
begin
  Result := FEnable;
end;

procedure TWMIMonitor.SetEnable(const Value: Boolean);
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

function TWMIMonitor.GetLevels: TBrightnessLevels;
begin
  Result := FLevels;
end;

function TWMIMonitor.GetLevel: Integer;
begin
  Result := FLevel;
end;

procedure TWMIMonitor.SetLevel(const Value: Integer);
var
  PreparedBrightness: DWORD;
begin
  if FLevel = Value then Exit;
  if not FEnable then Exit;
  FLevel := Value;
  if FLevel < 0 then FLevel := 0;
  if FLevel >= FLevels.Count then FLevel := FLevels.Count - 1;

  if BatterySaver then
    PreparedBrightness := FLevels[FLevel] * 100 div EnergySaverBrightness
  else
    PreparedBrightness := FLevels[FLevel];

  if not FWmiSetBrightnessThread.SetBrightness(PreparedBrightness) then
  begin
    if Assigned(FOnError) then
      FOnError(Self);
  end;
end;

function TWMIMonitor.GetNormalizedBrightness(Level: Integer): Byte;
begin
  Result := NormalizeBrightness(FLevels, Level);
end;

function TWMIMonitor.GetUniqueString: string;
const
  UniqueStringFmt = '%0:s; T=%1:d';
  MonType: array [TBrightnessMonitorType] of Integer = (0, 1);
begin 
  Result := Format(UniqueStringFmt, [FInstanceName, MonType[MonitorType]]);
end;

function TWMIMonitor.GetSlowMonitor: Boolean;
begin
  Result := False;
end;

function TWMIMonitor.GetActive: Boolean;
begin
  Result := FActive;
end;

procedure TWMIMonitor.SetActive(const Value: Boolean);
begin
  if FActive = Value then Exit;
  if not FEnable then Exit;

  FActive := Value or FAlwaysActive;
  FConfig.Active := FActive;

  if Assigned(FOnChangeActive) then
    FOnChangeActive(Self, FActive);
end;

function TWMIMonitor.GetAdaptiveBrightness: Boolean;
begin
  Result := FAdaptiveBrightness;
end;

procedure TWMIMonitor.SetAdaptiveBrightness(const Value: Boolean);
begin
  if not AdaptiveBrightnessAvalible then Exit;
  ApplyAdaptiveBrightness(Value);
end;

function TWMIMonitor.GetAdaptiveBrightnessAvalible: Boolean;
var
  Status: DWORD;
begin
  Status := PowerReadSettingAttributes(@GUID_VIDEO_SUBGROUP, @GUID_VIDEO_ADAPTIVE_DISPLAY_BRIGHTNESS);
  Result := (Status <> 0) and (Status <> POWER_ATTRIBUTE_HIDE);
end;

function TWMIMonitor.GetManagementMethods: TBrightnessMonitorManagementMethods;
begin
  Result := FManagementMethods;
end;

procedure TWMIMonitor.SetManagementMethods(
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
function TWMIMonitor.GetOnChangeLevel: TBrightnessChangeLevelEvent;
begin
  Result := FOnChangeLevel;
end;

procedure TWMIMonitor.SetOnChangeLevel(const Value: TBrightnessChangeLevelEvent);
begin
  FOnChangeLevel := Value;
end;

function TWMIMonitor.GetOnChangeActive: TBrightnessChangeActiveEvent;
begin
  Result := FOnChangeActive;
end;

procedure TWMIMonitor.SetOnChangeActive(const Value: TBrightnessChangeActiveEvent);
begin
  FOnChangeActive := Value;
end;

function TWMIMonitor.GetOnChangeEnable: TBrightnessChangeEnableEvent;
begin
  Result := FOnChangeEnable;
end;

procedure TWMIMonitor.SetOnChangeEnable(const Value: TBrightnessChangeEnableEvent);
begin
  FOnChangeEnable := Value;
end;

function TWMIMonitor.GetOnChangeEnable2: TBrightnessChangeEnableEvent;
begin
  Result := FOnChangeEnable2;
end;

procedure TWMIMonitor.SetOnChangeEnable2(const Value: TBrightnessChangeEnableEvent);
begin
  FOnChangeEnable2 := Value;
end;

function TWMIMonitor.GetOnChangeAdaptiveBrightness: TBrightnessChangeAdaptiveBrightnessEvent;
begin
  Result := FOnChangeAdaptiveBrightness;
end;

procedure TWMIMonitor.SetOnChangeAdaptiveBrightness(
  const Value: TBrightnessChangeAdaptiveBrightnessEvent);
begin
  FOnChangeAdaptiveBrightness := Value;
end;

function TWMIMonitor.GetOnChangeManagementMethods: TBrightnessChangeManagementMethodsEvent;
begin
  Result := FOnChangeManagementMethods;
end;

procedure TWMIMonitor.SetOnChangeManagementMethods(
  const Value: TBrightnessChangeManagementMethodsEvent);
begin
  FOnChangeManagementMethods := Value;
end;
{$ENDREGION}

class constructor TWMIMonitor.Create;
begin
  BatterySaver := False;
  EnergySaverBrightness := 100;
end;


{ TWMIBrightnessProvider }

constructor TWMIBrightnessProvider.Create(AlwaysActiveMonitors: Boolean = False);
var
  hr: HRESULT;
begin
  inherited Create;

  FAlwaysActiveMonitors := AlwaysActiveMonitors;
  TWMIMonitor.AdaptiveBrightnessForAllScheme := False;
  FAdaptiveDisplayBrightness := False;

  FMonitors := TList<IBrightnessMonitor>.Create;

  CoInitializeEx(nil, COINIT_MULTITHREADED);

  hr := CoInitializeSecurity(nil, -1, nil, nil,
    RPC_C_AUTHN_LEVEL_DEFAULT, RPC_C_IMP_LEVEL_IMPERSONATE, nil, EOAC_NONE, nil);
  if Failed(hr) then Exit;

  hr := CoCreateInstance(CLSID_WbemLocator, nil, CLSCTX_INPROC_SERVER, IID_IWbemLocator, FLocator);
  if Failed(hr) then Exit;

  hr := FLocator.ConnectServer(strNamespace, strUser, strPassword, '',
    WBEM_FLAG_CONNECT_USE_MAX_WAIT, '', nil, FServices);
  if Failed(hr) then Exit;

  FMsgWindow := AllocateHWnd(MsgWindowProc);

  FNotifyAdaptiveDisplayBrightness := RegisterPowerSettingNotification(
            FMsgWindow,
            GUID_VIDEO_ADAPTIVE_DISPLAY_BRIGHTNESS,
            DEVICE_NOTIFY_WINDOW_HANDLE);
  FNotifyPowerSavingStatus := RegisterPowerSettingNotification(
            FMsgWindow,
            GUID_POWER_SAVING_STATUS,
            DEVICE_NOTIFY_WINDOW_HANDLE);
  FNotifyEnergySaverBrightness := RegisterPowerSettingNotification(
            FMsgWindow,
            GUID_ENERGY_SAVER_BRIGHTNESS,
            DEVICE_NOTIFY_WINDOW_HANDLE);
end;

destructor TWMIBrightnessProvider.Destroy;
begin
  if FNotifyEnergySaverBrightness <> nil then
    UnregisterPowerSettingNotification(FNotifyEnergySaverBrightness);
  if FNotifyPowerSavingStatus <> nil then
    UnregisterPowerSettingNotification(FNotifyPowerSavingStatus);
  if FNotifyAdaptiveDisplayBrightness <> nil then
    UnregisterPowerSettingNotification(FNotifyAdaptiveDisplayBrightness);

  DeallocateHWnd(FMsgWindow);

  FMonitors.Free;
  FServices           := nil;
  FLocator            := nil;
  CoUninitialize;

  inherited;
end;

function TWMIBrightnessProvider.RegisterBrightnessEvent: Boolean;
begin
  FWmiEventListener := TWmiEventListener.Create;
  FWmiEventListener.OnIndicate := BrightnessEvent;
  FWmiEventListener.Start;
  Result := True;
end;

function TWMIBrightnessProvider.UnregisterBrightnessEvent: Boolean;
begin
  if Assigned(FWmiEventListener) then
  begin
    FWmiEventListener.OnIndicate := nil;
    FWmiEventListener.Terminate;
  end;
  Result := True;
end;

procedure TWMIBrightnessProvider.BrightnessEvent(ASender: TObject; objWbemObject: IWbemClassObject);
var
  hr        : HRESULT;
  pVal      : OleVariant;
  pType     : Integer;
  plFlavor  : Integer;

  Active        : Boolean;
  Brightness    : UInt8;
  InstanceName  : TInstanceName;
  Monitor: IBrightnessMonitor;
begin
  hr := objWbemObject.Get('InstanceName', 0, pVal, pType, plFlavor);
  if hr <> WBEM_S_NO_ERROR then Exit;

  InstanceName := TInstanceName(pVal);
  VarClear(pVal);

  hr := objWbemObject.Get('Active', 0, pVal, pType, plFlavor);
  if hr <> WBEM_S_NO_ERROR then Exit;

  Active := Boolean(pVal);
  VarClear(pVal);

  hr := objWbemObject.Get('Brightness', 0, pVal, pType, plFlavor);
  if hr <> WBEM_S_NO_ERROR then Exit;

  Brightness :=  UInt8(pVal);
  VarClear(pVal);

  for Monitor in FMonitors do
    if (Monitor as TWMIMonitor).InstanceName = InstanceName then
    begin
      (Monitor as TWMIMonitor).BrightnessChanged(Brightness);
      Exit;
    end;

  if Active then
    if Assigned(FOnNeedUpdate) then
      FOnNeedUpdate(Self);
end;

procedure TWMIBrightnessProvider.MsgWindowProc(var Msg: TMessage);
var
  PowerBroadcastSetting: TPowerBroadcastSetting;
begin
  Msg.Result := DefWindowProc(FMsgWindow, Msg.Msg, Msg.WParam, Msg.LParam);
  if Msg.Msg = WM_POWERBROADCAST then
    if Msg.WParam = PBT_POWERSETTINGCHANGE then
    begin
      PowerBroadcastSetting:= PPowerBroadcastSetting(Msg.LParam)^;
      if PowerBroadcastSetting.PowerSetting = GUID_VIDEO_ADAPTIVE_DISPLAY_BRIGHTNESS then
      begin
        // Изменилась настройка адаптивной яркости
        UpdateAdaptiveDisplayBrightness(PBOOL(@PowerBroadcastSetting.Data)^);
        Exit;
      end;
      if PowerBroadcastSetting.PowerSetting = GUID_POWER_SAVING_STATUS then
      begin
        // Изменился режим экономии заряда
        UpdateBatterySaver(PDWORD(@PowerBroadcastSetting.Data)^ and DWORD(1) = DWORD(1));
        Exit;
      end;
      if PowerBroadcastSetting.PowerSetting = GUID_ENERGY_SAVER_BRIGHTNESS then
      begin
        // Изменился вес подсветки в режиме экономии заряда
        UpdateEnergySaverBrightness(PDWORD(@PowerBroadcastSetting.Data)^);
        Exit;
      end;
    end;
end;

function TWMIBrightnessProvider.Load: TList<IBrightnessMonitor>;
const
  EnumTimeout = 8000;
var
  hr              : HRESULT;

  ppEnum  : IEnumWbemClassObject;

  WmiMonitorBrightness  : IWbemClassObject;
  Returned              : ULONG;

  Monitor: TWMIMonitor;
begin
  UnregisterBrightnessEvent;
  FMonitors.Clear;
  Result := FMonitors;

  try
    hr := FServices.ExecQuery('WQL', WQLBrightness, WBEM_FLAG_FORWARD_ONLY or WBEM_FLAG_RETURN_IMMEDIATELY, nil, ppEnum);
    if not Succeeded(hr) then Exit;

    while ppEnum.Next(EnumTimeout, 1, WmiMonitorBrightness, Returned) = Winapi.Windows.ERROR_SUCCESS do
    begin
      if Returned = 0 then Break;

      try
        Monitor := TWMIMonitor.Create(FServices, WmiMonitorBrightness, FAlwaysActiveMonitors);
        Monitor.AdaptiveBrightnessChanged(FAdaptiveDisplayBrightness);
        Monitor.OnError := MonitorError;
        FMonitors.Add(Monitor);
      except
        Continue;
      end;
    end;
  except
    Exit;
  end;

  RegisterBrightnessEvent;
end;

procedure TWMIBrightnessProvider.Clean;
begin
  UnregisterBrightnessEvent;
  FMonitors.Clear;
end;

procedure TWMIBrightnessProvider.MonitorError(Sender: TObject);
begin
  if Assigned(FOnNeedUpdate) then
    FOnNeedUpdate(Self);
end;

procedure TWMIBrightnessProvider.UpdateAdaptiveDisplayBrightness(Value: BOOL);
var
  Monitor: IBrightnessMonitor;
begin
  FAdaptiveDisplayBrightness := Value;
  for Monitor in FMonitors do
    (Monitor as TWMIMonitor).AdaptiveBrightnessChanged(Value);
end;

procedure TWMIBrightnessProvider.UpdateBatterySaver(Value: Boolean);
begin
  TWMIMonitor.BatterySaver := Value;
end;

procedure TWMIBrightnessProvider.UpdateEnergySaverBrightness(
  Value: DWORD);
begin
  TWMIMonitor.EnergySaverBrightness := Value;
end;

function TWMIBrightnessProvider.GetMonitors: TList<IBrightnessMonitor>;
begin
  Result := FMonitors;
end;

function TWMIBrightnessProvider.GetOnNeedUpdate: TProviderNeedUpdateEvent;
begin
  Result := FOnNeedUpdate;
end;

procedure TWMIBrightnessProvider.SetOnNeedUpdate(
  const Value: TProviderNeedUpdateEvent);
begin
  FOnNeedUpdate := Value;
end;

function TWMIBrightnessProvider.GetAdaptiveBrightnessForAllScheme: Boolean;
begin
  Result := TWMIMonitor.AdaptiveBrightnessForAllScheme;
end;

procedure TWMIBrightnessProvider.SetAdaptiveBrightnessForAllScheme(
  const Value: Boolean);
begin
  if TWMIMonitor.AdaptiveBrightnessForAllScheme = Value then Exit;

  TWMIMonitor.AdaptiveBrightnessForAllScheme := Value;
  if TWMIMonitor.AdaptiveBrightnessForAllScheme then
    TWMIMonitor.ApplyAdaptiveBrightness(FAdaptiveDisplayBrightness);
end;

{ TWmiEventListener }

constructor TWmiEventListener.Create;
begin
  inherited Create(True);
  FreeOnTerminate := True;
end;

procedure TWmiEventListener.CallOnIndicate;
var
  IndicateEvent: TSinkIndicateEvent;
begin
  IndicateEvent := FOnIndicate;
  if Assigned(IndicateEvent) then IndicateEvent(Self, FEventObject);
end;

procedure TWmiEventListener.Execute;
var
  hr: HRESULT;
  ppEnum: IEnumWbemClassObject;
  WmiEvent: IWbemClassObject;
  Returned: ULONG;
begin
  hr := CoInitializeEx(nil, COINIT_APARTMENTTHREADED);
  if Failed(hr) then Exit;
  try
    hr := CoCreateInstance(CLSID_WbemLocator, nil, CLSCTX_INPROC_SERVER, IID_IWbemLocator, FLocator);
    if Failed(hr) then Exit;

    hr := FLocator.ConnectServer(strNamespace, strUser, strPassword, '',
      WBEM_FLAG_CONNECT_USE_MAX_WAIT, '', nil, FServices);
    if Failed(hr) then Exit;

    hr := FServices.ExecNotificationQuery('WQL', WQLBrightnessEvent, WBEM_FLAG_FORWARD_ONLY or WBEM_FLAG_RETURN_IMMEDIATELY, nil, ppEnum);
    if not Succeeded(hr) then Exit;

    while not Terminated do
    begin
      if ppEnum.Next(Longint(WBEM_INFINITE), 1, WmiEvent, Returned) = Winapi.Windows.ERROR_SUCCESS then
      begin
        FEventObject := WmiEvent;
        if not Terminated then Synchronize(CallOnIndicate);
        FEventObject := nil;
        WmiEvent := nil;
      end
      else
      begin
        Sleep(5000);
      end;
    end;
  finally
    Terminate;
  end;
end;

procedure TWmiEventListener.TerminatedSet;
begin
  if not Finished then
  begin
    FServices := nil;
    FLocator  := nil;
    if GetCurrentThread = Handle then
      CoUninitialize;
    TerminateThread(Handle, 0);
  end;
end;

{ TWmiSetBrightnessThread }

constructor TWmiSetBrightnessThread.Create(InstanceName: TInstanceName);
var
  ThreadStartup: TThreadExecuteStartup;
begin
  FInstanceName := InstanceName;

  ThreadStartup.ThreadAvalibleEvent := TValueEvent.Create;
  ThreadStartup.InstanceName := InstanceName;
  try
    Handle := CreateThread(nil, 0, @ThreadExecute, @ThreadStartup, 0, ThreadID);
    try
      if (ThreadStartup.ThreadAvalibleEvent.WaitFor <> wrSignaled) or not ThreadStartup.ThreadAvalibleEvent.Result then
        raise TBrightnessMonitorException.Create('Thread not started');
    except
      Terminate;
      CloseHandle(Handle);
      raise;
    end;
  finally
    ThreadStartup.ThreadAvalibleEvent.Free;
  end;
end;

destructor TWmiSetBrightnessThread.Destroy;
begin
  Terminate;
  CloseHandle(Handle);
end;

class function TWmiSetBrightnessThread.ThreadExecute(lpParameter: LPVOID): DWORD;
const
  Timeout = 1;
  EnumTimeout = 8000;
var
  hr: HRESULT;

  Msg: TMsg;
  bRet: BOOL;

  Returned              : ULONG;
  pVal                  : OleVariant;
  pType                 : Integer;
  plFlavor              : Integer;

  Locator: IWbemLocator;
  Services: IWbemServices;

  MethodsEnum         : IEnumWbemClassObject;
  WmiMonitorBrightnessMethods : IWbemClassObject;
  MethodInstanceName  : TInstanceName;

  pathVariable        : OleVariant;
  pCallResult         : IWbemCallResult;
  pClass              : IWbemClassObject;
  pInSignature        : IWbemClassObject;
  pOutSignature       : IWbemClassObject;
  pInInstance         : IWbemClassObject;
  pOutParams          : IWbemClassObject;

  TimeoutParam        : OleVariant;
  BrightnessParam     : OleVariant;

  InstanceName: string;
  ThreadAvalibleEvent: TValueEvent;
begin
  Result := 0;
  InstanceName := TThreadExecuteStartup(lpParameter^).InstanceName;
  ThreadAvalibleEvent := TThreadExecuteStartup(lpParameter^).ThreadAvalibleEvent;
  try
    hr := CoInitializeEx(nil, COINIT_APARTMENTTHREADED);
    if Failed(hr) then Exit;

    hr := CoCreateInstance(CLSID_WbemLocator, nil, CLSCTX_INPROC_SERVER, IID_IWbemLocator, Locator);
    if Failed(hr) then Exit;

    hr := Locator.ConnectServer(strNamespace, strUser, strPassword, '',
      WBEM_FLAG_CONNECT_USE_MAX_WAIT, '', nil, Services);
    if Failed(hr) then Exit;

    hr := Services.ExecQuery('WQL', WQLBrightnessMethods, WBEM_FLAG_FORWARD_ONLY or WBEM_FLAG_RETURN_IMMEDIATELY, nil, MethodsEnum);
    if not Succeeded(hr) then Exit;

    while MethodsEnum.Next(EnumTimeout, 1, WmiMonitorBrightnessMethods, Returned) = Winapi.Windows.ERROR_SUCCESS do
    begin
      if Returned = 0 then Break;

      hr := WmiMonitorBrightnessMethods.Get('InstanceName', 0, pVal, pType, plFlavor);
      if not Succeeded(hr) then Continue;

      MethodInstanceName := TInstanceName(pVal);
      VarClear(pVal);

      if MethodInstanceName = InstanceName then
      begin
        try
          hr := WmiMonitorBrightnessMethods.Get('__PATH', 0, pathVariable, pType, plFlavor);
          if hr <> WBEM_S_NO_ERROR then Continue;

          hr := Services.GetObject('WmiMonitorBrightnessMethods', 0, nil, pClass, pCallResult);
          if hr <> WBEM_S_NO_ERROR then Continue;

          hr := pClass.GetMethod('WmiSetBrightness', 0, pInSignature, pOutSignature);
          if hr <> WBEM_S_NO_ERROR then Continue;

          hr := pInSignature.SpawnInstance(0, pInInstance);
          if hr <> WBEM_S_NO_ERROR then Continue;

          TimeoutParam := UInt32(Timeout);
          hr := pInInstance.Put('Timeout', 0, @TimeoutParam, CIM_UINT32);
          if hr <> WBEM_S_NO_ERROR then Continue;

          PeekMessage(Msg, HWND(-1), 0, 0, PM_NOREMOVE);
          ThreadAvalibleEvent.SetEvent(True);
          ThreadAvalibleEvent := nil;
          repeat
            bRet := GetMessage(Msg, HWND(-1), 0, 0);
            if LONG(bRet) <> -1 then
            begin
              case Msg.message of
                WM_SETBRIGHTNESS:
                try
                  BrightnessParam := UInt8(Msg.wParam);
                  hr := pInInstance.Put('Brightness', 0, @BrightnessParam, CIM_UINT8);
                  if hr <> WBEM_S_NO_ERROR then Continue;

                  hr := Services.ExecMethod(pathVariable, 'WmiSetBrightness', 0, nil, pInInstance, pOutParams, pCallResult);
                  if hr <> WBEM_S_NO_ERROR then Continue;
                finally
                  VarClear(BrightnessParam);
                  pOutParams := nil;
                  pCallResult := nil;

                  TValueEvent(Pointer(Msg.lParam)^).SetEvent(hr = WBEM_S_NO_ERROR);
                end;
              end;

              DispatchMessage(Msg);
            end;
          until (not bRet);

          Break;
        finally
          pCallResult := nil;
          VarClear(TimeoutParam);
          pInInstance := nil;
          pOutSignature := nil;
          pInSignature := nil;
          pClass := nil;
          VarClear(pathVariable);
        end;
      end;
    end;
  finally
    MethodsEnum := nil;
    Services   := nil;
    Locator    := nil;
    CoUninitialize;

    if ThreadAvalibleEvent <> nil then ThreadAvalibleEvent.SetEvent(False);
  end;
end;

procedure TWmiSetBrightnessThread.Terminate;
begin
  if not PostThreadMessage(ThreadID, WM_QUIT, 0, 0) then TerminateThread(ThreadID, 0);
end;

function TWmiSetBrightnessThread.SetBrightness(Brightness: Byte): Boolean;
var
  SetBrightnessEvent: TValueEvent;
begin
  try
    SetBrightnessEvent := TValueEvent.Create;
    Result := PostThreadMessage(ThreadID, WM_SETBRIGHTNESS, Brightness, LPARAM(@SetBrightnessEvent));
    if Result then
      Result := SetBrightnessEvent.WaitFor = wrSignaled;
    if Result then
      Result := SetBrightnessEvent.Result;
  finally
    SetBrightnessEvent.Free;
  end;
end;

{ TWmiSetBrightnessThread.TValueEvent }

procedure TWmiSetBrightnessThread.TValueEvent.SetEvent(EventResult: Boolean);
begin
  Result := EventResult;
  SetEvent;
end;

end.
