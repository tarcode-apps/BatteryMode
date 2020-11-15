unit Power.Schemes.Providers.Default;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Classes,
  System.Generics.Collections, System.Generics.Defaults,
  Core.Language,
  Power, Power.WinApi.PowrProf,
  Versions.Helpers;

type
  TPowerScheme = class;
  TPowerSchemes = class;
  TPowerSchemeProvider = class;

  TPowerSchemeGUIDs = record
    GUID: TGUID;
    OverlayGUID: TGUID;
  end;

  TPowerScheme = class(TInterfacedObject, IPowerScheme)
  strict private
    class function ReadFriendlyName(GUID: TGUID):string; static;
  public
    class function ReadActiveScheme: TGUID;
    class function ReadActiveOverlay: TGUID;
    class function IsOverlaySupported: Boolean;
    class function MakeUniqueString(GUID: TGUID; OverlayGUID: TGUID): string;
    class function ParseUniqueString(UniqueString: string): TPowerSchemeGUIDs;
  strict private
    [weak] FProvider: TPowerSchemeProvider;
    FGUID: TGUID;
    FOverlayGUID: TGUID;
    FFriendlyName: string;
    FIsHidden: Boolean;
  strict private
    function _GetBrightness(PowerCondition: TSystemPowerCondition): DWORD;
    procedure _SetBrightness(PowerCondition: TSystemPowerCondition;
      const Value: DWORD);
    function _GetUniqueString: string;
    function _GetFriendlyName: string;
    function _GetPowerSchemeType: TPowerSchemeType;
    function _GetOverlaySchemeType: TOverlaySchemeType;
    function _GetDischargeLevel(PowerCondition: TSystemPowerCondition): DWORD;
    procedure _SetDischargeLevel(PowerCondition: TSystemPowerCondition;
      const Value: DWORD);
    function _GetReserveLevel(PowerCondition: TSystemPowerCondition): DWORD;
    procedure _SetReserveLevel(PowerCondition: TSystemPowerCondition;
      const Value: DWORD);
    function _GetEnegrySaverBrightnessWeight(PowerCondition: TSystemPowerCondition): DWORD;
    procedure _SetEnegrySaverBrightnessWeight(PowerCondition: TSystemPowerCondition;
      const Value: DWORD);
  protected
    constructor Create(GUID: TGUID; OverlayGUID: TGUID; Provider: TPowerSchemeProvider); overload;
  public
    constructor Create(GUID: TGUID; OverlayGUID: TGUID); overload;

    property GUID: TGUID read FGUID;
    property OverlayGUID: TGUID read FOverlayGUID;
  public
    function Activate: Boolean;
    function IsActive: Boolean;
    function IsHidden: Boolean;

    function Equals(Value: IPowerScheme): Boolean; reintroduce;
    function Copy: IPowerScheme;

    property Brightness[PowerCondition: TSystemPowerCondition]: DWORD read _GetBrightness write _SetBrightness;
    property UniqueString: string read _GetUniqueString;
    property FriendlyName: string read _GetFriendlyName;
    property PowerSchemeType: TPowerSchemeType read _GetPowerSchemeType;
    property OverlaySchemeType: TOverlaySchemeType read _GetOverlaySchemeType;
    property DischargeLevel[PowerCondition: TSystemPowerCondition]: DWORD read _GetDischargeLevel write _SetDischargeLevel;
    property ReserveLevel[PowerCondition: TSystemPowerCondition]: DWORD read _GetReserveLevel write _SetReserveLevel;
    property EnegrySaverBrightnessWeight[PowerCondition: TSystemPowerCondition]: DWORD read _GetEnegrySaverBrightnessWeight write _SetEnegrySaverBrightnessWeight;
  end;

  TPowerSchemes = class(TPowerSchemeList)
  protected
    function GetActiveScheme: IPowerScheme; override;
  public
    function Copy: TPowerSchemeList; override;
  end;

  TPowerSchemeProvider = class(TInterfacedObject, IPowerSchemeProvider)
  strict private
    FMsgWnd: HWND;
    FNotifyActivePowerscheme      : HPOWERNOTIFY;
    FNotifyPowerSavingStatus      : HPOWERNOTIFY;
    FNotifyEnergySaverBrightness  : HPOWERNOTIFY;
    FEffectivePowerModeNotifications: PPVOID;
    FEnegrySaver: Boolean;
    FEnegrySaverBrightnessWeight: DWORD;
    FSchemes: TPowerSchemes;
    FActive: IPowerScheme;
    FSchemeFeatures: TPowerSchemeFeatures;
    FSupportedSchemeFeatures: TPowerSchemeFeatures;

    FOnActivate: TEventActivatePowerScheme;
    FOnUpdate: TEventUpdatePowerSchemes;
    FOnInternalActivating: TEventActivatePowerScheme;
    FOnInternalActivated: TEventActivatePowerScheme;

    FOnEnegrySaverChange: TEventEnegrySaverSwitched;
    FOnEnegrySaverBrightnessWeightChange: TEventPowerSchemeValueChange;

    procedure MsgWndHandle(var Msg: TMessage);
    function LoadPowerScheme: TPowerSchemes;
    procedure AddFallCreatorsMissingSchemes(ExistingSchemes: TPowerSchemes);
    procedure AddOverlaySchemes(ExistingSchemes: TPowerSchemes);
  strict private
    class procedure EffectivePowerModeCallback(
      Mode: EFFECTIVE_POWER_MODE; const Context: Pointer); stdcall; static;
  strict private
    function _GetActive: IPowerScheme;
    function _GetSchemes: TPowerSchemeList;

    function _GetSchemeFeatures: TPowerSchemeFeatures;
    procedure _SetSchemeFeatures(const Value: TPowerSchemeFeatures);
    function _GetSupportedSchemeFeatures: TPowerSchemeFeatures;

    procedure _SetBrightnessForAllScheme(PowerCondition: TSystemPowerCondition;
      const Value: DWORD);

    function _GetEnegrySaver: Boolean;
    procedure _SetEnegrySaver(const Value: Boolean);
    function _GetEnegrySaverBrightnessWeight: DWORD;

    function _GetOnActivate: TEventActivatePowerScheme;
    procedure _SetOnActivate(const Value: TEventActivatePowerScheme);

    function _GetOnUpdate: TEventUpdatePowerSchemes;
    procedure _SetOnUpdate(const Value: TEventUpdatePowerSchemes);

    function _GetOnInternalActivating: TEventActivatePowerScheme;
    procedure _SetOnInternalActivating(const Value: TEventActivatePowerScheme);
    function _GetOnInternalActivated: TEventActivatePowerScheme;
    procedure _SetOnInternalActivated(const Value: TEventActivatePowerScheme);

    function _GetOnEnegrySaverSwitched: TEventEnegrySaverSwitched;
    procedure _SetOnEnegrySaverSwitched(const Value: TEventEnegrySaverSwitched);
    function _GetOnEnegrySaverBrightnessWeightChange: TEventPowerSchemeValueChange;
    procedure _SetOnEnegrySaverBrightnessWeightChange(const Value: TEventPowerSchemeValueChange);
  protected
    procedure DoInternalActivating(Sender: IPowerScheme);
    procedure DoInternalActivated(Sender: IPowerScheme);
    procedure DoActivate(Sender: IPowerScheme);
  public
    constructor Create;
    destructor Destroy; override;
  public
    function CheckForUpdates: Boolean;
    function ReActivate: Boolean;
    function MakeSchemeFromUniqueString(UniqueString: string): IPowerScheme;

    property Active: IPowerScheme read _GetActive;
    property Schemes: TPowerSchemeList read _GetSchemes;
    property SchemeFeatures: TPowerSchemeFeatures read _GetSchemeFeatures write _SetSchemeFeatures;
    property SupportedSchemeFeatures: TPowerSchemeFeatures read _GetSupportedSchemeFeatures;
    property BrightnessForAllScheme[PowerCondition: TSystemPowerCondition]: DWORD write _SetBrightnessForAllScheme;
    property EnegrySaver: Boolean read _GetEnegrySaver write _SetEnegrySaver;
    property EnegrySaverBrightnessWeight: DWORD read _GetEnegrySaverBrightnessWeight;
    property OnActivate: TEventActivatePowerScheme read _GetOnActivate write _SetOnActivate;
    property OnUpdate: TEventUpdatePowerSchemes read _GetOnUpdate write _SetOnUpdate;
    property OnInternalActivating: TEventActivatePowerScheme read _GetOnInternalActivating write _SetOnInternalActivating;
    property OnInternalActivated: TEventActivatePowerScheme read _GetOnInternalActivated write _SetOnInternalActivated;
    property OnEnegrySaverSwitched: TEventEnegrySaverSwitched read _GetOnEnegrySaverSwitched write _SetOnEnegrySaverSwitched;
    property OnEnegrySaverBrightnessWeightChange: TEventPowerSchemeValueChange read _GetOnEnegrySaverBrightnessWeightChange write _SetOnEnegrySaverBrightnessWeightChange;
  end;

