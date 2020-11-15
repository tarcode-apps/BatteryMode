unit Scheduling;

interface

uses
  Winapi.Windows,
  System.SysUtils, System.Classes,
  System.Generics.Collections, System.Generics.Defaults,
  Battery.Mode,
  Power, Power.Display,
  Power.WinApi.PowrProf;

type
  // Интерфейсы
  ITrigger = interface;
  ICondition = interface;
  IAction = interface;
  IRule = interface;
  IRuleConfigurator = interface;
  IStateConfigurator = interface;

  // Классы
  TRule = class;
  TTriggerComparrer = class;
  TActionComparrer = class;
  TRuleComparrer = class;
  TTriggerList = class;
  TConditionList = class;
  TActionList = class;
  TRuleList = class;

  TState = record
    Percentage: DWORD;
    PowerScheme: IPowerScheme;
    PowerCondition: TSystemPowerCondition;
    BatterySaver: Boolean;
    LidSwitchOpen: Boolean;
    DisplayState: TDisplayState;

    class function Current: TState; static;
  end;

  TTriggerType = (ttUnknown, ttPercent, ttAc, ttLidSwitch, ttDisplayState, ttScheme);
  TConditionType = (ctUnknown, ctPercent, ctAc, ctLidSwitch, ctDisplayState, ctScheme, ctNotScheme);
  TActionType = (atUnknown, atMessage, atScheme, atRun, atSound, atPower);

  ITrigger = interface
    function GetTriggerType: TTriggerType;
    function GetID: Integer;
    procedure SetID(const Value: Integer);
    function GetCfgStr: string;
    function GetDescription: string;

    function Check(const Previous, Current: TState): Boolean;
    function Parse(CfgStr: string): Boolean;
    function Copy: ITrigger;
    property TriggerType: TTriggerType read GetTriggerType;
    property ID: Integer read GetID write SetID;
    property CfgStr: string read GetCfgStr;
    property Description: string read GetDescription;
  end;

  ICondition = interface
    function _GetConditionType: TConditionType;
    function _GetID: Integer;
    procedure _SetID(const Value: Integer);
    function _GetCfgStr: string;
    function _GetDescription: string;

    function Check(const Previous, Current: TState): Boolean;
    function Parse(CfgStr: string): Boolean;
    function Copy: ICondition;
    property ConditionType: TConditionType read _GetConditionType;
    property ID: Integer read _GetID write _SetID;
    property CfgStr: string read _GetCfgStr;
    property Description: string read _GetDescription;
  end;

  IAction = interface
    function GetActionType: TActionType;
    function GetID: Integer;
    procedure SetID(const Value: Integer);
    function GetCfgStr: string;
    function GetDescription: string;

    function Execute: Boolean;
    function Parse(CfgStr: string): Boolean;
    function Copy: IAction;
    property ActionType: TActionType read GetActionType;
    property ID: Integer read GetID write SetID;
    property CfgStr: string read GetCfgStr;
    property Description: string read GetDescription;
  end;

  TConditionOperation = (oAnd, oOr);
  IRule = interface
    function _GetName: string;
    procedure _SetName(const Value: string);
    function _GetID: Integer;
    procedure _SetID(const Value: Integer);
    function _GetEnabled: Boolean;
    procedure _SetEnabled(const Value: Boolean);
    function _GetConditionOperation: TConditionOperation;
    procedure _SetConditionOperation(const Value: TConditionOperation);
    function _GetBraked: Boolean;
    procedure _SetBraked(const Value: Boolean);
    function _GetTriggers: TTriggerList;
    function _GetConditions: TConditionList;
    function _GetActions: TActionList;

    function Check(const Previous, Current: TState): Boolean;
    function Run: Boolean;
    function Copy: IRule;

    property Name: string read _GetName write _SetName;
    property ID: Integer read _GetID write _SetID;
    property Enabled: Boolean read _GetEnabled write _SetEnabled;
    property ConditionOperation: TConditionOperation read _GetConditionOperation write _SetConditionOperation;
    property Braked: Boolean read _GetBraked write _SetBraked;
    property Triggers: TTriggerList read _GetTriggers;
    property Conditions: TConditionList read _GetConditions;
    property Actions: TActionList read _GetActions;
  end;

  IRuleConfigurator = interface
    function Load: TRuleList;
    procedure Save(Rules: TRuleList);
  end;

  IStateConfigurator = interface
    function Load: TState;
    procedure Save(State: TState);
  end;

  TTriggerComparrer = class(TComparer<ITrigger>)
  public
    function Compare(const Left, Right: ITrigger): Integer; override;
  end;

  TConditionComparrer = class(TComparer<ICondition>)
  public
    function Compare(const Left, Right: ICondition): Integer; override;
  end;

  TActionComparrer = class(TComparer<IAction>)
  public
    function Compare(const Left, Right: IAction): Integer; override;
  end;

  TRuleComparrer = class(TComparer<IRule>)
  public
    function Compare(const Left, Right: IRule): Integer; override;
  end;
  
  TTriggerList = class(TList<ITrigger>)
  public
    constructor Create; reintroduce;
    procedure FixID;
    procedure Sort;  reintroduce;
    function Copy: TTriggerList;
  end;

  TConditionList = class(TList<ICondition>)
  public
    constructor Create; reintroduce;
    procedure FixID;
    procedure Sort;  reintroduce;
    function Copy: TConditionList;
  end;

  TActionList = class(TList<IAction>)
  public
    constructor Create; reintroduce;
    procedure FixID;
    procedure Sort;  reintroduce;
    function Copy: TActionList;
  end;

  TRuleList = class(TList<IRule>)
  public
    constructor Create; reintroduce;
    procedure FixID;
    function NextID: Integer;
    procedure Sort;  reintroduce;
    function Copy: TRuleList;
  end;

  TRule = class(TInterfacedObject, IRule)
  private
    FName: string;
    FID: Integer;
    FEnabled: Boolean;
    FConditionOperation: TConditionOperation;
    FBraked: Boolean;
    FTriggers: TTriggerList;
    FConditions: TConditionList;
    FActions: TActionList;
    function _GetName: string;
    procedure _SetName(const Value: string);
    function _GetID: Integer;
    procedure _SetID(const Value: Integer);
    function _GetEnabled: Boolean;
    procedure _SetEnabled(const Value: Boolean);
    function _GetConditionOperation: TConditionOperation;
    procedure _SetConditionOperation(const Value: TConditionOperation);
    function _GetBraked: Boolean;
    procedure _SetBraked(const Value: Boolean);
    function _GetTriggers: TTriggerList;
    function _GetConditions: TConditionList;
    function _GetActions: TActionList;
  public
    constructor Create; reintroduce;
    destructor Destroy; override;

    function Check(const Previous, Current: TState): Boolean;
    function Run: Boolean;
    function Copy: IRule;

    property Name: string read _GetName write _SetName;
    property ID: Integer read _GetID write _SetID;
    property Enabled: Boolean read _GetEnabled write _SetEnabled;
    property ConditionOperation: TConditionOperation read _GetConditionOperation write _SetConditionOperation;
    property Braked: Boolean read _GetBraked write _SetBraked;
    property Triggers: TTriggerList read _GetTriggers;
    property Conditions: TConditionList read _GetConditions;
    property Actions: TActionList read _GetActions;
  end;

