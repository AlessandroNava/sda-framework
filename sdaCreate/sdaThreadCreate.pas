unit sdaThreadCreate;

interface

{$INCLUDE 'sda.inc'}

uses
  sdaWindows;

type
  TSdaThreadCreate = class(TObject)
  private
    FExitCode: Integer;
    FFatalException: TObject;
  protected
    procedure Execute; virtual;
  public
    constructor Create; virtual;
    destructor Destroy; override;

    property FatalException: TObject read FFatalException write FFatalException;
    property ExitCode: Integer read FExitCode write FExitCode;
  end;

  TSdaThreadClass = class of TSdaThreadCreate;

function SdaCreateThread(ThreadClass: TSdaThreadClass; CreateSuspended: Boolean = false;
  StackSize: Integer = 0; Id: PUINT = nil): THandle;

implementation

function SdaThreadProc(lpParameter: LPVOID): DWORD; stdcall;
var
  Obj: TSdaThreadCreate absolute lpParameter;
begin
  Result := 0;
  if Assigned(Obj) then
  try
    try
      Obj.ExitCode := 0;
      OutputDebugString(PChar(Obj.ClassName));
      Obj.Execute;
      Result := Obj.ExitCode;
    except
      Obj.FatalException := AcquireExceptionObject;
    end;
  finally
    Obj.Free;
  end;
end;

function SdaCreateThread(ThreadClass: TSdaThreadClass; CreateSuspended: Boolean;
  StackSize: Integer; Id: PUINT): THandle;
const
  Flags: array [Boolean] of DWORD = (0, CREATE_SUSPENDED);
var
  Obj: TSdaThreadCreate;
begin
  if not Assigned(ThreadClass) then Exit(0);
  Obj := ThreadClass.Create;
  Result := CreateThread(nil, StackSize, @SdaThreadProc, Obj,
    Flags[CreateSuspended], Id^);
  if Result = 0 then Obj.Free;
end;

{ TSdaThreadCreate }

constructor TSdaThreadCreate.Create;
begin
  inherited Create;
end;

destructor TSdaThreadCreate.Destroy;
begin
  if Assigned(FatalException) then
    FatalException.Free;
  inherited;
end;

procedure TSdaThreadCreate.Execute;
begin
end;

end.