implementation

{ TPowerScheme }

class function TPowerScheme.ReadActiveScheme: TGUID;
var
  Buffer: PGUID;
begin
  if PowerGetActiveScheme(0, @Buffer) = ERROR_SUCCESS then begin
    Result := Buffer^;
    LocalFree(HLOCAL(Buffer));
  end else
    Result := TGUID.Empty;
end;

class function TPowerScheme.ReadActiveOverlay: TGUID;
begin
  if not IsOverlaySupported then Exit(GUID_POWER_POLICY_OVERLAY_SCHEME_NONE);

  if not PowerGetActualOverlayScheme(Result) = ERROR_SUCCESS then
    Result := GUID_POWER_POLICY_OVERLAY_SCHEME_NONE;
end;

class function TPowerScheme.IsOverlaySupported: Boolean;
begin
  Result := IsWindows10Update1809OrGreater;
end;

class function TPowerScheme.MakeUniqueString(GUID, OverlayGUID: TGUID): string;
begin
  if IsOverlaySupported and (OverlayGUID <> GUID_POWER_POLICY_OVERLAY_SCHEME_NONE) then
    Result := string.Join(',', [GUID.ToString, OverlayGUID.ToString])
  else
    Result := GUID.ToString;
end;

class function TPowerScheme.ParseUniqueString(
  UniqueString: string): TPowerSchemeGUIDs;
