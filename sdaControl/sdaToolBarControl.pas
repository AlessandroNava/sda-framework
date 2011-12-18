unit sdaToolBarControl;

interface

// http://msdn.microsoft.com/en-us/library/ff486067(VS.85).aspx

{$INCLUDE 'sda.inc'}

uses
  sdaWindows, sdaMessages;

const
  TOOLBARCLASSNAME = 'ToolbarWindow32';

type
  PTBButton = ^TTBButton;
  _TBBUTTON = packed record
    iBitmap: Integer;
    idCommand: Integer;
    fsState: Byte;
    fsStyle: Byte;
    bReserved: array[1..2] of Byte;
    dwData: Longint;
    iString: Integer;
  end;
  TTBButton = _TBBUTTON;

  PColorMap = ^TColorMap;
  _COLORMAP = packed record
    cFrom: TColorRef;
    cTo: TColorRef;
  end;
  TColorMap = _COLORMAP;
  COLORMAP = _COLORMAP;

function CreateToolBarEx(Wnd: HWnd; ws: Longint; ID: UINT;
  Bitmaps: Integer; BMInst: THandle; BMID: Cardinal; Buttons: PTBButton;
  NumButtons: Integer; dxButton, dyButton: Integer;
  dxBitmap, dyBitmap: Integer; StructSize: UINT): HWND; stdcall;

function CreateMappedBitmap(Instance: THandle; Bitmap: Integer;
  Flags: UINT; ColorMap: PColorMap; NumMaps: Integer): HBITMAP; stdcall;

const
  CMB_MASKED              = $02;

  TBSTATE_CHECKED         = $01;
  TBSTATE_PRESSED         = $02;
  TBSTATE_ENABLED         = $04;
  TBSTATE_HIDDEN          = $08;
  TBSTATE_INDETERMINATE   = $10;
  TBSTATE_WRAP            = $20;
  TBSTATE_ELLIPSES        = $40;
  TBSTATE_MARKED          = $80;

  TBSTYLE_BUTTON          = $00;
  TBSTYLE_SEP             = $01;
  TBSTYLE_CHECK           = $02;
  TBSTYLE_GROUP           = $04;
  TBSTYLE_CHECKGROUP      = TBSTYLE_GROUP or TBSTYLE_CHECK;
  TBSTYLE_DROPDOWN        = $08;
  TBSTYLE_AUTOSIZE        = $0010; // automatically calculate the cx of the button
  TBSTYLE_NOPREFIX        = $0020; // if this button should not have accel prefix

  TBSTYLE_TOOLTIPS        = $0100;
  TBSTYLE_WRAPABLE        = $0200;
  TBSTYLE_ALTDRAG         = $0400;
  TBSTYLE_FLAT            = $0800;
  TBSTYLE_LIST            = $1000;
  TBSTYLE_CUSTOMERASE     = $2000;
  TBSTYLE_REGISTERDROP    = $4000;
  TBSTYLE_TRANSPARENT     = $8000;
  TBSTYLE_EX_DRAWDDARROWS = $00000001;

  { For IE >= 0x0500 }
  BTNS_BUTTON             = TBSTYLE_BUTTON;
  BTNS_SEP                = TBSTYLE_SEP;
  BTNS_CHECK              = TBSTYLE_CHECK;
  BTNS_GROUP              = TBSTYLE_GROUP;
  BTNS_CHECKGROUP         = TBSTYLE_CHECKGROUP;
  BTNS_DROPDOWN           = TBSTYLE_DROPDOWN;
  BTNS_AUTOSIZE           = TBSTYLE_AUTOSIZE;
  BTNS_NOPREFIX           = TBSTYLE_NOPREFIX;
  { For IE >= 0x0501 }
  BTNS_SHOWTEXT           = $0040;  // ignored unless TBSTYLE_EX_MIXEDBUTTONS is set

  { For IE >= 0x0500 }
  BTNS_WHOLEDROPDOWN      = $0080;  // draw drop-down arrow, but without split arrow section

  { For IE >= 0x0501 }
  TBSTYLE_EX_MIXEDBUTTONS = $00000008;
  TBSTYLE_EX_HIDECLIPPEDBUTTONS = $00000010;  // don't show partially obscured buttons

  { For Windows >= XP }
  TBSTYLE_EX_DOUBLEBUFFER = $00000080; // Double Buffer the toolbar

type
  _NMTBCUSTOMDRAW = packed record
    nmcd: TNMCustomDraw;
    hbrMonoDither: HBRUSH;
    hbrLines: HBRUSH;                // For drawing lines on buttons
    hpenLines: HPEN;                 // For drawing lines on buttons
    clrText: COLORREF;               // Color of text
    clrMark: COLORREF;               // Color of text bk when marked. (only if TBSTATE_MARKED)
    clrTextHighlight: COLORREF;      // Color of text when highlighted
    clrBtnFace: COLORREF;            // Background of the button
    clrBtnHighlight: COLORREF;       // 3D highlight
    clrHighlightHotTrack: COLORREF;  // In conjunction with fHighlightHotTrack
                                     // will cause button to highlight like a menu
    rcText: TRect;                   // Rect for text
    nStringBkMode: Integer;
    nHLStringBkMode: Integer;

    { For Windows >= XP }
    iListGap: Integer;
  end;
  PNMTBCustomDraw = ^TNMTBCustomDraw;
  TNMTBCustomDraw = _NMTBCUSTOMDRAW;

