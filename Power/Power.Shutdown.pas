unit Power.Shutdown;

interface

uses
  Winapi.Windows,
  Helpers.Privileges, Helpers.Wts,
  Versions.Helpers,
  Power, Power.WinApi.Advapi32, Power.WinApi.PowrProf, Power.WinApi.Reason;

const
  {$EXTERNALSYM EWX_HYBRID_SHUTDOWN}
  EWX_HYBRID_SHUTDOWN = $00400000;

type
  TPowerBaseAction = class(TInterfacedObject, IPowerAction)
  protected
    function _GetActionType: TPowerActionType; virtual; abstract;
  public
    function Perform: Boolean; virtual;
    function IsSupported: Boolean; virtual;
  end;

  TPowerShutdownAction = class(TPowerBaseAction)
  protected
    function _GetActionType: TPowerActionType; override;
  public
    function Perform: Boolean; override;
  end;

  TPowerRebootAction = class(TPowerBaseAction)
  protected
    function _GetActionType: TPowerActionType; override;
  public
    function Perform: Boolean; override;
  end;

  TPowerSleepAction = class(TPowerBaseAction)
  protected
    function _GetActionType: TPowerActionType; override;
  public
    function Perform: Boolean; override;
    function IsSupported: Boolean; override;
  end;

  TPowerHibernateAction = class(TPowerBaseAction)
  protected
    function _GetActionType: TPowerActionType; override;
  public
    function Perform: Boolean; override;
    function IsSupported: Boolean; override;
  end;

  TPowerLogOutAction = class(TPowerBaseAction)
  protected
    function _GetActionType: TPowerActionType; override;
  public
    function Perform: Boolean; override;
  end;

  TPowerLockAction = class(TPowerBaseAction)
  protected
    function _GetActionType: TPowerActionType; override;
  public
    function Perform: Boolean; override;
  end;

  TPowerDiagnosticAction = class(TPowerBaseAction)
  protected
    function _GetActionType: TPowerActionType; override;
  public
    function Perform: Boolean; override;
    function IsSupported: Boolean; override;
  end;

  TPowerDisconnectAction = class(TPowerBaseAction)
  protected
    function _GetActionType: TPowerActionType; override;
  public
    function Perform: Boolean; override;
    function IsSupported: Boolean; override;
  end;

implementation

{ TPowerAction }

function TPowerBaseAction.Perform: Boolean;
begin
  Result := TPrivilegesManager.Current.Enable(SE_SHUTDOWN_NAME);
end;

function TPowerBaseAction.IsSupported: Boolean;
begin
  Result := True;
end;

{ TPowerShutdownAction }

function TPowerShutdownAction.Perform: Boolean;
var
  Flags: UINT;
begin
  Result := inherited;
  if not Result then Exit(False);

  Flags := EWX_POWEROFF;
  if IsWindows8OrGreater then
    Flags := Flags or EWX_HYBRID_SHUTDOWN;

  Result := ExitWindowsEx(Flags,
    SHTDN_REASON_MAJOR_OTHER or
    SHTDN_REASON_MINOR_OTHER or
    SHTDN_REASON_FLAG_PLANNED);
end;

function TPowerShutdownAction._GetActionType: TPowerActionType;
begin
  Result := patShutdown;
end;

{ TPowerRebootAction }

function TPowerRebootAction.Perform: Boolean;
begin
  Result := inherited;
  if not Result then Exit(False);

  Result := ExitWindowsEx(EWX_REBOOT,
    SHTDN_REASON_MAJOR_OTHER or
    SHTDN_REASON_MINOR_OTHER or
    SHTDN_REASON_FLAG_PLANNED);
end;

function TPowerRebootAction._GetActionType: TPowerActionType;
begin
  Result := patReboot;
end;

{ TPowerSleepAction }

function TPowerSleepAction.Perform: Boolean;
begin
  Result := inherited;
  if not Result then Exit(False);

  SetSuspendState(False, False, False);
end;

function TPowerSleepAction.IsSupported: Boolean;
var
  SystemPowerCapabilities: SYSTEM_POWER_CAPABILITIES;
begin
  if not GetPwrCapabilities(SystemPowerCapabilities) then
    Exit(False);

  with SystemPowerCapabilities do
    Result := SystemS1 or SystemS2 or SystemS3;
end;

function TPowerSleepAction._GetActionType: TPowerActionType;
begin
  Result := patSleep;
end;

{ TPowerHibernateAction }

function TPowerHibernateAction.Perform: Boolean;
begin
  Result := inherited;
  if not Result then Exit(False);

  SetSuspendState(True, False, False);
end;

function TPowerHibernateAction.IsSupported: Boolean;
var
  SystemPowerCapabilities: SYSTEM_POWER_CAPABILITIES;
begin
  if not GetPwrCapabilities(SystemPowerCapabilities) then
    Exit(False);

  with SystemPowerCapabilities do
    Result := SystemS4 and HiberFilePresent;
end;

function TPowerHibernateAction._GetActionType: TPowerActionType;
begin
  Result := patHibernate;
end;

{ TPowerLogOutAction }

function TPowerLogOutAction.Perform: Boolean;
begin
  Result := inherited;
  if not Result then Exit(False);

  Result := ExitWindowsEx(EWX_LOGOFF,
    SHTDN_REASON_MAJOR_OTHER or
    SHTDN_REASON_MINOR_OTHER or
    SHTDN_REASON_FLAG_PLANNED);
end;

function TPowerLogOutAction._GetActionType: TPowerActionType;
begin
  Result := patLogOut;
end;

{ TPowerLockAction }

function TPowerLockAction.Perform: Boolean;
begin
  Result := LockWorkStation;
end;

function TPowerLockAction._GetActionType: TPowerActionType;
begin
  Result := patLock;
end;

{ TPowerDiagnosticAction }

function TPowerDiagnosticAction.Perform: Boolean;
begin
  Result := inherited;
  if not Result then Exit(False);

  Result := InitiateShutdown(nil, nil, 0,
    SHUTDOWN_RESTART or SHUTDOWN_DIAGNOSTIC or SHUTDOWN_FORCE_OTHERS,
    SHTDN_REASON_MAJOR_OTHER or
    SHTDN_REASON_MINOR_OTHER or
    SHTDN_REASON_FLAG_PLANNED) = ERROR_SUCCESS;
end;

function TPowerDiagnosticAction.IsSupported: Boolean;
begin
  Result := IsWindows8OrGreater;
end;

function TPowerDiagnosticAction._GetActionType: TPowerActionType;
begin
  Result := patDiagnostic;
end;

{ TPowerDisconnectAction }

function TPowerDisconnectAction.Perform: Boolean;
begin
  Result := WTSDisconnectSession(WTS_CURRENT_SERVER_HANDLE, WTS_CURRENT_SESSION, False);
end;

function TPowerDisconnectAction.IsSupported: Boolean;
begin
  Result := GetSystemMetrics(SM_REMOTESESSION) <> 0;
end;

function TPowerDisconnectAction._GetActionType: TPowerActionType;
begin
  Result := patDisconnect;
end;

end.
