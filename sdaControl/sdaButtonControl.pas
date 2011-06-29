unit sdaButtonControl;

interface

{$INCLUDE 'sda.inc'}

uses
  sdaWindows;

// http://msdn.microsoft.com/en-us/library/bb775943(VS.85).aspx

const
  WC_BUTTON = 'Button';

  BUTTON_IMAGELIST_ALIGN_LEFT     = 0;
  BUTTON_IMAGELIST_ALIGN_RIGHT    = 1;
  BUTTON_IMAGELIST_ALIGN_TOP      = 2;
  BUTTON_IMAGELIST_ALIGN_BOTTOM   = 3;
  BUTTON_IMAGELIST_ALIGN_CENTER   = 4;

{ Button Control Styles }
const
  BS_PUSHBUTTON = 0;
  BS_DEFPUSHBUTTON = 1;
  BS_CHECKBOX = 2;
  BS_AUTOCHECKBOX = 3;
  BS_RADIOBUTTON = 4;
  BS_3STATE = 5;
  BS_AUTO3STATE = 6;
  BS_GROUPBOX = 7;
  BS_USERBUTTON = 8;
  BS_AUTORADIOBUTTON = 9;
  BS_OWNERDRAW = 11;
  BS_LEFTTEXT = $20;
  BS_TEXT = 0;
  BS_ICON = $40;
  BS_BITMAP = $80;
  BS_LEFT = $100;
  BS_RIGHT = $200;
  BS_CENTER = 768;
  BS_TOP = $400;
  BS_BOTTOM = $800;
  BS_VCENTER = 3072;
  BS_PUSHLIKE = $1000;
  BS_MULTILINE = $2000;
  BS_NOTIFY = $4000;
  BS_FLAT = $8000;
  BS_RIGHTBUTTON = BS_LEFTTEXT;

  BST_UNCHECKED = 0;
  BST_CHECKED = 1;
  BST_INDETERMINATE = 2;
  BST_PUSHED = 4;
  BST_FOCUS = 8;

{ Button Notification Codes }
const
  BN_CLICKED       = 0;
  BN_PAINT         = 1;
  BN_HILITE        = 2;
  BN_UNHILITE      = 3;
  BN_DISABLE       = 4;
  BN_DOUBLECLICKED = 5;
  BN_PUSHED = BN_HILITE;
  BN_UNPUSHED = BN_UNHILITE;
  BN_DBLCLK = BN_DOUBLECLICKED;
  BN_SETFOCUS = 6;
  BN_KILLFOCUS = 7;

{ Button Control Messages }
const
  BM_GETCHECK = $00F0;
  BM_SETCHECK = $00F1;
  BM_GETSTATE = $00F2;
  BM_SETSTATE = $00F3;
  BM_SETSTYLE = $00F4;
  BM_CLICK    = $00F5;
  BM_GETIMAGE = $00F6;
  BM_SETIMAGE = $00F7;
  BM_SETDONTCLICK = $00F8;

type
  BUTTON_IMAGELIST = packed record
    himl: HIMAGELIST;
    margin: TRect;
    uAlign: UINT;
  end;
  TButtonImageList = BUTTON_IMAGELIST;
  PButtonImageList = ^TButtonImageList;

const
  BCM_FIRST               = $1600;

  BCM_GETIDEALSIZE        = BCM_FIRST + $0001;
  BCM_SETIMAGELIST        = BCM_FIRST + $0002;
  BCM_GETIMAGELIST        = BCM_FIRST + $0003;
  BCM_SETTEXTMARGIN       = BCM_FIRST + $0004;
  BCM_GETTEXTMARGIN       = BCM_FIRST + $0005;