const
  // Toolbar custom draw return flags
  TBCDRF_NOEDGES              = $00010000;  // Don't draw button edges
  TBCDRF_HILITEHOTTRACK       = $00020000;  // Use color of the button bk when hottracked
  TBCDRF_NOOFFSET             = $00040000;  // Don't offset button if pressed
  TBCDRF_NOMARK               = $00080000;  // Don't draw default highlight of image/text for TBSTATE_MARKED
  TBCDRF_NOETCHEDEFFECT       = $00100000;  // Don't draw etched effect for disabled items

  { For IE >= 0x0500 }
  TBCDRF_BLENDICON            = $00200000;  // Use ILD_BLEND50 on the icon image
  TBCDRF_NOBACKGROUND         = $00400000;  // Use ILD_BLEND50 on the icon image

  { For Windows >= Vista }
  TBCDRF_USECDCOLORS          = $00800000;  // Use CustomDrawColors to RenderText regardless of VisualStyle

  TB_ENABLEBUTTON         = WM_USER + 1;
  TB_CHECKBUTTON          = WM_USER + 2;
  TB_PRESSBUTTON          = WM_USER + 3;
  TB_HIDEBUTTON           = WM_USER + 4;
  TB_INDETERMINATE        = WM_USER + 5;
  TB_MARKBUTTON           = WM_USER + 6;
  TB_ISBUTTONENABLED      = WM_USER + 9;
  TB_ISBUTTONCHECKED      = WM_USER + 10;
  TB_ISBUTTONPRESSED      = WM_USER + 11;
  TB_ISBUTTONHIDDEN       = WM_USER + 12;
  TB_ISBUTTONINDETERMINATE = WM_USER + 13;
  TB_ISBUTTONHIGHLIGHTED   = WM_USER + 14;
  TB_SETSTATE             = WM_USER + 17;
  TB_GETSTATE             = WM_USER + 18;
  TB_ADDBITMAP            = WM_USER + 19;

type
  PTBAddBitmap = ^TTBAddBitmap;
  tagTBADDBITMAP = packed record
    hInst: THandle;
    nID: UINT;
  end;
  TTBAddBitmap = tagTBADDBITMAP;
  TBADDBITMAP = tagTBADDBITMAP;

const
  HINST_COMMCTRL = THandle(-1);

  IDB_STD_SMALL_COLOR     = 0;
  IDB_STD_LARGE_COLOR     = 1;
  IDB_VIEW_SMALL_COLOR    = 4;
  IDB_VIEW_LARGE_COLOR    = 5;
  IDB_HIST_SMALL_COLOR    = 8;
  IDB_HIST_LARGE_COLOR    = 9;
  IDB_HIST_NORMAL         = 12;
  IDB_HIST_HOT            = 13;
  IDB_HIST_DISABLED       = 14;
  IDB_HIST_PRESSED       = 15;

{ icon indexes for standard bitmap }
  STD_CUT                 = 0;
  STD_COPY                = 1;
  STD_PASTE               = 2;
  STD_UNDO                = 3;
  STD_REDOW               = 4;
  STD_DELETE              = 5;
  STD_FILENEW             = 6;
  STD_FILEOPEN            = 7;
  STD_FILESAVE            = 8;
  STD_PRINTPRE            = 9;
  STD_PROPERTIES          = 10;
  STD_HELP                = 11;
  STD_FIND                = 12;
  STD_REPLACE             = 13;
  STD_PRINT               = 14;

{ icon indexes for standard view bitmap }
  VIEW_LARGEICONS         = 0;
  VIEW_SMALLICONS         = 1;
  VIEW_LIST               = 2;
  VIEW_DETAILS            = 3;
  VIEW_SORTNAME           = 4;
  VIEW_SORTSIZE           = 5;
  VIEW_SORTDATE           = 6;
  VIEW_SORTTYPE           = 7;
  VIEW_PARENTFOLDER       = 8;
  VIEW_NETCONNECT         = 9;
  VIEW_NETDISCONNECT      = 10;
  VIEW_NEWFOLDER          = 11;
  VIEW_VIEWMENU           = 12;

{ icon indexes for history bitmap }
  HIST_BACK               = 0;
  HIST_FORWARD            = 1;
  HIST_FAVORITES          = 2;
  HIST_ADDTOFAVORITES     = 3;
  HIST_VIEWTREE           = 4;

  TB_ADDBUTTONSA          = WM_USER + 20;
  TB_INSERTBUTTONA        = WM_USER + 21;
  TB_DELETEBUTTON         = WM_USER + 22;
  TB_GETBUTTON            = WM_USER + 23;
  TB_BUTTONCOUNT          = WM_USER + 24;
  TB_COMMANDTOINDEX       = WM_USER + 25;

