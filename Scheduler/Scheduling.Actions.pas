unit Scheduling.Actions;

interface

uses
  Winapi.Windows,
  System.SysUtils, System.Classes,
  Vcl.MPlayer,
  Battery.Mode,
  Core.Language,
  Core.UI.Notifications,
  Media.Player, Media.Player.Helpers,
  Power,
  Power.Display, Power.Shutdown, Power.WinApi.PowrProf,
  Scheduling;

type
  TActionBase = class(TInterfacedObject, IAction)
  private
    FID: Integer;
  protected
    function GetID: Integer; virtual;
    procedure SetID(const Value: Integer); virtual;
    function GetActionType: TActionType; virtual; abstract;
    function GetCfgStr: string; virtual; abstract;
    function GetDescription: string; virtual; abstract;
  public
    function Execute: Boolean; virtual; abstract;
    function Parse(CfgStr: string): Boolean; virtual; abstract;
    function Copy: IAction; virtual; abstract;
  end;

  TActionMessage = class(TActionBase)
  strict private type
    TMessageThread = class(TThread)
    strict private
      FhWnd: HWND;
      FlpText: string;
      FlpCaption: string;
      FuType: UINT;
    strict protected
      procedure Execute; override;
    public
      constructor Create(hWnd: HWND; lpText: string; lpCaption: string; uType: UINT); reintroduce;
    end;
  strict private
    FText: string;
  strict protected
    function GetActionType: TActionType; override;
    function GetCfgStr: string; override;
    function GetDescription: string; override;
  public
    constructor Create(Text: string); overload;

    function Execute: Boolean; override;
    function Parse(CfgStr: string): Boolean; override;
    function Copy: IAction; override;

    property ActionType: TActionType read GetActionType;
    property ID: Integer read GetID write SetID;
    property CfgStr: string read GetCfgStr;
    property Description: string read GetDescription;

    property Text: string read FText;
  end;

  TActionScheme = class(TActionBase)
  private
    FScheme: IPowerScheme;
  protected
    function GetActionType: TActionType; override;
    function GetCfgStr: string; override;
    function GetDescription: string; override;
  public
    constructor Create(Scheme: IPowerScheme); overload;

    function Execute: Boolean; override;
    function Parse(CfgStr: string): Boolean; override;
    function Copy: IAction; override;

    property ActionType: TActionType read GetActionType;

    property ID: Integer read GetID write SetID;
    property CfgStr: string read GetCfgStr;
    property Description: string read GetDescription;

    property Scheme: IPowerScheme read FScheme;
  end;

  TActionRun = class(TActionBase)
  strict private const
    ValueDelimiter = '<*@:>';
  strict private
    FFileName: string;
    FHide: Boolean;
  strict protected
    function GetActionType: TActionType; override;
    function GetCfgStr: string; override;
    function GetDescription: string; override;
  public
    constructor Create(FileName: string; Hide: Boolean); overload;

    function Execute: Boolean; override;
    function Parse(CfgStr: string): Boolean; override;
    function Copy: IAction; override;

    property ActionType: TActionType read GetActionType;

    property ID: Integer read GetID write SetID;
    property CfgStr: string read GetCfgStr;
    property Description: string read GetDescription;

    property FileName: string read FFileName;
    property Hide: Boolean read FHide;
  end;

  TActionSound = class(TActionBase)
  strict private type
    TSoundThread = class(TThread)
    strict private
      FFileName: string;
      FVolume: Integer;
    strict protected
      procedure Execute; override;
    public
      constructor Create(FileName: string; Volume: Integer); reintroduce;
    end;
  strict private const
    ValueDelimiter = '<*@:>';
  strict private
    FFileName: string;
    FVolume: Integer;
  strict protected
    function GetActionType: TActionType; override;
    function GetCfgStr: string; override;
    function GetDescription: string; override;
  public
    constructor Create(FileName: string; Volume: Integer); overload;

    function Execute: Boolean; override;
    function Parse(CfgStr: string): Boolean; override;
    function Copy: IAction; override;

    property ActionType: TActionType read GetActionType;

    property ID: Integer read GetID write SetID;
    property CfgStr: string read GetCfgStr;
    property Description: string read GetDescription;

    property FileName: string read FFileName;
    property Volume: Integer read FVolume;
  end;

  TActionPowerType = (ptaShutdown, ptaReboot, ptaSleep, ptaHibernate, ptaMonitorOff, ptaMonitorOn);
  TActionPower = class(TActionBase)
  private
    FActionPowerType: TActionPowerType;
  protected
    function GetActionType: TActionType; override;
    function GetCfgStr: string; override;
    function GetDescription: string; override;
  public
    constructor Create(ActionPowerType: TActionPowerType); overload;

    function Execute: Boolean; override;
    function Parse(CfgStr: string): Boolean; override;
    function Copy: IAction; override;

    property ActionType: TActionType read GetActionType;

    property ID: Integer read GetID write SetID;
    property CfgStr: string read GetCfgStr;
    property Description: string read GetDescription;

    property ActionPowerType: TActionPowerType read FActionPowerType;
  end;

