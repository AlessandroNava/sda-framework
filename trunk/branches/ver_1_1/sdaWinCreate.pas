unit sdaWinCreate;

interface

{$INCLUDE 'sda.inc'}

uses
  Windows, Messages, sdaSysUtils;

const
  SDAM_BASE = WM_APP + $3000;
  SDAM_SETWNDHANDLE = SDAM_BASE + 1;
  SDAM_DESTROYWINDOW = SDAM_BASE + 2;
  
type
  TSdaBasicWindow = class(TObject)
  strict private
    FHandle: HWND;
    procedure SDASetWndHandle(var Message: TMessage); message SDAM_SETWNDHANDLE;
    procedure WMTimer(var Message: TWMTimer); message WM_TIMER;
    procedure WMCommand(var Message: TWMCommand); message WM_COMMAND;
    procedure WMSysCommand(var Message: TWMSysCommand); message WM_SYSCOMMAND;
    procedure WMHotKey(var Message: TWMHotKey); message WM_HOTKEY;
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
    procedure WMStyleChanging(var Message: TWMStyleChanging); message WM_STYLECHANGING;
    procedure WMNCDestroy(var Message: TWMNCDestroy); message WM_NCDESTROY;
  strict protected
    property Handle: HWND read FHandle write FHandle;
    procedure DestroyHandle;
    procedure TimerEvent(TimerID: Integer); virtual;
    function  CommandEvent(ItemID: Integer; EventCode: Integer): Boolean; virtual;
    procedure HotKeyEvent(HotKeyID: Integer); virtual;
    procedure PaintEvent(DC: HDC); virtual;
    function StyleChanging(OldStyle: DWORD; var NewStyle: DWORD;
      ExStyle: Boolean): Boolean; virtual;
    { Meaning of Param:
      EventCode                         Meaning
      ------------------------------------------------------
      SC_HOTKEY                         ActivateWnd: HWND

      SC_KEYMENU                        Key: Word

      SC_CLOSE, SC_HSCROLL,
      SC_MAXIMIZE, SC_MINIMIZE,
      SC_MOUSEMENU, SC_MOVE,
      SC_NEXTWINDOW, SC_PREVWINDOW,
      SC_RESTORE, SC_SCREENSAVE,
      SC_SIZE, SC_TASKLIST, SC_VSCROLL: XPos, YPos: Smallint

      Other:                            unused
    }
    function SysCommandEvent(EventCode: Integer; Param: LPARAM): Boolean; virtual;
    { Messages $C000..$FFFF (RegisterWindowMessage)
    }
    procedure RegisteredMessage(var Message: TMessage); virtual;
    procedure BeforeDestroyHandle; virtual;
  public
    constructor Create; virtual;

    class function WinClassName: string; virtual;
    class function FillWndClass(var AWndClass: TWndClassEx): Boolean; virtual;

    class function RegisterClass: Boolean;
    class function UnregisterClass: Boolean;
    class function ClassRegistered: Boolean;
    class function GetWindowClass(var AWndClass: TWndClassEx): Boolean;

    procedure DefaultHandler(var Message); override;
  end;

  TSdaWindowObjectClass = class of TSdaBasicWindow;

  TSdaWindowObject = class(TSdaBasicWindow)
  public
    class function CreateHandle(const ACaption: string = '';
      AStyle: DWORD = WS_OVERLAPPEDWINDOW;
      AExStyle: DWORD = 0;
      ALeft: Integer = Integer(CW_USEDEFAULT);
      ATop: Integer = Integer(CW_USEDEFAULT);
      AWidth: Integer = Integer(CW_USEDEFAULT);
      AHeight: Integer = Integer(CW_USEDEFAULT);
      AWndParent: HWND = 0;
      AInstance: HINST = 0;
      AMenu: HMENU = 0;
      AParam: Pointer = nil): HWND; virtual;
  end;

  TSdaDialogObject = class(TSdaBasicWindow)
  strict private
    FDialogMessageHandled: Boolean;
  strict private
    procedure WMCommand(var Message: TWMCommand); message WM_COMMAND;
    procedure WMSysCommand(var Message: TWMSysCommand); message WM_SYSCOMMAND;
    procedure WMInitDialog(var Message: TWMInitDialog); message WM_INITDIALOG;
  strict protected
    function InitDialog(AFocusControl: HWND): Boolean; virtual;
  protected
    property DialogMessageHandled: Boolean read FDialogMessageHandled
      write FDialogMessageHandled;
  public
    class function WinClassName: string; override;
    class function FillWndClass(var AWndClass: TWndClassEx): Boolean; override;

    procedure Dispatch(var Message); override;
    procedure DefaultHandler(var Message); override;

    class function CreateHandle(const ATemplateName: string;
      AWndParent: HWND = 0; AInstance: HINST = 0;
      AParam: Pointer = nil): HWND; overload; virtual;
    class function CreateHandle(const ATemplateId: Integer;
      AWndParent: HWND = 0; AInstance: HINST = 0;
      AParam: Pointer = nil): HWND; overload; virtual;
    class function CreateHandle(const ATemplate: DLGTEMPLATE;
      AWndParent: HWND = 0; AParam: Pointer = nil): HWND; overload; virtual;
  end;

