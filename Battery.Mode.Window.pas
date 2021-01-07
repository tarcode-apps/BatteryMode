unit Battery.Mode.Window;

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.ShellAPI,
  System.SysUtils, System.Variants, System.Classes, System.Win.Registry,
  System.Generics.Collections,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Menus, Vcl.StdCtrls,
  Vcl.ExtCtrls,
  Api.Pipe.Server,
  Autorun.Manager,
  AutoUpdate, AutoUpdate.Scheduler,
  Battery.Mode, Battery.Controls, Battery.Splash, Battery.Icons,
  Brightness, Brightness.Manager, Brightness.Manager.HookHandler, Brightness.Controls,
  Brightness.Providers.Physical, Brightness.Providers.WMI, Brightness.Providers.LCD,
  Core.Language, Core.Language.Controls, Core.Startup,
  Core.UI, Core.UI.Controls, Core.UI.Notifications,
  Power, Power.Display, Power.Shutdown,
  Power.WinApi.PowrProf,
  Scheduling, Scheduling.Scheduler, Scheduling.UI.Scheduler,
  Scheduling.StateConfigurator, Scheduling.Configurator,
  Tray.Notify.Window, Tray.Notify.Controls,
  Versions, Versions.Info, Versions.Helpers,
  HotKey, HotKey.Handler,
  PowerMonitor.Window,
  Settings.Window;

const
  REG_Key = 'Software\Battery Mode';
  REG_Current = 'Current';
  REG_Version = 'Version';
  REG_IconStyle = 'Icon Style';
  REG_IconBehavior = 'Icon Behavior';
  REG_IconColorType = 'White Icon'; // Legacy
  REG_ExplicitMissingBattery = 'Explicit Missing Battery';
  REG_HotKeyEnable = 'HotKey Enable';
  REG_SystemBorder = 'System Border';
  REG_FixedLocalBrightness = 'Fixed Local Brightness';
  REG_ShowMonitorName = 'Show Monitor Name';
  REG_ShowBrightnessPercent = 'Show Brightness Percent';
  REG_BrightnessRescanDelayMillisecond = 'Brightness Rescan Delay';
  REG_DisplayIndicator = 'Display Indicator Power Schemes';
  REG_FeatureMissingScheme = 'Feature Missing Scheme';
  REG_FeatureOverlay = 'Feature Overlay';
  REG_FeatureHiddedScheme = 'Show Hidded Scheme'; // Legacy
  REG_AutoUpdateEnable = 'AutoUpdate Enable';
  REG_AutoUpdateLastCheck = 'AutoUpdate Last Check';
  REG_AutoUpdateSkipVersion = 'AutoUpdate Skip Version';
  REG_HotKeyNextScheme = 'HotKey Next Scheme';
  REG_SchedulerEnabled = 'Scheduler Enabled';
  REG_LinkType = 'Link Type';
  REG_LinkTypeRdp = 'Link Type RDP';
  REG_ID = 'ID';
  REG_Language = 'Language';

  MSGFLT_ALLOW = 1;
  MSGFLT_DISALLOW = 2;
  MSGFLT_RESET = 0;

  HotKeyNextScheme = 0;

type
  TDisplayIndicator = (diNone, diPrimary, diAll);
  TUIInfo = (UIInfoHide, UIInfoSN);
  TUiLabel = (
    uilPower,
    uilMonitorOff,
    uilShutdown,
    uilReboot,
    uilSleep,
    uilHibernate,
    uilLogOut,
    uilLock,
    uilDiagnostic,
    uilPowerMonitor,
    uilDisconnect);

  TConfig = record
    IconStyle: TIconStyle;
    IconColorType: TIconColorType;
    IconBehavior: TIconBehavior;
    ExplicitMissingBattery: Boolean;
    HotKeyEnable: Boolean;
    SystemBorder: TSystemBorder;
    FixedLocalBrightness: Boolean;
    ShowMonitorName: Boolean;
    ShowBrightnessPercent: Boolean;
    BrightnessRescanDelayMillisecond: Cardinal;
    DisplayIndicator: TDisplayIndicator;
    FeatureMissingScheme: Boolean;
    FeatureOverlay: Boolean;
    FeatureHiddedScheme: Boolean;
    AutoUpdateEnable: Boolean;
    AutoUpdateLastCheck: TDateTime;
    AutoUpdateSkipVersion: TVersion;
    HotKeyNextScheme: string;
    SchedulerEnabled: Boolean;
    LinkType: TUiLabel;
    LinkTypeRdp: TUiLabel;
    Language: string;
    ID: TAppID;
  end;

