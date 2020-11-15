unit HotKey.Handler;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.Classes, System.SysUtils,
  System.Generics.Collections, System.Generics.Defaults,
  HotKey;

type
  THotKeyEvent = procedure(Sender: TObject; Index: THotKeyIndex) of object;
  TEnabledEvent = procedure(Sender: TObject; Enable: Boolean) of object;
  THotKeyHendler = class
  private
    FMsgWnd: HWND;
    FHotKeyDict: TDictionary<THotKeyIndex, THotKeyValue>;
    FEnabled: Boolean;
    FOnEnabled: TEnabledEvent;
    FOnHotKey: THotKeyEvent;
    FOnChange: THotKeyEvent;
                 
    procedure MsgWndHandle(var Msg: TMessage);
    
    procedure SetEnabled(const Value: Boolean);
    function GetHotKey(Index: THotKeyIndex): THotKeyValue;
    procedure SetOnEnabled(const Value: TEnabledEvent);
  public
    constructor Create;
    destructor Destroy; override;

    procedure RegisterHotKey(Index: THotKeyIndex; Value: THotKeyValue);
    procedure UnregisterHotKey(Index: THotKeyIndex);

    property Enabled: Boolean read FEnabled write SetEnabled;
    property HotKey[Index: THotKeyIndex]: THotKeyValue read GetHotKey;
    property OnEnabled: TEnabledEvent read FOnEnabled write SetOnEnabled;
    property OnHotKey: THotKeyEvent read FOnHotKey write FOnHotKey;
    property OnChange: THotKeyEvent read FOnChange write FOnChange;
  end;

implementation

{ THotKeyHendler }

constructor THotKeyHendler.Create;
begin
  inherited Create;
  FEnabled := False;
  FHotKeyDict := TDictionary<THotKeyIndex, THotKeyValue>.Create;
end;

destructor THotKeyHendler.Destroy;
begin
  Enabled := False;
  FHotKeyDict.Free;
  inherited;
end;

procedure THotKeyHendler.MsgWndHandle(var Msg: TMessage);
begin
  Msg.Result := DefWindowProc(FMsgWnd, Msg.Msg, Msg.WParam, Msg.LParam);

  if Msg.Msg <> WM_HOTKEY then Exit;
  if not FHotKeyDict.ContainsKey(THotKeyIndex(Msg.WParam)) then Exit;

  if Assigned(FOnHotKey) then
    FOnHotKey(Self, THotKeyIndex(Msg.WParam));
end;

procedure THotKeyHendler.RegisterHotKey(Index: THotKeyIndex; Value: THotKeyValue);
begin
  if FEnabled then
  begin
    if FHotKeyDict.Count = 0 then
      FMsgWnd := AllocateHWnd(MsgWndHandle);

    Winapi.Windows.RegisterHotKey(FMsgWnd, Index, Value.fuModifiers, Value.uVirtKey);
  end;
  FHotKeyDict.AddOrSetValue(Index, Value);

  if Assigned(FOnChange) then
    FOnChange(Self, Index);
end;  

procedure THotKeyHendler.UnregisterHotKey(Index: THotKeyIndex);
begin
  if not FHotKeyDict.ContainsKey(Index) then Exit;

  FHotKeyDict.Remove(Index);
  if FEnabled then
  begin
    Winapi.Windows.UnregisterHotKey(FMsgWnd, Index);
    if FHotKeyDict.Count = 0 then
      DeallocateHWnd(FMsgWnd);
  end;
end;

procedure THotKeyHendler.SetEnabled(const Value: Boolean);
var
  Pair: TPair<THotKeyIndex, THotKeyValue>;
  Key: THotKeyIndex;
begin
  if FEnabled = Value then Exit;
  FEnabled := Value;

  if FEnabled then
  begin
    if FHotKeyDict.Count > 0 then
      FMsgWnd := AllocateHWnd(MsgWndHandle);

    for Pair in FHotKeyDict do    
      Winapi.Windows.RegisterHotKey(FMsgWnd, Pair.Key, Pair.Value.fuModifiers, Pair.Value.uVirtKey);
  end
  else
  begin
    for Key in FHotKeyDict.Keys do    
      Winapi.Windows.UnregisterHotKey(FMsgWnd, Key);

    if FHotKeyDict.Count > 0 then
      DeallocateHWnd(FMsgWnd);
  end;

  if Assigned(FOnEnabled) then
    FOnEnabled(Self, FEnabled);
end;

procedure THotKeyHendler.SetOnEnabled(const Value: TEnabledEvent);
begin
  FOnEnabled := Value;
  if Assigned(FOnEnabled) then
    FOnEnabled(Self, FEnabled);
end;

function THotKeyHendler.GetHotKey(Index: THotKeyIndex): THotKeyValue;
begin
  if not FHotKeyDict.TryGetValue(Index, Result) then
    Result := THotKeyValue.Empty;
end;

end.
