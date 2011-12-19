unit sdaFileUtils;

interface

{$INCLUDE 'sda.inc'}

uses
  sdaWindows;

resourcestring
  SCannotCreateDir = 'Unable to create directory';

type
{ Generic filename type }

  TFileName = type string;

{ Search record used by FindFirst, FindNext, and FindClose }

  TSearchRec = record
  private
    function GetTimeStamp: TDateTime;
  public
    Time: Integer platform deprecated;
    Size: Int64;
    Attr: Integer;
    Name: TFileName;
    ExcludeAttr: Integer;
    FindHandle: THandle platform;
    FindData: TWin32FindData platform;
    property TimeStamp: TDateTime read GetTimeStamp;

    function First(const Path: string; Attr: Integer): Boolean; inline;
    function Next: Boolean; inline;
    procedure Close; inline;
  end;

  TDateTimeInfoRec = record
  private
    Data: TWin32FindData platform;
    function GetCreationTime: TDateTime;
    function GetLastAccessTime: TDateTime;
    function GetTimeStamp: TDateTime;
  public
    property CreationTime: TDateTime read GetCreationTime;
    property LastAccessTime: TDateTime read GetLastAccessTime;
    property TimeStamp: TDateTime read GetTimeStamp;
  end;

{ File management routines }

{ FileOpen opens the specified file using the specified access mode. The
  access mode value is constructed by OR-ing one of the fmOpenXXXX constants
  with one of the fmShareXXXX constants. If the return value is positive,
  the function was successful and the value is the file handle of the opened
  file. A return value of -1 indicates that an error occurred. }

function FileOpen(const FileName: string; Mode: LongWord): THandle;

{ FileCreate creates a new file by the specified name. If the return value
  is positive, the function was successful and the value is the file handle
  of the new file. A return value of -1 indicates that an error occurred.
  On Linux, this calls FileCreate(FileName, DEFFILEMODE) to create
  the file with read and write access for the current user only.  }

function FileCreate(const FileName: string): THandle; overload;

{ This second version of FileCreate lets you specify the access rights to put on the newly
  created file.  The access rights parameter is ignored on Win32 }

function FileCreate(const FileName: string; Rights: Integer): THandle; overload;

{ This third version of FileCreate lets you specify the share mode for the newly
  created file. }

function FileCreate(const FileName: string; Mode: LongWord; Rights: Integer): THandle; overload;

{ FileCreateSymLink creates a symbolic link. The parameter Link is the name of
  the symbolic link created and Target is the string contained in the symbolic
  link. }

function FileCreateSymLink(const Link, Target: string): Boolean;

{ FileSystemAttributes returns the file system attributes of the path\file given
  by Path. The attributes can contain any of the following:

  fsCaseSensitive - The file system is case sensitive.
  fsCasePreserving - The file system is case preserving but not necessarily case
                     sensitive.
  fsLocal - The drive is a local drive to the computer.
  fsNetwork - The drive is a networked drive.
  fsRemovable - The drive is removable. This could be a USB drive, CD ROM or a
                mounted volume.
  fsSymLink - The file system supports symbolic links.

  If the specified path does not exist then the exception
  EDirectoryNotFoundException is raised. If an OS error occurs then the
  exception EOSError is raised. }

type
  TFileSystemAttribute = (fsCaseSensitive, fsCasePreserving, fsLocal,
    fsNetwork, fsRemovable, fsSymLink);
  TFileSystemAttributes = set of TFileSystemAttribute;

function FileSystemAttributes(const Path: string): TFileSystemAttributes;

{ FileRead reads Count bytes from the file given by Handle into the buffer
  specified by Buffer. The return value is the number of bytes actually
  read; it is less than Count if the end of the file was reached. The return
  value is -1 if an error occurred. }

function FileRead(Handle: THandle; var Buffer; Count: LongWord): Integer;

{ FileWrite writes Count bytes to the file given by Handle from the buffer
  specified by Buffer. The return value is the number of bytes actually
  written, or -1 if an error occurred. }

function FileWrite(Handle: THandle; const Buffer; Count: LongWord): Integer;

{ FileSeek changes the current position of the file given by Handle to be
  Offset bytes relative to the point given by Origin. Origin = 0 means that
  Offset is relative to the beginning of the file, Origin = 1 means that
  Offset is relative to the current position, and Origin = 2 means that
  Offset is relative to the end of the file. The return value is the new
  current position, relative to the beginning of the file, or -1 if an error
  occurred. }

function FileSeek(Handle: THandle; Offset, Origin: Integer): Integer; overload;
function FileSeek(Handle: THandle; const Offset: Int64; Origin: Integer): Int64; overload;

{ FileClose closes the specified file. }

procedure FileClose(Handle: THandle); inline;

{ FileAge returns the date-and-time stamp of the specified file. The return
  value can be converted to a TDateTime value using the FileDateToDateTime
  function. The return value is -1 if the file does not exist. This version
  does not support date-and-time stamps prior to 1980 and after 2107. If the
  specified file is a symlink then the function is performed on the target
  file. }

function FileAge(const FileName: string): Integer; overload; deprecated;

{ FileAge retrieves the date-and-time stamp of the specified file as a
  TDateTime. This version supports all valid NTFS date-and-time stamps
  and returns a boolean value that indicates whether the specified file
  exists. If the specified file is a symlink the function is performed on
  the target file. If FollowLink is false then the date-and-time of the
  symlink file is returned. }

function FileAge(const FileName: string; out FileDateTime: TDateTime): Boolean; overload;

{ FileExists returns a boolean value that indicates whether the specified
  file exists. If the specified file is a symlink the function is performed on
  the target file. If FollowLink is false then the symlink file is used
  regardless if the link is broken or is a link to a directory. }

function FileExists(const FileName: string; FollowLink: Boolean = True): Boolean;

{ DirectoryExists returns a boolean value that indicates whether the
  specified directory exists (and is actually a directory). If the specified
  directory is a symlink the function is performed on the target directory. If
  FollowLink is false then the symlink file is used. If the link is broken
  DirectoryExists will always return false. }

function DirectoryExists(const Directory: string; FollowLink: Boolean = True): Boolean;

{ ForceDirectories ensures that all the directories in a specific path exist.
  Any portion that does not already exist will be created.  Function result
  indicates success of the operation.  The function can fail if the current
  user does not have sufficient file access rights to create directories in
  the given path.  }