type
  TBatteryModeForm = class(TTrayNotifyWindow)
    PanelTop: TPanel;
    PanelConfig: TPanel;
    PanelBatterySaver: TPanel; 
    PanelBottom: TPanel;
    LabelAppName: TLabel;
    ImageIcon: TImage;
    LabelAppInfo: TLabel;
    LabelStatus: TLabel;
    LabelConfig: TLabel;
    LinkGridPanel: TGridPanel;
    Link: TStaticText;
    PopupMenuTray: TPopupMenu;
    TrayMenuClose: TMenuItem;
    TrayMenuAutorun: TMenuItem;
    TrayMenuSeparator1: TMenuItem;
    TrayMenuPower: TMenuItem;
    TrayMenuSeparator2: TMenuItem;
    TrayMenuSystemIcon: TMenuItem;
    TrayMenuMobilityCenter: TMenuItem;
    TrayMenuPowerAction: TMenuItem;
    TrayMenuPowerActionDisconnect: TMenuItem;
    TrayMenuPowerActionShutdown: TMenuItem;
    TrayMenuPowerActionReboot: TMenuItem;
    TrayMenuPowerActionSleep: TMenuItem;
    TrayMenuPowerActionHibernate: TMenuItem;
    TrayMenuPowerActionDiagnostic: TMenuItem;
    TrayMenuPowerActionLogOut: TMenuItem;
    TrayMenuPowerActionLock: TMenuItem;
    TrayMenuWebsite: TMenuItem;
    TrayMenuSeparator4: TMenuItem;
    TrayMenuPowerMonitor: TMenuItem;
    TrayMenuSeparator3: TMenuItem;
    TrayMenuScheduler: TMenuItem;
    TrayMenuBrightnessUpdate: TMenuItem;
    TrayMenuSeparator6: TMenuItem;
    TrayMenuMonitorsOff: TMenuItem;
    TrayMenuSeparator7: TMenuItem;
    TrayMenuLanguage: TMenuItem;
    TrayMenuLanguageSystem: TMenuItem;
    TrayMenuSeparator8: TMenuItem;
    TrayMenuSettings: TMenuItem;
    CheckBoxBatterySaver: TCheckBox;

    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormDeactivate(Sender: TObject);
    procedure FormShow(Sender: TObject);

    procedure LinkClick(Sender: TObject);

    procedure LabelAppInfoClick(Sender: TObject);
    procedure TrayMenuCloseClick(Sender: TObject);
    procedure TrayMenuAutoUpdateEnableClick(Sender: TObject);
    procedure TrayMenuAutoUpdateCheckClick(Sender: TObject);
    procedure TrayMenuSchedulerClick(Sender: TObject);
    procedure TrayMenuWebsiteClick(Sender: TObject);
    procedure TrayMenuAutorunClick(Sender: TObject);
    procedure TrayMenuPowerClick(Sender: TObject);
    procedure TrayMenuSystemIconClick(Sender: TObject);
    procedure TrayMenuMobilityCenterClick(Sender: TObject);
    procedure TrayMenuPowerActionDisconnectClick(Sender: TObject);
    procedure TrayMenuPowerActionShutdownClick(Sender: TObject);
    procedure TrayMenuPowerActionRebootClick(Sender: TObject);
    procedure TrayMenuPowerActionSleepClick(Sender: TObject);
    procedure TrayMenuPowerActionHibernateClick(Sender: TObject);
    procedure TrayMenuPowerActionDiagnosticClick(Sender: TObject);
    procedure TrayMenuPowerActionLogOutClick(Sender: TObject);
    procedure TrayMenuPowerActionLockClick(Sender: TObject);
    procedure TrayMenuPowerMonitorClick(Sender: TObject);
    procedure TrayMenuBrightnessUpdateClick(Sender: TObject);
    procedure TrayMenuMonitorsOffClick(Sender: TObject);
    procedure TrayMenuLanguageItemClick(Sender: TObject);
    procedure TrayMenuSettingsClick(Sender: TObject);

    procedure TrayNotifyUpdateAvalible(Sender: TObject; Value: Integer);
    procedure TrayNotifyUpdateFail(Sender: TObject; Value: Integer);
    procedure TrayIconPopupMenu(Sender: TObject; Shift: TShiftState);

    procedure CheckBoxBatterySaverClick(Sender: TObject);
  protected
    procedure LoadIcon; override;
    procedure Loadlocalization;
    procedure LoadAvailableLocalizetions;
    procedure DoSystemUsesLightThemeChange(LightTheme: Boolean); override;

    function DefaultConfig: TConfig;
    function LoadConfig: TConfig;
    procedure SaveConfig(Conf: TConfig);
  private
    LockerPowerScheme: ILocker;
    LockerAutorun: ILocker;
    LockerBatterySaver: ILocker;
    LockerSaveConfig: ILocker;
    LockerLanguage: ILocker;

    FUIInfo: TUIInfo;
    FLinkType: TUiLabel;
    FLinkTypeRdp: TUiLabel;
    FLanguage: string;

    FIsRemoteSession: Boolean;

    FAutoUpdateScheduler: TAutoUpdateScheduler;

    ApiServer: TApiServer;

    FBrightnessConfigurator: TBrightnessConfigurator;
    FBrightnessManager: TBrightnessManager;
    FBrightnessManagerHookHandler: TBrightnessManagerHookHandler;
    FPhysicalBrightnessProvider: TPhysicalBrightnessProvider;
    FWMIBrightnessProvider: TWMIBrightnessProvider;
    FLCDBrightnessProvider: TLCDBrightnessProvider;
    FBrightnessPanel: TBrightnessListPanel;
    FBrightnessLastLevels: TDictionary<string, Integer>;

    FHotKeyHandler: THotKeyHendler;
    
    FScheduler: TScheduler;

    DisplayStateHandler: TDisplayStateHandler;

    SchemeRadioButtons: TList<TSchemeRadioButton>;

    procedure SchemeRadioButtonClick(Sender: TObject);

    procedure OpenPowerCFG;
    procedure OpenSystemIcon;
    procedure OpenMobilityCenter;
    procedure MonitorOff;

    procedure SetUIInfo(const Value: TUIInfo);
    function GetUiLabel: TUiLabel;
    procedure SetUiLabel(const Value: TUiLabel);
    procedure SetLanguage(const Value: string);

    procedure AutorunManagerAutorun(Sender: TObject; Enable: Boolean);

    procedure BatteryModeUpdatePowerScheme(Sender: TObject; const PowerSchemeList: TPowerSchemeList);
    procedure BatteryModeStateChange(Sender: TObject; const State: TBatteryState);
    procedure BatteryModeLocalPowerSchemeChanged(Sender: TObject; const State: TBatteryState);
    procedure BatteryModeGlobalPowerSchemeChange(Sender: TObject; const State: TBatteryState);

    procedure IconHelperChange(Sender: TObject);

    procedure HotKeyHandlerHotKey(Sender: TObject; Index: THotKeyIndex);

    procedure DisplayStateHandlerDisplayStateChange(Sender: TObject; DisplayState: TDisplayState);

    procedure BrightnessManagerBeforeUpdate(Sender: TObject);
    procedure BrightnessManagerAfterUpdate(Sender: TObject);

    procedure BrightnessPanelAddMonitor(Sender: TObject; Monitor: IBrightnessMonitor);
    procedure BrightnessPanelRemoveMonitor(Sender: TObject; Monitor: IBrightnessMonitor);
    procedure BrightnessPanelChangeLevel(Sender: IBrightnessMonitor; NewLevel: Integer);

    procedure SetDisplayIndicator(const Value: TDisplayIndicator);
    function GetDisplayIndicator: TDisplayIndicator;

    procedure AutoUpdateSchedulerSaveLastCheck(Sender: TObject; Time: TDateTime);
    procedure AutoUpdateSchedulerInstalling(Sender: TObject);
    procedure AutoUpdateSchedulerSkip(Sender: TObject; Version: TVersion);
    procedure AutoUpdateSchedulerAvalible(Sender: TObject; Version: TVersion);

    procedure WMWtsSessionChange(var Msg: TMessage); message WM_WTSSESSION_CHANGE;
  public
    function DefaultUiLabel: TUiLabel;
    function DefaultUiLabelRdp: TUiLabel;

    procedure SaveCurrentConfig;
    procedure ClearConfig;
    procedure DeleteConfig;
    procedure PrepareRestart;

    property UIInfo: TUIInfo read FUIInfo write SetUIInfo;
    property UiLabel: TUiLabel read GetUiLabel write SetUiLabel;
    property DisplayIndicator: TDisplayIndicator read GetDisplayIndicator write SetDisplayIndicator;
    property IsRemoteSession: Boolean read FIsRemoteSession;
    property Language: string read FLanguage write SetLanguage;

    property BrightnessPanel: TBrightnessListPanel read FBrightnessPanel;
    property BrightnessManager: TBrightnessManager read FBrightnessManager;
    property BrightnessManagerHookHandler: TBrightnessManagerHookHandler read FBrightnessManagerHookHandler;
    property WMIBrightnessProvider: TWMIBrightnessProvider read FWMIBrightnessProvider;

    property HotKeyHandler: THotKeyHendler read FHotKeyHandler;

    property Scheduler: TScheduler read FScheduler;

    property AutoUpdateScheduler: TAutoUpdateScheduler read FAutoUpdateScheduler;
  end;

var
  BatteryModeForm: TBatteryModeForm;

implementation

{$R *.dfm}

procedure TBatteryModeForm.FormCreate(Sender: TObject);
var
  Conf: TConfig;
  Monitor: IBrightnessMonitor;
  SchemeFeatures: TPowerSchemeFeatures;
