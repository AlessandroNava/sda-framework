unit sdaProgressBarControl;

interface

{$INCLUDE 'sda.inc'}

uses
  sdaWindows, sdaMessages, sdaGraphics;

const
  PROGRESS_CLASS = 'msctls_progress32';

type
  PBRANGE = record
    iLow: Integer;
    iHigh: Integer;
  end;
  PPBRange = ^TPBRange;
  TPBRange = PBRANGE;

const
  PBS_SMOOTH              = 01;
  PBS_VERTICAL            = 04;
  { For Windows >= XP }
  PBS_MARQUEE             = $08;
  { For Windows >= Vista }
  PBS_SMOOTHREVERSE       = $10;

  PBM_SETRANGE            = WM_USER + 1;
  PBM_SETPOS              = WM_USER + 2;
  PBM_DELTAPOS            = WM_USER + 3;
  PBM_SETSTEP             = WM_USER + 4;
  PBM_STEPIT              = WM_USER + 5;
  PBM_SETRANGE32          = WM_USER + 6;
  PBM_GETRANGE            = WM_USER + 7;
  PBM_GETPOS              = WM_USER + 8;
  PBM_SETBARCOLOR         = WM_USER + 9;
  PBM_SETBKCOLOR          = CCM_SETBKCOLOR;
  PBM_SETMARQUEE          = WM_USER + 10;
  PBM_GETSTEP             = WM_USER + 13;
  PBM_GETBKCOLOR          = WM_USER + 14;
  PBM_GETBARCOLOR         = WM_USER + 15;
  PBM_SETSTATE            = WM_USER + 16;
  PBM_GETSTATE            = WM_USER + 17;

  { For Windows >= Vista }
  PBST_NORMAL             = $0001;
  PBST_ERROR              = $0002;
  PBST_PAUSED             = $0003;

type
  TSdaProgressBarControl = record
  private
    FHandle: HWND;
    function GetMax: Integer; inline;
    function GetMin: Integer; inline;
    function GetPosition: Integer; inline;
    procedure SetMax(const Value: Integer); inline;
    procedure SetMin(const Value: Integer); inline;
    procedure SetPosition(const Value: Integer); inline;
    function GetBackColor: TColor; inline;
    function GetBarColor: TColor; inline;
    procedure SetBackColor(const Value: TColor); inline;
    procedure SetBarColor(const Value: TColor); inline;
    function GetStep: Integer; inline;
    procedure SetStep(const Value: Integer); inline;
    function GetStyle: DWORD; inline;
    procedure SetStyle(const Value: DWORD);
  public
    property Handle: HWND read FHandle write FHandle;
    class function CreateHandle(Left, Top, Width, Height: Integer;
      Parent: HWND = 0; Style: DWORD = WS_CHILD or WS_VISIBLE;
      ExStyle: DWORD = 0): HWND; inline; static;
    procedure DestroyHandle; inline;

    class operator Implicit(Value: HWND): TSdaProgressBarControl; inline;

    property Min: Integer read GetMin write SetMin;
    property Max: Integer read GetMax write SetMax;
    property Position: Integer read GetPosition write SetPosition;
    property Step: Integer read GetStep write SetStep;

    property Style: DWORD read GetStyle write SetStyle;

    property BarColor: TColor read GetBarColor write SetBarColor;
    property BackColor: TColor read GetBackColor write SetBackColor;

    procedure Increment; overload; inline;
    procedure Increment(const Value: Integer); overload; inline;

    procedure EnableMarquee(const Interval: Integer = 0); inline;
    procedure DisableMarquee; inline;
  end;

implementation

{ TSdaProgressBarControl }

class function TSdaProgressBarControl.CreateHandle(Left, Top, Width, Height: Integer;
  Parent: HWND; Style: DWORD; ExStyle: DWORD): HWND;
begin
  Result := CreateWindowEx(ExStyle, PROGRESS_CLASS, nil, Style, Left, Top,
    Width, Height, Parent, 0, HInstance, nil);
