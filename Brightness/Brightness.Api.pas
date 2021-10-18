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

  DISPLAY_DEVICE_ACTIVE = 1;

  QDC_ALL_PATHS = 1;
  DISPLAYCONFIG_MODE_INFO_TYPE_SOURCE = 1;
  DISPLAYCONFIG_MODE_INFO_TYPE_TARGET = 2;

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

  {$MinEnumSize 4}
  DISPLAYCONFIG_DEVICE_INFO_TYPE = (
    DISPLAYCONFIG_DEVICE_INFO_GET_SOURCE_NAME = 1,
    DISPLAYCONFIG_DEVICE_INFO_GET_TARGET_NAME,
    DISPLAYCONFIG_DEVICE_INFO_GET_TARGET_PREFERRED_MODE,
    DISPLAYCONFIG_DEVICE_INFO_GET_ADAPTER_NAME,
    DISPLAYCONFIG_DEVICE_INFO_SET_TARGET_PERSISTENCE,
    DISPLAYCONFIG_DEVICE_INFO_GET_TARGET_BASE_TYPE,
    DISPLAYCONFIG_DEVICE_INFO_GET_SUPPORT_VIRTUAL_RESOLUTION,
    DISPLAYCONFIG_DEVICE_INFO_SET_SUPPORT_VIRTUAL_RESOLUTION,
    DISPLAYCONFIG_DEVICE_INFO_GET_ADVANCED_COLOR_INFO,
    DISPLAYCONFIG_DEVICE_INFO_SET_ADVANCED_COLOR_STATE,
    DISPLAYCONFIG_DEVICE_INFO_GET_SDR_WHITE_LEVEL,
    DISPLAYCONFIG_DEVICE_INFO_GET_MONITOR_SPECIALIZATION,
    DISPLAYCONFIG_DEVICE_INFO_SET_MONITOR_SPECIALIZATION,
    DISPLAYCONFIG_DEVICE_INFO_FORCE_UINT32
  );

  DISPLAYCONFIG_TARGET_DEVICE_NAME_FLAGS =   UINT32;
  DISPLAYCONFIG_VIDEO_OUTPUT_TECHNOLOGY =    UINT32;
  DISPLAYCONFIG_ROTATION =                   UINT32;
  DISPLAYCONFIG_SCALING =                    UINT32;
  DISPLAYCONFIG_SCANLINE_ORDERING =          UINT32;
  DISPLAYCONFIG_MODE_INFO_TYPE =             UINT32;
  DISPLAYCONFIG_PIXELFORMAT =                UINT32;
  DISPLAYCONFIG_TOPOLOGY_ID =                UINT32;

  PDISPLAYCONFIG_TOPOLOGY_ID = ^DISPLAYCONFIG_TOPOLOGY_ID;

  DISPLAYCONFIG_PATH_SOURCE_INFO= packed record
    adapterId: LUID;
    id: UINT32;
    modeInfoIdx: UINT32;
    statusFlags: UINT32;
  end;

  DISPLAYCONFIG_RATIONAL= packed record
    Numerator: UINT32;
    Denominator: UINT32;
  end;

  DISPLAYCONFIG_PATH_TARGET_INFO = packed record
    adapterId: LUID;
    id: UINT32;
    modeInfoIdx: UINT32;
    outputTechnology: DISPLAYCONFIG_VIDEO_OUTPUT_TECHNOLOGY;
    rotation: DISPLAYCONFIG_ROTATION;
    scaling: DISPLAYCONFIG_SCALING;
    refreshRate: DISPLAYCONFIG_RATIONAL;
    scanLineOrdering: DISPLAYCONFIG_SCANLINE_ORDERING;
    targetAvailable: BOOL;
    statusFlags: UINT32;
  end;

  DISPLAYCONFIG_PATH_INFO = packed record
    sourceInfo: DISPLAYCONFIG_PATH_SOURCE_INFO;
    targetInfo: DISPLAYCONFIG_PATH_TARGET_INFO;
    flags: UINT32;
  end;
  PDISPLAYCONFIG_PATH_INFO = ^DISPLAYCONFIG_PATH_INFO;

  DISPLAYCONFIG_2DREGION = packed record
    cx: UINT32;
    cy: UINT32;
  end;

  DISPLAYCONFIG_VIDEO_SIGNAL_INFO = packed record
    pixelRate: UInt64;
    hSyncFreq, vSyncFreq: DISPLAYCONFIG_RATIONAL;
    activeSize, totalSize: DISPLAYCONFIG_2DREGION;
    videoStandard: UINT32;
  end;

  DISPLAYCONFIG_TARGET_MODE = packed record
    targetVideoSignalInfo: DISPLAYCONFIG_VIDEO_SIGNAL_INFO;
  end;

  DISPLAYCONFIG_SOURCE_MODE= packed record
    width: UINT32;
    height: UINT32;
    pixelFormat: DISPLAYCONFIG_PIXELFORMAT;
    position: TPointL;
  end;

  RECTL = packed record
    left: LONG;
    top: LONG;
    right: LONG;
    bottom: LONG;
  end;

  DISPLAYCONFIG_DESKTOP_IMAGE_INFO = packed record
    PathSourceSize: TPointL;
    DesktopImageRegion, DesktopImageClip: RECTL;
  end;

  DISPLAYCONFIG_MODE_INFO = packed record
    infoType: DISPLAYCONFIG_MODE_INFO_TYPE;
    id: UINT32;
    adapterId: LUID;
    case Byte of
    1: (targetMode: DISPLAYCONFIG_TARGET_MODE);
    2: (sourceMode: DISPLAYCONFIG_SOURCE_MODE);
    3: (desktopImageInfo: DISPLAYCONFIG_DESKTOP_IMAGE_INFO);
  end;
  PDISPLAYCONFIG_MODE_INFO = ^DISPLAYCONFIG_MODE_INFO;

  DISPLAYCONFIG_DEVICE_INFO_HEADER = packed record
    typ: DISPLAYCONFIG_DEVICE_INFO_TYPE;
    size: UINT32;
    adapterId: LUID;
    id: UINT32;
  end;
  PDISPLAYCONFIG_DEVICE_INFO_HEADER = ^DISPLAYCONFIG_DEVICE_INFO_HEADER;

  DISPLAYCONFIG_TARGET_DEVICE_NAME = packed record
    header: DISPLAYCONFIG_DEVICE_INFO_HEADER;
    flags: DISPLAYCONFIG_TARGET_DEVICE_NAME_FLAGS;
    outputTechnology: DISPLAYCONFIG_VIDEO_OUTPUT_TECHNOLOGY;
    edidManufactureId, edidProductCodeId: Word;
    connectorInstance: UINT32;
    monitorFriendlyDeviceName: array[0.. 63] of WideChar;
    monitorDevicePath: array[0.. 127] of WideChar;
  end;

  DISPLAYCONFIG_ADAPTER_NAME = packed record
    header: DISPLAYCONFIG_DEVICE_INFO_HEADER;
    adapterDevicePath: array[0 .. 127] of WCHAR;
  end;

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

{$EXTERNALSYM GetDisplayConfigBufferSizes}
function GetDisplayConfigBufferSizes(
  flags: UINT32;
  out numPathArrayElements: UINT32;
  out numModeInfoArrayElements: UINT32): LONG; stdcall; // Vista

{$EXTERNALSYM QueryDisplayConfig}
function QueryDisplayConfig(
  flags: UINT32;
  var numPathArrayElements: UINT32;
  pathArray: PDISPLAYCONFIG_PATH_INFO;
  var numModeInfoArrayElements: UINT32;
  modeInfoArray: PDISPLAYCONFIG_MODE_INFO;
  currentTopologyId: PDISPLAYCONFIG_TOPOLOGY_ID): LONG; stdcall; // Windows 7

{$EXTERNALSYM DisplayConfigGetDeviceInfo}
function DisplayConfigGetDeviceInfo(
  requestPacket: PDISPLAYCONFIG_DEVICE_INFO_HEADER): LONG; stdcall;  // Vista

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
function GetDisplayConfigBufferSizes; external user32 delayed;
function QueryDisplayConfig; external user32 delayed;
function DisplayConfigGetDeviceInfo; external user32 delayed;
{$WARN SYMBOL_PLATFORM ON}

end.
