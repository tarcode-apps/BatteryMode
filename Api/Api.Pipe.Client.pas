unit Api.Pipe.Client;

interface

uses
  Winapi.Windows,
  System.SysUtils,
  Api.Pipe.Command;

type
  TApiClient = class
  private
    FFullPipeName: string;
  public
    constructor Create(PipeName: string);

    function Send(Command: IApiCommand): Boolean;
    function SendAndWaitResponse(Command: IApiCommand; out Response: string): Boolean;
  end;

implementation

{ TApiClient }

constructor TApiClient.Create(PipeName: string);
const
  PipeBaseNameFmt = '\\.\pipe\%0:s';
begin
  inherited Create;
  FFullPipeName := Format(PipeBaseNameFmt, [PipeName]);
end;

function TApiClient.Send(Command: IApiCommand): Boolean;
var
  Pipe: THandle;
  lpBytesWrite: DWORD;
  LastError: DWORD;

  CommandStr: string;
begin
  Pipe := CreateFile(LPCTSTR(FFullPipeName), GENERIC_WRITE or GENERIC_READ, 0,
    nil, OPEN_EXISTING, FILE_FLAG_WRITE_THROUGH, 0);

  if Pipe = INVALID_HANDLE_VALUE then
    Exit(False);

  try
    LastError := GetLastError;
    if (LastError <> ERROR_SUCCESS) and (LastError <> ERROR_PIPE_BUSY) then
      Exit(False);

    if LastError = ERROR_PIPE_BUSY then
      if not WaitNamedPipe(LPCTSTR(FFullPipeName), 8000) then
        Exit(False);

    CommandStr := Command.GetCommand;
    Result := WriteFile(Pipe,
      LPCTSTR(CommandStr)^, CommandStr.Length * Sizeof(char),
      lpBytesWrite, nil);
  finally
    CloseHandle(Pipe);
  end;
end;

function TApiClient.SendAndWaitResponse(Command: IApiCommand;
  out Response: string): Boolean;
const
  BufferSize = 512;
var
  Pipe: THandle;
  Buffer: array [0 .. BufferSize - 1] of Char;
  lpBytesRead: DWORD;
  LastError: DWORD;

  CommandStr: string;
  lpMode: DWORD;
begin
  Response := '';

  Pipe := CreateFile(LPCTSTR(FFullPipeName), GENERIC_WRITE or GENERIC_READ, 0,
    nil, OPEN_EXISTING, FILE_FLAG_WRITE_THROUGH, 0);

  if pipe = INVALID_HANDLE_VALUE then
    Exit(False);

  try
    LastError := GetLastError;
    if (LastError <> ERROR_SUCCESS) and (LastError <> ERROR_PIPE_BUSY) then
      Exit(False);

    if LastError = ERROR_PIPE_BUSY then
      if not WaitNamedPipe(LPCTSTR(FFullPipeName), 8000) then
        Exit(False);

    lpMode := PIPE_READMODE_MESSAGE;
    if not SetNamedPipeHandleState(Pipe, lpMode, nil, nil) then
      Exit(False);

    CommandStr := Command.GetCommand;
    Result := TransactNamedPipe(Pipe,
      LPCTSTR(CommandStr), CommandStr.Length * Sizeof(char),
      @Buffer[0], BufferSize, lpBytesRead, nil);

    if not Result and (GetLastError() <> ERROR_MORE_DATA) then
      Exit(False);

    while True do
    begin
      Response := Response + Copy(Buffer, 0, lpBytesRead div SizeOf(Char));

      if Result then
        Break;

      Result := ReadFile(Pipe, Buffer[0], BufferSize, lpBytesRead, nil);
      if not Result and (GetLastError() <> ERROR_MORE_DATA) then
        Break;
    end;
  finally
    CloseHandle(Pipe);
  end;
end;

end.
