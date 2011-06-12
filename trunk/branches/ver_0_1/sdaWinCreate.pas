unit sdaWinCreate;

{$INCLUDE 'sda.inc'}

interface

uses
  Windows, Messages;

type
  TSdaWindowClass = class(TObject)
  strict private
    class function WindowProc(hWnd: HWND; uMsg: UINT; wParam: WPARAM;
      lParam: LPARAM): LRESULT; stdcall; static;
  public
    { Never create instances of this class and all its descedants directly -
      it may cause unpredictable behaviour
    }
    constructor Create(AHandle: HWND); virtual;

    class function WinClassName: string; virtual;
    class function FillWndClass(var AWndClassEx: WNDCLASSEX): Boolean; virtual;

    class function RegisterClass: Boolean;
    class function UnregisterClass: Boolean;
    class function GetWindowClass(var AWndClassEx: WNDCLASSEX): Boolean;
    class function ClassRegistered: Boolean;
  end;

  TSdaWindowObject = class(TSdaWindowClass)
  strict private
    procedure WMTimer(var Message: TWMTimer); message WM_TIMER;
    procedure WMCommand(var Message: TWMCommand); message WM_COMMAND;
    procedure WMHotKey(var Message: TWMHotKey); message WM_HOTKEY;
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
  strict protected
    FHandle: HWND;

    procedure TimerEvent(TimerID: Integer); virtual;
    function  CommandEvent(ItemID: Integer; EventCode: Integer): Boolean; virtual;
    procedure HotKeyEvent(HotKeyID: Integer); virtual;
    procedure PaintEvent(DC: HDC); virtual;
  public
    constructor Create(AHandle: HWND); override;

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

    property Handle: HWND read FHandle;

    procedure DefaultHandler(var Message); override;
  end;

  TSdaWindowObjectClass = class of TSdaWindowObject;

  TSdaDialogObject = class(TObject)
  strict private
    FDialogMessageHandled: Boolean;
    class function DialogProc(hWnd: HWND; uMsg: UINT; wParam: WPARAM;
      lParam: LPARAM): BOOL; stdcall; static;
  strict private
    procedure WMTimer(var Message: TWMTimer); message WM_TIMER;
    procedure WMCommand(var Message: TWMCommand); message WM_COMMAND;
    procedure WMHotKey(var Message: TWMHotKey); message WM_HOTKEY;
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
    procedure WMInitDialog(var Message: TWMInitDialog); message WM_INITDIALOG;
  strict protected
    FHandle: HWND;
    procedure DialogMessageHandled(AHandled: Boolean = true);

    procedure TimerEvent(TimerID: Integer); virtual;
    function CommandEvent(ItemID: Integer; EventCode: Integer): Boolean; virtual;
    procedure HotKeyEvent(HotKeyID: Integer); virtual;
    procedure PaintEvent(DC: HDC); virtual;
    function InitDialog(AFocusControl: HWND): Boolean; virtual;
  public
    { Never create instances of this class and all its descedants directly -
      it may cause unpredictable behaviour
    }
    constructor Create(AHandle: HWND); virtual;

    class function CreateHandle(const ATemplateName: string;
      AWndParent: HWND = 0; AInstance: HINST = 0): HWND; overload; virtual;
    class function CreateHandle(const ATemplateId: Integer;
      AWndParent: HWND = 0; AInstance: HINST = 0): HWND; overload; virtual;
    class function CreateHandle(const ATemplate: DLGTEMPLATE;
      AWndParent: HWND = 0): HWND; overload; virtual;

    property Handle: HWND read FHandle;

    procedure Dispatch(var Message); override;
    procedure DefaultHandler(var Message); override;
  end;

  TSdaDialogObjectClass = class of TSdaDialogObject;

implementation

procedure FreeAndNil(var Obj);
var
  Temp: TObject;
begin
  Temp := TObject(Obj);
  Pointer(Obj) := nil;
  Temp.Free;
end;

const
  SDAWL_CLASSREF = 0;

const
  sSDAAssociatedObjectProp = 'WndPROP_SDA_Associated_Object';

function SdaDefaultWindowProc(hWnd: HWND; uMsg: UINT; wParam: WPARAM;
  lParam: LPARAM): LRESULT; stdcall;
begin
  Result := DefWindowProc(hWnd, uMsg, wParam, lParam);
end;

function SdaDefaultDialogProc(hWnd: HWND; uMsg: UINT; wParam: WPARAM;
  lParam: LPARAM): BOOL; stdcall;
begin
  Result := FALSE; // Default handle for message
end;

