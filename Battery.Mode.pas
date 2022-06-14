unit Battery.Mode;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.Classes, System.SysUtils,
  System.Generics.Collections, System.Generics.Defaults,
  Core.Language, Core.Startup.Tasks,
  Power,
  Power.Schemes.Providers.Default, Power.Schemes.Providers.Legacy,
  Power.WinApi.PowrProf,
  Versions.Helpers,
  Helpers.Services;

type
  TBatteryState = record
    Hint: string;
    Percentage: DWORD;
    PowerScheme: IPowerScheme;
    PowerCondition: TSystemPowerCondition;
    BatterySaver: Boolean;
    EnergySaverBrightness: DWORD;
    Mobile: Boolean;
    BatteryPresent: Boolean;
    LidSwitchOpen: Boolean;
  end;

  TEventBatteryStateChange = procedure(Sender: TObject; const State: TBatteryState) of object;
  TEventUpdatePowerScheme = procedure(Sender: TObject; const PowerSchemeList: TPowerSchemeList) of object;
  TEventPowerChange = procedure(Sender: TObject; Sleep: Boolean) of object;

  TBatteryMode = class
  strict private const
    TimerSystemPowerStatusCheck = 1;
  private
    class var FPowerSchemeProvider: IPowerSchemeProvider;

    class var FOnStateChange: TEventBatteryStateChange;
    class var FOnUpdatePowerScheme: TEventUpdatePowerScheme;
    class var FOnGlobalPowerSchemeChange: TEventBatteryStateChange;
    class var FOnLocalPowerSchemeChanges: TEventBatteryStateChange;
    class var FOnLocalPowerSchemeChanged: TEventBatteryStateChange;
    class var FOnPowerChange: TEventPowerChange;

    class var HBatteryMsgForm: HWND;

    class var FBatteryState: TBatteryState;

    class var NotifyBatteryPercentageRemaining  : HPOWERNOTIFY;
    class var NotifyAcdcPowerSource             : HPOWERNOTIFY;
    class var NotifyLidSwitchStateChange        : HPOWERNOTIFY;

    class var FTimerSystemPowerStatus: TSystemPowerStatus;

    class var FBrightness: Byte;
    class var FNotSetBrightness: Byte;
    class var FBrightnessForAllScheme: Boolean;
    class var FFirstChangeBrightnessFix: Boolean;

    class procedure BatteryMsgFormHandle(var Msg: TMessage);

    class function FormatBatteryMessage(Msg: string; const Status: TSystemPowerStatus): string;
    class function SystemPowerStatysToIndex(const Status: TSystemPowerStatus; const State: TBatteryState): Integer;
    class function SystemPowerStatusToHint(const Status: TSystemPowerStatus; const State: TBatteryState): string;

    class procedure PowerSchemeProviderActivate(Sender: TObject; const PowerScheme: IPowerScheme);
    class procedure PowerSchemeProviderUpdate(Sender: TObject; const PowerSchemes: TPowerSchemeList);
    class procedure PowerSchemeProviderInternalActivating(Sender: TObject; const PowerScheme: IPowerScheme);
    class procedure PowerSchemeProviderInternalActivated(Sender: TObject; const PowerScheme: IPowerScheme);
    class procedure PowerSchemeProviderEnegrySaverSwitched(Sender: TObject; const Value: Boolean);
    class procedure PowerSchemeProviderEnegrySaverBrightnessWeightChange(Sender: TObject; const Value: DWORD);

    class function ACLineStatusToSystemPowerCondition(ACLineStatus : Byte): TSystemPowerCondition;

    class procedure UpdateSystemPowerStatus(const Status: TSystemPowerStatus);
    class procedure UpdateLidSwitchState(LidSwitchOpen: BOOL);

    class function ApplyBrightness: Boolean;

    class function GetIsBatteriesPresent: Boolean; static;
    class function GetIsMobilePlatform: Boolean; static;
    class procedure SetBrightness(const Value: Byte); static;
    class procedure SetBrightnessForAllScheme(const Value: Boolean); static;
    class function GetBatterySaver: Boolean; static;
    class procedure SetBatterySaver(const Value: Boolean); static;
    class procedure SetOnStateChange(const Value: TEventBatteryStateChange); static;
    class procedure SetOnUpdatePowerScheme(const Value: TEventUpdatePowerScheme); static;

    class procedure Init;
    class procedure Done;
  public
    class procedure UpdateSchemes;
    class procedure UpdateState;
    class function NextScheme: Boolean;
    class function CustomScheme(UniqueString: string): Boolean;
    class function MaxPowerSavings: Boolean;
    class function TypicalPowerSavings: Boolean;
    class function MinPowerSavings: Boolean;
    class function UltimatePowerSavings: Boolean;
    class property PowerSchemes: IPowerSchemeProvider read FPowerSchemeProvider;
    class property IsBatteriesPresent: Boolean read GetIsBatteriesPresent;
    class property IsMobilePlatform: Boolean read GetIsMobilePlatform;
    class property State: TBatteryState read FBatteryState;
    class property Brightness: Byte read FBrightness write SetBrightness;
    class property BrightnessForAllScheme: Boolean read FBrightnessForAllScheme write SetBrightnessForAllScheme;
    class property BatterySaver: Boolean read GetBatterySaver write SetBatterySaver;
    class property OnStateChange: TEventBatteryStateChange read FOnStateChange write SetOnStateChange;
    class property OnUpdatePowerScheme: TEventUpdatePowerScheme read FOnUpdatePowerScheme write SetOnUpdatePowerScheme;
    class property OnLocalPowerSchemeChanges: TEventBatteryStateChange read FOnLocalPowerSchemeChanges write FOnLocalPowerSchemeChanges;
    class property OnLocalPowerSchemeChanged: TEventBatteryStateChange read FOnLocalPowerSchemeChanged write FOnLocalPowerSchemeChanged;
    class property OnGlobalPowerSchemeChange: TEventBatteryStateChange read FOnGlobalPowerSchemeChange write FOnGlobalPowerSchemeChange;
    class property OnPowerChange: TEventPowerChange read FOnPowerChange write FOnPowerChange;
  end;

