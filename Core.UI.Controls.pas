unit Core.UI.Controls;

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.CommCtrl, Winapi.UxTheme,
  System.Classes, System.SysUtils, System.Win.Registry,
  Vcl.Forms, Vcl.ExtCtrls, Vcl.StdCtrls, Vcl.ComCtrls, Vcl.Graphics,
  Vcl.Controls, Vcl.Themes,
  Versions.Helpers;

type
  TCompatibleForm = class(TForm)
  strict private
    FWindowCreated: Boolean;

    function GetSystemUsesLightTheme: Boolean;
  private
    FIsSystemUsesLightTheme: Boolean;
  protected
    procedure DoCreate; override;
    procedure DoSystemUsesLightThemeChange(LightTheme: Boolean); virtual;

    procedure WMSettingChange(var Msg: TMessage); message WM_SETTINGCHANGE;
  public
    constructor Create(AOwner: TComponent); override;

    property WindowCreated: Boolean read FWindowCreated;
    property IsSystemUsesLightTheme: Boolean read FIsSystemUsesLightTheme;
  end;

type
  TPanelShape = (psNone, psTopLine, psBottomLine, psLeftLine, psRightLine);
  // Panel с добавлением граничных линий и событиями входа и выхода мыши
  TPanel = class(Vcl.ExtCtrls.TPanel)
  public
    constructor Create(AOwner: TComponent); override;
  private
    FShape: TPanelShape;
    FShapeColor: TColor;
    procedure SetShape(const Value: TPanelShape);
    procedure SetShapeColor(const Value: TColor);
  protected
    procedure Paint; override;
    procedure AlignControls(AControl: TControl; var Rect: TRect); override;
    procedure RequestAlign; override;
  published
    property Shape: TPanelShape read FShape write SetShape default psNone;
    property ShapeColor: TColor read FShapeColor write SetShapeColor
      default clSilver;
    property OnMouseEnter;
    property OnMouseLeave;
  end;

type
  // TrackBar с инвертированым колёсиком
  TTrackBarToolTipTextEvent = procedure(Sender: TObject; var Text: string) of object;
  TTrackBar = class(Vcl.ComCtrls.TTrackBar)
  private
    FDirectDrag: Boolean;
    FToolTipFormat: string;
    FOnToolTipText: TTrackBarToolTipTextEvent;
  protected
    procedure WMMouseWheel(var Msg: TWMMouseWheel); message WM_MOUSEWHEEL;
    procedure WMLButtonDown(var Msg: TWMLButtonDown); message WM_LBUTTONDOWN;
    procedure WMNotify(var Message: TWMNotify); message WM_NOTIFY;
    procedure DoToolTipText(Sender: TObject; var Text: string); virtual;
  published
    property DirectDrag: Boolean read FDirectDrag write FDirectDrag default False;
    property ToolTipFormat: string read FToolTipFormat write FToolTipFormat;
    property OnToolTipText: TTrackBarToolTipTextEvent read FOnToolTipText write FOnToolTipText;
  public
    constructor Create(AOwner: TComponent); override;
  end;

type
  // Edit с возможностью центрирования текста
  TEdit = class(Vcl.StdCtrls.TEdit)
  private
    FAlignment: TAlignment;
    procedure SetAlignment(Value: TAlignment);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  published
    property Alignment: TAlignment read FAlignment write SetAlignment
      default taLeftJustify;
  end;

type
  // CheckBox с дополнительным пробелом перед текстом и свойством AutoSize
  TCheckBox = class(Vcl.StdCtrls.TCheckBox)
  private
    FThemeActive: Boolean;
    FAdditionalSpace: Boolean;
    function GetText: TCaption;
    procedure SetText(const Value: TCaption);
    procedure SetAdditionalSpace(const Value: Boolean);
    function GetAutoSize: Boolean;
    procedure SetAutoSize(const Value: Boolean); reintroduce;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure CMTextChanged(var Message: TMessage); message CM_TEXTCHANGED;
    procedure WMThemeChanged(var Message: TMessage); message WM_THEMECHANGED;
  protected
    function CanAutoSize(var NewWidth, NewHeight: Integer): Boolean; override;
  published
    constructor Create(AOwner: TComponent); override;
    property AutoSize: Boolean read GetAutoSize write SetAutoSize;
    property Caption read GetText write SetText;
    property AdditionalSpace: Boolean read FAdditionalSpace write SetAdditionalSpace;
  end;

