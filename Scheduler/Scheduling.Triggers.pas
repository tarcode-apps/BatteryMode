unit Scheduling.Triggers;

interface

uses
  Winapi.Windows,
  System.SysUtils, System.Classes,
  Core.Language,
  Battery.Mode,
  Power.Display,
  Power,
  Power.WinApi.PowrProf,
  Scheduling;

type
  TTriggerPercentage = class(TInterfacedObject, ITrigger)
  public type
    TClause = (pcDropBelow, pcRiseAbove, pcChanged);
  strict private const
    CmdDropBelow  = 'DropBelow';
    CmdRiseAbove  = 'RiseAbove';
    CmdChanged     = 'Changed';
    PercentageDelim = ':';
  strict private
    FID: Integer;
    FClause: TClause;
    FPercentage: DWORD;

    function ClauseText(Clause: TClause): string;
  strict protected
    function GetTriggerType: TTriggerType;
    function GetID: Integer;
    procedure SetID(const Value: Integer);
    function GetCfgStr: string;
    function GetDescription: string;
  public
    constructor Create(Clause: TClause; Percentage: DWORD = 0); overload;

    function Check(const Previous, Current: TState): Boolean;
    function Parse(CfgStr: string): Boolean;
    function Copy: ITrigger;

    property TriggerType: TTriggerType read GetTriggerType;
    property ID: Integer read GetID write SetID;
    property CfgStr: string read GetCfgStr;
    property Description: string read GetDescription;

    property Clause: TClause read FClause;
    property Percentage: DWORD read FPercentage;
  end;

  TTriggerAc = class(TInterfacedObject, ITrigger)
  public type
    TClause = (accInject, accEject, accChanged);
  strict private const
    CmdInject       = 'Inject';
    CmdEject        = 'Eject';
    CmdChanged      = 'Changed';
  strict private
    FID: Integer;
    FClause: TClause;

    function ClauseText(Clause: TClause): string;
  strict protected
    function GetTriggerType: TTriggerType;
    function GetID: Integer;
    procedure SetID(const Value: Integer);
    function GetCfgStr: string;
    function GetDescription: string;
  public
    constructor Create(Clause: TClause); overload;

    function Check(const Previous, Current: TState): Boolean;
    function Parse(CfgStr: string): Boolean;
    function Copy: ITrigger;

    property TriggerType: TTriggerType read GetTriggerType;
    property ID: Integer read GetID write SetID;
    property CfgStr: string read GetCfgStr;
    property Description: string read GetDescription;

    property Clause: TClause read FClause;
  end;

  TTriggerLidSwitch = class(TInterfacedObject, ITrigger)
  public type
    TClause = (lscClosed, lscOpened);
  strict private const
    CmdClosed   = 'Closed';
    CmdOpened   = 'Opened';
  strict private
    FID: Integer;
    FClause: TClause;

    function ClauseText(Clause: TClause): string;
  strict protected
    function GetTriggerType: TTriggerType;
    function GetID: Integer;
    procedure SetID(const Value: Integer);
    function GetCfgStr: string;
    function GetDescription: string;
  public
    constructor Create(Clause: TClause); overload;

    function Check(const Previous, Current: TState): Boolean;
    function Parse(CfgStr: string): Boolean;
    function Copy: ITrigger;

    property TriggerType: TTriggerType read GetTriggerType;
    property ID: Integer read GetID write SetID;
    property CfgStr: string read GetCfgStr;
    property Description: string read GetDescription;

    property Clause: TClause read FClause;
  end;

  TTriggerDisplayState = class(TInterfacedObject, ITrigger)
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
    function GetTriggerType: TTriggerType;
    function GetID: Integer;
    procedure SetID(const Value: Integer);
    function GetCfgStr: string;
    function GetDescription: string;
  public
    constructor Create(Clause: TClause); overload;

    function Check(const Previous, Current: TState): Boolean;
    function Parse(CfgStr: string): Boolean;
    function Copy: ITrigger;

    property TriggerType: TTriggerType read GetTriggerType;
    property ID: Integer read GetID write SetID;
    property CfgStr: string read GetCfgStr;
    property Description: string read GetDescription;

    property Clause: TClause read FClause;
  end;

  TTriggerScheme = class(TInterfacedObject, ITrigger)
  strict private
    FID: Integer;
    FClause: IPowerScheme;
  strict protected
    function GetTriggerType: TTriggerType;
    function GetID: Integer;
    procedure SetID(const Value: Integer);
    function GetCfgStr: string;
    function GetDescription: string;
  public
    constructor Create(Scheme: IPowerScheme); overload;

    function Check(const Previous, Current: TState): Boolean;
    function Parse(CfgStr: string): Boolean;
    function Copy: ITrigger;

    property TriggerType: TTriggerType read GetTriggerType;
    property ID: Integer read GetID write SetID;
    property CfgStr: string read GetCfgStr;
    property Description: string read GetDescription;

    property Clause: IPowerScheme read FClause;
  end;

  TTriggerStartup = class(TInterfacedObject, ITrigger)
  strict private
    FID: Integer;
  strict protected
    function GetTriggerType: TTriggerType;
    function GetID: Integer;
    procedure SetID(const Value: Integer);
    function GetCfgStr: string;
    function GetDescription: string;
  public
    function Check(const Previous, Current: TState): Boolean;
    function Parse(CfgStr: string): Boolean;
    function Copy: ITrigger;

    property TriggerType: TTriggerType read GetTriggerType;
    property ID: Integer read GetID write SetID;
    property CfgStr: string read GetCfgStr;
    property Description: string read GetDescription;
  end;

  TTriggerSleep = class(TInterfacedObject, ITrigger)
  strict private
    FID: Integer;
  strict protected
    function GetTriggerType: TTriggerType;
    function GetID: Integer;
    procedure SetID(const Value: Integer);
    function GetCfgStr: string;
    function GetDescription: string;
  public
    function Check(const Previous, Current: TState): Boolean;
    function Parse(CfgStr: string): Boolean;
    function Copy: ITrigger;

    property TriggerType: TTriggerType read GetTriggerType;
    property ID: Integer read GetID write SetID;
    property CfgStr: string read GetCfgStr;
    property Description: string read GetDescription;
  end;

  TTriggerWakeup = class(TInterfacedObject, ITrigger)
  strict private
    FID: Integer;
  strict protected
    function GetTriggerType: TTriggerType;
    function GetID: Integer;
    procedure SetID(const Value: Integer);
    function GetCfgStr: string;
    function GetDescription: string;
  public
    function Check(const Previous, Current: TState): Boolean;
    function Parse(CfgStr: string): Boolean;
    function Copy: ITrigger;

    property TriggerType: TTriggerType read GetTriggerType;
    property ID: Integer read GetID write SetID;
    property CfgStr: string read GetCfgStr;
    property Description: string read GetDescription;
  end;

