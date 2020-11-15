program Updater;

{$WEAKLINKRTTI ON}

{$IFDEF DEBUG}
  {$APPTYPE CONSOLE}
{$ENDIF}

{$R *.res}

{$IFDEF WIN64}
  {$R 'UpdaterFiles64.res' 'UpdaterFiles64.rc'}
{$ELSE}
  {$R 'UpdaterFiles32.res' 'UpdaterFiles32.rc'}
{$ENDIF}

uses
  Winapi.Windows,
  Winapi.ShellAPI,
  System.SysUtils,
  System.Classes,
  System.ZLib,
  System.Generics.Collections,
  System.Generics.Defaults,
  AutoUpdate.Params in 'AutoUpdate\AutoUpdate.Params.pas';

{$SETPEFlAGS
  IMAGE_FILE_DEBUG_STRIPPED or
  IMAGE_FILE_LINE_NUMS_STRIPPED or
  IMAGE_FILE_LOCAL_SYMS_STRIPPED or
  IMAGE_FILE_RELOCS_STRIPPED}

const
  FullFileNameFormat = '%0:s\%1:s';
  BakFileNameFormat = '%0:s.bak';
  FileResNameFormat = 'FileUpdate%0:u';
  FileMainOldOffset = 8000;
  FileMainNewOffset = 8001;
  FileUpdateOffset = 8002;
  MutexOffset = 8950;

  RestartParamsFormat = '%0:s %1:s';
  SilentParam = '-Silent';

type
  TFiles = TList<string>;

function GetString(Index: Integer): string;
var
  RetLength: Integer;
begin
  RetLength := MAX_PATH;
  SetLength(Result, RetLength);
  RetLength := LoadString(HInstance, Index, LPTSTR(Result), RetLength);
  SetLength(Result, RetLength);
end;

function ResourceExist(Index: Integer): Boolean;
var
  ResStream: TResourceStream;
begin
  Result := True;
  try
    ResStream := TResourceStream.Create(HInstance, Format(FileResNameFormat, [Index]), RT_RCDATA);
    ResStream.Free;
  except
    Result := False;
  end;
end;

function ExtractFile(Index: Integer; FileName: string): Boolean;
var
  ResStream: TResourceStream;
  DecompresStream: TDecompressionStream;
  SaveStream: TFileStream;
begin
  Result := True;
  try
    ResStream := TResourceStream.Create(HInstance, Format(FileResNameFormat, [Index]), RT_RCDATA);
    try
      ResStream.Position := 0;
      DecompresStream := TDecompressionStream.Create(ResStream);
      try
        SaveStream := TFileStream.Create(FileName, fmCreate or fmOpenWrite or fmShareDenyWrite);
        try
          DecompresStream.Position := 0;
          SaveStream.CopyFrom(DecompresStream, DecompresStream.Size);
        finally
          SaveStream.Free;
        end;
      finally
        DecompresStream.Free;
      end;
    finally
      ResStream.Free;
    end;
  except
    Result := False;
  end;
end;

function BackupFile(FileName: string): Boolean;
var
  BakFileName: string;
begin
  BakFileName := Format(BakFileNameFormat, [FileName]);

  if FileExists(BakFileName) then
  begin
    Result := DeleteFile(BakFileName);
    if not Result then Exit(False);
  end;

  Result := RenameFile(FileName, BakFileName);
end;

function RestoreFile(FileName: string): Boolean;
var
  BakFileName: string;
begin
  BakFileName := Format(BakFileNameFormat, [FileName]);

  Result := FileExists(BakFileName);
  if not Result then Exit(False);

  if FileExists(FileName) then
  begin
    Result := DeleteFile(FileName);
    if not Result then Exit(False);
  end;

  Result := RenameFile(BakFileName, FileName);
end;

function RestoreAllFile(const Files: TFiles): Boolean;
var
  FileName: string;
begin
  Result := True;
  for FileName in Files do
    Result := Result and RestoreFile(FileName);
end;

function DeleteAllBackup(const Files: TFiles): Boolean;
var
  FileName: string;
  BakFileName: string;
begin
  Result := True;
  for FileName in Files do
  begin
    BakFileName := Format(BakFileNameFormat, [FileName]);
    Result := Result and DeleteFile(BakFileName);
  end;