function SdaSetAssociatedObject(hWnd: HWND; const Obj: TObject): TObject;
function SdaGetAssociatedObject(hWnd: HWND): TObject;

function SdaRegisterWindowClass(WndClass: TWndClassEx): Boolean;

function SdaCreateWindow(dwExStyle: DWORD; lpClassName: PWideChar;
  lpWindowName: PWideChar; dwStyle: DWORD; X, Y, nWidth, nHeight: Integer;
  hWndParent: HWND; hMenu: HMENU; hInstance: HINST; lpParam: Pointer;
  sdaObjectClass: TSdaWindowObjectClass): HWND;

function SdaCreateDialog(hInstance: HINST; lpTemplateName: PWideChar;
  hWndParent: HWND; lpInitParam: Pointer;
  sdaObjectClass: TSdaWindowObjectClass): HWND; overload;
function SdaCreateDialog(hInstance: HINST; const lpTemplate: TDlgTemplate;
  hWndParent: HWND; lpInitParam: Pointer;
  sdaObjectClass: TSdaWindowObjectClass): HWND; overload;

function SdaDefaultWindowProc(hWnd: HWND; uMsg: UINT; wParam: WPARAM;
  lParam: LPARAM): LRESULT; stdcall;
function SdaDefaultDialogProc(hWnd: HWND; uMsg: UINT; wParam: WPARAM;
  lParam: LPARAM): BOOL; stdcall;

type
  TMsgDlgType = (mtWarning, mtError, mtInformation, mtConfirmation, mtCustom);
  TMsgDlgButtons = (mbOK, mbOKCancel, mbYesNo, mbYesNoCancel,
    mbAbortRetryIgnore, mbRetryCancel);

function SdaMessageDlg(const Text, Caption: string; DlgType: TMsgDlgType;
  Buttons: TMsgDlgButtons; const IconResName: string = '';
  IconModule: HINST = 0; HelpId: Integer = 0): Integer;
procedure SdaShowMessage(const Message: string; const Caption: string = 'SDA Framework');

implementation

function SdaMessageDlg(const Text, Caption: string; DlgType: TMsgDlgType;
  Buttons: TMsgDlgButtons; const IconResName: string;
  IconModule: HINST; HelpId: Integer): Integer;
const
  MsgTypes: array [TMsgDlgType] of UINT = (MB_ICONWARNING, MB_ICONERROR,
    MB_ICONINFORMATION, MB_ICONQUESTION, MB_USERICON);
  MsgBtns: array [TMsgDlgButtons] of UINT = (MB_OK, MB_OKCANCEL, MB_YESNO,
    MB_YESNOCANCEL, MB_ABORTRETRYIGNORE, MB_RETRYCANCEL);