type
  TCheckState = (
    cbsUnchecked = BST_UNCHECKED,
    cbsGrayed = BST_INDETERMINATE,
    cbsChecked = BST_CHECKED
  );

  TButtonState = set of (
//    bsUnchecked = 0, // BST_UNCHECKED
    bsChecked = 0,   // BST_CHECKED
    bsGrayed = 1,    // BST_INDETERMINATE
    bsPushed = 2,    // BST_PUSHED,
    bsFocus = 3,     // BST_FOCUS,
    bsHot = 17,      // BST_HOT,
    bsDropDown = 18  // BST_DROPDOWNPUSHED
  );

  TImageAlign = (
    biAlignLeft = BUTTON_IMAGELIST_ALIGN_LEFT,
    biAlignTop = BUTTON_IMAGELIST_ALIGN_RIGHT,
    biAlignRight = BUTTON_IMAGELIST_ALIGN_TOP,
    biAlignBottom = BUTTON_IMAGELIST_ALIGN_BOTTOM,
    biAlignCenter = BUTTON_IMAGELIST_ALIGN_CENTER
  );

  TSdaButtonControl = record
  private
    FHandle: HWND;
    function GetStyle: DWORD;
    procedure SetStyle(const Value: DWORD);
    function GetBitmap: HBITMAP;
    function GetIcon: HICON;
    procedure SetBitmap(const Value: HBITMAP);
    procedure SetIcon(const Value: HICON);
    function GetState: TCheckState;
    procedure SetState(const Value: TCheckState);
    function GetTextMargins: TRect;
    procedure SetTextMargins(const Value: TRect);
    function GetButtonState: TButtonState;
    function GetImageAlign: TImageAlign;
    function GetImageList: HIMAGELIST;
    function GetImageMargins: TRect;
    procedure SetImageAlign(const Value: TImageAlign);
    procedure SetImageList(const Value: HIMAGELIST);
    procedure SetImageMargins(const Value: TRect);
  public
    class function CreateHandle(Left, Top, Width, Height: Integer;
      const Caption: string; Parent: HWND = 0;
      Style: DWORD = WS_CHILD or BS_PUSHBUTTON): HWND; static;
    procedure DestroyHandle;

    class operator Implicit(Value: HWND): TSdaButtonControl;

    property Handle: HWND read FHandle write FHandle;
    property Style: DWORD read GetStyle write SetStyle;

    property Icon: HICON read GetIcon write SetIcon;
    property Bitmap: HBITMAP read GetBitmap write SetBitmap;

    { Imagelist must contain images for next states:
        PBS_NORMAL = 1,
        PBS_HOT = 2,
        PBS_PRESSED = 3,
        PBS_DISABLED = 4,
        PBS_DEFAULTED = 5,
        PBS_STYLUSHOT = 6
    }
    property ImageList: HIMAGELIST read GetImageList write SetImageList;
    property ImageMargins: TRect read GetImageMargins write SetImageMargins;
    property ImageAlign: TImageAlign read GetImageAlign write SetImageAlign;

    property State: TCheckState read GetState write SetState;
    property TextMargins: TRect read GetTextMargins write SetTextMargins;
    property ButtonState: TButtonState read GetButtonState;

    procedure Click;
    function GetIdealSize: TSize;
    procedure Highlight(Highlight: Boolean = true);
  end;

implementation

{ TSdaButtonControl }

procedure TSdaButtonControl.Click;
begin
  SendMessage(FHandle, BM_CLICK, 0, 0);
end;

class function TSdaButtonControl.CreateHandle(Left, Top, Width, Height: Integer;
  const Caption: string; Parent: HWND; Style: DWORD): HWND;
begin
  Result := CreateWindowEx(0, WC_BUTTON, PChar(Caption), Style, Left, Top,
    Width, Height, Parent, 0, HInstance, nil);
end;

procedure TSdaButtonControl.DestroyHandle;
begin
  DestroyWindow(FHandle);
  FHandle := 0;
end;

function TSdaButtonControl.GetBitmap: HBITMAP;
begin
  Result := SendMessage(FHandle, BM_GETIMAGE, IMAGE_BITMAP, 0);
end;

function TSdaButtonControl.GetButtonState: TButtonState;
begin
  Result := TButtonState(SendMessage(FHandle, BM_GETSTATE, 0, 0));
end;

function TSdaButtonControl.GetIcon: HICON;
begin
  Result := SendMessage(FHandle, BM_GETIMAGE, IMAGE_ICON, 0);
end;

function TSdaButtonControl.GetIdealSize: TSize;
begin
  FillChar(Result, SizeOf(Result), 0);
  SendMessage(FHandle, BCM_GETIDEALSIZE, 0, LPARAM(@Result));
end;

