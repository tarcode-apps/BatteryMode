unit Battery.Icons;

interface

uses
  Winapi.Windows, Winapi.ActiveX,
  System.SysUtils, System.Classes,
  Battery.Mode,
  Power,
  Power.WinApi.PowrProf,
  Versions.Helpers,
  Helpers.Images.Generator,
  GdiPlus, GdiPlus.HSB.Helpers;

type
  TIconStyle = (isWin8, isWin10, isWin7, isWin8Light, isWin10Light, isWinXp, isWinVista);
  TIconBehavior = (ibIcon, ibPercent);
  TIconColorType = (ictScheme, ictMonochrome, ictLevel, ictSchemeInvert, ictLevelInvert);
  TIconTheme = (ithLight, ithDark);

  TIconHelper = class
  strict private
    class var OriginRedColor: TGPColor;
    class var OriginGreenColor: TGPColor;
    class var OriginYellowColor: TGPColor;
    class var OriginWhiteColor: TGPColor;
    class var OriginBlackColor: TGPColor;

    class var FIconStyle: TIconStyle;
    class var FIconColorType: TIconColorType;
    class var FExplicitMissingBattery: Boolean;
    class var FIconBehavior: TIconBehavior;
    class var FIconTheme: TIconTheme;
    class var FOnChange: TNotifyEvent;
    class var FMaxPowerSavingsColor: TGPColor;
    class var FTypicalPowerSavingsColor: TGPColor;
    class var FMinPowerSavingsColor: TGPColor;
    class var FCustomPowerSavingsColor: TGPColor;

    class constructor Create;

    class function GetIconListName(Dpi: Integer): string;
    class function GetImageListName(Dpi: Integer): string;
    class function GetPercentIcon(const State: TBatteryState; Dpi: Integer): HICON;
    class function IsFlag(b: Byte; Flag: Byte): Boolean; inline; static;

    class procedure PowerStatusToIndexes(const State: TBatteryState;
      const Status: TSystemPowerStatus; AnimateIndex: Int64;
      out Index1: Integer; out Index2: Integer; out OverlayIndex: Integer);
    class function PercentageToIndex(Percentage: DWORD): Integer;
    class procedure AssignColors; static;
    class procedure SetIconStyle(const Value: TIconStyle); static;
    class procedure SetIconColorType(const Value: TIconColorType); static;
    class procedure SetIconBehavior(const Value: TIconBehavior); static;
    class procedure SetIconTheme(const Value: TIconTheme); static;
    class procedure SetExplicitMissingBattery(const Value: Boolean); static;
    class procedure SetOnChange(const Value: TNotifyEvent); static;
  public
    class function GetIcon(Dpi: Integer): HICON;
    class function GetImage(Dpi: Integer): HBITMAP;
    class function GetImageAsIcon(Dpi: Integer): HICON;
    class function DefaultIconStyle: TIconStyle;
    class function DefaultIconBehavior: TIconBehavior;
    class function DefaultIconColorType: TIconColorType;
    class function DefaultIconTheme: TIconTheme;

    class property IconStyle: TIconStyle read FIconStyle write SetIconStyle;
    class property IconColorType: TIconColorType read FIconColorType write SetIconColorType;
    class property IconBehavior: TIconBehavior read FIconBehavior write SetIconBehavior;
    class property IconTheme: TIconTheme read FIconTheme write SetIconTheme;
    class property ExplicitMissingBattery: Boolean read FExplicitMissingBattery write SetExplicitMissingBattery;

    class property OnChange: TNotifyEvent read FOnChange write SetOnChange;
  end;

implementation

{ TIconHelper }

class function TIconHelper.GetIcon(Dpi: Integer): HICON;
var
  PowerStatus: TSystemPowerStatus;
  State: TBatteryState;
  Index1, Index2, OverlayIndex, Line: Integer;
begin
  if not GetSystemPowerStatus(PowerStatus) then
    ZeroMemory(@PowerStatus, SizeOf(PowerStatus));

  State := TBatteryMode.State;

  if (FIconBehavior = TIconBehavior.ibPercent) and
     State.BatteryPresent and
     (not IsFlag(PowerStatus.BatteryFlag, BATTERY_FLAG_NO_BATTERY)) and
     ((State.PowerCondition = PoAc) or (State.PowerCondition = PoDc)) then
  begin
    Result := GetPercentIcon(State, Dpi);
  end
  else
  begin
    PowerStatusToIndexes(TBatteryMode.State, PowerStatus, -1,
      Index1, Index2, OverlayIndex);

    case FIconTheme of
      ithDark: Line := 1;
      else Line := 0;
    end;

    Result := GenerateGPBitmapFromRes(GetIconListName(Dpi),
      [Index1, Index2, OverlayIndex],
      2, Line,
      TPoint.Create(Dpi, Dpi)).GetHIcon;
  end;