type
  PTBSaveParamsA = ^TTBSaveParamsA;
  PTBSaveParamsW = ^TTBSaveParamsW;
  PTBSaveParams = PTBSaveParamsW;
  tagTBSAVEPARAMSA = record
    hkr: THandle;
    pszSubKey: PAnsiChar;
    pszValueName: PAnsiChar;
  end;
  tagTBSAVEPARAMSW = record
    hkr: THandle;
    pszSubKey: PWideChar;
    pszValueName: PWideChar;
  end;
  tagTBSAVEPARAMS = tagTBSAVEPARAMSW;
  TTBSaveParamsA = tagTBSAVEPARAMSA;
  TTBSaveParamsW = tagTBSAVEPARAMSW;
  TTBSaveParams = TTBSaveParamsW;
  TBSAVEPARAMSA = tagTBSAVEPARAMSA;
  TBSAVEPARAMSW = tagTBSAVEPARAMSW;
  TBSAVEPARAMS = TBSAVEPARAMSW;

const
  TB_SAVERESTOREA          = WM_USER + 26;
  TB_ADDSTRINGA            = WM_USER + 28;
  TB_GETBUTTONTEXTA        = WM_USER + 45;
  TBN_GETBUTTONINFOA       = TBN_FIRST-0;

  TB_SAVERESTOREW          = WM_USER + 76;
  TB_ADDSTRINGW            = WM_USER + 77;
  TB_GETBUTTONTEXTW        = WM_USER + 75;
  TBN_GETBUTTONINFOW       = TBN_FIRST-20;

{$IFDEF UNICODE}
  TB_SAVERESTORE          = TB_SAVERESTOREW;
  TB_ADDSTRING            = TB_ADDSTRINGW;
  TB_GETBUTTONTEXT        = TB_GETBUTTONTEXTW;
  TBN_GETBUTTONINFO       = TBN_GETBUTTONINFOW;
{$ELSE}
  TB_SAVERESTORE          = TB_SAVERESTOREA;
  TB_ADDSTRING            = TB_ADDSTRINGA;
  TB_GETBUTTONTEXT        = TB_GETBUTTONTEXTA;
  TBN_GETBUTTONINFO       = TBN_GETBUTTONINFOA;
{$ENDIF}

  TB_CUSTOMIZE            = WM_USER + 27;
  TB_GETITEMRECT          = WM_USER + 29;
  TB_BUTTONSTRUCTSIZE     = WM_USER + 30;
  TB_SETBUTTONSIZE        = WM_USER + 31;
  TB_SETBITMAPSIZE        = WM_USER + 32;
  TB_AUTOSIZE             = WM_USER + 33;
  TB_GETTOOLTIPS          = WM_USER + 35;
  TB_SETTOOLTIPS          = WM_USER + 36;
  TB_SETPARENT            = WM_USER + 37;
  TB_SETROWS              = WM_USER + 39;
  TB_GETROWS              = WM_USER + 40;
  TB_SETCMDID             = WM_USER + 42;
  TB_CHANGEBITMAP         = WM_USER + 43;
  TB_GETBITMAP            = WM_USER + 44;
  TB_REPLACEBITMAP        = WM_USER + 46;
  TB_SETINDENT            = WM_USER + 47;
  TB_SETIMAGELIST         = WM_USER + 48;
  TB_GETIMAGELIST         = WM_USER + 49;
  TB_LOADIMAGES           = WM_USER + 50;
  TB_GETRECT              = WM_USER + 51; { wParam is the Cmd instead of index }
  TB_SETHOTIMAGELIST      = WM_USER + 52;
  TB_GETHOTIMAGELIST      = WM_USER + 53;
  TB_SETDISABLEDIMAGELIST = WM_USER + 54;
  TB_GETDISABLEDIMAGELIST = WM_USER + 55;
  TB_SETSTYLE             = WM_USER + 56;
  TB_GETSTYLE             = WM_USER + 57;
  TB_GETBUTTONSIZE        = WM_USER + 58;
  TB_SETBUTTONWIDTH       = WM_USER + 59;
  TB_SETMAXTEXTROWS       = WM_USER + 60;
  TB_GETTEXTROWS          = WM_USER + 61;

  TB_GETOBJECT            = WM_USER + 62;  // wParam == IID, lParam void **ppv
  TB_GETHOTITEM           = WM_USER + 71;
  TB_SETHOTITEM           = WM_USER + 72;  // wParam == iHotItem
  TB_SETANCHORHIGHLIGHT   = WM_USER + 73;  // wParam == TRUE/FALSE
  TB_GETANCHORHIGHLIGHT   = WM_USER + 74;
  TB_MAPACCELERATORA      = WM_USER + 78;  // wParam == ch, lParam int * pidBtn

type
  TBINSERTMARK = packed record
    iButton: Integer;
    dwFlags: DWORD;
  end;
  PTBInsertMark = ^TTBInsertMark;
  TTBInsertMark = TBINSERTMARK;