begin
  FIsRemoteSession := GetSystemMetrics(SM_REMOTESESSION) <> 0;
  try WTSRegisterSessionNotification(Handle, NOTIFY_FOR_THIS_SESSION); except end;

  // Инициализация блокировщиков событий
  LockerPowerScheme   := TLocker.Create;
  LockerAutorun       := TLocker.Create;
  LockerBatterySaver  := TLocker.Create;
  LockerSaveConfig    := TLocker.Create;
  LockerLanguage      := TLocker.Create;

  // Загрузка конфигурации
  Conf := LoadConfig;

  // Инициализация интерфейса
  Link.LinkMode           := True;
  PanelTop.Shape          := psBottomLine;
  PanelTop.Style          := tfpsHeader;
  PanelConfig.Shape       := psBottomLine;
  PanelConfig.Style       := tfpsBody;
  PanelBatterySaver.Shape := psBottomLine;
  PanelBatterySaver.Style := tfpsBody;
  PanelBottom.Style       := tfpsLinkArea;
  LabelAppName.Caption    := TVersionInfo.ProductName;
  UIInfo                  := Low(UIInfo);
  FLinkType               := Conf.LinkType;
  FLinkTypeRdp            := Conf.LinkTypeRdp;
  UiLabel                 := GetUiLabel;

  LabelAppInfo.Font.Name := Font.Name;
  LabelAppInfo.Font.Size := Font.Size;
  LabelConfig.Font.Name := Font.Name;
  LabelConfig.Font.Size := Font.Size;

  CheckBoxBatterySaver.AutoSize := True;

  SystemBorder := Conf.SystemBorder;
  
  SchemeRadioButtons := TList<TSchemeRadioButton>.Create;

  // Инициализация трея
  TrayIcon.PopupMenu := PopupMenuTray;
  TrayIcon.Icon := Application.Icon.Handle;
  TrayIcon.OnPopupMenu := TrayIconPopupMenu;

  // Инициализация Notification
  TNotificationService.Notification := TrayNotification;

  // Инициализация автозагрузки
  AutorunManager.OnAutorun := AutorunManagerAutorun;

  // Инициализация заставки
  TBatterySplash.ScaleByScreen := 8;
  DisplayIndicator := Conf.DisplayIndicator;

  // Инициализация значков
  TIconHelper.IconStyle := Conf.IconStyle;
  TIconHelper.IconColorType := Conf.IconColorType;
  TIconHelper.IconBehavior := Conf.IconBehavior;
  if IsSystemUsesLightTheme then
    TIconHelper.IconTheme := ithDark
  else
    TIconHelper.IconTheme := ithLight;
  TIconHelper.ExplicitMissingBattery := Conf.ExplicitMissingBattery;
  TIconHelper.OnChange := IconHelperChange;

  // Инициализация меню выключения
  TrayMenuPowerActionShutdown.Enabled    := TPowerShutdownAction.Create.IsSupported;
  TrayMenuPowerActionReboot.Enabled      := TPowerRebootAction.Create.IsSupported;
  TrayMenuPowerActionSleep.Enabled       := TPowerSleepAction.Create.IsSupported;
  TrayMenuPowerActionHibernate.Enabled   := TPowerHibernateAction.Create.IsSupported;
  TrayMenuPowerActionLogOut.Enabled      := TPowerLogOutAction.Create.IsSupported;
  TrayMenuPowerActionLock.Enabled        := TPowerLockAction.Create.IsSupported;
  TrayMenuPowerActionDiagnostic.Visible  := TPowerDiagnosticAction.Create.IsSupported;

  // Инициализация TBatteryMode
  SchemeFeatures := [];
  if Conf.FeatureMissingScheme then Include(SchemeFeatures, psfMissingScheme);
  if Conf.FeatureOverlay then Include(SchemeFeatures, psfOverlay);
  if Conf.FeatureHiddedScheme then Include(SchemeFeatures, psfHiddenScheme);
  TBatteryMode.PowerSchemes.SchemeFeatures := SchemeFeatures;
  TBatteryMode.UpdateState;
  TBatteryMode.BrightnessForAllScheme := Conf.FixedLocalBrightness;
  TBatteryMode.OnUpdatePowerScheme := BatteryModeUpdatePowerScheme;
  TBatteryMode.OnStateChange := BatteryModeStateChange;
  TBatteryMode.OnLocalPowerSchemeChanged := BatteryModeLocalPowerSchemeChanged;
  TBatteryMode.OnGlobalPowerSchemeChange := BatteryModeGlobalPowerSchemeChange;

  // Инициализация горячих клавиш
  FHotKeyHandler := THotKeyHendler.Create;
  FHotKeyHandler.OnHotKey := HotKeyHandlerHotKey;
  FHotKeyHandler.RegisterHotKey(HotKeyNextScheme, THotKeyValue.Create(Conf.HotKeyNextScheme));
  FHotKeyHandler.Enabled := Conf.HotKeyEnable;

  DisplayStateHandler := TDisplayStateHandler.Create;
  DisplayStateHandler.DisplayStateChange := DisplayStateHandlerDisplayStateChange;

  // Инициализация подсветки
  FBrightnessLastLevels := TDictionary<string, Integer>.Create();
  FBrightnessConfigurator := TBrightnessConfigurator.Create(REG_Key);
  // Инициализация BrightnessManager
  FBrightnessManager := TBrightnessManager.Create(FBrightnessConfigurator);
  FBrightnessManager.RescanDelayMillisecond := Conf.BrightnessRescanDelayMillisecond;
  FBrightnessManager.OnBeforeUpdate := BrightnessManagerBeforeUpdate;
  FBrightnessManager.OnAfterUpdate := BrightnessManagerAfterUpdate;
  if IsWindowsVistaOrGreater then
  begin
    FPhysicalBrightnessProvider := TPhysicalBrightnessProvider.Create(True);
    FBrightnessManager.AddProvider(FPhysicalBrightnessProvider);

    FWMIBrightnessProvider := TWMIBrightnessProvider.Create(True);
    FWMIBrightnessProvider.AdaptiveBrightnessForAllScheme := Conf.FixedLocalBrightness;
    FBrightnessManager.AddProvider(FWMIBrightnessProvider);
  end
  else
  begin
    FLCDBrightnessProvider := TLCDBrightnessProvider.Create(True);
    FBrightnessManager.AddProvider(FLCDBrightnessProvider);
  end;

  for Monitor in FBrightnessManager do
  begin
    if (Monitor.MonitorType = bmtInternal) and (Monitor.Enable or TBatteryMode.BrightnessForAllScheme) then
      TBatteryMode.Brightness := Monitor.NormalizedBrightness[Monitor.Level];

    if Monitor.Enable and Monitor.RequireBrightnessRefreshOnPowerUp then
    try
      Monitor.Level := Monitor.Level;
    except
      // ignore
    end;
  end;

  // Инициализация BrightnessPanel
  FBrightnessPanel := TBrightnessListPanel.Create(PanelBottom, BrightnessManager);
  FBrightnessPanel.OnAddMonitor := BrightnessPanelAddMonitor;
  FBrightnessPanel.OnRemoveMonitor := BrightnessPanelRemoveMonitor;
  FBrightnessPanel.OnChangeLevel := BrightnessPanelChangeLevel;
  FBrightnessPanel.ShowMonitorName := Conf.ShowMonitorName;
  FBrightnessPanel.ShowBrightnessPercent := Conf.ShowBrightnessPercent;
  FBrightnessPanel.Parent := PanelBottom;
  FBrightnessPanel.TabOrder := 0;

  FBrightnessManagerHookHandler := TBrightnessManagerHookHandler.Create(FBrightnessManager, TrayIcon);

  // Инициализация AutoUpdateScheduler
  FAutoUpdateScheduler := TAutoUpdateScheduler.Create(TLang[40],
    Conf.AutoUpdateLastCheck, Conf.AutoUpdateSkipVersion, Conf.ID);
  FAutoUpdateScheduler.OnSaveLastCheck := AutoUpdateSchedulerSaveLastCheck;
  FAutoUpdateScheduler.OnInstalling := AutoUpdateSchedulerInstalling;
  FAutoUpdateScheduler.OnSkip := AutoUpdateSchedulerSkip;
  FAutoUpdateScheduler.OnAvalible := AutoUpdateSchedulerAvalible;
  FAutoUpdateScheduler.Enable := Conf.AutoUpdateEnable;

  // Инициализация API
  ApiServer := TApiServer.Create(BrightnessManager);

  // Инициализация планировщика
  FScheduler := TScheduler.Create(
    TStateConfigurator.Create(string.Join(PathDelim, [REG_Key, REG_Current])),
    TRuleConfigurator.Create(REG_Key));

  // Загрузка локализации
  FLanguage := TLang.ResolveLocaleName(Conf.Language);
  LoadAvailableLocalizetions;
  Loadlocalization;

  // Отображение иконки в трее
  TrayIcon.Visible := True;

  // Запуск планировщика
  FScheduler.Enabled := Conf.SchedulerEnabled;

  case FAutoUpdateScheduler.StartupUpdateStatus of
    susComplete: TrayNotification.Notify(Format(TLang[45], [TVersionInfo.FileVersion.ToString]));
    susFail: TrayNotification.Notify(Format(TLang[46], [TVersionInfo.FileVersion.ToString]), [nfError], TrayNotifyUpdateFail);
  end;
