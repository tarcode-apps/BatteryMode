unit Core.Startup.Tasks;

interface

uses
  WinApi.Windows,
  System.SysUtils,
  Api.Pipe.Command, Api.Pipe.Client,
  Core.Language;

type
  TStartupTasks = class
  public const
    ERROR_Ok = $0000;
    ERROR_Autorun = $0001;
    ERROR_DelAutorun = $0002;
    ERROR_Mutex = $0004;
    ERROR_Pipe = $0008;

    CmdAutorun              = '-Autorun';
    CmdDelAutorun           = '-DelAutorun';
    CmdNextScheme           = '-Next';
    CmdMaxPowerSavings      = '-Economy';
    CmdTypicalPowerSavings  = '-Typical';
    CmdMinPowerSavings      = '-Performance';
    CmdUltimatePowerSavings = '-Ultimate';
    CmdGetBrightness        = '-GetBrightness';
    CmdSetBrightness        = '-SetBrightness';
  private const
    ParamLevel              = 'level';
  private
    class function ShowHelp(var ExitRequired: Boolean): UINT;
    class function GetMonitorsMsg(Cmd: TApiBrightnessMonitors): string;
    class procedure ShowMonitors(Cmd: TApiBrightnessMonitors);
    class function AddAutorun(var ExitRequired: Boolean): UINT;
    class function DelAutorun(var ExitRequired: Boolean): UINT;
    class function SendToApi(Command: IApiCommand): UINT;
    class function SendToApiAndWaitResponse(Command: IApiCommand; out Response: string): UINT;
  public
    class function PerformFromCmdInput(var ExitRequired: Boolean): UINT;
  end;

implementation

uses
  Autorun.Manager;

{ TTasks }

class function TStartupTasks.ShowHelp(var ExitRequired: Boolean): UINT;
const
  HelpMessage = 'CmdLine: [] [-Help] [-?] [/?] [?]' + sLineBreak +
    Char(VK_TAB)                + '[' +
      CmdNextScheme           + '] [' +
      CmdMaxPowerSavings      + '] [' +
      CmdTypicalPowerSavings  + '] [' +
      CmdMinPowerSavings      + '] [' +
      CmdUltimatePowerSavings + ']' + sLineBreak +
    Char(VK_TAB) + '[' + CmdGetBrightness + ']' + sLineBreak +
    Char(VK_TAB) + '[' + CmdSetBrightness + ' "<UniqueString>" ' + '[' + ParamLevel +']' + ' <Value>' + ']' + sLineBreak +
    sLineBreak +
    CmdNextScheme           + ' -- Set next power scheme'                   + sLineBreak +
    CmdMaxPowerSavings      + ' -- Set "Power saver" scheme'                + sLineBreak +
    CmdTypicalPowerSavings  + ' -- Set "Balanced" power scheme'             + sLineBreak +
    CmdMinPowerSavings      + ' -- Set "High performance" power scheme'     + sLineBreak +
    CmdUltimatePowerSavings + ' -- Set "Ultimate performance" power scheme' + sLineBreak +
    CmdGetBrightness        + ' -- Get brightness monitor list'             + sLineBreak +
    CmdSetBrightness        + ' -- Set brightness for monitor'              + sLineBreak +
      Char(VK_TAB) + '<UniqueString> -- Monitor ID. Use ' + CmdGetBrightness + ' command to find it' + sLineBreak +
      Char(VK_TAB) + ParamLevel + ' -- Set brightness to level number instead of percent' + sLineBreak +
      Char(VK_TAB) + '<Value> -- brightness percent value (or level)';
begin
  ExitRequired := True;
  MessageBox(0, HelpMessage, LPCTSTR(TLang[1]), MB_OK);
  Result := ERROR_Ok;
end;

class function TStartupTasks.GetMonitorsMsg(
  Cmd: TApiBrightnessMonitors): string;
