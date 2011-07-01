unit sdaModule;

interface

{$INCLUDE 'sda.inc'}

uses
  sdaWindows;

type
  TSdaModule = record
  private
    FHandle: HMODULE;
    function GetFileName: string;
    function GetProc(const Name: string): Pointer;
  public
    property Handle: HMODULE read FHandle write FHandle;
    class operator Implicit(Value: HMODULE): TSdaModule; inline;
    class function CreateHandle(const ModuleName: string;
      IncrementRefCounter: Boolean = true): HMODULE; overload; static;
    class function CreateHandle(const FileName: string): HMODULE; overload; static;

    procedure DestroyHandle;

    property FileName: string read GetFileName;
    property Proc[const Name: string]: Pointer read GetProc;

    procedure DisableThreadCalls;
  end;

implementation

{ TSdaModule }

class function TSdaModule.CreateHandle(const ModuleName: string;
  IncrementRefCounter: Boolean): HMODULE;
var
  dwFlags: DWORD;
begin
  if IncrementRefCounter then dwFlags := 0
    else dwFlags := GET_MODULE_HANDLE_EX_FLAG_UNCHANGED_REFCOUNT;
  if not GetModuleHandleEx(dwFlags, PChar(ModuleName), Result) then Result := 0;
end;

class function TSdaModule.CreateHandle(const FileName: string): HMODULE;
begin
  Result := LoadLibrary(PChar(FileName));
end;

procedure TSdaModule.DestroyHandle;
begin
  FreeLibrary(Handle);
end;

procedure TSdaModule.DisableThreadCalls;
begin
  DisableThreadLibraryCalls(Handle);
end;

function TSdaModule.GetFileName: string;
var
  Buffer: array [Word] of Char;
begin
  FillChar(Buffer, SizeOf(Buffer), 0);
  GetModuleFileName(Handle, Buffer, Length(Buffer));
  Result := Buffer;
end;

function TSdaModule.GetProc(const Name: string): Pointer;
begin
  Result := GetProcAddress(Handle, PChar(Name));
end;

class operator TSdaModule.Implicit(Value: HMODULE): TSdaModule;
begin
  Result.Handle := Value;
end;

end.
