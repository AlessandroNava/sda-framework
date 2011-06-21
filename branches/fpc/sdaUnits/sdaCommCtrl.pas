unit sdaCommCtrl;

interface

{$INCLUDE 'sda.inc'}

uses
 sdaWindows, sdaMessages;

type
  HIMAGELIST = THandle;

{ From prsht.h -- Interface for the Windows Property Sheet Pages }

const
  MAXPROPPAGES = 100;

  PSP_DEFAULT             = $00000000;
  PSP_DLGINDIRECT         = $00000001;
  PSP_USEHICON            = $00000002;
  PSP_USEICONID           = $00000004;
  PSP_USETITLE            = $00000008;
  PSP_RTLREADING          = $00000010;
  PSP_HASHELP             = $00000020;
  PSP_USEREFPARENT        = $00000040;
  PSP_USECALLBACK         = $00000080;
  PSP_PREMATURE           = $00000400;
  PSP_HIDEHEADER          = $00000800;
  PSP_USEHEADERTITLE      = $00001000;
  PSP_USEHEADERSUBTITLE   = $00002000;

  PSPCB_RELEASE           = 1;
  PSPCB_CREATE            = 2;

  PSH_DEFAULT             = $00000000;
  PSH_PROPTITLE           = $00000001;
  PSH_USEHICON            = $00000002;
  PSH_USEICONID           = $00000004;
  PSH_PROPSHEETPAGE       = $00000008;
  PSH_WIZARDHASFINISH     = $00000010;
  PSH_MULTILINETABS       = $00000010;
  PSH_WIZARD              = $00000020;
  PSH_USEPSTARTPAGE       = $00000040;
  PSH_NOAPPLYNOW          = $00000080;
  PSH_USECALLBACK         = $00000100;
  PSH_HASHELP             = $00000200;
  PSH_MODELESS            = $00000400;
  PSH_RTLREADING          = $00000800;
  PSH_WIZARDCONTEXTHELP   = $00001000;
  PSH_WIZARD97            = $00002000;
  PSH_WATERMARK           = $00008000;
  PSH_USEHBMWATERMARK     = $00010000;  // user pass in a hbmWatermark instead of pszbmWatermark
  PSH_USEHPLWATERMARK     = $00020000;  //
  PSH_STRETCHWATERMARK    = $00040000;  // stretchwatermark also applies for the header
  PSH_HEADER              = $00080000;
  PSH_USEHBMHEADER        = $00100000;
  PSH_USEPAGELANG         = $00200000;  // use frame dialog template matched to page

  PSCB_INITIALIZED  = 1;
  PSCB_PRECREATE    = 2;

  PSN_FIRST               = -200;
  PSN_LAST                = -299;

  PSN_SETACTIVE           = PSN_FIRST - 0;
  PSN_KILLACTIVE          = PSN_FIRST - 1;
  PSN_APPLY               = PSN_FIRST - 2;
  PSN_RESET               = PSN_FIRST - 3;
  PSN_HELP                = PSN_FIRST - 5;
  PSN_WIZBACK             = PSN_FIRST - 6;
  PSN_WIZNEXT             = PSN_FIRST - 7;
  PSN_WIZFINISH           = PSN_FIRST - 8;
  PSN_QUERYCANCEL         = PSN_FIRST - 9;
  PSN_GETOBJECT           = PSN_FIRST - 10;

  PSNRET_NOERROR              = 0;
  PSNRET_INVALID              = 1;
  PSNRET_INVALID_NOCHANGEPAGE = 2;

  PSM_SETCURSEL           = WM_USER + 101;
  PSM_REMOVEPAGE          = WM_USER + 102;
  PSM_ADDPAGE             = WM_USER + 103;
  PSM_CHANGED             = WM_USER + 104;
  PSM_RESTARTWINDOWS      = WM_USER + 105;
  PSM_REBOOTSYSTEM        = WM_USER + 106;
  PSM_CANCELTOCLOSE       = WM_USER + 107;
  PSM_QUERYSIBLINGS       = WM_USER + 108;
  PSM_UNCHANGED           = WM_USER + 109;
  PSM_APPLY               = WM_USER + 110;
  PSM_SETTITLE            = WM_USER + 111;
  PSM_SETTITLEW           = WM_USER + 120;
  PSM_SETWIZBUTTONS       = WM_USER + 112;
  PSM_PRESSBUTTON         = WM_USER + 113;
  PSM_SETCURSELID         = WM_USER + 114;
  PSM_SETFINISHTEXT       = WM_USER + 115;
  PSM_SETFINISHTEXTW      = WM_USER + 121;
  PSM_GETTABCONTROL       = WM_USER + 116;
  PSM_ISDIALOGMESSAGE     = WM_USER + 117;

  PSWIZB_BACK             = $00000001;
  PSWIZB_NEXT             = $00000002;
  PSWIZB_FINISH           = $00000004;
  PSWIZB_DISABLEDFINISH   = $00000008;

  PSBTN_BACK              = 0;
  PSBTN_NEXT              = 1;
  PSBTN_FINISH            = 2;
  PSBTN_OK                = 3;
  PSBTN_APPLYNOW          = 4;
  PSBTN_CANCEL            = 5;
  PSBTN_HELP              = 6;
  PSBTN_MAX               = 6;

  ID_PSRESTARTWINDOWS     = 2;
  ID_PSREBOOTSYSTEM       = ID_PSRESTARTWINDOWS or 1;

  WIZ_CXDLG               = 276;
  WIZ_CYDLG               = 140;

  WIZ_CXBMP               = 80;

  WIZ_BODYX               = 92;
  WIZ_BODYCX              = 184;

  PROP_SM_CXDLG           = 212;
  PROP_SM_CYDLG           = 188;

  PROP_MED_CXDLG          = 227;
  PROP_MED_CYDLG          = 215;

  PROP_LG_CXDLG           = 252;
  PROP_LG_CYDLG           = 218;

