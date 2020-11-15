unit Tray.Icon;

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.ShellAPI,
  System.SysUtils, System.Classes, System.Types,
  Vcl.Controls, Vcl.Menus,
  Mouse.Hook,
  Tray.Helpers,
  Versions.Helpers;

type
  TTrayPopupMenuEvent = procedure(Sender: TObject; Shift: TShiftState) of object;
  TTrayMouseWheelEvent = procedure(Sender: TObject; Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint) of object;

  TTrayIcon = class
  private const
    WM_TRAYNOTIFY = WM_USER + 1;
    TimerIconUpdate = UINT_PTR(1);
  private type
    TIsWow64Process = function (hProcess: THandle; var Wow64Process: BOOL): BOOL; stdcall;
  private
    FOwner: TComponent;
    FNotifyIconData: TNotifyIconData;
    FHandle: HWND;
    FHint: String;
    FID: Cardinal;
    FPopupMenu: TPopupMenu;
    FOnClick: TNotifyEvent;
    FOnBalloonClick: TNotifyEvent;
    FOnBalloonClick2: TNotifyEvent;
    FOnBalloonHide: TNotifyEvent;
    FOnPopupMenu: TTrayPopupMenuEvent;
    FOnOnMouseWheel: TTrayMouseWheelEvent;
    FIsClicked: Boolean;
    IsShellWindows7: Boolean;
    IsWin64: Boolean;
    FuncIsWow64Process: TIsWow64Process;

    WM_TASKBARCREATED: Cardinal;
    FVisible: Boolean;
    FBalloonHint: string;
    FBalloonTitle: string;

    procedure HandleIconMessage(var Msg: TMessage);

    procedure SetIcon(const Value: HICON);
    function  GetIcon: HICON;

    procedure SetHint(const Value: String);
    procedure SetBalloonHint(const Value: string);

    procedure SetID(const Value: Cardinal);

    procedure PopupAtCursor;
    procedure PopupAtPos(Pos: TPoint);
    procedure SetPopupMenu(const Value: TPopupMenu);

    function IsProcess64(Process: THandle): Boolean;
    procedure SetVisible(const Value: Boolean);
    procedure SetBalloonTitle(const Value: string);
    procedure SetOnMouseWheel(const Value: TTrayMouseWheelEvent);
  public
    constructor Create(AOwner: TComponent);
    destructor Destroy; override;

    property Icon: HICON read GetIcon write SetIcon;
    property ID: Cardinal read FID write SetID;
    property Hint: string read FHint write SetHint;
    property BalloonHint: string read FBalloonHint write SetBalloonHint;
    property BalloonTitle: string read FBalloonTitle write SetBalloonTitle;
    property PopupMenu: TPopupMenu read FPopupMenu write SetPopupMenu;
    property Handle: HWND read FHandle;
    property Visible: Boolean read FVisible write SetVisible;

    function GetIconRect: TRect;
    procedure SetFucus;
    procedure Update; overload;
    procedure Update(Timeout: UINT); overload;
    procedure ShowBalloonHint(InfoFlags: DWORD = NIIF_INFO);

    property OnClick: TNotifyEvent read FOnClick write FOnClick;
    property OnBalloonClick: TNotifyEvent read FOnBalloonClick write FOnBalloonClick;
    property OnBalloonClick2: TNotifyEvent read FOnBalloonClick2 write FOnBalloonClick2;
    property OnBalloonHide: TNotifyEvent read FOnBalloonHide write FOnBalloonHide;
    property OnPopupMenu: TTrayPopupMenuEvent read FOnPopupMenu write FOnPopupMenu;
    property OnMouseWheel: TTrayMouseWheelEvent read FOnOnMouseWheel write SetOnMouseWheel;
  end;

implementation

const
  TB_GETBUTTON    = WM_USER + 23;
  TB_BUTTONCOUNT  = WM_USER + 24;
  TB_GETRECT      = WM_USER + 51;

