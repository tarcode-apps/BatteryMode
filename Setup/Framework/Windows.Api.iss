#ifndef _WindowsApi
	#define _WindowsApi

[Code]

//
// WinAPI
//

const
	WM_DESTROY = $0002;
	WM_CLOSE = $0010;

type
	HINSTANCE = THandle;
	
procedure ExitProcess(uExitCode: UINT);
	external 'ExitProcess@kernel32.dll stdcall';

function ShellExecute(hwnd: HWND; lpOperation: string; lpFile: string;
	lpParameters: string; lpDirectory: string; nShowCmd: Integer): HINSTANCE;
	external 'ShellExecuteW@shell32.dll stdcall';

function SetFocus(hWnd: HWND): HWND;
	external 'SetFocus@user32.dll stdcall';

#endif