implementation

{ TActionBase }

function TActionBase.GetID: Integer;
begin
  Result := FID;
end;

procedure TActionBase.SetID(const Value: Integer);
begin
  FID := Value;
end;

{ TActionMessage }

constructor TActionMessage.Create(Text: string);
begin
  inherited Create;
  FText := Text;
end;

function TActionMessage.Execute: Boolean;
begin
  if TNotificationService.IsAvailable then
    Result := TNotificationService.Notification.Notify(FText, TLang[1])
  else
    Result := TMessageThread.Create(0, FText, TLang[1], MB_OK or MB_ICONINFORMATION or MB_SYSTEMMODAL) <> nil;
end;

function TActionMessage.GetActionType: TActionType;
begin
  Result := atMessage;
end;

function TActionMessage.GetCfgStr: string;
begin
  Result := FText;
end;

function TActionMessage.GetDescription: string;
begin
  Result := Format(TLang[1100], [FText]);
end;

function TActionMessage.Parse(CfgStr: string): Boolean;
begin
  FText := CfgStr;
  Result := True;
end;

function TActionMessage.Copy: IAction;
var
  Dest: TActionMessage;
begin
  Dest := TActionMessage.Create;
  Dest.FText := FText;
  Dest.ID := ID;
  Result := Dest;
end;

{ TActionMessage.TMessageThread }

constructor TActionMessage.TMessageThread.Create(hWnd: HWND; lpText: string;
  lpCaption: string; uType: UINT);
begin
  FhWnd := hWnd;
  FlpText := lpText;
  FlpCaption := lpCaption;
  FuType := uType;

  inherited Create;
end;

procedure TActionMessage.TMessageThread.Execute;
begin
  FreeOnTerminate := True;
  MessageBox(FhWnd, LPCTSTR(FlpText), LPCTSTR(FlpCaption), FuType);
end;

{ TActionScheme }

constructor TActionScheme.Create(Scheme: IPowerScheme);
begin
  inherited Create;
  FScheme := Scheme;
end;

function TActionScheme.Execute: Boolean;
begin
  Result := FScheme.Activate;
end;

function TActionScheme.GetActionType: TActionType;
begin
  Result := atScheme;
end;

function TActionScheme.GetCfgStr: string;
begin
  Result := Scheme.UniqueString;
end;

function TActionScheme.GetDescription: string;
var
  SchemeName: string;
begin
  if FScheme.IsHidden then
    SchemeName := FScheme.UniqueString
  else
    SchemeName := FScheme.FriendlyName;

  Result := Format(TLang[1110], [SchemeName]);
end;

function TActionScheme.Parse(CfgStr: string): Boolean;
begin
  Result := True;
  try
    FScheme := TBatteryMode.PowerSchemes.MakeSchemeFromUniqueString(CfgStr);
  except
    Result := False;
  end;
end;

