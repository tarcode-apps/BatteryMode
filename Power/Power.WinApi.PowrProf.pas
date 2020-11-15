unit Power.WinApi.PowrProf;

interface

uses
  Winapi.Windows;

const
  PWR_PROF  = 'PowrProf.dll';

{*******************************************************}
{             PowrProf Win32 API type                   }
{*******************************************************}

type
  {$MinEnumSize 4}
  {$EXTERNALSYM SYSTEM_POWER_CONDITION}
  SYSTEM_POWER_CONDITION = (
    PoAc                = 0,  // The computer is powered by an AC power source
    PoDc                = 1,  // The system is receiving power from built-in batteries.
    PoHot               = 2,  // The computer is powered by a short-term power source such as a UPS device.
    PoConditionMaximum  = 3   // Values equal to or greater than this value indicate an out of range value.
  );
  TSystemPowerCondition = SYSTEM_POWER_CONDITION;
  PSystemPowerCondition = ^SYSTEM_POWER_CONDITION;

  {$MinEnumSize 4}
  {$EXTERNALSYM SYSTEM_POWER_STATE}
  SYSTEM_POWER_STATE = (
    PowerSystemUnspecified  = 0, // A lid-open event does not wake the system.
    PowerSystemWorking      = 1, // Specifies system power state S0.
    PowerSystemSleeping1    = 2, // Specifies system power state S1.
    PowerSystemSleeping2    = 3, // Specifies system power state S2.
    PowerSystemSleeping3    = 4, // Specifies system power state S3.
    PowerSystemHibernate    = 5, // Specifies system power state S4 (HIBERNATE).
    PowerSystemShutdown     = 6, // Specifies system power state S5 (OFF).
    PowerSystemMaximum      = 7);// Specifies the maximum enumeration value.

  {$EXTERNALSYM BATTERY_REPORTING_SCALE}
  BATTERY_REPORTING_SCALE = packed record
    Granularity : ULONG;
    Capacity    : ULONG;
  end;
  {$EXTERNALSYM PBATTERY_REPORTING_SCALE}
  PBATTERY_REPORTING_SCALE = ^BATTERY_REPORTING_SCALE;

  {$EXTERNALSYM SYSTEM_POWER_CAPABILITIES}
  SYSTEM_POWER_CAPABILITIES = record
    // If this member is TRUE, there is a system power button.
    PowerButtonPresent: Boolean;
    // If this member is TRUE, there is a system sleep button.
    SleepButtonPresent: Boolean;
    // If this member is TRUE, there is a lid switch.
    LidPresent: Boolean;
    // If this member is TRUE, the operating system supports sleep state S1.
    SystemS1: Boolean;
    // If this member is TRUE, the operating system supports sleep state S2.
    SystemS2: Boolean;
    // If this member is TRUE, the operating system supports sleep state S3.
    SystemS3: Boolean;
    // If this member is TRUE, the operating system supports sleep state S4 (hibernation).
    SystemS4: Boolean;
    // If this member is TRUE, the operating system supports power off state S5 (soft off).
    SystemS5: Boolean;
    // If this member is TRUE, the system hibernation file is present.
    HiberFilePresent: Boolean;
    // If this member is TRUE, the system supports wake capabilities.
    FullWake: Boolean;
    // If this member is TRUE, the system supports video display dimming capabilities.
    VideoDimPresent: Boolean;
    // If this member is TRUE, the system supports APM BIOS power management features.
    ApmPresent: Boolean;
    // If this member is TRUE, there is an uninterruptible power supply (UPS).
    UpsPresent: Boolean;
    // If this member is TRUE, the system supports thermal zones.
    ThermalControl: Boolean;
    // If this member is TRUE, the system supports processor throttling.
    ProcessorThrottle: Boolean;
    // The minimum level of system processor throttling supported,
    // expressed as a percentage.
    ProcessorMinThrottle: Byte;
    // The maximum level of system processor throttling supported,
    // expressed as a percentage.
    ProcessorMaxThrottle: Byte;
    // If this member is TRUE, the system supports the hybrid sleep state.
    // Windows Server 2003 and Windows XP:  Hybrid sleep is not supported.
    // Windows 2000:  This member is not supported.
    FastSystemS4: Boolean;
    // If this member is set to TRUE, the system is currently capable of performing a fast startup transition.
    // This setting is based on whether the machine is capable of hibernate,
    // whether the machine currently has hibernate enabled (hiberfile exists),
    // and the local and group policy settings for using hibernate (including the Hibernate option in the Power control panel).
    HiberBoot: Boolean;
    // If this member is TRUE, the platform has support for ACPI wake alarm devices.
    // For more details on wake alarm devices, please see the ACPI specification section 9.18.
    WakeAlarmPresent: Boolean;
    // If this member is TRUE, the system supports the connected standby power model.
    // Windows XP, Windows Server 2003, Windows Vista, Windows Server 2008, Windows 7,
    // and Windows Server 2008 R2:  This value is supported starting in Windows 8 and Windows Server 2012
    AoAc: Boolean;
    // If this member is TRUE, the system supports allowing the removal of power
    // to fixed disk devices.
    DiskSpinDown: Boolean;
    // reserved
    spare3: array [0 .. 7] of Byte;
    // If this member is TRUE, there are one or more batteries in the system.
    SystemBatteriesPresent: Boolean;
    // If this member is TRUE, the system batteries are short-term.
    // Short-term batteries are used in uninterruptible power supplies (UPS).
    BatteriesAreShortTerm: Boolean;
    // A BATTERY_REPORTING_SCALE structure that contains information about
    // how system battery metrics are reported.
    BatteryScale: array [0 .. 2] of BATTERY_REPORTING_SCALE;
    // The lowest system sleep state (Sx) that will generate a wake event when
    // the system is on AC power. This member must be one of the
    // SYSTEM_POWER_STATE enumeration type values.
    AcOnLineWake: SYSTEM_POWER_STATE;
    // The lowest system sleep state (Sx) that will generate a wake event via
    // the lid switch. This member must be one of the SYSTEM_POWER_STATE
    // enumeration type values.
    SoftLidWake: SYSTEM_POWER_STATE;
    // To wake the computer using the RTC, the operating system must also
    // support waking from the sleep state the computer is in when the RTC
    // generates the wake event. Therefore, the effective lowest sleep state
    // from which an RTC wake event can wake the computer is the lowest sleep
    // state supported by the operating system that is equal to or higher than
    // the value of RtcWake. To determine the sleep states that the operating
    // system supports, check the SystemS1, SystemS2, SystemS3, and SystemS4 members.
    RtcWake: SYSTEM_POWER_STATE;
    // The minimum allowable system power state supporting wake events.
    // This member must be one of the SYSTEM_POWER_STATE enumeration type values.
    // Note that this state may change as different device drivers are
    // installed on the system.
    MinDeviceWakeState: SYSTEM_POWER_STATE;
    // The default system power state used if an application calls
    // RequestWakeupLatency with LT_LOWEST_LATENCY. This member must be one of
    // the SYSTEM_POWER_STATE enumeration type values.
    DefaultLowLatencyWake: SYSTEM_POWER_STATE;
  end;
  {$EXTERNALSYM PSYSTEM_POWER_CAPABILITIES}
  PSYSTEM_POWER_CAPABILITIES = ^SYSTEM_POWER_CAPABILITIES;

  {$MinEnumSize 4}
  {$EXTERNALSYM POWER_INFORMATION_LEVEL}
  POWER_INFORMATION_LEVEL = (
    AdministratorPowerPolicy      = 9,
    LastSleepTime                 = 15,
    LastWakeTime                  = 14,
    ProcessorInformation          = 11,
    ProcessorPowerPolicyAc        = 18,
    ProcessorPowerPolicyCurrent   = 22,
    ProcessorPowerPolicyDc        = 19,
    SystemBatteryState            = 5,
    SystemExecutionState          = 16,
    SystemPowerCapabilities       = 4,
    SystemPowerInformation        = 12,
    SystemPowerPolicyAc           = 0,
    SystemPowerPolicyCurrent      = 8,
    SystemPowerPolicyDc           = 1,
    SystemReserveHiberFile        = 10,
    VerifyProcessorPowerPolicyAc  = 20,
    VerifyProcessorPowerPolicyDc  = 21,
    VerifySystemPolicyAc          = 2,
    VerifySystemPolicyDc          = 3);

  {$MinEnumSize 4}
  {$EXTERNALSYM SYSTEM_BATTERY_STATE}
  SYSTEM_BATTERY_STATE = packed record
    AcOnLine          : BOOLEAN;
    BatteryPresent    : BOOLEAN;
    Charging          : BOOLEAN;
    Discharging       : BOOLEAN;
    Spare1: array [0..3] of BOOLEAN;
    MaxCapacity       : DWORD;
    RemainingCapacity : DWORD;
    Rate              : LONG;
    EstimatedTime     : DWORD;
    DefaultAlert1     : DWORD;
    DefaultAlert2     : DWORD;
  end;
  {$EXTERNALSYM PSYSTEM_BATTERY_STATE}
  PSYSTEM_BATTERY_STATE = ^SYSTEM_BATTERY_STATE;

  {$MinEnumSize 4}
  {$EXTERNALSYM _SYSTEM_POWER_INFORMATION}
  _SYSTEM_POWER_INFORMATION = record
    MaxIdlenessAllowed  : ULONG;
    Idleness            : ULONG;
    TimeRemaining       : ULONG;
    CoolingMode         : UCHAR;
  end;
  {$EXTERNALSYM SYSTEM_POWER_INFORMATION}
  SYSTEM_POWER_INFORMATION = _SYSTEM_POWER_INFORMATION;
  {$EXTERNALSYM PSYSTEM_POWER_INFORMATION}
  PSYSTEM_POWER_INFORMATION = ^SYSTEM_POWER_INFORMATION;

  {$MinEnumSize 4}
  {$EXTERNALSYM BATTERY_SET_INFORMATION_LEVEL}
  BATTERY_SET_INFORMATION_LEVEL = (
    BatteryCharge       = 1,
    BatteryCriticalBias = 0,
    BatteryDischarge    = 2);

  {$EXTERNALSYM _BATTERY_SET_INFORMATION}
  _BATTERY_SET_INFORMATION = record
    BatteryTag: ULONG;
    InformationLevel: BATTERY_SET_INFORMATION_LEVEL;
    Buffer: array [0..0] of UCHAR;
  end;
  {$EXTERNALSYM BATTERY_SET_INFORMATION}
  BATTERY_SET_INFORMATION = _BATTERY_SET_INFORMATION;
  {$EXTERNALSYM PBATTERY_SET_INFORMATION}
  PBATTERY_SET_INFORMATION = ^BATTERY_SET_INFORMATION;

  {$EXTERNALSYM NTSTATUS}
  NTSTATUS = UINT_PTR;

  {$MinEnumSize 4}
  {$EXTERNALSYM _POWER_DATA_ACCESSOR}
  _POWER_DATA_ACCESSOR = (
    ACCESS_AC_POWER_SETTING_INDEX,              // 0x0
    ACCESS_DC_POWER_SETTING_INDEX,              // 0x1
    ACCESS_FRIENDLY_NAME,
    ACCESS_DESCRIPTION,
    ACCESS_POSSIBLE_POWER_SETTING,
    ACCESS_POSSIBLE_POWER_SETTING_FRIENDLY_NAME,
    ACCESS_POSSIBLE_POWER_SETTING_DESCRIPTION,
    ACCESS_DEFAULT_AC_POWER_SETTING,
    ACCESS_DEFAULT_DC_POWER_SETTING,
    ACCESS_POSSIBLE_VALUE_MIN,
    ACCESS_POSSIBLE_VALUE_MAX,
    ACCESS_POSSIBLE_VALUE_INCREMENT,
    ACCESS_POSSIBLE_VALUE_UNITS,
    ACCESS_ICON_RESOURCE,
    ACCESS_DEFAULT_SECURITY_DESCRIPTOR,
    ACCESS_ATTRIBUTES,
    ACCESS_SCHEME,                              // 0x10
    ACCESS_SUBGROUP,                            // 0x11
    ACCESS_INDIVIDUAL_SETTING,                  // 0x12
    ACCESS_ACTIVE_SCHEME,                       // 0x13
    ACCESS_CREATE_SCHEME,                       // 0x14
    ACCESS_AC_POWER_SETTING_MAX,
    ACCESS_DC_POWER_SETTING_MAX,
    ACCESS_AC_POWER_SETTING_MIN,
    ACCESS_DC_POWER_SETTING_MIN,
    ACCESS_PROFILE,
    ACCESS_OVERLAY_SCHEME,
    ACCESS_ACTIVE_OVERLAY_SCHEME
  );
  {$EXTERNALSYM POWER_DATA_ACCESSOR}
  POWER_DATA_ACCESSOR = _POWER_DATA_ACCESSOR;
  {$EXTERNALSYM PPOWER_DATA_ACCESSOR}
  PPOWER_DATA_ACCESSOR = ^_POWER_DATA_ACCESSOR;

  {$MinEnumSize 4}
  {$EXTERNALSYM POWER_PLATFORM_ROLE}
  POWER_PLATFORM_ROLE = (
    PlatformRoleUnspecified        = 0,
    PlatformRoleDesktop            = 1,
    PlatformRoleMobile             = 2,
    PlatformRoleWorkstation        = 3,
    PlatformRoleEnterpriseServer   = 4,
    PlatformRoleSOHOServer         = 5,
    PlatformRoleAppliancePC        = 6,
    PlatformRolePerformanceServer  = 7,
    PlatformRoleSlate              = 8,
    PlatformRoleMaximum
  );

  {$MinEnumSize 4}
  {$EXTERNALSYM EFFECTIVE_POWER_MODE}
  EFFECTIVE_POWER_MODE = (
    EffectivePowerModeBatterySaver,
    EffectivePowerModeBetterBattery,
    EffectivePowerModeBalanced,
    EffectivePowerModeHighPerformance,
    EffectivePowerModeMaxPerformance,
    EffectivePowerModeGameMode,
    EffectivePowerModeMixedReality
  );

  {$EXTERNALSYM EFFECTIVE_POWER_MODE_CALLBACK}
  EFFECTIVE_POWER_MODE_CALLBACK = procedure(
    Mode: EFFECTIVE_POWER_MODE;
    const Context: Pointer
  ); stdcall;

