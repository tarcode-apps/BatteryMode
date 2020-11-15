unit Power.WinApi.PowrProf.Legacy;

interface

uses
  Winapi.Windows,
  Power.WinApi.PowrProf;

{*******************************************************}
{             PowrProf Win32 API type                   }
{*******************************************************}

const
  POWER_ACTION_CRITICAL         = 1; //Forces a critical suspension.
  POWER_ACTION_DISABLE_WAKES    = 2; //Disables all wake events.
  POWER_ACTION_LIGHTEST_FIRST   = 4; //Uses the first lightest available sleep state.
  POWER_ACTION_LOCK_CONSOLE     = 8 ; //Requires entry of the system password upon resume from one of the system standby states.
  POWER_ACTION_OVERRIDE_APPS    = 16; //Ignores applications that do not respond to the PBT_APMQUERYSUSPEND event broadcast in the WM_POWERBROADCAST message.
  POWER_ACTION_QUERY_ALLOWED    = 32; //Broadcasts a PBT_APMQUERYSUSPEND event to each application to request permission to suspend operation.
  POWER_ACTION_UI_ALLOWED       = 64;

  POWER_FORCE_TRIGGER_RESET     = 1; //Clears a user power button press.
  POWER_LEVEL_USER_NOTIFY_EXEC  = 2; //Specifies a program to be executed.
  POWER_LEVEL_USER_NOTIFY_SOUND = 4; //User notified using sound.
  POWER_LEVEL_USER_NOTIFY_TEXT  = 8; //User notified using the UI.
  POWER_USER_NOTIFY_BUTTON      = 16; //Indicates that the power action is in response to a user power button press.
  POWER_USER_NOTIFY_SHUTDOWN    = 32;

