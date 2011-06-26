unit sdaGraphics;

interface

{$INCLUDE 'sda.inc'}

uses
  sdaWindows;

type
  TColor = -$7FFFFFFF-1..$7FFFFFFF;
  PColor = ^TColor;

  TFillStyle = (fsSurface, fsBorder);
  TFillMode = (fmAlternate, fmWinding);
  TArcDirection = (arcClockWise, arcCounterClockWise);

  TLineDDACallback = procedure(X, Y: Integer) of object;

type
  TSdaCanvas = record
  private
    FHandle: HDC;
    function GetBrush: HBRUSH;
    function GetPen: HPEN;
    procedure SetBrush(const Value: HBRUSH);
    procedure SetPen(const Value: HPEN);
    function GetFont: HFONT;
    procedure SetFont(const Value: HFONT);
    function GetBackColor: TColor;
    function GetBackMode: Integer;
    function GetBrushColor: TColor;
    function GetMixMode: Integer;
    function GetPenColor: TColor;
    procedure SetBackColor(const Value: TColor);
    procedure SetBackMode(const Value: Integer);
    procedure SetBrushColor(const Value: TColor);
    procedure SetMixMode(const Value: Integer);
    procedure SetPenColor(const Value: TColor);
    function GetFillMode: TFillMode;
    procedure SetFillMode(const Value: TFillMode);
    function GetPixels(X, Y: Integer): TColor;
    procedure SetPixels(X, Y: Integer; const Value: TColor);
    function GetArcDirection: TArcDirection;
    procedure SetArcDirection(const Value: TArcDirection);
  public
    property Handle: HDC read FHandle write FHandle;

    class operator Implicit(Value: HDC): TSdaCanvas;

    class function CreateHandle(Window: HWND; NonClient: Boolean = false): HDC; overload; static;
    class function CreateHandle(CompatibleTo: HDC): HDC; overload; static;
    class function CreateHandle(const Driver, Device: string;
      const DevMode: TDevMode): HDC; overload; static;
    class function CreateHandle(const Driver, Device: string;
      DevMode: PDevMode): HDC; overload; static;
    class function CreateHandle(Bitmap: HBITMAP): HDC; overload; static;
    procedure DestroyHandle;

    property Pen: HPEN read GetPen write SetPen;
    property Brush: HBRUSH read GetBrush write SetBrush;
    property Font: HFONT read GetFont write SetFont;

    property Pixels[X, Y: Integer]: TColor read GetPixels write SetPixels;
    property BrushColor: TColor read GetBrushColor write SetBrushColor;
    property PenColor: TColor read GetPenColor write SetPenColor;
    property BackColor: TColor read GetBackColor write SetBackColor;
    property BackMode: Integer read GetBackMode write SetBackMode;
    property MixMode: Integer read GetMixMode write SetMixMode;
    property FillMode: TFillMode read GetFillMode write SetFillMode;
    property ArcDirection: TArcDirection read GetArcDirection write SetArcDirection;

    procedure FloodFill(X, Y: Integer; Color: TColor;
      FillStyle: TFillStyle);

    procedure Rectangle(const Rect: TRect);
    procedure FrameRect(const Rect: TRect);
    procedure InvertRect(const Rect: TRect);
    procedure FillRect(const Rect: TRect);
    procedure RoundRect(const Rect: TRect; Width, Height: Integer);

    procedure Ellipse(const Rect: TRect);
    procedure Chord(const Rect: TRect; const Start, Finish: TPoint);
    procedure Pie(const Rect: TRect; const Start, Finish: TPoint);
    procedure Arc(const Rect: TRect; const Start, Finish: TPoint);
    procedure ArcTo(const Rect: TRect; const Start, Finish: TPoint);
    procedure AngleArc(const Center: TPoint; Radius: Cardinal;
      StartAngle, SweepAngle: Single);

    procedure Polygon(const Points: array of TPoint);
    procedure Polyline(const Points: array of TPoint);
    procedure PolylineTo(const Points: array of TPoint);
    procedure PolyBezier(const Points: array of TPoint);
    procedure PolyBezierTo(const Points: array of TPoint);

    procedure MoveTo(X, Y: Integer);
    procedure LineTo(X, Y: Integer);
    procedure LineDDA(const Start, Finish: TPoint;
      const Callback: TLineDDACallback);

    procedure CopyRect(const Dest: TRect; DC: HDC; const Src: TRect);

    procedure Save;
    procedure Restore;

    function UnselectBitmap: HBITMAP;

    procedure Flush;
    procedure CancelPendingOperations;
    procedure PaintDesktop;
  end;

  TSdaIcon = record
  private
    FHandle: HICON;
    function GetIconSizes: TSize;
    function GetHeight: Integer;
    function GetWidth: Integer;
    function GetIsCursor: Boolean;
    function GetHotSpot: TPoint;
  public
    property Handle: HICON read FHandle write FHandle;
    class function CreateHandle(Instance: HMODULE; ResName: string;
      Width, Height: Integer; LoadCursor: Boolean = false;
      Flags: DWORD = LR_DEFAULTCOLOR): HICON; overload; static;
    class function CreateHandle(const Data; DataSize: Integer;
      Width, Height: Integer; CreateCursor: Boolean = false;
      Flags: DWORD = LR_DEFAULTCOLOR): HICON; overload; static;
    class function CreateHandle(const Image, Mask; Width, Height, ColorDepth: Integer;
      CreateCursor: Boolean; HotSpot: TPoint): HICON; overload; static;
    class function CreateHandle(Image, Mask: HBITMAP; CreateCursor: Boolean;
      HotSpot: TPoint): HICON; overload; static;
    procedure DestroyHandle;

    class operator Implicit(Value: HICON): TSdaIcon;

    function CopyHandle: HICON;

    property IsCursor: Boolean read GetIsCursor;
    property Width: Integer read GetWidth;
    property Height: Integer read GetHeight;
    property HotSpot: TPoint read GetHotSpot;

    procedure Draw(DC: HDC; Left, Top: Integer; AniStep: Integer = 0);
    procedure StretchDraw(DC: HDC; const Rect: TRect; AniStep: Integer = 0);
  end;

  TPixelFormat = (
    pfDeviceDependent = 0,
    pf1Bit = 1,
    pf4Bit = 4,
    pf8Bit = 8,
    pf16Bit = 16,
    pf24Bit = 24,
    pf32Bit = 32,
    pfCustom
  );

  TSdaBitmap = record
  private
    FHandle: HBITMAP;
    function GetHeight: Integer;
    function GetWidth: Integer;
    function GetData: Pointer;
    function GetPixelFormat: TPixelFormat;
    function GetScanLine(Index: Integer): Pointer;
    function GetStride: Integer;
  public
    property Handle: HBITMAP read FHandle write FHandle;
    class operator Implicit(Value: HBITMAP): TSdaBitmap; inline;
    procedure DestroyHandle; inline;

    class function CreateHandle(Width, Height: Integer;
      DC: HDC = 0): HBITMAP; overload; inline; static;
    class function CreateHandle(Width, Height: Integer; const Palette: array of TColor;
      PixelFormat: TPixelFormat = pf24Bit): HBITMAP; overload; static;

    property Width: Integer read GetWidth;
    property Height: Integer read GetHeight;
    property PixelFormat: TPixelFormat read GetPixelFormat;

    property Data: Pointer read GetData;
    property ScanLine[Index: Integer]: Pointer read GetScanLine;

    procedure Draw(DC: HDC; Left, Top: Integer);
    procedure StretchDraw(DC: HDC; const Rect: TRect);

    property Stride: Integer read GetStride;
  end;

