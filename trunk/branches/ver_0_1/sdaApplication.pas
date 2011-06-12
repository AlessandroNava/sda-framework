unit sdaApplication;

interface

{$INCLUDE 'sda.inc'}

uses
  Windows, Messages, sdaWinControl;

const
  WM_ENDMODAL = WM_APP + 1;

type
  TWMEndModal = record
    Msg: Cardinal;
    Unused: WPARAM;
    ModalResult: LPARAM;
    Result: LRESULT;
  end;

type
  TSdaApplication = class(TObject)
  strict private
    FModalLevel: Integer;
    FTerminated: Boolean;
    FHandle: HWND;
    function GetHandle: HWND;
    function GetTerminated: Boolean;
    procedure SetTerminated(const Value: Boolean);
    procedure SetHandle(const Value: HWND);
    function GetTitle: string;
  strict private
    function IsDialogMessage(var Message: TMsg): Boolean;
    procedure HandleApplicationMessage(var Message: TMsg);
  strict protected
    procedure Idle; virtual;
    function TryGetMessage(var Message: TMsg): Boolean; virtual;
    procedure DefDispatchMessage(var Message: TMsg); virtual;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    property Title: string read GetTitle;

    procedure Run;
    property Handle: HWND read GetHandle write SetHandle;
    property Terminated: Boolean read GetTerminated write SetTerminated;
    procedure Terminate;

    function BeginModal(Wnd: HWND): Integer;
    procedure EndModal(ModalResult: Integer);
    property ModalLevel: Integer read FModalLevel;

    procedure ShowMessage(const Message: string);
  end;

  TSdaApplicationClass = class of TSdaApplication;

threadvar
  Application: TSdaApplication;

procedure SdaApplicationInitialize(ApplicationClass: TSdaApplicationClass = nil);
procedure SdaApplicationFinalize;

implementation

procedure SdaApplicationInitialize(ApplicationClass: TSdaApplicationClass);
var
  NewApp: TSdaApplication;
begin
  if not Assigned(ApplicationClass) then
    ApplicationClass := TSdaApplication;
  NewApp := ApplicationClass.Create;
  NewApp := InterlockedExchangePointer(Pointer(Application), NewApp);
  if Assigned(NewApp) then
    NewApp.Free;
end;

procedure SdaApplicationFinalize;
var
  TempApp: TSdaApplication;
begin
  TempApp := InterlockedExchangePointer(Pointer(Application), nil);
  TempApp.Free;
end;

{ TSdaApplication }

constructor TSdaApplication.Create;
begin
  inherited Create;
end;

destructor TSdaApplication.Destroy;
begin
  if Handle <> 0 then
    DestroyWindow(Handle);
  inherited Destroy;
end;

procedure TSdaApplication.EndModal(ModalResult: Integer);
begin
  PostThreadMessage(GetCurrentThreadId, WM_ENDMODAL, 0, ModalResult);
end;

function TSdaApplication.IsDialogMessage(var Message: TMsg): Boolean;
var
  wnd: HWND;
begin
  wnd := GetForegroundWindow;
  if wnd = 0 then Exit(false);
  if GetWindowThreadProcessId(wnd, nil) <> GetCurrentThreadId then Result := false
    else Result := Windows.IsDialogMessage(wnd, Message);
end;

function TSdaApplication.TryGetMessage(var Message: TMsg): Boolean;
var
  Unicode: Boolean;
begin
  Result := false;
  while true do
  begin
    if PeekMessage(Message, 0, 0, 0, PM_NOREMOVE) then
    begin
      Unicode := (Message.hwnd = 0) or IsWindowUnicode(Message.hwnd);
      if Unicode then Result := PeekMessageW(Message, 0, 0, 0, PM_REMOVE)
                 else Result := PeekMessageA(Message, 0, 0, 0, PM_REMOVE);
      if Result then Break;
    end else
    begin
      Idle;
      if not WaitMessage then Exit(false);
    end;
  end;
end;

procedure TSdaApplication.DefDispatchMessage(var Message: TMsg);
var
  Unicode: Boolean;
begin
  if not IsDialogMessage(Message) then
  begin
    TranslateMessage(Message);
    Unicode := (Message.hwnd = 0) or IsWindowUnicode(Message.hwnd);
    if Unicode then Windows.DispatchMessageW(Message)
               else Windows.DispatchMessageA(Message);
  end;
end;

function TSdaApplication.BeginModal(Wnd: HWND): Integer;