const
  TBIMHT_AFTER      = $00000001; // TRUE = insert After iButton, otherwise before
  TBIMHT_BACKGROUND = $00000002; // TRUE iff missed buttons completely

  TB_GETINSERTMARK        = WM_USER + 79;  // lParam == LPTBINSERTMARK
  TB_SETINSERTMARK        = WM_USER + 80;  // lParam == LPTBINSERTMARK
  TB_INSERTMARKHITTEST    = WM_USER + 81;  // wParam == LPPOINT lParam == LPTBINSERTMARK
  TB_MOVEBUTTON           = WM_USER + 82;
  TB_GETMAXSIZE           = WM_USER + 83;  // lParam == LPSIZE
  TB_SETEXTENDEDSTYLE     = WM_USER + 84;  // For TBSTYLE_EX_*
  TB_GETEXTENDEDSTYLE     = WM_USER + 85;  // For TBSTYLE_EX_*
  TB_GETPADDING           = WM_USER + 86;
  TB_SETPADDING           = WM_USER + 87;
  TB_SETINSERTMARKCOLOR   = WM_USER + 88;
  TB_GETINSERTMARKCOLOR   = WM_USER + 89;

  TB_SETCOLORSCHEME       = CCM_SETCOLORSCHEME;  // lParam is color scheme
  TB_GETCOLORSCHEME       = CCM_GETCOLORSCHEME;	// fills in COLORSCHEME pointed to by lParam

  TB_SETUNICODEFORMAT     = CCM_SETUNICODEFORMAT;
  TB_GETUNICODEFORMAT     = CCM_GETUNICODEFORMAT;

  TB_MAPACCELERATORW      = WM_USER + 90;  // wParam == ch, lParam int * pidBtn
{$IFDEF UNICODE}
  TB_MAPACCELERATOR       = TB_MAPACCELERATORW;
{$ELSE}
  TB_MAPACCELERATOR       = TB_MAPACCELERATORA;
{$ENDIF}

type
  TBREPLACEBITMAP = packed record
    hInstOld: THandle;
    nIDOld: Cardinal;
    hInstNew: THandle;
    nIDNew: Cardinal;
    nButtons: Integer;
  end;
  PTBReplaceBitmap = ^TTBReplaceBitmap;
  TTBReplaceBitmap = TBREPLACEBITMAP;

const
  TBBF_LARGE              = $0001;

  TB_GETBITMAPFLAGS       = WM_USER + 41;

  TBIF_IMAGE              = $00000001;
  TBIF_TEXT               = $00000002;
  TBIF_STATE              = $00000004;
  TBIF_STYLE              = $00000008;
  TBIF_LPARAM             = $00000010;
  TBIF_COMMAND            = $00000020;
  TBIF_SIZE               = $00000040;
  TBIF_BYINDEX            = $80000000;

type
  TBBUTTONINFOA = record
    cbSize: UINT;
    dwMask: DWORD;
    idCommand: Integer;
    iImage: Integer;
    fsState: Byte;
    fsStyle: Byte;
    cx: Word;
    lParam: DWORD;
    pszText: PAnsiChar;
    cchText: Integer;
  end;
  TBBUTTONINFOW = record
    cbSize: UINT;
    dwMask: DWORD;
    idCommand: Integer;
    iImage: Integer;
    fsState: Byte;
    fsStyle: Byte;
    cx: Word;
    lParam: DWORD;
    pszText: PWideChar;
    cchText: Integer;
  end;
  TBBUTTONINFO = TBBUTTONINFOW;
  PTBButtonInfoA = ^TTBButtonInfoA;
  PTBButtonInfoW = ^TTBButtonInfoW;
  PTBButtonInfo = PTBButtonInfoW;
  TTBButtonInfoA = TBBUTTONINFOA;
  TTBButtonInfoW = TBBUTTONINFOW;
  TTBButtonInfo = TTBButtonInfoW;

const
  // BUTTONINFO APIs do NOT support the string pool.
  TB_GETBUTTONINFOW        = WM_USER + 63;
  TB_SETBUTTONINFOW        = WM_USER + 64;
  TB_GETBUTTONINFOA        = WM_USER + 65;
  TB_SETBUTTONINFOA        = WM_USER + 66;
{$IFDEF UNICODE}
  TB_GETBUTTONINFO         = TB_GETBUTTONINFOW;
  TB_SETBUTTONINFO         = TB_SETBUTTONINFOW;
{$ELSE}
  TB_GETBUTTONINFO         = TB_GETBUTTONINFOA;
  TB_SETBUTTONINFO         = TB_SETBUTTONINFOA;
{$ENDIF}

  TB_INSERTBUTTONW        = WM_USER + 67;
  TB_ADDBUTTONSW          = WM_USER + 68;

  TB_HITTEST              = WM_USER + 69;

  // New post Win95/NT4 for InsertButton and AddButton.  if iString member
  // is a pointer to a string, it will be handled as a string like listview
  // = although LPSTR_TEXTCALLBACK is not supported;.
{$IFDEF UNICODE}
  TB_INSERTBUTTON         = TB_INSERTBUTTONW;
  TB_ADDBUTTONS           = TB_ADDBUTTONSW;
{$ELSE}
  TB_INSERTBUTTON         = TB_INSERTBUTTONA;
  TB_ADDBUTTONS           = TB_ADDBUTTONSA;
{$ENDIF}
  TB_SETDRAWTEXTFLAGS     = WM_USER + 70;  // wParam == mask lParam == bit values
  TB_GETSTRINGW           = WM_USER + 91;
  TB_GETSTRINGA           = WM_USER + 92;
{$IFDEF UNICODE}
  TB_GETSTRING            = TB_GETSTRINGW;
{$ELSE}
  TB_GETSTRING            = TB_GETSTRINGA;
{$ENDIF}

  { For Windows >= XP }
  TBMF_PAD                = $00000001;
  TBMF_BARPAD             = $00000002;
  TBMF_BUTTONSPACING      = $00000004;

