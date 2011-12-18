unit sdaClasses;

interface

{$INCLUDE 'sda.inc'}

uses
  sdaSysUtils, {$IFDEF SDACLASSES_IMPLEMENT_ISTREAM}sdaWindows, sdaActiveX{$ENDIF};

type
  TSdaStrings = class(TObject)
  protected
    function GetCount: Integer; virtual; abstract;
    function GetStrings(Index: Integer): string; virtual; abstract;
    procedure SetCount(const Value: Integer); virtual; abstract;
    procedure SetStrings(Index: Integer; const Value: string); virtual; abstract;
    function GetText: string; virtual; abstract;
    procedure SetText(const Value: string); virtual; abstract;
    function GetLineSeparator: string; virtual; abstract;
    procedure SetLineSeparator(const Value: string); virtual; abstract;
  public
    property Strings[Index: Integer]: string read GetStrings write SetStrings; default;
    property Count: Integer read GetCount write SetCount;

    procedure Delete(Index: Integer); virtual; abstract;
    procedure Insert(Index: Integer; const Value: string); virtual; abstract;
    procedure Add(const Value: string); virtual; abstract;

    property LineSeparator: string read GetLineSeparator write SetLineSeparator;
    property Text: string read GetText write SetText;
  end;

  TSdaStringList = class(TSdaStrings)
  private
    FStrings: array of string;
    FLineSeparator: string;
  protected
    function GetCount: Integer; override;
    function GetStrings(Index: Integer): string; override;
    procedure SetCount(const Value: Integer); override;
    procedure SetStrings(Index: Integer; const Value: string); override;
    function GetText: string; override;
    procedure SetText(const Value: string); override;
    function GetLineSeparator: string; override;
    procedure SetLineSeparator(const Value: string); override;
  public
    procedure Add(const Value: string); override;
    procedure Delete(Index: Integer); override;
    procedure Insert(Index: Integer; const Value: string); override;
  end;

  TSeekOrigin = (soBeginning, soCurrent, soEnd);

  EReadError = class(Exception);
  EWriteError = class(Exception);

  TSdaStream = class({$IFDEF SDACLASSES_IMPLEMENT_ISTREAM}TInterfacedObject, IStream,
    ISequentialStream{$ELSE}TObject{$ENDIF})
  {$IFDEF SDACLASSES_IMPLEMENT_ISTREAM}
  strict private
    { ISequentialStream }
    function ISequentialStream.Read = ISS_Read;
    function ISequentialStream.Write = ISS_Write;
    function ISS_Read(pv: Pointer; cb: Longint; pcbRead: PLongint): HRESULT; stdcall;
    function ISS_Write(pv: Pointer; cb: Longint; pcbWritten: PLongint): HRESULT; stdcall;
    { IStream }
    function IStream.Read = ISS_Read;
    function IStream.Write = ISS_Write;
    function IStream.Seek = IS_Seek;
    function IStream.SetSize = IS_SetSize;
    function IStream.CopyTo = IS_CopyTo;
    function IStream.Commit = IS_Commit;
    function IStream.Revert = IS_Revert;
    function IStream.LockRegion = IS_LockRegion;
    function IStream.UnlockRegion = IS_UnlockRegion;
    function IStream.Stat = IS_Stat;
    function IStream.Clone = IS_Clone;

    function IS_Seek(dlibMove: Largeint; dwOrigin: Longint;
      out libNewPosition: Largeint): HRESULT; stdcall;
    function IS_SetSize(libNewSize: Largeint): HRESULT; stdcall;
    function IS_CopyTo(stm: IStream; cb: Largeint; out cbRead: Largeint;
      out cbWritten: Largeint): HRESULT; stdcall;
    function IS_Commit(grfCommitFlags: Longint): HRESULT; stdcall;
    function IS_Revert: HRESULT; stdcall;
    function IS_LockRegion(libOffset: Largeint; cb: Largeint;
      dwLockType: Longint): HRESULT; stdcall;
    function IS_UnlockRegion(libOffset: Largeint; cb: Largeint;
      dwLockType: Longint): HRESULT; stdcall;
    function IS_Stat(out statstg: TStatStg; grfStatFlag: Longint): HRESULT; stdcall;
    function IS_Clone(out stm: IStream): HRESULT; stdcall;
  {$ENDIF}
  strict private
    function GetPosition: Int64;
    procedure SetPosition(const Pos: Int64);
  strict protected
    function GetSize: Int64; virtual;
    procedure SetSize(const NewSize: Int64); virtual;
  public
    function Read(var Buffer; Count: Longint): Longint; virtual; abstract;
    function Write(const Buffer; Count: Longint): Longint; virtual; abstract;
    function Seek(const Offset: Int64; Origin: TSeekOrigin): Int64; virtual;
    procedure ReadBuffer(var Buffer; Count: Longint);
    procedure WriteBuffer(const Buffer; Count: Longint);
    function CopyFrom(Source: TSdaStream; Count: Int64): Int64;
    property Position: Int64 read GetPosition write SetPosition;
    property Size: Int64 read GetSize write SetSize;

    procedure WriteString(const Str: RawByteString);
    function ReadString: RawByteString;
  end;