implementation

{ TTriggerPercentage }

constructor TTriggerPercentage.Create(Clause: TClause;
  Percentage: DWORD);
begin
  inherited Create;

  FClause := Clause;
  FPercentage := Percentage;
end;

function TTriggerPercentage.Check(const Previous, Current: TState): Boolean;
begin
  Result := False;
  case FClause of
    pcDropBelow:
      Result := (Current.Percentage < FPercentage) and (Previous.Percentage >= FPercentage);
    pcRiseAbove:
      Result := (Current.Percentage > FPercentage) and (Previous.Percentage <= FPercentage);
    pcChanged:
      Result := (Current.Percentage <> Previous.Percentage);
  end;
end;

function TTriggerPercentage.GetTriggerType: TTriggerType;
begin
  Result := ttPercent;
end;

function TTriggerPercentage.GetID: Integer;
begin
  Result := FID;
end;

procedure TTriggerPercentage.SetID(const Value: Integer);
begin
  FID := Value;
end;

function TTriggerPercentage.GetCfgStr: string;
begin
  Result := string.Join(PercentageDelim, [ClauseText(FClause), FPercentage])
end;

function TTriggerPercentage.Parse(CfgStr: string): Boolean;
var
  Parts: TArray<string>;
begin
  try
    Parts := CfgStr.Split([PercentageDelim]);
    if Length(Parts) < 2 then Exit(False);

    FPercentage := DWORD.Parse(Parts[1]);

    if CompareText(Parts[0], CmdDropBelow) = 0 then
    begin
      FClause := pcDropBelow;
      Exit(True);
    end;

    if CompareText(Parts[0], CmdRiseAbove) = 0 then
    begin
      FClause := pcRiseAbove;
      Exit(True);
    end;

    if CompareText(Parts[0], CmdChanged) = 0 then
    begin
      FClause := pcChanged;
      Exit(True);
    end;

    Result := False;
  except
    Exit(False);
  end;
