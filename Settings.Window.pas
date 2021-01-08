unit Settings.Window;

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.ShellAPI,
  System.Generics.Collections, System.RegularExpressions,
  System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls,
  Vcl.StdCtrls, Vcl.ComCtrls, Vcl.Menus,
  Brightness,
  Core.UI, Core.UI.Controls, Core.Startup,
  Helpers.Reg;

type
  TSettingsWindow = class(TCompatibleForm)
    MainMenu: TMainMenu;
    MainMenuFile: TMenuItem;
    MainMenuExportConfigToFile: TMenuItem;
    MainMenuImportConfigFromFile: TMenuItem;
    MainMenuClose: TMenuItem;
    SettingTabs: TPageControl;
    InterfaceTab: TTabSheet;
    SchemesTab: TTabSheet;
    BrightnessTab: TTabSheet;
    AutoUpdateTab: TTabSheet;
    IconsGroup: TGroupBox;
    IconColorComboBox: TComboBox;
    IconStyleLabel: TLabel;
    IconsGrid: TGridPanel;
    IconStyleComboBox: TComboBox;
    IconColorLabel: TLabel;
    TypicalPowerSavingsMonochromeCheckBox: TCheckBox;
    IconStyleExplicitMissingBatteryCheckBox: TCheckBox;
    IconBehaviorPercentCheckBox: TCheckBox;
    IndicatorGroup: TGroupBox;
    IndicatorNotDisplayRadioButton: TRadioButton;
    IndicatorPrimaryMonitorRadioButton: TRadioButton;
    IndicatorAllMonitorRadioButton: TRadioButton;
    MainWindowGroup: TGroupBox;
    MainWindowGrid: TGridPanel;
    MainWindowLinkTypeLabel: TLabel;
    MainWindowLinkTypeComboBox: TComboBox;
    MainWindowDisableSystemBorderCheckBox: TCheckBox;
    SchemeFeaturesGroup: TGroupBox;
    SchemeFeatureMissingSchemeCheckBox: TCheckBox;
    SchemeFeatureOverlayCheckBox: TCheckBox;
    SchemeFeatureHiddenSchemeCheckBox: TCheckBox;
    BrightnessScrollBox: TScrollBox;
    BrightnessSliderGroup: TGroupBox;
    BrightnessSliderMonitorNameCheckBox: TCheckBox;
    BrightnessSliderPercentCheckBox: TCheckBox;
    BrightnessFixedCheckBox: TCheckBox;
    SchemeHotKeyPanel: TPanel;
    SchemeHotKeyButton: TButton;
    SchemeHotKeyLabel: TLabel;
    AutoUpdateEnabledCheckBox: TCheckBox;
    AutoUpdateCheckButton: TButton;
    BrightnessMonitorGroup: TGroupBox;
    AppCurrentVersionLabel: TLabel;
    IndicatorHelpLabel: TLabel;
    SchemeFeatureMissingSchemePanel: TPanel;
    SchemeFeatureOverlayPanel: TPanel;
    SchemeFeatureHiddenSchemePanel: TPanel;
    SchemeFeatureMissingSchemeHelpLabel: TLabel;
    SchemeFeatureOverlayHelpLabel: TLabel;
    SchemeFeatureHiddenSchemeHelpLabel: TLabel;
    SchemeFeatureMissingSchemeCheckPanel: TPanel;
    SchemeFeatureOverlayCheckPanel: TPanel;
    SchemeFeatureHiddenSchemeCheckPanel: TPanel;
    SchemeHotKeyActionPanel: TPanel;
    SchemeHotKeyHelpLabel: TLabel;
    BrightnessFixedHelpLabel: TLabel;
    BrightnessFixedCheckPanel: TPanel;
    BrightnessSliderMonitorNameCheckPanel: TPanel;
    BrightnessSliderPercentCheckPanel: TPanel;
    BrightnessOptionsGroup: TGroupBox;
    BrightnessRescanDelayHelpLabel: TLabel;
    BrightnessRescanDelayLabel: TLabel;
    BrightnessRescanDelayPanel: TPanel;
    BrightnessRescanDelayEdit: TEdit;
    BrightnessRescanDelayUpDown: TUpDown;
    BrightnessRescanDelayUnitsLabel: TLabel;
    AboutTab: TTabSheet;
    AboutIconPanel: TPanel;
    AppImage: TImage;
    AboutPanel: TPanel;
    AppNameLabel: TLabel;
    AppVersionLabel: TLabel;
    AppAuthorLabel: TLabel;
    AppCopyrightLabel: TLabel;
    AppSiteLink: TStaticText;
    LinksGrid: TGridPanel;
    AppHelpLink: TStaticText;
    AppFeedbackLink: TStaticText;
    AppDonateLink: TStaticText;
    AppSchedulerLink: TStaticText;
    AppChangelog: TStaticText;
    AppLicense: TStaticText;
    BrightnessFixedGroup: TGroupBox;
    SchemeHotKeyGroup: TGroupBox;
    AppSourceCodeLink: TStaticText;
    ExportConfigDialog: TSaveDialog;
    ImportConfigDialog: TOpenDialog;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormAfterMonitorDpiChanged(Sender: TObject; OldDPI, NewDPI: Integer);
    procedure FormShow(Sender: TObject);
    procedure MainMenuExportConfigToFileClick(Sender: TObject);
    procedure MainMenuImportConfigFromFileClick(Sender: TObject);
    procedure MainMenuCloseClick(Sender: TObject);
    procedure IconColorComboBoxChange(Sender: TObject);
    procedure IconStyleComboBoxChange(Sender: TObject);
    procedure TypicalPowerSavingsMonochromeCheckBoxClick(Sender: TObject);
    procedure IconStyleExplicitMissingBatteryCheckBoxClick(Sender: TObject);
    procedure IconBehaviorPercentCheckBoxClick(Sender: TObject);
    procedure IndicatorNotDisplayRadioButtonClick(Sender: TObject);
    procedure IndicatorPrimaryMonitorRadioButtonClick(Sender: TObject);
    procedure IndicatorAllMonitorRadioButtonClick(Sender: TObject);
    procedure MainWindowLinkTypeComboBoxChange(Sender: TObject);
    procedure MainWindowDisableSystemBorderCheckBoxClick(Sender: TObject);
    procedure SchemeFeatureMissingSchemeCheckBoxClick(Sender: TObject);
    procedure SchemeFeatureOverlayCheckBoxClick(Sender: TObject);
    procedure SchemeFeatureHiddenSchemeCheckBoxClick(Sender: TObject);
    procedure BrightnessSliderMonitorNameCheckBoxClick(Sender: TObject);
    procedure BrightnessSliderPercentCheckBoxClick(Sender: TObject);
    procedure BrightnessFixedCheckBoxClick(Sender: TObject);
    procedure BrightnessRescanDelayEditChange(Sender: TObject);
    procedure SchemeHotKeyButtonClick(Sender: TObject);
    procedure AutoUpdateEnabledCheckBoxClick(Sender: TObject);
    procedure AutoUpdateCheckButtonClick(Sender: TObject);
    procedure AppSiteLinkClick(Sender: TObject);
    procedure AppHelpLinkClick(Sender: TObject);
    procedure AppFeedbackLinkClick(Sender: TObject);
    procedure AppDonateLinkClick(Sender: TObject);
    procedure AppSchedulerLinkClick(Sender: TObject);
    procedure AppChangelogClick(Sender: TObject);
    procedure AppLicenseClick(Sender: TObject);
    procedure AppSourceCodeLinkClick(Sender: TObject);
  strict private
    class var FLastWindowHandle: THandle;
  public
    class procedure Open(AllSettings: Boolean);
  strict private
    FAllSettings: Boolean;
    FIsRemoteSession: Boolean;
    FBrightnessMonitorControls: TList<TControl>;
    FLastHintHidePause: Integer;
    procedure LoadIcon;
    procedure Loadlocalization;
    procedure LoadMainWindowLinkType;
    procedure LoadBrightnessMonitors;
    procedure ClearBrightnessMonitors;
    procedure UpdateHotKey;
    procedure FixGrids;
    procedure FixWindowHeight;
    function DropAccel(Text: string): string;
    procedure BrightnessManagerNotify(Sender: TObject;
      const Item: IBrightnessMonitor; Action: TCollectionNotification);
    procedure AutoUpdateSchedulerInCheck(Sender: TObject);
    procedure AutoUpdateSchedulerChecked(Sender: TObject);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure WMWtsSessionChange(var Msg: TMessage); message WM_WTSSESSION_CHANGE;
  public
    constructor Create(AllSettings: Boolean); reintroduce;
    property IsRemoteSession: Boolean read FIsRemoteSession;
  end;

  TBrightnessMonitorSettingsPanel = class(TPanel)
  private
    FMonitor: IBrightnessMonitor;
    FEnableLocker: ILocker;
    FEnablePanel: TPanel;
    FEnableCheckBox: TCheckBox;
    FConfigPanel: TPanel;
    FTrayScrollCheckBox: TCheckBox;
    FBrightnessRefreshOnPowerUpCheckBox: TCheckBox;
    procedure EnableCheckBoxClick(Sender: TObject);
    procedure TrayScrollCheckBoxClick(Sender: TObject);
    procedure BrightnessRefreshOnPowerUpCheckBoxClick(Sender: TObject);
  protected
    procedure MonitorChangeEnable2(Sender: IBrightnessMonitor; Enable: Boolean);
  public
    constructor Create(AOwner: TComponent; const Monitor: IBrightnessMonitor); reintroduce;
    destructor Destroy; override;

    property BrightnessMonitor: IBrightnessMonitor read FMonitor;
  end;

