unit GdiPlusHelpers;

{ Delphi GDI+ Library for use with Delphi 2009 or later.
  Copyright (C) 2009 by Erik van Bilsen.
  Email: erik@bilsen.com
  Website: www.bilsen.com/gdiplus

License in plain English:

1. I don't promise that this software works. (But if you find any bugs,
   please let me know!)
2. You can use this software for whatever you want. You don't have to pay me.
3. You may not pretend that you wrote this software. If you use it in a program,
   you must acknowledge somewhere in your documentation that you've used this
   code.

In legalese:

The author makes NO WARRANTY or representation, either express or implied,
with respect to this software, its quality, accuracy, merchantability, or
fitness for a particular purpose.  This software is provided "AS IS", and you,
its user, assume the entire risk as to its quality and accuracy.

Permission is hereby granted to use, copy, modify, and distribute this
software (or portions thereof) for any purpose, without fee, subject to these
conditions:
(1) If any part of the source code for this software is distributed, then the
License.txt file must be included, with this copyright and no-warranty notice
unaltered; and any additions, deletions, or changes to the original files
must be clearly indicated in accompanying documentation.
(2) If only executable code is distributed, then the accompanying
documentation must state that "this software is based in part on the Delphi
GDI+ library by Erik van Bilsen".
(3) Permission for use of this software is granted only if the user accepts
full responsibility for any undesirable consequences; the author accepts
NO LIABILITY for damages of any kind. }

interface

uses
  Windows,
  Graphics,
  Controls,
  GdiPlus;

type
  TGPCanvasHelper = class helper for TCanvas
  public
    function ToGPGraphics: IGPGraphics;
  end;

type
  TGPGraphicControlHelper = class helper for TGraphicControl
  public
    function ToGPGraphics: IGPGraphics;
  end;

type
  TGPCustomControlHelper = class helper for TCustomControl
  public
    function ToGPGraphics: IGPGraphics;
  end;

type
  TGPBitmapHelper = class helper for Graphics.TBitmap
  public
    function ToGPBitmap: IGPBitmap;
    procedure FromGPBitmap(const GPBitmap: IGPBitmap);
  end;

implementation

{ TGPCanvasHelper }

function TGPCanvasHelper.ToGPGraphics: IGPGraphics;
begin
  Result := TGPGraphics.Create(Handle);
end;

{ TGPGraphicControlHelper }

function TGPGraphicControlHelper.ToGPGraphics: IGPGraphics;
begin
  Result := TGPGraphics.Create(Canvas.Handle);
end;

{ TGPCustomControlHelper }

function TGPCustomControlHelper.ToGPGraphics: IGPGraphics;
begin
  Result := TGPGraphics.Create(Canvas.Handle);
end;

{ TGPBitmapHelper }

procedure TGPBitmapHelper.FromGPBitmap(const GPBitmap: IGPBitmap);
begin
  Handle := GPBitmap.GetHBitmap(0);
end;

function TGPBitmapHelper.ToGPBitmap: IGPBitmap;
begin
  if (PixelFormat in [pf1Bit, pf4Bit, pf8Bit]) then
    Result := TGPBitmap.Create(Handle, Palette)
  else
    Result := TGPBitmap.Create(Handle, 0);
end;

end.
