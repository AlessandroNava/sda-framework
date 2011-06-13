unit sdaThreads;

interface

{$INCLUDE 'sda.inc'}

uses
  sdaWindows;

function SdaGetMainThread: THandle;
function SdaGetMainThreadId: UINT;

implementation

var
  FMainThread: THandle;
  FMainThreadId: UINT;

function SdaGetMainThread: THandle;
begin
  Result := FMainThread;
end;

function SdaGetMainThreadId: UINT;
begin
  Result := FMainThreadId;
end;

initialization
  FMainThread := GetCurrentThread;
  FMainThreadId := GetCurrentThreadId;
end.
