unit sdaMenuControl;

interface

{$INCLUDE 'sda.inc'}

uses
  sdaWindows;

type
  TSdaMenuControl = record
  private
    FHandle: HMENU;
    function GetItemCount: Integer;
    procedure SetHandle(const Value: HMENU);
    function GetItemSubMenu(Index: Integer): HMENU;
    procedure SetItemSubMenu(Index: Integer; const Value: HMENU);
    function GetItemCaption(Index: Integer): string;
    procedure SetItemCaption(Index: Integer; const Value: string);
    function GetDefaultItem: Integer;
    procedure SetDefaultItem(const Value: Integer);
    function GetItemID(Index: Integer): Integer;
    procedure SetItemID(Index: Integer; const Value: Integer);
    function GetItemIsRadio(Index: Integer): Boolean;
    procedure SetItemIsRadio(Index: Integer; const Value: Boolean);
    function GetItemChecked(Index: Integer): Boolean;
    procedure SetItemChecked(Index: Integer; const Value: Boolean);
    function GetBackground: HBRUSH;
    procedure SetBackground(const Value: HBRUSH);
  public
    property Handle: HMENU read FHandle write SetHandle;
    procedure DestroyHandle; inline;
    class operator Implicit(Value: HMENU): TSdaMenuControl; inline;

    property ItemCaption[Index: Integer]: string read GetItemCaption
      write SetItemCaption;
    property ItemSubMenu[Index: Integer]: HMENU read GetItemSubMenu
      write SetItemSubMenu;
    property ItemID[Index: Integer]: Integer read GetItemID write SetItemID;
    property ItemCount: Integer read GetItemCount;
    property ItemIsRadio[Index: Integer]: Boolean read GetItemIsRadio
      write SetItemIsRadio;
    property ItemChecked[Index: Integer]: Boolean read GetItemChecked
      write SetItemChecked;
    property DefaultItem: Integer read GetDefaultItem write SetDefaultItem;

    procedure AddSeparator;
    procedure InsertSeparator(Index: Integer);

    procedure AddItem(ID: Integer; const Caption: string; Flags: DWORD); overload;
    procedure AddItem(ID: Integer; Bitmap: HBITMAP; Flags: DWORD); overload;
    procedure AddItem(ID: Integer; UserData: Pointer; Flags: DWORD); overload;

    procedure InsertItem(Index, ID: Integer; const Caption: string; Flags: DWORD); overload;
    procedure InsertItem(Index, ID: Integer; Bitmap: HBITMAP; Flags: DWORD); overload;
    procedure InsertItem(Index, ID: Integer; UserData: Pointer; Flags: DWORD); overload;

    procedure DeleteItem(Index: Integer);

    property Background: HBRUSH read GetBackground write SetBackground;
  end;

  TSdaPopupMenuControl = record
  private
    FHandle: HMENU;
    procedure SetHandle(const Value: HMENU);
  public
    property Handle: HMENU read FHandle write SetHandle;
    procedure DestroyHandle; inline;

    class operator Implicit(Value: HMENU): TSdaPopupMenuControl; inline;

    class function CreateHandle: HMENU; overload; inline; static;
    class function CreateHandle(Instance: HMODULE; MenuName: string;
      SubItemIndex: Integer = 0): HMENU; overload; static;
    class function CreateHandle(Window: HWND;
      ResetMenu: Boolean = false): HMENU; overload; inline; static;

    function Popup(Window: HWND; X, Y: Integer;
      Flags: DWORD = TPM_RETURNCMD or TPM_NONOTIFY): Integer; overload; inline;
    function Popup(Window: HWND; P: TPoint;
      Flags: DWORD = TPM_RETURNCMD or TPM_NONOTIFY): Integer; overload; inline;
    function Popup(Window: HWND; Flags: DWORD = TPM_RETURNCMD or TPM_NONOTIFY): Integer; overload; inline;

    procedure CheckRadioItem(ItemToCheck, FirstInGroup, LastInGroup: Integer);
  end;

  TSdaMainMenuControl = record
  private
    FHandle: HMENU;
    procedure SetHandle(const Value: HMENU);
  public
    property Handle: HMENU read FHandle write SetHandle;
    procedure DestroyHandle; inline;
    class operator Implicit(Value: HMENU): TSdaMainMenuControl;  inline;
    class function CreateHandle: HMENU; overload; inline; static;
    class function CreateHandle(Instance: HMODULE;
      MenuName: string): HMENU; overload; inline; static;
    class function CreateHandle(Window: HWND): HMENU; overload; inline; static;

    class procedure DrawMenuBar(Window: HWND); inline; static;
    procedure Apply(Window: HWND); inline;

    procedure HiliteItem(Window: HWND; Index: Integer; Hilite: Boolean); inline;
  end;