end;

class function TIconHelper.GetPercentIcon(const State: TBatteryState; Dpi: Integer): HICON;
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
  if State.Percentage >= 100 then FontSize := 10;
  FontSize := FontSize * Dpi/96;

  Font := TGPFont.Create('Microsoft Sans Serif', FontSize, [], UnitPixel);
  Rect := TGPRectF.Create(0, 0, Icon.Width, Icon.Height - 1);
  Format := TGPStringFormat.Create([StringFormatFlagsNoWrap]);
  Format.Alignment := TGPStringAlignment.StringAlignmentCenter;
  Format.LineAlignment := TGPStringAlignment.StringAlignmentCenter;
  Format.Trimming := TGPStringTrimming.StringTrimmingNone;

  if IsOverlayAsScheme then
  begin
    case State.PowerScheme.OverlaySchemeType of
      ostOverlayMin: Color := FMaxPowerSavingsColor;
      ostOverlayMax: Color := FMinPowerSavingsColor;
      ostOverlayHigh: Color := FCustomPowerSavingsColor;
      else Color := FTypicalPowerSavingsColor;
    end;
  end
  else
  begin
    case State.PowerScheme.PowerSchemeType of
      pstMaxPowerSavings: Color := FMaxPowerSavingsColor;
      pstTypicalPowerSavings: Color := FTypicalPowerSavingsColor;
      pstMinPowerSavings: Color := FMinPowerSavingsColor;
      else Color := FCustomPowerSavingsColor;
    end;
  end;

  Graphic := TGPGraphics.Create(Icon);
  Graphic.TextRenderingHint := TextRenderingHintSingleBitPerPixelGridFit;
  Graphic.DrawString(State.Percentage.ToString, Font, Rect, Format, TGPSolidBrush.Create(Color));

  Result := Icon.GetHIcon;
end;

class function TIconHelper.IsFlag(b, Flag: Byte): Boolean;
begin
  Result:= b and Flag = Flag;
end;

class function TIconHelper.GetImage(Dpi: Integer): HBITMAP;
var
  PowerStatus: TSystemPowerStatus;
  Index1, Index2, OverlayIndex: Integer;
begin
  if not GetSystemPowerStatus(PowerStatus) then
    ZeroMemory(@PowerStatus, SizeOf(PowerStatus));

  PowerStatusToIndexes(TBatteryMode.State, PowerStatus, -1,
    Index1, Index2, OverlayIndex);

  Result := GenerateGPBitmapFromRes(GetImageListName(Dpi),
    [Index1, Index2, OverlayIndex],
    1, 0,
    TPoint.Create(Dpi, Dpi)).GetHBitmap(TGPColor.Transparent);
end;

class function TIconHelper.GetImageAsIcon(Dpi: Integer): HICON;
var
  hBmp: HBITMAP;
begin
  hBmp := GetImage(Dpi);
  Result := HBitmapToHIcon(hBmp);
  DeleteObject(hBmp);
end;

class procedure TIconHelper.PowerStatusToIndexes(const State: TBatteryState;
  const Status: TSystemPowerStatus; AnimateIndex: Int64;
  out Index1: Integer; out Index2: Integer; out OverlayIndex: Integer);
const
  DcOffset        = 6;
  DcOverlayOffset = DcOffset + 10*4;
  AcOffset        = DcOverlayOffset + 10*3;
  AcOverlayOffset = AcOffset + 10*4;

  DesktopOffset         = AcOverlayOffset + 10*3;
  DesktopSchemeOffset   = DesktopOffset + 1;
  DesktopOverlayOffset  = DesktopSchemeOffset + 4;

  IndicatorOffset = DesktopOverlayOffset + 3;

  GreenShift   = 0;
  YellowShift  = 10;
  RedShift     = 20;
  WhiteShift   = 30;

  OverlayMinShift  = 40;
  OverlayMaxShift  = 50;
  OverlayHighShift = 60;

  DesktopGreenShift   = 0;
  DesktopYellowShift  = 1;
  DesktopRedShift     = 2;
  DesktopWhiteShift   = 3;

  DesktopOverlayMinShift  = 0;
  DesktopOverlayMaxShift  = 1;
  DesktopOverlayHighShift = 2;
