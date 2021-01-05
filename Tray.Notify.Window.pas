unit Tray.Notify.Window;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes, System.Types,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms,
  Core.UI.Controls, Core.UI.Notifications,
  Tray.Icon, Tray.Helpers, Tray.Icon.Notifications,
  Versions.Helpers;

type
  TSystemBorder = (sbDisable, sbDefault, sbWithoutBorder);
  TSystemBorderChangedEvent = procedure(Sender: TObject; SystemBorder: TSystemBorder) of object;

  TTrayNotifyWindow = class(TCompatibleForm)
  strict private const
    MSGFLT_ALLOW = 1;
    MSGFLT_DISALLOW = 2;
    MSGFLT_RESET = 0;

    TimerReposition = 1;
    TimerLoadIcon = 2;
  protected type
    tagCHANGEFILTERSTRUCT = record
      cbSize: DWORD;
      ExtStatus: DWORD;
    end;
    CHANGEFILTERSTRUCT = tagCHANGEFILTERSTRUCT;
    PCHANGEFILTERSTRUCT = ^CHANGEFILTERSTRUCT;

    TChangeWindowMessageFilterEx = function (Wnd: HWND; Msg: UINT; action: DWORD;
          pChangeFilterStruct: PCHANGEFILTERSTRUCT): BOOL; stdcall;
  strict private
    TickCountDeactivate: DWORD;
    FTrayIcon: TTrayIcon;
    FTrayNotification: INotification;
    FAeroEnabled: Boolean;
    FWindows10OrGreater: Boolean;
    FShowFirst: Boolean;
    FShowFix: Boolean;
    FPanelHeader: TPanel;
    FSystemBorder: TSystemBorder;
    FOnSystemBorderChanged: TSystemBorderChangedEvent;
    FIsLockedOpened: Boolean;

    procedure FormReposition(IconRect: TRect; AeroEnabled: Boolean);
    procedure InterfaceBuild;
    function PixelToDpi(Pixel: Integer): Integer;

    procedure TrayIconClick(Sender: TObject);
    procedure SetSystemBorder(const Value: TSystemBorder);
    procedure SetOnSystemBorderChanged(const Value: TSystemBorderChangedEvent);
  protected
    function IsAeroEnabled: Boolean;

    procedure WMNCHitTest(var Msg: TWMNCHitTest); message WM_NCHITTEST;
    procedure WMActivate (var Msg: TMessage);  message WM_ACTIVATE;
    procedure WMDisplayChange(var Msg: TWMDisplayChange); message WM_DISPLAYCHANGE;
    procedure WMDWMCompositionChanged(var Msg: TMessage); message WM_DWMCOMPOSITIONCHANGED;
    procedure WMSize(var Msg: TWMSize); message WM_SIZE;
    procedure WMShowWindow(var Msg: TWMShowWindow); message WM_SHOWWINDOW;
    procedure WMDpiChanged(var Message: TMessage); message WM_DPICHANGED;
    procedure WMTimer(var Message: TWMTimer); message WM_TIMER;

    procedure DoCreate; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyPress(var Key: Char); override;

    procedure LoadIcon; virtual; abstract;
    procedure DoSystemBorderChanged(var SystemBorder: TSystemBorder); virtual;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure Reposition;
    procedure LockOpened;
    procedure UnlockAndClose;

    property TrayIcon: TTrayIcon read FTrayIcon;
    property TrayNotification: INotification read FTrayNotification;
    property PanelHeader: TPanel read FPanelHeader;
    property SystemBorder: TSystemBorder read FSystemBorder write SetSystemBorder;

    property OnSystemBorderChanged: TSystemBorderChangedEvent read FOnSystemBorderChanged write SetOnSystemBorderChanged;
  end;

implementation

uses
  Winapi.MultiMon;

{ TTrayNotifyWindow }

constructor TTrayNotifyWindow.Create(AOwner: TComponent);
var
  Lib: HMODULE;
  ChangeWindowMessageFilterEx: TChangeWindowMessageFilterEx;
