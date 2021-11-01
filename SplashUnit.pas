unit SplashUnit;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Classes,
  GdiPlus, ScreenLiteUnit;

type
  TSplashEnabling = procedure of object;
  TSplashDisabling = procedure of object;
  TGetRealImageSize = function: TSize of object;
  TGeneratePicture = function(Width, Height: Integer; Monitor: TMonitorLite): IGPBitmap of object;

  TSplash = class
  public type
    TSplashMonitorType = (smtPrimary, smtAll, smtCustom);
    TSplashMonitorConfig = record
      MonitorType: TSplashMonitorType;
      MonitorNum: Integer;
      constructor Create(MonitorType: TSplashMonitorType; MonitorNum: Integer = 0);
    end;
  private const
    nIDEvent = $100;
    SplashWndClassName = 'SplashWindowClass';
    SplashWndName = 'SplashWindow';
  private
    class var FEnable: Boolean;
    class var FInterval: Integer;
    class var FTransparency: Byte;
    class var FScaleByScreen: Cardinal;
    class var uIDEvent: UINT_PTR;
    class var FShowing: Boolean;
    class var wndAtom: ATOM;
    class var SplashWndClass: TWndClassEx;
    class var SplashWndArray: array of HWND;

    class var Screen: TScreenLite;

    class var FMonitorConfig: TSplashMonitorConfig;
    class procedure SetEnable(const Value: Boolean); static;
    class procedure SetMonitorConfig(const Value: TSplashMonitorConfig); static;

    class function BuildSplashWnd(const Name: string; MonitorNum: Integer;
      WindowClass: TWndClassEx): HWND;
    class procedure ReleaseSplashWnd(wnd: HWND);

    class function RegistegSplashClass(const ClassName: string;
      out WindowClass: TWndClassEx): ATOM;
    class procedure UnregistegSplashClass(WindowClass: TWndClassEx);

    class procedure TimerProc(wnd: HWND; uMsg: UINT; idEvent: UINT_PTR; dwTime: DWORD); stdcall; static;
    class function WindowProc(wnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT; stdcall; static;

    class procedure PaintPicture(wnd: HWND; MonitorNum: Integer);

    class function ConfigToMonitorCount(Config: TSplashMonitorConfig;
      RealMonitorCount: Integer): Integer;
    class procedure UpdateAllForm;
    class procedure ShowAllForm;
    class procedure HideAllForm;
    class procedure ReleaseAllForm;

    class constructor Create;
    class destructor Destroy;
  protected
    class var EnablingFunc: TSplashEnabling;
    class var DisablingFunc: TSplashDisabling;

    class var GetRealImageSizeFunc: TGetRealImageSize;
    class var GeneratePictureFunc: TGeneratePicture;

    class procedure ShowSplash;
    class procedure HideSplash;

    class property Enable: Boolean read FEnable write SetEnable;
    class property MonitorConfig: TSplashMonitorConfig read FMonitorConfig write SetMonitorConfig;
    class property Interval: Integer read FInterval write FInterval;
    class property Transparency: Byte read FTransparency write FTransparency;
    class property Showing: Boolean read FShowing;
    class property ScaleByScreen: Cardinal read FScaleByScreen write FScaleByScreen;
  end;

implementation

uses
  Winapi.ActiveX, Winapi.MultiMon,
  System.Types;

{ TSplashForm }

class procedure TSplash.SetEnable(const Value: Boolean);
begin
  if FEnable = Value then Exit;

  if Value then begin
    EnablingFunc;
    wndAtom := RegistegSplashClass(SplashWndClassName, SplashWndClass);
    FEnable := wndAtom <> 0;
  end else begin
    FEnable := False;
    HideAllForm;
    ReleaseAllForm;
    DisablingFunc;
    UnregistegSplashClass(SplashWndClass);
  end;
end;

class procedure TSplash.SetMonitorConfig(const Value: TSplashMonitorConfig);
begin
  FMonitorConfig := Value;

  if FShowing then
    ShowSplash;
end;

class procedure TSplash.ShowSplash;
begin
  if FEnable then begin
    UpdateAllForm;
    ShowAllForm;
  end;
end;

class procedure TSplash.HideSplash;
begin
  HideAllForm;
end;

class function TSplash.ConfigToMonitorCount(Config: TSplashMonitorConfig;
  RealMonitorCount: Integer): Integer;
begin
  case Config.MonitorType of
    smtPrimary: if RealMonitorCount > 0 then Result := 1 else Result := 0;
    smtAll: Result := RealMonitorCount;
    smtCustom:
      if Config.MonitorNum < RealMonitorCount then
        Result := Config.MonitorNum + 1
      else if RealMonitorCount > 0 then Result := 1 else Result := 0;
    else Result := 0;
  end;
end;

{$REGION 'UpdateAllForm'}
class procedure TSplash.UpdateAllForm;
var
  SplashCount: Integer;
  RealSplashCount: Integer;
  MonitorCount: Integer;
  MonitorNum: Integer;
  i: Integer;
begin
  Screen.Update;
  MonitorCount := Screen.MonitorCount;
  RealSplashCount := Length(SplashWndArray);
  SplashCount := ConfigToMonitorCount(FMonitorConfig, MonitorCount);

  // Нормализуем количество форм
  if RealSplashCount > SplashCount then begin
    for i := RealSplashCount - 1 to SplashCount do
      ReleaseSplashWnd(SplashWndArray[i]);

    SetLength(SplashWndArray, SplashCount);
  end else if RealSplashCount < SplashCount then begin
    SetLength(SplashWndArray, SplashCount);

    for i := RealSplashCount to SplashCount - 1 do
      SplashWndArray[i] := BuildSplashWnd(SplashWndName, i, SplashWndClass);
  end;

  // Обновляем картинки
  case FMonitorConfig.MonitorType of
    smtPrimary:
      begin
        MonitorNum := Screen.PrimaryMonitor.MonitorNum;
        for i := 0 to SplashCount - 1 do
          PaintPicture(SplashWndArray[i], MonitorNum);
      end;
    smtAll:
      begin
        for i := 0 to SplashCount - 1 do
          PaintPicture(SplashWndArray[i], i);
      end;
    smtCustom:
      begin
        if FMonitorConfig.MonitorNum < MonitorCount then
          MonitorNum := FMonitorConfig.MonitorNum
        else
          MonitorNum := Screen.PrimaryMonitor.MonitorNum;

        for i := 0 to SplashCount - 1 do
          PaintPicture(SplashWndArray[i], MonitorNum);
      end;
  end;
end;
{$ENDREGION}

{$REGION 'ShowAllForm'}
class procedure TSplash.ShowAllForm;
var
  i: Integer;
begin
  KillTimer(0, uIDEvent);

  // Активируем формы
  for i := 0 to High(SplashWndArray) do
    ShowWindow(SplashWndArray[i], SW_SHOWNOACTIVATE);

  FShowing := True;
  uIDEvent := SetTimer(0, nIDEvent, FInterval, @TimerProc);
end;
{$ENDREGION}

{$REGION 'HideAllForm'}
class procedure TSplash.HideAllForm;
var
  i: Integer;
begin
  KillTimer(0, uIDEvent);

  for i := 0 to High(SplashWndArray) do
    ShowWindow(SplashWndArray[i], SW_HIDE);

  FShowing := False;
end;
{$ENDREGION}

{$REGION 'ReleaseAllForm'}
class procedure TSplash.ReleaseAllForm;
var
  i: Integer;
begin
  for i := 0 to High(SplashWndArray) do
    ReleaseSplashWnd(SplashWndArray[i]);

  SetLength(SplashWndArray, 0);
end;
{$ENDREGION}

class function TSplash.BuildSplashWnd(const Name: string; MonitorNum: Integer;
  WindowClass: TWndClassEx): HWND;
begin
  Result := CreateWindowEx(WS_EX_TOPMOST or WS_EX_NOACTIVATE or WS_EX_LAYERED,
    WindowClass.lpszClassName, LPTSTR(Name + MonitorNum.ToString),
    WS_POPUP or WS_DISABLED,
    0, 0, 0, 0, 0, 0, HInstance, nil);

    if Result <> 0 then
      SetWindowLong(Result, GWL_STYLE, NativeInt(WS_POPUP or WS_DISABLED));
end;

class procedure TSplash.ReleaseSplashWnd(wnd: HWND);
begin
  DestroyWindow(wnd);
end;

class function TSplash.RegistegSplashClass(const ClassName: string;
  out WindowClass: TWndClassEx): ATOM;
var
  WindowClassName: string;
  WindowClassSize: NativeInt;
begin
  WindowClass.cbSize := SizeOf(WindowClass);
  WindowClass.style := CS_HREDRAW or CS_VREDRAW;
  WindowClass.lpfnWndProc := @WindowProc;
  WindowClass.cbClsExtra := 0;
  WindowClass.cbWndExtra := 0;
  WindowClass.hInstance := HInstance;
  WindowClass.hIcon := 0;
  WindowClass.hCursor := LoadCursor(0, IDC_ARROW);
  WindowClass.hbrBackground := 0;
  WindowClass.lpszMenuName := nil;

  WindowClassName := ClassName + TGUID.NewGuid.ToString;
  WindowClassSize := Length(WindowClassName)*SizeOf(Char);
  WindowClass.lpszClassName := GetMemory(WindowClassSize);
  CopyMemory(WindowClass.lpszClassName, @WindowClassName, WindowClassSize);

  Result := RegisterClassEx(WindowClass);
end;

class procedure TSplash.UnregistegSplashClass(WindowClass: TWndClassEx);
begin
  Winapi.Windows.UnregisterClass(WindowClass.lpszClassName, HInstance);
  DestroyCursor(WindowClass.hCursor);
  FreeMemory(WindowClass.lpszClassName);
end;

class function TSplash.WindowProc(wnd: HWND; Msg: UINT; wParam: WPARAM; lParam: LPARAM): LRESULT;
begin
  case Msg of
    WM_DESTROY: begin
      Exit(0);
    end;
    WM_NCHITTEST: Exit(HTNOWHERE);
    WM_ACTIVATE: begin
        if (wParam = WA_ACTIVE) or (wParam = WA_CLICKACTIVE)then
          SetWindowPos(wnd, HWND_TOPMOST, 0, 0, 0, 0, SWP_ASYNCWINDOWPOS or
                                                    SWP_NOACTIVATE or
                                                    SWP_NOSIZE or
                                                    SWP_NOMOVE or
                                                    SWP_NOSENDCHANGING);
        Exit(0);
      end;
    else Result := DefWindowProc(wnd, Msg, wParam, lParam);
  end;
end;

class procedure TSplash.TimerProc(wnd: HWND; uMsg: UINT; idEvent: UINT_PTR;
  dwTime: DWORD);
begin
  if idEvent <> uIDEvent then Exit;

  HideAllForm;
end;

{$REGION 'PaintPicture'}
class procedure TSplash.PaintPicture(wnd: HWND; MonitorNum: Integer);
var
  Bitmap: IGPBitmap;
  RealImageSize: TSize;

  ScreenWidth, ScreenHeight: Cardinal;

  ScreenDC, BackDC: HDC;
  hBmp: HBITMAP;
  ptDst, ptSrc: TPoint;
  FormSize: TSize;
  BlendFunction: TBlendFunction;

  Width: Integer;
  Height: Integer;
  Left: Integer;
  Top: Integer;
begin
  ScreenDC := GetDC(0);
  BackDC := CreateCompatibleDC(ScreenDC);

  ScreenWidth := Screen.Monitors[MonitorNum].Width;
  ScreenHeight := Screen.Monitors[MonitorNum].Height;
  RealImageSize := GetRealImageSizeFunc;
  if ScreenWidth > ScreenHeight then begin
    Width :=  ScreenWidth div FScaleByScreen;
    Height := RealImageSize.cy * Width div RealImageSize.cx;
  end else begin
    Width :=  ScreenHeight div FScaleByScreen;
    Height := RealImageSize.cy * Width div RealImageSize.cx;
  end;
  Left := Screen.Monitors[MonitorNum].WorkareaRect.Left +
    ((Screen.Monitors[MonitorNum].WorkareaRect.Width - Width) div 2);
  Top :=  Screen.Monitors[MonitorNum].WorkareaRect.Top +
    ((Screen.Monitors[MonitorNum].WorkareaRect.Height - Height) div 2);

  Bitmap := GeneratePictureFunc(Width, Height, Screen.Monitors[MonitorNum]);

  hBmp := BitMap.GetHBITMAP(TGPColor.AlphaMask);
  SelectObject(BackDC, hBmp);

  ptDst.Create(Left, Top);
  ptSrc.Create(0, 0);
  FormSize.Create(Width, Height);

  BlendFunction.BlendOp := AC_SRC_OVER;
  BlendFunction.BlendFlags := 0;
  BlendFunction.SourceConstantAlpha := $FF - FTransparency;
  BlendFunction.AlphaFormat := AC_SRC_ALPHA;

  SetWindowPos(wnd, HWND_TOPMOST, 0, 0, Width, Height,
    SWP_NOACTIVATE or SWP_NOREDRAW or SWP_NOMOVE);

  UpdateLayeredWindow(wnd, ScreenDC, @ptDst, @FormSize, BackDC, @ptSrc,
    TGPColor.AlphaMask, @BlendFunction, ULW_ALPHA);

  ReleaseDC(0, ScreenDC);
  DeleteDC(BackDC);
  DeleteObject(hBmp);
end;
{$ENDREGION}

class constructor TSplash.Create;
begin
  SetLength(SplashWndArray, 0);
  FEnable := False;
  FMonitorConfig.Create(smtPrimary);
  FInterval := 1500;
  FTransparency := 0;
  FScaleByScreen := 5;
  FShowing := False;
  Screen := TScreenLite.Create;
end;

class destructor TSplash.Destroy;
begin
  Screen.Free;
  Enable := False;
end;

{ TSplash.TSplashMonitorConfig }

constructor TSplash.TSplashMonitorConfig.Create(
  MonitorType: TSplashMonitorType; MonitorNum: Integer);
begin
  Self.MonitorType := MonitorType;
  Self.MonitorNum := MonitorNum;
end;

end.
