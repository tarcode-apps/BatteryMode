unit TaskSchd;

//***************************************************
//  Microsoft Windows TaskScheduler API v.2.0
//  imported from taskschd.dll
//
//  editor : Terekhow Andrew
//           http://blog.karelia.ru/teran
//           icq#176-9-176-10
//  ver.1/ 14.10.2010
//****************************************************

interface

uses Windows, ActiveX, Classes, Graphics, OleServer, StdVCL, Variants;


const
  // TypeLibrary Major and minor versions
  TaskSchedulerMajorVersion = 2;
  TaskSchedulerMinorVersion = 0;

  LIBID_TaskScheduler:            TGUID = '{E34CB9F1-C7F7-424C-BE29-027DCC09363A}';

  IID_ITaskFolderCollection:      TGUID = '{79184A66-8664-423F-97F1-637356A5D812}';
  IID_ITaskFolder:                TGUID = '{8CFAC062-A080-4C15-9A88-AA7C2AF80DFC}';
  IID_IRegisteredTask:            TGUID = '{9C86F320-DEE3-4DD1-B972-A303F26B061E}';
  IID_IRunningTask:               TGUID = '{653758FB-7B9A-4F1E-A471-BEEB8E9B834E}';
  IID_IRunningTaskCollection:     TGUID = '{6A67614B-6828-4FEC-AA54-6D52E8F1F2DB}';
  IID_ITaskDefinition:            TGUID = '{F5BC8FC5-536D-4F77-B852-FBC1356FDEB6}';
  IID_IRegistrationInfo:          TGUID = '{416D8B73-CB41-4EA1-805C-9BE9A5AC4A74}';
  IID_ITriggerCollection:         TGUID = '{85DF5081-1B24-4F32-878A-D9D14DF4CB77}';
  IID_ITrigger:                   TGUID = '{09941815-EA89-4B5B-89E0-2A773801FAC3}';
  IID_IRepetitionPattern:         TGUID = '{7FB9ACF1-26BE-400E-85B5-294B9C75DFD6}';
  IID_ITaskSettings:              TGUID = '{8FD4711D-2D02-4C8C-87E3-EFF699DE127E}';
  IID_IIdleSettings:              TGUID = '{84594461-0053-4342-A8FD-088FABF11F32}';
  IID_INetworkSettings:           TGUID = '{9F7DEA84-C30B-4245-80B6-00E9F646F1B4}';
  IID_IPrincipal:                 TGUID = '{D98D51E5-C9B4-496A-A9C1-18980261CF0F}';
  IID_IActionCollection:          TGUID = '{02820E19-7B98-4ED2-B2E8-FDCCCEFF619B}';
  IID_IAction:                    TGUID = '{BAE54997-48B1-4CBE-9965-D6BE263EBEA4}';
  IID_IRegisteredTaskCollection:  TGUID = '{86627EB4-42A7-41E4-A4D9-AC33A72F2D52}';
  IID_ITaskService:               TGUID = '{2FABA4C7-4DA9-4013-9697-20CC3FD40F85}';
  IID_ITaskHandler:               TGUID = '{839D7762-5121-4009-9234-4F0D19394F04}';
  IID_ITaskHandlerStatus:         TGUID = '{EAEC7A8F-27A0-4DDC-8675-14726A01A38A}';
  IID_ITaskVariables:             TGUID = '{3E4C9351-D966-4B8B-BB87-CEBA68BB0107}';
  IID_ITaskNamedValuePair:        TGUID = '{39038068-2B46-4AFD-8662-7BB6F868D221}';
  IID_ITaskNamedValueCollection:  TGUID = '{B4EF826B-63C3-46E4-A504-EF69E4F7EA4D}';
  IID_IIdleTrigger:               TGUID = '{D537D2B0-9FB3-4D34-9739-1FF5CE7B1EF3}';
  IID_ILogonTrigger:              TGUID = '{72DADE38-FAE4-4B3E-BAF4-5D009AF02B1C}';
  IID_ISessionStateChangeTrigger: TGUID = '{754DA71B-4385-4475-9DD9-598294FA3641}';
  IID_IEventTrigger:              TGUID = '{D45B0167-9653-4EEF-B94F-0732CA7AF251}';
  IID_ITimeTrigger:               TGUID = '{B45747E0-EBA7-4276-9F29-85C5BB300006}';
  IID_IDailyTrigger:              TGUID = '{126C5CD8-B288-41D5-8DBF-E491446ADC5C}';
  IID_IWeeklyTrigger:             TGUID = '{5038FC98-82FF-436D-8728-A512A57C9DC1}';
  IID_IMonthlyTrigger:            TGUID = '{97C45EF1-6B02-4A1A-9C0E-1EBFBA1500AC}';
  IID_IMonthlyDOWTrigger:         TGUID = '{77D025A3-90FA-43AA-B52E-CDA5499B946A}';
  IID_IBootTrigger:               TGUID = '{2A9C35DA-D357-41F4-BBC1-207AC1B1F3CB}';
  IID_IRegistrationTrigger:       TGUID = '{4C8FEC3A-C218-4E0C-B23D-629024DB91A2}';
  IID_IExecAction:                TGUID = '{4C3D624D-FD6B-49A3-B9B7-09CB3CD3F047}';
  IID_IShowMessageAction:         TGUID = '{505E9E68-AF89-46B8-A30F-56162A83D537}';
  IID_IComHandlerAction:          TGUID = '{6D2FD252-75C5-4F66-90BA-2A7D8CC3039F}';
  IID_IEmailAction:               TGUID = '{10F62C64-7E16-4314-A0C2-0C3683F99D40}';
  IID_ITaskSettings2:             TGUID = '{2C05C3F0-6EED-4C05-A15F-ED7D7A98A369}';

  CLSID_TaskScheduler:            TGUID = '{0F87369F-A4E5-4CFC-BD3E-73E6154572DD}';
  CLSID_TaskHandlerPS:            TGUID = '{F2A69DB7-DA2C-4352-9066-86FEE6DACAC9}';
  CLSID_TaskHandlerStatusPS:      TGUID = '{9F15266D-D7BA-48F0-93C1-E6895F6FE5AC}';


