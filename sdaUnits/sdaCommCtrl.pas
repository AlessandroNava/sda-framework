unit sdaCommCtrl;

interface

{$INCLUDE 'sda.inc'}

uses
 sdaWindows, sdaMessages;

type
  HIMAGELIST = THandle;

{ From commctrl.h }

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

implementation

end.