end;

procedure TSdaProgressBarControl.DestroyHandle;
begin
  if DestroyWindow(Handle) then
    FHandle := 0;
end;

procedure TSdaProgressBarControl.DisableMarquee;
begin
  SendMessage(Handle, PBM_SETMARQUEE, 0, 0);
end;

procedure TSdaProgressBarControl.EnableMarquee(const Interval: Integer);
begin
  SendMessage(Handle, PBM_SETMARQUEE, -1, Interval);
end;

function TSdaProgressBarControl.GetBackColor: TColor;
begin
  Result := SendMessage(Handle, PBM_GETBKCOLOR, 0, 0);
end;

function TSdaProgressBarControl.GetBarColor: TColor;
begin
  Result := SendMessage(Handle, PBM_GETBARCOLOR, 0, 0);
end;

function TSdaProgressBarControl.GetMax: Integer;
begin
  Result := SendMessage(Handle, PBM_GETRANGE, WPARAM(BOOL(false)), LPARAM(nil));
end;

function TSdaProgressBarControl.GetMin: Integer;
begin
  Result := SendMessage(Handle, PBM_GETRANGE, WPARAM(BOOL(true)), LPARAM(nil));
end;

function TSdaProgressBarControl.GetPosition: Integer;
begin
  Result := SendMessage(Handle, PBM_GETPOS, 0, 0);
end;

function TSdaProgressBarControl.GetStep: Integer;
begin
  Result := SendMessage(Handle, PBM_GETSTEP, 0, 0);
end;

function TSdaProgressBarControl.GetStyle: DWORD;
begin
  Result := GetWindowLongPtr(Handle, GWL_STYLE) and $0000ffff;
end;

procedure TSdaProgressBarControl.Increment;
begin
  SendMessage(Handle, PBM_STEPIT, 0, 0);
end;

class operator TSdaProgressBarControl.Implicit(Value: HWND): TSdaProgressBarControl;
begin
  Result.Handle := Value;
end;

procedure TSdaProgressBarControl.Increment(const Value: Integer);
begin
  SendMessage(Handle, PBM_DELTAPOS, Value, 0);
end;

procedure TSdaProgressBarControl.SetBackColor(const Value: TColor);
begin
  SendMessage(Handle, PBM_SETBKCOLOR, 0, ColorToRGB(Value));
end;

procedure TSdaProgressBarControl.SetBarColor(const Value: TColor);
begin
  SendMessage(Handle, PBM_SETBARCOLOR, 0, ColorToRGB(Value));
end;

procedure TSdaProgressBarControl.SetMax(const Value: Integer);
var
  m: Integer;
begin
  m := SendMessage(Handle, PBM_GETRANGE, WPARAM(BOOL(true)), LPARAM(nil));
  SendMessage(Handle, PBM_SETRANGE32, m, Value);
end;

procedure TSdaProgressBarControl.SetMin(const Value: Integer);
var
  m: Integer;
begin
  m := SendMessage(Handle, PBM_GETRANGE, WPARAM(BOOL(false)), LPARAM(nil));
  SendMessage(Handle, PBM_SETRANGE32, Value, m);
end;

procedure TSdaProgressBarControl.SetPosition(const Value: Integer);
begin
  SendMessage(Handle, PBM_SETPOS, Value, 0);
end;

procedure TSdaProgressBarControl.SetStep(const Value: Integer);
begin
  SendMessage(Handle, PBM_SETSTEP, Value, 0);
end;

procedure TSdaProgressBarControl.SetStyle(const Value: DWORD);
var
  dw: DWORD;
begin
  dw := GetWindowLongPtr(Handle, GWL_STYLE) and $ffff0000;
  SetWindowLong(Handle, GWL_STYLE, dw or (Value and $0000ffff));
  SetWindowPos(Handle, 0, 0, 0, 0, 0, SWP_NOSIZE or SWP_NOMOVE or SWP_NOZORDER or
    SWP_FRAMECHANGED);
end;

end.
