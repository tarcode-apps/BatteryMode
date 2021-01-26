unit Scheduling.UI.Conditions;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes,
  System.Generics.Collections, System.Generics.Defaults,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.ComCtrls,
  Core.Language,
  Core.UI, Core.UI.Controls,
  Battery.Mode,
  Power,
  Scheduling, Scheduling.Conditions,
  Versions.Helpers;

type
  TConditionControlPanel = class;
  TConditionController = class;
  TBaseConditionPanel = class;
  TPreviewConditionPanel = class;
  TPercentageConditionPanel = class;

  TConditionControlPanel = class(TPanel)
  strict private type
    TConditionInfo = record
      Name: string;
      ConditionType: TConditionType;
      constructor Create(ConditionType: TConditionType);
    end;
  strict private
    FCondition: ICondition;
    FModifyCollector: IModifyCollector;
    [weak] FController: TConditionController;
    FComboBoxCondition: TComboBox;
    FButtonDelete: TButton;
    FConditionPanel: TBaseConditionPanel;
    FRemovable: Boolean;

    FUpdateLocker: ILocker;

    FConditionsInfo: TList<TConditionInfo>;
    FIndex: Integer;

    function GetCondition: ICondition;
    procedure Load(ConditionType: TConditionType; Condition: ICondition = nil);
    procedure UpdateButton;

    procedure ButtonDeleteClick(Sender: TObject);
    procedure ComboBoxConditionSelect(Sender: TObject);
    function GetRemovable: Boolean;
    procedure SetRemovable(const Value: Boolean);
  protected
    procedure CreateWnd; override;
  public
    constructor Create(AOwner: TComponent; Condition: ICondition;
      Controller: TConditionController; ModifyCollector: IModifyCollector); reintroduce;
    destructor Destroy; override;

    property Removable: Boolean read GetRemovable write SetRemovable;
    property Condition: ICondition read GetCondition;
  end;

  TBaseConditionPanel = class(TPanel)
  protected
    FCondition: ICondition;
    FModifyCollector: IModifyCollector;
    FUpdateLocker: ILocker;

    function GetCondition: ICondition; virtual;
  public
    constructor Create(AOwner: TComponent; Condition: ICondition;
      ModifyCollector: IModifyCollector); reintroduce;

    property Condition: ICondition read GetCondition;
  end;

  TPreviewConditionPanel = class(TBaseConditionPanel)
  private
    FLabelDescription: TLabel;
  public
    constructor Create(AOwner: TComponent; Condition: ICondition;
      ModifyCollector: IModifyCollector); reintroduce;
    destructor Destroy; override;
  end;

  TPercentageConditionPanel = class(TBaseConditionPanel)
  strict private type
    TClauseInfo = record
      Name: string;
      Clause: TConditionPercentage.TClause;
      constructor Create(Clause: TConditionPercentage.TClause);
    end;
  strict private
    FComboBoxClause: TComboBox;
    FEditPercentage: TEdit;
    FUpDownPercentage: TUpDown;
    FLabelPercentage: TLabel;
    FClausesInfo: TList<TClauseInfo>;
    FIndex: Integer;
    procedure EditPercentageChange(Sender: TObject);
    procedure ComboBoxPercentageSelect(Sender: TObject);
  protected
    procedure CreateWnd; override;
    function GetCondition: ICondition; override;
  public
    constructor Create(AOwner: TComponent; Condition: ICondition;
      ModifyCollector: IModifyCollector); reintroduce;
    destructor Destroy; override;
  end;

  TAcConditionPanel = class(TBaseConditionPanel)
  strict private type
    TClauseInfo = record
      Name: string;
      Clause: TConditionAc.TClause;
      constructor Create(Clause: TConditionAc.TClause);
    end;
  strict private
    FComboBoxClause: TComboBox;
    FClausesInfo: TList<TClauseInfo>;
    FIndex: Integer;
    procedure ComboBoxPercentageSelect(Sender: TObject);
  protected
    procedure CreateWnd; override;
    function GetCondition: ICondition; override;
  public
    constructor Create(AOwner: TComponent; Condition: ICondition;
      ModifyCollector: IModifyCollector); reintroduce;
    destructor Destroy; override;
  end;

  TLidSwitchConditionPanel = class(TBaseConditionPanel)
  strict private type
    TClauseInfo = record
      Name: string;
      Clause: TConditionLidSwitch.TClause;
      constructor Create(Clause: TConditionLidSwitch.TClause);
    end;
  strict private
    FComboBoxClause: TComboBox;
    FClausesInfo: TList<TClauseInfo>;
    FIndex: Integer;
    procedure ComboBoxClauseSelect(Sender: TObject);
  protected
    procedure CreateWnd; override;
    function GetCondition: ICondition; override;
  public
    constructor Create(AOwner: TComponent; Condition: ICondition;
      ModifyCollector: IModifyCollector); reintroduce;
    destructor Destroy; override;
  end;

  TDisplayStateConditionPanel = class(TBaseConditionPanel)
  strict private type
    TClauseInfo = record
      Name: string;
      Clause: TConditionDisplayState.TClause;
      constructor Create(Clause: TConditionDisplayState.TClause);
    end;
  strict private
    FComboBoxClause: TComboBox;
    FClausesInfo: TList<TClauseInfo>;
    FIndex: Integer;
    procedure ComboBoxClauseSelect(Sender: TObject);
  protected
    procedure CreateWnd; override;
    function GetCondition: ICondition; override;
  public
    constructor Create(AOwner: TComponent; Condition: ICondition;
      ModifyCollector: IModifyCollector); reintroduce;
    destructor Destroy; override;
  end;

  TSchemeConditionPanel = class(TBaseConditionPanel)
  strict protected
    FComboBoxClause: TComboBox;
    FClausesInfo: TPowerSchemeList;
    FIndex: Integer;
    procedure ComboBoxClauseSelect(Sender: TObject);
  strict protected
    procedure CreateWnd; override;
    function GetCondition: ICondition; override;
  public
    constructor Create(AOwner: TComponent; Condition: ICondition;
      ModifyCollector: IModifyCollector); reintroduce;
    destructor Destroy; override;
  end;

  TNotSchemeConditionPanel = class(TSchemeConditionPanel)
  strict protected
    function GetCondition: ICondition; override;
  end;

  TConditionsCountChange = procedure(Sender: TObject; Count: Integer) of object;
  TConditionController = class(TPanel)
  private
    FConditionPanels: TList<TConditionControlPanel>;
    FModifyCollector: IModifyCollector;
    FOnPanelRawCountChange: TConditionsCountChange;
    function GetPanelRawCount: Integer;
    procedure SetOnPanelRawCountChange(const Value: TConditionsCountChange);
  public
    constructor Create(AOwner: TComponent; Conditions: TConditionList; ModifyCollector: IModifyCollector); reintroduce;
    destructor Destroy; override;

    procedure AddDefault;
    function GetConditions: TConditionList;
    procedure Delete(Condition: ICondition); overload;
    procedure Delete(ConditionPanel: TConditionControlPanel); overload;
    procedure Sort;

    property PanelRawCount: Integer read GetPanelRawCount;
    property OnPanelRawCountChange: TConditionsCountChange read FOnPanelRawCountChange write SetOnPanelRawCountChange;
  end;

