unit Tray.Helpers;

interface

uses
  WinApi.Windows, Winapi.ShellAPI,
  System.Types;

function IsNotifyIconOverflowWindowVisible: boolean;
function IsTaskbarAutoHideOn : boolean;
function GetNotifyIconOverflowWindow: HWND;
function GetTrayNotifyWndToolbar: HWND;
function GetTaskbarPos: TRect;

function GET_X_LPARAM(const lParam: LPARAM): Integer; inline;
function GET_Y_LPARAM(const lParam: LPARAM): Integer; inline;

implementation

function IsNotifyIconOverflowWindowVisible: boolean;
var
  NotifyIconOverflowWindow: HWND;
begin
  NotifyIconOverflowWindow := GetNotifyIconOverflowWindow;
  if NotifyIconOverflowWindow = 0 then
    Result := False
  else
    Result := IsWindowVisible(NotifyIconOverflowWindow);
end;

function IsTaskbarAutoHideOn : boolean;
var
  ABData : TAppBarData;
begin
  ABData.cbSize := sizeof(ABData);
  Result := (SHAppBarMessage(ABM_GETSTATE, ABData) and ABS_AUTOHIDE) <> 0;
end;

function GetNotifyIconOverflowWindow: HWND;
begin
  Result := FindWindow('NotifyIconOverflowWindow', nil);
end;

function GetTrayNotifyWndToolbar: HWND;
var
  Shell_TrayWnd: HWND;
  TrayNotifyWnd: HWND;
  SysPager: HWND;
  ToolbarWindow32: HWND;
begin
  Shell_TrayWnd := FindWindow('Shell_TrayWnd', nil);
  if Shell_TrayWnd <> 0 then
  begin
    TrayNotifyWnd := FindWindowEx(Shell_TrayWnd, 0, 'TrayNotifyWnd', nil);
    if TrayNotifyWnd <> 0 then
    begin
      SysPager := FindWindowEx(TrayNotifyWnd, 0, 'SysPager', nil);
      if SysPager <> 0 then
      begin
        // Получение дескриптора окна ToolbarWindow32 содержащего иконки
        ToolbarWindow32 := FindWindowEx(SysPager, 0, 'ToolbarWindow32', nil);
        if ToolbarWindow32 <> 0 then
          Exit(ToolbarWindow32);
      end;

      // В Windows Vista 2 окна SysPager
      SysPager := FindWindowEx(TrayNotifyWnd, SysPager, 'SysPager', nil);
      if SysPager <> 0 then
      begin
        // Получение дескриптора окна ToolbarWindow32 содержащего иконки
        ToolbarWindow32 := FindWindowEx(SysPager, 0, 'ToolbarWindow32', nil);
        if ToolbarWindow32 <> 0 then
          Exit(ToolbarWindow32);
      end;
    end;
  end;
  Result := 0;
end;

function GetTaskbarPos: TRect;
var
  ABData : TAppBarData;
begin
  ABData.cbSize := sizeof(ABData);
  if SHAppBarMessage(ABM_GETTASKBARPOS, ABData) > 0 then
    Result := ABData.rc
  else
    Result := TRect.Empty;
end;

function GET_X_LPARAM(const lParam: LPARAM): Integer;
begin
  Result := Integer(SHORT(LOWORD(lParam)));
end;

function GET_Y_LPARAM(const lParam: LPARAM): Integer;
begin
  Result := Integer(SHORT(HiWord(lParam)));
end;

end.
