unit Brightness;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Classes, System.Win.Registry,
  System.Generics.Collections, System.Generics.Defaults;

const
  UnsortedMonitorNumber = Integer.MaxValue;

type
  TBrightnessMonitorType = (bmtInternal, bmtExternal);
  TBrightnessMonitorManagementMethod = (
    bmmmTrayScroll = 1
  );
  TBrightnessMonitorManagementMethods = set of TBrightnessMonitorManagementMethod;
  TBrightnessLevels = TList<Byte>;

  // Интерфейсы
  IBrightnessMonitor = interface;
  IBrightnessProvider = interface;

  // Классы
  TBrightnessMonitorComparer = class;
  TBrightnessConfig = class;

  // Исключения
  TBrightnessMonitorException = class;

  TBrightnessChangeLevelEvent = procedure(Sender: IBrightnessMonitor; NewLevel: Integer) of object;
  TBrightnessChangeActiveEvent = procedure(Sender: IBrightnessMonitor; Active: Boolean) of object;
  TBrightnessChangeEnableEvent = procedure(Sender: IBrightnessMonitor; Enable: Boolean) of object;
  TBrightnessChangeAdaptiveBrightnessEvent = procedure(Sender: IBrightnessMonitor; AdaptiveBrightness: Boolean) of object;
  TBrightnessChangeManagementMethodsEvent = procedure(Sender: IBrightnessMonitor; ManagementMethods: TBrightnessMonitorManagementMethods) of object;
  TBrightnessChangeNameEvent = procedure(Sender: IBrightnessMonitor; EffectiveName: string) of object;

  IBrightnessMonitor = interface
    function GetMonitorType: TBrightnessMonitorType;
    function GetDescription: string;
    function GetEnable: Boolean;
    procedure SetEnable(const Value: Boolean);
    function GetLevels: TBrightnessLevels;
    function GetLevel: Integer;
    procedure SetLevel(const Value: Integer);
    function GetNormalizedBrightness(Level: Integer): Byte;
    function GetUniqueString: string;
    function GetSlowMonitor: Boolean;
    function GetActive: Boolean;
    procedure SetActive(const Value: Boolean);
    function GetAdaptiveBrightness: Boolean;
    procedure SetAdaptiveBrightness(const Value: Boolean);
    function GetAdaptiveBrightnessAvalible: Boolean;
    function GetManagementMethods: TBrightnessMonitorManagementMethods;
    procedure SetManagementMethods(const Value: TBrightnessMonitorManagementMethods);
    function GetRequireBrightnessRefreshOnPowerUp: Boolean;
    procedure SetRequireBrightnessRefreshOnPowerUp(const Value: Boolean);
    function GetFriendlyName: string;
    procedure SetFriendlyName(const Value: string);
    function GetEffectiveName: string;
    function GetSortNumber: Integer;
    procedure SetSortNumber(const Value: Integer);

    function GetOnChangeLevel: TBrightnessChangeLevelEvent;
    procedure SetOnChangeLevel(const Value: TBrightnessChangeLevelEvent);
    function GetOnChangeActive: TBrightnessChangeActiveEvent;
    procedure SetOnChangeActive(const Value: TBrightnessChangeActiveEvent);
    function GetOnChangeEnable: TBrightnessChangeEnableEvent;
    procedure SetOnChangeEnable(const Value: TBrightnessChangeEnableEvent);
    function GetOnChangeEnable2: TBrightnessChangeEnableEvent;
    procedure SetOnChangeEnable2(const Value: TBrightnessChangeEnableEvent);
    function GetOnChangeAdaptiveBrightness: TBrightnessChangeAdaptiveBrightnessEvent;
    procedure SetOnChangeAdaptiveBrightness(const Value: TBrightnessChangeAdaptiveBrightnessEvent);
    function GetOnChangeManagementMethods: TBrightnessChangeManagementMethodsEvent;
    procedure SetOnChangeManagementMethods(const Value: TBrightnessChangeManagementMethodsEvent);
    function GetOnChangeName: TBrightnessChangeNameEvent;
    procedure SetOnChangeName(const Value: TBrightnessChangeNameEvent);
    function GetOnChangeName2: TBrightnessChangeNameEvent;
    procedure SetOnChangeName2(const Value: TBrightnessChangeNameEvent);

    procedure LoadConfig(Config: TBrightnessConfig);
    function GetDefaultConfig: TBrightnessConfig;

    property MonitorType: TBrightnessMonitorType read GetMonitorType;
    property Description: string read GetDescription;
    property Enable: Boolean read GetEnable write SetEnable;
    property Levels: TBrightnessLevels read GetLevels;
    property Level: Integer read GetLevel write SetLevel;
    property NormalizedBrightness[Level: Integer]: Byte read GetNormalizedBrightness;
    property UniqueString: string read GetUniqueString;
    property SlowMonitor: Boolean read GetSlowMonitor;
    property Active: Boolean read GetActive write SetActive;
    property AdaptiveBrightness: Boolean read GetAdaptiveBrightness write SetAdaptiveBrightness;
    property AdaptiveBrightnessAvalible: Boolean read GetAdaptiveBrightnessAvalible;
    property ManagementMethods: TBrightnessMonitorManagementMethods read GetManagementMethods write SetManagementMethods;
    property RequireBrightnessRefreshOnPowerUp: Boolean read GetRequireBrightnessRefreshOnPowerUp write SetRequireBrightnessRefreshOnPowerUp;
    property FriendlyName: string read GetFriendlyName write SetFriendlyName;
    property EffectiveName: string read GetEffectiveName;
    property SortNumber: Integer read GetSortNumber write SetSortNumber;

    property OnChangeLevel: TBrightnessChangeLevelEvent read GetOnChangeLevel write SetOnChangeLevel;
    property OnChangeActive: TBrightnessChangeActiveEvent read GetOnChangeActive write SetOnChangeActive;
    property OnChangeEnable: TBrightnessChangeEnableEvent read GetOnChangeEnable write SetOnChangeEnable;
    property OnChangeEnable2: TBrightnessChangeEnableEvent read GetOnChangeEnable2 write SetOnChangeEnable2;
    property OnChangeAdaptiveBrightness: TBrightnessChangeAdaptiveBrightnessEvent read GetOnChangeAdaptiveBrightness write SetOnChangeAdaptiveBrightness;
    property OnChangeManagementMethods: TBrightnessChangeManagementMethodsEvent read GetOnChangeManagementMethods write SetOnChangeManagementMethods;
    property OnChangeName: TBrightnessChangeNameEvent read GetOnChangeName write SetOnChangeName;
    property OnChangeName2: TBrightnessChangeNameEvent read GetOnChangeName2 write SetOnChangeName2;
  end;

  TBrightnessMonitorBase = class abstract(TInterfacedObject, IBrightnessMonitor)
  protected
    FEnable: Boolean;
    FConfig: TBrightnessConfig;
    FAlwaysActive: Boolean;
    FManagementMethods: TBrightnessMonitorManagementMethods;
    FRequireBrightnessRefreshOnPowerUp: Boolean;
    FFriendlyName: string;
    FSortNumber: Integer;

    FOnError: TNotifyEvent;
    FOnChangeLevel: TBrightnessChangeLevelEvent;
    FOnChangeActive: TBrightnessChangeActiveEvent;
    FOnChangeEnable: TBrightnessChangeEnableEvent;
    FOnChangeEnable2: TBrightnessChangeEnableEvent;
    FOnChangeAdaptiveBrightness: TBrightnessChangeAdaptiveBrightnessEvent;
    FOnChangeManagementMethods: TBrightnessChangeManagementMethodsEvent;
    FOnChangeName: TBrightnessChangeNameEvent;
    FOnChangeName2: TBrightnessChangeNameEvent;

    constructor Create(AlwaysActive: Boolean);

    function GetMonitorType: TBrightnessMonitorType; virtual; abstract;
    function GetDescription: string; virtual; abstract;
    function GetEnable: Boolean; virtual;
    procedure SetEnable(const Value: Boolean); virtual;
    function GetLevels: TBrightnessLevels; virtual; abstract;
    function GetLevel: Integer; virtual; abstract;
    procedure SetLevel(const Value: Integer); virtual; abstract;
    function GetNormalizedBrightness(Level: Integer): Byte; virtual; abstract;
    function GetUniqueString: string; virtual; abstract;
    function GetSlowMonitor: Boolean; virtual; abstract;
    function GetActive: Boolean; virtual; abstract;
    procedure SetActive(const Value: Boolean); virtual; abstract;
    function GetAdaptiveBrightness: Boolean; virtual; abstract;
    procedure SetAdaptiveBrightness(const Value: Boolean); virtual; abstract;
    function GetAdaptiveBrightnessAvalible: Boolean; virtual; abstract;
    function GetManagementMethods: TBrightnessMonitorManagementMethods; virtual;
    procedure SetManagementMethods(const Value: TBrightnessMonitorManagementMethods); virtual;
    function GetRequireBrightnessRefreshOnPowerUp: Boolean; virtual;
    procedure SetRequireBrightnessRefreshOnPowerUp(const Value: Boolean); virtual;
    function GetFriendlyName: string; virtual;
    procedure SetFriendlyName(const Value: string); virtual;
    function GetEffectiveName: string;
    function GetSortNumber: Integer;
    procedure SetSortNumber(const Value: Integer);

    function GetOnChangeLevel: TBrightnessChangeLevelEvent;
    procedure SetOnChangeLevel(const Value: TBrightnessChangeLevelEvent);
    function GetOnChangeActive: TBrightnessChangeActiveEvent;
    procedure SetOnChangeActive(const Value: TBrightnessChangeActiveEvent);
    function GetOnChangeEnable: TBrightnessChangeEnableEvent;
    procedure SetOnChangeEnable(const Value: TBrightnessChangeEnableEvent);
    function GetOnChangeEnable2: TBrightnessChangeEnableEvent;
    procedure SetOnChangeEnable2(const Value: TBrightnessChangeEnableEvent);
    function GetOnChangeAdaptiveBrightness: TBrightnessChangeAdaptiveBrightnessEvent;
    procedure SetOnChangeAdaptiveBrightness(const Value: TBrightnessChangeAdaptiveBrightnessEvent);
    function GetOnChangeManagementMethods: TBrightnessChangeManagementMethodsEvent;
    procedure SetOnChangeManagementMethods(const Value: TBrightnessChangeManagementMethodsEvent);
    function GetOnChangeName: TBrightnessChangeNameEvent;
    procedure SetOnChangeName(const Value: TBrightnessChangeNameEvent);
    function GetOnChangeName2: TBrightnessChangeNameEvent;
    procedure SetOnChangeName2(const Value: TBrightnessChangeNameEvent);
  public
    procedure LoadConfig(Config: TBrightnessConfig); virtual;
    function GetDefaultConfig: TBrightnessConfig; virtual; abstract;

    property MonitorType: TBrightnessMonitorType read GetMonitorType;
    property Description: string read GetDescription;
    property Enable: Boolean read GetEnable write SetEnable;
    property Levels: TBrightnessLevels read GetLevels;
    property Level: Integer read GetLevel write SetLevel;
    property NormalizedBrightness[Level: Integer]: Byte read GetNormalizedBrightness;
    property UniqueString: string read GetUniqueString;
    property SlowMonitor: Boolean read GetSlowMonitor;
    property Active: Boolean read GetActive write SetActive;
    property AdaptiveBrightness: Boolean read GetAdaptiveBrightness write SetAdaptiveBrightness;
    property AdaptiveBrightnessAvalible: Boolean read GetAdaptiveBrightnessAvalible;
    property ManagementMethods: TBrightnessMonitorManagementMethods read GetManagementMethods write SetManagementMethods;
    property RequireBrightnessRefreshOnPowerUp: Boolean read GetRequireBrightnessRefreshOnPowerUp write SetRequireBrightnessRefreshOnPowerUp;
    property FriendlyName: string read GetFriendlyName write SetFriendlyName;
    property EffectiveName: string read GetEffectiveName;
    property SortNumber: Integer read GetSortNumber write SetSortNumber;

    property OnError: TNotifyEvent read FOnError write FOnError;
    property OnChangeLevel: TBrightnessChangeLevelEvent read GetOnChangeLevel write SetOnChangeLevel;
    property OnChangeActive: TBrightnessChangeActiveEvent read GetOnChangeActive write SetOnChangeActive;
    property OnChangeEnable: TBrightnessChangeEnableEvent read GetOnChangeEnable write SetOnChangeEnable;
    property OnChangeEnable2: TBrightnessChangeEnableEvent read GetOnChangeEnable2 write SetOnChangeEnable2;
    property OnChangeAdaptiveBrightness: TBrightnessChangeAdaptiveBrightnessEvent read GetOnChangeAdaptiveBrightness write SetOnChangeAdaptiveBrightness;
    property OnChangeManagementMethods: TBrightnessChangeManagementMethodsEvent read GetOnChangeManagementMethods write SetOnChangeManagementMethods;
    property OnChangeName: TBrightnessChangeNameEvent read GetOnChangeName write SetOnChangeName;
    property OnChangeName2: TBrightnessChangeNameEvent read GetOnChangeName2 write SetOnChangeName2;
  end;

  TBrightnessMonitorComparer = class(TComparer<IBrightnessMonitor>)
  public
    function Compare(const Left, Right: IBrightnessMonitor): Integer; override;
  end;

  TBrightnessMonitorException = class(Exception)
  public
    constructor Create; overload;
  end;

  TProviderNeedUpdateEvent = procedure(Sender: IBrightnessProvider) of object;

  IBrightnessProvider = interface
    function GetMonitors: TList<IBrightnessMonitor>;
    function GetOnNeedUpdate: TProviderNeedUpdateEvent;
    procedure SetOnNeedUpdate(const Value: TProviderNeedUpdateEvent);

    function Load: TList<IBrightnessMonitor>;
    procedure Clean;

    property Monitors: TList<IBrightnessMonitor> read GetMonitors;
    property OnNeedUpdate: TProviderNeedUpdateEvent read GetOnNeedUpdate write SetOnNeedUpdate;
  end;

  TBrightnessConfig = class(TInterfacedObject)
  private const
    REG_Enable = 'Enabled';
    REG_Active = 'Active';
    REG_ManagementMethods = 'ManagementMethods';
    REG_RequireBrightnessRefreshOnPowerUp = 'RequireBrightnessRefreshOnPowerUp';
    REG_FriendlyName = 'FriendlyName';
    REG_SortNumber = 'SortNumber';
  private
    FRootRegKey: string;
    FRegKey: string;

    FEnable: Boolean;
    FActive: Boolean;
    FManagementMethods: TBrightnessMonitorManagementMethods;
    FRequireBrightnessRefreshOnPowerUp: Boolean;
    FFriendlyName: string;
    FSortNumber: Integer;

    procedure SetEnable(const Value: Boolean);
    procedure SetActive(const Value: Boolean);
    procedure SetManagementMethods(const Value: TBrightnessMonitorManagementMethods);
    procedure SetRequireBrightnessRefreshOnPowerUp(const Value: Boolean);
    procedure SetFriendlyName(const Value: string);
    procedure SetSortNumber(const Value: Integer);

    procedure LoadDefault(DefConfig: TBrightnessConfig);
    procedure SaveConfig;
  public
    constructor Create(RootRegKey: string; Monitor: IBrightnessMonitor); reintroduce; overload;
    constructor Create(
      aEnable: Boolean;
      aActive: Boolean;
      aManagementMethods: TBrightnessMonitorManagementMethods;
      aRequireBrightnessRefreshOnPowerUp: Boolean); reintroduce; overload;

    property Enable: Boolean read FEnable write SetEnable;
    property Active: Boolean read FActive write SetActive;
    property ManagementMethods: TBrightnessMonitorManagementMethods read FManagementMethods write SetManagementMethods;
    property RequireBrightnessRefreshOnPowerUp: Boolean read FRequireBrightnessRefreshOnPowerUp write SetRequireBrightnessRefreshOnPowerUp;
    property FriendlyName: string read FFriendlyName write SetFriendlyName;
    property SortNumber: Integer read FSortNumber write SetSortNumber;
  end;

  function NormalizeBrightness(Levels: TBrightnessLevels; Level: Integer): Byte;