const
  NO_SUBGROUP_GUID                  : TGUID = '{fea3413e-7e05-4911-9a71-700331f1c294}';

  GUID_BATTERY_SUBGROUP           : TGUID = '{e73a048d-bf27-4f12-9731-8b2076e8891f}';
  GUID_BATTERY_DISCHARGE_LEVEL_0  : TGUID = '{9A66D8D7-4FF7-4EF9-B5A2-5A326CA2A469}'; // Уровень почти полной разрядки батареи
  GUID_BATTERY_DISCHARGE_LEVEL_1  : TGUID = '{8183BA9A-E910-48DA-8769-14AE6DC1170A}'; // Уровень низкого заряда батареи
  GUID_BATTERY_DISCHARGE_LEVEL_2  : TGUID = '{07A07CA2-ADAF-40D7-B077-533AADED1BFA}';
  GUID_BATTERY_DISCHARGE_LEVEL_3  : TGUID = '{58AFD5A6-C2DD-47D2-9FBF-EF70CC5C5965}';
  GUID_BATTERY_RESERVE_LEVEL      : TGUID = '{f3c5027d-cd16-4930-aa6b-90db844a8f00}'; // Уровень резервной батареи

  // Battery life remaining
  // ----------------------
  // Specifies the percentage of battery life remaining.  The consumer
  // may register for notification in order to track battery life in
  // a fine-grained manner.
  //
  // Once registered, the consumer can expect to be notified as the battery
  // life percentage changes.
  //
  // The consumer will recieve a value between 0 and 100 (inclusive) which
  // indicates percent battery life remaining.
  GUID_BATTERY_PERCENTAGE_REMAINING : TGUID = '{A7AD8041-B45A-4CAE-87A3-EECBB468A9E1}';

  GUID_POWERSCHEME_PERSONALITY      : TGUID = '{245D8541-3943-4422-B025-13A784F679B7}';
  GUID_ACTIVE_POWERSCHEME           : TGUID = '{31F9F286-5084-42FE-B720-2B0264993763}';

  // AC/DC power source
  // ------------------
  // Specifies the power source for the system.  consumers may register for
  // notification when the power source changes and will be notified with
  // one of 3 values:
  // 0 - Indicates the system is being powered by an AC power source.
  // 1 - Indicates the system is being powered by a DC power source.
  // 2 - Indicates the system is being powered by a short-term DC power
  //     source.  For example, this would be the case if the system is
  //     being powed by a short-term battery supply in a backing UPS
  //     system.  When this value is recieved, the consumer should make
  //     preparations for either a system hibernate or system shutdown.
  GUID_ACDC_POWER_SOURCE            : TGUID = '{5d3e9a59-e9D5-4b00-a6bd-ff34ff516548}';

  // Lid state changes
  // -----------------
  // Specifies the current state of the lid (open or closed). The callback won't
  // be called at all until a lid device is found and its current state is known.
  //
  // Values:
  // 0 - closed
  // 1 - opened
  GUID_LIDSWITCH_STATE_CHANGE: TGUID = '{BA3E0F4D-B817-4094-A2D1-D56379E6A0F3}';

  // Energy Saver settings
  // ---------------------
  // Specifies the subgroup which will contain all of the Energy Saver settings
  // for a single policy.
  GUID_ENERGY_SAVER_SUBGROUP          : TGUID = '{DE830923-A562-41AF-A086-E3A2C6BAD2DA}';
  //Indicates if Enegry Saver is ON or OFF.
  GUID_POWER_SAVING_STATUS            : TGUID = '{E00958C0-C213-4ACE-AC77-FECCED2EEEA5}';
  //Defines a guid to engage Energy Saver at specific battery charge level
  GUID_ENERGY_SAVER_BATTERY_THRESHOLD : TGUID = '{E69653CA-CF7F-4F05-AA73-CB833FA90AD4}';
  // Defines a guid to specify display brightness weight when Energy Saver is engaged
  GUID_ENERGY_SAVER_BRIGHTNESS        : TGUID = '{13D09884-F74E-474A-A852-B6BDE8AD03A8}';

  ALL_POWERSCHEMES_GUID             : TGUID = '{68A1E95E-13EA-41E1-8011-0C496CA490B0}';
  GUID_MIN_POWER_SAVINGS            : TGUID = '{8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c}';
  GUID_MAX_POWER_SAVINGS            : TGUID = '{a1841308-3541-4fab-bc81-f71556f20b4a}';
  GUID_TYPICAL_POWER_SAVINGS        : TGUID = '{381b4222-f694-41f0-9685-ff5bb260df2e}';
  GUID_ULTIMATE_POWER_SAVINGS       : TGUID = '{e9a42b02-d5df-448d-aa00-03f14749eb61}';

  // OVERLAY_SCHEME_NONE
  GUID_POWER_POLICY_OVERLAY_SCHEME_NONE                 : TGUID = '{00000000-0000-0000-0000-000000000000}';
  // OVERLAY_SCHEME_HIGH
  GUID_POWER_POLICY_OVERLAY_SCHEME_HIGH_PERFORMANCE     : TGUID = '{3AF9B8D9-7C97-431D-AD78-34A8BFEA439F}';
  // OVERLAY_SCHEME_MAX
  GUID_POWER_POLICY_OVERLAY_SCHEME_MAX_PERFORMANCE      : TGUID = '{DED574B5-45A0-4F42-8737-46345C09C238}';
  // OVERLAY_SCHEME_MIN
  GUID_POWER_POLICY_OVERLAY_SCHEME_BETTER_BATTERY_LIFE  : TGUID = '{961CC777-2547-4F9D-8174-7D86181B8A7A}';

  GUID_VIDEO_SUBGROUP                       : TGUID = '{7516B95F-F776-4464-8C53-06167F40CC99}';
  GUID_CONSOLE_DISPLAY_STATE                : TGUID = '{6fe69556-704a-47a0-8f24-c28d936fda47}';
  GUID_MONITOR_POWER_ON                     : TGUID = '{02731015-4510-4526-99e6-e5a17ebd1aea}'; // Windows 8 and Windows Server 2012:  New applications should use GUID_CONSOLE_DISPLAY_STATE instead of this notification
  GUID_DEVICE_POWER_POLICY_VIDEO_BRIGHTNESS : TGUID = '{aded5e82-b909-4619-9949-f5d71dac0bcb}';
  GUID_VIDEO_ADAPTIVE_DISPLAY_BRIGHTNESS    : TGUID = '{FBD9AA66-9553-4097-BA44-ED6E9D65EAB8}';

  // System button actions
  // ---------------------
  // Specifies the subgroup which will contain all of the system button
  // settings for a single policy.
  GUID_SYSTEM_BUTTON_SUBGROUP     : TGUID = '{4F971E89-EEBD-4455-A8DE-9E59040E7347}';

  // Specifies (in a POWER_ACTION_POLICY structure) the appropriate action to
  // take when the system power button is pressed.
  GUID_POWERBUTTON_ACTION         : TGUID = '{7648EFA3-DD9C-4E3E-B566-50F929386280}';
  GUID_POWERBUTTON_ACTION_FLAGS   : TGUID = '{857E7FAC-034B-4704-ABB1-BCA54AA31478}';

  // Specifies (in a POWER_ACTION_POLICY structure) the appropriate action to
  // take when the system sleep button is pressed.
  GUID_SLEEPBUTTON_ACTION         : TGUID = '{96996BC0-AD50-47EC-923B-6F41874DD9EB}';
  GUID_SLEEPBUTTON_ACTION_FLAGS   : TGUID = '{2A160AB1-B69D-4743-B718-BF1441D5E493}';

  // Specifies (in a POWER_ACTION_POLICY structure) the appropriate action to
  // take when the system sleep button is pressed.
  GUID_USERINTERFACEBUTTON_ACTION : TGUID = '{A7066653-8D6C-40A8-910E-A1F54B84C7E5}';

  // Specifies (in a POWER_ACTION_POLICY structure) the appropriate action to
  // take when the system lid is closed.
  GUID_LIDCLOSE_ACTION            : TGUID = '{5CA83367-6E45-459F-A27B-476B1D01C936}';
  GUID_LIDCLOSE_ACTION_FLAGS      : TGUID = '{97E969AC-0D6C-4D08-927C-D7BD7AD7857B}';
  GUID_LIDOPEN_POWERSTATE         : TGUID = '{99FF10E7-23B1-4C07-A9D1-5C3206D741B4}';

  STATUS_SUCCESS = NTSTATUS($00000000);

  PO_TZ_ACTIVE        = UCHAR(0); // The system is currently in Active cooling mode.
  PO_TZ_INVALID_MODE  = UCHAR(2); // The system does not support CPU throttling, or there is no thermal zone defined in the system.
  PO_TZ_PASSIVE       = UCHAR(1); // The system is currently in Passive cooling mode.

  POWER_ATTRIBUTE_HIDE = DWORD(1);

  ERROR_SUCCESS = DWORD($0); // The specified power setting is not currently overridden by a group policy.
  ERROR_ACCESS_DISABLED_BY_POLICY = DWORD($04EC); // This program is blocked by group policy. For more information, contact your system administrator.
  ERROR_INSTALL_REMOTE_DISALLOWED = DWORD($0668); // Only Administrators can remotely access power settings.

  POWER_PLATFORM_ROLE_V1 = ULONG($00000001);
  POWER_PLATFORM_ROLE_V2 = ULONG($00000002);

  EFFECTIVE_POWER_MODE_V1: DWORD = 1;
  EFFECTIVE_POWER_MODE_V2: DWORD = 2;

