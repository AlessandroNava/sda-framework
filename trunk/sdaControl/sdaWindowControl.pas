unit sdaWindowControl;

interface

{$INCLUDE 'sda.inc'}

uses
  sdaWindows, Messages;

type
  TSdaWindowControl = record
  private
    FHandle: HWND;
    function GetWindowClass: string;
    function GetCaption: string;
    function GetExStyle: DWORD;
    function GetStyle: DWORD;
    procedure SetCaption(const Value: string);
    procedure SetExStyle(const Value: DWORD);
    procedure SetStyle(const Value: DWORD);
    function GetBoundsRect: TRect;
    function GetClientHeight: Integer;
    function GetClientRect: TRect;
    function GetClientWidth: Integer;
    function GetHeight: Integer;
    function GetLeft: Integer;
    function GetTop: Integer;
    function GetWidth: Integer;
    procedure SetBoundsRect(const Value: TRect);
    procedure SetClientHeight(const Value: Integer);
    procedure SetClientRect(const Value: TRect);
    procedure SetClientWidth(const Value: Integer);
    procedure SetHeight(const Value: Integer);
    procedure SetLeft(const Value: Integer);
    procedure SetTop(const Value: Integer);
    procedure SetWidth(const Value: Integer);
    function GetEnabled: Boolean;
    function GetVisible: Boolean;
    procedure SetEnabled(const Value: Boolean);
    procedure SetVisible(const Value: Boolean);
    function GetParent: HWND;
    procedure SetParent(const Value: HWND);
  public
    property Handle: HWND read FHandle write FHandle;
    class operator Explicit(Value: TSdaWindowControl): HWND;
    class operator Implicit(Value: HWND): TSdaWindowControl;

    property Style: DWORD read GetStyle write SetStyle;
    property ExStyle: DWORD read GetExStyle write SetExStyle;
    property Caption: string read GetCaption write SetCaption;
    property WindowClass: string read GetWindowClass;
    property Parent: HWND read GetParent write SetParent;

    property Left: Integer read GetLeft write SetLeft;
    property Top: Integer read GetTop write SetTop;
    property Width: Integer read GetWidth write SetWidth;
    property Height: Integer read GetHeight write SetHeight;
    property ClientWidth: Integer read GetClientWidth write SetClientWidth;
    property ClientHeight: Integer read GetClientHeight write SetClientHeight;

    property BoundsRect: TRect read GetBoundsRect write SetBoundsRect;
    property ClientRect: TRect read GetClientRect write SetClientRect;

    property Visible: Boolean read GetVisible write SetVisible;
    property Enabled: Boolean read GetEnabled write SetEnabled;

    procedure Show(CmdShow: Integer = SW_SHOW);
    procedure Hide;
    procedure Close;
    procedure Minimize;
    procedure Maximize;
    procedure Restore;

    procedure SetBounds(const Left, Top, Width, Height: Integer);
    procedure SetClient(const Width, Height: Integer);

    // Flashes window specified count of times
    procedure Flash(FlashCount: Integer; FlashButton: Boolean = true;
      FlashCaption: Boolean = true; Timeout: Integer = 0); overload;
    // Flashes window until flashing will be directly stopped
    procedure Flash(StartFlashing: Boolean; FlashButton: Boolean = true;
      FlashCaption: Boolean = true; Timeout: Integer = 0); overload;
    // Flashes window until it will be activated
    procedure Flash(FlashButton: Boolean = true;
      FlashCaption: Boolean = true; Timeout: Integer = 0); overload;
  end;

implementation

{ TWindowsControl }

procedure TSdaWindowControl.Close;
var
  pt: TPoint;
begin
  GetCursorPos(pt);
  SendMessage(Handle, WM_SYSCOMMAND, SC_CLOSE, MakeLParam(pt.X, pt.Y));
end;

function TSdaWindowControl.GetBoundsRect: TRect;
begin
  if not GetWindowRect(Handle, Result) then
  begin
    Result.Left := 0; Result.Top := 0; Result.Right := 0; Result.Bottom := 0;
  end;
end;

function TSdaWindowControl.GetCaption: string;
var
  cbText: Integer;
begin
  if IsWindow(Handle) then
  begin
    cbText := SendMessage(Handle, WM_GETTEXTLENGTH, 0, 0);
    if cbText > 0 then
    begin
      SetLength(Result, cbText + 1);
      FillChar(Result[1], Length(Result) * SizeOf(char), 0);
      cbText := SendMessage(Handle, WM_GETTEXT, Length(Result), LPARAM(PChar(Result)));
      if cbText >= 0 then SetLength(Result, cbText);
    end else Result := '';
  end else Result := '';
end;

function TSdaWindowControl.GetClientHeight: Integer;
var
  rc: TRect;
begin
  if sdaWindows.GetClientRect(Handle, rc) then Result := rc.Bottom - rc.Top
    else Result := 0;
end;

function TSdaWindowControl.GetClientWidth: Integer;
var
  rc: TRect;
