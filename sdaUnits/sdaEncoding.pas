unit sdaEncoding;

interface

{$INCLUDE 'sda.inc'}

uses
  sdaSysUtils;

type
  TEncoding = class
  strict private
    class var
      FANSIEncoding: TEncoding;
      FASCIIEncoding: TEncoding;
      FBigEndianUnicodeEncoding: TEncoding;
      FUnicodeEncoding: TEncoding;
      FUTF7Encoding: TEncoding;
      FUTF8Encoding: TEncoding;
    class destructor Destroy;
    class function GetANSI: TEncoding; static;
    class function GetASCII: TEncoding; static;
    class function GetBigEndianUnicode: TEncoding; static;
    class function GetDefault: TEncoding; static; inline;
    class function GetUnicode: TEncoding; static;
    class function GetUTF7: TEncoding; static;
    class function GetUTF8: TEncoding; static;
  strict protected
    FIsSingleByte: Boolean;
    FMaxCharSize: Integer;
    function GetByteCount(Chars: PChar; CharCount: Integer): Integer; overload; virtual; abstract;
    function GetBytes(Chars: PChar; CharCount: Integer; Bytes: PByte; ByteCount: Integer): Integer; overload; virtual; abstract;
    function GetCharCount(Bytes: PByte; ByteCount: Integer): Integer; overload; virtual; abstract;
    function GetChars(Bytes: PByte; ByteCount: Integer; Chars: PChar; CharCount: Integer): Integer; overload; virtual; abstract;
    function GetCodePage: Cardinal; virtual;
    function GetEncodingName: string; virtual;
  public
    function Clone: TEncoding; virtual;
    class function Convert(Source, Destination: TEncoding; const Bytes: TBytes): TBytes; overload;
    class function Convert(Source, Destination: TEncoding; const Bytes: TBytes; StartIndex, Count: Integer): TBytes; overload;
    class procedure FreeEncodings;
    class function IsStandardEncoding(AEncoding: TEncoding): Boolean; static;
    class function GetBufferEncoding(const Buffer: TBytes; var AEncoding: TEncoding): Integer; overload; static;
    class function GetBufferEncoding(const Buffer: TBytes; var AEncoding: TEncoding;
      ADefaultEncoding: TEncoding): Integer; overload; static;
    function GetByteCount(const Chars: TCharArray): Integer; overload;
    function GetByteCount(const Chars: TCharArray; CharIndex, CharCount: Integer): Integer; overload;
    function GetByteCount(const S: string): Integer; overload;
    function GetByteCount(const S: string; CharIndex, CharCount: Integer): Integer; overload;
    function GetBytes(const Chars: TCharArray): TBytes; overload;
    function GetBytes(const Chars: TCharArray; CharIndex, CharCount: Integer): TBytes; overload;
    function GetBytes(const Chars: TCharArray; CharIndex, CharCount: Integer;
      const Bytes: TBytes; ByteIndex: Integer): Integer; overload;
    function GetBytes(const S: string): TBytes; overload;
    function GetBytes(const S: string; CharIndex, CharCount: Integer;
      const Bytes: TBytes; ByteIndex: Integer): Integer; overload;
    function GetCharCount(const Bytes: TBytes): Integer; overload;
    function GetCharCount(const Bytes: TBytes; ByteIndex, ByteCount: Integer): Integer; overload;
    function GetChars(const Bytes: TBytes): TCharArray; overload;
    function GetChars(const Bytes: TBytes; ByteIndex, ByteCount: Integer): TCharArray; overload;
    function GetChars(const Bytes: TBytes; ByteIndex, ByteCount: Integer;
      const Chars: TCharArray; CharIndex: Integer): Integer; overload;
    class function GetEncoding(CodePage: Integer): TEncoding; overload; static;
    class function GetEncoding(const EncodingName: string): TEncoding; overload; static;
    function GetMaxByteCount(CharCount: Integer): Integer; virtual; abstract;
    function GetMaxCharCount(ByteCount: Integer): Integer; virtual; abstract;
    function GetPreamble: TBytes; virtual; abstract;
    function GetString(const Bytes: TBytes): string; overload;
    function GetString(const Bytes: TBytes; ByteIndex, ByteCount: Integer): string; overload;
    class property ANSI: TEncoding read GetANSI;
    class property ASCII: TEncoding read GetASCII;
    class property BigEndianUnicode: TEncoding read GetBigEndianUnicode;
    property CodePage: Cardinal read GetCodePage;
    class property Default: TEncoding read GetDefault;
    property EncodingName: string read GetEncodingName;
    property IsSingleByte: Boolean read FIsSingleByte;
    class property Unicode: TEncoding read GetUnicode;
    class property UTF7: TEncoding read GetUTF7;
    class property UTF8: TEncoding read GetUTF8;
  end;

  TMBCSEncoding = class(TEncoding)
  private
    FCodePage: Cardinal;
    FMBToWCharFlags: Cardinal;
    FWCharToMBFlags: Cardinal;
  strict protected
    function GetByteCount(Chars: PChar; CharCount: Integer): Integer; overload; override;
    function GetBytes(Chars: PChar; CharCount: Integer; Bytes: PByte; ByteCount: Integer): Integer; overload; override;
    function GetCharCount(Bytes: PByte; ByteCount: Integer): Integer; overload; override;
    function GetChars(Bytes: PByte; ByteCount: Integer; Chars: PChar; CharCount: Integer): Integer; overload; override;
    function GetCodePage: Cardinal; override;
    function GetEncodingName: string; override;
  public
    constructor Create; overload; virtual;
    constructor Create(CodePage: Integer); overload; virtual;
    constructor Create(CodePage, MBToWCharFlags, WCharToMBFlags: Integer); overload; virtual;
    function Clone: TEncoding; override;
    function GetMaxByteCount(CharCount: Integer): Integer; override;
    function GetMaxCharCount(ByteCount: Integer): Integer; override;
    function GetPreamble: TBytes; override;
  end;

  TUTF7Encoding = class(TMBCSEncoding)
  public
    constructor Create; override;
    function Clone: TEncoding; override;
    function GetMaxByteCount(CharCount: Integer): Integer; override;
    function GetMaxCharCount(ByteCount: Integer): Integer; override;
  end;

  TUTF8Encoding = class(TUTF7Encoding)
  public
    constructor Create; override;
    function Clone: TEncoding; override;
    function GetMaxByteCount(CharCount: Integer): Integer; override;
    function GetMaxCharCount(ByteCount: Integer): Integer; override;
    function GetPreamble: TBytes; override;
  end;

  TUnicodeEncoding = class(TEncoding)
  strict protected
    function GetByteCount(Chars: PChar; CharCount: Integer): Integer; overload; override;
    function GetBytes(Chars: PChar; CharCount: Integer; Bytes: PByte; ByteCount: Integer): Integer; overload; override;
    function GetCharCount(Bytes: PByte; ByteCount: Integer): Integer; overload; override;
    function GetChars(Bytes: PByte; ByteCount: Integer; Chars: PChar; CharCount: Integer): Integer; overload; override;
    function GetCodePage: Cardinal; override;
    function GetEncodingName: string; override;
  public
    constructor Create; virtual;
    function Clone: TEncoding; override;
    function GetMaxByteCount(CharCount: Integer): Integer; override;
    function GetMaxCharCount(ByteCount: Integer): Integer; override;
    function GetPreamble: TBytes; override;
  end;

  TBigEndianUnicodeEncoding = class(TUnicodeEncoding)
  strict protected
    function GetBytes(Chars: PChar; CharCount: Integer; Bytes: PByte; ByteCount: Integer): Integer; overload; override;
    function GetChars(Bytes: PByte; ByteCount: Integer; Chars: PChar; CharCount: Integer): Integer; overload; override;
    function GetCodePage: Cardinal; override;
    function GetEncodingName: string; override;
  public
    function Clone: TEncoding; override;
    function GetPreamble: TBytes; override;
  end;