type
  // RadioButton со свойством AutoSize
  TRadioButton = class(Vcl.StdCtrls.TRadioButton)
  private
    function GetAutoSize: Boolean;
    procedure SetAutoSize(const Value: Boolean); reintroduce;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure CMTextChanged(var Message: TMessage); message CM_TEXTCHANGED;
  protected
    function CanAutoSize(var NewWidth, NewHeight: Integer): Boolean; override;
  published
    property AutoSize: Boolean read GetAutoSize write SetAutoSize;
  end;

type
  // ComboBox с автоматическим подбором ширины выпадающего списка
  TComboBox = class(Vcl.StdCtrls.TComboBox)
  private
    FAutoDropDownWidth: Boolean;
  protected
    procedure DropDown; override;
  published
    property AutoDropDownWidth: Boolean read FAutoDropDownWidth write FAutoDropDownWidth;
  end;

type
  TLabel = class(Vcl.StdCtrls.TLabel)
  protected
    procedure AdjustBounds; override;
    procedure Resize; override;
  end;

type
  // StaticText с функцией ссылки
  TLinkStyle = (lsNormal, lsHover);
  TStaticText = class(Vcl.StdCtrls.TStaticText)
  strict private
    FLinkFont: TFont;
    FMouseHovered: Boolean;
    FFocused: Boolean;
    FHideFocus: Boolean;
    FLinkMode: Boolean;
    procedure SetLinkMode(const Value: Boolean);
    procedure FontChange(Sender: TObject);
    procedure LinkFontChange(Sender: TObject);
  protected
    procedure KeyPress(var Key: Char); override;
    procedure CreateWnd; override;
    function GetLinkStyleColor(Style: TLinkStyle): TColor; virtual;
    procedure ApplyLinkStyle(Style: TLinkStyle);
    procedure UpdateLinkStyle;
    procedure WMSetFocus(var Message: TWMSetFocus); message WM_SETFOCUS;
    procedure WMKillFocus(var Message: TWMKillFocus); message WM_KILLFOCUS;
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
    procedure WMUpdateUIState(var Message: TWMUpdateUIState); message WM_UPDATEUISTATE;
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property LinkMode: Boolean read FLinkMode write SetLinkMode;
  end;

type
  // TabControl с функцией AutoSize
  TTabControl = class(Vcl.ComCtrls.TTabControl)
  published
    property AutoSize;
  end;

type
  // TGroupBox с функцией AutoSize
  TGroupBox = class(Vcl.StdCtrls.TGroupBox)
  published
    property AutoSize;
    procedure AlignControls(AControl: TControl; var Rect: TRect); override;
  end;

type
  // TScrollBox с поддержкой прокрутки колесом мыши
  // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  // !!! Требуется MouseWheelRouting !!!
  // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  TScrollBox = class(Vcl.Forms.TScrollBox)
  protected
    procedure WndProc(var Message: TMessage); override;
  end;

type
  // Button со свойством AutoSize
  TButton = class(Vcl.StdCtrls.TButton)
  private
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure CMTextChanged(var Message: TMessage); message CM_TEXTCHANGED;
    function GetAutoSize: Boolean;
    procedure SetAutoSize(const Value: Boolean); reintroduce;
  protected
    function CanAutoSize(var NewWidth, NewHeight: Integer): Boolean; override;
  public
    property AutoSize: Boolean read GetAutoSize write SetAutoSize;
  end;

implementation

{ TCompatibleForm }

constructor TCompatibleForm.Create(AOwner: TComponent);
var
  NonClientMetric: NONCLIENTMETRICS;
  NewHFont: HFONT;
begin
  FWindowCreated := False;
  FIsSystemUsesLightTheme := GetSystemUsesLightTheme;

  inherited;

  if not IsWindowsVistaOrGreater then
  begin
    NonClientMetric.cbSize := NONCLIENTMETRICS.SizeOf;
    if SystemParametersInfo(SPI_GETNONCLIENTMETRICS, NonClientMetric.cbSize, @NonClientMetric, 0) then
    begin
      NewHFont := CreateFontIndirect(NonClientMetric.lfMessageFont);
      if NewHFont <> 0 then
        Font.Handle := NewHFont;
    end;
  end;
end;

procedure TCompatibleForm.DoCreate;
begin
  inherited;

  // Окно успешно создано
  FWindowCreated := True;
end;

procedure TCompatibleForm.DoSystemUsesLightThemeChange(LightTheme: Boolean);
begin
  FIsSystemUsesLightTheme := LightTheme;
