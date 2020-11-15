unit WinHttp_TLB;

// ************************************************************************ //
// WARNING                                                                    
// -------                                                                    
// The types declared in this file were generated from data read from a       
// Type Library. If this type library is explicitly or indirectly (via        
// another type library referring to this type library) re-imported, or the   
// 'Refresh' command of the Type Library Editor activated while editing the   
// Type Library, the contents of this file will be regenerated and all        
// manual modifications will be lost.                                         
// ************************************************************************ //

// PASTLWTR : 1.2
// File generated on 26/03/2013 17:40:09 from Type Library described below.

// ************************************************************************  //
// Type Lib: C:\Windows\system32\winhttp.dll (1)
// LIBID: {662901FC-6951-4854-9EB2-D9A2570F2B2E}
// LCID: 0
// Helpfile: 
// HelpString: Microsoft WinHTTP Services, version 5.1
// DepndLst: 
//   (1) v2.0 stdole, (C:\Windows\SysWOW64\stdole2.tlb)
// Errors:
//   Error creating palette bitmap of (TWinHttpRequest) : Server C:\Windows\system32\winhttp.dll contains no icons
// ************************************************************************ //
// *************************************************************************//
// NOTE:                                                                      
// Items guarded by $IFDEF_LIVE_SERVER_AT_DESIGN_TIME are used by properties  
// which return objects that may need to be explicitly created via a function 
// call prior to any access via the property. These items have been disabled  
// in order to prevent accidental use from within the object inspector. You   
// may enable them by defining LIVE_SERVER_AT_DESIGN_TIME or by selectively   
// removing them from the $IFDEF blocks. However, such items must still be    
// programmatically created via a method of the appropriate CoClass before    
// they can be used.                                                          
{$TYPEDADDRESS OFF} // Unit must be compiled without type-checked pointers. 
{$WARN SYMBOL_PLATFORM OFF}
{$WRITEABLECONST ON}
{$VARPROPSETTER ON}
interface

uses Windows, ActiveX, Classes, Graphics, OleServer, StdVCL, Variants;
  

// *********************************************************************//
// GUIDS declared in the TypeLibrary. Following prefixes are used:        
//   Type Libraries     : LIBID_xxxx                                      
//   CoClasses          : CLASS_xxxx                                      
//   DISPInterfaces     : DIID_xxxx                                       
//   Non-DISP interfaces: IID_xxxx                                        
// *********************************************************************//
const
  // TypeLibrary Major and minor versions
  WinHttpMajorVersion = 5;
  WinHttpMinorVersion = 1;

  LIBID_WinHttp: TGUID = '{662901FC-6951-4854-9EB2-D9A2570F2B2E}';

  IID_IWinHttpRequest: TGUID = '{016FE2EC-B2C8-45F8-B23B-39E53A75396B}';
  IID_IWinHttpRequestEvents: TGUID = '{F97F4E15-B787-4212-80D1-D380CBBF982E}';
  CLASS_WinHttpRequest: TGUID = '{2087C2F4-2CEF-4953-A8AB-66779B670495}';

// *********************************************************************//
// Declaration of Enumerations defined in Type Library                    
// *********************************************************************//
// Constants for enum WinHttpRequestOption
type
  WinHttpRequestOption = TOleEnum;
const
  WinHttpRequestOption_UserAgentString = $00000000;
  WinHttpRequestOption_URL = $00000001;
  WinHttpRequestOption_URLCodePage = $00000002;
  WinHttpRequestOption_EscapePercentInURL = $00000003;
  WinHttpRequestOption_SslErrorIgnoreFlags = $00000004;
  WinHttpRequestOption_SelectCertificate = $00000005;
  WinHttpRequestOption_EnableRedirects = $00000006;
  WinHttpRequestOption_UrlEscapeDisable = $00000007;
  WinHttpRequestOption_UrlEscapeDisableQuery = $00000008;
  WinHttpRequestOption_SecureProtocols = $00000009;
  WinHttpRequestOption_EnableTracing = $0000000A;
  WinHttpRequestOption_RevertImpersonationOverSsl = $0000000B;
  WinHttpRequestOption_EnableHttpsToHttpRedirects = $0000000C;
  WinHttpRequestOption_EnablePassportAuthentication = $0000000D;
  WinHttpRequestOption_MaxAutomaticRedirects = $0000000E;
  WinHttpRequestOption_MaxResponseHeaderSize = $0000000F;
  WinHttpRequestOption_MaxResponseDrainSize = $00000010;
  WinHttpRequestOption_EnableHttp1_1 = $00000011;
  WinHttpRequestOption_EnableCertificateRevocationCheck = $00000012;
  WinHttpRequestOption_RejectUserpwd = $00000013;