const
  clSystemColor = $FF000000;

  clScrollBar = TColor(clSystemColor or COLOR_SCROLLBAR);
  clBackground = TColor(clSystemColor or COLOR_BACKGROUND);
  clActiveCaption = TColor(clSystemColor or COLOR_ACTIVECAPTION);
  clInactiveCaption = TColor(clSystemColor or COLOR_INACTIVECAPTION);
  clMenu = TColor(clSystemColor or COLOR_MENU);
  clWindow = TColor(clSystemColor or COLOR_WINDOW);
  clWindowFrame = TColor(clSystemColor or COLOR_WINDOWFRAME);
  clMenuText = TColor(clSystemColor or COLOR_MENUTEXT);
  clWindowText = TColor(clSystemColor or COLOR_WINDOWTEXT);
  clCaptionText = TColor(clSystemColor or COLOR_CAPTIONTEXT);
  clActiveBorder = TColor(clSystemColor or COLOR_ACTIVEBORDER);
  clInactiveBorder = TColor(clSystemColor or COLOR_INACTIVEBORDER);
  clAppWorkSpace = TColor(clSystemColor or COLOR_APPWORKSPACE);
  clHighlight = TColor(clSystemColor or COLOR_HIGHLIGHT);
  clHighlightText = TColor(clSystemColor or COLOR_HIGHLIGHTTEXT);
  clBtnFace = TColor(clSystemColor or COLOR_BTNFACE);
  clBtnShadow = TColor(clSystemColor or COLOR_BTNSHADOW);
  clGrayText = TColor(clSystemColor or COLOR_GRAYTEXT);
  clBtnText = TColor(clSystemColor or COLOR_BTNTEXT);
  clInactiveCaptionText = TColor(clSystemColor or COLOR_INACTIVECAPTIONTEXT);
  clBtnHighlight = TColor(clSystemColor or COLOR_BTNHIGHLIGHT);
  cl3DDkShadow = TColor(clSystemColor or COLOR_3DDKSHADOW);
  cl3DLight = TColor(clSystemColor or COLOR_3DLIGHT);
  clInfoText = TColor(clSystemColor or COLOR_INFOTEXT);
  clInfoBk = TColor(clSystemColor or COLOR_INFOBK);
  clHotLight = TColor(clSystemColor or COLOR_HOTLIGHT);
  clGradientActiveCaption = TColor(clSystemColor or COLOR_GRADIENTACTIVECAPTION);
  clGradientInactiveCaption = TColor(clSystemColor or COLOR_GRADIENTINACTIVECAPTION);
  clMenuHighlight = TColor(clSystemColor or COLOR_MENUHILIGHT);
  clMenuBar = TColor(clSystemColor or COLOR_MENUBAR);

  clBlack = TColor($000000);
  clMaroon = TColor($000080);
  clGreen = TColor($008000);
  clOlive = TColor($008080);
  clNavy = TColor($800000);
  clPurple = TColor($800080);
  clTeal = TColor($808000);
  clGray = TColor($808080);
  clSilver = TColor($C0C0C0);
  clRed = TColor($0000FF);
  clLime = TColor($00FF00);
  clYellow = TColor($00FFFF);
  clBlue = TColor($FF0000);
  clFuchsia = TColor($FF00FF);
  clAqua = TColor($FFFF00);
  clLtGray = TColor($C0C0C0);
  clDkGray = TColor($808080);
  clWhite = TColor($FFFFFF);

  clMoneyGreen = TColor($C0DCC0);
  clSkyBlue = TColor($F0CAA6);
  clCream = TColor($F0FBFF);
  clMedGray = TColor($A4A0A0);

  clNone = TColor($1FFFFFFF);
  clDefault = TColor($20000000);

  { The following "cl" values come from the Web Named Color palette and
    are stored in the Windows COLORREF byte order x00bbggrr }
  { Two of these colors are duplicates Aqua/Cyan Fuchsia/Magenta }
  clWebSnow = $FAFAFF;
  clWebFloralWhite = $F0FAFF;
  clWebLavenderBlush = $F5F0FF;
  clWebOldLace = $E6F5FD;
  clWebIvory = $F0FFFF;
  clWebCornSilk = $DCF8FF;
  clWebBeige = $DCF5F5;
  clWebAntiqueWhite = $D7EBFA;
  clWebWheat = $B3DEF5;
  clWebAliceBlue = $FFF8F0;
  clWebGhostWhite = $FFF8F8;
  clWebLavender = $FAE6E6;
  clWebSeashell = $EEF5FF;
  clWebLightYellow = $E0FFFF;
  clWebPapayaWhip = $D5EFFF;
  clWebNavajoWhite = $ADDEFF;
  clWebMoccasin = $B5E4FF;
  clWebBurlywood = $87B8DE;
  clWebAzure = $FFFFF0;
  clWebMintcream = $FAFFF5;
  clWebHoneydew = $F0FFF0;
  clWebLinen = $E6F0FA;
  clWebLemonChiffon = $CDFAFF;
  clWebBlanchedAlmond = $CDEBFF;
  clWebBisque = $C4E4FF;
  clWebPeachPuff = $B9DAFF;
  clWebTan = $8CB4D2;
  // yellows/reds yellow -> rosybrown
  clWebYellow = $00FFFF;
  clWebDarkOrange = $008CFF;
  clWebRed = $0000FF;
  clWebDarkRed = $00008B;
  clWebMaroon = $000080;
  clWebIndianRed = $5C5CCD;
  clWebSalmon = $7280FA;
  clWebCoral = $507FFF;
  clWebGold = $00D7FF;
  clWebTomato = $4763FF;
  clWebCrimson = $3C14DC;
  clWebBrown = $2A2AA5;
  clWebChocolate = $1E69D2;
  clWebSandyBrown = $60A4F4;
  clWebLightSalmon = $7AA0FF;
  clWebLightCoral = $8080F0;
  clWebOrange = $00A5FF;
  clWebOrangeRed = $0045FF;
  clWebFirebrick = $2222B2;
  clWebSaddleBrown = $13458B;
  clWebSienna = $2D52A0;
  clWebPeru = $3F85CD;
  clWebDarkSalmon = $7A96E9;
  clWebRosyBrown = $8F8FBC;
  // greens palegoldenrod -> darkseagreen
  clWebPaleGoldenrod = $AAE8EE;
  clWebLightGoldenrodYellow = $D2FAFA;
  clWebOlive = $008080;
  clWebForestGreen = $228B22;
  clWebGreenYellow = $2FFFAD;
  clWebChartreuse = $00FF7F;
  clWebLightGreen = $90EE90;
  clWebAquamarine = $D4FF7F;
  clWebSeaGreen = $578B2E;
  clWebGoldenRod = $20A5DA;
  clWebKhaki = $8CE6F0;
  clWebOliveDrab = $238E6B;
  clWebGreen = $008000;
  clWebYellowGreen = $32CD9A;
  clWebLawnGreen = $00FC7C;
  clWebPaleGreen = $98FB98;
  clWebMediumAquamarine = $AACD66;
  clWebMediumSeaGreen = $71B33C;
  clWebDarkGoldenRod = $0B86B8;
  clWebDarkKhaki = $6BB7BD;
  clWebDarkOliveGreen = $2F6B55;
  clWebDarkgreen = $006400;
  clWebLimeGreen = $32CD32;
  clWebLime = $00FF00;
  clWebSpringGreen = $7FFF00;
  clWebMediumSpringGreen = $9AFA00;
  clWebDarkSeaGreen = $8FBC8F;
  // greens/blues lightseagreen -> navy
  clWebLightSeaGreen = $AAB220;
  clWebPaleTurquoise = $EEEEAF;
  clWebLightCyan = $FFFFE0;
  clWebLightBlue = $E6D8AD;
  clWebLightSkyBlue = $FACE87;
  clWebCornFlowerBlue = $ED9564;
  clWebDarkBlue = $8B0000;
  clWebIndigo = $82004B;
  clWebMediumTurquoise = $CCD148;
  clWebTurquoise = $D0E040;
  clWebCyan = $FFFF00; //   clWebAqua
  clWebAqua = $FFFF00;
  clWebPowderBlue = $E6E0B0;
  clWebSkyBlue = $EBCE87;
  clWebRoyalBlue = $E16941;
  clWebMediumBlue = $CD0000;
  clWebMidnightBlue = $701919;
  clWebDarkTurquoise = $D1CE00;
  clWebCadetBlue = $A09E5F;
  clWebDarkCyan = $8B8B00;
  clWebTeal = $808000;
  clWebDeepskyBlue = $FFBF00;
  clWebDodgerBlue = $FF901E;
  clWebBlue = $FF0000;
  clWebNavy = $800000;
  // violets/pinks darkviolet -> pink
  clWebDarkViolet = $D30094;
  clWebDarkOrchid = $CC3299;
  clWebMagenta = $FF00FF; //   clWebFuchsia
  clWebFuchsia = $FF00FF;
  clWebDarkMagenta = $8B008B;
  clWebMediumVioletRed = $8515C7;
  clWebPaleVioletRed = $9370DB;
  clWebBlueViolet = $E22B8A;
  clWebMediumOrchid = $D355BA;
  clWebMediumPurple = $DB7093;
  clWebPurple = $800080;
  clWebDeepPink = $9314FF;
  clWebLightPink = $C1B6FF;
  clWebViolet = $EE82EE;
  clWebOrchid = $D670DA;
  clWebPlum = $DDA0DD;
  clWebThistle = $D8BFD8;
  clWebHotPink = $B469FF;
  clWebPink = $CBC0FF;
  // blue/gray/black lightsteelblue -> black
  clWebLightSteelBlue = $DEC4B0;
  clWebMediumSlateBlue = $EE687B;
  clWebLightSlateGray = $998877;
  clWebWhite = $FFFFFF;
  clWebLightgrey = $D3D3D3;
  clWebGray = $808080;
  clWebSteelBlue = $B48246;
  clWebSlateBlue = $CD5A6A;
  clWebSlateGray = $908070;
  clWebWhiteSmoke = $F5F5F5;
  clWebSilver = $C0C0C0;
  clWebDimGray = $696969;
  clWebMistyRose = $E1E4FF;
  clWebDarkSlateBlue = $8B3D48;
  clWebDarkSlategray = $4F4F2F;
  clWebGainsboro = $DCDCDC;
  clWebDarkGray = $A9A9A9;
  clWebBlack = $000000;

