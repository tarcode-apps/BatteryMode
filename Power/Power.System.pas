unit Power.System;

interface

uses
  Winapi.Windows,
  System.SysUtils, System.Classes,
  System.Generics.Collections, System.Generics.Defaults,
  Power.WinApi.Kernel32, Power.WinApi.SetupApi;

type
  TBattery = record
  const
    UnknownTemperature = ULONG(-1);
  private
    function GetIsDeviceNameRelevant: Boolean;
    function GetIsCapacityRelevant: Boolean;
    function GetIsDesignedCapacityRelevant: Boolean;
    function GetIsFullChargedCapacityRelevant: Boolean;
    function GetIsManufactureDateRelevant: Boolean;
    function GetIsManufactureNameRelevant: Boolean;
    function GetIsRateRelevant: Boolean;
    function GetIsSerialNumberRelevant: Boolean;
    function GetIsTemperatureRelevant: Boolean;
    function GetIsUniqueIDRelevant: Boolean;
    function GetIsVoltageRelevant: Boolean;

    function GetIsCapacityRelative: Boolean;

    function GetCapacity_mAh: ULONG;
    function GetDesignedCapacity_mAh: ULONG;
    function GetFullChargedCapacity_mAh: ULONG;
    function GetDefaultAlert1_mAh: ULONG;
    function GetDefaultAlert2_mAh: ULONG;
    function GetRate_mA: ULONG;
    function GetRate_W: ULONG;
    function GetVoltage_V: Double;
    function GetIsCycleCountRelevant: Boolean;
    function GetWearLevel: Double;
    function GetIsWearLevelRelevant: Boolean;
    function GetCapacityPercent: Integer;
    function GetIsChemistryRelevant: Boolean;
    function GetIsDefaultAlert1Relevant: Boolean;
    function GetIsDefaultAlert2Relevant: Boolean;
    function GetTemperature_C: LONG;
    function GetTemperature_F: LONG;
    function GetIsUPS: Boolean;
  public
    Capabilities        : ULONG;
    PowerState          : ULONG;
    Technology          : TTechnology;
    Chemistry           : string;
    DeviceName          : string;
    ManufactureName     : string;
    ManufactureDate     : TDate;
    SerialNumber        : string;
    UniqueID            : string;
    DesignedCapacity    : ULONG;
    FullChargedCapacity : ULONG;
    Capacity            : ULONG;
    DefaultAlert1       : ULONG;
    DefaultAlert2       : ULONG;
    CriticalBias        : ULONG;
    CycleCount          : ULONG;
    Temperature         : ULONG;
    Voltage             : ULONG;
    Rate                : LONG;

    property IsDeviceNameRelevant: Boolean read GetIsDeviceNameRelevant;
    property IsManufactureNameRelevant: Boolean read GetIsManufactureNameRelevant;
    property IsManufactureDateRelevant: Boolean read GetIsManufactureDateRelevant;
    property IsSerialNumberRelevant: Boolean read GetIsSerialNumberRelevant;
    property IsUniqueIDRelevant: Boolean read GetIsUniqueIDRelevant;
    property IsChemistryRelevant: Boolean read GetIsChemistryRelevant;
    property IsCapacityRelevant: Boolean read GetIsCapacityRelevant;
    property IsDesignedCapacityRelevant: Boolean read GetIsDesignedCapacityRelevant;
    property IsFullChargedCapacityRelevant: Boolean read GetIsFullChargedCapacityRelevant;
    property IsTemperatureRelevant: Boolean read GetIsTemperatureRelevant;
    property IsCycleCountRelevant: Boolean read GetIsCycleCountRelevant;
    property IsVoltageRelevant: Boolean read GetIsVoltageRelevant;
    property IsRateRelevant: Boolean read GetIsRateRelevant;
    property IsDefaultAlert1Relevant: Boolean read GetIsDefaultAlert1Relevant;
    property IsDefaultAlert2Relevant: Boolean read GetIsDefaultAlert2Relevant;
    property IsWearLevelRelevant: Boolean read GetIsWearLevelRelevant;
    property IsUPS: Boolean read GetIsUPS;

    property IsCapacityRelative: Boolean read GetIsCapacityRelative;

    property WearLevel: Double read GetWearLevel;
    property DesignedCapacity_mAh: ULONG read GetDesignedCapacity_mAh;
    property FullChargedCapacity_mAh: ULONG read GetFullChargedCapacity_mAh;
    property Capacity_mAh: ULONG read GetCapacity_mAh;
    property CapacityPercent: Integer read GetCapacityPercent;
    property DefaultAlert1_mAh: ULONG read GetDefaultAlert1_mAh;
    property DefaultAlert2_mAh: ULONG read GetDefaultAlert2_mAh;
    property Voltage_V: Double read GetVoltage_V;
    property Rate_W: ULONG read GetRate_W;
    property Rate_mA: ULONG read GetRate_mA;
    property Temperature_C: LONG read GetTemperature_C;
    property Temperature_F: LONG read GetTemperature_F;
  end;
  TBatteryList = class(TList<TBattery>)
  private
    function GetBatteryCount: Integer;
    function GetUPSCount: Integer;
  public
    property BatteryCount: Integer read GetBatteryCount;
    property UPSCount: Integer read GetUPSCount;
  end;

  TInformationEvent = procedure(Sender: TObject; Batterys: TBatteryList; SystemPowerStatus: TSystemPowerStatus) of object;

  TPowerSystem = class(TThread)
  private
    FOnInformation: TInformationEvent;

    class function GetBatterys: TBatteryList;
    class function GetSystem: TSystemPowerStatus;
  protected
    procedure Execute; override;
  public
    class procedure GetInformation(out Batterys: TBatteryList; out SystemPowerStatus: TSystemPowerStatus);
  public
    constructor Create;
    procedure GetInformationAsync;
    property OnInformation: TInformationEvent read FOnInformation write FOnInformation;
  end;

  function IsFlag(Val: ULONG; Flag: ULONG): Boolean; inline;

