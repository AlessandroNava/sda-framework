unit sdaClasses;

interface

{$INCLUDE 'sda.inc'}

type
  TSdaStrings = class abstract(TObject)
  private
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

implementation

uses
  sdaSysUtils;

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

end.
