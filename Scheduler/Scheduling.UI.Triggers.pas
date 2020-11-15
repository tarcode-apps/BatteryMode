unit Scheduling.UI.Triggers;

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
  Scheduling, Scheduling.Triggers,
  Versions.Helpers;

type
  TTriggerControlPanel = class;
  TTriggerController = class;
  TBaseTriggerPanel = class;

  TTriggerControlPanel = class(TPanel)
  strict private type
    TTiggerInfo = record
      Name: string;
      TriggerType: TTriggerType;
      constructor Create(TriggerType: TTriggerType);
    end;
  strict private
    FTrigger: ITrigger;
    FModifyCollector: IModifyCollector;
    [weak] FController: TTriggerController;
    FComboBoxTrigger: TComboBox;
    FButtonDelete: TButton;
    FTriggerPanel: TBaseTriggerPanel;
    
    FUpdateLocker: ILocker;

    FTriggersInfo: TList<TTiggerInfo>;
    FIndex: Integer;

    function GetTrigger: ITrigger;
    procedure Load(TriggerType: TTriggerType; Trigger: ITrigger = nil);
    
    procedure ButtonDeleteClick(Sender: TObject);
    procedure ComboBoxTriggerSelect(Sender: TObject);
    function GetRemovable: Boolean;
    procedure SetRemovable(const Value: Boolean);
  protected
    procedure CreateWnd; override;
  public
    constructor Create(AOwner: TComponent; Trigger: ITrigger;
      Controller: TTriggerController; ModifyCollector: IModifyCollector); reintroduce;
    destructor Destroy; override;

    property Removable: Boolean read GetRemovable write SetRemovable;
    property Trigger: ITrigger read GetTrigger;
  end;

  TBaseTriggerPanel = class(TPanel)
  protected
    FTrigger: ITrigger;
    FModifyCollector: IModifyCollector;
    FUpdateLocker: ILocker;

    function GetTrigger: ITrigger; virtual;
  public
    constructor Create(AOwner: TComponent; Trigger: ITrigger;
      ModifyCollector: IModifyCollector); reintroduce;

    property Trigger: ITrigger read GetTrigger;
  end;

  TPreviewTriggerPanel = class(TBaseTriggerPanel)
  private
    FLabelDescription: TLabel;
  public
    constructor Create(AOwner: TComponent; Trigger: ITrigger;
      ModifyCollector: IModifyCollector); reintroduce;
    destructor Destroy; override;
  end;

  TPercentageTriggerPanel = class(TBaseTriggerPanel)
  strict private type
    TConditionInfo = record
      Name: string;
      Clause: TTriggerPercentage.TClause;
      constructor Create(Clause: TTriggerPercentage.TClause);
    end;
  strict private
    FComboBoxCondition: TComboBox;
    FEditPercentage: TEdit;
    FUpDownPercentage: TUpDown;
    FLabelPercentage: TLabel;
    FConditionsInfo: TList<TConditionInfo>;
    FIndex: Integer;
    procedure EditPercentageChange(Sender: TObject);
    procedure ComboBoxPercentageSelect(Sender: TObject);
  protected                          
    procedure CreateWnd; override;
    function GetTrigger: ITrigger; override;
  public
    constructor Create(AOwner: TComponent; Trigger: ITrigger;
      ModifyCollector: IModifyCollector); reintroduce;
    destructor Destroy; override;
  end;

  TAcTriggerPanel = class(TBaseTriggerPanel)
  strict private type
    TConditionInfo = record
      Name: string;
      Clause: TTriggerAc.TClause;
      constructor Create(Clause: TTriggerAc.TClause);
    end;
  strict private
    FComboBoxCondition: TComboBox;
    FConditionsInfo: TList<TConditionInfo>;
    FIndex: Integer;
    procedure ComboBoxPercentageSelect(Sender: TObject);
  protected
    procedure CreateWnd; override;
    function GetTrigger: ITrigger; override;
  public
    constructor Create(AOwner: TComponent; Trigger: ITrigger;
      ModifyCollector: IModifyCollector); reintroduce;
    destructor Destroy; override;
  end;

  TLidSwitchTriggerPanel = class(TBaseTriggerPanel)
  strict private type
    TConditionInfo = record
      Name: string;
      Clause: TTriggerLidSwitch.TClause;
      constructor Create(Clause: TTriggerLidSwitch.TClause);
    end;
  strict private
    FComboBoxCondition: TComboBox;
    FConditionsInfo: TList<TConditionInfo>;
    FIndex: Integer;
    procedure ComboBoxConditionSelect(Sender: TObject);
  protected
    procedure CreateWnd; override;
    function GetTrigger: ITrigger; override;
  public
    constructor Create(AOwner: TComponent; Trigger: ITrigger;
      ModifyCollector: IModifyCollector); reintroduce;
    destructor Destroy; override;
  end;

  TDisplayStateTriggerPanel = class(TBaseTriggerPanel)
  strict private type
    TConditionInfo = record
      Name: string;
      Clause: TTriggerDisplayState.TClause;
      constructor Create(Clause: TTriggerDisplayState.TClause);
    end;
  strict private
    FComboBoxCondition: TComboBox;
    FConditionsInfo: TList<TConditionInfo>;
    FIndex: Integer;
    procedure ComboBoxConditionSelect(Sender: TObject);
  protected
    procedure CreateWnd; override;
    function GetTrigger: ITrigger; override;
  public
    constructor Create(AOwner: TComponent; Trigger: ITrigger;
      ModifyCollector: IModifyCollector); reintroduce;
    destructor Destroy; override;
  end;

  TSchemeTriggerPanel = class(TBaseTriggerPanel)
  strict private
    FComboBoxCondition: TComboBox;
    FConditionsInfo: TPowerSchemeList;
    FIndex: Integer;
    procedure ComboBoxConditionSelect(Sender: TObject);
  protected
    procedure CreateWnd; override;
    function GetTrigger: ITrigger; override;
  public
    constructor Create(AOwner: TComponent; Trigger: ITrigger;
      ModifyCollector: IModifyCollector); reintroduce;
    destructor Destroy; override;
  end;

  TTriggersCountChange = procedure(Sender: TObject; Count: Integer) of object;
  TTriggerController = class(TPanel)
  private
    FTriggerPanels: TList<TTriggerControlPanel>;
    FModifyCollector: IModifyCollector;
    FOnPanelRawCountChange: TTriggersCountChange;
    function GetPanelRawCount: Integer;
    procedure SetOnPanelRawCountChange(const Value: TTriggersCountChange);
  public
    constructor Create(AOwner: TComponent; Triggers: TTriggerList; ModifyCollector: IModifyCollector); reintroduce;
    destructor Destroy; override;

    procedure AddDefault;
    function GetTriggers: TTriggerList;
    procedure Delete(Trigger: ITrigger); overload;
    procedure Delete(TriggerPanel: TTriggerControlPanel); overload;
    procedure Sort;

    property PanelRawCount: Integer read GetPanelRawCount;
    property OnPanelRawCountChange: TTriggersCountChange read FOnPanelRawCountChange write SetOnPanelRawCountChange;
  end;

