unit sdaWinUtil;

interface

{$INCLUDE 'sda.inc'}

uses
  Windows, Messages;

const
  SDAM_BASE = WM_APP + $3000;
  SDAM_SETWNDHANDLE = SDAM_BASE + 1;

type
  TSdaWindowObject = class(TObject)
  strict private
    FHandle: HWND;
    procedure SDASetWndHandle(var Message: TMessage); message SDAM_SETWNDHANDLE;
  strict protected
    property Handle: HWND read FHandle write FHandle;
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

  TSdaWindowObjectClass = class of TSdaWindowObject;

  TSdaDialogObject = class(TSdaWindowObject)
  strict private
    FDialogMessageHandled: Boolean;
  protected
    property DialogMessageHandled: Boolean read FDialogMessageHandled
      write FDialogMessageHandled;
  public
    class function WinClassName: string; override;
    class function FillWndClass(var AWndClass: TWndClassEx): Boolean; override;

    procedure Dispatch(var Message); override;
    procedure DefaultHandler(var Message); override;
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

{ TSdaWindowObject }

constructor TSdaWindowObject.Create;
begin
  inherited Create;
end;

procedure TSdaWindowObject.DefaultHandler(var Message);
begin
  with TMessage(Message) do
    Result := SdaDefaultWindowProc(Handle, Msg, WParam, LParam);
end;

procedure TSdaWindowObject.SDASetWndHandle(var Message: TMessage);
begin
  FHandle := Message.WParam;
  Message.Result := 0;
end;

class function TSdaWindowObject.WinClassName: string;
begin
  Result := ClassName;
  if Result <> '' then
    if UpCase(Result[1]) = 'T' then Delete(Result, 1, 1);
  Result := 'Sda.' + Result;
end;

class function TSdaWindowObject.FillWndClass(
  var AWndClass: TWndClassEx): Boolean;
begin
  FillChar(AWndClass, SizeOf(AWndClass), 0);
  AWndClass.hbrBackground := COLOR_BTNFACE + 1;
  AWndClass.hCursor := LoadCursor(0, IDC_ARROW);
  Result := true;
end;

class function TSdaWindowObject.ClassRegistered: Boolean;
var
  WndClass: WNDCLASSEX;
begin
  Result := GetWindowClass(WndClass);
end;

class function TSdaWindowObject.GetWindowClass(
  var AWndClass: TWndClassEx): Boolean;
begin
  AWndClass.cbSize := SizeOf(AWndClass);
  Result := GetClassInfoEx(HInstance, PChar(WinClassName), AWndClass);
end;

class function TSdaWindowObject.RegisterClass: Boolean;
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

class function TSdaWindowObject.UnregisterClass: Boolean;
begin
  Result := Windows.UnregisterClass(PChar(WinClassName), HInstance);
end;

{ TSdaDialogObject }

procedure TSdaDialogObject.DefaultHandler(var Message);
begin
  TMessage(Message).Result := 0;
  DialogMessageHandled := false;
end;

procedure TSdaDialogObject.Dispatch(var Message);
begin
  DialogMessageHandled := true;
  inherited Dispatch(Message);
end;

class function TSdaDialogObject.FillWndClass(
  var AWndClass: TWndClassEx): Boolean;
begin
  Result := false;
end;

class function TSdaDialogObject.WinClassName: string;
const
  MagicDlgClass = '#32770'; // 'Magic' value - dialog's window class by default
var
  hgbl: HGLOBAL;
  lpdt: PDlgTemplate;
  h: HWND;
  Buf: array [Byte] of Char;
begin
  hgbl := GlobalAlloc(GMEM_FIXED or GMEM_ZEROINIT, 1024);
  if hgbl = 0 then Exit(MagicDlgClass);
  try
    lpdt := PDlgTemplate(GlobalLock(hgbl));
    if lpdt = nil then Exit(MagicDlgClass);
    try
      h := CreateDialogIndirect(HInstance, lpdt^, 0, nil);
      if h = 0 then Exit(MagicDlgClass);
      try
        FillChar(Buf, SizeOf(Buf), 0);
        RealGetWindowClass(h, Buf, Length(Buf));
        Result := Buf;
      finally
        DestroyWindow(h);
      end;
    finally
      GlobalUnlock(hgbl);
    end;
  finally
    GlobalFree(hgbl);
  end;
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

