unit sdaSocketControl;

interface

{$INCLUDE 'sda.inc'}

uses
  sdaSysUtils, sdaWindows, sdaWinSock;

type
  EWindowsSocket = class(Exception);

  TSocketType = (
    SocketStream   = SOCK_STREAM,
    SocketDatagram = SOCK_DGRAM,
    SocketRaw      = SOCK_RAW,
    SocketReliablyDeliveredMessage = SOCK_RDM,
    SocketSequencedPacket          = SOCK_SEQPACKET
  );

  TSocketProtocol = (
    ProtocolIP    = IPPROTO_IP,
    ProtocolICMP  = IPPROTO_ICMP,
    ProtocolIGMP  = IPPROTO_IGMP,
    ProtocolGGP   = IPPROTO_GGP,
    ProtocolTCP   = IPPROTO_TCP,
    ProtocolPUP   = IPPROTO_PUP,
    ProtocolUDP   = IPPROTO_UDP,
    ProtocolIDP   = IPPROTO_IDP,
    ProtocolND    = IPPROTO_ND,
    ProtocolRAW   = IPPROTO_RAW
  );

  TSocketReadWriteCallBack = reference to procedure(Socket: TSocket; Data: Pointer;
    DataSize, ErrorCode: Integer);

  TSdaSocket = record
  private class var
    FAutoProcessPendingOperations: Boolean;
  public
    class property AutoProcessPendingOperations: Boolean
      read FAutoProcessPendingOperations write FAutoProcessPendingOperations;
  private
    FHandle: TSocket;
    class procedure CompletionRoutine(dwError, cbTransferred: DWORD;
      lpOverlapped: PWSAOverlapped; dwFlags: DWORD); stdcall; static;
    function GetSocketType: Integer;
    function GetPort: u_short;
    function GetIP: u_long;
    procedure SetHandle(const Value: TSocket);
    function GetHandle: TSocket;
    function GetEvents: TWSANetworkEvents;
    class function GetComputerIP: u_long; static;
    class function GetComputerName: string; static;
    function GetConnected: Boolean;
    function GetIsListening: Boolean;
    function GetUseNagle: Boolean;
    procedure SetUseNagle(const Value: Boolean);
    function GetAllowBroadcast: Boolean;
    procedure SetAllowBroadcast(const Value: Boolean);
    function GetPeerIP: u_long;
    function GetPeerPort: u_short;
  public
    property Handle: TSocket read GetHandle write SetHandle;
    class function CreateHandle(SocketType: TSocketType = SocketStream;
      Protocol: TSocketProtocol = ProtocolTCP): TSocket; overload; static;
    procedure DestroyHandle;
    class operator Implicit(Value: TSocket): TSdaSocket; inline;
    class operator Implicit(const Value: TSdaSocket): TSocket; inline;

    property SocketType: Integer read GetSocketType;
    property Port: u_short read GetPort;
    property IP: u_long read GetIP;

    property UseNagle: Boolean read GetUseNagle write SetUseNagle;
    property AllowBroadcast: Boolean read GetAllowBroadcast write SetAllowBroadcast;

    procedure Bind(const IP: u_long; PortMin, PortMax: u_short;
      ReuseAddress: Boolean = false); overload;
    procedure Bind(const Host: string; PortMin, PortMax: u_short;
      ReuseAddress: Boolean = false); overload;
    procedure Bind(const IP: u_long; Port: u_short;
      ReuseAddress: Boolean = false); overload;
    procedure Bind(const Host: string; Port: u_short;
      ReuseAddress: Boolean = false); overload;
    procedure Listen;
    property IsListening: Boolean read GetIsListening;
    function Accept: TSocket;
    procedure Connect(const IP: u_long; Port: u_short); overload;
    procedure Connect(const Host: string; Port: u_short); overload;
    property Connected: Boolean read GetConnected;
    procedure Disconnect;

    property Events: TWSANetworkEvents read GetEvents;

    procedure Read(BytesNeeded: Integer; const CallBack: TSocketReadWriteCallBack);
    procedure Write(const Data; DataSize: Integer; const CallBack: TSocketReadWriteCallBack);

    procedure ReadFrom(const IP: u_long; Port: u_short; BytesNeeded: Integer;
      const CallBack: TSocketReadWriteCallBack); overload;
    procedure ReadFrom(const HostName: string; Port: u_short; BytesNeeded: Integer;
      const CallBack: TSocketReadWriteCallBack); overload;
    procedure WriteTo(const IP: u_long; Port: u_short; const Data; DataSize: Integer;
      const CallBack: TSocketReadWriteCallBack); overload;
    procedure WriteTo(const HostName: string; Port: u_short; const Data; DataSize: Integer;
      const CallBack: TSocketReadWriteCallBack); overload;

    class procedure ProcessPendingOperations; static;
    class function Resolve(const HostName: string): u_long; static;
    class function HostName(IP: u_long): string; static;

    class property ComputerIP: u_long read GetComputerIP;
    class property ComputerName: string read GetComputerName;

    property PeerIP: u_long read GetPeerIP;
    property PeerPort: u_short read GetPeerPort;
  end;