type
  HPropSheetPage = Pointer;

  PPropSheetPageA = ^TPropSheetPageA;
  PPropSheetPageW = ^TPropSheetPageW;
  PPropSheetPage = PPropSheetPageW;

  LPFNPSPCALLBACKA = function(Wnd: HWnd; Msg: Integer;
    PPSP: PPropSheetPageA): Integer stdcall;
  LPFNPSPCALLBACKW = function(Wnd: HWnd; Msg: Integer;
    PPSP: PPropSheetPageW): Integer stdcall;
  LPFNPSPCALLBACK = LPFNPSPCALLBACKW;
  TFNPSPCallbackA = LPFNPSPCALLBACKA;
  TFNPSPCallbackW = LPFNPSPCALLBACKW;
  TFNPSPCallback = TFNPSPCallbackW;

  _PROPSHEETPAGEA = record
    dwSize: DWORD;
    dwFlags: DWORD;
    hInstance: THandle;
    case Integer of
      0: (
        pszTemplate: PAnsiChar);
      1: (
        pResource: Pointer;
        case Integer of
          0: (
            hIcon: THandle);
          1: (
            pszIcon: PAnsiChar;
            pszTitle: PAnsiChar;
            pfnDlgProc: Pointer;
            lParam: Longint;
            pfnCallback: TFNPSPCallbackA;
            pcRefParent: PInteger;
            pszHeaderTitle: PAnsiChar;      // this is displayed in the header
            pszHeaderSubTitle: PAnsiChar)); //
  end;
  _PROPSHEETPAGEW = record
    dwSize: DWORD;
    dwFlags: DWORD;
    hInstance: THandle;
    case Integer of
      0: (
        pszTemplate: PWideChar);
      1: (
        pResource: Pointer;
        case Integer of
          0: (
            hIcon: THandle);
          1: (
            pszIcon: PWideChar;
            pszTitle: PWideChar;
            pfnDlgProc: Pointer;
            lParam: Longint;
            pfnCallback: TFNPSPCallbackW;
            pcRefParent: PInteger;
            pszHeaderTitle: PWideChar;      // this is displayed in the header
            pszHeaderSubTitle: PWideChar)); //
  end;
  _PROPSHEETPAGE = _PROPSHEETPAGEW;
  TPropSheetPageA = _PROPSHEETPAGEA;
  TPropSheetPageW = _PROPSHEETPAGEW;
  TPropSheetPage = TPropSheetPageW;
  PROPSHEETPAGEA = _PROPSHEETPAGEA;
  PROPSHEETPAGEW = _PROPSHEETPAGEW;
  PROPSHEETPAGE = PROPSHEETPAGEW;


  PFNPROPSHEETCALLBACK = function(Wnd: HWnd; Msg: Integer;
    LParam: Integer): Integer stdcall;
  TFNPropSheetCallback = PFNPROPSHEETCALLBACK;

  PPropSheetHeaderA = ^TPropSheetHeaderA;
  PPropSheetHeaderW = ^TPropSheetHeaderW;
  PPropSheetHeader = PPropSheetHeaderW;
  _PROPSHEETHEADERA = record
    dwSize: DWORD;
    dwFlags: DWORD;
    hwndParent: HWnd;
    hInstance: THandle;
    case Integer of
      0: (
  hIcon: THandle);
      1: (
  pszIcon: PAnsiChar;
  pszCaption: PAnsiChar;
  nPages: Integer;
  case Integer of
    0: (
      nStartPage: Integer);
    1: (
      pStartPage: PAnsiChar;
      case Integer of
        0: (
    ppsp: PPropSheetPageA);
        1: (
    phpage: Pointer;
    pfnCallback: TFNPropSheetCallback;
                case Integer of
                  0: (
                    hbmWatermark: HBITMAP);
                  1: (
                    pszbmWatermark: PAnsiChar;
                    hplWatermark: HPALETTE;
                    // Header bitmap shares the palette with watermark
                    case Integer of
                      0: (
                        hbmHeader: HBITMAP);
                      1: (
                        pszbmHeader: PAnsiChar)))));
  end;
  _PROPSHEETHEADERW = record
    dwSize: DWORD;
    dwFlags: DWORD;
    hwndParent: HWnd;
    hInstance: THandle;
    case Integer of
      0: (
  hIcon: THandle);
      1: (
  pszIcon: PWideChar;
  pszCaption: PWideChar;
  nPages: Integer;
  case Integer of
    0: (
      nStartPage: Integer);
    1: (
      pStartPage: PWideChar;
      case Integer of
        0: (
    ppsp: PPropSheetPageW);
        1: (
    phpage: Pointer;
    pfnCallback: TFNPropSheetCallback;
                case Integer of
                  0: (
                    hbmWatermark: HBITMAP);
                  1: (
                    pszbmWatermark: PWideChar;
                    hplWatermark: HPALETTE;
                    // Header bitmap shares the palette with watermark
                    case Integer of
                      0: (
                        hbmHeader: HBITMAP);
                      1: (
                        pszbmHeader: PWideChar)))));
  end;
  _PROPSHEETHEADER = _PROPSHEETHEADERW;
  TPropSheetHeaderA = _PROPSHEETHEADERA;
  TPropSheetHeaderW = _PROPSHEETHEADERW;
  TPropSheetHeader = TPropSheetHeaderW;

  LPFNADDPROPSHEETPAGE = function(hPSP: HPropSheetPage;
    lParam: Longint): BOOL stdcall;
  TFNAddPropSheetPage = LPFNADDPROPSHEETPAGE;

  LPFNADDPROPSHEETPAGES = function(lpvoid: Pointer; pfn: TFNAddPropSheetPage;
    lParam: Longint): BOOL stdcall;
  TFNAddPropSheetPages = LPFNADDPROPSHEETPAGES;