implementation

{ TTriggerControlPanel }

constructor TTriggerControlPanel.Create(AOwner: TComponent; Trigger: ITrigger;
  Controller: TTriggerController; ModifyCollector: IModifyCollector);
var
  I: Integer;
begin
  inherited Create(AOwner);
  FUpdateLocker := TLocker.Create;

  FTrigger := Trigger;
  FController := Controller;
  FModifyCollector := ModifyCollector;

  FTriggersInfo := TList<TTiggerInfo>.Create;
  FTriggersInfo.Add(TTiggerInfo.Create(ttPercent));
  FTriggersInfo.Add(TTiggerInfo.Create(ttAc));
  if IsWindowsVistaOrGreater then
    FTriggersInfo.Add(TTiggerInfo.Create(ttLidSwitch));
  if IsWindowsVistaOrGreater then
    FTriggersInfo.Add(TTiggerInfo.Create(ttDisplayState));
  FTriggersInfo.Add(TTiggerInfo.Create(ttScheme));

  FIndex := -1;
  if Assigned(FTrigger) then
  begin
    for I := 0 to FTriggersInfo.Count - 1 do
      if FTrigger.TriggerType = FTriggersInfo[I].TriggerType then
      begin
        FIndex := I;
        Break;
      end;

    if FIndex = -1 then
    begin
      FTriggersInfo.Add(TTiggerInfo.Create(FTrigger.TriggerType));
      FIndex := FTriggersInfo.Count - 1;
    end;
  end;

  Align := alTop;
  BevelOuter := bvNone;
  Height := 37;
  Padding.SetBounds(16, 4, 16, 4);

  FComboBoxTrigger := TComboBox.Create(Self);
  with FComboBoxTrigger do
  begin
    Align := alLeft;
    AlignWithMargins := True;
    Style := csDropDownList;
    Parent := Self;
    Margins.SetBounds(0, 3, 0, 3);
    Tag := 1; // Заполнение данными на CreateWnd
    Width := 175;
    OnChange := ComboBoxTriggerSelect;
  end;

  FButtonDelete := TButton.Create(Self);
  with FButtonDelete do
  begin
    Align := alRight;
    AlignWithMargins := True;
    Caption := TLang[1090]; // Удалить
    Parent := Self;
    Margins.SetBounds(3, 2, 0, 2);
    Width := 64;
    OnClick := ButtonDeleteClick;
  end;

  if Assigned(FTrigger) then
    Load(FTrigger.TriggerType, FTrigger);
