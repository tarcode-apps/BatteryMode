unit Helpers.Services;

interface

uses
  Winapi.Windows, Winapi.WinSvc;

function ServiceGetStatus(sMachine, sService: LPCTSTR): DWORD;
function IsServiceRunning(sMachine, sService: LPCTSTR): Boolean;
function IsServiceExisting(sMachine, sService: LPCTSTR): Boolean;

implementation

function ServiceGetStatus(sMachine, sService: LPCTSTR): DWORD;
var
  SCManager, Service: SC_Handle;
  ServiceStatus: TServiceStatus;
begin
  Result := 0;
  // Open service manager handle.
  SCManager := OpenSCManager(sMachine, nil, SC_MANAGER_CONNECT);
  if SCManager > 0 then begin
    Service := OpenService(SCManager, sService, SERVICE_QUERY_STATUS);
    // if Service installed
    if (Service > 0) then begin
      // SS structure holds the service status (TServiceStatus);
      if (QueryServiceStatus(Service, ServiceStatus)) then
        Result := ServiceStatus.dwCurrentState;
      CloseServiceHandle(Service);
    end;
    CloseServiceHandle(SCManager);
  end;
end;

function IsServiceRunning(sMachine, sService: LPCTSTR): Boolean;
begin
  Result := ServiceGetStatus(sMachine, sService) = SERVICE_RUNNING;
end;

function IsServiceExisting(sMachine, sService: LPCTSTR): Boolean;
begin
  Result := ServiceGetStatus(sMachine, sService) <> 0;
end;

end.
