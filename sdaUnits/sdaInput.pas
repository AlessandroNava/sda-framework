unit sdaInput;

interface

{$INCLUDE 'sda.inc'}

uses
  sdaWindows, sdaSysUtils;

type
  TSdaMouse = record
  private
    function GetCapture: HWND;
    function GetCursorPos: TPoint;
    function GetMousePresent: Boolean;
    function GetScrollLines: Integer;
    function GetWheelPresent: Boolean;
    procedure SetCapture(const Value: HWND);
    procedure SetCursorPos(const Value: TPoint);
    function GetDoubleClickTime: Integer;
    procedure SetDoubleClickTime(const Value: Integer);
  public
    property MousePresent: Boolean read GetMousePresent;
    property WheelPresent: Boolean read GetWheelPresent;
    property WheelScrollLines: Integer read GetScrollLines;
    property CursorPos: TPoint read GetCursorPos write SetCursorPos;
    property Capture: HWND read GetCapture write SetCapture;
    property DoubleClickTime: Integer read GetDoubleClickTime
      write SetDoubleClickTime;

    procedure SwapButtons(Swap: Boolean);
    procedure TrackEvent(Window: HWND; Flags: DWORD; HoverTime: DWORD = HOVER_DEFAULT);
  end;

  TSdaKeyboard = record
  private
    function GetDefaultKbLayout: HKL;
  public
    property DefaultKbLayout: HKL read GetDefaultKbLayout;
  end;

var
  Mouse: TSdaMouse;
  Keyboard: TSdaKeyboard;

function InputKeyDown(VKey: Byte): TInput; overload;
function InputKeyDown(Scan: WideChar): TInput; overload;
function InputKeyUp(VKey: Byte): TInput; overload;
function InputKeyUp(Scan: WideChar): TInput; overload;

function SdaSendInput(Inputs: array of TInput): Integer;

implementation

function InputKeyDown(VKey: Byte): TInput;
begin
  FillChar(Result, SizeOf(Result), 0);
  Result.Itype := INPUT_KEYBOARD;
  Result.ki.wVk := VKey;
  Result.ki.dwFlags := 0;
end;

function InputKeyDown(Scan: WideChar): TInput;
begin
  FillChar(Result, SizeOf(Result), 0);
  Result.Itype := INPUT_KEYBOARD;
  Result.ki.wScan := Word(Scan);
  Result.ki.dwFlags := KEYEVENTF_SCANCODE or KEYEVENTF_UNICODE;
end;

function InputKeyUp(VKey: Byte): TInput;
begin
  FillChar(Result, SizeOf(Result), 0);
  Result.Itype := INPUT_KEYBOARD;
  Result.ki.wVk := VKey;
  Result.ki.dwFlags := KEYEVENTF_KEYUP;
end;

function InputKeyUp(Scan: WideChar): TInput;
begin
  FillChar(Result, SizeOf(Result), 0);
  Result.Itype := INPUT_KEYBOARD;
  Result.ki.wScan := Word(Scan);
  Result.ki.dwFlags := KEYEVENTF_SCANCODE or KEYEVENTF_UNICODE or KEYEVENTF_KEYUP;
end;

function SdaSendInput(Inputs: array of TInput): Integer;
begin
  if Length(Inputs) <= 0 then Exit(0);
  Result := SendInput(Length(Inputs), Inputs[0], SizeOf(TInput));
end;

{ TMouse }

function TSdaMouse.GetCapture: HWND;
begin
  Result := sdaWindows.GetCapture;
end;

procedure TSdaMouse.SetCapture(const Value: HWND);
begin
  if Capture <> Value then
  begin
    if Value = 0 then ReleaseCapture
      else sdaWindows.SetCapture(Value);
  end;
end;

function TSdaMouse.GetCursorPos: TPoint;
begin
  if not sdaWindows.GetCursorPos(Result) then
    Result := Point(0, 0);
end;

function TSdaMouse.GetDoubleClickTime: Integer;
begin
  Result := sdaWindows.GetDoubleClickTime;
end;

procedure TSdaMouse.SetCursorPos(const Value: TPoint);
begin
  sdaWindows.SetCursorPos(Value.X, Value.Y);
end;

procedure TSdaMouse.SetDoubleClickTime(const Value: Integer);
begin
  sdaWindows.SetDoubleClickTime(Value);
end;

procedure TSdaMouse.SwapButtons(Swap: Boolean);
begin
  SwapMouseButton(Swap);
end;

procedure TSdaMouse.TrackEvent(Window: HWND; Flags, HoverTime: DWORD);
var
  tme: TTrackMouseEvent;
begin
  FillChar(tme, SizeOf(tme), 0);
  tme.cbSize := SizeOf(tme);
  tme.dwFlags := Flags;
  tme.hwndTrack := Window;
  tme.dwHoverTime := HoverTime;
  TrackMouseEvent(tme);
end;

function TSdaMouse.GetMousePresent: Boolean;
begin
  Result := BOOL(GetSystemMetrics(SM_MOUSEPRESENT));
end;

function TSdaMouse.GetScrollLines: Integer;
begin
  if WheelPresent then SystemParametersInfo(SPI_GETWHEELSCROLLLINES, 0, Result, 0)
    else Result := 0;
end;

function TSdaMouse.GetWheelPresent: Boolean;
begin
  Result := BOOL(GetSystemMetrics(SM_MOUSEWHEELPRESENT));
end;

{ TSdaKeyboard }

function TSdaKeyboard.GetDefaultKbLayout: HKL;
begin
  Result := GetKeyboardLayout(0);
end;

end.