type
  PModalList = ^TModalList;
  TModalList = record
    Next: PModalList;
    Wnd: HWND;
  end;

  TModalState = record
    Wnd: HWND;
    FgWnd: HWND;
    First: PModalList;
  end;
  PModalState = ^TModalState;

  function EnumThreadWndProc(hWnd: HWND; lParam: PModalState): BOOL; stdcall;
  var
    List: PModalList;
  begin
    if (hWnd <> lParam.Wnd) and IsWindowEnabled(hWnd) and IsWindowVisible(hWnd) then
    begin
      New(List);
      List.Wnd := hWnd;
      List.Next := lParam.First;
      lParam.First := List;
      EnableWindow(hWnd, false);
    end;
    Result := true;
  end;

  function StoreModalState(Wnd: HWND): PModalState;
  begin
    New(Result);
    Result.Wnd := Wnd;
    Result.FgWnd := GetForegroundWindow;
    EnumThreadWindows(GetCurrentThreadId, @EnumThreadWndProc, Integer(Result));
  end;

  procedure RestoreModalState(State: PModalState);
  var
    Temp: PModalList;
  begin
    while State.First <> nil do
    begin
      Temp := State.First;
      State.First := Temp.Next;
      EnableWindow(Temp.Wnd, true);
      Dispose(Temp);
    end;
    SetForegroundWindow(State.FgWnd);
    Dispose(State);
  end;

var
  Message: TMsg;
  ModalState: PModalState;
begin
  Result := 0;
  ModalState := StoreModalState(Wnd);
  InterlockedIncrement(FModalLevel);
  ShowWindow(Wnd, SW_SHOWNORMAL);
  try
    while not Terminated do
    begin
      if not IsWindow(Handle) then Terminate;

      if TryGetMessage(Message) then
      begin
        if Message.message <> WM_QUIT then
        begin
          if Message.hwnd = 0 then
          begin
            if Message.message = WM_ENDMODAL then
            begin
              Result := Message.lParam; // ModalResult of TWMEndModal
              Break;
            end else HandleApplicationMessage(Message)
          end else DefDispatchMessage(Message);
        end else Terminate;
      end else Terminate;
    end;
  finally
    ShowWindow(Wnd, SW_HIDE);
    InterlockedDecrement(FModalLevel);
    RestoreModalState(ModalState);
  end;
end;

procedure TSdaApplication.Run;
var
  Message: TMsg;
begin
  ShowWindow(Handle, SW_SHOWNORMAL);
  try
    while not Terminated do
    begin
      if not IsWindow(Handle) then Terminate;

      if TryGetMessage(Message) then
      begin
        if Message.message <> WM_QUIT then
        begin
          if Message.hwnd = 0 then HandleApplicationMessage(Message)
            else DefDispatchMessage(Message);
        end else Terminate;
      end else Terminate;
    end;
  finally
    ShowWindow(Handle, SW_HIDE);
  end;
end;

function TSdaApplication.GetHandle: HWND;
begin
  Result := FHandle;
end;

procedure TSdaApplication.SetHandle(const Value: HWND);
begin
  FHandle := Value;
end;

procedure TSdaApplication.SetTerminated(const Value: Boolean);
begin
  FTerminated := Value;
end;

procedure TSdaApplication.ShowMessage(const Message: string);
begin
  MessageBox(Handle, PChar(Message), PChar(Title),
    MB_OK or MB_ICONINFORMATION or MB_TASKMODAL);
end;

function TSdaApplication.GetTerminated: Boolean;
begin
  Result := FTerminated;
end;

function TSdaApplication.GetTitle: string;
var
  i: Integer;
begin
  i := GetWindowTextLength(Handle);
  if i > 0 then
  begin
    SetLength(Result, i + 1);
    i := GetWindowText(Handle, PChar(Result), Length(Result));
    SetLength(Result, i);
  end else Result := '';
  if Result = '' then
  begin
    Result := ParamStr(0);
    i := Length(Result);
    while i >= 1 do
      if (Result[i] = '/') or (Result[i] = '\') then Break
        else Dec(i);
    Delete(Result, 1, i);
    if Result = '' then Result := 'Application';
  end;
end;

procedure TSdaApplication.HandleApplicationMessage(var Message: TMsg);
var
  Msg: TMessage;
begin
  Msg.Msg := Message.message;
  Msg.WParam := Message.wParam;
  Msg.LParam := Message.lParam;
  Msg.Result := 0;
  Dispatch(Msg);
end;

procedure TSdaApplication.Terminate;
begin
  Terminated := true;
end;

procedure TSdaApplication.Idle;
begin
end;

end.
