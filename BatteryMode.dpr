program BatteryMode;

{$WEAKLINKRTTI ON}

{$R *.res}

{$R 'BrazilianPortugueseAutorunMessage.res' 'Localization\BrazilianPortuguese\BrazilianPortugueseAutorunMessage.rc'}
{$R 'BrazilianPortugueseAutoUpdate.res' 'Localization\BrazilianPortuguese\BrazilianPortugueseAutoUpdate.rc'}
{$R 'BrazilianPortugueseBatteryModeLanguage.res' 'Localization\BrazilianPortuguese\BrazilianPortugueseBatteryModeLanguage.rc'}
{$R 'BrazilianPortugueseBatteryStatusHint.res' 'Localization\BrazilianPortuguese\BrazilianPortugueseBatteryStatusHint.rc'}
{$R 'BrazilianPortugueseHotKey.res' 'Localization\BrazilianPortuguese\BrazilianPortugueseHotKey.rc'}
{$R 'BrazilianPortuguesePowerInformation.res' 'Localization\BrazilianPortuguese\BrazilianPortuguesePowerInformation.rc'}
{$R 'BrazilianPortugueseScheduling.res' 'Localization\BrazilianPortuguese\BrazilianPortugueseScheduling.rc'}
{$R 'EnglishAutorunMessage.res' 'Localization\English\EnglishAutorunMessage.rc'}
{$R 'EnglishAutoUpdate.res' 'Localization\English\EnglishAutoUpdate.rc'}
{$R 'EnglishBatteryModeLanguage.res' 'Localization\English\EnglishBatteryModeLanguage.rc'}
{$R 'EnglishBatteryStatusHint.res' 'Localization\English\EnglishBatteryStatusHint.rc'}
{$R 'EnglishHotKey.res' 'Localization\English\EnglishHotKey.rc'}
{$R 'EnglishPowerInformation.res' 'Localization\English\EnglishPowerInformation.rc'}
{$R 'EnglishScheduling.res' 'Localization\English\EnglishScheduling.rc'}
{$R 'FrenchAutorunMessage.res' 'Localization\French\FrenchAutorunMessage.rc'}
{$R 'FrenchAutoUpdate.res' 'Localization\French\FrenchAutoUpdate.rc'}
{$R 'FrenchBatteryModeLanguage.res' 'Localization\French\FrenchBatteryModeLanguage.rc'}
{$R 'FrenchBatteryStatusHint.res' 'Localization\French\FrenchBatteryStatusHint.rc'}
{$R 'FrenchHotKey.res' 'Localization\French\FrenchHotKey.rc'}
{$R 'FrenchPowerInformation.res' 'Localization\French\FrenchPowerInformation.rc'}
{$R 'FrenchScheduling.res' 'Localization\French\FrenchScheduling.rc'}
{$R 'HungarianAutorunMessage.res' 'Localization\Hungarian\HungarianAutorunMessage.rc'}
{$R 'HungarianAutoUpdate.res' 'Localization\Hungarian\HungarianAutoUpdate.rc'}
{$R 'HungarianBatteryModeLanguage.res' 'Localization\Hungarian\HungarianBatteryModeLanguage.rc'}
{$R 'HungarianBatteryStatusHint.res' 'Localization\Hungarian\HungarianBatteryStatusHint.rc'}
{$R 'HungarianHotKey.res' 'Localization\Hungarian\HungarianHotKey.rc'}
{$R 'HungarianPowerInformation.res' 'Localization\Hungarian\HungarianPowerInformation.rc'}
{$R 'HungarianScheduling.res' 'Localization\Hungarian\HungarianScheduling.rc'}
{$R 'ItalianAutorunMessage.res' 'Localization\Italian\ItalianAutorunMessage.rc'}
{$R 'ItalianAutoUpdate.res' 'Localization\Italian\ItalianAutoUpdate.rc'}
{$R 'ItalianBatteryModeLanguage.res' 'Localization\Italian\ItalianBatteryModeLanguage.rc'}
{$R 'ItalianBatteryStatusHint.res' 'Localization\Italian\ItalianBatteryStatusHint.rc'}
{$R 'ItalianHotKey.res' 'Localization\Italian\ItalianHotKey.rc'}
{$R 'ItalianPowerInformation.res' 'Localization\Italian\ItalianPowerInformation.rc'}
{$R 'ItalianScheduling.res' 'Localization\Italian\ItalianScheduling.rc'}
{$R 'KoreanAutorunMessage.res' 'Localization\Korean\KoreanAutorunMessage.rc'}
{$R 'KoreanAutoUpdate.res' 'Localization\Korean\KoreanAutoUpdate.rc'}
{$R 'KoreanBatteryModeLanguage.res' 'Localization\Korean\KoreanBatteryModeLanguage.rc'}
{$R 'KoreanBatteryStatusHint.res' 'Localization\Korean\KoreanBatteryStatusHint.rc'}
{$R 'KoreanHotKey.res' 'Localization\Korean\KoreanHotKey.rc'}
{$R 'KoreanPowerInformation.res' 'Localization\Korean\KoreanPowerInformation.rc'}
{$R 'KoreanScheduling.res' 'Localization\Korean\KoreanScheduling.rc'}
{$R 'PolishAutorunMessage.res' 'Localization\Polish\PolishAutorunMessage.rc'}
{$R 'PolishAutoUpdate.res' 'Localization\Polish\PolishAutoUpdate.rc'}
{$R 'PolishBatteryModeLanguage.res' 'Localization\Polish\PolishBatteryModeLanguage.rc'}
{$R 'PolishBatteryStatusHint.res' 'Localization\Polish\PolishBatteryStatusHint.rc'}
{$R 'PolishHotKey.res' 'Localization\Polish\PolishHotKey.rc'}
{$R 'PolishPowerInformation.res' 'Localization\Polish\PolishPowerInformation.rc'}
{$R 'PolishScheduling.res' 'Localization\Polish\PolishScheduling.rc'}
{$R 'RussianAutorunMessage.res' 'Localization\Russian\RussianAutorunMessage.rc'}
{$R 'RussianAutoUpdate.res' 'Localization\Russian\RussianAutoUpdate.rc'}
{$R 'RussianBatteryModeLanguage.res' 'Localization\Russian\RussianBatteryModeLanguage.rc'}
{$R 'RussianBatteryStatusHint.res' 'Localization\Russian\RussianBatteryStatusHint.rc'}
{$R 'RussianHotKey.res' 'Localization\Russian\RussianHotKey.rc'}
{$R 'RussianPowerInformation.res' 'Localization\Russian\RussianPowerInformation.rc'}
{$R 'RussianScheduling.res' 'Localization\Russian\RussianScheduling.rc'}
{$R 'SpanishAutorunMessage.res' 'Localization\Spanish\SpanishAutorunMessage.rc'}
{$R 'SpanishAutoUpdate.res' 'Localization\Spanish\SpanishAutoUpdate.rc'}
{$R 'SpanishBatteryModeLanguage.res' 'Localization\Spanish\SpanishBatteryModeLanguage.rc'}
{$R 'SpanishBatteryStatusHint.res' 'Localization\Spanish\SpanishBatteryStatusHint.rc'}
{$R 'SpanishHotKey.res' 'Localization\Spanish\SpanishHotKey.rc'}
{$R 'SpanishPowerInformation.res' 'Localization\Spanish\SpanishPowerInformation.rc'}
{$R 'SpanishScheduling.res' 'Localization\Spanish\SpanishScheduling.rc'}
{$R 'UkrainianAutorunMessage.res' 'Localization\Ukrainian\UkrainianAutorunMessage.rc'}
{$R 'UkrainianAutoUpdate.res' 'Localization\Ukrainian\UkrainianAutoUpdate.rc'}
{$R 'UkrainianBatteryModeLanguage.res' 'Localization\Ukrainian\UkrainianBatteryModeLanguage.rc'}
{$R 'UkrainianBatteryStatusHint.res' 'Localization\Ukrainian\UkrainianBatteryStatusHint.rc'}
{$R 'UkrainianHotKey.res' 'Localization\Ukrainian\UkrainianHotKey.rc'}
{$R 'UkrainianPowerInformation.res' 'Localization\Ukrainian\UkrainianPowerInformation.rc'}
{$R 'UkrainianScheduling.res' 'Localization\Ukrainian\UkrainianScheduling.rc'}
{$R 'JapaneseAutorunMessage.res' 'Localization\Japanese\JapaneseAutorunMessage.rc'}
{$R 'JapaneseAutoUpdate.res' 'Localization\Japanese\JapaneseAutoUpdate.rc'}
{$R 'JapaneseBatteryModeLanguage.res' 'Localization\Japanese\JapaneseBatteryModeLanguage.rc'}
{$R 'JapaneseBatteryStatusHint.res' 'Localization\Japanese\JapaneseBatteryStatusHint.rc'}
{$R 'JapaneseHotKey.res' 'Localization\Japanese\JapaneseHotKey.rc'}
{$R 'JapanesePowerInformation.res' 'Localization\Japanese\JapanesePowerInformation.rc'}
{$R 'JapaneseScheduling.res' 'Localization\Japanese\JapaneseScheduling.rc'}
{$R *.dres}