implementation

function NormalizeBrightness(Levels: TBrightnessLevels; Level: Integer): Byte;
  function Max(a, b: Byte): Byte; inline;
  begin
    if a > b then Result := a else Result := b;
  end;
begin
  try
    Result := MulDiv(Levels[Level], 100, Max(Levels.First, Levels.Last));
  except
    Result := 255;
  end;
end;

{ TBrightnessMonitorBase }

constructor TBrightnessMonitorBase.Create(AlwaysActive: Boolean);
begin
  inherited Create;

  FAlwaysActive := AlwaysActive;
  FManagementMethods := [];
  FRequireBrightnessRefreshOnPowerUp := False;
  FFriendlyName := '';
  FSortNumber := UnsortedMonitorNumber;
end;

procedure TBrightnessMonitorBase.LoadConfig(Config: TBrightnessConfig);
begin
  FConfig := Config;
  Enable := FConfig.Enable;
  Active := FConfig.Active or FAlwaysActive;
  ManagementMethods := FConfig.ManagementMethods;
  RequireBrightnessRefreshOnPowerUp := FConfig.RequireBrightnessRefreshOnPowerUp;
  FriendlyName := FConfig.FriendlyName;
  SortNumber := FConfig.SortNumber;
end;

function TBrightnessMonitorBase.GetEnable: Boolean;
begin
  Result := FEnable;
