unit sdaDialogCreate;

interface

{$INCLUDE 'sda.inc'}

uses
  sdaSystem, sdaWindows, sdaMessages;

type
  TSdaDialogObject = class(TObject)
  private
    FHandle: HWND;
    FDialogMessageHandled: Boolean;
    procedure WMNCDestroy(var Message: TWMNCDestroy); message WM_NCDESTROY;
    procedure WMCommand(var Message: TWMCommand); message WM_COMMAND;
    procedure WMMenuCommand(var Message: TWMMenuCommand); message WM_MENUCOMMAND;
    procedure WMSysCommand(var Message: TWMSysCommand); message WM_SYSCOMMAND;
    procedure WMInitDialog(var Message: TWMInitDialog); message WM_INITDIALOG;
  protected
    property Handle: HWND read FHandle write FHandle;
    procedure DestroyHandle;
    function InitDialog(AFocusControl: HWND): Boolean; virtual;
    function  CommandEvent(ItemID: Integer; EventCode: Integer): Boolean; virtual;
    function AccelEvent(AccelID: Integer): Boolean; virtual;
    { If Menu = 0 then ItemIdOrPosition is ID of item; otherwise, it is position
      of item in Menu menu }
    function MenuEvent(ItemIdOrPosition: Integer; Menu: HMENU): Boolean; virtual;
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

function SdaSetAssociatedObject(hWnd: HWND; const Obj: TObject): TObject; inline;
begin
  Result := TObject(SetWindowLongPtr(hWnd, DWL_USER, NativeInt(Obj)));
end;

function SdaGetAssociatedObject(hWnd: HWND): TObject; inline;
begin
  Result := TObject(GetWindowLongPtr(hWnd, DWL_USER));
end;

{ ��� �������� ���� � WM_NCCREATE ���������� �������� �� ���������
  TSdaCreateWndContext, ��� ������ ���������� ��� ����������� ��'���, �
  ����� �������� ���; ��� �������������� WM_NCCREATE ����� ���������������
  ���� �������� �� �������� ���
}
function SdaDialogProc(hWnd: HWND; uMsg: UINT; wParam: WPARAM;
  lParam: LPARAM): BOOL; stdcall;
var
  Message: TMessage;
  sdaObj: TObject;
  lpcs: PSdaCreateWndContext absolute lParam;
  MsgHandled: BOOL;
begin
  { ���������� ��������� ������� ����������� �����
  }
  SetWindowLongPtr(hWnd, DWL_MSGRESULT, 0);
  if uMsg = SDAM_DESTROYWINDOW then
  begin
    DestroyWindow(hWnd);
    Exit(true);
  end;
  { г����� �� ������� � ��������� ����� � ����, �� ������ ������������
    ���� WM_INITDIALOG, � lParam - ���������� �� TSdaCreateWndContext.
    ³�������, ��� �������� WM_INITDIALOG ���������� ��'��� �� ����,
    ������������ �������� Handle, � ���� ����������� WM_INITDIALOG,
    ���������� �������� �������� lParam
  }
  if uMsg = WM_INITDIALOG then
  begin
    if lpcs <> nil then
    begin
      SdaSetAssociatedObject(hWnd, lpcs.SdaObject);
      if Assigned(lpcs.SdaObject) then
        if lpcs.SdaObject is TSdaDialogObject then
          TSdaDialogObject(lpcs.SdaObject).Handle := hWnd;
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
    { ���� � ���������� ������ ���� �������� ������� �������� (�������,
      ������ ������ � ������ ���������� ����������). ���� SdaDialogProc
      ������� ��� �����������, ���� ������� �� TSdaDialogObject.MessageProcessed,
      � �����, �� ������� ���������: ���������� �������� �� FALSE.
      ��� ��� ����� ���������� SdaDialogProc ������� TSdaDialogObject.MessageProcessed
    }
    case uMsg of
    { ��������� ����������� - �� ��������� ������� �������� �� INT_PTR
      ��� BOOL � ��������� ����������� �������; � ����� �������� �������
      ��������� TRUE � �������� ��������� �� ��������� SetWindowLongPtr(hwndDlg,
      DWL_MSGRESULT, lResult) (���� �������) ���� ����������� ���� ��������� ��
      FALSE �� ���������� ����������� �� �������������
    }
    WM_CHARTOITEM, WM_COMPAREITEM, WM_CTLCOLORBTN, WM_CTLCOLORDLG,
    WM_CTLCOLOREDIT, WM_CTLCOLORLISTBOX, WM_CTLCOLORSCROLLBAR,
    WM_CTLCOLORSTATIC, WM_INITDIALOG, WM_QUERYDRAGICON, WM_VKEYTOITEM: begin
        if MsgHandled then Result := BOOL(Message.Result)
          else Result := false;
      end;
    else
      SetWindowLongPtr(hWnd, DWL_MSGRESULT, Message.Result);
      { ������� ���������� ������ ������������� � ������� TObject.Dispatch;
        TSdaDialogObject ��������� ���� ��� �������� FDialogMessageHandled TRUE,
        �� ������ �� ��'��� ������ �� ��� ����� �������� �����������; ����
        ����� ���������� �����-�������� �����������, � ���� ���� ���������
        � DefaultHandler, FDialogMessageHandled ��������� �� FALSE.
        TSdaDialogObject.DialogMessageHandled ��������������� ��� ����������,
        �� ������� ���������� ����������� ��� ���������� �������
      }
      Result := MsgHandled;
    end; { case }

    if uMsg = WM_NCDESTROY then
    begin
      SdaSetAssociatedObject(hWnd, nil);
      { �������� ������� ������ �������� (�� ²�����!!!) ��������� �� ����������,
        � ����� ���� ��������� ����������� ��'���; �� ���������� ������ �
        ��������� ��'������: �� ����������� ������ �������� �� �������������
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

procedure TSdaDialogObject.WMNCDestroy(var Message: TWMNCDestroy);
begin
  BeforeDestroyHandle;
  inherited;
end;

procedure TSdaDialogObject.WMCommand(var Message: TWMCommand);
var
  Handled: Boolean;
begin
  if (Message.NotifyCode = 0) and (Message.Ctl = 0) then
  begin
    { Menu }
    Handled := MenuEvent(Message.ItemID, 0);
  end else
  if (Message.NotifyCode = 1) and (Message.Ctl = 0) then
  begin
    { Accelerator, Message.Ctl = 0 }
    Handled := AccelEvent(Message.ItemID);
  end else
  begin
    { Control, Message.Ctl = Control identifier }
    Handled := CommandEvent(Message.ItemID, Message.NotifyCode);
  end;
  if Handled then Message.Result := 0
    else Message.Result := -1;
  DialogMessageHandled := Message.Result = 0;
end;

procedure TSdaDialogObject.WMInitDialog(var Message: TWMInitDialog);
begin
  Message.Result := LRESULT(InitDialog(Message.Focus));
end;

procedure TSdaDialogObject.WMMenuCommand(var Message: TWMMenuCommand);
begin
  MenuEvent(Message.ItemPos, Message.Menu);
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

function TSdaDialogObject.AccelEvent(AccelID: Integer): Boolean;
begin
  Result := false;
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

function TSdaDialogObject.MenuEvent(ItemIdOrPosition: Integer;
  Menu: HMENU): Boolean;
begin
  Result := false;
end;

end.