function CreatePropertySheetPage(var PSP: TPropSheetPage): HPropSheetPage; stdcall;
function CreatePropertySheetPageA(var PSP: TPropSheetPageA): HPropSheetPage; stdcall;
function CreatePropertySheetPageW(var PSP: TPropSheetPageW): HPropSheetPage; stdcall;
function DestroyPropertySheetPage(hPSP: HPropSheetPage): BOOL; stdcall;
function PropertySheet(var PSH: TPropSheetHeader): Integer; stdcall;
function PropertySheetA(var PSH: TPropSheetHeaderA): Integer; stdcall;
function PropertySheetW(var PSH: TPropSheetHeaderW): Integer; stdcall;

{ From commctrl.h }

type
  tagINITCOMMONCONTROLSEX = packed record
    dwSize: DWORD;             // size of this structure
    dwICC: DWORD;              // flags indicating which classes to be initialized
  end;
  PInitCommonControlsEx = ^TInitCommonControlsEx;
  TInitCommonControlsEx = tagINITCOMMONCONTROLSEX;

const
  ICC_LISTVIEW_CLASSES   = $00000001; // listview, header
  ICC_TREEVIEW_CLASSES   = $00000002; // treeview, tooltips
  ICC_BAR_CLASSES        = $00000004; // toolbar, statusbar, trackbar, tooltips
  ICC_TAB_CLASSES        = $00000008; // tab, tooltips
  ICC_UPDOWN_CLASS       = $00000010; // updown
  ICC_PROGRESS_CLASS     = $00000020; // progress
  ICC_HOTKEY_CLASS       = $00000040; // hotkey
  ICC_ANIMATE_CLASS      = $00000080; // animate
  ICC_WIN95_CLASSES      = $000000FF;
  ICC_DATE_CLASSES       = $00000100; // month picker, date picker, time picker, updown
  ICC_USEREX_CLASSES     = $00000200; // comboex
  ICC_COOL_CLASSES       = $00000400; // rebar (coolbar) control
  ICC_INTERNET_CLASSES   = $00000800;
  ICC_PAGESCROLLER_CLASS = $00001000; // page scroller
  ICC_NATIVEFNTCTL_CLASS = $00002000; // native font control
  { For Windows >= XP }
  ICC_STANDARD_CLASSES   = $00004000;
  ICC_LINK_CLASS         = $00008000;

procedure InitCommonControls; stdcall;
function InitCommonControlsEx(var ICC: TInitCommonControlsEx): Bool; { Re-defined below }

const
  IMAGE_BITMAP = 0;

const
  ODT_HEADER              = 100;
  ODT_TAB                 = 101;
  ODT_LISTVIEW            = 102;


{ ====== Ranges for control message IDs ======================= }

const
  LVM_FIRST               = $1000;      { ListView messages }
  TV_FIRST                = $1100;      { TreeView messages }
  HDM_FIRST               = $1200;      { Header messages }
  TCM_FIRST               = $1300;      { Tab control messages }
  PGM_FIRST               = $1400;      { Pager control messages }
  { For Windows >= XP }
  ECM_FIRST               = $1500;      { Edit control messages }
  BCM_FIRST               = $1600;      { Button control messages }
  CBM_FIRST               = $1700;      { Combobox control messages }

  CCM_FIRST               = $2000;      { Common control shared messages }
  CCM_LAST                = CCM_FIRST + $200;

  CCM_SETBKCOLOR          = CCM_FIRST + 1; // lParam is bkColor

type
  tagCOLORSCHEME = packed record
    dwSize: DWORD;
    clrBtnHighlight: COLORREF;    // highlight color
    clrBtnShadow: COLORREF;       // shadow color
  end;
  PColorScheme = ^TColorScheme;
  TColorScheme = tagCOLORSCHEME;

const
  CCM_SETCOLORSCHEME      = CCM_FIRST + 2; // lParam is color scheme
  CCM_GETCOLORSCHEME      = CCM_FIRST + 3; // fills in COLORSCHEME pointed to by lParam
  CCM_GETDROPTARGET       = CCM_FIRST + 4;
  CCM_SETUNICODEFORMAT    = CCM_FIRST + 5;
  CCM_GETUNICODEFORMAT    = CCM_FIRST + 6;
  CCM_SETVERSION          = CCM_FIRST + $7;
  CCM_GETVERSION          = CCM_FIRST + $8;
  CCM_SETNOTIFYWINDOW     = CCM_FIRST + $9;   { wParam == hwndParent. }
  { For Windows >= XP }
  CCM_SETWINDOWTHEME      = CCM_FIRST + $B;
  CCM_DPISCALE            = CCM_FIRST + $C;   { wParam == Awareness }

  INFOTIPSIZE = 1024;  // for tooltips

{ ====== WM_NOTIFY codes (NMHDR.code values) ================== }

