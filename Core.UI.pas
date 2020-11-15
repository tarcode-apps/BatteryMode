unit Core.UI;

interface

uses
  Winapi.Windows,
  System.SysUtils, System.Classes,
  Vcl.Controls;

type
  { Интерфейсы }

  /// Locker
  ILocker = interface
    function _GetIsLocked: Boolean;

    procedure Lock;
    procedure Unlock;

    property IsLocked: Boolean read _GetIsLocked;
  end;

  /// SizeSelector
  ISizeSelector = interface
    function _GetSize: Integer;

    function Add(Size: Integer): Integer;
    function AddControl(Control: TControl): Integer;
    function AddPadding(Control: TWinControl): Integer;
    function Select(Size: Integer): Integer;
    function SelectWithMargins(Size: Integer; Control: TControl): Integer;
    function SelectControl(Control: TControl): Integer;

    property Size: Integer read _GetSize;
  end;

  /// SizeAccumulator
  ISizeAccumulator = interface
    function _GetSize: Integer;

    function Add(Size: Integer): Integer;
    function AddPadding(Control: TWinControl): Integer;
    function AddControl(Control: TControl): Integer;

    function NextControlFront(Control: TControl): Integer;
    property Size: Integer read _GetSize;
  end;

  /// ModifyCollector
  TModifyEvent = procedure(Sender: TObject; var Modify: Boolean) of object;
  IModifyCollector = interface
    function _GetIsModify: Boolean;
    procedure _SetOnModify(const Value: TModifyEvent);
    function _GetOnModify: TModifyEvent;

    procedure Modify;
    procedure UnModify;
    property IsModify: Boolean read _GetIsModify;
    property OnModify: TModifyEvent read _GetOnModify write _SetOnModify;
  end;

  { Классы }

  /// Locker
  TLocker = class(TInterfacedObject, ILocker)
  strict private
    FLockCount: Integer;
    function _GetIsLocked: Boolean; inline;
  public
    constructor Create(Locked: Boolean = False); reintroduce;

    procedure Lock; inline;
    procedure Unlock; inline;
  end;

  TSizeType = (stMax, stMin);
  /// THeightSelector
  THeightSelector = class(TInterfacedObject, ISizeSelector)
  strict private
    FSizeType: TSizeType;
    FAdditionalSize: Integer;
    FSizeValue: Integer;
    function _GetSize: Integer; inline;
  public
    constructor Create(SizeType: TSizeType = stMax); overload;
    constructor Create(AdditionalSize: Integer; SizeType: TSizeType = stMax); overload;

    function Add(Size: Integer): Integer; inline;
    function AddControl(Control: TControl): Integer; inline;
    function AddPadding(Control: TWinControl): Integer; inline;
    function Select(Size: Integer): Integer; inline;
    function SelectWithMargins(Size: Integer; Control: TControl): Integer; inline;
    function SelectControl(Control: TControl): Integer; inline;

    property Size: Integer read _GetSize;
  end;

  /// TWidthSelector
  TWidthSelector = class(TInterfacedObject, ISizeSelector)
  strict private
    FSizeType: TSizeType;
    FAdditionalSize: Integer;
    FSizeValue: Integer;
    function _GetSize: Integer; inline;
  public
    constructor Create(SizeType: TSizeType = stMax); overload;
    constructor Create(AdditionalSize: Integer; SizeType: TSizeType = stMax); overload;

    function Add(Size: Integer): Integer; inline;
    function AddControl(Control: TControl): Integer; inline;
    function AddPadding(Control: TWinControl): Integer; inline;
    function Select(Size: Integer): Integer; inline;
    function SelectWithMargins(Size: Integer; Control: TControl): Integer; inline;
    function SelectControl(Control: TControl): Integer; inline;

    property Size: Integer read _GetSize;
  end;

  /// THeightAccumulator
  THeightAccumulator = class(TInterfacedObject, ISizeAccumulator)
  strict private
    FSizeValue: Integer;
    function _GetSize: Integer; inline;
  public
    constructor Create; overload;
    constructor Create(Size: Integer); overload;

    function Add(Size: Integer): Integer; inline;
    function AddPadding(Control: TWinControl): Integer; inline;
    function AddControl(Control: TControl): Integer; inline;

    function NextControlFront(Control: TControl): Integer;
    property Size: Integer read _GetSize;
  end;

  /// TWidthAccumulator
  TWidthAccumulator = class(TInterfacedObject, ISizeAccumulator)
  strict private
    FSizeValue: Integer;
    function _GetSize: Integer; inline;
  public
    constructor Create; overload;
    constructor Create(Size: Integer); overload;

    function Add(Size: Integer): Integer; inline;
    function AddPadding(Control: TWinControl): Integer; inline;
    function AddControl(Control: TControl): Integer; inline;

    function NextControlFront(Control: TControl): Integer;
    property Size: Integer read _GetSize;
  end;

  /// TModifyCollector
  TModifyCollector = class(TInterfacedObject, IModifyCollector)
  private
    FIsModify: Boolean;
    FOnModify: TModifyEvent;
    procedure _SetOnModify(const Value: TModifyEvent); inline;
    function _GetOnModify: TModifyEvent; inline;
    function _GetIsModify: Boolean; inline;
  public
    constructor Create(Modify: Boolean = False); reintroduce;
    procedure Modify; inline;
    procedure UnModify; inline;
    property IsModify: Boolean read _GetIsModify;
    property OnModify: TModifyEvent read _GetOnModify write _SetOnModify;
  end;

