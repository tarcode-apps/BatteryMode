unit Api.Pipe.Command;

interface

uses
  System.SysUtils;

const
  CommandPipeName = 'BatteryModeCmdPipe';

type
  TApiCommandType = (actUnknown, actChangeScheme, actSetBrightness, actGetBrightnessMonitors, actBrightnessMonitors);

  IApiCommand = interface
    function GetCommandType: TApiCommandType;
    function GetCommandBody: string;

    function Parse(S: string): Boolean;
    function GetCommand: string;

    property CommandType: TApiCommandType read GetCommandType;
    property CommandBody: string read GetCommandBody;
  end;

  // CommandType#CommandBody
  TApiBaseCommand = class(TInterfacedObject, IApiCommand)
  protected const
    HeadDelimiter = '#';
  protected
    FCommandType: TApiCommandType;
    FCommandBody: string;
    function GetCommandType: TApiCommandType; virtual;
    function GetCommandBody: string; virtual;
  public
    function Parse(S: string): Boolean; virtual;
    function GetCommand: string; virtual;

    property CommandType: TApiCommandType read GetCommandType;
    property CommandBody: string read GetCommandBody;
  end;

  // actChangeScheme#Next|Economy|Typical|Performance|Custom[@:<GUID>]
  TApiChangeScheme = class(TApiBaseCommand)
  type
    TSchemeType = (stNext, stMaxPowerSavings, stTypicalPowerSavings, stMinPowerSavings, stCustom);
  protected const
    CmdNextScheme           = 'Next';
    CmdMaxPowerSavings      = 'Economy';
    CmdTypicalPowerSavings  = 'Typical';
    CmdMinPowerSavings      = 'Performance';
    CmdCustom               = 'Custom';
    UniqueStringDelimiter = '@:';
  private
    FSchemeType: TSchemeType;
    FUniqueString: string;
  protected
    function GetCommandType: TApiCommandType; override;
    function GetCommandBody: string; override;
    function SchemeTypeText(Scheme: TSchemeType): string;
  public
    constructor Create(Scheme: TSchemeType); overload;
    constructor Create(Scheme: TSchemeType; UniqueString: string); overload;
    function Parse(S: string): Boolean; override;

    property SchemeType: TSchemeType read FSchemeType;
    property UniqueString: string read FUniqueString;
  end;

  // actSetBrightness#<UniqueString>@:Level|Brightness@:<Value>
  TApiSetBrightness = class(TApiBaseCommand)
  type
    TChangeType = (ctLevel, ctBrightness);
  protected const
    CmdLevel      = 'Level';
    CmdBrightness = 'Brightness';
    ValueDelimiter      = '@:';
  private
    FUniqueString: string;
    FChangeType: TChangeType;
    FValue: Integer;
  protected
    function GetCommandType: TApiCommandType; override;
    function GetCommandBody: string; override;
    function ChangeTypeText(ChangeType: TChangeType): string;
  public
    constructor Create(UniqueString: string; ChangeType: TChangeType; Value: Integer); overload;
    function Parse(S: string): Boolean; override;

    property UniqueString: string read FUniqueString;
    property ChangeType: TChangeType read FChangeType;
    property Value: Integer read FValue;
  end;

  // actGetBrightnessMonitors#GetBrightnessMonitors
  TApiGetBrightnessMonitors = class(TApiBaseCommand)
  protected const
    Cmd = 'GetBrightnessMonitors';
  protected
    function GetCommandBody: string; override;
    function GetCommandType: TApiCommandType; override;
  public
    function Parse(S: string): Boolean; override;    
  end;

  // actBrightnessMonitors#<UniqueString>@:<Description>@:Level,...,Level@:CurrentLevel@;<UniqueString>...
  TApiBrightnessMonitors = class(TApiBaseCommand)
  type
    TMonitorInfo = record
      Description: string;
      UniqueString: string;
      Level: Integer;
      Levels: array of Integer;
    end;
    TMonitorsInfo = array of TMonitorInfo;
  protected const
    MonitorDelimiter  = '@;';
    ValueDelimiter    = '@:';
    LevelDelimiter    = ',';
  protected
    FMonitorsInfo: TMonitorsInfo;
    function GetMonitor(Index: Integer): TMonitorInfo;
    function GetMonitorCount: Integer;
    
    function GetCommandType: TApiCommandType; override;
    function GetCommandBody: string; override;
  public
    function Parse(S: string): Boolean; override;
    
    property Monitor[Index : Integer]: TMonitorInfo read GetMonitor;
    property MonitorCount: Integer read GetMonitorCount;
  end;

