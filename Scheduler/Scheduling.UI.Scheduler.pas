unit Scheduling.UI.Scheduler;

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.ShellAPI,
  System.SysUtils, System.Variants, System.Classes,
  System.Generics.Collections, System.Generics.Defaults,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Core.Language,
  Core.UI, Core.UI.Controls,
  Scheduling, Scheduling.Scheduler, Scheduling.UI.Editor,
  Versions.Helpers;

type
  TSchedulingWindow = class;
  TRulePreviewPanel = class;
  TRuleController   = class;

  TRulePreviewPanel = class(TPanel)
  private
    FRule: IRule;
    FLoading: Boolean;
    [weak] FController: TRuleController;
    FModifyCollector: IModifyCollector;

    FPanelDescription: TPanel;
    FPanelControl: TPanel;
    FPanelSort: TPanel;
    FLabelName: TLabel;
    FLabelInfo: TLabel;
    FButtonDelete: TButton;
    FButtonEdit: TButton;
    FButtonUp: TButton;
    FButtonDown: TButton;
    FCheckBoxEnabled: TCheckBox;
    FFirst: Boolean;
    FLast: Boolean;
    procedure SetFirst(const Value: Boolean);
    procedure SetLast(const Value: Boolean);

    procedure Load;

    procedure AdjustHeight;
    procedure AdjustSortButtonPosition;

    procedure CheckBoxEnabledClick(Sender: TObject);
    procedure ButtonEditClick(Sender: TObject);
    procedure ButtonDeleteClick(Sender: TObject);
    procedure ButtonUpClick(Sender: TObject);
    procedure ButtonDownClick(Sender: TObject);
    procedure ChildDblClick(Sender: TObject);
  protected
    procedure SetParent(AParent: TWinControl); override;
    procedure DblClick; override;
    procedure CreateWnd; override;
    procedure ChangeScale(M, D: Integer); override;
  public
    constructor Create(AOwner: TComponent; Rule: IRule; Controller: TRuleController; ModifyCollector: IModifyCollector); reintroduce;
    destructor Destroy; override;

    procedure Edit;
    property Rule: IRule read FRule;
    property First: Boolean read FFirst write SetFirst;
    property Last: Boolean read FLast write SetLast;
  end;

  TRulePreviewPanelComparer = class(TComparer<TRulePreviewPanel>)
  public
    function Compare(const Left, Right: TRulePreviewPanel): Integer; override;
  end;

  TRuleController = class(TScrollBox)
  private
    FRules: TRuleList;
    FRulePanels: TList<TRulePreviewPanel>;
    FModifyCollector: IModifyCollector;
  public
    constructor Create(AOwner: TComponent; Rules: TRuleList; ModifyCollector: IModifyCollector); reintroduce;
    destructor Destroy; override;

    function AddDefault: IRule;
    procedure Delete(Rule: IRule); overload;
    procedure Delete(RulePanel: TRulePreviewPanel); overload;
    procedure Sort;

    property Rules: TRuleList read FRules;
  end;

  TSchedulingWindow = class(TCompatibleForm)
    PanelConfig: TPanel;
    PanelControl: TPanel;
    PanelApply: TPanel;
    ButtonCancel: TButton;
    ButtonApply: TButton;
    CheckBoxEnabled: TCheckBox;
    ButtonAddRule: TButton;
    LinkHelp: TStaticText;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormDestroy(Sender: TObject);
    procedure ButtonCancelClick(Sender: TObject);
    procedure ButtonApplyClick(Sender: TObject);
    procedure CheckBoxEnabledClick(Sender: TObject);
    procedure ButtonAddRuleClick(Sender: TObject);
    procedure LinkHelpClick(Sender: TObject);
    procedure FormBeforeMonitorDpiChanged(Sender: TObject; OldDPI,
      NewDPI: Integer);
    procedure FormAfterMonitorDpiChanged(Sender: TObject; OldDPI,
      NewDPI: Integer);
  private const
    MinHeight = 240;
    MinWidth = 400;
  private
    FScheduler: TScheduler;

    FRuleController: TRuleController;
    FModifyCollector: IModifyCollector;
    FModification: Boolean;
    procedure Loadlocalization;
    procedure Apply;
    procedure ModifyCollectorModify(Sender: TObject; var Modify: Boolean);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  private
    class var FSchedulingWindowHandle: THandle;
    class constructor Create;
  public
    class procedure Configure(Scheduler: TScheduler);
  public
    constructor Create(Scheduler: TScheduler); reintroduce;
  end;