implementation

{ TConditionControlPanel }

constructor TConditionControlPanel.Create(AOwner: TComponent; Condition: ICondition;
  Controller: TConditionController; ModifyCollector: IModifyCollector);
var
  I: Integer;
begin
  inherited Create(AOwner);
  FUpdateLocker := TLocker.Create;
  FRemovable := False;

  FCondition := Condition;
  FController := Controller;
  FModifyCollector := ModifyCollector;

  FConditionsInfo := TList<TConditionInfo>.Create;
  FConditionsInfo.Add(TConditionInfo.Create(ctPercent));
  FConditionsInfo.Add(TConditionInfo.Create(ctAc));
  if IsWindowsVistaOrGreater then
    FConditionsInfo.Add(TConditionInfo.Create(ctLidSwitch));
  if IsWindowsVistaOrGreater then
    FConditionsInfo.Add(TConditionInfo.Create(ctDisplayState));
  FConditionsInfo.Add(TConditionInfo.Create(ctScheme));
  FConditionsInfo.Add(TConditionInfo.Create(ctNotScheme));

  FIndex := -1;
  if Assigned(FCondition) then
  begin
    for I := 0 to FConditionsInfo.Count - 1 do
      if FCondition.ConditionType = FConditionsInfo[I].ConditionType then
      begin
        FIndex := I;
        Break;
      end;

    if FIndex = -1 then
    begin
      FConditionsInfo.Add(TConditionInfo.Create(FCondition.ConditionType));
      FIndex := FConditionsInfo.Count - 1;
    end;
  end;

  Align := alTop;
  BevelOuter := bvNone;
  Height := 37;
  Padding.SetBounds(16, 4, 16, 4);

  FComboBoxCondition := TComboBox.Create(Self);
  with FComboBoxCondition do
  begin
    Align := alLeft;
    AlignWithMargins := True;
    Style := csDropDownList;
    Parent := Self;
    Margins.SetBounds(0, 3, 0, 3);
    Tag := 1; // Заполнение данными на CreateWnd
    Width := 190;
    OnChange := ComboBoxConditionSelect;
  end;

  FButtonDelete := TButton.Create(Self);
  with FButtonDelete do
  begin
    Align := alRight;
    AlignWithMargins := True;
    Parent := Self;
    Margins.SetBounds(3, 2, 0, 2);
    Width := 64;
    OnClick := ButtonDeleteClick;
  end;

  UpdateButton;

  if Assigned(FCondition) then
    Load(FCondition.ConditionType, FCondition);