uses
  Winapi.Windows,
  Winapi.Messages,
  System.Win.Registry,
  Vcl.Forms,
  Api.Pipe.Client in 'Api\Api.Pipe.Client.pas',
  Api.Pipe.Command in 'Api\Api.Pipe.Command.pas',
  Api.Pipe.Server in 'Api\Api.Pipe.Server.pas',
  Api.Pipe.Server.Command in 'Api\Api.Pipe.Server.Command.pas',
  Autorun in 'Autorun\Autorun.pas',
  Autorun.Providers.TaskScheduler2 in 'Autorun\Autorun.Providers.TaskScheduler2.pas',
  Autorun.Providers.Registry in 'Autorun\Autorun.Providers.Registry.pas',
  Autorun.Manager in 'Autorun\Autorun.Manager.pas',
  AutoUpdate in 'AutoUpdate\AutoUpdate.pas',
  AutoUpdate.Params in 'AutoUpdate\AutoUpdate.Params.pas',
  AutoUpdate.Scheduler in 'AutoUpdate\AutoUpdate.Scheduler.pas',
  AutoUpdate.VersionDefinition in 'AutoUpdate\AutoUpdate.VersionDefinition.pas',
  AutoUpdate.Window.NotFound in 'AutoUpdate\AutoUpdate.Window.NotFound.pas' {NotFoundWindow},
  AutoUpdate.Window.Notify in 'AutoUpdate\AutoUpdate.Window.Notify.pas',
  AutoUpdate.Window.Update in 'AutoUpdate\AutoUpdate.Window.Update.pas' {AutoUpdateWnd},
  Brightness in 'Brightness\Brightness.pas',
  Brightness.Api in 'Brightness\Brightness.Api.pas',
  Brightness.Controls in 'Brightness\Brightness.Controls.pas',
  Brightness.Manager.HookHandler in 'Brightness\Brightness.Manager.HookHandler.pas',
  Brightness.Manager in 'Brightness\Brightness.Manager.pas',
  Brightness.Providers.LCD in 'Brightness\Brightness.Providers.LCD.pas',
  Brightness.Providers.Physical in 'Brightness\Brightness.Providers.Physical.pas',
  Brightness.Providers.WMI in 'Brightness\Brightness.Providers.WMI.pas',
  HotKey in 'HotKey\HotKey.pas',
  HotKey.Handler in 'HotKey\HotKey.Handler.pas',
  HotKey.Window.Query in 'HotKey\HotKey.Window.Query.pas' {HotKeyQueryWindow},
  GdiPlus.HSB.Helpers in 'Libs\GdiPlus.HSB.Helpers.pas',
  GdiPlus in 'Libs\GdiPlus.pas',
  GdiPlusHelpers in 'Libs\GdiPlusHelpers.pas',
  JwaWbemCli in 'Libs\JwaWbemCli.pas',
  Pipes in 'Libs\Pipes.pas',
  TaskSchd in 'Libs\TaskSchd.pas',
  WinHttp_TLB in 'Libs\WinHttp_TLB.pas',
  Power.Display in 'Power\Power.Display.pas',
  Power.Shutdown in 'Power\Power.Shutdown.pas',
  Power in 'Power\Power.pas',
  Power.Schemes.Providers.Default in 'Power\Power.Schemes.Providers.Default.pas',
  Power.Schemes.Providers.Legacy in 'Power\Power.Schemes.Providers.Legacy.pas',
  Power.System in 'Power\Power.System.pas',
  Power.WinApi.Advapi32 in 'Power\Power.WinApi.Advapi32.pas',
  Power.WinApi.Kernel32 in 'Power\Power.WinApi.Kernel32.pas',
  Power.WinApi.PowrProf in 'Power\Power.WinApi.PowrProf.pas',
  Power.WinApi.PowrProf.Legacy in 'Power\Power.WinApi.PowrProf.Legacy.pas',
  Power.WinApi.Reason in 'Power\Power.WinApi.Reason.pas',
  Power.WinApi.SetupApi in 'Power\Power.WinApi.SetupApi.pas',
  Scheduling in 'Scheduler\Scheduling.pas',
  Scheduling.Actions in 'Scheduler\Scheduling.Actions.pas',
  Scheduling.Triggers in 'Scheduler\Scheduling.Triggers.pas',
  Scheduling.Conditions in 'Scheduler\Scheduling.Conditions.pas',
  Scheduling.Configurator in 'Scheduler\Scheduling.Configurator.pas',
  Scheduling.Scheduler in 'Scheduler\Scheduling.Scheduler.pas',
  Scheduling.StateConfigurator in 'Scheduler\Scheduling.StateConfigurator.pas',
  Scheduling.UI.Actions in 'Scheduler\Scheduling.UI.Actions.pas',
  Scheduling.UI.Conditions in 'Scheduler\Scheduling.UI.Conditions.pas',
  Scheduling.UI.Editor in 'Scheduler\Scheduling.UI.Editor.pas' {RuleEditorWindow},
  Scheduling.UI.Scheduler in 'Scheduler\Scheduling.UI.Scheduler.pas' {SchedulingWindow},
  Scheduling.UI.Triggers in 'Scheduler\Scheduling.UI.Triggers.pas',
  Battery.Mode in 'Battery.Mode.pas',
  Battery.Mode.Window in 'Battery.Mode.Window.pas' {BatteryModeForm},
  Battery.Controls in 'Battery.Controls.pas',
  Battery.Icons in 'Battery.Icons.pas',
  Battery.Splash in 'Battery.Splash.pas',
  Core.Language in 'Core.Language.pas',
  Core.Language.Controls in 'Core.Language.Controls.pas',
  Core.Startup in 'Core.Startup.pas',
  Core.Startup.Tasks in 'Core.Startup.Tasks.pas',
  Core.UI in 'Core.UI.pas',
  Core.UI.Controls in 'Core.UI.Controls.pas',
  Core.UI.Notifications in 'Core.UI.Notifications.pas',
  Helpers.Images.Generator in 'Helpers.Images.Generator.pas',
  Helpers.License in 'Helpers.License.pas',
  Helpers.Privileges in 'Helpers.Privileges.pas',
  Helpers.Reg in 'Helpers.Reg.pas',
  Helpers.Services in 'Helpers.Services.pas',
  Helpers.Wts in 'Helpers.Wts.pas',
  Media.Player.Helpers in 'Media.Player.Helpers.pas',
  Media.Player in 'Media.Player.pas',
  MemoryDirector in 'MemoryDirector.pas',
  Mouse.Hook in 'Mouse.Hook.pas',
  Mouse.WheelRouting in 'Mouse.WheelRouting.pas',
  PowerMonitor.Window in 'PowerMonitor.Window.pas' {PowerMonitorWindow},
  ScreenLiteUnit in 'ScreenLiteUnit.pas',
  Settings.Window in 'Settings.Window.pas' {BatteryModeSettingsWindow},
  SplashUnit in 'SplashUnit.pas',
  Tray.Helpers in 'Tray.Helpers.pas',
  Tray.Icon in 'Tray.Icon.pas',
  Tray.Icon.Notifications in 'Tray.Icon.Notifications.pas',
  Tray.Notify.Controls in 'Tray.Notify.Controls.pas',
  Tray.Notify.Window in 'Tray.Notify.Window.pas',
  Versions in 'Versions.pas',
  Versions.Helpers in 'Versions.Helpers.pas',
  Versions.Info in 'Versions.Info.pas';

