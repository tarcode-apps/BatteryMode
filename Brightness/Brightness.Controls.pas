unit Brightness.Controls;

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.CommCtrl,
  System.SysUtils, System.Classes,
  System.Generics.Collections, System.Generics.Defaults,
  Vcl.Controls, Vcl.ComCtrls, Vcl.ExtCtrls, Vcl.Graphics, Vcl.Menus, Vcl.StdCtrls,
  Core.Language,
  Core.UI, Core.UI.Controls,
  Tray.Notify.Controls,
  Brightness, Brightness.Manager;

type
  TBrightnessTrackBar = class(Core.UI.Controls.TTrackBar)
  private
    FUpdateLocker: ILocker;
    FMonitor: IBrightnessMonitor;

    FOnChangeLevel: TBrightnessChangeLevelEvent;
  protected
    procedure Changed; override;
    procedure DoToolTipText(Sender: TObject; var Text: string); override;

    procedure CNHScroll(var Msg: TWMHScroll); message CN_HSCROLL;
    procedure CNVScroll(var Msg: TWMVScroll); message CN_VSCROLL;

    procedure MonitorChangeLevel(Sender: IBrightnessMonitor; NewLevel: Integer);
  public
    constructor Create(AOwner: TComponent; const Monitor: IBrightnessMonitor); reintroduce;

    property BrightnessMonitor: IBrightnessMonitor read FMonitor;
    property OnChangeLevel: TBrightnessChangeLevelEvent read FOnChangeLevel write FOnChangeLevel;
  end;

  TBrightnessImage = class(TImage)
  private const
                          // Active, Adaptive,Type
    MonitorIconName: array [Boolean, Boolean, TBrightnessMonitorType] of string =
      ((('RBrightNotActive',          'RBrightExNotActive'),
        ('RBrightNotActiveAdaptive',  'RBrightExNotActive')),
       (('RBright',                   'RBrightEx'),
        ('RBrightAdaptive',           'RBrightEx')));
  private
    FMonitor: IBrightnessMonitor;

    FOnChangeActive: TBrightnessChangeActiveEvent;
    FOnChangeAdaptiveBrightness: TBrightnessChangeAdaptiveBrightnessEvent;
  protected
    function LoadIconDpi(hInstance: HINST; lpIconName: LPCTSTR): HICON;
    procedure MonitorChangeActive(Sender: IBrightnessMonitor; Active: Boolean);
    procedure MonitorChangeAdaptiveBrightness(Sender: IBrightnessMonitor; AdaptiveBrightness: Boolean);
    procedure ChangeScale(M, D: Integer; isDpiChange: Boolean); override;
  public
    constructor Create(AOwner: TComponent; const Monitor: IBrightnessMonitor); reintroduce;
    destructor Destroy; override;

    procedure Click; override;

    property BrightnessMonitor: IBrightnessMonitor read FMonitor;
    property OnChangeActive: TBrightnessChangeActiveEvent read FOnChangeActive write FOnChangeActive;
    property OnChangeAdaptiveBrightness: TBrightnessChangeAdaptiveBrightnessEvent read FOnChangeAdaptiveBrightness write FOnChangeAdaptiveBrightness;
  end;

  TBrightnessPanel = class(TPanel)
  private const BaseHeight = 26;
  private
    FMonitor: IBrightnessMonitor;
    FTrackBarPanel: TPanel;
    FTrackBar: TBrightnessTrackBar;
    FImageLow: TBrightnessImage;
    FValueLabel: TLabel;
    FMonitorNameLabel: TLabel;
    FShowMonitorName: Boolean;
    FShowBrightnessPercent: Boolean;

    FOnChangeLevel: TBrightnessChangeLevelEvent;
    FOnChangeActive: TBrightnessChangeActiveEvent;
    FOnChangeEnable: TBrightnessChangeEnableEvent;
    FOnChangeAdaptiveBrightness: TBrightnessChangeAdaptiveBrightnessEvent;

    procedure SetShowMonitorName(const Value: Boolean);
    procedure SetShowBrightnessPercent(const Value: Boolean);
  protected
    procedure MonitorChangeEnable(Sender: IBrightnessMonitor; Enable: Boolean);
    procedure ImageChangeActive(Sender: IBrightnessMonitor; Active: Boolean);
    procedure ImageChangeAdaptiveBrightness(Sender: IBrightnessMonitor; AdaptiveBrightness: Boolean);
    procedure TrackBarChangeLevel(Sender: IBrightnessMonitor; NewLevel: Integer);
    procedure ChangeScale(M: Integer; D: Integer; isDpiChange: Boolean); override;
    procedure SetParent(AParent: TWinControl); override;
  public
    constructor Create(AOwner: TComponent; const Monitor: IBrightnessMonitor); reintroduce;
    destructor Destroy; override;

    property BrightnessMonitor: IBrightnessMonitor read FMonitor;
    property ShowMonitorName: Boolean read FShowMonitorName write SetShowMonitorName;
    property ShowBrightnessPercent: Boolean read FShowBrightnessPercent write SetShowBrightnessPercent;

    property OnChangeLevel: TBrightnessChangeLevelEvent read FOnChangeLevel write FOnChangeLevel;
    property OnChangeActive: TBrightnessChangeActiveEvent read FOnChangeActive write FOnChangeActive;
    property OnChangeEnable: TBrightnessChangeEnableEvent read FOnChangeEnable write FOnChangeEnable;
    property OnChangeAdaptiveBrightness: TBrightnessChangeAdaptiveBrightnessEvent read FOnChangeAdaptiveBrightness write FOnChangeAdaptiveBrightness;
  end;

  TBrightnessPanelComparer = class(TComparer<TBrightnessPanel>)
  public
    function Compare(const Left, Right: TBrightnessPanel): Integer; override;
  end;

  TBrightnessListPanelChangeMonitor = procedure(Sender: TObject; Monitor: IBrightnessMonitor) of object;
  
  TBrightnessListPanel = class(TPanel)
  private
    FPanels: TList<TBrightnessPanel>;
    FBrightnessManager: TBrightnessManager;
    FShowMonitorName: Boolean;
    FShowBrightnessPercent: Boolean;

    FOnChangeLevel: TBrightnessChangeLevelEvent;
    FOnChangeActive: TBrightnessChangeActiveEvent;
    FOnChangeEnable: TBrightnessChangeEnableEvent;
    FOnChangeAdaptiveBrightness: TBrightnessChangeAdaptiveBrightnessEvent;
    FOnAddMonitor: TBrightnessListPanelChangeMonitor;
    FOnRemoveMonitor: TBrightnessListPanelChangeMonitor;

    procedure SetShowBrightnessPercent(const Value: Boolean);
    procedure SetShowMonitorName(const Value: Boolean);
  protected
    procedure BrightnessManagerNotify(Sender: TObject;
      const Item: IBrightnessMonitor; Action: TCollectionNotification);

    procedure PanelChangeActive(Sender: IBrightnessMonitor; Active: Boolean);
    procedure PanelChangeLevel(Sender: IBrightnessMonitor; NewLevel: Integer);
    procedure PanelChangeEnable(Sender: IBrightnessMonitor; Enable: Boolean);
    procedure PanelChangeAdaptiveBrightness(Sender: IBrightnessMonitor; AdaptiveBrightness: Boolean);

    procedure AddMonitor(Monitor: IBrightnessMonitor);
    procedure RemoveMonitor(Monitor: IBrightnessMonitor);
    procedure SortMonitors;

    procedure FixSize;
    procedure UpdateShapes;
  public
    constructor Create(AOwner: TComponent; BrightnessManager: TBrightnessManager); reintroduce;
    destructor Destroy; override;

    property ShowMonitorName: Boolean read FShowMonitorName write SetShowMonitorName;
    property ShowBrightnessPercent: Boolean read FShowBrightnessPercent write SetShowBrightnessPercent;

    property OnAddMonitor: TBrightnessListPanelChangeMonitor read FOnAddMonitor write FOnAddMonitor;
    property OnRemoveMonitor: TBrightnessListPanelChangeMonitor read FOnRemoveMonitor write FOnRemoveMonitor;
    
    property OnChangeLevel: TBrightnessChangeLevelEvent read FOnChangeLevel write FOnChangeLevel;
    property OnChangeActive: TBrightnessChangeActiveEvent read FOnChangeActive write FOnChangeActive;
    property OnChangeEnable: TBrightnessChangeEnableEvent read FOnChangeEnable write FOnChangeEnable;
    property OnChangeAdaptiveBrightness: TBrightnessChangeAdaptiveBrightnessEvent read FOnChangeAdaptiveBrightness write FOnChangeAdaptiveBrightness;
  end;