type
  {$MinEnumSize 4}
  TTaskState = (tsUnknown  = 0,
                tsDisabled = 1,
                tsQueued   = 2,
                tsReady    = 3,
                tsRunning  = 4);

  {$MinEnumSize 4}
  TTaskTriggerType2 = (ttEvent              = 0,
                       ttTime               = 1,
                       ttDaily              = 2,
                       ttWeekly             = 3,
                       ttMonthly            = 4,
                       ttMonthlyDOW         = 5,
                       ttIdle               = 6,
                       ttRegistration       = 7,
                       ttBoot               = 8,
                       ttLogin              = 9,
                       ttSessionStateChange = 11);

  {$MinEnumSize 4}
  TTaskInstancesPolicy = (tiParallel      = 0,
                          tiQueue         = 1,
                          tiIgnoreNew     = 2,
                          tiStopExisting  = 3);

  {$MinEnumSize 4}
  TTaskCompability = (tcAT   = 0,
                      tcV1   = 1,
                      tcV2   = 2,
                      tcV2_1 = 3);

  {$MinEnumSize 4}
  TTaskLogonType = (tlNone                       = 0,
                    tlPassword                   = 1,
                    tlS4U                        = 2,
                    tlIneractiveToken            = 3,
                    tlGroup                      = 4,
                    tlSeiviceAccount             = 5,
                    tlIneractiveTokenOrPassword  = 6);

  {$MinEnumSize 4}
  TTaskRunLevelType = (trlLUA     = 0,
                       trlHighest = 1);

  {$MinEnumSize 4}
  TTaskActionType = (taExec         = 0,
                     taCOMHandler   = 5,
                     taSendEMail    = 6,
                     taShowMessage  = 7);

  {$MinEnumSize 4}
  TTaskSessionStateChangeType = (tssConsoleConnect    = 1,
                                 tssConsoleDisconnect = 2,
                                 tssRemoteConnect     = 3,
                                 tssRemoteDisconnect  = 4,
                                 tssSessionLock       = 7,
                                 tssSessionUnlock     = 8);

  {$MinEnumSize 4}
  TTaskRunFlags = (trfNoFlags           = $0,
                   trfAsSelf            = $1,
                   trfIgonreConstraints = $2,
                   trfUseSessionID      = $4,
                   trfUserSID           = $8);

  {$MinEnumSize 4}
  TTaskEnumFlags = (tefHidden = $1);

  {$MinEnumSize 4}
  TTaskProcessTokenSIDType = (tptsNone          = 0,
                              tptsUnrestricted  = 1,
                              tptsDefault       = 2);

  {$MinEnumSize 4}
  TTaskCreation = (tcValidateOnly               = $01,
                   tcCreate                     = $02,
                   tcUpdate                     = $04,
                   tcCreateOrUpdate             = $06,
                   tcDisable                    = $08,
                   tcDontAddPrincipalAce        = $10,
                   tcIgnoreRegistrationTriggers = $20);

  {$MinEnumSize 4}
  TTaskPriority = (tpRealtime         = 0,
                   tpHigh             = 1,
                   tpAboveNormal1     = 2,
                   tpAboveNormal2     = 3,
                   tpNormal1          = 4,
                   tpNormal2          = 5,
                   tpNormal3          = 6,
                   tpBelowNormal1     = 7,
                   tpBelowNormal2     = 8,
                   tpIdleThreadLowest = 9,
                   tpIdleThreadIdle   = 10);

type
  ITaskFolderCollection       = interface;
  ITaskFolder                 = interface;
  IRegisteredTask             = interface;
  IRunningTask                = interface;
  IRunningTaskCollection      = interface;
  ITaskDefinition             = interface;
  IRegistrationInfo           = interface;

  IRepetitionPattern          = interface;
  ITaskSettings               = interface;
  IIdleSettings               = interface;
  INetworkSettings            = interface;
  IPrincipal                  = interface;
  IRegisteredTaskCollection   = interface;
  ITaskService                = interface;
  ITaskHandler                = interface;
  ITaskHandlerStatus          = interface;
  ITaskVariables              = interface;
  ITaskNamedValuePair         = interface;
  ITaskNamedValueCollection   = interface;

  ITriggerCollection          = interface;
  ITrigger                    = interface;
  IIdleTrigger                = interface;
  ILogonTrigger               = interface;
  ISessionStateChangeTrigger  = interface;
  IEventTrigger               = interface;
  ITimeTrigger                = interface;
  IDailyTrigger               = interface;
  IWeeklyTrigger              = interface;
  IMonthlyTrigger             = interface;
  IMonthlyDOWTrigger          = interface;
  IBootTrigger                = interface;
  IRegistrationTrigger        = interface;

  IActionCollection           = interface;
  IAction                     = interface;
  IExecAction                 = interface;
  IShowMessageAction          = interface;
  IComHandlerAction           = interface;
  IEmailAction                = interface;

  ITaskSettings2              = interface;


// *********************************************************************//
// Interface: ITaskFolderCollection
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {79184A66-8664-423F-97F1-637356A5D812}
// *********************************************************************//
  ITaskFolderCollection = interface(IDispatch)
    ['{79184A66-8664-423F-97F1-637356A5D812}']
    function Get_Count: Integer; safecall;
    function Get_Item(index: OleVariant): ITaskFolder; safecall;
    function Get__NewEnum: IUnknown; safecall;

    property Count: Integer read Get_Count;
    property Item[index: OleVariant]: ITaskFolder read Get_Item; default;
    property _NewEnum: IUnknown read Get__NewEnum;
  end;



// *********************************************************************//
// Interface: ITaskFolder
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {8CFAC062-A080-4C15-9A88-AA7C2AF80DFC}
// *********************************************************************//
  ITaskFolder = interface(IDispatch)
    ['{8CFAC062-A080-4C15-9A88-AA7C2AF80DFC}']
    function Get_Name: WideString; safecall;
    function Get_Path: WideString; safecall;
    function GetFolder(const Path: WideString): ITaskFolder; safecall;
    function GetFolders(flags: LONG): ITaskFolderCollection; safecall;
    function CreateFolder(const subFolderName: WideString; sddl: OleVariant): ITaskFolder; safecall;
    procedure DeleteFolder(const subFolderName: WideString; flags: LONG); safecall;
    function GetTask(const Path: WideString): IRegisteredTask; safecall;
    function GetTasks(flags: LONG): IRegisteredTaskCollection; safecall;
    procedure DeleteTask(const Name: WideString; flags: LONG); safecall;
    function RegisterTask(const Path: WideString; const XmlText: WideString; flags: Integer;
                          UserId: OleVariant; password: OleVariant; LogonType: TTaskLogonType;
                          sddl: OleVariant): IRegisteredTask; safecall;
    function RegisterTaskDefinition(const Path: WideString; const pDefinition: ITaskDefinition;
                                    flags: LONG; UserId: OleVariant; password: OleVariant;
                                    LogonType: TTaskLogonType; sddl: OleVariant): IRegisteredTask; safecall;
    function GetSecurityDescriptor(securityInformation: LONG): WideString; safecall;
    procedure SetSecurityDescriptor(const sddl: WideString; flags: LONG); safecall;

    property Name: WideString read Get_Name;
    property Path: WideString read Get_Path;
  end;



