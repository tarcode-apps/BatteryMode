unit Helpers.Privileges;

interface

uses
  Winapi.Windows,
  System.SysUtils;

const
  // Privileges names
  SE_ASSIGNPRIMARYTOKEN_NAME = 'SeAssignPrimaryTokenPrivilege';
  SE_AUDIT_NAME = 'SeAuditPrivilege';
  SE_BACKUP_NAME = 'SeBackupPrivilege';
  SE_CHANGE_NOTIFY_NAME = 'SeChangeNotifyPrivilege';
  SE_CREATE_GLOBAL_NAME = 'SeCreateGlobalPrivilege';
  SE_CREATE_PAGEFILE_NAME = 'SeCreatePagefilePrivilege';
  SE_CREATE_PERMANENT_NAME = 'SeCreatePermanentPrivilege';
  SE_CREATE_TOKEN_NAME = 'SeCreateTokenPrivilege';
  SE_DEBUG_NAME = 'SeDebugPrivilege';
  SE_ENABLE_DELEGATION_NAME = 'SeEnableDelegationPrivilege';
  SE_IMPERSONATE_NAME = 'SeImpersonatePrivilege';
  SE_INC_BASE_PRIORITY_NAME = 'SeIncreaseBasePriorityPrivilege';
  SE_INCREASE_QUOTA_NAME = 'SeIncreaseQuotaPrivilege';
  SE_LOAD_DRIVER_NAME = 'SeLoadDriverPrivilege';
  SE_LOCK_MEMORY_NAME = 'SeLockMemoryPrivilege';
  SE_MACHINE_ACCOUNT_NAME = 'SeMachineAccountPrivilege';
  SE_MANAGE_VOLUME_NAME = 'SeManageVolumePrivilege';
  SE_PROF_SINGLE_PROCESS_NAME = 'SeProfileSingleProcessPrivilege';
  SE_REMOTE_SHUTDOWN_NAME = 'SeRemoteShutdownPrivilege';
  SE_RESTORE_NAME = 'SeRestorePrivilege';
  SE_SECURITY_NAME = 'SeSecurityPrivilege';
  SE_SHUTDOWN_NAME = 'SeShutdownPrivilege';
  SE_SYNC_AGENT_NAME = 'SeSyncAgentPrivilege';
  SE_SYSTEM_ENVIRONMENT_NAME = 'SeSystemEnvironment';
  SE_SYSTEM_PROFILE_NAME = 'SeSystemProfilePrivilege';
  SE_SYSTEMTIME_NAME = 'SeSystemtimePrivilege';
  SE_TAKE_OWNERSHIP_NAME = 'SeTakeOwnershipPrivilege';
  SE_TCB_NAME = 'SeTcbPrivilege';
  SE_UNDOCK_NAME = 'SeUndockPrivilege';
  SE_UNSOLICITED_INPUT_NAME = 'SeUnsolicitedInputPrivilege';

type
  IPrivilegesManager = interface
    function Enable(Name: string): Boolean;
    function Disable(Name: string): Boolean;
    function Check(Name: string): Boolean;
    function DisableAll: Boolean;
  end;

  TPrivilegesManager = class(TInterfacedObject, IPrivilegesManager)
  strict private
    FProcess: THandle;

    function CheckPrivilege(Process: THandle; lpszPrivilege: LPCTSTR): Boolean;
    function SetPrivilege(Process: THandle;
                      lpszPrivilege: LPCTSTR;         // name of privilege to enable/disable
                      bEnablePrivilege: BOOL;         // to enable or disable privilege
                      bDisableAllPrivileges: BOOL = False): BOOL;
  public
    constructor Create(Process: THandle); overload;
    constructor Create; overload;

    function Enable(Name: string): Boolean;
    function Disable(Name: string): Boolean;
    function Check(Name: string): Boolean;
    function DisableAll: Boolean;
  public
    class function Current: IPrivilegesManager;
  end;

