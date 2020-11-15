unit Scheduling.Conditions;

interface

uses
  Winapi.Windows,
  System.SysUtils, System.Classes,
  Battery.Mode,
  Core.Language,
  Power, Power.Display,
  Power.WinApi.PowrProf,
  Scheduling;

type
  TConditionPercentage = class(TInterfacedObject, ICondition)
  public type
    TClause = (pcLower, pcHigher);
  strict private const
    CmdLower      = 'Lower';
    CmdHigher     = 'Higher';
    PercentageDelim = ':';
  strict private
    FID: Integer;
    FClause: TClause;
    FPercentage: DWORD;

    function ClauseText(Clause: TClause): string;
  strict protected
    function _GetConditionType: TConditionType;
    function _GetID: Integer;
    procedure _SetID(const Value: Integer);
    function _GetCfgStr: string;
    function _GetDescription: string;
  public
    constructor Create(Clause: TClause; Percentage: DWORD = 0); overload;

    function Check(const Previous, Current: TState): Boolean;
    function Parse(CfgStr: string): Boolean;
    function Copy: ICondition;

    property ConditionType: TConditionType read _GetConditionType;
    property ID: Integer read _GetID write _SetID;
    property CfgStr: string read _GetCfgStr;
    property Description: string read _GetDescription;

    property Clause: TClause read FClause;
    property Percentage: DWORD read FPercentage;
  end;

  TConditionAc = class(TInterfacedObject, ICondition)
  public type
    TClause = (accConnected, accDisconnected);
  strict private const
    CmdConnected    = 'Connected';
    CmdDisconnected = 'Disconnected';
  strict private
    FID: Integer;
    FClause: TClause;

    function ClauseText(Clause: TClause): string;
  strict protected
    function _GetConditionType: TConditionType;
    function _GetID: Integer;
    procedure _SetID(const Value: Integer);
    function _GetCfgStr: string;
    function _GetDescription: string;
  public
    constructor Create(Clause: TClause); overload;

    function Check(const Previous, Current: TState): Boolean;
    function Parse(CfgStr: string): Boolean;
    function Copy: ICondition;

    property ConditionType: TConditionType read _GetConditionType;
    property ID: Integer read _GetID write _SetID;
    property CfgStr: string read _GetCfgStr;
    property Description: string read _GetDescription;

    property Clause: TClause read FClause;
  end;

  TConditionLidSwitch = class(TInterfacedObject, ICondition)
  public type
    TClause = (lscClose, lscOpen);
  strict private const
    CmdClose  = 'Close';
    CmdOpen   = 'Open';
  strict private
    FID: Integer;
    FClause: TClause;

    function ClauseText(Clause: TClause): string;
  strict protected
    function _GetConditionType: TConditionType;
    function _GetID: Integer;
    procedure _SetID(const Value: Integer);
    function _GetCfgStr: string;
    function _GetDescription: string;
  public
    constructor Create(Clause: TClause); overload;

    function Check(const Previous, Current: TState): Boolean;
    function Parse(CfgStr: string): Boolean;
    function Copy: ICondition;

    property ConditionType: TConditionType read _GetConditionType;
    property ID: Integer read _GetID write _SetID;
    property CfgStr: string read _GetCfgStr;
    property Description: string read _GetDescription;

    property Clause: TClause read FClause;
  end;

  TConditionDisplayState = class(TInterfacedObject, ICondition)
  public type
    TClause = (dscOff, dscOn, dscDimmed);
  strict private const
    CmdOff    = 'Off';
    CmdOn     = 'On';
    CmdDimmed = 'Dimmed';
  strict private
    FID: Integer;
    FClause: TClause;

    function ClauseText(Clause: TClause): string;
  strict protected
    function _GetConditionType: TConditionType;
    function _GetID: Integer;
    procedure _SetID(const Value: Integer);
    function _GetCfgStr: string;
    function _GetDescription: string;
  public
    constructor Create(Clause: TClause); overload;

    function Check(const Previous, Current: TState): Boolean;
    function Parse(CfgStr: string): Boolean;
    function Copy: ICondition;

    property ConditionType: TConditionType read _GetConditionType;
    property ID: Integer read _GetID write _SetID;
    property CfgStr: string read _GetCfgStr;
    property Description: string read _GetDescription;

    property Clause: TClause read FClause;
  end;

  TConditionScheme = class(TInterfacedObject, ICondition)
  strict private
    FID: Integer;
    FClause: IPowerScheme;
  strict protected
    function _GetConditionType: TConditionType; virtual;
    function _GetID: Integer;
    procedure _SetID(const Value: Integer);
    function _GetCfgStr: string;
    function _GetDescription: string; virtual;

    function GetClauseName: string;
  public
    constructor Create(Scheme: IPowerScheme); overload;

    function Check(const Previous, Current: TState): Boolean; virtual;
    function Parse(CfgStr: string): Boolean;
    function Copy: ICondition; virtual;

    property ConditionType: TConditionType read _GetConditionType;
    property ID: Integer read _GetID write _SetID;
    property CfgStr: string read _GetCfgStr;
    property Description: string read _GetDescription;

    property Clause: IPowerScheme read FClause;
  end;

  TConditionNotScheme = class(TConditionScheme)
  strict protected
    function _GetConditionType: TConditionType; override;
    function _GetDescription: string; override;
  public
    function Check(const Previous, Current: TState): Boolean; override;
    function Copy: ICondition; override;
  end;

