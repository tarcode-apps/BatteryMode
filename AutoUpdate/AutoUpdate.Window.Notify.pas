unit AutoUpdate.Window.Notify;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls,
  Core.UI.Controls;

type
  TAutoUpdateNotifyWindow = class(TCompatibleForm)
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure DoClose(var Action: TCloseAction); override;
  public
    constructor Create; reintroduce; virtual;
    function ShowNotify: Integer;
  end;

implementation

{ TAutoUpdateNotifyWindow }

constructor TAutoUpdateNotifyWindow.Create;
begin
  inherited Create(nil);
end;

procedure TAutoUpdateNotifyWindow.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.WndParent := 0;
  Params.ExStyle := Params.ExStyle or WS_EX_APPWINDOW;
end;

procedure TAutoUpdateNotifyWindow.DoClose(var Action: TCloseAction);
begin
  inherited DoClose(Action);
  ModalResult := mrClose;
end;

function TAutoUpdateNotifyWindow.ShowNotify: Integer;
begin
  Show;
  ModalResult := mrNone;
  try
    repeat
      Application.HandleMessage;
      if Application.Terminated then begin
        ModalResult := mrCancel;
        Close;
      end;
    until ModalResult <> mrNone;
    Result := ModalResult;
  except
    Result := mrNone;
  end;
end;

end.
