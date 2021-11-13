unit Icon.Renderers.Simple;

interface

uses
  Winapi.Windows,
  System.SysUtils,
  Icon.Renderers,
  Helpers.Images.Generator,
  GdiPlus,
  Battery.Mode,
  Power, Power.WinApi.PowrProf;

type
  TSimpleIconRenderer = class(TInterfacedObject, IIconRenderer)
  strict private
    class function IsFlag(b: Byte; Flag: Byte): Boolean; inline; static;
  strict private
    FOptions: TIconsOptions;

    procedure PowerStatusToIndexes(
      const State: TBatteryState;
      const Status: TSystemPowerStatus;
      AnimateIndex: Int64;
      out Line: Byte;
      out Index: Integer);
    function PercentageToIndex(Percentage: DWORD): Integer;
    function GetIconListName(Dpi: Integer): string;
    function GetImageListName(Dpi: Integer): string;
  public
    constructor Create(Options: TIconsOptions); reintroduce;

    function GenerateIcon(IconParams: TIconParams; Dpi: Integer): HICON;
    function GenerateImage(IconParams: TIconParams; Dpi: Integer): HBITMAP;
  end;

implementation

{ TSimpleIconRenderer }

constructor TSimpleIconRenderer.Create(Options: TIconsOptions);
begin
  inherited Create;

  FOptions := Options;
end;

function TSimpleIconRenderer.GenerateIcon(IconParams: TIconParams; Dpi: Integer): HICON;
var
  Index: Integer;
  Line, LineOffset: Byte;
begin
  PowerStatusToIndexes(IconParams.State, IconParams.PowerStatus, -1, Line, Index);

  if (FOptions.IconTheme = ithDark) or FOptions.TrayIconDark then
    LineOffset := 9
  else
    LineOffset := 0;

  Result := GenerateGPBitmapFromRes(GetIconListName(Dpi),
    [Index], 18, Line + LineOffset,
    TPoint.Create(Dpi, Dpi)).GetHIcon;
end;

function TSimpleIconRenderer.GenerateImage(IconParams: TIconParams; Dpi: Integer): HBITMAP;
var
  Index: Integer;
  Line: Byte;
begin
  PowerStatusToIndexes(IconParams.State, IconParams.PowerStatus, -1, Line, Index);

  Result := GenerateGPBitmapFromRes(GetImageListName(Dpi),
    [Index], 9, Line,
    TPoint.Create(Dpi, Dpi)).GetHBitmap(TGPColor.Transparent);
end;

class function TSimpleIconRenderer.IsFlag(b, Flag: Byte): Boolean;
begin
  Result:= b and Flag = Flag;
end;

function TSimpleIconRenderer.PercentageToIndex(Percentage: DWORD): Integer;
begin
  case Percentage of
    0  ..  3: Result := 0;
    4  .. 13: Result := 1;
    14 .. 23: Result := 2;
    24 .. 33: Result := 3;
    34 .. 43: Result := 4;
    44 .. 53: Result := 5;
    54 .. 63: Result := 6;
    64 .. 73: Result := 7;
    74 .. 83: Result := 8;
    84 .. 93: Result := 9;
    94 ..100: Result := 10;
    else Result := 0;
  end;
end;

procedure TSimpleIconRenderer.PowerStatusToIndexes(
  const State: TBatteryState;
  const Status: TSystemPowerStatus;
  AnimateIndex: Int64;
  out Line: Byte;
  out Index: Integer);
const
  DcLine = 0;
  AcLine = 1;
  ErrorLine = 2;
  WarningLine = 3;
  EcoLine = 4;
  EjectedLine = 6;
  EjectedAcLine = 7;
  DesktopLine = 8;

  PercentCount = 11;

  WhiteOffset   = 0;
  GreenOffset   = PercentCount;
  YellowOffset  = PercentCount * 2;
  RedOffset     = PercentCount * 3;
  PurpleOffset  = PercentCount * 4;

  OverlayMinOffset  = PercentCount * 5;
  OverlayMaxOffset  = PercentCount * 6;
  OverlayHighOffset = PercentCount * 7;

  DesktopOffset        = 0;
  DesktopWhiteOffset   = 1;
  DesktopGreenOffset   = 2;
  DesktopYellowOffset  = 3;
  DesktopRedOffset     = 4;
  DesktopPurpleOffset  = 5;

  DesktopOverlayMinOffset  = 5;
  DesktopOverlayMaxOffset  = 6;
  DesktopOverlayHighOffset = 7;