implementation

{$R *.dfm}

{ TSchedulingWindow }

class procedure TSchedulingWindow.Configure(Scheduler: TScheduler);
var
  SchedulingWindow: TSchedulingWindow;
begin
  if FSchedulingWindowHandle = 0 then
  begin
    SchedulingWindow := TSchedulingWindow.Create(Scheduler);
    SchedulingWindow.Show;
  end
  else
  begin
    ShowWindow(FSchedulingWindowHandle, SW_RESTORE);
    SetForegroundWindow(FSchedulingWindowHandle);
  end;
end;

constructor TSchedulingWindow.Create(Scheduler: TScheduler);
begin
  inherited Create(nil);
  FSchedulingWindowHandle := WindowHandle;
  FScheduler := Scheduler;

  FModification := False;

  FModifyCollector := TModifyCollector.Create;
  FModifyCollector.OnModify := ModifyCollectorModify;

  // Инициализация интерфейса
  CheckBoxEnabled.AdditionalSpace := True;
  PanelConfig.Shape := psBottomLine;
  PanelControl.Shape := psTopLine;
  ButtonAddRule.Padding.Left := 14;
  ButtonAddRule.Padding.Right := 14;
  ButtonAddRule.AutoSize := True;
  LinkHelp.LinkMode := True;

  // Инициализация контроллера правил
  FRuleController := TRuleController.Create(Self, FScheduler.Rules.Copy, FModifyCollector);
  FRuleController.Parent := Self;
  FRuleController.TabOrder := 1;

  // Загрузка конфигурации планировщика
  FModification := True;
  try
    CheckBoxEnabled.Checked := FScheduler.Enabled;
  finally
    FModification := False;
  end;

  // Загрузка локализации
  Loadlocalization;

  if IsWindows10OrGreater then Color := clWindow;
end;

procedure TSchedulingWindow.FormDestroy(Sender: TObject);
begin
  FRuleController.Free;
  FSchedulingWindowHandle := 0;
end;

procedure TSchedulingWindow.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.WndParent := 0;
  Params.ExStyle := Params.ExStyle or WS_EX_APPWINDOW;
end;

procedure TSchedulingWindow.Apply;
begin
  FScheduler.Load(FRuleController.Rules);
  FScheduler.Save;
  FScheduler.Enabled := CheckBoxEnabled.Checked;
  FModifyCollector.UnModify;
end;

procedure TSchedulingWindow.FormAfterMonitorDpiChanged(Sender: TObject; OldDPI,
  NewDPI: Integer);
begin
  Constraints.MinHeight := MulDiv(MinHeight, NewDPI, 96);
  Constraints.MinWidth := MulDiv(MinWidth, NewDPI, 96);
  EnableAlign;
end;

procedure TSchedulingWindow.FormBeforeMonitorDpiChanged(Sender: TObject; OldDPI,
  NewDPI: Integer);
begin
  DisableAlign;
  Constraints.MinHeight := 0;
  Constraints.MinWidth := 0;
end;

procedure TSchedulingWindow.FormClose(Sender: TObject;
  var Action: TCloseAction);
begin
  Action := caFree;

  if FModifyCollector.IsModify then
    case MessageBox(WindowHandle, LPCTSTR(TLang[1010]), LPCTSTR(TLang[1000]), MB_YESNOCANCEL or MB_ICONQUESTION) of
      IDYES: Apply;
      IDNO: Action := caFree;
      else Action := caNone;
    end;
end;

procedure TSchedulingWindow.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key =  Char(VK_ESCAPE) then Close;
end;

procedure TSchedulingWindow.CheckBoxEnabledClick(Sender: TObject);
begin
  if FModification then Exit;
  
  FModifyCollector.Modify;
end;

procedure TSchedulingWindow.ButtonAddRuleClick(Sender: TObject);
begin
  FRuleController.AddDefault;
end;

procedure TSchedulingWindow.ButtonApplyClick(Sender: TObject);
begin
  Apply;
  Close;
end;