end;

procedure TCompatibleForm.WMSettingChange(var Msg: TMessage);
var
  IsSystemLightTheme: Boolean;
begin
  if LPCTSTR(Msg.LParam) = 'ImmersiveColorSet' then
  begin
    IsSystemLightTheme := GetSystemUsesLightTheme;
    if IsSystemLightTheme <> FIsSystemUsesLightTheme then
      DoSystemUsesLightThemeChange(IsSystemLightTheme);
  end;
end;

function TCompatibleForm.GetSystemUsesLightTheme: Boolean;
var
  Registry: TRegistry;
begin
  Result := False;
  if not IsWindows10Update1903OrGreater then Exit;

  Registry := TRegistry.Create;
  try
    Registry.RootKey := HKEY_CURRENT_USER;
    if Registry.OpenKeyReadOnly('\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize') then
    try
      if Registry.ValueExists('SystemUsesLightTheme') then
        Result := Registry.ReadBool('SystemUsesLightTheme');
    finally
      Registry.CloseKey;
    end;
  finally
    Registry.Free;
  end;
end;


{ TPanel }

constructor TPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  Shape := psNone;
  ShapeColor := clSilver;
end;

procedure TPanel.Paint;
begin
  inherited;
  if FShape = psNone then Exit;

  Canvas.Pen.Color := FShapeColor;

  case FShape of
    psTopLine:
      begin
        Canvas.MoveTo(0,     0);
        Canvas.LineTo(Width, 0);
      end;
    psBottomLine:
      begin
        Canvas.MoveTo(0,     Height - 1);
        Canvas.LineTo(Width, Height - 1);
      end;
    psLeftLine:
      begin
        Canvas.MoveTo(0, 0);
        Canvas.LineTo(0, Height);
      end;
    psRightLine:
      begin
        Canvas.MoveTo(Width - 1, 0);
        Canvas.LineTo(Width - 1, Height);
      end;
  end;
end;

procedure TPanel.RequestAlign;
begin
  inherited;
  Realign;
end;

procedure TPanel.AlignControls(AControl: TControl; var Rect: TRect);
begin
  inherited;
  AdjustSize;
end;

procedure TPanel.SetShape(const Value: TPanelShape);
begin
  if Value <> FShape then begin
    FShape := Value;
    Invalidate;
  end;
end;

procedure TPanel.SetShapeColor(const Value: TColor);
begin
  if Value <> FShapeColor then begin
    FShapeColor := Value;
    Invalidate;
  end;
end;


{ TTrackBar }

constructor TTrackBar.Create(AOwner: TComponent);
begin
  inherited;

  FDirectDrag := False;
end;

procedure TTrackBar.WMMouseWheel(var Msg: TWMMouseWheel);
begin
  Msg.WheelDelta := -Msg.WheelDelta;
  inherited;
end;

procedure TTrackBar.WMLButtonDown(var Msg: TWMLButtonDown);
var
  ChannelRect, SliderRect: TRect;
  SliderWidth: Integer;
  Pt: TPoint;
begin
  if not FDirectDrag then begin
    inherited;
    Exit;
  end;

  ZeroMemory(@SliderRect, SizeOf(SliderRect));
  SendMessage(WindowHandle, TBM_GETTHUMBRECT, 0, LPARAM(@SliderRect));

  ZeroMemory(@ChannelRect, SizeOf(ChannelRect));
  SendMessage(WindowHandle, TBM_GETCHANNELRECT, 0, LPARAM(@ChannelRect));

  if Orientation = trHorizontal then begin
    Pt.Create(msg.XPos, msg.YPos);
    SliderWidth := SliderRect.Width div 2;
    ChannelRect.Top := SliderRect.Top;
    ChannelRect.Bottom := SliderRect.Bottom;
  end else begin
    Pt.Create(msg.YPos, msg.XPos);
    SliderWidth := SliderRect.Height div 2;
    ChannelRect.Top := SliderRect.Left;
    ChannelRect.Bottom := SliderRect.Right;
  end;


  if not SliderRect.Contains(TPoint.Create(msg.XPos, msg.YPos)) then
    if ChannelRect.Contains(Pt) then begin
      Inc(ChannelRect.Left, SliderWidth);
      Dec(ChannelRect.Right, SliderWidth);

      SendMessage(WindowHandle, WM_LBUTTONDOWN, Msg.Keys, MakeLParam(SliderRect.CenterPoint.X, SliderRect.CenterPoint.Y));
      SendMessage(WindowHandle, TBM_SETPOS, WPARAM(True), Round((Pt.X - ChannelRect.Left) * (Max - Min) / ChannelRect.Width));

      Exit;
    end;

  inherited;