{*******************************************************}
{             PowrProf Win32 API function               }
{*******************************************************}

{$EXTERNALSYM PowerReadFriendlyName}
function PowerReadFriendlyName(
  RootPowerKey: HKEY;
  const SchemeGuid: PGUID;
  const SubGroupOfPowerSettingGuid: PGUID;
  const PowerSettingGuid: PGUID;
  Buffer: PUCHAR;
  var BufferSize: DWORD
): DWORD; stdcall;

{$EXTERNALSYM PowerEnumerate}
function PowerEnumerate(
  RootPowerKey: HKEY;
  const SchemeGuid: PGUID;
  const SubGroupOfPowerSettingGuid: PGUID;
  AccessFlag: POWER_DATA_ACCESSOR;
  Index: ULONG;
  Buffer: PUCHAR;
  var BufferSize: DWORD
): DWORD; stdcall;

{$EXTERNALSYM PowerGetOverlaySchemes}
function PowerGetOverlaySchemes(
  out Buffer: HLOCAL;
  out Count: DWORD;
  Reserved: DWORD
): DWORD; stdcall;

{$EXTERNALSYM PowerDeleteScheme}
function PowerDeleteScheme(
  RootPowerKey: HKEY;
  const SchemeGuid: PGUID
): DWORD; stdcall;

