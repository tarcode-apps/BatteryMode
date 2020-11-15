unit Scheduling.UI.Actions;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes,
  System.Generics.Collections, System.Generics.Defaults,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Vcl.ComCtrls,
  Battery.Mode,
  Core.Language,
  Core.UI, Core.UI.Controls,
  Power,
  Power.Shutdown,
  Scheduling, Scheduling.Actions,
  Versions.Helpers;

type
  TActionBasePanel = class(TPanel)
  strict private
    FAction: IAction;
    FInvolved: Boolean;
    FInvolvedUpdate: Boolean;
    FCheckBoxInvolved: TCheckBox;
    FPanelAction: TPanel;

    FModifyCollector: IModifyCollector;

    function GetActionName: string;
    procedure SetActionName(const Value: string);
    function GetInvolved: Boolean;
    procedure SetInvolved(const Value: Boolean);

    procedure CheckBoxInvolvedClick(Sender: TObject);
  protected
    FModification: Boolean;

    function GetRuleAction: IAction; virtual;
    procedure DoInvolved(Value: Boolean); virtual;

    property Action: IAction read FAction;
    property ActionName: string read GetActionName write SetActionName;
    property PanelAction: TPanel read FPanelAction;
    property CheckBoxInvolved: TCheckBox read FCheckBoxInvolved;
    property ModifyCollector: IModifyCollector read FModifyCollector;
  public
    constructor Create(AOwner: TComponent; ModifyCollector: IModifyCollector;
      Action: IAction); reintroduce;
    destructor Destroy; override;

    property Involved: Boolean read GetInvolved write SetInvolved;
    property RuleAction: IAction read GetRuleAction;
  end;

  TActionWithExtraPanel = class(TActionBasePanel)
  strict private
    FPanelExtra: TPanel;
  private
    function GetPanelExtraHeight: Integer;
    procedure SetPanelExtraHeight(const Value: Integer);
  protected
    procedure DoInvolved(Value: Boolean); override;

    property PanelExtra: TPanel read FPanelExtra;
    property PanelExtraHeight: Integer read GetPanelExtraHeight write SetPanelExtraHeight;
  public
    constructor Create(AOwner: TComponent; ModifyCollector: IModifyCollector;
      Action: IAction); reintroduce;
    procedure AfterConstruction; override;
    destructor Destroy; override;
  end;

  TActionPreviewPanel = class(TActionBasePanel)
  strict private
    FLabelDescription: TLabel;
  protected
    procedure DoInvolved(Value: Boolean); override;
  public
    constructor Create(AOwner: TComponent; ModifyCollector: IModifyCollector;
      Action: IAction); reintroduce;
    destructor Destroy; override;
  end;

  TActionMessagePanel = class(TActionBasePanel)
  strict private
    FEditMessage: TEdit;
    procedure EditMessageChange(Sender: TObject);
  protected
     function GetRuleAction: IAction; override;
     procedure DoInvolved(Value: Boolean); override;
  public
    constructor Create(AOwner: TComponent; ModifyCollector: IModifyCollector;
      Action: IAction); reintroduce;
    destructor Destroy; override;
  end;

  TActionSchemePanel = class(TActionBasePanel)
  strict private
    FSchemes: TPowerSchemeList;
    FComboBoxScheme: TComboBox;
    FIndex: Integer;
    procedure ComboBoxSchemeSelect(Sender: TObject);
  protected
    function GetRuleAction: IAction; override;
    procedure DoInvolved(Value: Boolean); override;
    procedure CreateWnd; override;
  public
    constructor Create(AOwner: TComponent; ModifyCollector: IModifyCollector;
      Action: IAction); reintroduce;
    destructor Destroy; override;
  end;

  TActionRunPanel = class(TActionWithExtraPanel)
  strict private
    FEdit: TEdit;
    FButton: TButton;
    FCheckBox: TCheckBox;
    procedure EditChange(Sender: TObject);
    procedure EditDblClick(Sender: TObject);
    procedure ButtonClick(Sender: TObject);
    procedure CheckBoxClick(Sender: TObject);
  protected
     function GetRuleAction: IAction; override;
     procedure DoInvolved(Value: Boolean); override;
  public
    constructor Create(AOwner: TComponent; ModifyCollector: IModifyCollector;
      Action: IAction); reintroduce;
    destructor Destroy; override;
  end;

  TActionSoundPanel = class(TActionWithExtraPanel)
  strict private
    FEdit: TEdit;
    FButton: TButton;
    FLabel: TLabel;
    FTrackBar: TTrackBar;
    procedure EditChange(Sender: TObject);
    procedure EditDblClick(Sender: TObject);
    procedure ButtonClick(Sender: TObject);
    procedure TrackBarChange(Sender: TObject);
  protected
     function GetRuleAction: IAction; override;
     procedure DoInvolved(Value: Boolean); override;
  public
    constructor Create(AOwner: TComponent; ModifyCollector: IModifyCollector;
      Action: IAction); reintroduce;
    destructor Destroy; override;
  end;

  TActionPowerPanel = class(TActionBasePanel)
  strict private
    FActionTypes: TList<TActionPowerType>;
    FComboBoxPower: TComboBox;
    FIndex: Integer;
    procedure ComboBoxPowerSelect(Sender: TObject);
  protected
    function GetRuleAction: IAction; override;
    procedure DoInvolved(Value: Boolean); override;
    procedure CreateWnd; override;
  public
    constructor Create(AOwner: TComponent; ModifyCollector: IModifyCollector;
      Action: IAction); reintroduce;
    destructor Destroy; override;
  end;