// Constants for enum WinHttpRequestAutoLogonPolicy
type
  WinHttpRequestAutoLogonPolicy = TOleEnum;
const
  AutoLogonPolicy_Always = $00000000;
  AutoLogonPolicy_OnlyIfBypassProxy = $00000001;
  AutoLogonPolicy_Never = $00000002;

// Constants for enum WinHttpRequestSslErrorFlags
type
  WinHttpRequestSslErrorFlags = TOleEnum;
const
  SslErrorFlag_UnknownCA = $00000100;
  SslErrorFlag_CertWrongUsage = $00000200;
  SslErrorFlag_CertCNInvalid = $00001000;
  SslErrorFlag_CertDateInvalid = $00002000;
  SslErrorFlag_Ignore_All = $00003300;

// Constants for enum WinHttpRequestSecureProtocols
type
  WinHttpRequestSecureProtocols = TOleEnum;
const
  SecureProtocol_SSL2 = $00000008;
  SecureProtocol_SSL3 = $00000020;
  SecureProtocol_TLS1 = $00000080;
  SecureProtocol_ALL = $000000A8;

type

// *********************************************************************//
// Forward declaration of types defined in TypeLibrary                    
// *********************************************************************//
  IWinHttpRequest = interface;
  IWinHttpRequestDisp = dispinterface;
  IWinHttpRequestEvents = interface;

// *********************************************************************//
// Declaration of CoClasses defined in Type Library                       
// (NOTE: Here we map each CoClass to its Default Interface)              
// *********************************************************************//
  WinHttpRequest = IWinHttpRequest;


// *********************************************************************//
// Declaration of structures, unions and aliases.                         
// *********************************************************************//
  PPSafeArray1 = ^PSafeArray; {*}

  HTTPREQUEST_PROXY_SETTING = Integer; 
  HTTPREQUEST_SETCREDENTIALS_FLAGS = Integer; 

// *********************************************************************//
// Interface: IWinHttpRequest
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {016FE2EC-B2C8-45F8-B23B-39E53A75396B}
// *********************************************************************//
  IWinHttpRequest = interface(IDispatch)
    ['{016FE2EC-B2C8-45F8-B23B-39E53A75396B}']
    procedure SetProxy(ProxySetting: HTTPREQUEST_PROXY_SETTING; ProxyServer: OleVariant; 
                       BypassList: OleVariant); safecall;
    procedure SetCredentials(const UserName: WideString; const Password: WideString; 
                             Flags: HTTPREQUEST_SETCREDENTIALS_FLAGS); safecall;
    procedure Open(const Method: WideString; const Url: WideString; Async: OleVariant); safecall;
    procedure SetRequestHeader(const Header: WideString; const Value: WideString); safecall;
    function GetResponseHeader(const Header: WideString): WideString; safecall;
    function GetAllResponseHeaders: WideString; safecall;
    procedure Send(Body: OleVariant); safecall;
    function Get_Status: Integer; safecall;
    function Get_StatusText: WideString; safecall;
    function Get_ResponseText: WideString; safecall;
    function Get_ResponseBody: OleVariant; safecall;
    function Get_ResponseStream: OleVariant; safecall;
    function Get_Option(Option: WinHttpRequestOption): OleVariant; safecall;
    procedure Set_Option(Option: WinHttpRequestOption; Value: OleVariant); safecall;
    function WaitForResponse(Timeout: OleVariant): WordBool; safecall;
    procedure Abort; safecall;
    procedure SetTimeouts(ResolveTimeout: Integer; ConnectTimeout: Integer; SendTimeout: Integer; 
                          ReceiveTimeout: Integer); safecall;
    procedure SetClientCertificate(const ClientCertificate: WideString); safecall;
    procedure SetAutoLogonPolicy(AutoLogonPolicy: WinHttpRequestAutoLogonPolicy); safecall;
    property Status: Integer read Get_Status;
    property StatusText: WideString read Get_StatusText;
    property ResponseText: WideString read Get_ResponseText;
    property ResponseBody: OleVariant read Get_ResponseBody;
    property ResponseStream: OleVariant read Get_ResponseStream;
    property Option[Option: WinHttpRequestOption]: OleVariant read Get_Option write Set_Option;
  end;

