unit Icon.Renderers.Percent;

interface

uses
  Winapi.Windows,
  System.SysUtils,
  Icon.Renderers,
  Helpers.Images.Generator,
  GdiPlus, GdiPlus.HSB.Helpers,
  Battery.Mode,
  Power, Power.WinApi.PowrProf,
  Versions.Helpers;

type
  TPercentIconRenderer = class(TBaseIconRenderer)
  strict private
    FMaxPowerSavingsColor: TGPColor;
    FTypicalPowerSavingsColor: TGPColor;
    FMinPowerSavingsColor: TGPColor;
    FUltimatePowerSavingsColor: TGPColor;
    FCustomPowerSavingsColor: TGPColor;

    procedure AssignColors;
  public
    constructor Create(Options: TIconsOptions);

    function GenerateIcon(IconParams: TIconParams; Dpi: Integer): HICON; override;
    function GenerateImage(IconParams: TIconParams; Dpi: Integer): HBITMAP; override;
  end;

implementation

{ TPercentIconRenderer }

constructor TPercentIconRenderer.Create(Options: TIconsOptions);
begin
  inherited Create(Options);

  AssignColors;
end;

function TPercentIconRenderer.GenerateIcon(IconParams: TIconParams; Dpi: Integer): HICON;
var
  Icon: IGPBitmap;
  Graphic: IGPGraphics;
  FontFamily: string;
  Font: IGPFont;
  FontSize: Single;
  Rect: TGPRectF;
  Format: IGPStringFormat;
  Color: TGPColor;
  IsOverlayAsScheme: Boolean;
  IsHiDpi: Boolean;

  function GetSystemFontName: string;
  var
    NonClientMetric: NONCLIENTMETRICS;
  begin
    NonClientMetric.cbSize := NONCLIENTMETRICS.SizeOf;
    if not SystemParametersInfo(SPI_GETNONCLIENTMETRICS, NonClientMetric.cbSize, @NonClientMetric, 0) then
      Exit('Segoe UI');

    Result := NonClientMetric.lfMessageFont.lfFaceName;
  end;
begin
  IsHiDpi := (Dpi > 96) and IsWindowsVistaOrGreater;
  IsOverlayAsScheme := not (psfMissingScheme in TBatteryMode.PowerSchemes.SchemeFeatures);

  if IsWindows10Update1607OrGreater then
    Icon := TGPBitmap.Create(GetSystemMetricsForDpi(SM_CXSMICON, Dpi), GetSystemMetricsForDpi(SM_CYSMICON, Dpi))
  else
    Icon := TGPBitmap.Create(GetSystemMetrics(SM_CXSMICON), GetSystemMetrics(SM_CYSMICON));

  Icon.SetResolution(Dpi, Dpi);

  Graphic := TGPGraphics.Create(Icon);

  if IsHiDpi then
  begin
    FontFamily := GetSystemFontName;
    Rect := TGPRectF.Create(0, 0, Icon.Width, Icon.Height);

    if (FOptions.IconTheme = ithDark) or FOptions.TrayIconDark then
    begin
      Graphic.TextRenderingHint := TextRenderingHintAntiAliasGridFit;
      Graphic.PixelOffsetMode := PixelOffsetModeHighQuality;
    end
    else
    begin
      Graphic.TextRenderingHint := TextRenderingHintClearTypeGridFit;
    end;
  end
  else
  begin
    FontFamily := 'Microsoft Sans Serif';
    Rect := TGPRectF.Create(0, 0, Icon.Width, Icon.Height - 1);

    Graphic.TextRenderingHint := TextRenderingHintSingleBitPerPixelGridFit;
  end;

  FontSize := 12;
  if IconParams.State.Percentage >= 100 then FontSize := 10;
  FontSize := FontSize * Dpi/96;

  Font := TGPFont.Create(FontFamily, FontSize, [], UnitPixel);
  Format := TGPStringFormat.Create([StringFormatFlagsNoWrap]);
  Format.Alignment := TGPStringAlignment.StringAlignmentCenter;
  Format.LineAlignment := TGPStringAlignment.StringAlignmentCenter;
  Format.Trimming := TGPStringTrimming.StringTrimmingNone;

  case FOptions.IconColorType of
    ictCharger:
      case IconParams.State.PowerCondition of
        PoAc: Color := FMaxPowerSavingsColor;
        else
          if IsPercentageCritical(IconParams.State.Percentage) then
            Color := FMinPowerSavingsColor
          else
            Color := FTypicalPowerSavingsColor;
      end;
    ictChargerAndLevel:
      case IconParams.State.PowerCondition of
        PoAc: Color := FCustomPowerSavingsColor;
        else
          case PercentageToLevel(IconParams.State.Percentage) of
            clLow:  Color := FMinPowerSavingsColor;
            clMid:  Color := FTypicalPowerSavingsColor;
            clHigh: Color := FMaxPowerSavingsColor;
            else Color := FCustomPowerSavingsColor;
          end;
      end;
    else
    begin
      if IsOverlayAsScheme then
      begin
        case IconParams.State.PowerScheme.OverlaySchemeType of
          ostOverlayMin: Color := FMaxPowerSavingsColor;
          ostOverlayMax: Color := FMinPowerSavingsColor;
          ostOverlayHigh: Color := FCustomPowerSavingsColor;
          else Color := FTypicalPowerSavingsColor;
        end;
      end
      else
      begin
        case IconParams.State.PowerScheme.PowerSchemeType of
          pstMaxPowerSavings: Color := FMaxPowerSavingsColor;
          pstTypicalPowerSavings: Color := FTypicalPowerSavingsColor;
          pstMinPowerSavings: Color := FMinPowerSavingsColor;
          pstUltimatePowerSavings: Color := FUltimatePowerSavingsColor;
          else Color := FCustomPowerSavingsColor;
        end;
      end;
    end;
  end;

  Graphic.DrawString(IconParams.State.Percentage.ToString, Font, Rect, Format, TGPSolidBrush.Create(Color));

  Result := Icon.GetHIcon;