implementation

{ TBrightnessTrackBar }

constructor TBrightnessTrackBar.Create(AOwner: TComponent; const Monitor: IBrightnessMonitor);
begin
  inherited Create(AOwner);

  FUpdateLocker := TLocker.Create;

  FMonitor := Monitor;
  FMonitor.OnChangeLevel := MonitorChangeLevel;

  FUpdateLocker.Lock;
  try
    Align := alClient;
    AlignWithMargins := True;
    Margins.SetBounds(0, 1, 0, 0);
    Min := 0;
    Max := FMonitor.Levels.Count - 1;
    Position := FMonitor.Level;
    Hint := FMonitor.Levels[FMonitor.Level].ToString + '%';
    ShowSelRange := False;
    TickStyle := tsNone;
    ThumbLength := 22;
    PositionToolTip := ptTop;
    DirectDrag := True;
  finally
    FUpdateLocker.Unlock;
  end;
end;

procedure TBrightnessTrackBar.MonitorChangeLevel(Sender: IBrightnessMonitor; NewLevel: Integer);
begin
  FUpdateLocker.Lock;
  try
    Position := NewLevel;
  finally
    FUpdateLocker.Unlock;
  end;

  if Assigned(FOnChangeLevel) then
    FOnChangeLevel(Sender, NewLevel);