end;

procedure TConditionControlPanel.CreateWnd;
var
  ConditionInfo: TConditionInfo;
begin
  inherited;

  if FComboBoxCondition.Tag <> 1 then Exit;

  FUpdateLocker.Lock;
  try
    FComboBoxCondition.Tag := 0;
    for ConditionInfo in FConditionsInfo do
      FComboBoxCondition.Items.Add(ConditionInfo.Name);

    FComboBoxCondition.ItemIndex := FIndex;
  finally
    FUpdateLocker.Unlock;
  end;
end;

destructor TConditionControlPanel.Destroy;
begin
  FComboBoxCondition.Free;
  FButtonDelete.Free;

  FConditionsInfo.Free;

  inherited;
end;

procedure TConditionControlPanel.ButtonDeleteClick(Sender: TObject);
begin
  if FUpdateLocker.IsLocked then Exit;

  if FRemovable then
    FController.Delete(Self)
  else
  begin
    FUpdateLocker.Lock;
    try
      if Assigned(FConditionPanel) then
        FreeAndNil(FConditionPanel);

      FComboBoxCondition.ItemIndex := -1;

      FModifyCollector.Modify;

      UpdateButton;
    finally
      FUpdateLocker.Unlock;
    end;
  end;
end;

procedure TConditionControlPanel.ComboBoxConditionSelect(Sender: TObject);
begin
  FModifyCollector.Modify;
  Load(FConditionsInfo[(Sender as TComboBox).ItemIndex].ConditionType);
end;

function TConditionControlPanel.GetRemovable: Boolean;
begin
  Result := FRemovable;
end;

procedure TConditionControlPanel.SetRemovable(const Value: Boolean);
begin
  FRemovable := Value;
  UpdateButton;
end;

procedure TConditionControlPanel.UpdateButton;
begin
  if FRemovable then
  begin
    FButtonDelete.Caption := TLang[1090]; // Удалить
    FButtonDelete.Visible := True;
  end
  else if Assigned(FConditionPanel) then
  begin
    FButtonDelete.Caption := TLang[1092]; // Очистить
    FButtonDelete.Visible := True;
  end
  else
    FButtonDelete.Visible := False;
end;

function TConditionControlPanel.GetCondition: ICondition;
begin
  if Assigned(FConditionPanel) then
    Result := FConditionPanel.Condition
  else
    Result := nil;
end;

procedure TConditionControlPanel.Load(ConditionType: TConditionType; Condition: ICondition = nil);
begin
  FUpdateLocker.Lock;
  try
    if Assigned(FConditionPanel) then
      FreeAndNil(FConditionPanel);

    case ConditionType of
      ctPercent:      FConditionPanel := TPercentageConditionPanel.Create(Self, Condition, FModifyCollector);
      ctAc:           FConditionPanel := TAcConditionPanel.Create(Self, Condition, FModifyCollector);
      ctLidSwitch:    FConditionPanel := TLidSwitchConditionPanel.Create(Self, Condition, FModifyCollector);
      ctDisplayState: FConditionPanel := TDisplayStateConditionPanel.Create(Self, Condition, FModifyCollector);
      ctScheme:       FConditionPanel := TSchemeConditionPanel.Create(Self, Condition, FModifyCollector);
      ctNotScheme:    FConditionPanel := TNotSchemeConditionPanel.Create(Self, Condition, FModifyCollector);
      else FConditionPanel := TPreviewConditionPanel.Create(Self, Condition, FModifyCollector);
    end;
    FConditionPanel.Parent := Self;
    FConditionPanel.TabOrder := 1;

    UpdateButton;
  finally
    FUpdateLocker.Unlock;
  end;
end;

{ TConditionControlPanel.TConditionInfo }

constructor TConditionControlPanel.TConditionInfo.Create(ConditionType: TConditionType);
begin
  Self.ConditionType := ConditionType;
  case ConditionType of
    ctPercent:      Name := TLang[1301]; // Процент заряда батареи
    ctAc:           Name := TLang[1321]; // Источник электропитания
    ctLidSwitch:    Name := TLang[1341]; // Крышка ноутбука
    ctDisplayState: Name := TLang[1361]; // Экран
    ctScheme:       Name := TLang[1381]; // Схема электропитания
    ctNotScheme:    Name := TLang[1391]; // Схема электропитания не
    else Name := TLang[1091]; // неизвестное условие
  end;
end;

{ TConditionController }

constructor TConditionController.Create(AOwner: TComponent;
  Conditions: TConditionList; ModifyCollector: IModifyCollector);
var
  ConditionPanel: TConditionControlPanel;
  Condition: ICondition;
