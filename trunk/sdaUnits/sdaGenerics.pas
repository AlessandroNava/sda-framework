unit sdaGenerics;

interface

{$INCLUDE 'sda.inc'}

type
  TSdaListCompare<T> = reference to function(const A, B: T): Integer;

  TSdaList<T> = class(TObject)
  protected
    FItems: array of T;
  private
    function GetCount: Integer;
    function GetItems(Index: Integer): T;
    procedure SetItems(Index: Integer; const Value: T);
  public
    property Items[Index: Integer]: T read GetItems write SetItems; default;
    property Count: Integer read GetCount;

    function Add(const Item: T): Integer; virtual;
    procedure Delete(Index: Integer); virtual;
    procedure Remove(const Item: T; const Compare: TSdaListCompare<T>); virtual;
    procedure Clear; virtual;

    procedure Sort(const Compare: TSdaListCompare<T>);
  end;

  TSdaObjectList<T: class> = class(TSdaList<T>)
  private
    FOwnObjects: Boolean;
  public
    constructor Create(OwnObjects: Boolean = true);
    property OwnObjects: Boolean read FOwnObjects write FOwnObjects;
    procedure Delete(Index: Integer); override;
    procedure Clear; override;
  end;

implementation

{ TSdaList<T> }

function TSdaList<T>.Add(const Item: T): Integer;
begin
  SetLength(FItems, Length(FItems) + 1);
  FItems[High(FItems)] := Item;
  Result := High(Integer);
end;

procedure TSdaList<T>.Clear;
begin
  SetLength(FItems, 0);
end;

procedure TSdaList<T>.Delete(Index: Integer);
var
  i: Integer;
begin
  for i := Index to High(FItems) - 1 do
    FItems[i] := FItems[i + 1];
  SetLength(FItems, Length(FItems) - 1);
end;

function TSdaList<T>.GetCount: Integer;
begin
  Result := Length(FItems);
end;

function TSdaList<T>.GetItems(Index: Integer): T;
begin
  Result := FItems[Index];
end;

procedure TSdaList<T>.Remove(const Item: T; const Compare: TSdaListCompare<T>);
var
  i: Integer;
begin
  if not Assigned(Compare) then Exit;
  for i := 0 to High(FItems) do
    if Compare(FItems[i], Item) = 0 then
    begin
      Delete(i);
      Exit;
    end;
end;

procedure TSdaList<T>.SetItems(Index: Integer; const Value: T);
begin
  FItems[Index] := Value;
end;

procedure TSdaList<T>.Sort(const Compare: TSdaListCompare<T>);
var
  i, j: Integer;
  temp: T;
begin
  if not Assigned(Compare) then Exit;
  for i := High(FItems) downto 1 do
    for j := 0 to i - 1 do
      if Compare(FItems[i], FItems[j]) < 0 then
      begin
        temp := FItems[i]; FItems[i] := FItems[j]; FItems[j] := temp;
      end;
end;

{ TSdaObjectList<T> }

constructor TSdaObjectList<T>.Create(OwnObjects: Boolean);
begin
  inherited Create;
  FOwnObjects := OwnObjects;
end;

procedure TSdaObjectList<T>.Clear;
var
  i: Integer;
begin
  for i := 0 to High(FItems) do
    FItems[i].Free;
  inherited Clear;
end;

procedure TSdaObjectList<T>.Delete(Index: Integer);
begin
  FItems[Index].Free;
  inherited;
end;

end.