implementation

{ TBatteryMode }

{$REGION 'SETTERS and GETTERS'}
class procedure TBatteryMode.SetBrightness(const Value: Byte);
begin
  FBrightness := Value;

  ApplyBrightness;
end;

class procedure TBatteryMode.SetBrightnessForAllScheme(const Value: Boolean);
begin
  if FBrightnessForAllScheme = Value then Exit;

  FBrightnessForAllScheme := Value;

  if FBrightnessForAllScheme then ApplyBrightness;
end;

class function TBatteryMode.GetBatterySaver: Boolean;
begin
  Result := FBatteryState.BatterySaver;
end;

class procedure TBatteryMode.SetBatterySaver(const Value: Boolean);
begin
  //
end;

class procedure TBatteryMode.SetOnStateChange(const Value: TEventBatteryStateChange);
begin
  FOnStateChange := Value;
  if Assigned(FOnStateChange) then FOnStateChange(nil, FBatteryState);
end;

class procedure TBatteryMode.SetOnUpdatePowerScheme(
  const Value: TEventUpdatePowerScheme);
begin
  FOnUpdatePowerScheme := Value;
  if Assigned(FOnUpdatePowerScheme) then
    FOnUpdatePowerScheme(nil, FPowerSchemeProvider.Schemes);
end;
{$ENDREGION}

{$REGION 'Formating Hint Message'}
class function TBatteryMode.FormatBatteryMessage(Msg: string;
  const Status: TSystemPowerStatus): string;
var
  Hour, Min, Sec, MSec, HourFull, MinFull, SecFull, MSecFull: Word;
begin
  DecodeTime(Status.BatteryLifeTime/SecsPerDay, Hour, Min, Sec, MSec);
  DecodeTime(Status.BatteryFullLifeTime/SecsPerDay, HourFull, MinFull, SecFull, MSecFull);

  Result:= Format(Msg, [Hour, Min, Status.BatteryLifePercent, HourFull, MinFull]);
end;

