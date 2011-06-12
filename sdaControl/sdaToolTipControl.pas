unit sdaToolTipControl;

interface

{$INCLUDE 'sda.inc'}

// http://msdn.microsoft.com/en-us/library/bb760246(VS.85).aspx

uses
  sdaWindows, Messages, sdaCommCtrl, sdaGraphics;

const
  TOOLTIPS_CLASS = 'tooltips_class32';

type
  TOOLINFOA = record
    cbSize: UINT;
    uFlags: UINT;
    hwnd: HWND;
    uId: UINT;
    Rect: TRect;
    hInst: THandle;
    lpszText: PAnsiChar;
    lParam: LPARAM;
    { For Windows >= XP }
    lpReserved: Pointer;
  end;

  TOOLINFOW = record
    cbSize: UINT;
    uFlags: UINT;
    hwnd: HWND;
    uId: UINT;
    Rect: TRect;
    hInst: THandle;
    lpszText: PWideChar;
    lParam: LPARAM;
    { For Windows >= XP }
    lpReserved: Pointer;
  end;

  TOOLINFO = {$IFDEF UNICODE}TOOLINFOW{$ELSE}TOOLINFOA{$ENDIF};
  TToolInfoA = TOOLINFOA;
  TToolInfoW = TOOLINFOW;
  TToolInfo  = {$IFDEF UNICODE}TToolInfoW{$ELSE}TToolInfoA{$ENDIF};

  PToolInfoA = ^TToolInfoA;
  PToolInfoW = ^TToolInfoW;
  PToolInfo  = ^TToolInfo;

