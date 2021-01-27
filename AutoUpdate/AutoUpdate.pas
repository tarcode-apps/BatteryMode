unit AutoUpdate;

interface

uses
  Winapi.Windows, Winapi.ShellAPI, Winapi.ActiveX, Winapi.WinInet,
  System.Classes, System.SysUtils, System.Variants,
  System.Generics.Collections, System.Generics.Defaults,
  Vcl.Forms, Vcl.AxCtrls, Vcl.Controls,
  AutoUpdate.Window.NotFound, AutoUpdate.Window.Update,
  AutoUpdate.VersionDefinition,
  Core.Language,
  Versions, Versions.Info, Versions.Helpers,
  WinHttp_TLB;

type
  TEventInstallUpdate = procedure(Sender: TObject; FileVersionInfo: TFileVersionInfo) of object;
  TEventAvalibleUpdate = procedure(Sender: TObject; FileVersionInfo: TFileVersionInfo) of object;
  TEventSkipUpdate = procedure(Sender: TObject; FileVersionInfo: TFileVersionInfo) of object;
  TEventCancelUpdate = procedure(Sender: TObject) of object;
  TEventCheckedUpdate = procedure(Sender: TObject) of object;
  TEventErrorUpdate = procedure(Sender: TObject) of object;

  TAppID = Integer;

  TAutoUpdate = class(TThread)
  private
    FUrl: string;
    FID: TAppID;
    FAutoUpdateVersionOnly: Boolean;
    FSilent: Boolean;
    FSkipVersion: TVersion;
    FOnChecked: TEventCheckedUpdate;

    FFileVersionInfoSync: TFileVersionInfo;
    FOnInstall: TEventInstallUpdate;
    FOnAvalible: TEventAvalibleUpdate;
    FOnCancel: TEventCancelUpdate;
    FOnSkip: TEventSkipUpdate;
    FOnError: TEventErrorUpdate;

    function Download(Url: string; var Stream: TStream): Boolean;

    function NotifyNoUpdates: Integer;
    function NotifyUpdateAvailable(FileVersionInfo: TFileVersionInfo): Integer;
    function GetWinTemp: string;

    procedure InstallUpdate(FileVersionInfo: TFileVersionInfo);
    procedure AvalibleUpdate(FileVersionInfo: TFileVersionInfo);
    procedure SkipUpdate(FileVersionInfo: TFileVersionInfo);
    procedure CancelUpdate;
    procedure CheckedUpdate;
    procedure ErrorUpdate;

    procedure DoInstallUpdate;
    procedure DoAvalibleUpdate;
    procedure DoSkipUpdate;
    procedure DoCancelUpdate;
    procedure DoCheckedUpdate;
    procedure DoErrorUpdate;

    procedure SetOnInstall(const Value: TEventInstallUpdate);
    procedure SetOnAvalible(const Value: TEventAvalibleUpdate);
    procedure SetOnSkip(const Value: TEventSkipUpdate);
    procedure SetOnCancel(const Value: TEventCancelUpdate);
    procedure SetOnChecked(const Value: TEventCheckedUpdate);
    procedure SetOnError(const Value: TEventErrorUpdate);
  protected
    procedure Execute; override;
  public
    constructor Create(Url: string; ID: TAppID);
    destructor Destroy; override;
    procedure CheckAsync(SkipVersion: TVersion;
      AutoUpdateVersionOnly: Boolean = True; Silent: Boolean = True);

    property OnInstall: TEventInstallUpdate read FOnInstall write SetOnInstall;
    property OnAvalible: TEventAvalibleUpdate read FOnAvalible write SetOnAvalible;
    property OnSkip: TEventSkipUpdate read FOnSkip write SetOnSkip;
    property OnCancel: TEventCancelUpdate read FOnCancel write SetOnCancel;
    property OnChecked: TEventCheckedUpdate read FOnChecked write SetOnChecked;
    property OnError: TEventErrorUpdate read FOnError write SetOnError;
  end;

implementation

procedure TrimWorkingSetSize;
var
  MainHandle: THandle;
begin
  MainHandle := OpenProcess(PROCESS_ALL_ACCESS, False, GetCurrentProcessID);
  SetProcessWorkingSetSize(MainHandle, SIZE_T(-1), SIZE_T(-1));
  CloseHandle(MainHandle);
end;


{ TAutoUpdate }

constructor TAutoUpdate.Create(Url: string; ID: TAppID);
begin
  inherited Create(True);
  FreeOnTerminate := True;

  FUrl := Url;
  FID := ID;
end;

destructor TAutoUpdate.Destroy;
begin
  inherited Destroy;
end;

procedure TAutoUpdate.SetOnInstall(const Value: TEventInstallUpdate);
begin
  FOnInstall := Value;
