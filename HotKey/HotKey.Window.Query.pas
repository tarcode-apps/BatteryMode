unit HotKey.Window.Query;

interface

uses
  Winapi.Windows, Winapi.Messages,
  System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ComCtrls,
  Vcl.StdCtrls, Vcl.ExtCtrls,
  Core.Language,
  Core.UI, Core.UI.Controls,
  HotKey,
  Versions.Helpers;

type
  THotKeyInfo = record
    Enabled: Boolean;
    Value: THotKeyValue;
    constructor Create(Enabled: Boolean; Value: THotKeyValue);

    class operator Equal(const Left, Right: THotKeyInfo): Boolean;
    class operator NotEqual(const Left, Right: THotKeyInfo): Boolean;
  end;

  THotKeyQueryWindow = class(TCompatibleForm)
    PanelControl: TPanel;
    PanelHotKey: TPanel;
    ButtonCancel: TButton;
    ButtonApply: TButton;
    RadioButtonAltPause: TRadioButton;
    RadioButtonCtrlDelete: TRadioButton;
    RadioButtonCustom: TRadioButton;
    HotKeyCustom: THotKey;
    CheckBoxEnabled: TCheckBox;
    PanelEnable: TPanel;
    LabelMessage: TLabel;
    procedure RadioButtonClick(Sender: TObject);
    procedure HotKeyCustomChange(Sender: TObject);
    procedure CheckBoxEnabledClick(Sender: TObject);
    procedure FormAfterMonitorDpiChanged(Sender: TObject; OldDPI,
      NewDPI: Integer);
    procedure FormBeforeMonitorDpiChanged(Sender: TObject; OldDPI,
      NewDPI: Integer);
  private
    FParentHandle: THandle;
    FModifyCollector: IModifyCollector;
    FUpdateLocker: ILocker;
    FHotKeyInfo: THotKeyInfo;
    procedure Loadlocalization;
    function GetValue: THotKeyValue;
    procedure ModifyCollectorModify(Sender: TObject; var Modify: Boolean);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure KeyPress(var Key: Char); override;
    procedure DoClose(var Action: TCloseAction); override;
  public
    constructor Create(AOwner: TComponent; HotKeyInfo: THotKeyInfo; Msg: string; ParentHandle: THandle); reintroduce;
    function QueryHotKey: THotKeyInfo;
  end;

implementation

{$R *.dfm}

constructor THotKeyQueryWindow.Create(AOwner: TComponent;
  HotKeyInfo: THotKeyInfo; Msg: string; ParentHandle: THandle);
begin
  FParentHandle := ParentHandle;
  inherited Create(AOwner);
  FHotKeyInfo := HotKeyInfo;

  FUpdateLocker := TLocker.Create;
  FModifyCollector := TModifyCollector.Create;
  FModifyCollector.OnModify := ModifyCollectorModify;

  // Инициализация интерфейса
  PanelEnable.Shape := psBottomLine;
  PanelControl.Shape := psTopLine;
  HotKeyCustom.Align := alTop;
  RadioButtonAltPause.AutoSize := True;
  RadioButtonCtrlDelete.AutoSize := True;
  RadioButtonCustom.AutoSize := True;

  PanelHotKey.AutoSize := False;

  LabelMessage.Caption := Msg;
  LabelMessage.Visible := not Msg.IsEmpty;

  LabelMessage.Font.Name := Font.Name;
  LabelMessage.Font.Size := Font.Size;

  FUpdateLocker.Lock;
  try
    CheckBoxEnabled.Checked := HotKeyInfo.Enabled;

    if HotKeyInfo.Value = THotKeyValue.Create(MOD_ALT, VK_PAUSE) then
    begin
      HotKeyCustom.Enabled := False;
      RadioButtonAltPause.Checked := True;
      ActiveControl := RadioButtonAltPause;
    end
    else if HotKeyInfo.Value = THotKeyValue.Create(MOD_CONTROL, VK_DELETE) then
    begin
      HotKeyCustom.Enabled := False;
      RadioButtonCtrlDelete.Checked := True;
      ActiveControl := RadioButtonCtrlDelete;
    end
    else
    begin
      HotKeyCustom.Enabled := True;
      RadioButtonCustom.Checked := True;
      HotKeyCustom.HotKey := HotKeyInfo.Value.ToShortCut;
      ActiveControl := HotKeyCustom;
    end;
  finally
    FUpdateLocker.Unlock;
  end;

  // Загрузка локализации
  Loadlocalization;

  PanelHotKey.AutoSize := True;

  if IsWindows10OrGreater then Color := clWindow;
