// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //
// Удалены Object instance handling //
// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! //

{* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

Author:       Russell Libby, updated by Franзois PIETTE @ OverByte
Creation:     Mar 30, 2003
Last update:  Oct 04, 2013
Description:  Pipe components by Russell Libby
              See blog article at http://francois-piette.blogspot.be
Version:      1.01
History:      See below in the original comments


 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *}
unit Pipes;

////////////////////////////////////////////////////////////////////////////////
//
// Unit : Pipes
// Author : rllibby  (Russell Libby)
// Date : 01.30.2003 - Original code
//
// 01.19.2006 - Code overhauled to allow for usage in dll's
// when compiled with Delphi 6 and up.
//
// 04.03.2008 - Second overhaul after finding that memory leaks
// in the server thread handling when run under
// load. Also found cases where messages were missed
// using PeekMessage due to the queue being full. It
// seems that the message queue has a 10000 message
// limit.
//
// 04.04.2008 - (1) Better memory handling for messages.
// (2) Smart reallocation for overlapped reads
// (3) Message chunking is handled, which alleviates
// the developer from manually splitting data writes
// over the network when the data is > 65K.
// (4) Temp file backed streams for multi packet
// messages.
// (5) Added the ability to throttle down client
// based on memory consumption in the write queue.
//
// 05.30.2008 - Updated the client / server components to allow
// the Active (server) and Disconnect (client) calls
// to be made while processing an event from the
// component.
//
// 06.05.2008 - Wrapped up the TPipeConsole component, which
// handles redirection from console processes.
// Also provides a means of synchronous execution
// by way of the Execute(...) function.
//
// 10.20.2008 - Added remote code threading for obtaining the
// console handle directly. If this fails, the
// code will revert to enumerating the windows
// of the console process. Also added priority
// setting for the process.
//
// 12.01.2010 - Fix to "constructor TPipeListenThread.Create()"
// where "FPipeServer.FThreadCount.Increment" was being
// called before the property was set from the incoming
// parameters
//
// 04.03.2013 - francois.piette@overbyte.be updated the code for Delphi XE3
// Started from sources downloaded from Mick Grove blog
// http://micksmix.wordpress.com/2011/06/27/named-pipes-unit-for-delphi/
// I made a runttime package and a designtime package. For that purpose,
// I moved the register procedure to a separate source "PipesReg.pas".
// I made simple icons for the components.
// The components are registered in the "Pipes" tab in the IDE.
//
// 04.10.2013 - arno.garrels@gmx.de added 64-bit support and fixed code to
// compile with Delphi 7 to XE5 (earlier versions may compile however untested).
// Made event parameter HPIPE a type THandle otherwise there type mismatches
// in event handler signatures.
//
// Description : Set of client and server named pipe components for Delphi, as
// well a console pipe redirection component.
//
// Notes:
//
// TPipeClient
//
// - The worker thread coordinates events with the component by way of
//   SendMessage. This means the thread that the component lives on has
//   to have a message loop. Also, it means that the developer needs
//   to watch what is done in the TPipeClient events. Do not expect the
//   following calls to work from within the events:
//
// - FlushPipeBuffers
// - WaitForReply
// - Write (works, but no memory throttling)
//
// The reason these calls do not work is that they are expecting
// interaction from the worker thead, which is currently stalled while
// waiting on the event handler to finish (and the SendMessage call to
// complete). I have coded these routines so that they will NOT deadlock,
// but again, don't expect them to ever return success if called from
// within one of TPipeClient events. The one exception to this is the
// call to Disconnect, which can be called from within an event. If
// called from within an event, the component will PostMessage to itself
// and will perform the true disconnect when the message is handled.
//
// TPipeServer
//
// - The worker threads coordinate events with the component by way of
//   SendMessage. This means the thread that the component lives on has
//   to have a message loop. No special restrictions for what is done in
//   the event handlers.
//
// TPipeConsole
//
// - The worker thread coordinates events with the component by way of
//   SendMessage. This means the thread that the component lives on has
//   to have a message loop. No special restrictions for what is done in
//   the event handlers.
//
////////////////////////////////////////////////////////////////////////////////
interface

{$DEFINE DELPHI_6_ABOVE}
{$IFDEF CONDITIONALEXPRESSIONS}
  {$IF COMPILERVERSION > 22}
    {$DEFINE DELPHI_XE2_ABOVE} // has 64-bit compiler
  {$ENDIF}
{$ENDIF}
{$IFNDEF DELPHI_XE2_ABOVE}
  {$DEFINE CPUX86}
{$ENDIF}

{$WARN SYMBOL_PLATFORM OFF}        // TThreadPriority is specific to Windows

////////////////////////////////////////////////////////////////////////////////
// Include units
////////////////////////////////////////////////////////////////////////////////
uses
    Windows,
    Types,
    SysUtils,
    Classes,
    Messages;

////////////////////////////////////////////////////////////////////////////////
// Resource strings
////////////////////////////////////////////////////////////////////////////////
resourcestring
    resThreadCtx =
        'The notify window and the component window do not exist in the same thread!';
    resPipeActive = 'Cannot change property while server is active!';
    resPipeConnected = 'Cannot change property when client is connected!';
    resBadPipeName = 'Invalid pipe name specified!';
    resPipeBaseName = '\\.\pipe\';
    resPipeBaseFmtName = '\\%s\pipe\';
    resPipeName = 'PipeServer';
    resConClass = 'ConsoleWindowClass';
    resComSpec = 'ComSpec';

    ////////////////////////////////////////////////////////////////////////////////
    // Min, max and default constants
    ////////////////////////////////////////////////////////////////////////////////
const
    MAX_NAME        = 256;
    MAX_WAIT        = 1000;
    MAX_BUFFER      = Pred(MaxWord);
    DEF_SLEEP       = 100;
    DEF_MEMTHROTTLE = 10240000;

////////////////////////////////////////////////////////////////////////////////
// Pipe mode constants
////////////////////////////////////////////////////////////////////////////////
const
    PIPE_MODE      = PIPE_TYPE_MESSAGE or PIPE_READMODE_MESSAGE or PIPE_WAIT;
    PIPE_OPENMODE  = PIPE_ACCESS_DUPLEX or FILE_FLAG_OVERLAPPED;
    PIPE_INSTANCES = PIPE_UNLIMITED_INSTANCES;

////////////////////////////////////////////////////////////////////////////////
// Pipe handle constants
////////////////////////////////////////////////////////////////////////////////
const
    STD_PIPE_INPUT  = 0;
    STD_PIPE_OUTPUT = 1;
    STD_PIPE_ERROR  = 2;

////////////////////////////////////////////////////////////////////////////////
// Mutliblock message constants
////////////////////////////////////////////////////////////////////////////////
const
    MB_MAGIC  = $4347414D; // MAGC
    MB_START  = $424D5453; // STMB
    MB_END    = $424D5445; // ETMB
    MB_PREFIX = 'PMM';


////////////////////////////////////////////////////////////////////////////////
// Pipe window message constants
////////////////////////////////////////////////////////////////////////////////
const
    WM_PIPEERROR_L  = WM_USER + 100;
    WM_PIPEERROR_W  = WM_USER + 101;
    WM_PIPECONNECT  = WM_USER + 102;
    WM_PIPESEND     = WM_USER + 103;
    WM_PIPEMESSAGE  = WM_USER + 104;
    WM_PIPE_CON_OUT = WM_USER + 105;
    WM_PIPE_CON_ERR = WM_USER + 106;
    WM_PIPEMINMSG   = WM_PIPEERROR_L;
    WM_PIPEMAXMSG   = WM_PIPE_CON_ERR;

////////////////////////////////////////////////////////////////////////////////
// Posted (deferred) window messages
////////////////////////////////////////////////////////////////////////////////
const
    WM_THREADCTX  = WM_USER + 200;
    WM_DOSHUTDOWN = WM_USER + 300;

////////////////////////////////////////////////////////////////////////////////
// Thread window message constants
////////////////////////////////////////////////////////////////////////////////
const
    CM_EXECPROC      = $8FFD;
    CM_DESTROYWINDOW = $8FFC;

////////////////////////////////////////////////////////////////////////////////
// Pipe exception type
////////////////////////////////////////////////////////////////////////////////
type
    EPipeException = class(Exception);

////////////////////////////////////////////////////////////////////////////////
// Pipe data type
////////////////////////////////////////////////////////////////////////////////
type
    HPIPE = type THandle;

