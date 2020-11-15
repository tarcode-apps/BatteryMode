unit AutoUpdate.Window.NotFound;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  AutoUpdate.Window.Notify,
  Core.Language,
  Core.UI, Core.UI.Controls,
  Versions.Info;

type
  TNotFoundWindow = class(TAutoUpdateNotifyWindow)
    LabelMessage: TLabel;
    PanelBottom: TPanel;
    CloseButton: TButton;
    Image: TImage;
    LabelTitle: TLabel;
    PanelImage: TPanel;
    PanelInfo: TPanel;
    procedure FormAfterMonitorDpiChanged(Sender: TObject; OldDPI,
      NewDPI: Integer);
    procedure FormBeforeMonitorDpiChanged(Sender: TObject; OldDPI,
      NewDPI: Integer);
  protected
    procedure ApplySize;
    procedure LoadIcon;
    procedure Loadlocalization;
    procedure DoCreate; override;
  end;

implementation

{$R *.dfm}

{ TUnreadMessageForm }

procedure TNotFoundWindow.DoCreate;
begin
  inherited;

  LabelTitle.Font.Name := Font.Name;

  PanelBottom.Shape := psTopLine;

  Loadlocalization;
  LoadIcon;

  ApplySize;
end;

procedure TNotFoundWindow.ApplySize;
var
  WidthSelector: ISizeSelector;
  HeightSelector: ISizeSelector;
  WidthAccumulator: ISizeAccumulator;
  HeightAccumulator: ISizeAccumulator;
begin
  // Значок
  WidthAccumulator := TWidthAccumulator.Create;
  WidthAccumulator.AddPadding(PanelImage);
  WidthAccumulator.AddControl(Image);
  PanelImage.ClientWidth := WidthAccumulator.Size;

  // Вычисление максимальной ширины
  WidthSelector := TWidthSelector.Create(PanelImage.Margins.ExplicitWidth);
  WidthSelector.AddPadding(PanelInfo);

  with LabelTitle do
  begin
    Canvas.Font := Font;
    WidthSelector.SelectWithMargins(Canvas.TextWidth(Caption), LabelTitle);
  end;

  with LabelMessage do
  begin
    Canvas.Font := Font;
    WidthSelector.SelectWithMargins(Canvas.TextWidth(Caption), LabelMessage);
  end;

  ClientWidth := WidthSelector.Size;

  // Вычисление максимальной высоты
  HeightAccumulator := THeightAccumulator.Create;
  HeightAccumulator.AddPadding(PanelInfo);
  HeightAccumulator.AddControl(LabelTitle);
  HeightAccumulator.AddControl(LabelMessage);

  HeightSelector := THeightSelector.Create;
  HeightSelector.AddControl(PanelBottom);
  HeightSelector.SelectWithMargins(Image.Width + PanelImage.Padding.Top + PanelImage.Padding.Bottom, Image);
  HeightSelector.Select(HeightAccumulator.Size);

  ClientHeight := HeightSelector.Size;
end;

procedure TNotFoundWindow.LoadIcon;
var
  hIco: HICON;
begin
  case GetCurrentPPI of
    0..96:    hIco := CopyImage(Application.Icon.Handle, IMAGE_ICON, 32, 32, LR_COPYFROMRESOURCE);
    97..120:  hIco := CopyImage(Application.Icon.Handle, IMAGE_ICON, 40, 40, LR_COPYFROMRESOURCE);
    121..144: hIco := CopyImage(Application.Icon.Handle, IMAGE_ICON, 48, 48, LR_COPYFROMRESOURCE);
    145..192: hIco := CopyImage(Application.Icon.Handle, IMAGE_ICON, 64, 64, LR_COPYFROMRESOURCE);
    else      hIco := CopyImage(Application.Icon.Handle, IMAGE_ICON, 80, 80, LR_COPYFROMRESOURCE);
  end;
  DestroyIcon(Image.Picture.Icon.Handle);
  Image.Picture.Icon.Handle := hIco;
end;

procedure TNotFoundWindow.Loadlocalization;
begin
  Caption := TLang[900];

  LabelTitle.Caption := TLang[907];
  LabelMessage.Caption := Format(TLang[908], [TLang[1], TVersionInfo.FileVersion.ToString]);

  CloseButton.Caption := TLang[909];
end;

procedure TNotFoundWindow.FormAfterMonitorDpiChanged(Sender: TObject; OldDPI,
  NewDPI: Integer);
begin
  AutoSize := True;
  LoadIcon;
end;

procedure TNotFoundWindow.FormBeforeMonitorDpiChanged(Sender: TObject; OldDPI,
  NewDPI: Integer);
begin
  AutoSize := False;
end;

end.
