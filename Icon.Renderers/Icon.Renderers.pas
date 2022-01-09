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
  TIconBehavior = (
    ibIcon = 0,
    ibPercent = 1);
  TIconColorType = (
    ictScheme = 0,
    ictMonochrome = 1,
    ictLevel = 2,
    ictSchemeInvert = 3,
    ictLevelInvert = 4,
    ictCharger = 5,
    ictChargerAndLevel = 6);
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
    FIconColorLevelLow: Byte;
    FIconColorLevelMid: Byte;
    FIconColorChargerLevelCritical: Byte;
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
    procedure SetIconColorLevelLow(const Value: Byte);
    procedure SetIconColorLevelMid(const Value: Byte);
    procedure SetIconColorChargerLevelCritical(const Value: Byte);
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
    class function DefaultIconColorLevelLow: Byte;
    class function DefaultIconColorLevelMid: Byte;
    class function DefaultIconColorChargerLevelCritical: Byte;

    property IconStyle: TIconStyle read FIconStyle write SetIconStyle;
    property EffectiveIconStyle: TIconStyle read FEffectiveIconStyle;
    property IconColorType: TIconColorType read FIconColorType write SetIconColorType;
    property IconColorLevelLow: Byte read FIconColorLevelLow write SetIconColorLevelLow;
    property IconColorLevelMid: Byte read FIconColorLevelMid write SetIconColorLevelMid;
    property IconColorChargerLevelCritical: Byte read FIconColorChargerLevelCritical write SetIconColorChargerLevelCritical;
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

  TBaseIconRenderer = class(TInterfacedObject, IIconRenderer)
  protected type
    TColorLevel = (clLow, clMid, clHigh, clUnknown);
  protected
    class function IsFlag(b: Byte; Flag: Byte): Boolean; inline; static;
  protected
    FOptions: TIconsOptions;

    function PercentageToLevel(Percentage: DWORD): TColorLevel;
    function IsPercentageCritical(Percentage: DWORD): Boolean;
  public
    constructor Create(Options: TIconsOptions); reintroduce;

    function GenerateIcon(IconParams: TIconParams; Dpi: Integer): HICON; virtual; abstract;
    function GenerateImage(IconParams: TIconParams; Dpi: Integer): HBITMAP; virtual; abstract;
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

class function TIconsOptions.DefaultIconColorLevelLow: Byte;
begin
  Result := 25;
end;

class function TIconsOptions.DefaultIconColorLevelMid: Byte;
begin
  Result := 50;
end;

class function TIconsOptions.DefaultIconColorChargerLevelCritical: Byte;
begin
  Result := 15;
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

procedure TIconsOptions.SetIconColorLevelLow(const Value: Byte);
begin
  if Value in [0 .. 100] then
    FIconColorLevelLow := Value
  else
    FIconColorLevelLow := DefaultIconColorLevelLow;

  DoChange;
end;

procedure TIconsOptions.SetIconColorLevelMid(const Value: Byte);
begin
  if Value in [0 .. 100] then
    FIconColorLevelMid := Value
  else
    FIconColorLevelMid := DefaultIconColorLevelMid;

  DoChange;
end;

procedure TIconsOptions.SetIconColorChargerLevelCritical(const Value: Byte);
begin
  if Value in [0 .. 100] then
    FIconColorChargerLevelCritical := Value
  else
    FIconColorChargerLevelCritical := DefaultIconColorChargerLevelCritical;

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

{ TBaseIconRenderer }

class function TBaseIconRenderer.IsFlag(b, Flag: Byte): Boolean;
begin
  Result := b and Flag = Flag;
end;

constructor TBaseIconRenderer.Create(Options: TIconsOptions);
begin
  inherited Create;
  FOptions := Options;
end;

function TBaseIconRenderer.PercentageToLevel(Percentage: DWORD): TColorLevel;
begin
  if Percentage > 100 then Exit(clUnknown);
  if Percentage > FOptions.IconColorLevelMid then Exit(clHigh);
  if Percentage > FOptions.IconColorLevelLow then Exit(clMid);
  Exit(clLow);
end;

function TBaseIconRenderer.IsPercentageCritical(Percentage: DWORD): Boolean;
begin
  Result := Percentage <= FOptions.IconColorChargerLevelCritical;
end;

end.