end;

procedure TTriggerControlPanel.CreateWnd;
var
  TriggerInfo: TTiggerInfo;
begin
  inherited;

  if FComboBoxTrigger.Tag <> 1 then Exit;

  FUpdateLocker.Lock;
  try
    FComboBoxTrigger.Tag := 0;
    for TriggerInfo in FTriggersInfo do
      FComboBoxTrigger.Items.Add(TriggerInfo.Name);

    FComboBoxTrigger.ItemIndex := FIndex;
  finally
    FUpdateLocker.Unlock;
  end;
end;

destructor TTriggerControlPanel.Destroy;
begin
  FComboBoxTrigger.Free;
  FButtonDelete.Free;

  FTriggersInfo.Free;

  inherited;
end;

procedure TTriggerControlPanel.ButtonDeleteClick(Sender: TObject);
begin
  if FUpdateLocker.IsLocked then Exit;

  FController.Delete(Self);
end;

procedure TTriggerControlPanel.ComboBoxTriggerSelect(Sender: TObject);
begin
  FModifyCollector.Modify;
  Load(FTriggersInfo[(Sender as TComboBox).ItemIndex].TriggerType);
end;

function TTriggerControlPanel.GetRemovable: Boolean;
begin
  Result := FButtonDelete.Visible;
end; 

procedure TTriggerControlPanel.SetRemovable(const Value: Boolean);
begin
  FButtonDelete.Visible := Value;
end;

function TTriggerControlPanel.GetTrigger: ITrigger;
begin
  if Assigned(FTriggerPanel) then
    Result := FTriggerPanel.Trigger
  else
    Result := nil;
end;

procedure TTriggerControlPanel.Load(TriggerType: TTriggerType; Trigger: ITrigger = nil);
begin
  FUpdateLocker.Lock;
  try
    if Assigned(FTriggerPanel) then
      FreeAndNil(FTriggerPanel);

    case TriggerType of
      ttPercent:      FTriggerPanel := TPercentageTriggerPanel.Create(Self, Trigger, FModifyCollector);
      ttAc:           FTriggerPanel := TAcTriggerPanel.Create(Self, Trigger, FModifyCollector);
      ttLidSwitch:    FTriggerPanel := TLidSwitchTriggerPanel.Create(Self, Trigger, FModifyCollector);
      ttDisplayState: FTriggerPanel := TDisplayStateTriggerPanel.Create(Self, Trigger, FModifyCollector);
      ttScheme:       FTriggerPanel := TSchemeTriggerPanel.Create(Self, Trigger, FModifyCollector);
      else FTriggerPanel := TPreviewTriggerPanel.Create(Self, Trigger, FModifyCollector);
    end;
    FTriggerPanel.Parent := Self;
    FTriggerPanel.TabOrder := 1;
  finally
    FUpdateLocker.Unlock;
  end;
end;

{ TTriggerControlPanel.TTiggerInfo }