implementation

function IsFlag(Val: ULONG; Flag: ULONG): Boolean; inline;
begin
  Result := Val and Flag = Flag;
end;

{ TPowerSystem }

constructor TPowerSystem.Create;
begin
  inherited Create(True);
  FreeOnTerminate := True;
end;

procedure TPowerSystem.Execute;
var
  Batt: TBatteryList;
  Status: TSystemPowerStatus;
begin
  GetInformation(Batt, Status);

  if Assigned(FOnInformation) then
    FOnInformation(Self, Batt, Status);
end;

class procedure TPowerSystem.GetInformation(out Batterys: TBatteryList;
  out SystemPowerStatus: TSystemPowerStatus);
begin
  Batterys := GetBatterys;
  SystemPowerStatus := GetSystem;
end;

procedure TPowerSystem.GetInformationAsync;
begin
  Start;
end;

class function TPowerSystem.GetBatterys: TBatteryList;
var
  hdev: HDEVINFO;
  idev: Integer;
  did: SP_DEVICE_INTERFACE_DATA;
  cbRequired: DWORD;
  pdidd: PSP_DEVICE_INTERFACE_DETAIL_DATA;
  hBattery: THandle;
  bqi: BATTERY_QUERY_INFORMATION;
  dwWait: DWORD;
  dwOut: DWORD;
  bi: BATTERY_INFORMATION;
  bmd: BATTERY_MANUFACTURE_DATE;
  bws: BATTERY_WAIT_STATUS;
  bs: BATTERY_STATUS;

  Battery: TBattery;
