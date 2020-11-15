unit Scheduling.StateConfigurator;

interface

uses
  Winapi.Windows,
  System.SysUtils, System.Classes, System.Win.Registry,
  Scheduling,
  Battery.Mode,
  Power, Power.Display,
  Power.WinApi.PowrProf;

type
  TStateConfigurator = class(TInterfacedObject, IStateConfigurator)
  private const
    REG_Scheduling = 'Scheduler';

    REG_StatePrefix = 'State';
    REG_StatePercentage = 'Percentage';
    REG_StatePowerScheme = 'Power Scheme';
    REG_StatePowerCondition = 'Power Condition';
    REG_StateBatterySaver = 'Battery Saver';
    REG_StateLidSwitchOpen = 'Lid Switch Open';
    REG_StateDisplay = 'Display State';
  private
    FRootRegKey: string;
    FRegKey: string;
  public
    constructor Create(RootRegKey: string);

    function Load: TState;
    procedure Save(State: TState);
  end;

implementation

{ TStateConfigurator }

constructor TStateConfigurator.Create(RootRegKey: string);
begin
  FRootRegKey := RootRegKey;
  FRegKey := string.Join(PathDelim, [FRootRegKey, REG_Scheduling, REG_StatePrefix]);
end;

function TStateConfigurator.Load: TState;
var
  Registry: TRegistry;
  CurrentState: TState;

  function ReadBoolDef(const Name: string; const Def: Boolean): Boolean;
  begin
    if Registry.ValueExists(Name) then
      Result := Registry.ReadBool(Name)
    else
      Result := Def;
  end;

  function ReadIntegerDef(const Name: string; const Def: Integer): Integer;
  begin
    if Registry.ValueExists(Name) then
      Result := Registry.ReadInteger(Name)
    else
      Result := Def;
  end;

  function ReadStringDef(const Name: string; const Def: string): string;
  begin
    if Registry.ValueExists(Name) then
      Result := Registry.ReadString(Name)
    else
      Result := Def;
  end;
begin
  CurrentState := TState.Current;

  Registry := TRegistry.Create;
  try
    Registry.RootKey := HKEY_CURRENT_USER;
    if not Registry.KeyExists(FRegKey) then Exit(CurrentState);
    if not Registry.OpenKeyReadOnly(FRegKey) then Exit(CurrentState);

    // Read config
    Result.Percentage := ReadIntegerDef(REG_StatePercentage, CurrentState.Percentage);
    try
      Result.PowerScheme :=
        TBatteryMode.PowerSchemes.MakeSchemeFromUniqueString(
          ReadStringDef(REG_StatePowerScheme, CurrentState.PowerScheme.UniqueString));
    except
      Result.PowerScheme := CurrentState.PowerScheme;
    end;
    Result.PowerCondition := TSystemPowerCondition(ReadIntegerDef(REG_StatePowerCondition, Integer(CurrentState.PowerCondition)));
    Result.BatterySaver := ReadBoolDef(REG_StateBatterySaver, CurrentState.BatterySaver);
    Result.LidSwitchOpen := ReadBoolDef(REG_StateLidSwitchOpen, CurrentState.LidSwitchOpen);
    Result.DisplayState := TDisplayState(ReadIntegerDef(REG_StateDisplay, Integer(CurrentState.DisplayState)));
    // end read config
  finally
    Registry.Free;
  end;
end;

procedure TStateConfigurator.Save(State: TState);
var
  Registry: TRegistry;
begin
  Registry := TRegistry.Create;
  try
    Registry.RootKey := HKEY_CURRENT_USER;
    Registry.DeleteKey(FRegKey);

    if Registry.OpenKey(FRegKey, True) then
    begin
      // Write config
      Registry.WriteInteger(REG_StatePercentage, State.Percentage);
      Registry.WriteString(REG_StatePowerScheme, State.PowerScheme.UniqueString);
      Registry.WriteInteger(REG_StatePowerCondition, Integer(State.PowerCondition));
      Registry.WriteBool(REG_StateBatterySaver, State.BatterySaver);
      Registry.WriteBool(REG_StateLidSwitchOpen, State.LidSwitchOpen);
      Registry.WriteInteger(REG_StateDisplay, Integer(State.DisplayState));
      // end write config
    end;
  finally
    Registry.Free;
  end;
end;

end.