class function TBatteryMode.SystemPowerStatysToIndex(
  const Status: TSystemPowerStatus; const State: TBatteryState): Integer;
var
  Hour, Min, Sec, MSec: Word;

  function IsFlag(b: Byte; Flag: Byte): Boolean; inline;
  begin
    Result:= b and Flag = Flag;
  end;
begin
  DecodeTime(Status.BatteryLifeTime/SecsPerDay, Hour, Min, Sec, MSec);

  with Status do begin
    // Настольный компьютер
    if not State.BatteryPresent and (State.PowerCondition <> PoHot) then
      Exit(600);

    // Батарея не обнаружена
    if (State.PowerCondition = PoAc) and IsFlag(BatteryFlag, BATTERY_FLAG_NO_BATTERY) then
      Exit(627);

    // Подключена и заряжается
    if (ACLineStatus = AC_LINE_ONLINE) and IsFlag(BatteryFlag, BATTERY_FLAG_CHARGING) and
       (BatteryLifePercent = 255) then
      Exit(621);

    // %0:u ч. %1:.2u мин. до полной зарядки
    if (ACLineStatus = AC_LINE_ONLINE) and IsFlag(BatteryFlag, BATTERY_FLAG_CHARGING) and
       (BatteryLifeTime <> DWORD(-1)) and (Hour > 0) then
      Exit(622);

    // %1:u мин. до полной зарядки
    if (ACLineStatus = AC_LINE_ONLINE) and IsFlag(BatteryFlag, BATTERY_FLAG_CHARGING) and
       (BatteryLifeTime <> DWORD(-1)) and (Hour = 0) then
      Exit(623);

    // %2:u%% доступно (подключена, заряжается)
    if (ACLineStatus = AC_LINE_ONLINE) and
       IsFlag(BatteryFlag, BATTERY_FLAG_CHARGING) and
       (BatteryLifePercent < 100) then
      Exit(624);

    // %2:u%% доступно (подключена, не заряжается)
    if (ACLineStatus = AC_LINE_ONLINE) and
       not IsFlag(BatteryFlag, BATTERY_FLAG_CHARGING) and
       (BatteryLifePercent < 100) then
      Exit(625);

    // Полностью заряжена (100%%)
    if (BatteryLifePercent = 100) then
      Exit(626);

    // Батарея не обнаружена
    if IsFlag(BatteryFlag, BATTERY_FLAG_NO_BATTERY) then
      Exit(627);

    // Подключена и не заряжается
    if (ACLineStatus = AC_LINE_ONLINE) and not IsFlag(BatteryFlag, BATTERY_FLAG_CHARGING) and
       (BatteryLifePercent = 255) then
      Exit(628);

    // Осталось %0:u ч. %1:.2u мин. (%2:u%%)
    if (ACLineStatus = AC_LINE_OFFLINE) and (BatteryLifePercent < 100) and
       (BatteryLifeTime <> DWORD(-1)) and (Hour > 0) then
      Exit(650);

    // Осталось %1:u мин. (%2:u%%)
    if (ACLineStatus = AC_LINE_OFFLINE) and (BatteryLifePercent < 100) and
       (BatteryLifeTime <> DWORD(-1)) and (Hour = 0) then
      Exit(651);

    // Осталось %2:u%%
    if (ACLineStatus = AC_LINE_OFFLINE) and (BatteryLifePercent < 100) and
       (BatteryLifeTime = DWORD(-1)) then
      Exit(654);

    // Нет данных
    if (ACLineStatus = AC_LINE_UNKNOWN) or
       (IsFlag(BatteryFlag, BATTERY_FLAG_UNKNOWN)) then
      Exit(655);

    Result := 655;
  end;
end;

class function TBatteryMode.SystemPowerStatusToHint(
  const Status: TSystemPowerStatus; const State: TBatteryState): string;
var
  RawMsg: string;
begin
  RawMsg:= TLang[SystemPowerStatysToIndex(Status, State)];
  Result:= FormatBatteryMessage(RawMsg, Status);
end;
{$ENDREGION}

