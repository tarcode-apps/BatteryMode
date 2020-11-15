unit Api.Pipe.Server.Command;

interface

uses
  Api.Pipe.Command,
  Battery.Mode,
  Power,
  Brightness, Brightness.Manager;

type
  IApiServerCommand = interface(IApiCommand)
    function Run: Boolean;
  end;

  TApiServerChangeScheme = class(TApiChangeScheme, IApiServerCommand)
  public
    function Run: Boolean;
  end;

  TApiServerSetBrightness = class(TApiSetBrightness, IApiServerCommand)
  private
    FBrightnessManager: TBrightnessManager;
  protected
    function LevelFromBrightness(Monitor: IBrightnessMonitor;
      Brightness: Integer): Integer;
  public
    constructor Create(BrightnessManager: TBrightnessManager);
    function Run: Boolean;
  end;

  TApiServerBrightnessMonitors = class(TApiBrightnessMonitors, IApiServerCommand)
  public
    constructor Create(BrightnessManager: TBrightnessManager);
    function Run: Boolean;
  end;

implementation

{ TApiServerChangeScheme }

function TApiServerChangeScheme.Run: Boolean;
var
  Scheme: IPowerScheme;
begin
  case SchemeType of
    stNext:                 Exit(TBatteryMode.NextScheme);
    stMaxPowerSavings :     Exit(TBatteryMode.MaxPowerSavings);
    stTypicalPowerSavings : Exit(TBatteryMode.TypicalPowerSavings);
    stMinPowerSavings :     Exit(TBatteryMode.MinPowerSavings);
    stCustom:
      begin
        Scheme := TBatteryMode.PowerSchemes.Schemes.Find(UniqueString);
        if Scheme <> nil then
          Exit(Scheme.Activate);
      end;
  end;
  Result := False;
end;

{ TApiSetChangeBrightness }

function TApiServerSetBrightness.Run: Boolean;
var
  Monitor: IBrightnessMonitor;

  procedure ChangeLevel(Monitor: IBrightnessMonitor; Level: Integer);
  begin
    if Level < 0 then Level := 0;
    if Level >= Monitor.Levels.Count then Level := Monitor.Levels.Count - 1;
    Monitor.Level := Level
  end;
begin
  Result := False;
  for Monitor in FBrightnessManager do
    if Monitor.Enable and (Monitor.UniqueString = UniqueString) then
    begin
      if ChangeType = ctLevel then
        ChangeLevel(Monitor, Value)
      else
        ChangeLevel(Monitor, LevelFromBrightness(Monitor, Value));

      Exit(True);
    end;
end;

constructor TApiServerSetBrightness.Create(
  BrightnessManager: TBrightnessManager);
begin
  inherited Create;
  FBrightnessManager := BrightnessManager;
end;

function TApiServerSetBrightness.LevelFromBrightness
  (Monitor: IBrightnessMonitor; Brightness: Integer): Integer;
var
  I: Integer;
begin
  with Monitor do
  begin
    if Brightness <= Levels.First then Exit(0);
    if Brightness > Levels.Last then Exit(Monitor.Levels.Count - 1);

    Result := 0;
    for I := 0 to Levels.Count - 2 do
      if (Brightness > Levels[I]) and (Brightness <= Levels[I + 1]) then
        if Brightness - Levels[I] > (Levels[I + 1] - Levels[I]) div 2 then
          Exit(I + 1)
        else
          Exit(I);
  end;
end;

{ TApiServerBrightnessMonitors }

constructor TApiServerBrightnessMonitors.Create(
  BrightnessManager: TBrightnessManager);
var
  Monitor: IBrightnessMonitor;
  I, J: Integer;
begin
  I := 0;
  for Monitor in BrightnessManager do
    if Monitor.Enable then
    begin
      SetLength(FMonitorsInfo, I + 1);
      FMonitorsInfo[I].Description := Monitor.Description;
      FMonitorsInfo[I].UniqueString := Monitor.UniqueString;

      SetLength(FMonitorsInfo[I].Levels, Monitor.Levels.Count);
      for J := 0 to Monitor.Levels.Count - 1 do
        FMonitorsInfo[I].Levels[J] := Monitor.Levels[J];

      FMonitorsInfo[I].Level := Monitor.Level;

      Inc(I);
    end;
end;

function TApiServerBrightnessMonitors.Run: Boolean;
begin
  Result := True;
end;

end.