// TBytes/string conversion routines
function BytesOf(const Val: RawByteString): TBytes; overload;
function BytesOf(const Val: UnicodeString): TBytes; overload;
function BytesOf(const Val: WideChar): TBytes; overload;
function BytesOf(const Val: AnsiChar): TBytes; overload;
function StringOf(const Bytes: TBytes): UnicodeString;
function PlatformBytesOf(const Value: string): TBytes;
function PlatformStringOf(const Value: TBytes): UnicodeString;
function WideStringOf(const Value: TBytes): UnicodeString;
function WideBytesOf(const Value: UnicodeString): TBytes;

implementation

uses
  sdaWindows;

resourcestring
  SInvalidSourceArray = 'Invalid source array';
  SInvalidDestinationArray = 'Invalid destination array';
  SCharIndexOutOfBounds = 'Character index out of bounds (%d)';
  SByteIndexOutOfBounds = 'Start index out of bounds (%d)';
  SInvalidCharCount = 'Invalid count (%d)';
  SInvalidDestinationIndex = 'Invalid destination index (%d)';
  SInvalidCodePage = 'Invalid code page';
  SInvalidEncodingName = 'Invalid encoding name';

{$I EncodingData.inc}

function GetEncodingHashIndex(Hash: Cardinal): Integer;
var
  I: Integer;