var
  MsgPrms: TMsgBoxParams;
begin
  FillChar(MsgPrms, SizeOf(MsgPrms), 0);
  MsgPrms.dwStyle := MsgTypes[DlgType] or MsgBtns[Buttons] or MB_TASKMODAL;
  MsgPrms.lpszText := PChar(Text);
  MsgPrms.lpszCaption := PChar(Caption);
  MsgPrms.dwLanguageId := MAKELANGID(LANG_NEUTRAL, SUBLANG_NEUTRAL);
  if IconResName <> '' then
  begin
    MsgPrms.lpszIcon := PChar(IconResName);
    MsgPrms.hInstance := IconModule;
    if MsgPrms.hInstance = 0 then
      MsgPrms.hInstance := HInstance;
  end;
  MsgPrms.dwContextHelpId := HelpId;
  Result := Integer(MessageBoxIndirect(MsgPrms));
end;

procedure SdaShowMessage(const Message: string; const Caption: string);
begin
  MessageBox(0, PChar(Message), PChar(Caption), MB_OK or MB_TASKMODAL);
end;

type
  TSdaCreateWndContext = record
    SdaObject: TObject;
    UserData: Pointer;
  end;
  PSdaCreateWndContext = ^TSdaCreateWndContext;

function SdaDefaultWindowProc(hWnd: HWND; uMsg: UINT; wParam: WPARAM;
  lParam: LPARAM): LRESULT;
begin
  Result := DefWindowProc(hWnd, uMsg, wParam, lParam);
end;

function SdaDefaultDialogProc(hWnd: HWND; uMsg: UINT; wParam: WPARAM;
  lParam: LPARAM): BOOL;
begin
  Result := FALSE; // Default handle for message
end;

{ При створенні вікна в WM_NCCREATE передається вказівник на структуру
  TSdaCreateWndContext, яка містить інформацію про прикріплений об'єкт, а
  також додаткові дані; при диспечеризації WM_NCCREATE треба використовувати
  саме вказівник на додаткові дані
}
function SdaWindowProc(hWnd: HWND; uMsg: UINT; wParam: WPARAM;
  lParam: LPARAM): LRESULT; stdcall;
var
  Message: TMessage;
  sdaObj: TObject;
  lpcs: PCreateStruct absolute lParam;
begin
  { Спеціальні повідомлення SDA завжди диспечеризуються напряму, і ніколи не потрапляють
    в віконну процедуру. Якщо потрапило - це означає, що його відправили з іншого
    потоку чи навіть програми; щоб попередити нестабільну роботу, просто ігноруємо
    його. Вийнятки: SDAM_DESTROYWINDOW
  }
  if uMsg = SDAM_DESTROYWINDOW then
  begin
    DestroyWindow(hWnd);
    Exit(0);
  end;
  if uMsg >= SDAM_BASE then Exit(0);
  { Ініціалізація вікна: прикріпяємо об'єкт до вікна. На відміну від
    звичайного для Windows порядку створення вікна, перше повідомлення, яке
    отримає об'єкт, буде SDAM_SETWNDHANDLE - воно необхідно щоб об'єкт
    отримав свій дескриптор ще до того, як отримає перше повідомлення
    Windows
  }
  if uMsg = WM_NCCREATE then
  begin
    if lpcs.lpCreateParams <> nil then
      with PSdaCreateWndContext(lpcs.lpCreateParams)^ do
      begin
        SdaSetAssociatedObject(hWnd, SdaObject);
        if Assigned(SdaObject) then
        begin
          Message.Msg := SDAM_SETWNDHANDLE;
          Message.WParam := hWnd;
          Message.LParam := 0;
          Message.Result := 0;
          SdaObject.Dispatch(Message);
        end;
      end;
    lParam := Windows.LPARAM(PSdaCreateWndContext(lpcs.lpCreateParams).UserData);
  end;

  sdaObj := SdaGetAssociatedObject(hWnd);
  if Assigned(sdaObj) then
  begin
    Message.Msg := uMsg;
    Message.WParam := wParam;
    Message.LParam := lParam;
    Message.Result := 0;
    SdaObj.Dispatch(Message);
    Result := Message.Result;
    if uMsg = WM_NCDESTROY then
    begin
      SdaSetAssociatedObject(hWnd, nil);
      { Спочатку замінюємо віконну процедуру на стандартну - це гарантує, що
        ніякі повідомлення не будуть оброблені після знищення об'єкта
      }
      SetWindowLong(hWnd, GWL_WNDPROC, Integer(@SdaDefaultWindowProc));
      sdaObj.Free;
    end;
  end else
  begin
    Result := SdaDefaultWindowProc(hWnd, uMsg, wParam, lParam);
  end;
