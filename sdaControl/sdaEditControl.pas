unit sdaEditControl;

interface

{$INCLUDE 'sda.inc'}

uses
  sdaWindows, sdaMessages;

type
  TSdaEditControl = record
  private
    FHandle: HWND;
    function GetStyle: DWORD;
    procedure SetStyle(const Value: DWORD);
    function GetHorizontalScroll: Boolean;
    function GetVerticalScroll: Boolean;
    procedure SetHorizontalScroll(const Value: Boolean);
    procedure SetVerticalScroll(const Value: Boolean);
    function GetSelLength: Integer;
    function GetSelStart: Integer;
    procedure SetSelLength(const Value: Integer);
    procedure SetSelStart(const Value: Integer);
    function GetModified: Boolean;
    procedure SetModified(const Value: Boolean);
    function GetText: string;
    procedure SetText(const Value: string);
    function GetSelText: string;
    procedure SetSelText(const Value: string);
  public
    property Handle: HWND read FHandle write FHandle;
    class function CreateHandle(Style: DWORD = WS_CHILD;
      Parent: HWND = 0; const Text: string = ''; ExStyle: DWORD = 0): HWND; inline; static;
    procedure DestroyHandle; inline;
    class operator Implicit(Value: HWND): TSdaEditControl; inline;

    property Style: DWORD read GetStyle write SetStyle;
    property VerticalScroll: Boolean read GetVerticalScroll write SetVerticalScroll;
    property HorizontalScroll: Boolean read GetHorizontalScroll write SetHorizontalScroll;

    procedure Cut;
    procedure Copy;
    procedure Paste;
    procedure Delete;
    procedure SelectAll;
    procedure Undo;

    property Text: string read GetText write SetText;

    procedure SetSelection(const Text: string; CanUndo: Boolean = true);

    property SelStart: Integer read GetSelStart write SetSelStart;
    property SelLength: Integer read GetSelLength write SetSelLength;
    property SelText: string read GetSelText write SetSelText;

    property Modified: Boolean read GetModified write SetModified;

    procedure ScrollToCaret;
    procedure ClearUndo;
  end;

implementation

{ TSdaEditControl }

class function TSdaEditControl.CreateHandle(Style: DWORD; Parent: HWND;
  const Text: string; ExStyle: DWORD): HWND;
begin
  Result := CreateWindowEx(ExStyle, 'EDIT', PChar(Text), Style, 0, 0, 0, 0,
    Parent, 0, HInstance, nil);
end;

procedure TSdaEditControl.Cut;
begin
  SendMessage(Handle, WM_CUT, 0, 0);
end;

procedure TSdaEditControl.ClearUndo;
begin
  SendMessage(Handle, EM_EMPTYUNDOBUFFER, 0, 0);
end;

procedure TSdaEditControl.Copy;
begin
  SendMessage(Handle, WM_COPY, 0, 0);
end;

procedure TSdaEditControl.Delete;
begin
  SendMessage(Handle, WM_CLEAR, 0, 0);
end;

procedure TSdaEditControl.Paste;
begin
  SendMessage(Handle, WM_PASTE, 0, 0);
end;

procedure TSdaEditControl.DestroyHandle;
begin
  if DestroyWindow(FHandle) then
    FHandle := 0;
end;

function TSdaEditControl.GetHorizontalScroll: Boolean;
begin
  Result := (GetWindowLongPtr(Handle, GWL_STYLE) and WS_HSCROLL) = WS_HSCROLL;
end;

function TSdaEditControl.GetModified: Boolean;
begin
  Result := SendMessage(Handle, EM_GETMODIFY, 0, 0) <> 0;
end;

function TSdaEditControl.GetSelLength: Integer;
var
  dws, dwe: DWORD;
begin
  SendMessage(Handle, EM_GETSEL, WPARAM(@dws), LPARAM(@dwe));
  Result := dwe - dws;
end;

function TSdaEditControl.GetSelStart: Integer;
var
  dws: DWORD;
begin
  SendMessage(Handle, EM_GETSEL, WPARAM(@dws), 0);
  Result := dws;
end;

function TSdaEditControl.GetSelText: string;
var
  dws, dwe: DWORD;
begin
  SendMessage(Handle, EM_GETSEL, WPARAM(@dws), LPARAM(@dwe));
  Result := System.Copy(Text, dws + 1, dwe - dws);
end;

function TSdaEditControl.GetStyle: DWORD;
begin
  Result := GetWindowLongPtr(Handle, GWL_STYLE) and $0000ffff;
end;

function TSdaEditControl.GetText: string;
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

function TSdaEditControl.GetVerticalScroll: Boolean;
begin
  Result := (GetWindowLongPtr(Handle, GWL_STYLE) and WS_VSCROLL) = WS_VSCROLL;
end;

class operator TSdaEditControl.Implicit(Value: HWND): TSdaEditControl;
begin
  Result.Handle := Value;
end;

procedure TSdaEditControl.ScrollToCaret;
begin
  SendMessage(Handle, EM_SCROLLCARET, 0, 0);
end;

procedure TSdaEditControl.SelectAll;
begin
  SendMessage(Handle, EM_SETSEL, 0, LPARAM(-1));
end;

procedure TSdaEditControl.SetHorizontalScroll(const Value: Boolean);
begin
  ShowScrollBar(Handle, SB_HORZ, Value);
end;

procedure TSdaEditControl.SetModified(const Value: Boolean);
begin
  SendMessage(Handle, EM_SETMODIFY, WPARAM(Value), 0);
end;

procedure TSdaEditControl.SetSelection(const Text: string; CanUndo: Boolean);
begin
  SendMessage(Handle, EM_REPLACESEL, WPARAM(CanUndo), LPARAM(PChar(Text)));
end;

procedure TSdaEditControl.SetSelLength(const Value: Integer);
var
  dws: DWORD;
begin
  SendMessage(Handle, EM_GETSEL, WPARAM(@dws), 0);
  SendMessage(Handle, EM_SETSEL, dws, dws + DWORD(Value));
end;

procedure TSdaEditControl.SetSelStart(const Value: Integer);
begin
  SendMessage(Handle, EM_SETSEL, Value, Value);
end;

procedure TSdaEditControl.SetSelText(const Value: string);
begin
  SetSelection(Value, true);
end;

procedure TSdaEditControl.SetStyle(const Value: DWORD);
var
  dw: DWORD;
begin
  dw := GetWindowLongPtr(Handle, GWL_STYLE) and $ffff0000;
  SetWindowLongPtr(Handle, GWL_STYLE, (Value and $0000ffff) or dw);
end;

procedure TSdaEditControl.SetText(const Value: string);
begin
  SendMessage(Handle, WM_SETTEXT, 0, LPARAM(PChar(Value)));
end;

procedure TSdaEditControl.SetVerticalScroll(const Value: Boolean);
begin
  ShowScrollBar(Handle, SB_VERT, Value);
end;

procedure TSdaEditControl.Undo;
begin
  SendMessage(Handle, EM_UNDO, 0, 0);
end;

end.
