unit Brightness.Manager;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Classes, System.Win.Registry, System.Math,
  System.Generics.Collections, System.Generics.Defaults,
  Brightness;

type
  TBrightnessConfigurator = class
  private const
    REG_Brightness = 'Brightness';
  private
    FRootRegKey: string;
    FRegKey: string;
  public
    constructor Create(RootRegKey: string); reintroduce;

    procedure ConfigureMonitor(Monitor: IBrightnessMonitor);
  end;

  TBrightnessManager = class(TList<IBrightnessMonitor>)
  private
    FMsgWindow: THandle;
    FConfigurator: TBrightnessConfigurator;
    FRescanDelayMillisecond: Cardinal;
    FOnNotify2: TCollectionNotifyEvent<IBrightnessMonitor>;
    FOnBeforeUpdate: TNotifyEvent;
    FOnAfterUpdate: TNotifyEvent;
    function GetInternalMonitorCount: Integer;
  protected
    FProviders: TList<IBrightnessProvider>;
    procedure MsgWindowProc(var Msg: TMessage);
    procedure Update(Provider: IBrightnessProvider); overload;
    procedure ProviderNeedUpdate(Sender: IBrightnessProvider);
    procedure Notify(const Item: IBrightnessMonitor; Action: TCollectionNotification); override;
  public
    constructor Create(Configurator: TBrightnessConfigurator); reintroduce;
    destructor Destroy; override;

    procedure AddProvider(Provider: IBrightnessProvider);
    procedure RemoveProvider(Provider: IBrightnessProvider);

    procedure Update; overload;
    procedure Update(Delay: Cardinal); overload;

    procedure ChangeLevel(Method: TBrightnessMonitorManagementMethod; LevelDiff: Integer);

    property InternalMonitorCount: Integer read GetInternalMonitorCount;

    property RescanDelayMillisecond: Cardinal read FRescanDelayMillisecond write FRescanDelayMillisecond;

    property OnNotify2: TCollectionNotifyEvent<IBrightnessMonitor> read FOnNotify2 write FOnNotify2;
    property OnBeforeUpdate: TNotifyEvent read FOnBeforeUpdate write FOnBeforeUpdate;
    property OnAfterUpdate: TNotifyEvent read FOnAfterUpdate write FOnAfterUpdate;
  end;

implementation

{ TBrightnessManager }

constructor TBrightnessManager.Create(Configurator: TBrightnessConfigurator);
begin
  inherited Create;

  FConfigurator := Configurator;

  FProviders := TList<IBrightnessProvider>.Create;
  FMsgWindow := AllocateHWnd(MsgWindowProc);

  if GetTickCount < 1000*60 then
    SetTimer(FMsgWindow, INVALID_HANDLE_VALUE, RescanDelayMillisecond, nil);
end;

destructor TBrightnessManager.Destroy;
var
  Provider: IBrightnessProvider;
  Monitor: IBrightnessMonitor;
begin
  DeallocateHWnd(FMsgWindow);

  for Provider in FProviders do
  begin
    for Monitor in Provider.Monitors do
      Remove(Monitor);
    Provider.Clean;
  end;

  FProviders.Free;

  inherited;
end;

procedure TBrightnessManager.MsgWindowProc(var Msg: TMessage);
begin
  Msg.Result := DefWindowProc(FMsgWindow, Msg.Msg, Msg.WParam, Msg.LParam);
  case Msg.Msg of
    WM_DISPLAYCHANGE:
      SetTimer(FMsgWindow, INVALID_HANDLE_VALUE, RescanDelayMillisecond, nil);
    WM_POWERBROADCAST:
      case Msg.WParam of
        PBT_APMRESUMEAUTOMATIC:
          SetTimer(FMsgWindow, INVALID_HANDLE_VALUE, RescanDelayMillisecond, nil);
      end;
    WM_TIMER:
      begin
        KillTimer(FMsgWindow, Msg.WParam);
        if Msg.WParam = INVALID_HANDLE_VALUE then
          Update
        else
          Update(IBrightnessProvider(Msg.WParam));
      end;
  end;
end;

procedure TBrightnessManager.Notify(const Item: IBrightnessMonitor;
  Action: TCollectionNotification);