procedure TSchedulingWindow.ButtonCancelClick(Sender: TObject);
begin
  FModifyCollector.UnModify;
  Close;
end;

procedure TSchedulingWindow.LinkHelpClick(Sender: TObject);
begin
  ShellExecute(Handle, 'open', LPTSTR(TLang[1006]), nil, nil, SW_RESTORE);
end;

procedure TSchedulingWindow.ModifyCollectorModify(Sender: TObject;
  var Modify: Boolean);
begin
  ButtonApply.Enabled := Modify;
end;

procedure TSchedulingWindow.Loadlocalization;
begin
  Caption := TLang[1000]; // Планировщик
  
  ButtonApply.Caption   := TLang[1001]; // Применить
  ButtonCancel.Caption  := TLang[1002]; // Отмена
  ButtonAddRule.Caption := TLang[1003]; // Добавить правило

  LinkHelp.Caption := TLang[1005]; // Справка по планировщику

  CheckBoxEnabled.Caption := TLang[1020]; // Включить планировщик
end;

class constructor TSchedulingWindow.Create;
begin
  FSchedulingWindowHandle := 0;
end;

{ TRulePreviewPanel }

constructor TRulePreviewPanel.Create(AOwner: TComponent; Rule: IRule;
  Controller: TRuleController; ModifyCollector: IModifyCollector);
begin
  inherited Create(AOwner);
  FRule := Rule;
  FController := Controller;
  FModifyCollector := ModifyCollector;
  FLoading := False;

  Align := alTop;
  BevelOuter := bvNone;
  Shape := psBottomLine;
  Padding.SetBounds(0, 1, 13, 1);

  FPanelSort := TPanel.Create(Self);
  with FPanelSort do
  begin
    Align := alLeft;
    AlignWithMargins := True;
    BevelOuter := bvNone;
    Shape := psRightLine;
    Padding.SetBounds(0, 1, 0, 0);
    Margins.SetBounds(0, 0, 0, 1);
    Width := 30;
    Parent := Self;
    OnDblClick := ChildDblClick;
  end;

  FPanelDescription := TPanel.Create(Self);
  with FPanelDescription do
  begin
    Align := alClient;
    AlignWithMargins := True;
    BevelOuter := bvNone;
    Padding.SetBounds(0, 7, 0, 6);
    Margins.SetBounds(16, 0, 0, 0);
    Parent := Self;
    OnDblClick := ChildDblClick;
  end;

  FPanelControl := TPanel.Create(Self);
  with FPanelControl do
  begin
    Align := alRight;
    AlignWithMargins := True;
    BevelOuter := bvNone;
    Width := 94;
    Margins.SetBounds(0, 0, 0, 6);
    Parent := Self;
    OnDblClick := ChildDblClick;
  end;

  FButtonUp := TButton.Create(FPanelSort);
  with FButtonUp do
  begin
    Align := alTop;
    AlignWithMargins := True;
    Caption := Char($25B2);
    Height := 21;
    if not IsWindowsVistaOrGreater then
    begin
      Font.Name := 'Arial';
      Font.Size := 9;
      Font.Quality := fqClearType;
    end;
    Hint := TLang[1060]; // Переместить выше
    ShowHint := True;
    Margins.SetBounds(4, 3, 5, 0);
    Parent := FPanelSort;
    OnClick := ButtonUpClick;
  end;

  FButtonDown := TButton.Create(FPanelSort);
  with FButtonDown do
  begin
    Align := alTop;
    AlignWithMargins := True;
    Caption := Char($25BC);;
    Height := 21;
    if not IsWindowsVistaOrGreater then
    begin
      Font.Name := 'Arial';
      Font.Size := 9;
      Font.Quality := fqClearType;
    end;
    Hint := TLang[1061]; // Переместить ниже
    ShowHint := True;
    Margins.SetBounds(4, 0, 5, 3);
    Parent := FPanelSort;
    OnClick := ButtonDownClick;
  end;

  FLabelName := TLabel.Create(FPanelDescription);
  with FLabelName do
  begin
    Align := alTop;
    AlignWithMargins := True;
    AutoSize := True;

    if not TLang.ShouldAvoidBoldFonts then Font.Style := [fsBold];

    Margins.SetBounds(0, 2, 0, 2);
    Tag := 1; // Font FIX
    Parent := FPanelDescription;
    OnDblClick := ChildDblClick;
  end;

  FLabelInfo := TLabel.Create(FPanelDescription);
  with FLabelInfo do
  begin
    Align := alTop;
    AlignWithMargins := True;
    EllipsisPosition := epWordEllipsis;
    Margins.SetBounds(0, 2, 0, 2);
    Parent := FPanelDescription;
    OnDblClick := ChildDblClick;
  end;

  FCheckBoxEnabled := TCheckBox.Create(FPanelControl);
  with FCheckBoxEnabled do
  begin
    Align := alTop;
    AlignWithMargins := True;
    AdditionalSpace := True;
    AutoSize := True;
    Caption := TLang[1040]; // Включить
    Margins.SetBounds(4, 9, 3, 8);
    Parent := FPanelControl;
    OnClick := CheckBoxEnabledClick;
  end;

  FButtonEdit := TButton.Create(FPanelControl);
  with FButtonEdit do
  begin
    Align := alTop;
    AlignWithMargins := True;
    Caption := TLang[1045]; // Изменить
    Parent := FPanelControl;
    OnClick := ButtonEditClick;
  end;

  FButtonDelete := TButton.Create(FPanelControl);
  with FButtonDelete do
  begin
    Align := alTop;
    AlignWithMargins := True;
    Caption := TLang[1046]; // Удалить
    Parent := FPanelControl;
    OnClick := ButtonDeleteClick;
  end;

  Load;
