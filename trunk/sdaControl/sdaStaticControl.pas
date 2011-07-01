unit sdaStaticControl;

interface

{$INCLUDE 'sda.inc'}

uses
  sdaWindows, sdaMessages;

const
  WC_STATIC = 'Static';

const
  { Static Control Mesages }
  STM_SETICON = 368;
  STM_GETICON = 369;
  STM_SETIMAGE = 370;
  STM_GETIMAGE = 371;

  { Static Control Notifications }
  STN_CLICKED = 0;
  STN_DBLCLK = 1;
  STN_ENABLE = 2;
  STN_DISABLE = 3;
  STM_MSGMAX = 372;

const
  SS_LEFT = 0;
  SS_CENTER = 1;
  SS_RIGHT = 2;
  SS_ICON = 3;
  SS_BLACKRECT = 4;
  SS_GRAYRECT = 5;
  SS_WHITERECT = 6;
  SS_BLACKFRAME = 7;
  SS_GRAYFRAME = 8;
  SS_WHITEFRAME = 9;
  SS_USERITEM = 10;
  SS_SIMPLE = 11;
  SS_LEFTNOWORDWRAP = 12;
  SS_BITMAP = 14;
  SS_OWNERDRAW = 13;
  SS_ENHMETAFILE = 15;
  SS_ETCHEDHORZ = $10;
  SS_ETCHEDVERT = 17;
  SS_ETCHEDFRAME = 18;
  SS_TYPEMASK = 31;
  SS_NOPREFIX = $80;
  SS_NOTIFY = $100;
  SS_CENTERIMAGE = $200;
  SS_RIGHTJUST = $400;
  SS_REALSIZEIMAGE = $800;
  SS_SUNKEN = $1000;
  SS_EDITCONTROL = $2000;
  SS_ENDELLIPSIS =  $4000;
  SS_PATHELLIPSIS = $8000;
  SS_WORDELLIPSIS = $C000;
  SS_ELLIPSISMASK = $C000;

type
  TSdaStaticControl = record
  private
    FHandle: HWND;
    function GetBitmap: HBITMAP; inline;
    function GetIcon: HICON; inline;
    function GetMetafile: HENHMETAFILE; inline;
    procedure SetBitmap(const Value: HBITMAP); inline;
    procedure SetIcon(const Value: HICON); inline;
    procedure SetMetafile(const Value: HENHMETAFILE); inline;
    function GetText: string;
    procedure SetText(const Value: string); inline;
    function GetStyle: DWORD; inline;
    procedure SetStyle(const Value: DWORD);
  public
    property Handle: HWND read FHandle write FHandle;
    class operator Implicit(Value: HWND): TSdaStaticControl;
    class function CreateHandle(Style: DWORD; Left, Top, Width, Height: Integer;
      Parent: HWND = 0; const Caption: string = ''): HWND; inline; static;
    procedure DestroyHandle; inline;

    property Icon: HICON read GetIcon write SetIcon;
    property Bitmap: HBITMAP read GetBitmap write SetBitmap;
    property Metafile: HENHMETAFILE read GetMetafile write SetMetafile;
    property Text: string read GetText write SetText;
    property Style: DWORD read GetStyle write SetStyle;
  end;

implementation

{ TSdaStaticControl }

class function TSdaStaticControl.CreateHandle(Style: DWORD; Left, Top,
  Width, Height: Integer; Parent: HWND; const Caption: string): HWND;
var
  p: PChar;
begin
  if Caption = '' then p := nil
    else p := PChar(Caption);
  Result := CreateWindow(WC_STATIC, p, Style, Left, Top, Width, Height,
    Parent, 0, HInstance, nil);
end;

procedure TSdaStaticControl.DestroyHandle;
begin
  if DestroyWindow(Handle) then
    FHandle := 0;
end;

function TSdaStaticControl.GetBitmap: HBITMAP;
begin
  Result := SendMessage(Handle, STM_GETIMAGE, IMAGE_BITMAP, 0);
end;

function TSdaStaticControl.GetIcon: HICON;
begin
  Result := SendMessage(Handle, STM_GETIMAGE, IMAGE_ICON, 0);
end;

function TSdaStaticControl.GetMetafile: HENHMETAFILE;
begin
  Result := SendMessage(Handle, STM_GETIMAGE, IMAGE_ENHMETAFILE, 0);
end;

function TSdaStaticControl.GetStyle: DWORD;
begin
  Result := GetWindowLongPtr(Handle, GWL_STYLE) and $0000ffff;
end;

function TSdaStaticControl.GetText: string;
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

class operator TSdaStaticControl.Implicit(Value: HWND): TSdaStaticControl;
begin
  Result.Handle := Value;
end;

procedure TSdaStaticControl.SetBitmap(const Value: HBITMAP);
begin
  SendMessage(Handle, STM_SETIMAGE, IMAGE_BITMAP, Value);
end;

procedure TSdaStaticControl.SetIcon(const Value: HICON);
begin
  SendMessage(Handle, STM_SETIMAGE, IMAGE_ICON, Value);
end;

procedure TSdaStaticControl.SetMetafile(const Value: HENHMETAFILE);
begin
  SendMessage(Handle, STM_SETIMAGE, IMAGE_ENHMETAFILE, Value);
end;

procedure TSdaStaticControl.SetStyle(const Value: DWORD);
var
  dw: DWORD;
begin
  dw := GetWindowLongPtr(Handle, GWL_STYLE) and $ffff0000;
  SetWindowLongPtr(Handle, GWL_STYLE, dw or (Value and $0000ffff));
  SetWindowPos(Handle, 0, 0, 0, 0, 0, SWP_NOSIZE or SWP_NOMOVE or SWP_NOZORDER or
    SWP_FRAMECHANGED);
end;

procedure TSdaStaticControl.SetText(const Value: string);
begin
  SendMessage(Handle, WM_SETTEXT, 0, LPARAM(PChar(Value)));
end;

end.
