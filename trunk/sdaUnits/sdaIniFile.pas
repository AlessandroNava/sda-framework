unit sdaIniFile;

interface

{$INCLUDE 'sda.inc'}

uses
  sdaWindows;

type
  TSdaWinIniFile = {$IFDEF FPC}object{$ELSE}record{$ENDIF}
    procedure WriteString(const Section, Key, Value: string);
    function ReadString(const Section, Key, Default: string): string;

    procedure DeleteSection(const Section: string);
    procedure DeleteKey(const Section, Key: string);

    function ReadSectionNames: string;
    function ReadSectionKeys(const Section: string): string;

    procedure UpdateFile;
  end;

  TSdaIniFile = {$IFDEF FPC}object{$ELSE}record{$ENDIF}
  private
    FFileName: string;
  public
    property FileName: string read FFileName write FFileName;

    procedure WriteString(const Section, Key, Value: string);
    function ReadString(const Section, Key, Default: string): string;

    procedure DeleteSection(const Section: string);
    procedure DeleteKey(const Section, Key: string);

    function ReadSectionNames: string;
    function ReadSectionKeys(const Section: string): string;

    procedure UpdateFile;
  end;

implementation

uses
  sdaSysUtils;

{ TSdaIniFile }

procedure TSdaIniFile.DeleteKey(const Section, Key: string);
begin
  WritePrivateProfileString(PChar(Section), PChar(Key), nil, PChar(FileName));
end;

procedure TSdaIniFile.DeleteSection(const Section: string);
begin
  WritePrivateProfileString(PChar(Section), nil, nil, PChar(FileName));
end;

function TSdaIniFile.ReadSectionKeys(const Section: string): string;
var
  Buf: array [Word] of Char; // Maximun size of whole section is 64 Kb
  p: PChar;
begin
  FillChar(Buf, SizeOf(Buf), 0);
  GetPrivateProfileString(PChar(Section), nil, nil, Buf, Length(Buf),
    PChar(FileName));
  p := Buf; Result := '';
  while Length(p) > 0 do
  begin
    if Result = '' then Result := p
      else Result := Result + #13#10 + p;
    Inc(p, Length(p) + 1);
  end;
end;

function TSdaIniFile.ReadSectionNames: string;
var
  Buf: array [Word] of Char; // Maximun size of whole section is 64 Kb
  p: PChar;
begin
  FillChar(Buf, SizeOf(Buf), 0);
  GetPrivateProfileString(nil, nil, nil, Buf, Length(Buf), PChar(FileName));
  p := Buf; Result := '';
  while Length(p) > 0 do
  begin
    if Result = '' then Result := p
      else Result := Result + #13#10 + p;
    Inc(p, Length(p) + 1);
  end;
end;

function TSdaIniFile.ReadString(const Section, Key, Default: string): string;
var
  Buf: array [Word] of Char; // Maximun size of whole section is 64 Kb
  n: Integer;
begin
  FillChar(Buf, SizeOf(Buf), 0);
  n := GetPrivateProfileString(PChar(Section), PChar(Key), PChar(Default),
    Buf, Length(Buf), PChar(FileName));
  Result := Copy(Buf, 1, n);
end;

procedure TSdaIniFile.UpdateFile;
begin
  WritePrivateProfileString(nil, nil, nil, PChar(FileName));
end;

procedure TSdaIniFile.WriteString(const Section, Key, Value: string);
begin
  WritePrivateProfileString(PChar(Section), PChar(Key), PChar(Value), PChar(FileName));
end;

{ TSdaWinIniFile }

procedure TSdaWinIniFile.DeleteKey(const Section, Key: string);
begin
  WriteProfileString(PChar(Section), PChar(Key), nil);
end;

procedure TSdaWinIniFile.DeleteSection(const Section: string);
begin
  WriteProfileString(PChar(Section), nil, nil);
end;

function TSdaWinIniFile.ReadSectionKeys(const Section: string): string;
var
  Buf: array [Word] of Char; // Maximun size of whole section is 64 Kb
  p: PChar;
begin
  FillChar(Buf, SizeOf(Buf), 0);
  GetProfileString(PChar(Section), nil, nil, Buf, Length(Buf));
  p := Buf; Result := '';
  while Length(p) > 0 do
  begin
    if Result = '' then Result := p
      else Result := Result + #13#10 + p;
    Inc(p, Length(p) + 1);
  end;
end;

function TSdaWinIniFile.ReadSectionNames: string;
var
  Buf: array [Word] of Char; // Maximun size of whole section is 64 Kb
  p: PChar;
begin
  FillChar(Buf, SizeOf(Buf), 0);
  GetProfileString(nil, nil, nil, Buf, Length(Buf));
  p := Buf; Result := '';
  while Length(p) > 0 do
  begin
    if Result = '' then Result := p
      else Result := Result + #13#10 + p;
    Inc(p, Length(p) + 1);
  end;
end;

function TSdaWinIniFile.ReadString(const Section, Key, Default: string): string;
var
  Buf: array [Word] of Char; // Maximun size of whole section is 64 Kb
  n: Integer;
begin
  FillChar(Buf, SizeOf(Buf), 0);
  n := GetProfileString(PChar(Section), PChar(Key), PChar(Default), Buf, Length(Buf));
  Result := Copy(Buf, 1, n);
end;

procedure TSdaWinIniFile.UpdateFile;
begin
  WriteProfileString(nil, nil, nil);
end;

procedure TSdaWinIniFile.WriteString(const Section, Key, Value: string);
begin
  WriteProfileString(PChar(Section), PChar(Key), PChar(Value));
end;

end.