function WSAErrorString(ErrorCode: Integer): string; overload;
function WSAErrorString: string; overload;
procedure WSARaiseError(ErrorCode: Integer);
procedure WSARaiseLastError;
procedure WSACheck(ReturnValue: Integer);

function IPStringToIP(const S: string): u_long; inline;
function IPToIPString(IP: u_long): string; inline;

implementation

function IPStringToIP(const S: string): u_long;
begin
  Result := ntohl(inet_addr(PAnsiChar(AnsiString(S))));
end;

function IPToIPString(IP: u_long): string;
var
  addr: in_addr;
begin
  addr.S_addr := htonl(IP);
  Result := string(inet_ntoa(addr));
end;

var
  SocketLibData: TWSAData;

function WSAErrorString(ErrorCode: Integer): string;
var
  Buffer: array[0..2047] of Char;
begin
  FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM, nil, ErrorCode, 0,
    @Buffer, SizeOf(Buffer), nil);
  Result := Buffer;
end;

function WSAErrorString: string;
begin
  Result := WSAErrorString(WSAGetLastError);
end;

procedure WSARaiseError(ErrorCode: Integer);
begin
  if ErrorCode = 0 then Exit;
  if ErrorCode = WSAEWOULDBLOCK then Exit; // Normal behaviour to non-blocking sockets
  raise EWindowsSocket.Create('Socket Error #' + IntToStr(ErrorCode) + #13#10 +
    WSAErrorString(ErrorCode));
end;

procedure WSARaiseLastError;
begin
  WSARaiseError(WSAGetLastError);
end;

procedure WSACheck(ReturnValue: Integer);
begin
  if ReturnValue = SOCKET_ERROR then
    WSARaiseLastError;
end;

type
  TWSAOverlappedEx = packed record
    Overlapped: TWSAOverlapped;
    Socket: TSocket;
    CallBack: TSocketReadWriteCallBack;
    Buffer: array of Byte;
    _Buf: TWSABuf;
  end;
  PWSAOverlappedEx = ^TWSAOverlappedEx;

{ TSdaSocket }

class function TSdaSocket.CreateHandle(SocketType: TSocketType; Protocol: TSocketProtocol): TSocket;
var
  nbio: DWORD;
  {$IFDEF DEBUG}
  dbg: BOOL;
  sz: Integer;
  {$ENDIF}
begin
  Result := WSASocket(AF_INET, Integer(SocketType), Integer(Protocol), nil, 0, WSA_FLAG_OVERLAPPED);
  if Result = INVALID_SOCKET then WSARaiseLastError;
  nbio := 1; WSACheck(ioctlsocket(Result, FIONBIO, nbio));
  {$IFDEF DEBUG}
  dbg := true; sz := SizeOf(dbg);
  WSACheck(setsockopt(Result, SOL_SOCKET, SO_DEBUG, Pointer(@dbg), sz));
  {$ENDIF}
