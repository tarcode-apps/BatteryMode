unit Core.UI.Notifications;

interface

type
  TNotificationFlag = (nfInfo, nfWarning, nfError);
  TNotificationFlags = set of TNotificationFlag;

  TNotificationCallback = procedure(Sender: TObject; Value: Integer) of object;

  INotification = interface
    function _GetTitle: string;
    procedure _SetTitle(const Value: string);

    function Notify(Msg: string): Boolean; overload;
    function Notify(Msg: string; Callback: TNotificationCallback): Boolean; overload;
    function Notify(Msg: string; Flags: TNotificationFlags): Boolean; overload;
    function Notify(Msg: string; Flags: TNotificationFlags; Callback: TNotificationCallback): Boolean; overload;
    function Notify(Msg: string; Title: string): Boolean; overload;
    function Notify(Msg: string; Title: string; Flags: TNotificationFlags): Boolean; overload;
    function Notify(Msg: string; Title: string; Flags: TNotificationFlags; Callback: TNotificationCallback): Boolean; overload;

    property Title: string read _GetTitle write _SetTitle;
  end;

  TNotificationService = class
  private class
    var FNotification: INotification;
    class function GetIsAvailable: Boolean; static;
  public
    class property Notification: INotification read FNotification write FNotification;
    class property IsAvailable: Boolean read GetIsAvailable;
  end;

implementation

{ TNotificationService }

class function TNotificationService.GetIsAvailable: Boolean;
begin
  Result := Assigned(FNotification);
end;

end.
