unit sdaWinSock;

interface

{$INCLUDE 'sda.inc'}

uses
  sdaWindows;

type
  u_char = AnsiChar;
  u_short = Word;
  u_int = Integer;
  u_long = DWORD;

  TSocket = u_int;

const
  FD_SETSIZE     =   64;

  SD_RECEIVE     = 0;
  SD_SEND        = 1;
  SD_BOTH        = 2;

type
  PFDSet = ^TFDSet;
  TFDSet = record
    fd_count: u_int;
    fd_array: array[0..FD_SETSIZE-1] of TSocket;
  end;

  PTimeVal = ^TTimeVal;
  timeval = record
    tv_sec: Longint;
    tv_usec: Longint;
  end;
  TTimeVal = timeval;

const
  IOCPARM_MASK = $7f;
  IOC_VOID     = $20000000;
  IOC_OUT      = $40000000;
  IOC_IN       = $80000000;
  IOC_INOUT    = (IOC_IN or IOC_OUT);

  FIONREAD     = IOC_OUT or { get # bytes to read }
    ((Longint(SizeOf(Longint)) and IOCPARM_MASK) shl 16) or
    (Longint(Byte('f')) shl 8) or 127;
  FIONBIO      = IOC_IN or { set/clear non-blocking i/o }
    ((Longint(SizeOf(Longint)) and IOCPARM_MASK) shl 16) or
    (Longint(Byte('f')) shl 8) or 126;
  FIOASYNC     = IOC_IN or { set/clear async i/o }
    ((Longint(SizeOf(Longint)) and IOCPARM_MASK) shl 16) or
    (Longint(Byte('f')) shl 8) or 125;

type
  PHostEnt = ^THostEnt;
  hostent = record
    h_name: PAnsiChar;
    h_aliases: ^PAnsiChar;
    h_addrtype: Smallint;
    h_length: Smallint;
    case Byte of
      0: (h_addr_list: ^PAnsiChar);
      1: (h_addr: ^PAnsiChar)
  end;
  THostEnt = hostent;

  PNetEnt = ^TNetEnt;
  netent = record
    n_name: PAnsiChar;
    n_aliases: ^PAnsiChar;
    n_addrtype: Smallint;
    n_net: u_long;
  end;
  TNetEnt = netent;

  PServEnt = ^TServEnt;
  servent = record
    s_name: PAnsiChar;
    s_aliases: ^PAnsiChar;
    s_port: Word;
    s_proto: PAnsiChar;
  end;
  TServEnt = servent;

  PProtoEnt = ^TProtoEnt;
  protoent = record
    p_name: PAnsiChar;
    p_aliases: ^PAnsiChar;
    p_proto: Smallint;
  end;
  TProtoEnt = protoent;

const

{ Protocols }

  IPPROTO_IP     =   0;             { dummy for IP }
  IPPROTO_ICMP   =   1;             { control message protocol }
  IPPROTO_IGMP   =   2;             { group management protocol }
  IPPROTO_GGP    =   3;             { gateway^2 (deprecated) }
  IPPROTO_TCP    =   6;             { tcp }
  IPPROTO_PUP    =  12;             { pup }
  IPPROTO_UDP    =  17;             { user datagram protocol }
  IPPROTO_IDP    =  22;             { xns idp }
  IPPROTO_ND     =  77;             { UNOFFICIAL net disk proto }
  IPPROTO_RAW    =  255;            { raw IP packet }
  IPPROTO_MAX    =  256;

{ Port/socket numbers: network standard functions}

  IPPORT_ECHO    =   7;
  IPPORT_DISCARD =   9;
  IPPORT_SYSTAT  =   11;
  IPPORT_DAYTIME =   13;
  IPPORT_NETSTAT =   15;
  IPPORT_FTP     =   21;
  IPPORT_TELNET  =   23;
  IPPORT_SMTP    =   25;
  IPPORT_TIMESERVER  =  37;
  IPPORT_NAMESERVER  =  42;
  IPPORT_WHOIS       =  43;
  IPPORT_MTP         =  57;

{ Port/socket numbers: host specific functions }

  IPPORT_TFTP        =  69;
  IPPORT_RJE         =  77;
  IPPORT_FINGER      =  79;
  IPPORT_TTYLINK     =  87;
  IPPORT_SUPDUP      =  95;

{ UNIX TCP sockets }

  IPPORT_EXECSERVER  =  512;
  IPPORT_LOGINSERVER =  513;
  IPPORT_CMDSERVER   =  514;
  IPPORT_EFSSERVER   =  520;

{ UNIX UDP sockets }

  IPPORT_BIFFUDP     =  512;
  IPPORT_WHOSERVER   =  513;
  IPPORT_ROUTESERVER =  520;

{ Ports < IPPORT_RESERVED are reserved for
  privileged processes (e.g. root). }

  IPPORT_RESERVED    =  1024;

{ Link numbers }

  IMPLINK_IP         =  155;
  IMPLINK_LOWEXPER   =  156;
  IMPLINK_HIGHEXPER  =  158;

type
  SunB = packed record
    s_b1, s_b2, s_b3, s_b4: u_char;
  end;

  SunW = packed record
    s_w1, s_w2: u_short;
  end;

  PInAddr = ^TInAddr;
  in_addr = record
    case integer of
      0: (S_un_b: SunB);
      1: (S_un_w: SunW);
      2: (S_addr: u_long);
  end;
  TInAddr = in_addr;

  PSockAddrIn = ^TSockAddrIn;
  sockaddr_in = record
    case Integer of
      0: (sin_family: u_short;
          sin_port: u_short;
          sin_addr: TInAddr;
          sin_zero: array[0..7] of AnsiChar);
      1: (sa_family: u_short;
          sa_data: array[0..13] of AnsiChar)
  end;
  TSockAddrIn = sockaddr_in;

const
  INADDR_ANY       = $00000000;
  INADDR_LOOPBACK  = $7F000001;
  INADDR_BROADCAST = DWORD($FFFFFFFF);
  INADDR_NONE      = DWORD($FFFFFFFF);

  WSADESCRIPTION_LEN     =   256;
  WSASYS_STATUS_LEN      =   128;

type
  PWSAData = ^TWSAData;
  WSAData = record // !!! also WSDATA
    wVersion: Word;
    wHighVersion: Word;
    szDescription: array[0..WSADESCRIPTION_LEN] of AnsiChar;
    szSystemStatus: array[0..WSASYS_STATUS_LEN] of AnsiChar;
    iMaxSockets: Word;
    iMaxUdpDg: Word;
    lpVendorInfo: PAnsiChar;
  end;
  TWSAData = WSAData;

  PTransmitFileBuffers = ^TTransmitFileBuffers;
  _TRANSMIT_FILE_BUFFERS = record
      Head: Pointer;
      HeadLength: DWORD;
      Tail: Pointer;
      TailLength: DWORD;
  end;
  TTransmitFileBuffers = _TRANSMIT_FILE_BUFFERS;
  TRANSMIT_FILE_BUFFERS = _TRANSMIT_FILE_BUFFERS;


const
  TF_DISCONNECT           = $01;
  TF_REUSE_SOCKET         = $02;
  TF_WRITE_BEHIND         = $04;

{ Options for use with [gs]etsockopt at the IP level. }

  IP_OPTIONS          = 1;
  IP_MULTICAST_IF     = 2;           { set/get IP multicast interface   }
  IP_MULTICAST_TTL    = 3;           { set/get IP multicast timetolive  }
  IP_MULTICAST_LOOP   = 4;           { set/get IP multicast loopback    }
  IP_ADD_MEMBERSHIP   = 5;           { add  an IP group membership      }
  IP_DROP_MEMBERSHIP  = 6;           { drop an IP group membership      }
  IP_TTL              = 7;           { set/get IP Time To Live          }
  IP_TOS              = 8;           { set/get IP Type Of Service       }
  IP_DONTFRAGMENT     = 9;           { set/get IP Don't Fragment flag   }


  IP_DEFAULT_MULTICAST_TTL   = 1;    { normally limit m'casts to 1 hop  }
  IP_DEFAULT_MULTICAST_LOOP  = 1;    { normally hear sends if a member  }
  IP_MAX_MEMBERSHIPS         = 20;   { per socket; must fit in one mbuf }

{ This is used instead of -1, since the
  TSocket type is unsigned.}

  INVALID_SOCKET    = TSocket(not(0));
  SOCKET_ERROR      = -1;

{ Types }

  SOCK_STREAM     = 1;               { stream socket }
  SOCK_DGRAM      = 2;               { datagram socket }
  SOCK_RAW        = 3;               { raw-protocol interface }
  SOCK_RDM        = 4;               { reliably-delivered message }
  SOCK_SEQPACKET  = 5;               { sequenced packet stream }

{ Option flags per-socket. }

  SO_DEBUG        = $0001;          { turn on debugging info recording }
  SO_ACCEPTCONN   = $0002;          { socket has had listen() }
  SO_REUSEADDR    = $0004;          { allow local address reuse }
  SO_KEEPALIVE    = $0008;          { keep connections alive }
  SO_DONTROUTE    = $0010;          { just use interface addresses }
  SO_BROADCAST    = $0020;          { permit sending of broadcast msgs }
  SO_USELOOPBACK  = $0040;          { bypass hardware when possible }
  SO_LINGER       = $0080;          { linger on close if data present }
  SO_OOBINLINE    = $0100;          { leave received OOB data in line }

  SO_DONTLINGER  =   $ff7f;

{ Additional options. }

  SO_SNDBUF       = $1001;          { send buffer size }
  SO_RCVBUF       = $1002;          { receive buffer size }
  SO_SNDLOWAT     = $1003;          { send low-water mark }
  SO_RCVLOWAT     = $1004;          { receive low-water mark }
  SO_SNDTIMEO     = $1005;          { send timeout }
  SO_RCVTIMEO     = $1006;          { receive timeout }
  SO_ERROR        = $1007;          { get error status and clear }
  SO_TYPE         = $1008;          { get socket type }

{ Options for connect and disconnect data and options.  Used only by
  non-TCP/IP transports such as DECNet, OSI TP4, etc. }

  SO_CONNDATA     = $7000;
  SO_CONNOPT      = $7001;
  SO_DISCDATA     = $7002;
  SO_DISCOPT      = $7003;
  SO_CONNDATALEN  = $7004;
  SO_CONNOPTLEN   = $7005;
  SO_DISCDATALEN  = $7006;
  SO_DISCOPTLEN   = $7007;

{ Option for opening sockets for synchronous access. }

  SO_OPENTYPE     = $7008;

  SO_SYNCHRONOUS_ALERT    = $10;
  SO_SYNCHRONOUS_NONALERT = $20;

{ Other NT-specific options. }

  SO_MAXDG        = $7009;
  SO_MAXPATHDG    = $700A;
  SO_UPDATE_ACCEPT_CONTEXT     = $700B;
  SO_CONNECT_TIME = $700C;

{ TCP options. }

  TCP_NODELAY     = $0001;
  TCP_BSDURGENT   = $7000;

{ Address families. }

  AF_UNSPEC       = 0;               { unspecified }
  AF_UNIX         = 1;               { local to host (pipes, portals) }
  AF_INET         = 2;               { internetwork: UDP, TCP, etc. }
  AF_IMPLINK      = 3;               { arpanet imp addresses }
  AF_PUP          = 4;               { pup protocols: e.g. BSP }
  AF_CHAOS        = 5;               { mit CHAOS protocols }
  AF_IPX          = 6;               { IPX and SPX }
  AF_NS           = 6;               { XEROX NS protocols }
  AF_ISO          = 7;               { ISO protocols }
  AF_OSI          = AF_ISO;          { OSI is ISO }
  AF_ECMA         = 8;               { european computer manufacturers }
  AF_DATAKIT      = 9;               { datakit protocols }
  AF_CCITT        = 10;              { CCITT protocols, X.25 etc }
  AF_SNA          = 11;              { IBM SNA }
  AF_DECnet       = 12;              { DECnet }
  AF_DLI          = 13;              { Direct data link interface }
  AF_LAT          = 14;              { LAT }
  AF_HYLINK       = 15;              { NSC Hyperchannel }
  AF_APPLETALK    = 16;              { AppleTalk }
  AF_NETBIOS      = 17;              { NetBios-style addresses }
  AF_VOICEVIEW    = 18;              { VoiceView }
  AF_FIREFOX      = 19;              { FireFox }
  AF_UNKNOWN1     = 20;              { Somebody is using this! }
  AF_BAN          = 21;              { Banyan }
  AF_MAX          = 22;

type
  { Structure used by kernel to store most addresses. }

  PSOCKADDR = ^TSockAddr;
  TSockAddr = sockaddr_in;

  { Structure used by kernel to pass protocol information in raw sockets. }
  PSockProto = ^TSockProto;
  sockproto = record
    sp_family: u_short;
    sp_protocol: u_short;
  end;
  TSockProto = sockproto;

const
{ Protocol families, same as address families for now. }

  PF_UNSPEC       = AF_UNSPEC;
  PF_UNIX         = AF_UNIX;
  PF_INET         = AF_INET;
  PF_IMPLINK      = AF_IMPLINK;
  PF_PUP          = AF_PUP;
  PF_CHAOS        = AF_CHAOS;
  PF_NS           = AF_NS;
  PF_IPX          = AF_IPX;
  PF_ISO          = AF_ISO;
  PF_OSI          = AF_OSI;
  PF_ECMA         = AF_ECMA;
  PF_DATAKIT      = AF_DATAKIT;
  PF_CCITT        = AF_CCITT;
  PF_SNA          = AF_SNA;
  PF_DECnet       = AF_DECnet;
  PF_DLI          = AF_DLI;
  PF_LAT          = AF_LAT;
  PF_HYLINK       = AF_HYLINK;
  PF_APPLETALK    = AF_APPLETALK;
  PF_VOICEVIEW    = AF_VOICEVIEW;
  PF_FIREFOX      = AF_FIREFOX;
  PF_UNKNOWN1     = AF_UNKNOWN1;
  PF_BAN          = AF_BAN;
  PF_MAX          = AF_MAX;

type
{ Structure used for manipulating linger option. }
  PLinger = ^TLinger;
  linger = record
    l_onoff: u_short;
    l_linger: u_short;
  end;
  TLinger = linger;

const
{ Level number for (get/set)sockopt() to apply to socket itself. }

  SOL_SOCKET      = $ffff;          {options for socket level }

{ Maximum queue length specifiable by listen. }

  SOMAXCONN       = 5;

  MSG_OOB         = $1;             {process out-of-band data }
  MSG_PEEK        = $2;             {peek at incoming message }
  MSG_DONTROUTE   = $4;             {send without using routing tables }

  MSG_MAXIOVLEN   = 16;

  MSG_PARTIAL     = $8000;          {partial send or recv for message xport }

{ Define constant based on rfc883, used by gethostbyxxxx() calls. }

  MAXGETHOSTSTRUCT        = 1024;



{ All Windows Sockets error constants are biased by WSABASEERR from the "normal" }

  WSABASEERR              = 10000;

{ Windows Sockets definitions of regular Microsoft C error constants }

  WSAEINTR                = (WSABASEERR+4);
  WSAEBADF                = (WSABASEERR+9);
  WSAEACCES               = (WSABASEERR+13);
  WSAEFAULT               = (WSABASEERR+14);
  WSAEINVAL               = (WSABASEERR+22);
  WSAEMFILE               = (WSABASEERR+24);

{ Windows Sockets definitions of regular Berkeley error constants }

  WSAEWOULDBLOCK          = (WSABASEERR+35);
  WSAEINPROGRESS          = (WSABASEERR+36);
  WSAEALREADY             = (WSABASEERR+37);
  WSAENOTSOCK             = (WSABASEERR+38);
  WSAEDESTADDRREQ         = (WSABASEERR+39);
  WSAEMSGSIZE             = (WSABASEERR+40);
  WSAEPROTOTYPE           = (WSABASEERR+41);
  WSAENOPROTOOPT          = (WSABASEERR+42);
  WSAEPROTONOSUPPORT      = (WSABASEERR+43);
  WSAESOCKTNOSUPPORT      = (WSABASEERR+44);
  WSAEOPNOTSUPP           = (WSABASEERR+45);
  WSAEPFNOSUPPORT         = (WSABASEERR+46);
  WSAEAFNOSUPPORT         = (WSABASEERR+47);
  WSAEADDRINUSE           = (WSABASEERR+48);
  WSAEADDRNOTAVAIL        = (WSABASEERR+49);
  WSAENETDOWN             = (WSABASEERR+50);
  WSAENETUNREACH          = (WSABASEERR+51);
  WSAENETRESET            = (WSABASEERR+52);
  WSAECONNABORTED         = (WSABASEERR+53);
  WSAECONNRESET           = (WSABASEERR+54);
  WSAENOBUFS              = (WSABASEERR+55);
  WSAEISCONN              = (WSABASEERR+56);
  WSAENOTCONN             = (WSABASEERR+57);
  WSAESHUTDOWN            = (WSABASEERR+58);
  WSAETOOMANYREFS         = (WSABASEERR+59);
  WSAETIMEDOUT            = (WSABASEERR+60);
  WSAECONNREFUSED         = (WSABASEERR+61);
  WSAELOOP                = (WSABASEERR+62);
  WSAENAMETOOLONG         = (WSABASEERR+63);
  WSAEHOSTDOWN            = (WSABASEERR+64);
  WSAEHOSTUNREACH         = (WSABASEERR+65);
  WSAENOTEMPTY            = (WSABASEERR+66);
  WSAEPROCLIM             = (WSABASEERR+67);
  WSAEUSERS               = (WSABASEERR+68);
  WSAEDQUOT               = (WSABASEERR+69);
  WSAESTALE               = (WSABASEERR+70);
  WSAEREMOTE              = (WSABASEERR+71);
  WSAEDISCON              = (WSABASEERR+101);

{ Extended Windows Sockets error constant definitions }

  WSASYSNOTREADY          = (WSABASEERR+91);
  WSAVERNOTSUPPORTED      = (WSABASEERR+92);
  WSANOTINITIALISED       = (WSABASEERR+93);

{ Error return codes from gethostbyname() and gethostbyaddr()
  (when using the resolver). Note that these errors are
  retrieved via WSAGetLastError() and must therefore follow
  the rules for avoiding clashes with error numbers from
  specific implementations or language run-time systems.
  For this reason the codes are based at WSABASEERR+1001.
  Note also that [WSA]NO_ADDRESS is defined only for
  compatibility purposes. }

{ Authoritative Answer: Host not found }

  WSAHOST_NOT_FOUND       = (WSABASEERR+1001);
  HOST_NOT_FOUND          = WSAHOST_NOT_FOUND;

{ Non-Authoritative: Host not found, or SERVERFAIL }

  WSATRY_AGAIN            = (WSABASEERR+1002);
  TRY_AGAIN               = WSATRY_AGAIN;

{ Non recoverable errors, FORMERR, REFUSED, NOTIMP }

  WSANO_RECOVERY          = (WSABASEERR+1003);
  NO_RECOVERY             = WSANO_RECOVERY;

{ Valid name, no data record of requested type }

  WSANO_DATA              = (WSABASEERR+1004);
  NO_DATA                 = WSANO_DATA;

{ no address, look for MX record }

  WSANO_ADDRESS           = WSANO_DATA;
  NO_ADDRESS              = WSANO_ADDRESS;

{ Socket function prototypes }

function accept(s: TSocket; addr: PSockAddr; addrlen: PInteger): TSocket; stdcall;
function bind(s: TSocket; addr: PSockAddr; namelen: Integer): Integer; stdcall;
function closesocket(s: TSocket): Integer; stdcall;
function connect(s: TSocket; name: PSockAddr; namelen: Integer): Integer; stdcall;
function ioctlsocket(s: TSocket; cmd: DWORD; var arg: u_long): Integer; stdcall;
function getpeername(s: TSocket; name: PSockAddr; var namelen: Integer): Integer; stdcall;
function getsockname(s: TSocket; name: PSockAddr; var namelen: Integer): Integer; stdcall;
function getsockopt(s: TSocket; level, optname: Integer; optval: PAnsiChar; var optlen: Integer): Integer; stdcall;
function htonl(hostlong: u_long): u_long; stdcall;
function htons(hostshort: u_short): u_short; stdcall;
function inet_addr(cp: PAnsiChar): u_long; stdcall; {PInAddr;}  { TInAddr }
function inet_ntoa(inaddr: TInAddr): PAnsiChar; stdcall;
function listen(s: TSocket; backlog: Integer): Integer; stdcall;
function ntohl(netlong: u_long): u_long; stdcall;
function ntohs(netshort: u_short): u_short; stdcall;
function recv(s: TSocket; var Buf; len, flags: Integer): Integer; stdcall;
function recvfrom(s: TSocket; var Buf; len, flags: Integer;
  var from: TSockAddr; var fromlen: Integer): Integer; stdcall;
function select(nfds: Integer; readfds, writefds, exceptfds: PFDSet;
  timeout: PTimeVal): Longint; stdcall;
function send(s: TSocket; const Buf; len, flags: Integer): Integer; stdcall;
function sendto(s: TSocket; const Buf; len, flags: Integer; var addrto: TSockAddr;
  tolen: Integer): Integer; stdcall;
function setsockopt(s: TSocket; level, optname: Integer; optval: PAnsiChar;
  optlen: Integer): Integer; stdcall;
function shutdown(s: TSocket; how: Integer): Integer; stdcall;
function socket(af, Struct, protocol: Integer): TSocket; stdcall;
function gethostbyaddr(addr: Pointer; len, Struct: Integer): PHostEnt; stdcall;
function gethostbyname(name: PAnsiChar): PHostEnt; stdcall;
function gethostname(name: PAnsiChar; len: Integer): Integer; stdcall;
function getservbyport(port: Integer; proto: PAnsiChar): PServEnt; stdcall;
function getservbyname(name, proto: PAnsiChar): PServEnt; stdcall;
function getprotobynumber(proto: Integer): PProtoEnt; stdcall;
function getprotobyname(name: PAnsiChar): PProtoEnt; stdcall;
function WSAStartup(wVersionRequired: word; var WSData: TWSAData): Integer; stdcall;
function WSACleanup: Integer; stdcall;
procedure WSASetLastError(iError: Integer); stdcall;
function WSAGetLastError: Integer; stdcall;
function WSAIsBlocking: BOOL; stdcall;
function WSAUnhookBlockingHook: Integer; stdcall;
function WSASetBlockingHook(lpBlockFunc: TFarProc): TFarProc; stdcall;
function WSACancelBlockingCall: Integer; stdcall;
function WSAAsyncGetServByName(HWindow: HWND; wMsg: u_int;
  name, proto, buf: PAnsiChar; buflen: Integer): THandle; stdcall;
function WSAAsyncGetServByPort( HWindow: HWND; wMsg, port: u_int;
  proto, buf: PAnsiChar; buflen: Integer): THandle; stdcall;
function WSAAsyncGetProtoByName(HWindow: HWND; wMsg: u_int;
  name, buf: PAnsiChar; buflen: Integer): THandle; stdcall;
function WSAAsyncGetProtoByNumber(HWindow: HWND; wMsg: u_int; number: Integer;
  buf: PAnsiChar; buflen: Integer): THandle; stdcall;
function WSAAsyncGetHostByName(HWindow: HWND; wMsg: u_int;
  name, buf: PAnsiChar; buflen: Integer): THandle; stdcall;
function WSAAsyncGetHostByAddr(HWindow: HWND; wMsg: u_int; addr: PAnsiChar;
  len, Struct: Integer; buf: PAnsiChar; buflen: Integer): THandle; stdcall;
function WSACancelAsyncRequest(hAsyncTaskHandle: THandle): Integer; stdcall;
function WSAAsyncSelect(s: TSocket; HWindow: HWND; wMsg: u_int; lEvent: Longint): Integer; stdcall;
function WSARecvEx(s: TSocket; var buf; len: Integer; var flags: Integer): Integer; stdcall;
function __WSAFDIsSet(s: TSocket; var FDSet: TFDSet): Bool; stdcall;

function TransmitFile(hSocket: TSocket; hFile: THandle; nNumberOfBytesToWrite: DWORD;
  nNumberOfBytesPerSend: DWORD; lpOverlapped: POverlapped;
  lpTransmitBuffers: PTransmitFileBuffers; dwReserved: DWORD): BOOL; stdcall;

function AcceptEx(sListenSocket, sAcceptSocket: TSocket;
  lpOutputBuffer: Pointer; dwReceiveDataLength, dwLocalAddressLength,
  dwRemoteAddressLength: DWORD; var lpdwBytesReceived: DWORD;
  lpOverlapped: POverlapped): BOOL; stdcall;

procedure GetAcceptExSockaddrs(lpOutputBuffer: Pointer;
  dwReceiveDataLength, dwLocalAddressLength, dwRemoteAddressLength: DWORD;
  var LocalSockaddr: PSockAddr; var LocalSockaddrLength: Integer;
  var RemoteSockaddr: PSockAddr; var RemoteSockaddrLength: Integer); stdcall;

function WSAMakeSyncReply(Buflen, Error: Word): Longint; inline;
function WSAMakeSelectReply(Event, Error: Word): Longint; inline;
function WSAGetAsyncBuflen(Param: Longint): Word; inline;
function WSAGetAsyncError(Param: Longint): Word; inline;
function WSAGetSelectEvent(Param: Longint): Word; inline;
function WSAGetSelectError(Param: Longint): Word; inline;

procedure FD_CLR(Socket: TSocket; var FDSet: TFDSet);
function FD_ISSET(Socket: TSocket; var FDSet: TFDSet): Boolean;
procedure FD_SET(Socket: TSocket; var FDSet: TFDSet); // renamed due to conflict with fd_set (above)
procedure FD_ZERO(var FDSet: TFDSet);

const
  WSA_IO_PENDING = 997;

type
  TWSAEvent = THandle;

  PWSABuf = ^TWSABuf;
  TWSABuf = packed record
    Len: Cardinal;
    Buf: PChar;
  end;

  PWSAOverlapped = ^TWSAOverlapped;
  TWSAOverlapped = packed record
    Internal: DWORD;
    InternalHigh: DWORD;
    Offet: DWORD;
    OffsetHigh: DWORD;
    hEvent: TWSAEvent;
  end;

  TWSAOverlappedCompletionRoutine = procedure(
    dwError: DWORD;
    cdTransferred: DWORD;
    lpOverlapped: PWSAOverlapped;
    dwFlags: DWORD); stdcall;


function WSARecv(S: TSocket; lpBuffers: PWSABuf; dwBufferCount: DWORD;
  var NumberOfBytesRecvd: DWORD; var Flags: DWORD; lpOverlapped: PWSAOverlapped;
  lpCompletionRoutine: TWSAOverlappedCompletionRoutine): Integer; stdcall;

function WSASend(S: TSocket; lpBuffers: PWSABuf; dwBufferCount: DWORD;
  var NumberOfBytesRecvd: DWORD; Flags: DWORD; lpOverlapped: PWSAOverlapped;
  lpCompletionRoutine: TWSAOverlappedCompletionRoutine): Integer; stdcall;

function WSASendTo(s: TSocket; lpBuffers: PWSABuf; dwBufferCount: DWORD;
  var lpNumberOfBytesSent: DWORD; dwFlags: DWORD; lpTo: PSockAddr;
  iToLen: Integer; lpOverlapped: PWSAOverlapped;
  lpCompletionRoutine: TWSAOverlappedCompletionRoutine): Integer; stdcall;

function WSARecvFrom(s: TSocket; lpBuffers: PWSABuf; dwBufferCount: DWORD;
  var lpNumberOfBytesRecvd: DWORD; var lpFlags: DWORD; lpFrom: PSockAddr;
  var lpFromlen: Integer; lpOverlapped: PWSAOverlapped;
  lpCompletionRoutine: TWSAOverlappedCompletionRoutine
): Integer; stdcall;

function WSASendDisconnect(s: TSocket; lpOutboundDisconnectData: PWSABuf): Integer; stdcall;

{ Define flags to be used with the WSAAsyncSelect() and WSAEnumNetworkEvents() calls }

const
  FD_MAX_EVENTS                   = 10;
  FD_ALL_EVENTS                   = (1 shl FD_MAX_EVENTS) - 1;
  FD_READ_BIT                     = 0;
  FD_READ                         = 1 shl FD_READ_BIT;
  FD_WRITE_BIT                    = 1;
  FD_WRITE                        = 1 shl FD_WRITE_BIT;
  FD_OOB_BIT                      = 2;
  FD_OOB                          = 1 shl FD_OOB_BIT;
  FD_ACCEPT_BIT                   = 3;
  FD_ACCEPT                       = 1 shl FD_ACCEPT_BIT;
  FD_CONNECT_BIT                  = 4;
  FD_CONNECT                      = 1 shl FD_CONNECT_BIT;
  FD_CLOSE_BIT                    = 5;
  FD_CLOSE                        = 1 shl FD_CLOSE_BIT;
  FD_QOS_BIT                      = 6;
  FD_QOS                          = 1 shl FD_QOS_BIT;
  FD_GROUP_QOS_BIT                = 7;
  FD_GROUP_QOS                    = 1 shl FD_GROUP_QOS_BIT;
  FD_ROUTING_INTERFACE_CHANGE_BIT = 8;
  FD_ROUTING_INTERFACE_CHANGE     = 1 shl FD_ROUTING_INTERFACE_CHANGE_BIT;
  FD_ADDRESS_LIST_CHANGE_BIT      = 9;
  FD_ADDRESS_LIST_CHANGE          = 1 shl FD_ADDRESS_LIST_CHANGE_BIT;

type
  _WSANETWORKEVENTS = record
    lNetworkEvents: LongInt;
    iErrorCode: array [0..FD_MAX_EVENTS] of DWORD;
  end;
  WSANETWORKEVENTS = _WSANETWORKEVENTS;
  TWSANetworkEvents = WSANETWORKEVENTS;
  PWSANetworkEvents = ^TWSANetworkEvents;

function WSAEnumNetworkEvents(s: TSocket; hEventObject: TWSAEvent;
  var lpNetworkEvents: TWSANetworkEvents): Integer; stdcall;

const
  WSAPROTOCOL_LEN = 255;
  MAX_PROTOCOL_CHAIN = 7;

  WSA_FLAG_OVERLAPPED = $01;

type
  _WSAPROTOCOLCHAIN = record
    ChainLen: Integer;
    ChainEntries: array [0..MAX_PROTOCOL_CHAIN - 1] of DWORD;
  end;
  WSAPROTOCOLCHAIN = _WSAPROTOCOLCHAIN;
  PWSAPROTOCOLCHAIN = ^WSAPROTOCOLCHAIN;

  _WSAPROTOCOL_INFOA = record
    dwServiceFlags1: DWORD;
    dwServiceFlags2: DWORD;
    dwServiceFlags3: DWORD;
    dwServiceFlags4: DWORD;
    dwProviderFlags: DWORD;
    ProviderId: TGUID;
    dwCatalogEntryId: DWORD;
    ProtocolChain: WSAPROTOCOLCHAIN;
    iVersion: Integer;
    iAddressFamily: Integer;
    iMaxSockAddr: Integer;
    iMinSockAddr: Integer;
    iSocketType: Integer;
    iProtocol: Integer;
    iProtocolMaxOffset: Integer;
    iNetworkByteOrder: Integer;
    iSecurityScheme: Integer;
    dwMessageSize: DWORD;
    dwProviderReserved: DWORD;
    szProtocol: array [0..WSAPROTOCOL_LEN] of AnsiChar;
  end;
  WSAPROTOCOL_INFOA = _WSAPROTOCOL_INFOA;
  PWSAPROTOCOL_INFOA = ^WSAPROTOCOL_INFOA;

  _WSAPROTOCOL_INFOW = record
    dwServiceFlags1: DWORD;
    dwServiceFlags2: DWORD;
    dwServiceFlags3: DWORD;
    dwServiceFlags4: DWORD;
    dwProviderFlags: DWORD;
    ProviderId: TGUID;
    dwCatalogEntryId: DWORD;
    ProtocolChain: WSAPROTOCOLCHAIN;
    iVersion: Integer;
    iAddressFamily: Integer;
    iMaxSockAddr: Integer;
    iMinSockAddr: Integer;
    iSocketType: Integer;
    iProtocol: Integer;
    iProtocolMaxOffset: Integer;
    iNetworkByteOrder: Integer;
    iSecurityScheme: Integer;
    dwMessageSize: DWORD;
    dwProviderReserved: DWORD;
    szProtocol: array [0..WSAPROTOCOL_LEN] of WideChar;
  end;
  WSAPROTOCOL_INFOW = _WSAPROTOCOL_INFOW;
  PWSAPROTOCOL_INFOW = ^WSAPROTOCOL_INFOW;

  _WSAPROTOCOL_INFO = record
    dwServiceFlags1: DWORD;
    dwServiceFlags2: DWORD;
    dwServiceFlags3: DWORD;
    dwServiceFlags4: DWORD;
    dwProviderFlags: DWORD;
    ProviderId: TGUID;
    dwCatalogEntryId: DWORD;
    ProtocolChain: WSAPROTOCOLCHAIN;
    iVersion: Integer;
    iAddressFamily: Integer;
    iMaxSockAddr: Integer;
    iMinSockAddr: Integer;
    iSocketType: Integer;
    iProtocol: Integer;
    iProtocolMaxOffset: Integer;
    iNetworkByteOrder: Integer;
    iSecurityScheme: Integer;
    dwMessageSize: DWORD;
    dwProviderReserved: DWORD;
    szProtocol: array [0..WSAPROTOCOL_LEN] of Char;
  end;
  WSAPROTOCOL_INFO = _WSAPROTOCOL_INFO;
  PWSAPROTOCOL_INFO = ^WSAPROTOCOL_INFO;

function WSASocketA(af, type_, protocol: Integer; lpProtocolInfo: PWSAPROTOCOL_INFOA;
  g: DWORD; dwFlags: DWORD): TSocket; stdcall;

function WSASocketW(af, type_, protocol: Integer; lpProtocolInfo: PWSAPROTOCOL_INFOW;
  g: DWORD; dwFlags: DWORD): TSocket; stdcall;

function WSASocket(af, type_, protocol: Integer; lpProtocolInfo: PWSAPROTOCOL_INFO;
  g: DWORD; dwFlags: DWORD): TSocket; stdcall;

function WSAListen(s: TSocket; backlog: Integer): Integer; stdcall;

type
  FLOWSPEC = record
    TokenRate: ULONG;
    TokenBucketSize: ULONG;
    PeakBandwidth: ULONG;
    Latency: ULONG;
    DelayVariation: ULONG;
    ServiceType: ULONG;
    MaxSduSize: ULONG;
    MinimumPolicedSize: ULONG;
  end;
  PFLOWSPEC = ^FLOWSPEC;

const
  CF_ACCEPT = $0000;
  CF_REJECT = $0001;
  CF_DEFER  = $0002;

const
  SIO_GET_EXTENSION_FUNCTION_POINTER = IOC_INOUT or $08000000 or 6;
  WSAID_DISCONNECTEX: TGUID = (D1: $7fda2e11; D2: $8630; D3: $436f;
    D4: ($a0, $31, $f5, $36, $a6, $ee, $c1, $57));

type
  TWSAAcceptConditionProc = function(lpCallerId, lpCallerData: PWSABuf;
    lpSQOS, lpGQOS: PFLOWSPEC; lpCalleeId, lpCalleeData: PWSABuf;
    g: DWORD; dwCallbackData: DWORD_PTR): Integer; stdcall;

function WSAAccept(s: TSocket; addr: PSOCKADDR; addrlen: PInteger;
  lpfnCondition: TWSAAcceptConditionProc; dwCallbackData: DWORD_PTR): TSocket;

function DisconnectEx(hSocket: TSocket; lpOverlapped: POverlapped;
  dwFlags: DWORD; reserved: DWORD): BOOL; stdcall;

function WSAIoctl(s: TSocket; dwIoControlCode: DWORD; lpvInBuffer: Pointer;
  cbInBuffer: DWORD; lpvOutBuffer: Pointer; cbOutBuffer: DWORD;
  lpcbBytesReturned: PDWORD; lpOverlapped: PWSAOverlapped;
  lpCompletionRoutine: TWSAOverlappedCompletionRoutine): Integer; stdcall;

implementation

const
  winsocket = 'wsock32.dll';
  ws2_32 = 'ws2_32.dll';

function WSAMakeSyncReply(Buflen, Error: Word): Longint;
begin
  Result := MakeLong(Buflen, Error);
end;

function WSAMakeSelectReply(Event, Error: Word): Longint;
begin
  Result := MakeLong(Event, Error);
end;

function WSAGetAsyncBuflen(Param: Longint): Word;
begin
  Result := LOWORD(Param);
end;

function WSAGetAsyncError(Param: Longint): Word;
begin
  Result := HIWORD(Param);
end;

function WSAGetSelectEvent(Param: Longint): Word;
begin
  Result := LOWORD(Param);
end;

function WSAGetSelectError(Param: Longint): Word;
begin
  Result := HIWORD(Param);
end;

procedure FD_CLR(Socket: TSocket; var FDSet: TFDSet);
var
  I: Integer;
begin
  I := 0;
  while I < FDSet.fd_count do
  begin
    if FDSet.fd_array[I] = Socket then
    begin
      while I < FDSet.fd_count - 1 do
      begin
        FDSet.fd_array[I] := FDSet.fd_array[I + 1];
        Inc(I);
      end;
      Dec(FDSet.fd_count);
      Break;
    end;
    Inc(I);
  end;
end;

function FD_ISSET(Socket: TSocket; var FDSet: TFDSet): Boolean;
begin
  Result := __WSAFDIsSet(Socket, FDSet);
end;

procedure FD_SET(Socket: TSocket; var FDSet: TFDSet);
begin
  if FDSet.fd_count < FD_SETSIZE then
  begin
    FDSet.fd_array[FDSet.fd_count] := Socket;
    Inc(FDSet.fd_count);
  end;
end;

procedure FD_ZERO(var FDSet: TFDSet);
begin
  FDSet.fd_count := 0;
end;

function accept;            external winsocket name 'accept';
function bind;              external winsocket name 'bind';
function closesocket;       external winsocket name 'closesocket';
function connect;           external winsocket name 'connect';
function getpeername;       external winsocket name 'getpeername';
function getsockname;       external winsocket name 'getsockname';
function getsockopt;        external winsocket name 'getsockopt';
function htonl;             external winsocket name 'htonl';
function htons;             external winsocket name 'htons';
function inet_addr;         external winsocket name 'inet_addr';
function inet_ntoa;         external winsocket name 'inet_ntoa';
function ioctlsocket;       external winsocket name 'ioctlsocket';
function listen;            external winsocket name 'listen';
function ntohl;             external winsocket name 'ntohl';
function ntohs;             external winsocket name 'ntohs';
function recv;              external winsocket name 'recv';
function recvfrom;          external winsocket name 'recvfrom';
function select;            external winsocket name 'select';
function send;              external winsocket name 'send';
function sendto;            external winsocket name 'sendto';
function setsockopt;        external winsocket name 'setsockopt';
function shutdown;          external winsocket name 'shutdown';
function socket;            external winsocket name 'socket';
function gethostbyaddr;     external winsocket name 'gethostbyaddr';
function gethostbyname;     external winsocket name 'gethostbyname';
function getprotobyname;    external winsocket name 'getprotobyname';
function getprotobynumber;  external winsocket name 'getprotobynumber';
function getservbyname;     external winsocket name 'getservbyname';
function getservbyport;     external winsocket name 'getservbyport';
function gethostname;       external winsocket name 'gethostname';
function WSAAsyncSelect;    external winsocket name 'WSAAsyncSelect';
function WSARecvEx;         external winsocket name 'WSARecvEx';
function WSAAsyncGetHostByAddr;    external winsocket name 'WSAAsyncGetHostByAddr';
function WSAAsyncGetHostByName;    external winsocket name 'WSAAsyncGetHostByName';
function WSAAsyncGetProtoByNumber; external winsocket name 'WSAAsyncGetProtoByNumber';
function WSAAsyncGetProtoByName;   external winsocket name 'WSAAsyncGetProtoByName';
function WSAAsyncGetServByPort;    external winsocket name 'WSAAsyncGetServByPort';
function WSAAsyncGetServByName;    external winsocket name 'WSAAsyncGetServByName';
function WSACancelAsyncRequest;    external winsocket name 'WSACancelAsyncRequest';
function WSASetBlockingHook;       external winsocket name 'WSASetBlockingHook';
function WSAUnhookBlockingHook;    external winsocket name 'WSAUnhookBlockingHook';
function WSAGetLastError;          external winsocket name 'WSAGetLastError';
procedure WSASetLastError;         external winsocket name 'WSASetLastError';
function WSACancelBlockingCall;    external winsocket name 'WSACancelBlockingCall';
function WSAIsBlocking;            external winsocket name 'WSAIsBlocking';
function WSAStartup;               external winsocket name 'WSAStartup';
function WSACleanup;               external winsocket name 'WSACleanup';
function __WSAFDIsSet;             external winsocket name '__WSAFDIsSet';
function TransmitFile;             external winsocket name 'TransmitFile';
function AcceptEx;                 external winsocket name 'AcceptEx';
procedure GetAcceptExSockaddrs;    external winsocket name 'GetAcceptExSockaddrs';

function WSASocketA; external ws2_32 name 'WSASocketA';
function WSASocketW; external ws2_32 name 'WSASocketW';
function WSASocket; external ws2_32 name {$IFDEF UNICODE}'WSASocketW'{$ELSE}'WSASocketA'{$ENDIF};
function WSARecv; external ws2_32;
function WSASend; external ws2_32;
function WSASendDisconnect; external ws2_32;
function WSAEnumNetworkEvents; external ws2_32;
function WSASendTo; external ws2_32;
function WSARecvFrom; external ws2_32;
function WSAListen; external winsocket name 'listen';
function WSAAccept; external ws2_32;
function WSAIoctl; external ws2_32;

function DisconnectEx(hSocket: TSocket; lpOverlapped: POverlapped;
  dwFlags: DWORD; reserved: DWORD): BOOL;
type
  TDisconnectEx = function(hSocket: TSocket; lpOverlapped: POverlapped;
    dwFlags: DWORD; reserved: DWORD): BOOL; stdcall;
var
  g: TGUID;
  dex: TDisconnectEx;
  cbRes: DWORD;
begin
  cbRes := 0; dex := nil; g := WSAID_DISCONNECTEX;
  Result := WSAIoctl(hSocket, SIO_GET_EXTENSION_FUNCTION_POINTER, @g, SizeOf(TGUID),
    @dex, SizeOf(TDisconnectEx), @cbRes, nil, nil) = 0;
  if not Result then Exit;
  if cbRes <> SizeOf(TDisconnectEx) then Exit(false);
  if not Assigned(dex) then Exit(false);
  Result := dex(hSocket, lpOverlapped, dwFlags, 0);
end;

end.