function ForceDirectories(Dir: string): Boolean;

{ FindFirst searches the directory given by Path for the first entry that
  matches the filename given by Path and the attributes given by Attr. The
  result is returned in the search record given by SearchRec. The return
  value is zero if the function was successful. Otherwise the return value
  is a system error code. After calling FindFirst, always call FindClose.
  FindFirst is typically used with FindNext and FindClose as follows:

    Result := FindFirst(Path, Attr, SearchRec);
    while Result = 0 do
    begin
      ProcessSearchRec(SearchRec);
      Result := FindNext(SearchRec);
    end;
    FindClose(SearchRec);

  where ProcessSearchRec represents user-defined code that processes the
  information in a search record. }

function FindFirst(const Path: string; Attr: Integer;
  var F: TSearchRec): Integer;

{ FindNext returs the next entry that matches the name and attributes
  specified in a previous call to FindFirst. The search record must be one
  that was passed to FindFirst. The return value is zero if the function was
  successful. Otherwise the return value is a system error code. }

function FindNext(var F: TSearchRec): Integer;

{ FindClose terminates a FindFirst/FindNext sequence and frees memory and system
  resources allocated by FindFirst.
  Every FindFirst/FindNext must end with a call to FindClose. }

procedure FindClose(var F: TSearchRec);

{ FileGetDate returns the OS date-and-time stamp of the file given by
  Handle. The return value is -1 if the handle is invalid. The
  FileDateToDateTime function can be used to convert the returned value to
  a TDateTime value. }

function FileGetDate(Handle: THandle): Integer;

{ FileGetDateTimeInfo returns the date-and-time stamp of the specified file
  and supports all valid NTFS date-and-time stamps. A boolena value is returned
  indicating whether the specified file exists. If the specified file is a
  symlink the function is performed on the target file. If FollowLink is false
  then the date-and-time of the symlink file is returned. }

function FileGetDateTimeInfo(const FileName: string;
  out DateTime: TDateTimeInfoRec): Boolean;

{ FileSetDate sets the OS date-and-time stamp of the file given by FileName
  to the value given by Age. The DateTimeToFileDate function can be used to
  convert a TDateTime value to an OS date-and-time stamp. The return value
  is zero if the function was successful. Otherwise the return value is a
  system error code. If the specified file is a symlink then the function is
  performed on the target file. }

function FileSetDate(const FileName: string; Age: Integer): Integer; overload;

{ FileSetDate by handle is not available on Unix platforms because there
  is no standard way to set a file's modification time using only a file
  handle, and no standard way to obtain the file name of an open
  file handle. }

function FileSetDate(Handle: THandle; Age: Integer): Integer; overload; platform;

{ FileGetAttr returns the file attributes of the file given by FileName. The
  attributes can be examined by AND-ing with the faXXXX constants defined
  above. A return value of -1 indicates that an error occurred. If the
  specified file is a symlink then the function is performed on the target file.
  If FollowLink is false then the symlink file is used. }

function FileGetAttr(const FileName: string): Integer; platform;

{ FileGetAttr returns the file attributes of the file given by FileName. The
  attributes can be examined by AND-ing with the faXXXX constants defined
  above. A return value of -1 indicates that an error occurred. If the
  specified file is a symlink then the function is performed on the target file.
  If FollowLink is false then the symlink file is used. }

function FileSetAttr(const FileName: string; Attr: Integer): Integer; platform;

{ FileIsReadOnly tests whether a given file is read-only for the current
  process and effective user id.  If the file does not exist, the
  function returns False.  (Check FileExists before calling FileIsReadOnly)
  This function is platform portable.  If the specified file is a symlink
  then the function is performed on the target file. }

function FileIsReadOnly(const FileName: string): Boolean;

{ FileSetReadOnly sets the read only state of a file.  The file must
  exist and the current effective user id must be the owner of the file.
  On Unix systems, FileSetReadOnly attempts to set or remove
  all three (user, group, and other) write permissions on the file.
  If you want to grant partial permissions (writeable for owner but not
  for others), use platform specific functions such as chmod.
  The function returns True if the file was successfully modified,
  False if there was an error.  This function is platform portable. If the
  specified file is a symlink then the function is performed on the target
  file. }

function FileSetReadOnly(const FileName: string; ReadOnly: Boolean): Boolean;

{ DeleteFile deletes the file given by FileName. The return value is True if
  the file was successfully deleted, or False if an error occurred. DeleteFile
  can delete a symlink to a file or directory. }

function DeleteFile(const FileName: string): Boolean;

{ RenameFile renames the file given by OldName to the name given by NewName.
  The return value is True if the file was successfully renamed, or False if
  an error occurred. If the file specified is a symlink then the function is
  performed on the symlink. }

function RenameFile(const OldName, NewName: string): Boolean; inline;

{ ChangeFileExt changes the extension of a filename. FileName specifies a
  filename with or without an extension, and Extension specifies the new
  extension for the filename. The new extension can be a an empty string or
  a period followed by up to three characters. }

type
  TFilenameCaseMatch = (mkNone, mkExactMatch, mkSingleMatch, mkAmbiguous);

function ExpandFileNameCase(const FileName: string;
  out MatchFound: TFilenameCaseMatch): string; overload;

{ ExpandUNCFileName expands the given filename to a fully qualified filename.
  This function is the same as ExpandFileName except that it will return the
  drive portion of the filename in the format '\\<servername>\<sharename> if
  that drive is actually a network resource instead of a local resource.
  Like ExpandFileName, embedded '.' and '..' directory references are
  removed. }

function ExpandUNCFileName(const FileName: string): string; overload;

{ ExtractRelativePath will return a file path name relative to the given
  BaseName.  It strips the common path dirs and adds '..\' on Windows,
  and '../' on Linux for each level up from the BaseName path. Note: Directories
  passed in should include trailing backslashes}

function ExtractRelativePath(const BaseName, DestName: string): string; overload;

{ IsRelativePath returns a boolean value that indicates whether the specified
  path is a relative path. }

function IsRelativePath(const Path: string): Boolean;

{ ExtractShortPathName will convert the given filename to the short form
  by calling the GetShortPathName API.  Will return an empty string if
  the file or directory specified does not exist }

function ExtractShortPathName(const FileName: string): string; overload;