begin
  inherited Create(AOwner);

  Align := alTop;
  AutoSize := True;
  BevelOuter := bvNone;

  FModifyCollector := ModifyCollector;

  FConditionPanels := TList<TConditionControlPanel>.Create;

  for Condition in Conditions do
  begin
    ConditionPanel := TConditionControlPanel.Create(Self, Condition, Self, FModifyCollector);
    ConditionPanel.Parent := Self;
    FConditionPanels.Add(ConditionPanel);
  end;

  if Conditions.Count = 0 then
  begin
    ConditionPanel := TConditionControlPanel.Create(Self, nil, Self, FModifyCollector);
    ConditionPanel.Parent := Self;
    FConditionPanels.Add(ConditionPanel);
  end;

  Sort;
end;

destructor TConditionController.Destroy;
var
  ConditionPanel: TObject;
begin
  for ConditionPanel in FConditionPanels do ConditionPanel.Free;
  FConditionPanels.Free;

  inherited;
end;

procedure TConditionController.Delete(Condition: ICondition);
var
  ConditionPanel: TConditionControlPanel;
begin
  for ConditionPanel in FConditionPanels do
    if ConditionPanel.Condition = Condition then
    begin
      FModifyCollector.Modify;
      FConditionPanels.Remove(ConditionPanel);
      ConditionPanel.Free;
      Break;
    end;

  Sort;

  if Assigned(FOnPanelRawCountChange) then
    FOnPanelRawCountChange(Self, FConditionPanels.Count);
end;

procedure TConditionController.Delete(ConditionPanel: TConditionControlPanel);
begin
  FModifyCollector.Modify;

  FConditionPanels.Remove(ConditionPanel);
  ConditionPanel.Free;

  Sort;

  if Assigned(FOnPanelRawCountChange) then
    FOnPanelRawCountChange(Self, FConditionPanels.Count);
end;

procedure TConditionController.Sort;
var
  I: Integer;
  HeightAccumulator: Integer;
begin
  if FConditionPanels.Count = 0 then Exit;

  DisableAlign;
  try
    HeightAccumulator := Padding.Top;
    for I := 0 to FConditionPanels.Count - 1 do
      with FConditionPanels[I] do
      begin
        Top := HeightAccumulator;
        TabOrder := I;
        Removable := FConditionPanels.Count <> 1;

        Inc(HeightAccumulator, Margins.ExplicitHeight);
      end;
  finally
    EnableAlign;
  end;
end;

procedure TConditionController.AddDefault;
var
  ConditionPanel: TConditionControlPanel;
begin
  FModifyCollector.Modify;

  DisableAlign;
  try
    ConditionPanel := TConditionControlPanel.Create(Self, nil, Self, FModifyCollector);
    ConditionPanel.Parent := Self;
    FConditionPanels.Add(ConditionPanel);

    Sort;
  finally
    EnableAlign;
  end;

  if Assigned(FOnPanelRawCountChange) then
    FOnPanelRawCountChange(Self, FConditionPanels.Count);
end;

function TConditionController.GetPanelRawCount: Integer;
begin
  Result := FConditionPanels.Count;
end;

procedure TConditionController.SetOnPanelRawCountChange(
  const Value: TConditionsCountChange);
begin
  FOnPanelRawCountChange := Value;
  if Assigned(FOnPanelRawCountChange) then
    FOnPanelRawCountChange(Self, FConditionPanels.Count);
end;

function TConditionController.GetConditions: TConditionList;
var
  Condition: ICondition;
  I: Integer;
begin
  Result := TConditionList.Create;
  for I := 0 to FConditionPanels.Count - 1 do
  begin
    Condition := FConditionPanels[I].Condition;
    if Assigned(Condition) then
    begin
      Condition.ID := I;
      Result.Add(Condition);
    end;
  end;
end;

{ TBaseConditionPanel }

constructor TBaseConditionPanel.Create(AOwner: TComponent; Condition: ICondition;
  ModifyCollector: IModifyCollector);
begin
  inherited Create(AOwner);
  FCondition := Condition;
  FModifyCollector := ModifyCollector;
  FUpdateLocker := TLocker.Create;

  Align := alClient;
  BevelOuter := bvNone;
end;

function TBaseConditionPanel.GetCondition: ICondition;
begin
  Result := FCondition;
end;

{ TPreviewConditionPanel }

constructor TPreviewConditionPanel.Create(AOwner: TComponent; Condition: ICondition;
  ModifyCollector: IModifyCollector);
var
  ConditionDescription: string;
