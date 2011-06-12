unit sdaWinControl;

{$INCLUDE 'sda.inc'}

interface

uses
  Windows, Messages, sdaWinUtil;

type
  TSdaWindowControl = class(TObject)
  private
    FHandle: HWND;
    function GetSDAObject: TObject;
    function GetWindowClass: string;
    function GetHandle: HWND; virtual;
    function GetCaption: string;
    function GetExStyle: DWORD;
    function GetStyle: DWORD;
    procedure SetHandle(const Value: HWND);
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
  public
    constructor Create(AWindow: HWND);

    property Handle: HWND read GetHandle write SetHandle;

    property SDAObject: TObject read GetSDAObject;

    property Style: DWORD read GetStyle write SetStyle;
    property ExStyle: DWORD read GetExStyle write SetExStyle;
    property Caption: string read GetCaption write SetCaption;
    property WindowClass: string read GetWindowClass;

    property Left: Integer read GetLeft write SetLeft;
    property Top: Integer read GetTop write SetTop;
    property Width: Integer read GetWidth write SetWidth;
    property Height: Integer read GetHeight write SetHeight;
    property ClientWidth: Integer read GetClientWidth write SetClientWidth;
    property ClientHeight: Integer read GetClientHeight write SetClientHeight;

    property BoundsRect: TRect read GetBoundsRect write SetBoundsRect;
    property ClientRect: TRect read GetClientRect write SetClientRect;

    procedure Show(CmdShow: Integer = SW_SHOW);
    procedure Hide;

    procedure SetBounds(const Left, Top, Width, Height: Integer);
  end;

implementation

{ TWindowsControl }

constructor TSdaWindowControl.Create(AWindow: HWND);
begin
  inherited Create;
  FHandle := AWindow;
end;

function TSdaWindowControl.GetSDAObject: TObject;
begin
  Result := nil;
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
  nLen: Integer;
begin
  nLen := GetWindowTextLength(FHandle);
  SetLength(Result, nLen);
  if Result <> '' then
  nLen := GetWindowText(FHandle, PChar(Result), Length(Result));
  SetLength(Result, nLen);
end;

function TSdaWindowControl.GetClientHeight: Integer;
var
  rc: TRect;
begin
  if Windows.GetClientRect(Handle, rc) then Result := rc.Bottom - rc.Top
    else Result := 0;
end;

function TSdaWindowControl.GetClientWidth: Integer;
var
  rc: TRect;
begin
  if Windows.GetClientRect(Handle, rc) then Result := rc.Right - rc.Left
    else Result := 0;
end;

function TSdaWindowControl.GetClientRect: TRect;
begin
  if not Windows.GetClientRect(Handle, Result) then
  begin
    Result.Left := 0; Result.Top := 0; Result.Right := 0; Result.Bottom := 0;
  end;
end;

function TSdaWindowControl.GetExStyle: DWORD;
begin
  Result := GetWindowLongPtr(FHandle, GWL_EXSTYLE);
end;

function TSdaWindowControl.GetHandle: HWND;
begin
  Result := FHandle;
end;

function TSdaWindowControl.GetLeft: Integer;
var
  rc: TRect;
begin
  if GetWindowRect(Handle, rc) then Result := rc.Left
    else Result := 0;
end;

function TSdaWindowControl.GetTop: Integer;
var
  rc: TRect;
begin
  if GetWindowRect(Handle, rc) then Result := rc.Top
    else Result := 0;
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

procedure TSdaWindowControl.SetBounds(const Left, Top, Width, Height: Integer);
begin
  SetWindowPos(Handle, 0, Left, Top, Width, Height, SWP_NOZORDER or SWP_NOACTIVATE);
end;

procedure TSdaWindowControl.SetCaption(const Value: string);
begin
  SetWindowText(FHandle, Value);
end;

procedure TSdaWindowControl.SetClientHeight(const Value: Integer);
var
  wnd, cli: TRect;
begin
  if GetWindowRect(Handle, wnd) and Windows.GetClientRect(Handle, cli) then
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
  if GetWindowRect(Handle, wnd) and Windows.GetClientRect(Handle, cli) then
  begin
    OffsetRect(cli, -cli.Left, -cli.Top);
    Dec(wnd.Right, wnd.Left + cli.Right); Inc(wnd.Right, Value);
    Dec(wnd.Bottom, wnd.Top);
    SetBounds(wnd.Left, wnd.Top, wnd.Right, wnd.Bottom);
  end;
end;

procedure TSdaWindowControl.SetClientRect(const Value: TRect);
var
  wnd, cli: TRect;
begin
  if GetWindowRect(Handle, wnd) and Windows.GetClientRect(Handle, cli) then
  begin
    OffsetRect(cli, -cli.Left, -cli.Top);
    Dec(wnd.Right, wnd.Left + cli.Right); Inc(wnd.Right, Value.Right - Value.Left);
    Dec(wnd.Bottom, wnd.Top + cli.Bottom); Inc(wnd.Bottom, Value.Bottom - Value.Top);
    SetBounds(wnd.Left, wnd.Top, wnd.Right, wnd.Bottom);
  end;
end;

procedure TSdaWindowControl.SetExStyle(const Value: DWORD);
begin
  SetWindowLongPtr(FHandle, GWL_EXSTYLE, Value);
end;

procedure TSdaWindowControl.SetHandle(const Value: HWND);
begin
  FHandle := Value;
end;

procedure TSdaWindowControl.SetStyle(const Value: DWORD);
begin
  SetWindowLongPtr(FHandle, GWL_STYLE, Value);
end;

procedure TSdaWindowControl.SetLeft(const Value: Integer);
begin
  SetWindowPos(Handle, 0, Value, Top, 0, 0, SWP_NOSIZE or SWP_NOZORDER or SWP_NOACTIVATE);
end;

procedure TSdaWindowControl.SetTop(const Value: Integer);
begin
  SetWindowPos(Handle, 0, Left, Value, 0, 0, SWP_NOSIZE or SWP_NOZORDER or SWP_NOACTIVATE);
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