end;

procedure TSdaSocket.Bind(const IP: u_long; PortMin, PortMax: u_short; ReuseAddress: Boolean);
var
  addr: sockaddr_in;
  port: u_short;
  err: Integer;
  b: BOOL;
begin
  if Handle = INVALID_SOCKET then Exit;

  b := ReuseAddress;
  WSACheck(setsockopt(FHandle, SOL_SOCKET, SO_REUSEADDR, Pointer(@b), SizeOf(b)));

  if PortMin > PortMax then
  begin
    port := PortMin; PortMin := PortMax; PortMax := port;
  end;
  FillChar(addr, SizeOf(addr), 0);
  addr.sin_family := AF_INET;
  addr.sin_addr.S_addr := htonl(IP);
  for port := PortMin to PortMax do
  begin
    addr.sin_port := htons(port);
    if sdaWinSock.bind(FHandle, PSOCKADDR(@addr), SizeOf(addr)) <> SOCKET_ERROR then
    begin
      b := true;
      setsockopt(FHandle, SOL_SOCKET, SO_DONTLINGER, PAnsiChar(@b), SizeOf(BOOL));
      Exit;
    end;
    err := WSAGetLastError;
    if err <> WSAEADDRINUSE then WSARaiseError(err);
  end;
  WSARaiseError(WSAEADDRINUSE);
end;

procedure TSdaSocket.Connect(const IP: u_long; Port: u_short);
var
  addr: sockaddr_in;
begin
  if Handle = INVALID_SOCKET then Exit;
  FillChar(addr, SizeOf(addr), 0);
  addr.sin_family := AF_INET;
  addr.sin_port := htons(Port);
  addr.sin_addr.S_addr := htonl(IP);
  WSACheck(sdaWinSock.connect(FHandle, PSOCKADDR(@addr), SizeOf(addr)));
end;

procedure TSdaSocket.Connect(const Host: string; Port: u_short);
begin
  Connect(Resolve(Host), Port);
end;

procedure TSdaSocket.DestroyHandle;
begin
  if AutoProcessPendingOperations then ProcessPendingOperations;
  if Handle = INVALID_SOCKET then Exit;
  shutdown(FHandle, SD_BOTH);
  WSACheck(closesocket(FHandle));
  FHandle := INVALID_SOCKET;
end;

procedure TSdaSocket.Disconnect;
begin
  if Handle = INVALID_SOCKET then Exit;
  if not DisconnectEx(FHandle, nil, TF_REUSE_SOCKET, 0) then WSARaiseLastError;
end;

function TSdaSocket.GetIP: u_long;
var
  addr: sockaddr_in;
  len: Integer;
begin
  if Handle = INVALID_SOCKET then Exit(0);
  FillChar(addr, SizeOf(addr), 0);
  len := SizeOf(addr);
  WSACheck(getsockname(FHandle, @addr, len));
  if addr.sin_family <> AF_INET then Exit(0);
  Result := ntohl(addr.sin_addr.S_addr);
end;

function TSdaSocket.GetIsListening: Boolean;
var
  res: BOOL;
  sz: Integer;
begin
  if Handle = INVALID_SOCKET then Exit(false);
  res := false; sz := 0;
  WSACheck(getsockopt(FHandle, SOL_SOCKET, SO_ACCEPTCONN, Pointer(@res), sz));
  Result := res;
end;

function TSdaSocket.GetPeerIP: u_long;
var
  addr: sockaddr_in;
  len: Integer;
begin
  if Handle = INVALID_SOCKET then Exit(0);
  FillChar(addr, SizeOf(addr), 0);
  len := SizeOf(addr);
  WSACheck(getpeername(FHandle, @addr, len));
  if addr.sin_family <> AF_INET then Exit(0);
  Result := ntohl(addr.sin_addr.S_addr);
end;