implementation

{ TBaseActionPanel }

constructor TActionBasePanel.Create(AOwner: TComponent;
  ModifyCollector: IModifyCollector; Action: IAction);
var
  WidthAccumulator: Integer;
begin
  inherited Create(AOwner);
  FAction := Action;
  FModifyCollector := ModifyCollector;

  FInvolvedUpdate := False;
  FModification := False;
  FInvolved := False;

  Align := alTop;
  BevelOuter := bvNone;
  Height := 37;
  Padding.SetBounds(16, 4, 16, 4);

  WidthAccumulator := Padding.Left;
  DisableAlign;
  try
    FCheckBoxInvolved := TCheckBox.Create(Self);
    with FCheckBoxInvolved do
    begin
      Align := alLeft;
      AlignWithMargins := True;
      AdditionalSpace := True;
      AutoSize := True;
      Parent := Self;
      Padding.SetBounds(4, 0, 2, 0);
      Margins.SetBounds(0, 2, 2, 3);
      Left := WidthAccumulator;
      OnClick := CheckBoxInvolvedClick;

      Inc(WidthAccumulator, Margins.ExplicitWidth);
    end;

    FPanelAction := TPanel.Create(Self);
    with FPanelAction do
    begin
      Align := alClient;
      AlignWithMargins := True;
      BevelOuter := bvNone;
      Parent := Self;
      Left := WidthAccumulator;
      Margins.SetBounds(0, 0, 0, 0);
    end;
  finally
    EnableAlign;
  end;

  Involved := Assigned(FAction);
end;

destructor TActionBasePanel.Destroy;
begin
  FCheckBoxInvolved.Free;
  FPanelAction.Free;

  inherited;
end;

function TActionBasePanel.GetActionName: string;
begin
  Result := FCheckBoxInvolved.Caption;
end;

procedure TActionBasePanel.SetActionName(const Value: string);
begin
  FCheckBoxInvolved.Caption := Value;
end;

function TActionBasePanel.GetInvolved: Boolean;
begin
  Result := FInvolved;
end;

procedure TActionBasePanel.SetInvolved(const Value: Boolean);
begin
  if FInvolved = Value then Exit;
  FInvolved := Value;

  FInvolvedUpdate := True;
  try
    FCheckBoxInvolved.Checked := FInvolved;
  finally
    FInvolvedUpdate := False;
  end;

  DoInvolved(Value);
end;

procedure TActionBasePanel.DoInvolved(Value: Boolean);
begin
end;

procedure TActionBasePanel.CheckBoxInvolvedClick(Sender: TObject);
begin
  if FInvolvedUpdate then Exit;

  Involved := (Sender as TCheckBox).Checked;
  FModifyCollector.Modify;
end;

function TActionBasePanel.GetRuleAction: IAction;
begin
  Result := FAction;
end;

{ TActionWithExtraPanel }

constructor TActionWithExtraPanel.Create(AOwner: TComponent;
  ModifyCollector: IModifyCollector; Action: IAction);
var
  HeightDelta: Integer;
begin
  inherited Create(AOwner, ModifyCollector, Action);

  FPanelExtra := TPanel.Create(PanelAction);
  with FPanelExtra do
  begin
    Align := alBottom;
    AlignWithMargins := True;
    Height := 21;
    Margins.SetBounds(3, 0, 1, 0);
    BevelOuter := bvNone;
    Parent := PanelAction;
    Visible := Involved;
  end;

  HeightDelta := FPanelExtra.Margins.ExplicitHeight;

  if Involved then
  begin
    Height := Height + HeightDelta;
    CheckBoxInvolved.Margins.Bottom := CheckBoxInvolved.Margins.Bottom + HeightDelta;
  end;
