unit IconColorLevels.Window;

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.CommCtrl,
  System.SysUtils, System.Variants, System.Classes, System.Math,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls,
  Icon.Renderers,
  Core.Language,
  Core.UI, Core.UI.Controls,
  Versions.Helpers, Vcl.ComCtrls;

type
  TIconColorLevelsWindow = class(TForm)
    PanelControl: TPanel;
    ButtonCancel: TButton;
    ButtonApply: TButton;
    LevelsPanel: TPanel;
    LowLevelPanel: TPanel;
    LowLevelLabel: TLabel;
    LowLevelEdit: TEdit;
    LowLevelUpDown: TUpDown;
    LowLevelPercentLabel: TLabel;
    MidLevelPanel: TPanel;
    MidLevelLabel: TLabel;
    MidLevelPercentLabel: TLabel;
    MidLevelEdit: TEdit;
    MidLevelUpDown: TUpDown;
    HighLevelPanel: TPanel;
    HighLevelLabel: TLabel;
    ChargerCriticalLevelPanel: TPanel;
    ChargerCriticalLevelLabel: TLabel;
    ChargerCriticalLevelPercentLabel: TLabel;
    ChargerCriticalLevelEdit: TEdit;
    ChargerCriticalLevelUpDown: TUpDown;
    ResetPanel: TPanel;
    ResetLink: TStaticText;
    procedure ChargerCriticalLevelEditExit(Sender: TObject);
    procedure ChargerCriticalLevelEditChange(Sender: TObject);
    procedure LowLevelEditExit(Sender: TObject);
    procedure LowLevelEditChange(Sender: TObject);
    procedure LowLevelUpDownChangingEx(Sender: TObject;
      var AllowChange: Boolean; NewValue: Integer; Direction: TUpDownDirection);
    procedure MidLevelEditExit(Sender: TObject);
    procedure MidLevelEditChange(Sender: TObject);
    procedure MidLevelUpDownChangingEx(Sender: TObject;
      var AllowChange: Boolean; NewValue: Integer; Direction: TUpDownDirection);
    procedure ButtonApplyClick(Sender: TObject);
    procedure ResetLinkClick(Sender: TObject);
  strict private
    FParentHandle: THandle;
    FIconOptions: TIconsOptions;
    FLastChargerCriticalLevel: Byte;
    FLastLowLevel: Byte;
    FLastMidLevel: Byte;
    FLocker: ILocker;
    FModifyCollector: IModifyCollector;
    procedure Loadlocalization;
    procedure UpdateLabels(ForceRealign: Boolean = False);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure KeyPress(var Key: Char); override;
    procedure DoClose(var Action: TCloseAction); override;
  public
    constructor Create(AOwner: TComponent; IconOptions: TIconsOptions; ParentHandle: THandle); reintroduce;
  end;

implementation

{$R *.dfm}

{ TIconColorLevelsWindow }

constructor TIconColorLevelsWindow.Create(AOwner: TComponent;
  IconOptions: TIconsOptions; ParentHandle: THandle);
var
  Accumulator: ISizeAccumulator;
begin
  FParentHandle := ParentHandle;
  FIconOptions := IconOptions;
  FLastChargerCriticalLevel := IconOptions.IconColorChargerLevelCritical;
  FLastLowLevel := IconOptions.IconColorLevelLow;
  FLastMidLevel := IconOptions.IconColorLevelMid;

  inherited Create(AOwner);

  FModifyCollector := TModifyCollector.Create;

  PanelControl.Shape := psTopLine;
  ResetLink.LinkMode := True;

  Accumulator := THeightAccumulator.Create;
  Accumulator.AddPadding(LevelsPanel);
  Accumulator.AddControl(ResetPanel);

  FLocker := TLocker.Create(True);

  if FIconOptions.IconColorType = ictCharger then begin
    LowLevelPanel.Visible := False;
    MidLevelPanel.Visible := False;
    HighLevelPanel.Visible := False;
    Accumulator.AddControl(ChargerCriticalLevelPanel);

    ChargerCriticalLevelUpDown.Position := FIconOptions.IconColorChargerLevelCritical;
  end else begin
    ChargerCriticalLevelPanel.Visible := False;
    Accumulator.AddControl(LowLevelPanel);
    Accumulator.AddControl(MidLevelPanel);
    Accumulator.AddControl(HighLevelPanel);

    MidLevelUpDown.Position := FIconOptions.IconColorLevelMid;
    LowLevelUpDown.Position := FIconOptions.IconColorLevelLow;
  end;

  LevelsPanel.Height := Accumulator.Size;

  Loadlocalization;
  UpdateLabels;
  FLocker.Unlock;

  if IsWindows10OrGreater then Color := clWindow;
end;

procedure TIconColorLevelsWindow.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.WndParent := FParentHandle;
  if FParentHandle = 0 then
    Params.ExStyle := Params.ExStyle or WS_EX_APPWINDOW;
end;

procedure TIconColorLevelsWindow.KeyPress(var Key: Char);
begin
  inherited;
  if Key =  Char(VK_ESCAPE) then Close;
end;

procedure TIconColorLevelsWindow.ButtonApplyClick(Sender: TObject);
begin
  FModifyCollector.UnModify;
end;

procedure TIconColorLevelsWindow.ChargerCriticalLevelEditChange(Sender: TObject);
var
  NewValue: Integer;
begin
  if FLocker.IsLocked then Exit;
  if not Integer.TryParse(TEdit(Sender).Text, NewValue) then Exit;

  if NewValue < ChargerCriticalLevelUpDown.Min then
    NewValue := ChargerCriticalLevelUpDown.Min;

  if NewValue > ChargerCriticalLevelUpDown.Max then
    NewValue := ChargerCriticalLevelUpDown.Max;

  FIconOptions.IconColorChargerLevelCritical := Byte(NewValue);
  FModifyCollector.Modify;
  UpdateLabels;