constructor TTriggerControlPanel.TTiggerInfo.Create(TriggerType: TTriggerType);
begin
  Self.TriggerType := TriggerType;
  case TriggerType of
    ttPercent:      Name := TLang[1202]; // Процент заряда батареи
    ttAc:           Name := TLang[1221]; // Источник электропитания
    ttLidSwitch:    Name := TLang[1241]; // Крышка ноутбука
    ttDisplayState: Name := TLang[1261]; // Экран
    ttScheme:       Name := TLang[1281]; // Схема электропитания
    else Name := TLang[1091]; // неизвестное условие
  end;
end;

{ TTriggerController }

constructor TTriggerController.Create(AOwner: TComponent;
  Triggers: TTriggerList; ModifyCollector: IModifyCollector);
var
  TriggerPanel: TTriggerControlPanel;
  Trigger: ITrigger;
begin
  inherited Create(AOwner);

  Align := alTop;
  AutoSize := True;
  BevelOuter := bvNone;

  FModifyCollector := ModifyCollector;

  FTriggerPanels := TList<TTriggerControlPanel>.Create;

  for Trigger in Triggers do
  begin
    TriggerPanel := TTriggerControlPanel.Create(Self, Trigger, Self, FModifyCollector);
    TriggerPanel.Parent := Self;
    FTriggerPanels.Add(TriggerPanel);
  end;

  if Triggers.Count = 0 then
  begin
    TriggerPanel := TTriggerControlPanel.Create(Self, nil, Self, FModifyCollector);
    TriggerPanel.Parent := Self;
    FTriggerPanels.Add(TriggerPanel);
  end;

  Sort;
end;

destructor TTriggerController.Destroy;
var
  TriggerPanel: TObject;
begin
  for TriggerPanel in FTriggerPanels do TriggerPanel.Free;
  FTriggerPanels.Free;

  inherited;
end;

procedure TTriggerController.Delete(Trigger: ITrigger);
var
  TriggerPanel: TTriggerControlPanel;
begin
  for TriggerPanel in FTriggerPanels do
    if TriggerPanel.Trigger = Trigger then
    begin
      FModifyCollector.Modify;
      FTriggerPanels.Remove(TriggerPanel);
      TriggerPanel.Free;
      Break;
    end;

  Sort;

  if Assigned(FOnPanelRawCountChange) then
    FOnPanelRawCountChange(Self, FTriggerPanels.Count);
end;

procedure TTriggerController.Delete(TriggerPanel: TTriggerControlPanel);
begin
  FModifyCollector.Modify;

  FTriggerPanels.Remove(TriggerPanel);
  TriggerPanel.Free;

  Sort;

  if Assigned(FOnPanelRawCountChange) then
    FOnPanelRawCountChange(Self, FTriggerPanels.Count);
end;

procedure TTriggerController.Sort;
var
  I: Integer;
  HeightAccumulator: Integer;
begin
  if FTriggerPanels.Count = 0 then Exit;  

  DisableAlign;
  try
    HeightAccumulator := Padding.Top;
    for I := 0 to FTriggerPanels.Count - 1 do
      with FTriggerPanels[I] do
      begin
        Top := HeightAccumulator;
        TabOrder := I;
        Removable := FTriggerPanels.Count <> 1;
        
        Inc(HeightAccumulator, Margins.ExplicitHeight);
      end;
  finally
    EnableAlign;
  end;
end;

procedure TTriggerController.AddDefault;
var
  TriggerPanel: TTriggerControlPanel;
begin
  FModifyCollector.Modify;

  DisableAlign;
  try
    TriggerPanel := TTriggerControlPanel.Create(Self, nil, Self, FModifyCollector);
    TriggerPanel.Parent := Self;
    FTriggerPanels.Add(TriggerPanel);

    Sort;  
  finally
    EnableAlign;
  end;

  if Assigned(FOnPanelRawCountChange) then
    FOnPanelRawCountChange(Self, FTriggerPanels.Count);
end; 

function TTriggerController.GetPanelRawCount: Integer;
begin
  Result := FTriggerPanels.Count;
end;  

procedure TTriggerController.SetOnPanelRawCountChange(
  const Value: TTriggersCountChange);