begin
  inherited;

  FWindows10OrGreater := IsWindows10OrGreater;
  FShowFirst := True;
  FShowFix := False;
  FSystemBorder := sbDefault;
  FIsLockedOpened := False;

  FPanelHeader := TPanel.Create(Self);
  with FPanelHeader do
  begin
    Align := alTop;
    BevelOuter := bvNone;
    Height := 3;
    ParentColor := True;
    Parent := Self;
    ShowCaption := False;
  end;

  FTrayIcon := TTrayIcon.Create(Self);
  FTrayIcon.OnClick := TrayIconClick;
  FTrayIcon.Icon := Application.Icon.Handle;

  FTrayNotification := TTrayNotificationManager.Create(FTrayIcon);

  Lib := LoadLibrary(user32);
  if Lib <> 0 then begin
    ChangeWindowMessageFilterEx := GetProcAddress(Lib, 'ChangeWindowMessageFilterEx');
    if Assigned(ChangeWindowMessageFilterEx) then begin
      ChangeWindowMessageFilterEx(Handle, WM_SHOWWINDOW, MSGFLT_ALLOW, nil);
      ChangeWindowMessageFilterEx(Handle, WM_ACTIVATE, MSGFLT_ALLOW, nil);
    end;
    FreeLibrary(Lib);
  end;

  InterfaceBuild;
end;

destructor TTrayNotifyWindow.Destroy;
begin
  FIsLockedOpened := False;
  FPanelHeader.Free;
  FTrayIcon.Free;
  inherited;
end;

procedure TTrayNotifyWindow.DoCreate;
begin
  inherited;

  SendMessage(Handle, WM_UPDATEUISTATE, MakeWParam(UIS_SET, UISF_HIDEFOCUS), 0);

  FPanelHeader.Top := 0;
  FPanelHeader.TabOrder := 0;

  DoSystemBorderChanged(FSystemBorder);

  // Перемещение окна к иконке в трее
  Reposition;
end;

procedure TTrayNotifyWindow.FormReposition(IconRect: TRect;
  AeroEnabled: Boolean);
var
  Spacing: TRect;

  WorkArea, TaskBar: TRect;
  Point: TPoint;
  MonInfo: TMonitorInfo;
begin
  case SystemBorder of
    sbDisable:
      Spacing.Create(0, 0, 0, 0);
    sbWithoutBorder:
      begin
        if AeroEnabled then
          Spacing.Create(PixelToDpi(8), PixelToDpi(8), PixelToDpi(8), PixelToDpi(8))
        else
          Spacing.Create(0, 0, 0, 0);
      end
    else
    begin
      if AeroEnabled and IsWindows10OrGreater then
        Spacing.Create(0, PixelToDpi(8), 0, 0)
      else if AeroEnabled then
        Spacing.Create(PixelToDpi(8), PixelToDpi(8), PixelToDpi(8), PixelToDpi(8))
      else
        Spacing.Create(0, 0, 0, 0);
    end;
  end;

  if IconRect.IsEmpty then
    Point := Mouse.CursorPos
  else
    Point := IconRect.CenterPoint;

  MonInfo.cbSize := SizeOf(TMonitorInfo);
  GetMonitorInfo(MonitorFromPoint(Point, MONITOR_DEFAULTTONEAREST), @MonInfo);
  WorkArea := MonInfo.rcWork;
  if IsTaskbarAutoHideOn then begin
    TaskBar := GetTaskbarPos;
    // ---X---
    if TaskBar.Left > WorkArea.Left then begin
      // Справа
      if (TaskBar.Left < WorkArea.Right) and
         (TaskBar.Left > WorkArea.Left) then
        WorkArea.Right := TaskBar.Left;
    end else begin
      // Слева
      if (TaskBar.Right > WorkArea.Left) and
         (TaskBar.Right < WorkArea.Right) then
        WorkArea.Left := TaskBar.Right;
    end;

    // ---Y---
    if TaskBar.Top > WorkArea.Top then begin
      // Внизу
      if (TaskBar.Top < WorkArea.Bottom) and
         (TaskBar.Top > WorkArea.Top) then
        WorkArea.Bottom := TaskBar.Top;
    end else begin
      // Вверху
      if (TaskBar.Bottom > WorkArea.Top) and
         (TaskBar.Bottom < WorkArea.Bottom) then
        WorkArea.Top := TaskBar.Bottom;
    end;
  end;

  //---X---
  if Point.X - Width div 2 - Spacing.Left < WorkArea.Left then
    Left := WorkArea.Left + Spacing.Left
  else if Point.X + Width div 2 + Spacing.Right > WorkArea.Right then
    Left := WorkArea.Right - Width - Spacing.Right
  else
    Left := Point.X - Self.Width div 2;

  //---Y---
  if WorkArea.Contains(Point) and IsNotifyIconOverflowWindowVisible then begin
    //Иконка на дополнительной панели
    if IconRect.Top - Height - (Spacing.Top + Spacing.Bottom) >= WorkArea.Top then
      Top := IconRect.Top - Height - Spacing.Bottom
    else
      Top := IconRect.Bottom + Spacing.Top;
  end else begin
    //Иконка на панели уведомлений
    if Point.Y - Height div 2 - Spacing.Top < WorkArea.Top then
      Top := WorkArea.Top + Spacing.Top
    else if Point.Y + Height div 2 + Spacing.Bottom > WorkArea.Bottom  then
      Top := WorkArea.Bottom - Height - Spacing.Bottom
    else
      Top := Point.Y - Height div 2;
  end;

  // Корректировка при малом разрешении или высоком DPI
  if Left < WorkArea.Left then Left := WorkArea.Left;
  if Top  < WorkArea.Top  then Top  := WorkArea.Top;