begin
  for I := Low(EncodingHashList) to High(EncodingHashList) do
    if Hash = EncodingHashList[I] then
      Exit(I);
  Result := -1;
end;

function GetCodePageFromEncodingName(const Name: string; var CodePage: Cardinal): Boolean;
var
  Index, Code: Integer;
  PSearchName, PEncodingName: PAnsiChar;
begin
  Result := False;
  PSearchName := PAnsiChar(AnsiString(Name));
  Index := GetEncodingHashIndex(HashName(PSearchName));
  if Index <> -1 then
  begin
    PEncodingName := PAnsiChar(@EncodingNameList) + Word(EncodingDataList[Index]);
    Result := StrComp(PSearchName, PEncodingName) = 0;
    if Result then
      CodePage := HiWord(EncodingDataList[Index]);
  end
  else
  begin
    // if we don't find the encoding in the pre-built list of hashed names,
    // test if it's a codepage specified in the "cp####" format.
    if Copy(Name, 1, 2) = 'cp' then // do not localize
    begin
      Val(Copy(Name, 3, Length(Name) - 2), CodePage, Code);
      Result := Code = 0;
    end;
  end;
end;

{ TEncoding }

function TEncoding.Clone: TEncoding;
begin
  Result := nil; // Return nil if encoding class cannot be cloned
end;

class function TEncoding.Convert(Source, Destination: TEncoding; const Bytes: TBytes): TBytes;
begin
  Result := Destination.GetBytes(Source.GetChars(Bytes));
end;

class function TEncoding.Convert(Source, Destination: TEncoding; const Bytes: TBytes;
  StartIndex, Count: Integer): TBytes;
begin
  Result := Destination.GetBytes(Source.GetChars(Bytes, StartIndex, Count));
end;

class destructor TEncoding.Destroy;
begin
  FreeEncodings;
end;

class procedure TEncoding.FreeEncodings;
begin
  FreeAndNil(FANSIEncoding);
  FreeAndNil(FASCIIEncoding);
  FreeAndNil(FUTF7Encoding);
  FreeAndNil(FUTF8Encoding);
  FreeAndNil(FUnicodeEncoding);
  FreeAndNil(FBigEndianUnicodeEncoding);
end;

class function TEncoding.GetANSI: TEncoding;
var
  LEncoding: TEncoding;
begin
  if FANSIEncoding = nil then
  begin
    LEncoding := TMBCSEncoding.Create(GetACP, 0, 0);
    if InterlockedCompareExchangePointer(Pointer(FANSIEncoding), LEncoding, nil) <> nil then
      LEncoding.Free;
  end;
  Result := FANSIEncoding;
end;

class function TEncoding.GetASCII: TEncoding;
var
  LCPInfo: TCPInfo;
  LEncoding: TEncoding;
begin
  if FASCIIEncoding = nil then
  begin
    { Check whether the ASCII encoding is supported }
    if GetCPInfo(20127, LCPInfo) then
      LEncoding := TMBCSEncoding.Create(20127, 0, 0)
    else
      LEncoding := TMBCSEncoding.Create(437, 0, 0); // Select OEM US 437 otherwise

    if InterlockedCompareExchangePointer(Pointer(FASCIIEncoding), LEncoding, nil) <> nil then
      LEncoding.Free;
  end;
  Result := FASCIIEncoding;
end;

class function TEncoding.GetBigEndianUnicode: TEncoding;
var
  LEncoding: TEncoding;
begin
  if FBigEndianUnicodeEncoding = nil then
  begin
    LEncoding := TBigEndianUnicodeEncoding.Create;

    if InterlockedCompareExchangePointer(Pointer(FBigEndianUnicodeEncoding), LEncoding, nil) <> nil then
      LEncoding.Free;
  end;
  Result := FBigEndianUnicodeEncoding;
end;

class function TEncoding.GetBufferEncoding(const Buffer: TBytes; var AEncoding: TEncoding): Integer;
begin
  Result := GetBufferEncoding(Buffer, AEncoding, Default); // Must call property getter to create Encoding
end;