begin
  Result := TBatteryList.Create;

  hdev := SetupDiGetClassDevs(GUID_DEVCLASS_BATTERY,
                              nil, 0, DIGCF_PRESENT or DIGCF_DEVICEINTERFACE);
  if hdev = INVALID_HANDLE_VALUE then Exit;

  try
    // Limit search to 100 batteries max
    for idev := 0 to 99 do begin
      ZeroMemory(@did, SizeOf(did));
      did.cbSize := SizeOf(did);

      if not SetupDiEnumDeviceInterfaces(hdev, nil,
          GUID_DEVCLASS_BATTERY, idev, did) then begin
        if GetLastError() = ERROR_NO_MORE_ITEMS then Break;
        Continue;
      end;

      cbRequired := 0;
      SetupDiGetDeviceInterfaceDetail(hdev, @did, nil, 0, @cbRequired, nil);

      if GetLastError() = ERROR_INSUFFICIENT_BUFFER then begin
        pdidd := PSP_DEVICE_INTERFACE_DETAIL_DATA(LocalAlloc(LPTR, cbRequired));
        if not Assigned(pdidd) then Continue;

        try
          pdidd^.cbSize := SizeOf(pdidd^);
          if not SetupDiGetDeviceInterfaceDetail(hdev, @did, pdidd, cbRequired, @cbRequired, nil) then Continue;

          // Enumerated a battery.  Ask it for information.
          hBattery := CreateFile(pdidd^.DevicePath,
                                 GENERIC_READ or GENERIC_WRITE,
                                 FILE_SHARE_READ or FILE_SHARE_WRITE,
                                 nil,
                                 OPEN_EXISTING,
                                 FILE_ATTRIBUTE_NORMAL,
                                 0);
          if hBattery = INVALID_HANDLE_VALUE then Continue;

          try
            // Ask the battery for its tag.
            ZeroMemory(@bqi, SizeOf(bqi));
            dwWait := 0;
            if not (DeviceIoControl(hBattery, IOCTL_BATTERY_QUERY_TAG,
                @dwWait,
                SizeOf(dwWait),
                @bqi.BatteryTag,
                SizeOf(bqi.BatteryTag),
                dwOut,
                nil) and (bqi.BatteryTag <> 0)) then Continue;

            // With the tag, you can query the battery info.
            ZeroMemory(@bi, SizeOf(bi));
            bqi.InformationLevel := BatteryInformation;
            if not DeviceIoControl(hBattery,
                IOCTL_BATTERY_QUERY_INFORMATION,
                @bqi,
                SizeOf(bqi),
                @bi,
                SizeOf(bi),
                dwOut,
                nil) then Continue;
            Battery.Capabilities := bi.Capabilities;
            case bi.Technology of
              0: Battery.Technology := Nonrechargeable;
              else Battery.Technology := Rechargeable;
            end;
            SetLength(Battery.Chemistry, 4);
            Battery.Chemistry[1] := chr(bi.Chemistry[0]);
            Battery.Chemistry[2] := chr(bi.Chemistry[1]);
            Battery.Chemistry[3] := chr(bi.Chemistry[2]);
            Battery.Chemistry[4] := chr(bi.Chemistry[3]);
            Battery.Chemistry.Trim;

            Battery.DesignedCapacity := bi.DesignedCapacity;
            Battery.FullChargedCapacity := bi.FullChargedCapacity;
            Battery.DefaultAlert1 := bi.DefaultAlert1;
            Battery.DefaultAlert2 := bi.DefaultAlert2;
            Battery.CriticalBias := bi.CriticalBias;
            Battery.CycleCount := bi.CycleCount;

            // Query the battery device name.
            SetLength(Battery.DeviceName, MAX_PATH);
            bqi.InformationLevel := BatteryDeviceName;
            if DeviceIoControl(hBattery,
                IOCTL_BATTERY_QUERY_INFORMATION,
                @bqi,
                SizeOf(bqi),
                LPTSTR(Battery.DeviceName),
                MAX_PATH,
                dwOut,
                nil) then begin
              SetLength(Battery.DeviceName, dwOut div SizeOf(Char));
              Battery.DeviceName := Battery.DeviceName.Trim;
            end else
              Battery.DeviceName := '';


            // Query the battery manufacture name.
            SetLength(Battery.ManufactureName, MAX_PATH);
            bqi.InformationLevel := BatteryManufactureName;
            if DeviceIoControl(hBattery,
                IOCTL_BATTERY_QUERY_INFORMATION,
                @bqi,
                SizeOf(bqi),
                LPTSTR(Battery.ManufactureName),
                MAX_PATH,
                dwOut,
                nil) then begin
              SetLength(Battery.ManufactureName, dwOut div SizeOf(Char));
              Battery.ManufactureName := Battery.ManufactureName.Trim;
            end else
              Battery.ManufactureName := '';

            // Query the battery manufacture date.
            ZeroMemory(@Battery.ManufactureDate, SizeOf(bmd));
            bqi.InformationLevel := BatteryManufactureDate;
            if DeviceIoControl(hBattery,
                IOCTL_BATTERY_QUERY_INFORMATION,
                @bqi,
                SizeOf(bqi),
                @bmd,
                SizeOf(bmd),
                dwOut,
                nil) then
              Battery.ManufactureDate := EncodeDate(bmd.Year, bmd.Month, bmd.Day)
            else
              Battery.ManufactureDate := 0;

            // Query the battery serial number.
            SetLength(Battery.SerialNumber, MAX_PATH);
            bqi.InformationLevel := BatterySerialNumber;
            if DeviceIoControl(hBattery,
                IOCTL_BATTERY_QUERY_INFORMATION,
                @bqi,
                SizeOf(bqi),
                LPTSTR(Battery.SerialNumber),
                MAX_PATH,
                dwOut,
                nil) then begin
              SetLength(Battery.SerialNumber, dwOut div SizeOf(Char));
              Battery.SerialNumber := Battery.SerialNumber.Trim;
            end else
              Battery.SerialNumber := '';

            // Query the battery temperature.
            bqi.InformationLevel := BatteryTemperature;
            if not DeviceIoControl(hBattery,
                IOCTL_BATTERY_QUERY_INFORMATION,
                @bqi,
                SizeOf(bqi),
                @Battery.Temperature,
                SizeOf(Battery.Temperature),
                dwOut,
                nil) then
              Battery.Temperature := Battery.UnknownTemperature;

            // Query the battery unique ID.
            SetLength(Battery.UniqueID, MAX_PATH);
            bqi.InformationLevel := BatteryUniqueID;
            if DeviceIoControl(hBattery,
                IOCTL_BATTERY_QUERY_INFORMATION,
                @bqi,
                SizeOf(bqi),
                LPTSTR(Battery.UniqueID),
                MAX_PATH,
                dwOut,
                nil) then begin
              SetLength(Battery.UniqueID, dwOut div SizeOf(Char));
              Battery.UniqueID := Battery.UniqueID.Trim;
            end else
              Battery.UniqueID := '';

            // Query the battery status.
            ZeroMemory(@bws, SizeOf(bws));
            bws.BatteryTag := bqi.BatteryTag;
            ZeroMemory(@bs, SizeOf(bs));
            if not DeviceIoControl(hBattery,
                IOCTL_BATTERY_QUERY_STATUS,
                @bws,
                SizeOf(bws),
                @bs,
                SizeOf(bs),
                dwOut,
                nil) then Continue;

            Battery.PowerState := bs.PowerState;
            Battery.Capacity := bs.Capacity;
            Battery.Voltage := bs.Voltage;
            Battery.Rate := bs.Rate;

            Result.Add(Battery);
          finally
            CloseHandle(hBattery);
          end;
        finally
          LocalFree(HLOCAL(pdidd));
        end;
      end;
    end;
  finally
    SetupDiDestroyDeviceInfoList(hdev);
  end;