function ColorToRGB(Color: TColor): Longint;

implementation

uses
  sdaSysUtils;

function ColorToRGB(Color: TColor): Longint;
begin
  if Color < 0 then Result := GetSysColor(Color and $000000FF)
    else Result := Color;
end;

{ TSdaCanvas }

procedure TSdaCanvas.AngleArc(const Center: TPoint; Radius: Cardinal;
  StartAngle, SweepAngle: Single);
begin
  sdaWindows.AngleArc(FHandle, Center.X, Center.Y, Radius, StartAngle, SweepAngle);
end;

procedure TSdaCanvas.Arc(const Rect: TRect; const Start, Finish: TPoint);
begin
  sdaWindows.Arc(FHandle, Rect.Left, Rect.Top, Rect.Right, Rect.Bottom,
    Start.X, Start.Y, Finish.X, Finish.Y);
end;

procedure TSdaCanvas.ArcTo(const Rect: TRect; const Start, Finish: TPoint);
begin
  sdaWindows.ArcTo(FHandle, Rect.Left, Rect.Top, Rect.Right, Rect.Bottom,
    Start.X, Start.Y, Finish.X, Finish.Y);
end;

procedure TSdaCanvas.CancelPendingOperations;
begin
  CancelDC(FHandle);
end;

procedure TSdaCanvas.Chord(const Rect: TRect; const Start, Finish: TPoint);
begin
  sdaWindows.Chord(FHandle, Rect.Left, Rect.Top, Rect.Right, Rect.Bottom,
    Start.X, Start.Y, Finish.X, Finish.Y);
