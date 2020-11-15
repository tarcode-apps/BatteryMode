unit Core.Startup;

interface
uses
  Winapi.Windows;

type
  TMutexLocker = class
  private
    class var FName: string;
    class var FMutex: THandle;
    class var FIsLocked: Boolean;
    class var FIsExist: Boolean;
  public
    class procedure Init(Name: string; Locked: Boolean = False);

    class function Lock: Boolean;
    class procedure Unlock;

    class property IsLocked: Boolean read FIsLocked;
    class property IsExist: Boolean read FIsExist;
  end;

implementation

{ TMutexLocker }

class procedure TMutexLocker.Init(Name: string; Locked: Boolean);
begin
  FName := Name;
  FMutex := 0;
  FIsLocked := False;
  FIsExist := False;

  if Locked then Lock;
end;

class function TMutexLocker.Lock: Boolean;
begin
  FMutex := CreateMutex(nil, True, LPCTSTR(FName));
  FIsLocked := FMutex <> 0;
  FIsExist := GetLastError() = ERROR_ALREADY_EXISTS;

  Result := FIsLocked;
end;

class procedure TMutexLocker.Unlock;
begin
  if FMutex <> 0 then
    CloseHandle(FMutex);
  FIsLocked := False;
  FIsExist := False;
end;

end.
