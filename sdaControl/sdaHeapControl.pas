unit sdaHeapControl;

interface

{$INCLUDE 'sda.inc'}

uses
  sdaWindows;

type
  TSdaHeapControl = record
  private
    FHandle: THandle;
  public
    property Handle: THandle read FHandle write FHandle;
    class operator Implicit(Value: THandle): TSdaHeapControl; inline;

    class function CreateHandle(EnableExecute: Boolean = false;
      InitialSize: Integer = 0): THandle; inline; static;
    procedure DestroyHandle; inline;

    function Alloc(Size: Integer): Pointer; inline;
    function ReAlloc(Ptr: Pointer; NewSize: Integer): Pointer; inline;
    procedure Free(Ptr: Pointer); inline;
    function MemSize(Ptr: Pointer): Integer; inline;

    function Lock: Boolean; inline;
    procedure Unlock; inline;

    function Validate(Ptr: Pointer = nil): Boolean; inline;
  end;

implementation

{ TSdaHeapControl }

function TSdaHeapControl.Alloc(Size: Integer): Pointer;
begin
  Result := HeapAlloc(Handle, HEAP_ZERO_MEMORY, Size);
end;

class function TSdaHeapControl.CreateHandle(EnableExecute: Boolean;
  InitialSize: Integer): THandle;
var
  dwFlags: DWORD;
begin
  if EnableExecute then dwFlags := HEAP_CREATE_ENABLE_EXECUTE
    else dwFlags := 0;
  Result := HeapCreate(dwFlags, InitialSize, 0);
end;

procedure TSdaHeapControl.DestroyHandle;
begin
  if HeapDestroy(Handle) then
    FHandle := 0;
end;

procedure TSdaHeapControl.Free(Ptr: Pointer);
begin
  HeapFree(Handle, 0, Ptr);
end;

class operator TSdaHeapControl.Implicit(Value: THandle): TSdaHeapControl;
begin
  Result.Handle := Value;
end;

function TSdaHeapControl.Lock: Boolean;
begin
  Result := HeapLock(Handle);
end;

function TSdaHeapControl.MemSize(Ptr: Pointer): Integer;
begin
  Result := HeapSize(Handle, 0, Ptr);
end;

function TSdaHeapControl.ReAlloc(Ptr: Pointer; NewSize: Integer): Pointer;
begin
  Result := HeapReAlloc(Handle, HEAP_ZERO_MEMORY, Ptr, NewSize);
end;

procedure TSdaHeapControl.Unlock;
begin
  HeapUnlock(Handle);
end;

function TSdaHeapControl.Validate(Ptr: Pointer): Boolean;
begin
  Result := HeapValidate(Handle, 0, Ptr);
end;

end.