class function TEncoding.GetBufferEncoding(const Buffer: TBytes; var AEncoding: TEncoding;
  ADefaultEncoding: TEncoding): Integer;

  function ContainsPreamble(const Buffer, Signature: TBytes): Boolean;
  var
    I: Integer;
  begin
    Result := True;
    if Length(Buffer) >= Length(Signature) then
    begin
      for I := 1 to Length(Signature) do
        if Buffer[I - 1] <> Signature [I - 1] then
        begin
          Result := False;
          Break;
        end;
    end
    else
      Result := False;
  end;

var
  Preamble: TBytes;
begin
  Result := 0;
  if AEncoding = nil then
  begin
    // Find the appropraite encoding
    if ContainsPreamble(Buffer, TEncoding.UTF8.GetPreamble) then
      AEncoding := TEncoding.UTF8
    else if ContainsPreamble(Buffer, TEncoding.Unicode.GetPreamble) then
      AEncoding := TEncoding.Unicode
    else if ContainsPreamble(Buffer, TEncoding.BigEndianUnicode.GetPreamble) then
      AEncoding := TEncoding.BigEndianUnicode
    else
    begin
      AEncoding := ADefaultEncoding;
      Exit; // Don't proceed just in case ADefaultEncoding has a Preamble
    end;
    Result := Length(AEncoding.GetPreamble);
  end
  else
  begin
    Preamble := AEncoding.GetPreamble;
    if ContainsPreamble(Buffer, Preamble) then
      Result := Length(Preamble);
  end;
end;

function TEncoding.GetByteCount(const Chars: TCharArray): Integer;
begin
  Result := GetByteCount(Chars, 0, Length(Chars));
end;

function TEncoding.GetByteCount(const Chars: TCharArray; CharIndex, CharCount: Integer): Integer;
begin
  if CharIndex < 0 then
    raise EEncodingError.CreateResFmt(@SCharIndexOutOfBounds, [CharIndex]);
  if CharCount < 0 then
    raise EEncodingError.CreateResFmt(@SInvalidCharCount, [CharCount]);
  if (Length(Chars) - CharIndex) < CharCount then
    raise EEncodingError.CreateResFmt(@SInvalidCharCount, [CharCount]);

  Result := GetByteCount(@Chars[CharIndex], CharCount);
end;

function TEncoding.GetByteCount(const S: string): Integer;
begin
  Result := GetByteCount(PChar(S), Length(S));
end;

function TEncoding.GetByteCount(const S: string; CharIndex, CharCount: Integer): Integer;
begin
  if CharIndex < 1 then
    raise EEncodingError.CreateResFmt(@SCharIndexOutOfBounds, [CharIndex]);
  if CharCount < 0 then
    raise EEncodingError.CreateResFmt(@SInvalidCharCount, [CharCount]);
  if (Length(S) - CharIndex + 1) < CharCount then
    raise EEncodingError.CreateResFmt(@SInvalidCharCount, [CharCount]);

  Result := GetByteCount(PChar(@S[CharIndex]), CharCount);
end;

function TEncoding.GetBytes(const Chars: TCharArray; CharIndex, CharCount: Integer): TBytes;
var
  Len: Integer;
begin
  Len := GetByteCount(Chars, CharIndex, CharCount);
  SetLength(Result, Len);
  GetBytes(Chars, CharIndex, CharCount, Result, 0);
end;

function TEncoding.GetBytes(const Chars: TCharArray): TBytes;
var
  Len: Integer;
begin
  Len := GetByteCount(Chars);
  SetLength(Result, Len);
  GetBytes(Chars, 0, Length(Chars), Result, 0);
end;

function TEncoding.GetBytes(const Chars: TCharArray; CharIndex, CharCount: Integer;
  const Bytes: TBytes; ByteIndex: Integer): Integer;
var
  Len: Integer;
begin
  if (Chars = nil) and (CharCount <> 0) then
    raise EEncodingError.CreateRes(@SInvalidSourceArray);
  if (Bytes = nil) and (CharCount <> 0) then
    raise EEncodingError.CreateRes(@SInvalidDestinationArray);
  if CharIndex < 0 then
    raise EEncodingError.CreateResFmt(@SCharIndexOutOfBounds, [CharIndex]);
  if CharCount < 0 then
    raise EEncodingError.CreateResFmt(@SInvalidCharCount, [CharCount]);
  if (Length(Chars) - CharIndex) < CharCount then
    raise EEncodingError.CreateResFmt(@SInvalidCharCount, [CharCount]);
  Len := Length(Bytes);
  if (ByteIndex < 0) or (ByteIndex > Len) then
    raise EEncodingError.CreateResFmt(@SInvalidDestinationIndex, [ByteIndex]);
  if Len - ByteIndex < GetByteCount(Chars, CharIndex, CharCount) then
    raise EEncodingError.CreateRes(@SInvalidDestinationArray);

  Result := GetBytes(@Chars[CharIndex], CharCount, @Bytes[ByteIndex], Len - ByteIndex);
