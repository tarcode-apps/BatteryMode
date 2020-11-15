unit AutoUpdate.Window.Update;

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.ActiveX, Winapi.ShellAPI,
  System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  Vcl.OleCtrls, Vcl.ExtCtrls,
  WebBrowserEx, SHDocVw, idoc,
  AutoUpdate.Window.Notify, AutoUpdate.VersionDefinition,
  Core.Language,
  Core.UI, Core.UI.Controls,
  Versions.Info;

type
  TAutoUpdateWnd = class(TAutoUpdateNotifyWindow)
    Image: TImage;
    LabelTitle: TLabel;
    LabelMessage: TLabel;
    PanelImage: TPanel;
    PanelInfo: TPanel;
    LabelInfo: TLabel;
    PanelWeb: TPanel;
    PanelButton: TPanel;
    ButtonInstall: TButton;
    ButtonLater: TButton;
    ButtonSkip: TButton;
    PanelLater: TPanel;
    procedure FormAfterMonitorDpiChanged(Sender: TObject; OldDPI,
      NewDPI: Integer);
    procedure FormBeforeMonitorDpiChanged(Sender: TObject; OldDPI,
      NewDPI: Integer);
  private
    WebBrowser: TWebBrowserEx;
    FChangeLog: TStringStream;
    FChangeLogLoading: Boolean;

    procedure LoadIcon;
    procedure Loadlocalization;
    procedure ApplySize;
    procedure ApplyConstraitns;
    procedure ApplyWebBrowserScale;

    function WebBrowserGetHostInfo(Sender: TObject; var pInfo: _DOCHOSTUIINFO): HRESULT;
    procedure WebBrowserDocumentComplete(ASender: TObject;
      const pDisp: IDispatch; const URL: OleVariant);
    procedure WebBrowserNewWindow3(ASender: TObject; var ppDisp: IDispatch; var Cancel: WordBool;
      dwFlags: LongWord; const bstrUrlContext: WideString; const bstrUrl: WideString);
  public
    constructor Create(FileVersionInfo: TFileVersionInfo; ChangeLog: TStringStream); reintroduce;
    destructor Destroy; override;
  end;

implementation

{$R *.dfm}

{ TAutoUpdateWnd }

constructor TAutoUpdateWnd.Create(FileVersionInfo: TFileVersionInfo; ChangeLog: TStringStream);
var
  HeightAccumulator: ISizeAccumulator;
begin
  inherited Create;

  LabelTitle.Font.Name := Font.Name;
  LabelInfo.Font.Name := Font.Name;
  LabelInfo.Font.Size := Font.Size;

  LabelMessage.Caption := Format(TLang[902],
    [TLang[1], FileVersionInfo.Version.ToString, TVersionInfo.FileVersion.ToString]);

  with ButtonSkip do begin
    AutoSize := True;
    Padding.Left := 15;
    Padding.Right := 15;
  end;
  with ButtonLater do begin
    AutoSize := True;
    Padding.Left := 15;
    Padding.Right := 15;
  end;
  with ButtonInstall do begin
    AutoSize := True;
    Padding.Left := 15;
    Padding.Right := 15;
  end;

  LoadIcon;
  Loadlocalization;

  try
    if ChangeLog.Size = 0 then raise Exception.Create('No ChangeLog');

    FChangeLog := TStringStream.Create;
    FChangeLog.CopyFrom(ChangeLog, ChangeLog.Size);
    FChangeLog.Position := 0;
    FChangeLogLoading := True;

    WebBrowser := TWebBrowserEx.Create(Self);
    with WebBrowser do begin
      Align := alClient;
      ControlBorder := cbNone;
      TheaterMode := True;
      UserMode := True;
      FlatScrollBar := True;
      UseTheme := True;
      Silent := True;
      OnGetHostInfo := WebBrowserGetHostInfo;
      OnDocumentComplete := WebBrowserDocumentComplete;
      OnNewWindow3 := WebBrowserNewWindow3;
      Offline := True;

      Navigate('about:blank');
    end;
    PanelWeb.InsertControl(WebBrowser);
  except
    WebBrowser := nil;
    LabelInfo.Visible := False;
    PanelWeb.Visible := False;

    HeightAccumulator := THeightAccumulator.Create;
    HeightAccumulator.AddControl(PanelWeb);
    HeightAccumulator.AddControl(LabelInfo);
    Height := Height - HeightAccumulator.Size;
  end;
  ApplySize;
  ApplyConstraitns;
end;

destructor TAutoUpdateWnd.Destroy;
begin
  if WebBrowser <> nil then WebBrowser.Free;
  if FChangeLog <> nil then FChangeLog.Free;
  inherited Destroy;
end;

procedure TAutoUpdateWnd.LoadIcon;
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

procedure TAutoUpdateWnd.Loadlocalization;
begin
  Caption := TLang[900];

  LabelTitle.Caption := Format(TLang[901], [TLang[1]]);
  LabelInfo.Caption := TLang[903];

  ButtonSkip.Caption := TLang[904];
  ButtonLater.Caption := TLang[905];
  ButtonInstall.Caption := TLang[906];
end;

procedure TAutoUpdateWnd.WebBrowserDocumentComplete(ASender: TObject;
  const pDisp: IDispatch; const URL: OleVariant);