{$EXTERNALSYM PowerRestoreDefaultPowerSchemes}
function PowerRestoreDefaultPowerSchemes: DWORD; stdcall;

{$EXTERNALSYM PowerGetActiveScheme}
function PowerGetActiveScheme(
  UserRootPowerKey: HKEY;
  ActivePolicyGuid: PGUID
): DWORD; stdcall;

{$EXTERNALSYM PowerSetActiveScheme}
function PowerSetActiveScheme(
  UserRootPowerKey: HKEY;
  const SchemeGuid: PGUID
): DWORD; stdcall;

{$EXTERNALSYM PowerGetEffectiveOverlayScheme}
function PowerGetEffectiveOverlayScheme(
  out SchemeGuid: TGUID
): DWORD; stdcall;

{$EXTERNALSYM PowerGetActualOverlayScheme}
function PowerGetActualOverlayScheme(
  out SchemeGuid: TGUID
): DWORD; stdcall;

{$EXTERNALSYM PowerSetActiveOverlayScheme}
function PowerSetActiveOverlayScheme(
  const SchemeGuid: TGUID
): DWORD; stdcall;

{$EXTERNALSYM PowerReadACValueIndex}
function PowerReadACValueIndex(
  RootPowerKey: HKEY;
  const SchemeGuid: PGUID;
  const SubGroupOfPowerSettingsGuid:PGUID;
  const PowerSettingGuid: PGUID;
  out AcValueIndex: DWORD
): DWORD; stdcall;