class function TBatteryMode.GetIsBatteriesPresent: Boolean;
var
  PowerCapabilities: SYSTEM_POWER_CAPABILITIES;
begin
  Result := False;
  if GetPwrCapabilities(PowerCapabilities) then
    Result := PowerCapabilities.SystemBatteriesPresent;
end;

class function TBatteryMode.GetIsMobilePlatform: Boolean;
var
  PlatformRole: POWER_PLATFORM_ROLE;
begin
  if IsWindows8OrGreater then
  begin
    PlatformRole := PowerDeterminePlatformRoleEx(POWER_PLATFORM_ROLE_V2);
    Result := (PlatformRole = PlatformRoleMobile) or (PlatformRole = PlatformRoleSlate);
  end
  else if IsWindowsVistaOrGreater then
    Result := PowerDeterminePlatformRole = PlatformRoleMobile
  else
    Result := IsBatteriesPresent;
end;

class procedure TBatteryMode.UpdateSchemes;
begin
  FPowerSchemeProvider.CheckForUpdates;
end;

class procedure TBatteryMode.UpdateState;
var
  SystemPowerStatus: TSystemPowerStatus;
begin
  GetSystemPowerStatus(SystemPowerStatus);
  UpdateSystemPowerStatus(SystemPowerStatus);
end;

class function TBatteryMode.NextScheme: Boolean;
var
  Index: Integer;
begin
  if not Assigned(FPowerSchemeProvider) then Exit(False);
  if FPowerSchemeProvider.Schemes.Count = 0 then Exit(False);

  Index := FPowerSchemeProvider.Schemes.IndexOf(FPowerSchemeProvider.Active);
  if Index < 0 then
    FPowerSchemeProvider.CheckForUpdates;

  if Index = FPowerSchemeProvider.Schemes.Count - 1 then
    Result := FPowerSchemeProvider.Schemes.First.Activate
  else if Index >= 0 then
    Result := FPowerSchemeProvider.Schemes[Index + 1].Activate
  else
    Result := FPowerSchemeProvider.Schemes.First.Activate;
end;

class function TBatteryMode.CustomScheme(UniqueString: string): Boolean;
var
  PowerScheme: IPowerScheme;
begin
  if not Assigned(FPowerSchemeProvider) then Exit(False);

  PowerScheme := FPowerSchemeProvider.Schemes.Find(UniqueString);
  if PowerScheme <> nil then
    Exit(PowerScheme.Activate);

  Result := False;
end;

class function TBatteryMode.MaxPowerSavings: Boolean;
var
  PowerScheme: IPowerScheme;
begin
  if not Assigned(FPowerSchemeProvider) then Exit(False);

  Result := False;
  for PowerScheme in FPowerSchemeProvider.Schemes do
    if PowerScheme.PowerSchemeType = pstMaxPowerSavings then begin
      PowerScheme.Activate;
      Exit(True);
    end;
end;

class function TBatteryMode.TypicalPowerSavings: Boolean;
var
  PowerScheme: IPowerScheme;
begin
  if not Assigned(FPowerSchemeProvider) then Exit(False);

  Result := False;
  for PowerScheme in FPowerSchemeProvider.Schemes do
    if PowerScheme.PowerSchemeType = pstTypicalPowerSavings then begin
      PowerScheme.Activate;
      Exit(True);
    end;
end;

class function TBatteryMode.MinPowerSavings: Boolean;
var
  PowerScheme: IPowerScheme;
begin
  if not Assigned(FPowerSchemeProvider) then Exit(False);

  Result := False;
  for PowerScheme in FPowerSchemeProvider.Schemes do
    if PowerScheme.PowerSchemeType = pstMinPowerSavings then begin
      PowerScheme.Activate;
      Exit(True);
    end;
end;

class function TBatteryMode.UltimatePowerSavings: Boolean;
var
  PowerScheme: IPowerScheme;
begin
  if not Assigned(FPowerSchemeProvider) then Exit(False);

  Result := False;
  for PowerScheme in FPowerSchemeProvider.Schemes do
    if PowerScheme.PowerSchemeType = pstUltimatePowerSavings then begin
      PowerScheme.Activate;
      Exit(True);
    end;