{ FileSearch searches for the file given by Name in the list of directories
  given by DirList. The directory paths in DirList must be separated by
  PathSep chars. The search always starts with the current directory of the
  current drive. The returned value is a concatenation of one of the
  directory paths and the filename, or an empty string if the file could not
  be located. }

function FileSearch(const Name, DirList: string): string;

{ DiskFree returns the number of free bytes on the specified drive number,
  where 0 = Current, 1 = A, 2 = B, etc. DiskFree returns -1 if the drive
  number is invalid. }

{ The GetDiskFreeSpace Win32 API does not support partitions larger than 2GB
  under Win95.  A new Win32 function, GetDiskFreeSpaceEx, supports partitions
  larger than 2GB but only exists on Win NT 4.0 and Win95 OSR2.
  The GetDiskFreeSpaceEx function pointer variable below will be initialized
  at startup to point to either the actual OS API function if it exists on
  the system, or to an internal Delphi function if it does not.  When running
  on Win95 pre-OSR2, the output of this function will still be limited to
  the 2GB range reported by Win95, but at least you don't have to worry
  about which API function to call in code you write.  }

var
  GetDiskFreeSpaceEx: function (Directory: PChar; var FreeAvailable,
    TotalSpace: TLargeInteger; TotalFree: PLargeInteger): Bool stdcall = nil;

function DiskFree(Drive: Byte): Int64;

{ DiskSize returns the size in bytes of the specified drive number, where
  0 = Current, 1 = A, 2 = B, etc. DiskSize returns -1 if the drive number
  is invalid. }

function DiskSize(Drive: Byte): Int64;

{ FileDateToDateTime converts an OS date-and-time value to a TDateTime
  value. The FileAge, FileGetDate, and FileSetDate routines operate on OS
  date-and-time values, and the Time field of a TSearchRec used by the
  FindFirst and FindNext functions contains an OS date-and-time value. }

function FileDateToDateTime(FileDate: Integer): TDateTime;

{ DateTimeToFileDate converts a TDateTime value to an OS date-and-time
  value. The FileAge, FileGetDate, and FileSetDate routines operate on OS
  date-and-time values, and the Time field of a TSearchRec used by the
  FindFirst and FindNext functions contains an OS date-and-time value. }

function DateTimeToFileDate(DateTime: TDateTime): Integer;

{ GetCurrentDir returns the current directory. }

function GetCurrentDir: string;

{ SetCurrentDir sets the current directory. The return value is True if
  the current directory was successfully changed, or False if an error
  occurred. }

function SetCurrentDir(const Dir: string): Boolean;

{ CreateDir creates a new directory. The return value is True if a new
  directory was successfully created, or False if an error occurred. }

function CreateDir(const Dir: string): Boolean;

{ RemoveDir deletes an existing empty directory. The return value is
  True if the directory was successfully deleted, or False if an error
  occurred. If the given directory is a symlink to a directory then the
  symlink is deleted. On Windows the link can be broken and the symlink
  can still be verified to be a symlink. }

function RemoveDir(const Dir: string): Boolean;

{ AnsiCompareFileName supports DOS file name comparison idiosyncracies
  in Far East locales (Zenkaku) on Winapi.Windows.
  In non-MBCS locales on Windows, AnsiCompareFileName is identical to
  AnsiCompareText (case insensitive).
  On Linux, AnsiCompareFileName is identical to AnsiCompareStr (case sensitive).
  For general purpose file name comparisions, you should use this function
  instead of AnsiCompareText. }

function AnsiCompareFileName(const S1, S2: string; CheckVolumeCase: Boolean=False): Integer; overload;

function SameFileName(const S1, S2: string): Boolean; inline; overload;

{ AnsiLowerCaseFileName is identical to AnsiLowerCase. }

function AnsiLowerCaseFileName(const S: string): string; overload; deprecated 'Use AnsiLowerCase instead';

{ AnsiUpperCaseFileName is identical to AnsiUpperCase. }

function AnsiUpperCaseFileName(const S: string): string; overload; deprecated 'Use AnsiUpperCase instead';

implementation

uses
  sdaSysUtils;

function InternalFileTimeToDateTime(Time: TFileTime): TDateTime;

  function InternalEncodeDateTime(const AYear, AMonth, ADay, AHour, AMinute, ASecond,
    AMilliSecond: Word): TDateTime;
  var
    LTime: TDateTime;
    Success: Boolean;
  begin
    Result := 0;
    Success := TryEncodeDate(AYear, AMonth, ADay, Result);
    if Success then
    begin
      Success := TryEncodeTime(AHour, AMinute, ASecond, AMilliSecond, LTime);
      if Success then
        if Result >= 0 then
          Result := Result + LTime
        else
          Result := Result - LTime
    end;
  end;

var
  LFileTime: TFileTime;
  SysTime: TSystemTime;
begin
  Result := 0;
  FileTimeToLocalFileTime(Time, LFileTime);

  if FileTimeToSystemTime(LFileTime, SysTime) then
    with SysTime do
    begin
      Result := InternalEncodeDateTime(wYear, wMonth, wDay, wHour, wMinute,
        wSecond, wMilliseconds);
    end;
end;

{ TSearchRec }

procedure TSearchRec.Close;
begin
  FindClose(Self);
end;

function TSearchRec.Next: Boolean;
begin
  Result := FindNext(Self) = 0;
end;

function TSearchRec.First(const Path: string; Attr: Integer): Boolean;
begin
  Result := FindFirst(Path, Attr, Self) = 0;
end;

function TSearchRec.GetTimeStamp: TDateTime;
begin
  Result := InternalFileTimeToDateTime(FindData.ftLastWriteTime);
end;

{ TDateTimeRec }

function TDateTimeInfoRec.GetCreationTime: TDateTime;
begin
  Result := InternalFileTimeToDateTime(Data.ftCreationTime);
end;

function TDateTimeInfoRec.GetLastAccessTime: TDateTime;
begin
  Result := InternalFileTimeToDateTime(Data.ftLastAccessTime);
end;

function TDateTimeInfoRec.GetTimeStamp: TDateTime;
begin
  Result := InternalFileTimeToDateTime(Data.ftLastWriteTime);
end;

{ File management routines }

function FileOpen(const FileName: string; Mode: LongWord): THandle;
const
  AccessMode: array[0..2] of LongWord = (
    GENERIC_READ,
    GENERIC_WRITE,
    GENERIC_READ or GENERIC_WRITE);
  ShareMode: array[0..4] of LongWord = (
    0,
    0,
    FILE_SHARE_READ,
    FILE_SHARE_WRITE,
    FILE_SHARE_READ or FILE_SHARE_WRITE);