end;

procedure TBrightnessMonitorBase.SetEnable(const Value: Boolean);
begin
  if FEnable = Value then Exit;

  FEnable := Value;
  if Assigned(FConfig) then FConfig.Enable := FEnable;

  if Assigned(FOnChangeEnable) then FOnChangeEnable(Self, FEnable);
  if Assigned(FOnChangeEnable2) then FOnChangeEnable2(Self, FEnable);
end;

function TBrightnessMonitorBase.GetManagementMethods: TBrightnessMonitorManagementMethods;
begin
  Result := FManagementMethods;
end;

procedure TBrightnessMonitorBase.SetManagementMethods(
  const Value: TBrightnessMonitorManagementMethods);
begin
  if FManagementMethods = Value then Exit;

  FManagementMethods := Value;

  if Assigned(FConfig) then
    FConfig.ManagementMethods := FManagementMethods;

  if Assigned(FOnChangeManagementMethods) then
    FOnChangeManagementMethods(Self, FManagementMethods);
end;

function TBrightnessMonitorBase.GetRequireBrightnessRefreshOnPowerUp: Boolean;
begin
  Result := FRequireBrightnessRefreshOnPowerUp;
end;

procedure TBrightnessMonitorBase.SetRequireBrightnessRefreshOnPowerUp(
  const Value: Boolean);
