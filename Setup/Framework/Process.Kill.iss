#ifndef _ProcessKill
	#define _ProcessKill

#include "Windows.Api.iss"

[Code]

//
// Functions for shutting down processes
//

procedure SendCloseMessageByWindowName(WindowName: string);
var
	Wnd: HWND;
begin
	Wnd := FindWindowByWindowName(WindowName);
	MsgBox(IntToStr(Wnd), mbInformation, MB_OK);
	if Wnd <> 0 then SendMessage(Wnd, WM_CLOSE, 0, 0);
end;

procedure SendCloseMessageByClassName(ClassName: string);
var
	Wnd: HWND;
begin
	Wnd := FindWindowByClassName(ClassName);
	if Wnd <> 0 then SendMessage(Wnd, WM_CLOSE, 0, 0);
end;

procedure SendDestroyMessageByWindowName(WindowName: string);
var
	Wnd: HWND;
begin
	Wnd := FindWindowByWindowName(WindowName);
	if Wnd <> 0 then SendMessage(Wnd, WM_DESTROY, 0, 0);
end;

procedure SendDestroyMessageByClassName(ClassName: string);
var
	Wnd: HWND;
begin
	Wnd := FindWindowByClassName(ClassName);
	if Wnd <> 0 then SendMessage(Wnd, WM_DESTROY, 0, 0);
end;

function TaskKill(FileName: String): Boolean;
var
	ResultCode: Integer;
begin
	Result := Exec(ExpandConstant('taskkill.exe'), '/f /im ' + '"' + FileName + '"', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
end;

#endif
