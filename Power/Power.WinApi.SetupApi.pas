unit Power.WinApi.SetupApi;

interface

uses
  Winapi.Windows;

const
  SETUP_API = 'SetupApi.dll';

{*******************************************************}
{             SetupApi Win32 API type                   }
{*******************************************************}

const
  GUID_DEVCLASS_BATTERY : TGUID = '{72631e54-78a4-11d0-bcf7-00aa00b7b32a}';

  DIGCF_DEFAULT         = DWORD($00000001); // only valid with DIGCF_DEVICEINTERFACE
  DIGCF_PRESENT         = DWORD($00000002);
  DIGCF_ALLCLASSES      = DWORD($00000004);
  DIGCF_PROFILE         = DWORD($00000008);
  DIGCF_DEVICEINTERFACE = DWORD($00000010);

  SPINT_ACTIVE  = DWORD($00000001); // The interface is active (enabled).
  SPINT_DEFAULT = DWORD($00000002); // The interface is the default interface for the device class.
  SPINT_REMOVED = DWORD($00000004); // The interface is removed.

type
  {$EXTERNALSYM _SP_DEVICE_INTERFACE_DATA}
  _SP_DEVICE_INTERFACE_DATA = packed record
    cbSize              : DWORD;
    InterfaceClassGuid  : TGUID;
    Flags               : DWORD;
    Reserved            : ULONG_PTR;
  end;
  {$EXTERNALSYM SP_DEVICE_INTERFACE_DATA}
  SP_DEVICE_INTERFACE_DATA = _SP_DEVICE_INTERFACE_DATA;
  {$EXTERNALSYM PSP_DEVICE_INTERFACE_DATA}
  PSP_DEVICE_INTERFACE_DATA = ^SP_DEVICE_INTERFACE_DATA;

  {$EXTERNALSYM _SP_DEVICE_INTERFACE_DETAIL_DATA}
  _SP_DEVICE_INTERFACE_DETAIL_DATA = {$IFNDEF WIN64}packed{$ENDIF} record
    cbSize      : DWORD;
    DevicePath  : array [0..0] of Char;
  end;
  {$EXTERNALSYM SP_DEVICE_INTERFACE_DETAIL_DATA}
  SP_DEVICE_INTERFACE_DETAIL_DATA = _SP_DEVICE_INTERFACE_DETAIL_DATA;
  {$EXTERNALSYM PSP_DEVICE_INTERFACE_DETAIL_DATA}
  PSP_DEVICE_INTERFACE_DETAIL_DATA = ^SP_DEVICE_INTERFACE_DETAIL_DATA;

  {$EXTERNALSYM _SP_DEVINFO_DATA}
  _SP_DEVINFO_DATA = packed record
    cbSize    : DWORD;
    ClassGuid : TGUID;
    DevInst   : DWORD; // DEVINST handle
    Reserved  : ULONG_PTR;
  end;
  {$EXTERNALSYM SP_DEVINFO_DATA}
  SP_DEVINFO_DATA = _SP_DEVINFO_DATA;
  {$EXTERNALSYM PSP_DEVINFO_DATA}
  PSP_DEVINFO_DATA = ^SP_DEVINFO_DATA;

  {$EXTERNALSYM HDEVINFO}
  HDEVINFO = THandle;


{*******************************************************}
{             SetupApi Win32 API function               }
{*******************************************************}

{$EXTERNALSYM SetupDiGetClassDevs}
function SetupDiGetClassDevs(
  const ClassGuid: TGUID;
  Enumerator: LPCTSTR;
  hwndParent: HWND;
  Flags: DWORD): HDEVINFO; stdcall;

{$EXTERNALSYM SetupDiDestroyDeviceInfoList}
function SetupDiDestroyDeviceInfoList(
  DeviceInfoSet: HDEVINFO): BOOL; stdcall;

{$EXTERNALSYM SetupDiGetClassDevs}
function SetupDiEnumDeviceInterfaces(
  DeviceInfoSet: HDEVINFO;
  DeviceInfoData: PSP_DEVINFO_DATA;
  const InterfaceClassGuid: TGUID;
  MemberIndex: DWORD;
  out DeviceInterfaceData: SP_DEVICE_INTERFACE_DATA): BOOL; stdcall;

{$EXTERNALSYM SetupDiGetDeviceInterfaceDetail}
function SetupDiGetDeviceInterfaceDetail(
  DeviceInfoSet: HDEVINFO;
  DeviceInterfaceData: PSP_DEVICE_INTERFACE_DATA;
  DeviceInterfaceDetailData: PSP_DEVICE_INTERFACE_DETAIL_DATA;
  DeviceInterfaceDetailDataSize: DWORD;
  RequiredSize: PDWORD;
  DeviceInfoData: PSP_DEVINFO_DATA): BOOL; stdcall;

implementation

function SetupDiGetClassDevs; external SETUP_API
    {$IFDEF UNICODE} name 'SetupDiGetClassDevsW';
    {$ELSE} name 'SetupDiGetClassDevsA';{$ENDIF}

function SetupDiDestroyDeviceInfoList; external SETUP_API;

function SetupDiEnumDeviceInterfaces; external SETUP_API;

function SetupDiGetDeviceInterfaceDetail; external SETUP_API
    {$IFDEF UNICODE} name 'SetupDiGetDeviceInterfaceDetailW';
    {$ELSE} name 'SetupDiGetDeviceInterfaceDetailA';{$ENDIF}

end.