end;

function ReplaceFile(Index: Integer; Dir: string; var Backups: TFiles): Boolean;
var
  FileName: string;
begin
  FileName := Format(FullFileNameFormat, [Dir, GetString(FileUpdateOffset + Index)]);

  if FileExists(FileName) then
  begin
    Result := BackupFile(FileName);
    if not Result then Exit(False);

    Backups.Add(FileName);
  end;

  Result := ExtractFile(Index, FileName);
end;

function ReplaceAllFile(Dir: string): Boolean;
var
  I: Integer;
  Backups: TFiles;
begin
  Result := True;
  Backups := TFiles.Create;
  try
    I := 0;
    while ResourceExist(I) and Result do
    begin
      Result := ReplaceFile(I, Dir, Backups);
      Inc(I);
    end;

    if not Result then
    begin
      if RestoreAllFile(Backups) then
        DeleteAllBackup(Backups);
    end else
      DeleteAllBackup(Backups);
  finally
    Backups.Free;
  end;
end;

procedure UpdateComplete(Dir: string);
var
  FileName: string;
begin
  FileName := Format(FullFileNameFormat, [Dir, GetString(FileMainNewOffset)]);
  ShellExecute(0, LPTSTR('open'), LPTSTR(FileName), LPTSTR(StartParamUpdateComplete), LPTSTR(Dir), SW_NORMAL);
end;

procedure UpdateFail(Dir: string);
var
  FileName: string;
begin
  FileName := Format(FullFileNameFormat, [Dir, GetString(FileMainOldOffset)]);
  ShellExecute(0, LPTSTR('open'), LPTSTR(FileName), LPTSTR(StartParamUpdateFail), LPTSTR(Dir), SW_NORMAL);
end;

procedure ShowHelp;
begin
  MessageBox(0, 'CmdLine: "Directory of the updated program"', 'Using', MB_ICONINFORMATION or MB_OK);
end;

procedure WaitMutex;
const
  WaitTimeout = 3000;
var
  Mutex: THandle;
begin
  Mutex := OpenMutex(SYNCHRONIZE, True, LPTSTR(GetString(MutexOffset)));
  if Mutex = 0 then Exit;

  WaitForSingleObject(Mutex, WaitTimeout);
  CloseHandle(Mutex);
end;

var
  Silent: Boolean;
  ProgramDir: string;
  Sei: TShellExecuteInfo;
  lpExitCode: DWORD;

begin
  if ParamCount < 1 then
  begin
    ShowHelp;
    ExitProcess(1);
  end;

  ProgramDir := ParamStr(1);
  if not DirectoryExists(ProgramDir) then
  begin
    UpdateFail('');
    ExitProcess(1);
  end;

  if ParamCount >= 2 then
    Silent := UpperCase(ParamStr(2)) = UpperCase(SilentParam)
  else
    Silent := False;

  WaitMutex;

  if ReplaceAllFile(ProgramDir) then
  begin
    if not Silent then UpdateComplete(ProgramDir);
    ExitProcess(0);
  end
  else
  begin
    if Silent then ExitProcess(1);

    ZeroMemory(@Sei, SizeOf(Sei));
    Sei.cbSize := SizeOf(Sei);
    Sei.fMask := SEE_MASK_NOCLOSEPROCESS;
    Sei.lpVerb := LPTSTR('runas');
    Sei.lpFile := LPTSTR(ParamStr(0));
    Sei.nShow := SW_HIDE;
    Sei.lpParameters := PChar(Format(RestartParamsFormat, [ProgramDir.QuotedString('"'), SilentParam]));

    if ShellExecuteEx(@Sei) then
    begin
      WaitForSingleObject(Sei.hProcess, INFINITE);
      if not GetExitCodeProcess(Sei.hProcess, lpExitCode) then
      begin
        UpdateFail(ProgramDir);
        ExitProcess(1);
      end;

      if lpExitCode <> 0 then
      begin
        UpdateFail(ProgramDir);
        ExitProcess(1);
      end;

      UpdateComplete(ProgramDir);
    end
    else
    begin
      UpdateFail(ProgramDir);
      ExitProcess(1);
    end;
  end;
end.