implementation

{ TConditionPercentage }

constructor TConditionPercentage.Create(Clause: TClause;
  Percentage: DWORD);
begin
  inherited Create;

  FClause := Clause;
  FPercentage := Percentage;
end;

function TConditionPercentage.Check(const Previous, Current: TState): Boolean;
begin
  Result := False;
  case FClause of
    pcLower:
      Result := (Current.Percentage < FPercentage);
    pcHigher:
      Result := (Current.Percentage > FPercentage);
  end;
end;

function TConditionPercentage._GetConditionType: TConditionType;
begin
  Result := ctPercent;
end;

function TConditionPercentage._GetID: Integer;
begin
  Result := FID;
end;

procedure TConditionPercentage._SetID(const Value: Integer);
begin
  FID := Value;
end;

function TConditionPercentage._GetCfgStr: string;
begin
  Result := string.Join(PercentageDelim, [ClauseText(FClause), FPercentage])
end;

function TConditionPercentage.Parse(CfgStr: string): Boolean;
var
  Parts: TArray<string>;
begin
  try
    Parts := CfgStr.Split([PercentageDelim]);
    if Length(Parts) < 2 then Exit(False);

    FPercentage := DWORD.Parse(Parts[1]);

    if CompareText(Parts[0], CmdLower) = 0 then
    begin
      FClause := pcLower;
      Exit(True);
    end;

    if CompareText(Parts[0], CmdHigher) = 0 then
    begin
      FClause := pcHigher;
      Exit(True);
    end;

    Result := False;
  except
    Exit(False);
  end;
end;

function TConditionPercentage.Copy: ICondition;
begin
  Result := TConditionPercentage.Create;
  with Result as TConditionPercentage do
  begin
    FClause := Self.FClause;
    FPercentage := Self.FPercentage;
    FID := Self.FID;
  end;
end;

function TConditionPercentage._GetDescription: string;
const
  ClauseTypeIndex: array [TClause] of Integer = (1305, 1306);
begin
  Result := Format(TLang[1300], [TLang[ClauseTypeIndex[FClause]], FPercentage]);
end;

function TConditionPercentage.ClauseText(Clause: TClause): string;
begin
  case Clause of
    pcLower: Result := CmdLower;
    pcHigher: Result := CmdHigher;
  end;
end;

{ TConditionAc }

constructor TConditionAc.Create(Clause: TClause);
begin
  inherited Create;

  FClause := Clause;