implementation

resourcestring
  sCannotWriteString = 'Cannot write string to stream';
  sCannotReadString = 'Cannot read string from stream';

{ TSdaStringList }

procedure TSdaStringList.Add(const Value: string);
begin
  SetLength(FStrings, Length(FStrings) + 1);
  FStrings[High(FStrings)] := Value;
end;

procedure TSdaStringList.Delete(Index: Integer);
var
  i: Integer;
begin
  if (Index < 0) or (Index > High(FStrings)) then Exit;
  for i := Index to High(FStrings) - 1 do
    FStrings[i] := FStrings[i + 1];
  SetLength(FStrings, Length(FStrings) - 1);
end;

function TSdaStringList.GetCount: Integer;
begin
  Result := Length(FStrings);
end;

function TSdaStringList.GetLineSeparator: string;
begin
  Result := FLineSeparator;
end;

function TSdaStringList.GetStrings(Index: Integer): string;
begin
  if (Index < 0) or (Index > High(FStrings)) then Result := ''
    else Result := FStrings[Index];
end;

function TSdaStringList.GetText: string;
var
  i: Integer;
begin
  if Length(FStrings) <= 0 then Result := '' else
  begin
    Result := FStrings[0];
    for i := 1 to High(FStrings) do
      Result := Result + LineSeparator + FStrings[i];
  end;
end;

procedure TSdaStringList.Insert(Index: Integer; const Value: string);
var
  i: Integer;
begin
  if Index < 0 then Exit;
  SetLength(FStrings, Length(FStrings) + 1);
  for i := High(FStrings) downto Index + 1 do
    FStrings[i] := FStrings[i - 1];
  if Index > High(FStrings) then Index := High(FStrings);
  FStrings[Index] := Value;
end;

procedure TSdaStringList.SetCount(const Value: Integer);
begin
  SetLength(FStrings, Value);
end;

procedure TSdaStringList.SetLineSeparator(const Value: string);
begin
  FLineSeparator := Value;
end;

procedure TSdaStringList.SetStrings(Index: Integer; const Value: string);
begin
  if (Index < 0) or (Index > High(FStrings)) then Exit;
  FStrings[Index] := Value;
end;

procedure TSdaStringList.SetText(const Value: string);
var
  i, n, j, cnt: Integer;
begin
  SetLength(FStrings, 0);
  if Value = '' then Exit;
  n := Length(LineSeparator);
  if n = 0 then
  begin
    SetLength(FStrings, 1);
    FStrings[0] := Value;
  end else
  begin
    i := 1; cnt := 1;
    while i <= Length(Value) - n + 1 do
    begin
      if Copy(Value, i, n) = LineSeparator then
      begin
        Inc(cnt);
        Inc(i, n);
      end else Inc(i);
    end;
    SetLength(FStrings, cnt);
    j := 1;
    for i := 0 to High(FStrings) do
    begin
      n := PosEx(LineSeparator, Value, j);
      if n <= 0 then n := Length(Value) + 1;
      FStrings[i] := Copy(Value, j, n - j);
      j := n + Length(LineSeparator);
    end;
  end;
