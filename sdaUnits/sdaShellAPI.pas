unit sdaShellAPI;

interface

{$INCLUDE 'sda.inc'}

uses sdaWindows;

// WinAPI header uses byte alignment.
{$A1}

type
  HDROP = THandle;
  PPWideChar = ^PWideChar;

function DragQueryFile(Drop: HDROP; FileIndex: UINT; FileName: PWideChar; cb: UINT): UINT; stdcall;
function DragQueryFileA(Drop: HDROP; FileIndex: UINT; FileName: PAnsiChar; cb: UINT): UINT; stdcall;
function DragQueryFileW(Drop: HDROP; FileIndex: UINT; FileName: PWideChar; cb: UINT): UINT; stdcall;
function DragQueryPoint(Drop: HDROP; var Point: TPoint): BOOL; stdcall;
procedure DragFinish(Drop: HDROP); stdcall;
procedure DragAcceptFiles(Wnd: HWND; Accept: BOOL); stdcall;
function ShellExecute(hWnd: HWND; Operation, FileName, Parameters,
  Directory: PWideChar; ShowCmd: Integer): HINST; stdcall;
function ShellExecuteA(hWnd: HWND; Operation, FileName, Parameters,
  Directory: PAnsiChar; ShowCmd: Integer): HINST; stdcall;
function ShellExecuteW(hWnd: HWND; Operation, FileName, Parameters,
  Directory: PWideChar; ShowCmd: Integer): HINST; stdcall;
function FindExecutable(FileName, Directory: PWideChar; Result: PWideChar): HINST; stdcall;
function FindExecutableA(FileName, Directory: PAnsiChar; Result: PAnsiChar): HINST; stdcall;
function FindExecutableW(FileName, Directory: PWideChar; Result: PWideChar): HINST; stdcall;
function CommandLineToArgvW(lpCmdLine: LPCWSTR; var pNumArgs: Integer): PPWideChar; stdcall;
function ShellAbout(Wnd: HWND; szApp, szOtherStuff: PWideChar; Icon: HICON): Integer; stdcall;
function ShellAboutA(Wnd: HWND; szApp, szOtherStuff: PAnsiChar; Icon: HICON): Integer; stdcall;
function ShellAboutW(Wnd: HWND; szApp, szOtherStuff: PWideChar; Icon: HICON): Integer; stdcall;
function DuplicateIcon(hInst: HINST; Icon: HICON): HICON; stdcall;
function ExtractAssociatedIcon(hInst: HINST; lpIconPath: PWideChar;
  var lpiIcon: Word): HICON; stdcall;
function ExtractAssociatedIconA(hInst: HINST; lpIconPath: PAnsiChar;
  var lpiIcon: Word): HICON; stdcall;
function ExtractAssociatedIconW(hInst: HINST; lpIconPath: PWideChar;
  var lpiIcon: Word): HICON; stdcall;
function ExtractAssociatedIconEx(hInst: HINST;
  pszIconPath: PWideChar; var piIconIndex: WORD; var piIconID: WORD): HICON; stdcall;
function ExtractAssociatedIconExA(hInst: HINST;
  pszIconPath: PAnsiChar; var piIconIndex: WORD; var piIconID: WORD): HICON; stdcall;
function ExtractAssociatedIconExW(hInst: HINST;
  pszIconPath: PWideChar; var piIconIndex: WORD; var piIconID: WORD): HICON; stdcall;
function ExtractIcon(hInst: HINST; lpszExeFileName: PWideChar;
  nIconIndex: UINT): HICON; stdcall;
function ExtractIconA(hInst: HINST; lpszExeFileName: PAnsiChar;
  nIconIndex: UINT): HICON; stdcall;
function ExtractIconW(hInst: HINST; lpszExeFileName: PWideChar;
  nIconIndex: UINT): HICON; stdcall;

type
  PDragInfoA = ^_DRAGINFOA;
  PDragInfoW = ^_DRAGINFOW;
  PDragInfo = PDragInfoW;
  _DRAGINFOA = record
    uSize: UINT;                 { init with SizeOf(DRAGINFO) }
    pt: TPoint;
    fNC: BOOL;
    lpFileList: PAnsiChar;
    grfKeyState: DWORD;
  end;
  TDragInfoA = _DRAGINFOA;
  LPDRAGINFOA = PDragInfoA;
  _DRAGINFOW = record
    uSize: UINT;                 { init with SizeOf(DRAGINFO) }
    pt: TPoint;
    fNC: BOOL;
    lpFileList: PWideChar;
    grfKeyState: DWORD;
  end;
  TDragInfoW = _DRAGINFOW;
  LPDRAGINFOW = PDragInfoW;
  _DRAGINFO = _DRAGINFOW;

const
{ AppBar stuff }

  ABM_NEW           = $00000000;
  ABM_REMOVE        = $00000001;
  ABM_QUERYPOS      = $00000002;
  ABM_SETPOS        = $00000003;
  ABM_GETSTATE      = $00000004;
  ABM_GETTASKBARPOS = $00000005;
  ABM_ACTIVATE      = $00000006;  { lParam = True/False means activate/deactivate }
  ABM_GETAUTOHIDEBAR = $00000007;
  ABM_SETAUTOHIDEBAR = $00000008;  { this can fail at any time.  MUST check the result
                                     lParam = TRUE/FALSE  Set/Unset
                                     uEdge = what edge }
  ABM_WINDOWPOSCHANGED = $0000009;
  ABM_SETSTATE = $0000000a;

{ these are put in the wparam of callback messages }

  ABN_STATECHANGE    = $0000000;
  ABN_POSCHANGED     = $0000001;
  ABN_FULLSCREENAPP  = $0000002;
  ABN_WINDOWARRANGE  = $0000003; { lParam = True means hide }

{ flags for get state }

  ABS_AUTOHIDE    = $0000001;
  ABS_ALWAYSONTOP = $0000002;

  ABE_LEFT        = 0;
  ABE_TOP         = 1;
  ABE_RIGHT       = 2;
  ABE_BOTTOM      = 3;

type
  PAppBarData = ^TAppBarData;
  _AppBarData = record
    cbSize: DWORD;
    hWnd: HWND;
    uCallbackMessage: UINT;
    uEdge: UINT;
    rc: TRect;
    lParam: LPARAM; { message specific }
  end;
  TAppBarData = _AppBarData;
  APPBARDATA = _AppBarData;

function SHAppBarMessage(dwMessage: DWORD; var pData: TAppBarData): UINT; stdcall;
// //  EndAppBar

function DoEnvironmentSubst(szString: PWideChar; cbString: UINT): DWORD; stdcall;
function DoEnvironmentSubstA(szString: PAnsiChar; cbString: UINT): DWORD; stdcall;
function DoEnvironmentSubstW(szString: PWideChar; cbString: UINT): DWORD; stdcall;
function ExtractIconEx(lpszFile: PWideChar; nIconIndex: Integer;
  var phiconLarge, phiconSmall: HICON; nIcons: UINT): UINT; stdcall;
function ExtractIconExA(lpszFile: PAnsiChar; nIconIndex: Integer;
  var phiconLarge, phiconSmall: HICON; nIcons: UINT): UINT; stdcall;
function ExtractIconExW(lpszFile: PWideChar; nIconIndex: Integer;
  var phiconLarge, phiconSmall: HICON; nIcons: UINT): UINT; stdcall;


{ Shell File Operations }

const
  FO_MOVE           = $0001;
  FO_COPY           = $0002;
  FO_DELETE         = $0003;
  FO_RENAME         = $0004;

