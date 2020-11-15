unit Core.Language.Controls;

interface

uses
  Winapi.Windows,
  System.Classes,
  Vcl.StdCtrls, Vcl.Menus,
  Core.Language,
  Core.UI.Controls;

type
  TLanguageMenuItem = class (TMenuItem)
  strict private
    FLocalization: TAvailableLocalization;
  public
    constructor Create(AOwner: TComponent; Localization: TAvailableLocalization); reintroduce;
    property Localization: TAvailableLocalization read FLocalization;
  end;

implementation

{ TLanguageMenuItem }

constructor TLanguageMenuItem.Create(AOwner: TComponent;
  Localization: TAvailableLocalization);
begin
  inherited Create(AOwner);

  FLocalization := Localization;

  AutoCheck := True;
  RadioItem := True;

  Caption := FLocalization.Value;
end;

end.
