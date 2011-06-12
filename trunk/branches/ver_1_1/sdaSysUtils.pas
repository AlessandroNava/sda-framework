unit sdaSysUtils;

interface

uses
  Windows;

type
  Exception = class(TObject)
  strict private
    FMessage: string;
    FInnerException: TObject;
  public
    constructor Create(const Msg: string);
    destructor Destroy; override;
    function ToString: string; override;
    property Message: string read FMessage write FMessage;
    property InnerException: TObject read FInnerException;
  end;

function IntToStr(const Value: Integer): string; overload;
function IntToStr(const Value: Int64): string; overload;

function BoolToStr(const Value: Boolean; UseBoolStrings: Boolean = true): string;
function StrToBool(const Value: string): Boolean;

function FloatToStr(const Value: Extended): string; overload;

function StrToInt(const Value: string): Int64;
function StrToFloat(const Value: string): Extended;
function StrToIntDef(const Value: string; const Default: Int64): Int64;
function StrToFloatDef(const Value: string; const Default: Extended): Extended;

function Point(X, Y: Integer): TPoint; overload; inline;
function Point(P: TSmallPoint): TPoint; overload; inline;
function Point(P: TPoint): TSmallPoint; overload; inline;

function Rect(Left, Top, Right, Bottom: Integer): TRect; overload; inline;
function Bounds(Left, Top, Width, Height: Integer): TRect; inline;
function Rect(const ARect: TSmallRect): TRect; overload; inline;
function Rect(const ARect: TRect): TSmallRect; overload; inline;

procedure StrLCopy(const Dest, Src: PChar; nLen: Integer);

procedure FreeAndNil(var Obj); inline;

function Min(A, B: Integer): Integer; inline;
function Max(A, B: Integer): Integer; inline;

implementation

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

function BoolToStr(const Value: Boolean; UseBoolStrings: Boolean = true): string;
const
  sBool: array[Boolean, Boolean] of string = (('0', 'false'), ('1', 'true'));
begin
  Result := sBool[Value, UseBoolStrings];
end;

function StrToBool(const Value: string): Boolean;
begin
  // TODO: Implement this
  Result := false;
end;

{ Exception class }

constructor Exception.Create(const Msg: string);
begin
  inherited Create;
  FMessage := Msg;
  FInnerException := AcquireExceptionObject;
end;

destructor Exception.Destroy;
begin
  if Assigned(InnerException) then
    InnerException.Free;
  inherited Destroy;
end;

function Exception.ToString: string;
var
  Inner: TObject;
begin
  Result := Message;
  Inner := InnerException;
  while Assigned(Inner) do
  begin
    Result := Result + #13#10 + Inner.ToString;
    if Inner is Exception then
      Inner := Exception(Inner).InnerException;
  end;
end;

function IntToStr(const Value: Integer): string;
begin
  {$WARNINGS OFF}
  Str(Value, Result);
  {$WARNINGS ON}
end;

function IntToStr(const Value: Int64): string;
begin
  {$WARNINGS OFF}
  Str(Value, Result);
  {$WARNINGS ON}
end;

function FloatToStr(const Value: Extended): string;
begin
  {$WARNINGS OFF}
  Str(Value, Result);
  {$WARNINGS ON}
end;

function StrToInt(const Value: string): Int64;
var
  e: Integer;
begin
  Val(Value, Result, e);
  if e > 0 then ;
end;

function StrToFloat(const Value: string): Extended;
var
  e: Integer;
begin
  Val(Value, Result, e);
  if e > 0 then ;
end;

function StrToIntDef(const Value: string; const Default: Int64): Int64;
var
  e: Integer;
begin
  Val(Value, Result, e);
  if e > 0 then Result := Default;
end;

function StrToFloatDef(const Value: string; const Default: Extended): Extended;
var
  e: Integer;
begin
  Val(Value, Result, e);
  if e > 0 then Result := Default;
end;

procedure FreeAndNil(var Obj);
var
  Temp: TObject;
begin
  Temp := TObject(Obj);
  Pointer(Obj) := nil;
  Temp.Free;
end;

procedure StrLCopy(const Dest, Src: PChar; nLen: Integer);
var
  i: Integer;
begin
  for i := 0 to nLen - 1 do
  begin
    if Src[i] = #0 then Break;
    Dest[i] := Src[i];
  end;
end;

end.
