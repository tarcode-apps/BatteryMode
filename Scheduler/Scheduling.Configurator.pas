unit Scheduling.Configurator;

interface

uses
  Winapi.Windows,
  System.SysUtils, System.Classes, System.Win.Registry,
  System.Generics.Collections, System.Generics.Defaults,
  Scheduling;

type
  TRuleConfigurator = class(TInterfacedObject, IRuleConfigurator)
  private const
    REG_Scheduling = 'Scheduler';
    REG_RulePrefix = 'Rule';
    REG_RuleName = 'Name';
    REG_RuleID = 'ID';
    REG_RuleEnabled = 'Enabled';
    REG_RuleBraked = 'Braked';
    REG_RuleOperation = 'Operation';
    REG_ActionPrefix = 'Action';
    REG_ActionType = 'Type';
    REG_ActionID = 'ID';
    REG_ActionSetting = 'Setting';
    REG_TriggerPrefix = 'Trigger';
    REG_TriggerType = 'Type';
    REG_TriggerID = 'ID';
    REG_TriggerSetting = 'Setting';
    REG_ConditionPrefix = 'Condition';
    REG_ConditionType = 'Type';
    REG_ConditionID = 'ID';
    REG_ConditionSetting = 'Setting';
  private
    FRootRegKey: string;
    FRegKey: string;
  public
    constructor Create(RootRegKey: string);

    function Load: TRuleList;
    procedure Save(Rules: TRuleList);
  end;

implementation

uses
  Scheduling.Actions, Scheduling.Triggers, Scheduling.Conditions;

{ TRuleConfigurator }

constructor TRuleConfigurator.Create(RootRegKey: string);
begin
  FRootRegKey := RootRegKey;
  FRegKey := string.Join(PathDelim, [FRootRegKey, REG_Scheduling]);
end;

function TRuleConfigurator.Load: TRuleList;
const
  RuleDefName = 'Rule';
  RuleDefEnabled = False;
  RuleDefBraked = False;
  RuleDefOperation = oAnd;
var
  Registry: TRegistry;
  Keys, TriggerCondActionKeys: TStringList;
  Key, TriggerCondAction: string;
  Rule: IRule;
  Action: IAction;
  Trigger: ITrigger;
  Condition: ICondition;

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

  function ReadOperationDef(const Name: string; const Def: TConditionOperation): TConditionOperation;
  var
    Operation: Integer;
  begin
    if Registry.ValueExists(Name) then
    begin
      Operation := Registry.ReadInteger(Name);
      if Operation in [Integer(Low(Result))..Integer(High(Result))] then
        Result := TConditionOperation(Operation)
      else
        Result := Def;
    end else
      Result := Def;
  end;

  function ReadAction: IAction;
  begin
    if not Registry.ValueExists(REG_ActionType) then Exit(nil);

    case TActionType(Registry.ReadInteger(REG_ActionType)) of
      atMessage:  Result := TActionMessage.Create;
      atScheme:   Result := TActionScheme.Create;
      atRun:      Result := TActionRun.Create;
      atSound:    Result := TActionSound.Create;
      atPower:    Result := TActionPower.Create;
      else Exit(nil);
    end;

    Result.ID := ReadIntegerDef(REG_ActionID, 0);

    if not Registry.ValueExists(REG_ActionSetting) then Exit(nil);
    if not Result.Parse(Registry.ReadString(REG_ActionSetting)) then Exit(nil);
  end;

  function ReadTrigger: ITrigger;
  begin
    if not Registry.ValueExists(REG_TriggerType) then Exit(nil);

    case TTriggerType(Registry.ReadInteger(REG_TriggerType)) of
      ttPercent:      Result := TTriggerPercentage.Create;
      ttAc:           Result := TTriggerAc.Create;
      ttLidSwitch:    Result := TTriggerLidSwitch.Create;
      ttDisplayState: Result := TTriggerDisplayState.Create;
      ttScheme:       Result := TTriggerScheme.Create;
      ttStartup:      Result := TTriggerStartup.Create;
      ttSleep:        Result := TTriggerSleep.Create;
      ttWakeup:       Result := TTriggerWakeup.Create;
      else Exit(nil);
    end;

    Result.ID := ReadIntegerDef(REG_TriggerID, 0);

    if not Registry.ValueExists(REG_TriggerSetting) then Exit(nil);
    if not Result.Parse(Registry.ReadString(REG_TriggerSetting)) then Exit(nil);
  end;

  function ReadCondition: ICondition;
  begin
    if not Registry.ValueExists(REG_ConditionType) then Exit(nil);

    case TConditionType(Registry.ReadInteger(REG_ConditionType)) of
      ctPercent:      Result := TConditionPercentage.Create;
      ctAc:           Result := TConditionAc.Create;
      ctLidSwitch:    Result := TConditionLidSwitch.Create;
      ctDisplayState: Result := TConditionDisplayState.Create;
      ctScheme:       Result := TConditionScheme.Create;
      ctNotScheme:    Result := TConditionNotScheme.Create;
      else Exit(nil);
    end;

    Result.ID := ReadIntegerDef(REG_ConditionID, 0);

    if not Registry.ValueExists(REG_ConditionSetting) then Exit(nil);
    if not Result.Parse(Registry.ReadString(REG_ConditionSetting)) then Exit(nil);
  end;