function TActionScheme.Copy: IAction;
begin
  Result := TActionScheme.Create(FScheme);
  (Result as TActionScheme).ID := ID;
end;

{ TActionRun }

constructor TActionRun.Create(FileName: string; Hide: Boolean);
begin
  inherited Create;
  FFileName := FileName;
  FHide := Hide;
end;

function TActionRun.Execute: Boolean;
var
  StartUpInfo : TStartUpInfo;
  ProcessInfo : TProcessInformation;
  lpCommandLine: LPTSTR;
begin
  ZeroMemory(@StartUpInfo, SizeOf(StartUpInfo));
  StartUpInfo.cb := SizeOf(StartUpInfo);
  if FHide then
  begin
    StartUpInfo.dwFlags := STARTF_USESHOWWINDOW;
    StartUpInfo.wShowWindow := SW_HIDE;
  end;

  if string.IsNullOrWhiteSpace(FFileName) then
    lpCommandLine := nil
  else
    lpCommandLine := LPTSTR(FFileName);
  Result := CreateProcess(nil, lpCommandLine, nil, nil, False,
    NORMAL_PRIORITY_CLASS, nil, nil, StartUpInfo, ProcessInfo);

  if Result then
  begin
    CloseHandle(ProcessInfo.hProcess);
    CloseHandle(ProcessInfo.hThread);
  end;
end;

function TActionRun.GetActionType: TActionType;
begin
  Result := atRun;
end;

function TActionRun.GetCfgStr: string;
begin
  Result := string.Join(ValueDelimiter, [FFileName, BoolToStr(FHide, True)]);
end;

function TActionRun.GetDescription: string;
var
  FilePath: string;
  Params: string;
begin
  FilePath := FFileName;
  if FilePath.StartsWith('"') and (FilePath.CountChar('"') >= 2) then
  begin
    Params := FilePath.Substring(FilePath.IndexOf('"', 2) + 1);
    FilePath := FilePath.Remove(FilePath.LastIndexOf('"') + 1);
  end;

  FilePath := FilePath.DeQuotedString('"');
  if IsRelativePath(FilePath) then
    FilePath := FilePath + Params
  else
    FilePath := ExtractFileName(FilePath) + Params;

  if FHide then
    Result := Format(TLang[1122], [FilePath])
  else
    Result := Format(TLang[1121], [FilePath]);
end;

function TActionRun.Parse(CfgStr: string): Boolean;
var
  Parts: TArray<string>;
  PartsCount: Integer;
begin
  Result := True;
  try
    Parts := CfgStr.Split([ValueDelimiter]);
    PartsCount := Length(Parts);
    if PartsCount > 0 then
      FFileName := Parts[0];

    if PartsCount > 1 then
      FHide := StrToBoolDef(Parts[1], False)
    else
      FHide := False;
  except
    Result := False;
  end;
end;

function TActionRun.Copy: IAction;
begin
  Result := TActionRun.Create;
  with Result as TActionRun do
  begin
    FFileName := Self.FFileName;
    FHide := Self.FHide;
    ID := Self.ID;
  end;
end;

{ TActionSound }

constructor TActionSound.Create(FileName: string; Volume: Integer);
begin
  inherited Create;
  FFileName := FileName;
  FVolume := Volume;
end;

function TActionSound.Execute: Boolean;
var
  FilePath: string;
begin
  FilePath := FFileName.DeQuotedString('"');
  if not FileExists(FilePath) then Exit(False);

  Result := TSoundThread.Create(FilePath, Volume) <> nil;
end;

function TActionSound.GetActionType: TActionType;
begin
  Result := atSound;
end;

function TActionSound.GetCfgStr: string;
begin
  Result := string.Join(ValueDelimiter, [FFileName, FVolume.ToString]);
end;

function TActionSound.GetDescription: string;
var
  FilePath: string;
begin
  FilePath := FFileName.DeQuotedString('"');
  FilePath := ExtractFileName(FilePath);

  if FVolume = 100 then
    Result := Format(TLang[1131], [FilePath])
  else
    Result := Format(TLang[1132], [FilePath, FVolume]);
