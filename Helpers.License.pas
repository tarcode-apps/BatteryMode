unit Helpers.License;

interface

uses
  Winapi.Windows, Winapi.Messages, Winapi.ShellAPI,
  System.SysUtils, System.Variants, System.Classes, System.IOUtils,
  Core.Language;

type
  TLicense = class
  private const
    LicResNameFormat = 'LicenseFile%0:u';
    LicFileNameFormat = '%0:s License.txt';
  public
    class procedure Open;
    class function IsLocaleSupported(LangId: LANGID): Boolean;
  strict private
    class function GetLicenseLangId: LANGID;
  end;

implementation

{ TLicense }

class procedure TLicense.Open;
var
  ResStream: TResourceStream;
  SaveStream: TFileStream;
  LicFilePath: string;
begin
  LicFilePath := TPath.Combine(TPath.GetTempPath, Format(LicFileNameFormat, [TLang[1]]));

  ResStream := TResourceStream.Create(HInstance, Format(LicResNameFormat, [GetLicenseLangId]), RT_RCDATA);
  try
    ResStream.Position := 0;
    SaveStream := TFileStream.Create(LicFilePath, fmCreate or fmOpenWrite or fmShareDenyWrite);
    try
      SaveStream.CopyFrom(ResStream, ResStream.Size);
    finally
      SaveStream.Free;
    end;
  finally
    ResStream.Free;
  end;
  ShellExecute(0, 'open', LPCTSTR(LicFilePath), nil, nil, SW_SHOWMAXIMIZED);
end;

class function TLicense.IsLocaleSupported(LangId: LANGID): Boolean;
begin
  Result := FindResource(hInstance, LPCTSTR(Format(LicResNameFormat, [LangId])), RT_RCDATA) <> 0;
end;

class function TLicense.GetLicenseLangId: LANGID;
begin
  Result := TLang.EffectiveLanguageId;
  if IsLocaleSupported(Result) then Exit;

  if TLang.Fallback.ContainsKey(Result) then
    Result := TLang.Fallback[Result];

  if IsLocaleSupported(Result) then Exit;

  Result := TLang.DefaultLang;
end;

end.