end;

class procedure TBatteryMode.BatteryMsgFormHandle(var Msg: TMessage);
var
  PowerBroadcastSetting: TPowerBroadcastSetting;
  SystemPowerStatus: TSystemPowerStatus;
begin
  Msg.Result := DefWindowProc(HBatteryMsgForm, Msg.Msg, Msg.WParam, Msg.LParam);

  if Msg.Msg = WM_TIMER then
  begin
    case Msg.WParam of
      TimerSystemPowerStatusCheck:
        begin
          GetSystemPowerStatus(SystemPowerStatus);
          if not CompareMem(@FTimerSystemPowerStatus, @SystemPowerStatus, SizeOf(TSystemPowerStatus)) then
          begin
            UpdateSystemPowerStatus(SystemPowerStatus);
            FTimerSystemPowerStatus := SystemPowerStatus;
          end;
        end;
    end;
    Exit;
  end;

  if Msg.Msg = WM_POWERBROADCAST then
  begin
    case Msg.WParam of
      PBT_POWERSETTINGCHANGE:
        begin
          PowerBroadcastSetting:= PPowerBroadcastSetting(Msg.LParam)^;
          if PowerBroadcastSetting.PowerSetting = GUID_BATTERY_PERCENTAGE_REMAINING then
          begin
            // Изменился заряд батареи
            GetSystemPowerStatus(SystemPowerStatus);
            UpdateSystemPowerStatus(SystemPowerStatus);
            Exit;
          end;
          if PowerBroadcastSetting.PowerSetting = GUID_ACDC_POWER_SOURCE then
          begin
            // Изменился источник питания
            GetSystemPowerStatus(SystemPowerStatus);
            UpdateSystemPowerStatus(SystemPowerStatus);
            Exit;
          end;
          if PowerBroadcastSetting.PowerSetting = GUID_LIDSWITCH_STATE_CHANGE then
          begin
            // Изменилось состояние крышки ноутбука
            UpdateLidSwitchState(PBOOL(@PowerBroadcastSetting.Data)^);
            Exit;
          end;
        end;

      PBT_APMPOWERSTATUSCHANGE:
        begin
          GetSystemPowerStatus(SystemPowerStatus);
          UpdateSystemPowerStatus(SystemPowerStatus);
        end;

      PBT_APMSUSPEND:
        if Assigned(FOnPowerChange) then FOnPowerChange(nil, True);

      PBT_APMRESUMEAUTOMATIC:
        if Assigned(FOnPowerChange) then FOnPowerChange(nil, False);
    end;

    Exit;
  end;
end;

class procedure TBatteryMode.PowerSchemeProviderActivate(Sender: TObject;
  const PowerScheme: IPowerScheme);
begin
  FNotSetBrightness := UnknownBrightness;
  FFirstChangeBrightnessFix := False;

  FBatteryState.PowerScheme := PowerScheme;

  if Assigned(FOnGlobalPowerSchemeChange) then
    FOnGlobalPowerSchemeChange(nil, FBatteryState);

  if Assigned(FOnStateChange) then FOnStateChange(nil, FBatteryState);
end;

class procedure TBatteryMode.PowerSchemeProviderUpdate(Sender: TObject;
  const PowerSchemes: TPowerSchemeList);
begin
  if Assigned(FOnUpdatePowerScheme) then FOnUpdatePowerScheme(nil,  FPowerSchemeProvider.Schemes);
end;

class procedure TBatteryMode.PowerSchemeProviderInternalActivating(
  Sender: TObject; const PowerScheme: IPowerScheme);
begin
  FBatteryState.PowerScheme := PowerScheme;
  if Assigned(FOnLocalPowerSchemeChanges) then
    FOnLocalPowerSchemeChanges(nil, FBatteryState);
end;

class procedure TBatteryMode.PowerSchemeProviderInternalActivated(
  Sender: TObject; const PowerScheme: IPowerScheme);
begin
  if Assigned(FOnLocalPowerSchemeChanged) then
    FOnLocalPowerSchemeChanged(nil, FBatteryState);