type
  { For Windows >= XP }
  TBMETRICSA = packed record
    cbSize: Integer;
    dwMask: DWORD;
    cxPad: Integer;   { PAD }
    cyPad: Integer;
    cxBarPad: Integer;{ BARPAD }
    cyBarPad: Integer;
    cxButtonSpacing: Integer;{ BUTTONSPACING }
    cyButtonSpacing: Integer;
  end;
  TBMETRICSW = packed record
    cbSize: Integer;
    dwMask: DWORD;

    cxPad: Integer;   { PAD }
    cyPad: Integer;
    cxBarPad: Integer;{ BARPAD }
    cyBarPad: Integer;
    cxButtonSpacing: Integer;{ BUTTONSPACING }
    cyButtonSpacing: Integer;
  end;
  TBMETRICS = TBMETRICSW;
  PTBMetricsA = ^TTBMetricsA;
  PTBMetricsW = ^TTBMetricsW;
  PTBMetrics = PTBMetricsW;
  TTBMetricsA = TBMETRICSA;
  TTBMetricsW = TBMETRICSW;
  TTBMetrics = TTBMetricsW;

const
  { For Windows >= XP }
  TB_GETMETRICS           = WM_USER + 101;
  TB_SETMETRICS           = WM_USER + 102;

  { For Windows >= Vista }
  TB_GETITEMDROPDOWNRECT  = WM_USER + 103;
  TB_SETPRESSEDIMAGELIST  = WM_USER + 104;
  TB_GETPRESSEDIMAGELIST  = WM_USER + 105;

  { For Windows >= XP }
  TB_SETWINDOWTHEME       = CCM_SETWINDOWTHEME;

const
  TBN_BEGINDRAG           = TBN_FIRST-1;
  TBN_ENDDRAG             = TBN_FIRST-2;
  TBN_BEGINADJUST         = TBN_FIRST-3;
  TBN_ENDADJUST           = TBN_FIRST-4;
  TBN_RESET               = TBN_FIRST-5;
  TBN_QUERYINSERT         = TBN_FIRST-6;
  TBN_QUERYDELETE         = TBN_FIRST-7;
  TBN_TOOLBARCHANGE       = TBN_FIRST-8;
  TBN_CUSTHELP            = TBN_FIRST-9;
  TBN_DROPDOWN            = TBN_FIRST-10;
  TBN_CLOSEUP             = TBN_FIRST-11;
  TBN_GETOBJECT           = TBN_FIRST-12;
  TBN_RESTORE             = TBN_FIRST-21;
  TBN_SAVE                = TBN_FIRST-22;


type
  // Structure for TBN_HOTITEMCHANGE notification
  tagNMTBHOTITEM = packed record
    hdr: TNMHdr;
    idOld: Integer;
    idNew: Integer;
    dwFlags: DWORD;           // HICF_*
  end;
  PNMTBHotItem = ^TNMTBHotItem;
  TNMTBHotItem = tagNMTBHOTITEM;

const
  // Hot item change flags
  HICF_OTHER          = $00000000;
  HICF_MOUSE          = $00000001;          // Triggered by mouse
  HICF_ARROWKEYS      = $00000002;          // Triggered by arrow keys
  HICF_ACCELERATOR    = $00000004;          // Triggered by accelerator
  HICF_DUPACCEL       = $00000008;          // This accelerator is not unique
  HICF_ENTERING       = $00000010;          // idOld is invalid
  HICF_LEAVING        = $00000020;          // idNew is invalid
  HICF_RESELECT       = $00000040;          // hot item reselected

  TBN_HOTITEMCHANGE       = TBN_FIRST - 13;
  TBN_DRAGOUT             = TBN_FIRST - 14; // this is sent when the user clicks down on a button then drags off the button
  TBN_DELETINGBUTTON      = TBN_FIRST - 15; // uses TBNOTIFY
  TBN_GETDISPINFOA        = TBN_FIRST - 16; // This is sent when the  toolbar needs  some display information
  TBN_GETDISPINFOW        = TBN_FIRST - 17; // This is sent when the  toolbar needs  some display information
  TBN_GETINFOTIPA         = TBN_FIRST - 18;
  TBN_GETINFOTIPW         = TBN_FIRST - 19;

type
  tagNMTBGETINFOTIPA = record
    hdr: TNMHdr;
    pszText: PAnsiChar;
    cchTextMax: Integer;
    iItem: Integer;
    lParam: LPARAM;
  end;
  tagNMTBGETINFOTIPW = record
    hdr: TNMHdr;
    pszText: PWideChar;
    cchTextMax: Integer;
    iItem: Integer;
    lParam: LPARAM;
  end;
  tagNMTBGETINFOTIP = tagNMTBGETINFOTIPW;
  PNMTBGetInfoTipA = ^TNMTBGetInfoTipA;
  PNMTBGetInfoTipW = ^TNMTBGetInfoTipW;
  PNMTBGetInfoTip = PNMTBGetInfoTipW;
  TNMTBGetInfoTipA = tagNMTBGETINFOTIPA;
  TNMTBGetInfoTipW = tagNMTBGETINFOTIPW;
  TNMTBGetInfoTip = TNMTBGetInfoTipW;