{$SETPEFlAGS IMAGE_FILE_DEBUG_STRIPPED or IMAGE_FILE_LINE_NUMS_STRIPPED or IMAGE_FILE_LOCAL_SYMS_STRIPPED or IMAGE_FILE_RELOCS_STRIPPED}

const
  MSGFLT_ADD = 1;

var
  Wnd: HWND;
  ExitRequired: Boolean;
  ExitCode: UINT;
  Registry: TRegistry;

begin
  TLang.Fallback.Add(MAKELANGID(LANG_SPANISH, SUBLANG_SPANISH_MODERN),  MAKELANGID(LANG_SPANISH, SUBLANG_SPANISH));
  TLang.Fallback.Add(MAKELANGID(LANG_SPANISH, SUBLANG_SPANISH_MEXICAN), MAKELANGID(LANG_SPANISH, SUBLANG_SPANISH));
  TLang.Fallback.Add(MAKELANGID(LANG_UKRAINIAN, SUBLANG_DEFAULT),       MAKELANGID(LANG_RUSSIAN, SUBLANG_DEFAULT));

  Registry := TRegistry.Create;
  try
    try
      Registry.RootKey := HKEY_CURRENT_USER;
      if Registry.KeyExists(REG_Key) then
        if Registry.OpenKeyReadOnly(REG_Key) then
        try
          if Registry.ValueExists(REG_LanguageId) then
            TLang.LanguageId := Registry.ReadInteger(REG_LanguageId)
          else if Registry.ValueExists(REG_Language) then
            TLang.LanguageId := TLang.LocaleNameToLCID(Registry.ReadString(REG_Language));
        finally
          Registry.CloseKey;
        end;
    finally
      Registry.Free;
    end;

    TLang.GetStringRes(HInstance, 0, TLang.EffectiveLanguageId); 
  except
    TLang.LanguageId := 0;
  end;

  //TLang.LanguageId := MAKELANGID(LANG_ENGLISH, SUBLANG_ENGLISH_US);       // 1033 (0x0409)
  //TLang.LanguageId := MAKELANGID(LANG_UKRAINIAN, SUBLANG_DEFAULT);        // 1058 (0x0422)
  //TLang.LanguageId := MAKELANGID(LANG_FRENCH, SUBLANG_DEFAULT);           // 1036 (0x040C)
  //TLang.LanguageId := MAKELANGID(LANG_HUNGARIAN, SUBLANG_DEFAULT);        // 1038 (0x040E)
  //TLang.LanguageId := MAKELANGID(LANG_ITALIAN, SUBLANG_ITALIAN);          // 1040 (0x0410)
  //TLang.LanguageId := MAKELANGID(LANG_KOREAN, SUBLANG_DEFAULT);           // 1042 (0x0412)
  //TLang.LanguageId := MAKELANGID(LANG_POLISH, SUBLANG_POLISH_POLAND);     // 1045 (0x0415)
  //TLang.LanguageId := MAKELANGID(LANG_PORTUGUESE, SUBLANG_DEFAULT);       // 1046 (0x0416)
  //TLang.LanguageId := MAKELANGID(LANG_SPANISH, SUBLANG_SPANISH);          // 1034 (0x040A)
  //TLang.LanguageId := MAKELANGID(LANG_SPANISH, SUBLANG_SPANISH_MODERN);   // 3082 (0x0C0A)
  //TLang.LanguageId := MAKELANGID(LANG_SPANISH, SUBLANG_SPANISH_MEXICAN);  // 2058 (0x080A)

  TMemoryDirector.SetWorkingSetSize(Round(2.5*1024*1024), 5*1024*1024);
  TMemoryDirector.OuotaLimitMinEnable := True;

  AutorunManager.AddProvider(TRegistryProvider.Create, True, True);
  AutorunManager.AddProvider(TTaskScheduler2Provider.Create, False, False);

  ExitRequired := False;
  ExitCode := TStartupTasks.PerformFromCmdInput(ExitRequired);
  if ExitRequired then ExitProcess(ExitCode);

  // Проверка запущеной копии программы
  TMutexLocker.Init('BatteryModMutex');
  TMutexLocker.Lock;
  if TMutexLocker.IsExist then
  begin
    Wnd := FindWindow('TBatteryModeForm', nil);
    if Wnd <> 0 then begin
      ShowWindowAsync(Wnd, SW_SHOW);
      SetForegroundWindow(Wnd);
    end;
    TMutexLocker.Unlock;
    ExitProcess(TStartupTasks.ERROR_Mutex);
  end;

  Application.Initialize;
  Application.ShowMainForm := False;
  Application.Title := TLang[1];
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TBatteryModeForm, BatteryModeForm);
  Application.Run;

  TMutexLocker.Unlock;
end.
