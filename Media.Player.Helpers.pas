unit Media.Player.Helpers;

interface

uses
  Winapi.Windows, Winapi.MMSystem,
  System.SysUtils,
  Vcl.Consts, Vcl.MPlayer;

const
  MCI_SETAUDIO            = $0873;
  MCI_DGV_SETAUDIO_VOLUME = $4002;
  MCI_DGV_SETAUDIO_ITEM   = $00800000;
  MCI_DGV_SETAUDIO_VALUE  = $01000000;
  MCI_DGV_STATUS_VOLUME   = $4019;

type
  MCI_STATUS_PARMS = record
    dwCallback: DWORD_PTR;
    dwReturn: DWORD_PTR;
    dwItem: DWORD;
    dwTrack: DWORD;
  end;

  MCI_DGV_SETAUDIO_PARMS = record
    dwCallback: DWORD_PTR;
    dwItem: DWORD;
    dwValue: DWORD;
    dwOver: DWORD;
    lpstrAlgorithm: LPTSTR;
    lpstrQuality: LPTSTR;
  end;

  TMediaPlayerHelper = class helper for TMediaPlayer
  private
    function GetErrorString(Error: MCIERROR): string;

    function GetVolume: Integer;
    procedure SetVolume(const Value: Integer);
  public
    // Volume 0 - 1000
    property Volume: Integer read GetVolume write SetVolume;
  end;

implementation

{ TMediaPlayerHelper }

function TMediaPlayerHelper.GetErrorString(Error: MCIERROR): string;
{$IF DEFINED(CLR)}
var
  ErrMsg: System.Text.StringBuilder;
begin
  ErrMsg := StringBuilder.Create(4096);
  if not mciGetErrorString(Error, ErrMsg, ErrMsg.Capacity) then
    Result := SMCIUnknownError
  else
    Result := ErrMsg.ToString;
{$ELSE}
var
  ErrMsg: array[0..4095] of Char;
begin
  if not mciGetErrorString(Error, ErrMsg, SizeOf(ErrMsg)) then
    Result := SMCIUnknownError
  else SetString(Result, ErrMsg, StrLen(ErrMsg));
{$ENDIF}
end;

function TMediaPlayerHelper.GetVolume: Integer;
var
  StatusParms: MCI_STATUS_PARMS;
  Error: MCIERROR;
begin
  ZeroMemory(@StatusParms, SizeOf(StatusParms));
  StatusParms.dwItem := MCI_DGV_STATUS_VOLUME;
  Error := mciSendCommand(Self.DeviceID, MCI_STATUS, MCI_STATUS_ITEM, DWORD_PTR(@StatusParms));
  if Error <> 0 then raise EMCIDeviceError.Create(GetErrorString(Error));

  Result := StatusParms.dwReturn;
end;

procedure TMediaPlayerHelper.SetVolume(const Value: Integer);
var
  SetAudioParms: MCI_DGV_SETAUDIO_PARMS;
  Error: MCIERROR;
begin
  ZeroMemory(@SetAudioParms, SizeOf(SetAudioParms));
  SetAudioParms.dwItem := MCI_DGV_SETAUDIO_VOLUME;
  SetAudioParms.dwValue := Value;
  Error := mciSendCommand(Self.DeviceID, MCI_SETAUDIO,
    MCI_DGV_SETAUDIO_VALUE or MCI_DGV_SETAUDIO_ITEM, DWORD_PTR(@SetAudioParms));

  if Error <> 0 then raise EMCIDeviceError.Create(GetErrorString(Error));
end;

end.
