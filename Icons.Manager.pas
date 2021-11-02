unit Icons.Manager;

interface

uses
  Winapi.Windows,
  System.SysUtils, System.Classes,
  System.Generics.Collections, System.Generics.Defaults,
  Power, Power.WinApi.PowrProf,
  Battery.Mode,
  Icon.Renderers,
  Icon.Renderers.Default, Icon.Renderers.Percent, Icon.Renderers.Simple,
  Helpers.Images.Generator,
  Versions.Helpers;

type
  TIconsManager = class
  strict private
    class function IsFlag(b: Byte; Flag: Byte): Boolean; inline; static;
  strict private
    FRenderer: IIconRenderer;
    FTextRenderer: IIconRenderer;

    FOptions: TIconsOptions;

    function GetRenderer: IIconRenderer;
    function GetTextRenderer: IIconRenderer;
    procedure OptionsChange(Sender: TObject);

    property Renderer: IIconRenderer read GetRenderer;
    property TextRenderer: IIconRenderer read GetTextRenderer;
  public
    constructor Create; reintroduce;
    destructor Destroy; override;

    function GetIcon(Dpi: Integer): HICON;
    function GetImage(Dpi: Integer): HBITMAP;
    function GetImageAsIcon(Dpi: Integer): HICON;

    property Options: TIconsOptions read FOptions;
  end;

implementation

{ TIconsManager }

class function TIconsManager.IsFlag(b, Flag: Byte): Boolean;
begin
  Result:= b and Flag = Flag;
end;

constructor TIconsManager.Create;
begin
  FOptions := TIconsOptions.Create;
  with FOptions do
  begin
    IconStyle := DefaultIconStyle;
    IconColorType := DefaultIconColorType;
    IconBehavior := DefaultIconBehavior;
    IconTheme := DefaultIconTheme;
    ExplicitMissingBattery := True;
    OnChange := OptionsChange;
  end;
end;

destructor TIconsManager.Destroy;
begin
  FOptions.Free;
end;

function TIconsManager.GetIcon(Dpi: Integer): HICON;
var
  PowerStatus: TSystemPowerStatus;
  State: TBatteryState;
  EffectiveRenderer: IIconRenderer;
begin
  if not GetSystemPowerStatus(PowerStatus) then
    ZeroMemory(@PowerStatus, SizeOf(PowerStatus));

  State := TBatteryMode.State;

  if (FOptions.IconBehavior = TIconBehavior.ibPercent) and
     State.BatteryPresent and
     (not IsFlag(PowerStatus.BatteryFlag, BATTERY_FLAG_NO_BATTERY)) and
     ((State.PowerCondition = PoAc) or (State.PowerCondition = PoDc)) then
    EffectiveRenderer := TextRenderer
  else
    EffectiveRenderer := Renderer;

  Result := EffectiveRenderer.GenerateIcon(PowerStatus, State, Dpi);
end;

function TIconsManager.GetImage(Dpi: Integer): HBITMAP;
var
  PowerStatus: TSystemPowerStatus;
begin
  if not GetSystemPowerStatus(PowerStatus) then
    ZeroMemory(@PowerStatus, SizeOf(PowerStatus));

  Result := Renderer.GenerateImage(PowerStatus, TBatteryMode.State, Dpi);
end;

function TIconsManager.GetImageAsIcon(Dpi: Integer): HICON;
var
  hBmp: HBITMAP;
begin
  hBmp := GetImage(Dpi);
  Result := HBitmapToHIcon(hBmp);
  DeleteObject(hBmp);
end;

function TIconsManager.GetRenderer: IIconRenderer;
begin
  if FRenderer <> nil then Exit(FRenderer);

  case FOptions.IconStyle of
    isWin8..isWinVista: FRenderer := TDefaultIconRenderer.Create(FOptions);
    isWin11: FRenderer := TSimpleIconRenderer.Create(FOptions);
    else raise Exception.Create('Not supported icon style');
  end;
  Result := FRenderer;
end;

function TIconsManager.GetTextRenderer: IIconRenderer;
begin
  if FTextRenderer <> nil then Exit(FTextRenderer);

  FTextRenderer := TPercentIconRenderer.Create(FOptions);
  Result := FTextRenderer;
end;

procedure TIconsManager.OptionsChange(Sender: TObject);
begin
  FRenderer := nil;
  FTextRenderer := nil;
end;

end.
