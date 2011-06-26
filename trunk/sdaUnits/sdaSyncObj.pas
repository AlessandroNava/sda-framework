unit sdaSyncObj;

interface

uses
  sdaWindows;

type
  TSdaCriticalSection = record
  private
    FCS: RTL_CRITICAL_SECTION;
  public
    procedure Initialize;
    procedure Destroy;

    procedure Enter;
    procedure Leave;
    function TryEnter: Boolean;
  end;

  TSdaEvent = record
  private
    FHandle: THandle;
  public
    property Handle: THandle read FHandle write FHandle;
    class operator Implicit(Value: THandle): TSdaEvent; inline;
    class function CreateHandle(InitialState,
      ManualReset: Boolean): THandle; overload; inline; static;
    class function CreateHandle(const Name: string;
      InitialState, ManualReset: Boolean): THandle; overload; inline; static;
    class function CreateHandle(const Name: string): THandle; overload; inline; static;
    procedure DestroyHandle; inline;

    procedure SetEvent; inline;
    procedure ResetEvent; inline;

    function WaitFor(Timeout: DWORD = INFINITE): DWORD; inline;
  end;

  TSynchronizeMethod = procedure(Data: Pointer) of object;

  TSdaSynchronize = record
  private type
    TSyncEntry = record
      Method: TSynchronizeMethod;
      Event: THandle;
      Data: Pointer;
    end;
  private
    FSync: array of TSyncEntry;
    FCS: RTL_CRITICAL_SECTION;
  public
    procedure Initialize;
    procedure Destroy;

    procedure Synchronize(const Method: TSynchronizeMethod; Data: Pointer = nil);
    procedure CheckSynchronize;
  end;

implementation

{ TSdaCriticalSection }

procedure TSdaCriticalSection.Initialize;
begin
  InitializeCriticalSection(FCS);
end;

procedure TSdaCriticalSection.Destroy;
begin
  DeleteCriticalSection(FCS);
  FillChar(FCS, SizeOf(FCS), 0);
end;

procedure TSdaCriticalSection.Enter;
begin
  EnterCriticalSection(FCS);
end;

procedure TSdaCriticalSection.Leave;
begin
  LeaveCriticalSection(FCS);
end;

function TSdaCriticalSection.TryEnter: Boolean;
begin
  Result := TryEnterCriticalSection(FCS);
end;

{ TSdaEvent }

class function TSdaEvent.CreateHandle(InitialState, ManualReset: Boolean): THandle;
begin
  Result := CreateEvent(nil, ManualReset, InitialState, nil);
end;

class function TSdaEvent.CreateHandle(const Name: string; InitialState,
  ManualReset: Boolean): THandle;
begin
  Result := CreateEvent(nil, ManualReset, InitialState, PChar(Name));
end;

class function TSdaEvent.CreateHandle(const Name: string): THandle;
begin
  Result := OpenEvent(SYNCHRONIZE or _DELETE or READ_CONTROL or EVENT_MODIFY_STATE,
    false, PChar(Name));
end;

procedure TSdaEvent.DestroyHandle;
begin
  CloseHandle(Handle);
  FHandle := 0;
end;

class operator TSdaEvent.Implicit(Value: THandle): TSdaEvent;
begin
  Result.Handle := Value;
end;

procedure TSdaEvent.ResetEvent;
begin
  sdaWindows.ResetEvent(Handle);
end;

procedure TSdaEvent.SetEvent;
begin
  sdaWindows.SetEvent(Handle);
end;

function TSdaEvent.WaitFor(Timeout: DWORD): DWORD;
begin
  Result := WaitForSingleObject(Handle, Timeout);
end;

{ TSdaSynchronize }

procedure TSdaSynchronize.Initialize;
begin
  InitializeCriticalSection(FCS);
end;

procedure TSdaSynchronize.Synchronize(const Method: TSynchronizeMethod;
  Data: Pointer);
var
  Event: THandle;
begin
  EnterCriticalSection(FCS);
  try
    SetLength(FSync, Length(FSync) + 1);
    FSync[High(FSync)].Method := Method;
    FSync[High(FSync)].Data := Data;
    Event := CreateEvent(nil, true, false, nil);
    FSync[High(FSync)].Event := Event;
  finally
    LeaveCriticalSection(FCS);
  end;
  WaitForSingleObject(Event, INFINITE);
  CloseHandle(Event);
end;

procedure TSdaSynchronize.CheckSynchronize;
var
  i: Integer;
begin
  EnterCriticalSection(FCS);
  try
    for i := 0 to High(FSync) do
    begin
      if Assigned(FSync[i].Method) then
        FSync[i].Method(FSync[i].Data);
      SetEvent(FSync[i].Event);
    end;
    SetLength(FSync, 0);
  finally
    LeaveCriticalSection(FCS);
  end;
end;

procedure TSdaSynchronize.Destroy;
begin
  CheckSynchronize;
  DeleteCriticalSection(FCS);
end;

end.