end;

procedure TActionWithExtraPanel.AfterConstruction;
begin
  inherited;
  PanelAction.TabOrder := 1;
  PanelExtra.TabOrder := 2;
end;

destructor TActionWithExtraPanel.Destroy;
begin
  FPanelExtra.Free;
  inherited;
end;

procedure TActionWithExtraPanel.DoInvolved(Value: Boolean);
var
  HeightDelta: Integer;
begin
  inherited;
  if Assigned(FPanelExtra) then
  begin
    FPanelExtra.Visible := Value;

    HeightDelta := FPanelExtra.Margins.ExplicitHeight;

    if Value then
    begin
      Height := Height + HeightDelta;
      CheckBoxInvolved.Margins.Bottom := CheckBoxInvolved.Margins.Bottom + HeightDelta;
    end
    else
    begin
      Height := Height - HeightDelta;
      CheckBoxInvolved.Margins.Bottom := CheckBoxInvolved.Margins.Bottom - HeightDelta;
    end;
  end;
end;

function TActionWithExtraPanel.GetPanelExtraHeight: Integer;
begin
  Result := FPanelExtra.Height;
end;

procedure TActionWithExtraPanel.SetPanelExtraHeight(const Value: Integer);
var
  HeightDelta: Integer;
begin
  if Assigned(FPanelExtra) then
  begin
    HeightDelta := Value - FPanelExtra.Height;
    FPanelExtra.Height := Value;

    if Involved then
    begin
      Height := Height + HeightDelta;
      CheckBoxInvolved.Margins.Bottom := CheckBoxInvolved.Margins.Bottom + HeightDelta;
    end;
  end;
end;

{ TActionPreviewPanel }

constructor TActionPreviewPanel.Create(AOwner: TComponent;
  ModifyCollector: IModifyCollector; Action: IAction);
var
  ActionDescription: string;
begin
  inherited Create(AOwner, ModifyCollector, Action);

  if Assigned(Action) then
    ActionDescription := Action.Description
  else
    ActionDescription := '';

  FLabelDescription := TLabel.Create(PanelAction);
  with FLabelDescription do
  begin
    Align := alClient;
    AlignWithMargins := True;
    Layout := tlCenter;
    Enabled := Involved;
    EllipsisPosition := epEndEllipsis;
    Caption := ActionDescription;
    Parent := PanelAction;
    Margins.SetBounds(2, 2, 0, 4);
  end;
end;

destructor TActionPreviewPanel.Destroy;
begin
  FLabelDescription.Free;
  inherited;
end;

procedure TActionPreviewPanel.DoInvolved(Value: Boolean);
begin
  inherited;
  if Assigned(FLabelDescription) then
    FLabelDescription.Enabled := Value;
end;

{ TActionMessagePanel }

constructor TActionMessagePanel.Create(AOwner: TComponent;
  ModifyCollector: IModifyCollector; Action: IAction);
var
  ActionText: string;
begin
  inherited Create(AOwner, ModifyCollector, Action);

  ActionName := TLang[1101]; // Показать сообщение

  if Action is TActionMessage then
    ActionText := (Action as TActionMessage).Text
  else
    ActionText := '';

  FModification := True;
  try
    FEditMessage := TEdit.Create(PanelAction);
    with FEditMessage do
    begin
      Align := alClient;
      AlignWithMargins := True;
      Enabled := Involved;
      Text := ActionText;
      Parent := PanelAction;
      Margins.SetBounds(3, 3, 0, 3);
      OnChange := EditMessageChange;
    end;
  finally
    FModification := False;
  end;
end;

destructor TActionMessagePanel.Destroy;
begin
  FEditMessage.Free;
  inherited;
end;

procedure TActionMessagePanel.EditMessageChange(Sender: TObject);
begin
  if FModification then Exit;

  ModifyCollector.Modify;
end;

function TActionMessagePanel.GetRuleAction: IAction;
begin
  Result := TActionMessage.Create(FEditMessage.Text);
  if Assigned(Action) then
    Result.ID := Action.ID;
end;

procedure TActionMessagePanel.DoInvolved(Value: Boolean);
begin
  inherited;
  if Assigned(FEditMessage) then
    FEditMessage.Enabled := Value;