const
  TTS_ALWAYSTIP           = $01;
  TTS_NOPREFIX            = $02;
  { For IE >= 0x0500 }
  TTS_NOANIMATE           = $10;
  TTS_NOFADE              = $20;
  TTS_BALLOON             = $40;
  TTS_CLOSE               = $80;
  { For Windows >= Vista }
  TTS_USEVISUALSTYLE      = $100;  // Use themed hyperlinks

  TTF_IDISHWND            = $0001;
  TTF_CENTERTIP           = $0002;
  TTF_RTLREADING          = $0004;
  TTF_SUBCLASS            = $0010;
  TTF_TRACK               = $0020;
  TTF_ABSOLUTE            = $0080;
  TTF_TRANSPARENT         = $0100;
  TTF_PARSELINKS          = $1000;  // For IE >= 0x0501
  TTF_DI_SETITEM          = $8000;  // valid only on the TTN_NEEDTEXT callback

  TTDT_AUTOMATIC      = 0;
  TTDT_RESHOW         = 1;
  TTDT_AUTOPOP        = 2;
  TTDT_INITIAL        = 3;

  // ToolTip Icons (Set with TTM_SETTITLE)
  TTI_NONE            = 0;
  TTI_INFO            = 1;
  TTI_WARNING         = 2;
  TTI_ERROR           = 3;
  { For Windows >= Vista }
  TTI_INFO_LARGE      = 4;
  TTI_WARNING_LARGE   = 5;
  TTI_ERROR_LARGE     = 6;

  // Tool Tip Messages
  TTM_ACTIVATE        = WM_USER + 1;
  TTM_SETDELAYTIME    = WM_USER + 3;
  TTM_ADDTOOLA        = WM_USER + 4;
  TTM_DELTOOLA        = WM_USER + 5;
  TTM_NEWTOOLRECTA    = WM_USER + 6;
  TTM_GETTOOLINFOA    = WM_USER + 8;
  TTM_SETTOOLINFOA    = WM_USER + 9;
  TTM_HITTESTA        = WM_USER + 10;
  TTM_GETTEXTA        = WM_USER + 11;
  TTM_UPDATETIPTEXTA  = WM_USER + 12;
  TTM_ENUMTOOLSA      = WM_USER + 14;
  TTM_GETCURRENTTOOLA = WM_USER + 15;
  TTM_ADDTOOLW        = WM_USER + 50;
  TTM_DELTOOLW        = WM_USER + 51;
  TTM_NEWTOOLRECTW    = WM_USER + 52;
  TTM_GETTOOLINFOW    = WM_USER + 53;
  TTM_SETTOOLINFOW    = WM_USER + 54;
  TTM_HITTESTW        = WM_USER + 55;
  TTM_GETTEXTW        = WM_USER + 56;
  TTM_UPDATETIPTEXTW  = WM_USER + 57;
  TTM_ENUMTOOLSW      = WM_USER + 58;
  TTM_GETCURRENTTOOLW = WM_USER + 59;
  TTM_WINDOWFROMPOINT = WM_USER + 16;
  TTM_TRACKACTIVATE   = WM_USER + 17;
  TTM_TRACKPOSITION   = WM_USER + 18;
  TTM_SETTIPBKCOLOR   = WM_USER + 19;
  TTM_SETTIPTEXTCOLOR = WM_USER + 20;
  TTM_GETDELAYTIME    = WM_USER + 21;
  TTM_GETTIPBKCOLOR   = WM_USER + 22;
  TTM_GETTIPTEXTCOLOR = WM_USER + 23;
  TTM_SETMAXTIPWIDTH  = WM_USER + 24;
  TTM_GETMAXTIPWIDTH  = WM_USER + 25;
  TTM_SETMARGIN       = WM_USER + 26;
  TTM_GETMARGIN       = WM_USER + 27;
  TTM_POP             = WM_USER + 28;
  TTM_UPDATE          = WM_USER + 29;
  { For IE >= 0X0500 }
  TTM_GETBUBBLESIZE   = WM_USER + 30;
  TTM_ADJUSTRECT      = WM_USER + 31;
  TTM_SETTITLEA       = WM_USER + 32;
  TTM_SETTITLEW       = WM_USER + 33;
  { For Windows >= XP }
  TTM_POPUP           = WM_USER + 34;
  TTM_GETTITLE        = WM_USER + 35;

  TTM_ADDTOOL        = {$IFDEF UNICODE}TTM_ADDTOOLW{$ELSE}TTM_ADDTOOLA{$ENDIF};
  TTM_DELTOOL        = {$IFDEF UNICODE}TTM_DELTOOLW{$ELSE}TTM_DELTOOLA{$ENDIF};
  TTM_NEWTOOLRECT    = {$IFDEF UNICODE}TTM_NEWTOOLRECTW{$ELSE}TTM_NEWTOOLRECTA{$ENDIF};
  TTM_GETTOOLINFO    = {$IFDEF UNICODE}TTM_GETTOOLINFOW{$ELSE}TTM_GETTOOLINFOA{$ENDIF};
  TTM_SETTOOLINFO    = {$IFDEF UNICODE}TTM_SETTOOLINFOW{$ELSE}TTM_SETTOOLINFOA{$ENDIF};
  TTM_HITTEST        = {$IFDEF UNICODE}TTM_HITTESTW{$ELSE}TTM_HITTESTA{$ENDIF};
  TTM_GETTEXT        = {$IFDEF UNICODE}TTM_GETTEXTW{$ELSE}TTM_GETTEXTA{$ENDIF};
  TTM_UPDATETIPTEXT  = {$IFDEF UNICODE}TTM_UPDATETIPTEXTW{$ELSE}TTM_UPDATETIPTEXTA{$ENDIF};
  TTM_ENUMTOOLS      = {$IFDEF UNICODE}TTM_ENUMTOOLSW{$ELSE}TTM_ENUMTOOLSA{$ENDIF};
  TTM_GETCURRENTTOOL = {$IFDEF UNICODE}TTM_GETCURRENTTOOLW{$ELSE}TTM_GETCURRENTTOOLA{$ENDIF};
  { For IE >= 0X0500 }
  TTM_SETTITLE       = TTM_SETTITLEW;
  { For Windows >= XP }
  TTM_SETWINDOWTHEME = CCM_SETWINDOWTHEME;
  TTM_RELAYEVENT     = WM_USER + 7;
  TTM_GETTOOLCOUNT   = WM_USER + 13;

  TTN_FIRST = 0 - 520;
  TTN_LAST  = 0 - 549;

  TTN_NEEDTEXTA = TTN_FIRST - 0;
  TTN_NEEDTEXTW = TTN_FIRST - 10;
  TTN_NEEDTEXT  = {$IFDEF UNICODE}TTN_NEEDTEXTW{$ELSE}TTN_NEEDTEXTA{$ENDIF};
  TTN_SHOW      = TTN_FIRST - 1;
  TTN_POP       = TTN_FIRST - 2;
  TTN_LINKCLICK = TTN_FIRST - 3;