// *********************************************************************//
// DispIntf:  IWinHttpRequestDisp
// Flags:     (4544) Dual NonExtensible OleAutomation Dispatchable
// GUID:      {016FE2EC-B2C8-45F8-B23B-39E53A75396B}
// *********************************************************************//
  IWinHttpRequestDisp = dispinterface
    ['{016FE2EC-B2C8-45F8-B23B-39E53A75396B}']
    procedure SetProxy(ProxySetting: HTTPREQUEST_PROXY_SETTING; ProxyServer: OleVariant; 
                       BypassList: OleVariant); dispid 13;
    procedure SetCredentials(const UserName: WideString; const Password: WideString; 
                             Flags: HTTPREQUEST_SETCREDENTIALS_FLAGS); dispid 14;
    procedure Open(const Method: WideString; const Url: WideString; Async: OleVariant); dispid 1;
    procedure SetRequestHeader(const Header: WideString; const Value: WideString); dispid 2;
    function GetResponseHeader(const Header: WideString): WideString; dispid 3;
    function GetAllResponseHeaders: WideString; dispid 4;
    procedure Send(Body: OleVariant); dispid 5;
    property Status: Integer readonly dispid 7;
    property StatusText: WideString readonly dispid 8;
    property ResponseText: WideString readonly dispid 9;
    property ResponseBody: OleVariant readonly dispid 10;
    property ResponseStream: OleVariant readonly dispid 11;
    property Option[Option: WinHttpRequestOption]: OleVariant dispid 6;
    function WaitForResponse(Timeout: OleVariant): WordBool; dispid 15;
    procedure Abort; dispid 12;
    procedure SetTimeouts(ResolveTimeout: Integer; ConnectTimeout: Integer; SendTimeout: Integer; 
                          ReceiveTimeout: Integer); dispid 16;
    procedure SetClientCertificate(const ClientCertificate: WideString); dispid 17;
    procedure SetAutoLogonPolicy(AutoLogonPolicy: WinHttpRequestAutoLogonPolicy); dispid 18;
  end;

// *********************************************************************//
// Interface: IWinHttpRequestEvents
// Flags:     (384) NonExtensible OleAutomation
// GUID:      {F97F4E15-B787-4212-80D1-D380CBBF982E}
// *********************************************************************//
  IWinHttpRequestEvents = interface(IUnknown)
    ['{F97F4E15-B787-4212-80D1-D380CBBF982E}']
    procedure OnResponseStart(Status: Integer; const ContentType: WideString); stdcall;
    procedure OnResponseDataAvailable(var Data: PSafeArray); stdcall;
    procedure OnResponseFinished; stdcall;
    procedure OnError(ErrorNumber: Integer; const ErrorDescription: WideString); stdcall;
  end;

// *********************************************************************//
// The Class CoWinHttpRequest provides a Create and CreateRemote method to          
// create instances of the default interface IWinHttpRequest exposed by              
// the CoClass WinHttpRequest. The functions are intended to be used by             
// clients wishing to automate the CoClass objects exposed by the         
// server of this typelibrary.                                            
// *********************************************************************//
  CoWinHttpRequest = class
    class function Create: IWinHttpRequest;
    class function CreateRemote(const MachineName: string): IWinHttpRequest;
  end;

  TWinHttpRequestOnResponseStart = procedure(ASender: TObject; Status: Integer; 
                                                               const ContentType: WideString) of object;
  TWinHttpRequestOnResponseDataAvailable = procedure(ASender: TObject; var Data: PSafeArray) of object;
  TWinHttpRequestOnError = procedure(ASender: TObject; ErrorNumber: Integer; 
                                                       const ErrorDescription: WideString) of object;