const
  TBNF_IMAGE              = $00000001;
  TBNF_TEXT               = $00000002;
  TBNF_DI_SETITEM         = $10000000;

type
  NMTBDISPINFOA = record
    hdr: TNMHdr;
    dwMask: DWORD;      // [in] Specifies the values requested .[out] Client ask the data to be set for future use
    idCommand: Integer; // [in] id of button we're requesting info for
    lParam: DWORD;      // [in] lParam of button
    iImage: Integer;    // [out] image index
    pszText: PAnsiChar; // [out] new text for item
    cchText: Integer;   // [in] size of buffer pointed to by pszText
  end;
  NMTBDISPINFOW = record
    hdr: TNMHdr;
    dwMask: DWORD;      // [in] Specifies the values requested .[out] Client ask the data to be set for future use
    idCommand: Integer; // [in] id of button we're requesting info for
    lParam: DWORD;      // [in] lParam of button
    iImage: Integer;    // [out] image index
    pszText: PWideChar; // [out] new text for item
    cchText: Integer;   // [in] size of buffer pointed to by pszText
  end;
  NMTBDISPINFO = NMTBDISPINFOW;
  PNMTBDispInfoA = ^TNMTBDispInfoA;
  PNMTBDispInfoW = ^TNMTBDispInfoW;
  PNMTBDispInfo = PNMTBDispInfoW;
  TNMTBDispInfoA = NMTBDISPINFOA;
  TNMTBDispInfoW = NMTBDISPINFOW;
  TNMTBDispInfo = TNMTBDispInfoW;

const
  // Return codes for TBN_DROPDOWN
  TBDDRET_DEFAULT         = 0;
  TBDDRET_NODEFAULT       = 1;
  TBDDRET_TREATPRESSED    = 2;       // Treat as a standard press button

type
  tagNMTOOLBARA = record
    hdr: TNMHdr;
    iItem: Integer;
    tbButton: TTBButton;
    cchText: Integer;
    pszText: PAnsiChar;
  end;
  tagNMTOOLBARW = record
    hdr: TNMHdr;
    iItem: Integer;
    tbButton: TTBButton;
    cchText: Integer;
    pszText: PWideChar;
  end;
  tagNMTOOLBAR = tagNMTOOLBARW;
  PNMToolBarA = ^TNMToolBarA;
  PNMToolBarW = ^TNMToolBarW;
  PNMToolBar = PNMToolBarW;
  TNMToolBarA = tagNMTOOLBARA;
  TNMToolBarW = tagNMTOOLBARW;
  TNMToolBar = TNMToolBarW;

type
  TSdaToolBarControl = record
  private
    FHandle: HWND;
    function GetButtonCount: Integer;
    function GetDisabledImages: HIMAGELIST;
    function GetHotImages: HIMAGELIST;
    function GetImages: HIMAGELIST;
    procedure SetDisabledImages(const Value: HIMAGELIST);
    procedure SetHotImages(const Value: HIMAGELIST);
    procedure SetImages(const Value: HIMAGELIST);
    function GetPressedImages: HIMAGELIST;
    procedure SetPressedImages(const Value: HIMAGELIST);
    function GetButtonEnabled(Index: Integer): Boolean;
    function GetButtonVisible(Index: Integer): Boolean;
    procedure SetButtonEnabled(Index: Integer; const Value: Boolean);
    procedure SetButtonVisible(Index: Integer; const Value: Boolean);
    function GetButtonChecked(Index: Integer): Boolean;
    procedure SetButtonChecked(Index: Integer; const Value: Boolean);
    function GetHotButton: Integer;
    procedure SetHotButton(const Value: Integer);
    function GetIndent: Integer;
    procedure SetIndent(const Value: Integer);
    function GetButtonCommand(Index: Integer): Integer;
    procedure SetButtonCommand(Index: Integer; const Value: Integer);
    function GetButtonPressed(Index: Integer): Boolean;
    procedure SetButtonPressed(Index: Integer; const Value: Boolean);
    function GetButtonRect(Index: Integer): TRect;
    function GetExStyle: DWORD;
    procedure SetExStyle(const Value: DWORD);
  public
    property Handle: HWND read FHandle write FHandle;
    class function CreateHandle(Style: DWORD; Parent: HWND): HWND; static;
    procedure DestroyHandle;
    class operator Implicit(Value: HWND): TSdaToolBarControl;
    class operator Explicit(const Value: TSdaToolBarControl): HWND;

    procedure AddButton(Command: Integer; ImageIndex: Integer = -1;
       const Caption: string = ''; Style: DWORD = BTNS_BUTTON or BTNS_AUTOSIZE;
       State: DWORD = TBSTATE_ENABLED);
    procedure InsertButton(Index: Integer; Command: Integer;
      ImageIndex: Integer = -1; const Caption: string = '';
      Style: DWORD = BTNS_BUTTON or BTNS_AUTOSIZE; State: DWORD = TBSTATE_ENABLED);
    procedure AddSeparator(Width: Integer = -1);

    procedure DeleteButton(Index: Integer);
    procedure AdjustSize;
    procedure DisplayCustomizeBox;
    procedure MoveButton(Index, NewIndex: Integer);
    procedure SetNotificationParent(Handler: HWND);
    function ButtonFromCommand(Command: Integer): Integer;

    property ExStyle: DWORD read GetExStyle write SetExStyle;

    property Images: HIMAGELIST read GetImages write SetImages;
    property HotImages: HIMAGELIST read GetHotImages write SetHotImages;
    property PressedImages: HIMAGELIST read GetPressedImages write SetPressedImages;
    property DisabledImages: HIMAGELIST read GetDisabledImages write SetDisabledImages;

    property ButtonCount: Integer read GetButtonCount;
    property ButtonVisible[Index: Integer]: Boolean read GetButtonVisible
      write SetButtonVisible;
    property ButtonEnabled[Index: Integer]: Boolean read GetButtonEnabled
      write SetButtonEnabled;
    property ButtonChecked[Index: Integer]: Boolean read GetButtonChecked
      write SetButtonChecked;
    property ButtonCommand[Index: Integer]: Integer read GetButtonCommand
      write SetButtonCommand;
    property ButtonPressed[Index: Integer]: Boolean read GetButtonPressed
      write SetButtonPressed;

    property ButtonRect[Index: Integer]: TRect read GetButtonRect;

    // Index of hot button - only for flat toolbars
    property HotButton: Integer read GetHotButton write SetHotButton;
    property Indent: Integer read GetIndent write SetIndent;
  end;