// *********************************************************************//
// Interface: IRegisteredTask
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {9C86F320-DEE3-4DD1-B972-A303F26B061E}
// *********************************************************************//
  IRegisteredTask = interface(IDispatch)
    ['{9C86F320-DEE3-4DD1-B972-A303F26B061E}']
    function Get_Name: WideString; safecall;
    function Get_Path: WideString; safecall;
    function Get_State: TTaskState; safecall;
    function Get_Enabled: WordBool; safecall;
    procedure Set_Enabled(pEnabled: WordBool); safecall;
    function Run(params: OleVariant): IRunningTask; safecall;
    function RunEx(params: OleVariant; flags: TTaskRunFlags; sessionID: LONG; const user: WideString): IRunningTask; safecall;
    function GetInstances(flags: LONG): IRunningTaskCollection; safecall;
    function Get_LastRunTime: TDateTime; safecall;
    function Get_LastTaskResult: HRESULT; safecall;
    function Get_NumberOfMissedRuns: DWORD; safecall;
    function Get_NextRunTime: TDateTime; safecall;
    function Get_Definition: ITaskDefinition; safecall;
    function Get_Xml: WideString; safecall;
    function GetSecurityDescriptor(securityInformation: LONG): WideString; safecall;
    procedure SetSecurityDescriptor(const sddl: WideString; flags: LONG); safecall;
    procedure Stop(flags: LONG); safecall;
    procedure GetRunTimes(var pstStart: _SYSTEMTIME; var pstEnd: TSystemTime; var pCount: LongWord;
                          out pRunTimes: PSystemTime); safecall;       // pSystemTime ?

    property Name: WideString read Get_Name;
    property Path: WideString read Get_Path;
    property State: TTaskState read Get_State;
    property Enabled: WordBool read Get_Enabled write Set_Enabled;
    property LastRunTime: TDateTime read Get_LastRunTime;
    property LastTaskResult: HRESULT read Get_LastTaskResult;
    property NumberOfMissedRuns: DWORD read Get_NumberOfMissedRuns;
    property NextRunTime: TDateTime read Get_NextRunTime;
    property Definition: ITaskDefinition read Get_Definition;
    property Xml: WideString read Get_Xml;
  end;


// *********************************************************************//
// Interface: IRunningTask
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {653758FB-7B9A-4F1E-A471-BEEB8E9B834E}
// *********************************************************************//
  IRunningTask = interface(IDispatch)
    ['{653758FB-7B9A-4F1E-A471-BEEB8E9B834E}']
    function Get_Name: WideString; safecall;
    function Get_InstanceGuid: WideString; safecall;
    function Get_Path: WideString; safecall;
    function Get_State: TTaskState; safecall;
    function Get_CurrentAction: WideString; safecall;
    procedure Stop; safecall;
    procedure Refresh; safecall;
    function Get_EnginePID: DWORD; safecall;
    property Name: WideString read Get_Name;
    property InstanceGuid: WideString read Get_InstanceGuid;
    property Path: WideString read Get_Path;
    property State: TTaskState read Get_State;
    property CurrentAction: WideString read Get_CurrentAction;
    property EnginePID: DWORD read Get_EnginePID;
  end;



// *********************************************************************//
// Interface: IRunningTaskCollection
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {6A67614B-6828-4FEC-AA54-6D52E8F1F2DB}
// *********************************************************************//
  IRunningTaskCollection = interface(IDispatch)
    ['{6A67614B-6828-4FEC-AA54-6D52E8F1F2DB}']
    function Get_Count: LONG; safecall;
    function Get_Item(index: OleVariant): IRunningTask; safecall;
    function Get__NewEnum: IUnknown; safecall;
    property Count: LONG read Get_Count;
    property Item[index: OleVariant]: IRunningTask read Get_Item; default;
    property _NewEnum: IUnknown read Get__NewEnum;
  end;



// *********************************************************************//
// Interface: ITaskDefinition
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {F5BC8FC5-536D-4F77-B852-FBC1356FDEB6}
// *********************************************************************//
  ITaskDefinition = interface(IDispatch)
    ['{F5BC8FC5-536D-4F77-B852-FBC1356FDEB6}']
    function Get_RegistrationInfo: IRegistrationInfo; safecall;
    procedure Set_RegistrationInfo(const ppRegistrationInfo: IRegistrationInfo); safecall;
    function Get_Triggers: ITriggerCollection; safecall;
    procedure Set_Triggers(const ppTriggers: ITriggerCollection); safecall;
    function Get_Settings: ITaskSettings; safecall;
    procedure Set_Settings(const ppSettings: ITaskSettings); safecall;
    function Get_Data: WideString; safecall;
    procedure Set_Data(const pData: WideString); safecall;
    function Get_Principal: IPrincipal; safecall;
    procedure Set_Principal(const ppPrincipal: IPrincipal); safecall;
    function Get_Actions: IActionCollection; safecall;
    procedure Set_Actions(const ppActions: IActionCollection); safecall;
    function Get_XmlText: WideString; safecall;
    procedure Set_XmlText(const pXml: WideString); safecall;
    property RegistrationInfo: IRegistrationInfo read Get_RegistrationInfo write Set_RegistrationInfo;
    property Triggers: ITriggerCollection read Get_Triggers write Set_Triggers;
    property Settings: ITaskSettings read Get_Settings write Set_Settings;
    property Data: WideString read Get_Data write Set_Data;
    property Principal: IPrincipal read Get_Principal write Set_Principal;
    property Actions: IActionCollection read Get_Actions write Set_Actions;
    property XmlText: WideString read Get_XmlText write Set_XmlText;
  end;

// *********************************************************************//
// Interface: IRegistrationInfo
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {416D8B73-CB41-4EA1-805C-9BE9A5AC4A74}
// *********************************************************************//
  IRegistrationInfo = interface(IDispatch)
    ['{416D8B73-CB41-4EA1-805C-9BE9A5AC4A74}']
    function Get_Description: WideString; safecall;
    procedure Set_Description(const pDescription: WideString); safecall;
    function Get_Author: WideString; safecall;
    procedure Set_Author(const pAuthor: WideString); safecall;
    function Get_Version: WideString; safecall;
    procedure Set_Version(const pVersion: WideString); safecall;
    function Get_Date: WideString; safecall;
    procedure Set_Date(const pDate: WideString); safecall;
    function Get_Documentation: WideString; safecall;
    procedure Set_Documentation(const pDocumentation: WideString); safecall;
    function Get_XmlText: WideString; safecall;
    procedure Set_XmlText(const pText: WideString); safecall;
    function Get_URI: WideString; safecall;
    procedure Set_URI(const pUri: WideString); safecall;
    function Get_SecurityDescriptor: OleVariant; safecall;
    procedure Set_SecurityDescriptor(pSddl: OleVariant); safecall;
    function Get_Source: WideString; safecall;
    procedure Set_Source(const pSource: WideString); safecall;
    property Description: WideString read Get_Description write Set_Description;
    property Author: WideString read Get_Author write Set_Author;
    property Version: WideString read Get_Version write Set_Version;
    property Date: WideString read Get_Date write Set_Date;
    property Documentation: WideString read Get_Documentation write Set_Documentation;
    property XmlText: WideString read Get_XmlText write Set_XmlText;
    property URI: WideString read Get_URI write Set_URI;
    property SecurityDescriptor: OleVariant read Get_SecurityDescriptor write Set_SecurityDescriptor;
    property Source: WideString read Get_Source write Set_Source;
  end;