type
  { For Windows >= XP }
  TTGETTITLE = record
    dwSize: DWORD;
    uTitleBitmap: Integer;
    cch: Integer;
    pszTitle: PWCHAR;
  end;
  TTTGetTitle = TTGETTITLE;
  PTTGetTitle = ^TTTGetTitle;

type
  TTHITTESTINFOA = record
    hwnd: HWND;
    pt: TPoint;
    ti: TToolInfoA;
  end;
  TTHITTESTINFOW = record
    hwnd: HWND;
    pt: TPoint;
    ti: TToolInfoW;
  end;
  TTHITTESTINFO = {$IFDEF UNICODE}TTHITTESTINFOW{$ELSE}TTHITTESTINFOA{$ENDIF};
  TTTHitTestInfoA = TTHITTESTINFOA;
  TTTHitTestInfoW = TTHITTESTINFOW;
  TTTHitTestInfo  = TTHITTESTINFO;
  PTTHitTestInfoA = ^TTTHitTestInfoA;
  PTTHitTestInfoW = ^TTTHitTestInfoW;
  PTTHitTestInfo  = ^TTTHitTestInfo;

type
  tagNMTTDISPINFOA = record
    hdr: TNMHdr;
    lpszText: PAnsiChar;
    szText: array[0..79] of AnsiChar;
    hinst: HINST;
    uFlags: UINT;
    lParam: LPARAM;
  end;
  tagNMTTDISPINFOW = record
    hdr: TNMHdr;
    lpszText: PWideChar;
    szText: array[0..79] of WideChar;
    hinst: HINST;
    uFlags: UINT;
    lParam: LPARAM;
  end;
  tagNMTTDISPINFO = tagNMTTDISPINFOW;

  TNMTTDispInfoA = tagNMTTDISPINFOA;
  TNMTTDispInfoW = tagNMTTDISPINFOW;
  TNMTTDispInfo  = {$IFDEF UNICODE}TNMTTDispInfoW{$ELSE}TNMTTDispInfoA{$ENDIF};
  PNMTTDispInfoA = ^TNMTTDispInfoA;
  PNMTTDispInfoW = ^TNMTTDispInfoW;
  PNMTTDispInfo  = ^TNMTTDispInfo;

  TOOLTIPTEXTA = tagNMTTDISPINFOA;
  TOOLTIPTEXTW = tagNMTTDISPINFOW;
  TOOLTIPTEXT  = {$IFDEF UNICODE}TOOLTIPTEXTW{$ELSE}TOOLTIPTEXTA{$ENDIF};
  TToolTipTextA = TOOLTIPTEXTA;
  TToolTipTextW = TOOLTIPTEXTW;
  TToolTipText  = TOOLTIPTEXT;
  PToolTipTextA = ^TToolTipTextA;
  PToolTipTextW = ^TToolTipTextW;
  PToolTipText =  ^TToolTipText;