begin
  FOnPanelRawCountChange := Value;
  if Assigned(FOnPanelRawCountChange) then
    FOnPanelRawCountChange(Self, FTriggerPanels.Count);
end;

function TTriggerController.GetTriggers: TTriggerList;
var
  Trigger: ITrigger;
  I: Integer;
begin
  Result := TTriggerList.Create;
  for I := 0 to FTriggerPanels.Count - 1 do
  begin
    Trigger := FTriggerPanels[I].Trigger;
    if Assigned(Trigger) then
    begin
      Trigger.ID := I;
      Result.Add(Trigger);
    end;
  end;
end;

{ TBaseTriggerPanel }

constructor TBaseTriggerPanel.Create(AOwner: TComponent; Trigger: ITrigger;
  ModifyCollector: IModifyCollector);
begin
  inherited Create(AOwner);
  FTrigger := Trigger;
  FModifyCollector := ModifyCollector;
  FUpdateLocker := TLocker.Create;
  
  Align := alClient;
  BevelOuter := bvNone;
end;

function TBaseTriggerPanel.GetTrigger: ITrigger;
begin
  Result := FTrigger;
end;

{ TPreviewTriggerPanel }

constructor TPreviewTriggerPanel.Create(AOwner: TComponent; Trigger: ITrigger;
  ModifyCollector: IModifyCollector);
var
  TriggerDescription: string;
begin
  inherited Create(AOwner, Trigger, ModifyCollector);
  
  if Assigned(FTrigger) then
    TriggerDescription := FTrigger.Description
  else
    TriggerDescription := '';
    
  FLabelDescription := TLabel.Create(Self);
  with FLabelDescription do
  begin
    Align := alClient;
    AlignWithMargins := True;
    Layout := tlCenter;
    EllipsisPosition := epEndEllipsis;
    Caption := TriggerDescription;
    Parent := Self;
    Margins.SetBounds(2, 2, 0, 4);
  end;
end;

destructor TPreviewTriggerPanel.Destroy;
begin
  FLabelDescription.Free;
  inherited;
end;

{ TPercentageTriggerPanel }

constructor TPercentageTriggerPanel.Create(AOwner: TComponent;
  Trigger: ITrigger; ModifyCollector: IModifyCollector);
var
  WidthAccumulator: Integer;
  TriggerPercentage: Integer;
  PercentageVisible: Boolean;
  I: Integer;
begin
  inherited Create(AOwner, Trigger, ModifyCollector);

  FConditionsInfo := TList<TConditionInfo>.Create;
  FConditionsInfo.Add(TConditionInfo.Create(pcDropBelow));
  FConditionsInfo.Add(TConditionInfo.Create(pcRiseAbove));
  FConditionsInfo.Add(TConditionInfo.Create(pcChanged));

  FIndex := -1;
  TriggerPercentage := 50;
  if FTrigger is TTriggerPercentage then
  begin
    TriggerPercentage := (FTrigger as TTriggerPercentage).Percentage;

    for I := 0 to FConditionsInfo.Count - 1 do
      if (FTrigger as TTriggerPercentage).Clause = FConditionsInfo[I].Clause then
      begin
        FIndex := I;
        Break;
      end;

    if FIndex = -1 then
    begin
      FConditionsInfo.Add(TConditionInfo.Create((FTrigger as TTriggerPercentage).Clause));
      FIndex := FConditionsInfo.Count - 1;
    end;
  end;

  if FIndex >= 0 then
    PercentageVisible := FConditionsInfo[FIndex].Clause <> pcChanged
  else
    PercentageVisible := False;

  DisableAlign;
  FUpdateLocker.Lock;
  WidthAccumulator := Padding.Left; 
  try 
    FComboBoxCondition := TComboBox.Create(Self);
    with FComboBoxCondition do
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
      Text := TriggerPercentage.ToString;
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
      Position := TriggerPercentage;
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

destructor TPercentageTriggerPanel.Destroy;
begin
  FUpDownPercentage.Free;
  FEditPercentage.Free;
  FComboBoxCondition.Free;
  FConditionsInfo.Free;
  inherited;
end;

procedure TPercentageTriggerPanel.CreateWnd;
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

