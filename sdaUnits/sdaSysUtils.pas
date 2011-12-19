unit sdaSysUtils;

{$INCLUDE 'sda.inc'}

{$H+,B-,R-}
{$WARN SYMBOL_PLATFORM OFF}
{$WARN WIDECHAR_REDUCED OFF}
{$WARN UNSAFE_TYPE OFF}


interface

{$IFDEF WIN64}
  {$DEFINE CPUX64}
  {$WARN NO_RETVAL OFF}
{$ELSE}
  {$DEFINE CPUX86}
{$ENDIF}

uses
  sdaWindows;

{ File open modes }

const
  fmOpenRead       = $0000;
  fmOpenWrite      = $0001;
  fmOpenReadWrite  = $0002;
  fmExclusive      = $0004; // when used with FileCreate, atomically creates the file only if it doesn't exist, fails otherwise

  fmShareCompat    = $0000 platform; // DOS compatibility mode is not portable
  fmShareExclusive = $0010;
  fmShareDenyWrite = $0020;
  fmShareDenyRead  = $0030 platform; // write-only not supported on all platforms
  fmShareDenyNone  = $0040;

{ File attribute constants }

  faInvalid     = -1;
  faReadOnly    = $00000001;
  faHidden      = $00000002 platform; // only a convention on POSIX
  faSysFile     = $00000004 platform; // on POSIX system files are not regular files and not directories
  faVolumeID    = $00000008 platform deprecated;  // not used in Win32
  faDirectory   = $00000010;
  faArchive     = $00000020 platform;
  faNormal      = $00000080;
  faTemporary   = $00000100 platform;
  faSymLink     = $00000400 platform; // Available on POSIX and Vista and above
  faCompressed  = $00000800 platform;
  faEncrypted   = $00004000 platform;
  faVirtual     = $00010000 platform;
  faAnyFile     = $000001FF;

{ Units of time }

  HoursPerDay   = 24;
  MinsPerHour   = 60;
  SecsPerMin    = 60;
  MSecsPerSec   = 1000;
  MinsPerDay    = HoursPerDay * MinsPerHour;
  SecsPerDay    = MinsPerDay * SecsPerMin;
  SecsPerHour   = SecsPerMin * MinsPerHour;
  MSecsPerDay   = SecsPerDay * MSecsPerSec;

{ Days between 1/1/0001 and 12/31/1899 }

  DateDelta = 693594;

{ Days between TDateTime basis (12/31/1899) and Unix time_t basis (1/1/1970) }

  UnixDateDelta = 25569;

type
  TBytes = TArray<Byte>;

{ Standard Character set type }

  TSysCharSet = set of AnsiChar;

{ Set access to an integer }

  TIntegerSet = set of 0..SizeOf(Integer) * 8 - 1;

{ Type conversion records }

  WordRec = packed record
    case Integer of
      0: (Lo, Hi: Byte);
      1: (Bytes: array [0..1] of Byte);
  end;

  LongRec = packed record
    case Integer of
      0: (Lo, Hi: Word);
      1: (Words: array [0..1] of Word);
      2: (Bytes: array [0..3] of Byte);
  end;

  Int64Rec = packed record
    case Integer of
      0: (Lo, Hi: Cardinal);
      1: (Cardinals: array [0..1] of Cardinal);
      2: (Words: array [0..3] of Word);
      3: (Bytes: array [0..7] of Byte);
  end;

{ General arrays }

  PByteArray = ^TByteArray;
  TByteArray = array[0..32767] of Byte;

  PWordArray = ^TWordArray;
  TWordArray = array[0..16383] of Word;

{ Generic procedure pointer }

  TProcedure = procedure;

{ FloatToText, FloatToTextFmt, TextToFloat, and FloatToDecimal type codes }

  TFloatValue = (fvExtended, fvCurrency);

{ FloatToText format codes }

  TFloatFormat = (ffGeneral, ffExponent, ffFixed, ffNumber, ffCurrency);

{ FloatToDecimal result record }

  TFloatRec = packed record
    Exponent: Smallint;
    Negative: Boolean;
    Digits: array[0..20] of AnsiChar;
  end;

{ Date and time record }

  TTimeStamp = record
    Time: Integer;      { Number of milliseconds since midnight }
    Date: Integer;      { One plus number of days since 1/1/0001 }
  end;

{ MultiByte Character Set (MBCS) byte type }
  TMbcsByteType = (mbSingleByte, mbLeadByte, mbTrailByte);

type
  TLocaleID = LCID;

{ System Locale information record }
  TSysLocale = packed record
    DefaultLCID: TLocaleID;
    PriLangID: Integer;
    SubLangID: Integer;
    FarEast: Boolean;
    MiddleEast: Boolean;
  end;

{ This is used by TLanguages }
  TLangRec = packed record
    FName: string;
    FLCID: TLocaleID;
    FExt: string;
    FLocaleName: string;
  end;

type
{ This stores the languages that the system supports }
  TLanguages = class
  private
    FSysLangs: TArray<TLangRec>;
    class destructor Destroy;
    function LocalesCallback(LocaleID: PChar): Integer;
    function GetExt(Index: Integer): string;
    function GetID(Index: Integer): string;
    function GetLocaleID(Index: Integer): TLocaleID;
    function GetLocaleName(Index: Integer): string;
    function GetName(Index: Integer): string;
    function GetNameFromLocaleID(ID: TLocaleID): string;
    function GetNameFromLCID(const ID: string): string;
    function GetCount: integer;
    class function GetUserDefaultLocale: TLocaleID; static;
  public
    constructor Create;

    function IndexOf(ID: TLocaleID): Integer; overload;
    function IndexOf(const LocaleName: string): Integer; overload;
    property Count: Integer read GetCount;
    property Name[Index: Integer]: string read GetName;
    property NameFromLocaleID[ID: TLocaleID]: string read GetNameFromLocaleID;
    property NameFromLCID[const ID: string]: string read GetNameFromLCID;
    property ID[Index: Integer]: string read GetID;
    property LocaleName[Index: Integer]: string read GetLocaleName;
    property LocaleID[Index: Integer]: TLocaleID read GetLocaleID;
    property Ext[Index: Integer]: string read GetExt;
    class property UserDefaultLocale: TLocaleID read GetUserDefaultLocale;
  end;

{ Exceptions }

  PExceptionRecord = System.PExceptionRecord;

  Exception = class(TObject)
  private
    FMessage: string;
    FHelpContext: Integer;
    FInnerException: Exception;
    FStackInfo: Pointer;
    FAcquireInnerException: Boolean;
    class constructor Create;
    class destructor Destroy;
  protected
    procedure SetInnerException;
    procedure SetStackInfo(AStackInfo: Pointer);
    function GetStackTrace: string;
    // This virtual function will be called right before this exception is about to be
    // raised. In the case of an external non-Delphi exception, this is called soon after
    // the object is created since the "raise" condition is already in progress.
    procedure RaisingException(P: PExceptionRecord); virtual;
  public
    constructor Create(const Msg: string);
    constructor CreateFmt(const Msg: string; const Args: array of const);
    constructor CreateRes(Ident: Integer); overload;
    constructor CreateRes(ResStringRec: PResStringRec); overload;
    constructor CreateResFmt(Ident: Integer; const Args: array of const); overload;
    constructor CreateResFmt(ResStringRec: PResStringRec; const Args: array of const); overload;
    constructor CreateHelp(const Msg: string; AHelpContext: Integer);
    constructor CreateFmtHelp(const Msg: string; const Args: array of const;
      AHelpContext: Integer);
    constructor CreateResHelp(Ident: Integer; AHelpContext: Integer); overload;
    constructor CreateResHelp(ResStringRec: PResStringRec; AHelpContext: Integer); overload;
    constructor CreateResFmtHelp(ResStringRec: PResStringRec; const Args: array of const;
      AHelpContext: Integer); overload;
    constructor CreateResFmtHelp(Ident: Integer; const Args: array of const;
      AHelpContext: Integer); overload;
    destructor Destroy; override;
    function GetBaseException: Exception; virtual;
    function ToString: string; override;
    property BaseException: Exception read GetBaseException;
    property HelpContext: Integer read FHelpContext write FHelpContext;
    property InnerException: Exception read FInnerException;
    property Message: string read FMessage write FMessage;
    property StackTrace: string read GetStackTrace;
    property StackInfo: Pointer read FStackInfo;
  class var
    // Hook this function to return an opaque data structure that contains stack information
    // for the given exception information record. This function will be called when the
    // exception is about to be raised or if this is an external exception such as an
    // Access Violation, called soon after the object is created.
    GetExceptionStackInfoProc: function (P: PExceptionRecord): Pointer;
    // This function is called to return a string representation of the above opaque
    // data structure
    GetStackInfoStringProc: function (Info: Pointer): string;
    // This function is called when the destructor is called to clean up any data associated
    // with the given opaque data structure.
    CleanUpStackInfoProc: procedure (Info: Pointer);
    // Use this function to raise an exception instance from within an exception handler and
    // you want to "acquire" the active exception and chain it to the new exception and preserve
    // the context. This will cause the FInnerException field to get set with the exception
    // in currently in play.
    // You should only call this procedure from within an except block where the this new
    // exception is expected to be handled elsewhere.
    class procedure RaiseOuterException(E: Exception); static;
    // Provide another method that does the same thing as RaiseOuterException, but uses the
    // C++ vernacular of "throw"
    class procedure ThrowOuterException(E: Exception); static;
  end;

  EArgumentException = class(Exception);
  EArgumentOutOfRangeException = class(EArgumentException);
  EArgumentNilException = class(EArgumentException);

  EPathTooLongException = class(Exception);
  ENotSupportedException = class(Exception);
  EDirectoryNotFoundException = class(Exception);
  EFileNotFoundException = class(Exception);

  EInvalidOpException = class(Exception);

  ENoConstructException = class(Exception);

  ExceptClass = class of Exception;

  EAbort = class(Exception);

  EHeapException = class(Exception)
  private
    AllowFree: Boolean;
  protected
    procedure RaisingException(P: PExceptionRecord); override;
  public
    procedure FreeInstance; override;
  end;

  EOutOfMemory = class(EHeapException);

  EInOutError = class(Exception)
  public
    ErrorCode: Integer;
  end;

  EExternal = class(Exception)
  public
    ExceptionRecord: PExceptionRecord platform;
  end;

  EExternalException = class(EExternal);

  EIntError = class(EExternal);
  EDivByZero = class(EIntError);
  ERangeError = class(EIntError);
  EIntOverflow = class(EIntError);

  EMathError = class(EExternal);
  EInvalidOp = class(EMathError);
  EZeroDivide = class(EMathError);
  EOverflow = class(EMathError);
  EUnderflow = class(EMathError);

  EInvalidPointer = class(EHeapException);

  EInvalidCast = class(Exception);

  EConvertError = class(Exception);

  EAccessViolation = class(EExternal);
  EPrivilege = class(EExternal);
  EStackOverflow = class(EExternal)
    end deprecated;
  EControlC = class(EExternal);

  EVariantError = class(Exception);
  EPropReadOnly = class(Exception);
  EPropWriteOnly = class(Exception);
  EAssertionFailed = class(Exception);
  EAbstractError = class(Exception);
  EIntfCastError = class(Exception);
  EInvalidContainer = class(Exception);
  EInvalidInsert = class(Exception);
  EPackageError = class(Exception);

  EOSError = class(Exception)
  public
    ErrorCode: DWORD;
  end;

  EWin32Error = class(EOSError)
  end deprecated;

  ESafecallException = class(Exception);

  EMonitor = class(Exception);
  EMonitorLockException = class(EMonitor);
  ENoMonitorSupportException = class(EMonitor);

  EProgrammerNotFound = class(Exception);

  ENotImplemented = class(Exception);

var
{ Empty string and null string pointer. These constants are provided for
  backwards compatibility only.  }

  EmptyStr: string = '';
  NullStr: PString = @EmptyStr;

  EmptyWideStr: WideString = '';
  NullWideStr: PWideString = @EmptyWideStr;

  EmptyAnsiStr: AnsiString = '';
  NullAnsiStr: PAnsiString = @EmptyAnsiStr;

{ Win32 platform identifier.  This will be one of the following values:

    VER_PLATFORM_WIN32s
    VER_PLATFORM_WIN32_WINDOWS
    VER_PLATFORM_WIN32_NT

  See WINDOWS.PAS for the numerical values. }

  Win32Platform: Integer = 0;

{ Win32 OS version information -

  see TOSVersionInfo.dwMajorVersion/dwMinorVersion/dwBuildNumber }

  Win32MajorVersion: Integer = 0;
  Win32MinorVersion: Integer = 0;
  Win32BuildNumber: Integer = 0;

{ Win32 OS extra version info string -

  see TOSVersionInfo.szCSDVersion }

  Win32CSDVersion: string = '';

{ Win32 OS version tester }

function CheckWin32Version(AMajor: Integer; AMinor: Integer = 0): Boolean;

{ GetFileVersion returns the most significant 32 bits of a file's binary
  version number. Typically, this includes the major and minor version placed
  together in one 32-bit integer. It generally does not include the release
  or build numbers. It returns Cardinal(-1) if it failed. }
function GetFileVersion(const AFileName: string): Cardinal;

{ Currency and date/time formatting options

  The initial values of these variables are fetched from the system registry
  using the GetLocaleInfo function in the Win32 API. The description of each
  variable specifies the LOCALE_XXXX constant used to fetch the initial
  value.

  CurrencyString - Defines the currency symbol used in floating-point to
  decimal conversions. The initial value is fetched from LOCALE_SCURRENCY.

  CurrencyFormat - Defines the currency symbol placement and separation
  used in floating-point to decimal conversions. Possible values are:

    0 = '$1'
    1 = '1$'
    2 = '$ 1'
    3 = '1 $'

  The initial value is fetched from LOCALE_ICURRENCY.

  NegCurrFormat - Defines the currency format for used in floating-point to
  decimal conversions of negative numbers. Possible values are:

    0 = '($1)'      4 = '(1$)'      8 = '-1 $'      12 = '$ -1'
    1 = '-$1'       5 = '-1$'       9 = '-$ 1'      13 = '1- $'
    2 = '$-1'       6 = '1-$'      10 = '1 $-'      14 = '($ 1)'
    3 = '$1-'       7 = '1$-'      11 = '$ 1-'      15 = '(1 $)'

  The initial value is fetched from LOCALE_INEGCURR.

  ThousandSeparator - The character used to separate thousands in numbers
  with more than three digits to the left of the decimal separator. The
  initial value is fetched from LOCALE_STHOUSAND.  A value of #0 indicates
  no thousand separator character should be output even if the format string
  specifies thousand separators.

  DecimalSeparator - The character used to separate the integer part from
  the fractional part of a number. The initial value is fetched from
  LOCALE_SDECIMAL.  DecimalSeparator must be a non-zero value.

  CurrencyDecimals - The number of digits to the right of the decimal point
  in a currency amount. The initial value is fetched from LOCALE_ICURRDIGITS.

  DateSeparator - The character used to separate the year, month, and day
  parts of a date value. The initial value is fetched from LOCATE_SDATE.

  ShortDateFormat - The format string used to convert a date value to a
  short string suitable for editing. For a complete description of date and
  time format strings, refer to the documentation for the FormatDate
  function. The short date format should only use the date separator
  character and the  m, mm, d, dd, yy, and yyyy format specifiers. The
  initial value is fetched from LOCALE_SSHORTDATE.

  LongDateFormat - The format string used to convert a date value to a long
  string suitable for display but not for editing. For a complete description
  of date and time format strings, refer to the documentation for the
  FormatDate function. The initial value is fetched from LOCALE_SLONGDATE.

  TimeSeparator - The character used to separate the hour, minute, and
  second parts of a time value. The initial value is fetched from
  LOCALE_STIME.

  TimeAMString - The suffix string used for time values between 00:00 and
  11:59 in 12-hour clock format. The initial value is fetched from
  LOCALE_S1159.

  TimePMString - The suffix string used for time values between 12:00 and
  23:59 in 12-hour clock format. The initial value is fetched from
  LOCALE_S2359.

  ShortTimeFormat - The format string used to convert a time value to a
  short string with only hours and minutes. The default value is computed
  from LOCALE_ITIME and LOCALE_ITLZERO.

  LongTimeFormat - The format string used to convert a time value to a long
  string with hours, minutes, and seconds. The default value is computed
  from LOCALE_ITIME and LOCALE_ITLZERO.

  ShortMonthNames - Array of strings containing short month names. The mmm
  format specifier in a format string passed to FormatDate causes a short
  month name to be substituted. The default values are fecthed from the
  LOCALE_SABBREVMONTHNAME system locale entries.

  LongMonthNames - Array of strings containing long month names. The mmmm
  format specifier in a format string passed to FormatDate causes a long
  month name to be substituted. The default values are fecthed from the
  LOCALE_SMONTHNAME system locale entries.

  ShortDayNames - Array of strings containing short day names. The ddd
  format specifier in a format string passed to FormatDate causes a short
  day name to be substituted. The default values are fecthed from the
  LOCALE_SABBREVDAYNAME system locale entries.

  LongDayNames - Array of strings containing long day names. The dddd
  format specifier in a format string passed to FormatDate causes a long
  day name to be substituted. The default values are fecthed from the
  LOCALE_SDAYNAME system locale entries.

  ListSeparator - The character used to separate items in a list.  The
  initial value is fetched from LOCALE_SLIST.

  TwoDigitYearCenturyWindow - Determines what century is added to two
  digit years when converting string dates to numeric dates.  This value
  is subtracted from the current year before extracting the century.
  This can be used to extend the lifetime of existing applications that
  are inextricably tied to 2 digit year data entry.  The best solution
  to Year 2000 (Y2k) issues is not to accept 2 digit years at all - require
  4 digit years in data entry to eliminate century ambiguities.

  Examples:

  Current TwoDigitCenturyWindow  Century  StrToDate() of:
  Year    Value                  Pivot    '01/01/03' '01/01/68' '01/01/50'
  -------------------------------------------------------------------------
  1998    0                      1900     1903       1968       1950
  2002    0                      2000     2003       2068       2050
  1998    50 (default)           1948     2003       1968       1950
  2002    50 (default)           1952     2003       1968       2050
  2020    50 (default)           1970     2003       2068       2050
 }

const
  { Specifies the default value of the TwoDigitCenturyWindow }
  CDefaultTwoDigitYearCenturyWindow = 50;

var
  // Important: Do not change the order of these declarations, they must
  // match the declaration order of the fields in TFormatSettings exactly!
  CurrencyString: string deprecated 'Use FormatSettings.CurrencyString';
  CurrencyFormat: Byte deprecated 'Use FormatSettings.CurrencyFormat';
  CurrencyDecimals: Byte deprecated 'Use FormatSettings.CurrencyDecimals';
  DateSeparator: Char deprecated 'Use FormatSettings.DateSeparator';
  TimeSeparator: Char deprecated 'Use FormatSettings.TimeSeparator';
  ListSeparator: Char deprecated 'Use FormatSettings.ListSeparator';
  ShortDateFormat: string deprecated 'Use FormatSettings.ShortDateFormat';
  LongDateFormat: string deprecated 'Use FormatSettings.LongDateFormat';
  TimeAMString: string deprecated 'Use FormatSettings.TimeAMString';
  TimePMString: string deprecated 'Use FormatSettings.TimePMString';
  ShortTimeFormat: string deprecated 'Use FormatSettings.ShortTimeFormat';
  LongTimeFormat: string deprecated 'Use FormatSettings.LongTimeFormat';
  ShortMonthNames: array[1..12] of string deprecated 'Use FormatSettings.ShortMonthNames';
  LongMonthNames: array[1..12] of string deprecated 'Use FormatSettings.LongMonthNames';
  ShortDayNames: array[1..7] of string deprecated 'Use FormatSettings.ShortDayNames';
  LongDayNames: array[1..7] of string deprecated 'Use FormatSettings.LongDayNames';
  ThousandSeparator: Char deprecated 'Use FormatSettings.ThousandSeparator';
  DecimalSeparator: Char deprecated 'Use FormatSettings.DecimalSeparator';
  TwoDigitYearCenturyWindow: Word deprecated 'Use FormatSettings.TwoDigitYearCenturyWindow';
  NegCurrFormat: Byte deprecated 'Use FormatSettings.NegCurrFormat';

var
  SysLocale: TSysLocale;


{ Thread safe currency and date/time formatting

  The TFormatSettings record is designed to allow thread safe formatting,
  equivalent to the gloabal variables described above. Each of the
  formatting routines that use the gloabal variables have overloaded
  equivalents, requiring an additional parameter of type TFormatSettings.

  A TFormatSettings record must be populated before use. This can be done
  by calling TFormatSettings.Create and specifying the desired locale. To
  create a TFormatSettings record with the current default call the
  parameterless function Create or pass an empty string as the LocaleName.
  Note that some format specifiers still require specific thread locale
  settings (such as period/era names). }

type
  TFormatSettings = record
  strict private
    class function AdjustLocaleName(const LocaleName: string): string; static;
    class procedure GetDayNames(Locale: TLocaleID; var AFormatSettings: TFormatSettings); static;
    class procedure GetMonthNames(Locale: TLocaleID; var AFormatSettings: TFormatSettings); static;
    class function GetString(Locale: TLocaleID; LocaleItem, DefaultIndex: Integer;
      const DefaultValues: array of Pointer): string; static;
    class function TranslateDateFormat(Locale: TLocaleID; LocaleType: Integer;
      const Default: string; const Separator: Char): string; static;
  public
    // Important: Do not change the order of these declarations, they must
    // match the declaration order of the corresponding globals variables exactly!
    CurrencyString: string;
    CurrencyFormat: Byte;
    CurrencyDecimals: Byte;
    DateSeparator: Char;
    TimeSeparator: Char;
    ListSeparator: Char;
    ShortDateFormat: string;
    LongDateFormat: string;
    TimeAMString: string;
    TimePMString: string;
    ShortTimeFormat: string;
    LongTimeFormat: string;
    ShortMonthNames: array[1..12] of string;
    LongMonthNames: array[1..12] of string;
    ShortDayNames: array[1..7] of string;
    LongDayNames: array[1..7] of string;
    ThousandSeparator: Char;
    DecimalSeparator: Char;
    TwoDigitYearCenturyWindow: Word;
    NegCurrFormat: Byte;
    // Creates a TFormatSettings record with current default values provided
    // by the operating system.
    class function Create: TFormatSettings; overload; static; inline;
    // Creates a TFormatSettings record with values provided by the operating
    // system for the specified locale. The locale is an LCID on Windows
    // platforms, or a locale_t on Posix platforms.
    class function Create(Locale: TLocaleID): TFormatSettings; overload; platform; static;
    // Creates a TFormatSettings record with values provided by the operating
    // system for the specified locale name in the "Language-Country" format.
    // Example: 'en-US' for U.S. English settings or 'en-UK' for UK English settings.
    class function Create(const LocaleName: string): TFormatSettings; overload; static;
  end;

  TLocaleOptions = (loInvariantLocale, loUserLocale);

var
  // Note: Using the global FormatSettings variable corresponds to using the
  // individual global formatting variables and is not thread-safe.
  FormatSettings: TFormatSettings absolute CurrencyString;

const
  MaxEraCount = 7;

var
  EraNames: array [1..MaxEraCount] of string;
  EraYearOffsets: array [1..MaxEraCount] of Integer;

const
  PathDelim  = '\';
  DriveDelim = ':';
  PathSep    = ';';

function Languages: TLanguages;

{ Exit procedure handling }

{ AddExitProc adds the given procedure to the run-time library's exit
  procedure list. When an application terminates, its exit procedures are
  executed in reverse order of definition, i.e. the last procedure passed
  to AddExitProc is the first one to get executed upon termination. }

procedure AddExitProc(Proc: TProcedure);

{ String handling routines }

{ NewStr allocates a string on the heap. NewStr is provided for backwards
  compatibility only. }

function NewStr(const S: AnsiString): PAnsiString; deprecated;

{ DisposeStr disposes a string pointer that was previously allocated using
  NewStr. DisposeStr is provided for backwards compatibility only. }

procedure DisposeStr(P: PAnsiString); deprecated;

{ AssignStr assigns a new dynamically allocated string to the given string
  pointer. AssignStr is provided for backwards compatibility only. }

procedure AssignStr(var P: PAnsiString; const S: AnsiString); deprecated;

{ AppendStr appends S to the end of Dest. AppendStr is provided for
  backwards compatibility only. Use "Dest := Dest + S" instead. }

procedure AppendStr(var Dest: AnsiString; const S: AnsiString); deprecated;

{ UpperCase converts all ASCII characters in the given string to upper case.
  The conversion affects only 7-bit ASCII characters between 'a' and 'z'. To
  convert 8-bit international characters, use AnsiUpperCase. }

function UpperCase(const S: string): string; overload;
function UpperCase(const S: string; LocaleOptions: TLocaleOptions): string; overload; inline;

{ LowerCase converts all ASCII characters in the given string to lower case.
  The conversion affects only 7-bit ASCII characters between 'A' and 'Z'. To
  convert 8-bit international characters, use AnsiLowerCase. }

function LowerCase(const S: string): string; overload;
function LowerCase(const S: string; LocaleOptions: TLocaleOptions): string; overload; inline;

{ CompareStr compares S1 to S2, with case-sensitivity. The return value is
  less than 0 if S1 < S2, 0 if S1 = S2, or greater than 0 if S1 > S2. The
  compare operation is based on the 8-bit ordinal value of each character
  and is not affected by the current user locale. }

function CompareStr(const S1, S2: string): Integer; overload;
function CompareStr(const S1, S2: string; LocaleOptions: TLocaleOptions): Integer; overload;

{ SameStr compares S1 to S2, with case-sensitivity. Returns true if
  S1 and S2 are the equal, that is, if CompareStr would return 0. }

function SameStr(const S1, S2: string): Boolean; overload; inline;
function SameStr(const S1, S2: string; LocaleOptions: TLocaleOptions): Boolean; overload;

{ CompareMem performs a binary compare of Length bytes of memory referenced
  by P1 to that of P2.  CompareMem returns True if the memory referenced by
  P1 is identical to that of P2. }

function CompareMem(P1, P2: Pointer; Length: Integer): Boolean;

{ CompareText compares S1 to S2, without case-sensitivity. The return value
  is the same as for CompareStr. The compare operation is based on the 8-bit
  ordinal value of each character, after converting 'a'..'z' to 'A'..'Z',
  and is not affected by the current user locale. }

function CompareText(const S1, S2: string): Integer; overload;
function CompareText(const S1, S2: string; LocaleOptions: TLocaleOptions): Integer; overload;

{ SameText compares S1 to S2, without case-sensitivity. Returns true if
  S1 and S2 are the equal, that is, if CompareText would return 0. SameText
  has the same 8-bit limitations as CompareText }

function SameText(const S1, S2: string): Boolean; overload; inline;
function SameText(const S1, S2: string; LocaleOptions: TLocaleOptions): Boolean; overload;

{ AnsiUpperCase converts all characters in the given string to upper case.
  The conversion uses the current user locale. }

function AnsiUpperCase(const S: string): string; overload;

{ AnsiLowerCase converts all characters in the given string to lower case.
  The conversion uses the current user locale. }

function AnsiLowerCase(const S: string): string; overload;

{ AnsiCompareStr compares S1 to S2, with case-sensitivity. The compare
  operation is controlled by the current user locale. The return value
  is the same as for CompareStr. }

function AnsiCompareStr(const S1, S2: string): Integer; overload;

{ AnsiSameStr compares S1 to S2, with case-sensitivity. The compare
  operation is controlled by the current user locale. The return value
  is True if AnsiCompareStr would have returned 0. }

function AnsiSameStr(const S1, S2: string): Boolean; inline; overload;

{ AnsiCompareText compares S1 to S2, without case-sensitivity. The compare
  operation is controlled by the current user locale. The return value
  is the same as for CompareStr. }

function AnsiCompareText(const S1, S2: string): Integer; overload;

{ AnsiSameText compares S1 to S2, without case-sensitivity. The compare
  operation is controlled by the current user locale. The return value
  is True if AnsiCompareText would have returned 0. }

function AnsiSameText(const S1, S2: string): Boolean; inline; overload;

{ AnsiStrComp compares S1 to S2, with case-sensitivity. The compare
  operation is controlled by the current user locale. The return value
  is the same as for CompareStr. }

function AnsiStrComp(S1, S2: PAnsiChar): Integer; inline; overload;
function AnsiStrComp(S1, S2: PWideChar): Integer; inline; overload;

{ AnsiStrIComp compares S1 to S2, without case-sensitivity. The compare
  operation is controlled by the current user locale. The return value
  is the same as for CompareStr. }

function AnsiStrIComp(S1, S2: PAnsiChar): Integer; inline; overload;
function AnsiStrIComp(S1, S2: PWideChar): Integer; inline; overload;

{ AnsiStrLComp compares S1 to S2, with case-sensitivity, up to a maximum
  length of MaxLen bytes. The compare operation is controlled by the
  current user locale. The return value is the same as for CompareStr. }

function AnsiStrLComp(S1, S2: PAnsiChar; MaxLen: Cardinal): Integer; overload;
function AnsiStrLComp(S1, S2: PWideChar; MaxLen: Cardinal): Integer; overload;

{ AnsiStrLIComp compares S1 to S2, without case-sensitivity, up to a maximum
  length of MaxLen bytes. The compare operation is controlled by the
  current user locale. The return value is the same as for CompareStr. }

function AnsiStrLIComp(S1, S2: PAnsiChar; MaxLen: Cardinal): Integer; overload;
function AnsiStrLIComp(S1, S2: PWideChar; MaxLen: Cardinal): Integer; overload;

{ AnsiStrLower converts all characters in the given string to lower case.
  The conversion uses the current user locale. }

function AnsiStrLower(Str: PAnsiChar): PAnsiChar; overload;
function AnsiStrLower(Str: PWideChar): PWideChar; inline; overload;

{ AnsiStrUpper converts all characters in the given string to upper case.
  The conversion uses the current user locale. }

function AnsiStrUpper(Str: PAnsiChar): PAnsiChar; overload;
function AnsiStrUpper(Str: PWideChar): PWideChar; inline; overload;

{ AnsiLastChar returns a pointer to the last full character in the string.
  This function supports multibyte characters  }

function AnsiLastChar(const S: AnsiString): PAnsiChar; overload;
function AnsiLastChar(const S: UnicodeString): PWideChar; overload;

{ AnsiStrLastChar returns a pointer to the last full character in the string.
  This function supports multibyte characters.  }

function AnsiStrLastChar(P: PAnsiChar): PAnsiChar; overload;
function AnsiStrLastChar(P: PWideChar): PWideChar; overload;

{ WideUpperCase converts all characters in the given string to upper case. }

function WideUpperCase(const S: WideString): WideString;

{ WideLowerCase converts all characters in the given string to lower case. }

function WideLowerCase(const S: WideString): WideString;

{ WideCompareStr compares S1 to S2, with case-sensitivity. The return value
  is the same as for CompareStr. }

function WideCompareStr(const S1, S2: WideString): Integer;

{ WideSameStr compares S1 to S2, with case-sensitivity. The return value
  is True if WideCompareStr would have returned 0. }

function WideSameStr(const S1, S2: WideString): Boolean; inline;

{ WideCompareText compares S1 to S2, without case-sensitivity. The return value
  is the same as for CompareStr. }

function WideCompareText(const S1, S2: WideString): Integer;

{ WideSameText compares S1 to S2, without case-sensitivity. The return value
  is True if WideCompareText would have returned 0. }

function WideSameText(const S1, S2: WideString): Boolean; inline;

{ Trim trims leading and trailing spaces and control characters from the
  given string. }

function Trim(const S: string): string; overload;

{ TrimLeft trims leading spaces and control characters from the given
  string. }

function TrimLeft(const S: string): string; overload;

{ TrimRight trims trailing spaces and control characters from the given
  string. }

function TrimRight(const S: string): string; overload;

{ QuotedStr returns the given string as a quoted string. A single quote
  character is inserted at the beginning and the end of the string, and
  for each single quote character in the string, another one is added. }

function QuotedStr(const S: string): string; overload;

{ AnsiQuotedStr returns the given string as a quoted string, using the
  provided Quote character.  A Quote character is inserted at the beginning
  and end of the string, and each Quote character in the string is doubled.
  This function supports multibyte character strings (MBCS). }

function AnsiQuotedStr(const S: string; Quote: Char): string; overload;

{ AnsiExtractQuotedStr removes the Quote characters from the beginning and end
  of a quoted string, and reduces pairs of Quote characters within the quoted
  string to a single character. If the first character in Src is not the Quote
  character, the function returns an empty string.  The function copies
  characters from the Src to the result string until the second solitary
  Quote character or the first null character in Src. The Src parameter is
  updated to point to the first character following the quoted string.  If
  the Src string does not contain a matching end Quote character, the Src
  parameter is updated to point to the terminating null character in Src.
  This function supports multibyte character strings (MBCS).  }

function AnsiExtractQuotedStr(var Src: PAnsiChar; Quote: AnsiChar): AnsiString; overload;
function AnsiExtractQuotedStr(var Src: PWideChar; Quote: WideChar): UnicodeString; overload;

{ AnsiDequotedStr is a simplified version of AnsiExtractQuotedStr }

function AnsiDequotedStr(const S: string; AQuote: Char): string; overload;

{ AdjustLineBreaks adjusts all line breaks in the given string to the
  indicated style.
  When Style is tlbsCRLF, the function changes all
  CR characters not followed by LF and all LF characters not preceded
  by a CR into CR/LF pairs.
  When Style is tlbsLF, the function changes all CR/LF pairs and CR characters
  not followed by LF to LF characters. }

function AdjustLineBreaks(const S: string; Style: TTextLineBreakStyle = tlbsCRLF): string; overload;

{ IntToStr converts the given value to its decimal string representation. }

function IntToStr(Value: Integer): string; overload;
function IntToStr(Value: Int64): string; overload;

{ UIntToStr converts the given unsigned value to its decimal string representation. }

function UIntToStr(Value: Cardinal): string; overload;
function UIntToStr(Value: UInt64): string; overload;

{ IntToHex converts the given value to a hexadecimal string representation
  with the minimum number of digits specified. }

function IntToHex(Value: Integer; Digits: Integer): string; overload;
function IntToHex(Value: Int64; Digits: Integer): string; overload;
function IntToHex(Value: UInt64; Digits: Integer): string; overload;

{ StrToInt converts the given string to an integer value. If the string
  doesn't contain a valid value, an EConvertError exception is raised. }

function StrToInt(const S: string): Integer; overload;
function StrToIntDef(const S: string; Default: Integer): Integer; overload;
function TryStrToInt(const S: string; out Value: Integer): Boolean; overload;

{ Similar to the above functions but for Int64 instead }

function StrToInt64(const S: string): Int64; overload;
function StrToInt64Def(const S: string; const Default: Int64): Int64; overload;
function TryStrToInt64(const S: string; out Value: Int64): Boolean; overload;

{ StrToBool converts the given string to a boolean value.  If the string
  doesn't contain a valid value, an EConvertError exception is raised.
  BoolToStr converts boolean to a string value that in turn can be converted
  back into a boolean.  BoolToStr will always pick the first element of
  the TrueStrs/FalseStrs arrays. }

var
  TrueBoolStrs: array of String;
  FalseBoolStrs: array of String;

const
  DefaultTrueBoolStr = 'True';   // DO NOT LOCALIZE
  DefaultFalseBoolStr = 'False'; // DO NOT LOCALIZE

function StrToBool(const S: string): Boolean; overload;
function StrToBoolDef(const S: string; const Default: Boolean): Boolean; overload;
function TryStrToBool(const S: string; out Value: Boolean): Boolean; overload;

function BoolToStr(B: Boolean; UseBoolStrs: Boolean = False): string;

{ LoadStr loads the string resource given by Ident from the application's
  executable file or associated resource module. If the string resource
  does not exist, LoadStr returns an empty string. }

function LoadStr(Ident: Integer): string;

{ FmtLoadStr loads the string resource given by Ident from the application's
  executable file or associated resource module, and uses it as the format
  string in a call to the Format function with the given arguments. }

function FmtLoadStr(Ident: Integer; const Args: array of const): string;

{ PChar routines }
{ const params help simplify C++ code.  No effect on pascal code }

{ StrLen returns the number of characters in Str, not counting the null
  terminator. }

function StrLen(const Str: PAnsiChar): Cardinal; overload; inline;
function StrLen(const Str: PWideChar): Cardinal; overload; inline;

{ StrEnd returns a pointer to the null character that terminates Str. }

function StrEnd(const Str: PAnsiChar): PAnsiChar; overload;
function StrEnd(const Str: PWideChar): PWideChar; overload;

{ StrMove copies exactly Count characters from Source to Dest and returns
  Dest. Source and Dest may overlap. }

function StrMove(Dest: PAnsiChar; const Source: PAnsiChar; Count: Cardinal): PAnsiChar; overload;
function StrMove(Dest: PWideChar; const Source: PWideChar; Count: Cardinal): PWideChar; overload;

{ StrCopy copies Source to Dest and returns Dest. }

function StrCopy(Dest: PAnsiChar; const Source: PAnsiChar): PAnsiChar; overload;
function StrCopy(Dest: PWideChar; const Source: PWideChar): PWideChar; overload;

{ StrECopy copies Source to Dest and returns StrEnd(Dest). }

function StrECopy(Dest: PAnsiChar; const Source: PAnsiChar): PAnsiChar; overload;
function StrECopy(Dest: PWideChar; const Source: PWideChar): PWideChar; overload;

{ StrLCopy copies at most MaxLen characters from Source to Dest and
  returns Dest. }

function StrLCopy(Dest: PAnsiChar; const Source: PAnsiChar; MaxLen: Cardinal): PAnsiChar; overload;
function StrLCopy(Dest: PWideChar; const Source: PWideChar; MaxLen: Cardinal): PWideChar; overload;

{ StrPCopy copies the Pascal style string Source into Dest and
  returns Dest. }

function StrPCopy(Dest: PAnsiChar; const Source: AnsiString): PAnsiChar; overload;
function StrPCopy(Dest: PWideChar; const Source: UnicodeString): PWideChar; overload;

{ StrPLCopy copies at most MaxLen characters from the Pascal style string
  Source into Dest and returns Dest. }

function StrPLCopy(Dest: PAnsiChar; const Source: AnsiString;
  MaxLen: Cardinal): PAnsiChar; overload;
function StrPLCopy(Dest: PWideChar; const Source: UnicodeString;
  MaxLen: Cardinal): PWideChar; overload;

{ StrCat appends a copy of Source to the end of Dest and returns Dest. }

function StrCat(Dest: PAnsiChar; const Source: PAnsiChar): PAnsiChar; overload;
function StrCat(Dest: PWideChar; const Source: PWideChar): PWideChar; overload;

{ StrLCat appends at most MaxLen - StrLen(Dest) characters from Source to
  the end of Dest, and returns Dest. }

function StrLCat(Dest: PAnsiChar; const Source: PAnsiChar; MaxLen: Cardinal): PAnsiChar; overload;
function StrLCat(Dest: PWideChar; const Source: PWideChar; MaxLen: Cardinal): PWideChar; overload;

{ StrComp compares Str1 to Str2. The return value is less than 0 if
  Str1 < Str2, 0 if Str1 = Str2, or greater than 0 if Str1 > Str2. }

function StrComp(const Str1, Str2: PAnsiChar): Integer; overload;
function StrComp(const Str1, Str2: PWideChar): Integer; overload;

{ StrIComp compares Str1 to Str2, without case sensitivity. The return
  value is the same as StrComp. }

function StrIComp(const Str1, Str2: PAnsiChar): Integer; overload;
function StrIComp(const Str1, Str2: PWideChar): Integer; overload;

{ StrLComp compares Str1 to Str2, for a maximum length of MaxLen
  characters. The return value is the same as StrComp. }

function StrLComp(const Str1, Str2: PAnsiChar; MaxLen: Cardinal): Integer; overload;
function StrLComp(const Str1, Str2: PWideChar; MaxLen: Cardinal): Integer; overload;

{ StrLIComp compares Str1 to Str2, for a maximum length of MaxLen
  characters, without case sensitivity. The return value is the same
  as StrComp. }

function StrLIComp(const Str1, Str2: PAnsiChar; MaxLen: Cardinal): Integer; overload;
function StrLIComp(const Str1, Str2: PWideChar; MaxLen: Cardinal): Integer; overload;

{ StrScan returns a pointer to the first occurrence of Chr in Str. If Chr
  does not occur in Str, StrScan returns NIL. The null terminator is
  considered to be part of the string. }

function StrScan(const Str: PAnsiChar; Chr: AnsiChar): PAnsiChar; overload;
function StrScan(const Str: PWideChar; Chr: WideChar): PWideChar; overload;

{ StrRScan returns a pointer to the last occurrence of Chr in Str. If Chr
  does not occur in Str, StrRScan returns NIL. The null terminator is
  considered to be part of the string. }

function StrRScan(const Str: PAnsiChar; Chr: AnsiChar): PAnsiChar; overload;
function StrRScan(const Str: PWideChar; Chr: WideChar): PWideChar; overload;

{ TextPos: Same as StrPos but is case insensitive }

function TextPos(Str, SubStr: PAnsiChar): PAnsiChar; overload;
function TextPos(Str, SubStr: PWideChar): PWideChar; overload;

{ StrPos returns a pointer to the first occurrence of Str2 in Str1. If
  Str2 does not occur in Str1, StrPos returns NIL. }

function StrPos(const Str1, Str2: PAnsiChar): PAnsiChar; overload;
function StrPos(const Str1, Str2: PWideChar): PWideChar; overload;

{ StrUpper converts Str to upper case and returns Str. }

function StrUpper(Str: PAnsiChar): PAnsiChar; overload;
function StrUpper(Str: PWideChar): PWideChar; overload;

{ StrLower converts Str to lower case and returns Str. }

function StrLower(Str: PAnsiChar): PAnsiChar; overload;
function StrLower(Str: PWideChar): PWideChar; overload;

{ StrPas converts Str to a Pascal style string. This function is provided
  for backwards compatibility only. To convert a null terminated string to
  a Pascal style string, use a string type cast or an assignment. }

function StrPas(const Str: PAnsiChar): AnsiString; overload;
function StrPas(const Str: PWideChar): UnicodeString; overload;

{ StrAlloc allocates a buffer of the given size on the heap. The size of
  the allocated buffer is encoded in a four byte header that immediately
  preceeds the buffer. To dispose the buffer, use StrDispose. }

function AnsiStrAlloc(Size: Cardinal): PAnsiChar;
function WideStrAlloc(Size: Cardinal): PWideChar;
function StrAlloc(Size: Cardinal): PChar;

{ StrBufSize returns the allocated size of the given buffer, not including
  the two byte header. }

function StrBufSize(const Str: PAnsiChar): Cardinal; overload;
function StrBufSize(const Str: PWideChar): Cardinal; overload;

{ StrNew allocates a copy of Str on the heap. If Str is NIL, StrNew returns
  NIL and doesn't allocate any heap space. Otherwise, StrNew makes a
  duplicate of Str, obtaining space with a call to the StrAlloc function,
  and returns a pointer to the duplicated string. To dispose the string,
  use StrDispose. }

function StrNew(const Str: PAnsiChar): PAnsiChar; overload;
function StrNew(const Str: PWideChar): PWideChar; overload;

{ StrDispose disposes a string that was previously allocated with StrAlloc
  or StrNew. If Str is NIL, StrDispose does nothing. }

procedure StrDispose(Str: PAnsiChar); overload;
procedure StrDispose(Str: PWideChar); overload;

{ String formatting routines }

{ The Format routine formats the argument list given by the Args parameter
  using the format string given by the Format parameter.

  Format strings contain two types of objects--plain characters and format
  specifiers. Plain characters are copied verbatim to the resulting string.
  Format specifiers fetch arguments from the argument list and apply
  formatting to them.

  Format specifiers have the following form:

    "%" [index ":"] ["-"] [width] ["." prec] type

  A format specifier begins with a % character. After the % come the
  following, in this order:

  -  an optional argument index specifier, [index ":"]
  -  an optional left-justification indicator, ["-"]
  -  an optional width specifier, [width]
  -  an optional precision specifier, ["." prec]
  -  the conversion type character, type

  The following conversion characters are supported:

  d  Decimal. The argument must be an integer value. The value is converted
     to a string of decimal digits. If the format string contains a precision
     specifier, it indicates that the resulting string must contain at least
     the specified number of digits; if the value has less digits, the
     resulting string is left-padded with zeros.

  u  Unsigned decimal.  Similar to 'd' but no sign is output.

  e  Scientific. The argument must be a floating-point value. The value is
     converted to a string of the form "-d.ddd...E+ddd". The resulting
     string starts with a minus sign if the number is negative, and one digit
     always precedes the decimal point. The total number of digits in the
     resulting string (including the one before the decimal point) is given
     by the precision specifer in the format string--a default precision of
     15 is assumed if no precision specifer is present. The "E" exponent
     character in the resulting string is always followed by a plus or minus
     sign and at least three digits.

  f  Fixed. The argument must be a floating-point value. The value is
     converted to a string of the form "-ddd.ddd...". The resulting string
     starts with a minus sign if the number is negative. The number of digits
     after the decimal point is given by the precision specifier in the
     format string--a default of 2 decimal digits is assumed if no precision
     specifier is present.

  g  General. The argument must be a floating-point value. The value is
     converted to the shortest possible decimal string using fixed or
     scientific format. The number of significant digits in the resulting
     string is given by the precision specifier in the format string--a
     default precision of 15 is assumed if no precision specifier is present.
     Trailing zeros are removed from the resulting string, and a decimal
     point appears only if necessary. The resulting string uses fixed point
     format if the number of digits to the left of the decimal point in the
     value is less than or equal to the specified precision, and if the
     value is greater than or equal to 0.00001. Otherwise the resulting
     string uses scientific format.

  n  Number. The argument must be a floating-point value. The value is
     converted to a string of the form "-d,ddd,ddd.ddd...". The "n" format
     corresponds to the "f" format, except that the resulting string
     contains thousand separators.

  m  Money. The argument must be a floating-point value. The value is
     converted to a string that represents a currency amount. The conversion
     is controlled by the CurrencyString, CurrencyFormat, NegCurrFormat,
     ThousandSeparator, DecimalSeparator, and CurrencyDecimals global
     variables, all of which are initialized from locale settings provided
     by the operating system.  For example, Currency Format preferences can be
     set in the International section of the Windows Control Panel. If the format
     string contains a precision specifier, it overrides the value given
     by the CurrencyDecimals global variable.

  p  Pointer. The argument must be a pointer value. The value is converted
     to a string of the form "XXXX:YYYY" where XXXX and YYYY are the
     segment and offset parts of the pointer expressed as four hexadecimal
     digits.

  s  String. The argument must be a character, a string, or a PChar value.
     The string or character is inserted in place of the format specifier.
     The precision specifier, if present in the format string, specifies the
     maximum length of the resulting string. If the argument is a string
     that is longer than this maximum, the string is truncated.

  x  Hexadecimal. The argument must be an integer value. The value is
     converted to a string of hexadecimal digits. If the format string
     contains a precision specifier, it indicates that the resulting string
     must contain at least the specified number of digits; if the value has
     less digits, the resulting string is left-padded with zeros.

  Conversion characters may be specified in upper case as well as in lower
  case--both produce the same results.

  For all floating-point formats, the actual characters used as decimal and
  thousand separators are obtained from the DecimalSeparator and
  ThousandSeparator global variables.

  Index, width, and precision specifiers can be specified directly using
  decimal digit string (for example "%10d"), or indirectly using an asterisk
  charcater (for example "%*.*f"). When using an asterisk, the next argument
  in the argument list (which must be an integer value) becomes the value
  that is actually used. For example "Format('%*.*f', [8, 2, 123.456])" is
  the same as "Format('%8.2f', [123.456])".

  A width specifier sets the minimum field width for a conversion. If the
  resulting string is shorter than the minimum field width, it is padded
  with blanks to increase the field width. The default is to right-justify
  the result by adding blanks in front of the value, but if the format
  specifier contains a left-justification indicator (a "-" character
  preceding the width specifier), the result is left-justified by adding
  blanks after the value.

  An index specifier sets the current argument list index to the specified
  value. The index of the first argument in the argument list is 0. Using
  index specifiers, it is possible to format the same argument multiple
  times. For example "Format('%d %d %0:d %d', [10, 20])" produces the string
  '10 20 10 20'.

  The Format function can be combined with other formatting functions. For
  example

    S := Format('Your total was %s on %s', [
      FormatFloat('$#,##0.00;;zero', Total),
      FormatDateTime('mm/dd/yy', Date)]);

  which uses the FormatFloat and FormatDateTime functions to customize the
  format beyond what is possible with Format.

  Each of the string formatting routines that uses global variables for
  formatting (separators, decimals, date/time formats etc.), has an
  overloaded equivalent requiring a parameter of type TFormatSettings. This
  additional parameter provides the formatting information rather than the
  global variables. For more information see the notes at TFormatSettings.  }

function Format(const Format: string;
  const Args: array of const): string; overload;
function Format(const Format: string; const Args: array of const;
  const AFormatSettings: TFormatSettings): string; overload;

{ FmtStr formats the argument list given by Args using the format string
  given by Format into the string variable given by Result. For further
  details, see the description of the Format function. }

procedure FmtStr(var Result: string; const Format: string;
  const Args: array of const); overload;
procedure FmtStr(var Result: string; const Format: string;
  const Args: array of const; const AFormatSettings: TFormatSettings); overload;

{ StrFmt formats the argument list given by Args using the format string
  given by Format into the buffer given by Buffer. It is up to the caller to
  ensure that Buffer is large enough for the resulting string. The returned
  value is Buffer. For further details, see the description of the Format
  function. }

function StrFmt(Buffer, Format: PAnsiChar;
  const Args: array of const): PAnsiChar; overload;
function StrFmt(Buffer, Format: PAnsiChar; const Args: array of const;
  const AFormatSettings: TFormatSettings): PAnsiChar; overload;

function StrFmt(Buffer, Format: PWideChar;
  const Args: array of const): PWideChar; overload;
function StrFmt(Buffer, Format: PWideChar; const Args: array of const;
  const AFormatSettings: TFormatSettings): PWideChar; overload;

{ StrLFmt formats the argument list given by Args using the format string
  given by Format into the buffer given by Buffer. The resulting string will
  contain no more than MaxBufLen characters, not including the null terminator.
  The returned value is Buffer. For further details, see the description of
  the Format function. }

function StrLFmt(Buffer: PAnsiChar; MaxBufLen: Cardinal; Format: PAnsiChar;
  const Args: array of const): PAnsiChar; overload;
function StrLFmt(Buffer: PAnsiChar; MaxBufLen: Cardinal; Format: PAnsiChar;
  const Args: array of const;
  const AFormatSettings: TFormatSettings): PAnsiChar; overload;

function StrLFmt(Buffer: PWideChar; MaxBufLen: Cardinal; Format: PWideChar;
  const Args: array of const): PWideChar; overload;
function StrLFmt(Buffer: PWideChar; MaxBufLen: Cardinal; Format: PWideChar;
  const Args: array of const;
  const AFormatSettings: TFormatSettings): PWideChar; overload;

{ FormatBuf formats the argument list given by Args using the format string
  given by Format and FmtLen into the buffer given by Buffer and BufLen.
  The Format parameter is a reference to a buffer containing FmtLen
  characters, and the Buffer parameter is a reference to a buffer of BufLen
  characters. The returned value is the number of characters actually stored
  in Buffer. The returned value is always less than or equal to BufLen. For
  further details, see the description of the Format function. }

function FormatBuf(var Buffer; BufLen: Cardinal; const Format;
  FmtLen: Cardinal; const Args: array of const): Cardinal; overload;
function FormatBuf(var Buffer; BufLen: Cardinal; const Format;
  FmtLen: Cardinal; const Args: array of const;
  const AFormatSettings: TFormatSettings): Cardinal; overload;

function FormatBuf(Buffer: PWideChar; BufLen: Cardinal; const Format;
  FmtLen: Cardinal; const Args: array of const): Cardinal; overload;
function FormatBuf(Buffer: PWideChar; BufLen: Cardinal; const Format;
  FmtLen: Cardinal; const Args: array of const;
  const AFormatSettings: TFormatSettings): Cardinal; overload;

function FormatBuf(var Buffer: UnicodeString; BufLen: Cardinal; const Format;
  FmtLen: Cardinal; const Args: array of const): Cardinal; overload;
function FormatBuf(var Buffer: UnicodeString; BufLen: Cardinal; const Format;
  FmtLen: Cardinal; const Args: array of const;
  const AFormatSettings: TFormatSettings): Cardinal; overload;

{ The WideFormat routine formats the argument list given by the Args parameter
  using the format WideString given by the Format parameter. This routine is
  the WideString equivalent of Format. For further details, see the description
  of the Format function. }
function WideFormat(const Format: WideString;
  const Args: array of const): WideString; overload;
function WideFormat(const Format: WideString;
  const Args: array of const;
  const AFormatSettings: TFormatSettings): WideString; overload;

{ WideFmtStr formats the argument list given by Args using the format WideString
  given by Format into the WideString variable given by Result. For further
  details, see the description of the Format function. }
procedure WideFmtStr(var Result: WideString; const Format: WideString;
  const Args: array of const); overload;
procedure WideFmtStr(var Result: WideString; const Format: WideString;
  const Args: array of const; const AFormatSettings: TFormatSettings); overload;

{ WideFormatBuf formats the argument list given by Args using the format string
  given by Format and FmtLen into the buffer given by Buffer and BufLen.
  The Format parameter is a reference to a buffer containing FmtLen
  UNICODE characters (WideChar), and the Buffer parameter is a reference to a
  buffer of BufLen UNICODE characters (WideChar). The return value is the number
  of UNICODE characters actually stored in Buffer. The return value is always
  less than or equal to BufLen. For further details, see the description of the
  Format function.

  Important: BufLen, FmtLen and the return result are always the number of
  UNICODE characters, *not* the number of bytes. To calculate the number of bytes
  multiply them by SizeOf(WideChar). }
function WideFormatBuf(var Buffer; BufLen: Cardinal; const Format;
  FmtLen: Cardinal; const Args: array of const): Cardinal; overload;
function WideFormatBuf(var Buffer; BufLen: Cardinal; const Format;
  FmtLen: Cardinal; const Args: array of const;
  const AFormatSettings: TFormatSettings): Cardinal; overload;

{ Floating point conversion routines }

{ Each of the floating point conversion routines that uses global variables
  for formatting (separators, decimals, etc.), has an overloaded equivalent
  requiring a parameter of type TFormatSettings. This additional parameter
  provides the formatting information rather than the global variables. For
  more information see the notes at TFormatSettings.  }

{ FloatToStr converts the floating-point value given by Value to its string
  representation. The conversion uses general number format with 15
  significant digits. For further details, see the description of the
  FloatToStrF function. }

function FloatToStr(Value: Extended): string; overload; inline;
function FloatToStr(Value: Extended;
  const AFormatSettings: TFormatSettings): string; overload;

{ CurrToStr converts the currency value given by Value to its string
  representation. The conversion uses general number format. For further
  details, see the description of the CurrToStrF function. }

function CurrToStr(Value: Currency): string; overload; inline;
function CurrToStr(Value: Currency;
  const AFormatSettings: TFormatSettings): string; overload;

{ FloatToCurr will range validate a value to make sure it falls
  within the acceptable currency range }

const
  MinCurrency: Currency = -922337203685477.5807;  //!! overflow?
  MaxCurrency: Currency =  922337203685477.5807;  //!! overflow?

function FloatToCurr(const Value: Extended): Currency;
function TryFloatToCurr(const Value: Extended; out AResult: Currency): Boolean;

{ FloatToStrF converts the floating-point value given by Value to its string
  representation. The Format parameter controls the format of the resulting
  string. The Precision parameter specifies the precision of the given value.
  It should be 7 or less for values of type Single, 15 or less for values of
  type Double, and 18 or less for values of type Extended. The meaning of the
  Digits parameter depends on the particular format selected.

  The possible values of the Format parameter, and the meaning of each, are
  described below.

  ffGeneral - General number format. The value is converted to the shortest
  possible decimal string using fixed or scientific format. Trailing zeros
  are removed from the resulting string, and a decimal point appears only
  if necessary. The resulting string uses fixed point format if the number
  of digits to the left of the decimal point in the value is less than or
  equal to the specified precision, and if the value is greater than or
  equal to 0.00001. Otherwise the resulting string uses scientific format,
  and the Digits parameter specifies the minimum number of digits in the
  exponent (between 0 and 4).

  ffExponent - Scientific format. The value is converted to a string of the
  form "-d.ddd...E+dddd". The resulting string starts with a minus sign if
  the number is negative, and one digit always precedes the decimal point.
  The total number of digits in the resulting string (including the one
  before the decimal point) is given by the Precision parameter. The "E"
  exponent character in the resulting string is always followed by a plus
  or minus sign and up to four digits. The Digits parameter specifies the
  minimum number of digits in the exponent (between 0 and 4).

  ffFixed - Fixed point format. The value is converted to a string of the
  form "-ddd.ddd...". The resulting string starts with a minus sign if the
  number is negative, and at least one digit always precedes the decimal
  point. The number of digits after the decimal point is given by the Digits
  parameter--it must be between 0 and 18. If the number of digits to the
  left of the decimal point is greater than the specified precision, the
  resulting value will use scientific format.

  ffNumber - Number format. The value is converted to a string of the form
  "-d,ddd,ddd.ddd...". The ffNumber format corresponds to the ffFixed format,
  except that the resulting string contains thousand separators.

  ffCurrency - Currency format. The value is converted to a string that
  represents a currency amount. The conversion is controlled by the
  CurrencyString, CurrencyFormat, NegCurrFormat, ThousandSeparator, and
  DecimalSeparator global variables, all of which are initialized from
  locale settings provided by the operating system.  For example,
  Currency Format preferences can be set in the International section
  of the Windows Control Panel.
  The number of digits after the decimal point is given by the Digits
  parameter--it must be between 0 and 18.

  For all formats, the actual characters used as decimal and thousand
  separators are obtained from the DecimalSeparator and ThousandSeparator
  global variables.

  If the given value is a NAN (not-a-number), the resulting string is 'NAN'.
  If the given value is positive infinity, the resulting string is 'INF'. If
  the given value is negative infinity, the resulting string is '-INF'. }

function FloatToStrF(Value: Extended; Format: TFloatFormat;
  Precision, Digits: Integer): string; overload; inline;
function FloatToStrF(Value: Extended; Format: TFloatFormat;
  Precision, Digits: Integer;
  const AFormatSettings: TFormatSettings): string; overload;

{ CurrToStrF converts the currency value given by Value to its string
  representation. A call to CurrToStrF corresponds to a call to
  FloatToStrF with an implied precision of 19 digits. }

function CurrToStrF(Value: Currency; Format: TFloatFormat;
  Digits: Integer): string; overload; inline;
function CurrToStrF(Value: Currency; Format: TFloatFormat;
  Digits: Integer; const AFormatSettings: TFormatSettings): string; overload;

{ FloatToText converts the given floating-point value to its decimal
  representation using the specified format, precision, and digits. The
  Value parameter must be a variable of type Extended or Currency, as
  indicated by the ValueType parameter. The resulting string of characters
  is stored in the given buffer, and the returned value is the number of
  characters stored. The resulting string is not null-terminated. For
  further details, see the description of the FloatToStrF function. }

function FloatToText(BufferArg: PAnsiChar; const Value; ValueType: TFloatValue;
  Format: TFloatFormat; Precision, Digits: Integer): Integer; overload; inline;
function FloatToText(BufferArg: PAnsiChar; const Value; ValueType: TFloatValue;
  Format: TFloatFormat; Precision, Digits: Integer;
  const AFormatSettings: TFormatSettings): Integer; overload;

function FloatToText(BufferArg: PWideChar; const Value; ValueType: TFloatValue;
  Format: TFloatFormat; Precision, Digits: Integer): Integer; overload; inline;
function FloatToText(BufferArg: PWideChar; const Value; ValueType: TFloatValue;
  Format: TFloatFormat; Precision, Digits: Integer;
  const AFormatSettings: TFormatSettings): Integer; overload;

{ FormatFloat formats the floating-point value given by Value using the
  format string given by Format. The following format specifiers are
  supported in the format string:

  0     Digit placeholder. If the value being formatted has a digit in the
        position where the '0' appears in the format string, then that digit
        is copied to the output string. Otherwise, a '0' is stored in that
        position in the output string.

  #     Digit placeholder. If the value being formatted has a digit in the
        position where the '#' appears in the format string, then that digit
        is copied to the output string. Otherwise, nothing is stored in that
        position in the output string.

  .     Decimal point. The first '.' character in the format string
        determines the location of the decimal separator in the formatted
        value; any additional '.' characters are ignored. The actual
        character used as a the decimal separator in the output string is
        determined by the DecimalSeparator global variable, which is initialized
        from locale settings obtained from the operating system.

  ,     Thousand separator. If the format string contains one or more ','
        characters, the output will have thousand separators inserted between
        each group of three digits to the left of the decimal point. The
        placement and number of ',' characters in the format string does not
        affect the output, except to indicate that thousand separators are
        wanted. The actual character used as a the thousand separator in the
        output is determined by the ThousandSeparator global variable, which
        is initialized from locale settings obtained from the operating system.

  E+    Scientific notation. If any of the strings 'E+', 'E-', 'e+', or 'e-'
  E-    are contained in the format string, the number is formatted using
  e+    scientific notation. A group of up to four '0' characters can
  e-    immediately follow the 'E+', 'E-', 'e+', or 'e-' to determine the
        minimum number of digits in the exponent. The 'E+' and 'e+' formats
        cause a plus sign to be output for positive exponents and a minus
        sign to be output for negative exponents. The 'E-' and 'e-' formats
        output a sign character only for negative exponents.

  'xx'  Characters enclosed in single or double quotes are output as-is, and
  "xx"  do not affect formatting.

  ;     Separates sections for positive, negative, and zero numbers in the
        format string.

  The locations of the leftmost '0' before the decimal point in the format
  string and the rightmost '0' after the decimal point in the format string
  determine the range of digits that are always present in the output string.

  The number being formatted is always rounded to as many decimal places as
  there are digit placeholders ('0' or '#') to the right of the decimal
  point. If the format string contains no decimal point, the value being
  formatted is rounded to the nearest whole number.

  If the number being formatted has more digits to the left of the decimal
  separator than there are digit placeholders to the left of the '.'
  character in the format string, the extra digits are output before the
  first digit placeholder.

  To allow different formats for positive, negative, and zero values, the
  format string can contain between one and three sections separated by
  semicolons.

  One section - The format string applies to all values.

  Two sections - The first section applies to positive values and zeros, and
  the second section applies to negative values.

  Three sections - The first section applies to positive values, the second
  applies to negative values, and the third applies to zeros.

  If the section for negative values or the section for zero values is empty,
  that is if there is nothing between the semicolons that delimit the
  section, the section for positive values is used instead.

  If the section for positive values is empty, or if the entire format string
  is empty, the value is formatted using general floating-point formatting
  with 15 significant digits, corresponding to a call to FloatToStrF with
  the ffGeneral format. General floating-point formatting is also used if
  the value has more than 18 digits to the left of the decimal point and
  the format string does not specify scientific notation.

  The table below shows some sample formats and the results produced when
  the formats are applied to different values:

  Format string          1234        -1234       0.5         0
  -----------------------------------------------------------------------
                         1234        -1234       0.5         0
  0                      1234        -1234       1           0
  0.00                   1234.00     -1234.00    0.50        0.00
  #.##                   1234        -1234       .5
  #,##0.00               1,234.00    -1,234.00   0.50        0.00
  #,##0.00;(#,##0.00)    1,234.00    (1,234.00)  0.50        0.00
  #,##0.00;;Zero         1,234.00    -1,234.00   0.50        Zero
  0.000E+00              1.234E+03   -1.234E+03  5.000E-01   0.000E+00
  #.###E-0               1.234E3     -1.234E3    5E-1        0E0
  ----------------------------------------------------------------------- }

function FormatFloat(const Format: string; Value: Extended): string; overload; inline;
function FormatFloat(const Format: string; Value: Extended;
  const AFormatSettings: TFormatSettings): string; overload;

{ FormatCurr formats the currency value given by Value using the format
  string given by Format. For further details, see the description of the
  FormatFloat function. }

function FormatCurr(const Format: string; Value: Currency): string; overload; inline;
function FormatCurr(const Format: string; Value: Currency;
  const AFormatSettings: TFormatSettings): string; overload;

{ FloatToTextFmt converts the given floating-point value to its decimal
  representation using the specified format. The Value parameter must be a
  variable of type Extended or Currency, as indicated by the ValueType
  parameter. The resulting string of characters is stored in the given
  buffer, and the returned value is the number of characters stored. The
  resulting string is not null-terminated. For further details, see the
  description of the FormatFloat function. }

function FloatToTextFmt(Buf: PAnsiChar; const Value; ValueType: TFloatValue;
  Format: PAnsiChar): Integer; overload; inline;
function FloatToTextFmt(Buf: PAnsiChar; const Value; ValueType: TFloatValue;
  Format: PAnsiChar; const AFormatSettings: TFormatSettings): Integer; overload;

function FloatToTextFmt(Buf: PWideChar; const Value; ValueType: TFloatValue;
  Format: PWideChar): Integer; overload; inline;
function FloatToTextFmt(Buf: PWideChar; const Value; ValueType: TFloatValue;
  Format: PWideChar; const AFormatSettings: TFormatSettings): Integer; overload;

{ StrToFloat converts the given string to a floating-point value. The string
  must consist of an optional sign (+ or -), a string of digits with an
  optional decimal point, and an optional 'E' or 'e' followed by a signed
  integer. Leading and trailing blanks in the string are ignored. The
  DecimalSeparator global variable defines the character that must be used
  as a decimal point. Thousand separators and currency symbols are not
  allowed in the string. If the string doesn't contain a valid value, an
  EConvertError exception is raised. }

function StrToFloat(const S: string): Extended; overload; inline;
function StrToFloat(const S: string;
  const AFormatSettings: TFormatSettings): Extended; overload;

function StrToFloatDef(const S: string;
  const Default: Extended): Extended; overload; inline;
function StrToFloatDef(const S: string; const Default: Extended;
  const AFormatSettings: TFormatSettings): Extended; overload;

function TryStrToFloat(const S: string; out Value: Extended): Boolean; overload; inline;
function TryStrToFloat(const S: string; out Value: Extended;
  const AFormatSettings: TFormatSettings): Boolean; overload;

function TryStrToFloat(const S: string; out Value: Double): Boolean; overload; inline;
function TryStrToFloat(const S: string; out Value: Double;
  const AFormatSettings: TFormatSettings): Boolean; overload;

function TryStrToFloat(const S: string; out Value: Single): Boolean; overload; inline;
function TryStrToFloat(const S: string; out Value: Single;
  const AFormatSettings: TFormatSettings): Boolean; overload;

{ StrToCurr converts the given string to a currency value. For further
  details, see the description of the StrToFloat function. }

function StrToCurr(const S: string): Currency; overload; inline;
function StrToCurr(const S: string;
  const AFormatSettings: TFormatSettings): Currency; overload;

function StrToCurrDef(const S: string;
  const Default: Currency): Currency; overload; inline;
function StrToCurrDef(const S: string; const Default: Currency;
  const AFormatSettings: TFormatSettings): Currency; overload;

function TryStrToCurr(const S: string; out Value: Currency): Boolean; overload; inline;
function TryStrToCurr(const S: string; out Value: Currency;
  const AFormatSettings: TFormatSettings): Boolean; overload;

{ TextToFloat converts the null-terminated string given by Buffer to a
  floating-point value which is returned in the variable given by Value.
  The Value parameter must be a variable of type Extended or Currency, as
  indicated by the ValueType parameter. The return value is True if the
  conversion was successful, or False if the string is not a valid
  floating-point value. For further details, see the description of the
  StrToFloat function. }

function TextToFloat(Buffer: PAnsiChar; var Value;
  ValueType: TFloatValue): Boolean; overload; inline;
function TextToFloat(Buffer: PAnsiChar; var Value; ValueType: TFloatValue;
  const AFormatSettings: TFormatSettings): Boolean; overload;

function TextToFloat(Buffer: PWideChar; var Value;
  ValueType: TFloatValue): Boolean; overload; inline;
function TextToFloat(Buffer: PWideChar; var Value; ValueType: TFloatValue;
  const AFormatSettings: TFormatSettings): Boolean; overload;

{ FloatToDecimal converts a floating-point value to a decimal representation
  that is suited for further formatting. The Value parameter must be a
  variable of type Extended or Currency, as indicated by the ValueType
  parameter. For values of type Extended, the Precision parameter specifies
  the requested number of significant digits in the result--the allowed range
  is 1..18. For values of type Currency, the Precision parameter is ignored,
  and the implied precision of the conversion is 19 digits. The Decimals
  parameter specifies the requested maximum number of digits to the left of
  the decimal point in the result. Precision and Decimals together control
  how the result is rounded. To produce a result that always has a given
  number of significant digits regardless of the magnitude of the number,
  specify 9999 for the Decimals parameter. The result of the conversion is
  stored in the specified TFloatRec record as follows:

  Exponent - Contains the magnitude of the number, i.e. the number of
  significant digits to the right of the decimal point. The Exponent field
  is negative if the absolute value of the number is less than one. If the
  number is a NAN (not-a-number), Exponent is set to -32768. If the number
  is INF or -INF (positive or negative infinity), Exponent is set to 32767.

  Negative - True if the number is negative, False if the number is zero
  or positive.

  Digits - Contains up to 18 (for type Extended) or 19 (for type Currency)
  significant digits followed by a null terminator. The implied decimal
  point (if any) is not stored in Digits. Trailing zeros are removed, and
  if the resulting number is zero, NAN, or INF, Digits contains nothing but
  the null terminator. }

procedure FloatToDecimal(var Result: TFloatRec; const Value;
  ValueType: TFloatValue; Precision, Decimals: Integer);

{ Date/time support routines }

function DateTimeToTimeStamp(DateTime: TDateTime): TTimeStamp;

function TimeStampToDateTime(const TimeStamp: TTimeStamp): TDateTime;
function MSecsToTimeStamp(MSecs: Comp): TTimeStamp;
function TimeStampToMSecs(const TimeStamp: TTimeStamp): Comp;

{ EncodeDate encodes the given year, month, and day into a TDateTime value.
  The year must be between 1 and 9999, the month must be between 1 and 12,
  and the day must be between 1 and N, where N is the number of days in the
  specified month. If the specified values are not within range, an
  EConvertError exception is raised. The resulting value is the number of
  days between 12/30/1899 and the given date. }

function EncodeDate(Year, Month, Day: Word): TDateTime;

{ EncodeTime encodes the given hour, minute, second, and millisecond into a
  TDateTime value. The hour must be between 0 and 23, the minute must be
  between 0 and 59, the second must be between 0 and 59, and the millisecond
  must be between 0 and 999. If the specified values are not within range, an
  EConvertError exception is raised. The resulting value is a number between
  0 (inclusive) and 1 (not inclusive) that indicates the fractional part of
  a day given by the specified time. The value 0 corresponds to midnight,
  0.5 corresponds to noon, 0.75 corresponds to 6:00 pm, etc. }

function EncodeTime(Hour, Min, Sec, MSec: Word): TDateTime;

{ Instead of generating errors the following variations of EncodeDate and
  EncodeTime simply return False if the parameters given are not valid.
  Other than that, these functions are functionally the same as the above
  functions. }

function TryEncodeDate(Year, Month, Day: Word; out Date: TDateTime): Boolean;
function TryEncodeTime(Hour, Min, Sec, MSec: Word; out Time: TDateTime): Boolean;

{ DecodeDate decodes the integral (date) part of the given TDateTime value
  into its corresponding year, month, and day. If the given TDateTime value
  is less than or equal to zero, the year, month, and day return parameters
  are all set to zero. }

procedure DecodeDate(const DateTime: TDateTime; var Year, Month, Day: Word);

{ This variation of DecodeDate works similarly to the above function but
  returns more information.  The result value of this function indicates
  whether the year decoded is a leap year or not.  }

function DecodeDateFully(const DateTime: TDateTime; var Year, Month, Day,
  DOW: Word): Boolean;

{ DecodeTime decodes the fractional (time) part of the given TDateTime value
  into its corresponding hour, minute, second, and millisecond. }

procedure DecodeTime(const DateTime: TDateTime; var Hour, Min, Sec, MSec: Word);

{ DateTimeToSystemTime converts a date and time from Delphi's TDateTime
  format into the Win32 API's TSystemTime format. }

procedure DateTimeToSystemTime(const DateTime: TDateTime; var SystemTime: TSystemTime);

{ SystemTimeToDateTime converts a date and time from the Win32 API's
  TSystemTime format into Delphi's TDateTime format. }

function SystemTimeToDateTime(const SystemTime: TSystemTime): TDateTime;

{ TrySystemTimeToDateTime converts a date and time from the Win32 API's
  TSystemTime format into Delphi's TDateTime format without raising an
  EConvertError exception. }

function TrySystemTimeToDateTime(const SystemTime: TSystemTime; out DateTime: TDateTime): Boolean;

{ DayOfWeek returns the day of the week of the given date. The result is an
  integer between 1 and 7, corresponding to Sunday through Saturday.
  This function is not ISO 8601 compliant, for that see the DateUtils unit. }

function DayOfWeek(const DateTime: TDateTime): Word;

{ Date returns the current date. }

function Date: TDateTime;

{ Time returns the current time. }

function Time: TDateTime;
function GetTime: TDateTime;

{ Now returns the current date and time, corresponding to Date + Time. }

function Now: TDateTime;

{ Current year returns the year portion of the date returned by Now }

function CurrentYear: Word;

{ IncMonth returns Date shifted by the specified number of months.
  NumberOfMonths parameter can be negative, to return a date N months ago.
  If the input day of month is greater than the last day of the resulting
  month, the day is set to the last day of the resulting month.
  Input time of day is copied to the DateTime result.  }

function IncMonth(const DateTime: TDateTime; NumberOfMonths: Integer = 1): TDateTime;

{ Optimized version of IncMonth that works with years, months and days
  directly.  See above comments for more detail as to what happens to the day
  when incrementing months }

procedure IncAMonth(var Year, Month, Day: Word; NumberOfMonths: Integer = 1);

{ ReplaceTime replaces the time portion of the DateTime parameter with the given
  time value, adjusting the signs as needed if the date is prior to 1900
  (Date value less than zero)  }

procedure ReplaceTime(var DateTime: TDateTime; const NewTime: TDateTime);

{ ReplaceDate replaces the date portion of the DateTime parameter with the given
  date value, adjusting as needed for negative dates }

procedure ReplaceDate(var DateTime: TDateTime; const NewDate: TDateTime);

{ IsLeapYear determines whether the given year is a leap year. }

function IsLeapYear(Year: Word): Boolean;

type
  PDayTable = ^TDayTable;
  TDayTable = array[1..12] of Word;

{ The MonthDays array can be used to quickly find the number of
  days in a month:  MonthDays[IsLeapYear(Y), M]      }

const
  MonthDays: array [Boolean] of TDayTable =
    ((31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31),
     (31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31));

{ Each of the date/time formatting routines that uses global variables
  for formatting (separators, decimals, etc.), has an overloaded equivalent
  requiring a parameter of type TFormatSettings. This additional parameter
  provides the formatting information rather than the global variables. For
  more information see the note at TFormatSettings.  }

{ DateToStr converts the date part of the given TDateTime value to a string.
  The conversion uses the format specified by the ShortDateFormat global
  variable. }

function DateToStr(const DateTime: TDateTime): string; overload; inline;
function DateToStr(const DateTime: TDateTime;
  const AFormatSettings: TFormatSettings): string; overload; inline;

{ TimeToStr converts the time part of the given TDateTime value to a string.
  The conversion uses the format specified by the LongTimeFormat global
  variable. }

function TimeToStr(const DateTime: TDateTime): string; overload; inline;
function TimeToStr(const DateTime: TDateTime;
  const AFormatSettings: TFormatSettings): string; overload; inline;

{ DateTimeToStr converts the given date and time to a string. The resulting
  string consists of a date and time formatted using the ShortDateFormat and
  LongTimeFormat global variables. Time information is included in the
  resulting string only if the fractional part of the given date and time
  value is non-zero. }

function DateTimeToStr(const DateTime: TDateTime): string; overload; inline;
function DateTimeToStr(const DateTime: TDateTime;
  const AFormatSettings: TFormatSettings): string; overload; inline;

{ StrToDate converts the given string to a date value. The string must
  consist of two or three numbers, separated by the character defined by
  the DateSeparator global variable. The order for month, day, and year is
  determined by the ShortDateFormat global variable--possible combinations
  are m/d/y, d/m/y, and y/m/d. If the string contains only two numbers, it
  is interpreted as a date (m/d or d/m) in the current year. Year values
  between 0 and 99 are assumed to be in the current century. If the given
  string does not contain a valid date, an EConvertError exception is
  raised. }

function StrToDate(const S: string): TDateTime; overload; inline;
function StrToDate(const S: string;
  const AFormatSettings: TFormatSettings): TDateTime; overload;

function StrToDateDef(const S: string;
  const Default: TDateTime): TDateTime; overload; inline;
function StrToDateDef(const S: string; const Default: TDateTime;
  const AFormatSettings: TFormatSettings): TDateTime; overload;

function TryStrToDate(const S: string; out Value: TDateTime): Boolean; overload; inline;
function TryStrToDate(const S: string; out Value: TDateTime;
  const AFormatSettings: TFormatSettings): Boolean; overload;

{ StrToTime converts the given string to a time value. The string must
  consist of two or three numbers, separated by the character defined by
  the TimeSeparator global variable, optionally followed by an AM or PM
  indicator. The numbers represent hour, minute, and (optionally) second,
  in that order. If the time is followed by AM or PM, it is assumed to be
  in 12-hour clock format. If no AM or PM indicator is included, the time
  is assumed to be in 24-hour clock format. If the given string does not
  contain a valid time, an EConvertError exception is raised. }

function StrToTime(const S: string): TDateTime; overload; inline;
function StrToTime(const S: string;
  const AFormatSettings: TFormatSettings): TDateTime; overload;

function StrToTimeDef(const S: string;
  const Default: TDateTime): TDateTime; overload; inline;
function StrToTimeDef(const S: string; const Default: TDateTime;
  const AFormatSettings: TFormatSettings): TDateTime; overload;

function TryStrToTime(const S: string; out Value: TDateTime): Boolean; overload; inline;
function TryStrToTime(const S: string; out Value: TDateTime;
  const AFormatSettings: TFormatSettings): Boolean; overload;

{ StrToDateTime converts the given string to a date and time value. The
  string must contain a date optionally followed by a time. The date and
  time parts of the string must follow the formats described for the
  StrToDate and StrToTime functions. }

function StrToDateTime(const S: string): TDateTime; overload; inline;
function StrToDateTime(const S: string;
  const AFormatSettings: TFormatSettings): TDateTime; overload;

function StrToDateTimeDef(const S: string;
  const Default: TDateTime): TDateTime; overload; inline;
function StrToDateTimeDef(const S: string; const Default: TDateTime;
  const AFormatSettings: TFormatSettings): TDateTime; overload;

function TryStrToDateTime(const S: string;
  out Value: TDateTime): Boolean; overload; inline;
function TryStrToDateTime(const S: string; out Value: TDateTime;
  const AFormatSettings: TFormatSettings): Boolean; overload;

{ FormatDateTime formats the date-and-time value given by DateTime using the
  format given by Format. The following format specifiers are supported:

  c       Displays the date using the format given by the ShortDateFormat
          global variable, followed by the time using the format given by
          the LongTimeFormat global variable. The time is not displayed if
          the fractional part of the DateTime value is zero.

  d       Displays the day as a number without a leading zero (1-31).

  dd      Displays the day as a number with a leading zero (01-31).

  ddd     Displays the day as an abbreviation (Sun-Sat) using the strings
          given by the ShortDayNames global variable.

  dddd    Displays the day as a full name (Sunday-Saturday) using the strings
          given by the LongDayNames global variable.

  ddddd   Displays the date using the format given by the ShortDateFormat
          global variable.

  dddddd  Displays the date using the format given by the LongDateFormat
          global variable.

  g       Displays the period/era as an abbreviation (Japanese and
          Taiwanese locales only).

  gg      Displays the period/era as a full name.

  e       Displays the year in the current period/era as a number without
          a leading zero (Japanese, Korean and Taiwanese locales only).

  ee      Displays the year in the current period/era as a number with
          a leading zero (Japanese, Korean and Taiwanese locales only).

  m       Displays the month as a number without a leading zero (1-12). If
          the m specifier immediately follows an h or hh specifier, the
          minute rather than the month is displayed.

  mm      Displays the month as a number with a leading zero (01-12). If
          the mm specifier immediately follows an h or hh specifier, the
          minute rather than the month is displayed.

  mmm     Displays the month as an abbreviation (Jan-Dec) using the strings
          given by the ShortMonthNames global variable.

  mmmm    Displays the month as a full name (January-December) using the
          strings given by the LongMonthNames global variable.

  yy      Displays the year as a two-digit number (00-99).

  yyyy    Displays the year as a four-digit number (0000-9999).

  h       Displays the hour without a leading zero (0-23).

  hh      Displays the hour with a leading zero (00-23).

  n       Displays the minute without a leading zero (0-59).

  nn      Displays the minute with a leading zero (00-59).

  s       Displays the second without a leading zero (0-59).

  ss      Displays the second with a leading zero (00-59).

  z       Displays the millisecond without a leading zero (0-999).

  zzz     Displays the millisecond with a leading zero (000-999).

  t       Displays the time using the format given by the ShortTimeFormat
          global variable.

  tt      Displays the time using the format given by the LongTimeFormat
          global variable.

  am/pm   Uses the 12-hour clock for the preceding h or hh specifier, and
          displays 'am' for any hour before noon, and 'pm' for any hour
          after noon. The am/pm specifier can use lower, upper, or mixed
          case, and the result is displayed accordingly.

  a/p     Uses the 12-hour clock for the preceding h or hh specifier, and
          displays 'a' for any hour before noon, and 'p' for any hour after
          noon. The a/p specifier can use lower, upper, or mixed case, and
          the result is displayed accordingly.

  ampm    Uses the 12-hour clock for the preceding h or hh specifier, and
          displays the contents of the TimeAMString global variable for any
          hour before noon, and the contents of the TimePMString global
          variable for any hour after noon.

  /       Displays the date separator character given by the DateSeparator
          global variable.

  :       Displays the time separator character given by the TimeSeparator
          global variable.

  'xx'    Characters enclosed in single or double quotes are displayed as-is,
  "xx"    and do not affect formatting.

  Format specifiers may be written in upper case as well as in lower case
  letters--both produce the same result.

  If the string given by the Format parameter is empty, the date and time
  value is formatted as if a 'c' format specifier had been given.

  The following example:

    S := FormatDateTime('"The meeting is on" dddd, mmmm d, yyyy, ' +
      '"at" hh:mm AM/PM', StrToDateTime('2/15/95 10:30am'));

  assigns 'The meeting is on Wednesday, February 15, 1995 at 10:30 AM' to
  the string variable S. }

function FormatDateTime(const Format: string;
  DateTime: TDateTime): string; overload; inline;
function FormatDateTime(const Format: string; DateTime: TDateTime;
  const AFormatSettings: TFormatSettings): string; overload;

{ DateTimeToString converts the date and time value given by DateTime using
  the format string given by Format into the string variable given by Result.
  For further details, see the description of the FormatDateTime function. }

procedure DateTimeToString(var Result: string; const Format: string;
  DateTime: TDateTime); overload; inline;
procedure DateTimeToString(var Result: string; const Format: string;
  DateTime: TDateTime; const AFormatSettings: TFormatSettings); overload;

{ FloatToDateTime will range validate a value to make sure it falls
  within the acceptable date range }

const
  MinDateTime: TDateTime = -657434.0;      { 01/01/0100 12:00:00.000 AM }
  MaxDateTime: TDateTime =  2958465.99999; { 12/31/9999 11:59:59.999 PM }

function FloatToDateTime(const Value: Extended): TDateTime;
function TryFloatToDateTime(const Value: Extended; out AResult: TDateTime): Boolean;

{ System error messages }

function SysErrorMessage(ErrorCode: Cardinal): string;

{ Initialization file support }

function GetLocaleStr(Locale, LocaleType: Integer; const Default: string): string; platform;
function GetLocaleChar(Locale, LocaleType: Integer; Default: Char): Char; platform;

{ GetFormatSettings resets all locale-specific variables (date, time, number,
  currency formats, system locale) to the values provided by the operating system. }

procedure GetFormatSettings;

{ GetLocaleFormatSettings loads locale-specific variables (date, time, number,
  currency formats) with values provided by the operating system for the
  specified locale. The values are stored in the FormatSettings record.

  Note: This function is deprecated, TFormatSettings.Create(Locale)
  should be used instead. }

procedure GetLocaleFormatSettings(Locale: TLocaleID;
  var AFormatSettings: TFormatSettings); inline; platform; deprecated 'Use TFormatSettings.Create(Locale)';

{
  LCIDToCodePage retrieves the ANSI codepage associated with a given
  locale identifier.
}
function LCIDToCodePage(const ALCID: LCID): Integer;

{ Exception handling routines }

{ In Linux, the parameter to sleep() is in whole seconds.  In Windows, the
  parameter is in milliseconds.  To ease headaches, we implement a version
  of sleep here for Linux that takes milliseconds and calls a Linux system
  function with sub-second resolution.  This maps directly to the Windows
  API on Winapi.Windows. }

function GetModuleName(Module: HMODULE): string;

function ExceptionErrorMessage(ExceptObject: TObject; ExceptAddr: Pointer;
  Buffer: PChar; Size: Integer): Integer;

procedure ShowException(ExceptObject: TObject; ExceptAddr: Pointer);

procedure Abort;

procedure OutOfMemoryError;

procedure Beep; inline;

{ MBCS functions }

{ LeadBytes is a char set that indicates which char values are lead bytes
  in multibyte character sets (Japanese, Chinese, etc).
  This set is always empty for western locales. }
var
  LeadBytes: set of AnsiChar = [];

{ ByteType indicates what kind of byte exists at the Index'th byte in S.
  Western locales always return mbSingleByte.  Far East multibyte locales
  may also return mbLeadByte, indicating the byte is the first in a multibyte
  character sequence, and mbTrailByte, indicating that the byte is one of
  a sequence of bytes following a lead byte.  One or more trail bytes can
  follow a lead byte, depending on locale charset encoding and OS platform.
  Parameters are assumed to be valid. }

function ByteType(const S: AnsiString; Index: Integer): TMbcsByteType; overload;
function ByteType(const S: UnicodeString; Index: Integer): TMbcsByteType; overload;

{ StrByteType works the same as ByteType, but on null-terminated PChar strings }

function StrByteType(Str: PAnsiChar; Index: Cardinal): TMbcsByteType; overload;
function StrByteType(Str: PWideChar; Index: Cardinal): TMbcsByteType; overload;

{ ByteToCharLen returns the character length of a MBCS string, scanning the
  string for up to MaxLen bytes.  In multibyte character sets, the number of
  characters in a string may be less than the number of bytes.  }

function ByteToCharLen(const S: AnsiString; MaxLen: Integer): Integer; overload; inline;
function ByteToCharLen(const S: UnicodeString; MaxLen: Integer): Integer; overload; inline; deprecated 'Use ElementToCharLen.';

function ElementToCharLen(const S: AnsiString; MaxLen: Integer): Integer; overload;
function ElementToCharLen(const S: UnicodeString; MaxLen: Integer): Integer; overload;

{ CharToByteLen returns the byte length of a MBCS string, scanning the string
  for up to MaxLen characters. }

function CharToByteLen(const S: AnsiString; MaxLen: Integer): Integer; overload; inline;
function CharToByteLen(const S: UnicodeString; MaxLen: Integer): Integer; overload; inline; deprecated 'Use CharToElementLen.';

function CharToElementLen(const S: AnsiString; MaxLen: Integer): Integer; overload;
function CharToElementLen(const S: UnicodeString; MaxLen: Integer): Integer; overload;

{ ByteToCharIndex returns the 1-based character index of the Index'th byte in
  a MBCS string.  Returns zero if Index is out of range:
  (Index <= 0) or (Index > Length(S)) }

function ByteToCharIndex(const S: AnsiString; Index: Integer): Integer; overload; inline;
function ByteToCharIndex(const S: UnicodeString; Index: Integer): Integer; overload; inline; deprecated 'Use ElementToCharIndex.';

function ElementToCharIndex(const S: AnsiString; Index: Integer): Integer; overload;
function ElementToCharIndex(const S: UnicodeString; Index: Integer): Integer; overload;

{ CharToByteIndex returns the 1-based byte index of the Index'th character
  in a MBCS string.  Returns zero if Index or Result are out of range:
  (Index <= 0) or (Index > Length(S)) or (Result would be > Length(S)) }

function CharToByteIndex(const S: AnsiString; Index: Integer): Integer; overload; inline;
function CharToByteIndex(const S: UnicodeString; Index: Integer): Integer; overload; inline; deprecated 'Use CharToElementIndex.';

function CharToElementIndex(const S: AnsiString; Index: Integer): Integer; overload;
function CharToElementIndex(const S: UnicodeString; Index: Integer): Integer; overload;

{ StrCharLength returns the number of bytes required by the first character
  in Str.  In Windows, multibyte characters can be up to two bytes in length.
  In Linux, multibyte characters can be up to six bytes in length (UTF-8). }

function StrCharLength(const Str: PAnsiChar): Integer; overload;
function StrCharLength(const Str: PWideChar): Integer; overload;

{ StrNextChar returns a pointer to the first byte of the character following
  the character pointed to by Str.  }

function StrNextChar(const Str: PAnsiChar): PAnsiChar; inline; overload;
function StrNextChar(const Str: PWideChar): PWideChar; overload;

{ CharLength returns the number of bytes required by the character starting
  at bytes S[Index].  }

function CharLength(const S: AnsiString; Index: Integer): Integer; overload;
function CharLength(const S: UnicodeString; Index: Integer): Integer; overload;

{ NextCharIndex returns the byte index of the first byte of the character
  following the character starting at S[Index].  }

function NextCharIndex(const S: UnicodeString; Index: Integer): Integer; overload;
function NextCharIndex(const S: AnsiString; Index: Integer): Integer; overload;

{ IsLeadChar returns whether or not the Char is part of a multi-character sequence }

function IsLeadChar(C: AnsiChar): Boolean; overload; inline;
function IsLeadChar(C: WideChar): Boolean; overload; inline;

{ CharInSet tests whether or not the given character is in the given set of lower
  characters }

function CharInSet(C: AnsiChar; const CharSet: TSysCharSet): Boolean; overload; inline;
function CharInSet(C: WideChar; const CharSet: TSysCharSet): Boolean; overload; inline;

{ IsPathDelimiter returns True if the character at byte S[Index]
  is a PathDelimiter ('\' or '/'), and it is not a MBCS lead or trail byte. }

function IsPathDelimiter(const S: string; Index: Integer): Boolean; overload;

{ IsDelimiter returns True if the character at byte S[Index] matches any
  character in the Delimiters string, and the character is not a MBCS lead or
  trail byte.  S may contain multibyte characters; Delimiters must contain
  only single byte characters. }

function IsDelimiter(const Delimiters, S: string; Index: Integer): Boolean; overload;

{ IncludeTrailingPathDelimiter returns the path with a PathDelimiter
  ('/' or '\') at the end.  This function is MBCS enabled. }

function IncludeTrailingPathDelimiter(const S: string): string; overload;

{ IncludeTrailingBackslash is the old name for IncludeTrailingPathDelimiter. }

function IncludeTrailingBackslash(const S: string): string; platform; overload; inline;

{ ExcludeTrailingPathDelimiter returns the path without a PathDelimiter
  ('\' or '/') at the end.  This function is MBCS enabled. }

function ExcludeTrailingPathDelimiter(const S: string): string; overload;

{ ExcludeTrailingBackslash is the old name for ExcludeTrailingPathDelimiter. }

function ExcludeTrailingBackslash(const S: string): string; platform; overload; inline;

{ LastDelimiter returns the byte index in S of the rightmost whole
  character that matches any character in Delimiters (except null (#0)).
  S may contain multibyte characters; Delimiters must contain only single
  byte non-null characters.
  Example: LastDelimiter('\.:', 'c:\filename.ext') returns 12. }

function LastDelimiter(const Delimiters, S: string): Integer; overload;

{ FindDelimiter returns the index in S of the character that matches any of
  the characters in Delimiters (except null (#)). StartIdx specifies the
  index in S at which the search for delimiters will start. }

function FindDelimiter(const Delimiters, S: string; StartIdx: Integer = 1): Integer;

{ AnsiPos:  Same as Pos but supports MBCS strings }

function AnsiPos(const Substr, S: string): Integer; overload;

{ AnsiStrPos: Same as StrPos but supports MBCS strings }

function AnsiStrPos(Str, SubStr: PAnsiChar): PAnsiChar; overload;
function AnsiStrPos(Str, SubStr: PWideChar): PWideChar; overload;

{ AnsiStrRScan: Same as StrRScan but supports MBCS strings }

function AnsiStrRScan(Str: PAnsiChar; Chr: AnsiChar): PAnsiChar; overload;
function AnsiStrRScan(Str: PWideChar; Chr: WideChar): PWideChar; inline; overload;

{ AnsiStrScan: Same as StrScan but supports MBCS strings }

function AnsiStrScan(Str: PAnsiChar; Chr: AnsiChar): PAnsiChar; overload;
function AnsiStrScan(Str: PWideChar; Chr: WideChar): PWideChar; overload; inline;

{ StringReplace replaces occurances of <oldpattern> with <newpattern> in a
  given string.  Assumes the string may contain Multibyte characters }

type
  TReplaceFlags = set of (rfReplaceAll, rfIgnoreCase);

function StringReplace(const S, OldPattern, NewPattern: string;
  Flags: TReplaceFlags): string; overload;

{ WrapText will scan a string for BreakChars and insert the BreakStr at the
  last BreakChar position before MaxCol.  Will not insert a break into an
  embedded quoted string (both ''' and '"' supported) }

function WrapText(const Line, BreakStr: string; const BreakChars: TSysCharSet;
  MaxCol: Integer): string; overload;
function WrapText(const Line: string; MaxCol: Integer = 45): string; overload;

{ FindCmdLineSwitch determines whether the string in the Switch parameter
  was passed as a command line argument to the application.  SwitchChars
  identifies valid argument-delimiter characters (i.e., "-" and "/" are
  common delimiters). The IgnoreCase paramter controls whether a
  case-sensistive or case-insensitive search is performed. }

const
  SwitchChars = ['/','-'];

function FindCmdLineSwitch(const Switch: string; const Chars: TSysCharSet;
  IgnoreCase: Boolean): Boolean; overload;

{ These versions of FindCmdLineSwitch are convenient for writing portable
  code.  The characters that are valid to indicate command line switches vary
  on different platforms.  For example, '/' cannot be used as a switch char
  on Linux because '/' is the path delimiter. }

{ This version uses SwitchChars defined above, and IgnoreCase False. }
function FindCmdLineSwitch(const Switch: string): Boolean; overload;

{ This version uses SwitchChars defined above. }
function FindCmdLineSwitch(const Switch: string; IgnoreCase: Boolean): Boolean; overload;

type
  TCmdLineSwitchType = (clstValueNextParam, clstValueAppended);
  TCmdLineSwitchTypes = set of TCmdLineSwitchType;

{ This version is used to return values.
  Switch values may be specified in the following ways on the command line:
    -p Value                - clstValueNextParam
    -pValue or -p:Value     - clstValueAppended

  Pass the SwitchTypes parameter to exclude either of these switch types.
  Switch may be 1 or more characters in length. }
function FindCmdLineSwitch(const Switch: string; var Value: string; IgnoreCase: Boolean = True;
  const SwitchTypes: TCmdLineSwitchTypes = [clstValueNextParam, clstValueAppended]): Boolean; overload;

{ FreeAndNil frees the given TObject instance and sets the variable reference
  to nil.  Be careful to only pass TObjects to this routine. }

procedure FreeAndNil(var Obj); inline;

{ Interface support routines }

function Supports(const Instance: IInterface; const IID: TGUID; out Intf): Boolean; overload;
function Supports(const Instance: TObject; const IID: TGUID; out Intf): Boolean; overload;
function Supports(const Instance: IInterface; const IID: TGUID): Boolean; overload;
function Supports(const Instance: TObject; const IID: TGUID): Boolean; overload; // Unsafe
function Supports(const AClass: TClass; const IID: TGUID): Boolean; overload;

function CreateGUID(out Guid: TGUID): HResult;
function StringToGUID(const S: string): TGUID;
function GUIDToString(const Guid: TGUID): string;
function IsEqualGUID(const Guid1, Guid2: TGUID): Boolean;

type
  TGuidHelper = record helper for TGUID
    class function Create(const B: TBytes): TGUID; overload; static;
    class function Create(const S: string): TGUID; overload; static;
    class function Create(A: Integer; B: SmallInt; C: SmallInt; const D: TBytes): TGUID; overload; static;
    class function Create(A: Integer; B: SmallInt; C: SmallInt; D, E, F, G, H, I, J, K: Byte): TGUID; overload; static;
    class function Create(A: Cardinal; B: Word; C: Word; D, E, F, G, H, I, J, K: Byte): TGUID; overload; static;
    class function NewGuid: TGUID; static;
    function ToByteArray: TBytes;
    function ToString: string;
  end;

{ RaiseLastOSError calls GetLastError to retrieve the code for
  the last occuring error in a call to an OS or system library function.
  If GetLastError returns an error code,  RaiseLastOSError raises
  an EOSError exception with the error code and a system-provided
  message associated with with error. }

procedure RaiseLastOSError; overload;
procedure RaiseLastOSError(LastError: Integer); overload;
procedure CheckOSError(LastError: Integer); inline;

procedure RaiseLastWin32Error; deprecated 'Use RaiseLastOSError';

{ Win32Check is used to check the return value of a Win32 API function     }
{ which returns a BOOL to indicate success.  If the Win32 API function     }
{ returns False (indicating failure), Win32Check calls RaiseLastOSError }
{ to raise an exception.  If the Win32 API function returns True,          }
{ Win32Check returns True. }

function Win32Check(RetVal: BOOL): BOOL; platform;

{ Termination procedure support }

type
  TTerminateProc = function: Boolean;

{ Call AddTerminateProc to add a terminate procedure to the system list of }
{ termination procedures.  Delphi will call all of the function in the     }
{ termination procedure list before an application terminates.  The user-  }
{ defined TermProc function should return True if the application can      }
{ safely terminate or False if the application cannot safely terminate.    }
{ If one of the functions in the termination procedure list returns False, }
{ the application will not terminate. }

procedure AddTerminateProc(TermProc: TTerminateProc);

{ CallTerminateProcs is called by VCL when an application is about to }
{ terminate.  It returns True only if all of the functions in the     }
{ system's terminate procedure list return True.  This function is    }
{ intended only to be called by Delphi, and it should not be called   }
{ directly. }

function CallTerminateProcs: Boolean;

function GDAL: LongWord;
procedure RCS;
procedure RPR;


{ HexDisplayPrefix contains the prefix to display on hexadecimal
  values - '$' for Pascal syntax, '0x' for C++ syntax.  This is
  for display only - this does not affect the string-to-integer
  conversion routines. }
var
  HexDisplayPrefix: string = '$';

{ SafeLoadLibrary calls LoadLibrary, disabling normal Win32 error message
  popup dialogs if the requested file can't be loaded.  SafeLoadLibrary also
  preserves the current FPU control word (precision, exception masks) across
  the LoadLibrary call (in case the DLL you're loading hammers the FPU control
  word in its initialization, as many MS DLLs do)}

function SafeLoadLibrary(const FileName: string;
  ErrorMode: UINT = SEM_NOOPENFILEERRORBOX): HMODULE;

function GetEnvironmentVariable(const Name: string): string; overload;

// Utility function for .NET source compatibility

function DelegatesEqual(A, B: Pointer): Boolean; inline;

// Utility functions for Unicode support

function ByteLength(const S: string): Integer; inline;

type
  EEncodingError = class(Exception);

// Generic Anonymous method declarations
type
  TProc = reference to procedure;
  TProc<T> = reference to procedure (Arg1: T);
  TProc<T1,T2> = reference to procedure (Arg1: T1; Arg2: T2);
  TProc<T1,T2,T3> = reference to procedure (Arg1: T1; Arg2: T2; Arg3: T3);
  TProc<T1,T2,T3,T4> = reference to procedure (Arg1: T1; Arg2: T2; Arg3: T3; Arg4: T4);

  TFunc<TResult> = reference to function: TResult;
  TFunc<T,TResult> = reference to function (Arg1: T): TResult;
  TFunc<T1,T2,TResult> = reference to function (Arg1: T1; Arg2: T2): TResult;
  TFunc<T1,T2,T3,TResult> = reference to function (Arg1: T1; Arg2: T2; Arg3: T3): TResult;
  TFunc<T1,T2,T3,T4,TResult> = reference to function (Arg1: T1; Arg2: T2; Arg3: T3; Arg4: T4): TResult;

  TPredicate<T> = reference to function (Arg1: T): Boolean;

{ GetDefaultFallbackLanguages retrieves the current DefaultFallbackLanguages string. }
function GetDefaultFallbackLanguages: string;

{ SetDefaultFallbackLanguages set new default fallback languages. }
procedure SetDefaultFallbackLanguages(const Languages: string);

{ PreferredUILanguages retrieves the preferred UI languages for the user's
  default UI langauges at runtime. This function uses System.GetUILanguages
  with GetUserDefaultUILanguage Windows API and DefaultFallbackLanguages setting. }
function PreferredUILanguages: string;

{$SCOPEDENUMS ON}
type
  TUncertainState = (Maybe, Yes, No);
{$SCOPEDENUMS OFF}

type
  TOSVersion = record
  public type
    TArchitecture = (arIntelX86, arIntelX64);
    TPlatform = (pfWindows, pfMacOS);
  private
    class var FArchitecture: TArchitecture;
    class var FBuild: Integer;
    class var FMajor: Integer;
    class var FMinor: Integer;
    class var FName: string;
    class var FPlatform: TPlatform;
    class var FServicePackMajor: Integer;
    class var FServicePackMinor: Integer;
    class constructor Create;
  public
    class function Check(AMajor: Integer): Boolean; overload; static; inline;
    class function Check(AMajor, AMinor: Integer): Boolean; overload; static; inline;
    class function Check(AMajor, AMinor, AServicePackMajor: Integer): Boolean; overload; static; inline;
    class function ToString: string; static;
    class property Architecture: TArchitecture read FArchitecture;
    class property Build: Integer read FBuild;
    class property Major: Integer read FMajor;
    class property Minor: Integer read FMinor;
    class property Name: string read FName;
    class property Platform: TPlatform read FPlatform;
    class property ServicePackMajor: Integer read FServicePackMajor;
    class property ServicePackMinor: Integer read FServicePackMinor;
  end;

type
  TExceptType = (etDivByZero, etRangeError, etIntOverflow, etInvalidOp, etZeroDivide, etOverflow, etUnderflow,
    etInvalidCast, etAccessViolation, etPrivilege, etControlC, etStackOverflow, etVariantError, etAssertionFailed,
    etExternalException, etIntfCastError, etSafeCallException, etMonitorLockException, etNoMonitorSupportException,
    etNotImplemented
  );

  TExceptRec = record
    EClass: TExceptType;
    EIdent: string;
  end;

resourcestring
  SUnknown = '<unknown>';
  SInvalidInteger = '''%s'' is not a valid integer value';
  SInvalidFloat = '''%s'' is not a valid floating point value';
  SInvalidCurrency = '''%s'' is not a valid currency value';
  SInvalidDate = '''%s'' is not a valid date';
  SInvalidTime = '''%s'' is not a valid time';
  SInvalidDateTime = '''%s'' is not a valid date and time';
  SInvalidDateTimeFloat = '''%g'' is not a valid date and time';
  SInvalidTimeStamp = '''%d.%d'' is not a valid timestamp';
  SInvalidGUID = '''%s'' is not a valid GUID value';
  SInvalidBoolean = '''%s'' is not a valid boolean value';
  STimeEncodeError = 'Invalid argument to time encode';
  SDateEncodeError = 'Invalid argument to date encode';
  SOutOfMemory = 'Out of memory';
  SInOutError = 'I/O error %d';
  SFileNotFound = 'File not found';
  SInvalidFilename = 'Invalid filename';
  STooManyOpenFiles = 'Too many open files';
  SAccessDenied = 'File access denied';
  SEndOfFile = 'Read beyond end of file';
  SDiskFull = 'Disk full';
  SInvalidInput = 'Invalid numeric input';
  SDivByZero = 'Division by zero';
  SRangeError = 'Range check error';
  SIntOverflow = 'Integer overflow';
  SInvalidOp = 'Invalid floating point operation';
  SZeroDivide = 'Floating point division by zero';
  SOverflow = 'Floating point overflow';
  SUnderflow = 'Floating point underflow';
  SInvalidPointer = 'Invalid pointer operation';
  SInvalidCast = 'Invalid class typecast';
  SFormatTooLong = 'Format string too long';
  SOSError = 'System Error.  Code: %d.'+sLineBreak+'%s';
  SUnkOSError = 'A call to an OS function failed';
  SNL = 'Application is not licensed to use this feature';

  SShortMonthNameJan = 'Jan';
  SShortMonthNameFeb = 'Feb';
  SShortMonthNameMar = 'Mar';
  SShortMonthNameApr = 'Apr';
  SShortMonthNameMay = 'May';
  SShortMonthNameJun = 'Jun';
  SShortMonthNameJul = 'Jul';
  SShortMonthNameAug = 'Aug';
  SShortMonthNameSep = 'Sep';
  SShortMonthNameOct = 'Oct';
  SShortMonthNameNov = 'Nov';
  SShortMonthNameDec = 'Dec';

  SLongMonthNameJan = 'January';
  SLongMonthNameFeb = 'February';
  SLongMonthNameMar = 'March';
  SLongMonthNameApr = 'April';
  SLongMonthNameMay = 'May';
  SLongMonthNameJun = 'June';
  SLongMonthNameJul = 'July';
  SLongMonthNameAug = 'August';
  SLongMonthNameSep = 'September';
  SLongMonthNameOct = 'October';
  SLongMonthNameNov = 'November';
  SLongMonthNameDec = 'December';

  SShortDayNameSun = 'Sun';
  SShortDayNameMon = 'Mon';
  SShortDayNameTue = 'Tue';
  SShortDayNameWed = 'Wed';
  SShortDayNameThu = 'Thu';
  SShortDayNameFri = 'Fri';
  SShortDayNameSat = 'Sat';

  SLongDayNameSun = 'Sunday';
  SLongDayNameMon = 'Monday';
  SLongDayNameTue = 'Tuesday';
  SLongDayNameWed = 'Wednesday';
  SLongDayNameThu = 'Thursday';
  SLongDayNameFri = 'Friday';
  SLongDayNameSat = 'Saturday';

  SException = 'Exception %s in module %s at %p.' + sLineBreak + '%s%s' + sLineBreak;
  SExceptTitle = 'Application Error';
  SOperationAborted = 'Operation aborted';
  SAssertError = '%s (%s, line %d)';
  SAbstractError = 'Abstract Error';
  SAssertionFailed = 'Assertion failed';
  SReadAccess = 'Read';
  SWriteAccess = 'Write';
  SModuleAccessViolation = 'Access violation at address %p in module ''%s''. %s of address %p';
  SAccessViolationArg3 = 'Access violation at address %p. %s of address %p';
  SExternalException = 'External exception %x';
  SAccessViolationNoArg = 'Access violation';
  SPrivilege = 'Privileged instruction';
  SStackOverflow = 'Stack overflow';
  SControlC = 'Control-C hit';
  SInvalidVarCast = 'Invalid variant type conversion';
  SInvalidVarOp = 'Invalid variant operation';
  SDispatchError = 'Variant method calls not supported';
  SVarArrayCreate = 'Error creating variant or safe array';
  SVarArrayBounds = 'Variant or safe array index out of bounds';
  SSafecallException = 'Exception in safecall method';
  SMonitorLockException = 'Object lock not owned';
  SNoMonitorSupportException = 'Monitor support function not initialized';
  SNotImplemented = 'Feature not implemented';
  SVarInvalid = 'Invalid argument';
  SIntfCastError = 'Interface not supported';
  SInvalidFormat = 'Format ''%s'' invalid or incompatible with argument';
  SArgumentMissing = 'No argument for format ''%s''';

const
  ExceptTypes: array[TExceptType] of ExceptClass = (
    EDivByZero,
    ERangeError,
    EIntOverflow,
    EInvalidOp,
    EZeroDivide,
    EOverflow,
    EUnderflow,
    EInvalidCast,
    EAccessViolation,
    EPrivilege,
    EControlC,
    EStackOverflow,
    EVariantError,
    EAssertionFailed,
    EExternalException,
    EIntfCastError,
    ESafecallException,
    EMonitorLockException,
    ENoMonitorSupportException,
    ENotImplemented
  );
  // by using another indirection, the linker can actually eliminate all exception support if exceptions are not
  // referenced by the applicaiton.
  ExceptMap: array[Ord(reDivByZero)..Ord(High(TRuntimeError))] of TExceptRec = (
    (EClass: etDivByZero; EIdent: SDivByZero),
    (EClass: etRangeError; EIdent: SRangeError),
    (EClass: etIntOverflow; EIdent: SIntOverflow),
    (EClass: etInvalidOp; EIdent: SInvalidOp),
    (EClass: etZeroDivide; EIdent: SZeroDivide),
    (EClass: etOverflow; EIdent: SOverflow),
    (EClass: etUnderflow; EIdent: SUnderflow),
    (EClass: etInvalidCast; EIdent: SInvalidCast),
    (EClass: etAccessViolation; EIdent: SAccessViolationNoArg),
    (EClass: etPrivilege; EIdent: SPrivilege),
    (EClass: etControlC; EIdent: SControlC),
    (EClass: etStackOverflow; EIdent: SStackOverflow),
    (EClass: etVariantError; EIdent: SInvalidVarCast),
    (EClass: etVariantError; EIdent: SInvalidVarOp),
    (EClass: etVariantError; EIdent: SDispatchError),
    (EClass: etVariantError; EIdent: SVarArrayCreate),
    (EClass: etVariantError; EIdent: SVarInvalid),
    (EClass: etVariantError; EIdent: SVarArrayBounds),
    (EClass: etAssertionFailed; EIdent: SAssertionFailed),
    (EClass: etExternalException; EIdent: SExternalException),
    (EClass: etIntfCastError; EIdent: SIntfCastError),
    (EClass: etSafecallException; EIdent: SSafecallException),
    (EClass: etMonitorLockException; EIdent: SMonitorLockException),
    (EClass: etNoMonitorSupportException; EIdent: SNoMonitorSupportException),
    (EClass: etNotImplemented; EIdent: SNotImplemented)
    );

function HashName(Name: PAnsiChar): Cardinal;

resourcestring
  SInvalidGuidArray = 'Byte array for GUID must be exactly %s bytes long';
  SDriveNotFound = 'The drive cannot be found';
  SListCapacityError = 'List capacity out of bounds (%d)';
  SListIndexError = 'List index out of bounds (%d)';
  SParamIsNegative = 'Parameter %s cannot be a negative value';
  SInputBufferExceed = 'Input buffer exceeded for %s = %d, %s = %d';

function ChangeFileExt(const FileName, Extension: string): string; overload;

{ ChangeFilePath changes the path of a filename. FileName specifies a
  filename with or without an extension, and Path specifies the new
  path for the filename. The new path is not required to contain the trailing
  path delimiter. }

function ChangeFilePath(const FileName, Path: string): string; overload;

{ ExtractFilePath extracts the drive and directory parts of the given
  filename. The resulting string is the leftmost characters of FileName,
  up to and including the colon or backslash that separates the path
  information from the name and extension. The resulting string is empty
  if FileName contains no drive and directory parts. }

function ExtractFilePath(const FileName: string): string; overload;

{ ExtractFileDir extracts the drive and directory parts of the given
  filename. The resulting string is a directory name suitable for passing
  to SetCurrentDir, CreateDir, etc. The resulting string is empty if
  FileName contains no drive and directory parts. }

function ExtractFileDir(const FileName: string): string; overload;

{ ExtractFileDrive extracts the drive part of the given filename.  For
  filenames with drive letters, the resulting string is '<drive>:'.
  For filenames with a UNC path, the resulting string is in the form
  '\\<servername>\<sharename>'.  If the given path contains neither
  style of filename, the result is an empty string. }

function ExtractFileDrive(const FileName: string): string; overload;

{ ExtractFileName extracts the name and extension parts of the given
  filename. The resulting string is the leftmost characters of FileName,
  starting with the first character after the colon or backslash that
  separates the path information from the name and extension. The resulting
  string is equal to FileName if FileName contains no drive and directory
  parts. }

function ExtractFileName(const FileName: string): string; overload;

{ ExtractFileExt extracts the extension part of the given filename. The
  resulting string includes the period character that separates the name
  and extension parts. The resulting string is empty if the given filename
  has no extension. }

function ExtractFileExt(const FileName: string): string; overload;

{ ExpandFileName expands the given filename to a fully qualified filename.
  The resulting string consists of a drive letter, a colon, a root relative
  directory path, and a filename. Embedded '.' and '..' directory references
  are removed. }

function ExpandFileName(const FileName: string): string; overload;

{ ExpandFilenameCase returns a fully qualified filename like ExpandFilename,
  but performs a case-insensitive filename search looking for a close match
  in the actual file system, differing only in uppercase versus lowercase of
  the letters.  This is useful to convert lazy user input into useable file
  names, or to convert filename data created on a case-insensitive file
  system (Win32) to something useable on a case-sensitive file system (Linux).

  The MatchFound out parameter indicates what kind of match was found in the
  file system, and what the function result is based upon:

  ( in order of increasing difficulty or complexity )
  mkExactMatch:  Case-sensitive match.  Result := ExpandFileName(FileName).
  mkSingleMatch: Exactly one file in the given directory path matches the
        given filename on a case-insensitive basis.
        Result := ExpandFileName(FileName as found in file system).
  mkAmbiguous: More than one file in the given directory path matches the
        given filename case-insensitively.
        In many cases, this should be considered an error.
        Result := ExpandFileName(First matching filename found).
  mkNone:  File not found at all.  Result := ExpandFileName(FileName).

  Note that because this function has to search the file system it may be
  much slower than ExpandFileName, particularly when the given filename is
  ambiguous or does not exist.  Use ExpandFilenameCase only when you have
  a filename of dubious orgin - such as from user input - and you want
  to make a best guess before failing.  }

function Point(X, Y: Integer): TPoint; overload; inline;
function Point(P: TSmallPoint): TPoint; overload; inline;
function Point(P: TPoint): TSmallPoint; overload; inline;

function Rect(Left, Top, Right, Bottom: Integer): TRect; overload; inline;
function Bounds(Left, Top, Width, Height: Integer): TRect; inline;
function Rect(const ARect: TSmallRect): TRect; overload; inline;
function Rect(const ARect: TRect): TSmallRect; overload; inline;

function Min(A, B: Integer): Integer; inline;
function Max(A, B: Integer): Integer; inline;

function PosEx(const SubStr, Str: string; Offset: Integer = 1): Integer;

implementation

uses
  sdaCharacter;

function PosEx(const SubStr, Str: string; Offset: Integer): Integer;
var
  i: Integer;
begin
  if Offset <= 0 then Offset := 1;
  for i := Offset to Length(Str) - Length(SubStr) + 1 do
    if Copy(Str, i, Length(SubStr)) = SubStr then Exit(i);
  Result := 0;
end;

function Min(A, B: Integer): Integer;
begin
  if A > B then Result := B else Result := A;
end;

function Max(A, B: Integer): Integer;
begin
  if A < B then Result := B else Result := A;
end;

function Point(X, Y: Integer): TPoint;
begin
  Result.X := X;
  Result.Y := Y;
end;

function Point(P: TSmallPoint): TPoint;
begin
  Result.X := P.x;
  Result.Y := P.y;
end;

function Point(P: TPoint): TSmallPoint;
begin
  Result.x := P.X;
  Result.y := P.Y;
end;

function Rect(Left, Top, Right, Bottom: Integer): TRect;
begin
  Result.Left := Left; Result.Top := Top;
  Result.Right := Right; Result.Bottom := Bottom;
end;

function Bounds(Left, Top, Width, Height: Integer): TRect;
begin
  Result.Left := Left; Result.Top := Top;
  Result.Right := Left + Width;
  Result.Bottom := Top + Height;
end;

function Rect(const ARect: TSmallRect): TRect;
begin
  Result.Left := ARect.Left; Result.Top := ARect.Top;
  Result.Right := ARect.Right; Result.Bottom := ARect.Bottom;
end;

function Rect(const ARect: TRect): TSmallRect;
begin
  Result.Left := ARect.Left; Result.Top := ARect.Top;
  Result.Right := ARect.Right; Result.Bottom := ARect.Bottom;
end;

function AnsiStrLastChar(P: PAnsiChar): PAnsiChar;
var
  LastByte: Integer;
begin
  LastByte := StrLen(P) - 1;
  Result := @P[LastByte];
  if StrByteType(P, LastByte) = mbTrailByte then Dec(Result);
end;

function AnsiStrLastChar(P: PWideChar): PWideChar;
var
  Len: Integer;
begin
  Len := StrLen(P);
  Result := @P[Len - 1];
  if (Len > 1) and (Result^ >= #$DC00) and (Result^ <= #$DFFF) and
     (Result[-1] >= #$D800) and (Result[-1] <= #$DBFF) then
    Dec(Result, 1);
end;

function AnsiLastChar(const S: AnsiString): PAnsiChar;
var
  LastByte: Integer;
begin
  LastByte := Length(S);
  if LastByte <> 0 then
  begin
    while ByteType(S, LastByte) = mbTrailByte do Dec(LastByte);
    Result := @S[LastByte];
  end
  else
    Result := nil;
end;

function AnsiLastChar(const S: UnicodeString): PWideChar;
var
  Len: Integer;
begin
  if S = '' then
    Result := nil
  else
  begin
    Len := Length(S);
    Result := @S[Len];
    if (Len > 1) and (Result^ >= #$DC00) and (Result^ <= #$DFFF) and
       (Result[-1] >= #$D800) and (Result[-1] <= #$DBFF) then
      Dec(Result, 1);
  end;
end;

function LastDelimiter(const Delimiters, S: string): Integer;
var
  P: PChar;
begin
  Result := Length(S);
  P := PChar(Delimiters);
  while Result > 0 do
  begin
    if (S[Result] <> #0) and (StrScan(P, S[Result]) <> nil) then
      Exit;
    Dec(Result);
  end;
end;

function FindDelimiter(const Delimiters, S: string; StartIdx: Integer = 1): Integer;
var
  Stop: Boolean;
  Len: Integer;
begin
  Result := 0;

  Len := Length(S);
  Stop := False;
  while (not Stop) and (StartIdx <= Len) do
    if IsDelimiter(Delimiters, S, StartIdx) then
    begin
      Result := StartIdx;
      Stop := True;
    end
    else
      Inc(StartIdx);
end;

function ChangeFileExt(const FileName, Extension: string): string;
var
  I: Integer;
begin
  I := LastDelimiter('.' + PathDelim + DriveDelim,Filename);
  if (I = 0) or (FileName[I] <> '.') then I := MaxInt;
  Result := Copy(FileName, 1, I - 1) + Extension;
end;

function ChangeFilePath(const FileName, Path: string): string;
begin
  Result := IncludeTrailingPathDelimiter(Path) + ExtractFileName(FileName);
end;

function ExtractFilePath(const FileName: string): string;
var
  I: Integer;
begin
  I := LastDelimiter(PathDelim + DriveDelim, FileName);
  Result := Copy(FileName, 1, I);
end;

function ExtractFileDir(const FileName: string): string;
var
  I: Integer;
begin
  I := LastDelimiter(PathDelim + DriveDelim, Filename);
  if (I > 1) and (FileName[I] = PathDelim) and
    (not IsDelimiter( PathDelim + DriveDelim, FileName, I-1)) then Dec(I);
  Result := Copy(FileName, 1, I);
end;

function ExtractFileDrive(const FileName: string): string;
var
  I, J: Integer;
begin
  if (Length(FileName) >= 2) and (FileName[2] = DriveDelim) then
    Result := Copy(FileName, 1, 2)
  else if (Length(FileName) >= 2) and (FileName[1] = PathDelim) and
    (FileName[2] = PathDelim) then
  begin
    J := 0;
    I := 3;
    While (I < Length(FileName)) and (J < 2) do
    begin
      if FileName[I] = PathDelim then Inc(J);
      if J < 2 then Inc(I);
    end;
    if FileName[I] = PathDelim then Dec(I);
    Result := Copy(FileName, 1, I);
  end else Result := '';
end;

function ExtractFileName(const FileName: string): string;
var
  I: Integer;
begin
  I := LastDelimiter(PathDelim + DriveDelim, FileName);
  Result := Copy(FileName, I + 1, MaxInt);
end;

function ExtractFileExt(const FileName: string): string;
var
  I: Integer;
begin
  I := LastDelimiter('.' + PathDelim + DriveDelim, FileName);
  if (I > 0) and (FileName[I] = '.') then
    Result := Copy(FileName, I, MaxInt) else
    Result := '';
end;

function ExpandFileName(const FileName: string): string;
var
  FName: PChar;
  Buffer: array[0..MAX_PATH - 1] of Char;
  Len: Integer;
begin
  Len := GetFullPathName(PChar(FileName), Length(Buffer), Buffer, FName);
  if Len <= Length(Buffer) then
    SetString(Result, Buffer, Len)
  else if Len > 0 then
  begin
    SetLength(Result, Len);
    Len := GetFullPathName(PChar(FileName), Len, PChar(Result), FName);
    if Len < Length(Result) then
      SetLength(Result, Len);
  end;
end;

//Rewrote using UnicodeFromLocalChars which is a wrapper for MultiByteToWideChar on Windows and emulates it on non windows
function HashNameMBCS(Name: PAnsiChar): Cardinal;
const
  BufferLen = MAX_PATH;
var
  Len, NameLen: Cardinal;
  Data: PWideChar;
  Buffer: array[0..BufferLen - 1] of WideChar;
  I: Integer;
begin
  NameLen := Length(Name);
  Len := UnicodeFromLocaleChars(CP_UTF8, 0, Name, NameLen, nil, 0);
  if Len > BufferLen then
    GetMem(Data, Len * SizeOf(Char))
  else
    Data := @Buffer[0];

  UnicodeFromLocaleChars(CP_UTF8, 0, Name, NameLen, Data, Len);
  AnsiStrUpper(Data);

  Result := 0;
  for I := 0 to Len - 1 do
  begin
    Result := (Result shl 5) or (Result shr 27); //ROL Result, 5
    Result := Result xor Cardinal(Data[I]);
  end;

  if Data <> @Buffer[0] then
    FreeMem(Data);
end;

function HashName(Name: PAnsiChar): Cardinal;
var
  LCurr: PAnsiChar;
begin
  { ESI -> Name }
  Result := 0;
  LCurr := Name;

  while LCurr^ <> #0 do
  begin
    { Abort on a MBCS character }
    if Ord(LCurr^) > 127 then
    begin
      Result := HashNameMBCS(LCurr);
      Exit;
    end;

    { Update the hash. Lowercase the uppercased charaters in the process }
    if LCurr^ in ['A' .. 'Z'] then
      Result := Result xor (Ord(LCurr^) or $20)
    else
      Result := Result xor Ord(LCurr^);

    { Go to next }
    Inc(LCurr);

    { Update the hashed value }
    Result := (Result shr 27) or (Result shl 5);
  end;
end;

const
  MaxSingle   =  3.4e+38;
  MaxDouble   =  1.7e+308;

{ Utility routines }

procedure DivMod(Dividend: Integer; Divisor: Word;
  var Result, Remainder: Word);
begin
  Result    := Dividend div Divisor;
  Remainder := Dividend mod Divisor;
end;

procedure ConvertError(ResString: PResStringRec); local;
begin
  raise EConvertError.CreateRes(ResString);
end;

type
  OBJECT_INFORMATION_CLASS = (ObjectBasicInformation, ObjectNameInformation,
    ObjectTypeInformation, ObjectAllTypesInformation, ObjectHandleInformation);

  UNICODE_STRING = packed record
    Length: Word;
    MaximumLength: Word;
    Buffer:PWideChar;
  end;

  OBJECT_NAME_INFORMATION = record
    TypeName: UNICODE_STRING;
    Reserved: array[0..21] of ULONG; // reserved for internal use
  end;

  TNtQueryObject = function (ObjectHandle: THandle;
    ObjectInformationClass: OBJECT_INFORMATION_CLASS; ObjectInformation: Pointer;
    Length: ULONG; ResultLength: PDWORD): THandle; stdcall;

procedure ConvertErrorFmt(ResString: PResStringRec; const Args: array of const); local;
begin
  raise EConvertError.CreateResFmt(ResString, Args);
end;

function CreateGUID(out Guid: TGUID): HResult;
begin
  Result := CoCreateGuid(Guid);
end;

function StringToGUID(const S: string): TGUID;

  procedure InvalidGUID;
  begin
    ConvertErrorFmt(@SInvalidGUID, [s]);
  end;

  function HexChar(c: Char): Byte;
  begin
    case c of
      '0'..'9':  Result := Byte(c) - Byte('0');
      'a'..'f':  Result := (Byte(c) - Byte('a')) + 10;
      'A'..'F':  Result := (Byte(c) - Byte('A')) + 10;
    else
      InvalidGUID;
      Result := 0;
    end;
  end;

  function HexByte(p: PChar): Byte;
  begin
    Result := Byte((HexChar(p[0]) shl 4) + HexChar(p[1]));
  end;

var
  i: Integer;
  src: PChar;
  dest: PByte;
begin
  if ((Length(S) <> 38) or (s[1] <> '{')) then InvalidGUID;
  dest := @Result;
  src := PChar(s);
  Inc(src);
  for i := 0 to 3 do
    dest[i] := HexByte(src+(3-i)*2);
  Inc(src, 8);
  Inc(dest, 4);
  if src[0] <> '-' then InvalidGUID;
  Inc(src);
  for i := 0 to 1 do
  begin
    dest^ := HexByte(src+2);
    Inc(dest);
    dest^ := HexByte(src);
    Inc(dest);
    Inc(src, 4);
    if src[0] <> '-' then InvalidGUID;
    inc(src);
  end;
  dest^ := HexByte(src);
  Inc(dest);
  Inc(src, 2);
  dest^ := HexByte(src);
  Inc(dest);
  Inc(src, 2);
  if src[0] <> '-' then InvalidGUID;
  Inc(src);
  for i := 0 to 5 do
  begin
    dest^ := HexByte(src);
    Inc(dest);
    Inc(src, 2);
  end;
end;

function GUIDToString(const Guid: TGUID): string;
begin
  SetLength(Result, 38);
  StrLFmt(PChar(Result), 38,'{%.8x-%.4x-%.4x-%.2x%.2x-%.2x%.2x%.2x%.2x%.2x%.2x}',   // do not localize
    [Guid.D1, Guid.D2, Guid.D3, Guid.D4[0], Guid.D4[1], Guid.D4[2], Guid.D4[3],
    Guid.D4[4], Guid.D4[5], Guid.D4[6], Guid.D4[7]]);
end;

function IsEqualGUID(const Guid1, Guid2: TGUID): Boolean;
var
  a, b: PIntegerArray;
begin
  a := PIntegerArray(@Guid1);
  b := PIntegerArray(@Guid2);
  Result := (a^[0] = b^[0]) and (a^[1] = b^[1]) and (a^[2] = b^[2]) and (a^[3] = b^[3]);
end;

{ TGuidHelper }

class function TGuidHelper.Create(const S: string): TGUID;
begin
  Result := StringToGUID(S);
end;

class function TGuidHelper.Create(const B: TBytes): TGUID;
begin
  if Length(B) <> 16 then
    raise EArgumentException.CreateResFmt(@SInvalidGuidArray, [16]);
  Move(B[0], Result, SizeOf(Result));
end;

class function TGuidHelper.Create(A: Integer; B, C: SmallInt; const D: TBytes): TGUID;
begin
  if Length(D) <> 16 then
    raise EArgumentException.CreateResFmt(@SInvalidGuidArray, [8]);
  Result.D1 := LongWord(A);
  Result.D2 := Word(B);
  Result.D3 := Word(C);
  Move(D[0], Result.D4, SizeOf(Result.D4));
end;

class function TGuidHelper.Create(A: Cardinal; B, C: Word; D, E, F, G, H, I, J, K: Byte): TGUID;
begin
  Result.D1 := LongWord(A);
  Result.D2 := Word(B);
  Result.D3 := Word(C);
  Result.D4[0] := D;
  Result.D4[1] := E;
  Result.D4[2] := F;
  Result.D4[3] := G;
  Result.D4[4] := H;
  Result.D4[5] := I;
  Result.D4[6] := J;
  Result.D4[7] := K;
end;

class function TGuidHelper.Create(A: Integer; B, C: SmallInt; D, E, F, G, H, I, J, K: Byte): TGUID;
begin
  Result.D1 := LongWord(A);
  Result.D2 := Word(B);
  Result.D3 := Word(C);
  Result.D4[0] := D;
  Result.D4[1] := E;
  Result.D4[2] := F;
  Result.D4[3] := G;
  Result.D4[4] := H;
  Result.D4[5] := I;
  Result.D4[6] := J;
  Result.D4[7] := K;
end;

class function TGuidHelper.NewGuid: TGUID;
begin
  if CreateGUID(Result) <> S_OK then
    RaiseLastOSError;
end;

function TGuidHelper.ToByteArray: TBytes;
begin
  SetLength(Result, 16);
  Move(D1, Result[0], SizeOf(Self));
end;

function TGuidHelper.ToString: string;
begin
  Result := GuidToString(Self);
end;

{ Exit procedure handling }

type
  PExitProcInfo = ^TExitProcInfo;
  TExitProcInfo = record
    Next: PExitProcInfo;
    SaveExit: Pointer;
    Proc: TProcedure;
  end;

var
  ExitProcList: PExitProcInfo = nil;

procedure DoExitProc;
var
  P: PExitProcInfo;
  Proc: TProcedure;
begin
  P := ExitProcList;
  ExitProcList := P^.Next;
  ExitProc := P^.SaveExit;
  Proc := P^.Proc;
  Dispose(P);
  Proc;
end;

procedure AddExitProc(Proc: TProcedure);
var
  P: PExitProcInfo;
begin
  New(P);
  P^.Next := ExitProcList;
  P^.SaveExit := ExitProc;
  P^.Proc := Proc;
  ExitProcList := P;
  ExitProc := @DoExitProc;
end;

{ String handling routines }

{ Put these (IsLeadChar, CharInSet) here so that they're compiled before being used so they're properly
  inlined }

function IsLeadChar(C: AnsiChar): Boolean;
begin
  Result := C in LeadBytes;
end;

function IsLeadChar(C: WideChar): Boolean;
begin
  Result := (C >= #$D800) and (C <= #$DFFF);
end;

function CharInSet(C: AnsiChar; const CharSet: TSysCharSet): Boolean;
begin
  Result := C in CharSet;
end;

function CharInSet(C: WideChar; const CharSet: TSysCharSet): Boolean;
begin
  Result := C in CharSet;
end;

function NewStr(const S: AnsiString): PAnsiString;
begin
  if S = '' then Result := NullAnsiStr else
  begin
    New(Result);
    Result^ := S;
  end;
end;

procedure DisposeStr(P: PAnsiString);
begin
  if (P <> nil) and (P^ <> '') then Dispose(P);
end;

procedure AssignStr(var P: PAnsiString; const S: AnsiString);
var
  Temp: PAnsiString;
begin
  Temp := P;
  P := NewStr(S);
  DisposeStr(Temp);
end;

procedure AppendStr(var Dest: AnsiString; const S: AnsiString);
begin
  Dest := Dest + S;
end;

(* ***** BEGIN LICENSE BLOCK *****
 *
 * The function UpperCase is licensed under the CodeGear license terms.
 *
 * The initial developer of the original code is Fastcode
 * Code was modified to to ensure the string payload is ansi
 *
 * Portions created by the initial developer are Copyright (C) 2002-2004
 * the initial developer. All Rights Reserved.
 *
 * Contributor(s): John O'Harrow, Allen Bauer
 *
 * ***** END LICENSE BLOCK ***** *)
function UpperCase(const S: string): string;
var
  I, Len: Integer;
  DstP, SrcP: PChar;
  Ch: Char;
begin
  Len := Length(S);
  SetLength(Result, Len);
  if Len > 0 then
  begin
    DstP := PChar(Pointer(Result));
    SrcP := PChar(Pointer(S));
    for I := Len downto 1 do
    begin
      Ch := SrcP^;
      case Ch of
        'a'..'z':
          Ch := Char(Word(Ch) xor $0020);
      end;
      DstP^ := Ch;
      Inc(DstP);
      Inc(SrcP);
    end;
  end;
end;

function UpperCase(const S: string; LocaleOptions: TLocaleOptions): string;
begin
  if LocaleOptions = loUserLocale then
    Result := AnsiUpperCase(S)
  else
    Result := UpperCase(S);
end;

(* ***** BEGIN LICENSE BLOCK *****
 *
 * The function LowerCase is licensed under the CodeGear license terms.
 *
 * The initial developer of the original code is Fastcode
 * Code was modified to to ensure the string payload is ansi
 *
 * Portions created by the initial developer are Copyright (C) 2002-2004
 * the initial developer. All Rights Reserved.
 *
 * Contributor(s): John O'Harrow, Allen Bauer
 *
 * ***** END LICENSE BLOCK ***** *)
function LowerCase(const S: string): string;
var
  I, Len: Integer;
  DstP, SrcP: PChar;
  Ch: Char;
begin
  Len := Length(S);
  SetLength(Result, Len);
  if Len > 0 then
  begin
    DstP := PChar(Pointer(Result));
    SrcP := PChar(Pointer(S));
    for I := Len downto 1 do
    begin
      Ch := SrcP^;
      case Ch of
        'A'..'Z':
          Ch := Char(Word(Ch) or $0020);
      end;
      DstP^ := Ch;
      Inc(DstP);
      Inc(SrcP);
    end;
  end;
end;

function LowerCase(const S: string; LocaleOptions: TLocaleOptions): string;
begin
  if LocaleOptions = loUserLocale then
    Result := AnsiLowerCase(S)
  else
    Result := LowerCase(S);
end;

(* ***** BEGIN LICENSE BLOCK *****
 *
 * The function CompareStr is licensed under the CodeGear license terms.
 *
 * The initial developer of the original code is Fastcode
 * Code was modified to support word-sized Unicode strings and to ensure
 * the string payload is unicode
 *
 * Portions created by the initial developer are Copyright (C) 2002-2007
 * the initial developer. All Rights Reserved.
 *
 * Contributor(s): Pierre le Riche, Allen Bauer
 *
 * ***** END LICENSE BLOCK ***** *)
function CompareStr(const S1, S2: string): Integer;
var
  I, Last, L1, L2, C1, C2, Ch1, Ch2: Integer;
begin
  L1 := Length(S1);
  L2 := Length(S2);
  result := L1 - L2;
  if (L1 > 0) and (L2 > 0) then
  begin
    if result < 0 then Last := L1 shl 1
    else Last := L2 shl 1;

    I := 0;
    while I < Last do
    begin
      C1 := PInteger(PByte(S1) + I)^;
      C2 := PInteger(PByte(S2) + I)^;
      if C1 <> C2 then
      begin
        { Compare first character }
        Ch1 := C1 and $0000FFFF;
        Ch2 := C2 and $0000FFFF;
        if Ch1 <> Ch2 then
          Exit(Ch1 - Ch2);

        { Compare second }
        Ch1 := (C1 and $FFFF0000) shr 16;
        Ch2 := (C2 and $FFFF0000) shr 16;
        if Ch1 <> Ch2 then
          Exit(Ch1 - Ch2);
      end;
      inc(I, 4);
    end;
  end;
end;

function CompareStr(const S1, S2: string; LocaleOptions: TLocaleOptions): Integer;
begin
  if LocaleOptions = loUserLocale then
    Result := AnsiCompareStr(S1, S2)
  else
    Result := CompareStr(S1, S2);
end;

function SameStr(const S1, S2: string): Boolean;
begin
  if Pointer(S1) = Pointer(S2) then
    Exit(True)
  else if (Pointer(S1) = nil) or (Pointer(S2) = nil) then
    Exit(False)
  else
    Result := CompareStr(S1, S2) = 0;
end;

function SameStr(const S1, S2: string; LocaleOptions: TLocaleOptions): Boolean;
begin
  if LocaleOptions = loUserLocale then
    Result := AnsiSameStr(S1, S2)
  else
    Result := SameStr(S1, S2);
end;

                                                                                              
(* ***** BEGIN LICENSE BLOCK *****
 *
 * The function CompareMem is licensed under the CodeGear license terms.
 *
 * The initial developer of the original code is Fastcode
 *
 * Portions created by the initial developer are Copyright (C) 2002-2004
 * the initial developer. All Rights Reserved.
 *
 * Contributor(s): Aleksandr Sharahov
 *
 * ***** END LICENSE BLOCK ***** *)
function CompareMem(P1, P2: Pointer; Length: Integer): Boolean;
var
  pb1: PByte absolute P1;
  pb2: PByte absolute P2;
begin;
  while Length > 0 do
  begin
    if pb1^ <> pb2^ then Exit(false);
    Inc(pb1); Inc(pb2); Dec(Length);
  end;
  Result := true;
end;

(* ***** BEGIN LICENSE BLOCK *****
 *
 * The function CompareText is licensed under the CodeGear license terms.
 *
 * The initial developer of the original code is Fastcode
 *
 * Portions created by the initial developer are Copyright (C) 2002-2004
 * the initial developer. All Rights Reserved.
 *
 * Contributor(s): John O'Harrow
 *
 * ***** END LICENSE BLOCK ***** *)
function CompareText(const S1, S2: string): Integer;
var
  I, Last, L1, L2, C1, C2, Ch1, Ch2: Integer;
begin
  L1 := Length(S1);
  L2 := Length(S2);
  result := L1 - L2;
  if (L1 > 0) and (L2 > 0) then
  begin
    if result < 0 then Last := L1 shl 1
    else Last := L2 shl 1;

    I := 0;
    while I < Last do
    begin
      C1 := PInteger(PByte(S1) + I)^;
      C2 := PInteger(PByte(S2) + I)^;
      if C1 <> C2 then
      begin
        { Compare first char}
        Ch1 := C1 and $0000FFFF;
        Ch2 := C2 and $0000FFFF;
        if Ch1 <> Ch2 then
        begin
          if (Ch1 >= ord('a')) and (Ch1 <= ord('z')) then
            Ch1 := Ch1 xor $20;

          if (Ch2 >= ord('a')) and (Ch2 <= ord('z')) then
            Ch2 := Ch2 xor $20;

          if Ch1 <> Ch2 then
            Exit(Ch1 - Ch2);
        end;

        { Compare second }
        Ch1 := (C1 and $FFFF0000) shr 16;
        Ch2 := (C2 and $FFFF0000) shr 16;
        if Ch1 <> Ch2 then
        begin
          if (Ch1 >= ord('a')) and (Ch1 <= ord('z')) then
            Ch1 := Ch1 xor $20;

          if (Ch2 >= ord('a')) and (Ch2 <= ord('z')) then
            Ch2 := Ch2 xor $20;

          if Ch1 <> Ch2 then
            Exit(Ch1 - Ch2);
        end;
      end;
      inc(I, 4);
    end;
  end;
end;

function CompareText(const S1, S2: string; LocaleOptions: TLocaleOptions): Integer;
begin
  if LocaleOptions = loUserLocale then
    Result := AnsiCompareText(S1, S2)
  else
    Result := CompareText(S1, S2);
end;

function SameText(const S1, S2: string): Boolean;
begin
  if Pointer(S1) = Pointer(S2) then
    Exit(True)
  else if (Pointer(S1) = nil) or (Pointer(S2) = nil) then
    Exit(False)
  else
    Result := CompareText(S1, S2) = 0;
end;

function SameText(const S1, S2: string; LocaleOptions: TLocaleOptions): Boolean;
begin
  if LocaleOptions = loUserLocale then
    Result := AnsiSameText(S1, S2)
  else
    Result := SameText(S1, S2);
end;

function AnsiUpperCase(const S: string): string;
var
  Len: Integer;
begin
  Len := Length(S);
  SetString(Result, PChar(S), Len);
  if Len > 0 then
    CharUpperBuff(PChar(Result), Len);
end;

function AnsiLowerCase(const S: string): string;
var
  Len: Integer;
begin
  Len := Length(S);
  SetString(Result, PChar(S), Len);
  if Len > 0 then
    CharLowerBuff(PChar(Result), Len);
end;

function AnsiCompareStr(const S1, S2: string): Integer;
begin
  Result := CompareString(LOCALE_USER_DEFAULT, 0, PChar(S1), Length(S1),
      PChar(S2), Length(S2)) - CSTR_EQUAL;
end;

function AnsiSameStr(const S1, S2: string): Boolean;
begin
  Result := AnsiCompareStr(S1, S2) = 0;
end;

function AnsiCompareText(const S1, S2: string): Integer;
begin
  Result := CompareString(LOCALE_USER_DEFAULT, NORM_IGNORECASE, PChar(S1),
    Length(S1), PChar(S2), Length(S2)) - CSTR_EQUAL;
end;

function AnsiSameText(const S1, S2: string): Boolean;
begin
  Result := AnsiCompareText(S1, S2) = 0;
end;

function AnsiStrComp(S1, S2: PAnsiChar): Integer;
begin
  Result := CompareStringA(LOCALE_USER_DEFAULT, 0, S1, -1, S2, -1) - CSTR_EQUAL;
end;

function AnsiStrComp(S1, S2: PWideChar): Integer;
begin
  Result := CompareStringW(LOCALE_USER_DEFAULT, 0, S1, -1, S2, -1) - CSTR_EQUAL;
end;

function AnsiStrIComp(S1, S2: PAnsiChar): Integer;
begin
  Result := CompareStringA(LOCALE_USER_DEFAULT, NORM_IGNORECASE, S1, -1,
    S2, -1) - CSTR_EQUAL;
end;

function AnsiStrIComp(S1, S2: PWideChar): Integer;
begin
  Result := CompareStringW(LOCALE_USER_DEFAULT, NORM_IGNORECASE, S1, -1,
    S2, -1) - CSTR_EQUAL;
end;

function AnsiStrLComp(S1, S2: PAnsiChar; MaxLen: Cardinal): Integer;
begin
  Result := CompareStringA(LOCALE_USER_DEFAULT, 0,
    S1, MaxLen, S2, MaxLen) - CSTR_EQUAL;
end;

function AnsiStrLComp(S1, S2: PWideChar; MaxLen: Cardinal): Integer;
begin
  Result := CompareStringW(LOCALE_USER_DEFAULT, 0,
    S1, MaxLen, S2, MaxLen) - CSTR_EQUAL;
end;

function AnsiStrLIComp(S1, S2: PAnsiChar; MaxLen: Cardinal): Integer;
begin
  Result := CompareStringA(LOCALE_USER_DEFAULT, NORM_IGNORECASE,
    S1, MaxLen, S2, MaxLen) - CSTR_EQUAL;
end;

function AnsiStrLIComp(S1, S2: PWideChar; MaxLen: Cardinal): Integer;
begin
  Result := CompareStringW(LOCALE_USER_DEFAULT, NORM_IGNORECASE,
    S1, MaxLen, S2, MaxLen) - CSTR_EQUAL;
end;

function AnsiStrLower(Str: PAnsiChar): PAnsiChar;
begin
  Result := CharLowerA(Str);
end;

function AnsiStrLower(Str: PWideChar): PWideChar;
begin
  Result := CharLowerW(Str);
end;

function AnsiStrUpper(Str: PAnsiChar): PAnsiChar;
begin
  Result := CharUpperA(Str);
end;

function AnsiStrUpper(Str: PWideChar): PWideChar;
begin
  Result := CharUpperW(Str);
end;

function WideUpperCase(const S: WideString): WideString;
var
  Len: Integer;
begin
  Len := Length(S);
  SetString(Result, PWideChar(S), Len);
  if Len > 0 then CharUpperBuffW(Pointer(Result), Len);
end;

function WideLowerCase(const S: WideString): WideString;
var
  Len: Integer;
begin
  Len := Length(S);
  SetString(Result, PWideChar(S), Len);
  if Len > 0 then CharLowerBuffW(Pointer(Result), Len);
end;

function WideCompareStr(const S1, S2: WideString): Integer;
begin
  SetLastError(0);
  Result := CompareStringW(LOCALE_USER_DEFAULT, 0, PWideChar(S1), Length(S1),
    PWideChar(S2), Length(S2)) - CSTR_EQUAL;
  if GetLastError <> 0 then
    RaiseLastOSError;
end;

function WideSameStr(const S1, S2: WideString): Boolean;
begin
  Result := WideCompareStr(S1, S2) = 0;
end;

function WideCompareText(const S1, S2: WideString): Integer;
begin
  SetLastError(0);
  Result := CompareStringW(LOCALE_USER_DEFAULT, NORM_IGNORECASE, PWideChar(S1),
    Length(S1), PWideChar(S2), Length(S2)) - CSTR_EQUAL;
  if GetLastError <> 0 then
    RaiseLastOSError;
end;

function WideSameText(const S1, S2: WideString): Boolean;
begin
  Result := WideCompareText(S1, S2) = 0;
end;

function Trim(const S: string): string;
var
  I, L: Integer;
begin
  L := Length(S);
  I := 1;
  if (L > 0) and (S[I] > ' ') and (S[L] > ' ') then Exit(S);
  while (I <= L) and (S[I] <= ' ') do Inc(I);
  if I > L then Exit('');
  while S[L] <= ' ' do Dec(L);
  Result := Copy(S, I, L - I + 1);
end;

function TrimLeft(const S: string): string;
var
  I, L: Integer;
begin
  L := Length(S);
  I := 1;
  while (I <= L) and (S[I] <= ' ') do Inc(I);
  if I = 1 then Exit(S);
  Result := Copy(S, I, Maxint);
end;

function TrimRight(const S: string): string;
var
  I: Integer;
begin
  I := Length(S);
  if (I > 0) and (S[I] > ' ') then Exit(S);
  while (I > 0) and (S[I] <= ' ') do Dec(I);
  Result := Copy(S, 1, I);
end;

function QuotedStr(const S: string): string;
var
  I: Integer;
begin
  Result := S;
  for I := Length(Result) downto 1 do
    if Result[I] = '''' then Insert('''', Result, I);
  Result := '''' + Result + '''';
end;

function AnsiQuotedStr(const S: string; Quote: Char): string;
var
  P, Src, Dest: PChar;
  AddCount: Integer;
begin
  AddCount := 0;
  P := AnsiStrScan(PChar(S), Quote);
  while P <> nil do
  begin
    Inc(P);
    Inc(AddCount);
    P := AnsiStrScan(P, Quote);
  end;
  if AddCount = 0 then
  begin
    Result := Quote + S + Quote;
    Exit;
  end;
  SetLength(Result, Length(S) + AddCount + 2);
  Dest := PChar(Result);
  Dest^ := Quote;
  Inc(Dest);
  Src := PChar(S);
  P := AnsiStrScan(Src, Quote);
  repeat
    Inc(P);
    Move(Src^, Dest^, (P - Src) * SizeOf(Char));
    Inc(Dest, P - Src);
    Dest^ := Quote;
    Inc(Dest);
    Src := P;
    P := AnsiStrScan(Src, Quote);
  until P = nil;
  P := StrEnd(Src);
  Move(Src^, Dest^, (P - Src) * SizeOf(Char));
  Inc(Dest, P - Src);
  Dest^ := Quote;
end;

function AnsiExtractQuotedStr(var Src: PAnsiChar; Quote: AnsiChar): AnsiString;
var
  P, Dest: PAnsiChar;
  DropCount: Integer;
  EndSuffix: Integer;
begin
  Result := '';
  if (Src = nil) or (Src^ <> Quote) then Exit;
  Inc(Src);
  DropCount := 1;
  P := Src;
  Src := AnsiStrScan(Src, Quote);
  while Src <> nil do   // count adjacent pairs of quote chars
  begin
    Inc(Src);
    if Src^ <> Quote then Break;
    Inc(Src);
    Inc(DropCount);
    Src := AnsiStrScan(Src, Quote);
  end;
  EndSuffix := Ord(Src = nil); // Has an ending quoatation mark?
  if Src = nil then Src := StrEnd(P);
  if ((Src - P) <= 1 - EndSuffix) or ((Src - P - DropCount) = EndSuffix) then Exit;
  if DropCount = 1 then
    SetString(Result, P, Src - P - 1 + EndSuffix)
  else
  begin
    SetLength(Result, Src - P - DropCount + EndSuffix);
    Dest := PAnsiChar(Result);
    Src := AnsiStrScan(P, Quote);
    while Src <> nil do
    begin
      Inc(Src);
      if Src^ <> Quote then Break;
      Move(P^, Dest^, Src - P);
      Inc(Dest, Src - P);
      Inc(Src);
      P := Src;
      Src := AnsiStrScan(Src, Quote);
    end;
    if Src = nil then Src := StrEnd(P);
    Move(P^, Dest^, Src - P - 1 + EndSuffix);
  end;
end;

function AnsiExtractQuotedStr(var Src: PWideChar; Quote: WideChar): UnicodeString;
var
  P, Dest: PWideChar;
  DropCount: Integer;
  EndSuffix: Integer;
begin
  Result := '';
  if (Src = nil) or (Src^ <> Quote) then Exit;
  Inc(Src);
  DropCount := 1;
  P := Src;
  Src := AnsiStrScan(Src, Quote);
  while Src <> nil do   // count adjacent pairs of quote chars
  begin
    Inc(Src);
    if Src^ <> Quote then Break;
    Inc(Src);
    Inc(DropCount);
    Src := AnsiStrScan(Src, Quote);
  end;
  EndSuffix := Ord(Src = nil); // Has an ending quoatation mark?
  if Src = nil then Src := StrEnd(P);
  if ((Src - P) <= 1 - EndSuffix) or ((Src - P - DropCount) = EndSuffix) then Exit;
  if DropCount = 1 then
    SetString(Result, P, Src - P - 1 + EndSuffix)
  else
  begin
    SetLength(Result, Src - P - DropCount + EndSuffix);
    Dest := PWideChar(Result);
    Src := AnsiStrScan(P, Quote);
    while Src <> nil do
    begin
      Inc(Src);
      if Src^ <> Quote then Break;
      Move(P^, Dest^, (Src - P) * SizeOf(Char));
      Inc(Dest, Src - P);
      Inc(Src);
      P := Src;
      Src := AnsiStrScan(Src, Quote);
    end;
    if Src = nil then Src := StrEnd(P);
    Move(P^, Dest^, (Src - P - 1 + EndSuffix) * SizeOf(Char));
  end;
end;

function AnsiDequotedStr(const S: string; AQuote: Char): string;
var
  LText: PChar;
begin
  LText := PChar(S);
  Result := AnsiExtractQuotedStr(LText, AQuote);
  if ((Result = '') or (LText^ = #0)) and
     (Length(S) > 0) and ((S[1] <> AQuote) or (S[Length(S)] <> AQuote)) then
    Result := S;
end;

function AdjustLineBreaks(const S: string; Style: TTextLineBreakStyle): string;
var
  Source, SourceEnd, Dest: PChar;
  DestLen: Integer;
begin
  Source := Pointer(S);
  SourceEnd := Source + Length(S);
  DestLen := Length(S);
  while Source < SourceEnd do
  begin
    case Source^ of
      #10:
        if Style = tlbsCRLF then
          Inc(DestLen);
      #13:
        if Style = tlbsCRLF then
          if Source[1] = #10 then
            Inc(Source)
          else
            Inc(DestLen)
        else
          if Source[1] = #10 then
            Dec(DestLen);
    end;
    Inc(Source);
  end;
  if DestLen = Length(Source) then
    Result := S
  else
  begin
    Source := Pointer(S);
    SetString(Result, nil, DestLen);
    Dest := Pointer(Result);
    while Source < SourceEnd do
      case Source^ of
        #10:
          begin
            if Style = tlbsCRLF then
            begin
              Dest^ := #13;
              Inc(Dest);
            end;
            Dest^ := #10;
            Inc(Dest);
            Inc(Source);
          end;
        #13:
          begin
            if Style = tlbsCRLF then
            begin
              Dest^ := #13;
              Inc(Dest);
            end;
            Dest^ := #10;
            Inc(Dest);
            Inc(Source);
            if Source^ = #10 then Inc(Source);
          end;
      else
        Dest^ := Source^;
        Inc(Dest);
        Inc(Source);
      end;
  end;
end;
                                                       
const
  TwoDigitLookup : packed array[0..99] of array[1..2] of Char =
    ('00','01','02','03','04','05','06','07','08','09',
     '10','11','12','13','14','15','16','17','18','19',
     '20','21','22','23','24','25','26','27','28','29',
     '30','31','32','33','34','35','36','37','38','39',
     '40','41','42','43','44','45','46','47','48','49',
     '50','51','52','53','54','55','56','57','58','59',
     '60','61','62','63','64','65','66','67','68','69',
     '70','71','72','73','74','75','76','77','78','79',
     '80','81','82','83','84','85','86','87','88','89',
     '90','91','92','93','94','95','96','97','98','99');
const
  TwoHexLookup : packed array[0..255] of array[1..2] of Char =
  ('00','01','02','03','04','05','06','07','08','09','0A','0B','0C','0D','0E','0F',
   '10','11','12','13','14','15','16','17','18','19','1A','1B','1C','1D','1E','1F',
   '20','21','22','23','24','25','26','27','28','29','2A','2B','2C','2D','2E','2F',
   '30','31','32','33','34','35','36','37','38','39','3A','3B','3C','3D','3E','3F',
   '40','41','42','43','44','45','46','47','48','49','4A','4B','4C','4D','4E','4F',
   '50','51','52','53','54','55','56','57','58','59','5A','5B','5C','5D','5E','5F',
   '60','61','62','63','64','65','66','67','68','69','6A','6B','6C','6D','6E','6F',
   '70','71','72','73','74','75','76','77','78','79','7A','7B','7C','7D','7E','7F',
   '80','81','82','83','84','85','86','87','88','89','8A','8B','8C','8D','8E','8F',
   '90','91','92','93','94','95','96','97','98','99','9A','9B','9C','9D','9E','9F',
   'A0','A1','A2','A3','A4','A5','A6','A7','A8','A9','AA','AB','AC','AD','AE','AF',
   'B0','B1','B2','B3','B4','B5','B6','B7','B8','B9','BA','BB','BC','BD','BE','BF',
   'C0','C1','C2','C3','C4','C5','C6','C7','C8','C9','CA','CB','CC','CD','CE','CF',
   'D0','D1','D2','D3','D4','D5','D6','D7','D8','D9','DA','DB','DC','DD','DE','DF',
   'E0','E1','E2','E3','E4','E5','E6','E7','E8','E9','EA','EB','EC','ED','EE','EF',
   'F0','F1','F2','F3','F4','F5','F6','F7','F8','F9','FA','FB','FC','FD','FE','FF');

function _IntToStr32(Value: Cardinal; Negative: Boolean): string;
var
  I, J, K : Cardinal;
  Digits  : Integer;
  P       : PChar;
  NewLen  : Integer;
begin
  I := Value;
  if I >= 10000 then
    if I >= 1000000 then
      if I >= 100000000 then
        Digits := 9 + Ord(I >= 1000000000)
      else
        Digits := 7 + Ord(I >= 10000000)
    else
      Digits := 5 + Ord(I >= 100000)
  else
    if I >= 100 then
      Digits := 3 + Ord(I >= 1000)
    else
      Digits := 1 + Ord(I >= 10);
  NewLen  := Digits + Ord(Negative);
  SetLength(Result, NewLen);
  P := PChar(Result);
  P^ := '-';
  Inc(P, Ord(Negative));
  if Digits > 2 then
    repeat
      J  := I div 100;           {Dividend div 100}
      K  := J * 100;
      K  := I - K;               {Dividend mod 100}
      I  := J;                   {Next Dividend}
      Dec(Digits, 2);
      PDWord(P + Digits)^ := DWord(TwoDigitLookup[K]);
    until Digits <= 2;
  if Digits = 2 then
    PDWord(P+ Digits-2)^ := DWord(TwoDigitLookup[I])
  else
    PChar(P)^ := Char(I or ord('0'));
end;

function _IntToStr64(Value: UInt64; Negative: Boolean): string;
var
  I64, J64, K64      : UInt64;
  I32, J32, K32, L32 : Cardinal;
  Digits             : Byte;
  P                  : PChar;
  NewLen             : Integer;
begin
  {Within Integer Range - Use Faster Integer Version}
  if (Negative and (Value <= High(Integer))) or
     (not Negative and (Value <= High(Cardinal))) then
    Exit(_IntToStr32(Value, Negative));

  I64 := Value;
  if I64 >= 100000000000000 then
    if I64 >= 10000000000000000 then
      if I64 >= 1000000000000000000 then
        if I64 >= 10000000000000000000 then
          Digits := 20
        else
          Digits := 19
      else
        Digits := 17 + Ord(I64 >= 100000000000000000)
    else
      Digits := 15 + Ord(I64 >= 1000000000000000)
  else
    if I64 >= 1000000000000 then
      Digits := 13 + Ord(I64 >= 10000000000000)
    else
      if I64 >= 10000000000 then
        Digits := 11 + Ord(I64 >= 100000000000)
      else
        Digits := 10;
  NewLen  := Digits + Ord(Negative);
  SetLength(Result, NewLen);
  P := PChar(Result);
  P^ := '-';
  Inc(P, Ord(Negative));
  if Digits = 20 then
  begin
    P^ := '1';
    Inc(P);
    Dec(I64, 10000000000000000000);
    Dec(Digits);
  end;
  if Digits > 17 then
  begin {18 or 19 Digits}
    if Digits = 19 then
    begin
      P^ := '0';
      while I64 >= 1000000000000000000 do
      begin
        Dec(I64, 1000000000000000000);
        Inc(P^);
      end;
      Inc(P);
    end;
    P^ := '0';
    while I64 >= 100000000000000000 do
    begin
      Dec(I64, 100000000000000000);
      Inc(P^);
    end;
    Inc(P);
    Digits := 17;
  end;
  J64 := I64 div 100000000;
  K64 := I64 - (J64 * 100000000); {Remainder = 0..99999999}
  I32 := K64;
  J32 := I32 div 100;
  K32 := J32 * 100;
  K32 := I32 - K32;
  PDWord(P + Digits - 2)^ := DWord(TwoDigitLookup[K32]);
  I32 := J32 div 100;
  L32 := I32 * 100;
  L32 := J32 - L32;
  PDWord(P + Digits - 4)^ := DWord(TwoDigitLookup[L32]);
  J32 := I32 div 100;
  K32 := J32 * 100;
  K32 := I32 - K32;
  PDWord(P + Digits - 6)^ := DWord(TwoDigitLookup[K32]);
  PDWord(P + Digits - 8)^ := DWord(TwoDigitLookup[J32]);
  Dec(Digits, 8);
  I32 := J64; {Dividend now Fits within Integer - Use Faster Version}
  if Digits > 2 then
    repeat
      J32 := I32 div 100;
      K32 := J32 * 100;
      K32 := I32 - K32;
      I32 := J32;
      Dec(Digits, 2);
      PDWord(P + Digits)^ := DWord(TwoDigitLookup[K32]);
    until Digits <= 2;
  if Digits = 2 then
    PDWord(P + Digits-2)^ := DWord(TwoDigitLookup[I32])
  else
    P^ := Char(I32 or ord('0'));
end;

function IntToStr(Value: Integer): string;
begin
  if Value < 0 then
    Result := _IntToStr32(-Value, True)
  else
    Result := _IntToStr32(Value, False);
end;

function IntToStr(Value: Int64): string;
begin
  if Value < 0 then
    Result := _IntToStr64(-Value, True)
  else
    Result := _IntToStr64(Value, False);
end;

function UIntToStr(Value: Cardinal): string;
begin
  Result := _IntToStr32(Value, False);
end;

function UIntToStr(Value: UInt64): string;
begin
  Result := _IntToStr64(Value, False);
end;

function _IntToHex(Value: UInt64; Digits: Integer): string;
var
  I32    : Integer;
  I, J   : UInt64;
  P      : PChar;
  NewLen : Integer;
begin
  NewLen := 1;
  I := Value shr 4;
  while I > 0 do
  begin
    Inc(NewLen);
    I := I shr 4;
  end;
  if Digits > NewLen then
  begin
    SetLength(Result, Digits);
    for I32 := 1 to Digits - NewLen do
      Result[I32] := '0';
    P := @Result[Digits - NewLen+1];
  end
  else
  begin
    SetLength(Result, NewLen);
    P := PChar(Result);
  end;
  I := Value;
  while NewLen > 2 do
  begin
    J := I and $FF;
    I := I shr 8;
    Dec(NewLen, 2);
    PDWord(P + NewLen)^ := DWord(TwoHexLookup[J]);
  end;
  if NewLen = 2 then
    PDWord(P)^ := DWord(TwoHexLookup[I])
  else
    PChar(P)^ := (PChar(@TwoHexLookup[I])+1)^;
end;

function IntToHex(Value: Integer; Digits: Integer): string;
begin
  Result := _IntToHex(Cardinal(Value), Digits);
end;

function IntToHex(Value: Int64; Digits: Integer): string;
begin
  Result := _IntToHex(Value, digits);
end;

function IntToHex(Value: UInt64; Digits: Integer): string;
begin
  Result := _IntToHex(Value, digits);
end;

function StrToInt(const S: string): Integer;
var
  E: Integer;
begin
  Val(S, Result, E);
  if E <> 0 then ConvertErrorFmt(@SInvalidInteger, [S]);
end;

function StrToIntDef(const S: string; Default: Integer): Integer;
var
  E: Integer;
begin
  Val(S, Result, E);
  if E <> 0 then Result := Default;
end;

function TryStrToInt(const S: string; out Value: Integer): Boolean;
var
  E: Integer;
begin
  Val(S, Value, E);
  Result := E = 0;
end;

function StrToInt64(const S: string): Int64;
var
  E: Integer;
begin
  Val(S, Result, E);
  if E <> 0 then ConvertErrorFmt(@SInvalidInteger, [S]);
end;

function StrToInt64Def(const S: string; const Default: Int64): Int64;
var
  E: Integer;
begin
  Val(S, Result, E);
  if E <> 0 then Result := Default;
end;

function TryStrToInt64(const S: string; out Value: Int64): Boolean;
var
  E: Integer;
begin
  Val(S, Value, E);
  Result := E = 0;
end;

procedure VerifyBoolStrArray;
begin
  if Length(TrueBoolStrs) = 0 then
  begin
    SetLength(TrueBoolStrs, 1);
    TrueBoolStrs[0] := DefaultTrueBoolStr;
  end;
  if Length(FalseBoolStrs) = 0 then
  begin
    SetLength(FalseBoolStrs, 1);
    FalseBoolStrs[0] := DefaultFalseBoolStr;
  end;
end;

function StrToBool(const S: string): Boolean;
begin
  if not TryStrToBool(S, Result) then
    ConvertErrorFmt(@SInvalidBoolean, [S]);
end;

function StrToBoolDef(const S: string; const Default: Boolean): Boolean;
begin
  if not TryStrToBool(S, Result) then
    Result := Default;
end;

function TryStrToBool(const S: string; out Value: Boolean): Boolean;
  function CompareWith(const aArray: array of string): Boolean;
  var
    I: Integer;
  begin
    Result := False;
    for I := Low(aArray) to High(aArray) do
      if AnsiSameText(S, aArray[I]) then
      begin
        Result := True;
        Break;
      end;
  end;
var
  LResult: Extended;
begin
  Result := TryStrToFloat(S, LResult);
  if Result then
    Value := LResult <> 0
  else
  begin
    VerifyBoolStrArray;
    Result := CompareWith(TrueBoolStrs);
    if Result then
      Value := True
    else
    begin
      Result := CompareWith(FalseBoolStrs);
      if Result then
        Value := False;
    end;
  end;
end;

function BoolToStr(B: Boolean; UseBoolStrs: Boolean = False): string;
const
  cSimpleBoolStrs: array [boolean] of String = ('0', '-1');
begin
  if UseBoolStrs then
  begin
    VerifyBoolStrArray;
    if B then
      Result := TrueBoolStrs[0]
    else
      Result := FalseBoolStrs[0];
  end
  else
    Result := cSimpleBoolStrs[B];
end;

type
  PStrData = ^TStrData;
  TStrData = record
    Ident: Integer;
    Str: string;
  end;

function EnumStringModules(Instance: HINST; Data: Pointer): Boolean;
var
  Buffer: array [0..1023] of char;
begin
  with PStrData(Data)^ do
  begin
    SetString(Str, Buffer,
      LoadString(Instance, Ident, Buffer, Length(Buffer)));
    Result := Str = '';
  end;
end;

function FindStringResource(Ident: Integer): string;
var
  StrData: TStrData;
begin
  StrData.Ident := Ident;
  StrData.Str := '';
  EnumResourceModules(EnumStringModules, @StrData);
  Result := StrData.Str;
end;

function LoadStr(Ident: Integer): string;
begin
  Result := FindStringResource(Ident);
end;

function FmtLoadStr(Ident: Integer; const Args: array of const): string;
begin
  FmtStr(Result, FindStringResource(Ident), Args);
end;

{ PChar routines }

function StrLen(const Str: PAnsiChar): Cardinal;
begin
  Result := Length(Str);
end;

function StrLen(const Str: PWideChar): Cardinal;
begin
  Result := Length(Str);
end;

function StrEnd(const Str: PAnsiChar): PAnsiChar;
begin
  Result := Str;
  while Result^ <> #0 do
    Inc(Result);
end;

function StrEnd(const Str: PWideChar): PWideChar;
begin
  Result := Str;
  while Result^ <> #0 do
    Inc(Result);
end;

function StrMove(Dest: PAnsiChar; const Source: PAnsiChar; Count: Cardinal): PAnsiChar;
begin
  Result := Dest;
  Move(Source^, Dest^, Count * SizeOf(AnsiChar));
end;

function StrMove(Dest: PWideChar; const Source: PWideChar; Count: Cardinal): PWideChar;
begin
  Result := Dest;
  Move(Source^, Dest^, Count * SizeOf(WideChar));
end;

function StrCopy(Dest: PAnsiChar; const Source: PAnsiChar): PAnsiChar;
begin
  Move(Source^, Dest^, (StrLen(Source) + 1) * SizeOf(AnsiChar));
  Result := Dest;
end;

function StrCopy(Dest: PWideChar; const Source: PWideChar): PWideChar;
begin
  Move(Source^, Dest^, (StrLen(Source) + 1) * SizeOf(WideChar));
  Result := Dest;
end;

function StrECopy(Dest: PAnsiChar; const Source: PAnsiChar): PAnsiChar;
var
  Len: Integer;
begin
  Len := StrLen(Source);
  Move(Source^, Dest^, (Len + 1) * SizeOf(AnsiChar));
  Result := Dest + Len;
end;

function StrECopy(Dest: PWideChar; const Source: PWideChar): PWideChar;
var
  Len: Integer;
begin
  Len := StrLen(Source);
  Move(Source^, Dest^, (Len + 1) * SizeOf(WideChar));
  Result := Dest + Len;
end;

function StrLCopy(Dest: PAnsiChar; const Source: PAnsiChar; MaxLen: Cardinal): PAnsiChar;
var
  Len: Cardinal;
begin
  Result := Dest;
  Len := StrLen(Source);
  if Len > MaxLen then
    Len := MaxLen;
  Move(Source^, Dest^, Len * SizeOf(AnsiChar));
  Dest[Len] := #0;
end;

function StrLCopy(Dest: PWideChar; const Source: PWideChar; MaxLen: Cardinal): PWideChar;
var
  Len: Cardinal;
begin
  Result := Dest;
  Len := StrLen(Source);
  if Len > MaxLen then
    Len := MaxLen;
  Move(Source^, Dest^, Len * SizeOf(WideChar));
  Dest[Len] := #0;
end;

function StrPCopy(Dest: PAnsiChar; const Source: AnsiString): PAnsiChar;
begin
  Result := StrLCopy(Dest, PAnsiChar(Source), Length(Source));
end;

function StrPCopy(Dest: PWideChar; const Source: UnicodeString): PWideChar;
begin
  Result := StrLCopy(Dest, PWideChar(Source), Length(Source));
end;

function StrPLCopy(Dest: PAnsiChar; const Source: AnsiString;
  MaxLen: Cardinal): PAnsiChar;
begin
  Result := StrLCopy(Dest, PAnsiChar(Source), MaxLen);
end;

function StrPLCopy(Dest: PWideChar; const Source: UnicodeString;
  MaxLen: Cardinal): PWideChar;
begin
  Result := StrLCopy(Dest, PWideChar(Source), MaxLen);
end;

function StrCat(Dest: PAnsiChar; const Source: PAnsiChar): PAnsiChar;
begin
  StrCopy(StrEnd(Dest), Source);
  Result := Dest;
end;

function StrCat(Dest: PWideChar; const Source: PWideChar): PWideChar;
begin
  StrCopy(StrEnd(Dest), Source);
  Result := Dest;
end;

function StrLCat(Dest: PAnsiChar; const Source: PAnsiChar; MaxLen: Cardinal): PAnsiChar;
var
  DestLen: Cardinal;
begin
  Result := Dest;
  DestLen := StrLen(Dest);
  if DestLen < MaxLen then
    StrLCopy(PAnsiChar(@Dest[DestLen]), Source, MaxLen - DestLen);
end;

function StrLCat(Dest: PWideChar; const Source: PWideChar; MaxLen: Cardinal): PWideChar;
var
  DestLen: Cardinal;
begin
  Result := Dest;
  DestLen := StrLen(Dest);
  if DestLen < MaxLen then
    StrLCopy(PWideChar(@Dest[DestLen]), Source, MaxLen - DestLen);
end;

function StrComp(const Str1, Str2: PAnsiChar): Integer;
var
  P1, P2: PAnsiChar;
begin
  P1 := Str1;
  P2 := Str2;
  while True do
  begin
    if (P1^ <> P2^) or (P1^ = #0) then
      Exit(Ord(P1^) - Ord(P2^));
    Inc(P1);
    Inc(P2);
  end;
end;

function StrComp(const Str1, Str2: PWideChar): Integer;
var
  P1, P2: PWideChar;
begin
  P1 := Str1;
  P2 := Str2;
  while True do
  begin
    if (P1^ <> P2^) or (P1^ = #0) then
      Exit(Ord(P1^) - Ord(P2^));
    Inc(P1);
    Inc(P2);
  end;
end;

function StrIComp(const Str1, Str2: PAnsiChar): Integer;
var
  P1, P2: PAnsiChar;
  C1, C2: AnsiChar;
begin
  P1 := Str1;
  P2 := Str2;
  while True do
  begin
    if P1^ in ['a'..'z'] then
      C1 := AnsiChar(Byte(P1^) xor $20)
    else
      C1 := P1^;

    if P2^ in ['a'..'z'] then
      C2 := AnsiChar(Byte(P2^) xor $20)
    else
      C2 := P2^;

    if (C1 <> C2) or (C1 = #0) then
      Exit(Ord(C1) - Ord(C2));
    Inc(P1);
    Inc(P2);
  end;
end;

function StrIComp(const Str1, Str2: PWideChar): Integer;
var
  P1, P2: PWideChar;
  C1, C2: WideChar;
begin
  P1 := Str1;
  P2 := Str2;
  while True do
  begin
    if P1^ in ['a'..'z'] then
      C1 := WideChar(Word(P1^) xor $20)
    else
      C1 := P1^;

    if P2^ in ['a'..'z'] then
      C2 := WideChar(Word(P2^) xor $20)
    else
      C2 := P2^;

    if (C1 <> C2) or (C1 = #0) then
      Exit(Ord(C1) - Ord(C2));
    Inc(P1);
    Inc(P2);
  end;
end;

function StrLComp(const Str1, Str2: PAnsiChar; MaxLen: Cardinal): Integer;
var
  I: Cardinal;
  P1, P2: PAnsiChar;
begin
  P1 := Str1;
  P2 := Str2;
  I := 0;
  while I < MaxLen do
  begin
    if (P1^ <> P2^) or (P1^ = #0) then
      Exit(Ord(P1^) - Ord(P2^));

    Inc(P1);
    Inc(P2);
    Inc(I);
  end;
  Result := 0;
end;

function StrLComp(const Str1, Str2: PWideChar; MaxLen: Cardinal): Integer;
var
  I: Cardinal;
  P1, P2: PWideChar;
begin
  P1 := Str1;
  P2 := Str2;
  I := 0;
  while I < MaxLen do
  begin
    if (P1^ <> P2^) or (P1^ = #0) then
      Exit(Ord(P1^) - Ord(P2^));

    Inc(P1);
    Inc(P2);
    Inc(I);
  end;
  Result := 0;
end;

function StrLIComp(const Str1, Str2: PAnsiChar; MaxLen: Cardinal): Integer;
var
  P1, P2: PAnsiChar;
  I: Cardinal;
  C1, C2: AnsiChar;
begin
  P1 := Str1;
  P2 := Str2;
  I := 0;
  while I < MaxLen do
  begin
    if P1^ in ['a'..'z'] then
      C1 := AnsiChar(Byte(P1^) xor $20)
    else
      C1 := P1^;

    if P2^ in ['a'..'z'] then
      C2 := AnsiChar(Byte(P2^) xor $20)
    else
      C2 := P2^;

    if (C1 <> C2) or (C1 = #0) then
      Exit(Ord(C1) - Ord(C2));

    Inc(P1);
    Inc(P2);
    Inc(I);
  end;
  Result := 0;
end;

function StrLIComp(const Str1, Str2: PWideChar; MaxLen: Cardinal): Integer;
var
  P1, P2: PWideChar;
  I: Cardinal;
  C1, C2: WideChar;
begin
  P1 := Str1;
  P2 := Str2;
  I := 0;
  while I < MaxLen do
  begin
    if P1^ in ['a'..'z'] then
      C1 := WideChar(Word(P1^) xor $20)
    else
      C1 := P1^;

    if P2^ in ['a'..'z'] then
      C2 := WideChar(Word(P2^) xor $20)
    else
      C2 := P2^;

    if (C1 <> C2) or (C1 = #0) then
      Exit(Ord(C1) - Ord(C2));

    Inc(P1);
    Inc(P2);
    Inc(I);
  end;
  Result := 0;
end;

function StrScan(const Str: PAnsiChar; Chr: AnsiChar): PAnsiChar;
begin
  Result := Str;
  while Result^ <> #0 do
  begin
    if Result^ = Chr then
      Exit;
    Inc(Result);
  end;
  if Chr <> #0 then
    Result := nil;
end;

function StrScan(const Str: PWideChar; Chr: WideChar): PWideChar;
begin
  Result := Str;
  while Result^ <> #0 do
  begin
    if Result^ = Chr then
      Exit;
    Inc(Result);
  end;
  if Chr <> #0 then
    Result := nil;
end;

function StrRScan(const Str: PAnsiChar; Chr: AnsiChar): PAnsiChar;
var
  MostRecentFound: PAnsiChar;
begin
  if Chr = AnsiChar(#0) then
    Result := StrEnd(Str)
  else
  begin
    Result := nil;

    MostRecentFound := Str;
    while True do
    begin
      while MostRecentFound^ <> Chr do
      begin
        if MostRecentFound^ = AnsiChar(#0) then
          Exit;
        Inc(MostRecentFound);
      end;
      Result := MostRecentFound;
      Inc(MostRecentFound);
    end;
  end;
end;

function StrRScan(const Str: PWideChar; Chr: WideChar): PWideChar;
var
  MostRecentFound: PWideChar;
begin
  if Chr = #0 then
    Result := StrEnd(Str)
  else
  begin
    Result := nil;

    MostRecentFound := Str;
    while True do
    begin
      while MostRecentFound^ <> Chr do
      begin
        if MostRecentFound^ = #0 then
          Exit;
        Inc(MostRecentFound);
      end;
      Result := MostRecentFound;
      Inc(MostRecentFound);
    end;
  end;
end;

function StrPos(const Str1, Str2: PAnsiChar): PAnsiChar;
var
  P, LStr1, LStr2: PAnsiChar;
begin
  Result := nil;
  if (Str1^ = #0) or (Str2^ = #0) then
    Exit;

  LStr1 := Str1;
  while LStr1^ <> #0 do
  begin
    if LStr1^ = Str2^ then
    begin
      P := LStr1;
      LStr2 := Str2;
      while LStr2^ <> #0 do
      begin
        if (LStr1^ <> LStr2^) or (LStr1^ = #0) then
          Break;
        Inc(LStr1);
        Inc(LStr2);
      end;
      if LStr2^ = #0 then
        Exit(P);
    end;
    Inc(LStr1);
  end;
end;

function StrPos(const Str1, Str2: PWideChar): PWideChar;
var
  MatchStart, LStr1, LStr2: PWideChar;
begin
  Result := nil;
  if (Str1^ = #0) or (Str2^ = #0) then
    Exit;

  MatchStart := Str1;
  while MatchStart^<> #0 do
  begin
    if MatchStart^ = Str2^ then
    begin
      LStr1 := MatchStart+1;
      LStr2 := Str2+1;
      while True do
      begin
        if LStr2^ = #0 then
          Exit(MatchStart);
        if (LStr1^ <> LStr2^) or (LStr1^ = #0) then
          Break;
        Inc(LStr1);
        Inc(LStr2);
      end;
    end;
    Inc(MatchStart);
  end;
end;

function StrPosLen(const Str1, Str2: PWideChar; Len1, Len2: Integer): PWideChar;
var
  I: Integer;
begin
  Result := nil;
  if Len1 = 0 then
    Exit;
  if Len2 = 0 then
    Exit;
  for I := 0 to Len1 - Len2 do
  begin
    if (Str1[I] <> #0) and (StrLComp(PWideChar(PByte(Str1) + I * SizeOf(WideChar)), Str2, Len2) = 0) then
    begin
      Result := PWideChar(PByte(Str1) + I * SizeOf(WideChar));
      Exit;
    end;
  end;
end;

function StrUpper(Str: PAnsiChar): PAnsiChar;
begin
  Result := Str;
  while Str^ <> #0 do
  begin
    if Str^ in ['a'..'z'] then
      Dec(Str^, $20);
    Inc(Str);
  end;
end;

function StrUpper(Str: PWideChar): PWideChar;
begin
  Result := Str;
  while Str^ <> #0 do
  begin
    if Str^ in ['a'..'z'] then
      Dec(Str^, $20);
    Inc(Str);
  end;
end;

function StrLower(Str: PAnsiChar): PAnsiChar;
begin
  Result := Str;
  while Str^ <> #0 do
  begin
    if Str^ in ['A'..'Z'] then
      Inc(Str^, $20);
    Inc(Str);
  end;
end;

function StrLower(Str: PWideChar): PWideChar;
begin
  Result := Str;
  while Str^ <> #0 do
  begin
    if Str^ in ['A'..'Z'] then
      Inc(Str^, $20);
    Inc(Str);
  end;
end;

function StrPas(const Str: PAnsiChar): AnsiString;
begin
  Result := Str;
end;

function StrPas(const Str: PWideChar): UnicodeString;
begin
  Result := Str;
end;

function AnsiStrAlloc(Size: Cardinal): PAnsiChar;
begin
  Inc(Size, SizeOf(Cardinal));
  GetMem(Result, Size);
  Cardinal(Pointer(Result)^) := Size;
  Inc(Result, SizeOf(Cardinal));
end;

function WideStrAlloc(Size: Cardinal): PWideChar;
begin
  //BJK: Size should probably be char count, not bytes; but at least 'div 2' below prevents overrun.
  Size := Size * SizeOf(WideChar);
  Inc(Size, SizeOf(Cardinal));
  GetMem(Result, Size);
  Cardinal(Pointer(Result)^) := Size;
  Inc(Result, SizeOf(Cardinal) div 2);
end;

function StrAlloc(Size: Cardinal): PChar;
begin
  Result := WideStrAlloc(Size);
end;

function StrBufSize(const Str: PAnsiChar): Cardinal;
var
  P: PAnsiChar;
begin
  P := Str;
  Dec(P, SizeOf(Cardinal));
  Result := Cardinal(Pointer(P)^) - SizeOf(Cardinal);
end;

function StrBufSize(const Str: PWideChar): Cardinal;
var
  P: PWideChar;
begin
  P := Str;
  Dec(P, SizeOf(Cardinal) div 2);
  Result := (Cardinal(Pointer(P)^) - SizeOf(Cardinal)) div SizeOf(WideChar);
end;

function StrNew(const Str: PAnsiChar): PAnsiChar;
var
  Size: Cardinal;
begin
  if Str = nil then Result := nil else
  begin
    Size := StrLen(Str) + 1;
    Result := StrMove(AnsiStrAlloc(Size), Str, Size);
  end;
end;

function StrNew(const Str: PWideChar): PWideChar;
var
  Size: Cardinal;
begin
  if Str = nil then Result := nil else
  begin
    Size := StrLen(Str) + 1;
    Result := StrMove(WideStrAlloc(Size), Str, Size);
  end;
end;

procedure StrDispose(Str: PAnsiChar);
begin
  if Str <> nil then
  begin
    Dec(Str, SizeOf(Cardinal));
    FreeMem(Str, Cardinal(Pointer(Str)^));
  end;
end;

procedure StrDispose(Str: PWideChar);
begin
  if Str <> nil then
  begin
    Dec(Str, SizeOf(Cardinal) div 2);
    FreeMem(Str, Cardinal(Pointer(Str)^));
  end;
end;

{ String formatting routines }

procedure FormatError(ErrorCode: Integer; Format: PChar; FmtLen: Cardinal);
const
  FormatErrorStrs: array[0..1] of PResStringRec = (
    @SInvalidFormat, @SArgumentMissing);
var
  Buffer: array[0..31] of Char;
begin
  if FmtLen > 31 then FmtLen := 31;
                                                                            
  if StrByteType(Format, FmtLen-1) = mbLeadByte then Dec(FmtLen);
  StrMove(Buffer, Format, FmtLen);
  Buffer[FmtLen] := #0;
  ConvertErrorFmt(FormatErrorStrs[ErrorCode], [PChar(@Buffer)]);
end;

procedure WideFormatError(ErrorCode: Integer; Format: PWideChar;
  FmtLen: Cardinal);
var
  WideFormat: WideString;
  FormatText: string;
begin
  SetLength(WideFormat, FmtLen);
  SetString(WideFormat, Format, FmtLen);
  FormatText := WideFormat;
  FormatError(ErrorCode, PChar(FormatText), FmtLen);
end;

procedure AnsiFormatError(ErrorCode: Integer; Format: PAnsiChar;
  FmtLen: Cardinal);
var
  FormatText: string;
begin
  FormatText := UTF8ToUnicodeString(Format);
  FormatError(ErrorCode, PChar(FormatText), FmtLen);
end;

procedure FormatVarToStr(var S: AnsiString; const V: TVarData);
begin
  if Assigned(System.VarToLStrProc) then
    System.VarToLStrProc(S, V)
  else
    System.Error(reVarInvalidOp);
end;

procedure FormatClearStr(var S: AnsiString);
begin
  S := '';
end;

function FormatBuf(var Buffer; BufLen: Cardinal; const Format;
  FmtLen: Cardinal; const Args: array of const): Cardinal;
begin
  Result := FormatBuf(Buffer, BufLen, Format, FmtLen, Args, FormatSettings);
end;

function FormatBuf(Buffer: PWideChar; BufLen: Cardinal; const Format;
  FmtLen: Cardinal; const Args: array of const): Cardinal;
begin
  Result := FormatBuf(Buffer, BufLen, Format, FmtLen, Args, FormatSettings);
end;

function FormatBuf(Buffer: PWideChar; BufLen: Cardinal; const Format;
  FmtLen: Cardinal; const Args: array of const;
  const AFormatSettings: TFormatSettings): Cardinal;
begin
  Result := WideFormatBuf(Buffer^, BufLen, Format, FmtLen, Args, AFormatSettings);
end;

function FormatBuf(var Buffer: UnicodeString; BufLen: Cardinal; const Format;
  FmtLen: Cardinal; const Args: array of const): Cardinal;
begin
  Result := FormatBuf(Buffer, BufLen, Format, FmtLen, Args, FormatSettings);
end;

function FormatBuf(var Buffer: UnicodeString; BufLen: Cardinal; const Format;
  FmtLen: Cardinal; const Args: array of const;
  const AFormatSettings: TFormatSettings): Cardinal;
begin
  Result := WideFormatBuf(Buffer, BufLen, Format, FmtLen, Args, AFormatSettings);
end;

function StrFmt(Buffer, Format: PAnsiChar; const Args: array of const): PAnsiChar;
begin
  Result := StrFmt(Buffer, Format, Args, FormatSettings);
end;

function StrFmt(Buffer, Format: PWideChar; const Args: array of const): PWideChar;
begin
  Result := StrFmt(Buffer, Format, Args, FormatSettings);
end;

function StrFmt(Buffer, Format: PAnsiChar; const Args: array of const;
  const AFormatSettings: TFormatSettings): PAnsiChar;
begin
  if (Buffer <> nil) and (Format <> nil) then
  begin
    Buffer[FormatBuf(Buffer^, MaxInt, Format^, StrLen(Format), Args,
      AFormatSettings)] := AnsiChar(#0);
    Result := Buffer;
  end
  else
    Result := nil;
end;

function StrFmt(Buffer, Format: PWideChar; const Args: array of const;
  const AFormatSettings: TFormatSettings): PWideChar;
begin
  if (Buffer <> nil) and (Format <> nil) then
  begin
    Buffer[WideFormatBuf(Buffer^, MaxInt, Format^, StrLen(Format), Args,
      AFormatSettings)] := #0;
    Result := Buffer;
  end
  else
    Result := nil;
end;

function StrLFmt(Buffer: PAnsiChar; MaxBufLen: Cardinal; Format: PAnsiChar;
  const Args: array of const): PAnsiChar;
begin
  Result := StrLFmt(Buffer, MaxBufLen, Format, Args, FormatSettings);
end;

function StrLFmt(Buffer: PWideChar; MaxBufLen: Cardinal; Format: PWideChar;
  const Args: array of const): PWideChar;
begin
  Result := StrLFmt(Buffer, MaxBufLen, Format, Args, FormatSettings);
end;

function StrLFmt(Buffer: PAnsiChar; MaxBufLen: Cardinal; Format: PAnsiChar;
  const Args: array of const; const AFormatSettings: TFormatSettings): PAnsiChar;
begin
  if (Buffer <> nil) and (Format <> nil) then
  begin
    Buffer[FormatBuf(Buffer^, MaxBufLen, Format^, StrLen(Format), Args,
      AFormatSettings)] := AnsiChar(#0);
    Result := Buffer;
  end
  else
    Result := nil;
end;

function StrLFmt(Buffer: PWideChar; MaxBufLen: Cardinal; Format: PWideChar;
  const Args: array of const;
  const AFormatSettings: TFormatSettings): PWideChar;
begin
  if (Buffer <> nil) and (Format <> nil) then
  begin
    Buffer[WideFormatBuf(Buffer^, MaxBufLen, Format^, StrLen(Format), Args,
      AFormatSettings)] := #0;
    Result := Buffer;
  end
  else
    Result := nil;
end;

function Format(const Format: string; const Args: array of const): string;
begin
  Result := sdaSysUtils.Format(Format, Args, FormatSettings);
end;

function Format(const Format: string; const Args: array of const;
  const AFormatSettings: TFormatSettings): string;
begin
  FmtStr(Result, Format, Args, AFormatSettings);
end;

procedure FmtStr(var Result: string; const Format: string;
  const Args: array of const);
begin
  FmtStr(Result, Format, Args, FormatSettings);
end;

procedure FmtStr(var Result: string; const Format: string;
  const Args: array of const; const AFormatSettings: TFormatSettings);
var
  Len, BufLen: Integer;
  Buffer: array[0..4095] of Char;
begin
  BufLen := Length(Buffer);
  if Length(Format) < (Length(Buffer) - (Length(Buffer) div 4)) then
    Len := FormatBuf(Buffer, Length(Buffer) - 1, Pointer(Format)^, Length(Format),
      Args, AFormatSettings)
  else
  begin
    BufLen := Length(Format);
    Len := BufLen;
  end;
  if Len >= BufLen - 1 then
  begin
    while Len >= BufLen - 1 do
    begin
      Inc(BufLen, BufLen);
      Result := '';          // prevent copying of existing data, for speed
      SetLength(Result, BufLen);
{$IFDEF UNICODE}
      Len := FormatBuf(PChar(Result), BufLen - 1, Pointer(Format)^,
        Length(Format), Args, AFormatSettings);
{$ELSE}
      Len := FormatBuf(Pointer(Result)^, BufLen - 1, Pointer(Format)^,
        Length(Format), Args, AFormatSettings);
{$ENDIF}
    end;
    SetLength(Result, Len);
  end
  else
    SetString(Result, Buffer, Len);
end;

procedure WideFormatVarToStr(var S: WideString; const V: TVarData);
begin
  if Assigned(System.VarToWStrProc) then
    System.VarToWStrProc(S, V)
  else
    System.Error(reVarInvalidOp);
end;

function WideFloatToText(BufferArg: PWideChar; const Value; ValueType: TFloatValue;
  Format: TFloatFormat; Precision, Digits: Integer): Integer;
begin
  Result := FloatToText(BufferArg, Value, ValueType, Format, Precision, Digits);
end;

function FloatToTextEx(BufferArg: PChar; const Value; ValueType: TFloatValue;
  Format: TFloatFormat; Precision, Digits: Integer;
  const AFormatSettings: TFormatSettings): Integer;
begin
  Result := FloatToText(BufferArg, Value, ValueType, Format, Precision, Digits,
    AFormatSettings);
end;

function AnsiFloatToTextEx(BufferArg: PAnsiChar; const Value; ValueType: TFloatValue;
  Format: TFloatFormat; Precision, Digits: Integer;
  const AFormatSettings: TFormatSettings): Integer;
begin
  Result := FloatToText(BufferArg, Value, ValueType, Format, Precision, Digits,
    AFormatSettings);
end;

function WideFormatBuf(var Buffer; BufLen: Cardinal; const Format;
  FmtLen: Cardinal; const Args: array of const): Cardinal;
begin
  Result := WideFormatBuf(Buffer, BufLen, Format, FmtLen, Args, FormatSettings);
end;

function WideFormatBuf(var Buffer; BufLen: Cardinal; const Format;
  FmtLen: Cardinal; const Args: array of const;
  const AFormatSettings: TFormatSettings): Cardinal;
var
  BufPtr: PChar;
  FormatPtr: PChar;
  FormatStartPtr: PChar;
  FormatEndPtr: PChar;
  ArgsIndex: Integer;
  ArgsLength: Integer;
  BufMaxLen: Cardinal;
  Overwrite: Boolean;
  FormatChar: Char;
  S: string;
  StrBuf: array[0..64] of Char;
  LeftJustification: Boolean;
  Width: Integer;
  Precision: Integer;
  Len: Integer;
  FirstNumber: Integer;
  CurrentArg: TVarRec;
  FloatVal: TFloatValue;

  function ApplyWidth(NumChar, Negitive: Integer): Boolean;
  var
    I: Integer;
    Max: Integer;
  begin
    Result := False;
    if (Precision > NumChar) and (FormatChar <> 'S') then
      Max := Precision
    else
      Max := NumChar;
    if (Width <> -1) and (Width > Max + Negitive) then
    begin
      for I := Max + 1  + Negitive to Width do
      begin
        if BufMaxLen = 0 then
        begin
          Result := True;
          Break;
        end;
        BufPtr^ := ' ';
        Inc(BufPtr);
        Dec(BufMaxLen, Sizeof(Char));
      end;
    end;
  end;

  function AddBuf(const AItem: PChar; ItemLen: Integer = -1): Boolean;
  var
    NumChar: Integer;
    Len: Integer;
    I: Integer;
    Item: PChar;
    Negitive: Integer;
    BytesToCopy: Cardinal;
  begin
    Item := AItem;
    if Assigned(AItem) then
      NumChar := StrLen(Item)
    else
      NumChar := 0;
    if (ItemLen > -1) and (NumChar > ItemLen) then
      NumChar := ItemLen;
    Len := NumChar * Sizeof(Char);
    if (Assigned(AItem)) and (Item^ = '-') and (FormatChar <> 'S') then
    begin
      Dec(Len, Sizeof(Char));
      Dec(NumChar);
      Negitive := 1;
    end
    else
      Negitive := 0;
    if not LeftJustification then
    begin
      Result := ApplyWidth(NumChar, Negitive);
      if Result then
        Exit;
    end;
    if Negitive = 1 then
    begin
      if BufMaxLen = 0 then
      begin
        Result := True;
        Exit;
      end;
      Inc(Item);
      BufPtr^ := '-';
      Inc(BufPtr);
      Dec(BufMaxLen, Sizeof(Char));
    end;
    if (Precision <> -1) and (Precision > NumChar) and (FormatChar <> 'S') then
      for I := NumChar + 1 to Precision do
      begin
        if BufMaxLen = 0 then
        begin
          Result := True;
          Exit;
        end;
        BufPtr^ := '0';
        Inc(BufPtr);
        Dec(BufMaxLen, Sizeof(Char));
      end;
    if Assigned(AItem) then
    begin
      Result := BufMaxLen < Cardinal(Len);
      if Result then
        BytesToCopy := BufMaxLen
      else
        BytesToCopy := Len;
      Move(Item^, BufPtr^, BytesToCopy);
      BufPtr := PChar(PByte(BufPtr) + BytesToCopy);
      Dec(BufMaxLen, BytesToCopy);
    end
    else
      Result := False;
    if LeftJustification then
      Result := ApplyWidth(NumChar, Negitive);
  end;

begin
  if (not Assigned(@Buffer)) or  (not Assigned(@Format)) then
  begin
    Result := 0;
    Exit;
  end;
  ArgsIndex := -1;
  ArgsLength := Length(Args);
  BufPtr := PChar(@Buffer);
  FormatPtr := PChar(@Format);
  if BufLen < $7FFFFFFF then
    BufMaxLen := BufLen * Sizeof(Char)
  else
    BufMaxLen := BufLen;
  FormatEndPtr := FormatPtr + FmtLen;
  while FormatPtr < FormatEndPtr do
    if FormatPtr^ = '%' then
    begin
      Inc(FormatPtr);
      if FormatPtr >= FormatEndPtr then
        Break;
      if FormatPtr^ = '%' then
      begin
        if BufMaxLen = 0 then
          FormatError(0, PChar(@Format), FmtLen);
        BufPtr^ := FormatPtr^;
        Inc(FormatPtr);
        Inc(BufPtr);
        Dec(BufMaxLen, Sizeof(Char));
        Continue;
      end;
      Width := -1;
      // Gather Index
      Inc(ArgsIndex);
      if TCharacter.IsNumber(FormatPtr^) then
      begin
        FormatStartPtr := FormatPtr;
        while (FormatPtr < FormatEndPtr) and (TCharacter.IsNumber(FormatPtr^)) do
          Inc(FormatPtr);
        if FormatStartPtr <> FormatPtr then
        begin
          StrLCopy(StrBuf, FormatStartPtr, Integer(FormatPtr - FormatStartPtr));
          if not TryStrToInt(StrBuf, FirstNumber) then
            FormatError(0, PChar(@Format), FmtLen);
          if FormatPtr^ = ':' then
          begin
            Inc(FormatPtr);
            ArgsIndex := FirstNumber;
          end
          else
            Width := FirstNumber;
        end;
      end
      else if FormatPtr^ = ':' then
      begin
        ArgsIndex := 0;
        Inc(FormatPtr);
      end;
      // Gather Justification
      if FormatPtr^ = '-' then
      begin
        LeftJustification := True;
        Inc(FormatPtr);
      end
      else
        LeftJustification := False;
      // Gather Width
      FormatStartPtr := FormatPtr;
      if FormatPtr^ = '*' then
      begin
        Width := -2;
        Inc(FormatPtr);
      end
      else if TCharacter.IsNumber(FormatPtr^) then
      begin
        while (FormatPtr < FormatEndPtr) and (TCharacter.IsNumber(FormatPtr^)) do
          Inc(FormatPtr);
        if FormatStartPtr <> FormatPtr then
        begin
          StrLCopy(StrBuf, FormatStartPtr, Integer(FormatPtr - FormatStartPtr));
          if not TryStrToInt(StrBuf, Width) then
            FormatError(0, PChar(@Format), FmtLen);
        end
      end;
      // Gather Precision
      if FormatPtr^ = '.' then
      begin
        Inc(FormatPtr);
        if (FormatPtr >= FormatEndPtr) then
          Break;
        if FormatPtr^ = '*' then
        begin
          Precision := -2;
          Inc(FormatPtr);
        end
        else
        begin
          FormatStartPtr := FormatPtr;
          while (FormatPtr < FormatEndPtr) and (TCharacter.IsNumber(FormatPtr^)) do
            Inc(FormatPtr);
          StrLCopy(StrBuf, FormatStartPtr, Integer(FormatPtr - FormatStartPtr));
          if not TryStrToInt(StrBuf, Precision) then
            Precision := -1;
        end;
      end
      else
        Precision := -1;

      // Gather Conversion Character
      if not TCharacter.IsLetter(FormatPtr^) then
        Break;
      case FormatPtr^ of
        'a'..'z':
          FormatChar := Char(Word(FormatPtr^) xor $0020);
      else
        FormatChar := FormatPtr^;
      end;
      Inc(FormatPtr);

      // Handle Args
      if Width = -2 then // If * width was found
      begin
        if ArgsIndex >= ArgsLength then
          FormatError(1, PChar(@Format), FmtLen);
        if Args[ArgsIndex].VType = vtInteger then
        begin
          if ArgsIndex >= ArgsLength then
            FormatError(1, PChar(@Format), FmtLen);
          Width := Args[ArgsIndex].VInteger;
          if Width < 0 then
          begin
            LeftJustification := not LeftJustification;
            Width := -Width;
          end;
          Inc(ArgsIndex);
        end
        else
          FormatError(0, PChar(@Format), FmtLen);
      end;
      if Precision = -2 then
      begin
        if ArgsIndex >= ArgsLength then
          FormatError(1, PChar(@Format), FmtLen);
        if Args[ArgsIndex].VType = vtInteger then
        begin
          if ArgsIndex >= ArgsLength then
            FormatError(1, PChar(@Format), FmtLen);
          Precision := Args[ArgsIndex].VInteger;
          Inc(ArgsIndex);
        end
        else
          FormatError(0, PChar(@Format), FmtLen);
      end;

      if ArgsIndex >= ArgsLength then
        FormatError(1, PChar(@Format), FmtLen);
      CurrentArg := Args[ArgsIndex];

      Overwrite := False;
      case CurrentArg.VType of
        vtBoolean,
        vtObject,
        vtClass,
        vtInterface: FormatError(0, PChar(@Format), FmtLen);
        vtInteger:
          begin
            if (Precision > 16) or (Precision = -1) then
              Precision := 0;
            case FormatChar of
              'D': S := IntToStr(CurrentArg.VInteger);
              'U': S := UIntToStr(Cardinal(CurrentArg.VInteger));
              'X': S := IntToHex(CurrentArg.VInteger, 0);
            else
              FormatError(0, PChar(@Format), FmtLen);
            end;
            Overwrite := AddBuf(PChar(S));
          end;
        vtWideChar,
        vtChar:
          if FormatChar = 'S' then
          begin
              if CurrentArg.VType = vtChar then
                S := Char(CurrentArg.VChar)
              else
                S := Char(CurrentArg.VWideChar);
            Overwrite := AddBuf(PChar(S), Precision);
          end
          else
            FormatError(0, PChar(@Format), FmtLen);
        vtExtended, vtCurrency:
          begin
            if CurrentArg.VType = vtExtended then
              FloatVal := fvExtended
            else
              FloatVal := fvCurrency;
            Len := 0;
            if (FormatChar = 'G') or (FormatChar = 'E') then
            begin
              if Cardinal(Precision) > 18 then
                Precision := 15;
            end
            else if Cardinal(Precision) > 18 then
            begin
              Precision := 2;
              if FormatChar = 'M' then
                Precision := AFormatSettings.CurrencyDecimals;
            end;
            case FormatChar of
              'G': Len := FloatToText(StrBuf, CurrentArg.VExtended^, FloatVal, ffGeneral, Precision, 3, AFormatSettings);
              'E': Len := FloatToText(StrBuf, CurrentArg.VExtended^, FloatVal, ffExponent, Precision, 3, AFormatSettings);
              'F': Len := FloatToText(StrBuf, CurrentArg.VExtended^, FloatVal, ffFixed, 18, Precision, AFormatSettings);
              'N': Len := FloatToText(StrBuf, CurrentArg.VExtended^, FloatVal, ffNumber, 18, Precision, AFormatSettings);
              'M': Len := FloatToText(StrBuf, CurrentArg.VExtended^, FloatVal, ffCurrency, 18, Precision, AFormatSettings);
            else
              FormatError(0, PChar(@Format), FmtLen);
            end;
            StrBuf[Len] := #0;
            Precision := 0;
            Overwrite := AddBuf(StrBuf);
          end;
        vtString:
          if FormatChar = 'S' then
            Overwrite := AddBuf(PChar(UnicodeString(PShortString(CurrentArg.VAnsiString)^)), Precision)
          else
            FormatError(0, PChar(@Format), FmtLen);
        vtPointer:
          if FormatChar = 'P' then
          begin
            S := IntToHex(NativeInt(CurrentArg.VPointer), SizeOf(Pointer)*2);
            Overwrite := AddBuf(PChar(S));
          end
          else
            FormatError(0, PChar(@Format), FmtLen);
        vtPChar:
          if FormatChar = 'S' then
            Overwrite := AddBuf(PChar(UnicodeString(CurrentArg.VPChar)), Precision)
          else
            FormatError(0, PChar(@Format), FmtLen);
        vtPWideChar:
          if FormatChar = 'S' then
            Overwrite := AddBuf(CurrentArg.VPWideChar, Precision)
          else
            FormatError(0, PChar(@Format), FmtLen);
        vtAnsiString:
          if FormatChar = 'S' then
            Overwrite := AddBuf(PChar(UnicodeString(AnsiString(CurrentArg.VAnsiString))), Precision)
          else
            FormatError(0, PChar(@Format), FmtLen);
        vtVariant:
          if FormatChar = 'S' then
            case TVarData(CurrentArg.VVariant^).VType of
              varString:
                Overwrite := AddBuf(PChar(string(PAnsiChar(TVarData(CurrentArg.VVariant^).VString))), Precision);
              varOleStr:
                Overwrite := AddBuf(PChar(TVarData(CurrentArg.VVariant^).VOleStr), Precision);
              varUString:
                Overwrite := AddBuf(PChar(TVarData(CurrentArg.VVariant^).VUString), Precision);
            else
              FormatError(0, PChar(@Format), FmtLen);
            end
          else
            FormatError(0, PChar(@Format), FmtLen);
        vtWideString:
          if FormatChar = 'S' then
            Overwrite := AddBuf(CurrentArg.VWideString, Precision)
          else
            FormatError(0, PChar(@Format), FmtLen);
        vtInt64:
          begin
            if (Precision > 32) or (Precision = -1)  then
              Precision := 0;
            case FormatChar of
              'D': S := IntToStr(CurrentArg.VInt64^);
              'U': S := UIntToStr(UInt64(CurrentArg.VInt64^));
              'X': S := IntToHex(CurrentArg.VInt64^, 0);
            else
              FormatError(0, PChar(@Format), FmtLen);
            end;
            Overwrite := AddBuf(PChar(S));
          end;
        vtUnicodeString:
          if FormatChar = 'S' then
            Overwrite := AddBuf(CurrentArg.VUnicodeString, Precision)
          else
            FormatError(0, PChar(@Format), FmtLen);
      end;
      if Overwrite then
      begin
        Result := BufPtr - PChar(@Buffer);
        Exit;
      end;
    end
    else
    begin
      if BufMaxLen = 0 then
      begin
        Result := BufPtr - PChar(@Buffer);
        Exit;
      end;
      BufPtr^ := FormatPtr^;
      Inc(FormatPtr);
      Inc(BufPtr);
      Dec(BufMaxLen, Sizeof(Char));
    end;
  Result := BufPtr - PChar(@Buffer);
end;

function FormatBuf(var Buffer; BufLen: Cardinal; const Format;
  FmtLen: Cardinal; const Args: array of const;
  const AFormatSettings: TFormatSettings): Cardinal;
var
  BufPtr: PAnsiChar;
  FormatPtr: PAnsiChar;
  FormatStartPtr: PAnsiChar;
  FormatEndPtr: PAnsiChar;
  ArgsIndex: Integer;
  ArgsLength: Integer;
  BufMaxLen: Cardinal;
  Overwrite: Boolean;
  FormatChar: AnsiChar;
  S: AnsiString;
  StrBuf: array[0..64] of AnsiChar;
  LeftJustification: Boolean;
  Width: Integer;
  Precision: Integer;
  Len: Integer;
  FirstNumber: Integer;
  CurrentArg: TVarRec;
  FloatVal: TFloatValue;

  function ApplyWidth(NumChar, Negitive: Integer): Boolean;
  var
    I: Integer;
    Max: Integer;
  begin
    Result := False;
    if (Precision > NumChar) and (FormatChar <> 'S') then
      Max := Precision
    else
      Max := NumChar;
    if (Width <> 0) and (Width > Max + Negitive) then
    begin
      for I := Max + 1  + Negitive to Width do
      begin
        if BufMaxLen = 0 then
        begin
          Result := True;
          Break;
        end;
        BufPtr^ := ' ';
        Inc(BufPtr);
        Dec(BufMaxLen, Sizeof(AnsiChar));
      end;
    end;
  end;

  function AddBuf(const AItem: PAnsiChar; ItemLen: Integer = -1): Boolean;
  var
    NumChar: Integer;
    Len: Integer;
    I: Integer;
    Item: PAnsiChar;
    Negitive: Integer;
    BytesToCopy: Cardinal;
  begin
    Item := AItem;
    if Assigned(AItem) then
      NumChar := StrLen(Item)
    else
      NumChar := 0;
    if (ItemLen > -1) and (NumChar > ItemLen) then
      NumChar := ItemLen;
    Len := NumChar * Sizeof(AnsiChar);
    if (Assigned(AItem)) and (Item^ = '-') and (FormatChar <> 'S') then
    begin
      Dec(Len, Sizeof(AnsiChar));
      Dec(NumChar);
      Negitive := 1;
    end
    else
      Negitive := 0;
    if not LeftJustification then
    begin
      Result := ApplyWidth(NumChar, Negitive);
      if Result then
        Exit;
    end;
    if Negitive = 1 then
    begin
      if BufMaxLen = 0 then
      begin
        Result := True;
        Exit;
      end;
      Inc(Item);
      BufPtr^ := '-';
      Inc(BufPtr);
      Dec(BufMaxLen, Sizeof(AnsiChar));
    end;
    if (Precision <> -1) and (Precision > NumChar) and (FormatChar <> 'S') then
      for I := NumChar + 1 to Precision do
      begin
        if BufMaxLen = 0 then
        begin
          Result := True;
          Exit;
        end;
        BufPtr^ := '0';
        Inc(BufPtr);
        Dec(BufMaxLen, Sizeof(AnsiChar));
      end;
    if Assigned(AItem) then
    begin
      Result := BufMaxLen < Cardinal(Len);
      if Result then
        BytesToCopy := BufMaxLen
      else
        BytesToCopy := Len;
      Move(Item^, BufPtr^, BytesToCopy);
      BufPtr := PAnsiChar(PByte(BufPtr) + BytesToCopy);
      Dec(BufMaxLen, BytesToCopy);
    end
    else
      Result := False;
    if LeftJustification then
      Result := ApplyWidth(NumChar, Negitive);
  end;

begin
  if (not Assigned(@Buffer)) or  (not Assigned(@Format)) then
  begin
    Result := 0;
    Exit;
  end;
  ArgsIndex := -1;
  ArgsLength := Length(Args);
  BufPtr := PAnsiChar(@Buffer);
  FormatPtr := PAnsiChar(@Format);
  if BufLen < $7FFFFFFF then
    BufMaxLen := BufLen * Sizeof(AnsiChar)
  else
    BufMaxLen := BufLen;
  FormatEndPtr := FormatPtr + FmtLen;
  while (FormatPtr < FormatEndPtr) do
    if FormatPtr^ = '%' then
    begin
      Inc(FormatPtr);
      if (FormatPtr >= FormatEndPtr) then
        Break;
      if FormatPtr^ = '%' then
      begin
        if BufMaxLen = 0 then
          AnsiFormatError(0, PAnsiChar(@Format), FmtLen);
        BufPtr^ := FormatPtr^;
        Inc(FormatPtr);
        Inc(BufPtr);
        Dec(BufMaxLen, Sizeof(AnsiChar));
        Continue;
      end;
      Width := 0;
      // Gather Index
      Inc(ArgsIndex);
      if TCharacter.IsNumber(Char(FormatPtr^)) then
      begin
        FormatStartPtr := FormatPtr;
        while (FormatPtr < FormatEndPtr) and (TCharacter.IsNumber(Char(FormatPtr^)))  do
          Inc(FormatPtr);
        if FormatStartPtr <> FormatPtr then
        begin
          StrLCopy(StrBuf, FormatStartPtr, Integer(FormatPtr - FormatStartPtr));
          if not TryStrToInt(string(StrBuf), FirstNumber) then
            AnsiFormatError(0, PAnsiChar(@Format), FmtLen);
          if FormatPtr^ = ':' then
          begin
            Inc(FormatPtr);
            ArgsIndex := FirstNumber;
          end
          else
            Width := FirstNumber;
        end;
      end
      else if FormatPtr^ = ':' then
      begin
        ArgsIndex := 0;
        Inc(FormatPtr);
      end;
      // Gather Justification
      if FormatPtr^ = '-' then
      begin
        LeftJustification := True;
        Inc(FormatPtr);
      end
      else
        LeftJustification := False;
      // Gather Width
      FormatStartPtr := FormatPtr;
      if FormatPtr^ = '*' then
      begin
        Width := -2;
        Inc(FormatPtr);
      end
      else if TCharacter.IsNumber(Char(FormatPtr^)) then
      begin
        while (FormatPtr < FormatEndPtr) and (TCharacter.IsNumber(Char(FormatPtr^)))  do
          Inc(FormatPtr);
        if FormatStartPtr <> FormatPtr then
        begin
          StrLCopy(StrBuf, FormatStartPtr, Integer(FormatPtr - FormatStartPtr));
          if not TryStrToInt(string(StrBuf), Width) then
            AnsiFormatError(0, PAnsiChar(@Format), FmtLen);
        end
      end;
      // Gather Precision
      if FormatPtr^ = '.' then
      begin
        Inc(FormatPtr);
        if (FormatPtr >= FormatEndPtr) then
          Break;
        if FormatPtr^ = '*' then
        begin
          Precision := -2;
          Inc(FormatPtr);
        end
        else
        begin
          FormatStartPtr := FormatPtr;
          while (FormatPtr < FormatEndPtr) and (TCharacter.IsNumber(Char(FormatPtr^)))  do
            Inc(FormatPtr);
          StrLCopy(StrBuf, FormatStartPtr, Integer(FormatPtr - FormatStartPtr));
          if not TryStrToInt(string(StrBuf), Precision) then
            AnsiFormatError(0, PAnsiChar(@Format), FmtLen);
        end;
      end
      else
        Precision := -1;

      // Gather Conversion Character
      if not TCharacter.IsLetter(Char(FormatPtr^)) then
        Break;
      case FormatPtr^ of
        'a'..'z':
          FormatChar := AnsiChar(Byte(FormatPtr^) xor $20);
      else
        FormatChar := FormatPtr^;
      end;
      Inc(FormatPtr);

      // Handle Args
      if Width = -2 then // If * width was found
      begin
        if ArgsIndex >= ArgsLength then
          AnsiFormatError(1, PAnsiChar(@Format), FmtLen);
        if Args[ArgsIndex].VType = vtInteger then
        begin
          if ArgsIndex >= ArgsLength then
            AnsiFormatError(1, PAnsiChar(@Format), FmtLen);
          Width := Args[ArgsIndex].VInteger;
          if Width < 0 then
          begin
            LeftJustification := not LeftJustification;
            Width := -Width;
          end;
          Inc(ArgsIndex);
        end
        else
          AnsiFormatError(0, PAnsiChar(@Format), FmtLen);
      end;
      if Precision = -2 then
      begin
        if ArgsIndex >= ArgsLength then
          AnsiFormatError(1, PAnsiChar(@Format), FmtLen);
        if Args[ArgsIndex].VType = vtInteger then
        begin
          if ArgsIndex >= ArgsLength then
            AnsiFormatError(1, PAnsiChar(@Format), FmtLen);
          Precision := Args[ArgsIndex].VInteger;
          Inc(ArgsIndex);
        end
        else
          AnsiFormatError(0, PAnsiChar(@Format), FmtLen);
      end;

      if ArgsIndex >= ArgsLength then
        AnsiFormatError(1, PAnsiChar(@Format), FmtLen);
      CurrentArg := Args[ArgsIndex];

      Overwrite := False;
      case CurrentArg.VType of
        vtBoolean,
        vtObject,
        vtClass,
        vtWideChar,
        vtPWideChar,
        vtWideString,
        vtInterface: AnsiFormatError(0, PAnsiChar(@Format), FmtLen);
        vtInteger:
          begin
            if (Precision > 16) or (Precision = -1) then
              Precision := 0;
            case FormatChar of
              'D': S := AnsiString(IntToStr(CurrentArg.VInteger));
              'U': S := AnsiString(UIntToStr(Cardinal(CurrentArg.VInteger)));
              'X': S := AnsiString(IntToHex(CurrentArg.VInteger, 0));
            else
              AnsiFormatError(0, PAnsiChar(@Format), FmtLen);
            end;
            Overwrite := AddBuf(PAnsiChar(S));
          end;
        vtChar:
          if FormatChar = 'S' then
          begin
            S := AnsiChar(CurrentArg.VChar);
            Overwrite := AddBuf(PAnsiChar(S), Precision);
          end
          else
            AnsiFormatError(0, PAnsiChar(@Format), FmtLen);
        vtExtended, vtCurrency:
          begin
            if CurrentArg.VType = vtExtended then
              FloatVal := fvExtended
            else
              FloatVal := fvCurrency;
            Len := 0;
            if (FormatChar = 'G') or (FormatChar = 'E') then
            begin
              if Cardinal(Precision) > 18 then
                Precision := 15;
            end
            else if Cardinal(Precision) > 18 then
            begin
              Precision := 2;
              if FormatChar = 'M' then
                Precision := AFormatSettings.CurrencyDecimals;
            end;
            case FormatChar of
              'G': Len := FloatToText(StrBuf, CurrentArg.VExtended^, FloatVal, ffGeneral, Precision, 3, AFormatSettings);
              'E': Len := FloatToText(StrBuf, CurrentArg.VExtended^, FloatVal, ffExponent, Precision, 3, AFormatSettings);
              'F': Len := FloatToText(StrBuf, CurrentArg.VExtended^, FloatVal, ffFixed, 18, Precision, AFormatSettings);
              'N': Len := FloatToText(StrBuf, CurrentArg.VExtended^, FloatVal, ffNumber, 18, Precision, AFormatSettings);
              'M': Len := FloatToText(StrBuf, CurrentArg.VExtended^, FloatVal, ffCurrency, 18, Precision, AFormatSettings);
            else
              AnsiFormatError(0, PAnsiChar(@Format), FmtLen);
            end;
            StrBuf[Len] := #0;
            Precision := 0;
            Overwrite := AddBuf(StrBuf);
          end;
        vtString:
          if FormatChar = 'S' then
            Overwrite := AddBuf(PAnsiChar(AnsiString(ShortString(PShortString(CurrentArg.VAnsiString)^))), Precision)
          else
            AnsiFormatError(0, PAnsiChar(@Format), FmtLen);
        vtUnicodeString:
          if FormatChar = 'S' then
            Overwrite := AddBuf(PAnsiChar(AnsiString(CurrentArg.VPWideChar)), Precision)
          else
            AnsiFormatError(0, PAnsiChar(@Format), FmtLen);
        vtVariant:
          if FormatChar = 'S' then
            case TVarData(CurrentArg.VVariant^).VType of
              varString:
                Overwrite := AddBuf(PAnsiChar(TVarData(CurrentArg.VVariant^).VString), Precision);
              varOleStr:
                Overwrite := AddBuf(PAnsiChar(AnsiString(TVarData(CurrentArg.VVariant^).VOleStr)), Precision);
              varUString:
                Overwrite := AddBuf(PAnsiChar(AnsiString(string(TVarData(CurrentArg.VVariant^).VUString))), Precision);
            else
              FormatError(0, PChar(@Format), FmtLen);
            end
          else
            FormatError(0, PChar(@Format), FmtLen);
        vtPointer:
          if FormatChar = 'P' then
          begin
            S := AnsiString(IntToHex(NativeInt(CurrentArg.VPointer), SizeOf(Pointer)*2));
            Overwrite := AddBuf(PAnsiChar(S));
          end
          else
            AnsiFormatError(0, PAnsiChar(@Format), FmtLen);
        vtPChar:
          if FormatChar = 'S' then
            Overwrite := AddBuf(CurrentArg.VWideString, Precision)
          else
            AnsiFormatError(0, PAnsiChar(@Format), FmtLen);
        vtAnsiString:
          if FormatChar = 'S' then
            Overwrite := AddBuf(CurrentArg.VAnsiString, Precision)
          else
            AnsiFormatError(0, PAnsiChar(@Format), FmtLen);
        vtInt64:
          begin
            if (Precision > 32) or (Precision = -1)  then
              Precision := 0;
            case FormatChar of
              'D': S := AnsiString(IntToStr(CurrentArg.VInt64^));
              'U': S := AnsiString(UIntToStr(UInt64(CurrentArg.VInt64^)));
              'X': S := AnsiString(IntToHex(CurrentArg.VInt64^, 0));
            else
              AnsiFormatError(0, PAnsiChar(@Format), FmtLen);
            end;
            Overwrite := AddBuf(PAnsiChar(S));
          end;
      end;
      if Overwrite then
      begin
        Result := BufPtr - PAnsiChar(@Buffer);
        Exit;
      end;
    end
    else
    begin
      if BufMaxLen = 0 then
      begin
        Result := BufPtr - PAnsiChar(@Buffer);
        Exit;
      end;
      BufPtr^ := FormatPtr^;
      Inc(FormatPtr);
      Inc(BufPtr);
      Dec(BufMaxLen, Sizeof(AnsiChar));
    end;
  Result := BufPtr - PAnsiChar(@Buffer);
end;

procedure WideFmtStr(var Result: WideString; const Format: WideString;
  const Args: array of const); overload;
begin
  WideFmtStr(Result, Format, Args, FormatSettings);
end;

procedure WideFmtStr(var Result: WideString; const Format: WideString;
  const Args: array of const; const AFormatSettings: TFormatSettings); overload;
const
  BufSize = 2048;
var
  Len, BufLen: Integer;
  Buffer: array[0..BufSize-1] of WideChar;
begin
  if Length(Format) < (BufSize - (BufSize div 4)) then
  begin
    BufLen := BufSize;
    Len := WideFormatBuf(Buffer, BufSize - 1, Pointer(Format)^,
      Length(Format), Args, AFormatSettings);
    if Len < BufLen - 1 then
    begin
      SetString(Result, Buffer, Len);
      Exit;
    end;
  end
  else
  begin
    BufLen := Length(Format);
    Len := BufLen;
  end;

  while Len >= BufLen - 1 do
  begin
    Inc(BufLen, BufLen);
    Result := '';          // prevent copying of existing data, for speed
    SetLength(Result, BufLen);
    Len := WideFormatBuf(Pointer(Result)^, BufLen - 1, Pointer(Format)^,
      Length(Format), Args, AFormatSettings);
  end;
  SetLength(Result, Len);
end;

function WideFormat(const Format: WideString; const Args: array of const): WideString;
begin
  Result := WideFormat(Format, Args, FormatSettings);
end;

function WideFormat(const Format: WideString; const Args: array of const;
  const AFormatSettings: TFormatSettings): WideString;
begin
  WideFmtStr(Result, Format, Args, AFormatSettings);
end;

{ Floating point conversion routines }

const
  // 1E18 as a 64-bit integer
  Const1E18Lo = $0A7640000;
  Const1E18Hi = $00DE0B6B3;
  FCon1E18: Extended = 1E18;
  DCon10: Integer = 10;

function FloatToText(BufferArg: PWideChar; const Value; ValueType: TFloatValue;
  Format: TFloatFormat; Precision, Digits: Integer): Integer;
begin
  Result := FloatToText(BufferArg, Value, ValueType, Format, Precision,
    Digits, FormatSettings);
end;

function FloatToText(BufferArg: PAnsiChar; const Value; ValueType: TFloatValue;
  Format: TFloatFormat; Precision, Digits: Integer): Integer;
begin
  Result := FloatToText(BufferArg, Value, ValueType, Format, Precision,
    Digits, FormatSettings);
end;

function WideFloatToTextFmtSettings(BufferArg: PWideChar;
  const Value; ValueType: TFloatValue; Format: TFloatFormat;
  Precision, Digits: Integer; const AFormatSettings: TFormatSettings): Integer;
begin
  Result := FloatToText(BufferArg, Value, ValueType, Format, Precision,
    Digits, AFormatSettings);
end;

function InternalFloatToText(
  ABuffer: PByte;
  ABufferIsUnicode: Boolean;
  const AValue;
  AValueType: TFloatValue;
  AFormat: TFloatFormat;
  APrecision, ADigits: Integer;
  const AFormatSettings: TFormatSettings): Integer;
const
  CMinExtPrecision = 2;
{$IFDEF CPUX86}
  CMaxExtPrecision = 18;
{$ELSE !CPUX86}
  CMaxExtPrecision = 16;
{$ENDIF !CPUX86}

  CCurrPrecision = 19;
  CGenExpDigits = 9999;

  CExpChar = 'E';          // DO NOT LOCALIZE
  CMinusSign: Char = '-';  // DO NOT LOCALIZE
  CPlusSign: Char = '+';   // DO NOT LOCALIZE
  CZero: Char = '0';       // DO NOT LOCALIZE
  CSpecial: array[0 .. 1] of string[3] = ('INF', 'NAN'); // DO NOT LOCALIZE
  CCurrencyFormats: array[0 .. 3] of string[5] = ('$*@@@', '*$@@@', '$ *@@', '* $@@'); // DO NOT LOCALIZE
  CNegCurrencyFormats: array[0 .. 15] of string[5] =
  (
    '($*)@', '-$*@@', '$-*@@', '$*-@@', '(*$)@', '-*$@@', // DO NOT LOCALIZE
    '*-$@@', '*$-@@', '-* $@', '-$ *@', '* $-@', // DO NOT LOCALIZE
    '$ *-@', '$ -*@', '*- $@', '($ *)', '(* $)' // DO NOT LOCALIZE
  );

var
  FloatRec: TFloatRec;

  LDigits: Integer;
  LExponent: Cardinal;
  LUseENotation: Boolean;

  LCurrentFormat: string[5];
  LCurrChar: AnsiChar;
  LFloatRecDigit: Integer;
  LNextThousand: Integer;

  procedure AppendChar(const AChar: Char);
  begin
    if ABufferIsUnicode then
    begin
      PWideChar(ABuffer)^ := AChar;
      Inc(ABuffer, SizeOf(Char));
    end else
    begin
      PAnsiChar(ABuffer)^ := AnsiChar(AChar);
      Inc(ABuffer, SizeOf(AnsiChar));
    end;

    Inc(Result);
  end;

  procedure AppendAnsiChar(const AChar: AnsiChar);
  begin
    if ABufferIsUnicode then
    begin
      PWideChar(ABuffer)^ := Char(AChar);
      Inc(ABuffer, SizeOf(Char));
    end else
    begin
      PAnsiChar(ABuffer)^ := AChar;
      Inc(ABuffer, SizeOf(AnsiChar));
    end;

    Inc(Result);
  end;

  procedure AppendShortString(const AStr: ShortString);
  var
    I, L: Integer;
  begin
    L := Length(AStr);

    if L > 0 then
    begin
      if ABufferIsUnicode then
      begin
        { Unicode -- loop }
        for I := 1 to L do
        begin
          PWideChar(ABuffer)^ := Char(AStr[I]);
          Inc(ABuffer, SizeOf(Char));
        end;
      end else
      begin
        { ANSI -- move directly }
        Move(AStr[1], ABuffer^, L);
        Inc(ABuffer, L * SizeOf(AnsiChar));
      end;

      Inc(Result, L);
    end;
  end;

  procedure AppendString(const AStr: String);
  var
    I, L: Integer;
  begin
    L := Length(AStr);

    if L > 0 then
    begin
      if ABufferIsUnicode then
      begin
        { Unicode -- move directly }
        MoveChars(AStr[1], ABuffer^, L);
        Inc(ABuffer, L * SizeOf(Char));
      end else
      begin
        { ANSI -- loop }
        for I := 1 to L do
        begin
          PAnsiChar(ABuffer)^ := AnsiChar(AStr[I]);
          Inc(ABuffer, SizeOf(AnsiChar));
        end;
      end;

      Inc(Result, L);
    end;
  end;

  function GetDigit: AnsiChar;
  begin
    Result := FloatRec.Digits[LFloatRecDigit];

    if Result = #0 then
      Result := '0'
    else
      Inc(LFloatRecDigit);
  end;

  procedure FormatNumber;
  var
    K: Integer;
  begin
    if ADigits > CMaxExtPrecision then
      LDigits := CMaxExtPrecision
    else
      LDigits := ADigits;

    K := FloatRec.Exponent;
    if K > 0 then
    begin
      { Find the position of the next thousand separator }
      LNextThousand := 0;
      if AFormat <> ffFixed then
        LNextThousand := ((K - 1) mod 3) + 1;

      repeat
        { Append the next digit }
        AppendAnsiChar(GetDigit);

        { Update loop counters }
        Dec(K);
        Dec(LNextThousand);

        { Try to append the thousands separator and reset the counter }
        if (LNextThousand = 0) and (K > 0) then
        begin
          LNextThousand := 3;

          if AFormatSettings.ThousandSeparator <> #0 then
            AppendChar(AFormatSettings.ThousandSeparator);
        end;
      until (K = 0);

    end else
      AppendChar(CZero);

    { If there are ADigits left to fill }
    if LDigits <> 0 then
    begin
      { Put in the decimal separator if it was specified }
      if AFormatSettings.DecimalSeparator <> #0 then
        AppendChar(AFormatSettings.DecimalSeparator);

      { If there is  negative exponent }
      if K < 0 then
      begin
        { Fill with zeroes until the exponent or ADigits are exhausted}
        repeat
          AppendChar(CZero);

          Inc(K);
          Dec(LDigits);
        until (K = 0) or (LDigits = 0);
      end;

      if LDigits > 0 then
      begin
        { Exponent was filled, there are still ADigits left to fill }
        repeat
          AppendAnsiChar(GetDigit);
          Dec(LDigits);
        until (LDigits <= 0);
      end;
    end;
  end;

  procedure FormatExponent;
  var
    LMinCnt, LExponent: Integer;
    LExpString: string[8];
    LDigitCnt: Integer;
  begin
    { Adjust digit count }
    if ADigits > 4 then
      LMinCnt := 0
    else
      LMinCnt := ADigits;

    { Get exponent }
    LExponent := FloatRec.Exponent - 1;

    { Place the E character into position }
    AppendChar(CExpChar);

{    if FloatRec.Digits[0] <> #0 then
    begin
      if LExponent < 0 then
      begin
        LExponent := -LExponent;
        AppendChar(CMinusSign);
      end;
    end else
    begin
      LExponent := 0;

      if AFormat <> ffGeneral then
        AppendChar(CPlusSign);
    end;
 }
    if FloatRec.Digits[0] <> #0 then
    begin
      if LExponent < 0 then
      begin
        LExponent := -LExponent;
        AppendChar(CMinusSign);
      end
      else
      begin
        if AFormat <> ffGeneral then
          AppendChar(CPlusSign);
      end;
    end else
    begin
      if AFormat <> ffGeneral then
        AppendChar(CPlusSign);
      LExponent := 0;
    end;

    Str(LExponent, LExpString);
    LDigitCnt := Length(LExpString);

    while LDigitCnt < LMinCnt do
    begin
      AppendChar(CZero);
      Inc(LDigitCnt);
    end;

    AppendShortString(LExpString);
  end;

begin
  LFloatRecDigit := 0;
  Result := 0;

  if AValueType = fvExtended then
  begin
    { Check min and max precisions for an Extended }
    if APrecision < CMinExtPrecision then
      APrecision := CMinExtPrecision
    else if APrecision > CMaxExtPrecision then
      APrecision := CMaxExtPrecision;
  end else
    APrecision := CCurrPrecision;

  { Check the number of ADigits to use }
  if AFormat in [ffGeneral, ffExponent] then
    LDigits := CGenExpDigits
  else
    LDigits := ADigits;

  { Decode the float }
  FloatToDecimal(FloatRec, AValue, AValueType, APrecision, LDigits);
{$IFDEF CPUX86}
  LExponent := FloatRec.Exponent - $7FFF;
{$ENDIF CPUX86}
{$IFDEF CPUX64}
  LExponent := FloatRec.Exponent - $7FF;
{$ENDIF CPUX64}

  { Check for INF or NAN}
  if LExponent < 2 then
  begin
    { Append the sign to output buffer }
    if FloatRec.Negative then
      AppendChar(CMinusSign);

    AppendShortString(CSpecial[LExponent]);
    Exit;
  end;

  if (not (AFormat in [ffGeneral .. ffCurrency])) or
    ((FloatRec.Exponent > APrecision) and (AFormat <> ffExponent)) then
    AFormat := ffGeneral;

  case AFormat of
    ffGeneral:
    begin
      { Append the sign to output buffer }
      if FloatRec.Negative then
        AppendChar(CMinusSign);

      LUseENotation := False;

      { Obtain digit count and whether to use the E notation }
      LDigits := FloatRec.Exponent;
      if (LDigits > APrecision) or (LDigits < -3) then
      begin
        LDigits := 1;
        LUseENotation := True;
      end;

      if LDigits > 0 then
      begin
        { Append the ADigits that precede decimal separator }
        while LDigits > 0 do
        begin
          AppendAnsiChar(GetDigit);
          Dec(LDigits);
        end;

        { Append the decimal separator and the following digit }
        if FloatRec.Digits[LFloatRecDigit] <> #0 then
        begin
          AppendChar(AFormatSettings.DecimalSeparator);

          { Append the ADigits that come after the decimal separator }
          while FloatRec.Digits[LFloatRecDigit] <> #0 do
            AppendAnsiChar(GetDigit);
        end;

        if LUseENotation then
          FormatExponent();
      end else
      begin
        AppendChar(CZero);

        if FloatRec.Digits[0] <> #0 then
        begin
          AppendChar(AFormatSettings.DecimalSeparator);
          LDigits := -LDigits;

          { Append zeroes to fulfill the exponent }
          while LDigits > 0 do
          begin
            AppendChar(CZero);
            Dec(LDigits);
          end;

          { Attach all the other ADigits now }
          while FloatRec.Digits[LFloatRecDigit] <> #0 do
            AppendAnsiChar(GetDigit);
        end;
      end;
    end;

    ffExponent:
    begin
      { Append the sign to output buffer }
      if FloatRec.Negative then
        AppendChar(CMinusSign);

      { Append the first digit and the decimal separator }
      AppendAnsiChar(GetDigit);
      AppendChar(AFormatSettings.DecimalSeparator);

      { Append ADigits based on the APrecision requirements }
      Dec(APrecision);
      repeat
        AppendAnsiChar(GetDigit);
        Dec(APrecision);
      until (APrecision = 0);

      FormatExponent();
    end;

    ffNumber, ffFixed:
    begin
      { Append the sign to output buffer }
      if FloatRec.Negative then
        AppendChar(CMinusSign);

      FormatNumber();
    end;

    ffCurrency:
    begin
      { Select the appropriate currency AFormat}
      if FloatRec.Negative then
      begin
        {  negative AFormat is used, check for bounds and select }
        if AFormatSettings.NegCurrFormat > High(CNegCurrencyFormats) then
          LCurrentFormat := CNegCurrencyFormats[High(CNegCurrencyFormats)]
        else
          LCurrentFormat := CNegCurrencyFormats[AFormatSettings.NegCurrFormat];
      end else
      begin
        {  positive AFormat is used, check for bounds and select }
        if AFormatSettings.CurrencyFormat > High(CCurrencyFormats) then
          LCurrentFormat := CCurrencyFormats[High(CCurrencyFormats)]
        else
          LCurrentFormat := CCurrencyFormats[AFormatSettings.CurrencyFormat];
      end;

      { Iterate over each charater in the AFormat string }
      for LCurrChar in LCurrentFormat do
        case LCurrChar of
          '@': break;
          '$':
            if AFormatSettings.CurrencyString <> EmptyStr then
              AppendString(AFormatSettings.CurrencyString);
          '*': FormatNumber();
          else
             AppendAnsiChar(LCurrChar);
        end;
    end;
  end;
end;

function FloatToText(BufferArg: PWideChar; const Value; ValueType: TFloatValue;
  Format: TFloatFormat; Precision, Digits: Integer;
  const AFormatSettings: TFormatSettings): Integer;
begin
  { Call internal helper. Specify that we're using an Unicode buffer }
  Result := InternalFloatToText(PByte(BufferArg), True, Value, ValueType, Format, Precision, Digits, AFormatSettings);
end;

function FloatToText(BufferArg: PAnsiChar; const Value; ValueType: TFloatValue;
  Format: TFloatFormat; Precision, Digits: Integer;
  const AFormatSettings: TFormatSettings): Integer;
begin
  { Call internal helper. Specify that we're using an ANSI buffer }
  Result := InternalFloatToText(PByte(BufferArg), False, Value, ValueType, Format, Precision, Digits, AFormatSettings);
end;

function InternalFloatToTextFmt(Buf: PByte; const Value; ValueType: TFloatValue; Format: PByte;
  const AFormatSettings: TFormatSettings; const Unicode: Boolean): Integer;
const
  CMinExtPrecision = 2;
{$IFDEF CPUX64}
  CMaxExtPrecision = 18;
{$ELSE !CPUX64}
  CMaxExtPrecision = 16;
{$ENDIF !CPUX64}

var
  AIndex: Integer;
  ThousandSep: Boolean;
  Section: String;
  SectionIndex: Integer;
  FloatValue: TFloatRec;
  DecimalIndex: Integer;
  FirstDigit: Integer;
  LastDigit: Integer;
  DigitCount: Integer;
  Scientific: Boolean;
  Precision: Integer;
  Digits: Integer;
  DecimalSep: Char;
  ThousandsSep: Char;
  FormatLength: Integer;

  procedure AppendChar(const AChar: Char);
  begin
    if Unicode then
    begin
      PWideChar(Buf)^ := AChar;
      Inc(Buf, SizeOf(Char));
    end else
    begin
      PAnsiChar(Buf)^ := AnsiChar(AChar);
      Inc(Buf, SizeOf(AnsiChar));
    end;

    Inc(Result);
  end;

  function GetLength(const ABuf: PByte): Integer;
  var
    AWide: PWideChar;
    AAnsi: PAnsiChar;
  begin
    Result := 0;
    if Unicode then
    begin
      AWide := PWideChar(ABuf);
      while AWide^ <> #0 do
      begin
        Inc(AWide);
        Inc(Result);
      end;
    end else
    begin
      AAnsi := PAnsiChar(ABuf);
      while AAnsi^ <> #0 do
      begin
        Inc(AAnsi);
        Inc(Result);
      end;
    end;
  end;

  function GetCharIndex(const ABuf: PByte; const Index: Integer): Char;
  begin
    if Unicode then
      Result := PWideChar(ABuf)[Index]
    else
      Result := Char(PAnsiChar(ABuf)[Index]);
  end;

  procedure AppendAnsiChar(const AChar: AnsiChar);
  begin
    if Unicode then
    begin
      PWideChar(Buf)^ := Char(AChar);
      Inc(Buf, SizeOf(Char));
    end else
    begin
      PAnsiChar(Buf)^ := AChar;
      Inc(Buf, SizeOf(AnsiChar));
    end;

    Inc(Result);
  end;

  procedure AppendString(const AStr: String);
  var
    I, L: Integer;
  begin
    L := Length(AStr);

    if L > 0 then
    begin
      if Unicode then
      begin
        { Unicode -- move directly }
        MoveChars(AStr[1], Buf^, L);
        Inc(Buf, L * SizeOf(Char));
      end else
      begin
        { ANSI -- loop }
        for I := 1 to L do
        begin
          PAnsiChar(Buf)^ := AnsiChar(AStr[I]);
          Inc(Buf, SizeOf(AnsiChar));
        end;
      end;

      Inc(Result, L);
    end;
  end;

  function FindSection(AIndex: Integer): Integer;
  var
    Section: Integer;
    C: Integer;
  begin
    Section := 0;
    C := 0;
    FormatLength := GetLength(Format);
    while (Section <> AIndex) and (C < FormatLength) do
    begin
      case GetCharIndex(Format, C) of
        ';': begin
          Inc(Section);
          Inc(C);
        end;

        '"': begin
          Inc(C);
          while (C < FormatLength) and (GetCharIndex(Format, C) <> '"') do
            Inc(C);
          if C < FormatLength then
            Inc(C);
        end;

        '''': begin
          Inc(C);
          while (C < FormatLength) and (GetCharIndex(Format, C) <> '''') do
            Inc(C);
          if C < FormatLength then
            Inc(C);
        end;

        else
          Inc(C);
      end;
    end;
    if (Section < AIndex) or (C = FormatLength) then
      Result := 0
    else
      Result := C;
  end;

  function ScanSection(APos: Integer): String;
  var
    C: Integer;
    AChar: Char;
    I: Integer;
  begin
    DecimalIndex := -1;
    Scientific := false;
    ThousandSep := false;
    C := APos;
    FirstDigit := 32767;
    DigitCount := 0;
    LastDigit := 0;
    while (C < FormatLength) and (GetCharIndex(Format, C) <> ';') do
    begin
      case GetCharIndex(Format, C) of
        ',': begin
          ThousandSep := true;
          Inc(C);
        end;

        '.': begin
          if DecimalIndex = -1 then
            DecimalIndex := DigitCount;
          Inc(C);
        end;

        '"': begin
          Inc(C);
          while (C < FormatLength) and (GetCharIndex(Format, C) <> '"') do
            Inc(C);
          if C < FormatLength then
            Inc(C);
        end;

        '''': begin
          Inc(C);
          while (C < FormatLength) and (GetCharIndex(Format, C) <> '''') do
            Inc(C);
          if C < FormatLength then
            Inc(C);
        end;

        'e', 'E': begin
          Inc(C);
          if C < FormatLength then
          begin
            AChar := GetCharIndex(Format, C);
            if (AChar = '-') or (AChar = '+') then begin
              Scientific := true;
              Inc(C);
              while (C < FormatLength) and (GetCharIndex(Format, C) = '0') do
                Inc(C);
            end;
          end;
        end;

        '#': begin
          Inc(DigitCount);
          Inc(C);
        end;

        '0': begin
          if DigitCount < FirstDigit then
            FirstDigit := DigitCount;

          Inc(DigitCount);
          LastDigit := DigitCount;
          Inc(C);
        end;

        else
          Inc(C);
      end;
    end;

    if DecimalIndex = -1 then
      DecimalIndex := DigitCount;
    LastDigit := DecimalIndex - LastDigit;
    if LastDigit > 0 then
      LastDigit := 0;

    FirstDigit := DecimalIndex - FirstDigit;
    if FirstDigit < 0 then
      FirstDigit := 0;
    Result := '';
    for I := APos to APos + (C - APos - 1) do
      Result := Result + GetCharIndex(Format, I);
  end;

  function DigitsLength: Integer;
  var
    C: Integer;
  begin
    Result := 0;
    C := Low(FloatValue.Digits);
    while (C <= High(FloatValue.Digits)) and (FloatValue.Digits[C] <> #0) do
    begin
      Inc(C);
      Inc(Result);
    end;
  end;

  procedure ApplyFormat;
  var
    C: Integer;
    DigitDelta: Integer;
    DigitPlace: Integer;
    DigitsC: Integer;
    DigitsLimit: Integer;
    OldC: Char;
    Sign: Char;
    Zeros: Integer;

    procedure WriteDigit(ADigit: AnsiChar);
    begin
      if DigitPlace = 0 then
      begin
        AppendChar(DecimalSep);
        AppendAnsiChar(ADigit);
        Dec(DigitPlace);
      end
      else
      begin
        AppendAnsiChar(ADigit);
        Dec(DigitPlace);
        if ThousandSep and (DigitPlace > 1) and ((DigitPlace mod 3) = 0) then
          AppendChar(ThousandsSep);
      end;
    end;

    procedure AddDigit;
    var
      AChar: AnsiChar;
    begin
      if DigitsC <= DigitsLimit then
      begin
        AChar := FloatValue.Digits[DigitsC];
        Inc(DigitsC);
        WriteDigit(AChar);
      end
      else
      begin
        if DigitPlace <= LastDigit then
          Dec(DigitPlace)
        else
          WriteDigit('0');
      end;
    end;

    procedure PutFmtDigit;
    begin
      if DigitDelta < 0 then
      begin
        Inc(DigitDelta);
        if DigitPlace <= FirstDigit then
          WriteDigit('0')
        else
          Dec(DigitPlace);
      end
      else
      begin
        if DigitDelta = 0 then
          AddDigit
        else
        begin  // DigitDelta > 0
          while DigitDelta > 0 do
          begin
            AddDigit;
            Dec(DigitDelta);
          end;
          AddDigit;
        end;
      end;
    end;

    procedure PutExponent(EChar: Char; Sign: Char; Zeros: Integer; Exponent: Integer);
    var
      Exp: String;
      WriteSign: String;
    begin
      AppendChar(EChar);
      if (Sign = '+') and (Exponent >=0) then
        WriteSign := '+'
      else
        if Exponent < 0 then
          WriteSign := '-'
        else
          WriteSign := '';

      Exp := IntToStr(Abs(Exponent));
      AppendString(WriteSign + StringOfChar('0', Zeros - Length(Exp)) + Exp);
    end;

  begin
    if (FloatValue.Negative) and (SectionIndex = 0) then
      AppendChar('-');

    if Scientific then
    begin
      DigitPlace := DecimalIndex;
      DigitDelta := 0;
    end
    else
    begin
      DigitDelta := FloatValue.Exponent - DecimalIndex;
      if DigitDelta >= 0 then
        DigitPlace := FloatValue.Exponent
      else
        DigitPlace := DecimalIndex;
    end;

    DigitsLimit := DigitsLength - 1;
    C := 1;
    DigitsC := 0;
    while C <= Length(Section) do
    begin
      case Section[C] of
        '0', '#': begin
          PutFmtDigit;
          Inc(C);
        end;

        '.', ',': Inc(C);

        '"', '''': begin
          OldC := Section[C];
          Inc(C);
          while (C < Length(Section)) and (Section[C] <> OldC) do
          begin
            AppendChar(Section[C]);
            Inc(C);
          end;
          Inc(C);
        end;

        'e', 'E': begin
          OldC := Section[C];
          Inc(C);
          if C <= Length(Section) then
          begin
            Sign := Section[C];
            if (Sign <> '+') and (Sign <> '-') then
              AppendChar(OldC)
            else
            begin
              Zeros := 0;
              Inc(C);
              while (C <= Length(Section)) and (Section[C] = '0') do
              begin
                Inc(C);
                if Zeros < 4 then Inc(Zeros);
              end;
              PutExponent(OldC, Sign, Zeros, FloatValue.Exponent - DecimalIndex);
            end;
          end;
        end;

        else
        begin
          AppendChar(Section[C]);
          Inc(C);
        end;
      end;
    end;
    if Result > 0 then begin
      AppendChar(#0);
      Dec(Result);
    end;
  end;

var
  Temp: Extended;

begin
  Result := 0;
  DecimalSep := AFormatSettings.DecimalSeparator;
  ThousandsSep := AFormatSettings.ThousandSeparator;

  if ValueType = fvCurrency then
    Temp := Currency(Value)
  else
    Temp := Extended(Value);

  if Extended(Temp) > 0 then
    AIndex := 0
  else
    if Extended(Temp) < 0 then
      AIndex := 1
    else
      AIndex := 2;

  SectionIndex := FindSection(AIndex);
  Section := ScanSection(SectionIndex);

  if Scientific then
  begin
    Precision := DigitCount;
    Digits := 9999;
  end
  else begin
    Precision := CMaxExtPrecision;
    Digits := DigitCount - DecimalIndex;
  end;
  FloatToDecimal(FloatValue, Value, ValueType, Precision, Digits);

  if (FormatLength = 0) or (GetCharIndex(Format, 0) = ';') or
    ((FloatValue.Exponent >= 18) and (not Scientific)) or
    (FloatValue.Exponent = $7FF) or (FloatValue.Exponent = $800) then
    if Unicode then
      Result := FloatToText(PWideChar(Buf), Value, ValueType, ffGeneral, 15, 0)
    else
      Result := FloatToText(PAnsiChar(Buf), Value, ValueType, ffGeneral, 15, 0)
  else
    ApplyFormat;
end;

function FloatToTextFmt(Buf: PAnsiChar; const Value; ValueType: TFloatValue;
  Format: PAnsiChar): Integer;
begin
  Result := FloatToTextFmt(Buf, Value, ValueType, Format, FormatSettings);
end;

function FloatToTextFmt(Buf: PAnsiChar; const Value; ValueType: TFloatValue;
  Format: PAnsiChar; const AFormatSettings: TFormatSettings): Integer;
begin
  Result := InternalFloatToTextFmt(PByte(Buf), Value, ValueType, PByte(Format), AFormatSettings, False);
end;

function FloatToTextFmt(Buf: PWideChar; const Value; ValueType: TFloatValue;
  Format: PWideChar): Integer;
begin
  Result := FloatToTextFmt(Buf, Value, ValueType, Format, FormatSettings);
end;

function FloatToTextFmt(Buf: PWideChar; const Value; ValueType: TFloatValue;
  Format: PWideChar; const AFormatSettings: TFormatSettings): Integer; overload;
begin
  Result := InternalFloatToTextFmt(PByte(Buf), Value, ValueType, PByte(Format), AFormatSettings, True);
end;

const
  cInfinity   =  1.0 / 0.0;
  cNInfinity  = -1.0 / 0.0;
  cNaN        =  0.0 / 0.0;

const
{$IFDEF CPUX86}
  Pow10Tab0: array[0..31] of Extended = (
    1e0,  1e1,  1e2,  1e3,  1e4,  1e5,  1e6,  1e7,  1e8,  1e9,
    1e10, 1e11, 1e12, 1e13, 1e14, 1e15, 1e16, 1e17, 1e18, 1e19,
    1e20, 1e21, 1e22, 1e23, 1e24, 1e25, 1e26, 1e27, 1e28, 1e29,
    1e30, 1e31);
  Pow10Tab1: array[0..14] of Extended = (
    1e32,  1e64,  1e96,  1e128, 1e160, 1e192, 1e224, 1e256, 1e288, 1e320,
    1e352, 1e384, 1e416, 1e448, 1e480);
  Pow10Tab2: array[0..8] of Extended = (
    1e512, 1e1024, 1e1536, 1e2048, 1e2560, 1e3072, 1e3584, 1e4096, 1e4608);
{$ELSE !CPUX86}
  Pow10Tab0: array[0..31] of Double = (
    1e0, 1e1, 1e2, 1e3, 1e4, 1e5, 1e6, 1e7, 1e8, 1e9,
    1e10, 1e11, 1e12, 1e13, 1e14, 1e15, 1e16, 1e17, 1e18, 1e19,
    1e20, 1e21, 1e22, 1e23, 1e24, 1e25, 1e26, 1e27, 1e28, 1e29,
    1e30, 1e31);
  Pow10Tab1: array[0..7] of Double = (
    1e0, 1e32, 1e64, 1e96, 1e128, 1e160, 1e192, 1e224);
{$ENDIF CPUX86}

function Power10(val: Extended; power: Integer): Extended;
{$IFDEF CPUX86}
var
  I, P: Integer;
begin
  Result := Val;
  if Power > 0 then
  begin
    if Power >= 5120 then
      Exit(cInfinity);
    Result := Result * Pow10Tab0[Power and $1F];
    P := Power shr 5;
    if P <> 0 then
    begin
      I := P and $F;
      if I <> 0 then
        Result := Result * Pow10Tab1[I - 1];
      I := P shr 4;
      if I <> 0 then
        Result := Result * Pow10Tab2[I - 1];
    end;
  end
  else if Power < 0 then
  begin
    P := -Power;
    if P >= 5120 then
      Exit(0);
    Result := Result / Pow10Tab0[P and $1F];
    P := P shr 5;
    if P <> 0 then
    begin
      I := P and $F;
      if I <> 0 then
        Result := Result / Pow10Tab1[I - 1];
      I := P shr 4;
      if I <> 0 then
        Result := Result / Pow10Tab2[I - 1];
    end;
  end;
end;
{$ELSE !CPUX86}
var
  I, P: Integer;
begin
  Result := Val;
  if Power > 0 then
  begin
    if Power >= 632 then // +308 - (-324) (Exp of  MinDouble)
    begin
      RaiseOverflowException;
      Exit(cInfinity);
    end;
    Result := Result * Pow10Tab0[Power and $1F];
    P := Power shr 5;
    if P <> 0 then
    begin
      I := P and $7;
      if I <> 0 then
        Result := Result * Pow10Tab1[I];
      I := P shr 3;
      if I >= 1 then // 256 - 511
        Result := Result * 1E256;
      if I = 2 then // 512 - 631 (767)
        Result := Result * 1E256;
    end;
  end
  else if Power < 0 then
  begin
    P := -Power;
    if P >= 632 then
    begin
      RaiseUnderflowException;
      Exit(0);
    end;
    Result := Result / Pow10Tab0[P and $1F];
    P := P shr 5;
    if P <> 0 then
    begin
      I := P and $7;
      if I <> 0 then
        Result := Result / Pow10Tab1[I];
      I := P shr 3;
      if I >= 1 then // 256 - 511
        Result := Result * 1E-256;
      if I = 2 then // 512 - 631 (767)
        Result := Result * 1E-256;
    end;
  end;
end;
{$ENDIF CPUX86}

const
// 8087/SSE status word masks
  mIE = $0001;
  mDE = $0002;
  mZE = $0004;
  mOE = $0008;
  mUE = $0010;
  mPE = $0020;
{$IFDEF CPUX86}
  mC0 = $0100;
  mC1 = $0200;
  mC2 = $0400;
  mC3 = $4000;
{$ENDIF CPUX86}

{$IFDEF CPUX86}
const
// 8087 control word
// Infinity control  = 1 Affine
// Rounding Control  = 0 Round to nearest or even
// Precision Control = 3 64 bits
// All interrupts masked
  CWNear: Word = $133F;
{$ENDIF CPUX86}
{$IFDEF CPUX64}
const
//  MXCSR control word
// Rounding Control  = 0 Round to nearest or even
// All interrupts masked
  MXCSRNear: UInt32 = $1F80;
{$ENDIF CPUX64}

procedure FloatToDecimal(var Result: TFloatRec; const Value;
  ValueType: TFloatValue; Precision, Decimals: Integer);
  type
    TBCDBytes = array [0..9] of Byte;

  function GetBcdBytes(val:Extended): TBcdBytes;
  var
    I: Int64;
    Ind, D: Integer;
  begin
    FillChar(Result, SizeOf(Result), 0);
    if val < 0 then Result[9] := $80;
    I := Round(Abs(val));
    Ind := 0;
    while (I > 0) and (Ind < 9) do
    begin
      D := I mod 100;
      Result[Ind] := (D mod 10) + ((D div 10) shl 4);
      I := I div 100;
      Inc(Ind);
    end;
  end;

  procedure ExtToDecimal(Value: Extended);
  var
    Exp : Integer;
    bcdBytes: TBcdBytes;
    I, J : Integer;
  begin
{$IFDEF CPUX86}
    Exp := PWordArray(@Value)^[4];
    Result.Negative := (Exp and $8000) = $8000;
{$ENDIF CPUX86}
{$IFDEF CPUX64}
    Exp := PWordArray(@Value)^[3] shr 4;
    Result.Negative := (Exp and $800) = $800;
{$ENDIF CPUX64}

{$IFDEF CPUX86}
    Exp := Exp and $7FFF;
    if (Exp = 0) and (PInt64(@Value)^ = 0)then
{$ENDIF CPUX86}
{$IFDEF CPUX64}
    Exp := Exp and $7FF;
    if (Exp = 0) and
        ( ((PWordArray(@Value)^[3] and $000F) = $0000) and
           (PWordArray(@Value)^[2] = $0000) and
           (PWordArray(@Value)^[1] = $0000) and
           (PWordArray(@Value)^[0] = $0000) ) then
{$ENDIF CPUX64}
    begin
      // plus/minus zero.
      Result.Exponent := 0; //
      Result.Digits[0] := #0;
      Exit;
    end
{$IFDEF CPUX86}
    else if Exp = $7FFF then
{$ENDIF CPUX86}
{$IFDEF CPUX64}
    else if Exp = $7FF then
{$ENDIF CPUX64}
    begin
{$IFDEF CPUX86}
      if (PWordArray(@Value)^[3] = $8000) and
         (PWordArray(@Value)^[2] = $0000) and
         (PWordArray(@Value)^[1] = $0000) and
         (PWordArray(@Value)^[0] = $0000) then
      begin
        // plus/minus inf.
        Result.Exponent := $7FFF; // Exp;
      end
{$ENDIF CPUX86}
{$IFDEF CPUX64}
      if (((PWordArray(@Value)^[3] and $000F) = $0000) and
           (PWordArray(@Value)^[2] = $0000) and
           (PWordArray(@Value)^[1] = $0000) and
           (PWordArray(@Value)^[0] = $0000) ) then
      begin
        // plus/minus inf.
        Result.Exponent := $7FF; // Exp;
      end
{$ENDIF CPUX64}
      else
      begin
        // NaN
{$IFDEF CPUX86}
        Result.Exponent := SmallInt($8000);
{$ENDIF CPUX86}
{$IFDEF CPUX64}
  Result.Exponent := SmallInt($800);
{$ENDIF CPUX64}
        Result.Negative := False;
      end;
      Result.Digits[0] := #0;
      Exit;
    end;

    if Result.Negative then Value := -Value;

{$IFDEF CPUX86}
    Exp := Exp - $3FFF;
{$ENDIF CPUX86}
{$IFDEF CPUX64}
    if Exp = 0 then  //denormalized number, exponent = 0 and mantissa <> 0, fix exponent
    begin
      N := PInt64(@Value)^;
      while (N and $0008000000000000) = 0 do
      begin
        Dec(Exp);
        N := N shl 1;
      end;
    end;
    Exp := Exp - $3FF;
{$ENDIF CPUX64}
    Exp := (Exp * 19728);  // // exp10 * 2 ** 16 = exp2 * log10(2) * 2**16. Log10(2) * 2 ** 16 ~= 19728
    Exp := PSmallInt(PByte(@Exp)+2)^; // Temp = High 16 bits of result, sign extended
    Exp := Exp + 1;
    Result.Exponent := Exp;

    Value := Round(Power10(Value, 18 - Exp));
    if Value >= FCon1E18 then
    begin
      Value := Value / DCon10;
      Inc(Result.Exponent);
    end;
    bcdBytes := GetBcdBytes(Value);

    for I := 8 downto 0 do
      PWord(@Result.Digits[16-I*2])^ := $3030 +
        ((bcdBytes[I] and $0F) SHL 8) +
        ((bcdBytes[I] and $F0) SHR 4);
    Result.Digits[18] := #0;

    if Result.Exponent + Decimals < 0 then
    begin
      Result.Exponent := 0;
      Result.Negative := False;
      Result.Digits[0] := #0;
      Exit;
    end;
    J := Result.Exponent + Decimals;
    if J >= Precision then J := Precision;
    if (J >= 18) or  (Result.Digits[J] < '5') then
    begin
      if (J > 18) then J := 18;
      while true do
      begin
        Result.Digits[J] := #0;
        Dec(J);
        if J < 0 then
        begin
          Result.Negative := False;
          Exit;
        end;
        if Result.Digits[J] <> '0' then
          Exit;
      end;
    end
    else
    begin
      while true do
      begin
        Result.Digits[J] := #0;
        Dec(J);
        if J < 0 then
        begin
          Result.Digits[0] := '1';
          Inc(Result.Exponent);
          Exit;
        end;

        Inc(Result.Digits[J]);
        if Result.Digits[J] <= '9' then
          Exit;
      end;
    end;
  end;

  procedure CurrToDecimal(Value: Currency);
  Var
    U: UInt64;
    S: String;
    RoundUpFlag: Boolean;
    I, J: Integer;
    RoundingCh : Char;
    Exp: SmallInt;
    NegaFlag: Boolean;
  begin
    Result.Negative := False;
    Result.Exponent := 0;
    Result.Digits[0] := #0;

    U := PUInt64(@Value)^;
    if U = 0 then Exit;

    NegaFlag := False;
    if (U and $8000000000000000) <> 0 then
    begin
      NegaFlag := True;
      U := not U + 1;
    end;

    S := _IntToStr64(U, False);

    if Decimals >= 4 then Decimals := 4
    else if Decimals < 0 then Decimals := 0;

    if Decimals < 4 then
    begin
      I := 4 - Decimals;

      if Length(S) < I then Exit;

      J := Length(S) - I + 1;
      RoundingCh := S[J];
      S[J] := '0';
      Inc(J);

      RoundUpFlag := False;
      while J <= Length(S) do
      begin
        if S[J] <> '0' then
        begin
          RoundUpFlag := True;
          S[J] := '0';
        end;
        Inc(J);
      end;

      if RoundingCh >= '5' then
      begin
        J := Length(S) - I;
        if (RoundingCh > '5') or (RoundUpFlag or ((J > 0) and (S[J] in ['1', '3', '5', '7', '9']))) then
        begin
          while (J > 0) and (S[J] = '9') do
          begin
            S[J] := '0';
            Dec(J);
          end;
          if J = 0 then S := '1' + S
          else S[J] := Succ(S[J]);
        end;
      end;
    end;

    Exp := Length(S) - 4;
    while (Length(S) > 0) and (S[Length(S)] = '0') do S := Copy(S, 1, Length(S)-1);
    if S = '' then Exit;

    for I := 1 to Length(S) do Result.Digits[I-1] := AnsiChar(S[I]);
    Result.Digits[Length(S)] := #0;
    Result.Exponent := Exp;
    Result.Negative := NegaFlag;
  end;

begin
  if ValueType = fvExtended then
    ExtToDecimal(Extended(Value))
  else
    CurrToDecimal(Currency(Value));
end;

{$IFDEF CPUX86}
function TestAndClearFPUExceptions(AExceptionMask: Word): Boolean;
asm
      PUSH    ECX
      MOV     CX, AX
      FSTSW   AX
      TEST    AX, CX
      JNE     @@bad
      XOR     EAX, EAX
      INC     EAX
      JMP     @@exit
@@bad:
      XOR     EAX, EAX
@@exit:
      POP     ECX
      FCLEX
      RET
end;
{$ENDIF CPUX86}
{$IFDEF CPUX64}
function TestAndClearSSEExceptions(AExceptionMask: UInt32): Boolean;
var
  MXCSR: UInt32;
begin
  MXCSR := GetMXCSR;
  Result := ((MXCSR and $003F) and AExceptionMask) = 0;
  ResetMXCSR;
end;
{$ENDIF CPUX64}

function InternalTextToFloat(
  ABuffer: PByte;
  const AIsUnicodeBuffer: Boolean;
  var AValue;
  const AValueType: TFloatValue;
  const AFormatSettings: TFormatSettings): Boolean;
const
{$IFDEF CPUX64}
  CMaxExponent = 1024;
{$ELSE !CPUX64}
  CMaxExponent = 4999;
{$ENDIF !CPUX64}

  CExponent = 'E'; // DO NOT LOCALIZE;
  CPlus = '+';     // DO NOT LOCALIZE;
  CMinus = '-';    // DO NOT LOCALIZE;

var
{$IFDEF CPUX86}
  LSavedCtrlWord: Word;
{$ENDIF CPUX86}
{$IFDEF CPUX64}
  LSavedMXCSR: UInt32;
{$ENDIF CPUX64}
  LPower: Integer;
  LSign: SmallInt;
  LResult: Extended;
  LCurrChar: Char;

  procedure NextChar;
  begin
    if AIsUnicodeBuffer then
    begin
      LCurrChar := PWideChar(ABuffer)^;
      Inc(PWideChar(ABuffer));
    end else
    begin
      LCurrChar := Char(PAnsiChar(ABuffer)^);
      Inc(PAnsiChar(ABuffer));
    end;
  end;

  procedure SkipWhitespace();
  begin
    { Skip white spaces }
    while LCurrChar = ' ' do
      NextChar;
  end;

  function ReadSign(): SmallInt;
  begin
    Result := 1;
    if LCurrChar = CPlus then
      NextChar()
    else if LCurrChar = CMinus then
    begin
      NextChar();
      Result := -1;
    end;
  end;

  function ReadNumber(var AOut: Extended): Integer;
  begin
    Result := 0;
    while CharInSet(LCurrChar, ['0'..'9']) do
    begin
      AOut := AOut * 10;
      AOut := AOut + Ord(LCurrChar) - Ord('0');

      NextChar();
      Inc(Result);
    end;
  end;

  function ReadExponent: SmallInt;
  var
    LSign: SmallInt;
  begin
    LSign := ReadSign();
    Result := 0;
    while CharInSet(LCurrChar, ['0'..'9']) do
    begin
      Result := Result * 10;
      Result := Result + Ord(LCurrChar) - Ord('0');
      NextChar();
    end;

    if Result > CMaxExponent then
      Result := CMaxExponent;

    Result := Result * LSign;
  end;

begin
  { Prepare }
  Result := False;
  NextChar();

{$IFDEF CPUX86}
  { Prepare the FPU }
  LSavedCtrlWord := Get8087CW();
  TestAndClearFPUExceptions(0);
  Set8087CW(CWNear);
{$ENDIF CPUX86}
{$IFDEF CPUX64}
  { Prepare the FPU }
  LSavedMXCSR := GetMXCSR;
  TestAndClearSSEExceptions(0);
  SetMXCSR(MXCSRNear);
{$ENDIF CPUX64}

  { Skip white spaces }
  SkipWhitespace();

  { Exit if nothing to do }
  if LCurrChar <> #0 then
  begin
    { Detect the sign of the number }
    LSign := ReadSign();
    if LCurrChar <> #0 then
    begin
      { De result }
      LResult := 0;

      { Read the integer and fractionary parts }
      ReadNumber(LResult);
      if LCurrChar = AFormatSettings.DecimalSeparator then
      begin
        NextChar();
        LPower := -ReadNumber(LResult);
      end else
        LPower := 0;

      { Read the exponent and adjust the power }
      if Char(Word(LCurrChar) and $FFDF) = CExponent then
      begin
        NextChar();
        Inc(LPower, ReadExponent());
      end;

      { Skip white spaces }
      SkipWhitespace();

      { Continue only if the buffer is depleted }
      if LCurrChar = #0 then
      begin
        { Calculate the final number }
        LResult := Power10(LResult, LPower) * LSign;

        if AValueType = fvCurrency then
          Currency(AValue) := LResult
        else
          Extended(AValue) := LResult;

{$IFDEF CPUX86}
        { Final check that everything went OK }
        Result := TestAndClearFPUExceptions(mIE + mOE);
{$ENDIF CPUX86}
{$IFDEF CPUX64}
        { Final check that everything went OK }
        Result := TestAndClearSSEExceptions(mIE + mOE);
{$ENDIF CPUX64}
      end;
    end;
  end;

  { Clear Math Exceptions }
{$IFDEF CPUX86}
  Set8087CW(LSavedCtrlWord);
{$ENDIF CPUX86}
{$IFDEF CPUX64}
  SetMXCSR(LSavedMXCSR);
{$ENDIF CPUX64}
end;

function TextToFloat(Buffer: PWideChar; var Value; ValueType: TFloatValue): Boolean;
begin
  Result := TextToFloat(Buffer, Value, ValueType, FormatSettings);
end;

function TextToFloat(Buffer: PWideChar; var Value;
  ValueType: TFloatValue; const AFormatSettings: TFormatSettings): Boolean;
begin
  { Call internal helper. Assuming the buffer is Unicode. }
  Result := InternalTextToFloat(PByte(Buffer), True, Value, ValueType, AFormatSettings);
end;

function TextToFloat(Buffer: PAnsiChar; var Value; ValueType: TFloatValue): Boolean;
begin
  Result := TextToFloat(Buffer, Value, ValueType, FormatSettings);
end;

function TextToFloat(Buffer: PAnsiChar; var Value;
  ValueType: TFloatValue; const AFormatSettings: TFormatSettings): Boolean;
begin
  { Call internal helper. Assuming the buffer is ANSI. }
  Result := InternalTextToFloat(PByte(Buffer), False, Value, ValueType, AFormatSettings);
end;

function FloatToStr(Value: Extended): string;
begin
  Result := FloatToStr(Value, FormatSettings);
end;

function FloatToStr(Value: Extended; const AFormatSettings: TFormatSettings): string;
var
  Buffer: array[0..63] of Char;
begin
  SetString(Result, Buffer, FloatToText(Buffer, Value, fvExtended,
    ffGeneral, 15, 0, AFormatSettings));
end;

function CurrToStr(Value: Currency): string;
begin
  Result := CurrToStr(Value, FormatSettings);
end;

function CurrToStr(Value: Currency;
  const AFormatSettings: TFormatSettings): string;
var
  Buffer: array[0..63] of Char;
begin
  SetString(Result, Buffer, FloatToText(Buffer, Value, fvCurrency,
    ffGeneral, 0, 0, AFormatSettings));
end;

function TryFloatToCurr(const Value: Extended; out AResult: Currency): Boolean;
begin
  Result := (Value >= MinCurrency) and (Value <= MaxCurrency);
  if Result then
    AResult := Value;
end;

function FloatToCurr(const Value: Extended): Currency;
begin
  if not TryFloatToCurr(Value, Result) then
    ConvertErrorFmt(@SInvalidCurrency, [FloatToStr(Value)]);
end;

function FloatToStrF(Value: Extended; Format: TFloatFormat;
  Precision, Digits: Integer): string;
begin
  Result := FloatToStrF(Value, Format, Precision, Digits, FormatSettings);
end;

function FloatToStrF(Value: Extended; Format: TFloatFormat;
  Precision, Digits: Integer; const AFormatSettings: TFormatSettings): string;
var
  Buffer: array[0..63] of Char;
begin
  SetString(Result, Buffer, FloatToText(Buffer, Value, fvExtended,
    Format, Precision, Digits, AFormatSettings));
end;

function CurrToStrF(Value: Currency; Format: TFloatFormat; Digits: Integer): string;
begin
  Result := CurrToStrF(Value, Format, Digits, FormatSettings);
end;

function CurrToStrF(Value: Currency; Format: TFloatFormat;
  Digits: Integer; const AFormatSettings: TFormatSettings): string;
var
  Buffer: array[0..63] of Char;
begin
  SetString(Result, Buffer, FloatToText(Buffer, Value, fvCurrency,
    Format, 0, Digits, AFormatSettings));
end;

function FormatFloat(const Format: string; Value: Extended): string;
begin
  Result := FormatFloat(Format, Value, FormatSettings);
end;

function FormatFloat(const Format: string; Value: Extended;
  const AFormatSettings: TFormatSettings): string;
var
  Buffer: array[0..255] of Char;
begin
  if Length(Format) > Length(Buffer) - 32 then ConvertError(@SFormatTooLong);
  SetString(Result, Buffer, FloatToTextFmt(Buffer, Value, fvExtended,
    PChar(Format), AFormatSettings));
end;

function FormatCurr(const Format: string; Value: Currency): string;
begin
  Result := FormatCurr(Format, Value, FormatSettings);
end;

function FormatCurr(const Format: string; Value: Currency;
  const AFormatSettings: TFormatSettings): string;
var
  Buffer: array[0..255] of Char;
begin
  if Length(Format) > Length(Buffer) - 32 then ConvertError(@SFormatTooLong);
  SetString(Result, Buffer, FloatToTextFmt(Buffer, Value, fvCurrency,
    PChar(Format), AFormatSettings));
end;

function StrToFloat(const S: string): Extended;
begin
  Result := StrToFloat(S, FormatSettings);
end;

function StrToFloat(const S: string;
  const AFormatSettings: TFormatSettings): Extended;
begin
  if not TextToFloat(PChar(S), Result, fvExtended, AFormatSettings) then
    ConvertErrorFmt(@SInvalidFloat, [S]);
end;

function StrToFloatDef(const S: string; const Default: Extended): Extended;
begin
  Result := StrToFloatDef(S, Default, FormatSettings);
end;

function StrToFloatDef(const S: string; const Default: Extended;
  const AFormatSettings: TFormatSettings): Extended;
begin
  if not TextToFloat(PChar(S), Result, fvExtended, AFormatSettings) then
    Result := Default;
end;

function TryStrToFloat(const S: string; out Value: Extended): Boolean;
begin
  Result := TryStrToFloat(S, Value, FormatSettings);
end;

function TryStrToFloat(const S: string; out Value: Extended;
  const AFormatSettings: TFormatSettings): Boolean;
begin
  Result := TextToFloat(PChar(S), Value, fvExtended, AFormatSettings);
end;

function TryStrToFloat(const S: string; out Value: Double): Boolean;
begin
  Result := TryStrToFloat(S, Value, FormatSettings);
end;

function TryStrToFloat(const S: string; out Value: Double;
  const AFormatSettings: TFormatSettings): Boolean;
var
  LValue: Extended;
begin
  Result := TextToFloat(PChar(S), LValue, fvExtended, AFormatSettings);
  if Result then
    if (LValue < -MaxDouble) or (LValue > MaxDouble) then
      Result := False;
  if Result then
    Value := LValue;
end;

function TryStrToFloat(const S: string; out Value: Single): Boolean;
begin
  Result := TryStrToFloat(S, Value, FormatSettings);
end;

function TryStrToFloat(const S: string; out Value: Single;
  const AFormatSettings: TFormatSettings): Boolean;
var
  LValue: Extended;
begin
  Result := TextToFloat(PChar(S), LValue, fvExtended, AFormatSettings);
  if Result then
    if (LValue < -MaxSingle) or (LValue > MaxSingle) then
      Result := False;
  if Result then
    Value := LValue;
end;

function StrToCurr(const S: string): Currency;
begin
  Result := StrToCurr(S, FormatSettings);
end;

function StrToCurr(const S: string;
  const AFormatSettings: TFormatSettings): Currency;
begin
  if not TextToFloat(PChar(S), Result, fvCurrency, AFormatSettings) then
    ConvertErrorFmt(@SInvalidFloat, [S]);
end;

function StrToCurrDef(const S: string; const Default: Currency): Currency;
begin
  Result := StrToCurrDef(S, Default, FormatSettings);
end;

function StrToCurrDef(const S: string; const Default: Currency;
  const AFormatSettings: TFormatSettings): Currency;
begin
  if not TextToFloat(PChar(S), Result, fvCurrency, AFormatSettings) then
    Result := Default;
end;

function TryStrToCurr(const S: string; out Value: Currency): Boolean;
begin
  Result := TryStrToCurr(S, Value, FormatSettings);
end;

function TryStrToCurr(const S: string; out Value: Currency;
  const AFormatSettings: TFormatSettings): Boolean;
begin
  Result := TextToFloat(PChar(S), Value, fvCurrency, AFormatSettings);
end;

{ Date/time support routines }

const
  FMSecsPerDay: Single = MSecsPerDay;
  IMSecsPerDay: Integer = MSecsPerDay;

// #281569 [vk]
procedure ValidateTimeStampDate(const TimeStampDate: Integer);
begin
  if (TimeStampDate <= 0) then
    raise EInvalidOp.Create(SInvalidOp);
end;

function DateTimeToTimeStamp(DateTime: TDateTime): TTimeStamp;
var
  LTemp, LTemp2: Int64;
begin
  LTemp := Round(DateTime * FMSecsPerDay);
  LTemp2 := (LTemp div IMSecsPerDay);
  Result.Date := DateDelta + LTemp2;
  Result.Time := Abs(LTemp) mod IMSecsPerDay;
end;

procedure ValidateTimeStamp(const TimeStamp: TTimeStamp);
begin
  if (TimeStamp.Time < 0) or (TimeStamp.Date <= 0) or
     (TimeStamp.Time >= IMSecsPerDay) then
    ConvertErrorFmt(@SInvalidTimeStamp, [TimeStamp.Date, TimeStamp.Time]);
end;

procedure ValidateMSec(const MSec: Comp);
begin
  if MSec = 0 then
    ConvertErrorFmt(@SInvalidTimeStamp, [0, 0]);
end;

function TimeStampToDateTime(const TimeStamp: TTimeStamp): TDateTime;
var
  Temp: Int64;
begin
  ValidateTimeStamp(TimeStamp);
  Temp := TimeStamp.Date;
  Dec(Temp, DateDelta);
  Temp := Temp * IMSecsPerDay;

  if Temp >= 0 then
    Inc(Temp, TimeStamp.Time)
  else
    Dec(Temp, TimeStamp.Time);

  Result := Temp / FMSecsPerDay;
end;

function MSecsToTimeStamp(MSecs: Comp): TTimeStamp;
begin
  ValidateMSec(MSecs);
  { This check is required in order be compatible with ASM version }
  if MSecs < 0 then
    System.Error(reDivByZero);

  Result.Date := PUInt64(@MSecs)^ div IMSecsPerDay;
  Result.Time := PUInt64(@MSecs)^ mod IMSecsPerDay;
end;

function TimeStampToMSecs(const TimeStamp: TTimeStamp): Comp;
begin
  ValidateTimeStamp(TimeStamp);

  Result := TimeStamp.Date;
  Result := (Result * FMSecsPerDay) + TimeStamp.Time;
end;

{ Time encoding and decoding }

function TryEncodeTime(Hour, Min, Sec, MSec: Word; out Time: TDateTime): Boolean;
var
  TS: TTimeStamp;
begin
  Result := False;
  if (Hour < HoursPerDay) and (Min < MinsPerHour) and (Sec < SecsPerMin) and (MSec < MSecsPerSec) then
  begin
    TS.Time :=  (Hour * (MinsPerHour * SecsPerMin * MSecsPerSec))
              + (Min * SecsPerMin * MSecsPerSec)
              + (Sec * MSecsPerSec)
              +  MSec;
    TS.Date := DateDelta; // This is the "zero" day for a TTimeStamp, days between 1/1/0001 and 12/30/1899 including the latter date
    Time := TimeStampToDateTime(TS);
    Result := True;
  end;
end;

function EncodeTime(Hour, Min, Sec, MSec: Word): TDateTime;
begin
  if not TryEncodeTime(Hour, Min, Sec, MSec, Result) then
    ConvertError(@STimeEncodeError);
end;

procedure DecodeTime(const DateTime: TDateTime; var Hour, Min, Sec, MSec: Word);
var
  MinCount, MSecCount: Word;
begin
  DivMod(DateTimeToTimeStamp(DateTime).Time, SecsPerMin * MSecsPerSec, MinCount, MSecCount);
  DivMod(MinCount, MinsPerHour, Hour, Min);
  DivMod(MSecCount, MSecsPerSec, Sec, MSec);
end;

{ Date encoding and decoding }

function IsLeapYear(Year: Word): Boolean;
begin
  Result := (Year mod 4 = 0) and ((Year mod 100 <> 0) or (Year mod 400 = 0));
end;

function TryEncodeDate(Year, Month, Day: Word; out Date: TDateTime): Boolean;
var
  I: Integer;
  DayTable: PDayTable;
begin
  Result := False;
  DayTable := @MonthDays[IsLeapYear(Year)];
  if (Year >= 1) and (Year <= 9999) and (Month >= 1) and (Month <= 12) and
    (Day >= 1) and (Day <= DayTable^[Month]) then
  begin
    for I := 1 to Month - 1 do Inc(Day, DayTable^[I]);
    I := Year - 1;
    Date := I * 365 + I div 4 - I div 100 + I div 400 + Day - DateDelta;
    Result := True;
  end;
end;

function EncodeDate(Year, Month, Day: Word): TDateTime;
begin
  if not TryEncodeDate(Year, Month, Day, Result) then
    ConvertError(@SDateEncodeError);
end;

function DecodeDateFully(const DateTime: TDateTime; var Year, Month, Day, DOW: Word): Boolean;
const
  D1 = 365;
  D4 = D1 * 4 + 1;
  D100 = D4 * 25 - 1;
  D400 = D100 * 4 + 1;
var
  Y, M, D, I: Word;
  T: Integer;
  DayTable: PDayTable;
begin
  T := DateTimeToTimeStamp(DateTime).Date;
  if T <= 0 then
  begin
    Year := 0;
    Month := 0;
    Day := 0;
    DOW := 0;
    Result := False;
  end else
  begin
    DOW := T mod 7 + 1;
    Dec(T);
    Y := 1;
    while T >= D400 do
    begin
      Dec(T, D400);
      Inc(Y, 400);
    end;
    DivMod(T, D100, I, D);
    if I = 4 then
    begin
      Dec(I);
      Inc(D, D100);
    end;
    Inc(Y, I * 100);
    DivMod(D, D4, I, D);
    Inc(Y, I * 4);
    DivMod(D, D1, I, D);
    if I = 4 then
    begin
      Dec(I);
      Inc(D, D1);
    end;
    Inc(Y, I);
    Result := IsLeapYear(Y);
    DayTable := @MonthDays[Result];
    M := 1;
    while True do
    begin
      I := DayTable^[M];
      if D < I then Break;
      Dec(D, I);
      Inc(M);
    end;
    Year := Y;
    Month := M;
    Day := D + 1;
  end;
end;

procedure DecodeDate(const DateTime: TDateTime; var Year, Month, Day: Word);
var
  Dummy: Word;
begin
  DecodeDateFully(DateTime, Year, Month, Day, Dummy);
end;

procedure DateTimeToSystemTime(const DateTime: TDateTime; var SystemTime: TSystemTime);
begin
  with SystemTime do
  begin
    DecodeDateFully(DateTime, wYear, wMonth, wDay, wDayOfWeek);
    Dec(wDayOfWeek);
    DecodeTime(DateTime, wHour, wMinute, wSecond, wMilliseconds);
  end;
end;

function SystemTimeToDateTime(const SystemTime: TSystemTime): TDateTime;
begin
  with SystemTime do
  begin
    Result := EncodeDate(wYear, wMonth, wDay);
    if Result >= 0 then
      Result := Result + EncodeTime(wHour, wMinute, wSecond, wMilliSeconds)
    else
      Result := Result - EncodeTime(wHour, wMinute, wSecond, wMilliSeconds);
  end;
end;

function TrySystemTimeToDateTime(const SystemTime: TSystemTime; out DateTime: TDateTime): Boolean;
var
  LDateTime: TDateTime;
begin
  with SystemTime do
  begin
    Result := TryEncodeDate(wYear, wMonth, wDay, DateTime);
    if Result then
    begin
      Result := TryEncodeTime(wHour, wMinute, wSecond, wMilliSeconds, LDateTime);
      if DateTime >= 0 then
        DateTime := DateTime + LDateTime
      else
        DateTime := DateTime - LDateTime;
    end;
  end;
end;

function DayOfWeek(const DateTime: TDateTime): Word;
begin
  Result := DateTimeToTimeStamp(DateTime).Date mod 7 + 1;
end;

function Date: TDateTime;
var
  SystemTime: TSystemTime;
begin
  GetLocalTime(SystemTime);
  with SystemTime do Result := EncodeDate(wYear, wMonth, wDay);
end;

function Time: TDateTime;
var
  SystemTime: TSystemTime;
begin
  GetLocalTime(SystemTime);
  with SystemTime do
    Result := EncodeTime(wHour, wMinute, wSecond, wMilliSeconds);
end;

function GetTime: TDateTime;
begin
  Result := Time;
end;

function Now: TDateTime;
var
  SystemTime: TSystemTime;
begin
  GetLocalTime(SystemTime);
  with SystemTime do
    Result := EncodeDate(wYear, wMonth, wDay) +
      EncodeTime(wHour, wMinute, wSecond, wMilliseconds);
end;

function IncMonth(const DateTime: TDateTime; NumberOfMonths: Integer): TDateTime;
var
  Year, Month, Day: Word;
begin
  DecodeDate(DateTime, Year, Month, Day);
  IncAMonth(Year, Month, Day, NumberOfMonths);
  Result := EncodeDate(Year, Month, Day);
  ReplaceTime(Result, DateTime);
end;

procedure IncAMonth(var Year, Month, Day: Word; NumberOfMonths: Integer = 1);
var
  DayTable: PDayTable;
  Sign: Integer;
begin
  if NumberOfMonths >= 0 then Sign := 1 else Sign := -1;
  Year := Year + (NumberOfMonths div 12);
  NumberOfMonths := NumberOfMonths mod 12;
  Inc(Month, NumberOfMonths);
  if Word(Month-1) > 11 then    // if Month <= 0, word(Month-1) > 11)
  begin
    Inc(Year, Sign);
    Inc(Month, -12 * Sign);
  end;
  DayTable := @MonthDays[IsLeapYear(Year)];
  if Day > DayTable^[Month] then Day := DayTable^[Month];
end;

procedure ReplaceTime(var DateTime: TDateTime; const NewTime: TDateTime);
begin
  DateTime := Trunc(DateTime);
  if DateTime >= 0 then
    DateTime := DateTime + Abs(Frac(NewTime))
  else
    DateTime := DateTime - Abs(Frac(NewTime));
end;

procedure ReplaceDate(var DateTime: TDateTime; const NewDate: TDateTime);
var
  Temp: TDateTime;
begin
  Temp := NewDate;
  ReplaceTime(Temp, DateTime);
  DateTime := Temp;
end;

function CurrentYear: Word;
var
  SystemTime: TSystemTime;
begin
  GetLocalTime(SystemTime);
  Result := SystemTime.wYear;
end;

{ Date/time to string conversions }

procedure DateTimeToString(var Result: string; const Format: string;
  DateTime: TDateTime);
begin
  DateTimeToString(Result, Format, DateTime, FormatSettings);
end;

procedure DateTimeToString(var Result: string; const Format: string;
  DateTime: TDateTime; const AFormatSettings: TFormatSettings);
const
  BufSize = 256;
var
  BufPosStatic, BufPosDynamic, AppendLevel: Integer;
  BufferStatic: array[0..BufSize-1] of Char;
  BufferDynamic: array of Char;
  UseStatic: Boolean;
  I: Integer;

  procedure AppendChars(P: PChar; Count: Integer);
  var
    NumChars: Integer;
  begin
    if Count > 0 then
    begin
      if UseStatic then
      begin
        NumChars := SizeOf(BufferStatic) div SizeOf(Char);
        if BufPosStatic + Count > NumChars then
          UseStatic := false
        else
        begin
          Move(P[0], BufferStatic[BufPosStatic], Count * SizeOf(Char));
          Inc(BufPosStatic, Count);
        end
      end;
      if not UseStatic then
      begin
        NumChars := Length(BufferDynamic);
        while BufPosDynamic + Count > NumChars do
    begin
          NumChars := NumChars + BufSize;
          SetLength(BufferDynamic, NumChars);
        end;
        Move(P[0], BufferDynamic[BufPosDynamic], Count * SizeOf(Char));
        Inc(BufPosDynamic, Count);
      end;
    end;
  end;

  procedure AppendString(const S: string);
  begin
    AppendChars(Pointer(S), Length(S));
  end;

  procedure AppendNumber(Number, Digits: Integer);
  const
    Format: array[0..3] of Char = '%.*d';
  var
    NumBuf: array[0..15] of Char;
  begin
    AppendChars(NumBuf, FormatBuf(NumBuf, Length(NumBuf), Format,
      Length(Format), [Digits, Number]));
  end;

  procedure AppendFormat(Format: PChar);
  var
    Starter, Token, LastToken: Char;
    DateDecoded, TimeDecoded, Use12HourClock,
    BetweenQuotes: Boolean;
    P: PChar;
    Count: Integer;
    Year, Month, Day, Hour, Min, Sec, MSec, H: Word;

    procedure GetCount;
    var
      P: PChar;
    begin
      P := Format;
      while Format^ = Starter do Inc(Format);
      Count := Format - P + 1;
    end;

    procedure GetDate;
    begin
      if not DateDecoded then
      begin
        DecodeDate(DateTime, Year, Month, Day);
        DateDecoded := True;
      end;
    end;

    procedure GetTime;
    begin
      if not TimeDecoded then
      begin
        DecodeTime(DateTime, Hour, Min, Sec, MSec);
        TimeDecoded := True;
      end;
    end;

    function ConvertEraString(const Count: Integer) : string;
    var
      FormatStr: string;
      SystemTime: TSystemTime;
      Buffer: array[Byte] of Char;
      P: PChar;
    begin
      Result := '';
      with SystemTime do
      begin
        wYear  := Year;
        wMonth := Month;
        wDay   := Day;
      end;

      FormatStr := 'gg';
      if GetDateFormat(GetThreadLocale, DATE_USE_ALT_CALENDAR, @SystemTime,
        PChar(FormatStr), Buffer, SizeOf(Buffer)) <> 0 then
      begin
        Result := Buffer;
        if Count = 1 then
        begin
          case SysLocale.PriLangID of
            LANG_JAPANESE:
              Result := Copy(Result, 1, CharToBytelen(Result, 1));
            LANG_CHINESE:
              if (SysLocale.SubLangID = SUBLANG_CHINESE_TRADITIONAL)
                and (ByteToCharLen(Result, Length(Result)) = 4) then
              begin
                P := Buffer + CharToByteIndex(Result, 3) - 1;
                SetString(Result, P, CharToByteLen(P, 2));
              end;
          end;
        end;
      end;
    end;

    function ConvertYearString(const Count: Integer): string;
    var
      FormatStr: string;
      SystemTime: TSystemTime;
      Buffer: array[Byte] of Char;
    begin
      Result := '';
      with SystemTime do
      begin
        wYear  := Year;
        wMonth := Month;
        wDay   := Day;
      end;

      if Count <= 2 then
        FormatStr := 'yy' // avoid Win95 bug.
      else
        FormatStr := 'yyyy';

      if GetDateFormat(GetThreadLocale, DATE_USE_ALT_CALENDAR, @SystemTime,
        PChar(FormatStr), Buffer, SizeOf(Buffer)) <> 0 then
      begin
        Result := Buffer;
        if (Count = 1) and (Result[1] = '0') then
          Result := Copy(Result, 2, Length(Result)-1);
      end;
    end;

  begin
    if (Format <> nil) and (AppendLevel < 2) then
    begin
      Inc(AppendLevel);
      LastToken := ' ';
      DateDecoded := False;
      TimeDecoded := False;
      Use12HourClock := False;
      while Format^ <> #0 do
      begin
        Starter := Format^;
        if IsLeadChar(Starter) then
        begin
          AppendChars(Format, StrCharLength(Format) div SizeOf(Char));
          Format := StrNextChar(Format);
          LastToken := ' ';
          Continue;
        end;
        Format := StrNextChar(Format);
        Token := Starter;
        if Token in ['a'..'z'] then Dec(Token, 32);
        if Token in ['A'..'Z'] then
        begin
          if (Token = 'M') and (LastToken = 'H') then Token := 'N';
          LastToken := Token;
        end;
        case Token of
          'Y':
            begin
              GetCount;
              GetDate;
              if Count <= 2 then
                AppendNumber(Year mod 100, 2) else
                AppendNumber(Year, 4);
            end;
          'G':
            begin
              GetCount;
              GetDate;
              AppendString(ConvertEraString(Count));
            end;
          'E':
            begin
              GetCount;
              GetDate;
              AppendString(ConvertYearString(Count));
            end;
          'M':
            begin
              GetCount;
              GetDate;
              case Count of
                1, 2: AppendNumber(Month, Count);
                3: AppendString(AFormatSettings.ShortMonthNames[Month]);
              else
                AppendString(AFormatSettings.LongMonthNames[Month]);
              end;
            end;
          'D':
            begin
              GetCount;
              case Count of
                1, 2:
                  begin
                    GetDate;
                    AppendNumber(Day, Count);
                  end;
                3: AppendString(AFormatSettings.ShortDayNames[DayOfWeek(DateTime)]);
                4: AppendString(AFormatSettings.LongDayNames[DayOfWeek(DateTime)]);
                5: AppendFormat(Pointer(AFormatSettings.ShortDateFormat));
              else
                AppendFormat(Pointer(AFormatSettings.LongDateFormat));
              end;
            end;
          'H':
            begin
              GetCount;
              GetTime;
              BetweenQuotes := False;
              P := Format;
              while P^ <> #0 do
              begin
                if IsLeadChar(P^) then
                begin
                  P := StrNextChar(P);
                  Continue;
                end;
                case P^ of
                  'A', 'a':
                    if not BetweenQuotes then
                    begin
                      if ( (StrLIComp(P, 'AM/PM', 5) = 0)
                        or (StrLIComp(P, 'A/P',   3) = 0)
                        or (StrLIComp(P, 'AMPM',  4) = 0) ) then
                        Use12HourClock := True;
                      Break;
                    end;
                  'H', 'h':
                    Break;
                  '''', '"': BetweenQuotes := not BetweenQuotes;
                end;
                Inc(P);
              end;
              H := Hour;
              if Use12HourClock then
                if H = 0 then H := 12 else if H > 12 then Dec(H, 12);
              if Count > 2 then Count := 2;
              AppendNumber(H, Count);
            end;
          'N':
            begin
              GetCount;
              GetTime;
              if Count > 2 then Count := 2;
              AppendNumber(Min, Count);
            end;
          'S':
            begin
              GetCount;
              GetTime;
              if Count > 2 then Count := 2;
              AppendNumber(Sec, Count);
            end;
          'T':
            begin
              GetCount;
              if Count = 1 then
                AppendFormat(Pointer(AFormatSettings.ShortTimeFormat)) else
                AppendFormat(Pointer(AFormatSettings.LongTimeFormat));
            end;
          'Z':
            begin
              GetCount;
              GetTime;
              if Count > 3 then Count := 3;
              AppendNumber(MSec, Count);
            end;
          'A':
            begin
              GetTime;
              P := Format - 1;
              if StrLIComp(P, 'AM/PM', 5) = 0 then
              begin
                if Hour >= 12 then Inc(P, 3);
                AppendChars(P, 2);
                Inc(Format, 4);
                Use12HourClock := TRUE;
              end else
              if StrLIComp(P, 'A/P', 3) = 0 then
              begin
                if Hour >= 12 then Inc(P, 2);
                AppendChars(P, 1);
                Inc(Format, 2);
                Use12HourClock := TRUE;
              end else
              if StrLIComp(P, 'AMPM', 4) = 0 then
              begin
                if Hour < 12 then
                  AppendString(AFormatSettings.TimeAMString) else
                  AppendString(AFormatSettings.TimePMString);
                Inc(Format, 3);
                Use12HourClock := TRUE;
              end else
              if StrLIComp(P, 'AAAA', 4) = 0 then
              begin
                GetDate;
                AppendString(AFormatSettings.LongDayNames[DayOfWeek(DateTime)]);
                Inc(Format, 3);
              end else
              if StrLIComp(P, 'AAA', 3) = 0 then
              begin
                GetDate;
                AppendString(AFormatSettings.ShortDayNames[DayOfWeek(DateTime)]);
                Inc(Format, 2);
              end else
              AppendChars(@Starter, 1);
            end;
          'C':
            begin
              GetCount;
              AppendFormat(Pointer(AFormatSettings.ShortDateFormat));
              GetTime;
              if (Hour <> 0) or (Min <> 0) or (Sec <> 0) then
              begin
                AppendChars(' ', 1);
                AppendFormat(Pointer(AFormatSettings.LongTimeFormat));
              end;
            end;
          '/':
            if AFormatSettings.DateSeparator <> #0 then
              AppendChars(@AFormatSettings.DateSeparator, 1);
          ':':
            if AFormatSettings.TimeSeparator <> #0 then
              AppendChars(@AFormatSettings.TimeSeparator, 1);
          '''', '"':
            begin
              P := Format;
              while (Format^ <> #0) and (Format^ <> Starter) do
              begin
                if IsLeadChar(Format^) then
                  Format := StrNextChar(Format)
                else
                  Inc(Format);
              end;
              AppendChars(P, Format - P);
              if Format^ <> #0 then Inc(Format);
            end;
        else
          AppendChars(@Starter, 1);
        end;
      end;
      Dec(AppendLevel);
    end;
  end;

begin
  BufPosStatic := 0;
  BufPosDynamic := 0;
  UseStatic := True;
  SetLength(BufferDynamic, 0);
  AppendLevel := 0;
  if Format <> '' then AppendFormat(Pointer(Format)) else AppendFormat('C');
  SetString(Result, BufferStatic, BufPosStatic);
  if BufPosDynamic > 0 then
  begin
    for I := 0 to BufPosDynamic - 1 do
      Result := Result + BufferDynamic[i];
    SetLength(BufferDynamic, 0);
  end;
end;

function TryFloatToDateTime(const Value: Extended; out AResult: TDateTime): Boolean;
begin
  Result := not ((Value < MinDateTime) or (Value >= Int(MaxDateTime) + 1.0));
  if Result then
    AResult := Value;
end;

function FloatToDateTime(const Value: Extended): TDateTime;
begin
  if not TryFloatToDateTime(Value, Result) then
    ConvertErrorFmt(@SInvalidDateTimeFloat, [Value]);
end;

function DateToStr(const DateTime: TDateTime): string;
begin
  Result := DateToStr(DateTime, FormatSettings);
end;

function DateToStr(const DateTime: TDateTime;
  const AFormatSettings: TFormatSettings): string;
begin
  DateTimeToString(Result, AFormatSettings.ShortDateFormat, DateTime,
    AFormatSettings);
end;

function TimeToStr(const DateTime: TDateTime): string;
begin
  Result := TimeToStr(DateTime, FormatSettings);
end;

function TimeToStr(const DateTime: TDateTime;
  const AFormatSettings: TFormatSettings): string;
begin
  DateTimeToString(Result, AFormatSettings.LongTimeFormat, DateTime,
    AFormatSettings);
end;

function DateTimeToStr(const DateTime: TDateTime): string;
begin
  Result := DateTimeToStr(DateTime, FormatSettings);
end;

function DateTimeToStr(const DateTime: TDateTime;
  const AFormatSettings: TFormatSettings): string;
begin
  DateTimeToString(Result, '', DateTime, AFormatSettings);
end;

function FormatDateTime(const Format: string; DateTime: TDateTime): string;
begin
  Result := FormatDateTime(Format, DateTime, FormatSettings);
end;

function FormatDateTime(const Format: string; DateTime: TDateTime;
  const AFormatSettings: TFormatSettings): string;
begin
  DateTimeToString(Result, Format, DateTime, AFormatSettings);
end;

{ String to date/time conversions }

type
  TDateOrder = (doMDY, doDMY, doYMD);

procedure ScanBlanks(const S: string; var Pos: Integer);
var
  I: Integer;
begin
  I := Pos;
  while (I <= Length(S)) and (S[I] = ' ') do Inc(I);
  Pos := I;
end;

function ScanNumber(const S: string; var Pos: Integer;
  var Number: Word; var CharCount: Byte): Boolean;
var
  I: Integer;
  N: Word;
begin
  Result := False;
  CharCount := 0;
  ScanBlanks(S, Pos);
  I := Pos;
  N := 0;
  while (I <= Length(S)) and (S[I] in ['0'..'9']) and (N < 1000) do
  begin
    N := N * 10 + (Ord(S[I]) - Ord('0'));
    Inc(I);
  end;
  if I > Pos then
  begin
    CharCount := I - Pos;
    Pos := I;
    Number := N;
    Result := True;
  end;
end;

function ScanString(const S: string; var Pos: Integer;
  const Symbol: string): Boolean;
begin
  Result := False;
  if Symbol <> '' then
  begin
    ScanBlanks(S, Pos);
    if AnsiCompareText(Symbol, Copy(S, Pos, Length(Symbol))) = 0 then
    begin
      Inc(Pos, Length(Symbol));
      Result := True;
    end;
  end;
end;

function ScanChar(const S: string; var Pos: Integer; Ch: Char): Boolean;
begin
  Result := False;
  ScanBlanks(S, Pos);
  if (Pos <= Length(S)) and (S[Pos] = Ch) then
  begin
    Inc(Pos);
    Result := True;
  end;
end;

function GetDateOrder(const DateFormat: string): TDateOrder;
var
  I: Integer;
begin
  Result := doMDY;
  I := 1;
  while I <= Length(DateFormat) do
  begin
    case Chr(Ord(DateFormat[I]) and $DF) of
      'E': Result := doYMD;
      'Y': Result := doYMD;
      'M': Result := doMDY;
      'D': Result := doDMY;
    else
      Inc(I);
      Continue;
    end;
    Exit;
  end;
end;

procedure ScanToNumber(const S: string; var Pos: Integer);
begin
  while (Pos <= Length(S)) and not (S[Pos] in ['0'..'9']) do
  begin
    if IsLeadChar(S[Pos]) then
      Pos := NextCharIndex(S, Pos)
    else
      Inc(Pos);
  end;
end;

function GetEraYearOffset(const Name: string): Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := Low(EraNames) to High(EraNames) do
  begin
    if EraNames[I] = '' then Break;
    if AnsiStrPos(PChar(EraNames[I]), PChar(Name)) <> nil then
    begin
      Result := EraYearOffsets[I];
      Exit;
    end;
  end;
end;

function ScanDate(const S: string; var Pos: Integer; var Date: TDateTime;
  const AFormatSettings: TFormatSettings): Boolean; overload;
var
  DateOrder: TDateOrder;
  N1, N2, N3, Y, M, D: Word;
  L1, L2, L3, YearLen: Byte;
  CenturyBase: Integer;
  EraName : string;
  EraYearOffset: Integer;

  function EraToYear(Year: Integer): Integer;
  begin
    if SysLocale.PriLangID = LANG_KOREAN then
    begin
      if Year <= 99 then
        Inc(Year, (CurrentYear + Abs(EraYearOffset)) div 100 * 100);
      if EraYearOffset > 0 then
        EraYearOffset := -EraYearOffset;
    end
    else
      Dec(EraYearOffset);
    Result := Year + EraYearOffset;
  end;

begin
  Y := 0;
  M := 0;
  D := 0;
  YearLen := 0;
  Result := False;
  DateOrder := GetDateOrder(AFormatSettings.ShortDateFormat);
  EraYearOffset := 0;
  if AFormatSettings.ShortDateFormat[1] = 'g' then  // skip over prefix text
  begin
    ScanToNumber(S, Pos);
    EraName := Trim(Copy(S, 1, Pos-1));
    EraYearOffset := GetEraYearOffset(EraName);
  end
  else
    if AnsiPos('e', AFormatSettings.ShortDateFormat) > 0 then
      EraYearOffset := EraYearOffsets[1];
  if not (ScanNumber(S, Pos, N1, L1) and ScanChar(S, Pos, AFormatSettings.DateSeparator) and
    ScanNumber(S, Pos, N2, L2)) then Exit;
  if ScanChar(S, Pos, AFormatSettings.DateSeparator) then
  begin
    if not ScanNumber(S, Pos, N3, L3) then Exit;
    case DateOrder of
      doMDY: begin Y := N3; YearLen := L3; M := N1; D := N2; end;
      doDMY: begin Y := N3; YearLen := L3; M := N2; D := N1; end;
      doYMD: begin Y := N1; YearLen := L1; M := N2; D := N3; end;
    end;
    if EraYearOffset > 0 then
      Y := EraToYear(Y)
    else
    if (YearLen <= 2) then
    begin
      CenturyBase := CurrentYear - AFormatSettings.TwoDigitYearCenturyWindow;
      Inc(Y, CenturyBase div 100 * 100);
      if (AFormatSettings.TwoDigitYearCenturyWindow > 0) and (Y < CenturyBase) then
        Inc(Y, 100);
    end;
  end else
  begin
    Y := CurrentYear;
    if DateOrder = doDMY then
    begin
      D := N1; M := N2;
    end else
    begin
      M := N1; D := N2;
    end;
  end;
  ScanChar(S, Pos, AFormatSettings.DateSeparator);
  ScanBlanks(S, Pos);
  if SysLocale.FarEast and (System.Pos('ddd', AFormatSettings.ShortDateFormat) <> 0) then
  begin     // ignore trailing text
    if AFormatSettings.ShortTimeFormat[1] in ['0'..'9'] then  // stop at time digit
      ScanToNumber(S, Pos)
    else  // stop at time prefix
      repeat
        while (Pos <= Length(S)) and (S[Pos] <> ' ') do Inc(Pos);
        ScanBlanks(S, Pos);
      until (Pos > Length(S)) or
        (AnsiCompareText(AFormatSettings.TimeAMString,
         Copy(S, Pos, Length(AFormatSettings.TimeAMString))) = 0) or
        (AnsiCompareText(AFormatSettings.TimePMString,
         Copy(S, Pos, Length(AFormatSettings.TimePMString))) = 0);
  end;
  Result := TryEncodeDate(Y, M, D, Date);
end;

function ScanTime(const S: string; var Pos: Integer; var Time: TDateTime;
  const AFormatSettings: TFormatSettings): Boolean; overload;
var
  BaseHour: Integer;
  Hour, Min, Sec, MSec: Word;
  Junk: Byte;
begin
  Result := False;
  BaseHour := -1;
  if ScanString(S, Pos, AFormatSettings.TimeAMString) or ScanString(S, Pos, 'AM') then
    BaseHour := 0
  else if ScanString(S, Pos, AFormatSettings.TimePMString) or ScanString(S, Pos, 'PM') then
    BaseHour := 12;
  if BaseHour >= 0 then ScanBlanks(S, Pos);
  if not ScanNumber(S, Pos, Hour, Junk) then Exit;
  Min := 0;
  Sec := 0;
  MSec := 0;
  if ScanChar(S, Pos, AFormatSettings.TimeSeparator) then
  begin
    if not ScanNumber(S, Pos, Min, Junk) then Exit;
    if ScanChar(S, Pos, AFormatSettings.TimeSeparator) then
    begin
      if not ScanNumber(S, Pos, Sec, Junk) then Exit;
      if ScanChar(S, Pos, AFormatSettings.DecimalSeparator) then
        if not ScanNumber(S, Pos, MSec, Junk) then Exit;
    end;
  end;
  if BaseHour < 0 then
    if ScanString(S, Pos, AFormatSettings.TimeAMString) or ScanString(S, Pos, 'AM') then
      BaseHour := 0
    else
      if ScanString(S, Pos, AFormatSettings.TimePMString) or ScanString(S, Pos, 'PM') then
        BaseHour := 12;
  if BaseHour >= 0 then
  begin
    if (Hour = 0) or (Hour > 12) then Exit;
    if Hour = 12 then Hour := 0;
    Inc(Hour, BaseHour);
  end;
  ScanBlanks(S, Pos);
  Result := TryEncodeTime(Hour, Min, Sec, MSec, Time);
end;

function StrToDate(const S: string): TDateTime;
begin
  Result := StrToDate(S, FormatSettings);
end;

function StrToDate(const S: string;
  const AFormatSettings: TFormatSettings): TDateTime;
begin
  if not TryStrToDate(S, Result, AFormatSettings) then
    ConvertErrorFmt(@SInvalidDate, [S]);
end;

function StrToDateDef(const S: string; const Default: TDateTime): TDateTime;
begin
  Result := StrToDateDef(S, Default, FormatSettings);
end;

function StrToDateDef(const S: string; const Default: TDateTime;
  const AFormatSettings: TFormatSettings): TDateTime;
begin
  if not TryStrToDate(S, Result, AFormatSettings) then
    Result := Default;
end;

function TryStrToDate(const S: string; out Value: TDateTime): Boolean;
begin
  Result := TryStrToDate(S, Value, FormatSettings);
end;

function TryStrToDate(const S: string; out Value: TDateTime;
  const AFormatSettings: TFormatSettings): Boolean;
var
  Pos: Integer;
begin
  Pos := 1;
  Result := ScanDate(S, Pos, Value, AFormatSettings) and (Pos > Length(S));
end;

function StrToTime(const S: string): TDateTime;
begin
  Result := StrToTime(S, FormatSettings);
end;

function StrToTime(const S: string;
  const AFormatSettings: TFormatSettings): TDateTime;
begin
  if not TryStrToTime(S, Result, AFormatSettings) then
    ConvertErrorFmt(@SInvalidTime, [S]);
end;

function StrToTimeDef(const S: string; const Default: TDateTime): TDateTime;
begin
  Result := StrToTimeDef(S, Default, FormatSettings);
end;

function StrToTimeDef(const S: string; const Default: TDateTime;
  const AFormatSettings: TFormatSettings): TDateTime;
begin
  if not TryStrToTime(S, Result, AFormatSettings) then
    Result := Default;
end;

function TryStrToTime(const S: string; out Value: TDateTime): Boolean;
begin
  Result := TryStrToTime(S, Value, FormatSettings);
end;

function TryStrToTime(const S: string; out Value: TDateTime;
  const AFormatSettings: TFormatSettings): Boolean;
var
  Pos: Integer;
begin
  Pos := 1;
  Result := ScanTime(S, Pos, Value, AFormatSettings) and (Pos > Length(S));
end;

function StrToDateTime(const S: string): TDateTime;
begin
  Result := StrToDateTime(S, FormatSettings);
end;

function StrToDateTime(const S: string;
  const AFormatSettings: TFormatSettings): TDateTime;
begin
  if not TryStrToDateTime(S, Result, AFormatSettings) then
    ConvertErrorFmt(@SInvalidDateTime, [S]);
end;

function StrToDateTimeDef(const S: string; const Default: TDateTime): TDateTime;
begin
  Result := StrToDateTimeDef(S, Default, FormatSettings);
end;

function StrToDateTimeDef(const S: string; const Default: TDateTime;
  const AFormatSettings: TFormatSettings): TDateTime;
begin
  if not TryStrToDateTime(S, Result, AFormatSettings) then
    Result := Default;
end;

function TryStrToDateTime(const S: string; out Value: TDateTime): Boolean;
begin
  Result := TryStrToDateTime(S, Value, FormatSettings);
end;

function TryStrToDateTime(const S: string; out Value: TDateTime;
  const AFormatSettings: TFormatSettings): Boolean;
var
  Pos: Integer;
  NumberPos: Integer;
  BlankPos, OrigBlankPos: Integer;
  LDate, LTime: TDateTime;
  Stop: Boolean;
begin
  Result := True;
  Pos := 1;
  LTime := 0;

  // jump over all the non-numeric characters before the date data
  ScanToNumber(S, Pos);

  // date data scanned; searched for the time data
  if ScanDate(S, Pos, LDate, AFormatSettings) then
  begin
    // search for time data; search for the first number in the time data
    NumberPos := Pos;
    ScanToNumber(S, NumberPos);

    // the first number of the time data was found
    if NumberPos < Length(S) then
    begin
      // search between the end of date and the start of time for AM and PM
      // strings; if found, then ScanTime from this position where it is found
      BlankPos := Pos - 1;
      Stop := False;
      while (not Stop) and (BlankPos < NumberPos) do
      begin
        // blank was found; scan for AM/PM strings that may follow the blank
        if (BlankPos > 0) and (BlankPos < NumberPos) then
        begin
          Inc(BlankPos); // start after the blank
          OrigBlankPos := BlankPos; // keep BlankPos because ScanString modifies it
          Stop := ScanString(S, BlankPos, AFormatSettings.TimeAMString) or
                  ScanString(S, BlankPos, 'AM') or
                  ScanString(S, BlankPos, AFormatSettings.TimePMString) or
                  ScanString(S, BlankPos, 'PM');

          // ScanString jumps over the AM/PM string; if found, then it is needed
          // by ScanTime to correctly scan the time
          BlankPos := OrigBlankPos;
        end
        // no more blanks found; end the loop
        else
          Stop := True;

        // search of the next blank if no AM/PM string has been found
        if not Stop then
        begin
          while (S[BlankPos] <> ' ') and (BlankPos <= Length(S)) do
            Inc(BlankPos);
          if BlankPos > Length(S) then
            BlankPos := 0;
        end;
      end;

      // loop was forcely stopped; check if AM/PM has been found
      if Stop then
        // AM/PM has been found; check if it is before or after the time data
        if BlankPos > 0 then
          if BlankPos < NumberPos then // AM/PM is before the time number
            Pos := BlankPos
          else
            Pos := NumberPos // AM/PM is after the time number
        else
          Pos := NumberPos
      // the blank found is after the the first number in time data
      else
        Pos := NumberPos;

      // get the time data
      Result := ScanTime(S, Pos, LTime, AFormatSettings);

      // time data scanned with no errors
      if Result then
        if LDate >= 0 then
          Value := LDate + LTime
        else
          Value := LDate - LTime;
    end
    // no time data; return only date data
    else
      Value := LDate;
  end
  // could not scan date data; try to scan time data
  else
    Result := TryStrToTime(S, Value, AFormatSettings)
end;

{ System error messages }

function SysErrorMessage(ErrorCode: Cardinal): string;
var
  Buffer: PChar;
  Len: Integer;
begin
  { Obtain the formatted message for the given Win32 ErrorCode
    Let the OS initialize the Buffer variable. Need to LocalFree it afterward.
  }
  Len := FormatMessage(
    FORMAT_MESSAGE_FROM_SYSTEM or
    FORMAT_MESSAGE_IGNORE_INSERTS or
    FORMAT_MESSAGE_ARGUMENT_ARRAY or
    FORMAT_MESSAGE_ALLOCATE_BUFFER, nil, ErrorCode, 0, @Buffer, 0, nil);

  try
    { Remove the undesired line breaks and '.' char }
    while (Len > 0) and (CharInSet(Buffer[Len - 1], [#0..#32, '.'])) do Dec(Len);
    { Convert to Delphi string }
    SetString(Result, Buffer, Len);
  finally
    { Free the OS allocated memory block }
    LocalFree(HLOCAL(Buffer));
  end;
end;

{ Initialization file support }

function GetLocaleStr(Locale, LocaleType: Integer; const Default: string): string;
var
  L: Integer;
  Buffer: array[0..255] of Char;
begin
  L := GetLocaleInfo(Locale, LocaleType, Buffer, Length(Buffer));
  if L > 0 then SetString(Result, Buffer, L - 1) else Result := Default;
end;

function GetLocaleChar(Locale, LocaleType: Integer; Default: Char): Char;
var
  Buffer: array[0..1] of Char;
begin
  if GetLocaleInfo(Locale, LocaleType, Buffer, 2) > 0 then
    Result := Buffer[0] else
    Result := Default;
end;

var
  DefShortMonthNames: array[1..12] of Pointer = (@SShortMonthNameJan,
    @SShortMonthNameFeb, @SShortMonthNameMar, @SShortMonthNameApr,
    @SShortMonthNameMay, @SShortMonthNameJun, @SShortMonthNameJul,
    @SShortMonthNameAug, @SShortMonthNameSep, @SShortMonthNameOct,
    @SShortMonthNameNov, @SShortMonthNameDec);

  DefLongMonthNames: array[1..12] of Pointer = (@SLongMonthNameJan,
    @SLongMonthNameFeb, @SLongMonthNameMar, @SLongMonthNameApr,
    @SLongMonthNameMay, @SLongMonthNameJun, @SLongMonthNameJul,
    @SLongMonthNameAug, @SLongMonthNameSep, @SLongMonthNameOct,
    @SLongMonthNameNov, @SLongMonthNameDec);

  DefShortDayNames: array[1..7] of Pointer = (@SShortDayNameSun,
    @SShortDayNameMon, @SShortDayNameTue, @SShortDayNameWed,
    @SShortDayNameThu, @SShortDayNameFri, @SShortDayNameSat);

  DefLongDayNames: array[1..7] of Pointer = (@SLongDayNameSun,
    @SLongDayNameMon, @SLongDayNameTue, @SLongDayNameWed,
    @SLongDayNameThu, @SLongDayNameFri, @SLongDayNameSat);

{ TFormatSettings }

class function TFormatSettings.Create(Locale: TLocaleID): TFormatSettings;
var
  HourFormat, TimePrefix, TimePostfix: string;
begin
  if not IsValidLocale(Locale, LCID_INSTALLED) then
    Locale := GetThreadLocale;

  GetDayNames(Locale, Result);
  GetMonthNames(Locale, Result);
  with Result do
  begin
    CurrencyString := GetLocaleStr(Locale, LOCALE_SCURRENCY, '');
    CurrencyFormat := StrToIntDef(GetLocaleStr(Locale, LOCALE_ICURRENCY, '0'), 0);
    NegCurrFormat := StrToIntDef(GetLocaleStr(Locale, LOCALE_INEGCURR, '0'), 0);
    ThousandSeparator := GetLocaleChar(Locale, LOCALE_STHOUSAND, ',');
    DecimalSeparator := GetLocaleChar(Locale, LOCALE_SDECIMAL, '.');
    CurrencyDecimals := StrToIntDef(GetLocaleStr(Locale, LOCALE_ICURRDIGITS, '0'), 0);
    DateSeparator := GetLocaleChar(Locale, LOCALE_SDATE, '/');
    ShortDateFormat := TranslateDateFormat(Locale, LOCALE_SSHORTDATE, 'm/d/yy', DateSeparator);
    LongDateFormat := TranslateDateFormat(Locale, LOCALE_SLONGDATE, 'mmmm d, yyyy', DateSeparator);
    TimeSeparator := GetLocaleChar(Locale, LOCALE_STIME, ':');
    TimeAMString := GetLocaleStr(Locale, LOCALE_S1159, 'am');
    TimePMString := GetLocaleStr(Locale, LOCALE_S2359, 'pm');
    TimePrefix := '';
    TimePostfix := '';
    if StrToIntDef(GetLocaleStr(Locale, LOCALE_ITLZERO, '0'), 0) = 0 then
      HourFormat := 'h'
    else
      HourFormat := 'hh';
    if StrToIntDef(GetLocaleStr(Locale, LOCALE_ITIME, '0'), 0) = 0 then
      if StrToIntDef(GetLocaleStr(Locale, LOCALE_ITIMEMARKPOSN, '0'), 0) = 0 then
        TimePostfix := ' AMPM'
      else
        TimePrefix := 'AMPM ';
    ShortTimeFormat := TimePrefix + HourFormat + ':mm' + TimePostfix;
    LongTimeFormat := TimePrefix + HourFormat + ':mm:ss' + TimePostfix;
    ListSeparator := GetLocaleChar(Locale, LOCALE_SLIST, ',');
    TwoDigitYearCenturyWindow := CDefaultTwoDigitYearCenturyWindow;
  end;
end;

class function TFormatSettings.Create(const LocaleName: string): TFormatSettings;
var
  Locale: LCID;
begin
  if LocaleName <> '' then
  begin
    if Win32MajorVersion >= 6 then
      // Windows Vista and later support a direct API call
      Locale := LocaleNameToLCID(PChar(AdjustLocaleName(LocaleName)), 0)
    else
      // Use TLanguages for older OS versions (slower)
      Locale := Languages.LocaleID[Languages.IndexOf(AdjustLocaleName(LocaleName))];
  end
  else
    Locale := GetThreadLocale;

  Result := Create(Locale);
end;

class function TFormatSettings.Create: TFormatSettings;
begin
  Result := TFormatSettings.Create('');
end;

class function TFormatSettings.AdjustLocaleName(const LocaleName: string): string;
const
  CLookup = '_';
  CReplace = '-';
var
  P: PChar;
begin
  Result := LocaleName;
  P := PChar(Result);
  while P^ <> #0 do
  begin
    if P^ = CLookup then
    begin
      P^ := CReplace;
      Break;
    end;
    Inc(P);
  end;
end;

class procedure TFormatSettings.GetDayNames(Locale: TLocaleID;
  var AFormatSettings: TFormatSettings);
const
  CShortName = LOCALE_SABBREVDAYNAME1;
  CLongName = LOCALE_SDAYNAME1;
var
  I, Day: Integer;
begin
  for I := 1 to 7 do
  begin
    Day := (I + 5) mod 7;
    AFormatSettings.ShortDayNames[I] := GetString(Locale,
      CShortName + Day, I - Low(DefShortDayNames), DefShortDayNames);
    AFormatSettings.LongDayNames[I] := GetString(Locale,
      CLongName + Day, I - Low(DefLongDayNames), DefLongDayNames);
  end;
end;

class procedure TFormatSettings.GetMonthNames(Locale: TLocaleID;
  var AFormatSettings: TFormatSettings);
const
  CShortName = LOCALE_SABBREVMONTHNAME1;
  CLongName = LOCALE_SMONTHNAME1;
var
  I: Integer;
begin
  for I := 1 to 12 do
  begin
    AFormatSettings.ShortMonthNames[I] := GetString(Locale,
      CShortName + I - 1, I - Low(DefShortMonthNames), DefShortMonthNames);
    AFormatSettings.LongMonthNames[I] := GetString(Locale,
      CLongName + I - 1, I - Low(DefLongMonthNames), DefLongMonthNames);
  end;
end;

class function TFormatSettings.GetString(Locale: TLocaleID; LocaleItem,
  DefaultIndex: Integer; const DefaultValues: array of Pointer): string;
begin
  Result := GetLocaleStr(Locale, LocaleItem, '');
  if Result = '' then
    Result := LoadResString(DefaultValues[DefaultIndex]);
end;

class function TFormatSettings.TranslateDateFormat(Locale: TLocaleID;
  LocaleType: Integer; const Default: string; const Separator: Char): string;
var
  I: Integer;
  L: Integer;
  CalendarType: CALTYPE;
  RemoveEra: Boolean;
  LFormat: string;

  procedure FixDateSeparator(var DateFormat: string);
  var
    P: PChar;
  begin
    P := PChar(DateFormat);
    if P = nil then
      Exit;

    while P^ <> #0 do
    begin
      if P^ = Separator then
        P^ := '/';
      Inc(P);
    end;
  end;

begin
  I := 1;
  Result := '';
  LFormat := GetLocaleStr(Locale, LocaleType, Default);
  CalendarType := StrToIntDef(GetLocaleStr(Locale, LOCALE_ICALENDARTYPE, '1'), 1);
  if not (CalendarType in [CAL_JAPAN, CAL_TAIWAN, CAL_KOREA]) then
  begin
    RemoveEra := SysLocale.PriLangID in [LANG_JAPANESE, LANG_CHINESE, LANG_KOREAN];
    if RemoveEra then
    begin
      While I <= Length(LFormat) do
      begin
        if not (LFormat[I] in ['g', 'G']) then
          Result := Result + LFormat[I];
        Inc(I);
      end;
    end
    else
      Result := LFormat;

    { Adjust the date separator accordingly }
    FixDateSeparator(Result);
    Exit;
  end;

  while I <= Length(LFormat) do
  begin
    if IsLeadChar(LFormat[I]) then
    begin
      L := CharLength(LFormat, I) div SizeOf(Char);
      Result := Result + Copy(LFormat, I, L);
      Inc(I, L);
    end else
    begin
      if StrLIComp(@LFormat[I], 'gg', 2) = 0 then
      begin
        Result := Result + 'ggg';
        Inc(I, 1);
      end
      else if StrLIComp(@LFormat[I], 'yyyy', 4) = 0 then
      begin
        Result := Result + 'eeee';
        Inc(I, 4-1);
      end
      else if StrLIComp(@LFormat[I], 'yy', 2) = 0 then
      begin
        Result := Result + 'ee';
        Inc(I, 2-1);
      end
      else if LFormat[I] in ['y', 'Y'] then
        Result := Result + 'e'
      else
        Result := Result + LFormat[I];
      Inc(I);
    end;
  end;

  { Adjust the date separator accordingly }
  FixDateSeparator(Result);
end;

function EnumEraNames(Names: PChar): Integer; stdcall;
var
  I: Integer;
begin
  Result := 0;
  I := Low(EraNames);
  while EraNames[I] <> '' do
    if (I = High(EraNames)) then
      Exit
    else Inc(I);
  EraNames[I] := Names;
  Result := 1;
end;

function EnumEraYearOffsets(YearOffsets: PChar): Integer; stdcall;
var
  I: Integer;
begin
  Result := 0;
  I := Low(EraYearOffsets);
  while EraYearOffsets[I] <> -1 do
    if (I = High(EraYearOffsets)) then
      Exit
    else Inc(I);
  EraYearOffsets[I] := StrToIntDef(YearOffsets, 0);
  Result := 1;
end;

procedure GetEraNamesAndYearOffsets;
var
  J: Integer;
  CalendarType: CALTYPE;
begin
  CalendarType := StrToIntDef(GetLocaleStr(GetThreadLocale,
    LOCALE_IOPTIONALCALENDAR, '1'), 1);
  if CalendarType in [CAL_JAPAN, CAL_TAIWAN, CAL_KOREA] then
  begin
    EnumCalendarInfo(@EnumEraNames, GetThreadLocale, CalendarType,
      CAL_SERASTRING);
    for J := Low(EraYearOffsets) to High(EraYearOffsets) do
      EraYearOffsets[J] := -1;
    EnumCalendarInfo(@EnumEraYearOffsets, GetThreadLocale, CalendarType,
      CAL_IYEAROFFSETRANGE);
  end;
end;

{ Exception handling routines }

var
  OutOfMemory: EOutOfMemory;
  InvalidPointer: EInvalidPointer;

{ Convert physical address to logical address }

{ Format and return an exception error message }

function ExceptionErrorMessage(ExceptObject: TObject; ExceptAddr: Pointer;
  Buffer: PChar; Size: Integer): Integer;

  function ConvertAddr(Address: Pointer): Pointer;
  begin
    Result := Address;
    if Result <> nil then
      Dec(PByte(Result), $1000);
  end;

var
  MsgPtr: PChar;
  MsgEnd: PChar;
  MsgLen: Integer;
  ModuleName: array[0..MAX_PATH] of Char;
  Temp: array[0..MAX_PATH] of Char;
  Format: array[0..255] of Char;
  Info: TMemoryBasicInformation;
  ConvertedAddress: Pointer;
begin
  VirtualQuery(ExceptAddr, Info, sizeof(Info));
  if (Info.State <> MEM_COMMIT) or
    (GetModuleFilename(THandle(Info.AllocationBase), Temp, Length(Temp)) = 0) then
  begin
    GetModuleFileName(HInstance, Temp, Length(Temp));
    ConvertedAddress := ConvertAddr(ExceptAddr);
  end
  else
    NativeInt(ConvertedAddress) := NativeInt(ExceptAddr) - NativeInt(Info.AllocationBase);
  StrLCopy(ModuleName, AnsiStrRScan(Temp, '\') + 1, Length(ModuleName) - 1);
  MsgPtr := '';
  MsgEnd := '';
  if ExceptObject is Exception then
  begin
    MsgPtr := PChar(Exception(ExceptObject).Message);
    MsgLen := StrLen(MsgPtr);
    if (MsgLen <> 0) and (MsgPtr[MsgLen - 1] <> '.') then MsgEnd := '.';
  end;
  LoadString(FindResourceHInstance(HInstance),
    PResStringRec(@SException).Identifier, Format, Length(Format));
  StrLFmt(Buffer, Size, Format, [ExceptObject.ClassName, ModuleName,
    ConvertedAddress, MsgPtr, MsgEnd]);
  Result := StrLen(Buffer);
end;

{ Display exception message box }

                                                                                  
procedure ShowException(ExceptObject: TObject; ExceptAddr: Pointer);
var
  Title: array[0..63] of Char;
  Buffer: array[0..1023] of Char;
  OemBuffer: array of AnsiChar;
  BufSize, OemBufSize: Integer;
  Dummy: Cardinal;
begin
  BufSize := ExceptionErrorMessage(ExceptObject, ExceptAddr, Buffer, Length(Buffer));
  if IsConsole then
  begin
    Flush(Output);
    OemBufSize := WideCharToMultiByte(CP_OEMCP, 0, Buffer, BufSize, nil, 0, nil, nil);
    SetLength(OemBuffer, OemBufSize);
    WideCharToMultiByte(CP_OEMCP, 0, Buffer, BufSize, @OemBuffer[0], OemBufSize, nil, nil);
    WriteFile(GetStdHandle(STD_ERROR_HANDLE), OemBuffer[0], OemBufSize, Dummy, nil);
    WriteFile(GetStdHandle(STD_ERROR_HANDLE), sLineBreak, 2, Dummy, nil);
  end
  else
  begin
    LoadString(FindResourceHInstance(HInstance), PResStringRec(@SExceptTitle).Identifier,
      Title, Length(Title));
    MessageBox(0, Buffer, Title, MB_OK or MB_ICONSTOP or MB_TASKMODAL);
  end;
end;

{ Raise abort exception }

procedure Abort;
begin
  raise EAbort.CreateRes(@SOperationAborted);
end;

{ Raise out of memory exception }

procedure OutOfMemoryError;
begin
  raise OutOfMemory;
end;

{ Exception class }

constructor Exception.Create(const Msg: string);
begin
  FMessage := Msg;
end;

constructor Exception.CreateFmt(const Msg: string;
  const Args: array of const);
begin
  FMessage := Format(Msg, Args);
end;

constructor Exception.CreateRes(Ident: Integer);
begin
  FMessage := LoadStr(Ident);
end;

constructor Exception.CreateRes(ResStringRec: PResStringRec);
begin
  FMessage := LoadResString(ResStringRec);
end;

constructor Exception.CreateResFmt(Ident: Integer;
  const Args: array of const);
begin
  FMessage := Format(LoadStr(Ident), Args);
end;

constructor Exception.CreateResFmt(ResStringRec: PResStringRec;
  const Args: array of const);
begin
  FMessage := Format(LoadResString(ResStringRec), Args);
end;

constructor Exception.CreateHelp(const Msg: string; AHelpContext: Integer);
begin
  FMessage := Msg;
  FHelpContext := AHelpContext;
end;

constructor Exception.CreateFmtHelp(const Msg: string; const Args: array of const;
  AHelpContext: Integer);
begin
  FMessage := Format(Msg, Args);
  FHelpContext := AHelpContext;
end;

constructor Exception.CreateResHelp(Ident: Integer; AHelpContext: Integer);
begin
  FMessage := LoadStr(Ident);
  FHelpContext := AHelpContext;
end;

constructor Exception.CreateResHelp(ResStringRec: PResStringRec;
  AHelpContext: Integer);
begin
  FMessage := LoadResString(ResStringRec);
  FHelpContext := AHelpContext;
end;

constructor Exception.CreateResFmtHelp(Ident: Integer;
  const Args: array of const;
  AHelpContext: Integer);
begin
  FMessage := Format(LoadStr(Ident), Args);
  FHelpContext := AHelpContext;
end;

constructor Exception.CreateResFmtHelp(ResStringRec: PResStringRec;
  const Args: array of const;
  AHelpContext: Integer);
begin
  FMessage := Format(LoadResString(ResStringRec), Args);
  FHelpContext := AHelpContext;
end;

destructor Exception.Destroy;
begin
  FreeAndNil(FInnerException);
  if Assigned(CleanupStackInfoProc) then
    CleanupStackInfoProc(FStackInfo);
  FStackInfo := nil;
  inherited Destroy;
end;

function Exception.GetBaseException: Exception;
begin
  Result := Self;
  while Result.InnerException <> nil do
    Result := Result.InnerException;
end;

function Exception.GetStackTrace: string;
begin
  if Assigned(GetStackInfoStringProc) then
    Result := GetStackInfoStringProc(FStackInfo)
  else
    Result := '';
end;

class procedure Exception.RaiseOuterException(E: Exception);
begin
  if E <> nil then
    E.FAcquireInnerException := True;
  raise E;
end;

class procedure Exception.ThrowOuterException(E: Exception);
begin
  if E <> nil then
    E.FAcquireInnerException := True;
  raise E;
end;

procedure Exception.RaisingException(P: PExceptionRecord);
begin
  SetInnerException;
  if Assigned(GetExceptionStackInfoProc) then
    SetStackInfo(GetExceptionStackInfoProc(P));
end;

procedure Exception.SetInnerException;
begin
  if FAcquireInnerException and (TObject(ExceptObject) is Exception) then
    FInnerException := AcquireExceptionObject;
end;

procedure Exception.SetStackInfo(AStackInfo: Pointer);
begin
  FStackInfo := AStackInfo;
end;

function Exception.ToString: string;
var
  Inner: Exception;
begin
  Inner := Self;
  Result := '';
  while Inner <> nil do
  begin
    if Result <> '' then
      Result := Result + sLineBreak + Inner.Message
    else
      Result := Inner.Message;
    Inner := Inner.InnerException;
  end;
end;

{ EHeapException class }

procedure EHeapException.FreeInstance;
begin
  if AllowFree then
    inherited FreeInstance;
end;

procedure EHeapException.RaisingException(P: PExceptionRecord);
begin
  SetInnerException;
  // Don't try to get a stack trace since that may involve heap operations which at this point
  // would probably be a "bad thing" to do.
end;

{ Create I/O exception }

function CreateInOutError: EInOutError;
type
  TErrorRec = record
    Code: Integer;
    Ident: string;
  end;
const
  ErrorMap: array[0..6] of TErrorRec = (
    (Code: 2; Ident: SFileNotFound),
    (Code: 3; Ident: SInvalidFilename),
    (Code: 4; Ident: STooManyOpenFiles),
    (Code: 5; Ident: SAccessDenied),
    (Code: 100; Ident: SEndOfFile),
    (Code: 101; Ident: SDiskFull),
    (Code: 106; Ident: SInvalidInput));
var
  I: Integer;
  InOutRes: Integer;
begin
  I := Low(ErrorMap);
  InOutRes := IOResult;  // resets IOResult to zero
  while (I <= High(ErrorMap)) and (ErrorMap[I].Code <> InOutRes) do Inc(I);
  if I <= High(ErrorMap) then
    Result := EInOutError.Create(ErrorMap[I].Ident) else
    Result := EInOutError.CreateResFmt(@SInOutError, [InOutRes]);
  Result.ErrorCode := InOutRes;
end;

{ RTL error handler }

procedure ErrorHandler(ErrorCode: Byte; ErrorAddr: Pointer); export;
var
  E: Exception;
begin
  case ErrorCode of
    Ord(reOutOfMemory):
      E := OutOfMemory;
    Ord(reInvalidPtr):
      E := InvalidPointer;
    Ord(reDivByZero)..Ord(High(TRuntimeError)):
      begin
        with ExceptMap[ErrorCode] do
          E := ExceptTypes[EClass].Create(EIdent);
      end;
  else
    E := CreateInOutError;
  end;
  if ErrorAddr <> nil then
    raise E at ErrorAddr
  else
    raise E;
end;

{ Assertion error handler }
procedure AssertErrorHandler(const Message, Filename: string;
  LineNumber: Integer; ErrorAddr: Pointer);
begin
  if Message <> '' then
    raise EAssertionFailed.CreateFmt(SAssertError,
      [Message, Filename, LineNumber]) at ErrorAddr
  else
    raise EAssertionFailed.CreateFmt(SAssertError,
      [SAssertionFailed, Filename, LineNumber]) at ErrorAddr;
end;

{ Abstract method invoke error handler }

procedure AbstractErrorHandler;
begin
  raise EAbstractError.CreateRes(@SAbstractError);
end;

function MapException(P: PExceptionRecord): TRuntimeError;
begin
  case P.ExceptionCode of
    STATUS_INTEGER_DIVIDE_BY_ZERO:
      Result := System.reDivByZero;
    STATUS_ARRAY_BOUNDS_EXCEEDED:
      Result := System.reRangeError;
    STATUS_INTEGER_OVERFLOW:
      Result := System.reIntOverflow;
    STATUS_FLOAT_INEXACT_RESULT,
    STATUS_FLOAT_INVALID_OPERATION,
    STATUS_FLOAT_STACK_CHECK:
      Result := System.reInvalidOp;
    STATUS_FLOAT_DIVIDE_BY_ZERO:
      Result := System.reZeroDivide;
    STATUS_FLOAT_OVERFLOW:
      Result := System.reOverflow;
    STATUS_FLOAT_UNDERFLOW,
    STATUS_FLOAT_DENORMAL_OPERAND:
      Result := System.reUnderflow;
    STATUS_ACCESS_VIOLATION:
      Result := System.reAccessViolation;
    STATUS_PRIVILEGED_INSTRUCTION:
      Result := System.rePrivInstruction;
    STATUS_CONTROL_C_EXIT:
      Result := System.reControlBreak;
    STATUS_STACK_OVERFLOW:
      Result := System.reStackOverflow;
    else
      Result := System.reExternalException;
  end;
end;

function GetExceptionClass(P: PExceptionRecord): ExceptClass;
var
  ErrorCode: Byte;
begin
  ErrorCode := Byte(MapException(P));
  Result := ExceptTypes[ExceptMap[ErrorCode].EClass];
end;

function GetExceptionObject(P: PExceptionRecord): Exception;
var
  ErrorCode: Integer;

  function CreateAVObject: Exception;
  var
    AccessOp: string; // string ID indicating the access type READ or WRITE
    AccessAddress: Pointer;
    MemInfo: TMemoryBasicInformation;
    ModName: array[0..MAX_PATH] of Char;
  begin
    with P^ do
    begin
      if ExceptionInformation[0] = 0 then
        AccessOp := SReadAccess
      else
        AccessOp := SWriteAccess;
      AccessAddress := Pointer(ExceptionInformation[1]);
      VirtualQuery(ExceptionAddress, MemInfo, SizeOf(MemInfo));
      if (MemInfo.State = MEM_COMMIT) and
         (GetModuleFileName(THandle(MemInfo.AllocationBase), ModName, Length(ModName)) <> 0) then
        Result := EAccessViolation.CreateFmt(sModuleAccessViolation,
          [ExceptionAddress, ExtractFileName(ModName), AccessOp,
          AccessAddress])
      else
        Result := EAccessViolation.CreateFmt(SAccessViolationArg3,
          [ExceptionAddress, AccessOp, AccessAddress]);
    end;
  end;

begin
  ErrorCode := Byte(MapException(P));
  case ErrorCode of
    3..10, 12..21:
      with ExceptMap[ErrorCode] do Result := ExceptTypes[EClass].Create(EIdent);
    11: Result := CreateAVObject;
  else
    Result := EExternalException.CreateFmt(SExternalException, [P.ExceptionCode]);
  end;
  if Result is EExternal then EExternal(Result).ExceptionRecord := P;
  Result.RaisingException(P);
end;

procedure RaiseExceptObject(P: PExceptionRecord);
begin
  if TObject(P.ExceptObject) is Exception then
    Exception(P.ExceptObject).RaisingException(P);
end;

{ RTL exception handler }

procedure ExceptHandler(ExceptObject: TObject; ExceptAddr: Pointer); far;
begin
  ShowException(ExceptObject, ExceptAddr);
  Halt(1);
end;

procedure InitExceptions;
begin
  OutOfMemory := EOutOfMemory.CreateRes(@SOutOfMemory);
  InvalidPointer := EInvalidPointer.CreateRes(@SInvalidPointer);
  ErrorProc := ErrorHandler;
  ExceptProc := @ExceptHandler;
  ExceptionClass := Exception;

  ExceptClsProc := @GetExceptionClass;
  ExceptObjProc := @GetExceptionObject;
  RaiseExceptObjProc := @RaiseExceptObject;

  AssertErrorProc := @AssertErrorHandler;
  AbstractErrorProc := @AbstractErrorHandler;
end;

procedure DoneExceptions;
begin
  if Assigned(OutOfMemory) then
  begin
    OutOfMemory.AllowFree := True;
    OutOfMemory.FreeInstance;
    OutOfMemory := nil;
  end;
  if Assigned(InvalidPointer) then
  begin
    InvalidPointer.AllowFree := True;
    InvalidPointer.Free;
    InvalidPointer := nil;
  end;
  ErrorProc := nil;
  ExceptProc := nil;
  ExceptionClass := nil;
  ExceptClsProc := nil;
  ExceptObjProc := nil;
  AssertErrorProc := nil;
end;

class constructor Exception.Create;
begin
  InitExceptions;
end;

class destructor Exception.Destroy;
begin
  DoneExceptions;
end;

function NewSyncWaitObj: Pointer; inline;
begin
  Result := Pointer(CreateEvent(nil, False, False, nil));
end;

procedure DeleteSyncWaitObj(P: Pointer); inline;
begin
  CloseHandle(THandle(P));
end;

procedure SignalSyncWaitObj(P: Pointer); inline;
begin
  SetEvent(THandle(P));
end;

procedure ResetSyncWaitObj(P: Pointer); inline;
begin
  ResetEvent(THandle(P));
end;

function WaitForSyncWaitObj(P: Pointer; Timeout: Cardinal): Integer;
begin
  Result := WaitForSingleObject(THandle(P), Timeout);
end;

{ This section provides the required support to the TMonitor record in System. }
type
  PEventItemHolder = ^TEventItemHolder;
  TEventItemHolder = record
    Next: PEventItemHolder;
    Event: Pointer;
  end;

  TSyncEventItem = record
    Lock: Integer;
    Event: Pointer;
  end;

var
  SyncEventCache: array[0..31] of TSyncEventItem;
  EventCache: PEventItemHolder;
  EventItemHolders: PEventItemHolder;

procedure Push(var Stack: PEventItemHolder; EventItem: PEventItemHolder);
begin
  repeat
    EventItem.Next := Stack;
  until InterlockedCompareExchangePointer(Pointer(Stack), EventItem, EventItem.Next) = EventItem.Next;
end;

function Pop(var Stack: PEventItemHolder): PEventItemHolder;
begin
  repeat
    Result := Stack;
    if Result = nil then
      Exit;
  until InterlockedCompareExchangePointer(Pointer(Stack), Result.Next, Result) = Result;
end;

function NewSyncObj: Pointer;
var
  I: Integer;
begin
  Result := nil;
  for I := Low(SyncEventCache) to High(SyncEventCache) do
    if SyncEventCache[I].Lock = 0 then
    begin
      if InterlockedCompareExchange(SyncEventCache[I].Lock, 1, 0) <> 0 then
        Continue;
      if SyncEventCache[I].Event = nil then
        SyncEventCache[I].Event := NewSyncWaitObj;
      Result := SyncEventCache[I].Event;
      Exit;
    end;
  if Result = nil then
    Result := NewSyncWaitObj;
  ResetSyncWaitObj(Result);
end;

procedure FreeSyncObj(SyncObject: Pointer);
var
  I: Integer;
begin
  for I := Low(SyncEventCache) to High(SyncEventCache) do
    if SyncEventCache[I].Event = SyncObject then
    begin
      InterlockedExchange(SyncEventCache[I].Lock, 0);
      Exit;
    end;
  DeleteSyncWaitObj(SyncObject);
end;

function NewWaitObj: Pointer;
var
  EventItem: PEventItemHolder;
begin
  EventItem := Pop(EventCache);
  if EventItem <> nil then
  begin
    Result := EventItem.Event;
    EventItem.Event := nil;
    Push(EventItemHolders, EventItem);
  end else
    Result := NewSyncWaitObj;
  ResetSyncWaitObj(Result);
end;

procedure FreeWaitObj(WaitObject: Pointer);
var
  EventItem: PEventItemHolder;
begin
  EventItem := Pop(EventItemHolders);
  if EventItem = nil then
    New(EventItem);
  EventItem.Event := WaitObject;
  Push(EventCache, EventItem);
end;

function WaitOrSignalObj(SignalObject, WaitObject: Pointer; Timeout: Cardinal): Cardinal;
begin
  if (SignalObject <> nil) and (WaitObject = nil) then
  begin
    Result := 0;
    SignalSyncWaitObj(SignalObject);
  end else if (WaitObject <> nil) and (SignalObject = nil) then
    Result := WaitForSyncWaitObj(WaitObject, Timeout)
  else Result := 1;
end;

const
  MonitorSupport: TMonitorSupport = (
    NewSyncObject: NewSyncObj;
    FreeSyncObject: FreeSyncObj;
    NewWaitObject: NewWaitObj;
    FreeWaitObject: FreeWaitObj;
    WaitOrSignalObject: WaitOrSignalObj;
  );

procedure InitMonitorSupport;
begin
  System.MonitorSupport := @MonitorSupport;
end;

procedure DoneMonitorSupport;

  procedure CleanStack(Stack: PEventItemHolder);
  var
    Walker: PEventItemHolder;
  begin
    Walker := Stack;
    while Walker <> nil do
    begin
      Stack := Walker.Next;
      if Walker.Event <> nil then
        DeleteSyncWaitObj(Walker.Event);
      Dispose(Walker);
      Walker := Stack;
    end;
  end;

  procedure CleanEventList(var EventCache: array of TSyncEventItem);
  var
    I: Integer;
  begin
    for I := Low(EventCache) to High(EventCache) do
    begin
      repeat until InterlockedCompareExchange(EventCache[I].Lock, 1, 0) = 0;
      DeleteSyncWaitObj(EventCache[I].Event);
    end;
  end;

begin
  CleanStack(InterlockedExchangePointer(Pointer(EventCache), nil));
  CleanStack(InterlockedExchangePointer(Pointer(EventItemHolders), nil));
  CleanEventList(SyncEventCache);
end;

procedure InitPlatformId;
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
      if Win32Platform = VER_PLATFORM_WIN32_WINDOWS then
        Win32BuildNumber := dwBuildNumber and $FFFF
      else
        Win32BuildNumber := dwBuildNumber;
      Win32CSDVersion := szCSDVersion;
    end;
end;

function CheckWin32Version(AMajor: Integer; AMinor: Integer = 0): Boolean;
begin
  Result := (Win32MajorVersion > AMajor) or
            ((Win32MajorVersion = AMajor) and
             (Win32MinorVersion >= AMinor));
end;

function GetFileVersion(const AFileName: string): Cardinal;
var
  FileName: string;
  InfoSize, Wnd: DWORD;
  VerBuf: Pointer;
  FI: PVSFixedFileInfo;
  VerSize: DWORD;
begin
  Result := Cardinal(-1);
  // GetFileVersionInfo modifies the filename parameter data while parsing.
  // Copy the string const into a local variable to create a writeable copy.
  FileName := AFileName;
  UniqueString(FileName);
  InfoSize := GetFileVersionInfoSize(PChar(FileName), Wnd);
  if InfoSize <> 0 then
  begin
    GetMem(VerBuf, InfoSize);
    try
      if GetFileVersionInfo(PChar(FileName), Wnd, InfoSize, VerBuf) then
        if VerQueryValue(VerBuf, '\', Pointer(FI), VerSize) then
          Result:= FI.dwFileVersionMS;
    finally
      FreeMem(VerBuf);
    end;
  end;
end;

procedure Beep;
begin
  MessageBeep(0);
end;

{ MBCS functions }

function ByteTypeTest(P: PAnsiChar; Index: Integer): TMbcsByteType;
var
  I: Integer;
begin
  Result := mbSingleByte;
  if (P = nil) or (P[Index] = #$0) then Exit;
  if (Index = 0) then
  begin
    if IsLeadChar(P[0]) then Result := mbLeadByte;
  end
  else
  begin
    I := Index - 1;
    while (I >= 0) and IsLeadChar(P[I]) do Dec(I);
    if ((Index - I) mod 2) = 0 then Result := mbTrailByte
    else if IsLeadChar(P[Index]) then Result := mbLeadByte;
  end;
end;

function ByteType(const S: AnsiString; Index: Integer): TMbcsByteType;
begin
  Result := mbSingleByte;
  if SysLocale.FarEast then
    Result := ByteTypeTest(PAnsiChar(S), Index-1);
end;

function ByteType(const S: UnicodeString; Index: Integer): TMbcsByteType;
begin
  Result := mbSingleByte;
  if (Index > 0) and (Index <= Length(S)) and IsLeadChar(S[Index]) then
    if (S[Index] >= #$D800) and (S[Index] <= #$DBFF) then
      Result := mbLeadByte
    else
      Result := mbTrailByte;
end;

function StrByteType(Str: PAnsiChar; Index: Cardinal): TMbcsByteType;
begin
  Result := mbSingleByte;
  if SysLocale.FarEast then
    Result := ByteTypeTest(Str, Index);
end;

function StrByteType(Str: PWideChar; Index: Cardinal): TMbcsByteType;
begin
  Result := mbSingleByte;
  if IsLeadChar(Str[Index - 1]) then
    if (Str[Index - 1] >= #$D800) and (Str[Index - 1] <= #$DBFF) then
      Result := mbLeadByte
    else
      Result := mbTrailByte;
end;

function ElementToCharLen(const S: AnsiString; MaxLen: Integer): Integer;
begin
  if Length(S) < MaxLen then MaxLen := Length(S);
  Result := ByteToCharIndex(S, MaxLen);
end;

function ElementToCharLen(const S: UnicodeString; MaxLen: Integer): Integer;
begin
  if Length(S) < MaxLen then MaxLen := Length(S);
  Result := ByteToCharIndex(S, MaxLen);
end;

function ByteToCharLen(const S: AnsiString; MaxLen: Integer): Integer;
begin
  Result := ElementToCharLen(S, MaxLen);
end;

function ByteToCharLen(const S: UnicodeString; MaxLen: Integer): Integer;
begin
  Result := ElementToCharLen(S, MaxLen);
end;

function ElementToCharIndex(const S: AnsiString; Index: Integer): Integer;
var
  I: Integer;
begin
  Result := 0;
  if (Index <= 0) or (Index > Length(S)) then Exit;
  Result := Index;
  if not SysLocale.FarEast then Exit;
  I := 1;
  Result := 0;
  while I <= Index do
  begin
    if IsLeadChar(S[I]) then
      I := NextCharIndex(S, I)
    else
      Inc(I);
    Inc(Result);
  end;
end;

function ElementToCharIndex(const S: UnicodeString; Index: Integer): Integer;
var
  I: Integer;
begin
  Result := 0;
  if (Index <= 0) or (Index > Length(S)) then
    Exit;
  I := 1;
  while I <= Index do
  begin
    if IsLeadChar(S[I]) then
      I := NextCharIndex(S, I)
    else
      Inc(I);
    Inc(Result);
  end;
end;

function ByteToCharIndex(const S: AnsiString; Index: Integer): Integer;
begin
  Result := ElementToCharIndex(S, Index);
end;

function ByteToCharIndex(const S: UnicodeString; Index: Integer): Integer;
begin
  Result := ElementToCharIndex(S, Index);
end;

procedure CountChars(const S: AnsiString; MaxChars: Integer; var CharCount, ByteCount: Integer); overload;
var
  C, L, B: Integer;
begin
  L := Length(S) * SizeOf(Char);
  C := 1;
  B := 1;
  while (B < L) and (C < MaxChars) do
  begin
    Inc(C);
    if IsLeadChar(S[B]) then
      B := NextCharIndex(S, B)
    else
      Inc(B);
  end;
  if (C = MaxChars) and (B < L) and IsLeadChar(S[B]) then
    B := NextCharIndex(S, B) - 1;
  CharCount := C;
  ByteCount := B;
end;

procedure CountChars(const S: UnicodeString; MaxChars: Integer; var CharCount, ByteCount: Integer); overload;
var
  C, L, I: Integer;
begin
  L := Length(S);
  C := 1;
  I := 1;
  while (I < L) and (C < MaxChars) do
  begin
    Inc(C);
    if IsLeadChar(S[I]) then
    begin
      Inc(I, 2); //Jump the trailing surrogate
      if I > L then
      begin
        Dec(C);
        Dec(I);
      end;
    end
    else
      Inc(I);
  end;
  if (C = MaxChars) and (I < L) and IsLeadChar(S[I]) then
    I := NextCharIndex(S, I) - 1;

  CharCount := C;
  ByteCount := I;
end;

function CharToElementIndex(const S: AnsiString; Index: Integer): Integer;
var
  Chars: Integer;
begin
  Result := 0;
  if (Index <= 0) or (Index > Length(S)) then Exit;
  if (Index > 1) and SysLocale.FarEast then
  begin
    CountChars(S, Index-1, Chars, Result);
    if (Chars < (Index-1)) or (Result >= Length(S)) then
      Result := 0  // Char index out of range
    else
      Inc(Result);
  end
  else
    Result := Index;
end;

function CharToElementIndex(const S: UnicodeString; Index: Integer): Integer;
var
  Chars: Integer;
begin
  Result := 0;
  if (Index <= 0) or (Index > Length(S)) then
    Exit;
  CountChars(S, Index-1, Chars, Result);
  if (Chars < (Index-1)) or (Result >= Length(S)) then
    Result := 0  // Char index out of range
  else if (Index > 1) then
    Inc(Result);
end;

function CharToByteIndex(const S: AnsiString; Index: Integer): Integer;
begin
  Result := CharToElementIndex(S, Index);
end;

function CharToByteIndex(const S: UnicodeString; Index: Integer): Integer;
begin
  Result := CharToElementIndex(S, Index);
end;

function CharToElementLen(const S: AnsiString; MaxLen: Integer): Integer;
var
  Chars: Integer;
begin
  Result := 0;
  if MaxLen <= 0 then Exit;
  if MaxLen > Length(S) then MaxLen := Length(S);
  if SysLocale.FarEast then
  begin
    CountChars(S, MaxLen, Chars, Result);
    if Result > Length(S) then
      Result := Length(S);
  end
  else
    Result := MaxLen;
end;

function CharToElementLen(const S: UnicodeString; MaxLen: Integer): Integer;
var
  Chars: Integer;
begin
  Result := 0;
  if MaxLen <= 0 then Exit;
  if MaxLen > Length(S) then MaxLen := Length(S);
  CountChars(S, MaxLen, Chars, Result);
  if Result > Length(S) * SizeOf(Char) then
    Result := Length(S) * SizeOf(Char);
end;

function CharToByteLen(const S: AnsiString; MaxLen: Integer): Integer;
begin
  Result := CharToElementLen(S, MaxLen);
end;

function CharToByteLen(const S: UnicodeString; MaxLen: Integer): Integer;
begin
  Result := CharToElementLen(S, MaxLen);
end;

{ MBCS Helper functions }

function StrCharLength(const Str: PAnsiChar): Integer;
begin
  if SysLocale.FarEast and (Str^ <> #0) then
    Result := NativeInt(CharNextA(Str)) - NativeInt(Str)
  else
    Result := 1;
end;

function StrCharLength(const Str: PWideChar): Integer;
begin
  if (Str^ >= #$D800) and (Str^ <= #$DBFF) and
     (Str[1] >= #$DC00) and (Str[1] <= #$DFFF) then
    Result := SizeOf(WideChar) * 2
  else
    Result := SizeOf(WideChar);
end;

function StrNextChar(const Str: PAnsiChar): PAnsiChar;
begin
  Result := CharNextA(Str);
end;

function StrNextChar(const Str: PWideChar): PWideChar;
begin
  Result := Str;
  if (Result^ >= #$D800) and (Result^ <= #$DBFF) and
     (Result[1] >= #$DC00) and (Result[1] <= #$DFFF) then
    Inc(Result, 2)
  else if Result^ <> #0 then
    Inc(Result, 1);
end;

function CharLength(const S: UnicodeString; Index: Integer): Integer;
begin
  Result := SizeOf(WideChar);
  assert((Index > 0) and (Index <= Length(S)));
  if IsLeadChar(S[Index]) then
    Result := StrCharLength(PWideChar(S) + Index - 1);
end;

function CharLength(const S: AnsiString; Index: Integer): Integer;
begin
  Result := SizeOf(AnsiChar);
  assert((Index > 0) and (Index <= Length(S)));
  if IsLeadChar(S[Index]) then
    Result := StrCharLength(PAnsiChar(S) + Index - 1);
end;

function NextCharIndex(const S: UnicodeString; Index: Integer): Integer;
begin
  Result := Index + 1;
  assert((Index > 0) and (Index <= Length(S)));
  if IsLeadChar(S[Index]) then
    Result := Index + StrCharLength(PWideChar(S) + Index - 1) div SizeOf(WideChar);
end;

function NextCharIndex(const S: AnsiString; Index: Integer): Integer;
begin
  Result := Index + 1;
  assert((Index > 0) and (Index <= Length(S)));
  if IsLeadChar(S[Index]) then
    Result := Index + StrCharLength(PAnsiChar(S) + Index - 1);
end;

function IsPathDelimiter(const S: string; Index: Integer): Boolean;
begin
  Result := (Index > 0) and (Index <= Length(S)) and (S[Index] = PathDelim)
    and (ByteType(S, Index) = mbSingleByte);
end;

function IsDelimiter(const Delimiters, S: string; Index: Integer): Boolean;
begin
  Result := False;
  if (Index <= 0) or (Index > Length(S)) or (ByteType(S, Index) <> mbSingleByte) then exit;
  Result := StrScan(PChar(Delimiters), S[Index]) <> nil;
end;

function IncludeTrailingBackslash(const S: string): string;
begin
  Result := IncludeTrailingPathDelimiter(S);
end;

function IncludeTrailingPathDelimiter(const S: string): string;
begin
  Result := S;
  if not IsPathDelimiter(Result, Length(Result)) then
    Result := Result + PathDelim;
end;

function ExcludeTrailingBackslash(const S: string): string;
begin
  Result := ExcludeTrailingPathDelimiter(S);
end;

function ExcludeTrailingPathDelimiter(const S: string): string;
begin
  Result := S;
  if IsPathDelimiter(Result, Length(Result)) then
    SetLength(Result, Length(Result)-1);
end;

function AnsiPos(const Substr, S: string): Integer;
var
  P: PChar;
begin
  Result := 0;
{$IFDEF UNICODE}
  P := StrPosLen(PChar(S), PChar(SubStr), Length(S), Length(SubStr));
{$ELSE}
  P := AnsiStrPos(PChar(S), PChar(SubStr));
{$ENDIF}
  if P <> nil then
    Result := (NativeInt(P) - NativeInt(PChar(S))) div SizeOf(Char) + 1;
end;

function TextPos(Str, SubStr: PAnsiChar): PAnsiChar;
var
  LowerStr, LowerSubStr: PAnsiChar;
begin
  LowerSubStr := nil;
  LowerStr := StrLower(StrNew(Str));
  try
    LowerSubStr := StrLower(StrNew(SubStr));
    Result := StrPos(LowerStr, LowerSubStr);
    if Result <> nil then
      Result := PAnsiChar(PByte(Str) + (PByte(Result) - PByte(LowerStr)));
  finally
    StrDispose(LowerSubStr);
    StrDispose(LowerStr);
  end;
end;

function TextPos(Str, SubStr: PWideChar): PWideChar;
var
  LowerStr, LowerSubStr: PWideChar;
begin
  LowerSubStr := nil;
  LowerStr := StrLower(StrNew(Str));
  try
    LowerSubStr := StrLower(StrNew(SubStr));
    Result := StrPos(LowerStr, LowerSubStr);
    if Result <> nil then
      Result := PWideChar(PByte(Str) + (PByte(Result) - PByte(LowerStr)));
  finally
    StrDispose(LowerSubStr);
    StrDispose(LowerStr);
  end;
end;

function AnsiStrPos(Str, SubStr: PAnsiChar): PAnsiChar;
var
  L1, L2: Cardinal;
  ByteType : TMbcsByteType;
begin
  Result := nil;
  if (Str = nil) or (Str^ = #0) or (SubStr = nil) or (SubStr^ = #0) then Exit;
  L1 := StrLen(Str);
  L2 := StrLen(SubStr);
  Result := StrPos(Str, SubStr);
  while (Result <> nil) and ((L1 - Cardinal(Result - Str)) >= L2) do
  begin
    ByteType := StrByteType(Str, Integer(Result-Str));
    if (ByteType <> mbTrailByte) and
      (CompareStringA(LOCALE_USER_DEFAULT, 0, Result, L2, SubStr, L2) = CSTR_EQUAL) then Exit;
    if (ByteType = mbLeadByte) then Inc(Result);
    Inc(Result);
    Result := StrPos(Result, SubStr);
  end;
  Result := nil;
end;

function AnsiStrPos(Str, SubStr: PWideChar): PWideChar;
begin
  Result := StrPos(Str, SubStr);
end;

function AnsiStrRScan(Str: PAnsiChar; Chr: AnsiChar): PAnsiChar;
begin
  Str := AnsiStrScan(Str, Chr);
  Result := Str;
  if Chr <> AnsiChar(#$0) then
  begin
    while Str <> nil do
    begin
      Result := Str;
      Inc(Str);
      Str := AnsiStrScan(Str, Chr);
    end;
  end
end;

function AnsiStrRScan(Str: PWideChar; Chr: WideChar): PWideChar;
begin
  Result := StrRScan(Str, Chr);
end;

function AnsiStrScan(Str: PAnsiChar; Chr: AnsiChar): PAnsiChar;
begin
  Result := StrScan(Str, Chr);
  while Result <> nil do
  begin
    case StrByteType(Str, Integer(Result-Str)) of
      mbSingleByte: Exit;
      mbLeadByte: Inc(Result);
    end;
    Inc(Result);
    Result := StrScan(Result, Chr);
  end;
end;

function AnsiStrScan(Str: PWideChar; Chr: WideChar): PWideChar;
begin
  Result := StrScan(Str, Chr);
end;

function LCIDToCodePage(const ALCID: LCID): Integer;
var
  Buffer: array [0..6] of Char;
begin
  GetLocaleInfo(ALcid, LOCALE_IDEFAULTANSICODEPAGE, Buffer, Length(Buffer));
  Result:= StrToIntDef(Buffer, GetACP);
end;

procedure InitSysLocale;
var
  DefaultLCID: LCID;
  DefaultLangID: LANGID;
  AnsiCPInfo: TCPInfo;

  procedure InitLeadBytes;
  var
    I: Integer;
    J: Byte;
  begin
    GetCPInfo(CP_ACP, AnsiCPInfo);
    with AnsiCPInfo do
    begin
      I := 0;
      while (I < MAX_LEADBYTES) and ((LeadByte[I] or LeadByte[I + 1]) <> 0) do
      begin
        for J := LeadByte[I] to LeadByte[I + 1] do
          Include(LeadBytes, AnsiChar(J));
        Inc(I, 2);
      end;
    end;
  end;

begin
  { Set default to English (US). }
  SysLocale.DefaultLCID := $0409;
  SysLocale.PriLangID := LANG_ENGLISH;
  SysLocale.SubLangID := SUBLANG_ENGLISH_US;

  DefaultLCID := GetThreadLocale;
  if DefaultLCID <> 0 then SysLocale.DefaultLCID := DefaultLCID;

  DefaultLangID := Word(DefaultLCID);
  if DefaultLangID <> 0 then
  begin
    SysLocale.PriLangID := DefaultLangID and $3ff;
    SysLocale.SubLangID := DefaultLangID shr 10;
  end;

  LeadBytes := [];
  SysLocale.MiddleEast := True;

{$IF DEFINED(UNICODE)}
  SysLocale.FarEast := True;
{$ELSE}
  SysLocale.FarEast := GetSystemMetrics(SM_DBCSENABLED) <> 0;
{$IFEND}
  if SysLocale.FarEast then
    InitLeadBytes;
end;

procedure GetFormatSettings;
var
  I: Integer;
  LFormatSettings: TFormatSettings;
begin
  InitSysLocale;
  if SysLocale.FarEast then
    GetEraNamesAndYearOffsets;

  LFormatSettings := TFormatSettings.Create(''); // Initialize to default locale
  // Assign to globals to prevent smart-linking
  sdaSysUtils.CurrencyFormat := LFormatSettings.CurrencyFormat;
  sdaSysUtils.NegCurrFormat := LFormatSettings.NegCurrFormat;
  sdaSysUtils.ThousandSeparator := LFormatSettings.ThousandSeparator;
  sdaSysUtils.DecimalSeparator := LFormatSettings.DecimalSeparator;
  sdaSysUtils.CurrencyDecimals := LFormatSettings.CurrencyDecimals;
  sdaSysUtils.DateSeparator := LFormatSettings.DateSeparator;
  sdaSysUtils.TimeSeparator := LFormatSettings.TimeSeparator;
  sdaSysUtils.ListSeparator := LFormatSettings.ListSeparator;
  sdaSysUtils.CurrencyString := LFormatSettings.CurrencyString;
  sdaSysUtils.ShortDateFormat := LFormatSettings.ShortDateFormat;
  sdaSysUtils.LongDateFormat := LFormatSettings.LongDateFormat;
  sdaSysUtils.TimeAMString := LFormatSettings.TimeAMString;
  sdaSysUtils.TimePMString := LFormatSettings.TimePMString;
  sdaSysUtils.ShortTimeFormat := LFormatSettings.ShortTimeFormat;
  sdaSysUtils.LongTimeFormat := LFormatSettings.LongTimeFormat;
  for I := 1 to 12 do
  begin
    sdaSysUtils.ShortMonthNames[I] := LFormatSettings.ShortMonthNames[I];
    sdaSysUtils.LongMonthNames[I] := LFormatSettings.LongMonthNames[I];
  end;
  for I := 1 to 7 do
  begin
    sdaSysUtils.ShortDayNames[I] := LFormatSettings.ShortDayNames[I];
    sdaSysUtils.LongDayNames[I] := LFormatSettings.LongDayNames[I];
  end;
  sdaSysUtils.TwoDigitYearCenturyWindow := LFormatSettings.TwoDigitYearCenturyWindow;
end;

procedure GetLocaleFormatSettings(Locale: TLocaleID; var AFormatSettings: TFormatSettings);
begin
  AFormatSettings := TFormatSettings.Create(Locale);
end;

function StringReplace(const S, OldPattern, NewPattern: string;
  Flags: TReplaceFlags): string;
var
  SearchStr, Patt, NewStr: string;
  Offset: Integer;
begin
  if rfIgnoreCase in Flags then
  begin
    SearchStr := AnsiUpperCase(S);
    Patt := AnsiUpperCase(OldPattern);
  end else
  begin
    SearchStr := S;
    Patt := OldPattern;
  end;
  NewStr := S;
  Result := '';
  while SearchStr <> '' do
  begin
    Offset := AnsiPos(Patt, SearchStr);
    if Offset = 0 then
    begin
      Result := Result + NewStr;
      Break;
    end;
    Result := Result + Copy(NewStr, 1, Offset - 1) + NewPattern;
    NewStr := Copy(NewStr, Offset + Length(OldPattern), MaxInt);
    if not (rfReplaceAll in Flags) then
    begin
      Result := Result + NewStr;
      Break;
    end;
    SearchStr := Copy(SearchStr, Offset + Length(Patt), MaxInt);
  end;
end;

function WrapText(const Line, BreakStr: string; const BreakChars: TSysCharSet;
  MaxCol: Integer): string;
const
  QuoteChars = ['''', '"'];
var
  Col, Pos: Integer;
  LinePos, LineLen: Integer;
  BreakLen, BreakPos: Integer;
  QuoteChar, CurChar: Char;
  ExistingBreak: Boolean;
  L: Integer;
begin
  Col := 1;
  Pos := 1;
  LinePos := 1;
  BreakPos := 0;
  QuoteChar := #0;
  ExistingBreak := False;
  LineLen := Length(Line);
  BreakLen := Length(BreakStr);
  Result := '';
  while Pos <= LineLen do
  begin
    CurChar := Line[Pos];
    if IsLeadChar(CurChar) then
    begin
      L := CharLength(Line, Pos) div SizeOf(Char) - 1;
      Inc(Pos, L);
      Inc(Col, L);
    end
    else
    begin
    if CurChar in QuoteChars then
      if QuoteChar = #0 then
        QuoteChar := CurChar
      else if CurChar = QuoteChar then
        QuoteChar := #0;
    if QuoteChar = #0 then
    begin
      if CurChar = BreakStr[1] then
      begin
        ExistingBreak := StrLComp(PChar(BreakStr), PChar(@Line[Pos]), BreakLen) = 0;
        if ExistingBreak then
        begin
          Inc(Pos, BreakLen-1);
          BreakPos := Pos;
        end;
      end;

      if not ExistingBreak then
        if CurChar in BreakChars then
          BreakPos := Pos;
      end;
    end;

    Inc(Pos);
    Inc(Col);

    if not (QuoteChar in QuoteChars) and (ExistingBreak or
      ((Col > MaxCol) and (BreakPos > LinePos))) then
    begin
      Col := 1;
      Result := Result + Copy(Line, LinePos, BreakPos - LinePos + 1);
      if not (CurChar in QuoteChars) then
      begin
        while Pos <= LineLen do
        begin
          if Line[Pos] in BreakChars then
          begin
            Inc(Pos);
            ExistingBreak := False;
          end
          else
          begin
            if StrLComp(PChar(@Line[Pos]), sLineBreak, Length(sLineBreak)) = 0 then
            begin
              Inc(Pos, Length(sLineBreak));
              ExistingBreak := True;
            end
            else
              Break;
          end;
        end;
      end;
      if (Pos <= LineLen) and not ExistingBreak then
        Result := Result + BreakStr;

      Inc(BreakPos);
      LinePos := BreakPos;
      Pos := LinePos;
      ExistingBreak := False;
    end;
  end;
  Result := Result + Copy(Line, LinePos, MaxInt);
end;

function WrapText(const Line: string; MaxCol: Integer): string;
begin
  Result := WrapText(Line, sLineBreak, [' ', '-', #9], MaxCol); { do not localize }
end;

function FindCmdLineSwitch(const Switch: string; const Chars: TSysCharSet;
  IgnoreCase: Boolean): Boolean;
var
  I: Integer;
  S: string;
begin
  for I := 1 to ParamCount do
  begin
    S := ParamStr(I);
    if (Chars = []) or (S[1] in Chars) then
      if IgnoreCase then
      begin
        if (AnsiCompareText(Copy(S, 2, Maxint), Switch) = 0) then
        begin
          Result := True;
          Exit;
        end;
      end
      else begin
        if (AnsiCompareStr(Copy(S, 2, Maxint), Switch) = 0) then
        begin
          Result := True;
          Exit;
        end;
      end;
  end;
  Result := False;
end;

function FindCmdLineSwitch(const Switch: string): Boolean;
begin
  Result := FindCmdLineSwitch(Switch, SwitchChars, True);
end;

function FindCmdLineSwitch(const Switch: string; IgnoreCase: Boolean): Boolean;
begin
  Result := FindCmdLineSwitch(Switch, SwitchChars, IgnoreCase);
end;

function FindCmdLineSwitch(const Switch: string; var Value: string; IgnoreCase: Boolean = True;
  const SwitchTypes: TCmdLineSwitchTypes = [clstValueNextParam, clstValueAppended]): Boolean; overload;
type
  TCompareProc = function(const S1, S2: string): Boolean;
var
  Param: string;
  I, ValueOfs,
  SwitchLen, ParamLen: Integer;
  SameSwitch: TCompareProc;
begin
  Result := False;
  Value := '';
  if IgnoreCase then
    SameSwitch := SameText else
    SameSwitch := SameStr;
  SwitchLen := Length(Switch);

  for I := 1 to ParamCount do
  begin
    Param := ParamStr(I);
    if CharInSet(Param[1], SwitchChars) and SameSwitch(Copy(Param, 2, SwitchLen), Switch) then
    begin
      ParamLen := Length(Param);
      // Look for an appended value if the param is longer than the switch
      if (ParamLen > SwitchLen+1) then
      begin
        // If not looking for appended value switches then this is not a matching switch
        if not (clstValueAppended in SwitchTypes) then
          Continue;
        ValueOfs := SwitchLen + 2;
        if Param[ValueOfs] = ':' then
          Inc(ValueOfs);
        Value := Copy(Param, ValueOfs, MaxInt);
      end
      // If the next param is not a switch, then treat it as the value
      else if (clstValueNextParam in SwitchTypes) and (I < ParamCount) and
              not CharInSet(ParamStr(I+1)[1], SwitchChars) then
        Value := ParamStr(I+1);
      Result := True;
      Break;
    end;
  end;
end;

{ Package info structures }

type
  PPkgName = ^TPkgName;
  TPkgName = packed record
    HashCode: Byte;
    Name: array[0..255] of AnsiChar;
  end;

  { PackageUnitFlags:
    bit      meaning
    -----------------------------------------------------------------------------------------
    0      | main unit
    1      | package unit (dpk source)
    2      | $WEAKPACKAGEUNIT unit
    3      | original containment of $WEAKPACKAGEUNIT (package into which it was compiled)
    4      | implicitly imported
    5..7   | reserved
  }
  PUnitName = ^TUnitName;
  TUnitName = packed record
    Flags : Byte;
    HashCode: Byte;
    Name: array[0..255] of AnsiChar;
  end;

  { Package flags:
    bit     meaning
    -----------------------------------------------------------------------------------------
    0     | 1: never-build                  0: always build
    1     | 1: design-time only             0: not design-time only      on => bit 2 = off
    2     | 1: run-time only                0: not run-time only         on => bit 1 = off
    3     | 1: do not check for dup units   0: perform normal dup unit check
    4..25 | reserved
    26..27| (producer) 0: pre-V4, 1: undefined, 2: c++, 3: Pascal
    28..29| reserved
    30..31| 0: EXE, 1: Package DLL, 2: Library DLL, 3: undefined
  }
  PPackageInfoHeader = ^TPackageInfoHeader;
  TPackageInfoHeader = packed record
    Flags: Cardinal;
    RequiresCount: Integer;
    {Requires: array[0..9999] of TPkgName;
    ContainsCount: Integer;
    Contains: array[0..9999] of TUnitName;}
  end;

const
  cBucketSize = 1021; // better distribution than 1024

type
  PUnitHashEntry = ^TUnitHashEntry;
  TUnitHashEntry = record
    Next, Prev: PUnitHashEntry;
    LibModule: PLibModule;
    UnitName: PAnsiChar;
    DupsAllowed: Boolean;
    FullHash: Cardinal;
  end;
  TUnitHashArray = TArray<TUnitHashEntry>;
  TUnitHashBuckets = array[0..cBucketSize-1] of PUnitHashEntry;

  PModuleInfo = ^TModuleInfo;
  TModuleInfo = record
    Validated: Boolean;
    UnitHashArray: TUnitHashArray;
  end;

var
  ValidatedUnitHashBuckets: TUnitHashBuckets;
  UnitHashBuckets: TUnitHashBuckets;

function FindLibModule(Module: HModule): PLibModule; inline;
begin
  Result := LibModuleList;
  while Result <> nil do
  begin
    if Result.Instance = Cardinal(Module) then Exit;
    Result := Result.Next;
  end;
end;

procedure ModuleUnloaded(Module: HINST);
var
  LibModule: PLibModule;
  ModuleInfo: PModuleInfo;
  I: Integer;
  HC: Cardinal;
  Buckets: ^TUnitHashBuckets;
begin
  LibModule := FindLibModule(Module);
  if (LibModule <> nil) and (LibModule.Reserved <> 0) then
  begin
    ModuleInfo := PModuleInfo(LibModule.Reserved);
    if ModuleInfo.Validated then
      Buckets := @ValidatedUnitHashBuckets
    else
      Buckets := @UnitHashBuckets;
    for I := Low(ModuleInfo.UnitHashArray) to High(ModuleInfo.UnitHashArray) do
    begin
      if ModuleInfo.UnitHashArray[I].Prev <> nil then
        ModuleInfo.UnitHashArray[I].Prev.Next := ModuleInfo.UnitHashArray[I].Next
      else if ModuleInfo.UnitHashArray[I].UnitName <> nil then
      begin
        HC := HashName(ModuleInfo.UnitHashArray[I].UnitName) mod cBucketSize;
        if Buckets[HC] = @ModuleInfo.UnitHashArray[I] then
          Buckets[HC] := ModuleInfo.UnitHashArray[I].Next;
      end;
      if ModuleInfo.UnitHashArray[I].Next <> nil then
        ModuleInfo.UnitHashArray[I].Next.Prev := ModuleInfo.UnitHashArray[I].Prev;
    end;
    Dispose(ModuleInfo);
    LibModule.Reserved := 0;
  end;
end;

function PackageInfoTable(Module: HMODULE): PPackageInfoHeader;
var
  ResInfo: HRSRC;
  Data: THandle;
begin
  Result := nil;
  ResInfo := FindResource(Module, 'PACKAGEINFO', RT_RCDATA);
  if ResInfo <> 0 then
  begin
    Data := LoadResource(Module, ResInfo);
    if Data <> 0 then
    try
      Result := LockResource(Data);
      UnlockResource(Data);
    finally
      FreeResource(Data);
    end;
  end;
end;

function GetModuleName(Module: HMODULE): string;
var
  ModName: array[0..MAX_PATH] of Char;
begin
  SetString(Result, ModName, GetModuleFileName(Module, ModName, Length(ModName)));
end;

procedure RaiseLastOSError;
begin
  RaiseLastOSError(GetLastError);
end;

procedure RaiseLastOSError(LastError: Integer);
var
  Error: EOSError;
begin
  if LastError <> 0 then
    Error := EOSError.CreateResFmt(@SOSError, [LastError,
      SysErrorMessage(LastError)])
  else
    Error := EOSError.CreateRes(@SUnkOSError);
  Error.ErrorCode := LastError;
  raise Error;
end;

procedure CheckOSError(LastError: Integer);
begin
  if LastError <> 0 then
    RaiseLastOSError(LastError);
end;

{ RaiseLastWin32Error }

procedure RaiseLastWin32Error;
begin
  RaiseLastOSError;
end;

{ Win32Check }

function Win32Check(RetVal: BOOL): BOOL;
begin
  if not RetVal then RaiseLastOSError;
  Result := RetVal;
end;

type
  PTerminateProcInfo = ^TTerminateProcInfo;
  TTerminateProcInfo = record
    Next: PTerminateProcInfo;
    Proc: TTerminateProc;
  end;

var
  TerminateProcList: PTerminateProcInfo = nil;

procedure AddTerminateProc(TermProc: TTerminateProc);
var
  P: PTerminateProcInfo;
begin
  New(P);
  P^.Next := TerminateProcList;
  P^.Proc := TermProc;
  TerminateProcList := P;
end;

function CallTerminateProcs: Boolean;
var
  PI: PTerminateProcInfo;
begin
  Result := True;
  PI := TerminateProcList;
  while Result and (PI <> nil) do
  begin
    Result := PI^.Proc;
    PI := PI^.Next;
  end;
end;

procedure FreeTerminateProcs;
var
  PI: PTerminateProcInfo;
begin
  while TerminateProcList <> nil do
  begin
    PI := TerminateProcList;
    TerminateProcList := PI^.Next;
    Dispose(PI);
  end;
end;

function AL1(const P): LongWord;
type
  List = array[0..3] of DWORD;
begin
  Result := List(P)[0];
  Result := Result XOR List(P)[1];
  Result := Result XOR List(P)[2];
  Result := Result XOR List(P)[3];
end;

function AL2(const P): LongWord;
type
  List = array[0..3] of DWORD;
begin
  Result := List(P)[0];
  Result := (Result shr 5) or (Result shl 27);
  Result := Result XOR List(P)[1];
  Result := (Result shr 5) or (Result shl 27);
  Result := Result XOR List(P)[2];
  Result := (Result shr 5) or (Result shl 27);
  Result := Result XOR List(P)[3];
end;

const
  AL1s: array[0..3] of LongWord = ($FFFFFFF0, $FFFFEBF0, 0, $FFFFFFFF);
  AL2s: array[0..3] of LongWord = ($42C3ECEF, $20F7AEB6, $D1C2F74E, $3F6574DE);

procedure ALV;
begin
  raise Exception.CreateRes(@SNL);
end;

function ALR: Pointer;
var
  LibModule: PLibModule;
begin
  if MainInstance <> 0 then
    Result := Pointer(LoadResource(MainInstance, FindResource(MainInstance, 'DVCLAL',
      RT_RCDATA)))
  else
  begin
    Result := nil;
    LibModule := LibModuleList;
    while LibModule <> nil do
    begin
      with LibModule^ do
      begin
        Result := Pointer(LoadResource(Instance, FindResource(Instance, 'DVCLAL',
          RT_RCDATA)));
        if Result <> nil then Break;
      end;
      LibModule := LibModule.Next;
    end;
  end;
end;

function GDAL: LongWord;
type
  TDVCLAL = array[0..3] of LongWord;
  PDVCLAL = ^TDVCLAL;
var
  P: Pointer;
  A1, A2: LongWord;
  PAL1s, PAL2s: PDVCLAL;
  ALOK: Boolean;
begin
  P := ALR;
  if P <> nil then
  begin
    A1 := AL1(P^);
    A2 := AL2(P^);
    Result := A1;
    PAL1s := @AL1s;
    PAL2s := @AL2s;
    ALOK := ((A1 = PAL1s[0]) and (A2 = PAL2s[0])) or
            ((A1 = PAL1s[1]) and (A2 = PAL2s[1])) or
            ((A1 = PAL1s[2]) and (A2 = PAL2s[2]));
    FreeResource(HGLOBAL(P));
    if not ALOK then ALV;
  end else Result := AL1s[3];
end;

procedure RCS;
var
  P: Pointer;
  ALOK: Boolean;
begin
  P := ALR;
  if P <> nil then
  begin
    ALOK := (AL1(P^) = AL1s[2]) and (AL2(P^) = AL2s[2]);
    FreeResource(HGLOBAL(P));
  end else ALOK := False;
  if not ALOK then ALV;
end;

procedure RPR;
var
  AL: LongWord;
begin
  AL := GDAL;
  if (AL <> AL1s[1]) and (AL <> AL1s[2]) then ALV;
end;

procedure FreeAndNil(var Obj);
var
  Temp: TObject;
begin
  Temp := TObject(Obj);
  Pointer(Obj) := nil;
  Temp.Free;
end;

{ Interface support routines }

function Supports(const Instance: IInterface; const IID: TGUID; out Intf): Boolean;
begin
  Result := (Instance <> nil) and (Instance.QueryInterface(IID, Intf) = 0);
end;

function Supports(const Instance: TObject; const IID: TGUID; out Intf): Boolean;
var
  LUnknown: IUnknown;
begin
  Result := (Instance <> nil) and
            ((Instance.GetInterface(IUnknown, LUnknown) and Supports(LUnknown, IID, Intf)) or
             Instance.GetInterface(IID, Intf));
end;

function Supports(const Instance: IInterface; const IID: TGUID): Boolean;
var
  Temp: IInterface;
begin
  Result := Supports(Instance, IID, Temp);
end;

function Supports(const Instance: TObject; const IID: TGUID): Boolean;
var
  Temp: IInterface;
begin
  // NOTE: Calling this overload on a ref-counted object that has REFCOUNT=0
  // will result in it being freed upon exit from this routine.
  Result := Supports(Instance, IID, Temp);
end;

function Supports(const AClass: TClass; const IID: TGUID): Boolean;
begin
  Result := AClass.GetInterfaceEntry(IID) <> nil;
end;

{ TLanguages }

threadvar
  FTempLanguages: TLanguages;

function EnumLocalesCallback(LocaleID: PChar): Integer; stdcall;
begin
  Result := FTempLanguages.LocalesCallback(LocaleID);
end;

{ Query the OS for information for a specified locale. Unicode version. Works correctly on Asian WinNT. }
function GetLocaleDataW(ID: LCID; Flag: DWORD): string;
var
  Buffer: array[0..1023] of WideChar;
begin
  Buffer[0] := #0;
  GetLocaleInfoW(ID, Flag, Buffer, Length(Buffer));
  Result := Buffer;
end;

{ Called for each supported locale. }
function TLanguages.LocalesCallback(LocaleID: PChar): Integer;
var
  AID: LCID;
  ShortLangName: string;
begin
  AID := StrToInt('$' + Copy(LocaleID, 5, 4));
  ShortLangName := GetLocaleDataW(AID, LOCALE_SABBREVLANGNAME);
  if ShortLangName <> '' then
  begin
    SetLength(FSysLangs, Length(FSysLangs) + 1);
    with FSysLangs[High(FSysLangs)] do
    begin
      FName := GetLocaleDataW(AID, LOCALE_SLANGUAGE);
      FLCID := AID;
      FExt := ShortLangName;
      FLocaleName := Format('%s-%s', [GetLocaleDataW(AID, LOCALE_SISO639LANGNAME),
        GetLocaleDataW(AID, LOCALE_SISO3166CTRYNAME)]);
    end;
  end;
  Result := 1;
end;

constructor TLanguages.Create;
begin
  inherited Create;
  FTempLanguages := Self;
  EnumSystemLocales(@EnumLocalesCallback, LCID_SUPPORTED);
end;

function TLanguages.GetCount: Integer;
begin
  Result := Length(FSysLangs);
end;

function TLanguages.GetExt(Index: Integer): string;
begin
  Result := FSysLangs[Index].FExt;
end;

function TLanguages.GetID(Index: Integer): string;
begin
  Result := HexDisplayPrefix + IntToHex(FSysLangs[Index].FLCID, 8);
end;

function TLanguages.GetLocaleID(Index: Integer): TLocaleID;
begin
  Result := FSysLangs[Index].FLCID;
end;

function TLanguages.GetLocaleName(Index: Integer): string;
begin
  Result := FSysLangs[Index].FLocaleName;
end;

function TLanguages.GetName(Index: Integer): string;
begin
  Result := FSysLangs[Index].FName;
end;

function TLanguages.GetNameFromLocaleID(ID: TLocaleID): string;
var
  Index: Integer;
begin
  Result := sUnknown;
  Index := IndexOf(ID);
  if Index <> - 1 then Result := Name[Index];
  if Result = '' then Result := sUnknown;
end;

class function TLanguages.GetUserDefaultLocale: TLocaleID;
begin
  Result := sdaWindows.GetUserDefaultLCID;
end;

function TLanguages.GetNameFromLCID(const ID: string): string;
begin
  Result := NameFromLocaleID[StrToIntDef(ID, 0)];
end;

function TLanguages.IndexOf(ID: TLocaleID): Integer;
begin
  for Result := Low(FSysLangs) to High(FSysLangs) do
    if FSysLangs[Result].FLCID = ID then Exit;
  Result := -1;
end;

function TLanguages.IndexOf(const LocaleName: string): Integer;
begin
  for Result := Low(FSysLangs) to High(FSysLangs) do
    if CompareText(FSysLangs[Result].FLocaleName, LocaleName) = 0 then Exit;

  Result := -1;
end;

var
  FLanguages: TLanguages;

class destructor TLanguages.Destroy;
begin
  FreeAndNil(FLanguages);
end;

function Languages: TLanguages;
begin
  if FLanguages = nil then
    FLanguages := TLanguages.Create;
  Result := FLanguages;
end;

                                                                                                                    
function SafeLoadLibrary(const Filename: string; ErrorMode: UINT): HMODULE;
var
  OldMode: UINT;
  {$IFDEF CPUX86}
  FPUControlWord: Word;
  {$ENDIF CPUX86}
begin
  OldMode := SetErrorMode(ErrorMode);
  try
  {$IFDEF CPUX86}
    FPUControlWord := Get8087CW();
    Result := LoadLibrary(PChar(Filename));
    TestAndClearFPUExceptions(0);
    Set8087CW(FPUControlWord);
  {$ENDIF CPUX86}
  {$IFDEF CPUX64}
    Result := LoadLibrary(PChar(Filename));
  {$ENDIF CPUX64}
  finally
    SetErrorMode(OldMode);
  end;
end;

function GetEnvironmentVariable(const Name: string): string;
const
  BufSize = 1024;
var
  Len: Integer;
  Buffer: array[0..BufSize - 1] of Char;
begin
  Result := '';
  Len := GetEnvironmentVariable(PChar(Name), @Buffer, BufSize);
  if Len < BufSize then
    SetString(Result, PChar(@Buffer), Len)
  else
  begin
    SetLength(Result, Len - 1);
    GetEnvironmentVariable(PChar(Name), PChar(Result), Len);
  end;
end;

procedure ClearHashTables;
var
  Module: PLibModule;
begin
  Module := LibModuleList;
  while Module <> nil do
  begin
    if Module.Reserved <> 0 then
    begin
      Dispose(PModuleInfo(Module.Reserved));
      Module.Reserved := 0;
    end;
    Module := Module.Next;
  end;
end;

function DelegatesEqual(A, B: Pointer): Boolean;
begin
  Result := A = B;
end;

function ByteLength(const S: string): Integer;
begin
  Result := Length(S) * SizeOf(Char);
end;

type
  TLanguageArray = TArray<string>;
var
  LanguageArray : TLanguageArray;
  DefaultFallbackLanguages: string = '';

procedure InitLanguageList;

  procedure AddNewLanguages(NewLanguages: string);
  var
    aLang: string;
    I: integer;
  begin
    NewLanguages := UpperCase(NewLanguages);
    while NewLanguages <> '' do
    begin
      I := Pos(',', NewLanguages);
      if I > 0 then
      begin
        aLang := Copy(NewLanguages, 1, I-1);
        NewLanguages := Copy(NewLanguages, I+1, MAXINT);
      end
      else
      begin
        aLang := NewLanguages;
        NewLanguages := '';
      end;
      if aLang <> '' then
      begin
        // Duplicate check.
        for I := 0 to Length(LanguageArray) - 1 do
        begin
          if LanguageArray[I] = aLang then
          begin
            aLang := '';
            break;
          end;
        end;
      end;
      if aLang <> '' then
      begin
        SetLength(LanguageArray, length(LanguageArray)+1);
        LanguageArray[length(LanguageArray)-1] := aLang;
      end;
    end;
  end;

var
  aLanguageList: string;
begin
  if Length(LanguageArray) = 0 then
  begin
    aLanguageList := GetLocaleOverride('');
    if aLanguageList = '' then
      aLanguageList := GetUILanguages(GetUserDefaultUILanguage);
    AddNewLanguages(aLanguageList);
    if DefaultFallbackLanguages <> '' then
      AddNewLanguages(DefaultFallbackLanguages);
  end;
end;

function GetDefaultFallbackLanguages: string;
begin
  Result := DefaultFallbackLanguages;
end;

procedure SetDefaultFallbackLanguages(const Languages: string);
begin
  if DefaultFallbackLanguages <> UpperCase(Languages) then
  begin
    DefaultFallbackLanguages := UpperCase(Languages);
    SetLength(LanguageArray, 0);
    InitLanguageList;
  end;
end;

function PreferredUILanguages: string;
var
  aLang, Separator: string;
begin
  InitLanguageList;

  Result := '';
  Separator := '';
  for aLang in LanguageArray do
  begin
    Result := Result + Separator + aLang;
    Separator := ',';
  end;
end;

{ TOSVersion }

const
  PROCESSOR_ARCHITECTURE_AMD64       = 9;

  VER_PLATFORM_WIN32S                = 0;
  VER_PLATFORM_WIN32_WINDOWS         = 1;
  VER_PLATFORM_WIN32_NT              = 2;

  VER_SERVER_NT                      = $80000000;
  VER_WORKSTATION_NT                 = $40000000;

  VER_NT_WORKSTATION                 = $00000001;
  VER_NT_DOMAIN_CONTROLLER           = $00000002;
  VER_NT_SERVER                      = $00000003;

  VER_SUITE_SMALLBUSINESS            = $00000001;
  VER_SUITE_ENTERPRISE               = $00000002;
  VER_SUITE_BACKOFFICE               = $00000004;
  VER_SUITE_COMMUNICATIONS           = $00000008;
  VER_SUITE_TERMINAL                 = $00000010;
  VER_SUITE_SMALLBUSINESS_RESTRICTED = $00000020;
  VER_SUITE_EMBEDDEDNT               = $00000040;
  VER_SUITE_DATACENTER               = $00000080;
  VER_SUITE_SINGLEUSERTS             = $00000100;
  VER_SUITE_PERSONAL                 = $00000200;
  VER_SUITE_BLADE                    = $00000400;

  SVersionStr: string = '%s (Version %d.%d, Build %d, %5:s)';
  SSPVersionStr: string = '%s Service Pack %4:d (Version %1:d.%2:d, Build %3:d, %5:s)';
  SVersion32: string = '32-bit Edition';
  SVersion64: string = '64-bit Edition';
  SWindows: string = 'Windows';
  SWindowsVista: string = 'Windows Vista';
  SWindowsServer2008: string = 'Windows Server 2008';
  SWindows7: string = 'Windows 7';
  SWindowsServer2008R2: string = 'Windows Server 2008 R2';
  SWindows2000: string = 'Windows 2000';
  SWindowsXP: string = 'Windows XP';
  SWindowsServer2003: string = 'Windows Server 2003';
  SWindowsServer2003R2: string = 'Windows Server 2003 R2';

class constructor TOSVersion.Create;
const
  CArchitectures: array[Boolean] of TArchitecture = (arIntelX86, arIntelX64);
var
  SysInfo: TSystemInfo;
  VerInfo: TOSVersionInfoEx;
begin
  ZeroMemory(@VerInfo, SizeOf(VerInfo));
  VerInfo.dwOSVersionInfoSize := SizeOf(VerInfo);
  GetVersionEx(VerInfo);

  FPlatform := pfWindows;
  FMajor := VerInfo.dwMajorVersion;
  FMinor := VerInfo.dwMinorVersion;
  FBuild := VerInfo.dwBuildNumber;
  FServicePackMajor := VerInfo.wServicePackMajor;
  FServicePackMinor := VerInfo.wServicePackMinor;

  ZeroMemory(@SysInfo, SizeOf(SysInfo));
  if Check(5, 1) then // GetNativeSystemInfo not supported on Windows 2000
    GetNativeSystemInfo(SysInfo);
  FArchitecture := CArchitectures[SysInfo.wProcessorArchitecture = PROCESSOR_ARCHITECTURE_AMD64];

  FName := SWindows;
  case FMajor of
    6:  case FMinor of
          0: if VerInfo.wProductType = VER_NT_WORKSTATION then
               FName := SWindowsVista
             else
               FName := SWindowsServer2008;
          1: if VerInfo.wProductType = VER_NT_WORKSTATION then
               FName := SWindows7
             else
               FName := SWindowsServer2008R2;
        end;
    5:  case FMinor of
          0: FName := SWindows2000;
          1: FName := SWindowsXP;
          2:
            begin
              if (VerInfo.wProductType = VER_NT_WORKSTATION) and
                 (SysInfo.wProcessorArchitecture = PROCESSOR_ARCHITECTURE_AMD64) then
                FName := SWindowsXP
              else
              begin
                if GetSystemMetrics(SM_SERVERR2) = 0 then
                  FName := SWindowsServer2003
                else
                  FName := SWindowsServer2003R2
              end;
            end;
        end;
  end;
end;

class function TOSVersion.Check(AMajor: Integer): Boolean;
begin
  Result := Major >= AMajor;
end;

class function TOSVersion.Check(AMajor, AMinor: Integer): Boolean;
begin
  Result := (Major > AMajor) or ((Major = AMajor) and (Minor >= AMinor));
end;

class function TOSVersion.Check(AMajor, AMinor, AServicePackMajor: Integer): Boolean;
begin
  Result := (Major > AMajor) or ((Major = AMajor) and (Minor > AMinor)) or
    ((Major = AMajor) and (Minor = AMinor) and (ServicePackMajor >= AServicePackMajor));
end;

class function TOSVersion.ToString: string;
const
  CVersionStr: array[Boolean] of PResStringRec = (@SVersionStr, @SSPVersionStr);
  CEditionStr: array[Boolean] of PResStringRec = (@SVersion32, @SVersion64);
begin
  Result := Format(LoadResString(CVersionStr[ServicePackMajor <> 0]),
    [Name, Major, Minor, Build, ServicePackMajor,
    LoadResString(CEditionStr[FArchitecture = arIntelX64])]);
end;

initialization
  if ModuleIsCpp then HexDisplayPrefix := '0x';
  InitMonitorSupport;
  AddModuleUnloadProc(ModuleUnloaded);

  InitPlatformId;
  DefaultFallbackLanguages := GetLocaleOverride('');
  GetFormatSettings; { Win implementation uses platform id }
finalization
  RemoveModuleUnloadProc(ModuleUnloaded);
  ClearHashTables;
  FreeTerminateProcs;
  DoneMonitorSupport;

end.
