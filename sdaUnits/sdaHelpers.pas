unit sdaHelpers;

interface

{$INCLUDE 'sda.inc'}

uses
  sdaWindows, sdaMessages;

type
  TSdaWindowPaintHelper = record
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

  TSdaTimer = record
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

  TSdaScrollBarHelper = record
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

  TSdaTranslateAccelHelper = record
  private
    FAccel: array of HACCEL;
    function GetCount: Integer; inline;
    function GetItem(Index: Integer): HACCEL; inline;
    procedure SetItem(Index: Integer; const Value: HACCEL); inline;
  public
    property Items[Index: Integer]: HACCEL read GetItem write SetItem; default;
    property Count: Integer read GetCount;

    procedure Add(Accel: HACCEL);
    procedure Delete(Accel: HACCEL; Destroy: Boolean = false);
    procedure Clear(Destroy: Boolean = false);
    procedure HandleAccelMessage(var Message: TMessage);
  end;

  TOwnerDrawControl = (
    OwnerDrawButton = ODT_BUTTON,     // Only draw
    OwnerDrawComboBox = ODT_COMBOBOX, // Measure & draw
    OwnerDrawListBox = ODT_LISTBOX,   // Measure & draw
    OwnerDrawListView = ODT_LISTVIEW, // Measure & draw
    OwnerDrawMenu = ODT_MENU,         // Measure & draw
    OwnerDrawStatic = ODT_STATIC,     // Only draw
    OwnerDrawTabControl = ODT_TAB,    // Only draw
    OwnerDrawHeader = ODT_HEADER      // ??
  );

  TMeasureItemEvent = procedure(Control: TOwnerDrawControl;
    ControlID, ItemIndex: Integer; var Width, Height: Integer;
    Data: Pointer; var Handled: Boolean) of object;

  TSdaMeasureItemHelper = record
  public
    class procedure HandleMeasureMessage(var Message: TWMMeasureItem;
      const Handler: TMeasureItemEvent); static;
  end;

  TOwnerDrawAction = set of (
    DrawActionDrawEntire, // ODA_DRAWENTIRE
    DrawActionFocus,      // ODA_FOCUS
    DrawActionSelect      // ODA_SELECT
  );

  TOwnerDrawState = set of (
    DrawStateChecked,      // ODS_CHECKED - only menu
    DrawStateComboBoxEdit, // ODS_COMBOBOXEDIT - edit control of combo box
    DrawStateDefault,      // ODS_DEFAULT
    DrawStateDisabled,     // ODS_DISABLED
    DrawStateFocus,        // ODS_FOCUS
    DrawStateGrayed,       // ODS_GRAYED - only menu
    DrawStateHotLight,     // ODS_HOTLIGHT
    DrawStateInactive,     // ODS_INACTIVE
    DrawStateNoAccel,      // ODS_NOACCEL
    DrawStateNoFocusRect,  // ODS_NOFOCUSRECT
    DrawStateSelected      // ODS_SELECTED
  );

  TDrawItemEvent = procedure(Control: TOwnerDrawControl; ControlID,
    ItemIndex: Integer; Action: TOwnerDrawAction; State: TOwnerDrawState;
    Handle: THandle { HWND or HMENU }; DC: HDC; const Rect: TRect;
    Data: Pointer; var Handled: Boolean) of object;

  TSdaDrawItemHelper = record
  public
    class procedure HandleDrawMessage(var Message: TWMDrawItem;
      const Handler: TDrawItemEvent); static;
  end;

  TSubclassProcedure = procedure(Window: HWND; var Message: TMessage;
    var Handled: Boolean) of object;

  TSdaSubclassHelper = record
  public
    class procedure Apply(Window: HWND; Proc: TSubclassProcedure); static;
    class procedure Remove(Window: HWND; Proc: TSubclassProcedure); static;
  end;

  TSdaSubclassObject = class(TObject)
  private
    FHandle: HWND;
    FHandled: Boolean;
    procedure SubclassProc(Window: HWND; var Message: TMessage; var Handled: Boolean);
    procedure SetHandle(const Value: HWND);
  public
    constructor Create(Window: HWND = 0); virtual;
    destructor Destroy; override;
    property Handle: HWND read FHandle write SetHandle;
    procedure DefaultHandler(var Message); override;
  end;

implementation

uses
  sdaSystem;

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

{ TSdaTranslateAccelHelper }