// *********************************************************************//
// Interface: ITriggerCollection
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {85DF5081-1B24-4F32-878A-D9D14DF4CB77}
// *********************************************************************//
  ITriggerCollection = interface(IDispatch)
    ['{85DF5081-1B24-4F32-878A-D9D14DF4CB77}']
    function Get_Count: LONG; safecall;
    function Get_Item(index: LONG): ITrigger; safecall;
    function Get__NewEnum: IUnknown; safecall;
    function Create(triggerType: TTaskTriggerType2): ITrigger; safecall;
    procedure Remove(index: OleVariant); safecall;
    procedure Clear; safecall;
    property Count: LONG read Get_Count;
    property Item[index: LONG]: ITrigger read Get_Item; default;
    property _NewEnum: IUnknown read Get__NewEnum;
  end;

// *********************************************************************//
// Interface: ITrigger
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {09941815-EA89-4B5B-89E0-2A773801FAC3}
// *********************************************************************//
  ITrigger = interface(IDispatch)
    ['{09941815-EA89-4B5B-89E0-2A773801FAC3}']
    function Get_type: TTaskTriggerType2; safecall;
    function Get_Id: WideString; safecall;
    procedure Set_Id(const pId: WideString); safecall;
    function Get_Repetition: IRepetitionPattern; safecall;
    procedure Set_Repetition(const ppRepeat: IRepetitionPattern); safecall;
    function Get_ExecutionTimeLimit: WideString; safecall;
    procedure Set_ExecutionTimeLimit(const pTimeLimit: WideString); safecall;
    function Get_StartBoundary: WideString; safecall;
    procedure Set_StartBoundary(const pStart: WideString); safecall;
    function Get_EndBoundary: WideString; safecall;
    procedure Set_EndBoundary(const pEnd: WideString); safecall;
    function Get_Enabled: WordBool; safecall;
    procedure Set_Enabled(pEnabled: WordBool); safecall;
    property triggerType: TTaskTriggerType2 read Get_type;
    property Id: WideString read Get_Id write Set_Id;
    property Repetition: IRepetitionPattern read Get_Repetition write Set_Repetition;
    property ExecutionTimeLimit: WideString read Get_ExecutionTimeLimit write Set_ExecutionTimeLimit;
    property StartBoundary: WideString read Get_StartBoundary write Set_StartBoundary;
    property EndBoundary: WideString read Get_EndBoundary write Set_EndBoundary;
    property Enabled: WordBool read Get_Enabled write Set_Enabled;
  end;

// *********************************************************************//
// Interface: IRepetitionPattern
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {7FB9ACF1-26BE-400E-85B5-294B9C75DFD6}
// *********************************************************************//
  IRepetitionPattern = interface(IDispatch)
    ['{7FB9ACF1-26BE-400E-85B5-294B9C75DFD6}']
    function Get_Interval: WideString; safecall;
    procedure Set_Interval(const pInterval: WideString); safecall;
    function Get_Duration: WideString; safecall;
    procedure Set_Duration(const pDuration: WideString); safecall;
    function Get_StopAtDurationEnd: WordBool; safecall;
    procedure Set_StopAtDurationEnd(pStop: WordBool); safecall;
    property Interval: WideString read Get_Interval write Set_Interval;
    property Duration: WideString read Get_Duration write Set_Duration;
    property StopAtDurationEnd: WordBool read Get_StopAtDurationEnd write Set_StopAtDurationEnd;
  end;


// *********************************************************************//
// Interface: ITaskSettings
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {8FD4711D-2D02-4C8C-87E3-EFF699DE127E}
// *********************************************************************//
  ITaskSettings = interface(IDispatch)
    ['{8FD4711D-2D02-4C8C-87E3-EFF699DE127E}']
    function Get_AllowDemandStart: WordBool; safecall;
    procedure Set_AllowDemandStart(pAllowDemandStart: WordBool); safecall;
    function Get_RestartInterval: WideString; safecall;
    procedure Set_RestartInterval(const pRestartInterval: WideString); safecall;
    function Get_RestartCount: SYSINT; safecall;
    procedure Set_RestartCount(pRestartCount: SYSINT); safecall;
    function Get_MultipleInstances: TTaskInstancesPolicy; safecall;
    procedure Set_MultipleInstances(pPolicy: TTaskInstancesPolicy); safecall;
    function Get_StopIfGoingOnBatteries: WordBool; safecall;
    procedure Set_StopIfGoingOnBatteries(pStopIfOnBatteries: WordBool); safecall;
    function Get_DisallowStartIfOnBatteries: WordBool; safecall;
    procedure Set_DisallowStartIfOnBatteries(pDisallowStart: WordBool); safecall;
    function Get_AllowHardTerminate: WordBool; safecall;
    procedure Set_AllowHardTerminate(pAllowHardTerminate: WordBool); safecall;
    function Get_StartWhenAvailable: WordBool; safecall;
    procedure Set_StartWhenAvailable(pStartWhenAvailable: WordBool); safecall;
    function Get_XmlText: WideString; safecall;
    procedure Set_XmlText(const pText: WideString); safecall;
    function Get_RunOnlyIfNetworkAvailable: WordBool; safecall;
    procedure Set_RunOnlyIfNetworkAvailable(pRunOnlyIfNetworkAvailable: WordBool); safecall;
    function Get_ExecutionTimeLimit: WideString; safecall;
    procedure Set_ExecutionTimeLimit(const pExecutionTimeLimit: WideString); safecall;
    function Get_Enabled: WordBool; safecall;
    procedure Set_Enabled(pEnabled: WordBool); safecall;
    function Get_DeleteExpiredTaskAfter: WideString; safecall;
    procedure Set_DeleteExpiredTaskAfter(const pExpirationDelay: WideString); safecall;
    function Get_Priority: SYSINT; safecall;
    procedure Set_Priority(pPriority: SYSINT); safecall;
    function Get_Compatibility: TTaskCompability; safecall;
    procedure Set_Compatibility(pCompatLevel: TTaskCompability); safecall;
    function Get_Hidden: WordBool; safecall;
    procedure Set_Hidden(pHidden: WordBool); safecall;
    function Get_IdleSettings: IIdleSettings; safecall;
    procedure Set_IdleSettings(const ppIdleSettings: IIdleSettings); safecall;
    function Get_RunOnlyIfIdle: WordBool; safecall;
    procedure Set_RunOnlyIfIdle(pRunOnlyIfIdle: WordBool); safecall;
    function Get_WakeToRun: WordBool; safecall;
    procedure Set_WakeToRun(pWake: WordBool); safecall;
    function Get_NetworkSettings: INetworkSettings; safecall;
    procedure Set_NetworkSettings(const ppNetworkSettings: INetworkSettings); safecall;
    property AllowDemandStart: WordBool read Get_AllowDemandStart write Set_AllowDemandStart;
    property RestartInterval: WideString read Get_RestartInterval write Set_RestartInterval;
    property RestartCount: SYSINT read Get_RestartCount write Set_RestartCount;
    property MultipleInstances: TTaskInstancesPolicy read Get_MultipleInstances write Set_MultipleInstances;
    property StopIfGoingOnBatteries: WordBool read Get_StopIfGoingOnBatteries write Set_StopIfGoingOnBatteries;
    property DisallowStartIfOnBatteries: WordBool read Get_DisallowStartIfOnBatteries write Set_DisallowStartIfOnBatteries;
    property AllowHardTerminate: WordBool read Get_AllowHardTerminate write Set_AllowHardTerminate;
    property StartWhenAvailable: WordBool read Get_StartWhenAvailable write Set_StartWhenAvailable;
    property XmlText: WideString read Get_XmlText write Set_XmlText;
    property RunOnlyIfNetworkAvailable: WordBool read Get_RunOnlyIfNetworkAvailable write Set_RunOnlyIfNetworkAvailable;
    property ExecutionTimeLimit: WideString read Get_ExecutionTimeLimit write Set_ExecutionTimeLimit;
    property Enabled: WordBool read Get_Enabled write Set_Enabled;
    property DeleteExpiredTaskAfter: WideString read Get_DeleteExpiredTaskAfter write Set_DeleteExpiredTaskAfter;
    property Priority: SYSINT read Get_Priority write Set_Priority;
    property Compatibility: TTaskCompability read Get_Compatibility write Set_Compatibility;
    property Hidden: WordBool read Get_Hidden write Set_Hidden;
    property IdleSettings: IIdleSettings read Get_IdleSettings write Set_IdleSettings;
    property RunOnlyIfIdle: WordBool read Get_RunOnlyIfIdle write Set_RunOnlyIfIdle;
    property WakeToRun: WordBool read Get_WakeToRun write Set_WakeToRun;
    property NetworkSettings: INetworkSettings read Get_NetworkSettings write Set_NetworkSettings;
  end;