end;

function TEncoding.GetBytes(const S: string): TBytes;
var
  Len: Integer;
begin
  Len := GetByteCount(S);
  SetLength(Result, Len);
  GetBytes(S, 1, Length(S), Result, 0);
end;

function TEncoding.GetBytes(const S: string; CharIndex, CharCount: Integer;
  const Bytes: TBytes; ByteIndex: Integer): Integer;
var
  Len: Integer;
begin
  if (Bytes = nil) and (CharCount <> 0) then
    raise EEncodingError.CreateRes(@SInvalidSourceArray);
  if CharIndex < 1 then
    raise EEncodingError.CreateResFmt(@SCharIndexOutOfBounds, [CharIndex]);
  if CharCount < 0 then
    raise EEncodingError.CreateResFmt(@SInvalidCharCount, [CharCount]);
  if (Length(S) - CharIndex + 1) < CharCount then
    raise EEncodingError.CreateResFmt(@SInvalidCharCount, [CharCount]);
  Len := Length(Bytes);
  if (ByteIndex < 0) or (ByteIndex > Len) then
    raise EEncodingError.CreateResFmt(@SInvalidDestinationIndex, [ByteIndex]);
  if Len - ByteIndex < GetByteCount(S, CharIndex, CharCount) then
    raise EEncodingError.CreateRes(@SInvalidDestinationArray);

  Result := GetBytes(@S[CharIndex], CharCount, @Bytes[ByteIndex], Len - ByteIndex);
end;

function TEncoding.GetCharCount(const Bytes: TBytes): Integer;
begin
  Result := GetCharCount(Bytes, 0, Length(Bytes));
end;

function TEncoding.GetCharCount(const Bytes: TBytes; ByteIndex, ByteCount: Integer): Integer;
begin
  if (Bytes = nil) and (ByteCount <> 0) then
    raise EEncodingError.CreateRes(@SInvalidSourceArray);
  if ByteIndex < 0 then
    raise EEncodingError.CreateResFmt(@SByteIndexOutOfBounds, [ByteIndex]);
  if ByteCount < 0 then
    raise EEncodingError.CreateResFmt(@SInvalidCharCount, [ByteCount]);
  if (Length(Bytes) - ByteIndex) < ByteCount then
    raise EEncodingError.CreateResFmt(@SInvalidCharCount, [ByteCount]);

  Result := GetCharCount(@Bytes[ByteIndex], ByteCount);
end;

function TEncoding.GetChars(const Bytes: TBytes): TCharArray;
begin
  Result := GetChars(Bytes, 0, Length(Bytes));
end;

function TEncoding.GetChars(const Bytes: TBytes; ByteIndex, ByteCount: Integer): TCharArray;
var
  Len: Integer;
begin
  if (Bytes = nil) and (ByteCount <> 0) then
    raise EEncodingError.CreateRes(@SInvalidSourceArray);
  if ByteIndex < 0 then
    raise EEncodingError.CreateResFmt(@SByteIndexOutOfBounds, [ByteIndex]);
  if ByteCount < 0 then
    raise EEncodingError.CreateResFmt(@SInvalidCharCount, [ByteCount]);
  if (Length(Bytes) - ByteIndex) < ByteCount then
    raise EEncodingError.CreateResFmt(@SInvalidCharCount, [ByteCount]);

  Len := GetCharCount(Bytes, ByteIndex, ByteCount);
  SetLength(Result, Len);
  GetChars(@Bytes[ByteIndex], ByteCount, PChar(Result), Len);
end;

function TEncoding.GetChars(const Bytes: TBytes; ByteIndex, ByteCount: Integer;
  const Chars: TCharArray; CharIndex: Integer): Integer;
var
  LCharCount: Integer;
begin
  if (Bytes = nil) and (ByteCount <> 0) then
    raise EEncodingError.CreateRes(@SInvalidSourceArray);
  if ByteIndex < 0 then
    raise EEncodingError.CreateResFmt(@SByteIndexOutOfBounds, [ByteIndex]);
  if ByteCount < 0 then
    raise EEncodingError.CreateResFmt(@SInvalidCharCount, [ByteCount]);
  if (Length(Bytes) - ByteIndex) < ByteCount then
    raise EEncodingError.CreateResFmt(@SInvalidCharCount, [ByteCount]);

  LCharCount := GetCharCount(Bytes, ByteIndex, ByteCount);
  if (CharIndex < 0) or (CharIndex > Length(Chars)) then
    raise EEncodingError.CreateResFmt(@SInvalidDestinationIndex, [CharIndex]);
  if CharIndex + LCharCount > Length(Chars) then
    raise EEncodingError.CreateRes(@SInvalidDestinationArray);

  Result := GetChars(@Bytes[ByteIndex], ByteCount, @Chars[CharIndex], LCharCount);
