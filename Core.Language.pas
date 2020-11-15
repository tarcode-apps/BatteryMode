unit Core.Language;

interface

uses
  Winapi.Windows, Winapi.MLang,
  System.SysUtils,
  System.Generics.Collections,
  Versions.Helpers;

const
  SUBLANG_POLISH_POLAND = $01;

type
  TAvailableLocalization = record
    LanguageId: LANGID;
    Value: string;
  end;
  TAvailableLocalizations = TList<TAvailableLocalization>;

  TLang = class
  strict private type
    TEnumResLangParam = class  
    public
      Index: DWORD;
      ResArray: TAvailableLocalizations;
    end;
  strict private
    class var FLanguageId: LANGID;
    class var FDefaultLang: LANGID;
    class var FFallback: TDictionary<LANGID, LANGID>;
    
    class constructor Create;

    class function EnumResLangProc(
      hModule: HMODULE;
      lpszType: LPCTSTR;
      lpszName: LPCTSTR;
      wIDLanguage: WORD;
      lParam: LONG_PTR): BOOL; stdcall; static;
    
    class procedure SetLanguageId(const Value: LANGID); static;
    class procedure SetDefaultLang(const Value: LANGID); static;
    class function GetLocaleName: string; static;
    class procedure SetLocaleName(const Value: string); static;
    class function GetLanguageName: string; static;
    class function GetValues(Index: DWORD): string; static;
    class function GetWindowsLanguageId: LANGID; static;
  protected
    class function GetStringRes(idx: DWORD; wLang: LANGID): string;
  public
    class function LanguageIdToName(LanguageId: LANGID): string;
    class function LCIDToLocaleName(ALcID: LCID; dwFlags: DWORD = LOCALE_ALLOW_NEUTRAL_NAMES): string;
    class function LocaleNameToLCID(Name: string; dwFlags: DWORD = LOCALE_ALLOW_NEUTRAL_NAMES): LCID;
    class function ResolveLocaleName(NameToResolve: string): string;

    class function GetAvailableLocalizations(Index: DWORD): TAvailableLocalizations;
    class function GetString(Index: DWORD): string; overload;
    class function GetString(Index: DWORD; LanguageId: LANGID): string; overload;
    class function ShouldAvoidBoldFonts : boolean;

    class property LanguageId: LANGID read FLanguageId write SetLanguageId;
    class property LocaleName: string read GetLocaleName write SetLocaleName;
    class property LanguageName: string read GetLanguageName;
    class property WindowsLanguageId: LANGID read GetWindowsLanguageId;
    class property DefaultLang: LANGID read FDefaultLang write SetDefaultLang;
    class property Fallback: TDictionary<LANGID, LANGID> read FFallback;
    class property Values[Index: DWORD]: string read GetValues; default;
  end;

implementation

uses
  System.Classes;

{ TLang }

class function TLang.GetString(Index: DWORD): string;
var
  Lang: LANGID;
begin
  Lang := FLanguageId;
  while True do
  begin
    try
      Exit(GetStringRes(Index, Lang));
    except
      if not Fallback.ContainsKey(Lang) then Break;
      Lang := Fallback[Lang];
    end;
  end;

  try
    Exit(GetStringRes(Index, FDefaultLang));
  except
    Exit('');
  end;
end;

class function TLang.GetString(Index: DWORD; LanguageId: LANGID): string;
begin
  try
    Result := GetStringRes(Index, LanguageId);
  except
    Result := '';
  end;
end;

class function TLang.ShouldAvoidBoldFonts;
begin
  // Japanese user asked us not to use bold fonts since it makes "kanji"
  // difficult to read.
  Result := FLanguageId = 1041;
end;

class function TLang.GetStringRes(idx: DWORD; wLang: LANGID): string;
var
  hFindRes: HRSRC;
  hLoadRes: HGLOBAL;
  nBlockID, nItemID: DWORD;
  pRes: LPVOID;
  dwSize: DWORD;
  i: DWORD;
  nLen: Word;
const
  NO_OF_STRINGS_PER_BLOCK = 16;
begin
  Result:= '';

  nBlockID:= (idx shr 4) + 1;
  nItemID:= 16 - (nBlockID shl 4 - idx);

  hFindRes:= FindResourceEx(HInstance, RT_STRING, MakeIntResource(nBlockID), wLang);
  if hFindRes = 0 then raise EResNotFound.Create('Resource not found');

  hLoadRes:= LoadResource(HInstance, hFindRes);
  if hLoadRes = 0 then raise EResNotFound.Create('Resource not load');

  pRes:= LockResource(hLoadRes);
  if pRes = nil then raise EResNotFound.Create('Resource not lock');

  try
    dwSize:= SizeofResource(HInstance, hFindRes);
    if dwSize = 0 then raise EResNotFound.Create('Zero resource size');

    for i:= 0 to NO_OF_STRINGS_PER_BLOCK - 1 do begin
      nLen:= PWORD(pRes)^;
      pRes:= LPVOID(DWORD_PTR(pRes) + SizeOf(Char));
      if pRes = nil then raise EResNotFound.Create('Resource is null');

      if nItemID = i then
      begin
        if nLen = 0 then raise EResNotFound.Create('Resource is null');
        SetString(Result, PChar(pRes), nLen);
        Exit;
      end else
        pRes:= LPVOID(DWORD_PTR(pRes) + nLen*SizeOf(Char));
    end;
  finally
    UnlockResource(hLoadRes);
  end;
