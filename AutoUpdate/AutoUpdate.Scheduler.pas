unit AutoUpdate.Scheduler;

interface

uses
  System.SysUtils, System.Classes, System.DateUtils,
  Vcl.ExtCtrls,
  AutoUpdate, AutoUpdate.VersionDefinition, AutoUpdate.Params,
  Versions;

type
  TEventUpdateCheck = procedure(Sender: TObject) of object;
  TEventUpdateSaveLastCheck = procedure(Sender: TObject; Time: TDateTime) of object;
  TEventUpdateInstalling = procedure(Sender: TObject) of object;
  TEventUpdateSkip = procedure(Sender: TObject; Version: TVersion) of object;
  TEventUpdateAvalible = procedure(Sender: TObject; Version: TVersion) of object;

  TAutoUpdateScheduler = class
  private const
    AutoCheckDelay = 8000;
    UrlParamFmt = '%0:s?%1:s';
    CheckFmt = 'check=%0:s';
    CheckAuto = 'auto';
    CheckUser = 'user';
  public type
    TStartupUpdateStatus = (susNone, susComplete, susFail);
  private
    FUrl: string;
    FID: TAppID;
    FLastCheck: TDateTime;
    FSkipVersion: TVersion;
    FPeriod: TDateTime;
    FEnable: Boolean;
    FCheckInProgress: Boolean;
    FTimer: TTimer;

    FOnChecked: TEventUpdateCheck;
    FOnInstalling: TEventUpdateInstalling;
    FOnInCheck: TEventUpdateCheck;
    FOnSkip: TEventUpdateSkip;
    FOnSaveLastCheck: TEventUpdateSaveLastCheck;
    FOnAvalible: TEventUpdateAvalible;

    procedure AutoUpdateInstallUpdate(Sender: TObject; FileVersionInfo: TFileVersionInfo);
    procedure AutoUpdateAvalibleUpdate(Sender: TObject; FileVersionInfo: TFileVersionInfo);
    procedure AutoUpdateSkipUpdate(Sender: TObject; FileVersionInfo: TFileVersionInfo);
    procedure AutoUpdateCancelUpdate(Sender: TObject);
    procedure AutoUpdateCheckedUpdate(Sender: TObject);
    procedure AutoUpdateErrorUpdate(Sender: TObject);

    procedure SetEnable(const Value: Boolean);
    function GetStartupUpdateStatus: TStartupUpdateStatus;

    procedure FTimerTimer(Sender: TObject);
  public
    class function NewID: TAppID; inline; static;
  public
    constructor Create(Url: string; LastCheck: TDateTime; SkipVersion: TVersion; ID: TAppID); reintroduce;
    destructor Destroy; override;

    procedure Check(UserCheck: Boolean = False);

    property Enable: Boolean read FEnable write SetEnable;
    property LastCheck: TDateTime read FLastCheck;
    property SkipVersion: TVersion read FSkipVersion;
    property IsCheckInProgress: Boolean read FCheckInProgress;
    property StartupUpdateStatus: TStartupUpdateStatus read GetStartupUpdateStatus;
    property ID: TAppID read FID;

    property OnInCheck: TEventUpdateCheck read FOnInCheck write FOnInCheck;
    property OnChecked: TEventUpdateCheck read FOnChecked write FOnChecked;
    property OnSaveLastCheck: TEventUpdateSaveLastCheck read FOnSaveLastCheck write FOnSaveLastCheck;
    property OnInstalling: TEventUpdateInstalling read FOnInstalling write FOnInstalling;
    property OnSkip: TEventUpdateSkip read FOnSkip write FOnSkip;
    property OnAvalible: TEventUpdateAvalible read FOnAvalible write FOnAvalible;
  end;

implementation

{ TAutoUpdateScheduler }

class function TAutoUpdateScheduler.NewID: TAppID;
var
  I, R: Integer;
begin
  for I := 0 to 100 do
  begin
    Randomize;
    R := Random(R.MaxValue);
    if (R > 0) and (R < R.MaxValue) then Exit(TAppID(R));
  end;
  Result := 0;
end;


constructor TAutoUpdateScheduler.Create(Url: string; LastCheck: TDateTime;
  SkipVersion: TVersion; ID: TAppID);
begin
  inherited Create;

  FUrl := Url;
  FLastCheck := LastCheck;
  FSkipVersion := SkipVersion;
  FID := ID;
  FEnable := False;
  FCheckInProgress := False;

  FPeriod := EncodeTime(23, 59, 59, 999);

  FTimer := TTimer.Create(nil);
  FTimer.Enabled := False;
  FTimer.OnTimer := FTimerTimer;