implementation

{ TSdaToolBarControl }

procedure TSdaToolBarControl.AddButton(Command: Integer; ImageIndex: Integer;
  const Caption: string; Style, State: DWORD);
var
  btn: TTBButton;
begin
  FillChar(btn, SizeOf(btn), 0);
  btn.iBitmap := ImageIndex;
  btn.idCommand := Command;
  btn.fsState := State;
  btn.fsStyle := Style;
  if Caption <> '' then btn.iString := NativeInt(PChar(Caption));
  SendMessage(FHandle, TB_ADDBUTTONS, 1, LPARAM(@btn));
end;

procedure TSdaToolBarControl.AddSeparator(Width: Integer);
var
  btn: TTBButton;
begin
  FillChar(btn, SizeOf(btn), 0);
  btn.iBitmap := Width;
  btn.fsStyle := TBSTYLE_SEP;
  SendMessage(FHandle, TB_ADDBUTTONS, 1, LPARAM(@btn));
end;

procedure TSdaToolBarControl.AdjustSize;
begin
  SendMessage(Handle, TB_AUTOSIZE, 0, 0);
end;

function TSdaToolBarControl.ButtonFromCommand(Command: Integer): Integer;
begin
  Result := SendMessage(handle, TB_COMMANDTOINDEX, Command, 0);
end;

class function TSdaToolBarControl.CreateHandle(Style: DWORD; Parent: HWND): HWND;
begin
  Result := CreateWindowEx(WS_EX_TRANSPARENT, TOOLBARCLASSNAME, nil,
    WS_CHILD or WS_CLIPCHILDREN or WS_CLIPSIBLINGS or WS_VISIBLE or (Style and $0000ffff),
    0, 0, 0, 0, Parent, 0, HInstance, nil);
  if Result <> 0 then
    SendMessage(Result, TB_BUTTONSTRUCTSIZE, SizeOf(TTBButton), 0);
end;

procedure TSdaToolBarControl.DeleteButton(Index: Integer);
begin
  SendMessage(Handle, TB_DELETEBUTTON, Index, 0);
end;

procedure TSdaToolBarControl.DestroyHandle;
begin
  DestroyWindow(FHandle);
  FHandle := 0;
end;

procedure TSdaToolBarControl.DisplayCustomizeBox;
begin
  SendMessage(Handle, TB_CUSTOMIZE, 0, 0);
end;

class operator TSdaToolBarControl.Explicit(const Value: TSdaToolBarControl): HWND;
begin
  Result := Value.Handle;
end;

function TSdaToolBarControl.GetButtonChecked(Index: Integer): Boolean;
begin
  Result := BOOL(SendMessage(Handle, TB_ISBUTTONCHECKED,
    GetButtonCommand(Index), 0));
end;

function TSdaToolBarControl.GetButtonCommand(Index: Integer): Integer;
var
  btn: TTBButton;
begin
  FillChar(btn, SizeOf(btn), 0);
  SendMessage(Handle, TB_GETBUTTON, Index, LPARAM(@btn));
  Result := btn.idCommand;
end;

function TSdaToolBarControl.GetButtonCount: Integer;
begin
  Result := SendMessage(Handle, TB_BUTTONCOUNT, 0, 0);
end;

function TSdaToolBarControl.GetButtonEnabled(Index: Integer): Boolean;
begin
  Result := BOOL(SendMessage(Handle, TB_ISBUTTONENABLED,
    GetButtonCommand(Index), 0));
end;

function TSdaToolBarControl.GetButtonPressed(Index: Integer): Boolean;
begin
  Result := BOOL(SendMessage(Handle, TB_ISBUTTONPRESSED, GetButtonCommand(Index), 0));
end;

function TSdaToolBarControl.GetButtonRect(Index: Integer): TRect;
begin
  FillChar(Result, SizeOf(Result), 0);
  SendMessage(Handle, TB_GETITEMRECT, Index, LPARAM(@Result));
