unit Power.WinApi.Kernel32;

interface

uses
  Winapi.Windows;

{*******************************************************}
{             Kernel32 Win32 API type                   }
{*******************************************************}

const
  BATTERY_CHARGING      = DWORD($00000004); // Indicates that the battery is currently charging.
  BATTERY_CRITICAL      = DWORD($00000008); // Indicates that battery failure is imminent.
  BATTERY_DISCHARGING   = DWORD($00000002); // Indicates that the battery is currently discharging.
  BATTERY_POWER_ON_LINE = DWORD($00000001); // Indicates that the system has access to AC power, so no batteries are being discharged.

  BATTERY_UNKNOWN_CAPACITY  = DWORD($FFFFFFFF);
  BATTERY_UNKNOWN_VOLTAGE   = DWORD($FFFFFFFF);
  BATTERY_UNKNOWN_RATE      = DWORD($80000000);

  // Indicates that the battery capacity and rate information are relative, and not in any specific units.
  // If this bit is not set, the reporting units are milliwatt-hours (mWh) for capacity and milliwatts (mW) for rate.
  // If this bit is set, all references to units in the other battery documentation can be ignored.
  // All rate information is reported in units per hour.
  // For example, if the fully charged capacity is reported as 100,
  // a rate of 200 indicates that the battery will use all of its capacity in half an hour.
  BATTERY_CAPACITY_RELATIVE       = DWORD($40000000);
  BATTERY_IS_SHORT_TERM           = DWORD($20000000); // Indicates that the normal operation is for a fail-safe function. If this bit is not set the battery is expected to be used during normal system usage.
  BATTERY_SET_CHARGE_SUPPORTED    = DWORD($00000001); // Indicates that set information requests of the type BatteryCharge are supported by this battery device.
  BATTERY_SET_DISCHARGE_SUPPORTED = DWORD($00000002); // Indicates that set information requests of the type BatteryDischarge are supported by this battery device.
  BATTERY_SYSTEM_BATTERY          = DWORD($80000000); // Indicates that the battery can provide general power to run the system.

type
  {$MinEnumSize 4}
  {$EXTERNALSYM BATTERY_QUERY_INFORMATION_LEVEL}
  BATTERY_QUERY_INFORMATION_LEVEL = (
    BatteryDeviceName             = 4,
    BatteryEstimatedTime          = 3,
    BatteryGranularityInformation = 1,
    BatteryInformation            = 0,
    BatteryManufactureDate        = 5,
    BatteryManufactureName        = 6,
    BatterySerialNumber           = 8,
    BatteryTemperature            = 2,
    BatteryUniqueID               = 7);

  {$EXTERNALSYM _BATTERY_QUERY_INFORMATION}
  _BATTERY_QUERY_INFORMATION = packed record
    BatteryTag        : ULONG;
    InformationLevel  : BATTERY_QUERY_INFORMATION_LEVEL;
    AtRate            : LONG;
  end;
  {$EXTERNALSYM BATTERY_QUERY_INFORMATION}
  BATTERY_QUERY_INFORMATION = _BATTERY_QUERY_INFORMATION;
  {$EXTERNALSYM PBATTERY_QUERY_INFORMATION}
  PBATTERY_QUERY_INFORMATION = ^BATTERY_QUERY_INFORMATION;

  {$EXTERNALSYM _BATTERY_INFORMATION}
  _BATTERY_INFORMATION = packed record
    Capabilities        : ULONG;
    Technology          : UCHAR;
    Reserved  : array [0..2] of UCHAR;
    Chemistry : array [0..3] of UCHAR;
    DesignedCapacity    : ULONG;
    FullChargedCapacity : ULONG;
    DefaultAlert1       : ULONG;
    DefaultAlert2       : ULONG;
    CriticalBias        : ULONG;
    CycleCount          : ULONG;
  end;
  {$EXTERNALSYM BATTERY_INFORMATION}
  BATTERY_INFORMATION = _BATTERY_INFORMATION;
  {$EXTERNALSYM PBATTERY_INFORMATION}
  PBATTERY_INFORMATION = ^BATTERY_INFORMATION;

  {$MinEnumSize 1}
  TTechnology = (
    Nonrechargeable = 0, // Nonrechargeable battery, for example, alkaline.
    Rechargeable    = 1  // Rechargeable battery, for example, lead acid.
  );

  {$EXTERNALSYM _BATTERY_WAIT_STATUS}
  _BATTERY_WAIT_STATUS = packed record
    BatteryTag    : ULONG;
    Timeout       : ULONG;
    PowerState    : ULONG;
    LowCapacity   : ULONG;
    HighCapacity  : ULONG;
  end;
  {$EXTERNALSYM BATTERY_WAIT_STATUS}
  BATTERY_WAIT_STATUS = _BATTERY_WAIT_STATUS;
  {$EXTERNALSYM PBATTERY_WAIT_STATUS}
  PBATTERY_WAIT_STATUS = ^BATTERY_WAIT_STATUS;

  {$EXTERNALSYM _BATTERY_STATUS}
  _BATTERY_STATUS = packed record
    PowerState  : ULONG;
    Capacity    : ULONG;
    Voltage     : ULONG;
    Rate        : LONG;
  end;
  {$EXTERNALSYM BATTERY_STATUS}
  BATTERY_STATUS = _BATTERY_STATUS;
  {$EXTERNALSYM PBATTERY_STATUS}
  PBATTERY_STATUS = ^BATTERY_STATUS;

  {$EXTERNALSYM _BATTERY_MANUFACTURE_DATE}
  _BATTERY_MANUFACTURE_DATE = packed record
    Day   : UCHAR;
    Month : UCHAR;
    Year  : USHORT;
  end;
  {$EXTERNALSYM BATTERY_MANUFACTURE_DATE}
  BATTERY_MANUFACTURE_DATE = _BATTERY_MANUFACTURE_DATE;
  {$EXTERNALSYM PBATTERY_MANUFACTURE_DATE}
  PBATTERY_MANUFACTURE_DATE = ^BATTERY_MANUFACTURE_DATE;

implementation

end.
