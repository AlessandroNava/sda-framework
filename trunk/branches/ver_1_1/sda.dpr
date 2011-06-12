program sda;

{$INCLUDE 'sda.inc'}

{$R 'dlg.res' 'dlg.rc'}

uses
  Windows,
  Messages,
  sdaWinControl in 'sdaWinControl.pas',
  sdaApplication in 'sdaApplication.pas',
  sdaWinCreate in 'sdaWinCreate.pas',
  sdaSysUtils in 'sdaSysUtils.pas',
  sdaDlgControl in 'sdaDlgControl.pas',
  sdaNotifyIcon in 'sdaNotifyIcon.pas',
  sdaTimer in 'sdaTimer.pas',
  sdaInput in 'sdaInput.pas',
  sdaScreen in 'sdaScreen.pas';

const
  IDCTL_LABEL_HINT    = 101;
  IDCTL_PROGRESSBAR   = 102;
  IDPAUSE             = 103;
  IDCTL_LABEL_SUBHINT = 105;

type
  TAppDlg = class(TSdaDialogObject)
  private
    FTray: TSdaNotifyIcon;
  protected
    function InitDialog(AFocusControl: HWND): Boolean; override;
    function CommandEvent(ItemID: Integer; EventCode: Integer): Boolean; override;
    procedure BeforeDestroyHandle; override;
  end;

{ TAppDlg }

procedure TAppDlg.BeforeDestroyHandle;
begin
  FTray.HideIcon;
end;

function TAppDlg.CommandEvent(ItemID, EventCode: Integer): Boolean;
begin
  if ItemID = IDCANCEL then
  begin
    if Application.ModalLevel > 0 then Application.EndModal(IDCANCEL)
      else Application.Terminate;
    Result := true;
  end else
  if ItemID = IDPAUSE then
  begin
    FTray.ShowBalloonHint('Hello', 'Hello, World!', BalloonInfo, 10);
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
  c := Handle;
  c.Left := (Screen.Width - c.Width) div 2;
  c.Top := (Screen.Height - c.Height) div 2;
  Result := inherited InitDialog(AFocusControl);

  FTray.Window := Handle;
  FTray.ID := 1;
  FTray.Message := WM_USER + 1000;
  FTray.Icon := LoadImage(HInstance, '#1', IMAGE_ICON, 16, 16, LR_COLOR);
  FTray.Hint := 'Hello, World!';
  FTray.ShowIcon;

  ShowWindow(Handle, SW_SHOW);
end;

begin
  SdaApplicationInitialize;
  try
    TAppDlg.CreateHandle(100);
    Application.Run;
  finally
    SdaApplicationFinalize;
  end;
end.