var
  Offset: Integer;
  IsOverlayAsScheme: Boolean;

  function GetDesktopScheme(
    SchemeType: TPowerSchemeType;
    OverlayType: TOverlaySchemeType;
    IsOverlayAsScheme: Boolean): Integer; inline;
  begin
    case FIconColorType of
      ictScheme, ictLevel:
        case SchemeType of
          pstMaxPowerSavings:   Exit(DesktopSchemeOffset + DesktopGreenShift);
          pstTypicalPowerSavings:
            if IsOverlayAsScheme then
            begin
              case OverlayType of
                ostOverlayMin:  Exit(DesktopSchemeOffset + DesktopGreenShift);
                ostOverlayMax:  Exit(DesktopSchemeOffset + DesktopRedShift);
                ostOverlayHigh: Exit(DesktopSchemeOffset + DesktopWhiteShift);
                else            Exit(DesktopSchemeOffset + DesktopYellowShift);
              end;
            end
            else
            begin
              case OverlayType of
                ostOverlayMin:  Exit(DesktopOverlayOffset + DesktopOverlayMinShift);
                ostOverlayMax:  Exit(DesktopOverlayOffset + DesktopOverlayMaxShift);
                ostOverlayHigh: Exit(DesktopOverlayOffset + DesktopOverlayHighShift);
                else            Exit(DesktopSchemeOffset + DesktopYellowShift);
              end;
            end;
          pstMinPowerSavings:   Exit(DesktopSchemeOffset + DesktopRedShift);
          else                  Exit(DesktopSchemeOffset + DesktopWhiteShift);
        end;
      ictSchemeInvert, ictLevelInvert:
        case SchemeType of
          pstMaxPowerSavings:   Exit(DesktopSchemeOffset + DesktopRedShift);
          pstTypicalPowerSavings:
            if IsOverlayAsScheme then
            begin
              case OverlayType of
                ostOverlayMin:  Exit(DesktopSchemeOffset + DesktopRedShift);
                ostOverlayMax:  Exit(DesktopSchemeOffset + DesktopGreenShift);
                ostOverlayHigh: Exit(DesktopSchemeOffset + DesktopWhiteShift);
                else            Exit(DesktopSchemeOffset + DesktopYellowShift);
              end;
            end
            else
            begin
              case OverlayType of
                ostOverlayMin:  Exit(DesktopOverlayOffset + DesktopOverlayMaxShift);
                ostOverlayMax:  Exit(DesktopOverlayOffset + DesktopOverlayMinShift);
                ostOverlayHigh: Exit(DesktopOverlayOffset + DesktopOverlayHighShift);
                else            Exit(DesktopSchemeOffset + DesktopYellowShift);
              end;
            end;
          pstMinPowerSavings:   Exit(DesktopSchemeOffset + DesktopGreenShift);
          else                  Exit(DesktopSchemeOffset + DesktopWhiteShift);
        end;
      else                      Exit(DesktopSchemeOffset + DesktopWhiteShift);
    end;
  end;
