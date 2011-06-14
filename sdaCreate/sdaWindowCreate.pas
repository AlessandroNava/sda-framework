unit sdaWindowCreate;

interface

{$INCLUDE 'sda.inc'}

uses
  sdaWindows, sdaMessages;

type
  TSdaWindowProc = function(Window: HWND; var Message: TMessage): BOOL; stdcall;

procedure SdaInitWindowClass(var WndClass: TWndClassEx);
function SdaRegisterWindowClass(WndClass: TWndClassEx): Boolean;
function SdaGetInstancePointer(Window: HWND): Pointer;
procedure SdaDefProcessMessage(Window: HWND; var Message: TMessage);

implementation

procedure SdaDefProcessMessage(Window: HWND; var Message: TMessage);
begin
  Message.Result := DefWindowProc(Window, Message.Msg, Message.WParam,
    Message.LParam);
end;

procedure SdaInitWindowClass(var WndClass: TWndClassEx);
begin
  FillChar(WndClass, SizeOf(WndClass), 0);
  WndClass.cbSize := SizeOf(WndClass);
  WndClass.hInstance := HInstance;
  WndClass.hCursor := LoadCursor(0, IDC_ARROW);
  WndClass.hbrBackground := COLOR_WINDOW + 1;
end;

const
  SDACL_INSTANCESIZE = 0;
  SDACL_WINDOWPROC = SizeOf(Pointer);

function SdaGetInstancePointer(Window: HWND): Pointer;
var
  n: Integer;
begin
  n := GetClassLongPtr(Window, GCL_CBWNDEXTRA);
  if n < SizeOf(Pointer) then Exit(nil);
  Result := Pointer(GetWindowLongPtr(Window, n - SizeOf(Pointer)));
end;

function SdaWindowProc(hWnd: HWND; uMsg: UINT; wParam: WPARAM;
  lParam: LPARAM): LRESULT; stdcall;
var
  n, cb: Integer;
  WndProc: Pointer;
  SelfPtr: Pointer;
  Msg: TMessage;
  MsgHandled: BOOL;
begin
  if uMsg = WM_NCCREATE then
  begin
    n := GetClassLongPtr(hWnd, GCL_CBWNDEXTRA);
    if n >= SizeOf(Pointer) then
    begin
      Dec(n, SizeOf(Pointer));
      cb := GetClassLongPtr(hWnd, SDACL_INSTANCESIZE);
      if cb > 0 then
      begin
        GetMem(SelfPtr, cb);
        if SelfPtr <> nil then ZeroMemory(SelfPtr, cb);
      end else SelfPtr := nil;
      SetWindowLongPtr(hWnd, n, NativeInt(SelfPtr));
    end;
  end;

  WndProc := Pointer(GetClassLongPtr(hWnd, SDACL_WINDOWPROC));
  if WndProc <> nil then
  begin
    Msg.Msg := uMsg;
    Msg.WParam := wParam;
    Msg.LParam := lParam;
    Msg.Result := 0;
    MsgHandled := TSdaWindowProc(WndProc)(hWnd, Msg);
  end else MsgHandled := false;

  if uMsg = WM_NCDESTROY then
  begin
    n := GetClassLongPtr(hWnd, GCL_CBWNDEXTRA);
    if n >= SizeOf(Pointer) then
    begin
      Dec(n, SizeOf(Pointer));
      SelfPtr := Pointer(SetWindowLongPtr(hWnd, n, NativeInt(nil)));
      FreeMem(SelfPtr);
    end;
  end;
  if MsgHandled then Result := Msg.Result
    else Result := DefWindowProc(hWnd, uMsg, wParam, lParam);
end;

{ WndClass.cbClsExtra
    На вході - розмір даних класу; замінюємо на 2 * SizeOf(Pointer) - для
    зберігання оригінального значення cbClsExtra та вказівника на віконну
    процедуру TSdaWindowProc
  WndClass.cbWndExtra
    Додаємо в кінці чотири байти для зберігання вказівника на дані класу
  WndClass.lpfnWndProc
    На вході - вказівник на віконну процедуру типу TSdaWindowProc; замінюємо
    на DefWindowProc, а оригінальний вказівник записуємо в екстрадані класу.
    Спочатку встановлюємо DefWindowProc для того, щоб можна було створити
    тимчасове вікно без негативних насліків, потім змінюємо на SdaWindowProc -
    всі нові вікна будуть створюватись з новою віконною процедурою
}
function SdaRegisterWindowClass(WndClass: TWndClassEx): Boolean;
var
  h: HWND;
  ClsDataSize: Integer;
  WndProc: Pointer;
begin
  ClsDataSize := WndClass.cbClsExtra;
  WndClass.cbClsExtra := 2 * SizeOf(Pointer);
  WndClass.cbWndExtra := WndClass.cbWndExtra + SizeOf(Pointer);
  WndProc := WndClass.lpfnWndProc;
  WndClass.lpfnWndProc := @DefWindowProc;
  Result := RegisterClassEx(WndClass) <> 0;
  if Result then
  begin
    h := CreateWindow(WndClass.lpszClassName, nil, WS_OVERLAPPED, 0, 0, 0, 0, 0,
      0, WndClass.hInstance, nil);
    if h <> 0 then
    begin
      SetClassLongPtr(h, SDACL_INSTANCESIZE, ClsDataSize);
      SetClassLongPtr(h, SDACL_WINDOWPROC, NativeInt(WndProc));
      SetClassLongPtr(h, GCL_WNDPROC, NativeInt(@SdaWindowProc));
      DestroyWindow(h);
    end;
  end;
end;

end.