end;

function TPercentIconRenderer.GenerateImage(IconParams: TIconParams; Dpi: Integer): HBITMAP;
begin
  raise Exception.Create('Not implemented image generation');
end;

procedure TPercentIconRenderer.AssignColors;
var
  GreenColor, YellowColor, RedColor: TGPColor;

  function ChangeBrightness(Color: TGPColor; DB: Double): TGPColor;
  var
    Hue, Saturation, Brightness: Double;
  begin
    RGBToHSV(Color, Hue, Saturation, Brightness);
    Brightness := Brightness + DB;
    Result := HSVToRGB(Hue, Saturation, Brightness);
  end;

  function ChangeSaturation(Color: TGPColor; DS: Double): TGPColor;
  var
    Hue, Saturation, Brightness: Double;
  begin
    RGBToHSV(Color, Hue, Saturation, Brightness);
    Saturation := Saturation + DS;
    Result := HSVToRGB(Hue, Saturation, Brightness);
  end;
begin
  if (FOptions.IconTheme = ithDark) or FOptions.TrayIconDark then
  begin
    FCustomPowerSavingsColor := TGPColor.Black;
    GreenColor  := TGPColor.Create(56, 158, 13);  // #389e0d
    YellowColor := TGPColor.Create(135, 104, 0);  // #876800
    RedColor    := TGPColor.Create(213, 0, 0);    // #D50000
    FUltimatePowerSavingsColor := TGPColor.Create(114, 46, 209); // #722ed1

    if FOptions.IsIconStyleLight then
    begin
      GreenColor  := ChangeBrightness(GreenColor,   -0.1);
      YellowColor := ChangeBrightness(YellowColor,  -0.05);
      RedColor    := ChangeBrightness(RedColor,     -0.3);
      FUltimatePowerSavingsColor := ChangeBrightness(FUltimatePowerSavingsColor, -0.2);
    end;
  end
  else
  begin
    FCustomPowerSavingsColor := TGPColor.White;
    GreenColor  := TGPColor.Create(115, 209, 61);   // #73d13d
    YellowColor := TGPColor.Create(250, 219, 20);   // #fadb14
    RedColor    := TGPColor.Create(255, 77, 79);    // #ff4d4f
    FUltimatePowerSavingsColor := TGPColor.Create(179, 127, 235);  // #b37feb

    if FOptions.IsIconStyleLight then
    begin
      GreenColor  := ChangeSaturation(GreenColor,   -0.5);
      YellowColor := ChangeSaturation(YellowColor,  -0.5);
      RedColor    := ChangeSaturation(RedColor,     -0.5);
      FUltimatePowerSavingsColor := ChangeSaturation(FUltimatePowerSavingsColor, -0.3);
    end;
  end;

  case FOptions.IconColorType of
    ictScheme, ictLevel, ictCharger, ictChargerAndLevel:
    begin
      FMaxPowerSavingsColor := GreenColor;
      FMinPowerSavingsColor := RedColor;
    end;
    ictSchemeInvert, ictLevelInvert:
    begin
      FMaxPowerSavingsColor := RedColor;
      FMinPowerSavingsColor := GreenColor;
    end;
    else
    begin
      FMaxPowerSavingsColor := FCustomPowerSavingsColor;
      FMinPowerSavingsColor := FCustomPowerSavingsColor;
    end;
  end;

  if (FOptions.IconColorType = ictMonochrome) or FOptions.TypicalPowerSavingsMonochrome then
    FTypicalPowerSavingsColor := FCustomPowerSavingsColor
  else
    FTypicalPowerSavingsColor := YellowColor;
end;

end.
