unit ScreenLiteUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.MultiMon,
  System.SysUtils, System.Classes, System.Generics.Collections;

const
  WM_DPICHANGED = $02E0;
  Shcore = 'Shcore.dll';

type
  TWMDPIChanged = record
    Msg: Cardinal;
    MsgFiller: TDWordFiller;
    case Integer of
      0: (XDpi: Smallint;
          YDpi: Smallint;
          NewWindowRect: PRect;
          Result: LRESULT);
      1: (Dpi: TSmallPoint);
  end;

type
  {$MinEnumSize 4}
  _Monitor_DPI_Type = (
    MDT_Effective_DPI  = 0,
    MDT_Angular_DPI    = 1,
    MDT_Raw_DPI        = 2,
    MDT_Default        = MDT_Effective_DPI
  );
  Monitor_DPI_Type = _Monitor_DPI_Type;

  { TMonitor }

  TMonitorLite = record
  private
    FHandle: HMONITOR;
    FMonitorNum: Integer;
    function GetLeft: Integer;
    function GetHeight: Integer;
    function GetTop: Integer;
    function GetWidth: Integer;
    function GetBoundsRect: TRect;
    function GetWorkareaRect: TRect;
    function GetPrimary: Boolean;
    function GetDpi: TPoint;
  public
    constructor Create(Handle: HMONITOR; MonitorNum: Integer);

    function PixelToDpi(Pixel: Integer): Integer;
    function PixelFontToDpi(Pixel: Integer): Integer;

    property Handle: HMONITOR read FHandle;
    property MonitorNum: Integer read FMonitorNum;
    property Left: Integer read GetLeft;
    property Height: Integer read GetHeight;
    property Top: Integer read GetTop;
    property Width: Integer read GetWidth;
    property BoundsRect: TRect read GetBoundsRect;
    property WorkareaRect: TRect read GetWorkareaRect;
    property Primary: Boolean read GetPrimary;
    property Dpi: TPoint read GetDpi;
  end;

  { TScreen }

  TMonitorDefaultTo = (mdNearest, mdNull, mdPrimary);

  TScreenLite = class
  private
    FPixelsPerInch: TPoint;
    FMonitors: TList<TMonitorLite>;

    class function EnumMonitorsProc(hm: HMONITOR; dc: HDC; r: PRect; Data: LPARAM): BOOL; stdcall; static;

    function GetDesktopTop: Integer;
    function GetDesktopLeft: Integer;
    function GetDesktopHeight: Integer;
    function GetDesktopWidth: Integer;
    function GetDesktopRect: TRect;

    function GetWorkAreaTop: Integer;
    function GetWorkAreaLeft: Integer;
    function GetWorkAreaHeight: Integer;
    function GetWorkAreaWidth: Integer;
    function GetWorkAreaRect: TRect;

    function GetHeight: Integer;
    function GetWidth: Integer;

    function GetMonitor(Index: Integer): TMonitorLite;
    function GetMonitorCount: Integer;


    function GetPrimaryMonitor: TMonitorLite;
    procedure ClearMonitors;
    procedure UpdateMonitors;
  public
    constructor Create;
    destructor Destroy; override;

    procedure Update;

    function PixelToDpi(Pixel: Integer): Integer;
    function PixelFontToDpi(Pixel: Integer): Integer;

    property DesktopTop: Integer read GetDesktopTop;
    property DesktopLeft: Integer read GetDesktopLeft;
    property DesktopHeight: Integer read GetDesktopHeight;
    property DesktopWidth: Integer read GetDesktopWidth;
    property DesktopRect: TRect read GetDesktopRect;

    property WorkAreaTop: Integer read GetWorkAreaTop;
    property WorkAreaLeft: Integer read GetWorkAreaLeft;
    property WorkAreaHeight: Integer read GetWorkAreaHeight;
    property WorkAreaWidth: Integer read GetWorkAreaWidth;
    property WorkAreaRect: TRect read GetWorkAreaRect;

    property Height: Integer read GetHeight;
    property Width: Integer read GetWidth;

    property PixelsPerInch: TPoint read FPixelsPerInch;

    property Monitors[Index: Integer]: TMonitorLite read GetMonitor;
    property MonitorCount: Integer read GetMonitorCount;
    function FindMonitor(Handle: HMONITOR): TMonitorLite;
    function FindWindowMonitor(Handle: THandle): TMonitorLite;
    property PrimaryMonitor: TMonitorLite read GetPrimaryMonitor;
  end;