type
  {$MinEnumSize 4}
  {$EXTERNALSYM POWER_ACTION}
  POWER_ACTION = (PowerActionNone,
                  PowerActionReserved,
                  PowerActionSleep,
                  PowerActionHibernate,
                  PowerActionShutdown,
                  PowerActionShutdownReset,
                  PowerActionShutdownOff,
                  PowerActionWarmEject);

  {$MinEnumSize 4}
  {$EXTERNALSYM POWER_INFORMATION_LEVEL}
  POWER_INFORMATION_LEVEL = (AdministratorPowerPolicy,
                             LastSleepTime,
                             LastWakeTime,
                             ProcessorInformation,
                             ProcessorPowerPolicyAc,
                             ProcessorPowerPolicyCurrent,
                             ProcessorPowerPolicyDc,
                             SystemBatteryState,
                             SystemExecutionState,
                             SystemPowerCapabilities,
                             SystemPowerInformation,
                             SystemPowerPolicyAc,
                             SystemPowerPolicyCurrent,
                             SystemPowerPolicyDc,
                             SystemReserveHiberFile,
                             VerifyProcessorPowerPolicyAc,
                             VerifyProcessorPowerPolicyDc,
                             VerifySystemPolicyAc,
                             VerifySystemPolicyDc);

  {$EXTERNALSYM POWER_ACTION_POLICY}
  POWER_ACTION_POLICY = record
    Action: POWER_ACTION;
    Flags: ULONG;
    EventCode: ULONG;
  end;
  {$EXTERNALSYM PPOWER_ACTION_POLICY}
  PPOWER_ACTION_POLICY = ^POWER_ACTION_POLICY;

  {$EXTERNALSYM SYSTEM_POWER_LEVEL}
  SYSTEM_POWER_LEVEL = record
    Enable: Boolean;
    Spare: array[0..2] of UCHAR;
    BatteryLevel: ULONG;
    PowerPolicy: POWER_ACTION_POLICY;
    MinSystemState: SYSTEM_POWER_STATE;
  end;
  {$EXTERNALSYM PSYSTEM_POWER_LEVEL}
  PSYSTEM_POWER_LEVEL = ^SYSTEM_POWER_LEVEL;

  {$EXTERNALSYM USER_POWER_POLICY}
  USER_POWER_POLICY = record
    Revision: ULONG;
    IdleAc: POWER_ACTION_POLICY;
    IdleDc: POWER_ACTION_POLICY;
    IdleTimeoutAc: ULONG;
    IdleTimeoutDc: ULONG;
    IdleSensitivityAc: UCHAR;
    IdleSensitivityDc: UCHAR;
    ThrottlePolicyAc: UCHAR;
    ThrottlePolicyDc: UCHAR;
    MaxSleepAc: SYSTEM_POWER_STATE;
    MaxSleepDc: SYSTEM_POWER_STATE;
    Reserved: array[0..1] of ULONG;
    VideoTimeoutAc: ULONG;
    VideoTimeoutDc: ULONG;
    SpindownTimeoutAc: ULONG;
    SpindownTimeoutDc: ULONG;
    OptimizeForPowerAc: Boolean;
    OptimizeForPowerDc: Boolean;
    FanThrottleToleranceAc: UCHAR;
    FanThrottleToleranceDc: UCHAR;
    ForcedThrottleAc: UCHAR;
    ForcedThrottleDc: UCHAR;
  end;
  {$EXTERNALSYM PUSER_POWER_POLICY}
  PUSER_POWER_POLICY = USER_POWER_POLICY;

  {$EXTERNALSYM GLOBAL_USER_POWER_POLICY}
  GLOBAL_USER_POWER_POLICY = record
    Revision: ULONG;
    PowerButtonAc: POWER_ACTION_POLICY;
    PowerButtonDc: POWER_ACTION_POLICY;
    SleepButtonAc: POWER_ACTION_POLICY;
    SleepButtonDc: POWER_ACTION_POLICY;
    LidCloseAc: POWER_ACTION_POLICY;
    LidCloseDc: POWER_ACTION_POLICY;
    DischargePolicy: array of SYSTEM_POWER_LEVEL;
    GlobalFlags: ULONG;
  end;
  {$EXTERNALSYM PGLOBAL_USER_POWER_POLICY}
  PGLOBAL_USER_POWER_POLICY = ^GLOBAL_USER_POWER_POLICY;

  {$EXTERNALSYM MACHINE_POWER_POLICY}
  MACHINE_POWER_POLICY = record
    Revision: ULONG;
    MinSleepAc: SYSTEM_POWER_STATE;
    MinSleepDc: SYSTEM_POWER_STATE;
    ReducedLatencySleepAc: SYSTEM_POWER_STATE;
    ReducedLatencySleepDc: SYSTEM_POWER_STATE;
    DozeTimeoutAc: ULONG;
    DozeTimeoutDc: ULONG;
    DozeS4TimeoutAc: ULONG;
    DozeS4TimeoutDc: ULONG;
    MinThrottleAc: UCHAR;
    MinThrottleDc: UCHAR;
    pad1: array[0..1] of UCHAR;
    OverThrottledAc: POWER_ACTION_POLICY;
    OverThrottledDc: POWER_ACTION_POLICY;
  end;
  {$EXTERNALSYM PMACHINE_POWER_POLICY}
  PMACHINE_POWER_POLICY = ^MACHINE_POWER_POLICY;

  {$EXTERNALSYM GLOBAL_MACHINE_POWER_POLICY}
  GLOBAL_MACHINE_POWER_POLICY = record
    Revision: ULONG;
    LidOpenWakeAc: SYSTEM_POWER_STATE;
    LidOpenWakeDc: SYSTEM_POWER_STATE;
    BroadcastCapacityResolution: ULONG;
  end;
  {$EXTERNALSYM PGLOBAL_MACHINE_POWER_POLICY}
  PGLOBAL_MACHINE_POWER_POLICY = ^GLOBAL_MACHINE_POWER_POLICY;

  {$EXTERNALSYM POWER_POLICY}
  POWER_POLICY = record
    user: USER_POWER_POLICY;
    mach: MACHINE_POWER_POLICY;
  end;
  {$EXTERNALSYM PPOWER_POLICY}
  PPOWER_POLICY = ^POWER_POLICY;

  {$EXTERNALSYM GLOBAL_POWER_POLICY}
  GLOBAL_POWER_POLICY = record
    user: GLOBAL_USER_POWER_POLICY;
    mach: GLOBAL_MACHINE_POWER_POLICY;
  end;
  {$EXTERNALSYM PGLOBAL_POWER_POLICY}
  PGLOBAL_POWER_POLICY = ^GLOBAL_POWER_POLICY;

  PWRSCHEMESENUMPROC = function(
    uiIndex: UINT;      // power scheme index
    dwName: DWORD;      // size of the sName string, in bytes
    sName: LPTSTR;      // name of the power scheme
    dwDesc: DWORD;      // size of the sDesc string, in bytes
    sDesc: LPTSTR;      // description string
    pp: PPOWER_POLICY;  // receives the power policy
    lParam: LPARAM      // user-defined value
    ): Boolean; stdcall;

