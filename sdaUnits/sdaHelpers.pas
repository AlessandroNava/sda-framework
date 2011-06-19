unit sdaHelpers;

interface

{$INCLUDE 'sda.inc'}

uses
  sdaWindows, sdaMessages;

type
  TSdaWindowPaintHelper = {$IFDEF FPC}object{$ELSE}record{$ENDIF}
  private
    FPaintStruct: PAINTSTRUCT;
    FMsgDC: Boolean;
    FWindow: HWND;
  public
    procedure BeginPaint(Window: HWND; const Message: TWMPaint); overload;
    procedure BeginPaint(Window: HWND; const Message: TWMEraseBkgnd); overload;
    procedure EndPaint;

    property Window: HWND read FWindow;
    property DC: HDC read FPaintStruct.hdc;
  end;

  TSdaTimer = {$IFDEF FPC}object{$ELSE}record{$ENDIF}
  private
    FWindow: HWND;
    FID: Integer;
    procedure SetID(const Value: Integer);
    procedure SetWindow(const Value: HWND);
  public
    property Window: HWND read FWindow write SetWindow;
    property ID: Integer read FID write SetID;
    procedure Enable(AnInterval: Integer);
    procedure Disable;
  end;

  TScrollBarPlacing = (sbpControl = SB_CTL, sbpHorizontal = SB_HORZ,
    sbpVertical = SB_VERT);

  TSdaScrollBarHelper = {$IFDEF FPC}object{$ELSE}record{$ENDIF}
  private
    FWindow: HWND;
    FPlacing: TScrollBarPlacing;
    FPageIncrement: Integer;
    FIncrement: Integer;
    function GetMax: Integer;
    function GetMin: Integer;
    function GetPageSize: Integer;
    function GetPosition: Integer;
    function GetVisible: Boolean;
    procedure SetMax(const Value: Integer);
    procedure SetMin(const Value: Integer);
    procedure SetPageSize(const Value: Integer);
    procedure SetPosition(const Value: Integer);
    procedure SetVisible(const Value: Boolean);
    function GetTrackPos: Integer;
    procedure HandleVScroll(var Message: TWMVScroll);
    procedure HandleHScroll(var Message: TWMHScroll);
  public
    property Window: HWND read FWindow write FWindow;
    property Placing: TScrollBarPlacing read FPlacing write FPlacing;

    property Visible: Boolean read GetVisible write SetVisible;
    property Min: Integer read GetMin write SetMin;
    property Max: Integer read GetMax write SetMax;
    property Position: Integer read GetPosition write SetPosition;
    property PageSize: Integer read GetPageSize write SetPageSize;

    property Increment: Integer read FIncrement write FIncrement;
    property PageIncrement: Integer read FPageIncrement write FPageIncrement;

    function HandleScrollMessage(var Message: TMessage): Boolean;
  end;

implementation

{ TSdaWindowPaintHelper }

procedure TSdaWindowPaintHelper.BeginPaint(Window: HWND;
  const Message: TWMPaint);
begin
  FWindow := Window;
  FMsgDC := Message.DC <> 0;
  if FMsgDC then FPaintStruct.hdc := Message.DC
    else sdaWindows.BeginPaint(FWindow, FPaintStruct);
end;

procedure TSdaWindowPaintHelper.BeginPaint(Window: HWND;
  const Message: TWMEraseBkgnd);
begin
  FWindow := Window;
  FPaintStruct.hdc := Message.DC;
  FMsgDC := true;
end;

procedure TSdaWindowPaintHelper.EndPaint;
begin
  if not FMsgDC then sdaWindows.EndPaint(FWindow, FPaintStruct);
  FPaintStruct.hdc := 0;
  FWindow := 0;
end;

{ TSdaTimer }

procedure TSdaTimer.Disable;
begin
  if (Window <> 0) and (ID <> 0) then
    KillTimer(Window, ID);
end;

procedure TSdaTimer.Enable(AnInterval: Integer);
begin
  if (Window <> 0) and (ID <> 0) then
  begin
    KillTimer(Window, ID);
    SetTimer(Window, ID, AnInterval, nil);
  end;
end;

procedure TSdaTimer.SetID(const Value: Integer);
begin
  if Value <> ID then
  begin
    Disable;
    FID := Value;
  end;
end;

procedure TSdaTimer.SetWindow(const Value: HWND);
begin
  if Value <> Window then
  begin
    Disable;
    FWindow := Value;
  end;
end;

{ TSdaScrollBarHelper }

function TSdaScrollBarHelper.GetMax: Integer;
var
  si: SCROLLINFO;
begin
  FillChar(si, SizeOf(si), 0);
  si.cbSize := SizeOf(si);
  si.fMask := SIF_RANGE;
  GetScrollInfo(FWindow, Integer(FPlacing), si);
  Result := si.nMax;
end;

function TSdaScrollBarHelper.GetMin: Integer;
var
  si: SCROLLINFO;
begin
  FillChar(si, SizeOf(si), 0);
  si.cbSize := SizeOf(si);
  si.fMask := SIF_RANGE;
  GetScrollInfo(FWindow, Integer(FPlacing), si);
  Result := si.nMin;
end;

function TSdaScrollBarHelper.GetPageSize: Integer;
var
  si: SCROLLINFO;
