unit Sensors.AmbientLightSensor;

interface

uses
  Winapi.Windows, Winapi.ActiveX,
  Winapi.Sensors, Winapi.Sensorsapi, Winapi.Portabledevicetypes,
  System.SysUtils, System.Win.ComObj,
  System.Generics.Collections, System.Generics.Defaults;

type
  TLuxEvent = procedure(Sender: TObject; Lux: Double) of object;
  TAmbientLightSensor = class(TInterfacedObject)
  public type
    {$MinEnumSize 4}
    TLuxPair = packed record
      Offset: UINT;
      LightLevel: UINT;
      constructor Create(aOffset: UINT; aLightLevel: UINT);
    end;
  private type
    TLuxCurve = array [0..0] of TLuxPair;
    PLuxCurve = ^TLuxCurve;
  private
    FSensorManager: ISensorManager;
    FSensor: ISensor;
    FCurve: TList<TLuxPair>;
    FLux: Double;
    FOnLux: TLuxEvent;

    function ExtractLux(Data: PROPVARIANT): UINT;
    procedure DataUpdatedEvent(Sender: TObject; const Sensor: ISensor; const NewData: ISensorDataReport);
  public
    constructor Create;
    destructor Destroy; override;

    property Lux: Double read FLux;
    property Curve: TList<TLuxPair> read FCurve;
    property OnLux: TLuxEvent read FOnLux write FOnLux;
  end;

implementation

type
  TUIntArray = array [0..0] of UINT;
  PUIntArray = ^TUIntArray;

type
  TDataUpdatedEvent = procedure (Sender: TObject; const Sensor: ISensor; const NewData: ISensorDataReport) of object;
  TSensorEvent = procedure (Sender: TObject; const Sensor: ISensor; const EventID: TGUID;
    const EventData: IPortableDeviceValues) of object;
  TLeaveEvent = procedure (Sender: TObject; const ID: TGUID) of object;
  TStateChangeEvent = procedure (Sender: TObject; const Sensor: ISensor; State: SensorState) of object;

  TSensorEventSink = class(TInterfacedObject, ISensorEvents)
  private
    FDataUpdated: TDataUpdatedEvent;
    FEvent: TSensorEvent;
    FLeave: TLeaveEvent;
    FStateChange: TStateChangeEvent;
  protected
    function OnDataUpdated(const pSensor: ISensor; const pNewData: ISensorDataReport): HRESULT; stdcall;
    function OnEvent(const pSensor: ISensor; const eventID: TGUID;
      const pEventData: IPortableDeviceValues): HRESULT; stdcall;
    function OnLeave(const ID: TGUID): HRESULT; stdcall;
    function OnStateChanged(const pSensor: ISensor; state: SensorState): HRESULT; stdcall;
  public
    constructor Create(ADataUpdated: TDataUpdatedEvent; AEvent: TSensorEvent; ALeave: TLeaveEvent;
      AStateChange: TStateChangeEvent);
  end;

{ TAmbientLightSensor }

constructor TAmbientLightSensor.Create;
var
  hr: HRESULT;

  Sensors: ISensorCollection;
  SensorCount: DWORD;

  pvCurve: PROPVARIANT;
  pValue: PROPVARIANT;
  ppDataReport: ISensorDataReport;
  cElement: UINT;

  I: Integer;