implementation

{ TSdaPopupMenu }

procedure TSdaMenuControl.AddItem(ID: Integer; const Caption: string;
  Flags: DWORD);
begin
  AppendMenu(Handle, Flags or MF_BYPOSITION and not (MF_BITMAP or MF_OWNERDRAW), ID, PChar(Caption));
end;

procedure TSdaMenuControl.AddItem(ID: Integer; Bitmap: HBITMAP;
  Flags: DWORD);
begin
  AppendMenu(Handle, Flags or MF_BYPOSITION or MF_BITMAP and not MF_OWNERDRAW, ID, PChar(Bitmap));
end;

procedure TSdaMenuControl.AddItem(ID: Integer; UserData: Pointer;
  Flags: DWORD);
begin
  AppendMenu(Handle, Flags or MF_BYPOSITION or MF_OWNERDRAW and not MF_BITMAP, ID, UserData);
end;

procedure TSdaMenuControl.AddSeparator;
begin
  InsertSeparator(ItemCount);
end;

procedure TSdaMenuControl.DeleteItem(Index: Integer);
begin
  DeleteMenu(Handle, Index, MF_BYPOSITION);
end;

procedure TSdaMenuControl.DestroyHandle;
begin
  if DestroyMenu(FHandle) then
    FHandle := 0;
end;

function TSdaMenuControl.GetBackground: HBRUSH;
var
  mi: TMenuInfo;
begin
  FillChar(mi, SizeOf(mi), 0);
  mi.cbSize := SizeOf(mi);
  mi.fMask := MIM_BACKGROUND;
  GetMenuInfo(Handle, mi);
  Result := mi.hbrBack;
end;

function TSdaMenuControl.GetDefaultItem: Integer;
begin
  Result := GetMenuDefaultItem(Handle, DWORD(-1), GMDI_USEDISABLED);
end;

function TSdaMenuControl.GetItemCaption(Index: Integer): string;
var
  mii: MENUITEMINFO;
begin
  FillChar(mii, SizeOf(mii), 0);
  mii.cbSize := SizeOf(mii);
  mii.fMask := MIIM_STRING;
  GetMenuItemInfo(Handle, Index, true, mii);

  SetLength(Result, mii.cch + 1);
  mii.dwTypeData := PChar(Result);
  mii.cch := Length(Result);
  GetMenuItemInfo(Handle, Index, true, mii);
  Result := PChar(Result);
end;

function TSdaMenuControl.GetItemChecked(Index: Integer): Boolean;
var
  mii: MENUITEMINFO;
begin
  FillChar(mii, SizeOf(mii), 0);
  mii.cbSize := SizeOf(mii);
  mii.fMask := MIIM_STATE;
  GetMenuItemInfo(Handle, Index, true, mii);
  Result := mii.fState and MFS_CHECKED = MFS_CHECKED;
end;

function TSdaMenuControl.GetItemCount: Integer;
begin
  Result := GetMenuItemCount(Handle);
end;

function TSdaMenuControl.GetItemID(Index: Integer): Integer;
var
  mii: MENUITEMINFO;
begin
  FillChar(mii, SizeOf(mii), 0);
  mii.cbSize := SizeOf(mii);
  mii.fMask := MIIM_ID;
  GetMenuItemInfo(Handle, Index, true, mii);
  Result := mii.wID;
end;

function TSdaMenuControl.GetItemIsRadio(Index: Integer): Boolean;
var
  mii: MENUITEMINFO;
begin
  FillChar(mii, SizeOf(mii), 0);
  mii.cbSize := SizeOf(mii);
  mii.fMask := MIIM_FTYPE;
  GetMenuItemInfo(Handle, Index, true, mii);
  Result := mii.fType and MFT_RADIOCHECK = MFT_RADIOCHECK;
end;

