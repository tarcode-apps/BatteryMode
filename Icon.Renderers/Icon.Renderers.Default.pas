unit Icon.Renderers.Default;

interface

uses
  Winapi.Windows,
  Icon.Renderers,
  Helpers.Images.Generator,
  GdiPlus,
  Battery.Mode,
  Power, Power.WinApi.PowrProf;

type
  TDefaultIconRenderer = class(TInterfacedObject, IIconRenderer)
  strict private
    class function IsFlag(b: Byte; Flag: Byte): Boolean; inline; static;
  strict private
    FOptions: TIconsOptions;

    procedure PowerStatusToIndexes(const State: TBatteryState;
      const Status: TSystemPowerStatus; AnimateIndex: Int64;
      out Index1: Integer; out Index2: Integer; out OverlayIndex: Integer);
    function PercentageToIndex(Percentage: DWORD): Integer;
    function GetIconListName(Dpi: Integer): string;
    function GetImageListName(Dpi: Integer): string;
  public
    constructor Create(Options: TIconsOptions); reintroduce;

    function GenerateIcon(
      PowerStatus: TSystemPowerStatus;
      State: TBatteryState;
      Dpi: Integer): HICON;
    function GenerateImage(
      PowerStatus: TSystemPowerStatus;
      State: TBatteryState;
      Dpi: Integer): HBITMAP;
  end;

implementation

{ TDefaultIconRenderer }

constructor TDefaultIconRenderer.Create(Options: TIconsOptions);
begin
  inherited Create;

  FOptions := Options;
end;

function TDefaultIconRenderer.GenerateIcon(
  PowerStatus: TSystemPowerStatus;
  State: TBatteryState;
  Dpi: Integer): HICON;
var
  Index1, Index2, OverlayIndex: Integer;
  Line: Byte;
begin
  PowerStatusToIndexes(State, PowerStatus, -1, Index1, Index2, OverlayIndex);

  Line := 0;
  case FOptions.IconStyle of
    isWin10, isWin10Light:
      if (FOptions.IconTheme = ithDark) or FOptions.TrayIconDark then Line := 1;
    else
      if FOptions.IconTheme = ithDark then Line := 1;
  end;

  Result := GenerateGPBitmapFromRes(GetIconListName(Dpi),
    [Index1, Index2, OverlayIndex],
    2, Line,
    TPoint.Create(Dpi, Dpi)).GetHIcon;
end;

function TDefaultIconRenderer.GenerateImage(
  PowerStatus: TSystemPowerStatus;
  State: TBatteryState;
  Dpi: Integer): HBITMAP;
var
  Index1, Index2, OverlayIndex: Integer;
begin
  PowerStatusToIndexes(TBatteryMode.State, PowerStatus, -1,
    Index1, Index2, OverlayIndex);

  Result := GenerateGPBitmapFromRes(GetImageListName(Dpi),
    [Index1, Index2, OverlayIndex],
    1, 0,
    TPoint.Create(Dpi, Dpi)).GetHBitmap(TGPColor.Transparent);
end;

class function TDefaultIconRenderer.IsFlag(b, Flag: Byte): Boolean;
begin
  Result:= b and Flag = Flag;
end;

function TDefaultIconRenderer.PercentageToIndex(Percentage: DWORD): Integer;
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

procedure TDefaultIconRenderer.PowerStatusToIndexes(const State: TBatteryState;
  const Status: TSystemPowerStatus; AnimateIndex: Int64; out Index1, Index2,
  OverlayIndex: Integer);
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
    Options: TIconsOptions;
    SchemeType: TPowerSchemeType;
    OverlayType: TOverlaySchemeType;
    IsOverlayAsScheme: Boolean): Integer; inline;
  begin
    case Options.IconColorType of
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
                else
                  if Options.TypicalPowerSavingsMonochrome then
                    Exit(DesktopSchemeOffset + DesktopWhiteShift)
                  else
                    Exit(DesktopSchemeOffset + DesktopYellowShift);
              end;
            end
            else
            begin
              case OverlayType of
                ostOverlayMin:  Exit(DesktopOverlayOffset + DesktopOverlayMinShift);
                ostOverlayMax:  Exit(DesktopOverlayOffset + DesktopOverlayMaxShift);
                ostOverlayHigh: Exit(DesktopOverlayOffset + DesktopOverlayHighShift);
                else
                  if Options.TypicalPowerSavingsMonochrome then
                    Exit(DesktopSchemeOffset + DesktopWhiteShift)
                  else
                    Exit(DesktopSchemeOffset + DesktopYellowShift);
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
                else
                  if Options.TypicalPowerSavingsMonochrome then
                    Exit(DesktopSchemeOffset + DesktopWhiteShift)
                  else
                    Exit(DesktopSchemeOffset + DesktopYellowShift);
              end;
            end
            else
            begin
              case OverlayType of
                ostOverlayMin:  Exit(DesktopOverlayOffset + DesktopOverlayMaxShift);
                ostOverlayMax:  Exit(DesktopOverlayOffset + DesktopOverlayMinShift);
                ostOverlayHigh: Exit(DesktopOverlayOffset + DesktopOverlayHighShift);
                else
                  if Options.TypicalPowerSavingsMonochrome then
                    Exit(DesktopSchemeOffset + DesktopWhiteShift)
                  else
                    Exit(DesktopSchemeOffset + DesktopYellowShift);
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
      Index1 := GetDesktopScheme(
        FOptions,
        PowerScheme.PowerSchemeType,
        PowerScheme.OverlaySchemeType,
        IsOverlayAsScheme);
      Exit;
    end;

    // Ноутбуки

    // Значок
    case PowerCondition of
      PoAc: begin
        if IsFlag(Status.BatteryFlag, BATTERY_FLAG_NO_BATTERY) then begin
          if FOptions.ExplicitMissingBattery then
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
    case FOptions.IconColorType of
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
                else
                  if FOptions.TypicalPowerSavingsMonochrome then
                    Inc(Offset, WhiteShift)
                  else
                    Inc(Offset, YellowShift);
              end;
            end
            else
            begin
              case PowerScheme.OverlaySchemeType of
                ostOverlayMin:  Inc(Offset, OverlayMinShift);
                ostOverlayHigh: Inc(Offset, OverlayHighShift);
                ostOverlayMax:  Inc(Offset, OverlayMaxShift);
                else
                  if FOptions.TypicalPowerSavingsMonochrome then
                    Inc(Offset, WhiteShift)
                  else
                    Inc(Offset, YellowShift);
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
                else
                  if FOptions.TypicalPowerSavingsMonochrome then
                    Inc(Offset, WhiteShift)
                  else
                    Inc(Offset, YellowShift);
              end;
            end
            else
            begin
              case PowerScheme.OverlaySchemeType of
                ostOverlayMin:  Inc(Offset, OverlayMaxShift);
                ostOverlayHigh: Inc(Offset, OverlayHighShift);
                ostOverlayMax:  Inc(Offset, OverlayMinShift);
                else
                  if FOptions.TypicalPowerSavingsMonochrome then
                    Inc(Offset, WhiteShift)
                  else
                    Inc(Offset, YellowShift);
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

function TDefaultIconRenderer.GetIconListName(Dpi: Integer): string;
begin
  case FOptions.IconStyle of
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

function TDefaultIconRenderer.GetImageListName(Dpi: Integer): string;
begin
  case FOptions.IconStyle of
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

end.