type
  TRAYDATA = record
    hwnd: HWND;
    uID: UINT;
    uCallbackMessage: UINT;
    Reserved : array [0..1] of DWORD;
    hIcon: HICON;
  end;

  TBBUTTON32 = record
    iBitmap: Integer;
    idCommand: Integer;
    fsState: Byte;
    fsStyle: Byte;
    bReserved: array[1..2] of Byte; // padding for alignment
    dwData: DWORD_PTR;
    iString: INT_PTR;
  end;

  TBBUTTON64 = record
    iBitmap: Integer;
    idCommand: Integer;
    fsState: Byte;
    fsStyle: Byte;
    bReserved: array[1..6] of Byte; // padding for alignment
    dwData: DWORD_PTR;
    iString: INT_PTR;
  end;


{ TTrayIcon }

constructor TTrayIcon.Create(AOwner: TComponent);
var
  Lib: HMODULE;
begin
  IsShellWindows7 := IsWindows7OrGreater;
  IsWin64 := IsWindows64Bit;

  Lib := LoadLibrary(kernel32);
  if Lib <> 0 then
  begin
    FuncIsWow64Process := GetProcAddress(Lib, 'IsWow64Process');
    FreeLibrary(Lib);
  end else
    FuncIsWow64Process := nil;

  FOwner := AOwner;
  FVisible := False;
  FIsClicked := False;

  FHandle := AllocateHWnd(HandleIconMessage);
  WM_TASKBARCREATED := RegisterWindowMessage('TaskbarCreated');

  ZeroMemory(@FNotifyIconData, SizeOf(FNotifyIconData));
  FNotifyIconData.cbSize            := TNotifyIconData.SizeOf;
  FNotifyIconData.Wnd               := FHandle;
  FNotifyIconData.uID               := 0;
  FNotifyIconData.uFlags            := NIF_MESSAGE or NIF_ICON or NIF_TIP;
  FNotifyIconData.uCallbackMessage  := WM_TRAYNOTIFY;
  FNotifyIconData.HIcon             := 0;
  FNotifyIconData.szTip             := '';
  if IsWindowsVistaOrGreater then
  begin
    FNotifyIconData.uVersion        := NOTIFYICON_VERSION_4;
    FNotifyIconData.uFlags          := FNotifyIconData.uFlags or NIF_SHOWTIP;
  end
  else
  begin
    FNotifyIconData.uTimeout        := 10000;
  end;
end;

destructor TTrayIcon.Destroy;
begin
  if Assigned(FOnOnMouseWheel) then TMouseHook.UnregisterHook(FHandle);
  Shell_NotifyIcon(NIM_DELETE, @FNotifyIconData);
  DeallocateHWnd(FHandle);
end;

procedure TTrayIcon.HandleIconMessage(var Msg: TMessage);
var
  MousePos: TPoint;