var
  Parts: TArray<string>;
begin
  Parts := UniqueString.Split([',']);
  Result.GUID := StringToGUID(Parts[0]);
  if IsOverlaySupported and (Length(Parts) > 1) then
    Result.OverlayGUID := StringToGUID(Parts[1])
  else
    Result.OverlayGUID := GUID_POWER_POLICY_OVERLAY_SCHEME_NONE;
end;

class function TPowerScheme.ReadFriendlyName(GUID: TGUID): string;
var
  Buffer: PUCHAR;
  BufferSize: DWORD;
begin
  Result := '';
  if PowerReadFriendlyName(0, @GUID, nil, nil, nil, BufferSize) = ERROR_SUCCESS then
  begin
    GetMem(Buffer, BufferSize);
    if PowerReadFriendlyName(0, @GUID, nil, nil, Buffer, BufferSize) = ERROR_SUCCESS then
      Result := WideCharToString(PChar(Buffer));
    FreeMem(Buffer);
  end;
end;

constructor TPowerScheme.Create(GUID: TGUID; OverlayGUID: TGUID);
begin
  Create(GUID, OverlayGUID, nil);
end;

constructor TPowerScheme.Create(GUID: TGUID; OverlayGUID: TGUID; Provider: TPowerSchemeProvider);
begin
  FGUID := GUID;
  FOverlayGUID := OverlayGUID;
  FProvider := Provider;

  if OverlayGUID = GUID_POWER_POLICY_OVERLAY_SCHEME_HIGH_PERFORMANCE then
    FFriendlyName := TLang[160]
  else if OverlayGUID = GUID_POWER_POLICY_OVERLAY_SCHEME_MAX_PERFORMANCE then
    FFriendlyName := TLang[161]
  else if OverlayGUID = GUID_POWER_POLICY_OVERLAY_SCHEME_BETTER_BATTERY_LIFE then
    FFriendlyName := TLang[162]
  else
    FFriendlyName := ReadFriendlyName(FGUID);

  FIsHidden := string.IsNullOrWhiteSpace(FFriendlyName);
  if FIsHidden then FFriendlyName := TLang[27];
end;

function TPowerScheme._GetBrightness(
  PowerCondition: TSystemPowerCondition): DWORD;
var
  Status: DWORD;
begin
  if PowerCondition = PoAc then
    Status := PowerReadACValueIndex(0, @FGUID,
        @GUID_VIDEO_SUBGROUP, @GUID_DEVICE_POWER_POLICY_VIDEO_BRIGHTNESS,
        Result)
  else
    Status := PowerReadDCValueIndex(0, @FGUID,
        @GUID_VIDEO_SUBGROUP, @GUID_DEVICE_POWER_POLICY_VIDEO_BRIGHTNESS,
        Result);

  if Status <> ERROR_SUCCESS then
    raise EPowerSchemeBrightnessError.Create('Get brightness failed');
end;

procedure TPowerScheme._SetBrightness(PowerCondition: TSystemPowerCondition;
  const Value: DWORD);
var
  Status: DWORD;
begin
  if PowerCondition = PoAc then
    Status := PowerWriteACValueIndex(0, @FGUID,
        @GUID_VIDEO_SUBGROUP, @GUID_DEVICE_POWER_POLICY_VIDEO_BRIGHTNESS,
        Value)
  else
    Status := PowerWriteDCValueIndex(0, @FGUID,
        @GUID_VIDEO_SUBGROUP, @GUID_DEVICE_POWER_POLICY_VIDEO_BRIGHTNESS,
        Value);

  if Status <> ERROR_SUCCESS then
    raise EPowerSchemeBrightnessError.Create('Set brightness failed');
end;

function TPowerScheme._GetUniqueString: string;
begin
  Result := MakeUniqueString(FGUID, FOverlayGUID);
end;

function TPowerScheme._GetFriendlyName: string;
begin
  Result := FFriendlyName;
end;

function TPowerScheme._GetPowerSchemeType: TPowerSchemeType;
begin
  if FGUID = GUID_MIN_POWER_SAVINGS then Exit(pstMinPowerSavings);
  if FGUID = GUID_MAX_POWER_SAVINGS then Exit(pstMaxPowerSavings);
  if FGUID = GUID_TYPICAL_POWER_SAVINGS then Exit(pstTypicalPowerSavings);
  Result := pstCustom;
end;