var
  StringList: TStringList;
  Document: Variant;
begin
  ApplyWebBrowserScale;

  if not FChangeLogLoading or (FChangeLog.DataString = '') then Exit;
  FChangeLogLoading := False;

  if not Assigned((ASender as TWebBrowserEx).Document) then Exit;
    
  StringList := TStringList.Create;
  Document := (ASender as TWebBrowserEx).Document;
  try
    StringList.LoadFromStream(FChangeLog);
    Document.Clear;
    Document.Write(string(StringList.GetText));
  finally
    Document.Close;
    StringList.Free;
  end;
end;

function TAutoUpdateWnd.WebBrowserGetHostInfo(Sender: TObject;
  var pInfo: _DOCHOSTUIINFO): HRESULT;
const
  DOCHOSTUIFLAG_DPI_AWARE = DWORD($40000000);
begin
  pInfo.dwFlags := pInfo.dwFlags or DOCHOSTUIFLAG_DPI_AWARE;
  Result := S_OK;
end;

procedure TAutoUpdateWnd.WebBrowserNewWindow3(ASender: TObject;
  var ppDisp: IDispatch; var Cancel: WordBool; dwFlags: LongWord;
  const bstrUrlContext, bstrUrl: WideString);
begin
  ShellExecute(Handle, 'open', LPTSTR(bstrUrl), nil, nil, SW_RESTORE);
  Cancel := True;
end;

procedure TAutoUpdateWnd.ApplySize;
var
  WidthAccumulator: ISizeAccumulator;
  WidthSelector: ISizeSelector;
begin
  // Значёк
  WidthAccumulator := TWidthAccumulator.Create;
  WidthAccumulator.AddPadding(PanelImage);
  WidthAccumulator.AddControl(Image);
  PanelImage.ClientWidth := WidthAccumulator.Size;

  // Вычисление максимальной ширины
  WidthAccumulator := TWidthAccumulator.Create;
  with LabelMessage do
  begin
    Canvas.Font := Font;
    WidthAccumulator.Add(Canvas.TextWidth(Caption));
  end;
  WidthAccumulator.AddControl(PanelImage);
  WidthAccumulator.AddPadding(PanelInfo);

  WidthSelector := TWidthSelector.Create(stMax);
  WidthSelector.Select(WidthAccumulator.Size);

  WidthAccumulator := TWidthAccumulator.Create;
  WidthAccumulator.AddControl(PanelImage);
  WidthAccumulator.AddPadding(PanelInfo);
  WidthAccumulator.AddPadding(PanelButton);
  WidthAccumulator.AddPadding(PanelLater);
  WidthAccumulator.AddControl(ButtonSkip);
  WidthAccumulator.AddControl(ButtonLater);
  WidthAccumulator.AddControl(ButtonInstall);

  ClientWidth := WidthSelector.Select(WidthAccumulator.Size);
end;

procedure TAutoUpdateWnd.ApplyConstraitns;
var
  WidthAccumulator: ISizeAccumulator;
  HeightAccumulator: ISizeAccumulator;
begin
  HeightAccumulator := THeightAccumulator.Create;
  HeightAccumulator.AddPadding(PanelInfo);
  HeightAccumulator.AddControl(LabelTitle);
  HeightAccumulator.AddControl(LabelMessage);
  if WebBrowser <> nil then
    HeightAccumulator.AddControl(LabelInfo);
  HeightAccumulator.AddControl(PanelButton);
  Constraints.MinHeight := HeightAccumulator.Size + Height - ClientHeight;

  WidthAccumulator := TWidthAccumulator.Create;
  WidthAccumulator.AddControl(PanelImage);
  WidthAccumulator.AddPadding(PanelInfo);
  WidthAccumulator.AddPadding(PanelButton);
  WidthAccumulator.AddPadding(PanelLater);
  WidthAccumulator.AddControl(ButtonSkip);
  WidthAccumulator.AddControl(ButtonLater);
  WidthAccumulator.AddControl(ButtonInstall);
  Constraints.MinWidth := WidthAccumulator.Size + Width - ClientWidth;
end;

procedure TAutoUpdateWnd.ApplyWebBrowserScale;
var
  PPI: Integer;
  pvaIn: OleVariant;
  pvaOut: OleVariant;
begin
  PPI := GetCurrentPPI;
  if PPI = 96 then
    pvaIn := Integer(Round(PPI/96 * 100))
  else
    pvaIn := Integer(Round(PPI/96 * 100)) + 2;

  try
    WebBrowser.ControlInterface.ExecWB(
      OLECMDID_OPTICAL_ZOOM, OLECMDEXECOPT_DONTPROMPTUSER, pvaIn, pvaOut);
  except end;
end;

procedure TAutoUpdateWnd.FormAfterMonitorDpiChanged(Sender: TObject; OldDPI,
  NewDPI: Integer);
begin
  LoadIcon;
  ApplyWebBrowserScale;
  ApplyConstraitns;
end;

procedure TAutoUpdateWnd.FormBeforeMonitorDpiChanged(Sender: TObject; OldDPI,
  NewDPI: Integer);
begin
  Constraints.MinHeight := 0;
  Constraints.MinWidth := 0;
end;

end.