// *********************************************************************//
// OLE Server Proxy class declaration
// Server Object    : TWinHttpRequest
// Help String      : WinHttpRequest component
// Default Interface: IWinHttpRequest
// Def. Intf. DISP? : No
// Event   Interface: IWinHttpRequestEvents
// TypeFlags        : (2) CanCreate
// *********************************************************************//
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  TWinHttpRequestProperties= class;
{$ENDIF}
  TWinHttpRequest = class(TOleServer)
  private
    FOnResponseStart: TWinHttpRequestOnResponseStart;
    FOnResponseDataAvailable: TWinHttpRequestOnResponseDataAvailable;
    FOnResponseFinished: TNotifyEvent;
    FOnError: TWinHttpRequestOnError;
    FIntf:        IWinHttpRequest;
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    FProps:       TWinHttpRequestProperties;
    function      GetServerProperties: TWinHttpRequestProperties;
{$ENDIF}
    function      GetDefaultInterface: IWinHttpRequest;
  protected
    procedure InitServerData; override;
    procedure InvokeEvent(DispID: TDispID; var Params: TVariantArray); override;
    function Get_Status: Integer;
    function Get_StatusText: WideString;
    function Get_ResponseText: WideString;
    function Get_ResponseBody: OleVariant;
    function Get_ResponseStream: OleVariant;
    function Get_Option(Option: WinHttpRequestOption): OleVariant;
    procedure Set_Option(Option: WinHttpRequestOption; Value: OleVariant);
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
    procedure Connect; override;
    procedure ConnectTo(svrIntf: IWinHttpRequest);
    procedure Disconnect; override;
    procedure SetProxy(ProxySetting: HTTPREQUEST_PROXY_SETTING); overload;
    procedure SetProxy(ProxySetting: HTTPREQUEST_PROXY_SETTING; ProxyServer: OleVariant); overload;
    procedure SetProxy(ProxySetting: HTTPREQUEST_PROXY_SETTING; ProxyServer: OleVariant; 
                       BypassList: OleVariant); overload;
    procedure SetCredentials(const UserName: WideString; const Password: WideString; 
                             Flags: HTTPREQUEST_SETCREDENTIALS_FLAGS);
    procedure Open(const Method: WideString; const Url: WideString); overload;
    procedure Open(const Method: WideString; const Url: WideString; Async: OleVariant); overload;
    procedure SetRequestHeader(const Header: WideString; const Value: WideString);
    function GetResponseHeader(const Header: WideString): WideString;
    function GetAllResponseHeaders: WideString;
    procedure Send; overload;
    procedure Send(Body: OleVariant); overload;
    function WaitForResponse: WordBool; overload;
    function WaitForResponse(Timeout: OleVariant): WordBool; overload;
    procedure Abort;
    procedure SetTimeouts(ResolveTimeout: Integer; ConnectTimeout: Integer; SendTimeout: Integer; 
                          ReceiveTimeout: Integer);
    procedure SetClientCertificate(const ClientCertificate: WideString);
    procedure SetAutoLogonPolicy(AutoLogonPolicy: WinHttpRequestAutoLogonPolicy);
    property DefaultInterface: IWinHttpRequest read GetDefaultInterface;
    property Status: Integer read Get_Status;
    property StatusText: WideString read Get_StatusText;
    property ResponseText: WideString read Get_ResponseText;
    property ResponseBody: OleVariant read Get_ResponseBody;
    property ResponseStream: OleVariant read Get_ResponseStream;
    property Option[Option: WinHttpRequestOption]: OleVariant read Get_Option write Set_Option;
  published
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
    property Server: TWinHttpRequestProperties read GetServerProperties;
{$ENDIF}
    property OnResponseStart: TWinHttpRequestOnResponseStart read FOnResponseStart write FOnResponseStart;
    property OnResponseDataAvailable: TWinHttpRequestOnResponseDataAvailable read FOnResponseDataAvailable write FOnResponseDataAvailable;
    property OnResponseFinished: TNotifyEvent read FOnResponseFinished write FOnResponseFinished;
    property OnError: TWinHttpRequestOnError read FOnError write FOnError;
  end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
// *********************************************************************//
// OLE Server Properties Proxy Class
// Server Object    : TWinHttpRequest
// (This object is used by the IDE's Property Inspector to allow editing
//  of the properties of this server)
// *********************************************************************//
 TWinHttpRequestProperties = class(TPersistent)
  private
    FServer:    TWinHttpRequest;
    function    GetDefaultInterface: IWinHttpRequest;
    constructor Create(AServer: TWinHttpRequest);
  protected
    function Get_Status: Integer;
    function Get_StatusText: WideString;
    function Get_ResponseText: WideString;
    function Get_ResponseBody: OleVariant;
    function Get_ResponseStream: OleVariant;
    function Get_Option(Option: WinHttpRequestOption): OleVariant;
    procedure Set_Option(Option: WinHttpRequestOption; Value: OleVariant);
  public
    property DefaultInterface: IWinHttpRequest read GetDefaultInterface;
  published
  end;
{$ENDIF}


procedure Register;

resourcestring
  dtlServerPage = 'ActiveX';

  dtlOcxPage = 'ActiveX';

implementation

uses ComObj;