end;

{ TSdaStream }

{$IFDEF SDACLASSES_IMPLEMENT_ISTREAM}
function TSdaStream.ISS_Read(pv: Pointer; cb: Integer;
  pcbRead: PLongint): HRESULT;
var
  NumRead: Longint;
begin
  try
    if pv = nil then Exit(STG_E_INVALIDPOINTER);
    NumRead := Read(pv^, cb);
    if pcbRead <> Nil then pcbRead^ := NumRead;
    Result := S_OK;
  except
    Result := S_FALSE;
  end;
end;

function TSdaStream.ISS_Write(pv: Pointer; cb: Integer;
  pcbWritten: PLongint): HRESULT;
var
  NumWritten: Longint;
begin
  try
    if pv = nil then Exit(STG_E_INVALIDPOINTER);
    NumWritten := Write(pv^, cb);
    if pcbWritten <> Nil then pcbWritten^ := NumWritten;
    Result := S_OK;
  except
    Result := STG_E_CANTSAVE;
  end;
end;

function TSdaStream.IS_Clone(out stm: IStream): HRESULT;
begin
  Result := E_NOTIMPL;
end;

function TSdaStream.IS_Commit(grfCommitFlags: Integer): HRESULT;
begin
  Result := S_OK;
end;

function TSdaStream.IS_CopyTo(stm: IStream; cb: Largeint; out cbRead,
  cbWritten: Largeint): HRESULT;
const
  MaxBufSize = 1024 * 1024;  // 1mb
var
  Buffer: array of Byte;
  BufSize, n, i, r: Integer;
  BytesRead, BytesWritten, W: LargeInt;
begin
  Result := S_OK;
  BytesRead := 0;
  BytesWritten := 0;
  try
    if cb > MaxBufSize then BufSize := MaxBufSize else BufSize := Integer(cb);
    SetLength(Buffer, BufSize);
    while cb > 0 do
    begin
      if cb > MaxInt then i := MaxInt else i := cb;
      while i > 0 do
      begin
        if i > BufSize then n := BufSize else n := i;
        r := Read(Buffer[0], n);
        if r = 0 then Exit; // The end of the stream was hit.
        Inc(BytesRead, r);
        W := 0;
        Result := stm.Write(@Buffer[0], r, @W);
        Inc(BytesWritten, W);
        if (Result = S_OK) and (Integer(W) <> r) then Result := E_FAIL;
        if Result <> S_OK then Exit;
        Dec(i, r); Dec(cb, r);
      end;
    end;
    if (@cbWritten <> nil) then cbWritten := BytesWritten;
    if (@cbRead <> nil) then cbRead := BytesRead;
  except
    Result := E_UNEXPECTED;
  end;
end;

function TSdaStream.IS_LockRegion(libOffset, cb: Largeint;
  dwLockType: Integer): HRESULT;
begin
  Result := STG_E_INVALIDFUNCTION;
end;

function TSdaStream.IS_Revert: HRESULT;
begin
  Result := STG_E_REVERTED;
end;

function TSdaStream.IS_Seek(dlibMove: Largeint; dwOrigin: Integer;
  out libNewPosition: Largeint): HRESULT;
var
  NewPos: LargeInt;
begin
  try
    if (dwOrigin < STREAM_SEEK_SET) or (dwOrigin > STREAM_SEEK_END) then
      Exit(STG_E_INVALIDFUNCTION);
    NewPos := Seek(dlibMove, TSeekOrigin(dwOrigin));
    if @libNewPosition <> nil then libNewPosition := NewPos;
    Result := S_OK;
  except
    Result := STG_E_INVALIDPOINTER;
  end;
end;

function TSdaStream.IS_SetSize(libNewSize: Largeint): HRESULT;
begin
  try
    Size := libNewSize;
    if libNewSize <> Size then Result := E_FAIL else Result := S_OK;
  except
    Result := E_UNEXPECTED;
  end;