implementation

{ TLocker }

constructor TLocker.Create(Locked: Boolean = False);
begin
  inherited Create;
  if Locked then FLockCount := 1 else FLockCount := 0;
end;

procedure TLocker.Lock;
begin
  Inc(FLockCount, 1);
end;

procedure TLocker.Unlock;
begin
  if FLockCount > 0 then
    Dec(FLockCount, 1);
end;

function TLocker._GetIsLocked: Boolean;
begin
  Result := FLockCount > 0;
end;

{ THeightSelector }

constructor THeightSelector.Create(SizeType: TSizeType);
begin
  Create(0, SizeType);
end;

constructor THeightSelector.Create(AdditionalSize: Integer; SizeType: TSizeType);
begin
  inherited Create;
  FAdditionalSize := AdditionalSize;
  FSizeType := SizeType;

  case SizeType of
    stMax: FSizeValue := 0;
    stMin: FSizeValue := Integer.MaxValue;
    else raise Exception.Create('Unsupported SizeType');
  end;
end;

function THeightSelector.Add(Size: Integer): Integer;
begin
  Inc(FAdditionalSize, Size);
  Result := FAdditionalSize + FSizeValue;
end;

function THeightSelector.AddControl(Control: TControl): Integer;
begin
  Result := Add(Control.Margins.ExplicitHeight);
end;

function THeightSelector.AddPadding(Control: TWinControl): Integer;
begin
  Inc(FAdditionalSize, Control.Padding.Top + Control.Padding.Bottom);
  Result := FAdditionalSize + FSizeValue;
end;

function THeightSelector.Select(Size: Integer): Integer;
begin
  case FSizeType of
    stMax: if Size > FSizeValue then FSizeValue := Size;
    stMin: if Size < FSizeValue then FSizeValue := Size;
  end;

  Result := FSizeValue;
end;

function THeightSelector.SelectWithMargins(Size: Integer;
  Control: TControl): Integer;
begin
  if Control.AlignWithMargins and (Control.Parent <> nil) then
    Result := Select(Size + Control.Margins.Top + Control.Margins.Bottom)
  else
    Result := Select(Size);
end;

function THeightSelector.SelectControl(Control: TControl): Integer;
begin
  Result := Select(Control.Margins.ExplicitHeight);
end;

function THeightSelector._GetSize: Integer;
begin
  Result := FAdditionalSize + FSizeValue;
end;

{ TWidthSelector }

constructor TWidthSelector.Create(SizeType: TSizeType);
begin
  Create(0, SizeType);
end;

constructor TWidthSelector.Create(AdditionalSize: Integer; SizeType: TSizeType);
begin
  inherited Create;
  FAdditionalSize := AdditionalSize;
  FSizeType := SizeType;
  FSizeValue := 0;
end;

function TWidthSelector.Add(Size: Integer): Integer;
begin
  Inc(FAdditionalSize, Size);
  Result := FAdditionalSize + FSizeValue;
end;