end;

function TEncoding.GetCodePage: Cardinal;
begin
  Result := Cardinal(-1); // Not supported
end;

class function TEncoding.GetDefault: TEncoding;
begin
  Result := ANSI;
end;

class function TEncoding.GetEncoding(CodePage: Integer): TEncoding;
begin
  case CodePage of
    1200: Result := TUnicodeEncoding.Create;
    1201: Result := TBigEndianUnicodeEncoding.Create;
    CP_UTF7: Result := TUTF7Encoding.Create;
    CP_UTF8: Result := TUTF8Encoding.Create;
  else
    Result := TMBCSEncoding.Create(CodePage);
  end;
end;

class function TEncoding.GetEncoding(const EncodingName: string): TEncoding;
var
  LCodePage: Cardinal;
begin
  if GetCodePageFromEncodingName(LowerCase(EncodingName), LCodePage) then
    Result := GetEncoding(LCodePage)
  else
    raise EEncodingError.CreateRes(@SInvalidEncodingName);
end;

function TEncoding.GetEncodingName: string;
begin
  Result := '';
end;

function TEncoding.GetString(const Bytes: TBytes): string;
begin
  Result := GetString(Bytes, 0, Length(Bytes));
end;

function TEncoding.GetString(const Bytes: TBytes; ByteIndex, ByteCount: Integer): string;
var
  LChars: TCharArray;
begin
  LChars := GetChars(Bytes, ByteIndex, ByteCount);
  SetString(Result, PChar(LChars), Length(LChars));
end;

class function TEncoding.GetUnicode: TEncoding;
var
  LEncoding: TEncoding;
begin
  if FUnicodeEncoding = nil then
  begin
    LEncoding := TUnicodeEncoding.Create;
    if InterlockedCompareExchangePointer(Pointer(FUnicodeEncoding), LEncoding, nil) <> nil then
      LEncoding.Free;
  end;
  Result := FUnicodeEncoding;
end;

class function TEncoding.GetUTF7: TEncoding;
var
  LEncoding: TEncoding;
begin
  if FUTF7Encoding = nil then
  begin
    LEncoding := TUTF7Encoding.Create;
    if InterlockedCompareExchangePointer(Pointer(FUTF7Encoding), LEncoding, nil) <> nil then
      LEncoding.Free;
  end;
  Result := FUTF7Encoding;
end;

class function TEncoding.GetUTF8: TEncoding;
var
  LEncoding: TEncoding;
begin
  if FUTF8Encoding = nil then
  begin
    LEncoding := TUTF8Encoding.Create;
    if InterlockedCompareExchangePointer(Pointer(FUTF8Encoding), LEncoding, nil) <> nil then
      LEncoding.Free;
  end;
  Result := FUTF8Encoding;
end;

class function TEncoding.IsStandardEncoding(AEncoding: TEncoding): Boolean;
begin
  Result :=
    (AEncoding <> nil) and
    ((AEncoding = FANSIEncoding) or
    (AEncoding = FUTF8Encoding) or
    (AEncoding = FUnicodeEncoding) or
    (AEncoding = FASCIIEncoding) or
    (AEncoding = FUTF7Encoding) or
    (AEncoding = FBigEndianUnicodeEncoding));
end;

{ TMBCSEncoding }

constructor TMBCSEncoding.Create;
begin
  Create(GetACP, 0, 0);
end;

constructor TMBCSEncoding.Create(CodePage: Integer);
begin
  FCodePage := CodePage;
  Create(CodePage, 0, 0);
end;

constructor TMBCSEncoding.Create(CodePage, MBToWCharFlags, WCharToMBFlags: Integer);
var
  LCPInfo: TCPInfo;
begin
  if CodePage = CP_ACP then
    FCodePage := GetACP
  else
    FCodePage := CodePage;
  FMBToWCharFlags := MBToWCharFlags;
  FWCharToMBFlags := WCharToMBFlags;

  if not GetCPInfo(FCodePage, LCPInfo) then
    raise EEncodingError.CreateRes(@SInvalidCodePage);
  FMaxCharSize := LCPInfo.MaxCharSize;
  FIsSingleByte := FMaxCharSize = 1;