end;

function SdaDialogProc(hWnd: HWND; uMsg: UINT; wParam: WPARAM;
  lParam: LPARAM): BOOL; stdcall;
var
  Message: TMessage;
  sdaObj: TObject;
  lpcs: PSdaCreateWndContext absolute lParam;
  MsgHandled: BOOL;
begin
  { Ініціалізуємо результат обробки повідомлення нулем
  }
  SetWindowLongPtr(hWnd, DWL_MSGRESULT, 0);
  { Спеціальні повідомлення SDA завжди диспечеризуються напряму, і ніколи не потрапляють
    в віконну процедуру. Якщо потрапило - це означає, що його відправили з іншого
    потоку чи навіть програми; щоб попередити нестабільну роботу, просто ігноруємо
    його. Вийнятки: SDAM_DESTROYWINDOW
  }
  if uMsg = SDAM_DESTROYWINDOW then
  begin
    DestroyWindow(hWnd);
    Exit(true);
  end;
  if uMsg >= SDAM_BASE then Exit(false);
  { Різниця між діалогом і звичайним вікном в тому, що першим повідомленням
    буде WM_INITDIALOG, і lParam - вказівником на TSdaCreateWndContext.
    Відповідно, при отриманні WM_INITDIALOG прикріпяємо об'єкт до вікна
    і відправляємо спочатку SDAM_SETWNDHANDLE, а потім і WM_INITDIALOG,
    попередньо замінивши значення lParam
  }
  if uMsg = WM_INITDIALOG then
  begin
    if lpcs <> nil then
    begin
      SdaSetAssociatedObject(hWnd, lpcs.SdaObject);
      if Assigned(lpcs.SdaObject) then
      begin
        Message.Msg := SDAM_SETWNDHANDLE;
        Message.WParam := hWnd;
        Message.LParam := 0;
        Message.Result := 0;
        lpcs.SdaObject.Dispatch(Message);
      end;
      lParam := Windows.LPARAM(lpcs.UserData);
    end;
  end;

  sdaObj := SdaGetAssociatedObject(hWnd);
  if Assigned(sdaObj) then
  begin
    Message.Msg := uMsg;
    Message.WParam := wParam;
    Message.LParam := lParam;
    Message.Result := 0;
    sdaObj.Dispatch(Message);

    if sdaObj is TSdaDialogObject then MsgHandled := TSdaDialogObject(sdaObj).DialogMessageHandled
      else MsgHandled := false;
    { Деякі з повідомлень повинні бути оброблені діалогом особливо (зокрема,
      різниця полягає в способі повернення результату). Коли SdaDialogProc
      виявляє такі повідомлення, вона повертає не TSdaDialogObject.MessageProcessed,
      а вирішує, що потрібно повернути: спеціальне значення чи FALSE.
      Для всіх інших повідомлень SdaDialogProc повертає TSdaDialogObject.MessageProcessed
    }
    case uMsg of
    { Спеціальні повідомлення - їх результат потрібно привести до INT_PTR
      або BOOL і повернути результатом функції; в інших випадках потрібно
      повертати TRUE і зберігати результат за допомогою SetWindowLongPtr(hwndDlg,
      DWL_MSGRESULT, lResult) (якщо потрібно) якщо повідомлення було оброблено чи
      FALSE що опрацювати повідомлення за замовчуванням
    }
    WM_CHARTOITEM, WM_COMPAREITEM, WM_CTLCOLORBTN, WM_CTLCOLORDLG,
    WM_CTLCOLOREDIT, WM_CTLCOLORLISTBOX, WM_CTLCOLORSCROLLBAR,
    WM_CTLCOLORSTATIC, WM_INITDIALOG, WM_QUERYDRAGICON, WM_VKEYTOITEM: begin
        if MsgHandled then Result := BOOL(Message.Result)
          else Result := false;
      end;
    else
      SetWindowLongPtr(hWnd, DWL_MSGRESULT, Message.Result);
      { Обробка повідомлень класом розпочинається з виклику TObject.Dispatch;
        TSdaDialogObject перекриває його щоб присвоїти FDialogMessageHandled TRUE,
        що означає що об'єкт швидше за все планує обробити повідомлення; після
        цього виконується метод-обробник повідомлення, і якщо воно потрапляє
        в DefaultHandler, FDialogMessageHandled змінюється на FALSE.
        TSdaDialogObject.DialogMessageHandled використовується для визначення,
        чи потрібно передавати повідомлення для стандартної обробки
      }
      Result := MsgHandled;
    end; { case }

    if uMsg = WM_NCDESTROY then
    begin
      SdaSetAssociatedObject(hWnd, nil);
      { Спочатку потрібно змінити діалогову (НЕ ВІКОННУ!!!) процедуру на стандартну,
        і тільки потім знищувати прикріплений об'єкт; це попередить роботу зі
        знищеними об'єктами: всі повідомлення будуть оброблені за замовчуванням
      }
      SetWindowLongPtr(hWnd, DWL_DLGPROC, Integer(@SdaDefaultDialogProc));
      sdaObj.Free;
    end;
  end else
  begin
    Result := SdaDefaultDialogProc(hWnd, uMsg, wParam, lParam);
  end;