function TSdaButtonControl.GetImageAlign: TImageAlign;
var
  il: BUTTON_IMAGELIST;
begin
  FillChar(il, SizeOf(il), 0);
  SendMessage(FHandle, BCM_GETIMAGELIST, 0, LPARAM(@il));
  Result := TImageAlign(il.uAlign);
end;

function TSdaButtonControl.GetImageList: HIMAGELIST;
var
  il: BUTTON_IMAGELIST;
begin
  FillChar(il, SizeOf(il), 0);
  SendMessage(FHandle, BCM_GETIMAGELIST, 0, LPARAM(@il));
  Result := il.himl;
end;

function TSdaButtonControl.GetImageMargins: TRect;
var
  il: BUTTON_IMAGELIST;
begin
  FillChar(il, SizeOf(il), 0);
  SendMessage(FHandle, BCM_GETIMAGELIST, 0, LPARAM(@il));
  Result := il.margin;
end;

function TSdaButtonControl.GetState: TCheckState;
begin
  Result := TCheckState(SendMessage(FHandle, BM_GETCHECK, 0, 0));
end;

function TSdaButtonControl.GetStyle: DWORD;
begin
  Result := GetWindowLong(FHandle, GWL_STYLE) and $0000ffff;
end;

function TSdaButtonControl.GetTextMargins: TRect;
begin
  FillChar(Result, SizeOf(Result), 0);
  SendMessage(FHandle, BCM_GETTEXTMARGIN, 0, LPARAM(@Result));
end;

procedure TSdaButtonControl.Highlight(Highlight: Boolean);
begin
  SendMessage(FHandle, BM_SETSTATE, WPARAM(BOOL(Highlight)), 0);
end;

class operator TSdaButtonControl.Implicit(Value: HWND): TSdaButtonControl;
begin
  Result.Handle := Value;
end;

procedure TSdaButtonControl.SetBitmap(const Value: HBITMAP);
begin
  SendMessage(FHandle, BM_SETIMAGE, IMAGE_BITMAP, Value);
end;

procedure TSdaButtonControl.SetIcon(const Value: HICON);
begin
  SendMessage(FHandle, BM_SETIMAGE, IMAGE_ICON, Value);
end;

procedure TSdaButtonControl.SetImageAlign(const Value: TImageAlign);
var
  il: BUTTON_IMAGELIST;
begin
  FillChar(il, SizeOf(il), 0);
  SendMessage(FHandle, BCM_GETIMAGELIST, 0, LPARAM(@il));
  il.uAlign := DWORD(Value);
  SendMessage(FHandle, BCM_SETIMAGELIST, 0, LPARAM(@il));
  InvalidateRgn(FHandle, 0, true);
end;

procedure TSdaButtonControl.SetImageList(const Value: HIMAGELIST);
var
  il: BUTTON_IMAGELIST;
begin
  FillChar(il, SizeOf(il), 0);
  SendMessage(FHandle, BCM_GETIMAGELIST, 0, LPARAM(@il));
  il.himl := Value;
  SendMessage(FHandle, BCM_SETIMAGELIST, 0, LPARAM(@il));
  InvalidateRgn(FHandle, 0, true);
end;

procedure TSdaButtonControl.SetImageMargins(const Value: TRect);
var
  il: BUTTON_IMAGELIST;
begin
  FillChar(il, SizeOf(il), 0);
  SendMessage(FHandle, BCM_GETIMAGELIST, 0, LPARAM(@il));
  il.margin := Value;
  SendMessage(FHandle, BCM_SETIMAGELIST, 0, LPARAM(@il));
  InvalidateRgn(FHandle, 0, true);
end;

procedure TSdaButtonControl.SetState(const Value: TCheckState);
begin
  SendMessage(FHandle, BM_SETCHECK, WPARAM(Value), 0);
end;

procedure TSdaButtonControl.SetStyle(const Value: DWORD);
begin
  SendMessage(FHandle, BM_SETSTYLE, Value and $0000ffff, LPARAM(BOOL(true)));
end;

procedure TSdaButtonControl.SetTextMargins(const Value: TRect);
begin
  SendMessage(FHandle, BCM_SETTEXTMARGIN, 0, LPARAM(@Value));
end;

end.
