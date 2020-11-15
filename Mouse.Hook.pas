unit Mouse.Hook;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.Generics.Collections,
  System.SysUtils, System.Classes, System.SyncObjs;

const
  WM_MOUSEWHEELHOOK = WM_USER + 400;
  WM_MOUSEHWHEELHOOK = WM_USER + 401;

type
  TMouseHook = class
  private const
    WH_MOUSE_LL = 14;
    HC_ACTION = 0;
    LLMHF_INJECTED          = $00000001;
    LLMHF_LOWER_IL_INJECTED = $00000002;
    WM_HOOK   = WM_USER + 256;
    WM_UNHOOK = WM_USER + 257;
  private type
    tagMSLLHOOKSTRUCT = record
      pt: TPoint;
      mouseData: DWORD;
      flags: DWORD;
      time: DWORD;
      dwExtraInfo: ULONG_PTR;
    end;
    MSLLHOOKSTRUCT = tagMSLLHOOKSTRUCT;
    PMSLLHOOKSTRUCT = ^MSLLHOOKSTRUCT;
    LPMSLLHOOKSTRUCT = ^MSLLHOOKSTRUCT;
  private
    class var HookHandle: HHOOK;
    class var HThread: THandle;
    class var IdThread: DWORD;
    class var FRecipients: TList<THandle>;

    class constructor Create;
    class destructor Destroy;

    class function Hook: boolean; static;
    class function UnHook: boolean; static;
    class function LowLevelMouseProc(nCode: Integer; wParam: WPARAM;
      lParam: LPARAM): LRESULT; stdcall; static;
    class function ThreadExecute(lpParameter: LPVOID): DWORD; stdcall; static;
  public
    class procedure RegisterHook(hRecipient: THandle);
    class procedure UnregisterHook(hRecipient: THandle);
  end;

implementation

{ TMouseHook }

class procedure TMouseHook.RegisterHook(hRecipient: THandle);
begin
  if FRecipients.Contains(hRecipient) then Exit;

  FRecipients.Add(hRecipient);
  if FRecipients.Count = 1 then Hook;
end;

class procedure TMouseHook.UnregisterHook(hRecipient: THandle);
begin
  if not FRecipients.Contains(hRecipient) then Exit;

  FRecipients.Remove(hRecipient);
  if FRecipients.Count = 0 then UnHook;
end;

class function TMouseHook.Hook: Boolean;
var
  ThreadAvalibleEvent: TEvent;
begin
  if HThread = 0 then
  begin
    ThreadAvalibleEvent := TEvent.Create;
    HThread := CreateThread(nil, 0, @ThreadExecute, @ThreadAvalibleEvent, 0, IdThread);
    SetThreadPriority(HThread, THREAD_PRIORITY_TIME_CRITICAL);
    ThreadAvalibleEvent.WaitFor;
    ThreadAvalibleEvent.Free;
  end;

  Result:= PostThreadMessage(IdThread, WM_HOOK, 0, 0);
end;

class function TMouseHook.UnHook: Boolean;
begin
  Result:= PostThreadMessage(IdThread, WM_UNHOOK, 0, 0);
end;

class function TMouseHook.LowLevelMouseProc(nCode: Integer; wParam: WPARAM;
  lParam: LPARAM): LRESULT;
var
  WheelMessage: Winapi.Windows.WPARAM;
  PMsLl: LPMSLLHOOKSTRUCT;
  WheelDelta: SHORT;
  KeyState: Word;
  wP: Winapi.Windows.WPARAM;
  lP: Winapi.Windows.LPARAM;
  hRecipient: THandle;
begin
  if nCode <> HC_ACTION then
    Exit(CallNextHookEx(HookHandle, nCode, wParam, lParam));

  case wParam of
    WM_MOUSEWHEEL, WM_MOUSEHWHEEL: begin
      case wParam of
        WM_MOUSEHWHEEL: WheelMessage := WM_MOUSEHWHEELHOOK;
        else WheelMessage := WM_MOUSEWHEELHOOK;
      end;

      PMsLl := LPMSLLHOOKSTRUCT(lParam);

      WheelDelta := HiWord(PMsLl^.mouseData);

      KeyState:= 0;
      if HiByte(GetKeyState(VK_SHIFT))   <> 0 then KeyState := KeyState or MK_SHIFT;
      if HiByte(GetKeyState(VK_LBUTTON)) <> 0 then KeyState := KeyState or MK_LBUTTON;
      if HiByte(GetKeyState(VK_RBUTTON)) <> 0 then KeyState := KeyState or MK_RBUTTON;
      if HiByte(GetKeyState(VK_CONTROL)) <> 0 then KeyState := KeyState or MK_CONTROL;
      if HiByte(GetKeyState(VK_MBUTTON)) <> 0 then KeyState := KeyState or MK_MBUTTON;

      wP := MakeWParam(KeyState, WheelDelta);
      lP := MakeLParam(PMsLl^.pt.X, PMsLl^.pt.Y);

      for hRecipient in FRecipients do
        PostMessage(hRecipient, WheelMessage, wP, lP);
    end;
  end;

  Exit(CallNextHookEx(HookHandle, nCode, wParam, lParam));
end;

class function TMouseHook.ThreadExecute(lpParameter: LPVOID): DWORD;
var
  Msg: TMsg;
  bRet: BOOL;
begin
  Result := 0;
  PeekMessage(Msg, HWND(-1), 0, 0, PM_NOREMOVE);
  TEvent(lpParameter^).SetEvent;
  try
    repeat
      bRet := GetMessage(Msg, HWND(-1), 0, 0);
      if LONG(bRet) <> -1 then begin
        case Msg.message of
          WM_HOOK: begin
            HookHandle:= SetWindowsHookEx(WH_MOUSE_LL, @LowLevelMouseProc, HInstance, 0);
          end;
          WM_UNHOOK: begin
            if HookHandle <> 0 then
              if UnhookWindowsHookEx(HookHandle) then HookHandle:= 0;
          end;
        end;

        DispatchMessage(Msg);
      end;
    until (not bRet);
  finally
    if HookHandle <> 0 then
      if UnhookWindowsHookEx(HookHandle) then HookHandle:= 0;
  end;
end;

class constructor TMouseHook.Create;
begin
  HookHandle := 0;
  HThread := 0;
  FRecipients := TList<THandle>.Create;
end;

class destructor TMouseHook.Destroy;
begin
  UnHook;
  PostThreadMessage(IdThread, WM_QUIT, 0, 0);
  FreeAndNil(FRecipients);
end;

end.