end;

function TConditionAc.Check(const Previous, Current: TState): Boolean;
begin
  Result := False;
  case FClause of
    accConnected:
      Result := (Current.PowerCondition = PoAc);
    accDisconnected:
      Result := (Current.PowerCondition <> PoAc);
  end;
end;

function TConditionAc._GetConditionType: TConditionType;
begin
  Result := ctAc;
end;

function TConditionAc._GetID: Integer;
begin
  Result := FID;
end;

procedure TConditionAc._SetID(const Value: Integer);
begin
  FID := Value;
end;

function TConditionAc._GetCfgStr: string;
begin
  Result := ClauseText(FClause);
end;

function TConditionAc.Parse(CfgStr: string): Boolean;
begin
  try
    if CompareText(CfgStr, CmdConnected) = 0 then
    begin
      FClause := accConnected;
      Exit(True);
    end;

    if CompareText(CfgStr, CmdDisconnected) = 0 then
    begin
      FClause := accDisconnected;
      Exit(True);
    end;

    Result := False;
  except
    Exit(False);
  end;
end;

function TConditionAc.Copy: ICondition;
begin
  Result := TConditionAc.Create;
  with Result as TConditionAc do
  begin
    FClause := Self.FClause;
    FID := Self.FID;
  end;
end;

function TConditionAc._GetDescription: string;
const
  ClauseIndex: array [TClause] of Integer = (1325, 1326);
begin
  Result := Format(TLang[1320], [TLang[ClauseIndex[FClause]]]);
end;

function TConditionAc.ClauseText(Clause: TClause): string;
begin
  case Clause of
    accConnected: Result := CmdConnected;
    accDisconnected: Result := CmdDisconnected;
  end;
end;

{ TConditionLidSwitch }

constructor TConditionLidSwitch.Create(Clause: TClause);
begin
  inherited Create;

  FClause := Clause;
end;

function TConditionLidSwitch.Check(const Previous, Current: TState): Boolean;
begin
  Result := False;
  case FClause of
    lscClose:
      Result := not Current.LidSwitchOpen;
    lscOpen:
      Result := Current.LidSwitchOpen;
  end;
end;

function TConditionLidSwitch._GetConditionType: TConditionType;
begin
  Result := ctLidSwitch;
end;

function TConditionLidSwitch._GetID: Integer;
begin
  Result := FID;
end;

procedure TConditionLidSwitch._SetID(const Value: Integer);
begin
  FID := Value;
end;

function TConditionLidSwitch._GetCfgStr: string;
begin
  Result := ClauseText(FClause);
end;

function TConditionLidSwitch.Parse(CfgStr: string): Boolean;
begin
  try
    if CompareText(CfgStr, CmdClose) = 0 then
    begin
      FClause := lscClose;
      Exit(True);
    end;

    if CompareText(CfgStr, CmdOpen) = 0 then
    begin
      FClause := lscOpen;
      Exit(True);
    end;

    Result := False;
  except
    Exit(False);
  end;
end;

function TConditionLidSwitch.Copy: ICondition;
begin
  Result := TConditionLidSwitch.Create;
  with Result as TConditionLidSwitch do
  begin
    FClause := Self.FClause;
    FID := Self.FID;
  end;
end;

function TConditionLidSwitch._GetDescription: string;
const
  ClauseIndex: array [TClause] of Integer = (1345, 1346);
begin
  Result := Format(TLang[1340], [TLang[ClauseIndex[FClause]]]);
end;

function TConditionLidSwitch.ClauseText(Clause: TClause): string;
begin
  case Clause of
    lscClose: Result := CmdClose;
    lscOpen:  Result := CmdOpen;
  end;
end;

{ TConditionDisplayState }

constructor TConditionDisplayState.Create(Clause: TClause);
begin
  inherited Create;

  FClause := Clause;
end;