end;

procedure TBrightnessTrackBar.Changed;
begin
  if FUpdateLocker.IsLocked then Exit;

  inherited;
  FMonitor.Level := Position;
end;

procedure TBrightnessTrackBar.DoToolTipText(Sender: TObject; var Text: string);
var
  Brightness: Byte;
begin
  with FMonitor do begin
    try
      Brightness := NormalizedBrightness[SendMessage(WindowHandle, TBM_GETPOS, 0, 0)];
      if Brightness > 100 then
        Hint := ''
      else
        Hint := Brightness.ToString + '%';
      Text := Hint;
    except
      Hint := '';
      Text := '';
    end;
  end;
  inherited;
end;

procedure TBrightnessTrackBar.CNHScroll(var Msg: TWMHScroll);
begin
  if FMonitor.SlowMonitor then begin
    if (Msg.ScrollCode = TB_ENDTRACK) or (Msg.ScrollCode = TB_THUMBTRACK) then
    begin
      Msg.Result := 0;
      Exit;
    end;
  end;

  inherited;
end;

procedure TBrightnessTrackBar.CNVScroll(var Msg: TWMVScroll);
begin
  if FMonitor.SlowMonitor then begin
    if (Msg.ScrollCode = TB_ENDTRACK) or (Msg.ScrollCode = TB_THUMBTRACK) then
    begin
      Msg.Result := 0;
      Exit;
    end;
  end;

  inherited;
end;

{ TBrightnessImage }

constructor TBrightnessImage.Create(AOwner: TComponent;
  const Monitor: IBrightnessMonitor);
begin
  inherited Create(AOwner);

  FMonitor := Monitor;
  FMonitor.OnChangeActive := MonitorChangeActive;
  FMonitor.OnChangeAdaptiveBrightness := MonitorChangeAdaptiveBrightness;

  Align := alLeft;
  AlignWithMargins := True;
  AutoSize := True;
  Margins.SetBounds(3, 4, 3, 0);
  Picture.Icon.Handle := LoadIconDpi(HInstance,
    LPCTSTR(MonitorIconName[FMonitor.Active, FMonitor.AdaptiveBrightness, FMonitor.MonitorType]));
  if FMonitor.AdaptiveBrightnessAvalible then
  begin
    if FMonitor.AdaptiveBrightness then Hint := TLang[31] else Hint := TLang[30];
  end
  else
    Hint := FMonitor.Description;
  ShowHint := True;