var
  IsOverlayAsScheme: Boolean;

  function GetDesktopScheme(
    Options: TIconsOptions;
    SchemeType: TPowerSchemeType;
    OverlayType: TOverlaySchemeType;
    IsOverlayAsScheme: Boolean): Integer; inline;
  begin
    case Options.IconColorType of
      ictScheme, ictLevel:
        case SchemeType of
          pstMaxPowerSavings:   Exit(DesktopGreenOffset);
          pstTypicalPowerSavings:
            if IsOverlayAsScheme then
            begin
              case OverlayType of
                ostOverlayMin:  Exit(DesktopGreenOffset);
                ostOverlayMax:  Exit(DesktopRedOffset);
                ostOverlayHigh: Exit(DesktopWhiteOffset);
                else
                  if Options.TypicalPowerSavingsMonochrome then
                    Exit(DesktopOffset)
                  else
                    Exit(DesktopYellowOffset);
              end;
            end
            else
            begin
              case OverlayType of
                ostOverlayMin:  Exit(DesktopOverlayMinOffset);
                ostOverlayMax:  Exit(DesktopOverlayMaxOffset);
                ostOverlayHigh: Exit(DesktopOverlayHighOffset);
                else
                  if Options.TypicalPowerSavingsMonochrome then
                    Exit(DesktopOffset)
                  else
                    Exit(DesktopYellowOffset);
              end;
            end;
          pstMinPowerSavings:       Exit(DesktopRedOffset);
          pstUltimatePowerSavings:  Exit(DesktopPurpleOffset);
          else                      Exit(DesktopWhiteOffset);
        end;
      ictSchemeInvert, ictLevelInvert:
        case SchemeType of
          pstMaxPowerSavings:   Exit(DesktopRedOffset);
          pstTypicalPowerSavings:
            if IsOverlayAsScheme then
            begin
              case OverlayType of
                ostOverlayMin:  Exit(DesktopRedOffset);
                ostOverlayMax:  Exit(DesktopGreenOffset);
                ostOverlayHigh: Exit(DesktopWhiteOffset);
                else
                  if Options.TypicalPowerSavingsMonochrome then
                    Exit(DesktopOffset)
                  else
                    Exit(DesktopYellowOffset);
              end;
            end
            else
            begin
              case OverlayType of
                ostOverlayMin:  Exit(DesktopOverlayMaxOffset);
                ostOverlayMax:  Exit(DesktopOverlayMinOffset);
                ostOverlayHigh: Exit(DesktopOverlayHighOffset);
                else
                  if Options.TypicalPowerSavingsMonochrome then
                    Exit(DesktopOffset)
                  else
                    Exit(DesktopYellowOffset);
              end;
            end;
          pstMinPowerSavings:       Exit(DesktopGreenOffset);
          pstUltimatePowerSavings:  Exit(DesktopPurpleOffset);
          else                      Exit(DesktopWhiteOffset);
        end;
      else                        Exit(DesktopWhiteOffset);
    end;
  end;