implementation

{ TRule }

constructor TRule.Create;
begin
  inherited Create;

  FName := '';;
  FID := 0;
  FEnabled := False;
  FConditionOperation := oAnd;
  FBraked := False;
  FTriggers := TTriggerList.Create;
  FConditions := TConditionList.Create;
  FActions := TActionList.Create;
end;

destructor TRule.Destroy;
begin
  FTriggers.Free;
  FConditions.Free;
  FActions.Free;

  inherited Destroy;
end;

function TRule.Check(const Previous, Current: TState): Boolean;
  function CheckTriggers(const Previous, Current: TState): Boolean;
  var
    Trigger: ITrigger;
  begin
    if FTriggers.Count = 0 then Exit(False);

    Result := False;
    for Trigger in FTriggers do
    begin
      Result := Result or Trigger.Check(Previous, Current);
      if Result then Exit;
    end;
  end;

  function CheckConditionsAnd(const Previous, Current: TState): Boolean;
  var
    Condition: ICondition;
  begin
    if FConditions.Count = 0 then Exit(True);

    Result := True;
    for Condition in FConditions do
    begin
      Result := Result and Condition.Check(Previous, Current);
      if not Result then Exit;
    end;
  end;

  function CheckConditionsOr(const Previous, Current: TState): Boolean;
  var
    Condition: ICondition;
  begin
    if FConditions.Count = 0 then Exit(True);

    Result := False;
    for Condition in FConditions do
    begin
      Result := Result or Condition.Check(Previous, Current);
      if Result then Exit;
    end;
  end;
begin
  Result := CheckTriggers(Previous, Current);
  if not Result then Exit;

  case FConditionOperation of
    oAnd: Result := CheckConditionsAnd(Previous, Current);
    oOr:  Result := CheckConditionsOr(Previous, Current);
    else Result := False;
  end;
end;

function TRule.Run: Boolean;
var
  Action: IAction;
begin
  Result := True;
  for Action in FActions do
    Result := Result and Action.Execute;
end;

function TRule.Copy: IRule;
begin
  Result := TRule.Create;
  with Result as TRule do
  begin
    FName := Self.FName;
    FEnabled := Self.FEnabled;
    FConditionOperation := Self.FConditionOperation;
    FBraked := Self.FBraked;
    FID := Self.FID;
    FTriggers := Self.FTriggers.Copy;
    FConditions := Self.FConditions.Copy;
    FActions := Self.FActions.Copy;
  end;
