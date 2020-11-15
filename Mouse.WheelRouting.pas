unit Mouse.WheelRouting;

interface

uses
  Winapi.Windows, Winapi.Messages, Vcl.Forms;

type
  TMouseWheelRouting = class
  private class var
    FOnMessage: TMessageEvent;
    FCurrentProcessId: DWORD;
  protected
    class procedure AppMessage(var Msg: TMsg; var Handled: Boolean);
    class procedure Init;
  public
    class property OnMessage: TMessageEvent read FOnMessage write FOnMessage;
  end;

implementation

{ TMouseWheelRouting }

class procedure TMouseWheelRouting.AppMessage(var Msg: TMsg; var Handled: Boolean);
var
  Wnd: HWND;
  ProcessId: DWORD;
begin
  if (Msg.message = WM_MOUSEWHEEL) or (Msg.message = WM_MOUSEHWHEEL) then begin
    Wnd := WindowFromPoint(Msg.pt);

    if Wnd <> 0 then begin
      GetWindowThreadProcessId(Wnd, ProcessId);
      if ProcessId = FCurrentProcessId then
        SendMessage(Wnd, Msg.message, Msg.wParam, Msg.lParam);
    end;

    Handled := True;
  end;

  if Assigned(FOnMessage) then FOnMessage(Msg, Handled);
end;

class procedure TMouseWheelRouting.Init;
begin
  FCurrentProcessId := GetCurrentProcessId;
  FOnMessage := nil;
  Application.OnMessage := AppMessage;
end;

initialization
  TMouseWheelRouting.Init;

end.