end;

procedure TAutoUpdate.SetOnAvalible(const Value: TEventAvalibleUpdate);
begin
  FOnAvalible := Value;
end;

procedure TAutoUpdate.SetOnSkip(const Value: TEventSkipUpdate);
begin
  FOnSkip := Value;
end;

procedure TAutoUpdate.SetOnCancel(const Value: TEventCancelUpdate);
begin
  FOnCancel := Value;
end;

procedure TAutoUpdate.SetOnChecked(const Value: TEventCheckedUpdate);
begin
  FOnChecked := Value;
end;

procedure TAutoUpdate.SetOnError(const Value: TEventErrorUpdate);
begin
  FOnError := Value;
end;

procedure TAutoUpdate.CheckAsync(SkipVersion: TVersion;
  AutoUpdateVersionOnly: Boolean = True; Silent: Boolean = True);
begin
  FSkipVersion := SkipVersion;
  FAutoUpdateVersionOnly := AutoUpdateVersionOnly;
  FSilent := Silent;

  Start;
end;

function TAutoUpdate.Download(Url: string; var Stream: TStream): Boolean;
const
  //           Name Ver  AppT  Lang  WinT  Maj Min  Build  AppID
  UserAgent = '%0:s %1:s %2:s; %3:u; %4:s %5:u.%6:u.%7:u; ID%8:.10u';
var
  Http: IWinHttpRequest;
  HttpStream: IStream;
  OleStream: TOleStream;
  WinType: string;
  WinVer: TOSVersionInfo;
begin
  Http := CoWinHttpRequest.Create;
  try
    Http.Open('GET', Url, False);
    if IsWindows64Bit then WinType := 'Win64' else WinType := 'Win32';
    if not GetWindowsVersion(WinVer) then
      ZeroMemory(@WinVer, SizeOf(WinVer));

    Http.Option[WinHttpRequestOption_UserAgentString] := Format(UserAgent,
        [TLang[1],
        TVersionInfo.FileVersion.ToString,
        TVersionInfo.BinaryTypeAsShortString,
        TLang.EffectiveLanguageId,
        WinType,
        WinVer.dwMajorVersion,
        WinVer.dwMinorVersion,
        WinVer.dwBuildNumber,
        FID]);
    Http.Send(EmptyParam);

    if Http.Status <> HTTP_STATUS_OK then Exit(False);

    HttpStream := IUnknown(Http.ResponseStream) as IStream;
    OleStream := TOleStream.Create(HttpStream);
    try
      OleStream.Position := 0;
      Stream.CopyFrom(OleStream, OleStream.Size);
      Result := True;
    finally
      OleStream.Free;
    end;
  finally
    Http := nil;
  end;
end;

procedure TAutoUpdate.Execute;
var
  UrlStream: TStringStream;
  StringList: TStringList;
  VersionUrl: string;
  VerStream: TStringStream;
  VersionDefinition: TVersionDefinition;
  FileVersionInfo: TFileVersionInfo;
begin
  try
    CoInitialize(nil);
    UrlStream := TStringStream.Create('', TEncoding.UTF8);
    try
      if not Download(FUrl, TStream(UrlStream)) then begin
        ErrorUpdate;
        Exit;
      end;

      StringList := TStringList.Create;
      try
        UrlStream.Position := 0;
        StringList.LoadFromStream(UrlStream, UrlStream.Encoding);
        VersionUrl := StringList.Text.Trim;
      finally
        StringList.Free;
      end;
    finally
      UrlStream.Free;
    end;

    VerStream := TStringStream.Create;
    try
      if not Download(VersionUrl, TStream(VerStream)) then begin
        ErrorUpdate;
        Exit;
      end;

      VersionDefinition := TVersionDefinition.Create(VerStream);
      try
        try
          CheckedUpdate;
          FileVersionInfo := VersionDefinition.GetCompatibilityFileVersion(TVersionInfo.FileVersion, FSkipVersion);
          if FAutoUpdateVersionOnly and not FileVersionInfo.AutoUpdate then begin
            ErrorUpdate;
            Exit;
          end;

          if FSilent then
            AvalibleUpdate(FileVersionInfo)
          else
            case NotifyUpdateAvailable(FileVersionInfo) of
              mrYes: InstallUpdate(FileVersionInfo);
              mrIgnore: SkipUpdate(FileVersionInfo);
              else CancelUpdate;
            end;
        except
          ErrorUpdate;
        end;
      finally
        VersionDefinition.Free;
      end;
    finally
      VerStream.Free;
    end;
    CoUninitialize;
  except
    ErrorUpdate;
  end;
end;