implementation

{ TApiBaseCommand }

function TApiBaseCommand.Parse(S: string): Boolean;
var
  Parts: TArray<string>;
begin
  Result := True;
  try
    Parts := S.Split([HeadDelimiter], 2);
    FCommandType := TApiCommandType(Parts[0].ToInteger);
    FCommandBody := Parts[1];
  except
    Result := False;
  end;
end;

function TApiBaseCommand.GetCommandType: TApiCommandType;
begin
  Result := FCommandType;
end;

function TApiBaseCommand.GetCommandBody: string;
begin
  Result := FCommandBody;
end;

function TApiBaseCommand.GetCommand: string;
begin
  Result := string.Join(HeadDelimiter, [string.Parse(Integer(CommandType)), CommandBody]);
end;

{ TApiChangeScheme }

constructor TApiChangeScheme.Create(Scheme: TSchemeType);
begin
  inherited Create;
  FCommandType := actChangeScheme;
  FSchemeType := Scheme;
  if Scheme = stCustom then
    raise Exception.Create('Custom scheme required UniqueString');
end;

constructor TApiChangeScheme.Create(Scheme: TSchemeType; UniqueString: string);
begin
  inherited Create;
  FCommandType := actChangeScheme;
  FSchemeType := Scheme;
  FUniqueString := UniqueString;
end;

function TApiChangeScheme.GetCommandBody: string;
begin
  if FSchemeType = stCustom then
    Result := string.Join(UniqueStringDelimiter, [SchemeTypeText(FSchemeType), FUniqueString])
  else
    Result := SchemeTypeText(FSchemeType);
end;

function TApiChangeScheme.GetCommandType: TApiCommandType;
begin
  Result := actChangeScheme;
end;

function TApiChangeScheme.Parse(S: string): Boolean;
var
  Parts: TArray<string>;
begin
  Result := inherited Parse(S);
  if not Result then Exit;

  Result := FCommandType = actChangeScheme;
  if not Result then Exit;

  if FCommandBody = CmdNextScheme then
  begin
    FSchemeType := stNext;
    Exit(True);
  end;

  if FCommandBody = CmdMaxPowerSavings then
  begin
    FSchemeType := stMaxPowerSavings;
    Exit(True);
  end;

  if FCommandBody = CmdTypicalPowerSavings then
  begin
    FSchemeType := stTypicalPowerSavings;
    Exit(True);
  end;

  if FCommandBody = CmdMinPowerSavings then
  begin
    FSchemeType := stMinPowerSavings;
    Exit(True);
  end;

  if FCommandBody.StartsWith(CmdCustom) then
  begin
    try
      Parts := FCommandBody.Split([UniqueStringDelimiter], 2, TStringSplitOptions.None);
      FSchemeType := stCustom;
      FUniqueString := Parts[1];
      Exit(True);
    except
      Exit(False);
    end;
  end;

  Result := False;
end;

function TApiChangeScheme.SchemeTypeText(Scheme: TSchemeType): string;
begin
  case Scheme of
    stNext: Result := CmdNextScheme;
    stMaxPowerSavings: Result := CmdMaxPowerSavings;
    stTypicalPowerSavings: Result := CmdTypicalPowerSavings;
    stMinPowerSavings: Result := CmdMinPowerSavings;
    stCustom: Result := CmdCustom;
  end;
end;

{ TApiSetBrightness }

constructor TApiSetBrightness.Create(UniqueString: string; ChangeType: TChangeType; Value: Integer);
begin
  inherited Create;
  FUniqueString := UniqueString;
  FChangeType := ChangeType;
  FValue := Value;
end;

function TApiSetBrightness.GetCommandBody: string;
begin
  Result := string.Join(ValueDelimiter,
    [FUniqueString, ChangeTypeText(FChangeType), FValue.ToString]);
end;

function TApiSetBrightness.GetCommandType: TApiCommandType;
begin
  Result := actSetBrightness;
end;