end;

{ При реєстрації класу вікна додаємо додаткові байти для зберігання прикріпленого
  об'єкта, а також примусово змінюємо віконну процедуру
}
function SdaRegisterWindowClass(WndClass: TWndClassEx): Boolean;
begin
  WndClass.cbWndExtra := WndClass.cbWndExtra + SizeOf(Pointer);
  WndClass.lpfnWndProc := @SdaWindowProc;
  Result := RegisterClassEx(WndClass) <> 0;
end;

{ При реєстрації вікна до WNDCLASSEX.cbWndExtra додається SizeOf(Pointer) для
  зберігання посилання на прикріплений об'єкт; для діалогів при ініціалізації
  бібліотеки виводиться підклас, для якого поле WNDCLASSEX.cbWndExtra також
  збільшене на SizeOf(Pointer)
}
function SdaSetAssociatedObject(hWnd: HWND; const Obj: TObject): TObject;
var
  GWL_SDAOBJ: Integer;
begin
  GWL_SDAOBJ := GetClassLong(hWnd, GCL_CBWNDEXTRA) - SizeOf(Pointer);
  if GWL_SDAOBJ < 0 then Exit(nil);
  Result := TObject(SetWindowLongPtr(hWnd, GWL_SDAOBJ, NativeInt(Obj)));
end;

function SdaGetAssociatedObject(hWnd: HWND): TObject;
var
  GWL_SDAOBJ: Integer;
begin
  GWL_SDAOBJ := GetClassLong(hWnd, GCL_CBWNDEXTRA) - SizeOf(Pointer);
  if GWL_SDAOBJ < 0 then Exit(nil);
  Result := TObject(GetWindowLongPtr(hWnd, GWL_SDAOBJ));
