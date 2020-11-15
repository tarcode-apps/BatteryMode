unit Brightness.Manager.HookHandler;

interface

uses
  System.Classes,
  Winapi.Windows,
  Brightness, Brightness.Manager,
  Tray.Icon;

type
  TBrightnessManagerHookHandler = class
  strict private
    FTrayIcon: TTrayIcon;
    FBrightnessManager: TBrightnessManager;

    FLastWnd: HWND;
    FLastWndIsTray: Boolean;

    function IsTrayWnd(Wnd: HWND): Boolean;
    function GetWindowClass(Wnd: HWND): string;
    procedure TrayIconMouseWheel(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint);
  public
    constructor Create(BrightnessManager: TBrightnessManager; TrayIcon: TTrayIcon);
    destructor Destroy; override;

    procedure UpdateBindings;
  end;

implementation

{ TBrightnessManagerHookHandler }

constructor TBrightnessManagerHookHandler.Create(
  BrightnessManager: TBrightnessManager; TrayIcon: TTrayIcon);
begin
  FBrightnessManager := BrightnessManager;
  FTrayIcon := TrayIcon;
  FLastWnd := 0;
  FLastWndIsTray := False;

  UpdateBindings;
end;

destructor TBrightnessManagerHookHandler.Destroy;
begin
  FTrayIcon.OnMouseWheel := nil;
end;

function TBrightnessManagerHookHandler.GetWindowClass(Wnd: HWND): string;
var
  WndClassLength: Integer;
begin
  SetLength(Result, MAX_PATH);
  WndClassLength := Winapi.Windows.GetClassName(Wnd, LPTSTR(Result), MAX_PATH);
  if WndClassLength > 0 then
    SetLength(Result, WndClassLength)
  else
    Result := '';
end;

function TBrightnessManagerHookHandler.IsTrayWnd(Wnd: HWND): Boolean;
begin
  if Wnd = 0 then Exit(False);

  Wnd := GetAncestor(Wnd, GA_ROOT);
  if Wnd = 0 then Exit(False);

  Result := GetWindowClass(Wnd) = 'Shell_TrayWnd';
end;

procedure TBrightnessManagerHookHandler.TrayIconMouseWheel(Sender: TObject;
  Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint);
var
  Wnd: HWND;
begin
  Wnd := WindowFromPoint(MousePos);
  if Wnd <> FLastWnd then
  begin
    FLastWnd := Wnd;
    FLastWndIsTray := IsTrayWnd(Wnd);
  end;

  if FLastWndIsTray then
  begin
    if WheelDelta > 0 then
      FBrightnessManager.ChangeLevel(bmmmTrayScroll, 1)
    else
      FBrightnessManager.ChangeLevel(bmmmTrayScroll, -1);
  end;
end;

procedure TBrightnessManagerHookHandler.UpdateBindings;
  function IsNeedTracking: Boolean;
  var
    Monitor: IBrightnessMonitor;
  begin
    Result := False;
    for Monitor in FBrightnessManager do
    begin
      if Monitor.Enable and (bmmmTrayScroll in Monitor.ManagementMethods) then Exit(True);
    end;
  end;
begin
  if IsNeedTracking then
    FTrayIcon.OnMouseWheel := TrayIconMouseWheel
  else
    FTrayIcon.OnMouseWheel := nil;
end;

end.