begin
  inherited Create(AOwner, Condition, ModifyCollector);

  if Assigned(FCondition) then
    ConditionDescription := FCondition.Description
  else
    ConditionDescription := '';

  FLabelDescription := TLabel.Create(Self);
  with FLabelDescription do
  begin
    Align := alClient;
    AlignWithMargins := True;
    Layout := tlCenter;
    EllipsisPosition := epEndEllipsis;
    Caption := ConditionDescription;
    Parent := Self;
    Margins.SetBounds(2, 2, 0, 4);
  end;
end;

destructor TPreviewConditionPanel.Destroy;
begin
  FLabelDescription.Free;
  inherited;
end;

{ TPercentageConditionPanel }

constructor TPercentageConditionPanel.Create(AOwner: TComponent;
  Condition: ICondition; ModifyCollector: IModifyCollector);
var
  WidthAccumulator: Integer;
  ConditionPercentage: Integer;
  PercentageVisible: Boolean;
  I: Integer;
begin
  inherited Create(AOwner, Condition, ModifyCollector);

  FClausesInfo := TList<TClauseInfo>.Create;
  FClausesInfo.Add(TClauseInfo.Create(pcLower));
  FClausesInfo.Add(TClauseInfo.Create(pcHigher));

  FIndex := -1;
  ConditionPercentage := 50;
  if FCondition is TConditionPercentage then
  begin
    ConditionPercentage := (FCondition as TConditionPercentage).Percentage;

    for I := 0 to FClausesInfo.Count - 1 do
      if (FCondition as TConditionPercentage).Clause = FClausesInfo[I].Clause then
      begin
        FIndex := I;
        Break;
      end;

    if FIndex = -1 then
    begin
      FClausesInfo.Add(TClauseInfo.Create((FCondition as TConditionPercentage).Clause));
      FIndex := FClausesInfo.Count - 1;
    end;
  end;

  PercentageVisible := FIndex >= 0;

  DisableAlign;
  FUpdateLocker.Lock;
  WidthAccumulator := Padding.Left;
  try
    FComboBoxClause := TComboBox.Create(Self);
    with FComboBoxClause do
    begin
      Align := alLeft;
      AlignWithMargins := True;
      Style := csDropDownList;
      Parent := Self;
      Margins.SetBounds(4, 3, 0, 3);
      Tag := 1; // Заполнение данными на CreateWnd
      Width := 135;
      Left := WidthAccumulator;
      OnChange := ComboBoxPercentageSelect;

      Inc(WidthAccumulator, Margins.ExplicitWidth);
    end;

    FEditPercentage := TEdit.Create(Self);
    with FEditPercentage do
    begin
      Align := alLeft;
      AlignWithMargins := True;
      Alignment := taCenter;
      MaxLength := 3;
      Parent := Self;
      NumbersOnly := True;
      Text := ConditionPercentage.ToString;
      Margins.SetBounds(4, 3, 0, 3);
      Width := 32;
      Left := WidthAccumulator;
      Tag := 1; // Пропуск первого OnChange из-за UpDown Associate
      Visible := PercentageVisible;
      OnChange := EditPercentageChange;

      Inc(WidthAccumulator, Margins.ExplicitWidth);
    end;

    FUpDownPercentage := TUpDown.Create(Self);
    with FUpDownPercentage do
    begin
      Align := alLeft;
      AlignWithMargins := True;
      Max := 100;
      Min := 0;
      Increment := 5;
      Parent := Self;
      Margins.SetBounds(0, 3, 0, 3);
      Left := WidthAccumulator;
      Position := ConditionPercentage;
      Associate := FEditPercentage;
      Visible := PercentageVisible;

      Inc(WidthAccumulator, Margins.ExplicitWidth);
    end;

    FLabelPercentage := TLabel.Create(Self);
    with FLabelPercentage do
    begin
      Align := alClient;
      AlignWithMargins := True;
      Layout := tlCenter;
      EllipsisPosition := epEndEllipsis;
      Caption := '%';
      Parent := Self;
      Left := WidthAccumulator;
      Margins.SetBounds(2, 2, 0, 4);
      Visible := PercentageVisible;
    end;
  finally
    FUpdateLocker.Unlock;
    EnableAlign;
  end;
end;

destructor TPercentageConditionPanel.Destroy;
begin
  FUpDownPercentage.Free;
  FEditPercentage.Free;
  FComboBoxClause.Free;
  FClausesInfo.Free;
  inherited;
end;

procedure TPercentageConditionPanel.CreateWnd;
var
  ClauseInfo: TClauseInfo;
begin
  inherited;

  if FComboBoxClause.Tag <> 1 then Exit;

  FUpdateLocker.Lock;
  try
    FComboBoxClause.Tag := 0;
    for ClauseInfo in FClausesInfo do
      FComboBoxClause.Items.Add(ClauseInfo.Name);

    FComboBoxClause.ItemIndex := FIndex;
  finally
    FUpdateLocker.Unlock;
  end;
end;

