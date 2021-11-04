unit PowerMonitor.Window;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes, System.SyncObjs,
  System.Generics.Collections, System.Generics.Defaults,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.Mask,
  Vcl.ComCtrls, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Menus,
  Core.Language,
  Core.UI, Core.UI.Controls,
  Power.System, Power.WinApi.Kernel32,
  Versions.Helpers;

type
  TPowerInfoKey = (
    ikCaption,

    ikName,
    ikManufacture,
    ikManufactureDate,
    ikSerialNumber,
    ikDesignedCapacity,
    ikType,
    ikCycleCount,
    ikWearLevel,
    ikPowerState,
    ikFullChargedCapacity,
    ikCapacity,
    ikVoltage,
    ikRate,
    ikDefaultAlert1,
    ikDefaultAlert2,
    ikTemperature,

    ikPowerSource,
    ikFullLifetime,
    ikBatteryStatus,
    ikLifetime);

  TPowerInfo = TDictionary<TPowerInfoKey, string>;

  TPowerMonitorWindow = class(TCompatibleForm)
    TabControl: TTabControl;
    GroupBoxBattery: TGroupBox;
    LabelName: TLabeledEdit;
    LabelManufacture: TLabeledEdit;
    LabelManufactureDate: TLabeledEdit;
    LabelSerialNumber: TLabeledEdit;
    LabelDesignedCapacity: TLabeledEdit;
    LabelType: TLabeledEdit;
    LabelCycleCount: TLabeledEdit;
    LabelWearLevel: TLabeledEdit;
    LabelPowerState: TLabeledEdit;
    LabelFullChargedCapacity: TLabeledEdit;
    LabelCapacity: TLabeledEdit;
    LabelVoltage: TLabeledEdit;
    LabelRate: TLabeledEdit;
    LabelDefaultAlert1: TLabeledEdit;
    LabelDefaultAlert2: TLabeledEdit;
    LabelTemperature: TLabeledEdit;
    GroupBoxSystem: TGroupBox;
    LabelPowerSource: TLabeledEdit;
    LabelFullLifetime: TLabeledEdit;
    LabelBatteryStatus: TLabeledEdit;
    LabelLifetime: TLabeledEdit;
    TimerAutoupdate: TTimer;
    MainMenu: TMainMenu;
    MainMenuFile: TMenuItem;
    MainMenuSave: TMenuItem;
    MainMenuClose: TMenuItem;
    MainMenuSaveAs: TMenuItem;
    MainMenuView: TMenuItem;
    MainMenuAlwaysOnTop: TMenuItem;
    procedure TabControlChange(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormAfterMonitorDpiChanged(Sender: TObject; OldDPI,
      NewDPI: Integer);
    procedure FormBeforeMonitorDpiChanged(Sender: TObject; OldDPI,
      NewDPI: Integer);
    procedure TimerAutoupdateTimer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure MainMenuCloseClick(Sender: TObject);
    procedure MainMenuSaveClick(Sender: TObject);
    procedure MainMenuSaveAsClick(Sender: TObject);
    procedure MainMenuAlwaysOnTopClick(Sender: TObject);
  private
    LockerInfo: ILocker;

    FBatterys: TBatteryList;
    FSystemPowerStatus: TSystemPowerStatus;
    FLogFile: string;
    procedure LoadBatteryInfo(Info: TPowerInfo);
    procedure LoadSystemInfo(Info: TPowerInfo);
    procedure Loadlocalization;

    constructor Create; reintroduce;

    function GetBatteryInfo(Battery: TBattery): TPowerInfo;
    function GetSystemInfo(Status: TSystemPowerStatus): TPowerInfo;

    procedure PowerSystemInformation(Sender: TObject;
      Batterys: TBatteryList; SystemPowerStatus: TSystemPowerStatus);

    function SaveLogAs: string;
    function SaveLog(FileName: string; Batterys: TBatteryList;
      Status: TSystemPowerStatus): Boolean;
    procedure SetLogFile(const Value: string);
    property LogFile: string read FLogFile write SetLogFile;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure UpdateInfo(Batterys: TBatteryList; Status: TSystemPowerStatus);
  strict private
    class var FLastWindowHandle: THandle;
  public
    class var StayOnTop: Boolean;
    class procedure Open;
  end;

implementation

{$R *.dfm}

class procedure TPowerMonitorWindow.Open;
var
  PowerMonitorWindow: TPowerMonitorWindow;
begin
  if FLastWindowHandle = 0 then
  begin
    PowerMonitorWindow := TPowerMonitorWindow.Create;
    PowerMonitorWindow.Show;
  end
  else
  begin
    ShowWindow(FLastWindowHandle, SW_RESTORE);
    SetForegroundWindow(FLastWindowHandle);
  end;
end;

function ComputerName: string;
var
  Size: DWORD;
begin
  Size := MAX_PATH;
  SetLength(Result, Size);
  if GetComputerName(LPTSTR(Result), Size) then
    SetLength(Result, Size)
  else
    Result := '';
end;

procedure TrimWorkingSetSize;
var
  MainHandle: THandle;
begin
  MainHandle := OpenProcess(PROCESS_ALL_ACCESS, False, GetCurrentProcessID);
  SetProcessWorkingSetSize(MainHandle, SIZE_T(-1), SIZE_T(-1));
  CloseHandle(MainHandle);
end;


{ TPowerMonitorForm }

constructor TPowerMonitorWindow.Create;
begin
  inherited Create(nil);
  LockerInfo := TLocker.Create;

  FLastWindowHandle := WindowHandle;

  TPowerSystem.GetInformation(FBatterys, FSystemPowerStatus);
end;

procedure TPowerMonitorWindow.FormCreate(Sender: TObject);
begin
  if StayOnTop then
  begin
    MainMenuAlwaysOnTop.Checked := True;
    FormStyle := fsStayOnTop;
  end;

  Loadlocalization;

  UpdateInfo(FBatterys, FSystemPowerStatus);
  TabControl.AutoSize := True;
  LogFile := '';

  TimerAutoupdate.Enabled := True;

  if IsWindows10OrGreater then Color := clWindow;
end;

procedure TPowerMonitorWindow.FormDestroy(Sender: TObject);
begin
  FLastWindowHandle := 0;
  TimerAutoupdate.Enabled := False;
end;

procedure TPowerMonitorWindow.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.WndParent := 0;
  Params.ExStyle := Params.ExStyle or WS_EX_APPWINDOW;
end;

procedure TPowerMonitorWindow.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TPowerMonitorWindow.FormAfterMonitorDpiChanged(Sender: TObject; OldDPI,
  NewDPI: Integer);
begin
  TabControl.AutoSize := True;
  AutoSize := True;
end;

procedure TPowerMonitorWindow.FormBeforeMonitorDpiChanged(Sender: TObject; OldDPI,
  NewDPI: Integer);
begin
  AutoSize := False;
  TabControl.AutoSize := False;
end;

procedure TPowerMonitorWindow.SetLogFile(const Value: string);
var
  CaptionProp: string;
begin
  FLogFile := Value;
  if FLogFile = '' then
    CaptionProp := '%0:s'
  else
    CaptionProp := '%0:s - %1:s';

  Caption := Format(CaptionProp, [TLang[704], ExtractFileName(FLogFile)]); // Система электропитания
end;

function TPowerMonitorWindow.GetBatteryInfo(Battery: TBattery): TPowerInfo;
const
  TypeTechChemProp = '%0:s %1:s';
  TypeTechProp = '%0:s';
  WearLevelProp = '%0:s%%';
  CapacityProp = '%0:u mWh';
  CapacityFullProp = '%0:u mWh (%1:u mAh)';
  CapacityRelativeProp = '%0:u';
  CapacityCurrentProp = '%0:u mWh, %2:d%%';
  CapacityCurrentFullProp = '%0:u mWh (%1:u mAh), %2:d%%';
  CapacityCurrentRelativeProp = '%0:u, %2:d%%';
  CapacityCurrentWitoutPercentProp = '%0:u mWh';
  CapacityCurrentFullWitoutPercentProp = '%0:u mWh (%1:u mAh)';
  CapacityCurrentRelativeWitoutPercentProp = '%0:u';
  VoltageProp = '%0:.3n V';
  RateProp = '%0:d mW';
  RateFullProp = '%0:d mW (%1:d mA)';
  RateRelativeProp = '%0:d';
  AlertProp = '%0:d mWh';
  AlertFullProp = '%0:d mWh (%1:d mAh)';
  AlertRelativeProp = '%0:d';
  TemperatureProp = '%0:d °C (%1:d °F)';

  function DefProp(PropRelevant: Boolean; Prop: string): string; overload;
  begin
    if PropRelevant then Result := Prop else Result := TLang[700]; // N/A
  end;

  function DefProp(PropRelevant: Boolean; Prop: ULONG): string; overload;
  begin
    if PropRelevant then Result := UIntToStr(Prop) else Result := TLang[700]; // N/A
  end;

var
  DesignedCapacityFormat: string;
  FullChargedCapacityFormat: string;
  CurrentCapacityFormat: string;
  RateFormat: string;
  DefaultAlert1Format: string;
  DefaultAlert2Format: string;
begin
  Result := TPowerInfo.Create(16);

  with Battery do begin
    if IsUPS then
      Result.Add(ikCaption, TLang[781])
    else
      Result.Add(ikCaption, TLang[782]);

    Result.Add(ikName, DefProp(IsDeviceNameRelevant, DeviceName));
    Result.Add(ikManufacture, DefProp(IsManufactureNameRelevant, ManufactureName));
    Result.Add(ikManufactureDate, DefProp(IsManufactureDateRelevant, DateToStr(ManufactureDate)));
    Result.Add(ikSerialNumber, DefProp(IsSerialNumberRelevant, SerialNumber));

    if IsChemistryRelevant then
      case Technology of
        Nonrechargeable: Result.Add(ikType, Format(TLang[740], [Chemistry]));
        Rechargeable: Result.Add(ikType, Format(TLang[741], [Chemistry]));
      end
    else
      case Technology of
        Nonrechargeable: Result.Add(ikType, TLang[742]);
        Rechargeable: Result.Add(ikType, TLang[743]);
      end;

    Result.Add(ikCycleCount, DefProp(IsCycleCountRelevant, CycleCount));

    Result.Add(ikWearLevel, DefProp(IsWearLevelRelevant, Format(WearLevelProp, [FormatFloat('0.#', WearLevel)])));

    if IsFlag(PowerState, BATTERY_POWER_ON_LINE) then
      Result.Add(ikPowerState, TLang[745])
    else if IsFlag(PowerState, BATTERY_CHARGING) then
      Result.Add(ikPowerState, TLang[746])
    else if IsFlag(PowerState, BATTERY_CRITICAL) then
      Result.Add(ikPowerState, TLang[747])
    else if IsFlag(PowerState, BATTERY_DISCHARGING) then
      Result.Add(ikPowerState, TLang[748])
    else Result.Add(ikPowerState, TLang[700]);

    if IsCapacityRelative then
    begin
      DesignedCapacityFormat := CapacityRelativeProp;
      FullChargedCapacityFormat := CapacityRelativeProp;
      if IsFullChargedCapacityRelevant then
        CurrentCapacityFormat := CapacityCurrentRelativeProp
      else
        CurrentCapacityFormat := CapacityCurrentRelativeWitoutPercentProp;

      RateFormat := RateRelativeProp;

      DefaultAlert1Format := AlertRelativeProp;
      DefaultAlert2Format := AlertRelativeProp;
    end
    else
    begin
      if IsVoltageRelevant then begin
        DesignedCapacityFormat := CapacityFullProp;
        FullChargedCapacityFormat := CapacityFullProp;
        if IsFullChargedCapacityRelevant then
          CurrentCapacityFormat := CapacityCurrentFullProp
        else
          CurrentCapacityFormat := CapacityCurrentFullWitoutPercentProp;

        RateFormat := RateFullProp;

        DefaultAlert1Format := AlertFullProp;
        DefaultAlert2Format := AlertFullProp;
      end else begin
        DesignedCapacityFormat := CapacityProp;
        FullChargedCapacityFormat := CapacityProp;
        if IsFullChargedCapacityRelevant then
          CurrentCapacityFormat := CapacityCurrentProp
        else
          CurrentCapacityFormat := CapacityCurrentWitoutPercentProp;

        RateFormat := RateProp;

        DefaultAlert1Format := AlertProp;
        DefaultAlert2Format := AlertProp;
      end;
    end;

    Result.Add(ikDesignedCapacity, DefProp(IsDesignedCapacityRelevant, Format(DesignedCapacityFormat, [DesignedCapacity, DesignedCapacity_mAh])));
    Result.Add(ikFullChargedCapacity, DefProp(IsFullChargedCapacityRelevant, Format(FullChargedCapacityFormat, [FullChargedCapacity, FullChargedCapacity_mAh])));
    Result.Add(ikCapacity, DefProp(IsCapacityRelevant, Format(CurrentCapacityFormat, [Capacity, Capacity_mAh, CapacityPercent])));

    Result.Add(ikRate, DefProp(IsRateRelevant, Format(RateFormat, [Rate, Rate_mA])));

    Result.Add(ikDefaultAlert1, DefProp(IsDefaultAlert1Relevant, Format(DefaultAlert1Format, [DefaultAlert1, DefaultAlert1_mAh])));
    Result.Add(ikDefaultAlert2, DefProp(IsDefaultAlert2Relevant, Format(DefaultAlert2Format, [DefaultAlert2, DefaultAlert2_mAh])));

    Result.Add(ikVoltage, DefProp(IsVoltageRelevant, Format(VoltageProp, [Voltage_V])));

    Result.Add(ikTemperature, DefProp(IsTemperatureRelevant, Format(TemperatureProp, [Temperature_C, Temperature_F])));
  end;
end;

function TPowerMonitorWindow.GetSystemInfo(Status: TSystemPowerStatus): TPowerInfo;
var
  RawMsg: string;

  function PowerStatusToIndex(SystemPowerStatus: TSystemPowerStatus): Integer;
  begin
    with SystemPowerStatus do begin
      if IsFlag(BatteryFlag, BATTERY_FLAG_UNKNOWN) then
        Exit(700); // N/A

      if IsFlag(BatteryFlag, BATTERY_FLAG_NO_BATTERY) then
        Exit(784); // Батарея отсутствует

      if (BatteryLifePercent <= 100) and
          IsFlag(BatteryFlag, BATTERY_FLAG_CHARGING) and
          IsFlag(BatteryFlag, BATTERY_FLAG_HIGH) then
        Exit(785); // %0:d%% (Высокий, Зарядка)

      if (BatteryLifePercent <= 100) and
          IsFlag(BatteryFlag, BATTERY_FLAG_CHARGING) and
          IsFlag(BatteryFlag, BATTERY_FLAG_LOW) then
        Exit(786); // %0:d%% (Низкий, Зарядка)

      if (BatteryLifePercent <= 100) and
          IsFlag(BatteryFlag, BATTERY_FLAG_CHARGING) and
          IsFlag(BatteryFlag, BATTERY_FLAG_CRITICAL) then
        Exit(787); // %0:d%% (Критический, Зарядка)

      if (BatteryLifePercent <= 100) and
          IsFlag(BatteryFlag, BATTERY_FLAG_CHARGING) then
        Exit(788); // %0:d%% (Зарядка)

      if (BatteryLifePercent <= 100) and
          IsFlag(BatteryFlag, BATTERY_FLAG_HIGH) then
        Exit(789); // %0:d%% (Высокий)

      if (BatteryLifePercent <= 100) and
          IsFlag(BatteryFlag, BATTERY_FLAG_LOW) then
        Exit(790); // %0:d%% (Низкий)

      if (BatteryLifePercent <= 100) and
          IsFlag(BatteryFlag, BATTERY_FLAG_CRITICAL) then
        Exit(791); // %0:d%% (Критический)

      if (BatteryLifePercent <= 100) then
        Exit(792); // %0:d%%

      if IsFlag(BatteryFlag, BATTERY_FLAG_CHARGING) and
          IsFlag(BatteryFlag, BATTERY_FLAG_HIGH) then
        Exit(793); // Высокий, Зарядка

      if IsFlag(BatteryFlag, BATTERY_FLAG_CHARGING) and
          IsFlag(BatteryFlag, BATTERY_FLAG_LOW) then
        Exit(794); // Низкий, Зарядка

      if IsFlag(BatteryFlag, BATTERY_FLAG_CHARGING) and
          IsFlag(BatteryFlag, BATTERY_FLAG_CRITICAL) then
        Exit(795); // Критический, Зарядка

      if IsFlag(BatteryFlag, BATTERY_FLAG_CHARGING) then
        Exit(796); // Зарядка

      if IsFlag(BatteryFlag, BATTERY_FLAG_HIGH) then
        Exit(797); // Высокий

      if IsFlag(BatteryFlag, BATTERY_FLAG_LOW) then
        Exit(798); // Низкий

      if IsFlag(BatteryFlag, BATTERY_FLAG_CRITICAL) then
        Exit(799); // Критический

      Result := 701;
    end;
  end;

  function FormatTime(Time: DWORD): string;
  var
    Hour, Min, Sec, MSec: Word;
  begin
    if Time = BATTERY_LIFE_UNKNOWN then Exit(TLang[701]);

    DecodeTime(Time/SecsPerDay, Hour, Min, Sec, MSec);

    if Hour <> 0 then
      Result := Format(TLang[775], [Hour, Min])
    else
      Result := Format(TLang[776], [Hour, Min])
  end;
begin
  Result := TPowerInfo.Create(4);
  with Status do begin
    if IsFlag(ACLineStatus, AC_LINE_ONLINE) then
      Result.Add(ikPowerSource, TLang[780])     // Электросеть
    else if IsFlag(ACLineStatus, AC_LINE_BACKUP_POWER) then
      Result.Add(ikPowerSource, TLang[781])     // ИБП
    else if IsFlag(ACLineStatus, AC_LINE_OFFLINE) then
      Result.Add(ikPowerSource, TLang[782])     // Батарея
    else if IsFlag(ACLineStatus, AC_LINE_UNKNOWN) then
      Result.Add(ikPowerSource, TLang[700])     // N/A
    else Result.Add(ikPowerSource, TLang[700]); // N/A

    RawMsg := TLang[PowerStatusToIndex(Status)];
    Result.Add(ikBatteryStatus, Format(RawMsg, [BatteryLifePercent]));

    Result.Add(ikLifetime, FormatTime(BatteryLifeTime));
    Result.Add(ikFullLifetime, FormatTime(BatteryFullLifeTime));
  end;
end;

procedure TPowerMonitorWindow.LoadBatteryInfo(Info: TPowerInfo);
begin
  LabelName.Text                := Info[ikName];
  LabelManufacture.Text         := Info[ikManufacture];
  LabelManufactureDate.Text     := Info[ikManufactureDate];
  LabelSerialNumber.Text        := Info[ikSerialNumber];
  LabelType.Text                := Info[ikType];
  LabelCycleCount.Text          := Info[ikCycleCount];
  LabelWearLevel.Text           := Info[ikWearLevel];
  LabelPowerState.Text          := Info[ikPowerState];
  LabelDesignedCapacity.Text    := Info[ikDesignedCapacity];
  LabelFullChargedCapacity.Text := Info[ikFullChargedCapacity];
  LabelCapacity.Text            := Info[ikCapacity];
  LabelVoltage.Text             := Info[ikVoltage];
  LabelRate.Text                := Info[ikRate];
  LabelDefaultAlert1.Text       := Info[ikDefaultAlert1];
  LabelDefaultAlert2.Text       := Info[ikDefaultAlert2];
  LabelWearLevel.Text           := Info[ikWearLevel];
  LabelTemperature.Text         := Info[ikTemperature];
end;

procedure TPowerMonitorWindow.Loadlocalization;
begin
  MainMenuFile.Caption                        := TLang[755]; // Файл
  MainMenuClose.Caption                       := TLang[756]; // Закрыть
  MainMenuSave.Caption                        := TLang[757]; // Сохранить
  MainMenuSaveAs.Caption                      := TLang[758]; // Сохранить как...

  MainMenuView.Caption                        := TLang[750]; // Вид
  MainMenuAlwaysOnTop.Caption                 := TLang[751]; // Поверх остальных окон

  GroupBoxBattery.Caption                     := TLang[705]; // Свойства батареи

  LabelName.EditLabel.Caption                 := TLang[710]; // Имя устройства
  LabelManufacture.EditLabel.Caption          := TLang[711]; // Производитель
  LabelManufactureDate.EditLabel.Caption      := TLang[712]; // Дата изготовления
  LabelSerialNumber.EditLabel.Caption         := TLang[713]; // Серийный номер
  LabelType.EditLabel.Caption                 := TLang[714]; // Тип батареи
  LabelCycleCount.EditLabel.Caption           := TLang[715]; // Циклов заряда/разряда
  LabelWearLevel.EditLabel.Caption            := TLang[716]; // Степень изношенности
  LabelPowerState.EditLabel.Caption           := TLang[717]; // Состояние

  LabelDesignedCapacity.EditLabel.Caption     := TLang[718]; // Паспортная ёмкость
  LabelFullChargedCapacity.EditLabel.Caption  := TLang[719]; // Ёмкость при полной зарядке
  LabelCapacity.EditLabel.Caption             := TLang[720]; // Текущая ёмкость
  LabelVoltage.EditLabel.Caption              := TLang[721]; // Напряжение батареи
  LabelRate.EditLabel.Caption                 := TLang[722]; // Скорость зарядки/разрядки
  LabelDefaultAlert1.EditLabel.Caption        := TLang[725]; // Сигнал тревоги 1
  LabelDefaultAlert2.EditLabel.Caption        := TLang[726]; // Сигнал тревоги 2
  LabelTemperature.EditLabel.Caption          := TLang[727]; // Температура

  GroupBoxSystem.Caption                      := TLang[765]; // Свойства электропитания

  LabelPowerSource.EditLabel.Caption          := TLang[770]; // Текущий источник питания
  LabelBatteryStatus.EditLabel.Caption        := TLang[771]; // Состояние батарей
  LabelFullLifetime.EditLabel.Caption         := TLang[772]; // Полное время работы от батарей
  LabelLifetime.EditLabel.Caption             := TLang[773]; // Оставшееся время работы от батарей
end;

procedure TPowerMonitorWindow.LoadSystemInfo(Info: TPowerInfo);
begin
  LabelPowerSource.Text   := Info[ikPowerSource];
  LabelBatteryStatus.Text := Info[ikBatteryStatus];
  LabelLifetime.Text      := Info[ikLifetime];
  LabelFullLifetime.Text  := Info[ikFullLifetime];
end;

procedure TPowerMonitorWindow.MainMenuAlwaysOnTopClick(Sender: TObject);
begin
  StayOnTop := (Sender as TMenuItem).Checked;
  if StayOnTop then
    FormStyle := fsStayOnTop
  else
    FormStyle := fsNormal;
end;

procedure TPowerMonitorWindow.MainMenuCloseClick(Sender: TObject);
begin
  Close;
end;

function TPowerMonitorWindow.SaveLogAs: string;
const
  FilterProp = '%0:s (%1:s)|%1:s';
var
  Dialog: TSaveDialog;
  Filter: TStringList;
begin
  Result := '';
  Dialog := TSaveDialog.Create(Self);
  Filter := TStringList.Create;
  try
    Filter.Add(Format(FilterProp, [TLang[759], '*.*']));
    Filter.Add(Format(FilterProp, [TLang[760], '*.txt']));
    Filter.Add(Format(FilterProp, [TLang[761], '*.log']));
    Filter.Delimiter := '|';
    Filter.QuoteChar := #0;
    Dialog.Filter := Filter.DelimitedText;
    Dialog.FilterIndex := 2;

    Dialog.DefaultExt := 'txt';
    Dialog.FileName := 'Battery Info ' + ComputerName;
    Dialog.Options := Dialog.Options + [ofOverwritePrompt];

    if Dialog.Execute(Handle) then begin
      if SaveLog(Dialog.FileName, FBatterys, FSystemPowerStatus) then
        Result := Dialog.FileName;
    end;
  finally
    Filter.Free;
    Dialog.Free;
    TrimWorkingSetSize;
  end;
end;

procedure TPowerMonitorWindow.MainMenuSaveAsClick(Sender: TObject);
begin
  LogFile := SaveLogAs;
end;

procedure TPowerMonitorWindow.MainMenuSaveClick(Sender: TObject);
begin
  if LogFile <> '' then
    SaveLog(LogFile, FBatterys, FSystemPowerStatus)
  else
    LogFile := SaveLogAs;
end;

procedure TPowerMonitorWindow.TabControlChange(Sender: TObject);
begin
  if LockerInfo.IsLocked then Exit;
  UpdateInfo(FBatterys, FSystemPowerStatus);
end;

procedure TPowerMonitorWindow.TimerAutoupdateTimer(Sender: TObject);
var
  PowerSystem: TPowerSystem;
begin
  (Sender as TTimer).Enabled := False;

  PowerSystem := TPowerSystem.Create;
  PowerSystem.OnInformation := PowerSystemInformation;
  PowerSystem.GetInformationAsync;
end;

procedure TPowerMonitorWindow.PowerSystemInformation(Sender: TObject;
  Batterys: TBatteryList; SystemPowerStatus: TSystemPowerStatus);
begin
  FBatterys.Free;
  FBatterys := Batterys;
  FSystemPowerStatus := SystemPowerStatus;
  UpdateInfo(FBatterys, FSystemPowerStatus);

  TimerAutoupdate.Enabled := True;
end;

function TPowerMonitorWindow.SaveLog(FileName: string; Batterys: TBatteryList;
  Status: TSystemPowerStatus): Boolean;
const
  TabIndexedProp = '%0:s %1:u';
  TabOneProp = '%0:s';
  KeyValProp = #9 + '%0:-32s : %1:s';
var
  Log: TStringList;
  Battery: TBattery;
  BatteryCount: Integer;
  UPSCount: Integer;
  BatteryIndex: Integer;
  UPSIndex: Integer;

  TabProp: string;
  Info: TPowerInfo;
begin
  Result := True;
  try
    Log := TStringList.Create;
    try
      Log.Add(ComputerName + #9 + DateTimeToStr(Now));
      Log.Add('');

      BatteryCount := Batterys.BatteryCount;
      UPSCount := Batterys.UPSCount;

      BatteryIndex := 1;
      UPSIndex := 1;

      for Battery in Batterys do begin
        Info := GetBatteryInfo(Battery);
        if Battery.IsUPS then begin
          if UPSCount = 1 then TabProp := TabOneProp else TabProp := TabIndexedProp;
          Log.Add(Format(TabProp, [Info[ikCaption], UPSIndex]));
          Inc(UPSIndex);
        end else begin
          if BatteryCount = 1 then TabProp := TabOneProp else TabProp := TabIndexedProp;
          Log.Add(Format(TabProp, [Info[ikCaption], BatteryIndex]));
          Inc(BatteryIndex);
        end;
        Log.Add(Format(KeyValProp, [TLang[710], Info[ikName]])); // Имя устройства
        Log.Add(Format(KeyValProp, [TLang[711], Info[ikManufacture]])); // Производитель
        Log.Add(Format(KeyValProp, [TLang[712], Info[ikManufactureDate]])); // Дата изготовления
        Log.Add(Format(KeyValProp, [TLang[713], Info[ikSerialNumber]])); // Серийный номер
        Log.Add(Format(KeyValProp, [TLang[714], Info[ikType]])); // Тип батареи
        Log.Add(Format(KeyValProp, [TLang[715], Info[ikCycleCount]])); // Циклов заряда/разряда
        Log.Add(Format(KeyValProp, [TLang[716], Info[ikWearLevel]])); // Степень изношенности
        Log.Add(Format(KeyValProp, [TLang[717], Info[ikPowerState]])); // Состояние
        Log.Add(Format(KeyValProp, [TLang[718], Info[ikDesignedCapacity]])); // Паспортная ёмкость
        Log.Add(Format(KeyValProp, [TLang[719], Info[ikFullChargedCapacity]])); // Ёмкость при полной зарядке
        Log.Add(Format(KeyValProp, [TLang[720], Info[ikCapacity]])); // Текущая ёмкость
        Log.Add(Format(KeyValProp, [TLang[721], Info[ikVoltage]])); // Напряжение батареи
        Log.Add(Format(KeyValProp, [TLang[722], Info[ikRate]])); // Скорость зарядки/разрядки
        Log.Add(Format(KeyValProp, [TLang[725], Info[ikDefaultAlert1]])); // Сигнал тревоги 1
        Log.Add(Format(KeyValProp, [TLang[726], Info[ikDefaultAlert2]])); // Сигнал тревоги 2
        Log.Add(Format(KeyValProp, [TLang[727], Info[ikTemperature]])); // Температура
        Log.Add('');
        Info.Free;
      end;

      Info := GetSystemInfo(Status);
      Log.Add(TLang[765]);
      Log.Add(Format(KeyValProp, [TLang[770], Info[ikPowerSource]])); // Текущий источник питания
      Log.Add(Format(KeyValProp, [TLang[771], Info[ikBatteryStatus]])); // Состояние батарей
      Log.Add(Format(KeyValProp, [TLang[772], Info[ikLifetime]])); // Полное время работы от батарей
      Log.Add(Format(KeyValProp, [TLang[773], Info[ikFullLifetime]])); // Оставшееся время работы от батарей

      Log.SaveToFile(FileName, TEncoding.UTF8);
    finally
      Log.Free;
    end;
  except
    Result := False;
  end;
end;

procedure TPowerMonitorWindow.UpdateInfo(Batterys: TBatteryList; Status: TSystemPowerStatus);
const
  TabIndexedProp = '%0:s %1:u';
  TabOneProp = '%0:s';
var
  TabCount: Integer;
  BatteryCount: Integer;
  UPSCount: Integer;
  BatteryIndex: Integer;
  UPSIndex: Integer;
  Battery: TBattery;

  Tabs: TStringList;
  TabProp: string;
  TabIndex: Integer;
  BatteryInfo: TPowerInfo;
  SystemInfo: TPowerInfo;
begin
  TabCount := Batterys.Count;
  TabIndex := TabControl.TabIndex;
  case TabCount of
    0: begin
      if TabControl.Tabs.Text <> '' then TabControl.Tabs.Text := '';
      GroupBoxBattery.Visible := False;
    end;
    1: begin
      if TabControl.Tabs.Text <> '' then TabControl.Tabs.Text := '';
      GroupBoxBattery.Visible := True;

      BatteryInfo := GetBatteryInfo(Batterys[0]);
      LoadBatteryInfo(BatteryInfo);
      BatteryInfo.Free;
    end;
    else begin
      BatteryCount := Batterys.BatteryCount;
      UPSCount := Batterys.UPSCount;

      GroupBoxBattery.Visible := True;

      Tabs := TStringList.Create;
      BatteryIndex := 1;
      UPSIndex := 1;
      for Battery in Batterys do
        if Battery.IsUPS then begin
          if UPSCount = 1 then TabProp := TabOneProp else TabProp := TabIndexedProp;
          Tabs.Add(Format(TabProp, [TLang[781], UPSIndex]));
          Inc(UPSIndex);
        end else begin
          if BatteryCount = 1 then TabProp := TabOneProp else TabProp := TabIndexedProp;
          Tabs.Add(Format(TabProp, [TLang[782], BatteryIndex]));
          Inc(BatteryIndex);
        end;

      if not TabControl.Tabs.Equals(Tabs) then begin
        TabControl.Tabs.Text := Tabs.Text;

        LockerInfo.Lock;
        try
          if (TabIndex >= TabCount) or (TabIndex < 0) then
            TabControl.TabIndex := 0
          else if TabIndex <> TabControl.TabIndex then
            TabControl.TabIndex := TabIndex;
        finally
          LockerInfo.Unlock;
        end;
      end;

      BatteryInfo := GetBatteryInfo(Batterys[TabControl.TabIndex]);
      LoadBatteryInfo(BatteryInfo);
      BatteryInfo.Free;
    end;
  end;

  SystemInfo := GetSystemInfo(Status);
  LoadSystemInfo(SystemInfo);
  SystemInfo.Free;
end;

end.