begin
  Line := 0;
  Index := 0;

  IsOverlayAsScheme := not (psfMissingScheme in TBatteryMode.PowerSchemes.SchemeFeatures);

  with State do begin
    // Desktop without UPS
    if not BatteryPresent and (PowerCondition <> PoHot) then begin
      Line := DesktopLine;
      Index := GetDesktopScheme(
        FOptions,
        PowerScheme.PowerSchemeType,
        PowerScheme.OverlaySchemeType,
        IsOverlayAsScheme);
      Exit;
    end;

    // Laptops
    case PowerCondition of
      PoAc: begin
        if IsFlag(Status.BatteryFlag, BATTERY_FLAG_NO_BATTERY) then begin
          Line := EjectedAcLine; // Ejected battery + AC
          Exit;
        end;
        Line := AcLine; // AC
      end;

      PoDc: begin
        Line := DcLine; // DC
      end;

      PoHot: begin
        if AnimateIndex < 0 then
        begin
          Line := EjectedAcLine; // Ejected battery + AC
          Exit;
        end;

        if AnimateIndex mod 2 = 0 then
          Line := EjectedAcLine // Ejected battery + AC
        else
          Line := AcLine; // AC

        Exit;
      end;

      else begin
        Line := EjectedLine; // Ejected battery
        Exit;
      end;
    end;

    // Scheme
    case FOptions.IconColorType of
      ictScheme:
        case PowerScheme.PowerSchemeType of
          pstMaxPowerSavings:   Index := GreenOffset;
          pstTypicalPowerSavings:
          begin
            if IsOverlayAsScheme then
            begin
              case PowerScheme.OverlaySchemeType of
                ostOverlayMin:  Index := GreenOffset;
                ostOverlayHigh: Index := WhiteOffset;
                ostOverlayMax:  Index := RedOffset;
                else
                  if FOptions.TypicalPowerSavingsMonochrome then
                    Index := WhiteOffset
                  else
                    Index := YellowOffset;
              end;
            end
            else
            begin
              case PowerScheme.OverlaySchemeType of
                ostOverlayMin:  Index := OverlayMinOffset;
                ostOverlayHigh: Index := OverlayHighOffset;
                ostOverlayMax:  Index := OverlayMaxOffset;
                else
                  if FOptions.TypicalPowerSavingsMonochrome then
                    Index := WhiteOffset
                  else
                    Index := YellowOffset;
              end;
            end;
          end;
          pstMinPowerSavings:       Index := RedOffset;
          pstUltimatePowerSavings:  Index := PurpleOffset;
          else                      Index := WhiteOffset;
        end;
      ictSchemeInvert:
        case PowerScheme.PowerSchemeType of
          pstMaxPowerSavings:   Index := RedOffset;
          pstTypicalPowerSavings:
          begin
            if IsOverlayAsScheme then
            begin
              case PowerScheme.OverlaySchemeType of
                ostOverlayMin:  Index := RedOffset;
                ostOverlayHigh: Index := WhiteOffset;
                ostOverlayMax:  Index := GreenOffset;
                else
                  if FOptions.TypicalPowerSavingsMonochrome then
                    Index := WhiteOffset
                  else
                    Index := YellowOffset;
              end;
            end
            else
            begin
              case PowerScheme.OverlaySchemeType of
                ostOverlayMin:  Index := OverlayMaxOffset;
                ostOverlayHigh: Index := OverlayHighOffset;
                ostOverlayMax:  Index := OverlayMinOffset;
                else
                  if FOptions.TypicalPowerSavingsMonochrome then
                    Index := WhiteOffset
                  else
                    Index := YellowOffset;
              end;
            end;
          end;
          pstMinPowerSavings:       Index := GreenOffset;
          pstUltimatePowerSavings:  Index := PurpleOffset;
          else                      Index := WhiteOffset;
        end;
      ictMonochrome:
        Index := WhiteOffset;
      ictLevel:
        case Percentage of
          0..25:    Index := RedOffset;
          26..50:   Index := YellowOffset;
          51..100:  Index := GreenOffset;
          else Index := WhiteOffset;
        end;
      ictLevelInvert:
        case Percentage of
          0..25:    Index := GreenOffset;
          26..50:   Index := YellowOffset;
          51..100:  Index := RedOffset;
          else Index := WhiteOffset;
        end;
      else Index := WhiteOffset;
    end;

    if AnimateIndex < 0 then
      Inc(Index, PercentageToIndex(Percentage))
    else
      Inc(Index, AnimateIndex mod 11);

    // Overlay
    if BatterySaver then
      Line := EcoLine; // Battery Saver

    if PowerCondition = PoDc then begin
      if Percentage <= PowerScheme.ReserveLevel[PowerCondition] then begin
        if (AnimateIndex < 0) or (AnimateIndex mod 2 = 0) then
          Line := ErrorLine; // Error
      end else if Percentage <= PowerScheme.DischargeLevel[PowerCondition] then begin
        if (AnimateIndex < 0) or (AnimateIndex mod 2 = 0) then
          Line := WarningLine; // Warning
      end;
    end;
  end;
end;

function TSimpleIconRenderer.GetIconListName(Dpi: Integer): string;
begin
  case FOptions.IconStyle of
    isWin11:
    begin
      if Dpi <= 96  then Exit('Win11Icons16');
      if Dpi <= 120 then Exit('Win11Icons20');
      if Dpi <= 144 then Exit('Win11Icons24');
      Exit('Win11Icons32');
    end;
    else raise Exception.Create('Not supported style');
  end;
end;

function TSimpleIconRenderer.GetImageListName(Dpi: Integer): string;
begin
  case FOptions.IconStyle of
    isWin11:
    begin
      if Dpi <= 96  then Exit('Win11Images32');
      if Dpi <= 120 then Exit('Win11Images44');
      if Dpi <= 144 then Exit('Win11Images44');
      Exit('Win11Images64');
    end;
    else raise Exception.Create('Not supported style');
  end;
end;

end.