begin
  if sdaWindows.GetClientRect(Handle, rc) then Result := rc.Right - rc.Left
    else Result := 0;
end;

function TSdaWindowControl.GetClientRect: TRect;
begin
  if not sdaWindows.GetClientRect(Handle, Result) then
  begin
    Result.Left := 0; Result.Top := 0; Result.Right := 0; Result.Bottom := 0;
  end;
end;

function TSdaWindowControl.GetEnabled: Boolean;
begin
  Result := IsWindowEnabled(Handle);
end;

function TSdaWindowControl.GetExStyle: DWORD;
begin
  Result := GetWindowLongPtr(FHandle, GWL_EXSTYLE);
end;

function TSdaWindowControl.GetLeft: Integer;
var
  rc: TRect;
begin
  if GetWindowRect(Handle, rc) then Result := rc.Left
    else Result := 0;
end;

function TSdaWindowControl.GetParent: HWND;
begin
  Result := sdaWindows.GetParent(Handle);
end;

function TSdaWindowControl.GetTop: Integer;
var
  rc: TRect;
begin
  if GetWindowRect(Handle, rc) then Result := rc.Top
    else Result := 0;
end;

function TSdaWindowControl.GetVisible: Boolean;
begin
  Result := IsWindowVisible(Handle);
end;

function TSdaWindowControl.GetHeight: Integer;
var
  rc: TRect;
begin
  if GetWindowRect(Handle, rc) then Result := rc.Bottom - rc.Top
    else Result := 0;
end;

function TSdaWindowControl.GetWidth: Integer;
var
  rc: TRect;
begin
  if GetWindowRect(Handle, rc) then Result := rc.Right - rc.Left
    else Result := 0;
end;

function TSdaWindowControl.GetStyle: DWORD;
begin
  Result := GetWindowLongPtr(FHandle, GWL_STYLE);
end;

function TSdaWindowControl.GetWindowClass: string;
var
  Buf: array [0..512] of Char;
begin
  if Handle = 0 then Exit('');
  FillChar(Buf, SizeOf(Buf), 0);
  GetClassName(Handle, Buf, Length(Buf));
  Result := Buf;
end;

procedure TSdaWindowControl.Hide;
begin
  ShowWindow(Handle, SW_HIDE);
end;

class operator TSdaWindowControl.Explicit(Value: TSdaWindowControl): HWND;
begin
  Result := Value.Handle;
end;

procedure TSdaWindowControl.Flash(FlashCount: Integer; FlashButton,
  FlashCaption: Boolean; Timeout: Integer);
var
  fi: FLASHWINFO;
begin
  FillChar(fi, SizeOf(fi), 0);
  fi.cbSize := SizeOf(fi);
  fi.hwnd := Handle;
  fi.dwTimeout := Timeout;
  fi.dwFlags := FLASHW_TIMER;
  fi.uCount := FlashCount;
  if FlashButton then fi.dwFlags := fi.dwFlags or FLASHW_TRAY;
  if FlashCaption then fi.dwFlags := fi.dwFlags or FLASHW_CAPTION;
  FlashWindowEx(fi);
end;

procedure TSdaWindowControl.Flash(StartFlashing, FlashButton,
  FlashCaption: Boolean; Timeout: Integer);
var
  fi: FLASHWINFO;
begin
  FillChar(fi, SizeOf(fi), 0);
  fi.cbSize := SizeOf(fi);
  fi.hwnd := Handle;
  fi.dwTimeout := Timeout;
  if StartFlashing then fi.dwFlags := FLASHW_TIMER
    else fi.dwFlags := FLASHW_STOP;
  if FlashButton then fi.dwFlags := fi.dwFlags or FLASHW_TRAY;
  if FlashCaption then fi.dwFlags := fi.dwFlags or FLASHW_CAPTION;
  FlashWindowEx(fi);
end;

procedure TSdaWindowControl.Flash(FlashButton, FlashCaption: Boolean;
  Timeout: Integer);
var
  fi: FLASHWINFO;
begin
  FillChar(fi, SizeOf(fi), 0);
  fi.cbSize := SizeOf(fi);
  fi.hwnd := Handle;
  fi.dwTimeout := Timeout;
  fi.dwFlags := FLASHW_TIMERNOFG;
  if FlashButton then fi.dwFlags := fi.dwFlags or FLASHW_TRAY;
  if FlashCaption then fi.dwFlags := fi.dwFlags or FLASHW_CAPTION;
  FlashWindowEx(fi);
end;

class operator TSdaWindowControl.Implicit(Value: HWND): TSdaWindowControl;
begin
  Result.Handle := Value;
end;

procedure TSdaWindowControl.Maximize;
begin
  ShowWindow(Handle, SW_MAXIMIZE);
end;

procedure TSdaWindowControl.Minimize;
begin
  ShowWindow(Handle, SW_MINIMIZE);
end;

procedure TSdaWindowControl.Restore;
begin
  ShowWindow(Handle, SW_RESTORE);