begin
  inherited;
  if Assigned(FOnNotify2) then
    FOnNotify2(Self, Item, Action);
end;

procedure TBrightnessManager.ProviderNeedUpdate(Sender: IBrightnessProvider);
begin
  SetTimer(FMsgWindow, UIntPtr(Sender), 300, nil);
end;

procedure TBrightnessManager.Update(Provider: IBrightnessProvider);
var
  Monitor: IBrightnessMonitor;
begin
  for Monitor in Provider.Monitors do
    Remove(Monitor);

  for Monitor in Provider.Load do
  begin
    FConfigurator.ConfigureMonitor(Monitor);
    Add(Monitor);
  end;
end;

procedure TBrightnessManager.Update;
var
  Provider: IBrightnessProvider;
begin
  if Assigned(FOnBeforeUpdate) then FOnBeforeUpdate(Self);

  for Provider in FProviders do Update(Provider);

  if Assigned(FOnAfterUpdate) then FOnAfterUpdate(Self);
end;

procedure TBrightnessManager.Update(Delay: Cardinal);
begin
  SetTimer(FMsgWindow, INVALID_HANDLE_VALUE, Delay, nil);
end;

procedure TBrightnessManager.AddProvider(Provider: IBrightnessProvider);
var
  Monitor: IBrightnessMonitor;
begin
  Provider.OnNeedUpdate := ProviderNeedUpdate;
  FProviders.Add(Provider);

  for Monitor in Provider.Load do
  begin
    FConfigurator.ConfigureMonitor(Monitor);
    Add(Monitor);
  end;
end;

procedure TBrightnessManager.RemoveProvider(Provider: IBrightnessProvider);
var
  Monitor: IBrightnessMonitor;
begin
  if not FProviders.Remove(Provider) >= 0 then Exit;

  for Monitor in Provider.Monitors do
    Remove(Monitor);

  Provider.Clean;
end;

function TBrightnessManager.GetInternalMonitorCount: Integer;
var
  Monitor: IBrightnessMonitor;
begin
  Result := 0;
  for Monitor in Self do
    if Monitor.MonitorType = bmtInternal then
      Inc(Result);
end;

procedure TBrightnessManager.ChangeLevel(
  Method: TBrightnessMonitorManagementMethod; LevelDiff: Integer);
const
  MaxGreedSize = 50;
var
  TouchedMonitors: TList<IBrightnessMonitor>;
  Monitor: IBrightnessMonitor;
  MinLevelCount: Integer;
  Ratio, NewLevel: Extended;
begin
  if LevelDiff = 0 then Exit;

  TouchedMonitors := TList<IBrightnessMonitor>.Create;
  try
    MinLevelCount := 255;
    for Monitor in Self do
    begin
      if Monitor.Enable and (bmmmTrayScroll in Monitor.ManagementMethods) then
      begin
        TouchedMonitors.Add(Monitor);
        if MinLevelCount > Monitor.Levels.Count then MinLevelCount := Monitor.Levels.Count;
      end;
    end;
    if TouchedMonitors.Count = 0 then Exit;

    if MinLevelCount > MaxGreedSize then MinLevelCount := MaxGreedSize;

    for Monitor in TouchedMonitors do
    begin
      Ratio := MinLevelCount/Monitor.Levels.Count;
      NewLevel := (Ratio * Monitor.Level + LevelDiff)/Ratio;

      if TouchedMonitors.Count = 1 then
        Monitor.Level := Round(NewLevel)
      else if LevelDiff > 0 then
        Monitor.Level := Ceil(NewLevel)
      else
        Monitor.Level := Trunc(NewLevel);
    end;
  finally
    TouchedMonitors.Free;
  end;
end;

{ TBrightnessConfigurator }

constructor TBrightnessConfigurator.Create(RootRegKey: string);
begin
  inherited Create;

  FRootRegKey := RootRegKey;
  FRegKey := FRootRegKey + PathDelim + REG_Brightness;
end;

procedure TBrightnessConfigurator.ConfigureMonitor(Monitor: IBrightnessMonitor);
begin
  TBrightnessConfig.Create(FRegKey, Monitor);
end;

end.
