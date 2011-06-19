unit sdaScreen;

interface

{$INCLUDE 'sda.inc'}

uses
  sdaWindows, sdaSysUtils;

type
  TSdaScreen = {$IFDEF FPC}object{$ELSE}record{$ENDIF}
  private
    function GetHeight: Integer;
    function GetWidth: Integer;
    function GetDesktopHeight: Integer;
    function GetDesktopLeft: Integer;
    function GetDesktopRect: TRect;
    function GetDesktopTop: Integer;
    function GetDesktopWidth: Integer;
    function GetWorkAreaHeight: Integer;
    function GetWorkAreaLeft: Integer;
    function GetWorkAreaRect: TRect;
    function GetWorkAreaTop: Integer;
    function GetWorkAreaWidth: Integer;
    function GetActiveWindow: HWND;
    procedure SetActiveWindow(const Value: HWND);
    function GetForegroundWindow: HWND;
    procedure SetForegroundWindow(const Value: HWND);
    function GetPixelsPerInch: Integer;
  public
    property Width: Integer read GetWidth;
    property Height: Integer read GetHeight;

    property DesktopRect: TRect read GetDesktopRect;
    property DesktopHeight: Integer read GetDesktopHeight;
    property DesktopLeft: Integer read GetDesktopLeft;
    property DesktopTop: Integer read GetDesktopTop;
    property DesktopWidth: Integer read GetDesktopWidth;

    property WorkAreaRect: TRect read GetWorkAreaRect;
    property WorkAreaHeight: Integer read GetWorkAreaHeight;
    property WorkAreaLeft: Integer read GetWorkAreaLeft;
    property WorkAreaTop: Integer read GetWorkAreaTop;
    property WorkAreaWidth: Integer read GetWorkAreaWidth;

    property ActiveWindow: HWND read GetActiveWindow write SetActiveWindow;
    property ForegroundWindow: HWND read GetForegroundWindow write SetForegroundWindow;

    property PixelsPerInch: Integer read GetPixelsPerInch;
  end;

var
  Screen: TSdaScreen;

implementation

{ TScreen }

function TSdaScreen.GetWidth: Integer;
begin
  Result := GetSystemMetrics(SM_CXSCREEN);
end;

function TSdaScreen.GetHeight: Integer;
begin
  Result := GetSystemMetrics(SM_CYSCREEN);
end;

function TSdaScreen.GetPixelsPerInch: Integer;
var
  DC: HDC;
begin
  DC := GetDC(0);
  Result := GetDeviceCaps(DC, LOGPIXELSY);
  ReleaseDC(0, DC);
end;

function TSdaScreen.GetDesktopLeft: Integer;
begin
  Result := GetSystemMetrics(SM_XVIRTUALSCREEN);
end;

function TSdaScreen.GetDesktopTop: Integer;
begin
 Result := GetSystemMetrics(SM_YVIRTUALSCREEN);
end;

function TSdaScreen.GetDesktopWidth: Integer;
begin
  Result := GetSystemMetrics(SM_CXVIRTUALSCREEN);
end;

function TSdaScreen.GetDesktopHeight: Integer;
begin
  Result := GetSystemMetrics(SM_CYVIRTUALSCREEN);
end;

function TSdaScreen.GetDesktopRect: TRect;
begin
  Result := Bounds(DesktopLeft, DesktopTop, DesktopWidth, DesktopHeight);
end;

function TSdaScreen.GetWorkAreaLeft: Integer;
begin
  Result := WorkAreaRect.Left;
end;

function TSdaScreen.GetWorkAreaTop: Integer;
begin
  Result := WorkAreaRect.Top;
end;

function TSdaScreen.GetWorkAreaWidth: Integer;
begin
  with WorkAreaRect do
    Result := Right - Left;
end;

function TSdaScreen.GetWorkAreaHeight: Integer;
begin
  with WorkAreaRect do
    Result := Bottom - Top;
end;

function TSdaScreen.GetWorkAreaRect: TRect;
begin
  SystemParametersInfo(SPI_GETWORKAREA, 0, Result, 0);
end;

function TSdaScreen.GetActiveWindow: HWND;
begin
  Result := sdaWindows.GetActiveWindow;
end;

procedure TSdaScreen.SetActiveWindow(const Value: HWND);
begin
  sdaWindows.SetActiveWindow(Value);
end;

function TSdaScreen.GetForegroundWindow: HWND;
begin
  Result := sdaWindows.GetForegroundWindow;
end;

procedure TSdaScreen.SetForegroundWindow(const Value: HWND);
begin
  sdaWindows.SetForegroundWindow(Value);
end;

end.