end;

class procedure TBatteryMode.PowerSchemeProviderEnegrySaverSwitched(
  Sender: TObject; const Value: Boolean);
begin
  if FBatteryState.BatterySaver = Value then Exit;

  FFirstChangeBrightnessFix := False;
  FBatteryState.BatterySaver := Value;

  if Assigned(FOnStateChange) then FOnStateChange(nil, FBatteryState);
end;

class procedure TBatteryMode.PowerSchemeProviderEnegrySaverBrightnessWeightChange(
  Sender: TObject; const Value: DWORD);
begin
  if FBatteryState.EnergySaverBrightness = Value then Exit;

  FBatteryState.EnergySaverBrightness := Value;

  if Assigned(FOnStateChange) then FOnStateChange(nil, FBatteryState);
end;

class function TBatteryMode.ACLineStatusToSystemPowerCondition(
  ACLineStatus: Byte): TSystemPowerCondition;
begin
  case ACLineStatus of
    AC_LINE_OFFLINE       : Exit(PoDc);
    AC_LINE_ONLINE        : Exit(PoAc);
    AC_LINE_BACKUP_POWER  : Exit(PoHot);
    else Exit(PoConditionMaximum);
  end;
end;

class procedure TBatteryMode.UpdateSystemPowerStatus(const Status: TSystemPowerStatus);
var
  PowerCondition: TSystemPowerCondition;
begin
  FBatteryState.Percentage := Status.BatteryLifePercent;
  FBatteryState.BatteryPresent := IsBatteriesPresent;

  PowerCondition := ACLineStatusToSystemPowerCondition(Status.ACLineStatus);
  if PowerCondition <> FBatteryState.PowerCondition then
  begin
    // Изменился источник питания
    FFirstChangeBrightnessFix := True;

    FBatteryState.PowerCondition := PowerCondition;
    FBatteryState.Mobile := IsMobilePlatform;
  end;

  FBatteryState.Hint := SystemPowerStatusToHint(Status, FBatteryState);

  if Assigned(FOnStateChange) then FOnStateChange(nil, FBatteryState);
end;

class procedure TBatteryMode.UpdateLidSwitchState(LidSwitchOpen: BOOL);
begin
  if FBatteryState.LidSwitchOpen = LidSwitchOpen then Exit;

  FBatteryState.LidSwitchOpen := LidSwitchOpen;

  if Assigned(FOnStateChange) then FOnStateChange(nil, FBatteryState);
end;



class function TBatteryMode.ApplyBrightness: Boolean;
var
  PreparedBrightness: DWORD;
begin
  Result := True;
  try
    if FBrightness = UnknownBrightness then Exit(True);

    if FBrightnessForAllScheme then begin
      if FFirstChangeBrightnessFix then
        FBrightness := FNotSetBrightness;

      if FBrightness = UnknownBrightness then Exit(True);

      if FBatteryState.BatterySaver then
        PreparedBrightness := FBrightness * 100 div FBatteryState.EnergySaverBrightness
      else
        PreparedBrightness := FBrightness;

      try
        FPowerSchemeProvider.BrightnessForAllScheme[PoAc] := PreparedBrightness;
        FPowerSchemeProvider.BrightnessForAllScheme[PoDc] := PreparedBrightness;
      except
        Result := False;
      end;

      if FFirstChangeBrightnessFix then
        FPowerSchemeProvider.ReActivate;

      FNotSetBrightness := FBrightness;
    end else begin
      if FBatteryState.BatterySaver then
        PreparedBrightness := FBrightness * 100 div FBatteryState.EnergySaverBrightness
      else
        PreparedBrightness := FBrightness;

      try
        FPowerSchemeProvider.Active.Brightness[FBatteryState.PowerCondition] := PreparedBrightness;
      except
        Result := False;
      end;
    end;
  finally
    FFirstChangeBrightnessFix := False;
  end;
end;


class procedure TBatteryMode.Init;
var
  SystemPowerStatus: TSystemPowerStatus;