procedure TPercentageTriggerPanel.EditPercentageChange(Sender: TObject);
begin
  if FUpdateLocker.IsLocked then Exit;
  
  if (Sender as TEdit).Tag = 1 then
  begin
    (Sender as TEdit).Tag := 0; 
    Exit;
  end;
  
  FModifyCollector.Modify;
end;

procedure TPercentageTriggerPanel.ComboBoxPercentageSelect(Sender: TObject);
var
  PercentageVisible: Boolean;
begin
  if FUpdateLocker.IsLocked then Exit;

  if (Sender as TComboBox).ItemIndex >= 0 then
    PercentageVisible := FConditionsInfo[(Sender as TComboBox).ItemIndex].Clause <> pcChanged
  else
    PercentageVisible := False;

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

function TPercentageTriggerPanel.GetTrigger: ITrigger;
var
  Percentage: Integer;
begin
  if FComboBoxCondition.ItemIndex < 0 then Exit(nil);
  if not Integer.TryParse(FEditPercentage.Text, Percentage) then Exit(nil);

  if Percentage < 0 then Percentage := 0;
  if Percentage > 100 then Percentage := 100;

  Result := TTriggerPercentage.Create(
    FConditionsInfo[FComboBoxCondition.ItemIndex].Clause, Percentage);
end;

{ TPercentageTriggerPanel.TConditionInfo }

constructor TPercentageTriggerPanel.TConditionInfo.Create(
  Clause: TTriggerPercentage.TClause);
begin
  Self.Clause := Clause;
  case Clause of
    pcDropBelow:  Name := TLang[1205]; // опустился ниже
    pcRiseAbove:  Name := TLang[1206]; // поднялся выше
    pcChanged:    Name := TLang[1207]; // изменился
  end;
end;

{ TAcTriggerPanel }

constructor TAcTriggerPanel.Create(AOwner: TComponent; Trigger: ITrigger;
  ModifyCollector: IModifyCollector);
var
  I: Integer;
begin
  inherited Create(AOwner, Trigger, ModifyCollector);

  FConditionsInfo := TList<TConditionInfo>.Create;
  FConditionsInfo.Add(TConditionInfo.Create(accInject));
  FConditionsInfo.Add(TConditionInfo.Create(accEject));
  FConditionsInfo.Add(TConditionInfo.Create(accChanged));

  FIndex := -1;
  if FTrigger is TTriggerAc then
  begin
    for I := 0 to FConditionsInfo.Count - 1 do
      if (FTrigger as TTriggerAc).Clause = FConditionsInfo[I].Clause then
      begin
        FIndex := I;
        Break;
      end;

    if FIndex = -1 then
    begin
      FConditionsInfo.Add(TConditionInfo.Create((FTrigger as TTriggerAc).Clause));
      FIndex := FConditionsInfo.Count - 1;
    end;
  end;

  DisableAlign;
  FUpdateLocker.Lock;
  try
    FComboBoxCondition := TComboBox.Create(Self);
    with FComboBoxCondition do
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

destructor TAcTriggerPanel.Destroy;
begin
  FComboBoxCondition.Free;
  FConditionsInfo.Free;
  inherited;
end;

procedure TAcTriggerPanel.CreateWnd;
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

procedure TAcTriggerPanel.ComboBoxPercentageSelect(Sender: TObject);
begin
  if FUpdateLocker.IsLocked then Exit;

  FModifyCollector.Modify;
end;

function TAcTriggerPanel.GetTrigger: ITrigger;
begin
  if FComboBoxCondition.ItemIndex < 0 then Exit(nil);

  Result := TTriggerAc.Create(
    FConditionsInfo[FComboBoxCondition.ItemIndex].Clause);
end;

{ TAcTriggerPanel.TConditionInfo }

constructor TAcTriggerPanel.TConditionInfo.Create(Clause: TTriggerAc.TClause);
begin
  Self.Clause := Clause;
  case Clause of
    accInject:       Name := TLang[1225]; // подсоединён
    accEject:        Name := TLang[1226]; // отсоединён
    accChanged:      Name := TLang[1227]; // изменил состояние
  end;
end;

{ TLidSwitchTriggerPanel }

constructor TLidSwitchTriggerPanel.Create(AOwner: TComponent; Trigger: ITrigger;
  ModifyCollector: IModifyCollector);
var
  I: Integer;