implementation

uses
  Core.Language,
  Helpers.License,
  Brightness.Controls,
  Battery.Mode, Battery.Mode.Window, Battery.Icons, Battery.Splash,
  Power, Power.Shutdown,
  HotKey.Window.Query,
  Tray.Notify.Window,
  Versions.Helpers, Versions.Info;

{$R *.dfm}

{ TSettingsWindow }

class procedure TSettingsWindow.Open(AllSettings: Boolean);
var
  SettingsWindow: TSettingsWindow;
begin
  if FLastWindowHandle = 0 then
  begin
    SettingsWindow := TSettingsWindow.Create(AllSettings);
    SettingsWindow.Show;
  end
  else
  begin
    ShowWindow(FLastWindowHandle, SW_RESTORE);
    SetForegroundWindow(FLastWindowHandle);
  end;
end;

constructor TSettingsWindow.Create(AllSettings: Boolean);
begin
  inherited Create(nil);
  FLastWindowHandle := WindowHandle;
  FBrightnessMonitorControls := TList<TControl>.Create;

  FAllSettings := AllSettings;
  FIsRemoteSession := GetSystemMetrics(SM_REMOTESESSION) <> 0;
end;

procedure TSettingsWindow.FormCreate(Sender: TObject);
const
  VerFmt = '%0:s: %1:s %2:s';
var
  Features, SupportedFeatures: TPowerSchemeFeatures;