end;

procedure TBatteryModeForm.FormDestroy(Sender: TObject);
begin
  if WindowCreated and not LockerSaveConfig.IsLocked then
    SaveCurrentConfig;

  FScheduler.Free;

  FAutoUpdateScheduler.Free;

  FBrightnessManager.Free;
  FBrightnessPanel.Free;
  FBrightnessManagerHookHandler.Free;
  FBrightnessConfigurator.Free;
  FBrightnessLastLevels.Free;

  ApiServer.Free;

  DisplayStateHandler.Free;

  FHotKeyHandler.Free;

  try WTSUnRegisterSessionNotification(Handle); except end;
end;

procedure TBatteryModeForm.FormActivate(Sender: TObject);
begin
  TBatteryMode.UpdateSchemes;
end;

procedure TBatteryModeForm.FormDeactivate(Sender: TObject);
begin
  UIInfo:= Low(UIInfo);
end;

procedure TBatteryModeForm.FormShow(Sender: TObject);
begin
  PanelConfig.Realign;
end;

procedure TBatteryModeForm.WMWtsSessionChange(var Msg: TMessage);
var
  RemoteSession: Boolean;
begin
  RemoteSession := GetSystemMetrics(SM_REMOTESESSION) <> 0;
  if FIsRemoteSession = RemoteSession then Exit;

  FIsRemoteSession := RemoteSession;
  UiLabel := GetUiLabel;
end;

{$REGION 'Form Events'}
procedure TBatteryModeForm.LabelAppInfoClick(Sender: TObject);
begin
  if UIInfo = High(UIInfo) then
    UIInfo:= Low(UIInfo)
  else
    UIInfo:= Succ(UIInfo);
end;

procedure TBatteryModeForm.LinkClick(Sender: TObject);
  procedure PerformPowerAction(Action: IPowerAction);
  begin
    if Action.IsSupported then
      if Action.Perform then
        ShowWindow(Handle, SW_HIDE);
  end;
begin
  case UiLabel of
    uilPower: OpenPowerCFG;
    uilMonitorOff:
      begin
        MonitorOff;
        ShowWindow(Handle, SW_HIDE);
      end;
    uilShutdown: PerformPowerAction(TPowerShutdownAction.Create);
    uilReboot:
      if GetKeyState(VK_SHIFT) < 0 then
        PerformPowerAction(TPowerDiagnosticAction.Create)
      else
        PerformPowerAction(TPowerRebootAction.Create);
    uilSleep: PerformPowerAction(TPowerSleepAction.Create);
    uilHibernate: PerformPowerAction(TPowerHibernateAction.Create);
    uilLogOut: PerformPowerAction(TPowerLogOutAction.Create);
    uilLock: PerformPowerAction(TPowerLockAction.Create);
    uilDiagnostic: PerformPowerAction(TPowerDiagnosticAction.Create);
    uilPowerMonitor: ShowPowerMonitor;
    uilDisconnect: PerformPowerAction(TPowerDisconnectAction.Create);
  end;
end;

procedure TBatteryModeForm.TrayMenuPowerActionDisconnectClick(Sender: TObject);
begin
  TPowerDisconnectAction.Create.Perform;
end;

procedure TBatteryModeForm.TrayMenuPowerActionShutdownClick(Sender: TObject);
begin
  TPowerShutdownAction.Create.Perform;
end;

procedure TBatteryModeForm.TrayMenuPowerActionRebootClick(Sender: TObject);
begin
  TPowerRebootAction.Create.Perform;
end;

procedure TBatteryModeForm.TrayMenuPowerActionSleepClick(Sender: TObject);
begin
  TPowerSleepAction.Create.Perform;
end;

procedure TBatteryModeForm.TrayMenuPowerActionHibernateClick(Sender: TObject);
begin
  TPowerHibernateAction.Create.Perform;
end;

procedure TBatteryModeForm.TrayMenuPowerActionDiagnosticClick(Sender: TObject);
begin
  TPowerDiagnosticAction.Create.Perform;
end;

procedure TBatteryModeForm.TrayMenuPowerActionLogOutClick(Sender: TObject);
begin
  TPowerLogOutAction.Create.Perform;
end;

procedure TBatteryModeForm.TrayMenuPowerActionLockClick(Sender: TObject);
begin
  TPowerLockAction.Create.Perform;
end;

procedure TBatteryModeForm.TrayMenuPowerClick(Sender: TObject);
begin
  OpenPowerCFG;
end;

procedure TBatteryModeForm.TrayMenuSystemIconClick(Sender: TObject);
begin
  OpenSystemIcon;
end;

procedure TBatteryModeForm.TrayMenuMobilityCenterClick(Sender: TObject);
begin
  OpenMobilityCenter;
end;

procedure TBatteryModeForm.TrayMenuMonitorsOffClick(Sender: TObject);
begin
  MonitorOff;
end;

procedure TBatteryModeForm.TrayMenuAutorunClick(Sender: TObject);
begin
  if LockerAutorun.IsLocked then Exit;
  AutorunManager.SetAutorunEx((Sender as TMenuItem).Checked);
  SetForegroundWindow(TrayIcon.Handle);
end;

procedure TBatteryModeForm.TrayMenuBrightnessUpdateClick(Sender: TObject);
begin
  BrightnessManager.Update;
end;

procedure TBatteryModeForm.TrayMenuSettingsClick(Sender: TObject);
begin
  TSettingsWindow.Open(GetKeyState(VK_SHIFT) < 0);
end;

procedure TBatteryModeForm.TrayMenuAutoUpdateEnableClick(Sender: TObject);
begin
  AutoUpdateScheduler.Enable := (Sender as TMenuItem).Checked;
end;

procedure TBatteryModeForm.TrayMenuAutoUpdateCheckClick(Sender: TObject);
begin
  AutoUpdateScheduler.Check(True);
end;

procedure TBatteryModeForm.TrayMenuSchedulerClick(Sender: TObject);
begin
  TSchedulingWindow.Configure(FScheduler);
end;

procedure TBatteryModeForm.TrayMenuWebsiteClick(Sender: TObject);
begin
  ShellExecute(Handle, 'open', LPTSTR(TLang.GetString(12)), nil, nil, SW_RESTORE);
end;

procedure TBatteryModeForm.TrayMenuPowerMonitorClick(Sender: TObject);
begin
  ShowPowerMonitor;
end;

procedure TBatteryModeForm.TrayMenuLanguageItemClick(Sender: TObject);
begin
  if LockerLanguage.IsLocked then Exit;

  if (Sender is TLanguageMenuItem) then
    Language := TLang.LCIDToLocaleName((Sender as TLanguageMenuItem).Localization.LanguageId)
  else
    Language := '';
end;

procedure TBatteryModeForm.TrayMenuCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TBatteryModeForm.TrayNotifyUpdateAvalible(Sender: TObject; Value: Integer);
begin
  SetForegroundWindow(TrayIcon.Handle);
  AutoUpdateScheduler.Check(True);
end;

procedure TBatteryModeForm.TrayNotifyUpdateFail(Sender: TObject; Value: Integer);
begin
  ShellExecute(Handle, 'open', LPTSTR(TLang.GetString(12)), nil, nil, SW_RESTORE);