end;

{ TActionSchemePanel }

constructor TActionSchemePanel.Create(AOwner: TComponent;
  ModifyCollector: IModifyCollector; Action: IAction);
var
  I: Integer;
begin
  inherited Create(AOwner, ModifyCollector, Action);

  ActionName := TLang[1111]; // Включить схему электропитания

  FSchemes := TBatteryMode.PowerSchemes.Schemes.Copy;

  FIndex := -1;
  if Action is TActionScheme then
  begin
    for I := 0 to FSchemes.Count - 1 do
      if FSchemes[I].UniqueString = (Action as TActionScheme).Scheme.UniqueString then
      begin
        FIndex := I;
        Break;
      end;

    if FIndex = -1 then
    begin
      FSchemes.Add((Action as TActionScheme).Scheme);
      FIndex := FSchemes.Count - 1;
    end;
  end;

  FModification := True;
  try
    FComboBoxScheme := TComboBox.Create(PanelAction);
    with FComboBoxScheme do
    begin
      Align := alClient;
      AlignWithMargins := True;
      Enabled := Involved;
      Style := csDropDownList;
      Parent := PanelAction;
      Margins.SetBounds(3, 3, 0, 3);
      Tag := 1;
      OnChange := ComboBoxSchemeSelect;
    end;
  finally
    FModification := False;
  end;
end;

procedure TActionSchemePanel.CreateWnd;
var
  Scheme: IPowerScheme;
begin
  inherited;

  if FComboBoxScheme.Tag <> 1 then Exit;

  FModification := True;
  try
    FComboBoxScheme.Tag := 0;
    for Scheme in FSchemes do
      if Scheme.IsHidden then
        FComboBoxScheme.Items.Add(Scheme.UniqueString)
      else
        FComboBoxScheme.Items.Add(Scheme.FriendlyName);

    FComboBoxScheme.ItemIndex := FIndex;
  finally
    FModification := False;
  end;
end;

destructor TActionSchemePanel.Destroy;
begin
  FComboBoxScheme.Free;
  FSchemes.Free;
  inherited;
end;

procedure TActionSchemePanel.ComboBoxSchemeSelect(Sender: TObject);
begin
  if FModification then Exit;
  ModifyCollector.Modify;
end;


function TActionSchemePanel.GetRuleAction: IAction;
begin
  if FComboBoxScheme.ItemIndex = -1 then Exit(nil);

  Result := TActionScheme.Create(FSchemes[FComboBoxScheme.ItemIndex]);
  if Assigned(Action) then
    Result.ID := Action.ID;
end;

procedure TActionSchemePanel.DoInvolved(Value: Boolean);
begin
  inherited;
  if Assigned(FComboBoxScheme) then
    FComboBoxScheme.Enabled := Value;
end;

{ TActionRunPanel }

constructor TActionRunPanel.Create(AOwner: TComponent;
  ModifyCollector: IModifyCollector; Action: IAction);
var
  ActionText: string;
  ActionHide: Boolean;
begin
  inherited Create(AOwner, ModifyCollector, Action);

  ActionName := TLang[1120]; // Запустить программу

  if Action is TActionRun then
  begin
    ActionText := (Action as TActionRun).FileName;
    ActionHide := (Action as TActionRun).Hide;
  end
  else
  begin
    ActionText := '';
    ActionHide := False;
  end;

  FModification := True;
  try
    FEdit := TEdit.Create(PanelAction);
    with FEdit do
    begin
      Align := alClient;
      AlignWithMargins := True;
      Enabled := Involved;
      Text := ActionText;
      Parent := PanelAction;
      Margins.SetBounds(3, 3, 0, 3);
      OnChange := EditChange;
      OnDblClick := EditDblClick;
    end;

    FButton := TButton.Create(PanelAction);
    with FButton do
    begin
      Align := alRight;
      AlignWithMargins := True;
      Enabled := Involved;
      Caption := TLang[1125]; // Открыть
      Parent := PanelAction;
      Margins.SetBounds(3, 2, 0, 2);
      OnClick := ButtonClick;
    end;

    FCheckBox := TCheckBox.Create(PanelExtra);
    with FCheckBox do
    begin
      Align := alClient;
      AlignWithMargins := True;
      AdditionalSpace := True;
      Enabled := Involved;
      Caption := TLang[1126]; // Скрыто
      Checked := ActionHide;
      Parent := PanelExtra;
      Margins.SetBounds(0, 2, 0, 2);
      OnClick := CheckBoxClick;
    end;
  finally
    FModification := False;
  end;