// *********************************************************************//
// Interface: IIdleSettings
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {84594461-0053-4342-A8FD-088FABF11F32}
// *********************************************************************//
  IIdleSettings = interface(IDispatch)
    ['{84594461-0053-4342-A8FD-088FABF11F32}']
    function Get_IdleDuration: WideString; safecall;
    procedure Set_IdleDuration(const pDelay: WideString); safecall;
    function Get_WaitTimeout: WideString; safecall;
    procedure Set_WaitTimeout(const pTimeout: WideString); safecall;
    function Get_StopOnIdleEnd: WordBool; safecall;
    procedure Set_StopOnIdleEnd(pStop: WordBool); safecall;
    function Get_RestartOnIdle: WordBool; safecall;
    procedure Set_RestartOnIdle(pRestart: WordBool); safecall;
    property IdleDuration: WideString read Get_IdleDuration write Set_IdleDuration;
    property WaitTimeout: WideString read Get_WaitTimeout write Set_WaitTimeout;
    property StopOnIdleEnd: WordBool read Get_StopOnIdleEnd write Set_StopOnIdleEnd;
    property RestartOnIdle: WordBool read Get_RestartOnIdle write Set_RestartOnIdle;
  end;

// *********************************************************************//
// Interface: INetworkSettings
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {9F7DEA84-C30B-4245-80B6-00E9F646F1B4}
// *********************************************************************//
  INetworkSettings = interface(IDispatch)
    ['{9F7DEA84-C30B-4245-80B6-00E9F646F1B4}']
    function Get_Name: WideString; safecall;
    procedure Set_Name(const pName: WideString); safecall;
    function Get_Id: WideString; safecall;
    procedure Set_Id(const pId: WideString); safecall;
    property Name: WideString read Get_Name write Set_Name;
    property Id: WideString read Get_Id write Set_Id;
  end;


// *********************************************************************//
// Interface: IPrincipal
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {D98D51E5-C9B4-496A-A9C1-18980261CF0F}
// *********************************************************************//
  IPrincipal = interface(IDispatch)
    ['{D98D51E5-C9B4-496A-A9C1-18980261CF0F}']
    function Get_Id: WideString; safecall;
    procedure Set_Id(const pId: WideString); safecall;
    function Get_DisplayName: WideString; safecall;
    procedure Set_DisplayName(const pName: WideString); safecall;
    function Get_UserId: WideString; safecall;
    procedure Set_UserId(const pUser: WideString); safecall;
    function Get_LogonType: TTaskLogonType; safecall;
    procedure Set_LogonType(pLogon: TTaskLogonType); safecall;
    function Get_GroupId: WideString; safecall;
    procedure Set_GroupId(const pGroup: WideString); safecall;
    function Get_RunLevel: TTaskRunLevelType; safecall;
    procedure Set_RunLevel(pRunLevel: TTaskRunLevelType); safecall;
    property Id: WideString read Get_Id write Set_Id;
    property DisplayName: WideString read Get_DisplayName write Set_DisplayName;
    property UserId: WideString read Get_UserId write Set_UserId;
    property LogonType: TTaskLogonType read Get_LogonType write Set_LogonType;
    property GroupId: WideString read Get_GroupId write Set_GroupId;
    property RunLevel: TTaskRunLevelType read Get_RunLevel write Set_RunLevel;
  end;

// *********************************************************************//
// Interface: IActionCollection
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {02820E19-7B98-4ED2-B2E8-FDCCCEFF619B}
// *********************************************************************//
  IActionCollection = interface(IDispatch)
    ['{02820E19-7B98-4ED2-B2E8-FDCCCEFF619B}']
    function Get_Count: LONG; safecall;
    function Get_Item(index: LONG): IAction; safecall;
    function Get__NewEnum: IUnknown; safecall;
    function Get_XmlText: WideString; safecall;
    procedure Set_XmlText(const pText: WideString); safecall;
    function Create(ActionType: TTaskActionType): IAction; safecall;
    procedure Remove(index: OleVariant); safecall;
    procedure Clear; safecall;
    function Get_Context: WideString; safecall;
    procedure Set_Context(const pContext: WideString); safecall;
    property Count: LONG read Get_Count;
    property Item[index: LONG]: IAction read Get_Item; default;
    property _NewEnum: IUnknown read Get__NewEnum;
    property XmlText: WideString read Get_XmlText write Set_XmlText;
    property Context: WideString read Get_Context write Set_Context;
  end;

// *********************************************************************//
// Interface: IAction
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {BAE54997-48B1-4CBE-9965-D6BE263EBEA4}
// *********************************************************************//
  IAction = interface(IDispatch)
    ['{BAE54997-48B1-4CBE-9965-D6BE263EBEA4}']
    function Get_Id: WideString; safecall;
    procedure Set_Id(const pId: WideString); safecall;
    function Get_type: TTaskActionType; safecall;
    property Id: WideString read Get_Id write Set_Id;
    property ActionType: TTaskActionType read Get_type;
  end;