////////////////////////////////////////////////////////////////////////////////
// Record and class types
////////////////////////////////////////////////////////////////////////////////
type
    // Forward declarations
    TPipeServer = class;
    TPipeClient = class;
    TWriteQueue = class;

    // Std handles for console redirection
    TPipeStdHandles = array [STD_PIPE_INPUT .. STD_PIPE_ERROR] of THandle;

    // Process window info
    PPipeConsoleInfo = ^TPipeConsoleInfo;

    TPipeConsoleInfo = packed record
        ProcessID : DWORD;
        ThreadID : DWORD;
        Window : HWND;
    end;

    // Data write record
    PPipeWrite = ^TPipeWrite;

    TPipeWrite = packed record
        Buffer : PChar;
        Count : Integer;
    end;

    // Data write message block
    PPipeMsgBlock = ^TPipeMsgBlock;

    TPipeMsgBlock = packed record
        Size : DWORD;
        MagicStart : DWORD;
        ControlCode : DWORD;
        MagicEnd : DWORD;
    end;

    // Data writer list record
    PWriteNode = ^TWriteNode;

    TWriteNode = packed record
        PipeWrite : PPipeWrite;
        NextNode : PWriteNode;
    end;

    // Server pipe info record
    PPipeInfo = ^TPipeInfo;

    TPipeInfo = packed record
        Pipe : HPIPE;
        KillEvent : THandle;
        WriteQueue : TWriteQueue;
    end;

    // Thread sync info
    TSyncInfo = class
        FSyncBaseTID : THandle;
        FThreadWindow : HWND;
        FThreadCount : Integer;
    end;

    // Exception frame
    PRaiseFrame = ^TRaiseFrame;

    TRaiseFrame = record
        NextRaise : PRaiseFrame;
        ExceptAddr : Pointer;
        ExceptObject : TObject;
        ExceptionRecord : PExceptionRecord;
    end;

    // Pipe context for error messages
    TPipeContext = (pcListener, pcWorker);

    // Pipe Events
    TOnConsole     = procedure(Sender : TObject; Stream : TStream) of object;
    TOnConsoleStop = procedure(Sender : TObject; ExitValue : LongWord)
        of object;
    TOnPipeConnect    = procedure(Sender : TObject; Pipe : HPIPE) of object;
    TOnPipeDisconnect = procedure(Sender : TObject; Pipe : HPIPE) of object;
    TOnPipeMessage = procedure(Sender : TObject; Pipe : HPIPE; Stream : TStream)
        of object;
    TOnPipeSent = procedure(Sender : TObject; Pipe : HPIPE; Size : DWORD)
        of object;
    TOnPipeError = procedure(Sender : TObject; Pipe : HPIPE;
        PipeContext : TPipeContext; ErrorCode : Integer) of object;

    // TWriteQueue class
    TWriteQueue = class(TObject)
    private
        // Private declarations
        FMutex    : THandle;
        FDataEv   : THandle;
        FEmptyEv  : THandle;
        FDataSize : LongWord;
        FHead     : PWriteNode;
        FTail     : PWriteNode;
        procedure UpdateState;
        function NodeSize(Node : PWriteNode) : LongWord;
    protected
        // Protected declarations
        procedure Clear;
        procedure EnqueueControlPacket(ControlCode : DWORD);
        procedure EnqueueMultiPacket(PipeWrite : PPipeWrite);
        function GetEmpty : Boolean;
        function NewNode(PipeWrite : PPipeWrite) : PWriteNode;
    public
        // Public declarations
        constructor Create;
        destructor Destroy; override;
        procedure Enqueue(PipeWrite : PPipeWrite);
        procedure EnqueueEndPacket;
        procedure EnqueueStartPacket;
        function Dequeue : PPipeWrite;
        property DataEvent : THandle read FDataEv;
        property DataSize : LongWord read FDataSize;
        property Empty : Boolean read GetEmpty;
        property EmptyEvent : THandle read FEmptyEv;
    end;

    // TThreadSync class
    TThreadSync = class
    private
        // Private declarations
        FSyncRaise   : TObject;
        FMethod      : TThreadMethod;
        FSyncBaseTID : THandle;
    public
        // Public declarations
        constructor Create;
        destructor Destroy; override;
        procedure Synchronize(Method : TThreadMethod);
        property SyncBaseTID : THandle read FSyncBaseTID;
    end;

    // TThreadEx class
    TThreadEx = class(TThread)
    private
        // Private declarations
        FSync : TThreadSync;
        procedure HandleTerminate;
    protected
        // Protected declarations
        procedure SafeSynchronize(Method : TThreadMethod);
        procedure Synchronize(Method : TThreadMethod);
        procedure DoTerminate; override;
    public
        // Public declarations
        constructor Create(CreateSuspended : Boolean);
        destructor Destroy; override;
        procedure Run;
        procedure Wait;
        property Sync : TThreadSync read FSync;
    end;

    // TSyncManager class
    TSyncManager = class(TObject)
    private
        // Private declarations
        FThreadLock : TRTLCriticalSection;
        FList       : TList;
    protected
        // Protected declarations
        procedure DoDestroyWindow(Info : TSyncInfo);
        procedure FreeSyncInfo(Info : TSyncInfo);
        function AllocateWindow : HWND;
        function FindSyncInfo(SyncBaseTID : LongWord) : TSyncInfo;
    public
        // Public declarations
        class function Instance : TSyncManager;
        constructor Create;
        destructor Destroy; override;
        procedure AddThread(ThreadSync : TThreadSync);
        procedure RemoveThread(ThreadSync : TThreadSync);
        procedure Synchronize(ThreadSync : TThreadSync);
    end;

    // TThreadCounter class
    TThreadCounter = class(TObject)
    private
        // Private declarations
        FLock  : TRTLCriticalSection;
        FEmpty : THandle;
        FCount : Integer;
    protected
        // Protected declarations
        function GetCount : Integer;
    public
        // Public declarations
        constructor Create;
        destructor Destroy; override;
        procedure Increment;
        procedure Decrement;
        procedure WaitForEmpty;
        property Count : Integer read GetCount;
    end;

    // TFastMemStream class
    TFastMemStream = class(TMemoryStream)
    protected
        // Protected declarations
        function Realloc(var NewCapacity : NativeInt) : Pointer; override;
    end;

    // Multipacket message handler
    TPipeMultiMsg = class(TObject)
    private
        // Private declarations
        FHandle : THandle;
        FStream : TStream;
    protected
        // Protected declarations
        procedure CreateTempBacking;
    public
        // Public declarations
        constructor Create;
        destructor Destroy; override;
        property Stream : TStream read FStream;
    end;

    // TPipeListenThread class
    TPipeListenThread = class(TThreadEx)
    private
        // Private declarations
        FNotify       : HWND;
        FNotifyThread : THandle;
        FErrorCode    : Integer;
        FPipe         : HPIPE;
        FPipeName     : string;
        FConnected    : Boolean;
        FEvents       : array [0 .. 1] of THandle;
        FOlapConnect  : TOverlapped;
        FPipeServer   : TPipeServer;
        FSA           : TSecurityAttributes;
    protected
        // Protected declarations
        function CreateServerPipe : Boolean;
        procedure DoWorker;
        procedure Execute; override;
        function SafeSendMessage(AMsg : UINT; AWParam: WPARAM; ALParam: LPARAM): LRESULT;
    public
        // Public declarations
        constructor Create(PipeServer : TPipeServer; KillEvent : THandle);
        destructor Destroy; override;
    end;

    // TPipeThread class
    TPipeThread = class(TThreadEx)
    private
        // Private declarations
        FServer       : Boolean;
        FNotify       : HWND;
        FNotifyThread : THandle;
        FPipe         : HPIPE;
        FErrorCode    : Integer;
        FCounter      : TThreadCounter;
        FWrite        : DWORD;
        FWriteQueue   : TWriteQueue;
        FPipeWrite    : PPipeWrite;
        FRcvRead      : DWORD;
        FPendingRead  : Boolean;
        FPendingWrite : Boolean;
        FMultiMsg     : TPipeMultiMsg;
        FRcvStream    : TFastMemStream;
        FRcvBuffer    : PChar;
        FRcvAlloc     : DWORD;
        FRcvSize      : DWORD;
        FEvents       : array [0 .. 3] of THandle;
        FOlapRead     : TOverlapped;
        FOlapWrite    : TOverlapped;
    protected
        // Protected declarations
        function QueuedRead : Boolean;
        function CompleteRead : Boolean;
        function QueuedWrite : Boolean;
        function CompleteWrite : Boolean;
        procedure DoMessage;
        procedure Execute; override;
        function SafeSendMessage(AMsg : UINT; AWParam : WPARAM; ALParam : LPARAM): LRESULT;
    public
        // Public declarations
        constructor Create(Server : Boolean; NotifyWindow : HWND;
            NotifyThread : THandle; WriteQueue : TWriteQueue;
            Counter : TThreadCounter; Pipe : HPIPE; KillEvent : THandle);
        destructor Destroy; override;
        property Pipe : HPIPE read FPipe;
    end;

    // TPipeServer component class
    TPipeServer = class(TComponent)
    private
        // Private declarations
        FBaseThread  : THandle;
        FHwnd        : HWND;
        FPipeName    : string;
        FDeferActive : Boolean;
        FActive      : Boolean;
        FInShutDown  : Boolean;
        FKillEv      : THandle;
        FClients     : TList;
        FThreadCount : TThreadCounter;
        FListener    : TPipeListenThread;
        FSA          : TSecurityAttributes;
        FOPS         : TOnPipeSent;
        FOPC         : TOnPipeConnect;
        FOPD         : TOnPipeDisconnect;
        FOPM         : TOnPipeMessage;
        FOPE         : TOnPipeError;
        procedure DoStartup;
        procedure DoShutdown;
    protected
        // Protected declarations
        function AllocPipeInfo(Pipe : HPIPE) : PPipeInfo;
        function GetClient(Index : Integer) : HPIPE;
        function GetClientCount : Integer;
        function GetClientInfo(Pipe : HPIPE; out PipeInfo : PPipeInfo)
            : Boolean;
        procedure WndMethod(var Message : TMessage);
        procedure RemoveClient(Pipe : HPIPE);
        procedure SetActive(Value : Boolean);
        procedure SetPipeName(Value : string);
        procedure AddWorkerThread(Pipe : HPIPE);
        procedure RemoveWorkerThread(Sender : TObject);
        procedure RemoveListenerThread(Sender : TObject);
        procedure Loaded; override;
    public
        // Public declarations
        constructor Create(AOwner : TComponent); override;
        constructor CreateUnowned;
        destructor Destroy; override;
        function Broadcast(var Buffer; Count : Integer) : Boolean; overload;
        function Broadcast(var Prefix; PrefixCount : Integer; var Buffer;
            Count : Integer) : Boolean; overload;
        function Disconnect(Pipe : HPIPE) : Boolean;
        function Write(Pipe : HPIPE; var Prefix; PrefixCount : Integer;
            var Buffer; Count : Integer) : Boolean; overload;
        function Write(Pipe : HPIPE; var Buffer; Count : Integer)
            : Boolean; overload;
        function SendStream(Pipe : HPIPE; Stream : TStream) : Boolean;
        property WindowHandle : HWND read FHwnd;
        property ClientCount : Integer read GetClientCount;
        property Clients[index : Integer] : HPIPE read GetClient;
    published
        // Published declarations
        property Active           : Boolean read FActive write SetActive;
        property OnPipeSent       : TOnPipeSent read FOPS write FOPS;
        property OnPipeConnect    : TOnPipeConnect read FOPC write FOPC;
        property OnPipeDisconnect : TOnPipeDisconnect read FOPD write FOPD;
        property OnPipeMessage    : TOnPipeMessage read FOPM write FOPM;
        property OnPipeError      : TOnPipeError read FOPE write FOPE;
        property PipeName         : string read FPipeName write SetPipeName;
    end;

    // TPipeClient component class
    TPipeClient = class(TComponent)
    private
        // Private declarations
        FBaseThread    : THandle;
        FHwnd          : HWND;
        FPipe          : HPIPE;
        FPipeName      : string;
        FServerName    : string;
        FDisconnecting : Boolean;
        FReply         : Boolean;
        FThrottle      : LongWord;
        FWriteQueue    : TWriteQueue;
        FWorker        : TPipeThread;
        FKillEv        : THandle;
        FSA            : TSecurityAttributes;
        FOPE           : TOnPipeError;
        FOPD           : TOnPipeDisconnect;
        FOPM           : TOnPipeMessage;
        FOPS           : TOnPipeSent;
    protected
        // Protected declarations
        function GetConnected : Boolean;
        procedure SetPipeName(Value : string);
        procedure SetServerName(Value : string);
        procedure RemoveWorkerThread(Sender : TObject);
        procedure WndMethod(var AMsg : TMessage);
    public
        // Public declarations
        constructor Create(AOwner : TComponent); override;
        constructor CreateUnowned;
        destructor Destroy; override;
        function Connect(WaitTime : DWORD = NMPWAIT_USE_DEFAULT_WAIT;
            Start : Boolean = TRUE) : Boolean;
        function WaitForReply(TimeOut : Cardinal = INFINITE) : Boolean;
        procedure Disconnect;
        procedure FlushPipeBuffers;
        function SendStream(Stream : TStream) : Boolean;
        function Write(var Prefix; PrefixCount : Integer; var Buffer;
            Count : Integer) : Boolean; overload;
        function Write(var Buffer; Count : Integer) : Boolean; overload;
        property Connected : Boolean read GetConnected;
        property WindowHandle : HWND read FHwnd;
        property Pipe : HPIPE read FPipe;
    published
        // Published declarations
        property MemoryThrottle : LongWord read FThrottle write FThrottle;
        property PipeName       : string read FPipeName write SetPipeName;
        property ServerName     : string read FServerName write SetServerName;
        property OnPipeDisconnect : TOnPipeDisconnect read FOPD write FOPD;
        property OnPipeMessage : TOnPipeMessage read FOPM write FOPM;
        property OnPipeSent    : TOnPipeSent read FOPS write FOPS;
        property OnPipeError   : TOnPipeError read FOPE write FOPE;
    end;

    // TPipeConsoleThread class
    TPipeConsoleThread = class(TThreadEx)
    private
        // Private declarations
        FNotify  : HWND;
        FStream  : TFastMemStream;
        FProcess : THandle;
        FOutput  : THandle;
        FError   : THandle;
        procedure ProcessPipe(Handle : THandle; AMsg : UINT);
    protected
        // Protected declarations
        procedure Execute; override;
        procedure ProcessPipes;
        function SafeSendMessage(AMsg : UINT; AWParam: WParam; ALParam : LPARAM)
            : LRESULT;
    public
        // Public declarations
        constructor Create(NotifyWindow : HWND;
            ProcessHandle, OutputPipe, ErrorPipe : THandle);
        destructor Destroy; override;
    end;

    // TPipeConsole component class
    TPipeConsole = class(TComponent)
    private
        // Private declarations
        FRead        : TPipeStdHandles;
        FWrite       : TPipeStdHandles;
        FWorker      : TPipeConsoleThread;
        FPriority    : TThreadPriority;
        FPI          : TProcessInformation;
        FSI          : TStartupInfo;
        FLastErr     : Integer;
        FVisible     : Boolean;
        FStopping    : Boolean;
        FHwnd        : HWND;
        FOnStop      : TOnConsoleStop;
        FOnOutput    : TOnConsole;
        FOnError     : TOnConsole;
        FApplication : string;
        FCommandLine : string;
        procedure ProcessPipe(Handle : THandle; Stream : TStream);
        function SynchronousRun(OutputStream, ErrorStream : TStream;
            TimeOut : DWORD) : DWORD;
    protected
        // Protected declarations
        function GetConsoleHandle : HWND;
        function GetRunning : Boolean;
        function GetVisible : Boolean;
        function OpenStdPipes : Boolean;
        procedure CloseStdPipes;
        procedure ForcePriority(Value : TThreadPriority);
        procedure RemoveWorkerThread(Sender : TObject);
        procedure SetLastErr(Value : Integer);
        procedure SetPriority(Value : TThreadPriority);
        procedure SetVisible(Value : Boolean);
        procedure WndMethod(var Message : TMessage);
    public
        // Public declarations
        constructor Create(AOwner : TComponent); override;
        constructor CreateUnowned;
        destructor Destroy; override;
        function ComSpec : string;
        function Execute(Application, CommandLine: string;
            OutputStream, ErrorStream: TStream; var ProcessExitCode: DWORD;
            var ProcessId: DWORD; CriticalSection: PRTLCriticalSection;
            TimeOut: DWORD = INFINITE): DWORD;
        procedure SendCtrlBreak;
        procedure SendCtrlC;
        function Start(Application, CommandLine : string) : Boolean;
        procedure Stop(ExitValue : DWORD);
        procedure Write(const Buffer; Length : Integer);
        property Application : string read FApplication;
        property CommandLine : string read FCommandLine;
        property ConsoleHandle : HWND read GetConsoleHandle;
        property Running : Boolean read GetRunning;
    published
        // Published declarations
        property LastError : Integer read FLastErr write SetLastErr;
        property OnError   : TOnConsole read FOnError write FOnError;
        property OnOutput  : TOnConsole read FOnOutput write FOnOutput;
        property OnStop    : TOnConsoleStop read FOnStop write FOnStop;
        property Priority  : TThreadPriority read FPriority write SetPriority;
        property Visible   : Boolean read GetVisible write SetVisible;
    end;

////////////////////////////////////////////////////////////////////////////////
// Console helper functions
////////////////////////////////////////////////////////////////////////////////
function ExecConsoleEvent(ProcessHandle : THandle; Event : DWORD) : Boolean;
procedure ExitProcessEx(ProcessHandle : THandle; ExitCode : DWORD);
function GetConsoleWindowEx(ProcessHandle : THandle;
    ProcessID, ThreadID : DWORD) : HWND;

////////////////////////////////////////////////////////////////////////////////
// Pipe helper functions
////////////////////////////////////////////////////////////////////////////////
function AllocPipeWrite(const Buffer; Count : Integer) : PPipeWrite;
function AllocPipeWriteWithPrefix(const Prefix; PrefixCount : Integer;
    const Buffer; Count : Integer) : PPipeWrite;
procedure CheckPipeName(Value : string);
procedure ClearOverlapped(var Overlapped : TOverlapped;
    ClearEvent : Boolean = FALSE);
procedure CloseHandleClear(var Handle : THandle); overload;
procedure CloseHandleClear(var Handle : HPIPE); overload;
function ComputerName : string;
procedure DisconnectAndClose(Pipe : HPIPE; IsServer : Boolean = TRUE);
procedure DisposePipeWrite(var PipeWrite : PPipeWrite);
function EnumConsoleWindows(Window : HWND; lParam : Integer) : BOOL; stdcall;
procedure FlushMessages;
function IsHandle(Handle : THandle) : Boolean;
procedure RaiseWindowsError;

////////////////////////////////////////////////////////////////////////////////
// Security helper functions
////////////////////////////////////////////////////////////////////////////////
procedure InitializeSecurity(var SA : TSecurityAttributes);
procedure FinalizeSecurity(var SA : TSecurityAttributes);




implementation

{$IFNDEF DELPHI_XE2_ABOVE}
type
    NativeUInt = LongWord;
    NativeInt  = LongInt;
    SIZE_T     = NativeUInt; // SIZE_T since XE2 available
{$ENDIF}

type
    // Object instance structure
    PObjectInstance = ^TObjectInstance;
    TObjectInstance = packed record
        Code : Byte;
        Offset : Integer;
        case Integer of
            0 : (Next : PObjectInstance);
            1 : (Method : TWndMethod);
    end;

const
  {$IFDEF CPUX86}
    CodeBytes = 2;
  {$ENDIF}
  {$IFDEF CPUX64}
    CodeBytes = 8;
  {$ENDIF}
    INSTANCE_COUNT = (4096 - SizeOf(Pointer) * 2 - CodeBytes) div SizeOf(TObjectInstance) - 1;//313;

type
    // Object instance page block
    PInstanceBlock = ^TInstanceBlock;
    TInstanceBlock = packed record
        Next : PInstanceBlock;
        Counter : Word;
        Code : array [1 .. CodeBytes] of Byte;
        WndProcPtr : Pointer;
        Instances : array [0 .. INSTANCE_COUNT] of TObjectInstance;
    end;

////////////////////////////////////////////////////////////////////////////////
// Global protected variables
////////////////////////////////////////////////////////////////////////////////
var
    InstBlockList  : PInstanceBlock  = nil;
    InstFreeList   : PObjectInstance = nil;
    SyncManager    : TSyncManager    = nil;
    InstCritSect   : TRTLCriticalSection;
    ThreadWndClass : TWndClass = (style : 0; lpfnWndProc : nil; cbClsExtra : 0;
        cbWndExtra : 0; hInstance : 0; hIcon : 0; hCursor : 0;
        hbrBackground : 0; lpszMenuName : nil;
        lpszClassName : 'ThreadSyncWindow');
    ObjWndClass : TWndClass = (style : 0; lpfnWndProc : @DefWindowProc;
        cbClsExtra : 0; cbWndExtra : 0; hInstance : 0; hIcon : 0; hCursor : 0;
        hbrBackground : 0; lpszMenuName : nil; lpszClassName : 'ObjWndWindow');

////////////////////////////////////////////////////////////////////////////////
// TPipeConsoleThread
////////////////////////////////////////////////////////////////////////////////

constructor TPipeConsoleThread.Create(NotifyWindow : HWND;
    ProcessHandle, OutputPipe, ErrorPipe : THandle);
begin
    // Perform inherited create (suspended)
    inherited Create(TRUE);

    // Resource protection
    try
        // Set initial state
        FProcess := 0;
        FNotify  := NotifyWindow;
        FOutput  := OutputPipe;
        FError   := ErrorPipe;
        FStream  := TFastMemStream.Create;
    finally
        // Duplicate the process handle
        DuplicateHandle(GetCurrentProcess, ProcessHandle, GetCurrentProcess,
            @FProcess, 0, TRUE, DUPLICATE_SAME_ACCESS);
    end;

    // Set thread parameters
    FreeOnTerminate := TRUE;
    Priority        := tpLower;
end;


destructor TPipeConsoleThread.Destroy;
begin
    // Resource protection
    try
        // Close the process handle
        CloseHandleClear(FProcess);
        // Free the memory stream
        FStream.Free;
    finally
        // Perform inherited
        inherited Destroy;
    end;
end;


procedure TPipeConsoleThread.Execute;
var
    dwExitCode : DWORD;
begin
    // Set default return value
    ReturnValue := ERROR_SUCCESS;

    // Keep looping until the process terminates
    while TRUE do begin
        // Wait for specified amount of time
        case WaitForSingleObject(FProcess, DEF_SLEEP) of
            // Object is signaled (process is finished)
            WAIT_OBJECT_0 : begin
                    // Process the output pipes one last time
                    ProcessPipes;
                    // Get the process exit code
                    if GetExitCodeProcess(FProcess, dwExitCode) then
                        ReturnValue := dwExitCode;
                    // Break the loop
                    break;
                end;
            // Timeout, check the output pipes for data
            WAIT_TIMEOUT :
                ProcessPipes;
        else
            // Failure, set return code
            ReturnValue := GetLastError;
            // Done processing
            break;
        end;
    end;
end;


procedure TPipeConsoleThread.ProcessPipes;
begin
    // Process the output pipe
    ProcessPipe(FOutput, WM_PIPE_CON_OUT);

    // Process the error pipe
    ProcessPipe(FError, WM_PIPE_CON_ERR);
end;


procedure TPipeConsoleThread.ProcessPipe(Handle : THandle; AMsg : UINT);
var
    dwRead : DWORD;
    dwSize : DWORD;
begin
    // Check the pipe for available data
    if PeekNamedPipe(Handle, nil, 0, nil, @dwSize, nil) and (dwSize > 0) then
    begin
        // Set the stream size
        FStream.Size := dwSize;
        // Resource protection
        try
            // Read from the pipe
            if ReadFile(Handle, FStream.Memory^, dwSize, dwRead, nil) then begin
                // Make sure we read the number of bytes specified by size
                if not(dwRead = dwSize) then
                    FStream.Size := dwRead;
                // Rewind the stream
                FStream.Position := 0;
                // Send the message to the component
                SafeSendMessage(AMsg, 0, LPARAM(FStream));
                // Sleep
                Sleep(0);
            end;
        finally
            // Clear the stream
            FStream.Clear;
        end;
    end;
end;


function TPipeConsoleThread.SafeSendMessage(AMsg : UINT;
    AWParam : WPARAM; ALParam : LPARAM) : LRESULT;
begin
    // Check window handle
    if IsWindow(FNotify) then
        // Send the message
        Result := SendMessage(FNotify, AMsg, AWParam, ALParam)
    else
        // Failure
        Result := 0;
end;

////////////////////////////////////////////////////////////////////////////////
// TPipeConsole
////////////////////////////////////////////////////////////////////////////////


constructor TPipeConsole.Create(AOwner : TComponent);
begin
    // Perform inherited create
    inherited Create(AOwner);

    // Private declarations
    FHwnd := AllocateHWnd(WndMethod);
    FillChar(FRead, SizeOf(FRead), 0);
    FillChar(FWrite, SizeOf(FWrite), 0);
    FillChar(FPI, SizeOf(FPI), 0);
    FillChar(FSI, SizeOf(FSI), 0);
    FLastErr  := ERROR_SUCCESS;
    FPriority := tpNormal;
    SetLength(FApplication, 0);
    SetLength(FCommandLine, 0);
    FStopping := FALSE;
    FVisible  := FALSE;
    FWorker   := nil;