end;

procedure THotKeyQueryWindow.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.WndParent := FParentHandle;
  if FParentHandle = 0 then
    Params.ExStyle := Params.ExStyle or WS_EX_APPWINDOW;
end;

procedure THotKeyQueryWindow.KeyPress(var Key: Char);
begin
  inherited;
  if Key =  Char(VK_ESCAPE) then Close;
end;

procedure THotKeyQueryWindow.DoClose(var Action: TCloseAction);
begin
  Action := caFree;
  inherited;
end;

procedure THotKeyQueryWindow.Loadlocalization;
begin
  Caption := TLang[300]; // Горячая клавиша

  CheckBoxEnabled.Caption := TLang[320]; // Включить

  ButtonApply.Caption   := TLang[301]; // Применить
  ButtonCancel.Caption  := TLang[302]; // Отмена

  RadioButtonCustom.Caption := TLang[310]; // Выбрать
end;

function THotKeyQueryWindow.GetValue: THotKeyValue;
begin
  if RadioButtonAltPause.Checked then
    Exit(THotKeyValue.Create(MOD_ALT, VK_PAUSE));

  if RadioButtonCtrlDelete.Checked then
    Exit(THotKeyValue.Create(MOD_CONTROL, VK_DELETE));

  if RadioButtonCustom.Checked then
    Exit(THotKeyValue.Create(HotKeyCustom.HotKey));
end;

procedure THotKeyQueryWindow.CheckBoxEnabledClick(Sender: TObject);
begin
  if FUpdateLocker.IsLocked then Exit;

  FModifyCollector.Modify;
end;

procedure THotKeyQueryWindow.RadioButtonClick(Sender: TObject);
begin
  if FUpdateLocker.IsLocked then Exit;

  if Sender = RadioButtonCustom then
  begin
    HotKeyCustom.Enabled := True;
    ActiveControl := HotKeyCustom;
  end
  else
    HotKeyCustom.Enabled := False;

  FModifyCollector.Modify;
end;

procedure THotKeyQueryWindow.HotKeyCustomChange(Sender: TObject);
begin
  if FUpdateLocker.IsLocked then Exit;

  FModifyCollector.Modify;
end;

procedure THotKeyQueryWindow.FormAfterMonitorDpiChanged(Sender: TObject; OldDPI,
  NewDPI: Integer);
begin
  AutoSize := True;
end;

procedure THotKeyQueryWindow.FormBeforeMonitorDpiChanged(Sender: TObject;
  OldDPI, NewDPI: Integer);
begin
  AutoSize := False;
end;

procedure THotKeyQueryWindow.ModifyCollectorModify(Sender: TObject;
  var Modify: Boolean);
begin
  ButtonApply.Enabled := Modify;
end;

function THotKeyQueryWindow.QueryHotKey: THotKeyInfo;
begin
  if ShowModal = mrOk then
  begin
    Result.Enabled := CheckBoxEnabled.Checked;
    Result.Value := GetValue;
  end
  else
    Result := FHotKeyInfo;
end;

{ THotKeyInfo }

constructor THotKeyInfo.Create(Enabled: Boolean; Value: THotKeyValue);
begin
  Self.Enabled := Enabled;
  Self.Value := Value;
end;

class operator THotKeyInfo.Equal(const Left, Right: THotKeyInfo): Boolean;
begin
  Result := (Left.Enabled = Right.Enabled) and (Left.Value = Right.Value);
end;

class operator THotKeyInfo.NotEqual(const Left, Right: THotKeyInfo): Boolean;
begin
  Result := not (Left = Right);
end;

end.
