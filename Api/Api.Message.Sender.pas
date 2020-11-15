unit Api.Message.Sender;

interface

uses
  WinApi.Windows,
  Api.Message;

function FindMainWindow: HWND;
function SendNextSchemeMessage(NextSchemeType: TNextSchemeType): Boolean;
function SendNextSchemeMessageAsync(NextSchemeType: TNextSchemeType): Boolean;

implementation

function FindMainWindow: HWND;
begin
  Result := FindWindow(MainWindowClass, MainWindowName);
end;

function SendNextSchemeMessage(NextSchemeType: TNextSchemeType): Boolean;
var
  wnd: THandle;
begin
  wnd := FindMainWindow;
  if wnd = 0 then Exit(False);

  Result := SendMessage(wnd, WM_NEXT_SCHEME, WPARAM(NextSchemeType), 0) = NextSchemeConfirm;
end;

function SendNextSchemeMessageAsync(NextSchemeType: TNextSchemeType): Boolean;
var
  wnd: THandle;
begin
  wnd := FindMainWindow;
  if wnd = 0 then Exit(False);

  Result := PostMessage(wnd, WM_NEXT_SCHEME, WPARAM(NextSchemeType), 0);
end;

end.