end;

procedure TTrackBar.WMNotify(var Message: TWMNotify);
var
  PDispInfo: PNMTTDispInfo;
  ToolTipText: string;
begin
  if Message.NMHdr^.code = TTN_NEEDTEXT then begin
    PDispInfo := PNMTTDispInfo(Message.NMHdr);
    if not string.IsNullOrEmpty(FToolTipFormat) then
      ToolTipText := string.Format(FToolTipFormat, [SendMessage(WindowHandle, TBM_GETPOS, 0, 0)]);

    DoToolTipText(Self, ToolTipText);

    if not string.IsNullOrEmpty(ToolTipText) then
      PDispInfo^.lpszText := LPTSTR(ToolTipText)
    else
      inherited;
  end else
    inherited;
end;

procedure TTrackBar.DoToolTipText(Sender: TObject; var Text: string);
begin
  if Assigned(FOnToolTipText) then
    FOnToolTipText(Self, Text);
end;

{ TEdit }

procedure TEdit.CreateParams(var Params: TCreateParams);
begin
  inherited;
  case Alignment of
    taLeftJustify:
      Params.Style:= Params.Style or ES_LEFT;
    taRightJustify:
      Params.Style:= Params.Style or ES_RIGHT;
    taCenter:
      Params.Style:= Params.Style or ES_CENTER;
  end;
end;

procedure TEdit.SetAlignment(Value: TAlignment);
begin
  if FAlignment <> Value then
  begin
    FAlignment:= Value;
    RecreateWnd;
  end;
end;


{ TCheckBox }

constructor TCheckBox.Create(AOwner: TComponent);
begin
  inherited;
  FThemeActive := IsThemeActive;
end;

function TCheckBox.GetText: TCaption;
begin
  if AdditionalSpace then
    Result := Copy(inherited Caption, 2, Length(inherited Caption) - 2)
  else
    Result := inherited Caption;
end;

procedure TCheckBox.SetText(const Value: TCaption);
begin
  if AdditionalSpace then
    inherited Caption := ' ' + Value + ' '
  else
    inherited Caption := Value;
end;

procedure TCheckBox.SetAdditionalSpace(const Value: Boolean);
begin
  if FAdditionalSpace = Value then Exit;

  FAdditionalSpace := Value;

  if FAdditionalSpace then
    inherited Caption := ' ' + inherited Caption + ' '
  else
    inherited Caption := Copy(inherited Caption, 2, Length(inherited Caption) - 2)
end;

function TCheckBox.GetAutoSize: Boolean;
begin
  Result := inherited AutoSize;
end;

procedure TCheckBox.SetAutoSize(const Value: Boolean);
var
  NewWidth, NewHeight: Integer;
begin
  inherited AutoSize := Value;

  if CanAutoSize(NewWidth, NewHeight) then
  begin
    Left := Left + Width - NewWidth;
    Top := Top + Height - NewHeight;

    Width := NewWidth;
    Height := NewHeight;
  end;
end;

function TCheckBox.CanAutoSize(var NewWidth, NewHeight: Integer): Boolean;
const
  WordBreak: array [Boolean] of Cardinal = (0, DT_WORDBREAK);
var
  DC: HDC;
  ContentRect: TRect;
  SaveFont: HFONT;
  DrawFlags: Cardinal;
begin
  if not AutoSize then Exit(False);
  if Parent <> nil then HandleNeeded;
  if WindowHandle = 0 then Exit(False);

  Result := False;
  DC := GetDC(WindowHandle);
  try
    ContentRect.Create(0, 0, NewWidth, NewHeight);
    SaveFont := SelectObject(DC, Font.Handle);
    DrawFlags := DT_CENTER or DT_VCENTER or DT_HIDEPREFIX or DT_CALCRECT or WordBreak[WordWrap];
    if DrawText(DC, PChar(inherited Caption), -1, ContentRect, DrawFlags) <> 0 then begin
      NewWidth := ContentRect.Width + Padding.Left + Padding.Right + GetSystemMetrics(SM_CXMENUCHECK) + 3;
      if not FThemeActive then
        NewWidth := NewWidth + 2*GetSystemMetrics(SM_CXEDGE);

      NewHeight := ContentRect.Height + Padding.Top + Padding.Bottom;
      if GetSystemMetrics(SM_CYMENUCHECK) > NewHeight then
        NewHeight := GetSystemMetrics(SM_CYMENUCHECK);

      Result := True;
    end;
    SelectObject(DC, SaveFont);
  finally
    ReleaseDC(WindowHandle, DC);
  end;