procedure TSdaTranslateAccelHelper.Add(Accel: HACCEL);
var
  i: Integer;
begin
  for i := 0 to High(FAccel) do
    if FAccel[i] = Accel then Exit;
  SetLength(FAccel, Length(FAccel) + 1);
  FAccel[High(FAccel)] := Accel;
end;

procedure TSdaTranslateAccelHelper.Clear(Destroy: Boolean);
var
  i: Integer;
begin
  if Destroy then
    for i := 0 to High(FAccel) do
      DestroyAcceleratorTable(FAccel[i]);
  SetLength(FAccel, 0);
end;

procedure TSdaTranslateAccelHelper.Delete(Accel: HACCEL; Destroy: Boolean);
var
  i: Integer;
  tmp: HACCEL;
begin
  for i := 0 to High(FAccel) do
    if FAccel[i] = Accel then
    begin
      tmp := FAccel[i];
      if i < High(FAccel) then FAccel[i] := FAccel[High(FAccel)];
      SetLength(FAccel, Length(FAccel) - 1);
      if Destroy then DestroyAcceleratorTable(tmp);
      Exit;
    end;
end;

function TSdaTranslateAccelHelper.GetCount: Integer;
begin
  Result := Length(FAccel);
end;

function TSdaTranslateAccelHelper.GetItem(Index: Integer): HACCEL;
begin
  Result := FAccel[Index];
end;

procedure TSdaTranslateAccelHelper.HandleAccelMessage(var Message: TMessage);
var
  i: Integer;
  msg: PMsg;
begin
  if Message.Msg <> SDAM_TRANSLATEACCEL then Exit;
  msg := PMsg(Message.LParam);
  for i := 0 to High(FAccel) do
    if TranslateAccelerator(msg.hwnd, FAccel[i], msg^) <> 0 then
    begin
      Message.Result := 1;
      Exit;
    end;
  Message.Result := 0;
end;

procedure TSdaTranslateAccelHelper.SetItem(Index: Integer; const Value: HACCEL);
begin
  FAccel[Index] := Value;
end;

{ TSdaMeasureItemHelper }

class procedure TSdaMeasureItemHelper.HandleMeasureMessage(var Message: TWMMeasureItem;
  const Handler: TMeasureItemEvent);
var
  w, h: Integer;
  Handled: Boolean;
begin
  Message.Result := LRESULT(BOOL(false));
  if not Assigned(Handler) then Exit;
  w := Message.MeasureItemStruct.itemWidth;
  h := Message.MeasureItemStruct.itemHeight;
  Handled := true;
  Handler(TOwnerDrawControl(Message.MeasureItemStruct.CtlType),
    Message.MeasureItemStruct.CtlID, Message.MeasureItemStruct.itemID,
    w, h, Pointer(Message.MeasureItemStruct.itemData), Handled);
  if Handled then
  begin
    Message.MeasureItemStruct.itemWidth := w;
    Message.MeasureItemStruct.itemHeight := h;
  end;
  Message.Result := LRESULT(BOOL(Handled));
end;

{ TSdaDrawItemHelper }

class procedure TSdaDrawItemHelper.HandleDrawMessage(var Message: TWMDrawItem;
  const Handler: TDrawItemEvent);
var
  Handled: Boolean;
  Action: TOwnerDrawAction;
  State: TOwnerDrawState;