end;


constructor TPipeConsole.CreateUnowned;
begin
    // Perform create with no owner
    Create(nil);
end;


destructor TPipeConsole.Destroy;
begin
    // Resource protection
    try
        // Stop the console application
        Stop(0);
        // Deallocate the window handle
        DeallocateHWnd(FHwnd);
    finally
        // Perform inherited
        inherited Destroy;
    end;
end;


procedure TPipeConsole.SetLastErr(Value : Integer);
begin
    // Resource protection
    try
        // Set the last error for the thread
        SetLastError(Value);
    finally
        // Update the last error status
        FLastErr := Value;
    end;
end;


function TPipeConsole.ComSpec : string;
begin
    // Allocate buffer for result
    SetLength(Result, MAX_PATH);

    // Resource protection
    try
        // Get the environment variable for COMSPEC and truncate to actual result
        SetLength(Result, GetEnvironmentVariable(PChar(resComSpec),
            Pointer(Result), MAX_PATH));
    finally
        // Capture the last error code
        FLastErr := GetLastError;
    end;
end;


function TPipeConsole.OpenStdPipes : Boolean;
var
    dwIndex : Integer;
begin
    // Set default result
    Result := FALSE;

    // Resource protection
    try
        // Close any open handles
        CloseStdPipes;
        // Resource protection
        try
            // Iterate the pipe array and create new read / write pipe handles
            for dwIndex := STD_PIPE_INPUT to STD_PIPE_ERROR do begin
                // Create the pipes
                if CreatePipe(FRead[dwIndex], FWrite[dwIndex], nil, MAX_BUFFER)
                then begin
                    // Duplicate the read handles so they can be inherited
                    if DuplicateHandle(GetCurrentProcess, FRead[dwIndex],
                        GetCurrentProcess, @FRead[dwIndex], 0, TRUE,
                        DUPLICATE_CLOSE_SOURCE or DUPLICATE_SAME_ACCESS) then
                        // Duplicate the write handles so they can be inherited
                        Result := DuplicateHandle(GetCurrentProcess,
                            FWrite[dwIndex], GetCurrentProcess,
                            @FWrite[dwIndex], 0, TRUE, DUPLICATE_CLOSE_SOURCE or
                            DUPLICATE_SAME_ACCESS)
                    else
                        // Failed to duplicate
                        Result := FALSE;
                end
                else
                    // Failed to create pipes
                    Result := FALSE;
                // Should we continue?
                if not(Result) then
                    break;
            end;
        finally
            // Capture the last error code
            FLastErr := GetLastError;
        end;
    finally
        // Close all handles on failure
        if not(Result) then
            CloseStdPipes;
    end;
end;


procedure TPipeConsole.CloseStdPipes;
var
    dwIndex : Integer;
begin
    // Iterate the pipe array and close the read / write pipe handles
    for dwIndex := STD_PIPE_INPUT to STD_PIPE_ERROR do begin
        // Close and clear the read handle
        CloseHandleClear(FRead[dwIndex]);
        // Close and clear the read handle
        CloseHandleClear(FWrite[dwIndex]);
    end;
end;


function TPipeConsole.GetRunning : Boolean;
begin
    // Check process information
    Result := (IsHandle(FPI.hProcess) and (WaitForSingleObject(FPI.hProcess,
        0) = WAIT_TIMEOUT));
end;


procedure TPipeConsole.SendCtrlBreak;
begin
    // Make sure the process is running, then inject and exec
    if GetRunning then
        ExecConsoleEvent(FPI.hProcess, CTRL_BREAK_EVENT);
end;


procedure TPipeConsole.SendCtrlC;
begin
    // Make sure the process is running, then inject and exec
    if GetRunning then
        ExecConsoleEvent(FPI.hProcess, CTRL_C_EVENT);
end;


procedure TPipeConsole.Write(const Buffer; Length : Integer);
var
    dwWrite : DWORD;
begin
    // Check state
    if GetRunning and IsHandle(FWrite[STD_PIPE_INPUT]) then begin
        // Write data to the pipe
        WriteFile(FWrite[STD_PIPE_INPUT], Buffer, Length, dwWrite, nil);
    end;
end;


function TPipeConsole.GetConsoleHandle : HWND;
var
    lpConInfo : TPipeConsoleInfo;
begin
    // Clear the return handle
    Result := 0;

    // Check to see if running
    if GetRunning then begin
        // Clear the window handle
        lpConInfo.Window := 0;
        // Resource protection
        try
            // Set process info
            lpConInfo.ProcessID := FPI.dwProcessID;
            lpConInfo.ThreadID  := FPI.dwThreadID;
            // Enumerate the windows on the console thread
            EnumWindows(@EnumConsoleWindows, LPARAM(@lpConInfo));
        finally
            // Return the window handle
            Result := lpConInfo.Window;
        end;
    end;
end;


function TPipeConsole.GetVisible : Boolean;
var
    hwndCon : HWND;
begin
    // Check running state
    if not(GetRunning) then
        // If not running then return the stored state
        Result := FVisible
    else begin
        // Attempt to get the window handle
        hwndCon := GetConsoleWindowEx(FPI.hProcess, FPI.dwProcessID,
            FPI.dwThreadID);
        // Check result
        if IsWindow(hwndCon) then
            // Return visible state
            Result := IsWindowVisible(hwndCon)
        else
            // Return stored state
            Result := FVisible;
    end;
end;


procedure TPipeConsole.ForcePriority(Value : TThreadPriority);
const
    Priorities : array [TThreadPriority] of Integer = (THREAD_PRIORITY_IDLE,
        THREAD_PRIORITY_LOWEST, THREAD_PRIORITY_BELOW_NORMAL,
        THREAD_PRIORITY_NORMAL, THREAD_PRIORITY_ABOVE_NORMAL,
        THREAD_PRIORITY_HIGHEST, THREAD_PRIORITY_TIME_CRITICAL);
begin
    // Check running state
    if not(GetRunning) then
        // Update the value
        FPriority := Value
    else begin
        // Get the thread handle
        if SetThreadPriority(FPI.hThread, Priorities[Value]) then begin
            // Priority was set, persist value
            FPriority := Value;
        end;
    end;
end;


procedure TPipeConsole.SetPriority(Value : TThreadPriority);
begin
    // Check against current value
    if (FPriority <> Value) then
        ForcePriority(Value);
end;


procedure TPipeConsole.SetVisible(Value : Boolean);
var
    hwndCon : HWND;
begin
    // Check against current state
    if not(GetVisible = Value) then begin
        // Update the state
        FVisible := Value;
        // Check to see if running
        if GetRunning then begin
            // Attempt to have the console window return us its handle
            hwndCon := GetConsoleWindowEx(FPI.hProcess, FPI.dwProcessID,
                FPI.dwThreadID);
            // Check result
            if IsWindow(hwndCon) then begin
                // Show or hide based on visibility
                if FVisible then
                    // Show
                    ShowWindow(hwndCon, SW_SHOWNORMAL)
                else
                    // Hide
                    ShowWindow(hwndCon, SW_HIDE);
            end;
        end;
    end;
end;


procedure TPipeConsole.WndMethod(var Message : TMessage);
begin
    // Handle the pipe messages
    case message.Msg of
        // Pipe output from console
        WM_PIPE_CON_OUT :
            if Assigned(FOnOutput) then
                FOnOutput(Self, TStream(Pointer(message.lParam)));
        // Pipe error from console
        WM_PIPE_CON_ERR :
            if Assigned(FOnError) then
                FOnError(Self, TStream(Pointer(message.lParam)));
        // Shutdown
        WM_DOSHUTDOWN :
            Stop(message.wParam);
    else
        // Call default window procedure
        message.Result := DefWindowProc(FHwnd, message.Msg, message.wParam,
            message.lParam);
    end;
end;


procedure TPipeConsole.RemoveWorkerThread(Sender : TObject);
var
    dwReturn : LongWord;
begin
    // Get the thread return value
    dwReturn := FWorker.ReturnValue;

    // Resource protection
    try
        // Set thread variable to nil
        FWorker := nil;
        // Resource protection
        try
            // Notify of process stop
            if (not(csDestroying in ComponentState) and Assigned(FOnStop)) then
                FOnStop(Self, dwReturn);
        finally
            // Close the process and thread handles
            CloseHandleClear(FPI.hProcess);
            CloseHandleClear(FPI.hThread);
        end;
    finally
        // Close the pipe handles
        CloseStdPipes;
    end;
end;


procedure TPipeConsole.ProcessPipe(Handle : THandle; Stream : TStream);
var
    lpszBuffer : PChar;
    dwRead     : DWORD;
    dwSize     : DWORD;
begin
    // Check the pipe for available data
    if PeekNamedPipe(Handle, nil, 0, nil, @dwSize, nil) and (dwSize > 0) then
    begin
        // Allocate buffer for read. Note, we need to clear the output even if no stream is passed
        lpszBuffer := AllocMem(dwSize);
        // Resource protection
        try
            // Read from the pipe
            if ReadFile(Handle, lpszBuffer^, dwSize, dwRead, nil) and
                Assigned(Stream) then begin
                // Save buffer to stream
                Stream.Write(lpszBuffer^, dwRead);
            end;
        finally
            // Free the memory
            FreeMem(lpszBuffer);
        end;
    end;
end;


function TPipeConsole.SynchronousRun(OutputStream, ErrorStream : TStream;
    TimeOut : DWORD) : DWORD;
begin
    // Set default return value
    SetLastErr(ERROR_SUCCESS);

    // Resource protection
    try
        // Keep looping until the process terminates
        while TRUE do begin
            // Wait for specified amount of time
            case WaitForSingleObject(FPI.hProcess, DEF_SLEEP) of
                // Object is signaled (process is finished)
                WAIT_OBJECT_0 : begin
                        // Process the output pipes one last time
                        ProcessPipe(FRead[STD_PIPE_OUTPUT], OutputStream);
                        ProcessPipe(FRead[STD_PIPE_ERROR], ErrorStream);
                        // Break the loop
                        break;
                    end;
                // Timeout, check the output pipes for data
                WAIT_TIMEOUT : begin
                        // Process the output pipes
                        ProcessPipe(FRead[STD_PIPE_OUTPUT], OutputStream);
                        ProcessPipe(FRead[STD_PIPE_ERROR], ErrorStream);
                    end;
            else
                // Failure, set return code
                SetLastErr(GetLastError);
                // Done processing
                break;
            end;
            // Check the timeout
            if (TimeOut > 0) and (GetTickCount > TimeOut) then begin
                // Terminate the process
                ExitProcessEx(FPI.hProcess, 0);
                // Set result
                SetLastErr(ERROR_TIMEOUT);
                // Done processing
                break;
            end;
        end;
    finally
        // Return last error result
        Result := FLastErr;
    end;
end;


// ProcessExitCode, ProcessId and CriticalSection added by Alexey Valuev
function TPipeConsole.Execute(Application, CommandLine: string;
    OutputStream, ErrorStream: TStream; var ProcessExitCode: DWORD;
    var ProcessId: DWORD; CriticalSection: PRTLCriticalSection;
    TimeOut: DWORD = INFINITE): DWORD;
var
  dwExitCode: DWORD;
begin
    // Set default result
    SetLastErr(ERROR_SUCCESS);
    ProcessExitCode := 0;

    // Both params cannot be null
    if (Length(Application) = 0) and (Length(CommandLine) = 0) then begin
        // Set error code
        SetLastErr(ERROR_INVALID_PARAMETER);
        // Failure
        Result := FLastErr;
    end
    else begin
        // Stop existing process if running
        Stop(0);
        // Resource protection
        try
            // Clear the process information
            FillChar(FPI, SizeOf(FPI), 0);
            // Clear the startup info structure
            FillChar(FSI, SizeOf(FSI), 0);
            // Attempt to open the pipes for redirection
            if OpenStdPipes then begin
                // Resource protection
                try
                    // Set structure size
                    FSI.cb := SizeOf(FSI);
                    // Set flags
                    FSI.dwFlags := STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES;
                    // Determine if the process will be shown or hidden
                    if FVisible then
                        // Show flag
                        FSI.wShowWindow := SW_SHOWNORMAL
                    else
                        // Hide flag
                        FSI.wShowWindow := SW_HIDE;
                    // Set the redirect handles
                    FSI.hStdInput  := FRead[STD_PIPE_INPUT];
                    FSI.hStdOutput := FWrite[STD_PIPE_OUTPUT];
                    FSI.hStdError  := FWrite[STD_PIPE_ERROR];
                    // Create the process
                    if CreateProcess(Pointer(Application), Pointer(CommandLine),
                        nil, nil, TRUE, CREATE_NEW_CONSOLE or
                        CREATE_NEW_PROCESS_GROUP or NORMAL_PRIORITY_CLASS, nil,
                        nil, FSI, FPI) then begin
                        // Resource protection
                        try
                            // Set the priority
                            if (FPriority <> tpNormal) then
                                ForcePriority(FPriority);
                            // Wait for input idle
                            WaitForInputIdle(FPI.hProcess, INFINITE);
                            if CriticalSection <> nil then
                              EnterCriticalSection(CriticalSection^);
                            try
                              ProcessId := FPI.dwProcessId;
                            finally
                              if CriticalSection <> nil then
                                LeaveCriticalSection(CriticalSection^);
                            end;
                            // Check timeout value
                            if (TimeOut = INFINITE) then
                                // Synchronous loop with no timeout
                                SynchronousRun(OutputStream, ErrorStream, 0)
                            else
                                // Synchronous loop with timeout
                                SynchronousRun(OutputStream, ErrorStream,
                                    GetTickCount + TimeOut)
                        finally
                            if GetExitCodeProcess(FPI.hProcess, dwExitCode) then
                              ProcessExitCode := dwExitCode;
                            // Close the process and thread handle
                            CloseHandleClear(FPI.hProcess);
                            CloseHandleClear(FPI.hThread);
                        end;
                    end
                    else
                        // Set the last error
                        SetLastErr(GetLastError);
                finally
                    // Close the pipe handles
                    CloseStdPipes;
                end;
            end;
        finally
            // Return last error code
            Result := FLastErr;
        end;
    end;
end;


function TPipeConsole.Start(Application, CommandLine : string) : Boolean;
begin
    // Both params cannot be null
    if (Length(Application) = 0) and (Length(CommandLine) = 0) then begin
        // Set error code
        SetLastErr(ERROR_INVALID_PARAMETER);
        // Failure
        Result := FALSE;
    end
    else begin
        // Stop existing process if running
        Stop(0);
        // Resource protection
        try
            // Clear the process information
            FillChar(FPI, SizeOf(FPI), 0);
            // Clear the startup info structure
            FillChar(FSI, SizeOf(FSI), 0);
            // Attempt to open the pipes for redirection
            if OpenStdPipes then begin
                // Set structure size
                FSI.cb := SizeOf(FSI);
                // Set flags
                FSI.dwFlags := STARTF_USESHOWWINDOW or STARTF_USESTDHANDLES;
                // Determine if the process will be shown or hidden
                if FVisible then
                    // Show flag
                    FSI.wShowWindow := SW_SHOWNORMAL
                else
                    // Hide flag
                    FSI.wShowWindow := SW_HIDE;
                // Set the redirect handles
                FSI.hStdInput  := FRead[STD_PIPE_INPUT];
                FSI.hStdOutput := FWrite[STD_PIPE_OUTPUT];
                FSI.hStdError  := FWrite[STD_PIPE_ERROR];
                // Create the process
                if CreateProcess(Pointer(Application), Pointer(CommandLine),
                    nil, nil, TRUE, CREATE_NEW_CONSOLE or
                    CREATE_NEW_PROCESS_GROUP or NORMAL_PRIORITY_CLASS, nil, nil,
                    FSI, FPI) then begin
                    // Persist the strings used to start the process
                    FApplication := Application;
                    FCommandLine := CommandLine;
                    // Set the priority
                    if (FPriority <> tpNormal) then
                        ForcePriority(FPriority);
                    // Wait for input idle
                    WaitForInputIdle(FPI.hProcess, INFINITE);
                    // Exception trap
                    try
                        // Process is created, now start the worker thread
                        FWorker := TPipeConsoleThread.Create(FHwnd,
                            FPI.hProcess, FRead[STD_PIPE_OUTPUT],
                            FRead[STD_PIPE_ERROR]);
                        // Resource protection
                        try
                            // Set the OnTerminate handler
                            FWorker.OnTerminate := RemoveWorkerThread;
                        finally
                            // Resume the worker thread
                            FWorker.Run;
                        end;
                    except
                        // Stop the process
                        Stop(0);
                    end;
                end
                else
                    // Get the last error
                    SetLastErr(GetLastError);
            end;
        finally
            // Check final running state
            Result := Assigned(FWorker);
        end;
    end;
end;