class function TSdaWindowClass.WindowProc(hWnd: HWND; uMsg: UINT; wParam: WPARAM;
  lParam: LPARAM): LRESULT; stdcall;
var
  Message: TMessage;
  sdaObj: TObject;
  sdaClass: TSdaWindowObjectClass;
begin
  try
    sdaObj := TObject(GetProp(hWnd, sSDAAssociatedObjectProp));
    if not Assigned(sdaObj) then
    begin
      sdaClass := TSdaWindowObjectClass(GetClassLong(hWnd, SDAWL_CLASSREF));
      if Assigned(sdaClass) then
      begin
        sdaObj := sdaClass.Create(hWnd);
        SetProp(hWnd, sSDAAssociatedObjectProp, DWORD(sdaObj));
      end;
    end;
    if Assigned(sdaObj) and (sdaObj is TSdaWindowObject) then
    begin
      Message.Msg := uMsg;
      Message.WParam := wParam;
      Message.LParam := lParam;
      Message.Result := 0;
      TSdaWindowObject(sdaObj).Dispatch(Message);
      Result := Message.Result;
      if uMsg = WM_NCDESTROY then
      begin
        SetProp(hWnd, sSDAAssociatedObjectProp, 0);
        { Firstly we need to change window procedure to default, and only after
          then destroy associated object - to prevent access to destroyed objects:
          all messages passed to this window will be handled by-default, so there
          will not be any manipulations with Delphi classes' instances
        }
        SetWindowLong(hWnd, GWL_WNDPROC, Integer(@SdaDefaultWindowProc));
        FreeAndNil(sdaObj);
      end;
    end else
    begin
      Result := SdaDefaultWindowProc(hWnd, uMsg, wParam, lParam);
    end;
  except
    Result := SdaDefaultWindowProc(hWnd, uMsg, wParam, lParam);
  end;
end;

class function TSdaDialogObject.DialogProc(hWnd: HWND; uMsg: UINT; wParam: WPARAM;
  lParam: LPARAM): BOOL; stdcall;
var
  Message: TMessage;
  sdaObj: TObject;
  sdaClass: TSdaDialogObjectClass;
begin
  try
    sdaObj := TObject(GetProp(hWnd, sSDAAssociatedObjectProp));
    if not Assigned(sdaObj) then
    begin
      { The first message received by dialog is WM_INITDIALOG, and the last one
        is WM_NCDESTROY - dialog window is destroyed by DesroyWindow call and
        dialog class' window procedure pass WM_NCDESTROY to dialog procedure
      }
      if uMsg = WM_INITDIALOG then
      begin
        sdaClass := TSdaDialogObjectClass(lParam);
        if Assigned(sdaClass) then
        begin
          sdaObj := sdaClass.Create(hWnd);
          SetProp(hWnd, sSDAAssociatedObjectProp, DWORD(sdaObj));
          lParam := 0;
        end;
      end;
    end;
    if Assigned(sdaObj) and (sdaObj is TSdaDialogObject) then
    begin
      Message.Msg := uMsg;
      Message.WParam := wParam;
      Message.LParam := lParam;
      Message.Result := 0;
      TSdaDialogObject(sdaObj).Dispatch(Message);
      { There are list of messages that are processed in special way (exactly,
        difference is in returning result from them). When SdaDialogProc detects
        these messages, it does not return TSdaDialogObject.FMessageProcessed
        directly, but analyze it and then decides when to return special value
        or FALSE. For all other messages SdaDialogProc simply returns
        TSdaDialogObject.FMessageProcessed
      }
      case uMsg of
      { Special messages for Dialogs - their results must be cast to INT_PTR
        or BOOL and be returned directly; in other cases, dialog proc must
        return TRUE and store message result by calling SetWindowLong(hwndDlg,
        DWL_MSGRESULT, lResult) (if needed) if it processed message, or
        FALSE to process message using default dialog procedure
      }
      WM_CHARTOITEM, WM_COMPAREITEM, WM_CTLCOLORBTN, WM_CTLCOLORDLG,
      WM_CTLCOLOREDIT, WM_CTLCOLORLISTBOX, WM_CTLCOLORSCROLLBAR,
      WM_CTLCOLORSTATIC, WM_INITDIALOG, WM_QUERYDRAGICON, WM_VKEYTOITEM: begin
          if TSdaDialogObject(sdaObj).FDialogMessageHandled then Result := false
            else Result := BOOL(Message.Result);
        end;
      else
        SetWindowLong(hWnd, DWL_MSGRESULT, Message.Result);
        { Processing message by class begins with TObject.Dispatch; TSdaDialogObject
          overrides it to set FDialogMessageHandled to TRUE, that means that
          object probably will fully process current message; than message is
          dispatching, and when it leaves to DefaultHandler, the last one sets
          FDialogMessageHandled to FALSE, and message is passed to default
          dialog procedure. TSdaDialogObject.DialogMessageHandled is used to
          directly rule of processing message
        }
        Result := TSdaDialogObject(sdaObj).FDialogMessageHandled;
      end; { case }

      if uMsg = WM_NCDESTROY then
      begin
        SetProp(hWnd, sSDAAssociatedObjectProp, 0);
        { Firstly we need to change Dialog (NOT WINDOW!!!) procedure to default,
          and only after then destroy associated object - to prevent access to
          destroyed objects: all messages passed to this window will be handled
          by-default, so there will not be any manipulations with Delphi classes'
          instances
        }
        SetWindowLong(hWnd, DWL_DLGPROC, Integer(@SdaDefaultDialogProc));
        FreeAndNil(sdaObj);
      end;
    end else
    begin
      Result := SdaDefaultDialogProc(hWnd, uMsg, wParam, lParam);
    end;
  except
    Result := SdaDefaultDialogProc(hWnd, uMsg, wParam, lParam);
  end;