end;

destructor TRulePreviewPanel.Destroy;
begin
  FLabelName.Free;
  FLabelInfo.Free;

  inherited;
end;

procedure TRulePreviewPanel.ChangeScale(M, D: Integer);
begin
  inherited;

  if FLabelName.Tag = 1 then
  begin
    FLabelName.Tag := 0;
    FLabelName.Font.Height := Font.Height;
  end;

  AdjustHeight;
end;

procedure TRulePreviewPanel.CheckBoxEnabledClick(Sender: TObject);
begin
  if FLoading then Exit;

  FRule.Enabled := (Sender as TCheckBox).Checked;
  FModifyCollector.Modify;

  FLabelName.Enabled := FRule.Enabled;
  FLabelInfo.Enabled := FRule.Enabled;
end;

procedure TRulePreviewPanel.ButtonEditClick(Sender: TObject);
begin
  Edit;
end;

procedure TRulePreviewPanel.ButtonDeleteClick(Sender: TObject);
begin
  if FLoading then Exit;

  FController.Delete(Self);
end;

procedure TRulePreviewPanel.ButtonUpClick(Sender: TObject);
begin
  if FFirst then Exit;

  FRule.ID := FRule.ID - 1;
  FModifyCollector.Modify;
  FController.Sort;

  if Parent is TScrollBox then    
    (Parent as TScrollBox).ScrollInView(Self);
end;

procedure TRulePreviewPanel.ButtonDownClick(Sender: TObject);
begin
  if FLast then Exit;
  
  FRule.ID := FRule.ID + 1;
  FModifyCollector.Modify;
  FController.Sort;

  if Parent is TScrollBox then
    (Parent as TScrollBox).ScrollInView(Self);
end;

procedure TRulePreviewPanel.ChildDblClick(Sender: TObject);
begin
  DblClick;
end;

procedure TRulePreviewPanel.Load;
var
  Trigger: ITrigger;
  Condition: ICondition;
  ActionRule: IAction;
  Fmt: string;
  HeightAccumulator: Integer;
  Info: string;
  R: TRect;

  procedure AddInfo(Str: string);
  begin
    if Info.IsEmpty then
      Info := Str
    else
      Info := string.Join(sLineBreak, [Info, Str]);
  end;
