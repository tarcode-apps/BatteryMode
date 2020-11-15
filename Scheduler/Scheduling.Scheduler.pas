unit Scheduling.Scheduler;

interface

uses
  Winapi.Windows,
  System.SysUtils, System.Classes,
  Scheduling,
  Battery.Mode,
  Power, Power.Display,
  Power.WinApi.PowrProf;

type
  TScheduler = class
  private
    FStateConfigurator: IStateConfigurator;
    FConfigurator: IRuleConfigurator;
    FEnabled: Boolean;
    FRules: TRuleList;
    FPrevious: TState;
    FCurrent: TState;

    function Run: Boolean;
    procedure SetEnabled(const Value: Boolean);
  public
    constructor Create(StateConfigurator: IStateConfigurator; Configurator: IRuleConfigurator);
    destructor Destroy; override;

    procedure Load(Rules: TRuleList);
    procedure Save;
    procedure SaveState;

    procedure ChangePercentage(Value: DWORD);
    procedure ChangePowerScheme(Value: IPowerScheme);
    procedure ChangePowerCondition(Value: TSystemPowerCondition);
    procedure ChangeBatterySaver(Value: Boolean);
    procedure ChangeLidSwitchState(Value: Boolean);
    procedure ChangeDisplayState(Value: TDisplayState);

    property Enabled: Boolean read FEnabled write SetEnabled;
    property Rules: TRuleList read FRules;
  end;

implementation

{ TScheduler }

constructor TScheduler.Create(StateConfigurator: IStateConfigurator; Configurator: IRuleConfigurator);
begin
  FEnabled := False;

  FStateConfigurator := StateConfigurator;
  FPrevious := FStateConfigurator.Load;
  FCurrent := TState.Current;

  FRules := TRuleList.Create;
  FConfigurator := Configurator;
  if Assigned(FConfigurator) then
    Load(FConfigurator.Load);
end;

destructor TScheduler.Destroy;
begin
  FRules.Free;
end;

procedure TScheduler.Load(Rules: TRuleList);
var
  OldRule: TRuleList;
begin
  OldRule := FRules;
  FRules := Rules;
  OldRule.Free;
end;

procedure TScheduler.Save;
begin
  if Assigned(FConfigurator) then
    FConfigurator.Save(FRules);
end;

procedure TScheduler.SaveState;
begin
  FStateConfigurator.Save(FCurrent);
end;

procedure TScheduler.SetEnabled(const Value: Boolean);
begin
  if FEnabled = Value then Exit;

  FEnabled := Value;
  Run;
end;

function TScheduler.Run: Boolean;
var
  Rule: IRule;
  RunRes: Boolean;
begin
  if not FEnabled then Exit(False);
  if FRules.Count = 0 then Exit(False);

  SaveState;

  Result := True;
  for Rule in FRules do
    if Rule.Enabled and Rule.Check(FPrevious, FCurrent) then
    begin
      RunRes := Rule.Run;
      Result := Result and RunRes;
      if RunRes and Rule.Braked then
        Break;
    end;
end;

procedure TScheduler.ChangePercentage(Value: DWORD);
begin
  FPrevious := FCurrent;
  if FCurrent.Percentage = Value then Exit;

  FCurrent.Percentage := Value;
  Run;
end;

procedure TScheduler.ChangePowerScheme(Value: IPowerScheme);
begin
  FPrevious := FCurrent;
  if FCurrent.PowerScheme = Value then Exit;

  FCurrent.PowerScheme := Value;
  Run;
end;

procedure TScheduler.ChangePowerCondition(Value: TSystemPowerCondition);
begin
  FPrevious := FCurrent;
  if FCurrent.PowerCondition = Value then Exit;

  FCurrent.PowerCondition := Value;
  Run;
end;

procedure TScheduler.ChangeBatterySaver(Value: Boolean);
begin
  FPrevious := FCurrent;
  if FCurrent.BatterySaver = Value then Exit;

  FCurrent.BatterySaver := Value;
  Run;
end;

procedure TScheduler.ChangeLidSwitchState(Value: Boolean);
begin
  FPrevious := FCurrent;
  if FCurrent.LidSwitchOpen = Value then Exit;

  FCurrent.LidSwitchOpen := Value;
  Run;
end;

procedure TScheduler.ChangeDisplayState(Value: TDisplayState);
begin
  FPrevious := FCurrent;
  if FCurrent.DisplayState = Value then Exit;

  FCurrent.DisplayState := Value;
  Run;
end;

end.