// *********************************************************************//
// Interface: IRegisteredTaskCollection
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {86627EB4-42A7-41E4-A4D9-AC33A72F2D52}
// *********************************************************************//
  IRegisteredTaskCollection = interface(IDispatch)
    ['{86627EB4-42A7-41E4-A4D9-AC33A72F2D52}']
    function Get_Count: LONG; safecall;
    function Get_Item(index: OleVariant): IRegisteredTask; safecall;
    function Get__NewEnum: IUnknown; safecall;
    property Count: LONG read Get_Count;
    property Item[index: OleVariant]: IRegisteredTask read Get_Item; default;
    property _NewEnum: IUnknown read Get__NewEnum;
  end;

// *********************************************************************//
// Interface: ITaskService
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {2FABA4C7-4DA9-4013-9697-20CC3FD40F85}
// *********************************************************************//
  ITaskService = interface(IDispatch)
    ['{2FABA4C7-4DA9-4013-9697-20CC3FD40F85}']
    function GetFolder(const Path: WideString): ITaskFolder; safecall;
    function GetRunningTasks(flags: LONG): IRunningTaskCollection; safecall;
    function NewTask(flags: DWORD): ITaskDefinition; safecall;
    procedure Connect(serverName: OleVariant; user: OleVariant; domain: OleVariant;
                      password: OleVariant); safecall;
    function Get_Connected: WordBool; safecall;
    function Get_TargetServer: WideString; safecall;
    function Get_ConnectedUser: WideString; safecall;
    function Get_ConnectedDomain: WideString; safecall;
    function Get_HighestVersion: DWORD; safecall;

    property Connected: WordBool read Get_Connected;
    property TargetServer: WideString read Get_TargetServer;
    property ConnectedUser: WideString read Get_ConnectedUser;
    property ConnectedDomain: WideString read Get_ConnectedDomain;
    property HighestVersion: DWORD read Get_HighestVersion;
  end;


// *********************************************************************//
// Interface: ITaskHandler
// Flags:     (0)
// GUID:      {839D7762-5121-4009-9234-4F0D19394F04}
// *********************************************************************//
  ITaskHandler = interface(IUnknown)
    ['{839D7762-5121-4009-9234-4F0D19394F04}']
    function Start(const pHandlerServices: IUnknown; const Data: WideString): HRESULT; stdcall;
    function Stop(out pRetCode: HRESULT): HRESULT; stdcall;
    function Pause: HRESULT; stdcall;
    function Resume: HRESULT; stdcall;
  end;

// *********************************************************************//
// Interface: ITaskHandlerStatus
// Flags:     (0)
// GUID:      {EAEC7A8F-27A0-4DDC-8675-14726A01A38A}
// *********************************************************************//
  ITaskHandlerStatus = interface(IUnknown)
    ['{EAEC7A8F-27A0-4DDC-8675-14726A01A38A}']
    function UpdateStatus(percentComplete: SHORT; const statusMessage: WideString): HRESULT; stdcall;
    function TaskCompleted(taskErrCode: HRESULT): HRESULT; stdcall;
  end;

// *********************************************************************//
// Interface: ITaskVariables
// Flags:     (0)
// GUID:      {3E4C9351-D966-4B8B-BB87-CEBA68BB0107}
// *********************************************************************//
  ITaskVariables = interface(IUnknown)
    ['{3E4C9351-D966-4B8B-BB87-CEBA68BB0107}']
    function GetInput(out pInput: WideString): HRESULT; stdcall;
    function SetOutput(const input: WideString): HRESULT; stdcall;
    function GetContext(out pContext: WideString): HRESULT; stdcall;
  end;

// *********************************************************************//
// Interface: ITaskNamedValuePair
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {39038068-2B46-4AFD-8662-7BB6F868D221}
// *********************************************************************//
  ITaskNamedValuePair = interface(IDispatch)
    ['{39038068-2B46-4AFD-8662-7BB6F868D221}']
    function Get_Name: WideString; safecall;
    procedure Set_Name(const pName: WideString); safecall;
    function Get_Value: WideString; safecall;
    procedure Set_Value(const pValue: WideString); safecall;
    property Name: WideString read Get_Name write Set_Name;
    property Value: WideString read Get_Value write Set_Value;
  end;


// *********************************************************************//
// Interface: ITaskNamedValueCollection
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {B4EF826B-63C3-46E4-A504-EF69E4F7EA4D}
// *********************************************************************//
  ITaskNamedValueCollection = interface(IDispatch)
    ['{B4EF826B-63C3-46E4-A504-EF69E4F7EA4D}']
    function Get_Count: LONG; safecall;
    function Get_Item(index: LONG): ITaskNamedValuePair; safecall;
    function Get__NewEnum: IUnknown; safecall;
    function Create(const Name: WideString; const Value: WideString): ITaskNamedValuePair; safecall;
    procedure Remove(index: LONG); safecall;
    procedure Clear; safecall;
    property Count: LONG read Get_Count;
    property Item[index: LONG]: ITaskNamedValuePair read Get_Item; default;
    property _NewEnum: IUnknown read Get__NewEnum;
  end;

// *********************************************************************//
// Interface: IIdleTrigger
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {D537D2B0-9FB3-4D34-9739-1FF5CE7B1EF3}
// *********************************************************************//
  IIdleTrigger = interface(ITrigger)
    ['{D537D2B0-9FB3-4D34-9739-1FF5CE7B1EF3}']
  end;


// *********************************************************************//
// Interface: ILogonTrigger
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {72DADE38-FAE4-4B3E-BAF4-5D009AF02B1C}
// *********************************************************************//
  ILogonTrigger = interface(ITrigger)
    ['{72DADE38-FAE4-4B3E-BAF4-5D009AF02B1C}']
    function Get_Delay: WideString; safecall;
    procedure Set_Delay(const pDelay: WideString); safecall;
    function Get_UserId: WideString; safecall;
    procedure Set_UserId(const pUser: WideString); safecall;
    property Delay: WideString read Get_Delay write Set_Delay;
    property UserId: WideString read Get_UserId write Set_UserId;
  end;

// *********************************************************************//
// Interface: ISessionStateChangeTrigger
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {754DA71B-4385-4475-9DD9-598294FA3641}
// *********************************************************************//
  ISessionStateChangeTrigger = interface(ITrigger)
    ['{754DA71B-4385-4475-9DD9-598294FA3641}']
    function Get_Delay: WideString; safecall;
    procedure Set_Delay(const pDelay: WideString); safecall;
    function Get_UserId: WideString; safecall;
    procedure Set_UserId(const pUser: WideString); safecall;
    function Get_StateChange: TTaskSessionStateChangeType; safecall;
    procedure Set_StateChange(pType: TTaskSessionStateChangeType); safecall;
    property Delay: WideString read Get_Delay write Set_Delay;
    property UserId: WideString read Get_UserId write Set_UserId;
    property StateChange: TTaskSessionStateChangeType read Get_StateChange write Set_StateChange;
  end;