end;

class function TPowerSystem.GetSystem: TSystemPowerStatus;
begin
  if not GetSystemPowerStatus(Result) then
    ZeroMemory(@Result, SizeOf(Result));
end;


{ TBattery }

function TBattery.GetIsCapacityRelevant: Boolean;
begin
  Result := Capacity <> BATTERY_UNKNOWN_CAPACITY;
end;

function TBattery.GetIsDesignedCapacityRelevant: Boolean;
begin
  Result := True;
end;

function TBattery.GetIsFullChargedCapacityRelevant: Boolean;
begin
  Result := True;
end;

function TBattery.GetIsChemistryRelevant: Boolean;
begin
  Result := Chemistry <> '';
end;

function TBattery.GetIsDefaultAlert1Relevant: Boolean;
begin
  Result := DefaultAlert1 > 0;
end;

function TBattery.GetIsDefaultAlert2Relevant: Boolean;
begin
  Result := DefaultAlert2 > 0;
end;

function TBattery.GetIsDeviceNameRelevant: Boolean;
begin
  Result := DeviceName <> '';
end;

function TBattery.GetIsManufactureDateRelevant: Boolean;
begin
  Result := ManufactureDate <> 0;
end;

function TBattery.GetIsManufactureNameRelevant: Boolean;
begin
  Result := ManufactureName <> '';
