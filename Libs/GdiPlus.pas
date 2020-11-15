unit GdiPlus;

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
NO LIABILITY for damages of any kind.

Version history
===============

Version 1.2:
-Minor bug fixes
-The biggest complaint with version 1.0 was about name conflicts (for example
 between Graphics.TBitmap and GdiPlus.TBitmap). In this version, all GDI+ types
 start with a "TGP" or "IGP" prefix now to avoid these collisions (for example
 IGPBitmap and TGPBitmap). The previous type names are still available if you
 define the GDIP_ALIAS conditional define in your project, although usage of
 these names is discouraged now.

Version 1.1:
Never existed (to avoid confusion with Microsofts GDI+ version 1.1)

Version 1.0:
Initial version }

{$ALIGN 8}
{$MINENUMSIZE 4}

interface

uses
  Windows,
  Math,
  ActiveX,
  SysUtils,
  Generics.Collections;

{$IFDEF GDIP_0110}
const
  GDIPVER = $0110;

{$R GdiPlus11.res}
{$ELSE}
const
  GDIPVER = $0100;
{$ENDIF}

const
  GdiPlusDll = 'gdiplus.dll';

type
  PUInt16 = ^UInt16;
  PLangID = ^LangID;
  TColorRef = Integer;

{$REGION 'Support classes'}
type
  IGPArray<T> = interface
  ['{E80D8F50-F3E5-4E5F-8E07-FC4535EA90EA}']
    { Property access methods }
    function GetCount: Integer;
    procedure SetCount(const Value: Integer);
    function GetItem(const Index: Integer): T;
    procedure SetItem(const Index: Integer; const Value: T);
    function GetItemPtr: Pointer;

    { Methods }
    function GetEnumerator: TEnumerator<T>;

    { Properties }
    property Count: Integer read GetCount write SetCount;
    property Items[const Index: Integer]: T read GetItem write SetItem; default;
    property ItemPtr: Pointer read GetItemPtr;
  end;

type
  TGPArray<T> = class(TInterfacedObject, IGPArray<T>)
  public
    type
      TEnumerator = class(TEnumerator<T>)
      private
        FArray: TGPArray<T>;
        FIndex: Integer;
        function GetCurrent: T;
      protected
        function DoGetCurrent: T; override;
        function DoMoveNext: Boolean; override;
      public
        constructor Create(const AArray: TGPArray<T>);
        property Current: T read GetCurrent;
        function MoveNext: Boolean;
      end;
  private
    FItems: array of T;
  private
    { IGPArray<T> }
    function GetCount: Integer;
    procedure SetCount(const Value: Integer);
    function GetItem(const Index: Integer): T;
    procedure SetItem(const Index: Integer; const Value: T);
    function GetItemPtr: Pointer;
    function GetEnumerator: TEnumerator<T>;
  public
    constructor Create(const Count: Integer);
  end;

type
  IGPBuffer = interface
  ['{F252CE33-4F54-4B76-9261-2344D1BCD19C}']
    { Property access methods }
    function GetData: Pointer;
    function GetSize: Cardinal;

    { Properties }
    property Data: Pointer read GetData;
    property Size: Cardinal read GetSize;
  end;

type
  TGPBuffer = class(TInterfacedObject, IGPBuffer)
  private
    FData: Pointer;
    FSize: Cardinal;
  private
    { IRegionData }
    function GetData: Pointer;
    function GetSize: Cardinal;
  public
    constructor Create(const Data: Pointer; const Size: Cardinal);
    destructor Destroy; override;
  end;
{$ENDREGION 'Support classes'}

{$REGION 'GdiplusMem.h'}
(*****************************************************************************
 * GdiplusMem.h
 * GDI+ Private Memory Management APIs
 *****************************************************************************)

//----------------------------------------------------------------------------
// Memory Allocation APIs
//----------------------------------------------------------------------------

function GdipAlloc(Size: Integer): Pointer; stdcall; external GdiPlusDll;
procedure GdipFree(Ptr: Pointer); stdcall; external GdiPlusDll;
{$ENDREGION 'GdiplusMem.h'}

{$REGION 'GdiplusBase.h'}
(*****************************************************************************
 * GdiplusBase.h
 * GDI+ base memory allocation class
 *****************************************************************************)

type
  GpNativeHandle = Pointer;

type
  IGdiplusBase = interface
  ['{24A5D3F5-4A9B-42A2-9F60-20825E2740F5}']
    { Property access methods }
    function GetNativeHandle: GpNativeHandle;
    procedure SetNativeHandle(const Value: GpNativeHandle);

    { Properties }
    property NativeHandle: GpNativeHandle read GetNativeHandle write SetNativeHandle;
  end;

  TGdiplusBase = class(TInterfacedObject, IGdiPlusBase)
  protected
    FNativeHandle: GpNativeHandle;
  private
    { IGdiPlusBase }
    function GetNativeHandle: GpNativeHandle;
    procedure SetNativeHandle(const Value: GpNativeHandle);
  private
    constructor Create;
  public
    class function NewInstance: TObject; override;
    procedure FreeInstance; override;
  end;
{$ENDREGION 'GdiplusBase.h'}

{$REGION 'GdiplusEnums.h'}
(*****************************************************************************
 * GdiplusEnums.h
 * GDI+ Enumeration Types
 *****************************************************************************)

//--------------------------------------------------------------------------
// Default bezier flattening tolerance in device pixels.
//--------------------------------------------------------------------------

const
  FlatnessDefault = 1.0 / 4.0;

//--------------------------------------------------------------------------
// Graphics and Container State cookies
//--------------------------------------------------------------------------

type
  TGPGraphicsState = UINT;
  PGPGraphicsState = ^TGPGraphicsState;
  TGPGraphicsContainer = UINT;
  PGPGraphicsContainer = ^TGPGraphicsContainer;

//--------------------------------------------------------------------------
// Fill mode constants
//--------------------------------------------------------------------------

type
  TGPFillMode = (
    FillModeAlternate,        // 0
    FillModeWinding);         // 1

//--------------------------------------------------------------------------
// Quality mode constants
//--------------------------------------------------------------------------

type
  TGPQualityMode = (
    QualityModeInvalid   = -1,
    QualityModeDefault   = 0,
    QualityModeLow       = 1,  // Best performance
    QualityModeHigh      = 2); // Best rendering quality

//--------------------------------------------------------------------------
// Alpha Compositing mode constants
//--------------------------------------------------------------------------

type
  TGPCompositingMode = (
    CompositingModeSourceOver,    // 0
    CompositingModeSourceCopy);   // 1

//--------------------------------------------------------------------------
// Alpha Compositing quality constants
//--------------------------------------------------------------------------

type
  TGPCompositingQuality = (
    CompositingQualityInvalid          = Ord(QualityModeInvalid),
    CompositingQualityDefault          = Ord(QualityModeDefault),
    CompositingQualityHighSpeed        = Ord(QualityModeLow),
    CompositingQualityHighQuality      = Ord(QualityModeHigh),
    CompositingQualityGammaCorrected,
    CompositingQualityAssumeLinear);

//--------------------------------------------------------------------------
// Unit constants
//--------------------------------------------------------------------------

type
  TGPUnit = (
    UnitWorld,       // 0 -- World coordinate (non-physical unit)
    UnitDisplay,     // 1 -- Variable -- for PageTransform only
    UnitPixel,       // 2 -- Each unit is one device pixel.
    UnitPoint,       // 3 -- Each unit is a printer's point, or 1/72 inch.
    UnitInch,        // 4 -- Each unit is 1 inch.
    UnitDocument,    // 5 -- Each unit is 1/300 inch.
    UnitMillimeter); // 6 -- Each unit is 1 millimeter.

//--------------------------------------------------------------------------
// MetafileFrameUnit
//
// The frameRect for creating a metafile can be specified in any of these
// units.  There is an extra frame unit value (MetafileFrameUnitGdi) so
// that units can be supplied in the same units that GDI expects for
// frame rects -- these units are in .01 (1/100ths) millimeter units
// as defined by GDI.
//--------------------------------------------------------------------------

type
  TGPMetafileFrameUnit = (
    MetafileFrameUnitPixel      = Ord(UnitPixel),
    MetafileFrameUnitPoint      = Ord(UnitPoint),
    MetafileFrameUnitInch       = Ord(UnitInch),
    MetafileFrameUnitDocument   = Ord(UnitDocument),
    MetafileFrameUnitMillimeter = Ord(UnitMillimeter),
    MetafileFrameUnitGdi);  // GDI compatible .01 MM units

//--------------------------------------------------------------------------
// Coordinate space identifiers
//--------------------------------------------------------------------------

type
  TGPCoordinateSpace = (
    CoordinateSpaceWorld,     // 0
    CoordinateSpacePage,      // 1
    CoordinateSpaceDevice);   // 2

//--------------------------------------------------------------------------
// Various wrap modes for brushes
//--------------------------------------------------------------------------

type
  TGPWrapMode = (
    WrapModeTile,        // 0
    WrapModeTileFlipX,   // 1
    WrapModeTileFlipY,   // 2
    WrapModeTileFlipXY,  // 3
    WrapModeClamp);      // 4

//--------------------------------------------------------------------------
// Various hatch styles
//--------------------------------------------------------------------------

type
  TGPHatchStyle = (
    HatchStyleHorizontal,                   // 0
    HatchStyleVertical,                     // 1
    HatchStyleForwardDiagonal,              // 2
    HatchStyleBackwardDiagonal,             // 3
    HatchStyleCross,                        // 4
    HatchStyleDiagonalCross,                // 5
    HatchStyle05Percent,                    // 6
    HatchStyle10Percent,                    // 7
    HatchStyle20Percent,                    // 8
    HatchStyle25Percent,                    // 9
    HatchStyle30Percent,                    // 10
    HatchStyle40Percent,                    // 11
    HatchStyle50Percent,                    // 12
    HatchStyle60Percent,                    // 13
    HatchStyle70Percent,                    // 14
    HatchStyle75Percent,                    // 15
    HatchStyle80Percent,                    // 16
    HatchStyle90Percent,                    // 17
    HatchStyleLightDownwardDiagonal,        // 18
    HatchStyleLightUpwardDiagonal,          // 19
    HatchStyleDarkDownwardDiagonal,         // 20
    HatchStyleDarkUpwardDiagonal,           // 21
    HatchStyleWideDownwardDiagonal,         // 22
    HatchStyleWideUpwardDiagonal,           // 23
    HatchStyleLightVertical,                // 24
    HatchStyleLightHorizontal,              // 25
    HatchStyleNarrowVertical,               // 26
    HatchStyleNarrowHorizontal,             // 27
    HatchStyleDarkVertical,                 // 28
    HatchStyleDarkHorizontal,               // 29
    HatchStyleDashedDownwardDiagonal,       // 30
    HatchStyleDashedUpwardDiagonal,         // 31
    HatchStyleDashedHorizontal,             // 32
    HatchStyleDashedVertical,               // 33
    HatchStyleSmallConfetti,                // 34
    HatchStyleLargeConfetti,                // 35
    HatchStyleZigZag,                       // 36
    HatchStyleWave,                         // 37
    HatchStyleDiagonalBrick,                // 38
    HatchStyleHorizontalBrick,              // 39
    HatchStyleWeave,                        // 40
    HatchStylePlaid,                        // 41
    HatchStyleDivot,                        // 42
    HatchStyleDottedGrid,                   // 43
    HatchStyleDottedDiamond,                // 44
    HatchStyleShingle,                      // 45
    HatchStyleTrellis,                      // 46
    HatchStyleSphere,                       // 47
    HatchStyleSmallGrid,                    // 48
    HatchStyleSmallCheckerBoard,            // 49
    HatchStyleLargeCheckerBoard,            // 50
    HatchStyleOutlinedDiamond,              // 51
    HatchStyleSolidDiamond,                 // 52

    HatchStyleTotal,
    HatchStyleLargeGrid = HatchStyleCross,  // 4

    HatchStyleMin       = HatchStyleHorizontal,
    HatchStyleMax       = HatchStyleTotal - 1);

//--------------------------------------------------------------------------
// Dash style constants
//--------------------------------------------------------------------------

type
  TGPDashStyle = (
    DashStyleSolid,          // 0
    DashStyleDash,           // 1
    DashStyleDot,            // 2
    DashStyleDashDot,        // 3
    DashStyleDashDotDot,     // 4
    DashStyleCustom);        // 5

//--------------------------------------------------------------------------
// Dash cap constants
//--------------------------------------------------------------------------

type
  TGPDashCap = (
    DashCapFlat             = 0,
    DashCapRound            = 2,
    DashCapTriangle         = 3);

//--------------------------------------------------------------------------
// Line cap constants (only the lowest 8 bits are used).
//--------------------------------------------------------------------------

type
  TGPLineCap = (
    LineCapFlat             = 0,
    LineCapSquare           = 1,
    LineCapRound            = 2,
    LineCapTriangle         = 3,

    LineCapNoAnchor         = $10,  // corresponds to flat cap
    LineCapSquareAnchor     = $11,  // corresponds to square cap
    LineCapRoundAnchor      = $12,  // corresponds to round cap
    LineCapDiamondAnchor    = $13,  // corresponds to triangle cap
    LineCapArrowAnchor      = $14,  // no correspondence

    LineCapCustom           = $ff,  // custom cap

    LineCapAnchorMask       = $f0); // mask to check for anchor or not.

//--------------------------------------------------------------------------
// Custom Line cap type constants
//--------------------------------------------------------------------------

type
  TGPCustomLineCapType = (
    CustomLineCapTypeDefault         = 0,
    CustomLineCapTypeAdjustableArrow = 1);

//--------------------------------------------------------------------------
// Line join constants
//--------------------------------------------------------------------------

type
  TGPLineJoin = (
    LineJoinMiter        = 0,
    LineJoinBevel        = 1,
    LineJoinRound        = 2,
    LineJoinMiterClipped = 3);

//--------------------------------------------------------------------------
// Path point types (only the lowest 8 bits are used.)
//  The lowest 3 bits are interpreted as point type
//  The higher 5 bits are reserved for flags.
//--------------------------------------------------------------------------

type
  TGPPathPointType = (
    PathPointTypeStart           = 0,    // move
    PathPointTypeLine            = 1,    // line
    PathPointTypeBezier          = 3,    // default Bezier (= cubic Bezier)
    PathPointTypePathTypeMask    = $07, // type mask (lowest 3 bits).
    PathPointTypeDashMode        = $10, // currently in dash mode.
    PathPointTypePathMarker      = $20, // a marker for the path.
    PathPointTypeCloseSubpath    = $80, // closed flag

    // Path types used for advanced path.

    PathPointTypeBezier3         = 3);  // cubic Bezier

//--------------------------------------------------------------------------
// WarpMode constants
//--------------------------------------------------------------------------

type
  TGPWarpMode = (
    WarpModePerspective,    // 0
    WarpModeBilinear);      // 1

//--------------------------------------------------------------------------
// LineGradient Mode
//--------------------------------------------------------------------------

type
  TGPLinearGradientMode = (
    LinearGradientModeHorizontal,         // 0
    LinearGradientModeVertical,           // 1
    LinearGradientModeForwardDiagonal,    // 2
    LinearGradientModeBackwardDiagonal);  // 3

//--------------------------------------------------------------------------
// Region Comine Modes
//--------------------------------------------------------------------------

type
  TGPCombineMode = (
    CombineModeReplace,     // 0
    CombineModeIntersect,   // 1
    CombineModeUnion,       // 2
    CombineModeXor,         // 3
    CombineModeExclude,     // 4
    CombineModeComplement); // 5 (Exclude From)

//--------------------------------------------------------------------------
 // Image types
//--------------------------------------------------------------------------

type
  TGPImageType = (
    ImageTypeUnknown,   // 0
    ImageTypeBitmap,    // 1
    ImageTypeMetafile); // 2

//--------------------------------------------------------------------------
// Interpolation modes
//--------------------------------------------------------------------------

type
  TGPInterpolationMode = (
    InterpolationModeInvalid          = Ord(QualityModeInvalid),
    InterpolationModeDefault          = Ord(QualityModeDefault),
    InterpolationModeLowQuality       = Ord(QualityModeLow),
    InterpolationModeHighQuality      = Ord(QualityModeHigh),
    InterpolationModeBilinear,
    InterpolationModeBicubic,
    InterpolationModeNearestNeighbor,
    InterpolationModeHighQualityBilinear,
    InterpolationModeHighQualityBicubic);

//--------------------------------------------------------------------------
// Pen types
//--------------------------------------------------------------------------

type
  TGPPenAlignment = (
    PenAlignmentCenter       = 0,
    PenAlignmentInset        = 1);

//--------------------------------------------------------------------------
// Brush types
//--------------------------------------------------------------------------

type
  TGPBrushType = (
    BrushTypeSolidColor       = 0,
    BrushTypeHatchFill        = 1,
    BrushTypeTextureFill      = 2,
    BrushTypePathGradient     = 3,
    BrushTypeLinearGradient   = 4);

//--------------------------------------------------------------------------
// Pen's Fill types
//--------------------------------------------------------------------------

type
  TGPPenType = (
    PenTypeSolidColor       = Ord(BrushTypeSolidColor),
    PenTypeHatchFill        = Ord(BrushTypeHatchFill),
    PenTypeTextureFill      = Ord(BrushTypeTextureFill),
    PenTypePathGradient     = Ord(BrushTypePathGradient),
    PenTypeLinearGradient   = Ord(BrushTypeLinearGradient),
    PenTypeUnknown          = -1);

//--------------------------------------------------------------------------
// Matrix Order
//--------------------------------------------------------------------------

type
  TGPMatrixOrder = (
    MatrixOrderPrepend    = 0,
    MatrixOrderAppend     = 1);

//--------------------------------------------------------------------------
// Generic font families
//--------------------------------------------------------------------------

type
  TGPGenericFontFamily = (
    GenericFontFamilySerif,
    GenericFontFamilySansSerif,
    GenericFontFamilyMonospace);

//--------------------------------------------------------------------------
// FontStyle: face types and common styles
//--------------------------------------------------------------------------

type
  TGPFontStyleEntry = (
    FontStyleBold      = 0,
    FontStyleItalic    = 1,
    FontStyleUnderline = 2,
    FontStyleStrikeout = 3,
    FontStyleReserved  = 31);

  TGPFontStyle = set of TGPFontStyleEntry;

const
  FontStyleRegular = [];
  FontStyleBoldItalic = [FontStyleBold, FontStyleItalic];

//---------------------------------------------------------------------------
// Smoothing Mode
//---------------------------------------------------------------------------

type
  TGPSmoothingMode = (
    SmoothingModeInvalid     = Ord(QualityModeInvalid),
    SmoothingModeDefault     = Ord(QualityModeDefault),
    SmoothingModeHighSpeed   = Ord(QualityModeLow),
    SmoothingModeHighQuality = Ord(QualityModeHigh),
    SmoothingModeNone,
    SmoothingModeAntiAlias
    {$IF (GDIPVER >= $0110)}
    ,
    SmoothingModeAntiAlias8x4 = Ord(SmoothingModeAntiAlias),
    SmoothingModeAntiAlias8x8
    {$IFEND}
    );

//---------------------------------------------------------------------------
// Pixel Format Mode
//---------------------------------------------------------------------------

type
  TGPPixelOffsetMode = (
    PixelOffsetModeInvalid     = Ord(QualityModeInvalid),
    PixelOffsetModeDefault     = Ord(QualityModeDefault),
    PixelOffsetModeHighSpeed   = Ord(QualityModeLow),
    PixelOffsetModeHighQuality = Ord(QualityModeHigh),
    PixelOffsetModeNone,    // No pixel offset
    PixelOffsetModeHalf);   // Offset by -0.5, -0.5 for fast anti-alias perf

//---------------------------------------------------------------------------
// Text Rendering Hint
//---------------------------------------------------------------------------

type
  TGPTextRenderingHint = (
    TextRenderingHintSystemDefault = 0,            // Glyph with system default rendering hint
    TextRenderingHintSingleBitPerPixelGridFit,     // Glyph bitmap with hinting
    TextRenderingHintSingleBitPerPixel,            // Glyph bitmap without hinting
    TextRenderingHintAntiAliasGridFit,             // Glyph anti-alias bitmap with hinting
    TextRenderingHintAntiAlias,                    // Glyph anti-alias bitmap without hinting
    TextRenderingHintClearTypeGridFit);            // Glyph CT bitmap with hinting

//---------------------------------------------------------------------------
// Metafile Types
//---------------------------------------------------------------------------

type
  TGPMetafileType = (
    MetafileTypeInvalid,            // Invalid metafile
    MetafileTypeWmf,                // Standard WMF
    MetafileTypeWmfPlaceable,       // Placeable WMF
    MetafileTypeEmf,                // EMF (not EMF+)
    MetafileTypeEmfPlusOnly,        // EMF+ without dual, down-level records
    MetafileTypeEmfPlusDual);       // EMF+ with dual, down-level records

//---------------------------------------------------------------------------
// Specifies the type of EMF to record
//---------------------------------------------------------------------------

type
  TGPEmfType = (
    EmfTypeEmfOnly     = Ord(MetafileTypeEmf),          // no EMF+, only EMF
    EmfTypeEmfPlusOnly = Ord(MetafileTypeEmfPlusOnly),  // no EMF, only EMF+
    EmfTypeEmfPlusDual = Ord(MetafileTypeEmfPlusDual)); // both EMF+ and EMF

//---------------------------------------------------------------------------
// EMF+ Persistent object types
//---------------------------------------------------------------------------

type
  TGPObjectType = (
    ObjectTypeInvalid,
    ObjectTypeBrush,
    ObjectTypePen,
    ObjectTypePath,
    ObjectTypeRegion,
    ObjectTypeImage,
    ObjectTypeFont,
    ObjectTypeStringFormat,
    ObjectTypeImageAttributes,
    ObjectTypeCustomLineCap,
    {$IF (GDIPVER >= $0110)}
    ObjectTypeGraphics,

    ObjectTypeMax = ObjectTypeGraphics,
    {$ELSE}
    ObjectTypeMax = ObjectTypeCustomLineCap,
    {$IFEND}
    ObjectTypeMin = ObjectTypeBrush);

function ObjectTypeIsValid(const ObjectType: TGPObjectType): Boolean; inline;

//---------------------------------------------------------------------------
// EMF+ Records
//---------------------------------------------------------------------------

// We have to change the WMF record numbers so that they don't conflict with
// the EMF and EMF+ record numbers.

const
  GDIP_EMFPLUS_RECORD_BASE        = $00004000;
  GDIP_WMF_RECORD_BASE            = $00010000;
//  GDIP_WMF_RECORD_TO_EMFPLUS(n)   ((EmfPlusRecordType)((n) | GDIP_WMF_RECORD_BASE))
//  GDIP_EMFPLUS_RECORD_TO_WMF(n)   ((n) & (~GDIP_WMF_RECORD_BASE))
//  GDIP_IS_WMF_RECORDTYPE(n)       (((n) & GDIP_WMF_RECORD_BASE) != 0)

type
  TEmfPlusRecordType = (
    // Since we have to enumerate GDI records right along with GDI+ records,
    // We list all the GDI records here so that they can be part of the
    // same enumeration type which is used in the enumeration callback.

    WmfRecordTypeSetBkColor              = GDIP_WMF_RECORD_BASE or META_SETBKCOLOR,
    WmfRecordTypeSetBkMode               = GDIP_WMF_RECORD_BASE or META_SETBKMODE,
    WmfRecordTypeSetMapMode              = GDIP_WMF_RECORD_BASE or META_SETMAPMODE,
    WmfRecordTypeSetROP2                 = GDIP_WMF_RECORD_BASE or META_SETROP2,
    WmfRecordTypeSetRelAbs               = GDIP_WMF_RECORD_BASE or META_SETRELABS,
    WmfRecordTypeSetPolyFillMode         = GDIP_WMF_RECORD_BASE or META_SETPOLYFILLMODE,
    WmfRecordTypeSetStretchBltMode       = GDIP_WMF_RECORD_BASE or META_SETSTRETCHBLTMODE,
    WmfRecordTypeSetTextCharExtra        = GDIP_WMF_RECORD_BASE or META_SETTEXTCHAREXTRA,
    WmfRecordTypeSetTextColor            = GDIP_WMF_RECORD_BASE or META_SETTEXTCOLOR,
    WmfRecordTypeSetTextJustification    = GDIP_WMF_RECORD_BASE or META_SETTEXTJUSTIFICATION,
    WmfRecordTypeSetWindowOrg            = GDIP_WMF_RECORD_BASE or META_SETWINDOWORG,
    WmfRecordTypeSetWindowExt            = GDIP_WMF_RECORD_BASE or META_SETWINDOWEXT,
    WmfRecordTypeSetViewportOrg          = GDIP_WMF_RECORD_BASE or META_SETVIEWPORTORG,
    WmfRecordTypeSetViewportExt          = GDIP_WMF_RECORD_BASE or META_SETVIEWPORTEXT,
    WmfRecordTypeOffsetWindowOrg         = GDIP_WMF_RECORD_BASE or META_OFFSETWINDOWORG,
    WmfRecordTypeScaleWindowExt          = GDIP_WMF_RECORD_BASE or META_SCALEWINDOWEXT,
    WmfRecordTypeOffsetViewportOrg       = GDIP_WMF_RECORD_BASE or META_OFFSETVIEWPORTORG,
    WmfRecordTypeScaleViewportExt        = GDIP_WMF_RECORD_BASE or META_SCALEVIEWPORTEXT,
    WmfRecordTypeLineTo                  = GDIP_WMF_RECORD_BASE or META_LINETO,
    WmfRecordTypeMoveTo                  = GDIP_WMF_RECORD_BASE or META_MOVETO,
    WmfRecordTypeExcludeClipRect         = GDIP_WMF_RECORD_BASE or META_EXCLUDECLIPRECT,
    WmfRecordTypeIntersectClipRect       = GDIP_WMF_RECORD_BASE or META_INTERSECTCLIPRECT,
    WmfRecordTypeArc                     = GDIP_WMF_RECORD_BASE or META_ARC,
    WmfRecordTypeEllipse                 = GDIP_WMF_RECORD_BASE or META_ELLIPSE,
    WmfRecordTypeFloodFill               = GDIP_WMF_RECORD_BASE or META_FLOODFILL,
    WmfRecordTypePie                     = GDIP_WMF_RECORD_BASE or META_PIE,
    WmfRecordTypeRectangle               = GDIP_WMF_RECORD_BASE or META_RECTANGLE,
    WmfRecordTypeRoundRect               = GDIP_WMF_RECORD_BASE or META_ROUNDRECT,
    WmfRecordTypePatBlt                  = GDIP_WMF_RECORD_BASE or META_PATBLT,
    WmfRecordTypeSaveDC                  = GDIP_WMF_RECORD_BASE or META_SAVEDC,
    WmfRecordTypeSetPixel                = GDIP_WMF_RECORD_BASE or META_SETPIXEL,
    WmfRecordTypeOffsetClipRgn           = GDIP_WMF_RECORD_BASE or META_OFFSETCLIPRGN,
    WmfRecordTypeTextOut                 = GDIP_WMF_RECORD_BASE or META_TEXTOUT,
    WmfRecordTypeBitBlt                  = GDIP_WMF_RECORD_BASE or META_BITBLT,
    WmfRecordTypeStretchBlt              = GDIP_WMF_RECORD_BASE or META_STRETCHBLT,
    WmfRecordTypePolygon                 = GDIP_WMF_RECORD_BASE or META_POLYGON,
    WmfRecordTypePolyline                = GDIP_WMF_RECORD_BASE or META_POLYLINE,
    WmfRecordTypeEscape                  = GDIP_WMF_RECORD_BASE or META_ESCAPE,
    WmfRecordTypeRestoreDC               = GDIP_WMF_RECORD_BASE or META_RESTOREDC,
    WmfRecordTypeFillRegion              = GDIP_WMF_RECORD_BASE or META_FILLREGION,
    WmfRecordTypeFrameRegion             = GDIP_WMF_RECORD_BASE or META_FRAMEREGION,
    WmfRecordTypeInvertRegion            = GDIP_WMF_RECORD_BASE or META_INVERTREGION,
    WmfRecordTypePaintRegion             = GDIP_WMF_RECORD_BASE or META_PAINTREGION,
    WmfRecordTypeSelectClipRegion        = GDIP_WMF_RECORD_BASE or META_SELECTCLIPREGION,
    WmfRecordTypeSelectObject            = GDIP_WMF_RECORD_BASE or META_SELECTOBJECT,
    WmfRecordTypeSetTextAlign            = GDIP_WMF_RECORD_BASE or META_SETTEXTALIGN,
    WmfRecordTypeDrawText                = GDIP_WMF_RECORD_BASE or $062F,  // META_DRAWTEXT
    WmfRecordTypeChord                   = GDIP_WMF_RECORD_BASE or META_CHORD,
    WmfRecordTypeSetMapperFlags          = GDIP_WMF_RECORD_BASE or META_SETMAPPERFLAGS,
    WmfRecordTypeExtTextOut              = GDIP_WMF_RECORD_BASE or META_EXTTEXTOUT,
    WmfRecordTypeSetDIBToDev             = GDIP_WMF_RECORD_BASE or META_SETDIBTODEV,
    WmfRecordTypeSelectPalette           = GDIP_WMF_RECORD_BASE or META_SELECTPALETTE,
    WmfRecordTypeRealizePalette          = GDIP_WMF_RECORD_BASE or META_REALIZEPALETTE,
    WmfRecordTypeAnimatePalette          = GDIP_WMF_RECORD_BASE or META_ANIMATEPALETTE,
    WmfRecordTypeSetPalEntries           = GDIP_WMF_RECORD_BASE or META_SETPALENTRIES,
    WmfRecordTypePolyPolygon             = GDIP_WMF_RECORD_BASE or META_POLYPOLYGON,
    WmfRecordTypeResizePalette           = GDIP_WMF_RECORD_BASE or META_RESIZEPALETTE,
    WmfRecordTypeDIBBitBlt               = GDIP_WMF_RECORD_BASE or META_DIBBITBLT,
    WmfRecordTypeDIBStretchBlt           = GDIP_WMF_RECORD_BASE or META_DIBSTRETCHBLT,
    WmfRecordTypeDIBCreatePatternBrush   = GDIP_WMF_RECORD_BASE or META_DIBCREATEPATTERNBRUSH,
    WmfRecordTypeStretchDIB              = GDIP_WMF_RECORD_BASE or META_STRETCHDIB,
    WmfRecordTypeExtFloodFill            = GDIP_WMF_RECORD_BASE or META_EXTFLOODFILL,
    WmfRecordTypeSetLayout               = GDIP_WMF_RECORD_BASE or $0149,  // META_SETLAYOUT
    WmfRecordTypeResetDC                 = GDIP_WMF_RECORD_BASE or $014C,  // META_RESETDC
    WmfRecordTypeStartDoc                = GDIP_WMF_RECORD_BASE or $014D,  // META_STARTDOC
    WmfRecordTypeStartPage               = GDIP_WMF_RECORD_BASE or $004F,  // META_STARTPAGE
    WmfRecordTypeEndPage                 = GDIP_WMF_RECORD_BASE or $0050,  // META_ENDPAGE
    WmfRecordTypeAbortDoc                = GDIP_WMF_RECORD_BASE or $0052,  // META_ABORTDOC
    WmfRecordTypeEndDoc                  = GDIP_WMF_RECORD_BASE or $005E,  // META_ENDDOC
    WmfRecordTypeDeleteObject            = GDIP_WMF_RECORD_BASE or META_DELETEOBJECT,
    WmfRecordTypeCreatePalette           = GDIP_WMF_RECORD_BASE or META_CREATEPALETTE,
    WmfRecordTypeCreateBrush             = GDIP_WMF_RECORD_BASE or $00F8,  // META_CREATEBRUSH
    WmfRecordTypeCreatePatternBrush      = GDIP_WMF_RECORD_BASE or META_CREATEPATTERNBRUSH,
    WmfRecordTypeCreatePenIndirect       = GDIP_WMF_RECORD_BASE or META_CREATEPENINDIRECT,
    WmfRecordTypeCreateFontIndirect      = GDIP_WMF_RECORD_BASE or META_CREATEFONTINDIRECT,
    WmfRecordTypeCreateBrushIndirect     = GDIP_WMF_RECORD_BASE or META_CREATEBRUSHINDIRECT,
    WmfRecordTypeCreateBitmapIndirect    = GDIP_WMF_RECORD_BASE or $02FD,  // META_CREATEBITMAPINDIRECT
    WmfRecordTypeCreateBitmap            = GDIP_WMF_RECORD_BASE or $06FE,  // META_CREATEBITMAP
    WmfRecordTypeCreateRegion            = GDIP_WMF_RECORD_BASE or META_CREATEREGION,

    EmfRecordTypeHeader                  = EMR_HEADER,
    EmfRecordTypePolyBezier              = EMR_POLYBEZIER,
    EmfRecordTypePolygon                 = EMR_POLYGON,
    EmfRecordTypePolyline                = EMR_POLYLINE,
    EmfRecordTypePolyBezierTo            = EMR_POLYBEZIERTO,
    EmfRecordTypePolyLineTo              = EMR_POLYLINETO,
    EmfRecordTypePolyPolyline            = EMR_POLYPOLYLINE,
    EmfRecordTypePolyPolygon             = EMR_POLYPOLYGON,
    EmfRecordTypeSetWindowExtEx          = EMR_SETWINDOWEXTEX,
    EmfRecordTypeSetWindowOrgEx          = EMR_SETWINDOWORGEX,
    EmfRecordTypeSetViewportExtEx        = EMR_SETVIEWPORTEXTEX,
    EmfRecordTypeSetViewportOrgEx        = EMR_SETVIEWPORTORGEX,
    EmfRecordTypeSetBrushOrgEx           = EMR_SETBRUSHORGEX,
    EmfRecordTypeEOF                     = EMR_EOF,
    EmfRecordTypeSetPixelV               = EMR_SETPIXELV,
    EmfRecordTypeSetMapperFlags          = EMR_SETMAPPERFLAGS,
    EmfRecordTypeSetMapMode              = EMR_SETMAPMODE,
    EmfRecordTypeSetBkMode               = EMR_SETBKMODE,
    EmfRecordTypeSetPolyFillMode         = EMR_SETPOLYFILLMODE,
    EmfRecordTypeSetROP2                 = EMR_SETROP2,
    EmfRecordTypeSetStretchBltMode       = EMR_SETSTRETCHBLTMODE,
    EmfRecordTypeSetTextAlign            = EMR_SETTEXTALIGN,
    EmfRecordTypeSetColorAdjustment      = EMR_SETCOLORADJUSTMENT,
    EmfRecordTypeSetTextColor            = EMR_SETTEXTCOLOR,
    EmfRecordTypeSetBkColor              = EMR_SETBKCOLOR,
    EmfRecordTypeOffsetClipRgn           = EMR_OFFSETCLIPRGN,
    EmfRecordTypeMoveToEx                = EMR_MOVETOEX,
    EmfRecordTypeSetMetaRgn              = EMR_SETMETARGN,
    EmfRecordTypeExcludeClipRect         = EMR_EXCLUDECLIPRECT,
    EmfRecordTypeIntersectClipRect       = EMR_INTERSECTCLIPRECT,
    EmfRecordTypeScaleViewportExtEx      = EMR_SCALEVIEWPORTEXTEX,
    EmfRecordTypeScaleWindowExtEx        = EMR_SCALEWINDOWEXTEX,
    EmfRecordTypeSaveDC                  = EMR_SAVEDC,
    EmfRecordTypeRestoreDC               = EMR_RESTOREDC,
    EmfRecordTypeSetWorldTransform       = EMR_SETWORLDTRANSFORM,
    EmfRecordTypeModifyWorldTransform    = EMR_MODIFYWORLDTRANSFORM,
    EmfRecordTypeSelectObject            = EMR_SELECTOBJECT,
    EmfRecordTypeCreatePen               = EMR_CREATEPEN,
    EmfRecordTypeCreateBrushIndirect     = EMR_CREATEBRUSHINDIRECT,
    EmfRecordTypeDeleteObject            = EMR_DELETEOBJECT,
    EmfRecordTypeAngleArc                = EMR_ANGLEARC,
    EmfRecordTypeEllipse                 = EMR_ELLIPSE,
    EmfRecordTypeRectangle               = EMR_RECTANGLE,
    EmfRecordTypeRoundRect               = EMR_ROUNDRECT,
    EmfRecordTypeArc                     = EMR_ARC,
    EmfRecordTypeChord                   = EMR_CHORD,
    EmfRecordTypePie                     = EMR_PIE,
    EmfRecordTypeSelectPalette           = EMR_SELECTPALETTE,
    EmfRecordTypeCreatePalette           = EMR_CREATEPALETTE,
    EmfRecordTypeSetPaletteEntries       = EMR_SETPALETTEENTRIES,
    EmfRecordTypeResizePalette           = EMR_RESIZEPALETTE,
    EmfRecordTypeRealizePalette          = EMR_REALIZEPALETTE,
    EmfRecordTypeExtFloodFill            = EMR_EXTFLOODFILL,
    EmfRecordTypeLineTo                  = EMR_LINETO,
    EmfRecordTypeArcTo                   = EMR_ARCTO,
    EmfRecordTypePolyDraw                = EMR_POLYDRAW,
    EmfRecordTypeSetArcDirection         = EMR_SETARCDIRECTION,
    EmfRecordTypeSetMiterLimit           = EMR_SETMITERLIMIT,
    EmfRecordTypeBeginPath               = EMR_BEGINPATH,
    EmfRecordTypeEndPath                 = EMR_ENDPATH,
    EmfRecordTypeCloseFigure             = EMR_CLOSEFIGURE,
    EmfRecordTypeFillPath                = EMR_FILLPATH,
    EmfRecordTypeStrokeAndFillPath       = EMR_STROKEANDFILLPATH,
    EmfRecordTypeStrokePath              = EMR_STROKEPATH,
    EmfRecordTypeFlattenPath             = EMR_FLATTENPATH,
    EmfRecordTypeWidenPath               = EMR_WIDENPATH,
    EmfRecordTypeSelectClipPath          = EMR_SELECTCLIPPATH,
    EmfRecordTypeAbortPath               = EMR_ABORTPATH,
    EmfRecordTypeReserved_069            = 69,  // Not Used
    EmfRecordTypeGdiComment              = EMR_GDICOMMENT,
    EmfRecordTypeFillRgn                 = EMR_FILLRGN,
    EmfRecordTypeFrameRgn                = EMR_FRAMERGN,
    EmfRecordTypeInvertRgn               = EMR_INVERTRGN,
    EmfRecordTypePaintRgn                = EMR_PAINTRGN,
    EmfRecordTypeExtSelectClipRgn        = EMR_EXTSELECTCLIPRGN,
    EmfRecordTypeBitBlt                  = EMR_BITBLT,
    EmfRecordTypeStretchBlt              = EMR_STRETCHBLT,
    EmfRecordTypeMaskBlt                 = EMR_MASKBLT,
    EmfRecordTypePlgBlt                  = EMR_PLGBLT,
    EmfRecordTypeSetDIBitsToDevice       = EMR_SETDIBITSTODEVICE,
    EmfRecordTypeStretchDIBits           = EMR_STRETCHDIBITS,
    EmfRecordTypeExtCreateFontIndirect   = EMR_EXTCREATEFONTINDIRECTW,
    EmfRecordTypeExtTextOutA             = EMR_EXTTEXTOUTA,
    EmfRecordTypeExtTextOutW             = EMR_EXTTEXTOUTW,
    EmfRecordTypePolyBezier16            = EMR_POLYBEZIER16,
    EmfRecordTypePolygon16               = EMR_POLYGON16,
    EmfRecordTypePolyline16              = EMR_POLYLINE16,
    EmfRecordTypePolyBezierTo16          = EMR_POLYBEZIERTO16,
    EmfRecordTypePolylineTo16            = EMR_POLYLINETO16,
    EmfRecordTypePolyPolyline16          = EMR_POLYPOLYLINE16,
    EmfRecordTypePolyPolygon16           = EMR_POLYPOLYGON16,
    EmfRecordTypePolyDraw16              = EMR_POLYDRAW16,
    EmfRecordTypeCreateMonoBrush         = EMR_CREATEMONOBRUSH,
    EmfRecordTypeCreateDIBPatternBrushPt = EMR_CREATEDIBPATTERNBRUSHPT,
    EmfRecordTypeExtCreatePen            = EMR_EXTCREATEPEN,
    EmfRecordTypePolyTextOutA            = EMR_POLYTEXTOUTA,
    EmfRecordTypePolyTextOutW            = EMR_POLYTEXTOUTW,
    EmfRecordTypeSetICMMode              = 98,  // EMR_SETICMMODE,
    EmfRecordTypeCreateColorSpace        = 99,  // EMR_CREATECOLORSPACE,
    EmfRecordTypeSetColorSpace           = 100, // EMR_SETCOLORSPACE,
    EmfRecordTypeDeleteColorSpace        = 101, // EMR_DELETECOLORSPACE,
    EmfRecordTypeGLSRecord               = 102, // EMR_GLSRECORD,
    EmfRecordTypeGLSBoundedRecord        = 103, // EMR_GLSBOUNDEDRECORD,
    EmfRecordTypePixelFormat             = 104, // EMR_PIXELFORMAT,
    EmfRecordTypeDrawEscape              = 105, // EMR_RESERVED_105,
    EmfRecordTypeExtEscape               = 106, // EMR_RESERVED_106,
    EmfRecordTypeStartDoc                = 107, // EMR_RESERVED_107,
    EmfRecordTypeSmallTextOut            = 108, // EMR_RESERVED_108,
    EmfRecordTypeForceUFIMapping         = 109, // EMR_RESERVED_109,
    EmfRecordTypeNamedEscape             = 110, // EMR_RESERVED_110,
    EmfRecordTypeColorCorrectPalette     = 111, // EMR_COLORCORRECTPALETTE,
    EmfRecordTypeSetICMProfileA          = 112, // EMR_SETICMPROFILEA,
    EmfRecordTypeSetICMProfileW          = 113, // EMR_SETICMPROFILEW,
    EmfRecordTypeAlphaBlend              = 114, // EMR_ALPHABLEND,
    EmfRecordTypeSetLayout               = 115, // EMR_SETLAYOUT,
    EmfRecordTypeTransparentBlt          = 116, // EMR_TRANSPARENTBLT,
    EmfRecordTypeReserved_117            = 117, // Not Used
    EmfRecordTypeGradientFill            = 118, // EMR_GRADIENTFILL,
    EmfRecordTypeSetLinkedUFIs           = 119, // EMR_RESERVED_119,
    EmfRecordTypeSetTextJustification    = 120, // EMR_RESERVED_120,
    EmfRecordTypeColorMatchToTargetW     = 121, // EMR_COLORMATCHTOTARGETW,
    EmfRecordTypeCreateColorSpaceW       = 122, // EMR_CREATECOLORSPACEW,
    EmfRecordTypeMax                     = 122,
    EmfRecordTypeMin                     = 1,

    // That is the END of the GDI EMF records.

    // Now we start the list of EMF+ records.  We leave quite
    // a bit of room here for the addition of any new GDI
    // records that may be added later.

    EmfPlusRecordTypeInvalid = GDIP_EMFPLUS_RECORD_BASE,
    EmfPlusRecordTypeHeader,
    EmfPlusRecordTypeEndOfFile,

    EmfPlusRecordTypeComment,

    EmfPlusRecordTypeGetDC,

    EmfPlusRecordTypeMultiFormatStart,
    EmfPlusRecordTypeMultiFormatSection,
    EmfPlusRecordTypeMultiFormatEnd,

    // For all persistent objects

    EmfPlusRecordTypeObject,

    // Drawing Records

    EmfPlusRecordTypeClear,
    EmfPlusRecordTypeFillRects,
    EmfPlusRecordTypeDrawRects,
    EmfPlusRecordTypeFillPolygon,
    EmfPlusRecordTypeDrawLines,
    EmfPlusRecordTypeFillEllipse,
    EmfPlusRecordTypeDrawEllipse,
    EmfPlusRecordTypeFillPie,
    EmfPlusRecordTypeDrawPie,
    EmfPlusRecordTypeDrawArc,
    EmfPlusRecordTypeFillRegion,
    EmfPlusRecordTypeFillPath,
    EmfPlusRecordTypeDrawPath,
    EmfPlusRecordTypeFillClosedCurve,
    EmfPlusRecordTypeDrawClosedCurve,
    EmfPlusRecordTypeDrawCurve,
    EmfPlusRecordTypeDrawBeziers,
    EmfPlusRecordTypeDrawImage,
    EmfPlusRecordTypeDrawImagePoints,
    EmfPlusRecordTypeDrawString,

    // Graphics State Records

    EmfPlusRecordTypeSetRenderingOrigin,
    EmfPlusRecordTypeSetAntiAliasMode,
    EmfPlusRecordTypeSetTextRenderingHint,
    EmfPlusRecordTypeSetTextContrast,
    EmfPlusRecordTypeSetInterpolationMode,
    EmfPlusRecordTypeSetPixelOffsetMode,
    EmfPlusRecordTypeSetCompositingMode,
    EmfPlusRecordTypeSetCompositingQuality,
    EmfPlusRecordTypeSave,
    EmfPlusRecordTypeRestore,
    EmfPlusRecordTypeBeginContainer,
    EmfPlusRecordTypeBeginContainerNoParams,
    EmfPlusRecordTypeEndContainer,
    EmfPlusRecordTypeSetWorldTransform,
    EmfPlusRecordTypeResetWorldTransform,
    EmfPlusRecordTypeMultiplyWorldTransform,
    EmfPlusRecordTypeTranslateWorldTransform,
    EmfPlusRecordTypeScaleWorldTransform,
    EmfPlusRecordTypeRotateWorldTransform,
    EmfPlusRecordTypeSetPageTransform,
    EmfPlusRecordTypeResetClip,
    EmfPlusRecordTypeSetClipRect,
    EmfPlusRecordTypeSetClipPath,
    EmfPlusRecordTypeSetClipRegion,
    EmfPlusRecordTypeOffsetClip,

    EmfPlusRecordTypeDrawDriverString,
    {$IF (GDIPVER >= $0110)}
    EmfPlusRecordTypeStrokeFillPath,
    EmfPlusRecordTypeSerializableObject,

    EmfPlusRecordTypeSetTSGraphics,
    EmfPlusRecordTypeSetTSClip,
    {$IFEND}
    // NOTE: New records *must* be added immediately before this line.

    EmfPlusRecordTotal,

    EmfPlusRecordTypeMax = EmfPlusRecordTotal-1,
    EmfPlusRecordTypeMin = EmfPlusRecordTypeHeader);

//---------------------------------------------------------------------------
// StringFormatFlags
//---------------------------------------------------------------------------

//---------------------------------------------------------------------------
// String format flags
//
//  DirectionRightToLeft          - For horizontal text, the reading order is
//                                  right to left. This value is called
//                                  the base embedding level by the Unicode
//                                  bidirectional engine.
//                                  For vertical text, columns are read from
//                                  right to left.
//                                  By default, horizontal or vertical text is
//                                  read from left to right.
//
//  DirectionVertical             - Individual lines of text are vertical. In
//                                  each line, characters progress from top to
//                                  bottom.
//                                  By default, lines of text are horizontal,
//                                  each new line below the previous line.
//
//  NoFitBlackBox                 - Allows parts of glyphs to overhang the
//                                  bounding rectangle.
//                                  By default glyphs are first aligned
//                                  inside the margines, then any glyphs which
//                                  still overhang the bounding box are
//                                  repositioned to avoid any overhang.
//                                  For example when an italic
//                                  lower case letter f in a font such as
//                                  Garamond is aligned at the far left of a
//                                  rectangle, the lower part of the f will
//                                  reach slightly further left than the left
//                                  edge of the rectangle. Setting this flag
//                                  will ensure the character aligns visually
//                                  with the lines above and below, but may
//                                  cause some pixels outside the formatting
//                                  rectangle to be clipped or painted.
//
//  DisplayFormatControl          - Causes control characters such as the
//                                  left-to-right mark to be shown in the
//                                  output with a representative glyph.
//
//  NoFontFallback                - Disables fallback to alternate fonts for
//                                  characters not supported in the requested
//                                  font. Any missing characters will be
//                                  be displayed with the fonts missing glyph,
//                                  usually an open square.
//
//  NoWrap                        - Disables wrapping of text between lines
//                                  when formatting within a rectangle.
//                                  NoWrap is implied when a point is passed
//                                  instead of a rectangle, or when the
//                                  specified rectangle has a zero line length.
//
//  NoClip                        - By default text is clipped to the
//                                  formatting rectangle. Setting NoClip
//                                  allows overhanging pixels to affect the
//                                  device outside the formatting rectangle.
//                                  Pixels at the end of the line may be
//                                  affected if the glyphs overhang their
//                                  cells, and either the NoFitBlackBox flag
//                                  has been set, or the glyph extends to far
//                                  to be fitted.
//                                  Pixels above/before the first line or
//                                  below/after the last line may be affected
//                                  if the glyphs extend beyond their cell
//                                  ascent / descent. This can occur rarely
//                                  with unusual diacritic mark combinations.

//---------------------------------------------------------------------------

type
  TGPStringFormatFlag = (
    StringFormatFlagsDirectionRightToLeft  = 0,
    StringFormatFlagsDirectionVertical     = 1,
    StringFormatFlagsNoFitBlackBox         = 2,
    StringFormatFlagsDisplayFormatControl  = 5,
    StringFormatFlagsNoFontFallback        = 10,
    StringFormatFlagsMeasureTrailingSpaces = 11,
    StringFormatFlagsNoWrap                = 12,
    StringFormatFlagsLineLimit             = 13,

    StringFormatFlagsNoClip                = 14,
    StringFormatFlagsBypassGDI             = 31);
  TGPStringFormatFlags = set of TGPStringFormatFlag;

//---------------------------------------------------------------------------
// StringTrimming
//---------------------------------------------------------------------------

type
  TGPStringTrimming = (
    StringTrimmingNone              = 0,
    StringTrimmingCharacter         = 1,
    StringTrimmingWord              = 2,
    StringTrimmingEllipsisCharacter = 3,
    StringTrimmingEllipsisWord      = 4,
    StringTrimmingEllipsisPath      = 5);

//---------------------------------------------------------------------------
// National language digit substitution
//---------------------------------------------------------------------------

type
  TGPStringDigitSubstitute = (
    StringDigitSubstituteUser        = 0,  // As NLS setting
    StringDigitSubstituteNone        = 1,
    StringDigitSubstituteNational    = 2,
    StringDigitSubstituteTraditional = 3);
  PGPStringDigitSubstitute = ^TGPStringDigitSubstitute;

//---------------------------------------------------------------------------
// Hotkey prefix interpretation
//---------------------------------------------------------------------------

type
  TGPHotkeyPrefix = (
    HotkeyPrefixNone        = 0,
    HotkeyPrefixShow        = 1,
    HotkeyPrefixHide        = 2);

//---------------------------------------------------------------------------
// String alignment flags
//---------------------------------------------------------------------------

type
  TGPStringAlignment = (
    // Left edge for left-to-right text,
    // right for right-to-left text,
    // and top for vertical
    StringAlignmentNear   = 0,
    StringAlignmentCenter = 1,
    StringAlignmentFar    = 2);

//---------------------------------------------------------------------------
// DriverStringOptions
//---------------------------------------------------------------------------

type
  TGPDriverStringOption = (
    DriverStringOptionsCmapLookup             = 0,
    DriverStringOptionsVertical               = 1,
    DriverStringOptionsRealizedAdvance        = 2,
    DriverStringOptionsLimitSubpixel          = 3,
    DriverStringOptionsReserved               = 31);
  TGPDriverStringOptions = set of TGPDriverStringOption;

//---------------------------------------------------------------------------
// Flush Intention flags
//---------------------------------------------------------------------------

type
  TGPFlushIntention = (
    FlushIntentionFlush = 0,        // Flush all batched rendering operations
    FlushIntentionSync = 1);        // Flush all batched rendering operations
                                    // and wait for them to complete

//---------------------------------------------------------------------------
// Image encoder parameter related types
//---------------------------------------------------------------------------

type
  TGPEncoderParameterValueType = (
    EncoderParameterValueTypeByte           = 1,    // 8-bit unsigned int
    EncoderParameterValueTypeASCII          = 2,    // 8-bit byte containing one 7-bit ASCII
                                                    // code. NULL terminated.
    EncoderParameterValueTypeShort          = 3,    // 16-bit unsigned int
    EncoderParameterValueTypeLong           = 4,    // 32-bit unsigned int
    EncoderParameterValueTypeRational       = 5,    // Two Longs. The first Long is the
                                                    // numerator, the second Long expresses the
                                                    // denomintor.
    EncoderParameterValueTypeLongRange      = 6,    // Two longs which specify a range of
                                                    // integer values. The first Long specifies
                                                    // the lower end and the second one
                                                    // specifies the higher end. All values
                                                    // are inclusive at both ends
    EncoderParameterValueTypeUndefined      = 7,    // 8-bit byte that can take any value
                                                    // depending on field definition
    EncoderParameterValueTypeRationalRange  = 8     // Two Rationals. The first Rational
                                                    // specifies the lower end and the second
                                                    // specifies the higher end. All values
                                                    // are inclusive at both ends
    {$IF (GDIPVER >= $0110)}
    ,
    EncoderParameterValueTypePointer        = 9     // a pointer to a parameter defined data.
    {$IFEND}
    );

//---------------------------------------------------------------------------
// Image encoder value types
//---------------------------------------------------------------------------

type
  TGPEncoderValue = (
    EncoderValueColorTypeCMYK,
    EncoderValueColorTypeYCCK,
    EncoderValueCompressionLZW,
    EncoderValueCompressionCCITT3,
    EncoderValueCompressionCCITT4,
    EncoderValueCompressionRle,
    EncoderValueCompressionNone,
    EncoderValueScanMethodInterlaced,
    EncoderValueScanMethodNonInterlaced,
    EncoderValueVersionGif87,
    EncoderValueVersionGif89,
    EncoderValueRenderProgressive,
    EncoderValueRenderNonProgressive,
    EncoderValueTransformRotate90,
    EncoderValueTransformRotate180,
    EncoderValueTransformRotate270,
    EncoderValueTransformFlipHorizontal,
    EncoderValueTransformFlipVertical,
    EncoderValueMultiFrame,
    EncoderValueLastFrame,
    EncoderValueFlush,
    EncoderValueFrameDimensionTime,
    EncoderValueFrameDimensionResolution,
    EncoderValueFrameDimensionPage
    {$IF (GDIPVER >= $0110)}
    ,
    EncoderValueColorTypeGray,
    EncoderValueColorTypeRGB
    {$IFEND}
    );

//---------------------------------------------------------------------------
// Conversion of Emf To WMF Bits flags
//---------------------------------------------------------------------------

type
  TGPEmfToWmfBitsFlag = (
    EmfToWmfBitsFlagsEmbedEmf         = 0,
    EmfToWmfBitsFlagsIncludePlaceable = 1,
    EmfToWmfBitsFlagsNoXORClip        = 2,
    EmfToWmfBitsFlagsReserved         = 31);
  TGPEmfToWmfBitsFlags = set of TGPEmfToWmfBitsFlag;

const
  EmfToWmfBitsFlagsDefault = [];

{$IF (GDIPVER >= $0110)}
//---------------------------------------------------------------------------
// Conversion of Emf To Emf+ Bits flags
//---------------------------------------------------------------------------

type
  TGPConvertToEmfPlusFlags = (
    ConvertToEmfPlusFlagsRopUsed       = 0,
    ConvertToEmfPlusFlagsText          = 1,
    ConvertToEmfPlusFlagsInvalidRecord = 2);

const
  ConvertToEmfPlusFlagsDefault = [];
{$IFEND}

//---------------------------------------------------------------------------
// Test Control flags
//---------------------------------------------------------------------------

type
  TGPTestControlEnum = (
    TestControlForceBilinear = 0,
    TestControlNoICM = 1,
    TestControlGetBuildNumber = 2);

{$ENDREGION 'GdiplusEnums.h' }

{$REGION 'GdiplusTypes.h'}
(*****************************************************************************
 * GdiplusTypes.h
 * GDI+ Types
 *****************************************************************************)

//--------------------------------------------------------------------------
// Callback functions
//--------------------------------------------------------------------------

type
  TGPImageAbort = function(CallbackData: Pointer): BOOL; stdcall;
  TGPDrawImageAbort = TGPImageAbort;
  TGPGetThumbnailImageAbort = TGPImageAbort;

// Callback for EnumerateMetafile methods.  The parameters are:

//      recordType      WMF, EMF, or EMF+ record type
//      flags           (always 0 for WMF/EMF records)
//      dataSize        size of the record data (in bytes), or 0 if no data
//      data            pointer to the record data, or NULL if no data
//      callbackData    pointer to callbackData, if any

// This method can then call Metafile::PlayRecord to play the
// record that was just enumerated.  If this method  returns
// FALSE, the enumeration process is aborted.  Otherwise, it continues.

type
  TGPEnumerateMetafileProc= function (RecordType: TEmfPlusRecordType;
    Flags, DataSize: UINT; Data: PByte; CallbackData: Pointer): BOOL; stdcall;

{$IF (GDIPVER >= $0110)}
// This is the main GDI+ Abort interface

type
  TGdiplusAbort = record
    Abort: function: HRESULT of object;
  end;
  PGdiplusAbort = ^TGdiplusAbort;
{$IFEND}

//--------------------------------------------------------------------------
// Primitive data types
//
// NOTE:
//  Types already defined in standard header files:
//      INT8
//      UINT8
//      INT16
//      UINT16
//      INT32
//      UINT32
//      INT64
//      UINT64
//
//  Avoid using the following types:
//      LONG - use INT
//      ULONG - use UINT
//      DWORD - use UINT32
//--------------------------------------------------------------------------

const
  REAL_MAX       = MaxSingle;
  REAL_MIN       = MinSingle;
  REAL_TOLERANCE = (MinSingle * 100);
  REAL_EPSILON   = 1.192092896e-07; // FLT_EPSILON

//--------------------------------------------------------------------------
// Status return values from GDI+ methods
//--------------------------------------------------------------------------

type
  TGPStatus = (
    Ok = 0,
    GenericError = 1,
    InvalidParameter = 2,
    OutOfMemory = 3,
    ObjectBusy = 4,
    InsufficientBuffer = 5,
    NotImplemented = 6,
    Win32Error = 7,
    WrongState = 8,
    Aborted = 9,
    FileNotFound = 10,
    ValueOverflow = 11,
    AccessDenied = 12,
    UnknownImageFormat = 13,
    FontFamilyNotFound = 14,
    FontStyleNotFound = 15,
    NotTrueTypeFont = 16,
    UnsupportedGdiplusVersion = 17,
    GdiplusNotInitialized = 18,
    PropertyNotFound = 19,
    PropertyNotSupported = 20
    {$IF (GDIPVER >= $0110)}
    ,
    ProfileNotFound = 21
    {$IFEND}
    );

//--------------------------------------------------------------------------
// Represents a dimension in a 2D coordinate system (floating-point coordinates)
//--------------------------------------------------------------------------

type
  TGPSizeF = record
  public
    Width: Single;
    Height: Single;
  public
    procedure Initialize; overload;
    procedure Initialize(const Size: TGPSizeF); overload;
    procedure Initialize(const AWidth, AHeight: Single); overload;
    class function Create(const Size: TGPSizeF): TGPSizeF; overload; static;
    class function Create(const AWidth, AHeight: Single): TGPSizeF; overload; static;
    class operator Add(const A, B: TGPSizeF): TGPSizeF;
    class operator Subtract(const A, B: TGPSizeF): TGPSizeF;
    function Empty: Boolean;
    function Equals(const Size: TGPSizeF): Boolean;
  end;
  PGPSizeF = ^TGPSizeF;

//--------------------------------------------------------------------------
// Represents a dimension in a 2D coordinate system (integer coordinates)
//--------------------------------------------------------------------------

type
  TGPSize = record
  public
    Width: Integer;
    Height: Integer;
  public
    procedure Initialize; overload;
    procedure Initialize(const Size: TGPSize); overload;
    procedure Initialize(const AWidth, AHeight: Integer); overload;
    class function Create(const Size: TGPSize): TGPSize; overload; static;
    class function Create(const AWidth, AHeight: Integer): TGPSize; overload; static;
    class operator Add(const A, B: TGPSize): TGPSize;
    class operator Subtract(const A, B: TGPSize): TGPSize;
    function Empty: Boolean;
    function Equals(const Size: TGPSize): Boolean;
  end;
  PGPSize = ^TGPSize;

//--------------------------------------------------------------------------
// Represents a location in a 2D coordinate system (floating-point coordinates)
//--------------------------------------------------------------------------

type
  TGPPointF = record
  public
    X: Single;
    Y: Single;
  public
    procedure Initialize; overload;
    procedure Initialize(const Point: TGPPointF); overload;
    procedure Initialize(const Size: TGPSizeF); overload;
    procedure Initialize(const AX, AY: Single); overload;
    class function Create(const Point: TGPPointF): TGPPointF; overload; static;
    class function Create(const Size: TGPSizeF): TGPPointF; overload; static;
    class function Create(const AX, AY: Single): TGPPointF; overload; static;
    class operator Add(const A, B: TGPPointF): TGPPointF;
    class operator Subtract(const A, B: TGPPointF): TGPPointF;
    function Equals(const Point: TGPPointF): Boolean;
  end;
  PGPPointF = ^TGPPointF;

//--------------------------------------------------------------------------
// Represents a location in a 2D coordinate system (integer coordinates)
//--------------------------------------------------------------------------

type
  TGPPoint = record
  public
    X: Integer;
    Y: Integer;
  public
    procedure Initialize; overload;
    procedure Initialize(const Point: TGPPoint); overload;
    procedure Initialize(const Size: TGPSize); overload;
    procedure Initialize(const AX, AY: Integer); overload;
    class function Create(const Point: TGPPoint): TGPPoint; overload; static;
    class function Create(const Size: TGPSize): TGPPoint; overload; static;
    class function Create(const AX, AY: Integer): TGPPoint; overload; static;
    class operator Add(const A, B: TGPPoint): TGPPoint;
    class operator Subtract(const A, B: TGPPoint): TGPPoint;
    function Equals(const Point: TGPPoint): Boolean;
  end;
  PGPPoint = ^TGPPoint;

//--------------------------------------------------------------------------
// Represents a rectangle in a 2D coordinate system (floating-point coordinates)
//--------------------------------------------------------------------------

type
  PGPRectF = ^TGPRectF;
  TGPRectF = record
  public
    X: Single;
    Y: Single;
    Width: Single;
    Height: Single;
  private
    function GetLocation: TGPPointF;
    function GetSize: TGPSizeF;
    function GetBounds: TGPRectF;
    function GetRight: Single;
    function GetBottom: Single;
  public
    procedure Initialize; overload;
    procedure Initialize(const AX, AY, AWidth, AHeight: Single); overload;
    procedure Initialize(const Location: TGPPointF; const Size: TGPSizeF); overload;
    procedure InitializeFromLTRB(const Left, Top, Right, Bottom: Single);
    class function Create(const AX, AY, AWidth, AHeight: Single): TGPRectF; overload; static;
    class function Create(const Location: TGPPointF; const Size: TGPSizeF): TGPRectF; overload; static;
    function Clone: TGPRectF;
    function IsEmptyArea: Boolean;
    function Equals(const Rect: TGPRectF): Boolean;
    function Contains(const AX, AY: Single): Boolean; overload;
    function Contains(const Point: TGPPointF): Boolean; overload;
    function Contains(const Rect: TGPRectF): Boolean; overload;
    procedure Inflate(const DX, DY: Single); overload;
    procedure Inflate(const DXY: Single); overload;
    procedure Inflate(const Point: TGPPointF); overload;
    function Intersect(const Rect: TGPRectF): Boolean; overload;
    class function Intersect(out C: TGPRectF; const A, B: TGPRectF): Boolean; overload; static;
    function IntersectsWith(const Rect: TGPRectF): Boolean;
    function Union(const Rect: TGPRectF): Boolean; overload;
    class function Union(out C: TGPRectF; const A, B: TGPRectF): Boolean; overload; static;
    procedure Offset(const Point: TGPPointF); overload;
    procedure Offset(const DX, DY: Single); overload;

    property Location: TGPPointF read GetLocation;
    property Size: TGPSizeF read GetSize;
    property Bounds: TGPRectF read GetBounds;
    property Left: Single read X;
    property Top: Single read Y;
    property Right: Single read GetRight;
    property Bottom: Single read GetBottom;
  end;

//--------------------------------------------------------------------------
// Represents a rectangle in a 2D coordinate system (integer coordinates)
//--------------------------------------------------------------------------

type
  PGPRect = ^TGPRect;
  TGPRect = record
  public
    X: Integer;
    Y: Integer;
    Width: Integer;
    Height: Integer;
  private
    function GetLocation: TGPPoint;
    function GetSize: TGPSize;
    function GetBounds: TGPRect;
    function GetRight: Integer;
    function GetBottom: Integer;
  public
    procedure Initialize; overload;
    procedure Initialize(const AX, AY, AWidth, AHeight: Integer); overload;
    procedure Initialize(const Location: TGPPoint; const Size: TGPSize); overload;
    procedure Initialize(const Rect: Windows.TRect); overload;
    procedure InitializeFromLTRB(const Left, Top, Right, Bottom: Integer);
    class function Create(const AX, AY, AWidth, AHeight: Integer): TGPRect; overload; static;
    class function Create(const Location: TGPPoint; const Size: TGPSize): TGPRect; overload; static;
    class function Create(const Rect: Windows.TRect): TGPRect; overload; static;
    function Clone: TGPRect;
    function IsEmptyArea: Boolean;
    function Equals(const Rect: TGPRect): Boolean;
    function Contains(const AX, AY: Integer): Boolean; overload;
    function Contains(const Point: TGPPoint): Boolean; overload;
    function Contains(const Rect: TGPRect): Boolean; overload;
    procedure Inflate(const DX, DY: Integer); overload;
    procedure Inflate(const Point: TGPPoint); overload;
    function Intersect(const Rect: TGPRect): Boolean; overload;
    class function Intersect(out C: TGPRect; const A, B: TGPRect): Boolean; overload; static;
    function IntersectsWith(const Rect: TGPRect): Boolean;
    function Union(const Rect: TGPRect): Boolean; overload;
    class function Union(out C: TGPRect; const A, B: TGPRect): Boolean; overload; static;
    procedure Offset(const Point: TGPPoint); overload;
    procedure Offset(const DX, DY: Integer); overload;

    property Location: TGPPoint read GetLocation;
    property Size: TGPSize read GetSize;
    property Bounds: TGPRect read GetBounds;
    property Left: Integer read X;
    property Top: Integer read Y;
    property Right: Integer read GetRight;
    property Bottom: Integer read GetBottom;
  end;

type
  TGPNativePathData = record
    Count: Integer;
    Points: PGPPointF;
    Types: PByte;
  end;
  PGPNativePathData = ^TGPNativePathData;

type
  TGPCharacterRange = record
  public
    First: Integer;
    Length: Integer;
  public
    procedure Initialize; overload;
    procedure Initialize(const AFirst, ALength: Integer); overload;
  end;
  PGPCharacterRange = ^TGPCharacterRange;

{$ENDREGION 'GdiplusTypes.h'}

{$REGION 'GdiplusInit.h'}
(*****************************************************************************
 * GdiplusInit.h
 * GDI+ Startup and Shutdown APIs
 *****************************************************************************)

type
  TGPDebugEventLevel = (
    DebugEventLevelFatal,
    DebugEventLevelWarning);

// Callback function that GDI+ can call, on debug builds, for assertions
// and warnings.

type
  TGPDebugEventProc = procedure(Level: TGPDebugEventLevel; Message: PAnsiChar); stdcall;

// Notification functions which the user must call appropriately if
// "SuppressBackgroundThread" (below) is set.

type
  TGPNofificationHookProc = function(out Token: ULONG): TGPStatus; stdcall;
  TGPNofificationUnhookProc = procedure(Token: ULONG); stdcall;

// Input structure for GdiplusStartup()

type
  TGdiplusStartupInput = record
  public
    GdiplusVersion: UInt32; // Must be 1  (or 2 for the Ex version)
    DebugEventCallback: TGPDebugEventProc; // Ignored on free builds
    SuppressBackgroundThread: BOOL; // FALSE unless you're prepared to call the hook/unhook functions properly
    SuppressExternalCodecs: BOOL; // FALSE unless you want GDI+ only to use its internal image codecs.
  public
    procedure Intialize(const ADebugEventCallback: TGPDebugEventProc = nil;
      const ASuppressBackgroundThread: Boolean = False;
      const ASuppressExternalCodecs: Boolean = False);
  end;
  PGdiplusStartupInput = ^TGdiplusStartupInput;

{$IF (GDIPVER >= $0110)}
type
  TGdiplusStartupInputEx = record
  public
    { From TGdiplusStartupInput }
    GdiplusVersion: UInt32;
    DebugEventCallback: TGPDebugEventProc;
    SuppressBackgroundThread: BOOL;
    SuppressExternalCodecs: BOOL;
    { New }
    StartupParameters: Integer; // Do we not set the FPU rounding mode
  public
    procedure Intialize(const AStartupParameters: Integer = 0;
      const ADebugEventCallback: TGPDebugEventProc = nil;
      const ASuppressBackgroundThread: Boolean = False;
      const ASuppressExternalCodecs: Boolean = False);
  end;
  PGdiplusStartupInputEx = ^TGdiplusStartupInputEx;

const
  GdiplusStartupDefault = 0;
  GdiplusStartupNoSetRound = 1;
  GdiplusStartupSetPSValue = 2;
  GdiplusStartupTransparencyMask = $FF000000;
{$IFEND}

// Output structure for GdiplusStartup()

type
  TGdiplusStartupOutput = record
    // The following 2 fields are NULL if SuppressBackgroundThread is FALSE.
    // Otherwise, they are functions which must be called appropriately to
    // replace the background thread.
    //
    // These should be called on the application's main message loop - i.e.
    // a message loop which is active for the lifetime of GDI+.
    // "NotificationHook" should be called before starting the loop,
    // and "NotificationUnhook" should be called after the loop ends.
    NotificationHook: TGPNofificationHookProc;
    NotificationUnhook: TGPNofificationUnhookProc;
  end;
  PGdiplusStartupOutput = ^TGdiplusStartupOutput;

// GDI+ initialization. Must not be called from DllMain - can cause deadlock.
//
// Must be called before GDI+ API's or constructors are used.
//
// token  - may not be NULL - accepts a token to be passed in the corresponding
//          GdiplusShutdown call.
// input  - may not be NULL
// output - may be NULL only if input->SuppressBackgroundThread is FALSE.

function GdiplusStartup(out Token: ULONG; const Input: PGdiplusStartupInput;
  Output: PGdiplusStartupOutput): TGPStatus; stdcall; external GdiPlusDll;

// GDI+ termination. Must be called before GDI+ is unloaded.
// Must not be called from DllMain - can cause deadlock.
//
// GDI+ API's may not be called after GdiplusShutdown. Pay careful attention
// to GDI+ object destructors.

procedure GdiplusShutdown(Token: ULONG); stdcall; external GdiPlusDll;
{$ENDREGION 'GdiplusInit.h'}

{$REGION 'GdiplusPixelFormats.h'}
(*****************************************************************************
 * GdiplusPixelFormats.h
 * GDI+ Pixel Formats
 *****************************************************************************)

type
  ARGB = UInt32;
  ARGB64 = UInt64;
  PARGB = ^ARGB;
  PARGB64 = ^ARGB64;

const
  ALPHA_SHIFT = 24;
  RED_SHIFT   = 16;
  GREEN_SHIFT = 8;
  BLUE_SHIFT  = 0;
  ALPHA_MASK  = ARGB($FF) shl ALPHA_SHIFT;

// In-memory pixel data formats:
// bits 0-7 = format index
// bits 8-15 = pixel size (in bits)
// bits 16-23 = flags
// bits 24-31 = reserved

type
  TGPPixelFormat = Integer;

const
  PixelFormatIndexed         = $00010000; // Indexes into a palette
  PixelFormatGDI             = $00020000; // Is a GDI-supported format
  PixelFormatAlpha           = $00040000; // Has an alpha component
  PixelFormatPAlpha          = $00080000; // Pre-multiplied alpha
  PixelFormatExtended        = $00100000; // Extended color 16 bits/channel
  PixelFormatCanonical       = $00200000;

  PixelFormatUndefined       = 0;
  PixelFormatDontCare        = 0;

  PixelFormat1bppIndexed     = ( 1 or ( 1 shl 8) or PixelFormatIndexed or PixelFormatGDI);
  PixelFormat4bppIndexed     = ( 2 or ( 4 shl 8) or PixelFormatIndexed or PixelFormatGDI);
  PixelFormat8bppIndexed     = ( 3 or ( 8 shl 8) or PixelFormatIndexed or PixelFormatGDI);
  PixelFormat16bppGrayScale  = ( 4 or (16 shl 8) or PixelFormatExtended);
  PixelFormat16bppRGB555     = ( 5 or (16 shl 8) or PixelFormatGDI);
  PixelFormat16bppRGB565     = ( 6 or (16 shl 8) or PixelFormatGDI);
  PixelFormat16bppARGB1555   = ( 7 or (16 shl 8) or PixelFormatAlpha or PixelFormatGDI);
  PixelFormat24bppRGB        = ( 8 or (24 shl 8) or PixelFormatGDI);
  PixelFormat32bppRGB        = ( 9 or (32 shl 8) or PixelFormatGDI);
  PixelFormat32bppARGB       = (10 or (32 shl 8) or PixelFormatAlpha or PixelFormatGDI or PixelFormatCanonical);
  PixelFormat32bppPARGB      = (11 or (32 shl 8) or PixelFormatAlpha or PixelFormatPAlpha or PixelFormatGDI);
  PixelFormat48bppRGB        = (12 or (48 shl 8) or PixelFormatExtended);
  PixelFormat64bppARGB       = (13 or (64 shl 8) or PixelFormatAlpha  or PixelFormatCanonical or PixelFormatExtended);
  PixelFormat64bppPARGB      = (14 or (64 shl 8) or PixelFormatAlpha  or PixelFormatPAlpha or PixelFormatExtended);
  PixelFormat32bppCMYK       = (15 or (32 shl 8));
  PixelFormatMax             = 16;

function GetPixelFormatSize(const PixFmt: TGPPixelFormat): Integer; inline;
function IsIndexedPixelFormat(const PixFmt: TGPPixelFormat): Boolean; inline;
function IsAlphaPixelFormat(const PixFmt: TGPPixelFormat): Boolean; inline;
function IsExtendedPixelFormat(const PixFmt: TGPPixelFormat): Boolean; inline;

//--------------------------------------------------------------------------
// Determine if the Pixel Format is Canonical format:
//   PixelFormat32bppARGB
//   PixelFormat32bppPARGB
//   PixelFormat64bppARGB
//   PixelFormat64bppPARGB
//--------------------------------------------------------------------------

function IsCanonicalPixelFormat(const PixFmt: TGPPixelFormat): Boolean; inline;

{$IF (GDIPVER >= $0110)}
//----------------------------------------------------------------------------
// Color format conversion parameters
//----------------------------------------------------------------------------

type
  TGPPaletteType = (
    // Arbitrary custom palette provided by caller.

    PaletteTypeCustom           = 0,

    // Optimal palette generated using a median-cut algorithm.

    PaletteTypeOptimal        = 1,

    // Black and white palette.

    PaletteTypeFixedBW          = 2,

    // Symmetric halftone palettes.
    // Each of these halftone palettes will be a superset of the system palette.
    // E.g. Halftone8 will have it's 8-color on-off primaries and the 16 system
    // colors added. With duplicates removed, that leaves 16 colors.

    PaletteTypeFixedHalftone8   = 3, // 8-color, on-off primaries
    PaletteTypeFixedHalftone27  = 4, // 3 intensity levels of each color
    PaletteTypeFixedHalftone64  = 5, // 4 intensity levels of each color
    PaletteTypeFixedHalftone125 = 6, // 5 intensity levels of each color
    PaletteTypeFixedHalftone216 = 7, // 6 intensity levels of each color

    // Assymetric halftone palettes.
    // These are somewhat less useful than the symmetric ones, but are
    // included for completeness. These do not include all of the system
    // colors.

    PaletteTypeFixedHalftone252 = 8,  // 6-red, 7-green, 6-blue intensities
    PaletteTypeFixedHalftone256 = 9); // 8-red, 8-green, 4-blue intensities

type
  TGPDitherType = (
    DitherTypeNone          = 0,

    // Solid color - picks the nearest matching color with no attempt to
    // halftone or dither. May be used on an arbitrary palette.

    DitherTypeSolid         = 1,

    // Ordered dithers and spiral dithers must be used with a fixed palette.

    // NOTE: DitherOrdered4x4 is unique in that it may apply to 16bpp
    // conversions also.

    DitherTypeOrdered4x4    = 2,

    DitherTypeOrdered8x8    = 3,
    DitherTypeOrdered16x16  = 4,
    DitherTypeSpiral4x4     = 5,
    DitherTypeSpiral8x8     = 6,
    DitherTypeDualSpiral4x4 = 7,
    DitherTypeDualSpiral8x8 = 8,

    // Error diffusion. May be used with any palette.

    DitherTypeErrorDiffusion   = 9,

    DitherTypeMax              = 10);
{$IFEND}

type
  TGPPaletteFlag = (
    PaletteFlagsHasAlpha    = 0,
    PaletteFlagsGrayScale   = 1,
    PaletteFlagsHalftone    = 2,
    PaletteFlagsReserved    = 31);
  TGPPaletteFlags = set of TGPPaletteFlag;

type
  TGPNativeColorPalette = record
  public
    Flags: TGPPaletteFlags;
    Count: Integer;
    // Entries: array [0..0] of ARGB;
  end;
  PGPNativeColorPalette = ^TGPNativeColorPalette;
{$ENDREGION 'GdiplusPixelFormats.h'}

{$REGION 'GdiplusColor.h'}
(*****************************************************************************
 * GdiplusColor.h
 * GDI+ Color Object
 *****************************************************************************)

//----------------------------------------------------------------------------
// Color mode
//----------------------------------------------------------------------------

type
  TGPColorMode = (
    ColorModeARGB32 = 0,
    ColorModeARGB64 = 1);

//----------------------------------------------------------------------------
// Color Channel flags
//----------------------------------------------------------------------------

type
  TGPColorChannelFlags = (
    ColorChannelFlagsC = 0,
    ColorChannelFlagsM,
    ColorChannelFlagsY,
    ColorChannelFlagsK,
    ColorChannelFlagsLast);

//----------------------------------------------------------------------------
// Color
//----------------------------------------------------------------------------

type
  TGPColor = record
  private
    FArgb: ARGB;
  private
    function GetAlpha: Byte;
    procedure SetAlpha(const Value: Byte);
    function GetRed: Byte;
    procedure SetRed(const Value: Byte);
    function GetGreen: Byte;
    procedure SetGreen(const Value: Byte);
    function GetBlue: Byte;
    procedure SetBlue(const Value: Byte);
    function GetColorRef: TColorRef;
    procedure SetColorRef(const Value: TColorRef);
  public
    // Common color constants
    const AliceBlue            = $FFF0F8FF;
    const AntiqueWhite         = $FFFAEBD7;
    const Aqua                 = $FF00FFFF;
    const Aquamarine           = $FF7FFFD4;
    const Azure                = $FFF0FFFF;
    const Beige                = $FFF5F5DC;
    const Bisque               = $FFFFE4C4;
    const Black                = $FF000000;
    const BlanchedAlmond       = $FFFFEBCD;
    const Blue                 = $FF0000FF;
    const BlueViolet           = $FF8A2BE2;
    const Brown                = $FFA52A2A;
    const BurlyWood            = $FFDEB887;
    const CadetBlue            = $FF5F9EA0;
    const Chartreuse           = $FF7FFF00;
    const Chocolate            = $FFD2691E;
    const Coral                = $FFFF7F50;
    const CornflowerBlue       = $FF6495ED;
    const Cornsilk             = $FFFFF8DC;
    const Crimson              = $FFDC143C;
    const Cyan                 = $FF00FFFF;
    const DarkBlue             = $FF00008B;
    const DarkCyan             = $FF008B8B;
    const DarkGoldenrod        = $FFB8860B;
    const DarkGray             = $FFA9A9A9;
    const DarkGreen            = $FF006400;
    const DarkKhaki            = $FFBDB76B;
    const DarkMagenta          = $FF8B008B;
    const DarkOliveGreen       = $FF556B2F;
    const DarkOrange           = $FFFF8C00;
    const DarkOrchid           = $FF9932CC;
    const DarkRed              = $FF8B0000;
    const DarkSalmon           = $FFE9967A;
    const DarkSeaGreen         = $FF8FBC8B;
    const DarkSlateBlue        = $FF483D8B;
    const DarkSlateGray        = $FF2F4F4F;
    const DarkTurquoise        = $FF00CED1;
    const DarkViolet           = $FF9400D3;
    const DeepPink             = $FFFF1493;
    const DeepSkyBlue          = $FF00BFFF;
    const DimGray              = $FF696969;
    const DodgerBlue           = $FF1E90FF;
    const Firebrick            = $FFB22222;
    const FloralWhite          = $FFFFFAF0;
    const ForestGreen          = $FF228B22;
    const Fuchsia              = $FFFF00FF;
    const Gainsboro            = $FFDCDCDC;
    const GhostWhite           = $FFF8F8FF;
    const Gold                 = $FFFFD700;
    const Goldenrod            = $FFDAA520;
    const Gray                 = $FF808080;
    const Green                = $FF008000;
    const GreenYellow          = $FFADFF2F;
    const Honeydew             = $FFF0FFF0;
    const HotPink              = $FFFF69B4;
    const IndianRed            = $FFCD5C5C;
    const Indigo               = $FF4B0082;
    const Ivory                = $FFFFFFF0;
    const Khaki                = $FFF0E68C;
    const Lavender             = $FFE6E6FA;
    const LavenderBlush        = $FFFFF0F5;
    const LawnGreen            = $FF7CFC00;
    const LemonChiffon         = $FFFFFACD;
    const LightBlue            = $FFADD8E6;
    const LightCoral           = $FFF08080;
    const LightCyan            = $FFE0FFFF;
    const LightGoldenrodYellow = $FFFAFAD2;
    const LightGray            = $FFD3D3D3;
    const LightGreen           = $FF90EE90;
    const LightPink            = $FFFFB6C1;
    const LightSalmon          = $FFFFA07A;
    const LightSeaGreen        = $FF20B2AA;
    const LightSkyBlue         = $FF87CEFA;
    const LightSlateGray       = $FF778899;
    const LightSteelBlue       = $FFB0C4DE;
    const LightYellow          = $FFFFFFE0;
    const Lime                 = $FF00FF00;
    const LimeGreen            = $FF32CD32;
    const Linen                = $FFFAF0E6;
    const Magenta              = $FFFF00FF;
    const Maroon               = $FF800000;
    const MediumAquamarine     = $FF66CDAA;
    const MediumBlue           = $FF0000CD;
    const MediumOrchid         = $FFBA55D3;
    const MediumPurple         = $FF9370DB;
    const MediumSeaGreen       = $FF3CB371;
    const MediumSlateBlue      = $FF7B68EE;
    const MediumSpringGreen    = $FF00FA9A;
    const MediumTurquoise      = $FF48D1CC;
    const MediumVioletRed      = $FFC71585;
    const MidnightBlue         = $FF191970;
    const MintCream            = $FFF5FFFA;
    const MistyRose            = $FFFFE4E1;
    const Moccasin             = $FFFFE4B5;
    const NavajoWhite          = $FFFFDEAD;
    const Navy                 = $FF000080;
    const OldLace              = $FFFDF5E6;
    const Olive                = $FF808000;
    const OliveDrab            = $FF6B8E23;
    const Orange               = $FFFFA500;
    const OrangeRed            = $FFFF4500;
    const Orchid               = $FFDA70D6;
    const PaleGoldenrod        = $FFEEE8AA;
    const PaleGreen            = $FF98FB98;
    const PaleTurquoise        = $FFAFEEEE;
    const PaleVioletRed        = $FFDB7093;
    const PapayaWhip           = $FFFFEFD5;
    const PeachPuff            = $FFFFDAB9;
    const Peru                 = $FFCD853F;
    const Pink                 = $FFFFC0CB;
    const Plum                 = $FFDDA0DD;
    const PowderBlue           = $FFB0E0E6;
    const Purple               = $FF800080;
    const Red                  = $FFFF0000;
    const RosyBrown            = $FFBC8F8F;
    const RoyalBlue            = $FF4169E1;
    const SaddleBrown          = $FF8B4513;
    const Salmon               = $FFFA8072;
    const SandyBrown           = $FFF4A460;
    const SeaGreen             = $FF2E8B57;
    const SeaShell             = $FFFFF5EE;
    const Sienna               = $FFA0522D;
    const Silver               = $FFC0C0C0;
    const SkyBlue              = $FF87CEEB;
    const SlateBlue            = $FF6A5ACD;
    const SlateGray            = $FF708090;
    const Snow                 = $FFFFFAFA;
    const SpringGreen          = $FF00FF7F;
    const SteelBlue            = $FF4682B4;
    const Tan                  = $FFD2B48C;
    const Teal                 = $FF008080;
    const Thistle              = $FFD8BFD8;
    const Tomato               = $FFFF6347;
    const Transparent          = $00FFFFFF;
    const Turquoise            = $FF40E0D0;
    const Violet               = $FFEE82EE;
    const Wheat                = $FFF5DEB3;
    const White                = $FFFFFFFF;
    const WhiteSmoke           = $FFF5F5F5;
    const Yellow               = $FFFFFF00;
    const YellowGreen          = $FF9ACD32;

    // Shift count and bit mask for A, R, G, B components
    const AlphaShift = 24;
    const RedShift   = 16;
    const GreenShift = 8;
    const BlueShift  = 0;

    const AlphaMask  = $FF000000;
    const RedMask    = $00FF0000;
    const GreenMask  = $0000FF00;
    const BlueMask   = $000000FF;
  public
    procedure Initialize; overload;

    // Construct an opaque Color object with
    // the specified Red, Green, Blue values.
    //
    // Color values are not premultiplied.
    procedure Initialize(const R, G, B: Byte); overload;
    procedure Initialize(const A, R, G, B: Byte); overload;
    procedure Initialize(const AArgb: ARGB); overload;
    procedure InitializeFromColorRef(const ColorRef: TColorRef);

    class operator Implicit(const AArgb: ARGB): TGPColor;
    class operator Implicit(const Color: TGPColor): ARGB;
    class function MakeARGB(const A, R, G, B: Byte): ARGB; static;
    class function Create(const R, G, B: Byte): TGPColor; overload; static;
    class function Create(const A, R, G, B: Byte): TGPColor; overload; static;
    class function Create(const AArgb: ARGB): TGPColor; overload; static;
    class function CreateFromColorRef(const ColorRef: TColorRef): TGPColor; overload; static;

    property Alpha: Byte read GetAlpha write SetAlpha;
    property A: Byte read GetAlpha write SetAlpha;
    property R: Byte read GetRed write SetRed;
    property G: Byte read GetGreen write SetGreen;
    property B: Byte read GetBlue write SetBlue;
    property Value: ARGB read FArgb write FArgb;
    property ColorRef: TColorRef read GetColorRef write SetColorRef;
  end;
  PGPColor = ^TGPColor;
{$ENDREGION 'GdiplusColor.h'}

{$REGION 'GdiplusMetaHeader.h'}
(*****************************************************************************
 * GdiplusMetaHeader.h
 * GDI+ Metafile Related Structures
 *****************************************************************************)

type
  TEnhMetaHeader3 = record
    iType: DWORD;               // Record type EMR_HEADER
    nSize: DWORD;               // Record size in bytes.  This may be greater
                                // than the sizeof(ENHMETAHEADER).
    rclBounds: Windows.TRect;   // Inclusive-inclusive bounds in device units
    rclFrame: Windows.TRect;    // Inclusive-inclusive Picture Frame .01mm unit
    dSignature: DWORD;          // Signature.  Must be ENHMETA_SIGNATURE.
    nVersion: DWORD;            // Version number
    nBytes: DWORD;              // Size of the metafile in bytes
    nRecords: DWORD;            // Number of records in the metafile
    nHandles: WORD;             // Number of handles in the handle table
                                // Handle index zero is reserved.
    sReserved: WORD;            // Reserved.  Must be zero.
    nDescription: DWORD;        // Number of chars in the unicode desc string
                                // This is 0 if there is no description string
    offDescription: DWORD;      // Offset to the metafile description record.
                                // This is 0 if there is no description string
    nPalEntries: DWORD;         // Number of entries in the metafile palette.
    szlDevice: Windows.TSize;   // Size of the reference device in pels
    szlMillimeters: Windows.TSize; // Size of the reference device in millimeters
  end;
  PEnhMetaHeader3 = ^TEnhMetaHeader3;

// Placeable WMFs

// Placeable Metafiles were created as a non-standard way of specifying how
// a metafile is mapped and scaled on an output device.
// Placeable metafiles are quite wide-spread, but not directly supported by
// the Windows API. To playback a placeable metafile using the Windows API,
// you will first need to strip the placeable metafile header from the file.
// This is typically performed by copying the metafile to a temporary file
// starting at file offset 22 (0x16). The contents of the temporary file may
// then be used as input to the Windows GetMetaFile(), PlayMetaFile(),
// CopyMetaFile(), etc. GDI functions.

// Each placeable metafile begins with a 22-byte header,
//  followed by a standard metafile:

type
  TPWMFRect16 = packed record
    Left: Int16;
    Top: Int16;
    Right: Int16;
    Bottom: Int16;
  end;
  PPWMFRect16 = ^TPWMFRect16;

type
  TWmfPlaceableFileHeader = packed record
    Key: UInt32;                 // GDIP_WMF_PLACEABLEKEY
    Hmf: Int16;                  // Metafile HANDLE number (always 0)
    BoundingBox: TPWMFRect16;    // Coordinates in metafile units
    Inch: Int16;                 // Number of metafile units per inch
    Reserved: UInt32;            // Reserved (always 0)
    Checksum: Int16;             // Checksum value for previous 10 WORDs
  end;
  PWmfPlaceableFileHeader = ^TWmfPlaceableFileHeader;

// Key contains a special identification value that indicates the presence
// of a placeable metafile header and is always 0x9AC6CDD7.

// Handle is used to stored the handle of the metafile in memory. When written
// to disk, this field is not used and will always contains the value 0.

// Left, Top, Right, and Bottom contain the coordinates of the upper-left
// and lower-right corners of the image on the output device. These are
// measured in twips.

// A twip (meaning "twentieth of a point") is the logical unit of measurement
// used in Windows Metafiles. A twip is equal to 1/1440 of an inch. Thus 720
// twips equal 1/2 inch, while 32,768 twips is 22.75 inches.

// Inch contains the number of twips per inch used to represent the image.
// Normally, there are 1440 twips per inch; however, this number may be
// changed to scale the image. A value of 720 indicates that the image is
// double its normal size, or scaled to a factor of 2:1. A value of 360
// indicates a scale of 4:1, while a value of 2880 indicates that the image
// is scaled down in size by a factor of two. A value of 1440 indicates
// a 1:1 scale ratio.

// Reserved is not used and is always set to 0.

// Checksum contains a checksum value for the previous 10 WORDs in the header.
// This value can be used in an attempt to detect if the metafile has become
// corrupted. The checksum is calculated by XORing each WORD value to an
// initial value of 0.

// If the metafile was recorded with a reference Hdc that was a display.

const
  GDIP_EMFPLUSFLAGS_DISPLAY = $00000001;

type
  TGPMetafileHeader = record
  private
    type
      THeader = record
        case Integer of
          0: (WmfHeader: TMetaHeader);
          1: (EmfHeader: TEnhMetaHeader3);
      end;
  private
    FMetafileType: TGPMetafileType;
    FSize: Cardinal;    // Size of the metafile (in bytes)
    FVersion: Cardinal; // EMF+, EMF, or WMF version
    FEmfPlusFlags: Cardinal;
    FDpiX: Single;
    FDpiY: Single;
    FX: Integer;        // Bounds in device units
    FY: Integer;
    FWidth: Integer;
    FHeight: Integer;
    FHeader: THeader;
    FEmfPlusHeaderSize: Integer; // size of the EMF+ header in file
    FLogicalDpiX: Integer;       // Logical Dpi of reference Hdc
    FLogicalDpiY: Integer;       // usually valid only for EMF+
  private
    function GetBounds: TGPRect;
    function GetWmfHeader: PMetaHeader;
    function GetEmfHeader: PEnhMetaHeader3;
  public
    // Is it any type of WMF (standard or Placeable Metafile)?
    function IsWmf: Boolean;

    // Is this an Placeable Metafile?
    function IsWmfPlaceable: Boolean;

    // Is this an EMF (not an EMF+)?
    function IsEmf: Boolean;

    // Is this an EMF or EMF+ file?
    function IsEmfOrEmfPlus: Boolean;

    // Is this an EMF+ file?
    function IsEmfPlus: Boolean;

    // Is this an EMF+ dual (has dual, down-level records) file?
    function IsEmfPlusDual: Boolean;

    // Is this an EMF+ only (no dual records) file?
    function IsEmfPlusOnly: Boolean;

    // If it's an EMF+ file, was it recorded against a display Hdc?
    function IsDisplay: Boolean;

    property MetafileType: TGPMetafileType read FMetafileType;
    property MetafileSize: Cardinal read FSize;

    // If IsEmfPlus, this is the EMF+ version; else it is the WMF or EMF ver
    property Version: Cardinal read FVersion;

    // Get the EMF+ flags associated with the metafile
    property EmfPlusFlags: Cardinal read FEmfPlusFlags;

    property DpiX: Single read FDpiX;
    property DpiY: Single read FDpiY;
    property Bounds: TGPRect read GetBounds;

    // Get the WMF header of the metafile (if it is a WMF)
    property WmfHeader: PMetaHeader read GetWmfHeader;

    // Get the EMF header of the metafile (if it is an EMF)
    property EmfHeader: PEnhMetaHeader3 read GetEmfHeader;

    property EmfPlusHeaderSize: Integer read FEmfPlusHeaderSize;
    property LogicalDpiX: Integer read FLogicalDpiX;
    property LogicalDpiY: Integer read FLogicalDpiY;
  end;
  PGPMetafileHeader = ^TGPMetafileHeader;
{$ENDREGION 'GdiplusMetaHeader.h'}

{$REGION 'GdiplusImaging.h'}
(*****************************************************************************
 * GdiplusImaging.h
 * GDI+ Imaging GUIDs
 *****************************************************************************)

//---------------------------------------------------------------------------
// Image file format identifiers
//---------------------------------------------------------------------------
const
  ImageFormatUndefined : TGUID = '{b96b3ca9-0728-11d3-9d7b-0000f81ef32e}';
  ImageFormatMemoryBMP : TGUID = '{b96b3caa-0728-11d3-9d7b-0000f81ef32e}';
  ImageFormatBMP       : TGUID = '{b96b3cab-0728-11d3-9d7b-0000f81ef32e}';
  ImageFormatEMF       : TGUID = '{b96b3cac-0728-11d3-9d7b-0000f81ef32e}';
  ImageFormatWMF       : TGUID = '{b96b3cad-0728-11d3-9d7b-0000f81ef32e}';
  ImageFormatJPEG      : TGUID = '{b96b3cae-0728-11d3-9d7b-0000f81ef32e}';
  ImageFormatPNG       : TGUID = '{b96b3caf-0728-11d3-9d7b-0000f81ef32e}';
  ImageFormatGIF       : TGUID = '{b96b3cb0-0728-11d3-9d7b-0000f81ef32e}';
  ImageFormatTIFF      : TGUID = '{b96b3cb1-0728-11d3-9d7b-0000f81ef32e}';
  ImageFormatEXIF      : TGUID = '{b96b3cb2-0728-11d3-9d7b-0000f81ef32e}';
  ImageFormatIcon      : TGUID = '{b96b3cb5-0728-11d3-9d7b-0000f81ef32e}';

//---------------------------------------------------------------------------
// Predefined multi-frame dimension IDs
//---------------------------------------------------------------------------

const
  FrameDimensionTime       : TGUID = '{6aedbd6d-3fb5-418a-83a6-7f45229dc872}';
  FrameDimensionResolution : TGUID = '{84236f7b-3bd3-428f-8dab-4ea1439ca315}';
  FrameDimensionPage       : TGUID = '{7462dc86-6180-4c7e-8e3f-ee7333a7a483}';

//---------------------------------------------------------------------------
// Property sets
//---------------------------------------------------------------------------

const
  FormatIDImageInformation : TGUID = '{e5836cbe-5eef-4f1d-acde-ae4c43b608ce}';
  FormatIDJpegAppHeaders   : TGUID = '{1c4afdcd-6177-43cf-abc7-5f51af39ee85}';

//---------------------------------------------------------------------------
// Encoder parameter sets
//---------------------------------------------------------------------------

const
  EncoderCompression      : TGUID = '{e09d739d-ccd4-44ee-8eba-3fbf8be4fc58}';
  EncoderColorDepth       : TGUID = '{66087055-ad66-4c7c-9a18-38a2310b8337}';
  EncoderScanMethod       : TGUID = '{3a4e2661-3109-4e56-8536-42c156e7dcfa}';
  EncoderVersion          : TGUID = '{24d18c76-814a-41a4-bf53-1c219cccf797}';
  EncoderRenderMethod     : TGUID = '{6d42c53a-229a-4825-8bb7-5c99e2b9a8b8}';
  EncoderQuality          : TGUID = '{1d5be4b5-fa4a-452d-9cdd-5db35105e7eb}';
  EncoderTransformation   : TGUID = '{8d0eb2d1-a58e-4ea8-aa14-108074b7b6f9}';
  EncoderLuminanceTable   : TGUID = '{edb33bce-0266-4a77-b904-27216099e717}';
  EncoderChrominanceTable : TGUID = '{f2e455dc-09b3-4316-8260-676ada32481c}';
  EncoderSaveFlag         : TGUID = '{292266fc-ac40-47bf-8cfc-a85b89a655de}';

  {$IF (GDIPVER >= $0110)}
  EncoderColorSpace       : TGUID = '{ae7a62a0-ee2c-49d8-9d07-1ba8a927596e}';
  EncoderImageItems       : TGUID = '{63875e13-1f1d-45ab-9195-a29b6066a650}';
  EncoderSaveAsCMYK       : TGUID = '{a219bbc9-0a9d-4005-a3ee-3a421b8bb06c}';
  {$IFEND}

  CodecIImageBytes        : TGUID = '{025d1823-6c7d-447b-bbdb-a3cbc3dfa2fc}';

type
  IGPImageBytes = interface(IUnknown)
  ['{025D1823-6C7D-447B-BBDB-A3CBC3DFA2FC}']
    // Return total number of bytes in the IStream
    function CountBytes(out Count: UINT): HRESULT; stdcall;

    // Locks "cb" bytes, starting from "ulOffset" in the stream, and returns the
    // pointer to the beginning of the locked memory chunk in "ppvBytes"
    function LockBytes(Count: UINT; Offset: ULONG; out Bytes: Pointer): HResult; stdcall;

    // Unlocks "cb" bytes, pointed by "pvBytes", starting from "ulOffset" in the
    // stream
    function UnlockBytes(const Bytes: Pointer; Count: UINT; Offset: ULONG): HResult; stdcall;
  end;

//--------------------------------------------------------------------------
// Information flags about image codecs
//--------------------------------------------------------------------------

type
  TGPImageCodecFlag = (
    ImageCodecFlagsEncoder            = 0,
    ImageCodecFlagsDecoder            = 1,
    ImageCodecFlagsSupportBitmap      = 2,
    ImageCodecFlagsSupportVector      = 3,
    ImageCodecFlagsSeekableEncode     = 4,
    ImageCodecFlagsBlockingDecode     = 5,

    ImageCodecFlagsBuiltin            = 16,
    ImageCodecFlagsSystem             = 17,
    ImageCodecFlagsUser               = 18);
  TGPImageCodecFlags = set of TGPImageCodecFlag;

//--------------------------------------------------------------------------
// ImageCodecInfo structure
//--------------------------------------------------------------------------

type
  TGPNativeImageCodecInfo = record
  public
    ClsId: TGUID;
    FormatId: TGUID;
    CodecName: PWideChar;
    DllName: PWideChar;
    FormatDescription: PWideChar;
    FilenameExtension: PWideChar;
    MimeType: PWideChar;
    Flags: TGPImageCodecFlags;
    Version: DWORD;
    SigCount: DWORD;
    SigSize: DWORD;
    SigPattern: PByte;
    SigMask: PByte;
  end;
  PGPNativeImageCodecInfo = ^TGPNativeImageCodecInfo;

//---------------------------------------------------------------------------
// Access modes used when calling Image::LockBits
//---------------------------------------------------------------------------

type
  TGPImageLockModeOption = (
    ImageLockModeRead         = 0,
    ImageLockModeWrite        = 1,
    ImageLockModeUserInputBuf = 2,
    ImageLockModeReserved     = 31);

  TGPImageLockMode = set of TGPImageLockModeOption;

//---------------------------------------------------------------------------
// Information about image pixel data
//---------------------------------------------------------------------------

type
  TGPBitmapData = record
  public
    Width: Cardinal;
    Height: Cardinal;
    Stride: Integer;
    PixelFormat: TGPPixelFormat;
    Scan0: Pointer;
    Reserved: Cardinal;
  end;
  PGPBitmapData = ^TGPBitmapData;

//---------------------------------------------------------------------------
// Image flags
//---------------------------------------------------------------------------

type
  TGPImageFlag = (
    // Low-word: shared with SINKFLAG_x

    ImageFlagsScalable            = 0,
    ImageFlagsHasAlpha            = 1,
    ImageFlagsHasTranslucent      = 2,
    ImageFlagsPartiallyScalable   = 3,

    // Low-word: color space definition

    ImageFlagsColorSpaceRGB       = 4,
    ImageFlagsColorSpaceCMYK      = 5,
    ImageFlagsColorSpaceGRAY      = 6,
    ImageFlagsColorSpaceYCBCR     = 7,
    ImageFlagsColorSpaceYCCK      = 8,

    // Low-word: image size info

    ImageFlagsHasRealDPI          = 12,
    ImageFlagsHasRealPixelSize    = 13,

    // High-word

    ImageFlagsReadOnly            = 16,
    ImageFlagsCaching             = 17);

  TGPImageFlags = set of TGPImageFlag;

const
  ImageFlagsNone = [];

type
  TGPRotateFlipType = (
    RotateNoneFlipNone = 0,
    Rotate90FlipNone   = 1,
    Rotate180FlipNone  = 2,
    Rotate270FlipNone  = 3,

    RotateNoneFlipX    = 4,
    Rotate90FlipX      = 5,
    Rotate180FlipX     = 6,
    Rotate270FlipX     = 7,

    RotateNoneFlipY    = Rotate180FlipX,
    Rotate90FlipY      = Rotate270FlipX,
    Rotate180FlipY     = RotateNoneFlipX,
    Rotate270FlipY     = Rotate90FlipX,

    RotateNoneFlipXY   = Rotate180FlipNone,
    Rotate90FlipXY     = Rotate270FlipNone,
    Rotate180FlipXY    = RotateNoneFlipNone,
    Rotate270FlipXY    = Rotate90FlipNone);

//---------------------------------------------------------------------------
// Encoder Parameter structure
//---------------------------------------------------------------------------

type
  TGPNativeEncoderParameter = record
  public
    Guid: TGUID;               // GUID of the parameter
    NumberOfValues: ULONG;     // Number of the parameter values
    ValueType: TGPEncoderParameterValueType;  // Value type, like ValueTypeLONG  etc.
    Value: Pointer;            // A pointer to the parameter values
  end;
  PGPNativeEncoderParameter = ^TGPNativeEncoderParameter;

//---------------------------------------------------------------------------
// Encoder Parameters structure
//---------------------------------------------------------------------------

type
  TGPNativeEncoderParameters = record
  public
    Count: Cardinal;  // Number of parameters in this structure
    Parameter: array [0..0] of TGPNativeEncoderParameter; // Parameter values
  end;
  PGPNativeEncoderParameters = ^TGPNativeEncoderParameters;

{$IF (GDIPVER >= $0110)}
type
  TGPItemDataPosition = (
    ItemDataPositionAfterHeader    = 0,
    ItemDataPositionAfterPalette   = 1,
    ItemDataPositionAfterBits      = 2);

//---------------------------------------------------------------------------
// External Data Item
//---------------------------------------------------------------------------

type
  TGPImageItemData = record
  public
    Size: Cardinal;       // size of the structure
    Position: Cardinal;   // flags describing how the data is to be used.
    Desc: Pointer;        // description on how the data is to be saved.
                          // it is different for every codec type.
    DescSize: Cardinal;   // size memory pointed by Desc
    Data: Pointer;        // pointer to the data that is to be saved in the
                          // file, could be anything saved directly.
    DataSize: Cardinal;   // size memory pointed by Data
    Cookie: Cardinal;     // opaque for the apps data member used during
                          // enumeration of image data items.
  end;
  PGPImageItemData = ^TGPImageItemData;
{$IFEND}

//---------------------------------------------------------------------------
// Property Item
//---------------------------------------------------------------------------

type
  TGPNativePropertyItem = record
  public
    Id: TPropID;                // ID of this property
    Length: ULONG;              // Length of the property value, in bytes
    ValueType: Word;            // Type of the value, as one of TAG_TYPE_XXX
                                // defined above
    Value: Pointer;             // property value
  end;
  PGPNativePropertyItem = ^TGPNativePropertyItem;

//---------------------------------------------------------------------------
// Image property types
//---------------------------------------------------------------------------

const
  PropertyTagTypeByte        = 1;
  PropertyTagTypeASCII       = 2;
  PropertyTagTypeShort       = 3;
  PropertyTagTypeLong        = 4;
  PropertyTagTypeRational    = 5;
  PropertyTagTypeUndefined   = 7;
  PropertyTagTypeSLONG       = 9;
  PropertyTagTypeSRational  = 10;

//---------------------------------------------------------------------------
// Image property ID tags
//---------------------------------------------------------------------------

  PropertyTagExifIFD             = $8769;
  PropertyTagGpsIFD              = $8825;

  PropertyTagNewSubfileType      = $00FE;
  PropertyTagSubfileType         = $00FF;
  PropertyTagImageWidth          = $0100;
  PropertyTagImageHeight         = $0101;
  PropertyTagBitsPerSample       = $0102;
  PropertyTagCompression         = $0103;
  PropertyTagPhotometricInterp   = $0106;
  PropertyTagThreshHolding       = $0107;
  PropertyTagCellWidth           = $0108;
  PropertyTagCellHeight          = $0109;
  PropertyTagFillOrder           = $010A;
  PropertyTagDocumentName        = $010D;
  PropertyTagImageDescription    = $010E;
  PropertyTagEquipMake           = $010F;
  PropertyTagEquipModel          = $0110;
  PropertyTagStripOffsets        = $0111;
  PropertyTagOrientation         = $0112;
  PropertyTagSamplesPerPixel     = $0115;
  PropertyTagRowsPerStrip        = $0116;
  PropertyTagStripBytesCount     = $0117;
  PropertyTagMinSampleValue      = $0118;
  PropertyTagMaxSampleValue      = $0119;
  PropertyTagXResolution         = $011A;   // Image resolution in width direction
  PropertyTagYResolution         = $011B;   // Image resolution in height direction
  PropertyTagPlanarConfig        = $011C;   // Image data arrangement
  PropertyTagPageName            = $011D;
  PropertyTagXPosition           = $011E;
  PropertyTagYPosition           = $011F;
  PropertyTagFreeOffset          = $0120;
  PropertyTagFreeByteCounts      = $0121;
  PropertyTagGrayResponseUnit    = $0122;
  PropertyTagGrayResponseCurve   = $0123;
  PropertyTagT4Option            = $0124;
  PropertyTagT6Option            = $0125;
  PropertyTagResolutionUnit      = $0128;   // Unit of X and Y resolution
  PropertyTagPageNumber          = $0129;
  PropertyTagTransferFuncition   = $012D;
  PropertyTagSoftwareUsed        = $0131;
  PropertyTagDateTime            = $0132;
  PropertyTagArtist              = $013B;
  PropertyTagHostComputer        = $013C;
  PropertyTagPredictor           = $013D;
  PropertyTagWhitePoint          = $013E;
  PropertyTagPrimaryChromaticities = $013F;
  PropertyTagColorMap            = $0140;
  PropertyTagHalftoneHints       = $0141;
  PropertyTagTileWidth           = $0142;
  PropertyTagTileLength          = $0143;
  PropertyTagTileOffset          = $0144;
  PropertyTagTileByteCounts      = $0145;
  PropertyTagInkSet              = $014C;
  PropertyTagInkNames            = $014D;
  PropertyTagNumberOfInks        = $014E;
  PropertyTagDotRange            = $0150;
  PropertyTagTargetPrinter       = $0151;
  PropertyTagExtraSamples        = $0152;
  PropertyTagSampleFormat        = $0153;
  PropertyTagSMinSampleValue     = $0154;
  PropertyTagSMaxSampleValue     = $0155;
  PropertyTagTransferRange       = $0156;

  PropertyTagJPEGProc            = $0200;
  PropertyTagJPEGInterFormat     = $0201;
  PropertyTagJPEGInterLength     = $0202;
  PropertyTagJPEGRestartInterval = $0203;
  PropertyTagJPEGLosslessPredictors  = $0205;
  PropertyTagJPEGPointTransforms     = $0206;
  PropertyTagJPEGQTables         = $0207;
  PropertyTagJPEGDCTables        = $0208;
  PropertyTagJPEGACTables        = $0209;

  PropertyTagYCbCrCoefficients   = $0211;
  PropertyTagYCbCrSubsampling    = $0212;
  PropertyTagYCbCrPositioning    = $0213;
  PropertyTagREFBlackWhite       = $0214;

  PropertyTagICCProfile          = $8773;   // This TAG is defined by ICC
                                            // for embedded ICC in TIFF
  PropertyTagGamma               = $0301;
  PropertyTagICCProfileDescriptor = $0302;
  PropertyTagSRGBRenderingIntent = $0303;

  PropertyTagImageTitle          = $0320;
  PropertyTagCopyright           = $8298;

// Extra TAGs (Like Adobe Image Information tags etc.)

  PropertyTagResolutionXUnit           = $5001;
  PropertyTagResolutionYUnit           = $5002;
  PropertyTagResolutionXLengthUnit     = $5003;
  PropertyTagResolutionYLengthUnit     = $5004;
  PropertyTagPrintFlags                = $5005;
  PropertyTagPrintFlagsVersion         = $5006;
  PropertyTagPrintFlagsCrop            = $5007;
  PropertyTagPrintFlagsBleedWidth      = $5008;
  PropertyTagPrintFlagsBleedWidthScale = $5009;
  PropertyTagHalftoneLPI               = $500A;
  PropertyTagHalftoneLPIUnit           = $500B;
  PropertyTagHalftoneDegree            = $500C;
  PropertyTagHalftoneShape             = $500D;
  PropertyTagHalftoneMisc              = $500E;
  PropertyTagHalftoneScreen            = $500F;
  PropertyTagJPEGQuality               = $5010;
  PropertyTagGridSize                  = $5011;
  PropertyTagThumbnailFormat           = $5012; // 1 = JPEG, 0 = RAW RGB
  PropertyTagThumbnailWidth            = $5013;
  PropertyTagThumbnailHeight           = $5014;
  PropertyTagThumbnailColorDepth       = $5015;
  PropertyTagThumbnailPlanes           = $5016;
  PropertyTagThumbnailRawBytes         = $5017;
  PropertyTagThumbnailSize             = $5018;
  PropertyTagThumbnailCompressedSize   = $5019;
  PropertyTagColorTransferFunction     = $501A;
  PropertyTagThumbnailData             = $501B; // RAW thumbnail bits in
                                                // JPEG format or RGB format
                                                // depends on
                                                // PropertyTagThumbnailFormat

// Thumbnail related TAGs

  PropertyTagThumbnailImageWidth       = $5020;  // Thumbnail width
  PropertyTagThumbnailImageHeight      = $5021;  // Thumbnail height
  PropertyTagThumbnailBitsPerSample    = $5022;  // Number of bits per
                                                 // component
  PropertyTagThumbnailCompression      = $5023;  // Compression Scheme
  PropertyTagThumbnailPhotometricInterp = $5024; // Pixel composition
  PropertyTagThumbnailImageDescription = $5025;  // Image Tile
  PropertyTagThumbnailEquipMake        = $5026;  // Manufacturer of Image
                                                 // Input equipment
  PropertyTagThumbnailEquipModel       = $5027;  // Model of Image input
                                                 // equipment
  PropertyTagThumbnailStripOffsets     = $5028;  // Image data location
  PropertyTagThumbnailOrientation      = $5029;  // Orientation of image
  PropertyTagThumbnailSamplesPerPixel  = $502A;  // Number of components
  PropertyTagThumbnailRowsPerStrip     = $502B;  // Number of rows per strip
  PropertyTagThumbnailStripBytesCount  = $502C;  // Bytes per compressed
                                                 // strip
  PropertyTagThumbnailResolutionX      = $502D;  // Resolution in width
                                                 // direction
  PropertyTagThumbnailResolutionY      = $502E;  // Resolution in height
                                                 // direction
  PropertyTagThumbnailPlanarConfig     = $502F;  // Image data arrangement
  PropertyTagThumbnailResolutionUnit   = $5030;  // Unit of X and Y
                                                 // Resolution
  PropertyTagThumbnailTransferFunction = $5031;  // Transfer function
  PropertyTagThumbnailSoftwareUsed     = $5032;  // Software used
  PropertyTagThumbnailDateTime         = $5033;  // File change date and
                                                 // time
  PropertyTagThumbnailArtist           = $5034;  // Person who created the
                                                 // image
  PropertyTagThumbnailWhitePoint       = $5035;  // White point chromaticity
  PropertyTagThumbnailPrimaryChromaticities = $5036; // Chromaticities of
                                                     // primaries
  PropertyTagThumbnailYCbCrCoefficients = $5037; // Color space transforma-
                                                 // tion coefficients
  PropertyTagThumbnailYCbCrSubsampling = $5038;  // Subsampling ratio of Y
                                                 // to C
  PropertyTagThumbnailYCbCrPositioning = $5039;  // Y and C position
  PropertyTagThumbnailRefBlackWhite    = $503A;  // Pair of black and white
                                                 // reference values
  PropertyTagThumbnailCopyRight        = $503B;  // CopyRight holder

  PropertyTagLuminanceTable            = $5090;
  PropertyTagChrominanceTable          = $5091;

  PropertyTagFrameDelay                = $5100;
  PropertyTagLoopCount                 = $5101;

  {$IF (GDIPVER >= $0110)}
  PropertyTagGlobalPalette             = $5102;
  PropertyTagIndexBackground           = $5103;
  PropertyTagIndexTransparent          = $5104;
  {$IFEND}

  PropertyTagPixelUnit         = $5110;  // Unit specifier for pixel/unit
  PropertyTagPixelPerUnitX     = $5111;  // Pixels per unit in X
  PropertyTagPixelPerUnitY     = $5112;  // Pixels per unit in Y
  PropertyTagPaletteHistogram  = $5113;  // Palette histogram

// EXIF specific tag

  PropertyTagExifExposureTime  = $829A;
  PropertyTagExifFNumber       = $829D;

  PropertyTagExifExposureProg  = $8822;
  PropertyTagExifSpectralSense = $8824;
  PropertyTagExifISOSpeed      = $8827;
  PropertyTagExifOECF          = $8828;

  PropertyTagExifVer            = $9000;
  PropertyTagExifDTOrig         = $9003; // Date & time of original
  PropertyTagExifDTDigitized    = $9004; // Date & time of digital data generation

  PropertyTagExifCompConfig     = $9101;
  PropertyTagExifCompBPP        = $9102;

  PropertyTagExifShutterSpeed   = $9201;
  PropertyTagExifAperture       = $9202;
  PropertyTagExifBrightness     = $9203;
  PropertyTagExifExposureBias   = $9204;
  PropertyTagExifMaxAperture    = $9205;
  PropertyTagExifSubjectDist    = $9206;
  PropertyTagExifMeteringMode   = $9207;
  PropertyTagExifLightSource    = $9208;
  PropertyTagExifFlash          = $9209;
  PropertyTagExifFocalLength    = $920A;
  PropertyTagExifSubjectArea    = $9214;  // exif 2.2 Subject Area
  PropertyTagExifMakerNote      = $927C;
  PropertyTagExifUserComment    = $9286;
  PropertyTagExifDTSubsec       = $9290;  // Date & Time subseconds
  PropertyTagExifDTOrigSS       = $9291;  // Date & Time original subseconds
  PropertyTagExifDTDigSS        = $9292;  // Date & TIme digitized subseconds

  PropertyTagExifFPXVer         = $A000;
  PropertyTagExifColorSpace     = $A001;
  PropertyTagExifPixXDim        = $A002;
  PropertyTagExifPixYDim        = $A003;
  PropertyTagExifRelatedWav     = $A004;  // related sound file
  PropertyTagExifInterop        = $A005;
  PropertyTagExifFlashEnergy    = $A20B;
  PropertyTagExifSpatialFR      = $A20C;  // Spatial Frequency Response
  PropertyTagExifFocalXRes      = $A20E;  // Focal Plane X Resolution
  PropertyTagExifFocalYRes      = $A20F;  // Focal Plane Y Resolution
  PropertyTagExifFocalResUnit   = $A210;  // Focal Plane Resolution Unit
  PropertyTagExifSubjectLoc     = $A214;
  PropertyTagExifExposureIndex  = $A215;
  PropertyTagExifSensingMethod  = $A217;
  PropertyTagExifFileSource     = $A300;
  PropertyTagExifSceneType      = $A301;
  PropertyTagExifCfaPattern     = $A302;

// New EXIF 2.2 properties

  PropertyTagExifCustomRendered           = $A401;
  PropertyTagExifExposureMode             = $A402;
  PropertyTagExifWhiteBalance             = $A403;
  PropertyTagExifDigitalZoomRatio         = $A404;
  PropertyTagExifFocalLengthIn35mmFilm    = $A405;
  PropertyTagExifSceneCaptureType         = $A406;
  PropertyTagExifGainControl              = $A407;
  PropertyTagExifContrast                 = $A408;
  PropertyTagExifSaturation               = $A409;
  PropertyTagExifSharpness                = $A40A;
  PropertyTagExifDeviceSettingDesc        = $A40B;
  PropertyTagExifSubjectDistanceRange     = $A40C;
  PropertyTagExifUniqueImageID            = $A420;


  PropertyTagGpsVer             = $0000;
  PropertyTagGpsLatitudeRef     = $0001;
  PropertyTagGpsLatitude        = $0002;
  PropertyTagGpsLongitudeRef    = $0003;
  PropertyTagGpsLongitude       = $0004;
  PropertyTagGpsAltitudeRef     = $0005;
  PropertyTagGpsAltitude        = $0006;
  PropertyTagGpsGpsTime         = $0007;
  PropertyTagGpsGpsSatellites   = $0008;
  PropertyTagGpsGpsStatus       = $0009;
  PropertyTagGpsGpsMeasureMode  = $000A ;
  PropertyTagGpsGpsDop          = $000B;  // Measurement precision
  PropertyTagGpsSpeedRef        = $000C;
  PropertyTagGpsSpeed           = $000D;
  PropertyTagGpsTrackRef        = $000E;
  PropertyTagGpsTrack           = $000F;
  PropertyTagGpsImgDirRef       = $0010;
  PropertyTagGpsImgDir          = $0011;
  PropertyTagGpsMapDatum        = $0012;
  PropertyTagGpsDestLatRef      = $0013;
  PropertyTagGpsDestLat         = $0014;
  PropertyTagGpsDestLongRef     = $0015;
  PropertyTagGpsDestLong        = $0016;
  PropertyTagGpsDestBearRef     = $0017;
  PropertyTagGpsDestBear        = $0018;
  PropertyTagGpsDestDistRef     = $0019;
  PropertyTagGpsDestDist        = $001A;
  PropertyTagGpsProcessingMethod = $001B;
  PropertyTagGpsAreaInformation = $001C;
  PropertyTagGpsDate            = $001D;
  PropertyTagGpsDifferential    = $001E;
{$ENDREGION 'GdiplusImaging.h'}

{$REGION 'GdiplusColorMatrix.h'}
(*****************************************************************************
 * GdiplusColorMatrix.h
 * GDI+ Color Matrix object, used with Graphics.DrawImage
 *****************************************************************************)

{$IF (GDIPVER >= $0110)}
//----------------------------------------------------------------------------
// Color channel look up table (LUT)
//----------------------------------------------------------------------------

type
  TGPColorChannelLUT = array [0..255] of Byte;

//----------------------------------------------------------------------------
// Per-channel Histogram for 8bpp images.
//----------------------------------------------------------------------------

type
  TGPHistogramFormat = (
    HistogramFormatARGB,
    HistogramFormatPARGB,
    HistogramFormatRGB,
    HistogramFormatGray,
    HistogramFormatB,
    HistogramFormatG,
    HistogramFormatR,
    HistogramFormatA);
{$IFEND}

//----------------------------------------------------------------------------
// Color matrix
//----------------------------------------------------------------------------

type
  TGPColorMatrix = record
  public
    M: array [0..4, 0..4] of Single;
  public
    procedure SetToIdentity;
  end;
  PGPColorMatrix = ^TGPColorMatrix;

//----------------------------------------------------------------------------
// Color Matrix flags
//----------------------------------------------------------------------------

type
  TGPColorMatrixFlags = (
    ColorMatrixFlagsDefault   = 0,
    ColorMatrixFlagsSkipGrays = 1,
    ColorMatrixFlagsAltGray   = 2);

//----------------------------------------------------------------------------
// Color Adjust Type
//----------------------------------------------------------------------------

type
  TGPColorAdjustType = (
    ColorAdjustTypeDefault,
    ColorAdjustTypeBitmap,
    ColorAdjustTypeBrush,
    ColorAdjustTypePen,
    ColorAdjustTypeText,
    ColorAdjustTypeCount,
    ColorAdjustTypeAny);  // Reserved

//----------------------------------------------------------------------------
// Color Map
//----------------------------------------------------------------------------

type
  TGPColorMap = record
    OldColor: TGPColor;
    NewColor: TGPColor;
  end;
  PGPColorMap = ^TGPColorMap;

{$ENDREGION 'GdiplusColorMatrix.h'}

{$REGION 'GdiplusEffects.h'}
{$IF (GDIPVER >= $0110)}
(*****************************************************************************
 * GdiplusEffects.h
 * Gdiplus effect objects
 *****************************************************************************)
//-----------------------------------------------------------------------------
// GDI+ effect GUIDs
//-----------------------------------------------------------------------------

const
  BlurEffectGuid                  : TGUID = '{633C80A4-1843-482b-9EF2-BE2834C5FDD4}';
  SharpenEffectGuid               : TGUID = '{63CBF3EE-C526-402c-8F71-62C540BF5142}';
  ColorMatrixEffectGuid           : TGUID = '{718F2615-7933-40e3-A511-5F68FE14DD74}';
  ColorLUTEffectGuid              : TGUID = '{A7CE72A9-0F7F-40d7-B3CC-D0C02D5C3212}';
  BrightnessContrastEffectGuid    : TGUID = '{D3A1DBE1-8EC4-4c17-9F4C-EA97AD1C343D}';
  HueSaturationLightnessEffectGuid: TGUID = '{8B2DD6C3-EB07-4d87-A5F0-7108E26A9C5F}';
  LevelsEffectGuid                : TGUID = '{99C354EC-2A31-4f3a-8C34-17A803B33A25}';
  TintEffectGuid                  : TGUID = '{1077AF00-2848-4441-9489-44AD4C2D7A2C}';
  ColorBalanceEffectGuid          : TGUID = '{537E597D-251E-48da-9664-29CA496B70F8}';
  RedEyeCorrectionEffectGuid      : TGUID = '{74D29D05-69A4-4266-9549-3CC52836B632}';
  ColorCurveEffectGuid            : TGUID = '{DD6A0022-58E4-4a67-9D9B-D48EB881A53D}';

//-----------------------------------------------------------------------------

type
  TGPSharpenParams = record
  public
    Radius: Single;
    Amount: Single;
  end;
  PGPSharpenParams = ^TGPSharpenParams;

type
  TGPBlurParams = record
  public
    Radius: Single;
    ExpandEdge: BOOL;
  end;
  PGPBlurParams = ^TGPBlurParams;

type
  TGPBrightnessContrastParams = record
  public
    BrightnessLevel: Integer;
    ContrastLevel: Integer;
  end;
  PGPBrightnessContrastParams = ^TGPBrightnessContrastParams;

type
  TGPRedEyeCorrectionParams = record
  public
    NumberOfAreas: Cardinal;
    Areas: Windows.PRect;
  end;
  PGPRedEyeCorrectionParams = ^TGPRedEyeCorrectionParams;

type
  TGPHueSaturationLightnessParams = record
  public
    HueLevel: Integer;
    SaturationLevel: Integer;
    LightnessLevel: Integer;
  end;
  PGPHueSaturationLightnessParams = ^TGPHueSaturationLightnessParams;

type
  TGPTintParams = record
  public
    Hue: Integer;
    Amount: Integer;
  end;
  PGPTintParams = ^TGPTintParams;

type
  TGPLevelsParams = record
  public
    Highlight: Integer;
    Midtone: Integer;
    Shadow: Integer;
  end;
  PGPLevelsParams = ^TGPLevelsParams;

type
  TGPColorBalanceParams = record
  public
    CyanRed: Integer;
    MagentaGreen: Integer;
    YellowBlue: Integer;
  end;
  PGPColorBalanceParams = ^TGPColorBalanceParams;

type
  TGPColorLUTParams = record
    // look up tables for each color channel.

    LutB: TGPColorChannelLUT;
    LutG: TGPColorChannelLUT;
    LutR: TGPColorChannelLUT;
    LutA: TGPColorChannelLUT;
  end;
  PGPColorLUTParams = ^TGPColorLUTParams;

type
  TGPCurveAdjustments = (
    AdjustExposure,
    AdjustDensity,
    AdjustContrast,
    AdjustHighlight,
    AdjustShadow,
    AdjustMidtone,
    AdjustWhiteSaturation,
    AdjustBlackSaturation);

type
  TGPCurveChannel = (
    CurveChannelAll,
    CurveChannelRed,
    CurveChannelGreen,
    CurveChannelBlue);

type
  TGPColorCurveParams = record
  public
    Adjustment: TGPCurveAdjustments;
    Channel: TGPCurveChannel;
    AdjustValue: Integer;
  end;
  PGPColorCurveParams = ^TGPColorCurveParams;

type
  CGpEffect = Pointer;

function GdipCreateEffect(Guid: TGUID;
  out Effect: CGpEffect): TGPStatus; stdcall; external GdiPlusDll;

function GdipDeleteEffect(Effect: CGpEffect): TGPStatus; stdcall; external GdiPlusDll;

function GdipGetEffectParameterSize(Effect: CGpEffect;
  out Size: UINT): TGPStatus; stdcall; external GdiPlusDll;

function GdipSetEffectParameters(Effect: CGpEffect; const Params: Pointer;
  const Size: UINT): TGPStatus; stdcall; external GdiPlusDll;

function GdipGetEffectParameters(Effect: CGpEffect; var Size: UINT;
  Params: Pointer): TGPStatus; stdcall; external GdiPlusDll;

type
  IGPEffect = interface(IGdiPlusBase)
  ['{446CEE9F-25A0-400F-8599-3905CBE4828A}']
    { Property access methods }
    function GetAuxDataSize: Integer;
    function GetAuxData: Pointer;
    function GetUseAuxData: Boolean;
    procedure SetUseAuxData(const Value: Boolean);
    function GetParameterSize: Cardinal;

    { Methods }
    procedure ReleaseAuxData;
    procedure SetAuxData(const Data: Pointer; const Size: Integer);

    { Properties }
    property AuxDataSize: Integer read GetAuxDataSize;
    property AuxData: Pointer read GetAuxData;
    property UseAuxData: Boolean read GetUseAuxData write SetUseAuxData;
    property ParameterSize: Cardinal read GetParameterSize;
  end;

  TGPEffect = class(TGdiplusBase, IGPEffect)
  private
    FAuxDataSize: Integer;
    FAuxData: Pointer;
    FUseAuxData: Boolean;
  private
    { IGPEffect }
    function GetAuxDataSize: Integer;
    function GetAuxData: Pointer;
    function GetUseAuxData: Boolean;
    procedure SetUseAuxData(const Value: Boolean);
    function GetParameterSize: Cardinal;
    procedure ReleaseAuxData;
    procedure SetAuxData(const Data: Pointer; const Size: Integer);
  protected
    procedure SetParameters(const Params: Pointer; const Size: Cardinal);
    procedure GetParameters(var Size: Cardinal; Params: Pointer);
  public
    destructor Destroy; override;
  end;

type
  // Blur
  IGPBlur = interface(IGPEffect)
  ['{8F6EFDE6-E905-4886-8386-8BE9E92545E5}']
    { Property access methods }
    function GetParameters: TGPBlurParams;
    procedure SetParameters(const Value: TGPBlurParams);

    { Properties }
    property Parameters: TGPBlurParams read GetParameters write SetParameters;
  end;

  TGPBlur = class(TGPEffect, IGPBlur)
  private
    { IGPBlur }
    function GetParameters: TGPBlurParams;
    procedure SetParameters(const Value: TGPBlurParams);
  public
    constructor Create;
  end;

type
  // Sharpen
  IGPSharpen = interface(IGPEffect)
  ['{D5276FFC-FB19-4DCC-9FBB-DC5142DDE65E}']
    { Property access methods }
    function GetParameters: TGPSharpenParams;
    procedure SetParameters(const Value: TGPSharpenParams);

    { Properties }
    property Parameters: TGPSharpenParams read GetParameters write SetParameters;
  end;

  TGPSharpen = class(TGPEffect, IGPSharpen)
  private
    { IGPSharpen }
    function GetParameters: TGPSharpenParams;
    procedure SetParameters(const Value: TGPSharpenParams);
  public
    constructor Create;
  end;

type
  // RedEye Correction
  IGPRedEyeCorrection = interface(IGPEffect)
  ['{055F978A-DB24-48C9-B87E-BA5616809566}']
    { Property access methods }
    function GetParameters: TGPRedEyeCorrectionParams;
    procedure SetParameters(const Value: TGPRedEyeCorrectionParams);

    { Properties }
    property Parameters: TGPRedEyeCorrectionParams read GetParameters write SetParameters;
  end;

  TGPRedEyeCorrection = class(TGPEffect, IGPRedEyeCorrection)
  private
    { IGPRedEyeCorrection }
    function GetParameters: TGPRedEyeCorrectionParams;
    procedure SetParameters(const Value: TGPRedEyeCorrectionParams);
  public
    constructor Create;
  end;

type
  // Brightness/Contrast
  IGPBrightnessContrast = interface(IGPEffect)
  ['{3216DA55-5C78-4376-B693-E538E757118E}']
    { Property access methods }
    function GetParameters: TGPBrightnessContrastParams;
    procedure SetParameters(const Value: TGPBrightnessContrastParams);

    { Properties }
    property Parameters: TGPBrightnessContrastParams read GetParameters write SetParameters;
  end;

  TGPBrightnessContrast = class(TGPEffect, IGPBrightnessContrast)
  private
    { IGPBrightnessContrast }
    function GetParameters: TGPBrightnessContrastParams;
    procedure SetParameters(const Value: TGPBrightnessContrastParams);
  public
    constructor Create;
  end;

type
  // Hue/Saturation/Lightness
  IGPHueSaturationLightness = interface(IGPEffect)
  ['{7DFF5E66-E1FB-4441-B78A-03423A1AB3CC}']
    { Property access methods }
    function GetParameters: TGPHueSaturationLightnessParams;
    procedure SetParameters(const Value: TGPHueSaturationLightnessParams);

    { Properties }
    property Parameters: TGPHueSaturationLightnessParams read GetParameters write SetParameters;
  end;

  TGPHueSaturationLightness = class(TGPEffect, IGPHueSaturationLightness)
  private
    { IGPHueSaturationLightness }
    function GetParameters: TGPHueSaturationLightnessParams;
    procedure SetParameters(const Value: TGPHueSaturationLightnessParams);
  public
    constructor Create;
  end;

type
  // Highlight/Midtone/Shadow curves
  IGPLevels = interface(IGPEffect)
  ['{A4770860-C2CA-47EB-AF07-91F85B2FD0FC}']
    { Property access methods }
    function GetParameters: TGPLevelsParams;
    procedure SetParameters(const Value: TGPLevelsParams);

    { Properties }
    property Parameters: TGPLevelsParams read GetParameters write SetParameters;
  end;

  TGPLevels = class(TGPEffect, IGPLevels)
  private
    { IGPLevels }
    function GetParameters: TGPLevelsParams;
    procedure SetParameters(const Value: TGPLevelsParams);
  public
    constructor Create;
  end;

type
  // Tint
  IGPTint = interface(IGPEffect)
  ['{EEBFC517-2FC5-4164-860A-C133C1D15541}']
    { Property access methods }
    function GetParameters: TGPTintParams;
    procedure SetParameters(const Value: TGPTintParams);

    { Properties }
    property Parameters: TGPTintParams read GetParameters write SetParameters;
  end;

  TGPTint = class(TGPEffect, IGPTint)
  private
    { IGPTint }
    function GetParameters: TGPTintParams;
    procedure SetParameters(const Value: TGPTintParams);
  public
    constructor Create;
  end;

type
  // ColorBalance
  IGPColorBalance = interface(IGPEffect)
  ['{951B7FA7-239E-402E-B20F-DC1058A93B38}']
    { Property access methods }
    function GetParameters: TGPColorBalanceParams;
    procedure SetParameters(const Value: TGPColorBalanceParams);

    { Properties }
    property Parameters: TGPColorBalanceParams read GetParameters write SetParameters;
  end;

  TGPColorBalance = class(TGPEffect, IGPColorBalance)
  private
    { IGPColorBalance }
    function GetParameters: TGPColorBalanceParams;
    procedure SetParameters(const Value: TGPColorBalanceParams);
  public
    constructor Create;
  end;

type
  // ColorMatrix
  IGPColorMatrixEffect = interface(IGPEffect)
  ['{492E9124-97C2-45AD-BC4E-699F75C62AF4}']
    { Property access methods }
    function GetParameters: TGPColorMatrix;
    procedure SetParameters(const Value: TGPColorMatrix);

    { Properties }
    property Parameters: TGPColorMatrix read GetParameters write SetParameters;
  end;

  TGPColorMatrixEffect = class(TGPEffect, IGPColorMatrixEffect)
  private
    { IGPColorMatrixEffect }
    function GetParameters: TGPColorMatrix;
    procedure SetParameters(const Value: TGPColorMatrix);
  public
    constructor Create;
  end;

type
  // ColorLUT
  IGPColorLUT = interface(IGPEffect)
  ['{4846B6A9-7A08-4A09-B599-963588A77C14}']
    { Property access methods }
    function GetParameters: TGPColorLUTParams;
    procedure SetParameters(const Value: TGPColorLUTParams);

    { Properties }
    property Parameters: TGPColorLUTParams read GetParameters write SetParameters;
  end;

  TGPColorLUT = class(TGPEffect, IGPColorLUT)
  private
    { IGPColorLUT }
    function GetParameters: TGPColorLUTParams;
    procedure SetParameters(const Value: TGPColorLUTParams);
  public
    constructor Create;
  end;

type
  // Color Curve
  IGPColorCurve = interface(IGPEffect)
  ['{710EE23F-A7A0-43E4-9551-51EA66E12773}']
    { Property access methods }
    function GetParameters: TGPColorCurveParams;
    procedure SetParameters(const Value: TGPColorCurveParams);

    { Properties }
    property Parameters: TGPColorCurveParams read GetParameters write SetParameters;
  end;

  TGPColorCurve = class(TGPEffect, IGPColorCurve)
  private
    { IGPColorCurve }
    function GetParameters: TGPColorCurveParams;
    procedure SetParameters(const Value: TGPColorCurveParams);
  public
    constructor Create;
  end;
{$IFEND}
{$ENDREGION 'GdiplusEffects.h'}

{$REGION 'GdiplusGpStubs.h (1)'}
(*****************************************************************************
 * GdiplusGpStubs.h
 * Private GDI+ header file.
 *****************************************************************************)

//---------------------------------------------------------------------------
// Private GDI+ classes for internal type checking
//---------------------------------------------------------------------------

  GpGraphics = Pointer;

  GpBrush = Pointer;
  GpTexture = Pointer;
  GpSolidFill = Pointer;
  GpLineGradient = Pointer;
  GpPathGradient = Pointer;
  GpHatch = Pointer;

  GpPen = Pointer;
  GpCustomLineCap = Pointer;
  GpAdjustableArrowCap = Pointer;

  GpImage = Pointer;
  GpBitmap = Pointer;
  PGpBitmap = ^GpBitmap;
  GpMetafile = Pointer;
  GpImageAttributes = Pointer;

  GpPath = Pointer;
  GpRegion = Pointer;
  PGpRegion = ^GpRegion;
  GpPathIterator = Pointer;

  GpFontFamily = Pointer;
  PGpFontFamily = ^GpFontFamily;
  GpFont = Pointer;
  GpStringFormat = Pointer;
  GpFontCollection = Pointer;
  GpInstalledFontCollection = Pointer;
  GpPrivateFontCollection = Pointer;

  GpCachedBitmap = Pointer;

  GpMatrix = Pointer;

{$ENDREGION 'GdiplusGpStubs.h (1)'}

{$REGION 'GdiplusFlat.h'}
(*****************************************************************************
 * GdiplusFlat.h
 * Private GDI+ header file.
 *****************************************************************************)

//----------------------------------------------------------------------------
// GraphicsPath APIs
//----------------------------------------------------------------------------

{ GdipCreatePath(GpFillMode brushMode, GpPath **path); }
function GdipCreatePath(BrushMode: TGPFillMode; out Path: GpPath): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipCreatePath2(GDIPCONST GpPointF*, GDIPCONST BYTE*, INT, GpFillMode, GpPath **path); }
function GdipCreatePath2(const Param1: PGPPointF; const Param2: PByte;
  Param3: Integer; Param4: TGPFillMode; out Path: GpPath): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipCreatePath2I(GDIPCONST GpPoint*, GDIPCONST BYTE*, INT, GpFillMode, GpPath **path); }
function GdipCreatePath2I(const Param1: PGPPoint; const Param2: PByte;
  Param3: Integer; Param4: TGPFillMode; out Path: GpPath): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipClonePath(GpPath* path, GpPath **clonePath); }
function GdipClonePath(Path: GpPath; out ClonePath: GpPath): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipDeletePath(GpPath* path); }
function GdipDeletePath(Path: GpPath): TGPStatus; stdcall; external GdiPlusDll;

{ GdipResetPath(GpPath* path); }
function GdipResetPath(Path: GpPath): TGPStatus; stdcall; external GdiPlusDll;

{ GdipGetPointCount(GpPath* path, INT* count); }
function GdipGetPointCount(Path: GpPath; out Count: Integer): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetPathTypes(GpPath* path, BYTE* types, INT count); }
function GdipGetPathTypes(Path: GpPath; Types: PByte; Count: Integer): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetPathPoints(GpPath*, GpPointF* points, INT count); }
function GdipGetPathPoints(Path: GpPath; Points: PGPPointF; Count: Integer): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetPathPointsI(GpPath*, GpPoint* points, INT count); }
function GdipGetPathPointsI(Path: GpPath; Points: PGPPoint; Count: Integer): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetPathFillMode(GpPath *path, GpFillMode *fillmode); }
function GdipGetPathFillMode(Path: GpPath; out Fillmode: TGPFillMode): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipSetPathFillMode(GpPath *path, GpFillMode fillmode); }
function GdipSetPathFillMode(Path: GpPath; Fillmode: TGPFillMode): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetPathData(GpPath *path, GpPathData* pathData); }
function GdipGetPathData(Path: GpPath; PathData: PGPNativePathData): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipStartPathFigure(GpPath *path); }
function GdipStartPathFigure(Path: GpPath): TGPStatus; stdcall; external GdiPlusDll;

{ GdipClosePathFigure(GpPath *path); }
function GdipClosePathFigure(Path: GpPath): TGPStatus; stdcall; external GdiPlusDll;

{ GdipClosePathFigures(GpPath *path); }
function GdipClosePathFigures(Path: GpPath): TGPStatus; stdcall; external GdiPlusDll;

{ GdipSetPathMarker(GpPath* path); }
function GdipSetPathMarker(Path: GpPath): TGPStatus; stdcall; external GdiPlusDll;

{ GdipClearPathMarkers(GpPath* path); }
function GdipClearPathMarkers(Path: GpPath): TGPStatus; stdcall; external GdiPlusDll;

{ GdipReversePath(GpPath* path); }
function GdipReversePath(Path: GpPath): TGPStatus; stdcall; external GdiPlusDll;

{ GdipGetPathLastPoint(GpPath* path, GpPointF* lastPoint); }
function GdipGetPathLastPoint(Path: GpPath; out LastPoint: TGPPointF): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipAddPathLine(GpPath *path, REAL x1, REAL y1, REAL x2, REAL y2); }
function GdipAddPathLine(Path: GpPath; X1: Single; Y1: Single; X2: Single;
  Y2: Single): TGPStatus; stdcall; external GdiPlusDll;

{ GdipAddPathLine2(GpPath *path, GDIPCONST GpPointF *points, INT count); }
function GdipAddPathLine2(Path: GpPath; const Points: PGPPointF; Count: Integer): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipAddPathArc(GpPath *path, REAL x, REAL y, REAL width, REAL height, REAL startAngle, REAL sweepAngle); }
function GdipAddPathArc(Path: GpPath; X: Single; Y: Single; Width: Single;
  Height: Single; StartAngle: Single; SweepAngle: Single): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipAddPathBezier(GpPath *path, REAL x1, REAL y1, REAL x2, REAL y2, REAL x3, REAL y3, REAL x4, REAL y4); }
function GdipAddPathBezier(Path: GpPath; X1: Single; Y1: Single; X2: Single;
  Y2: Single; X3: Single; Y3: Single; X4: Single; Y4: Single): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipAddPathBeziers(GpPath *path, GDIPCONST GpPointF *points, INT count); }
function GdipAddPathBeziers(Path: GpPath; const Points: PGPPointF; Count: Integer): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipAddPathCurve(GpPath *path, GDIPCONST GpPointF *points, INT count); }
function GdipAddPathCurve(Path: GpPath; const Points: PGPPointF; Count: Integer): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipAddPathCurve2(GpPath *path, GDIPCONST GpPointF *points, INT count, REAL tension); }
function GdipAddPathCurve2(Path: GpPath; const Points: PGPPointF; Count: Integer;
  Tension: Single): TGPStatus; stdcall; external GdiPlusDll;

{ GdipAddPathCurve3(GpPath *path, GDIPCONST GpPointF *points, INT count, INT offset, INT numberOfSegments, REAL tension); }
function GdipAddPathCurve3(Path: GpPath; const Points: PGPPointF; Count: Integer;
  Offset: Integer; NumberOfSegments: Integer; Tension: Single): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipAddPathClosedCurve(GpPath *path, GDIPCONST GpPointF *points, INT count); }
function GdipAddPathClosedCurve(Path: GpPath; const Points: PGPPointF;
  Count: Integer): TGPStatus; stdcall; external GdiPlusDll;

{ GdipAddPathClosedCurve2(GpPath *path, GDIPCONST GpPointF *points, INT count, REAL tension); }
function GdipAddPathClosedCurve2(Path: GpPath; const Points: PGPPointF;
  Count: Integer; Tension: Single): TGPStatus; stdcall; external GdiPlusDll;

{ GdipAddPathRectangle(GpPath *path, REAL x, REAL y, REAL width, REAL height); }
function GdipAddPathRectangle(Path: GpPath; X: Single; Y: Single; Width: Single;
  Height: Single): TGPStatus; stdcall; external GdiPlusDll;

{ GdipAddPathRectangles(GpPath *path, GDIPCONST GpRectF *rects, INT count); }
function GdipAddPathRectangles(Path: GpPath; const Rects: PGPRectF;
  Count: Integer): TGPStatus; stdcall; external GdiPlusDll;

{ GdipAddPathEllipse(GpPath *path, REAL x, REAL y, REAL width, REAL height); }
function GdipAddPathEllipse(Path: GpPath; X: Single; Y: Single; Width: Single;
  Height: Single): TGPStatus; stdcall; external GdiPlusDll;

{ GdipAddPathPie(GpPath *path, REAL x, REAL y, REAL width, REAL height, REAL startAngle, REAL sweepAngle); }
function GdipAddPathPie(Path: GpPath; X: Single; Y: Single; Width: Single;
  Height: Single; StartAngle: Single; SweepAngle: Single): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipAddPathPolygon(GpPath *path, GDIPCONST GpPointF *points, INT count); }
function GdipAddPathPolygon(Path: GpPath; const Points: PGPPointF; Count: Integer): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipAddPathPath(GpPath *path, GDIPCONST GpPath* addingPath, BOOL connect); }
function GdipAddPathPath(Path: GpPath; const AddingPath: GpPath; Connect: Bool): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipAddPathString(GpPath *path, GDIPCONST WCHAR *string, INT length, GDIPCONST GpFontFamily *family, INT style, REAL emSize, GDIPCONST RectF *layoutRect, GDIPCONST GpStringFormat *format); }
function GdipAddPathString(Path: GpPath; const Str: PWideChar; Length: Integer;
  const Family: GpFontFamily; Style: TGPFontStyle; EmSize: Single;
  const LayoutRect: PGPRectF; const Format: GpStringFormat): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipAddPathStringI(GpPath *path, GDIPCONST WCHAR *string, INT length, GDIPCONST GpFontFamily *family, INT style, REAL emSize, GDIPCONST Rect *layoutRect, GDIPCONST GpStringFormat *format); }
function GdipAddPathStringI(Path: GpPath; const Str: PWideChar; Length: Integer;
  const Family: GpFontFamily; Style: TGPFontStyle; EmSize: Single;
  const LayoutRect: PGPRect; const Format: GpStringFormat): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipAddPathLineI(GpPath *path, INT x1, INT y1, INT x2, INT y2); }
function GdipAddPathLineI(Path: GpPath; X1: Integer; Y1: Integer; X2: Integer;
  Y2: Integer): TGPStatus; stdcall; external GdiPlusDll;

{ GdipAddPathLine2I(GpPath *path, GDIPCONST GpPoint *points, INT count); }
function GdipAddPathLine2I(Path: GpPath; const Points: PGPPoint; Count: Integer): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipAddPathArcI(GpPath *path, INT x, INT y, INT width, INT height, REAL startAngle, REAL sweepAngle); }
function GdipAddPathArcI(Path: GpPath; X: Integer; Y: Integer; Width: Integer;
  Height: Integer; StartAngle: Single; SweepAngle: Single): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipAddPathBezierI(GpPath *path, INT x1, INT y1, INT x2, INT y2, INT x3, INT y3, INT x4, INT y4); }
function GdipAddPathBezierI(Path: GpPath; X1: Integer; Y1: Integer; X2: Integer;
  Y2: Integer; X3: Integer; Y3: Integer; X4: Integer; Y4: Integer): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipAddPathBeziersI(GpPath *path, GDIPCONST GpPoint *points, INT count); }
function GdipAddPathBeziersI(Path: GpPath; const Points: PGPPoint; Count: Integer): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipAddPathCurveI(GpPath *path, GDIPCONST GpPoint *points, INT count); }
function GdipAddPathCurveI(Path: GpPath; const Points: PGPPoint; Count: Integer): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipAddPathCurve2I(GpPath *path, GDIPCONST GpPoint *points, INT count, REAL tension); }
function GdipAddPathCurve2I(Path: GpPath; const Points: PGPPoint; Count: Integer;
  Tension: Single): TGPStatus; stdcall; external GdiPlusDll;

{ GdipAddPathCurve3I(GpPath *path, GDIPCONST GpPoint *points, INT count, INT offset, INT numberOfSegments, REAL tension); }
function GdipAddPathCurve3I(Path: GpPath; const Points: PGPPoint; Count: Integer;
  Offset: Integer; NumberOfSegments: Integer; Tension: Single): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipAddPathClosedCurveI(GpPath *path, GDIPCONST GpPoint *points, INT count); }
function GdipAddPathClosedCurveI(Path: GpPath; const Points: PGPPoint;
  Count: Integer): TGPStatus; stdcall; external GdiPlusDll;

{ GdipAddPathClosedCurve2I(GpPath *path, GDIPCONST GpPoint *points, INT count, REAL tension); }
function GdipAddPathClosedCurve2I(Path: GpPath; const Points: PGPPoint;
  Count: Integer; Tension: Single): TGPStatus; stdcall; external GdiPlusDll;

{ GdipAddPathRectangleI(GpPath *path, INT x, INT y, INT width, INT height); }
function GdipAddPathRectangleI(Path: GpPath; X: Integer; Y: Integer;
  Width: Integer; Height: Integer): TGPStatus; stdcall; external GdiPlusDll;

{ GdipAddPathRectanglesI(GpPath *path, GDIPCONST GpRect *rects, INT count); }
function GdipAddPathRectanglesI(Path: GpPath; const Rects: PGPRect;
  Count: Integer): TGPStatus; stdcall; external GdiPlusDll;

{ GdipAddPathEllipseI(GpPath *path, INT x, INT y, INT width, INT height); }
function GdipAddPathEllipseI(Path: GpPath; X: Integer; Y: Integer;
  Width: Integer; Height: Integer): TGPStatus; stdcall; external GdiPlusDll;

{ GdipAddPathPieI(GpPath *path, INT x, INT y, INT width, INT height, REAL startAngle, REAL sweepAngle); }
function GdipAddPathPieI(Path: GpPath; X: Integer; Y: Integer; Width: Integer;
  Height: Integer; StartAngle: Single; SweepAngle: Single): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipAddPathPolygonI(GpPath *path, GDIPCONST GpPoint *points, INT count); }
function GdipAddPathPolygonI(Path: GpPath; const Points: PGPPoint; Count: Integer): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipFlattenPath(GpPath *path, GpMatrix* matrix, REAL flatness); }
function GdipFlattenPath(Path: GpPath; Matrix: GpMatrix; Flatness: Single): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipWindingModeOutline( GpPath *path, GpMatrix *matrix, REAL flatness ); }
function GdipWindingModeOutline(Path: GpPath; Matrix: GpMatrix;
  Flatness: Single): TGPStatus; stdcall; external GdiPlusDll;

{ GdipWidenPath( GpPath *nativePath, GpPen *pen, GpMatrix *matrix, REAL flatness ); }
function GdipWidenPath(NativePath: GpPath; Pen: GpPen; Matrix: GpMatrix;
  Flatness: Single): TGPStatus; stdcall; external GdiPlusDll;

{ GdipWarpPath(GpPath *path, GpMatrix* matrix, GDIPCONST GpPointF *points, INT count, REAL srcx, REAL srcy, REAL srcwidth, REAL srcheight, WarpMode warpMode, REAL flatness); }
function GdipWarpPath(Path: GpPath; Matrix: GpMatrix; const Points: PGPPointF;
  Count: Integer; Srcx: Single; Srcy: Single; Srcwidth: Single;
  Srcheight: Single; WarpMode: TGPWarpMode; Flatness: Single): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipTransformPath(GpPath* path, GpMatrix* matrix); }
function GdipTransformPath(Path: GpPath; Matrix: GpMatrix): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetPathWorldBounds(GpPath* path, GpRectF* bounds, GDIPCONST GpMatrix *matrix, GDIPCONST GpPen *pen); }
function GdipGetPathWorldBounds(Path: GpPath; Bounds: PGPRectF;
  const Matrix: GpMatrix; const Pen: GpPen): TGPStatus; stdcall; external GdiPlusDll;

{ GdipGetPathWorldBoundsI(GpPath* path, GpRect* bounds, GDIPCONST GpMatrix *matrix, GDIPCONST GpPen *pen); }
function GdipGetPathWorldBoundsI(Path: GpPath; Bounds: PGPRect;
  const Matrix: GpMatrix; const Pen: GpPen): TGPStatus; stdcall; external GdiPlusDll;

{ GdipIsVisiblePathPoint(GpPath* path, REAL x, REAL y, GpGraphics *graphics, BOOL *result); }
function GdipIsVisiblePathPoint(Path: GpPath; X: Single; Y: Single;
  Graphics: GpGraphics; out Result: Bool): TGPStatus; stdcall; external GdiPlusDll;

{ GdipIsVisiblePathPointI(GpPath* path, INT x, INT y, GpGraphics *graphics, BOOL *result); }
function GdipIsVisiblePathPointI(Path: GpPath; X: Integer; Y: Integer;
  Graphics: GpGraphics; out Result: Bool): TGPStatus; stdcall; external GdiPlusDll;

{ GdipIsOutlineVisiblePathPoint(GpPath* path, REAL x, REAL y, GpPen *pen, GpGraphics *graphics, BOOL *result); }
function GdipIsOutlineVisiblePathPoint(Path: GpPath; X: Single; Y: Single;
  Pen: GpPen; Graphics: GpGraphics; out Result: Bool): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipIsOutlineVisiblePathPointI(GpPath* path, INT x, INT y, GpPen *pen, GpGraphics *graphics, BOOL *result); }
function GdipIsOutlineVisiblePathPointI(Path: GpPath; X: Integer; Y: Integer;
  Pen: GpPen; Graphics: GpGraphics; out Result: Bool): TGPStatus; stdcall;
  external GdiPlusDll;


//----------------------------------------------------------------------------
// PathIterator APIs
//----------------------------------------------------------------------------

{ GdipCreatePathIter(GpPathIterator **iterator, GpPath* path); }
function GdipCreatePathIter(out Iterator: GpPathIterator; Path: GpPath): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipDeletePathIter(GpPathIterator *iterator); }
function GdipDeletePathIter(Iterator: GpPathIterator): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipPathIterNextSubpath(GpPathIterator* iterator, INT *resultCount, INT* startIndex, INT* endIndex, BOOL* isClosed); }
function GdipPathIterNextSubpath(Iterator: GpPathIterator;
  out ResultCount: Integer; out StartIndex: Integer; out EndIndex: Integer;
  out IsClosed: Bool): TGPStatus; stdcall; external GdiPlusDll;

{ GdipPathIterNextSubpathPath(GpPathIterator* iterator, INT* resultCount, GpPath* path, BOOL* isClosed); }
function GdipPathIterNextSubpathPath(Iterator: GpPathIterator;
  out ResultCount: Integer; Path: GpPath; out IsClosed: Bool): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipPathIterNextPathType(GpPathIterator* iterator, INT* resultCount, BYTE* pathType, INT* startIndex, INT* endIndex); }
function GdipPathIterNextPathType(Iterator: GpPathIterator;
  out ResultCount: Integer; out PathType: Byte; out StartIndex: Integer;
  out EndIndex: Integer): TGPStatus; stdcall; external GdiPlusDll;

{ GdipPathIterNextMarker(GpPathIterator* iterator, INT *resultCount, INT* startIndex, INT* endIndex); }
function GdipPathIterNextMarker(Iterator: GpPathIterator; out ResultCount: Integer;
  out StartIndex: Integer; out EndIndex: Integer): TGPStatus; stdcall; external GdiPlusDll;

{ GdipPathIterNextMarkerPath(GpPathIterator* iterator, INT* resultCount, GpPath* path); }
function GdipPathIterNextMarkerPath(Iterator: GpPathIterator;
  out ResultCount: Integer; Path: GpPath): TGPStatus; stdcall; external GdiPlusDll;

{ GdipPathIterGetCount(GpPathIterator* iterator, INT* count); }
function GdipPathIterGetCount(Iterator: GpPathIterator; out Count: Integer): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipPathIterGetSubpathCount(GpPathIterator* iterator, INT* count); }
function GdipPathIterGetSubpathCount(Iterator: GpPathIterator; out Count: Integer): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipPathIterIsValid(GpPathIterator* iterator, BOOL* valid); }
function GdipPathIterIsValid(Iterator: GpPathIterator; Valid: PBool): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipPathIterHasCurve(GpPathIterator* iterator, BOOL* hasCurve); }
function GdipPathIterHasCurve(Iterator: GpPathIterator; out HasCurve: Bool): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipPathIterRewind(GpPathIterator* iterator); }
function GdipPathIterRewind(Iterator: GpPathIterator): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipPathIterEnumerate(GpPathIterator* iterator, INT* resultCount, GpPointF *points, BYTE *types, INT count); }
function GdipPathIterEnumerate(Iterator: GpPathIterator; out ResultCount: Integer;
  Points: PGPPointF; Types: PByte; Count: Integer): TGPStatus; stdcall; external GdiPlusDll;

{ GdipPathIterCopyData(GpPathIterator* iterator, INT* resultCount, GpPointF* points, BYTE* types, INT startIndex, INT endIndex); }
function GdipPathIterCopyData(Iterator: GpPathIterator; out ResultCount: Integer;
  Points: PGPPointF; Types: PByte; StartIndex: Integer; EndIndex: Integer): TGPStatus; stdcall;
  external GdiPlusDll;

//----------------------------------------------------------------------------
// Matrix APIs
//----------------------------------------------------------------------------

{ GdipCreateMatrix(GpMatrix **matrix); }
function GdipCreateMatrix(out Matrix: GpMatrix): TGPStatus; stdcall; external GdiPlusDll;

{ GdipCreateMatrix2(REAL m11, REAL m12, REAL m21, REAL m22, REAL dx, REAL dy, GpMatrix **matrix); }
function GdipCreateMatrix2(M11: Single; M12: Single; M21: Single; M22: Single;
  Dx: Single; Dy: Single; out Matrix: GpMatrix): TGPStatus; stdcall; external GdiPlusDll;

{ GdipCreateMatrix3(GDIPCONST GpRectF *rect, GDIPCONST GpPointF *dstplg, GpMatrix **matrix); }
function GdipCreateMatrix3(const Rect: PGPRectF; const Dstplg: PGPPointF;
  out Matrix: GpMatrix): TGPStatus; stdcall; external GdiPlusDll;

{ GdipCreateMatrix3I(GDIPCONST GpRect *rect, GDIPCONST GpPoint *dstplg, GpMatrix **matrix); }
function GdipCreateMatrix3I(const Rect: PGPRect; const Dstplg: PGPPoint;
  out Matrix: GpMatrix): TGPStatus; stdcall; external GdiPlusDll;

{ GdipCloneMatrix(GpMatrix *matrix, GpMatrix **cloneMatrix); }
function GdipCloneMatrix(Matrix: GpMatrix; out CloneMatrix: GpMatrix): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipDeleteMatrix(GpMatrix *matrix); }
function GdipDeleteMatrix(Matrix: GpMatrix): TGPStatus; stdcall; external GdiPlusDll;

{ GdipSetMatrixElements(GpMatrix *matrix, REAL m11, REAL m12, REAL m21, REAL m22, REAL dx, REAL dy); }
function GdipSetMatrixElements(Matrix: GpMatrix; M11: Single; M12: Single;
  M21: Single; M22: Single; Dx: Single; Dy: Single): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipMultiplyMatrix(GpMatrix *matrix, GpMatrix* matrix2, GpMatrixOrder order); }
function GdipMultiplyMatrix(Matrix: GpMatrix; Matrix2: GpMatrix;
  Order: TGPMatrixOrder): TGPStatus; stdcall; external GdiPlusDll;

{ GdipTranslateMatrix(GpMatrix *matrix, REAL offsetX, REAL offsetY, GpMatrixOrder order); }
function GdipTranslateMatrix(Matrix: GpMatrix; OffsetX: Single; OffsetY: Single;
  Order: TGPMatrixOrder): TGPStatus; stdcall; external GdiPlusDll;

{ GdipScaleMatrix(GpMatrix *matrix, REAL scaleX, REAL scaleY, GpMatrixOrder order); }
function GdipScaleMatrix(Matrix: GpMatrix; ScaleX: Single; ScaleY: Single;
  Order: TGPMatrixOrder): TGPStatus; stdcall; external GdiPlusDll;

{ GdipRotateMatrix(GpMatrix *matrix, REAL angle, GpMatrixOrder order); }
function GdipRotateMatrix(Matrix: GpMatrix; Angle: Single; Order: TGPMatrixOrder): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipShearMatrix(GpMatrix *matrix, REAL shearX, REAL shearY, GpMatrixOrder order); }
function GdipShearMatrix(Matrix: GpMatrix; ShearX: Single; ShearY: Single;
  Order: TGPMatrixOrder): TGPStatus; stdcall; external GdiPlusDll;

{ GdipInvertMatrix(GpMatrix *matrix); }
function GdipInvertMatrix(Matrix: GpMatrix): TGPStatus; stdcall; external GdiPlusDll;

{ GdipTransformMatrixPoints(GpMatrix *matrix, GpPointF *pts, INT count); }
function GdipTransformMatrixPoints(Matrix: GpMatrix; Pts: PGPPointF;
  Count: Integer): TGPStatus; stdcall; external GdiPlusDll;

{ GdipTransformMatrixPointsI(GpMatrix *matrix, GpPoint *pts, INT count); }
function GdipTransformMatrixPointsI(Matrix: GpMatrix; Pts: PGPPoint;
  Count: Integer): TGPStatus; stdcall; external GdiPlusDll;

{ GdipVectorTransformMatrixPoints(GpMatrix *matrix, GpPointF *pts, INT count); }
function GdipVectorTransformMatrixPoints(Matrix: GpMatrix; Pts: PGPPointF;
  Count: Integer): TGPStatus; stdcall; external GdiPlusDll;

{ GdipVectorTransformMatrixPointsI(GpMatrix *matrix, GpPoint *pts, INT count); }
function GdipVectorTransformMatrixPointsI(Matrix: GpMatrix; Pts: PGPPoint;
  Count: Integer): TGPStatus; stdcall; external GdiPlusDll;

{ GdipGetMatrixElements(GDIPCONST GpMatrix *matrix, REAL *matrixOut); }
function GdipGetMatrixElements(const Matrix: GpMatrix; MatrixOut: PSingle): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipIsMatrixInvertible(GDIPCONST GpMatrix *matrix, BOOL *result); }
function GdipIsMatrixInvertible(const Matrix: GpMatrix; out Result: Bool): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipIsMatrixIdentity(GDIPCONST GpMatrix *matrix, BOOL *result); }
function GdipIsMatrixIdentity(const Matrix: GpMatrix; out Result: Bool): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipIsMatrixEqual(GDIPCONST GpMatrix *matrix, GDIPCONST GpMatrix *matrix2, BOOL *result); }
function GdipIsMatrixEqual(const Matrix: GpMatrix; const Matrix2: GpMatrix;
  out Result: Bool): TGPStatus; stdcall; external GdiPlusDll;

//----------------------------------------------------------------------------
// Region APIs
//----------------------------------------------------------------------------

{ GdipCreateRegion(GpRegion **region); }
function GdipCreateRegion(out Region: GpRegion): TGPStatus; stdcall; external GdiPlusDll;

{ GdipCreateRegionRect(GDIPCONST GpRectF *rect, GpRegion **region); }
function GdipCreateRegionRect(const Rect: PGPRectF; out Region: GpRegion): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipCreateRegionRectI(GDIPCONST GpRect *rect, GpRegion **region); }
function GdipCreateRegionRectI(const Rect: PGPRect; out Region: GpRegion): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipCreateRegionPath(GpPath *path, GpRegion **region); }
function GdipCreateRegionPath(Path: GpPath; out Region: GpRegion): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipCreateRegionRgnData(GDIPCONST BYTE *regionData, INT size, GpRegion **region); }
function GdipCreateRegionRgnData(const RegionData: PByte; Size: Integer;
  out Region: GpRegion): TGPStatus; stdcall; external GdiPlusDll;

{ GdipCreateRegionHrgn(HRGN hRgn, GpRegion **region); }
function GdipCreateRegionHrgn(HRgn: HRGN; out Region: GpRegion): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipCloneRegion(GpRegion *region, GpRegion **cloneRegion); }
function GdipCloneRegion(Region: GpRegion; out CloneRegion: GpRegion): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipDeleteRegion(GpRegion *region); }
function GdipDeleteRegion(Region: GpRegion): TGPStatus; stdcall; external GdiPlusDll;

{ GdipSetInfinite(GpRegion *region); }
function GdipSetInfinite(Region: GpRegion): TGPStatus; stdcall; external GdiPlusDll;

{ GdipSetEmpty(GpRegion *region); }
function GdipSetEmpty(Region: GpRegion): TGPStatus; stdcall; external GdiPlusDll;

{ GdipCombineRegionRect(GpRegion *region, GDIPCONST GpRectF *rect, CombineMode combineMode); }
function GdipCombineRegionRect(Region: GpRegion; const Rect: PGPRectF;
  CombineMode: TGPCombineMode): TGPStatus; stdcall; external GdiPlusDll;

{ GdipCombineRegionRectI(GpRegion *region, GDIPCONST GpRect *rect, CombineMode combineMode); }
function GdipCombineRegionRectI(Region: GpRegion; const Rect: PGPRect;
  CombineMode: TGPCombineMode): TGPStatus; stdcall; external GdiPlusDll;

{ GdipCombineRegionPath(GpRegion *region, GpPath *path, CombineMode combineMode); }
function GdipCombineRegionPath(Region: GpRegion; Path: GpPath;
  CombineMode: TGPCombineMode): TGPStatus; stdcall; external GdiPlusDll;

{ GdipCombineRegionRegion(GpRegion *region, GpRegion *region2, CombineMode combineMode); }
function GdipCombineRegionRegion(Region: GpRegion; Region2: GpRegion;
  CombineMode: TGPCombineMode): TGPStatus; stdcall; external GdiPlusDll;

{ GdipTranslateRegion(GpRegion *region, REAL dx, REAL dy); }
function GdipTranslateRegion(Region: GpRegion; Dx: Single; Dy: Single): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipTranslateRegionI(GpRegion *region, INT dx, INT dy); }
function GdipTranslateRegionI(Region: GpRegion; Dx: Integer; Dy: Integer): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipTransformRegion(GpRegion *region, GpMatrix *matrix); }
function GdipTransformRegion(Region: GpRegion; Matrix: GpMatrix): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetRegionBounds(GpRegion *region, GpGraphics *graphics, GpRectF *rect); }
function GdipGetRegionBounds(Region: GpRegion; Graphics: GpGraphics;
  out Rect: TGPRectF): TGPStatus; stdcall; external GdiPlusDll;

{ GdipGetRegionBoundsI(GpRegion *region, GpGraphics *graphics, GpRect *rect); }
function GdipGetRegionBoundsI(Region: GpRegion; Graphics: GpGraphics;
  out Rect: TGPRect): TGPStatus; stdcall; external GdiPlusDll;

{ GdipGetRegionHRgn(GpRegion *region, GpGraphics *graphics, HRGN *hRgn); }
function GdipGetRegionHRgn(Region: GpRegion; Graphics: GpGraphics;
  out HRgn: HRgn): TGPStatus; stdcall; external GdiPlusDll;

{ GdipIsEmptyRegion(GpRegion *region, GpGraphics *graphics, BOOL *result); }
function GdipIsEmptyRegion(Region: GpRegion; Graphics: GpGraphics;
  out Result: Bool): TGPStatus; stdcall; external GdiPlusDll;

{ GdipIsInfiniteRegion(GpRegion *region, GpGraphics *graphics, BOOL *result); }
function GdipIsInfiniteRegion(Region: GpRegion; Graphics: GpGraphics;
  out Result: Bool): TGPStatus; stdcall; external GdiPlusDll;

{ GdipIsEqualRegion(GpRegion *region, GpRegion *region2, GpGraphics *graphics, BOOL *result); }
function GdipIsEqualRegion(Region: GpRegion; Region2: GpRegion;
  Graphics: GpGraphics; out Result: Bool): TGPStatus; stdcall; external GdiPlusDll;

{ GdipGetRegionDataSize(GpRegion *region, UINT * bufferSize); }
function GdipGetRegionDataSize(Region: GpRegion; out BufferSize: Cardinal): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetRegionData(GpRegion *region, BYTE * buffer, UINT bufferSize, UINT * sizeFilled); }
function GdipGetRegionData(Region: GpRegion; Buffer: Pointer;
  BufferSize: Cardinal; SizeFilled: PCardinal): TGPStatus; stdcall; external GdiPlusDll;

{ GdipIsVisibleRegionPoint(GpRegion *region, REAL x, REAL y, GpGraphics *graphics, BOOL *result); }
function GdipIsVisibleRegionPoint(Region: GpRegion; X: Single; Y: Single;
  Graphics: GpGraphics; out Result: Bool): TGPStatus; stdcall; external GdiPlusDll;

{ GdipIsVisibleRegionPointI(GpRegion *region, INT x, INT y, GpGraphics *graphics, BOOL *result); }
function GdipIsVisibleRegionPointI(Region: GpRegion; X: Integer; Y: Integer;
  Graphics: GpGraphics; out Result: Bool): TGPStatus; stdcall; external GdiPlusDll;

{ GdipIsVisibleRegionRect(GpRegion *region, REAL x, REAL y, REAL width, REAL height, GpGraphics *graphics, BOOL *result); }
function GdipIsVisibleRegionRect(Region: GpRegion; X: Single; Y: Single;
  Width: Single; Height: Single; Graphics: GpGraphics; out Result: Bool): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipIsVisibleRegionRectI(GpRegion *region, INT x, INT y, INT width, INT height, GpGraphics *graphics, BOOL *result); }
function GdipIsVisibleRegionRectI(Region: GpRegion; X: Integer; Y: Integer;
  Width: Integer; Height: Integer; Graphics: GpGraphics; out Result: Bool): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetRegionScansCount(GpRegion *region, UINT* count, GpMatrix* matrix); }
function GdipGetRegionScansCount(Region: GpRegion; out Count: Integer;
  Matrix: GpMatrix): TGPStatus; stdcall; external GdiPlusDll;

{ GdipGetRegionScans(GpRegion *region, GpRectF* rects, INT* count, GpMatrix* matrix); }
function GdipGetRegionScans(Region: GpRegion; Rects: PGPRectF; var Count: Integer;
  Matrix: GpMatrix): TGPStatus; stdcall; external GdiPlusDll;

{ GdipGetRegionScansI(GpRegion *region, GpRect* rects, INT* count, GpMatrix* matrix); }
function GdipGetRegionScansI(Region: GpRegion; Rects: PGPRect; var Count: Integer;
  Matrix: GpMatrix): TGPStatus; stdcall; external GdiPlusDll;

//----------------------------------------------------------------------------
// Brush APIs
//----------------------------------------------------------------------------

{ GdipCloneBrush(GpBrush *brush, GpBrush **cloneBrush); }
function GdipCloneBrush(Brush: GpBrush; out CloneBrush: GpBrush): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipDeleteBrush(GpBrush *brush); }
function GdipDeleteBrush(Brush: GpBrush): TGPStatus; stdcall; external GdiPlusDll;

{ GdipGetBrushType(GpBrush *brush, GpBrushType *type); }
function GdipGetBrushType(Brush: GpBrush; out AType: TGPBrushType): TGPStatus; stdcall;
  external GdiPlusDll;

//----------------------------------------------------------------------------
// HatchBrush APIs
//----------------------------------------------------------------------------

{ GdipCreateHatchBrush(GpHatchStyle hatchstyle, ARGB forecol, ARGB backcol, GpHatch **brush); }
function GdipCreateHatchBrush(Hatchstyle: TGPHatchStyle; Forecol: ARGB;
  Backcol: ARGB; out Brush: GpHatch): TGPStatus; stdcall; external GdiPlusDll;

{ GdipGetHatchStyle(GpHatch *brush, GpHatchStyle *hatchstyle); }
function GdipGetHatchStyle(Brush: GpHatch; out Hatchstyle: TGPHatchStyle): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetHatchForegroundColor(GpHatch *brush, ARGB* forecol); }
function GdipGetHatchForegroundColor(Brush: GpHatch; out Forecol: ARGB): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetHatchBackgroundColor(GpHatch *brush, ARGB* backcol); }
function GdipGetHatchBackgroundColor(Brush: GpHatch; out Backcol: ARGB): TGPStatus; stdcall;
  external GdiPlusDll;

//----------------------------------------------------------------------------
// TextureBrush APIs
//----------------------------------------------------------------------------

{ GdipCreateTexture(GpImage *image, GpWrapMode wrapmode, GpTexture **texture); }
function GdipCreateTexture(Image: GpImage; Wrapmode: TGPWrapMode;
  out Texture: GpTexture): TGPStatus; stdcall; external GdiPlusDll;

{ GdipCreateTexture2(GpImage *image, GpWrapMode wrapmode, REAL x, REAL y, REAL width, REAL height, GpTexture **texture); }
function GdipCreateTexture2(Image: GpImage; Wrapmode: TGPWrapMode; X: Single;
  Y: Single; Width: Single; Height: Single; out Texture: GpTexture): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipCreateTextureIA(GpImage *image, GDIPCONST GpImageAttributes *imageAttributes, REAL x, REAL y, REAL width, REAL height, GpTexture **texture); }
function GdipCreateTextureIA(Image: GpImage;
  const ImageAttributes: GpImageAttributes; X: Single; Y: Single; Width: Single;
  Height: Single; out Texture: GpTexture): TGPStatus; stdcall; external GdiPlusDll;

{ GdipCreateTexture2I(GpImage *image, GpWrapMode wrapmode, INT x, INT y, INT width, INT height, GpTexture **texture); }
function GdipCreateTexture2I(Image: GpImage; Wrapmode: TGPWrapMode; X: Integer;
  Y: Integer; Width: Integer; Height: Integer; out Texture: GpTexture): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipCreateTextureIAI(GpImage *image, GDIPCONST GpImageAttributes *imageAttributes, INT x, INT y, INT width, INT height, GpTexture **texture); }
function GdipCreateTextureIAI(Image: GpImage;
  const ImageAttributes: GpImageAttributes; X: Integer; Y: Integer;
  Width: Integer; Height: Integer; out Texture: GpTexture): TGPStatus; stdcall;
  external GdiPlusDll;


{ GdipGetTextureTransform(GpTexture *brush, GpMatrix *matrix); }
function GdipGetTextureTransform(Brush: GpTexture; Matrix: GpMatrix): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipSetTextureTransform(GpTexture *brush, GDIPCONST GpMatrix *matrix); }
function GdipSetTextureTransform(Brush: GpTexture; const Matrix: GpMatrix): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipResetTextureTransform(GpTexture* brush); }
function GdipResetTextureTransform(Brush: GpTexture): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipMultiplyTextureTransform(GpTexture* brush, GDIPCONST GpMatrix *matrix, GpMatrixOrder order); }
function GdipMultiplyTextureTransform(Brush: GpTexture; const Matrix: GpMatrix;
  Order: TGPMatrixOrder): TGPStatus; stdcall; external GdiPlusDll;

{ GdipTranslateTextureTransform(GpTexture* brush, REAL dx, REAL dy, GpMatrixOrder order); }
function GdipTranslateTextureTransform(Brush: GpTexture; Dx: Single; Dy: Single;
  Order: TGPMatrixOrder): TGPStatus; stdcall; external GdiPlusDll;

{ GdipScaleTextureTransform(GpTexture* brush, REAL sx, REAL sy, GpMatrixOrder order); }
function GdipScaleTextureTransform(Brush: GpTexture; Sx: Single; Sy: Single;
  Order: TGPMatrixOrder): TGPStatus; stdcall; external GdiPlusDll;

{ GdipRotateTextureTransform(GpTexture* brush, REAL angle, GpMatrixOrder order); }
function GdipRotateTextureTransform(Brush: GpTexture; Angle: Single;
  Order: TGPMatrixOrder): TGPStatus; stdcall; external GdiPlusDll;

{ GdipSetTextureWrapMode(GpTexture *brush, GpWrapMode wrapmode); }
function GdipSetTextureWrapMode(Brush: GpTexture; Wrapmode: TGPWrapMode): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetTextureWrapMode(GpTexture *brush, GpWrapMode *wrapmode); }
function GdipGetTextureWrapMode(Brush: GpTexture; out Wrapmode: TGPWrapMode): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetTextureImage(GpTexture *brush, GpImage **image); }
function GdipGetTextureImage(Brush: GpTexture; out Image: GpImage): TGPStatus; stdcall;
  external GdiPlusDll;

//----------------------------------------------------------------------------
// SolidBrush APIs
//----------------------------------------------------------------------------

{ GdipCreateSolidFill(ARGB color, GpSolidFill **brush); }
function GdipCreateSolidFill(Color: ARGB; out Brush: GpSolidFill): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipSetSolidFillColor(GpSolidFill *brush, ARGB color); }
function GdipSetSolidFillColor(Brush: GpSolidFill; Color: ARGB): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetSolidFillColor(GpSolidFill *brush, ARGB *color); }
function GdipGetSolidFillColor(Brush: GpSolidFill; out Color: ARGB): TGPStatus; stdcall;
  external GdiPlusDll;

//----------------------------------------------------------------------------
// LineBrush APIs
//----------------------------------------------------------------------------

{ GdipCreateLineBrush(GDIPCONST GpPointF* point1, GDIPCONST GpPointF* point2, ARGB color1, ARGB color2, GpWrapMode wrapMode, GpLineGradient **lineGradient); }
function GdipCreateLineBrush(const Point1: PGPPointF; const Point2: PGPPointF;
  Color1: ARGB; Color2: ARGB; WrapMode: TGPWrapMode;
  out LineGradient: GpLineGradient): TGPStatus; stdcall; external GdiPlusDll;

{ GdipCreateLineBrushI(GDIPCONST GpPoint* point1, GDIPCONST GpPoint* point2, ARGB color1, ARGB color2, GpWrapMode wrapMode, GpLineGradient **lineGradient); }
function GdipCreateLineBrushI(const Point1: PGPPoint; const Point2: PGPPoint;
  Color1: ARGB; Color2: ARGB; WrapMode: TGPWrapMode;
  out LineGradient: GpLineGradient): TGPStatus; stdcall; external GdiPlusDll;

{ GdipCreateLineBrushFromRect(GDIPCONST GpRectF* rect, ARGB color1, ARGB color2, LinearGradientMode mode, GpWrapMode wrapMode, GpLineGradient **lineGradient); }
function GdipCreateLineBrushFromRect(const Rect: PGPRectF; Color1: ARGB;
  Color2: ARGB; Mode: TGPLinearGradientMode; WrapMode: TGPWrapMode;
  out LineGradient: GpLineGradient): TGPStatus; stdcall; external GdiPlusDll;

{ GdipCreateLineBrushFromRectI(GDIPCONST GpRect* rect, ARGB color1, ARGB color2, LinearGradientMode mode, GpWrapMode wrapMode, GpLineGradient **lineGradient); }
function GdipCreateLineBrushFromRectI(const Rect: PGPRect; Color1: ARGB;
  Color2: ARGB; Mode: TGPLinearGradientMode; WrapMode: TGPWrapMode;
  out LineGradient: GpLineGradient): TGPStatus; stdcall; external GdiPlusDll;

{ GdipCreateLineBrushFromRectWithAngle(GDIPCONST GpRectF* rect, ARGB color1, ARGB color2, REAL angle, BOOL isAngleScalable, GpWrapMode wrapMode, GpLineGradient **lineGradient); }
function GdipCreateLineBrushFromRectWithAngle(const Rect: PGPRectF; Color1: ARGB;
  Color2: ARGB; Angle: Single; IsAngleScalable: Bool; WrapMode: TGPWrapMode;
  out LineGradient: GpLineGradient): TGPStatus; stdcall; external GdiPlusDll;

{ GdipCreateLineBrushFromRectWithAngleI(GDIPCONST GpRect* rect, ARGB color1, ARGB color2, REAL angle, BOOL isAngleScalable, GpWrapMode wrapMode, GpLineGradient **lineGradient); }
function GdipCreateLineBrushFromRectWithAngleI(const Rect: PGPRect; Color1: ARGB;
  Color2: ARGB; Angle: Single; IsAngleScalable: Bool; WrapMode: TGPWrapMode;
  out LineGradient: GpLineGradient): TGPStatus; stdcall; external GdiPlusDll;

{ GdipSetLineColors(GpLineGradient *brush, ARGB color1, ARGB color2); }
function GdipSetLineColors(Brush: GpLineGradient; Color1: ARGB; Color2: ARGB): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetLineColors(GpLineGradient *brush, ARGB* colors); }
function GdipGetLineColors(Brush: GpLineGradient; Colors: PARGB): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetLineRect(GpLineGradient *brush, GpRectF *rect); }
function GdipGetLineRect(Brush: GpLineGradient; out Rect: TGPRectF): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetLineRectI(GpLineGradient *brush, GpRect *rect); }
function GdipGetLineRectI(Brush: GpLineGradient; out Rect: TGPRect): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipSetLineGammaCorrection(GpLineGradient *brush, BOOL useGammaCorrection); }
function GdipSetLineGammaCorrection(Brush: GpLineGradient;
  UseGammaCorrection: Bool): TGPStatus; stdcall; external GdiPlusDll;

{ GdipGetLineGammaCorrection(GpLineGradient *brush, BOOL *useGammaCorrection); }
function GdipGetLineGammaCorrection(Brush: GpLineGradient;
  out UseGammaCorrection: Bool): TGPStatus; stdcall; external GdiPlusDll;

{ GdipGetLineBlendCount(GpLineGradient *brush, INT *count); }
function GdipGetLineBlendCount(Brush: GpLineGradient; out Count: Integer): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetLineBlend(GpLineGradient *brush, REAL *blend, REAL* positions, INT count); }
function GdipGetLineBlend(Brush: GpLineGradient; Blend: PSingle;
  Positions: PSingle; Count: Integer): TGPStatus; stdcall; external GdiPlusDll;

{ GdipSetLineBlend(GpLineGradient *brush, GDIPCONST REAL *blend, GDIPCONST REAL* positions, INT count); }
function GdipSetLineBlend(Brush: GpLineGradient; const Blend: PSingle;
  const Positions: PSingle; Count: Integer): TGPStatus; stdcall; external GdiPlusDll;

{ GdipGetLinePresetBlendCount(GpLineGradient *brush, INT *count); }
function GdipGetLinePresetBlendCount(Brush: GpLineGradient; out Count: Integer): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetLinePresetBlend(GpLineGradient *brush, ARGB *blend, REAL* positions, INT count); }
function GdipGetLinePresetBlend(Brush: GpLineGradient; Blend: PARGB;
  Positions: PSingle; Count: Integer): TGPStatus; stdcall; external GdiPlusDll;

{ GdipSetLinePresetBlend(GpLineGradient *brush, GDIPCONST ARGB *blend, GDIPCONST REAL* positions, INT count); }
function GdipSetLinePresetBlend(Brush: GpLineGradient; const Blend: PARGB;
  const Positions: PSingle; Count: Integer): TGPStatus; stdcall; external GdiPlusDll;

{ GdipSetLineSigmaBlend(GpLineGradient *brush, REAL focus, REAL scale); }
function GdipSetLineSigmaBlend(Brush: GpLineGradient; Focus: Single;
  Scale: Single): TGPStatus; stdcall; external GdiPlusDll;

{ GdipSetLineLinearBlend(GpLineGradient *brush, REAL focus, REAL scale); }
function GdipSetLineLinearBlend(Brush: GpLineGradient; Focus: Single;
  Scale: Single): TGPStatus; stdcall; external GdiPlusDll;

{ GdipSetLineWrapMode(GpLineGradient *brush, GpWrapMode wrapmode); }
function GdipSetLineWrapMode(Brush: GpLineGradient; Wrapmode: TGPWrapMode): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetLineWrapMode(GpLineGradient *brush, GpWrapMode *wrapmode); }
function GdipGetLineWrapMode(Brush: GpLineGradient; out Wrapmode: TGPWrapMode): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetLineTransform(GpLineGradient *brush, GpMatrix *matrix); }
function GdipGetLineTransform(Brush: GpLineGradient; Matrix: GpMatrix): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipSetLineTransform(GpLineGradient *brush, GDIPCONST GpMatrix *matrix); }
function GdipSetLineTransform(Brush: GpLineGradient; const Matrix: GpMatrix): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipResetLineTransform(GpLineGradient* brush); }
function GdipResetLineTransform(Brush: GpLineGradient): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipMultiplyLineTransform(GpLineGradient* brush, GDIPCONST GpMatrix *matrix, GpMatrixOrder order); }
function GdipMultiplyLineTransform(Brush: GpLineGradient;
  const Matrix: GpMatrix; Order: TGPMatrixOrder): TGPStatus; stdcall; external GdiPlusDll;

{ GdipTranslateLineTransform(GpLineGradient* brush, REAL dx, REAL dy, GpMatrixOrder order); }
function GdipTranslateLineTransform(Brush: GpLineGradient; Dx: Single;
  Dy: Single; Order: TGPMatrixOrder): TGPStatus; stdcall; external GdiPlusDll;

{ GdipScaleLineTransform(GpLineGradient* brush, REAL sx, REAL sy, GpMatrixOrder order); }
function GdipScaleLineTransform(Brush: GpLineGradient; Sx: Single; Sy: Single;
  Order: TGPMatrixOrder): TGPStatus; stdcall; external GdiPlusDll;

{ GdipRotateLineTransform(GpLineGradient* brush, REAL angle, GpMatrixOrder order); }
function GdipRotateLineTransform(Brush: GpLineGradient; Angle: Single;
  Order: TGPMatrixOrder): TGPStatus; stdcall; external GdiPlusDll;

//----------------------------------------------------------------------------
// PathGradientBrush APIs
//----------------------------------------------------------------------------

{ GdipCreatePathGradient(GDIPCONST GpPointF* points, INT count, GpWrapMode wrapMode, GpPathGradient **polyGradient); }
function GdipCreatePathGradient(const Points: PGPPointF; Count: Integer;
  WrapMode: TGPWrapMode; out PolyGradient: GpPathGradient): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipCreatePathGradientI(GDIPCONST GpPoint* points, INT count, GpWrapMode wrapMode, GpPathGradient **polyGradient); }
function GdipCreatePathGradientI(const Points: PGPPoint; Count: Integer;
  WrapMode: TGPWrapMode; out PolyGradient: GpPathGradient): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipCreatePathGradientFromPath(GDIPCONST GpPath* path, GpPathGradient **polyGradient); }
function GdipCreatePathGradientFromPath(const Path: GpPath;
  out PolyGradient: GpPathGradient): TGPStatus; stdcall; external GdiPlusDll;

{ GdipGetPathGradientCenterColor( GpPathGradient *brush, ARGB* colors); }
function GdipGetPathGradientCenterColor(Brush: GpPathGradient; out Color: ARGB): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipSetPathGradientCenterColor( GpPathGradient *brush, ARGB colors); }
function GdipSetPathGradientCenterColor(Brush: GpPathGradient; Color: ARGB): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetPathGradientSurroundColorsWithCount( GpPathGradient *brush, ARGB* color, INT* count); }
function GdipGetPathGradientSurroundColorsWithCount(Brush: GpPathGradient;
  Color: PARGB; out Count: Integer): TGPStatus; stdcall; external GdiPlusDll;

{ GdipSetPathGradientSurroundColorsWithCount( GpPathGradient *brush, GDIPCONST ARGB* color, INT* count); }
function GdipSetPathGradientSurroundColorsWithCount(Brush: GpPathGradient;
  const Color: PARGB; out Count: Integer): TGPStatus; stdcall; external GdiPlusDll;

{ GdipGetPathGradientPath(GpPathGradient *brush, GpPath *path); }
function GdipGetPathGradientPath(Brush: GpPathGradient; Path: GpPath): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipSetPathGradientPath(GpPathGradient *brush, GDIPCONST GpPath *path); }
function GdipSetPathGradientPath(Brush: GpPathGradient; const Path: GpPath): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetPathGradientCenterPoint( GpPathGradient *brush, GpPointF* points); }
function GdipGetPathGradientCenterPoint(Brush: GpPathGradient; out Point: TGPPointF): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetPathGradientCenterPointI( GpPathGradient *brush, GpPoint* points); }
function GdipGetPathGradientCenterPointI(Brush: GpPathGradient; out Point: TGPPoint): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipSetPathGradientCenterPoint( GpPathGradient *brush, GDIPCONST GpPointF* points); }
function GdipSetPathGradientCenterPoint(Brush: GpPathGradient;
  const Point: PGPPointF): TGPStatus; stdcall; external GdiPlusDll;

{ GdipSetPathGradientCenterPointI( GpPathGradient *brush, GDIPCONST GpPoint* points); }
function GdipSetPathGradientCenterPointI(Brush: GpPathGradient;
  const Point: PGPPoint): TGPStatus; stdcall; external GdiPlusDll;

{ GdipGetPathGradientRect(GpPathGradient *brush, GpRectF *rect); }
function GdipGetPathGradientRect(Brush: GpPathGradient; out Rect: TGPRectF): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetPathGradientRectI(GpPathGradient *brush, GpRect *rect); }
function GdipGetPathGradientRectI(Brush: GpPathGradient; out Rect: TGPRect): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetPathGradientPointCount(GpPathGradient *brush, INT* count); }
function GdipGetPathGradientPointCount(Brush: GpPathGradient; out Count: Integer): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetPathGradientSurroundColorCount(GpPathGradient *brush, INT* count); }
function GdipGetPathGradientSurroundColorCount(Brush: GpPathGradient;
  out Count: Integer): TGPStatus; stdcall; external GdiPlusDll;

{ GdipSetPathGradientGammaCorrection(GpPathGradient *brush, BOOL useGammaCorrection); }
function GdipSetPathGradientGammaCorrection(Brush: GpPathGradient;
  UseGammaCorrection: Bool): TGPStatus; stdcall; external GdiPlusDll;

{ GdipGetPathGradientGammaCorrection(GpPathGradient *brush, BOOL *useGammaCorrection); }
function GdipGetPathGradientGammaCorrection(Brush: GpPathGradient;
  out UseGammaCorrection: Bool): TGPStatus; stdcall; external GdiPlusDll;

{ GdipGetPathGradientBlendCount(GpPathGradient *brush, INT *count); }
function GdipGetPathGradientBlendCount(Brush: GpPathGradient; out Count: Integer): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetPathGradientBlend(GpPathGradient *brush, REAL *blend, REAL *positions, INT count); }
function GdipGetPathGradientBlend(Brush: GpPathGradient; Blend: PSingle;
  Positions: PSingle; Count: Integer): TGPStatus; stdcall; external GdiPlusDll;

{ GdipSetPathGradientBlend(GpPathGradient *brush, GDIPCONST REAL *blend, GDIPCONST REAL *positions, INT count); }
function GdipSetPathGradientBlend(Brush: GpPathGradient; const Blend: PSingle;
  const Positions: PSingle; Count: Integer): TGPStatus; stdcall; external GdiPlusDll;

{ GdipGetPathGradientPresetBlendCount(GpPathGradient *brush, INT *count); }
function GdipGetPathGradientPresetBlendCount(Brush: GpPathGradient;
  out Count: Integer): TGPStatus; stdcall; external GdiPlusDll;

{ GdipGetPathGradientPresetBlend(GpPathGradient *brush, ARGB *blend, REAL* positions, INT count); }
function GdipGetPathGradientPresetBlend(Brush: GpPathGradient; Blend: PARGB;
  Positions: PSingle; Count: Integer): TGPStatus; stdcall; external GdiPlusDll;

{ GdipSetPathGradientPresetBlend(GpPathGradient *brush, GDIPCONST ARGB *blend, GDIPCONST REAL* positions, INT count); }
function GdipSetPathGradientPresetBlend(Brush: GpPathGradient;
  const Blend: PARGB; const Positions: PSingle; Count: Integer): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipSetPathGradientSigmaBlend(GpPathGradient *brush, REAL focus, REAL scale); }
function GdipSetPathGradientSigmaBlend(Brush: GpPathGradient; Focus: Single;
  Scale: Single): TGPStatus; stdcall; external GdiPlusDll;

{ GdipSetPathGradientLinearBlend(GpPathGradient *brush, REAL focus, REAL scale); }
function GdipSetPathGradientLinearBlend(Brush: GpPathGradient; Focus: Single;
  Scale: Single): TGPStatus; stdcall; external GdiPlusDll;

{ GdipGetPathGradientWrapMode(GpPathGradient *brush, GpWrapMode *wrapmode); }
function GdipGetPathGradientWrapMode(Brush: GpPathGradient;
  out Wrapmode: TGPWrapMode): TGPStatus; stdcall; external GdiPlusDll;

{ GdipSetPathGradientWrapMode(GpPathGradient *brush, GpWrapMode wrapmode); }
function GdipSetPathGradientWrapMode(Brush: GpPathGradient; Wrapmode: TGPWrapMode): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetPathGradientTransform(GpPathGradient *brush, GpMatrix *matrix); }
function GdipGetPathGradientTransform(Brush: GpPathGradient; Matrix: GpMatrix): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipSetPathGradientTransform(GpPathGradient *brush, GpMatrix *matrix); }
function GdipSetPathGradientTransform(Brush: GpPathGradient; Matrix: GpMatrix): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipResetPathGradientTransform(GpPathGradient* brush); }
function GdipResetPathGradientTransform(Brush: GpPathGradient): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipMultiplyPathGradientTransform(GpPathGradient* brush, GDIPCONST GpMatrix *matrix, GpMatrixOrder order); }
function GdipMultiplyPathGradientTransform(Brush: GpPathGradient;
  const Matrix: GpMatrix; Order: TGPMatrixOrder): TGPStatus; stdcall; external GdiPlusDll;

{ GdipTranslatePathGradientTransform(GpPathGradient* brush, REAL dx, REAL dy, GpMatrixOrder order); }
function GdipTranslatePathGradientTransform(Brush: GpPathGradient; Dx: Single;
  Dy: Single; Order: TGPMatrixOrder): TGPStatus; stdcall; external GdiPlusDll;

{ GdipScalePathGradientTransform(GpPathGradient* brush, REAL sx, REAL sy, GpMatrixOrder order); }
function GdipScalePathGradientTransform(Brush: GpPathGradient; Sx: Single;
  Sy: Single; Order: TGPMatrixOrder): TGPStatus; stdcall; external GdiPlusDll;

{ GdipRotatePathGradientTransform(GpPathGradient* brush, REAL angle, GpMatrixOrder order); }
function GdipRotatePathGradientTransform(Brush: GpPathGradient; Angle: Single;
  Order: TGPMatrixOrder): TGPStatus; stdcall; external GdiPlusDll;

{ GdipGetPathGradientFocusScales(GpPathGradient *brush, REAL* xScale, REAL* yScale); }
function GdipGetPathGradientFocusScales(Brush: GpPathGradient; out XScale: Single;
  out YScale: Single): TGPStatus; stdcall; external GdiPlusDll;

{ GdipSetPathGradientFocusScales(GpPathGradient *brush, REAL xScale, REAL yScale); }
function GdipSetPathGradientFocusScales(Brush: GpPathGradient; XScale: Single;
  YScale: Single): TGPStatus; stdcall; external GdiPlusDll;

//----------------------------------------------------------------------------
// Pen APIs
//----------------------------------------------------------------------------

{ GdipCreatePen1(ARGB color, REAL width, GpUnit unit, GpPen **pen); }
function GdipCreatePen1(Color: ARGB; Width: Single; AUnit: TGPUnit;
  out Pen: GpPen): TGPStatus; stdcall; external GdiPlusDll;

{ GdipCreatePen2(GpBrush *brush, REAL width, GpUnit unit, GpPen **pen); }
function GdipCreatePen2(Brush: GpBrush; Width: Single; AUnit: TGPUnit;
  out Pen: GpPen): TGPStatus; stdcall; external GdiPlusDll;

{ GdipClonePen(GpPen *pen, GpPen **clonepen); }
function GdipClonePen(Pen: GpPen; out Clonepen: GpPen): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipDeletePen(GpPen *pen); }
function GdipDeletePen(Pen: GpPen): TGPStatus; stdcall; external GdiPlusDll;

{ GdipSetPenWidth(GpPen *pen, REAL width); }
function GdipSetPenWidth(Pen: GpPen; Width: Single): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetPenWidth(GpPen *pen, REAL *width); }
function GdipGetPenWidth(Pen: GpPen; out Width: Single): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipSetPenUnit(GpPen *pen, GpUnit unit); }
function GdipSetPenUnit(Pen: GpPen; AUnit: TGPUnit): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetPenUnit(GpPen *pen, GpUnit *unit); }
function GdipGetPenUnit(Pen: GpPen; out AUnit: TGPUnit): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipSetPenLineCap197819(GpPen *pen, GpLineCap startCap, GpLineCap endCap, GpDashCap dashCap); }
function GdipSetPenLineCap197819(Pen: GpPen; StartCap: TGPLineCap;
  EndCap: TGPLineCap; DashCap: TGPDashCap): TGPStatus; stdcall; external GdiPlusDll;

{ GdipSetPenStartCap(GpPen *pen, GpLineCap startCap); }
function GdipSetPenStartCap(Pen: GpPen; StartCap: TGPLineCap): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipSetPenEndCap(GpPen *pen, GpLineCap endCap); }
function GdipSetPenEndCap(Pen: GpPen; EndCap: TGPLineCap): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipSetPenDashCap197819(GpPen *pen, GpDashCap dashCap); }
function GdipSetPenDashCap197819(Pen: GpPen; DashCap: TGPDashCap): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetPenStartCap(GpPen *pen, GpLineCap *startCap); }
function GdipGetPenStartCap(Pen: GpPen; out StartCap: TGPLineCap): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetPenEndCap(GpPen *pen, GpLineCap *endCap); }
function GdipGetPenEndCap(Pen: GpPen; out EndCap: TGPLineCap): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetPenDashCap197819(GpPen *pen, GpDashCap *dashCap); }
function GdipGetPenDashCap197819(Pen: GpPen; out DashCap: TGPDashCap): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipSetPenLineJoin(GpPen *pen, GpLineJoin lineJoin); }
function GdipSetPenLineJoin(Pen: GpPen; LineJoin: TGPLineJoin): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetPenLineJoin(GpPen *pen, GpLineJoin *lineJoin); }
function GdipGetPenLineJoin(Pen: GpPen; out LineJoin: TGPLineJoin): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipSetPenCustomStartCap(GpPen *pen, GpCustomLineCap* customCap); }
function GdipSetPenCustomStartCap(Pen: GpPen; CustomCap: GpCustomLineCap): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetPenCustomStartCap(GpPen *pen, GpCustomLineCap** customCap); }
function GdipGetPenCustomStartCap(Pen: GpPen; out CustomCap: GpCustomLineCap): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipSetPenCustomEndCap(GpPen *pen, GpCustomLineCap* customCap); }
function GdipSetPenCustomEndCap(Pen: GpPen; CustomCap: GpCustomLineCap): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetPenCustomEndCap(GpPen *pen, GpCustomLineCap** customCap); }
function GdipGetPenCustomEndCap(Pen: GpPen; out CustomCap: GpCustomLineCap): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipSetPenMiterLimit(GpPen *pen, REAL miterLimit); }
function GdipSetPenMiterLimit(Pen: GpPen; MiterLimit: Single): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetPenMiterLimit(GpPen *pen, REAL *miterLimit); }
function GdipGetPenMiterLimit(Pen: GpPen; out MiterLimit: Single): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipSetPenMode(GpPen *pen, GpPenAlignment penMode); }
function GdipSetPenMode(Pen: GpPen; PenMode: TGPPenAlignment): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetPenMode(GpPen *pen, GpPenAlignment *penMode); }
function GdipGetPenMode(Pen: GpPen; out PenMode: TGPPenAlignment): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipSetPenTransform(GpPen *pen, GpMatrix *matrix); }
function GdipSetPenTransform(Pen: GpPen; Matrix: GpMatrix): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetPenTransform(GpPen *pen, GpMatrix *matrix); }
function GdipGetPenTransform(Pen: GpPen; Matrix: GpMatrix): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipResetPenTransform(GpPen *pen); }
function GdipResetPenTransform(Pen: GpPen): TGPStatus; stdcall; external GdiPlusDll;

{ GdipMultiplyPenTransform(GpPen *pen, GDIPCONST GpMatrix *matrix, GpMatrixOrder order); }
function GdipMultiplyPenTransform(Pen: GpPen; const Matrix: GpMatrix;
  Order: TGPMatrixOrder): TGPStatus; stdcall; external GdiPlusDll;

{ GdipTranslatePenTransform(GpPen *pen, REAL dx, REAL dy, GpMatrixOrder order); }
function GdipTranslatePenTransform(Pen: GpPen; Dx: Single; Dy: Single;
  Order: TGPMatrixOrder): TGPStatus; stdcall; external GdiPlusDll;

{ GdipScalePenTransform(GpPen *pen, REAL sx, REAL sy, GpMatrixOrder order); }
function GdipScalePenTransform(Pen: GpPen; Sx: Single; Sy: Single;
  Order: TGPMatrixOrder): TGPStatus; stdcall; external GdiPlusDll;

{ GdipRotatePenTransform(GpPen *pen, REAL angle, GpMatrixOrder order); }
function GdipRotatePenTransform(Pen: GpPen; Angle: Single; Order: TGPMatrixOrder): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipSetPenColor(GpPen *pen, ARGB argb); }
function GdipSetPenColor(Pen: GpPen; Argb: ARGB): TGPStatus; stdcall; external GdiPlusDll;

{ GdipGetPenColor(GpPen *pen, ARGB *argb); }
function GdipGetPenColor(Pen: GpPen; out Argb: ARGB): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipSetPenBrushFill(GpPen *pen, GpBrush *brush); }
function GdipSetPenBrushFill(Pen: GpPen; Brush: GpBrush): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetPenBrushFill(GpPen *pen, GpBrush **brush); }
function GdipGetPenBrushFill(Pen: GpPen; out Brush: GpBrush): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetPenFillType(GpPen *pen, GpPenType* type); }
function GdipGetPenFillType(Pen: GpPen; out AType: TGPPenType): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetPenDashStyle(GpPen *pen, GpDashStyle *dashstyle); }
function GdipGetPenDashStyle(Pen: GpPen; out Dashstyle: TGPDashStyle): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipSetPenDashStyle(GpPen *pen, GpDashStyle dashstyle); }
function GdipSetPenDashStyle(Pen: GpPen; Dashstyle: TGPDashStyle): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetPenDashOffset(GpPen *pen, REAL *offset); }
function GdipGetPenDashOffset(Pen: GpPen; out Offset: Single): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipSetPenDashOffset(GpPen *pen, REAL offset); }
function GdipSetPenDashOffset(Pen: GpPen; Offset: Single): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetPenDashCount(GpPen *pen, INT *count); }
function GdipGetPenDashCount(Pen: GpPen; out Count: Integer): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipSetPenDashArray(GpPen *pen, GDIPCONST REAL *dash, INT count); }
function GdipSetPenDashArray(Pen: GpPen; const Dash: PSingle; Count: Integer): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetPenDashArray(GpPen *pen, REAL *dash, INT count); }
function GdipGetPenDashArray(Pen: GpPen; Dash: PSingle; Count: Integer): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetPenCompoundCount(GpPen *pen, INT *count); }
function GdipGetPenCompoundCount(Pen: GpPen; out Count: Integer): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipSetPenCompoundArray(GpPen *pen, GDIPCONST REAL *dash, INT count); }
function GdipSetPenCompoundArray(Pen: GpPen; const Dash: PSingle;
  Count: Integer): TGPStatus; stdcall; external GdiPlusDll;

{ GdipGetPenCompoundArray(GpPen *pen, REAL *dash, INT count); }
function GdipGetPenCompoundArray(Pen: GpPen; Dash: PSingle; Count: Integer): TGPStatus; stdcall;
  external GdiPlusDll;

//----------------------------------------------------------------------------
// CustomLineCap APIs
//----------------------------------------------------------------------------

{ GdipCreateCustomLineCap(GpPath* fillPath, GpPath* strokePath, GpLineCap baseCap, REAL baseInset, GpCustomLineCap **customCap); }
function GdipCreateCustomLineCap(FillPath: GpPath; StrokePath: GpPath;
  BaseCap: TGPLineCap; BaseInset: Single; out CustomCap: GpCustomLineCap): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipDeleteCustomLineCap(GpCustomLineCap* customCap); }
function GdipDeleteCustomLineCap(CustomCap: GpCustomLineCap): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipCloneCustomLineCap(GpCustomLineCap* customCap, GpCustomLineCap** clonedCap); }
function GdipCloneCustomLineCap(CustomCap: GpCustomLineCap;
  out ClonedCap: GpCustomLineCap): TGPStatus; stdcall; external GdiPlusDll;

{ GdipGetCustomLineCapType(GpCustomLineCap* customCap, CustomLineCapType* capType); }
function GdipGetCustomLineCapType(CustomCap: GpCustomLineCap;
  out CapType: TGPCustomLineCapType): TGPStatus; stdcall; external GdiPlusDll;

{ GdipSetCustomLineCapStrokeCaps(GpCustomLineCap* customCap, GpLineCap startCap, GpLineCap endCap); }
function GdipSetCustomLineCapStrokeCaps(CustomCap: GpCustomLineCap;
  StartCap: TGPLineCap; EndCap: TGPLineCap): TGPStatus; stdcall; external GdiPlusDll;

{ GdipGetCustomLineCapStrokeCaps(GpCustomLineCap* customCap, GpLineCap* startCap, GpLineCap* endCap); }
function GdipGetCustomLineCapStrokeCaps(CustomCap: GpCustomLineCap;
  out StartCap: TGPLineCap; out EndCap: TGPLineCap): TGPStatus; stdcall; external GdiPlusDll;

{ GdipSetCustomLineCapStrokeJoin(GpCustomLineCap* customCap, GpLineJoin lineJoin); }
function GdipSetCustomLineCapStrokeJoin(CustomCap: GpCustomLineCap;
  LineJoin: TGPLineJoin): TGPStatus; stdcall; external GdiPlusDll;

{ GdipGetCustomLineCapStrokeJoin(GpCustomLineCap* customCap, GpLineJoin* lineJoin); }
function GdipGetCustomLineCapStrokeJoin(CustomCap: GpCustomLineCap;
  out LineJoin: TGPLineJoin): TGPStatus; stdcall; external GdiPlusDll;

{ GdipSetCustomLineCapBaseCap(GpCustomLineCap* customCap, GpLineCap baseCap); }
function GdipSetCustomLineCapBaseCap(CustomCap: GpCustomLineCap;
  BaseCap: TGPLineCap): TGPStatus; stdcall; external GdiPlusDll;

{ GdipGetCustomLineCapBaseCap(GpCustomLineCap* customCap, GpLineCap* baseCap); }
function GdipGetCustomLineCapBaseCap(CustomCap: GpCustomLineCap;
  out BaseCap: TGPLineCap): TGPStatus; stdcall; external GdiPlusDll;

{ GdipSetCustomLineCapBaseInset(GpCustomLineCap* customCap, REAL inset); }
function GdipSetCustomLineCapBaseInset(CustomCap: GpCustomLineCap;
  Inset: Single): TGPStatus; stdcall; external GdiPlusDll;

{ GdipGetCustomLineCapBaseInset(GpCustomLineCap* customCap, REAL* inset); }
function GdipGetCustomLineCapBaseInset(CustomCap: GpCustomLineCap;
  out Inset: Single): TGPStatus; stdcall; external GdiPlusDll;

{ GdipSetCustomLineCapWidthScale(GpCustomLineCap* customCap, REAL widthScale); }
function GdipSetCustomLineCapWidthScale(CustomCap: GpCustomLineCap;
  WidthScale: Single): TGPStatus; stdcall; external GdiPlusDll;

{ GdipGetCustomLineCapWidthScale(GpCustomLineCap* customCap, REAL* widthScale); }
function GdipGetCustomLineCapWidthScale(CustomCap: GpCustomLineCap;
  out WidthScale: Single): TGPStatus; stdcall; external GdiPlusDll;

//----------------------------------------------------------------------------
// AdjustableArrowCap APIs
//----------------------------------------------------------------------------

{ GdipCreateAdjustableArrowCap(REAL height, REAL width, BOOL isFilled, GpAdjustableArrowCap **cap); }
function GdipCreateAdjustableArrowCap(Height: Single; Width: Single;
  IsFilled: Bool; out Cap: GpAdjustableArrowCap): TGPStatus; stdcall; external GdiPlusDll;

{ GdipSetAdjustableArrowCapHeight(GpAdjustableArrowCap* cap, REAL height); }
function GdipSetAdjustableArrowCapHeight(Cap: GpAdjustableArrowCap;
  Height: Single): TGPStatus; stdcall; external GdiPlusDll;

{ GdipGetAdjustableArrowCapHeight(GpAdjustableArrowCap* cap, REAL* height); }
function GdipGetAdjustableArrowCapHeight(Cap: GpAdjustableArrowCap;
  out Height: Single): TGPStatus; stdcall; external GdiPlusDll;

{ GdipSetAdjustableArrowCapWidth(GpAdjustableArrowCap* cap, REAL width); }
function GdipSetAdjustableArrowCapWidth(Cap: GpAdjustableArrowCap;
  Width: Single): TGPStatus; stdcall; external GdiPlusDll;

{ GdipGetAdjustableArrowCapWidth(GpAdjustableArrowCap* cap, REAL* width); }
function GdipGetAdjustableArrowCapWidth(Cap: GpAdjustableArrowCap;
  out Width: Single): TGPStatus; stdcall; external GdiPlusDll;

{ GdipSetAdjustableArrowCapMiddleInset(GpAdjustableArrowCap* cap, REAL middleInset); }
function GdipSetAdjustableArrowCapMiddleInset(Cap: GpAdjustableArrowCap;
  MiddleInset: Single): TGPStatus; stdcall; external GdiPlusDll;

{ GdipGetAdjustableArrowCapMiddleInset(GpAdjustableArrowCap* cap, REAL* middleInset); }
function GdipGetAdjustableArrowCapMiddleInset(Cap: GpAdjustableArrowCap;
  out MiddleInset: Single): TGPStatus; stdcall; external GdiPlusDll;

{ GdipSetAdjustableArrowCapFillState(GpAdjustableArrowCap* cap, BOOL fillState); }
function GdipSetAdjustableArrowCapFillState(Cap: GpAdjustableArrowCap;
  FillState: Bool): TGPStatus; stdcall; external GdiPlusDll;

{ GdipGetAdjustableArrowCapFillState(GpAdjustableArrowCap* cap, BOOL* fillState); }
function GdipGetAdjustableArrowCapFillState(Cap: GpAdjustableArrowCap;
  out FillState: Bool): TGPStatus; stdcall; external GdiPlusDll;

//----------------------------------------------------------------------------
// Image APIs
//----------------------------------------------------------------------------

{ GdipLoadImageFromStream(IStream* stream, GpImage **image); }
function GdipLoadImageFromStream(const Stream: IStream; out Image: GpImage): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipLoadImageFromFile(GDIPCONST WCHAR* filename, GpImage **image); }
function GdipLoadImageFromFile(const Filename: PWideChar; out Image: GpImage): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipLoadImageFromStreamICM(IStream* stream, GpImage **image); }
function GdipLoadImageFromStreamICM(const Stream: IStream; out Image: GpImage): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipLoadImageFromFileICM(GDIPCONST WCHAR* filename, GpImage **image); }
function GdipLoadImageFromFileICM(const Filename: PWideChar; out Image: GpImage): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipCloneImage(GpImage *image, GpImage **cloneImage); }
function GdipCloneImage(Image: GpImage; out CloneImage: GpImage): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipDisposeImage(GpImage *image); }
function GdipDisposeImage(Image: GpImage): TGPStatus; stdcall; external GdiPlusDll;

{ GdipSaveImageToFile(GpImage *image, GDIPCONST WCHAR* filename, GDIPCONST CLSID* clsidEncoder, GDIPCONST EncoderParameters* encoderParams); }
function GdipSaveImageToFile(Image: GpImage; const Filename: PWideChar;
  const ClsidEncoder: TGUID; const EncoderParams: PGPNativeEncoderParameters): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipSaveImageToStream(GpImage *image, IStream* stream, GDIPCONST CLSID* clsidEncoder, GDIPCONST EncoderParameters* encoderParams); }
function GdipSaveImageToStream(Image: GpImage; const Stream: IStream;
  const ClsidEncoder: TGUID; const EncoderParams: PGPNativeEncoderParameters): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipSaveAdd(GpImage *image, GDIPCONST EncoderParameters* encoderParams); }
function GdipSaveAdd(Image: GpImage; const EncoderParams: PGPNativeEncoderParameters): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipSaveAddImage(GpImage *image, GpImage* newImage, GDIPCONST EncoderParameters* encoderParams); }
function GdipSaveAddImage(Image: GpImage; NewImage: GpImage;
  const EncoderParams: PGPNativeEncoderParameters): TGPStatus; stdcall; external GdiPlusDll;

{ GdipGetImageGraphicsContext(GpImage *image, GpGraphics **graphics); }
function GdipGetImageGraphicsContext(Image: GpImage; out Graphics: GpGraphics): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetImageBounds(GpImage *image, GpRectF *srcRect, GpUnit *srcUnit); }
function GdipGetImageBounds(Image: GpImage; out SrcRect: TGPRectF;
  out SrcUnit: TGPUnit): TGPStatus; stdcall; external GdiPlusDll;

{ GdipGetImageDimension(GpImage *image, REAL *width, REAL *height); }
function GdipGetImageDimension(Image: GpImage; out Width: Single;
  out Height: Single): TGPStatus; stdcall; external GdiPlusDll;

{ GdipGetImageType(GpImage *image, ImageType *type); }
function GdipGetImageType(Image: GpImage; out AType: TGPImageType): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetImageWidth(GpImage *image, UINT *width); }
function GdipGetImageWidth(Image: GpImage; out Width: Cardinal): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetImageHeight(GpImage *image, UINT *height); }
function GdipGetImageHeight(Image: GpImage; out Height: Cardinal): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetImageHorizontalResolution(GpImage *image, REAL *resolution); }
function GdipGetImageHorizontalResolution(Image: GpImage; out Resolution: Single): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetImageVerticalResolution(GpImage *image, REAL *resolution); }
function GdipGetImageVerticalResolution(Image: GpImage; out Resolution: Single): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetImageFlags(GpImage *image, UINT *flags); }
function GdipGetImageFlags(Image: GpImage; out Flags: TGPImageFlags): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetImageRawFormat(GpImage *image, GUID *format); }
function GdipGetImageRawFormat(Image: GpImage; out Format: TGUID): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetImagePixelFormat(GpImage *image, PixelFormat *format); }
function GdipGetImagePixelFormat(Image: GpImage; out Format: TGPPixelFormat): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetImageThumbnail(GpImage *image, UINT thumbWidth, UINT thumbHeight, GpImage **thumbImage, GetThumbnailImageAbort callback, VOID * callbackData); }
function GdipGetImageThumbnail(Image: GpImage; ThumbWidth: Cardinal;
  ThumbHeight: Cardinal; out ThumbImage: GpImage;
  Callback: TGPGetThumbnailImageAbort; CallbackData: Pointer): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetEncoderParameterListSize(GpImage *image, GDIPCONST CLSID* clsidEncoder, UINT* size); }
function GdipGetEncoderParameterListSize(Image: GpImage;
  const ClsidEncoder: PGUID; out Size: Cardinal): TGPStatus; stdcall; external GdiPlusDll;

{ GdipGetEncoderParameterList(GpImage *image, GDIPCONST CLSID* clsidEncoder, UINT size, EncoderParameters* buffer); }
function GdipGetEncoderParameterList(Image: GpImage; const ClsidEncoder: PGUID;
  Size: Cardinal; Buffer: PGPNativeEncoderParameters): TGPStatus; stdcall; external GdiPlusDll;

{ GdipImageGetFrameDimensionsCount(GpImage* image, UINT* count); }
function GdipImageGetFrameDimensionsCount(Image: GpImage; out Count: Cardinal): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipImageGetFrameDimensionsList(GpImage* image, GUID* dimensionIDs, UINT count); }
function GdipImageGetFrameDimensionsList(Image: GpImage; DimensionIDs: PGUID;
  Count: Cardinal): TGPStatus; stdcall; external GdiPlusDll;

{ GdipImageGetFrameCount(GpImage *image, GDIPCONST GUID* dimensionID, UINT* count); }
function GdipImageGetFrameCount(Image: GpImage; const DimensionID: TGUID;
  out Count: Cardinal): TGPStatus; stdcall; external GdiPlusDll;

{ GdipImageSelectActiveFrame(GpImage *image, GDIPCONST GUID* dimensionID, UINT frameIndex); }
function GdipImageSelectActiveFrame(Image: GpImage; const DimensionID: TGUID;
  FrameIndex: Cardinal): TGPStatus; stdcall; external GdiPlusDll;

{ GdipImageRotateFlip(GpImage *image, RotateFlipType rfType); }
function GdipImageRotateFlip(Image: GpImage; RfType: TGPRotateFlipType): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetImagePalette(GpImage *image, ColorPalette *palette, INT size); }
function GdipGetImagePalette(Image: GpImage; Palette: PGPNativeColorPalette;
  Size: Integer): TGPStatus; stdcall; external GdiPlusDll;

{ GdipSetImagePalette(GpImage *image, GDIPCONST ColorPalette *palette); }
function GdipSetImagePalette(Image: GpImage; const Palette: PGPNativeColorPalette): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetImagePaletteSize(GpImage *image, INT *size); }
function GdipGetImagePaletteSize(Image: GpImage; out Size: Integer): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetPropertyCount(GpImage *image, UINT* numOfProperty); }
function GdipGetPropertyCount(Image: GpImage; out NumOfProperty: Cardinal): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetPropertyIdList(GpImage *image, UINT numOfProperty, PROPID* list); }
function GdipGetPropertyIdList(Image: GpImage; NumOfProperty: Cardinal;
  List: PPropID): TGPStatus; stdcall; external GdiPlusDll;

{ GdipGetPropertyItemSize(GpImage *image, PROPID propId, UINT* size); }
function GdipGetPropertyItemSize(Image: GpImage; PropId: TPropID;
  out Size: Cardinal): TGPStatus; stdcall; external GdiPlusDll;

{ GdipGetPropertyItem(GpImage *image, PROPID propId,UINT propSize, PropertyItem* buffer); }
function GdipGetPropertyItem(Image: GpImage; PropId: TPropID;
  PropSize: Cardinal; Buffer: PGPNativePropertyItem): TGPStatus; stdcall; external GdiPlusDll;

{ GdipGetPropertySize(GpImage *image, UINT* totalBufferSize, UINT* numProperties); }
function GdipGetPropertySize(Image: GpImage; out TotalBufferSize: Cardinal;
  out NumProperties: Cardinal): TGPStatus; stdcall; external GdiPlusDll;

{ GdipGetAllPropertyItems(GpImage *image, UINT totalBufferSize, UINT numProperties, PropertyItem* allItems); }
function GdipGetAllPropertyItems(Image: GpImage; TotalBufferSize: Cardinal;
  NumProperties: Cardinal; AllItems: PGPNativePropertyItem): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipRemovePropertyItem(GpImage *image, PROPID propId); }
function GdipRemovePropertyItem(Image: GpImage; PropId: TPropID): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipSetPropertyItem(GpImage *image, GDIPCONST PropertyItem* item); }
function GdipSetPropertyItem(Image: GpImage; const Item: PGPNativePropertyItem): TGPStatus; stdcall;
  external GdiPlusDll;

{$IF (GDIPVER >= $0110)}
{ GdipFindFirstImageItem(GpImage *image, ImageItemData* item); }
function GdipFindFirstImageItem(Image: GpImage; Item: PGPImageItemData): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipFindNextImageItem(GpImage *image, ImageItemData* item); }
function GdipFindNextImageItem(Image: GpImage; Item: PGPImageItemData): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetImageItemData(GpImage *image, ImageItemData* item); }
function GdipGetImageItemData(Image: GpImage; Item: PGPImageItemData): TGPStatus; stdcall;
  external GdiPlusDll;
{$IFEND}

{ GdipImageForceValidation(GpImage *image); }
function GdipImageForceValidation(Image: GpImage): TGPStatus; stdcall;
  external GdiPlusDll;

//----------------------------------------------------------------------------
// Bitmap APIs
//----------------------------------------------------------------------------

{ GdipCreateBitmapFromStream(IStream* stream, GpBitmap **bitmap); }
function GdipCreateBitmapFromStream(const Stream: IStream; out Bitmap: GpBitmap): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipCreateBitmapFromFile(GDIPCONST WCHAR* filename, GpBitmap **bitmap); }
function GdipCreateBitmapFromFile(const Filename: PWideChar;
  out Bitmap: GpBitmap): TGPStatus; stdcall; external GdiPlusDll;

{ GdipCreateBitmapFromStreamICM(IStream* stream, GpBitmap **bitmap); }
function GdipCreateBitmapFromStreamICM(const Stream: IStream;
  out Bitmap: GpBitmap): TGPStatus; stdcall; external GdiPlusDll;

{ GdipCreateBitmapFromFileICM(GDIPCONST WCHAR* filename, GpBitmap **bitmap); }
function GdipCreateBitmapFromFileICM(const Filename: PWideChar;
  out Bitmap: GpBitmap): TGPStatus; stdcall; external GdiPlusDll;

{ GdipCreateBitmapFromScan0(INT width, INT height, INT stride, PixelFormat format, BYTE* scan0, GpBitmap** bitmap); }
function GdipCreateBitmapFromScan0(Width: Integer; Height: Integer;
  Stride: Integer; Format: TGPPixelFormat; Scan0: PByte; out Bitmap: GpBitmap): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipCreateBitmapFromGraphics(INT width, INT height, GpGraphics* target, GpBitmap** bitmap); }
function GdipCreateBitmapFromGraphics(Width: Integer; Height: Integer;
  Target: GpGraphics; out Bitmap: GpBitmap): TGPStatus; stdcall; external GdiPlusDll;

{ GdipCreateBitmapFromDirectDrawSurface(IDirectDrawSurface7* surface, GpBitmap** bitmap); }
function GdipCreateBitmapFromDirectDrawSurface(const Surface: IUnknown;
  out Bitmap: GpBitmap): TGPStatus; stdcall; external GdiPlusDll;

{ GdipCreateBitmapFromGdiDib(GDIPCONST BITMAPINFO* gdiBitmapInfo, VOID* gdiBitmapData, GpBitmap** bitmap); }
function GdipCreateBitmapFromGdiDib(const GdiBitmapInfo: PBitmapInfo;
  GdiBitmapData: Pointer; out Bitmap: GpBitmap): TGPStatus; stdcall; external GdiPlusDll;

{ GdipCreateBitmapFromHBITMAP(HBITMAP hbm, HPALETTE hpal, GpBitmap** bitmap); }
function GdipCreateBitmapFromHBITMAP(Hbm: HBitmap; Hpal: HPalette;
  out Bitmap: GpBitmap): TGPStatus; stdcall; external GdiPlusDll;

{ GdipCreateHBITMAPFromBitmap(GpBitmap* bitmap, HBITMAP* hbmReturn, ARGB background); }
function GdipCreateHBITMAPFromBitmap(Bitmap: GpBitmap; out HbmReturn: HBitmap;
  Background: ARGB): TGPStatus; stdcall; external GdiPlusDll;

{ GdipCreateBitmapFromHICON(HICON hicon, GpBitmap** bitmap); }
function GdipCreateBitmapFromHICON(Hicon: HIcon; out Bitmap: GpBitmap): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipCreateHICONFromBitmap(GpBitmap* bitmap, HICON* hbmReturn); }
function GdipCreateHICONFromBitmap(Bitmap: GpBitmap; out HbmReturn: HIcon): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipCreateBitmapFromResource(HINSTANCE hInstance, GDIPCONST WCHAR* lpBitmapName, GpBitmap** bitmap); }
function GdipCreateBitmapFromResource(HInstance: HInst;
  const LpBitmapName: PWideChar; out Bitmap: GpBitmap): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipCloneBitmapArea(REAL x, REAL y, REAL width, REAL height, PixelFormat format, GpBitmap *srcBitmap, GpBitmap **dstBitmap); }
function GdipCloneBitmapArea(X: Single; Y: Single; Width: Single;
  Height: Single; Format: TGPPixelFormat; SrcBitmap: GpBitmap;
  out DstBitmap: GpBitmap): TGPStatus; stdcall; external GdiPlusDll;

{ GdipCloneBitmapAreaI(INT x, INT y, INT width, INT height, PixelFormat format, GpBitmap *srcBitmap, GpBitmap **dstBitmap); }
function GdipCloneBitmapAreaI(X: Integer; Y: Integer; Width: Integer;
  Height: Integer; Format: TGPPixelFormat; SrcBitmap: GpBitmap;
  out DstBitmap: GpBitmap): TGPStatus; stdcall; external GdiPlusDll;

{ GdipBitmapLockBits(GpBitmap* bitmap, GDIPCONST GpRect* rect, UINT flags, PixelFormat format, BitmapData* lockedBitmapData); }
function GdipBitmapLockBits(Bitmap: GpBitmap; const Rect: PGPRect;
  Flags: TGPImageLockMode; Format: TGPPixelFormat; out LockedBitmapData: TGPBitmapData): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipBitmapUnlockBits(GpBitmap* bitmap, BitmapData* lockedBitmapData); }
function GdipBitmapUnlockBits(Bitmap: GpBitmap; const LockedBitmapData: TGPBitmapData): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipBitmapGetPixel(GpBitmap* bitmap, INT x, INT y, ARGB *color); }
function GdipBitmapGetPixel(Bitmap: GpBitmap; X: Integer; Y: Integer;
  out Color: ARGB): TGPStatus; stdcall; external GdiPlusDll;

{ GdipBitmapSetPixel(GpBitmap* bitmap, INT x, INT y, ARGB color); }
function GdipBitmapSetPixel(Bitmap: GpBitmap; X: Integer; Y: Integer;
  Color: ARGB): TGPStatus; stdcall; external GdiPlusDll;

{$IF (GDIPVER >= $0110)}
{ GdipImageSetAbort( GpImage *pImage, GdiplusAbort *pIAbort ); }
function GdipImageSetAbort(PImage: GpImage; PIAbort: PGdiplusAbort): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGraphicsSetAbort( GpGraphics *pGraphics, GdiplusAbort *pIAbort ); }
function GdipGraphicsSetAbort(PGraphics: GpGraphics; PIAbort: PGdiplusAbort): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipBitmapConvertFormat( IN GpBitmap *pInputBitmap, PixelFormat format, DitherType dithertype, PaletteType palettetype, ColorPalette *palette, REAL alphaThresholdPercent ); }
function GdipBitmapConvertFormat(const InputBitmap: GpBitmap;
  Format: TGPPixelFormat; Dithertype: TGPDitherType; Palettetype: TGPPaletteType;
  Palette: PGPNativeColorPalette; AlphaThresholdPercent: Single): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipInitializePalette( OUT ColorPalette *palette, PaletteType palettetype, INT optimalColors, BOOL useTransparentColor, GpBitmap *bitmap ); }
function GdipInitializePalette(const Palette: PGPNativeColorPalette;
  Palettetype: TGPPaletteType; OptimalColors: Integer; UseTransparentColor: Bool;
  Bitmap: GpBitmap): TGPStatus; stdcall; external GdiPlusDll;

{ GdipBitmapApplyEffect( GpBitmap* bitmap, CGpEffect *effect, RECT *roi, BOOL useAuxData, VOID **auxData, INT *auxDataSize ); }
function GdipBitmapApplyEffect(Bitmap: GpBitmap; Effect: CGpEffect; Roi: Windows.PRect;
  UseAuxData: Bool; out AuxData: Pointer; out AuxDataSize: Integer): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipBitmapCreateApplyEffect( GpBitmap **inputBitmaps, INT numInputs, CGpEffect *effect, RECT *roi, RECT *outputRect, GpBitmap **outputBitmap, BOOL useAuxData, VOID **auxData, INT *auxDataSize ); }
function GdipBitmapCreateApplyEffect(const InputBitmaps: PGpBitmap;
  NumInputs: Integer; Effect: CGpEffect; Roi: Windows.PRect; OutputRect: Windows.PRect;
  out OutputBitmap: GpBitmap; UseAuxData: Bool; out AuxData: Pointer;
  out AuxDataSize: Integer): TGPStatus; stdcall; external GdiPlusDll;

{ GdipBitmapGetHistogram( GpBitmap* bitmap, IN HistogramFormat format, IN UINT NumberOfEntries, __out_bcount(sizeof(UINT)*256) UINT *channel0, __out_bcount(sizeof(UINT)*256) UINT *channel1, __out_bcount(sizeof(UINT)*256) UINT *channel2, __out_bcount(sizeof(UINT)*256) UINT *channel3 ); }
function GdipBitmapGetHistogram(Bitmap: GpBitmap;
  const Format: TGPHistogramFormat; const NumberOfEntries: Cardinal;
  Channel0: PCardinal; Channel1: PCardinal; Channel2: PCardinal;
  Channel3: PCardinal): TGPStatus; stdcall; external GdiPlusDll;

{ GdipBitmapGetHistogramSize( IN HistogramFormat format, OUT UINT *NumberOfEntries ); }
function GdipBitmapGetHistogramSize(const Format: TGPHistogramFormat;
  out NumberOfEntries: Cardinal): TGPStatus; stdcall; external GdiPlusDll;
{$IFEND}

{ GdipBitmapSetResolution(GpBitmap* bitmap, REAL xdpi, REAL ydpi); }
function GdipBitmapSetResolution(Bitmap: GpBitmap; Xdpi: Single; Ydpi: Single): TGPStatus; stdcall;
  external GdiPlusDll;

//----------------------------------------------------------------------------
// ImageAttributes APIs
//----------------------------------------------------------------------------

{ GdipCreateImageAttributes(GpImageAttributes **imageattr); }
function GdipCreateImageAttributes(out Imageattr: GpImageAttributes): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipCloneImageAttributes(GDIPCONST GpImageAttributes *imageattr, GpImageAttributes **cloneImageattr); }
function GdipCloneImageAttributes(const Imageattr: GpImageAttributes;
  out CloneImageattr: GpImageAttributes): TGPStatus; stdcall; external GdiPlusDll;

{ GdipDisposeImageAttributes(GpImageAttributes *imageattr); }
function GdipDisposeImageAttributes(Imageattr: GpImageAttributes): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipSetImageAttributesToIdentity(GpImageAttributes *imageattr, ColorAdjustType type); }
function GdipSetImageAttributesToIdentity(Imageattr: GpImageAttributes;
  AType: TGPColorAdjustType): TGPStatus; stdcall; external GdiPlusDll;

{ GdipResetImageAttributes(GpImageAttributes *imageattr, ColorAdjustType type); }
function GdipResetImageAttributes(Imageattr: GpImageAttributes;
  AType: TGPColorAdjustType): TGPStatus; stdcall; external GdiPlusDll;

{ GdipSetImageAttributesColorMatrix(GpImageAttributes *imageattr, ColorAdjustType type, BOOL enableFlag, GDIPCONST ColorMatrix* colorMatrix, GDIPCONST ColorMatrix* grayMatrix, ColorMatrixFlags flags); }
function GdipSetImageAttributesColorMatrix(Imageattr: GpImageAttributes;
  AType: TGPColorAdjustType; EnableFlag: Bool; const ColorMatrix: PGPColorMatrix;
  const GrayMatrix: PGPColorMatrix; Flags: TGPColorMatrixFlags): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipSetImageAttributesThreshold(GpImageAttributes *imageattr, ColorAdjustType type, BOOL enableFlag, REAL threshold); }
function GdipSetImageAttributesThreshold(Imageattr: GpImageAttributes;
  AType: TGPColorAdjustType; EnableFlag: Bool; Threshold: Single): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipSetImageAttributesGamma(GpImageAttributes *imageattr, ColorAdjustType type, BOOL enableFlag, REAL gamma); }
function GdipSetImageAttributesGamma(Imageattr: GpImageAttributes;
  AType: TGPColorAdjustType; EnableFlag: Bool; Gamma: Single): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipSetImageAttributesNoOp(GpImageAttributes *imageattr, ColorAdjustType type, BOOL enableFlag); }
function GdipSetImageAttributesNoOp(Imageattr: GpImageAttributes;
  AType: TGPColorAdjustType; EnableFlag: Bool): TGPStatus; stdcall; external GdiPlusDll;

{ GdipSetImageAttributesColorKeys(GpImageAttributes *imageattr, ColorAdjustType type, BOOL enableFlag, ARGB colorLow, ARGB colorHigh); }
function GdipSetImageAttributesColorKeys(Imageattr: GpImageAttributes;
  AType: TGPColorAdjustType; EnableFlag: Bool; ColorLow: ARGB; ColorHigh: ARGB): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipSetImageAttributesOutputChannel(GpImageAttributes *imageattr, ColorAdjustType type, BOOL enableFlag, ColorChannelFlags channelFlags); }
function GdipSetImageAttributesOutputChannel(Imageattr: GpImageAttributes;
  AType: TGPColorAdjustType; EnableFlag: Bool; ChannelFlags: TGPColorChannelFlags): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipSetImageAttributesOutputChannelColorProfile(GpImageAttributes *imageattr, ColorAdjustType type, BOOL enableFlag, GDIPCONST WCHAR *colorProfileFilename); }
function GdipSetImageAttributesOutputChannelColorProfile(
  Imageattr: GpImageAttributes; AType: TGPColorAdjustType; EnableFlag: Bool;
  const ColorProfileFilename: PWideChar): TGPStatus; stdcall; external GdiPlusDll;

{ GdipSetImageAttributesRemapTable(GpImageAttributes *imageattr, ColorAdjustType type, BOOL enableFlag, UINT mapSize, GDIPCONST ColorMap *map); }
function GdipSetImageAttributesRemapTable(Imageattr: GpImageAttributes;
  AType: TGPColorAdjustType; EnableFlag: Bool; MapSize: Cardinal;
  const Map: PGPColorMap): TGPStatus; stdcall; external GdiPlusDll;
{ GdipSetImageAttributesWrapMode( GpImageAttributes *imageAttr, WrapMode wrap, ARGB argb, BOOL clamp ); }
function GdipSetImageAttributesWrapMode(ImageAttr: GpImageAttributes;
  Wrap: TGPWrapMode; Argb: ARGB; Clamp: Bool): TGPStatus; stdcall; external GdiPlusDll;

{ GdipSetImageAttributesICMMode( GpImageAttributes *imageAttr, BOOL on ); }
function GdipSetImageAttributesICMMode(ImageAttr: GpImageAttributes; Enable: Bool): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetImageAttributesAdjustedPalette( GpImageAttributes *imageAttr, ColorPalette * colorPalette, ColorAdjustType colorAdjustType ); }
function GdipGetImageAttributesAdjustedPalette(ImageAttr: GpImageAttributes;
  ColorPalette: PGPNativeColorPalette; ColorAdjustType: TGPColorAdjustType): TGPStatus; stdcall;
  external GdiPlusDll;

//----------------------------------------------------------------------------
// Graphics APIs
//----------------------------------------------------------------------------

{ GdipFlush(GpGraphics *graphics, GpFlushIntention intention); }
function GdipFlush(Graphics: GpGraphics; Intention: TGPFlushIntention): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipCreateFromHDC(HDC hdc, GpGraphics **graphics); }
function GdipCreateFromHDC(Hdc: HDC; out Graphics: GpGraphics): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipCreateFromHDC2(HDC hdc, HANDLE hDevice, GpGraphics **graphics); }
function GdipCreateFromHDC2(Hdc: HDC; HDevice: THandle;
  out Graphics: GpGraphics): TGPStatus; stdcall; external GdiPlusDll;

{ GdipCreateFromHWND(HWND hwnd, GpGraphics **graphics); }
function GdipCreateFromHWND(Hwnd: HWnd; out Graphics: GpGraphics): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipCreateFromHWNDICM(HWND hwnd, GpGraphics **graphics); }
function GdipCreateFromHWNDICM(Hwnd: HWnd; out Graphics: GpGraphics): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipDeleteGraphics(GpGraphics *graphics); }
function GdipDeleteGraphics(Graphics: GpGraphics): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetDC(GpGraphics* graphics, HDC * hdc); }
function GdipGetDC(Graphics: GpGraphics; out Hdc: HDC): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipReleaseDC(GpGraphics* graphics, HDC hdc); }
function GdipReleaseDC(Graphics: GpGraphics; Hdc: HDC): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipSetCompositingMode(GpGraphics *graphics, CompositingMode compositingMode); }
function GdipSetCompositingMode(Graphics: GpGraphics;
  CompositingMode: TGPCompositingMode): TGPStatus; stdcall; external GdiPlusDll;

{ GdipGetCompositingMode(GpGraphics *graphics, CompositingMode *compositingMode); }
function GdipGetCompositingMode(Graphics: GpGraphics;
  out CompositingMode: TGPCompositingMode): TGPStatus; stdcall; external GdiPlusDll;

{ GdipSetRenderingOrigin(GpGraphics *graphics, INT x, INT y); }
function GdipSetRenderingOrigin(Graphics: GpGraphics; X: Integer; Y: Integer): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetRenderingOrigin(GpGraphics *graphics, INT *x, INT *y); }
function GdipGetRenderingOrigin(Graphics: GpGraphics; out X: Integer; out Y: Integer): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipSetCompositingQuality(GpGraphics *graphics, CompositingQuality compositingQuality); }
function GdipSetCompositingQuality(Graphics: GpGraphics;
  CompositingQuality: TGPCompositingQuality): TGPStatus; stdcall; external GdiPlusDll;

{ GdipGetCompositingQuality(GpGraphics *graphics, CompositingQuality *compositingQuality); }
function GdipGetCompositingQuality(Graphics: GpGraphics;
  out CompositingQuality: TGPCompositingQuality): TGPStatus; stdcall; external GdiPlusDll;

{ GdipSetSmoothingMode(GpGraphics *graphics, SmoothingMode smoothingMode); }
function GdipSetSmoothingMode(Graphics: GpGraphics;
  SmoothingMode: TGPSmoothingMode): TGPStatus; stdcall; external GdiPlusDll;

{ GdipGetSmoothingMode(GpGraphics *graphics, SmoothingMode *smoothingMode); }
function GdipGetSmoothingMode(Graphics: GpGraphics;
  out SmoothingMode: TGPSmoothingMode): TGPStatus; stdcall; external GdiPlusDll;

{ GdipSetPixelOffsetMode(GpGraphics* graphics, PixelOffsetMode pixelOffsetMode); }
function GdipSetPixelOffsetMode(Graphics: GpGraphics;
  PixelOffsetMode: TGPPixelOffsetMode): TGPStatus; stdcall; external GdiPlusDll;

{ GdipGetPixelOffsetMode(GpGraphics *graphics, PixelOffsetMode *pixelOffsetMode); }
function GdipGetPixelOffsetMode(Graphics: GpGraphics;
  out PixelOffsetMode: TGPPixelOffsetMode): TGPStatus; stdcall; external GdiPlusDll;

{ GdipSetTextRenderingHint(GpGraphics *graphics, TextRenderingHint mode); }
function GdipSetTextRenderingHint(Graphics: GpGraphics;
  Mode: TGPTextRenderingHint): TGPStatus; stdcall; external GdiPlusDll;

{ GdipGetTextRenderingHint(GpGraphics *graphics, TextRenderingHint *mode); }
function GdipGetTextRenderingHint(Graphics: GpGraphics;
  out Mode: TGPTextRenderingHint): TGPStatus; stdcall; external GdiPlusDll;

{ GdipSetTextContrast(GpGraphics *graphics, UINT contrast); }
function GdipSetTextContrast(Graphics: GpGraphics; Contrast: Integer): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetTextContrast(GpGraphics *graphics, UINT * contrast); }
function GdipGetTextContrast(Graphics: GpGraphics; out Contrast: Integer): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipSetInterpolationMode(GpGraphics *graphics, InterpolationMode interpolationMode); }
function GdipSetInterpolationMode(Graphics: GpGraphics;
  InterpolationMode: TGPInterpolationMode): TGPStatus; stdcall; external GdiPlusDll;

{ GdipGetInterpolationMode(GpGraphics *graphics, InterpolationMode *interpolationMode); }
function GdipGetInterpolationMode(Graphics: GpGraphics;
  out InterpolationMode: TGPInterpolationMode): TGPStatus; stdcall; external GdiPlusDll;

{ GdipSetWorldTransform(GpGraphics *graphics, GpMatrix *matrix); }
function GdipSetWorldTransform(Graphics: GpGraphics; Matrix: GpMatrix): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipResetWorldTransform(GpGraphics *graphics); }
function GdipResetWorldTransform(Graphics: GpGraphics): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipMultiplyWorldTransform(GpGraphics *graphics, GDIPCONST GpMatrix *matrix, GpMatrixOrder order); }
function GdipMultiplyWorldTransform(Graphics: GpGraphics;
  const Matrix: GpMatrix; Order: TGPMatrixOrder): TGPStatus; stdcall; external GdiPlusDll;

{ GdipTranslateWorldTransform(GpGraphics *graphics, REAL dx, REAL dy, GpMatrixOrder order); }
function GdipTranslateWorldTransform(Graphics: GpGraphics; Dx: Single;
  Dy: Single; Order: TGPMatrixOrder): TGPStatus; stdcall; external GdiPlusDll;

{ GdipScaleWorldTransform(GpGraphics *graphics, REAL sx, REAL sy, GpMatrixOrder order); }
function GdipScaleWorldTransform(Graphics: GpGraphics; Sx: Single; Sy: Single;
  Order: TGPMatrixOrder): TGPStatus; stdcall; external GdiPlusDll;

{ GdipRotateWorldTransform(GpGraphics *graphics, REAL angle, GpMatrixOrder order); }
function GdipRotateWorldTransform(Graphics: GpGraphics; Angle: Single;
  Order: TGPMatrixOrder): TGPStatus; stdcall; external GdiPlusDll;

{ GdipGetWorldTransform(GpGraphics *graphics, GpMatrix *matrix); }
function GdipGetWorldTransform(Graphics: GpGraphics; Matrix: GpMatrix): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipResetPageTransform(GpGraphics *graphics); }
function GdipResetPageTransform(Graphics: GpGraphics): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetPageUnit(GpGraphics *graphics, GpUnit *unit); }
function GdipGetPageUnit(Graphics: GpGraphics; out AUnit: TGPUnit): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetPageScale(GpGraphics *graphics, REAL *scale); }
function GdipGetPageScale(Graphics: GpGraphics; out Scale: Single): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipSetPageUnit(GpGraphics *graphics, GpUnit unit); }
function GdipSetPageUnit(Graphics: GpGraphics; AUnit: TGPUnit): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipSetPageScale(GpGraphics *graphics, REAL scale); }
function GdipSetPageScale(Graphics: GpGraphics; Scale: Single): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetDpiX(GpGraphics *graphics, REAL* dpi); }
function GdipGetDpiX(Graphics: GpGraphics; out Dpi: Single): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetDpiY(GpGraphics *graphics, REAL* dpi); }
function GdipGetDpiY(Graphics: GpGraphics; out Dpi: Single): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipTransformPoints(GpGraphics *graphics, GpCoordinateSpace destSpace, GpCoordinateSpace srcSpace, GpPointF *points, INT count); }
function GdipTransformPoints(Graphics: GpGraphics; DestSpace: TGPCoordinateSpace;
  SrcSpace: TGPCoordinateSpace; Points: PGPPointF; Count: Integer): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipTransformPointsI(GpGraphics *graphics, GpCoordinateSpace destSpace, GpCoordinateSpace srcSpace, GpPoint *points, INT count); }
function GdipTransformPointsI(Graphics: GpGraphics; DestSpace: TGPCoordinateSpace;
  SrcSpace: TGPCoordinateSpace; Points: PGPPoint; Count: Integer): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetNearestColor(GpGraphics *graphics, ARGB* argb); }
function GdipGetNearestColor(Graphics: GpGraphics; Argb: PARGB): TGPStatus; stdcall;
  external GdiPlusDll;

// Creates the Win9x Halftone Palette (even on NT) with correct Desktop colors
function GdipCreateHalftonePalette: HPalette; external GdiPlusDll;

{ GdipDrawLine(GpGraphics *graphics, GpPen *pen, REAL x1, REAL y1, REAL x2, REAL y2); }
function GdipDrawLine(Graphics: GpGraphics; Pen: GpPen; X1: Single; Y1: Single;
  X2: Single; Y2: Single): TGPStatus; stdcall; external GdiPlusDll;

{ GdipDrawLineI(GpGraphics *graphics, GpPen *pen, INT x1, INT y1, INT x2, INT y2); }
function GdipDrawLineI(Graphics: GpGraphics; Pen: GpPen; X1: Integer;
  Y1: Integer; X2: Integer; Y2: Integer): TGPStatus; stdcall; external GdiPlusDll;

{ GdipDrawLines(GpGraphics *graphics, GpPen *pen, GDIPCONST GpPointF *points, INT count); }
function GdipDrawLines(Graphics: GpGraphics; Pen: GpPen; const Points: PGPPointF;
  Count: Integer): TGPStatus; stdcall; external GdiPlusDll;

{ GdipDrawLinesI(GpGraphics *graphics, GpPen *pen, GDIPCONST GpPoint *points, INT count); }
function GdipDrawLinesI(Graphics: GpGraphics; Pen: GpPen; const Points: PGPPoint;
  Count: Integer): TGPStatus; stdcall; external GdiPlusDll;

{ GdipDrawArc(GpGraphics *graphics, GpPen *pen, REAL x, REAL y, REAL width, REAL height, REAL startAngle, REAL sweepAngle); }
function GdipDrawArc(Graphics: GpGraphics; Pen: GpPen; X: Single; Y: Single;
  Width: Single; Height: Single; StartAngle: Single; SweepAngle: Single): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipDrawArcI(GpGraphics *graphics, GpPen *pen, INT x, INT y, INT width, INT height, REAL startAngle, REAL sweepAngle); }
function GdipDrawArcI(Graphics: GpGraphics; Pen: GpPen; X: Integer; Y: Integer;
  Width: Integer; Height: Integer; StartAngle: Single; SweepAngle: Single): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipDrawBezier(GpGraphics *graphics, GpPen *pen, REAL x1, REAL y1, REAL x2, REAL y2, REAL x3, REAL y3, REAL x4, REAL y4); }
function GdipDrawBezier(Graphics: GpGraphics; Pen: GpPen; X1: Single;
  Y1: Single; X2: Single; Y2: Single; X3: Single; Y3: Single; X4: Single;
  Y4: Single): TGPStatus; stdcall; external GdiPlusDll;

{ GdipDrawBezierI(GpGraphics *graphics, GpPen *pen, INT x1, INT y1, INT x2, INT y2, INT x3, INT y3, INT x4, INT y4); }
function GdipDrawBezierI(Graphics: GpGraphics; Pen: GpPen; X1: Integer;
  Y1: Integer; X2: Integer; Y2: Integer; X3: Integer; Y3: Integer; X4: Integer;
  Y4: Integer): TGPStatus; stdcall; external GdiPlusDll;

{ GdipDrawBeziers(GpGraphics *graphics, GpPen *pen, GDIPCONST GpPointF *points, INT count); }
function GdipDrawBeziers(Graphics: GpGraphics; Pen: GpPen;
  const Points: PGPPointF; Count: Integer): TGPStatus; stdcall; external GdiPlusDll;

{ GdipDrawBeziersI(GpGraphics *graphics, GpPen *pen, GDIPCONST GpPoint *points, INT count); }
function GdipDrawBeziersI(Graphics: GpGraphics; Pen: GpPen;
  const Points: PGPPoint; Count: Integer): TGPStatus; stdcall; external GdiPlusDll;

{ GdipDrawRectangle(GpGraphics *graphics, GpPen *pen, REAL x, REAL y, REAL width, REAL height); }
function GdipDrawRectangle(Graphics: GpGraphics; Pen: GpPen; X: Single;
  Y: Single; Width: Single; Height: Single): TGPStatus; stdcall; external GdiPlusDll;

{ GdipDrawRectangleI(GpGraphics *graphics, GpPen *pen, INT x, INT y, INT width, INT height); }
function GdipDrawRectangleI(Graphics: GpGraphics; Pen: GpPen; X: Integer;
  Y: Integer; Width: Integer; Height: Integer): TGPStatus; stdcall; external GdiPlusDll;

{ GdipDrawRectangles(GpGraphics *graphics, GpPen *pen, GDIPCONST GpRectF *rects, INT count); }
function GdipDrawRectangles(Graphics: GpGraphics; Pen: GpPen;
  const Rects: PGPRectF; Count: Integer): TGPStatus; stdcall; external GdiPlusDll;

{ GdipDrawRectanglesI(GpGraphics *graphics, GpPen *pen, GDIPCONST GpRect *rects, INT count); }
function GdipDrawRectanglesI(Graphics: GpGraphics; Pen: GpPen;
  const Rects: PGPRect; Count: Integer): TGPStatus; stdcall; external GdiPlusDll;

{ GdipDrawEllipse(GpGraphics *graphics, GpPen *pen, REAL x, REAL y, REAL width, REAL height); }
function GdipDrawEllipse(Graphics: GpGraphics; Pen: GpPen; X: Single; Y: Single;
  Width: Single; Height: Single): TGPStatus; stdcall; external GdiPlusDll;

{ GdipDrawEllipseI(GpGraphics *graphics, GpPen *pen, INT x, INT y, INT width, INT height); }
function GdipDrawEllipseI(Graphics: GpGraphics; Pen: GpPen; X: Integer;
  Y: Integer; Width: Integer; Height: Integer): TGPStatus; stdcall; external GdiPlusDll;

{ GdipDrawPie(GpGraphics *graphics, GpPen *pen, REAL x, REAL y, REAL width, REAL height, REAL startAngle, REAL sweepAngle); }
function GdipDrawPie(Graphics: GpGraphics; Pen: GpPen; X: Single; Y: Single;
  Width: Single; Height: Single; StartAngle: Single; SweepAngle: Single): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipDrawPieI(GpGraphics *graphics, GpPen *pen, INT x, INT y, INT width, INT height, REAL startAngle, REAL sweepAngle); }
function GdipDrawPieI(Graphics: GpGraphics; Pen: GpPen; X: Integer; Y: Integer;
  Width: Integer; Height: Integer; StartAngle: Single; SweepAngle: Single): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipDrawPolygon(GpGraphics *graphics, GpPen *pen, GDIPCONST GpPointF *points, INT count); }
function GdipDrawPolygon(Graphics: GpGraphics; Pen: GpPen;
  const Points: PGPPointF; Count: Integer): TGPStatus; stdcall; external GdiPlusDll;

{ GdipDrawPolygonI(GpGraphics *graphics, GpPen *pen, GDIPCONST GpPoint *points, INT count); }
function GdipDrawPolygonI(Graphics: GpGraphics; Pen: GpPen;
  const Points: PGPPoint; Count: Integer): TGPStatus; stdcall; external GdiPlusDll;

{ GdipDrawPath(GpGraphics *graphics, GpPen *pen, GpPath *path); }
function GdipDrawPath(Graphics: GpGraphics; Pen: GpPen; Path: GpPath): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipDrawCurve(GpGraphics *graphics, GpPen *pen, GDIPCONST GpPointF *points, INT count); }
function GdipDrawCurve(Graphics: GpGraphics; Pen: GpPen; const Points: PGPPointF;
  Count: Integer): TGPStatus; stdcall; external GdiPlusDll;

{ GdipDrawCurveI(GpGraphics *graphics, GpPen *pen, GDIPCONST GpPoint *points, INT count); }
function GdipDrawCurveI(Graphics: GpGraphics; Pen: GpPen; const Points: PGPPoint;
  Count: Integer): TGPStatus; stdcall; external GdiPlusDll;

{ GdipDrawCurve2(GpGraphics *graphics, GpPen *pen, GDIPCONST GpPointF *points, INT count, REAL tension); }
function GdipDrawCurve2(Graphics: GpGraphics; Pen: GpPen; const Points: PGPPointF;
  Count: Integer; Tension: Single): TGPStatus; stdcall; external GdiPlusDll;

{ GdipDrawCurve2I(GpGraphics *graphics, GpPen *pen, GDIPCONST GpPoint *points, INT count, REAL tension); }
function GdipDrawCurve2I(Graphics: GpGraphics; Pen: GpPen; const Points: PGPPoint;
  Count: Integer; Tension: Single): TGPStatus; stdcall; external GdiPlusDll;

{ GdipDrawCurve3(GpGraphics *graphics, GpPen *pen, GDIPCONST GpPointF *points, INT count, INT offset, INT numberOfSegments, REAL tension); }
function GdipDrawCurve3(Graphics: GpGraphics; Pen: GpPen; const Points: PGPPointF;
  Count: Integer; Offset: Integer; NumberOfSegments: Integer; Tension: Single): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipDrawCurve3I(GpGraphics *graphics, GpPen *pen, GDIPCONST GpPoint *points, INT count, INT offset, INT numberOfSegments, REAL tension); }
function GdipDrawCurve3I(Graphics: GpGraphics; Pen: GpPen; const Points: PGPPoint;
  Count: Integer; Offset: Integer; NumberOfSegments: Integer; Tension: Single): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipDrawClosedCurve(GpGraphics *graphics, GpPen *pen, GDIPCONST GpPointF *points, INT count); }
function GdipDrawClosedCurve(Graphics: GpGraphics; Pen: GpPen;
  const Points: PGPPointF; Count: Integer): TGPStatus; stdcall; external GdiPlusDll;

{ GdipDrawClosedCurveI(GpGraphics *graphics, GpPen *pen, GDIPCONST GpPoint *points, INT count); }
function GdipDrawClosedCurveI(Graphics: GpGraphics; Pen: GpPen;
  const Points: PGPPoint; Count: Integer): TGPStatus; stdcall; external GdiPlusDll;

{ GdipDrawClosedCurve2(GpGraphics *graphics, GpPen *pen, GDIPCONST GpPointF *points, INT count, REAL tension); }
function GdipDrawClosedCurve2(Graphics: GpGraphics; Pen: GpPen;
  const Points: PGPPointF; Count: Integer; Tension: Single): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipDrawClosedCurve2I(GpGraphics *graphics, GpPen *pen, GDIPCONST GpPoint *points, INT count, REAL tension); }
function GdipDrawClosedCurve2I(Graphics: GpGraphics; Pen: GpPen;
  const Points: PGPPoint; Count: Integer; Tension: Single): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGraphicsClear(GpGraphics *graphics, ARGB color); }
function GdipGraphicsClear(Graphics: GpGraphics; Color: ARGB): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipFillRectangle(GpGraphics *graphics, GpBrush *brush, REAL x, REAL y, REAL width, REAL height); }
function GdipFillRectangle(Graphics: GpGraphics; Brush: GpBrush; X: Single;
  Y: Single; Width: Single; Height: Single): TGPStatus; stdcall; external GdiPlusDll;

{ GdipFillRectangleI(GpGraphics *graphics, GpBrush *brush, INT x, INT y, INT width, INT height); }
function GdipFillRectangleI(Graphics: GpGraphics; Brush: GpBrush; X: Integer;
  Y: Integer; Width: Integer; Height: Integer): TGPStatus; stdcall; external GdiPlusDll;

{ GdipFillRectangles(GpGraphics *graphics, GpBrush *brush, GDIPCONST GpRectF *rects, INT count); }
function GdipFillRectangles(Graphics: GpGraphics; Brush: GpBrush;
  const Rects: PGPRectF; Count: Integer): TGPStatus; stdcall; external GdiPlusDll;

{ GdipFillRectanglesI(GpGraphics *graphics, GpBrush *brush, GDIPCONST GpRect *rects, INT count); }
function GdipFillRectanglesI(Graphics: GpGraphics; Brush: GpBrush;
  const Rects: PGPRect; Count: Integer): TGPStatus; stdcall; external GdiPlusDll;

{ GdipFillPolygon(GpGraphics *graphics, GpBrush *brush, GDIPCONST GpPointF *points, INT count, GpFillMode fillMode); }
function GdipFillPolygon(Graphics: GpGraphics; Brush: GpBrush;
  const Points: PGPPointF; Count: Integer; FillMode: TGPFillMode): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipFillPolygonI(GpGraphics *graphics, GpBrush *brush, GDIPCONST GpPoint *points, INT count, GpFillMode fillMode); }
function GdipFillPolygonI(Graphics: GpGraphics; Brush: GpBrush;
  const Points: PGPPoint; Count: Integer; FillMode: TGPFillMode): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipFillPolygon2(GpGraphics *graphics, GpBrush *brush, GDIPCONST GpPointF *points, INT count); }
function GdipFillPolygon2(Graphics: GpGraphics; Brush: GpBrush;
  const Points: PGPPointF; Count: Integer): TGPStatus; stdcall; external GdiPlusDll;

{ GdipFillPolygon2I(GpGraphics *graphics, GpBrush *brush, GDIPCONST GpPoint *points, INT count); }
function GdipFillPolygon2I(Graphics: GpGraphics; Brush: GpBrush;
  const Points: PGPPoint; Count: Integer): TGPStatus; stdcall; external GdiPlusDll;

{ GdipFillEllipse(GpGraphics *graphics, GpBrush *brush, REAL x, REAL y, REAL width, REAL height); }
function GdipFillEllipse(Graphics: GpGraphics; Brush: GpBrush; X: Single;
  Y: Single; Width: Single; Height: Single): TGPStatus; stdcall; external GdiPlusDll;

{ GdipFillEllipseI(GpGraphics *graphics, GpBrush *brush, INT x, INT y, INT width, INT height); }
function GdipFillEllipseI(Graphics: GpGraphics; Brush: GpBrush; X: Integer;
  Y: Integer; Width: Integer; Height: Integer): TGPStatus; stdcall; external GdiPlusDll;

{ GdipFillPie(GpGraphics *graphics, GpBrush *brush, REAL x, REAL y, REAL width, REAL height, REAL startAngle, REAL sweepAngle); }
function GdipFillPie(Graphics: GpGraphics; Brush: GpBrush; X: Single; Y: Single;
  Width: Single; Height: Single; StartAngle: Single; SweepAngle: Single): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipFillPieI(GpGraphics *graphics, GpBrush *brush, INT x, INT y, INT width, INT height, REAL startAngle, REAL sweepAngle); }
function GdipFillPieI(Graphics: GpGraphics; Brush: GpBrush; X: Integer;
  Y: Integer; Width: Integer; Height: Integer; StartAngle: Single;
  SweepAngle: Single): TGPStatus; stdcall; external GdiPlusDll;

{ GdipFillPath(GpGraphics *graphics, GpBrush *brush, GpPath *path); }
function GdipFillPath(Graphics: GpGraphics; Brush: GpBrush; Path: GpPath): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipFillClosedCurve(GpGraphics *graphics, GpBrush *brush, GDIPCONST GpPointF *points, INT count); }
function GdipFillClosedCurve(Graphics: GpGraphics; Brush: GpBrush;
  const Points: PGPPointF; Count: Integer): TGPStatus; stdcall; external GdiPlusDll;

{ GdipFillClosedCurveI(GpGraphics *graphics, GpBrush *brush, GDIPCONST GpPoint *points, INT count); }
function GdipFillClosedCurveI(Graphics: GpGraphics; Brush: GpBrush;
  const Points: PGPPoint; Count: Integer): TGPStatus; stdcall; external GdiPlusDll;

{ GdipFillClosedCurve2(GpGraphics *graphics, GpBrush *brush, GDIPCONST GpPointF *points, INT count, REAL tension, GpFillMode fillMode); }
function GdipFillClosedCurve2(Graphics: GpGraphics; Brush: GpBrush;
  const Points: PGPPointF; Count: Integer; Tension: Single; FillMode: TGPFillMode): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipFillClosedCurve2I(GpGraphics *graphics, GpBrush *brush, GDIPCONST GpPoint *points, INT count, REAL tension, GpFillMode fillMode); }
function GdipFillClosedCurve2I(Graphics: GpGraphics; Brush: GpBrush;
  const Points: PGPPoint; Count: Integer; Tension: Single; FillMode: TGPFillMode): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipFillRegion(GpGraphics *graphics, GpBrush *brush, GpRegion *region); }
function GdipFillRegion(Graphics: GpGraphics; Brush: GpBrush; Region: GpRegion): TGPStatus; stdcall;
  external GdiPlusDll;

{$IF (GDIPVER >= $0110)}
{ GdipDrawImageFX( GpGraphics *graphics, GpImage *image, GpRectF *source, GpMatrix *xForm, CGpEffect *effect, GpImageAttributes *imageAttributes, GpUnit srcUnit ); }
function GdipDrawImageFX(Graphics: GpGraphics; Image: GpImage; Source: PGPRectF;
  XForm: GpMatrix; Effect: CGpEffect; ImageAttributes: GpImageAttributes;
  SrcUnit: TGPUnit): TGPStatus; stdcall; external GdiPlusDll;
{$IFEND}

{ GdipDrawImage(GpGraphics *graphics, GpImage *image, REAL x, REAL y); }
function GdipDrawImage(Graphics: GpGraphics; Image: GpImage; X: Single;
  Y: Single): TGPStatus; stdcall; external GdiPlusDll;

{ GdipDrawImageI(GpGraphics *graphics, GpImage *image, INT x, INT y); }
function GdipDrawImageI(Graphics: GpGraphics; Image: GpImage; X: Integer;
  Y: Integer): TGPStatus; stdcall; external GdiPlusDll;

{ GdipDrawImageRect(GpGraphics *graphics, GpImage *image, REAL x, REAL y, REAL width, REAL height); }
function GdipDrawImageRect(Graphics: GpGraphics; Image: GpImage; X: Single;
  Y: Single; Width: Single; Height: Single): TGPStatus; stdcall; external GdiPlusDll;

{ GdipDrawImageRectI(GpGraphics *graphics, GpImage *image, INT x, INT y, INT width, INT height); }
function GdipDrawImageRectI(Graphics: GpGraphics; Image: GpImage; X: Integer;
  Y: Integer; Width: Integer; Height: Integer): TGPStatus; stdcall; external GdiPlusDll;

{ GdipDrawImagePoints(GpGraphics *graphics, GpImage *image, GDIPCONST GpPointF *dstpoints, INT count); }
function GdipDrawImagePoints(Graphics: GpGraphics; Image: GpImage;
  const Dstpoints: PGPPointF; Count: Integer): TGPStatus; stdcall; external GdiPlusDll;

{ GdipDrawImagePointsI(GpGraphics *graphics, GpImage *image, GDIPCONST GpPoint *dstpoints, INT count); }
function GdipDrawImagePointsI(Graphics: GpGraphics; Image: GpImage;
  const Dstpoints: PGPPoint; Count: Integer): TGPStatus; stdcall; external GdiPlusDll;

{ GdipDrawImagePointRect(GpGraphics *graphics, GpImage *image, REAL x, REAL y, REAL srcx, REAL srcy, REAL srcwidth, REAL srcheight, GpUnit srcUnit); }
function GdipDrawImagePointRect(Graphics: GpGraphics; Image: GpImage; X: Single;
  Y: Single; Srcx: Single; Srcy: Single; Srcwidth: Single; Srcheight: Single;
  SrcUnit: TGPUnit): TGPStatus; stdcall; external GdiPlusDll;

{ GdipDrawImagePointRectI(GpGraphics *graphics, GpImage *image, INT x, INT y, INT srcx, INT srcy, INT srcwidth, INT srcheight, GpUnit srcUnit); }
function GdipDrawImagePointRectI(Graphics: GpGraphics; Image: GpImage;
  X: Integer; Y: Integer; Srcx: Integer; Srcy: Integer; Srcwidth: Integer;
  Srcheight: Integer; SrcUnit: TGPUnit): TGPStatus; stdcall; external GdiPlusDll;

{ GdipDrawImageRectRect(GpGraphics *graphics, GpImage *image, REAL dstx, REAL dsty, REAL dstwidth, REAL dstheight, REAL srcx, REAL srcy, REAL srcwidth, REAL srcheight, GpUnit srcUnit, GDIPCONST GpImageAttributes* imageAttributes, DrawImageAbort callback, VOID * callbackData); }
function GdipDrawImageRectRect(Graphics: GpGraphics; Image: GpImage;
  Dstx: Single; Dsty: Single; Dstwidth: Single; Dstheight: Single; Srcx: Single;
  Srcy: Single; Srcwidth: Single; Srcheight: Single; SrcUnit: TGPUnit;
  const ImageAttributes: GpImageAttributes; Callback: TGPDrawImageAbort;
  CallbackData: Pointer): TGPStatus; stdcall; external GdiPlusDll;

{ GdipDrawImageRectRectI(GpGraphics *graphics, GpImage *image, INT dstx, INT dsty, INT dstwidth, INT dstheight, INT srcx, INT srcy, INT srcwidth, INT srcheight, GpUnit srcUnit, GDIPCONST GpImageAttributes* imageAttributes, DrawImageAbort callback, VOID * callbackData); }
function GdipDrawImageRectRectI(Graphics: GpGraphics; Image: GpImage;
  Dstx: Integer; Dsty: Integer; Dstwidth: Integer; Dstheight: Integer;
  Srcx: Integer; Srcy: Integer; Srcwidth: Integer; Srcheight: Integer;
  SrcUnit: TGPUnit; const ImageAttributes: GpImageAttributes;
  Callback: TGPDrawImageAbort; CallbackData: Pointer): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipDrawImagePointsRect(GpGraphics *graphics, GpImage *image, GDIPCONST GpPointF *points, INT count, REAL srcx, REAL srcy, REAL srcwidth, REAL srcheight, GpUnit srcUnit, GDIPCONST GpImageAttributes* imageAttributes, DrawImageAbort callback, VOID * callbackData); }
function GdipDrawImagePointsRect(Graphics: GpGraphics; Image: GpImage;
  const Points: PGPPointF; Count: Integer; Srcx: Single; Srcy: Single;
  Srcwidth: Single; Srcheight: Single; SrcUnit: TGPUnit;
  const ImageAttributes: GpImageAttributes; Callback: TGPDrawImageAbort;
  CallbackData: Pointer): TGPStatus; stdcall; external GdiPlusDll;

{ GdipDrawImagePointsRectI(GpGraphics *graphics, GpImage *image, GDIPCONST GpPoint *points, INT count, INT srcx, INT srcy, INT srcwidth, INT srcheight, GpUnit srcUnit, GDIPCONST GpImageAttributes* imageAttributes, DrawImageAbort callback, VOID * callbackData); }
function GdipDrawImagePointsRectI(Graphics: GpGraphics; Image: GpImage;
  const Points: PGPPoint; Count: Integer; Srcx: Integer; Srcy: Integer;
  Srcwidth: Integer; Srcheight: Integer; SrcUnit: TGPUnit;
  const ImageAttributes: GpImageAttributes; Callback: TGPDrawImageAbort;
  CallbackData: Pointer): TGPStatus; stdcall; external GdiPlusDll;

{ GdipEnumerateMetafileDestPoint( GpGraphics * graphics, GDIPCONST GpMetafile * metafile, GDIPCONST PointF & destPoint, EnumerateMetafileProc callback, VOID * callbackData, GDIPCONST GpImageAttributes * imageAttributes ); }
function GdipEnumerateMetafileDestPoint(Graphics: GpGraphics;
  const Metafile: GpMetafile; const DestPoint: PGPPointF;
  Callback: TGPEnumerateMetafileProc; CallbackData: Pointer;
  const ImageAttributes: GpImageAttributes): TGPStatus; stdcall; external GdiPlusDll;

{ GdipEnumerateMetafileDestPointI( GpGraphics * graphics, GDIPCONST GpMetafile * metafile, GDIPCONST Point & destPoint, EnumerateMetafileProc callback, VOID * callbackData, GDIPCONST GpImageAttributes * imageAttributes ); }
function GdipEnumerateMetafileDestPointI(Graphics: GpGraphics;
  const Metafile: GpMetafile; const DestPoint: PGPPoint;
  Callback: TGPEnumerateMetafileProc; CallbackData: Pointer;
  const ImageAttributes: GpImageAttributes): TGPStatus; stdcall; external GdiPlusDll;

{ GdipEnumerateMetafileDestRect( GpGraphics * graphics, GDIPCONST GpMetafile * metafile, GDIPCONST RectF & destRect, EnumerateMetafileProc callback, VOID * callbackData, GDIPCONST GpImageAttributes * imageAttributes ); }
function GdipEnumerateMetafileDestRect(Graphics: GpGraphics;
  const Metafile: GpMetafile; const DestRect: PGPRectF;
  Callback: TGPEnumerateMetafileProc; CallbackData: Pointer;
  const ImageAttributes: GpImageAttributes): TGPStatus; stdcall; external GdiPlusDll;

{ GdipEnumerateMetafileDestRectI( GpGraphics * graphics, GDIPCONST GpMetafile * metafile, GDIPCONST Rect & destRect, EnumerateMetafileProc callback, VOID * callbackData, GDIPCONST GpImageAttributes * imageAttributes ); }
function GdipEnumerateMetafileDestRectI(Graphics: GpGraphics;
  const Metafile: GpMetafile; const DestRect: PGPRect;
  Callback: TGPEnumerateMetafileProc; CallbackData: Pointer;
  const ImageAttributes: GpImageAttributes): TGPStatus; stdcall; external GdiPlusDll;

{ GdipEnumerateMetafileDestPoints( GpGraphics * graphics, GDIPCONST GpMetafile * metafile, GDIPCONST PointF * destPoints, INT count, EnumerateMetafileProc callback, VOID * callbackData, GDIPCONST GpImageAttributes * imageAttributes ); }
function GdipEnumerateMetafileDestPoints(Graphics: GpGraphics;
  const Metafile: GpMetafile; const DestPoints: PGPPointF; Count: Integer;
  Callback: TGPEnumerateMetafileProc; CallbackData: Pointer;
  const ImageAttributes: GpImageAttributes): TGPStatus; stdcall; external GdiPlusDll;

{ GdipEnumerateMetafileDestPointsI( GpGraphics * graphics, GDIPCONST GpMetafile * metafile, GDIPCONST Point * destPoints, INT count, EnumerateMetafileProc callback, VOID * callbackData, GDIPCONST GpImageAttributes * imageAttributes ); }
function GdipEnumerateMetafileDestPointsI(Graphics: GpGraphics;
  const Metafile: GpMetafile; const DestPoints: PGPPoint; Count: Integer;
  Callback: TGPEnumerateMetafileProc; CallbackData: Pointer;
  const ImageAttributes: GpImageAttributes): TGPStatus; stdcall; external GdiPlusDll;

{ GdipEnumerateMetafileSrcRectDestPoint( GpGraphics * graphics, GDIPCONST GpMetafile * metafile, GDIPCONST PointF & destPoint, GDIPCONST RectF & srcRect, Unit srcUnit, EnumerateMetafileProc callback, VOID * callbackData, GDIPCONST GpImageAttributes * imageAttributes ); }
function GdipEnumerateMetafileSrcRectDestPoint(Graphics: GpGraphics;
  const Metafile: GpMetafile; const DestPoint: PGPPointF; const SrcRect: PGPRectF;
  SrcUnit: TGPUnit; Callback: TGPEnumerateMetafileProc; CallbackData: Pointer;
  const ImageAttributes: GpImageAttributes): TGPStatus; stdcall; external GdiPlusDll;

{ GdipEnumerateMetafileSrcRectDestPointI( GpGraphics * graphics, GDIPCONST GpMetafile * metafile, GDIPCONST Point & destPoint, GDIPCONST Rect & srcRect, Unit srcUnit, EnumerateMetafileProc callback, VOID * callbackData, GDIPCONST GpImageAttributes * imageAttributes ); }
function GdipEnumerateMetafileSrcRectDestPointI(Graphics: GpGraphics;
  const Metafile: GpMetafile; const DestPoint: PGPPoint; const SrcRect: PGPRect;
  SrcUnit: TGPUnit; Callback: TGPEnumerateMetafileProc; CallbackData: Pointer;
  const ImageAttributes: GpImageAttributes): TGPStatus; stdcall; external GdiPlusDll;

{ GdipEnumerateMetafileSrcRectDestRect( GpGraphics * graphics, GDIPCONST GpMetafile * metafile, GDIPCONST RectF & destRect, GDIPCONST RectF & srcRect, Unit srcUnit, EnumerateMetafileProc callback, VOID * callbackData, GDIPCONST GpImageAttributes * imageAttributes ); }
function GdipEnumerateMetafileSrcRectDestRect(Graphics: GpGraphics;
  const Metafile: GpMetafile; const DestRect: PGPRectF; const SrcRect: PGPRectF;
  SrcUnit: TGPUnit; Callback: TGPEnumerateMetafileProc; CallbackData: Pointer;
  const ImageAttributes: GpImageAttributes): TGPStatus; stdcall; external GdiPlusDll;

{ GdipEnumerateMetafileSrcRectDestRectI( GpGraphics * graphics, GDIPCONST GpMetafile * metafile, GDIPCONST Rect & destRect, GDIPCONST Rect & srcRect, Unit srcUnit, EnumerateMetafileProc callback, VOID * callbackData, GDIPCONST GpImageAttributes * imageAttributes ); }
function GdipEnumerateMetafileSrcRectDestRectI(Graphics: GpGraphics;
  const Metafile: GpMetafile; const DestRect: PGPRect; const SrcRect: PGPRect;
  SrcUnit: TGPUnit; Callback: TGPEnumerateMetafileProc; CallbackData: Pointer;
  const ImageAttributes: GpImageAttributes): TGPStatus; stdcall; external GdiPlusDll;

{ GdipEnumerateMetafileSrcRectDestPoints( GpGraphics * graphics, GDIPCONST GpMetafile * metafile, GDIPCONST PointF * destPoints, INT count, GDIPCONST RectF & srcRect, Unit srcUnit, EnumerateMetafileProc callback, VOID * callbackData, GDIPCONST GpImageAttributes * imageAttributes ); }
function GdipEnumerateMetafileSrcRectDestPoints(Graphics: GpGraphics;
  const Metafile: GpMetafile; const DestPoints: PGPPointF; Count: Integer;
  const SrcRect: PGPRectF; SrcUnit: TGPUnit; Callback: TGPEnumerateMetafileProc;
  CallbackData: Pointer; const ImageAttributes: GpImageAttributes): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipEnumerateMetafileSrcRectDestPointsI( GpGraphics * graphics, GDIPCONST GpMetafile * metafile, GDIPCONST Point * destPoints, INT count, GDIPCONST Rect & srcRect, Unit srcUnit, EnumerateMetafileProc callback, VOID * callbackData, GDIPCONST GpImageAttributes * imageAttributes ); }
function GdipEnumerateMetafileSrcRectDestPointsI(Graphics: GpGraphics;
  const Metafile: GpMetafile; const DestPoints: PGPPoint; Count: Integer;
  const SrcRect: PGPRect; SrcUnit: TGPUnit; Callback: TGPEnumerateMetafileProc;
  CallbackData: Pointer; const ImageAttributes: GpImageAttributes): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipPlayMetafileRecord( GDIPCONST GpMetafile * metafile, EmfPlusRecordType recordType, UINT flags, UINT dataSize, GDIPCONST BYTE * data ); }
function GdipPlayMetafileRecord(const Metafile: GpMetafile;
  RecordType: TEmfPlusRecordType; Flags: Cardinal; DataSize: Cardinal;
  const Data: PByte): TGPStatus; stdcall; external GdiPlusDll;

{ GdipSetClipGraphics(GpGraphics *graphics, GpGraphics *srcgraphics, CombineMode combineMode); }
function GdipSetClipGraphics(Graphics: GpGraphics; Srcgraphics: GpGraphics;
  CombineMode: TGPCombineMode): TGPStatus; stdcall; external GdiPlusDll;

{ GdipSetClipRect(GpGraphics *graphics, REAL x, REAL y, REAL width, REAL height, CombineMode combineMode); }
function GdipSetClipRect(Graphics: GpGraphics; X: Single; Y: Single;
  Width: Single; Height: Single; CombineMode: TGPCombineMode): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipSetClipRectI(GpGraphics *graphics, INT x, INT y, INT width, INT height, CombineMode combineMode); }
function GdipSetClipRectI(Graphics: GpGraphics; X: Integer; Y: Integer;
  Width: Integer; Height: Integer; CombineMode: TGPCombineMode): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipSetClipPath(GpGraphics *graphics, GpPath *path, CombineMode combineMode); }
function GdipSetClipPath(Graphics: GpGraphics; Path: GpPath;
  CombineMode: TGPCombineMode): TGPStatus; stdcall; external GdiPlusDll;

{ GdipSetClipRegion(GpGraphics *graphics, GpRegion *region, CombineMode combineMode); }
function GdipSetClipRegion(Graphics: GpGraphics; Region: GpRegion;
  CombineMode: TGPCombineMode): TGPStatus; stdcall; external GdiPlusDll;

{ GdipSetClipHrgn(GpGraphics *graphics, HRGN hRgn, CombineMode combineMode); }
function GdipSetClipHrgn(Graphics: GpGraphics; HRgn: HRGN;
  CombineMode: TGPCombineMode): TGPStatus; stdcall; external GdiPlusDll;

{ GdipResetClip(GpGraphics *graphics); }
function GdipResetClip(Graphics: GpGraphics): TGPStatus; stdcall; external GdiPlusDll;

{ GdipTranslateClip(GpGraphics *graphics, REAL dx, REAL dy); }
function GdipTranslateClip(Graphics: GpGraphics; Dx: Single; Dy: Single): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipTranslateClipI(GpGraphics *graphics, INT dx, INT dy); }
function GdipTranslateClipI(Graphics: GpGraphics; Dx: Integer; Dy: Integer): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetClip(GpGraphics *graphics, GpRegion *region); }
function GdipGetClip(Graphics: GpGraphics; Region: GpRegion): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetClipBounds(GpGraphics *graphics, GpRectF *rect); }
function GdipGetClipBounds(Graphics: GpGraphics; out Rect: TGPRectF): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetClipBoundsI(GpGraphics *graphics, GpRect *rect); }
function GdipGetClipBoundsI(Graphics: GpGraphics; out Rect: TGPRect): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipIsClipEmpty(GpGraphics *graphics, BOOL *result); }
function GdipIsClipEmpty(Graphics: GpGraphics; out Result: Bool): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetVisibleClipBounds(GpGraphics *graphics, GpRectF *rect); }
function GdipGetVisibleClipBounds(Graphics: GpGraphics; out Rect: TGPRectF): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetVisibleClipBoundsI(GpGraphics *graphics, GpRect *rect); }
function GdipGetVisibleClipBoundsI(Graphics: GpGraphics; out Rect: TGPRect): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipIsVisibleClipEmpty(GpGraphics *graphics, BOOL *result); }
function GdipIsVisibleClipEmpty(Graphics: GpGraphics; out Result: Bool): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipIsVisiblePoint(GpGraphics *graphics, REAL x, REAL y, BOOL *result); }
function GdipIsVisiblePoint(Graphics: GpGraphics; X: Single; Y: Single;
  out Result: Bool): TGPStatus; stdcall; external GdiPlusDll;

{ GdipIsVisiblePointI(GpGraphics *graphics, INT x, INT y, BOOL *result); }
function GdipIsVisiblePointI(Graphics: GpGraphics; X: Integer; Y: Integer;
  out Result: Bool): TGPStatus; stdcall; external GdiPlusDll;

{ GdipIsVisibleRect(GpGraphics *graphics, REAL x, REAL y, REAL width, REAL height, BOOL *result); }
function GdipIsVisibleRect(Graphics: GpGraphics; X: Single; Y: Single;
  Width: Single; Height: Single; out Result: Bool): TGPStatus; stdcall; external GdiPlusDll;

{ GdipIsVisibleRectI(GpGraphics *graphics, INT x, INT y, INT width, INT height, BOOL *result); }
function GdipIsVisibleRectI(Graphics: GpGraphics; X: Integer; Y: Integer;
  Width: Integer; Height: Integer; out Result: Bool): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipSaveGraphics(GpGraphics *graphics, GraphicsState *state); }
function GdipSaveGraphics(Graphics: GpGraphics; out State: TGPGraphicsState): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipRestoreGraphics(GpGraphics *graphics, GraphicsState state); }
function GdipRestoreGraphics(Graphics: GpGraphics; State: TGPGraphicsState): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipBeginContainer(GpGraphics *graphics, GDIPCONST GpRectF* dstrect, GDIPCONST GpRectF *srcrect, GpUnit unit, GraphicsContainer *state); }
function GdipBeginContainer(Graphics: GpGraphics; const Dstrect: PGPRectF;
  const Srcrect: PGPRectF; AUnit: TGPUnit; out State: TGPGraphicsContainer): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipBeginContainerI(GpGraphics *graphics, GDIPCONST GpRect* dstrect, GDIPCONST GpRect *srcrect, GpUnit unit, GraphicsContainer *state); }
function GdipBeginContainerI(Graphics: GpGraphics; const Dstrect: PGPRect;
  const Srcrect: PGPRect; AUnit: TGPUnit; out State: TGPGraphicsContainer): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipBeginContainer2(GpGraphics *graphics, GraphicsContainer* state); }
function GdipBeginContainer2(Graphics: GpGraphics; out State: TGPGraphicsContainer): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipEndContainer(GpGraphics *graphics, GraphicsContainer state); }
function GdipEndContainer(Graphics: GpGraphics; State: TGPGraphicsContainer): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetMetafileHeaderFromWmf( HMETAFILE hWmf, GDIPCONST WmfPlaceableFileHeader * wmfPlaceableFileHeader, MetafileHeader * header ); }
function GdipGetMetafileHeaderFromWmf(HWmf: HMetaFile;
  const WmfPlaceableFileHeader: TWmfPlaceableFileHeader;
  out Header: TGPMetafileHeader): TGPStatus; stdcall; external GdiPlusDll;

{ GdipGetMetafileHeaderFromEmf( HENHMETAFILE hEmf, MetafileHeader * header ); }
function GdipGetMetafileHeaderFromEmf(HEmf: HEnhMetaFile;
  out Header: TGPMetafileHeader): TGPStatus; stdcall; external GdiPlusDll;

{ GdipGetMetafileHeaderFromFile( GDIPCONST WCHAR* filename, MetafileHeader * header ); }
function GdipGetMetafileHeaderFromFile(const Filename: PWideChar;
  out Header: TGPMetafileHeader): TGPStatus; stdcall; external GdiPlusDll;

{ GdipGetMetafileHeaderFromStream( IStream * stream, MetafileHeader * header ); }
function GdipGetMetafileHeaderFromStream(const Stream: IStream;
  out Header: TGPMetafileHeader): TGPStatus; stdcall; external GdiPlusDll;

{ GdipGetMetafileHeaderFromMetafile( GpMetafile * metafile, MetafileHeader * header ); }
function GdipGetMetafileHeaderFromMetafile(Metafile: GpMetafile;
  out Header: TGPMetafileHeader): TGPStatus; stdcall; external GdiPlusDll;

{ GdipGetHemfFromMetafile( GpMetafile * metafile, HENHMETAFILE * hEmf ); }
function GdipGetHemfFromMetafile(Metafile: GpMetafile;
  out HEmf: HEnhMetaFile): TGPStatus; stdcall; external GdiPlusDll;

{ GdipCreateStreamOnFile(GDIPCONST WCHAR * filename, UINT access, IStream **stream); }
function GdipCreateStreamOnFile(const Filename: PWideChar; Access: Cardinal;
  const Stream: IStream): TGPStatus; stdcall; external GdiPlusDll;

{ GdipCreateMetafileFromWmf(HMETAFILE hWmf, BOOL deleteWmf, GDIPCONST WmfPlaceableFileHeader * wmfPlaceableFileHeader, GpMetafile **metafile); }
function GdipCreateMetafileFromWmf(HWmf: HMetaFile; DeleteWmf: Bool;
  const WmfPlaceableFileHeader: TWmfPlaceableFileHeader;
  out Metafile: GpMetafile): TGPStatus; stdcall; external GdiPlusDll;

{ GdipCreateMetafileFromEmf(HENHMETAFILE hEmf, BOOL deleteEmf, GpMetafile **metafile); }
function GdipCreateMetafileFromEmf(HEmf: HEnhMetaFile; DeleteEmf: Bool;
  out Metafile: GpMetafile): TGPStatus; stdcall; external GdiPlusDll;

{ GdipCreateMetafileFromFile(GDIPCONST WCHAR* file, GpMetafile **metafile); }
function GdipCreateMetafileFromFile(const Filename: PWideChar;
  out Metafile: GpMetafile): TGPStatus; stdcall; external GdiPlusDll;

{ GdipCreateMetafileFromWmfFile(GDIPCONST WCHAR* file, GDIPCONST WmfPlaceableFileHeader * wmfPlaceableFileHeader, GpMetafile **metafile); }
function GdipCreateMetafileFromWmfFile(const Filename: PWideChar;
  const WmfPlaceableFileHeader: TWmfPlaceableFileHeader;
  out Metafile: GpMetafile): TGPStatus; stdcall; external GdiPlusDll;

{ GdipCreateMetafileFromStream(IStream * stream, GpMetafile **metafile); }
function GdipCreateMetafileFromStream(const Stream: IStream;
  out Metafile: GpMetafile): TGPStatus; stdcall; external GdiPlusDll;


{ GdipRecordMetafile( HDC referenceHdc, EmfType type, GDIPCONST GpRectF * frameRect, MetafileFrameUnit frameUnit, GDIPCONST WCHAR * description, GpMetafile ** metafile ); }
function GdipRecordMetafile(ReferenceHdc: HDC; AType: TGPEmfType;
  const FrameRect: PGPRectF; FrameUnit: TGPMetafileFrameUnit;
  const Description: PWideChar; out Metafile: GpMetafile): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipRecordMetafileI( HDC referenceHdc, EmfType type, GDIPCONST GpRect * frameRect, MetafileFrameUnit frameUnit, GDIPCONST WCHAR * description, GpMetafile ** metafile ); }
function GdipRecordMetafileI(ReferenceHdc: HDC; AType: TGPEmfType;
  const FrameRect: PGPRect; FrameUnit: TGPMetafileFrameUnit;
  const Description: PWideChar; out Metafile: GpMetafile): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipRecordMetafileFileName( GDIPCONST WCHAR* fileName, HDC referenceHdc, EmfType type, GDIPCONST GpRectF * frameRect, MetafileFrameUnit frameUnit, GDIPCONST WCHAR * description, GpMetafile ** metafile ); }
function GdipRecordMetafileFileName(const FileName: PWideChar;
  ReferenceHdc: HDC; AType: TGPEmfType; const FrameRect: PGPRectF;
  FrameUnit: TGPMetafileFrameUnit; const Description: PWideChar;
  out Metafile: GpMetafile): TGPStatus; stdcall; external GdiPlusDll;

{ GdipRecordMetafileFileNameI( GDIPCONST WCHAR* fileName, HDC referenceHdc, EmfType type, GDIPCONST GpRect * frameRect, MetafileFrameUnit frameUnit, GDIPCONST WCHAR * description, GpMetafile ** metafile ); }
function GdipRecordMetafileFileNameI(const FileName: PWideChar;
  ReferenceHdc: HDC; AType: TGPEmfType; const FrameRect: PGPRect;
  FrameUnit: TGPMetafileFrameUnit; const Description: PWideChar;
  out Metafile: GpMetafile): TGPStatus; stdcall; external GdiPlusDll;

{ GdipRecordMetafileStream( IStream * stream, HDC referenceHdc, EmfType type, GDIPCONST GpRectF * frameRect, MetafileFrameUnit frameUnit, GDIPCONST WCHAR * description, GpMetafile ** metafile ); }
function GdipRecordMetafileStream(const Stream: IStream; ReferenceHdc: HDC;
  AType: TGPEmfType; const FrameRect: PGPRectF; FrameUnit: TGPMetafileFrameUnit;
  const Description: PWideChar; out Metafile: GpMetafile): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipRecordMetafileStreamI( IStream * stream, HDC referenceHdc, EmfType type, GDIPCONST GpRect * frameRect, MetafileFrameUnit frameUnit, GDIPCONST WCHAR * description, GpMetafile ** metafile ); }
function GdipRecordMetafileStreamI(const Stream: IStream; ReferenceHdc: HDC;
  AType: TGPEmfType; const FrameRect: PGPRect; FrameUnit: TGPMetafileFrameUnit;
  const Description: PWideChar; out Metafile: GpMetafile): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipSetMetafileDownLevelRasterizationLimit( GpMetafile * metafile, UINT metafileRasterizationLimitDpi ); }
function GdipSetMetafileDownLevelRasterizationLimit(Metafile: GpMetafile;
  MetafileRasterizationLimitDpi: Cardinal): TGPStatus; stdcall; external GdiPlusDll;

{ GdipGetMetafileDownLevelRasterizationLimit( GDIPCONST GpMetafile * metafile, UINT * metafileRasterizationLimitDpi ); }
function GdipGetMetafileDownLevelRasterizationLimit(const Metafile: GpMetafile;
  out MetafileRasterizationLimitDpi: Cardinal): TGPStatus; stdcall; external GdiPlusDll;

{ GdipGetImageDecodersSize(UINT *numDecoders, UINT *size); }
function GdipGetImageDecodersSize(out NumDecoders: Cardinal; out Size: Cardinal): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetImageDecoders(UINT numDecoders, UINT size, __out_bcount(size) ImageCodecInfo *decoders); }
function GdipGetImageDecoders(NumDecoders: Cardinal; Size: Cardinal;
  Decoders: PGPNativeImageCodecInfo): TGPStatus; stdcall; external GdiPlusDll;

{ GdipGetImageEncodersSize(UINT *numEncoders, UINT *size); }
function GdipGetImageEncodersSize(out NumEncoders: Cardinal; out Size: Cardinal): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetImageEncoders(UINT numEncoders, UINT size, __out_bcount(size) ImageCodecInfo *encoders); }
function GdipGetImageEncoders(NumEncoders: Cardinal; Size: Cardinal;
  Encoders: PGPNativeImageCodecInfo): TGPStatus; stdcall; external GdiPlusDll;

{ GdipComment(GpGraphics* graphics, UINT sizeData, GDIPCONST BYTE * data); }
function GdipComment(Graphics: GpGraphics; SizeData: Cardinal;
  const Data: PByte): TGPStatus; stdcall; external GdiPlusDll;

//----------------------------------------------------------------------------
// FontFamily APIs
//----------------------------------------------------------------------------

{ GdipCreateFontFamilyFromName(GDIPCONST WCHAR *name, GpFontCollection *fontCollection, GpFontFamily **fontFamily); }
function GdipCreateFontFamilyFromName(const Name: PWideChar;
  FontCollection: GpFontCollection; out FontFamily: GpFontFamily): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipDeleteFontFamily(GpFontFamily *fontFamily); }
function GdipDeleteFontFamily(FontFamily: GpFontFamily): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipCloneFontFamily(GpFontFamily *fontFamily, GpFontFamily **clonedFontFamily); }
function GdipCloneFontFamily(FontFamily: GpFontFamily;
  out ClonedFontFamily: GpFontFamily): TGPStatus; stdcall; external GdiPlusDll;

{ GdipGetGenericFontFamilySansSerif(GpFontFamily **nativeFamily); }
function GdipGetGenericFontFamilySansSerif(out NativeFamily: GpFontFamily): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetGenericFontFamilySerif(GpFontFamily **nativeFamily); }
function GdipGetGenericFontFamilySerif(out NativeFamily: GpFontFamily): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetGenericFontFamilyMonospace(GpFontFamily **nativeFamily); }
function GdipGetGenericFontFamilyMonospace(out NativeFamily: GpFontFamily): TGPStatus; stdcall;
  external GdiPlusDll;


{ GdipGetFamilyName( GDIPCONST GpFontFamily *family, __out_ecount(LF_FACESIZE) LPWSTR name, LANGID language ); }
function GdipGetFamilyName(const Family: GpFontFamily; Name: PWideChar;
  Language: LangID): TGPStatus; stdcall; external GdiPlusDll;

{ GdipIsStyleAvailable(GDIPCONST GpFontFamily *family, INT style, BOOL * IsStyleAvailable); }
function GdipIsStyleAvailable(const Family: GpFontFamily; Style: TGPFontStyle;
  out IsStyleAvailable: Bool): TGPStatus; stdcall; external GdiPlusDll;

{ GdipFontCollectionEnumerable( GpFontCollection* fontCollection, GpGraphics* graphics, INT * numFound ); }
function GdipFontCollectionEnumerable(FontCollection: GpFontCollection;
  Graphics: GpGraphics; NumFound: PInteger): TGPStatus; stdcall; external GdiPlusDll;

{ GdipFontCollectionEnumerate( GpFontCollection* fontCollection, INT numSought, GpFontFamily* gpfamilies[], INT* numFound, GpGraphics* graphics ); }
function GdipFontCollectionEnumerate(FontCollection: GpFontCollection;
  NumSought: Integer; Gpfamilies: PGpFontFamily; NumFound: PInteger;
  Graphics: GpGraphics): TGPStatus; stdcall; external GdiPlusDll;

{ GdipGetEmHeight(GDIPCONST GpFontFamily *family, INT style, UINT16 * EmHeight); }
function GdipGetEmHeight(const Family: GpFontFamily; Style: TGPFontStyle;
  out EmHeight: UInt16): TGPStatus; stdcall; external GdiPlusDll;

{ GdipGetCellAscent(GDIPCONST GpFontFamily *family, INT style, UINT16 * CellAscent); }
function GdipGetCellAscent(const Family: GpFontFamily; Style: TGPFontStyle;
  out CellAscent: UInt16): TGPStatus; stdcall; external GdiPlusDll;

{ GdipGetCellDescent(GDIPCONST GpFontFamily *family, INT style, UINT16 * CellDescent); }
function GdipGetCellDescent(const Family: GpFontFamily; Style: TGPFontStyle;
  out CellDescent: UInt16): TGPStatus; stdcall; external GdiPlusDll;

{ GdipGetLineSpacing(GDIPCONST GpFontFamily *family, INT style, UINT16 * LineSpacing); }
function GdipGetLineSpacing(const Family: GpFontFamily; Style: TGPFontStyle;
  out LineSpacing: UInt16): TGPStatus; stdcall; external GdiPlusDll;

//----------------------------------------------------------------------------
// Font APIs
//----------------------------------------------------------------------------

{ GdipCreateFontFromDC( HDC hdc, GpFont **font ); }
function GdipCreateFontFromDC(Hdc: HDC; out Font: GpFont): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipCreateFontFromLogfontA( HDC hdc, GDIPCONST LOGFONTA *logfont, GpFont **font ); }
function GdipCreateFontFromLogfontA(Hdc: HDC; const Logfont: PLogFontA;
  out Font: GpFont): TGPStatus; stdcall; external GdiPlusDll;

{ GdipCreateFontFromLogfontW( HDC hdc, GDIPCONST LOGFONTW *logfont, GpFont **font ); }
function GdipCreateFontFromLogfontW(Hdc: HDC; const Logfont: PLogFontW;
  out Font: GpFont): TGPStatus; stdcall; external GdiPlusDll;

{ GdipCreateFont( GDIPCONST GpFontFamily *fontFamily, REAL emSize, INT style, Unit unit, GpFont **font ); }
function GdipCreateFont(const FontFamily: GpFontFamily; EmSize: Single;
  Style: TGPFontStyle; MeasureUnit: TGPUnit; out Font: GpFont): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipCloneFont(GpFont* font, GpFont** cloneFont); }
function GdipCloneFont(Font: GpFont; out CloneFont: GpFont): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipDeleteFont(GpFont* font); }
function GdipDeleteFont(Font: GpFont): TGPStatus; stdcall; external GdiPlusDll;

{ GdipGetFamily(GpFont *font, GpFontFamily **family); }
function GdipGetFamily(Font: GpFont; out Family: GpFontFamily): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetFontStyle(GpFont *font, INT *style); }
function GdipGetFontStyle(Font: GpFont; out Style: TGPFontStyle): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetFontSize(GpFont *font, REAL *size); }
function GdipGetFontSize(Font: GpFont; out Size: Single): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetFontUnit(GpFont *font, Unit *unit); }
function GdipGetFontUnit(Font: GpFont; out MeasureUnit: TGPUnit): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetFontHeight(GDIPCONST GpFont *font, GDIPCONST GpGraphics *graphics, REAL *height); }
function GdipGetFontHeight(const Font: GpFont; const Graphics: GpGraphics;
  out Height: Single): TGPStatus; stdcall; external GdiPlusDll;

{ GdipGetFontHeightGivenDPI(GDIPCONST GpFont *font, REAL dpi, REAL *height); }
function GdipGetFontHeightGivenDPI(const Font: GpFont; Dpi: Single;
  out Height: Single): TGPStatus; stdcall; external GdiPlusDll;

{ GdipGetLogFontA(GpFont * font, GpGraphics *graphics, LOGFONTA * logfontA); }
function GdipGetLogFontA(Font: GpFont; Graphics: GpGraphics;
  out LogfontA: TLogFontA): TGPStatus; stdcall; external GdiPlusDll;

{ GdipGetLogFontW(GpFont * font, GpGraphics *graphics, LOGFONTW * logfontW); }
function GdipGetLogFontW(Font: GpFont; Graphics: GpGraphics;
  out LogfontW: TLogFontW): TGPStatus; stdcall; external GdiPlusDll;

{ GdipNewInstalledFontCollection(GpFontCollection** fontCollection); }
function GdipNewInstalledFontCollection(out FontCollection: GpFontCollection): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipNewPrivateFontCollection(GpFontCollection** fontCollection); }
function GdipNewPrivateFontCollection(out FontCollection: GpFontCollection): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipDeletePrivateFontCollection(GpFontCollection** fontCollection); }
function GdipDeletePrivateFontCollection(out FontCollection: GpFontCollection): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetFontCollectionFamilyCount( GpFontCollection* fontCollection, INT * numFound ); }
function GdipGetFontCollectionFamilyCount(FontCollection: GpFontCollection;
  out NumFound: Integer): TGPStatus; stdcall; external GdiPlusDll;

{ GdipGetFontCollectionFamilyList( GpFontCollection* fontCollection, INT numSought, GpFontFamily* gpfamilies[], INT* numFound ); }
function GdipGetFontCollectionFamilyList(FontCollection: GpFontCollection;
  NumSought: Integer; Gpfamilies: PGpFontFamily; out NumFound: Integer): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipPrivateAddFontFile( GpFontCollection* fontCollection, GDIPCONST WCHAR* filename ); }
function GdipPrivateAddFontFile(FontCollection: GpFontCollection;
  const Filename: PWideChar): TGPStatus; stdcall; external GdiPlusDll;

{ GdipPrivateAddMemoryFont( GpFontCollection* fontCollection, GDIPCONST void* memory, INT length ); }
function GdipPrivateAddMemoryFont(FontCollection: GpFontCollection;
  const Memory: Pointer; Length: Integer): TGPStatus; stdcall; external GdiPlusDll;

//----------------------------------------------------------------------------
// Text APIs
//----------------------------------------------------------------------------

{ GdipDrawString( GpGraphics *graphics, GDIPCONST WCHAR *string, INT length, GDIPCONST GpFont *font, GDIPCONST RectF *layoutRect, GDIPCONST GpStringFormat *stringFormat, GDIPCONST GpBrush *brush ); }
function GdipDrawString(Graphics: GpGraphics; const Str: PWideChar;
  Length: Integer; const Font: GpFont; const LayoutRect: PGPRectF;
  const StringFormat: GpStringFormat; const Brush: GpBrush): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipMeasureString( GpGraphics *graphics, GDIPCONST WCHAR *string, INT length, GDIPCONST GpFont *font, GDIPCONST RectF *layoutRect, GDIPCONST GpStringFormat *stringFormat, RectF *boundingBox, INT *codepointsFitted, INT *linesFilled ); }
function GdipMeasureString(Graphics: GpGraphics; const Str: PWideChar;
  Length: Integer; const Font: GpFont; const LayoutRect: PGPRectF;
  const StringFormat: GpStringFormat; out BoundingBox: TGPRectF;
  CodepointsFitted: PInteger; LinesFilled: PInteger): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipMeasureCharacterRanges( GpGraphics *graphics, GDIPCONST WCHAR *string, INT length, GDIPCONST GpFont *font, GDIPCONST RectF &layoutRect, GDIPCONST GpStringFormat *stringFormat, INT regionCount, GpRegion **regions ); }
function GdipMeasureCharacterRanges(Graphics: GpGraphics; const Str: PWideChar;
  Length: Integer; const Font: GpFont; const LayoutRect: PGPRectF;
  const StringFormat: GpStringFormat; RegionCount: Integer;
  Regions: PGpRegion): TGPStatus; stdcall; external GdiPlusDll;

{ GdipDrawDriverString( GpGraphics *graphics, GDIPCONST UINT16 *text, INT length, GDIPCONST GpFont *font, GDIPCONST GpBrush *brush, GDIPCONST PointF *positions, INT flags, GDIPCONST GpMatrix *matrix ); }
function GdipDrawDriverString(Graphics: GpGraphics; const Text: PUInt16;
  Length: Integer; const Font: GpFont; const Brush: GpBrush;
  const Positions: PGPPointF; Flags: TGPDriverStringOptions; const Matrix: GpMatrix): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipMeasureDriverString( GpGraphics *graphics, GDIPCONST UINT16 *text, INT length, GDIPCONST GpFont *font, GDIPCONST PointF *positions, INT flags, GDIPCONST GpMatrix *matrix, RectF *boundingBox ); }
function GdipMeasureDriverString(Graphics: GpGraphics; const Text: PUInt16;
  Length: Integer; const Font: GpFont; const Positions: PGPPointF; Flags: TGPDriverStringOptions;
  const Matrix: GpMatrix; out BoundingBox: TGPRectF): TGPStatus; stdcall; external GdiPlusDll;

//----------------------------------------------------------------------------
// String format APIs
//----------------------------------------------------------------------------

{ GdipCreateStringFormat( INT formatAttributes, LANGID language, GpStringFormat **format ); }
function GdipCreateStringFormat(FormatAttributes: TGPStringFormatFlags; Language: LANGID;
  out Format: GpStringFormat): TGPStatus; stdcall; external GdiPlusDll;

{ GdipStringFormatGetGenericDefault(GpStringFormat **format); }
function GdipStringFormatGetGenericDefault(out Format: GpStringFormat): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipStringFormatGetGenericTypographic(GpStringFormat **format); }
function GdipStringFormatGetGenericTypographic(out Format: GpStringFormat): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipDeleteStringFormat(GpStringFormat *format); }
function GdipDeleteStringFormat(Format: GpStringFormat): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipCloneStringFormat(GDIPCONST GpStringFormat *format, GpStringFormat **newFormat); }
function GdipCloneStringFormat(const Format: GpStringFormat;
  out NewFormat: GpStringFormat): TGPStatus; stdcall; external GdiPlusDll;

{ GdipSetStringFormatFlags(GpStringFormat *format, INT flags); }
function GdipSetStringFormatFlags(Format: GpStringFormat; Flags: TGPStringFormatFlags): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetStringFormatFlags(GDIPCONST GpStringFormat *format, INT *flags); }
function GdipGetStringFormatFlags(const Format: GpStringFormat;
  out Flags: TGPStringFormatFlags): TGPStatus; stdcall; external GdiPlusDll;

{ GdipSetStringFormatAlign(GpStringFormat *format, StringAlignment align); }
function GdipSetStringFormatAlign(Format: GpStringFormat;
  Align: TGPStringAlignment): TGPStatus; stdcall; external GdiPlusDll;

{ GdipGetStringFormatAlign(GDIPCONST GpStringFormat *format, StringAlignment *align); }
function GdipGetStringFormatAlign(const Format: GpStringFormat;
  out Align: TGPStringAlignment): TGPStatus; stdcall; external GdiPlusDll;

{ GdipSetStringFormatLineAlign(GpStringFormat *format, StringAlignment align); }
function GdipSetStringFormatLineAlign(Format: GpStringFormat;
  Align: TGPStringAlignment): TGPStatus; stdcall; external GdiPlusDll;

{ GdipGetStringFormatLineAlign(GDIPCONST GpStringFormat *format, StringAlignment *align); }
function GdipGetStringFormatLineAlign(const Format: GpStringFormat;
  out Align: TGPStringAlignment): TGPStatus; stdcall; external GdiPlusDll;

{ GdipSetStringFormatTrimming( GpStringFormat *format, StringTrimming trimming ); }
function GdipSetStringFormatTrimming(Format: GpStringFormat;
  Trimming: TGPStringTrimming): TGPStatus; stdcall; external GdiPlusDll;

{ GdipGetStringFormatTrimming( GDIPCONST GpStringFormat *format, StringTrimming *trimming ); }
function GdipGetStringFormatTrimming(const Format: GpStringFormat;
  out Trimming: TGPStringTrimming): TGPStatus; stdcall; external GdiPlusDll;

{ GdipSetStringFormatHotkeyPrefix(GpStringFormat *format, INT hotkeyPrefix); }
function GdipSetStringFormatHotkeyPrefix(Format: GpStringFormat;
  HotkeyPrefix: TGPHotkeyPrefix): TGPStatus; stdcall; external GdiPlusDll;

{ GdipGetStringFormatHotkeyPrefix(GDIPCONST GpStringFormat *format, INT *hotkeyPrefix); }
function GdipGetStringFormatHotkeyPrefix(const Format: GpStringFormat;
  out HotkeyPrefix: TGPHotkeyPrefix): TGPStatus; stdcall; external GdiPlusDll;

{ GdipSetStringFormatTabStops(GpStringFormat *format, REAL firstTabOffset, INT count, GDIPCONST REAL *tabStops); }
function GdipSetStringFormatTabStops(Format: GpStringFormat;
  FirstTabOffset: Single; Count: Integer; const TabStops: PSingle): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetStringFormatTabStops(GDIPCONST GpStringFormat *format, INT count, REAL *firstTabOffset, REAL *tabStops); }
function GdipGetStringFormatTabStops(const Format: GpStringFormat;
  Count: Integer; out FirstTabOffset: Single; TabStops: PSingle): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetStringFormatTabStopCount(GDIPCONST GpStringFormat *format, INT * count); }
function GdipGetStringFormatTabStopCount(const Format: GpStringFormat;
  out Count: Integer): TGPStatus; stdcall; external GdiPlusDll;

{ GdipSetStringFormatDigitSubstitution(GpStringFormat *format, LANGID language, StringDigitSubstitute substitute); }
function GdipSetStringFormatDigitSubstitution(Format: GpStringFormat;
  Language: LangID; Substitute: TGPStringDigitSubstitute): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetStringFormatDigitSubstitution(GDIPCONST GpStringFormat *format, LANGID *language, StringDigitSubstitute *substitute); }
function GdipGetStringFormatDigitSubstitution(const Format: GpStringFormat;
  Language: PLangID; Substitute: PGPStringDigitSubstitute): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipGetStringFormatMeasurableCharacterRangeCount( GDIPCONST GpStringFormat *format, INT *count ); }
function GdipGetStringFormatMeasurableCharacterRangeCount(
  const Format: GpStringFormat; out Count: Integer): TGPStatus; stdcall; external GdiPlusDll;

{ GdipSetStringFormatMeasurableCharacterRanges( GpStringFormat *format, INT rangeCount, GDIPCONST CharacterRange *ranges ); }
function GdipSetStringFormatMeasurableCharacterRanges(Format: GpStringFormat;
  RangeCount: Integer; const Ranges: PGPCharacterRange): TGPStatus; stdcall;
  external GdiPlusDll;

//----------------------------------------------------------------------------
// Cached Bitmap APIs
//----------------------------------------------------------------------------

{ GdipCreateCachedBitmap( GpBitmap *bitmap, GpGraphics *graphics, GpCachedBitmap **cachedBitmap ); }
function GdipCreateCachedBitmap(Bitmap: GpBitmap; Graphics: GpGraphics;
  out CachedBitmap: GpCachedBitmap): TGPStatus; stdcall; external GdiPlusDll;

{ GdipDeleteCachedBitmap(GpCachedBitmap *cachedBitmap); }
function GdipDeleteCachedBitmap(CachedBitmap: GpCachedBitmap): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipDrawCachedBitmap( GpGraphics *graphics, GpCachedBitmap *cachedBitmap, INT x, INT y ); }
function GdipDrawCachedBitmap(Graphics: GpGraphics;
  CachedBitmap: GpCachedBitmap; X: Integer; Y: Integer): TGPStatus; stdcall;
  external GdiPlusDll;

function GdipEmfToWmfBits(HEmf: HEnhMetaFile; cbData16: UINT; pData16: PByte;
  MapMode: Integer; Flags: TGPEmfToWmfBitsFlags): UINT; stdcall; external GdiPlusDll;

{ GdipSetImageAttributesCachedBackground( GpImageAttributes *imageattr, BOOL enableFlag ); }
function GdipSetImageAttributesCachedBackground(Imageattr: GpImageAttributes;
  EnableFlag: Bool): TGPStatus; stdcall; external GdiPlusDll;

{ GdipTestControl( GpTestControlEnum control, void * param ); }
function GdipTestControl(Control: TGPTestControlEnum; Param: Pointer): TGPStatus; stdcall;
  external GdiPlusDll;

function GdiplusNotificationHook(out Token: ULONG): TGPStatus; stdcall; external GdiPlusDll;

procedure GdiplusNotificationUnhook(Token: ULONG); stdcall; external GdiPlusDll;

{$IF (GDIPVER >= $0110)}
{ GdipConvertToEmfPlus( const GpGraphics* refGraphics, GpMetafile* metafile, INT* conversionFailureFlag, EmfType emfType, const WCHAR* description, GpMetafile** out_metafile ); }
function GdipConvertToEmfPlus(const RefGraphics: GpGraphics;
  Metafile: GpMetafile; ConversionFailureFlag: PInteger; EmfType: TGPEmfType;
  const Description: PWideChar; out Out_metafile: GpMetafile): TGPStatus; stdcall;
  external GdiPlusDll;

{ GdipConvertToEmfPlusToFile( const GpGraphics* refGraphics, GpMetafile* metafile, INT* conversionFailureFlag, const WCHAR* filename, EmfType emfType, const WCHAR* description, GpMetafile** out_metafile ); }
function GdipConvertToEmfPlusToFile(const RefGraphics: GpGraphics;
  Metafile: GpMetafile; ConversionFailureFlag: PInteger;
  const Filename: PWideChar; EmfType: TGPEmfType; const Description: PWideChar;
  out Out_metafile: GpMetafile): TGPStatus; stdcall; external GdiPlusDll;

{ GdipConvertToEmfPlusToStream( const GpGraphics* refGraphics, GpMetafile* metafile, INT* conversionFailureFlag, IStream* stream, EmfType emfType, const WCHAR* description, GpMetafile** out_metafile ); }
function GdipConvertToEmfPlusToStream(const RefGraphics: GpGraphics;
  Metafile: GpMetafile; ConversionFailureFlag: PInteger; const Stream: IStream;
  EmfType: TGPEmfType; const Description: PWideChar; out Out_metafile: GpMetafile): TGPStatus; stdcall;
  external GdiPlusDll;
{$IFEND}
{$ENDREGION 'GdiplusFlat.h'}

{$REGION 'GdiplusGpStubs.h (2)'}
(*****************************************************************************
 * GdiplusGpStubs.h
 * Private GDI+ header file.
 *****************************************************************************)


//---------------------------------------------------------------------------
// GDI+ classes for forward reference
//---------------------------------------------------------------------------

type
  IGPGraphics = interface;
  IGPPen = interface;
  IGPBrush = interface;
  IGPMatrix = interface;
  IGPBitmap = interface;
  IGPMetafile = interface;
  IGPGraphicsPath = interface;
  IGPGraphicsPathIterator = interface;
  IGPRegion = interface;
  IGPImage = interface;
  IGPTextureBrush = interface;
  IGPHatchBrush = interface;
  IGPSolidBrush = interface;
  IGPLinearGradientBrush = interface;
  IGPPathGradientBrush = interface;
  IGPFont = interface;
  IGPFontFamily = interface;
  IGPFontCollection = interface;
  IGPInstalledFontCollection = interface;
  IGPPrivateFontCollection = interface;
  IGPImageAttributes = interface;
  IGPCachedBitmap = interface;
{$ENDREGION 'GdiplusGpStubs.h (2)'}

{$REGION 'GdiplusRegion.h'}
(*****************************************************************************
 * GdiplusRegion.h
 * GDI+ Region class implementation
 *****************************************************************************)

  IGPRegionData = IGPBuffer;
  IGPRegionScansF = IGPArray<TGPRectF>;
  IGPRegionScans = IGPArray<TGPRect>;

  IGPRegion = interface(IGdiPlusBase)
  ['{BA76B8F7-FEF0-41AA-9E96-59946D279F4D}']
    { Methods }
    function Clone: IGPRegion;
    procedure MakeInfinite;
    procedure MakeEmpty;
    function GetData: IGPRegionData;
    procedure Intersect(const Rect: TGPRect); overload;
    procedure Intersect(const Rect: TGPRectF); overload;
    procedure Intersect(const Path: IGPGraphicsPath); overload;
    procedure Intersect(const Region: IGPRegion); overload;
    procedure Union(const Rect: TGPRect); overload;
    procedure Union(const Rect: TGPRectF); overload;
    procedure Union(const Path: IGPGraphicsPath); overload;
    procedure Union(const Region: IGPRegion); overload;
    procedure ExclusiveOr(const Rect: TGPRect); overload;
    procedure ExclusiveOr(const Rect: TGPRectF); overload;
    procedure ExclusiveOr(const Path: IGPGraphicsPath); overload;
    procedure ExclusiveOr(const Region: IGPRegion); overload;
    procedure Exclude(const Rect: TGPRect); overload;
    procedure Exclude(const Rect: TGPRectF); overload;
    procedure Exclude(const Path: IGPGraphicsPath); overload;
    procedure Exclude(const Region: IGPRegion); overload;
    procedure Complement(const Rect: TGPRect); overload;
    procedure Complement(const Rect: TGPRectF); overload;
    procedure Complement(const Path: IGPGraphicsPath); overload;
    procedure Complement(const Region: IGPRegion); overload;
    procedure Translate(const DX, DY: Single); overload;
    procedure Translate(const DX, DY: Integer); overload;
    procedure Transform(const Matrix: IGPMatrix);
    procedure GetBounds(out Rect: TGPRect; const G: IGPGraphics); overload;
    procedure GetBounds(out Rect: TGPRectF; const G: IGPGraphics); overload;
    function GetHRGN(const G: IGPGraphics): HRGN;
    function IsEmpty(const G: IGPGraphics): Boolean;
    function IsInfinite(const G: IGPGraphics): Boolean;
    function IsVisible(const X, Y: Integer; const G: IGPGraphics = nil): Boolean; overload;
    function IsVisible(const Point: TGPPoint; const G: IGPGraphics = nil): Boolean; overload;
    function IsVisible(const X, Y: Single; const G: IGPGraphics = nil): Boolean; overload;
    function IsVisible(const Point: TGPPointF; const G: IGPGraphics = nil): Boolean; overload;
    function IsVisible(const X, Y, Width, Height: Integer; const G: IGPGraphics = nil): Boolean; overload;
    function IsVisible(const Rect: TGPRect; const G: IGPGraphics = nil): Boolean; overload;
    function IsVisible(const X, Y, Width, Height: Single; const G: IGPGraphics = nil): Boolean; overload;
    function IsVisible(const Rect: TGPRectF; const G: IGPGraphics = nil): Boolean; overload;
    function Equals(const Region: IGPRegion; const G: IGPGraphics): Boolean;
    function GetRegionScans(const Matrix: IGPMatrix): IGPRegionScansF;
    function GetRegionScansI(const Matrix: IGPMatrix): IGPRegionScans;
  end;

  TGPRegion = class(TGdiplusBase, IGPRegion)
  private
    { IGPRegion }
    function Clone: IGPRegion;
    procedure MakeInfinite;
    procedure MakeEmpty;
    function GetData: IGPRegionData;
    procedure Intersect(const Rect: TGPRect); overload;
    procedure Intersect(const Rect: TGPRectF); overload;
    procedure Intersect(const Path: IGPGraphicsPath); overload;
    procedure Intersect(const Region: IGPRegion); overload;
    procedure Union(const Rect: TGPRect); overload;
    procedure Union(const Rect: TGPRectF); overload;
    procedure Union(const Path: IGPGraphicsPath); overload;
    procedure Union(const Region: IGPRegion); overload;
    procedure ExclusiveOr(const Rect: TGPRect); overload;
    procedure ExclusiveOr(const Rect: TGPRectF); overload;
    procedure ExclusiveOr(const Path: IGPGraphicsPath); overload;
    procedure ExclusiveOr(const Region: IGPRegion); overload;
    procedure Exclude(const Rect: TGPRect); overload;
    procedure Exclude(const Rect: TGPRectF); overload;
    procedure Exclude(const Path: IGPGraphicsPath); overload;
    procedure Exclude(const Region: IGPRegion); overload;
    procedure Complement(const Rect: TGPRect); overload;
    procedure Complement(const Rect: TGPRectF); overload;
    procedure Complement(const Path: IGPGraphicsPath); overload;
    procedure Complement(const Region: IGPRegion); overload;
    procedure Translate(const DX, DY: Single); overload;
    procedure Translate(const DX, DY: Integer); overload;
    procedure Transform(const Matrix: IGPMatrix);
    procedure GetBounds(out Rect: TGPRect; const G: IGPGraphics); overload;
    procedure GetBounds(out Rect: TGPRectF; const G: IGPGraphics); overload;
    function GetHRGN(const G: IGPGraphics): HRGN;
    function IsEmpty(const G: IGPGraphics): Boolean;
    function IsInfinite(const G: IGPGraphics): Boolean;
    function IsVisible(const X, Y: Integer; const G: IGPGraphics = nil): Boolean; overload;
    function IsVisible(const Point: TGPPoint; const G: IGPGraphics = nil): Boolean; overload;
    function IsVisible(const X, Y: Single; const G: IGPGraphics = nil): Boolean; overload;
    function IsVisible(const Point: TGPPointF; const G: IGPGraphics = nil): Boolean; overload;
    function IsVisible(const X, Y, Width, Height: Integer; const G: IGPGraphics = nil): Boolean; overload;
    function IsVisible(const Rect: TGPRect; const G: IGPGraphics = nil): Boolean; overload;
    function IsVisible(const X, Y, Width, Height: Single; const G: IGPGraphics = nil): Boolean; overload;
    function IsVisible(const Rect: TGPRectF; const G: IGPGraphics = nil): Boolean; overload;
    function Equals(const Region: IGPRegion; const G: IGPGraphics): Boolean; reintroduce;
    function GetRegionScans(const Matrix: IGPMatrix): IGPRegionScansF;
    function GetRegionScansI(const Matrix: IGPMatrix): IGPRegionScans;
  private
    constructor Create(const NativeRegion: GpRegion); overload;
  public
    constructor Create; overload;
    constructor Create(const Rect: TGPRectF); overload;
    constructor Create(const Rect: TGPRect); overload;
    constructor Create(const Path: IGPGraphicsPath); overload;
    constructor Create(const RegionData: PByte; const Size: Integer); overload;
    constructor Create(const HRgn: HRGN); overload;
    destructor Destroy; override;

    class function FromHRGN(const HRgn: HRGN): IGPRegion; static;
  end;
{$ENDREGION 'GdiplusRegion.h'}

{$REGION 'GdiplusFontFamily.h'}
(*****************************************************************************
 * GdiplusFontFamily.h
 * GDI+ Font Family class
 *****************************************************************************)

  IGPFontFamily = interface(IGdiPlusBase)
  ['{FC545EB0-E826-476E-9435-8ADAE2D191B4}']
    { Property access method }
    function GetFamilyNameInternal: String;

    { Methods }
    function GetFamilyName(const Language: LangID = 0): String;
    function Clone: IGPFontFamily;
    function IsAvailable: Boolean;
    function IsStyleAvailable(const Style: TGPFontStyle): Boolean;
    function GetEmHeight(const Style: TGPFontStyle): Word;
    function GetCellAscent(const Style: TGPFontStyle): Word;
    function GetCellDescent(const Style: TGPFontStyle): Word;
    function GetLineSpacing(const Style: TGPFontStyle): Word;

    { Properties }
    property FamilyName: String read GetFamilyNameInternal;
  end;

  TGPFontFamily = class(TGdiplusBase, IGPFontFamily)
  private
    class var FGenericSansSerifFontFamily: IGPFontFamily;
    class var FGenericSerifFontFamily: IGPFontFamily;
    class var FGenericMonoSpaceFontFamily: IGPFontFamily;
  private
    { IGPFontFamily }
    function GetFamilyNameInternal: String;
    function GetFamilyName(const Language: LangID = 0): String;
    function Clone: IGPFontFamily;
    function IsAvailable: Boolean;
    function IsStyleAvailable(const Style: TGPFontStyle): Boolean;
    function GetEmHeight(const Style: TGPFontStyle): Word;
    function GetCellAscent(const Style: TGPFontStyle): Word;
    function GetCellDescent(const Style: TGPFontStyle): Word;
    function GetLineSpacing(const Style: TGPFontStyle): Word;
  private
    constructor Create(const NativeFamily: GpFontFamily); overload;
  public
    constructor Create; overload;
    constructor Create(const Name: String;
      const FontCollection: IGPFontCollection = nil); overload;
    destructor Destroy; override;

    class function GenericSansSerif: IGPFontFamily; static;
    class function GenericSerif: IGPFontFamily; static;
    class function GenericMonospace: IGPFontFamily; static;
  end;

{$ENDREGION 'GdiplusFontFamily.h'}

{$REGION 'GdiplusFont.h'}
(*****************************************************************************
 * GdiplusFont.h
 * GDI+ Font class
 *****************************************************************************)

  IGPFont = interface(IGdiPlusBase)
  ['{63A81FE2-D0BC-4031-9DD8-0254A1CC732D}']
    { Property access methods }
    function GetStyle: TGPFontStyle;
    function GetSize: Single;
    function GetUnit: TGPUnit;
    function GetFamily: IGPFontFamily;

    { Methods }
    function Clone: IGPFont;
    function GetLogFontA(const G: IGPGraphics): TLogFontA;
    function GetLogFontW(const G: IGPGraphics): TLogFontW;
    function IsAvailable: Boolean;
    function GetHeight(const Graphics: IGPGraphics): Single; overload;
    function GetHeight(const Dpi: Single): Single; overload;

    { Properties }
    property Style: TGPFontStyle read GetStyle;
    property Size: Single read GetSize;
    property MeasureUnit: TGPUnit read GetUnit;
    property Family: IGPFontFamily read GetFamily;
  end;

  TGPFont = class(TGdiPlusBase, IGPFont)
  private
    { IGPFont }
    function GetStyle: TGPFontStyle;
    function GetSize: Single;
    function GetUnit: TGPUnit;
    function Clone: IGPFont;
    function GetLogFontA(const G: IGPGraphics): TLogFontA;
    function GetLogFontW(const G: IGPGraphics): TLogFontW;
    function IsAvailable: Boolean;
    function GetHeight(const Graphics: IGPGraphics): Single; overload;
    function GetHeight(const Dpi: Single): Single; overload;
    function GetFamily: IGPFontFamily;
  private
    constructor Create(const NativeFont: GpFont); overload;
  public
    constructor Create(const DC: HDC); overload;
    constructor Create(const DC: HDC; const LogFont: TLogFontA); overload;
    constructor Create(const DC: HDC; const LogFont: TLogFontW); overload;
    constructor Create(const DC: HDC; const FontHandle: HFont); overload;
    constructor Create(const Family: IGPFontFamily; const EmSize: Single;
      const Style: TGPFontStyle = FontStyleRegular;
      const MeasureUnit: TGPUnit = UnitPoint); overload;
    constructor Create(const FamilyName: String; const EmSize: Single;
      const Style: TGPFontStyle = FontStyleRegular;
      const MeasureUnit: TGPUnit = UnitPoint;
      const FontCollection: IGPFontCollection = nil); overload;
    destructor Destroy; override;
  end;

{$ENDREGION 'GdiplusFont.h'}

{$REGION 'GdiplusFontCollection.h'}
(*****************************************************************************
 * GdiplusFontCollection.h
 * Font collections (Installed and Private)
 *****************************************************************************)

  IGPFontFamilies = IGPArray<IGPFontFamily>;

  IGPFontCollection = interface(IGdiPlusBase)
  ['{5040653F-C5E1-4CA1-9623-6CD258F6DD6C}']
    { Property access methods }
    function GetFamilies: IGPFontFamilies;

    { Properties }
    property Families: IGPFontFamilies read GetFamilies;
  end;

  TGPFontCollection = class(TGdiPlusBase, IGPFontCollection)
  private
    { IGPFontCollection }
    function GetFamilies: IGPFontFamilies;
  public
    constructor Create;
  end;

  IGPInstalledFontCollection = interface(IGPFontCollection)
  ['{168514BC-DC7E-40BC-808D-B2E949AE9F4F}']
  end;

  TGPInstalledFontCollection = class(TGPFontCollection, IGPInstalledFontCollection)
  public
    constructor Create;
  end;

  IGPPrivateFontCollection = interface(IGPFontCollection)
  ['{75E3CC1B-16E4-4203-9796-05B47EB5F076}']
    { Methods }
    procedure AddFontFile(const Filename: String);
    procedure AddMemoryFont(const Memory: Pointer; const Length: Integer);
  end;

  TGPPrivateFontCollection = class(TGPFontCollection, IGPPrivateFontCollection)
  private
    { IGPPrivateFontCollection }
    procedure AddFontFile(const Filename: String);
    procedure AddMemoryFont(const Memory: Pointer; const Length: Integer);
  public
    constructor Create;
    destructor Destroy; override;
  end;

{$ENDREGION 'GdiplusFontCollection.h'}

{$REGION 'GdiplusBitmap.h'}
(*****************************************************************************
 * GdiplusBitmap.h
 * GDI+ Bitmap class
 *****************************************************************************)

  IGPImageFormat = interface
  ['{EDAB4D5F-527C-47D6-B53E-38DB9496725D}']
    { Property access method }
    function GetGuid: TGUID;
    function GetCodecId: TGUID;

    { Properties }
    property Guid: TGUID read GetGUID;
    property CodecId: TGUID read GetCodecId;
  end;

  TGPImageFormat = class(TInterfacedObject, IGPImageFormat)
  private
    FGuid: TGUID;
    FCodecId: TGUID;
    class var FInitialized: Boolean;
    class var FBmp: IGPImageFormat;
    class var FJpeg: IGPImageFormat;
    class var FGif: IGPImageFormat;
    class var FTiff: IGPImageFormat;
    class var FPng: IGPImageFormat;
    class function GetBmp: IGPImageFormat; static;
    class function GetJpeg: IGPImageFormat; static;
    class function GetGif: IGPImageFormat; static;
    class function GetTiff: IGPImageFormat; static;
    class function GetPng: IGPImageFormat; static;
    class procedure InitializeCodecs; static;
  private
    { IGPImageFormat }
    function GetGuid: TGuid;
    function GetCodecId: TGUID;
  public
    constructor Create(const Guid: TGUID); overload;
    constructor Create(const Guid, CodecId: TGUID); overload;
    class function FindByFormatId(const lFormatId: TGUID): IGPImageFormat; static;

    class property Bmp: IGPImageFormat read GetBmp;
    class property Jpeg: IGPImageFormat read GetJpeg;
    class property Gif: IGPImageFormat read GetGif;
    class property Tiff: IGPImageFormat read GetTiff;
    class property Png: IGPImageFormat read GetPng;
  end;

  IGPImageCodecInfo = interface
  ['{4AAE3ECA-3AEA-4C20-8D17-865F07393536}']
    { Property access methods }
    function GetClsId: TGUID;
    function GetCodecName: String;
    function GetDllName: String;
    function GetFilenameExtension: String;
    function GetFlags: TGPImageCodecFlags;
    function GetFormatDescription: String;
    function GetFormatId: TGUID;
    function GetMimeType: String;
    function GetVersion: Integer;

    { Properties }
    property ClsId: TGUID read GetClsId;
    property CodecName: String read GetCodecName;
    property DllName: String read GetDllName;
    property FilenameExtension: String read GetFilenameExtension;
    property Flags: TGPImageCodecFlags read GetFlags;
    property FormatDescription: String read GetFormatDescription;
    property FormatId: TGUID read GetFormatId;
    property MimeType: String read GetMimeType;
    property Version: Integer read GetVersion;
  end;

  IGPImageCodecInfoArray = IGPArray<IGPImageCodecInfo>;

  TGPImageCodecInfo = class(TInterfacedObject, IGPImageCodecInfo)
  private
    FInfo: TGPNativeImageCodecInfo;
  private
    { IGPImageCodecInfo }
    function GetClsId: TGUID;
    function GetCodecName: String;
    function GetDllName: String;
    function GetFilenameExtension: String;
    function GetFlags: TGPImageCodecFlags;
    function GetFormatDescription: String;
    function GetFormatId: TGUID;
    function GetMimeType: String;
    function GetVersion: Integer;
  public
    constructor Create(const Info: TGPNativeImageCodecInfo);
    class function GetImageDecoders: IGPImageCodecInfoArray; static;
    class function GetImageEncoders: IGPImageCodecInfoArray; static;
  end;

  IGPEncoderParameters = interface;

  TGPEncoderParameterEnumerator = class
  private
    FIndex: Integer;
    FParams: IGPEncoderParameters;
  public
    constructor Create(const AParams: IGPEncoderParameters);
    function GetCurrent: PGPNativeEncoderParameter;
    function MoveNext: Boolean;
    property Current: PGPNativeEncoderParameter read GetCurrent;
  end;

  IGPEncoderParameters = interface
  ['{284A0A77-1831-483A-AF75-903FCFB50A56}']
    { Property access methods }
    function GetCount: Integer;
    function GetParam(const Index: Integer): PGPNativeEncoderParameter;
    function GetNativeParams: PGPNativeEncoderParameters;

    { Methods }
    function GetEnumerator: TGPEncoderParameterEnumerator;
    procedure Clear;
    procedure Add(const ParamType: TGUID; const Value: TGPEncoderValue); overload;
    procedure Add(const ParamType: TGUID; const Value: array of TGPEncoderValue); overload;
    procedure Add(const ParamType: TGUID; var Value: Byte); overload;
    procedure Add(const ParamType: TGUID; const Value: array of Byte); overload;
    procedure Add(const ParamType: TGUID; var Value: Int16); overload;
    procedure Add(const ParamType: TGUID; const Value: array of Int16); overload;
    procedure Add(const ParamType: TGUID; var Value: Int32); overload;
    procedure Add(const ParamType: TGUID; const Value: array of Int32); overload;
    procedure Add(const ParamType: TGUID; var Value: Int64); overload;
    procedure Add(const ParamType: TGUID; const Value: array of Int64); overload;
    procedure Add(const ParamType: TGUID; const Value: String); overload;
    procedure Add(const ParamType: TGUID; const Value: Byte;
      const Undefined: Boolean); overload;
    procedure Add(const ParamType: TGUID; const Value: array of Byte;
      const Undefined: Boolean); overload;
    procedure Add(const ParamType: TGUID; var Numerator, Denominator: Int32); overload;
    procedure Add(const ParamType: TGUID; const Numerators,
      Denominators: array of Int32); overload;
    procedure Add(const ParamType: TGUID; var RangeBegin, RangeEnd: Int64); overload;
    procedure Add(const ParamType: TGUID; const RangesBegin,
      RangesEnd: array of Int64); overload;
    procedure Add(const ParamType: TGUID; const NumberOfValues: Integer;
      const ValueType: TGPEncoderParameterValueType; const Value: Pointer); overload;
    procedure Add(const ParamType: TGUID; const Numerator1, Denominator1,
      Numerator2, Denominator2: Int32); overload;
    procedure Add(const ParamType: TGUID; const Numerator1, Denominator1,
      Numerator2, Denominator2: array of Int32); overload;

    { Properties }
    property Count: Integer read GetCount;
    property Param[const Index: Integer]: PGPNativeEncoderParameter read GetParam; default;
    property NativeParams: PGPNativeEncoderParameters read GetNativeParams;
  end;

  TGPEncoderParameters = class(TInterfacedObject, IGPEncoderParameters)
  private
    FParams: array of TGPNativeEncoderParameter;
    FParamCount: Integer;
    FValues: Pointer;
    FValueSize: Integer;
    FValueAllocated: Integer;
    FNativeParams: PGPNativeEncoderParameters;
    FModified: Boolean;
  private
    { IGPEncoderParameters }
    function GetNativeParams: PGPNativeEncoderParameters;
    function GetEnumerator: TGPEncoderParameterEnumerator;
    function GetCount: Integer;
    function GetParam(const Index: Integer): PGPNativeEncoderParameter;
    procedure Clear;
    procedure Add(const ParamType: TGUID; const Value: TGPEncoderValue); overload;
    procedure Add(const ParamType: TGUID; const Value: array of TGPEncoderValue); overload;
    procedure Add(const ParamType: TGUID; var Value: Byte); overload;
    procedure Add(const ParamType: TGUID; const Value: array of Byte); overload;
    procedure Add(const ParamType: TGUID; var Value: Int16); overload;
    procedure Add(const ParamType: TGUID; const Value: array of Int16); overload;
    procedure Add(const ParamType: TGUID; var Value: Int32); overload;
    procedure Add(const ParamType: TGUID; const Value: array of Int32); overload;
    procedure Add(const ParamType: TGUID; var Value: Int64); overload;
    procedure Add(const ParamType: TGUID; const Value: array of Int64); overload;
    procedure Add(const ParamType: TGUID; const Value: String); overload;
    procedure Add(const ParamType: TGUID; const Value: Byte;
      const Undefined: Boolean); overload;
    procedure Add(const ParamType: TGUID; const Value: array of Byte;
      const Undefined: Boolean); overload;
    procedure Add(const ParamType: TGUID; var Numerator, Denominator: Int32); overload;
    procedure Add(const ParamType: TGUID; const Numerators,
      Denominators: array of Int32); overload;
    procedure Add(const ParamType: TGUID; var RangeBegin, RangeEnd: Int64); overload;
    procedure Add(const ParamType: TGUID; const RangesBegin,
      RangesEnd: array of Int64); overload;
    procedure Add(const ParamType: TGUID; const NumberOfValues: Integer;
      const ValueType: TGPEncoderParameterValueType; const Value: Pointer); overload;
    procedure Add(const ParamType: TGUID; const Numerator1, Denominator1,
      Numerator2, Denominator2: Int32); overload;
    procedure Add(const ParamType: TGUID; const Numerator1, Denominator1,
      Numerator2, Denominator2: array of Int32); overload;
  private
    constructor Create(const Params: PGPNativeEncoderParameters); overload;
  public
    constructor Create; overload;
    destructor Destroy; override;
  end;

  IGPColorPalette = interface
  ['{17D63D7E-20F6-445F-AEFC-3D53FC8D01CE}']
    { Property access methods }
    function GetFlags: TGPPaletteFlags;
    procedure SetFlags(const Value: TGPPaletteFlags);
    function GetCount: Integer;
    function GetEntry(const Index: Integer): ARGB;
    procedure SetEntry(const Index: Integer; const Value: ARGB);
    function GetEntryPtr: PARGB;
    function GetNativePalette: PGPNativeColorPalette;

    { Properties }
    property Flags: TGPPaletteFlags read GetFlags write SetFlags;
    property Count: Integer read GetCount;
    property Entries[const Index: Integer]: ARGB read GetEntry write SetEntry; default;
    property EntryPtr: PARGB read GetEntryPtr;
    property NativePalette: PGPNativeColorPalette read GetNativePalette;
  end;

  TGPColorPalette = class(TInterfacedObject, IGPColorPalette)
  private
    FData: PGPNativeColorPalette;
    FEntries: PARGB;
  private
    { IGPColorPalette }
    function GetFlags: TGPPaletteFlags;
    procedure SetFlags(const Value: TGPPaletteFlags);
    function GetCount: Integer;
    function GetEntry(const Index: Integer): ARGB;
    procedure SetEntry(const Index: Integer; const Value: ARGB);
    function GetEntryPtr: PARGB;
    function GetNativePalette: PGPNativeColorPalette;
  private
    constructor Create(const NativePalette: PGPNativeColorPalette); overload;
  public
    constructor Create(const Count: Integer); overload;
    destructor Destroy; override;
  end;

  IGPPropertyItem = interface
  ['{8886FE82-91E0-4069-B7BA-EA4A99E28AB4}']
    { Property access methods }
    function GetId: TPropID;
    procedure SetId(const Value: TPropID);
    function GetLength: Cardinal;
    procedure SetLength(const Value: Cardinal);
    function GetValueType: Word;
    procedure SetValueType(const Value: Word);
    function GetValue: Pointer;
    procedure SetValue(const Value: Pointer);
    function GetNativeItem: PGPNativePropertyItem;

    { Properties }
    property Id: TPropID read GetId write SetId;
    property Length: Cardinal read GetLength write SetLength;
    property ValueType: Word read GetValueType write SetValueType;
    property Value: Pointer read GetValue write SetValue;
    property NativeItem: PGPNativePropertyItem read GetNativeItem;
  end;

  TGPPropertyItem = class(TInterfacedObject, IGPPropertyItem)
  private
    FData: PGPNativePropertyItem;
  private
    { IGPPropertyItem }
    function GetId: TPropID;
    procedure SetId(const Value: TPropID);
    function GetLength: Cardinal;
    procedure SetLength(const Value: Cardinal);
    function GetValueType: Word;
    procedure SetValueType(const Value: Word);
    function GetValue: Pointer;
    procedure SetValue(const Value: Pointer);
    function GetNativeItem: PGPNativePropertyItem;
  private
    constructor Create(const Data: PGPNativePropertyItem); overload;
  public
    constructor Create; overload;
    destructor Destroy; override;
  end;

  IGPFrameDimensions = IGPArray<TGUID>;
  IGPPropertyIdList = IGPArray<TPropID>;
  IGPPropertyItems = IGPArray<IGPPropertyItem>;

  IGPImage = interface(IGdiPlusBase)
  ['{9E494AC2-7002-41CD-9776-CA6B5A4E8426}']
    { Property access methods }
    function GetType: TGPImageType;
    function GetWidth: Cardinal;
    function GetHeight: Cardinal;
    function GetHorizontalResolution: Single;
    function GetVerticalResolution: Single;
    function GetFlags: TGPImageFlags;
    function GetRawFormat: TGUID;
    function GetPixelFormat: TGPPixelFormat;
    function GetPalette: IGPColorPalette;
    procedure SetPalette(const Value: IGPColorPalette);
    function GetPropertyIdList: IGPPropertyIdList;
    function GetPropertyItems: IGPPropertyItems;

    { Methods }
    function Clone: IGPImage;
    procedure Save(const Filename: String; const Format: IGPImageFormat;
      const Params: IGPEncoderParameters = nil); overload;
    procedure Save(const Filename: String; const Encoder: IGPImageCodecInfo;
      const Params: IGPEncoderParameters = nil); overload;
    procedure Save(const Stream: IStream; const Format: IGPImageFormat;
      const Params: IGPEncoderParameters = nil); overload;
    procedure Save(const Stream: IStream; const Encoder: IGPImageCodecInfo;
      const Params: IGPEncoderParameters = nil); overload;
    procedure SaveAdd(const Params: IGPEncoderParameters); overload;
    procedure SaveAdd(const NewImage: IGPImage;
      const Params: IGPEncoderParameters); overload;
    procedure GetPhysicalDimension(out Size: TGPSizeF);
    procedure GetBounds(out SrcRect: TGPRectF; out SrcUnit: TGPUnit);
    function GetThumbnailImage(const ThumbWidth, ThumbHeight: Cardinal;
      const Callback: TGPGetThumbnailImageAbort = nil;
      const CallbackData: Pointer = nil): IGPImage;
    function GetFrameDimensions: IGPFrameDimensions;
    function GetFrameCount(const DimensionID: TGUID): Cardinal;
    procedure SelectActiveFrame(const DimensionID: TGUID;
      const FrameIndex: Cardinal);
    procedure RotateFlip(const RotateFlipType: TGPRotateFlipType);
    function GetPropertyItem(const PropId: TPropID): IGPPropertyItem;
    procedure SetPropertyItem(const PropItem: IGPPropertyItem);
    procedure RemovePropertyItem(const PropId: TPropID);
    function GetEncoderParameterList(const lEncoder: TGUID): IGPEncoderParameters;
    {$IF (GDIPVER >= $0110)}
    procedure FindFirstItem(const Item: PGPImageItemData);
    procedure FindNextItem(const Item: PGPImageItemData);
    procedure GetItemData(const Item: PGPImageItemData);
    procedure SetAbort(const Abort: TGdiplusAbort);
    {$IFEND}

    { Properties }
    property ImageType: TGPImageType read GetType;
    property Width: Cardinal read GetWidth;
    property Height: Cardinal read GetHeight;
    property HorizontalResolution: Single read GetHorizontalResolution;
    property VerticalResolution: Single read GetVerticalResolution;
    property Flags: TGPImageFlags read GetFlags;
    property RawFormat: TGUID read GetRawFormat;
    property PixelFormat: TGPPixelFormat read GetPixelFormat;
    property Palette: IGPColorPalette read GetPalette write SetPalette;
    property PropertyIdList: IGPPropertyIdList read GetPropertyIdList;
    property PropertyItems: IGPPropertyItems read GetPropertyItems;
  end;

  TGPImage = class(TGdiplusBase, IGPImage)
  private
    { IGPImage }
    function GetType: TGPImageType;
    function GetWidth: Cardinal;
    function GetHeight: Cardinal;
    function GetHorizontalResolution: Single;
    function GetVerticalResolution: Single;
    function GetFlags: TGPImageFlags;
    function GetRawFormat: TGUID;
    function GetPixelFormat: TGPPixelFormat;
    function GetPalette: IGPColorPalette;
    procedure SetPalette(const Value: IGPColorPalette);
    function GetPropertyIdList: IGPPropertyIdList;
    function GetPropertyItems: IGPPropertyItems;

    function Clone: IGPImage;
    procedure Save(const Filename: String; const Format: IGPImageFormat;
      const Params: IGPEncoderParameters = nil); overload;
    procedure Save(const Filename: String; const Encoder: IGPImageCodecInfo;
      const Params: IGPEncoderParameters = nil); overload;
    procedure Save(const Stream: IStream; const Format: IGPImageFormat;
      const Params: IGPEncoderParameters = nil); overload;
    procedure Save(const Stream: IStream; const Encoder: IGPImageCodecInfo;
      const Params: IGPEncoderParameters = nil); overload;
    procedure SaveAdd(const Params: IGPEncoderParameters); overload;
    procedure SaveAdd(const NewImage: IGPImage;
      const Params: IGPEncoderParameters); overload;
    procedure GetPhysicalDimension(out Size: TGPSizeF);
    procedure GetBounds(out SrcRect: TGPRectF; out SrcUnit: TGPUnit);
    function GetThumbnailImage(const ThumbWidth, ThumbHeight: Cardinal;
      const Callback: TGPGetThumbnailImageAbort = nil;
      const CallbackData: Pointer = nil): IGPImage;
    function GetFrameDimensions: IGPFrameDimensions;
    function GetFrameCount(const DimensionID: TGUID): Cardinal;
    procedure SelectActiveFrame(const DimensionID: TGUID;
      const FrameIndex: Cardinal);
    procedure RotateFlip(const RotateFlipType: TGPRotateFlipType);
    function GetPropertyItem(const PropId: TPropID): IGPPropertyItem;
    procedure SetPropertyItem(const PropItem: IGPPropertyItem);
    procedure RemovePropertyItem(const PropId: TPropID);
    function GetEncoderParameterList(const lEncoder: TGUID): IGPEncoderParameters;
    {$IF (GDIPVER >= $0110)}
    procedure FindFirstItem(const Item: PGPImageItemData);
    procedure FindNextItem(const Item: PGPImageItemData);
    procedure GetItemData(const Item: PGPImageItemData);
    procedure SetAbort(const Abort: TGdiplusAbort);
    {$IFEND}
  private
    constructor Create(const NativeImage: GpImage); overload;
  public
    constructor Create(const Filename: String;
      const UseEmbeddedColorManagement: Boolean = False); overload;
    constructor Create(const Stream: IStream;
      const UseEmbeddedColorManagement: Boolean = False); overload;
    destructor Destroy; override;

    class function FromFile(const Filename: String;
      const UseEmbeddedColorManagement: Boolean = False): IGPImage; static;
    class function FromStream(const Stream: IStream;
      const UseEmbeddedColorManagement: Boolean = False): IGPImage; static;
  end;

  {$IF (GDIPVER >= $0110)}
  IGPHistogram = interface
  ['{4449210B-46EF-46B0-9458-CE3277CBBA67}']
    { Property access methods }
    function GetChannelCount: Integer;
    function GetEntryCount: Integer;
    function GetValue(const ChannelIndex, EntryIndex: Integer): Cardinal;
    function GetChannel0(const Index: Integer): Cardinal;
    function GetChannel1(const Index: Integer): Cardinal;
    function GetChannel2(const Index: Integer): Cardinal;
    function GetChannel3(const Index: Integer): Cardinal;
    function GetValuePtr(const ChannelIndex: Integer): PCardinal;
    function GetChannel0Ptr: PCardinal;
    function GetChannel1Ptr: PCardinal;
    function GetChannel2Ptr: PCardinal;
    function GetChannel3Ptr: PCardinal;

    { Properties }
    property ChannelCount: Integer read GetChannelCount;
    property EntryCount: Integer read GetEntryCount;
    property Values[const ChannelIndex, EntryIndex: Integer]: Cardinal read GetValue; default;
    property Channel0[const Index: Integer]: Cardinal read GetChannel0;
    property Channel1[const Index: Integer]: Cardinal read GetChannel1;
    property Channel2[const Index: Integer]: Cardinal read GetChannel2;
    property Channel3[const Index: Integer]: Cardinal read GetChannel3;
    property ValuePtr[const ChannelIndex: Integer]: PCardinal read GetValuePtr;
    property Channel0Ptr: PCardinal read GetChannel0Ptr;
    property Channel1Ptr: PCardinal read GetChannel1Ptr;
    property Channel2Ptr: PCardinal read GetChannel2Ptr;
    property Channel3Ptr: PCardinal read GetChannel3Ptr;
  end;

  TGPHistogram = class(TInterfacedObject, IGPHistogram)
  private
    FChannelCount: Integer;
    FEntryCount: Integer;
    FChannels: array [0..3] of PCardinal;
  private
    { IGPHistogram }
    function GetChannelCount: Integer;
    function GetEntryCount: Integer;
    function GetValue(const ChannelIndex, EntryIndex: Integer): Cardinal;
    function GetChannel0(const Index: Integer): Cardinal;
    function GetChannel1(const Index: Integer): Cardinal;
    function GetChannel2(const Index: Integer): Cardinal;
    function GetChannel3(const Index: Integer): Cardinal;
    function GetValuePtr(const ChannelIndex: Integer): PCardinal;
    function GetChannel0Ptr: PCardinal;
    function GetChannel1Ptr: PCardinal;
    function GetChannel2Ptr: PCardinal;
    function GetChannel3Ptr: PCardinal;
  private
    constructor Create(const AChannelCount, AEntryCount: Integer;
      const AChannel0, AChannel1, AChannel2, AChannel3: PCardinal);
  public
    destructor Destroy; override;
  end;
  {$IFEND}

  IGPBitmap = interface(IGPImage)
  ['{704FC1E3-DAFC-4775-9BCB-D7D70741BB54}']
    { Property access methods }
    function GetPixel(const X, Y: Integer): TGPColor;
    procedure SetPixel(const X, Y: Integer; const Value: TGPColor);

    { Methods }
    function Clone: IGPBitmap; overload;
    function Clone(const Rect: TGPRect; const Format: TGPPixelFormat): IGPBitmap; overload;
    function Clone(const X, Y, Width, Height: Integer; const Format: TGPPixelFormat): IGPBitmap; overload;
    function Clone(const Rect: TGPRectF; const Format: TGPPixelFormat): IGPBitmap; overload;
    function Clone(const X, Y, Width, Height: Single; const Format: TGPPixelFormat): IGPBitmap; overload;
    function LockBits(const Rect: TGPRect; const Mode: TGPImageLockMode;
      const Format: TGPPixelFormat): TGPBitmapData;
    procedure UnlockBits(const LockedBitmapData: TGPBitmapData);
    {$IF (GDIPVER >= $0110)}
    procedure ConvertFormat(const Format: TGPPixelFormat;
      const DitherType: TGPDitherType; const PaletteType: TGPPaletteType;
      const Palette: IGPColorPalette = nil; const AlphaThresholdPercent: Single = 0);
    procedure ApplyEffect(const Effect: IGPEffect; const ROI: Windows.PRect = nil);
    function GetHistogram(const Format: TGPHistogramFormat): IGPHistogram;
    {$IFEND}
    procedure SetResolution(const XDpi, YDpi: Single);
    function GetHBitmap(const ColorBackground: TGPColor): HBitmap;
    function GetHIcon: HIcon;

    { Properties }
    property Pixels[const X, Y: Integer]: TGPColor read GetPixel write SetPixel; default;
  end;

  TGPBitmap = class(TGPImage, IGPBitmap)
  private
    { IGPBitmap }
    function GetPixel(const X, Y: Integer): TGPColor;
    procedure SetPixel(const X, Y: Integer; const Value: TGPColor);

    function Clone: IGPBitmap; overload;
    function Clone(const Rect: TGPRect; const Format: TGPPixelFormat): IGPBitmap; overload;
    function Clone(const X, Y, Width, Height: Integer; const Format: TGPPixelFormat): IGPBitmap; overload;
    function Clone(const Rect: TGPRectF; const Format: TGPPixelFormat): IGPBitmap; overload;
    function Clone(const X, Y, Width, Height: Single; const Format: TGPPixelFormat): IGPBitmap; overload;
    function LockBits(const Rect: TGPRect; const Mode: TGPImageLockMode;
      const Format: TGPPixelFormat): TGPBitmapData;
    procedure UnlockBits(const LockedBitmapData: TGPBitmapData);
    {$IF (GDIPVER >= $0110)}
    procedure ConvertFormat(const Format: TGPPixelFormat;
      const DitherType: TGPDitherType; const PaletteType: TGPPaletteType;
      const Palette: IGPColorPalette; const AlphaThresholdPercent: Single);
    procedure ApplyEffect(const Effect: IGPEffect; const ROI: Windows.PRect); overload;
    function GetHistogram(const Format: TGPHistogramFormat): IGPHistogram;
    {$IFEND}
    procedure SetResolution(const XDpi, YDpi: Single);
    function GetHBitmap(const ColorBackground: TGPColor): HBitmap;
    function GetHIcon: HIcon;
  private
    constructor Create(const NativeBitmap: GpBitmap); overload;
  public
    constructor Create(const Filename: String;
      const UseEmbeddedColorManagement: Boolean = False); overload;
    constructor Create(const Stream: IStream;
      const UseEmbeddedColorManagement: Boolean = False); overload;
    constructor Create(const Width, Height, Stride: Integer;
      const Format: TGPPixelFormat; const Scan0: Pointer); overload;
    constructor Create(const Width, Height: Integer;
      const Format: TGPPixelFormat = PixelFormat32bppARGB); overload;
    constructor Create(const Width, Height: Integer;
      const Target: IGPGraphics); overload;
    constructor Create(const DirectDrawSurface7: IUnknown); overload;
    constructor Create(const BitmapInfo: TBitmapInfo;
      const BitmapData: Pointer); overload;
    constructor Create(const BitmapHandle: HBitmap;
      const Palette: HPalette); overload;
    constructor Create(const IconHandle: HIcon); overload;
    constructor Create(const Instance: HInst; const BitmapName: String); overload;

    class function FromFile(const Filename: String;
      const UseEmbeddedColorManagement: Boolean = False): IGPBitmap; static;
    class function FromStream(const Stream: IStream;
      const UseEmbeddedColorManagement: Boolean = False): IGPBitmap; static;
    class function FromDirectDrawSurface7(const Surface: IUnknown): IGPBitmap;
    class function FromBitmapInfo(const BitmapInfo: TBitmapInfo;
      const BitmapData: Pointer): IGPBitmap;
    class function FromHBitmap(const BitmapHandle: HBitmap;
      const Palette: HPalette): IGPBitmap;
    class function FromHIcon(const IconHandle: HIcon): IGPBitmap;
    class function FromResource(const Instance: HInst;
      const BitmapName: String): IGPBitmap;

    {$IF (GDIPVER >= $0110)}
    class function InitializePalette(const ColorCount: Integer;
      const PaletteType: TGPPaletteType; const OptimalColors: Integer;
      const UseTransparentColor: Boolean; const Bitmap: IGPBitmap): IGPColorPalette; static;
    class function ApplyEffect(const Inputs: array of IGPBitmap;
      const Effect: IGPEffect; const ROI, OutputRect: Windows.PRect): IGPBitmap; overload;
    {$IFEND}
  end;

{$ENDREGION 'GdiplusBitmap.h'}

{$REGION 'GdiplusLineCaps.h'}
(*****************************************************************************
 * GdiplusLineCaps.h
 * GDI+ CustomLineCap APIs
 *****************************************************************************)

  IGPCustomLineCap = interface(IGdiPlusBase)
  ['{6BF10928-312C-42F6-83DE-76D98FFFCD7B}']
    { Property access methods }
    function GetStrokeJoin: TGPLineJoin;
    procedure SetStrokeJoin(const Value: TGPLineJoin);
    function GetBaseCap: TGPLineCap;
    procedure SetBaseCap(const Value: TGPLineCap);
    function GetBaseInset: Single;
    procedure SetBaseInset(const Value: Single);
    function GetWidthScale: Single;
    procedure SetWidthScale(const Value: Single);

    { Methods }
    function Clone: IGPCustomLineCap;
    procedure SetStrokeCap(const StrokeCap: TGPLineCap);
    procedure SetStrokeCaps(const StartCap, EndCap: TGPLineCap);
    procedure GetStrokeCaps(out StartCap, EndCap: TGPLineCap);

    { Properties }
    property StrokeJoin: TGPLineJoin read GetStrokeJoin write SetStrokeJoin;
    property BaseCap: TGPLineCap read GetBaseCap write SetBaseCap;
    property BaseInset: Single read GetBaseInset write SetBaseInset;
    property WidthScale: Single read GetWidthScale write SetWidthScale;
  end;

  TGPCustomLineCap = class(TGdiplusBase, IGPCustomLineCap)
  private
    { IGPCustomLineCap }
    function GetStrokeJoin: TGPLineJoin;
    procedure SetStrokeJoin(const Value: TGPLineJoin);
    function GetBaseCap: TGPLineCap;
    procedure SetBaseCap(const Value: TGPLineCap);
    function GetBaseInset: Single;
    procedure SetBaseInset(const Value: Single);
    function GetWidthScale: Single;
    procedure SetWidthScale(const Value: Single);

    function Clone: IGPCustomLineCap;
    procedure SetStrokeCap(const StrokeCap: TGPLineCap);
    procedure SetStrokeCaps(const StartCap, EndCap: TGPLineCap);
    procedure GetStrokeCaps(out StartCap, EndCap: TGPLineCap);
  private
    constructor Create(const NativeLineCap: GpCustomLineCap); overload;
  public
    constructor Create(const FillPath, StrokePath: IGPGraphicsPath;
      const BaseCap: TGPLineCap = LineCapFlat; const BaseInset: Single = 0); overload;
    destructor Destroy; override;
  end;

  IGPAdjustableArrowCap = interface(IGPCustomLineCap)
  ['{25BE82E3-DF7F-4143-B5EA-3E535BDD3A86}']
    { Property access methods }
    function GetHeight: Single;
    procedure SetHeight(const Value: Single);
    function GetWidth: Single;
    procedure SetWidth(const Value: Single);
    function GetMiddleInset: Single;
    procedure SetMiddleInset(const Value: Single);
    function GetFilled: Boolean;
    procedure SetFilled(const Value: Boolean);

    { Properties }
    property Height: Single read GetHeight write SetHeight;
    property Width: Single read GetWidth write SetWidth;
    property MiddleInset: Single read GetMiddleInset write SetMiddleInset;
    property Filled: Boolean read GetFilled write SetFilled;
  end;

  TGPAdjustableArrowCap = class(TGPCustomLineCap, IGPAdjustableArrowCap)
  private
    { IGPAdjustableArrowCap }
    function GetHeight: Single;
    procedure SetHeight(const Value: Single);
    function GetWidth: Single;
    procedure SetWidth(const Value: Single);
    function GetMiddleInset: Single;
    procedure SetMiddleInset(const Value: Single);
    function GetFilled: Boolean;
    procedure SetFilled(const Value: Boolean);
  public
    constructor Create(const Height, Width: Single;
      const IsFilled: Boolean = True); overload;
  end;
{$ENDREGION 'GdiplusLineCaps.h'}

{$REGION 'GdiplusCachedBitmap.h'}
(*****************************************************************************
 * GdiplusCachedBitmap.h
 * GDI+ CachedBitmap is a representation of an accelerated drawing
 * that has restrictions on what operations are allowed in order
 * to accelerate the drawing to the destination.
 *****************************************************************************)

  IGPCachedBitmap = interface(IGdiPlusBase)
  ['{1F77CA35-C917-4167-87CF-BF9DBB23FCAB}']
  end;

  TGPCachedBitmap = class(TGdiplusBase, IGPCachedBitmap)
  public
    constructor Create(const Bitmap: IGPBitmap; const Graphics: IGPGraphics); overload;
    destructor Destroy; override;
  end;

{$ENDREGION 'GdiplusCachedBitmap.h'}

{$REGION 'GdiplusMetafile.h'}
(*****************************************************************************
 * GdiplusMetafile.h
 * GDI+ Metafile class
 *****************************************************************************)

  IGPMetafile = interface(IGPImage)
  ['{BBA510DD-1D60-4067-839C-C77733BCC2AB}']
    { Property access methods }
    function GetDownLevelRasterizationLimit: Cardinal;
    procedure SetDownLevelRasterizationLimit(const Value: Cardinal);

    { Methods }
    function GetMetafileHeader: TGPMetafileHeader;
    function GetHEnhMetafile: HEnhMetafile;
    procedure PlayRecord(const RecordType: TEmfPlusRecordType;
      const Flags, DataSize: Integer; const Data: Pointer);
    {$IF (GDIPVER >= $0110)}
    procedure ConvertToEmfPlus(const RefGraphics: IGPGraphics;
      const ConversionFailureFlag: PInteger = nil;
      const EmfType: TGPEmfType = EmfTypeEmfPlusOnly;
      const Description: String = ''); overload;
    procedure ConvertToEmfPlus(const RefGraphics: IGPGraphics;
      const Filename: String; const ConversionFailureFlag: PInteger = nil;
      const EmfType: TGPEmfType = EmfTypeEmfPlusOnly;
      const Description: String = ''); overload;
    procedure ConvertToEmfPlus(const RefGraphics: IGPGraphics;
      const Stream: IStream; const ConversionFailureFlag: PInteger = nil;
      const EmfType: TGPEmfType = EmfTypeEmfPlusOnly;
      const Description: String = ''); overload;
    {$IFEND}

    { Properties }
    property DownLevelRasterizationLimit: Cardinal read GetDownLevelRasterizationLimit write SetDownLevelRasterizationLimit;
  end;

  TGPMetafile = class(TGPImage, IGPMetafile)
  private
    { IGPMetafile }
    function GetDownLevelRasterizationLimit: Cardinal;
    procedure SetDownLevelRasterizationLimit(const Value: Cardinal);

    function GetMetafileHeader: TGPMetafileHeader; overload;
    function GetHEnhMetafile: HEnhMetafile;
    procedure PlayRecord(const RecordType: TEmfPlusRecordType;
      const Flags, DataSize: Integer; const Data: Pointer);
    {$IF (GDIPVER >= $0110)}
    procedure ConvertToEmfPlus(const RefGraphics: IGPGraphics;
      const ConversionFailureFlag: PInteger = nil;
      const EmfType: TGPEmfType = EmfTypeEmfPlusOnly;
      const Description: String = ''); overload;
    procedure ConvertToEmfPlus(const RefGraphics: IGPGraphics;
      const Filename: String; const ConversionFailureFlag: PInteger = nil;
      const EmfType: TGPEmfType = EmfTypeEmfPlusOnly;
      const Description: String = ''); overload;
    procedure ConvertToEmfPlus(const RefGraphics: IGPGraphics;
      const Stream: IStream; const ConversionFailureFlag: PInteger = nil;
      const EmfType: TGPEmfType = EmfTypeEmfPlusOnly;
      const Description: String = ''); overload;
    {$IFEND}
  public
    constructor Create(const Wmf: HMetafile;
      const WmfPlaceableFileHeader: TWmfPlaceableFileHeader;
      const DeleteWmf: Boolean = False); overload;
    constructor Create(const Emf: HEnhMetafile; const DeleteEmf: Boolean = False); overload;
    constructor Create(const Filename: String); overload;
    constructor Create(const Filename: String;
      const WmfPlaceableFileHeader: TWmfPlaceableFileHeader); overload;
    constructor Create(const Stream: IStream); overload;
    constructor Create(const ReferenceDC: HDC;
      const EmfType: TGPEmfType = EmfTypeEmfPlusDual;
      const Description: String = ''); overload;
    constructor Create(const ReferenceDC: HDC; const FrameRect: TGPRectF;
      const FrameUnit: TGPMetafileFrameUnit = MetafileFrameUnitGdi;
      const EmfType: TGPEmfType = EmfTypeEmfPlusDual;
      const Description: String = ''); overload;
    constructor Create(const ReferenceDC: HDC; const FrameRect: TGPRect;
      const FrameUnit: TGPMetafileFrameUnit = MetafileFrameUnitGdi;
      const EmfType: TGPEmfType = EmfTypeEmfPlusDual;
      const Description: String = ''); overload;
    constructor Create(const Filename: String; const ReferenceDC: HDC;
      const EmfType: TGPEmfType = EmfTypeEmfPlusDual;
      const Description: String = ''); overload;
    constructor Create(const Filename: String; const ReferenceDC: HDC;
      const FrameRect: TGPRectF;
      const FrameUnit: TGPMetafileFrameUnit = MetafileFrameUnitGdi;
      const EmfType: TGPEmfType = EmfTypeEmfPlusDual;
      const Description: String = ''); overload;
    constructor Create(const Filename: String; const ReferenceDC: HDC;
      const FrameRect: TGPRect;
      const FrameUnit: TGPMetafileFrameUnit = MetafileFrameUnitGdi;
      const EmfType: TGPEmfType = EmfTypeEmfPlusDual;
      const Description: String = ''); overload;
    constructor Create(const Stream: IStream; const ReferenceDC: HDC;
      const EmfType: TGPEmfType = EmfTypeEmfPlusDual;
      const Description: String = ''); overload;
    constructor Create(const Stream: IStream; const ReferenceDC: HDC;
      const FrameRect: TGPRectF;
      const FrameUnit: TGPMetafileFrameUnit = MetafileFrameUnitGdi;
      const EmfType: TGPEmfType = EmfTypeEmfPlusDual;
      const Description: String = ''); overload;
    constructor Create(const Stream: IStream; const ReferenceDC: HDC;
      const FrameRect: TGPRect;
      const FrameUnit: TGPMetafileFrameUnit = MetafileFrameUnitGdi;
      const EmfType: TGPEmfType = EmfTypeEmfPlusDual;
      const Description: String = ''); overload;

    class function GetMetafileHeader(const Wmf: HMetafile;
      const WmfPlaceableFileHeader: TWmfPlaceableFileHeader): TGPMetafileHeader; overload; static;
    class function GetMetafileHeader(const Emf: HEnhMetafile): TGPMetafileHeader; overload; static;
    class function GetMetafileHeader(const Filename: String): TGPMetafileHeader; overload; static;
    class function GetMetafileHeader(const Stream: IStream): TGPMetafileHeader; overload; static;

    class function EmfToWmfBits(const Emf: HEnhMetafile;
      const MapMode: Integer = MM_ANISOTROPIC;
      const Flags: TGPEmfToWmfBitsFlags = EmfToWmfBitsFlagsDefault): IGPBuffer;
  end;

{$ENDREGION 'GdiplusMetafile.h'}

{$REGION 'GdiplusImageAttributes.h'}

(*****************************************************************************
 * GdiplusImageAttributes.h
 * GDI+ Image Attributes used with Graphics.DrawImage
 *****************************************************************************)

  IGPImageAttributes = interface(IGdiPlusBase)
  ['{840C6292-E52C-4A2D-8444-CCE2A91DB701}']
    { Methods }
    function Clone: IGPImageAttributes;
    procedure SetToIdentity(const AdjustType: TGPColorAdjustType = ColorAdjustTypeDefault);
    procedure Reset(const AdjustType: TGPColorAdjustType = ColorAdjustTypeDefault);
    procedure SetColorMatrix(const ColorMatrix: TGPColorMatrix;
      const Mode: TGPColorMatrixFlags = ColorMatrixFlagsDefault;
      const AdjustType: TGPColorAdjustType = ColorAdjustTypeDefault);
    procedure ClearColorMatrix(const AdjustType: TGPColorAdjustType = ColorAdjustTypeDefault);
    procedure SetColorMatrices(const ColorMatrix, GrayMatrix: TGPColorMatrix;
      const Mode: TGPColorMatrixFlags = ColorMatrixFlagsDefault;
      const AdjustType: TGPColorAdjustType = ColorAdjustTypeDefault);
    procedure ClearColorMatrices(const AdjustType: TGPColorAdjustType = ColorAdjustTypeDefault);
    procedure SetThreshold(const Threshold: Single;
      const AdjustType: TGPColorAdjustType = ColorAdjustTypeDefault);
    procedure ClearThreshold(const AdjustType: TGPColorAdjustType = ColorAdjustTypeDefault);
    procedure SetGamma(const Gamma: Single;
      const AdjustType: TGPColorAdjustType = ColorAdjustTypeDefault);
    procedure ClearGamma(const AdjustType: TGPColorAdjustType = ColorAdjustTypeDefault);
    procedure SetNoOp(const AdjustType: TGPColorAdjustType = ColorAdjustTypeDefault);
    procedure ClearNoOp(const AdjustType: TGPColorAdjustType = ColorAdjustTypeDefault);
    procedure SetColorKey(const ColorLow, ColorHigh: TGPColor;
      const AdjustType: TGPColorAdjustType = ColorAdjustTypeDefault);
    procedure ClearColorKey(const AdjustType: TGPColorAdjustType = ColorAdjustTypeDefault);
    procedure SetOutputChannel(const ChannelFlags: TGPColorChannelFlags;
      const AdjustType: TGPColorAdjustType = ColorAdjustTypeDefault);
    procedure ClearOutputChannel(const AdjustType: TGPColorAdjustType = ColorAdjustTypeDefault);
    procedure SetOutputChannelColorProfile(const ColorProfileFilename: String;
      const AdjustType: TGPColorAdjustType = ColorAdjustTypeDefault);
    procedure ClearOutputChannelColorProfile(
      const AdjustType: TGPColorAdjustType = ColorAdjustTypeDefault);
    procedure SetRemapTable(const Map: array of TGPColorMap;
      const AdjustType: TGPColorAdjustType = ColorAdjustTypeDefault);
    procedure ClearRemapTable(const AdjustType: TGPColorAdjustType = ColorAdjustTypeDefault);
    procedure SetBrushRemapTable(const Map: array of TGPColorMap);
    procedure ClearBrushRemapTable;
    procedure SetWrapMode(const Wrap: TGPWrapMode;
      const Color: TGPColor; const Clamp: Boolean = False); overload;
    procedure SetWrapMode(const Wrap: TGPWrapMode); overload;
    procedure GetAdjustedPalette(const ColorPalette: IGPColorPalette;
      const ColorAdjustType: TGPColorAdjustType);
  end;

  TGPImageAttributes = class(TGdiplusBase, IGPImageAttributes)
  private
    { IGPImageAttributes }
    function Clone: IGPImageAttributes;
    procedure SetToIdentity(const AdjustType: TGPColorAdjustType = ColorAdjustTypeDefault);
    procedure Reset(const AdjustType: TGPColorAdjustType = ColorAdjustTypeDefault);
    procedure SetColorMatrix(const ColorMatrix: TGPColorMatrix;
      const Mode: TGPColorMatrixFlags = ColorMatrixFlagsDefault;
      const AdjustType: TGPColorAdjustType = ColorAdjustTypeDefault);
    procedure ClearColorMatrix(const AdjustType: TGPColorAdjustType = ColorAdjustTypeDefault);
    procedure SetColorMatrices(const ColorMatrix, GrayMatrix: TGPColorMatrix;
      const Mode: TGPColorMatrixFlags = ColorMatrixFlagsDefault;
      const AdjustType: TGPColorAdjustType = ColorAdjustTypeDefault);
    procedure ClearColorMatrices(const AdjustType: TGPColorAdjustType = ColorAdjustTypeDefault);
    procedure SetThreshold(const Threshold: Single;
      const AdjustType: TGPColorAdjustType = ColorAdjustTypeDefault);
    procedure ClearThreshold(const AdjustType: TGPColorAdjustType = ColorAdjustTypeDefault);
    procedure SetGamma(const Gamma: Single;
      const AdjustType: TGPColorAdjustType = ColorAdjustTypeDefault);
    procedure ClearGamma(const AdjustType: TGPColorAdjustType = ColorAdjustTypeDefault);
    procedure SetNoOp(const AdjustType: TGPColorAdjustType = ColorAdjustTypeDefault);
    procedure ClearNoOp(const AdjustType: TGPColorAdjustType = ColorAdjustTypeDefault);
    procedure SetColorKey(const ColorLow, ColorHigh: TGPColor;
      const AdjustType: TGPColorAdjustType = ColorAdjustTypeDefault);
    procedure ClearColorKey(const AdjustType: TGPColorAdjustType = ColorAdjustTypeDefault);
    procedure SetOutputChannel(const ChannelFlags: TGPColorChannelFlags;
      const AdjustType: TGPColorAdjustType = ColorAdjustTypeDefault);
    procedure ClearOutputChannel(const AdjustType: TGPColorAdjustType = ColorAdjustTypeDefault);
    procedure SetOutputChannelColorProfile(const ColorProfileFilename: String;
      const AdjustType: TGPColorAdjustType = ColorAdjustTypeDefault);
    procedure ClearOutputChannelColorProfile(
      const AdjustType: TGPColorAdjustType = ColorAdjustTypeDefault);
    procedure SetRemapTable(const Map: array of TGPColorMap;
      const AdjustType: TGPColorAdjustType = ColorAdjustTypeDefault);
    procedure ClearRemapTable(const AdjustType: TGPColorAdjustType = ColorAdjustTypeDefault);
    procedure SetBrushRemapTable(const Map: array of TGPColorMap);
    procedure ClearBrushRemapTable;
    procedure SetWrapMode(const Wrap: TGPWrapMode;
      const Color: TGPColor; const Clamp: Boolean = False); overload;
    procedure SetWrapMode(const Wrap: TGPWrapMode); overload;
    procedure GetAdjustedPalette(const ColorPalette: IGPColorPalette;
      const ColorAdjustType: TGPColorAdjustType);
  private
    constructor Create(const NativeAttributes: GpImageAttributes); overload;
  public
    constructor Create; overload;
    destructor Destroy; override;
  end;

{$ENDREGION 'GdiplusImageAttributes.h'}

{$REGION 'GdiplusMatrix.h'}

(*****************************************************************************
 * GdiplusMatrix.h
 * GDI+ Matrix class
 *****************************************************************************)

  TGPMatrixElements = record
    case Integer of
      0: (M: array [0..5] of Single);
      1: (M11: Single;
          M12: Single;
          M21: Single;
          M22: Single;
          DX : Single;
          DY : Single);
  end;

  TGPPlgPointsF = array [0..2] of TGPPointF;
  TGPPlgPoints = array [0..2] of TGPPoint;

  IGPMatrix = interface(IGdiPlusBase)
  ['{2B5AA3D4-F4AA-436D-AB48-18321613FF99}']
    { Property access methods }
    function GetElements: TGPMatrixElements;
    procedure SetElements(const Value: TGPMatrixElements); overload;
    function GetOffsetX: Single;
    function GetOffsetY: Single;
    function GetIsInvertible: Boolean;
    function GetIsIdentity: Boolean;

    { Methods }
    function Clone: IGPMatrix;
    procedure Reset;
    procedure SetElements(const M11, M12, M21, M22, DX, DY: Single); overload;
    procedure Multiply(const Matrix: IGPMatrix;
      const Order: TGPMatrixOrder = MatrixOrderPrepend);
    procedure Translate(const OffsetX, OffsetY: Single;
      const Order: TGPMatrixOrder = MatrixOrderPrepend);
    procedure Scale(const ScaleX, ScaleY: Single;
      const Order: TGPMatrixOrder = MatrixOrderPrepend);
    procedure Rotate(const Angle: Single;
      const Order: TGPMatrixOrder = MatrixOrderPrepend);
    procedure RotateAt(const Angle: Single; const Center: TGPPointF;
      const Order: TGPMatrixOrder = MatrixOrderPrepend);
    procedure Shear(const ShearX, ShearY: Single;
      const Order: TGPMatrixOrder = MatrixOrderPrepend);
    procedure Invert;
    procedure TransformPoint(var Point: TGPPointF); overload;
    procedure TransformPoint(var Point: TGPPoint); overload;
    procedure TransformPoints(const Points: array of TGPPointF); overload;
    procedure TransformPoints(const Points: array of TGPPoint); overload;
    procedure TransformVector(var Point: TGPPointF); overload;
    procedure TransformVector(var Point: TGPPoint); overload;
    procedure TransformVectors(const Points: array of TGPPointF); overload;
    procedure TransformVectors(const Points: array of TGPPoint); overload;
    function Equals(const Matrix: IGPMatrix): Boolean;

    { Properties }
    property Elements: TGPMatrixElements read GetElements write SetElements;
    property OffsetX: Single read GetOffsetX;
    property OffsetY: Single read GetOffsetY;
    property IsInvertible: Boolean read GetIsInvertible;
    property IsIdentity: Boolean read GetIsIdentity;
  end;

  TGPMatrix = class(TGdiplusBase, IGPMatrix)
  private
    { IGPMatrix }
    function GetElements: TGPMatrixElements;
    procedure SetElements(const Value: TGPMatrixElements); overload;
    function GetOffsetX: Single;
    function GetOffsetY: Single;
    function GetIsInvertible: Boolean;
    function GetIsIdentity: Boolean;

    function Clone: IGPMatrix;
    procedure Reset;
    procedure SetElements(const M11, M12, M21, M22, DX, DY: Single); overload;
    procedure Multiply(const Matrix: IGPMatrix;
      const Order: TGPMatrixOrder = MatrixOrderPrepend);
    procedure Translate(const OffsetX, OffsetY: Single;
      const Order: TGPMatrixOrder = MatrixOrderPrepend);
    procedure Scale(const ScaleX, ScaleY: Single;
      const Order: TGPMatrixOrder = MatrixOrderPrepend);
    procedure Rotate(const Angle: Single;
      const Order: TGPMatrixOrder = MatrixOrderPrepend);
    procedure RotateAt(const Angle: Single; const Center: TGPPointF;
      const Order: TGPMatrixOrder = MatrixOrderPrepend);
    procedure Shear(const ShearX, ShearY: Single;
      const Order: TGPMatrixOrder = MatrixOrderPrepend);
    procedure Invert;
    procedure TransformPoint(var Point: TGPPointF); overload;
    procedure TransformPoint(var Point: TGPPoint); overload;
    procedure TransformPoints(const Points: array of TGPPointF); overload;
    procedure TransformPoints(const Points: array of TGPPoint); overload;
    procedure TransformVector(var Point: TGPPointF); overload;
    procedure TransformVector(var Point: TGPPoint); overload;
    procedure TransformVectors(const Points: array of TGPPointF); overload;
    procedure TransformVectors(const Points: array of TGPPoint); overload;
    function Equals(const Matrix: IGPMatrix): Boolean; reintroduce;
  private
    constructor Create(const NativeMatrix: GpMatrix); overload;
  public
    constructor Create; overload;
    constructor Create(const M11, M12, M21, M22, DX, DY: Single); overload;
    constructor Create(const Rect: TGPRectF; const DstPlg: TGPPlgPointsF); overload;
    constructor Create(const Rect: TGPRect; const DstPlg: TGPPlgPoints); overload;
    destructor Destroy; override;
  end;
{$ENDREGION 'GdiplusMatrix.h'}

{$REGION 'GdiplusBrush.h'}

(*****************************************************************************
 * GdiplusBrush.h
 * GDI+ Brush class
 *****************************************************************************)
  IGPBrush = interface(IGdiPlusBase)
  ['{E0A8536C-D389-43E9-984F-B6DB6B1AFBF2}']
    { Property access methods }
    function GetType: TGPBrushType;

    { Methods }
    function Clone: IGPBrush;

    { Properties }
    property BrushType: TGPBrushType read GetType;
  end;

  TGPBrush = class abstract(TGdiplusBase, IGPBrush)
  private
    { IGPBrush }
    function GetType: TGPBrushType;
    function Clone: IGPBrush;
  private
    constructor Create; overload;
    constructor Create(const NativeBrush: GpBrush); overload;
  public
    destructor Destroy; override;
  end;

  IGPSolidBrush = interface(IGPBrush)
  ['{5DC6D20E-74C1-48B8-83A1-00D213827298}']
    { Property access methods }
    function GetColor: TGPColor;
    procedure SetColor(const Value: TGPColor);

    { Properties }
    property Color: TGPColor read GetColor write SetColor;
  end;

  TGPSolidBrush = class(TGPBrush, IGPSolidBrush)
  private
    { IGPSolidBrush }
    function GetColor: TGPColor;
    procedure SetColor(const Value: TGPColor);
  private
    constructor Create; overload;
  public
    constructor Create(const Color: TGPColor); overload;
  end;

  IGPTextureBrush = interface(IGPBrush)
  ['{37076023-1AE9-4F95-BB6C-D09C4E647AC2}']
    { Property access methods }
    function GetTransform: IGPMatrix;
    procedure SetTransform(const Value: IGPMatrix);
    function GetWrapMode: TGPWrapMode;
    procedure SetWrapMode(const Value: TGPWrapMode);
    function GetImage: IGPImage;

    { Methods }
    procedure ResetTransform;
    procedure MultiplyTransform(const Matrix: IGPMatrix;
      const Order: TGPMatrixOrder = MatrixOrderPrepend);
    procedure TranslateTransform(const DX, DY: Single;
      const Order: TGPMatrixOrder = MatrixOrderPrepend);
    procedure ScaleTransform(const SX, SY: Single;
      const Order: TGPMatrixOrder = MatrixOrderPrepend);
    procedure RotateTransform(const Angle: Single;
      const Order: TGPMatrixOrder = MatrixOrderPrepend);

    { Properties }
    property Transform: IGPMatrix read GetTransform write SetTransform;
    property WrapMode: TGPWrapMode read GetWrapMode write SetWrapMode;
    property Image: IGPImage read GetImage;
  end;

  TGPTextureBrush = class(TGPBrush, IGPTextureBrush)
  private
    { IGPTextureBrush }
    function GetTransform: IGPMatrix;
    procedure SetTransform(const Value: IGPMatrix);
    function GetWrapMode: TGPWrapMode;
    procedure SetWrapMode(const Value: TGPWrapMode);
    function GetImage: IGPImage;

    procedure ResetTransform;
    procedure MultiplyTransform(const Matrix: IGPMatrix;
      const Order: TGPMatrixOrder = MatrixOrderPrepend);
    procedure TranslateTransform(const DX, DY: Single;
      const Order: TGPMatrixOrder = MatrixOrderPrepend);
    procedure ScaleTransform(const SX, SY: Single;
      const Order: TGPMatrixOrder = MatrixOrderPrepend);
    procedure RotateTransform(const Angle: Single;
      const Order: TGPMatrixOrder = MatrixOrderPrepend);
  private
    constructor Create; overload;
  public
    constructor Create(const Image: IGPImage;
      const WrapMode: TGPWrapMode = WrapModeTile); overload;
    constructor Create(const Image: IGPImage;
      const WrapMode: TGPWrapMode; const DstRect: TGPRectF); overload;
    constructor Create(const Image: IGPImage;
      const WrapMode: TGPWrapMode; const DstRect: TGPRect); overload;
    constructor Create(const Image: IGPImage; const DstRect: TGPRectF;
      const ImageAttributes: IGPImageAttributes = nil); overload;
    constructor Create(const Image: IGPImage; const DstRect: TGPRect;
      const ImageAttributes: IGPImageAttributes = nil); overload;
    constructor Create(const Image: IGPImage;
      const WrapMode: TGPWrapMode; const DstX, DstY, DstWidth, DstHeight: Single); overload;
    constructor Create(const Image: IGPImage;
      const WrapMode: TGPWrapMode; const DstX, DstY, DstWidth, DstHeight: Integer); overload;
  end;

  TGPLinearColors = array [0..1] of TGPColor;

  IGPBlend = interface
  ['{497DDA96-3962-4037-B5D4-089D0C463378}']
    { Property access methods }
    function GetCount: Integer;
    function GetFactor(const Index: Integer): Single;
    procedure SetFactor(const Index: Integer; const Value: Single);
    function GetPosition(const Index: Integer): Single;
    procedure SetPosition(const Index: Integer; const Value: Single);
    function GetFactorPtr: PSingle;
    function GetPositionPtr: PSingle;

    { Properties }
    property Count: Integer read GetCount;
    property Factors[const Index: Integer]: Single read GetFactor write SetFactor;
    property Positions[const Index: Integer]: Single read GetPosition write SetPosition;
    property FactorPtr: PSingle read GetFactorPtr;
    property PositionPtr: PSingle read GetPositionPtr;
  end;

  TGPBlend = class(TInterfacedObject, IGPBlend)
  private
    FFactors: array of Single;
    FPositions: array of Single;
  private
    { IGPBlend }
    function GetCount: Integer;
    function GetFactor(const Index: Integer): Single;
    procedure SetFactor(const Index: Integer; const Value: Single);
    function GetPosition(const Index: Integer): Single;
    procedure SetPosition(const Index: Integer; const Value: Single);
    function GetFactorPtr: PSingle;
    function GetPositionPtr: PSingle;
  private
    constructor Create(const ACount: Integer); overload;
  public
    constructor Create(const AFactors, APositions: array of Single); overload;
  end;

  IGPColorBlend = interface
  ['{5F3C0BE0-BFED-4275-A21B-7FF97687F271}']
    { Property access methods }
    function GetCount: Integer;
    function GetColor(const Index: Integer): TGPColor;
    procedure SetColor(const Index: Integer; const Value: TGPColor);
    function GetPosition(const Index: Integer): Single;
    procedure SetPosition(const Index: Integer; const Value: Single);
    function GetColorPtr: PGPColor;
    function GetPositionPtr: PSingle;

    { Properties }
    property Count: Integer read GetCount;
    property Colors[const Index: Integer]: TGPColor read GetColor write SetColor;
    property Positions[const Index: Integer]: Single read GetPosition write SetPosition;
    property ColorPtr: PGPColor read GetColorPtr;
    property PositionPtr: PSingle read GetPositionPtr;
  end;

  TGPColorBlend = class(TInterfacedObject, IGPColorBlend)
  private
    FColors: array of TGPColor;
    FPositions: array of Single;
  private
    { IGPColorBlend }
    function GetCount: Integer;
    function GetColor(const Index: Integer): TGPColor;
    procedure SetColor(const Index: Integer; const Value: TGPColor);
    function GetPosition(const Index: Integer): Single;
    procedure SetPosition(const Index: Integer; const Value: Single);
    function GetColorPtr: PGPColor;
    function GetPositionPtr: PSingle;
  private
    constructor Create(const ACount: Integer); overload;
  public
    constructor Create(const AColors: array of TGPColor;
      const APositions: array of Single); overload;
  end;

  IGPLinearGradientBrush = interface(IGPBrush)
  ['{85ECE5BB-FE0F-4CD9-9094-6608696C8475}']
    { Property access methods }
    function GetLinearColors: TGPLinearColors;
    procedure SetLinearColors(const Value: TGPLinearColors);
    function GetRectangle: TGPRectF; overload;
    function GetGammaCorrection: Boolean;
    procedure SetGammaCorrection(const Value: Boolean);
    function GetBlend: IGPBlend;
    procedure SetBlend(const Value: IGPBlend);
    function GetInterpolationColors: IGPColorBlend;
    procedure SetInterpolationColors(const Value: IGPColorBlend);
    function GetTransform: IGPMatrix;
    procedure SetTransform(const Value: IGPMatrix);
    function GetWrapMode: TGPWrapMode;
    procedure SetWrapMode(const Value: TGPWrapMode);

    { Methods }
    procedure GetRectangle(out Rect: TGPRectF); overload;
    procedure GetRectangle(out Rect: TGPRect); overload;
    procedure SetBlendBellShape(const Focus: Single; const Scale: Single = 1);
    procedure SetBlendTriangularShape(const Focus: Single; const Scale: Single = 1);
    procedure ResetTransform;
    procedure MultiplyTransform(const Matrix: IGPMatrix;
      const Order: TGPMatrixOrder = MatrixOrderPrepend);
    procedure TranslateTransform(const DX, DY: Single;
      const Order: TGPMatrixOrder = MatrixOrderPrepend);
    procedure ScaleTransform(const SX, SY: Single;
      const Order: TGPMatrixOrder = MatrixOrderPrepend);
    procedure RotateTransform(const Angle: Single;
      const Order: TGPMatrixOrder = MatrixOrderPrepend);

    { Properties }
    property LinearColors: TGPLinearColors read GetLinearColors write SetLinearColors;
    property Rectangle: TGPRectF read GetRectangle;
    property GammaCorrection: Boolean read GetGammaCorrection write SetGammaCorrection;
    property Blend: IGPBlend read GetBlend write SetBlend;
    property InterpolationColors: IGPColorBlend read GetInterpolationColors write SetInterpolationColors;
    property Transform: IGPMatrix read GetTransform write SetTransform;
    property WrapMode: TGPWrapMode read GetWrapMode write SetWrapMode;
  end;

  TGPLinearGradientBrush = class(TGPBrush, IGPLinearGradientBrush)
  private
    { IGPLinearGradientBrush }
    function GetLinearColors: TGPLinearColors;
    procedure SetLinearColors(const Value: TGPLinearColors);
    function GetRectangle: TGPRectF; overload;
    function GetGammaCorrection: Boolean;
    procedure SetGammaCorrection(const Value: Boolean);
    function GetBlend: IGPBlend;
    procedure SetBlend(const Value: IGPBlend);
    function GetInterpolationColors: IGPColorBlend;
    procedure SetInterpolationColors(const Value: IGPColorBlend);
    function GetTransform: IGPMatrix;
    procedure SetTransform(const Value: IGPMatrix);
    function GetWrapMode: TGPWrapMode;
    procedure SetWrapMode(const Value: TGPWrapMode);

    procedure GetRectangle(out Rect: TGPRectF); overload;
    procedure GetRectangle(out Rect: TGPRect); overload;
    procedure SetBlendBellShape(const Focus: Single; const Scale: Single = 1);
    procedure SetBlendTriangularShape(const Focus: Single; const Scale: Single = 1);
    procedure ResetTransform;
    procedure MultiplyTransform(const Matrix: IGPMatrix;
      const Order: TGPMatrixOrder = MatrixOrderPrepend);
    procedure TranslateTransform(const DX, DY: Single;
      const Order: TGPMatrixOrder = MatrixOrderPrepend);
    procedure ScaleTransform(const SX, SY: Single;
      const Order: TGPMatrixOrder = MatrixOrderPrepend);
    procedure RotateTransform(const Angle: Single;
      const Order: TGPMatrixOrder = MatrixOrderPrepend);
  private
    constructor Create; overload;
  public
    constructor Create(const Point1, Point2: TGPPointF;
      const Color1, Color2: TGPColor); overload;
    constructor Create(const Point1, Point2: TGPPoint;
      const Color1, Color2: TGPColor); overload;
    constructor Create(const Rect: TGPRectF; const Color1, Color2: TGPColor;
      const Mode: TGPLinearGradientMode); overload;
    constructor Create(const Rect: TGPRect; const Color1, Color2: TGPColor;
      const Mode: TGPLinearGradientMode); overload;
    constructor Create(const Rect: TGPRectF; const Color1, Color2: TGPColor;
      const Angle: Single; const IsAngleScalable: Boolean = False); overload;
    constructor Create(const Rect: TGPRect; const Color1, Color2: TGPColor;
      const Angle: Single; const IsAngleScalable: Boolean = False); overload;
  end;

  IGPHatchBrush = interface(IGPBrush)
  ['{5EED3025-99F4-435D-A854-FDF2B0A08FBD}']
    { Property access methods }
    function GetHatchStyle: TGPHatchStyle;
    function GetForegroundColor: TGPColor;
    function GetBackgroundColor: TGPColor;

    { Properties }
    property HatchStyle: TGPHatchStyle read GetHatchStyle;
    property ForegroundColor: TGPColor read GetForegroundColor;
    property BackgroundColor: TGPColor read GetBackgroundColor;
  end;

  TGPHatchBrush = class(TGPBrush, IGPHatchBrush)
  private
    { IGPHatchBrush }
    function GetHatchStyle: TGPHatchStyle;
    function GetForegroundColor: TGPColor;
    function GetBackgroundColor: TGPColor;
  private
    constructor Create; overload;
  public
    constructor Create(const HatchStyle: TGPHatchStyle; const ForeColor,
      BackColor: TGPColor); overload;
    constructor Create(const HatchStyle: TGPHatchStyle; const ForeColor: TGPColor); overload;
  end;

{$ENDREGION 'GdiplusBrush.h'}

{$REGION 'GdiplusPen.h'}

(*****************************************************************************
 * GdiplusPen.h
 * GDI+ Pen class
 *****************************************************************************)

  IGPDashPattern = IGPArray<Single>;
  IGPCompoundArray = IGPArray<Single>;

  IGPPen = interface(IGdiPlusBase)
  ['{5F88EBBC-6104-44AC-BDCE-691DBEF21607}']
    { Property access methods }
    function GetWidth: Single;
    procedure SetWidth(const Value: Single);
    function GetStartCap: TGPLineCap;
    procedure SetStartCap(const Value: TGPLineCap);
    function GetEndCap: TGPLineCap;
    procedure SetEndCap(const Value: TGPLineCap);
    function GetDashCap: TGPDashCap;
    procedure SetDashCap(const Value: TGPDashCap);
    function GetLineJoin: TGPLineJoin;
    procedure SetLineJoin(const Value: TGPLineJoin);
    function GetCustomStartCap: IGPCustomLineCap;
    procedure SetCustomStartCap(const Value: IGPCustomLineCap);
    function GetCustomEndCap: IGPCustomLineCap;
    procedure SetCustomEndCap(const Value: IGPCustomLineCap);
    function GetMiterLimit: Single;
    procedure SetMiterLimit(const Value: Single);
    function GetAlignment: TGPPenAlignment;
    procedure SetAlignment(const Value: TGPPenAlignment);
    function GetTransform: IGPMatrix;
    procedure SetTransform(const Value: IGPMatrix);
    function GetPenType: TGPPenType;
    function GetColor: TGPColor;
    procedure SetColor(const Value: TGPColor);
    function GetBrush: IGPBrush;
    procedure SetBrush(const Value: IGPBrush);
    function GetDashStyle: TGPDashStyle;
    procedure SetDashStyle(const Value: TGPDashStyle);
    function GetDashOffset: Single;
    procedure SetDashOffset(const Value: Single);
    function GetDashPattern: IGPDashPattern;
    procedure SetDashPatternInternal(const Value: IGPDashPattern);
    function GetCompoundArray: IGPCompoundArray;
    procedure SetCompoundArray(const Value: IGPCompoundArray);

    { Methods }
    function Clone: IGPPen;
    procedure SetLineCap(const StartCap, EndCap: TGPLineCap;
      const DashCap: TGPDashCap);
    procedure ResetTransform;
    procedure MultiplyTransform(const Matrix: IGPMatrix;
      const Order: TGPMatrixOrder = MatrixOrderPrepend);
    procedure TranslateTransform(const DX, DY: Single;
      const Order: TGPMatrixOrder = MatrixOrderPrepend);
    procedure ScaleTransform(const SX, SY: Single;
      const Order: TGPMatrixOrder = MatrixOrderPrepend);
    procedure RotateTransform(const Angle: Single;
      const Order: TGPMatrixOrder = MatrixOrderPrepend);
    procedure SetDashPattern(const Pattern: array of Single);

    { Properties }
    property Width: Single read GetWidth write SetWidth;
    property StartCap: TGPLineCap read GetStartCap write SetStartCap;
    property EndCap: TGPLineCap read GetEndCap write SetEndCap;
    property DashCap: TGPDashCap read GetDashCap write SetDashCap;
    property LineJoin: TGPLineJoin read GetLineJoin write SetLineJoin;
    property CustomStartCap: IGPCustomLineCap read GetCustomStartCap write SetCustomStartCap;
    property CustomEndCap: IGPCustomLineCap read GetCustomEndCap write SetCustomEndCap;
    property MiterLimit: Single read GetMiterLimit write SetMiterLimit;
    property Alignment: TGPPenAlignment read GetAlignment write SetAlignment;
    property Transform: IGPMatrix read GetTransform write SetTransform;
    property PenType: TGPPenType read GetPenType;
    property Color: TGPColor read GetColor write SetColor;
    property Brush: IGPBrush read GetBrush write SetBrush;
    property DashStyle: TGPDashStyle read GetDashStyle write SetDashStyle;
    property DashOffset: Single read GetDashOffset write SetDashOffset;
    property DashPattern: IGPDashPattern read GetDashPattern write SetDashPatternInternal;
    property CompoundArray: IGPCompoundArray read GetCompoundArray write SetCompoundArray;
  end;

  TGPPen = class(TGdiplusBase, IGPPen)
  private
    { IGPPen }
    function GetWidth: Single;
    procedure SetWidth(const Value: Single);
    function GetStartCap: TGPLineCap;
    procedure SetStartCap(const Value: TGPLineCap);
    function GetEndCap: TGPLineCap;
    procedure SetEndCap(const Value: TGPLineCap);
    function GetDashCap: TGPDashCap;
    procedure SetDashCap(const Value: TGPDashCap);
    function GetLineJoin: TGPLineJoin;
    procedure SetLineJoin(const Value: TGPLineJoin);
    function GetCustomStartCap: IGPCustomLineCap;
    procedure SetCustomStartCap(const Value: IGPCustomLineCap);
    function GetCustomEndCap: IGPCustomLineCap;
    procedure SetCustomEndCap(const Value: IGPCustomLineCap);
    function GetMiterLimit: Single;
    procedure SetMiterLimit(const Value: Single);
    function GetAlignment: TGPPenAlignment;
    procedure SetAlignment(const Value: TGPPenAlignment);
    function GetTransform: IGPMatrix;
    procedure SetTransform(const Value: IGPMatrix);
    function GetPenType: TGPPenType;
    function GetColor: TGPColor;
    procedure SetColor(const Value: TGPColor);
    function GetBrush: IGPBrush;
    procedure SetBrush(const Value: IGPBrush);
    function GetDashStyle: TGPDashStyle;
    procedure SetDashStyle(const Value: TGPDashStyle);
    function GetDashOffset: Single;
    procedure SetDashOffset(const Value: Single);
    function GetDashPattern: IGPDashPattern;
    procedure SetDashPatternInternal(const Value: IGPDashPattern);
    function GetCompoundArray: IGPCompoundArray;
    procedure SetCompoundArray(const Value: IGPCompoundArray);

    function Clone: IGPPen;
    procedure SetLineCap(const StartCap, EndCap: TGPLineCap;
      const DashCap: TGPDashCap);
    procedure ResetTransform;
    procedure MultiplyTransform(const Matrix: IGPMatrix;
      const Order: TGPMatrixOrder = MatrixOrderPrepend);
    procedure TranslateTransform(const DX, DY: Single;
      const Order: TGPMatrixOrder = MatrixOrderPrepend);
    procedure ScaleTransform(const SX, SY: Single;
      const Order: TGPMatrixOrder = MatrixOrderPrepend);
    procedure RotateTransform(const Angle: Single;
      const Order: TGPMatrixOrder = MatrixOrderPrepend);
    procedure SetDashPattern(const Pattern: array of Single);
  private
    constructor Create(const NativePen: GpPen); overload;
  public
    constructor Create(const Color: TGPColor; const Width: Single = 1); overload;
    constructor Create(const Brush: IGPBrush; const Width: Single = 1); overload;
    destructor Destroy; override;
  end;

{$ENDREGION 'GdiplusPen.h'}

{$REGION 'GdiplusStringFormat.h'}

(*****************************************************************************
 * GdiplusStringFormat.h
 * GDI+ StringFormat class
 *****************************************************************************)

  IGPTabStops = IGPArray<Single>;
  IGPCharacterRanges = IGPArray<TGPCharacterRange>;

  IGPStringFormat = interface(IGdiPlusBase)
  ['{15875A7E-A799-4460-AC3B-4C5A966319E8}']
    { Property access methods }
    function GetFormatFlags: TGPStringFormatFlags;
    procedure SetFormatFlags(const Value: TGPStringFormatFlags);
    function GetAlignment: TGPStringAlignment;
    procedure SetAlignment(const Value: TGPStringAlignment);
    function GetLineAlignment: TGPStringAlignment;
    procedure SetLineAlignment(const Value: TGPStringAlignment);
    function GetHotkeyPrefix: TGPHotkeyPrefix;
    procedure SetHotkeyPrefix(const Value: TGPHotkeyPrefix);
    function GetDigitSubstitutionLanguage: LangID;
    function GetDigitSubstitutionMethod: TGPStringDigitSubstitute;
    function GetTrimming: TGPStringTrimming;
    procedure SetTrimming(const Value: TGPStringTrimming);
    function GetMeasurableCharacterRangeCount: Integer;

    { Methods }
    function Clone: IGPStringFormat;
    function GetTabStops(out FirstTabOffset: Single): IGPTabStops;
    procedure SetTabStops(const FirstTabOffset: Single;
      const TabStops: array of Single);
    procedure SetDigitSubstitution(const Language: LangID;
      const Substitute: TGPStringDigitSubstitute);
    procedure SetMeasurableCharacterRanges(const Ranges: IGPCharacterRanges);

    { Properties }
    property FormatFlags: TGPStringFormatFlags read GetFormatFlags write SetFormatFlags;
    property Alignment: TGPStringAlignment read GetAlignment write SetAlignment;
    property LineAlignment: TGPStringAlignment read GetLineAlignment write SetLineAlignment;
    property HotkeyPrefix: TGPHotkeyPrefix read GetHotkeyPrefix write SetHotkeyPrefix;
    property DigitSubstitutionLanguage: LangID read GetDigitSubstitutionLanguage;
    property DigitSubstitutionMethod: TGPStringDigitSubstitute read GetDigitSubstitutionMethod;
    property Trimming: TGPStringTrimming read GetTrimming write SetTrimming;
    property MeasurableCharacterRangeCount: Integer read GetMeasurableCharacterRangeCount;
  end;

  TGPStringFormat = class(TGdiplusBase, IGPStringFormat)
  private
    class var FGenericDefault: IGPStringFormat;
    class var FGenericTypographic: IGPStringFormat;
  private
    { IGPStringFormat }
    function GetFormatFlags: TGPStringFormatFlags;
    procedure SetFormatFlags(const Value: TGPStringFormatFlags);
    function GetAlignment: TGPStringAlignment;
    procedure SetAlignment(const Value: TGPStringAlignment);
    function GetLineAlignment: TGPStringAlignment;
    procedure SetLineAlignment(const Value: TGPStringAlignment);
    function GetHotkeyPrefix: TGPHotkeyPrefix;
    procedure SetHotkeyPrefix(const Value: TGPHotkeyPrefix);
    function GetDigitSubstitutionLanguage: LangID;
    function GetDigitSubstitutionMethod: TGPStringDigitSubstitute;
    function GetTrimming: TGPStringTrimming;
    procedure SetTrimming(const Value: TGPStringTrimming);
    function GetMeasurableCharacterRangeCount: Integer;

    function Clone: IGPStringFormat;
    function GetTabStops(out FirstTabOffset: Single): IGPTabStops;
    procedure SetTabStops(const FirstTabOffset: Single;
      const TabStops: array of Single);
    procedure SetDigitSubstitution(const Language: LangID;
      const Substitute: TGPStringDigitSubstitute);
    procedure SetMeasurableCharacterRanges(const Ranges: IGPCharacterRanges);
  private
    constructor Create(const NativeFormat: GpStringFormat); overload;
  public
    constructor Create(const FormatFlags: TGPStringFormatFlags = [];
      const Language: LangID = LANG_NEUTRAL); overload;
    constructor Create(const Format: IGPStringFormat); overload;
    destructor Destroy; override;

    class function GenericDefault: IGPStringFormat; static;
    class function GenericTypographic: IGPStringFormat; static;
  end;
{$ENDREGION 'GdiplusStringFormat.h'}

{$REGION 'GdiplusPath.h'}

(*****************************************************************************
 * GdiplusPath.h
 * GDI+ Graphics Path class
 *****************************************************************************)

  IGPPathTypes = IGPArray<Byte>;
  IGPPathPoints = IGPArray<TGPPointF>;
  IGPPathPointsI = IGPArray<TGPPoint>;

  IGPPathData = interface
  ['{2FC67BFC-7013-4279-839A-1FCD71BD0909}']
    { Property access methods }
    function GetCount: Integer;
    procedure SetCount(const Value: Integer);
    function GetPoint(const Index: Integer): TGPPointF;
    function GetType(const Index: Integer): Byte;
    function GetPointPtr: PGPPointF;
    function GetTypePtr: PByte;
    function GetNativePathData: TGPNativePathData;

    { Properties }
    property Count: Integer read GetCount write SetCount;
    property Points[const Index: Integer]: TGPPointF read GetPoint;
    property Types[const Index: Integer]: Byte read GetType;
    property PointPtr: PGPPointF read GetPointPtr;
    property TypePtr: PByte read GetTypePtr;
    property NativePathData: TGPNativePathData read GetNativePathData;
  end;

  TGPPathData = class(TInterfacedObject, IGPPathData)
  private
    FPoints: array of TGPPointF;
    FTypes: array of Byte;
  private
    { IGPPathData }
    function GetCount: Integer;
    procedure SetCount(const Value: Integer);
    function GetPoint(const Index: Integer): TGPPointF;
    function GetType(const Index: Integer): Byte;
    function GetPointPtr: PGPPointF;
    function GetTypePtr: PByte;
    function GetNativePathData: TGPNativePathData;
  private
    constructor Create(const ACount: Integer);
  end;

  IGPGraphicsPath = interface(IGdiPlusBase)
  ['{9F117627-F765-41C0-96BD-44AA9165BF07}']
    { Property access methods }
    function GetFillMode: TGPFillMode;
    procedure SetFillMode(const Value: TGPFillMode);
    function GetPathData: IGPPathData;
    function GetPointCount: Integer;
    function GetPathTypes: IGPPathTypes;
    function GetPathPoints: IGPPathPoints;
    function GetPathPointsI: IGPPathPointsI;

    { Methods }
    function Clone: IGPGraphicsPath;
    procedure Reset;
    procedure StartFigure;
    procedure CloseFigure;
    procedure CloseAllFigures;
    procedure SetMarker;
    procedure ClearMarkers;
    procedure Reverse;
    function GetLastPoint: TGPPointF;

    procedure AddLine(const Pt1, Pt2: TGPPointF); overload;
    procedure AddLine(const X1, Y1, X2, Y2: Single); overload;
    procedure AddLine(const Pt1, Pt2: TGPPoint); overload;
    procedure AddLine(const X1, Y1, X2, Y2: Integer); overload;

    procedure AddLines(const Points: array of TGPPointF); overload;
    procedure AddLines(const Points: array of TGPPoint); overload;

    procedure AddArc(const Rect: TGPRectF; const StartAngle, SweepAngle: Single); overload;
    procedure AddArc(const X, Y, Width, Height, StartAngle, SweepAngle: Single); overload;
    procedure AddArc(const Rect: TGPRect; const StartAngle, SweepAngle: Single); overload;
    procedure AddArc(const X, Y, Width, Height: Integer;
      const StartAngle, SweepAngle: Single); overload;

    procedure AddBezier(const Pt1, Pt2, Pt3, Pt4: TGPPointF); overload;
    procedure AddBezier(const X1, Y1, X2, Y2, X3, Y3, X4, Y4: Single); overload;
    procedure AddBezier(const Pt1, Pt2, Pt3, Pt4: TGPPoint); overload;
    procedure AddBezier(const X1, Y1, X2, Y2, X3, Y3, X4, Y4: Integer); overload;

    procedure AddBeziers(const Points: array of TGPPointF); overload;
    procedure AddBeziers(const Points: array of TGPPoint); overload;

    procedure AddCurve(const Points: array of TGPPointF); overload;
    procedure AddCurve(const Points: array of TGPPointF;
      const Tension: Single); overload;
    procedure AddCurve(const Points: array of TGPPointF;
      const Offset, NumberOfSegments: Integer; const Tension: Single); overload;
    procedure AddCurve(const Points: array of TGPPoint); overload;
    procedure AddCurve(const Points: array of TGPPoint;
      const Tension: Single); overload;
    procedure AddCurve(const Points: array of TGPPoint;
      const Offset, NumberOfSegments: Integer; const Tension: Single); overload;

    procedure AddClosedCurve(const Points: array of TGPPointF); overload;
    procedure AddClosedCurve(const Points: array of TGPPointF;
      const Tension: Single); overload;
    procedure AddClosedCurve(const Points: array of TGPPoint); overload;
    procedure AddClosedCurve(const Points: array of TGPPoint;
      const Tension: Single); overload;

    procedure AddRectangle(const Rect: TGPRectF); overload;
    procedure AddRectangle(const Rect: TGPRect); overload;

    procedure AddRectangles(const Rects: array of TGPRectF); overload;
    procedure AddRectangles(const Rects: array of TGPRect); overload;

    procedure AddEllipse(const Rect: TGPRectF); overload;
    procedure AddEllipse(const X, Y, Width, Height: Single); overload;
    procedure AddEllipse(const Rect: TGPRect); overload;
    procedure AddEllipse(const X, Y, Width, Height: Integer); overload;

    procedure AddPie(const Rect: TGPRectF; const StartAngle, SweepAngle: Single); overload;
    procedure AddPie(const X, Y, Width, Height, StartAngle, SweepAngle: Single); overload;
    procedure AddPie(const Rect: TGPRect; const StartAngle, SweepAngle: Single); overload;
    procedure AddPie(const X, Y, Width, Height: Integer;
      const StartAngle, SweepAngle: Single); overload;

    procedure AddPolygon(const Points: array of TGPPointF); overload;
    procedure AddPolygon(const Points: array of TGPPoint); overload;

    procedure AddPath(const AddingPath: IGPGraphicsPath; const Connect: Boolean);

    procedure AddString(const Str: String; const Family: IGPFontFamily;
      const Style: TGPFontStyle; const EmSize: Single; const Origin: TGPPointF;
      const Format: IGPStringFormat); overload;
    procedure AddString(const Str: String; const Family: IGPFontFamily;
      const Style: TGPFontStyle; const EmSize: Single; const LayoutRect: TGPRectF;
      const Format: IGPStringFormat); overload;
    procedure AddString(const Str: String; const Family: IGPFontFamily;
      const Style: TGPFontStyle; const EmSize: Single; const Origin: TGPPoint;
      const Format: IGPStringFormat); overload;
    procedure AddString(const Str: String; const Family: IGPFontFamily;
      const Style: TGPFontStyle; const EmSize: Single; const LayoutRect: TGPRect;
      const Format: IGPStringFormat); overload;

    procedure Transform(const Matrix: IGPMatrix);
    procedure GetBounds(out Bounds: TGPRectF; const Matrix: IGPMatrix = nil;
      const Pen: IGPPen = nil); overload;
    procedure GetBounds(out Bounds: TGPRect; const Matrix: IGPMatrix = nil;
      const Pen: IGPPen = nil); overload;
    procedure Flatten(const Matrix: IGPMatrix = nil;
      const Flatness: Single = FlatnessDefault);
    procedure Widen(const Pen: IGPPen; const Matrix: IGPMatrix = nil;
      const Flatness: Single = FlatnessDefault);
    procedure Outline(const Matrix: IGPMatrix = nil;
      const Flatness: Single = FlatnessDefault);
    procedure Warp(const DestPoints: array of TGPPointF; const SrcRect: TGPRectF;
      const Matrix: IGPMatrix = nil; const WarpMode: TGPWarpMode = WarpModePerspective;
      const Flatness: Single = FlatnessDefault);

    function IsVisible(const Point: TGPPointF; const G: IGPGraphics = nil): Boolean; overload;
    function IsVisible(const X, Y: Single; const G: IGPGraphics = nil): Boolean; overload;
    function IsVisible(const Point: TGPPoint; const G: IGPGraphics = nil): Boolean; overload;
    function IsVisible(const X, Y: Integer; const G: IGPGraphics = nil): Boolean; overload;

    function IsOutlineVisible(const Point: TGPPointF; const Pen: IGPPen;
      const G: IGPGraphics = nil): Boolean; overload;
    function IsOutlineVisible(const X, Y: Single; const Pen: IGPPen;
      const G: IGPGraphics = nil): Boolean; overload;
    function IsOutlineVisible(const Point: TGPPoint; const Pen: IGPPen;
      const G: IGPGraphics = nil): Boolean; overload;
    function IsOutlineVisible(const X, Y: Integer; const Pen: IGPPen;
      const G: IGPGraphics = nil): Boolean; overload;

    { Properties }
    property FillMode: TGPFillMode read GetFillMode write SetFillMode;
    property PathData: IGPPathData read GetPathData;
    property PointCount: Integer read GetPointCount;
    property PathTypes: IGPPathTypes read GetPathTypes;
    property PathPoints: IGPPathPoints read GetPathPoints;
    property PathPointsI: IGPPathPointsI read GetPathPointsI;
  end;

  TGPGraphicsPath = class(TGdiplusBase, IGPGraphicsPath)
  private
    { IGPGraphicsPath }
    function GetFillMode: TGPFillMode;
    procedure SetFillMode(const Value: TGPFillMode);
    function GetPathData: IGPPathData;
    function GetPointCount: Integer;
    function GetPathTypes: IGPPathTypes;
    function GetPathPoints: IGPPathPoints;
    function GetPathPointsI: IGPPathPointsI;

    function Clone: IGPGraphicsPath;
    procedure Reset;
    procedure StartFigure;
    procedure CloseFigure;
    procedure CloseAllFigures;
    procedure SetMarker;
    procedure ClearMarkers;
    procedure Reverse;
    function GetLastPoint: TGPPointF;
    procedure AddLine(const Pt1, Pt2: TGPPointF); overload;
    procedure AddLine(const X1, Y1, X2, Y2: Single); overload;
    procedure AddLine(const Pt1, Pt2: TGPPoint); overload;
    procedure AddLine(const X1, Y1, X2, Y2: Integer); overload;
    procedure AddLines(const Points: array of TGPPointF); overload;
    procedure AddLines(const Points: array of TGPPoint); overload;
    procedure AddArc(const Rect: TGPRectF; const StartAngle, SweepAngle: Single); overload;
    procedure AddArc(const X, Y, Width, Height, StartAngle, SweepAngle: Single); overload;
    procedure AddArc(const Rect: TGPRect; const StartAngle, SweepAngle: Single); overload;
    procedure AddArc(const X, Y, Width, Height: Integer;
      const StartAngle, SweepAngle: Single); overload;
    procedure AddBezier(const Pt1, Pt2, Pt3, Pt4: TGPPointF); overload;
    procedure AddBezier(const X1, Y1, X2, Y2, X3, Y3, X4, Y4: Single); overload;
    procedure AddBezier(const Pt1, Pt2, Pt3, Pt4: TGPPoint); overload;
    procedure AddBezier(const X1, Y1, X2, Y2, X3, Y3, X4, Y4: Integer); overload;
    procedure AddBeziers(const Points: array of TGPPointF); overload;
    procedure AddBeziers(const Points: array of TGPPoint); overload;
    procedure AddCurve(const Points: array of TGPPointF); overload;
    procedure AddCurve(const Points: array of TGPPointF;
      const Tension: Single); overload;
    procedure AddCurve(const Points: array of TGPPointF;
      const Offset, NumberOfSegments: Integer; const Tension: Single); overload;
    procedure AddCurve(const Points: array of TGPPoint); overload;
    procedure AddCurve(const Points: array of TGPPoint;
      const Tension: Single); overload;
    procedure AddCurve(const Points: array of TGPPoint;
      const Offset, NumberOfSegments: Integer; const Tension: Single); overload;
    procedure AddClosedCurve(const Points: array of TGPPointF); overload;
    procedure AddClosedCurve(const Points: array of TGPPointF;
      const Tension: Single); overload;
    procedure AddClosedCurve(const Points: array of TGPPoint); overload;
    procedure AddClosedCurve(const Points: array of TGPPoint;
      const Tension: Single); overload;
    procedure AddRectangle(const Rect: TGPRectF); overload;
    procedure AddRectangle(const Rect: TGPRect); overload;
    procedure AddRectangles(const Rects: array of TGPRectF); overload;
    procedure AddRectangles(const Rects: array of TGPRect); overload;
    procedure AddEllipse(const Rect: TGPRectF); overload;
    procedure AddEllipse(const X, Y, Width, Height: Single); overload;
    procedure AddEllipse(const Rect: TGPRect); overload;
    procedure AddEllipse(const X, Y, Width, Height: Integer); overload;
    procedure AddPie(const Rect: TGPRectF; const StartAngle, SweepAngle: Single); overload;
    procedure AddPie(const X, Y, Width, Height, StartAngle, SweepAngle: Single); overload;
    procedure AddPie(const Rect: TGPRect; const StartAngle, SweepAngle: Single); overload;
    procedure AddPie(const X, Y, Width, Height: Integer;
      const StartAngle, SweepAngle: Single); overload;
    procedure AddPolygon(const Points: array of TGPPointF); overload;
    procedure AddPolygon(const Points: array of TGPPoint); overload;
    procedure AddPath(const AddingPath: IGPGraphicsPath; const Connect: Boolean);
    procedure AddString(const Str: String; const Family: IGPFontFamily;
      const Style: TGPFontStyle; const EmSize: Single; const Origin: TGPPointF;
      const Format: IGPStringFormat); overload;
    procedure AddString(const Str: String; const Family: IGPFontFamily;
      const Style: TGPFontStyle; const EmSize: Single; const LayoutRect: TGPRectF;
      const Format: IGPStringFormat); overload;
    procedure AddString(const Str: String; const Family: IGPFontFamily;
      const Style: TGPFontStyle; const EmSize: Single; const Origin: TGPPoint;
      const Format: IGPStringFormat); overload;
    procedure AddString(const Str: String; const Family: IGPFontFamily;
      const Style: TGPFontStyle; const EmSize: Single; const LayoutRect: TGPRect;
      const Format: IGPStringFormat); overload;
    procedure Transform(const Matrix: IGPMatrix);
    procedure GetBounds(out Bounds: TGPRectF; const Matrix: IGPMatrix = nil;
      const Pen: IGPPen = nil); overload;
    procedure GetBounds(out Bounds: TGPRect; const Matrix: IGPMatrix = nil;
      const Pen: IGPPen = nil); overload;
    procedure Flatten(const Matrix: IGPMatrix = nil;
      const Flatness: Single = FlatnessDefault);
    procedure Widen(const Pen: IGPPen; const Matrix: IGPMatrix = nil;
      const Flatness: Single = FlatnessDefault);
    procedure Outline(const Matrix: IGPMatrix = nil;
      const Flatness: Single = FlatnessDefault);
    procedure Warp(const DestPoints: array of TGPPointF; const SrcRect: TGPRectF;
      const Matrix: IGPMatrix = nil; const WarpMode: TGPWarpMode = WarpModePerspective;
      const Flatness: Single = FlatnessDefault);
    function IsVisible(const Point: TGPPointF; const G: IGPGraphics = nil): Boolean; overload;
    function IsVisible(const X, Y: Single; const G: IGPGraphics = nil): Boolean; overload;
    function IsVisible(const Point: TGPPoint; const G: IGPGraphics = nil): Boolean; overload;
    function IsVisible(const X, Y: Integer; const G: IGPGraphics = nil): Boolean; overload;
    function IsOutlineVisible(const Point: TGPPointF; const Pen: IGPPen;
      const G: IGPGraphics = nil): Boolean; overload;
    function IsOutlineVisible(const X, Y: Single; const Pen: IGPPen;
      const G: IGPGraphics = nil): Boolean; overload;
    function IsOutlineVisible(const Point: TGPPoint; const Pen: IGPPen;
      const G: IGPGraphics = nil): Boolean; overload;
    function IsOutlineVisible(const X, Y: Integer; const Pen: IGPPen;
      const G: IGPGraphics = nil): Boolean; overload;
  private
    constructor Create(const NativePath: GpPath); overload;
  public
    constructor Create(const FillMode: TGPFillMode = FillModeAlternate); overload;
    constructor Create(const Points: array of TGPPointF; const Types: array of Byte;
      const FillMode: TGPFillMode = FillModeAlternate); overload;
    constructor Create(const Points: array of TGPPoint; const Types: array of Byte;
      const FillMode: TGPFillMode = FillModeAlternate); overload;
    destructor Destroy; override;
  end;

  IGPGraphicsPathIterator = interface(IGdiPlusBase)
  ['{4A37267A-F6EE-46C1-8D1D-08256ED3FCB8}']
    { Property access methods }
    function GetCount: Integer;
    function GetSubpathCount: Integer;

    { Methods }
    function NextSubPath(out StartIndex, EndIndex: Integer;
      out IsClosed: Boolean): Integer; overload;
    function NextSubPath(const Path: IGPGraphicsPath;
      out IsClosed: Boolean): Integer; overload;
    function NextPathType(out PathType: Byte; out StartIndex,
      EndIndex: Integer): Integer;
    function NextMarker(out StartIndex, EndIndex: Integer): Integer; overload;
    function NextMarker(const Path: IGPGraphicsPath): Integer; overload;
    function HasCurve: Boolean;
    procedure Rewind;
    function Enumerate: IGPPathData;
    function CopyData(const StartIndex, EndIndex: Integer): IGPPathData;

    { Properties }
    property Count: Integer read GetCount;
    property SubpathCount: Integer read GetSubpathCount;
  end;

  TGPGraphicsPathIterator = class(TGdiplusBase, IGPGraphicsPathIterator)
  private
    { IGPGraphicsPathIterator }
    function GetCount: Integer;
    function GetSubpathCount: Integer;

    function NextSubPath(out StartIndex, EndIndex: Integer;
      out IsClosed: Boolean): Integer; overload;
    function NextSubPath(const Path: IGPGraphicsPath;
      out IsClosed: Boolean): Integer; overload;
    function NextPathType(out PathType: Byte; out StartIndex,
      EndIndex: Integer): Integer;
    function NextMarker(out StartIndex, EndIndex: Integer): Integer; overload;
    function NextMarker(const Path: IGPGraphicsPath): Integer; overload;
    function HasCurve: Boolean;
    procedure Rewind;
    function Enumerate: IGPPathData;
    function CopyData(const StartIndex, EndIndex: Integer): IGPPathData;
  public
    constructor Create(const Path: IGPGraphicsPath);
    destructor Destroy; override;
  end;

  IGPColors = IGPArray<TGPColor>;

  IGPPathGradientBrush = interface(IGPBrush)
  ['{66013840-6B90-4179-B72A-031548138EBF}']
    { Property access methods }
    function GetCenterColor: TGPColor;
    procedure SetCenterColor(const Value: TGPColor);
    function GetPointCount: Integer;
    function GetSurroundColors: IGPColors;
    procedure SetSurroundColorsInternal(const Value: IGPColors);
    function GetGraphicsPath: IGPGraphicsPath;
    procedure SetGraphicsPath(const Value: IGPGraphicsPath);
    function GetCenterPoint: TGPPointF;
    procedure SetCenterPoint(const Value: TGPPointF);
    function GetCenterPointI: TGPPoint;
    procedure SetCenterPointI(const Value: TGPPoint);
    function GetRectangle: TGPRectF;
    function GetRectangleI: TGPRect;
    function GetGammaCorrection: Boolean;
    procedure SetGammaCorrection(const Value: Boolean);
    function GetBlend: IGPBlend;
    procedure SetBlend(const Value: IGPBlend);
    function GetInterpolationColors: IGPColorBlend;
    procedure SetInterpolationColors(const Value: IGPColorBlend);
    function GetTransform: IGPMatrix;
    procedure SetTransform(const Value: IGPMatrix);
    function GetWrapMode: TGPWrapMode;
    procedure SetWrapMode(const Value: TGPWrapMode);

    { Methods }
    procedure SetBlendBellShape(const Focus: Single; const Scale: Single = 1);
    procedure SetBlendTriangularShape(const Focus: Single; const Scale: Single = 1);
    procedure ResetTransform;
    procedure MultiplyTransform(const Matrix: IGPMatrix;
      const Order: TGPMatrixOrder = MatrixOrderPrepend);
    procedure TranslateTransform(const DX, DY: Single;
      const Order: TGPMatrixOrder = MatrixOrderPrepend);
    procedure ScaleTransform(const SX, SY: Single;
      const Order: TGPMatrixOrder = MatrixOrderPrepend);
    procedure RotateTransform(const Angle: Single;
      const Order: TGPMatrixOrder = MatrixOrderPrepend);
    procedure GetFocusScales(out XScale, YScale: Single);
    procedure SetFocusScales(const XScale, YScale: Single);
    procedure SetSurroundColors(const Colors: array of TGPColor);

    { Properties }
    property CenterColor: TGPColor read GetCenterColor write SetCenterColor;
    property PointCount: Integer read GetPointCount;
    property SurroundColors: IGPColors read GetSurroundColors write SetSurroundColorsInternal;
    property GraphicsPath: IGPGraphicsPath read GetGraphicsPath write SetGraphicsPath;
    property CenterPoint: TGPPointF read GetCenterPoint write SetCenterPoint;
    property CenterPointI: TGPPoint read GetCenterPointI write SetCenterPointI;
    property Rectangle: TGPRectF read GetRectangle;
    property RectangleI: TGPRect read GetRectangleI;
    property GammaCorrection: Boolean read GetGammaCorrection write SetGammaCorrection;
    property Blend: IGPBlend read GetBlend write SetBlend;
    property InterpolationColors: IGPColorBlend read GetInterpolationColors write SetInterpolationColors;
    property Transform: IGPMatrix read GetTransform write SetTransform;
    property WrapMode: TGPWrapMode read GetWrapMode write SetWrapMode;
  end;

  TGPPathGradientBrush = class(TGPBrush, IGPPathGradientBrush)
  private
    { IGPPathGradientBrush }
    function GetCenterColor: TGPColor;
    procedure SetCenterColor(const Value: TGPColor);
    function GetPointCount: Integer;
    function GetSurroundColors: IGPColors;
    procedure SetSurroundColorsInternal(const Value: IGPColors);
    function GetGraphicsPath: IGPGraphicsPath;
    procedure SetGraphicsPath(const Value: IGPGraphicsPath);
    function GetCenterPoint: TGPPointF;
    procedure SetCenterPoint(const Value: TGPPointF);
    function GetCenterPointI: TGPPoint;
    procedure SetCenterPointI(const Value: TGPPoint);
    function GetRectangle: TGPRectF;
    function GetRectangleI: TGPRect;
    function GetGammaCorrection: Boolean;
    procedure SetGammaCorrection(const Value: Boolean);
    function GetBlend: IGPBlend;
    procedure SetBlend(const Value: IGPBlend);
    function GetInterpolationColors: IGPColorBlend;
    procedure SetInterpolationColors(const Value: IGPColorBlend);
    function GetTransform: IGPMatrix;
    procedure SetTransform(const Value: IGPMatrix);
    function GetWrapMode: TGPWrapMode;
    procedure SetWrapMode(const Value: TGPWrapMode);

    procedure SetBlendBellShape(const Focus: Single; const Scale: Single = 1);
    procedure SetBlendTriangularShape(const Focus: Single; const Scale: Single = 1);
    procedure ResetTransform;
    procedure MultiplyTransform(const Matrix: IGPMatrix;
      const Order: TGPMatrixOrder = MatrixOrderPrepend);
    procedure TranslateTransform(const DX, DY: Single;
      const Order: TGPMatrixOrder = MatrixOrderPrepend);
    procedure ScaleTransform(const SX, SY: Single;
      const Order: TGPMatrixOrder = MatrixOrderPrepend);
    procedure RotateTransform(const Angle: Single;
      const Order: TGPMatrixOrder = MatrixOrderPrepend);
    procedure GetFocusScales(out XScale, YScale: Single);
    procedure SetFocusScales(const XScale, YScale: Single);
    procedure SetSurroundColors(const Colors: array of TGPColor);
  public
    constructor Create(const Points: array of TGPPointF;
      const WrapMode: TGPWrapMode = WrapModeClamp); overload;
    constructor Create(const Points: array of TGPPoint;
      const WrapMode: TGPWrapMode = WrapModeClamp); overload;
    constructor Create(const Path: IGPGraphicsPath); overload;
  end;
{$ENDREGION 'GdiplusPath.h'}

{$REGION 'GdiplusGraphics.h'}

(*****************************************************************************
 * GdiplusGraphics.h
 * GDI+ Graphics class
 *****************************************************************************)

  IGPRegions = IGPArray<IGPRegion>;

  IGPGraphics = interface(IGdiPlusBase)
  ['{57F85BA4-CB01-4466-8441-948D03588F54}']
    { Property access methods }
    function GetRenderingOrigin: TGPPoint; overload;
    procedure SetRenderingOrigin(const Value: TGPPoint); overload;
    function GetCompositingMode: TGPCompositingMode;
    procedure SetCompositingMode(const Value: TGPCompositingMode);
    function GetCompositingQuality: TGPCompositingQuality;
    procedure SetCompositingQuality(const Value: TGPCompositingQuality);
    function GetTextRenderingHint: TGPTextRenderingHint;
    procedure SetTextRenderingHint(const Value: TGPTextRenderingHint);
    function GetTextContrast: Integer;
    procedure SetTextContrast(const Value: Integer);
    function GetInterpolationMode: TGPInterpolationMode;
    procedure SetInterpolationMode(const Value: TGPInterpolationMode);
    function GetSmoothingMode: TGPSmoothingMode;
    procedure SetSmoothingMode(const Value: TGPSmoothingMode);
    function GetPixelOffsetMode: TGPPixelOffsetMode;
    procedure SetPixelOffsetMode(const Value: TGPPixelOffsetMode);
    function GetTransform: IGPMatrix;
    procedure SetTransform(const Value: IGPMatrix);
    function GetPageUnit: TGPUnit;
    procedure SetPageUnit(const Value: TGPUnit);
    function GetPageScale: Single;
    procedure SetPageScale(const Value: Single);
    function GetDpiX: Single;
    function GetDpiY: Single;
    function GetClip: IGPRegion;
    procedure SetClipReplace(const Value: IGPRegion);
    function GetClipBounds: TGPRectF;
    function GetClipBoundsI: TGPRect;
    function GetIsClipEmpty: Boolean;
    function GetVisibleClipBounds: TGPRectF;
    function GetVisibleClipBoundsI: TGPRect;
    function GetIsVisibleClipEmpty: Boolean;

    { Methods }
    procedure Flush(const Intention: TGPFlushIntention = FlushIntentionFlush);
    function GetHDC: HDC;
    procedure ReleaseHDC(const DC: HDC);
    procedure GetRenderingOrigin(out X, Y: Integer); overload;
    procedure SetRenderingOrigin(const X, Y: Integer); overload;
    {$IF (GDIPVER >= $0110)}
    procedure SetAbort(const IAbort: TGdiplusAbort);
    {$IFEND}
    procedure ResetTransform;
    procedure MultiplyTransform(const Matrix: IGPMatrix;
      const Order: TGPMatrixOrder = MatrixOrderPrepend);
    procedure TranslateTransform(const DX, DY: Single;
      const Order: TGPMatrixOrder = MatrixOrderPrepend);
    procedure ScaleTransform(const SX, SY: Single;
      const Order: TGPMatrixOrder = MatrixOrderPrepend);
    procedure RotateTransform(const Angle: Single;
      const Order: TGPMatrixOrder = MatrixOrderPrepend);
    procedure TransformPoints(const DestSpace, SrcSpace: TGPCoordinateSpace;
      const Points: array of TGPPointF); overload;
    procedure TransformPoints(const DestSpace, SrcSpace: TGPCoordinateSpace;
      const Points: array of TGPPoint); overload;
    function GetNearestColor(const Color: TGPColor): TGPColor;

    procedure DrawLine(const Pen: IGPPen; const Pt1, Pt2: TGPPointF); overload;
    procedure DrawLine(const Pen: IGPPen; const X1, Y1, X2, Y2: Single); overload;
    procedure DrawLine(const Pen: IGPPen; const Pt1, Pt2: TGPPoint); overload;
    procedure DrawLine(const Pen: IGPPen; const X1, Y1, X2, Y2: Integer); overload;

    procedure DrawLines(const Pen: IGPPen; const Points: array of TGPPointF); overload;
    procedure DrawLines(const Pen: IGPPen; const Points: array of TGPPoint); overload;

    procedure DrawArc(const Pen: IGPPen; const Rect: TGPRectF; const StartAngle,
      SweepAngle: Single); overload;
    procedure DrawArc(const Pen: IGPPen; const X, Y, Width, Height, StartAngle,
      SweepAngle: Single); overload;
    procedure DrawArc(const Pen: IGPPen; const Rect: TGPRect; const StartAngle,
      SweepAngle: Single); overload;
    procedure DrawArc(const Pen: IGPPen; const X, Y, Width, Height: Integer;
      const StartAngle, SweepAngle: Single); overload;

    procedure DrawBezier(const Pen: IGPPen; const Pt1, Pt2, Pt3, Pt4: TGPPointF); overload;
    procedure DrawBezier(const Pen: IGPPen; const X1, Y1, X2, Y2, X3, Y3, X4, Y4: Single); overload;
    procedure DrawBezier(const Pen: IGPPen; const Pt1, Pt2, Pt3, Pt4: TGPPoint); overload;
    procedure DrawBezier(const Pen: IGPPen; const X1, Y1, X2, Y2, X3, Y3, X4, Y4: Integer); overload;

    procedure DrawBeziers(const Pen: IGPPen; const Points: array of TGPPointF); overload;
    procedure DrawBeziers(const Pen: IGPPen; const Points: array of TGPPoint); overload;

    procedure DrawRectangle(const Pen: IGPPen; const Rect: TGPRectF); overload;
    procedure DrawRectangle(const Pen: IGPPen; const Rect: TGPRect); overload;
    procedure DrawRectangle(const Pen: IGPPen; const X, Y, Width, Height: Single); overload;
    procedure DrawRectangle(const Pen: IGPPen; const X, Y, Width, Height: Integer); overload;

    procedure DrawRectangles(const Pen: IGPPen; const Rects: array of TGPRectF); overload;
    procedure DrawRectangles(const Pen: IGPPen; const Rects: array of TGPRect); overload;

    procedure DrawEllipse(const Pen: IGPPen; const Rect: TGPRectF); overload;
    procedure DrawEllipse(const Pen: IGPPen; const X, Y, Width, Height: Single); overload;
    procedure DrawEllipse(const Pen: IGPPen; const Rect: TGPRect); overload;
    procedure DrawEllipse(const Pen: IGPPen; const X, Y, Width, Height: Integer); overload;

    procedure DrawPie(const Pen: IGPPen; const Rect: TGPRectF;
      const StartAngle, SweepAngle: Single); overload;
    procedure DrawPie(const Pen: IGPPen; const X, Y, Width, Height,
      StartAngle, SweepAngle: Single); overload;
    procedure DrawPie(const Pen: IGPPen; const Rect: TGPRect;
      const StartAngle, SweepAngle: Single); overload;
    procedure DrawPie(const Pen: IGPPen; const X, Y, Width, Height: Integer;
      const StartAngle, SweepAngle: Single); overload;

    procedure DrawPolygon(const Pen: IGPPen; const Points: array of TGPPointF); overload;
    procedure DrawPolygon(const Pen: IGPPen; const Points: array of TGPPoint); overload;

    procedure DrawPath(const Pen: IGPPen; const Path: IGPGraphicsPath);

    procedure DrawCurve(const Pen: IGPPen; const Points: array of TGPPointF); overload;
    procedure DrawCurve(const Pen: IGPPen; const Points: array of TGPPointF;
      const Tension: Single); overload;
    procedure DrawCurve(const Pen: IGPPen; const Points: array of TGPPointF;
      const Offset, NumberOfSegments: Integer; const Tension: Single); overload;
    procedure DrawCurve(const Pen: IGPPen; const Points: array of TGPPoint); overload;
    procedure DrawCurve(const Pen: IGPPen; const Points: array of TGPPoint;
      const Tension: Single); overload;
    procedure DrawCurve(const Pen: IGPPen; const Points: array of TGPPoint;
      const Offset, NumberOfSegments: Integer; const Tension: Single); overload;

    procedure DrawClosedCurve(const Pen: IGPPen; const Points: array of TGPPointF); overload;
    procedure DrawClosedCurve(const Pen: IGPPen; const Points: array of TGPPointF;
      const Tension: Single); overload;
    procedure DrawClosedCurve(const Pen: IGPPen; const Points: array of TGPPoint); overload;
    procedure DrawClosedCurve(const Pen: IGPPen; const Points: array of TGPPoint;
      const Tension: Single); overload;

    procedure Clear(const Color: TGPColor);

    procedure FillRectangle(const Brush: IGPBrush; const Rect: TGPRectF); overload;
    procedure FillRectangle(const Brush: IGPBrush; const Rect: TGPRect); overload;
    procedure FillRectangle(const Brush: IGPBrush; const X, Y, Width, Height: Single); overload;
    procedure FillRectangle(const Brush: IGPBrush; const X, Y, Width, Height: Integer); overload;

    procedure FillRectangles(const Brush: IGPBrush; const Rects: array of TGPRectF); overload;
    procedure FillRectangles(const Brush: IGPBrush; const Rects: array of TGPRect); overload;

    procedure FillPolygon(const Brush: IGPBrush; const Points: array of TGPPointF); overload;
    procedure FillPolygon(const Brush: IGPBrush; const Points: array of TGPPoint); overload;
    procedure FillPolygon(const Brush: IGPBrush; const Points: array of TGPPointF;
      const FillMode: TGPFillMode); overload;
    procedure FillPolygon(const Brush: IGPBrush; const Points: array of TGPPoint;
      const FillMode: TGPFillMode); overload;

    procedure FillEllipse(const Brush: IGPBrush; const Rect: TGPRectF); overload;
    procedure FillEllipse(const Brush: IGPBrush; const X, Y, Width, Height: Single); overload;
    procedure FillEllipse(const Brush: IGPBrush; const Rect: TGPRect); overload;
    procedure FillEllipse(const Brush: IGPBrush; const X, Y, Width, Height: Integer); overload;

    procedure FillPie(const Brush: IGPBrush; const Rect: TGPRectF;
      const StartAngle, SweepAngle: Single); overload;
    procedure FillPie(const Brush: IGPBrush; const X, Y, Width, Height,
      StartAngle, SweepAngle: Single); overload;
    procedure FillPie(const Brush: IGPBrush; const Rect: TGPRect;
      const StartAngle, SweepAngle: Single); overload;
    procedure FillPie(const Brush: IGPBrush; const X, Y, Width, Height: Integer;
      const StartAngle, SweepAngle: Single); overload;

    procedure FillPath(const Brush: IGPBrush; const Path: IGPGraphicsPath);

    procedure FillClosedCurve(const Brush: IGPBrush; const Points: array of TGPPointF); overload;
    procedure FillClosedCurve(const Brush: IGPBrush; const Points: array of TGPPointF;
      const FillMode: TGPFillMode; const Tension: Single); overload;
    procedure FillClosedCurve(const Brush: IGPBrush; const Points: array of TGPPoint); overload;
    procedure FillClosedCurve(const Brush: IGPBrush; const Points: array of TGPPoint;
      const FillMode: TGPFillMode; const Tension: Single); overload;

    procedure FillRegion(const Brush: IGPBrush; const Region: IGPRegion);

    procedure DrawString(const Str: String; const Font: IGPFont;
      const Origin: TGPPointF; const Brush: IGPBrush); overload;
    procedure DrawString(const Str: String; const Font: IGPFont;
      const LayoutRect: TGPRectF; const Format: IGPStringFormat;
      const Brush: IGPBrush); overload;
    procedure DrawString(const Str: String; const Font: IGPFont;
      const Origin: TGPPointF; const Format: IGPStringFormat;
      const Brush: IGPBrush); overload;

    function MeasureString(const Str: String; const Font: IGPFont;
      const LayoutRect: TGPRectF; const Format: IGPStringFormat): TGPRectF; overload;
    function MeasureString(const Str: String; const Font: IGPFont;
      const LayoutRect: TGPRectF; const Format: IGPStringFormat;
      out CodepointsFitted, LinesFilled: Integer): TGPRectF; overload;
    function MeasureString(const Str: String; const Font: IGPFont;
      const LayoutRectSize: TGPSizeF; const Format: IGPStringFormat): TGPSizeF; overload;
    function MeasureString(const Str: String; const Font: IGPFont;
      const LayoutRectSize: TGPSizeF; const Format: IGPStringFormat;
      out CodepointsFitted, LinesFilled: Integer): TGPSizeF; overload;
    function MeasureString(const Str: String; const Font: IGPFont;
      const Origin: TGPPointF; const Format: IGPStringFormat): TGPRectF; overload;
    function MeasureString(const Str: String; const Font: IGPFont;
      const LayoutRect: TGPRectF): TGPRectF; overload;
    function MeasureString(const Str: String; const Font: IGPFont;
      const Origin: TGPPointF): TGPRectF; overload;

    function MeasureCharacterRanges(const Str: String; const Font: IGPFont;
      const LayoutRect: TGPRectF; const Format: IGPStringFormat): IGPRegions;
    procedure DrawDriverString(const Text: PUInt16; const Length: Integer;
      const Font: IGPFont; const Brush: IGPBrush; const Positions: PGPPointF;
      const Flags: TGPDriverStringOptions; const Matrix: IGPMatrix);
    function MeasureDriverString(const Text: PUInt16; const Length: Integer;
      const Font: IGPFont; const Positions: PGPPointF;
      const Flags: TGPDriverStringOptions; const Matrix: IGPMatrix): TGPRectF;

    procedure DrawCachedBitmap(const CachedBitmap: IGPCachedBitmap;
      const X, Y: Integer);

    procedure DrawImage(const Image: IGPImage; const Point: TGPPointF); overload;
    procedure DrawImage(const Image: IGPImage; const X, Y: Single); overload;
    procedure DrawImage(const Image: IGPImage; const Rect: TGPRectF); overload;
    procedure DrawImage(const Image: IGPImage; const X, Y, Width, Height: Single); overload;
    procedure DrawImage(const Image: IGPImage; const Point: TGPPoint); overload;
    procedure DrawImage(const Image: IGPImage; const X, Y: Integer); overload;
    procedure DrawImage(const Image: IGPImage; const Rect: TGPRect); overload;
    procedure DrawImage(const Image: IGPImage; const X, Y, Width, Height: Integer); overload;
    procedure DrawImage(const Image: IGPImage; const DestPoints: TGPPlgPointsF); overload;
    procedure DrawImage(const Image: IGPImage; const DestPoints: TGPPlgPoints); overload;
    procedure DrawImage(const Image: IGPImage; const X, Y, SrcX, SrcY, SrcWidth,
      SrcHeight: Single; const SrcUnit: TGPUnit); overload;
    procedure DrawImage(const Image: IGPImage; const DestRect: TGPRectF;
      const SrcX, SrcY, SrcWidth, SrcHeight: Single; const SrcUnit: TGPUnit;
      const ImageAttributes: IGPImageAttributes = nil;
      const Callback: TGPDrawImageAbort = nil; const CallbackData: Pointer = nil); overload;
    procedure DrawImage(const Image: IGPImage; const DstX, DstY, DstWidth,
      DstHeight, SrcX, SrcY, SrcWidth, SrcHeight: Single; const SrcUnit: TGPUnit;
      const ImageAttributes: IGPImageAttributes = nil;
      const Callback: TGPDrawImageAbort = nil; const CallbackData: Pointer = nil); overload;
    procedure DrawImage(const Image: IGPImage; const DestPoints: TGPPlgPointsF;
      const SrcX, SrcY, SrcWidth, SrcHeight: Single; const SrcUnit: TGPUnit;
      const ImageAttributes: IGPImageAttributes = nil;
      const Callback: TGPDrawImageAbort = nil; const CallbackData: Pointer = nil); overload;
    procedure DrawImage(const Image: IGPImage; const X, Y, SrcX, SrcY, SrcWidth,
      SrcHeight: Integer; const SrcUnit: TGPUnit); overload;
    procedure DrawImage(const Image: IGPImage; const DestRect: TGPRect;
      const SrcX, SrcY, SrcWidth, SrcHeight: Integer; const SrcUnit: TGPUnit;
      const ImageAttributes: IGPImageAttributes = nil;
      const Callback: TGPDrawImageAbort = nil; const CallbackData: Pointer = nil); overload;
    procedure DrawImage(const Image: IGPImage; const DstX, DstY, DstWidth,
      DstHeight, SrcX, SrcY, SrcWidth, SrcHeight: Integer; const SrcUnit: TGPUnit;
      const ImageAttributes: IGPImageAttributes = nil;
      const Callback: TGPDrawImageAbort = nil; const CallbackData: Pointer = nil); overload;
    procedure DrawImage(const Image: IGPImage; const DestPoints: TGPPlgPoints;
      const SrcX, SrcY, SrcWidth, SrcHeight: Integer; const SrcUnit: TGPUnit;
      const ImageAttributes: IGPImageAttributes = nil;
      const Callback: TGPDrawImageAbort = nil; const CallbackData: Pointer = nil); overload;
    {$IF (GDIPVER >= $0110)}
    procedure DrawImage(const Image: IGPImage; const DestRect, SourceRect: TGPRectF;
      const SrcUnit: TGPUnit; const ImageAttributes: IGPImageAttributes = nil); overload;
    procedure DrawImage(const Image: IGPImage; const SourceRect: TGPRectF;
      const XForm: IGPMatrix; const Effect: IGPEffect;
      const ImageAttributes: IGPImageAttributes; const SrcUnit: TGPUnit); overload;
    {$IFEND}

    procedure EnumerateMetafile(const Metafile: IGPMetafile;
      const DestPoint: TGPPointF; const Callback: TGPEnumerateMetafileProc;
      const CallbackData: Pointer = nil;
      const ImageAttributes: IGPImageAttributes = nil); overload;
    procedure EnumerateMetafile(const Metafile: IGPMetafile;
      const DestPoint: TGPPoint; const Callback: TGPEnumerateMetafileProc;
      const CallbackData: Pointer = nil;
      const ImageAttributes: IGPImageAttributes = nil); overload;
    procedure EnumerateMetafile(const Metafile: IGPMetafile;
      const DestRect: TGPRectF; const Callback: TGPEnumerateMetafileProc;
      const CallbackData: Pointer = nil;
      const ImageAttributes: IGPImageAttributes = nil); overload;
    procedure EnumerateMetafile(const Metafile: IGPMetafile;
      const DestRect: TGPRect; const Callback: TGPEnumerateMetafileProc;
      const CallbackData: Pointer = nil;
      const ImageAttributes: IGPImageAttributes = nil); overload;
    procedure EnumerateMetafile(const Metafile: IGPMetafile;
      const DestPoints: TGPPlgPointsF; const Callback: TGPEnumerateMetafileProc;
      const CallbackData: Pointer = nil;
      const ImageAttributes: IGPImageAttributes = nil); overload;
    procedure EnumerateMetafile(const Metafile: IGPMetafile;
      const DestPoints: TGPPlgPoints; const Callback: TGPEnumerateMetafileProc;
      const CallbackData: Pointer = nil;
      const ImageAttributes: IGPImageAttributes = nil); overload;
    procedure EnumerateMetafile(const Metafile: IGPMetafile;
      const DestPoint: TGPPointF; const SrcRect: TGPRectF; const SrcUnit: TGPUnit;
      const Callback: TGPEnumerateMetafileProc; const CallbackData: Pointer = nil;
      const ImageAttributes: IGPImageAttributes = nil); overload;
    procedure EnumerateMetafile(const Metafile: IGPMetafile;
      const DestPoint: TGPPoint; const SrcRect: TGPRect; const SrcUnit: TGPUnit;
      const Callback: TGPEnumerateMetafileProc; const CallbackData: Pointer = nil;
      const ImageAttributes: IGPImageAttributes = nil); overload;
    procedure EnumerateMetafile(const Metafile: IGPMetafile;
      const DestRect, SrcRect: TGPRectF; const SrcUnit: TGPUnit;
      const Callback: TGPEnumerateMetafileProc; const CallbackData: Pointer = nil;
      const ImageAttributes: IGPImageAttributes = nil); overload;
    procedure EnumerateMetafile(const Metafile: IGPMetafile;
      const DestRect, SrcRect: TGPRect; const SrcUnit: TGPUnit;
      const Callback: TGPEnumerateMetafileProc; const CallbackData: Pointer = nil;
      const ImageAttributes: IGPImageAttributes = nil); overload;
    procedure EnumerateMetafile(const Metafile: IGPMetafile;
      const DestPoints: TGPPlgPointsF; const SrcRect: TGPRectF; const SrcUnit: TGPUnit;
      const Callback: TGPEnumerateMetafileProc; const CallbackData: Pointer = nil;
      const ImageAttributes: IGPImageAttributes = nil); overload;
    procedure EnumerateMetafile(const Metafile: IGPMetafile;
      const DestPoints: TGPPlgPoints; const SrcRect: TGPRect; const SrcUnit: TGPUnit;
      const Callback: TGPEnumerateMetafileProc; const CallbackData: Pointer = nil;
      const ImageAttributes: IGPImageAttributes = nil); overload;

    procedure SetClip(const G: IGPGraphics;
      const CombineMode: TGPCombineMode = CombineModeReplace); overload;
    procedure SetClip(const Rect: TGPRectF;
      const CombineMode: TGPCombineMode = CombineModeReplace); overload;
    procedure SetClip(const Rect: TGPRect;
      const CombineMode: TGPCombineMode = CombineModeReplace); overload;
    procedure SetClip(const Path: IGPGraphicsPath;
      const CombineMode: TGPCombineMode = CombineModeReplace); overload;
    procedure SetClip(const Region: IGPRegion;
      const CombineMode: TGPCombineMode = CombineModeReplace); overload;
    procedure SetClip(const Region: HRgn;
      const CombineMode: TGPCombineMode = CombineModeReplace); overload;

    procedure IntersectClip(const Rect: TGPRectF); overload;
    procedure IntersectClip(const Rect: TGPRect); overload;
    procedure IntersectClip(const Region: IGPRegion); overload;
    procedure ExcludeClip(const Rect: TGPRectF); overload;
    procedure ExcludeClip(const Rect: TGPRect); overload;
    procedure ExcludeClip(const Region: IGPRegion); overload;
    procedure ResetClip;
    procedure TranslateClip(const DX, DY: Single); overload;
    procedure TranslateClip(const DX, DY: Integer); overload;

    function IsVisible(const X, Y: Integer): Boolean; overload;
    function IsVisible(const Point: TGPPoint): Boolean; overload;
    function IsVisible(const X, Y, Width, Height: Integer): Boolean; overload;
    function IsVisible(const Rect: TGPRect): Boolean; overload;
    function IsVisible(const X, Y: Single): Boolean; overload;
    function IsVisible(const Point: TGPPointF): Boolean; overload;
    function IsVisible(const X, Y, Width, Height: Single): Boolean; overload;
    function IsVisible(const Rect: TGPRectF): Boolean; overload;

    function Save: TGPGraphicsState;
    procedure Restore(const State: TGPGraphicsState);
    function BeginContainer(const DstRect, SrcRect: TGPRectF;
      const MeasureUnit: TGPUnit): TGPGraphicsContainer; overload;
    function BeginContainer(const DstRect, SrcRect: TGPRect;
      const MeasureUnit: TGPUnit): TGPGraphicsContainer; overload;
    function BeginContainer: TGPGraphicsContainer; overload;
    procedure EndContainer(const State: TGPGraphicsContainer);

    procedure AddMetafileComment(const Data: array of Byte);

    { Properties }
    property RenderingOrigin: TGPPoint read GetRenderingOrigin write SetRenderingOrigin;
    property CompositingMode: TGPCompositingMode read GetCompositingMode write SetCompositingMode;
    property CompositingQuality: TGPCompositingQuality read GetCompositingQuality write SetCompositingQuality;
    property TextRenderingHint: TGPTextRenderingHint read GetTextRenderingHint write SetTextRenderingHint;
    property TextContrast: Integer read GetTextContrast write SetTextContrast;
    property InterpolationMode: TGPInterpolationMode read GetInterpolationMode write SetInterpolationMode;
    property SmoothingMode: TGPSmoothingMode read GetSmoothingMode write SetSmoothingMode;
    property PixelOffsetMode: TGPPixelOffsetMode read GetPixelOffsetMode write SetPixelOffsetMode;
    property Transform: IGPMatrix read GetTransform write SetTransform;
    property PageUnit: TGPUnit read GetPageUnit write SetPageUnit;
    property PageScale: Single read GetPageScale write SetPageScale;
    property DpiX: Single read GetDpiX;
    property DpiY: Single read GetDpiY;
    property Clip: IGPRegion read GetClip write SetClipReplace;
    property ClipBounds: TGPRectF read GetClipBounds;
    property ClipBoundsI: TGPRect read GetClipBoundsI;
    property IsClipEmpty: Boolean read GetIsClipEmpty;
    property VisibleClipBounds: TGPRectF read GetVisibleClipBounds;
    property VisibleClipBoundsI: TGPRect read GetVisibleClipBoundsI;
    property IsVisibleClipEmpty: Boolean read GetIsVisibleClipEmpty;
  end;

  TGPGraphics = class(TGdiplusBase, IGPGraphics)
  private
    { IGPGraphics }
    function GetRenderingOrigin: TGPPoint; overload;
    procedure SetRenderingOrigin(const Value: TGPPoint); overload;
    function GetCompositingMode: TGPCompositingMode;
    procedure SetCompositingMode(const Value: TGPCompositingMode);
    function GetCompositingQuality: TGPCompositingQuality;
    procedure SetCompositingQuality(const Value: TGPCompositingQuality);
    function GetTextRenderingHint: TGPTextRenderingHint;
    procedure SetTextRenderingHint(const Value: TGPTextRenderingHint);
    function GetTextContrast: Integer;
    procedure SetTextContrast(const Value: Integer);
    function GetInterpolationMode: TGPInterpolationMode;
    procedure SetInterpolationMode(const Value: TGPInterpolationMode);
    function GetSmoothingMode: TGPSmoothingMode;
    procedure SetSmoothingMode(const Value: TGPSmoothingMode);
    function GetPixelOffsetMode: TGPPixelOffsetMode;
    procedure SetPixelOffsetMode(const Value: TGPPixelOffsetMode);
    function GetTransform: IGPMatrix;
    procedure SetTransform(const Value: IGPMatrix);
    function GetPageUnit: TGPUnit;
    procedure SetPageUnit(const Value: TGPUnit);
    function GetPageScale: Single;
    procedure SetPageScale(const Value: Single);
    function GetDpiX: Single;
    function GetDpiY: Single;
    function GetClip: IGPRegion;
    procedure SetClipReplace(const Value: IGPRegion);
    function GetClipBounds: TGPRectF;
    function GetClipBoundsI: TGPRect;
    function GetIsClipEmpty: Boolean;
    function GetVisibleClipBounds: TGPRectF;
    function GetVisibleClipBoundsI: TGPRect;
    function GetIsVisibleClipEmpty: Boolean;

    procedure Flush(const Intention: TGPFlushIntention = FlushIntentionFlush);
    function GetHDC: HDC;
    procedure ReleaseHDC(const DC: HDC);
    procedure GetRenderingOrigin(out X, Y: Integer); overload;
    procedure SetRenderingOrigin(const X, Y: Integer); overload;
    {$IF (GDIPVER >= $0110)}
    procedure SetAbort(const IAbort: TGdiplusAbort);
    {$IFEND}
    procedure ResetTransform;
    procedure MultiplyTransform(const Matrix: IGPMatrix;
      const Order: TGPMatrixOrder = MatrixOrderPrepend);
    procedure TranslateTransform(const DX, DY: Single;
      const Order: TGPMatrixOrder = MatrixOrderPrepend);
    procedure ScaleTransform(const SX, SY: Single;
      const Order: TGPMatrixOrder = MatrixOrderPrepend);
    procedure RotateTransform(const Angle: Single;
      const Order: TGPMatrixOrder = MatrixOrderPrepend);
    procedure TransformPoints(const DestSpace, SrcSpace: TGPCoordinateSpace;
      const Points: array of TGPPointF); overload;
    procedure TransformPoints(const DestSpace, SrcSpace: TGPCoordinateSpace;
      const Points: array of TGPPoint); overload;
    function GetNearestColor(const Color: TGPColor): TGPColor;

    procedure DrawLine(const Pen: IGPPen; const Pt1, Pt2: TGPPointF); overload;
    procedure DrawLine(const Pen: IGPPen; const X1, Y1, X2, Y2: Single); overload;
    procedure DrawLine(const Pen: IGPPen; const Pt1, Pt2: TGPPoint); overload;
    procedure DrawLine(const Pen: IGPPen; const X1, Y1, X2, Y2: Integer); overload;

    procedure DrawLines(const Pen: IGPPen; const Points: array of TGPPointF); overload;
    procedure DrawLines(const Pen: IGPPen; const Points: array of TGPPoint); overload;

    procedure DrawArc(const Pen: IGPPen; const Rect: TGPRectF; const StartAngle,
      SweepAngle: Single); overload;
    procedure DrawArc(const Pen: IGPPen; const X, Y, Width, Height, StartAngle,
      SweepAngle: Single); overload;
    procedure DrawArc(const Pen: IGPPen; const Rect: TGPRect; const StartAngle,
      SweepAngle: Single); overload;
    procedure DrawArc(const Pen: IGPPen; const X, Y, Width, Height: Integer;
      const StartAngle, SweepAngle: Single); overload;

    procedure DrawBezier(const Pen: IGPPen; const Pt1, Pt2, Pt3, Pt4: TGPPointF); overload;
    procedure DrawBezier(const Pen: IGPPen; const X1, Y1, X2, Y2, X3, Y3, X4, Y4: Single); overload;
    procedure DrawBezier(const Pen: IGPPen; const Pt1, Pt2, Pt3, Pt4: TGPPoint); overload;
    procedure DrawBezier(const Pen: IGPPen; const X1, Y1, X2, Y2, X3, Y3, X4, Y4: Integer); overload;

    procedure DrawBeziers(const Pen: IGPPen; const Points: array of TGPPointF); overload;
    procedure DrawBeziers(const Pen: IGPPen; const Points: array of TGPPoint); overload;

    procedure DrawRectangle(const Pen: IGPPen; const Rect: TGPRectF); overload;
    procedure DrawRectangle(const Pen: IGPPen; const Rect: TGPRect); overload;
    procedure DrawRectangle(const Pen: IGPPen; const X, Y, Width, Height: Single); overload;
    procedure DrawRectangle(const Pen: IGPPen; const X, Y, Width, Height: Integer); overload;

    procedure DrawRectangles(const Pen: IGPPen; const Rects: array of TGPRectF); overload;
    procedure DrawRectangles(const Pen: IGPPen; const Rects: array of TGPRect); overload;

    procedure DrawEllipse(const Pen: IGPPen; const Rect: TGPRectF); overload;
    procedure DrawEllipse(const Pen: IGPPen; const X, Y, Width, Height: Single); overload;
    procedure DrawEllipse(const Pen: IGPPen; const Rect: TGPRect); overload;
    procedure DrawEllipse(const Pen: IGPPen; const X, Y, Width, Height: Integer); overload;

    procedure DrawPie(const Pen: IGPPen; const Rect: TGPRectF;
      const StartAngle, SweepAngle: Single); overload;
    procedure DrawPie(const Pen: IGPPen; const X, Y, Width, Height,
      StartAngle, SweepAngle: Single); overload;
    procedure DrawPie(const Pen: IGPPen; const Rect: TGPRect;
      const StartAngle, SweepAngle: Single); overload;
    procedure DrawPie(const Pen: IGPPen; const X, Y, Width, Height: Integer;
      const StartAngle, SweepAngle: Single); overload;

    procedure DrawPolygon(const Pen: IGPPen; const Points: array of TGPPointF); overload;
    procedure DrawPolygon(const Pen: IGPPen; const Points: array of TGPPoint); overload;

    procedure DrawPath(const Pen: IGPPen; const Path: IGPGraphicsPath);

    procedure DrawCurve(const Pen: IGPPen; const Points: array of TGPPointF); overload;
    procedure DrawCurve(const Pen: IGPPen; const Points: array of TGPPointF;
      const Tension: Single); overload;
    procedure DrawCurve(const Pen: IGPPen; const Points: array of TGPPointF;
      const Offset, NumberOfSegments: Integer; const Tension: Single); overload;
    procedure DrawCurve(const Pen: IGPPen; const Points: array of TGPPoint); overload;
    procedure DrawCurve(const Pen: IGPPen; const Points: array of TGPPoint;
      const Tension: Single); overload;
    procedure DrawCurve(const Pen: IGPPen; const Points: array of TGPPoint;
      const Offset, NumberOfSegments: Integer; const Tension: Single); overload;

    procedure DrawClosedCurve(const Pen: IGPPen; const Points: array of TGPPointF); overload;
    procedure DrawClosedCurve(const Pen: IGPPen; const Points: array of TGPPointF;
      const Tension: Single); overload;
    procedure DrawClosedCurve(const Pen: IGPPen; const Points: array of TGPPoint); overload;
    procedure DrawClosedCurve(const Pen: IGPPen; const Points: array of TGPPoint;
      const Tension: Single); overload;

    procedure Clear(const Color: TGPColor);

    procedure FillRectangle(const Brush: IGPBrush; const Rect: TGPRectF); overload;
    procedure FillRectangle(const Brush: IGPBrush; const Rect: TGPRect); overload;
    procedure FillRectangle(const Brush: IGPBrush; const X, Y, Width, Height: Single); overload;
    procedure FillRectangle(const Brush: IGPBrush; const X, Y, Width, Height: Integer); overload;

    procedure FillRectangles(const Brush: IGPBrush; const Rects: array of TGPRectF); overload;
    procedure FillRectangles(const Brush: IGPBrush; const Rects: array of TGPRect); overload;

    procedure FillPolygon(const Brush: IGPBrush; const Points: array of TGPPointF); overload;
    procedure FillPolygon(const Brush: IGPBrush; const Points: array of TGPPoint); overload;
    procedure FillPolygon(const Brush: IGPBrush; const Points: array of TGPPointF;
      const FillMode: TGPFillMode); overload;
    procedure FillPolygon(const Brush: IGPBrush; const Points: array of TGPPoint;
      const FillMode: TGPFillMode); overload;

    procedure FillEllipse(const Brush: IGPBrush; const Rect: TGPRectF); overload;
    procedure FillEllipse(const Brush: IGPBrush; const X, Y, Width, Height: Single); overload;
    procedure FillEllipse(const Brush: IGPBrush; const Rect: TGPRect); overload;
    procedure FillEllipse(const Brush: IGPBrush; const X, Y, Width, Height: Integer); overload;

    procedure FillPie(const Brush: IGPBrush; const Rect: TGPRectF;
      const StartAngle, SweepAngle: Single); overload;
    procedure FillPie(const Brush: IGPBrush; const X, Y, Width, Height,
      StartAngle, SweepAngle: Single); overload;
    procedure FillPie(const Brush: IGPBrush; const Rect: TGPRect;
      const StartAngle, SweepAngle: Single); overload;
    procedure FillPie(const Brush: IGPBrush; const X, Y, Width, Height: Integer;
      const StartAngle, SweepAngle: Single); overload;

    procedure FillPath(const Brush: IGPBrush; const Path: IGPGraphicsPath);

    procedure FillClosedCurve(const Brush: IGPBrush; const Points: array of TGPPointF); overload;
    procedure FillClosedCurve(const Brush: IGPBrush; const Points: array of TGPPointF;
      const FillMode: TGPFillMode; const Tension: Single); overload;
    procedure FillClosedCurve(const Brush: IGPBrush; const Points: array of TGPPoint); overload;
    procedure FillClosedCurve(const Brush: IGPBrush; const Points: array of TGPPoint;
      const FillMode: TGPFillMode; const Tension: Single); overload;

    procedure FillRegion(const Brush: IGPBrush; const Region: IGPRegion);

    procedure DrawString(const Str: String; const Font: IGPFont;
      const LayoutRect: TGPRectF; const Format: IGPStringFormat;
      const Brush: IGPBrush); overload;
    procedure DrawString(const Str: String; const Font: IGPFont;
      const Origin: TGPPointF; const Format: IGPStringFormat;
      const Brush: IGPBrush); overload;
    procedure DrawString(const Str: String; const Font: IGPFont;
      const Origin: TGPPointF; const Brush: IGPBrush); overload;

    function MeasureString(const Str: String; const Font: IGPFont;
      const LayoutRect: TGPRectF; const Format: IGPStringFormat): TGPRectF; overload;
    function MeasureString(const Str: String; const Font: IGPFont;
      const LayoutRect: TGPRectF; const Format: IGPStringFormat;
      out CodepointsFitted, LinesFilled: Integer): TGPRectF; overload;
    function MeasureString(const Str: String; const Font: IGPFont;
      const LayoutRectSize: TGPSizeF; const Format: IGPStringFormat): TGPSizeF; overload;
    function MeasureString(const Str: String; const Font: IGPFont;
      const LayoutRectSize: TGPSizeF; const Format: IGPStringFormat;
      out CodepointsFitted, LinesFilled: Integer): TGPSizeF; overload;
    function MeasureString(const Str: String; const Font: IGPFont;
      const Origin: TGPPointF; const Format: IGPStringFormat): TGPRectF; overload;
    function MeasureString(const Str: String; const Font: IGPFont;
      const LayoutRect: TGPRectF): TGPRectF; overload;
    function MeasureString(const Str: String; const Font: IGPFont;
      const Origin: TGPPointF): TGPRectF; overload;

    function MeasureCharacterRanges(const Str: String; const Font: IGPFont;
      const LayoutRect: TGPRectF; const Format: IGPStringFormat): IGPRegions;
    procedure DrawDriverString(const Text: PUInt16; const Length: Integer;
      const Font: IGPFont; const Brush: IGPBrush; const Positions: PGPPointF;
      const Flags: TGPDriverStringOptions; const Matrix: IGPMatrix);
    function MeasureDriverString(const Text: PUInt16; const Length: Integer;
      const Font: IGPFont; const Positions: PGPPointF;
      const Flags: TGPDriverStringOptions; const Matrix: IGPMatrix): TGPRectF;

    procedure DrawCachedBitmap(const CachedBitmap: IGPCachedBitmap;
      const X, Y: Integer);

    procedure DrawImage(const Image: IGPImage; const Point: TGPPointF); overload;
    procedure DrawImage(const Image: IGPImage; const X, Y: Single); overload;
    procedure DrawImage(const Image: IGPImage; const Rect: TGPRectF); overload;
    procedure DrawImage(const Image: IGPImage; const X, Y, Width, Height: Single); overload;
    procedure DrawImage(const Image: IGPImage; const Point: TGPPoint); overload;
    procedure DrawImage(const Image: IGPImage; const X, Y: Integer); overload;
    procedure DrawImage(const Image: IGPImage; const Rect: TGPRect); overload;
    procedure DrawImage(const Image: IGPImage; const X, Y, Width, Height: Integer); overload;
    procedure DrawImage(const Image: IGPImage; const DestPoints: TGPPlgPointsF); overload;
    procedure DrawImage(const Image: IGPImage; const DestPoints: TGPPlgPoints); overload;
    procedure DrawImage(const Image: IGPImage; const X, Y, SrcX, SrcY, SrcWidth,
      SrcHeight: Single; const SrcUnit: TGPUnit); overload;
    procedure DrawImage(const Image: IGPImage; const DestRect: TGPRectF;
      const SrcX, SrcY, SrcWidth, SrcHeight: Single; const SrcUnit: TGPUnit;
      const ImageAttributes: IGPImageAttributes = nil;
      const Callback: TGPDrawImageAbort = nil; const CallbackData: Pointer = nil); overload;
    procedure DrawImage(const Image: IGPImage; const DstX, DstY, DstWidth,
      DstHeight, SrcX, SrcY, SrcWidth, SrcHeight: Single; const SrcUnit: TGPUnit;
      const ImageAttributes: IGPImageAttributes = nil;
      const Callback: TGPDrawImageAbort = nil; const CallbackData: Pointer = nil); overload;
    procedure DrawImage(const Image: IGPImage; const DestPoints: TGPPlgPointsF;
      const SrcX, SrcY, SrcWidth, SrcHeight: Single; const SrcUnit: TGPUnit;
      const ImageAttributes: IGPImageAttributes = nil;
      const Callback: TGPDrawImageAbort = nil; const CallbackData: Pointer = nil); overload;
    procedure DrawImage(const Image: IGPImage; const X, Y, SrcX, SrcY, SrcWidth,
      SrcHeight: Integer; const SrcUnit: TGPUnit); overload;
    procedure DrawImage(const Image: IGPImage; const DestRect: TGPRect;
      const SrcX, SrcY, SrcWidth, SrcHeight: Integer; const SrcUnit: TGPUnit;
      const ImageAttributes: IGPImageAttributes = nil;
      const Callback: TGPDrawImageAbort = nil; const CallbackData: Pointer = nil); overload;
    procedure DrawImage(const Image: IGPImage; const DstX, DstY, DstWidth,
      DstHeight, SrcX, SrcY, SrcWidth, SrcHeight: Integer; const SrcUnit: TGPUnit;
      const ImageAttributes: IGPImageAttributes = nil;
      const Callback: TGPDrawImageAbort = nil; const CallbackData: Pointer = nil); overload;
    procedure DrawImage(const Image: IGPImage; const DestPoints: TGPPlgPoints;
      const SrcX, SrcY, SrcWidth, SrcHeight: Integer; const SrcUnit: TGPUnit;
      const ImageAttributes: IGPImageAttributes = nil;
      const Callback: TGPDrawImageAbort = nil; const CallbackData: Pointer = nil); overload;
    {$IF (GDIPVER >= $0110)}
    procedure DrawImage(const Image: IGPImage; const DestRect, SourceRect: TGPRectF;
      const SrcUnit: TGPUnit; const ImageAttributes: IGPImageAttributes = nil); overload;
    procedure DrawImage(const Image: IGPImage; const SourceRect: TGPRectF;
      const XForm: IGPMatrix; const Effect: IGPEffect;
      const ImageAttributes: IGPImageAttributes; const SrcUnit: TGPUnit); overload;
    {$IFEND}

    procedure EnumerateMetafile(const Metafile: IGPMetafile;
      const DestPoint: TGPPointF; const Callback: TGPEnumerateMetafileProc;
      const CallbackData: Pointer = nil;
      const ImageAttributes: IGPImageAttributes = nil); overload;
    procedure EnumerateMetafile(const Metafile: IGPMetafile;
      const DestPoint: TGPPoint; const Callback: TGPEnumerateMetafileProc;
      const CallbackData: Pointer = nil;
      const ImageAttributes: IGPImageAttributes = nil); overload;
    procedure EnumerateMetafile(const Metafile: IGPMetafile;
      const DestRect: TGPRectF; const Callback: TGPEnumerateMetafileProc;
      const CallbackData: Pointer = nil;
      const ImageAttributes: IGPImageAttributes = nil); overload;
    procedure EnumerateMetafile(const Metafile: IGPMetafile;
      const DestRect: TGPRect; const Callback: TGPEnumerateMetafileProc;
      const CallbackData: Pointer = nil;
      const ImageAttributes: IGPImageAttributes = nil); overload;
    procedure EnumerateMetafile(const Metafile: IGPMetafile;
      const DestPoints: TGPPlgPointsF; const Callback: TGPEnumerateMetafileProc;
      const CallbackData: Pointer = nil;
      const ImageAttributes: IGPImageAttributes = nil); overload;
    procedure EnumerateMetafile(const Metafile: IGPMetafile;
      const DestPoints: TGPPlgPoints; const Callback: TGPEnumerateMetafileProc;
      const CallbackData: Pointer = nil;
      const ImageAttributes: IGPImageAttributes = nil); overload;
    procedure EnumerateMetafile(const Metafile: IGPMetafile;
      const DestPoint: TGPPointF; const SrcRect: TGPRectF; const SrcUnit: TGPUnit;
      const Callback: TGPEnumerateMetafileProc; const CallbackData: Pointer = nil;
      const ImageAttributes: IGPImageAttributes = nil); overload;
    procedure EnumerateMetafile(const Metafile: IGPMetafile;
      const DestPoint: TGPPoint; const SrcRect: TGPRect; const SrcUnit: TGPUnit;
      const Callback: TGPEnumerateMetafileProc; const CallbackData: Pointer = nil;
      const ImageAttributes: IGPImageAttributes = nil); overload;
    procedure EnumerateMetafile(const Metafile: IGPMetafile;
      const DestRect, SrcRect: TGPRectF; const SrcUnit: TGPUnit;
      const Callback: TGPEnumerateMetafileProc; const CallbackData: Pointer = nil;
      const ImageAttributes: IGPImageAttributes = nil); overload;
    procedure EnumerateMetafile(const Metafile: IGPMetafile;
      const DestRect, SrcRect: TGPRect; const SrcUnit: TGPUnit;
      const Callback: TGPEnumerateMetafileProc; const CallbackData: Pointer = nil;
      const ImageAttributes: IGPImageAttributes = nil); overload;
    procedure EnumerateMetafile(const Metafile: IGPMetafile;
      const DestPoints: TGPPlgPointsF; const SrcRect: TGPRectF; const SrcUnit: TGPUnit;
      const Callback: TGPEnumerateMetafileProc; const CallbackData: Pointer = nil;
      const ImageAttributes: IGPImageAttributes = nil); overload;
    procedure EnumerateMetafile(const Metafile: IGPMetafile;
      const DestPoints: TGPPlgPoints; const SrcRect: TGPRect; const SrcUnit: TGPUnit;
      const Callback: TGPEnumerateMetafileProc; const CallbackData: Pointer = nil;
      const ImageAttributes: IGPImageAttributes = nil); overload;

    procedure SetClip(const G: IGPGraphics;
      const CombineMode: TGPCombineMode = CombineModeReplace); overload;
    procedure SetClip(const Rect: TGPRectF;
      const CombineMode: TGPCombineMode = CombineModeReplace); overload;
    procedure SetClip(const Rect: TGPRect;
      const CombineMode: TGPCombineMode = CombineModeReplace); overload;
    procedure SetClip(const Path: IGPGraphicsPath;
      const CombineMode: TGPCombineMode = CombineModeReplace); overload;
    procedure SetClip(const Region: IGPRegion;
      const CombineMode: TGPCombineMode = CombineModeReplace); overload;
    procedure SetClip(const Region: HRgn;
      const CombineMode: TGPCombineMode = CombineModeReplace); overload;

    procedure IntersectClip(const Rect: TGPRectF); overload;
    procedure IntersectClip(const Rect: TGPRect); overload;
    procedure IntersectClip(const Region: IGPRegion); overload;
    procedure ExcludeClip(const Rect: TGPRectF); overload;
    procedure ExcludeClip(const Rect: TGPRect); overload;
    procedure ExcludeClip(const Region: IGPRegion); overload;
    procedure ResetClip;
    procedure TranslateClip(const DX, DY: Single); overload;
    procedure TranslateClip(const DX, DY: Integer); overload;

    function IsVisible(const X, Y: Integer): Boolean; overload;
    function IsVisible(const Point: TGPPoint): Boolean; overload;
    function IsVisible(const X, Y, Width, Height: Integer): Boolean; overload;
    function IsVisible(const Rect: TGPRect): Boolean; overload;
    function IsVisible(const X, Y: Single): Boolean; overload;
    function IsVisible(const Point: TGPPointF): Boolean; overload;
    function IsVisible(const X, Y, Width, Height: Single): Boolean; overload;
    function IsVisible(const Rect: TGPRectF): Boolean; overload;

    function Save: TGPGraphicsState;
    procedure Restore(const State: TGPGraphicsState);
    function BeginContainer(const DstRect, SrcRect: TGPRectF;
      const MeasureUnit: TGPUnit): TGPGraphicsContainer; overload;
    function BeginContainer(const DstRect, SrcRect: TGPRect;
      const MeasureUnit: TGPUnit): TGPGraphicsContainer; overload;
    function BeginContainer: TGPGraphicsContainer; overload;
    procedure EndContainer(const State: TGPGraphicsContainer);

    procedure AddMetafileComment(const Data: array of Byte);
  public
    constructor Create(const DC: HDC); overload;
    constructor Create(const DC: HDC; const Device: THandle); overload;
    constructor Create(const Window: HWnd; const ICM: Boolean = False); overload;
    constructor Create(const Image: IGPImage); overload;
    destructor Destroy; override;

    class function FromHDC(const DC: HDC): IGPGraphics; overload; static;
    class function FromHDC(const DC: HDC; const Device: THandle): IGPGraphics; overload; static;
    class function FromHWnd(const Window: HWnd;
      const ICM: Boolean = False): IGPGraphics; static;
    class function FromImage(const Image: IGPImage): IGPGraphics; static;
  end;
{$ENDREGION 'GdiplusGraphics.h'}

{$REGION 'Utilities'}
type
  EGdipError = class(Exception)
  private
    FStatus: TGPStatus;
  public
    constructor Create(const Status: TGPStatus);

    property Status: TGPStatus read FStatus;
  end;
{$ENDREGION 'Utilities'}

{$REGION 'Aliases'}
{$IFDEF GDIP_ALIAS}
type
  TGraphicsState = TGPGraphicsState;
  PGraphicsState = PGPGraphicsState;
  TGraphicsContainer = TGPGraphicsContainer;
  PGraphicsContainer = PGPGraphicsContainer;
  TFillMode = TGPFillMode;
  TQualityMode = TGPQualityMode;
  TCompositingMode = TGPCompositingMode;
  TCompositingQuality = TGPCompositingQuality;
  TUnit = TGPUnit;
  TMetafileFrameUnit = TGPMetafileFrameUnit;
  TCoordinateSpace = TGPCoordinateSpace;
  TWrapMode = TGPWrapMode;
  THatchStyle = TGPHatchStyle;
  TDashStyle = TGPDashStyle;
  TDashCap = TGPDashCap;
  TLineCap = TGPLineCap;
  TCustomLineCapType = TGPCustomLineCapType;
  TLineJoin = TGPLineJoin;
  TPathPointType = TGPPathPointType;
  TWarpMode = TGPWarpMode;
  TLinearGradientMode = TGPLinearGradientMode;
  TCombineMode = TGPCombineMode;
  TImageType = TGPImageType;
  TInterpolationMode = TGPInterpolationMode;
  TPenAlignment = TGPPenAlignment;
  TBrushType = TGPBrushType;
  TPenType = TGPPenType;
  TMatrixOrder = TGPMatrixOrder;
  TGenericFontFamily = TGPGenericFontFamily;
  TFontStyleEntry = TGPFontStyleEntry;
  TFontStyle = TGPFontStyle;
  TSmoothingMode = TGPSmoothingMode;
  TPixelOffsetMode = TGPPixelOffsetMode;
  TTextRenderingHint = TGPTextRenderingHint;
  TMetafileType = TGPMetafileType;
  TEmfType = TGPEmfType;
  TObjectType = TGPObjectType;
  TStringFormatFlag = TGPStringFormatFlag;
  TStringFormatFlags = TGPStringFormatFlags;
  TStringTrimming = TGPStringTrimming;
  TStringDigitSubstitute = TGPStringDigitSubstitute;
  PStringDigitSubstitute = PGPStringDigitSubstitute;
  THotkeyPrefix = TGPHotkeyPrefix;
  TStringAlignment = TGPStringAlignment;
  TDriverStringOption = TGPDriverStringOption;
  TDriverStringOptions = TGPDriverStringOptions;
  TFlushIntention = TGPFlushIntention;
  TEncoderParameterValueType = TGPEncoderParameterValueType;
  TEncoderValue = TGPEncoderValue;
  TEmfToWmfBitsFlag = TGPEmfToWmfBitsFlag;
  TEmfToWmfBitsFlags = TGPEmfToWmfBitsFlags;
  TTestControlEnum = TGPTestControlEnum;
  TImageAbort = TGPImageAbort;
  TDrawImageAbort = TGPDrawImageAbort;
  TGetThumbnailImageAbort = TGPGetThumbnailImageAbort;
  TEnumerateMetafileProc = TGPEnumerateMetafileProc;
  TStatus = TGPStatus;
  TSizeF = TGPSizeF;
  PSizeF = PGPSizeF;
  TSize = TGPSize;
  PSize = PGPSize;
  TPointF = TGPPointF;
  PPointF = PGPPointF;
  TPoint = TGPPoint;
  PPoint = PGPPoint;
  PRectF = PGPRectF;
  TRectF = TGPRectF;
  PRect = PGPRect;
  TRect = TGPRect;
  TNativePathData = TGPNativePathData;
  PNativePathData = PGPNativePathData;
  TCharacterRange = TGPCharacterRange;
  PCharacterRange = PGPCharacterRange;
  TDebugEventLevel = TGPDebugEventLevel;
  TDebugEventProc = TGPDebugEventProc;
  TNofificationHookProc = TGPNofificationHookProc;
  TNofificationUnhookProc = TGPNofificationUnhookProc;
  TPixelFormat = TGPPixelFormat;
  TPaletteFlag = TGPPaletteFlag;
  TPaletteFlags = TGPPaletteFlags;
  TNativeColorPalette = TGPNativeColorPalette;
  PNativeColorPalette = PGPNativeColorPalette;
  TColorMode = TGPColorMode;
  TColorChannelFlags = TGPColorChannelFlags;
  TColor = TGPColor;
  PColor = PGPColor;
  TMetafileHeader = TGPMetafileHeader;
  PMetafileHeader = PGPMetafileHeader;
  IImageBytes = IGPImageBytes;
  TImageCodecFlag = TGPImageCodecFlag;
  TNativeImageCodecInfo = TGPNativeImageCodecInfo;
  PNativeImageCodecInfo = PGPNativeImageCodecInfo;
  TImageLockModeOption = TGPImageLockModeOption;
  TImageLockMode = TGPImageLockMode;
  TBitmapData = TGPBitmapData;
  PBitmapData = PGPBitmapData;
  TImageFlag = TGPImageFlag;
  TImageFlags = TGPImageFlags;
  TRotateFlipType = TGPRotateFlipType;
  TNativeEncoderParameter = TGPNativeEncoderParameter;
  PNativeEncoderParameter = PGPNativeEncoderParameter;
  TNativeEncoderParameters = TGPNativeEncoderParameters;
  PNativeEncoderParameters = PGPNativeEncoderParameters;
  TNativePropertyItem = TGPNativePropertyItem;
  PNativePropertyItem = PGPNativePropertyItem;
  TColorMatrix = TGPColorMatrix;
  PColorMatrix = PGPColorMatrix;
  TColorMatrixFlags = TGPColorMatrixFlags;
  TColorAdjustType = TGPColorAdjustType;
  TColorMap = TGPColorMap;
  PColorMap = PGPColorMap;
  IRegionData = IGPRegionData;
  IRegionScansF = IGPRegionScansF;
  IRegionScans = IGPRegionScans;
  IRegion = IGPRegion;
  TRegion = TGPRegion;
  IFontFamily = IGPFontFamily;
  TFontFamily = TGPFontFamily;
  IFont = IGPFont;
  TFont = TGPFont;
  IFontFamilies = IGPFontFamilies;
  IFontCollection = IGPFontCollection;
  TFontCollection = TGPFontCollection;
  IInstalledFontCollection = IGPInstalledFontCollection;
  TInstalledFontCollection = TGPInstalledFontCollection;
  IPrivateFontCollection = IGPPrivateFontCollection;
  TPrivateFontCollection = TGPPrivateFontCollection;
  IImageFormat = IGPImageFormat;
  TImageFormat = TGPImageFormat;
  IImageCodecInfo = IGPImageCodecInfo;
  IImageCodecInfoArray = IGPImageCodecInfoArray;
  TImageCodecInfo = TGPImageCodecInfo;
  IEncoderParameters = IGPEncoderParameters;
  TEncoderParameterEnumerator = TGPEncoderParameterEnumerator;
  TEncoderParameters = TGPEncoderParameters;
  IColorPalette = IGPColorPalette;
  TColorPalette = TGPColorPalette;
  IPropertyItem = IGPPropertyItem;
  TPropertyItem = TGPPropertyItem;
  IFrameDimensions = IGPFrameDimensions;
  IPropertyIdList = IGPPropertyIdList;
  IPropertyItems = IGPPropertyItems;
  IImage = IGPImage;
  TImage = TGPImage;
  IBitmap = IGPBitmap;
  TBitmap = TGPBitmap;
  ICustomLineCap = IGPCustomLineCap;
  TCustomLineCap = TGPCustomLineCap;
  IAdjustableArrowCap = IGPAdjustableArrowCap;
  TAdjustableArrowCap = TGPAdjustableArrowCap;
  ICachedBitmap = IGPCachedBitmap;
  TCachedBitmap = TGPCachedBitmap;
  IMetafile = IGPMetafile;
  TMetafile = TGPMetafile;
  IImageAttributes = IGPImageAttributes;
  TImageAttributes = TGPImageAttributes;
  TMatrixElements = TGPMatrixElements;
  TPlgPointsF = TGPPlgPointsF;
  TPlgPoints = TGPPlgPoints;
  IMatrix = IGPMatrix;
  TMatrix = TGPMatrix;
  IBrush = IGPBrush;
  TBrush = TGPBrush;
  ISolidBrush = IGPSolidBrush;
  TSolidBrush = TGPSolidBrush;
  ITextureBrush = IGPTextureBrush;
  TTextureBrush = TGPTextureBrush;
  TLinearColors = TGPLinearColors;
  IBlend = IGPBlend;
  TBlend = TGPBlend;
  IColorBlend = IGPColorBlend;
  TColorBlend = TGPColorBlend;
  ILinearGradientBrush = IGPLinearGradientBrush;
  TLinearGradientBrush = TGPLinearGradientBrush;
  IHatchBrush = IGPHatchBrush;
  THatchBrush = TGPHatchBrush;
  IDashPattern = IGPDashPattern;
  ICompoundArray = IGPCompoundArray;
  IPen = IGPPen;
  TPen = TGPPen;
  ITabStops = IGPTabStops;
  ICharacterRanges = IGPCharacterRanges;
  IStringFormat = IGPStringFormat;
  TStringFormat = TGPStringFormat;
  IPathTypes = IGPPathTypes;
  IPathPoints = IGPPathPoints;
  IPathPointsI = IGPPathPointsI;
  IPathData = IGPPathData;
  TPathData = TGPPathData;
  IGraphicsPath = IGPGraphicsPath;
  TGraphicsPath = TGPGraphicsPath;
  IGraphicsPathIterator = IGPGraphicsPathIterator;
  TGraphicsPathIterator = TGPGraphicsPathIterator;
  IColors = IGPColors;
  IPathGradientBrush = IGPPathGradientBrush;
  TPathGradientBrush = TGPPathGradientBrush;
  IRegions = IGPRegions;
  IGraphics = IGPGraphics;
  TGraphics = TGPGraphics;
{$IF (GDIPVER >= $0110)}
  TConvertToEmfPlusFlags = TGPConvertToEmfPlusFlags;
  TPaletteType = TGPPaletteType;
  TDitherType = TGPDitherType;
  TItemDataPosition = TGPItemDataPosition;
  TImageItemData = TGPImageItemData;
  PImageItemData = PGPImageItemData;
  TColorChannelLUT = TGPColorChannelLUT;
  THistogramFormat = TGPHistogramFormat;
  IHistogram = IGPHistogram;
  THistogram = TGPHistogram;
  TSharpenParams = TGPSharpenParams;
  PSharpenParams = PGPSharpenParams;
  TBlurParams = TGPBlurParams;
  PBlurParams = PGPBlurParams;
  TBrightnessContrastParams = TGPBrightnessContrastParams;
  PBrightnessContrastParams = PGPBrightnessContrastParams;
  TRedEyeCorrectionParams = TGPRedEyeCorrectionParams;
  PRedEyeCorrectionParams = PGPRedEyeCorrectionParams;
  THueSaturationLightnessParams = TGPHueSaturationLightnessParams;
  PHueSaturationLightnessParams = PGPHueSaturationLightnessParams;
  TTintParams = TGPTintParams;
  PTintParams = PGPTintParams;
  TLevelsParams = TGPLevelsParams;
  PLevelsParams = PGPLevelsParams;
  TColorBalanceParams = TGPColorBalanceParams;
  PColorBalanceParams = PGPColorBalanceParams;
  TColorLUTParams = TGPColorLUTParams;
  PColorLUTParams = PGPColorLUTParams;
  TCurveAdjustments = TGPCurveAdjustments;
  TCurveChannel = TGPCurveChannel;
  TColorCurveParams = TGPColorCurveParams;
  PColorCurveParams = PGPColorCurveParams;
  IEffect = IGPEffect;
  TEffect = TGPEffect;
  IBlur = IGPBlur;
  TBlur = TGPBlur;
  ISharpen = IGPSharpen;
  TSharpen = TGPSharpen;
  IRedEyeCorrection = IGPRedEyeCorrection;
  TRedEyeCorrection = TGPRedEyeCorrection;
  IBrightnessContrast = IGPBrightnessContrast;
  TBrightnessContrast = TGPBrightnessContrast;
  IHueSaturationLightness = IGPHueSaturationLightness;
  THueSaturationLightness = TGPHueSaturationLightness;
  ILevels = IGPLevels;
  TLevels = TGPLevels;
  ITint = IGPTint;
  TTint = TGPTint;
  IColorBalance = IGPColorBalance;
  TColorBalance = TGPColorBalance;
  IColorMatrixEffect = IGPColorMatrixEffect;
  TColorMatrixEffect = TGPColorMatrixEffect;
  IColorLUT = IGPColorLUT;
  TColorLUT = TGPColorLUT;
  IColorCurve = IGPColorCurve;
  TColorCurve = TGPColorCurve;
{$IFEND} // (GDIPVER >= $0110)
{$ENDIF} // GDIP_ALIAS
{$ENDREGION 'Aliases'}

implementation

{$POINTERMATH ON}

{$REGION 'Support classes'}

{ TGPArray<T>.TEnumerator }

constructor TGPArray<T>.TEnumerator.Create(const AArray: TGPArray<T>);
begin
  inherited Create;
  FArray := AArray;
  FIndex := -1;
end;

function TGPArray<T>.TEnumerator.DoGetCurrent: T;
begin
  Result := GetCurrent;
end;

function TGPArray<T>.TEnumerator.DoMoveNext: Boolean;
begin
  Result := MoveNext;
end;

function TGPArray<T>.TEnumerator.GetCurrent: T;
begin
  Result := FArray.GetItem(FIndex);
end;

function TGPArray<T>.TEnumerator.MoveNext: Boolean;
begin
  if (FIndex >= FArray.GetCount) then
    Exit(False);
  Inc(FIndex);
  Result := (FIndex < FArray.GetCount);
end;

{ TGPArray<T> }

constructor TGPArray<T>.Create(const Count: Integer);
begin
  inherited Create;
  SetLength(FItems, Count);
end;

function TGPArray<T>.GetCount: Integer;
begin
  Result := Length(FItems);
end;

function TGPArray<T>.GetEnumerator: TEnumerator<T>;
begin
  Result := TEnumerator.Create(Self);
end;

function TGPArray<T>.GetItem(const Index: Integer): T;
begin
  Result := FItems[Index];
end;

function TGPArray<T>.GetItemPtr: Pointer;
begin
  Result := @FItems[0];
end;

procedure TGPArray<T>.SetCount(const Value: Integer);
begin
  if (Value <> Length(FItems)) then
    SetLength(FItems, Value);
end;

procedure TGPArray<T>.SetItem(const Index: Integer; const Value: T);
begin
  FItems[Index] := Value;
end;

{ TGPBuffer }

constructor TGPBuffer.Create(const Data: Pointer; const Size: Cardinal);
begin
  inherited Create;
  FData := Data;
  FSize := Size;
end;

destructor TGPBuffer.Destroy;
begin
  FreeMem(FData);
  inherited;
end;

function TGPBuffer.GetData: Pointer;
begin
  Result := FData;
end;

function TGPBuffer.GetSize: Cardinal;
begin
  Result := FSize;
end;

{$ENDREGION 'Support classes'}

{$REGION 'Utilities'}
procedure GdipCheck(const Status: TGPStatus); inline;
begin
  if (Status <> Ok) then
    raise EGdipError.Create(Status);
end;

function GdipHandle(const GpObject: IGdiplusBase): GpNativeHandle;
begin
  if Assigned(GpObject) then
    Result := GpObject.NativeHandle
  else
    Result := nil;
end;
{ EGdipError }

constructor EGdipError.Create(const Status: TGPStatus);
var
  S: String;
begin
  case Status of
    GenericError:
      S := 'Generic Error';
    InvalidParameter:
      S := 'One of the arguments passed to the method was not valid';
    OutOfMemory:
      S := 'Out of Memory';
    ObjectBusy:
      S := 'One of the arguments is already in use in another thread';
    InsufficientBuffer:
      S := 'The specified buffer is not large enough to hold the data to be received';
    NotImplemented:
      S := 'Method is not implemented';
    Win32Error:
      S := 'Win32 Error: ' + SysErrorMessage(GetLastError);
    WrongState:
      S := 'The object is in an invalid state';
    Aborted:
      S := 'The method was aborted';
    FileNotFound:
      S := 'The specified image file or metafile cannot be found';
    ValueOverflow:
      S := 'The method performed an arithmetic operation that produces a numeric overflow';
    AccessDenied:
      S := 'A write operation is not allowed on the specified file';
    UnknownImageFormat:
      S := 'The specified image file format is not known';
    FontFamilyNotFound:
      S := 'The specified font family cannot be found';
    FontStyleNotFound:
      S := 'The specified style is not available for the specified font family';
    NotTrueTypeFont:
      S := 'The specified font is not a TrueType font';
    UnsupportedGdiplusVersion:
      S := 'The version of GDI+ installed on the system is incompatible with the requested version';
    GdiplusNotInitialized:
      S := 'GDI+ is not initialized';
    PropertyNotFound:
      S := 'The specified property does not exist in the image';
    PropertyNotSupported:
      S := 'The specified property is not supported by the format of the image';
    {$IF (GDIPVER >= $0110)}
    ProfileNotFound:
      S := 'The color profile required to save an image in CMYK format was not found';
    {$IFEND}
  else
    S := 'Unknown error: ' + IntToStr(Ord(Status));
  end;
  inherited Create('(GDI+ Error) ' + S);
end;
{$ENDREGION 'Utilities'}

{$REGION 'GdiplusBase.h'}
(*****************************************************************************
 * GdiplusBase.h
 * GDI+ base memory allocation class
 *****************************************************************************)

{ TGdiplusBase }

constructor TGdiplusBase.Create;
begin
  inherited Create;
end;

procedure TGdiplusBase.FreeInstance;
begin
  CleanupInstance;
  GdipFree(Self);
end;

function TGdiplusBase.GetNativeHandle: GpNativeHandle;
begin
  Result := FNativeHandle;
end;

class function TGdiplusBase.NewInstance: TObject;
begin
  Result := InitInstance(GdipAlloc(InstanceSize));

  { Set an implicit refcount so that refcounting during construction won't
    destroy the object (see TInterfacedObject.NewInstance) }
  TGdiplusBase(Result).FRefCount := 1;
end;

procedure TGdiplusBase.SetNativeHandle(const Value: GpNativeHandle);
begin
  FNativeHandle := Value;
end;

{$ENDREGION 'GdiplusBase.h'}

{$REGION 'GdiplusEnums.h'}
(*****************************************************************************
 * GdiplusEnums.h
 * GDI+ Enumeration Types
 *****************************************************************************)

function ObjectTypeIsValid(const ObjectType: TGPObjectType): Boolean; inline;
begin
  Result := (ObjectType >= ObjectTypeMin) and (ObjectType <= ObjectTypeMax);
end;
{$ENDREGION 'GdiplusEnums.h' }

{$REGION 'GdiplusTypes.h'}

{ TGPSizeF }

class operator TGPSizeF.Add(const A, B: TGPSizeF): TGPSizeF;
begin
  Result.Initialize(A.Width + B.Width, A.Height + B.Height);
end;

class function TGPSizeF.Create(const Size: TGPSizeF): TGPSizeF;
begin
  Result.Initialize(Size);
end;

class function TGPSizeF.Create(const AWidth, AHeight: Single): TGPSizeF;
begin
  Result.Initialize(AWidth, AHeight);
end;

function TGPSizeF.Empty: Boolean;
begin
  Result := (Width = 0) and (Height = 0);
end;

function TGPSizeF.Equals(const Size: TGPSizeF): Boolean;
begin
  Result := (Width = Size.Width) and (Height = Size.Height);
end;

procedure TGPSizeF.Initialize;
begin
  Width := 0;
  Height := 0;
end;

procedure TGPSizeF.Initialize(const AWidth, AHeight: Single);
begin
  Width := AWidth;
  Height := AHeight;
end;

procedure TGPSizeF.Initialize(const Size: TGPSizeF);
begin
  Width := Size.Width;
  Height := Size.Height;
end;

class operator TGPSizeF.Subtract(const A, B: TGPSizeF): TGPSizeF;
begin
  Result.Initialize(A.Width - B.Width, A.Height - B.Height);
end;

{ TGPSize }

class operator TGPSize.Add(const A, B: TGPSize): TGPSize;
begin
  Result.Initialize(A.Width + B.Width, A.Height + B.Height);
end;

class function TGPSize.Create(const Size: TGPSize): TGPSize;
begin
  Result.Initialize(Size);
end;

class function TGPSize.Create(const AWidth, AHeight: Integer): TGPSize;
begin
  Result.Initialize(AWidth, AHeight);
end;

function TGPSize.Empty: Boolean;
begin
  Result := (Width = 0) and (Height = 0);
end;

function TGPSize.Equals(const Size: TGPSize): Boolean;
begin
  Result := (Width = Size.Width) and (Height = Size.Height);
end;

procedure TGPSize.Initialize;
begin
  Width := 0;
  Height := 0;
end;

procedure TGPSize.Initialize(const AWidth, AHeight: Integer);
begin
  Width := AWidth;
  Height := AHeight;
end;

procedure TGPSize.Initialize(const Size: TGPSize);
begin
  Width := Size.Width;
  Height := Size.Height;
end;

class operator TGPSize.Subtract(const A, B: TGPSize): TGPSize;
begin
  Result.Initialize(A.Width - B.Width, A.Height - B.Height);
end;

{ TGPPointF }

class operator TGPPointF.Add(const A, B: TGPPointF): TGPPointF;
begin
  Result.Initialize(A.X + B.X, A.Y + B.Y);
end;

class function TGPPointF.Create(const Point: TGPPointF): TGPPointF;
begin
  Result.Initialize(Point);
end;

class function TGPPointF.Create(const Size: TGPSizeF): TGPPointF;
begin
  Result.Initialize(Size);
end;

class function TGPPointF.Create(const AX, AY: Single): TGPPointF;
begin
  Result.Initialize(AX, AY);
end;

function TGPPointF.Equals(const Point: TGPPointF): Boolean;
begin
  Result := (X = Point.X) and (Y = Point.Y);
end;

procedure TGPPointF.Initialize;
begin
  X := 0;
  Y := 0;
end;

procedure TGPPointF.Initialize(const Point: TGPPointF);
begin
  X := Point.X;
  Y := Point.Y;
end;

procedure TGPPointF.Initialize(const AX, AY: Single);
begin
  X := AX;
  Y := AY;
end;

procedure TGPPointF.Initialize(const Size: TGPSizeF);
begin
  X := Size.Width;
  Y := Size.Height;
end;

class operator TGPPointF.Subtract(const A, B: TGPPointF): TGPPointF;
begin
  Result.Initialize(A.X - B.X, A.Y - B.Y);
end;

{ TGPPoint }

class operator TGPPoint.Add(const A, B: TGPPoint): TGPPoint;
begin
  Result.Initialize(A.X + B.X, A.Y + B.Y);
end;

class function TGPPoint.Create(const Point: TGPPoint): TGPPoint;
begin
  Result.Initialize(Point);
end;

class function TGPPoint.Create(const Size: TGPSize): TGPPoint;
begin
  Result.Initialize(Size);
end;

class function TGPPoint.Create(const AX, AY: Integer): TGPPoint;
begin
  Result.Initialize(AX, AY);
end;

function TGPPoint.Equals(const Point: TGPPoint): Boolean;
begin
  Result := (X = Point.X) and (Y = Point.Y);
end;

procedure TGPPoint.Initialize;
begin
  X := 0;
  Y := 0;
end;

procedure TGPPoint.Initialize(const Point: TGPPoint);
begin
  X := Point.X;
  Y := Point.Y;
end;

procedure TGPPoint.Initialize(const AX, AY: Integer);
begin
  X := AX;
  Y := AY;
end;

procedure TGPPoint.Initialize(const Size: TGPSize);
begin
  X := Size.Width;
  Y := Size.Height;
end;

class operator TGPPoint.Subtract(const A, B: TGPPoint): TGPPoint;
begin
  Result.Initialize(A.X - B.X, A.Y - B.Y);
end;

{ TGPRectF }

function TGPRectF.Clone: TGPRectF;
begin
  Result := Self;
end;

function TGPRectF.Contains(const Rect: TGPRectF): Boolean;
begin
  Result := (X <= Rect.X) and (Rect.Right <= Right)
        and (Y <= Rect.Y) and (Rect.Bottom <= Bottom);
end;

class function TGPRectF.Create(const AX, AY, AWidth, AHeight: Single): TGPRectF;
begin
  Result.Initialize(AX, AY, AWidth, AHeight);
end;

class function TGPRectF.Create(const Location: TGPPointF;
  const Size: TGPSizeF): TGPRectF;
begin
  Result.Initialize(Location, Size);
end;

function TGPRectF.Contains(const Point: TGPPointF): Boolean;
begin
  Result := Contains(Point.X, Point.Y);
end;

function TGPRectF.Contains(const AX, AY: Single): Boolean;
begin
  Result := (AX >= X) and (AX < (X + Width)) and (AY >= Y) and (AY < (Y + Height));
end;

function TGPRectF.Equals(const Rect: TGPRectF): Boolean;
begin
  Result := (X = Rect.X) and (Y = Rect.Y) and (Width = Rect.Width) and (Height = Rect.Height);
end;

function TGPRectF.GetBottom: Single;
begin
  Result := Y + Height;
end;

function TGPRectF.GetBounds: TGPRectF;
begin
  Result := Self;
end;

function TGPRectF.GetLocation: TGPPointF;
begin
  Result.X := X;
  Result.Y := Y;
end;

function TGPRectF.GetRight: Single;
begin
  Result := X + Width;
end;

function TGPRectF.GetSize: TGPSizeF;
begin
  Result.Width := Width;
  Result.Height := Height;
end;

procedure TGPRectF.Inflate(const Point: TGPPointF);
begin
  Inflate(Point.X, Point.Y);
end;

procedure TGPRectF.Inflate(const DX, DY: Single);
begin
  X := X - DX;
  Y := Y - DY;
  Width := Width + (2 * DX);
  Height := Height + (2 * DY);
end;

procedure TGPRectF.Initialize;
begin
  X := 0;
  Y := 0;
  Width := 0;
  Height := 0;
end;

procedure TGPRectF.Initialize(const AX, AY, AWidth, AHeight: Single);
begin
  X := AX;
  Y := AY;
  Width := AWidth;
  Height := AHeight;
end;

procedure TGPRectF.Inflate(const DXY: Single);
begin
  Inflate(DXY, DXY);
end;

procedure TGPRectF.Initialize(const Location: TGPPointF; const Size: TGPSizeF);
begin
  X := Location.X;
  Y := Location.Y;
  Width := Size.Width;
  Height := Size.Height;
end;

procedure TGPRectF.InitializeFromLTRB(const Left, Top, Right, Bottom: Single);
begin
  X := Left;
  Y := Top;
  Width := Right - Left;
  Height := Bottom - Top;
end;

class function TGPRectF.Intersect(out C: TGPRectF; const A, B: TGPRectF): Boolean;
var
  Right, Bottom, Left, Top: Single;
begin
  Right := Min(A.Right, B.Right);
  Bottom := Min(A.Bottom, B.Bottom);
  Left := Max(A.Left, B.Left);
  Top := Max(A.Top, B.Top);

  C.X := Left;
  C.Y := Top;
  C.Width := Right - Left;
  C.Height := Bottom - Top;
  Result := (not C.IsEmptyArea);
end;

function TGPRectF.Intersect(const Rect: TGPRectF): Boolean;
begin
  Result := Intersect(Self, Self, Rect);
end;

function TGPRectF.IntersectsWith(const Rect: TGPRectF): Boolean;
begin
  Result := (Left < Rect.Right) and (Top < Rect.Bottom)
        and (Right > Rect.Left) and (Bottom > Rect.Top);
end;

function TGPRectF.IsEmptyArea: Boolean;
begin
  Result := (Width <= REAL_EPSILON) or (Height <= REAL_EPSILON);
end;

procedure TGPRectF.Offset(const DX, DY: Single);
begin
  X := X + DX;
  Y := Y + DY;
end;

function TGPRectF.Union(const Rect: TGPRectF): Boolean;
begin
  Result := Union(Self, Self, Rect);
end;

procedure TGPRectF.Offset(const Point: TGPPointF);
begin
  Offset(Point.X, Point.Y);
end;

class function TGPRectF.Union(out C: TGPRectF; const A, B: TGPRectF): Boolean;
var
  Right, Bottom, Left, Top: Single;
begin
  Right := Max(A.Right, B.Right);
  Bottom := Max(A.Bottom, B.Bottom);
  Left := Min(A.Left, B.Left);
  Top := Min(A.Top, B.Top);

  C.X := Left;
  C.Y := Top;
  C.Width := Right - Left;
  C.Height := Bottom - Top;
  Result := (not C.IsEmptyArea);
end;

{ TGPRect }

function TGPRect.Clone: TGPRect;
begin
  Result := Self;
end;

function TGPRect.Contains(const Rect: TGPRect): Boolean;
begin
  Result := (X <= Rect.X) and (Rect.Right <= Right)
        and (Y <= Rect.Y) and (Rect.Bottom <= Bottom);
end;

class function TGPRect.Create(const AX, AY, AWidth, AHeight: Integer): TGPRect;
begin
  Result.Initialize(AX, AY, AWidth, AHeight);
end;

class function TGPRect.Create(const Location: TGPPoint; const Size: TGPSize): TGPRect;
begin
  Result.Initialize(Location, Size);
end;

class function TGPRect.Create(const Rect: Windows.TRect): TGPRect;
begin
  Result.Initialize(Rect);
end;

function TGPRect.Contains(const Point: TGPPoint): Boolean;
begin
  Result := Contains(Point.X, Point.Y);
end;

function TGPRect.Contains(const AX, AY: Integer): Boolean;
begin
  Result := (AX >= X) and (AX < (X + Width)) and (AY >= Y) and (AY < (Y + Height));
end;

function TGPRect.Equals(const Rect: TGPRect): Boolean;
begin
  Result := (X = Rect.X) and (Y = Rect.Y) and (Width = Rect.Width) and (Height = Rect.Height);
end;

function TGPRect.GetBottom: Integer;
begin
  Result := Y + Height;
end;

function TGPRect.GetBounds: TGPRect;
begin
  Result := Self;
end;

function TGPRect.GetLocation: TGPPoint;
begin
  Result.X := X;
  Result.Y := Y;
end;

function TGPRect.GetRight: Integer;
begin
  Result := X + Width;
end;

function TGPRect.GetSize: TGPSize;
begin
  Result.Width := Width;
  Result.Height := Height;
end;

procedure TGPRect.Inflate(const Point: TGPPoint);
begin
  Inflate(Point.X, Point.Y);
end;

procedure TGPRect.Inflate(const DX, DY: Integer);
begin
  X := X - DX;
  Y := Y - DY;
  Width := Width + (2 * DX);
  Height := Height + (2 * DY);
end;

procedure TGPRect.Initialize;
begin
  X := 0;
  Y := 0;
  Width := 0;
  Height := 0;
end;

procedure TGPRect.Initialize(const AX, AY, AWidth, AHeight: Integer);
begin
  X := AX;
  Y := AY;
  Width := AWidth;
  Height := AHeight;
end;

procedure TGPRect.Initialize(const Location: TGPPoint; const Size: TGPSize);
begin
  X := Location.X;
  Y := Location.Y;
  Width := Size.Width;
  Height := Size.Height;
end;

procedure TGPRect.Initialize(const Rect: Windows.TRect);
begin
  X := Rect.Left;
  Y := Rect.Top;
  Width := Rect.Right - Rect.Left;
  Height := Rect.Bottom - Rect.Top;
end;

procedure TGPRect.InitializeFromLTRB(const Left, Top, Right, Bottom: Integer);
begin
  X := Left;
  Y := Top;
  Width := Right - Left;
  Height := Bottom - Top;
end;

class function TGPRect.Intersect(out C: TGPRect; const A, B: TGPRect): Boolean;
var
  Right, Bottom, Left, Top: Integer;
begin
  Right := Min(A.Right, B.Right);
  Bottom := Min(A.Bottom, B.Bottom);
  Left := Max(A.Left, B.Left);
  Top := Max(A.Top, B.Top);

  C.X := Left;
  C.Y := Top;
  C.Width := Right - Left;
  C.Height := Bottom - Top;
  Result := (not C.IsEmptyArea);
end;

function TGPRect.Intersect(const Rect: TGPRect): Boolean;
begin
  Result := Intersect(Self, Self, Rect);
end;

function TGPRect.IntersectsWith(const Rect: TGPRect): Boolean;
begin
  Result := (Left < Rect.Right) and (Top < Rect.Bottom)
        and (Right > Rect.Left) and (Bottom > Rect.Top);
end;

function TGPRect.IsEmptyArea: Boolean;
begin
  Result := (Width <= REAL_EPSILON) or (Height <= REAL_EPSILON);
end;

procedure TGPRect.Offset(const DX, DY: Integer);
begin
  X := X + DX;
  Y := Y + DY;
end;

function TGPRect.Union(const Rect: TGPRect): Boolean;
begin
  Result := Union(Self, Self, Rect);
end;

procedure TGPRect.Offset(const Point: TGPPoint);
begin
  Offset(Point.X, Point.Y);
end;

class function TGPRect.Union(out C: TGPRect; const A, B: TGPRect): Boolean;
var
  Right, Bottom, Left, Top: Integer;
begin
  Right := Max(A.Right, B.Right);
  Bottom := Max(A.Bottom, B.Bottom);
  Left := Min(A.Left, B.Left);
  Top := Min(A.Top, B.Top);

  C.X := Left;
  C.Y := Top;
  C.Width := Right - Left;
  C.Height := Bottom - Top;
  Result := (not C.IsEmptyArea);
end;

{ TGPCharacterRange }

procedure TGPCharacterRange.Initialize;
begin
  First := 0;
  Length := 0;
end;

procedure TGPCharacterRange.Initialize(const AFirst, ALength: Integer);
begin
  First := AFirst;
  Length := ALength;
end;
{$ENDREGION 'GdiplusTypes.h'}

{$REGION 'GdiplusInit.h'}

{ TGdiplusStartupInput }

procedure TGdiplusStartupInput.Intialize(
  const ADebugEventCallback: TGPDebugEventProc; const ASuppressBackgroundThread,
  ASuppressExternalCodecs: Boolean);
begin
  GdiplusVersion := 1;
  DebugEventCallback := ADebugEventCallback;
  SuppressBackgroundThread := ASuppressBackgroundThread;
  SuppressExternalCodecs := ASuppressExternalCodecs;
end;

{$IF (GDIPVER >= $0110)}

{ TGdiplusStartupInputEx }

procedure TGdiplusStartupInputEx.Intialize(const AStartupParameters: Integer;
  const ADebugEventCallback: TGPDebugEventProc; const ASuppressBackgroundThread,
  ASuppressExternalCodecs: Boolean);
begin
  GdiplusVersion := 2;
  DebugEventCallback := ADebugEventCallback;
  SuppressBackgroundThread := ASuppressBackgroundThread;
  SuppressExternalCodecs := ASuppressExternalCodecs;
  StartupParameters := AStartupParameters;
end;
{$IFEND}

{$ENDREGION 'GdiplusInit.h'}

{$REGION 'GdiplusPixelFormats.h'}
function GetPixelFormatSize(const PixFmt: TGPPixelFormat): Integer; inline;
begin
  Result := (PixFmt shr 8) and $FF;
end;

function IsIndexedPixelFormat(const PixFmt: TGPPixelFormat): Boolean; inline;
begin
  Result := ((PixFmt and PixelFormatIndexed) <> 0);
end;

function IsAlphaPixelFormat(const PixFmt: TGPPixelFormat): Boolean; inline;
begin
  Result := ((PixFmt and PixelFormatAlpha) <> 0);
end;

function IsExtendedPixelFormat(const PixFmt: TGPPixelFormat): Boolean; inline;
begin
  Result := ((PixFmt and PixelFormatExtended) <> 0);
end;

function IsCanonicalPixelFormat(const PixFmt: TGPPixelFormat): Boolean; inline;
begin
  Result := ((PixFmt and PixelFormatCanonical) <> 0);
end;

{$ENDREGION 'GdiplusPixelFormats.h'}

{$REGION 'GdiplusColor.h'}

{ TGPColor }

class function TGPColor.Create(const AArgb: ARGB): TGPColor;
begin
  Result.FArgb := AArgb;
end;

class function TGPColor.CreateFromColorRef(const ColorRef: TColorRef): TGPColor;
begin
  Result.SetColorRef(ColorRef);
end;

class function TGPColor.Create(const R, G, B: Byte): TGPColor;
begin
  Result.FArgb := MakeARGB(255, R, G, B);
end;

class function TGPColor.Create(const A, R, G, B: Byte): TGPColor;
begin
  Result.FArgb := MakeARGB(A, R, G, B);
end;

function TGPColor.GetAlpha: Byte;
begin
  Result := Byte(FArgb shr AlphaShift);
end;

function TGPColor.GetBlue: Byte;
begin
  Result := Byte(FArgb shr BlueShift);
end;

function TGPColor.GetColorRef: TColorRef;
begin
  Result := GetRed or (GetGreen shl 8) or (GetBlue shl 16);
end;

function TGPColor.GetGreen: Byte;
begin
  Result := Byte(FArgb shr GreenShift);
end;

function TGPColor.GetRed: Byte;
begin
  Result := Byte(FArgb shr RedShift);
end;

procedure TGPColor.Initialize(const R, G, B: Byte);
begin
  FArgb := MakeARGB(255, R, G, B);
end;

procedure TGPColor.Initialize;
begin
  FArgb := Black;
end;

class operator TGPColor.Implicit(const AArgb: ARGB): TGPColor;
begin
  Result.FArgb := AArgb;
end;

class operator TGPColor.Implicit(const Color: TGPColor): ARGB;
begin
  Result := Color.FArgb;
end;

procedure TGPColor.Initialize(const AArgb: ARGB);
begin
  FArgb := AArgb;
end;

procedure TGPColor.InitializeFromColorRef(const ColorRef: TColorRef);
begin
  SetColorRef(ColorRef);
end;

procedure TGPColor.Initialize(const A, R, G, B: Byte);
begin
  FArgb := MakeARGB(A, R, G, B)
end;

class function TGPColor.MakeARGB(const A, R, G, B: Byte): ARGB;
begin
  Result := (ARGB(B) shl BlueShift) or
            (ARGB(G) shl GreenShift) or
            (ARGB(R) shl RedShift) or
            (ARGB(A) shl AlphaShift);
end;

procedure TGPColor.SetAlpha(const Value: Byte);
begin
  FArgb := (FArgb and (not AlphaMask)) or (Value shl AlphaShift);
end;

procedure TGPColor.SetBlue(const Value: Byte);
begin
  FArgb := (FArgb and (not BlueMask)) or (Value shl BlueShift);
end;

procedure TGPColor.SetColorRef(const Value: TColorRef);
begin
  if (Value < 0) then
    FArgb := GetSysColor(Value and $000000FF)
  else
    FArgb := Value;
  FArgb := MakeARGB(255, Byte(FArgb), Byte(FArgb shr 8), Byte(FArgb shr 16));
end;

procedure TGPColor.SetGreen(const Value: Byte);
begin
  FArgb := (FArgb and (not GreenMask)) or (Value shl GreenShift);
end;

procedure TGPColor.SetRed(const Value: Byte);
begin
  FArgb := (FArgb and (not RedMask)) or (Value shl RedShift);
end;

{$ENDREGION 'GdiplusColor.h'}

{$REGION 'GdiplusMetaHeader.h'}

{ TGPMetafileHeader }

function TGPMetafileHeader.GetBounds: TGPRect;
begin
  Result.Initialize(FX, FY, FWidth, FHeight);
end;

function TGPMetafileHeader.GetEmfHeader: PEnhMetaHeader3;
begin
  if (IsEmfOrEmfPlus) then
    Result := @FHeader.EmfHeader
  else
    Result := nil;
end;

function TGPMetafileHeader.GetWmfHeader: PMetaHeader;
begin
  if (IsWmf) then
    Result := @FHeader.WmfHeader
  else
    Result := nil;
end;

function TGPMetafileHeader.IsDisplay: Boolean;
begin
  Result := IsEmfPlus and ((FEmfPlusFlags and GDIP_EMFPLUSFLAGS_DISPLAY) <> 0);
end;

function TGPMetafileHeader.IsEmf: Boolean;
begin
  Result := (FMetafileType = MetafileTypeEmf);
end;

function TGPMetafileHeader.IsEmfOrEmfPlus: Boolean;
begin
  Result := (FMetafileType >= MetafileTypeEmf);
end;

function TGPMetafileHeader.IsEmfPlus: Boolean;
begin
  Result := (FMetafileType >= MetafileTypeEmfPlusOnly);
end;

function TGPMetafileHeader.IsEmfPlusDual: Boolean;
begin
  Result := (FMetafileType = MetafileTypeEmfPlusDual);
end;

function TGPMetafileHeader.IsEmfPlusOnly: Boolean;
begin
  Result := (FMetafileType = MetafileTypeEmfPlusOnly);
end;

function TGPMetafileHeader.IsWmf: Boolean;
begin
  Result := (FMetafileType in [MetafileTypeWmf, MetafileTypeWmfPlaceable]);
end;

function TGPMetafileHeader.IsWmfPlaceable: Boolean;
begin
  Result := (FMetafileType = MetafileTypeWmfPlaceable);
end;
{$ENDREGION 'GdiplusMetaHeader.h'}

{$REGION 'GdiplusColorMatrix.h'}
procedure TGPColorMatrix.SetToIdentity;
begin
  FillChar(M, SizeOf(M), 0);
  M[0,0] := 1;
  M[1,1] := 1;
  M[2,2] := 1;
  M[3,3] := 1;
  M[4,4] := 1;
end;
{$ENDREGION 'GdiplusColorMatrix.h'}

{$REGION 'GdiplusEffects.h'}
{$IF (GDIPVER >= $0110)}

{ TGPEffect }

destructor TGPEffect.Destroy;
begin
  ReleaseAuxData;

  // Release the native Effect.
  GdipCheck(GdipDeleteEffect(FNativeHandle));
  inherited;
end;

function TGPEffect.GetAuxData: Pointer;
begin
  Result := FAuxData;
end;

function TGPEffect.GetAuxDataSize: Integer;
begin
  Result := FAuxDataSize;
end;

procedure TGPEffect.GetParameters(var Size: Cardinal; Params: Pointer);
begin
  GdipCheck(GdipGetEffectParameters(FNativeHandle, Size, Params));
end;

function TGPEffect.GetParameterSize: Cardinal;
begin
  GdipCheck(GdipGetEffectParameterSize(FNativeHandle, Result));
end;

function TGPEffect.GetUseAuxData: Boolean;
begin
  Result := FUseAuxData;
end;

procedure TGPEffect.ReleaseAuxData;
begin
  // pvData is allocated by ApplyEffect. Return the pointer so that
  // it can be freed by the appropriate memory manager.
  GdipFree(FAuxData);
  FAuxData := nil;
  FAuxDataSize := 0;
end;

procedure TGPEffect.SetAuxData(const Data: Pointer; const Size: Integer);
begin
  ReleaseAuxData;
  FAuxData := Data;
  FAuxDataSize := Size;
end;

procedure TGPEffect.SetParameters(const Params: Pointer; const Size: Cardinal);
begin
  GdipCheck(GdipSetEffectParameters(FNativeHandle, Params, Size));
end;

procedure TGPEffect.SetUseAuxData(const Value: Boolean);
begin
  FUseAuxData := Value;
end;

{ TGPBlur }

constructor TGPBlur.Create;
begin
  inherited Create;
  GdipCheck(GdipCreateEffect(BlurEffectGuid, FNativeHandle));
end;

function TGPBlur.GetParameters: TGPBlurParams;
var
  Size: Cardinal;
begin
  Size := SizeOf(Result);
  inherited GetParameters(Size, @Result);
end;

procedure TGPBlur.SetParameters(const Value: TGPBlurParams);
begin
  inherited SetParameters(@Value, SizeOf(Value));
end;

{ TGPSharpen }

constructor TGPSharpen.Create;
begin
  inherited Create;
  GdipCheck(GdipCreateEffect(SharpenEffectGuid, FNativeHandle));
end;

function TGPSharpen.GetParameters: TGPSharpenParams;
var
  Size: Cardinal;
begin
  Size := SizeOf(Result);
  inherited GetParameters(Size, @Result);
end;

procedure TGPSharpen.SetParameters(const Value: TGPSharpenParams);
begin
  inherited SetParameters(@Value, SizeOf(Value));
end;

{ TGPRedEyeCorrection }

constructor TGPRedEyeCorrection.Create;
begin
  inherited Create;
  GdipCheck(GdipCreateEffect(RedEyeCorrectionEffectGuid, FNativeHandle));
end;

function TGPRedEyeCorrection.GetParameters: TGPRedEyeCorrectionParams;
var
  Size: Cardinal;
begin
  Size := SizeOf(Result);
  inherited GetParameters(Size, @Result);
end;

procedure TGPRedEyeCorrection.SetParameters(const Value: TGPRedEyeCorrectionParams);
begin
  inherited SetParameters(@Value, SizeOf(Value)
    + (Value.NumberOfAreas * SizeOf(Windows.TRect)));
end;

{ TGPBrightnessContrast }

constructor TGPBrightnessContrast.Create;
begin
  inherited Create;
  GdipCheck(GdipCreateEffect(BrightnessContrastEffectGuid, FNativeHandle));
end;

function TGPBrightnessContrast.GetParameters: TGPBrightnessContrastParams;
var
  Size: Cardinal;
begin
  Size := SizeOf(Result);
  inherited GetParameters(Size, @Result);
end;

procedure TGPBrightnessContrast.SetParameters(
  const Value: TGPBrightnessContrastParams);
begin
  inherited SetParameters(@Value, SizeOf(Value));
end;

{ TGPHueSaturationLightness }

constructor TGPHueSaturationLightness.Create;
begin
  inherited Create;
  GdipCheck(GdipCreateEffect(HueSaturationLightnessEffectGuid, FNativeHandle));
end;

function TGPHueSaturationLightness.GetParameters: TGPHueSaturationLightnessParams;
var
  Size: Cardinal;
begin
  Size := SizeOf(Result);
  inherited GetParameters(Size, @Result);
end;

procedure TGPHueSaturationLightness.SetParameters(
  const Value: TGPHueSaturationLightnessParams);
begin
  inherited SetParameters(@Value, SizeOf(Value));
end;

{ TGPLevels }

constructor TGPLevels.Create;
begin
  inherited Create;
  GdipCheck(GdipCreateEffect(LevelsEffectGuid, FNativeHandle));
end;

function TGPLevels.GetParameters: TGPLevelsParams;
var
  Size: Cardinal;
begin
  Size := SizeOf(Result);
  inherited GetParameters(Size, @Result);
end;

procedure TGPLevels.SetParameters(const Value: TGPLevelsParams);
begin
  inherited SetParameters(@Value, SizeOf(Value));
end;

{ TGPTint }

constructor TGPTint.Create;
begin
  inherited Create;
  GdipCheck(GdipCreateEffect(TintEffectGuid, FNativeHandle));
end;

function TGPTint.GetParameters: TGPTintParams;
var
  Size: Cardinal;
begin
  Size := SizeOf(Result);
  inherited GetParameters(Size, @Result);
end;

procedure TGPTint.SetParameters(const Value: TGPTintParams);
begin
  inherited SetParameters(@Value, SizeOf(Value));
end;

{ TGPColorBalance }

constructor TGPColorBalance.Create;
begin
  inherited Create;
  GdipCheck(GdipCreateEffect(ColorBalanceEffectGuid, FNativeHandle));
end;

function TGPColorBalance.GetParameters: TGPColorBalanceParams;
var
  Size: Cardinal;
begin
  Size := SizeOf(Result);
  inherited GetParameters(Size, @Result);
end;

procedure TGPColorBalance.SetParameters(const Value: TGPColorBalanceParams);
begin
  inherited SetParameters(@Value, SizeOf(Value));
end;

{ TGPColorMatrixEffect }

constructor TGPColorMatrixEffect.Create;
begin
  inherited Create;
  GdipCheck(GdipCreateEffect(ColorMatrixEffectGuid, FNativeHandle));
end;

function TGPColorMatrixEffect.GetParameters: TGPColorMatrix;
var
  Size: Cardinal;
begin
  Size := SizeOf(Result);
  inherited GetParameters(Size, @Result);
end;

procedure TGPColorMatrixEffect.SetParameters(const Value: TGPColorMatrix);
begin
  inherited SetParameters(@Value, SizeOf(Value));
end;

{ TGPColorLUT }

constructor TGPColorLUT.Create;
begin
  inherited Create;
  GdipCheck(GdipCreateEffect(ColorLUTEffectGuid, FNativeHandle));
end;

function TGPColorLUT.GetParameters: TGPColorLUTParams;
var
  Size: Cardinal;
begin
  Size := SizeOf(Result);
  inherited GetParameters(Size, @Result);
end;

procedure TGPColorLUT.SetParameters(const Value: TGPColorLUTParams);
begin
  inherited SetParameters(@Value, SizeOf(Value));
end;

{ TGPColorCurve }

constructor TGPColorCurve.Create;
begin
  inherited Create;
  GdipCheck(GdipCreateEffect(ColorCurveEffectGuid, FNativeHandle));
end;

function TGPColorCurve.GetParameters: TGPColorCurveParams;
var
  Size: Cardinal;
begin
  Size := SizeOf(Result);
  inherited GetParameters(Size, @Result);
end;

procedure TGPColorCurve.SetParameters(const Value: TGPColorCurveParams);
begin
  inherited SetParameters(@Value, SizeOf(Value));
end;

{$IFEND}
{$ENDREGION 'GdiplusEffects.h'}

{$REGION 'GdiplusRegion.h'}

{ TGPRegion }

function TGPRegion.Clone: IGPRegion;
var
  NativeClone: GpRegion;
begin
  NativeClone := nil;
  GdipCheck(GdipCloneRegion(FNativeHandle, NativeClone));
  Result := TGPRegion.Create(NativeClone);
end;

constructor TGPRegion.Create(const NativeRegion: GpRegion);
begin
  inherited Create;
  FNativeHandle := NativeRegion;
end;

constructor TGPRegion.Create(const Path: IGPGraphicsPath);
begin
  inherited Create;
  GdipCheck(GdipCreateRegionPath(Path.NativeHandle, FNativeHandle));
end;

constructor TGPRegion.Create(const Rect: TGPRect);
begin
  inherited Create;
  GdipCheck(GdipCreateRegionRectI(@Rect, FNativeHandle));
end;

constructor TGPRegion.Create(const HRgn: HRGN);
begin
  inherited Create;
  GdipCheck(GdipCreateRegionHrgn(HRgn, FNativeHandle));
end;

constructor TGPRegion.Create(const RegionData: PByte; const Size: Integer);
begin
  inherited Create;
  GdipCheck(GdipCreateRegionRgnData(RegionData, Size, FNativeHandle));
end;

constructor TGPRegion.Create;
begin
  inherited Create;
  GdipCheck(GdipCreateRegion(FNativeHandle));
end;

constructor TGPRegion.Create(const Rect: TGPRectF);
begin
  inherited Create;
  GdipCheck(GdipCreateRegionRect(@Rect, FNativeHandle));
end;

procedure TGPRegion.Complement(const Rect: TGPRectF);
begin
  GdipCheck(GdipCombineRegionRect(FNativeHandle, @Rect, CombineModeComplement));
end;

procedure TGPRegion.Complement(const Rect: TGPRect);
begin
  GdipCheck(GdipCombineRegionRectI(FNativeHandle, @Rect, CombineModeComplement));
end;

procedure TGPRegion.Complement(const Path: IGPGraphicsPath);
begin
  GdipCheck(GdipCombineRegionRect(FNativeHandle, Path.NativeHandle, CombineModeComplement));
end;

procedure TGPRegion.Complement(const Region: IGPRegion);
begin
  GdipCheck(GdipCombineRegionRect(FNativeHandle, Region.NativeHandle, CombineModeComplement));
end;

destructor TGPRegion.Destroy;
begin
  GdipDeleteRegion(FNativeHandle);
  inherited;
end;

function TGPRegion.Equals(const Region: IGPRegion; const G: IGPGraphics): Boolean;
var
  B: Bool;
begin
  B := False;
  GdipCheck(GdipIsEqualRegion(FNativeHandle, Region.NativeHandle, G.NativeHandle, B));
  Result := B;
end;

procedure TGPRegion.ExclusiveOr(const Rect: TGPRectF);
begin
  GdipCheck(GdipCombineRegionRect(FNativeHandle, @Rect, CombineModeXor));
end;

procedure TGPRegion.ExclusiveOr(const Rect: TGPRect);
begin
  GdipCheck(GdipCombineRegionRectI(FNativeHandle, @Rect, CombineModeXor));
end;

procedure TGPRegion.Exclude(const Rect: TGPRectF);
begin
  GdipCheck(GdipCombineRegionRect(FNativeHandle, @Rect, CombineModeExclude));
end;

procedure TGPRegion.Exclude(const Rect: TGPRect);
begin
  GdipCheck(GdipCombineRegionRectI(FNativeHandle, @Rect, CombineModeExclude));
end;

procedure TGPRegion.Exclude(const Region: IGPRegion);
begin
  GdipCheck(GdipCombineRegionRegion(FNativeHandle, Region.NativeHandle, CombineModeExclude));
end;

procedure TGPRegion.Exclude(const Path: IGPGraphicsPath);
begin
  GdipCheck(GdipCombineRegionPath(FNativeHandle, Path.NativeHandle, CombineModeExclude));
end;

procedure TGPRegion.ExclusiveOr(const Region: IGPRegion);
begin
  GdipCheck(GdipCombineRegionRegion(FNativeHandle, Region.NativeHandle, CombineModeXor));
end;

procedure TGPRegion.ExclusiveOr(const Path: IGPGraphicsPath);
begin
  GdipCheck(GdipCombineRegionPath(FNativeHandle, Path.NativeHandle, CombineModeXor));
end;

class function TGPRegion.FromHRGN(const HRgn: HRGN): IGPRegion;
var
  NativeRegion: GpRegion;
begin
  NativeRegion := nil;
  if (GdipCreateRegionHrgn(HRgn, NativeRegion) = Ok) then
    Result := TGPRegion.Create(NativeRegion)
  else
    Result := nil;
end;

procedure TGPRegion.GetBounds(out Rect: TGPRectF; const G: IGPGraphics);
begin
  GdipCheck(GdipGetRegionBounds(FNativeHandle, G.NativeHandle, Rect));
end;

procedure TGPRegion.GetBounds(out Rect: TGPRect; const G: IGPGraphics);
begin
  GdipCheck(GdipGetRegionBoundsI(FNativeHandle, G.NativeHandle, Rect));
end;

function TGPRegion.GetData: IGPRegionData;
var
  Data: Pointer;
  Size: Cardinal;
begin
  Data := nil;
  Size := 0;
  GdipCheck(GdipGetRegionDataSize(FNativeHandle, Size));
  if (Size > 0) then
  begin
    GetMem(Data, Size);
    GdipCheck(GdipGetRegionData(FNativeHandle, Data, Size, nil));
  end;
  Result := TGPBuffer.Create(Data, Size);
end;

function TGPRegion.GetHRGN(const G: IGPGraphics): HRGN;
begin
  GdipCheck(GdipGetRegionHRgn(FNativeHandle, G.NativeHandle, Result));
end;

function TGPRegion.GetRegionScans(const Matrix: IGPMatrix): IGPRegionScansF;
var
  Count: Integer;
begin
  Count := 0;
  GdipCheck(GdipGetRegionScansCount(FNativeHandle, Count, Matrix.NativeHandle));
  Result := TGPArray<TGPRectF>.Create(Count);
  if (Count > 0) then
    GdipCheck(GdipGetRegionScans(FNativeHandle, Result.ItemPtr, Count, Matrix.NativeHandle));
end;

function TGPRegion.GetRegionScansI(const Matrix: IGPMatrix): IGPRegionScans;
var
  Count: Integer;
begin
  Count := 0;
  GdipCheck(GdipGetRegionScansCount(FNativeHandle, Count, Matrix.NativeHandle));
  Result := TGPArray<TGPRect>.Create(Count);
  if (Count > 0) then
    GdipCheck(GdipGetRegionScansI(FNativeHandle, Result.ItemPtr, Count, Matrix.NativeHandle));
end;

procedure TGPRegion.Intersect(const Rect: TGPRectF);
begin
  GdipCheck(GdipCombineRegionRect(FNativeHandle, @Rect, CombineModeIntersect));
end;

procedure TGPRegion.Intersect(const Path: IGPGraphicsPath);
begin
  GdipCheck(GdipCombineRegionPath(FNativeHandle, Path.NativeHandle, CombineModeIntersect));
end;

procedure TGPRegion.Intersect(const Region: IGPRegion);
begin
  GdipCheck(GdipCombineRegionRegion(FNativeHandle, Region.NativeHandle, CombineModeIntersect));
end;

procedure TGPRegion.Intersect(const Rect: TGPRect);
begin
  GdipCheck(GdipCombineRegionRectI(FNativeHandle, @Rect, CombineModeIntersect));
end;

function TGPRegion.IsEmpty(const G: IGPGraphics): Boolean;
var
  B: Bool;
begin
  B := False;
  GdipCheck(GdipIsEmptyRegion(FNativeHandle, G.NativeHandle, B));
  Result := B;
end;

function TGPRegion.IsInfinite(const G: IGPGraphics): Boolean;
var
  B: Bool;
begin
  B := False;
  GdipCheck(GdipIsInfiniteRegion(FNativeHandle, G.NativeHandle, B));
  Result := B;
end;

function TGPRegion.IsVisible(const Rect: TGPRect; const G: IGPGraphics): Boolean;
var
  B: Bool;
begin
  B := False;
  GdipCheck(GdipIsVisibleRegionRectI(FNativeHandle, Rect.X, Rect.Y,
    Rect.Width, Rect.Height, GdipHandle(G), B));
  Result := B;
end;

function TGPRegion.IsVisible(const X, Y, Width, Height: Integer;
  const G: IGPGraphics): Boolean;
begin
  Result := IsVisible(TGPRect.Create(X, Y, Width, Height), G);
end;

function TGPRegion.IsVisible(const Rect: TGPRectF; const G: IGPGraphics): Boolean;
var
  B: Bool;
begin
  B := False;
  GdipCheck(GdipIsVisibleRegionRect(FNativeHandle, Rect.X, Rect.Y,
    Rect.Width, Rect.Height, GdipHandle(G), B));
  Result := B;
end;

function TGPRegion.IsVisible(const X, Y, Width, Height: Single;
  const G: IGPGraphics): Boolean;
begin
  Result := IsVisible(TGPRectF.Create(X, Y, Width, Height), G);
end;

function TGPRegion.IsVisible(const Point: TGPPoint; const G: IGPGraphics): Boolean;
var
  B: Bool;
begin
  B := False;
  GdipCheck(GdipIsVisibleRegionPointI(FNativeHandle, Point.X, Point.Y, GdipHandle(G), B));
  Result := B;
end;

function TGPRegion.IsVisible(const X, Y: Integer; const G: IGPGraphics): Boolean;
begin
  Result := IsVisible(TGPPoint.Create(X, Y), G);
end;

function TGPRegion.IsVisible(const Point: TGPPointF; const G: IGPGraphics): Boolean;
var
  B: Bool;
begin
  B := False;
  GdipCheck(GdipIsVisibleRegionPoint(FNativeHandle, Point.X, Point.Y, GdipHandle(G), B));
  Result := B;
end;

function TGPRegion.IsVisible(const X, Y: Single; const G: IGPGraphics): Boolean;
begin
  Result := IsVisible(TGPPointF.Create(X, Y), G);
end;

procedure TGPRegion.MakeEmpty;
begin
  GdipCheck(GdipSetEmpty(FNativeHandle));
end;

procedure TGPRegion.MakeInfinite;
begin
  GdipCheck(GdipSetInfinite(FNativeHandle));
end;

procedure TGPRegion.Transform(const Matrix: IGPMatrix);
begin
  GdipCheck(GdipTransformRegion(FNativeHandle, Matrix.NativeHandle));
end;

procedure TGPRegion.Translate(const DX, DY: Single);
begin
  GdipCheck(GdipTranslateRegion(FNativeHandle, DX, DY));
end;

procedure TGPRegion.Translate(const DX, DY: Integer);
begin
  GdipCheck(GdipTranslateRegionI(FNativeHandle, DX, DY));
end;

procedure TGPRegion.Union(const Rect: TGPRect);
begin
  GdipCheck(GdipCombineRegionRectI(FNativeHandle, @Rect, CombineModeUnion));
end;

procedure TGPRegion.Union(const Rect: TGPRectF);
begin
  GdipCheck(GdipCombineRegionRect(FNativeHandle, @Rect, CombineModeUnion));
end;

procedure TGPRegion.Union(const Path: IGPGraphicsPath);
begin
  GdipCheck(GdipCombineRegionPath(FNativeHandle, Path.NativeHandle, CombineModeUnion));
end;

procedure TGPRegion.Union(const Region: IGPRegion);
begin
  GdipCheck(GdipCombineRegionRegion(FNativeHandle, Region.NativeHandle, CombineModeUnion));
end;
{$ENDREGION 'GdiplusRegion.h'}

{$REGION 'GdiplusFontFamily.h'}
{ TGPFontFamily }

function TGPFontFamily.Clone: IGPFontFamily;
var
  ClonedFamily: GpFontFamily;
begin
  ClonedFamily := nil;
  GdipCheck(GdipCloneFontFamily(FNativeHandle, ClonedFamily));
  Result := TGPFontFamily.Create(ClonedFamily);
end;

constructor TGPFontFamily.Create(const NativeFamily: GpFontFamily);
begin
  inherited Create;
  FNativeHandle := NativeFamily;
end;

constructor TGPFontFamily.Create;
begin
  inherited Create;
end;

constructor TGPFontFamily.Create(const Name: String;
  const FontCollection: IGPFontCollection);
begin
  inherited Create;
  GdipCheck(GdipCreateFontFamilyFromName(PWideChar(Name), GdipHandle(FontCollection), FNativeHandle));
end;

destructor TGPFontFamily.Destroy;
begin
  GdipDeleteFontFamily(FNativeHandle);
  inherited;
end;

class function TGPFontFamily.GenericMonospace: IGPFontFamily;
var
  NativeFamily: GpFontFamily;
begin
  if (FGenericMonospaceFontFamily = nil) then
  begin
    GdipCheck(GdipGetGenericFontFamilyMonospace(NativeFamily));
    FGenericMonospaceFontFamily := TGPFontFamily.Create(NativeFamily);
  end;
  Result := FGenericMonospaceFontFamily;
end;

class function TGPFontFamily.GenericSansSerif: IGPFontFamily;
var
  NativeFamily: GpFontFamily;
begin
  if (FGenericSansSerifFontFamily = nil) then
  begin
    GdipCheck(GdipGetGenericFontFamilySansSerif(NativeFamily));
    FGenericSansSerifFontFamily := TGPFontFamily.Create(NativeFamily);
  end;
  Result := FGenericSansSerifFontFamily;
end;

class function TGPFontFamily.GenericSerif: IGPFontFamily;
var
  NativeFamily: GpFontFamily;
begin
  if (FGenericSerifFontFamily = nil) then
  begin
    GdipCheck(GdipGetGenericFontFamilySerif(NativeFamily));
    FGenericSerifFontFamily := TGPFontFamily.Create(NativeFamily);
  end;
  Result := FGenericSerifFontFamily;
end;

function TGPFontFamily.GetCellAscent(const Style: TGPFontStyle): Word;
begin
  GdipCheck(GdipGetCellAscent(FNativeHandle, Style, Result));
end;

function TGPFontFamily.GetCellDescent(const Style: TGPFontStyle): Word;
begin
  GdipCheck(GdipGetCellDescent(FNativeHandle, Style, Result));
end;

function TGPFontFamily.GetEmHeight(const Style: TGPFontStyle): Word;
begin
  GdipCheck(GdipGetEmHeight(FNativeHandle, Style, Result));
end;

function TGPFontFamily.GetFamilyName(const Language: LangID = 0): String;
var
  Name: array [0..LF_FACESIZE - 1] of WideChar;
begin
  GdipCheck(GdipGetFamilyName(FNativeHandle, Name, Language));
  Result := Name;
end;

function TGPFontFamily.GetFamilyNameInternal: String;
begin
  Result := GetFamilyName(0);
end;

function TGPFontFamily.GetLineSpacing(const Style: TGPFontStyle): Word;
begin
  GdipCheck(GdipGetLineSpacing(FNativeHandle, Style, Result));
end;

function TGPFontFamily.IsAvailable: Boolean;
begin
  Result := Assigned(FNativeHandle);
end;

function TGPFontFamily.IsStyleAvailable(const Style: TGPFontStyle): Boolean;
var
  B: Bool;
begin
  if (GdipIsStyleAvailable(FNativeHandle, Style, B) <> Ok) then
    Result := False
  else
    Result := B;
end;
{$ENDREGION 'GdiplusFontFamily.h'}

{$REGION 'GdiplusFont.h'}

{ TGPFont }

function TGPFont.Clone: IGPFont;
var
  NativeClone: GpFont;
begin
  NativeClone := nil;
  GdipCheck(GdipCloneFont(FNativeHandle, NativeClone));
  Result := TGPFont.Create(NativeClone);
end;

constructor TGPFont.Create(const DC: HDC; const LogFont: TLogFontA);
begin
  GdipCheck(GdipCreateFontFromLogfontA(DC, @LogFont, FNativeHandle))
end;

constructor TGPFont.Create(const DC: HDC);
begin
  inherited Create;
  GdipCheck(GdipCreateFontFromDC(DC, FNativeHandle));
end;

constructor TGPFont.Create(const NativeFont: GpFont);
begin
  inherited Create;
  FNativeHandle := NativeFont;
end;

constructor TGPFont.Create(const Family: IGPFontFamily; const EmSize: Single;
  const Style: TGPFontStyle; const MeasureUnit: TGPUnit);
begin
  inherited Create;
  GdipCheck(GdipCreateFont(GdipHandle(Family), EmSize, Style, MeasureUnit, FNativeHandle))
end;

constructor TGPFont.Create(const FamilyName: String; const EmSize: Single;
  const Style: TGPFontStyle; const MeasureUnit: TGPUnit;
  const FontCollection: IGPFontCollection);
var
  Family: IGPFontFamily;
  NativeFamily: GpFontFamily;
begin
  inherited Create;
  try
    Family := TGPFontFamily.Create(FamilyName, FontCollection);
    NativeFamily := Family.NativeHandle;
  except
    NativeFamily := TGPFontFamily.GenericSansSerif.NativeHandle;
  end;
  GdipCheck(GdipCreateFont(NativeFamily, EmSize, Style, MeasureUnit, FNativeHandle))
end;

constructor TGPFont.Create(const DC: HDC; const LogFont: TLogFontW);
begin
  inherited Create;
  GdipCheck(GdipCreateFontFromLogfontW(DC, @LogFont, FNativeHandle))
end;

constructor TGPFont.Create(const DC: HDC; const FontHandle: HFont);
var
  LogFont: TLogFontA;
begin
  inherited Create;
  if (FontHandle <> 0) then
  begin
    if (GetObjectA(FontHandle, SizeOf(LogFont), @LogFont) <> 0) then
      GdipCheck(GdipCreateFontFromLogfontA(DC, @LogFont, FNativeHandle))
    else
      GdipCheck(GdipCreateFontFromDC(DC, FNativeHandle));
  end
  else
    GdipCheck(GdipCreateFontFromDC(DC, FNativeHandle));
end;

destructor TGPFont.Destroy;
begin
  GdipDeleteFont(FNativeHandle);
  inherited;
end;

function TGPFont.GetFamily: IGPFontFamily;
var
  NativeFamily: GpFontFamily;
begin
  GdipCheck(GdipGetFamily(FNativeHandle, NativeFamily));
  Result := TGPFontFamily.Create(NativeFamily);
end;

function TGPFont.GetHeight(const Dpi: Single): Single;
begin
  GdipCheck(GdipGetFontHeightGivenDPI(FNativeHandle, Dpi, Result));
end;

function TGPFont.GetHeight(const Graphics: IGPGraphics): Single;
begin
  GdipCheck(GdipGetFontHeight(FNativeHandle, GdipHandle(Graphics), Result));
end;

function TGPFont.GetLogFontA(const G: IGPGraphics): TLogFontA;
begin
  GdipCheck(GdipGetLogFontA(FNativeHandle, GdipHandle(G), Result));
end;

function TGPFont.GetLogFontW(const G: IGPGraphics): TLogFontW;
begin
  GdipCheck(GdipGetLogFontW(FNativeHandle, GdipHandle(G), Result));
end;

function TGPFont.GetSize: Single;
begin
  GdipCheck(GdipGetFontSize(FNativeHandle, Result));
end;

function TGPFont.GetStyle: TGPFontStyle;
begin
  GdipCheck(GdipGetFontStyle(FNativeHandle, Result));
end;

function TGPFont.GetUnit: TGPUnit;
begin
  GdipCheck(GdipGetFontUnit(FNativeHandle, Result));
end;

function TGPFont.IsAvailable: Boolean;
begin
  Result := Assigned(FNativeHandle);
end;
{$ENDREGION 'GdiplusFont.h'}

{$REGION 'GdiplusFontCollection.h'}

{ TGPFontCollection }

constructor TGPFontCollection.Create;
begin
  inherited Create;
  FNativeHandle := nil;
end;

function TGPFontCollection.GetFamilies: IGPFontFamilies;
var
  NativeFamilyList: array of GpFontFamily;
  NativeClone: GpFontFamily;
  Count, ActualCount, I: Integer;
begin
  Count := 0;
  GdipCheck(GdipGetFontCollectionFamilyCount(FNativeHandle, Count));

  SetLength(NativeFamilyList, Count);
  GdipCheck(GdipGetFontCollectionFamilyList(FNativeHandle, Count,
    @NativeFamilyList[0], ActualCount));

  Result := TGPArray<IGPFontFamily>.Create(ActualCount);
  for I := 0 to ActualCount - 1 do
  begin
    GdipCheck(GdipCloneFontFamily(NativeFamilyList[I], NativeClone));
    Result[I] := TGPFontFamily.Create(NativeClone);
  end;
end;

{ TGPInstalledFontCollection }

constructor TGPInstalledFontCollection.Create;
begin
  inherited Create;
  GdipCheck(GdipNewInstalledFontCollection(FNativeHandle));
end;

{ TGPPrivateFontCollection }

procedure TGPPrivateFontCollection.AddFontFile(const Filename: String);
begin
  GdipCheck(GdipPrivateAddFontFile(FNativeHandle, PWideChar(Filename)));
end;

procedure TGPPrivateFontCollection.AddMemoryFont(const Memory: Pointer;
  const Length: Integer);
begin
  GdipCheck(GdipPrivateAddMemoryFont(FNativeHandle, Memory, Length));
end;

constructor TGPPrivateFontCollection.Create;
begin
  inherited Create;
  GdipCheck(GdipNewPrivateFontCollection(FNativeHandle));
end;

destructor TGPPrivateFontCollection.Destroy;
begin
  GdipDeletePrivateFontCollection(FNativeHandle);
  inherited;
end;
{$ENDREGION 'GdiplusFontCollection.h'}

{$REGION 'GdiplusBitmap.h'}
{ TGPImageFormat }

constructor TGPImageFormat.Create(const Guid: TGUID);
begin
  inherited Create;
  FGuid := Guid;
end;

constructor TGPImageFormat.Create(const Guid, CodecId: TGUID);
begin
  inherited Create;
  FGuid := Guid;
  FCodecId := CodecId;
end;

class function TGPImageFormat.FindByFormatId(
  const lFormatId: TGUID): IGPImageFormat;
begin
  InitializeCodecs;
  if IsEqualGUID(lFormatId, FBmp.Guid) then
    Result := FBmp
  else if IsEqualGUID(lFormatId, FGif.Guid) then
    Result := FGif
  else if IsEqualGUID(lFormatId, FJpeg.Guid) then
    Result := FJpeg
  else if IsEqualGUID(lFormatId, FPng.Guid) then
    Result := FPng
  else if IsEqualGUID(lFormatId, FTiff.Guid) then
    Result := FTiff
  else
    Result := nil;
end;

class function TGPImageFormat.GetBmp: IGPImageFormat;
begin
  InitializeCodecs;
  Result := FBmp;
end;

function TGPImageFormat.GetCodecId: TGUID;
begin
  Result := FCodecId;
end;

class function TGPImageFormat.GetGif: IGPImageFormat;
begin
  InitializeCodecs;
  Result := FGif;
end;

function TGPImageFormat.GetGuid: TGuid;
begin
  Result := FGuid;
end;

class function TGPImageFormat.GetJpeg: IGPImageFormat;
begin
  InitializeCodecs;
  Result := FJpeg;
end;

class function TGPImageFormat.GetPng: IGPImageFormat;
begin
  InitializeCodecs;
  Result := FPng;
end;

class function TGPImageFormat.GetTiff: IGPImageFormat;
begin
  InitializeCodecs;
  Result := FTiff;
end;

class procedure TGPImageFormat.InitializeCodecs;
var
  I, Count, Size: Cardinal;
  List, Info: PGPNativeImageCodecInfo;
begin
  if (not FInitialized) then
  begin
    FInitialized := True;
    GdipCheck(GdipGetImageEncodersSize(Count, Size));
    if (Size > 0) then
    begin
      GetMem(List, Size);
      try
        GdipCheck(GdipGetImageEncoders(Count, Size, List));
        Info := List;
        for I := 0 to Count - 1 do
        begin
          if IsEqualGUID(Info.FormatId, ImageFormatBMP) then
            FBmp := TGPImageFormat.Create(Info.FormatId, Info.ClsId)
          else
          if IsEqualGUID(Info.FormatId, ImageFormatJPEG) then
            FJpeg := TGPImageFormat.Create(Info.FormatId, Info.ClsId)
          else
          if IsEqualGUID(Info.FormatId, ImageFormatGIF) then
            FGif := TGPImageFormat.Create(Info.FormatId, Info.ClsId)
          else
          if IsEqualGUID(Info.FormatId, ImageFormatTIFF) then
            FTiff := TGPImageFormat.Create(Info.FormatId, Info.ClsId)
          else
          if IsEqualGUID(Info.FormatId, ImageFormatPNG) then
            FPng := TGPImageFormat.Create(Info.FormatId, Info.ClsId);
          Inc(Info);
        end;
      finally
        FreeMem(List);
      end;
    end;
    Assert(Assigned(FBmp));
    Assert(Assigned(FJpeg));
    Assert(Assigned(FGif));
    Assert(Assigned(FTiff));
    Assert(Assigned(FPng));
  end;
end;

{ TGPImageCodecInfo }

constructor TGPImageCodecInfo.Create(const Info: TGPNativeImageCodecInfo);
begin
  inherited Create;
  FInfo := Info;
end;

function TGPImageCodecInfo.GetClsId: TGUID;
begin
  Result := FInfo.ClsId;
end;

function TGPImageCodecInfo.GetCodecName: String;
begin
  Result := FInfo.CodecName;
end;

function TGPImageCodecInfo.GetDllName: String;
begin
  Result := FInfo.DllName;
end;

function TGPImageCodecInfo.GetFilenameExtension: String;
begin
  Result := FInfo.FilenameExtension;
end;

function TGPImageCodecInfo.GetFlags: TGPImageCodecFlags;
begin
  Result := FInfo.Flags;
end;

function TGPImageCodecInfo.GetFormatDescription: String;
begin
  Result := FInfo.FormatDescription;
end;

function TGPImageCodecInfo.GetFormatId: TGUID;
begin
  Result := FInfo.FormatId;
end;

class function TGPImageCodecInfo.GetImageDecoders: IGPImageCodecInfoArray;
var
  I, Count, Size: Cardinal;
  List, Info: PGPNativeImageCodecInfo;
begin
  GdipCheck(GdipGetImageDecodersSize(Count, Size));
  if (Count > 0) then
  begin
    Result := TGPArray<IGPImageCodecInfo>.Create(Count);
    GetMem(List, Size);
    try
      GdipCheck(GdipGetImageDecoders(Count, Size, List));
      Info := List;
      for I := 0 to Count - 1 do
      begin
        Result[I] := TGPImageCodecInfo.Create(Info^);
        Inc(Info);
      end;
    finally
      FreeMem(List);
    end;
  end
  else
    Result := nil;
end;

class function TGPImageCodecInfo.GetImageEncoders: IGPImageCodecInfoArray;
var
  I, Count, Size: Cardinal;
  List, Info: PGPNativeImageCodecInfo;
begin
  GdipCheck(GdipGetImageEncodersSize(Count, Size));
  if (Count > 0) then
  begin
    Result := TGPArray<IGPImageCodecInfo>.Create(Count);
    GetMem(List, Size);
    try
      GdipCheck(GdipGetImageEncoders(Count, Size, List));
      Info := List;
      for I := 0 to Count - 1 do
      begin
        Result[I] := TGPImageCodecInfo.Create(Info^);
        Inc(Info);
      end;
    finally
      FreeMem(List);
    end;
  end
  else
    Result := nil;
end;

function TGPImageCodecInfo.GetMimeType: String;
begin
  Result := FInfo.MimeType;
end;

function TGPImageCodecInfo.GetVersion: Integer;
begin
  Result := FInfo.Version;
end;

{ TGPEncoderParameterEnumerator }

constructor TGPEncoderParameterEnumerator.Create(
  const AParams: IGPEncoderParameters);
begin
  inherited Create;
  FParams := AParams;
  FIndex := -1;
end;

function TGPEncoderParameterEnumerator.GetCurrent: PGPNativeEncoderParameter;
begin
  Result := FParams.Param[FIndex];
end;

function TGPEncoderParameterEnumerator.MoveNext: Boolean;
begin
  Result := (FIndex < FParams.Count - 1);
  if Result then
    Inc(FIndex);
end;

{ TGPEncoderParameters }

procedure TGPEncoderParameters.Add(const ParamType: TGUID; var Value: Int64);
var
  Value32: Int32;
begin
  Value32 := Value;
  Add(ParamType, 1, EncoderParameterValueTypeLong, @Value32);
end;

procedure TGPEncoderParameters.Add(const ParamType: TGUID;
  const Value: array of Int32);
begin
  Assert(Length(Value) > 0);
  Add(ParamType, Length(Value), EncoderParameterValueTypeLong, @Value[0]);
end;

procedure TGPEncoderParameters.Add(const ParamType: TGUID; const Value: String);
var
  AnsiValue: AnsiString;
begin
  {$WARNINGS OFF}
  AnsiValue := AnsiString(Value);
  {$WARNINGS ON}
  Assert(Length(AnsiValue) > 0);
  Add(ParamType, Length(AnsiValue) + 1, EncoderParameterValueTypeASCII, @AnsiValue[1]);
end;

procedure TGPEncoderParameters.Add(const ParamType: TGUID;
  const Value: array of Int64);
var
  Value32: array of Int32;
  I: Integer;
begin
  Assert(Length(Value) > 0);
  SetLength(Value32, Length(Value));
  for I := 0 to Length(Value) - 1 do
    Value32[I] := Value[I];
  Add(ParamType, Length(Value), EncoderParameterValueTypeLong, @Value32[0]);
end;

procedure TGPEncoderParameters.Add(const ParamType: TGUID; var Value: Int32);
begin
  Add(ParamType, 1, EncoderParameterValueTypeLong, @Value);
end;

procedure TGPEncoderParameters.Add(const ParamType: TGUID;
  const Value: array of Byte);
begin
  Assert(Length(Value) > 0);
  Add(ParamType, Length(Value), EncoderParameterValueTypeByte, @Value[0]);
end;

procedure TGPEncoderParameters.Add(const ParamType: TGUID; var Value: Byte);
begin
  Add(ParamType, 1, EncoderParameterValueTypeByte, @Value);
end;

procedure TGPEncoderParameters.Add(const ParamType: TGUID;
  const Value: array of Int16);
begin
  Assert(Length(Value) > 0);
  Add(ParamType, Length(Value), EncoderParameterValueTypeShort, @Value[0]);
end;

procedure TGPEncoderParameters.Add(const ParamType: TGUID; var Value: Int16);
begin
  Add(ParamType, 1, EncoderParameterValueTypeShort, @Value);
end;

procedure TGPEncoderParameters.Add(const ParamType: TGUID;
  const NumberOfValues: Integer; const ValueType: TGPEncoderParameterValueType;
  const Value: Pointer);
var
  ValueSize: Integer;
  ValuePtr: PByte;
begin
  FModified := True;
  if (FParamCount >= Length(FParams)) then
    SetLength(FParams, FParamCount + 4);

  case ValueType of
    EncoderParameterValueTypeByte,
    EncoderParameterValueTypeASCII,
    EncoderParameterValueTypeUndefined:
      ValueSize := 1;
    EncoderParameterValueTypeShort:
      ValueSize := 2;
    EncoderParameterValueTypeLong:
      ValueSize := 4;
    EncoderParameterValueTypeRational,
    EncoderParameterValueTypeLongRange:
      ValueSize := 8;
    EncoderParameterValueTypeRationalRange:
      ValueSize := 16;

    {$IF (GDIPVER >= $0110)}
    EncoderParameterValueTypePointer:
      ValueSize := 1;
    {$IFEND}
  else
    begin
      ValueSize := 1;
      Assert(False);
    end;
  end;
  ValueSize := ValueSize * NumberOfValues;
  if ((FValueSize + ValueSize) > FValueAllocated) then
  begin
    FValueAllocated := FValueSize + ValueSize + 64;
    ReallocMem(FValues, FValueAllocated);
  end;
  ValuePtr := FValues;
  Inc(ValuePtr, FValueSize);
  Inc(FValueSize, ValueSize);
  Move(Value^, ValuePtr^, ValueSize);

  FParams[FParamCount].Guid := ParamType;
  FParams[FParamCount].NumberOfValues := NumberOfValues;
  FParams[FParamCount].ValueType := ValueType;
  FParams[FParamCount].Value := ValuePtr;

  Inc(FParamCount);
end;

procedure TGPEncoderParameters.Add(const ParamType: TGUID; const RangesBegin,
  RangesEnd: array of Int64);
var
  Ranges: array of Int32;
  I: Integer;
begin
  Assert(Length(RangesBegin) > 0);
  Assert(Length(RangesBegin) = Length(RangesEnd));
  SetLength(Ranges, Length(RangesBegin) * 2);
  for I := 0 to Length(RangesBegin) - 1 do
  begin
    Ranges[I * 2 + 0] := RangesBegin[I];
    Ranges[I * 2 + 1] := RangesEnd[I];
  end;
  Add(ParamType, Length(RangesBegin), EncoderParameterValueTypeLongRange, @Ranges[0]);
end;

procedure TGPEncoderParameters.Add(const ParamType: TGUID; const Numerator1,
  Denominator1, Numerator2, Denominator2: array of Int32);
var
  Values: array of Int32;
  I: Integer;
begin
  Assert(Length(Numerator1) > 0);
  Assert(Length(Numerator1) = Length(Numerator2));
  Assert(Length(Numerator1) = Length(Denominator1));
  Assert(Length(Numerator1) = Length(Denominator2));
  SetLength(Values, Length(Numerator1) * 4);
  for I := 0 to Length(Numerator1) - 1 do
  begin
    Values[I * 4 + 0] := Numerator1[I];
    Values[I * 4 + 1] := Denominator1[I];
    Values[I * 4 + 2] := Numerator2[I];
    Values[I * 4 + 3] := Denominator2[I];
  end;
  Add(ParamType, Length(Numerator1), EncoderParameterValueTypeRationalRange, @Values[0]);
end;

procedure TGPEncoderParameters.Add(const ParamType: TGUID;
  const Value: array of TGPEncoderValue);
begin
  Assert(Length(Value) > 0);
  Add(ParamType, Length(Value), EncoderParameterValueTypeLong, @Value[0]);
end;

procedure TGPEncoderParameters.Add(const ParamType: TGUID;
  const Value: TGPEncoderValue);
begin
  Add(ParamType, 1, EncoderParameterValueTypeLong, @Value);
end;

procedure TGPEncoderParameters.Clear;
begin
  FParamCount := 0;
  FValueSize := 0;
  FModified := True;
end;

constructor TGPEncoderParameters.Create;
begin
  inherited Create;
end;

constructor TGPEncoderParameters.Create(const Params: PGPNativeEncoderParameters);
var
  Param: PGPNativeEncoderParameter;
  I: Integer;
begin
  inherited Create;
  if Assigned(Params) then
  begin
    SetLength(FParams, Params.Count);
    if (Params.Count > 0) then
    begin
      Param := @Params.Parameter[0];
      for I := 0 to Params.Count - 1 do
      begin
        Add(Param.Guid, Param.NumberOfValues, Param.ValueType, Param.Value);
        Inc(Param);
      end;
    end;
  end;
end;

procedure TGPEncoderParameters.Add(const ParamType: TGUID; const Numerator1,
  Denominator1, Numerator2, Denominator2: Int32);
var
  Values: array [0..3] of Int32;
begin
  Values[0] := Numerator1;
  Values[1] := Denominator1;
  Values[2] := Numerator2;
  Values[3] := Denominator2;
  Add(ParamType, 1, EncoderParameterValueTypeRationalRange, @Values[0]);
end;

procedure TGPEncoderParameters.Add(const ParamType: TGUID; var RangeBegin,
  RangeEnd: Int64);
var
  Values: array [0..1] of Int32;
begin
  Values[0] := RangeBegin;
  Values[1] := RangeEnd;
  Add(ParamType, 1, EncoderParameterValueTypeLongRange, @Values[0]);
end;

procedure TGPEncoderParameters.Add(const ParamType: TGUID;
  const Value: array of Byte; const Undefined: Boolean);
begin
  Assert(Length(Value) > 0);
  if (Undefined) then
    Add(ParamType, Length(Value), EncoderParameterValueTypeUndefined, @Value[0])
  else
    Add(ParamType, Length(Value), EncoderParameterValueTypeByte, @Value[0]);
end;

procedure TGPEncoderParameters.Add(const ParamType: TGUID; const Value: Byte;
  const Undefined: Boolean);
begin
  if (Undefined) then
    Add(ParamType, 1, EncoderParameterValueTypeUndefined, @Value)
  else
    Add(ParamType, 1, EncoderParameterValueTypeByte, @Value);
end;

procedure TGPEncoderParameters.Add(const ParamType: TGUID; const Numerators,
  Denominators: array of Int32);
var
  Values: array of Int32;
  I: Integer;
begin
  Assert(Length(Numerators) > 0);
  Assert(Length(Numerators) = Length(Denominators));
  SetLength(Values, Length(Numerators) * 2);
  for I := 0 to Length(Numerators) - 1 do
  begin
    Values[I * 2 + 0] := Numerators[I];
    Values[I * 2 + 1] := Denominators[I];
  end;
  Add(ParamType, Length(Numerators), EncoderParameterValueTypeRational, @Values[0]);
end;

procedure TGPEncoderParameters.Add(const ParamType: TGUID; var Numerator,
  Denominator: Int32);
var
  Values: array [0..1] of Int32;
begin
  Values[0] := Numerator;
  Values[1] := Denominator;
  Add(ParamType, 1, EncoderParameterValueTypeRational, @Values[0]);
end;

destructor TGPEncoderParameters.Destroy;
begin
  FreeMem(FNativeParams);
  FreeMem(FValues);
  inherited;
end;

function TGPEncoderParameters.GetCount: Integer;
begin
  Result := FParamCount;
end;

function TGPEncoderParameters.GetEnumerator: TGPEncoderParameterEnumerator;
begin
  Result := TGPEncoderParameterEnumerator.Create(Self);
end;

function TGPEncoderParameters.GetNativeParams: PGPNativeEncoderParameters;
begin
  if (FNativeParams = nil) or (FModified) then
  begin
    ReallocMem(FNativeParams, 4 + FParamCount * SizeOf(TGPNativeEncoderParameter));
    FNativeParams.Count := FParamCount;
    if (FParamCount > 0) then
      Move(FParams[0], FNativeParams.Parameter[0], FParamCount * SizeOf(TGPNativeEncoderParameter));
    FModified := False;
  end;
  Result := FNativeParams;
end;

function TGPEncoderParameters.GetParam(const Index: Integer): PGPNativeEncoderParameter;
begin
  Result := @FParams[Index];
end;

{ TGPColorPalette }

constructor TGPColorPalette.Create(const Count: Integer);
begin
  inherited Create;
  GetMem(FData, SizeOf(TGPNativeColorPalette) + Count * SizeOf(ARGB));
  FData.Count := Count;
  FData.Flags := [];
  FEntries := Pointer(FData);
  Inc(PByte(FEntries), SizeOf(TGPNativeColorPalette));
end;

constructor TGPColorPalette.Create(const NativePalette: PGPNativeColorPalette);
begin
  if (NativePalette = nil) then
  begin
    Create(1);
    FData.Count := 0;
  end
  else
  begin
    inherited Create;
    FData := NativePalette;
    FEntries := Pointer(FData);
    Inc(PByte(FEntries), SizeOf(TGPNativeColorPalette));
  end;
end;

destructor TGPColorPalette.Destroy;
begin
  FreeMem(FData);
  inherited;
end;

function TGPColorPalette.GetCount: Integer;
begin
  Result := FData.Count;
end;

function TGPColorPalette.GetEntry(const Index: Integer): ARGB;
begin
  Result := FEntries[Index];
end;

function TGPColorPalette.GetEntryPtr: PARGB;
begin
  Result := FEntries;
end;

function TGPColorPalette.GetFlags: TGPPaletteFlags;
begin
  Result := FData.Flags;
end;

function TGPColorPalette.GetNativePalette: PGPNativeColorPalette;
begin
  Result := FData;
end;

procedure TGPColorPalette.SetEntry(const Index: Integer; const Value: ARGB);
begin
  FEntries[Index] := Value;
end;

procedure TGPColorPalette.SetFlags(const Value: TGPPaletteFlags);
begin
  FData.Flags := Value;
end;

{ TGPPropertyItem }

constructor TGPPropertyItem.Create(const Data: PGPNativePropertyItem);
begin
  inherited Create;
  FData := Data;
end;

constructor TGPPropertyItem.Create;
begin
  inherited Create;
  GetMem(FData, SizeOf(TGPNativePropertyItem));
end;

destructor TGPPropertyItem.Destroy;
begin
  FreeMem(FData);
  inherited;
end;

function TGPPropertyItem.GetId: TPropID;
begin
  Result := FData.Id;
end;

function TGPPropertyItem.GetLength: Cardinal;
begin
  Result := FData.Length;
end;

function TGPPropertyItem.GetNativeItem: PGPNativePropertyItem;
begin
  Result := FData;
end;

function TGPPropertyItem.GetValue: Pointer;
begin
  Result := FData.Value;
end;

function TGPPropertyItem.GetValueType: Word;
begin
  Result := FData.ValueType;
end;

procedure TGPPropertyItem.SetId(const Value: TPropID);
begin
  FData.Id := Value;
end;

procedure TGPPropertyItem.SetLength(const Value: Cardinal);
begin
  FData.Length := Value;
end;

procedure TGPPropertyItem.SetValue(const Value: Pointer);
begin
  FData.Value := Value;
end;

procedure TGPPropertyItem.SetValueType(const Value: Word);
begin
  FData.ValueType := Value;
end;

{ TGPImage }

function TGPImage.Clone: IGPImage;
var
  NativeClone: GpImage;
begin
  NativeClone := nil;
  GdipCheck(GdipCloneImage(FNativeHandle, NativeClone));
  Result := TGPImage.Create(NativeClone);
end;

constructor TGPImage.Create(const Stream: IStream;
  const UseEmbeddedColorManagement: Boolean);
begin
  inherited Create;
  if (UseEmbeddedColorManagement) then
    GdipCheck(GdipLoadImageFromStreamICM(Stream, FNativeHandle))
  else
    GdipCheck(GdipLoadImageFromStream(Stream, FNativeHandle))
end;

constructor TGPImage.Create(const Filename: String;
  const UseEmbeddedColorManagement: Boolean);
begin
  inherited Create;
  if (UseEmbeddedColorManagement) then
    GdipCheck(GdipLoadImageFromFileICM(PWideChar(Filename), FNativeHandle))
  else
    GdipCheck(GdipLoadImageFromFile(PWideChar(Filename), FNativeHandle))
end;

constructor TGPImage.Create(const NativeImage: GpImage);
begin
  inherited Create;
  FNativeHandle := NativeImage;
end;

destructor TGPImage.Destroy;
begin
  GdipDisposeImage(FNativeHandle);
  inherited;
end;

{$IF (GDIPVER >= $0110)}
procedure TGPImage.FindFirstItem(const Item: PGPImageItemData);
begin
  GdipCheck(GdipFindFirstImageItem(FNativeHandle, Item));
end;

procedure TGPImage.FindNextItem(const Item: PGPImageItemData);
begin
  GdipCheck(GdipFindNextImageItem(FNativeHandle, Item));
end;

procedure TGPImage.GetItemData(const Item: PGPImageItemData);
begin
  GdipCheck(GdipGetImageItemData(FNativeHandle, Item));
end;

procedure TGPImage.SetAbort(const Abort: TGdiplusAbort);
begin
  GdipCheck(GdipImageSetAbort(FNativeHandle, @Abort));
end;
{$IFEND}

class function TGPImage.FromFile(const Filename: String;
  const UseEmbeddedColorManagement: Boolean): IGPImage;
begin
  Result := TGPImage.Create(Filename, UseEmbeddedColorManagement);
end;

class function TGPImage.FromStream(const Stream: IStream;
  const UseEmbeddedColorManagement: Boolean): IGPImage;
begin
  Result := TGPImage.Create(Stream, UseEmbeddedColorManagement);
end;

procedure TGPImage.GetBounds(out SrcRect: TGPRectF; out SrcUnit: TGPUnit);
begin
  GdipCheck(GdipGetImageBounds(FNativeHandle, SrcRect, SrcUnit));
end;

function TGPImage.GetEncoderParameterList(const lEncoder: TGUID): IGPEncoderParameters;
var
  Size: Cardinal;
  Params: PGPNativeEncoderParameters;
begin
  Size := 0;
  Params := nil;
  try
    if (GdipGetEncoderParameterListSize(FNativeHandle, @lEncoder, Size) = Ok) and (Size > 0) then
    begin
      GetMem(Params, Size);
      GdipCheck(GdipGetEncoderParameterList(FNativeHandle, @lEncoder, Size, Params));
    end;
    Result := TGPEncoderParameters.Create(Params);
  finally
    FreeMem(Params);
  end;
end;

function TGPImage.GetFlags: TGPImageFlags;
begin
  Result := [];
  GdipCheck(GdipGetImageFlags(FNativeHandle, Result));
end;

function TGPImage.GetFrameCount(const DimensionID: TGUID): Cardinal;
begin
  Result := 0;
  GdipCheck(GdipImageGetFrameCount(FNativeHandle, DimensionID, Result));
end;

function TGPImage.GetFrameDimensions: IGPFrameDimensions;
var
  Count: Cardinal;
begin
  Count := 0;
  GdipCheck(GdipImageGetFrameDimensionsCount(FNativeHandle, Count));
  Result := TGPArray<TGUID>.Create(Count);
  if (Count > 0) then
    GdipCheck(GdipImageGetFrameDimensionsList(FNativeHandle, Result.ItemPtr, Count));
end;

function TGPImage.GetHeight: Cardinal;
begin
  Result := 0;
  GdipCheck(GdipGetImageHeight(FNativeHandle, Result));
end;

function TGPImage.GetHorizontalResolution: Single;
begin
  Result := 0;
  GdipCheck(GdipGetImageHorizontalResolution(FNativeHandle, Result));
end;

function TGPImage.GetPalette: IGPColorPalette;
var
  Size: Integer;
  Palette: PGPNativeColorPalette;
begin
  Palette := nil;
  Size := 0;
  GdipCheck(GdipGetImagePaletteSize(FNativeHandle, Size));
  if (Size > 0) then
  begin
    GetMem(Palette, Size);
    GdipCheck(GdipGetImagePalette(FNativeHandle, Palette, Size));
  end;
  Result := TGPColorPalette.Create(Palette);
end;

procedure TGPImage.GetPhysicalDimension(out Size: TGPSizeF);
begin
  GdipCheck(GdipGetImageDimension(FNativeHandle, Size.Width, Size.Height));
end;

function TGPImage.GetPixelFormat: TGPPixelFormat;
begin
  GdipCheck(GdipGetImagePixelFormat(FNativeHandle, Result));
end;

function TGPImage.GetPropertyIdList: IGPPropertyIdList;
var
  Count: Cardinal;
begin
  Count := 0;
  GdipCheck(GdipGetPropertyCount(FNativeHandle, Count));
  Result := TGPArray<TPropID>.Create(Count);
  if (Count > 0) then
    GdipCheck(GdipGetPropertyIdList(FNativeHandle, Count, Result.ItemPtr));
end;

function TGPImage.GetPropertyItem(const PropId: TPropID): IGPPropertyItem;
var
  Size: Cardinal;
  Data: PGPNativePropertyItem;
begin
  Size := 0;
  Data := nil;
  GdipCheck(GdipGetPropertyItemSize(FNativeHandle, PropId, Size));
  if (Size > 0) then
  begin
    GetMem(Data, Size);
    GdipCheck(GdipGetPropertyItem(FNativeHandle, PropId, Size, Data));
  end;
  Result := TGPPropertyItem.Create(Data);
end;

function TGPImage.GetPropertyItems: IGPPropertyItems;
var
  I, TotalBufferSize, NumProperties, PropSize: Cardinal;
  AllProperties, CurProp, Data: PGPNativePropertyItem;
begin
  GdipCheck(GdipGetPropertySize(FNativeHandle, TotalBufferSize, NumProperties));
  Result := TGPArray<IGPPropertyItem>.Create(NumProperties);
  if (TotalBufferSize > 0) then
  begin
    GetMem(AllProperties, TotalBufferSize);
    try
      GdipCheck(GdipGetAllPropertyItems(FNativeHandle, TotalBufferSize,
        NumProperties, AllProperties));
      CurProp := AllProperties;
      PropSize := TotalBufferSize div SizeOf(TGPNativePropertyItem);
      for I := 0 to NumProperties - 1 do
      begin
        GetMem(Data, PropSize);
        Move(CurProp^, Data^, PropSize);
        Result[I] := TGPPropertyItem.Create(Data);
        Inc(CurProp);
      end;
    finally
      FreeMem(AllProperties);
    end;
  end;
end;

function TGPImage.GetRawFormat: TGUID;
begin
  GdipCheck(GdipGetImageRawFormat(FNativeHandle, Result));
end;

function TGPImage.GetThumbnailImage(const ThumbWidth, ThumbHeight: Cardinal;
  const Callback: TGPGetThumbnailImageAbort; const CallbackData: Pointer): IGPImage;
var
  NativeThumbnail: GpImage;
begin
  NativeThumbnail := nil;
  GdipCheck(GdipGetImageThumbnail(FNativeHandle, ThumbWidth, ThumbHeight,
    NativeThumbnail, Callback, CallbackData));
  Result := TGPImage.Create(NativeThumbnail);
end;

function TGPImage.GetType: TGPImageType;
begin
  Result := ImageTypeUnknown;
  GdipCheck(GdipGetImageType(FNativeHandle, Result));
end;

function TGPImage.GetVerticalResolution: Single;
begin
  Result := 0;
  GdipCheck(GdipGetImageVerticalResolution(FNativeHandle, Result));
end;

function TGPImage.GetWidth: Cardinal;
begin
  Result := 0;
  GdipCheck(GdipGetImageWidth(FNativeHandle, Result));
end;

procedure TGPImage.RemovePropertyItem(const PropId: TPropID);
begin
  GdipCheck(GdipRemovePropertyItem(FNativeHandle, PropId));
end;

procedure TGPImage.RotateFlip(const RotateFlipType: TGPRotateFlipType);
begin
  GdipCheck(GdipImageRotateFlip(FNativeHandle, RotateFlipType));
end;

procedure TGPImage.Save(const Filename: String; const Encoder: IGPImageCodecInfo;
  const Params: IGPEncoderParameters);
var
  NativeParams: PGPNativeEncoderParameters;
begin
  Assert(Assigned(Encoder));
  if Assigned(Params) then
    NativeParams := Params.NativeParams
  else
    NativeParams := nil;
  GdipCheck(GdipSaveImageToFile(FNativeHandle, PWideChar(Filename),
    Encoder.ClsId, NativeParams));
end;

procedure TGPImage.Save(const Stream: IStream; const Format: IGPImageFormat;
  const Params: IGPEncoderParameters);
var
  NativeParams: PGPNativeEncoderParameters;
begin
  Assert(Assigned(Format));
  if Assigned(Params) then
    NativeParams := Params.NativeParams
  else
    NativeParams := nil;
  GdipCheck(GdipSaveImageToStream(FNativeHandle, Stream, Format.CodecId, NativeParams));
end;

procedure TGPImage.Save(const Stream: IStream; const Encoder: IGPImageCodecInfo;
  const Params: IGPEncoderParameters);
var
  NativeParams: PGPNativeEncoderParameters;
begin
  Assert(Assigned(Encoder));
  if Assigned(Params) then
    NativeParams := Params.NativeParams
  else
    NativeParams := nil;
  GdipCheck(GdipSaveImageToStream(FNativeHandle, Stream, Encoder.ClsId, NativeParams));
end;

procedure TGPImage.Save(const Filename: String; const Format: IGPImageFormat;
  const Params: IGPEncoderParameters);
var
  NativeParams: PGPNativeEncoderParameters;
begin
  Assert(Assigned(Format));
  if Assigned(Params) then
    NativeParams := Params.NativeParams
  else
    NativeParams := nil;
  GdipCheck(GdipSaveImageToFile(FNativeHandle, PWideChar(Filename),
    Format.CodecId, NativeParams));
end;

procedure TGPImage.SaveAdd(const NewImage: IGPImage;
  const Params: IGPEncoderParameters);
begin
  Assert(Assigned(Params));
  if (NewImage = nil) then
    GdipCheck(InvalidParameter);
  GdipCheck(GdipSaveAddImage(FNativeHandle, NewImage.NativeHandle, Params.NativeParams));
end;

procedure TGPImage.SaveAdd(const Params: IGPEncoderParameters);
begin
  Assert(Assigned(Params));
  GdipCheck(GdipSaveAdd(FNativeHandle, Params.NativeParams));
end;

procedure TGPImage.SelectActiveFrame(const DimensionID: TGUID;
  const FrameIndex: Cardinal);
begin
  GdipCheck(GdipImageSelectActiveFrame(FNativeHandle, DimensionID, FrameIndex));
end;

procedure TGPImage.SetPalette(const Value: IGPColorPalette);
begin
  Assert(Assigned(Value));
  GdipCheck(GdipSetImagePalette(FNativeHandle, Value.NativePalette));
end;

procedure TGPImage.SetPropertyItem(const PropItem: IGPPropertyItem);
begin
  Assert(Assigned(PropItem));
  GdipCheck(GdipSetPropertyItem(FNativeHandle, PropItem.NativeItem));
end;

{$IF (GDIPVER >= $0110)}

{ TGPHistogram }

constructor TGPHistogram.Create(const AChannelCount, AEntryCount: Integer; const AChannel0, AChannel1,
  AChannel2, AChannel3: PCardinal);
begin
  inherited Create;
  FChannelCount := AChannelCount;
  FEntryCount := AEntryCount;
  FChannels[0] := AChannel0;
  FChannels[1] := AChannel1;
  FChannels[2] := AChannel2;
  FChannels[3] := AChannel3;
end;

destructor TGPHistogram.Destroy;
begin
  FreeMem(FChannels[3]);
  FreeMem(FChannels[2]);
  FreeMem(FChannels[1]);
  FreeMem(FChannels[0]);
  inherited;
end;

function TGPHistogram.GetChannel0(const Index: Integer): Cardinal;
begin
  Result := FChannels[0, Index];
end;

function TGPHistogram.GetChannel0Ptr: PCardinal;
begin
  Result := FChannels[0];
end;

function TGPHistogram.GetChannel1(const Index: Integer): Cardinal;
begin
  Result := FChannels[1,Index];
end;

function TGPHistogram.GetChannel1Ptr: PCardinal;
begin
  Result := FChannels[1];
end;

function TGPHistogram.GetChannel2(const Index: Integer): Cardinal;
begin
  Result := FChannels[2,Index];
end;

function TGPHistogram.GetChannel2Ptr: PCardinal;
begin
  Result := FChannels[2];
end;

function TGPHistogram.GetChannel3(const Index: Integer): Cardinal;
begin
  Result := FChannels[3,Index];
end;

function TGPHistogram.GetChannel3Ptr: PCardinal;
begin
  Result := FChannels[3];
end;

function TGPHistogram.GetChannelCount: Integer;
begin
  Result := FChannelCount;
end;

function TGPHistogram.GetEntryCount: Integer;
begin
  Result := FEntryCount;
end;

function TGPHistogram.GetValue(const ChannelIndex, EntryIndex: Integer): Cardinal;
begin
  Result := FChannels[ChannelIndex, EntryIndex];
end;

function TGPHistogram.GetValuePtr(const ChannelIndex: Integer): PCardinal;
begin
  Result := FChannels[ChannelIndex];
end;
{$IFEND}

{ TGPBitmap }

{$IF (GDIPVER >= $0110)}
procedure TGPBitmap.ApplyEffect(const Effect: IGPEffect; const ROI: Windows.PRect);
var
  AuxData: Pointer;
  AuxDataSize: Integer;
begin
  Effect.ReleaseAuxData;
  AuxData := nil;
  AuxDataSize := 0;
  GdipCheck(GdipBitmapApplyEffect(FNativeHandle, Effect.NativeHandle, ROI,
    Effect.UseAuxData, AuxData, AuxDataSize));
  Effect.SetAuxData(AuxData, AuxDataSize);
end;

class function TGPBitmap.ApplyEffect(const Inputs: array of IGPBitmap;
  const Effect: IGPEffect; const ROI, OutputRect: Windows.PRect): IGPBitmap;
var
  NativeInputs: array of GpBitmap;
  NativeOutput: GpBitmap;
  I, AuxDataSize: Integer;
  AuxData: Pointer;
begin
  SetLength(NativeInputs, Length(Inputs));
  for I := 0 to Length(Inputs) - 1 do
    NativeInputs[I] := Inputs[I].NativeHandle;

  Effect.ReleaseAuxData;
  AuxData := nil;
  AuxDataSize := 0;

  GdipCheck(GdipBitmapCreateApplyEffect(@NativeInputs[0], Length(Inputs),
    Effect.NativeHandle, ROI, OutputRect, NativeOutput, Effect.UseAuxData,
    AuxData, AuxDataSize));

  Effect.SetAuxData(AuxData, AuxDataSize);
  Result := TGPBitmap.Create(NativeOutput);
end;
{$IFEND}

function TGPBitmap.Clone(const Rect: TGPRectF; const Format: TGPPixelFormat): IGPBitmap;
begin
  Result := Clone(Rect.X, Rect.Y, Rect.Width, Rect.Height, Format);
end;

function TGPBitmap.Clone(const X, Y, Width, Height: Single;
  const Format: TGPPixelFormat): IGPBitmap;
var
  NativeClone: GpBitmap;
begin
  GdipCheck(GdipCloneBitmapArea(X, Y, Width, Height, Format, FNativeHandle, NativeClone));
  Result := TGPBitmap.Create(NativeClone);
end;

function TGPBitmap.Clone: IGPBitmap;
begin
  Result := Clone(0, 0, GetWidth, GetHeight, GetPixelFormat);
end;

function TGPBitmap.Clone(const X, Y, Width, Height: Integer;
  const Format: TGPPixelFormat): IGPBitmap;
var
  NativeClone: GpBitmap;
begin
  GdipCheck(GdipCloneBitmapAreaI(X, Y, Width, Height, Format, FNativeHandle, NativeClone));
  Result := TGPBitmap.Create(NativeClone);
end;

function TGPBitmap.Clone(const Rect: TGPRect; const Format: TGPPixelFormat): IGPBitmap;
begin
  Result := Clone(Rect.X, Rect.Y, Rect.Width, Rect.Height, Format);
end;

{$IF (GDIPVER >= $0110)}
procedure TGPBitmap.ConvertFormat(const Format: TGPPixelFormat;
  const DitherType: TGPDitherType; const PaletteType: TGPPaletteType;
  const Palette: IGPColorPalette; const AlphaThresholdPercent: Single);
var
  NativePalette: PGPNativeColorPalette;
begin
  if Assigned(Palette) then
    NativePalette := Palette.NativePalette
  else
    NativePalette := nil;
  GdipCheck(GdipBitmapConvertFormat(FNativeHandle, Format, DitherType,
    PaletteType, NativePalette, AlphaThresholdPercent));
end;
{$IFEND}

constructor TGPBitmap.Create(const Filename: String;
  const UseEmbeddedColorManagement: Boolean);
begin
  inherited Create;
  if (UseEmbeddedColorManagement) then
    GdipCheck(GdipCreateBitmapFromFileICM(PWideChar(Filename), FNativeHandle))
  else
    GdipCheck(GdipCreateBitmapFromFile(PWideChar(Filename), FNativeHandle))
end;

constructor TGPBitmap.Create(const NativeBitmap: GpBitmap);
begin
  inherited Create(NativeBitmap);
end;

constructor TGPBitmap.Create(const BitmapHandle: HBitmap;
  const Palette: HPalette);
begin
  inherited Create;
  GdipCheck(GdipCreateBitmapFromHBITMAP(BitmapHandle, Palette, FNativeHandle))
end;

constructor TGPBitmap.Create(const BitmapInfo: TBitmapInfo;
  const BitmapData: Pointer);
begin
  inherited Create;
  GdipCheck(GdipCreateBitmapFromGdiDib(@BitmapInfo, BitmapData, FNativeHandle))
end;

constructor TGPBitmap.Create(const Instance: HInst; const BitmapName: String);
begin
  inherited Create;
  GdipCheck(GdipCreateBitmapFromResource(Instance, PWideChar(BitmapName), FNativeHandle))
end;

constructor TGPBitmap.Create(const IconHandle: HIcon);
begin
  inherited Create;
  GdipCheck(GdipCreateBitmapFromHICON(IconHandle, FNativeHandle))
end;

constructor TGPBitmap.Create(const DirectDrawSurface7: IInterface);
{$IFOPT C+}
const
  IID_IDirectDrawSurface7: TGUID = '{15e65ec0-3b9c-11d2-b92f-00609797ea5b}';
{$ENDIF}
begin
  {$IFOPT C+}
  Assert(Supports(DirectDrawSurface7, IID_IDirectDrawSurface7));
  {$ENDIF}
  inherited Create;
  GdipCheck(GdipCreateBitmapFromDirectDrawSurface(DirectDrawSurface7, FNativeHandle))
end;

constructor TGPBitmap.Create(const Stream: IStream;
  const UseEmbeddedColorManagement: Boolean);
begin
  inherited Create;
  if (UseEmbeddedColorManagement) then
    GdipCheck(GdipCreateBitmapFromStreamICM(Stream, FNativeHandle))
  else
    GdipCheck(GdipCreateBitmapFromStream(Stream, FNativeHandle))
end;

constructor TGPBitmap.Create(const Width, Height, Stride: Integer;
  const Format: TGPPixelFormat; const Scan0: Pointer);
begin
  inherited Create;
  GdipCheck(GdipCreateBitmapFromScan0(Width, Height, Stride, Format, Scan0, FNativeHandle));
end;

constructor TGPBitmap.Create(const Width, Height: Integer;
  const Target: IGPGraphics);
begin
  inherited Create;
  GdipCheck(GdipCreateBitmapFromGraphics(Width, Height, Target.NativeHandle, FNativeHandle));
end;

constructor TGPBitmap.Create(const Width, Height: Integer;
  const Format: TGPPixelFormat);
begin
  inherited Create;
  GdipCheck(GdipCreateBitmapFromScan0(Width, Height, 0, Format, nil, FNativeHandle));
end;

class function TGPBitmap.FromBitmapInfo(const BitmapInfo: TBitmapInfo;
  const BitmapData: Pointer): IGPBitmap;
begin
  Result := TGPBitmap.Create(BitmapInfo, BitmapData);
end;

class function TGPBitmap.FromDirectDrawSurface7(
  const Surface: IInterface): IGPBitmap;
begin
  Result := TGPBitmap.Create(Surface);
end;

class function TGPBitmap.FromFile(const Filename: String;
  const UseEmbeddedColorManagement: Boolean): IGPBitmap;
begin
  Result := TGPBitmap.Create(Filename, UseEmbeddedColorManagement);
end;

class function TGPBitmap.FromHBitmap(const BitmapHandle: HBitmap;
  const Palette: HPalette): IGPBitmap;
begin
  Result := TGPBitmap.Create(BitmapHandle, Palette);
end;

class function TGPBitmap.FromHIcon(const IconHandle: HIcon): IGPBitmap;
begin
  Result := TGPBitmap.Create(IconHandle);
end;

class function TGPBitmap.FromResource(const Instance: HInst;
  const BitmapName: String): IGPBitmap;
begin
  Result := TGPBitmap.Create(Instance, BitmapName);
end;

class function TGPBitmap.FromStream(const Stream: IStream;
  const UseEmbeddedColorManagement: Boolean): IGPBitmap;
begin
  Result := TGPBitmap.Create(Stream, UseEmbeddedColorManagement);
end;

function TGPBitmap.GetHBitmap(const ColorBackground: TGPColor): HBitmap;
begin
  GdipCheck(GdipCreateHBITMAPFromBitmap(FNativeHandle, Result, ColorBackground.Value));
end;

function TGPBitmap.GetHIcon: HIcon;
begin
  GdipCheck(GdipCreateHICONFromBitmap(FNativeHandle, Result));
end;

{$IF (GDIPVER >= $0110)}
function TGPBitmap.GetHistogram(const Format: TGPHistogramFormat): IGPHistogram;
var
  ChannelCount, EntryCount: Cardinal;
  Channel0, Channel1, Channel2, Channel3: PCardinal;
begin
  case Format of
    HistogramFormatARGB,
    HistogramFormatPARGB:
      ChannelCount := 4;
    HistogramFormatRGB:
      ChannelCount := 3;
  else
    ChannelCount := 1;
  end;
  EntryCount := 0;
  Channel0 := nil;
  Channel1 := nil;
  Channel2 := nil;
  Channel3 := nil;
  GdipCheck(GdipBitmapGetHistogramSize(Format, EntryCount));
  if (EntryCount > 0) then
  begin
    GetMem(Channel0, EntryCount * SizeOf(Cardinal));
    if (ChannelCount > 1) then
    begin
      GetMem(Channel1, EntryCount * SizeOf(Cardinal));
      GetMem(Channel2, EntryCount * SizeOf(Cardinal));
      if (ChannelCount > 3) then
        GetMem(Channel3, EntryCount * SizeOf(Cardinal));
    end;

    try
      GdipCheck(GdipBitmapGetHistogram(FNativeHandle, Format, EntryCount,
        Channel0, Channel1, Channel2, Channel3));
    except
      FreeMem(Channel3);
      FreeMem(Channel2);
      FreeMem(Channel2);
      FreeMem(Channel0);
      Channel0 := nil;
      Channel1 := nil;
      Channel2 := nil;
      Channel3 := nil;
    end;
  end;
  Result := TGPHistogram.Create(ChannelCount, EntryCount, Channel0, Channel1, Channel2, Channel3);
end;
{$IFEND}

function TGPBitmap.GetPixel(const X, Y: Integer): TGPColor;
begin
  GdipCheck(GdipBitmapGetPixel(FNativeHandle, X, Y, Result.FArgb));
end;

{$IF (GDIPVER >= $0110)}
class function TGPBitmap.InitializePalette(const ColorCount: Integer;
  const PaletteType: TGPPaletteType; const OptimalColors: Integer;
  const UseTransparentColor: Boolean; const Bitmap: IGPBitmap): IGPColorPalette;
var
  NativePalette: PGPNativeColorPalette;
begin
  GetMem(NativePalette, SizeOf(TGPNativeColorPalette) + ColorCount * SizeOf(ARGB));
  NativePalette.Flags := [];
  NativePalette.Count := ColorCount;
  try
    GdipCheck(GdipInitializePalette(NativePalette, PaletteType, OptimalColors,
      UseTransparentColor, GdipHandle(Bitmap)));
  except
    FreeMem(NativePalette);
    raise;
  end;
  Result := TGPColorPalette.Create(NativePalette);
end;
{$IFEND}

function TGPBitmap.LockBits(const Rect: TGPRect; const Mode: TGPImageLockMode;
  const Format: TGPPixelFormat): TGPBitmapData;
begin
  GdipCheck(GdipBitmapLockBits(FNativeHandle, @Rect, Mode, Format, Result));
end;

procedure TGPBitmap.SetPixel(const X, Y: Integer; const Value: TGPColor);
begin
  GdipCheck(GdipBitmapSetPixel(FNativeHandle, X, Y, Value.Value));
end;

procedure TGPBitmap.SetResolution(const XDpi, YDpi: Single);
begin
  GdipCheck(GdipBitmapSetResolution(FNativeHandle, XDpi, YDpi));
end;

procedure TGPBitmap.UnlockBits(const LockedBitmapData: TGPBitmapData);
begin
  GdipCheck(GdipBitmapUnlockBits(FNativeHandle, LockedBitmapData));
end;
{$ENDREGION 'GdiplusBitmap.h'}

{$REGION 'GdiplusLineCaps.h'}

{ TGPCustomLineCap }

function TGPCustomLineCap.Clone: IGPCustomLineCap;
var
  NativeClone: GpCustomLineCap;
begin
  NativeClone := nil;
  GdipCheck(GdipCloneCustomLineCap(FNativeHandle, NativeClone));
  Result := TGPCustomLineCap.Create(NativeClone);
end;

constructor TGPCustomLineCap.Create(const NativeLineCap: GpCustomLineCap);
begin
  inherited Create;
  FNativeHandle := NativeLineCap;
end;

constructor TGPCustomLineCap.Create(const FillPath, StrokePath: IGPGraphicsPath;
  const BaseCap: TGPLineCap; const BaseInset: Single);
begin
  inherited Create;
  GdipCheck(GdipCreateCustomLineCap(GdipHandle(FillPath), GdipHandle(StrokePath),
    BaseCap, BaseInset, FNativeHandle));
end;

destructor TGPCustomLineCap.Destroy;
begin
  GdipDeleteCustomLineCap(FNativeHandle);
  inherited;
end;

function TGPCustomLineCap.GetBaseCap: TGPLineCap;
begin
  GdipCheck(GdipGetCustomLineCapBaseCap(FNativeHandle, Result));
end;

function TGPCustomLineCap.GetBaseInset: Single;
begin
  GdipCheck(GdipGetCustomLineCapBaseInset(FNativeHandle, Result));
end;

procedure TGPCustomLineCap.GetStrokeCaps(out StartCap, EndCap: TGPLineCap);
begin
  GdipCheck(GdipGetCustomLineCapStrokeCaps(FNativeHandle, StartCap, EndCap));
end;

function TGPCustomLineCap.GetStrokeJoin: TGPLineJoin;
begin
  GdipCheck(GdipGetCustomLineCapStrokeJoin(FNativeHandle, Result));
end;

function TGPCustomLineCap.GetWidthScale: Single;
begin
  GdipCheck(GdipGetCustomLineCapWidthScale(FNativeHandle, Result));
end;

procedure TGPCustomLineCap.SetBaseCap(const Value: TGPLineCap);
begin
  GdipCheck(GdipSetCustomLineCapBaseCap(FNativeHandle, Value));
end;

procedure TGPCustomLineCap.SetBaseInset(const Value: Single);
begin
  GdipCheck(GdipSetCustomLineCapBaseInset(FNativeHandle, Value));
end;

procedure TGPCustomLineCap.SetStrokeCap(const StrokeCap: TGPLineCap);
begin
  SetStrokeCaps(StrokeCap, StrokeCap);
end;

procedure TGPCustomLineCap.SetStrokeCaps(const StartCap, EndCap: TGPLineCap);
begin
  GdipCheck(GdipSetCustomLineCapStrokeCaps(FNativeHandle, StartCap, EndCap));
end;

procedure TGPCustomLineCap.SetStrokeJoin(const Value: TGPLineJoin);
begin
  GdipCheck(GdipSetCustomLineCapStrokeJoin(FNativeHandle, Value));
end;

procedure TGPCustomLineCap.SetWidthScale(const Value: Single);
begin
  GdipCheck(GdipSetCustomLineCapWidthScale(FNativeHandle, Value));
end;

{ TGPAdjustableArrowCap }

constructor TGPAdjustableArrowCap.Create(const Height, Width: Single;
  const IsFilled: Boolean);
begin
  GdipCheck(GdipCreateAdjustableArrowCap(Height, Width, IsFilled, FNativeHandle));
end;

function TGPAdjustableArrowCap.GetFilled: Boolean;
var
  B: Bool;
begin
  GdipCheck(GdipGetAdjustableArrowCapFillState(FNativeHandle, B));
  Result := B;
end;

function TGPAdjustableArrowCap.GetHeight: Single;
begin
  GdipCheck(GdipGetAdjustableArrowCapHeight(FNativeHandle, Result));
end;

function TGPAdjustableArrowCap.GetMiddleInset: Single;
begin
  GdipCheck(GdipGetAdjustableArrowCapMiddleInset(FNativeHandle, Result));
end;

function TGPAdjustableArrowCap.GetWidth: Single;
begin
  GdipCheck(GdipGetAdjustableArrowCapWidth(FNativeHandle, Result));
end;

procedure TGPAdjustableArrowCap.SetFilled(const Value: Boolean);
begin
  GdipCheck(GdipSetAdjustableArrowCapFillState(FNativeHandle, Value));
end;

procedure TGPAdjustableArrowCap.SetHeight(const Value: Single);
begin
  GdipCheck(GdipSetAdjustableArrowCapHeight(FNativeHandle, Value));
end;

procedure TGPAdjustableArrowCap.SetMiddleInset(const Value: Single);
begin
  GdipCheck(GdipSetAdjustableArrowCapMiddleInset(FNativeHandle, Value));
end;

procedure TGPAdjustableArrowCap.SetWidth(const Value: Single);
begin
  GdipCheck(GdipSetAdjustableArrowCapWidth(FNativeHandle, Value));
end;
{$ENDREGION 'GdiplusLineCaps.h'}

{$REGION 'GdiplusCachedBitmap.h'}

{ TGPCachedBitmap }

constructor TGPCachedBitmap.Create(const Bitmap: IGPBitmap;
  const Graphics: IGPGraphics);
begin
  inherited Create;
  GdipCheck(GdipCreateCachedBitmap(Bitmap.NativeHandle, Graphics.NativeHandle, FNativeHandle));
end;

destructor TGPCachedBitmap.Destroy;
begin
  GdipDeleteCachedBitmap(FNativeHandle);
  inherited;
end;
{$ENDREGION 'GdiplusCachedBitmap.h'}

{$REGION 'GdiplusMetafile.h'}

{ TGPMetafile }

{$IF (GDIPVER >= $0110)}
procedure TGPMetafile.ConvertToEmfPlus(const RefGraphics: IGPGraphics;
  const ConversionFailureFlag: PInteger; const EmfType: TGPEmfType;
  const Description: String);
var
  Metafile: GpMetafile;
begin
  Metafile := nil;
  GdipCheck(GdipConvertToEmfPlus(RefGraphics.NativeHandle, FNativeHandle,
    ConversionFailureFlag, EmfType, PWideChar(Description), Metafile));
  GdipDisposeImage(FNativeHandle);
  FNativeHandle := Metafile;
end;

procedure TGPMetafile.ConvertToEmfPlus(const RefGraphics: IGPGraphics;
  const Filename: String; const ConversionFailureFlag: PInteger;
  const EmfType: TGPEmfType; const Description: String);
var
  Metafile: GpMetafile;
begin
  Metafile := nil;
  GdipCheck(GdipConvertToEmfPlusToFile(RefGraphics.NativeHandle, FNativeHandle,
    ConversionFailureFlag, PWideChar(Filename), EmfType, PWideChar(Description), Metafile));
  GdipDisposeImage(FNativeHandle);
  FNativeHandle := Metafile;
end;

procedure TGPMetafile.ConvertToEmfPlus(const RefGraphics: IGPGraphics;
  const Stream: IStream; const ConversionFailureFlag: PInteger;
  const EmfType: TGPEmfType; const Description: String);
var
  Metafile: GpMetafile;
begin
  Metafile := nil;
  GdipCheck(GdipConvertToEmfPlusToStream(RefGraphics.NativeHandle, FNativeHandle,
    ConversionFailureFlag, Stream, EmfType, PWideChar(Description), Metafile));
  GdipDisposeImage(FNativeHandle);
  FNativeHandle := Metafile;
end;
{$IFEND}

constructor TGPMetafile.Create(const Filename: String;
  const WmfPlaceableFileHeader: TWmfPlaceableFileHeader);
begin
  inherited Create;
  GdipCheck(GdipCreateMetafileFromWmfFile(PWideChar(Filename), WmfPlaceableFileHeader, FNativeHandle));
end;

constructor TGPMetafile.Create(const Stream: IStream);
begin
  inherited Create;
  GdipCheck(GdipCreateMetafileFromStream(Stream, FNativeHandle));
end;

constructor TGPMetafile.Create(const ReferenceDC: HDC; const EmfType: TGPEmfType;
  const Description: String);
begin
  inherited Create;
  GdipCheck(GdipRecordMetafile(ReferenceDC, EmfType, nil, MetafileFrameUnitGdi,
    PWideChar(Description), FNativeHandle));
end;

constructor TGPMetafile.Create(const Filename: String);
begin
  inherited Create;
  GdipCheck(GdipCreateMetafileFromFile(PWideChar(Filename), FNativeHandle));
end;

constructor TGPMetafile.Create(const Wmf: HMetafile;
  const WmfPlaceableFileHeader: TWmfPlaceableFileHeader;
  const DeleteWmf: Boolean);
begin
  inherited Create;
  GdipCheck(GdipCreateMetafileFromWmf(Wmf, DeleteWmf, WmfPlaceableFileHeader, FNativeHandle));
end;

constructor TGPMetafile.Create(const Emf: HEnhMetafile; const DeleteEmf: Boolean);
begin
  inherited Create;
  GdipCheck(GdipCreateMetafileFromEmf(Emf, DeleteEmf, FNativeHandle));
end;

constructor TGPMetafile.Create(const ReferenceDC: HDC; const FrameRect: TGPRectF;
  const FrameUnit: TGPMetafileFrameUnit; const EmfType: TGPEmfType;
  const Description: String);
begin
  inherited Create;
  GdipCheck(GdipRecordMetafile(ReferenceDC, EmfType, @FrameRect, FrameUnit,
    PWideChar(Description), FNativeHandle));
end;

constructor TGPMetafile.Create(const Stream: IStream; const ReferenceDC: HDC;
  const EmfType: TGPEmfType; const Description: String);
begin
  inherited Create;
  GdipCheck(GdipRecordMetafileStream(Stream, ReferenceDC, EmfType, nil,
    MetafileFrameUnitGdi, PWideChar(Description), FNativeHandle));
end;

constructor TGPMetafile.Create(const Stream: IStream; const ReferenceDC: HDC;
  const FrameRect: TGPRectF; const FrameUnit: TGPMetafileFrameUnit;
  const EmfType: TGPEmfType; const Description: String);
begin
  inherited Create;
  GdipCheck(GdipRecordMetafileStream(Stream, ReferenceDC, EmfType, @FrameRect,
    FrameUnit, PWideChar(Description), FNativeHandle));
end;

constructor TGPMetafile.Create(const Stream: IStream; const ReferenceDC: HDC;
  const FrameRect: TGPRect; const FrameUnit: TGPMetafileFrameUnit;
  const EmfType: TGPEmfType; const Description: String);
begin
  inherited Create;
  GdipCheck(GdipRecordMetafileStreamI(Stream, ReferenceDC, EmfType, @FrameRect,
    FrameUnit, PWideChar(Description), FNativeHandle));
end;

constructor TGPMetafile.Create(const Filename: String; const ReferenceDC: HDC;
  const FrameRect: TGPRect; const FrameUnit: TGPMetafileFrameUnit;
  const EmfType: TGPEmfType; const Description: String);
begin
  inherited Create;
  GdipCheck(GdipRecordMetafileFileNameI(PWideChar(Filename), ReferenceDC,
    EmfType, @FrameRect, FrameUnit, PWideChar(Description), FNativeHandle));
end;

constructor TGPMetafile.Create(const ReferenceDC: HDC; const FrameRect: TGPRect;
  const FrameUnit: TGPMetafileFrameUnit; const EmfType: TGPEmfType;
  const Description: String);
begin
  inherited Create;
  GdipCheck(GdipRecordMetafileI(ReferenceDC, EmfType, @FrameRect, FrameUnit,
    PWideChar(Description), FNativeHandle));
end;

constructor TGPMetafile.Create(const Filename: String; const ReferenceDC: HDC;
  const EmfType: TGPEmfType; const Description: String);
begin
  inherited Create;
  GdipCheck(GdipRecordMetafileFileName(PWideChar(Filename), ReferenceDC,
    EmfType, nil, MetafileFrameUnitGdi, PWideChar(Description), FNativeHandle));
end;

constructor TGPMetafile.Create(const Filename: String; const ReferenceDC: HDC;
  const FrameRect: TGPRectF; const FrameUnit: TGPMetafileFrameUnit;
  const EmfType: TGPEmfType; const Description: String);
begin
  inherited Create;
  GdipCheck(GdipRecordMetafileFileName(PWideChar(Filename), ReferenceDC,
    EmfType, @FrameRect, FrameUnit, PWideChar(Description), FNativeHandle));
end;

class function TGPMetafile.EmfToWmfBits(const Emf: HEnhMetafile;
  const MapMode: Integer; const Flags: TGPEmfToWmfBitsFlags): IGPBuffer;
var
  Data: Pointer;
  Size: Integer;
begin
  Data := nil;
  Size := GdipEmfToWmfBits(Emf, 0, nil, MapMode, Flags);
  if (Size > 0) then
  begin
    GetMem(Data, Size);
    GdipEmfToWmfBits(Emf, Size, Data, MapMode, Flags);
  end;
  Result := TGPBuffer.Create(Data, Size);
end;

function TGPMetafile.GetDownLevelRasterizationLimit: Cardinal;
begin
  GdipCheck(GdipGetMetafileDownLevelRasterizationLimit(FNativeHandle, Result));
end;

function TGPMetafile.GetHEnhMetafile: HEnhMetafile;
begin
  GdipCheck(GdipGetHemfFromMetafile(FNativeHandle, Result));
end;

class function TGPMetafile.GetMetafileHeader(
  const Emf: HEnhMetafile): TGPMetafileHeader;
begin
  GdipCheck(GdipGetMetafileHeaderFromEmf(Emf, Result));
end;

class function TGPMetafile.GetMetafileHeader(const Wmf: HMetafile;
  const WmfPlaceableFileHeader: TWmfPlaceableFileHeader): TGPMetafileHeader;
begin
  GdipCheck(GdipGetMetafileHeaderFromWmf(Wmf, WmfPlaceableFileHeader, Result));
end;

function TGPMetafile.GetMetafileHeader: TGPMetafileHeader;
begin
  GdipCheck(GdipGetMetafileHeaderFromMetafile(FNativeHandle, Result));
end;

class function TGPMetafile.GetMetafileHeader(
  const Filename: String): TGPMetafileHeader;
begin
  GdipCheck(GdipGetMetafileHeaderFromFile(PWideChar(Filename), Result));
end;

class function TGPMetafile.GetMetafileHeader(
  const Stream: IStream): TGPMetafileHeader;
begin
  GdipCheck(GdipGetMetafileHeaderFromStream(Stream, Result));
end;

procedure TGPMetafile.PlayRecord(const RecordType: TEmfPlusRecordType;
  const Flags, DataSize: Integer; const Data: Pointer);
begin
  GdipCheck(GdipPlayMetafileRecord(FNativeHandle, RecordType, Flags, DataSize, Data));
end;

procedure TGPMetafile.SetDownLevelRasterizationLimit(const Value: Cardinal);
begin
  GdipCheck(GdipSetMetafileDownLevelRasterizationLimit(FNativeHandle, Value));
end;
{$ENDREGION 'GdiplusMetafile.h'}

{$REGION 'GdiplusImageAttributes.h'}

{ TGPImageAttributes }

procedure TGPImageAttributes.ClearBrushRemapTable;
begin
  ClearRemapTable(ColorAdjustTypeBrush);
end;

procedure TGPImageAttributes.ClearColorKey(const AdjustType: TGPColorAdjustType);
begin
  GdipCheck(GdipSetImageAttributesColorKeys(FNativeHandle, AdjustType, False,
    0, 0));
end;

procedure TGPImageAttributes.ClearColorMatrices(
  const AdjustType: TGPColorAdjustType);
begin
  GdipCheck(GdipSetImageAttributesColorMatrix(FNativeHandle, AdjustType,
    False, nil, nil, ColorMatrixFlagsDefault));
end;

procedure TGPImageAttributes.ClearColorMatrix(const AdjustType: TGPColorAdjustType);
begin
  GdipCheck(GdipSetImageAttributesColorMatrix(FNativeHandle, AdjustType,
    False, nil, nil, ColorMatrixFlagsDefault));
end;

procedure TGPImageAttributes.ClearGamma(const AdjustType: TGPColorAdjustType);
begin
  GdipCheck(GdipSetImageAttributesGamma(FNativeHandle, AdjustType,
    False, 0));
end;

procedure TGPImageAttributes.ClearNoOp(const AdjustType: TGPColorAdjustType);
begin
  GdipCheck(GdipSetImageAttributesNoOp(FNativeHandle, AdjustType, False));
end;

procedure TGPImageAttributes.ClearOutputChannel(
  const AdjustType: TGPColorAdjustType);
begin
  GdipCheck(GdipSetImageAttributesOutputChannel(FNativeHandle, AdjustType, False,
    ColorChannelFlagsLast));
end;

procedure TGPImageAttributes.ClearOutputChannelColorProfile(
  const AdjustType: TGPColorAdjustType);
begin
  GdipCheck(GdipSetImageAttributesOutputChannelColorProfile(FNativeHandle,
    AdjustType, False, nil));
end;

procedure TGPImageAttributes.ClearRemapTable(const AdjustType: TGPColorAdjustType);
begin
  GdipCheck(GdipSetImageAttributesRemapTable(FNativeHandle, AdjustType, False,
    0, nil));
end;

procedure TGPImageAttributes.ClearThreshold(const AdjustType: TGPColorAdjustType);
begin
  GdipCheck(GdipSetImageAttributesThreshold(FNativeHandle, AdjustType,
    False, 0));
end;

function TGPImageAttributes.Clone: IGPImageAttributes;
var
  NativeClone: GpImageAttributes;
begin
  GdipCheck(GdipCloneImageAttributes(FNativeHandle, NativeClone));
  Result := TGPImageAttributes.Create(NativeClone);
end;

constructor TGPImageAttributes.Create(const NativeAttributes: GpImageAttributes);
begin
  inherited Create;
  FNativeHandle := NativeAttributes;
end;

constructor TGPImageAttributes.Create;
begin
  inherited Create;
  GdipCheck(GdipCreateImageAttributes(FNativeHandle));
end;

destructor TGPImageAttributes.Destroy;
begin
  GdipDisposeImageAttributes(FNativeHandle);
  inherited;
end;

procedure TGPImageAttributes.GetAdjustedPalette(const ColorPalette: IGPColorPalette;
  const ColorAdjustType: TGPColorAdjustType);
begin
  Assert(Assigned(ColorPalette));
  GdipCheck(GdipGetImageAttributesAdjustedPalette(FNativeHandle,
    ColorPalette.NativePalette, ColorAdjustType));
end;

procedure TGPImageAttributes.Reset(const AdjustType: TGPColorAdjustType);
begin
  GdipCheck(GdipResetImageAttributes(FNativeHandle, AdjustType));
end;

procedure TGPImageAttributes.SetBrushRemapTable(const Map: array of TGPColorMap);
begin
  SetRemapTable(Map, ColorAdjustTypeBrush);
end;

procedure TGPImageAttributes.SetColorKey(const ColorLow, ColorHigh: TGPColor;
  const AdjustType: TGPColorAdjustType);
begin
  GdipCheck(GdipSetImageAttributesColorKeys(FNativeHandle, AdjustType, True,
    ColorLow.Value, ColorHigh.Value));
end;

procedure TGPImageAttributes.SetColorMatrices(const ColorMatrix,
  GrayMatrix: TGPColorMatrix; const Mode: TGPColorMatrixFlags;
  const AdjustType: TGPColorAdjustType);
begin
  GdipCheck(GdipSetImageAttributesColorMatrix(FNativeHandle, AdjustType,
    True, @ColorMatrix, @GrayMatrix, Mode));
end;

procedure TGPImageAttributes.SetColorMatrix(const ColorMatrix: TGPColorMatrix;
  const Mode: TGPColorMatrixFlags; const AdjustType: TGPColorAdjustType);
begin
  GdipCheck(GdipSetImageAttributesColorMatrix(FNativeHandle, AdjustType,
    True, @ColorMatrix, nil, Mode));
end;

procedure TGPImageAttributes.SetGamma(const Gamma: Single;
  const AdjustType: TGPColorAdjustType);
begin
  GdipCheck(GdipSetImageAttributesGamma(FNativeHandle, AdjustType,
    True, Gamma));
end;

procedure TGPImageAttributes.SetNoOp(const AdjustType: TGPColorAdjustType);
begin
  GdipCheck(GdipSetImageAttributesNoOp(FNativeHandle, AdjustType, True));
end;

procedure TGPImageAttributes.SetOutputChannel(
  const ChannelFlags: TGPColorChannelFlags; const AdjustType: TGPColorAdjustType);
begin
  GdipCheck(GdipSetImageAttributesOutputChannel(FNativeHandle, AdjustType, True,
    ChannelFlags));
end;

procedure TGPImageAttributes.SetOutputChannelColorProfile(
  const ColorProfileFilename: String; const AdjustType: TGPColorAdjustType);
begin
  GdipCheck(GdipSetImageAttributesOutputChannelColorProfile(FNativeHandle,
    AdjustType, True, PWideChar(ColorProfileFilename)));
end;

procedure TGPImageAttributes.SetRemapTable(const Map: array of TGPColorMap;
  const AdjustType: TGPColorAdjustType);
begin
  Assert(Length(Map) > 0);
  GdipCheck(GdipSetImageAttributesRemapTable(FNativeHandle, AdjustType, True,
    Length(Map), @Map[0]));
end;

procedure TGPImageAttributes.SetThreshold(const Threshold: Single;
  const AdjustType: TGPColorAdjustType);
begin
  GdipCheck(GdipSetImageAttributesThreshold(FNativeHandle, AdjustType,
    True, Threshold));
end;

procedure TGPImageAttributes.SetToIdentity(const AdjustType: TGPColorAdjustType);
begin
  GdipCheck(GdipSetImageAttributesToIdentity(FNativeHandle, AdjustType));
end;

procedure TGPImageAttributes.SetWrapMode(const Wrap: TGPWrapMode;
  const Color: TGPColor; const Clamp: Boolean);
begin
  GdipCheck(GdipSetImageAttributesWrapMode(FNativeHandle, Wrap, Color.Value,
    Clamp));
end;

procedure TGPImageAttributes.SetWrapMode(const Wrap: TGPWrapMode);
var
  Color: TGPColor;
begin
  Color := TGPColor.Black;
  SetWrapMode(Wrap, Color);
end;

{$ENDREGION 'GdiplusImageAttributes.h'}

{$REGION 'GdiplusMatrix.h'}

{ TGPMatrix }

function TGPMatrix.Clone: IGPMatrix;
var
  NativeClone: GpMatrix;
begin
  NativeClone := nil;
  GdipCheck(GdipCloneMatrix(FNativeHandle, NativeClone));
  Result := TGPMatrix.Create(NativeClone);
end;

constructor TGPMatrix.Create;
begin
  inherited Create;
  GdipCheck(GdipCreateMatrix(FNativeHandle));
end;

constructor TGPMatrix.Create(const NativeMatrix: GpMatrix);
begin
  inherited Create;
  FNativeHandle := NativeMatrix;
end;

constructor TGPMatrix.Create(const Rect: TGPRect; const DstPlg: TGPPlgPoints);
begin
  inherited Create;
  GdipCheck(GdipCreateMatrix3I(@Rect, @DstPlg, FNativeHandle));
end;

constructor TGPMatrix.Create(const Rect: TGPRectF; const DstPlg: TGPPlgPointsF);
begin
  inherited Create;
  GdipCheck(GdipCreateMatrix3(@Rect, @DstPlg, FNativeHandle));
end;

constructor TGPMatrix.Create(const M11, M12, M21, M22, DX, DY: Single);
begin
  inherited Create;
  GdipCheck(GdipCreateMatrix2(M11, M12, M21, M22, DX, DY, FNativeHandle));
end;

destructor TGPMatrix.Destroy;
begin
  GdipDeleteMatrix(FNativeHandle);
  inherited;
end;

function TGPMatrix.Equals(const Matrix: IGPMatrix): Boolean;
var
  B: Bool;
begin
  B := False;
  GdipCheck(GdipIsMatrixEqual(FNativeHandle, Matrix.NativeHandle, B));
  Result := B;
end;

function TGPMatrix.GetElements: TGPMatrixElements;
begin
  GdipCheck(GdipGetMatrixElements(FNativeHandle, @Result.M[0]));
end;

function TGPMatrix.GetIsIdentity: Boolean;
var
  B: Bool;
begin
  B := False;
  GdipCheck(GdipIsMatrixIdentity(FNativeHandle, B));
  Result := B;
end;

function TGPMatrix.GetIsInvertible: Boolean;
var
  B: Bool;
begin
  B := False;
  GdipCheck(GdipIsMatrixInvertible(FNativeHandle, B));
  Result := B;
end;

function TGPMatrix.GetOffsetX: Single;
var
  Elements: TGPMatrixElements;
begin
  Elements := GetElements;
  Result := Elements.DX;
end;

function TGPMatrix.GetOffsetY: Single;
var
  Elements: TGPMatrixElements;
begin
  Elements := GetElements;
  Result := Elements.DY;
end;

procedure TGPMatrix.Invert;
begin
  GdipCheck(GdipInvertMatrix(FNativeHandle));
end;

procedure TGPMatrix.Multiply(const Matrix: IGPMatrix; const Order: TGPMatrixOrder);
begin
  GdipCheck(GdipMultiplyMatrix(FNativeHandle, Matrix.NativeHandle, Order));
end;

procedure TGPMatrix.Reset;
begin
  GdipCheck(GdipSetMatrixElements(FNativeHandle, 1, 0, 0, 1, 0, 0));
end;

procedure TGPMatrix.Rotate(const Angle: Single; const Order: TGPMatrixOrder);
begin
  GdipCheck(GdipRotateMatrix(FNativeHandle, Angle, Order));
end;

procedure TGPMatrix.RotateAt(const Angle: Single; const Center: TGPPointF;
  const Order: TGPMatrixOrder);
begin
  if (Order = MatrixOrderPrepend) then
  begin
    GdipCheck(GdipTranslateMatrix(FNativeHandle, Center.X, Center.Y, Order));
    GdipCheck(GdipRotateMatrix(FNativeHandle, Angle, Order));
    GdipCheck(GdipTranslateMatrix(FNativeHandle, -Center.X, -Center.Y, Order));
  end
  else
  begin
    GdipCheck(GdipTranslateMatrix(FNativeHandle, -Center.X, -Center.Y, Order));
    GdipCheck(GdipRotateMatrix(FNativeHandle, Angle, Order));
    GdipCheck(GdipTranslateMatrix(FNativeHandle, Center.X, Center.Y, Order));
  end;
end;

procedure TGPMatrix.Scale(const ScaleX, ScaleY: Single;
  const Order: TGPMatrixOrder);
begin
  GdipCheck(GdipScaleMatrix(FNativeHandle, ScaleX, ScaleY, Order));
end;

procedure TGPMatrix.SetElements(const M11, M12, M21, M22, DX, DY: Single);
begin
  GdipCheck(GdipSetMatrixElements(FNativeHandle, M11, M12, M21, M22, DX, DY));
end;

procedure TGPMatrix.SetElements(const Value: TGPMatrixElements);
begin
  GdipCheck(GdipSetMatrixElements(FNativeHandle, Value.M11, Value.M12,
    Value.M21, Value.M22, Value.DX, Value.DY));
end;

procedure TGPMatrix.Shear(const ShearX, ShearY: Single;
  const Order: TGPMatrixOrder);
begin
  GdipCheck(GdipShearMatrix(FNativeHandle, ShearX, ShearY, Order));
end;

procedure TGPMatrix.TransformPoint(var Point: TGPPointF);
begin
  GdipCheck(GdipTransformMatrixPoints(FNativeHandle, @Point, 1));
end;

procedure TGPMatrix.TransformPoint(var Point: TGPPoint);
begin
  GdipCheck(GdipTransformMatrixPointsI(FNativeHandle, @Point, 1));
end;

procedure TGPMatrix.TransformPoints(const Points: array of TGPPointF);
begin
  Assert(Length(Points) > 0);
  GdipCheck(GdipTransformMatrixPoints(FNativeHandle, @Points[0], Length(Points)));
end;

procedure TGPMatrix.TransformPoints(const Points: array of TGPPoint);
begin
  Assert(Length(Points) > 0);
  GdipCheck(GdipTransformMatrixPointsI(FNativeHandle, @Points[0], Length(Points)));
end;

procedure TGPMatrix.TransformVector(var Point: TGPPoint);
begin
  GdipCheck(GdipVectorTransformMatrixPointsI(FNativeHandle, @Point, 1));
end;

procedure TGPMatrix.TransformVector(var Point: TGPPointF);
begin
  GdipCheck(GdipVectorTransformMatrixPoints(FNativeHandle, @Point, 1));
end;

procedure TGPMatrix.TransformVectors(const Points: array of TGPPoint);
begin
  Assert(Length(Points) > 0);
  GdipCheck(GdipVectorTransformMatrixPointsI(FNativeHandle, @Points[0], Length(Points)));
end;

procedure TGPMatrix.TransformVectors(const Points: array of TGPPointF);
begin
  Assert(Length(Points) > 0);
  GdipCheck(GdipVectorTransformMatrixPoints(FNativeHandle, @Points[0], Length(Points)));
end;

procedure TGPMatrix.Translate(const OffsetX, OffsetY: Single;
  const Order: TGPMatrixOrder);
begin
  GdipCheck(GdipTranslateMatrix(FNativeHandle, OffsetX, OffsetY, Order));
end;
{$ENDREGION 'GdiplusMatrix.h'}

{$REGION 'GdiplusBrush.h'}

{ TGPBrush }

function TGPBrush.Clone: IGPBrush;
var
  NativeClone: GpBrush;
begin
  GdipCheck(GdipCloneBrush(FNativeHandle, NativeClone));
  Result := TGPBrush.Create(NativeClone);
end;

constructor TGPBrush.Create(const NativeBrush: GpBrush);
begin
  inherited Create;
  FNativeHandle := NativeBrush;
end;

constructor TGPBrush.Create;
begin
  inherited Create;
end;

destructor TGPBrush.Destroy;
begin
  GdipDeleteBrush(FNativeHandle);
  inherited;
end;

function TGPBrush.GetType: TGPBrushType;
begin
  Result := TGPBrushType(-1);
  GdipCheck(GdipGetBrushType(FNativeHandle, Result));
end;

{ TGPSolidBrush }

constructor TGPSolidBrush.Create(const Color: TGPColor);
begin
  inherited Create;
  GdipCheck(GdipCreateSolidFill(Color.Value, FNativeHandle));
end;

constructor TGPSolidBrush.Create;
begin
  inherited Create;
end;

function TGPSolidBrush.GetColor: TGPColor;
begin
  GdipCheck(GdipGetSolidFillColor(FNativeHandle, Result.FArgb));
end;

procedure TGPSolidBrush.SetColor(const Value: TGPColor);
begin
  GdipCheck(GdipSetSolidFillColor(FNativeHandle, Value.FArgb));
end;

{ TGPTextureBrush }

constructor TGPTextureBrush.Create(const Image: IGPImage; const WrapMode: TGPWrapMode;
  const DstRect: TGPRect);
begin
  inherited Create;
  GdipCheck(GdipCreateTexture2I(Image.NativeHandle, WrapMode, DstRect.X,
    DstRect.Y, DstRect.Width, DstRect.Height, FNativeHandle));
end;

constructor TGPTextureBrush.Create(const Image: IGPImage; const WrapMode: TGPWrapMode;
  const DstRect: TGPRectF);
begin
  inherited Create;
  GdipCheck(GdipCreateTexture2(Image.NativeHandle, WrapMode, DstRect.X,
    DstRect.Y, DstRect.Width, DstRect.Height, FNativeHandle));
end;

constructor TGPTextureBrush.Create(const Image: IGPImage;
  const WrapMode: TGPWrapMode);
begin
  inherited Create;
  GdipCheck(GdipCreateTexture(Image.NativeHandle, WrapMode, FNativeHandle));
end;

constructor TGPTextureBrush.Create(const Image: IGPImage; const DstRect: TGPRectF;
  const ImageAttributes: IGPImageAttributes);
begin
  inherited Create;
  GdipCheck(GdipCreateTextureIA(Image.NativeHandle, GdipHandle(ImageAttributes),
    DstRect.X, DstRect.Y, DstRect.Width, DstRect.Height, FNativeHandle));
end;

constructor TGPTextureBrush.Create(const Image: IGPImage; const WrapMode: TGPWrapMode;
  const DstX, DstY, DstWidth, DstHeight: Integer);
begin
  inherited Create;
  GdipCheck(GdipCreateTexture2I(Image.NativeHandle, WrapMode, DstX, DstY,
    DstWidth, DstHeight, FNativeHandle));
end;

constructor TGPTextureBrush.Create;
begin
  inherited Create;
end;

constructor TGPTextureBrush.Create(const Image: IGPImage; const WrapMode: TGPWrapMode;
  const DstX, DstY, DstWidth, DstHeight: Single);
begin
  inherited Create;
  GdipCheck(GdipCreateTexture2(Image.NativeHandle, WrapMode, DstX, DstY,
    DstWidth, DstHeight, FNativeHandle));
end;

constructor TGPTextureBrush.Create(const Image: IGPImage; const DstRect: TGPRect;
  const ImageAttributes: IGPImageAttributes);
begin
  inherited Create;
  GdipCheck(GdipCreateTextureIAI(Image.NativeHandle, GdipHandle(ImageAttributes),
    DstRect.X, DstRect.Y, DstRect.Width, DstRect.Height, FNativeHandle));
end;

function TGPTextureBrush.GetImage: IGPImage;
var
  NativeImage: GpImage;
begin
  GdipCheck(GdipGetTextureImage(FNativeHandle, NativeImage));
  Result := TGPImage.Create(NativeImage);
end;

function TGPTextureBrush.GetTransform: IGPMatrix;
begin
  Result := TGPMatrix.Create;
  GdipCheck(GdipGetTextureTransform(FNativeHandle, Result.NativeHandle));
end;

function TGPTextureBrush.GetWrapMode: TGPWrapMode;
begin
  GdipCheck(GdipGetTextureWrapMode(FNativeHandle, Result));
end;

procedure TGPTextureBrush.MultiplyTransform(const Matrix: IGPMatrix;
  const Order: TGPMatrixOrder);
begin
  GdipCheck(GdipMultiplyTextureTransform(FNativeHandle, Matrix.NativeHandle,
    Order));
end;

procedure TGPTextureBrush.ResetTransform;
begin
  GdipCheck(GdipResetTextureTransform(FNativeHandle));
end;

procedure TGPTextureBrush.RotateTransform(const Angle: Single;
  const Order: TGPMatrixOrder);
begin
  GdipCheck(GdipRotateTextureTransform(FNativeHandle, Angle, Order));
end;

procedure TGPTextureBrush.ScaleTransform(const SX, SY: Single;
  const Order: TGPMatrixOrder);
begin
  GdipCheck(GdipScaleTextureTransform(FNativeHandle, SX, SY, Order));
end;

procedure TGPTextureBrush.SetTransform(const Value: IGPMatrix);
begin
  GdipCheck(GdipSetTextureTransform(FNativeHandle, Value.NativeHandle));
end;

procedure TGPTextureBrush.SetWrapMode(const Value: TGPWrapMode);
begin
  GdipCheck(GdipSetTextureWrapMode(FNativeHandle, Value));
end;

procedure TGPTextureBrush.TranslateTransform(const DX, DY: Single;
  const Order: TGPMatrixOrder);
begin
  GdipCheck(GdipTranslateTextureTransform(FNativeHandle, DX, DY, Order));
end;

{ TGPBlend }

constructor TGPBlend.Create(const ACount: Integer);
begin
  inherited Create;
  SetLength(FFactors, ACount);
  SetLength(FPositions, ACount);
end;

constructor TGPBlend.Create(const AFactors, APositions: array of Single);
begin
  Assert(Length(AFactors) > 0);
  Assert(Length(APositions) = Length(AFactors));
  Create(Length(AFactors));
  Move(AFactors[0], FFactors[0], Length(AFactors) * SizeOf(Single));
  Move(APositions[0], FPositions[0], Length(APositions) * SizeOf(Single));
end;

function TGPBlend.GetCount: Integer;
begin
  Result := Length(FFactors);
end;

function TGPBlend.GetFactor(const Index: Integer): Single;
begin
  Result := FFactors[Index];
end;

function TGPBlend.GetFactorPtr: PSingle;
begin
  Result := @FFactors[0];
end;

function TGPBlend.GetPosition(const Index: Integer): Single;
begin
  Result := FPositions[Index];
end;

function TGPBlend.GetPositionPtr: PSingle;
begin
  Result := @FPositions[0];
end;

procedure TGPBlend.SetFactor(const Index: Integer; const Value: Single);
begin
  FFactors[Index] := Value;
end;

procedure TGPBlend.SetPosition(const Index: Integer; const Value: Single);
begin
  FPositions[Index] := Value;
end;

{ TGPColorBlend }

constructor TGPColorBlend.Create(const ACount: Integer);
begin
  inherited Create;
  SetLength(FColors, ACount);
  SetLength(FPositions, ACount);
end;

constructor TGPColorBlend.Create(const AColors: array of TGPColor;
  const APositions: array of Single);
begin
  Assert(Length(AColors) > 0);
  Assert(Length(AColors) = Length(APositions));
  Create(Length(AColors));
  Move(AColors[0], FColors[0], Length(AColors) * SizeOf(TGPColor));
  Move(APositions[0], FPositions[0], Length(APositions) * SizeOf(Single));
end;

function TGPColorBlend.GetColor(const Index: Integer): TGPColor;
begin
  Result := FColors[Index];
end;

function TGPColorBlend.GetColorPtr: PGPColor;
begin
  Result := @FColors[0];
end;

function TGPColorBlend.GetCount: Integer;
begin
  Result := Length(FColors);
end;

function TGPColorBlend.GetPosition(const Index: Integer): Single;
begin
  Result := FPositions[Index];
end;

function TGPColorBlend.GetPositionPtr: PSingle;
begin
  Result := @FPositions[0];
end;

procedure TGPColorBlend.SetColor(const Index: Integer; const Value: TGPColor);
begin
  FColors[Index] := Value;
end;

procedure TGPColorBlend.SetPosition(const Index: Integer; const Value: Single);
begin
  FPositions[Index] := Value;
end;

{ TGPLinearGradientBrush }

constructor TGPLinearGradientBrush.Create(const Rect: TGPRectF; const Color1,
  Color2: TGPColor; const Mode: TGPLinearGradientMode);
begin
  inherited Create;
  GdipCheck(GdipCreateLineBrushFromRect(@Rect, Color1.Value, Color2.Value,
    Mode, WrapModeTile, FNativeHandle));
end;

constructor TGPLinearGradientBrush.Create(const Rect: TGPRect; const Color1,
  Color2: TGPColor; const Mode: TGPLinearGradientMode);
begin
  inherited Create;
  GdipCheck(GdipCreateLineBrushFromRectI(@Rect, Color1.Value, Color2.Value,
    Mode, WrapModeTile, FNativeHandle));
end;

constructor TGPLinearGradientBrush.Create(const Point1, Point2: TGPPointF;
  const Color1, Color2: TGPColor);
begin
  inherited Create;
  GdipCheck(GdipCreateLineBrush(@Point1, @Point2, Color1.Value, Color2.Value,
    WrapModeTile, FNativeHandle));
end;

constructor TGPLinearGradientBrush.Create(const Point1, Point2: TGPPoint;
  const Color1, Color2: TGPColor);
begin
  inherited Create;
  GdipCheck(GdipCreateLineBrushI(@Point1, @Point2, Color1.Value, Color2.Value,
    WrapModeTile, FNativeHandle));
end;

constructor TGPLinearGradientBrush.Create(const Rect: TGPRectF; const Color1,
  Color2: TGPColor; const Angle: Single; const IsAngleScalable: Boolean);
begin
  inherited Create;
  GdipCheck(GdipCreateLineBrushFromRectWithAngle(@Rect, Color1.Value, Color2.Value,
    Angle, IsAngleScalable, WrapModeTile, FNativeHandle));
end;

constructor TGPLinearGradientBrush.Create(const Rect: TGPRect; const Color1,
  Color2: TGPColor; const Angle: Single; const IsAngleScalable: Boolean);
begin
  inherited Create;
  GdipCheck(GdipCreateLineBrushFromRectWithAngleI(@Rect, Color1.Value, Color2.Value,
    Angle, IsAngleScalable, WrapModeTile, FNativeHandle));
end;

constructor TGPLinearGradientBrush.Create;
begin
  inherited Create;
end;

function TGPLinearGradientBrush.GetBlend: IGPBlend;
var
  Count: Integer;
begin
  Count := 0;
  GdipCheck(GdipGetLineBlendCount(FNativeHandle, Count));
  Result := TGPBlend.Create(Count);
  if (Count > 0) then
    GdipCheck(GdipGetLineBlend(FNativeHandle, Result.FactorPtr,
      Result.PositionPtr, Count));
end;

function TGPLinearGradientBrush.GetGammaCorrection: Boolean;
var
  B: Bool;
begin
  GdipCheck(GdipGetLineGammaCorrection(FNativeHandle, B));
  Result := B;
end;

function TGPLinearGradientBrush.GetInterpolationColors: IGPColorBlend;
var
  Count: Integer;
begin
  Count := 0;
  GdipCheck(GdipGetLinePresetBlendCount(FNativeHandle, Count));
  Result := TGPColorBlend.Create(Count);
  if (Count > 0) then
    GdipCheck(GdipGetLinePresetBlend(FNativeHandle, PARGB(Result.ColorPtr),
      Result.PositionPtr, Count));
end;

function TGPLinearGradientBrush.GetLinearColors: TGPLinearColors;
begin
  GdipCheck(GdipGetLineColors(FNativeHandle, @Result[0]));
end;

procedure TGPLinearGradientBrush.GetRectangle(out Rect: TGPRectF);
begin
  GdipCheck(GdipGetLineRect(FNativeHandle, Rect));
end;

function TGPLinearGradientBrush.GetRectangle: TGPRectF;
begin
  GdipCheck(GdipGetLineRect(FNativeHandle, Result));
end;

procedure TGPLinearGradientBrush.GetRectangle(out Rect: TGPRect);
begin
  GdipCheck(GdipGetLineRectI(FNativeHandle, Rect));
end;

function TGPLinearGradientBrush.GetTransform: IGPMatrix;
begin
  Result := TGPMatrix.Create;
  GdipCheck(GdipGetLineTransform(FNativeHandle, Result.NativeHandle));
end;

function TGPLinearGradientBrush.GetWrapMode: TGPWrapMode;
begin
  GdipCheck(GdipGetLineWrapMode(FNativeHandle, Result));
end;

procedure TGPLinearGradientBrush.MultiplyTransform(const Matrix: IGPMatrix;
  const Order: TGPMatrixOrder);
begin
  GdipCheck(GdipMultiplyLineTransform(FNativeHandle, Matrix.NativeHandle, Order));
end;

procedure TGPLinearGradientBrush.ResetTransform;
begin
  GdipCheck(GdipResetLineTransform(FNativeHandle));
end;

procedure TGPLinearGradientBrush.RotateTransform(const Angle: Single;
  const Order: TGPMatrixOrder);
begin
  GdipCheck(GdipRotateLineTransform(FNativeHandle, Angle, Order));
end;

procedure TGPLinearGradientBrush.ScaleTransform(const SX, SY: Single;
  const Order: TGPMatrixOrder);
begin
  GdipCheck(GdipScaleLineTransform(FNativeHandle, SX, SY, Order));
end;

procedure TGPLinearGradientBrush.SetBlend(const Value: IGPBlend);
begin
  Assert(Assigned(Value));
  GdipCheck(GdipSetLineBlend(FNativeHandle, Value.FactorPtr,
    Value.PositionPtr, Value.Count));
end;

procedure TGPLinearGradientBrush.SetBlendBellShape(const Focus, Scale: Single);
begin
  GdipCheck(GdipSetLineSigmaBlend(FNativeHandle, Focus, Scale));
end;

procedure TGPLinearGradientBrush.SetBlendTriangularShape(const Focus,
  Scale: Single);
begin
  GdipCheck(GdipSetLineLinearBlend(FNativeHandle, Focus, Scale));
end;

procedure TGPLinearGradientBrush.SetGammaCorrection(const Value: Boolean);
begin
  GdipCheck(GdipSetLineGammaCorrection(FNativeHandle, Value));
end;

procedure TGPLinearGradientBrush.SetInterpolationColors(const Value: IGPColorBlend);
begin
  Assert(Assigned(Value));
  GdipCheck(GdipSetLinePresetBlend(FNativeHandle, PARGB(Value.ColorPtr),
    Value.PositionPtr, Value.Count));
end;

procedure TGPLinearGradientBrush.SetLinearColors(const Value: TGPLinearColors);
begin
  GdipCheck(GdipSetLineColors(FNativeHandle, Value[0].Value, Value[1].Value));
end;

procedure TGPLinearGradientBrush.SetTransform(const Value: IGPMatrix);
begin
  GdipCheck(GdipSetLineTransform(FNativeHandle, Value.NativeHandle));
end;

procedure TGPLinearGradientBrush.SetWrapMode(const Value: TGPWrapMode);
begin
  GdipCheck(GdipSetLineWrapMode(FNativeHandle, Value));
end;

procedure TGPLinearGradientBrush.TranslateTransform(const DX, DY: Single;
  const Order: TGPMatrixOrder);
begin
  GdipCheck(GdipTranslateLineTransform(FNativeHandle, DX, DY, Order));
end;

{ TGPHatchBrush }

constructor TGPHatchBrush.Create(const HatchStyle: TGPHatchStyle; const ForeColor,
  BackColor: TGPColor);
begin
  inherited Create;
  GdipCheck(GdipCreateHatchBrush(HatchStyle, ForeColor.Value, BackColor.Value,
    FNativeHandle));
end;

constructor TGPHatchBrush.Create(const HatchStyle: TGPHatchStyle;
  const ForeColor: TGPColor);
begin
  inherited Create;
  GdipCheck(GdipCreateHatchBrush(HatchStyle, ForeColor.Value, TGPColor.Black,
    FNativeHandle));
end;

constructor TGPHatchBrush.Create;
begin
  inherited Create;
end;

function TGPHatchBrush.GetBackgroundColor: TGPColor;
begin
  GdipCheck(GdipGetHatchBackgroundColor(FNativeHandle, Result.FArgb));
end;

function TGPHatchBrush.GetForegroundColor: TGPColor;
begin
  GdipCheck(GdipGetHatchForegroundColor(FNativeHandle, Result.FArgb));
end;

function TGPHatchBrush.GetHatchStyle: TGPHatchStyle;
begin
  GdipCheck(GdipGetHatchStyle(FNativeHandle, Result));
end;
{$ENDREGION 'GdiplusBrush.h'}

{$REGION 'GdiplusPen.h'}

{ TGPPen }

function TGPPen.Clone: IGPPen;
var
  NativeClone: GpPen;
begin
  GdipCheck(GdipClonePen(FNativeHandle, NativeClone));
  Result := TGPPen.Create(FNativeHandle);
end;

constructor TGPPen.Create(const Brush: IGPBrush; const Width: Single);
begin
  inherited Create;
  GdipCheck(GdipCreatePen2(Brush.NativeHandle, Width, UnitWorld, FNativeHandle));
end;

constructor TGPPen.Create(const Color: TGPColor; const Width: Single);
begin
  inherited Create;
  GdipCheck(GdipCreatePen1(Color.Value, Width, UnitWorld, FNativeHandle));
end;

constructor TGPPen.Create(const NativePen: GpPen);
begin
  inherited Create;
  FNativeHandle := NativePen;
end;

destructor TGPPen.Destroy;
begin
  GdipDeletePen(FNativeHandle);
  inherited;
end;

function TGPPen.GetAlignment: TGPPenAlignment;
begin
  GdipCheck(GdipGetPenMode(FNativeHandle, Result));
end;

function TGPPen.GetBrush: IGPBrush;
var
  PenType: TGPPenType;
  NativeBrush: GpBrush;
begin
  Result := nil;
  GdipCheck(GdipGetPenFillType(FNativeHandle, PenType));
  case PenType of
    PenTypeSolidColor:
      Result := TGPSolidBrush.Create;

    PenTypeHatchFill:
      Result := TGPHatchBrush.Create;

    PenTypeTextureFill:
      Result := TGPTextureBrush.Create;

    PenTypePathGradient:
      Result := TGPBrush.Create;

    PenTypeLinearGradient:
      Result := TGPLinearGradientBrush.Create;
  end;

  if Assigned(Result) then
  begin
    NativeBrush := nil;
    GdipCheck(GdipGetPenBrushFill(FNativeHandle, NativeBrush));
    Result.NativeHandle := NativeBrush;
  end;
end;

function TGPPen.GetColor: TGPColor;
var
  PenType: TGPPenType;
begin
  GdipCheck(GdipGetPenFillType(FNativeHandle, PenType));
  if (PenType <> PenTypeSolidColor) then
    GdipCheck(WrongState);
  GdipCheck(GdipGetPenColor(FNativeHandle, Result.FArgb));
end;

function TGPPen.GetCompoundArray: IGPCompoundArray;
var
  Count: Integer;
begin
  Count := 0;
  GdipCheck(GdipGetPenCompoundCount(FNativeHandle, Count));
  Result := TGPArray<Single>.Create(Count);
  if (Count > 0) then
    GdipCheck(GdipGetPenCompoundArray(FNativeHandle, Result.ItemPtr, Count));
end;

function TGPPen.GetCustomEndCap: IGPCustomLineCap;
var
  NativeCap: GpCustomLineCap;
begin
  NativeCap := nil;
  GdipCheck(GdipGetPenCustomEndCap(FNativeHandle, NativeCap));
  Result := TGPCustomLineCap.Create(NativeCap);
end;

function TGPPen.GetCustomStartCap: IGPCustomLineCap;
var
  NativeCap: GpCustomLineCap;
begin
  NativeCap := nil;
  GdipCheck(GdipGetPenCustomStartCap(FNativeHandle, NativeCap));
  Result := TGPCustomLineCap.Create(NativeCap);
end;

function TGPPen.GetDashCap: TGPDashCap;
begin
  GdipCheck(GdipGetPenDashCap197819(FNativeHandle, Result));
end;

function TGPPen.GetDashOffset: Single;
begin
  GdipCheck(GdipGetPenDashOffset(FNativeHandle, Result));
end;

function TGPPen.GetDashPattern: IGPDashPattern;
var
  Count: Integer;
begin
  Count := 0;
  GdipCheck(GdipGetPenDashCount(FNativeHandle, Count));
  Result := TGPArray<Single>.Create(Count);
  if (Count > 0) then
    GdipCheck(GdipGetPenDashArray(FNativeHandle, Result.ItemPtr, Count));
end;

function TGPPen.GetDashStyle: TGPDashStyle;
begin
  GdipCheck(GdipGetPenDashStyle(FNativeHandle, Result));
end;

function TGPPen.GetEndCap: TGPLineCap;
begin
  GdipCheck(GdipGetPenEndCap(FNativeHandle, Result));
end;

function TGPPen.GetLineJoin: TGPLineJoin;
begin
  GdipCheck(GdipGetPenLineJoin(FNativeHandle, Result));
end;

function TGPPen.GetMiterLimit: Single;
begin
  GdipCheck(GdipGetPenMiterLimit(FNativeHandle, Result));
end;

function TGPPen.GetPenType: TGPPenType;
begin
  GdipCheck(GdipGetPenFillType(FNativeHandle, Result));
end;

function TGPPen.GetStartCap: TGPLineCap;
begin
  GdipCheck(GdipGetPenStartCap(FNativeHandle, Result));
end;

function TGPPen.GetTransform: IGPMatrix;
begin
  Result := TGPMatrix.Create;
  GdipCheck(GdipGetPenTransform(FNativeHandle, Result.NativeHandle));
end;

function TGPPen.GetWidth: Single;
begin
  GdipCheck(GdipGetPenWidth(FNativeHandle, Result));
end;

procedure TGPPen.MultiplyTransform(const Matrix: IGPMatrix;
  const Order: TGPMatrixOrder);
begin
  GdipCheck(GdipMultiplyPenTransform(FNativeHandle, Matrix.NativeHandle, Order));
end;

procedure TGPPen.ResetTransform;
begin
  GdipCheck(GdipResetPenTransform(FNativeHandle));
end;

procedure TGPPen.RotateTransform(const Angle: Single; const Order: TGPMatrixOrder);
begin
  GdipCheck(GdipRotatePenTransform(FNativeHandle, Angle, Order));
end;

procedure TGPPen.ScaleTransform(const SX, SY: Single; const Order: TGPMatrixOrder);
begin
  GdipCheck(GdipScalePenTransform(FNativeHandle, SX, SY, Order));
end;

procedure TGPPen.SetAlignment(const Value: TGPPenAlignment);
begin
  GdipCheck(GdipSetPenMode(FNativeHandle, Value));
end;

procedure TGPPen.SetBrush(const Value: IGPBrush);
begin
  GdipCheck(GdipSetPenBrushFill(FNativeHandle, Value.NativeHandle));
end;

procedure TGPPen.SetColor(const Value: TGPColor);
begin
  GdipCheck(GdipSetPenColor(FNativeHandle, Value.FArgb));
end;

procedure TGPPen.SetCompoundArray(const Value: IGPCompoundArray);
begin
  Assert(Assigned(Value));
  GdipCheck(GdipSetPenCompoundArray(FNativeHandle, Value.ItemPtr, Value.Count));
end;

procedure TGPPen.SetCustomEndCap(const Value: IGPCustomLineCap);
begin
  GdipCheck(GdipSetPenCustomEndCap(FNativeHandle, GdipHandle(Value)));
end;

procedure TGPPen.SetCustomStartCap(const Value: IGPCustomLineCap);
begin
  GdipCheck(GdipSetPenCustomStartCap(FNativeHandle, GdipHandle(Value)));
end;

procedure TGPPen.SetDashCap(const Value: TGPDashCap);
begin
  GdipCheck(GdipSetPenDashCap197819(FNativeHandle, Value));
end;

procedure TGPPen.SetDashOffset(const Value: Single);
begin
  GdipCheck(GdipSetPenDashOffset(FNativeHandle, Value));
end;

procedure TGPPen.SetDashPattern(const Pattern: array of Single);
begin
  Assert(Length(Pattern) > 0);
  GdipCheck(GdipSetPenDashArray(FNativeHandle, @Pattern[0], Length(Pattern)));
end;

procedure TGPPen.SetDashPatternInternal(const Value: IGPDashPattern);
begin
  Assert(Assigned(Value));
  GdipCheck(GdipSetPenDashArray(FNativeHandle, Value.ItemPtr, Value.Count));
end;

procedure TGPPen.SetDashStyle(const Value: TGPDashStyle);
begin
  GdipCheck(GdipSetPenDashStyle(FNativeHandle, Value));
end;

procedure TGPPen.SetEndCap(const Value: TGPLineCap);
begin
  GdipCheck(GdipSetPenEndCap(FNativeHandle, Value));
end;

procedure TGPPen.SetLineCap(const StartCap, EndCap: TGPLineCap;
  const DashCap: TGPDashCap);
begin
  GdipCheck(GdipSetPenLineCap197819(FNativeHandle, StartCap, EndCap, DashCap));
end;

procedure TGPPen.SetLineJoin(const Value: TGPLineJoin);
begin
  GdipCheck(GdipSetPenLineJoin(FNativeHandle, Value));
end;

procedure TGPPen.SetMiterLimit(const Value: Single);
begin
  GdipCheck(GdipSetPenMiterLimit(FNativeHandle, Value));
end;

procedure TGPPen.SetStartCap(const Value: TGPLineCap);
begin
  GdipCheck(GdipSetPenStartCap(FNativeHandle, Value));
end;

procedure TGPPen.SetTransform(const Value: IGPMatrix);
begin
  GdipCheck(GdipSetPenTransform(FNativeHandle, Value.NativeHandle));
end;

procedure TGPPen.SetWidth(const Value: Single);
begin
  GdipCheck(GdipSetPenWidth(FNativeHandle, Value));
end;

procedure TGPPen.TranslateTransform(const DX, DY: Single;
  const Order: TGPMatrixOrder);
begin
  GdipCheck(GdipTranslatePenTransform(FNativeHandle, DX, DY, Order));
end;
{$ENDREGION 'GdiplusPen.h'}

{$REGION 'GdiplusStringFormat.h'}

{ TGPStringFormat }

function TGPStringFormat.Clone: IGPStringFormat;
var
  NativeClone: GpStringFormat;
begin
  NativeClone := nil;
  GdipCheck(GdipCloneStringFormat(FNativeHandle, NativeClone));
  Result := TGPStringFormat.Create(NativeClone);
end;

constructor TGPStringFormat.Create(const NativeFormat: GpStringFormat);
begin
  inherited Create;
  FNativeHandle := NativeFormat;
end;

constructor TGPStringFormat.Create(const FormatFlags: TGPStringFormatFlags;
  const Language: LangID);
begin
  inherited Create;
  GdipCheck(GdipCreateStringFormat(FormatFlags, Language, FNativeHandle));
end;

constructor TGPStringFormat.Create(const Format: IGPStringFormat);
begin
  inherited Create;
  GdipCheck(GdipCloneStringFormat(GdipHandle(Format), FNativeHandle));
end;

destructor TGPStringFormat.Destroy;
begin
  GdipDeleteStringFormat(FNativeHandle);
  inherited;
end;

class function TGPStringFormat.GenericDefault: IGPStringFormat;
var
  NativeDefault: GpStringFormat;
begin
  if (FGenericDefault = nil) then
  begin
    NativeDefault := nil;
    GdipCheck(GdipStringFormatGetGenericDefault(NativeDefault));
    FGenericDefault := TGPStringFormat.Create(NativeDefault);
  end;
  Result := FGenericDefault;
end;

class function TGPStringFormat.GenericTypographic: IGPStringFormat;
var
  NativeDefault: GpStringFormat;
begin
  if (FGenericTypographic = nil) then
  begin
    NativeDefault := nil;
    GdipCheck(GdipStringFormatGetGenericTypographic(NativeDefault));
    FGenericTypographic := TGPStringFormat.Create(NativeDefault);
  end;
  Result := FGenericTypographic;
end;

function TGPStringFormat.GetAlignment: TGPStringAlignment;
begin
  GdipCheck(GdipGetStringFormatAlign(FNativeHandle, Result));
end;

function TGPStringFormat.GetDigitSubstitutionLanguage: LangID;
begin
  GdipCheck(GdipGetStringFormatDigitSubstitution(FNativeHandle, @Result, nil));
end;

function TGPStringFormat.GetDigitSubstitutionMethod: TGPStringDigitSubstitute;
begin
  GdipCheck(GdipGetStringFormatDigitSubstitution(FNativeHandle, nil, @Result));
end;

function TGPStringFormat.GetFormatFlags: TGPStringFormatFlags;
begin
  GdipCheck(GdipGetStringFormatFlags(FNativeHandle, Result));
end;

function TGPStringFormat.GetHotkeyPrefix: TGPHotkeyPrefix;
begin
  GdipCheck(GdipGetStringFormatHotkeyPrefix(FNativeHandle, Result));
end;

function TGPStringFormat.GetLineAlignment: TGPStringAlignment;
begin
  GdipCheck(GdipGetStringFormatLineAlign(FNativeHandle, Result));
end;

function TGPStringFormat.GetMeasurableCharacterRangeCount: Integer;
begin
  GdipCheck(GdipGetStringFormatMeasurableCharacterRangeCount(FNativeHandle,
    Result));
end;

function TGPStringFormat.GetTabStops(out FirstTabOffset: Single): IGPTabStops;
var
  Count: Integer;
begin
  GdipCheck(GdipGetStringFormatTabStopCount(FNativeHandle, Count));
  Result := TGPArray<Single>.Create(Count);
  if (Count > 0) then
    GdipCheck(GdipGetStringFormatTabStops(FNativeHandle, Count, FirstTabOffset,
      Result.ItemPtr));
end;

function TGPStringFormat.GetTrimming: TGPStringTrimming;
begin
  GdipCheck(GdipGetStringFormatTrimming(FNativeHandle, Result));
end;

procedure TGPStringFormat.SetAlignment(const Value: TGPStringAlignment);
begin
  GdipCheck(GdipSetStringFormatAlign(FNativeHandle, Value));
end;

procedure TGPStringFormat.SetDigitSubstitution(const Language: LangID;
  const Substitute: TGPStringDigitSubstitute);
begin
  GdipCheck(GdipSetStringFormatDigitSubstitution(FNativeHandle, Language, Substitute));
end;

procedure TGPStringFormat.SetFormatFlags(const Value: TGPStringFormatFlags);
begin
  GdipCheck(GdipSetStringFormatFlags(FNativeHandle, Value));
end;

procedure TGPStringFormat.SetHotkeyPrefix(const Value: TGPHotkeyPrefix);
begin
  GdipCheck(GdipSetStringFormatHotkeyPrefix(FNativeHandle, Value));
end;

procedure TGPStringFormat.SetLineAlignment(const Value: TGPStringAlignment);
begin
  GdipCheck(GdipSetStringFormatLineAlign(FNativeHandle, Value));
end;

procedure TGPStringFormat.SetMeasurableCharacterRanges(
  const Ranges: IGPCharacterRanges);
begin
  Assert(Assigned(Ranges));
  GdipCheck(GdipSetStringFormatMeasurableCharacterRanges(FNativeHandle,
    Ranges.Count, Ranges.ItemPtr));
end;

procedure TGPStringFormat.SetTabStops(const FirstTabOffset: Single;
  const TabStops: array of Single);
begin
  Assert(Length(TabStops) > 0);
  GdipCheck(GdipSetStringFormatTabStops(FNativeHandle, FirstTabOffset,
    Length(TabStops), @TabStops[0]));
end;

procedure TGPStringFormat.SetTrimming(const Value: TGPStringTrimming);
begin
  GdipCheck(GdipSetStringFormatTrimming(FNativeHandle, Value));
end;
{$ENDREGION 'GdiplusStringFormat.h'}

{$REGION 'GdiplusPath.h'}

{ TGPPathData }

constructor TGPPathData.Create(const ACount: Integer);
begin
  inherited Create;
  SetLength(FPoints, ACount);
  SetLength(FTypes, ACount);
end;

function TGPPathData.GetCount: Integer;
begin
  Result := Length(FPoints);
end;

function TGPPathData.GetNativePathData: TGPNativePathData;
begin
  Result.Count := Length(FPoints);
  Result.Points := @FPoints[0];
  Result.Types := @FTypes[0];
end;

function TGPPathData.GetPoint(const Index: Integer): TGPPointF;
begin
  Result := FPoints[Index];
end;

function TGPPathData.GetPointPtr: PGPPointF;
begin
  Result := @FPoints[0];
end;

function TGPPathData.GetType(const Index: Integer): Byte;
begin
  Result := FTypes[Index];
end;

function TGPPathData.GetTypePtr: PByte;
begin
  Result := @FTypes[0];
end;

procedure TGPPathData.SetCount(const Value: Integer);
begin
  if (Value <> Length(FPoints)) then
  begin
    SetLength(FPoints, Value);
    SetLength(FTypes, Value);
  end;
end;

{ TGPGraphicsPath }

procedure TGPGraphicsPath.AddArc(const Rect: TGPRectF; const StartAngle,
  SweepAngle: Single);
begin
  AddArc(Rect.X, Rect.Y, Rect.Width, Rect.Height, StartAngle, SweepAngle);
end;

procedure TGPGraphicsPath.AddArc(const X, Y, Width, Height: Integer;
  const StartAngle, SweepAngle: Single);
begin
  GdipCheck(GdipAddPathArcI(FNativeHandle, X, Y, Width, Height, StartAngle, SweepAngle));
end;

procedure TGPGraphicsPath.AddArc(const Rect: TGPRect; const StartAngle,
  SweepAngle: Single);
begin
  AddArc(Rect.X, Rect.Y, Rect.Width, Rect.Height, StartAngle, SweepAngle);
end;

procedure TGPGraphicsPath.AddArc(const X, Y, Width, Height, StartAngle,
  SweepAngle: Single);
begin
  GdipCheck(GdipAddPathArc(FNativeHandle, X, Y, Width, Height, StartAngle, SweepAngle));
end;

procedure TGPGraphicsPath.AddBezier(const Pt1, Pt2, Pt3, Pt4: TGPPoint);
begin
  AddBezier(Pt1.X, Pt1.Y, Pt2.X, Pt2.Y, Pt3.X, Pt3.Y, Pt4.X, Pt4.Y);
end;

procedure TGPGraphicsPath.AddBezier(const Pt1, Pt2, Pt3, Pt4: TGPPointF);
begin
  AddBezier(Pt1.X, Pt1.Y, Pt2.X, Pt2.Y, Pt3.X, Pt3.Y, Pt4.X, Pt4.Y);
end;

procedure TGPGraphicsPath.AddBezier(const X1, Y1, X2, Y2, X3, Y3, X4, Y4: Single);
begin
  GdipCheck(GdipAddPathBezier(FNativeHandle, X1, Y1, X2, Y2, X3, Y3, X4, Y4));
end;

procedure TGPGraphicsPath.AddBezier(const X1, Y1, X2, Y2, X3, Y3, X4,
  Y4: Integer);
begin
  GdipCheck(GdipAddPathBezierI(FNativeHandle, X1, Y1, X2, Y2, X3, Y3, X4, Y4));
end;

procedure TGPGraphicsPath.AddBeziers(const Points: array of TGPPointF);
begin
  Assert(Length(Points) > 0);
  GdipCheck(GdipAddPathBeziers(FNativeHandle, @Points[0], Length(Points)));
end;

procedure TGPGraphicsPath.AddBeziers(const Points: array of TGPPoint);
begin
  Assert(Length(Points) > 0);
  GdipCheck(GdipAddPathBeziersI(FNativeHandle, @Points[0], Length(Points)));
end;

procedure TGPGraphicsPath.AddClosedCurve(const Points: array of TGPPoint);
begin
  Assert(Length(Points) > 0);
  GdipCheck(GdipAddPathClosedCurveI(FNativeHandle, @Points[0], Length(Points)));
end;

procedure TGPGraphicsPath.AddClosedCurve(const Points: array of TGPPoint;
  const Tension: Single);
begin
  Assert(Length(Points) > 0);
  GdipCheck(GdipAddPathClosedCurve2I(FNativeHandle, @Points[0], Length(Points), Tension));
end;

procedure TGPGraphicsPath.AddClosedCurve(const Points: array of TGPPointF);
begin
  Assert(Length(Points) > 0);
  GdipCheck(GdipAddPathClosedCurve(FNativeHandle, @Points[0], Length(Points)));
end;

procedure TGPGraphicsPath.AddClosedCurve(const Points: array of TGPPointF;
  const Tension: Single);
begin
  Assert(Length(Points) > 0);
  GdipCheck(GdipAddPathClosedCurve2(FNativeHandle, @Points[0], Length(Points), Tension));
end;

procedure TGPGraphicsPath.AddCurve(const Points: array of TGPPoint);
begin
  Assert(Length(Points) > 0);
  GdipCheck(GdipAddPathCurveI(FNativeHandle, @Points[0], Length(Points)));
end;

procedure TGPGraphicsPath.AddCurve(const Points: array of TGPPoint;
  const Tension: Single);
begin
  Assert(Length(Points) > 0);
  GdipCheck(GdipAddPathCurve2I(FNativeHandle, @Points[0], Length(Points), Tension));
end;

procedure TGPGraphicsPath.AddCurve(const Points: array of TGPPoint; const Offset,
  NumberOfSegments: Integer; const Tension: Single);
begin
  Assert(Length(Points) > 0);
  GdipCheck(GdipAddPathCurve3I(FNativeHandle, @Points[0], Length(Points),
    Offset, NumberOfSegments, Tension));
end;

procedure TGPGraphicsPath.AddCurve(const Points: array of TGPPointF);
begin
  Assert(Length(Points) > 0);
  GdipCheck(GdipAddPathCurve(FNativeHandle, @Points[0], Length(Points)));
end;

procedure TGPGraphicsPath.AddCurve(const Points: array of TGPPointF;
  const Tension: Single);
begin
  Assert(Length(Points) > 0);
  GdipCheck(GdipAddPathCurve2(FNativeHandle, @Points[0], Length(Points), Tension));
end;

procedure TGPGraphicsPath.AddCurve(const Points: array of TGPPointF; const Offset,
  NumberOfSegments: Integer; const Tension: Single);
begin
  Assert(Length(Points) > 0);
  GdipCheck(GdipAddPathCurve3(FNativeHandle, @Points[0], Length(Points),
    Offset, NumberOfSegments, Tension));
end;

procedure TGPGraphicsPath.AddEllipse(const X, Y, Width, Height: Single);
begin
  GdipCheck(GdipAddPathEllipse(FNativeHandle, X, Y, Width, Height));
end;

procedure TGPGraphicsPath.AddEllipse(const Rect: TGPRectF);
begin
  AddEllipse(Rect.X, Rect.Y, Rect.Width, Rect.Height);
end;

procedure TGPGraphicsPath.AddEllipse(const X, Y, Width, Height: Integer);
begin
  GdipCheck(GdipAddPathEllipseI(FNativeHandle, X, Y, Width, Height));
end;

procedure TGPGraphicsPath.AddEllipse(const Rect: TGPRect);
begin
  AddEllipse(Rect.X, Rect.Y, Rect.Width, Rect.Height);
end;

procedure TGPGraphicsPath.AddLine(const Pt1, Pt2: TGPPoint);
begin
  AddLine(Pt1.X, Pt1.Y, Pt2.X, Pt2.Y);
end;

procedure TGPGraphicsPath.AddLine(const X1, Y1, X2, Y2: Integer);
begin
  GdipCheck(GdipAddPathLineI(FNativeHandle, X1, Y1, X2, Y2));
end;

procedure TGPGraphicsPath.AddLine(const Pt1, Pt2: TGPPointF);
begin
  AddLine(Pt1.X, Pt1.Y, Pt2.X, Pt2.Y);
end;

procedure TGPGraphicsPath.AddLine(const X1, Y1, X2, Y2: Single);
begin
  GdipCheck(GdipAddPathLine(FNativeHandle, X1, Y1, X2, Y2));
end;

procedure TGPGraphicsPath.AddLines(const Points: array of TGPPoint);
begin
  Assert(Length(Points) > 0);
  GdipCheck(GdipAddPathLine2I(FNativeHandle, @Points[0], Length(Points)));
end;

procedure TGPGraphicsPath.AddLines(const Points: array of TGPPointF);
begin
  Assert(Length(Points) > 0);
  GdipCheck(GdipAddPathLine2(FNativeHandle, @Points[0], Length(Points)));
end;

procedure TGPGraphicsPath.AddPath(const AddingPath: IGPGraphicsPath;
  const Connect: Boolean);
begin
  GdipCheck(GdipAddPathPath(FNativeHandle, GdipHandle(AddingPath), Connect));
end;

procedure TGPGraphicsPath.AddPie(const Rect: TGPRect; const StartAngle,
  SweepAngle: Single);
begin
  AddPie(Rect.X, Rect.Y, Rect.Width, Rect.Height, StartAngle, SweepAngle);
end;

procedure TGPGraphicsPath.AddPie(const X, Y, Width, Height: Integer;
  const StartAngle, SweepAngle: Single);
begin
  GdipCheck(GdipAddPathPieI(FNativeHandle, X, Y, Width, Height, StartAngle, SweepAngle));
end;

procedure TGPGraphicsPath.AddPie(const Rect: TGPRectF; const StartAngle,
  SweepAngle: Single);
begin
  AddPie(Rect.X, Rect.Y, Rect.Width, Rect.Height, StartAngle, SweepAngle);
end;

procedure TGPGraphicsPath.AddPie(const X, Y, Width, Height, StartAngle,
  SweepAngle: Single);
begin
  GdipCheck(GdipAddPathPie(FNativeHandle, X, Y, Width, Height, StartAngle, SweepAngle));
end;

procedure TGPGraphicsPath.AddPolygon(const Points: array of TGPPoint);
begin
  Assert(Length(Points) > 0);
  GdipCheck(GdipAddPathPolygonI(FNativeHandle, @Points[0], Length(Points)));
end;

procedure TGPGraphicsPath.AddPolygon(const Points: array of TGPPointF);
begin
  Assert(Length(Points) > 0);
  GdipCheck(GdipAddPathPolygon(FNativeHandle, @Points[0], Length(Points)));
end;

procedure TGPGraphicsPath.AddRectangle(const Rect: TGPRect);
begin
  GdipCheck(GdipAddPathRectangleI(FNativeHandle, Rect.X, Rect.Y,
    Rect.Width, Rect.Height));
end;

procedure TGPGraphicsPath.AddRectangle(const Rect: TGPRectF);
begin
  GdipCheck(GdipAddPathRectangle(FNativeHandle, Rect.X, Rect.Y,
    Rect.Width, Rect.Height));
end;

procedure TGPGraphicsPath.AddRectangles(const Rects: array of TGPRect);
begin
  Assert(Length(Rects) > 0);
  GdipCheck(GdipAddPathRectanglesI(FNativeHandle, @Rects[0], Length(Rects)));
end;

procedure TGPGraphicsPath.AddRectangles(const Rects: array of TGPRectF);
begin
  Assert(Length(Rects) > 0);
  GdipCheck(GdipAddPathRectangles(FNativeHandle, @Rects[0], Length(Rects)));
end;

procedure TGPGraphicsPath.AddString(const Str: String; const Family: IGPFontFamily;
  const Style: TGPFontStyle; const EmSize: Single; const Origin: TGPPoint;
  const Format: IGPStringFormat);
var
  Rect: TGPRect;
begin
  Rect.Initialize(Origin.X, Origin.Y, 0, 0);
  GdipCheck(GdipAddPathStringI(FNativeHandle, PWideChar(Str), Length(Str),
    GdipHandle(Family), Style, EmSize, @Rect, GdipHandle(Format)));
end;

procedure TGPGraphicsPath.AddString(const Str: String; const Family: IGPFontFamily;
  const Style: TGPFontStyle; const EmSize: Single; const LayoutRect: TGPRect;
  const Format: IGPStringFormat);
begin
  GdipCheck(GdipAddPathStringI(FNativeHandle, PWideChar(Str), Length(Str),
    GdipHandle(Family), Style, EmSize, @LayoutRect, GdipHandle(Format)));
end;

procedure TGPGraphicsPath.AddString(const Str: String; const Family: IGPFontFamily;
  const Style: TGPFontStyle; const EmSize: Single; const Origin: TGPPointF;
  const Format: IGPStringFormat);
var
  Rect: TGPRectF;
begin
  Rect.Initialize(Origin.X, Origin.Y, 0, 0);
  GdipCheck(GdipAddPathString(FNativeHandle, PWideChar(Str), Length(Str),
    GdipHandle(Family), Style, EmSize, @Rect, GdipHandle(Format)));
end;

procedure TGPGraphicsPath.AddString(const Str: String; const Family: IGPFontFamily;
  const Style: TGPFontStyle; const EmSize: Single; const LayoutRect: TGPRectF;
  const Format: IGPStringFormat);
begin
  GdipCheck(GdipAddPathString(FNativeHandle, PWideChar(Str), Length(Str),
    GdipHandle(Family), Style, EmSize, @LayoutRect, GdipHandle(Format)));
end;

procedure TGPGraphicsPath.ClearMarkers;
begin
  GdipCheck(GdipClearPathMarkers(FNativeHandle));
end;

function TGPGraphicsPath.Clone: IGPGraphicsPath;
var
  NativeClone: GpPath;
begin
  NativeClone := nil;
  GdipCheck(GdipClonePath(FNativeHandle, NativeClone));
  Result := TGPGraphicsPath.Create(NativeClone);
end;

procedure TGPGraphicsPath.CloseAllFigures;
begin
  GdipCheck(GdipClosePathFigures(FNativeHandle));
end;

procedure TGPGraphicsPath.CloseFigure;
begin
  GdipCheck(GdipClosePathFigure(FNativeHandle));
end;

constructor TGPGraphicsPath.Create(const Points: array of TGPPoint;
  const Types: array of Byte; const FillMode: TGPFillMode);
begin
  Assert(Length(Points) > 0);
  Assert(Length(Points) = Length(Types));
  inherited Create;
  GdipCheck(GdipCreatePath2I(@Points[0], @Types[0], Length(Points), FillMode,
    FNativeHandle));
end;

constructor TGPGraphicsPath.Create(const NativePath: GpPath);
begin
  inherited Create;
  FNativeHandle := NativePath;
end;

constructor TGPGraphicsPath.Create(const FillMode: TGPFillMode);
begin
  inherited Create;
  GdipCheck(GdipCreatePath(FillMode, FNativeHandle));
end;

constructor TGPGraphicsPath.Create(const Points: array of TGPPointF;
  const Types: array of Byte; const FillMode: TGPFillMode);
begin
  Assert(Length(Points) > 0);
  Assert(Length(Points) = Length(Types));
  inherited Create;
  GdipCheck(GdipCreatePath2(@Points[0], @Types[0], Length(Points), FillMode,
    FNativeHandle));
end;

destructor TGPGraphicsPath.Destroy;
begin
  GdipDeletePath(FNativeHandle);
  inherited;
end;

procedure TGPGraphicsPath.Flatten(const Matrix: IGPMatrix; const Flatness: Single);
begin
  GdipCheck(GdipFlattenPath(FNativeHandle, GdipHandle(Matrix), Flatness));
end;

procedure TGPGraphicsPath.GetBounds(out Bounds: TGPRectF; const Matrix: IGPMatrix;
  const Pen: IGPPen);
begin
  GdipCheck(GdipGetPathWorldBounds(FNativeHandle, @Bounds,
    GdipHandle(Matrix), GdipHandle(Pen)));
end;

procedure TGPGraphicsPath.GetBounds(out Bounds: TGPRect; const Matrix: IGPMatrix;
  const Pen: IGPPen);
begin
  GdipCheck(GdipGetPathWorldBoundsI(FNativeHandle, @Bounds,
    GdipHandle(Matrix), GdipHandle(Pen)));
end;

function TGPGraphicsPath.GetFillMode: TGPFillMode;
begin
  Result := FillModeAlternate;
  GdipCheck(GdipGetPathFillMode(FNativeHandle, Result));
end;

function TGPGraphicsPath.GetLastPoint: TGPPointF;
begin
  GdipCheck(GdipGetPathLastPoint(FNativeHandle, Result));
end;

function TGPGraphicsPath.GetPathData: IGPPathData;
var
  Count: Integer;
  NativeData: TGPNativePathData;
begin
  Count := GetPointCount;
  Result := TGPPathData.Create(Count);
  NativeData := Result.NativePathData;
  GdipCheck(GdipGetPathData(FNativeHandle, @NativeData));
end;

function TGPGraphicsPath.GetPathPoints: IGPPathPoints;
var
  Count: Integer;
begin
  Count := GetPointCount;
  Result := TGPArray<TGPPointF>.Create(Count);
  GdipCheck(GdipGetPathPoints(FNativeHandle, Result.ItemPtr, Count));
end;

function TGPGraphicsPath.GetPathPointsI: IGPPathPointsI;
var
  Count: Integer;
begin
  Count := GetPointCount;
  Result := TGPArray<TGPPoint>.Create(Count);
  GdipCheck(GdipGetPathPointsI(FNativeHandle, Result.ItemPtr, Count));
end;

function TGPGraphicsPath.GetPathTypes: IGPPathTypes;
var
  Count: Integer;
begin
  Count := GetPointCount;
  Result := TGPArray<Byte>.Create(Count);
  GdipCheck(GdipGetPathTypes(FNativeHandle, Result.ItemPtr, Count));
end;

function TGPGraphicsPath.GetPointCount: Integer;
begin
  Result := 0;
  GdipCheck(GdipGetPointCount(FNativeHandle, Result));
end;

function TGPGraphicsPath.IsOutlineVisible(const X, Y: Integer; const Pen: IGPPen;
  const G: IGPGraphics): Boolean;
var
  B: Bool;
begin
  B := False;
  GdipCheck(GdipIsOutlineVisiblePathPointI(FNativeHandle, X, Y, GdipHandle(Pen),
    GdipHandle(G), B));
  Result := B;
end;

function TGPGraphicsPath.IsOutlineVisible(const Point: TGPPointF; const Pen: IGPPen;
  const G: IGPGraphics): Boolean;
begin
  Result := IsOutlineVisible(Point.X, Point.Y, Pen, G);
end;

function TGPGraphicsPath.IsOutlineVisible(const X, Y: Single; const Pen: IGPPen;
  const G: IGPGraphics): Boolean;
var
  B: Bool;
begin
  B := False;
  GdipCheck(GdipIsOutlineVisiblePathPoint(FNativeHandle, X, Y, GdipHandle(Pen),
    GdipHandle(G), B));
  Result := B;
end;

function TGPGraphicsPath.IsOutlineVisible(const Point: TGPPoint; const Pen: IGPPen;
  const G: IGPGraphics): Boolean;
begin
  Result := IsOutlineVisible(Point.X, Point.Y, Pen, G);
end;

function TGPGraphicsPath.IsVisible(const X, Y: Single;
  const G: IGPGraphics): Boolean;
var
  B: Bool;
begin
  B := False;
  GdipCheck(GdipIsVisiblePathPoint(FNativeHandle, X, Y, GdipHandle(G), B));
  Result := B;
end;

function TGPGraphicsPath.IsVisible(const X, Y: Integer;
  const G: IGPGraphics): Boolean;
var
  B: Bool;
begin
  B := False;
  GdipCheck(GdipIsVisiblePathPointI(FNativeHandle, X, Y, GdipHandle(G), B));
  Result := B;
end;

function TGPGraphicsPath.IsVisible(const Point: TGPPointF;
  const G: IGPGraphics): Boolean;
begin
  Result := IsVisible(Point.X, Point.Y, G);
end;

function TGPGraphicsPath.IsVisible(const Point: TGPPoint;
  const G: IGPGraphics): Boolean;
begin
  Result := IsVisible(Point.X, Point.Y, G);
end;

procedure TGPGraphicsPath.Outline(const Matrix: IGPMatrix; const Flatness: Single);
begin
  GdipCheck(GdipWindingModeOutline(FNativeHandle, GdipHandle(Matrix), Flatness));
end;

procedure TGPGraphicsPath.Reset;
begin
  GdipCheck(GdipResetPath(FNativeHandle));
end;

procedure TGPGraphicsPath.Reverse;
begin
  GdipCheck(GdipReversePath(FNativeHandle));
end;

procedure TGPGraphicsPath.SetFillMode(const Value: TGPFillMode);
begin
  GdipCheck(GdipSetPathFillMode(FNativeHandle, Value));
end;

procedure TGPGraphicsPath.SetMarker;
begin
  GdipCheck(GdipSetPathMarker(FNativeHandle));
end;

procedure TGPGraphicsPath.StartFigure;
begin
  GdipCheck(GdipStartPathFigure(FNativeHandle));
end;

procedure TGPGraphicsPath.Transform(const Matrix: IGPMatrix);
begin
  if Assigned(Matrix) then
    GdipCheck(GdipTransformPath(FNativeHandle, Matrix.NativeHandle));
end;

procedure TGPGraphicsPath.Warp(const DestPoints: array of TGPPointF;
  const SrcRect: TGPRectF; const Matrix: IGPMatrix; const WarpMode: TGPWarpMode;
  const Flatness: Single);
begin
  Assert(Length(DestPoints) > 0);
  GdipCheck(GdipWarpPath(FNativeHandle, GdipHandle(Matrix), @DestPoints[0],
    Length(DestPoints), SrcRect.X, SrcRect.Y, SrcRect.Width, SrcRect.Height,
    WarpMode, Flatness));
end;

procedure TGPGraphicsPath.Widen(const Pen: IGPPen; const Matrix: IGPMatrix;
  const Flatness: Single);
begin
  GdipCheck(GdipWidenPath(FNativeHandle, Pen.NativeHandle, GdipHandle(Matrix), Flatness));
end;

{ TGPGraphicsPathIterator }

function TGPGraphicsPathIterator.CopyData(const StartIndex,
  EndIndex: Integer): IGPPathData;
var
  Count: Integer;
begin
  Count := EndIndex - StartIndex + 1;
  Result := TGPPathData.Create(Count);
  GdipCheck(GdipPathIterCopyData(FNativeHandle, Count, Result.PointPtr,
    Result.TypePtr, StartIndex, EndIndex));
  Result.Count := Count;
end;

constructor TGPGraphicsPathIterator.Create(const Path: IGPGraphicsPath);
begin
  inherited Create;
  GdipCheck(GdipCreatePathIter(FNativeHandle, GdipHandle(Path)));
end;

destructor TGPGraphicsPathIterator.Destroy;
begin
  GdipDeletePathIter(FNativeHandle);
  inherited;
end;

function TGPGraphicsPathIterator.Enumerate: IGPPathData;
var
  Count: Integer;
begin
  Count := GetCount;
  Result := TGPPathData.Create(Count);
  GdipCheck(GdipPathIterEnumerate(FNativeHandle, Count, Result.PointPtr,
    Result.TypePtr, Count));
  Result.Count := Count;
end;

function TGPGraphicsPathIterator.GetCount: Integer;
begin
  GdipCheck(GdipPathIterGetCount(FNativeHandle, Result));
end;

function TGPGraphicsPathIterator.GetSubpathCount: Integer;
begin
  GdipCheck(GdipPathIterGetSubpathCount(FNativeHandle, Result));
end;

function TGPGraphicsPathIterator.HasCurve: Boolean;
var
  B: Bool;
begin
  GdipCheck(GdipPathIterHasCurve(FNativeHandle, B));
  Result := B;
end;

function TGPGraphicsPathIterator.NextMarker(out StartIndex,
  EndIndex: Integer): Integer;
begin
  GdipCheck(GdipPathIterNextMarker(FNativeHandle, Result, StartIndex, EndIndex));
end;

function TGPGraphicsPathIterator.NextMarker(const Path: IGPGraphicsPath): Integer;
begin
  GdipCheck(GdipPathIterNextMarkerPath(FNativeHandle, Result, GdipHandle(Path)));
end;

function TGPGraphicsPathIterator.NextPathType(out PathType: Byte; out StartIndex,
  EndIndex: Integer): Integer;
begin
  GdipCheck(GdipPathIterNextPathType(FNativeHandle, Result, PathType,
    StartIndex, EndIndex));
end;

function TGPGraphicsPathIterator.NextSubPath(out StartIndex, EndIndex: Integer;
  out IsClosed: Boolean): Integer;
var
  B: Bool;
begin
  GdipCheck(GdipPathIterNextSubpath(FNativeHandle, Result, StartIndex,
    EndIndex, B));
  IsClosed := B;
end;

function TGPGraphicsPathIterator.NextSubPath(const Path: IGPGraphicsPath;
  out IsClosed: Boolean): Integer;
var
  B: Bool;
begin
  GdipCheck(GdipPathIterNextSubpathPath(FNativeHandle, Result,
    GdipHandle(Path), B));
  IsClosed := B;
end;

procedure TGPGraphicsPathIterator.Rewind;
begin
  GdipCheck(GdipPathIterRewind(FNativeHandle));
end;

{ TGPPathGradientBrush }

constructor TGPPathGradientBrush.Create(const Path: IGPGraphicsPath);
begin
  inherited Create;
  GdipCheck(GdipCreatePathGradientFromPath(Path.NativeHandle, FNativeHandle));
end;

constructor TGPPathGradientBrush.Create(const Points: array of TGPPoint;
  const WrapMode: TGPWrapMode);
begin
  inherited Create;
  Assert(Length(Points) > 0);
  GdipCheck(GdipCreatePathGradientI(@Points[0], Length(Points), WrapMode, FNativeHandle));
end;

constructor TGPPathGradientBrush.Create(const Points: array of TGPPointF;
  const WrapMode: TGPWrapMode);
begin
  inherited Create;
  Assert(Length(Points) > 0);
  GdipCheck(GdipCreatePathGradient(@Points[0], Length(Points), WrapMode, FNativeHandle));
end;

function TGPPathGradientBrush.GetBlend: IGPBlend;
var
  Count: Integer;
begin
  Count := 0;
  GdipCheck(GdipGetPathGradientBlendCount(FNativeHandle, Count));
  Result := TGPBlend.Create(Count);
  if (Count > 0) then
    GdipCheck(GdipGetPathGradientBlend(FNativeHandle, Result.FactorPtr,
      Result.PositionPtr, Count));
end;

function TGPPathGradientBrush.GetCenterColor: TGPColor;
begin
  GdipCheck(GdipGetPathGradientCenterColor(FNativeHandle, Result.FArgb));
end;

function TGPPathGradientBrush.GetCenterPoint: TGPPointF;
begin
  GdipCheck(GdipGetPathGradientCenterPoint(FNativeHandle, Result));
end;

function TGPPathGradientBrush.GetCenterPointI: TGPPoint;
begin
  GdipCheck(GdipGetPathGradientCenterPointI(FNativeHandle, Result));
end;

procedure TGPPathGradientBrush.GetFocusScales(out XScale, YScale: Single);
begin
  GdipCheck(GdipGetPathGradientFocusScales(FNativeHandle, XScale, YScale));
end;

function TGPPathGradientBrush.GetGammaCorrection: Boolean;
var
  B: Bool;
begin
  GdipCheck(GdipGetPathGradientGammaCorrection(FNativeHandle, B));
  Result := B;
end;

function TGPPathGradientBrush.GetGraphicsPath: IGPGraphicsPath;
var
  NativePath: GpPath;
begin
  NativePath := nil;
  GdipCheck(GdipGetPathGradientPath(FNativeHandle, NativePath));
  Result := TGPGraphicsPath.Create(NativePath);
end;

function TGPPathGradientBrush.GetInterpolationColors: IGPColorBlend;
var
  Count: Integer;
begin
  Count := 0;
  GdipCheck(GdipGetPathGradientPresetBlendCount(FNativeHandle, Count));
  Result := TGPColorBlend.Create(Count);
  if (Count > 0) then
    GdipCheck(GdipGetPathGradientPresetBlend(FNativeHandle, PARGB(Result.ColorPtr),
      Result.PositionPtr, Count));
end;

function TGPPathGradientBrush.GetPointCount: Integer;
begin
  GdipCheck(GdipGetPathGradientPointCount(FNativeHandle, Result));
end;

function TGPPathGradientBrush.GetRectangle: TGPRectF;
begin
  GdipCheck(GdipGetPathGradientRect(FNativeHandle, Result));
end;

function TGPPathGradientBrush.GetRectangleI: TGPRect;
begin
  GdipCheck(GdipGetPathGradientRectI(FNativeHandle, Result));
end;

function TGPPathGradientBrush.GetSurroundColors: IGPColors;
var
  Count: Integer;
begin
  GdipCheck(GdipGetPathGradientSurroundColorCount(FNativeHandle, Count));
  Result := TGPArray<TGPColor>.Create(Count);
  if (Count > 0) then
  begin
    GdipCheck(GdipGetPathGradientSurroundColorsWithCount(FNativeHandle,
      Result.ItemPtr, Count));
    Result.Count := Count;
  end;
end;

function TGPPathGradientBrush.GetTransform: IGPMatrix;
begin
  Result := TGPMatrix.Create;
  GdipCheck(GdipGetPathGradientTransform(FNativeHandle, Result.NativeHandle));
end;

function TGPPathGradientBrush.GetWrapMode: TGPWrapMode;
begin
  GdipCheck(GdipGetPathGradientWrapMode(FNativeHandle, Result));
end;

procedure TGPPathGradientBrush.MultiplyTransform(const Matrix: IGPMatrix;
  const Order: TGPMatrixOrder);
begin
  GdipCheck(GdipMultiplyPathGradientTransform(FNativeHandle,
    Matrix.NativeHandle, Order));
end;

procedure TGPPathGradientBrush.ResetTransform;
begin
  GdipCheck(GdipResetPathGradientTransform(FNativeHandle));
end;

procedure TGPPathGradientBrush.RotateTransform(const Angle: Single;
  const Order: TGPMatrixOrder);
begin
  GdipCheck(GdipRotatePathGradientTransform(FNativeHandle, Angle, Order));
end;

procedure TGPPathGradientBrush.ScaleTransform(const SX, SY: Single;
  const Order: TGPMatrixOrder);
begin
  GdipCheck(GdipScalePathGradientTransform(FNativeHandle, SX, SY, Order));
end;

procedure TGPPathGradientBrush.SetBlend(const Value: IGPBlend);
begin
  Assert(Assigned(Value));
  GdipCheck(GdipSetPathGradientBlend(FNativeHandle, Value.FactorPtr,
    Value.PositionPtr, Value.Count));
end;

procedure TGPPathGradientBrush.SetBlendBellShape(const Focus, Scale: Single);
begin
  GdipCheck(GdipSetPathGradientSigmaBlend(FNativeHandle, Focus, Scale));
end;

procedure TGPPathGradientBrush.SetBlendTriangularShape(const Focus,
  Scale: Single);
begin
  GdipCheck(GdipSetPathGradientLinearBlend(FNativeHandle, Focus, Scale));
end;

procedure TGPPathGradientBrush.SetCenterColor(const Value: TGPColor);
begin
  GdipCheck(GdipSetPathGradientCenterColor(FNativeHandle, Value.FArgb));
end;

procedure TGPPathGradientBrush.SetCenterPoint(const Value: TGPPointF);
begin
  GdipCheck(GdipSetPathGradientCenterPoint(FNativeHandle, @Value));
end;

procedure TGPPathGradientBrush.SetCenterPointI(const Value: TGPPoint);
begin
  GdipCheck(GdipSetPathGradientCenterPointI(FNativeHandle, @Value));
end;

procedure TGPPathGradientBrush.SetFocusScales(const XScale, YScale: Single);
begin
  GdipCheck(GdipSetPathGradientFocusScales(FNativeHandle, XScale, YScale));
end;

procedure TGPPathGradientBrush.SetGammaCorrection(const Value: Boolean);
begin
  GdipCheck(GdipSetPathGradientGammaCorrection(FNativeHandle, Value));
end;

procedure TGPPathGradientBrush.SetGraphicsPath(const Value: IGPGraphicsPath);
begin
  if Assigned(Value) then
    GdipCheck(GdipSetPathGradientPath(FNativeHandle, Value.NativeHandle))
  else
    GdipCheck(InvalidParameter);
end;

procedure TGPPathGradientBrush.SetInterpolationColors(const Value: IGPColorBlend);
begin
  GdipCheck(GdipSetPathGradientPresetBlend(FNativeHandle, PARGB(Value.ColorPtr),
    Value.PositionPtr, Value.Count));
end;

procedure TGPPathGradientBrush.SetSurroundColors(const Colors: array of TGPColor);
var
  Count: Integer;
begin
  Assert(Length(Colors) > 0);
  Count := Length(Colors);
  GdipCheck(GdipSetPathGradientSurroundColorsWithCount(FNativeHandle,
    @Colors[0], Count));
end;

procedure TGPPathGradientBrush.SetSurroundColorsInternal(const Value: IGPColors);
var
  Count: Integer;
begin
  Assert(Assigned(Value));
  Count := Value.Count;
  GdipCheck(GdipSetPathGradientSurroundColorsWithCount(FNativeHandle,
    Value.ItemPtr, Count));
  Value.Count := Count;
end;

procedure TGPPathGradientBrush.SetTransform(const Value: IGPMatrix);
begin
  GdipCheck(GdipSetPathGradientTransform(FNativeHandle, Value.NativeHandle));
end;

procedure TGPPathGradientBrush.SetWrapMode(const Value: TGPWrapMode);
begin
  GdipCheck(GdipSetPathGradientWrapMode(FNativeHandle, Value));
end;

procedure TGPPathGradientBrush.TranslateTransform(const DX, DY: Single;
  const Order: TGPMatrixOrder);
begin
  GdipCheck(GdipTranslatePathGradientTransform(FNativeHandle, DX, DY, Order));
end;
{$ENDREGION 'GdiplusPath.h'}

{$REGION 'GdiplusGraphics.h'}

{ TGPGraphics }

procedure TGPGraphics.AddMetafileComment(const Data: array of Byte);
begin
  Assert(Length(Data) > 0);
  GdipCheck(GdipComment(FNativeHandle, Length(Data), @Data[0]));
end;

function TGPGraphics.BeginContainer: TGPGraphicsContainer;
begin
  GdipCheck(GdipBeginContainer2(FNativeHandle, Result));
end;

function TGPGraphics.BeginContainer(const DstRect, SrcRect: TGPRect;
  const MeasureUnit: TGPUnit): TGPGraphicsContainer;
begin
  GdipCheck(GdipBeginContainerI(FNativeHandle, @DstRect, @SrcRect, MeasureUnit, Result));
end;

function TGPGraphics.BeginContainer(const DstRect, SrcRect: TGPRectF;
  const MeasureUnit: TGPUnit): TGPGraphicsContainer;
begin
  GdipCheck(GdipBeginContainer(FNativeHandle, @DstRect, @SrcRect, MeasureUnit, Result));
end;

procedure TGPGraphics.Clear(const Color: TGPColor);
begin
  GdipCheck(GdipGraphicsClear(FNativeHandle, Color.Value));
end;

constructor TGPGraphics.Create(const Image: IGPImage);
begin
  inherited Create;
  Assert(Assigned(Image));
  GdipCheck(GdipGetImageGraphicsContext(Image.NativeHandle, FNativeHandle));
end;

constructor TGPGraphics.Create(const DC: HDC);
begin
  inherited Create;
  GdipCheck(GdipCreateFromHDC(DC, FNativeHandle));
end;

constructor TGPGraphics.Create(const DC: HDC; const Device: THandle);
begin
  inherited Create;
  GdipCheck(GdipCreateFromHDC2(DC, Device, FNativeHandle));
end;

constructor TGPGraphics.Create(const Window: HWnd; const ICM: Boolean);
begin
  inherited Create;
  if (ICM) then
    GdipCheck(GdipCreateFromHWNDICM(Window, FNativeHandle))
  else
    GdipCheck(GdipCreateFromHWND(Window, FNativeHandle));
end;

destructor TGPGraphics.Destroy;
begin
  GdipDeleteGraphics(FNativeHandle);
  inherited;
end;

procedure TGPGraphics.DrawArc(const Pen: IGPPen; const Rect: TGPRect;
  const StartAngle, SweepAngle: Single);
begin
  DrawArc(Pen, Rect.X, Rect.Y, Rect.Width, Rect.Height, StartAngle, SweepAngle);
end;

procedure TGPGraphics.DrawArc(const Pen: IGPPen; const X, Y, Width, Height: Integer;
  const StartAngle, SweepAngle: Single);
begin
  GdipCheck(GdipDrawArcI(FNativeHandle, Pen.NativeHandle, X, Y, Width, Height,
    StartAngle, SweepAngle));
end;

procedure TGPGraphics.DrawArc(const Pen: IGPPen; const Rect: TGPRectF;
  const StartAngle, SweepAngle: Single);
begin
  DrawArc(Pen, Rect.X, Rect.Y, Rect.Width, Rect.Height, StartAngle, SweepAngle);
end;

procedure TGPGraphics.DrawArc(const Pen: IGPPen; const X, Y, Width, Height,
  StartAngle, SweepAngle: Single);
begin
  GdipCheck(GdipDrawArc(FNativeHandle, Pen.NativeHandle, X, Y, Width, Height,
    StartAngle, SweepAngle));
end;

procedure TGPGraphics.DrawBezier(const Pen: IGPPen; const Pt1, Pt2, Pt3,
  Pt4: TGPPoint);
begin
  DrawBezier(Pen, Pt1.X, Pt1.Y, Pt2.X, Pt2.Y, Pt3.X, Pt3.Y, Pt4.X, Pt4.Y);
end;

procedure TGPGraphics.DrawBezier(const Pen: IGPPen; const X1, Y1, X2, Y2, X3, Y3,
  X4, Y4: Integer);
begin
  GdipCheck(GdipDrawBezierI(FNativeHandle, Pen.NativeHandle, X1, Y1, X2, Y2,
    X3, Y3, X4, Y4));
end;

procedure TGPGraphics.DrawBezier(const Pen: IGPPen; const Pt1, Pt2, Pt3,
  Pt4: TGPPointF);
begin
  DrawBezier(Pen, Pt1.X, Pt1.Y, Pt2.X, Pt2.Y, Pt3.X, Pt3.Y, Pt4.X, Pt4.Y);
end;

procedure TGPGraphics.DrawBezier(const Pen: IGPPen; const X1, Y1, X2, Y2, X3, Y3,
  X4, Y4: Single);
begin
  GdipCheck(GdipDrawBezier(FNativeHandle, Pen.NativeHandle, X1, Y1, X2, Y2,
    X3, Y3, X4, Y4));
end;

procedure TGPGraphics.DrawBeziers(const Pen: IGPPen; const Points: array of TGPPoint);
begin
  Assert(Length(Points) > 0);
  GdipCheck(GdipDrawBeziersI(FNativeHandle, Pen.NativeHandle, @Points[0], Length(Points)));
end;

procedure TGPGraphics.DrawBeziers(const Pen: IGPPen;
  const Points: array of TGPPointF);
begin
  Assert(Length(Points) > 0);
  GdipCheck(GdipDrawBeziers(FNativeHandle, Pen.NativeHandle, @Points[0], Length(Points)));
end;

procedure TGPGraphics.DrawCachedBitmap(const CachedBitmap: IGPCachedBitmap; const X,
  Y: Integer);
begin
  GdipCheck(GdipDrawCachedBitmap(FNativeHandle, CachedBitmap.NativeHandle, X, Y));
end;

procedure TGPGraphics.DrawClosedCurve(const Pen: IGPPen;
  const Points: array of TGPPoint; const Tension: Single);
begin
  Assert(Length(Points) > 0);
  GdipCheck(GdipDrawClosedCurve2I(FNativeHandle, Pen.NativeHandle, @Points[0],
    Length(Points), Tension));
end;

procedure TGPGraphics.DrawClosedCurve(const Pen: IGPPen;
  const Points: array of TGPPointF);
begin
  Assert(Length(Points) > 0);
  GdipCheck(GdipDrawClosedCurve(FNativeHandle, Pen.NativeHandle, @Points[0],
    Length(Points)));
end;

procedure TGPGraphics.DrawClosedCurve(const Pen: IGPPen;
  const Points: array of TGPPointF; const Tension: Single);
begin
  Assert(Length(Points) > 0);
  GdipCheck(GdipDrawClosedCurve2(FNativeHandle, Pen.NativeHandle, @Points[0],
    Length(Points), Tension));
end;

procedure TGPGraphics.DrawClosedCurve(const Pen: IGPPen;
  const Points: array of TGPPoint);
begin
  Assert(Length(Points) > 0);
  GdipCheck(GdipDrawClosedCurveI(FNativeHandle, Pen.NativeHandle, @Points[0],
    Length(Points)));
end;

procedure TGPGraphics.DrawCurve(const Pen: IGPPen; const Points: array of TGPPointF;
  const Offset, NumberOfSegments: Integer; const Tension: Single);
begin
  Assert(Length(Points) > 0);
  GdipCheck(GdipDrawCurve3(FNativeHandle, Pen.NativeHandle, @Points[0],
    Length(Points), Offset, NumberOfSegments, Tension));
end;

procedure TGPGraphics.DrawCurve(const Pen: IGPPen; const Points: array of TGPPointF;
  const Tension: Single);
begin
  Assert(Length(Points) > 0);
  GdipCheck(GdipDrawCurve2(FNativeHandle, Pen.NativeHandle, @Points[0],
    Length(Points), Tension));
end;

procedure TGPGraphics.DrawCurve(const Pen: IGPPen; const Points: array of TGPPointF);
begin
  Assert(Length(Points) > 0);
  GdipCheck(GdipDrawCurve(FNativeHandle, Pen.NativeHandle, @Points[0], Length(Points)));
end;

procedure TGPGraphics.DrawCurve(const Pen: IGPPen; const Points: array of TGPPoint;
  const Offset, NumberOfSegments: Integer; const Tension: Single);
begin
  Assert(Length(Points) > 0);
  GdipCheck(GdipDrawCurve3I(FNativeHandle, Pen.NativeHandle, @Points[0],
    Length(Points), Offset, NumberOfSegments, Tension));
end;

procedure TGPGraphics.DrawCurve(const Pen: IGPPen; const Points: array of TGPPoint;
  const Tension: Single);
begin
  Assert(Length(Points) > 0);
  GdipCheck(GdipDrawCurve2I(FNativeHandle, Pen.NativeHandle, @Points[0],
    Length(Points), Tension));
end;

procedure TGPGraphics.DrawCurve(const Pen: IGPPen; const Points: array of TGPPoint);
begin
  Assert(Length(Points) > 0);
  GdipCheck(GdipDrawCurveI(FNativeHandle, Pen.NativeHandle, @Points[0], Length(Points)));
end;

procedure TGPGraphics.DrawDriverString(const Text: PUInt16; const Length: Integer;
  const Font: IGPFont; const Brush: IGPBrush; const Positions: PGPPointF;
  const Flags: TGPDriverStringOptions; const Matrix: IGPMatrix);
begin
  GdipCheck(GdipDrawDriverString(FNativeHandle, Text, Length, GdipHandle(Font),
    GdipHandle(Brush), Positions, Flags, GdipHandle(Matrix)));
end;

procedure TGPGraphics.DrawEllipse(const Pen: IGPPen; const X, Y, Width,
  Height: Single);
begin
  GdipCheck(GdipDrawEllipse(FNativeHandle, Pen.NativeHandle, X, Y, Width, Height));
end;

procedure TGPGraphics.DrawEllipse(const Pen: IGPPen; const Rect: TGPRect);
begin
  DrawEllipse(Pen, Rect.X, Rect.Y, Rect.Width, Rect.Height);
end;

procedure TGPGraphics.DrawEllipse(const Pen: IGPPen; const X, Y, Width,
  Height: Integer);
begin
  GdipCheck(GdipDrawEllipseI(FNativeHandle, Pen.NativeHandle, X, Y, Width, Height));
end;

procedure TGPGraphics.DrawEllipse(const Pen: IGPPen; const Rect: TGPRectF);
begin
  DrawEllipse(Pen, Rect.X, Rect.Y, Rect.Width, Rect.Height);
end;

procedure TGPGraphics.DrawImage(const Image: IGPImage; const X, Y, SrcX, SrcY,
  SrcWidth, SrcHeight: Single; const SrcUnit: TGPUnit);
begin
  GdipCheck(GdipDrawImagePointRect(FNativeHandle, GdipHandle(Image),
    X, Y, SrcX, SrcY, SrcWidth, SrcHeight, SrcUnit));
end;

procedure TGPGraphics.DrawImage(const Image: IGPImage; const DestRect: TGPRect;
  const SrcX, SrcY, SrcWidth, SrcHeight: Integer; const SrcUnit: TGPUnit;
  const ImageAttributes: IGPImageAttributes; const Callback: TGPDrawImageAbort;
  const CallbackData: Pointer);
begin
  GdipCheck(GdipDrawImageRectRectI(FNativeHandle, GdipHandle(Image),
    DestRect.X, DestRect.Y, DestRect.Width, DestRect.Height,
    SrcX, SrcY, SrcWidth, SrcHeight, SrcUnit, GdipHandle(ImageAttributes),
    Callback, CallbackData));
end;

procedure TGPGraphics.DrawImage(const Image: IGPImage; const DestPoints: TGPPlgPoints;
  const SrcX, SrcY, SrcWidth, SrcHeight: Integer; const SrcUnit: TGPUnit;
  const ImageAttributes: IGPImageAttributes; const Callback: TGPDrawImageAbort;
  const CallbackData: Pointer);
begin
  GdipCheck(GdipDrawImagePointsRectI(FNativeHandle, GdipHandle(Image),
    @DestPoints, 3, SrcX, SrcY, SrcWidth, SrcHeight, SrcUnit,
    GdipHandle(ImageAttributes), Callback, CallbackData));
end;

procedure TGPGraphics.DrawImage(const Image: IGPImage; const DstX, DstY, DstWidth,
  DstHeight, SrcX, SrcY, SrcWidth, SrcHeight: Single; const SrcUnit: TGPUnit;
  const ImageAttributes: IGPImageAttributes; const Callback: TGPDrawImageAbort;
  const CallbackData: Pointer);
begin
  GdipCheck(GdipDrawImageRectRect(FNativeHandle, GdipHandle(Image),
    DstX, DstY, DstWidth, DstHeight, SrcX, SrcY, SrcWidth, SrcHeight,
    SrcUnit, GdipHandle(ImageAttributes), Callback, CallbackData));
end;

procedure TGPGraphics.DrawImage(const Image: IGPImage; const DstX, DstY, DstWidth,
  DstHeight, SrcX, SrcY, SrcWidth, SrcHeight: Integer; const SrcUnit: TGPUnit;
  const ImageAttributes: IGPImageAttributes; const Callback: TGPDrawImageAbort;
  const CallbackData: Pointer);
begin
  GdipCheck(GdipDrawImageRectRectI(FNativeHandle, GdipHandle(Image),
    DstX, DstY, DstWidth, DstHeight, SrcX, SrcY, SrcWidth, SrcHeight,
    SrcUnit, GdipHandle(ImageAttributes), Callback, CallbackData));
end;

procedure TGPGraphics.DrawImage(const Image: IGPImage; const Rect: TGPRect);
begin
  DrawImage(Image, Rect.X, Rect.Y, Rect.Width, Rect.Height);
end;

procedure TGPGraphics.DrawImage(const Image: IGPImage;
  const DestPoints: TGPPlgPointsF; const SrcX, SrcY, SrcWidth,
  SrcHeight: Single; const SrcUnit: TGPUnit;
  const ImageAttributes: IGPImageAttributes; const Callback: TGPDrawImageAbort;
  const CallbackData: Pointer);
begin
  GdipCheck(GdipDrawImagePointsRect(FNativeHandle, GdipHandle(Image),
    @DestPoints, 3, SrcX, SrcY, SrcWidth, SrcHeight, SrcUnit,
    GdipHandle(ImageAttributes), Callback, CallbackData));
end;

procedure TGPGraphics.DrawImage(const Image: IGPImage; const DestRect: TGPRectF;
  const SrcX, SrcY, SrcWidth, SrcHeight: Single; const SrcUnit: TGPUnit;
  const ImageAttributes: IGPImageAttributes; const Callback: TGPDrawImageAbort;
  const CallbackData: Pointer);
begin
  GdipCheck(GdipDrawImageRectRect(FNativeHandle, GdipHandle(Image),
    DestRect.X, DestRect.Y, DestRect.Width, DestRect.Height,
    SrcX, SrcY, SrcWidth, SrcHeight, SrcUnit, GdipHandle(ImageAttributes),
    Callback, CallbackData));
end;

procedure TGPGraphics.DrawImage(const Image: IGPImage; const X, Y, Width,
  Height: Single);
begin
  GdipCheck(GdipDrawImageRect(FNativeHandle, GdipHandle(Image), X, Y, Width, Height));
end;

procedure TGPGraphics.DrawImage(const Image: IGPImage; const Point: TGPPoint);
begin
  DrawImage(Image, Point.X, Point.Y);
end;

procedure TGPGraphics.DrawImage(const Image: IGPImage; const X, Y: Integer);
begin
  GdipCheck(GdipDrawImageI(FNativeHandle, GdipHandle(Image), X, Y));
end;

procedure TGPGraphics.DrawImage(const Image: IGPImage; const Rect: TGPRectF);
begin
  DrawImage(Image, Rect.X, Rect.Y, Rect.Width, Rect.Height);
end;

procedure TGPGraphics.DrawImage(const Image: IGPImage; const X, Y, SrcX, SrcY,
  SrcWidth, SrcHeight: Integer; const SrcUnit: TGPUnit);
begin
  GdipCheck(GdipDrawImagePointRectI(FNativeHandle, GdipHandle(Image),
    X, Y, SrcX, SrcY, SrcWidth, SrcHeight, SrcUnit));
end;

procedure TGPGraphics.DrawImage(const Image: IGPImage; const Point: TGPPointF);
begin
  DrawImage(Image, Point.X, Point.Y);
end;

procedure TGPGraphics.DrawImage(const Image: IGPImage; const X, Y: Single);
begin
  GdipCheck(GdipDrawImage(FNativeHandle, GdipHandle(Image), X, Y));
end;

procedure TGPGraphics.DrawImage(const Image: IGPImage;
  const DestPoints: TGPPlgPoints);
begin
  GdipCheck(GdipDrawImagePointsI(FNativeHandle, GdipHandle(Image), @DestPoints[0], 3));
end;

procedure TGPGraphics.DrawImage(const Image: IGPImage;
  const DestPoints: TGPPlgPointsF);
begin
  GdipCheck(GdipDrawImagePoints(FNativeHandle, GdipHandle(Image), @DestPoints[0], 3));
end;

procedure TGPGraphics.DrawImage(const Image: IGPImage; const X, Y, Width,
  Height: Integer);
begin
  GdipCheck(GdipDrawImageRectI(FNativeHandle, GdipHandle(Image), X, Y, Width, Height));
end;

{$IF (GDIPVER >= $0110)}
procedure TGPGraphics.DrawImage(const Image: IGPImage; const DestRect,
  SourceRect: TGPRectF; const SrcUnit: TGPUnit;
  const ImageAttributes: IGPImageAttributes);
begin
  GdipCheck(GdipDrawImageRectRect(FNativeHandle, Image.NativeHandle,
    DestRect.X, DestRect.Y, DestRect.Width, DestRect.Height,
    SourceRect.X, SourceRect.Y, SourceRect.Width, SourceRect.Height,
    SrcUnit, GdipHandle(ImageAttributes), nil, nil));
end;

procedure TGPGraphics.DrawImage(const Image: IGPImage; const SourceRect: TGPRectF;
  const XForm: IGPMatrix; const Effect: IGPEffect;
  const ImageAttributes: IGPImageAttributes; const SrcUnit: TGPUnit);
begin
  GdipCheck(GdipDrawImageFX(FNativeHandle, Image.NativeHandle, @SourceRect,
    GdipHandle(XForm), GdipHandle(Effect), GdipHandle(ImageAttributes), SrcUnit));
end;
{$IFEND}

procedure TGPGraphics.DrawLine(const Pen: IGPPen; const Pt1, Pt2: TGPPoint);
begin
  DrawLine(Pen, Pt1.X, Pt1.Y, Pt2.X, Pt2.Y);
end;

procedure TGPGraphics.DrawLine(const Pen: IGPPen; const X1, Y1, X2, Y2: Single);
begin
  GdipCheck(GdipDrawLine(FNativeHandle, Pen.NativeHandle, X1, Y1, X2, Y2));
end;

procedure TGPGraphics.DrawLine(const Pen: IGPPen; const Pt1, Pt2: TGPPointF);
begin
  DrawLine(Pen, Pt1.X, Pt1.Y, Pt2.X, Pt2.Y);
end;

procedure TGPGraphics.DrawLine(const Pen: IGPPen; const X1, Y1, X2, Y2: Integer);
begin
  GdipCheck(GdipDrawLineI(FNativeHandle, Pen.NativeHandle, X1, Y1, X2, Y2));
end;

procedure TGPGraphics.DrawLines(const Pen: IGPPen; const Points: array of TGPPoint);
begin
  Assert(Length(Points) > 0);
  GdipCheck(GdipDrawLinesI(FNativeHandle, Pen.NativeHandle, @Points[0], Length(Points)));
end;

procedure TGPGraphics.DrawLines(const Pen: IGPPen; const Points: array of TGPPointF);
begin
  Assert(Length(Points) > 0);
  GdipCheck(GdipDrawLines(FNativeHandle, Pen.NativeHandle, @Points[0], Length(Points)));
end;

procedure TGPGraphics.DrawPath(const Pen: IGPPen; const Path: IGPGraphicsPath);
begin
  GdipCheck(GdipDrawPath(FNativeHandle, GdipHandle(Pen), GdipHandle(Path)));
end;

procedure TGPGraphics.DrawPie(const Pen: IGPPen; const X, Y, Width, Height,
  StartAngle, SweepAngle: Single);
begin
  GdipCheck(GdipDrawPie(FNativeHandle, Pen.NativeHandle, X, Y, Width, Height,
    StartAngle, SweepAngle));
end;

procedure TGPGraphics.DrawPie(const Pen: IGPPen; const Rect: TGPRectF;
  const StartAngle, SweepAngle: Single);
begin
  DrawPie(Pen, Rect.X, Rect.Y, Rect.Width, Rect.Height, StartAngle, SweepAngle);
end;

procedure TGPGraphics.DrawPie(const Pen: IGPPen; const X, Y, Width, Height: Integer;
  const StartAngle, SweepAngle: Single);
begin
  GdipCheck(GdipDrawPieI(FNativeHandle, Pen.NativeHandle, X, Y, Width, Height,
    StartAngle, SweepAngle));
end;

procedure TGPGraphics.DrawPie(const Pen: IGPPen; const Rect: TGPRect;
  const StartAngle, SweepAngle: Single);
begin
  DrawPie(Pen, Rect.X, Rect.Y, Rect.Width, Rect.Height, StartAngle, SweepAngle);
end;

procedure TGPGraphics.DrawPolygon(const Pen: IGPPen; const Points: array of TGPPoint);
begin
  Assert(Length(Points) > 0);
  GdipCheck(GdipDrawPolygonI(FNativeHandle, Pen.NativeHandle, @Points[0], Length(Points)));
end;

procedure TGPGraphics.DrawPolygon(const Pen: IGPPen;
  const Points: array of TGPPointF);
begin
  Assert(Length(Points) > 0);
  GdipCheck(GdipDrawPolygon(FNativeHandle, Pen.NativeHandle, @Points[0], Length(Points)));
end;

procedure TGPGraphics.DrawRectangle(const Pen: IGPPen; const Rect: TGPRectF);
begin
  DrawRectangle(Pen, Rect.X, Rect.Y, Rect.Width, Rect.Height);
end;

procedure TGPGraphics.DrawRectangle(const Pen: IGPPen; const Rect: TGPRect);
begin
  DrawRectangle(Pen, Rect.X, Rect.Y, Rect.Width, Rect.Height);
end;

procedure TGPGraphics.DrawRectangle(const Pen: IGPPen; const X, Y, Width,
  Height: Single);
begin
  GdipCheck(GdipDrawRectangle(FNativeHandle, Pen.NativeHandle, X, Y, Width, Height));
end;

procedure TGPGraphics.DrawRectangle(const Pen: IGPPen; const X, Y, Width,
  Height: Integer);
begin
  GdipCheck(GdipDrawRectangleI(FNativeHandle, Pen.NativeHandle, X, Y, Width, Height));
end;

procedure TGPGraphics.DrawRectangles(const Pen: IGPPen;
  const Rects: array of TGPRect);
begin
  Assert(Length(Rects) > 0);
  GdipCheck(GdipDrawRectanglesI(FNativeHandle, Pen.NativeHandle, @Rects[0], Length(Rects)));
end;

procedure TGPGraphics.DrawRectangles(const Pen: IGPPen;
  const Rects: array of TGPRectF);
begin
  Assert(Length(Rects) > 0);
  GdipCheck(GdipDrawRectangles(FNativeHandle, Pen.NativeHandle, @Rects[0], Length(Rects)));
end;

procedure TGPGraphics.DrawString(const Str: String; const Font: IGPFont;
  const Origin: TGPPointF; const Brush: IGPBrush);
var
  Rect: TGPRectF;
begin
  Rect.Initialize(Origin.X, Origin.Y, 0, 0);
  GdipCheck(GdipDrawString(FNativeHandle, PWideChar(Str), Length(Str),
    GdipHandle(Font), @Rect, nil, GdipHandle(Brush)));
end;

procedure TGPGraphics.DrawString(const Str: String; const Font: IGPFont;
  const Origin: TGPPointF; const Format: IGPStringFormat; const Brush: IGPBrush);
var
  Rect: TGPRectF;
begin
  Rect.Initialize(Origin.X, Origin.Y, 0, 0);
  GdipCheck(GdipDrawString(FNativeHandle, PWideChar(Str), Length(Str),
    GdipHandle(Font), @Rect, GdipHandle(Format), GdipHandle(Brush)));
end;

procedure TGPGraphics.DrawString(const Str: String; const Font: IGPFont;
  const LayoutRect: TGPRectF; const Format: IGPStringFormat; const Brush: IGPBrush);
begin
  GdipCheck(GdipDrawString(FNativeHandle, PWideChar(Str), Length(Str),
    GdipHandle(Font), @LayoutRect, GdipHandle(Format), GdipHandle(Brush)));
end;

procedure TGPGraphics.EndContainer(const State: TGPGraphicsContainer);
begin
  GdipCheck(GdipEndContainer(FNativeHandle, State));
end;

procedure TGPGraphics.EnumerateMetafile(const Metafile: IGPMetafile; const DestRect,
  SrcRect: TGPRectF; const SrcUnit: TGPUnit; const Callback: TGPEnumerateMetafileProc;
  const CallbackData: Pointer; const ImageAttributes: IGPImageAttributes);
begin
  GdipCheck(GdipEnumerateMetafileSrcRectDestRect(FNativeHandle,
    GdipHandle(Metafile), @DestRect, @SrcRect, SrcUnit, Callback,
    CallbackData, GdipHandle(ImageAttributes)));
end;

procedure TGPGraphics.EnumerateMetafile(const Metafile: IGPMetafile;
  const DestPoint: TGPPoint; const SrcRect: TGPRect; const SrcUnit: TGPUnit;
  const Callback: TGPEnumerateMetafileProc; const CallbackData: Pointer;
  const ImageAttributes: IGPImageAttributes);
begin
  GdipCheck(GdipEnumerateMetafileSrcRectDestPointI(FNativeHandle,
    GdipHandle(Metafile), @DestPoint, @SrcRect, SrcUnit, Callback,
    CallbackData, GdipHandle(ImageAttributes)));
end;

procedure TGPGraphics.EnumerateMetafile(const Metafile: IGPMetafile;
  const DestPoint: TGPPointF; const SrcRect: TGPRectF; const SrcUnit: TGPUnit;
  const Callback: TGPEnumerateMetafileProc; const CallbackData: Pointer;
  const ImageAttributes: IGPImageAttributes);
begin
  GdipCheck(GdipEnumerateMetafileSrcRectDestPoint(FNativeHandle,
    GdipHandle(Metafile), @DestPoint, @SrcRect, SrcUnit, Callback,
    CallbackData, GdipHandle(ImageAttributes)));
end;

procedure TGPGraphics.EnumerateMetafile(const Metafile: IGPMetafile;
  const DestPoints: TGPPlgPoints; const SrcRect: TGPRect; const SrcUnit: TGPUnit;
  const Callback: TGPEnumerateMetafileProc; const CallbackData: Pointer;
  const ImageAttributes: IGPImageAttributes);
begin
  GdipCheck(GdipEnumerateMetafileSrcRectDestPointsI(FNativeHandle,
    GdipHandle(Metafile), @DestPoints[0], 3, @SrcRect, SrcUnit, Callback,
    CallbackData, GdipHandle(ImageAttributes)));
end;

procedure TGPGraphics.EnumerateMetafile(const Metafile: IGPMetafile;
  const DestPoints: TGPPlgPointsF; const SrcRect: TGPRectF; const SrcUnit: TGPUnit;
  const Callback: TGPEnumerateMetafileProc; const CallbackData: Pointer;
  const ImageAttributes: IGPImageAttributes);
begin
  GdipCheck(GdipEnumerateMetafileSrcRectDestPoints(FNativeHandle,
    GdipHandle(Metafile), @DestPoints[0], 3, @SrcRect, SrcUnit, Callback,
    CallbackData, GdipHandle(ImageAttributes)));
end;

procedure TGPGraphics.EnumerateMetafile(const Metafile: IGPMetafile; const DestRect,
  SrcRect: TGPRect; const SrcUnit: TGPUnit; const Callback: TGPEnumerateMetafileProc;
  const CallbackData: Pointer; const ImageAttributes: IGPImageAttributes);
begin
  GdipCheck(GdipEnumerateMetafileSrcRectDestRectI(FNativeHandle,
    GdipHandle(Metafile), @DestRect, @SrcRect, SrcUnit, Callback,
    CallbackData, GdipHandle(ImageAttributes)));
end;

procedure TGPGraphics.EnumerateMetafile(const Metafile: IGPMetafile;
  const DestRect: TGPRectF; const Callback: TGPEnumerateMetafileProc;
  const CallbackData: Pointer; const ImageAttributes: IGPImageAttributes);
begin
  GdipCheck(GdipEnumerateMetafileDestRect(FNativeHandle, GdipHandle(Metafile),
    @DestRect, Callback, CallbackData, GdipHandle(ImageAttributes)));
end;

procedure TGPGraphics.EnumerateMetafile(const Metafile: IGPMetafile;
  const DestPoint: TGPPoint; const Callback: TGPEnumerateMetafileProc;
  const CallbackData: Pointer; const ImageAttributes: IGPImageAttributes);
begin
  GdipCheck(GdipEnumerateMetafileDestPointI(FNativeHandle, GdipHandle(Metafile),
    @DestPoint, Callback, CallbackData, GdipHandle(ImageAttributes)));
end;

procedure TGPGraphics.EnumerateMetafile(const Metafile: IGPMetafile;
  const DestPoint: TGPPointF; const Callback: TGPEnumerateMetafileProc;
  const CallbackData: Pointer; const ImageAttributes: IGPImageAttributes);
begin
  GdipCheck(GdipEnumerateMetafileDestPoint(FNativeHandle, GdipHandle(Metafile),
    @DestPoint, Callback, CallbackData, GdipHandle(ImageAttributes)));
end;

procedure TGPGraphics.EnumerateMetafile(const Metafile: IGPMetafile;
  const DestPoints: TGPPlgPoints; const Callback: TGPEnumerateMetafileProc;
  const CallbackData: Pointer; const ImageAttributes: IGPImageAttributes);
begin
  GdipCheck(GdipEnumerateMetafileDestPointsI(FNativeHandle, GdipHandle(Metafile),
    @DestPoints[0], 3, Callback, CallbackData, GdipHandle(ImageAttributes)));
end;

procedure TGPGraphics.EnumerateMetafile(const Metafile: IGPMetafile;
  const DestPoints: TGPPlgPointsF; const Callback: TGPEnumerateMetafileProc;
  const CallbackData: Pointer; const ImageAttributes: IGPImageAttributes);
begin
  GdipCheck(GdipEnumerateMetafileDestPoints(FNativeHandle, GdipHandle(Metafile),
    @DestPoints[0], 3, Callback, CallbackData, GdipHandle(ImageAttributes)));
end;

procedure TGPGraphics.EnumerateMetafile(const Metafile: IGPMetafile;
  const DestRect: TGPRect; const Callback: TGPEnumerateMetafileProc;
  const CallbackData: Pointer; const ImageAttributes: IGPImageAttributes);
begin
  GdipCheck(GdipEnumerateMetafileDestRectI(FNativeHandle, GdipHandle(Metafile),
    @DestRect, Callback, CallbackData, GdipHandle(ImageAttributes)));
end;

procedure TGPGraphics.ExcludeClip(const Region: IGPRegion);
begin
  GdipCheck(GdipSetClipRegion(FNativeHandle, Region.NativeHandle, CombineModeExclude));
end;

procedure TGPGraphics.ExcludeClip(const Rect: TGPRect);
begin
  GdipCheck(GdipSetClipRectI(FNativeHandle, Rect.X, Rect.Y, Rect.Width,
    Rect.Height, CombineModeExclude));
end;

procedure TGPGraphics.ExcludeClip(const Rect: TGPRectF);
begin
  GdipCheck(GdipSetClipRect(FNativeHandle, Rect.X, Rect.Y, Rect.Width,
    Rect.Height, CombineModeExclude));
end;

procedure TGPGraphics.FillClosedCurve(const Brush: IGPBrush;
  const Points: array of TGPPointF);
begin
  Assert(Length(Points) > 0);
  GdipCheck(GdipFillClosedCurve(FNativeHandle, Brush.NativeHandle, @Points[0],
    Length(Points)));
end;

procedure TGPGraphics.FillClosedCurve(const Brush: IGPBrush;
  const Points: array of TGPPoint);
begin
  Assert(Length(Points) > 0);
  GdipCheck(GdipFillClosedCurveI(FNativeHandle, Brush.NativeHandle, @Points[0],
    Length(Points)));
end;

procedure TGPGraphics.FillClosedCurve(const Brush: IGPBrush;
  const Points: array of TGPPoint; const FillMode: TGPFillMode;
  const Tension: Single);
begin
  Assert(Length(Points) > 0);
  GdipCheck(GdipFillClosedCurve2I(FNativeHandle, Brush.NativeHandle, @Points[0],
    Length(Points), Tension, FillMode));
end;

procedure TGPGraphics.FillClosedCurve(const Brush: IGPBrush;
  const Points: array of TGPPointF; const FillMode: TGPFillMode;
  const Tension: Single);
begin
  Assert(Length(Points) > 0);
  GdipCheck(GdipFillClosedCurve2(FNativeHandle, Brush.NativeHandle, @Points[0],
    Length(Points), Tension, FillMode));
end;

procedure TGPGraphics.FillEllipse(const Brush: IGPBrush; const Rect: TGPRect);
begin
  FillEllipse(Brush, Rect.X, Rect.Y, Rect.Width, Rect.Height);
end;

procedure TGPGraphics.FillEllipse(const Brush: IGPBrush; const X, Y, Width,
  Height: Integer);
begin
  GdipCheck(GdipFillEllipseI(FNativeHandle, Brush.NativeHandle, X, Y, Width, Height));
end;

procedure TGPGraphics.FillEllipse(const Brush: IGPBrush; const Rect: TGPRectF);
begin
  FillEllipse(Brush, Rect.X, Rect.Y, Rect.Width, Rect.Height);
end;

procedure TGPGraphics.FillEllipse(const Brush: IGPBrush; const X, Y, Width,
  Height: Single);
begin
  GdipCheck(GdipFillEllipse(FNativeHandle, Brush.NativeHandle, X, Y, Width, Height));
end;

procedure TGPGraphics.FillPath(const Brush: IGPBrush;
  const Path: IGPGraphicsPath);
begin
  GdipCheck(GdipFillPath(FNativeHandle, Brush.NativeHandle, Path.NativeHandle));
end;

procedure TGPGraphics.FillPie(const Brush: IGPBrush; const Rect: TGPRectF;
  const StartAngle, SweepAngle: Single);
begin
  FillPie(Brush, Rect.X, Rect.Y, Rect.Width, Rect.Height, StartAngle, SweepAngle);
end;

procedure TGPGraphics.FillPie(const Brush: IGPBrush; const X, Y, Width,
  Height: Integer; const StartAngle, SweepAngle: Single);
begin
  GdipCheck(GdipFillPieI(FNativeHandle, Brush.NativeHandle, X, Y, Width, Height,
    StartAngle, SweepAngle));
end;

procedure TGPGraphics.FillPie(const Brush: IGPBrush; const Rect: TGPRect;
  const StartAngle, SweepAngle: Single);
begin
  FillPie(Brush, Rect.X, Rect.Y, Rect.Width, Rect.Height, StartAngle, SweepAngle);
end;

procedure TGPGraphics.FillPie(const Brush: IGPBrush; const X, Y, Width, Height,
  StartAngle, SweepAngle: Single);
begin
  GdipCheck(GdipFillPie(FNativeHandle, Brush.NativeHandle, X, Y, Width, Height,
    StartAngle, SweepAngle));
end;

procedure TGPGraphics.FillPolygon(const Brush: IGPBrush;
  const Points: array of TGPPoint);
begin
  FillPolygon(Brush, Points, FillModeAlternate);
end;

procedure TGPGraphics.FillPolygon(const Brush: IGPBrush;
  const Points: array of TGPPointF; const FillMode: TGPFillMode);
begin
  Assert(Length(Points) > 0);
  GdipCheck(GdipFillPolygon(FNativeHandle, Brush.NativeHandle, @Points[0],
    Length(Points), FillMode));
end;

procedure TGPGraphics.FillPolygon(const Brush: IGPBrush;
  const Points: array of TGPPoint; const FillMode: TGPFillMode);
begin
  Assert(Length(Points) > 0);
  GdipCheck(GdipFillPolygonI(FNativeHandle, Brush.NativeHandle, @Points[0],
    Length(Points), FillMode));
end;

procedure TGPGraphics.FillPolygon(const Brush: IGPBrush;
  const Points: array of TGPPointF);
begin
  FillPolygon(Brush, Points, FillModeAlternate);
end;

procedure TGPGraphics.FillRectangle(const Brush: IGPBrush; const X, Y, Width,
  Height: Integer);
begin
  GdipCheck(GdipFillRectangleI(FNativeHandle, Brush.NativeHandle, X, Y, Width, Height));
end;

procedure TGPGraphics.FillRectangle(const Brush: IGPBrush; const Rect: TGPRect);
begin
  FillRectangle(Brush, Rect.X, Rect.Y, Rect.Width, Rect.Height);
end;

procedure TGPGraphics.FillRectangle(const Brush: IGPBrush; const Rect: TGPRectF);
begin
  FillRectangle(Brush, Rect.X, Rect.Y, Rect.Width, Rect.Height);
end;

procedure TGPGraphics.FillRectangle(const Brush: IGPBrush; const X, Y, Width,
  Height: Single);
begin
  GdipCheck(GdipFillRectangle(FNativeHandle, Brush.NativeHandle, X, Y, Width, Height));
end;

procedure TGPGraphics.FillRectangles(const Brush: IGPBrush;
  const Rects: array of TGPRect);
begin
  Assert(Length(Rects) > 0);
  GdipCheck(GdipFillRectanglesI(FNativeHandle, Brush.NativeHandle, @Rects[0], Length(Rects)));
end;

procedure TGPGraphics.FillRectangles(const Brush: IGPBrush;
  const Rects: array of TGPRectF);
begin
  Assert(Length(Rects) > 0);
  GdipCheck(GdipFillRectangles(FNativeHandle, Brush.NativeHandle, @Rects[0], Length(Rects)));
end;

procedure TGPGraphics.FillRegion(const Brush: IGPBrush; const Region: IGPRegion);
begin
  GdipCheck(GdipFillRegion(FNativeHandle, Brush.NativeHandle, Region.NativeHandle));
end;

procedure TGPGraphics.Flush(const Intention: TGPFlushIntention);
begin
  GdipFlush(FNativeHandle, Intention);
end;

class function TGPGraphics.FromHDC(const DC: HDC): IGPGraphics;
begin
  Result := TGPGraphics.Create(DC);
end;

class function TGPGraphics.FromHDC(const DC: HDC;
  const Device: THandle): IGPGraphics;
begin
  Result := TGPGraphics.Create(DC, Device);
end;

class function TGPGraphics.FromHWnd(const Window: HWnd;
  const ICM: Boolean): IGPGraphics;
begin
  Result := TGPGraphics.Create(Window, ICM);
end;

class function TGPGraphics.FromImage(const Image: IGPImage): IGPGraphics;
begin
  Result := TGPGraphics.Create(Image);
end;

function TGPGraphics.GetClip: IGPRegion;
begin
  Result := TGPRegion.Create;
  GdipCheck(GdipGetClip(FNativeHandle, Result.NativeHandle));
end;

function TGPGraphics.GetClipBounds: TGPRectF;
begin
  GdipCheck(GdipGetClipBounds(FNativeHandle, Result));
end;

function TGPGraphics.GetClipBoundsI: TGPRect;
begin
  GdipCheck(GdipGetClipBoundsI(FNativeHandle, Result));
end;

function TGPGraphics.GetCompositingMode: TGPCompositingMode;
begin
  GdipCheck(GdipGetCompositingMode(FNativeHandle, Result));
end;

function TGPGraphics.GetCompositingQuality: TGPCompositingQuality;
begin
  GdipCheck(GdipGetCompositingQuality(FNativeHandle, Result));
end;

function TGPGraphics.GetDpiX: Single;
begin
  GdipCheck(GdipGetDpiX(FNativeHandle, Result));
end;

function TGPGraphics.GetDpiY: Single;
begin
  GdipCheck(GdipGetDpiY(FNativeHandle, Result));
end;

function TGPGraphics.GetHDC: HDC;
begin
  Result := 0;
  GdipCheck(GdipGetDC(FNativeHandle, Result));
end;

function TGPGraphics.GetInterpolationMode: TGPInterpolationMode;
begin
  GdipCheck(GdipGetInterpolationMode(FNativeHandle, Result));
end;

function TGPGraphics.GetIsClipEmpty: Boolean;
var
  B: Bool;
begin
  B := False;
  GdipCheck(GdipIsClipEmpty(FNativeHandle, B));
  Result := B;
end;

function TGPGraphics.GetIsVisibleClipEmpty: Boolean;
var
  B: Bool;
begin
  B := False;
  GdipCheck(GdipIsVisibleClipEmpty(FNativeHandle, B));
  Result := B;
end;

function TGPGraphics.GetNearestColor(const Color: TGPColor): TGPColor;
var
  C: ARGB;
begin
  C := Color.Value;
  GdipCheck(GdipGetNearestColor(FNativeHandle, @C));
  Result.Value := C;
end;

function TGPGraphics.GetPageScale: Single;
begin
  GdipCheck(GdipGetPageScale(FNativeHandle, Result));
end;

function TGPGraphics.GetPageUnit: TGPUnit;
begin
  GdipCheck(GdipGetPageUnit(FNativeHandle, Result));
end;

function TGPGraphics.GetPixelOffsetMode: TGPPixelOffsetMode;
begin
  GdipCheck(GdipGetPixelOffsetMode(FNativeHandle, Result));
end;

procedure TGPGraphics.GetRenderingOrigin(out X, Y: Integer);
begin
  GdipCheck(GdipGetRenderingOrigin(FNativeHandle, X, Y));
end;

function TGPGraphics.GetRenderingOrigin: TGPPoint;
begin
  GdipCheck(GdipGetRenderingOrigin(FNativeHandle, Result.X, Result.Y));
end;

function TGPGraphics.GetSmoothingMode: TGPSmoothingMode;
begin
  GdipCheck(GdipGetSmoothingMode(FNativeHandle, Result));
end;

function TGPGraphics.GetTextContrast: Integer;
begin
  GdipCheck(GdipGetTextContrast(FNativeHandle, Result));
end;

function TGPGraphics.GetTextRenderingHint: TGPTextRenderingHint;
begin
  GdipCheck(GdipGetTextRenderingHint(FNativeHandle, Result));
end;

function TGPGraphics.GetTransform: IGPMatrix;
begin
  Result := TGPMatrix.Create;
  GdipCheck(GdipGetWorldTransform(FNativeHandle, Result.NativeHandle));
end;

function TGPGraphics.GetVisibleClipBounds: TGPRectF;
begin
 GdipCheck(GdipGetVisibleClipBounds(FNativeHandle, Result));
end;

function TGPGraphics.GetVisibleClipBoundsI: TGPRect;
begin
 GdipCheck(GdipGetVisibleClipBoundsI(FNativeHandle, Result));
end;

procedure TGPGraphics.IntersectClip(const Rect: TGPRectF);
begin
  GdipCheck(GdipSetClipRect(FNativeHandle, Rect.X, Rect.Y, Rect.Width,
    Rect.Height, CombineModeIntersect));
end;

procedure TGPGraphics.IntersectClip(const Rect: TGPRect);
begin
  GdipCheck(GdipSetClipRectI(FNativeHandle, Rect.X, Rect.Y, Rect.Width,
    Rect.Height, CombineModeIntersect));
end;

procedure TGPGraphics.IntersectClip(const Region: IGPRegion);
begin
  GdipCheck(GdipSetClipRegion(FNativeHandle, Region.NativeHandle, CombineModeIntersect));
end;

function TGPGraphics.IsVisible(const Rect: TGPRect): Boolean;
begin
  Result := IsVisible(Rect.X, Rect.Y, Rect.Width, Rect.Height);
end;

function TGPGraphics.IsVisible(const Rect: TGPRectF): Boolean;
begin
  Result := IsVisible(Rect.X, Rect.Y, Rect.Width, Rect.Height);
end;

function TGPGraphics.IsVisible(const X, Y, Width, Height: Integer): Boolean;
var
  B: Bool;
begin
  B := False;
  GdipCheck(GdipIsVisibleRectI(FNativeHandle, X, Y, Width, Height, B));
  Result := B;
end;

function TGPGraphics.IsVisible(const X, Y: Integer): Boolean;
var
  B: Bool;
begin
  B := False;
  GdipCheck(GdipIsVisiblePointI(FNativeHandle, X, Y, B));
  Result := B;
end;

function TGPGraphics.IsVisible(const Point: TGPPoint): Boolean;
begin
  Result := IsVisible(Point.X, Point.Y);
end;

function TGPGraphics.IsVisible(const X, Y, Width, Height: Single): Boolean;
var
  B: Bool;
begin
  B := False;
  GdipCheck(GdipIsVisibleRect(FNativeHandle, X, Y, Width, Height, B));
  Result := B;
end;

function TGPGraphics.IsVisible(const Point: TGPPointF): Boolean;
begin
  Result := IsVisible(Point.X, Point.Y);
end;

function TGPGraphics.IsVisible(const X, Y: Single): Boolean;
var
  B: Bool;
begin
  B := False;
  GdipCheck(GdipIsVisiblePoint(FNativeHandle, X, Y, B));
  Result := B;
end;

function TGPGraphics.MeasureCharacterRanges(const Str: String; const Font: IGPFont;
  const LayoutRect: TGPRectF; const Format: IGPStringFormat): IGPRegions;
var
  I, Count: Integer;
  NativeRegions: array of GpRegion;
begin
  if (Format = nil) then
    GdipCheck(InvalidParameter);
  Count := Format.MeasurableCharacterRangeCount;
  SetLength(NativeRegions, Count);
  Result := TGPArray<IGPRegion>.Create(Count);
  for I := 0 to Count - 1 do
  begin
    Result[I] := TGPRegion.Create;
    NativeRegions[I] := Result[I].NativeHandle;
  end;
  GdipCheck(GdipMeasureCharacterRanges(FNativeHandle, PWideChar(Str),
    Length(Str), GdipHandle(Font), @LayoutRect, Format.NativeHandle,
    Count, @NativeRegions[0]));
end;

function TGPGraphics.MeasureDriverString(const Text: PUInt16;
  const Length: Integer; const Font: IGPFont; const Positions: PGPPointF;
  const Flags: TGPDriverStringOptions; const Matrix: IGPMatrix): TGPRectF;
begin
  GdipCheck(GdipMeasureDriverString(FNativeHandle, Text, Length,
    GdipHandle(Font), Positions, Flags, GdipHandle(Matrix),
    Result));
end;

function TGPGraphics.MeasureString(const Str: String; const Font: IGPFont;
  const LayoutRect: TGPRectF; const Format: IGPStringFormat): TGPRectF;
var
  CodepointsFitted, LinesFilled: Integer;
begin
  Result :=  MeasureString(Str, Font, LayoutRect, Format, CodepointsFitted, LinesFilled);
end;

function TGPGraphics.MeasureString(const Str: String; const Font: IGPFont;
  const LayoutRect: TGPRectF; const Format: IGPStringFormat; out CodepointsFitted,
  LinesFilled: Integer): TGPRectF;
begin
  GdipCheck(GdipMeasureString(FNativeHandle, PWideChar(Str), Length(Str),
    GdipHandle(Font), @LayoutRect, GdipHandle(Format), Result,
    @CodepointsFitted, @LinesFilled));
end;

function TGPGraphics.MeasureString(const Str: String; const Font: IGPFont;
  const LayoutRect: TGPRectF): TGPRectF;
begin
  GdipCheck(GdipMeasureString(FNativeHandle, PWideChar(Str), Length(Str),
    GdipHandle(Font), @LayoutRect, nil, Result, nil, nil));
end;

function TGPGraphics.MeasureString(const Str: String; const Font: IGPFont;
  const Origin: TGPPointF): TGPRectF;
var
  Rect: TGPRectF;
begin
  Rect.Initialize(Origin.X, Origin.Y, 0, 0);
  GdipCheck(GdipMeasureString(FNativeHandle, PWideChar(Str), Length(Str),
    GdipHandle(Font), @Rect, nil, Result, nil, nil));
end;

function TGPGraphics.MeasureString(const Str: String; const Font: IGPFont;
  const Origin: TGPPointF; const Format: IGPStringFormat): TGPRectF;
var
  Rect: TGPRectF;
begin
  Rect.Initialize(Origin.X, Origin.Y, 0, 0);
  GdipCheck(GdipMeasureString(FNativeHandle, PWideChar(Str), Length(Str),
    GdipHandle(Font), @Rect, GdipHandle(Format), Result, nil, nil));
end;

function TGPGraphics.MeasureString(const Str: String; const Font: IGPFont;
  const LayoutRectSize: TGPSizeF; const Format: IGPStringFormat): TGPSizeF;
var
  CodepointsFitted, LinesFilled: Integer;
begin
  Result := MeasureString(Str, Font, LayoutRectSize, Format, CodepointsFitted, LinesFilled);
end;

function TGPGraphics.MeasureString(const Str: String; const Font: IGPFont;
  const LayoutRectSize: TGPSizeF; const Format: IGPStringFormat;
  out CodepointsFitted, LinesFilled: Integer): TGPSizeF;
var
  LayoutRect, BoundingBox: TGPRectF;
begin
  LayoutRect.Initialize(0, 0, LayoutRectSize.Width, LayoutRectSize.Height);
  GdipCheck(GdipMeasureString(FNativeHandle, PWideChar(Str), Length(Str),
    GdipHandle(Font), @LayoutRect, GdipHandle(Format), BoundingBox,
    @CodepointsFitted, @LinesFilled));
  Result.Width := BoundingBox.Width;
  Result.Height := BoundingBox.Height;
end;

procedure TGPGraphics.MultiplyTransform(const Matrix: IGPMatrix;
  const Order: TGPMatrixOrder);
begin
  GdipCheck(GdipMultiplyWorldTransform(FNativeHandle, Matrix.NativeHandle, Order));
end;

procedure TGPGraphics.ReleaseHDC(const DC: HDC);
begin
  GdipCheck(GdipReleaseDC(FNativeHandle, DC));
end;

procedure TGPGraphics.ResetClip;
begin
  GdipCheck(GdipResetClip(FNativeHandle));
end;

procedure TGPGraphics.ResetTransform;
begin
  GdipCheck(GdipResetWorldTransform(FNativeHandle));
end;

procedure TGPGraphics.Restore(const State: TGPGraphicsState);
begin
  GdipCheck(GdipRestoreGraphics(FNativeHandle, State));
end;

procedure TGPGraphics.RotateTransform(const Angle: Single;
  const Order: TGPMatrixOrder);
begin
  GdipCheck(GdipRotateWorldTransform(FNativeHandle, Angle, Order));
end;

function TGPGraphics.Save: TGPGraphicsState;
begin
  GdipCheck(GdipSaveGraphics(FNativeHandle, Result));
end;

procedure TGPGraphics.ScaleTransform(const SX, SY: Single;
  const Order: TGPMatrixOrder);
begin
  GdipCheck(GdipScaleWorldTransform(FNativeHandle, SX, SY, Order));
end;

{$IF (GDIPVER >= $0110)}
procedure TGPGraphics.SetAbort(const IAbort: TGdiplusAbort);
begin
  GdipCheck(GdipGraphicsSetAbort(FNativeHandle, @IAbort));
end;
{$IFEND}

procedure TGPGraphics.SetClip(const Rect: TGPRect; const CombineMode: TGPCombineMode);
begin
  GdipCheck(GdipSetClipRectI(FNativeHandle, Rect.X, Rect.Y, Rect.Width,
    Rect.Height, CombineMode));
end;

procedure TGPGraphics.SetClip(const Path: IGPGraphicsPath;
  const CombineMode: TGPCombineMode);
begin
  GdipCheck(GdipSetClipPath(FNativeHandle, Path.NativeHandle, CombineMode));
end;

procedure TGPGraphics.SetClip(const Region: HRgn;
  const CombineMode: TGPCombineMode);
begin
  GdipCheck(GdipSetClipHrgn(FNativeHandle, Region, CombineMode));
end;

procedure TGPGraphics.SetClip(const G: IGPGraphics;
  const CombineMode: TGPCombineMode);
begin
  GdipCheck(GdipSetClipGraphics(FNativeHandle, G.NativeHandle, CombineMode));
end;

procedure TGPGraphics.SetClip(const Region: IGPRegion;
  const CombineMode: TGPCombineMode);
begin
  GdipCheck(GdipSetClipRegion(FNativeHandle, Region.NativeHandle, CombineMode));
end;

procedure TGPGraphics.SetClip(const Rect: TGPRectF;
  const CombineMode: TGPCombineMode);
begin
  GdipCheck(GdipSetClipRect(FNativeHandle, Rect.X, Rect.Y, Rect.Width,
    Rect.Height, CombineMode));
end;

procedure TGPGraphics.SetClipReplace(const Value: IGPRegion);
begin
  GdipCheck(GdipSetClipRegion(FNativeHandle, Value.NativeHandle, CombineModeReplace));
end;

procedure TGPGraphics.SetCompositingMode(const Value: TGPCompositingMode);
begin
  GdipCheck(GdipSetCompositingMode(FNativeHandle, Value));
end;

procedure TGPGraphics.SetCompositingQuality(const Value: TGPCompositingQuality);
begin
  GdipCheck(GdipSetCompositingQuality(FNativeHandle, Value));
end;

procedure TGPGraphics.SetInterpolationMode(const Value: TGPInterpolationMode);
begin
  GdipCheck(GdipSetInterpolationMode(FNativeHandle, Value));
end;

procedure TGPGraphics.SetPageScale(const Value: Single);
begin
  GdipCheck(GdipSetPageScale(FNativeHandle, Value));
end;

procedure TGPGraphics.SetPageUnit(const Value: TGPUnit);
begin
  GdipCheck(GdipSetPageUnit(FNativeHandle, Value));
end;

procedure TGPGraphics.SetPixelOffsetMode(const Value: TGPPixelOffsetMode);
begin
  GdipCheck(GdipSetPixelOffsetMode(FNativeHandle, Value));
end;

procedure TGPGraphics.SetRenderingOrigin(const Value: TGPPoint);
begin
  GdipCheck(GdipSetRenderingOrigin(FNativeHandle, Value.X, Value.Y));
end;

procedure TGPGraphics.SetRenderingOrigin(const X, Y: Integer);
begin
  GdipCheck(GdipSetRenderingOrigin(FNativeHandle, X, Y));
end;

procedure TGPGraphics.SetSmoothingMode(const Value: TGPSmoothingMode);
begin
  GdipCheck(GdipSetSmoothingMode(FNativeHandle, Value));
end;

procedure TGPGraphics.SetTextContrast(const Value: Integer);
begin
  GdipCheck(GdipSetTextContrast(FNativeHandle, Value));
end;

procedure TGPGraphics.SetTextRenderingHint(const Value: TGPTextRenderingHint);
begin
  GdipCheck(GdipSetTextRenderingHint(FNativeHandle, Value));
end;

procedure TGPGraphics.SetTransform(const Value: IGPMatrix);
begin
  GdipCheck(GdipSetWorldTransform(FNativeHandle, Value.NativeHandle));
end;

procedure TGPGraphics.TransformPoints(const DestSpace, SrcSpace: TGPCoordinateSpace;
  const Points: array of TGPPoint);
begin
  Assert(Length(Points) > 0);
  GdipCheck(GdipTransformPointsI(FNativeHandle, DestSpace, SrcSpace,
    @Points[0], Length(Points)));
end;

procedure TGPGraphics.TransformPoints(const DestSpace, SrcSpace: TGPCoordinateSpace;
  const Points: array of TGPPointF);
begin
  Assert(Length(Points) > 0);
  GdipCheck(GdipTransformPoints(FNativeHandle, DestSpace, SrcSpace,
    @Points[0], Length(Points)));
end;

procedure TGPGraphics.TranslateClip(const DX, DY: Integer);
begin
  GdipCheck(GdipTranslateClipI(FNativeHandle, DX, DY));
end;

procedure TGPGraphics.TranslateClip(const DX, DY: Single);
begin
  GdipCheck(GdipTranslateClip(FNativeHandle, DX, DY));
end;

procedure TGPGraphics.TranslateTransform(const DX, DY: Single;
  const Order: TGPMatrixOrder);
begin
  GdipCheck(GdipTranslateWorldTransform(FNativeHandle, DX, DY, Order));
end;
{$ENDREGION 'GdiplusGraphics.h'}

{$REGION 'Initialization and Finalization'}

var
  {$IF (GDIPVER >= $0110)}
  StartupInput: TGdiplusStartupInputEx;
  {$ELSE}
  StartupInput: TGdiplusStartupInput;
  {$IFEND}
  GdiplusToken: ULONG;

procedure Initialize;
begin
  TGPImageFormat.FInitialized := False;
  StartupInput.Intialize;
  GdiplusStartup(GdiplusToken, @StartupInput, nil);
end;

procedure Finalize;
begin
  GdiplusShutdown(GdiplusToken);
end;

initialization
  Initialize;

finalization
  Finalize;
{$ENDREGION 'Initialization and Finalization'}

end.