begin
  inherited Create(AOwner, Trigger, ModifyCollector);

  FConditionsInfo := TList<TConditionInfo>.Create;
  FConditionsInfo.Add(TConditionInfo.Create(lscClosed));
  FConditionsInfo.Add(TConditionInfo.Create(lscOpened));

  FIndex := -1;
  if FTrigger is TTriggerLidSwitch then
  begin
    for I := 0 to FConditionsInfo.Count - 1 do
      if (FTrigger as TTriggerLidSwitch).Clause = FConditionsInfo[I].Clause then
      begin
        FIndex := I;
        Break;
      end;

    if FIndex = -1 then
    begin
      FConditionsInfo.Add(TConditionInfo.Create((FTrigger as TTriggerLidSwitch).Clause));
      FIndex := FConditionsInfo.Count - 1;
    end;
  end;

  DisableAlign;
  FUpdateLocker.Lock;
  try
    FComboBoxCondition := TComboBox.Create(Self);
    with FComboBoxCondition do
    begin
      Align := alLeft;
      AlignWithMargins := True;
      Style := csDropDownList;
      Parent := Self;
      Margins.SetBounds(4, 3, 0, 3);
      Tag := 1; // Заполнение данными на CreateWnd
      Width := 135;
      OnChange := ComboBoxConditionSelect;
    end;
  finally
    FUpdateLocker.Unlock;
    EnableAlign;
  end;
end;

destructor TLidSwitchTriggerPanel.Destroy;
begin
  FComboBoxCondition.Free;
  FConditionsInfo.Free;
  inherited;
end;

procedure TLidSwitchTriggerPanel.CreateWnd;
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

procedure TLidSwitchTriggerPanel.ComboBoxConditionSelect(Sender: TObject);
begin
  if FUpdateLocker.IsLocked then Exit;

  FModifyCollector.Modify;
end;

function TLidSwitchTriggerPanel.GetTrigger: ITrigger;
begin
  if FComboBoxCondition.ItemIndex < 0 then Exit(nil);

  Result := TTriggerLidSwitch.Create(
    FConditionsInfo[FComboBoxCondition.ItemIndex].Clause);
end;

{ TLidSwitchTriggerPanel.TConditionInfo }

constructor TLidSwitchTriggerPanel.TConditionInfo.Create(Clause: TTriggerLidSwitch.TClause);
begin
  Self.Clause := Clause;
  case Clause of
    lscClosed:  Name := TLang[1245]; // закрылась
    lscOpened:  Name := TLang[1246]; // открылась
  end;
end;

{ TDisplayStateTriggerPanel }

constructor TDisplayStateTriggerPanel.Create(AOwner: TComponent; Trigger: ITrigger;
  ModifyCollector: IModifyCollector);
var
  I: Integer;
begin
  inherited Create(AOwner, Trigger, ModifyCollector);

  FConditionsInfo := TList<TConditionInfo>.Create;
  FConditionsInfo.Add(TConditionInfo.Create(dscOff));
  FConditionsInfo.Add(TConditionInfo.Create(dscOn));
  if IsWindows8OrGreater then
    FConditionsInfo.Add(TConditionInfo.Create(dscDimmed));

  FIndex := -1;
  if FTrigger is TTriggerDisplayState then
  begin
    for I := 0 to FConditionsInfo.Count - 1 do
      if (FTrigger as TTriggerDisplayState).Clause = FConditionsInfo[I].Clause then
      begin
        FIndex := I;
        Break;
      end;

    if FIndex = -1 then
    begin
      FConditionsInfo.Add(TConditionInfo.Create((FTrigger as TTriggerDisplayState).Clause));
      FIndex := FConditionsInfo.Count - 1;
    end;
  end;

  DisableAlign;
  FUpdateLocker.Lock;
  try
    FComboBoxCondition := TComboBox.Create(Self);
    with FComboBoxCondition do
    begin
      Align := alLeft;
      AlignWithMargins := True;
      Style := csDropDownList;
      Parent := Self;
      Margins.SetBounds(4, 3, 0, 3);
      Tag := 1; // Заполнение данными на CreateWnd
      Width := 135;
      OnChange := ComboBoxConditionSelect;
    end;
  finally
    FUpdateLocker.Unlock;
    EnableAlign;
  end;
