unit sdaProcess;

interface

{$INCLUDE 'sda.inc'}

uses
  sdaWindows;

type
  TProcessDefaultLayout = (LayoutLTR = LAYOUT_LTR, LayoutRTL = LAYOUT_RTL);

  TSdaCurrentProcess = record
  private
    class function GetCommandLine: string; static;
    class function GetHandle: THandle; static;
    class function GetId: UINT; static;
    class function GetParamCount: Integer; static;
    class function GetParams(Index: Integer): string; static;
    class function GetExeName: string; static;
    class function GetMainThread: THandle; static;
    class function GetMainThreadId: UINT; static;
    class function GetDefaultLayout: TProcessDefaultLayout; static;
    class procedure SetDefaultLayout(const Value: TProcessDefaultLayout); static;
  public
    class property Handle: THandle read GetHandle;
    class property Id: UINT read GetId;
    class property ParamCount: Integer read GetParamCount;
    class property Params[Index: Integer]: string read GetParams;
    class property CommandLine: string read GetCommandLine;
    class property ExeName: string read GetExeName;
    class property MainThread: THandle read GetMainThread;
    class property MainThreadId: UINT read GetMainThreadId;
    class property DefaultLayout: TProcessDefaultLayout read GetDefaultLayout
      write SetDefaultLayout;

//    class procedure EnablePrivilege(const Name: string); static;
//    class procedure DisablePrivilege(const Name: string); static;
  end;

var
  Process: TSdaCurrentProcess;

implementation

var
  FMainThread: THandle;
  FMainThreadId: UINT;

{ TSdaProcess }

(*class procedure TSdaProcess.DisablePrivilege(const Name: string);
var
  hToken: DWORD;
  SeDebugNameValue: Int64;
  tkp: TOKEN_PRIVILEGES;
  ReturnLength: DWORD;
begin
  if not OpenProcessToken(INVALID_HANDLE_VALUE, TOKEN_ADJUST_PRIVILEGES or
    TOKEN_QUERY, hToken) then Exit;
  try
    if not LookupPrivilegeValue(nil, PChar(Name), SeDebugNameValue) then Exit;

    tkp.PrivilegeCount := 1;
    tkp.Privileges[0].Luid := SeDebugNameValue;
    tkp.Privileges[0].Attributes := 0; // Disable

    if not AdjustTokenPrivileges(hToken, false, tkp, SizeOf(TOKEN_PRIVILEGES),
      tkp, ReturnLength) then Exit;
  finally
    CloseHandle(hToken);
  end;
end;

class procedure TSdaProcess.EnablePrivilege(const Name: string);
var
  hToken: DWORD;
  SeDebugNameValue: Int64;
  tkp: TOKEN_PRIVILEGES;
  ReturnLength: DWORD;
begin
  if not OpenProcessToken(INVALID_HANDLE_VALUE, TOKEN_ADJUST_PRIVILEGES or
    TOKEN_QUERY, hToken) then Exit;
  try
    if not LookupPrivilegeValue(nil, PChar(Name), SeDebugNameValue) then Exit;

    tkp.PrivilegeCount := 1;
    tkp.Privileges[0].Luid := SeDebugNameValue;
    tkp.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;

    if not AdjustTokenPrivileges(hToken, false, tkp, SizeOf(TOKEN_PRIVILEGES),
      tkp, ReturnLength) then Exit;
  finally
    CloseHandle(hToken);
  end;
end; *)

class function TSdaCurrentProcess.GetCommandLine: string;
begin
  Result := GetCommandLine;
end;

class function TSdaCurrentProcess.GetDefaultLayout: TProcessDefaultLayout;
var
  dw: DWORD;
begin
  GetProcessDefaultLayout(dw);
  Result := TProcessDefaultLayout(dw);
end;

class function TSdaCurrentProcess.GetExeName: string;
begin
  Result := ParamStr(0);
end;

class function TSdaCurrentProcess.GetHandle: THandle;
begin
  Result := GetCurrentProcess;
end;

class function TSdaCurrentProcess.GetID: UINT;
begin
  Result := GetCurrentProcessId;
end;

class function TSdaCurrentProcess.GetMainThread: THandle;
begin
  Result := FMainThread;
end;

class function TSdaCurrentProcess.GetMainThreadId: UINT;
begin
  Result := FMainThreadId;
end;

class function TSdaCurrentProcess.GetParamCount: Integer;
begin
  Result := System.ParamCount;
end;

class function TSdaCurrentProcess.GetParams(Index: Integer): string;
begin
  Result := ParamStr(Index);
end;

class procedure TSdaCurrentProcess.SetDefaultLayout(const Value: TProcessDefaultLayout);
begin
  SetProcessDefaultLayout(DWORD(Value));
end;

initialization
  FMainThread := GetCurrentThread;
  FMainThreadId := GetCurrentThreadId;
end.