end;

procedure TIconColorLevelsWindow.ChargerCriticalLevelEditExit(Sender: TObject);
begin
  TEdit(Sender).Text := FIconOptions.IconColorChargerLevelCritical.ToString;
end;

procedure TIconColorLevelsWindow.LowLevelEditChange(Sender: TObject);
var
  NewValue: Integer;
begin
  if FLocker.IsLocked then Exit;
  if not Integer.TryParse(TEdit(Sender).Text, NewValue) then Exit;

  if NewValue < LowLevelUpDown.Min then
    NewValue := LowLevelUpDown.Min;

  if NewValue > LowLevelUpDown.Max then
    NewValue := LowLevelUpDown.Max;

  FIconOptions.IconColorLevelLow := Byte(NewValue);
  FModifyCollector.Modify;

  UpdateLabels(True);
end;

procedure TIconColorLevelsWindow.LowLevelEditExit(Sender: TObject);
begin
  TEdit(Sender).Text := FIconOptions.IconColorLevelLow.ToString;

  if FIconOptions.IconColorLevelLow > FIconOptions.IconColorLevelMid then
    MidLevelUpDown.Position := FIconOptions.IconColorLevelLow;
end;

procedure TIconColorLevelsWindow.LowLevelUpDownChangingEx(Sender: TObject;
  var AllowChange: Boolean; NewValue: Integer; Direction: TUpDownDirection);
begin
  if FLocker.IsLocked then Exit;
  if NewValue > FIconOptions.IconColorLevelMid then
    MidLevelUpDown.Position := NewValue;
end;

procedure TIconColorLevelsWindow.MidLevelEditChange(Sender: TObject);
var
  NewValue: Integer;
begin
  if FLocker.IsLocked then Exit;
  if not Integer.TryParse(TEdit(Sender).Text, NewValue) then Exit;

  if NewValue < MidLevelUpDown.Min then
    NewValue := MidLevelUpDown.Min;

  if NewValue > MidLevelUpDown.Max then
    NewValue := MidLevelUpDown.Max;

  FIconOptions.IconColorLevelMid := Byte(NewValue);
  FModifyCollector.Modify;

  UpdateLabels;
end;

procedure TIconColorLevelsWindow.MidLevelEditExit(Sender: TObject);
begin
  TEdit(Sender).Text := FIconOptions.IconColorLevelMid.ToString;

  if FIconOptions.IconColorLevelMid < FIconOptions.IconColorLevelLow then
    LowLevelUpDown.Position := FIconOptions.IconColorLevelMid;
end;

procedure TIconColorLevelsWindow.MidLevelUpDownChangingEx(Sender: TObject;
  var AllowChange: Boolean; NewValue: Integer; Direction: TUpDownDirection);
begin
  if FLocker.IsLocked then Exit;
  if (NewValue > TUpDown(Sender).Max) or (NewValue < TUpDown(Sender).Min) then begin
    AllowChange := False;
    Exit;
  end;

  if NewValue < FIconOptions.IconColorLevelLow then
    LowLevelUpDown.Position := NewValue;
end;

procedure TIconColorLevelsWindow.ResetLinkClick(Sender: TObject);
begin
  FLocker.Lock;
  try
    if FIconOptions.IconColorType = ictCharger then begin
      FIconOptions.IconColorChargerLevelCritical := FIconOptions.DefaultIconColorChargerLevelCritical;
      ChargerCriticalLevelUpDown.Position := FIconOptions.IconColorChargerLevelCritical;
      UpdateLabels;
    end else begin
      FIconOptions.IconColorLevelLow := FIconOptions.DefaultIconColorLevelLow;
      FIconOptions.IconColorLevelMid := FIconOptions.DefaultIconColorLevelMid;
      MidLevelUpDown.Position := FIconOptions.IconColorLevelMid;
      LowLevelUpDown.Position := FIconOptions.IconColorLevelLow;
      UpdateLabels(True);
    end;
  finally
    FLocker.Unlock;
  end;
end;

procedure TIconColorLevelsWindow.DoClose(var Action: TCloseAction);
begin
  inherited;
  Action := caFree;

  if (FModifyCollector.IsModify) then begin
    if FIconOptions.IconColorType = ictCharger then begin
      FIconOptions.IconColorChargerLevelCritical := FLastChargerCriticalLevel;
    end else begin
      FIconOptions.IconColorLevelLow := FLastLowLevel;
      FIconOptions.IconColorLevelMid := FLastMidLevel;
    end;
  end;
end;

procedure TIconColorLevelsWindow.Loadlocalization;
begin
  Caption := TLang[2150]; // Levels
  ResetLink.Caption  := TLang[2151]; // Defaults

  ButtonApply.Caption   := TLang[2000]; // Apply
  ButtonCancel.Caption  := TLang[2001]; // Cancel
end;

procedure TIconColorLevelsWindow.UpdateLabels(ForceRealign: Boolean);
begin
  if FIconOptions.IconColorType = ictCharger then begin
    ChargerCriticalLevelLabel.Caption := string.Format(TLang[2155], [0]); // Critical
  end else begin
    LowLevelLabel.Caption := string.Format(TLang[2156], [0]); // Low
    MidLevelLabel.Caption := string.Format(TLang[2157], [Min(100, FIconOptions.IconColorLevelLow + 1)]); // Mid
    HighLevelLabel.Caption := string.Format(TLang[2158], [Min(100, FIconOptions.IconColorLevelMid + 1), 100]); // High
  end;

  if ForceRealign then begin
    MidLevelUpDown.Associate := nil;
    MidLevelUpDown.Associate := MidLevelEdit;
  end;
end;

end.