begin
  Msg.Result := DefWindowProc(Handle, Msg.Msg, Msg.WParam, Msg.LParam);

  if Msg.Msg = WM_TRAYNOTIFY then
  begin
    case Msg.lParam of
      WM_LBUTTONDOWN:
        FIsClicked := True;
      WM_LBUTTONUP:
        if FIsClicked and Assigned(FOnClick) then
        begin
          FOnClick(Self);
          FIsClicked := False;
        end;
      WM_RBUTTONUP:
        if not IsWindowsVistaOrGreater then
          if (Assigned(FPopupMenu)) and (FPopupMenu.AutoPopup) then
            PopupAtCursor
          else
            if Assigned(FOnClick) then FOnClick(Self);
      NIN_BALLOONHIDE, NIN_BALLOONTIMEOUT:
        begin
          if Assigned(FOnBalloonHide) then
            FOnBalloonHide(Self);
        end;
      NIN_BALLOONUSERCLICK:
        begin
          FNotifyIconData.uFlags := FNotifyIconData.uFlags and not NIF_INFO;
          Shell_NotifyIcon(NIM_MODIFY, @FNotifyIconData);
          if Assigned(FOnBalloonClick) then
            FOnBalloonClick(Self);
          if Assigned(FOnBalloonClick2) then
            FOnBalloonClick2(Self);
        end;
      NIN_KEYSELECT:
        if Assigned(FOnClick) then FOnClick(Self);
      WM_CONTEXTMENU:
        if (Assigned(FPopupMenu)) and (FPopupMenu.AutoPopup) then
          PopupAtPos(TPoint.Create(GET_X_LPARAM(Msg.WParam), GET_Y_LPARAM(Msg.WParam)))
        else
          if Assigned(FOnClick) then FOnClick(Self);
    end;
    Exit;
  end;

  if Msg.Msg = WM_TASKBARCREATED then
  begin
    if FVisible then
    begin
      Shell_NotifyIcon(NIM_ADD, @FNotifyIconData);
      if IsWindowsVistaOrGreater then
        Shell_NotifyIcon(NIM_SETVERSION, @FNotifyIconData);
    end;
    Exit;
  end;

  if Msg.Msg = WM_TIMER then
  begin
    case Msg.WParam of
      TimerIconUpdate:
      begin
        KillTimer(FHandle, Msg.WParam);
        Update;
      end;
    end;
    Exit;
  end;
  
  if (Msg.Msg = WM_MOUSEWHEELHOOK) or (Msg.Msg = WM_MOUSEHWHEELHOOK) then
  begin
    if Assigned(FOnOnMouseWheel) then
    begin
      MousePos := TPoint.Create(Msg.LParamLo, Msg.LParamHi);
      if GetIconRect.Contains(MousePos) then
        FOnOnMouseWheel(Self, TShiftState(Msg.WParamLo), SHORT(Msg.WParamHi), MousePos);
    end;
    Exit;
  end;
end;

procedure TTrayIcon.SetIcon(const Value: HICON);
begin
  DestroyIcon(FNotifyIconData.hIcon);
  FNotifyIconData.hIcon:= Value;
  if FVisible then
    Shell_NotifyIcon(NIM_MODIFY, @FNotifyIconData);
end;

function TTrayIcon.GetIcon: HICON;
begin
  Result:= FNotifyIconData.hIcon;
end;

procedure TTrayIcon.SetID(const Value: Cardinal);
begin
  FID:= Value;
  FNotifyIconData.uID:= FID;
  if FVisible then
    Shell_NotifyIcon(NIM_MODIFY, @FNotifyIconData);
end;

procedure TTrayIcon.SetPopupMenu(const Value: TPopupMenu);
begin
  if (not (Value is TPopupMenu)) or (FPopupMenu = Value) then Exit;
  FPopupMenu := Value;
end;

procedure TTrayIcon.SetVisible(const Value: Boolean);
begin
  if FVisible = Value then Exit;

  FVisible := Value;
  if FVisible then
  begin
    Shell_NotifyIcon(NIM_ADD, @FNotifyIconData);
    if IsWindowsVistaOrGreater then
      Shell_NotifyIcon(NIM_SETVERSION, @FNotifyIconData);
  end else
    Shell_NotifyIcon(NIM_DELETE, @FNotifyIconData);
end;

procedure TTrayIcon.SetHint(const Value: String);
begin
  if FHint = Value then Exit;

  FHint := Value;
  ZeroMemory(@FNotifyIconData.szTip, SizeOf(FNotifyIconData.szTip));
  FHint.CopyTo(0, FNotifyIconData.szTip, 0, FHint.Length);

  if FHint <> '' then
    FNotifyIconData.uFlags := FNotifyIconData.uFlags or NIF_TIP
  else
    FNotifyIconData.uFlags := FNotifyIconData.uFlags and not NIF_TIP;

  if FVisible then
    Shell_NotifyIcon(NIM_MODIFY, @FNotifyIconData);
end;

procedure TTrayIcon.SetBalloonHint(const Value: string);
begin
  if FBalloonHint = Value then Exit;

  FBalloonHint := Value;
  ZeroMemory(@FNotifyIconData.szInfo, SizeOf(FNotifyIconData.szInfo));
  FBalloonHint.CopyTo(0, FNotifyIconData.szInfo, 0, FBalloonHint.Length);

  if FVisible then
    Shell_NotifyIcon(NIM_MODIFY, @FNotifyIconData);