end;

procedure TBatteryModeForm.TrayIconPopupMenu(Sender: TObject;
  Shift: TShiftState);
begin
  TrayMenuBrightnessUpdate.Visible      := ssShift in Shift;

  TrayMenuSeparator6.Visible            := ssShift in Shift;

  TrayMenuMonitorsOff.Visible           := not IsRemoteSession;
  TrayMenuPowerAction.Visible           := IsRemoteSession or (ssShift in Shift);
end;

procedure TBatteryModeForm.SchemeRadioButtonClick(Sender: TObject);
begin
  if LockerPowerScheme.IsLocked then Exit;

  if (Sender as TSchemeRadioButton).Checked then
    (Sender as TSchemeRadioButton).PowerScheme.Activate;
end;

procedure TBatteryModeForm.CheckBoxBatterySaverClick(Sender: TObject);
begin
  if LockerBatterySaver.IsLocked then Exit;

  TBatteryMode.BatterySaver := (Sender as TCheckBox).Checked; 
end;
{$ENDREGION}

{$REGION 'TBatteryMode Event'}
procedure TBatteryModeForm.BatteryModeStateChange(Sender: TObject;
  const State: TBatteryState);
var
  RadioButton: TSchemeRadioButton;
begin
  LockerPowerScheme.Lock;
  try
    TrayMenuMobilityCenter.Visible  := State.Mobile and IsWindowsVistaOrGreater;

    for RadioButton in SchemeRadioButtons do begin
      if RadioButton.PowerScheme.Equals(State.PowerScheme) then begin
        if not RadioButton.Checked then begin
          RadioButton.Checked := True;
          ActiveControl := RadioButton;
        end;
      end
      else
        RadioButton.Checked := False;
    end;

    LabelStatus.Caption := State.Hint;
    if State.BatterySaver then
      TrayIcon.Hint := State.Hint + sLineBreak + TLang[680]
    else
      TrayIcon.Hint := State.Hint;

    LoadIcon;
  finally
    LockerPowerScheme.Unlock;
  end;

  LockerBatterySaver.Lock;
  try
    CheckBoxBatterySaver.Checked := State.BatterySaver;
    CheckBoxBatterySaver.Enabled := State.PowerCondition = PoDc;
  finally
    LockerBatterySaver.Unlock;
  end;

  if Assigned(FScheduler) then
  begin
    FScheduler.ChangePercentage(State.Percentage);
    FScheduler.ChangePowerScheme(State.PowerScheme);
    FScheduler.ChangePowerCondition(State.PowerCondition);
    FScheduler.ChangeBatterySaver(State.BatterySaver);
    FScheduler.ChangeLidSwitchState(State.LidSwitchOpen);
  end;
end;

procedure TBatteryModeForm.BatteryModeUpdatePowerScheme(Sender: TObject;
  const PowerSchemeList: TPowerSchemeList);
var
  RadioButton: TSchemeRadioButton;
  Scheme: IPowerScheme;
  HeightAccumulator: ISizeAccumulator;
begin
  LockerPowerScheme.Lock;
  PanelConfig.AutoSize := False;
  PanelConfig.DisableAlign;
  try
    for RadioButton in SchemeRadioButtons do
      RadioButton.Free;

    SchemeRadioButtons.Clear;
    HeightAccumulator := THeightAccumulator.Create(PanelConfig.Padding.Top);
    HeightAccumulator.AddControl(LabelConfig);
    for Scheme in PowerSchemeList do
    begin
      RadioButton := TSchemeRadioButton.Create(PanelConfig, Scheme);
      with RadioButton do
      begin
        Parent := PanelConfig;
        Top := HeightAccumulator.NextControlFront(RadioButton);
        OnClick := SchemeRadioButtonClick;
      end;
      HeightAccumulator.AddControl(RadioButton);
      SchemeRadioButtons.Add(RadioButton);
    end;
  finally
    PanelConfig.EnableAlign;
    PanelConfig.AutoSize := True;
    LockerPowerScheme.Unlock;
  end;
end;

procedure TBatteryModeForm.BatteryModeLocalPowerSchemeChanged(Sender: TObject;
  const State: TBatteryState);
begin
  TBatterySplash.ShowSplash(sdtSelf, State,
    (TIconHelper.IconColorType = ictSchemeInvert) or (TIconHelper.IconColorType = ictSchemeInvert));
end;

procedure TBatteryModeForm.BatteryModeGlobalPowerSchemeChange(Sender: TObject;
  const State: TBatteryState);
begin
  TBatterySplash.ShowSplash(sdtAlways, State,
    (TIconHelper.IconColorType = ictSchemeInvert) or (TIconHelper.IconColorType = ictSchemeInvert));
end;
{$ENDREGION}

{$REGION 'BrightnessManager Events'}
procedure TBatteryModeForm.BrightnessManagerBeforeUpdate(Sender: TObject);
var
  Monitor: IBrightnessMonitor;
begin
  for Monitor in BrightnessManager do
  begin
    if Monitor.RequireBrightnessRefreshOnPowerUp then
      FBrightnessLastLevels[Monitor.UniqueString] := Monitor.Level;
  end;
end;

procedure TBatteryModeForm.BrightnessManagerAfterUpdate(Sender: TObject);
var
  Monitor: IBrightnessMonitor;
  Level: Integer;
begin
  for Monitor in BrightnessManager do
  begin
    if not Monitor.Enable then Continue;
    if not Monitor.RequireBrightnessRefreshOnPowerUp then Continue;

    if FBrightnessLastLevels.TryGetValue(Monitor.UniqueString, Level) then
    begin
      Monitor.Level := Level;
      FBrightnessLastLevels.Remove(Monitor.UniqueString);
    end;
  end;
end;
{$ENDREGION}

{$REGION 'BrightnessPanel Events'}
procedure TBatteryModeForm.BrightnessPanelAddMonitor(Sender: TObject;
  Monitor: IBrightnessMonitor);
begin
  if Monitor.MonitorType = bmtInternal then
    TBatteryMode.Brightness := Monitor.NormalizedBrightness[Monitor.Level];

  FBrightnessManagerHookHandler.UpdateBindings;
end;

procedure TBatteryModeForm.BrightnessPanelRemoveMonitor(Sender: TObject;
  Monitor: IBrightnessMonitor);
begin
  if not (BrightnessManager.InternalMonitorCount > 0) then
    TBatteryMode.Brightness := UnknownBrightness;

  FBrightnessManagerHookHandler.UpdateBindings;
end;

procedure TBatteryModeForm.BrightnessPanelChangeLevel(Sender: IBrightnessMonitor;
  NewLevel: Integer);
begin
  if (Sender.MonitorType = bmtInternal) and (Sender.Enable or TBatteryMode.BrightnessForAllScheme) then
    TBatteryMode.Brightness := Sender.NormalizedBrightness[Sender.Level];
end;
{$ENDREGION}

{$REGION 'AutoUpdateScheduler Event'}
procedure TBatteryModeForm.AutoUpdateSchedulerInstalling(Sender: TObject);
begin
  SaveCurrentConfig;
  TrayIcon.Visible := False;
  Application.Terminate;
  ExitProcess(0);
end;

procedure TBatteryModeForm.AutoUpdateSchedulerSaveLastCheck(Sender: TObject;
  Time: TDateTime);
begin
  SaveCurrentConfig;
end;

procedure TBatteryModeForm.AutoUpdateSchedulerSkip(Sender: TObject;
  Version: TVersion);
begin
  SaveCurrentConfig;
end;

procedure TBatteryModeForm.AutoUpdateSchedulerAvalible(Sender: TObject;
  Version: TVersion);
