unit sdaImageListControl;

interface

// http://msdn.microsoft.com/en-us/library/bb761391(VS.85).aspx

{$INCLUDE 'sda.inc'}

uses
  sdaWindows, sdaGraphics;

type
  HIMAGELIST = THandle;

  IMAGELISTDRAWPARAMS = packed record
    cbSize: DWORD;
    himl: HIMAGELIST;
    i: Integer;
    hdcDst: HDC;
    x: Integer;
    y: Integer;
    cx: Integer;
    cy: Integer;
    xBitmap: Integer;        // x offest from the upperleft of bitmap
    yBitmap: Integer;        // y offset from the upperleft of bitmap
    rgbBk: COLORREF;
    rgbFg: COLORREF;
    fStyle: UINT;
    dwRop: DWORD;
    { For IE >= 0x0501 }
    fState: DWORD;
    Frame: DWORD;
    crEffect: COLORREF;
  end;
  TImageListDrawParams = IMAGELISTDRAWPARAMS;
  PImageListDrawParams = ^TImageListDrawParams;

const
  ILC_MASK                = $0001;
  ILC_COLOR               = $0000;
  ILC_COLORDDB            = $00FE;
  ILC_COLOR4              = $0004;
  ILC_COLOR8              = $0008;
  ILC_COLOR16             = $0010;
  ILC_COLOR24             = $0018;
  ILC_COLOR32             = $0020;
  ILC_PALETTE             = $0800;
  ILC_MIRROR              = $00002000;
  ILC_PERITEMMIRROR       = $00008000;
  ILC_ORIGINALSIZE        = $00010000;
  ILC_HIGHQUALITYSCALE    = $00020000;

const
  ILD_NORMAL              = $0000;
  ILD_TRANSPARENT         = $0001;
  ILD_MASK                = $0010;
  ILD_IMAGE               = $0020;
  ILD_ROP                 = $0040;
  ILD_BLEND25             = $0002;
  ILD_BLEND50             = $0004;
  ILD_OVERLAYMASK         = $0F00;
  ILD_PRESERVEALPHA       = $00001000;
  ILD_SCALE               = $00002000;
  ILD_DPISCALE            = $00004000;
  ILD_ASYNC               = $00008000;

const
  ILD_SELECTED            = ILD_BLEND50;
  ILD_FOCUS               = ILD_BLEND25;
  ILD_BLEND               = ILD_BLEND50;

  ILS_NORMAL              = $00000000;
  ILS_GLOW                = $00000001;
  ILS_SHADOW              = $00000002;
  ILS_SATURATE            = $00000004;
  ILS_ALPHA               = $00000008;

  ILGT_NORMAL             = $00000000;
  ILGT_ASYNC              = $00000001;

const
  HBITMAP_CALLBACK               = HBITMAP(-1);     // only for SparseImageList

const
  ILCF_MOVE   = $00000000;
  ILCF_SWAP   = $00000001;

type
  IMAGEINFO = packed record
    hbmImage: HBitmap;
    hbmMask: HBitmap;
    Unused1: Integer;
    Unused2: Integer;
    rcImage: TRect;
  end;
  TImageInfo = IMAGEINFO;
  PImageInfo = ^TImageInfo;