end;

procedure TSdaCanvas.CopyRect(const Dest: TRect; DC: HDC; const Src: TRect);
begin
  StretchBlt(Handle, Dest.Left, Dest.Top, Dest.Right - Dest.Left, Dest.Bottom - Dest.Top,
    DC, Src.Left, Src.Top, Src.Right - Src.Left, Src.Bottom - Src.Top, SRCCOPY);
end;

class function TSdaCanvas.CreateHandle(Bitmap: HBITMAP): HDC;
begin
  Result := CreateCompatibleDC(0);
  if Result <> 0 then
  begin
    Bitmap := SelectObject(Result, Bitmap);
    if Bitmap <> 0 then DeleteObject(Bitmap);
  end;
end;

class function TSdaCanvas.CreateHandle(const Driver, Device: string;
  DevMode: PDevMode): HDC;
begin
  if AnsiSameText(Driver, 'DISPLAY') then DevMode := nil;
  Result := CreateDC(PChar(Driver), PChar(Device), nil, @DevMode);
end;

class function TSdaCanvas.CreateHandle(Window: HWND; NonClient: Boolean): HDC;
begin
  if NonClient then Result := GetWindowDC(Window)
    else Result := GetDC(Window);
end;

class function TSdaCanvas.CreateHandle(CompatibleTo: HDC): HDC;
begin
  Result := CreateCompatibleDC(CompatibleTo);
