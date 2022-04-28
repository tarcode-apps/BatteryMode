unit HotKey;

interface

uses
  Winapi.Windows,
  System.SysUtils, System.Classes, System.StrUtils,
  Vcl.Menus,
  Core.Language;

type
  THotKeyIndex = Integer;

  THotKeyValue = record
  private
    function GetDisplayName: string;
  public
    fuModifiers: Word;
    uVirtKey: Word;
    constructor Create(Modifiers, VirtKey: Word); overload;
    constructor Create(ShortCut: TShortCut); overload;
    constructor Create(Text: string); overload;

    function IsEmpty: Boolean;
    function ToShortCut: TShortCut;
    function ToString: string;

    property DisplayName: string read GetDisplayName;

    class function Empty: THotKeyValue; static;

    class operator Equal(const Left, Right: THotKeyValue): Boolean;
    class operator NotEqual(const Left, Right: THotKeyValue): Boolean;
  end;

implementation

{ THotKeyPair }

constructor THotKeyValue.Create(Modifiers, VirtKey: Word);
begin
  fuModifiers := Modifiers;
  uVirtKey := VirtKey;
end;

constructor THotKeyValue.Create(ShortCut: TShortCut);
begin
  uVirtKey := ShortCut and not (scShift + scCtrl + scAlt + scCommand);

  fuModifiers := 0;
  if ShortCut and scAlt <> 0 then fuModifiers := fuModifiers or MOD_ALT;
  if ShortCut and scCtrl <> 0 then fuModifiers := fuModifiers or MOD_CONTROL;
  if ShortCut and scShift <> 0 then fuModifiers := fuModifiers or MOD_SHIFT;
  if ShortCut and scCommand <> 0 then fuModifiers := fuModifiers or MOD_WIN;
end;

constructor THotKeyValue.Create(Text: string);
begin
  if CompareText(Text, 'Alt+Pause') = 0 then
  begin
    Create(MOD_ALT, VK_PAUSE);
    Exit;
  end;

  if CompareText(Text, 'Ctrl+Scroll Lock') = 0 then
  begin
    Create(MOD_CONTROL, VK_CANCEL);
    Exit;
  end;

  if Text.ToUpper.Contains('Win+'.ToUpper) then
  begin
    Text := Text.Replace('Win+', '', [rfIgnoreCase]);
    Create(TextToShortCut(Text));
    fuModifiers := fuModifiers or MOD_WIN;
    Exit;
  end;

  Create(TextToShortCut(Text));
end;

function THotKeyValue.IsEmpty: Boolean;
begin
  Result := (fuModifiers = 0) and (uVirtKey = 0);
end;

class function THotKeyValue.Empty: THotKeyValue;
begin
  Result := THotKeyValue.Create(0, 0);
end;

class operator THotKeyValue.Equal(const Left, Right: THotKeyValue): Boolean;
begin
  Result := (Left.fuModifiers = Right.fuModifiers) and (Left.uVirtKey = Right.uVirtKey);
end;

class operator THotKeyValue.NotEqual(const Left, Right: THotKeyValue): Boolean;
begin
  Result := not (Left = Right);
end;

function THotKeyValue.ToShortCut: TShortCut;
begin
  Result := uVirtKey;

  if fuModifiers and MOD_ALT = MOD_ALT then Inc(Result, scAlt);
  if fuModifiers and MOD_CONTROL = MOD_CONTROL then Inc(Result, scCtrl);
  if fuModifiers and MOD_SHIFT = MOD_SHIFT then Inc(Result, scShift);
  if fuModifiers and MOD_WIN = MOD_WIN then Inc(Result, scCommand);
end;

function THotKeyValue.ToString: string;
var
  Parts: TArray<string>;
begin
  if IsEmpty then Exit('');
  if (fuModifiers = MOD_ALT) and (uVirtKey = VK_PAUSE) then Exit('Alt+Pause');

  if (fuModifiers and MOD_WIN) = MOD_WIN then
  begin
    Parts := ShortCutToText(ToShortCut).Split(['+']);
    if Length(Parts) = 0 then Exit('');

    Result := '';
    if fuModifiers and MOD_SHIFT = MOD_SHIFT then Result := Result + 'Shift+';
    if fuModifiers and MOD_CONTROL = MOD_CONTROL then Result := Result + 'Ctrl+';
    Result := Result + 'Win+';
    if fuModifiers and MOD_ALT = MOD_ALT then Result := Result + 'Alt+';

    Exit(Result + Parts[High(Parts)]);
  end;

  Result := ShortCutToText(ToShortCut);
end;

function THotKeyValue.GetDisplayName: string;
begin
  Result := ToString();
  if Result.IsEmpty then Exit(TLang[350]); // None

  Result := Result
    .Replace('Ctrl', TLang[360])
    .Replace('Shift', TLang[361])
    .Replace('Alt', TLang[362])
    .Replace('Win', TLang[363])
    .Replace('Esc', TLang[364])
    .Replace('Tab', TLang[365])
    .Replace('Backspace', TLang[366])
    .Replace('Enter', TLang[367])
    .Replace('Print Screen', TLang[368])
    .Replace('Caps Lock', TLang[369])
    .Replace('Scroll Lock', TLang[370])
    .Replace('Pause', TLang[371])
    .Replace('Home', TLang[372])
    .Replace('End', TLang[373])
    .Replace('Del', TLang[374])
    .Replace('Insert', TLang[375])
    .Replace('PgUp', TLang[376])
    .Replace('PgDn', TLang[377])
    .Replace('+Up', '+' + TLang[378])
    .Replace('+Down', '+' + TLang[380])
    .Replace('+Right', '+' + TLang[379])
    .Replace('+Left', '+' + TLang[381]);
end;

end.