begin
  if FRequireBrightnessRefreshOnPowerUp = Value then Exit;

  FRequireBrightnessRefreshOnPowerUp := Value;

  if Assigned(FConfig) then
    FConfig.RequireBrightnessRefreshOnPowerUp := FRequireBrightnessRefreshOnPowerUp;
end;

function TBrightnessMonitorBase.GetFriendlyName: string;
begin
  Result := FFriendlyName;
end;

procedure TBrightnessMonitorBase.SetFriendlyName(const Value: string);
var
  Name: string;
begin
  if FFriendlyName = Value then Exit;

  FFriendlyName := Value;

  if Assigned(FConfig) then
    FConfig.FriendlyName := FFriendlyName;

  Name := EffectiveName;
  if Assigned(FOnChangeName) then FOnChangeName(Self, Name);
  if Assigned(FOnChangeName2) then FOnChangeName2(Self, Name);
end;

function TBrightnessMonitorBase.GetEffectiveName: string;
begin
  Result := FriendlyName;
  if string.IsNullOrEmpty(Result) then Result := Description;
end;

function TBrightnessMonitorBase.GetSortNumber: Integer;
begin
  Result := FSortNumber;
end;

procedure TBrightnessMonitorBase.SetSortNumber(const Value: Integer);
begin
  if FSortNumber = Value then Exit;

  FSortNumber := Value;

  if Assigned(FConfig) then
    FConfig.SortNumber := FSortNumber;