type
  TSdaToolTipDelayTime = (
    ttdtAutoPop = TTDT_AUTOPOP,
    ttdtInitial = TTDT_INITIAL,
    ttdtReshow = TTDT_RESHOW
  );

  TSdaToolTipToolInfo = record
    Text: string;
    Rect: TRect;
    Flags: DWORD;
  end;

  TSdaToolTipControl = record
  private
    FHandle: HWND;
    FWindow: HWND;
    procedure GetTitleInfo(var Icon: HICON; var Text: string);
    function GetTitle: string;
    procedure SetTitle(const Value: string);
    function GetTitleIcon: HICON;
    procedure SetTitleIcon(const Value: HICON);
    function GetBackColor: TColor;
    procedure SetBackColor(const Value: TColor);
    function GetTextColor: TColor;
    procedure SetTextColor(const Value: TColor);
    function GetDelayTime(Time: TSdaToolTipDelayTime): Integer;
    procedure SetDelayTime(Time: TSdaToolTipDelayTime; const Value: Integer);
    function GetMargins: TRect;
    procedure SetMargins(const Value: TRect);
    function GetMaxWidth: Integer;
    procedure SetMaxWidth(const Value: Integer);
    function GetToolCount: Integer;
    function GetTools(ID: Integer): TSdaToolTipToolInfo;
    procedure SetTools(ID: Integer; const Value: TSdaToolTipToolInfo);
    function GetToolID(Index: Integer): Integer;
    function GetCurrentTool: Integer;
    function GetStyle: DWORD;
    procedure SetStyle(const Value: DWORD);
  public
    class function CreateHandle(Style: DWORD): HWND; static;
    procedure DestroyHandle;

    class operator Implicit(Value: HWND): TSdaToolTipControl;
    class operator Explicit(Value: TSdaToolTipControl): HWND;

    property Handle: HWND read FHandle write FHandle;
    property Window: HWND read FWindow write FWindow;

    property Style: DWORD read GetStyle write SetStyle;

    procedure Activate(ActivateTip: Boolean);
    procedure ShowAtMouse;
    procedure Hide;

    // ToolTip related
    property Title: string read GetTitle write SetTitle;
    property TitleIcon: HICON read GetTitleIcon write SetTitleIcon;
    property BackColor: TColor read GetBackColor write SetBackColor;
    property TextColor: TColor read GetTextColor write SetTextColor;
    property DelayTime[Time: TSdaToolTipDelayTime]: Integer read GetDelayTime
      write SetDelayTime;
    property Margins: TRect read GetMargins write SetMargins;
    property MaxWidth: Integer read GetMaxWidth write SetMaxWidth;

    procedure Update;
    procedure SetTheme(const VisualStyleName: string);
    procedure RelayMouseEvent(const Message: TMessage);

    // Tool related
    property Tools[ID: Integer]: TSdaToolTipToolInfo read GetTools write SetTools;
    property ToolID[Index: Integer]: Integer read GetToolID;
    property ToolCount: Integer read GetToolCount;
    property CurrentTool: Integer read GetCurrentTool;

    procedure AddTool(ID: Integer; const Info: TSdaToolTipToolInfo); overload;
    procedure AddTool(ID: Integer; const Text: string; const Rect: TRect;
      Flags: DWORD); overload;
    procedure DeleteTool(ID: Integer);

    procedure SetToolRect(ID: Integer; const Rect: TRect);
    procedure SetToolText(ID: Integer; const Text: string);

    procedure TrackActivate(ID: Integer; Activate: Boolean);
    procedure TrackPosition(X, Y: Integer); overload;
    procedure TrackPosition(P: TPoint); overload;
  end;

implementation

uses
  Types;

{ TSdaToolTipControl }

procedure TSdaToolTipControl.AddTool(ID: Integer; const Info: TSdaToolTipToolInfo);
begin
  AddTool(ID, Info.Text, Info.Rect, Info.Flags);
end;

procedure TSdaToolTipControl.AddTool(ID: Integer; const Text: string; const Rect: TRect;
  Flags: DWORD);
var
  ti: TOOLINFO;