procedure TPercentageConditionPanel.EditPercentageChange(Sender: TObject);
begin
  if FUpdateLocker.IsLocked then Exit;

  if (Sender as TEdit).Tag = 1 then
  begin
    (Sender as TEdit).Tag := 0;
    Exit;
  end;

  FModifyCollector.Modify;
end;

procedure TPercentageConditionPanel.ComboBoxPercentageSelect(Sender: TObject);
var
  PercentageVisible: Boolean;
begin
  if FUpdateLocker.IsLocked then Exit;

  PercentageVisible := (Sender as TComboBox).ItemIndex >= 0;

  DisableAlign;
  try
    FEditPercentage.Visible := PercentageVisible;
    FUpDownPercentage.Visible := PercentageVisible;
    FLabelPercentage.Visible := PercentageVisible;
  finally
    EnableAlign;
  end;

  FModifyCollector.Modify;
end;

function TPercentageConditionPanel.GetCondition: ICondition;
var
  Percentage: Integer;
begin
  if FComboBoxClause.ItemIndex < 0 then Exit(nil);
  if not Integer.TryParse(FEditPercentage.Text, Percentage) then Exit(nil);

  if Percentage < 0 then Percentage := 0;
  if Percentage > 100 then Percentage := 100;

  Result := TConditionPercentage.Create(
    FClausesInfo[FComboBoxClause.ItemIndex].Clause, Percentage);
end;

{ TPercentageConditionPanel.TClauseInfo }

constructor TPercentageConditionPanel.TClauseInfo.Create(
  Clause: TConditionPercentage.TClause);
begin
  Self.Clause := Clause;
  case Clause of
    pcLower:  Name := TLang[1305]; // ниже
    pcHigher:  Name := TLang[1306]; // выше
  end;
end;

{ TAcConditionPanel }

constructor TAcConditionPanel.Create(AOwner: TComponent; Condition: ICondition;
  ModifyCollector: IModifyCollector);
var
  I: Integer;
begin
  inherited Create(AOwner, Condition, ModifyCollector);

  FClausesInfo := TList<TClauseInfo>.Create;
  FClausesInfo.Add(TClauseInfo.Create(accConnected));
  FClausesInfo.Add(TClauseInfo.Create(accDisconnected));

  FIndex := -1;
  if FCondition is TConditionAc then
  begin
    for I := 0 to FClausesInfo.Count - 1 do
      if (FCondition as TConditionAc).Clause = FClausesInfo[I].Clause then
      begin
        FIndex := I;
        Break;
      end;

    if FIndex = -1 then
    begin
      FClausesInfo.Add(TClauseInfo.Create((FCondition as TConditionAc).Clause));
      FIndex := FClausesInfo.Count - 1;
    end;
  end;

  DisableAlign;
  FUpdateLocker.Lock;
  try
    FComboBoxClause := TComboBox.Create(Self);
    with FComboBoxClause do
    begin
      Align := alLeft;
      AlignWithMargins := True;
      Style := csDropDownList;
      Parent := Self;
      Margins.SetBounds(4, 3, 0, 3);
      Tag := 1; // Заполнение данными на CreateWnd
      Width := 135;
      OnChange := ComboBoxPercentageSelect;
    end;
  finally
    FUpdateLocker.Unlock;
    EnableAlign;
  end;
end;

destructor TAcConditionPanel.Destroy;
begin
  FComboBoxClause.Free;
  FClausesInfo.Free;
  inherited;
end;

procedure TAcConditionPanel.CreateWnd;
var
  ClauseInfo: TClauseInfo;
begin
  inherited;

  if FComboBoxClause.Tag <> 1 then Exit;

  FUpdateLocker.Lock;
  try
    FComboBoxClause.Tag := 0;
    for ClauseInfo in FClausesInfo do
      FComboBoxClause.Items.Add(ClauseInfo.Name);

    FComboBoxClause.ItemIndex := FIndex;
  finally
    FUpdateLocker.Unlock;
  end;
end;

procedure TAcConditionPanel.ComboBoxPercentageSelect(Sender: TObject);
begin
  if FUpdateLocker.IsLocked then Exit;

  FModifyCollector.Modify;
end;

function TAcConditionPanel.GetCondition: ICondition;
begin
  if FComboBoxClause.ItemIndex < 0 then Exit(nil);

  Result := TConditionAc.Create(
    FClausesInfo[FComboBoxClause.ItemIndex].Clause);
end;

{ TAcConditionPanel.TClauseInfo }

constructor TAcConditionPanel.TClauseInfo.Create(Clause: TConditionAc.TClause);
begin
  Self.Clause := Clause;
  case Clause of
    accConnected:     Name := TLang[1325]; // подключен
    accDisconnected:  Name := TLang[1326]; // отключен
  end;
end;

{ TLidSwitchConditionPanel }