{$EXTERNALSYM PowerReadDCValueIndex}
function PowerReadDCValueIndex(
  RootPowerKey: HKEY;
  const SchemeGuid: PGUID;
  const SubGroupOfPowerSettingsGuid: PGUID;
  const PowerSettingGuid: PGUID;
  out AcValueIndex: DWORD
): DWORD; stdcall;

{$EXTERNALSYM PowerWriteACValueIndex}
function PowerWriteACValueIndex(
  RootPowerKey: HKEY;
  const SchemeGuid: PGUID;
  const SubGroupOfPowerSettingsGuid:PGUID;
  const PowerSettingGuid: PGUID;
  AcValueIndex: DWORD
): DWORD; stdcall;

{$EXTERNALSYM PowerWriteDCValueIndex}
function PowerWriteDCValueIndex(
  RootPowerKey: HKEY;
  const SchemeGuid: PGUID;
  const SubGroupOfPowerSettingsGuid: PGUID;
  const PowerSettingGuid: PGUID;
  AcValueIndex: DWORD
): DWORD; stdcall;

{$EXTERNALSYM PowerReadSettingAttributes}
function PowerReadSettingAttributes(
  const SubGroupGuid: PGUID;
  const PowerSettingGuid: PGUID
): DWORD; stdcall;