end;

function TMBCSEncoding.Clone: TEncoding;
begin
  Result := TMBCSEncoding.Create(CodePage, FMBToWCharFlags, FWCharToMBFlags);
end;

function TMBCSEncoding.GetByteCount(Chars: PChar; CharCount: Integer): Integer;
begin
  Result := LocaleCharsFromUnicode(FCodePage, FWCharToMBFlags,
    PChar(Chars), CharCount, nil, 0, nil, nil);
end;

function TMBCSEncoding.GetBytes(Chars: PChar; CharCount: Integer; Bytes: PByte;
  ByteCount: Integer): Integer;
begin
  Result := LocaleCharsFromUnicode(FCodePage, FWCharToMBFlags,
    PChar(Chars), CharCount, PAnsiChar(Bytes), ByteCount, nil, nil);
end;

function TMBCSEncoding.GetCharCount(Bytes: PByte; ByteCount: Integer): Integer;
begin
  Result := UnicodeFromLocaleChars(FCodePage, FMBToWCharFlags,
    PAnsiChar(Bytes), ByteCount, nil, 0);
end;

function TMBCSEncoding.GetChars(Bytes: PByte; ByteCount: Integer; Chars: PChar;
  CharCount: Integer): Integer;
begin
  Result := UnicodeFromLocaleChars(FCodePage, FMBToWCharFlags,
    PAnsiChar(Bytes), ByteCount, Chars, CharCount);
end;

function TMBCSEncoding.GetCodePage: Cardinal;
begin
  Result := FCodePage;
end;

function TMBCSEncoding.GetEncodingName: string;
var
  LCPInfo: TCPInfoEx;
begin
  if GetCPInfoEx(FCodePage, 0, LCPInfo) then
    Result := LCPInfo.CodePageName
  else
    Result := '';
end;

function TMBCSEncoding.GetMaxByteCount(CharCount: Integer): Integer;
begin
  Result := (CharCount + 1) * FMaxCharSize;
end;

function TMBCSEncoding.GetMaxCharCount(ByteCount: Integer): Integer;
begin
  Result := ByteCount;
end;

function TMBCSEncoding.GetPreamble: TBytes;
begin
  case CodePage of
    1200: Result := TBytes.Create($FF, $FE);    // unicode
    1201: Result := TBytes.Create($FE, $FF);    // big-endian unicode
    CP_UTF8: Result := TBytes.Create($EF, $BB, $BF);
  else
    SetLength(Result, 0);
  end;
end;

{ TUTF7Encoding }

constructor TUTF7Encoding.Create;
begin
  inherited Create(CP_UTF7);
  FIsSingleByte := False;
end;

function TUTF7Encoding.Clone: TEncoding;
begin
  Result := TUTF7Encoding.Create;
end;

function TUTF7Encoding.GetMaxByteCount(CharCount: Integer): Integer;
begin
  Result := (CharCount * 3) + 2;
end;

function TUTF7Encoding.GetMaxCharCount(ByteCount: Integer): Integer;
begin
  Result := ByteCount;
end;

{ TUTF8Encoding }

constructor TUTF8Encoding.Create;
begin
  inherited Create(CP_UTF8, MB_ERR_INVALID_CHARS, 0);
  FIsSingleByte := False;
end;

function TUTF8Encoding.Clone: TEncoding;
begin
  Result := TUTF8Encoding.Create;
end;

function TUTF8Encoding.GetMaxByteCount(CharCount: Integer): Integer;
begin
  Result := (CharCount + 1) * 3;
end;

function TUTF8Encoding.GetMaxCharCount(ByteCount: Integer): Integer;
begin
  Result := ByteCount + 1;
end;

function TUTF8Encoding.GetPreamble: TBytes;
begin
  Result := TBytes.Create($EF, $BB, $BF);
end;

{ TUnicodeEncoding }

constructor TUnicodeEncoding.Create;
begin
  FIsSingleByte := False;
  FMaxCharSize := 4;
end;

function TUnicodeEncoding.Clone: TEncoding;
begin
  Result := TUnicodeEncoding.Create;
end;

function TUnicodeEncoding.GetByteCount(Chars: PChar; CharCount: Integer): Integer;
begin
  Result := CharCount * SizeOf(Char);
end;

function TUnicodeEncoding.GetBytes(Chars: PChar; CharCount: Integer;
  Bytes: PByte; ByteCount: Integer): Integer;