end;

destructor TBrightnessImage.Destroy;
begin
  DestroyIcon(Picture.Icon.Handle);
  inherited;
end;

procedure TBrightnessImage.ChangeScale(M, D: Integer; isDpiChange: Boolean);
begin
  inherited;

  DestroyIcon(Picture.Icon.Handle);
  Picture.Icon.Handle := LoadIconDpi(HInstance,
    LPCTSTR(MonitorIconName[FMonitor.Active,
      FMonitor.AdaptiveBrightness, FMonitor.MonitorType]));
end;

procedure TBrightnessImage.Click;
begin
  if FMonitor.MonitorType = bmtInternal then
    FMonitor.AdaptiveBrightness := not FMonitor.AdaptiveBrightness
  else
    FMonitor.Active := not FMonitor.Active;
  inherited;
end;

procedure TBrightnessImage.MonitorChangeActive(Sender: IBrightnessMonitor;
  Active: Boolean);
begin
  DestroyIcon(Picture.Icon.Handle);
  Picture.Icon.Handle := LoadIconDpi(HInstance,
    LPCTSTR(MonitorIconName[Active, FMonitor.AdaptiveBrightness, FMonitor.MonitorType]));

  if Assigned(FOnChangeActive) then
    FOnChangeActive(Sender, Active);
end;

procedure TBrightnessImage.MonitorChangeAdaptiveBrightness(
  Sender: IBrightnessMonitor; AdaptiveBrightness: Boolean);
begin
  DestroyIcon(Picture.Icon.Handle);
  Picture.Icon.Handle := LoadIconDpi(HInstance,
    LPCTSTR(MonitorIconName[FMonitor.Active, AdaptiveBrightness, FMonitor.MonitorType]));

  if Assigned(FOnChangeAdaptiveBrightness) then
    FOnChangeAdaptiveBrightness(Sender, AdaptiveBrightness);

  if FMonitor.AdaptiveBrightnessAvalible then
  begin
    if FMonitor.AdaptiveBrightness then Hint := TLang[31] else Hint := TLang[30];
  end
  else
    Hint := FMonitor.Description;
end;

function TBrightnessImage.LoadIconDpi(hInstance: HINST; lpIconName: LPCTSTR): HICON;
var
  Icon: HICON;
  PPI: Integer;
begin
  PPI := GetCurrentPPI;
  Icon := LoadIcon(hInstance, lpIconName);
  try
    if PPI <= 96 then
      Exit(CopyImage(Icon, IMAGE_ICON, 16, 16, LR_COPYFROMRESOURCE));

    if PPI <= 120 then
      Exit(CopyImage(Icon, IMAGE_ICON, 22, 22, LR_COPYFROMRESOURCE));

    if PPI <= 144 then
      Exit(CopyImage(Icon, IMAGE_ICON, 28, 28, LR_COPYFROMRESOURCE));

    Result := CopyImage(Icon, IMAGE_ICON, 28, 28, LR_COPYFROMRESOURCE);
  finally
    DestroyIcon(Icon);
  end;
end;


{ TBrightnessPanel }

constructor TBrightnessPanel.Create(AOwner: TComponent; const Monitor: IBrightnessMonitor);
var
  Brightness: Byte;
  PPI: Integer;