end;

procedure TTrayIcon.SetBalloonTitle(const Value: string);
begin
  if FBalloonTitle = Value then Exit;

  FBalloonTitle := Value;
  ZeroMemory(@FNotifyIconData.szInfoTitle, SizeOf(FNotifyIconData.szInfoTitle));
  FBalloonTitle.CopyTo(0, FNotifyIconData.szInfoTitle, 0, FBalloonTitle.Length);

  if FVisible then
    Shell_NotifyIcon(NIM_MODIFY, @FNotifyIconData);
end;

procedure TTrayIcon.SetOnMouseWheel(const Value: TTrayMouseWheelEvent);
begin
  FOnOnMouseWheel := Value;
  if Assigned(FOnOnMouseWheel) then
    TMouseHook.RegisterHook(FHandle)
  else
    TMouseHook.UnregisterHook(FHandle);
end;


procedure TTrayIcon.PopupAtCursor;
var
  CursorPos: TPoint;
begin
  if GetCursorPos(CursorPos) then
    PopupAtPos(CursorPos);
end;

procedure TTrayIcon.PopupAtPos(Pos: TPoint);
var
  Shift: TShiftState;
begin
  Shift := [];
  if GetKeyState(VK_SHIFT)    < 0 then Include(Shift, ssShift);
  if GetKeyState(VK_CONTROL)  < 0 then Include(Shift, ssCtrl);
  if GetKeyState(VK_LBUTTON)  < 0 then Include(Shift, ssLeft);
  if GetKeyState(VK_RBUTTON)  < 0 then Include(Shift, ssRight);
  if GetKeyState(VK_MBUTTON)  < 0 then Include(Shift, ssMiddle);
  if GetKeyState(VK_MENU)     < 0 then Include(Shift, ssAlt);

  if Assigned(FOnPopupMenu) then
    FOnPopupMenu(Self, Shift);

  SetForegroundWindow(FHandle);
  FPopupMenu.Popup(Pos.X, Pos.Y);
end;

procedure TTrayIcon.SetFucus;
begin
  if FVisible then
    Shell_NotifyIcon(NIM_SETFOCUS, @FNotifyIconData);
end;

procedure TTrayIcon.Update;
begin
  if FVisible then
  begin
    Shell_NotifyIcon(NIM_ADD, @FNotifyIconData);
    if IsWindowsVistaOrGreater then
      Shell_NotifyIcon(NIM_SETVERSION, @FNotifyIconData);
  end
end;

procedure TTrayIcon.Update(Timeout: UINT);
begin
  SetTimer(FHandle, TimerIconUpdate, Timeout, nil);
end;

procedure TTrayIcon.ShowBalloonHint(InfoFlags: DWORD = NIIF_INFO);
begin
  if FVisible then
  begin
    FNotifyIconData.dwInfoFlags := InfoFlags;

    FNotifyIconData.uFlags := FNotifyIconData.uFlags or NIF_INFO;

    // Убираем старое уведомление
    ZeroMemory(@FNotifyIconData.szInfoTitle, SizeOf(FNotifyIconData.szInfoTitle));
    ZeroMemory(@FNotifyIconData.szInfo, SizeOf(FNotifyIconData.szInfo));
    Shell_NotifyIcon(NIM_MODIFY, @FNotifyIconData);

    // Отображаем новое
    FBalloonTitle.CopyTo(0, FNotifyIconData.szInfoTitle, 0, FBalloonTitle.Length);
    FBalloonHint.CopyTo(0, FNotifyIconData.szInfo, 0, FBalloonHint.Length);
    Shell_NotifyIcon(NIM_MODIFY, @FNotifyIconData);

    // Убираем флаг
    FNotifyIconData.uFlags := FNotifyIconData.uFlags and not NIF_INFO;
    Shell_NotifyIcon(NIM_MODIFY, @FNotifyIconData);
  end;
end;



