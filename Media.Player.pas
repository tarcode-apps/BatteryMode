unit Media.Player;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.Classes,
  Vcl.MPlayer;

type
  TMediaPlayer = class(Vcl.MPlayer.TMediaPlayer)
  strict private
    FFakeWnd: HWND;
    procedure FakeWndHandle(var Msg: TMessage);
  public
    constructor CreateWithoutUi;
    destructor Destroy; override;
  end;

implementation

{ TMediaPlayer }

constructor TMediaPlayer.CreateWithoutUi;
begin
  Create(nil);
  FFakeWnd := AllocateHWnd(FakeWndHandle);
  WindowHandle := FFakeWnd;
end;

destructor TMediaPlayer.Destroy;
begin
  inherited;
  if FFakeWnd <> 0 then DeallocateHWnd(FFakeWnd);
end;

procedure TMediaPlayer.FakeWndHandle(var Msg: TMessage);
begin
  Msg.Result := DefWindowProc(FFakeWnd, Msg.Msg, Msg.WParam, Msg.LParam);
end;

end.