end;

function TBattery.GetIsRateRelevant: Boolean;
begin
  Result := (DWORD(Rate) <> BATTERY_UNKNOWN_RATE) and (Rate <> 0);
end;

function TBattery.GetIsSerialNumberRelevant: Boolean;
begin
  Result := SerialNumber <> '';
end;

function TBattery.GetIsCycleCountRelevant: Boolean;
begin
  Result := CycleCount > 0;
end;

function TBattery.GetIsTemperatureRelevant: Boolean;
begin
  Result := (Temperature <> 0) and (Temperature <> UnknownTemperature);
end;

function TBattery.GetIsUniqueIDRelevant: Boolean;
begin
  Result := UniqueID <> '';
end;

function TBattery.GetIsUPS: Boolean;
begin
  Result := IsFlag(Capabilities, BATTERY_IS_SHORT_TERM);
end;

function TBattery.GetIsVoltageRelevant: Boolean;
begin
  Result := Voltage <> BATTERY_UNKNOWN_VOLTAGE;
end;

function TBattery.GetIsWearLevelRelevant: Boolean;
begin
  Result := IsDesignedCapacityRelevant and IsFullChargedCapacityRelevant;
end;

function TBattery.GetIsCapacityRelative: Boolean;
begin
  Result := IsFlag(Capabilities, BATTERY_CAPACITY_RELATIVE);
end;

function TBattery.GetWearLevel: Double;
begin
  if DesignedCapacity = 0 then Exit(0);
  if DesignedCapacity < FullChargedCapacity then Exit(0);

  Result := 100.0 - (FullChargedCapacity*100/DesignedCapacity);
  if Result < 0 then Result := 0;
  if Result > 100 then Result := 100;
end;

function TBattery.GetCapacityPercent: Integer;
begin
  if FullChargedCapacity <> 0 then
    Result := Round(Capacity/FullChargedCapacity*100)
  else
    Result := 0;
end;

function TBattery.GetCapacity_mAh: ULONG;
begin
  if Voltage = 0 then Exit(0);
  Result := Round(Capacity/Voltage*1000);
end;

function TBattery.GetDesignedCapacity_mAh: ULONG;
begin
  if Voltage = 0 then Exit(0);
  Result := Round(DesignedCapacity/Voltage*1000);
end;

function TBattery.GetFullChargedCapacity_mAh: ULONG;
begin
  if Voltage = 0 then Exit(0);
  Result := Round(FullChargedCapacity/Voltage*1000);
end;

function TBattery.GetDefaultAlert1_mAh: ULONG;
begin
  if Voltage = 0 then Exit(0);
  Result := Round(DefaultAlert1/Voltage*1000);
end;

function TBattery.GetDefaultAlert2_mAh: ULONG;
begin
  if Voltage = 0 then Exit(0);
  Result := Round(DefaultAlert2/Voltage*1000);
end;

function TBattery.GetRate_mA: ULONG;
begin
  if Voltage = 0 then Exit(0);
  Result := Round(Rate/Voltage*1000);
end;

function TBattery.GetRate_W: ULONG;
begin
  Result := Round(Rate/1000);
end;

function TBattery.GetVoltage_V: Double;
begin
  Result := Voltage/1000;
end;

function TBattery.GetTemperature_C: LONG;
begin
  Result := Round((Temperature/10) - 273.15);
end;

function TBattery.GetTemperature_F: LONG;
begin
  Result := Round(9*(Temperature/10 -273.15)/5 + 32);
end;


{ TBatteryList }

function TBatteryList.GetBatteryCount: Integer;
var
  Battery: TBattery;
begin
  Result := 0;
  for Battery in Self do
    if not Battery.IsUPS then
      Inc(Result);
end;

function TBatteryList.GetUPSCount: Integer;
var
  Battery: TBattery;
begin
  Result := 0;
  for Battery in Self do
    if Battery.IsUPS then
      Inc(Result);
end;

end.
