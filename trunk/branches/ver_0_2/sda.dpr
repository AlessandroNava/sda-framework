program sda;

{$INCLUDE 'sda.inc'}

{$R 'dlg.res' 'dlg.rc'}

uses
  Windows,
  sdaWinCreate in 'sdaWinCreate.pas',
  sdaWinControl in 'sdaWinControl.pas',
  sdaApplication in 'sdaApplication.pas',
  uDlgIDs in 'uDlgIDs.pas',
  sdaWinUtil in 'sdaWinUtil.pas',
  sdaSysUtils in 'sdaSysUtils.pas';

type
  TAppDlg = class(TSdaBaseDialog)
  protected
    function InitDialog(AFocusControl: HWND): Boolean; override;
    function CommandEvent(ItemID: Integer; EventCode: Integer): Boolean; override;
  end;

{ TAppDlg }

function TAppDlg.CommandEvent(ItemID, EventCode: Integer): Boolean;
var
  h: HWND;
begin
  if ItemID = IDCANCEL then
  begin
    if Application.ModalLevel > 0 then Application.EndModal(IDCANCEL)
      else Application.Terminate;
    Result := true;
  end else
  if ItemID = IDPAUSE then
  begin
    h := TAppDlg.CreateHandle(100, Handle);
    Application.BeginModal(h);
    Result := true;
  end else
  begin
    Result := inherited;
  end;
end;

function TAppDlg.InitDialog(AFocusControl: HWND): Boolean;
var
  c: TSdaWindowControl;
begin
  c := TSdaWindowControl.Create(Handle);
  try
    c.Left := (GetSystemMetrics(SM_CXSCREEN) - c.Width) div 2;
    c.Top := (GetSystemMetrics(SM_CYSCREEN) - c.Height) div 2;
    c.ClientHeight := 100;
    c.Show;
  finally
    FreeAndNil(c);
  end;
  Result := inherited InitDialog(AFocusControl);
end;

var
  h: HWND;

begin
  SdaApplicationInitialize;
  try
    h := TAppDlg.CreateHandle(100);
    Application.Run;
    DestroyWindow(h);
  finally
    SdaApplicationFinalize;
  end;
end.