// *********************************************************************//
// Interface: IEventTrigger
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {D45B0167-9653-4EEF-B94F-0732CA7AF251}
// *********************************************************************//
  IEventTrigger = interface(ITrigger)
    ['{D45B0167-9653-4EEF-B94F-0732CA7AF251}']
    function Get_Subscription: WideString; safecall;
    procedure Set_Subscription(const pQuery: WideString); safecall;
    function Get_Delay: WideString; safecall;
    procedure Set_Delay(const pDelay: WideString); safecall;
    function Get_ValueQueries: ITaskNamedValueCollection; safecall;
    procedure Set_ValueQueries(const ppNamedXPaths: ITaskNamedValueCollection); safecall;
    property Subscription: WideString read Get_Subscription write Set_Subscription;
    property Delay: WideString read Get_Delay write Set_Delay;
    property ValueQueries: ITaskNamedValueCollection read Get_ValueQueries write Set_ValueQueries;
  end;

// *********************************************************************//
// Interface: ITimeTrigger
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {B45747E0-EBA7-4276-9F29-85C5BB300006}
// *********************************************************************//
  ITimeTrigger = interface(ITrigger)
    ['{B45747E0-EBA7-4276-9F29-85C5BB300006}']
    function Get_RandomDelay: WideString; safecall;
    procedure Set_RandomDelay(const pRandomDelay: WideString); safecall;
    property RandomDelay: WideString read Get_RandomDelay write Set_RandomDelay;
  end;

// *********************************************************************//
// Interface: IDailyTrigger
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {126C5CD8-B288-41D5-8DBF-E491446ADC5C}
// *********************************************************************//
  IDailyTrigger = interface(ITrigger)
    ['{126C5CD8-B288-41D5-8DBF-E491446ADC5C}']
    function Get_DaysInterval: SHORT; safecall;
    procedure Set_DaysInterval(pDays: SHORT); safecall;
    function Get_RandomDelay: WideString; safecall;
    procedure Set_RandomDelay(const pRandomDelay: WideString); safecall;
    property DaysInterval: SHORT read Get_DaysInterval write Set_DaysInterval;
    property RandomDelay: WideString read Get_RandomDelay write Set_RandomDelay;
  end;

// *********************************************************************//
// Interface: IWeeklyTrigger
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {5038FC98-82FF-436D-8728-A512A57C9DC1}
// *********************************************************************//
  IWeeklyTrigger = interface(ITrigger)
    ['{5038FC98-82FF-436D-8728-A512A57C9DC1}']
    function Get_DaysOfWeek: SHORT; safecall;
    procedure Set_DaysOfWeek(pDays: SHORT); safecall;
    function Get_WeeksInterval: SHORT; safecall;
    procedure Set_WeeksInterval(pWeeks: SHORT); safecall;
    function Get_RandomDelay: WideString; safecall;
    procedure Set_RandomDelay(const pRandomDelay: WideString); safecall;
    property DaysOfWeek: SHORT read Get_DaysOfWeek write Set_DaysOfWeek;
    property WeeksInterval: SHORT read Get_WeeksInterval write Set_WeeksInterval;
    property RandomDelay: WideString read Get_RandomDelay write Set_RandomDelay;
  end;

// *********************************************************************//
// Interface: IMonthlyTrigger
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {97C45EF1-6B02-4A1A-9C0E-1EBFBA1500AC}
// *********************************************************************//
  IMonthlyTrigger = interface(ITrigger)
    ['{97C45EF1-6B02-4A1A-9C0E-1EBFBA1500AC}']
    function Get_DaysOfMonth: LONG; safecall;
    procedure Set_DaysOfMonth(pDays: LONG); safecall;
    function Get_MonthsOfYear: SHORT; safecall;
    procedure Set_MonthsOfYear(pMonths: SHORT); safecall;
    function Get_RunOnLastDayOfMonth: WordBool; safecall;
    procedure Set_RunOnLastDayOfMonth(pLastDay: WordBool); safecall;
    function Get_RandomDelay: WideString; safecall;
    procedure Set_RandomDelay(const pRandomDelay: WideString); safecall;
    property DaysOfMonth: LONG read Get_DaysOfMonth write Set_DaysOfMonth;
    property MonthsOfYear: SHORT read Get_MonthsOfYear write Set_MonthsOfYear;
    property RunOnLastDayOfMonth: WordBool read Get_RunOnLastDayOfMonth write Set_RunOnLastDayOfMonth;
    property RandomDelay: WideString read Get_RandomDelay write Set_RandomDelay;
  end;

// *********************************************************************//
// Interface: IMonthlyDOWTrigger
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {77D025A3-90FA-43AA-B52E-CDA5499B946A}
// *********************************************************************//
  IMonthlyDOWTrigger = interface(ITrigger)
    ['{77D025A3-90FA-43AA-B52E-CDA5499B946A}']
    function Get_DaysOfWeek: SHORT; safecall;
    procedure Set_DaysOfWeek(pDays: SHORT); safecall;
    function Get_WeeksOfMonth: SHORT; safecall;
    procedure Set_WeeksOfMonth(pWeeks: SHORT); safecall;
    function Get_MonthsOfYear: SHORT; safecall;
    procedure Set_MonthsOfYear(pMonths: SHORT); safecall;
    function Get_RunOnLastWeekOfMonth: WordBool; safecall;
    procedure Set_RunOnLastWeekOfMonth(pLastWeek: WordBool); safecall;
    function Get_RandomDelay: WideString; safecall;
    procedure Set_RandomDelay(const pRandomDelay: WideString); safecall;
    property DaysOfWeek: SHORT read Get_DaysOfWeek write Set_DaysOfWeek;
    property WeeksOfMonth: SHORT read Get_WeeksOfMonth write Set_WeeksOfMonth;
    property MonthsOfYear: SHORT read Get_MonthsOfYear write Set_MonthsOfYear;
    property RunOnLastWeekOfMonth: WordBool read Get_RunOnLastWeekOfMonth write Set_RunOnLastWeekOfMonth;
    property RandomDelay: WideString read Get_RandomDelay write Set_RandomDelay;
  end;

// *********************************************************************//
// Interface: IBootTrigger
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {2A9C35DA-D357-41F4-BBC1-207AC1B1F3CB}
// *********************************************************************//
  IBootTrigger = interface(ITrigger)
    ['{2A9C35DA-D357-41F4-BBC1-207AC1B1F3CB}']
    function Get_Delay: WideString; safecall;
    procedure Set_Delay(const pDelay: WideString); safecall;
    property Delay: WideString read Get_Delay write Set_Delay;
  end;


// *********************************************************************//
// Interface: IRegistrationTrigger
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {4C8FEC3A-C218-4E0C-B23D-629024DB91A2}
// *********************************************************************//
  IRegistrationTrigger = interface(ITrigger)
    ['{4C8FEC3A-C218-4E0C-B23D-629024DB91A2}']
    function Get_Delay: WideString; safecall;
    procedure Set_Delay(const pDelay: WideString); safecall;
    property Delay: WideString read Get_Delay write Set_Delay;
  end;



