program FilePreparer;

{$WEAKLINKRTTI ON}

{$IFDEF DEBUG}
  {$APPTYPE CONSOLE}
{$ENDIF}

{$R *.res}

uses
  Winapi.Windows,
  System.SysUtils, System.Classes, System.ZLib;

{$SETPEFlAGS
  IMAGE_FILE_DEBUG_STRIPPED or
  IMAGE_FILE_LINE_NUMS_STRIPPED or
  IMAGE_FILE_LOCAL_SYMS_STRIPPED or
  IMAGE_FILE_RELOCS_STRIPPED}

const
  CompressionExt = '.gzip';
  ParamDir = '-d';

function CompressFile(Dir: string; FileName: string): Boolean;
var
  InStream: TFileStream;
  OutStream: TFileStream;
  CompressionStream: TCompressionStream;
  CompressionFileName: string;
begin
  Result := True;
  try
    CompressionFileName := ChangeFilePath(FileName, Dir);
    CompressionFileName := ChangeFileExt(CompressionFileName, CompressionExt);

    InStream := TFileStream.Create(FileName, fmOpenRead);
    try
      OutStream := TFileStream.Create(CompressionFileName, fmCreate or fmOpenWrite or fmShareDenyWrite);
      try
        OutStream.Position := 0;
        CompressionStream := TCompressionStream.Create(clMax, OutStream);
        try
          InStream.Position := 0;
          CompressionStream.CopyFrom(InStream, InStream.Size);
        finally
          CompressionStream.Free;
        end;
      finally
        OutStream.Free;
      end;
    finally
      InStream.Free;
    end;
  except
    Result := False;
  end;
end;

procedure ShowHelp;
begin
  MessageBox(0, 'CmdLine: [-d "Target Directory"] "File 1"[ "File 2" "File 3" ...]', 'Using', MB_ICONINFORMATION or MB_OK);
end;

procedure PrepareFail(Msg: string);
begin
  MessageBox(0, LPCTSTR(Msg), 'Error', MB_ICONERROR or MB_OK);
end;

var
  TargetDir: string;
  FileName: string;
  I: Integer;
begin
  if ParamCount < 1 then begin
    ShowHelp;
    ExitProcess(1);
  end;

  if ParamStr(1) = ParamDir then begin
    if ParamCount < 2 then ExitProcess(1);

    TargetDir := ParamStr(2);
    if not ForceDirectories(TargetDir) then ExitProcess(1);

    I := 3;
  end else
    I := 1;

  while I <= ParamCount do begin
    FileName := ParamStr(I);
    if IsRelativePath(FileName) then
      FileName := ExpandFileName(FileName);

    if not DirectoryExists(TargetDir) then
      TargetDir := ExtractFileDir(FileName);

    if not FileExists(FileName) then ExitProcess(1);
    if not CompressFile(TargetDir, FileName) then ExitProcess(1);

    Inc(I);
  end;
  ExitProcess(0);
end.