function TSdaSocket.GetPeerPort: u_short;
var
  addr: sockaddr_in;
  len: Integer;
begin
  if Handle = INVALID_SOCKET then Exit(0);
  FillChar(addr, SizeOf(addr), 0);
  len := SizeOf(addr);
  WSACheck(getpeername(FHandle, @addr, len));
  if addr.sin_family <> AF_INET then Exit(0);
  Result := ntohs(addr.sin_port);
end;

function TSdaSocket.GetPort: u_short;
var
  addr: sockaddr_in;
  len: Integer;
begin
  if Handle = INVALID_SOCKET then Exit(0);
  FillChar(addr, SizeOf(addr), 0);
  len := SizeOf(addr);
  WSACheck(getsockname(FHandle, @addr, len));
  if addr.sin_family <> AF_INET then Exit(0);
  Result := ntohs(addr.sin_port);
end;

function TSdaSocket.GetSocketType: Integer;
var
  len: Integer;
begin
  if Handle = INVALID_SOCKET then Exit(0);
  len := SizeOf(Result);
  WSACheck(getsockopt(FHandle, SOL_SOCKET, SO_TYPE, PAnsiChar(@Result), len));
end;

class operator TSdaSocket.Implicit(Value: TSocket): TSdaSocket;
begin
  Result.Handle := Value;
end;

procedure TSdaSocket.Listen;
begin
  if Handle = INVALID_SOCKET then Exit;
  WSACheck(WSAListen(FHandle, SOMAXCONN));
end;

class procedure TSdaSocket.ProcessPendingOperations;
begin
  while SleepEx(10, true) = WAIT_IO_COMPLETION do ;
end;

procedure TSdaSocket.Bind(const Host: string; PortMin, PortMax: u_short; ReuseAddress: Boolean);
begin
  Bind(Resolve(Host), PortMin, PortMax, ReuseAddress);
end;

procedure TSdaSocket.Bind(const IP: u_long; Port: u_short; ReuseAddress: Boolean);
begin
  Bind(IP, Port, Port, ReuseAddress);
end;

procedure TSdaSocket.Bind(const Host: string; Port: u_short; ReuseAddress: Boolean);
begin
  Bind(Resolve(Host), Port, Port, ReuseAddress);
end;

class procedure TSdaSocket.CompletionRoutine(dwError, cbTransferred: DWORD;
  lpOverlapped: PWSAOverlapped; dwFlags: DWORD); stdcall;
var
  OverlappedEx: PWSAOverlappedEx absolute lpOverlapped;
begin
  // When connection is closed, completion routine is notified in one of ways:
  // 1. when cbTransferred = 0, conneciton was closed grasefully;
  // 2. when dwError = WSAEDISCON means the same - graseful disconnect;
  // 3. when dwError = WSAECONNRESET connection was aborted.
  // When detecting one of this cases, and there is callback, let pass
  // appropriate error code to it, and let it destroy socket. Is there was not
  // callback specified, we need to destroy socket
  if cbTransferred = 0 then dwError := WSAEDISCON; // Graseful disconnect
  if Assigned(OverlappedEx.CallBack) and (Length(OverlappedEx.Buffer) > 0) then
  begin
    if dwError <> 0 then cbTransferred := 0;
    OverlappedEx.CallBack(OverlappedEx.Socket, @OverlappedEx.Buffer[0],
      cbTransferred, dwError);
  end else
  begin
    if dwError <> 0 then closesocket(OverlappedEx.Socket);
  end;
  SetLength(OverlappedEx.Buffer, 0);
  Dispose(lpOverlapped);
end;

procedure TSdaSocket.Read(BytesNeeded: Integer;
  const CallBack: TSocketReadWriteCallBack);
var
  OverlappedEx: PWSAOverlappedEx;
  Overlapped: PWSAOverlapped absolute OverlappedEx;
  Res: Integer;
  BytesReceived, Flags: DWORD;