function TApiSetBrightness.Parse(S: string): Boolean;
var
  Parts: TArray<string>;
begin
  Result := inherited Parse(S);
  if not Result then Exit;

  Result := FCommandType = actSetBrightness;
  if not Result then Exit;

  try
    Parts := FCommandBody.Split([ValueDelimiter], 3, TStringSplitOptions.None);
    FUniqueString := string.Copy(Parts[0]);
    FValue := Integer.Parse(Parts[2]);

    if Parts[1] = CmdLevel then
    begin
      FChangeType := ctLevel;
      Exit(True);
    end;

    if Parts[1] = CmdBrightness then
    begin
      FChangeType := ctBrightness;
      Exit(True);
    end;

    Result := False;
  except
    Result := False;
  end;
end;

function TApiSetBrightness.ChangeTypeText(ChangeType: TChangeType): string;
begin
  case ChangeType of
    ctLevel: Result := CmdLevel;
    ctBrightness: Result := CmdBrightness;
  end;
end; 

{ TApiGetBrightnessMonitors }

function TApiGetBrightnessMonitors.GetCommandBody: string;
begin
  Result := Cmd;
end;

function TApiGetBrightnessMonitors.GetCommandType: TApiCommandType;
begin
  Result := actGetBrightnessMonitors;
end;

function TApiGetBrightnessMonitors.Parse(S: string): Boolean;
begin
  Result := inherited Parse(S);
  if not Result then Exit;

  Result := FCommandType = actGetBrightnessMonitors;
  if not Result then Exit;

  Result := FCommandBody = Cmd;  
end;

{ TApiBrightnessMonitors }

function TApiBrightnessMonitors.GetCommandBody: string;
var
  I, J: Integer;   
  LevelsStr: string;
  Monitor: string;
begin
  Result := '';
  for I := 0 to High(FMonitorsInfo) do
    with FMonitorsInfo[I] do
    begin
      LevelsStr := '';
      for J := 0 to Length(Levels) - 1 do
        if J = 0 then
          LevelsStr := Levels[J].ToString
        else
          LevelsStr := string.Join(LevelDelimiter, [LevelsStr, Levels[J]]);

      Monitor := string.Join(ValueDelimiter,
        [UniqueString, Description, LevelsStr, Level.ToString]);

      if I = 0 then
        Result := Monitor
      else
        Result := string.Join(MonitorDelimiter, [Result, Monitor]);
    end;
end;

function TApiBrightnessMonitors.GetCommandType: TApiCommandType;
begin
  Result := actBrightnessMonitors;
end;  

function TApiBrightnessMonitors.GetMonitor(Index: Integer): TMonitorInfo;
begin
  Result := FMonitorsInfo[Index];
end;

function TApiBrightnessMonitors.GetMonitorCount: Integer;
begin
  Result := Length(FMonitorsInfo);
end;

function TApiBrightnessMonitors.Parse(S: string): Boolean;
var
  MonitorsParts: TArray<string>;
  ValuesParts: TArray<string>;
  LevelsParts: TArray<string>;
  MonitorPartsCount: Integer;
  LevelsPartsCount: Integer;
  I, J: Integer;
begin
  Result := inherited Parse(S);
  if not Result then Exit;

  Result := FCommandType = actBrightnessMonitors;
  if not Result then Exit;

  try
    MonitorsParts := FCommandBody.Split([MonitorDelimiter], TStringSplitOptions.None);
    MonitorPartsCount := Length(MonitorsParts);
    SetLength(FMonitorsInfo, MonitorPartsCount);

    for I := 0 to MonitorPartsCount - 1 do
      with FMonitorsInfo[I] do
      begin
        ValuesParts := MonitorsParts[I].Split([ValueDelimiter], 4, TStringSplitOptions.None);
        UniqueString := ValuesParts[0]; 
        Description := ValuesParts[1];

        LevelsParts := ValuesParts[2].Split([LevelDelimiter]); 
        LevelsPartsCount := Length(LevelsParts);
        SetLength(Levels, LevelsPartsCount);
        for J := 0 to LevelsPartsCount - 1 do
          Levels[J] := Integer.Parse(LevelsParts[J]);

        Level := Integer.Parse(ValuesParts[3]);
      end;
  except
    Result := False;
  end;
end;

end.