end;

function SdaCreateWindow(dwExStyle: DWORD; lpClassName: PWideChar;
  lpWindowName: PWideChar; dwStyle: DWORD; X, Y, nWidth, nHeight: Integer;
  hWndParent: HWND; hMenu: HMENU; hInstance: HINST; lpParam: Pointer;
  sdaObjectClass: TSdaWindowObjectClass): HWND;
var
  data: TSdaCreateWndContext;
  sdaObject: TSdaBasicWindow;
begin
  if Assigned(sdaObjectClass) then sdaObject := sdaObjectClass.Create
    else sdaObject := nil;

  data.SdaObject := sdaObject;
  data.UserData := lpParam;
  Result := CreateWindowEx(dwExStyle, lpClassName, lpWindowName, dwStyle, X, Y,
    nWidth, nHeight, hWndParent, hMenu, hInstance, @data);

  if Result = 0 then
    sdaObject.Free;
end;

function SdaCreateDialog(hInstance: HINST; lpTemplateName: PWideChar;
  hWndParent: HWND; lpInitParam: Pointer;
  sdaObjectClass: TSdaWindowObjectClass): HWND;
var
  data: TSdaCreateWndContext;
  sdaObject: TSdaBasicWindow;
begin
  if Assigned(sdaObjectClass) then sdaObject := sdaObjectClass.Create
    else sdaObject := nil;

  data.SdaObject := sdaObject;
  data.UserData := lpInitParam;
  Result := CreateDialogParam(hInstance, lpTemplateName, hWndParent, @SdaDialogProc,
    LRESULT(@data));

  if Result = 0 then
    sdaObject.Free;
end;

function SdaCreateDialog(hInstance: HINST; const lpTemplate: TDlgTemplate;
  hWndParent: HWND; lpInitParam: Pointer;
  sdaObjectClass: TSdaWindowObjectClass): HWND;
var
  data: TSdaCreateWndContext;
  sdaObject: TSdaBasicWindow;
begin
  if Assigned(sdaObjectClass) then sdaObject := sdaObjectClass.Create
    else sdaObject := nil;

  data.SdaObject := sdaObject;
  data.UserData := lpInitParam;
  Result := CreateDialogIndirectParam(hInstance, lpTemplate, hWndParent, @SdaDialogProc,
    LRESULT(@data));

  if Result = 0 then
    sdaObject.Free;
end;

{ TSdaBasicWindow }

constructor TSdaBasicWindow.Create;
begin
  inherited Create;
end;

procedure TSdaBasicWindow.DefaultHandler(var Message);
begin
  with TMessage(Message) do
  begin
    if Msg >= $C000 then
    begin
      RegisteredMessage(TMessage(Message));
      Result := 0;
    end else Result := SdaDefaultWindowProc(Handle, Msg, WParam, LParam);
  end;
end;

procedure TSdaBasicWindow.DestroyHandle;
begin
  if IsWindow(Handle) then
    PostMessage(Handle, SDAM_DESTROYWINDOW, 0, 0);
end;

class function TSdaBasicWindow.WinClassName: string;
begin
  Result := ClassName;
  if Result <> '' then
    if UpCase(Result[1]) = 'T' then Delete(Result, 1, 1);
  Result := 'Sda.' + Result;
end;

class function TSdaBasicWindow.FillWndClass(
  var AWndClass: TWndClassEx): Boolean;
begin
  FillChar(AWndClass, SizeOf(AWndClass), 0);
  AWndClass.hbrBackground := COLOR_BTNFACE + 1;
  AWndClass.hCursor := LoadCursor(0, IDC_ARROW);
  Result := true;
end;

procedure TSdaBasicWindow.BeforeDestroyHandle;
begin
end;

