unit Power.Display;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Classes,
  Power.WinApi.PowrProf,
  Versions.Helpers;

type
  {$MinEnumSize 4}
  TDisplayState = (dsOff, dsOn, dsDimmed);

  TDisplayStateChangeEvent = procedure(Sender: TObject; DisplayState: TDisplayState) of object;

  TDisplayStateHandler = class
  strict private const
    TimerMonitorOff = UINT_PTR(1);
    TimerMonitorOn = UINT_PTR(2);
    TimerMonitorDimmed = UINT_PTR(3);
  strict private type
    {$MinEnumSize 4}
    TMonitorPowerState = (
      msOn = -1,
      msOff = 2,
      msStandBy = 1);
  strict private
    FMsgWnd: HWND;
    FNotifyDisplayState: HPOWERNOTIFY;

    FDisplayState: TDisplayState;
    FDisplayStateChange: TDisplayStateChangeEvent;

    procedure ChangeDisplayState(Value: TDisplayState);

    procedure MsgWndHandle(var Msg: TMessage);
    procedure SetDisplayState(const Value: TDisplayState);
    procedure SetDisplayStateChange(const Value: TDisplayStateChangeEvent);
  public
    constructor Create;
    destructor Destroy; override;

    procedure SetDisplayStateWithTimeout(Value: TDisplayState; Timeout: UINT);

    property DisplayState: TDisplayState read FDisplayState write SetDisplayState;
    property DisplayStateChange: TDisplayStateChangeEvent read FDisplayStateChange write SetDisplayStateChange;
  end;

implementation

{ TDisplayStateHandler }

constructor TDisplayStateHandler.Create;
begin
  FDisplayState := dsOn;

  FMsgWnd := AllocateHWnd(MsgWndHandle);
  if IsWindowsVistaOrGreater then
  begin
    if IsWindows8OrGreater then
      FNotifyDisplayState := RegisterPowerSettingNotification(
        FMsgWnd, GUID_CONSOLE_DISPLAY_STATE, DEVICE_NOTIFY_WINDOW_HANDLE)
    else
      FNotifyDisplayState := RegisterPowerSettingNotification(
        FMsgWnd, GUID_MONITOR_POWER_ON, DEVICE_NOTIFY_WINDOW_HANDLE);
  end;
end;

destructor TDisplayStateHandler.Destroy;
begin
  if IsWindowsVistaOrGreater then
  begin
    if FNotifyDisplayState <> nil then
      UnregisterPowerSettingNotification(FNotifyDisplayState);
  end;
  DeallocateHWnd(FMsgWnd);

  inherited;
end;

procedure TDisplayStateHandler.ChangeDisplayState(Value: TDisplayState);
const
  ToMonitorPowerState: array [dsOff..dsDimmed] of TMonitorPowerState = (msOff, msOn, msStandBy);
begin
  DefWindowProc(GetDesktopWindow(), WM_SYSCOMMAND, SC_MONITORPOWER, LPARAM(ToMonitorPowerState[Value]));
end;

procedure TDisplayStateHandler.MsgWndHandle(var Msg: TMessage);
var
  PowerBroadcastSetting: TPowerBroadcastSetting;
  State: TDisplayState;
begin
  Msg.Result := DefWindowProc(FMsgWnd, Msg.Msg, Msg.WParam, Msg.LParam);

  if Msg.Msg = WM_POWERBROADCAST then
  begin
    case Msg.WParam of
      PBT_POWERSETTINGCHANGE:
        begin
          PowerBroadcastSetting:= PPowerBroadcastSetting(Msg.LParam)^;

          // Изменилось состояние монитора
          if (PowerBroadcastSetting.PowerSetting = GUID_CONSOLE_DISPLAY_STATE) or
             (PowerBroadcastSetting.PowerSetting = GUID_MONITOR_POWER_ON) then
          begin
            State := TDisplayState(PDWORD(@PowerBroadcastSetting.Data)^);
            if State = FDisplayState then
              Exit;

            FDisplayState := State;

            if Assigned(FDisplayStateChange) then
              FDisplayStateChange(Self, FDisplayState);
            Exit;
          end;
        end;
    end;
  end;

  if Msg.Msg = WM_TIMER then
  begin
    KillTimer(FMsgWnd, Msg.WParam);
    case Msg.WParam of
      TimerMonitorOff:    ChangeDisplayState(dsOff);
      TimerMonitorOn:     ChangeDisplayState(dsOn);
      TimerMonitorDimmed: ChangeDisplayState(dsDimmed);
    end;
    Exit;
  end;
end;

procedure TDisplayStateHandler.SetDisplayStateWithTimeout(Value: TDisplayState;
  Timeout: UINT);
var
  TimerType: UINT_PTR;
begin
  case Value of
    dsOff:    TimerType := TimerMonitorOff;
    dsOn:     TimerType := TimerMonitorOn;
    dsDimmed: TimerType := TimerMonitorDimmed;
    else Exit;
  end;
  SetTimer(FMsgWnd, TimerType, Timeout, nil)
end;

procedure TDisplayStateHandler.SetDisplayState(const Value: TDisplayState);
begin
  ChangeDisplayState(Value);
end;

procedure TDisplayStateHandler.SetDisplayStateChange(
  const Value: TDisplayStateChangeEvent);
begin
  FDisplayStateChange := Value;
  if Assigned(FDisplayStateChange) then
    FDisplayStateChange(Self, FDisplayState);
end;

end.