begin
  if IsWindowsVistaOrGreater then
  begin
    if not IsServiceRunning(nil, 'Power') then
    begin
      MessageBox(0, LPCTSTR(TLang[3000]), LPCTSTR(TLang[1]), MB_OK or MB_ICONERROR);
      ExitProcess(TStartupTasks.ERROR_PowerService);
    end;

    FPowerSchemeProvider := TPowerSchemeProvider.Create;
  end
  else
    FPowerSchemeProvider := TPowerSchemeProviderLegacy.Create;

  FPowerSchemeProvider.OnUpdate := PowerSchemeProviderUpdate;
  FPowerSchemeProvider.OnActivate := PowerSchemeProviderActivate;
  FPowerSchemeProvider.OnInternalActivating := PowerSchemeProviderInternalActivating;
  FPowerSchemeProvider.OnInternalActivated := PowerSchemeProviderInternalActivated;
  FPowerSchemeProvider.OnEnegrySaverSwitched := PowerSchemeProviderEnegrySaverSwitched;
  FPowerSchemeProvider.OnEnegrySaverBrightnessWeightChange := PowerSchemeProviderEnegrySaverBrightnessWeightChange;

  FBrightness := UnknownBrightness;
  FNotSetBrightness := UnknownBrightness;
  FBrightnessForAllScheme := False;
  FFirstChangeBrightnessFix := False;

  GetSystemPowerStatus(SystemPowerStatus);
  FBatteryState.Percentage := SystemPowerStatus.BatteryLifePercent;
  FBatteryState.PowerScheme := FPowerSchemeProvider.Active;
  FBatteryState.PowerCondition := ACLineStatusToSystemPowerCondition(SystemPowerStatus.ACLineStatus);
  FBatteryState.BatterySaver := FPowerSchemeProvider.EnegrySaver;
  FBatteryState.EnergySaverBrightness := FPowerSchemeProvider.Active.EnegrySaverBrightnessWeight[FBatteryState.PowerCondition];
  FBatteryState.BatteryPresent := IsBatteriesPresent;
  FBatteryState.Mobile := IsMobilePlatform;
  FBatteryState.Hint := SystemPowerStatusToHint(SystemPowerStatus, FBatteryState);
  FBatteryState.LidSwitchOpen := True;

  HBatteryMsgForm := AllocateHWnd(BatteryMsgFormHandle);

  if IsWindowsVistaOrGreater then
  begin
    // NotifyLidSwitchStateChange должен быть зарегистрирован первым
    // из за невозможности получить значение без события
    NotifyLidSwitchStateChange := RegisterPowerSettingNotification(
      HBatteryMsgForm, GUID_LIDSWITCH_STATE_CHANGE, DEVICE_NOTIFY_WINDOW_HANDLE);
    NotifyBatteryPercentageRemaining := RegisterPowerSettingNotification(
      HBatteryMsgForm, GUID_BATTERY_PERCENTAGE_REMAINING, DEVICE_NOTIFY_WINDOW_HANDLE);
    NotifyAcdcPowerSource := RegisterPowerSettingNotification(
      HBatteryMsgForm, GUID_ACDC_POWER_SOURCE, DEVICE_NOTIFY_WINDOW_HANDLE);
  end
  else
  begin
    FTimerSystemPowerStatus := SystemPowerStatus;
    if SetTimer(HBatteryMsgForm, TimerSystemPowerStatusCheck, 1000, nil) = 0 then
      RaiseLastOSError;
  end;
end;

class procedure TBatteryMode.Done;
begin
  KillTimer(HBatteryMsgForm, TimerSystemPowerStatusCheck);

  if NotifyAcdcPowerSource <> nil then
    UnregisterPowerSettingNotification(NotifyAcdcPowerSource);
  if NotifyBatteryPercentageRemaining <> nil then
    UnregisterPowerSettingNotification(NotifyBatteryPercentageRemaining);
  if NotifyLidSwitchStateChange <> nil then
    UnregisterPowerSettingNotification(NotifyLidSwitchStateChange);

  DeallocateHWnd(HBatteryMsgForm);
end;

initialization
  TBatteryMode.Init;

finalization
  TBatteryMode.Done;

end.