const
  NM_FIRST                 = 0-  0;       { generic to all controls }
  NM_LAST                  = 0- 99;

  LVN_FIRST                = 0-100;       { listview }
  LVN_LAST                 = 0-199;

  HDN_FIRST                = 0-300;       { header }
  HDN_LAST                 = 0-399;

  TVN_FIRST                = 0-400;       { treeview }
  TVN_LAST                 = 0-499;

  TTN_FIRST                = 0-520;       { tooltips }
  TTN_LAST                 = 0-549;

  TCN_FIRST                = 0-550;       { tab control }
  TCN_LAST                 = 0-580;

{ Shell reserved           (0-580) -  (0-589) }

  CDN_FIRST                = 0-601;       { common dialog (new) }
  CDN_LAST                 = 0-699;

  TBN_FIRST                = 0-700;       { toolbar }
  TBN_LAST                 = 0-720;

  UDN_FIRST                = 0-721;       { updown }
  UDN_LAST                 = 0-740;

  MCN_FIRST                = 0-750;       { monthcal }
  MCN_LAST                 = 0-759;

  DTN_FIRST                = 0-760;       { datetimepick }
  DTN_LAST                 = 0-799;

  CBEN_FIRST               = 0-800;       { combo box ex }
  CBEN_LAST                = 0-830;

  RBN_FIRST                = 0-831;       { coolbar }
  RBN_LAST                 = 0-859;

  IPN_FIRST               = 0-860;       { internet address }
  IPN_LAST                = 0-879;       { internet address }

  SBN_FIRST               = 0-880;       { status bar }
  SBN_LAST                = 0-899;

  PGN_FIRST               = 0-900;       { Pager Control }
  PGN_LAST                = 0-950;

  WMN_FIRST               = 0-1000;
  WMN_LAST                = 0-1200;

  { For Windows >= XP }
  BCN_FIRST               = 0-1250;
  BCN_LAST                = 0-1350;

  { For Windows >= Vista }
  TRBN_FIRST              = 0-1501;          { trackbar }
  TRBN_LAST               = 0-1519;

  MSGF_COMMCTRL_BEGINDRAG     = $4200;
  MSGF_COMMCTRL_SIZEHEADER    = $4201;
  MSGF_COMMCTRL_DRAGSELECT    = $4202;
  MSGF_COMMCTRL_TOOLBARCUST   = $4203;


{ ====== Generic WM_NOTIFY notification codes ================= }

const
  NM_OUTOFMEMORY           = NM_FIRST-1;
  NM_CLICK                 = NM_FIRST-2;
  NM_DBLCLK                = NM_FIRST-3;
  NM_RETURN                = NM_FIRST-4;
  NM_RCLICK                = NM_FIRST-5;
  NM_RDBLCLK               = NM_FIRST-6;
  NM_SETFOCUS              = NM_FIRST-7;
  NM_KILLFOCUS             = NM_FIRST-8;
  NM_CUSTOMDRAW            = NM_FIRST-12;
  NM_HOVER                 = NM_FIRST-13;
  NM_NCHITTEST             = NM_FIRST-14;   // uses NMMOUSE struct
  NM_KEYDOWN               = NM_FIRST-15;   // uses NMKEY struct
  NM_RELEASEDCAPTURE       = NM_FIRST-16;
  NM_SETCURSOR             = NM_FIRST-17;   // uses NMMOUSE struct
  NM_CHAR                  = NM_FIRST-18;   // uses NMCHAR struct
  NM_TOOLTIPSCREATED       = NM_FIRST-19;    { notify of when the tooltips window is create }
  NM_LDOWN                 = NM_FIRST-20;
  NM_RDOWN                 = NM_FIRST-21;
  NM_THEMECHANGED          = NM_FIRST-22;
  { For Windows >= Vista }
  NM_FONTCHANGED          = NM_FIRST-23;
  NM_CUSTOMTEXT           = NM_FIRST-24;    { uses NMCUSTOMTEXT struct }
  NM_TVSTATEIMAGECHANGING = NM_FIRST-24;    { uses NMTVSTATEIMAGECHANGING struct, defined after HTREEITEM }

type
  tagNMMOUSE = packed record
    hdr: TNMHdr;
    dwItemSpec: DWORD;
    dwItemData: DWORD;
    pt: TPoint;
    dwHitInfo: DWORD; // any specifics about where on the item or control the mouse is
  end;
  PNMMouse = ^TNMMouse;
  TNMMouse = tagNMMOUSE;

  PNMClick = ^TNMClick;
  TNMClick = tagNMMOUSE;

  // Generic structure to request an object of a specific type.
  tagNMOBJECTNOTIFY = packed record
    hdr: TNMHdr;
    iItem: Integer;
    piid: PGUID;
    pObject: Pointer;
    hResult: HRESULT;
    dwFlags: DWORD;    // control specific flags (hints as to where in iItem it hit)
  end;
  PNMObjectNotify = ^TNMObjectNotify;
  TNMObjectNotify = tagNMOBJECTNOTIFY;

  // Generic structure for a key
  tagNMKEY = packed record
    hdr: TNMHdr;
    nVKey: UINT;
    uFlags: UINT;
  end;
  PNMKey = ^TNMKey;
  TNMKey = tagNMKEY;

  // Generic structure for a character
  tagNMCHAR = packed record
    hdr: TNMHdr;
    ch: UINT;
    dwItemPrev: DWORD;     // Item previously selected
    dwItemNext: DWORD;     // Item to be selected
  end;
  PNMChar = ^TNMChar;
  TNMChar = tagNMCHAR;

  { For IE >= 0x0600 }
  tagNMCUSTOMTEXT = record
    hdr: NMHDR;
    hDC: HDC;
    lpString: LPCWSTR;
    nCount: Integer;
    lpRect: PRect;
    uFormat: UINT;
    fLink: BOOL;
  end;
  PNMCustomText = ^TNMCustomText;
  TNMCustomText = tagNMCUSTOMTEXT;