end;

class function TLang.EnumResLangProc(
  hModule: HMODULE;
  lpszType: LPCTSTR;
  lpszName: LPCTSTR;
  wIDLanguage: WORD;
  lParam: LONG_PTR): BOOL; stdcall;
var
  EnumParam: TEnumResLangParam;
  AvailableLocalization: TAvailableLocalization;
begin
  EnumParam := TEnumResLangParam(lParam);
  try
    AvailableLocalization.Value := TLang.GetStringRes(EnumParam.Index, wIDLanguage);
    AvailableLocalization.LanguageId := LANGID(wIDLanguage);
    EnumParam.ResArray.Add(AvailableLocalization);  
  except
    // ignore
  end;
  Result := True;
end;

class function TLang.GetAvailableLocalizations(
  Index: DWORD): TAvailableLocalizations;
var
  nBlockID: DWORD;
  EnumParam: TEnumResLangParam;
begin
  Result:= TList<TAvailableLocalization>.Create;

  nBlockID:= (Index shr 4) + 1;
  EnumParam := TEnumResLangParam.Create;
  try
    EnumParam.Index := Index;
    EnumParam.ResArray := Result;
    EnumResourceLanguages(HInstance, RT_STRING, MakeIntResource(nBlockID), @EnumResLangProc, IntPtr(EnumParam));    
  finally
    EnumParam.Free;
  end;
end;

class function TLang.GetValues(Index: DWORD): string;
begin
  Result := GetString(Index);
end;

class procedure TLang.SetDefaultLang(const Value: LANGID);
begin
  if FDefaultLang = Value then Exit;
  FDefaultLang := Value;
end;

class function TLang.GetLanguageName: string;
begin
  Result := LanguageIdToName(FLanguageId);
end;

class function TLang.GetLocaleName: string;
begin
  Result := LCIDToLocaleName(FLanguageId);
end;

class procedure TLang.SetLocaleName(const Value: string);
begin
  FLanguageId := LocaleNameToLCID(Value);
  if FLanguageId = 0 then
    FLanguageId := WindowsLanguageId;
end;

class procedure TLang.SetLanguageId(const Value: LANGID);
begin
  if FLanguageId = Value then Exit;
  FLanguageId:= Value;
end;

class function TLang.GetWindowsLanguageId: LANGID;
begin
  Result := GetUserDefaultUILanguage;
end;

class function TLang.LanguageIdToName(LanguageId: LANGID): string;
var
  Len: DWORD;
begin
  SetLength(Result, MAX_PATH);
  Len := VerLanguageName(LanguageId, LPTSTR(Result), MAX_PATH);
  if Len > 0 then
    SetLength(Result, Len)
  else
    Result := '';
end;

class function TLang.LCIDToLocaleName(ALcID: LCID; dwFlags: DWORD): string;
var
  Lenght: Integer;
  pbstrRfc1766: WideString;
begin
  Result := '';

  if not IsWindowsVistaOrGreater then
  begin
    SetLength(pbstrRfc1766, LOCALE_NAME_MAX_LENGTH);
    if LcidToRfc1766(ALcID, LPTSTR(pbstrRfc1766), LOCALE_NAME_MAX_LENGTH) = S_OK then
    begin
      Result := WideCharToString(LPTSTR(pbstrRfc1766));
      SetLength(pbstrRfc1766, 0);
    end;
    Exit;
  end;

  if not IsWindows7OrGreater then dwFlags := 0;

  SetLength(Result, LOCALE_NAME_MAX_LENGTH);
  Lenght := Winapi.Windows.LCIDToLocaleName(ALcID, LPTSTR(Result), LOCALE_NAME_MAX_LENGTH, dwFlags);
  if Lenght > 0 then
    SetLength(Result, Lenght - 1)
  else
    Result := '';
end;

class function TLang.LocaleNameToLCID(Name: string; dwFlags: DWORD): LCID;
begin
  Result := 0;

  if IsWindows7OrGreater then
    Name := ResolveLocaleName(Name);

  if Name = '' then Exit(0);

  if not IsWindowsVistaOrGreater then
  begin
    if Rfc1766ToLcid(Result, LPTSTR(Name)) <> S_OK then
      Result := 0;
    Exit;
  end;

  if not IsWindows7OrGreater then dwFlags := 0;

  Result := Winapi.Windows.LocaleNameToLCID(LPCTSTR(Name), dwFlags);
end;

class function TLang.ResolveLocaleName(NameToResolve: string): string;
var
  Lenght: Integer;
begin
  if not IsWindows7OrGreater then Exit(NameToResolve);

  SetLength(Result, LOCALE_NAME_MAX_LENGTH);
  Lenght := Winapi.Windows.ResolveLocaleName(LPCTSTR(NameToResolve), LPTSTR(Result), LOCALE_NAME_MAX_LENGTH);
  if Lenght > 0 then
    SetLength(Result, Lenght - 1)
  else
    Result := '';
end;

class constructor TLang.Create;
begin
  FDefaultLang := MAKELANGID(LANG_ENGLISH, SUBLANG_ENGLISH_US);
  FLanguageId := WindowsLanguageId;
  FFallback := TDictionary<LANGID, LANGID>.Create;
end;

end.