function TPowerScheme._GetOverlaySchemeType: TOverlaySchemeType;
begin
  if not IsOverlaySupported then Exit(ostOverlayNone);

  if FOverlayGUID = GUID_POWER_POLICY_OVERLAY_SCHEME_HIGH_PERFORMANCE then Exit(ostOverlayHigh);
  if FOverlayGUID = GUID_POWER_POLICY_OVERLAY_SCHEME_MAX_PERFORMANCE then Exit(ostOverlayMax);
  if FOverlayGUID = GUID_POWER_POLICY_OVERLAY_SCHEME_BETTER_BATTERY_LIFE then Exit(ostOverlayMin);
  Result := ostOverlayNone;
end;

function TPowerScheme._GetDischargeLevel(
  PowerCondition: TSystemPowerCondition): DWORD;
begin
  if PowerCondition = PoDc then
  begin
    if PowerReadDCValueIndex(0, @FGUID,
                                @GUID_BATTERY_SUBGROUP,
                                @GUID_BATTERY_DISCHARGE_LEVEL_1,
                                Result) <> ERROR_SUCCESS then
      Result := 255;
  end
  else
  begin
    if PowerReadACValueIndex(0, @FGUID,
                                @GUID_BATTERY_SUBGROUP,
                                @GUID_BATTERY_DISCHARGE_LEVEL_1,
                                Result) <> ERROR_SUCCESS then
      Result := 255;
  end;
end;

procedure TPowerScheme._SetDischargeLevel(PowerCondition: TSystemPowerCondition;
  const Value: DWORD);
begin
  if PowerCondition = PoDc then
    PowerWriteDCValueIndex(0, @FGUID,
                              @GUID_BATTERY_SUBGROUP,
                              @GUID_BATTERY_DISCHARGE_LEVEL_1,
                              Value)
  else
    PowerWriteACValueIndex(0, @FGUID,
                              @GUID_BATTERY_SUBGROUP,
                              @GUID_BATTERY_DISCHARGE_LEVEL_1,
                              Value);
end;

function TPowerScheme._GetReserveLevel(
  PowerCondition: TSystemPowerCondition): DWORD;
begin
  if PowerCondition = PoDc then
  begin
    if PowerReadDCValueIndex(0, @FGUID,
                                @GUID_BATTERY_SUBGROUP,
                                @GUID_BATTERY_RESERVE_LEVEL,
                                Result) <> ERROR_SUCCESS then
      Result := 0;
  end
  else
  begin
    if PowerReadACValueIndex(0, @FGUID,
                                @GUID_BATTERY_SUBGROUP,
                                @GUID_BATTERY_RESERVE_LEVEL,
                                Result) <> ERROR_SUCCESS then
      Result := 0;
  end;
end;

procedure TPowerScheme._SetReserveLevel(PowerCondition: TSystemPowerCondition;
  const Value: DWORD);
begin
  if PowerCondition = PoDc then
    PowerWriteDCValueIndex(0, @FGUID,
                              @GUID_BATTERY_SUBGROUP,
                              @GUID_BATTERY_RESERVE_LEVEL,
                              Value)
  else
    PowerWriteACValueIndex(0, @FGUID,
                              @GUID_BATTERY_SUBGROUP,
                              @GUID_BATTERY_RESERVE_LEVEL,
                              Value);
end;

function TPowerScheme._GetEnegrySaverBrightnessWeight(
  PowerCondition: TSystemPowerCondition): DWORD;
var
  Status: DWORD;
begin
  if PowerCondition = PoDc then
    Status := PowerReadDCValueIndex(0, @FGUID,
                                       @GUID_ENERGY_SAVER_SUBGROUP,
                                       @GUID_ENERGY_SAVER_BRIGHTNESS,
                                       Result)
  else
    Status := PowerReadACValueIndex(0, @FGUID,
                                       @GUID_ENERGY_SAVER_SUBGROUP,
                                       @GUID_ENERGY_SAVER_BRIGHTNESS,
                                       Result);
  if Status <> ERROR_SUCCESS then
    Result := 100;
end;

procedure TPowerScheme._SetEnegrySaverBrightnessWeight(
  PowerCondition: TSystemPowerCondition; const Value: DWORD);
var
  Status: DWORD;
begin
  if PowerCondition = PoDc then
    Status := PowerWriteDCValueIndex(0, @FGUID,
                                        @GUID_ENERGY_SAVER_SUBGROUP,
                                        @GUID_ENERGY_SAVER_BRIGHTNESS,
                                        Value)
  else
    Status := PowerWriteACValueIndex(0, @FGUID,
                                        @GUID_ENERGY_SAVER_SUBGROUP,
                                        @GUID_ENERGY_SAVER_BRIGHTNESS,
                                        Value);
  if Status <> ERROR_SUCCESS then
    raise EPowerSchemeBrightnessError.Create('Set enegry saver brightness weight failed');
end;