begin
  Result := INVALID_HANDLE_VALUE;
  if ((Mode and 3) <= fmOpenReadWrite) and
    ((Mode and $F0) <= fmShareDenyNone) then
    Result := CreateFile(PChar(FileName), AccessMode[Mode and 3],
      ShareMode[(Mode and $F0) shr 4], nil, OPEN_EXISTING,
      FILE_ATTRIBUTE_NORMAL, 0);
end;

function FileCreate(const FileName: string): THandle;
begin
  Result := FileCreate(FileName, fmShareExclusive, 0);
end;

function FileCreate(const FileName: string; Rights: Integer): THandle;
begin
  Result := FileCreate(FileName, fmShareExclusive, Rights);
end;

function FileCreate(const FileName: string; Mode: LongWord; Rights: Integer): THandle;
const
  Exclusive: array[0..1] of LongWord = (
    CREATE_ALWAYS,
    CREATE_NEW);
  ShareMode: array[0..4] of LongWord = (
    0,
    0,
    FILE_SHARE_READ,
    FILE_SHARE_WRITE,
    FILE_SHARE_READ or FILE_SHARE_WRITE);
begin
  Result := INVALID_HANDLE_VALUE;
  if (Mode and $F0) <= fmShareDenyNone then
    Result := CreateFile(PChar(FileName), GENERIC_READ or GENERIC_WRITE,
      ShareMode[(Mode and $F0) shr 4], nil, Exclusive[(Mode and $0004) shr 2], FILE_ATTRIBUTE_NORMAL, 0);
end;

// The access rights of symlinks are unpredictable over network drives. It is
// therefore not recommended to create symlinks over a network drive. To enable
// remote access of symlinks under Windows Vista and Windows 7 use the command:
//   "fsutil behavior set SymlinkEvaluation R2R:1 R2L:1"
function FileCreateSymLink(const Link, Target: string): Boolean;
var
  Flags: DWORD;
  Path: string;
begin
  Result := False;

  if (Target = '') or (Link = '') or not CheckWin32Version(6, 0) then
    Exit;

  Path := ExtractFilePath(Link);

  if fsSymLink in FileSystemAttributes(Path) then
  begin
    if IsRelativePath(Target) then
      Flags := GetFileAttributes(PChar(IncludeTrailingPathDelimiter(Path) + Target))
    else
      Flags := GetFileAttributes(PChar(Target));

    if (Flags <> INVALID_FILE_ATTRIBUTES) and (faDirectory and Flags <> 0) then
      Flags := SYMBOLIC_LINK_FLAG_DIRECTORY
    else
      Flags := 0;

    Result := CreateSymbolicLink(PChar(Link), PChar(Target), Flags);
  end;
end;

function FileSystemAttributes(const Path: string): TFileSystemAttributes;
var
  Drive: string;
  SerialNumber, FileSystemFlags, ComponentLength: DWORD;
  VolumeName: array[0..MAX_PATH - 1] of Char;
  FileSystemBuffer: array[0..MAX_PATH - 1] of Char;
begin
  Result := [];

  if DirectoryExists(Path) or FileExists(Path) then
  begin
    Drive := IncludeTrailingPathDelimiter(ExtractFileDrive(Path));

    if GetVolumeInformation(PChar(Drive), @VolumeName[0], MAX_PATH, @SerialNumber,
      ComponentLength, FileSystemFlags, @FileSystemBuffer[0], MAX_PATH) then
    begin
      if FileSystemFlags and FILE_CASE_SENSITIVE_SEARCH <> 0 then
        Include(Result, fsCaseSensitive);
      if FileSystemFlags and FILE_CASE_PRESERVED_NAMES <> 0 then
        Include(Result, fsCasePreserving);
      if FileSystemFlags and FILE_SUPPORTS_REPARSE_POINTS <> 0 then
        Include(Result, fsSymLink);

      case GetDriveType(PChar(Drive)) of
        DRIVE_REMOVABLE, DRIVE_CDROM: Include(Result, fsRemovable);
        DRIVE_FIXED: Include(Result, fsLocal);
        DRIVE_REMOTE: Include(Result, fsNetwork);
      end;

      Exit;
    end;

    RaiseLastOSError;
  end;

  raise EDirectoryNotFoundException.Create(SDriveNotFound);
end;

function FileRead(Handle: THandle; var Buffer; Count: LongWord): Integer;
begin
  if not ReadFile(Handle, Buffer, Count, LongWord(Result), nil) then
    Result := -1;
end;

function FileWrite(Handle: THandle; const Buffer; Count: LongWord): Integer;
begin
  if not WriteFile(Handle, Buffer, Count, LongWord(Result), nil) then
    Result := -1;
end;

function FileSeek(Handle: THandle; Offset, Origin: Integer): Integer;
begin
  Result := SetFilePointer(Handle, Offset, nil, Origin);
end;

function FileSeek(Handle: THandle; const Offset: Int64; Origin: Integer): Int64;
begin
  Result := Offset;
  Int64Rec(Result).Lo := SetFilePointer(Handle, Int64Rec(Result).Lo,
    @Int64Rec(Result).Hi, Origin);
  if (Int64Rec(Result).Lo = $FFFFFFFF) and (GetLastError <> 0) then
    Int64Rec(Result).Hi := $FFFFFFFF;
end;

procedure FileClose(Handle: THandle);
begin
  CloseHandle(Handle);
end;

function GetFileAttributesExEmulated(lpFileName: PChar; fInfoLevelId: TGetFileExInfoLevels;
  lpFileInformation: Pointer): BOOL; stdcall;
var
  Handle: THandle;
  FindData: TWin32FindData;
begin
  Handle := FindFirstFile(lpFileName, FindData);
  if Handle <> INVALID_HANDLE_VALUE then
  begin
    sdaWindows.FindClose(Handle);
    if lpFileInformation <> nil then
    begin
      Move(FindData, lpFileInformation^, SizeOf(TWin32FileAttributeData));
      Result := True;
      Exit;
    end;
  end;
  Result := False;
end;

function FileAgeInternal(const FileName: string; out FileTime: TFileTime): Boolean;
var
  FindData: TWin32FileAttributeData;
  ErrorCode: Cardinal;
  Success: Boolean;