class function CoWinHttpRequest.Create: IWinHttpRequest;
begin
  Result := CreateComObject(CLASS_WinHttpRequest) as IWinHttpRequest;
end;

class function CoWinHttpRequest.CreateRemote(const MachineName: string): IWinHttpRequest;
begin
  Result := CreateRemoteComObject(MachineName, CLASS_WinHttpRequest) as IWinHttpRequest;
end;

procedure TWinHttpRequest.InitServerData;
const
  CServerData: TServerData = (
    ClassID:   '{2087C2F4-2CEF-4953-A8AB-66779B670495}';
    IntfIID:   '{016FE2EC-B2C8-45F8-B23B-39E53A75396B}';
    EventIID:  '{F97F4E15-B787-4212-80D1-D380CBBF982E}';
    LicenseKey: nil;
    Version: 500);
begin
  ServerData := @CServerData;
end;

procedure TWinHttpRequest.Connect;
var
  punk: IUnknown;
begin
  if FIntf = nil then
  begin
    punk := GetServer;
    ConnectEvents(punk);
    Fintf:= punk as IWinHttpRequest;
  end;
end;

procedure TWinHttpRequest.ConnectTo(svrIntf: IWinHttpRequest);
begin
  Disconnect;
  FIntf := svrIntf;
  ConnectEvents(FIntf);
end;

procedure TWinHttpRequest.DisConnect;
begin
  if Fintf <> nil then
  begin
    DisconnectEvents(FIntf);
    FIntf := nil;
  end;
end;

function TWinHttpRequest.GetDefaultInterface: IWinHttpRequest;
begin
  if FIntf = nil then
    Connect;
  Assert(FIntf <> nil, 'DefaultInterface is NULL. Component is not connected to Server. You must call ''Connect'' or ''ConnectTo'' before this operation');
  Result := FIntf;
end;

constructor TWinHttpRequest.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps := TWinHttpRequestProperties.Create(Self);
{$ENDIF}
end;