TGetDpiForMonitorFn = function(hmonitor: HMONITOR;
  dpiType: MONITOR_DPI_TYPE;
  out dpiX: UINT;
  out dpiY: UINT): HRESULT; stdcall;

implementation

{ TScreenLite }

constructor TScreenLite.Create;
begin
  FMonitors := TList<TMonitorLite>.Create;
  Update;
end;

destructor TScreenLite.Destroy;
begin
  FreeAndNil(FMonitors);
  inherited;
end;

procedure TScreenLite.Update;
begin
  UpdateMonitors;
  FPixelsPerInch := PrimaryMonitor.Dpi;
end;


class function TScreenLite.EnumMonitorsProc(hm: HMONITOR; dc: HDC; r: PRect; Data: LPARAM): BOOL; stdcall;
var
  M: TMonitorLite;
  FList: TList<TMonitorLite>;
begin
  FList := TList<TMonitorLite>(Data);
  M := TMonitorLite.Create(hm, FList.Count);
  FList.Add(M);
  Result := True;
end;


function TScreenLite.GetDesktopTop: Integer;
begin
  Result := GetSystemMetrics(SM_YVIRTUALSCREEN);
end;

function TScreenLite.GetDesktopLeft: Integer;
begin
  Result := GetSystemMetrics(SM_XVIRTUALSCREEN);
end;

function TScreenLite.GetDesktopHeight: Integer;
begin
  Result := GetSystemMetrics(SM_CYVIRTUALSCREEN);
end;

function TScreenLite.GetDesktopWidth: Integer;
begin
  Result := GetSystemMetrics(SM_CXVIRTUALSCREEN);
end;

function TScreenLite.GetDesktopRect: TRect;
begin
  Result := Bounds(DesktopLeft, DesktopTop, DesktopWidth, DesktopHeight);
end;

function TScreenLite.GetWorkAreaTop: Integer;
begin
  Result := WorkAreaRect.Top;
end;

function TScreenLite.GetWorkAreaLeft: Integer;
begin
  Result := WorkAreaRect.Left;
end;

function TScreenLite.GetWorkAreaHeight: Integer;
begin
  with WorkAreaRect do
    Result := Bottom - Top;
end;

function TScreenLite.GetWorkAreaWidth: Integer;
begin
  with WorkAreaRect do
    Result := Right - Left;
end;

function TScreenLite.PixelToDpi(Pixel: Integer): Integer;
begin
  Result := MulDiv(Pixel, PixelsPerInch.Y, 96);
end;

function TScreenLite.PixelFontToDpi(Pixel: Integer): Integer;
begin
  Result := MulDiv(Pixel, PixelsPerInch.Y, 72);
end;

function TScreenLite.GetWorkAreaRect: TRect;
begin
  SystemParametersInfo(SPI_GETWORKAREA, 0, Result, 0);
end;

function TScreenLite.GetHeight: Integer;
begin
  Result := GetSystemMetrics(SM_CYSCREEN);
end;

function TScreenLite.GetWidth: Integer;
begin
  Result := GetSystemMetrics(SM_CXSCREEN);
end;

function TScreenLite.GetMonitor(Index: Integer): TMonitorLite;
begin
  Result := FMonitors[Index];
end;

function TScreenLite.GetMonitorCount: Integer;
begin
  Result := FMonitors.Count;
end;

function TScreenLite.FindMonitor(Handle: HMONITOR): TMonitorLite;
  function DoFindMonitor: TMonitorLite;
  var
    I: Integer;
  begin
    for I := 0 to MonitorCount - 1 do
      if Monitors[I].Handle = Handle then Exit(Monitors[I]);
    Result.Create(HMONITOR(-1), 0);
  end;
begin
  Result := DoFindMonitor;
  if Result.Handle = HMONITOR(-1) then begin
    UpdateMonitors;
    Result := DoFindMonitor;
  end;
end;