begin
  inherited Create(AOwner);

  FMonitor := Monitor;
  FMonitor.OnChangeEnable := MonitorChangeEnable;

  FTrackBarPanel := TPanel.Create(Self);
  FTrackBarPanel.Align := alClient;
  FTrackBarPanel.BevelInner := bvNone;
  FTrackBarPanel.BevelOuter := bvNone;
  FTrackBarPanel.Parent := Self;

  FTrackBar := TBrightnessTrackBar.Create(FTrackBarPanel, FMonitor);
  FTrackBar.Parent := FTrackBarPanel;
  FTrackBar.OnChangeLevel := TrackBarChangeLevel;

  FImageLow := TBrightnessImage.Create(Self, FMonitor);
  FImageLow.Parent := Self;
  FImageLow.OnChangeActive := ImageChangeActive;
  FImageLow.OnChangeAdaptiveBrightness := ImageChangeAdaptiveBrightness;

  FValueLabel := TLabel.Create(Self);
  FValueLabel.Align := alRight;
  FValueLabel.AlignWithMargins := True;
  FValueLabel.Margins.SetBounds(3, 0, 0, 0);
  FValueLabel.AutoSize := False;
  FValueLabel.Layout := tlCenter;
  with FMonitor do begin
    Brightness := NormalizedBrightness[Level];
    if Brightness > 100 then
      FValueLabel.Caption := ''
    else
      FValueLabel.Caption := Brightness.ToString + '%';
  end;
  FValueLabel.Width := 28;
  FValueLabel.Visible := False;
  FValueLabel.Parent := Self;

  PPI := GetCurrentPPI;

  FMonitorNameLabel := TLabel.Create(FTrackBarPanel);
  FMonitorNameLabel.Align := alTop;
  FMonitorNameLabel.AlignWithMargins := True;
  FMonitorNameLabel.Alignment := taCenter;
  FMonitorNameLabel.Margins.SetBounds(0, 4, 0, 0);
  FMonitorNameLabel.EllipsisPosition := epEndEllipsis;
  FMonitorNameLabel.Caption := FMonitor.Description;
  FMonitorNameLabel.Visible := False;
  if PPI <= 96 then FMonitorNameLabel.Font.Name := 'Microsoft Sans Serif';
  FMonitorNameLabel.Font.Height := MulDiv(12, PPI, 96);
  FMonitorNameLabel.Parent := FTrackBarPanel;

  Align := alTop;
  BevelOuter := bvNone;
  Padding.Left := 16;
  Padding.Right := 12;
  Height := BaseHeight;
  Visible := FMonitor.Enable;
end;

destructor TBrightnessPanel.Destroy;
begin
  FTrackBarPanel.RemoveControl(FTrackBar);
  FTrackBar.Free;
  FTrackBarPanel.RemoveControl(FMonitorNameLabel);
  FMonitorNameLabel.Free;
  RemoveControl(FTrackBarPanel);
  FTrackBarPanel.Free;

  RemoveControl(FImageLow);
  FImageLow.Free;
  RemoveControl(FValueLabel);
  FValueLabel.Free;

  inherited;
end;

procedure TBrightnessPanel.ChangeScale(M, D: Integer; isDpiChange: Boolean);
begin
  inherited;
  if M <= 96 then
    FMonitorNameLabel.Font.Name := 'Microsoft Sans Serif'
  else
    FMonitorNameLabel.Font.Name := Font.Name;

  FMonitorNameLabel.Font.Height := MulDiv(12, M, 96);
end;

procedure TBrightnessPanel.SetParent(AParent: TWinControl);
begin
  inherited;
  FTrackBarPanel.Realign;
end;

procedure TBrightnessPanel.SetShowMonitorName(const Value: Boolean);
var
  PPI: Integer;
begin
  PPI := GetCurrentPPI;
  FShowMonitorName := Value;
  FMonitorNameLabel.Visible := Value;
  if Value then
  begin
    Height := MulDiv(BaseHeight + 6, PPI, 96) + FMonitorNameLabel.ExplicitHeight;
    FImageLow.Margins.SetBounds(
      MulDiv(3, PPI, 96),
      (Height - FImageLow.Picture.Height) div 2,
      MulDiv(3, PPI, 96),
      0);
    FTrackBar.Margins.Bottom := 1;
  end
  else
  begin
    Height := MulDiv(BaseHeight, PPI, 96);
    FImageLow.Margins.SetBounds(
      MulDiv(3, PPI, 96),
      MulDiv(4, PPI, 96),
      MulDiv(3, PPI, 96),
      0);
    FTrackBar.Margins.Bottom := 0;
  end;
