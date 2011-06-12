unit sdaWinControl;

{$INCLUDE 'sda.inc'}

interface

uses
  Windows, Messages;

type
  TWindowControl = class(TObject)
  strict private
    function GetSDAObject: TObject; protected
  strict protected
    FHandle: HWND;
    function GetHandle: HWND; virtual;
    function GetCaption: string;
    function GetExStyle: DWORD;
    function GetStyle: DWORD;
    procedure SetHandle(const Value: HWND);
    procedure SetCaption(const Value: string);
    procedure SetExStyle(const Value: DWORD);
    procedure SetStyle(const Value: DWORD);
  public
    constructor Create(AWindow: HWND);

    property Handle: HWND read GetHandle write SetHandle;

    property SDAObject: TObject read GetSDAObject;

    property Style: DWORD read GetStyle write SetStyle;
    property ExStyle: DWORD read GetExStyle write SetExStyle;
    property Caption: string read GetCaption write SetCaption;
  end;

implementation

const
  sSDAAssociatedObjectProp = 'PROP_SDA_Associated_Object';

{ TWindowsControl }

constructor TWindowControl.Create(AWindow: HWND);
begin
  inherited Create;
  FHandle := AWindow;
end;

function TWindowControl.GetSDAObject: TObject;
begin
  Result := TObject(GetProp(FHandle, sSDAAssociatedObjectProp));
end;

function TWindowControl.GetCaption: string;
var
  nLen: Integer;
begin
  nLen := GetWindowTextLength(FHandle);
  SetLength(Result, nLen);
  if Result <> '' then
  nLen := GetWindowText(FHandle, PChar(Result), Length(Result));
  SetLength(Result, nLen);
end;

function TWindowControl.GetExStyle: DWORD;
begin
  Result := GetWindowLongPtr(FHandle, GWL_EXSTYLE);
end;

function TWindowControl.GetHandle: HWND;
begin
  Result := FHandle;
end;

function TWindowControl.GetStyle: DWORD;
begin
  Result := GetWindowLongPtr(FHandle, GWL_STYLE);
end;

procedure TWindowControl.SetCaption(const Value: string);
begin
  SetWindowText(FHandle, Value);
end;

procedure TWindowControl.SetExStyle(const Value: DWORD);
begin
  SetWindowLongPtr(FHandle, GWL_EXSTYLE, Value);
end;

procedure TWindowControl.SetHandle(const Value: HWND);
begin
  FHandle := Value;
end;

procedure TWindowControl.SetStyle(const Value: DWORD);
begin
  SetWindowLongPtr(FHandle, GWL_STYLE, Value);
end;

end.