end;

function TBrightnessMonitorBase.GetOnChangeLevel: TBrightnessChangeLevelEvent;
begin
  Result := FOnChangeLevel;
end;

procedure TBrightnessMonitorBase.SetOnChangeLevel(const Value: TBrightnessChangeLevelEvent);
begin
  FOnChangeLevel := Value;
end;

function TBrightnessMonitorBase.GetOnChangeActive: TBrightnessChangeActiveEvent;
begin
  Result := FOnChangeActive;
end;

procedure TBrightnessMonitorBase.SetOnChangeActive(const Value: TBrightnessChangeActiveEvent);
begin
  FOnChangeActive := Value;
end;

function TBrightnessMonitorBase.GetOnChangeEnable: TBrightnessChangeEnableEvent;
begin
  Result := FOnChangeEnable;
end;

procedure TBrightnessMonitorBase.SetOnChangeEnable(const Value: TBrightnessChangeEnableEvent);
begin
  FOnChangeEnable := Value;
end;

function TBrightnessMonitorBase.GetOnChangeEnable2: TBrightnessChangeEnableEvent;
begin
  Result := FOnChangeEnable2;
end;

procedure TBrightnessMonitorBase.SetOnChangeEnable2(const Value: TBrightnessChangeEnableEvent);
begin
  FOnChangeEnable2 := Value;
