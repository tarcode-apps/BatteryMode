unit Autorun.Manager;

interface

uses
  Winapi.Windows, Winapi.ShellAPI,
  System.SysUtils,
  System.Generics.Collections, System.Generics.Defaults,
  Vcl.Forms,
  Core.Language, Core.Startup.Tasks,
  Autorun;

type
  TEventAutorunChange = procedure(Sender: TObject; Autorun: Boolean) of object;

  TAutorunManager = class
  private const
    MsgAutorunWithoutHRL  = 500;
    MsgAutorunOk          = 501;
    MsgDeleteOk           = 502;
    MsgAddError           = 503;
    MsgDeleteError        = 504;
  private
    FOptions: TAutorunOptions;
    FOnAutorun: TEventAutorunChange;

    FProviders: TList<IAutorunProvider>;
    FDefaultProviderIndex: Integer;
    FActiveProviderIndex: Integer;

    procedure SetOnAutorun(const Value: TEventAutorunChange);
  public
    constructor Create;
    destructor Destroy; override;

    procedure AddProvider(Provider: IAutorunProvider; Active: Boolean = False; Default: Boolean = False);
    procedure RemoveProvider(Provider: IAutorunProvider);

    function Autorun: Boolean;
    function IsAutorun: Boolean;
    function DeleteAutorun: Boolean;

    function SetAutorunEx(Enable: Boolean): Boolean;

    property Options: TAutorunOptions read FOptions;
    property OnAutorun: TEventAutorunChange read FOnAutorun write SetOnAutorun;
  end;

var
  AutorunManager: TAutorunManager;

implementation

{ TAutorunManager }

constructor TAutorunManager.Create;
begin
  FProviders := TList<IAutorunProvider>.Create;
  FDefaultProviderIndex := -1;
  FActiveProviderIndex := -1;

  FOptions := TAutorunOptions.Create;
end;

destructor TAutorunManager.Destroy;
begin
  FOptions.Free;
  FProviders.Free;
  inherited;
end;

function TAutorunManager.Autorun: Boolean;
begin
  DeleteAutorun;

  if (FActiveProviderIndex >= 0) and FProviders[FActiveProviderIndex].IsAvalible then
    Exit(FProviders[FActiveProviderIndex].Autorun(Options));

  if (FDefaultProviderIndex >= 0) and FProviders[FDefaultProviderIndex].IsAvalible then
    Exit(FProviders[FDefaultProviderIndex].Autorun(Options));

  Result := False;
end;

function TAutorunManager.DeleteAutorun: Boolean;
var
  Privider: IAutorunProvider;
begin
  Result := True;
  for Privider in FProviders do
    if Privider.IsAvalible then
      Result := Privider.DeleteAutorun(Options) and Result;
end;

function TAutorunManager.IsAutorun: Boolean;
var
  Provider: IAutorunProvider;
begin
  Result := False;
  for Provider in FProviders do
    if Provider.IsAvalible then
      Result := Result or Provider.IsAutorun(Options);
end;

function TAutorunManager.SetAutorunEx(Enable: Boolean): Boolean;
var
  Sei: TShellExecuteInfo;
  lpExitCode: DWORD;

  function NotifyInfo(Msg: string): Integer;
  begin
    Result := MessageBox(Application.MainForm.Handle, LPCTSTR(Msg), LPCTSTR(TLang[1]), MB_OK or MB_ICONINFORMATION);
  end;

  function NotifyWarn(Msg: string): Integer;
  begin
    Result := MessageBox(Application.MainForm.Handle, LPCTSTR(Msg), LPCTSTR(TLang[1]), MB_OK or MB_ICONWARNING);
  end;

  function NotifyError(Msg: string): Integer;
  begin
    Result := MessageBox(Application.MainForm.Handle, LPCTSTR(Msg), LPCTSTR(TLang[1]), MB_OK or MB_ICONERROR);
  end;

  function AddAutorunWithoutHighestRunLevel: Boolean;
  var
    HighestRunLevelOld: Boolean;
  begin
    HighestRunLevelOld := Options.HighestRunLevel;
    Options.HighestRunLevel := False;
    try
      Result := Autorun;
      if Result then
        NotifyWarn(TLang[MsgAutorunWithoutHRL]) // Программа добавлена в автозапуск без привилегий администратора.
      else
        NotifyError(TLang[MsgAddError]); // Ошибка добавления в автозапуск.
    finally
      Options.HighestRunLevel := HighestRunLevelOld;
    end;
  end;
