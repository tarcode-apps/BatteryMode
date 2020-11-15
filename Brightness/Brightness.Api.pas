unit Brightness.Api;

interface

uses
  Winapi.Windows, Winapi.MultiMon;

const
  DXVA2 = 'Dxva2.dll';

  MC_CAPS_NONE                                           = $00000000;
  MC_CAPS_MONITOR_TECHNOLOGY_TYPE                        = $00000001;
  MC_CAPS_BRIGHTNESS                                     = $00000002;
  MC_CAPS_CONTRAST                                       = $00000004;
  MC_CAPS_COLOR_TEMPERATURE                              = $00000008;
  MC_CAPS_RED_GREEN_BLUE_GAIN                            = $00000010;
  MC_CAPS_RED_GREEN_BLUE_DRIVE                           = $00000020;
  MC_CAPS_DEGAUSS                                        = $00000040;
  MC_CAPS_DISPLAY_AREA_POSITION                          = $00000080;
  MC_CAPS_DISPLAY_AREA_SIZE                              = $00000100;
  MC_CAPS_RESTORE_FACTORY_DEFAULTS                       = $00000400;
  MC_CAPS_RESTORE_FACTORY_COLOR_DEFAULTS                 = $00000800;
  MC_RESTORE_FACTORY_DEFAULTS_ENABLES_MONITOR_SETTINGS   = $00001000;

  STATUS_SUCCESS = $00000000;

  PHYSICAL_MONITOR_DESCRIPTION_SIZE = 128;

type
  {$EXTERNALSYM NTSTATUS}
  NTSTATUS = HRESULT;

  {$EXTERNALSYM UNICODE_STRING}
  UNICODE_STRING = packed record
    Length: USHORT;
    MaximumLength: USHORT;
    Buffer: LPWSTR;
    constructor Create(Length: USHORT; MaximumLength: USHORT; Buffer: LPWSTR);
  end;

  {$EXTERNALSYM _PHYSICAL_MONITOR}
  _PHYSICAL_MONITOR = packed record
    hPhysicalMonitor: THandle;
    szPhysicalMonitorDescription: array [0..PHYSICAL_MONITOR_DESCRIPTION_SIZE - 1] of WCHAR;
  end;
  {$EXTERNALSYM PHYSICAL_MONITOR}
  PHYSICAL_MONITOR = _PHYSICAL_MONITOR;
  {$EXTERNALSYM LPPHYSICAL_MONITOR}
  LPPHYSICAL_MONITOR = ^PHYSICAL_MONITOR;

{$EXTERNALSYM GetNumberOfPhysicalMonitorsFromHMONITOR}
function GetNumberOfPhysicalMonitorsFromHMONITOR(
  hMonitor: HMONITOR;
  out pdwNumberOfPhysicalMonitors: DWORD): BOOL; stdcall;

{$EXTERNALSYM GetPhysicalMonitorsFromHMONITOR}
function GetPhysicalMonitorsFromHMONITOR(
  hMonitor: HMONITOR;
  dwPhysicalMonitorArraySize: DWORD;
  pPhysicalMonitorArray: LPPHYSICAL_MONITOR): BOOL; stdcall;

{$EXTERNALSYM GetMonitorCapabilities}
function GetMonitorCapabilities(
  hMonitor: THandle;
  out pdwMonitorCapabilities: DWORD;
  out pdwSupportedColorTemperatures: DWORD): BOOL; stdcall;

{$EXTERNALSYM GetMonitorBrightness}
function GetMonitorBrightness(
  hMonitor: THandle;
  out pdwMinimumBrightness: DWORD;
  out pdwCurrentBrightness: DWORD;
  out pdwMaximumBrightness: DWORD): BOOL; stdcall;

{$EXTERNALSYM SetMonitorBrightness}
function SetMonitorBrightness(
  hMonitor: THandle;
  dwNewBrightness: DWORD): BOOL; stdcall;

{$EXTERNALSYM DestroyPhysicalMonitors}
function DestroyPhysicalMonitors(
  dwPhysicalMonitorArraySize: DWORD;
  pPhysicalMonitorArray: LPPHYSICAL_MONITOR): BOOL; stdcall;

implementation

{ UNICODE_STRING }

constructor UNICODE_STRING.Create(Length, MaximumLength: USHORT;
  Buffer: LPWSTR);
begin
  Self.Length := Length;
  Self.MaximumLength := MaximumLength;
  Self.Buffer := Buffer;
end;

{$WARN SYMBOL_PLATFORM OFF}
function GetNumberOfPhysicalMonitorsFromHMONITOR; external DXVA2 delayed;
function GetPhysicalMonitorsFromHMONITOR; external DXVA2 delayed;
function GetMonitorCapabilities; external DXVA2 delayed;
function GetMonitorBrightness; external DXVA2 delayed;
function SetMonitorBrightness; external DXVA2 delayed;
function DestroyPhysicalMonitors; external DXVA2 delayed;
{$WARN SYMBOL_PLATFORM ON}

end.