end;

function TSdaStream.IS_Stat(out statstg: TStatStg;
  grfStatFlag: Integer): HRESULT;
begin
  Result := S_OK;
  try
    if @statstg <> nil then
      with statstg do
      begin
        dwType := STGTY_STREAM;
        cbSize := Size;
        mTime.dwLowDateTime := 0;
        mTime.dwHighDateTime := 0;
        cTime.dwLowDateTime := 0;
        cTime.dwHighDateTime := 0;
        aTime.dwLowDateTime := 0;
        aTime.dwHighDateTime := 0;
        grfLocksSupported := LOCK_WRITE;
      end;
    if grfStatFlag and STATFLAG_NONAME = STATFLAG_NONAME then
      statstg.pwcsName := nil;
  except
    Result := E_UNEXPECTED;
  end;
end;

function TSdaStream.IS_UnlockRegion(libOffset, cb: Largeint;
  dwLockType: Integer): HRESULT;
begin
  Result := STG_E_INVALIDFUNCTION;
end;
{$ENDIF}

procedure TSdaStream.ReadBuffer(var Buffer; Count: Integer);
var
  LTotalCount,
  LReadCount: Longint;
begin
  { Perform a read directly. Most of the time this will succeed
    without the need to go into the WHILE loop. }
  LTotalCount := Read(Buffer, Count);
  while LTotalCount < Count do
  begin
    { Try to read a contiguous block of <Count> size }
    LReadCount := Read(PByte(NativeInt(@Buffer) + LTotalCount)^,
      Count - LTotalCount);
    { Check if we read something and decrease the number of bytes left to read }
    if LReadCount <= 0 then raise EReadError.Create('Stream read error')
      else Inc(LTotalCount, LReadCount);
  end
end;

function TSdaStream.ReadString: RawByteString;
var
  len: Integer;
begin
  Result := '';
  if Read(len, SizeOf(len)) <> SizeOf(len) then
    raise EReadError.Create(sCannotReadString);
  if len <= 0 then Exit;
    SetLength(Result, len);
  len := Read(Result[1], Length(Result));
  SetLength(Result, len);
end;

function TSdaStream.Seek(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
  Result := 0;
end;

procedure TSdaStream.SetPosition(const Pos: Int64);
begin
  Seek(Pos, soBeginning);
end;

procedure TSdaStream.SetSize(const NewSize: Int64);
begin
end;

procedure TSdaStream.WriteBuffer(const Buffer; Count: Integer);
begin
end;

procedure TSdaStream.WriteString(const Str: RawByteString);
var
  len: Integer;
begin
  len := Length(Str);
  if Write(len, SizeOf(len)) <> SizeOf(len) then
    raise EWriteError.Create(sCannotWriteString);
  if len <= 0 then Exit;
  if Write(Str[1], len) <> len then
    raise EWriteError.Create(sCannotWriteString);
end;

function TSdaStream.CopyFrom(Source: TSdaStream; Count: Int64): Int64;
const
  MaxBufSize = $F000;
var
  BufSize, N: Integer;
  Buffer: array of Byte;
begin
  if Count = 0 then
  begin
    Source.Position := 0;
    Count := Source.Size;
  end;
  Result := Count;
  if Count > MaxBufSize then BufSize := MaxBufSize else BufSize := Count;
  SetLength(Buffer, BufSize);
  while Count <> 0 do
  begin
    if Count > BufSize then N := BufSize else N := Count;
    Source.ReadBuffer(Buffer[0], N);
    WriteBuffer(Buffer[0], N);
    Dec(Count, N);
  end;
end;

function TSdaStream.GetPosition: Int64;
begin
  Result := Seek(0, soCurrent);
end;

function TSdaStream.GetSize: Int64;
var
  Pos: Int64;
begin
  Pos := Seek(0, soCurrent);
  Result := Seek(0, soEnd);
  Seek(Pos, soBeginning);
end;

end.