function TPowerScheme.Activate: Boolean;
begin
  if Assigned(FProvider) then
    FProvider.DoInternalActivating(Self);

  if IsActive then Exit(True);
  Result := PowerSetActiveScheme(0, @FGUID) = ERROR_SUCCESS;
  if Result and IsOverlaySupported then
    Result := PowerSetActiveOverlayScheme(FOverlayGUID) = ERROR_SUCCESS;

  if Assigned(FProvider) and Result then
    FProvider.DoInternalActivated(Self);
end;

function TPowerScheme.IsActive: Boolean;
begin
  Result := FGUID = ReadActiveScheme;
  if Result and IsOverlaySupported then
    Result := FOverlayGUID = ReadActiveOverlay;
end;

function TPowerScheme.IsHidden: Boolean;
begin
  Result := FIsHidden;
end;

function TPowerScheme.Equals(Value: IPowerScheme): Boolean;
begin
  if Value is TPowerScheme then
  begin
    Result := FGUID = TPowerScheme(Value).GUID;
    if Result and IsOverlaySupported then
      Result := FOverlayGUID = TPowerScheme(Value).OverlayGUID;
  end
  else
    Result := False;
end;

function TPowerScheme.Copy: IPowerScheme;
begin
  Result := TPowerScheme.Create(FGUID, FOverlayGUID, FProvider);
end;

{ TPowerSchemes }

function TPowerSchemes.GetActiveScheme: IPowerScheme;
var
  ActiveGUID: TGUID;
  OverlayGUID: TGUID;
  Scheme: IPowerScheme;
begin
  ActiveGUID := TPowerScheme.ReadActiveScheme;
  OverlayGUID := GUID_POWER_POLICY_OVERLAY_SCHEME_NONE;
  if TPowerScheme.IsOverlaySupported then
    OverlayGUID := TPowerScheme.ReadActiveOverlay;

  for Scheme in Self do
  begin
    if ((Scheme as TPowerScheme).GUID = ActiveGUID) and
       ((Scheme as TPowerScheme).OverlayGUID = OverlayGUID) then Exit(Scheme);
  end;

  Result := nil;
end;

function TPowerSchemes.Copy: TPowerSchemeList;
var
  Scheme: IPowerScheme;
begin
  Result := TPowerSchemes.Create;
  for Scheme in Self do
    Result.Add(Scheme.Copy);
end;

{ TPowerSchemeProvider }

class procedure TPowerSchemeProvider.EffectivePowerModeCallback(
  Mode: EFFECTIVE_POWER_MODE; const Context: Pointer);
var
  Self: TPowerSchemeProvider;
  ActiveGUID: TGUID;
  OverlayGUID: TGUID;
begin
  Self := TPowerSchemeProvider(Context);

  ActiveGUID := TPowerScheme.ReadActiveScheme;
  OverlayGUID := GUID_POWER_POLICY_OVERLAY_SCHEME_NONE;
  if (psfOverlay in Self.SupportedSchemeFeatures) and (psfOverlay in Self.SchemeFeatures) then
    OverlayGUID := TPowerScheme.ReadActiveOverlay;

  Self.FActive := Self.FSchemes.Find(TPowerScheme.MakeUniqueString(ActiveGUID, OverlayGUID));
  if Self.FActive = nil then
  begin
    if Self.CheckForUpdates then Exit;
    Self.FActive := TPowerScheme.Create(ActiveGUID, OverlayGUID, Self);
  end;

  Self.DoActivate(Self.FActive);
end;

constructor TPowerSchemeProvider.Create;
var
  SystemPowerStatus: TSystemPowerStatus;
begin
  inherited;

  GetSystemPowerStatus(SystemPowerStatus);
  FEnegrySaver := (SystemPowerStatus.Reserved1 = 1);

  FSchemeFeatures := [psfMissingScheme, psfOverlay, psfHiddenScheme];
  FSupportedSchemeFeatures := [];
  FSchemes := TPowerSchemes.Create;

  CheckForUpdates;

  if SystemPowerStatus.ACLineStatus = AC_LINE_ONLINE then
    FEnegrySaverBrightnessWeight := Active.Brightness[PoAc]
  else
    FEnegrySaverBrightnessWeight := Active.Brightness[PoDc];

  FMsgWnd := AllocateHWnd(MsgWndHandle);
  FNotifyActivePowerscheme := RegisterPowerSettingNotification(
    FMsgWnd, GUID_ACTIVE_POWERSCHEME, DEVICE_NOTIFY_WINDOW_HANDLE);
  FNotifyPowerSavingStatus := RegisterPowerSettingNotification(
    FMsgWnd, GUID_POWER_SAVING_STATUS, DEVICE_NOTIFY_WINDOW_HANDLE);
  FNotifyEnergySaverBrightness := RegisterPowerSettingNotification(
    FMsgWnd, GUID_ENERGY_SAVER_BRIGHTNESS, DEVICE_NOTIFY_WINDOW_HANDLE);
  if TPowerScheme.IsOverlaySupported then
  begin
    if PowerRegisterForEffectivePowerModeNotifications(
      EFFECTIVE_POWER_MODE_V1,
      EffectivePowerModeCallback,
      Self,
      FEffectivePowerModeNotifications) <> S_OK then
    begin
      FEffectivePowerModeNotifications := nil;
    end;
  end;