{ ==================== CUSTOM DRAW ========================================== }

const
  // custom draw return flags
  // values under 0x00010000 are reserved for global custom draw values.
  // above that are for specific controls
  CDRF_DODEFAULT          = $00000000;
  CDRF_NEWFONT            = $00000002;
  CDRF_SKIPDEFAULT        = $00000004;

  CDRF_NOTIFYPOSTPAINT    = $00000010;
  CDRF_NOTIFYITEMDRAW     = $00000020;
  CDRF_NOTIFYSUBITEMDRAW  = $00000020;  // flags are the same, we can distinguish by context
  CDRF_NOTIFYPOSTERASE    = $00000040;

  // drawstage flags
  // values under = $00010000 are reserved for global custom draw values.
  // above that are for specific controls
  CDDS_PREPAINT           = $00000001;
  CDDS_POSTPAINT          = $00000002;
  CDDS_PREERASE           = $00000003;
  CDDS_POSTERASE          = $00000004;
  // the = $000010000 bit means it's individual item specific
  CDDS_ITEM               = $00010000;
  CDDS_ITEMPREPAINT       = CDDS_ITEM or CDDS_PREPAINT;
  CDDS_ITEMPOSTPAINT      = CDDS_ITEM or CDDS_POSTPAINT;
  CDDS_ITEMPREERASE       = CDDS_ITEM or CDDS_PREERASE;
  CDDS_ITEMPOSTERASE      = CDDS_ITEM or CDDS_POSTERASE;
  CDDS_SUBITEM            = $00020000;

  // itemState flags
  CDIS_SELECTED       = $0001;
  CDIS_GRAYED         = $0002;
  CDIS_DISABLED       = $0004;
  CDIS_CHECKED        = $0008;
  CDIS_FOCUS          = $0010;
  CDIS_DEFAULT        = $0020;
  CDIS_HOT            = $0040;
  CDIS_MARKED         = $0080;
  CDIS_INDETERMINATE  = $0100;
  { For Windows >= XP }
  CDIS_SHOWKEYBOARDCUES = $0200;
  { For Windows >= Vista }
  CDIS_NEARHOT          = $0400;
  CDIS_OTHERSIDEHOT     = $0800;
  CDIS_DROPHILITED      = $1000;

type
  tagNMCUSTOMDRAWINFO = packed record
    hdr: TNMHdr;
    dwDrawStage: DWORD;
    hdc: HDC;
    rc: TRect;
    dwItemSpec: DWORD;  // this is control specific, but it's how to specify an item.  valid only with CDDS_ITEM bit set
    uItemState: UINT;
    lItemlParam: LPARAM;
  end;
  PNMCustomDraw = ^TNMCustomDraw;
  TNMCustomDraw = tagNMCUSTOMDRAWINFO;

  tagNMTTCUSTOMDRAW = packed record
    nmcd: TNMCustomDraw;
    uDrawFlags: UINT;
  end;
  PNMTTCustomDraw = ^TNMTTCustomDraw;
  TNMTTCustomDraw = tagNMTTCUSTOMDRAW;

{ ====== MENU HELP ========================== }

procedure MenuHelp(Msg: UINT; wParam: WPARAM; lParam: LPARAM;
  hMainMenu: HMENU; hInst: THandle; hwndStatus: HWND; lpwIDs: PUINT); stdcall;
function ShowHideMenuCtl(hWnd: HWND; uFlags: UINT; lpInfo: PINT): Bool; stdcall;
procedure GetEffectiveClientRect(hWnd: HWND; lprc: PRect; lpInfo: PINT); stdcall;

const
  MINSYSCOMMAND   = SC_SIZE;

{ ====== COMMON CONTROL STYLES ================ }

const
  CCS_TOP                 = $00000001;
  CCS_NOMOVEY             = $00000002;
  CCS_BOTTOM              = $00000003;
  CCS_NORESIZE            = $00000004;
  CCS_NOPARENTALIGN       = $00000008;
  CCS_ADJUSTABLE          = $00000020;
  CCS_NODIVIDER           = $00000040;
  CCS_VERT                = $00000080;
  CCS_LEFT                = (CCS_VERT or CCS_TOP);
  CCS_RIGHT               = (CCS_VERT or CCS_BOTTOM);
  CCS_NOMOVEX             = (CCS_VERT or CCS_NOMOVEY);

{ ======================  Native Font Control ============================== }

const
  WC_NATIVEFONTCTL            = 'NativeFontCtl';

  { style definition }
  NFS_EDIT                    = $0001;
  NFS_STATIC                  = $0002;
  NFS_LISTCOMBO               = $0004;
  NFS_BUTTON                  = $0008;
  NFS_ALL                     = $0010;

{ ====== TrackMouseEvent  ================================================== }

const
  WM_MOUSEHOVER                       = $02A1;
  WM_MOUSELEAVE                       = $02A3;

  TME_HOVER           = $00000001;
  TME_LEAVE           = $00000002;
  TME_NONCLIENT       = $00000010;
  TME_QUERY           = $40000000;
  TME_CANCEL          = $80000000;

  HOVER_DEFAULT       = $FFFFFFFF;