type
  TImageListColorDepth = (
    ilcdDefault = ILC_COLOR,
    ilcdDeviceDependent = ILC_COLORDDB,
    ilcdColor4Bit = ILC_COLOR4,
    ilcdColor8Bit = ILC_COLOR8,
    ilcdColor16Bit = ILC_COLOR16,
    ilcdColor24Bit = ILC_COLOR24,
    ilcdColor32Bit = ILC_COLOR32
  );

  TImageListDrawingStyle = (
    ildsBlend25 = ILD_BLEND25,
    ildsFocus = ILD_FOCUS,
    ildsBlend50 = ILD_BLEND50,
    ildsSelected = ILD_SELECTED,
    ildsBlend = ILD_BLEND,
    ildsMask = ILD_MASK,
    ildsNormal = ILD_NORMAL,
    ildsTransparent = ILD_TRANSPARENT
  );

  TSdaImageListControl = {$IFDEF FPC}object{$ELSE}record{$ENDIF}
  private
    FHandle: HIMAGELIST;
    function GetCount: Integer;
    procedure SetCount(const Value: Integer);
    function GetHeight: Integer;
    function GetWidth: Integer;
    function GetBackColor: TColor;
    procedure SetBackColor(const Value: TColor);
    procedure SetHeight(const Value: Integer);
    procedure SetWidth(const Value: Integer);
    function GetDragHotSpot: TPoint;
    function GetDragImageList: HIMAGELIST;
    function GetDragPosition: TPoint;
  public
    property Handle: HIMAGELIST read FHandle write FHandle;

    {$IFDEF DELPHI}
    class operator Implicit(Value: HIMAGELIST): TSdaImageListControl;
    {$ENDIF}

    {$IFDEF DELPHI}class {$ENDIF}function CreateHandle(Width, Height: Integer; ColorDepth: TImageListColorDepth;
      Masked: Boolean = true; AllocBy: Integer = 4): HIMAGELIST; overload; static;
    {$IFDEF DELPHI}class {$ENDIF}function CreateHandle(Instance: HMODULE; const BitmapName: string;
      Width: Integer; MaskColor: TColor; Flags: DWORD = LR_DEFAULTCOLOR;
      AllocBy: Integer = 4): HIMAGELIST; overload; static;
    procedure DestroyHandle;

    function Duplicate: HIMAGELIST;
    procedure SetSize(Width, Height: Integer);

    property Count: Integer read GetCount write SetCount;
    property Width: Integer read GetWidth write SetWidth;
    property Height: Integer read GetHeight write SetHeight;
    property BackColor: TColor read GetBackColor write SetBackColor;

    procedure Add(Image, Mask: HBITMAP); overload;
    procedure Add(Image: HBITMAP; MaskColor: TColor); overload;
    procedure Add(Icon: HICON); overload;
    procedure Add(Instance: HMODULE; const IconName: string; Flags: DWORD); overload;

    procedure Replace(Index: Integer; Image, Mask: HBITMAP); overload;
    procedure Replace(Index: Integer; Icon: HICON); overload;

    procedure Swap(Index1, Index2: Integer);
    procedure Delete(Index: Integer);
    procedure Clear;

    function Extract(Index: Integer; DrawingStyle: TImageListDrawingStyle = ildsTransparent): HICON;

    procedure Draw(Index: Integer; DC: HDC; Left, Top: Integer;
      DrawingStyle: TImageListDrawingStyle = ildsTransparent;
      BlendColor: TColor = clNone; BackColor: TColor = clNone;
      Overlay: Integer = 0; Width: Integer = 0; Height: Integer = 0);

    procedure BeginDrag(Index: Integer; const HotSpot: TPoint); overload;
    procedure BeginDrag(Index: Integer; HotSpotX, HotSpotY: Integer); overload;
    procedure DragMove(const P: TPoint); overload;
    procedure DragMove(X, Y: Integer); overload;
    procedure DragEnter(Window: HWND; const P: TPoint); overload;
    procedure DragEnter(Window: HWND; X, Y: Integer); overload;
    procedure DragLeave(Window: HWND);
    procedure DragShowImage(Show: Boolean);
    procedure EndDrag;

    property DragImageList: HIMAGELIST read GetDragImageList;
    property DragPosition: TPoint read GetDragPosition;
    property DragHotSpot: TPoint read GetDragHotSpot;
  end;

{$IFDEF FPC}
operator := (Value: HIMAGELIST): TSdaImageListControl;
{$ENDIF}

function IndexToOverlayMask(Index: Integer): Integer; inline;

function ImageList_Create(CX, CY: Integer; Flags: UINT;
  Initial, Grow: Integer): HIMAGELIST; stdcall;
function ImageList_Destroy(ImageList: HIMAGELIST): Bool; stdcall;
function ImageList_GetImageCount(ImageList: HIMAGELIST): Integer; stdcall;
function ImageList_SetImageCount(himl: HIMAGELIST; uNewCount: UINT): Integer; stdcall;
function ImageList_Add(ImageList: HIMAGELIST; Image, Mask: HBitmap): Integer; stdcall;
function ImageList_ReplaceIcon(ImageList: HIMAGELIST; Index: Integer;
  Icon: HIcon): Integer; stdcall;
function ImageList_SetBkColor(ImageList: HIMAGELIST; ClrBk: TColorRef): TColorRef; stdcall;
function ImageList_GetBkColor(ImageList: HIMAGELIST): TColorRef; stdcall;
function ImageList_SetOverlayImage(ImageList: HIMAGELIST; Image: Integer;
  Overlay: Integer): Bool; stdcall;
function ImageList_Draw(ImageList: HIMAGELIST; Index: Integer;
  Dest: HDC; X, Y: Integer; Style: UINT): Bool; stdcall;