begin
  if (Handle = INVALID_SOCKET) or (BytesNeeded <= 0) then Exit;

  New(OverlappedEx);
  FillChar(OverlappedEx.Overlapped, SizeOf(OverlappedEx.Overlapped), 0);
  OverlappedEx.Socket := Handle;
  OverlappedEx.CallBack := CallBack;
  SetLength(OverlappedEx.Buffer, BytesNeeded);

  Flags := 0;
  OverlappedEx._Buf.Len := Length(OverlappedEx.Buffer);
  OverlappedEx._Buf.Buf := @OverlappedEx.Buffer[0];
  if WSARecv(Handle, @OverlappedEx._Buf, 1, BytesReceived, Flags, Overlapped,
    CompletionRoutine) = SOCKET_ERROR then Res := WSAGetLastError
    else Res := 0;
  if Res <> WSA_IO_PENDING then WSARaiseError(Res);

  if AutoProcessPendingOperations then ProcessPendingOperations;
end;

procedure TSdaSocket.ReadFrom(const HostName: string; Port: u_short;
  BytesNeeded: Integer; const CallBack: TSocketReadWriteCallBack);
begin
  ReadFrom(Resolve(HostName), Port, BytesNeeded, CallBack);
end;

procedure TSdaSocket.ReadFrom(const IP: u_long; Port: u_short;
  BytesNeeded: Integer; const CallBack: TSocketReadWriteCallBack);
var
  OverlappedEx: PWSAOverlappedEx;
  Overlapped: PWSAOverlapped absolute OverlappedEx;
  Res: Integer;
  BytesReceived, Flags: DWORD;
  addr: sockaddr_in;
  addrlen: Integer;
begin
  if (Handle = INVALID_SOCKET) or (BytesNeeded <= 0) then Exit;

  New(OverlappedEx);
  FillChar(OverlappedEx.Overlapped, SizeOf(OverlappedEx.Overlapped), 0);
  OverlappedEx.Socket := Handle;
  OverlappedEx.CallBack := CallBack;
  SetLength(OverlappedEx.Buffer, BytesNeeded);

  FillChar(addr, SizeOf(addr), 0);
  addr.sin_family := AF_INET;
  addr.sin_port := htons(Port);
  addr.sin_addr.S_addr := htonl(IP);
  addrlen := SizeOf(addr);

  Flags := 0;
  OverlappedEx._Buf.Len := Length(OverlappedEx.Buffer);
  OverlappedEx._Buf.Buf := @OverlappedEx.Buffer[0];
  if WSARecvFrom(Handle, @OverlappedEx._Buf, 1, BytesReceived, Flags,
    PSOCKADDR(@addr), addrlen, Overlapped, CompletionRoutine) = SOCKET_ERROR
    then Res := WSAGetLastError
    else Res := 0;
  if Res <> WSA_IO_PENDING then WSARaiseError(Res);

  if AutoProcessPendingOperations then ProcessPendingOperations;
end;

procedure TSdaSocket.Write(const Data; DataSize: Integer;
  const CallBack: TSocketReadWriteCallBack);
var
  OverlappedEx: PWSAOverlappedEx;
  Overlapped: PWSAOverlapped absolute OverlappedEx;
  Res: Integer;
  BytesSent, Flags: DWORD;
begin
  if (Handle = INVALID_SOCKET) or (@Data = nil) or (DataSize <= 0) then Exit;

  New(OverlappedEx);
  FillChar(OverlappedEx.Overlapped, SizeOf(OverlappedEx.Overlapped), 0);
  OverlappedEx.Socket := Handle;
  OverlappedEx.CallBack := CallBack;
  SetLength(OverlappedEx.Buffer, DataSize);
  Move(Data, OverlappedEx.Buffer[0], DataSize);

  Flags := 0;
  OverlappedEx._Buf.Len := Length(OverlappedEx.Buffer);
  OverlappedEx._Buf.Buf := @OverlappedEx.Buffer[0];
  if WSASend(Handle, @OverlappedEx._Buf, 1, BytesSent, Flags, Overlapped,
    CompletionRoutine) = SOCKET_ERROR then Res := WSAGetLastError
    else Res := 0;
  if Res <> WSA_IO_PENDING then WSARaiseError(Res);
  if AutoProcessPendingOperations then ProcessPendingOperations;