begin
  if Enable then
    Result := Autorun
  else
    Result := DeleteAutorun;

  if Result then
  begin
    if Enable then
      NotifyInfo(TLang[MsgAutorunOk]) // Программа добавлена в автозапуск.
    else
      NotifyInfo(TLang[MsgDeleteOk]); // Программа удалена из автозапуска.
  end
  else
  begin
    ZeroMemory(@Sei, SizeOf(Sei));
    Sei.cbSize := SizeOf(TShellExecuteInfo);
    Sei.fMask := SEE_MASK_NOCLOSEPROCESS;
    Sei.lpVerb := PChar('runas');
    Sei.lpFile := LPCTSTR(ExpandUNCFileName(Options.FileName));
    Sei.nShow := SW_HIDE;
    if Enable then
      Sei.lpParameters := LPCTSTR(TStartupTasks.CmdAutorun)
    else
      Sei.lpParameters := LPCTSTR(TStartupTasks.CmdDelAutorun);

    if ShellExecuteEx(@Sei) then begin
      WaitForSingleObject(Sei.hProcess, INFINITE);

      if GetExitCodeProcess(Sei.hProcess, lpExitCode) then begin
        Result := (lpExitCode = TStartupTasks.ERROR_Ok);
        if Result then
          if Enable then
            NotifyInfo(TLang[MsgAutorunOk]) // Программа добавлена в автозапуск.
          else
            NotifyInfo(TLang[MsgDeleteOk]) // Программа удалена из автозапуска.
        else
          if Enable then
            NotifyError(TLang[MsgAddError]) // Ошибка добавления в автозапуск.
          else
            NotifyError(TLang[MsgDeleteError]); // Ошибка удаления из автозапуска.
      end else begin
        Result := (IsAutorun = Enable);
        if Result then
          if Enable then
            NotifyInfo(TLang[MsgAutorunOk]) // Программа добавлена в автозапуск.
          else
            NotifyInfo(TLang[MsgDeleteOk]) // Программа удалена из автозапуска.
        else
          if Enable then
            Result := AddAutorunWithoutHighestRunLevel
          else
            NotifyError(TLang[MsgDeleteError]); // Ошибка удаления из автозапуска.
      end;
      CloseHandle(Sei.hProcess);
    end else
      if Enable then
        Result := AddAutorunWithoutHighestRunLevel
      else begin
        Result := False;
        NotifyError(TLang[MsgDeleteError]); // Ошибка удаления из автозапуска.
      end;
  end;

  if Assigned(FOnAutorun) then FOnAutorun(Self, Enable = Result);
end;

procedure TAutorunManager.AddProvider(Provider: IAutorunProvider; Active,
  Default: Boolean);
var
  Index: Integer;
begin
  Index := FProviders.Add(Provider);

  if Active then
    FActiveProviderIndex := Index;

  if Default then
    FDefaultProviderIndex := Index;
end;

procedure TAutorunManager.RemoveProvider(Provider: IAutorunProvider);
var
  Index: Integer;
begin
  Index := FProviders.Remove(Provider);

  if Index < 0 then Exit;
  Dec(FActiveProviderIndex);
  Dec(FDefaultProviderIndex);

  if FProviders.Count = 0 then Exit;
  if FActiveProviderIndex < 0 then FActiveProviderIndex := 0;
  if FDefaultProviderIndex < 0 then FDefaultProviderIndex := 0;
end;

procedure TAutorunManager.SetOnAutorun(const Value: TEventAutorunChange);
begin
  FOnAutorun := Value;
  if Assigned(FOnAutorun) then FOnAutorun(Self, IsAutorun);
end;

initialization
  AutorunManager := TAutorunManager.Create;

end.
