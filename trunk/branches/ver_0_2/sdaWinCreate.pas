unit sdaWinCreate;

{$INCLUDE 'sda.inc'}

interface

uses
  Windows, Messages, sdaWinUtil;

type
  TSdaBaseWindow = class(TSdaWindowObject)
  strict private
    procedure WMTimer(var Message: TWMTimer); message WM_TIMER;
    procedure WMCommand(var Message: TWMCommand); message WM_COMMAND;
    procedure WMHotKey(var Message: TWMHotKey); message WM_HOTKEY;
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
  strict protected
    procedure TimerEvent(TimerID: Integer); virtual;
    function  CommandEvent(ItemID: Integer; EventCode: Integer): Boolean; virtual;
    procedure HotKeyEvent(HotKeyID: Integer); virtual;
    procedure PaintEvent(DC: HDC); virtual;
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

  TSdaWindowObjectClass = class of TSdaWindowObject;

  TSdaBaseDialog = class(TSdaDialogObject)
  strict private
    procedure WMTimer(var Message: TWMTimer); message WM_TIMER;
    procedure WMCommand(var Message: TWMCommand); message WM_COMMAND;
    procedure WMHotKey(var Message: TWMHotKey); message WM_HOTKEY;
    procedure WMPaint(var Message: TWMPaint); message WM_PAINT;
    procedure WMInitDialog(var Message: TWMInitDialog); message WM_INITDIALOG;
  strict protected
    procedure TimerEvent(TimerID: Integer); virtual;
    function CommandEvent(ItemID: Integer; EventCode: Integer): Boolean; virtual;
    procedure HotKeyEvent(HotKeyID: Integer); virtual;
    procedure PaintEvent(DC: HDC); virtual;
    function InitDialog(AFocusControl: HWND): Boolean; virtual;
  public
    class function CreateHandle(const ATemplateName: string;
      AWndParent: HWND = 0; AInstance: HINST = 0;
      AParam: Pointer = nil): HWND; overload; virtual;
    class function CreateHandle(const ATemplateId: Integer;
      AWndParent: HWND = 0; AInstance: HINST = 0;
      AParam: Pointer = nil): HWND; overload; virtual;
    class function CreateHandle(const ATemplate: DLGTEMPLATE;
      AWndParent: HWND = 0; AParam: Pointer = nil): HWND; overload; virtual;
  end;

implementation

{ TSdaWindowObject }

class function TSdaBaseWindow.CreateHandle(const ACaption: string;
  AStyle, AExStyle: DWORD; ALeft, ATop, AWidth, AHeight: Integer;
  AWndParent: HWND; AInstance: HINST; AMenu: HMENU; AParam: Pointer): HWND;
begin
  Result := SdaCreateWindow(AExStyle, PChar(WinClassName), PChar(ACaption), AStyle,
    ALeft, ATop, AWidth, AHeight, AWndParent, AMenu, AInstance, AParam, Self);
end;

procedure TSdaBaseWindow.WMCommand(var Message: TWMCommand);
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

procedure TSdaBaseWindow.WMHotKey(var Message: TWMHotKey);
begin
  HotKeyEvent(Message.HotKey);
end;

procedure TSdaBaseWindow.WMPaint(var Message: TWMPaint);
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

procedure TSdaBaseWindow.WMTimer(var Message: TWMTimer);
begin
  TimerEvent(Message.TimerID);
  Message.Result := 0;
end;

function TSdaBaseWindow.CommandEvent(ItemID, EventCode: Integer): Boolean;
begin
  Result := false;
end;

procedure TSdaBaseWindow.PaintEvent(DC: HDC);
begin
end;

procedure TSdaBaseWindow.TimerEvent(TimerID: Integer);
begin
end;

procedure TSdaBaseWindow.HotKeyEvent(HotKeyID: Integer);
begin
end;

{ TSdaDialogObject }

class function TSdaBaseDialog.CreateHandle(const ATemplateName: string;
  AWndParent: HWND; AInstance: HINST; AParam: Pointer): HWND;
begin
  if AInstance = 0 then AInstance := HInstance;
  Result := SdaCreateDialog(AInstance, PChar(ATemplateName), AWndParent,
    AParam, Self);
end;

class function TSdaBaseDialog.CreateHandle(const ATemplateId: Integer;
  AWndParent: HWND; AInstance: HINST; AParam: Pointer): HWND;
begin
  if AInstance = 0 then AInstance := HInstance;
  Result := SdaCreateDialog(AInstance, PChar(ATemplateId and $ffff), AWndParent,
    AParam, Self);
end;

class function TSdaBaseDialog.CreateHandle(const ATemplate: DLGTEMPLATE;
  AWndParent: HWND; AParam: Pointer): HWND;
begin
  Result := SdaCreateDialog(HInstance, ATemplate, AWndParent, AParam, Self);
end;

procedure TSdaBaseDialog.WMCommand(var Message: TWMCommand);
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
      DialogMessageHandled := false;
    end;
  end;
end;

procedure TSdaBaseDialog.WMHotKey(var Message: TWMHotKey);
begin
  HotKeyEvent(Message.HotKey);
end;

procedure TSdaBaseDialog.WMInitDialog(var Message: TWMInitDialog);
begin
  Message.Result := Integer(InitDialog(Message.Focus));
end;

procedure TSdaBaseDialog.WMPaint(var Message: TWMPaint);
var
  ps: TPaintStruct;
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

procedure TSdaBaseDialog.WMTimer(var Message: TWMTimer);
begin
  TimerEvent(Message.TimerID);
  Message.Result := 0;
end;

function TSdaBaseDialog.CommandEvent(ItemID, EventCode: Integer): Boolean;
begin
  Result := false;
end;

procedure TSdaBaseDialog.HotKeyEvent(HotKeyID: Integer);
begin
end;

function TSdaBaseDialog.InitDialog(AFocusControl: HWND): Boolean;
begin
  Result := true;
end;

procedure TSdaBaseDialog.PaintEvent(DC: HDC);
begin
end;

procedure TSdaBaseDialog.TimerEvent(TimerID: Integer);
begin
end;

end.