end;

procedure TTrayNotifyWindow.InterfaceBuild;
begin
  FAeroEnabled := IsAeroEnabled;

  AutoSize := False;
  case SystemBorder of
    sbDisable, sbWithoutBorder:
      begin
        SetWindowLong(Handle, GWL_STYLE, NativeInt(WS_CLIPCHILDREN or WS_CLIPSIBLINGS or WS_POPUP or WS_BORDER));
        SetWindowLong(Handle, GWL_EXSTYLE, NativeInt(WS_EX_TOOLWINDOW));
      end;
    else
    begin
      if FWindows10OrGreater then begin
        SetWindowLong(Handle, GWL_STYLE, NativeInt(WS_CLIPCHILDREN or WS_CLIPSIBLINGS or WS_POPUP or WS_SIZEBOX));
        SetWindowLong(Handle, GWL_EXSTYLE, NativeInt(WS_EX_WINDOWEDGE or WS_EX_TOOLWINDOW));
      end else if FAeroEnabled then begin
        SetWindowLong(Handle, GWL_STYLE, NativeInt(WS_CLIPCHILDREN or WS_CLIPSIBLINGS or WS_POPUP or WS_SIZEBOX));
        SetWindowLong(Handle, GWL_EXSTYLE, NativeInt(WS_EX_DLGMODALFRAME or WS_EX_TOOLWINDOW));
      end else begin
        SetWindowLong(Handle, GWL_STYLE, NativeInt(WS_CLIPCHILDREN or WS_CLIPSIBLINGS or WS_POPUP or WS_BORDER));
        SetWindowLong(Handle, GWL_EXSTYLE, NativeInt(WS_EX_TOOLWINDOW));
      end;
    end;
  end;

  Height := Height - GetSystemMetrics(SM_CYCAPTION);

  if IsWindows10OrGreater then
  begin
    FPanelHeader.Visible := (FSystemBorder <> sbDefault) or not FAeroEnabled;
    FPanelHeader.Top := 0;
  end;

  AutoSize := True;

  Reposition;
end;

function TTrayNotifyWindow.IsAeroEnabled: Boolean;
type
  TDwmIsCompositionEnabledFunc = function(out pfEnabled: BOOL): HRESULT; stdcall;