end;

function TBrightnessMonitorBase.GetOnChangeAdaptiveBrightness: TBrightnessChangeAdaptiveBrightnessEvent;
begin
  Result := FOnChangeAdaptiveBrightness;
end;

procedure TBrightnessMonitorBase.SetOnChangeAdaptiveBrightness(
  const Value: TBrightnessChangeAdaptiveBrightnessEvent);
begin
  FOnChangeAdaptiveBrightness := Value;
end;

function TBrightnessMonitorBase.GetOnChangeManagementMethods: TBrightnessChangeManagementMethodsEvent;
begin
  Result := FOnChangeManagementMethods;
end;

procedure TBrightnessMonitorBase.SetOnChangeManagementMethods(
  const Value: TBrightnessChangeManagementMethodsEvent);
begin
  FOnChangeManagementMethods := Value;
end;

function TBrightnessMonitorBase.GetOnChangeName: TBrightnessChangeNameEvent;
begin
  Result := FOnChangeName;
end;

procedure TBrightnessMonitorBase.SetOnChangeName(const Value: TBrightnessChangeNameEvent);
begin
  FOnChangeName := Value;
end;

function TBrightnessMonitorBase.GetOnChangeName2: TBrightnessChangeNameEvent;
begin
  Result := FOnChangeName2;