begin
  FillChar(si, SizeOf(si), 0);
  si.cbSize := SizeOf(si);
  si.fMask := SIF_PAGE;
  GetScrollInfo(FWindow, Integer(FPlacing), si);
  Result := si.nPage;
end;

function TSdaScrollBarHelper.GetPosition: Integer;
var
  si: SCROLLINFO;
begin
  FillChar(si, SizeOf(si), 0);
  si.cbSize := SizeOf(si);
  si.fMask := SIF_POS;
  GetScrollInfo(FWindow, Integer(FPlacing), si);
  Result := si.nPos;
end;

function TSdaScrollBarHelper.GetTrackPos: Integer;
var
  si: SCROLLINFO;
begin
  FillChar(si, SizeOf(si), 0);
  si.cbSize := SizeOf(si);
  si.fMask := SIF_TRACKPOS;
  GetScrollInfo(FWindow, Integer(FPlacing), si);
  Result := si.nTrackPos;
end;

function TSdaScrollBarHelper.GetVisible: Boolean;
begin
  case FPlacing of
    sbpControl: Result := IsWindowVisible(FWindow);
    sbpHorizontal: Result := GetWindowLongPtr(FWindow, GWL_STYLE) and WS_HSCROLL = WS_HSCROLL;
    sbpVertical: Result := GetWindowLongPtr(FWindow, GWL_STYLE) and WS_VSCROLL = WS_VSCROLL;
    else Result := false;
  end;
end;

procedure TSdaScrollBarHelper.HandleHScroll(var Message: TWMHScroll);
begin
  Message.Result := 0;
  case Message.ScrollCode of
    SB_LEFT: Position := Min;
    SB_RIGHT: Position := Max;
    SB_LINELEFT: Position := Position - Increment;
    SB_LINERIGHT: Position := Position + Increment;
    SB_PAGELEFT: Position := Position - PageIncrement;
    SB_PAGERIGHT: Position := Position + PageIncrement;
    SB_THUMBPOSITION: Position := GetTrackPos;
    SB_THUMBTRACK: Position := GetTrackPos;
    SB_ENDSCROLL: ;
  end;
end;

procedure TSdaScrollBarHelper.HandleVScroll(var Message: TWMVScroll);
begin
  Message.Result := 0;
  case Message.ScrollCode of
    SB_TOP: Position := Min;
    SB_BOTTOM: Position := Max;
    SB_LINEUP: Position := Position - Increment;
    SB_LINEDOWN: Position := Position + Increment;
    SB_PAGEUP: Position := Position - PageIncrement;
    SB_PAGEDOWN: Position := Position + PageIncrement;
    SB_THUMBPOSITION: Position := GetTrackPos;
    SB_THUMBTRACK: Position := GetTrackPos;
    SB_ENDSCROLL: ;
  end;
end;

function TSdaScrollBarHelper.HandleScrollMessage(var Message: TMessage): Boolean;
begin
  if (FPlacing = sbpHorizontal) and (Message.Msg <> WM_HSCROLL) then Exit(false);
  if (FPlacing = sbpVertical) and (Message.Msg <> WM_VSCROLL) then Exit(false);
  Result := true;
  if Message.Msg = WM_HSCROLL then HandleHScroll(TWMHScroll(Message)) else
  if Message.Msg = WM_VSCROLL then HandleVScroll(TWMVScroll(Message)) else
    Result := false;
end;

procedure TSdaScrollBarHelper.SetMax(const Value: Integer);
var
  si: SCROLLINFO;
begin
  FillChar(si, SizeOf(si), 0);
  si.cbSize := SizeOf(si);
  si.fMask := SIF_RANGE;
  GetScrollInfo(FWindow, Integer(FPlacing), si);
  si.nMax := Value;
  SetScrollInfo(FWindow, Integer(FPlacing), si, true);
end;

procedure TSdaScrollBarHelper.SetMin(const Value: Integer);
var
  si: SCROLLINFO;
begin
  FillChar(si, SizeOf(si), 0);
  si.cbSize := SizeOf(si);
  si.fMask := SIF_RANGE;
  GetScrollInfo(FWindow, Integer(FPlacing), si);
  si.nMin := Value;
  SetScrollInfo(FWindow, Integer(FPlacing), si, true);
end;

procedure TSdaScrollBarHelper.SetPageSize(const Value: Integer);
var
  si: SCROLLINFO;
begin
  FillChar(si, SizeOf(si), 0);
  si.cbSize := SizeOf(si);
  si.fMask := SIF_PAGE;
  GetScrollInfo(FWindow, Integer(FPlacing), si);
  si.nPage := Value;
  SetScrollInfo(FWindow, Integer(FPlacing), si, true);
end;

procedure TSdaScrollBarHelper.SetPosition(const Value: Integer);
var
  si: SCROLLINFO;
begin
  FillChar(si, SizeOf(si), 0);
  si.cbSize := SizeOf(si);
  si.fMask := SIF_POS;
  GetScrollInfo(FWindow, Integer(FPlacing), si);
  si.nPos := Value;
  SetScrollInfo(FWindow, Integer(FPlacing), si, true);
end;

procedure TSdaScrollBarHelper.SetVisible(const Value: Boolean);
begin
  ShowScrollBar(FWindow, Integer(FPlacing), Value);
end;

end.