function TTrayIcon.GetIconRect: TRect;
var
  Shell_TrayWnd: HWND;
  TrayNotifyWnd: HWND;
  SysPager: HWND;
  ToolbarWindow32: HWND;
  NotifyIconOverflowWindow: HWND;
  Identifier: NOTIFYICONIDENTIFIER;

  function GetIconPosByHWND(Wnd: HWND; var R: TRect): Boolean;
  var
    TrayID: DWORD;
    CountButton: NativeInt;
    hTrayProc: THandle;
    Process64: Boolean;
    pTrayData: Pointer;
    pIconRect: Pointer;// Переменная указывающая на туже области для структуры данных иконки
    PButtonData: Pointer;
    ButtonDataSize: SIZE_T;
    ButtonData32: TBBUTTON32;// Структура данных кнопки окна Toolbar Win32
    ButtonData64: TBBUTTON64;// Структура данных кнопки окна Toolbar Win64
    dwData: DWORD_PTR;
    idCommand: Integer;
    IconData: TRAYDATA;// Cтруктура данных иконцки кнопки окна Toolbar
    IconRect: TRect;// Координаты иконки
    i: Integer;
    RBytes : NativeUInt;
    TrayWndRect: TRect;// Координаты окна
    Found: Boolean;
  begin
    Result := False;

    // Получение идентификатора процесса Tray
    GetWindowThreadProcessId(Wnd, TrayID);
    // Получение количества кнопок в окне ToolbarWindow32
    CountButton := SendMessage(Wnd, TB_BUTTONCOUNT, 0, 0);
    if CountButton = 0 then Exit;

    // Получение дескриптора процесса по его ID
    hTrayProc := OpenProcess(STANDARD_RIGHTS_REQUIRED or SYNCHRONIZE or $FFF, False, TrayID);

    // Не удалось получить дескриптор процесса Tray
    if hTrayProc = 0 then Exit;

    Process64 := IsProcess64(hTrayProc);
    if Process64 then
    begin
      PButtonData := @ButtonData64;
      ButtonDataSize := SizeOf(TBBUTTON64);
    end
    else
    begin
      PButtonData := @ButtonData32;
      ButtonDataSize := SizeOf(TBBUTTON32);
    end;

    // Выделение памяти в процессе hTrayProc для доступа к резултатам обработки посылаемых событий
    pTrayData := VirtualAllocEx(hTrayProc,      // Дексриптор процесса в котором выделяем память
                                nil,            // Адресс начала выделения (nil - выберается системой)
                                ButtonDataSize, // Размер выделяемой области памяти
                                MEM_COMMIT,     // Программное распеределение памяти
                                PAGE_READWRITE);// Разрешение на чтение и запись памяти

    // Не удалось выделить виртуальную память
    if pTrayData = nil then
    begin
      CloseHandle(hTrayProc);
      Exit;
    end;

    pIconRect := pTrayData; //Переменная указывающая на туже области для структуры данных иконки

    Found := False;
    for i := 0 to CountButton - 1 do
    begin
      // Заполнение памяти структурой данных о кнопке Toolbar
      if SendMessage(Wnd,                   // Дескриптор окна Toolbar
                     TB_GETBUTTON,          // Запрос информации об кнопках
                     WPARAM(i),             // Номер кнопки от 0 до CountButton - 1
                     LPARAM(pTrayData)) = 0 // Указатель на выделенную область памяти
      then Continue;

      // Считывание из памяти процесса структуры TBBUTTON
      if not ReadProcessMemory(hTrayProc,       // Дескриптор процесса
                               pTrayData,       // Указатель на считываемую область памяти
                               PButtonData,     // Указатель на сохраняемую область памяти
                               ButtonDataSize,  // Размер копируемой памяти
                               RBytes)          // Количество считанных байт
      then Continue; // Не удалось прочитать память процесса

      if Process64 then
      begin
        dwData := ButtonData64.dwData;
        idCommand := ButtonData64.idCommand;
      end
      else
      begin
        dwData := ButtonData32.dwData;
        idCommand := ButtonData32.idCommand;
      end;

      // Получение структуры TRAYDATA
      if not ReadProcessMemory(hTrayProc,       // Дескриптор процесса
                               Pointer(dwData), // Указатель на считываемую область памяти
                               @IconData,       // Указатель на сохраняемую область памяти
                               SizeOf(TRAYDATA),// Размер копируемой памяти
                               RBytes)          // Количество считанных байт
      then Continue; // Не удалось прочитать память процесса

      // Проверка соответсвия иконки заданным параметрам
      // Критерий поиска дескриптор окна и идентификатор ресурса
      if (IconData.hwnd = FHandle) and (IconData.uID = FID) then
      begin
        // Получение размера Icon
        if SendMessage(Wnd,
                       TB_GETRECT,
                       idCommand,
                       LPARAM(pIconRect)) = 0
        then Continue;

        // Не удалось прочитать память процесса
        if not ReadProcessMemory(hTrayProc,     //Дескриптор процесса
                                 pIconRect,     //Указатель на считываемую область памяти
                                 @IconRect,     //Указатель на сохраняемую область памяти
                                 SizeOf(TRect), //Размер копируемой памяти
                                 RBytes)        //Количество считанных байт
        then Continue; // Не удалось прочитать память процесса

        Found := True;
        Break;
      end;
    end;

    VirtualFreeEx(hTrayProc, pTrayData, 0, MEM_RELEASE);
    CloseHandle(hTrayProc);

    // Иконка не найдена
    if not Found then Exit;

    if not GetWindowRect(Wnd, TrayWndRect) then Exit;

    R.Left    := TrayWndRect.Left + IconRect.Left   + 1;
    R.Top     := TrayWndRect.Top  + IconRect.Top    + 1;
    R.Right   := TrayWndRect.Left + IconRect.Right  - 1;
    R.Bottom  := TrayWndRect.Top  + IconRect.Bottom - 1;

    Result := True;
  end;