constructor TLidSwitchConditionPanel.Create(AOwner: TComponent; Condition: ICondition;
  ModifyCollector: IModifyCollector);
var
  I: Integer;
begin
  inherited Create(AOwner, Condition, ModifyCollector);

  FClausesInfo := TList<TClauseInfo>.Create;
  FClausesInfo.Add(TClauseInfo.Create(lscClose));
  FClausesInfo.Add(TClauseInfo.Create(lscOpen));

  FIndex := -1;
  if FCondition is TConditionLidSwitch then
  begin
    for I := 0 to FClausesInfo.Count - 1 do
      if (FCondition as TConditionLidSwitch).Clause = FClausesInfo[I].Clause then
      begin
        FIndex := I;
        Break;
      end;

    if FIndex = -1 then
    begin
      FClausesInfo.Add(TClauseInfo.Create((FCondition as TConditionLidSwitch).Clause));
      FIndex := FClausesInfo.Count - 1;
    end;
  end;

  DisableAlign;
  FUpdateLocker.Lock;
  try
    FComboBoxClause := TComboBox.Create(Self);
    with FComboBoxClause do
    begin
      Align := alLeft;
      AlignWithMargins := True;
      Style := csDropDownList;
      Parent := Self;
      Margins.SetBounds(4, 3, 0, 3);
      Tag := 1; // Заполнение данными на CreateWnd
      Width := 135;
      OnChange := ComboBoxClauseSelect;
    end;
  finally
    FUpdateLocker.Unlock;
    EnableAlign;
  end;
end;

destructor TLidSwitchConditionPanel.Destroy;
begin
  FComboBoxClause.Free;
  FClausesInfo.Free;
  inherited;
end;

procedure TLidSwitchConditionPanel.CreateWnd;
var
  ClauseInfo: TClauseInfo;
begin
  inherited;

  if FComboBoxClause.Tag <> 1 then Exit;

  FUpdateLocker.Lock;
  try
    FComboBoxClause.Tag := 0;
    for ClauseInfo in FClausesInfo do
      FComboBoxClause.Items.Add(ClauseInfo.Name);

    FComboBoxClause.ItemIndex := FIndex;
  finally
    FUpdateLocker.Unlock;
  end;
end;

procedure TLidSwitchConditionPanel.ComboBoxClauseSelect(Sender: TObject);
begin
  if FUpdateLocker.IsLocked then Exit;

  FModifyCollector.Modify;
end;

function TLidSwitchConditionPanel.GetCondition: ICondition;
begin
  if FComboBoxClause.ItemIndex < 0 then Exit(nil);

  Result := TConditionLidSwitch.Create(
    FClausesInfo[FComboBoxClause.ItemIndex].Clause);
end;

{ TLidSwitchConditionPanel.TClauseInfo }

constructor TLidSwitchConditionPanel.TClauseInfo.Create(Clause: TConditionLidSwitch.TClause);
begin
  Self.Clause := Clause;
  case Clause of
    lscClose: Name := TLang[1345]; // закрыта
    lscOpen:  Name := TLang[1346]; // открыта
  end;
end;

{ TDisplayStateConditionPanel }

constructor TDisplayStateConditionPanel.Create(AOwner: TComponent; Condition: ICondition;
  ModifyCollector: IModifyCollector);
var
  I: Integer;
begin
  inherited Create(AOwner, Condition, ModifyCollector);

  FClausesInfo := TList<TClauseInfo>.Create;
  FClausesInfo.Add(TClauseInfo.Create(dscOff));
  FClausesInfo.Add(TClauseInfo.Create(dscOn));
  if IsWindows8OrGreater then
    FClausesInfo.Add(TClauseInfo.Create(dscDimmed));

  FIndex := -1;
  if FCondition is TConditionDisplayState then
  begin
    for I := 0 to FClausesInfo.Count - 1 do
      if (FCondition as TConditionDisplayState).Clause = FClausesInfo[I].Clause then
      begin
        FIndex := I;
        Break;
      end;

    if FIndex = -1 then
    begin
      FClausesInfo.Add(TClauseInfo.Create((FCondition as TConditionDisplayState).Clause));
      FIndex := FClausesInfo.Count - 1;
    end;
  end;

  DisableAlign;
  FUpdateLocker.Lock;
  try
    FComboBoxClause := TComboBox.Create(Self);
    with FComboBoxClause do
    begin
      Align := alLeft;
      AlignWithMargins := True;
      Style := csDropDownList;
      Parent := Self;
      Margins.SetBounds(4, 3, 0, 3);
      Tag := 1; // Заполнение данными на CreateWnd
      Width := 135;
      OnChange := ComboBoxClauseSelect;
    end;
  finally
    FUpdateLocker.Unlock;
    EnableAlign;
  end;
end;

destructor TDisplayStateConditionPanel.Destroy;
begin
  FComboBoxClause.Free;
  FClausesInfo.Free;
  inherited;