end;

procedure TBrightnessPanel.SetShowBrightnessPercent(const Value: Boolean);
begin
  FShowBrightnessPercent := Value;
  FValueLabel.Visible := Value;
end;

procedure TBrightnessPanel.MonitorChangeEnable(Sender: IBrightnessMonitor;
  Enable: Boolean);
begin
  Visible := Enable;

  if Assigned(FOnChangeEnable) then
    FOnChangeEnable(Sender, Enable);
end;

procedure TBrightnessPanel.ImageChangeActive(Sender: IBrightnessMonitor;
  Active: Boolean);
begin
  if Assigned(FOnChangeActive) then
    FOnChangeActive(Sender, Active);
end;

procedure TBrightnessPanel.ImageChangeAdaptiveBrightness(
  Sender: IBrightnessMonitor; AdaptiveBrightness: Boolean);
begin
  if Assigned(FOnChangeAdaptiveBrightness) then
    FOnChangeAdaptiveBrightness(Sender, AdaptiveBrightness);
end;

procedure TBrightnessPanel.TrackBarChangeLevel(Sender: IBrightnessMonitor;
  NewLevel: Integer);
var
  Brightness: Byte;
begin
  if Assigned(FOnChangeLevel) then
    FOnChangeLevel(Sender, NewLevel);

  with FMonitor do begin
    Brightness := NormalizedBrightness[Level];
    if Brightness > 100 then
      FValueLabel.Caption := ''
    else
      FValueLabel.Caption := Brightness.ToString + '%';
  end;
end;


{ TBrightnessPanelComparer }

function TBrightnessPanelComparer.Compare(const Left,
  Right: TBrightnessPanel): Integer;
begin
  Result := TBrightnessMonitorComparer.Create.Compare(Left.BrightnessMonitor, Right.BrightnessMonitor);
end;


{ TBrightnessListPanel }

constructor TBrightnessListPanel.Create(AOwner: TComponent; BrightnessManager: TBrightnessManager);
var
  Monitor: IBrightnessMonitor;
begin
  inherited Create(AOwner);

  FPanels := TList<TBrightnessPanel>.Create;
  FBrightnessManager := BrightnessManager;
  BrightnessManager.OnNotify := BrightnessManagerNotify;

  Align := alTop;
  BevelOuter := bvNone;
  Padding.Top := 4;
  Padding.Bottom := 4;
  Shape := psBottomLine;
  Style := tfpsBrightness;
  Height := 0;

  for Monitor in FBrightnessManager do
    AddMonitor(Monitor);
end;

destructor TBrightnessListPanel.Destroy;
begin
  FPanels.Free;
  inherited Destroy;
end;

procedure TBrightnessListPanel.SetShowBrightnessPercent(const Value: Boolean);
var
  Panel: TBrightnessPanel;
begin
  FShowBrightnessPercent := Value;
  for Panel in FPanels do Panel.ShowBrightnessPercent := Value;
end;

procedure TBrightnessListPanel.SetShowMonitorName(const Value: Boolean);
var
  Panel: TBrightnessPanel;
begin
  FShowMonitorName := Value;
  for Panel in FPanels do Panel.ShowMonitorName := Value;

  UpdateShapes;

  if Value then
    Padding.SetBounds(0, 0, 0, 0)
  else
    Padding.SetBounds(0, MulDiv(4, GetCurrentPPI, 96), 0, MulDiv(4, GetCurrentPPI, 96));
end;

procedure TBrightnessListPanel.BrightnessManagerNotify(Sender: TObject;
  const Item: IBrightnessMonitor; Action: TCollectionNotification);
begin
  case Action of
    cnAdded: AddMonitor(Item);
    cnRemoved: RemoveMonitor(Item);
  end;
end;

procedure TBrightnessListPanel.PanelChangeActive(Sender: IBrightnessMonitor;
  Active: Boolean);
begin
  if Assigned(FOnChangeActive) then
    FOnChangeActive(Sender, Active);
end;