end;

class function TSdaCanvas.CreateHandle(const Driver, Device: string;
  const DevMode: TDevMode): HDC;
begin
  if AnsiSameText(Driver, 'DISPLAY')
    then Result := CreateDC(PChar(Driver), PChar(Device), nil, nil)
    else Result := CreateDC(PChar(Driver), PChar(Device), nil, @DevMode);
end;

procedure TSdaCanvas.DestroyHandle;
var
  h: HWND;
begin
  // Do not use this method if you have obtained HDC by calling GetDC(0)
  // because in this case DC will be destroyed instead to be passed
  // to ReleaseDC(0, DC)
  h := WindowFromDC(FHandle);
  if h <> 0 then ReleaseDC(h, FHandle)
    else DeleteDC(FHandle);
end;

procedure TSdaCanvas.Ellipse(const Rect: TRect);
begin
  sdaWindows.Ellipse(FHandle, Rect.Left, Rect.Top, Rect.Right, Rect.Bottom);
end;

procedure TSdaCanvas.FillRect(const Rect: TRect);
begin
  sdaWindows.FillRect(FHandle, Rect, 0);
end;

procedure TSdaCanvas.FloodFill(X, Y: Integer; Color: TColor;
  FillStyle: TFillStyle);
const
  FillStyles: array[TFillStyle] of Word = (FLOODFILLSURFACE, FLOODFILLBORDER);
begin
  ExtFloodFill(FHandle, X, Y, Color, FillStyles[FillStyle]);
end;

procedure TSdaCanvas.Flush;
begin
  GdiFlush;
end;

procedure TSdaCanvas.FrameRect(const Rect: TRect);
begin
  sdaWindows.FrameRect(FHandle, Rect, 0);
end;

function TSdaCanvas.GetArcDirection: TArcDirection;
begin
  if sdaWindows.GetArcDirection(FHandle) = AD_CLOCKWISE then Result := arcClockWise
    else Result := arcCounterClockWise;
end;

function TSdaCanvas.GetBackColor: TColor;
begin
  Result := GetBkColor(FHandle);
end;

function TSdaCanvas.GetBackMode: Integer;
begin
  Result := GetBkMode(FHandle);
end;

function TSdaCanvas.GetBrush: HBRUSH;
begin
  Result := GetCurrentObject(FHandle, OBJ_BRUSH);
end;

function TSdaCanvas.GetBrushColor: TColor;
begin
  Result := GetDCBrushColor(FHandle);
end;

function TSdaCanvas.GetFillMode: TFillMode;
begin
  if GetPolyFillMode(FHandle) = ALTERNATE then Result := fmAlternate
    else Result := fmWinding;
end;

function TSdaCanvas.GetFont: HFONT;
begin
  Result := GetCurrentObject(FHandle, OBJ_FONT);
end;

function TSdaCanvas.GetMixMode: Integer;
begin
  Result := GetROP2(FHandle);
end;

function TSdaCanvas.GetPen: HPEN;
begin
  Result := GetCurrentObject(FHandle, OBJ_PEN);
end;

function TSdaCanvas.GetPenColor: TColor;
begin
  Result := GetDCPenColor(FHandle);
end;

function TSdaCanvas.GetPixels(X, Y: Integer): TColor;
begin
  Result := GetPixel(FHandle, X, Y);
end;

class operator TSdaCanvas.Implicit(Value: HDC): TSdaCanvas;
begin
  Result.Handle := Value;
end;

procedure TSdaCanvas.InvertRect(const Rect: TRect);
begin
  sdaWindows.InvertRect(FHandle, Rect);
end;

procedure TSdaCanvas.LineDDA(const Start, Finish: TPoint;
  const Callback: TLineDDACallback);

type
  PLineDDACallback = ^TLineDDACallback;

  procedure LineDDAProc(X, Y: Integer; Data: PLineDDACallback);
  begin
    Data^(X, Y);
  end;

begin
  sdaWindows.LineDDA(Start.X, Start.Y, Finish.X, Finish.Y, @LineDDAProc,
    NativeInt(@Callback));
end;

procedure TSdaCanvas.LineTo(X, Y: Integer);
begin
  sdaWindows.LineTo(FHandle, X, Y);
end;

procedure TSdaCanvas.MoveTo(X, Y: Integer);
begin
  sdaWindows.MoveToEx(FHandle, X, Y, nil);
end;

procedure TSdaCanvas.PaintDesktop;
begin
  sdaWindows.PaintDesktop(FHandle);