begin
  if IsWindows10OrGreater then Color := clWindow;

  AppCurrentVersionLabel.Caption := Format(VerFmt,
        [TLang[912], string(TVersionInfo.FileVersion), TVersionInfo.BinaryTypeAsShortString]);
  AppCurrentVersionLabel.Font.Name := Font.Name;
  AppCurrentVersionLabel.Font.Size := Font.Size;

  IconColorComboBox.Enabled := IsWindowsVistaOrGreater or TBatteryMode.State.Mobile or TBatteryMode.State.BatteryPresent;
  if IsWindowsVistaOrGreater then
  begin
    IconColorComboBox.AddItem(DropAccel(TLang[121]), TObject(ictScheme));       // Показывает схему электропитания
    IconColorComboBox.AddItem(DropAccel(TLang[124]), TObject(ictSchemeInvert)); // Показывает схему электропитания (инвертировано)
  end;
  if TBatteryMode.State.Mobile or TBatteryMode.State.BatteryPresent then
  begin
    IconColorComboBox.AddItem(DropAccel(TLang[122]), TObject(ictLevel));        // Показывает заряд батареи
    IconColorComboBox.AddItem(DropAccel(TLang[125]), TObject(ictLevelInvert));  // Показывает заряд батареи (инвертировано)
  end;
  IconColorComboBox.AddItem(DropAccel(TLang[123]), TObject(ictMonochrome));     // Всегда белый
  IconColorComboBox.ItemIndex := IconColorComboBox.Items.IndexOfObject(TObject(TIconHelper.IconColorType));

  IconStyleComboBox.AddItem(DropAccel(TLang[76]), TObject(isWinXp));      // Windows XP
  IconStyleComboBox.AddItem(DropAccel(TLang[77]), TObject(isWinVista));   // Windows Vista
  IconStyleComboBox.AddItem(DropAccel(TLang[71]), TObject(isWin7));       // Windows 7
  IconStyleComboBox.AddItem(DropAccel(TLang[72]), TObject(isWin8));       // Windows 8
  IconStyleComboBox.AddItem(DropAccel(TLang[74]), TObject(isWin8Light));  // Windows 8 светлый
  IconStyleComboBox.AddItem(DropAccel(TLang[73]), TObject(isWin10));      // Windows 10
  IconStyleComboBox.AddItem(DropAccel(TLang[75]), TObject(isWin10Light)); // Windows 10 светлый
  IconStyleComboBox.ItemIndex := IconStyleComboBox.Items.IndexOfObject(TObject(TIconHelper.IconStyle));

  TypicalPowerSavingsMonochromeCheckBox.AutoSize := True;
  TypicalPowerSavingsMonochromeCheckBox.Checked := TIconHelper.TypicalPowerSavingsMonochrome;
  IconStyleExplicitMissingBatteryCheckBox.AutoSize := True;
  IconStyleExplicitMissingBatteryCheckBox.Checked := TIconHelper.ExplicitMissingBattery;
  IconStyleExplicitMissingBatteryCheckBox.Enabled := TBatteryMode.State.Mobile or TBatteryMode.State.BatteryPresent;
  IconBehaviorPercentCheckBox.AutoSize := True;
  IconBehaviorPercentCheckBox.Checked := TIconHelper.IconBehavior = ibPercent;
  IconBehaviorPercentCheckBox.Enabled := TBatteryMode.State.Mobile or TBatteryMode.State.BatteryPresent;

  IndicatorGroup.AutoSize := True;
  if TBatterySplash.SplashDisplayType = sdtNone then
    IndicatorNotDisplayRadioButton.Checked := True
  else if TBatterySplash.MonitorConfig.MonitorType = TBatterySplash.TSplashMonitorType.smtPrimary then
    IndicatorPrimaryMonitorRadioButton.Checked := True
  else if TBatterySplash.MonitorConfig.MonitorType = TBatterySplash.TSplashMonitorType.smtAll then
    IndicatorAllMonitorRadioButton.Checked := True;

  LoadMainWindowLinkType;

  MainWindowDisableSystemBorderCheckBox.AutoSize := True;
  MainWindowDisableSystemBorderCheckBox.Checked := BatteryModeForm.SystemBorder = sbWithoutBorder;
  MainWindowDisableSystemBorderCheckBox.Visible := (BatteryModeForm.SystemBorder <> sbDefault) or
                                                   (FAllSettings and IsWindowsVistaOrGreater) or
                                                   IsWindows10OrGreater;

  Features := TBatteryMode.PowerSchemes.SchemeFeatures;
  SupportedFeatures := TBatteryMode.PowerSchemes.SupportedSchemeFeatures;

  SchemeFeaturesGroup.AutoSize := True;
  SchemeFeaturesGroup.Visible := (psfMissingScheme in SupportedFeatures) or
                                 (psfOverlay in SupportedFeatures) or
                                 (psfHiddenScheme in SupportedFeatures);
  SchemeFeatureMissingSchemePanel.Visible     := psfMissingScheme in SupportedFeatures;
  SchemeFeatureMissingSchemeCheckBox.AutoSize := True;
  SchemeFeatureMissingSchemeCheckBox.Checked  := psfMissingScheme in Features;
  SchemeFeatureOverlayPanel.Visible           := psfOverlay in SupportedFeatures;
  SchemeFeatureOverlayCheckBox.AutoSize       := True;
  SchemeFeatureOverlayCheckBox.Checked        := psfOverlay in Features;
  SchemeFeatureHiddenSchemePanel.Visible      := psfHiddenScheme in SupportedFeatures;
  SchemeFeatureHiddenSchemeCheckBox.AutoSize  := True;
  SchemeFeatureHiddenSchemeCheckBox.Checked   := psfHiddenScheme in Features;

  SchemeHotKeyGroup.AutoSize := True;
  SchemeHotKeyButton.Padding.Left   := 14;
  SchemeHotKeyButton.Padding.Right  := 14;
  SchemeHotKeyButton.AutoSize := True;
  UpdateHotKey;

  BrightnessSliderGroup.AutoSize  := True;
  BrightnessSliderMonitorNameCheckBox.AutoSize  := True;
  BrightnessSliderMonitorNameCheckBox.Checked   := BatteryModeForm.BrightnessPanel.ShowMonitorName;
  BrightnessSliderPercentCheckBox.AutoSize      := True;
  BrightnessSliderPercentCheckBox.Checked       := BatteryModeForm.BrightnessPanel.ShowBrightnessPercent;

  BrightnessFixedGroup.AutoSize := True;
  BrightnessFixedCheckBox.AutoSize  := True;
  BrightnessFixedCheckBox.Checked   := TBatteryMode.BrightnessForAllScheme;

  BrightnessOptionsGroup.AutoSize := True;
  BrightnessRescanDelayUpDown.Position := BatteryModeForm.BrightnessManager.RescanDelayMillisecond div 1000;

  LoadBrightnessMonitors;
  BatteryModeForm.BrightnessManager.OnNotify2 := BrightnessManagerNotify;

  AutoUpdateEnabledCheckBox.AutoSize  := True;
  AutoUpdateEnabledCheckBox.Checked   := BatteryModeForm.AutoUpdateScheduler.Enable;
  AutoUpdateCheckButton.Padding.SetBounds(14, 5, 14, 5);
  AutoUpdateCheckButton.AutoSize      := True;
  AutoUpdateCheckButton.Enabled       := not BatteryModeForm.AutoUpdateScheduler.IsCheckInProgress;
  BatteryModeForm.AutoUpdateScheduler.OnInCheck := AutoUpdateSchedulerInCheck;
  BatteryModeForm.AutoUpdateScheduler.OnChecked := AutoUpdateSchedulerChecked;

  AppNameLabel.Font.Name := Font.Name;
  AppVersionLabel.Caption := Format(VerFmt,
    [TLang[10], string(TVersionInfo.FileVersion), TVersionInfo.BinaryTypeAsShortString]);
  AppCopyrightLabel.Caption := TVersionInfo.LegalCopyright;
  AppSiteLink.LinkMode := True;
  AppHelpLink.LinkMode := True;
  AppFeedbackLink.LinkMode := True;
  AppDonateLink.LinkMode := True;
  AppSchedulerLink.LinkMode := True;
  AppChangelog.LinkMode := True;
  AppLicense.LinkMode := True;
  AppSourceCodeLink.LinkMode := True;

  LoadIcon;
  Loadlocalization;

  FixGrids;

  BatteryModeForm.LockOpened;

  FLastHintHidePause := Application.HintHidePause;
  Application.HintHidePause := 30000;
end;

procedure TSettingsWindow.FormDestroy(Sender: TObject);
begin
  Application.HintHidePause := FLastHintHidePause;

  FLastWindowHandle := 0;
  ClearBrightnessMonitors;
  FBrightnessMonitorControls.Free;

  BatteryModeForm.UnlockAndClose;

  BatteryModeForm.BrightnessManager.OnNotify2 := nil;

  BatteryModeForm.AutoUpdateScheduler.OnInCheck := nil;
  BatteryModeForm.AutoUpdateScheduler.OnChecked := nil;