end;

function TRule._GetName: string;
begin
  Result := FName;
end;

procedure TRule._SetName(const Value: string);
begin
  FName := Value;
end;

function TRule._GetID: Integer;
begin
  Result := FID;
end;

procedure TRule._SetID(const Value: Integer);
begin
  FID := Value;
end;

function TRule._GetEnabled: Boolean;
begin
  Result := FEnabled;
end;

procedure TRule._SetEnabled(const Value: Boolean);
begin
  FEnabled := Value;
end;

function TRule._GetConditionOperation: TConditionOperation;
begin
  Result := FConditionOperation;
end;

procedure TRule._SetConditionOperation(const Value: TConditionOperation);
begin
  FConditionOperation := Value;
end;

function TRule._GetBraked: Boolean;
begin
  Result := FBraked;
end;

procedure TRule._SetBraked(const Value: Boolean);
begin
  FBraked := Value;
end;

function TRule._GetTriggers: TTriggerList;
begin
  Result := FTriggers;
end;

function TRule._GetConditions: TConditionList;
begin
  Result := FConditions;
end;

function TRule._GetActions: TActionList;
begin
  Result := FActions;
end;

{ TTriggerComparrer }

function TTriggerComparrer.Compare(const Left, Right: ITrigger): Integer;
begin
  if Left.ID > Right.ID then Exit(1);
  if Left.ID < Right.ID then Exit(-1);
  Exit(0);
end;

{ TConditionComparrer }

function TConditionComparrer.Compare(const Left, Right: ICondition): Integer;
begin
  if Left.ID > Right.ID then Exit(1);
  if Left.ID < Right.ID then Exit(-1);
  Exit(0);
end;

{ TActionComparrer }

function TActionComparrer.Compare(const Left, Right: IAction): Integer;
begin
  if Left.ID > Right.ID then Exit(1);
  if Left.ID < Right.ID then Exit(-1);
  Exit(0);
end;

{ TRuleComparrer }

function TRuleComparrer.Compare(const Left, Right: IRule): Integer;
begin
  if Left.ID > Right.ID then Exit(1);
  if Left.ID < Right.ID then Exit(-1);
  Exit(0);
end;

{ TTriggerList }

constructor TTriggerList.Create;
begin
  inherited Create(TTriggerComparrer.Create);
end;  

procedure TTriggerList.FixID;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Self[I].ID := I;
end;

procedure TTriggerList.Sort;
begin
  inherited Sort;
  FixID;
end;

function TTriggerList.Copy: TTriggerList;
var
  Trigger: ITrigger;
begin
  Result := TTriggerList.Create;
  for Trigger in Self do
    Result.Add(Trigger.Copy);
end;

{ TConditionList }

constructor TConditionList.Create;
begin
  inherited Create(TConditionComparrer.Create);
end;

procedure TConditionList.FixID;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Self[I].ID := I;
end;

procedure TConditionList.Sort;
begin
  inherited Sort;
  FixID;
end;

function TConditionList.Copy: TConditionList;
var
  Condition: ICondition;
begin
  Result := TConditionList.Create;
  for Condition in Self do
    Result.Add(Condition.Copy);
end;

{ TActionList }

constructor TActionList.Create;
begin
  inherited Create(TActionComparrer.Create);
end;

procedure TActionList.FixID;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Self[I].ID := I;
end;

procedure TActionList.Sort;
begin
  inherited Sort;
  FixID;
end;

function TActionList.Copy: TActionList;
var
  Action: IAction;
begin
  Result := TActionList.Create;
  for Action in Self do
    Result.Add(Action.Copy);
end;

{ TRuleList }

constructor TRuleList.Create;
begin
  inherited Create(TRuleComparrer.Create);
end;

procedure TRuleList.FixID;
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
    Self[I].ID := I;
end;

function TRuleList.NextID: Integer;
var
  I: Integer;
begin
  if Count = 0 then Exit(0);

  Result := Items[0].ID;
  for I := 1 to Count - 1 do
    if Items[I].ID > Result then
      Result := Items[I].ID;
  Inc(Result);
end;

procedure TRuleList.Sort;
begin
  inherited Sort;
  FixID;
end;

function TRuleList.Copy: TRuleList;
var
  Rule: IRule;
begin
  Result := TRuleList.Create;
  for Rule in Self do
    Result.Add(Rule.Copy);
end;

{ TState }

class function TState.Current: TState;
begin
  Result.Percentage := TBatteryMode.State.Percentage;
  Result.PowerScheme := TBatteryMode.PowerSchemes.Active;
  Result.PowerCondition := TBatteryMode.State.PowerCondition;
  Result.BatterySaver := TBatteryMode.State.BatterySaver;
  Result.LidSwitchOpen := TBatteryMode.State.LidSwitchOpen;
  Result.DisplayState := dsOn;
end;

end.