procedure TPipeConsole.Stop(ExitValue : DWORD);
begin
    // Check to see if still running
    if GetRunning and not(FStopping) then begin
        // Check to see if in a send message
        if InSendMessage then
            // Defered shutdown
            PostMessage(FHwnd, WM_DOSHUTDOWN, ExitValue, 0)
        else begin
            // Set state
            FStopping := TRUE;
            // Resource protection
            try
                // Clear strings
                SetLength(FApplication, 0);
                SetLength(FCommandLine, 0);
                // Resource protection
                try
                    // Force the process to close
                    ExitProcessEx(FPI.hProcess, ExitValue);
                    // Wait for thread to finish up
                    if Assigned(FWorker) then
                        FWorker.Wait;
                finally
                    // Close the process and thread handle
                    CloseHandleClear(FPI.hProcess);
                    CloseHandleClear(FPI.hThread);
                    // Close the pipe handles
                    CloseStdPipes;
                end;
            finally
                // Reset the stopping flag
                FStopping := FALSE;
            end;
        end;
    end;
end;

////////////////////////////////////////////////////////////////////////////////
// TPipeClient
////////////////////////////////////////////////////////////////////////////////


constructor TPipeClient.Create(AOwner : TComponent);
begin
    // Perform inherited
    inherited Create(AOwner);

    // Set defaults
    InitializeSecurity(FSA);
    FKillEv        := CreateEvent(@FSA, TRUE, FALSE, nil);
    FPipe          := INVALID_HANDLE_VALUE;
    FDisconnecting := FALSE;
    FBaseThread    := GetCurrentThreadID;
    FThrottle      := DEF_MEMTHROTTLE;
    FWriteQueue    := TWriteQueue.Create;
    FWorker        := nil;
    FPipeName      := resPipeName;
    FServerName    := EmptyStr;
    FHwnd          := AllocateHWnd(WndMethod);
end;


constructor TPipeClient.CreateUnowned;
begin
    // Perform create with no owner
    Create(nil);
end;


destructor TPipeClient.Destroy;
begin
    // Resource protection
    try
        // Disconnect the pipe
        Disconnect;
        // Close the event handle
        CloseHandle(FKillEv);
        // Free the write queue
        FWriteQueue.Free;
        // Free memory resources
        FinalizeSecurity(FSA);
        // Deallocate the window handle
        DeallocateHWnd(FHwnd);
    finally
        // Perform inherited
        inherited Destroy;
    end;
end;


function TPipeClient.GetConnected : Boolean;
var
    dwExit : DWORD;
begin
    // Check worker thread
    if Assigned(FWorker) then
        // Check exit state
        Result := GetExitCodeThread(FWorker.Handle, dwExit) and
            (dwExit = STILL_ACTIVE)
    else
        // Not connected
        Result := FALSE;
end;


function TPipeClient.Connect(WaitTime : DWORD = NMPWAIT_USE_DEFAULT_WAIT;
    Start : Boolean = TRUE) : Boolean;
var
    szName : string;
    dwMode : DWORD;
begin
    // Resource protection
    try
        // Check current connected state
        if not(GetConnected) then begin
            // Check existing pipe handle
            if IsHandle(FPipe) then begin
                // Check Start mode
                if Start then begin
                    // Pipe was already created, start worker thread against it
                    try
                        // Create thread to handle the pipe IO
                        FWorker := TPipeThread.Create(FALSE, FHwnd, FBaseThread,
                            FWriteQueue, nil, FPipe, FKillEv);
                        // Resource protection
                        try
                            // Set the OnTerminate handler
                            FWorker.OnTerminate := RemoveWorkerThread;
                        finally;
                            // Resume the thread
                            FWorker.Run;
                        end;
                    except
                        // Free the worker thread
                        FreeAndNil(FWorker);
                        // Close the pipe handle
                        CloseHandleClear(FPipe);
                    end;
                end;
            end
            else begin
                // Check name against local computer name first
                if (Length(FServerName) = 0) or
                    (CompareText(ComputerName, FServerName) = 0) then
                    // Set base local pipe name
                    szName := resPipeBaseName + FPipeName
                else
                    // Set base pipe name using specified server
                    szName := Format(resPipeBaseFmtName, [FServerName]) +
                        FPipeName;
                // Attempt to wait for the pipe first
                if WaitNamedPipe(PChar(szName), WaitTime) then begin
                    // Attempt to create client side handle
                    FPipe := CreateFile(PChar(szName), GENERIC_READ or
                        GENERIC_WRITE, 0, @FSA, OPEN_EXISTING,
                        FILE_ATTRIBUTE_NORMAL or FILE_FLAG_OVERLAPPED, 0);
                    // Success if we have a valid handle
                    if IsHandle(FPipe) then begin
                        // Set the pipe read mode flags
                        dwMode := PIPE_READMODE_MESSAGE or PIPE_WAIT;
                        // Update the pipe
                        SetNamedPipeHandleState(FPipe, dwMode, nil, nil);
                        // Check Start mode
                        if Start then begin
                            // Resource protection
                            try
                                // Create thread to handle the pipe IO
                                FWorker := TPipeThread.Create(FALSE, FHwnd,
                                    FBaseThread, FWriteQueue, nil,
                                    FPipe, FKillEv);
                                // Resource protection
                                try
                                    // Set the OnTerminate handler
                                    FWorker.OnTerminate := RemoveWorkerThread;
                                finally;
                                    // Resume the thread
                                    FWorker.Run;
                                end;
                            except
                                // Free the worker thread
                                FreeAndNil(FWorker);
                                // Close the pipe handle
                                CloseHandleClear(FPipe);
                            end;
                        end;
                    end;
                end;
            end;
        end;
    finally
        // Check connected state, or valid handle
        Result := GetConnected or IsHandle(FPipe);
    end;
end;


procedure TPipeClient.Disconnect;
begin
    // Check connected state
    if (GetConnected and not(FDisconnecting)) then begin
        // Check to see if processing a message from another thread
        if InSendMessage then
            // Defered shutdown
            PostMessage(FHwnd, WM_DOSHUTDOWN, 0, 0)
        else begin
            // Set disconnecting flag
            FDisconnecting := TRUE;
            // Resource protection
            try
                // Resource protection
                try
                    // Check worker thread
                    if Assigned(FWorker) then begin
                        // Resource protection
                        try
                            // Signal the kill event for the thread
                            SetEvent(FKillEv);
                        finally
                            // Wait for the thread to complete
                            FWorker.Wait;
                        end;
                    end;
                finally
                    // Clear pipe handle
                    FPipe := INVALID_HANDLE_VALUE;
                end;
            finally
                // Toggle flag
                FDisconnecting := FALSE;
            end;
        end;
    end
    // Check pipe handle
    else if IsHandle(FPipe) then
        // Close handle
        CloseHandleClear(FPipe);
end;


procedure TPipeClient.FlushPipeBuffers;
var
    hEvent : THandle;
begin
    // Make sure we are not being called from one of the events
    if not(InSendMessage) then begin
        // Get the event handle for the empty state
        hEvent := FWriteQueue.EmptyEvent;
        // While the worker thread is running
        while GetConnected do begin
            // Wait until the empty flag is set or we get a message
            case MsgWaitForMultipleObjects(1, hEvent, FALSE, INFINITE,
                QS_SENDMESSAGE) of
                // Empty event is signalled
                WAIT_OBJECT_0 :
                    break;
                // Messages waiting to be read
                WAIT_OBJECT_0 + 1 :
                    FlushMessages;
            end;
        end;
    end;
end;


function TPipeClient.WaitForReply(TimeOut : Cardinal = INFINITE) : Boolean;
var
    lpMsg  : TMsg;
    dwMark : LongWord;
begin
    // Clear reply flag
    FReply := FALSE;

    // Resource protection
    try
        // Make sure we are not being called from one of the events
        if not(InSendMessage) then begin
            // Get current tick count
            dwMark := GetTickCount;
            // Check connected state
            while not(FReply) and GetConnected do begin
                // Check for timeout
                if not(TimeOut = INFINITE) and
                    ((GetTickCount - dwMark) >= TimeOut) then
                    break;
                // Peek message from the queue
                if PeekMessage(lpMsg, 0, WM_PIPEMINMSG, WM_PIPEMAXMSG, PM_REMOVE)
                then begin
                    // Translate the message
                    TranslateMessage(lpMsg);
                    // Dispatch the message
                    DispatchMessage(lpMsg);
                end;
            end;
        end;
    finally
        // Is the reply flag set
        Result := FReply;
    end;
end;


function TPipeClient.SendStream(Stream : TStream) : Boolean;
var
    lpszBuffer : PChar;
    dwRead     : Integer;
begin
    // Check stream and current state
    if Assigned(Stream) and GetConnected then begin
        // Set default result
        Result := TRUE;
        // Resource protection
        try
            // Enqueue the start packet
            FWriteQueue.EnqueueStartPacket;
            // Resource protection
            try
                // Allocate buffer for sending
                lpszBuffer := AllocMem(MAX_BUFFER);
                // Resource protection
                try
                    // Set stream position
                    Stream.Position := 0;
                    // Queue the first read
                    dwRead := Stream.Read(lpszBuffer^, MAX_BUFFER);
                    // While data
                    while (dwRead > 0) and Result do begin
                        // Write the data
                        if write(lpszBuffer^, dwRead) then
                            // Seed next data
                            dwRead := Stream.Read(lpszBuffer^, MAX_BUFFER)
                        else
                            // Failed to write the data
                            Result := FALSE;
                    end;
                finally
                    // Free memory
                    FreeMem(lpszBuffer);
                end;
            finally
                // Enqueue the end packet
                FWriteQueue.EnqueueEndPacket;
            end;
        finally
            // Flush the buffers
            FlushPipeBuffers;
        end;
    end
    else
        // Invalid param or state
        Result := FALSE;
end;


function TPipeClient.Write(var Prefix; PrefixCount : Integer; var Buffer;
    Count : Integer) : Boolean;
begin
    // Check for memory throttling
    if ((FThrottle > 0) and (FWriteQueue.DataSize > FThrottle) and GetConnected)
    then
        FlushPipeBuffers;

    // Check connected state
    if GetConnected then begin
        // Resource protection
        try
            // Queue the data
            FWriteQueue.Enqueue(AllocPipeWriteWithPrefix(Prefix, PrefixCount,
                Buffer, Count));
        finally
            // Success
            Result := TRUE;
        end;
    end
    else
        // Not connected
        Result := FALSE;
end;


function TPipeClient.Write(var Buffer; Count : Integer) : Boolean;
begin
    // Check for memory throttling
    if ((FThrottle > 0) and (FWriteQueue.DataSize > FThrottle) and GetConnected)
    then
        FlushPipeBuffers;

    // Check connected state
    if GetConnected then begin
        // Resource protection
        try
            // Queue the data
            FWriteQueue.Enqueue(AllocPipeWrite(Buffer, Count));
        finally
            // Success
            Result := TRUE;
        end;
    end
    else
        // Not connected
        Result := FALSE;
end;


procedure TPipeClient.SetPipeName(Value : string);
begin
    // Check connected state and pipe handle
    if GetConnected or IsHandle(FPipe) then
        // Raise exception
        raise EPipeException.CreateRes(@resPipeConnected)
    else begin
        // Check the pipe name
        CheckPipeName(Value);
        // Set the pipe name
        FPipeName := Value;
    end;
end;


procedure TPipeClient.SetServerName(Value : string);
begin
    // Check connected state and pipe handle
    if GetConnected or IsHandle(FPipe) then
        // Raise exception
        raise EPipeException.CreateRes(@resPipeConnected)
    else
        // Set the server name
        FServerName := Value;
end;


procedure TPipeClient.RemoveWorkerThread(Sender : TObject);
begin
    // Set thread variable to nil
    FWorker := nil;

    // Resource protection
    try
        // Notify of disconnect
        if (not(csDestroying in ComponentState) and Assigned(FOPD)) then
            FOPD(Self, FPipe);
        // Clear the write queue
        FWriteQueue.Clear;
    finally
        // Invalidate handle
        FPipe := INVALID_HANDLE_VALUE;
    end;
end;


procedure TPipeClient.WndMethod(var AMsg : TMessage);
begin
    // Handle the pipe messages
    case AMsg.Msg of
        // Pipe worker error
        WM_PIPEERROR_W :
            if Assigned(FOPE) then
                FOPE(Self, AMsg.wParam, pcWorker, AMsg.lParam);
        // Pipe data sent
        WM_PIPESEND :
            if Assigned(FOPS) then
                FOPS(Self, AMsg.wParam, AMsg.lParam);
        // Pipe data read
        WM_PIPEMESSAGE : begin
                // Set reply flag
                FReply := TRUE;
                // Fire event
                if Assigned(FOPM) then
                    FOPM(Self, AMsg.wParam,
                        TStream(Pointer(AMsg.lParam)));
            end;
        // Raise exception
        WM_THREADCTX :
            raise EPipeException.CreateRes(@resThreadCtx);
        // Disconect
        WM_DOSHUTDOWN :
            Disconnect;
    else
        // Call default window procedure
        AMsg.Result := DefWindowProc(FHwnd, AMsg.Msg, AMsg.wParam,
            AMsg.lParam);
    end;
end;

////////////////////////////////////////////////////////////////////////////////
// TPipeServer
////////////////////////////////////////////////////////////////////////////////


constructor TPipeServer.Create(AOwner : TComponent);
begin
    // Perform inherited
    inherited Create(AOwner);

    // Initialize the security attributes
    InitializeSecurity(FSA);

    // Set staring defaults
    FHwnd        := AllocateHWnd(WndMethod);
    FBaseThread  := GetCurrentThreadID;
    FPipeName    := resPipeName;
    FActive      := FALSE;
    FDeferActive := FALSE;
    FInShutDown  := FALSE;
    FKillEv      := CreateEvent(@FSA, TRUE, FALSE, nil);
    FClients     := TList.Create;
    FThreadCount := TThreadCounter.Create;
    FListener    := nil;
end;


constructor TPipeServer.CreateUnowned;
begin
    // Perform inherited create with no owner
    Create(nil);
end;


destructor TPipeServer.Destroy;
begin
    // Resource protection
    try
        // Perform the shutdown if active
        Active := FALSE;
        // Close the event handle
        CloseHandle(FKillEv);
        // Free the clients list
        FClients.Free;
        // Free the thread counter
        FThreadCount.Free;
        // Cleanup memory
        FinalizeSecurity(FSA);
        // Deallocate the window
        DeallocateHWnd(FHwnd);
    finally
        // Perform inherited
        inherited Destroy;
    end;
end;


procedure TPipeServer.WndMethod(var Message : TMessage);
begin
    // Handle the pipe messages
    case message.Msg of
        // Listener thread error
        WM_PIPEERROR_L :
            if Assigned(FOPE) then
                FOPE(Self, message.wParam, pcListener, message.lParam);
        // Worker thread error
        WM_PIPEERROR_W :
            if Assigned(FOPE) then
                FOPE(Self, message.wParam, pcWorker, message.lParam);
        // Pipe connected
        WM_PIPECONNECT :
            if Assigned(FOPC) then
                FOPC(Self, message.wParam);
        // Data message sent on pipe
        WM_PIPESEND :
            if Assigned(FOPS) then
                FOPS(Self, message.wParam, message.lParam);
        // Data message recieved on pipe
        WM_PIPEMESSAGE :
            if Assigned(FOPM) then
                FOPM(Self, message.wParam, TStream(Pointer(message.lParam)));
        // Raise exception
        WM_THREADCTX :
            raise EPipeException.CreateRes(@resThreadCtx);
        // Disconect
        WM_DOSHUTDOWN :
            Active := FALSE;
    else
        // Call default window procedure
        message.Result := DefWindowProc(FHwnd, message.Msg, message.wParam,
            message.lParam);
    end;
end;


function TPipeServer.GetClientInfo(Pipe : HPIPE; out PipeInfo : PPipeInfo)
    : Boolean;
var
    dwIndex : Integer;
begin
    // Clear outbound param
    PipeInfo := nil;

    // Resource protection
    try
        // Locate the pipe info record for the given pipe first
        for dwIndex := Pred(FClients.Count) downto 0 do begin
            // Check pipe info pointer
            if (PPipeInfo(FClients[dwIndex])^.Pipe = Pipe) then begin
                // Found the record
                PipeInfo := PPipeInfo(FClients[dwIndex]);
                // Done processing
                break;
            end;
        end;
    finally
        // Success if we have the record
        Result := Assigned(PipeInfo);
    end;
end;


function TPipeServer.GetClient(Index : Integer) : HPIPE;
begin
    // Return the requested pipe
    Result := PPipeInfo(FClients[index])^.Pipe;
end;


function TPipeServer.GetClientCount : Integer;
begin
    // Return the number of client pipes
    Result := FClients.Count;
end;


function TPipeServer.Broadcast(var Buffer; Count : Integer) : Boolean;
var
    dwIndex : Integer;
    dwCount : Integer;