end;

procedure TDisplayStateConditionPanel.CreateWnd;
var
  ClauseInfo: TClauseInfo;
begin
  inherited;

  if FComboBoxClause.Tag <> 1 then Exit;

  FUpdateLocker.Lock;
  try
    FComboBoxClause.Tag := 0;
    for ClauseInfo in FClausesInfo do
      FComboBoxClause.Items.Add(ClauseInfo.Name);

    FComboBoxClause.ItemIndex := FIndex;
  finally
    FUpdateLocker.Unlock;
  end;
end;

procedure TDisplayStateConditionPanel.ComboBoxClauseSelect(Sender: TObject);
begin
  if FUpdateLocker.IsLocked then Exit;

  FModifyCollector.Modify;
end;

function TDisplayStateConditionPanel.GetCondition: ICondition;
begin
  if FComboBoxClause.ItemIndex < 0 then Exit(nil);

  Result := TConditionDisplayState.Create(
    FClausesInfo[FComboBoxClause.ItemIndex].Clause);
end;

{ TDisplayStateConditionPanel.TClauseInfo }

constructor TDisplayStateConditionPanel.TClauseInfo.Create(Clause: TConditionDisplayState.TClause);
begin
  Self.Clause := Clause;
  case Clause of
    dscOff:     Name := TLang[1365]; // отключен
    dscOn:      Name := TLang[1366]; // включен
    dscDimmed:  Name := TLang[1367]; // в режиме уменьшеной яркости
  end;
end;

{ TSchemeConditionPanel }

constructor TSchemeConditionPanel.Create(AOwner: TComponent;
  Condition: ICondition; ModifyCollector: IModifyCollector);
var
  I: Integer;
begin
  inherited Create(AOwner, Condition, ModifyCollector);

  FClausesInfo := TBatteryMode.PowerSchemes.Schemes.Copy;

  FIndex := -1;
  if FCondition is TConditionScheme then
  begin
    for I := 0 to FClausesInfo.Count - 1 do
      if (FCondition as TConditionScheme).Clause.Equals(FClausesInfo[I]) then
      begin
        FIndex := I;
        Break;
      end;

    if FIndex = -1 then
    try
      FClausesInfo.Add(TBatteryMode.PowerSchemes.MakeSchemeFromUniqueString((FCondition as TConditionScheme).Clause.UniqueString));
      FClausesInfo.Sort;
      for I := 0 to FClausesInfo.Count - 1 do
        if (FCondition as TConditionScheme).Clause.Equals(FClausesInfo[I]) then
        begin
          FIndex := I;
          Break;
        end;
    except
    end;
  end;

  DisableAlign;
  FUpdateLocker.Lock;
  try
    FComboBoxClause := TComboBox.Create(Self);
    with FComboBoxClause do
    begin
      Align := alLeft;
      AlignWithMargins := True;
      Style := csDropDownList;
      Parent := Self;
      Margins.SetBounds(4, 3, 0, 3);
      Tag := 1; // Заполнение данными на CreateWnd
      Width := 225;
      OnChange := ComboBoxClauseSelect;
    end;
  finally
    FUpdateLocker.Unlock;
    EnableAlign;
  end;
end;

destructor TSchemeConditionPanel.Destroy;
begin
  FComboBoxClause.Free;
  FClausesInfo.Free;
  inherited;
end;

procedure TSchemeConditionPanel.CreateWnd;
var
  ClauseInfo: IPowerScheme;
begin
  inherited;

  if FComboBoxClause.Tag <> 1 then Exit;

  FUpdateLocker.Lock;
  try
    FComboBoxClause.Tag := 0;
    for ClauseInfo in FClausesInfo do
      if ClauseInfo.IsHidden then
        FComboBoxClause.Items.Add(ClauseInfo.UniqueString)
      else
        FComboBoxClause.Items.Add(ClauseInfo.FriendlyName);

    FComboBoxClause.ItemIndex := FIndex;
  finally
    FUpdateLocker.Unlock;
  end;
end;

procedure TSchemeConditionPanel.ComboBoxClauseSelect(Sender: TObject);
begin
  if FUpdateLocker.IsLocked then Exit;

  FModifyCollector.Modify;
end;

function TSchemeConditionPanel.GetCondition: ICondition;
begin
  if FComboBoxClause.ItemIndex < 0 then Exit(nil);

  Result := TConditionScheme.Create(
    FClausesInfo[FComboBoxClause.ItemIndex]);
end;

{ TNotSchemeConditionPanel }

function TNotSchemeConditionPanel.GetCondition: ICondition;
begin
  if FComboBoxClause.ItemIndex < 0 then Exit(nil);

  Result := TConditionNotScheme.Create(
    FClausesInfo[FComboBoxClause.ItemIndex]);
end;

end.