begin
  Index1 := -1; // Проценты
  Index2 := -1; // Фон
  OverlayIndex := -1;

  IsOverlayAsScheme := not (psfMissingScheme in TBatteryMode.PowerSchemes.SchemeFeatures);

  with State do begin
    // Desktop без UPS
    if not BatteryPresent and (PowerCondition <> PoHot) then begin
      Index2 := DesktopOffset;
      Index1 := GetDesktopScheme(PowerScheme.PowerSchemeType, PowerScheme.OverlaySchemeType, IsOverlayAsScheme);
      Exit;
    end;

    // Ноутбуки

    // Значёк
    case PowerCondition of
      PoAc: begin
        if IsFlag(Status.BatteryFlag, BATTERY_FLAG_NO_BATTERY) then begin
          if FExplicitMissingBattery then
            Index2 := 5 // Батарея перечёркнутая + Сеть
          else
            Index2 := 4; // Серая батарея + Сеть
          Exit;
        end;
        Index2 := 3; // Батарея + сеть
        Offset := AcOffset;
      end;

      PoDc: begin
        Index2 := 0; // Батарея
        Offset := DcOffset;
      end;

      PoHot: begin
        if AnimateIndex < 0 then
          Index2 := 5 // Батарея перечёркнутая + Сеть
        else
          Index2 := 5 - AnimateIndex mod 2; // Серая батарея + Сеть | Батарея перечёркнутая + Сеть
        Exit;
      end;

      else begin
        Index2 := 2; // Батарея перечёркнутая
        Exit;
      end;
    end;

    // Проценты
    case FIconColorType of
      ictScheme:
        case PowerScheme.PowerSchemeType of
          pstMaxPowerSavings:   Inc(Offset, GreenShift);
          pstTypicalPowerSavings:
          begin
            if IsOverlayAsScheme then
            begin
              case PowerScheme.OverlaySchemeType of
                ostOverlayMin:  Inc(Offset, GreenShift);
                ostOverlayHigh: Inc(Offset, WhiteShift);
                ostOverlayMax:  Inc(Offset, RedShift);
                else            Inc(Offset, YellowShift);
              end;
            end
            else
            begin
              case PowerScheme.OverlaySchemeType of
                ostOverlayMin:  Inc(Offset, OverlayMinShift);
                ostOverlayHigh: Inc(Offset, OverlayHighShift);
                ostOverlayMax:  Inc(Offset, OverlayMaxShift);
                else            Inc(Offset, YellowShift);
              end;
            end;
          end;
          pstMinPowerSavings:   Inc(Offset, RedShift);
          else                  Inc(Offset, WhiteShift);
        end;
      ictSchemeInvert:
        case PowerScheme.PowerSchemeType of
          pstMaxPowerSavings:   Inc(Offset, RedShift);
          pstTypicalPowerSavings:
          begin
            if IsOverlayAsScheme then
            begin
              case PowerScheme.OverlaySchemeType of
                ostOverlayMin:  Inc(Offset, RedShift);
                ostOverlayHigh: Inc(Offset, WhiteShift);
                ostOverlayMax:  Inc(Offset, GreenShift);
                else            Inc(Offset, YellowShift);
              end;
            end
            else
            begin
              case PowerScheme.OverlaySchemeType of
                ostOverlayMin:  Inc(Offset, OverlayMaxShift);
                ostOverlayHigh: Inc(Offset, OverlayHighShift);
                ostOverlayMax:  Inc(Offset, OverlayMinShift);
                else            Inc(Offset, YellowShift);
              end;
            end;
          end;
          pstMinPowerSavings:   Inc(Offset, GreenShift);
          else                  Inc(Offset, WhiteShift);
        end;
      ictMonochrome:
        Inc(Offset, WhiteShift);
      ictLevel:
        case Percentage of
          0..25:    Inc(Offset, RedShift);
          26..50:   Inc(Offset, YellowShift);
          51..100:  Inc(Offset, GreenShift);
          else Inc(Offset, WhiteShift);
        end;
      ictLevelInvert:
        case Percentage of
          0..25:    Inc(Offset, GreenShift);
          26..50:   Inc(Offset, YellowShift);
          51..100:  Inc(Offset, RedShift);
          else Inc(Offset, WhiteShift);
        end;
      else Inc(Offset, WhiteShift);
    end;

    if AnimateIndex < 0 then
      Index1 := Offset + PercentageToIndex(Percentage)
    else
      Index1 := Offset + AnimateIndex mod 10;

    // Overlay
    if BatterySaver then
      OverlayIndex := IndicatorOffset + 2;

    if PowerCondition = PoDc then begin
      if Percentage <= PowerScheme.ReserveLevel[PowerCondition] then begin
        if (AnimateIndex < 0) or (AnimateIndex mod 2 = 0) then
          OverlayIndex := IndicatorOffset + 1; // Ошибка
      end else if Percentage <= PowerScheme.DischargeLevel[PowerCondition] then begin
        if (AnimateIndex < 0) or (AnimateIndex mod 2 = 0) then
          OverlayIndex := IndicatorOffset; // Внимание
      end;
    end;
  end;
end;

class procedure TIconHelper.SetIconStyle(const Value: TIconStyle);
begin
  if Value in [Low(TIconStyle) .. High(TIconStyle)] then
    FIconStyle := Value
  else
    FIconStyle := DefaultIconStyle;

  AssignColors;

  if Assigned(FOnChange) then
    FOnChange(nil);
end;