function TAutoUpdate.NotifyNoUpdates: Integer;
var
  Window: TNotFoundWindow;
begin
  Window := TNotFoundWindow.Create;
  try
    Result := Window.ShowNotify;
  finally
    Window.Free;
    TrimWorkingSetSize;
  end;
end;

function TAutoUpdate.NotifyUpdateAvailable(FileVersionInfo: TFileVersionInfo): Integer;
var
  Window: TAutoUpdateWnd;
  ChangeLogStream: TStringStream;
begin
  ChangeLogStream := TStringStream.Create;
  try
    try
      if not Download(FileVersionInfo.ChangeLogUrl, TStream(ChangeLogStream)) then
        ChangeLogStream.Clear;
      ChangeLogStream.Position := 0;
    except
      ChangeLogStream.Clear;
    end;

    Window := TAutoUpdateWnd.Create(FileVersionInfo, ChangeLogStream);
    try
      Result := Window.ShowNotify;
    finally
      Window.Free;
    end;
  finally
    ChangeLogStream.Free;
    TrimWorkingSetSize;
  end;
end;

function TAutoUpdate.GetWinTemp: string;
var
  nBufferLength: DWORD;
begin
  nBufferLength := MAX_PATH + 1;
  SetLength(Result, nBufferLength);
  nBufferLength := GetTempPath(nBufferLength, LPTSTR(Result));
  if nBufferLength > 0 then
    SetLength(Result, nBufferLength)
  else
    Result := string.Empty;
end;


procedure TAutoUpdate.DoInstallUpdate;
begin
  if Assigned(FOnInstall) then
    FOnInstall(Self, FFileVersionInfoSync);
end;
procedure TAutoUpdate.InstallUpdate(FileVersionInfo: TFileVersionInfo);
var
  FileName: string;
  FileParams: string;
  FileStream: TFileStream;

  function NotifyError(Msg: string): Integer;
  begin
    Result := MessageBox(Application.MainForm.Handle, LPCTSTR(Msg), LPCTSTR(TLang[1]), MB_OK or MB_ICONERROR);
  end;
begin
  FileName := GetWinTemp + FileVersionInfo.FileName;
  FileParams := ExtractFileDir(TVersionInfo.GetRealFileName).QuotedString('"');
  if not string.IsNullOrWhiteSpace(FileVersionInfo.FileParams) then
    FileParams := FileParams + ' ' + FileVersionInfo.FileParams;

  FileStream := TFileStream.Create(FileName, fmCreate);
  try
    if not Download(FileVersionInfo.FileUrl, TStream(FileStream)) then begin
      Synchronize(DoCancelUpdate);
      NotifyError(TLang[910]);
      Exit;
    end;
  finally
    FileStream.Free;
  end;

  if ShellExecute(0, LPTSTR('open'), LPTSTR(FileName), LPTSTR(FileParams) , nil, SW_NORMAL) > 32 then begin
    FFileVersionInfoSync := FileVersionInfo;
    Synchronize(DoInstallUpdate);
  end else begin
    Synchronize(DoCancelUpdate);
    NotifyError(TLang[911]);
  end;
end;


procedure TAutoUpdate.DoAvalibleUpdate;
begin
  if Assigned(FOnAvalible) then
    FOnAvalible(Self, FFileVersionInfoSync);
end;
procedure TAutoUpdate.AvalibleUpdate(FileVersionInfo: TFileVersionInfo);
begin
  FFileVersionInfoSync := FileVersionInfo;
  Synchronize(DoAvalibleUpdate);
end;


procedure TAutoUpdate.DoSkipUpdate;
begin
  if Assigned(FOnSkip) then
    FOnSkip(Self, FFileVersionInfoSync);
end;
procedure TAutoUpdate.SkipUpdate(FileVersionInfo: TFileVersionInfo);
begin
  FFileVersionInfoSync := FileVersionInfo;
  Synchronize(DoSkipUpdate);
end;


procedure TAutoUpdate.DoCancelUpdate;
begin
  if Assigned(FOnCancel) then
    FOnCancel(Self);
end;
procedure TAutoUpdate.CancelUpdate;
begin
  Synchronize(DoCancelUpdate);
end;


procedure TAutoUpdate.DoCheckedUpdate;
begin
  if Assigned(FOnChecked) then
    FOnChecked(Self);
end;
procedure TAutoUpdate.CheckedUpdate;
begin
  Synchronize(DoCheckedUpdate);
end;


procedure TAutoUpdate.DoErrorUpdate;
begin
  if Assigned(FOnError) then
    FOnError(Self);
end;
procedure TAutoUpdate.ErrorUpdate;
begin
  if not FSilent then NotifyNoUpdates;
  Synchronize(DoErrorUpdate);
end;

end.
