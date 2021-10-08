unit RenameMonitor.Window;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs,
  Vcl.StdCtrls, Vcl.ExtCtrls,
  Brightness,
  Core.Language,
  Core.UI, Core.UI.Controls,
  Versions.Helpers;

type
  TRenameMonitorWindow = class(TCompatibleForm)
    PanelControl: TPanel;
    ButtonCancel: TButton;
    ButtonApply: TButton;
    MonitorPanel: TPanel;
    FriendlyNameLabel: TLabel;
    FriendlyNameEdit: TEdit;
    RevertLink: TStaticText;
    RevertPanel: TPanel;
    procedure RevertLinkClick(Sender: TObject);
    procedure ButtonApplyClick(Sender: TObject);
  strict private
    FParentHandle: THandle;
    FMonitor: IBrightnessMonitor;
    procedure Loadlocalization;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure KeyPress(var Key: Char); override;
    procedure DoClose(var Action: TCloseAction); override;
  public
    constructor Create(AOwner: TComponent; Monitor: IBrightnessMonitor; ParentHandle: THandle); reintroduce;
  end;

implementation

{$R *.dfm}

{ TRenameMonitorWindow }

constructor TRenameMonitorWindow.Create(AOwner: TComponent;
  Monitor: IBrightnessMonitor; ParentHandle: THandle);
begin
  FParentHandle := ParentHandle;
  FMonitor := Monitor;
  inherited Create(AOwner);

  PanelControl.Shape := psTopLine;
  RevertLink.LinkMode := True;

  FriendlyNameEdit.Text := Monitor.EffectiveName;

  Loadlocalization;

  if IsWindows10OrGreater then Color := clWindow;
end;

procedure TRenameMonitorWindow.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.WndParent := FParentHandle;
  if FParentHandle = 0 then
    Params.ExStyle := Params.ExStyle or WS_EX_APPWINDOW;
end;

procedure TRenameMonitorWindow.KeyPress(var Key: Char);
begin
  inherited;
  if Key =  Char(VK_ESCAPE) then Close;
end;

procedure TRenameMonitorWindow.DoClose(var Action: TCloseAction);
begin
  inherited;
  Action := caFree;
end;

procedure TRenameMonitorWindow.RevertLinkClick(Sender: TObject);
begin
  FriendlyNameEdit.Text := FMonitor.Description;
  FriendlyNameEdit.SelectAll;
end;

procedure TRenameMonitorWindow.ButtonApplyClick(Sender: TObject);
begin
  if FriendlyNameEdit.Text <> FMonitor.Description then
    FMonitor.FriendlyName := FriendlyNameEdit.Text
  else
    FMonitor.FriendlyName := '';
end;

procedure TRenameMonitorWindow.Loadlocalization;
begin
  Caption := TLang[2100]; // Rename monitor
  FriendlyNameLabel.Caption := string.Format(TLang[2101], [FMonitor.Description]); // New name for %0:s
  RevertLink.Caption := TLang[2102]; // Revert original name
  ButtonApply.Caption   := TLang[2000]; // Apply
  ButtonCancel.Caption  := TLang[2001]; // Cancel
end;

end.