class function TSdaBasicWindow.ClassRegistered: Boolean;
var
  WndClass: WNDCLASSEX;
begin
  Result := GetWindowClass(WndClass);
end;

class function TSdaBasicWindow.GetWindowClass(
  var AWndClass: TWndClassEx): Boolean;
begin
  AWndClass.cbSize := SizeOf(AWndClass);
  Result := GetClassInfoEx(HInstance, PChar(WinClassName), AWndClass);
end;

class function TSdaBasicWindow.RegisterClass: Boolean;
var
  WndClass: TWndClassEx;
begin
  if ClassRegistered then UnregisterClass;
  if FillWndClass(WndClass) then
  begin
    WndClass.cbSize := SizeOf(WndClass);
    WndClass.hInstance := HInstance;
    WndClass.lpszClassName := PChar(WinClassName);
    Result := Windows.RegisterClassEx(WndClass) <> 0;
  end else Result := false;
end;

procedure TSdaBasicWindow.RegisteredMessage(var Message: TMessage);
begin
  Message.Result := 0;
end;

class function TSdaBasicWindow.UnregisterClass: Boolean;
begin
  Result := Windows.UnregisterClass(PChar(WinClassName), HInstance);
end;

procedure TSdaBasicWindow.SDASetWndHandle(var Message: TMessage);
begin
  FHandle := Message.WParam;
  Message.Result := 0;
end;

function TSdaBasicWindow.StyleChanging(OldStyle: DWORD; var NewStyle: DWORD;
  ExStyle: Boolean): Boolean;
begin
  Result := true;
end;

function TSdaBasicWindow.SysCommandEvent(EventCode: Integer;
  Param: LPARAM): Boolean;
begin
  Result := false;
end;

procedure TSdaBasicWindow.WMCommand(var Message: TWMCommand);
begin
  if (Message.NotifyCode = 0) and (Message.Ctl = 0) then
  begin
    { Menu };
    inherited;
  end else
  if (Message.NotifyCode = 1) and (Message.Ctl = 0) then
  begin
    { Accelerator, Message.Ctl = 0 };
    inherited;
  end else
  begin
    { Control, Message.Ctl = Control identifier }
    if CommandEvent(Message.ItemID, Message.NotifyCode) then Message.Result := 0
      else Message.Result := -1;
  end;
end;

procedure TSdaBasicWindow.WMHotKey(var Message: TWMHotKey);
begin
  HotKeyEvent(Message.HotKey);
end;

procedure TSdaBasicWindow.WMNCDestroy(var Message: TWMNCDestroy);
begin
  BeforeDestroyHandle;
  inherited;
end;

procedure TSdaBasicWindow.WMPaint(var Message: TWMPaint);
var ps: TPaintStruct;
begin
  if Message.DC = 0 then BeginPaint(Handle, ps) else ps.hdc := Message.DC;
  if ps.hdc <> 0 then
  try
    PaintEvent(ps.hdc);
    Message.Result := Integer(true);
  finally
    if Message.DC = 0 then EndPaint(Handle, ps);
  end;
end;

procedure TSdaBasicWindow.WMStyleChanging(var Message: TWMStyleChanging);
begin
  if not StyleChanging(Message.StyleStruct.styleOld, Message.StyleStruct.styleNew,
    Message.StyleType = GWL_EXSTYLE) then
    Message.StyleStruct.styleNew := Message.StyleStruct.styleOld;
  Message.Result := 0;
end;

procedure TSdaBasicWindow.WMSysCommand(var Message: TWMSysCommand);
begin
  if SysCommandEvent(Message.CmdType, TMessage(Message).LParam) then Message.Result := 0
    else Message.Result := -1;
end;

procedure TSdaBasicWindow.WMTimer(var Message: TWMTimer);
begin
  TimerEvent(Message.TimerID);
  Message.Result := 0;
end;

function TSdaBasicWindow.CommandEvent(ItemID, EventCode: Integer): Boolean;
begin
  Result := false;