end;

destructor TAutoUpdateScheduler.Destroy;
begin
  FTimer.Free;
  inherited Destroy;
end;

procedure TAutoUpdateScheduler.Check(UserCheck: Boolean);
var
  AutoUpdate: TAutoUpdate;
  PreparedUrl, CheckType: string;
begin
  if FCheckInProgress then Exit;

  if UserCheck then CheckType := CheckUser else CheckType := CheckAuto;
  PreparedUrl := Format(UrlParamFmt, [FUrl, Format(CheckFmt, [CheckType])]);

  FCheckInProgress := True;
  AutoUpdate := TAutoUpdate.Create(PreparedUrl, FID);
  AutoUpdate.OnInstall  := AutoUpdateInstallUpdate;
  AutoUpdate.OnAvalible := AutoUpdateAvalibleUpdate;
  AutoUpdate.OnSkip     := AutoUpdateSkipUpdate;
  AutoUpdate.OnCancel   := AutoUpdateCancelUpdate;
  AutoUpdate.OnChecked  := AutoUpdateCheckedUpdate;
  AutoUpdate.OnError    := AutoUpdateErrorUpdate;

  if Assigned(FOnInCheck) then FOnInCheck(Self);

  if UserCheck then
    AutoUpdate.CheckAsync(TVersion.Empty, False, False)
  else
    AutoUpdate.CheckAsync(FSkipVersion);
end;

{$REGION 'Setter and Getter'}
procedure TAutoUpdateScheduler.SetEnable(const Value: Boolean);
begin
  if FEnable = Value then Exit;

  FEnable := Value;

  if Abs(Now - FLastCheck) > FPeriod then
    FTimer.Interval := AutoCheckDelay
  else
    FTimer.Interval := MilliSecondOfTheDay(FPeriod - (Abs(Now - FLastCheck)));

  FTimer.Enabled := FEnable;
end;

function TAutoUpdateScheduler.GetStartupUpdateStatus: TStartupUpdateStatus;
var
  I: Integer;
begin
  for I := 1 to ParamCount do
  begin
    if ParamStr(I) = StartParamUpdateComplete then Exit(susComplete);
    if ParamStr(I) = StartParamUpdateFail then Exit(susFail);
  end;
  Result := susNone;
end;
{$ENDREGION}

{$REGION 'AutoUpdate Event'}
procedure TAutoUpdateScheduler.AutoUpdateInstallUpdate(Sender: TObject;
  FileVersionInfo: TFileVersionInfo);
begin
  FCheckInProgress := False;
  if Assigned(FOnChecked) then FOnChecked(Self);
  if Assigned(FOnInstalling) then FOnInstalling(Self);
end;

procedure TAutoUpdateScheduler.AutoUpdateAvalibleUpdate(Sender: TObject;
  FileVersionInfo: TFileVersionInfo);
begin
  FCheckInProgress := False;
  if Assigned(FOnChecked) then FOnChecked(Self);
  if Assigned(FOnAvalible) then FOnAvalible(Self, FileVersionInfo.Version);
end;

procedure TAutoUpdateScheduler.AutoUpdateSkipUpdate(Sender: TObject;
  FileVersionInfo: TFileVersionInfo);
begin
  FCheckInProgress := False;
  FSkipVersion := FileVersionInfo.Version;
  if Assigned(FOnChecked) then FOnChecked(Self);
  if Assigned(FOnSkip) then FOnSkip(Self, FSkipVersion);
end;

procedure TAutoUpdateScheduler.AutoUpdateCancelUpdate(Sender: TObject);
begin
  FCheckInProgress := False;
  if Assigned(FOnChecked) then FOnChecked(Self);
end;

procedure TAutoUpdateScheduler.AutoUpdateCheckedUpdate(Sender: TObject);
begin
  FLastCheck := Now;
  if Assigned(FOnSaveLastCheck) then FOnSaveLastCheck(Self, FLastCheck);
end;

procedure TAutoUpdateScheduler.AutoUpdateErrorUpdate(Sender: TObject);
begin
  FCheckInProgress := False;
  if Assigned(FOnChecked) then FOnChecked(Self);
end;
{$ENDREGION}

procedure TAutoUpdateScheduler.FTimerTimer(Sender: TObject);
begin
  (Sender as TTimer).Interval := MilliSecondOfTheDay(FPeriod);
  Check;
end;

end.
