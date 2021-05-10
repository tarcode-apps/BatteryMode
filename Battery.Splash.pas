unit Battery.Splash;

interface

uses
  Winapi.Windows,  Winapi.ActiveX,
  System.SysUtils, System.Classes,
  Battery.Mode, Battery.Icons,
  Power,
  Power.WinApi.PowrProf,
  Helpers.Images.Generator,
  GdiPlus, SplashUnit, ScreenLiteUnit;

type
  /// <summary>
  ///  sdtNone - Никогда не отображать Splash
  ///  sdtSelf - Только при изменении схемы питания из приложения
  ///  sdtAlways - Всегда отображать
  /// </summary>
  TSplashDisplayType = (sdtNone, sdtSelf, sdtAlways);

  TBatterySplash = class(TSplash)
  private
    class var FSplashDisplayType: TSplashDisplayType;

    class var FBatteryState: TBatteryState;
    class var FInvertColor: Boolean;
    class var ImageList: IGPImage;

    class function PercentageToIndex(Percentage: DWORD): Integer;
    class procedure SetSplashDisplayType(const Value: TSplashDisplayType); static;

    class constructor Create;
  protected
    class procedure Enabling;
    class procedure Disabling;
    class function GetRealImageSize: TSize;
    class function GeneratePicture(Width, Height: Integer; Monitor: TMonitorLite): IGPBitmap;
  public
    class procedure ShowSplash(DisplayType: TSplashDisplayType; const State: TBatteryState; InverColor: Boolean); overload;

    class property SplashDisplayType: TSplashDisplayType read FSplashDisplayType write SetSplashDisplayType;
    class property MonitorConfig;
    class property Interval;
    class property Transparency;
    class property Showing;
    class property ScaleByScreen;
  end;

implementation

class procedure TBatterySplash.SetSplashDisplayType(
  const Value: TSplashDisplayType);
begin
  if FSplashDisplayType = Value then Exit;

  FSplashDisplayType := Value;
  Enable := Value <> sdtNone;
end;

class procedure TBatterySplash.Enabling;
var
  ResStream: TResourceStream;
  Stream: IStream;
begin
  ResStream := TResourceStream.Create(HInstance, 'BatterySplash', RT_RCDATA);
  try
    Stream := TStreamAdapter.Create(ResStream);
    ImageList := TGPImage.Create(Stream);
  finally
    ResStream.Free;
  end;
end;

class procedure TBatterySplash.Disabling;
begin
  //
end;

class procedure TBatterySplash.ShowSplash(DisplayType: TSplashDisplayType;
  const State: TBatteryState; InverColor: Boolean);
begin
  if (DisplayType <> FSplashDisplayType) or (FSplashDisplayType = sdtNone) then Exit;

  FBatteryState := State;
  FInvertColor := InverColor;
  inherited ShowSplash;
end;

class function TBatterySplash.GetRealImageSize: TSize;
begin
  Result.Create(ImageList.Height, ImageList.Height);
end;

class function TBatterySplash.GeneratePicture(Width, Height: Integer; Monitor: TMonitorLite): IGPBitmap;
const
  CircleGreen = 0;
  CircleYellow = 1;
  CircleRed = 2;
  CircleBlue = 3;

  RingGreen = 4;
  RingYellow = 5;
  RingRed = 6;
  RingBlue = 7;

  BatteryBody = 8;
  PercentageOffset = 9;
  Charge = 18;
var
  Graphics: IGPGraphics;
  Indexes: array of Integer;
  IsOverlayAsScheme: Boolean;
