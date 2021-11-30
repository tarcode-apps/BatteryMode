unit Icon.Renderers;

interface

uses
  Winapi.Windows,
  System.Classes,
  Battery.Mode,
  Versions.Helpers;

type
  TIconStyle = (
    isAuto = -1,
    isWin8 = 0,
    isWin10 = 1,
    isWin7 = 2,
    isWin8Light = 3,
    isWin10Light = 4,
    isWinXp = 5,
    isWinVista = 6,
    isWin11 = 7,
    isWin11Light = 8);
  TIconBehavior = (ibIcon, ibPercent);
  TIconColorType = (ictScheme, ictMonochrome, ictLevel, ictSchemeInvert, ictLevelInvert);
  TIconTheme = (ithLight, ithDark);

  TIconParams = record
    PowerStatus: TSystemPowerStatus;
    State: TBatteryState;
    constructor Create(aPowerStatus: TSystemPowerStatus; aState: TBatteryState);
  end;

  TIconsOptions = class
  private
    FIconStyle: TIconStyle;
    FEffectiveIconStyle: TIconStyle;
    FIconColorType: TIconColorType;
    FExplicitMissingBattery: Boolean;
    FTypicalPowerSavingsMonochrome: Boolean;
    FIconBehavior: TIconBehavior;
    FIconTheme: TIconTheme;
    FTrayIconDark: Boolean;
    FOnChange: TNotifyEvent;
    FOnChange2: TNotifyEvent;

    procedure SetExplicitMissingBattery(const Value: Boolean);
    procedure SetIconBehavior(const Value: TIconBehavior);
    procedure SetIconColorType(const Value: TIconColorType);
    procedure SetIconStyle(const Value: TIconStyle);
    procedure SetIconTheme(const Value: TIconTheme);
    procedure SetTrayIconDark(const Value: Boolean);
    procedure SetTypicalPowerSavingsMonochrome(const Value: Boolean);
    procedure SetOnChange(const Value: TNotifyEvent);
    procedure SetOnChange2(const Value: TNotifyEvent);

    procedure DoChange;
  public
    class function DefaultIconStyle: TIconStyle;
    class function DefaultIconBehavior: TIconBehavior;
    class function DefaultIconColorType: TIconColorType;
    class function DefaultIconTheme: TIconTheme;

    property IconStyle: TIconStyle read FIconStyle write SetIconStyle;
    property EffectiveIconStyle: TIconStyle read FEffectiveIconStyle;
    property IconColorType: TIconColorType read FIconColorType write SetIconColorType;
    property ExplicitMissingBattery: Boolean read FExplicitMissingBattery write SetExplicitMissingBattery;
    property TypicalPowerSavingsMonochrome: Boolean read FTypicalPowerSavingsMonochrome write SetTypicalPowerSavingsMonochrome;
    property IconBehavior: TIconBehavior read FIconBehavior write SetIconBehavior;
    property IconTheme: TIconTheme read FIconTheme write SetIconTheme;
    property TrayIconDark: Boolean read FTrayIconDark write SetTrayIconDark;

    property OnChange: TNotifyEvent read FOnChange write SetOnChange;
    property OnChange2: TNotifyEvent read FOnChange2 write SetOnChange2;
  end;

  IIconRenderer = interface
    function GenerateIcon(IconParams: TIconParams; Dpi: Integer): HICON;
    function GenerateImage(IconParams: TIconParams; Dpi: Integer): HBITMAP;
  end;

implementation

{ TIconsOptions }

class function TIconsOptions.DefaultIconBehavior: TIconBehavior;
begin
  Result := TIconBehavior.ibIcon;
end;

class function TIconsOptions.DefaultIconColorType: TIconColorType;
begin
  if IsWindowsVistaOrGreater then Exit(ictScheme);
  if TBatteryMode.State.Mobile or TBatteryMode.State.BatteryPresent then Exit(ictLevel);

  Result := ictMonochrome;
end;

class function TIconsOptions.DefaultIconStyle: TIconStyle;
begin
  if IsWindows11OrGreater then Exit(isWin11);
  if IsWindows10OrGreater then Exit(isWin10);
  if IsWindows8OrGreater then Exit(isWin8);
  if IsWindows7OrGreater then Exit(isWin7);
  if IsWindowsVistaOrGreater then Exit(isWinVista);
  if IsWindowsXPOrGreater then Exit(isWinXp);

  Result := isWin7;
end;

class function TIconsOptions.DefaultIconTheme: TIconTheme;
begin
  Result := ithLight;
end;

procedure TIconsOptions.SetExplicitMissingBattery(const Value: Boolean);
begin
  FExplicitMissingBattery := Value;
  DoChange;
end;

procedure TIconsOptions.SetIconBehavior(const Value: TIconBehavior);
begin
  if Value in [Low(TIconBehavior) .. High(TIconBehavior)] then
    FIconBehavior := Value
  else
    FIconBehavior := DefaultIconBehavior;

  DoChange;
end;

procedure TIconsOptions.SetIconColorType(const Value: TIconColorType);
begin
  if Value in [Low(TIconColorType) .. High(TIconColorType)] then
    FIconColorType := Value
  else
    FIconColorType := DefaultIconColorType;

  if (FIconColorType = ictLevel) and
     not IsWindowsVistaOrGreater and
     not (TBatteryMode.State.Mobile or TBatteryMode.State.BatteryPresent) then
    FIconColorType := ictScheme;

  if (FIconColorType = ictScheme) and not IsWindowsVistaOrGreater then
    FIconColorType := ictMonochrome;

  DoChange;
end;

procedure TIconsOptions.SetIconStyle(const Value: TIconStyle);
begin
  if (Value > isAuto) and (Value <= High(TIconStyle)) then
  begin
    FIconStyle := Value;
    FEffectiveIconStyle := Value;
  end
  else
  begin
    FIconStyle := isAuto;
    FEffectiveIconStyle := DefaultIconStyle;
  end;

  DoChange;
end;

procedure TIconsOptions.SetIconTheme(const Value: TIconTheme);
begin
  if Value in [Low(TIconTheme) .. High(TIconTheme)] then
    FIconTheme := Value
  else
    FIconTheme := DefaultIconTheme;

  DoChange;
end;

procedure TIconsOptions.SetTrayIconDark(const Value: Boolean);
begin
  FTrayIconDark := Value;
  DoChange;
end;

procedure TIconsOptions.SetTypicalPowerSavingsMonochrome(const Value: Boolean);
begin
  FTypicalPowerSavingsMonochrome := Value;
  DoChange;
end;

procedure TIconsOptions.SetOnChange(const Value: TNotifyEvent);
begin
  FOnChange := Value;
end;

procedure TIconsOptions.SetOnChange2(const Value: TNotifyEvent);
begin
  FOnChange2 := Value;
end;

procedure TIconsOptions.DoChange;
begin
  if Assigned(FOnChange) then FOnChange(Self);
  if Assigned(FOnChange2) then FOnChange2(Self);
end;

{ TIconParams }

constructor TIconParams.Create(aPowerStatus: TSystemPowerStatus; aState: TBatteryState);
begin
  PowerStatus := aPowerStatus;
  State := aState;
end;

end.
