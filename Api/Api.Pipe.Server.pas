unit Api.Pipe.Server;

interface

uses
  Winapi.Windows,
  System.SysUtils, System.Classes,
  Battery.Mode,
  Brightness.Manager,
  Pipes, Api.Pipe.Command, Api.Pipe.Server.Command;

type
  TApiServer = class
  private
    PipeServer: TPipeServer;
    FBrightnessManager: TBrightnessManager;

    procedure PipeServerMessage(Sender : TObject; Pipe : HPIPE; Stream : TStream);
    procedure WorkerSendCommand(Sender: TObject; Command: IApiCommand);
    function Send(Pipe: HPIPE; Command: IApiCommand): Boolean;
  public
    constructor Create(BrightnessManager: TBrightnessManager);
    destructor Destroy; override;
  end;

  TSendCommandEvent = procedure(Sender: TObject; Command: IApiCommand) of object;
  TApiWorker = class(TThread)
  private
    FPipe: HPIPE;
    FComandString: string;
    FBrightnessManager: TBrightnessManager;
    FOnSendCommand: TSendCommandEvent;
    procedure DoWork;
  protected
    procedure Execute; override;
  public
    constructor Create(Pipe: HPIPE; ComandString: string; BrightnessManager: TBrightnessManager);
    property OnSendCommand: TSendCommandEvent read FOnSendCommand write FOnSendCommand;
    property Pipe: HPIPE read FPipe;
  end;

implementation

{ TApiServer }

constructor TApiServer.Create(BrightnessManager: TBrightnessManager);
begin
  inherited Create;

  FBrightnessManager := BrightnessManager;

  PipeServer := TPipeServer.CreateUnowned;
  PipeServer.OnPipeMessage := PipeServerMessage;
  PipeServer.PipeName := CommandPipeName;
  PipeServer.Active := True;
end;

destructor TApiServer.Destroy;
begin
  PipeServer.Free;
  inherited;
end;

procedure TApiServer.PipeServerMessage(Sender: TObject; Pipe: HPIPE;
  Stream: TStream);
var
  Worker: TApiWorker;
  Str : String;
begin
  if Stream.Size = 0 then
    Exit;

  SetLength(Str, Stream.Size div SizeOf(Char));
  Stream.Position := 0;
  Stream.Read(LPTSTR(Str)^, Stream.Size);

  Worker := TApiWorker.Create(Pipe, Str, FBrightnessManager);
  Worker.OnSendCommand := WorkerSendCommand;
  Worker.Start;
end;

procedure TApiServer.WorkerSendCommand(Sender: TObject; Command: IApiCommand);
begin
  Send((Sender as TApiWorker).Pipe, Command);
end;

function TApiServer.Send(Pipe: HPIPE; Command: IApiCommand): Boolean;
const
  BufSize = 512;
var
  Str: string;
begin
  Str := Command.GetCommand;
  Result := PipeServer.Write(Pipe, PChar(Str)^, Length(Str) * SizeOf(Char));
end;

{ TApiWorker }

constructor TApiWorker.Create(Pipe: HPIPE; ComandString: string; BrightnessManager: TBrightnessManager);
begin
  inherited Create(True);

  FPipe := Pipe;
  FComandString := ComandString;
  FBrightnessManager := BrightnessManager;

  FreeOnTerminate := True;
end;

procedure TApiWorker.DoWork;
var
  Cmd: IApiCommand;
  ServerCmd: IApiServerCommand;
begin
  Cmd := TApiBaseCommand.Create;
  if not Cmd.Parse(FComandString) then Exit;

  case Cmd.CommandType of
    actChangeScheme:
      ServerCmd := TApiServerChangeScheme.Create;
    actSetBrightness:
      ServerCmd := TApiServerSetBrightness.Create(FBrightnessManager);
    actGetBrightnessMonitors:
      begin
        if Assigned(FOnSendCommand) then
          FOnSendCommand(Self, TApiServerBrightnessMonitors.Create(FBrightnessManager));
        Exit;
      end
    else Exit;
  end;

  if not ServerCmd.Parse(FComandString) then Exit;
  ServerCmd.Run;
end;

procedure TApiWorker.Execute;
begin
  Synchronize(DoWork);
end;

end.