begin
  try
    if IsShellWindows7 then
    begin
      // Windows 7 и выше
      Identifier.cbSize   := SizeOf(Identifier);
      Identifier.hWnd     := FHandle;
      Identifier.uID      := FID;
      Identifier.guidItem := GUID_NULL;
      if Shell_NotifyIconGetRect(Identifier, Result) = S_OK then Exit;
    end;
    // Windows XP
    // Поиск в трее Shell_TrayWnd
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
            if GetIconPosByHWND(ToolbarWindow32, Result) then Exit;
        end;

        // В Windows Vista 2 окна SysPager
        SysPager := FindWindowEx(TrayNotifyWnd, SysPager, 'SysPager', nil);
        if SysPager <> 0 then
        begin
          // Получение дескриптора окна ToolbarWindow32 содержащего иконки
          ToolbarWindow32 := FindWindowEx(SysPager, 0, 'ToolbarWindow32', nil);
          if ToolbarWindow32 <> 0 then
            if GetIconPosByHWND(ToolbarWindow32, Result) then Exit;
        end;
      end;
    end;

    // Поиск на дополнительной панели NotifyIconOverflowWindow
    NotifyIconOverflowWindow := FindWindow('NotifyIconOverflowWindow', nil);
    if NotifyIconOverflowWindow <> 0 then
    begin
      // Получение дескриптора окна ToolbarWindow32 содержащего иконки
      ToolbarWindow32 := FindWindowEx(NotifyIconOverflowWindow, 0, 'ToolbarWindow32', nil);
      if ToolbarWindow32 <> 0 then
        if GetIconPosByHWND(ToolbarWindow32, Result) then Exit;
    end;

    Result := TRect.Empty;
  except
    Result := TRect.Empty;
  end;
end;

function TTrayIcon.IsProcess64(Process: THandle): Boolean;
var
  Wow64Process: BOOL;
begin
  // Система 32 бит
  if not IsWin64 then Exit(False);

  // В Windows XP до SP2 этой функции нет
  if not Assigned(FuncIsWow64Process) then Exit(True);

  if not FuncIsWow64Process(Process, Wow64Process) then Exit(False);

  Result := not Wow64Process;
end;

end.