begin
    // Set count
    dwCount := 0;

    // Resource protection
    try
        // Iterate the pipes and write the data to each one
        for dwIndex := Pred(FClients.Count) downto 0 do begin
            // Fail if a write fails
            if write(Clients[dwIndex], Buffer, Count) then
                // Update count
                Inc(dwCount)
            else
                // Failed, break out
                break;
        end;
    finally
        // Success if all pipes got the message
        Result := (dwCount = FClients.Count);
    end;
end;


function TPipeServer.Broadcast(var Prefix; PrefixCount : Integer; var Buffer;
    Count : Integer) : Boolean;
var
    dwIndex : Integer;
    dwCount : Integer;
begin
    // Set count
    dwCount := 0;

    // Resource protection
    try
        // Iterate the pipes and write the data to each one
        for dwIndex := Pred(FClients.Count) downto 0 do begin
            // Fail if a write fails
            if write(Clients[dwIndex], Prefix, PrefixCount, Buffer, Count) then
                // Update count
                Inc(dwCount)
            else
                // Failed, break out
                break;
        end;
    finally
        // Success if all pipes got the message
        Result := (dwCount = FClients.Count);
    end;
end;


function TPipeServer.Write(Pipe : HPIPE; var Prefix; PrefixCount : Integer;
    var Buffer; Count : Integer) : Boolean;
var
    ppiClient : PPipeInfo;
begin
    // Get the pipe info
    if GetClientInfo(Pipe, ppiClient) then begin
        // Queue the data
        ppiClient.WriteQueue.Enqueue(AllocPipeWriteWithPrefix(Prefix,
            PrefixCount, Buffer, Count));
        // Success
        Result := TRUE;
    end
    else
        // No client info
        Result := FALSE;
end;


function TPipeServer.Write(Pipe : HPIPE; var Buffer; Count : Integer) : Boolean;
var
    ppiClient : PPipeInfo;
begin
    // Get the pipe info
    if GetClientInfo(Pipe, ppiClient) then begin
        // Queue the data
        ppiClient.WriteQueue.Enqueue(AllocPipeWrite(Buffer, Count));
        // Success
        Result := TRUE;
    end
    else
        // No client info
        Result := FALSE;
end;


function TPipeServer.SendStream(Pipe : HPIPE; Stream : TStream) : Boolean;
var
    ppiClient  : PPipeInfo;
    lpszBuffer : PChar;
    dwRead     : Integer;
begin
    // Check stream and current state
    if Assigned(Stream) and GetClientInfo(Pipe, ppiClient) then begin
        // Resource protection
        try
            // Enqueue the start packet
            ppiClient^.WriteQueue.EnqueueStartPacket;
            // Resource protection
            try
                // Allocate buffer for sending
                lpszBuffer := AllocMem(MAX_BUFFER);
                // Resource protection
                try
                    // Set stream position
                    Stream.Position := 0;
                    // Queue the first read
                    dwRead := Stream.Read(lpszBuffer^, MAX_BUFFER);
                    // While data
                    while (dwRead > 0) do begin
                        // Enqueue the data
                        ppiClient^.WriteQueue.Enqueue
                            (AllocPipeWrite(lpszBuffer^, dwRead));
                        // Seed next data
                        dwRead := Stream.Read(lpszBuffer^, MAX_BUFFER)
                    end;
                finally
                    // Free memory
                    FreeMem(lpszBuffer);
                end;
            finally
                // Enqueue the end packet
                ppiClient^.WriteQueue.EnqueueEndPacket;
            end;
        finally
            // Set default result
            Result := TRUE;
        end;
    end
    else
        // Invalid param or state
        Result := FALSE;
end;


procedure TPipeServer.RemoveClient(Pipe : HPIPE);
var
    ppiClient : PPipeInfo;
begin
    // Attempt to get the pipe info
    if GetClientInfo(Pipe, ppiClient) then begin
        // Remove from the client list
        FClients.Remove(ppiClient);
        // Resource protection
        try
            // Resource protection
            try
                // Free the write queue
                ppiClient^.WriteQueue.Free;
                // Close the event handle
                CloseHandle(ppiClient^.KillEvent);
            finally
                // Free the client record
                FreeMem(ppiClient);
            end;
        finally
            // Call the OnDisconnect if assigned and not destroying
            if not(csDestroying in ComponentState) and Assigned(FOPD) then
                FOPD(Self, Pipe);
        end;
    end;
end;


function TPipeServer.Disconnect(Pipe : HPIPE) : Boolean;
var
    ppiClient : PPipeInfo;
    dwIndex   : Integer;
begin
    // Set default result
    Result := TRUE;

    // Check pipe passed in
    if (Pipe = 0) then begin
        // Disconnect all
        for dwIndex := Pred(FClients.Count) downto 0 do begin
            // Signal the kill event
            SetEvent(PPipeInfo(FClients[dwIndex])^.KillEvent);
        end;
    end
    // Get the specifed pipe info
    else if GetClientInfo(Pipe, ppiClient) then
        // Set the kill event
        SetEvent(ppiClient^.KillEvent)
    else
        // Failed to locate the pipe
        Result := FALSE;
end;


procedure TPipeServer.Loaded;
begin
    // Perform inherited
    inherited;

    // Set deferred active state
    SetActive(FDeferActive);
end;


procedure TPipeServer.SetActive(Value : Boolean);
begin
    // Check against current state
    if not(FActive = Value) then begin
        // Check loaded state
        if (csLoading in ComponentState) then
            // Set deferred state
            FDeferActive := Value
            // Check designing state. The problem is that in the IDE, a count on the
            // handle will be left open and cause us issues with client connections when
            // running in debugger.
        else if (csDesigning in ComponentState) then
            // Just update the value
            FActive := Value
        else if (Value) then
            // Perform startup
            DoStartup
        else
            // Perform shutdown
            DoShutdown;
    end;
end;


procedure TPipeServer.SetPipeName(Value : string);
begin
    // Check for change
    if not(Value = FPipeName) then begin
        // Check active state
        if FActive then
            // Cannot change pipe name if pipe server is active
            raise EPipeException.CreateRes(@resPipeActive)
        else begin
            // Check the pipe name
            CheckPipeName(Value);
            // Set the new pipe name
            FPipeName := Value;
        end;
    end;
end;


function TPipeServer.AllocPipeInfo(Pipe : HPIPE) : PPipeInfo;
begin
    // Create a new pipe info structure to manage the pipe
    Result := AllocMem(SizeOf(TPipeInfo));

    // Resource protection
    try
        // Set the pipe value
        Result^.Pipe := Pipe;
        // Create the write queue
        Result^.WriteQueue := TWriteQueue.Create;
        // Create individual kill events
        Result^.KillEvent := CreateEvent(nil, TRUE, FALSE, nil);
    finally
        // Add to client list
        FClients.Add(Result);
    end;
end;


procedure TPipeServer.AddWorkerThread(Pipe : HPIPE);
var
    pstWorker : TPipeThread;
    ppInfo    : PPipeInfo;
begin
    // Set worker thread
    pstWorker := nil;

    // Create a new pipe info structure to manage the pipe
    ppInfo := AllocPipeInfo(Pipe);

    // Resource protection
    try
        // Create the server worker thread
        pstWorker := TPipeThread.Create(TRUE, FHwnd, FBaseThread,
            ppInfo^.WriteQueue, FThreadCount, Pipe, ppInfo^.KillEvent);
        // Resource protection
        try
            // Set the OnTerminate handler
            pstWorker.OnTerminate := RemoveWorkerThread;
        finally
            // Resume the thread
            pstWorker.Run;
        end;
    except
        // Exception during thread create, remove the client record
        RemoveClient(Pipe);
        // Disconnect and close the pipe handle
        DisconnectAndClose(Pipe);
        // Free the worker thread object
        FreeAndNil(pstWorker);
    end;
end;


procedure TPipeServer.RemoveWorkerThread(Sender : TObject);
begin
    // Remove the pipe info record associated with this thread
    RemoveClient(TPipeThread(Sender).Pipe);
end;


procedure TPipeServer.RemoveListenerThread(Sender : TObject);
begin
    // Nil the thread var
    FListener := nil;

    // If we are not in a shutdown and are the only thread, then change the active state
    if (not(FInShutDown) and (FThreadCount.Count = 1)) then
        FActive := FALSE;
end;


procedure TPipeServer.DoStartup;
begin
    // Check active state
    if not(FActive) then begin
        // Make sure the kill event is in a non-signaled state
        ResetEvent(FKillEv);
        // Resource protection
        try
            // Create the listener thread
            FListener := TPipeListenThread.Create(Self, FKillEv);
            // Resource protection
            try
                // Set the OnTerminate handler
                FListener.OnTerminate := RemoveListenerThread;
            finally
                // Resume
                FListener.Run;
            end;
        except
            // Free the listener thread
            FreeAndNil(FListener);
            // Re-raise the exception
            raise;
        end;
        // Set active state
        FActive := TRUE;
    end;
end;


procedure TPipeServer.DoShutdown;
begin
    // If we are not active then exit
    if FActive and not(FInShutDown) then begin
        // Check in message flag
        if InSendMessage then
            // Defered shutdown
            PostMessage(FHwnd, WM_DOSHUTDOWN, 0, 0)
        else begin
            // Set shutdown flag
            FInShutDown := TRUE;
            // Resource protection
            try
                // Resource protection
                try
                    // Signal the kill event for the listener thread
                    SetEvent(FKillEv);
                    // Disconnect all
                    Disconnect(0);
                    // Wait until threads have finished up
                    FThreadCount.WaitForEmpty;
                finally
                    // Reset active state
                    FActive := FALSE;
                end;
            finally
                // Set active state to FALSE
                FInShutDown := FALSE;
            end;
        end;
    end;
end;


////////////////////////////////////////////////////////////////////////////////
// TPipeThread
////////////////////////////////////////////////////////////////////////////////


constructor TPipeThread.Create(Server : Boolean; NotifyWindow : HWND;
    NotifyThread : THandle; WriteQueue : TWriteQueue; Counter : TThreadCounter;
    Pipe : HPIPE; KillEvent : THandle);
begin
    // Perform inherited create (suspended)
    inherited Create(TRUE);

    // Increment the thread counter if assigned
    // statement changed 1-12-2013
    // if Assigned(FCounter) then
    // FCounter.Increment;
    if Assigned(Counter) then
        Counter.Increment;

    // Set initial state
    FServer       := Server;
    FNotify       := NotifyWindow;
    FNotifyThread := NotifyThread;
    FWriteQueue   := WriteQueue;
    FCounter      := Counter;
    FPipe         := Pipe;
    FErrorCode    := ERROR_SUCCESS;
    FPendingRead  := FALSE;
    FPendingWrite := FALSE;
    FPipeWrite    := nil;
    FMultiMsg     := nil;
    FRcvSize      := MAX_BUFFER;
    FRcvAlloc     := MAX_BUFFER;
    FRcvBuffer    := AllocMem(FRcvAlloc);
    FRcvStream    := TFastMemStream.Create;
    ClearOverlapped(FOlapRead, TRUE);
    ClearOverlapped(FOlapWrite, TRUE);
    FOlapRead.hEvent  := CreateEvent(nil, TRUE, FALSE, nil);
    FOlapWrite.hEvent := CreateEvent(nil, TRUE, FALSE, nil);
    ResetEvent(KillEvent);
    FEvents[0] := KillEvent;
    FEvents[1] := FOlapRead.hEvent;
    FEvents[2] := FOlapWrite.hEvent;
    FEvents[3] := FWriteQueue.DataEvent;

    // Set thread parameters
    FreeOnTerminate := TRUE;
    Priority        := tpLower;
end;


destructor TPipeThread.Destroy;
begin
    // Resource protection
    try
        // Resource protection
        try
            // Free the write buffer we may be holding on to
            DisposePipeWrite(FPipeWrite);
            // Free the receiver stream
            FRcvStream.Free;
            // Free buffer memory
            FreeMem(FRcvBuffer);
        finally
            // Decrement the thread counter if assigned
            if Assigned(FCounter) then
                FCounter.Decrement;
        end;
    finally
        // Perform inherited
        inherited Destroy;
    end;
end;


function TPipeThread.SafeSendMessage(AMsg : UINT; AWParam : WPARAM;
    ALParam : LPARAM): LRESULT;
begin
    // Check notification window
    if IsWindow(FNotify) then
        // Send the message
        Result := SendMessage(FNotify, AMsg, AWParam, ALParam)
    else
        // Failure
        Result := 0;
end;


function TPipeThread.QueuedRead : Boolean;
begin
    // Resource protection
    try
        // If we already have a pending read then nothing to do
        if not(FPendingRead) then begin
            // Set buffer size
            FRcvSize := FRcvAlloc;
            // Keep reading all available data until we get a pending read or a failure
            while not(FPendingRead) do begin
                // Set overlapped fields
                ClearOverlapped(FOlapRead);
                // Perform a read
                if ReadFile(FPipe, FRcvBuffer^, FRcvSize, FRcvRead, @FOlapRead)
                then begin
                    // Resource protection
                    try
                        // We read a full message
                        FRcvStream.Write(FRcvBuffer^, FRcvRead);
                        // Call the OnData
                        DoMessage;
                    finally
                        // Reset the read event
                        ResetEvent(FOlapRead.hEvent);
                    end;
                end
                else begin
                    // Get the last error code
                    FErrorCode := GetLastError;
                    // Handle cases where message is larger than read buffer used
                    if (FErrorCode = ERROR_MORE_DATA) then begin
                        // Write the current data
                        FRcvStream.Write(FRcvBuffer^, FRcvSize);
                        // Determine how much we need to expand the buffer to
                        if PeekNamedPipe(FPipe, nil, 0, nil, nil, @FRcvSize)
                        then begin
                            // Determine if required size is larger than allocated size
                            if (FRcvSize > FRcvAlloc) then begin
                                // Realloc buffer
                                ReallocMem(FRcvBuffer, FRcvSize);
                                // Update allocated size
                                FRcvAlloc := FRcvSize;
                            end;
                        end
                        else begin
                            // Failure
                            FErrorCode := GetLastError;
                            // Done
                            break;
                        end;
                    end
                    // Pending read
                    else if (FErrorCode = ERROR_IO_PENDING) then
                        // Set pending flag
                        FPendingRead := TRUE
                    else
                        // Failure
                        break;
                end;
            end;
        end;
    finally
        // Success if we have a pending read
        Result := FPendingRead;
    end;
end;


function TPipeThread.CompleteRead : Boolean;
begin
    // Reset the read event and pending flag
    ResetEvent(FOlapRead.hEvent);

    // Reset pending read
    FPendingRead := FALSE;

    // Check the overlapped results
    Result := GetOverlappedResult(FPipe, FOlapRead, FRcvRead, TRUE);

    // Handle failure
    if not(Result) then begin
        // Get the last error code
        FErrorCode := GetLastError;
        // Check for more data
        if (FErrorCode = ERROR_MORE_DATA) then begin
            // Write the current data to the stream
            FRcvStream.Write(FRcvBuffer^, FRcvSize);
            // Determine how much we need to expand the buffer to
            Result := PeekNamedPipe(FPipe, nil, 0, nil, nil, @FRcvSize);
            // Check result
            if Result then begin
                // Determine if required size is larger than allocated size
                if (FRcvSize > FRcvAlloc) then begin
                    // Realloc buffer
                    ReallocMem(FRcvBuffer, FRcvSize);
                    // Update allocated size
                    FRcvAlloc := FRcvSize;
                end;
                // Set overlapped fields
                ClearOverlapped(FOlapRead);
                // Read from the file again
                Result := ReadFile(FPipe, FRcvBuffer^, FRcvSize, FRcvRead,
                    @FOlapRead);
                // Handle error
                if not(Result) then begin
                    // Set error code
                    FErrorCode := GetLastError;
                    // Check for pending again, which means our state hasn't changed
                    if (FErrorCode = ERROR_IO_PENDING) then begin
                        // Still a pending read
                        FPendingRead := TRUE;
                        // Success
                        Result := TRUE;
                    end;
                end;
            end
            else
                // Set error code
                FErrorCode := GetLastError;
        end;
    end;

    // Check result and pending read flag
    if Result and not(FPendingRead) then begin
        // We have the full message
        FRcvStream.Write(FRcvBuffer^, FRcvRead);
        // Call the OnData
        DoMessage;
    end;
end;


function TPipeThread.QueuedWrite : Boolean;
var
    bWrite : Boolean;