begin
  // try to get the file attributes the easy way;
  // if something goes wrong, ErrorCode is set to a value other then ERROR_SUCCESS;
  // the chosen value is ERROR_SHARING_VIOLATION
  ErrorCode := ERROR_SUCCESS;
  Success := GetFileAttributesEx(PChar(FileName), GetFileExInfoStandard, @FindData);

  if not Success then
  begin
    // check if the file is locked or in share-exclusive mode;
    // if it is so, use FindFirstFile to get its age
    ErrorCode := GetLastError;

    case ErrorCode of
      ERROR_SHARING_VIOLATION,
      ERROR_LOCK_VIOLATION:
       if not GetFileAttributesExEmulated(PChar(FileName), GetFileExInfoStandard, @FindData) then
         ErrorCode := ERROR_SHARING_VIOLATION
       else
         ErrorCode := ERROR_SUCCESS;
    end;
  end;

  // if there was no error in getting the file attributes, obtain the file age
  if ErrorCode = ERROR_SUCCESS then
    if FindData.dwFileAttributes and faDirectory = 0 then
    begin
      if not FileTimeToLocalFileTime(FindData.ftLastWriteTime, FileTime) then
        ErrorCode := ERROR_SHARING_VIOLATION;
    end else
      ErrorCode := ERROR_SHARING_VIOLATION;

  { Result depends on the error code }
  Result := (ErrorCode = ERROR_SUCCESS);
end;

function FileAge(const FileName: string): Integer; overload;
var
  LFileTime: TFileTime;
begin
  { Use the internal helper routine }
  if (not FileAgeInternal(FileName, LFileTime)) or
     (not FileTimeToDosDateTime(LFileTime, LongRec(Result).Hi, LongRec(Result).Lo))
  then
    Result := -1; // Failure
end;

function FileAge(const FileName: string; out FileDateTime: TDateTime): Boolean;
var
  LFileTime: TFileTime;
  LSystemTime: TSystemTime;
begin
  { Use the internal helper routine }
  Result := FileAgeInternal(FileName, LFileTime) and
    FileTimeToSystemTime(LFileTime, LSystemTime);

  { If the date/time was obtained OK, transform it into Delphi time }
  if Result then
    Result := TrySystemTimeToDateTime(LSystemTime, FileDateTime);
end;

function FileExists(const FileName: string; FollowLink: Boolean = True): Boolean;

  function ExistsLockedOrShared(const Filename: string): Boolean;
  var
    FindData: TWin32FindData;
    LHandle: THandle;
  begin
    { Either the file is locked/share_exclusive or we got an access denied }
    LHandle := FindFirstFile(PChar(Filename), FindData);
    if LHandle <> INVALID_HANDLE_VALUE then
    begin
      sdaWindows.FindClose(LHandle);
      Result := FindData.dwFileAttributes and FILE_ATTRIBUTE_DIRECTORY = 0;
    end
    else
      Result := False;
  end;

var
  Flags: Cardinal;
  Handle: THandle;
  LastError: Cardinal;
begin
  Flags := GetFileAttributes(PChar(FileName));

  if Flags <> INVALID_FILE_ATTRIBUTES then
  begin
    if faSymLink and Flags <> 0 then
    begin
      if not FollowLink then
        Exit(True)
      else
      begin
        if faDirectory and Flags <> 0 then
          Exit(False)
        else
        begin
          Handle := CreateFile(PChar(FileName), GENERIC_READ, FILE_SHARE_READ, nil,
            OPEN_EXISTING, 0, 0);
          if Handle <> INVALID_HANDLE_VALUE then
          begin
            CloseHandle(Handle);
            Exit(True);
          end;
          LastError := GetLastError;
          Exit(LastError = ERROR_SHARING_VIOLATION);
        end;
      end;
    end;

    Exit(faDirectory and Flags = 0);
  end;

  LastError := GetLastError;
  Result := (LastError <> ERROR_FILE_NOT_FOUND) and
    (LastError <> ERROR_PATH_NOT_FOUND) and
    (LastError <> ERROR_INVALID_NAME) and ExistsLockedOrShared(Filename);
end;

function DirectoryExists(const Directory: string; FollowLink: Boolean = True): Boolean;
var
  Code: Cardinal;
  Handle: THandle;
  LastError: Cardinal;
begin
  Result := False;
  Code := GetFileAttributes(PChar(Directory));

  if Code <> INVALID_FILE_ATTRIBUTES then
  begin
    if faSymLink and Code = 0 then
      Result := faDirectory and Code <> 0
    else
    begin
      if FollowLink then
      begin
        Handle := CreateFile(PChar(Directory), GENERIC_READ, FILE_SHARE_READ, nil,
          OPEN_EXISTING, FILE_FLAG_BACKUP_SEMANTICS, 0);
        if Handle <> INVALID_HANDLE_VALUE then
        begin
          CloseHandle(Handle);
          Result := faDirectory and Code <> 0;
        end;
      end
      else if faDirectory and Code <> 0 then
        Result := True
      else
      begin
        Handle := CreateFile(PChar(Directory), GENERIC_READ, FILE_SHARE_READ, nil,
          OPEN_EXISTING, FILE_FLAG_BACKUP_SEMANTICS, 0);
        if Handle <> INVALID_HANDLE_VALUE then
        begin
          CloseHandle(Handle);
          Result := False;
        end
        else
          Result := True;
      end;
    end;
  end
  else
  begin
    LastError := GetLastError;
    Result := (LastError <> ERROR_FILE_NOT_FOUND) and
      (LastError <> ERROR_PATH_NOT_FOUND) and
      (LastError <> ERROR_INVALID_NAME) and
      (LastError <> ERROR_BAD_NETPATH);
  end;
end;

function ForceDirectories(Dir: string): Boolean;
var
  E: EInOutError;
begin
  Result := True;
  if Dir = '' then
  begin
    E := EInOutError.CreateRes(@SCannotCreateDir);
    E.ErrorCode := 3;
    raise E;
  end;
  Dir := ExcludeTrailingPathDelimiter(Dir);
  if (Length(Dir) < 3) or DirectoryExists(Dir)
    or (ExtractFilePath(Dir) = Dir) then Exit; // avoid 'xyz:\' problem.
  Result := ForceDirectories(ExtractFilePath(Dir)) and CreateDir(Dir);
end;

