program sda;

{$INCLUDE 'sda.inc'}

{$R 'dlg.res' 'dlg.rc'}

uses
  Windows,
  Messages,
  sdaWinCreate in 'sdaWinCreate.pas',
  sdaWinControl in 'sdaWinControl.pas',
  sdaApplication in 'sdaApplication.pas',
  uDlgIDs in 'uDlgIDs.pas';

type
  TAppDlg = class(TSdaDialogObject)
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
      else PostQuitMessage(0);
    Result := true;
  end else
  if ItemID = IDPAUSE then
  begin
    h := TAppDlg.CreateHandle(100, Handle);
    Application.BeginModal(h);
    DestroyWindow(h);
    Result := true;
  end else
  begin
    Result := inherited;
  end;
end;

function TAppDlg.InitDialog(AFocusControl: HWND): Boolean;
begin
  SetWindowPos(Handle, 0, 150, 100, 0, 0, SWP_NOSIZE or SWP_NOZORDER or SWP_NOACTIVATE);
  Result := inherited InitDialog(AFocusControl);
end;

begin
  SdaApplicationInitialize;
  try
    Application.Handle := TAppDlg.CreateHandle(100);
    Application.Run;
  finally
    SdaApplicationFinalize;
  end;
end.