begin
  FLoading := True;
  try
    Info := '';

    FPanelDescription.DisableAlign;
    try
      HeightAccumulator := FPanelDescription.Padding.Top;

      with FLabelName do
      begin
        Caption := FRule.Name;
        Enabled := FRule.Enabled;
        Visible := not FRule.Name.IsEmpty;
        Top := HeightAccumulator;

        Inc(HeightAccumulator, Margins.ExplicitHeight);
      end;

      with FCheckBoxEnabled do
      begin
        Checked := FRule.Enabled;
      end;

      Fmt := TLang[1030]; // Если %0:s
      for Trigger in FRule.Triggers do
      begin
        AddInfo(Format(Fmt, [Trigger.Description]));
        Fmt := TLang[1032];  // или %0:s
      end;

      if FRule.Triggers.Count > 0 then
      begin
        if FRule.Conditions.Count > 0 then
        begin
          Fmt := TLang[1036]; // при том, что %0:s
          for Condition in FRule.Conditions do
          begin
            AddInfo(Format(Fmt, [Condition.Description]));
            case FRule.ConditionOperation of
              oAnd: Fmt := TLang[1037]; // и %0:s
              oOr: Fmt := TLang[1038];  // или %0:s
            end;
          end;
        end;

        Fmt := TLang[1033]; // то %0:s
        for ActionRule in FRule.Actions do
        begin
          AddInfo(Format(Fmt, [ActionRule.Description]));
          Fmt := TLang[1034]; // и %0:s
        end;
      end
      else
        AddInfo(TLang[1035]);  // Условия отсутствуют

      with FLabelInfo do
      begin
        Caption := Info;
        Top := HeightAccumulator;
        Enabled := FRule.Enabled;

        if HandleAllocated then
        begin
          Canvas.Font := Font;
          Canvas.TextRect(R, Info, [tfCalcRect, tfNoPrefix]);
          Height := R.Height;
        end;
      end;
    finally
      FPanelDescription.EnableAlign;
      AdjustHeight;
    end;
  finally
    FLoading := False;
  end;
end;

procedure TRulePreviewPanel.CreateWnd;
var
  R: TRect;
  Info: string;
begin
  inherited;

  with FLabelInfo do
  begin
    Info := Caption;
    Canvas.Font := Font;
    Canvas.TextRect(R, Info, [tfCalcRect, tfNoPrefix]);
    Height := R.Height;
  end;
  AdjustHeight;
end;

procedure TRulePreviewPanel.Edit;
var
  EditWindow: TRuleEditorWindow;
  ParentForm: TCustomForm;
begin
  ParentForm := GetParentForm(Self);
  EditWindow := TRuleEditorWindow.Create(ParentForm, FRule, ParentForm.Handle);
  try
    case EditWindow.ShowModal of
      mrOk:
        begin
          FModifyCollector.Modify;
          Load;
        end;
    end;
  finally
    EditWindow.Free;
  end;
end;

procedure TRulePreviewPanel.AdjustHeight;
var
  HDesc, HConrol, I: Integer;
begin
  HDesc := FPanelDescription.Padding.Top + FPanelDescription.Padding.Bottom +
    FPanelDescription.Margins.Top + FPanelDescription.Margins.Bottom;
  for I := 0 to FPanelDescription.ControlCount - 1 do
    HDesc := HDesc + FPanelDescription.Controls[I].Margins.ExplicitHeight;

  HConrol := FPanelControl.Padding.Top + FPanelControl.Padding.Bottom +
    FPanelControl.Margins.Top + FPanelControl.Margins.Bottom;
  for I := 0 to FPanelControl.ControlCount - 1 do
    HConrol := HConrol + FPanelControl.Controls[I].Margins.ExplicitHeight;

  if HDesc > HConrol then
    Height := Padding.Top + Padding.Bottom + HDesc
  else
    Height := Padding.Top + Padding.Bottom + HConrol;
end;

procedure TRulePreviewPanel.AdjustSortButtonPosition;
var
  HeightAccumulator: Integer;
begin
  FPanelSort.DisableAlign;
  try
    HeightAccumulator := FPanelSort.Padding.Top;
    with FButtonUp do
    begin
      Top := HeightAccumulator;
      Inc(HeightAccumulator, Margins.ExplicitHeight);
    end;

    with FButtonDown do
      Top := HeightAccumulator;
  finally
    FPanelSort.EnableAlign;
  end;
end;

procedure TRulePreviewPanel.SetParent(AParent: TWinControl);
begin
  inherited;
  if not (csDestroying in ComponentState) then
    AdjustHeight;
end;

procedure TRulePreviewPanel.DblClick;
begin
  inherited;
  Edit;
end;