end;

procedure TSdaCanvas.Pie(const Rect: TRect; const Start, Finish: TPoint);
begin
  sdaWindows.Pie(FHandle, Rect.Left, Rect.Top, Rect.Right, Rect.Bottom,
    Start.X, Start.Y, Finish.X, Finish.Y);
end;

procedure TSdaCanvas.PolyBezier(const Points: array of TPoint);
begin
  if Length(Points) <= 0 then Exit;
  sdaWindows.PolyBezier(FHandle, Points[0], Length(Points));
end;

procedure TSdaCanvas.PolyBezierTo(const Points: array of TPoint);
begin
  if Length(Points) <= 0 then Exit;
  sdaWindows.PolyBezierTo(FHandle, Points[0], Length(Points));
end;

procedure TSdaCanvas.Polygon(const Points: array of TPoint);
begin
  if Length(Points) <= 0 then Exit;
  sdaWindows.Polygon(FHandle, Points[0], Length(Points));
end;

procedure TSdaCanvas.Polyline(const Points: array of TPoint);
begin
  if Length(Points) <= 0 then Exit;
  sdaWindows.Polyline(FHandle, Points[0], Length(Points));
end;

procedure TSdaCanvas.PolylineTo(const Points: array of TPoint);
begin
  if Length(Points) <= 0 then Exit;
  sdaWindows.PolylineTo(FHandle, Points[0], Length(Points));
end;

procedure TSdaCanvas.Rectangle(const Rect: TRect);
begin
  sdaWindows.Rectangle(FHandle, Rect.Left, Rect.Top, Rect.Right, Rect.Bottom);
end;

procedure TSdaCanvas.Restore;
begin
  RestoreDC(FHandle, -1);
end;

procedure TSdaCanvas.RoundRect(const Rect: TRect; Width, Height: Integer);
begin
  sdaWindows.RoundRect(FHandle, Rect.Left, Rect.Top, Rect.Right, Rect.Bottom,
    Width, Height);
end;

procedure TSdaCanvas.Save;
begin
  SaveDC(FHandle);
end;

procedure TSdaCanvas.SetArcDirection(const Value: TArcDirection);
begin
  if Value = arcClockWise then sdaWindows.SetArcDirection(FHandle, AD_CLOCKWISE)
    else sdaWindows.SetArcDirection(FHandle, AD_COUNTERCLOCKWISE);
end;

procedure TSdaCanvas.SetBackColor(const Value: TColor);
begin
  SetBkColor(FHandle, ColorToRGB(Value));
end;

procedure TSdaCanvas.SetBackMode(const Value: Integer);
begin
  SetBkMode(FHandle, Value);
end;

procedure TSdaCanvas.SetBrush(const Value: HBRUSH);
var
  hb: HBRUSH;
begin
  hb := SelectObject(FHandle, Value);
  if hb <> 0 then DeleteObject(hb);
end;

procedure TSdaCanvas.SetBrushColor(const Value: TColor);
begin
  SetDCBrushColor(FHandle, ColorToRGB(Value));
end;

procedure TSdaCanvas.SetFillMode(const Value: TFillMode);
begin
  if Value = fmAlternate then SetPolyFillMode(FHandle, ALTERNATE)
    else SetPolyFillMode(FHandle, WINDING);
end;

procedure TSdaCanvas.SetFont(const Value: HFONT);
var
  hf: HFONT;
begin
  hf := SelectObject(FHandle, Value);
  if hf <> 0 then DeleteObject(hf);
end;

procedure TSdaCanvas.SetMixMode(const Value: Integer);
begin
  SetROP2(FHandle, Value);
end;

procedure TSdaCanvas.SetPen(const Value: HPEN);
var
  hp: HBRUSH;
begin
  hp := SelectObject(FHandle, Value);
  if hp <> 0 then DeleteObject(hp);
end;

procedure TSdaCanvas.SetPenColor(const Value: TColor);
begin
  SetDCPenColor(FHandle, ColorToRGB(Value));
end;

procedure TSdaCanvas.SetPixels(X, Y: Integer; const Value: TColor);
begin
  SetPixel(FHandle, X, Y, ColorToRGB(Value));
end;

function TSdaCanvas.UnselectBitmap: HBITMAP;
var
  hbm: HBITMAP;
begin
  hbm := CreateCompatibleBitmap(0, 0, 0);
  if hbm = 0 then Exit(0);
  Result := SelectObject(Handle, hbm);
end;

{ TSdaIcon }

function TSdaIcon.CopyHandle: HICON;
begin
  Result := CopyIcon(FHandle);
end;

class function TSdaIcon.CreateHandle(Instance: HMODULE; ResName: string; Width,
  Height: Integer; LoadCursor: Boolean; Flags: DWORD): HICON;
var
  dwType: DWORD;
begin
  if LoadCursor then dwType := IMAGE_CURSOR else dwType := IMAGE_ICON;
  Result := LoadImage(HInstance, PChar(ResName), dwType, Width, Height, Flags);
end;

class function TSdaIcon.CreateHandle(const Data; DataSize, Width,
  Height: Integer; CreateCursor: Boolean; Flags: DWORD): HICON;