begin
  FillChar(ti, SizeOf(ti), 0);
  ti.cbSize := SizeOf(ti);
  ti.hwnd := Window;
  ti.uId := ID;
  ti.uFlags := Flags;
  ti.Rect := Rect;
  ti.hInst := HInstance;
  ti.lpszText := PChar(Text);
  SendMessage(Handle, TTM_ADDTOOL, 0, LPARAM(@ti));
end;

procedure TSdaToolTipControl.DeleteTool(ID: Integer);
var
  ti: TOOLINFO;
begin
  FillChar(ti, SizeOf(ti), 0);
  ti.cbSize := SizeOf(ti);
  ti.hwnd := Window;
  ti.uId := ID;
  SendMessage(Handle, TTM_DELTOOL, 0, LPARAM(@ti));
end;

procedure TSdaToolTipControl.DestroyHandle;
begin
  DestroyWindow(Handle);
end;

class function TSdaToolTipControl.CreateHandle(Style: DWORD): HWND;
begin
  Result := CreateWindowEx(WS_EX_TOPMOST or WS_EX_TOOLWINDOW, TOOLTIPS_CLASS,
    nil, WS_POPUP or Style, Integer(CW_USEDEFAULT), Integer(CW_USEDEFAULT),
    Integer(CW_USEDEFAULT), Integer(CW_USEDEFAULT), 0, 0, HInstance, nil);
  if Result = 0 then Exit;
  SetWindowPos(Result, HWND_TOPMOST, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE);
end;

procedure TSdaToolTipControl.GetTitleInfo(var Icon: HICON; var Text: string);
var
  tt: TTTGETTITLE;
  Buf: array[0..100] of Char; // The maximum size of title is 100 characters including terminating zero
begin
  FillChar(tt, SizeOf(tt), 0);
  tt.dwSize := SizeOf(tt);

  FillChar(Buf, SizeOf(Buf), 0);
  tt.cch := Length(Buf);
  tt.pszTitle := Buf;
  SendMessage(Handle, TTM_GETTITLE, 0, LPARAM(@tt));
  Icon := tt.uTitleBitmap;
  Text := tt.pszTitle;
end;

function TSdaToolTipControl.GetToolCount: Integer;
begin
  Result := SendMessage(Handle, TTM_GETTOOLCOUNT, 0, 0);
end;

function TSdaToolTipControl.GetToolID(Index: Integer): Integer;
var
  ti: TOOLINFO;
begin
  FillChar(ti, SizeOf(ti), 0);
  ti.cbSize := SizeOf(ti);
  SendMessage(Handle, TTM_ENUMTOOLS, Index, LPARAM(@ti));
  Result := ti.uId;
end;

procedure TSdaToolTipControl.Hide;
begin
  SendMessage(Handle, TTM_POP, 0, 0);
end;

class operator TSdaToolTipControl.Implicit(Value: HWND): TSdaToolTipControl;
begin
  Result.Handle := Value;
end;

class operator TSdaToolTipControl.Explicit(Value: TSdaToolTipControl): HWND;
begin
  Result := Value.Handle;
end;

procedure TSdaToolTipControl.RelayMouseEvent(const Message: TMessage);
var
  msg: TMsg;
  pos: DWORD;
begin
  msg.hwnd := Window;
  msg.message := Message.Msg;
  msg.wParam := Message.WParam;
  msg.lParam := Message.LParam;
  msg.time := GetMessageTime;
  pos := GetMessagePos;
  msg.pt := SmallPointToPoint(PSmallPoint(@pos)^);
  SendMessage(Handle, TTM_RELAYEVENT, 0, LPARAM(@msg));
end;

function TSdaToolTipControl.GetTitle: string;
var
  s: string;
  i: HICON;
begin
  GetTitleInfo(i, s);
  Result := s;
end;

function TSdaToolTipControl.GetBackColor: TColor;
begin
  Result := SendMessage(Handle, TTM_GETTIPBKCOLOR, 0, 0);
