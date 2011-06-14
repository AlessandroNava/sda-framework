unit sdaProcess;

interface

{$INCLUDE 'sda.inc'}

uses
  sdaWindows;

type
  TProcessDefaultLayout = (LayoutLTR = LAYOUT_LTR, LayoutRTL = LAYOUT_RTL);

  TSdaProcess = record
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
  end;

var
  Process: TSdaProcess;

implementation

var
  FMainThread: THandle;
  FMainThreadId: UINT;

{ TSdaProcess }

class function TSdaProcess.GetCommandLine: string;
begin
  Result := GetCommandLine;
end;

class function TSdaProcess.GetDefaultLayout: TProcessDefaultLayout;
var
  dw: DWORD;
begin
  GetProcessDefaultLayout(dw);
  Result := TProcessDefaultLayout(dw);
end;

class function TSdaProcess.GetExeName: string;
begin
  Result := ParamStr(0);
end;

class function TSdaProcess.GetHandle: THandle;
begin
  Result := GetCurrentProcess;
end;

class function TSdaProcess.GetID: UINT;
begin
  Result := GetCurrentProcessId;
end;

class function TSdaProcess.GetMainThread: THandle;
begin
  Result := FMainThread;
end;

class function TSdaProcess.GetMainThreadId: UINT;
begin
  Result := FMainThreadId;
end;

class function TSdaProcess.GetParamCount: Integer;
begin
  Result := System.ParamCount;
end;

class function TSdaProcess.GetParams(Index: Integer): string;
begin
  Result := ParamStr(Index);
end;

class procedure TSdaProcess.SetDefaultLayout(const Value: TProcessDefaultLayout);
begin
  SetProcessDefaultLayout(DWORD(Value));
end;

initialization
  FMainThread := GetCurrentThread;
  FMainThreadId := GetCurrentThreadId;
end.