end;

procedure TCheckBox.CMFontChanged(var Message: TMessage);
begin
  inherited;
  AdjustSize;
end;

procedure TCheckBox.CMTextChanged(var Message: TMessage);
begin
  inherited;
  AdjustSize;
end;

procedure TCheckBox.WMThemeChanged(var Message: TMessage);
begin
  FThemeActive := IsThemeActive;
  inherited;
end;


{ TRadioButton }

function TRadioButton.GetAutoSize: Boolean;
begin
  Result := inherited AutoSize;
end;

procedure TRadioButton.SetAutoSize(const Value: Boolean);
var
  NewWidth, NewHeight: Integer;
begin
  inherited AutoSize := Value;

  if CanAutoSize(NewWidth, NewHeight) then
  begin
    Left := Left + Width - NewWidth;
    Top := Top + Height - NewHeight;

    Width := NewWidth;
    Height := NewHeight;
  end;
end;

function TRadioButton.CanAutoSize(var NewWidth, NewHeight: Integer): Boolean;
const
  AlignBreak: array [TAlign] of DWORD = (0, DT_EDITCONTROL, DT_EDITCONTROL, 0, 0, DT_EDITCONTROL, 0);
  WordBreak: array [Boolean] of DWORD = (0, DT_WORDBREAK or DT_NOFULLWIDTHCHARBREAK);
var
  DC: HDC;
  ContentRect: TRect;
  SaveFont: HFONT;
  DrawFlags: Cardinal;
  ExtraSpace: TPoint;
begin
  if not AutoSize then Exit(False);
  if Parent <> nil then HandleNeeded;
  if WindowHandle = 0 then Exit(False);

  Result := False;
  DC := GetDC(WindowHandle);
  try
    ExtraSpace.X := Padding.Left + Padding.Right + GetSystemMetrics(SM_CXMENUCHECK);
    ExtraSpace.Y := Padding.Top + Padding.Bottom;

    ContentRect.Create(0,0,0,0);
    if NewWidth - ExtraSpace.X > 0 then ContentRect.Width := NewWidth - ExtraSpace.X - 1;
    if NewHeight - ExtraSpace.Y > 0 then ContentRect.Height := NewHeight - ExtraSpace.Y;

    SaveFont := SelectObject(DC, Font.Handle);

    DrawFlags := DT_HIDEPREFIX or DT_NOCLIP or DT_CALCRECT or WordBreak[WordWrap] or AlignBreak[Align];
    if DrawText(DC, LPCTSTR(Caption), -1, ContentRect, DrawFlags) <> 0 then
    begin
      NewWidth := ContentRect.Width + ExtraSpace.X + 2;
      NewHeight := ContentRect.Height + ExtraSpace.Y;
      if GetSystemMetrics(SM_CYMENUCHECK) > NewHeight then
        NewHeight := GetSystemMetrics(SM_CYMENUCHECK);

      Result := True;
    end;
    SelectObject(DC, SaveFont);
  finally
    ReleaseDC(WindowHandle, DC);
  end;
end;

procedure TRadioButton.CMFontChanged(var Message: TMessage);
begin
  inherited;
  AdjustSize;
end;

procedure TRadioButton.CMTextChanged(var Message: TMessage);
begin
  inherited;
  AdjustSize;
end;


{ TLabel }

procedure TLabel.AdjustBounds;
const
  WordWraps: array[Boolean] of Word = (0, DT_WORDBREAK);
  AccelChars: array [Boolean] of UINT = (DT_HIDEPREFIX, 0);

var
  DC: HDC;
  X: Integer;
  R: TRect;
  AAlignment: TAlignment;
  LSin,LCos: Double;
  LRcx,LRcy: Integer;
  p1:TPoint;
  LBox: TRect;

  procedure CalcBox(AIdx, X,Y: Integer; Init: Boolean=FALSE);
  begin
    if Init then
      LBox := Rect(X, Y, X, Y)
    else
    begin
      if X < LBox.Left then
        LBox.Left := X
      else if X > LBox.Right then
        LBox.Right := X;

      if Y < LBox.Top then
        LBox.Top := Y
      else if Y > LBox.Bottom then
        LBox.Bottom := Y;
    end;
  end;