begin
  Result := CharCount * SizeOf(Char);
  Move(Chars^, Bytes^, Result);
end;

function TUnicodeEncoding.GetCharCount(Bytes: PByte; ByteCount: Integer): Integer;
begin
  Result := ByteCount div SizeOf(Char);
end;

function TUnicodeEncoding.GetChars(Bytes: PByte; ByteCount: Integer;
  Chars: PChar; CharCount: Integer): Integer;
begin
  Result := CharCount;
  Move(Bytes^, Chars^, CharCount * SizeOf(Char));
end;

function TUnicodeEncoding.GetCodePage: Cardinal;
begin
  Result := 1200; // UTF-16LE
end;

function TUnicodeEncoding.GetEncodingName: string;
begin
  Result := '1200  (Unicode)'; // do not localize
end;

function TUnicodeEncoding.GetMaxByteCount(CharCount: Integer): Integer;
begin
  Result := (CharCount + 1) * 2;
end;

function TUnicodeEncoding.GetMaxCharCount(ByteCount: Integer): Integer;
begin
  Result := (ByteCount div 2) + (ByteCount and 1) + 1;
end;

function TUnicodeEncoding.GetPreamble: TBytes;
begin
  Result := TBytes.Create($FF, $FE);
end;

{ TBigEndianUnicodeEncoding }

function TBigEndianUnicodeEncoding.Clone: TEncoding;
begin
  Result := TBigEndianUnicodeEncoding.Create;
end;

function TBigEndianUnicodeEncoding.GetBytes(Chars: PChar; CharCount: Integer;
  Bytes: PByte; ByteCount: Integer): Integer;
var
  I: Integer;
begin
  for I := 0 to CharCount - 1 do
  begin
    Bytes^ := Hi(Word(Chars^));
    Inc(Bytes);
    Bytes^ := Lo(Word(Chars^));
    Inc(Bytes);
    Inc(Chars);
  end;
  Result := CharCount * SizeOf(WideChar);
end;

function TBigEndianUnicodeEncoding.GetChars(Bytes: PByte; ByteCount: Integer;
  Chars: PChar; CharCount: Integer): Integer;
var
  P: PByte;
  I: Integer;
begin
  P := Bytes;
  Inc(P);
  for I := 0 to CharCount - 1 do
  begin
    Chars^ := WideChar(MakeWord(P^, Bytes^));
    Inc(Bytes, 2);
    Inc(P, 2);
    Inc(Chars);
  end;
  Result := CharCount;
end;

function TBigEndianUnicodeEncoding.GetCodePage: Cardinal;
begin
  Result := 1201; // UTF-16BE
end;

function TBigEndianUnicodeEncoding.GetEncodingName: string;
begin
  Result := '1201  (Unicode - Big-Endian)'; // do not localize
end;

function TBigEndianUnicodeEncoding.GetPreamble: TBytes;
begin
  Result := TBytes.Create($FE, $FF);
end;

{ TBytes/string conversion routines }

function BytesOf(const Val: RawByteString): TBytes;
var
  Len: Integer;
begin
  Len := Length(Val);
  SetLength(Result, Len);
  Move(Val[1], Result[0], Len);
end;

function BytesOf(const Val: UnicodeString): TBytes;
begin
  Result := TEncoding.Default.GetBytes(Val);
end;

function BytesOf(const Val: WideChar): TBytes;
begin
  Result := BytesOf(UnicodeString(Val));
end;

function BytesOf(const Val: AnsiChar): TBytes;
begin
  SetLength(Result, 1);
  Result[0] := Byte(Val);
end;

function StringOf(const Bytes: TBytes): UnicodeString;
begin
  if Assigned(Bytes) then
    Result := TEncoding.Default.GetString(Bytes, Low(Bytes), High(Bytes) + 1)
  else
    Result := '';
end;

function PlatformBytesOf(const Value: string): TBytes;
begin
  Result := TEncoding.Unicode.GetBytes(Value);
end;

function PlatformStringOf(const Value: TBytes): UnicodeString;
begin
  if Assigned(Value) then
  begin
    Result := TEncoding.Unicode.GetString(Value, Low(Value), High(Value) + 1);
  end
  else
    Result := '';
end;

function WideStringOf(const Value: TBytes): UnicodeString;
begin
  if Assigned(Value) then
    Result := TEncoding.Unicode.GetString(Value, Low(Value), High(Value) + 1)
  else
    Result := '';
end;

function WideBytesOf(const Value: UnicodeString): TBytes;
begin
  Result := TEncoding.Unicode.GetBytes(Value)
end;

end.