function ImageList_Replace(ImageList: HIMAGELIST; Index: Integer;
  Image, Mask: HBitmap): Bool; stdcall;
function ImageList_AddMasked(ImageList: HIMAGELIST; Image: HBitmap;
  Mask: TColorRef): Integer; stdcall;
function ImageList_DrawEx(ImageList: HIMAGELIST; Index: Integer;
  Dest: HDC; X, Y, DX, DY: Integer; Bk, Fg: TColorRef; Style: Cardinal): Bool; stdcall;
function ImageList_DrawIndirect(pimldp: PImageListDrawParams): Integer; stdcall;
function ImageList_Remove(ImageList: HIMAGELIST; Index: Integer): Bool; stdcall;
function ImageList_GetIcon(ImageList: HIMAGELIST; Index: Integer;
  Flags: Cardinal): HIcon; stdcall;
function ImageList_LoadImage(Instance: THandle; Bmp: PWideChar; CX, Grow: Integer;
  Mask: TColorRef; pType, Flags: Cardinal): HIMAGELIST; stdcall;
function ImageList_LoadImageA(Instance: THandle; Bmp: PAnsiChar; CX, Grow: Integer;
  Mask: TColorRef; pType, Flags: Cardinal): HIMAGELIST; stdcall;
function ImageList_LoadImageW(Instance: THandle; Bmp: PWideChar; CX, Grow: Integer;
  Mask: TColorRef; pType, Flags: Cardinal): HIMAGELIST; stdcall;
function ImageList_Copy(himlDst: HIMAGELIST; iDst: Integer; himlSrc: HIMAGELIST;
  Src: Integer; uFlags: UINT): Integer; stdcall;
function ImageList_BeginDrag(ImageList: HIMAGELIST; Track: Integer;
  XHotSpot, YHotSpot: Integer): Bool; stdcall;
function ImageList_EndDrag: Bool; stdcall;
function ImageList_DragEnter(LockWnd: HWnd; X, Y: Integer): Bool; stdcall;
function ImageList_DragLeave(LockWnd: HWnd): Bool; stdcall;
function ImageList_DragMove(X, Y: Integer): Bool; stdcall;
function ImageList_SetDragCursorImage(ImageList: HIMAGELIST; Drag: Integer;
  XHotSpot, YHotSpot: Integer): Bool; stdcall;
function ImageList_DragShowNolock(Show: Bool): Bool; stdcall;
function ImageList_GetDragImage(Point, HotSpot: PPoint): HIMAGELIST; overload; stdcall;
function ImageList_GetDragImage(Point: PPoint; out HotSpot: TPoint): HIMAGELIST; overload; stdcall;
function ImageList_GetIconSize(ImageList: HIMAGELIST; var CX, CY: Integer): Bool; stdcall;
function ImageList_SetIconSize(ImageList: HIMAGELIST; CX, CY: Integer): Bool; stdcall;
function ImageList_GetImageInfo(ImageList: HIMAGELIST; Index: Integer;
  var ImageInfo: TImageInfo): Bool; stdcall;
function ImageList_Merge(ImageList1: HIMAGELIST; Index1: Integer;
  ImageList2: HIMAGELIST; Index2: Integer; DX, DY: Integer): HIMAGELIST; stdcall;
function ImageList_Duplicate(himl: HIMAGELIST): HIMAGELIST; stdcall;

implementation

function IndexToOverlayMask(Index: Integer): Integer;
begin
  Result := Index shl 8;
end;