end;

function TSdaToolBarControl.GetButtonVisible(Index: Integer): Boolean;
begin
  Result := not BOOL(SendMessage(Handle, TB_ISBUTTONHIDDEN,
    GetButtonCommand(Index), 0));
end;

function TSdaToolBarControl.GetDisabledImages: HIMAGELIST;
begin
  Result := SendMessage(Handle, TB_GETDISABLEDIMAGELIST, 0, 0);
end;

function TSdaToolBarControl.GetExStyle: DWORD;
begin
  Result := SendMessage(Handle, TB_GETEXTENDEDSTYLE, 0, 0);
end;

function TSdaToolBarControl.GetHotButton: Integer;
begin
  Result := SendMessage(Handle, TB_GETHOTITEM, 0, 0);
end;

function TSdaToolBarControl.GetHotImages: HIMAGELIST;
begin
  Result := SendMessage(Handle, TB_GETHOTIMAGELIST, 0, 0);
end;

function TSdaToolBarControl.GetImages: HIMAGELIST;
begin
  Result := SendMessage(Handle, TB_GETIMAGELIST, 0, 0);
end;

function TSdaToolBarControl.GetIndent: Integer;
begin
  // TODO: ???
  Result := 0;
end;

function TSdaToolBarControl.GetPressedImages: HIMAGELIST;
begin
  Result := SendMessage(Handle, TB_GETPRESSEDIMAGELIST, 0, 0);
end;

class operator TSdaToolBarControl.Implicit(Value: HWND): TSdaToolBarControl;
begin
  Result.Handle := Value;
end;

procedure TSdaToolBarControl.InsertButton(Index, Command, ImageIndex: Integer;
  const Caption: string; Style, State: DWORD);
var
  btn: TTBButton;
begin
  FillChar(btn, SizeOf(btn), 0);
  btn.iBitmap := ImageIndex;
  btn.idCommand := Command;
  btn.fsState := State;
  btn.fsStyle := Style;
  if Caption <> '' then btn.iString := NativeInt(PChar(Caption));
  SendMessage(FHandle, TB_INSERTBUTTON, Index, LPARAM(@btn));
end;

procedure TSdaToolBarControl.MoveButton(Index, NewIndex: Integer);
begin
  SendMessage(Handle, TB_MOVEBUTTON, Index, NewIndex);
end;

procedure TSdaToolBarControl.SetButtonChecked(Index: Integer;
  const Value: Boolean);
begin
  SendMessage(Handle, TB_CHECKBUTTON, GetButtonCommand(Index),
    LPARAM(BOOL(Value)) and $0000ffff);
end;

procedure TSdaToolBarControl.SetButtonCommand(Index: Integer;
  const Value: Integer);
begin
  SendMessage(Handle, TB_SETCMDID, Index, Value);
end;

procedure TSdaToolBarControl.SetButtonEnabled(Index: Integer;
  const Value: Boolean);
begin
  SendMessage(Handle, TB_ENABLEBUTTON, GetButtonCommand(Index),
    LPARAM(BOOL(Value)) and $0000ffff);
end;

procedure TSdaToolBarControl.SetButtonPressed(Index: Integer;
  const Value: Boolean);
begin
  SendMessage(Handle, TB_PRESSBUTTON, GetButtonCommand(Index),
    LPARAM(BOOL(Value)) and $0000ffff);
end;

procedure TSdaToolBarControl.SetButtonVisible(Index: Integer;
  const Value: Boolean);
begin
  SendMessage(Handle, TB_ENABLEBUTTON, GetButtonCommand(Index),
    LPARAM(not BOOL(Value)) and $0000ffff);
end;

procedure TSdaToolBarControl.SetDisabledImages(const Value: HIMAGELIST);
begin
  SendMessage(Handle, TB_SETDISABLEDIMAGELIST, 0, Value);
end;

procedure TSdaToolBarControl.SetExStyle(const Value: DWORD);
begin
  SendMessage(Handle, TB_SETEXTENDEDSTYLE, 0, Value);
end;

procedure TSdaToolBarControl.SetHotButton(const Value: Integer);
begin
  SendMessage(Handle, TB_SETHOTITEM, Value, 0);
end;

procedure TSdaToolBarControl.SetHotImages(const Value: HIMAGELIST);
begin
  SendMessage(Handle, TB_SETHOTIMAGELIST, 0, Value);
end;

procedure TSdaToolBarControl.SetImages(const Value: HIMAGELIST);
begin
  SendMessage(Handle, TB_SETIMAGELIST, 0, Value);
end;

procedure TSdaToolBarControl.SetIndent(const Value: Integer);
begin
  SendMessage(Handle, TB_SETINDENT, Value, 0);
end;

procedure TSdaToolBarControl.SetNotificationParent(Handler: HWND);
begin
  SendMessage(Handle, TB_SETPARENT, Handler, 0);
end;

procedure TSdaToolBarControl.SetPressedImages(const Value: HIMAGELIST);
begin
  SendMessage(Handle, TB_SETPRESSEDIMAGELIST, 0, Value);
end;

function CreateToolBarEx; external comctl32 name 'CreateToolbarEx';
function CreateMappedBitmap; external comctl32 name 'CreateMappedBitmap';

end.