end;

destructor TDisplayStateTriggerPanel.Destroy;
begin
  FComboBoxCondition.Free;
  FConditionsInfo.Free;
  inherited;
end;

procedure TDisplayStateTriggerPanel.CreateWnd;
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

procedure TDisplayStateTriggerPanel.ComboBoxConditionSelect(Sender: TObject);
begin
  if FUpdateLocker.IsLocked then Exit;

  FModifyCollector.Modify;
end;

function TDisplayStateTriggerPanel.GetTrigger: ITrigger;
begin
  if FComboBoxCondition.ItemIndex < 0 then Exit(nil);

  Result := TTriggerDisplayState.Create(
    FConditionsInfo[FComboBoxCondition.ItemIndex].Clause);
end;

{ TDisplayStateTriggerPanel.TConditionInfo }

constructor TDisplayStateTriggerPanel.TConditionInfo.Create(Clause: TTriggerDisplayState.TClause);
begin
  Self.Clause := Clause;
  case Clause of
    dscOff:       Name := TLang[1265]; // отключился
    dscOn:        Name := TLang[1266]; // включился
    dscDimmed:    Name := TLang[1267]; // в режиме уменьшеной яркости
  end;
end;

{ TSchemeTriggerPanel }

constructor TSchemeTriggerPanel.Create(AOwner: TComponent; Trigger: ITrigger;
  ModifyCollector: IModifyCollector);
var
  I: Integer;
begin
  inherited Create(AOwner, Trigger, ModifyCollector);

  FConditionsInfo := TBatteryMode.PowerSchemes.Schemes.Copy;

  FIndex := -1;
  if FTrigger is TTriggerScheme then
  begin
    for I := 0 to FConditionsInfo.Count - 1 do
      if (FTrigger as TTriggerScheme).Clause.Equals(FConditionsInfo[I]) then
      begin
        FIndex := I;
        Break;
      end;

    if FIndex = -1 then
    try
      FConditionsInfo.Add(TBatteryMode.PowerSchemes.MakeSchemeFromUniqueString((FTrigger as TTriggerScheme).Clause.UniqueString));
      FConditionsInfo.Sort;
      for I := 0 to FConditionsInfo.Count - 1 do
        if (FTrigger as TTriggerScheme).Clause.Equals(FConditionsInfo[I]) then
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
    FComboBoxCondition := TComboBox.Create(Self);
    with FComboBoxCondition do
    begin
      Align := alLeft;
      AlignWithMargins := True;
      Style := csDropDownList;
      Parent := Self;
      Margins.SetBounds(4, 3, 0, 3);
      Tag := 1; // Заполнение данными на CreateWnd
      Width := 213;
      OnChange := ComboBoxConditionSelect;
    end;
  finally
    FUpdateLocker.Unlock;
    EnableAlign;
  end;
end;

destructor TSchemeTriggerPanel.Destroy;
begin
  FComboBoxCondition.Free;
  FConditionsInfo.Free;
  inherited;
end;

procedure TSchemeTriggerPanel.CreateWnd;
var
  ConditionInfo: IPowerScheme;
begin
  inherited;

  if FComboBoxCondition.Tag <> 1 then Exit;

  FUpdateLocker.Lock;
  try
    FComboBoxCondition.Tag := 0;
    for ConditionInfo in FConditionsInfo do
      if ConditionInfo.IsHidden then
        FComboBoxCondition.Items.Add(ConditionInfo.UniqueString)
      else
        FComboBoxCondition.Items.Add(ConditionInfo.FriendlyName);

    FComboBoxCondition.ItemIndex := FIndex;
  finally
    FUpdateLocker.Unlock;
  end;
end;

procedure TSchemeTriggerPanel.ComboBoxConditionSelect(Sender: TObject);
begin
  if FUpdateLocker.IsLocked then Exit;

  FModifyCollector.Modify;
end;

function TSchemeTriggerPanel.GetTrigger: ITrigger;
begin
  if FComboBoxCondition.ItemIndex < 0 then Exit(nil);

  Result := TTriggerScheme.Create(
    FConditionsInfo[FComboBoxCondition.ItemIndex]);
end;

end.