const
  MonitorFmt = '%0:d. %1:s: "%2:s"' + sLineBreak + Char(VK_TAB) +
                    'Levels: %3:s' + sLineBreak + Char(VK_TAB) +
                    'Current level: %4:d';

  SerialLevelsFmt = '%0:d:%1:d, ..., %2:d:%3:d';

  MonitorFofmatMsg = 'Monitor info format:' + sLineBreak +
    '<N>. <Name>: "<UniqueString>"' + sLineBreak + Char(VK_TAB) +
      'Levels: <Level>:<Brightness>, ..., <Level>:<Brightness>' + sLineBreak + Char(VK_TAB) +
      'Current level: <CurrentLevel>' + sLineBreak + sLineBreak;
var
  LevelsMsg: string;
  I: Integer;
  J: Integer;

  /// <summary>
  ///   Определение того, что уровни распределены последовательно
  /// </summary>
  function IsSerialLevels(Levels: array of Integer): Boolean;
  var
    I: Integer;
  begin
    Result := True;

    for I := 1 to Length(Levels) - 1 do
      if Levels[I] <> I + Levels[0] then
        Exit(False);
  end;
begin
  Result := MonitorFofmatMsg;

  if Cmd.MonitorCount = 0 then
    Result := Result + 'Monitors not found.'
  else
    Result := Result + 'Monitors:' + sLineBreak;

  for I := 0 to Cmd.MonitorCount - 1 do
  begin
    if IsSerialLevels(Cmd.Monitor[I].Levels) then
      LevelsMsg := Format(SerialLevelsFmt,
        [0, Cmd.Monitor[I].Levels[0], High(Cmd.Monitor[I].Levels), Cmd.Monitor[I].Levels[High(Cmd.Monitor[I].Levels)]])
    else
      for J := 0 to High(Cmd.Monitor[I].Levels) do
      begin
        if J = 0 then
          LevelsMsg := J.ToString + ':' + Cmd.Monitor[I].Levels[J].ToString
        else
          LevelsMsg := LevelsMsg + ', ' + J.ToString + ':' + Cmd.Monitor[I].Levels[J].ToString;
      end;

    Result := Result + Format(MonitorFmt,
      [I, Cmd.Monitor[I].Description, Cmd.Monitor[I].UniqueString, LevelsMsg, Cmd.Monitor[I].Level]);

    if I < Cmd.MonitorCount - 1 then
      Result := Result + sLineBreak + sLineBreak;
  end;
end;

class procedure TStartupTasks.ShowMonitors(Cmd: TApiBrightnessMonitors);
var
  MonitorsMessage: string;
begin
  MonitorsMessage := GetMonitorsMsg(Cmd);
  MonitorsMessage := MonitorsMessage + sLineBreak + sLineBreak +
    'Press Ctrl+C to copy message to clipboard!';

  MessageBox(0, LPCTSTR(MonitorsMessage), 'Brightness monitors', MB_OK);
end;

class function TStartupTasks.AddAutorun(var ExitRequired: Boolean): UINT;
begin
  ExitRequired:= True;
  if AutorunManager.Autorun then
    Result:= ERROR_Ok
  else
    Result:= ERROR_Autorun;
end;

class function TStartupTasks.DelAutorun(var ExitRequired: Boolean): UINT;
begin
  ExitRequired:= True;
  if AutorunManager.DeleteAutorun then
    Result:= ERROR_Ok
  else
    Result:= ERROR_DelAutorun;
end;

class function TStartupTasks.SendToApi(Command: IApiCommand): UINT;
var
  ApiClient: TApiClient;
begin
  ApiClient := TApiClient.Create(CommandPipeName);
  try
    if ApiClient.Send(Command) then
      Result := ERROR_Ok
    else
      Result:= ERROR_Pipe;
  finally
    ApiClient.Free;
  end;
end;

class function TStartupTasks.SendToApiAndWaitResponse(Command: IApiCommand;
  out Response: string): UINT;