begin
  inherited Create;

  hr := CoInitializeEx(nil, COINIT_APARTMENTTHREADED);
  if (hr <> S_OK) and (hr <> S_FALSE) and (hr <> RPC_E_CHANGED_MODE) then OleCheck(hr);

  FSensorManager := CreateComObject(CLSID_SensorManager) as ISensorManager;
  OleCheck(FSensorManager.GetSensorsByCategory(SENSOR_TYPE_AMBIENT_LIGHT, Sensors));
  OleCheck(Sensors.GetCount(SensorCount));
  if SensorCount < 1 then raise Exception.Create('Ambient Light Sensor not Found');

  OleCheck(Sensors.GetAt(0, FSensor));
  OleCheck(FSensor.GetProperty(SENSOR_PROPERTY_LIGHT_RESPONSE_CURVE, pvCurve));
  if pvCurve.caub.cElems > 0 then
  begin
    FCurve := TList<TLuxPair>.Create;
    cElement := pvCurve.caub.cElems div SizeOf(UINT);

    for I := 0 to cElement - 1 do
    begin
      FCurve.Add(PLuxCurve(pvCurve.caub.pElems)^[I]);
    end;
  end;
  PropVariantClear(pvCurve);

  OleCheck(FSensor.GetData(ppDataReport));
  OleCheck(ppDataReport.GetSensorValue(SENSOR_DATA_TYPE_LIGHT_LEVEL_LUX, pValue));
  FLux := ExtractLux(pValue);
  PropVariantClear(pValue);

  FSensor.SetEventSink(TSensorEventSink.Create(DataUpdatedEvent, nil, nil, nil))
end;

destructor TAmbientLightSensor.Destroy;
begin
  if Assigned(FSensor) then FSensor.SetEventSink(nil);
  if Assigned(FCurve) then FCurve.Free;
  CoUninitialize;
  inherited;
end;

function TAmbientLightSensor.ExtractLux(Data: PROPVARIANT): UINT;
begin
  case Data.vt of
    VT_R4: Result := Round(Data.fltVal);
    VT_UI4: Result := Data.ulVal;
    else raise Exception.Create('Variable not supported');
  end;
end;

procedure TAmbientLightSensor.DataUpdatedEvent(Sender: TObject;
  const Sensor: ISensor; const NewData: ISensorDataReport);
var
  pValue: PROPVARIANT;
begin
  OleCheck(NewData.GetSensorValue(SENSOR_DATA_TYPE_LIGHT_LEVEL_LUX, pValue));
  FLux := ExtractLux(pValue);
  PropVariantClear(pValue);
  if Assigned(FOnLux) then FOnLux(Self, FLux);
end;

{ TSensorEventSink }

constructor TSensorEventSink.Create(ADataUpdated: TDataUpdatedEvent; AEvent: TSensorEvent; ALeave: TLeaveEvent;
  AStateChange: TStateChangeEvent);
begin
  inherited Create;
  FDataUpdated := ADataUpdated;
  FEvent := AEvent;
  FLeave := ALeave;
  FStateChange := AStateChange;
end;

function TSensorEventSink.OnDataUpdated(const pSensor: ISensor; const pNewData: ISensorDataReport): HRESULT;
begin
  try
    if Assigned(FDataUpdated) then
      FDataUpdated(Self, pSensor, pNewData);
    Result := S_OK;
  except
    Result := E_UNEXPECTED;
  end;
end;

function TSensorEventSink.OnEvent(const pSensor: ISensor; const eventID: TGUID;
  const pEventData: IPortableDeviceValues): HRESULT;
begin
  try
    if Assigned(FEvent) then
      FEvent(Self, pSensor, eventID, pEventData);
    Result := S_OK;
  except
    Result := E_UNEXPECTED;
  end;
end;

function TSensorEventSink.OnLeave(const ID: TGUID): HRESULT;
begin
  try
    if Assigned(FLeave) then
      FLeave(Self, ID);
    Result := S_OK;
  except
    Result := E_UNEXPECTED;
  end;
end;

function TSensorEventSink.OnStateChanged(const pSensor: ISensor; state: SensorState): HRESULT;
begin
  try
    if Assigned(FStateChange) then
      FStateChange(Self, pSensor, state);
    Result := S_OK;
  except
    Result := E_UNEXPECTED;
  end;
end;

{ TAmbientLightSensor.TLuxPair }

constructor TAmbientLightSensor.TLuxPair.Create(aOffset, aLightLevel: UINT);
begin
  Offset := aOffset;
  LightLevel := aLightLevel;
end;

end.