end;

destructor TActionRunPanel.Destroy;
begin
  FButton.Free;
  FEdit.Free;
  FCheckBox.Free;
  inherited;
end;

procedure TActionRunPanel.EditChange(Sender: TObject);
begin
  if FModification then Exit;

  ModifyCollector.Modify;
end;

procedure TActionRunPanel.EditDblClick(Sender: TObject);
begin
  FButton.Click;
end;

procedure TActionRunPanel.ButtonClick(Sender: TObject);
var
  OpenDialog: TOpenDialog;
begin
  OpenDialog := TOpenDialog.Create(Self);
  try
    if OpenDialog.Execute(WindowHandle) then
      FEdit.Text := string(OpenDialog.FileName).QuotedString('"');
  finally
    OpenDialog.Free;
  end;
end;

procedure TActionRunPanel.CheckBoxClick(Sender: TObject);
begin
  if FModification then Exit;

  ModifyCollector.Modify;
end;

function TActionRunPanel.GetRuleAction: IAction;
begin
  Result := TActionRun.Create(FEdit.Text, FCheckBox.Checked);
  if Assigned(Action) then
    Result.ID := Action.ID;
end;

procedure TActionRunPanel.DoInvolved(Value: Boolean);
begin
  inherited;
  if Assigned(FEdit) and Assigned(FButton) and Assigned(FCheckBox) then
  begin
    FEdit.Enabled := Value;
    FButton.Enabled := Value;
    FCheckBox.Enabled := Value;
  end;
end;

{ TActionSoundPanel }

constructor TActionSoundPanel.Create(AOwner: TComponent;
  ModifyCollector: IModifyCollector; Action: IAction);
var
  ActionText: string;
  ActionVolume: Integer;
begin
  inherited Create(AOwner, ModifyCollector, Action);

  ActionName := TLang[1130]; // Воспроизвести звук

  if Action is TActionSound then
  begin
    ActionText := (Action as TActionSound).FileName;
    ActionVolume := (Action as TActionSound).Volume;
  end
  else
  begin
    ActionText := '';
    ActionVolume := 100;
  end;

  FModification := True;
  try
    FEdit := TEdit.Create(PanelAction);
    with FEdit do
    begin
      Align := alClient;
      AlignWithMargins := True;
      Enabled := Involved;
      Text := ActionText;
      Margins.SetBounds(3, 3, 0, 3);
      Parent := PanelAction;
      OnChange := EditChange;
      OnDblClick := EditDblClick;
    end;

    FButton := TButton.Create(PanelAction);
    with FButton do
    begin
      Align := alRight;
      AlignWithMargins := True;
      Enabled := Involved;
      Caption := TLang[1135]; // Открыть
      Margins.SetBounds(3, 2, 0, 2);
      Parent := PanelAction;
      OnClick := ButtonClick;
    end;

    PanelExtraHeight := 27;

    FLabel := TLabel.Create(PanelExtra);
    with FLabel do
    begin
      Align := alLeft;
      AlignWithMargins := True;
      Caption := TLang[1136]; // Громкость
      Margins.SetBounds(0, 4, 3, 2);
      Parent := PanelExtra;
    end;

    FTrackBar := TTrackBar.Create(PanelExtra);
    with FTrackBar do
    begin
      Align := alClient;
      AlignWithMargins := True;
      DirectDrag := True;
      Enabled := Involved;
      ShowSelRange := False;
      TickStyle := tsNone;
      PositionToolTip := ptTop;
      ToolTipFormat := '%0:d%%';
      Min := 0;
      Max := 100;
      ThumbLength := 22;
      Position := ActionVolume;
      Margins.SetBounds(0, 2, FButton.Margins.ExplicitWidth - 1, 0);
      Parent := PanelExtra;
      OnChange := TrackBarChange;
    end;
  finally
    FModification := False;
  end;
end;

destructor TActionSoundPanel.Destroy;
begin
  FButton.Free;
  FEdit.Free;
  FLabel.Free;
  FTrackBar.Free;
  inherited;
end;

procedure TActionSoundPanel.EditChange(Sender: TObject);
begin
  if FModification then Exit;

  ModifyCollector.Modify;
end;

procedure TActionSoundPanel.EditDblClick(Sender: TObject);
begin
  FButton.Click;
end;

procedure TActionSoundPanel.ButtonClick(Sender: TObject);
var
  OpenDialog: TOpenDialog;