function ImageList_Create; external comctl32 name 'ImageList_Create';
function ImageList_Destroy; external comctl32 name 'ImageList_Destroy';
function ImageList_GetImageCount; external comctl32 name 'ImageList_GetImageCount';
function ImageList_SetImageCount; external comctl32 name 'ImageList_SetImageCount';
function ImageList_Add; external comctl32 name 'ImageList_Add';
function ImageList_ReplaceIcon; external comctl32 name 'ImageList_ReplaceIcon';
function ImageList_SetBkColor; external comctl32 name 'ImageList_SetBkColor';
function ImageList_GetBkColor; external comctl32 name 'ImageList_GetBkColor';
function ImageList_SetOverlayImage; external comctl32 name 'ImageList_SetOverlayImage';
function ImageList_Draw; external comctl32 name 'ImageList_Draw';
function ImageList_Replace; external comctl32 name 'ImageList_Replace';
function ImageList_AddMasked; external comctl32 name 'ImageList_AddMasked';
function ImageList_DrawEx; external comctl32 name 'ImageList_DrawEx';
function ImageList_DrawIndirect; external comctl32 name 'ImageList_DrawIndirect';
function ImageList_Remove; external comctl32 name 'ImageList_Remove';
function ImageList_GetIcon; external comctl32 name 'ImageList_GetIcon';
function ImageList_LoadImage; external comctl32 name 'ImageList_LoadImageW';
function ImageList_LoadImageA; external comctl32 name 'ImageList_LoadImageA';
function ImageList_LoadImageW; external comctl32 name 'ImageList_LoadImageW';
function ImageList_Copy; external comctl32 name 'ImageList_Copy';
function ImageList_BeginDrag; external comctl32 name 'ImageList_BeginDrag';
function ImageList_EndDrag; external comctl32 name 'ImageList_EndDrag';
function ImageList_DragEnter; external comctl32 name 'ImageList_DragEnter';
function ImageList_DragLeave; external comctl32 name 'ImageList_DragLeave';
function ImageList_DragMove; external comctl32 name 'ImageList_DragMove';
function ImageList_SetDragCursorImage; external comctl32 name 'ImageList_SetDragCursorImage';
function ImageList_DragShowNolock; external comctl32 name 'ImageList_DragShowNolock';
function ImageList_GetDragImage(Point, HotSpot: PPoint): HIMAGELIST; external comctl32 name 'ImageList_GetDragImage';
function ImageList_GetDragImage(Point: PPoint; out HotSpot: TPoint): HIMAGELIST; external comctl32 name 'ImageList_GetDragImage';
function ImageList_GetIconSize; external comctl32 name 'ImageList_GetIconSize';
function ImageList_SetIconSize; external comctl32 name 'ImageList_SetIconSize';
function ImageList_GetImageInfo; external comctl32 name 'ImageList_GetImageInfo';
function ImageList_Merge; external comctl32 name 'ImageList_Merge';
function ImageList_Duplicate; external comctl32 name 'ImageList_Duplicate';

{ TSdaImageListControl }

{$IFDEF DELPHI}class {$ENDIF}function TSdaImageListControl.CreateHandle(Width, Height: Integer;
  ColorDepth: TImageListColorDepth; Masked: Boolean;
  AllocBy: Integer): HIMAGELIST;
var
  Flags: DWORD;
begin
  Flags := DWORD(ColorDepth);
  if Masked then Flags := Flags or ILC_MASK;
  Result := ImageList_Create(Width, Height, Flags, AllocBy, AllocBy);
end;

procedure TSdaImageListControl.Add(Image, Mask: HBITMAP);
begin
  ImageList_Add(Handle, Image, Mask);
end;

procedure TSdaImageListControl.Add(Image: HBITMAP; MaskColor: TColor);
begin
  ImageList_AddMasked(Handle, Image, ColorToRGB(MaskColor));
end;

procedure TSdaImageListControl.Add(Icon: HICON);
begin
  ImageList_ReplaceIcon(Handle, -1, Icon);
end;

procedure TSdaImageListControl.BeginDrag(Index: Integer; const HotSpot: TPoint);
begin
  BeginDrag(Index, HotSpot.X, HotSpot.Y);
end;

procedure TSdaImageListControl.Add(Instance: HMODULE; const IconName: string;
  Flags: DWORD);
var
  icon: HICON;
  w, h: Integer;
begin
  ImageList_GetIconSize(Handle, w, h);
  icon := LoadImage(Instance, PChar(IconName), IMAGE_ICON, w, h, Flags);
  if icon <> 0 then
  begin
    ImageList_ReplaceIcon(Handle, -1, icon);
    DestroyIcon(icon);
  end;
end;

procedure TSdaImageListControl.BeginDrag(Index, HotSpotX, HotSpotY: Integer);
begin
  ImageList_BeginDrag(Handle, Index, HotSpotX, HotSpotY);
end;

procedure TSdaImageListControl.Clear;
begin
  ImageList_Remove(Handle, -1);
end;

{$IFDEF DELPHI}class {$ENDIF}function TSdaImageListControl.CreateHandle(Instance: HMODULE;
  const BitmapName: string; Width: Integer; MaskColor: TColor; Flags: DWORD;
  AllocBy: Integer): HIMAGELIST;
begin
  Result := ImageList_LoadImage(Instance, PChar(BitmapName), Width, AllocBy,
    ColorToRGB(MaskColor), IMAGE_BITMAP, Flags);
end;

procedure TSdaImageListControl.Delete(Index: Integer);
begin
  ImageList_Remove(Handle, Index);