function TSdaMenuControl.GetItemSubMenu(Index: Integer): HMENU;
begin
  Result := GetSubMenu(Handle, Index);
end;

procedure TSdaMenuControl.InsertItem(Index, ID: Integer;
  const Caption: string; Flags: DWORD);
begin
  InsertMenu(Handle, Index, Flags or MF_BYPOSITION and not (MF_BITMAP or MF_OWNERDRAW),
    ID, PChar(Caption));
end;

procedure TSdaMenuControl.InsertItem(Index, ID: Integer; Bitmap: HBITMAP;
  Flags: DWORD);
begin
  InsertMenu(Handle, Index, Flags or MF_BITMAP or MF_BYPOSITION and not MF_OWNERDRAW,
    ID, PChar(Bitmap));
end;

class operator TSdaMenuControl.Implicit(Value: HMENU): TSdaMenuControl;
begin
  Result.Handle := Value;
end;

procedure TSdaMenuControl.InsertItem(Index, ID: Integer; UserData: Pointer;
  Flags: DWORD);
begin
  InsertMenu(Handle, Index, Flags or MF_OWNERDRAW or MF_BYPOSITION and not MF_BITMAP, ID, UserData);
end;

procedure TSdaMenuControl.InsertSeparator(Index: Integer);
var
  mii: MENUITEMINFO;
begin
  FillChar(mii, SizeOf(mii), 0);
  mii.cbSize := SizeOf(mii);
  mii.fMask := MIIM_FTYPE;
  mii.fType := MFT_SEPARATOR;
  InsertMenuItem(Handle, Index, true, mii);
end;

procedure TSdaMenuControl.SetBackground(const Value: HBRUSH);
var
  mi: TMenuInfo;
begin
  FillChar(mi, SizeOf(mi), 0);
  mi.cbSize := SizeOf(mi);
  mi.fMask := MIM_BACKGROUND or MIM_APPLYTOSUBMENUS;
  mi.hbrBack := Value;
  SetMenuInfo(Handle, mi);
end;

procedure TSdaMenuControl.SetDefaultItem(const Value: Integer);
begin
  SetMenuDefaultItem(Handle, Value, DWORD(-1));
end;

procedure TSdaMenuControl.SetHandle(const Value: HMENU);
begin
  if IsMenu(Value) then FHandle := Value
    else FHandle := 0;
end;

procedure TSdaMenuControl.SetItemCaption(Index: Integer;
  const Value: string);
var
  mii: MENUITEMINFO;
begin
  FillChar(mii, SizeOf(mii), 0);
  mii.cbSize := SizeOf(mii);
  mii.fMask := MIIM_STRING;
  mii.dwTypeData := PChar(Value);
  SetMenuItemInfo(Handle, Index, true, mii);
end;

procedure TSdaMenuControl.SetItemChecked(Index: Integer; const Value: Boolean);
var
  mii: MENUITEMINFO;
begin
  FillChar(mii, SizeOf(mii), 0);
  mii.cbSize := SizeOf(mii);
  mii.fMask := MIIM_STATE;
  GetMenuItemInfo(Handle, Index, true, mii);
  if Value then mii.fState := mii.fState or MFS_CHECKED
    else mii.fState := mii.fState and not MFS_CHECKED;
  SetMenuItemInfo(Handle, Index, true, mii);
end;

procedure TSdaMenuControl.SetItemID(Index: Integer; const Value: Integer);
var
  mii: MENUITEMINFO;
begin
  FillChar(mii, SizeOf(mii), 0);
  mii.cbSize := SizeOf(mii);
  mii.fMask := MIIM_ID;
  mii.wID := Value;
  SetMenuItemInfo(Handle, Index, true, mii);
end;

procedure TSdaMenuControl.SetItemIsRadio(Index: Integer;
  const Value: Boolean);
var
  mii: MENUITEMINFO;
begin
  FillChar(mii, SizeOf(mii), 0);
  mii.cbSize := SizeOf(mii);
  mii.fMask := MIIM_FTYPE;
  GetMenuItemInfo(Handle, Index, true, mii);
  if Value then mii.fType := mii.fType or MFT_RADIOCHECK
    else mii.fType := mii.fType and not MFT_RADIOCHECK;
  SetMenuItemInfo(Handle, Index, true, mii);