end;

procedure TSettingsWindow.FixGrids;
begin
  IconsGroup.Realign;
  IconsGrid.ColumnCollection[0].SizeStyle := ssPercent;
  IconsGrid.ColumnCollection[0].SizeStyle := ssAuto;
  MainWindowGroup.Realign;
  MainWindowGrid.ColumnCollection[0].SizeStyle := ssPercent;
  MainWindowGrid.ColumnCollection[0].SizeStyle := ssAuto;
  LinksGrid.Realign;
end;

procedure TSettingsWindow.FixWindowHeight;
begin
  if Height > Screen.WorkAreaHeight then Height := Screen.WorkAreaHeight;
end;

procedure TSettingsWindow.FormShow(Sender: TObject);
begin
  FixWindowHeight;
end;

procedure TSettingsWindow.FormAfterMonitorDpiChanged(Sender: TObject; OldDPI,
  NewDPI: Integer);
begin
  FixWindowHeight;
  FixGrids;
end;

procedure TSettingsWindow.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TSettingsWindow.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.WndParent := 0;
  Params.ExStyle := Params.ExStyle or WS_EX_APPWINDOW;
end;

procedure TSettingsWindow.WMWtsSessionChange(var Msg: TMessage);
var
  RemoteSession: Boolean;
begin
  RemoteSession := GetSystemMetrics(SM_REMOTESESSION) <> 0;
  if FIsRemoteSession = RemoteSession then Exit;

  FIsRemoteSession := RemoteSession;

  LoadMainWindowLinkType;
end;

procedure TSettingsWindow.LoadMainWindowLinkType;
begin
  MainWindowLinkTypeComboBox.Clear;

  MainWindowLinkTypeComboBox.AddItem(DropAccel(TLang[15]), TObject(uilPower));  // Электропитание
  if not IsRemoteSession then
    MainWindowLinkTypeComboBox.AddItem(DropAccel(TLang[136]), TObject(uilMonitorOff)); // Отключить экран
  if TPowerShutdownAction.Create.IsSupported then
    MainWindowLinkTypeComboBox.AddItem(DropAccel(TLang[137]), TObject(uilShutdown)); // Завершение работы
  if TPowerRebootAction.Create.IsSupported then
    MainWindowLinkTypeComboBox.AddItem(DropAccel(TLang[138]), TObject(uilReboot)); // Перезагрузка
  if TPowerSleepAction.Create.IsSupported then
    MainWindowLinkTypeComboBox.AddItem(DropAccel(TLang[139]), TObject(uilSleep)); // Спящий режим
  if TPowerHibernateAction.Create.IsSupported then
    MainWindowLinkTypeComboBox.AddItem(DropAccel(TLang[140]), TObject(uilHibernate)); // Гибернация
  if TPowerLogOutAction.Create.IsSupported then
    MainWindowLinkTypeComboBox.AddItem(DropAccel(TLang[141]), TObject(uilLogOut)); // Выход
  if TPowerLockAction.Create.IsSupported then
    MainWindowLinkTypeComboBox.AddItem(DropAccel(TLang[142]), TObject(uilLock)); // Блокировать
  if TPowerDiagnosticAction.Create.IsSupported then
    MainWindowLinkTypeComboBox.AddItem(DropAccel(TLang[143]), TObject(uilDiagnostic)); // Особые варианты загрузки
  MainWindowLinkTypeComboBox.AddItem(DropAccel(TLang[144]), TObject(uilPowerMonitor)); // Информация о системе электропитания
  if IsRemoteSession then
    MainWindowLinkTypeComboBox.AddItem(DropAccel(TLang[145]), TObject(uilDisconnect)); // Отключиться

  MainWindowLinkTypeComboBox.ItemIndex := MainWindowLinkTypeComboBox.Items.IndexOfObject(TObject(BatteryModeForm.UiLabel));
end;

procedure TSettingsWindow.LoadBrightnessMonitors;
var
  Monitor: IBrightnessMonitor;
  Panel: TPanel;
  HeightAccumulator: ISizeAccumulator;
begin
  ClearBrightnessMonitors;
  HeightAccumulator := THeightAccumulator.Create(BrightnessMonitorGroup.Padding.Top + BrightnessMonitorGroup.Padding.Bottom);
  BrightnessMonitorGroup.AutoSize := False;
  for Monitor in BatteryModeForm.BrightnessManager do
  begin
    Panel := TBrightnessMonitorSettingsPanel.Create(BrightnessMonitorGroup, Monitor);
    Panel.Align := alTop;
    Panel.AlignWithMargins := True;
    Panel.Margins.SetBounds(7, 6, 7, 4);
    Panel.Parent := BrightnessMonitorGroup;
    Panel.Top := HeightAccumulator.NextControlFront(Panel);

    HeightAccumulator.AddControl(Panel);
    FBrightnessMonitorControls.Add(Panel);
  end;
  BrightnessMonitorGroup.AutoSize := True;
  BrightnessMonitorGroup.Visible := BatteryModeForm.BrightnessManager.Count > 0;

  BrightnessFixedGroup.Visible := BatteryModeForm.BrightnessManager.InternalMonitorCount > 0;
  BrightnessFixedGroup.Top := BrightnessMonitorGroup.Top + BrightnessMonitorGroup.Margins.ExplicitHeight;

  BrightnessTab.TabVisible := BatteryModeForm.BrightnessManager.Count > 0;
end;

procedure TSettingsWindow.ClearBrightnessMonitors;
var
  Control: TControl;
begin
  for Control in FBrightnessMonitorControls do
  begin
    Control.Free;
  end;
  FBrightnessMonitorControls.Clear;
end;

procedure TSettingsWindow.MainMenuCloseClick(Sender: TObject);
begin
  Close;
end;

procedure TSettingsWindow.MainMenuExportConfigToFileClick(Sender: TObject);
begin
  if not ExportConfigDialog.Execute(Handle) then
    Exit;

  BatteryModeForm.SaveCurrentConfig;
  BatteryModeForm.ClearConfig;
  TReg.Export(HKEY_CURRENT_USER, REG_Key, ExportConfigDialog.FileName);
  BatteryModeForm.Scheduler.SaveState;
end;

procedure TSettingsWindow.MainMenuImportConfigFromFileClick(Sender: TObject);
var
  StartUpInfo : TStartUpInfo;
  ProcessInfo : TProcessInformation;
