unit Versions.Info;

interface

uses
  Winapi.Windows, System.SysUtils,
  Versions;

type
  LANGANDCODEPAGE = record
    wLanguage: Word;
    wCodePage: Word;
  end;

  TVersionInfo = class
  private
    class var FFileName: TFileName;
    class var FLanguageInfo: string;
    class var FCompanyName: string;
    class var FFileDescription: string;
    class var FFileVersion: TVersion;
    class var FInternalName: string;
    class var FLegalCopyright: string;
    class var FOriginalFileName: string;
    class var FProductName: string;
    class var FProductVersion: TVersion;
    class var FComments: string;
    class var FBinaryType: DWORD;
    class procedure SetFileName(const Value: TFileName); static;
    class function GetBinaryTypeAsString: string; static;
    class function GetBinaryTypeAsShortString: string; static;
    class procedure Load; static;
    class procedure Clear; static;

    class constructor Create;
  public
    class function GetBuildOnly: string; static;
    class function GetRealFileName: string; static;
    class property FileName: TFileName read FFileName write SetFileName;
    class property LanguageInfo: string read FLanguageInfo;
    class property CompanyName: string read FCompanyName;
    class property FileDescription: string read FFileDescription;
    class property FileVersion: TVersion read FFileVersion;
    class property InternalName: string read FInternalName;
    class property LegalCopyright: string read FLegalCopyright;
    class property OriginalFileName: string read FOriginalFileName;
    class property ProductName: string read FProductName;
    class property ProductVersion: TVersion read FProductVersion;
    class property Comments: string read FComments;
    class property BinaryType: DWORD read FBinaryType;
    class property BinaryTypeAsString: string read GetBinaryTypeAsString;
    class property BinaryTypeAsShortString: string read GetBinaryTypeAsShortString;
  end;

implementation

uses
  Winapi.Messages, System.Classes;

{ TVersionInfo }

class function TVersionInfo.GetBuildOnly: string;
var
  Delimiter: Integer;
begin
  Delimiter:= LastDelimiter('.', FFileVersion);
  Result:= Copy(FFileVersion, Delimiter + 1, Length(FFileVersion) - Delimiter);
end;

class function TVersionInfo.GetRealFileName: string;
var
  nSize: DWORD;
begin
  nSize := MAX_PATH;
  SetLength(Result, nSize);
  nSize:= GetModuleFileName(0, LPTSTR(Result), nSize);
  if nSize <> 0 then
    SetLength(Result, nSize)
  else
    Result := '';
end;

class procedure TVersionInfo.Load;
var
  VInfo, Trans: Pointer;
  VInfoSize, Handle: DWORD;
  TransSize: UINT;

  function GetStringValue(const From: string): string;
  var
    Size: UINT;
    tempStr: string;
    Value: PChar;
  begin
    tempStr := Format('%s%.4x%.4x\%s%s', ['\StringFileInfo\', LoWord(LongInt(Trans^)), HiWord(LongInt(Trans^)), From, #0]);
    VerQueryValue(PChar(VInfo), PChar(tempStr), Pointer(Value), Size);
    if Size > 0 then Result:= Value else Result:= '';
  end;
begin
  Clear;

  if not FileExists(FFileName) then Exit;
  VInfoSize:= GetFileVersionInfoSize(PChar(FFileName), Handle);

  if VInfoSize < 1 then Exit;

  VInfo:= AllocMem(VInfoSize);
  GetFileVersionInfo(PChar(FFileName), Handle, VInfoSize, VInfo);

  VerQueryValue(VInfo,'\VarFileInfo\Translation', Trans, TransSize);
  if TransSize < 4 then Exit;

  FCompanyName:= GetStringValue('CompanyName');
  FFileDescription:= GetStringValue('FileDescription');
  FFileVersion:= GetStringValue('FileVersion');
  FInternalName:= GetStringValue('InternalName');
  FLegalCopyright:= GetStringValue('LegalCopyright');
  FOriginalFilename:= GetStringValue('OriginalFilename');
  FProductName:= GetStringValue('ProductName');
  FProductVersion:= GetStringValue('ProductVersion');
  FComments:= GetStringValue('Comments');

  FreeMem(VInfo, VInfoSize);

  if not GetBinaryType(LPTSTR(FFileName), FBinaryType) then FBinaryType:= DWORD(-1);
end;

class procedure TVersionInfo.Clear;
begin
  FLanguageInfo:= '';
  FCompanyName:= '';
  FFileDescription:= '';
  FFileVersion:= '';
  FInternalName:= '';
  FLegalCopyright:= '';
  FOriginalFileName:= '';
  FProductName:= '';
  FProductVersion:= '';
  FComments:= '';
  FBinaryType:= DWORD(-1);
end;

class procedure TVersionInfo.SetFileName(const Value: TFileName);
begin
  FFileName := Value;
  Load;
end;

class function TVersionInfo.GetBinaryTypeAsString: string;
begin
  case FBinaryType of
    SCS_32BIT_BINARY  : Result:= 'A 32-bit Windows-based application';
    SCS_64BIT_BINARY  : Result:= 'A 64-bit Windows-based application';
    SCS_DOS_BINARY    : Result:= 'An MS-DOS - based application';
    SCS_OS216_BINARY  : Result:= 'A 16-bit OS/2-based application';
    SCS_PIF_BINARY    : Result:= 'A PIF file that executes an MS-DOS – based application';
    SCS_POSIX_BINARY  : Result:= 'A POSIX – based application';
    SCS_WOW_BINARY    : Result:= 'A 16-bit Windows-based application';
    else Result:= '';
  end
end;

class function TVersionInfo.GetBinaryTypeAsShortString: string;
begin
  case FBinaryType of
    SCS_32BIT_BINARY  : Result:= 'x86';
    SCS_64BIT_BINARY  : Result:= 'x64';
    SCS_DOS_BINARY    : Result:= 'MS-DOS';
    SCS_OS216_BINARY  : Result:= '16-bit OS/2';
    SCS_PIF_BINARY    : Result:= 'PIF';
    SCS_POSIX_BINARY  : Result:= 'POSIX';
    SCS_WOW_BINARY    : Result:= 'Win16';
    else Result:= '';
  end
end;

class constructor TVersionInfo.Create;
begin
  TVersionInfo.FileName := GetRealFileName;
end;

end.