end;

function TTriggerPercentage.Copy: ITrigger;
begin
  Result := TTriggerPercentage.Create;
  with Result as TTriggerPercentage do
  begin
    FClause := Self.FClause;
    FPercentage := Self.FPercentage;
    FID := Self.FID;
  end;
end;

function TTriggerPercentage.GetDescription: string;
const
  ClauseIndex: array [TClause] of Integer = (1200, 1200, 1201);
  ClauseTypeIndex: array [TClause] of Integer = (1205, 1206, 1207);
begin
  Result := Format(TLang[ClauseIndex[FClause]], [TLang[ClauseTypeIndex[FClause]], FPercentage]);
end;

function TTriggerPercentage.ClauseText(Clause: TClause): string;
begin
  case Clause of
    pcDropBelow: Result := CmdDropBelow;
    pcRiseAbove: Result := CmdRiseAbove;
    pcChanged: Result := CmdChanged;
  end;
end;

{ TTriggerAc }

constructor TTriggerAc.Create(Clause: TClause);
begin
  inherited Create;

  FClause := Clause;
end;

function TTriggerAc.Check(const Previous, Current: TState): Boolean;
begin
  Result := False;
  case FClause of
    accInject:
      Result := (Current.PowerCondition = PoAc) and (Previous.PowerCondition <> PoAc);
    accEject:
      Result := (Current.PowerCondition <> PoAc) and (Previous.PowerCondition = PoAc);
    accChanged:
      Result := (Current.PowerCondition <> Previous.PowerCondition);
  end;
end;

function TTriggerAc.GetTriggerType: TTriggerType;
begin
  Result := ttAc;
end;

function TTriggerAc.GetID: Integer;
begin
  Result := FID;
end;

procedure TTriggerAc.SetID(const Value: Integer);
begin
  FID := Value;
end;

function TTriggerAc.GetCfgStr: string;
begin
  Result := ClauseText(FClause);
end;

function TTriggerAc.Parse(CfgStr: string): Boolean;
begin
  try
    if CompareText(CfgStr, CmdInject) = 0 then
    begin
      FClause := accInject;
      Exit(True);
    end;

    if CompareText(CfgStr, CmdEject) = 0 then
    begin
      FClause := accEject;
      Exit(True);
    end;

    if CompareText(CfgStr, CmdChanged) = 0 then
    begin
      FClause := accChanged;
      Exit(True);
    end;

    Result := False;
  except
    Exit(False);
  end;
end;

function TTriggerAc.Copy: ITrigger;
begin
  Result := TTriggerAc.Create;
  with Result as TTriggerAc do
  begin
    FClause := Self.FClause;
    FID := Self.FID;
  end;
end;

function TTriggerAc.GetDescription: string;
const
  ClauseTypeIndex: array [TClause] of Integer = (1225, 1226, 1227);
begin
  Result := Format(TLang[1220], [TLang[ClauseTypeIndex[FClause]]]);
end;

function TTriggerAc.ClauseText(Clause: TClause): string;
begin
  case Clause of
    accInject: Result := CmdInject;
    accEject: Result := CmdEject;
    accChanged: Result := CmdChanged;
  end;
end;

{ TTriggerLidSwitch }

constructor TTriggerLidSwitch.Create(Clause: TClause);
begin
  inherited Create;

  FClause := Clause;
end;