end;

destructor TPowerSchemeProvider.Destroy;
begin
  if FEffectivePowerModeNotifications <> nil then
    PowerUnregisterFromEffectivePowerModeNotifications(FEffectivePowerModeNotifications);
  if FNotifyPowerSavingStatus <> nil then
    UnregisterPowerSettingNotification(FNotifyPowerSavingStatus);
  if FNotifyEnergySaverBrightness <> nil then
    UnregisterPowerSettingNotification(FNotifyEnergySaverBrightness);
  if FNotifyActivePowerscheme <> nil then
    UnregisterPowerSettingNotification(FNotifyActivePowerscheme);

  DeallocateHWnd(FMsgWnd);

  FSchemes.Free;
  inherited;
end;

function TPowerSchemeProvider.CheckForUpdates: Boolean;
var
  NewList: TPowerSchemes;
  ActiveGUID: TGUID;
  OverlayGUID: TGUID;
  Scheme: IPowerScheme;
begin
  NewList := LoadPowerScheme;

  Result := NewList.Count <> FSchemes.Count;

  if not Result then
    for Scheme in NewList do
      if not FSchemes.Contains(Scheme) then
      begin
        Result := True;
        Break;
      end;

  if Result then
  begin
    FSchemes.Free;
    FSchemes := NewList;

    ActiveGUID := TPowerScheme.ReadActiveScheme;
    OverlayGUID := GUID_POWER_POLICY_OVERLAY_SCHEME_NONE;
    if (psfOverlay in SupportedSchemeFeatures) and (psfOverlay in SchemeFeatures) then
      OverlayGUID := TPowerScheme.ReadActiveOverlay;

    Scheme := FSchemes.Find(TPowerScheme.MakeUniqueString(ActiveGUID, OverlayGUID));
    if Scheme = nil then
      Scheme := TPowerScheme.Create(ActiveGUID, OverlayGUID, Self);
    
    if FActive <> Scheme then
    begin
      FActive := Scheme;
      if Assigned(FOnUpdate) then FOnUpdate(Self, FSchemes);
      DoActivate(FActive);
    end
    else
      if Assigned(FOnUpdate) then FOnUpdate(Self, FSchemes);
  end else
    NewList.Free;
end;

function TPowerSchemeProvider.ReActivate: Boolean;
begin
  Result := PowerSetActiveScheme(0, @(Active as TPowerScheme).GUID) = ERROR_SUCCESS
end;

function TPowerSchemeProvider.MakeSchemeFromUniqueString(
  UniqueString: string): IPowerScheme;
var
  GUIDs: TPowerSchemeGUIDs;
begin
  Result := FSchemes.Find(UniqueString);
  if Result = nil then
  begin
    GUIDs := TPowerScheme.ParseUniqueString(UniqueString);
    Result := TPowerScheme.Create(GUIDs.GUID, GUIDs.OverlayGUID, Self);
  end;
end;

function TPowerSchemeProvider._GetActive: IPowerScheme;
begin
  Result := FActive;
end;

function TPowerSchemeProvider._GetSchemeFeatures: TPowerSchemeFeatures;
begin
  Result := FSchemeFeatures;
end;

procedure TPowerSchemeProvider._SetSchemeFeatures(
  const Value: TPowerSchemeFeatures);
begin
  if FSchemeFeatures = Value then Exit;

  FSchemeFeatures := Value;
  CheckForUpdates;
end;

function TPowerSchemeProvider._GetSupportedSchemeFeatures: TPowerSchemeFeatures;
begin
  Result := FSupportedSchemeFeatures;
end;

function TPowerSchemeProvider._GetSchemes: TPowerSchemeList;
begin
  Result := FSchemes;
end;

procedure TPowerSchemeProvider._SetBrightnessForAllScheme(
  PowerCondition: TSystemPowerCondition; const Value: DWORD);
var
  Status: DWORD;
begin
  if PowerCondition = PoAc then
    Status := PowerWriteACValueIndex(0, @ALL_POWERSCHEMES_GUID,
      @GUID_VIDEO_SUBGROUP, @GUID_DEVICE_POWER_POLICY_VIDEO_BRIGHTNESS,
      Value)
  else
    Status := PowerWriteDCValueIndex(0, @ALL_POWERSCHEMES_GUID,
      @GUID_VIDEO_SUBGROUP, @GUID_DEVICE_POWER_POLICY_VIDEO_BRIGHTNESS,
      Value);

  if Status <> ERROR_SUCCESS then
    raise EPowerSchemeBrightnessError.Create('Set brightness for all scheme failed');
end;

function TPowerSchemeProvider._GetEnegrySaver: Boolean;
begin
  Result := FEnegrySaver;