end;

procedure TSdaBasicWindow.PaintEvent(DC: HDC);
begin
end;

procedure TSdaBasicWindow.TimerEvent(TimerID: Integer);
begin
end;

procedure TSdaBasicWindow.HotKeyEvent(HotKeyID: Integer);
begin
end;

{ TSdaWindowObject }

class function TSdaWindowObject.CreateHandle(const ACaption: string;
  AStyle, AExStyle: DWORD; ALeft, ATop, AWidth, AHeight: Integer;
  AWndParent: HWND; AInstance: HINST; AMenu: HMENU; AParam: Pointer): HWND;
begin
  Result := SdaCreateWindow(AExStyle, PChar(WinClassName), PChar(ACaption), AStyle,
    ALeft, ATop, AWidth, AHeight, AWndParent, AMenu, AInstance, AParam, Self);
end;

{ TSdaDialogObject }

class function TSdaDialogObject.WinClassName: string;
begin
  Result := '#' + IntToStr(ATOM(WC_DIALOG));
end;

class function TSdaDialogObject.FillWndClass(var AWndClass: TWndClassEx): Boolean;
begin
  Result := false;
end;

procedure TSdaDialogObject.Dispatch(var Message);
begin
  DialogMessageHandled := true;
  inherited Dispatch(Message);
end;

procedure TSdaDialogObject.DefaultHandler(var Message);
begin
  if TMessage(Message).Msg >= $C000 then
  begin
    RegisteredMessage(TMessage(Message));
    DialogMessageHandled := true;
  end else
  begin
    TMessage(Message).Result := 0;
    DialogMessageHandled := false;
  end;
end;

procedure TSdaDialogObject.WMCommand(var Message: TWMCommand);
begin
  inherited;
  DialogMessageHandled := Message.Result = 0;
end;

procedure TSdaDialogObject.WMInitDialog(var Message: TWMInitDialog);
begin
  Message.Result := LRESULT(InitDialog(Message.Focus));
end;

procedure TSdaDialogObject.WMSysCommand(var Message: TWMSysCommand);
begin
  inherited;
  DialogMessageHandled := Message.Result = 0;
end;

function TSdaDialogObject.InitDialog(AFocusControl: HWND): Boolean;
begin
  Result := true;
end;

class function TSdaDialogObject.CreateHandle(const ATemplateName: string;
  AWndParent: HWND; AInstance: HINST; AParam: Pointer): HWND;
begin
  if AInstance = 0 then AInstance := HInstance;
  Result := SdaCreateDialog(AInstance, PChar(ATemplateName), AWndParent,
    AParam, Self);
end;

class function TSdaDialogObject.CreateHandle(const ATemplateId: Integer;
  AWndParent: HWND; AInstance: HINST; AParam: Pointer): HWND;
begin
  if AInstance = 0 then AInstance := HInstance;
  Result := SdaCreateDialog(AInstance, PChar(ATemplateId and $ffff), AWndParent,
    AParam, Self);
end;

class function TSdaDialogObject.CreateHandle(const ATemplate: DLGTEMPLATE;
  AWndParent: HWND; AParam: Pointer): HWND;
begin
  Result := SdaCreateDialog(HInstance, ATemplate, AWndParent, AParam, Self);
end;

procedure SdaHookSysDialogClass;
var
  WndClass: TWndClassEx;
begin
  FillChar(WndClass, SizeOf(WndClass), 0);
  WndClass.cbSize := SizeOf(WndClass);
  if GetClassInfoEx(HInstance, WC_DIALOG, WndClass) then
  begin
    if WndClass.cbWndExtra = DLGWINDOWEXTRA then
    begin
      WndClass.cbWndExtra := WndClass.cbWndExtra + SizeOf(Pointer);
      RegisterClassEx(WndClass);
    end;
  end;
end;

initialization
  SdaHookSysDialogClass;
end.