begin
  Indexes := [];
  IsOverlayAsScheme := not (psfMissingScheme in TBatteryMode.PowerSchemes.SchemeFeatures);

  if FInvertColor then
  begin
    case FBatteryState.PowerScheme.PowerSchemeType of
      pstMaxPowerSavings    : Indexes := Indexes + [CircleRed];
      pstTypicalPowerSavings:
      begin
        if IsOverlayAsScheme then
        begin
          case FBatteryState.PowerScheme.OverlaySchemeType of
            ostOverlayMin   : Indexes := Indexes + [CircleRed];
            ostOverlayHigh  : Indexes := Indexes + [CircleBlue];
            ostOverlayMax   : Indexes := Indexes + [CircleGreen];
            else              Indexes := Indexes + [CircleYellow];
          end;
        end
        else
        begin
          Indexes := Indexes + [CircleYellow];
        end;
      end;
      pstMinPowerSavings    : Indexes := Indexes + [CircleGreen];
      else                    Indexes := Indexes + [CircleBlue];
    end;

    case FBatteryState.PowerScheme.OverlaySchemeType of
      ostOverlayMin : Indexes := Indexes + [RingRed];
      ostOverlayHigh: Indexes := Indexes + [RingBlue];
      ostOverlayMax : Indexes := Indexes + [RingGreen];
      else Indexes := Indexes + [Indexes[0] + RingGreen];
    end;
  end
  else
  begin
    case FBatteryState.PowerScheme.PowerSchemeType of
      pstMaxPowerSavings    : Indexes := Indexes + [CircleGreen];
      pstTypicalPowerSavings:
      begin
        if IsOverlayAsScheme then
        begin
          case FBatteryState.PowerScheme.OverlaySchemeType of
            ostOverlayMin   : Indexes := Indexes + [CircleGreen];
            ostOverlayHigh  : Indexes := Indexes + [CircleBlue];
            ostOverlayMax   : Indexes := Indexes + [CircleRed];
            else              Indexes := Indexes + [CircleYellow];
          end;
        end
        else
        begin
          Indexes := Indexes + [CircleYellow];
        end;
      end;
      pstMinPowerSavings    : Indexes := Indexes + [CircleRed];
      else                    Indexes := Indexes + [CircleBlue];
    end;

    case FBatteryState.PowerScheme.OverlaySchemeType of
      ostOverlayMin : Indexes := Indexes + [RingGreen];
      ostOverlayHigh: Indexes := Indexes + [RingBlue];
      ostOverlayMax : Indexes := Indexes + [RingRed];
      else Indexes := Indexes + [Indexes[0] + RingGreen];
    end;
  end;

  Indexes := Indexes + [BatteryBody];

  if FBatteryState.PowerCondition = PoDc then
    Indexes := Indexes + [PercentageOffset + PercentageToIndex(FBatteryState.Percentage)]
  else
    Indexes := Indexes + [Charge];

  Result := TGPBitmap.Create(Width, Height);
  Graphics := TGPGraphics.Create(Result);
  Graphics.DrawImage(GenerateGPBitmapFromBitmap(ImageList, Indexes, 1, 0, Monitor.Dpi), 0, 0, Width, Height);
end;

class function TBatterySplash.PercentageToIndex(Percentage: DWORD): Integer;
begin
  case Percentage of
    0  ..  4: Result := 0;  // _
    5  .. 14: Result := 1;  // \
    15 .. 25: Result := 2;  // |
    26 .. 37: Result := 3;  // |\
    38 .. 49: Result := 4;  // ||
    50 .. 63: Result := 5;  // ||\
    64 .. 78: Result := 6;  // |||
    79 .. 94: Result := 7;  // |||\
    95 .. 100: Result := 8; // ||||
    else Result := 0;
  end;
end;

class constructor TBatterySplash.Create;
begin
  FSplashDisplayType := sdtNone;

  EnablingFunc := Enabling;
  DisablingFunc := Disabling;
  GetRealImageSizeFunc := GetRealImageSize;
  GeneratePictureFunc := GeneratePicture;

  FBatteryState := TBatteryMode.State;
  FInvertColor := (TIconHelper.IconColorType = ictSchemeInvert) or (TIconHelper.IconColorType = ictSchemeInvert);
end;

end.