end;

function TSdaToolTipControl.GetCurrentTool: Integer;
var
  ti: TOOLINFO;
begin
  FillChar(ti, SizeOf(ti), 0);
  ti.cbSize := SizeOf(ti);
  SendMessage(Handle, TTM_GETCURRENTTOOL, 0, LPARAM(@ti));
  Result := ti.uId;
end;

procedure TSdaToolTipControl.SetBackColor(const Value: TColor);
begin
  SendMessage(Handle, TTM_SETTIPBKCOLOR, ColorToRGB(Value), 0);
end;

function TSdaToolTipControl.GetDelayTime(Time: TSdaToolTipDelayTime): Integer;
begin
  Result := SendMessage(Handle, TTM_GETDELAYTIME, WPARAM(Time), 0);
end;

procedure TSdaToolTipControl.SetDelayTime(Time: TSdaToolTipDelayTime;
  const Value: Integer);
begin
  if Value < 0 then SendMessage(Handle, TTM_SETDELAYTIME, WPARAM(Time), -1) else
  if Value > High(SmallInt) then SendMessage(Handle, TTM_SETDELAYTIME, WPARAM(Time), High(SmallInt)) else
    SendMessage(Handle, TTM_SETDELAYTIME, WPARAM(Time), Value);
end;

function TSdaToolTipControl.GetMargins: TRect;
begin
  FillChar(Result, SizeOf(Result), 0);
  SendMessage(Handle, TTM_GETMARGIN, 0, LPARAM(@Result));
end;

procedure TSdaToolTipControl.SetMargins(const Value: TRect);
begin
  SendMessage(Handle, TTM_SETMARGIN, 0, LPARAM(@Value));
end;

function TSdaToolTipControl.GetMaxWidth: Integer;
begin
  Result := SendMessage(Handle, TTM_GETMAXTIPWIDTH, 0, 0);
end;

procedure TSdaToolTipControl.SetMaxWidth(const Value: Integer);
begin
  if Value < 0 then SendMessage(Handle, TTM_SETMAXTIPWIDTH, 0, -1)
    else SendMessage(Handle, TTM_SETMAXTIPWIDTH, 0, Value);
end;

function TSdaToolTipControl.GetStyle: DWORD;
begin
  Result := GetWindowLongPtr(Handle, GWL_STYLE) and $0000ffff;
end;

procedure TSdaToolTipControl.SetStyle(const Value: DWORD);
var
  dw: DWORD;
begin
  dw := GetWindowLongPtr(Handle, GWL_STYLE) and $ffff0000;
  SetWindowLongPtr(Handle, GWL_STYLE, dw or (Value and $0000ffff));
  SetWindowPos(FHandle, 0, 0, 0, 0, 0, SWP_NOSIZE or SWP_NOMOVE or SWP_NOZORDER or
    SWP_FRAMECHANGED);
end;

function TSdaToolTipControl.GetTextColor: TColor;
begin
  Result := SendMessage(Handle, TTM_GETTIPTEXTCOLOR, 0, 0);
end;

procedure TSdaToolTipControl.SetTextColor(const Value: TColor);
begin
  SendMessage(Handle, TTM_SETTIPTEXTCOLOR, ColorToRGB(Value), 0);
end;

procedure TSdaToolTipControl.SetTheme(const VisualStyleName: string);
begin
  SendMessage(Handle, TTM_SETWINDOWTHEME, 0, LPARAM(PChar(VisualStyleName)));
end;

procedure TSdaToolTipControl.SetTitle(const Value: string);
var
  s: string;
  i: HICON;
begin
  GetTitleInfo(i, s);
  // Length of title must be 100 characters including terminating zero
  SendMessage(Handle, TTM_SETTITLE, i, LPARAM(PChar(Copy(Value, 1, 99))));
end;

function TSdaToolTipControl.GetTitleIcon: HICON;
var
  s: string;
  i: HICON;
