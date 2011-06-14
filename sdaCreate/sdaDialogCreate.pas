unit sdaDialogCreate;

interface

{$INCLUDE 'sda.inc'}

uses
  sdaWindows, sdaMessages, sdaSysUtils;

const
  SDAM_BASE = WM_APP + $3000;
  SDAM_SETWNDHANDLE = SDAM_BASE + 1;
  SDAM_DESTROYWINDOW = SDAM_BASE + 2;
  
type
  TSdaDialogObject = class(TObject)
  strict private
    FHandle: HWND;
    FDialogMessageHandled: Boolean;
    procedure SDASetWndHandle(var Message: TMessage); message SDAM_SETWNDHANDLE;
    procedure WMNCDestroy(var Message: TWMNCDestroy); message WM_NCDESTROY;
    procedure WMCommand(var Message: TWMCommand); message WM_COMMAND;
    procedure WMSysCommand(var Message: TWMSysCommand); message WM_SYSCOMMAND;
    procedure WMInitDialog(var Message: TWMInitDialog); message WM_INITDIALOG;
  strict protected
    property Handle: HWND read FHandle write FHandle;
    procedure DestroyHandle;
    function InitDialog(AFocusControl: HWND): Boolean; virtual;
    function  CommandEvent(ItemID: Integer; EventCode: Integer): Boolean; virtual;
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
  protected
    property DialogMessageHandled: Boolean read FDialogMessageHandled
      write FDialogMessageHandled;
  public
    constructor Create; virtual;
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

  TSdaDialogObjectClass = class of TSdaDialogObject;

function SdaCreateDialog(hInstance: HINST; lpTemplateName: PWideChar;
  hWndParent: HWND; lpInitParam: Pointer;
  sdaObjectClass: TSdaDialogObjectClass): HWND; overload;
function SdaCreateDialog(hInstance: HINST; const lpTemplate: TDlgTemplate;
  hWndParent: HWND; lpInitParam: Pointer;
  sdaObjectClass: TSdaDialogObjectClass): HWND; overload;

implementation

type
  TSdaCreateWndContext = record
    SdaObject: TObject;
    UserData: Pointer;
  end;
  PSdaCreateWndContext = ^TSdaCreateWndContext;

{ При реєстрації вікна до WNDCLASSEX.cbWndExtra додається SizeOf(Pointer) для
  зберігання посилання на прикріплений об'єкт; для діалогів при ініціалізації
  бібліотеки виводиться підклас, для якого поле WNDCLASSEX.cbWndExtra також
  збільшене на SizeOf(Pointer)
}
function SdaSetAssociatedObject(hWnd: HWND; const Obj: TObject): TObject;
var
  GWL_SDAOBJ: Integer;
begin
  GWL_SDAOBJ := GetClassLongPtr(hWnd, GCL_CBWNDEXTRA) - SizeOf(Pointer);
  if GWL_SDAOBJ < 0 then Exit(nil);
  Result := TObject(SetWindowLongPtr(hWnd, GWL_SDAOBJ, NativeInt(Obj)));
end;

function SdaGetAssociatedObject(hWnd: HWND): TObject;
var
  GWL_SDAOBJ: Integer;
begin
  GWL_SDAOBJ := GetClassLongPtr(hWnd, GCL_CBWNDEXTRA) - SizeOf(Pointer);
  if GWL_SDAOBJ < 0 then Exit(nil);
  Result := TObject(GetWindowLongPtr(hWnd, GWL_SDAOBJ));
end;

function SdaCreateAssociatedObject(hWnd: HWND): TObject;
var
  sdaClass: TSdaDialogObjectClass;
  cbCls: Integer;
begin
  if hWnd = 0 then Exit(nil);
  cbCls := GetClassLongPtr(hWnd, GCL_CBCLSEXTRA);
  if cbCls < SizeOf(Pointer) then Exit(nil);
  Dec(cbCls, SizeOf(Pointer));
  sdaClass := Pointer(GetClassLongPtr(hWnd, cbCls));
  if not Assigned(sdaClass) then Exit(nil);
  Result := sdaClass.Create;
  SdaSetAssociatedObject(hWnd, Result);
end;

{ При створенні вікна в WM_NCCREATE передається вказівник на структуру
  TSdaCreateWndContext, яка містить інформацію про прикріплений об'єкт, а
  також додаткові дані; при диспечеризації WM_NCCREATE треба використовувати
  саме вказівник на додаткові дані
}
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
      lParam := sdaWindows.LPARAM(lpcs.UserData);
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
      SetWindowLongPtr(hWnd, DWL_DLGPROC, NativeInt(nil));
      sdaObj.Free;
    end;
  end else Result := false;
end;

function SdaCreateDialog(hInstance: HINST; lpTemplateName: PWideChar;
  hWndParent: HWND; lpInitParam: Pointer;
  sdaObjectClass: TSdaDialogObjectClass): HWND;
var
  data: TSdaCreateWndContext;
  sdaObject: TSdaDialogObject;
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
  sdaObjectClass: TSdaDialogObjectClass): HWND;
var
  data: TSdaCreateWndContext;
  sdaObject: TSdaDialogObject;
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

{ TSdaDialogObject }

constructor TSdaDialogObject.Create;
begin
  inherited Create;
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

procedure TSdaDialogObject.SDASetWndHandle(var Message: TMessage);
begin
  FHandle := Message.WParam;
  Message.Result := 0;
end;

procedure TSdaDialogObject.WMNCDestroy(var Message: TWMNCDestroy);
begin
  BeforeDestroyHandle;
  inherited;
end;

procedure TSdaDialogObject.WMCommand(var Message: TWMCommand);
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
  DialogMessageHandled := Message.Result = 0;
end;

procedure TSdaDialogObject.WMInitDialog(var Message: TWMInitDialog);
begin
  Message.Result := LRESULT(InitDialog(Message.Focus));
end;

procedure TSdaDialogObject.WMSysCommand(var Message: TWMSysCommand);
begin
  if SysCommandEvent(Message.CmdType, TMessage(Message).LParam) then Message.Result := 0
    else Message.Result := -1;
  DialogMessageHandled := Message.Result = 0;
end;

procedure TSdaDialogObject.DestroyHandle;
begin
  if IsWindow(Handle) then
    PostMessage(Handle, SDAM_DESTROYWINDOW, 0, 0);
end;

procedure TSdaDialogObject.BeforeDestroyHandle;
begin
end;

procedure TSdaDialogObject.RegisteredMessage(var Message: TMessage);
begin
  Message.Result := 0;
end;

function TSdaDialogObject.SysCommandEvent(EventCode: Integer;
  Param: LPARAM): Boolean;
begin
  Result := false;
end;

function TSdaDialogObject.CommandEvent(ItemID, EventCode: Integer): Boolean;
begin
  Result := false;
end;

function TSdaDialogObject.InitDialog(AFocusControl: HWND): Boolean;
begin
  Result := true;
end;

procedure SdaRegisterDialogClass;
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
      WndClass.lpszClassName := 'Sda.Dialog';
      RegisterClassEx(WndClass);
    end;
  end;
end;

initialization
  SdaRegisterDialogClass;
end.