function TTriggerLidSwitch.Check(const Previous, Current: TState): Boolean;
begin
  Result := False;
  case FClause of
    lscClosed:
      Result := not Current.LidSwitchOpen and Previous.LidSwitchOpen;
    lscOpened:
      Result := Current.LidSwitchOpen and not Previous.LidSwitchOpen;
  end;
end;

function TTriggerLidSwitch.GetTriggerType: TTriggerType;
begin
  Result := ttLidSwitch;
end;

function TTriggerLidSwitch.GetID: Integer;
begin
  Result := FID;
end;

procedure TTriggerLidSwitch.SetID(const Value: Integer);
begin
  FID := Value;
end;

function TTriggerLidSwitch.GetCfgStr: string;
begin
  Result := ClauseText(FClause);
end;

function TTriggerLidSwitch.Parse(CfgStr: string): Boolean;
begin
  try
    if CompareText(CfgStr, CmdClosed) = 0 then
    begin
      FClause := lscClosed;
      Exit(True);
    end;

    if CompareText(CfgStr, CmdOpened) = 0 then
    begin
      FClause := lscOpened;
      Exit(True);
    end;

    Result := False;
  except
    Exit(False);
  end;
end;

function TTriggerLidSwitch.Copy: ITrigger;
begin
  Result := TTriggerLidSwitch.Create;
  with Result as TTriggerLidSwitch do
  begin
    FClause := Self.FClause;
    FID := Self.FID;
  end;
end;

function TTriggerLidSwitch.GetDescription: string;
const
  ClauseTypeIndex: array [TClause] of Integer = (1245, 1246);
begin
  Result := Format(TLang[1240], [TLang[ClauseTypeIndex[FClause]]]);
end;

function TTriggerLidSwitch.ClauseText(Clause: TClause): string;
begin
  case Clause of
    lscClosed:  Result := CmdClosed;
    lscOpened:  Result := CmdOpened;
  end;
end;

{ TTriggerDisplayState }

constructor TTriggerDisplayState.Create(Clause: TClause);
begin
  inherited Create;

  FClause := Clause;
end;

function TTriggerDisplayState.Check(const Previous, Current: TState): Boolean;
begin
  Result := False;
  case FClause of
    dscOff:
      Result := (Current.DisplayState = dsOff) and (Previous.DisplayState <> dsOff);
    dscOn:
      Result := (Current.DisplayState = dsOn) and (Previous.DisplayState <> dsOn);
    dscDimmed:
      Result := (Current.DisplayState = dsDimmed) and (Previous.DisplayState <> dsDimmed);
  end;
end;

function TTriggerDisplayState.GetTriggerType: TTriggerType;
begin
  Result := ttDisplayState;
end;

function TTriggerDisplayState.GetID: Integer;
begin
  Result := FID;
end;

procedure TTriggerDisplayState.SetID(const Value: Integer);
begin
  FID := Value;
end;

function TTriggerDisplayState.GetCfgStr: string;
begin
  Result := ClauseText(FClause);
end;

function TTriggerDisplayState.Parse(CfgStr: string): Boolean;
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

function TTriggerDisplayState.Copy: ITrigger;
begin
  Result := TTriggerDisplayState.Create;
  with Result as TTriggerDisplayState do
  begin
    FClause := Self.FClause;
    FID := Self.FID;
  end;
end;

function TTriggerDisplayState.GetDescription: string;
const
  ClauseTypeIndex: array [TClause] of Integer = (1265, 1266, 1267);
begin
  Result := Format(TLang[1260], [TLang[ClauseTypeIndex[FClause]]]);
end;

function TTriggerDisplayState.ClauseText(Clause: TClause): string;
begin
  case Clause of
    dscOff:     Result := CmdOff;
    dscOn:      Result := CmdOn;
    dscDimmed:  Result := CmdDimmed;
  end;
end;

{ TTriggerScheme }

constructor TTriggerScheme.Create(Scheme: IPowerScheme);
begin
  inherited Create;

  FClause := Scheme;
end;