implementation

{ TPrivilegesManager }

class function TPrivilegesManager.Current: IPrivilegesManager;
begin
  Result := TPrivilegesManager.Create;
end;

constructor TPrivilegesManager.Create;
begin
  Create(GetCurrentProcess);
end;

constructor TPrivilegesManager.Create(Process: THandle);
begin
  inherited Create;

  FProcess := Process;
end;

function TPrivilegesManager.Enable(Name: string): Boolean;
begin
  Result := SetPrivilege(FProcess, LPCTSTR(Name), True, False);
end;

function TPrivilegesManager.Disable(Name: string): Boolean;
begin
  Result := SetPrivilege(FProcess, LPCTSTR(Name), False, False);
end;

function TPrivilegesManager.Check(Name: string): Boolean;
begin
  Result := CheckPrivilege(FProcess, LPCTSTR(Name));
end;

function TPrivilegesManager.DisableAll: Boolean;
begin
  Result := SetPrivilege(FProcess, nil, False, True);
end;

function TPrivilegesManager.SetPrivilege(Process: THandle;
  lpszPrivilege: LPCTSTR; bEnablePrivilege: BOOL; bDisableAllPrivileges: BOOL): BOOL;
var
  TokenHandle: THandle;
  TokenPrivileges: TTokenPrivileges;
  newLuid: LUID;
  ReturnLength: DWORD;
begin
  if not OpenProcessToken(Process,
    TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, TokenHandle)
  then
    Exit(False);

  try
    if not bDisableAllPrivileges then
    begin
      if not LookupPrivilegeValue(nil, lpszPrivilege, TLargeInteger(newLuid)) then
        Exit(False);

      TokenPrivileges.PrivilegeCount := 1;
      TokenPrivileges.Privileges[0].Luid := TLargeInteger(newLuid);
      if bEnablePrivilege then
          TokenPrivileges.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED
      else
          TokenPrivileges.Privileges[0].Attributes := 0;
    end
    else
      ZeroMemory(@TokenPrivileges, SizeOf(TokenPrivileges));

    if not AdjustTokenPrivileges(TokenHandle,
                                 bDisableAllPrivileges,
                                 TokenPrivileges,
                                 SizeOf(TokenPrivileges),
                                 nil,
                                 ReturnLength) then
      Exit(False);

    if GetLastError = ERROR_NOT_ALL_ASSIGNED then
      Exit(False);

    Result := True;
  finally
    CloseHandle(TokenHandle);
  end;
end;

function TPrivilegesManager.CheckPrivilege(Process: THandle; lpszPrivilege: LPCTSTR): Boolean;
var
  Luid: TLargeInteger;
  TokenHandle: THandle;
  TokenInformation: Pointer;
  Size: Cardinal;
  I: Integer;
begin
  Result := False;

  if not LookupPrivilegeValue(nil, lpszPrivilege, Luid) then
    RaiseLastOSError;

  if not OpenProcessToken(Process, TOKEN_QUERY, TokenHandle) then
    RaiseLastOSError;

  try
    if not GetTokenInformation(TokenHandle, TokenPrivileges, nil, 0, Size) then
      if GetLastError <> ERROR_INSUFFICIENT_BUFFER then
        RaiseLastOSError;

    GetMem(TokenInformation, Size);
    try
      if not GetTokenInformation(TokenHandle, TokenPrivileges, TokenInformation, Size, Size) then
        RaiseLastOSError;

      with PTokenPrivileges(TokenInformation)^ do
      begin
        for I := 0 to PrivilegeCount - 1 do
          if Privileges[I].Luid = Luid then
            Exit(Privileges[I].Attributes and SE_PRIVILEGE_ENABLED = SE_PRIVILEGE_ENABLED);
      end;
    finally
      FreeMem(TokenInformation, Size);
    end;
  finally
    CloseHandle(TokenHandle);
  end;
end;

end.