begin
  OpenDialog := TOpenDialog.Create(Self);
  OpenDialog.Filter := string.Format('%0:s|*.wav;*.mp3;*.mid|%1:s|*.*', [TLang[1137], TLang[1138]]); // Звуковые файлы, Все файлы
  try
    if OpenDialog.Execute(WindowHandle) then
      FEdit.Text := string(OpenDialog.FileName);
  finally
    OpenDialog.Free;
  end;
end;

procedure TActionSoundPanel.TrackBarChange(Sender: TObject);
begin
  if FModification then Exit;

  ModifyCollector.Modify;
end;

function TActionSoundPanel.GetRuleAction: IAction;
begin
  Result := TActionSound.Create(FEdit.Text, FTrackBar.Position);
  if Assigned(Action) then
    Result.ID := Action.ID;
end;

procedure TActionSoundPanel.DoInvolved(Value: Boolean);
begin
  inherited;
  if Assigned(FEdit) and Assigned(FButton) and Assigned(FTrackBar) then
  begin
    FEdit.Enabled := Value;
    FButton.Enabled := Value;
    FTrackBar.Enabled := Value;
  end;
end;

{ TActionPowerPanel }

constructor TActionPowerPanel.Create(AOwner: TComponent;
  ModifyCollector: IModifyCollector; Action: IAction);
begin
  inherited Create(AOwner, ModifyCollector, Action);

  ActionName := TLang[1140]; // Завершение работы

  FActionTypes := TList<TActionPowerType>.Create;
  if TPowerShutdownAction.Create.IsSupported then FActionTypes.Add(ptaShutdown);
  if TPowerRebootAction.Create.IsSupported then FActionTypes.Add(ptaReboot);
  if TPowerSleepAction.Create.IsSupported then FActionTypes.Add(ptaSleep);
  if TPowerHibernateAction.Create.IsSupported then FActionTypes.Add(ptaHibernate);
  FActionTypes.AddRange([ptaMonitorOff, ptaMonitorOn]);

  FIndex := -1;
  if Action is TActionPower then
  begin
    FIndex := FActionTypes.IndexOf((Action as TActionPower).ActionPowerType);
  end;

  FModification := True;
  try
    FComboBoxPower := TComboBox.Create(PanelAction);
    with FComboBoxPower do
    begin
      Align := alClient;
      AlignWithMargins := True;
      Enabled := Involved;
      Style := csDropDownList;
      Parent := PanelAction;
      Margins.SetBounds(3, 3, 0, 3);
      Tag := 1;
      OnChange := ComboBoxPowerSelect;
    end;
  finally
    FModification := False;
  end;
end;

procedure TActionPowerPanel.CreateWnd;
var
  ActionPowerType: TActionPowerType;
begin
  inherited;

  if FComboBoxPower.Tag <> 1 then Exit;

  FModification := True;
  try
    FComboBoxPower.Tag := 0;
    for ActionPowerType in FActionTypes do
      case ActionPowerType of
        ptaShutdown: FComboBoxPower.Items.Add(TLang[1151]);      // Завершение работы
        ptaReboot: FComboBoxPower.Items.Add(TLang[1152]);        // Перезагрузка
        ptaSleep: FComboBoxPower.Items.Add(TLang[1153]);         // Спящий режим
        ptaHibernate: FComboBoxPower.Items.Add(TLang[1154]);     // Гибернация
        ptaMonitorOff: FComboBoxPower.Items.Add(TLang[1155]);    // Отключить экран
        ptaMonitorOn: FComboBoxPower.Items.Add(TLang[1156]);     // Включить экран
      end;

    FComboBoxPower.ItemIndex := FIndex;
  finally
    FModification := False;
  end;
end;

destructor TActionPowerPanel.Destroy;
begin
  FComboBoxPower.Free;
  FActionTypes.Free;
  inherited;
end;

procedure TActionPowerPanel.ComboBoxPowerSelect(Sender: TObject);
begin
  if FModification then Exit;
  ModifyCollector.Modify;
end;


function TActionPowerPanel.GetRuleAction: IAction;
begin
  if FComboBoxPower.ItemIndex = -1 then Exit(nil);

  Result := TActionPower.Create(FActionTypes[FComboBoxPower.ItemIndex]);
  if Assigned(Action) then
    Result.ID := Action.ID;
end;

procedure TActionPowerPanel.DoInvolved(Value: Boolean);
begin
  inherited;
  if Assigned(FComboBoxPower) then
    FComboBoxPower.Enabled := Value;
end;

end.