begin
  GetTitleInfo(i, s);
  Result := i;
end;

procedure TSdaToolTipControl.SetTitleIcon(const Value: HICON);
var
  s: string;
  i: HICON;
begin
  GetTitleInfo(i, s);
  SendMessage(Handle, TTM_SETTITLE, WPARAM(Value), LPARAM(PChar(s)));
end;

function TSdaToolTipControl.GetTools(ID: Integer): TSdaToolTipToolInfo;
var
  ti: TOOLINFO;
  Buf: array [Word] of Char;
begin
  FillChar(ti, SizeOf(ti), 0);
  ti.cbSize := SizeOf(ti);
  ti.hwnd := Window;
  ti.uId := ID;
  FillChar(Buf, SizeOf(Buf), 0);
  ti.lpszText := Buf;
  SendMessage(Handle, TTM_GETTOOLINFO, 0, LPARAM(@ti));
  Result.Text := ti.lpszText;
  Result.Rect := ti.Rect;
  Result.Flags := ti.uFlags;
end;

procedure TSdaToolTipControl.SetTools(ID: Integer; const Value: TSdaToolTipToolInfo);
var
  ti: TOOLINFO;
begin
  FillChar(ti, SizeOf(ti), 0);
  ti.cbSize := SizeOf(ti);
  ti.hwnd := Window;
  ti.uId := ID;
  ti.Rect := Value.Rect;
  ti.hInst := HInstance;
  ti.lpszText := PChar(Value.Text);
  ti.uFlags := Value.Flags;
  SendMessage(Handle, TTM_SETTOOLINFO, 0, LPARAM(@ti));
end;

procedure TSdaToolTipControl.SetToolRect(ID: Integer; const Rect: TRect);
var
  ti: TOOLINFO;
begin
  FillChar(ti, SizeOf(ti), 0);
  ti.cbSize := SizeOf(ti);
  ti.hwnd := Window;
  ti.uId := ID;
  ti.Rect := Rect;
  SendMessage(Handle, TTM_NEWTOOLRECT, 0, LPARAM(@ti));
end;

procedure TSdaToolTipControl.SetToolText(ID: Integer; const Text: string);
var
  ti: TOOLINFO;
begin
  FillChar(ti, SizeOf(ti), 0);
  ti.cbSize := SizeOf(ti);
  ti.hwnd := Window;
  ti.uId := ID;
  ti.hInst := HInstance;
  ti.lpszText := PChar(Text);
  SendMessage(Handle, TTM_UPDATETIPTEXT, 0, LPARAM(@ti));
end;

procedure TSdaToolTipControl.ShowAtMouse;
begin
  SendMessage(Handle, TTM_POPUP, 0, 0);
end;

procedure TSdaToolTipControl.TrackActivate(ID: Integer; Activate: Boolean);
var
  ti: TOOLINFO;
begin
  FillChar(ti, SizeOf(ti), 0);
  ti.cbSize := SizeOf(ti);
  ti.hwnd := Window;
  ti.uId := ID;
  SendMessage(Handle, TTM_TRACKACTIVATE, WPARAM(BOOL(Activate)), LPARAM(@ti));
end;

procedure TSdaToolTipControl.TrackPosition(X, Y: Integer);
begin
  SendMessage(Handle, TTM_TRACKPOSITION, 0, MakeLParam(X, Y));
end;

procedure TSdaToolTipControl.TrackPosition(P: TPoint);
begin
  SendMessage(Handle, TTM_TRACKPOSITION, 0, MakeLParam(P.X, P.Y));
end;

procedure TSdaToolTipControl.Update;
begin
  SendMessage(Handle, TTM_UPDATE, 0, 0);
end;

procedure TSdaToolTipControl.Activate(ActivateTip: Boolean);
begin
  SendMessage(Handle, TTM_ACTIVATE, WPARAM(BOOL(ActivateTip)), 0);
end;

end.