end;

procedure TPowerSchemeProvider._SetEnegrySaver(const Value: Boolean);
begin
  raise ENotImplemented.Create('Energy saver not configured');
end;

function TPowerSchemeProvider._GetEnegrySaverBrightnessWeight: DWORD;
begin
  Result := FEnegrySaverBrightnessWeight;
end;

function TPowerSchemeProvider._GetOnActivate: TEventActivatePowerScheme;
begin
  Result := FOnActivate;
end;

procedure TPowerSchemeProvider._SetOnActivate(const Value: TEventActivatePowerScheme);
begin
  FOnActivate := Value;
  DoActivate(Active);
end;

function TPowerSchemeProvider._GetOnUpdate: TEventUpdatePowerSchemes;
begin
  Result := FOnUpdate;
end;

procedure TPowerSchemeProvider._SetOnUpdate(
  const Value: TEventUpdatePowerSchemes);
begin
  FOnUpdate := Value;
  if Assigned(FOnUpdate) then
    FOnUpdate(Self, FSchemes);
end;

function TPowerSchemeProvider._GetOnInternalActivating: TEventActivatePowerScheme;
begin
  Result := FOnInternalActivating;
end;

procedure TPowerSchemeProvider._SetOnInternalActivating(
  const Value: TEventActivatePowerScheme);
begin
  FOnInternalActivating := Value;
end;

function TPowerSchemeProvider._GetOnInternalActivated: TEventActivatePowerScheme;
begin
  Result := FOnInternalActivated;
end;

procedure TPowerSchemeProvider._SetOnInternalActivated(
  const Value: TEventActivatePowerScheme);
begin
  FOnInternalActivated := Value;
end;

function TPowerSchemeProvider._GetOnEnegrySaverSwitched: TEventEnegrySaverSwitched;
begin
  Result := FOnEnegrySaverChange;
end;

procedure TPowerSchemeProvider._SetOnEnegrySaverSwitched(
  const Value: TEventEnegrySaverSwitched);
begin
  FOnEnegrySaverChange := Value;
end;

function TPowerSchemeProvider._GetOnEnegrySaverBrightnessWeightChange: TEventPowerSchemeValueChange;
begin
  Result := FOnEnegrySaverBrightnessWeightChange;
end;

procedure TPowerSchemeProvider._SetOnEnegrySaverBrightnessWeightChange(
  const Value: TEventPowerSchemeValueChange);
begin
  FOnEnegrySaverBrightnessWeightChange := Value;
end;

procedure TPowerSchemeProvider.DoInternalActivating(Sender: IPowerScheme);
begin
  if Assigned(FOnInternalActivating) then
    FOnInternalActivating(Self, Sender);
end;

procedure TPowerSchemeProvider.DoInternalActivated(Sender: IPowerScheme);
begin
  if Assigned(FOnInternalActivated) then
    FOnInternalActivated(Self, Sender);

  // Windows не вызывает EffectivePowerModeCallback если включен EnegrySaver
  if (psfOverlay in SupportedSchemeFeatures) and
     (psfOverlay in SchemeFeatures) and
     (Sender.PowerSchemeType = pstTypicalPowerSavings) and
     EnegrySaver then
  begin
    FActive := Sender;
    DoActivate(FActive);
  end;
end;

procedure TPowerSchemeProvider.DoActivate(Sender: IPowerScheme);
begin
  if Assigned(FOnActivate) then
    FOnActivate(Self, Sender);
end;

procedure TPowerSchemeProvider.MsgWndHandle(var Msg: TMessage);
var
  PowerBroadcastSetting: TPowerBroadcastSetting;
  ActiveGUID: TGUID;
  OverlayGUID: TGUID;
begin
  Msg.Result := DefWindowProc(FMsgWnd, Msg.Msg, Msg.WParam, Msg.LParam);

  if Msg.Msg = WM_POWERBROADCAST then
  begin
    case Msg.WParam of
      PBT_POWERSETTINGCHANGE:
        begin
          PowerBroadcastSetting:= PPowerBroadcastSetting(Msg.LParam)^;

          // Изменилась активная схема управления питанием
          if PowerBroadcastSetting.PowerSetting = GUID_ACTIVE_POWERSCHEME then
          begin
            ActiveGUID := TPowerScheme.ReadActiveScheme;
            OverlayGUID := GUID_POWER_POLICY_OVERLAY_SCHEME_NONE;
            if (psfOverlay in SupportedSchemeFeatures) and (psfOverlay in SchemeFeatures) then
              OverlayGUID := TPowerScheme.ReadActiveOverlay;

            FActive := FSchemes.Find(TPowerScheme.MakeUniqueString(ActiveGUID, OverlayGUID));
            if FActive = nil then
            begin
              if CheckForUpdates then Exit;
              FActive := TPowerScheme.Create(ActiveGUID, OverlayGUID, Self);
            end;

            DoActivate(FActive);
            Exit;
          end;

          // Изменился режим экономии заряда
          if PowerBroadcastSetting.PowerSetting = GUID_POWER_SAVING_STATUS then
          begin
            FEnegrySaver := PDWORD(@PowerBroadcastSetting.Data)^ and DWORD(1) = DWORD(1);
            if Assigned(FOnEnegrySaverChange) then
              FOnEnegrySaverChange(Self, FEnegrySaver);
            Exit;
          end;

          // Изменился вес подсветки в режиме экономии заряда
          if PowerBroadcastSetting.PowerSetting = GUID_ENERGY_SAVER_BRIGHTNESS then
          begin
            FEnegrySaverBrightnessWeight := PDWORD(@PowerBroadcastSetting.Data)^;
            if Assigned(FOnEnegrySaverBrightnessWeightChange) then
              FOnEnegrySaverBrightnessWeightChange(Self, FEnegrySaverBrightnessWeight);
            Exit;
          end;
        end;
    end;
  end;