function TConditionDisplayState.Check(const Previous, Current: TState): Boolean;
begin
  Result := False;
  case FClause of
    dscOff:
      Result := (Current.DisplayState = dsOff);
    dscOn:
      Result := (Current.DisplayState = dsOn);
    dscDimmed:
      Result := (Current.DisplayState = dsDimmed);
  end;
end;

function TConditionDisplayState._GetConditionType: TConditionType;
begin
  Result := ctDisplayState;
end;

function TConditionDisplayState._GetID: Integer;
begin
  Result := FID;
end;

procedure TConditionDisplayState._SetID(const Value: Integer);
begin
  FID := Value;
end;

function TConditionDisplayState._GetCfgStr: string;
begin
  Result := ClauseText(FClause);
end;

function TConditionDisplayState.Parse(CfgStr: string): Boolean;
begin
  try
    if CompareText(CfgStr, CmdOff) = 0 then
    begin
      FClause := dscOff;
      Exit(True);
    end;

    if CompareText(CfgStr, CmdOn) = 0 then
    begin
      FClause := dscOn;
      Exit(True);
    end;

    if CompareText(CfgStr, CmdDimmed) = 0 then
    begin
      FClause := dscDimmed;
      Exit(True);
    end;

    Result := False;
  except
    Exit(False);
  end;
end;

function TConditionDisplayState.Copy: ICondition;
begin
  Result := TConditionDisplayState.Create;
  with Result as TConditionDisplayState do
  begin
    FClause := Self.FClause;
    FID := Self.FID;
  end;
end;

function TConditionDisplayState._GetDescription: string;
const
  ClauseIndex: array [TClause] of Integer = (1365, 1366, 1367);
begin
  Result := Format(TLang[1360], [TLang[ClauseIndex[FClause]]]);
end;

function TConditionDisplayState.ClauseText(Clause: TClause): string;
begin
  case Clause of
    dscOff:     Result := CmdOff;
    dscOn:      Result := CmdOn;
    dscDimmed:  Result := CmdDimmed;
  end;
end;

{ TConditionScheme }

constructor TConditionScheme.Create(Scheme: IPowerScheme);
begin
  inherited Create;

  FClause := Scheme;
end;

function TConditionScheme.Check(const Previous, Current: TState): Boolean;
begin
  Result := Current.PowerScheme.Equals(FClause);
end;

function TConditionScheme._GetConditionType: TConditionType;
begin
  Result := ctScheme;
end;

function TConditionScheme._GetID: Integer;
begin
  Result := FID;
end;

procedure TConditionScheme._SetID(const Value: Integer);
begin
  FID := Value;
end;

function TConditionScheme._GetCfgStr: string;
begin
  Result := FClause.UniqueString;
end;

function TConditionScheme._GetDescription: string;
begin
  Result := Format(TLang[1380], [GetClauseName]);
end;

function TConditionScheme.GetClauseName: string;
begin
  if FClause.IsHidden then
    Result := FClause.UniqueString
  else
    Result := FClause.FriendlyName;
end;

function TConditionScheme.Copy: ICondition;
begin
  Result := TConditionScheme.Create(FClause);
  with Result as TConditionScheme do
    FID := Self.FID;
end;

function TConditionScheme.Parse(CfgStr: string): Boolean;
begin
  Result := True;
  try
    FClause := TBatteryMode.PowerSchemes.MakeSchemeFromUniqueString(CfgStr);
  except
    Result := False;
  end;
end;

{ TConditionNotScheme }

function TConditionNotScheme.Check(const Previous, Current: TState): Boolean;
begin
  Result := not inherited;
end;

function TConditionNotScheme._GetConditionType: TConditionType;
begin
  Result := ctNotScheme;
end;

function TConditionNotScheme._GetDescription: string;
begin
  Result := Format(TLang[1390], [GetClauseName]);
end;

function TConditionNotScheme.Copy: ICondition;
begin
  Result := TConditionNotScheme.Create(Clause);
  with Result as TConditionNotScheme do
    ID := Self.ID;
end;

end.
