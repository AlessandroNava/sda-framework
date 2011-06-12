unit sdaTestControl;

interface

{$INCLUDE 'sda.inc'}

uses
  Messages;

const
  WC_TESTCONTROL = 'Sda.Test';

  TCM_ADDPANEL = WM_USER + 1;

implementation

uses
  sdaSysUtils, sdaWindows, sdaApplication, sdaWinCreate, sdaWinControl,
  sdaHelpers, sdaGraphics;

type
  TTestCtl = packed record
    Cnt: Integer;

    function AddPanel: Integer;
    procedure DrawPanels(wnd: HWND; const msg: TWMPaint);
  end;
  PTestCtl = ^TTestCtl;

{ TTestCtl }

function TTestCtl.AddPanel: Integer;
begin
  if Cnt > 9 then Exit(-1);
  Inc(Cnt);
  Result := Cnt - 1;
end;

function TestWndProc(Window: HWND; var Message: TMessage): BOOL; stdcall;
var
  p: PTestCtl;
begin
  case Message.Msg of
    WM_CREATE: begin
      SendMessage(Window, TCM_ADDPANEL, 0, 0);
      SendMessage(Window, TCM_ADDPANEL, 0, 0);
      Result := false;
    end;
    WM_PAINT: begin
      p := SdaGetInstancePointer(Window);
      p.DrawPanels(Window, TWMPaint(Message));
      Result := true;
    end;
    TCM_ADDPANEL: begin
      p := SdaGetInstancePointer(Window);
      Message.Result := p.AddPanel;
      Result := true;
    end;
    else Result := false;
  end;
end;

procedure RegisterControl;
var
  wcx: TWndClassEx;
begin
  SdaInitWindowClass(wcx);
  wcx.lpszClassName := WC_TESTCONTROL;
  wcx.style := CS_PARENTDC or CS_GLOBALCLASS;
  wcx.cbClsExtra := SizeOf(TTestCtl);
  wcx.lpfnWndProc := @TestWndProc;
  SdaRegisterWindowClass(wcx);
end;

procedure TTestCtl.DrawPanels(wnd: HWND; const msg: TWMPaint);
var
  ps: TSdaWindowPaintHelper;
  wc: TSdaWindowControl;
  c: TSdaCanvas;
  i: Integer;
  rc: TRect;
begin
  wc := wnd;
  ps.BeginPaint(wnd, msg);
  c := ps.DC;
  c.Brush := GetStockObject(DC_BRUSH); c.BrushColor := clActiveCaption;
  c.FillRect(wc.ClientRect);
  c.Pen := GetStockObject(DC_PEN); c.PenColor := clRed;
  c.Brush := GetStockObject(DC_BRUSH); c.BrushColor := clYellow;
  rc := wc.ClientRect;
  for i := 0 to Cnt - 1 do
  begin
    c.Rectangle(Rect(rc.Left, rc.Top, rc.Right, rc.Top + 20));
    Inc(rc.Top, 21);
  end;
  ps.EndPaint;
end;

initialization
  RegisterControl;
end.