begin
  TrayNotification.Notify(Format(TLang[44], [Version.ToString]), TrayNotifyUpdateAvalible);
end;
{$ENDREGION}

procedure TBatteryModeForm.HotKeyHandlerHotKey(Sender: TObject;
  Index: THotKeyIndex);
begin
  case Index of
    HotKeyNextScheme: TBatteryMode.NextScheme;
  end;
end;

procedure TBatteryModeForm.DisplayStateHandlerDisplayStateChange(
  Sender: TObject; DisplayState: TDisplayState);
begin
  if (DisplayState = dsOn) and Assigned(BrightnessManager) then
    BrightnessManager.Update(BrightnessManager.RescanDelayMillisecond);

  if Assigned(FScheduler) then
    FScheduler.ChangeDisplayState(DisplayState);
end;

procedure TBatteryModeForm.AutorunManagerAutorun(Sender: TObject; Enable: Boolean);
begin
  LockerAutorun.Lock;
  try
    TrayMenuAutorun.Checked:= Enable;
  finally
    LockerAutorun.Unlock;
  end;
end;

procedure TBatteryModeForm.OpenPowerCFG;
begin
  WinExec('Control.exe powercfg.cpl', SW_RESTORE);
end;

procedure TBatteryModeForm.OpenSystemIcon;
begin
  if IsWindowsVersionOrGreater(10, 0, 14328, 0) then
    WinExec('rundll32 shell32.dll Options_RunDLL 1', SW_RESTORE)
  else if IsWindowsVistaOrGreater then
    WinExec('rundll32 shell32.dll Options_RunDLL 4', SW_RESTORE)
  else
    WinExec('rundll32 shell32.dll Options_RunDLL 1', SW_RESTORE)
end;

procedure TBatteryModeForm.OpenMobilityCenter;
begin
  ShellExecute(0, '', 'mblctr.exe', '/open', '', SW_NORMAL);
end;

procedure TBatteryModeForm.MonitorOff;
begin
  DisplayStateHandler.SetDisplayStateWithTimeout(dsOff, 200);
end;

procedure TBatteryModeForm.IconHelperChange(Sender: TObject);
begin
  LoadIcon;
end;

procedure TBatteryModeForm.LoadIcon;
begin
  TrayIcon.Icon := TIconHelper.GetIcon(GetCurrentPPI);

  if IsWindowsVistaOrGreater then
  begin
    DeleteObject(ImageIcon.Picture.Bitmap.Handle);
    ImageIcon.Picture.Bitmap.Handle := TIconHelper.GetImage(GetCurrentPPI);
  end
  else
  begin
    DeleteObject(ImageIcon.Picture.Icon.Handle);
    ImageIcon.Picture.Icon.Handle := TIconHelper.GetImageAsIcon(GetCurrentPPI);
  end;
end;

procedure TBatteryModeForm.Loadlocalization;
  function GetInternationalization(Index: Integer): string;
  var
    NonLocalized: string;
  begin
    Result := TLang[Index];
    NonLocalized := TLang.GetString(Index, TLang.DefaultLang);
    if Result <> NonLocalized then
      Result := Result + ' (' + NonLocalized + ')';
  end;
begin
  LabelAppName.Caption            := TLang[1];  // Battery Mode
  LabelConfig.Caption             := TLang[2];  // Выберите схему электропитания:

  CheckBoxBatterySaver.Caption    := TLang[60]; // Экономия заряда
  
  TrayMenuClose.Caption           := TLang[9];  // Выход
  TrayMenuAutorun.Caption         := TLang[6];  // Автозапуск
  TrayMenuSettings.Caption        := TLang[3];  // Дополнительные параметры
  TrayMenuWebsite.Caption         := TLang[11]; // Посетить сайт Battery Mode
  TrayMenuPowerMonitor.Caption    := TLang[13]; // Информация о системе элекропитания
  TrayMenuPower.Caption           := TLang[15]; // Электропитание
  TrayMenuSystemIcon.Caption      := TLang[16]; // Включить или выключить системные значки
  TrayMenuMobilityCenter.Caption  := TLang[17]; // Центр мобильности Windows

  TrayMenuBrightnessUpdate.Caption    := TLang[51]; // Обновить конфигурацию мониторов
  TrayMenuMonitorsOff.Caption         := TLang[136]; // Отключить экран

  TrayMenuPowerAction.Caption           := TLang[134]; // Завершение работы или выход из системы
  TrayMenuPowerActionShutdown.Caption   := TLang[137]; // Завершение работы
  TrayMenuPowerActionReboot.Caption     := TLang[138]; // Перезагрузка
  TrayMenuPowerActionSleep.Caption      := TLang[139]; // Спящий режим
  TrayMenuPowerActionHibernate.Caption  := TLang[140]; // Гибернация
  TrayMenuPowerActionLogOut.Caption     := TLang[141]; // Выход
  TrayMenuPowerActionLock.Caption       := TLang[142]; // Блокировать
  TrayMenuPowerActionDiagnostic.Caption := TLang[143]; // Особые варианты загрузки
  TrayMenuPowerActionDisconnect.Caption := TLang[145]; // Отключиться

  TrayMenuLanguage.Caption            := GetInternationalization(150);
  TrayMenuLanguageSystem.Caption      := GetInternationalization(151);

  TrayMenuScheduler.Caption         := TLang[80]; // Планировщик

  TrayIcon.BalloonTitle := TLang[1]; // Battery Mode
  TrayNotification.Title            := TLang[1]; // Battery Mode
end;

procedure TBatteryModeForm.LoadAvailableLocalizetions;
var
  AvailableLocalizations: TAvailableLocalizations;
  Localization: TAvailableLocalization;
  MenuItem: TMenuItem;
begin
  AvailableLocalizations := TLang.GetAvailableLocalizations(0);
  try  
    for Localization in AvailableLocalizations do
    begin
      MenuItem := TLanguageMenuItem.Create(PopupMenuTray, Localization);
      MenuItem.OnClick := TrayMenuLanguageItemClick;
      if Language <> '' then
        MenuItem.Checked := TLang.LCIDToLocaleName(Localization.LanguageId) = Language;
      
      TrayMenuLanguage.Add(MenuItem);
    end;
    
    TrayMenuLanguageSystem.Checked := Language = '';
  finally
    AvailableLocalizations.Free;
  end;
end;

procedure TBatteryModeForm.DoSystemUsesLightThemeChange(LightTheme: Boolean);
begin
  inherited;

  if LightTheme then
    TIconHelper.IconTheme := ithDark
  else
    TIconHelper.IconTheme := ithLight;
end;

procedure TBatteryModeForm.SetUIInfo(const Value: TUIInfo);
const
  VerFmt = '%0:s: %1:s %2:s';
begin
  FUIInfo := Value;
  case Value of
    UIInfoSN: begin
      LabelAppName.Visible := True;
      LabelAppInfo.Visible := True;
      LabelStatus.Visible := False;
      LabelAppInfo.Caption := Format(VerFmt,
        [TLang[10], string(TVersionInfo.FileVersion), TVersionInfo.BinaryTypeAsShortString]);
    end;
    else begin
      LabelAppName.Visible := False;
      LabelAppInfo.Visible := False;
      LabelStatus.Visible := True;
    end;
  end;
end;

function TBatteryModeForm.GetUiLabel: TUiLabel;
begin
  if IsRemoteSession then
    Result := FLinkTypeRdp
  else
    Result := FLinkType;

  if not (Result in [Low(TUiLabel) .. High(TUiLabel)]) then
    Result := DefaultUiLabel;
end;

procedure TBatteryModeForm.SetUiLabel(const Value: TUiLabel);
var
  NormalizedValue: TUiLabel;