end;

{ TSdaWindowClass }

constructor TSdaWindowClass.Create(AHandle: HWND);
begin
  inherited Create;
end;

class function TSdaWindowClass.WinClassName: string;
begin
  Result := 'Sda.' + ClassName;
end;

class function TSdaWindowClass.GetWindowClass(
  var AWndClassEx: WNDCLASSEX): Boolean;
begin
  AWndClassEx.cbSize := SizeOf(AWndClassEx);
  Result := GetClassInfoEx(HInstance, PChar(WinClassName), AWndClassEx);
end;

class function TSdaWindowClass.ClassRegistered: Boolean;
var
  WndClass: WNDCLASSEX;
begin
  Result := GetWindowClass(WndClass);
end;

class function TSdaWindowClass.FillWndClass(var AWndClassEx: WNDCLASSEX): Boolean;
begin
  FillChar(AWndClassEx, SizeOf(AWndClassEx), 0);
  AWndClassEx.hbrBackground := COLOR_BTNFACE + 1;
  AWndClassEx.hCursor := LoadCursor(0, IDC_ARROW);
  Result := true;
end;

class function TSdaWindowClass.RegisterClass: Boolean;
var
  WndClass: WNDCLASSEX;
  hDummy: HWND;
begin
  if ClassRegistered then UnregisterClass;
  if FillWndClass(WndClass) then
  begin
    WndClass.cbSize := SizeOf(WndClass);
    WndClass.lpfnWndProc := @DefWindowProc;
    WndClass.cbClsExtra := SizeOf(Pointer);
    WndClass.hInstance := HInstance;
    WndClass.lpszClassName := PChar(WinClassName);
    Result := Windows.RegisterClassEx(WndClass) <> 0;
    if Result then
    begin
      hDummy := CreateWindowEx(0, WndClass.lpszClassName, nil, WS_OVERLAPPED,
        0, 0, 0, 0, 0, 0, HInstance, nil);
      if hDummy = 0 then Exit(false);
      SetClassLong(hDummy, SDAWL_CLASSREF, Integer(Self));
      SetClassLong(hDummy, GCL_WNDPROC, Integer(@WindowProc));
      DestroyWindow(hDummy);
    end;
  end else
  begin
    SetLastError(0);
    Result := false;
  end;
end;

class function TSdaWindowClass.UnregisterClass: Boolean;
begin
  Result := Windows.UnregisterClass(PChar(WinClassName), HInstance);
end;

{ TSdaWindowObject }

constructor TSdaWindowObject.Create(AHandle: HWND);
begin
  inherited Create(AHandle);
  FHandle := AHandle;
end;

procedure TSdaWindowObject.DefaultHandler(var Message);
begin
  with TMessage(Message) do
    Result := DefWindowProc(FHandle, Msg, WParam, LParam);
end;

class function TSdaWindowObject.CreateHandle(const ACaption: string;
  AStyle, AExStyle: DWORD; ALeft, ATop, AWidth, AHeight: Integer;
  AWndParent: HWND; AInstance: HINST; AMenu: HMENU; AParam: Pointer): HWND;
begin
  Result := CreateWindowEx(AExStyle, PChar(WinClassName), PChar(ACaption), AStyle,
    ALeft, ATop, AWidth, AHeight, AWndParent, AMenu, AInstance, AParam);
end;

// -----------------------------------------------------------------------------