end;

procedure TSdaWindowControl.SetBounds(const Left, Top, Width, Height: Integer);
begin
  SetWindowPos(Handle, 0, Left, Top, Width, Height, SWP_NOZORDER or SWP_NOACTIVATE);
end;

procedure TSdaWindowControl.SetCaption(const Value: string);
begin
  SendMessage(Handle, WM_SETTEXT, 0, LPARAM(PChar(Value)));
end;

procedure TSdaWindowControl.SetClient(const Width, Height: Integer);
var
  wnd, cli: TRect;
begin
  if GetWindowRect(Handle, wnd) and sdaWindows.GetClientRect(Handle, cli) then
  begin
    OffsetRect(cli, -cli.Left, -cli.Top);
    Dec(wnd.Right, wnd.Left + cli.Right); Inc(wnd.Right, Width);
    Dec(wnd.Bottom, wnd.Top + cli.Bottom); Inc(wnd.Bottom, Height);
    SetBounds(wnd.Left, wnd.Top, wnd.Right, wnd.Bottom);
  end;
end;

procedure TSdaWindowControl.SetClientHeight(const Value: Integer);
var
  wnd, cli: TRect;
begin
  if GetWindowRect(Handle, wnd) and sdaWindows.GetClientRect(Handle, cli) then
  begin
    OffsetRect(cli, -cli.Left, -cli.Top);
    Dec(wnd.Right, wnd.Left);
    Dec(wnd.Bottom, wnd.Top + cli.Bottom); Inc(wnd.Bottom, Value);
    SetBounds(wnd.Left, wnd.Top, wnd.Right, wnd.Bottom);
  end;
end;

procedure TSdaWindowControl.SetClientWidth(const Value: Integer);
var
  wnd, cli: TRect;
begin
  if GetWindowRect(Handle, wnd) and sdaWindows.GetClientRect(Handle, cli) then
  begin
    OffsetRect(cli, -cli.Left, -cli.Top);
    Dec(wnd.Right, wnd.Left + cli.Right); Inc(wnd.Right, Value);
    Dec(wnd.Bottom, wnd.Top);
    SetBounds(wnd.Left, wnd.Top, wnd.Right, wnd.Bottom);
  end;
end;

procedure TSdaWindowControl.SetClientRect(const Value: TRect);
begin
  SetClient(Value.Right - Value.Left, Value.Bottom - Value.Top);
end;

procedure TSdaWindowControl.SetEnabled(const Value: Boolean);
begin
  EnableWindow(Handle, Value);
end;

procedure TSdaWindowControl.SetExStyle(const Value: DWORD);
begin
  SetWindowLongPtr(FHandle, GWL_EXSTYLE, Value);
  SetWindowPos(Handle, 0, 0, 0, 0, 0, SWP_FRAMECHANGED or SWP_NOSIZE or
    SWP_NOMOVE or SWP_NOZORDER);
end;

procedure TSdaWindowControl.SetStyle(const Value: DWORD);
begin
  SetWindowLongPtr(FHandle, GWL_STYLE, Value);
  SetWindowPos(Handle, 0, 0, 0, 0, 0, SWP_FRAMECHANGED or SWP_NOSIZE or
    SWP_NOMOVE or SWP_NOZORDER);
end;

procedure TSdaWindowControl.SetLeft(const Value: Integer);
begin
  SetWindowPos(Handle, 0, Value, Top, 0, 0, SWP_NOSIZE or SWP_NOZORDER or SWP_NOACTIVATE);
end;

procedure TSdaWindowControl.SetParent(const Value: HWND);
begin
  sdaWindows.SetParent(Handle, Value);
end;

procedure TSdaWindowControl.SetTop(const Value: Integer);
begin
  SetWindowPos(Handle, 0, Left, Value, 0, 0, SWP_NOSIZE or SWP_NOZORDER or SWP_NOACTIVATE);
end;

procedure TSdaWindowControl.SetVisible(const Value: Boolean);
begin
  if Value then Show else Hide;
end;

procedure TSdaWindowControl.SetHeight(const Value: Integer);
begin
  SetWindowPos(Handle, 0, 0, 0, Width, Value, SWP_NOMOVE or SWP_NOZORDER or SWP_NOACTIVATE);
end;

procedure TSdaWindowControl.SetWidth(const Value: Integer);
begin
  SetWindowPos(Handle, 0, 0, 0, Value, Height, SWP_NOMOVE or SWP_NOZORDER or SWP_NOACTIVATE);
end;

procedure TSdaWindowControl.SetBoundsRect(const Value: TRect);
begin
  SetWindowPos(Handle, 0, Value.Left, Value.Top, Value.Right - Value.Left,
    Value.Bottom - Value.Top, SWP_NOZORDER or SWP_NOACTIVATE);
end;

procedure TSdaWindowControl.Show(CmdShow: Integer);
begin
  ShowWindow(Handle, CmdShow);
end;

end.
