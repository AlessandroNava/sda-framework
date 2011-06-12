unit sdaSysUtils;

interface

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

function FloatToStr(const Value: Extended): string; overload;

function StrToInt(const Value: string): Int64;
function StrToFloat(const Value: string): Extended;
function StrToIntDef(const Value: string; const Default: Int64): Int64;
function StrToFloatDef(const Value: string; const Default: Extended): Extended;

procedure FreeAndNil(var Obj);

implementation

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

end.
