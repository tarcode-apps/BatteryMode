unit Tray.Icon.Notifications;

interface

uses
  Winapi.Windows, Winapi.ShellAPI,
  System.Classes,
  Core.UI.Notifications,
  Tray.Icon;

type
  TTrayNotificationManager = class(TInterfacedObject, INotification)
  private
    FTitle: string;
    FTrayIcon: TTrayIcon;
    FCallback: TNotificationCallback;

    function _GetTitle: string;
    procedure _SetTitle(const Value: string);

    procedure TrayIconBalloonClick(Sender: TObject);
  public
    constructor Create(TrayIcon: TTrayIcon);
  
    function Notify(Msg: string): Boolean; overload; inline;
    function Notify(Msg: string; Callback: TNotificationCallback): Boolean; overload; inline;
    function Notify(Msg: string; Flags: TNotificationFlags): Boolean; overload; inline;
    function Notify(Msg: string; Flags: TNotificationFlags; Callback: TNotificationCallback): Boolean; overload; inline;
    function Notify(Msg: string; Title: string): Boolean; overload; inline;
    function Notify(Msg: string; Title: string; Flags: TNotificationFlags): Boolean; overload; inline;
    function Notify(Msg: string; Title: string; Flags: TNotificationFlags; Callback: TNotificationCallback): Boolean; overload;

    property Title: string read FTitle write FTitle;
    property TrayIcon: TTrayIcon read FTrayIcon;
  end;

implementation

{ TNotificationManager }

constructor TTrayNotificationManager.Create(TrayIcon: TTrayIcon);
begin
  FTrayIcon := TrayIcon;
  FTrayIcon.OnBalloonClick2 := TrayIconBalloonClick;
end;

function TTrayNotificationManager.Notify(Msg: string): Boolean;
begin
  Result := Notify(Msg, TNotificationCallback(nil));
end;

function TTrayNotificationManager.Notify(Msg: string; Callback: TNotificationCallback): Boolean;
begin
  Result := Notify(Msg, [nfInfo], Callback);
end;

function TTrayNotificationManager.Notify(Msg: string;
  Flags: TNotificationFlags): Boolean;
begin
  Result := Notify(Msg, Flags, TNotificationCallback(nil));
end;

function TTrayNotificationManager.Notify(Msg: string; Flags: TNotificationFlags;
  Callback: TNotificationCallback): Boolean;
begin
  Result := Notify(Msg, Title, Flags, Callback);
end;

function TTrayNotificationManager.Notify(Msg, Title: string): Boolean;
begin
  Result := Notify(Msg, Title, [nfInfo]);
end;

function TTrayNotificationManager.Notify(Msg, Title: string;
  Flags: TNotificationFlags): Boolean;
begin
  Result := Notify(Msg, Title, Flags, TNotificationCallback(nil));
end;

function TTrayNotificationManager.Notify(Msg, Title: string;
  Flags: TNotificationFlags; Callback: TNotificationCallback): Boolean;
var
  Niif: DWORD;  
begin
  if not Assigned(FTrayIcon) then Exit(False);
    
  FCallback := Callback;

  Niif := 0;
  if nfInfo in Flags then Niif := Niif or NIIF_INFO;
  if nfWarning in Flags then Niif := Niif or NIIF_WARNING;
  if nfError in Flags then Niif := Niif or NIIF_ERROR;  
    
  FTrayIcon.BalloonTitle := Title;
  FTrayIcon.BalloonHint := Msg;
  FTrayIcon.ShowBalloonHint(Niif);

  Result := True;
end;

procedure TTrayNotificationManager.TrayIconBalloonClick(Sender: TObject);
begin
  if Assigned(FCallback) then
    FCallback(Sender, IDOK);
end;

function TTrayNotificationManager._GetTitle: string;
begin
  Result := FTitle;
end;

procedure TTrayNotificationManager._SetTitle(const Value: string);
begin
  FTitle := Value;
end;

end.