{$EXTERNALSYM PowerSettingAccessCheck}
function PowerSettingAccessCheck(
  AccessFlag: POWER_DATA_ACCESSOR;
  const PowerGuid: PGUID
): DWORD; stdcall;

{$EXTERNALSYM PowerDeterminePlatformRole}
function PowerDeterminePlatformRole: POWER_PLATFORM_ROLE; stdcall;

{$EXTERNALSYM PowerDeterminePlatformRoleEx}
function PowerDeterminePlatformRoleEx(
  Version: ULONG
): POWER_PLATFORM_ROLE; stdcall;

{$EXTERNALSYM PowerRegisterForEffectivePowerModeNotifications}
function PowerRegisterForEffectivePowerModeNotifications(
  Version: ULONG;
  const Callback: EFFECTIVE_POWER_MODE_CALLBACK;
  const Context: Pointer;
  out RegistrationHandle: PPVOID
): HRESULT; stdcall;

{$EXTERNALSYM PowerUnregisterFromEffectivePowerModeNotifications}
function PowerUnregisterFromEffectivePowerModeNotifications(
  RegistrationHandle: PPVOID
): HRESULT; stdcall;

{$EXTERNALSYM GetPwrCapabilities}
function GetPwrCapabilities(
  out lpSystemPowerCapabilities: SYSTEM_POWER_CAPABILITIES
): Boolean; stdcall;