begin
  if Value in [Low(TUiLabel) .. High(TUiLabel)] then
    NormalizedValue := Value
  else
    NormalizedValue := DefaultUiLabel;

  if IsRemoteSession then
    FLinkTypeRdp := NormalizedValue
  else
    FLinkType := NormalizedValue;

  case UiLabel of
    uilPower:         Link.Caption := TLang[15];  // Электропитание
    uilMonitorOff:    Link.Caption := TLang[136]; // Отключить экран
    uilShutdown:      Link.Caption := TLang[137]; // Завершение работы
    uilReboot:        Link.Caption := TLang[138]; // Перезагрузка
    uilSleep:         Link.Caption := TLang[139]; // Спящий режим
    uilHibernate:     Link.Caption := TLang[140]; // Гибернация
    uilLogOut:        Link.Caption := TLang[141]; // Выход
    uilLock:          Link.Caption := TLang[142]; // Блокировать
    uilDiagnostic:    Link.Caption := TLang[143]; // Особые варианты загрузки
    uilDisconnect:    Link.Caption := TLang[145]; // Отключиться
    uilPowerMonitor:  Link.Caption := TLang[144]; // Информация о системе электропитания
  end;
end;

procedure TBatteryModeForm.SetLanguage(const Value: string);
var
  CurrentLanguageId: LANGID;
  StartUpInfo : TStartUpInfo;
  ProcessInfo : TProcessInformation;
begin
  if FLanguage = Value then Exit;

  FLanguage := Value;
  CurrentLanguageId := TLang.LanguageId;
  TLang.LocaleName := FLanguage;
  if CurrentLanguageId = TLang.LanguageId then Exit;

  Loadlocalization;

  SaveCurrentConfig;
  FScheduler.SaveState;

  TMutexLocker.Unlock;
  TrayIcon.Visible := False;

  ZeroMemory(@StartUpInfo, SizeOf(StartUpInfo));
  StartUpInfo.cb := SizeOf(StartUpInfo);

  if not CreateProcess(LPCTSTR(Application.ExeName), nil, nil, nil, True,
    GetPriorityClass(GetCurrentProcess), nil, nil, StartUpInfo, ProcessInfo) then
  begin
    TMutexLocker.Lock;
    TrayIcon.Visible := True;
    Exit;
  end;

  LockerSaveConfig.Lock;
  try
    Application.Terminate;
  finally
    CloseHandle(ProcessInfo.hProcess);
    CloseHandle(ProcessInfo.hThread);

    ExitProcess(0);
  end;
end;

function TBatteryModeForm.DefaultUiLabel: TUiLabel;
begin
  Result := uilMonitorOff;
end;

function TBatteryModeForm.DefaultUiLabelRdp: TUiLabel;
begin
  Result := uilPower
end;

function TBatteryModeForm.GetDisplayIndicator: TDisplayIndicator;
begin
  if TBatterySplash.SplashDisplayType = sdtNone then
    Result := diNone
  else if TBatterySplash.MonitorConfig.MonitorType = TBatterySplash.TSplashMonitorType.smtPrimary then
    Result := diPrimary
  else if TBatterySplash.MonitorConfig.MonitorType = TBatterySplash.TSplashMonitorType.smtAll then
    Result := diAll
  else
    Result := diPrimary;
end;

procedure TBatteryModeForm.SetDisplayIndicator(const Value: TDisplayIndicator);
begin
  case Value of
    diNone:
      begin
        TBatterySplash.SplashDisplayType := sdtNone;
      end;
    diPrimary:
      begin
        TBatterySplash.MonitorConfig :=
          TBatterySplash.TSplashMonitorConfig.Create(TBatterySplash.TSplashMonitorType.smtPrimary);
        TBatterySplash.SplashDisplayType := sdtSelf;
      end;
    diAll:
      begin
        TBatterySplash.MonitorConfig :=
          TBatterySplash.TSplashMonitorConfig.Create(TBatterySplash.TSplashMonitorType.smtAll);
        TBatterySplash.SplashDisplayType := sdtSelf;
      end;
    else begin
      TBatterySplash.MonitorConfig :=
        TBatterySplash.TSplashMonitorConfig.Create(TBatterySplash.TSplashMonitorType.smtPrimary);
      TBatterySplash.SplashDisplayType := sdtSelf;
    end;
  end;
end;

{$REGION 'Config'}
function TBatteryModeForm.DefaultConfig: TConfig;
begin
  Result.IconStyle := TIconHelper.DefaultIconStyle;
  Result.IconColorType := TIconHelper.DefaultIconColorType;
  Result.IconBehavior := TIconHelper.DefaultIconBehavior;
  Result.ExplicitMissingBattery := False;
  Result.HotKeyEnable := True;
  Result.FixedLocalBrightness := False;
  Result.ShowMonitorName := False;
  Result.ShowBrightnessPercent := False;
  Result.BrightnessRescanDelayMillisecond := 5000;
  if IsWindowsVistaOrGreater then
    Result.DisplayIndicator := diPrimary
  else
    Result.DisplayIndicator := diNone;
  Result.FeatureMissingScheme := True;
  Result.FeatureOverlay := True;
  Result.FeatureHiddedScheme := False;
  Result.SystemBorder := sbDefault;
  Result.AutoUpdateEnable := True;
  Result.AutoUpdateLastCheck := 0;
  Result.AutoUpdateSkipVersion := TVersion.Empty;
  Result.HotKeyNextScheme := 'Alt+Pause';
  Result.SchedulerEnabled := True;
  Result.LinkType := DefaultUiLabel;
  Result.LinkTypeRdp := DefaultUiLabelRdp;
  Result.Language := '';
  Result.ID := TAutoUpdateScheduler.NewID;
end;

function TBatteryModeForm.LoadConfig: TConfig;
var
  Default: TConfig;
  Registry: TRegistry;

  function ReadBoolDef(const Name: string; const Def: Boolean): Boolean;
  begin
    if Registry.ValueExists(Name) then
      Result := Registry.ReadBool(Name)
    else
      Result := Def;
  end;

  function ReadIntegerDef(const Name: string; const Def: Integer): Integer;
  begin
    if Registry.ValueExists(Name) then
      Result := Registry.ReadInteger(Name)
    else
      Result := Def;
  end;

  function ReadStringDef(const Name: string; const Def: string): string;
  begin
    if Registry.ValueExists(Name) then
      Result := Registry.ReadString(Name)
    else
      Result := Def;
  end;