{*******************************************************}
{             PowrProf Win32 API function               }
{*******************************************************}

{$EXTERNALSYM CanUserWritePwrScheme}
function CanUserWritePwrScheme: Boolean; stdcall;

{$EXTERNALSYM GetActivePwrScheme}
function GetActivePwrScheme(out uiIndex: UINT): Boolean; stdcall;

{$EXTERNALSYM SetActivePwrScheme}
function SetActivePwrScheme(
  uiID: UINT;
  lpGlobalPowerPolicy: PGLOBAL_POWER_POLICY;
  lpPowerPolicy: PPOWER_POLICY): Boolean; stdcall;

{$EXTERNALSYM GetCurrentPowerPolicies}
function GetCurrentPowerPolicies(
  pGlobalPowerPolicy: PGLOBAL_POWER_POLICY;
  pPowerPolicy: PPOWER_POLICY): Boolean; stdcall;

{$EXTERNALSYM ReadGlobalPwrPolicy}
function ReadGlobalPwrPolicy(out pGlobalPowerPolicy: GLOBAL_POWER_POLICY): Boolean; stdcall;

{$EXTERNALSYM WriteGlobalPwrPolicy}
function WriteGlobalPwrPolicy(var pGlobalPowerPolicy: GLOBAL_POWER_POLICY): Boolean; stdcall;

{$EXTERNALSYM ReadPwrScheme}
function ReadPwrScheme(
  uiID: UINT;
  out pPowerPolicy: POWER_POLICY): Boolean; stdcall;

{$EXTERNALSYM WritePwrScheme}
function WritePwrScheme(
  uiID: UINT;
  lpszName: LPTSTR;
  lpszDescription: LPTSTR;
  pPowerPolicy: PPOWER_POLICY): Boolean; stdcall;

{$EXTERNALSYM DeletePwrScheme}
function DeletePwrScheme(uiIndex: UINT): Boolean; stdcall;

{$EXTERNALSYM EnumPwrSchemes}
function EnumPwrSchemes(
  EnumPwrSchemesProc: PWRSCHEMESENUMPROC;
  lParam: LPARAM): Boolean; stdcall;

{$EXTERNALSYM GetPwrDiskSpindownRange}
function GetPwrDiskSpindownRange(
  out RangeMax: UINT;
  out RangeMin: UINT): Boolean; stdcall;

{$EXTERNALSYM IsAdminOverrideActive}
function IsAdminOverrideActive: Boolean; stdcall;

{$EXTERNALSYM IsPwrHibernateAllowed}
function IsPwrHibernateAllowed: Boolean; stdcall;

{$EXTERNALSYM IsPwrShutdownAllowed}
function IsPwrShutdownAllowed: Boolean; stdcall;

{$EXTERNALSYM IsPwrSuspendAllowed}
function IsPwrSuspendAllowed: Boolean; stdcall;

implementation

{$WARN SYMBOL_PLATFORM OFF}
function CanUserWritePwrScheme; external PWR_PROF delayed;
function GetActivePwrScheme; external PWR_PROF delayed;
function SetActivePwrScheme; external PWR_PROF delayed;
function GetCurrentPowerPolicies; external PWR_PROF delayed;
function ReadGlobalPwrPolicy; external PWR_PROF delayed;
function WriteGlobalPwrPolicy; external PWR_PROF delayed;
function ReadPwrScheme; external PWR_PROF delayed;
function WritePwrScheme; external PWR_PROF delayed;
function DeletePwrScheme; external PWR_PROF delayed;
function EnumPwrSchemes; external PWR_PROF delayed;
function GetPwrDiskSpindownRange; external PWR_PROF delayed;
function IsAdminOverrideActive; external PWR_PROF delayed;
function IsPwrHibernateAllowed; external PWR_PROF delayed;
function IsPwrShutdownAllowed; external PWR_PROF delayed;
function IsPwrSuspendAllowed; external PWR_PROF delayed;
{$WARN SYMBOL_PLATFORM ON}

end.
