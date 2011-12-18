unit sdaSystem;

interface

uses
  sdaWindows, sdaMessages;

const
  SDAM_BASE = WM_APP + $3000;
  SDAM_DESTROYWINDOW = SDAM_BASE + 1;
  SDAM_TRANSLATEACCEL = SDAM_BASE + 2; // lParam = @tagMSG, Result = FALSE/TRUE

type
  TSdamTranslateAccel = packed record
    Msg: UINT;
    Unused: WPARAM;
    Message: PMsg;
    Result: LRESULT;
  end;

procedure SdaSetLastError(Error: HRESULT);
function SdaGetLastError: HRESULT;

implementation

threadvar
  FSdaLastError: HRESULT;

procedure SdaSetLastError(Error: HRESULT);
begin
  FSdaLastError := Error;
end;

function SdaGetLastError: HRESULT;
begin
  Result := FSdaLastError;
end;

end.