end;

procedure TSdaMenuControl.SetItemSubMenu(Index: Integer;
  const Value: HMENU);
var
  mii: MENUITEMINFO;
begin
  FillChar(mii, SizeOf(mii), 0);
  mii.cbSize := SizeOf(mii);
  mii.fMask := MIIM_SUBMENU;
  mii.hSubMenu := Value;
  SetMenuItemInfo(Handle, Index, true, mii);
end;

{ TSdaPopupMenuControl }

class function TSdaPopupMenuControl.CreateHandle: HMENU;
begin
  Result := CreatePopupMenu;
end;

class function TSdaPopupMenuControl.CreateHandle(Instance: HMODULE; MenuName: string;
  SubItemIndex: Integer): HMENU;
var
  hm: HMENU;
begin
  hm := LoadMenu(Instance, PChar(MenuName));
  if hm = 0 then Exit(0);
  Result := GetSubMenu(hm, SubItemIndex);
  RemoveMenu(hm, SubItemIndex, MF_BYPOSITION);
  DestroyMenu(hm);
end;

class function TSdaPopupMenuControl.CreateHandle(Window: HWND;
  ResetMenu: Boolean): HMENU;
begin
  Result := GetSystemMenu(Window, ResetMenu);
end;

procedure TSdaPopupMenuControl.DestroyHandle;
begin
  DestroyMenu(FHandle);
  FHandle := 0;
end;

class operator TSdaPopupMenuControl.Implicit(Value: HMENU): TSdaPopupMenuControl;
begin
  Result.Handle := Value;
end;

function TSdaPopupMenuControl.Popup(Window: HWND; X, Y: Integer;
  Flags: DWORD): Integer;
begin
  Result := Integer(TrackPopupMenuEx(Handle, Flags, X, Y, Window, nil));
end;

function TSdaPopupMenuControl.Popup(Window: HWND; P: TPoint;
  Flags: DWORD): Integer;
begin
  Result := Popup(Window, P.X, P.Y, Flags);
end;

function TSdaPopupMenuControl.Popup(Window: HWND; Flags: DWORD): Integer;
var
  p: TPoint;
begin
  GetCursorPos(p);
  Result := Popup(Window, p.X, p.Y, Flags);
end;

procedure TSdaPopupMenuControl.SetHandle(const Value: HMENU);
begin
  if IsMenu(Value) then FHandle := Value
    else FHandle := 0;
end;

procedure TSdaPopupMenuControl.CheckRadioItem(ItemToCheck, FirstInGroup,
  LastInGroup: Integer);
begin
  CheckMenuRadioItem(Handle, FirstInGroup, LastInGroup, ItemToCheck, MF_BYPOSITION);
end;

{ TSdaMainMenuControl }

class function TSdaMainMenuControl.CreateHandle: HMENU;
begin
  Result := CreateMenu;
end;

class function TSdaMainMenuControl.CreateHandle(Instance: HMODULE;
  MenuName: string): HMENU;
begin
  Result := LoadMenu(Instance, PChar(MenuName));
end;

procedure TSdaMainMenuControl.Apply(Window: HWND);
begin
  SetMenu(Window, Handle);
end;

class function TSdaMainMenuControl.CreateHandle(Window: HWND): HMENU;
begin
  Result := GetMenu(Window);
end;

procedure TSdaMainMenuControl.DestroyHandle;
begin
  DestroyMenu(FHandle);
  FHandle := 0;
end;

class procedure TSdaMainMenuControl.DrawMenuBar(Window: HWND);
begin
  sdaWindows.DrawMenuBar(Window);
end;

class operator TSdaMainMenuControl.Implicit(Value: HMENU): TSdaMainMenuControl;
begin
  Result.Handle := Value;
end;

procedure TSdaMainMenuControl.SetHandle(const Value: HMENU);
begin
  if IsMenu(Value) then FHandle := Value
    else FHandle := 0;
end;

procedure TSdaMainMenuControl.HiliteItem(Window: HWND; Index: Integer; Hilite: Boolean);
begin
  if Hilite then HiliteMenuItem(Window, Handle, Index, MF_BYPOSITION or MF_HILITE)
    else HiliteMenuItem(Window, Handle, Index, MF_BYPOSITION or MF_UNHILITE);
end;

end.