begin
    // Set default result
    Result := TRUE;

    // Check pending state
    if not(FPendingWrite) then begin
        // Check state of data event
        if (WaitForSingleObject(FEvents[3], 0) = WAIT_OBJECT_0) then begin
            // Dequeue write block
            FPipeWrite := FWriteQueue.Dequeue;
            // Is the record assigned?
            if Assigned(FPipeWrite) then begin
                // Set overlapped fields
                ClearOverlapped(FOlapWrite);
                // Write the data to the client
                bWrite := WriteFile(FPipe, FPipeWrite^.Buffer^,
                    FPipeWrite^.Count, FWrite, @FOlapWrite);
                // Get the last error code
                FErrorCode := GetLastError;
                // Check the write operation
                if bWrite then begin
                    // Resource protection
                    try
                        // Flush the pipe
                        FlushFileBuffers(FPipe);
                        // Call the OnData in the main thread
                        SafeSendMessage(WM_PIPESEND, WPARAM(FPipe), LPARAM(FWrite));
                        // Free the pipe write data
                        DisposePipeWrite(FPipeWrite);
                    finally
                        // Reset the write event
                        ResetEvent(FOlapWrite.hEvent);
                    end;
                end
                // Only acceptable error is pending
                else if (FErrorCode = ERROR_IO_PENDING) then
                    // Set pending flag
                    FPendingWrite := TRUE
                else
                    // Failure
                    Result := FALSE;
            end;
        end
        else
            // No data to write
            Result := TRUE;
    end;
end;


function TPipeThread.CompleteWrite : Boolean;
begin
    // Reset the write event and pending flag
    ResetEvent(FOlapWrite.hEvent);

    // Resource protection
    try
        // Check the overlapped results
        Result := GetOverlappedResult(FPipe, FOlapWrite, FWrite, TRUE);
        // Resource protection
        try
            // Handle failure
            if not(Result) then
                // Get the last error code
                FErrorCode := GetLastError
            else begin
                // Flush the pipe
                FlushFileBuffers(FPipe);
                // We sent a full message so call the OnSent in the main thread
                SafeSendMessage(WM_PIPESEND, WPARAM(FPipe), LPARAM(FWrite));
            end;
        finally
            // Make sure to free the queued pipe data
            DisposePipeWrite(FPipeWrite);
        end;
    finally
        // Reset pending flag
        FPendingWrite := FALSE;
    end;
end;


procedure TPipeThread.DoMessage;
var
    lpControlMsg : PPipeMsgBlock;
begin
    // Rewind the stream
    FRcvStream.Position := 0;

    // Resource protection
    try
        // Check the data to see if this is a multi part message
        if (FRcvStream.Size = SizeOf(TPipeMsgBlock)) then begin
            // Cast memory as control message
            lpControlMsg := PPipeMsgBlock(FRcvStream.Memory);
            // Check constants
            if (lpControlMsg^.Size = SizeOf(TPipeMsgBlock)) and
                (lpControlMsg^.MagicStart = MB_MAGIC) and
                (lpControlMsg^.MagicEnd = MB_MAGIC) then begin
                // Check to see if this is a start
                if (lpControlMsg^.ControlCode = MB_START) then begin
                    // Free existing multi part message
                    FreeAndNil(FMultiMsg);
                    // Create new multi part message
                    FMultiMsg := TPipeMultiMsg.Create;
                end
                // Check to see if this is an end
                else if (lpControlMsg^.ControlCode = MB_END) then begin
                    // The multi part message must be assigned
                    if Assigned(FMultiMsg) then begin
                        // Resource protection
                        try
                            // Rewind the stream
                            FMultiMsg.Stream.Position := 0;
                            // Send the message to the notification window
                            SafeSendMessage(WM_PIPEMESSAGE, WPARAM(FPipe),
                                LPARAM(FMultiMsg.Stream));
                        finally
                            // Free the multi part message
                            FreeAndNil(FMultiMsg);
                        end;
                    end;
                end
                else
                    // Unknown code
                    FreeAndNil(FMultiMsg);
            end
            else begin
                // Check for multi part message packet
                if Assigned(FMultiMsg) then
                    // Add data to existing stream
                    FMultiMsg.Stream.Write(FRcvStream.Memory^, FRcvStream.Size)
                else
                    // Send the message to the notification window
                    SafeSendMessage(WM_PIPEMESSAGE, WPARAM(FPipe), LPARAM(FRcvStream));
            end;
        end
        // Check to see if we are in a multi part message
        else if Assigned(FMultiMsg) then
            // Add data to existing stream
            FMultiMsg.Stream.Write(FRcvStream.Memory^, FRcvStream.Size)
        else
            // Send the message to the notification window
            SafeSendMessage(WM_PIPEMESSAGE, WPARAM(FPipe), LPARAM(FRcvStream));
    finally
        // Clear the read stream
        FRcvStream.Clear;
    end;
end;


procedure TPipeThread.Execute;
var
    dwEvents : Integer;
    bOK      : Boolean;
begin
    // Resource protection
    try
        // Check sync base thread against the component main thread
        if not(Sync.SyncBaseTID = FNotifyThread) then
            // Post message to main window and we are done
            PostMessage(FNotify, WM_THREADCTX, 0, 0)
        else begin
            // Notify the pipe server of the connect
            if FServer then
                SafeSendMessage(WM_PIPECONNECT, WPARAM(FPipe), 0);
            // Loop while not terminated
            while not(Terminated) do begin
                // Make sure we always have an outstanding read and write queued up
                bOK := (QueuedRead and QueuedWrite);
                // Relinquish time slice
                Sleep(0);
                // Check current queue state
                if bOK then begin
                    // Set number of events to wait on
                    dwEvents := 4;
                    // If a write is pending, then don't wait on the write queue data event
                    if FPendingWrite then
                        Dec(dwEvents);
                    // Handle the event that was signalled (or failure)
                    case WaitForMultipleObjects(dwEvents, @FEvents, FALSE,
                        INFINITE) of
                        // Killed by pipe server
                        WAIT_OBJECT_0 : begin
                                // Resource protection
                                try
                                    // Finish any final read / write (allow them a small delay to finish up)
                                    if FPendingWrite and
                                        (WaitForSingleObject(FEvents[2],
                                        DEF_SLEEP) = WAIT_OBJECT_0) then
                                        CompleteWrite;
                                    if FPendingRead and
                                        (WaitForSingleObject(FEvents[1],
                                        DEF_SLEEP) = WAIT_OBJECT_0) then
                                        CompleteRead;
                                finally
                                    // Terminate the thread
                                    Terminate;
                                end;
                            end;
                        // Read completed
                        WAIT_OBJECT_0 + 1 :
                            bOK := CompleteRead;
                        // Write completed
                        WAIT_OBJECT_0 + 2 :
                            bOK := CompleteWrite;
                        // Data waiting to be sent
                        WAIT_OBJECT_0 + 3 :
                            ;
                    else
                        // General failure
                        FErrorCode := GetLastError;
                        // Set status
                        bOK := FALSE;
                    end;
                end;
                // Check status
                if not(bOK) then begin
                    // Call OnError in the main thread if this is not a disconnect. Disconnects
                    // have their own event, and are not to be considered an error
                    if not(FErrorCode = ERROR_BROKEN_PIPE) then
                        SafeSendMessage(WM_PIPEERROR_W, WPARAM(FPipe), LPARAM(FErrorCode));
                    // Terminate the thread
                    Terminate;
                end;
            end;
        end;
    finally
        // Disconnect and close the pipe handle at this point
        DisconnectAndClose(FPipe, FServer);
        // Close all open handles that we own
        CloseHandle(FOlapRead.hEvent);
        CloseHandle(FOlapWrite.hEvent);
    end;
end;


////////////////////////////////////////////////////////////////////////////////
// TPipeListenThread
////////////////////////////////////////////////////////////////////////////////


constructor TPipeListenThread.Create(PipeServer : TPipeServer;
    KillEvent : THandle);
begin
    // Perform inherited create (suspended)
    inherited Create(TRUE);
    // Set starting parameters
    FreeOnTerminate := TRUE;
    Priority        := tpLower;
    FPipeServer     := PipeServer;

    // Increment the thread counter
    FPipeServer.FThreadCount.Increment;
    // *** 2010-12-01: MMC -- Moved this line from just after the "inherited Create(TRUE)" to after the assignment has been made to the property

    FNotifyThread := FPipeServer.FBaseThread;
    FPipeName     := PipeServer.PipeName;
    FNotify       := PipeServer.WindowHandle;
    InitializeSecurity(FSA);
    FPipe      := INVALID_HANDLE_VALUE;
    FConnected := FALSE;
    FillChar(FOlapConnect, SizeOf(FOlapConnect), 0);
    FOlapConnect.hEvent := CreateEvent(@FSA, TRUE, FALSE, nil);;
    FEvents[0]          := KillEvent;
    FEvents[1]          := FOlapConnect.hEvent;
end;


destructor TPipeListenThread.Destroy;
begin
    // Resource protection
    try
        // Resource protection
        try
            // Close the connect event handle
            CloseHandle(FOlapConnect.hEvent);
            // Disconnect and free the handle
            if IsHandle(FPipe) then begin
                // Check connected state
                if FConnected then
                    // Disconnect and close
                    DisconnectAndClose(FPipe)
                else
                    // Just close the handle
                    CloseHandle(FPipe);
            end;
            // Release memory for security structure
            FinalizeSecurity(FSA);
        finally
            // Decrement the thread counter
            FPipeServer.FThreadCount.Decrement;
        end;
    finally
        // Perform inherited
        inherited Destroy;
    end;
end;


function TPipeListenThread.CreateServerPipe : Boolean;
begin
    // Create the outbound pipe first
    FPipe := CreateNamedPipe(PChar(resPipeBaseName + FPipeName), PIPE_OPENMODE,
        PIPE_MODE, PIPE_INSTANCES, 0, 0, 1000, @FSA);

    // Resource protection
    try
        // Set result value based on valid handle
        if IsHandle(FPipe) then
            // Success
            FErrorCode := ERROR_SUCCESS
        else
            // Get last error
            FErrorCode := GetLastError;
    finally
        // Success if handle is valid
        Result := IsHandle(FPipe);
    end;
end;


procedure TPipeListenThread.DoWorker;
begin
    // Call the pipe server on the main thread to add a new worker thread
    FPipeServer.AddWorkerThread(FPipe);
end;


function TPipeListenThread.SafeSendMessage(AMsg : UINT;
    AWParam: WPARAM; ALParam : LPARAM) : LRESULT;
begin
    // Check notify window handle
    if IsWindow(FNotify) then
        // Send the message
        Result := SendMessage(FNotify, AMsg, AWParam, ALParam)
    else
        // Not a window
        Result := 0;
end;


procedure TPipeListenThread.Execute;
begin
    // Check sync base thread against the component main thread
    if not(Sync.SyncBaseTID = FNotifyThread) then
        // Post message to main window and we are done
        PostMessage(FNotify, WM_THREADCTX, 0, 0)
    else begin
        // Thread body
        while not(Terminated) do begin
            // Set default state
            FConnected := FALSE;
            // Attempt to create first pipe server instance
            if CreateServerPipe then begin
                // Connect the named pipe
                FConnected := ConnectNamedPipe(FPipe, @FOlapConnect);
                // Handle failure
                if not(FConnected) then begin
                    // Check the last error code
                    FErrorCode := GetLastError;
                    // Is pipe connected?
                    if (FErrorCode = ERROR_PIPE_CONNECTED) then
                        // Set connected state
                        FConnected := TRUE
                        // IO pending?
                    else if (FErrorCode = ERROR_IO_PENDING) then begin
                        // Wait for a connect or kill signal
                        case WaitForMultipleObjects(2, @FEvents, FALSE,
                            INFINITE) of
                            WAIT_FAILED :
                                FErrorCode := GetLastError;
                            WAIT_OBJECT_0 :
                                Terminate;
                            WAIT_OBJECT_0 + 1 :
                                FConnected := TRUE;
                        end;
                    end;
                end;
            end;
            // If we are not connected at this point then we had a failure
            if not(FConnected) then begin
                // Resource protection
                try
                    // No error if terminated or client connects / disconnects (no data)
                    if not(Terminated or (FErrorCode = ERROR_NO_DATA)) then
                        SafeSendMessage(WM_PIPEERROR_L, WPARAM(FPipe), LPARAM(FErrorCode));
                finally
                    // Close and clear
                    CloseHandleClear(FPipe);
                end;
            end
            else
                // Notify server of connect
                Synchronize(DoWorker);
        end;
    end;
end;


////////////////////////////////////////////////////////////////////////////////
// TThreadCounter
////////////////////////////////////////////////////////////////////////////////


constructor TThreadCounter.Create;
begin
    // Perform inherited
    inherited Create;

    // Create critical section lock
    InitializeCriticalSection(FLock);

    // Create event for empty state
    FEmpty := CreateEvent(nil, TRUE, TRUE, nil);

    // Set the starting count
    FCount := 0;
end;


destructor TThreadCounter.Destroy;
begin
    // Resource protection
    try
        // Close the event handle
        CloseHandleClear(FEmpty);
        // Delete the critical section
        DeleteCriticalSection(FLock);
    finally
        // Perform inherited
        inherited Destroy;
    end;
end;


function TThreadCounter.GetCount : Integer;
begin
    // Enter critical section
    EnterCriticalSection(FLock);

    // Resource protection
    try
        // Return the count
        Result := FCount;
    finally
        // Leave the critical section
        LeaveCriticalSection(FLock);
    end;
end;


procedure TThreadCounter.Increment;
begin
    // Enter critical section
    EnterCriticalSection(FLock);

    // Resource protection
    try
        // Increment the count
        Inc(FCount);
        // Reset the empty event
        ResetEvent(FEmpty);
    finally
        // Leave the critical section
        LeaveCriticalSection(FLock);
    end;
end;


procedure TThreadCounter.Decrement;
begin
    // Enter critical section
    EnterCriticalSection(FLock);

    // Resource protection
    try
        // Decrement the count
        if (FCount > 0) then
            Dec(FCount);
        // Signal empty event if count is zero
        if (FCount = 0) then
            SetEvent(FEmpty);
    finally
        // Leave the critical section
        LeaveCriticalSection(FLock);
    end;
end;


procedure TThreadCounter.WaitForEmpty;
begin
    // Wait until the empty event is signalled
    while (MsgWaitForMultipleObjects(1, FEmpty, FALSE, INFINITE, QS_SENDMESSAGE)
        = WAIT_OBJECT_0 + 1) do begin
        // Messages waiting to be read
        FlushMessages;
    end;
end;



////////////////////////////////////////////////////////////////////////////////
// TWriteQueue
////////////////////////////////////////////////////////////////////////////////


constructor TWriteQueue.Create;
begin
    // Perform inherited
    inherited Create;

    // Create mutex to allow for single access into the write queue
    FMutex := CreateMutex(nil, FALSE, nil);

    // Check mutex handle
    if (FMutex = 0) then
        // Raise exception
        RaiseWindowsError
    else begin
        // Create event to signal when we have data to write
        FDataEv := CreateEvent(nil, TRUE, FALSE, nil);
        // Check event handle
        if (FDataEv = 0) then
            // Raise exception
            RaiseWindowsError
        else begin
            // Create event to signal when the queue becomes empty
            FEmptyEv := CreateEvent(nil, TRUE, TRUE, nil);
            // Check event handle, raise exception on failure
            if (FEmptyEv = 0) then
                RaiseWindowsError;
        end;
    end;
end;


destructor TWriteQueue.Destroy;
begin
    // Resource protection
    try
        // Clear
        Clear;
        // Close the data event handle
        CloseHandleClear(FDataEv);
        // Close the empty event handle
        CloseHandleClear(FEmptyEv);
        // Close the mutex handle
        CloseHandleClear(FMutex);
    finally
        // Perform inherited
        inherited Destroy;
    end;
end;


function TWriteQueue.GetEmpty : Boolean;
begin
    // Determine if queue is empty
    Result := (FHead = nil);
end;


procedure TWriteQueue.Clear;
var
    lpNode : PWriteNode;
begin
    // Access the mutex
    WaitForSingleObject(FMutex, INFINITE);

    // Resource protection
    try
        // Reset the writer event
        ResetEvent(FDataEv);
        // Resource protection
        try
            // Resource protection
            try
                // Free all the items in the stack
                while Assigned(FHead) do begin
                    // Get the head node and push forward
                    lpNode := FHead;
                    // Resource protection
                    try
                        // Update head
                        FHead := lpNode^.NextNode;
                        // Free the pipe write data
                        DisposePipeWrite(lpNode^.PipeWrite);
                    finally
                        // Free the queued node
                        FreeMem(lpNode);
                    end;
                end;
            finally
                // Clear the tail
                FTail := nil;
                // Reset the data size
                FDataSize := 0;
            end;
        finally
            // Signal the empty event
            SetEvent(FEmptyEv);
        end;
    finally
        // Release the mutex
        ReleaseMutex(FMutex);
    end;
end;


function TWriteQueue.NodeSize(Node : PWriteNode) : LongWord;
begin
    // Result is at least size of TWriteNode plus allocator size
    Result := SizeOf(TWriteNode) + SizeOf(Integer);

    // Check pipe write
    if Assigned(Node^.PipeWrite) then begin
        // Include the pipe write structure
        Inc(Result, SizeOf(TPipeWrite) + SizeOf(Integer));
        // Include the pipe write data count
        Inc(Result, Node^.PipeWrite^.Count + SizeOf(Integer));
    end;
