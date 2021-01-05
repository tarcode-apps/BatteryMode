object PowerMonitorWindow: TPowerMonitorWindow
  AlignWithMargins = True
  Left = 0
  Top = 0
  AutoSize = True
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'PowerMonitor'
  ClientHeight = 563
  ClientWidth = 456
  Color = clBtnFace
  Constraints.MaxHeight = 630
  Constraints.MaxWidth = 465
  DefaultMonitor = dmPrimary
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Menu = MainMenu
  OldCreateOrder = False
  Position = poScreenCenter
  Visible = True
  OnAfterMonitorDpiChanged = FormAfterMonitorDpiChanged
  OnBeforeMonitorDpiChanged = FormBeforeMonitorDpiChanged
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 15
  object TabControl: TTabControl
    AlignWithMargins = True
    Left = 3
    Top = 3
    Width = 452
    Height = 558
    Margins.Right = 1
    Margins.Bottom = 2
    TabOrder = 0
    OnChange = TabControlChange
    object GroupBoxBattery: TGroupBox
      AlignWithMargins = True
      Left = 7
      Top = 9
      Width = 438
      Height = 382
      Align = alTop
      Caption = 'Battery'
      TabOrder = 0
      DesignSize = (
        438
        382)
      object LabelName: TLabeledEdit
        Left = 6
        Top = 38
        Width = 200
        Height = 23
        EditLabel.Width = 32
        EditLabel.Height = 15
        EditLabel.Caption = 'Name'
        ReadOnly = True
        TabOrder = 0
      end
      object LabelManufacture: TLabeledEdit
        Left = 6
        Top = 82
        Width = 200
        Height = 23
        EditLabel.Width = 68
        EditLabel.Height = 15
        EditLabel.Caption = 'Manufacture'
        ReadOnly = True
        TabOrder = 1
      end
      object LabelManufactureDate: TLabeledEdit
        Left = 6
        Top = 126
        Width = 200
        Height = 23
        EditLabel.Width = 92
        EditLabel.Height = 15
        EditLabel.Caption = 'ManufactureDate'
        ReadOnly = True
        TabOrder = 2
      end
      object LabelSerialNumber: TLabeledEdit
        Left = 6
        Top = 170
        Width = 200
        Height = 23
        EditLabel.Width = 72
        EditLabel.Height = 15
        EditLabel.Caption = 'SerialNumber'
        ReadOnly = True
        TabOrder = 3
      end
      object LabelDesignedCapacity: TLabeledEdit
        Left = 232
        Top = 38
        Width = 200
        Height = 23
        Anchors = [akTop, akRight]
        EditLabel.Width = 95
        EditLabel.Height = 15
        EditLabel.Caption = 'DesignedCapacity'
        ReadOnly = True
        TabOrder = 8
      end
      object LabelType: TLabeledEdit
        Left = 6
        Top = 214
        Width = 200
        Height = 23
        EditLabel.Width = 24
        EditLabel.Height = 15
        EditLabel.Caption = 'Type'
        ReadOnly = True
        TabOrder = 4
      end
      object LabelCycleCount: TLabeledEdit
        Left = 6
        Top = 258
        Width = 200
        Height = 23
        EditLabel.Width = 62
        EditLabel.Height = 15
        EditLabel.Caption = 'CycleCount'
        ReadOnly = True
        TabOrder = 5
      end
      object LabelWearLevel: TLabeledEdit
        Left = 6
        Top = 302
        Width = 200
        Height = 23
        EditLabel.Width = 54
        EditLabel.Height = 15
        EditLabel.Caption = 'WearLevel'
        ReadOnly = True
        TabOrder = 6
      end
      object LabelPowerState: TLabeledEdit
        Left = 6
        Top = 346
        Width = 200
        Height = 23
        EditLabel.Width = 59
        EditLabel.Height = 15
        EditLabel.Caption = 'PowerState'
        ReadOnly = True
        TabOrder = 7
      end
      object LabelFullChargedCapacity: TLabeledEdit
        Left = 232
        Top = 82
        Width = 200
        Height = 23
        Anchors = [akTop, akRight]
        EditLabel.Width = 110
        EditLabel.Height = 15
        EditLabel.Caption = 'FullChargedCapacity'
        ReadOnly = True
        TabOrder = 9
      end
      object LabelCapacity: TLabeledEdit
        Left = 232
        Top = 126
        Width = 200
        Height = 23
        Anchors = [akTop, akRight]
        EditLabel.Width = 46
        EditLabel.Height = 15
        EditLabel.Caption = 'Capacity'
        ReadOnly = True
        TabOrder = 10
      end
      object LabelVoltage: TLabeledEdit
        Left = 232
        Top = 170
        Width = 200
        Height = 23
        Anchors = [akTop, akRight]
        EditLabel.Width = 39
        EditLabel.Height = 15
        EditLabel.Caption = 'Voltage'
        ReadOnly = True
        TabOrder = 11
      end
      object LabelRate: TLabeledEdit
        Left = 232
        Top = 214
        Width = 200
        Height = 23
        Anchors = [akTop, akRight]
        EditLabel.Width = 23
        EditLabel.Height = 15
        EditLabel.Caption = 'Rate'
        ReadOnly = True
        TabOrder = 12
      end
      object LabelDefaultAlert1: TLabeledEdit
        Left = 232
        Top = 258
        Width = 200
        Height = 23
        Anchors = [akTop, akRight]
        EditLabel.Width = 69
        EditLabel.Height = 15
        EditLabel.Caption = 'DefaultAlert1'
        ReadOnly = True
        TabOrder = 13
      end
      object LabelDefaultAlert2: TLabeledEdit
        Left = 232
        Top = 302
        Width = 200
        Height = 23
        Anchors = [akTop, akRight]
        EditLabel.Width = 69
        EditLabel.Height = 15
        EditLabel.Caption = 'DefaultAlert2'
        ReadOnly = True
        TabOrder = 14
      end
      object LabelTemperature: TLabeledEdit
        Left = 232
        Top = 346
        Width = 200
        Height = 23
        Anchors = [akTop, akRight]
        EditLabel.Width = 66
        EditLabel.Height = 15
        EditLabel.Caption = 'Temperature'
        ReadOnly = True
        TabOrder = 15
      end
    end
    object GroupBoxSystem: TGroupBox
      AlignWithMargins = True
      Left = 7
      Top = 397
      Width = 438
      Height = 118
      Align = alTop
      Caption = 'System'
      TabOrder = 1
      DesignSize = (
        438
        118)
      object LabelPowerSource: TLabeledEdit
        Left = 6
        Top = 38
        Width = 200
        Height = 23
        EditLabel.Width = 69
        EditLabel.Height = 15
        EditLabel.Caption = 'PowerSource'
        ReadOnly = True
        TabOrder = 0
      end
      object LabelFullLifetime: TLabeledEdit
        Left = 232
        Top = 38
        Width = 200
        Height = 23
        Anchors = [akTop, akRight]
        EditLabel.Width = 62
        EditLabel.Height = 15
        EditLabel.Caption = 'FullLifetime'
        ReadOnly = True
        TabOrder = 2
      end
      object LabelBatteryStatus: TLabeledEdit
        Left = 6
        Top = 82
        Width = 200
        Height = 23
        EditLabel.Width = 69
        EditLabel.Height = 15
        EditLabel.Caption = 'BatteryStatus'
        ReadOnly = True
        TabOrder = 1
      end
      object LabelLifetime: TLabeledEdit
        Left = 232
        Top = 82
        Width = 200
        Height = 23
        Anchors = [akTop, akRight]
        EditLabel.Width = 43
        EditLabel.Height = 15
        EditLabel.Caption = 'Lifetime'
        ReadOnly = True
        TabOrder = 3
      end
    end
  end
  object TimerAutoupdate: TTimer
    Enabled = False
    Interval = 500
    OnTimer = TimerAutoupdateTimer
    Left = 58
    Top = 20
  end
  object MainMenu: TMainMenu
    Left = 131
    Top = 19
    object MainMenuFile: TMenuItem
      Caption = 'File'
      object MainMenuSave: TMenuItem
        Caption = 'Save'
        ShortCut = 16467
        OnClick = MainMenuSaveClick
      end
      object MainMenuSaveAs: TMenuItem
        Caption = 'SaveAs'
        ShortCut = 24659
        OnClick = MainMenuSaveAsClick
      end
      object MainMenuClose: TMenuItem
        Caption = 'Close'
        ShortCut = 27
        OnClick = MainMenuCloseClick
      end
    end
    object MainMenuView: TMenuItem
      Caption = 'View'
      object MainMenuAlwaysOnTop: TMenuItem
        AutoCheck = True
        Caption = 'AlwaysOnTop'
        ShortCut = 16468
        OnClick = MainMenuAlwaysOnTopClick
      end
    end
  end
end