end;

function TActionSound.Parse(CfgStr: string): Boolean;
var
  Parts: TArray<string>;
  PartsCount: Integer;
begin
  Result := True;
  try
    Parts := CfgStr.Split([ValueDelimiter]);
    PartsCount := Length(Parts);
    if PartsCount > 0 then
      FFileName := Parts[0];

    if PartsCount > 1 then
      FVolume := StrToIntDef(Parts[1], 100)
    else
      FVolume := 100;
  except
    Result := False;
  end;
end;

function TActionSound.Copy: IAction;
begin
  Result := TActionSound.Create;
  with Result as TActionSound do
  begin
    FFileName := Self.FFileName;
    FVolume := Self.FVolume;
    ID := Self.ID;
  end;
end;

{ TActionPower }

constructor TActionPower.Create(ActionPowerType: TActionPowerType);
begin
  inherited Create;
  FActionPowerType := ActionPowerType;
end;

function TActionPower.Execute: Boolean;
  function SetDisplayState(DisplayState: TDisplayState): Boolean;
  var
    DisplayStateHandler: TDisplayStateHandler;
  begin
    Result := True;
    DisplayStateHandler := TDisplayStateHandler.Create;
    try
      DisplayStateHandler.DisplayState := DisplayState;
    except
      Result := False;
    end;
    DisplayStateHandler.Free;
  end;
begin
  case FActionPowerType of
    ptaShutdown: Result := TPowerShutdownAction.Create.Perform;
    ptaReboot: Result := TPowerRebootAction.Create.Perform;
    ptaSleep: Result := TPowerSleepAction.Create.Perform;
    ptaHibernate: Result := TPowerHibernateAction.Create.Perform;
    ptaMonitorOff: Result := SetDisplayState(dsOff);
    ptaMonitorOn: Result := SetDisplayState(dsOn);
    else Result := False;
  end;
end;

function TActionPower.GetActionType: TActionType;
begin
  Result := atPower;
end;

function TActionPower.GetCfgStr: string;
begin
  Result :=  Integer(FActionPowerType).ToString;
end;

function TActionPower.GetDescription: string;
begin
  case FActionPowerType of
    ptaShutdown: Result := TLang[1141];      // завершить работу
    ptaReboot: Result := TLang[1142];        // перезагрузить компьютер
    ptaSleep: Result := TLang[1143];         // перейти в спящий режим
    ptaHibernate: Result := TLang[1144];     // перейти в режим гибернация
    ptaMonitorOff: Result := TLang[1145];    // отключить экран
    ptaMonitorOn: Result := TLang[1146];     // включить экран
    else Result := '';
  end;
end;

function TActionPower.Parse(CfgStr: string): Boolean;
begin
  Result := True;
  try
    FActionPowerType := TActionPowerType(Integer.Parse(CfgStr));
  except
    Result := False;
  end;
end;

function TActionPower.Copy: IAction;
begin
  Result := TActionPower.Create(FActionPowerType);
  Result.ID := ID;
end;

{ TActionMessage.TMessageThread }

constructor TActionSound.TSoundThread.Create(FileName: string; Volume: Integer);
begin
  FFileName := FileName;
  FVolume := Volume;

  inherited Create;
end;

procedure TActionSound.TSoundThread.Execute;
var
  MediaPlayer: TMediaPlayer;
begin
  FreeOnTerminate := True;

  MediaPlayer := TMediaPlayer.CreateWithoutUi;
  try
    try
      if CompareText(ExtractFileExt(FFileName), '.wav') = 0 then
        MediaPlayer.DeviceType := dtAVIVideo;

      MediaPlayer.FileName := FFileName;
      MediaPlayer.Open;
      try
        MediaPlayer.Volume := FVolume * 10;
      except
      end;
      MediaPlayer.Wait := True;
      MediaPlayer.Play;
      MediaPlayer.Close;
    except
    end;
  finally
    MediaPlayer.Destroy;
  end;
end;

end.
