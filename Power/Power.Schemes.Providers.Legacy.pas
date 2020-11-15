unit Power.Schemes.Providers.Legacy;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Classes,
  System.Generics.Collections, System.Generics.Defaults,
  Core.Language,
  Power,
  Power.WinApi.PowrProf, Power.WinApi.PowrProf.Legacy;

type
  TPowerSchemeLegacy = class;
  TPowerSchemesLegacy = class;
  TPowerSchemeProviderLegacy = class;

  TPowerSchemeLegacy = class(TInterfacedObject, IPowerScheme)
  strict private type
    TEnumPwrSchemesProcParamName = record
      UiID: UINT;
      Name: string;
    end;
    PEnumPwrSchemesProcParamName = ^TEnumPwrSchemesProcParamName;
  strict private
    class function EnumPwrSchemesProcName(uiIndex: UINT; dwName: DWORD; sName: LPTSTR;
      dwDesc: DWORD; sDesc: LPTSTR; pp: PPOWER_POLICY; lParam: LPARAM): Boolean; stdcall; static;
    class function ReadPowerSchemeName(UiID: UINT): string;
  strict private
    [weak] FProvider: TPowerSchemeProviderLegacy;
    FUiID: UINT;
    FFriendlyName: string;
    FIsHidden: Boolean;
  strict private
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
  protected
    constructor Create(UiID: UINT; Provider: TPowerSchemeProviderLegacy); overload;
    constructor Create(UiID: UINT; Name: string; Provider: TPowerSchemeProviderLegacy); overload;
  public
    constructor Create(UiID: UINT); overload;
    constructor Create(UiID: UINT; Name: string); overload;

    property UiID: UINT read FUiID;
  public
    function Activate: Boolean;
    function IsActive: Boolean;
    function IsHidden: Boolean;

    function Equals(Value: IPowerScheme): Boolean; reintroduce;
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

  TPowerSchemesLegacy = class(TPowerSchemeList)
  protected
    function GetActiveScheme: IPowerScheme; override;
  public
    function Copy: TPowerSchemeList; override;
  end;

  TPowerSchemeProviderLegacy = class(TInterfacedObject, IPowerSchemeProvider)
  strict private const
    TimerSchemeCheck = 1;
  strict private type
    TEnumPwrSchemesProcParam = record
      Provider: TPowerSchemeProviderLegacy;
      Schemes: TPowerSchemesLegacy;
      ShowHiddedScheme: Boolean;
      HiddedSchemePresent: Boolean;
    end;
    PEnumPwrSchemesProcParam = ^TEnumPwrSchemesProcParam;
  strict private
    class function EnumPwrSchemesProc(uiIndex: UINT; dwName: DWORD; sName: LPTSTR;
      dwDesc: DWORD; sDesc: LPTSTR; pp: PPOWER_POLICY; lParam: LPARAM): Boolean; stdcall; static;
  strict private
    FMsgWnd: HWND;
    FSchemes: TPowerSchemesLegacy;
    FActive: IPowerScheme;
    FSchemeFeatures: TPowerSchemeFeatures;
    FSupportedSchemeFeatures: TPowerSchemeFeatures;

    FOnActivate: TEventActivatePowerScheme;
    FOnUpdate: TEventUpdatePowerSchemes;
    FOnInternalActivating: TEventActivatePowerScheme;
    FOnInternalActivated: TEventActivatePowerScheme;

    FOnEnegrySaverChange: TEventEnegrySaverSwitched;
    FOnEnegrySaverBrightnessWeightChange: TEventPowerSchemeValueChange;

    procedure MsgWndHandle(var Msg: TMessage);
    function LoadPowerScheme: TPowerSchemesLegacy;
  strict private
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
  protected
    procedure DoInternalActivating(Sender: IPowerScheme);
    procedure DoInternalActivated(Sender: IPowerScheme);
  public
    constructor Create;
    destructor Destroy; override;
  public
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

implementation

{ TPowerSchemeLegacy }

class function TPowerSchemeLegacy.EnumPwrSchemesProcName(uiIndex: UINT;
  dwName: DWORD; sName: LPTSTR; dwDesc: DWORD; sDesc: LPTSTR; pp: PPOWER_POLICY;
  lParam: LPARAM): Boolean;
var
  Params: PEnumPwrSchemesProcParamName;
begin
  Params := PEnumPwrSchemesProcParamName(lParam);
  if uiIndex = Params^.UiID then
  begin
    Params^.Name := sName;
    Exit(False);
  end;

  Result := True;
end;

class function TPowerSchemeLegacy.ReadPowerSchemeName(UiID: UINT): string;
var
  Params: TEnumPwrSchemesProcParamName;
