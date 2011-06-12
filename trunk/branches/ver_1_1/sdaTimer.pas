unit sdaTimer;

interface

uses
  Windows, Messages, sdaSysUtils;

type
  TSdaTimerEvent = procedure(TimerID: Integer) of object;

  TSdaTimer = record
  private
    FWindow: HWND;
    FID: Integer;
    FOnTimer: TSdaTimerEvent;
    procedure SetID(const Value: Integer);
    procedure SetWindow(const Value: HWND);
  public
    property Window: HWND read FWindow write SetWindow;
    property ID: Integer read FID write SetID;
    property OnTimer: TSdaTimerEvent read FOnTimer write FOnTimer;
    procedure Enable(AnInterval: Integer);
    procedure Disable;
    procedure Elapsed;
  end;

implementation

{ TSdaTimer }

procedure TSdaTimer.Disable;
begin
  if (Window <> 0) and (ID <> 0) then
    KillTimer(Window, ID);
end;

procedure TSdaTimer.Elapsed;
begin
  if Assigned(OnTimer) then OnTimer(ID);
end;

procedure TSdaTimer.Enable(AnInterval: Integer);
begin
  if (Window <> 0) and (ID <> 0) then
  begin
    KillTimer(Window, ID);
    SetTimer(Window, ID, AnInterval, nil);
  end;
end;

procedure TSdaTimer.SetID(const Value: Integer);
begin
  if Value <> ID then
  begin
    Disable;
    FID := Value;
  end;
end;

procedure TSdaTimer.SetWindow(const Value: HWND);
begin
  if Value <> Window then
  begin
    Disable;
    FWindow := Value;
  end;
end;

end.