begin
  if not (csReading in ComponentState) and AutoSize then
  begin
    R := ClientRect;
    DC := GetDC(0);
    try
      Canvas.Handle := DC;
      if Font.Orientation = 0 then
        DoDrawText(R, DT_EXPANDTABS or DT_CALCRECT or WordWraps[WordWrap] or AccelChars[ShowAccelChar])
      else
        DoDrawText(R, DT_EXPANDTABS or DT_CALCRECT);
      Canvas.Handle := 0;
    finally
      ReleaseDC(0, DC);
    end;
    if Font.Orientation = 0 then
    begin
      X := Left;
      AAlignment := Alignment;
      if UseRightToLeftAlignment then
        ChangeBiDiModeAlignment(AAlignment);
      if AAlignment = taRightJustify then
        Inc(X, Width - R.Right);

      if HasParent then
        case Align of
          alTop, alBottom: SetBounds(Left, Top, Width, R.Height);
          alLeft, alRight: SetBounds(X, Top, R.Width, Height);
          else SetBounds(X, Top, R.Width, R.Height);
        end
      else
        SetBounds(X, Top, R.Width, R.Height);
    end
    else
    begin
      LSin := Sin((Font.Orientation / 10) * Pi / 180);
      LCos := Cos((Font.Orientation / 10) * Pi / 180);
      LRcx := R.Left + R.Width Div 2;
      LRcy := R.Top + R.Height Div 2;
      p1.x := (R.Left - LRcx);
      p1.Y := (R.Top - LRcy);
      CalcBox(0, Round(p1.X * LCos - p1.Y * LSin) + LRcx,
      Round(p1.X * LSin - p1.Y * LCos) + LRcy, TRUE);
      p1.X := (R.Right - LRcx);
      CalcBox(1, Round(p1.X * LCos - p1.Y * LSin) + LRcx,
      Round(p1.X * LSin - p1.Y * LCos) + LRcy);
      p1.Y := (R.Bottom - LRcy);
      CalcBox(2, Round(p1.X * LCos - p1.Y * LSin) + LRcx,
      Round(p1.X * LSin - p1.Y * LCos) + LRcy);
      p1.X := (R.Left - LRcx);
      CalcBox(3, Round(p1.X * LCos - p1.Y * LSin) + LRcx,
      Round(p1.X * LSin - p1.Y * LCos) + LRcy);
      OffsetRect(LBox, -LBox.Left, -LBox.Top);
      SetBounds(Left + LBox.Left, Top + LBox.Top, LBox.Right, LBox.Bottom);
    end;
  end;
end;

procedure TLabel.Resize;
begin
  inherited;
  AdjustBounds;
end;


{ TStaticText }

constructor TStaticText.Create(AOwner: TComponent);
begin
  inherited;

  FLinkFont := TFont.Create;
  FLinkFont.OnChange := LinkFontChange;
  FLinkFont.Assign(Font);
  Font.OnChange := FontChange;

  FMouseHovered := False;
  FFocused := False;
  FHideFocus := False;
  FLinkMode := False;
  ParentBackground := True;
end;

procedure TStaticText.CreateWnd;
begin
  inherited;
  AutoSize := False;
  AutoSize := True;
end;

destructor TStaticText.Destroy;
begin
  FLinkFont.Free;
  inherited;
end;

procedure TStaticText.FontChange(Sender: TObject);
begin
  FLinkFont.Assign(Sender as TFont);
  UpdateLinkStyle;
end;

procedure TStaticText.LinkFontChange(Sender: TObject);
begin
  Invalidate;
end;

procedure TStaticText.KeyPress(var Key: Char);
begin
  if (Key = Char(VK_SPACE)) and Assigned(OnClick) then
    OnClick(Self)
  else
    inherited;
end;

procedure TStaticText.WMSetFocus(var Message: TWMSetFocus);
begin
  FFocused := True;
  UpdateLinkStyle;
  Invalidate;
  inherited;
end;

procedure TStaticText.WMKillFocus(var Message: TWMKillFocus);
begin
  FFocused := False;
  UpdateLinkStyle;
  Invalidate;
  inherited;
end;

procedure TStaticText.WMPaint(var Message: TWMPaint);
const
  AccelChar: array [Boolean] of UINT = (DT_HIDEPREFIX, 0);
var
  DC: HDC;
  R: TRect;
  SaveFont: HFONT;
  SaveColor: COLORREF;
  DrawFlags: UINT;

  PS: TPaintStruct;