function TScreenLite.FindWindowMonitor(Handle: THandle): TMonitorLite;
begin
  Result := FindMonitor(MonitorFromWindow(Handle, MONITOR_DEFAULTTONEAREST));
end;

function TScreenLite.GetPrimaryMonitor: TMonitorLite;
  function DoGetPrimaryMonitor: TMonitorLite;
  var
    I: Integer;
  begin
    for I := 0 to MonitorCount - 1 do
      if Monitors[I].Primary then Exit(Monitors[I]);
    Result.Create(HMONITOR(-1), 0);
  end;
begin
  Result := DoGetPrimaryMonitor;
  if Result.Handle = HMONITOR(-1) then begin
    UpdateMonitors;
    Result := DoGetPrimaryMonitor;
  end;
end;

procedure TScreenLite.ClearMonitors;
begin
  FMonitors.Clear;
end;

procedure TScreenLite.UpdateMonitors;
begin
  ClearMonitors;
  EnumDisplayMonitors(0, nil, @EnumMonitorsProc, Winapi.Windows.LPARAM(FMonitors));
end;



{ TMonitor }

constructor TMonitorLite.Create(Handle: HMONITOR; MonitorNum: Integer);
begin
  FHandle := Handle;
  FMonitorNum := MonitorNum;
end;

function TMonitorLite.PixelToDpi(Pixel: Integer): Integer;
begin
  Result := MulDiv(Pixel, Dpi.Y, 96);
end;

function TMonitorLite.PixelFontToDpi(Pixel: Integer): Integer;
begin
  Result := MulDiv(Pixel, Dpi.Y, 72);
end;

function TMonitorLite.GetLeft: Integer;
begin
  Result := BoundsRect.Left;
end;

function TMonitorLite.GetHeight: Integer;
begin
  with BoundsRect do
    Result := Bottom - Top;
end;

function TMonitorLite.GetTop: Integer;
begin
  Result := BoundsRect.Top;
end;

function TMonitorLite.GetWidth: Integer;
begin
  with BoundsRect do
    Result := Right - Left;
end;

function TMonitorLite.GetBoundsRect: TRect;
var
  MonInfo: TMonitorInfo;
begin
  MonInfo.cbSize := SizeOf(MonInfo);
  GetMonitorInfo(FHandle, @MonInfo);
  Result := MonInfo.rcMonitor;
end;

function TMonitorLite.GetWorkareaRect: TRect;
var
  MonInfo: TMonitorInfo;
begin
  MonInfo.cbSize := SizeOf(MonInfo);
  GetMonitorInfo(FHandle, @MonInfo);
  Result := MonInfo.rcWork;
end;

function TMonitorLite.GetPrimary: Boolean;
var
  MonInfo: TMonitorInfo;
begin
  MonInfo.cbSize := SizeOf(MonInfo);
  GetMonitorInfo(FHandle, @MonInfo);
  Result := (MonInfo.dwFlags and MONITORINFOF_PRIMARY) <> 0;
end;

function TMonitorLite.GetDpi: TPoint;
var
  Lib: HMODULE;
  GetDpiForMonitorFn: TGetDpiForMonitorFn;
  DpiX: UINT;
  DpiY: UINT;

  function GetDeviceCapsDpi: TPoint;
  var
    DC: HDC;
  begin
    DC := GetDC(0);
    if DC <> 0 then begin
      Result.X := GetDeviceCaps(DC, LOGPIXELSX);
      Result.Y := GetDeviceCaps(DC, LOGPIXELSY);
      ReleaseDC(0, DC);
    end else
      Result.Create(96, 96);
  end;
begin
  Lib := LoadLibrary(Shcore);
  if Lib = 0 then Exit(GetDeviceCapsDpi);

  try
    GetDpiForMonitorFn := GetProcAddress(Lib, 'GetDpiForMonitor');
    if not Assigned(GetDpiForMonitorFn) then Exit(GetDeviceCapsDpi);

    if GetDpiForMonitorFn(FHandle, MDT_Default, DpiX, DpiY) <> S_OK then
      Exit(GetDeviceCapsDpi);

    Result.Create(DpiX, DpiY);
  finally
    FreeLibrary(Lib);
  end;
end;

end.