{ ��� �������� ���� � WM_NCCREATE ���������� �������� �� ���������
  TSdaCreateWndContext, ��� ������ ���������� ��� ����������� ��'���, �
  ����� �������� ���; ��� �������������� WM_NCCREATE ����� ���������������
  ���� �������� �� �������� ���
}
function SdaWindowProc(hWnd: HWND; uMsg: UINT; wParam: WPARAM;
  lParam: LPARAM): LRESULT; stdcall;
var
  Message: TMessage;
  sdaObj: TObject;
  lpcs: PCreateStruct absolute lParam;
begin
  { ��������� ����������� SDA ������ ���������������� �������, � ����� �� �����������
    � ������ ���������. ���� ��������� - �� ������, �� ���� ��������� � ������
    ������ �� ����� ��������; ��� ���������� ���������� ������, ������ ��������
    ����.
  }
  if uMsg >= SDAM_BASE then Exit(0);
  { ����������� ����: ���������� ��'��� �� ����. �� ����� ��
    ���������� ��� Windows ������� ��������� ����, ����� �����������, ���
    ������ ��'���, ���� SDAM_SETWNDHANDLE - ���� ��������� ��� ��'���
    ������� ��� ���������� �� �� ����, �� ������ ����� �����������
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
      { �������� �������� ������ ��������� �� ���������� - �� �������, ��
        ��� ����������� �� ������ �������� ���� �������� ��'����
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
  { ���������� ��������� ������� ����������� �����
  }
  SetWindowLongPtr(hWnd, DWL_MSGRESULT, 0);
  { ��������� ����������� SDA ������ ���������������� �������, � ����� �� �����������
    � ������ ���������. ���� ��������� - �� ������, �� ���� ��������� � ������
    ������ �� ����� ��������; ��� ���������� ���������� ������, ������ ��������
    ����.
  }
  if uMsg >= SDAM_BASE then Exit(false);
  { г����� �� ������� � ��������� ����� � ����, �� ������ ������������
    ���� WM_INITDIALOG, � lParam - ���������� �� TSdaCreateWndContext.
    ³�������, ��� �������� WM_INITDIALOG ���������� ��'��� �� ����
    � ����������� �������� SDAM_SETWNDHANDLE, � ���� � WM_INITDIALOG,
    ���������� �������� �������� lParam
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
        if MsgHandled then Result := false
          else Result := BOOL(Message.Result);
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
      SetWindowLongPtr(hWnd, DWL_DLGPROC, Integer(@SdaDefaultDialogProc));
      sdaObj.Free;
    end;
  end else
  begin
    Result := SdaDefaultDialogProc(hWnd, uMsg, wParam, lParam);
  end;
end;

{ ��� ��������� ����� ���� ������ �������� ����� ��� ��������� ������������
  ��'����, � ����� ��������� ������� ������ ���������
}

function SdaRegisterWindowClass(WndClass: TWndClassEx): Boolean;
begin
  WndClass.cbWndExtra := WndClass.cbWndExtra + SizeOf(Pointer);
  WndClass.lpfnWndProc := @SdaWindowProc;
  Result := RegisterClassEx(WndClass) <> 0;
end;

{ ��� ��������� ���� �� WNDCLASSEX.cbWndExtra �������� SizeOf(Pointer) ���
  ��������� ��������� �� ����������� ��'���; ��� ������ ��� �����������
  �������� ���������� ������, ��� ����� ���� WNDCLASSEX.cbWndExtra �����
  �������� �� SizeOf(Pointer)
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
  sdaObject: TSdaWindowObject;
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
  sdaObject: TSdaWindowObject;
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
  sdaObject: TSdaWindowObject;
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

end.