function FileGetDate(Handle: THandle): Integer;
var
  FileTime, LocalFileTime: TFileTime;
begin
  if GetFileTime(Handle, nil, nil, @FileTime) and
    FileTimeToLocalFileTime(FileTime, LocalFileTime) and
    FileTimeToDosDateTime(LocalFileTime, LongRec(Result).Hi,
      LongRec(Result).Lo) then Exit;
  Result := -1;
end;

function FileGetDateTimeInfo(const FileName: string;
  out DateTime: TDateTimeInfoRec): Boolean;
var
  Data: TWin32FindData;
begin
  Result := False;
  SetLastError(ERROR_SUCCESS);

  if GetFileAttributesEx(PChar(FileName), GetFileExInfoStandard, @Data) then
  begin
    if (faSymLink and Data.dwFileAttributes) <> 0 then Exit;
    DateTime.Data := Data;
    Result := True;
  end;
end;

function FileSetDate(const FileName: string; Age: Integer): Integer;
var
  f: THandle;
begin
  f := FileOpen(FileName, fmOpenWrite);
  if f = THandle(-1) then
    Result := GetLastError
  else
  begin
    Result := FileSetDate(f, Age);
    FileClose(f);
  end;
end;

function FileSetDate(Handle: THandle; Age: Integer): Integer;
var
  LocalFileTime, FileTime: TFileTime;
begin
  Result := 0;
  if DosDateTimeToFileTime(LongRec(Age).Hi, LongRec(Age).Lo, LocalFileTime) and
    LocalFileTimeToFileTime(LocalFileTime, FileTime) and
    SetFileTime(Handle, nil, nil, @FileTime) then Exit;
  Result := GetLastError;
end;

function FileGetAttr(const FileName: string): Integer;
begin
  Result := GetFileAttributes(PChar(FileName));
  if (faSymLink and Result) <> 0 then Result := faInvalid;
end;

function FileSetAttr(const FileName: string; Attr: Integer): Integer;
var
  LFileName: string;
begin
  Result := 0;
  LFileName := FileName;

  if not SetFileAttributes(PChar(LFileName), Attr) then
    Result := GetLastError;
end;

function FileIsReadOnly(const FileName: string): Boolean;
var
  Flags: DWORD;
begin
  Result := False;
  Flags := GetFileAttributes(PChar(FileName));

  if Flags <> INVALID_FILE_ATTRIBUTES then
    Result := Flags and faReadOnly <> 0;
end;

function FileSetReadOnly(const FileName: string; ReadOnly: Boolean): Boolean;
var
  Flags: Cardinal;
  LFileName: string;
begin
  Result := False;
  Flags := GetFileAttributes(PChar(FileName));

  if Flags <> INVALID_FILE_ATTRIBUTES then
  begin
    LFileName := FileName;
    if ReadOnly then Flags := Flags or faReadOnly
      else Flags := Flags and not faReadOnly;
    Result := SetFileAttributes(PChar(LFileName), Flags);
  end;
end;

function FindMatchingFile(var F: TSearchRec): Integer;
var
  LocalFileTime: TFileTime;
begin
  with F do
  begin
    while FindData.dwFileAttributes and ExcludeAttr <> 0 do
      if not FindNextFile(FindHandle, FindData) then
      begin
        Result := GetLastError;
        Exit;
      end;
    FileTimeToLocalFileTime(FindData.ftLastWriteTime, LocalFileTime);
    FileTimeToDosDateTime(LocalFileTime, LongRec(Time).Hi,
      LongRec(Time).Lo);
    Size := FindData.nFileSizeLow or Int64(FindData.nFileSizeHigh) shl 32;
    Attr := FindData.dwFileAttributes;
    Name := FindData.cFileName;
  end;
  Result := 0;
end;

function FindFirst(const Path: string; Attr: Integer;
  var F: TSearchRec): Integer;
const
  faSpecial = faHidden or faSysFile or faDirectory;
begin
  F.ExcludeAttr := not Attr and faSpecial;
  F.FindHandle := FindFirstFile(PChar(Path), F.FindData);
  if F.FindHandle <> INVALID_HANDLE_VALUE then
  begin
    Result := FindMatchingFile(F);
    if Result <> 0 then FindClose(F);
  end
  else
    Result := GetLastError;
end;

function FindNext(var F: TSearchRec): Integer;
begin
  if FindNextFile(F.FindHandle, F.FindData) then
    Result := FindMatchingFile(F)
  else
    Result := GetLastError;
end;

procedure FindClose(var F: TSearchRec);
begin
  if F.FindHandle <> INVALID_HANDLE_VALUE then
  begin
    sdaWindows.FindClose(F.FindHandle);
    F.FindHandle := INVALID_HANDLE_VALUE;
  end;
end;

function DeleteFile(const FileName: string): Boolean;
var
  Flags, LastError: Cardinal;
begin
  Result := sdaWindows.DeleteFile(PChar(FileName));

  if not Result then
  begin
    LastError := GetLastError;
    Flags := GetFileAttributes(PChar(FileName));

    if (Flags <> INVALID_FILE_ATTRIBUTES) and (faSymLink and Flags <> 0) and
      (faDirectory and Flags <> 0) then
    begin
      Result := RemoveDirectory(PChar(FileName));
      Exit;
    end;

    SetLastError(LastError);
  end;
end;

function RenameFile(const OldName, NewName: string): Boolean;
begin
  Result := MoveFile(PChar(OldName), PChar(NewName));
end;

function ExpandFileNameCase(const FileName: string; out MatchFound: TFilenameCaseMatch): string;
var
  SR: TSearchRec;
  FullPath, Name: string;
  Status: Integer;
begin
  Result := ExpandFileName(FileName);
  MatchFound := mkNone;

  if FileName = '' then // Stop for empty strings, otherwise we risk to get info infinite loop.
    Exit;

  FullPath := ExtractFilePath(Result);
  Name := ExtractFileName(Result);

  // if FullPath is not the root directory  (portable)
  if not SameFileName(FullPath, IncludeTrailingPathDelimiter(ExtractFileDrive(FullPath))) then
  begin  // Does the path need case-sensitive work?
    Status := FindFirst(ExcludeTrailingPathDelimiter(FullPath), faAnyFile, SR);
    FindClose(SR);   // close search before going recursive
    if Status <> 0 then
    begin
      FullPath := ExcludeTrailingPathDelimiter(FullPath);
      FullPath := ExpandFileNameCase(FullPath, MatchFound);
      if MatchFound = mkNone then
        Exit;    // if we can't find the path, we certainly can't find the file!
      FullPath := IncludeTrailingPathDelimiter(FullPath);
    end;
  end;

  // Path is validated / adjusted.  Now for the file itself
  try
    if FindFirst(FullPath + Name, faAnyFile, SR)= 0 then    // exact match on filename
    begin
      if not (MatchFound in [mkSingleMatch, mkAmbiguous]) then  // path might have been inexact
      begin
        if Name = SR.Name then
          MatchFound := mkExactMatch
        else
          MatchFound := mkSingleMatch;
      end;
      Exit(FullPath + SR.Name);
    end;
  finally
    FindClose(SR);
  end;