begin
  DC := BeginPaint(WindowHandle, PS);
  try
    R := Rect(0, 0, Width, Height);
    SetBkMode(DC, Winapi.Windows.TRANSPARENT);

    SaveFont := SelectObject(DC, FLinkFont.Handle);
    SaveColor := SetTextColor(DC, ColorToRGB(FLinkFont.Color));

    DrawFlags := DT_CENTER or DT_VCENTER or DT_SINGLELINE or AccelChar[ShowAccelChar];
    DrawText(DC, LPCTSTR(Caption), -1, R, DrawFlags);

    SelectObject(DC, SaveFont);
    SetTextColor(DC, SaveColor);

    if FFocused and not FHideFocus then
      DrawFocusRect(DC, R);
  finally
    EndPaint(WindowHandle, PS);
  end;
end;

procedure TStaticText.WMUpdateUIState(var Message: TWMUpdateUIState);
begin
  case Message.Action of
    UIS_CLEAR:
      case Message.Flags of
        UISF_ACTIVE: FFocused := False;
        UISF_HIDEACCEL: ; // ShowAccelChar := True;
        UISF_HIDEFOCUS: FHideFocus := False;
      end;
    UIS_INITIALIZE:
      case Message.Flags of
        UISF_ACTIVE: ;
        UISF_HIDEACCEL: ; // ShowAccelChar := False;
        UISF_HIDEFOCUS: FHideFocus := False;
      end;
    UIS_SET:
      case Message.Flags of
        UISF_ACTIVE: ;
        UISF_HIDEACCEL: ; // ShowAccelChar := False;
        UISF_HIDEFOCUS: FHideFocus := True;
      end;
  end;
  UpdateLinkStyle;
  Invalidate;

  inherited;
end;

function TStaticText.GetLinkStyleColor(Style: TLinkStyle): TColor;
begin
  Result := clHotLight;
end;

procedure TStaticText.ApplyLinkStyle(Style: TLinkStyle);
begin
  if Enabled and FLinkMode then begin
    FLinkFont.Color := GetLinkStyleColor(Style);
    case Style of
      lsHover: FLinkFont.Style:= [fsUnderline];
      else FLinkFont.Style:= [];
    end;
  end else
    FLinkFont.Assign(Font);
end;

procedure TStaticText.UpdateLinkStyle;
begin
  if FFocused or FMouseHovered then
    ApplyLinkStyle(lsHover)
  else
    ApplyLinkStyle(lsNormal);
end;

procedure TStaticText.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  FMouseHovered := True;
  if Enabled and FLinkMode then
    UpdateLinkStyle;
end;

procedure TStaticText.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  FMouseHovered := False;
  if Enabled and FLinkMode then
    UpdateLinkStyle;
end;

procedure TStaticText.SetLinkMode(const Value: Boolean);
begin
  FLinkMode := Value;
  if FLinkMode then
    Cursor := crHandPoint
  else
    Cursor := crDefault;
  UpdateLinkStyle;
end;


{ TScrollBox }

procedure TScrollBox.WndProc(var Message: TMessage);
var
  Msg: Cardinal;
  Code: WPARAM;
  I: Integer;
begin
  case Message.Msg of
    WM_MOUSEWHEEL:
      begin
        if (HiByte(GetKeyState(VK_SHIFT)) <> 0) and (HorzScrollBar.IsScrollBarVisible) then
          Msg := WM_HSCROLL
        else if VertScrollBar.IsScrollBarVisible then
          Msg := WM_VSCROLL
        else if HorzScrollBar.IsScrollBarVisible then
          Msg := WM_HSCROLL
        else begin
          Message.Result := DefWindowProc(Handle, Message.Msg, Message.WParam, Message.LParam);
          Exit;
        end;

        if TWMMouseWheel(Message).WheelDelta < 0 then
          Code := SB_LINEDOWN
        else
          Code := SB_LINEUP;

        for I := 1 to Mouse.WheelScrollLines do
          Perform(Msg, MakeWParam(Code, 0), 0);
        Perform(Msg, MakeWParam(SB_ENDSCROLL, 0), 0);

        Message.Result := 1;
      end;
    WM_MOUSEHWHEEL:
      begin
        if HorzScrollBar.IsScrollBarVisible then
          Msg := WM_HSCROLL
        else if VertScrollBar.IsScrollBarVisible then
          Msg := WM_VSCROLL
        else begin
          Message.Result := DefWindowProc(Handle, Message.Msg, Message.WParam, Message.LParam);
          Exit;
        end;

        if TWMMouseWheel(Message).WheelDelta < 0 then
          Code := SB_LINEDOWN
        else
          Code := SB_LINEUP;

        for I := 1 to Mouse.WheelScrollLines do
          Perform(Msg, MakeWParam(Code, 0), 0);
        Perform(Msg, MakeWParam(SB_ENDSCROLL, 0), 0);

        Message.Result := 0;
      end;
    else inherited WndProc(Message);
  end;
