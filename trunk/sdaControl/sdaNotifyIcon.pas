unit sdaNotifyIcon;

interface

{$INCLUDE 'sda.inc'}

uses
  sdaWindows, sdaMessages, ShellAPI;

type
  TNotifyIconDataExW = record
    cbSize: DWORD;
    hWnd: HWND;
    uID: UINT;
    uFlags: UINT;
    uCallbackMessage: UINT;
    hIcon: HICON;
    szTip: array [0..127] of WideChar;  // Previously 64 chars, now 128
    dwState: DWORD;
    dwStateMask: DWORD;
    szInfo: array [0..255] of WideChar;
    TimeoutOrVersion: record
      case Integer of          // 0: Before Win2000; 1: Win2000 and up
        0: (uTimeout: UINT);
        1: (uVersion: UINT);   // Only used when sending a NIM_SETVERSION message
      end;
    szInfoTitle: array [0..63] of WideChar;
    dwInfoFlags: DWORD;
{$IFDEF _WIN32_IE_600}
    guidItem: TGUID;  // Reserved for WinXP; define _WIN32_IE_600 if needed
{$ENDIF}
  end;

  TNotifyIconDataEx = TNotifyIconDataExW;

  TBalloonHintIcon = (
    BalloonNone = NIIF_NONE,
    BalloonInfo = NIIF_INFO,
    BalloonWarning = NIIF_WARNING,
    BalloonError = NIIF_ERROR,
    BalloonCustom = NIIF_USER
  );
  TBalloonHintTimeOut = 10..60;   // Windows defines 10-60 secs. as min-max

const
  // Key select events (Space and Enter)
  NIN_SELECT           = WM_USER + 0;
  NIN_KEYSELECT        = WM_USER + 1;
  // Events returned by balloon hint
  NIN_BALLOONSHOW      = WM_USER + 2;
  NIN_BALLOONHIDE      = WM_USER + 3;
  NIN_BALLOONTIMEOUT   = WM_USER + 4;
  NIN_BALLOONUSERCLICK = WM_USER + 5;

type
  TSdaNotifyIcon = {$IFDEF FPC}object{$ELSE}record{$ENDIF}
  private
    FIconData: TNotifyIconDataEx;
    function UpdateIcon(NotifyIconMessage: DWORD; AddFlags,
      RemoveFlags: DWORD): Boolean;
    function GetID: UINT;
    function GetWindow: HWND;
    procedure SetID(const Value: UINT);
    procedure SetWindow(const Value: HWND);
    function GetMessage: UINT;
    procedure SetMessage(const Value: UINT);
    function GetIcon: HICON;
    procedure SetIcon(const Value: HICON);
    function GetHint: string;
    procedure SetHint(const Value: string);
  public
    property Window: HWND read GetWindow write SetWindow;
    property ID: UINT read GetID write SetID;
    property Message: UINT read GetMessage write SetMessage;
    property Icon: HICON read GetIcon write SetIcon;
    property Hint: string read GetHint write SetHint;

    function ShowIcon: Boolean;
    function HideIcon: Boolean;

    function ShowBalloonHint(Title, Text: String; IconType: TBalloonHintIcon;
      TimeoutSecs: TBalloonHintTimeOut): Boolean;
    function HideBaloonHint: Boolean;
  end;

var
  WM_TASKBARCREATED: UINT;

implementation

uses
  SdaSysUtils;

const
  // Constants used for balloon hint feature
  NIIF_NONE            = $00000000;
  NIIF_INFO            = $00000001;
  NIIF_WARNING         = $00000002;
  NIIF_ERROR           = $00000003;
  NIIF_USER            = $00000004;
  NIIF_ICON_MASK       = $0000000F;    // Reserved for WinXP
  NIIF_NOSOUND         = $00000010;    // Reserved for WinXP
  // uFlags constants for TNotifyIconDataEx
  NIF_STATE            = $00000008;
  NIF_INFO             = $00000010;
  NIF_GUID             = $00000020;
  // dwMessage constants for Shell_NotifyIcon
  NIM_SETFOCUS         = $00000003;
  NIM_SETVERSION       = $00000004;
  NOTIFYICON_VERSION   = 3;            // Used with the NIM_SETVERSION message

{ TSdaNotifyIcon }

function TSdaNotifyIcon.UpdateIcon(NotifyIconMessage: DWORD;
  AddFlags, RemoveFlags: DWORD): Boolean;
begin
  FIconData.cbSize := SizeOf(FIconData);
  FIconData.uFlags := (FIconData.uFlags and not RemoveFlags) or AddFlags;
  Result := Shell_NotifyIcon(NotifyIconMessage, @FIconData);
end;

function TSdaNotifyIcon.GetHint: string;
begin
  Result := FIconData.szTip;
end;

function TSdaNotifyIcon.GetIcon: HICON;
begin
  Result := FIconData.hIcon;
end;

function TSdaNotifyIcon.GetID: UINT;
begin
  Result := FIconData.uID;
end;

function TSdaNotifyIcon.GetMessage: UINT;
begin
  Result := FIconData.uCallbackMessage;
end;

function TSdaNotifyIcon.GetWindow: HWND;
begin
  Result := FIconData.hWnd;
end;

procedure TSdaNotifyIcon.SetHint(const Value: string);
begin
  FillChar(FIconData.szTip, SizeOf(FIconData.szTip), 0);
  StrLCopy(FIconData.szTip, PChar(Value), Length(FIconData.szTip));
end;

procedure TSdaNotifyIcon.SetIcon(const Value: HICON);
begin
  FIconData.hIcon := Value;
end;

procedure TSdaNotifyIcon.SetID(const Value: UINT);
begin
  FIconData.uID := Value;
end;

procedure TSdaNotifyIcon.SetMessage(const Value: UINT);
begin
  FIconData.uCallbackMessage := Value;
end;

procedure TSdaNotifyIcon.SetWindow(const Value: HWND);
begin
  FIconData.hWnd := Value;
end;

function TSdaNotifyIcon.ShowBalloonHint(Title, Text: String;
  IconType: TBalloonHintIcon; TimeoutSecs: TBalloonHintTimeOut): Boolean;
begin
  with FIconData do
  begin
    uFlags := uFlags or NIF_INFO;
    FillChar(szInfo, SizeOf(szInfo), 0);
    StrLCopy(szInfo, PChar(Text), Length(szInfo) - 1);
    FillChar(szInfoTitle, SizeOf(szInfoTitle), 0);
    StrLCopy(szInfoTitle, PChar(Title), Length(szInfoTitle) - 1);
    TimeoutOrVersion.uTimeout := TimeoutSecs * 1000;
    dwInfoFlags := DWORD(IconType);
  end;
  Result := UpdateIcon(NIM_MODIFY, NIF_INFO, 0);
end;

function TSdaNotifyIcon.ShowIcon: Boolean;
begin
  Result := UpdateIcon(NIM_ADD, NIF_MESSAGE or NIF_ICON or NIF_TIP, 0);
end;

function TSdaNotifyIcon.HideBaloonHint: Boolean;
begin
  FillChar(FIconData.szInfo, SizeOf(FIconData.szInfo), 0);
  Result := UpdateIcon(NIM_MODIFY, NIF_INFO, 0);
end;

function TSdaNotifyIcon.HideIcon: Boolean;
begin
  Result := UpdateIcon(NIM_DELETE, 0, 0);
end;

initialization
  WM_TASKBARCREATED := RegisterWindowMessage('TaskbarCreated');
end.