begin
  Params.UiID := UiID;
  Params.Name := '';
  EnumPwrSchemes(EnumPwrSchemesProcName, LPARAM(@Params));
  Result := Params.Name;
end;

constructor TPowerSchemeLegacy.Create(UiID: UINT);
begin
  Create(UiID, ReadPowerSchemeName(FUiID), nil);
end;

constructor TPowerSchemeLegacy.Create(UiID: UINT; Name: string);
begin
  Create(UiID, Name, nil);
end;

constructor TPowerSchemeLegacy.Create(UiID: UINT;
  Provider: TPowerSchemeProviderLegacy);
begin
  Create(UiID, ReadPowerSchemeName(FUiID), Provider);
end;

constructor TPowerSchemeLegacy.Create(UiID: UINT; Name: string;
  Provider: TPowerSchemeProviderLegacy);
begin
  FUiID := UiID;
  FFriendlyName := Name;
  FProvider := Provider;

  FIsHidden :=  string.IsNullOrWhiteSpace(FFriendlyName);
  if FIsHidden then FFriendlyName := TLang[27];
end;

function TPowerSchemeLegacy._GetBrightness(
  PowerCondition: TSystemPowerCondition): DWORD;
begin
  Result := UnknownBrightness;
end;

procedure TPowerSchemeLegacy._SetBrightness(
  PowerCondition: TSystemPowerCondition; const Value: DWORD);
begin
  // Not supported
end;

function TPowerSchemeLegacy._GetUniqueString: string;
begin
  Result := UIntToStr(FUiID);
end;

function TPowerSchemeLegacy._GetFriendlyName: string;
begin
  Result := FFriendlyName;
end;

function TPowerSchemeLegacy._GetPowerSchemeType: TPowerSchemeType;
begin
  Result := pstCustom;
end;

function TPowerSchemeLegacy._GetOverlaySchemeType: TOverlaySchemeType;
begin
  Result := ostOverlayNone;
end;

function TPowerSchemeLegacy._GetDischargeLevel(
  PowerCondition: TSystemPowerCondition): DWORD;
begin
  Result := 0;
end;

procedure TPowerSchemeLegacy._SetDischargeLevel(
  PowerCondition: TSystemPowerCondition; const Value: DWORD);
begin
  // Not supported
end;

function TPowerSchemeLegacy._GetReserveLevel(
  PowerCondition: TSystemPowerCondition): DWORD;
begin
  Result := 0;
end;

procedure TPowerSchemeLegacy._SetReserveLevel(
  PowerCondition: TSystemPowerCondition; const Value: DWORD);
begin
  // Not supported
end;

function TPowerSchemeLegacy._GetEnegrySaverBrightnessWeight(
  PowerCondition: TSystemPowerCondition): DWORD;
begin
  Result := 100;
end;

procedure TPowerSchemeLegacy._SetEnegrySaverBrightnessWeight(
  PowerCondition: TSystemPowerCondition; const Value: DWORD);
begin
  // Not supported
end;

function TPowerSchemeLegacy.Activate: Boolean;
begin
  if Assigned(FProvider) then
    FProvider.DoInternalActivating(Self);

  if IsActive then Exit(True);
  Result := SetActivePwrScheme(FUiID, nil, nil);

  if Assigned(FProvider) and Result then
    FProvider.DoInternalActivated(Self);
end;

function TPowerSchemeLegacy.IsActive: Boolean;
var
  ActiveUiID: UINT;
begin
  if not GetActivePwrScheme(ActiveUiID) then
    Exit(False);

  Result := FUiID = ActiveUiID;
end;

function TPowerSchemeLegacy.IsHidden: Boolean;
begin
  Result := FIsHidden;
end;

function TPowerSchemeLegacy.Equals(Value: IPowerScheme): Boolean;
begin
  if Value is TPowerSchemeLegacy then
    Result := UiID = TPowerSchemeLegacy(Value).UiID
  else
    Result := False;
end;

function TPowerSchemeLegacy.Copy: IPowerScheme;
begin
  Result := TPowerSchemeLegacy.Create(FUiID, FriendlyName, FProvider);
end;

{ TPowerSchemesLegacy }

function TPowerSchemesLegacy.GetActiveScheme: IPowerScheme;
var
  ActiveUiID: UINT;
  Scheme: IPowerScheme;
begin
  if not GetActivePwrScheme(ActiveUiID) then
    Exit(nil);

  for Scheme in Self do
    if (Scheme as TPowerSchemeLegacy).UiID = ActiveUiID then
      Exit(Scheme);
  Result := nil;
end;

function TPowerSchemesLegacy.Copy: TPowerSchemeList;
var
  Scheme: IPowerScheme;
begin
  Result := TPowerSchemesLegacy.Create;
  for Scheme in Self do
    Result.Add(Scheme.Copy);
end;