end;


{ TButton }

function TButton.CanAutoSize(var NewWidth, NewHeight: Integer): Boolean;
const
  WordBreak: array [Boolean] of Cardinal = (0, DT_WORDBREAK);
var
  DC: HDC;
  ContentRect: TRect;
  Margins: TElementMargins;
  Details: TThemedElementDetails;
  SaveFont: HFONT;
  DrawFlags: Cardinal;
begin
  if not AutoSize then Exit(False);
  if Parent <> nil then HandleNeeded;
  if WindowHandle = 0 then Exit(False);

  DC := GetDC(WindowHandle);
  try
    ContentRect.Create(0, 0, NewWidth, NewHeight);
    Details := StyleServices.GetElementDetails(tbPushButtonNormal);
    StyleServices.GetElementContentRect(DC, Details, ContentRect, ContentRect);
    StyleServices.GetElementMargins(DC, Details, emContent, Margins);
    SaveFont := SelectObject(DC, Font.Handle);
    DrawFlags := DT_CENTER or DT_VCENTER or DT_HIDEPREFIX or DT_CALCRECT or WordBreak[WordWrap];
    if DrawText(DC, PChar(Caption), -1, ContentRect, DrawFlags) <> 0 then begin
      NewWidth := ContentRect.Width + Padding.Left + Padding.Right;
      NewHeight := ContentRect.Height + Padding.Top + Padding.Bottom;
    end;
    SelectObject(DC, SaveFont);
  finally
    ReleaseDC(WindowHandle, DC);
  end;
  Result := True;
end;

procedure TButton.CMFontChanged(var Message: TMessage);
begin
  inherited;
  AdjustSize;
end;

procedure TButton.CMTextChanged(var Message: TMessage);
begin
  inherited;
  AdjustSize;
end;

function TButton.GetAutoSize: Boolean;
begin
  Result := inherited AutoSize;
end;

procedure TButton.SetAutoSize(const Value: Boolean);
var
  NewWidth, NewHeight: Integer;
begin
  inherited AutoSize := Value;

  if CanAutoSize(NewWidth, NewHeight) then begin
    Left := Left + Width - NewWidth;
    Top := Top + Height - NewHeight;

    Width := NewWidth;
    Height := NewHeight;
  end;
end;

{ TComboBox }

procedure TComboBox.DropDown;
const
  TextMargin = 4;
var
  DC: HDC;
  SaveFont: HFONT;
  DrawFlags: Cardinal;
  Item: string;
  MaxItemWidth: Integer;
  ItemWidth: integer;
  ContentRect: TRect;
begin
  if not FAutoDropDownWidth then
  begin
    inherited;
    Exit;
  end;

  if Parent <> nil then HandleNeeded;
  if WindowHandle = 0 then
  begin
    inherited;
    Exit;
  end;

  DC := GetDC(WindowHandle);
  try
    SaveFont := SelectObject(DC, Font.Handle);
    DrawFlags := DT_VCENTER or DT_HIDEPREFIX or DT_CALCRECT;

    MaxItemWidth := 0;
    for Item in Items do
      if DrawText(DC, PChar(Item), -1, ContentRect, DrawFlags) <> 0 then
      begin
        ItemWidth := ContentRect.Width;
        if ItemWidth > MaxItemWidth then
          MaxItemWidth := ItemWidth;
      end;
    SelectObject(DC, SaveFont);
  finally
    ReleaseDC(WindowHandle, DC);
  end;

  Inc(MaxItemWidth, 2 * TextMargin);

  if MaxItemWidth > Width then
    if DropDownCount < Items.Count then
      Inc(MaxItemWidth, GetSystemMetrics(SM_CXVSCROLL));

  Perform(CB_SETDROPPEDWIDTH, MaxItemWidth, 0);

  inherited;
end;

{ TGroupBox }

procedure TGroupBox.AlignControls(AControl: TControl; var Rect: TRect);
begin
  inherited;
  AdjustSize;
end;

end.
 