begin
  if (@Data = nil) or (DataSize <= 0) then Exit(0);
  Result := CreateIconFromResourceEx(@Data, DataSize, not CreateCursor, $00030000,
    Width, Height, Flags);
end;

procedure TSdaIcon.DestroyHandle;
begin
  if IsCursor then DestroyCursor(FHandle)
    else DestroyIcon(FHandle);
  FHandle := 0;
end;

procedure TSdaIcon.Draw(DC: HDC; Left, Top: Integer; AniStep: Integer);
begin
  DrawIconEx(DC, Left, Top, FHandle, 0, 0, AniStep, 0, DI_NORMAL);
end;

procedure TSdaIcon.StretchDraw(DC: HDC; const Rect: TRect; AniStep: Integer);
begin
  DrawIconEx(DC, Rect.Left, Rect.Top, FHandle, Rect.Right - Rect.Left,
    Rect.Bottom - Rect.Top, AniStep, 0, DI_NORMAL);
end;

function TSdaIcon.GetIconSizes: TSize;
var
  ii: TIconInfo;
  bmp: BITMAP;
begin
  FillChar(Result, SizeOf(Result), 0);
  FillChar(ii, SizeOf(ii), 0);
  if GetIconInfo(FHandle, ii) then
  begin
    FillChar(bmp, SizeOf(bmp), 0);
    if ii.hbmColor = 0 then ii.hbmColor := ii.hbmMask;
    if GetObject(ii.hbmColor, SizeOf(bmp), @bmp) <> 0 then
    begin
      Result.cx := bmp.bmWidth;
      Result.cy := bmp.bmHeight;
      if bmp.bmBitsPixel = 1 then
        Result.cy := Result.cy div 2;
    end;
    DeleteObject(ii.hbmMask);
    if ii.hbmColor <> ii.hbmMask then
      DeleteObject(ii.hbmColor);
  end;
end;

function TSdaIcon.GetIsCursor: Boolean;
var
  ii: TIconInfo;
begin
  FillChar(ii, SizeOf(ii), 0);
  if GetIconInfo(FHandle, ii) then
  begin
    DeleteObject(ii.hbmMask);
    DeleteObject(ii.hbmColor);
    Result := not ii.fIcon;
  end else Result := false;
end;

function TSdaIcon.GetHotSpot: TPoint;
var
  ii: TIconInfo;
begin
  FillChar(ii, SizeOf(ii), 0);
  if GetIconInfo(FHandle, ii) then
  begin
    DeleteObject(ii.hbmMask);
    DeleteObject(ii.hbmColor);
    Result := Point(ii.xHotspot, ii.yHotspot);
  end else Result := Point(0, 0);
end;

function TSdaIcon.GetHeight: Integer;
begin
  Result := GetIconSizes.cy;
end;

function TSdaIcon.GetWidth: Integer;
begin
  Result := GetIconSizes.cx;
end;

class operator TSdaIcon.Implicit(Value: HICON): TSdaIcon;
begin
  Result.Handle := Value;
end;

class function TSdaIcon.CreateHandle(const Image, Mask; Width, Height,
  ColorDepth: Integer; CreateCursor: Boolean; HotSpot: TPoint): HICON;
begin
  if CreateCursor then
  begin
    Result := sdaWindows.CreateCursor(HInstance, HotSpot.X, HotSpot.Y,
      Width, Height, @Mask, @Image);
  end else
  begin
    Result := CreateIcon(HInstance, Width, Height, 1, ColorDepth, @Mask, @Image);
  end;
end;

class function TSdaIcon.CreateHandle(Image, Mask: HBITMAP; CreateCursor: Boolean;
  HotSpot: TPoint): HICON;
var
  ii: ICONINFO;
begin
  ii.fIcon := not CreateCursor;
  ii.xHotspot := HotSpot.X;
  ii.yHotspot := HotSpot.Y;
  ii.hbmMask := Mask;
  ii.hbmColor := Image;
  Result := CreateIconIndirect(ii);
end;

{ TSdaBitmap }

class function TSdaBitmap.CreateHandle(Width, Height: Integer; DC: HDC): HBITMAP;
var
  h: HDC;
begin
  if DC = 0 then h := GetDC(0) else h := DC;
  Result := CreateCompatibleBitmap(h, Width, Height);
  if DC = 0 then ReleaseDC(0, h);
end;

class function TSdaBitmap.CreateHandle(Width, Height: Integer;
  const Palette: array of TColor; PixelFormat: TPixelFormat): HBITMAP;
var
  p: Pointer;
  bmp: PBITMAPINFO;
  n: Integer;
  pcl: ^COLORREF;
  i: Integer;