end;

procedure TBrightnessMonitorBase.SetOnChangeName2(const Value: TBrightnessChangeNameEvent);
begin
  FOnChangeName2 := Value;
end;

{ TBrightnessMonitorComparer }

function TBrightnessMonitorComparer.Compare(const Left,
  Right: IBrightnessMonitor): Integer;
begin
  if Left.MonitorType = Right.MonitorType then
  begin
    Result := CompareText(Left.Description, Right.Description);
    if Result = 0 then
      Result := CompareText(Left.UniqueString, Right.UniqueString);
  end
  else
  begin
    if Left.MonitorType > Right.MonitorType then
      Exit(1)
    else if Left.MonitorType < Right.MonitorType then
      Exit(-1)
    else
      Exit(0);
  end;
end;

{ TBrightnessMonitorException }

constructor TBrightnessMonitorException.Create;
begin
  inherited Create(SysErrorMessage(GetLastError));
end;

{ TBrightnessConfig }

constructor TBrightnessConfig.Create(RootRegKey: string;
  Monitor: IBrightnessMonitor);
var
  Registry: TRegistry;
  DefConfig: TBrightnessConfig;

  function CleanupSpec(Str: string): string;
  var
    InvalidFileNameChars: TCharArray;
    Chr: Char;
  begin
    InvalidFileNameChars := TCharArray.Create(
      #0, #1, #2, #3, #4, #5, #6, #7, #8, #9, #10, #11, #12,
      #13, #14, #15, #16, #17, #18, #19, #20, #21, #22, #23, #24,
      #25, #26, #27, #28, #29, #30, #31,
      '"', '*', '/', ':', '<', '>', '?', '\', '|');

    Result := Str;
    for Chr in InvalidFileNameChars do
      Result := Result.Replace(Chr, '');
  end;

  function ReadBoolDef(const Name: string; const Def: Boolean): Boolean;
  begin
    if Registry.ValueExists(Name) then
      Result := Registry.ReadBool(Name)
    else
      Result := Def;
  end;

  function ReadIntegerDef(const Name: string; const Def: Integer): Integer;
  begin
    if Registry.ValueExists(Name) then
      Result := Registry.ReadInteger(Name)
    else
      Result := Def;
  end;

  function ReadStringDef(const Name: string; const Def: string): string;
  begin
    if Registry.ValueExists(Name) then
      Result := Registry.ReadString(Name)
    else
      Result := Def;
  end;

  function SetToInt(const aSet; const Size: Integer): Integer;
  begin
    Result := 0;
    Move(aSet, Result, Size);
  end;

  procedure IntToSet(const Value: Integer; var aSet; const Size: Integer);
  begin
    Move(Value, aSet, Size);
  end;
begin
  inherited Create;

  FRootRegKey := RootRegKey;
  FRegKey := FRootRegKey + PathDelim + CleanupSpec(Monitor.UniqueString);

  DefConfig := Monitor.GetDefaultConfig;
  LoadDefault(DefConfig);

  try
    Registry := TRegistry.Create;
    try
      Registry.RootKey := HKEY_CURRENT_USER;
      if not Registry.KeyExists(FRegKey) then Exit;
      if not Registry.OpenKeyReadOnly(FRegKey) then Exit;

      // Read config
      FEnable := ReadBoolDef(REG_Enable, DefConfig.Enable);
      FActive := ReadBoolDef(REG_Active, DefConfig.Active);
      IntToSet(
        ReadIntegerDef(REG_ManagementMethods, SetToInt(DefConfig.ManagementMethods, SizeOf(FManagementMethods))),
        FManagementMethods,
        SizeOf(FManagementMethods));
      FRequireBrightnessRefreshOnPowerUp := ReadBoolDef(REG_RequireBrightnessRefreshOnPowerUp, DefConfig.RequireBrightnessRefreshOnPowerUp);
      FFriendlyName := ReadStringDef(REG_FriendlyName, DefConfig.FriendlyName);
      FSortNumber := ReadIntegerDef(REG_SortNumber, DefConfig.SortNumber);
      // end read config

      Registry.CloseKey;
    finally
      Registry.Free;
    end;
  finally
    Monitor.LoadConfig(Self);
  end;
end;

constructor TBrightnessConfig.Create(
  aEnable, aActive: Boolean;
  aManagementMethods: TBrightnessMonitorManagementMethods;
  aRequireBrightnessRefreshOnPowerUp: Boolean);
begin
  inherited Create;

  FEnable := aEnable;
  FActive := aActive;
  FManagementMethods := aManagementMethods;
  FRequireBrightnessRefreshOnPowerUp := aRequireBrightnessRefreshOnPowerUp;
  FFriendlyName := '';
  FSortNumber := UnsortedMonitorNumber;
end;

procedure TBrightnessConfig.SetEnable(const Value: Boolean);
begin
  if FEnable = Value then Exit;

  FEnable := Value;
  SaveConfig;
end;

procedure TBrightnessConfig.SetActive(const Value: Boolean);
begin
  if FActive = Value then Exit;

  FActive := Value;
  SaveConfig;
end;

procedure TBrightnessConfig.SetManagementMethods(const Value: TBrightnessMonitorManagementMethods);
begin
  if FManagementMethods = Value then Exit;

  FManagementMethods := Value;
  SaveConfig;
end;

procedure TBrightnessConfig.SetRequireBrightnessRefreshOnPowerUp(const Value: Boolean);
begin
  if FRequireBrightnessRefreshOnPowerUp = Value then Exit;

  FRequireBrightnessRefreshOnPowerUp := Value;
  SaveConfig;
end;

procedure TBrightnessConfig.SetFriendlyName(const Value: string);
begin
  if FFriendlyName = Value then Exit;

  FFriendlyName := Value;
  SaveConfig;
end;

procedure TBrightnessConfig.SetSortNumber(const Value: Integer);
begin
  if FSortNumber = Value then Exit;

  FSortNumber := Value;
  SaveConfig;
end;

procedure TBrightnessConfig.SaveConfig;
var
  Registry: TRegistry;

  function SetToInt(const aSet; const Size: Integer): Integer;
  begin
    Result := 0;
    Move(aSet, Result, Size);
  end;
begin
  Registry := TRegistry.Create;
  try
    Registry.RootKey := HKEY_CURRENT_USER;
    Registry.DeleteKey(FRegKey);
    if Registry.OpenKey(FRegKey, True) then begin
      // Write config
      Registry.WriteBool(REG_Enable, FEnable);
      Registry.WriteBool(REG_Active, FActive);
      Registry.WriteInteger(REG_ManagementMethods, SetToInt(FManagementMethods, SizeOf(FManagementMethods)));
      Registry.WriteBool(REG_RequireBrightnessRefreshOnPowerUp, FRequireBrightnessRefreshOnPowerUp);
      Registry.WriteString(REG_FriendlyName, FFriendlyName);
      Registry.WriteInteger(REG_SortNumber, FSortNumber);
      // end write config

      Registry.CloseKey;
    end;
  finally
    Registry.Free;
  end;
end;

procedure TBrightnessConfig.LoadDefault(DefConfig: TBrightnessConfig);
begin
  FEnable := DefConfig.Enable;
  FActive := DefConfig.Active;
  FManagementMethods := DefConfig.ManagementMethods;
  FRequireBrightnessRefreshOnPowerUp := DefConfig.RequireBrightnessRefreshOnPowerUp;
  FFriendlyName := DefConfig.FriendlyName;
  FSortNumber := DefConfig.SortNumber;
end;

end.
