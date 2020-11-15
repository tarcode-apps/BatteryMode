unit Autorun.Providers.Registry;

interface

uses
  Winapi.Windows,
  System.SysUtils, System.Win.Registry,
  Autorun;

type
  TRegistryProvider = class(TInterfacedObject, IAutorunProvider)
  public
    function Autorun(Options: TAutorunOptions): Boolean;
    function DeleteAutorun(Options: TAutorunOptions): Boolean;
    function IsAutorun(Options: TAutorunOptions): Boolean;
    function IsAvalible: Boolean;
  end;

implementation

{ TRegistryProvider }

function TRegistryProvider.Autorun(Options: TAutorunOptions): Boolean;
var
  Registry: TRegistry;
begin
  Result := False;
  with Options do
    try
      if (Name = '') or (FileName = '') then Exit(False);
      Registry := TRegistry.Create;
      try
        if AllUser then
          Registry.RootKey := HKEY_LOCAL_MACHINE
        else
          Registry.RootKey := HKEY_CURRENT_USER;
        if Registry.OpenKey('\Software\Microsoft\Windows\CurrentVersion\Run', True) then begin
          Registry.WriteString(Name, ExpandUNCFileName(FileName));
          Result := Registry.ValueExists(Name);
          Registry.CloseKey;
        end;
      finally
        Registry.Free;
      end;
    except
      Result := False;
    end;
end;

function TRegistryProvider.DeleteAutorun(
  Options: TAutorunOptions): Boolean;
var
  Registry: TRegistry;
  LocalMachineFound: Boolean;
begin
  Result := False;
  LocalMachineFound := False;
  with Options do
    try
      if (Name = '') or (FileName = '') then Exit(False);
      Registry := TRegistry.Create;
      try
        Registry.RootKey := HKEY_CURRENT_USER;
        if Registry.OpenKey('\Software\Microsoft\Windows\CurrentVersion\Run', False) then begin
          if Registry.ValueExists(Name) then
            Result := Registry.DeleteValue(Name)
          else
            Result := True;
          Registry.CloseKey;
        end;
      finally
        Registry.Free;
      end;

      Registry := TRegistry.Create;
      try
        Registry.RootKey := HKEY_LOCAL_MACHINE;
        if Registry.OpenKeyReadOnly('\Software\Microsoft\Windows\CurrentVersion\Run') then
        begin
          LocalMachineFound := Registry.ValueExists(Name);
          Registry.CloseKey;
        end;
      finally
        Registry.Free;
      end;

      Registry := TRegistry.Create;
      try
        Registry.RootKey := HKEY_LOCAL_MACHINE;
        if LocalMachineFound then
        begin
          Result := Registry.OpenKey('\Software\Microsoft\Windows\CurrentVersion\Run', False);
          if Result then
          begin
            Result := Registry.DeleteValue(Name);
            Registry.CloseKey;
          end;
        end;
      finally
        Registry.Free;
      end;
    except
      Result := False;
    end;
end;

function TRegistryProvider.IsAutorun(Options: TAutorunOptions): Boolean;
var
  Registry: TRegistry;
begin
  Result := False;
  with Options do
    try
      if (Name = '') or (FileName = '') then Exit(False);
      Registry := TRegistry.Create;
      try
        Registry.RootKey := HKEY_CURRENT_USER;
        if Registry.OpenKeyReadOnly('\Software\Microsoft\Windows\CurrentVersion\Run') then begin
          if Registry.ValueExists(Name) then
            Result := CompareText(ExpandUNCFileName(Registry.ReadString(Name)), ExpandUNCFileName(FileName)) = 0;
          Registry.CloseKey;
        end;

        if not Result then begin
          Registry.RootKey := HKEY_LOCAL_MACHINE;
          if Registry.OpenKeyReadOnly('\Software\Microsoft\Windows\CurrentVersion\Run') then begin
            if Registry.ValueExists(Name) then
              Result := CompareText(ExpandUNCFileName(Registry.ReadString(Name)), ExpandUNCFileName(FileName)) = 0;
            Registry.CloseKey;
          end;
        end;
      finally
        Registry.Free;
      end;
    except
      Result := False;
    end;
end;

function TRegistryProvider.IsAvalible: Boolean;
begin
  Result := True;
end;

end.
