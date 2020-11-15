unit Tray.Notify.Controls;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.Classes,
  Vcl.Graphics, Vcl.Themes,
  Core.UI.Controls,
  Versions.Helpers;

type
  TFlyOutPanelStyle = (tfpsDefault, tfpsLinkArea, tfpsHeader, tfpsBody, tfpsBrightness);
  TPanel = class(Core.UI.Controls.TPanel)
  private
    IsShellWindows7: Boolean;
    FStyle: TFlyOutPanelStyle;
    procedure SetStyle(const Value: TFlyOutPanelStyle);
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    property Style: TFlyOutPanelStyle read FStyle write SetStyle;
  end;

  TStaticText = class(Core.UI.Controls.TStaticText)
  protected
    function GetLinkStyleColor(Style: TLinkStyle): TColor; override;
  end;

implementation

{ TPanel }

constructor TPanel.Create(AOwner: TComponent);
begin
  inherited;
  IsShellWindows7 := IsWindows7OrGreater;
  FStyle := tfpsDefault;
end;

procedure TPanel.Paint;
var
  Details: TThemedElementDetails;
  DividerSize: TSize;
  DividerColor: TColor;
begin
  if not StyleServices.Enabled then begin
    inherited;
    Exit;
  end;

  case FStyle of
    tfpsDefault:
      begin
        inherited;
        Exit;
      end;
    tfpsHeader:
      begin
        Details := StyleServices.GetElementDetails(tfFlyOutWindow);
        if not StyleServices.DrawElement(Canvas.Handle, Details, Rect(0, 0, Width, Height)) then begin
          inherited;
          Exit;
        end;
      end;
    tfpsBody:
      begin
        Details := StyleServices.GetElementDetails(tfFlyOutWindow);
        if not StyleServices.DrawElement(Canvas.Handle, Details, Rect(0, 0, Width, Height)) then begin
          inherited;
          Exit;
        end;
        Details := StyleServices.GetElementDetails(tfFlyOutDivider);
        StyleServices.GetElementSize(Canvas.Handle, Details, esActual, DividerSize);
        StyleServices.DrawElement(Canvas.Handle, Details, Rect(0, 0, Width, DividerSize.cy));
      end;
    tfpsLinkArea:
      begin
        Details := StyleServices.GetElementDetails(tfFlyOutLinkArea);
        if not StyleServices.DrawElement(Canvas.Handle, Details, Rect(0, 0, Width, Height)) then begin
          inherited;
          Exit;
        end;

        if not IsShellWindows7 then begin
          Details := StyleServices.GetElementDetails(tfFlyOutDivider);
          StyleServices.GetElementSize(Canvas.Handle, Details, esActual, DividerSize);
          StyleServices.DrawElement(Canvas.Handle, Details, Rect(0, 0, Width, DividerSize.cy));
        end;
      end;
    tfpsBrightness:
      begin
        Details := StyleServices.GetElementDetails(tfFlyOutDivider);
        if StyleServices.GetElementColor(Details, ecEdgeFillColor, DividerColor) then
          ShapeColor := DividerColor;
        inherited;
      end;
  end;
end;

procedure TPanel.SetStyle(const Value: TFlyOutPanelStyle);
begin
  if not IsWindowsVistaOrGreater then Exit;

  FStyle := Value;
  Repaint;
end;

{ TStaticText }

function TStaticText.GetLinkStyleColor(Style: TLinkStyle): TColor;
var
  Details: TThemedElementDetails;
begin
  if not (IsWindowsVistaOrGreater and StyleServices.Enabled) then
    Exit(inherited GetLinkStyleColor(Style));

  case Style of
    lsHover: Details := StyleServices.GetElementDetails(tfFlyOutLinkHover);
    else Details := StyleServices.GetElementDetails(tfFlyOutLinkNormal);
  end;

  if not StyleServices.GetElementColor(Details, ecTextColor, Result) then
    Exit(inherited GetLinkStyleColor(Style));
end;

end.
