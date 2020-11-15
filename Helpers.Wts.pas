unit Helpers.Wts;

interface

uses
  Winapi.Windows;

const
  { Specifies the current server }
  WTS_CURRENT_SERVER        = THandle(0);
  WTS_CURRENT_SERVER_HANDLE = THandle(0);
  WTS_CURRENT_SERVER_NAME    = nil;

  { Specifies the current session (SessionId) }
  WTS_CURRENT_SESSION = DWORD(-1);

  { Specifies any-session (SessionId) }
  WTS_ANY_SESSION = DWORD(-2);

  WTS_SESSION_DETACHED = $FFFFFFFF;

const
  { WTS_EVENT - Event flags for WTSWaitSystemEvent }
  WTS_EVENT_NONE        = DWORD($00000000); // return no event
  WTS_EVENT_CREATE      = DWORD($00000001); // new WinStation created
  WTS_EVENT_DELETE      = DWORD($00000002); // existing WinStation deleted
  WTS_EVENT_RENAME      = DWORD($00000004); // existing WinStation renamed
  WTS_EVENT_CONNECT     = DWORD($00000008); // WinStation connect to client
  WTS_EVENT_DISCONNECT  = DWORD($00000010); // WinStation logged on without client
  WTS_EVENT_LOGON       = DWORD($00000020); // user logged on to existing WinStation
  WTS_EVENT_LOGOFF      = DWORD($00000040); // user logged off from existing WinStation
  WTS_EVENT_STATECHANGE = DWORD($00000080); // WinStation state change
  WTS_EVENT_LICENSE     = DWORD($00000100); // license state change
  WTS_EVENT_ALL         = DWORD($7fffffff); // wait for all event types
  WTS_EVENT_FLUSH       = DWORD($80000000); // unblock all waiters

const
  AF_INET     = 2;      // internetwork: UDP, TCP, etc.
  AF_NS       = 6;      // XEROX NS protocols
  AF_IPX      = AF_NS;  // IPX protocols: IPX, SPX, etc.
  AF_NETBIOS  = 17;     // NetBios-style addresses
  AF_UNSPEC   = 0;      // unspecified

type
  { WTS_CONNECTSTATE_CLASS - Session connect state }
  {$MinEnumSize 4}
  {$EXTERNALSYM WTS_CONNECTSTATE_CLASS}
  WTS_CONNECTSTATE_CLASS = (
    WTSActive,            // User logged on to WinStation
    WTSConnected,         // WinStation connected to client
    WTSConnectQuery,      // In the process of connecting to client
    WTSShadow,            // Shadowing another WinStation
    WTSDisconnected,      // WinStation logged on without client
    WTSIdle,              // Waiting for client to connect
    WTSListen,            // WinStation is listening for connection
    WTSReset,             // WinStation is being reset
    WTSDown,              // WinStation is down due to error
    WTSInit);             // WinStation in initialization

  {$EXTERNALSYM _WTS_SESSION_INFO}
  _WTS_SESSION_INFO = record
    SessionId: DWORD;               // session id
    pWinStationName: LPTSTR;        // name of WinStation this session is connected to
    State: WTS_CONNECTSTATE_CLASS;  // connection state (see enum)
  end;
  {$EXTERNALSYM WTS_SESSION_INFO}
  WTS_SESSION_INFO = _WTS_SESSION_INFO;
  {$EXTERNALSYM PWTS_SESSION_INFO}
  PWTS_SESSION_INFO = ^WTS_SESSION_INFO;

  {$MinEnumSize 4}
  {$EXTERNALSYM WTS_INFO_CLASS}
  WTS_INFO_CLASS = (
    WTSInitialProgram,
    WTSApplicationName,
    WTSWorkingDirectory,
    WTSOEMId,
    WTSSessionId,
    WTSUserName,
    WTSWinStationName,
    WTSDomainName,
    WTSConnectState,
    WTSClientBuildNumber,
    WTSClientName,
    WTSClientDirectory,
    WTSClientProductId,
    WTSClientHardwareId,
    WTSClientAddress,
    WTSClientDisplay,
    WTSClientProtocolType,
    WTSIdleTime,
    WTSLogonTime,
    WTSIncomingBytes,
    WTSOutgoingBytes,
    WTSIncomingFrames,
    WTSOutgoingFrames,
    WTSClientInfo,
    WTSSessionInfo,
    WTSSessionInfoEx,
    WTSConfigInfo,
    WTSValidationInfo,   // Info Class value used to fetch Validation Information through the WTSQuerySessionInformation
    WTSSessionAddressV4,
    WTSIsRemoteSession);

  {$EXTERNALSYM _WTS_CLIENT_ADDRESS}
  _WTS_CLIENT_ADDRESS = record
    AddressFamily: DWORD;           // AF_INET, AF_IPX, AF_NETBIOS, AF_UNSPEC
    Address: array [0..19] of BYTE; // client network address
  end;
  {$EXTERNALSYM WTS_CLIENT_ADDRESS}
  WTS_CLIENT_ADDRESS = _WTS_CLIENT_ADDRESS;
  {$EXTERNALSYM PWTS_CLIENT_ADDRESS}
  PWTS_CLIENT_ADDRESS = ^WTS_CLIENT_ADDRESS;

