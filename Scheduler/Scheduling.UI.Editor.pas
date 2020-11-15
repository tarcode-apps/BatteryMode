unit Scheduling.UI.Editor;

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.ShellAPI,
  System.SysUtils, System.Variants, System.Classes,
  System.Generics.Collections, System.Generics.Defaults,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Core.Language,
  Core.UI, Core.UI.Controls,
  Scheduling, Scheduling.UI.Actions, Scheduling.UI.Triggers, Scheduling.UI.Conditions,
  Versions.Helpers;

type
  TRuleEditorWindow = class(TCompatibleForm)
    PanelConfig: TPanel;
    PanelControl: TPanel;
    PanelApply: TPanel;
    ButtonCancel: TButton;
    ButtonApply: TButton;
    PanelActions: TPanel;
    LabelName: TLabel;
    EditName: TEdit;
    CheckBoxBraked: TCheckBox;
    PanelTriggerInfo: TPanel;
    LabelIf: TLabel;
    ComboBoxOperation: TComboBox;
    PanelConditionInfo: TPanel;
    ButtonTriggerAdd: TButton;
    PanelActionInfo: TPanel;
    LabelActions: TLabel;
    LabelWhen: TLabel;
    ButtonConditionAdd: TButton;
    LinkHelp: TStaticText;
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure CheckBoxBrakedClick(Sender: TObject);
    procedure EditNameChange(Sender: TObject);
    procedure ButtonCancelClick(Sender: TObject);
    procedure ButtonApplyClick(Sender: TObject);
    procedure ComboBoxOperationSelect(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ButtonTriggerAddClick(Sender: TObject);
    procedure ButtonConditionAddClick(Sender: TObject);
    procedure LinkHelpClick(Sender: TObject);
    procedure FormAfterMonitorDpiChanged(Sender: TObject; OldDPI,
      NewDPI: Integer);
    procedure FormBeforeMonitorDpiChanged(Sender: TObject; OldDPI,
      NewDPI: Integer);
  private
    FParentHandle: THandle;
    FRule: IRule;
    FModifyCollector: IModifyCollector;
    FUpdateLocker: ILocker;

    FTriggersController: TTriggerController;
    FConditionsController: TConditionController;
    FActionPanels: TList<TActionBasePanel>;

    procedure Loadlocalization;
    procedure Apply;
    procedure ModifyCollectorModify(Sender: TObject; var Modify: Boolean);
    procedure ConditionsControllerPanelRawCountChange(Sender: TObject; Count: Integer);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  public
    constructor Create(AOwner: TComponent; Rule: IRule; ParentHandle: THandle); reintroduce;
  end;

implementation

{$R *.dfm}

constructor TRuleEditorWindow.Create(AOwner: TComponent; Rule: IRule; ParentHandle: THandle);
var
  Actions: TActionList;
  Action: IAction;

  function ExtractFirstActionFromType(Actions: TActionList; ActionType: TActionType): IAction;
  var
    Action: IAction;
  begin
    for Action in Actions do
      if Action.ActionType = ActionType then
      begin
        Actions.Remove(Action);
        Exit(Action);
      end;
    Result := nil;
  end;

  function NewPanel(Action: IAction; ActionType: TActionType): TActionBasePanel;
  begin
    case ActionType of
      atMessage: Result := TActionMessagePanel.Create(PanelActions, FModifyCollector, Action);
      atScheme: Result := TActionSchemePanel.Create(PanelActions, FModifyCollector, Action);
      atRun: Result := TActionRunPanel.Create(PanelActions, FModifyCollector, Action);
      atSound: Result := TActionSoundPanel.Create(PanelActions, FModifyCollector, Action);
      atPower: Result := TActionPowerPanel.Create(PanelActions, FModifyCollector, Action);
      else Result := TActionPreviewPanel.Create(PanelActions, FModifyCollector, Action);
    end;

    Result.Parent := PanelActions;
  end;
begin
  FParentHandle := ParentHandle;
  inherited Create(AOwner);
  FRule := Rule;

  FUpdateLocker := TLocker.Create;
  FModifyCollector := TModifyCollector.Create;
  FModifyCollector.OnModify := ModifyCollectorModify;
  FActionPanels := TList<TActionBasePanel>.Create;

  // Инициализация интерфейса
  CheckBoxBraked.AdditionalSpace := True;
  PanelConfig.Shape := psBottomLine;
  PanelControl.Shape := psTopLine;
  PanelConditionInfo.Shape := psTopLine;
  PanelActionInfo.Shape := psTopLine;
  ComboBoxOperation.AutoDropDownWidth := True;
  LinkHelp.LinkMode := True;

  // Загрузка локализации
  Loadlocalization;

  // Загрузка конфигурации
  FUpdateLocker.Lock;
  try
    EditName.Text := FRule.Name;
    CheckBoxBraked.Checked := FRule.Braked;

    case FRule.ConditionOperation of
      oAnd: ComboBoxOperation.ItemIndex := 0;
      else ComboBoxOperation.ItemIndex := 1;
    end;

    // Триггеры
    FTriggersController := TTriggerController.Create(Self, FRule.Triggers, FModifyCollector);
    FTriggersController.Parent := Self;
    FTriggersController.Top := PanelTriggerInfo.Top + PanelTriggerInfo.Margins.ExplicitHeight;
    FTriggersController.TabOrder := 2;

    // Условия
    FConditionsController := TConditionController.Create(Self, FRule.Conditions, FModifyCollector);
    FConditionsController.Parent := Self;
    FConditionsController.Top := PanelConditionInfo.Top + PanelConditionInfo.Margins.ExplicitHeight;
    FConditionsController.TabOrder := 4;
    FConditionsController.OnPanelRawCountChange := ConditionsControllerPanelRawCountChange;

    // Действия
    Actions := FRule.Actions.Copy;
    FActionPanels.Add(NewPanel(ExtractFirstActionFromType(Actions, atMessage), atMessage));
    FActionPanels.Add(NewPanel(ExtractFirstActionFromType(Actions, atScheme), atScheme));
    FActionPanels.Add(NewPanel(ExtractFirstActionFromType(Actions, atRun), atRun));
    FActionPanels.Add(NewPanel(ExtractFirstActionFromType(Actions, atSound), atSound));
    FActionPanels.Add(NewPanel(ExtractFirstActionFromType(Actions, atPower), atPower));

    for Action in Actions do
      FActionPanels.Add(NewPanel(Action, Action.ActionType));
  finally
    FUpdateLocker.Unlock;
  end;
  PanelActions.AutoSize := True;

  if IsWindows10OrGreater then Color := clWindow;
end;

procedure TRuleEditorWindow.FormDestroy(Sender: TObject);
var
  Panel: TObject;
begin
  FConditionsController.Free;
  FTriggersController.Free;
  for Panel in FActionPanels do Panel.Free;
  FActionPanels.Free;
end;

procedure TRuleEditorWindow.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.WndParent := FParentHandle;
end;

procedure TRuleEditorWindow.Apply;
var
  I: Integer;
  Action: IAction;
  NewTriggers: TTriggerList;
  NewConditions: TConditionList;
begin
  FRule.Name := EditName.Text;
  FRule.Braked := CheckBoxBraked.Checked;
  case ComboBoxOperation.ItemIndex of
    0: FRule.ConditionOperation := oAnd;
    else FRule.ConditionOperation := oOr;
  end;

  NewTriggers := FTriggersController.GetTriggers;
  try
    FRule.Triggers.Clear;
    FRule.Triggers.AddRange(NewTriggers.ToArray);
  finally
    NewTriggers.Free;
  end;

  NewConditions := FConditionsController.GetConditions;
  try
    FRule.Conditions.Clear;
    FRule.Conditions.AddRange(NewConditions.ToArray);
  finally
    NewTriggers.Free;
  end;

  FRule.Actions.Clear;
  for I := 0 to FActionPanels.Count - 1 do
  begin
    if not FActionPanels[I].Involved then Continue;

    Action := FActionPanels[I].RuleAction;
    if not Assigned(Action) then Continue;

    FRule.Actions.Add(FActionPanels[I].RuleAction);
    FRule.Actions.Last.ID := I;
  end;
  FRule.Actions.Sort;

  ModalResult := mrOk;

  FModifyCollector.UnModify;
end;

procedure TRuleEditorWindow.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caFree;

  if FModifyCollector.IsModify then
    case MessageBox(WindowHandle, LPCTSTR(TLang[1075]), LPCTSTR(TLang[1070]), MB_YESNOCANCEL or MB_ICONQUESTION) of
      IDYES: Apply;
      IDNO: ;
      else Action := caNone;
    end;
end;

procedure TRuleEditorWindow.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key =  Char(VK_ESCAPE) then Close;
end;

procedure TRuleEditorWindow.FormAfterMonitorDpiChanged(Sender: TObject; OldDPI,
  NewDPI: Integer);
begin
  EnableAlign;
  AutoSize := True;
end;

procedure TRuleEditorWindow.FormBeforeMonitorDpiChanged(Sender: TObject; OldDPI,
  NewDPI: Integer);
begin
  AutoSize := False;
  DisableAlign;
end;

procedure TRuleEditorWindow.LinkHelpClick(Sender: TObject);
begin
  ShellExecute(Handle, 'open', LPTSTR(TLang[1006]), nil, nil, SW_RESTORE);
end;

procedure TRuleEditorWindow.Loadlocalization;
begin
  Caption := TLang[1070]; // Свойства

  ButtonApply.Caption   := TLang[1071]; // Применить
  ButtonCancel.Caption  := TLang[1072]; // Отмена

  LinkHelp.Caption := TLang[1005]; // Справка по планировщику

  LabelName.Caption       := TLang[1080]; // Название
  CheckBoxBraked.Caption  := TLang[1081]; // Не применять остальные правила

  LabelIf.Caption         := TLang[1085]; // Если
  LabelWhen.Caption         := TLang[1088]; // При том, что:

  ComboBoxOperation.Items[0] := TLang[1086]; // выполняются все условия одновременно
  ComboBoxOperation.Items[1] := TLang[1087]; // выполняется хотя бы одно из условий

  ButtonTriggerAdd.Caption := TLang[1095]; // Добавить триггер
  ButtonConditionAdd.Caption := TLang[1097]; // Добавить условие

  LabelActions.Caption := TLang[1096]; // Выполнить действие
end;

procedure TRuleEditorWindow.ModifyCollectorModify(Sender: TObject;
  var Modify: Boolean);
begin
  ButtonApply.Enabled := Modify;
end;

procedure TRuleEditorWindow.ConditionsControllerPanelRawCountChange(
  Sender: TObject; Count: Integer);
begin
  ComboBoxOperation.Visible := Count > 1;
end;

procedure TRuleEditorWindow.ButtonTriggerAddClick(Sender: TObject);
begin
  FTriggersController.AddDefault;
end;

procedure TRuleEditorWindow.ButtonConditionAddClick(Sender: TObject);
begin
  FConditionsController.AddDefault;
end;

procedure TRuleEditorWindow.ButtonApplyClick(Sender: TObject);
begin
  Apply;
end;

procedure TRuleEditorWindow.ButtonCancelClick(Sender: TObject);
begin
  FModifyCollector.UnModify;
end;

procedure TRuleEditorWindow.CheckBoxBrakedClick(Sender: TObject);
begin
  if FUpdateLocker.IsLocked then Exit;

  FModifyCollector.Modify;
end;

procedure TRuleEditorWindow.ComboBoxOperationSelect(Sender: TObject);
begin
  if FUpdateLocker.IsLocked then Exit;

  FModifyCollector.Modify;
end;

procedure TRuleEditorWindow.EditNameChange(Sender: TObject);
begin
  if FUpdateLocker.IsLocked then Exit;

  FModifyCollector.Modify;
end;

end.
