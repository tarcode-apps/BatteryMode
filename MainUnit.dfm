object BatteryModeForm: TBatteryModeForm
  Left = 196
  Top = 149
  AutoSize = True
  BorderIcons = []
  BorderStyle = bsToolWindow
  Caption = 'BatteryModeForm'
  ClientHeight = 161
  ClientWidth = 247
  Color = clWindow
  Ctl3D = False
  DefaultMonitor = dmDesktop
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  FormStyle = fsStayOnTop
  KeyPreview = True
  OldCreateOrder = False
  OnActivate = FormActivate
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnDeactivate = FormDeactivate
  OnShow = FormShow
  PixelsPerInch = 96
  TextHeight = 15
  object PanelTop: TPanel
    Left = 0
    Top = 0
    Width = 247
    Height = 45
    Align = alTop
    BevelOuter = bvNone
    ParentColor = True
    TabOrder = 0
    DesignSize = (
      247
      45)
    object LabelAppName: TLabel
      Left = 51
      Top = 5
      Width = 167
      Height = 20
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Caption = 'LabelAppName'
      OnClick = LabelAppInfoClick
    end
    object ImageIcon: TImage
      Left = 10
      Top = 3
      Width = 36
      Height = 36
      Center = True
      Transparent = True
      OnClick = LabelAppInfoClick
    end
    object LabelAppInfo: TLabel
      Left = 51
      Top = 22
      Width = 167
      Height = 20
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Caption = 'LabelAppInfo'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clGray
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      Visible = False
      OnClick = LabelAppInfoClick
    end
    object LabelStatus: TLabel
      Left = 51
      Top = 5
      Width = 185
      Height = 36
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Caption = 'LabelStatus'
      WordWrap = True
    end
  end
  object PanelBottom: TPanel
    Left = 0
    Top = 118
    Width = 247
    Height = 43
    Align = alTop
    AutoSize = True
    BevelOuter = bvNone
    Color = clMenu
    Constraints.MinHeight = 43
    ParentBackground = False
    TabOrder = 3
    object LinkGridPanel: TGridPanel
      Left = 0
      Top = 0
      Width = 247
      Height = 43
      Align = alTop
      BevelOuter = bvNone
      Caption = 'LinkGridPanel'
      Color = clMenu
      ColumnCollection = <
        item
          Value = 100.000000000000000000
        end>
      ControlCollection = <
        item
          Column = 0
          Control = Link
          Row = 0
        end>
      RowCollection = <
        item
          Value = 100.000000000000000000
        end>
      ShowCaption = False
      TabOrder = 0
      DesignSize = (
        247
        43)
      object Link: TStaticText
        Left = 110
        Top = 12
        Width = 26
        Height = 19
        Margins.Left = 19
        Margins.Top = 14
        Margins.Right = 19
        Margins.Bottom = 8
        Alignment = taCenter
        Anchors = []
        Caption = 'Link'
        ShowAccelChar = False
        TabOrder = 0
        TabStop = True
        OnClick = LinkClick
      end
    end
  end
  object PanelConfig: TPanel
    Left = 0
    Top = 45
    Width = 247
    Height = 35
    Align = alTop
    AutoSize = True
    BevelOuter = bvNone
    Caption = 'PanelConfig'
    Padding.Left = 4
    Padding.Top = 4
    Padding.Right = 4
    Padding.Bottom = 13
    ParentColor = True
    ShowCaption = False
    TabOrder = 1
    object LabelConfig: TLabel
      AlignWithMargins = True
      Left = 4
      Top = 4
      Width = 239
      Height = 17
      Margins.Left = 0
      Margins.Top = 0
      Margins.Right = 0
      Margins.Bottom = 1
      Align = alTop
      Alignment = taCenter
      AutoSize = False
      Caption = 'LabelConfig'
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clGray
      Font.Height = -12
      Font.Name = 'Segoe UI'
      Font.Style = []
      ParentFont = False
      Layout = tlCenter
      ExplicitLeft = 16
      ExplicitTop = 5
      ExplicitWidth = 193
    end
  end
  object PanelBatterySaver: TPanel
    Left = 0
    Top = 80
    Width = 247
    Height = 38
    Align = alTop
    AutoSize = True
    BevelOuter = bvNone
    Caption = 'PanelBatterySaver'
    Padding.Left = 4
    Padding.Top = 6
    Padding.Right = 4
    Padding.Bottom = 10
    ParentColor = True
    ShowCaption = False
    TabOrder = 2
    Visible = False
    object CheckBoxBatterySaver: TCheckBox
      AlignWithMargins = True
      Left = 20
      Top = 10
      Width = 207
      Height = 17
      Margins.Left = 16
      Margins.Top = 4
      Margins.Right = 16
      Margins.Bottom = 1
      Align = alTop
      Caption = 'BatterySaver'
      TabOrder = 0
      OnClick = CheckBoxBatterySaverClick
    end
  end
  object PopupMenuTray: TPopupMenu
    Left = 192
    Top = 48
    object TrayMenuPower: TMenuItem
      Caption = 'Power'
      OnClick = TrayMenuPowerClick
    end
    object TrayMenuSystemIcon: TMenuItem
      Caption = 'SystemIcon'
      OnClick = TrayMenuSystemIconClick
    end
    object TrayMenuMobilityCenter: TMenuItem
      Caption = 'MobilityCenter'
      Visible = False
      OnClick = TrayMenuMobilityCenterClick
    end
    object TrayMenuSeparator1: TMenuItem
      Caption = '-'
    end
    object TrayMenuAutorun: TMenuItem
      AutoCheck = True
      Caption = 'Autorun'
      OnClick = TrayMenuAutorunClick
    end
    object TrayMenuSettings: TMenuItem
      Caption = 'Settings'
      OnClick = TrayMenuSettingsClick
    end
    object TrayMenuScheduler: TMenuItem
      Caption = 'Scheduler'
      OnClick = TrayMenuSchedulerClick
    end
    object TrayMenuLanguage: TMenuItem
      Caption = 'Language'
      object TrayMenuLanguageSystem: TMenuItem
        AutoCheck = True
        Caption = 'System'
        RadioItem = True
        OnClick = TrayMenuLanguageItemClick
      end
      object TrayMenuSeparator8: TMenuItem
        Caption = '-'
      end
    end
    object TrayMenuSeparator2: TMenuItem
      Caption = '-'
    end
    object TrayMenuWebsite: TMenuItem
      Caption = 'Website'
      OnClick = TrayMenuWebsiteClick
    end
    object TrayMenuSeparator3: TMenuItem
      Caption = '-'
    end
    object TrayMenuMonitorsOff: TMenuItem
      Caption = 'MonitorsOff'
      OnClick = TrayMenuMonitorsOffClick
    end
    object TrayMenuPowerAction: TMenuItem
      Caption = 'PowerAction'
      object TrayMenuPowerActionDisconnect: TMenuItem
        Caption = 'Disconnect'
        OnClick = TrayMenuPowerActionDisconnectClick
      end
      object TrayMenuPowerActionShutdown: TMenuItem
        Caption = 'Shutdown'
        OnClick = TrayMenuPowerActionShutdownClick
      end
      object TrayMenuPowerActionReboot: TMenuItem
        Caption = 'Reboot'
        OnClick = TrayMenuPowerActionRebootClick
      end
      object TrayMenuPowerActionSleep: TMenuItem
        Caption = 'Sleep'
        OnClick = TrayMenuPowerActionSleepClick
      end
      object TrayMenuPowerActionHibernate: TMenuItem
        Caption = 'Hibernate'
        OnClick = TrayMenuPowerActionHibernateClick
      end
      object TrayMenuPowerActionDiagnostic: TMenuItem
        Caption = 'Diagnostic'
        OnClick = TrayMenuPowerActionDiagnosticClick
      end
      object TrayMenuPowerActionLogOut: TMenuItem
        Caption = 'LogOut'
        OnClick = TrayMenuPowerActionLogOutClick
      end
      object TrayMenuPowerActionLock: TMenuItem
        Caption = 'Lock'
        OnClick = TrayMenuPowerActionLockClick
      end
    end
    object TrayMenuSeparator7: TMenuItem
      Caption = '-'
    end
    object TrayMenuPowerMonitor: TMenuItem
      Caption = 'PowerMonitor'
      OnClick = TrayMenuPowerMonitorClick
    end
    object TrayMenuSeparator4: TMenuItem
      Caption = '-'
    end
    object TrayMenuBrightnessUpdate: TMenuItem
      Caption = 'BrightnessUpdate'
      OnClick = TrayMenuBrightnessUpdateClick
    end
    object TrayMenuSeparator6: TMenuItem
      Caption = '-'
    end
    object TrayMenuClose: TMenuItem
      Caption = 'Close'
      OnClick = TrayMenuCloseClick
    end
  end
end