end;


function TWriteQueue.NewNode(PipeWrite : PPipeWrite) : PWriteNode;
begin
    // Allocate memory for new node
    GetMem(Result, SizeOf(TWriteNode));

    // Resource protection
    try
        // Set the pipe write field
        Result^.PipeWrite := PipeWrite;
        // Update the data count
        Inc(FDataSize, NodeSize(Result));
    finally
        // Make sure the next link is nil
        Result^.NextNode := nil;
    end;
end;


procedure TWriteQueue.EnqueueControlPacket(ControlCode : DWORD);
var
    lpControlMsg : TPipeMsgBlock;
begin
    // Access the mutex
    WaitForSingleObject(FMutex, INFINITE);

    // Resource protection
    try
        // Set control message constants
        lpControlMsg.Size       := SizeOf(TPipeMsgBlock);
        lpControlMsg.MagicStart := MB_MAGIC;
        lpControlMsg.MagicEnd   := MB_MAGIC;
        // Set end control message
        lpControlMsg.ControlCode := ControlCode;
        // Create pipe write and queue the data
        Enqueue(AllocPipeWrite(lpControlMsg, SizeOf(TPipeMsgBlock)));
    finally
        // Release the mutex
        ReleaseMutex(FMutex);
    end;
end;


procedure TWriteQueue.EnqueueEndPacket;
begin
    // Enqueue the start
    EnqueueControlPacket(MB_END);
end;


procedure TWriteQueue.EnqueueStartPacket;
begin
    // Enqueue the start
    EnqueueControlPacket(MB_START);
end;


procedure TWriteQueue.EnqueueMultiPacket(PipeWrite : PPipeWrite);
var
    lpData : PChar;
    dwSize : Integer;
begin
    // Access the mutex
    WaitForSingleObject(FMutex, INFINITE);

    // Resource protection
    try
        // Resource protection
        try
            // Resource protection
            try
                // Enqueue the start packet
                EnqueueStartPacket;
                // Get pointer to pipe write data
                lpData := PipeWrite^.Buffer;
                // While count of data to move
                while (PipeWrite^.Count > 0) do begin
                    // Determine packet size
                    if (PipeWrite^.Count > MAX_BUFFER) then
                        // Full packet size
                        dwSize := MAX_BUFFER
                    else
                        // Final packet
                        dwSize := PipeWrite^.Count;
                    // Resource protection
                    try
                        // Create pipe write and queue the data
                        Enqueue(AllocPipeWrite(lpData^, dwSize));
                        // Increment the data pointer
                        Inc(lpData, dwSize);
                    finally
                        // Decrement the remaining count
                        Dec(PipeWrite^.Count, dwSize);
                    end;
                end;
            finally
                // Enqueue the end packet
                EnqueueEndPacket;
            end;
        finally
            // Dispose of the original pipe write
            DisposePipeWrite(PipeWrite);
        end;
    finally
        // Release the mutex
        ReleaseMutex(FMutex);
    end;
end;


procedure TWriteQueue.UpdateState;
begin
    // Check head node
    if Assigned(FHead) then begin
        // Signal data event
        SetEvent(FDataEv);
        // Reset empty event
        ResetEvent(FEmptyEv);
    end
    else begin
        // Reset data event
        ResetEvent(FDataEv);
        // Signal empty event
        SetEvent(FEmptyEv);
    end;
end;


procedure TWriteQueue.Enqueue(PipeWrite : PPipeWrite);
var
    lpNode : PWriteNode;
begin
    // Access the mutex
    WaitForSingleObject(FMutex, INFINITE);

    // Resource protection
    try
        // Check pipe write
        if Assigned(PipeWrite) then begin
            // Resource protection
            try
                // Check count of bytes in the pipe write record
                if (PipeWrite^.Count > MAX_BUFFER) then
                    // Need to create multi packet message
                    EnqueueMultiPacket(PipeWrite)
                else begin
                    // Create a new node
                    lpNode := NewNode(PipeWrite);
                    // Resource protection
                    try
                        // Make this the last item in the queue
                        if Assigned(FTail) then
                            // Update the next node
                            FTail^.NextNode := lpNode
                        else
                            // Set the head node
                            FHead := lpNode;
                    finally
                        // Update the new tail
                        FTail := lpNode;
                    end;
                end;
            finally
                // Update event state
                UpdateState;
            end;
        end;
    finally
        // Release the mutex
        ReleaseMutex(FMutex);
    end;
end;


function TWriteQueue.Dequeue : PPipeWrite;
var
    lpNode : PWriteNode;
begin
    // Access the mutex
    WaitForSingleObject(FMutex, INFINITE);

    // Resource protection
    try
        // Resource protection
        try
            // Remove the first item from the queue
            if Assigned(FHead) then begin
                // Get head node
                lpNode := FHead;
                // Update the data count
                Dec(FDataSize, NodeSize(lpNode));
                // Resource protection
                try
                    // Set the return data
                    Result := lpNode^.PipeWrite;
                    // Does head = Tail?
                    if (FHead = FTail) then
                        FTail := nil;
                    // Update the head
                    FHead := lpNode^.NextNode;
                finally
                    // Free the memory for the node
                    FreeMem(lpNode);
                end;
            end
            else
                // No queued data
                Result := nil;
        finally
            // Update state
            UpdateState;
        end;
    finally
        // Release the mutex
        ReleaseMutex(FMutex);
    end;
end;



////////////////////////////////////////////////////////////////////////////////
// TPipeMultiMsg
////////////////////////////////////////////////////////////////////////////////


procedure TPipeMultiMsg.CreateTempBacking;
var
    lpszPath : array [0 .. MAX_PATH] of Char;
    lpszFile : array [0 .. MAX_PATH] of Char;
begin
    // Resource protection
    try
        // Attempt to get temp file
        if (GetTempPath(MAX_PATH, lpszPath) > 0) and
            (GetTempFileName(@lpszPath, MB_PREFIX, 0, @lpszFile) > 0) then
            // Open the temp file
            FHandle := CreateFile(@lpszFile, GENERIC_READ or GENERIC_WRITE, 0,
                nil, CREATE_ALWAYS, FILE_ATTRIBUTE_TEMPORARY or
                FILE_FLAG_DELETE_ON_CLOSE, 0)
        else
            // Failed to get temp filename
            FHandle := INVALID_HANDLE_VALUE;
    finally
        // If we failed to open a temp file then we will use memory for data backing
        if IsHandle(FHandle) then
            // Create handle stream
            FStream := THandleStream.Create(FHandle)
        else
            // Create fast memory stream
            FStream := TFastMemStream.Create;
    end;
end;


constructor TPipeMultiMsg.Create;
begin
    // Perform inherited
    inherited Create;

    // Create temp file backing
    CreateTempBacking;
end;


destructor TPipeMultiMsg.Destroy;
begin
    // Resource protection
    try
        // Free the stream
        FreeAndNil(FStream);
        // Close handle if open
        if IsHandle(FHandle) then
            CloseHandle(FHandle);
    finally
        // Perform inherited
        inherited Destroy;
    end;
end;



/// / TFastMemStream
////////////////////////////////////////////////////////////


function TFastMemStream.Realloc(var NewCapacity : NativeInt) : Pointer;
var
    dwDelta  : Integer;
    lpMemory : Pointer;
begin
    // Get current memory pointer
    lpMemory := Memory;

    // Resource protection
    try
        // Calculate the delta to be applied to the capacity
        if (NewCapacity > 0) then begin
            // Check new capacity
            if (NewCapacity > MaxWord) then
                // Delta is 1/4 of desired capacity
                dwDelta := NewCapacity div 4
            else
                // Minimum allocation of 64 KB
                dwDelta := MaxWord;
            // Update by delta
            Inc(NewCapacity, dwDelta);
        end;
        // Determine if capacity has changed
        if not(NewCapacity = Capacity) then begin
            // Check for nil alloc
            if (NewCapacity = 0) then begin
                // Release the memory
                FreeMem(lpMemory);
                // Clear result
                lpMemory := nil;
            end
            else begin
                // Check current capacity
                if (Capacity = 0) then
                    // Allocate memory
                    lpMemory := AllocMem(NewCapacity)
                else
                    // Reallocate memory
                    ReallocMem(lpMemory, NewCapacity);
            end;
        end;
    finally
        // Return modified pointer
        Result := lpMemory;
    end;
end;



////////////////////////////////////////////////////////////////////////////////
// Thread window procedure
////////////////////////////////////////////////////////////////////////////////


function ThreadWndProc(AWindow : HWND; AMsg, AWParam : WPARAM; ALParam : LPARAM): LRESULT; stdcall;
begin
    // Handle the window message
    case AMsg of
        // Exceute the method in thread
        CM_EXECPROC : begin
                // The lParam contains the thread sync information
                with TThreadSync(ALParam) do begin
                    // Set message result
                    Result := 0;
                    // Exception trap
                    try
                        // Clear the exception
                        FSyncRaise := nil;
                        // Call the method
                        FMethod;
                    except
{$IFNDEF DELPHI_6_ABOVE}
                        if not(RaiseList = nil) then begin
                            // Get exception object from frame
                            FSyncRaise := PRaiseFrame(RaiseList)^.ExceptObject;
                            // Clear frame exception object
                            PRaiseFrame(RaiseList)^.ExceptObject := nil;
                        end;
{$ELSE}
                        FSyncRaise := AcquireExceptionObject;
{$ENDIF}
                    end;
                end;
            end;
        // Thead destroying
        CM_DESTROYWINDOW : begin
                // Get instance of sync manager
                TSyncManager.Instance.DoDestroyWindow(TSyncInfo(ALParam));
                // Set message result
                Result := 0;
            end;
    else
        // Call the default window procedure
        Result := DefWindowProc(AWindow, AMsg, AWParam, ALParam);
    end;
end;



////////////////////////////////////////////////////////////////////////////////
// TSyncManager
////////////////////////////////////////////////////////////////////////////////


constructor TSyncManager.Create;
begin
    // Perform inherited
    inherited Create;

    // Initialize the critical section
    InitializeCriticalSection(FThreadLock);

    // Create the info list
    FList := TList.Create;
end;


destructor TSyncManager.Destroy;
var
    dwIndex : Integer;
begin
    // Resource protection
    try
        // Free all info records
        for dwIndex := Pred(FList.Count) downto 0 do
            FreeSyncInfo(TSyncInfo(FList[dwIndex]));
        // Free the list
        FList.Free;
        // Delete the critical section
        DeleteCriticalSection(FThreadLock);
    finally
        // Call inherited
        inherited Destroy;
    end;
end;


class function TSyncManager.Instance : TSyncManager;
begin
    // Enter critical section
    EnterCriticalSection(InstCritSect);

    // Resource protection
    try
        // Check global instance, create if needed
        if (SyncManager = nil) then
            SyncManager := TSyncManager.Create;
        // Return instance of sync manager
        Result := SyncManager
    finally
        // Leave critical section
        LeaveCriticalSection(InstCritSect);
    end;
end;


function TSyncManager.AllocateWindow : HWND;
var
    clsTemp   : TWndClass;
    bClassReg : Boolean;
begin
    // Set instance handle
    ThreadWndClass.hInstance   := hInstance;
    ThreadWndClass.lpfnWndProc := @ThreadWndProc;

    // Attempt to get class info
    bClassReg := GetClassInfo(hInstance, ThreadWndClass.lpszClassName, clsTemp);

    // Ensure the class is registered and the window procedure is the default window proc
    if not(bClassReg) or not(clsTemp.lpfnWndProc = @ThreadWndProc) then begin
        // Unregister if already registered
        if bClassReg then
            Windows.UnregisterClass(ThreadWndClass.lpszClassName, hInstance);
        // Register
        Windows.RegisterClass(ThreadWndClass);
    end;

    // Create the thread window
    Result := CreateWindowEx(0, ThreadWndClass.lpszClassName, '', 0, 0, 0, 0, 0,
        0, 0, hInstance, nil);
end;


procedure TSyncManager.AddThread(ThreadSync : TThreadSync);
var
    lpInfo : TSyncInfo;
begin
    // Enter critical section
    EnterCriticalSection(FThreadLock);

    // Resource protection
    try
        // Find the info using the base thread id
        lpInfo := FindSyncInfo(ThreadSync.SyncBaseTID);
        // Resource protection
        try
            // Check assignment
            if (lpInfo = nil) then begin
                // Create new info record
                lpInfo := TSyncInfo.Create;
                // Set base thread id
                lpInfo.FSyncBaseTID := ThreadSync.SyncBaseTID;
                // Add info to list
                FList.Add(lpInfo);
            end;
            // Check thread count, create window if needed
            if (lpInfo.FThreadCount = 0) then
                lpInfo.FThreadWindow := AllocateWindow;
        finally
            // Increment the thread count
            Inc(lpInfo.FThreadCount);
        end;
    finally
        // Leave the critical section
        LeaveCriticalSection(FThreadLock);
    end;
end;


procedure TSyncManager.RemoveThread(ThreadSync : TThreadSync);
var
    lpInfo : TSyncInfo;
begin
    // Enter critical section
    EnterCriticalSection(FThreadLock);

    // Resource protection
    try
        // Find the info using the base thread id
        lpInfo := FindSyncInfo(ThreadSync.SyncBaseTID);
        // Check assignment
        if Assigned(lpInfo) then
            PostMessage(lpInfo.FThreadWindow, CM_DESTROYWINDOW, 0,
                Longint(lpInfo));
    finally
        // Leave the critical section
        LeaveCriticalSection(FThreadLock);
    end;
end;


procedure TSyncManager.DoDestroyWindow(Info : TSyncInfo);
begin
    // Enter critical section
    EnterCriticalSection(FThreadLock);

    // Resource protection
    try
        // Decrement the thread count
        Dec(Info.FThreadCount);
        // Check for zero threads
        if (Info.FThreadCount = 0) then
            FreeSyncInfo(Info);
    finally
        // Leave the critical section
        LeaveCriticalSection(FThreadLock);
    end;
end;


procedure TSyncManager.FreeSyncInfo(Info : TSyncInfo);
begin
    // Check thread window
    if not(Info.FThreadWindow = 0) then begin
        // Resource protection
        try
            // Destroy window
            DestroyWindow(Info.FThreadWindow);
            // Remove from list
            FList.Remove(Info);
        finally
            // Free the class structure
            Info.Free;
        end;
    end;
end;


procedure TSyncManager.Synchronize(ThreadSync : TThreadSync);
var
    lpInfo : TSyncInfo;
begin
    // Find the info using the base thread id
    lpInfo := FindSyncInfo(ThreadSync.SyncBaseTID);

    // Check assignment, send message to thread window
    if Assigned(lpInfo) then
        SendMessage(lpInfo.FThreadWindow, CM_EXECPROC, 0, Longint(ThreadSync));
end;


function TSyncManager.FindSyncInfo(SyncBaseTID : LongWord) : TSyncInfo;
var
    dwIndex : Integer;
begin
    // Set default result
    Result := nil;

    // Locate in list
    for dwIndex := 0 to Pred(FList.Count) do begin
        // Compare thread id's
        if (TSyncInfo(FList[dwIndex]).FSyncBaseTID = SyncBaseTID) then begin
            // Found the info structure
            Result := TSyncInfo(FList[dwIndex]);
            // Done processing
            break;
        end;
    end;
end;



////////////////////////////////////////////////////////////////////////////////
// TThreadSync
////////////////////////////////////////////////////////////////////////////////


constructor TThreadSync.Create;
begin
    // Perform inherited
    inherited Create;

    // Set the base thread id
    FSyncBaseTID := GetCurrentThreadID;

    // Add self to sync manager
    TSyncManager.Instance.AddThread(Self);
end;


destructor TThreadSync.Destroy;
begin
    // Resource protection
    try
        // Remove self from sync manager
        TSyncManager.Instance.RemoveThread(Self);
    finally
        // Perform inherited
        inherited Destroy;
    end;
end;


procedure TThreadSync.Synchronize(Method : TThreadMethod);
begin
    // Clear sync raise exception object
    FSyncRaise := nil;

    // Set the method pointer
    FMethod := Method;

    // Resource protection
    try
        // Have the sync manager call the method
        TSyncManager.Instance.Synchronize(Self);
    finally
        // Check to see if the exception object was set
        if Assigned(FSyncRaise) then
            raise FSyncRaise;
    end;
end;



////////////////////////////////////////////////////////////////////////////////
// TThreadEx
////////////////////////////////////////////////////////////////////////////////


constructor TThreadEx.Create(CreateSuspended : Boolean);
begin
    // Create the sync
    FSync := TThreadSync.Create;

    // Perform inherited
    inherited Create(CreateSuspended);
end;


destructor TThreadEx.Destroy;
begin
    // Resource protection
    try
        // Free the sync object
        FSync.Free;
    finally
        // Perform inherited
        inherited Destroy;
    end;
end;