begin
  if not ImportConfigDialog.Execute(Handle) then
    Exit;

  BatteryModeForm.DeleteConfig;
  if not TReg.Import(ImportConfigDialog.FileName) then
  begin
    BatteryModeForm.SaveCurrentConfig;
    Exit;
  end;

  BatteryModeForm.Scheduler.SaveState;

  TMutexLocker.Unlock;
  BatteryModeForm.TrayIcon.Visible := False;

  ZeroMemory(@StartUpInfo, SizeOf(StartUpInfo));
  StartUpInfo.cb := SizeOf(StartUpInfo);

  if not CreateProcess(LPCTSTR(Application.ExeName), nil, nil, nil, True,
    GetPriorityClass(GetCurrentProcess), nil, nil, StartUpInfo, ProcessInfo) then
  begin
    TMutexLocker.Lock;
    BatteryModeForm.TrayIcon.Visible := True;
    Exit;
  end;

  BatteryModeForm.PrepareRestart;
  try
    Application.Terminate;
  finally
    CloseHandle(ProcessInfo.hProcess);
    CloseHandle(ProcessInfo.hThread);

    ExitProcess(0);
  end;
end;

procedure TSettingsWindow.IconColorComboBoxChange(Sender: TObject);
var
  CB: TComboBox;
begin
  CB := Sender as TComboBox;
  TIconHelper.IconColorType := TIconColorType(CB.Items.Objects[CB.ItemIndex]);
end;

procedure TSettingsWindow.IconStyleComboBoxChange(Sender: TObject);
var
  CB: TComboBox;
begin
  CB := Sender as TComboBox;
  TIconHelper.IconStyle := TIconStyle(CB.Items.Objects[CB.ItemIndex]);
end;

procedure TSettingsWindow.TypicalPowerSavingsMonochromeCheckBoxClick(
  Sender: TObject);
begin
  TIconHelper.TypicalPowerSavingsMonochrome := (Sender as TCheckBox).Checked;
end;

procedure TSettingsWindow.IconStyleExplicitMissingBatteryCheckBoxClick(
  Sender: TObject);
begin
  TIconHelper.ExplicitMissingBattery := (Sender as TCheckBox).Checked;
end;

procedure TSettingsWindow.IconBehaviorPercentCheckBoxClick(
  Sender: TObject);
begin
  if (Sender as TCheckBox).Checked then
    TIconHelper.IconBehavior := ibPercent
  else
    TIconHelper.IconBehavior := ibIcon;
end;

procedure TSettingsWindow.IndicatorAllMonitorRadioButtonClick(Sender: TObject);
begin
  if not (Sender as TRadioButton).Checked then Exit;

  TBatterySplash.MonitorConfig :=
    TBatterySplash.TSplashMonitorConfig.Create(TBatterySplash.TSplashMonitorType.smtAll);
  TBatterySplash.SplashDisplayType := sdtSelf;
end;

procedure TSettingsWindow.IndicatorNotDisplayRadioButtonClick(Sender: TObject);
begin
  if not (Sender as TRadioButton).Checked then Exit;

  TBatterySplash.SplashDisplayType := sdtNone;
end;

procedure TSettingsWindow.IndicatorPrimaryMonitorRadioButtonClick(
  Sender: TObject);
begin
  if not (Sender as TRadioButton).Checked then Exit;

  TBatterySplash.MonitorConfig :=
    TBatterySplash.TSplashMonitorConfig.Create(TBatterySplash.TSplashMonitorType.smtPrimary);
  TBatterySplash.SplashDisplayType := sdtSelf;
end;

procedure TSettingsWindow.MainWindowLinkTypeComboBoxChange(Sender: TObject);
var
  CB: TComboBox;
begin
  CB := Sender as TComboBox;
  BatteryModeForm.UiLabel := TUiLabel(CB.Items.Objects[CB.ItemIndex]);
end;

procedure TSettingsWindow.MainWindowDisableSystemBorderCheckBoxClick(
  Sender: TObject);
begin
  if (Sender as TCheckBox).Checked then
    BatteryModeForm.SystemBorder := sbWithoutBorder
  else
    BatteryModeForm.SystemBorder := sbDefault;
end;

procedure TSettingsWindow.SchemeFeatureMissingSchemeCheckBoxClick(
  Sender: TObject);
var
  SchemeFeatures: TPowerSchemeFeatures;
begin
  SchemeFeatures := TBatteryMode.PowerSchemes.SchemeFeatures;
  if (Sender as TCheckBox).Checked then
    Include(SchemeFeatures, psfMissingScheme)
  else
    Exclude(SchemeFeatures, psfMissingScheme);

  TBatteryMode.PowerSchemes.SchemeFeatures := SchemeFeatures;
end;

procedure TSettingsWindow.SchemeFeatureOverlayCheckBoxClick(Sender: TObject);
var
  SchemeFeatures: TPowerSchemeFeatures;
begin
  SchemeFeatures := TBatteryMode.PowerSchemes.SchemeFeatures;
  if (Sender as TCheckBox).Checked then
    Include(SchemeFeatures, psfOverlay)
  else
    Exclude(SchemeFeatures, psfOverlay);

  TBatteryMode.PowerSchemes.SchemeFeatures := SchemeFeatures;
end;

procedure TSettingsWindow.SchemeFeatureHiddenSchemeCheckBoxClick(
  Sender: TObject);
var
  SchemeFeatures: TPowerSchemeFeatures;
begin
  SchemeFeatures := TBatteryMode.PowerSchemes.SchemeFeatures;
  if (Sender as TCheckBox).Checked then
    Include(SchemeFeatures, psfHiddenScheme)
  else
    Exclude(SchemeFeatures, psfHiddenScheme);

  TBatteryMode.PowerSchemes.SchemeFeatures := SchemeFeatures;
end;

procedure TSettingsWindow.BrightnessSliderMonitorNameCheckBoxClick(
  Sender: TObject);
begin
  BatteryModeForm.BrightnessPanel.ShowMonitorName := (Sender as TCheckBox).Checked;
end;

procedure TSettingsWindow.BrightnessSliderPercentCheckBoxClick(Sender: TObject);
begin
  BatteryModeForm.BrightnessPanel.ShowBrightnessPercent := (Sender as TCheckBox).Checked;
end;

procedure TSettingsWindow.BrightnessFixedCheckBoxClick(Sender: TObject);
begin
  TBatteryMode.BrightnessForAllScheme := (Sender as TCheckBox).Checked;
  if Assigned(BatteryModeForm.WMIBrightnessProvider) then
    BatteryModeForm.WMIBrightnessProvider.AdaptiveBrightnessForAllScheme := (Sender as TCheckBox).Checked;
end;

procedure TSettingsWindow.BrightnessManagerNotify(Sender: TObject;
  const Item: IBrightnessMonitor; Action: TCollectionNotification);