// *********************************************************************//
// Interface: IExecAction
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {4C3D624D-FD6B-49A3-B9B7-09CB3CD3F047}
// *********************************************************************//
  IExecAction = interface(IAction)
    ['{4C3D624D-FD6B-49A3-B9B7-09CB3CD3F047}']
    function Get_Path: WideString; safecall;
    procedure Set_Path(const pPath: WideString); safecall;
    function Get_Arguments: WideString; safecall;
    procedure Set_Arguments(const pArgument: WideString); safecall;
    function Get_WorkingDirectory: WideString; safecall;
    procedure Set_WorkingDirectory(const pWorkingDirectory: WideString); safecall;
    property Path: WideString read Get_Path write Set_Path;
    property Arguments: WideString read Get_Arguments write Set_Arguments;
    property WorkingDirectory: WideString read Get_WorkingDirectory write Set_WorkingDirectory;
  end;

// *********************************************************************//
// Interface: IShowMessageAction
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {505E9E68-AF89-46B8-A30F-56162A83D537}
// *********************************************************************//
  IShowMessageAction = interface(IAction)
    ['{505E9E68-AF89-46B8-A30F-56162A83D537}']
    function Get_Title: WideString; safecall;
    procedure Set_Title(const pTitle: WideString); safecall;
    function Get_MessageBody: WideString; safecall;
    procedure Set_MessageBody(const pMessageBody: WideString); safecall;
    property Title: WideString read Get_Title write Set_Title;
    property MessageBody: WideString read Get_MessageBody write Set_MessageBody;
  end;

// *********************************************************************//
// Interface: IComHandlerAction
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {6D2FD252-75C5-4F66-90BA-2A7D8CC3039F}
// *********************************************************************//
  IComHandlerAction = interface(IAction)
    ['{6D2FD252-75C5-4F66-90BA-2A7D8CC3039F}']
    function Get_ClassId: WideString; safecall;
    procedure Set_ClassId(const pClsid: WideString); safecall;
    function Get_Data: WideString; safecall;
    procedure Set_Data(const pData: WideString); safecall;
    property ClassId: WideString read Get_ClassId write Set_ClassId;
    property Data: WideString read Get_Data write Set_Data;
  end;

// *********************************************************************//
// Interface: IEmailAction
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {10F62C64-7E16-4314-A0C2-0C3683F99D40}
// *********************************************************************//
  IEmailAction = interface(IAction)
    ['{10F62C64-7E16-4314-A0C2-0C3683F99D40}']
    function Get_Server: WideString; safecall;
    procedure Set_Server(const pServer: WideString); safecall;
    function Get_Subject: WideString; safecall;
    procedure Set_Subject(const pSubject: WideString); safecall;
    function Get_To_: WideString; safecall;
    procedure Set_To_(const pTo: WideString); safecall;
    function Get_Cc: WideString; safecall;
    procedure Set_Cc(const pCc: WideString); safecall;
    function Get_Bcc: WideString; safecall;
    procedure Set_Bcc(const pBcc: WideString); safecall;
    function Get_ReplyTo: WideString; safecall;
    procedure Set_ReplyTo(const pReplyTo: WideString); safecall;
    function Get_From: WideString; safecall;
    procedure Set_From(const pFrom: WideString); safecall;
    function Get_HeaderFields: ITaskNamedValueCollection; safecall;
    procedure Set_HeaderFields(const ppHeaderFields: ITaskNamedValueCollection); safecall;
    function Get_Body: WideString; safecall;
    procedure Set_Body(const pBody: WideString); safecall;
    function Get_Attachments: PSafeArray; safecall;
    procedure Set_Attachments(pAttachements: PSafeArray); safecall;
    property Server: WideString read Get_Server write Set_Server;
    property Subject: WideString read Get_Subject write Set_Subject;
    property To_: WideString read Get_To_ write Set_To_;
    property Cc: WideString read Get_Cc write Set_Cc;
    property Bcc: WideString read Get_Bcc write Set_Bcc;
    property ReplyTo: WideString read Get_ReplyTo write Set_ReplyTo;
    property From: WideString read Get_From write Set_From;
    property HeaderFields: ITaskNamedValueCollection read Get_HeaderFields write Set_HeaderFields;
    property Body: WideString read Get_Body write Set_Body;
    property Attachments: PSafeArray read Get_Attachments write Set_Attachments;
  end;

// *********************************************************************//
// Interface: ITaskSettings2
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {2C05C3F0-6EED-4C05-A15F-ED7D7A98A369}
// *********************************************************************//
  ITaskSettings2 = interface(IDispatch)
    ['{2C05C3F0-6EED-4C05-A15F-ED7D7A98A369}']
    function Get_DisallowStartOnRemoteAppSession: WordBool; safecall;
    procedure Set_DisallowStartOnRemoteAppSession(pDisallowStart: WordBool); safecall;
    function Get_UseUnifiedSchedulingEngine: WordBool; safecall;
    procedure Set_UseUnifiedSchedulingEngine(pUseUnifiedEngine: WordBool); safecall;
    property DisallowStartOnRemoteAppSession: WordBool read Get_DisallowStartOnRemoteAppSession write Set_DisallowStartOnRemoteAppSession;
    property UseUnifiedSchedulingEngine: WordBool read Get_UseUnifiedSchedulingEngine write Set_UseUnifiedSchedulingEngine;
  end;





  CoTaskScheduler = class
    class function Create(const MachineName: WideString = ''): ITaskService;
  end;

  CoTaskHandlerPS = class
    class function Create(const MachineName: WideString = ''): ITaskHandler;
  end;

  CoTaskHandlerStatusPS = class
    class function Create(const MachineName: WideString = ''): ITaskHandlerStatus;
  end;

implementation

uses ComObj;

class function CoTaskScheduler.Create(const MachineName: WideString): ITaskService;
begin
    if MachineName = '' then
        Result := CreateComObject(CLSID_TaskScheduler) as ITaskService
    else
        Result := CreateRemoteComObject(MachineName, CLSID_TaskScheduler) as ITaskService;
end;

class function CoTaskHandlerPS.Create(const MachineName: WideString): ITaskHandler;
begin
    if  MachineName = '' then
        Result := CreateComObject(CLSID_TaskHandlerPS) as ITaskHandler
    else
        Result := CreateRemoteComObject(MachineName, CLSID_TaskHandlerPS) as ITaskHandler;
end;



class function CoTaskHandlerStatusPS.Create(const MachineName: WideString): ITaskHandlerStatus;
begin
    if MachineName = '' then
        Result := CreateComObject(CLSID_TaskHandlerStatusPS) as ITaskHandlerStatus
    else
        Result := CreateRemoteComObject(MachineName, CLSID_TaskHandlerStatusPS) as ITaskHandlerStatus;
end;

end.