begin
  Message.Result := LRESULT(BOOL(false));
  if not Assigned(Handler) then Exit;
  Handled := true;

  Action := [];
  if Message.DrawItemStruct.itemAction and ODA_DRAWENTIRE = ODA_DRAWENTIRE then
    Include(Action, DrawActionDrawEntire);
  if Message.DrawItemStruct.itemAction and ODA_FOCUS = ODA_FOCUS then
    Include(Action, DrawActionFocus);
  if Message.DrawItemStruct.itemAction and ODA_SELECT = ODA_SELECT then
    Include(Action, DrawActionSelect);

  State := [];
  if Message.DrawItemStruct.itemState and ODS_CHECKED = ODS_CHECKED then
    Include(State, DrawStateChecked);
  if Message.DrawItemStruct.itemState and ODS_COMBOBOXEDIT = ODS_COMBOBOXEDIT then
    Include(State, DrawStateComboBoxEdit);
  if Message.DrawItemStruct.itemState and ODS_DEFAULT = ODS_DEFAULT then
    Include(State, DrawStateDefault);
  if Message.DrawItemStruct.itemState and ODS_DISABLED = ODS_DISABLED then
    Include(State, DrawStateDisabled);
  if Message.DrawItemStruct.itemState and ODS_FOCUS = ODS_FOCUS then
    Include(State, DrawStateFocus);
  if Message.DrawItemStruct.itemState and ODS_GRAYED = ODS_GRAYED then
    Include(State, DrawStateGrayed);
  if Message.DrawItemStruct.itemState and ODS_HOTLIGHT = ODS_HOTLIGHT then
    Include(State, DrawStateHotLight);
  if Message.DrawItemStruct.itemState and ODS_INACTIVE = ODS_INACTIVE then
    Include(State, DrawStateInactive);
  if Message.DrawItemStruct.itemState and ODS_NOACCEL = ODS_NOACCEL then
    Include(State, DrawStateNoAccel);
  if Message.DrawItemStruct.itemState and ODS_NOFOCUSRECT = ODS_NOFOCUSRECT then
    Include(State, DrawStateNoFocusRect);
  if Message.DrawItemStruct.itemState and ODS_SELECTED = ODS_SELECTED then
    Include(State, DrawStateSelected);

  Handler(TOwnerDrawControl(Message.DrawItemStruct.CtlType),
    Message.DrawItemStruct.CtlID, Message.DrawItemStruct.itemID,
    Action, State, Message.DrawItemStruct.hwndItem,
    Message.DrawItemStruct.hDC, Message.DrawItemStruct.rcItem,
    Pointer(Message.DrawItemStruct.itemData), Handled);
  Message.Result := LRESULT(BOOL(Handled));
end;

{ TSdaSubclassHelper }

function SubclassProc(hWnd: HWND; uMsg: UINT; wParam: WPARAM; lParam: LPARAM;
  uIdSubclass: UINT_PTR; dwRefData: DWORD_PTR): LRESULT; stdcall;
var
  Message: TMessage;
  Handled: Boolean;
  Obj: Pointer absolute dwRefData;
  Proc: Pointer absolute uIdSubclass;
  Meth: TSubclassProcedure;
begin
  if uMsg = WM_NCDESTROY then
    RemoveWindowSubclass(hWnd, @SubclassProc, uIdSubclass);
  if Assigned(Obj) and Assigned(Proc) then
  begin
    Handled := true;
    TMethod(Meth).Code := Proc;
    TMethod(Meth).Data := Obj;
    Message.Msg := uMsg;
    Message.WParam := wParam;
    Message.LParam := lParam;
    Message.Result := 0;
    Meth(hWnd, Message, Handled);
  end else Handled := false;
  if Handled then Result := Message.Result
    else Result := DefSubclassProc(hWnd, uMsg, wParam, lParam);
end;

class procedure TSdaSubclassHelper.Apply(Window: HWND; Proc: TSubclassProcedure);
begin
  SetWindowSubclass(Window, SubclassProc, DWORD(TMethod(Proc).Code),
    DWORD(TMethod(Proc).Data));
end;

class procedure TSdaSubclassHelper.Remove(Window: HWND; Proc: TSubclassProcedure);
begin
  RemoveWindowSubclass(Window, SubclassProc, DWORD(TMethod(Proc).Code));
end;

{ TSdaSubclassObject }

constructor TSdaSubclassObject.Create(Window: HWND);
begin
  inherited Create;
  FHandle := Window;
  if Handle <> 0 then TSdaSubclassHelper.Apply(Handle, SubclassProc);
end;

destructor TSdaSubclassObject.Destroy;
begin
  if Handle <> 0 then TSdaSubclassHelper.Remove(Handle, SubclassProc);
  inherited Destroy;
end;

procedure TSdaSubclassObject.DefaultHandler(var Message);
begin
  FHandled := false;
end;

procedure TSdaSubclassObject.SetHandle(const Value: HWND);
begin
  if Handle <> 0 then TSdaSubclassHelper.Remove(Handle, SubclassProc);
  FHandle := Value;
  if Handle <> 0 then TSdaSubclassHelper.Apply(Handle, SubclassProc);
end;

procedure TSdaSubclassObject.SubclassProc(Window: HWND; var Message: TMessage;
  var Handled: Boolean);
begin
  if Window <> Handle then
  begin
    Handled := false;
    Exit;
  end;
  FHandled := Handled;
  Dispatch(Message);
end;

end.