end;

function GetUniversalName(const FileName: string): string;
type
  PNetResourceArray = ^TNetResourceArray;
  TNetResourceArray = array[0..MaxInt div SizeOf(TNetResource) - 1] of TNetResource;
var
  I, BufSize, NetResult: Integer;
  Count, Size: LongWord;
  Drive: Char;
  NetHandle: THandle;
  NetResources: PNetResourceArray;
  RemoteNameInfo: array[0..1023] of Byte;
begin
  Result := FileName;
  if (Win32Platform <> VER_PLATFORM_WIN32_WINDOWS) or (Win32MajorVersion > 4) then
  begin
    Size := SizeOf(RemoteNameInfo);
    if WNetGetUniversalName(PChar(FileName), UNIVERSAL_NAME_INFO_LEVEL,
      @RemoteNameInfo, Size) <> NO_ERROR then Exit;
    Result := PRemoteNameInfo(@RemoteNameInfo).lpUniversalName;
  end else
  begin
  { The following works around a bug in WNetGetUniversalName under Windows 95 }
    Drive := UpCase(FileName[1]);
    if (Drive < 'A') or (Drive > 'Z') or (Length(FileName) < 3) or
      (FileName[2] <> ':') or (FileName[3] <> '\') then
      Exit;
    if WNetOpenEnum(RESOURCE_CONNECTED, RESOURCETYPE_DISK, 0, nil,
      NetHandle) <> NO_ERROR then Exit;
    try
      BufSize := 50 * SizeOf(TNetResource);
      GetMem(NetResources, BufSize);
      try
        while True do
        begin
          Count := $FFFFFFFF;
          Size := BufSize;
          NetResult := WNetEnumResource(NetHandle, Count, NetResources, Size);
          if NetResult = ERROR_MORE_DATA then
          begin
            BufSize := Size;
            ReallocMem(NetResources, BufSize);
            Continue;
          end;
          if NetResult <> NO_ERROR then Exit;
          for I := 0 to Count - 1 do
            with NetResources^[I] do
              if (lpLocalName <> nil) and (Drive = UpCase(lpLocalName[0])) then
              begin
                Result := lpRemoteName + Copy(FileName, 3, Length(FileName) - 2);
                Exit;
              end;
        end;
      finally
        FreeMem(NetResources, BufSize);
      end;
    finally
      WNetCloseEnum(NetHandle);
    end;
  end;
end;

function ExpandUNCFileName(const FileName: string): string;
begin
  { First get the local resource version of the file name }
  Result := ExpandFileName(FileName);
  if (Length(Result) >= 3) and (Result[2] = ':') and (Upcase(Result[1]) >= 'A')
    and (Upcase(Result[1]) <= 'Z') then
    Result := GetUniversalName(Result);
end;

function ExtractRelativePath(const BaseName, DestName: string): string;
var
  BasePath, DestPath: string;
  BaseLead, DestLead: PChar;
  BasePtr, DestPtr: PChar;

  function ExtractFilePathNoDrive(const FileName: string): string;
  begin
    Result := ExtractFilePath(FileName);
    Delete(Result, 1, Length(ExtractFileDrive(FileName)));
  end;

  function Next(var Lead: PChar): PChar;
  begin
    Result := Lead;
    if Result = nil then Exit;
    Lead := AnsiStrScan(Lead, PathDelim);
    if Lead <> nil then
    begin
      Lead^ := #0;
      Inc(Lead);
    end;
  end;

begin
  if SameFilename(ExtractFileDrive(BaseName), ExtractFileDrive(DestName)) then
  begin
    BasePath := ExtractFilePathNoDrive(BaseName);
    UniqueString(BasePath);
    DestPath := ExtractFilePathNoDrive(DestName);
    UniqueString(DestPath);
    BaseLead := Pointer(BasePath);
    BasePtr := Next(BaseLead);
    DestLead := Pointer(DestPath);
    DestPtr := Next(DestLead);
    while (BasePtr <> nil) and (DestPtr <> nil) and SameFilename(BasePtr, DestPtr) do
    begin
      BasePtr := Next(BaseLead);
      DestPtr := Next(DestLead);
    end;
    Result := '';
    while BaseLead <> nil do
    begin
      Result := Result + '..' + PathDelim;             { Do not localize }
      Next(BaseLead);
    end;
    if (DestPtr <> nil) and (DestPtr^ <> #0) then
      Result := Result + DestPtr + PathDelim;
    if DestLead <> nil then
      Result := Result + DestLead;     // destlead already has a trailing backslash
    Result := Result + ExtractFileName(DestName);
  end
  else
    Result := DestName;
end;

function IsRelativePath(const Path: string): Boolean;
var
  L: Integer;
begin
  L := Length(Path);
  Result := (L > 0) and (Path[1] <> PathDelim) and (L > 1) and (Path[2] <> ':');
end;

function ExtractShortPathName(const FileName: string): string;
var
  Buffer: array[0..MAX_PATH - 1] of Char;
  Len: Integer;
begin
  Len := GetShortPathName(PChar(FileName), Buffer, Length(Buffer));
  if Len <= Length(Buffer) then
    SetString(Result, Buffer, Len)
  else
    if Len > 0 then
    begin
      SetLength(Result, Len);
      Len := GetShortPathName(PChar(FileName), PChar(Result), Len);
      if Len < Length(Result) then
        SetLength(Result, Len);
    end;
end;

function FileSearch(const Name, DirList: string): string;
var
  I, P, L: Integer;
  C: Char;
begin
  Result := Name;
  if Result = '' then // nothing to do
    Exit;
  P := 1;
  L := Length(DirList);
  while True do
  begin
    if FileExists(Result) then Exit;
    while (P <= L) and (DirList[P] = PathSep) do Inc(P);
    if P > L then Break;
    I := P;
    while (P <= L) and (DirList[P] <> PathSep) do
    begin
      if IsLeadChar(DirList[P]) then
        P := NextCharIndex(DirList, P)
      else
        Inc(P);
    end;
    Result := Copy(DirList, I, P - I);
    C := AnsiLastChar(Result)^;
    if (C <> DriveDelim) and (C <> PathDelim) then
      Result := Result + PathDelim;
    Result := Result + Name;
  end;
  Result := '';
end;

function AnsiCompareFileName(const S1, S2: string; CheckVolumeCase: Boolean): Integer;
  function IsVolumeCaseSensitive(Path: string): Boolean;
  begin
    if Path = '' then
      Path := GetCurrentDir;
    while (Path <> '') and not DirectoryExists(Path) do
      Path := ExtractFilePath(ExcludeTrailingPathDelimiter(Path)); // Move up a directory
    if Path <> '' then
      Exit(fsCaseSensitive in FileSystemAttributes(Path));
    // Path was not found, so assume the default
    Result := False;
  end;
var
  LS1, LS2: string;
begin
  if CheckVolumeCase then
  begin
    if IsVolumeCaseSensitive(ExtractFilePath(S1)) or
       IsVolumeCaseSensitive(ExtractFilePath(S2)) then
    begin
      LS1 := S1;
      LS2 := S2;
    end
    else
    begin
      LS1 := AnsiLowerCase(S1);
      LS2 := AnsiLowerCase(S2);
    end;
  end
  else // not CheckVolumeCase
  begin
    LS1 := AnsiLowerCase(S1);
    LS2 := AnsiLowerCase(S2);
  end;
  Result := CompareStr(LS1, LS2);
end;

function SameFileName(const S1, S2: string): Boolean;
begin
  Result := AnsiCompareFileName(S1, S2) = 0;
end;

function AnsiLowerCaseFileName(const S: string): string;
begin
  Result := AnsiLowerCase(S); // Use "platform" lower casing which works for all locales in unicode
end;

function AnsiUpperCaseFileName(const S: string): string;
begin
  Result := AnsiUpperCase(S);  // Use "platform" upper casing which works for all locales in unicode
end;

// This function is used if the OS doesn't support GetDiskFreeSpaceEx
function BackfillGetDiskFreeSpaceEx(Directory: PChar; var FreeAvailable,
    TotalSpace: TLargeInteger; TotalFree: PLargeInteger): Bool; stdcall;
var
  SectorsPerCluster, BytesPerSector, FreeClusters, TotalClusters: LongWord;
  Temp: Int64;
  Dir: PChar;
begin
  if Directory <> nil then
    Dir := Directory
  else
    Dir := nil;
  Result := GetDiskFreeSpace(Dir, SectorsPerCluster, BytesPerSector,
    FreeClusters, TotalClusters);
  Temp := SectorsPerCluster * BytesPerSector;
  FreeAvailable := Temp * FreeClusters;
  TotalSpace := Temp * TotalClusters;
end;

procedure InitDriveSpacePtr;
var
  Kernel: THandle;
begin
  Kernel := GetModuleHandle(sdaWindows.Kernel32);
  if Kernel <> 0 then
{$IFDEF UNICODE}
    @GetDiskFreeSpaceEx := GetProcAddress(Kernel, 'GetDiskFreeSpaceExW');
{$ELSE !UNICODE}
    @GetDiskFreeSpaceEx := GetProcAddress(Kernel, 'GetDiskFreeSpaceExA');
{$ENDIF !UNICODE}
  if not Assigned(GetDiskFreeSpaceEx) then
    GetDiskFreeSpaceEx := @BackfillGetDiskFreeSpaceEx;
end;

function InternalGetDiskSpace(Drive: Byte;
  var TotalSpace, FreeSpaceAvailable: Int64): Bool;
var
  RootPath: array[0..4] of Char;
  RootPtr: PChar;
begin
  RootPtr := nil;
  if Drive > 0 then
  begin
    RootPath[0] := Char(Drive + $40);
    RootPath[1] := ':';
    RootPath[2] := '\';
    RootPath[3] := #0;
    RootPtr := RootPath;
  end;
  Result := GetDiskFreeSpaceEx(RootPtr, FreeSpaceAvailable, TotalSpace, nil);
end;

function DiskSize(Drive: Byte): Int64;
var
  FreeSpace: Int64;
begin
  if not InternalGetDiskSpace(Drive, Result, FreeSpace) then
    Result := -1;
end;

function DiskFree(Drive: Byte): Int64;
var
  TotalSpace: Int64;
begin
  if not InternalGetDiskSpace(Drive, TotalSpace, Result) then
    Result := -1;
end;

function FileDateToDateTime(FileDate: Integer): TDateTime;
begin
  Result :=
    EncodeDate(
      LongRec(FileDate).Hi shr 9 + 1980,
      LongRec(FileDate).Hi shr 5 and 15,
      LongRec(FileDate).Hi and 31) +
    EncodeTime(
      LongRec(FileDate).Lo shr 11,
      LongRec(FileDate).Lo shr 5 and 63,
      LongRec(FileDate).Lo and 31 shl 1, 0);
end;

function DateTimeToFileDate(DateTime: TDateTime): Integer;
var
  Year, Month, Day, Hour, Min, Sec, MSec: Word;
begin
  DecodeDate(DateTime, Year, Month, Day);
  if (Year < 1980) or (Year > 2107) then Result := 0 else
  begin
    DecodeTime(DateTime, Hour, Min, Sec, MSec);
    LongRec(Result).Lo := (Sec shr 1) or (Min shl 5) or (Hour shl 11);
    LongRec(Result).Hi := Day or (Month shl 5) or ((Year - 1980) shl 9);
  end;
end;

function GetCurrentDir: string;
begin
  GetDir(0, Result);
end;

function SetCurrentDir(const Dir: string): Boolean;
begin
  Result := SetCurrentDirectory(PChar(Dir));
end;

function CreateDir(const Dir: string): Boolean;
begin
  Result := CreateDirectory(PChar(Dir), nil);
end;

function RemoveDir(const Dir: string): Boolean;
begin
  Result := RemoveDirectory(PChar(Dir));
end;

initialization
  InitDriveSpacePtr;
end.
