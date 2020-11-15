unit Battery.Controls;

interface

uses
  System.Classes,
  Vcl.StdCtrls, Vcl.Controls,
  Core.UI.Controls,
  Power;

type
  TSchemeRadioButton = class (TRadioButton)
  private
    FPowerScheme: IPowerScheme;
    procedure SetPowerScheme(const Value: IPowerScheme);
  public
    constructor Create(AOwner: TComponent; Scheme: IPowerScheme); reintroduce;
    property PowerScheme: IPowerScheme read FPowerScheme write SetPowerScheme;
  end;

implementation

{ TSchemeRadioButton }

constructor TSchemeRadioButton.Create(AOwner: TComponent; Scheme: IPowerScheme);
begin
  inherited Create(AOwner);

  PowerScheme := Scheme;

  AutoSize := True;
  Align := alTop;
  AlignWithMargins := True;
  Margins.SetBounds(16, 5, 16, 2);
  WordWrap := True;
end;

procedure TSchemeRadioButton.SetPowerScheme(const Value: IPowerScheme);
begin
  FPowerScheme := Value;
  Caption := FPowerScheme.FriendlyName;
end;

end.