begin
  Default := DefaultConfig;
  Registry := TRegistry.Create;
  try
    Registry.RootKey := HKEY_CURRENT_USER;
    if not Registry.KeyExists(REG_Key) then Exit(Default);
    if not Registry.OpenKeyReadOnly(REG_Key) then Exit(Default);

    // Read config
    Result.IconStyle := TIconStyle(ReadIntegerDef(REG_IconStyle, Integer(Default.IconStyle)));
    Result.IconColorType := TIconColorType(ReadIntegerDef(REG_IconColorType, Integer(Default.IconColorType)));
    Result.IconBehavior := TIconBehavior(ReadIntegerDef(REG_IconBehavior, Integer(Default.IconBehavior)));
    Result.ExplicitMissingBattery := ReadBoolDef(REG_ExplicitMissingBattery, Default.ExplicitMissingBattery);
    Result.HotKeyEnable := ReadBoolDef(REG_HotKeyEnable, Default.HotKeyEnable);
    Result.SystemBorder := TSystemBorder(ReadIntegerDef(REG_SystemBorder, Integer(Default.SystemBorder)));
    Result.FixedLocalBrightness := ReadBoolDef(REG_FixedLocalBrightness, Default.FixedLocalBrightness);
    Result.ShowMonitorName := ReadBoolDef(REG_ShowMonitorName, Default.ShowMonitorName);
    Result.ShowBrightnessPercent := ReadBoolDef(REG_ShowBrightnessPercent, Default.ShowBrightnessPercent);
    Result.BrightnessRescanDelayMillisecond := Cardinal(ReadIntegerDef(REG_BrightnessRescanDelayMillisecond, Integer(Default.BrightnessRescanDelayMillisecond)));
    Result.DisplayIndicator := TDisplayIndicator(ReadIntegerDef(REG_DisplayIndicator, Integer(Default.DisplayIndicator)));
    Result.FeatureMissingScheme := ReadBoolDef(REG_FeatureMissingScheme, Default.FeatureMissingScheme);
    Result.FeatureOverlay := ReadBoolDef(REG_FeatureOverlay, Default.FeatureOverlay);
    Result.FeatureHiddedScheme := ReadBoolDef(REG_FeatureHiddedScheme, Default.FeatureHiddedScheme);
    Result.AutoUpdateEnable := ReadBoolDef(REG_AutoUpdateEnable, Default.AutoUpdateEnable);
    Result.AutoUpdateLastCheck := StrToDateTimeDef(ReadStringDef(REG_AutoUpdateLastCheck, ''), Default.AutoUpdateLastCheck);
    Result.AutoUpdateSkipVersion := ReadStringDef(REG_AutoUpdateSkipVersion, Default.AutoUpdateSkipVersion);
    Result.HotKeyNextScheme := ReadStringDef(REG_HotKeyNextScheme, Default.HotKeyNextScheme);
    Result.SchedulerEnabled := ReadBoolDef(REG_SchedulerEnabled, Default.SchedulerEnabled);
    Result.LinkType := TUiLabel(ReadIntegerDef(REG_LinkType, Integer(Default.LinkType)));
    Result.LinkTypeRdp := TUiLabel(ReadIntegerDef(REG_LinkTypeRdp, Integer(Default.LinkTypeRdp)));
    Result.Language := ReadStringDef(REG_Language, Default.Language);
    Result.ID := ReadIntegerDef(REG_ID, Default.ID);
    // end read config

    Registry.CloseKey;
  finally
    Registry.Free;
  end;
end;

procedure TBatteryModeForm.SaveConfig(Conf: TConfig);
var
  Registry: TRegistry;
begin
  Registry := TRegistry.Create;
  try
    Registry.RootKey := HKEY_CURRENT_USER;
    if Registry.OpenKey(REG_Key, True) then begin
      // Write config
      Registry.WriteString(REG_Version, TVersionInfo.FileVersion); // Last version
      Registry.WriteInteger(REG_IconStyle, Integer(Conf.IconStyle));
      Registry.WriteInteger(REG_IconColorType, Integer(Conf.IconColorType));
      Registry.WriteInteger(REG_IconBehavior, Integer(Conf.IconBehavior));
      Registry.WriteBool(REG_ExplicitMissingBattery, Conf.ExplicitMissingBattery);
      Registry.WriteBool(REG_HotKeyEnable, Conf.HotKeyEnable);
      Registry.WriteInteger(REG_SystemBorder, Integer(Conf.SystemBorder));
      Registry.WriteBool(REG_FixedLocalBrightness, Conf.FixedLocalBrightness);
      Registry.WriteBool(REG_ShowMonitorName, Conf.ShowMonitorName);
      Registry.WriteBool(REG_ShowBrightnessPercent, Conf.ShowBrightnessPercent);
      Registry.WriteInteger(REG_BrightnessRescanDelayMillisecond, Integer(Conf.BrightnessRescanDelayMillisecond));
      Registry.WriteInteger(REG_DisplayIndicator, Integer(Conf.DisplayIndicator));
      Registry.WriteBool(REG_FeatureMissingScheme, Conf.FeatureMissingScheme);
      Registry.WriteBool(REG_FeatureOverlay, Conf.FeatureOverlay);
      Registry.WriteBool(REG_FeatureHiddedScheme, Conf.FeatureHiddedScheme);
      Registry.WriteBool(REG_AutoUpdateEnable, Conf.AutoUpdateEnable);
      Registry.WriteString(REG_AutoUpdateLastCheck, DateTimeToStr(Conf.AutoUpdateLastCheck));
      Registry.WriteString(REG_AutoUpdateSkipVersion, Conf.AutoUpdateSkipVersion);
      Registry.WriteString(REG_HotKeyNextScheme, Conf.HotKeyNextScheme);
      Registry.WriteBool(REG_SchedulerEnabled, Conf.SchedulerEnabled);
      Registry.WriteInteger(REG_LinkType, Integer(Conf.LinkType));
      Registry.WriteInteger(REG_LinkTypeRdp, Integer(Conf.LinkTypeRdp));
      Registry.WriteString(REG_Language, Conf.Language);
      Registry.WriteInteger(REG_ID, Conf.ID);
      // end write config

      Registry.CloseKey;
    end;
  finally
    Registry.Free;
  end;
end;

procedure TBatteryModeForm.ClearConfig;
var
  Registry: TRegistry;
begin
  Registry := TRegistry.Create;
  try
    Registry.RootKey := HKEY_CURRENT_USER;
    Registry.DeleteKey(string.Join(PathDelim, [REG_Key, REG_Current]));
  finally
    Registry.Free;
  end;
end;

procedure TBatteryModeForm.DeleteConfig;
var
  Registry: TRegistry;
begin  
  Registry := TRegistry.Create;
  try
    Registry.RootKey := HKEY_CURRENT_USER;
    Registry.DeleteKey(REG_Key);
  finally
    Registry.Free;
  end;
end;

procedure TBatteryModeForm.SaveCurrentConfig;
var
  Conf: TConfig;
begin
  Conf.IconStyle := TIconHelper.IconStyle;
  Conf.IconColorType := TIconHelper.IconColorType;
  Conf.IconBehavior := TIconHelper.IconBehavior;
  Conf.ExplicitMissingBattery := TIconHelper.ExplicitMissingBattery;
  Conf.HotKeyEnable := HotKeyHandler.Enabled;
  Conf.SystemBorder := SystemBorder;
  Conf.FixedLocalBrightness := TBatteryMode.BrightnessForAllScheme;
  Conf.ShowMonitorName := BrightnessPanel.ShowMonitorName;
  Conf.ShowBrightnessPercent := BrightnessPanel.ShowBrightnessPercent;
  Conf.BrightnessRescanDelayMillisecond := BrightnessManager.RescanDelayMillisecond;
  Conf.DisplayIndicator := DisplayIndicator;
  Conf.FeatureMissingScheme := psfMissingScheme in TBatteryMode.PowerSchemes.SchemeFeatures;
  Conf.FeatureOverlay := psfOverlay in TBatteryMode.PowerSchemes.SchemeFeatures;
  Conf.FeatureHiddedScheme := psfHiddenScheme in TBatteryMode.PowerSchemes.SchemeFeatures;
  Conf.AutoUpdateEnable := AutoUpdateScheduler.Enable;
  Conf.AutoUpdateLastCheck := AutoUpdateScheduler.LastCheck;
  Conf.AutoUpdateSkipVersion := AutoUpdateScheduler.SkipVersion;
  Conf.HotKeyNextScheme := HotKeyHandler.HotKey[HotKeyNextScheme].ToString;
  Conf.SchedulerEnabled := FScheduler.Enabled;
  Conf.LinkType := FLinkType;
  Conf.LinkTypeRdp := FLinkTypeRdp;
  Conf.Language := Language;
  Conf.ID := AutoUpdateScheduler.ID;

  SaveConfig(Conf);
end;

procedure TBatteryModeForm.PrepareRestart;
begin
  LockerSaveConfig.Lock;
end;
{$ENDREGION}

end.