end;

procedure TSdaImageListControl.DestroyHandle;
begin
  ImageList_Destroy(Handle);
  FHandle := 0;
end;

procedure TSdaImageListControl.DragMove(const P: TPoint);
begin
  ImageList_DragMove(P.X, P.Y);
end;

procedure TSdaImageListControl.DragEnter(Window: HWND; const P: TPoint);
begin
  ImageList_DragEnter(Window, P.X, P.Y);
end;

procedure TSdaImageListControl.DragEnter(Window: HWND; X, Y: Integer);
begin
  ImageList_DragEnter(Window, X, Y);
end;

procedure TSdaImageListControl.DragLeave(Window: HWND);
begin
  ImageList_DragLeave(Window);
end;

procedure TSdaImageListControl.DragMove(X, Y: Integer);
begin
  ImageList_DragMove(X, Y);
end;

procedure TSdaImageListControl.DragShowImage(Show: Boolean);
begin
  ImageList_DragShowNolock(Show);
end;

procedure TSdaImageListControl.Draw(Index: Integer; DC: HDC; Left, Top: Integer;
  DrawingStyle: TImageListDrawingStyle; BlendColor, BackColor: TColor; Overlay,
  Width, Height: Integer);
begin
  ImageList_DrawEx(Handle, Index, DC, Left, Top, Width, Height,
    ColorToRGB(BackColor), ColorToRGB(BlendColor), DWORD(DrawingStyle) or
    DWORD(IndexToOverlayMask(Overlay)));
end;

function TSdaImageListControl.Duplicate: HIMAGELIST;
begin
  Result := ImageList_Duplicate(Handle);
end;

procedure TSdaImageListControl.EndDrag;
begin
  ImageList_EndDrag;
end;

function TSdaImageListControl.Extract(Index: Integer;
  DrawingStyle: TImageListDrawingStyle): HICON;
begin
  Result := ImageList_GetIcon(Handle, Index, DWORD(DrawingStyle));
end;

function TSdaImageListControl.GetBackColor: TColor;
begin
  Result := ImageList_GetBkColor(Handle);
end;

function TSdaImageListControl.GetCount: Integer;
begin
  Result := ImageList_GetImageCount(Handle);
end;

function TSdaImageListControl.GetDragHotSpot: TPoint;
begin
  ImageList_GetDragImage(nil, @Result);
end;

function TSdaImageListControl.GetDragImageList: HIMAGELIST;
begin
  Result := ImageList_GetDragImage(nil, nil);
end;

function TSdaImageListControl.GetDragPosition: TPoint;
begin
  ImageList_GetDragImage(@Result, nil);
end;

function TSdaImageListControl.GetHeight: Integer;
var
  temp: Integer;
begin
  ImageList_GetIconSize(Handle, temp, Result);
end;

function TSdaImageListControl.GetWidth: Integer;
var
  temp: Integer;
begin
  ImageList_GetIconSize(Handle, Result, temp);
end;

{$IFDEF DELPHI}
class operator TSdaImageListControl.Implicit(Value: HIMAGELIST): TSdaImageListControl;
{$ELSE}
operator := (Value: HIMAGELIST): TSdaImageListControl;
{$ENDIF}
begin
  Result.Handle := Value;
end;

procedure TSdaImageListControl.Replace(Index: Integer; Image, Mask: HBITMAP);
begin
  ImageList_Replace(Handle, Index, Image, Mask);
end;

procedure TSdaImageListControl.Replace(Index: Integer; Icon: HICON);
begin
  ImageList_ReplaceIcon(Handle, Index, Icon);
end;

procedure TSdaImageListControl.SetBackColor(const Value: TColor);
begin
  ImageList_SetBkColor(Handle, ColorToRGB(Value));
end;

procedure TSdaImageListControl.SetCount(const Value: Integer);
begin
  ImageList_SetImageCount(Handle, Value);
end;

procedure TSdaImageListControl.SetHeight(const Value: Integer);
begin
  SetSize(Width, Value);
end;

procedure TSdaImageListControl.SetWidth(const Value: Integer);
begin
  SetSize(Value, Height);
end;

procedure TSdaImageListControl.Swap(Index1, Index2: Integer);
begin
  ImageList_Copy(Handle, Index1, Handle, Index2, ILCF_SWAP);
end;

procedure TSdaImageListControl.SetSize(Width, Height: Integer);
begin
  ImageList_SetIconSize(Handle, Width, Height);
end;

end.