class procedure TIconHelper.SetIconColorType(const Value: TIconColorType);
begin
  if Value in [Low(TIconColorType) .. High(TIconColorType)] then
    FIconColorType := Value
  else
    FIconColorType := DefaultIconColorType;

  if (FIconColorType = ictScheme) and not IsWindowsVistaOrGreater then
    FIconColorType := ictMonochrome;

  AssignColors;

  if Assigned(FOnChange) then
    FOnChange(nil);
end;

class procedure TIconHelper.SetIconBehavior(const Value: TIconBehavior);
begin
  if Value in [Low(TIconBehavior) .. High(TIconBehavior)] then
    FIconBehavior := Value
  else
    FIconBehavior := DefaultIconBehavior;

  if Assigned(FOnChange) then
    FOnChange(nil);
end;

class procedure TIconHelper.SetIconTheme(const Value: TIconTheme);
begin
  if Value in [Low(TIconTheme) .. High(TIconTheme)] then
    FIconTheme := Value
  else
    FIconTheme := DefaultIconTheme;

  AssignColors;

  if Assigned(FOnChange) then
    FOnChange(nil);
end;

class procedure TIconHelper.SetExplicitMissingBattery(const Value: Boolean);
begin
  FExplicitMissingBattery := Value;

  if Assigned(FOnChange) then
    FOnChange(nil);
end;

class procedure TIconHelper.SetOnChange(const Value: TNotifyEvent);
begin
  FOnChange := Value;
  if Assigned(FOnChange) then
    FOnChange(nil);
end;

class function TIconHelper.GetIconListName(Dpi: Integer): string;
begin
  case FIconStyle of
    isWin10:
    begin
      if Dpi <= 96  then Exit('Win10IconList16');
      if Dpi <= 120 then Exit('Win10IconList20');
      if Dpi <= 144 then Exit('Win10IconList24');
      Exit('Win10IconList32');
    end;
    isWinXp:
    begin
      if Dpi <= 96  then Exit('WinXpIconList16');
      if Dpi <= 120 then Exit('WinXpIconList20');
      if Dpi <= 144 then Exit('WinXpIconList24');
      Exit('WinXpIconList32');
    end;
    isWinVista:
    begin
      if Dpi <= 96  then Exit('WinVistaIconList16');
      if Dpi <= 120 then Exit('WinVistaIconList20');
      if Dpi <= 144 then Exit('WinVistaIconList24');
      Exit('WinVistaIconList32');
    end;
    isWin7:
    begin
      if Dpi <= 96  then Exit('Win7IconList16');
      if Dpi <= 120 then Exit('Win7IconList20');
      if Dpi <= 144 then Exit('Win7IconList24');
      Exit('Win7IconList32');
    end;
    isWin8Light:
    begin
      if Dpi <= 96  then Exit('IconList16Light');
      if Dpi <= 120 then Exit('IconList20Light');
      if Dpi <= 144 then Exit('IconList24Light');
      Exit('IconList32Light');
    end;
    isWin10Light:
    begin
      if Dpi <= 96  then Exit('Win10IconList16Light');
      if Dpi <= 120 then Exit('Win10IconList20Light');
      if Dpi <= 144 then Exit('Win10IconList24Light');
      Exit('Win10IconList32Light');
    end;
    else begin
      if Dpi <= 96  then Exit('IconList16');
      if Dpi <= 120 then Exit('IconList20');
      if Dpi <= 144 then Exit('IconList24');
      Exit('IconList32');
    end;
  end;
end;

class function TIconHelper.GetImageListName(Dpi: Integer): string;
begin
  case FIconStyle of
    isWin10:
    begin
      if Dpi <= 96  then Exit('Win10ImageList32');
      if Dpi <= 120 then Exit('Win10ImageList44');
      if Dpi <= 144 then Exit('Win10ImageList44');
      Exit('Win10ImageList44');
    end;
    isWinXp:
    begin
      if Dpi <= 96  then Exit('WinXpImageList32');
      if Dpi <= 120 then Exit('WinXpImageList40');
      if Dpi <= 144 then Exit('WinXpImageList44');
      Exit('WinXpImageList44');
    end;
    isWinVista, isWin7:
    begin
      if Dpi <= 96  then Exit('Win7ImageList32');
      if Dpi <= 120 then Exit('Win7ImageList40');
      if Dpi <= 144 then Exit('Win7ImageList40');
      Exit('Win7ImageList40');
    end;
    isWin8Light:
    begin
      if Dpi <= 96  then Exit('ImageList32Light');
      if Dpi <= 120 then Exit('ImageList44Light');
      if Dpi <= 144 then Exit('ImageList44Light');
      Exit('ImageList44Light');
    end;
    isWin10Light:
    begin
      if Dpi <= 96  then Exit('Win10ImageList32Light');
      if Dpi <= 120 then Exit('Win10ImageList44Light');
      if Dpi <= 144 then Exit('Win10ImageList44Light');
      Exit('Win10ImageList44Light');
    end;
    else begin
      if Dpi <= 96  then Exit('ImageList32');
      if Dpi <= 120 then Exit('ImageList44');
      if Dpi <= 144 then Exit('ImageList44');
      Exit('ImageList44');
    end;
  end;