var
  ApiClient: TApiClient;
begin
  ApiClient := TApiClient.Create(CommandPipeName);
  try
    if ApiClient.SendAndWaitResponse(Command, Response) then
      Result := ERROR_Ok
    else
      Result:= ERROR_Pipe;
  finally
    ApiClient.Free;
  end;
end;

class function TStartupTasks.PerformFromCmdInput(var ExitRequired: Boolean): UINT;
var
  I: Integer;
  UniqueString: string;
  ChangeType: TApiSetBrightness.TChangeType;
  Value: Integer;

  Response: string;
  ResultCode: Cardinal;
  Cmd: TApiBrightnessMonitors;
begin
  I := 1;
  Result := ERROR_Ok;
  while I <= ParamCount do
  try
    if (CompareText(ParamStr(I), '-?') = 0) or
       (CompareText(ParamStr(I), '/?') = 0) or
       (CompareText(ParamStr(I), '-h') = 0) or
       (CompareText(ParamStr(I), '-help') = 0) then
    begin
      Result := Result or ShowHelp(ExitRequired);
      Break;
    end
    else if CompareText(ParamStr(I), CmdAutorun) = 0 then
    begin
      Result := Result or AddAutorun(ExitRequired);
      Break;
    end
    else if CompareText(ParamStr(I), CmdDelAutorun) = 0 then
    begin
      Result := Result or DelAutorun(ExitRequired);
      Break;
    end
    else if CompareText(ParamStr(I), CmdNextScheme) = 0 then
    begin
      ExitRequired := True;
      Result := Result or SendToApi(TApiChangeScheme.Create(stNext));
      Continue;
    end
    else if CompareText(ParamStr(I), CmdMaxPowerSavings) = 0 then
    begin
      ExitRequired := True;
      Result := Result or SendToApi(TApiChangeScheme.Create(stMaxPowerSavings));
      Continue;
    end
    else if CompareText(ParamStr(I), CmdTypicalPowerSavings) = 0 then
    begin
      ExitRequired := True;
      Result := Result or SendToApi(TApiChangeScheme.Create(stTypicalPowerSavings));
      Continue;
    end
    else if CompareText(ParamStr(I), CmdMinPowerSavings) = 0 then
    begin
      ExitRequired := True;
      Result := Result or SendToApi(TApiChangeScheme.Create(stMinPowerSavings));
      Continue;
    end
    else if CompareText(ParamStr(I), CmdUltimatePowerSavings) = 0 then
    begin
      ExitRequired := True;
      Result := Result or SendToApi(TApiChangeScheme.Create(stUltimatePowerSavings));
      Continue;
    end
    else if CompareText(ParamStr(I), CmdSetBrightness) = 0 then
    begin
      Inc(I);
      if I > ParamCount then Continue;

      UniqueString := ParamStr(I);

      Inc(I);
      if I > ParamCount then Continue;

      if CompareText(ParamStr(I), ParamLevel) = 0 then
      begin
        ChangeType := ctLevel;

        Inc(I);
        if I > ParamCount then Continue;
      end
      else
      begin
        ChangeType := ctBrightness;
      end;

      if not Integer.TryParse(ParamStr(I), Value) then Continue;

      ExitRequired := True;
      Result := Result or SendToApi(TApiSetBrightness.Create(UniqueString, ChangeType, Value));
      Continue;
    end
    else if CompareText(ParamStr(I), CmdGetBrightness) = 0 then
    begin
      ExitRequired := True;
      ResultCode := SendToApiAndWaitResponse(TApiGetBrightnessMonitors.Create, Response);
      Result := Result or ResultCode;
      if ResultCode <> ERROR_Ok then Continue;

      Cmd := TApiBrightnessMonitors.Create;
      if not Cmd.Parse(Response) then Continue;

      ShowMonitors(Cmd);

      Continue;
    end;
  finally
    Inc(I);
  end;
end;

end.