begin
  LoadBrightnessMonitors;
end;

procedure TSettingsWindow.BrightnessRescanDelayEditChange(Sender: TObject);
var
  Seconds: Integer;
begin
  if not Integer.TryParse(TEdit(Sender).Text, Seconds) then Exit;

  if Seconds < BrightnessRescanDelayUpDown.Min then
    Seconds := BrightnessRescanDelayUpDown.Min;

  if Seconds > BrightnessRescanDelayUpDown.Max then
    Seconds := BrightnessRescanDelayUpDown.Max;

  BatteryModeForm.BrightnessManager.RescanDelayMillisecond := Cardinal(Seconds) * 1000;
end;

procedure TSettingsWindow.SchemeHotKeyButtonClick(Sender: TObject);
var
  HotKeyQueryWindow: THotKeyQueryWindow;
  HotKeyInfo: THotKeyInfo;
begin
  (Sender as TButton).Enabled := False;
  try
    HotKeyInfo.Create(BatteryModeForm.HotKeyHandler.Enabled, BatteryModeForm.HotKeyHandler.HotKey[HotKeyNextScheme]);
    HotKeyQueryWindow := THotKeyQueryWindow.Create(Self, HotKeyInfo, TLang[90], 0);

    BatteryModeForm.HotKeyHandler.Enabled := False;

    HotKeyInfo := HotKeyQueryWindow.QueryHotKey;

    BatteryModeForm.HotKeyHandler.Enabled := HotKeyInfo.Enabled and not HotKeyInfo.Value.IsEmpty;
    BatteryModeForm.HotKeyHandler.RegisterHotKey(HotKeyNextScheme, HotKeyInfo.Value);
  finally
    (Sender as TButton).Enabled := True;
    UpdateHotKey;
  end;
end;

procedure TSettingsWindow.AutoUpdateEnabledCheckBoxClick(Sender: TObject);
begin
  BatteryModeForm.AutoUpdateScheduler.Enable := (Sender as TCheckBox).Checked;
end;

procedure TSettingsWindow.AppSiteLinkClick(Sender: TObject);
begin
  ShellExecute(Handle, 'open', LPTSTR(TLang[12]), nil, nil, SW_RESTORE);
  Close;
end;

procedure TSettingsWindow.AppSourceCodeLinkClick(Sender: TObject);
begin
  ShellExecute(Handle, 'open', LPTSTR(TLang[226]), nil, nil, SW_RESTORE);
  Close;
end;

procedure TSettingsWindow.AppHelpLinkClick(Sender: TObject);
begin
  ShellExecute(Handle, 'open', LPTSTR(TLang[215]), nil, nil, SW_RESTORE);
  Close;
end;

procedure TSettingsWindow.AppFeedbackLinkClick(Sender: TObject);
begin
  ShellExecute(Handle, 'open', LPTSTR(TLang[217]), nil, nil, SW_RESTORE);
  Close;
end;

procedure TSettingsWindow.AppDonateLinkClick(Sender: TObject);
begin
  ShellExecute(Handle, 'open', LPTSTR(TLang[219]), nil, nil, SW_RESTORE);
  Close;
end;

procedure TSettingsWindow.AppSchedulerLinkClick(Sender: TObject);
begin
  ShellExecute(Handle, 'open', LPTSTR(TLang[221]), nil, nil, SW_RESTORE);
  Close;
end;

procedure TSettingsWindow.AppChangelogClick(Sender: TObject);
begin
  ShellExecute(Handle, 'open', LPTSTR(TLang[223]), nil, nil, SW_RESTORE);
  Close;
end;

procedure TSettingsWindow.AppLicenseClick(Sender: TObject);
begin
  TLicense.Open;
  Close;
end;

procedure TSettingsWindow.AutoUpdateCheckButtonClick(Sender: TObject);
begin
  BatteryModeForm.AutoUpdateScheduler.Check(True);
end;

procedure TSettingsWindow.AutoUpdateSchedulerChecked(Sender: TObject);
begin
  AutoUpdateCheckButton.Enabled := True;
end;

procedure TSettingsWindow.AutoUpdateSchedulerInCheck(Sender: TObject);
begin
  AutoUpdateCheckButton.Enabled := False;
end;

procedure TSettingsWindow.UpdateHotKey;
const
  KeyValFmt = '%0:s: %1:s';
var
  HotKeyText: string;
begin
  if BatteryModeForm.HotKeyHandler.Enabled then
    HotKeyText := BatteryModeForm.HotKeyHandler.HotKey[HotKeyNextScheme].ToString
  else
    HotKeyText := TLang[91]; // Отключено

  SchemeHotKeyLabel.Caption :=  string.Format(KeyValFmt, [TLang[93], HotKeyText]);;
end;

procedure TSettingsWindow.LoadIcon;
var
  hIco: HICON;
begin
  case GetCurrentPPI of
    0..96:    hIco := CopyImage(Application.Icon.Handle, IMAGE_ICON, 32, 32, LR_COPYFROMRESOURCE);
    97..120:  hIco := CopyImage(Application.Icon.Handle, IMAGE_ICON, 40, 40, LR_COPYFROMRESOURCE);
    121..144: hIco := CopyImage(Application.Icon.Handle, IMAGE_ICON, 48, 48, LR_COPYFROMRESOURCE);
    145..192: hIco := CopyImage(Application.Icon.Handle, IMAGE_ICON, 64, 64, LR_COPYFROMRESOURCE);
    else      hIco := CopyImage(Application.Icon.Handle, IMAGE_ICON, 80, 80, LR_COPYFROMRESOURCE);
  end;
  DestroyIcon(AppImage.Picture.Icon.Handle);
  AppImage.Picture.Icon.Handle := hIco;
end;

procedure TSettingsWindow.Loadlocalization;
const
  KeyValFmt = '%0:s: %1:s';
