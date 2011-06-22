unit sdaAccelControl;

interface

{$INCLUDE 'sda.inc'}

uses
  sdaWindows;

type
  TAccelEntry = record
    Flags: set of (afAlt, afControl, afShift);
    Command: Integer;
    case IsVirtual: Boolean of
    true:  ( VKey: Word; );
    false: ( Key: Char;  );
  end;

  TSdaAccelControl = record
  private
    FHandle: HACCEL;
    function GetCount: Integer;
  public
    property Handle: HACCEL read FHandle write FHandle;
    class operator Implicit(Value: HACCEL): TSdaAccelControl;
    class function CreateHandle(Instance: HINST; const ResName: string): HACCEL; overload; static;
    class function CreateHandle(const Entries: array of TAccelEntry): HACCEL; overload; static;
    class function CreateHandle(Entries: array of ACCEL): HACCEL; overload; static;
    procedure DestroyHandle;

    function Duplicate: HACCEL;

    property Count: Integer read GetCount;
    procedure GetEntries(var Dest: array of ACCEL); overload;
    procedure GetEntries(var Dest: array of TAccelEntry); overload;

    function Translate(Window: HWND; var Message: TMsg): Boolean;
  end;

implementation

{ TSdaAccelControl }

class function TSdaAccelControl.CreateHandle(Instance: HINST;
  const ResName: string): HACCEL;
begin
  Result := LoadAccelerators(Instance, PChar(ResName));
end;

class function TSdaAccelControl.CreateHandle(
  const Entries: array of TAccelEntry): HACCEL;
var
  ent: array of ACCEL;
  i: Integer;
begin
  if Length(Entries) <= 0 then Exit(0);
  SetLength(ent, Length(Entries));
  for i := 0 to High(Entries) do
  begin
    ent[i].cmd := Entries[i].Command;
    ent[i].key := Entries[i].VKey;
    ent[i].fVirt := 0;
    if afShift   in Entries[i].Flags then ent[i].fVirt := ent[i].fVirt or FSHIFT;
    if afControl in Entries[i].Flags then ent[i].fVirt := ent[i].fVirt or FCONTROL;
    if afAlt     in Entries[i].Flags then ent[i].fVirt := ent[i].fVirt or FALT;
    if Entries[i].IsVirtual then ent[i].fVirt := ent[i].fVirt or FVIRTKEY;
  end;
  Result := CreateHandle(ent);
end;

class function TSdaAccelControl.CreateHandle(Entries: array of ACCEL): HACCEL;
begin
  if Length(Entries) <= 0 then Exit(0);
  Result := CreateAcceleratorTable(Entries, Length(Entries));
end;

procedure TSdaAccelControl.DestroyHandle;
begin
  DestroyAcceleratorTable(Handle);
  FHandle := 0;
end;

function TSdaAccelControl.Duplicate: HACCEL;
var
  ent: array of ACCEL;
  n: Integer;
begin
  if Handle = 0 then Exit(0);
  n := CopyAcceleratorTable(Handle, PByte(nil)^, 0);
  if n <= 0 then Exit(0);
  SetLength(ent, n);
  FillChar(ent[0], Length(ent) * SizeOf(ent[0]), 0);
  if CopyAcceleratorTable(Handle, ent[0], Length(ent)) <= 0 then Exit(0);
  Result := CreateAcceleratorTable(ent, Length(ent));
end;

function TSdaAccelControl.GetCount: Integer;
begin
  Result := CopyAcceleratorTable(Handle, PByte(nil)^, 0);
end;

procedure TSdaAccelControl.GetEntries(var Dest: array of ACCEL);
begin
  if Length(Dest) <= 0 then Exit;
  FillChar(Dest[0], Length(Dest) * SizeOf(Dest[0]), 0);
  CopyAcceleratorTable(Handle, Dest, Length(Dest));
end;

procedure TSdaAccelControl.GetEntries(var Dest: array of TAccelEntry);
var
  ent: array of ACCEL;
  i: Integer;
begin
  if Length(Dest) <= 0 then Exit;
  FillChar(ent[0], Length(ent) * SizeOf(ent[0]), 0);
  SetLength(ent, Length(Dest));
  CopyAcceleratorTable(Handle, ent[0], Length(ent));
  for i := 0 to High(Dest) do
  begin
    Dest[i].Command := ent[i].cmd;
    Dest[i].VKey := ent[i].key;
    Dest[i].IsVirtual := ent[i].fVirt and FVIRTKEY = FVIRTKEY;
    Dest[i].Flags := [];
    if ent[i].fVirt and FSHIFT = FSHIFT then Include(Dest[i].Flags, afShift);
    if ent[i].fVirt and FCONTROL = FCONTROL then Include(Dest[i].Flags, afControl);
    if ent[i].fVirt and FALT = FALT then Include(Dest[i].Flags, afAlt);
  end;
end;

class operator TSdaAccelControl.Implicit(Value: HACCEL): TSdaAccelControl;
begin
  Result.Handle := Value;
end;

function TSdaAccelControl.Translate(Window: HWND; var Message: TMsg): Boolean;
begin
  if Handle = 0 then Exit(false);
  Result := TranslateAccelerator(Window, Handle, Message) <> 0;
end;

end.