var
  IsEnabled: BOOL;
  ModuleHandle: HMODULE;
  DwmIsCompositionEnabledFunc: TDwmIsCompositionEnabledFunc;
begin
  Result := False;
  if Win32MajorVersion >= 6 then begin // Vista or Windows 7+
    ModuleHandle := LoadLibrary('dwmapi.dll');
    if ModuleHandle <> 0 then
      try
        @DwmIsCompositionEnabledFunc := GetProcAddress(ModuleHandle, 'DwmIsCompositionEnabled');
        if Assigned(DwmIsCompositionEnabledFunc) then
          if DwmIsCompositionEnabledFunc(IsEnabled) = S_OK then
            Result := IsEnabled;
      finally
        FreeLibrary(ModuleHandle);
      end;
  end;
end;

function TTrayNotifyWindow.PixelToDpi(Pixel: Integer): Integer;
begin
  Result := MulDiv(Pixel, GetCurrentPPI, 96);
end;

procedure TTrayNotifyWindow.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited;
  if (ssAlt in Shift) and (Key = VK_F4) then ShowWindow(Handle, SW_HIDE);
end;

procedure TTrayNotifyWindow.KeyPress(var Key: Char);
begin
  inherited;
  if (Key = Char(VK_ESCAPE)) and not FIsLockedOpened then ShowWindow(Handle, SW_HIDE);
end;

procedure TTrayNotifyWindow.Reposition;
var
  IconRect: TRect;
begin
  if Assigned(FTrayIcon) then
  begin
    IconRect := FTrayIcon.GetIconRect;
    if IconRect.IsEmpty then
      GetWindowRect(GetTrayNotifyWndToolbar, IconRect);

    FormReposition(IconRect, FAeroEnabled);
  end;
end;

procedure TTrayNotifyWindow.LockOpened;
begin
  ShowWindow(Handle, SW_RESTORE);
  FIsLockedOpened := True;
end;

procedure TTrayNotifyWindow.UnlockAndClose;
begin
  FIsLockedOpened := False;
  ShowWindow(Handle, SW_HIDE);
end;

procedure TTrayNotifyWindow.WMActivate(var Msg: TMessage);
begin
  inherited;
  
  if FIsLockedOpened then Exit;

  if Msg.wParam = WA_INACTIVE then begin
    TickCountDeactivate := GetTickCount;
    ShowWindow(Handle, SW_HIDE);

    if Assigned(OnDeactivate) then OnDeactivate(Self);
  end else
    if Assigned(OnActivate) then OnActivate(Self);
end;

procedure TTrayNotifyWindow.WMShowWindow(var Msg: TWMShowWindow);
var
  lpStartupInfo: TStartupInfo;
begin
  if FShowFix then
  begin
    Msg.Result := DefWindowProc(Handle, Msg.Msg, TMessage(Msg).WParam, TMessage(Msg).LParam);
    Exit;
  end;

  if FShowFirst then
  try
    // Исправление запуска в срернутом состоянии
    GetStartupInfo(lpStartupInfo);
    if (lpStartupInfo.dwFlags and STARTF_USESHOWWINDOW = STARTF_USESHOWWINDOW) and
       (lpStartupInfo.wShowWindow <> SW_SHOWDEFAULT) then
    begin
      FShowFix := True;
      try
        ShowWindow(Handle, SW_RESTORE);
        ShowWindow(Handle, SW_HIDE);
      finally
        FShowFix := False;
      end;
    end;
  finally
    FShowFirst := False;
  end;

  if Msg.Show then begin
    Reposition;

    try
      Visible := True;
    except
    end;

    Realign;

    inherited;

    SetActiveWindow(Handle);
    if not SetForegroundWindow(Handle) then
    begin
      // Workaround for Windows 10 Start and Notification Center
      AttachThreadInput(GetWindowThreadProcessId(GetForegroundWindow), GetCurrentThreadId, True);
    end;

    NotifyWinEvent(EVENT_SYSTEM_MENUPOPUPSTART, Handle, OBJID_CLIENT, 0);
  end else begin
    SelectFirst;

    try
      Visible := False;
    except
    end;

    inherited;

    NotifyWinEvent(EVENT_SYSTEM_MENUPOPUPEND, Handle, OBJID_CLIENT, 0);
    SendMessage(Handle, WM_UPDATEUISTATE, MakeWParam(UIS_SET, UISF_HIDEFOCUS), 0);
  end;