end;

procedure TSdaSocket.WriteTo(const HostName: string; Port: u_short; const Data;
  DataSize: Integer; const CallBack: TSocketReadWriteCallBack);
begin
  WriteTo(Resolve(HostName), Port, Data, DataSize, CallBack);
end;

procedure TSdaSocket.WriteTo(const IP: u_long; Port: u_short; const Data;
  DataSize: Integer; const CallBack: TSocketReadWriteCallBack);
var
  OverlappedEx: PWSAOverlappedEx;
  Overlapped: PWSAOverlapped absolute OverlappedEx;
  Res: Integer;
  BytesSent, Flags: DWORD;
  addr: sockaddr_in;
begin
  if (Handle = INVALID_SOCKET) or (@Data = nil) or (DataSize <= 0) then Exit;

  New(OverlappedEx);
  FillChar(OverlappedEx.Overlapped, SizeOf(OverlappedEx.Overlapped), 0);
  OverlappedEx.Socket := Handle;
  OverlappedEx.CallBack := CallBack;
  SetLength(OverlappedEx.Buffer, DataSize);
  Move(Data, OverlappedEx.Buffer[0], DataSize);

  FillChar(addr, SizeOf(addr), 0);
  addr.sin_family := AF_INET;
  addr.sin_port := htons(Port);
  addr.sin_addr.S_addr := htonl(IP);

  Flags := 0;
  OverlappedEx._Buf.Len := Length(OverlappedEx.Buffer);
  OverlappedEx._Buf.Buf := @OverlappedEx.Buffer[0];
  if WSASendTo(Handle, @OverlappedEx._Buf, 1, BytesSent, Flags,
    PSOCKADDR(@addr), SizeOf(addr), Overlapped, CompletionRoutine) = SOCKET_ERROR
    then Res := WSAGetLastError
    else Res := 0;
  if Res <> WSA_IO_PENDING then WSARaiseError(Res);
  if AutoProcessPendingOperations then ProcessPendingOperations;
end;

function TSdaSocket.Accept: TSocket;
var
  addr: sockaddr_in;
  len: Integer;
  accept_set: TFDSet;
  time: TTimeVal;
begin
  if Handle = INVALID_SOCKET then Exit(INVALID_SOCKET);
  FD_ZERO(accept_set); FD_SET(FHandle, accept_set);
  time.tv_sec := 0; time.tv_usec := 0;
  WSACheck(select(0, @accept_set, nil, nil, @time));
  if not FD_ISSET(FHandle, accept_set) then Exit(INVALID_SOCKET);

  FillChar(addr, SizeOf(addr), 0); len := SizeOf(addr);
  Result := sdaWinSock.accept(FHandle, PSOCKADDR(@addr), @len);
  if Result = INVALID_SOCKET then WSARaiseLastError;
end;

class function TSdaSocket.Resolve(const HostName: string): u_long;
var
  host: PHostEnt;
begin
  host := gethostbyname(PAnsiChar(AnsiString(HostName)));
  if host = nil then WSARaiseLastError;
  if host.h_addrtype <> AF_INET then WSARaiseError(WSAHOST_NOT_FOUND);
  Result := ntohl(PInAddr(host.h_addr^).S_addr);
end;

class function TSdaSocket.HostName(IP: u_long): string;
var
  host: PHostEnt;
  addr: in_addr;
begin
  FillChar(addr, SizeOf(addr), 0); addr.S_addr := htonl(IP);
  host := gethostbyaddr(@addr, SizeOf(addr), AF_INET);
  if host = nil then WSARaiseLastError;
  if host.h_addrtype <> AF_INET then WSARaiseError(WSAHOST_NOT_FOUND);
  Result := string(host.h_name);
