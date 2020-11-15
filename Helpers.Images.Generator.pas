unit Helpers.Images.Generator;

interface

uses
  Winapi.Windows, Winapi.ActiveX,
  System.Classes,
  GdiPlus;

function GenerateGPBitmapFromBitmap(BitmapList: IGPImage;
  Indexes: array of Integer; LineCount: Byte; Line: Byte; const Dpi: TPoint): IGPBitmap;

function GenerateGPBitmapFromRes(ResName: string;
  Indexes: array of Integer; LineCount: Byte; Line: Byte; const Dpi: TPoint): IGPBitmap;

function HBitmapToHIcon(hBmp: HBITMAP): HICON;

implementation

function GenerateGPBitmapFromBitmap(BitmapList: IGPImage;
  Indexes: array of Integer; LineCount: Byte; Line: Byte; const Dpi: TPoint): IGPBitmap;
var
  SizeY: Cardinal;
  Graphic: IGPGraphics;
  I: Integer;
begin
  Result := nil;
  SizeY := BitmapList.Height div LineCount;

  Result := TGPBitmap.Create(Integer(SizeY), Integer(SizeY));
  Result.SetResolution(BitmapList.HorizontalResolution,
                      BitmapList.VerticalResolution);

  Graphic := TGPGraphics.Create(Result);
  for I := Low(Indexes) to High(Indexes) do
    if Indexes[I] >= 0 then begin
      Graphic.DrawImage(BitmapList, -SizeY*Indexes[i], -SizeY*Line);
    end;
  Result.SetResolution(Dpi.X, Dpi.Y);
end;

function GenerateGPBitmapFromRes(ResName: string;
  Indexes: array of Integer; LineCount: Byte; Line: Byte; const Dpi: TPoint): IGPBitmap;
var
  ResStream: TResourceStream;
  Stream: IStream;
  BitmapList: IGPImage;
begin
  Result := nil;
  ResStream := TResourceStream.Create(HInstance, ResName, RT_RCDATA);
  try
    Stream := TStreamAdapter.Create(ResStream);
    BitmapList := TGPBitmap.Create(Stream);
    Result := GenerateGPBitmapFromBitmap(BitmapList, Indexes, LineCount, Line, Dpi);
  finally
    Stream := nil;
    ResStream.Free;
  end;
end;

function HBitmapToHIcon(hBmp: HBITMAP): HICON;
var
  hbmMask: HBITMAP;
  Info: ICONINFO;
  Bmp: BITMAP;
begin
  GetObject(hBmp, SizeOf(BITMAP), @Bmp);
  hbmMask := CreateCompatibleBitmap(GetDC(0), Bmp.bmWidth, Bmp.bmHeight);

  ZeroMemory(@Info, SizeOf(Info));
  Info.fIcon    := True;
  Info.hbmColor := hBmp;
  Info.hbmMask  := hbmMask;

  Result := CreateIconIndirect(Info);
  DeleteObject(hbmMask);
end;

end.