end;

function TPowerSchemeProvider.LoadPowerScheme: TPowerSchemes;
var
  BufferSize: DWORD;
  I: ULONG;
  Buffer: TGUID;
  Scheme: IPowerScheme;
begin
  Result := TPowerSchemes.Create;

  Exclude(FSupportedSchemeFeatures, psfHiddenScheme);
  I := 0;
  BufferSize := SizeOf(TGUID);
  while PowerEnumerate(0, nil, nil, ACCESS_SCHEME, I, @Buffer, BufferSize) = ERROR_SUCCESS do
  begin
    Scheme := TPowerScheme.Create(Buffer, GUID_POWER_POLICY_OVERLAY_SCHEME_NONE, Self);
    if Scheme.IsHidden then
    begin
      if psfHiddenScheme in FSchemeFeatures then
        Result.Add(Scheme);
      Include(FSupportedSchemeFeatures, psfHiddenScheme);
    end
    else
      Result.Add(Scheme);

    Inc(I);
  end;

  if (psfMissingScheme in FSchemeFeatures) and IsWindows10FallCreatorsOrGreater then
  begin
    AddFallCreatorsMissingSchemes(Result);
  end;

  if (psfOverlay in FSchemeFeatures) and TPowerScheme.IsOverlaySupported then
  begin
    AddOverlaySchemes(Result);
  end;

  Result.Sort;
end;

procedure TPowerSchemeProvider.AddOverlaySchemes(ExistingSchemes: TPowerSchemes);
var
  I: Integer;
  hMem: HLOCAL;
  Count: DWORD;
  OverlayGUID: TGUID;
begin
  hMem := 0;
  Exclude(FSupportedSchemeFeatures, psfOverlay);
  if PowerGetOverlaySchemes(hMem, Count, MakeWord(1, 0)) = ERROR_SUCCESS then
  begin
    for I := 0 to Count - 1 do
    begin
      OverlayGUID := PGUID(NativeUInt(hMem) + DWORD(I) * SizeOf(TGUID))^;
      ExistingSchemes.Add(TPowerScheme.Create(GUID_TYPICAL_POWER_SAVINGS, OverlayGUID, Self));
      Include(FSupportedSchemeFeatures, psfOverlay);
    end;
  end;

  if hMem <> 0 then LocalFree(hMem);
end;

procedure TPowerSchemeProvider.AddFallCreatorsMissingSchemes(ExistingSchemes: TPowerSchemes);
var
  PowerSaverFound: Boolean;
  HighPerformanceFound: Boolean;
  Scheme: IPowerScheme;
begin
  // Check if non-balanced schemes should be added using workaround
  PowerSaverFound := False;
  HighPerformanceFound := False;
  Exclude(FSupportedSchemeFeatures, psfMissingScheme);

  for Scheme in ExistingSchemes do
  begin
    if Scheme.UniqueString = GUID_MAX_POWER_SAVINGS.ToString then
      PowerSaverFound := True;
    if Scheme.UniqueString = GUID_MIN_POWER_SAVINGS.ToString then
      HighPerformanceFound := True;
  end;

  if not PowerSaverFound then begin
    // try to add PowerSaver
    Scheme := TPowerScheme.Create(GUID_MAX_POWER_SAVINGS, GUID_POWER_POLICY_OVERLAY_SCHEME_NONE, Self);
    if Scheme.FriendlyName <> '' then // Check if scheme exists and can be added
    begin
      ExistingSchemes.Add(Scheme);
      Include(FSupportedSchemeFeatures, psfMissingScheme);
    end;
  end;

  if not HighPerformanceFound then begin
    // try to add HighPerformance
    Scheme := TPowerScheme.Create(GUID_MIN_POWER_SAVINGS, GUID_POWER_POLICY_OVERLAY_SCHEME_NONE, Self);
    if Scheme.FriendlyName <> '' then // Check if scheme exists and can be added
    begin
      ExistingSchemes.Add(Scheme);
      Include(FSupportedSchemeFeatures, psfMissingScheme);
    end;
  end;
end;

end.