function TTriggerScheme.Check(const Previous, Current: TState): Boolean;
begin
  Result := Current.PowerScheme.Equals(FClause) and not Previous.PowerScheme.Equals(FClause);
end;

function TTriggerScheme.GetTriggerType: TTriggerType;
begin
  Result := ttScheme;
end;

function TTriggerScheme.GetID: Integer;
begin
  Result := FID;
end;

procedure TTriggerScheme.SetID(const Value: Integer);
begin
  FID := Value;
end;

function TTriggerScheme.GetCfgStr: string;
begin
  Result := FClause.UniqueString;
end;

function TTriggerScheme.GetDescription: string;
var
  SchemeName: string;
begin
  if FClause.IsHidden then
    SchemeName := FClause.UniqueString
  else
    SchemeName := FClause.FriendlyName;

  Result := Format(TLang[1280], [SchemeName]);
end;

function TTriggerScheme.Copy: ITrigger;
begin
  Result := TTriggerScheme.Create(FClause);
  with Result as TTriggerScheme do
    FID := Self.FID;
end;

function TTriggerScheme.Parse(CfgStr: string): Boolean;
begin
  Result := True;
  try
    FClause := TBatteryMode.PowerSchemes.MakeSchemeFromUniqueString(CfgStr);
  except
    Result := False;
  end;
end;

{ TTriggerStartup }

function TTriggerStartup.Check(const Previous, Current: TState): Boolean;
begin
  Result := not Previous.Started and Current.Started;
end;

function TTriggerStartup.GetID: Integer;
begin
  Result := FID;
end;

procedure TTriggerStartup.SetID(const Value: Integer);
begin
  FID := Value;
end;

function TTriggerStartup.GetTriggerType: TTriggerType;
begin
  Result := ttStartup;
end;

function TTriggerStartup.GetCfgStr: string;
begin
  Result := '';
end;

function TTriggerStartup.GetDescription: string;
begin
  Result := Format(TLang[1290], []);
end;

function TTriggerStartup.Parse(CfgStr: string): Boolean;
begin
  Result := True;
end;

function TTriggerStartup.Copy: ITrigger;
begin
  Result := TTriggerStartup.Create;
  with Result as TTriggerStartup do
    FID := Self.FID;
end;

{ TTriggerSleep }

function TTriggerSleep.Check(const Previous, Current: TState): Boolean;
begin
  Result := not Previous.Sleep and Current.Sleep;
end;

function TTriggerSleep.GetID: Integer;
begin
  Result := FID;
end;

procedure TTriggerSleep.SetID(const Value: Integer);
begin
  FID := Value;
end;

function TTriggerSleep.GetTriggerType: TTriggerType;
begin
  Result := ttSleep;
end;

function TTriggerSleep.GetCfgStr: string;
begin
  Result := '';
end;

function TTriggerSleep.GetDescription: string;
begin
  Result := Format(TLang[1250], []);
end;

function TTriggerSleep.Parse(CfgStr: string): Boolean;
begin
  Result := True;
end;

function TTriggerSleep.Copy: ITrigger;
begin
  Result := TTriggerSleep.Create;
  with Result as TTriggerSleep do
    FID := Self.FID;
end;

{ TTriggerWakeup }

function TTriggerWakeup.Check(const Previous, Current: TState): Boolean;
begin
  Result := Previous.Sleep and not Current.Sleep;
end;

function TTriggerWakeup.GetID: Integer;
begin
  Result := FID;
end;

procedure TTriggerWakeup.SetID(const Value: Integer);
begin
  FID := Value;
end;

function TTriggerWakeup.GetTriggerType: TTriggerType;
begin
  Result := ttWakeup;
end;

function TTriggerWakeup.GetCfgStr: string;
begin
  Result := '';
end;

function TTriggerWakeup.GetDescription: string;
begin
  Result := Format(TLang[1255], []);
end;

function TTriggerWakeup.Parse(CfgStr: string): Boolean;
begin
  Result := True;
end;

function TTriggerWakeup.Copy: ITrigger;
begin
  Result := TTriggerWakeup.Create;
  with Result as TTriggerWakeup do
    FID := Self.FID;
end;

end.