// SHFILEOPSTRUCT.fFlags and IFileOperation::SetOperationFlags() flag values
  FOF_MULTIDESTFILES         = $0001;
  FOF_CONFIRMMOUSE           = $0002;
  FOF_SILENT                 = $0004;  { don't create progress/report }
  FOF_RENAMEONCOLLISION      = $0008;
  FOF_NOCONFIRMATION         = $0010;  { Don't prompt the user. }
  FOF_WANTMAPPINGHANDLE      = $0020;  { Fill in SHFILEOPSTRUCT.hNameMappings
                                         Must be freed using SHFreeNameMappings }
  FOF_ALLOWUNDO              = $0040;
  FOF_FILESONLY              = $0080;  { on *.*, do only files }
  FOF_SIMPLEPROGRESS         = $0100;  { means don't show names of files }
  FOF_NOCONFIRMMKDIR         = $0200;  { don't confirm making any needed dirs }
  FOF_NOERRORUI              = $0400;  { don't put up error UI }
  FOF_NOCOPYSECURITYATTRIBS  = $0800;  // dont copy file security attributes (ACLs)
  FOF_NORECURSION            = $1000;  // don't recurse into directories for operations that would recurse
  FOF_NO_CONNECTED_ELEMENTS  = $2000;  // don't operate on connected elements ("xxx_files" folders that go with .htm files)
  FOF_WANTNUKEWARNING        = $4000;  // during delete operation, warn if nuking instead of recycling (partially overrides FOF_NOCONFIRMATION)
  FOF_NORECURSEREPARSE       = $8000;  // deprecated; the operations engine always does the right thing on FolderLink objects (symlinks, reparse points, folder shortcuts)
  FOF_NO_UI                  = FOF_SILENT or FOF_NOCONFIRMATION or FOF_NOERRORUI or FOF_NOCONFIRMMKDIR; // don't display any UI at all

type
  FILEOP_FLAGS = Word;

const
  PO_DELETE       = $0013;  { printer is being deleted }
  PO_RENAME       = $0014;  { printer is being renamed }
  PO_PORTCHANGE   = $0020;  { port this printer connected to is being changed
                              if this id is set, the strings received by
                              the copyhook are a doubly-null terminated
                              list of strings.  The first is the printer
                              name and the second is the printer port. }
  PO_REN_PORT     = $0034;  { PO_RENAME and PO_PORTCHANGE at same time. }

{ no POF_ flags currently defined }

type
  PRINTEROP_FLAGS = Word;

{ implicit parameters are:
      if pFrom or pTo are unqualified names the current directories are
      taken from the global current drive/directory settings managed
      by Get/SetCurrentDrive/Directory

      the global confirmation settings }

  PSHFileOpStructA = ^TSHFileOpStructA;
  PSHFileOpStructW = ^TSHFileOpStructW;
  PSHFileOpStruct = PSHFileOpStructW;
  _SHFILEOPSTRUCTA = packed record
    Wnd: HWND;
    wFunc: UINT;
    pFrom: PAnsiChar;
    pTo: PAnsiChar;
    fFlags: FILEOP_FLAGS;
    fAnyOperationsAborted: BOOL;
    hNameMappings: Pointer;
    lpszProgressTitle: PAnsiChar; { only used if FOF_SIMPLEPROGRESS }
  end;
  _SHFILEOPSTRUCTW = packed record
    Wnd: HWND;
    wFunc: UINT;
    pFrom: PWideChar;
    pTo: PWideChar;
    fFlags: FILEOP_FLAGS;
    fAnyOperationsAborted: BOOL;
    hNameMappings: Pointer;
    lpszProgressTitle: PWideChar; { only used if FOF_SIMPLEPROGRESS }
  end;
  _SHFILEOPSTRUCT = _SHFILEOPSTRUCTW;
  TSHFileOpStructA = _SHFILEOPSTRUCTA;
  TSHFileOpStructW = _SHFILEOPSTRUCTW;
  TSHFileOpStruct = TSHFileOpStructW;
  SHFILEOPSTRUCTA = _SHFILEOPSTRUCTA;
  SHFILEOPSTRUCTW = _SHFILEOPSTRUCTW;
  SHFILEOPSTRUCT = SHFILEOPSTRUCTW;

function SHFileOperation(const lpFileOp: TSHFileOpStruct): Integer; stdcall;
function SHFileOperationA(const lpFileOp: TSHFileOpStructA): Integer; stdcall;
function SHFileOperationW(const lpFileOp: TSHFileOpStructW): Integer; stdcall;
procedure SHFreeNameMappings(hNameMappings: THandle); stdcall;

type
  PSHNameMappingA = ^TSHNameMappingA;
  PSHNameMappingW = ^TSHNameMappingW;
  PSHNameMapping = PSHNameMappingW;
  _SHNAMEMAPPINGA = record
    pszOldPath: PAnsiChar;
    pszNewPath: PAnsiChar;
    cchOldPath: Integer;
    cchNewPath: Integer;
  end;
  _SHNAMEMAPPINGW = record
    pszOldPath: PWideChar;
    pszNewPath: PWideChar;
    cchOldPath: Integer;
    cchNewPath: Integer;
  end;
  _SHNAMEMAPPING = _SHNAMEMAPPINGW;
  TSHNameMappingA = _SHNAMEMAPPINGA;
  TSHNameMappingW = _SHNAMEMAPPINGW;
  TSHNameMapping = TSHNameMappingW;
  SHNAMEMAPPINGA = _SHNAMEMAPPINGA;
  SHNAMEMAPPINGW = _SHNAMEMAPPINGW;
  SHNAMEMAPPING = SHNAMEMAPPINGW;
// // End Shell File Operations

// //  Begin ShellExecuteEx and family
{ ShellExecute() and ShellExecuteEx() error codes }
const
{ regular WinExec() codes }
  SE_ERR_FNF              = 2;       { file not found }
  SE_ERR_PNF              = 3;       { path not found }
  SE_ERR_ACCESSDENIED     = 5;       { access denied }
  SE_ERR_OOM              = 8;       { out of memory }
  SE_ERR_DLLNOTFOUND      = 32;

{ error values for ShellExecute() beyond the regular WinExec() codes }
  SE_ERR_SHARE                    = 26;
  SE_ERR_ASSOCINCOMPLETE          = 27;
  SE_ERR_DDETIMEOUT               = 28;
  SE_ERR_DDEFAIL                  = 29;
  SE_ERR_DDEBUSY                  = 30;
  SE_ERR_NOASSOC                  = 31;

{ Note CLASSKEY overrides CLASSNAME }
  SEE_MASK_DEFAULT        = $00000000;
  SEE_MASK_CLASSNAME      = $00000001;
  SEE_MASK_CLASSKEY       = $00000003;
{ Note INVOKEIDLIST overrides IDLIST }
  SEE_MASK_IDLIST         = $00000004;
  SEE_MASK_INVOKEIDLIST   = $0000000c;
  SEE_MASK_ICON           = $00000010;
  SEE_MASK_HOTKEY         = $00000020;
  SEE_MASK_NOCLOSEPROCESS = $00000040;
  SEE_MASK_CONNECTNETDRV  = $00000080;
  SEE_MASK_NOASYNC   = $00000100;
  SEE_MASK_FLAG_DDEWAIT   = SEE_MASK_NOASYNC;
  SEE_MASK_DOENVSUBST     = $00000200;
  SEE_MASK_FLAG_NO_UI     = $00000400;
  SEE_MASK_UNICODE        = $00004000;
  SEE_MASK_NO_CONSOLE     = $00008000;
  SEE_MASK_ASYNCOK        = $00100000;
  SEE_MASK_HMONITOR       = $00200000;            // SHELLEXECUTEINFO.hMonitor
  SEE_MASK_NOZONECHECKS   = $00800000;
  SEE_MASK_NOQUERYCLASSSTORE = $01000000;
  SEE_MASK_WAITFORINPUTIDLE = $02000000;
  SEE_MASK_FLAG_LOG_USAGE = $04000000;

type
  PShellExecuteInfoA = ^TShellExecuteInfoA;
  PShellExecuteInfoW = ^TShellExecuteInfoW;
  PShellExecuteInfo = PShellExecuteInfoW;
  _SHELLEXECUTEINFOA = record
    cbSize: DWORD;
    fMask: ULONG;
    Wnd: HWND;
    lpVerb: PAnsiChar;
    lpFile: PAnsiChar;
    lpParameters: PAnsiChar;
    lpDirectory: PAnsiChar;
    nShow: Integer;
    hInstApp: HINST;
    { Optional fields }
    lpIDList: Pointer;
    lpClass: PAnsiChar;
    hkeyClass: HKEY;
    dwHotKey: DWORD;
    case Integer of 
      0: (
        hIcon: THandle);
      1: (
        hMonitor: THandle;
        hProcess: THandle;);
  end;
  _SHELLEXECUTEINFOW = record
    cbSize: DWORD;
    fMask: ULONG;
    Wnd: HWND;
    lpVerb: PWideChar;
    lpFile: PWideChar;
    lpParameters: PWideChar;
    lpDirectory: PWideChar;
    nShow: Integer;
    hInstApp: HINST;
    { Optional fields }
    lpIDList: Pointer;
    lpClass: PWideChar;
    hkeyClass: HKEY;
    dwHotKey: DWORD;
    case Integer of 
      0: (
        hIcon: THandle);
      1: (
        hMonitor: THandle;
        hProcess: THandle;);
  end;
  _SHELLEXECUTEINFO = _SHELLEXECUTEINFOW;
  TShellExecuteInfoA = _SHELLEXECUTEINFOA;
  TShellExecuteInfoW = _SHELLEXECUTEINFOW;
  TShellExecuteInfo = TShellExecuteInfoW;
  SHELLEXECUTEINFOA = _SHELLEXECUTEINFOA;
  SHELLEXECUTEINFOW = _SHELLEXECUTEINFOW;
  SHELLEXECUTEINFO = SHELLEXECUTEINFOW;

function ShellExecuteEx(lpExecInfo: PShellExecuteInfo):BOOL; stdcall;
function ShellExecuteExA(lpExecInfo: PShellExecuteInfoA):BOOL; stdcall;
function ShellExecuteExW(lpExecInfo: PShellExecuteInfoW):BOOL; stdcall;

//  SHCreateProcessAsUser()
type 
  _SHCREATEPROCESSINFOW = record
        cbSize: DWORD;
        fMask: ULONG;
        hwnd: HWND;
        pszFile: LPCWSTR;
        pszParameters: LPCWSTR;
        pszCurrentDirectory: LPCWSTR;
        hUserToken: THandle;
        lpProcessAttributes: PSecurityAttributes;
        lpThreadAttributes: PSecurityAttributes;
        bInheritHandles: BOOL;
        dwCreationFlags: DWORD;
        lpStartupInfo: PStartupInfoW;
        lpProcessInformation: PProcessInformation;
  end;
  SHCREATEPROCESSINFOW = _SHCREATEPROCESSINFOW;
  TSHCreateProcessInfoW = SHCREATEPROCESSINFOW;

function SHCreateProcessAsUserW(var pscpi: TSHCreateProcessInfoW): BOOL; stdcall;

function SHEvaluateSystemCommandTemplate(pszCmdTemplate: LPCWSTR; 
  var ppszApplication: LPWSTR; var ppszCommandLine: LPWSTR; 
  var ppszParameters: LPWSTR): HResult; stdcall;

type
  ASSOCCLASS = Integer;    
  TAssocClass = ASSOCClass;
const
  ASSOCCLASS_SHELL_KEY  = 0;    //  hkeyClass
  ASSOCCLASS_PROGID_KEY = 1;    //  hkeyClass
  ASSOCCLASS_PROGID_STR = 2;    //  pszClass (HKCR\pszClass)
  ASSOCCLASS_CLSID_KEY  = 3;    //  hkeyClass
  ASSOCCLASS_CLSID_STR  = 4;    //  pszClass (HKCR\CLSID\pszClass)
  ASSOCCLASS_APP_KEY    = 5;    //  hkeyClass
  ASSOCCLASS_APP_STR    = 6;    //  pszClass (HKCR\Applications\PathFindFileName(pszClass))
  ASSOCCLASS_SYSTEM_STR = 7;    //  pszClass
  ASSOCCLASS_FOLDER     = 8;    //  none
  ASSOCCLASS_STAR       = 9;    //  none
type
  ASSOCIATIONELEMENT = record
    ac: TAssocClass;            // required
    hkClass: HKEY;              // may be NULL
    pszClass: LPCWSTR;          // may be NULL
  end;
  ASSOCIATIONELEMENT_ = ASSOCIATIONELEMENT;
  TAssociationElement = ASSOCIATIONELEMENT;
  PAssociationElement = ^TASSOCIATIONELEMENT;

// the object returned from this API implements IQueryAssociations
function AssocCreateForClasses(var rgClasses: TAssociationElement;
  cClasses: Cardinal; const riid: TGUID; var ppv: Pointer): HResult; stdcall;
// //  End ShellExecuteEx and family

// RecycleBin

// struct for query recycle bin info
type
  LPSHQUERYRBINFO = ^SHQUERYRBINFO;
  SHQUERYRBINFO = record
    cbSize: DWORD;
    i64Size: DWORDLONG;
    i64NumItems: DWORDLONG;
  end;
  _SHQUERYRBINFO = SHQUERYRBINFO;
  TSHQueryRBInfo = SHQUERYRBINFO;
  PSHQueryRBInfo = ^TSHQueryRBInfo;

// flags for SHEmptyRecycleBin
// 
const
  SHERB_NOCONFIRMATION = $00000001; 
  SHERB_NOPROGRESSUI = $00000002;
  SHERB_NOSOUND = $00000004;

function SHQueryRecycleBin(pszRootPath: PWideChar;
  pSHQueryRBInfo: LPSHQUERYRBINFO): HResult; stdcall;
function SHQueryRecycleBinA(pszRootPath: PAnsiChar;
  pSHQueryRBInfo: LPSHQUERYRBINFO): HResult; stdcall;
function SHQueryRecycleBinW(pszRootPath: PWideChar;
  pSHQueryRBInfo: LPSHQUERYRBINFO): HResult; stdcall;
function SHEmptyRecycleBin(hwnd: HWND; pszRootPath: PWideChar;
  dwFlags: DWORD): HResult; stdcall;
function SHEmptyRecycleBinA(hwnd: HWND; pszRootPath: PAnsiChar;
  dwFlags: DWORD): HResult; stdcall;
function SHEmptyRecycleBinW(hwnd: HWND; pszRootPath: PWideChar;
  dwFlags: DWORD): HResult; stdcall;
// // end of RecycleBin

// // Taskbar notification definitions
type
  QUERY_USER_NOTIFICATION_STATE = Integer;
const
  QUNS_NOT_PRESENT             = 1;  // The user is not present.  Heuristic check for modes like: screen saver, locked machine, non-active FUS session
  QUNS_BUSY                    = 2;  // The user is busy.  Heuristic check for modes like: full-screen app
  QUNS_RUNNING_D3D_FULL_SCREEN = 3;  // full-screen (exlusive-mode) D3D app
  QUNS_PRESENTATION_MODE       = 4;  // Windows presentation mode (laptop feature) is turned on
  QUNS_ACCEPTS_NOTIFICATIONS   = 5;  // notifications can be freely sent
  QUNS_QUIET_TIME              = 6;   // We are in OOBE quiet period

function SHQueryUserNotificationState(
  var pquns: QUERY_USER_NOTIFICATION_STATE): HResult; stdcall;

// This api retrieves an IPropertyStore that stores the window's properties.
function SHGetPropertyStoreForWindow(hwnd: HWND; const riid: TGUID;
  var ppv: Pointer): HResult; stdcall;

type
  PNotifyIconDataA = ^TNotifyIconDataA;
  PNotifyIconDataW = ^TNotifyIconDataW;
  PNotifyIconData = PNotifyIconDataW;
  _NOTIFYICONDATAA = record
  private
    class constructor Create;
  public
    class function SizeOf: Integer; static;
  public
    cbSize: DWORD;
    Wnd: HWND;
    uID: UINT;
    uFlags: UINT;
    uCallbackMessage: UINT;
    hIcon: HICON;
    szTip: array [0..127] of AnsiChar;
    dwState: DWORD;
    dwStateMask: DWORD;
    szInfo: array [0..255] of AnsiChar;
    case Integer of
      0: (
        uTimeout: UINT);
      1: (uVersion: UINT;
        szInfoTitle: array [0..63] of AnsiChar;
        dwInfoFlags: DWORD;
        guidItem: TGUID;        // Requires Windows Vista or later
        hBalloonIcon: HICON);   // Requires Windows Vista or later
  end;
  _NOTIFYICONDATAW = record
  private
    class constructor Create;
  public
    class function SizeOf: Integer; static;
  public
    cbSize: DWORD;
    Wnd: HWND;
    uID: UINT;
    uFlags: UINT;
    uCallbackMessage: UINT;
    hIcon: HICON;
    szTip: array [0..127] of WideChar;
    dwState: DWORD;
    dwStateMask: DWORD;
    szInfo: array [0..255] of WideChar;
    case Integer of
      0: (
        uTimeout: UINT);
      1: (uVersion: UINT;
        szInfoTitle: array [0..63] of WideChar;
        dwInfoFlags: DWORD;
        guidItem: TGUID;        // Requires Windows Vista or later
        hBalloonIcon: HICON);   // Requires Windows Vista or later
  end;
  _NOTIFYICONDATA = _NOTIFYICONDATAW;
  TNotifyIconDataA = _NOTIFYICONDATAA;
  TNotifyIconDataW = _NOTIFYICONDATAW;
  TNotifyIconData = TNotifyIconDataW;
  NOTIFYICONDATAA = _NOTIFYICONDATAA;
  NOTIFYICONDATAW = _NOTIFYICONDATAW;
  NOTIFYICONDATA = NOTIFYICONDATAW;

const
  NIM_ADD         = $00000000;
  NIM_MODIFY      = $00000001;
  NIM_DELETE      = $00000002;
  NIM_SETFOCUS    = $00000003;
  NIM_SETVERSION  = $00000004;

// set NOTIFYICONDATA.uVersion with 0, 3 or 4
// please read the documentation on the behavior difference that the different versions imply
  NOTIFYICON_VERSION = 3;
  NOTIFYICON_VERSION_4 = 4;

  NIF_MESSAGE     = $00000001;
  NIF_ICON        = $00000002;
  NIF_TIP         = $00000004;
  NIF_STATE       = $00000008;
  NIF_INFO        = $00000010;
  NIF_GUID = $00000020;
  NIF_REALTIME = $00000040;
  NIF_SHOWTIP = $00000080;

  NIS_HIDDEN = $00000001;
  NIS_SHAREDICON = $00000002;
// says this is the source of a shared icon

// Notify Icon Infotip flags
  NIIF_NONE       = $00000000;
// icon flags are mutually exclusive
// and take only the lowest 2 bits
  NIIF_INFO       = $00000001;
  NIIF_WARNING    = $00000002;
  NIIF_ERROR      = $00000003;
  NIIF_USER       = $00000004;
  NIIF_ICON_MASK  = $0000000F;
  NIIF_NOSOUND    = $00000010;
  NIIF_LARGE_ICON = $00000020;
  NIIF_RESPECT_QUIET_TIME = $00000080;

  NIN_SELECT      = $0400;
  NINF_KEY        =  $1;
  NIN_KEYSELECT   = NIN_SELECT or NINF_KEY;

  NIN_BALLOONSHOW       = $0400 + 2;
  NIN_BALLOONHIDE       = $0400 + 3;
  NIN_BALLOONTIMEOUT    = $0400 + 4;
  NIN_BALLOONUSERCLICK  = $0400 + 5;
  NIN_POPUPOPEN         = $0400 + 6;
  NIN_POPUPCLOSE        = $0400 + 7;

type
  PNOTIFYICONIDENTIFIER = ^NOTIFYICONIDENTIFIER;
  NOTIFYICONIDENTIFIER = record
    cbSize: DWORD;
    hWnd: HWND;
    uID: UINT;
    guidItem: TGUID;
  end;
  _NOTIFYICONIDENTIFIER = NOTIFYICONIDENTIFIER;


function Shell_NotifyIcon(dwMessage: DWORD; lpData: PNotifyIconData): BOOL; stdcall;
function Shell_NotifyIconA(dwMessage: DWORD; lpData: PNotifyIconDataA): BOOL; stdcall;
function Shell_NotifyIconW(dwMessage: DWORD; lpData: PNotifyIconDataW): BOOL; stdcall;
function Shell_NotifyIconGetRect(var identifier: NOTIFYICONIDENTIFIER;
  var iconLocation: TRect): HResult; stdcall;
// // End Taskbar Notification Icons

{ Begin SHGetFileInfo }

(*
 * The SHGetFileInfo API provides an easy way to get attributes
 * for a file given a pathname.
 *
 *   PARAMETERS
 *
 *     pszPath              file name to get info about
 *     dwFileAttributes     file attribs, only used with SHGFI_USEFILEATTRIBUTES
 *     psfi                 place to return file info
 *     cbFileInfo           size of structure
 *     uFlags               flags
 *
 *   RETURN
 *     TRUE if things worked
 *)

type
  PSHFileInfoA = ^TSHFileInfoA;
  PSHFileInfoW = ^TSHFileInfoW;
  PSHFileInfo = PSHFileInfoW;
  _SHFILEINFOA = record
    hIcon: HICON;                      { out: icon }
    iIcon: Integer;                    { out: icon index }
    dwAttributes: DWORD;               { out: SFGAO_ flags }
    szDisplayName: array [0..MAX_PATH-1] of  AnsiChar; { out: display name (or path) }
    szTypeName: array [0..79] of AnsiChar;             { out: type name }
  end;
  _SHFILEINFOW = record
    hIcon: HICON;                      { out: icon }
    iIcon: Integer;                    { out: icon index }
    dwAttributes: DWORD;               { out: SFGAO_ flags }
    szDisplayName: array [0..MAX_PATH-1] of  WideChar; { out: display name (or path) }
    szTypeName: array [0..79] of WideChar;             { out: type name }
  end;
  _SHFILEINFO = _SHFILEINFOW;
  TSHFileInfoA = _SHFILEINFOA;
  TSHFileInfoW = _SHFILEINFOW;
  TSHFileInfo = TSHFileInfoW;
  SHFILEINFOA = _SHFILEINFOA;
  SHFILEINFOW = _SHFILEINFOW;
  SHFILEINFO = SHFILEINFOW;

const
  SHGFI_ICON              = $000000100;     { get icon }
  SHGFI_DISPLAYNAME       = $000000200;     { get display name }
  SHGFI_TYPENAME          = $000000400;     { get type name }
  SHGFI_ATTRIBUTES        = $000000800;     { get attributes }
  SHGFI_ICONLOCATION      = $000001000;     { get icon location }
  SHGFI_EXETYPE           = $000002000;     { return exe type }
  SHGFI_SYSICONINDEX      = $000004000;     { get system icon index }
  SHGFI_LINKOVERLAY       = $000008000;     { put a link overlay on icon }
  SHGFI_SELECTED          = $000010000;     { show icon in selected state }
  SHGFI_ATTR_SPECIFIED    = $000020000;     { get only specified attributes }
  SHGFI_LARGEICON         = $000000000;     { get large icon }
  SHGFI_SMALLICON         = $000000001;     { get small icon }
  SHGFI_OPENICON          = $000000002;     { get open icon }
  SHGFI_SHELLICONSIZE     = $000000004;     { get shell size icon }
  SHGFI_PIDL              = $000000008;     { pszPath is a pidl }
  SHGFI_USEFILEATTRIBUTES = $000000010;     { use passed dwFileAttribute }
  SHGFI_ADDOVERLAYS = $000000020;           { apply the appropriate overlays }
  SHGFI_OVERLAYINDEX = $000000040;          { Get the index of the overlay
                                              in the upper 8 bits of the iIcon }

function SHGetFileInfo(pszPath: PWideChar; dwFileAttributes: DWORD;
  var psfi: TSHFileInfo; cbFileInfo, uFlags: UINT): DWORD; stdcall;
function SHGetFileInfoA(pszPath: PAnsiChar; dwFileAttributes: DWORD;
  var psfi: TSHFileInfoA; cbFileInfo, uFlags: UINT): DWORD; stdcall;
function SHGetFileInfoW(pszPath: PWideChar; dwFileAttributes: DWORD;
  var psfi: TSHFileInfoW; cbFileInfo, uFlags: UINT): DWORD; stdcall;

type
  SHSTOCKICONINFO = record
    cbSize: DWORD;
    hIcon: HICON;
    iSysImageIndex: Integer;
    iIcon: Integer;
    szPath: packed array[0..MAX_PATH-1] of WCHAR;
  end;
  _SHSTOCKICONINFO = SHSTOCKICONINFO;
  TSHStockIconInfo = SHSTOCKICONINFO;
  PSHStockIconInfo = ^TSHSTockIconInfo;

const
  SHGSI_ICONLOCATION = 0;     // you always get the icon location
  SHGSI_ICON = SHGFI_ICON;
  SHGSI_SYSICONINDEX = SHGFI_SYSICONINDEX;
  SHGSI_LINKOVERLAY = SHGFI_LINKOVERLAY;
  SHGSI_SELECTED = SHGFI_SELECTED;
  SHGSI_LARGEICON = SHGFI_LARGEICON;
  SHGSI_SMALLICON = SHGFI_SMALLICON;
  SHGSI_SHELLICONSIZE = SHGFI_SHELLICONSIZE;

//  Shell icons
type
  SHSTOCKICONID = Integer;
const
  SIID_DOCNOASSOC        = 0;     // document (blank page), no associated program
  SIID_DOCASSOC          = 1;     // document with an associated program
  SIID_APPLICATION       = 2;     // generic application with no custom icon
  SIID_FOLDER            = 3;     // folder (closed)
  SIID_FOLDEROPEN        = 4;     // folder (open)
  SIID_DRIVE525          = 5;     // 5.25" floppy disk drive
  SIID_DRIVE35           = 6;     // 3.5" floppy disk drive
  SIID_DRIVEREMOVE       = 7;     // removable drive
  SIID_DRIVEFIXED        = 8;     // fixed (hard disk) drive
  SIID_DRIVENET          = 9;     // network drive
  SIID_DRIVENETDISABLED  = 10;    // disconnected network drive
  SIID_DRIVECD           = 11;    // CD drive
  SIID_DRIVERAM          = 12;    // RAM disk drive
  SIID_WORLD             = 13;    // entire network
  SIID_SERVER            = 15;    // a computer on the network
  SIID_PRINTER           = 16;    // printer
  SIID_MYNETWORK         = 17;    // My network places
  SIID_FIND              = 22;    // Find
  SIID_HELP              = 23;    // Help
  SIID_SHARE             = 28;    // overlay for shared items
  SIID_LINK              = 29;    // overlay for shortcuts to items
  SIID_SLOWFILE          = 30;    // overlay for slow items
  SIID_RECYCLER          = 31;    // empty recycle bin
  SIID_RECYCLERFULL      = 32;    // full recycle bin
  SIID_MEDIACDAUDIO      = 40;    // Audio CD Media
  SIID_LOCK              = 47;    // Security lock
  SIID_AUTOLIST          = 49;    // AutoList
  SIID_PRINTERNET        = 50;    // Network printer
  SIID_SERVERSHARE       = 51;    // Server share
  SIID_PRINTERFAX        = 52;    // Fax printer
  SIID_PRINTERFAXNET     = 53;    // Networked Fax Printer
  SIID_PRINTERFILE       = 54;    // Print to File
  SIID_STACK             = 55;    // Stack
  SIID_MEDIASVCD         = 56;    // SVCD Media
  SIID_STUFFEDFOLDER     = 57;    // Folder containing other items
  SIID_DRIVEUNKNOWN      = 58;    // Unknown drive
  SIID_DRIVEDVD          = 59;    // DVD Drive
  SIID_MEDIADVD          = 60;    // DVD Media
  SIID_MEDIADVDRAM       = 61;    // DVD-RAM Media
  SIID_MEDIADVDRW        = 62;    // DVD-RW Media
  SIID_MEDIADVDR         = 63;    // DVD-R Media
  SIID_MEDIADVDROM       = 64;    // DVD-ROM Media
  SIID_MEDIACDAUDIOPLUS  = 65;    // CD+ (Enhanced CD) Media
  SIID_MEDIACDRW         = 66;    // CD-RW Media
  SIID_MEDIACDR          = 67;    // CD-R Media
  SIID_MEDIACDBURN       = 68;    // Burning CD
  SIID_MEDIABLANKCD      = 69;    // Blank CD Media
  SIID_MEDIACDROM        = 70;    // CD-ROM Media
  SIID_AUDIOFILES        = 71;    // Audio files
  SIID_IMAGEFILES        = 72;    // Image files
  SIID_VIDEOFILES        = 73;    // Video files
  SIID_MIXEDFILES        = 74;    // Mixed files
  SIID_FOLDERBACK        = 75;    // Folder back
  SIID_FOLDERFRONT       = 76;    // Folder front
  SIID_SHIELD            = 77;    // Security shield. Use for UAC prompts only.
  SIID_WARNING           = 78;    // Warning
  SIID_INFO              = 79;    // Informational
  SIID_ERROR             = 80;    // Error
  SIID_KEY               = 81;    // Key / Secure
  SIID_SOFTWARE          = 82;    // Software
  SIID_RENAME            = 83;    // Rename
  SIID_DELETE            = 84;    // Delete
  SIID_MEDIAAUDIODVD     = 85;    // Audio DVD Media
  SIID_MEDIAMOVIEDVD     = 86;    // Movie DVD Media
  SIID_MEDIAENHANCEDCD   = 87;    // Enhanced CD Media
  SIID_MEDIAENHANCEDDVD  = 88;    // Enhanced DVD Media
  SIID_MEDIAHDDVD        = 89;    // HD-DVD Media
  SIID_MEDIABLURAY       = 90;    // BluRay Media
  SIID_MEDIAVCD          = 91;    // VCD Media
  SIID_MEDIADVDPLUSR     = 92;    // DVD+R Media
  SIID_MEDIADVDPLUSRW    = 93;    // DVD+RW Media
  SIID_DESKTOPPC         = 94;    // desktop computer
  SIID_MOBILEPC          = 95;    // mobile computer (laptop/notebook)
  SIID_USERS             = 96;    // users
  SIID_MEDIASMARTMEDIA   = 97;    // Smart Media
  SIID_MEDIACOMPACTFLASH = 98;    // Compact Flash
  SIID_DEVICECELLPHONE   = 99;    // Cell phone
  SIID_DEVICECAMERA      = 100;   // Camera
  SIID_DEVICEVIDEOCAMERA = 101;   // Video camera
  SIID_DEVICEAUDIOPLAYER = 102;   // Audio player
  SIID_NETWORKCONNECT    = 103;   // Connect to network
  SIID_INTERNET          = 104;   // Internet
  SIID_ZIPFILE           = 105;   // ZIP file
  SIID_SETTINGS          = 106;   // Settings
    // 107-131 are internal Vista RTM icons
    // 132-159 for SP1 icons
  SIID_DRIVEHDDVD        = 132;   // HDDVD Drive (all types)
  SIID_DRIVEBD           = 133;   // BluRay Drive (all types)
  SIID_MEDIAHDDVDROM     = 134;   // HDDVD-ROM Media
  SIID_MEDIAHDDVDR       = 135;   // HDDVD-R Media
  SIID_MEDIAHDDVDRAM     = 136;   // HDDVD-RAM Media
  SIID_MEDIABDROM        = 137;   // BluRay ROM Media
  SIID_MEDIABDR          = 138;   // BluRay R Media
  SIID_MEDIABDRE         = 139;   // BluRay RE Media (Rewriable and RAM)
  SIID_CLUSTEREDDRIVE    = 140;   // Clustered disk
    // 160+ are for Windows 7 icons
  SIID_MAX_ICONS         = 174;

  SIID_INVALID           = -1;

function SHGetStockIconInfo(siid: SHSTOCKICONID; uFlags: UINT;
  var psii: TSHStockIconInfo): HResult; stdcall;

function SHGetDiskFreeSpace(pszDirectoryName: PWideChar;
  var pulFreeBytesAvailableToCaller: ULARGE_INTEGER;
  var pulTotalNumberOfBytes: ULARGE_INTEGER;
  var pulTotalNumberOfFreeBytes: ULARGE_INTEGER): BOOL; stdcall;
function SHGetDiskFreeSpaceA(pszDirectoryName: PAnsiChar;
  var pulFreeBytesAvailableToCaller: ULARGE_INTEGER;
  var pulTotalNumberOfBytes: ULARGE_INTEGER;
  var pulTotalNumberOfFreeBytes: ULARGE_INTEGER): BOOL; stdcall;
function SHGetDiskFreeSpaceW(pszDirectoryName: PWideChar;
  var pulFreeBytesAvailableToCaller: ULARGE_INTEGER;
  var pulTotalNumberOfBytes: ULARGE_INTEGER;
  var pulTotalNumberOfFreeBytes: ULARGE_INTEGER): BOOL; stdcall;
function SHGetDiskFreeSpaceEx(pszDirectoryName: PWideChar;
  var pulFreeBytesAvailableToCaller: ULARGE_INTEGER;
  var pulTotalNumberOfBytes: ULARGE_INTEGER;
  var pulTotalNumberOfFreeBytes: ULARGE_INTEGER): BOOL; stdcall;
function SHGetDiskFreeSpaceExA(pszDirectoryName: PAnsiChar;
  var pulFreeBytesAvailableToCaller: ULARGE_INTEGER;
  var pulTotalNumberOfBytes: ULARGE_INTEGER;
  var pulTotalNumberOfFreeBytes: ULARGE_INTEGER): BOOL; stdcall;
function SHGetDiskFreeSpaceExW(pszDirectoryName: PWideChar;
  var pulFreeBytesAvailableToCaller: ULARGE_INTEGER;
  var pulTotalNumberOfBytes: ULARGE_INTEGER;
  var pulTotalNumberOfFreeBytes: ULARGE_INTEGER): BOOL; stdcall;

function SHGetNewLinkInfo(pszLinkTo: PWideChar; pszDir: PWideChar; pszName: PWideChar;
  var pfMustCopy: BOOL; uFlags: UINT): BOOL; stdcall
function SHGetNewLinkInfoA(pszLinkTo: PAnsiChar; pszDir: PAnsiChar; pszName: PAnsiChar;
  var pfMustCopy: BOOL; uFlags: UINT): BOOL; stdcall
function SHGetNewLinkInfoW(pszLinkTo: PWideChar; pszDir: PWideChar; pszName: PWideChar;
  var pfMustCopy: BOOL; uFlags: UINT): BOOL; stdcall

const
  SHGNLI_PIDL             = $000000001;     { pszLinkTo is a pidl }
  SHGNLI_PREFIXNAME       = $000000002;     { Make name "Shortcut to xxx" }
  SHGNLI_NOUNIQUE         = $000000004;     { don't do the unique name generation }
  SHGNLI_NOLNK = $000000008;                { don't add ".lnk" extension }
  SHGNLI_NOLOCNAME = $000000010;            { use non localized (parsing) name from the target}
  SHGNLI_USEURLEXT = $000000020;            { use ".url" extension instead of ".lnk" }

  PRINTACTION_OPEN = 0;                 // pszBuf1:<PrinterName>
  PRINTACTION_PROPERTIES = 1;           // pszBuf1:<PrinterName>, pszBuf2:optional <PageName>
  PRINTACTION_NETINSTALL = 2;           // pszBuf1:<NetPrinterName>
  PRINTACTION_NETINSTALLLINK = 3;       // pszBuf1:<NetPrinterName>, pszBuf2:<path to store link>
  PRINTACTION_TESTPAGE = 4;             // pszBuf1:<PrinterName>
  PRINTACTION_OPENNETPRN = 5;           // pszBuf1:<NetPrinterName>
  PRINTACTION_DOCUMENTDEFAULTS = 6;     // pszBuf1:<PrinterName>
  PRINTACTION_SERVERPROPERTIES = 7;     // pszBuf1:<Server> or <NetPrinterName>

// deprecated, instead invoke verbs on printers/netprinters using IContextMenu or ShellExecute()

function SHInvokePrinterCommand(hwnd: HWND; uAction: UINT; lpBuf1: PWideChar;
  lpBuf2: PWideChar; fModal: BOOL): BOOL; stdcall;
function SHInvokePrinterCommandA(hwnd: HWND; uAction: UINT; lpBuf1: PAnsiChar;
  lpBuf2: PAnsiChar; fModal: BOOL): BOOL; stdcall;
function SHInvokePrinterCommandW(hwnd: HWND; uAction: UINT; lpBuf1: PWideChar;
  lpBuf2: PWideChar; fModal: BOOL): BOOL; stdcall;

type
  OPEN_PRINTER_PROPS_INFOA = record 
    dwSize: DWORD;
    pszSheetName: PAnsiChar;
    uSheetIndex: UINT;
    dwFlags: DWORD;
    bModal: BOOL;
  end;
  OPEN_PRINTER_PROPS_INFOW = record
    dwSize: DWORD;
    pszSheetName: PWideChar;
    uSheetIndex: UINT;
    dwFlags: DWORD;
    bModal: BOOL;
  end;
  OPEN_PRINTER_PROPS_INFO = OPEN_PRINTER_PROPS_INFOW;
  _OPEN_PRINTER_PROPS_INFOA = OPEN_PRINTER_PROPS_INFOA;
  _OPEN_PRINTER_PROPS_INFOW = OPEN_PRINTER_PROPS_INFOW;
  _OPEN_PRINTER_PROPS_INFO = _OPEN_PRINTER_PROPS_INFOW;
  TOpenPrinterPropsInfoA = OPEN_PRINTER_PROPS_INFOA;
  TOpenPrinterPropsInfoW = OPEN_PRINTER_PROPS_INFOW;
  TOpenPrinterPropsInfo = TOpenPrinterPropsInfoW;
  POpenPrinterPropsInfoA = ^TOpenPrinterPropsInfoA;
  POpenPrinterPropsInfoW = ^TOpenPrinterPropsInfoW;
  POpenPrinterPropsInfo = POpenPrinterPropsInfoW;

const
  PRINT_PROP_FORCE_NAME = $01;

  shell32 = 'shell32.dll';

// 
// The SHLoadNonloadedIconOverlayIdentifiers API causes the shell's
// icon overlay manager to load any registered icon overlay
// identifers that are not currently loaded.  This is useful if an
// overlay identifier did not load at shell startup but is needed
// and can be loaded at a later time.  Identifiers already loaded
// are not affected.  Overlay identifiers implement the
// IShellIconOverlayIdentifier interface.
// 
// Returns:
//      S_OK
// 
function SHLoadNonloadedIconOverlayIdentifiers: HResult; stdcall;

// 
// The SHIsFileAvailableOffline API determines whether a file
// or folder is available for offline use.
// 
// Parameters:
//     pwszPath             file name to get info about
//     pdwStatus            (optional) OFFLINE_STATUS_* flags returned here
// 
// Returns:
//     S_OK                 File/directory is available offline, unless
//                            OFFLINE_STATUS_INCOMPLETE is returned.
//     E_INVALIDARG         Path is invalid, or not a net path
//     E_FAIL               File/directory is not available offline
// 
// Notes:
//     OFFLINE_STATUS_INCOMPLETE is never returned for directories.
//     Both OFFLINE_STATUS_LOCAL and OFFLINE_STATUS_REMOTE may be returned,
//     indicating "open in both places." This is common when the server is online.
// 
function SHIsFileAvailableOffline(pwszPath: LPCWSTR; 
  pdwStatus: LPDWORD): HResult; stdcall;

const
  OFFLINE_STATUS_LOCAL = $0001;         // If open, it's open locally
  OFFLINE_STATUS_REMOTE = $0002;        // If open, it's open remotely
  OFFLINE_STATUS_INCOMPLETE = $0004;    // The local copy is currently imcomplete.
                                            // The file will not be available offline
                                            // until it has been synchronized.

//  sets the specified path to use the string resource
//  as the UI instead of the file system name
function SHSetLocalizedName(pszPath: LPCWSTR; pszResModule: LPCWSTR;
  idsRes: Integer): HResult; stdcall;

//  sets the specified path to use the string resource
//  as the UI instead of the file system name
function SHRemoveLocalizedName(pszPath: LPCWSTR): HResult; stdcall;

//  gets the string resource for the specified path
function SHGetLocalizedName(pszPath: LPCWSTR; pszResModule: LPWSTR; cch: UINT; 
  var pidsRes: Integer): HResult; stdcall;

// ====== ShellMessageBox ================================================

// If lpcTitle is NULL, the title is taken from hWnd
// If lpcText is NULL, this is assumed to be an Out Of Memory message
// If the selector of lpcTitle or lpcText is NULL, the offset should be a
//     string resource ID
// The variable arguments must all be 32-bit values (even if fewer bits
//     are actually used)
// lpcText (or whatever string resource it causes to be loaded) should
//     be a formatting string similar to wsprintf except that only the
//     following formats are available:
//         %%              formats to a single '%'
//         %nn%s           the nn-th arg is a string which is inserted
//         %nn%ld          the nn-th arg is a DWORD, and formatted decimal
//         %nn%lx          the nn-th arg is a DWORD, and formatted hex
//     note that lengths are allowed on the %s, %ld, and %lx, just
//                         like wsprintf
// 
function ShellMessageBox(hAppInst: HINST;  hWnd: HWND; pcText: PWideChar;
  lpcTitle: PWideChar; fuStyle: UINT): Integer; cdecl; varargs;
function ShellMessageBoxA(hAppInst: HINST;  hWnd: HWND; pcText: PAnsiChar;
  lpcTitle: PAnsiChar; fuStyle: UINT): Integer; cdecl; varargs;
function ShellMessageBoxW(hAppInst: HINST;  hWnd: HWND; pcText: PWideChar;
  lpcTitle: PWideChar; fuStyle: UINT): Integer; cdecl; varargs;

function IsLFNDrive(pszPath: PWideChar): BOOL;
function IsLFNDriveA(pszPath: PAnsiChar): BOOL;
function IsLFNDriveW(pszPath: PWideChar): BOOL;

function SHEnumerateUnreadMailAccounts(hKeyUser: HKEY; dwIndex: DWORD;
  pszMailAddress: PWideChar; cchMailAddress: Integer): HResult; stdcall;
function SHEnumerateUnreadMailAccountsA(hKeyUser: HKEY; dwIndex: DWORD;
  pszMailAddress: PAnsiChar; cchMailAddress: Integer): HResult; stdcall;
function SHEnumerateUnreadMailAccountsW(hKeyUser: HKEY; dwIndex: DWORD;
  pszMailAddress: PWideChar; cchMailAddress: Integer): HResult; stdcall;
function SHGetUnreadMailCount(hKeyUser: HKEY; pszMailAddress: PWideChar;
  var pdwCount: DWORD; var pFileTime: FILETIME; pszShellExecuteCommand: PWideChar;
  cchShellExecuteCommand: Integer): HResult; stdcall;
function SHGetUnreadMailCountA(hKeyUser: HKEY; pszMailAddress: PAnsiChar;
  var pdwCount: DWORD; var pFileTime: FILETIME; pszShellExecuteCommand: PAnsiChar;
  cchShellExecuteCommand: Integer): HResult; stdcall;
function SHGetUnreadMailCountW(hKeyUser: HKEY; pszMailAddress: PWideChar;
  var pdwCount: DWORD; var pFileTime: FILETIME; pszShellExecuteCommand: PWideChar;
  cchShellExecuteCommand: Integer): HResult; stdcall;
function SHSetUnreadMailCount(pszMailAddress: PWideChar; dwCount: DWORD;
  pszShellExecuteCommand: PWideChar): HResult; stdcall;
function SHSetUnreadMailCountA(pszMailAddress: PAnsiChar; dwCount: DWORD;
  pszShellExecuteCommand: PAnsiChar): HResult; stdcall;
function SHSetUnreadMailCountW(pszMailAddress: PWideChar; dwCount: DWORD;
  pszShellExecuteCommand: PWideChar): HResult; stdcall;

function SHTestTokenMembership(hToken: THandle; ulRID: ULONG): HResult; stdcall;

function SHGetImageList(iImageList: Integer; const riid: TGUID;
  var ppvObj: Pointer): HResult;

const
  SHIL_LARGE = 0;           // normally 32x32
  SHIL_SMALL = 1;           // normally 16x16
  SHIL_EXTRALARGE = 2;
  SHIL_SYSSMALL = 3;        // like SHIL_SMALL, but tracks system small icon metric correctly
  SHIL_JUMBO = 4;           // normally 256x256
  SHIL_LAST = SHIL_JUMBO;

// Function call types for ntshrui folder sharing helpers
type
  PFNCANSHAREFOLDERW = function(pszPath: LPCWSTR): HRESULT;
type
  PFNSHOWSHAREFOLDERUIW = function(hwndParent: HWND;
    pszPath: LPCWSTR): HRESULT;

// API for new Network Address Control

// Instantiation
const
  WC_NETADDRESS = 'msctls_netaddress';
  {$EXTERNALSYM WC_NETADDRESS}
function InitNetworkAddressControl: BOOL; stdcall;
// Address Control Messages

type                                          
  NET_ADDRESS_INFO_ = record
    Address: array[0..256-1] of WCHAR;
    Port: array[0..6-1] of WCHAR;
  end;
  PNET_ADDRESS_INFO_ = ^NET_ADDRESS_INFO_;

  PNC_ADDRESS = ^NC_ADDRESS;
  NC_ADDRESS = record
    pAddrInfo: PNET_ADDRESS_INFO_;      // defined in iphlpapi.h
    PortNumber: USHORT;
    PrefixLength: Byte;
  end;
  tagNC_ADDRESS = NC_ADDRESS;
  TNcAddress = NC_ADDRESS;
  PNcAddress = ^TNcAddress;

// NCM_GETADDRESS returns the type of address that is present in the
// control (based on TBD Net Address flags).  If the input string has
// not been validated using this message will force the validation of
// the input string.  The WPARAM is a BOOL to determine to show the
// balloon tip.  The LPARAM is a pointer to the structure to fill in
// with the address type and address string.
const
  NCM_GETADDRESS = $0400+1; 
// NCM_SETALLOWTYPE sets the type of addresses that the control will allow.
// The address flags are defined in iphlpapi.h
  NCM_SETALLOWTYPE = $0400+2;
// NCM_GETALLOWTYPE returns the currently allowed type mask.
  NCM_GETALLOWTYPE = $0400+3;
// NCM_DISPLAYERRORTIP displays the error balloon tip with the correct
// error string (based on the last failure from the NCM_GETADDRESS call
  NCM_DISPLAYERRORTIP = $0400+4;

// Returns the type of media (CD, DVD, Blank, etc) that is in the drive.
// dwMediaContent is set to a combination of ARCONTENT flags.
function SHGetDriveMedia(pszDrive: LPCWSTR;
  var pdwMediaContent: DWORD): HResult; stdcall;

implementation

var
  Win32MajorVersion: Integer = 0;
  Win32MinorVersion: Integer = 0;
  Win32Platform: Integer = 0;

function AssocCreateForClasses; external shell32 name 'AssocCreateForClasses' delayed;
function CommandLineToArgvW; external shell32 name 'CommandLineToArgvW';
function DoEnvironmentSubst; external shell32 name 'DoEnvironmentSubstW';
function DoEnvironmentSubstA; external shell32 name 'DoEnvironmentSubstA';
function DoEnvironmentSubstW; external shell32 name 'DoEnvironmentSubstW';
procedure DragAcceptFiles; external shell32 name 'DragAcceptFiles';
procedure DragFinish; external shell32 name 'DragFinish';
function DragQueryFile; external shell32 name 'DragQueryFileW';
function DragQueryFileA; external shell32 name 'DragQueryFileA';
function DragQueryFileW; external shell32 name 'DragQueryFileW';
function DragQueryPoint; external shell32 name 'DragQueryPoint';
function DuplicateIcon; external shell32 name 'DuplicateIcon';
function ExtractAssociatedIcon; external shell32 name 'ExtractAssociatedIconW';
function ExtractAssociatedIconA; external shell32 name 'ExtractAssociatedIconA';
function ExtractAssociatedIconW; external shell32 name 'ExtractAssociatedIconW';
function ExtractAssociatedIconEx; external shell32 name 'ExtractAssociatedIconExW';
function ExtractAssociatedIconExA; external shell32 name 'ExtractAssociatedIconExA';
function ExtractAssociatedIconExW; external shell32 name 'ExtractAssociatedIconExW';
function ExtractIcon; external shell32 name 'ExtractIconW';
function ExtractIconA; external shell32 name 'ExtractIconA';
function ExtractIconW; external shell32 name 'ExtractIconW';
function ExtractIconEx; external shell32 name 'ExtractIconExW';
function ExtractIconExA; external shell32 name 'ExtractIconExA';
function ExtractIconExW; external shell32 name 'ExtractIconExW';
function FindExecutable; external shell32 name 'FindExecutableW';
function FindExecutableA; external shell32 name 'FindExecutableA';
function FindExecutableW; external shell32 name 'FindExecutableW';
function InitNetworkAddressControl; external shell32 name 'InitNetworkAddressControl' delayed;
function IsLFNDrive; external shell32 name 'IsLFNDriveW' delayed;
function IsLFNDriveA; external shell32 name 'IsLFNDriveA' delayed;
function IsLFNDriveW; external shell32 name 'IsLFNDriveW' delayed;
function SHAppBarMessage; external shell32 name 'SHAppBarMessage';
function SHCreateProcessAsUserW; external shell32 name 'SHCreateProcessAsUserW';
function Shell_NotifyIcon; external shell32 name 'Shell_NotifyIconW';
function Shell_NotifyIconA; external shell32 name 'Shell_NotifyIconA';
function Shell_NotifyIconW; external shell32 name 'Shell_NotifyIconW';
function Shell_NotifyIconGetRect; external shell32 name 'Shell_NotifyIconGetRect' delayed;
function ShellAbout; external shell32 name 'ShellAboutW';
function ShellAboutA; external shell32 name 'ShellAboutA';
function ShellAboutW; external shell32 name 'ShellAboutW';
function ShellExecute; external shell32 name 'ShellExecuteW';
function ShellExecuteA; external shell32 name 'ShellExecuteA';
function ShellExecuteW; external shell32 name 'ShellExecuteW';
function ShellExecuteEx; external shell32 name 'ShellExecuteExW';
function ShellExecuteExA; external shell32 name 'ShellExecuteExA';
function ShellExecuteExW; external shell32 name 'ShellExecuteExW';
function ShellMessageBox; external shell32 name 'ShellMessageBoxW';
function ShellMessageBoxA; external shell32 name 'ShellMessageBoxA';
function ShellMessageBoxW; external shell32 name 'ShellMessageBoxW';
function SHEmptyRecycleBin; external shell32 name 'SHEmptyRecycleBinW';
function SHEmptyRecycleBinA; external shell32 name 'SHEmptyRecycleBinA';
function SHEmptyRecycleBinW; external shell32 name 'SHEmptyRecycleBinW';
function SHEnumerateUnreadMailAccounts; external shell32 name 'SHEnumerateUnreadMailAccountsW' delayed;
function SHEnumerateUnreadMailAccountsA; external shell32 name 'SHEnumerateUnreadMailAccountsA' delayed;
function SHEnumerateUnreadMailAccountsW; external shell32 name 'SHEnumerateUnreadMailAccountsW' delayed;
function SHEvaluateSystemCommandTemplate; external shell32 name 'SHEvaluateSystemCommandTemplate' delayed;
function SHFileOperation; external shell32 name 'SHFileOperationW';
function SHFileOperationA; external shell32 name 'SHFileOperationA';
function SHFileOperationW; external shell32 name 'SHFileOperationW';
procedure SHFreeNameMappings; external shell32 name 'SHFreeNameMappings';
function SHGetDiskFreeSpace; external shell32 name 'SHGetDiskFreeSpaceExW';
function SHGetDiskFreeSpaceA; external shell32 name 'SHGetDiskFreeSpaceExA';
function SHGetDiskFreeSpaceW; external shell32 name 'SHGetDiskFreeSpaceExW';
function SHGetDiskFreeSpaceEx; external shell32 name 'SHGetDiskFreeSpaceExW';
function SHGetDiskFreeSpaceExA; external shell32 name 'SHGetDiskFreeSpaceExA';
function SHGetDiskFreeSpaceExW; external shell32 name 'SHGetDiskFreeSpaceExW';
function SHGetDriveMedia; external shell32 name 'SHGetDriveMedia' delayed;
function SHGetImageList; external shell32 name 'SHGetImageList' delayed;
function SHGetLocalizedName; external shell32 name 'SHGetLocalizedName' delayed;
function SHGetFileInfo; external shell32 name 'SHGetFileInfoW';
function SHGetFileInfoA; external shell32 name 'SHGetFileInfoA';
function SHGetFileInfoW; external shell32 name 'SHGetFileInfoW';
function SHGetNewLinkInfo; external shell32 name 'SHGetNewLinkInfoW';
function SHGetNewLinkInfoA; external shell32 name 'SHGetNewLinkInfoA';
function SHGetNewLinkInfoW; external shell32 name 'SHGetNewLinkInfoW';
function SHGetPropertyStoreForWindow; external shell32 name 'SHGetPropertyStoreForWindow' delayed;
function SHGetStockIconInfo; external shell32 name 'SHGetStockIconInfo' delayed;
function SHGetUnreadMailCount; external shell32 name 'SHGetUnreadMailCountW' delayed;
function SHGetUnreadMailCountA; external shell32 name 'SHGetUnreadMailCountA' delayed;
function SHGetUnreadMailCountW; external shell32 name 'SHGetUnreadMailCountW' delayed;
function SHInvokePrinterCommand; external shell32 name 'SHInvokePrinterCommandW';
function SHInvokePrinterCommandA; external shell32 name 'SHInvokePrinterCommandA';
function SHInvokePrinterCommandW; external shell32 name 'SHInvokePrinterCommandW';
function SHIsFileAvailableOffline; external shell32 name 'SHIsFileAvailableOffline';
function SHLoadNonloadedIconOverlayIdentifiers; external shell32 name 'SHLoadNonloadedIconOverlayIdentifiers';
function SHQueryRecycleBin; external shell32 name 'SHQueryRecycleBinW';
function SHQueryRecycleBinA; external shell32 name 'SHQueryRecycleBinA';
function SHQueryRecycleBinW; external shell32 name 'SHQueryRecycleBinW';
function SHQueryUserNotificationState; external shell32 name 'SHQueryUserNotificationState' delayed;
function SHRemoveLocalizedName; external shell32 name 'SHRemoveLocalizedName' delayed;
function SHSetLocalizedName; external shell32 name 'SHSetLocalizedName' delayed;
function SHSetUnreadMailCount; external shell32 name 'SHSetUnreadMailCountW' delayed;
function SHSetUnreadMailCountA; external shell32 name 'SHSetUnreadMailCountA' delayed;
function SHSetUnreadMailCountW; external shell32 name 'SHSetUnreadMailCountW' delayed;
function SHTestTokenMembership; external shell32 name 'SHTestTokenMembership';

procedure InitVersionInfo;
var
  OSVersionInfo: TOSVersionInfo;
begin
  OSVersionInfo.dwOSVersionInfoSize := SizeOf(OSVersionInfo);
  if GetVersionEx(OSVersionInfo) then
    with OSVersionInfo do
    begin
      Win32Platform := dwPlatformId;
      Win32MajorVersion := dwMajorVersion;
      Win32MinorVersion := dwMinorVersion;
    end;
end;

class constructor _NOTIFYICONDATAA.Create;
begin
  InitVersionInfo;
end;

class function _NOTIFYICONDATAA.SizeOf: Integer;
begin
  if Win32MajorVersion >= 6 then
    // Size of complete structure
    Result := System.SizeOf(_NOTIFYICONDATAA)
  else
    // Platforms prior to Vista do not recognize the fields guidItem and hBalloonIcon
    Result := System.SizeOf(_NOTIFYICONDATAA) - System.SizeOf(TGUID) - System.SizeOf(sdaWindows.HICON);
end;

class constructor _NOTIFYICONDATAW.Create;
begin
  InitVersionInfo;
end;

class function _NOTIFYICONDATAW.SizeOf: Integer;
begin
  if Win32MajorVersion >= 6 then
    // Size of complete structure
    Result := System.SizeOf(_NOTIFYICONDATAW)
  else
    // Platforms prior to Vista do not recognize the fields guidItem and hBalloonIcon
    Result := System.SizeOf(_NOTIFYICONDATAW) - System.SizeOf(TGUID) - System.SizeOf(sdaWindows.HICON);
end;

end.