{ TPowerSchemeProviderLegacy }

class function TPowerSchemeProviderLegacy.EnumPwrSchemesProc(uiIndex: UINT;
  dwName: DWORD; sName: LPTSTR; dwDesc: DWORD; sDesc: LPTSTR; pp: PPOWER_POLICY;
  lParam: LPARAM): Boolean;
var
  Params: PEnumPwrSchemesProcParam;
  Scheme: IPowerScheme;
begin
  Params := PEnumPwrSchemesProcParam(lParam);
  Scheme := TPowerSchemeLegacy.Create(uiIndex, sName, Params.Provider);
  if Scheme.IsHidden then
  begin
    if Params^.ShowHiddedScheme then
      Params^.Schemes.Add(Scheme);
    Params^.HiddedSchemePresent := True;
  end
  else
    Params^.Schemes.Add(Scheme);

  Result := True;
end;

constructor TPowerSchemeProviderLegacy.Create;
var
  SystemPowerStatus: TSystemPowerStatus;
begin
  inherited;

  GetSystemPowerStatus(SystemPowerStatus);

  FSchemeFeatures := [psfHiddenScheme];
  FSupportedSchemeFeatures := [];
  FSchemes := TPowerSchemesLegacy.Create;

  CheckForUpdates;

  FMsgWnd := AllocateHWnd(MsgWndHandle);

  if SetTimer(FMsgWnd, TimerSchemeCheck, 1000, nil) = 0 then
    RaiseLastOSError;
end;

destructor TPowerSchemeProviderLegacy.Destroy;
begin
  KillTimer(FMsgWnd, TimerSchemeCheck);

  DeallocateHWnd(FMsgWnd);

  FSchemes.Free;

  inherited;
end;

function TPowerSchemeProviderLegacy.CheckForUpdates: Boolean;
var
  NewList, OldList: TPowerSchemesLegacy;
  ActiveUiID: UINT;
  Scheme: IPowerScheme;
begin
  NewList := LoadPowerScheme;

  Result := NewList.Count <> FSchemes.Count;

  if not Result then
    for Scheme in NewList do
      if not FSchemes.Contains(Scheme) then
      begin
        Result := True;
        Break;
      end;

  if Result then
  begin
    OldList := FSchemes;
    FSchemes := NewList;
    OldList.Free;

    if not GetActivePwrScheme(ActiveUiID) then
      RaiseLastOSError;
    Scheme := FSchemes.Find(UIntToStr(ActiveUiID));
    if Scheme = nil then
      Scheme := TPowerSchemeLegacy.Create(ActiveUiID, '', Self);

    if FActive <> Scheme then
    begin
      FActive := Scheme;
      if Assigned(FOnUpdate) then FOnUpdate(Self, FSchemes);
      if Assigned(FOnActivate) then FOnActivate(Self, FActive);
    end
    else
      if Assigned(FOnUpdate) then FOnUpdate(Self, FSchemes);
  end else
    NewList.Free;
end;

function TPowerSchemeProviderLegacy.ReActivate: Boolean;
var
  ActiveUiID: UINT;
begin
  if not GetActivePwrScheme(ActiveUiID) then
    Exit(False);
  Result := SetActivePwrScheme(ActiveUiID, nil, nil);
end;

function TPowerSchemeProviderLegacy.MakeSchemeFromUniqueString(
  UniqueString: string): IPowerScheme;
begin
  Result := FSchemes.Find(UniqueString);
  if Result = nil then
    Result := TPowerSchemeLegacy.Create(UINT(StrToUInt64(UniqueString)), Self);
end;

function TPowerSchemeProviderLegacy._GetActive: IPowerScheme;
begin
  Result := FActive;
end;

function TPowerSchemeProviderLegacy._GetSchemeFeatures: TPowerSchemeFeatures;
begin
  Result := FSchemeFeatures;
end;

procedure TPowerSchemeProviderLegacy._SetSchemeFeatures(
  const Value: TPowerSchemeFeatures);
begin
  if FSchemeFeatures = Value then Exit;

  FSchemeFeatures := Value;
  CheckForUpdates;
end;

function TPowerSchemeProviderLegacy._GetSupportedSchemeFeatures: TPowerSchemeFeatures;
begin
  Result := FSupportedSchemeFeatures;
end;

function TPowerSchemeProviderLegacy._GetSchemes: TPowerSchemeList;
begin
  Result := FSchemes;
end;

procedure TPowerSchemeProviderLegacy._SetBrightnessForAllScheme(
  PowerCondition: TSystemPowerCondition; const Value: DWORD);
begin
  // Not supported
end;

function TPowerSchemeProviderLegacy._GetEnegrySaver: Boolean;
begin
  Result := False;
end;