{$EXTERNALSYM CallNtPowerInformation}
function CallNtPowerInformation(
  InformationLevel: POWER_INFORMATION_LEVEL;
  lpInputBuffer: PVOID;
  nInputBufferSize: ULONG;
  lpOutputBuffer: PVOID;
  nOutputBufferSize: ULONG
): NTSTATUS; stdcall;

{$EXTERNALSYM SetSuspendState}
function SetSuspendState(
  Hibernate: BOOL;
  ForceCritical: BOOL;
  DisableWakeEvent: BOOL
): BOOL; stdcall;

implementation

{$WARN SYMBOL_PLATFORM OFF}
function PowerReadFriendlyName;                               external PWR_PROF delayed;
function PowerEnumerate;                                      external PWR_PROF delayed;
function PowerGetOverlaySchemes;                              external PWR_PROF delayed;
function PowerDeleteScheme;                                   external PWR_PROF delayed;
function PowerRestoreDefaultPowerSchemes;                     external PWR_PROF delayed;
function PowerGetActiveScheme;                                external PWR_PROF delayed;
function PowerSetActiveScheme;                                external PWR_PROF delayed;
function PowerGetEffectiveOverlayScheme;                      external PWR_PROF delayed;
function PowerGetActualOverlayScheme;                         external PWR_PROF delayed;
function PowerSetActiveOverlayScheme;                         external PWR_PROF delayed;
function PowerReadACValueIndex;                               external PWR_PROF delayed;
function PowerReadDCValueIndex;                               external PWR_PROF delayed;
function PowerWriteACValueIndex;                              external PWR_PROF delayed;
function PowerWriteDCValueIndex;                              external PWR_PROF delayed;
function PowerReadSettingAttributes;                          external PWR_PROF delayed;
function PowerSettingAccessCheck;                             external PWR_PROF delayed;
function PowerDeterminePlatformRole;                          external PWR_PROF delayed;
function PowerDeterminePlatformRoleEx;                        external PWR_PROF delayed;
function PowerRegisterForEffectivePowerModeNotifications;     external PWR_PROF delayed;
function PowerUnregisterFromEffectivePowerModeNotifications;  external PWR_PROF delayed;
{$WARN SYMBOL_PLATFORM ON}
function GetPwrCapabilities;                                  external PWR_PROF;
function CallNtPowerInformation;                              external PWR_PROF;
function SetSuspendState;                                     external PWR_PROF;

end.