begin
  if PixelFormat in [pfDeviceDependent, pfCustom] then Exit(0);
  begin
    n := SizeOf(BITMAPINFOHEADER) + (2 shl Integer(PixelFormat));
    GetMem(bmp, n);
    try
      FillChar(bmp^, n, 0);
      bmp.bmiHeader.biSize := SizeOf(bmp.bmiHeader);
      bmp.bmiHeader.biWidth := Width;
      bmp.bmiHeader.biHeight := Height;
      bmp.bmiHeader.biPlanes := 1;
      bmp.bmiHeader.biBitCount := Integer(PixelFormat);
      bmp.bmiHeader.biCompression := BI_RGB;

      pcl := @bmp.bmiColors[0];
      n := 2 shl Integer(PixelFormat);
      if n > Length(Palette) then n := Length(Palette);
      for i := 0 to n - 1 do
      begin
        pcl^ := ColorToRGB(Palette[i]);
        Inc(pcl);
      end;

      Result := CreateDIBSection(0, bmp^, DIB_RGB_COLORS, p, 0, 0);
    finally
      FreeMem(bmp);
    end;
  end;
end;

procedure TSdaBitmap.DestroyHandle;
begin
  DeleteObject(Handle);
  FHandle := 0;
end;

function TSdaBitmap.GetData: Pointer;
var
  dib: DIBSECTION;
begin
  Result := nil;
  if Handle = 0 then Exit;
  FillChar(dib, SizeOf(dib), 0);
  if GetObject(Handle, SizeOf(dib), @dib) <> 0 then
    Result := dib.dsBm.bmBits;
end;

function TSdaBitmap.GetHeight: Integer;
var
  bmp: BITMAP;
begin
  Result := 0;
  if Handle = 0 then Exit;
  FillChar(bmp, SizeOf(bmp), 0);
  if GetObject(Handle, SizeOf(bmp), @bmp) <> 0 then
    Result := bmp.bmHeight;
end;

function TSdaBitmap.GetPixelFormat: TPixelFormat;
var
  bmp: BITMAP;
begin
  Result := pfDeviceDependent;
  if Handle = 0 then Exit;
  FillChar(bmp, SizeOf(bmp), 0);
  if GetObject(Handle, SizeOf(bmp), @bmp) <> 0 then
  begin
    if bmp.bmBits = nil then Result := pfDeviceDependent else
    if bmp.bmBitsPixel in [1, 4, 8, 16, 24, 32] then Result := TPixelFormat(bmp.bmBitsPixel)
      else Result := pfCustom;
  end;
end;

function TSdaBitmap.GetScanLine(Index: Integer): Pointer;
var
  dib: DIBSECTION;
begin
  Result := nil;
  if Handle = 0 then Exit;
  FillChar(dib, SizeOf(dib), 0);
  if GetObject(Handle, SizeOf(dib), @dib) <> 0 then
  begin
    if (Index < 0) or (Index >= dib.dsBm.bmHeight) then Exit;
    if dib.dsBm.bmBits <> nil then
    begin
      if not (dib.dsBm.bmBitsPixel in [1, 4, 8, 16, 24, 32]) then Exit;
      Result := dib.dsBm.bmBits;
      Inc(PByte(Result), dib.dsBm.bmWidthBytes);
    end;
  end;
end;

function TSdaBitmap.GetStride: Integer;
var
  bmp: BITMAP;
begin
  Result := 0;
  if Handle = 0 then Exit;
  FillChar(bmp, SizeOf(bmp), 0);
  if GetObject(Handle, SizeOf(bmp), @bmp) <> 0 then
    Result := bmp.bmWidthBytes;
end;

function TSdaBitmap.GetWidth: Integer;
var
  bmp: BITMAP;
begin
  Result := 0;
  if Handle = 0 then Exit;
  FillChar(bmp, SizeOf(bmp), 0);
  if GetObject(Handle, SizeOf(bmp), @bmp) <> 0 then
    Result := bmp.bmWidth;
end;

class operator TSdaBitmap.Implicit(Value: HBITMAP): TSdaBitmap;
begin
  Result.Handle := Value;
end;

procedure TSdaBitmap.Draw(DC: HDC; Left, Top: Integer);
var
  hc: HDC;
  bmp: BITMAP;
  hbm: HBITMAP;
begin
  if Handle = 0 then Exit;
  FillChar(bmp, SizeOf(bmp), 0);
  if GetObject(Handle, SizeOf(bmp), @bmp) <> 0 then
  begin
    hc := CreateCompatibleDC(0);
    hbm := SelectObject(hc, Handle);

    BitBlt(DC, Left, Top, bmp.bmWidth, bmp.bmHeight, hc, 0, 0, SRCCOPY);

    SelectObject(hc, hbm);
    DeleteDC(hc);
  end;
end;

procedure TSdaBitmap.StretchDraw(DC: HDC; const Rect: TRect);
var
  hc: HDC;
  bmp: BITMAP;
  hbm: HBITMAP;
begin
  if Handle = 0 then Exit;
  FillChar(bmp, SizeOf(bmp), 0);
  if GetObject(Handle, SizeOf(bmp), @bmp) <> 0 then
  begin
    hc := CreateCompatibleDC(0);
    hbm := SelectObject(hc, Handle);

    StretchBlt(DC, Rect.Left, Rect.Top, Rect.Right - Rect.Left, Rect.Bottom - Rect.Top,
      hc, 0, 0, bmp.bmWidth, bmp.bmHeight, SRCCOPY);

    SelectObject(hc, hbm);
    DeleteDC(hc);
  end;
end;

end.