begin
  Result := TRuleList.Create;

  Registry := TRegistry.Create;
  try
    Registry.RootKey := HKEY_CURRENT_USER;
    if not Registry.KeyExists(FRegKey) then Exit;
    if not Registry.OpenKeyReadOnly(FRegKey) then Exit;

    // Read config
    Keys := TStringList.Create;
    try
      Registry.GetKeyNames(Keys);
      Registry.CloseKey;

      for Key in Keys do
        if Key.StartsWith(REG_RulePrefix, True) and
          Registry.OpenKeyReadOnly(string.Join(PathDelim, [FRegKey, Key])) then
        begin
          Rule := TRule.Create;
          Rule.Name := ReadStringDef(REG_RuleName, RuleDefName);
          Rule.ID := ReadIntegerDef(REG_RuleID, 0);
          Rule.Enabled := ReadBoolDef(REG_RuleEnabled, RuleDefEnabled);
          Rule.Braked := ReadBoolDef(REG_RuleBraked, RuleDefBraked);
          Rule.ConditionOperation := ReadOperationDef(REG_RuleOperation, RuleDefOperation);

          TriggerCondActionKeys := TStringList.Create;
          try
            Registry.GetKeyNames(TriggerCondActionKeys);
            Registry.CloseKey;

            for TriggerCondAction in TriggerCondActionKeys do
              if TriggerCondAction.StartsWith(REG_ActionPrefix, True) and
                Registry.OpenKeyReadOnly(string.Join(PathDelim, [FRegKey, Key, TriggerCondAction])) then
              begin
                // Action
                Action := ReadAction;
                if Action <> nil then
                  Rule.Actions.Add(Action);
                Registry.CloseKey;
              end
              else if TriggerCondAction.StartsWith(REG_TriggerPrefix, True) and
                Registry.OpenKeyReadOnly(string.Join(PathDelim, [FRegKey, Key, TriggerCondAction])) then
              begin
                // Trigger
                Trigger := ReadTrigger;
                if Trigger <> nil then
                  Rule.Triggers.Add(Trigger);
                Registry.CloseKey;
              end
              else if TriggerCondAction.StartsWith(REG_ConditionPrefix, True) and
                Registry.OpenKeyReadOnly(string.Join(PathDelim, [FRegKey, Key, TriggerCondAction])) then
              begin
                // Condition
                Condition := ReadCondition;
                if Condition <> nil then
                  Rule.Conditions.Add(Condition);
                Registry.CloseKey;
              end;

          finally
            TriggerCondActionKeys.Free;
          end;
          Rule.Triggers.Sort;
          Rule.Conditions.Sort;
          Rule.Actions.Sort;
          Result.Add(Rule);
        end;
    finally
      Keys.Free;
    end;
    // end read config
  finally
    Registry.Free;
  end;

  Result.Sort;
end;

procedure TRuleConfigurator.Save(Rules: TRuleList);
var
  Registry: TRegistry;
  Keys: TStringList;
  Key: string;
  Rule: IRule;
  Action: IAction;
  Trigger: ITrigger;
  Condition: ICondition;
begin
  Registry := TRegistry.Create;
  try
    Registry.RootKey := HKEY_CURRENT_USER;
    if not Registry.OpenKey(FRegKey, True) then Exit;

    // Write config
    Keys := TStringList.Create;
    try
      Registry.GetKeyNames(Keys);

      for Key in Keys do
        if Key.StartsWith(REG_RulePrefix, True) then
          Registry.DeleteKey(Key);
      Registry.CloseKey;

      for Rule in Rules do
      begin
        Key := string.Join(PathDelim, [FRegKey,
              string.Join(' ', [REG_RulePrefix, Rule.ID])]);
        if Registry.OpenKey(Key, True) then
        begin
          Registry.WriteString(REG_RuleName, Rule.Name);
          Registry.WriteInteger(REG_RuleID, Rule.ID);
          Registry.WriteBool(REG_RuleEnabled, Rule.Enabled);
          Registry.WriteBool(REG_RuleBraked, Rule.Braked);
          Registry.WriteInteger(REG_RuleOperation, Integer(Rule.ConditionOperation));
          Registry.CloseKey;

          // Action
          for Action in Rule.Actions do
          begin
            Key := string.Join(PathDelim, [FRegKey,
              string.Join(' ', [REG_RulePrefix, Rule.ID]),
              string.Join(' ', [REG_ActionPrefix, Action.ID])]);
            if Registry.OpenKey(Key, True) then
            begin
              Registry.WriteInteger(REG_ActionType, Integer(Action.ActionType));
              Registry.WriteInteger(REG_ActionID, Action.ID);
              Registry.WriteString(REG_ActionSetting, Action.CfgStr);
              Registry.CloseKey;
            end;
          end;

          // Trigger
          for Trigger in Rule.Triggers do
          begin
            Key := string.Join(PathDelim, [FRegKey,
              string.Join(' ', [REG_RulePrefix, Rule.ID]),
              string.Join(' ', [REG_TriggerPrefix, Trigger.ID])]);
            if Registry.OpenKey(Key, True) then
            begin
              Registry.WriteInteger(REG_TriggerType, Integer(Trigger.TriggerType));
              Registry.WriteInteger(REG_TriggerID, Trigger.ID);
              Registry.WriteString(REG_TriggerSetting, Trigger.CfgStr);
              Registry.CloseKey;
            end;
          end;

          // Condition
          for Condition in Rule.Conditions do
          begin
            Key := string.Join(PathDelim, [FRegKey,
              string.Join(' ', [REG_RulePrefix, Rule.ID]),
              string.Join(' ', [REG_ConditionPrefix, Condition.ID])]);
            if Registry.OpenKey(Key, True) then
            begin
              Registry.WriteInteger(REG_ConditionType, Integer(Condition.ConditionType));
              Registry.WriteInteger(REG_ConditionID, Condition.ID);
              Registry.WriteString(REG_ConditionSetting, Condition.CfgStr);
              Registry.CloseKey;
            end;
          end;
        end;
      end;
    finally
      Keys.Free;
    end;
    // end write config
  finally
    Registry.Free;
  end;
end;

end.
