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
    FOriginRedColor: TGPColor;
    FOriginGreenColor: TGPColor;
    FOriginYellowColor: TGPColor;
    FOriginWhiteColor: TGPColor;
    FOriginBlackColor: TGPColor;

    FMaxPowerSavingsColor: TGPColor;
    FTypicalPowerSavingsColor: TGPColor;
    FMinPowerSavingsColor: TGPColor;
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

  FOriginRedColor := TGPColor.Create(255, 0, 51);
  FOriginGreenColor := TGPColor.Create(102, 204, 0);
  FOriginYellowColor := TGPColor.Create(255, 204, 51);
  FOriginWhiteColor := TGPColor.White;
  FOriginBlackColor := TGPColor.Black;

  AssignColors;
end;

function TPercentIconRenderer.GenerateIcon(IconParams: TIconParams; Dpi: Integer): HICON;
var
  Icon: IGPBitmap;
  Graphic: IGPGraphics;
  Font: IGPFont;
  FontSize: Single;
  Rect: TGPRectF;
  Format: IGPStringFormat;
  Color: TGPColor;
  IsOverlayAsScheme: Boolean;
begin
  IsOverlayAsScheme := not (psfMissingScheme in TBatteryMode.PowerSchemes.SchemeFeatures);

  if IsWindows10Update1607OrGreater then
    Icon := TGPBitmap.Create(GetSystemMetricsForDpi(SM_CXSMICON, Dpi), GetSystemMetricsForDpi(SM_CYSMICON, Dpi))
  else
    Icon := TGPBitmap.Create(GetSystemMetrics(SM_CXSMICON), GetSystemMetrics(SM_CYSMICON));

  Icon.SetResolution(Dpi, Dpi);

  FontSize := 12;
  if IconParams.State.Percentage >= 100 then FontSize := 10;
  FontSize := FontSize * Dpi/96;

  Font := TGPFont.Create('Microsoft Sans Serif', FontSize, [], UnitPixel);
  Rect := TGPRectF.Create(0, 0, Icon.Width, Icon.Height - 1);
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
          else Color := FCustomPowerSavingsColor;
        end;
      end;
    end;
  end;

  Graphic := TGPGraphics.Create(Icon);
  Graphic.TextRenderingHint := TextRenderingHintSingleBitPerPixelGridFit;
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
    FCustomPowerSavingsColor := FOriginBlackColor;
    GreenColor  := ChangeBrightness(FOriginGreenColor,  -0.3);
    YellowColor := ChangeBrightness(FOriginYellowColor, -0.5);
    RedColor    := ChangeBrightness(FOriginRedColor,    -0.3);
  end
  else
  begin
    FCustomPowerSavingsColor := FOriginWhiteColor;
    GreenColor  := ChangeSaturation(FOriginGreenColor,  -0.5);
    YellowColor := ChangeSaturation(FOriginYellowColor, -0.5);
    RedColor    := ChangeSaturation(FOriginRedColor,    -0.5);
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
