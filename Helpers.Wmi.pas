unit Helpers.Wmi;

interface

uses
  Winapi.Windows, Winapi.ActiveX,
  System.Classes,
  JwaWbemCli;

const
  RPC_C_AUTHN_LEVEL_DEFAULT = 0;
  RPC_C_IMP_LEVEL_IMPERSONATE = 3;
  RPC_C_AUTHN_WINNT = 10;
  RPC_C_AUTHZ_NONE = 0;
  RPC_C_AUTHN_LEVEL_CALL = 3;
  EOAC_NONE = 0;

const
  WmiLocalServer    = WideString('.');
  WmiLocalUser      = WideString('');
  WmiLocalPassword  = WideString('');

type
  TSinkIndicateEvent = procedure(Sender: TObject; objWbemObject: IWbemClassObject) of object;

  TWmiEventListener = class(TThread)
  strict private
    FEventObject: IWbemClassObject;
    FOnIndicate: TSinkIndicateEvent;
  protected
    FWqlQuery   : WideString;
    FNamespace  : WideString;
    FServer     : WideString;
    FUser       : WideString;
    FPassword   : WideString;
    FEnumTimeoutMilliseconds  : Longint;
    FDelayOnErrorMilliseconds : Integer;

    procedure Execute; override;
    procedure CallOnIndicate; virtual;
  public
    constructor Create(
      WqlQuery  : WideString;
      Namespace : WideString;
      Server    : WideString = WmiLocalServer;
      User      : WideString = WmiLocalUser;
      Password  : WideString = WmiLocalPassword;
      EnumTimeoutMilliseconds : Longint = 1000 * 60 * 60; // 1 Hour
      DelayOnErrorMilliseconds: Integer = 10 * 1000 // 10 Second
    ); overload;

    property OnIndicate: TSinkIndicateEvent read FOnIndicate write FOnIndicate;
  end;

implementation

{ TWmiEventListener }

constructor TWmiEventListener.Create(
  WqlQuery  : WideString;
  Namespace : WideString;
  Server    : WideString;
  User      : WideString;
  Password  : WideString;
  EnumTimeoutMilliseconds   : Longint;
  DelayOnErrorMilliseconds  : Integer);
begin
  inherited Create(True);
  FreeOnTerminate := True;

  FWqlQuery  := WqlQuery;
  FNamespace := Namespace;
  FServer    := Server;
  FUser      := User;
  FPassword  := Password;
  FEnumTimeoutMilliseconds := EnumTimeoutMilliseconds;
  FDelayOnErrorMilliseconds := DelayOnErrorMilliseconds;
end;

procedure TWmiEventListener.CallOnIndicate;
var
  IndicateEvent: TSinkIndicateEvent;
begin
  IndicateEvent := FOnIndicate;
  if Assigned(IndicateEvent) then IndicateEvent(Self, FEventObject);
end;

procedure TWmiEventListener.Execute;
var
  hr: HRESULT;
  Locator: IWbemLocator;
  Services: IWbemServices;
  ppEnum: IEnumWbemClassObject;
  WmiEvent: IWbemClassObject;
  Returned: ULONG;
begin
  hr := CoInitializeEx(nil, COINIT_APARTMENTTHREADED);
  if Failed(hr) then Exit;

  try
    hr := CoCreateInstance(CLSID_WbemLocator, nil, CLSCTX_INPROC_SERVER, IID_IWbemLocator, Locator);
    if Failed(hr) then Exit;

    hr := Locator.ConnectServer(FNamespace, FUser, FPassword, '', WBEM_FLAG_CONNECT_USE_MAX_WAIT, '', nil, Services);
    if Failed(hr) then Exit;

    hr := Services.ExecNotificationQuery('WQL', FWqlQuery, WBEM_FLAG_FORWARD_ONLY or WBEM_FLAG_RETURN_IMMEDIATELY, nil, ppEnum);
    if not Succeeded(hr) then Exit;

    while not Terminated do
    begin
      case ppEnum.Next(FEnumTimeoutMilliseconds, 1, WmiEvent, Returned) of
        WBEM_S_NO_ERROR:
        begin
          FEventObject := WmiEvent;
          if not Terminated then Synchronize(CallOnIndicate);
          FEventObject := nil;
          WmiEvent := nil;
        end;
        WBEM_S_TIMEDOUT:
          Continue;
        else
          Sleep(FDelayOnErrorMilliseconds);
      end;
    end;
  finally
    Services := nil;
    Locator  := nil;
    CoUninitialize;
  end;
end;

end.