function TWidthSelector.AddControl(Control: TControl): Integer;
begin
  Result := Add(Control.Margins.ExplicitWidth);
end;

function TWidthSelector.AddPadding(Control: TWinControl): Integer;
begin
  Inc(FAdditionalSize, Control.Padding.Left + Control.Padding.Right);
  Result := FAdditionalSize + FSizeValue;
end;

function TWidthSelector.Select(Size: Integer): Integer;
begin
  case FSizeType of
    stMax: if Size > FSizeValue then FSizeValue := Size;
    stMin: if Size < FSizeValue then FSizeValue := Size;
  end;

  Result := FSizeValue;
end;

function TWidthSelector.SelectWithMargins(Size: Integer;
  Control: TControl): Integer;
begin
  if Control.AlignWithMargins and (Control.Parent <> nil) then
    Result := Select(Size + Control.Margins.Left + Control.Margins.Right)
  else
    Result := Select(Size);
end;

function TWidthSelector.SelectControl(Control: TControl): Integer;
begin
  Result := Select(Control.Margins.ExplicitWidth);
end;

function TWidthSelector._GetSize: Integer;
begin
  Result := FAdditionalSize + FSizeValue;
end;

{ THeightAccumulator }

constructor THeightAccumulator.Create;
begin
  Create(0);
end;

constructor THeightAccumulator.Create(Size: Integer);
begin
  inherited Create;
  FSizeValue := Size;
end;

function THeightAccumulator.Add(Size: Integer): Integer;
begin
  Inc(FSizeValue, Size);
  Result := FSizeValue;
end;

function THeightAccumulator.AddControl(Control: TControl): Integer;
begin
  Result := Add(Control.Margins.ExplicitHeight);
end;

function THeightAccumulator.AddPadding(Control: TWinControl): Integer;
begin
  Inc(FSizeValue, Control.Padding.Top + Control.Padding.Bottom);
  Result := FSizeValue;
end;

function THeightAccumulator.NextControlFront(Control: TControl): Integer;
begin
  Result := Size;
  if Control.AlignWithMargins and (Control.Parent <> nil) then
    Inc(Result, Control.Margins.Top);
end;

function THeightAccumulator._GetSize: Integer;
begin
  Result := FSizeValue;
end;

{ TWidthAccumulator }

constructor TWidthAccumulator.Create;
begin
  Create(0);
end;

constructor TWidthAccumulator.Create(Size: Integer);
begin
  inherited Create;
  FSizeValue := Size;
end;

function TWidthAccumulator.Add(Size: Integer): Integer;
begin
  Inc(FSizeValue, Size);
  Result := FSizeValue;
end;

function TWidthAccumulator.AddControl(Control: TControl): Integer;
begin
  Result := Add(Control.Margins.ExplicitWidth);
end;

function TWidthAccumulator.AddPadding(Control: TWinControl): Integer;
begin
  Inc(FSizeValue, Control.Padding.Left + Control.Padding.Right);
  Result := FSizeValue;
end;

function TWidthAccumulator.NextControlFront(Control: TControl): Integer;
begin
  Result := Size;
  if Control.AlignWithMargins and (Control.Parent <> nil) then
    Inc(Result, Control.Margins.Left);
end;

function TWidthAccumulator._GetSize: Integer;
begin
  Result := FSizeValue;
end;

{ TModifyCollector }

constructor TModifyCollector.Create(Modify: Boolean);
begin
  inherited Create;
  FIsModify := Modify;
  FOnModify := nil;
end;

procedure TModifyCollector.Modify;
begin
  FIsModify := True;
  if Assigned(FOnModify) then
    FOnModify(Self, FIsModify);
end;

procedure TModifyCollector.UnModify;
begin
  FIsModify := False;
  if Assigned(FOnModify) then
    FOnModify(Self, FIsModify);
end;

function TModifyCollector._GetIsModify: Boolean;
begin
  Result := FIsModify;
end;

function TModifyCollector._GetOnModify: TModifyEvent;
begin
  Result := FOnModify;
end;

procedure TModifyCollector._SetOnModify(const Value: TModifyEvent);
begin
  FOnModify := Value;
  if Assigned(FOnModify) then
    FOnModify(Self, FIsModify);
end;

end.