end;

class operator TSdaSocket.Implicit(const Value: TSdaSocket): TSocket;
begin
  Result := Value.Handle;
end;

function TSdaSocket.GetHandle: TSocket;
begin
  if FHandle = 0 then FHandle := INVALID_SOCKET;
  Result := FHandle;
end;

function TSdaSocket.GetAllowBroadcast: Boolean;
var
  b: BOOL;
  sz: Integer;
begin
  sz := SizeOf(b);
  WSACheck(getsockopt(Handle, SOL_SOCKET, SO_BROADCAST, Pointer(@b), sz));
  Result := b;
end;

class function TSdaSocket.GetComputerIP: u_long;
var
  Buf: array [Word] of AnsiChar;
  host: PHostEnt;
begin
  FillChar(Buf, SizeOf(Buf), 0);
  WSACheck(sdaWinSock.gethostname(Buf, Length(Buf)));
  host := gethostbyname(Buf);
  if host = nil then WSARaiseLastError;
  if host.h_addrtype <> AF_INET then WSARaiseError(WSAHOST_NOT_FOUND);
  Result := ntohl(PInAddr(host.h_addr^).S_addr);
end;

class function TSdaSocket.GetComputerName: string;
var
  Buf: array [Word] of AnsiChar;
begin
  FillChar(Buf, SizeOf(Buf), 0);
  WSACheck(sdaWinSock.gethostname(Buf, Length(Buf)));
  Result := string(Buf);
end;

function TSdaSocket.GetConnected: Boolean;
var
  sw, se: TFDSet;
  err: LongInt;
  sz: Integer;
begin
  if Handle = INVALID_SOCKET then Exit(false);
  FD_ZERO(sw); FD_SET(FHandle, sw);
  FD_ZERO(se); FD_SET(FHandle, se);
  select(0, nil, @sw, @se, nil);
  if FD_ISSET(FHandle, se) then
  begin
    err := 0; sz := SizeOf(err);
    WSACheck(getsockopt(FHandle, SOL_SOCKET, SO_ERROR, Pointer(@err), sz));
    WSARaiseError(err);
  end;
  Result := FD_ISSET(FHandle, sw);
end;

procedure TSdaSocket.SetAllowBroadcast(const Value: Boolean);
var
  b: BOOL;
begin
  WSACheck(setsockopt(Handle, SOL_SOCKET, SO_BROADCAST, Pointer(@b), SizeOf(b)));
end;

procedure TSdaSocket.SetHandle(const Value: TSocket);
begin
  FHandle := Value;
  if FHandle = 0 then FHandle := INVALID_SOCKET;
end;

function TSdaSocket.GetUseNagle: Boolean;
var
  res: BOOL;
  sz: Integer;
begin
  if Handle = INVALID_SOCKET then Exit(false);
  res := false; sz := 0;
  WSACheck(getsockopt(FHandle, IPPROTO_TCP, TCP_NODELAY, Pointer(@res), sz));
  Result := res;
end;

procedure TSdaSocket.SetUseNagle(const Value: Boolean);
var
  res: BOOL;
  sz: Integer;
begin
  if Handle = INVALID_SOCKET then Exit;
  res := Value; sz := SizeOf(res);
  WSACheck(setsockopt(FHandle, IPPROTO_TCP, TCP_NODELAY, Pointer(@res), sz));
end;

function TSdaSocket.GetEvents: TWSANetworkEvents;
begin
  FillCHar(Result, SizeOf(Result), 0);
  if Handle = INVALID_SOCKET then Exit;
  WSACheck(WSAEnumNetworkEvents(FHandle, 0, Result));
end;

initialization
  FillChar(SocketLibData, SizeOf(SocketLibData), 0);
  WSARaiseError(WSAStartup($0202, SocketLibData));
  TSdaSocket.AutoProcessPendingOperations := false;
finalization
  WSACleanup;
end.             