procedure TBrightnessListPanel.PanelChangeLevel(Sender: IBrightnessMonitor;
  NewLevel: Integer);
begin
  if Assigned(FOnChangeLevel) then
    FOnChangeLevel(Sender, NewLevel);
end;

procedure TBrightnessListPanel.PanelChangeEnable(Sender: IBrightnessMonitor;
  Enable: Boolean);
begin
  FixSize;
  SortMonitors;
  UpdateShapes;
  
  if Assigned(FOnChangeEnable) then
    FOnChangeEnable(Sender, Enable);
end;

procedure TBrightnessListPanel.PanelChangeAdaptiveBrightness(
  Sender: IBrightnessMonitor; AdaptiveBrightness: Boolean);
begin
  if Assigned(FOnChangeAdaptiveBrightness) then
    FOnChangeAdaptiveBrightness(Sender, AdaptiveBrightness);
end;

procedure TBrightnessListPanel.AddMonitor(Monitor: IBrightnessMonitor);
var
  Panel: TBrightnessPanel;
begin
  AutoSize := False;
  Panel := TBrightnessPanel.Create(Self, Monitor);
  Panel.ShowMonitorName := FShowMonitorName;
  Panel.ShowBrightnessPercent := FShowBrightnessPercent;
  Panel.Parent := Self;
  Panel.OnChangeLevel := PanelChangeLevel;
  Panel.OnChangeActive := PanelChangeActive;
  Panel.OnChangeEnable := PanelChangeEnable;
  Panel.OnChangeAdaptiveBrightness := PanelChangeAdaptiveBrightness;
  FPanels.Add(Panel);

  if FPanels.Count > 1 then
    Panel.Top := FPanels.Last.Top + FPanels.Last.Height;

  FixSize;
  AutoSize := True;
  SortMonitors;
  UpdateShapes;
  Visible := FPanels.Count > 0;

  if Assigned(FOnAddMonitor) then
    FOnAddMonitor(Self, Monitor);
end;

procedure TBrightnessListPanel.RemoveMonitor(Monitor: IBrightnessMonitor);
var
  Panel: TBrightnessPanel;
begin
  AutoSize := False;
  for Panel in FPanels do
    if Panel.BrightnessMonitor = Monitor then
    begin
      RemoveControl(Panel);
      FPanels.Remove(Panel);
      Panel.Free;
      Break;
    end;

  FixSize;
  AutoSize := True;
  UpdateShapes;
  Visible := FPanels.Count > 0;

  if Assigned(FOnRemoveMonitor) then
    FOnRemoveMonitor(Self, Monitor);
end;

procedure TBrightnessListPanel.SortMonitors;
var
  I: Integer;
begin
  FPanels.Sort(TBrightnessPanelComparer.Create);

  if FPanels.Count = 0 then Exit;

  with FPanels[0] do
  begin
    Top := 0;
    TabOrder := 0;
  end;

  for I := 1 to FPanels.Count - 1 do
  begin
    with FPanels do
    begin
      if Items[i].Top <> Items[i - 1].Top + Items[i - 1].Height then
        Items[i].Top := Items[i - 1].Top + Items[i - 1].Height;
      Items[i].TabOrder := I;
    end;
  end;
end;

procedure TBrightnessListPanel.FixSize;
var
  Panel: TBrightnessPanel;
  NewHeight: Integer;
begin
  NewHeight := Padding.Top + Padding.Bottom;
  for Panel in FPanels do
    if Panel.Visible then
      NewHeight := NewHeight + Panel.Height;
  Height := NewHeight;

  Top := -1;
end;

procedure TBrightnessListPanel.UpdateShapes;
var
  I: Integer;
begin
  for I := 0 to FPanels.Count - 2 do
  begin
    if FShowMonitorName then
    begin
      FPanels[I].Shape := psBottomLine;
      FPanels[I].Style := tfpsBrightness;
    end
    else
    begin
      FPanels[I].Shape := psNone;
      FPanels[I].Style := tfpsDefault;
    end;
  end;

  if FPanels.Count > 0 then
    FPanels.Last.Shape := psNone;
end;

end.