procedure TSdaWindowObject.WMCommand(var Message: TWMCommand);
begin
  if (Message.NotifyCode = 0) and (Message.Ctl = 0) then
  begin
    { Menu };
  end else
  if (Message.NotifyCode = 1) and (Message.Ctl = 0) then
  begin
    { Accelerator, Message.Ctl = 0 };
  end else
  begin
    { Control, Message.Ctl = Control identifier }
    if CommandEvent(Message.ItemID, Message.NotifyCode) then Message.Result := 0
      else Message.Result := -1;
  end;
end;

procedure TSdaWindowObject.WMHotKey(var Message: TWMHotKey);
begin
  HotKeyEvent(Message.HotKey);
end;

procedure TSdaWindowObject.WMPaint(var Message: TWMPaint);
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

procedure TSdaWindowObject.WMTimer(var Message: TWMTimer);
begin
  TimerEvent(Message.TimerID);
  Message.Result := 0;
end;

function TSdaWindowObject.CommandEvent(ItemID, EventCode: Integer): Boolean;
begin
  Result := false;
end;

procedure TSdaWindowObject.PaintEvent(DC: HDC);
begin
end;

procedure TSdaWindowObject.TimerEvent(TimerID: Integer);
begin
end;

procedure TSdaWindowObject.HotKeyEvent(HotKeyID: Integer);
begin
end;

{ TSdaDialogObject }

constructor TSdaDialogObject.Create(AHandle: HWND);
begin
  inherited Create;
  FHandle := AHandle;
end;

class function TSdaDialogObject.CreateHandle(const ATemplateName: string;
  AWndParent: HWND; AInstance: HINST): HWND;
begin
  if AInstance = 0 then AInstance := HInstance;
  Result := CreateDialogParam(AInstance, PChar(ATemplateName), AWndParent,
    @DialogProc, Integer(Self));
end;

class function TSdaDialogObject.CreateHandle(const ATemplateId: Integer;
  AWndParent: HWND; AInstance: HINST): HWND;
begin
  if AInstance = 0 then AInstance := HInstance;
  Result := CreateDialogParam(AInstance, PChar(ATemplateId and $ffff), AWndParent,
    @DialogProc, Integer(Self));
end;

class function TSdaDialogObject.CreateHandle(const ATemplate: DLGTEMPLATE;
  AWndParent: HWND): HWND;
begin
  Result := CreateDialogIndirectParam(HInstance, ATemplate, AWndParent,
    @DialogProc, Integer(Self));
end;

procedure TSdaDialogObject.Dispatch(var Message);
begin
  FDialogMessageHandled := true;
  inherited Dispatch(Message);
end;

procedure TSdaDialogObject.DefaultHandler(var Message);
begin
  TMessage(Message).Result := 0;
  FDialogMessageHandled := false;
end;

procedure TSdaDialogObject.DialogMessageHandled(AHandled: Boolean);
begin
  FDialogMessageHandled := AHandled;
end;

// -----------------------------------------------------------------------------

procedure TSdaDialogObject.WMCommand(var Message: TWMCommand);
begin
  if (Message.NotifyCode = 0) and (Message.Ctl = 0) then
  begin
    { Menu };
  end else
  if (Message.NotifyCode = 1) and (Message.Ctl = 0) then
  begin
    { Accelerator, Message.Ctl = 0 };
  end else
  begin
    { Control, Message.Ctl = Control identifier }
    if CommandEvent(Message.ItemID, Message.NotifyCode) then Message.Result := 0 else
    begin
      Message.Result := -1;
      DialogMessageHandled(false);
    end;
  end;
end;

procedure TSdaDialogObject.WMHotKey(var Message: TWMHotKey);
begin
  HotKeyEvent(Message.HotKey);
end;

procedure TSdaDialogObject.WMInitDialog(var Message: TWMInitDialog);
begin
  Message.Result := Integer(InitDialog(Message.Focus));
end;

procedure TSdaDialogObject.WMPaint(var Message: TWMPaint);
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

procedure TSdaDialogObject.WMTimer(var Message: TWMTimer);
begin
  TimerEvent(Message.TimerID);
  Message.Result := 0;
end;

function TSdaDialogObject.CommandEvent(ItemID, EventCode: Integer): Boolean;
begin
  Result := false;
end;

procedure TSdaDialogObject.HotKeyEvent(HotKeyID: Integer);
begin
end;

function TSdaDialogObject.InitDialog(AFocusControl: HWND): Boolean;
begin
  Result := true;
end;

procedure TSdaDialogObject.PaintEvent(DC: HDC);
begin
end;

procedure TSdaDialogObject.TimerEvent(TimerID: Integer);
begin
end;

end.