procedure TRulePreviewPanel.SetFirst(const Value: Boolean);
begin
  FFirst := Value;
  FButtonUp.Visible := not FFirst;

  FPanelSort.Visible := not (FFirst and FLast);

  AdjustSortButtonPosition;
end;

procedure TRulePreviewPanel.SetLast(const Value: Boolean);
begin
  FLast := Value;
  FButtonDown.Visible := not FLast;

  FPanelSort.Visible := not (FFirst and FLast);

  AdjustSortButtonPosition;
end;

{ TRuleController }

constructor TRuleController.Create(AOwner: TComponent; Rules: TRuleList;
  ModifyCollector: IModifyCollector);
var
  RulePanel: TRulePreviewPanel;
  Rule: IRule;
begin
  inherited Create(AOwner);
  Align := alClient;
  BorderStyle := bsNone;
  ParentBackground := True;
  VertScrollBar.Tracking := True;

  FRules := Rules;
  FModifyCollector := ModifyCollector;

  FRulePanels := TList<TRulePreviewPanel>.Create(TRulePreviewPanelComparer.Create);
  for Rule in FRules do
  begin
    RulePanel := TRulePreviewPanel.Create(Self, Rule, Self, FModifyCollector);
    RulePanel.Parent := Self;
    FRulePanels.Add(RulePanel);
  end;

  Sort;
end;

destructor TRuleController.Destroy;
var
  RulePanel: TObject;
begin
  for RulePanel in FRulePanels do RulePanel.Free;
  FRulePanels.Free;

  inherited;
end;

function TRuleController.AddDefault: IRule;
var
  Rule: IRule;
  RulePanel: TRulePreviewPanel;
begin
  Rule := TRule.Create;
  Rule.ID := FRules.NextID;
  Rule.Name := TLang[1050];
  Rule.Enabled := True;
  FRules.Add(Rule);
  FModifyCollector.Modify;

  RulePanel := TRulePreviewPanel.Create(Self, Rule, Self, FModifyCollector);
  RulePanel.Parent := Self;
  FRulePanels.Add(RulePanel);

  Sort;

  ScrollInView(RulePanel);
  Result := Rule;
end;

procedure TRuleController.Delete(Rule: IRule);
var
  RulePanel: TRulePreviewPanel;
begin
  FRules.Remove(Rule);
  FModifyCollector.Modify;
  for RulePanel in FRulePanels do
    if RulePanel.Rule = Rule then
    begin
      FRulePanels.Remove(RulePanel);
      RulePanel.Free;
      Break;
    end;
    
  Sort;
end;

procedure TRuleController.Delete(RulePanel: TRulePreviewPanel);
begin
  FRules.Remove(RulePanel.Rule);
  FModifyCollector.Modify;

  FRulePanels.Remove(RulePanel);
  RulePanel.Free;

  Sort;
end;

procedure TRuleController.Sort;
var
  I: Integer;
  HeightAccumulator: Integer;
begin
  FRules.Sort;
  FRulePanels.Sort;

  if FRulePanels.Count = 0 then Exit;

  if FRulePanels.Count = 1 then
    with FRulePanels.First do
    begin
      First := True;
      Last := True;  
    end
  else
    with FRulePanels do
    begin
      First.First := True;
      First.Last := False;

      Last.First := False;
      Last.Last := True;

      for I := 1 to Count - 2 do
      begin
        Items[I].First := False;
        Items[I].Last := False;
      end;
    end;

  DisableAlign;
  DisableAutoRange;
  try
    HeightAccumulator := Padding.Top;
    Dec(HeightAccumulator, VertScrollBar.ScrollPos);

    for I := 0 to FRulePanels.Count - 1 do
      with FRulePanels[I] do
      begin
        Top := HeightAccumulator;
        TabOrder := I;

        Inc(HeightAccumulator, Margins.ExplicitHeight);
      end;
  finally
    EnableAlign;
    EnableAutoRange;
  end;
end;

{ TRulePreviewPanelComparer }

function TRulePreviewPanelComparer.Compare(const Left,
  Right: TRulePreviewPanel): Integer;
begin
  if Left.Rule.ID > Right.Rule.ID then Exit(1);
  if Left.Rule.ID < Right.Rule.ID then Exit(-1);
  Exit(0);
end;

end.