begin
  Caption := DropAccel(TLang[3]); // Дополнительные параметры

  MainMenuFile.Caption                  := TLang[755]; // Файл
  MainMenuClose.Caption                 := TLang[756]; // Закрыть
  MainMenuExportConfigToFile.Caption    := TLang[100]; // Экспортировать настройки в файл
  MainMenuImportConfigFromFile.Caption  := TLang[101]; // Импортировать настройки из файла

  ExportConfigDialog.Filter := Format('%0:s|*.reg|%1:s|*.txt|%2:s|*.*',
    [TLang[110],    // Файлы реестра (*.reg)
     TLang[111],    // Текстовые файлы (*.txt)
     TLang[112]]);  // Все файлы
  ExportConfigDialog.FileName := Format(TLang[105], [TLang[1]]); // Настройки %0:s
  ExportConfigDialog.Title    := Format(TLang[106], [TLang[1]]); // Экспорт файла настроек %0:s

  ImportConfigDialog.Filter := Format('%0:s|*.reg|%1:s|*.txt|%2:s|*.*',
    [TLang[110],    // Файлы реестра (*.reg)
     TLang[111],    // Текстовые файлы (*.txt)
     TLang[112]]);  // Все файлы
  ImportConfigDialog.Title    := Format(TLang[107], [TLang[1]]); // Импорт файла настроек %0:s

  InterfaceTab.Caption := DropAccel(TLang[81]);  // Интерфейс

  IconsGroup.Caption := DropAccel(TLang[83]); // Значки

  IconStyleLabel.Caption     := DropAccel(TLang[70]);  // Стиль значков
  IconColorLabel.Caption     := DropAccel(TLang[120]); // Цвет значков

  TypicalPowerSavingsMonochromeCheckBox.Caption   := DropAccel(TLang[133]); // Белый значок для сбалансированной ...
  TypicalPowerSavingsMonochromeCheckBox.Hint      := DropAccel(TLang[190]); // Использовать белый значок для сбалансированной ...
  TypicalPowerSavingsMonochromeCheckBox.ShowHint  := True;

  IconStyleExplicitMissingBatteryCheckBox.Caption   := DropAccel(TLang[131]); // Перечёркнутый значок отсутствующей батареи
  IconStyleExplicitMissingBatteryCheckBox.Hint      := DropAccel(TLang[181]); // Перечеркивать значок батареи в случае ...
  IconStyleExplicitMissingBatteryCheckBox.ShowHint  := True;

  IconBehaviorPercentCheckBox.Caption   := DropAccel(TLang[132]); // Отображать проценты &заряда в трее
  IconBehaviorPercentCheckBox.Hint      := DropAccel(TLang[182]); // Отображать числовое представление ...
  IconBehaviorPercentCheckBox.ShowHint  := True;

  IndicatorGroup.Caption                      := DropAccel(TLang[20]); // Отображать индикатор схем электропитания
  IndicatorHelpLabel.Caption                  := DropAccel(TLang[180]);// При переключении схем питания ...
  IndicatorNotDisplayRadioButton.Caption      := DropAccel(TLang[21]); // Не отображать
  IndicatorPrimaryMonitorRadioButton.Caption  := DropAccel(TLang[22]); // На основном мониторе
  IndicatorAllMonitorRadioButton.Caption      := DropAccel(TLang[23]); // На всех мониторах

  MainWindowGroup.Caption         := DropAccel(TLang[82]);  // Главное окно
  MainWindowLinkTypeLabel.Caption := DropAccel(TLang[135]); // Ссылка в нижней части окна

  MainWindowDisableSystemBorderCheckBox.Caption   := DropAccel(TLang[130]); // Отключить заголовок окна
  MainWindowDisableSystemBorderCheckBox.Hint      := DropAccel(TLang[183]); // Сделать рамку окна программы ...
  MainWindowDisableSystemBorderCheckBox.ShowHint  := True;

  SchemesTab.Caption                          := DropAccel(TLang[173]); // Схемы электропитания
  SchemeFeaturesGroup.Caption                 := DropAccel(TLang[170]); // Отображать наборы схем электропитания
  SchemeFeatureMissingSchemeHelpLabel.Caption := DropAccel(TLang[184]); // Отображать в главном окне программы "классические" ...
  SchemeFeatureMissingSchemeCheckBox.Caption  := DropAccel(TLang[171]); // Классические схемы электропитания
  SchemeFeatureOverlayHelpLabel.Caption       := DropAccel(TLang[185]); // Отображать в главном окне программы ...
  SchemeFeatureOverlayCheckBox.Caption        := DropAccel(TLang[172]); // Режимы питания Windows 10
  SchemeFeatureHiddenSchemeHelpLabel.Caption  := DropAccel(TLang[186]); // Отображать в главном окне программы "скрытые" ...
  SchemeFeatureHiddenSchemeCheckBox.Caption   := DropAccel(TLang[26]);  // Скрытые схемы электропитания

  SchemeHotKeyGroup.Caption     := DropAccel(TLang[92]);  // Горячие клавиши
  SchemeHotKeyHelpLabel.Caption := DropAccel(TLang[187]); // Позволяет настроить переключение ...
  SchemeHotKeyButton.Caption    := DropAccel(TLang[5]);   // Настроить горячие клавиши

  BrightnessTab.Caption                       := DropAccel(TLang[56]); // Яркость мониторов
  BrightnessSliderGroup.Caption               := DropAccel(TLang[53]); // Регулятор яркости
  BrightnessSliderMonitorNameCheckBox.Caption := DropAccel(TLang[54]); // Показывает названия мониторов
  BrightnessSliderPercentCheckBox.Caption     := DropAccel(TLang[55]); // Показывает яркость в процентах

  BrightnessFixedGroup.Caption      := DropAccel(TLang[7]);   // Фиксированная яркость экрана
  BrightnessFixedHelpLabel.Caption  := DropAccel(TLang[188]); // Предотвращать изменение ярокости экрана ...
  BrightnessFixedCheckBox.Caption   := DropAccel(TLang[7]);   // Фиксированная яркость экрана

  BrightnessMonitorGroup.Caption  := DropAccel(TLang[50]); // Управлять яркостью мониторов

  BrightnessOptionsGroup.Caption := DropAccel(TLang[230]); // Дополнительно
  BrightnessRescanDelayLabel.Caption := DropAccel(TLang[231]); // Задержка перед сканированием мониторов
  BrightnessRescanDelayHelpLabel.Caption := DropAccel(TLang[232]); // Увеличте задержку перед сканированием ...
  BrightnessRescanDelayUnitsLabel.Caption := DropAccel(TLang[233]); // секунд(ы)

  AutoUpdateTab.Caption               := DropAccel(TLang[41]); // Автоматическое обновление
  AutoUpdateEnabledCheckBox.Caption   := DropAccel(TLang[42]); // Автоматическая проверка обновлений
  AutoUpdateEnabledCheckBox.Hint      := DropAccel(TLang[189]); // Автоматически проверять наличие новых версий ...
  AutoUpdateEnabledCheckBox.ShowHint  := True;
  AutoUpdateCheckButton.Caption       := DropAccel(TLang[43]); // Проверить на наличие обновлений

  AboutTab.Caption := DropAccel(TLang[210]); // О программе
  AppNameLabel.Caption := DropAccel(TLang[1]); // Battery Mode
  AppAuthorLabel.Caption := string.Format(KeyValFmt, [TLang[211], TLang[212]]);
  AppSiteLink.Caption       := DropAccel(TLang[213]); // Сайт Battery Mode
  AppHelpLink.Caption       := DropAccel(TLang[214]); // Справка по Battery Mode
  AppFeedbackLink.Caption   := DropAccel(TLang[216]); // Обратная связь
  AppDonateLink.Caption     := DropAccel(TLang[218]); // Помочь в развитии проекта Battery Mode
  AppSchedulerLink.Caption  := DropAccel(TLang[220]); // Справка по планировщику
  AppChangelog.Caption      := DropAccel(TLang[222]); // История изменений
  AppLicense.Caption        := DropAccel(TLang[224]); // Лицензионное соглашение
  AppSourceCodeLink.Caption := DropAccel(TLang[225]); // Исходный код
