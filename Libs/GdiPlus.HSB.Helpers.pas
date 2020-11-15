unit GdiPlus.HSB.Helpers;

interface

uses
  System.Math,
  GdiPlus;

function HSVToRGB(Hue, Saturation, Brightness: Double): TGPColor;
procedure RGBToHSV(Color: TGPColor; out Hue, Saturation, Brightness: Double);

implementation

procedure RGBToHSV(Color: TGPColor; out Hue, Saturation, Brightness: Double);
var
  MinRGB, MaxRGB, Delta: Double;
begin
  MinRGB := Min(Min(Color.R, Color.G), Color.B);
  MaxRGB := Max(Max(Color.R, Color.G), Color.B);
  Delta := (MaxRGB - MinRGB);
  Brightness := maxRGB;
  if (MaxRGB <> 0.0) then
    Saturation := 255.0 * Delta / MaxRGB
  else
    Saturation := 0.0;

  if (Saturation <> 0.0) then
  begin
    if Color.R = MaxRGB then
      Hue := (Color.G - Color.B)/Delta
    else if Color.G = MaxRGB then
      Hue := 2.0 + (Color.B - Color.R)/Delta
    else if Color.B = MaxRGB then
      Hue := 4.0 + (Color.R - Color.G)/Delta
  end
  else Hue := -1.0;

  Hue := Hue*60;
  if Hue < 0.0 then Hue := Hue + 360.0;
  Hue := Hue/360.0;

  Saturation := Saturation/255;
  Brightness := Brightness/255;
end;

function HSVToRGB(Hue, Saturation, Brightness: Double): TGPColor;
var
  R, G, B: Byte;
  HueSector: Integer;
  HueFractional, BS, BSF, BSNF: Double;

  procedure CopyOutput(const RV, GV, BV: Double);
  const
    RGBmax = 255;
  begin
    R := Round(RGBmax * RV);
    G := Round(RGBmax * GV);
    B := Round(RGBmax * BV);
  end;
begin
  Assert(InRange(Hue,         0.0, 1.0));
  Assert(InRange(Saturation,  0.0, 1.0));
  Assert(InRange(Brightness,  0.0, 1.0));

  if Saturation = 0.0 then
  begin
    // achromatic (grey)
    CopyOutput(B, B, B);
    Exit(TGPColor.Create(R, G, B));
  end;
  Hue := Hue * 6.0; // sector 0 to 5
  HueSector := Floor(Hue);
  HueFractional := Hue - HueSector; // fractional part of H
  BS    := Brightness * (1.0 - Saturation);
  BSF   := Brightness * (1.0 - Saturation * HueFractional);
  BSNF  := Brightness * (1.0 - Saturation * (1.0 - HueFractional));
  case HueSector of
    0:    CopyOutput(Brightness,  BSNF,       BS);
    1:    CopyOutput(BSF,         Brightness, BS);
    2:    CopyOutput(BS,          Brightness, BSNF);
    3:    CopyOutput(BS,          BSF,        Brightness);
    4:    CopyOutput(BSNF,        BS,         Brightness);
    else  CopyOutput(Brightness,  BS,         BSF);
  end;
  Result := TGPColor.Create(R, G, B);
end;

end.