destructor TWinHttpRequest.Destroy;
begin
{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
  FProps.Free;
{$ENDIF}
  inherited Destroy;
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
function TWinHttpRequest.GetServerProperties: TWinHttpRequestProperties;
begin
  Result := FProps;
end;
{$ENDIF}

procedure TWinHttpRequest.InvokeEvent(DispID: TDispID; var Params: TVariantArray);
begin
  case DispID of
    -1: Exit;  // DISPID_UNKNOWN
(*{The DispID for this method is DISPID_UNKNOWN!?. }
    -1: if Assigned(FOnResponseStart) then
         FOnResponseStart(Self,
                          Params[0] {Integer},
                          Params[1] {const WideString});
*)
(*{The DispID for this method is DISPID_UNKNOWN!?. }
    -1: if Assigned(FOnResponseDataAvailable) then
         FOnResponseDataAvailable(Self, {??PSafeArray}OleVariant((TVarData(Params[0]).VPointer)^) {var  ??PSafeArray OleVariant});
*)
(*{The DispID for this method is DISPID_UNKNOWN!?. }
    -1: if Assigned(FOnResponseFinished) then
         FOnResponseFinished(Self);
*)
(*{The DispID for this method is DISPID_UNKNOWN!?. }
    -1: if Assigned(FOnError) then
         FOnError(Self,
                  Params[0] {Integer},
                  Params[1] {const WideString});
*)
  end; {case DispID}
end;

function TWinHttpRequest.Get_Status: Integer;
begin
    Result := DefaultInterface.Status;
end;

function TWinHttpRequest.Get_StatusText: WideString;
begin
    Result := DefaultInterface.StatusText;
end;

function TWinHttpRequest.Get_ResponseText: WideString;
begin
    Result := DefaultInterface.ResponseText;
end;

function TWinHttpRequest.Get_ResponseBody: OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.ResponseBody;
end;

function TWinHttpRequest.Get_ResponseStream: OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.ResponseStream;
end;

function TWinHttpRequest.Get_Option(Option: WinHttpRequestOption): OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.Option[Option];
end;

procedure TWinHttpRequest.Set_Option(Option: WinHttpRequestOption; Value: OleVariant);
begin
  DefaultInterface.Option[Option] := Value;
end;

procedure TWinHttpRequest.SetProxy(ProxySetting: HTTPREQUEST_PROXY_SETTING);
begin
  DefaultInterface.SetProxy(ProxySetting, EmptyParam, EmptyParam);
end;

procedure TWinHttpRequest.SetProxy(ProxySetting: HTTPREQUEST_PROXY_SETTING; ProxyServer: OleVariant);
begin
  DefaultInterface.SetProxy(ProxySetting, ProxyServer, EmptyParam);
end;

procedure TWinHttpRequest.SetProxy(ProxySetting: HTTPREQUEST_PROXY_SETTING; 
                                   ProxyServer: OleVariant; BypassList: OleVariant);
begin
  DefaultInterface.SetProxy(ProxySetting, ProxyServer, BypassList);
end;

procedure TWinHttpRequest.SetCredentials(const UserName: WideString; const Password: WideString; 
                                         Flags: HTTPREQUEST_SETCREDENTIALS_FLAGS);
begin
  DefaultInterface.SetCredentials(UserName, Password, Flags);
end;

procedure TWinHttpRequest.Open(const Method: WideString; const Url: WideString);
begin
  DefaultInterface.Open(Method, Url, EmptyParam);
end;

procedure TWinHttpRequest.Open(const Method: WideString; const Url: WideString; Async: OleVariant);
begin
  DefaultInterface.Open(Method, Url, Async);
end;

procedure TWinHttpRequest.SetRequestHeader(const Header: WideString; const Value: WideString);
begin
  DefaultInterface.SetRequestHeader(Header, Value);
end;

function TWinHttpRequest.GetResponseHeader(const Header: WideString): WideString;
begin
  Result := DefaultInterface.GetResponseHeader(Header);
end;

function TWinHttpRequest.GetAllResponseHeaders: WideString;
begin
  Result := DefaultInterface.GetAllResponseHeaders;
end;

procedure TWinHttpRequest.Send;
begin
  DefaultInterface.Send(EmptyParam);
end;

procedure TWinHttpRequest.Send(Body: OleVariant);
begin
  DefaultInterface.Send(Body);
end;

function TWinHttpRequest.WaitForResponse: WordBool;
begin
  Result := DefaultInterface.WaitForResponse(EmptyParam);
end;

function TWinHttpRequest.WaitForResponse(Timeout: OleVariant): WordBool;
begin
  Result := DefaultInterface.WaitForResponse(Timeout);
end;

procedure TWinHttpRequest.Abort;
begin
  DefaultInterface.Abort;
end;

procedure TWinHttpRequest.SetTimeouts(ResolveTimeout: Integer; ConnectTimeout: Integer; 
                                      SendTimeout: Integer; ReceiveTimeout: Integer);
begin
  DefaultInterface.SetTimeouts(ResolveTimeout, ConnectTimeout, SendTimeout, ReceiveTimeout);
end;

procedure TWinHttpRequest.SetClientCertificate(const ClientCertificate: WideString);
begin
  DefaultInterface.SetClientCertificate(ClientCertificate);
end;

procedure TWinHttpRequest.SetAutoLogonPolicy(AutoLogonPolicy: WinHttpRequestAutoLogonPolicy);
begin
  DefaultInterface.SetAutoLogonPolicy(AutoLogonPolicy);
end;

{$IFDEF LIVE_SERVER_AT_DESIGN_TIME}
constructor TWinHttpRequestProperties.Create(AServer: TWinHttpRequest);
begin
  inherited Create;
  FServer := AServer;
end;

function TWinHttpRequestProperties.GetDefaultInterface: IWinHttpRequest;
begin
  Result := FServer.DefaultInterface;
end;

function TWinHttpRequestProperties.Get_Status: Integer;
begin
    Result := DefaultInterface.Status;
end;

function TWinHttpRequestProperties.Get_StatusText: WideString;
begin
    Result := DefaultInterface.StatusText;
end;

function TWinHttpRequestProperties.Get_ResponseText: WideString;
begin
    Result := DefaultInterface.ResponseText;
end;

function TWinHttpRequestProperties.Get_ResponseBody: OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.ResponseBody;
end;

function TWinHttpRequestProperties.Get_ResponseStream: OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.ResponseStream;
end;

function TWinHttpRequestProperties.Get_Option(Option: WinHttpRequestOption): OleVariant;
var
  InterfaceVariant : OleVariant;
begin
  InterfaceVariant := DefaultInterface;
  Result := InterfaceVariant.Option[Option];
end;

procedure TWinHttpRequestProperties.Set_Option(Option: WinHttpRequestOption; Value: OleVariant);
begin
  DefaultInterface.Option[Option] := Value;
end;

{$ENDIF}

procedure Register;
begin
  RegisterComponents(dtlServerPage, [TWinHttpRequest]);
end;

end.