end;

function TSettingsWindow.DropAccel(Text: string): string;
begin
  Result := TRegEx.Replace(Text, '(\(&[0-9A-Z]\))|&', '');
end;

{ TBrightnessMonitorSettingsPanel }

constructor TBrightnessMonitorSettingsPanel.Create(AOwner: TComponent;
  const Monitor: IBrightnessMonitor);
begin
  inherited Create(AOwner);

  FEnableLocker := TLocker.Create;

  FMonitor := Monitor;
  FMonitor.OnChangeEnable2 := MonitorChangeEnable2;

  BevelOuter := bvNone;
  AutoSize := True;

  FEnablePanel := TPanel.Create(Self);
  FEnablePanel.Align := alTop;
  FEnablePanel.AlignWithMargins := True;
  FEnablePanel.Margins.SetBounds(0, 0, 0, 0);
  FEnablePanel.BevelOuter := bvNone;
  FEnablePanel.Height := 16;
  FEnablePanel.Parent := Self;

  FEnableCheckBox := TCheckBox.Create(FEnablePanel);
  FEnableCheckBox.Align := alLeft;
  FEnableCheckBox.Caption := Monitor.Description;
  FEnableCheckBox.AutoSize := True;
  FEnableCheckBox.Checked := Monitor.Enable;
  FEnableCheckBox.OnClick := EnableCheckBoxClick;
  FEnableCheckBox.Parent := FEnablePanel;

  FConfigPanel := TPanel.Create(Self);
  FConfigPanel.AutoSize := True;
  FConfigPanel.Align := alTop;
  FConfigPanel.AlignWithMargins := True;
  FConfigPanel.Margins.SetBounds(0, 5, 0, 2);
  FConfigPanel.BevelOuter := bvNone;
  FConfigPanel.Parent := Self;
  FConfigPanel.Top := FEnablePanel.Margins.ExplicitHeight;

  FTrayScrollCheckBox := TCheckBox.Create(FConfigPanel);
  FTrayScrollCheckBox.Align := alTop;
  FTrayScrollCheckBox.AlignWithMargins := True;
  FTrayScrollCheckBox.Margins.SetBounds(17, 0, 0, 0);
  FTrayScrollCheckBox.Caption := TLang[57];
  FTrayScrollCheckBox.AutoSize := True;
  FTrayScrollCheckBox.WordWrap := True;
  FTrayScrollCheckBox.Enabled := Monitor.Enable;
  FTrayScrollCheckBox.Checked := bmmmTrayScroll in Monitor.ManagementMethods;
  FTrayScrollCheckBox.OnClick := TrayScrollCheckBoxClick;
  FTrayScrollCheckBox.Parent := FConfigPanel;

  FBrightnessRefreshOnPowerUpCheckBox := TCheckBox.Create(FConfigPanel);
  FBrightnessRefreshOnPowerUpCheckBox.Align := alTop;
  FBrightnessRefreshOnPowerUpCheckBox.AlignWithMargins := True;
  FBrightnessRefreshOnPowerUpCheckBox.Margins.SetBounds(17, 7, 0, 0);
  FBrightnessRefreshOnPowerUpCheckBox.Caption := TLang[58];
  FBrightnessRefreshOnPowerUpCheckBox.AutoSize := True;
  FBrightnessRefreshOnPowerUpCheckBox.WordWrap := True;
  FBrightnessRefreshOnPowerUpCheckBox.Visible := Monitor.MonitorType = bmtExternal;
  FBrightnessRefreshOnPowerUpCheckBox.Enabled := Monitor.Enable;
  FBrightnessRefreshOnPowerUpCheckBox.Checked := Monitor.RequireBrightnessRefreshOnPowerUp;
  FBrightnessRefreshOnPowerUpCheckBox.OnClick := BrightnessRefreshOnPowerUpCheckBoxClick;
  FBrightnessRefreshOnPowerUpCheckBox.Parent := FConfigPanel;
  FBrightnessRefreshOnPowerUpCheckBox.Top := FTrayScrollCheckBox.Margins.ExplicitHeight;
end;

destructor TBrightnessMonitorSettingsPanel.Destroy;
begin
  FMonitor.OnChangeEnable2 := nil;
  FBrightnessRefreshOnPowerUpCheckBox.Free;
  FTrayScrollCheckBox.Free;
  FConfigPanel.Free;
  FEnableCheckBox.Free;
  FEnablePanel.Free;
  inherited;
end;

procedure TBrightnessMonitorSettingsPanel.EnableCheckBoxClick(Sender: TObject);
begin
  if FEnableLocker.IsLocked then Exit;

  FMonitor.Enable := (Sender as TCheckBox).Checked;
end;

procedure TBrightnessMonitorSettingsPanel.TrayScrollCheckBoxClick(
  Sender: TObject);
var
  ManagementMethods: TBrightnessMonitorManagementMethods;
begin
  ManagementMethods := FMonitor.ManagementMethods;
  if (Sender as TCheckBox).Checked then
    Include(ManagementMethods, bmmmTrayScroll)
  else
    Exclude(ManagementMethods, bmmmTrayScroll);

  FMonitor.ManagementMethods := ManagementMethods;

  BatteryModeForm.BrightnessManagerHookHandler.UpdateBindings;
end;

procedure TBrightnessMonitorSettingsPanel.BrightnessRefreshOnPowerUpCheckBoxClick(
  Sender: TObject);
begin
  FMonitor.RequireBrightnessRefreshOnPowerUp := (Sender as TCheckBox).Checked;
end;

procedure TBrightnessMonitorSettingsPanel.MonitorChangeEnable2(
  Sender: IBrightnessMonitor; Enable: Boolean);
begin
  FEnableLocker.Lock;
  try
    FEnableCheckBox.Checked := Enable;
    FTrayScrollCheckBox.Enabled := Enable;
    FBrightnessRefreshOnPowerUpCheckBox.Enabled := Enable;
  finally
    FEnableLocker.Unlock;
  end;
end;

end.