end;

class function TIconHelper.PercentageToIndex(Percentage: DWORD): Integer;
begin
  case Percentage of
    0  ..  4: Result := 0;
    5  .. 14: Result := 1;
    15 .. 24: Result := 2;
    25 .. 36: Result := 3;
    37 .. 47: Result := 4;
    48 .. 58: Result := 5;
    59 .. 72: Result := 6;
    73 .. 84: Result := 7;
    85 .. 95: Result := 8;
    96 ..100: Result := 9;
    else Result := 0;
  end;
end;

class procedure TIconHelper.AssignColors;
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
  case FIconTheme of
    ithLight:
    begin
      FCustomPowerSavingsColor := OriginWhiteColor;
      GreenColor  := ChangeSaturation(OriginGreenColor,  -0.5);
      YellowColor := ChangeSaturation(OriginYellowColor, -0.5);
      RedColor    := ChangeSaturation(OriginRedColor,    -0.5);
    end;
    else
    begin
      FCustomPowerSavingsColor := OriginBlackColor;
      GreenColor  := ChangeBrightness(OriginGreenColor,  -0.3);
      YellowColor := ChangeBrightness(OriginYellowColor, -0.5);
      RedColor    := ChangeBrightness(OriginRedColor,    -0.3);
    end;
  end;

  case FIconColorType of
    ictScheme, ictLevel:
    begin
      FMaxPowerSavingsColor := GreenColor;
      FTypicalPowerSavingsColor := YellowColor;
      FMinPowerSavingsColor := RedColor;
    end;
    ictSchemeInvert, ictLevelInvert:
    begin
      FMaxPowerSavingsColor := RedColor;
      FTypicalPowerSavingsColor := YellowColor;
      FMinPowerSavingsColor := GreenColor;
    end;
    else
    begin
      FMaxPowerSavingsColor := FCustomPowerSavingsColor;
      FTypicalPowerSavingsColor := FCustomPowerSavingsColor;
      FMinPowerSavingsColor := FCustomPowerSavingsColor;
    end;
  end;
end;

class function TIconHelper.DefaultIconStyle: TIconStyle;
begin
  if IsWindows10OrGreater then
    Result := isWin10
  else if IsWindows8OrGreater then
    Result := isWin8
  else if IsWindows7OrGreater then
    Result := isWin7
  else if IsWindowsVistaOrGreater then
    Result := isWinVista
  else if IsWindowsXPOrGreater then
    Result := isWinXp
  else
    Result := isWin7;
end;

class function TIconHelper.DefaultIconBehavior: TIconBehavior;
begin
  Result := TIconBehavior.ibIcon;
end;

class function TIconHelper.DefaultIconColorType: TIconColorType;
begin
  if IsWindowsVistaOrGreater then Exit(ictScheme);
  if TBatteryMode.State.Mobile or TBatteryMode.State.BatteryPresent then Exit(ictLevel);

  Result := ictMonochrome;
end;

class function TIconHelper.DefaultIconTheme: TIconTheme;
begin
  Result := ithLight;
end;

class constructor TIconHelper.Create;
begin
  FIconStyle := DefaultIconStyle;
  FIconColorType := DefaultIconColorType;
  FIconBehavior := DefaultIconBehavior;
  FIconTheme := DefaultIconTheme;
  FExplicitMissingBattery := True;

  OriginRedColor := TGPColor.Create(255, 0, 51);
  OriginGreenColor := TGPColor.Create(102, 204, 0);
  OriginYellowColor := TGPColor.Create(255, 204, 51);
  OriginWhiteColor := TGPColor.White;
  OriginBlackColor := TGPColor.Black;
end;

end.