procedure TThreadEx.DoTerminate;
begin
    // Overide the DoTerminate and don't call inherited
    if Assigned(OnTerminate) then
        Sync.Synchronize(HandleTerminate);
end;


procedure TThreadEx.HandleTerminate;
begin
    // Call OnTerminate if assigned
    if Assigned(OnTerminate) then
        OnTerminate(Self);
end;


procedure TThreadEx.Run;
begin
  {$IFDEF CONDITIONALEXPRESSIONS}
    {$IF COMPILERVERSION >= 21} // Delphi 2010 +
      inherited Start;
    {$ELSE}
      inherited Resume;
    {$IFEND}
  {$ELSE}
    inherited Resume;
  {$ENDIF}
end;


procedure TThreadEx.Synchronize(Method : TThreadMethod);
begin
    // Call the sync's version of synchronize
    Sync.Synchronize(Method);
end;


procedure TThreadEx.SafeSynchronize(Method : TThreadMethod);
begin
    // Exception trap
    try
        // Call synchronize
        Sync.Synchronize(Method);
    except
        // Eat the actual exception, just call terminate on the thread
        Terminate;
    end;
end;


procedure TThreadEx.Wait;
var
    hThread : THandle;
    dwExit  : DWORD;
begin
    // Set the thread handle
    hThread := Handle;

    // Check current thread against the sync thread id
    if (GetCurrentThreadID = Sync.SyncBaseTID) then begin
        // Message wait
        while (MsgWaitForMultipleObjects(1, hThread, FALSE, INFINITE,
            QS_ALLINPUT) = WAIT_OBJECT_0 + 1) do begin
            // Flush the messages
            FlushMessages;
            // Check thread state (because the handle is not duplicated, it can become invalid. Testing
            // WaitForSingleObject(Handle, 0) even returns WAIT_TIMEOUT for the invalid handle)
            if not(GetExitCodeThread(hThread, dwExit)) or
                not(dwExit = STILL_ACTIVE) then
                break;
        end;
    end
    else
        // Wait is not being called from base thread id, so use WaitForSingleObject
        WaitForSingleObject(hThread, INFINITE);
end;



////////////////////////////////////////////////////////////////////////////////
// Console helper functions
////////////////////////////////////////////////////////////////////////////////


type
    TConsoleEvent = function(dwCtrlEvent : DWORD; dwProcessGroupId : DWORD)
                              : BOOL; stdcall;
    TConsoleHwnd = function() : HWND; stdcall;


function ConsoleWindow(ConsoleHwnd : TConsoleHwnd) : HWND; stdcall;
begin
    // Check function pointer
    if Assigned(@ConsoleHwnd) then
        // Call function
        Result := ConsoleHwnd()
    else
        // Return zero
        Result := 0;
end;


function GetConsoleWindow(ProcessHandle : THandle) : HWND;
var
    lpConsoleHwnd : Pointer;
    hThread       : THandle;
    dwSize        : SIZE_T;
    dwWrite       : SIZE_T;
    dwExit        : DWORD;
begin
    // Get size of function that we need to inject
    dwSize := PChar(@GetConsoleWindow) - PChar(@ConsoleWindow);

    // Allocate memory in remote process
    lpConsoleHwnd := VirtualAllocEx(ProcessHandle, nil, dwSize, MEM_COMMIT,
        PAGE_EXECUTE_READWRITE);

    // Check memory, write code from this process
    if Assigned(lpConsoleHwnd) then begin
        // Write memory
        WriteProcessMemory(ProcessHandle, lpConsoleHwnd, @ConsoleWindow,
            dwSize, dwWrite);
        // Resource protection
        try
            // Create remote thread starting at the injected function, passing in the address to GetConsoleWindow
            hThread := CreateRemoteThread(ProcessHandle, nil, 0, lpConsoleHwnd,
                GetProcAddress(GetModuleHandle(kernel32), 'GetConsoleWindow'),
                0, DWORD(Pointer(nil)^));
            // Check thread
            if (hThread = 0) then
                // Failed to create thread
                Result := 0
            else begin
                // Resource protection
                try
                    // Wait for the thread to complete
                    WaitForSingleObject(hThread, INFINITE);
                    // Get the exit code from the thread
                    if GetExitCodeThread(hThread, dwExit) then
                        // Set return
                        Result := dwExit
                    else
                        // Failed to get exit code
                        Result := 0;
                finally
                    // Close the thread handle
                    CloseHandle(hThread);
                end;
            end;
        finally
            // Free allocated memory
            VirtualFreeEx(ProcessHandle, lpConsoleHwnd, 0, MEM_RELEASE);
        end;
    end
    else
        // Failed to create remote injected function
        Result := 0;
end;


function GetConsoleWindowEx(ProcessHandle : THandle;
    ProcessID, ThreadID : DWORD) : HWND;
var
    lpConInfo : TPipeConsoleInfo;
begin
    // Call the optimal routine first
    Result := GetConsoleWindow(ProcessHandle);

    // Check return handle
    if (Result = 0) then begin
        // Clear the window handle
        lpConInfo.Window := 0;
        // Resource protection
        try
            // Set process info
            lpConInfo.ProcessID := ProcessID;
            lpConInfo.ThreadID  := ThreadID;
            // Enumerate the windows on the console thread
            EnumWindows(@EnumConsoleWindows, Integer(@lpConInfo));
        finally
            // Return the window handle
            Result := lpConInfo.Window;
        end;
    end;
end;


function CtrlBreak(ConsoleEvent : TConsoleEvent) : DWORD; stdcall;
begin
    // Generate the control break
    Result := DWORD(ConsoleEvent(CTRL_BREAK_EVENT, 0));
end;


function CtrlC(ConsoleEvent : TConsoleEvent) : DWORD; stdcall;
begin
    // Generate the control break
    Result := DWORD(ConsoleEvent(CTRL_C_EVENT, 0));
end;


function ExecConsoleEvent(ProcessHandle : THandle; Event : DWORD) : Boolean;
var
    lpCtrlEvent : Pointer;
    hThread     : THandle;
    dwSize      : DWORD;
    dwWrite     : SIZE_T;
    dwExit      : DWORD;
begin
    // Check event
    case Event of
        // Control C
        CTRL_C_EVENT : begin
                // Get size of function that we need to inject
                dwSize := PChar(@ExecConsoleEvent) - PChar(@CtrlC);
                // Allocate memory in remote process
                lpCtrlEvent := VirtualAllocEx(ProcessHandle, nil, dwSize,
                    MEM_COMMIT, PAGE_EXECUTE_READWRITE);
                // Check memory, write code from this process
                if Assigned(lpCtrlEvent) then
                    WriteProcessMemory(ProcessHandle, lpCtrlEvent, @CtrlC,
                        dwSize, dwWrite);
            end;
        // Control break
        CTRL_BREAK_EVENT : begin
                // Get size of function that we need to inject
                dwSize := PChar(@CtrlC) - PChar(@CtrlBreak);
                // Allocate memory in remote process
                lpCtrlEvent := VirtualAllocEx(ProcessHandle, nil, dwSize,
                    MEM_COMMIT, PAGE_EXECUTE_READWRITE);
                // Check memory, write code from this process
                if Assigned(lpCtrlEvent) then
                    WriteProcessMemory(ProcessHandle, lpCtrlEvent, @CtrlBreak,
                        dwSize, dwWrite);
            end;
    else
        // Not going to handle
        lpCtrlEvent := nil;
    end;

    // Check remote function address
    if Assigned(lpCtrlEvent) then begin
        // Resource protection
        try
            // Create remote thread starting at the injected function, passing in the address to GenerateConsoleCtrlEvent
            hThread := CreateRemoteThread(ProcessHandle, nil, 0, lpCtrlEvent,
                GetProcAddress(GetModuleHandle(kernel32),
                'GenerateConsoleCtrlEvent'), 0, DWORD(Pointer(nil)^));
            // Check thread
            if (hThread = 0) then
                // Failed to create thread
                Result := FALSE
            else begin
                // Resource protection
                try
                    // Wait for the thread to complete
                    WaitForSingleObject(hThread, INFINITE);
                    // Get the exit code from the thread
                    if GetExitCodeThread(hThread, dwExit) then
                        // Set return
                        Result := not(dwExit = 0)
                    else
                        // Failed to get exit code
                        Result := FALSE;
                finally
                    // Close the thread handle
                    CloseHandle(hThread);
                end;
            end;
        finally
            // Free allocated memory
            VirtualFreeEx(ProcessHandle, lpCtrlEvent, 0, MEM_RELEASE);
        end;
    end
    else
        // Failed to create remote injected function
        Result := FALSE;
end;


procedure ExitProcessEx(ProcessHandle : THandle; ExitCode : DWORD);
var
    hKernel : HMODULE;
    hThread : THandle;
begin
    // Get handle to kernel32
    hKernel := GetModuleHandle(kernel32);

    // Check handle
    if not(hKernel = 0) then begin
        // Create a remote thread in the external process and have it call ExitProcess (tricky)
        hThread := CreateRemoteThread(ProcessHandle, nil, 0,
            GetProcAddress(hKernel, 'ExitProcess'), Pointer(ExitCode), 0,
            DWORD(Pointer(nil)^));
        // Check the thread handle
        if (hThread = 0) then
            // Just terminate the process
            TerminateProcess(ProcessHandle, ExitCode)
        else begin
            // Resource protection
            try
                // Wait for the thread to complete
                WaitForSingleObject(hThread, INFINITE);
            finally
                // Close the handle
                CloseHandle(hThread);
            end;
        end;
    end
    else
        // Attempt to use the process handle from the create process call
        TerminateProcess(ProcessHandle, ExitCode);
end;



////////////////////////////////////////////////////////////////////////////////
// Pipe helper functions
////////////////////////////////////////////////////////////////////////////////


procedure ClearOverlapped(var Overlapped : TOverlapped;
    ClearEvent : Boolean = FALSE);
begin
    // Check to see if all fields should be clered
    if ClearEvent then
        // Clear whole structure
        FillChar(Overlapped, SizeOf(Overlapped), 0)
    else begin
        // Clear all fields except for the event handle
        Overlapped.Internal     := 0;
        Overlapped.InternalHigh := 0;
        Overlapped.Offset       := 0;
        Overlapped.OffsetHigh   := 0;
    end;
end;


procedure CloseHandleClear(var Handle : THandle);
begin
    // Resource protection
    try
        // Check for invalid handle or zero
        if IsHandle(Handle) then
            CloseHandle(Handle);
    finally
        // Set to invalid handle
        Handle := INVALID_HANDLE_VALUE;
    end;
end;


procedure CloseHandleClear(var Handle : HPIPE);
begin
    CloseHandleClear(THandle(Handle));
end;


procedure DisconnectAndClose(Pipe : HPIPE; IsServer : Boolean = TRUE);
begin
    // Check handle
    if IsHandle(Pipe) then begin
        // Resource protection
        try
            // Cancel overlapped IO on the handle
            CancelIO(Pipe);
            // Flush file buffer
            FlushFileBuffers(Pipe);
            // Disconnect the server end of the named pipe if flag is set
            if IsServer then
                DisconnectNamedPipe(Pipe);
        finally
            // Close the pipe handle
            CloseHandle(Pipe);
        end;
    end;
end;


procedure RaiseWindowsError;
begin
{$IFDEF DELPHI_6_ABOVE}
    RaiseLastOSError;
{$ELSE}
    RaiseLastWin32Error;
{$ENDIF}
end;


procedure FlushMessages;
var
    lpMsg : TMsg;
begin
    // Flush the message queue for the calling thread
    while PeekMessage(lpMsg, 0, 0, 0, PM_REMOVE) do begin
        // Translate the message
        TranslateMessage(lpMsg);
        // Dispatch the message
        DispatchMessage(lpMsg);
        // Allow other threads to run
        Sleep(0);
    end;
end;


function IsHandle(Handle : THandle) : Boolean;
begin
    // Determine if a valid handle (only by value)
    Result := not((Handle = 0) or (Handle = INVALID_HANDLE_VALUE));
end;


function ComputerName : string;
var
    dwSize : DWORD;
begin
    // Set max size
    dwSize := Succ(MAX_PATH);

    // Resource protection
    try
        // Set string length
        SetLength(Result, dwSize);
        // Attempt to get the computer name
        if not(GetComputerName(@Result[1], dwSize)) then
            dwSize := 0;
    finally
        // Truncate string
        SetLength(Result, dwSize);
    end;
end;


function AllocPipeWriteWithPrefix(const Prefix; PrefixCount : Integer;
    const Buffer; Count : Integer) : PPipeWrite;
var
    lpBuffer : PChar;
begin
    // Allocate memory for the result
    Result := AllocMem(SizeOf(TPipeWrite));

    // Set the count of the buffer
    Result^.Count := PrefixCount + Count;

    // Allocate enough memory to store the prefix and data buffer
    Result^.Buffer := AllocMem(Result^.Count);

    // Set buffer pointer
    lpBuffer := Result^.Buffer;

    // Resource protection
    try
        // Move the prefix data in
        System.Move(Prefix, lpBuffer^, PrefixCount);
        // Increment the buffer position
        Inc(lpBuffer, PrefixCount);
    finally
        // Move the buffer data in
        System.Move(Buffer, lpBuffer^, Count);
    end;
end;


function AllocPipeWrite(const Buffer; Count : Integer) : PPipeWrite;
begin
    // Allocate memory for the result
    Result := AllocMem(SizeOf(TPipeWrite));

    // Resource protection
    try
        // Set the count of the buffer
        Result^.Count := Count;
        // Allocate enough memory to store the data buffer
        Result^.Buffer := AllocMem(Count);
    finally
        // Move data to the buffer
        System.Move(Buffer, Result^.Buffer^, Count);
    end;
end;


procedure DisposePipeWrite(var PipeWrite : PPipeWrite);
begin
    // Check pointer
    if Assigned(PipeWrite) then begin
        // Resource protection
        try
            // Resource protection
            try
                // Dispose of the memory being used by the pipe write structure
                if Assigned(PipeWrite^.Buffer) then
                    FreeMem(PipeWrite^.Buffer);
            finally
                // Free the memory record
                FreeMem(PipeWrite);
            end;
        finally
            // Clear the pointer
            PipeWrite := nil;
        end;
    end;
end;


function EnumConsoleWindows(Window : HWND; lParam : Integer) : BOOL; stdcall;
var
    lpConInfo : PPipeConsoleInfo;
begin
    // Get the console info
    lpConInfo := Pointer(lParam);

    // Get the thread id and compare against the passed structure
    if (lpConInfo^.ThreadID = GetWindowThreadProcessId(Window, nil)) then begin
        // Found the window, return the handle
        lpConInfo^.Window := Window;
        // Stop enumeration
        Result := FALSE;
    end
    else
        // Keep enumerating
        Result := TRUE;
end;


procedure CheckPipeName(Value : string);
begin
    // Validate the pipe name
    if (Pos('\', Value) > 0) or (Length(Value) > MAX_NAME) or (Length(Value) = 0)
    then
        raise EPipeException.CreateRes(@resBadPipeName);
end;



////////////////////////////////////////////////////////////////////////////////
// Security helper functions
////////////////////////////////////////////////////////////////////////////////


procedure InitializeSecurity(var SA : TSecurityAttributes);
var
    sd : PSecurityDescriptor;
begin
    // Allocate memory for the security descriptor
    sd := AllocMem(SECURITY_DESCRIPTOR_MIN_LENGTH);

    // Initialize the new security descriptor
    if InitializeSecurityDescriptor(sd, SECURITY_DESCRIPTOR_REVISION) then begin
        // Add a NULL descriptor ACL to the security descriptor
        if SetSecurityDescriptorDacl(sd, TRUE, nil, FALSE) then begin
            // Set up the security attributes structure
            SA.nLength              := SizeOf(TSecurityAttributes);
            SA.lpSecurityDescriptor := sd;
            SA.bInheritHandle       := TRUE;
        end
        else
            // Failed to init the sec descriptor
            RaiseWindowsError;
    end
    else
        // Failed to init the sec descriptor
        RaiseWindowsError;
end;


procedure FinalizeSecurity(var SA : TSecurityAttributes);
begin
    // Release memory that was assigned to security descriptor
    if Assigned(SA.lpSecurityDescriptor) then begin
        // Reource protection
        try
            // Free memory
            FreeMem(SA.lpSecurityDescriptor);
        finally
            // Clear pointer
            SA.lpSecurityDescriptor := nil;
        end;
    end;
end;






procedure CreateMessageQueue;
var
    lpMsg : TMsg;
begin
    // Spin a message queue
    PeekMessage(lpMsg, 0, WM_USER, WM_USER, PM_NOREMOVE);
end;


initialization

// Initialize the critical section for instance handling
InitializeCriticalSection(InstCritSect);

// If this is a console application then create a message queue
if IsConsole then
    CreateMessageQueue;

finalization

// Check sync manager
if Assigned(SyncManager) then
    FreeAndNil(SyncManager);

// Delete the critical section for instance handling
DeleteCriticalSection(InstCritSect);

end.

