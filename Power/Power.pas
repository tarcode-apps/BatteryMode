unit Power;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils,
  System.Generics.Collections, System.Generics.Defaults,
  Power.WinApi.PowrProf;

const
    UnknownBrightness = $FF;

type
  {$MinEnumSize 4}
  TPowerSchemeType = (
    pstMaxPowerSavings,
    pstTypicalPowerSavings,
    pstMinPowerSavings,
    pstCustom
  );

  {$MinEnumSize 4}
  TOverlaySchemeType = (
    ostOverlayMin,
    ostOverlayNone,
    ostOverlayHigh,
    ostOverlayMax
  );

  TPowerSchemeFeature = (
    psfMissingScheme,
    psfOverlay,
    psfHiddenScheme
  );
  TPowerSchemeFeatures = set of TPowerSchemeFeature;

  IPowerScheme = interface
    function _GetBrightness(PowerCondition: TSystemPowerCondition): DWORD;
    procedure _SetBrightness(PowerCondition: TSystemPowerCondition;
      const Value: DWORD);
    function _GetUniqueString: string;
    function _GetFriendlyName: string;
    function _GetPowerSchemeType: TPowerSchemeType;
    function _GetOverlaySchemeType: TOverlaySchemeType;
    function _GetDischargeLevel(PowerCondition: TSystemPowerCondition): DWORD;
    procedure _SetDischargeLevel(PowerCondition: TSystemPowerCondition;
      const Value: DWORD);
    function _GetReserveLevel(PowerCondition: TSystemPowerCondition): DWORD;
    procedure _SetReserveLevel(PowerCondition: TSystemPowerCondition;
      const Value: DWORD);
    function _GetEnegrySaverBrightnessWeight(PowerCondition: TSystemPowerCondition): DWORD;
    procedure _SetEnegrySaverBrightnessWeight(PowerCondition: TSystemPowerCondition;
      const Value: DWORD);

    function Activate: Boolean;
    function IsActive: Boolean;
    function IsHidden: Boolean;

    function Equals(Value: IPowerScheme): Boolean;
    function Copy: IPowerScheme;

    property Brightness[PowerCondition: TSystemPowerCondition]: DWORD read _GetBrightness write _SetBrightness;
    property UniqueString: string read _GetUniqueString;
    property FriendlyName: string read _GetFriendlyName;
    property PowerSchemeType: TPowerSchemeType read _GetPowerSchemeType;
    property OverlaySchemeType: TOverlaySchemeType read _GetOverlaySchemeType;
    property DischargeLevel[PowerCondition: TSystemPowerCondition]: DWORD read _GetDischargeLevel write _SetDischargeLevel;
    property ReserveLevel[PowerCondition: TSystemPowerCondition]: DWORD read _GetReserveLevel write _SetReserveLevel;
    property EnegrySaverBrightnessWeight[PowerCondition: TSystemPowerCondition]: DWORD read _GetEnegrySaverBrightnessWeight write _SetEnegrySaverBrightnessWeight;
  end;

  EPowerSchemeBrightnessError = class(Exception);

  TPowerSchemeComparer = class(TComparer<IPowerScheme>)
  public
    function Compare(const Left, Right: IPowerScheme): Integer; override;
  end;

  TPowerSchemeList = class(TList<IPowerScheme>)
  protected
    function GetActiveScheme: IPowerScheme; virtual;
  public
    constructor Create; overload;
    function Copy: TPowerSchemeList; virtual; abstract;
    function Find(UniqueString: string): IPowerScheme; virtual;
    property ActiveScheme: IPowerScheme read GetActiveScheme;
  end;

  TEventActivatePowerScheme = procedure(Sender: TObject; const PowerScheme: IPowerScheme) of object;
  TEventUpdatePowerSchemes = procedure(Sender: TObject; const PowerSchemes: TPowerSchemeList) of object;
  TEventPowerSchemeValueChange = procedure(Sender: TObject; const Value: DWORD) of object;
  TEventEnegrySaverSwitched = procedure(Sender: TObject; const Value: Boolean) of object;

  IPowerSchemeProvider = interface
    function _GetActive: IPowerScheme;
    function _GetSchemes: TPowerSchemeList;

    function _GetSchemeFeatures: TPowerSchemeFeatures;
    procedure _SetSchemeFeatures(const Value: TPowerSchemeFeatures);
    function _GetSupportedSchemeFeatures: TPowerSchemeFeatures;

    procedure _SetBrightnessForAllScheme(PowerCondition: TSystemPowerCondition;
      const Value: DWORD);

    function _GetEnegrySaver: Boolean;
    procedure _SetEnegrySaver(const Value: Boolean);
    function _GetEnegrySaverBrightnessWeight: DWORD;

    function _GetOnActivate: TEventActivatePowerScheme;
    procedure _SetOnActivate(const Value: TEventActivatePowerScheme);

    function _GetOnUpdate: TEventUpdatePowerSchemes;
    procedure _SetOnUpdate(const Value: TEventUpdatePowerSchemes);

    function _GetOnInternalActivating: TEventActivatePowerScheme;
    procedure _SetOnInternalActivating(const Value: TEventActivatePowerScheme);
    function _GetOnInternalActivated: TEventActivatePowerScheme;
    procedure _SetOnInternalActivated(const Value: TEventActivatePowerScheme);

    function _GetOnEnegrySaverSwitched: TEventEnegrySaverSwitched;
    procedure _SetOnEnegrySaverSwitched(const Value: TEventEnegrySaverSwitched);
    function _GetOnEnegrySaverBrightnessWeightChange: TEventPowerSchemeValueChange;
    procedure _SetOnEnegrySaverBrightnessWeightChange(const Value: TEventPowerSchemeValueChange);

    function CheckForUpdates: Boolean;
    function ReActivate: Boolean;
    function MakeSchemeFromUniqueString(UniqueString: string): IPowerScheme;

    property Active: IPowerScheme read _GetActive;
    property Schemes: TPowerSchemeList read _GetSchemes;
    property SchemeFeatures: TPowerSchemeFeatures read _GetSchemeFeatures write _SetSchemeFeatures;
    property SupportedSchemeFeatures: TPowerSchemeFeatures read _GetSupportedSchemeFeatures;
    property BrightnessForAllScheme[PowerCondition: TSystemPowerCondition]: DWORD write _SetBrightnessForAllScheme;
    property EnegrySaver: Boolean read _GetEnegrySaver write _SetEnegrySaver;
    property EnegrySaverBrightnessWeight: DWORD read _GetEnegrySaverBrightnessWeight;
    property OnActivate: TEventActivatePowerScheme read _GetOnActivate write _SetOnActivate;
    property OnUpdate: TEventUpdatePowerSchemes read _GetOnUpdate write _SetOnUpdate;
    property OnInternalActivating: TEventActivatePowerScheme read _GetOnInternalActivating write _SetOnInternalActivating;
    property OnInternalActivated: TEventActivatePowerScheme read _GetOnInternalActivated write _SetOnInternalActivated;
    property OnEnegrySaverSwitched: TEventEnegrySaverSwitched read _GetOnEnegrySaverSwitched write _SetOnEnegrySaverSwitched;
    property OnEnegrySaverBrightnessWeightChange: TEventPowerSchemeValueChange read _GetOnEnegrySaverBrightnessWeightChange write _SetOnEnegrySaverBrightnessWeightChange;
  end;

  {$MinEnumSize 4}
  TPowerActionType = (patShutdown, patReboot, patSleep, patHibernate, patLogOut, patLock, patDiagnostic, patDisconnect);

  IPowerAction = interface
    function _GetActionType: TPowerActionType;

    function Perform: Boolean;
    function IsSupported: Boolean;

    property ActionType: TPowerActionType read _GetActionType;
  end;