{$EXTERNALSYM WTSWaitSystemEvent}
function WTSWaitSystemEvent(
  hServer: THandle;
  EventMask: DWORD;
  var pEventFlags: DWORD): BOOL; stdcall; external wtsapi32;

{$EXTERNALSYM WTSEnumerateSessions}
function WTSEnumerateSessions(
  hServer: THandle;
  Reserved: DWORD;
  Version: DWORD;
  var ppSessionInfo: PWTS_SESSION_INFO;
  var pCount: DWORD): BOOL; stdcall; external wtsapi32
  {$IFDEF UNICODE}
  name 'WTSEnumerateSessionsW'
  {$ELSE}
  name 'WTSEnumerateSessionsA'
  {$ENDIF};

{$EXTERNALSYM WTSQuerySessionInformation}
function WTSQuerySessionInformation(
  hServer: THandle;
  SessionId: DWORD;
  WTSInfoClass: WTS_INFO_CLASS;
  var ppBuffer: LPTSTR;
  var pBytesReturned: DWORD): BOOL; stdcall; external wtsapi32
  {$IFDEF UNICODE}
  name 'WTSQuerySessionInformationW'
  {$ELSE}
  name 'WTSQuerySessionInformationA'
  {$ENDIF};

{$EXTERNALSYM WTSFreeMemory}
procedure WTSFreeMemory(pMemory: PVOID); stdcall; external wtsapi32;

{$EXTERNALSYM WTSQueryUserToken}
function WTSQueryUserToken(
  SessionId: ULONG;
  var phToken: THandle): BOOL; stdcall; external wtsapi32;

{$EXTERNALSYM WTSDisconnectSession}
function WTSDisconnectSession(
  hServer: THandle;
  SessionId: DWORD;
  bWait: BOOL): BOOL; stdcall; external wtsapi32;

function QuerySessionInformation(hServer: THandle; SessionId: DWORD;
  WTSInfoClass: WTS_INFO_CLASS): string;

function GetSessionUserName(SessionId: DWORD): string;
function GetSessionDomainName(SessionId: DWORD): string;

function GetCurrentSessionUserName: string;
function GetCurrentSessionDomainName: string;

function GetProcessSessionUserName(ProcessId: DWORD): string;
function GetProcessSessionDomainName(ProcessId: DWORD): string;

function GetCurrentProcessSessionUserName: string;
function GetCurrentProcessSessionDomainName: string;

implementation

function QuerySessionInformation(hServer: THandle; SessionId: DWORD;
  WTSInfoClass: WTS_INFO_CLASS): string;
var
  ppBuffer: LPTSTR;
  pBytesReturned: DWORD;
begin
  try
    if not WTSQuerySessionInformation(hServer, SessionId, WTSInfoClass,
                                      ppBuffer, pBytesReturned) then Exit('');
    SetString(Result, ppBuffer, pBytesReturned div SizeOf(Char) - 1);
  finally
    WTSFreeMemory(ppBuffer);
  end;
end;


function GetSessionUserName(SessionId: DWORD): string;
begin
  Result := QuerySessionInformation(WTS_CURRENT_SERVER_HANDLE, SessionId, WTS_INFO_CLASS.WTSUserName);
end;

function GetSessionDomainName(SessionId: DWORD): string;
begin
  Result := QuerySessionInformation(WTS_CURRENT_SERVER_HANDLE, SessionId, WTS_INFO_CLASS.WTSDomainName);
end;


function GetCurrentSessionUserName: string;
begin
  Result := GetSessionUserName(WTS_CURRENT_SESSION);
end;

function GetCurrentSessionDomainName: string;
begin
  Result := GetSessionDomainName(WTS_CURRENT_SESSION);
end;


function GetProcessSessionUserName(ProcessId: DWORD): string;
var
  SessionId: DWORD;
begin
  if not ProcessIdToSessionId(GetCurrentProcessId, @SessionId) then Exit('');
  Result := GetSessionUserName(SessionId);
end;

function GetProcessSessionDomainName(ProcessId: DWORD): string;
var
  SessionId: DWORD;
begin
  if not ProcessIdToSessionId(GetCurrentProcessId, @SessionId) then Exit('');
  Result := GetSessionDomainName(SessionId);
end;


function GetCurrentProcessSessionUserName: string;
begin
  Result := GetProcessSessionUserName(GetCurrentProcessId);
end;

function GetCurrentProcessSessionDomainName: string;
begin
  Result := GetProcessSessionDomainName(GetCurrentProcessId);
end;

end.
