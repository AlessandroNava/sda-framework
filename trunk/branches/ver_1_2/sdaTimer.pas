unit sdaTimer;

interface

uses
  Windows, Messages, sdaSysUtils;

type
  TSdaTimer = record
  private
    FWindow: HWND;
    FID: Integer;
    procedure SetID(const Value: Integer);
    procedure SetWindow(const Value: HWND);
  public
    property Window: HWND read FWindow write SetWindow;
    property ID: Integer read FID write SetID;
    procedure Enable(AnInterval: Integer);
    procedure Disable;
  end;

implementation

{ TSdaTimer }

procedure TSdaTimer.Disable;
begin
  if (Window <> 0) and (ID <> 0) then
    KillTimer(Window, ID);
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