procedure TPowerSchemeProviderLegacy._SetEnegrySaver(const Value: Boolean);
begin
  // Not supported
end;

function TPowerSchemeProviderLegacy._GetEnegrySaverBrightnessWeight: DWORD;
begin
  Result := 100;
end;

function TPowerSchemeProviderLegacy._GetOnActivate: TEventActivatePowerScheme;
begin
  Result := FOnActivate;
end;

procedure TPowerSchemeProviderLegacy._SetOnActivate(
  const Value: TEventActivatePowerScheme);
begin
  FOnActivate := Value;
  if Assigned(FOnActivate) then
    FOnActivate(Self, Active);
end;

function TPowerSchemeProviderLegacy._GetOnUpdate: TEventUpdatePowerSchemes;
begin
  Result := FOnUpdate;
end;

procedure TPowerSchemeProviderLegacy._SetOnUpdate(
  const Value: TEventUpdatePowerSchemes);
begin
  FOnUpdate := Value;
  if Assigned(FOnUpdate) then
    FOnUpdate(Self, FSchemes);
end;

function TPowerSchemeProviderLegacy._GetOnInternalActivating: TEventActivatePowerScheme;
begin
  Result := FOnInternalActivating;
end;

procedure TPowerSchemeProviderLegacy._SetOnInternalActivating(
  const Value: TEventActivatePowerScheme);
begin
  FOnInternalActivating := Value;
end;

function TPowerSchemeProviderLegacy._GetOnInternalActivated: TEventActivatePowerScheme;
begin
  Result := FOnInternalActivated;
end;

procedure TPowerSchemeProviderLegacy._SetOnInternalActivated(
  const Value: TEventActivatePowerScheme);
begin
  FOnInternalActivated := Value;
end;

function TPowerSchemeProviderLegacy._GetOnEnegrySaverSwitched: TEventEnegrySaverSwitched;
begin
  Result := FOnEnegrySaverChange;
end;

procedure TPowerSchemeProviderLegacy._SetOnEnegrySaverSwitched(
  const Value: TEventEnegrySaverSwitched);
begin
  FOnEnegrySaverChange := Value;
end;

function TPowerSchemeProviderLegacy._GetOnEnegrySaverBrightnessWeightChange: TEventPowerSchemeValueChange;
begin
  Result := FOnEnegrySaverBrightnessWeightChange;
end;

procedure TPowerSchemeProviderLegacy._SetOnEnegrySaverBrightnessWeightChange(
  const Value: TEventPowerSchemeValueChange);
begin
  FOnEnegrySaverBrightnessWeightChange := Value;
end;

procedure TPowerSchemeProviderLegacy.DoInternalActivating(Sender: IPowerScheme);
begin
  if Assigned(FOnInternalActivating) then
    FOnInternalActivating(Self, Sender);
end;

procedure TPowerSchemeProviderLegacy.DoInternalActivated(Sender: IPowerScheme);
begin
  FActive := Sender;

  if Assigned(FOnActivate) then
    FOnActivate(Self, Sender);

  if Assigned(FOnInternalActivated) then
    FOnInternalActivated(Self, Sender);
end;

procedure TPowerSchemeProviderLegacy.MsgWndHandle(var Msg: TMessage);
var
  ActiveUiID: UINT;
begin
  Msg.Result := DefWindowProc(FMsgWnd, Msg.Msg, Msg.WParam, Msg.LParam);

  if Msg.Msg = WM_TIMER then
  begin
    case Msg.WParam of
      TimerSchemeCheck:
        begin
          if GetActivePwrScheme(ActiveUiID) and (UIntToStr(ActiveUiID) <> FActive.UniqueString) then
          begin
            FActive := FSchemes.Find(UIntToStr(ActiveUiID));
            if FActive = nil then
            begin
              if CheckForUpdates then
                Exit;
              FActive := TPowerSchemeLegacy.Create(ActiveUiID, Self);
            end;

            if Assigned(FOnActivate) then
              FOnActivate(Self, FActive);
            Exit;
          end;
          Exit;
        end;
    end;
  end;
end;

function TPowerSchemeProviderLegacy.LoadPowerScheme: TPowerSchemesLegacy;
var
  Param: TEnumPwrSchemesProcParam;
begin
  Result := TPowerSchemesLegacy.Create;

  Param.Provider := Self;
  Param.Schemes := Result;
  Param.ShowHiddedScheme := psfHiddenScheme in FSchemeFeatures;
  Param.HiddedSchemePresent := False;

  Exclude(FSupportedSchemeFeatures, psfHiddenScheme);
  if EnumPwrSchemes(EnumPwrSchemesProc, LPARAM(@Param)) then
    if Param.HiddedSchemePresent then
      Include(FSupportedSchemeFeatures, psfHiddenScheme);

  Result.Sort;
end;

end.