implementation

{ TPowerSchemeComparer }

function TPowerSchemeComparer.Compare(const Left, Right: IPowerScheme): Integer;
begin
  if Left.UniqueString = Right.UniqueString then Exit(0);

  if (Left.PowerSchemeType = pstCustom) and (Right.PowerSchemeType = pstCustom) then
    Exit(CompareText(Left.FriendlyName, Right.FriendlyName));

  if Left.PowerSchemeType > Right.PowerSchemeType then
    Exit(1)
  else if Left.PowerSchemeType < Right.PowerSchemeType then
    Exit(-1)
  else
  begin
    if Left.OverlaySchemeType > Right.OverlaySchemeType then
      Exit(1)
    else if Left.OverlaySchemeType < Right.OverlaySchemeType then
      Exit(-1)
    else
      Exit(0);
  end;
end;

{ TPowerSchemeList }

constructor TPowerSchemeList.Create;
begin
  inherited Create(TPowerSchemeComparer.Create);
end;

function TPowerSchemeList.Find(UniqueString: string): IPowerScheme;
var
  Scheme: IPowerScheme;
begin
  for Scheme in Self do
    if Scheme.UniqueString = UniqueString then
      Exit(Scheme);
  Result := nil;
end;

function TPowerSchemeList.GetActiveScheme: IPowerScheme;
var
  Scheme: IPowerScheme;
begin
  for Scheme in Self do
    if Scheme.IsActive then
      Exit(Scheme);
  Result := nil;
end;

end.