end;

procedure TTrayNotifyWindow.WMDisplayChange(var Msg: TWMDisplayChange);
begin
  inherited;
  SetTimer(Handle, TimerReposition, 1000, nil);
end;

procedure TTrayNotifyWindow.WMDWMCompositionChanged(var Msg: TMessage);
begin
  inherited;
  InterfaceBuild;
end;

procedure TTrayNotifyWindow.WMNCHitTest(var Msg: TWMNCHitTest);
begin
  inherited;
  if (Msg.Result = HTLEFT) or (Msg.Result = HTRIGHT) or
     (Msg.Result = HTTOP) or (Msg.Result = HTBOTTOM) or
     (Msg.Result = HTTOPLEFT) or (Msg.Result = HTBOTTOMLEFT) or
     (Msg.Result = HTTOPRIGHT) or (Msg.Result = HTBOTTOMRIGHT)
  then Msg.Result:=HTBORDER;
end;

procedure TTrayNotifyWindow.WMSize(var Msg: TWMSize);
begin
  inherited;
  Reposition;
end;

procedure TTrayNotifyWindow.WMDpiChanged(var Message: TMessage);
begin
  if not FWindows10OrGreater then
  begin
    Message.Result := DefWindowProc(Handle, Message.Msg, Message.WParam, Message.LParam);
    Exit;
  end;

  AutoSize := False;
  DisableAlign;
  try
    inherited;
    FPanelHeader.Height := 3;
  finally
    EnableAlign;
    AutoSize := True;
    LoadIcon;
    SetTimer(Handle, TimerLoadIcon, 1500, nil); // Workaround for Windows 10 Shell_NotifyIcon bug
  end;
end;

procedure TTrayNotifyWindow.WMTimer(var Message: TWMTimer);
begin
  Message.Result := DefWindowProc(Handle, Message.Msg, TMessage(Message).WParam, TMessage(Message).LParam);

  case Message.TimerID of
    TimerReposition: Reposition;
    TimerLoadIcon: LoadIcon;
  end;
  KillTimer(Handle, Message.TimerID);
end;

procedure TTrayNotifyWindow.TrayIconClick(Sender: TObject);
begin
  if FIsLockedOpened then Exit;
  
  if IsWindowVisible(Handle) then
    ShowWindow(Handle, SW_HIDE) // Скрываем форму
  else
    if Abs(GetTickCount - TickCountDeactivate) > 200 then
      ShowWindow(Handle, SW_RESTORE); // Показываем форму, если с момента деативации прошло > 200 ms
end;

procedure TTrayNotifyWindow.SetSystemBorder(const Value: TSystemBorder);
begin
  if FSystemBorder = Value then Exit;

  if Value in [Low(TSystemBorder) .. High(TSystemBorder)] then
    FSystemBorder := Value
  else
    FSystemBorder := sbDefault;

  if IsWindows10OrGreater then ShowWindow(Handle, SW_HIDE);
  InterfaceBuild;
  DoSystemBorderChanged(FSystemBorder);
  if IsWindows10OrGreater and FIsLockedOpened then ShowWindow(Handle, SW_RESTORE);
end;

procedure TTrayNotifyWindow.SetOnSystemBorderChanged(
  const Value: TSystemBorderChangedEvent);
begin
  FOnSystemBorderChanged := Value;
  DoSystemBorderChanged(FSystemBorder);
end;

procedure TTrayNotifyWindow.DoSystemBorderChanged(var SystemBorder: TSystemBorder);
begin
  if Assigned(FOnSystemBorderChanged) then
    FOnSystemBorderChanged(Self, SystemBorder);
end;

end.
