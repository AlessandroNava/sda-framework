unit sdaDialogControl;

interface

{$INCLUDE 'sda.inc'}

uses
  sdaWindows, sdaMessages;

type
  TSdaDialogControl = record
  private
    FHandle: HWND;
    function GetItemEnabled(ItemID: Integer): Boolean;
    function GetItemHandle(ItemID: Integer): HWND;
    function GetItemID(WndChild: HWND): Integer;
    function GetItemCaption(ItemID: Integer): string;
    function GetItemVisible(ItemID: Integer): Boolean;
    procedure SetItemEnabled(ItemID: Integer; const Value: Boolean);
    procedure SetItemCaption(ItemID: Integer; const Value: string);
    procedure SetItemVisible(ItemID: Integer; const Value: Boolean);
    function GetDialogUnits(const Index: Integer): Integer;
    function GetDefaultItem: Integer;
    procedure SetDefaultItem(const Value: Integer);
  public
    property Handle: HWND read FHandle write FHandle;
    procedure DestroyHandle; inline;

    class operator Implicit(Value: HWND): TSdaDialogControl; inline;

    property ItemHandle[ItemID: Integer]: HWND read GetItemHandle;
    property ItemID[WndChild: HWND]: Integer read GetItemID;

    property ItemVisible[ItemID: Integer]: Boolean read GetItemVisible
      write SetItemVisible;
    property ItemCaption[ItemID: Integer]: string read GetItemCaption
      write SetItemCaption;
    property ItemEnabled[ItemID: Integer]: Boolean read GetItemEnabled
      write SetItemEnabled;

    procedure ChangeItemID(OldID, NewID: Integer); overload;
    procedure ChangeItemID(hwndItem: HWND; NewID: Integer); overload;

    procedure FocusItem(ItemID: Integer);
    procedure NextControl;
    procedure PrevControl;

    property DefaultItem: Integer read GetDefaultItem write SetDefaultItem;

    property DialogUnitsX: Integer index 0 read GetDialogUnits;
    property DialogUnitsY: Integer index 1 read GetDialogUnits;

    procedure MapDialogRect(var Rect: TRect);
    procedure Reposition;
  end;

implementation

{ TSdaDialogControl }

procedure TSdaDialogControl.DestroyHandle;
begin
  if DestroyWindow(Handle) then
    FHandle := 0;
end;

procedure TSdaDialogControl.ChangeItemID(hwndItem: HWND; NewID: Integer);
begin
  SetWindowLong(hwndItem, GWL_ID, NewID);
end;

class operator TSdaDialogControl.Implicit(Value: HWND): TSdaDialogControl;
begin
  Result.Handle := Value;
end;

procedure TSdaDialogControl.ChangeItemID(OldID, NewID: Integer);
var
  wnd: HWND;
begin
  wnd := ItemHandle[OldID];
  SetWindowLong(wnd, GWL_ID, NewID);
end;

procedure TSdaDialogControl.FocusItem(ItemID: Integer);
var
  wnd: HWND;
begin
  if ItemID > 0 then
  begin
    wnd := ItemHandle[ItemID];
    if wnd <> 0 then
      PostMessage(Handle, WM_NEXTDLGCTL, wnd, 1);
  end;
end;

function TSdaDialogControl.GetItemEnabled(ItemID: Integer): Boolean;
var
  wnd: HWND;
begin
  wnd := ItemHandle[ItemID];
  if IsWindow(wnd) then Result := IsWindowEnabled(wnd)
    else Result := false;
end;

function TSdaDialogControl.GetItemHandle(ItemID: Integer): HWND;
begin
  if ItemID <= 0 then Exit(0);
  if IsWindow(Handle) then Result := GetDlgItem(Handle, ItemID)
    else Result := 0;
end;

function TSdaDialogControl.GetItemID(WndChild: HWND): Integer;
begin
  Result := GetDlgCtrlID(WndChild);
end;

function TSdaDialogControl.GetDefaultItem: Integer;
begin
  Result := LoWord(SendMessage(Handle, DM_GETDEFID, 0, 0));
end;

function TSdaDialogControl.GetDialogUnits(const Index: Integer): Integer;
var
  rc: TRect;
begin
  rc.Left := 0; rc.Top := 0;
  rc.Right := 1; rc.Bottom := 1;
  sdaWindows.MapDialogRect(Handle, rc);
  if Index = 0 then Result := rc.Right
    else Result := rc.Bottom;
end;

function TSdaDialogControl.GetItemCaption(ItemID: Integer): string;
var
  wnd: HWND;
  cbText: Integer;
begin
  wnd := ItemHandle[ItemID];
  if IsWindow(wnd) then
  begin
    cbText := GetWindowTextLength(wnd);
    if cbText > 0 then
    begin
      SetLength(Result, cbText + 1);
      FillChar(Result[1], Length(Result) * SizeOf(char), 0);
      cbText := GetWindowText(wnd, PChar(Result), Length(Result));
      if cbText >= 0 then SetLength(Result, cbText);
    end else Result := '';
  end else Result := '';
end;

function TSdaDialogControl.GetItemVisible(ItemID: Integer): Boolean;
var
  wnd: HWND;
begin
  wnd := ItemHandle[ItemID];
  if wnd <> 0 then Result := IsWindowVisible(wnd)
    else Result := false;
end;

procedure TSdaDialogControl.MapDialogRect(var Rect: TRect);
begin
  sdaWindows.MapDialogRect(Handle, Rect);
end;

procedure TSdaDialogControl.NextControl;
begin
  PostMessage(Handle, WM_NEXTDLGCTL, 0, 0);
end;

procedure TSdaDialogControl.PrevControl;
begin
  PostMessage(Handle, WM_NEXTDLGCTL, 1, 0);
end;

procedure TSdaDialogControl.Reposition;
begin
  SendMessage(Handle, DM_REPOSITION, 0, 0);
end;

procedure TSdaDialogControl.SetItemEnabled(ItemID: Integer;
  const Value: Boolean);
var
  wnd: HWND;
begin
  wnd := ItemHandle[ItemID];
  if IsWindow(wnd) then
  begin
    if wnd = GetFocus then NextControl;
    EnableWindow(wnd, Value);
  end;
end;

procedure TSdaDialogControl.SetDefaultItem(const Value: Integer);
begin
  SendMessage(Handle, DM_SETDEFID, Value, 0);
end;

procedure TSdaDialogControl.SetItemCaption(ItemID: Integer; const Value: string);
var
  wnd: HWND;
begin
  wnd := ItemHandle[ItemID];
  if IsWindow(wnd) then SetDlgItemText(Handle, ItemID, PChar(Value));
end;

procedure TSdaDialogControl.SetItemVisible(ItemID: Integer;
  const Value: Boolean);
var
  wnd: HWND;
begin
  wnd := ItemHandle[ItemID];
  if IsWindow(wnd) then
    if Value then ShowWindow(wnd, SW_SHOW)
             else ShowWindow(wnd, SW_HIDE);
end;

end.