type
  tagTRACKMOUSEEVENT = packed record
    cbSize: DWORD;
    dwFlags: DWORD;
    hwndTrack: HWND;
    dwHoverTime: DWORD;
  end;
  PTrackMouseEvent = ^TTrackMouseEvent;
  TTrackMouseEvent = tagTRACKMOUSEEVENT;

{ Declare _TrackMouseEvent.  This API tries to use the window manager's }
{ implementation of TrackMouseEvent if it is present, otherwise it emulates. }
function _TrackMouseEvent(lpEventTrack: PTrackMouseEvent): BOOL; stdcall;

{ ====== Flat Scrollbar APIs========================================= }

const
  WSB_PROP_CYVSCROLL      = $00000001;
  WSB_PROP_CXHSCROLL      = $00000002;
  WSB_PROP_CYHSCROLL      = $00000004;
  WSB_PROP_CXVSCROLL      = $00000008;
  WSB_PROP_CXHTHUMB       = $00000010;
  WSB_PROP_CYVTHUMB       = $00000020;
  WSB_PROP_VBKGCOLOR      = $00000040;
  WSB_PROP_HBKGCOLOR      = $00000080;
  WSB_PROP_VSTYLE         = $00000100;
  WSB_PROP_HSTYLE         = $00000200;
  WSB_PROP_WINSTYLE       = $00000400;
  WSB_PROP_PALETTE        = $00000800;
  WSB_PROP_MASK           = $00000FFF;

  FSB_FLAT_MODE               = 2;
  FSB_ENCARTA_MODE            = 1;
  FSB_REGULAR_MODE            = 0;

function FlatSB_EnableScrollBar(hWnd: HWND; wSBflags, wArrows: UINT): BOOL; stdcall;
function FlatSB_ShowScrollBar(hWnd: HWND; wBar: Integer; bShow: BOOL): BOOL; stdcall;

function FlatSB_GetScrollRange(hWnd: HWND; nBar: Integer; var lpMinPos,
  lpMaxPos: Integer): BOOL; stdcall;
function FlatSB_GetScrollInfo(hWnd: HWND; BarFlag: Integer;
  var ScrollInfo: TScrollInfo): BOOL; stdcall;
function FlatSB_GetScrollPos(hWnd: HWND; nBar: Integer): Integer; stdcall;
function FlatSB_GetScrollProp(p1: HWND; propIndex: Integer;
  p3: PInteger): Bool; stdcall;

function FlatSB_SetScrollPos(hWnd: HWND; nBar, nPos: Integer;
  bRedraw: BOOL): Integer; stdcall;
function FlatSB_SetScrollInfo(hWnd: HWND; BarFlag: Integer;
  const ScrollInfo: TScrollInfo; Redraw: BOOL): Integer; stdcall;
function FlatSB_SetScrollRange(hWnd: HWND; nBar, nMinPos, nMaxPos: Integer;
  bRedraw: BOOL): BOOL; stdcall;
function FlatSB_SetScrollProp(p1: HWND; index: Integer; newValue: Integer;
  p4: Bool): Bool; stdcall;

function InitializeFlatSB(hWnd: HWND): Bool; stdcall;
procedure UninitializeFlatSB(hWnd: HWND); stdcall;

//
// subclassing stuff
//
type
  { For Windows >= XP }
  { $EXTERNALSYM SUBCLASSPROC}
  SUBCLASSPROC = function(hWnd: HWND; uMsg: UINT; wParam: WPARAM;
    lParam: LPARAM; uIdSubclass: UINT_PTR; dwRefData: DWORD_PTR): LRESULT; stdcall;
  TSubClassProc = SUBCLASSPROC;

{ For Windows >= XP }
function SetWindowSubclass(hWnd: HWND; pfnSubclass: SUBCLASSPROC;
  uIdSubclass: UINT_PTR; dwRefData: DWORD_PTR): BOOL;
function GetWindowSubclass(hWnd: HWND; pfnSubclass: SUBCLASSPROC;
  uIdSubclass: UINT_PTR; var pdwRefData: DWORD_PTR): BOOL;
function RemoveWindowSubclass(hWnd: HWND; pfnSubclass: SUBCLASSPROC;
  uIdSubclass: UINT_PTR): BOOL;
function DefSubclassProc(hWnd: HWND; uMsg: UINT; wParam: WPARAM;
  lParam: LPARAM): LRESULT;

{ For NTDDI_VERSION >= NTDDI_LONGHORN }
const
  LIM_SMALL = 0; // corresponds to SM_CXSMICON/SM_CYSMICON
  LIM_LARGE = 1; // corresponds to SM_CXICON/SM_CYICON

{ For NTDDI_VERSION >= NTDDI_LONGHORN }
function LoadIconMetric(hinst: HINST; pszName: LPCWSTR; lims: Integer;
  var phico: HICON): HResult;
function LoadIconWithScaleDown(hinst: HINST; pszName: LPCWSTR; cx: Integer;
  cy: Integer; var phico: HICON): HResult;

{ For Windows >= XP }
function DrawShadowText(hdc: HDC; pszText: LPCWSTR; cch: UINT; const prc: TRect;
  dwFlags: DWORD; crText, crShadow: COLORREF; ixOffset, iyOffset: Integer): Integer;

const
  { For Windows >= Vista }
  DCHF_TOPALIGN       = $00000002;  // default is center-align
  DCHF_HORIZONTAL     = $00000004;  // default is vertical
  DCHF_HOT            = $00000008;  // default is flat
  DCHF_PUSHED         = $00000010;  // default is flat
  DCHF_FLIPPED        = $00000020;  // if horiz, default is pointing right
                                        // if vert, default is pointing up
  { For Windows >= Vista }
  DCHF_TRANSPARENT    = $00000040;
  DCHF_INACTIVE       = $00000080;
  DCHF_NOBORDER       = $00000100;

{ For Windows >= Vista }
procedure DrawScrollArrow(hdc: HDC; lprc: PRect; wControlState: UINT;
  rgbOveride: COLORREF);

implementation

const
  cctrl = comctl32;

var
  ComCtl32DLL: THandle;
  _InitCommonControlsEx: function(var ICC: TInitCommonControlsEx): Bool stdcall;

procedure InitCommonControls; external cctrl name 'InitCommonControls';

procedure InitComCtl;
begin
  if ComCtl32DLL = 0 then
  begin
    ComCtl32DLL := GetModuleHandle(cctrl);
    if ComCtl32DLL <> 0 then
      @_InitCommonControlsEx := GetProcAddress(ComCtl32DLL, 'InitCommonControlsEx');
  end;
end;

function InitCommonControlsEx(var ICC: TInitCommonControlsEx): Bool;
begin
  if ComCtl32DLL = 0 then InitComCtl;
  Result := Assigned(_InitCommonControlsEx) and _InitCommonControlsEx(ICC);
end;

{ Property Sheets }
function CreatePropertySheetPage; external cctrl name 'CreatePropertySheetPageW';
function CreatePropertySheetPageA; external cctrl name 'CreatePropertySheetPageA';
function CreatePropertySheetPageW; external cctrl name 'CreatePropertySheetPageW';
function DestroyPropertySheetPage; external cctrl name 'DestroyPropertySheetPage';
function PropertySheet; external cctrl name 'PropertySheetW';
function PropertySheetA; external cctrl name 'PropertySheetA';
function PropertySheetW; external cctrl name 'PropertySheetW';

{ Menu Help }
procedure MenuHelp; external cctrl name 'MenuHelp';
function ShowHideMenuCtl; external cctrl name 'ShowHideMenuCtl';
procedure GetEffectiveClientRect; external cctrl name 'GetEffectiveClientRect';

{ TrackMouseEvent }

function _TrackMouseEvent;              external cctrl name '_TrackMouseEvent';

{ Flat Scrollbar APIs }

function FlatSB_EnableScrollBar;        external cctrl name 'FlatSB_EnableScrollBar';
function FlatSB_GetScrollInfo;          external cctrl name 'FlatSB_GetScrollInfo';
function FlatSB_GetScrollPos;           external cctrl name 'FlatSB_GetScrollPos';
function FlatSB_GetScrollProp;          external cctrl name 'FlatSB_GetScrollProp';
function FlatSB_GetScrollRange;         external cctrl name 'FlatSB_GetScrollRange';
function FlatSB_SetScrollInfo;          external cctrl name 'FlatSB_SetScrollInfo';
function FlatSB_SetScrollPos;           external cctrl name 'FlatSB_SetScrollPos';
function FlatSB_SetScrollProp;          external cctrl name 'FlatSB_SetScrollProp';
function FlatSB_SetScrollRange;         external cctrl name 'FlatSB_SetScrollRange';
function FlatSB_ShowScrollBar;          external cctrl name 'FlatSB_ShowScrollBar';
function InitializeFlatSB;              external cctrl name 'InitializeFlatSB';
procedure UninitializeFlatSB;           external cctrl name 'UninitializeFlatSB';

{ Subclassing }

var
  _SetWindowSubclass: function(hWnd: HWND; pfnSubclass: SUBCLASSPROC; 
    uIdSubclass: UINT_PTR; dwRefData: DWORD_PTR): BOOL; stdcall;

  _GetWindowSubclass: function(hWnd: HWND; pfnSubclass: SUBCLASSPROC;
    uIdSubclass: UINT_PTR; var pdwRefData: DWORD_PTR): BOOL; stdcall;

  _RemoveWindowSubclass: function(hWnd: HWND; pfnSubclass: SUBCLASSPROC;
    uIdSubclass: UINT_PTR): BOOL; stdcall;

  _DefSubclassProc: function(hWnd: HWND; uMsg: UINT; wParam: WPARAM;
    lParam: LPARAM): LRESULT; stdcall;

function SetWindowSubclass(hWnd: HWND; pfnSubclass: SUBCLASSPROC;
  uIdSubclass: UINT_PTR; dwRefData: DWORD_PTR): BOOL;
begin
  if Assigned(_SetWindowSubclass) then
    Result := _SetWindowSubclass(hWnd, pfnSubclass, uIdSubclass, dwRefData)
  else
  begin
    Result := False;
    if ComCtl32DLL > 0 then
    begin
      _SetWindowSubclass := GetProcAddress(ComCtl32DLL, 'SetWindowSubclass'); // Do not localize
      if Assigned(_SetWindowSubclass) then
        Result := _SetWindowSubclass(hWnd, pfnSubclass, uIdSubclass, dwRefData);
    end;
  end;
end;

function GetWindowSubclass(hWnd: HWND; pfnSubclass: SUBCLASSPROC;
  uIdSubclass: UINT_PTR; var pdwRefData: DWORD_PTR): BOOL;
begin
  if Assigned(_GetWindowSubclass) then
    Result := _GetWindowSubclass(hWnd, pfnSubclass, uIdSubclass, pdwRefData)
  else
  begin
    Result := False;
    if ComCtl32DLL > 0 then
    begin
      _GetWindowSubclass := GetProcAddress(ComCtl32DLL, 'GetWindowSubclass'); // Do not localize
      if Assigned(_GetWindowSubclass) then
        Result := _GetWindowSubclass(hWnd, pfnSubclass, uIdSubclass, pdwRefData);
    end;
  end;
end;

function RemoveWindowSubclass(hWnd: HWND; pfnSubclass: SUBCLASSPROC;
  uIdSubclass: UINT_PTR): BOOL;
begin
  if Assigned(_RemoveWindowSubclass) then
    Result := _RemoveWindowSubclass(hWnd, pfnSubclass, uIdSubclass)
  else
  begin
    Result := False;
    if ComCtl32DLL > 0 then
    begin
      _RemoveWindowSubclass := GetProcAddress(ComCtl32DLL, 'RemoveWindowSubclass'); // Do not localize
      if Assigned(_RemoveWindowSubclass) then
        Result := _RemoveWindowSubclass(hWnd, pfnSubclass, uIdSubclass);
    end;
  end;
end;

function DefSubclassProc(hWnd: HWND; uMsg: UINT; wParam: WPARAM;
  lParam: LPARAM): LRESULT;
begin
  if Assigned(_DefSubclassProc) then
    Result := _DefSubclassProc(hWnd, uMsg, wParam, lParam)
  else
  begin
    Result := 0;
    if ComCtl32DLL > 0 then
    begin
      _DefSubclassProc := GetProcAddress(ComCtl32DLL, 'DefSubclassProc'); // Do not localize
      if Assigned(_DefSubclassProc) then
        Result := _DefSubclassProc(hWnd, uMsg, wParam, lParam);
    end;
  end;
end;

var
  _LoadIconMetric: function(hinst: HINST; pszName: LPCWSTR; lims: Integer;
    var phico: HICON): HResult; stdcall;

  _LoadIconWithScaleDown: function(hinst: HINST; pszName: LPCWSTR; cx: Integer;
    cy: Integer; var phico: HICON): HResult; stdcall;

  _DrawShadowText: function(hdc: HDC; pszText: LPCWSTR; cch: UINT; const prc: TRect;
    dwFlags: DWORD; crText: COLORREF; crShadow: COLORREF; ixOffset: Integer;
    iyOffset: Integer): Integer; stdcall;

function LoadIconMetric(hinst: HINST; pszName: LPCWSTR; lims: Integer;
  var phico: HICON): HResult;
begin
  if Assigned(_LoadIconMetric) then
    Result := _LoadIconMetric(hinst, pszName, lims, phico)
  else
  begin
    Result := E_NOTIMPL;
    if ComCtl32DLL > 0 then
    begin
      _LoadIconMetric := GetProcAddress(ComCtl32DLL, 'LoadIconMetric'); // Do not localize
      if Assigned(_LoadIconMetric) then
        Result := _LoadIconMetric(hinst, pszName, lims, phico);
    end;
  end;
end;

function LoadIconWithScaleDown(hinst: HINST; pszName: LPCWSTR; cx: Integer;
  cy: Integer; var phico: HICON): HResult;
begin
  if Assigned(_LoadIconWithScaleDown) then
    Result := _LoadIconWithScaleDown(hinst, pszName, cx, cy, phico)
  else
  begin
    Result := E_NOTIMPL;
    if ComCtl32DLL > 0 then
    begin
      _LoadIconWithScaleDown := GetProcAddress(ComCtl32DLL, 'LoadIconWithScaleDown'); // Do not localize
      if Assigned(_LoadIconWithScaleDown) then
        Result := _LoadIconWithScaleDown(hinst, pszName, cx, cy, phico);
    end;
  end;
end;

function DrawShadowText(hdc: HDC; pszText: LPCWSTR; cch: UINT; const prc: TRect;
  dwFlags: DWORD; crText: COLORREF; crShadow: COLORREF; ixOffset: Integer;
  iyOffset: Integer): Integer;
begin
  if Assigned(_DrawShadowText) then
    Result := _DrawShadowText(hdc, pszText, cch, prc, dwFlags, crText, crShadow,
      ixOffset, iyOffset)
  else
  begin
    Result := 0;
    if ComCtl32DLL > 0 then
    begin
      _DrawShadowText := GetProcAddress(ComCtl32DLL, 'DrawShadowText'); // Do not localize
      if Assigned(_DrawShadowText) then
        Result := _DrawShadowText(hdc, pszText, cch, prc, dwFlags, crText,
          crShadow, ixOffset, iyOffset);
    end;
  end;
end;

var
  _DrawScrollArrow: procedure(hdc: HDC; lprc: PRect; wControlState: UINT;
    rgbOveride: COLORREF); stdcall;

procedure DrawScrollArrow(hdc: HDC; lprc: PRect; wControlState: UINT;
  rgbOveride: COLORREF);
begin
  if Assigned(_DrawScrollArrow) then
    _DrawScrollArrow(hdc, lprc, wControlState, rgbOveride)
  else
  begin
    if ComCtl32DLL > 0 then
    begin
      _DrawScrollArrow := GetProcAddress(ComCtl32DLL, 'DrawScrollArrow'); // Do not localize
      if Assigned(_DrawScrollArrow) then
        _DrawScrollArrow(hdc, lprc, wControlState, rgbOveride);
    end;
  end;
end;

end.
