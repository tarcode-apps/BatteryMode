object SettingsWindow: TSettingsWindow
  AlignWithMargins = True
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'Settings'
  ClientHeight = 533
  ClientWidth = 590
  Color = clBtnFace
  Constraints.MinHeight = 422
  Constraints.MinWidth = 470
  DefaultMonitor = dmPrimary
  DoubleBuffered = True
  Font.Charset = RUSSIAN_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Menu = MainMenu
  Position = poScreenCenter
  OnAfterMonitorDpiChanged = FormAfterMonitorDpiChanged
  OnClose = FormClose
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  TextHeight = 15
  object SettingTabs: TPageControl
    AlignWithMargins = True
    Left = 6
    Top = 5
    Width = 580
    Height = 523
    Margins.Left = 6
    Margins.Top = 5
    Margins.Right = 4
    Margins.Bottom = 5
    ActivePage = InterfaceTab
    Align = alClient
    TabOrder = 0
    object InterfaceTab: TTabSheet
      Caption = 'Interface'
      object IconsGroup: TGroupBox
        AlignWithMargins = True
        Left = 8
        Top = 3
        Width = 554
        Height = 170
        Margins.Left = 8
        Margins.Right = 10
        Align = alTop
        Caption = 'Icons'
        TabOrder = 0
        object IconsGrid: TGridPanel
          Left = 2
          Top = 17
          Width = 550
          Height = 151
          Align = alClient
          Alignment = taLeftJustify
          BevelOuter = bvNone
          Caption = 'IconsGrid'
          ColumnCollection = <
            item
              SizeStyle = ssAuto
              Value = 25.000000000000000000
            end
            item
              Value = 100.000000000000000000
            end
            item
              SizeStyle = ssAbsolute
              Value = 80.000000000000000000
            end>
          ControlCollection = <
            item
              Column = 1
              Control = IconColorComboBox
              Row = 0
            end
            item
              Column = 0
              Control = IconStyleLabel
              Row = 1
            end
            item
              Column = 1
              Control = IconStyleComboBox
              Row = 1
            end
            item
              Column = 0
              Control = IconColorLabel
              Row = 0
            end
            item
              Column = 1
              Control = TypicalPowerSavingsMonochromeCheckBox
              Row = 2
            end
            item
              Column = 1
              Control = IconStyleExplicitMissingBatteryCheckBox
              Row = 3
            end
            item
              Column = 1
              Control = IconBehaviorPercentCheckBox
              Row = 4
            end
            item
              Column = 2
              Control = IconColorLevelsButton
              Row = 0
            end>
          RowCollection = <
            item
              SizeStyle = ssAbsolute
              Value = 32.000000000000000000
            end
            item
              SizeStyle = ssAbsolute
              Value = 32.000000000000000000
            end
            item
              SizeStyle = ssAbsolute
              Value = 28.000000000000000000
            end
            item
              SizeStyle = ssAbsolute
              Value = 26.000000000000000000
            end
            item
              SizeStyle = ssAbsolute
              Value = 26.000000000000000000
            end>
          ShowCaption = False
          TabOrder = 0
          object IconColorComboBox: TComboBox
            AlignWithMargins = True
            Left = 69
            Top = 3
            Width = 398
            Height = 23
            Align = alClient
            Style = csDropDownList
            TabOrder = 0
            OnChange = IconColorComboBoxChange
          end
          object IconStyleLabel: TLabel
            AlignWithMargins = True
            Left = 6
            Top = 38
            Width = 48
            Height = 23
            Margins.Left = 6
            Margins.Top = 6
            Margins.Right = 6
            Align = alLeft
            Anchors = []
            Caption = 'IconStyle'
            ExplicitHeight = 15
          end
          object IconStyleComboBox: TComboBox
            AlignWithMargins = True
            Left = 69
            Top = 35
            Width = 398
            Height = 23
            Align = alClient
            Style = csDropDownList
            TabOrder = 1
            OnChange = IconStyleComboBoxChange
          end
          object IconColorLabel: TLabel
            AlignWithMargins = True
            Left = 6
            Top = 6
            Width = 52
            Height = 23
            Margins.Left = 6
            Margins.Top = 6
            Margins.Right = 8
            Align = alLeft
            Anchors = []
            Caption = 'IconColor'
            ExplicitHeight = 15
          end
          object TypicalPowerSavingsMonochromeCheckBox: TCheckBox
            AlignWithMargins = True
            Left = 69
            Top = 70
            Width = 204
            Height = 19
            Margins.Top = 6
            Caption = 'TypicalPowerSavingsMonochrome'
            TabOrder = 2
            OnClick = TypicalPowerSavingsMonochromeCheckBoxClick
          end
          object IconStyleExplicitMissingBatteryCheckBox: TCheckBox
            AlignWithMargins = True
            Left = 69
            Top = 96
            Width = 137
            Height = 19
            Margins.Top = 4
            Caption = 'ExplicitMissingBattery'
            TabOrder = 3
            OnClick = IconStyleExplicitMissingBatteryCheckBoxClick
          end
          object IconBehaviorPercentCheckBox: TCheckBox
            AlignWithMargins = True
            Left = 69
            Top = 122
            Width = 65
            Height = 19
            Margins.Top = 4
            Caption = 'Percent'
            TabOrder = 4
            OnClick = IconBehaviorPercentCheckBoxClick
          end
          object IconColorLevelsButton: TButton
            AlignWithMargins = True
            Left = 474
            Top = 2
            Width = 70
            Height = 25
            Margins.Left = 4
            Margins.Top = 2
            Margins.Right = 6
            Margins.Bottom = 5
            Align = alClient
            Caption = 'IconLevels'
            TabOrder = 5
            OnClick = IconColorLevelsButtonClick
          end
        end
      end
      object IndicatorGroup: TGroupBox
        AlignWithMargins = True
        Left = 8
        Top = 179
        Width = 554
        Height = 150
        Margins.Left = 8
        Margins.Right = 10
        Align = alTop
        Caption = 'Indicator'
        Padding.Top = 2
        Padding.Bottom = 6
        TabOrder = 1
        object IndicatorHelpLabel: TLabel
          AlignWithMargins = True
          Left = 9
          Top = 24
          Width = 536
          Height = 15
          Margins.Left = 7
          Margins.Top = 5
          Margins.Right = 7
          Align = alTop
          Caption = 'IndicatorHelpLabel'
          WordWrap = True
          ExplicitWidth = 100
        end
        object IndicatorNotDisplayRadioButton: TRadioButton
          AlignWithMargins = True
          Left = 9
          Top = 45
          Width = 536
          Height = 17
          Margins.Left = 7
          Margins.Right = 7
          Align = alTop
          Caption = 'NotDisplay'
          TabOrder = 0
          OnClick = IndicatorNotDisplayRadioButtonClick
        end
        object IndicatorPrimaryMonitorRadioButton: TRadioButton
          AlignWithMargins = True
          Left = 9
          Top = 68
          Width = 536
          Height = 17
          Margins.Left = 7
          Margins.Right = 7
          Align = alTop
          Caption = 'PrimaryMonitor'
          TabOrder = 1
          OnClick = IndicatorPrimaryMonitorRadioButtonClick
        end
        object IndicatorAllMonitorRadioButton: TRadioButton
          AlignWithMargins = True
          Left = 9
          Top = 91
          Width = 536
          Height = 17
          Margins.Left = 7
          Margins.Right = 7
          Align = alTop
          Caption = 'AllMonitor'
          TabOrder = 2
          OnClick = IndicatorAllMonitorRadioButtonClick
        end
        object IndicatorTransparencyPanel: TPanel
          AlignWithMargins = True
          Left = 9
          Top = 116
          Width = 536
          Height = 27
          Margins.Left = 7
          Margins.Top = 5
          Margins.Right = 7
          Margins.Bottom = 0
          Align = alTop
          BevelOuter = bvNone
          Caption = 'IndicatorTransparencyPanel'
          ShowCaption = False
          TabOrder = 3
          object IndicatorTransparencyLabel: TLabel
            AlignWithMargins = True
            Left = 0
            Top = 3
            Width = 144
            Height = 21
            Margins.Left = 0
            Align = alLeft
            Caption = 'IndicatorTransparencyLabel'
            ExplicitHeight = 15
          end
          object IndicatorTransparencyValueLabel: TLabel
            AlignWithMargins = True
            Left = 338
            Top = 3
            Width = 28
            Height = 21
            Align = alLeft
            Caption = 'Value'
            ExplicitHeight = 15
          end
          object IndicatorTransparencyTrackBar: TTrackBar
            AlignWithMargins = True
            Left = 150
            Top = 0
            Width = 182
            Height = 24
            Margins.Top = 0
            Align = alLeft
            Max = 16
            ShowSelRange = False
            TabOrder = 0
            TickStyle = tsNone
            OnChange = IndicatorTransparencyTrackBarChange
          end
        end
      end
      object MainWindowGroup: TGroupBox
        AlignWithMargins = True
        Left = 8
        Top = 335
        Width = 554
        Height = 81
        Margins.Left = 8
        Margins.Right = 10
        Align = alTop
        Caption = 'MainWindow'
        TabOrder = 2
        object MainWindowGrid: TGridPanel
          Left = 2
          Top = 17
          Width = 550
          Height = 62
          Align = alClient
          Alignment = taLeftJustify
          BevelOuter = bvNone
          Caption = 'MainWindowGrid'
          ColumnCollection = <
            item
              SizeStyle = ssAuto
              Value = 50.000000000000000000
            end
            item
              Value = 100.000000000000000000
            end
            item
              SizeStyle = ssAbsolute
              Value = 80.000000000000000000
            end>
          ControlCollection = <
            item
              Column = 0
              Control = MainWindowLinkTypeLabel
              Row = 0
            end
            item
              Column = 1
              Control = MainWindowLinkTypeComboBox
              Row = 0
            end
            item
              Column = 1
              Control = MainWindowDisableSystemBorderCheckBox
              Row = 1
            end>
          RowCollection = <
            item
              SizeStyle = ssAbsolute
              Value = 32.000000000000000000
            end
            item
              SizeStyle = ssAbsolute
              Value = 28.000000000000000000
            end>
          ShowCaption = False
          TabOrder = 0
          object MainWindowLinkTypeLabel: TLabel
            AlignWithMargins = True
            Left = 6
            Top = 6
            Width = 46
            Height = 23
            Margins.Left = 6
            Margins.Top = 6
            Margins.Right = 8
            Align = alLeft
            Caption = 'LinkType'
            ExplicitHeight = 15
          end
          object MainWindowLinkTypeComboBox: TComboBox
            AlignWithMargins = True
            Left = 63
            Top = 3
            Width = 404
            Height = 23
            Align = alClient
            Style = csDropDownList
            DropDownCount = 16
            TabOrder = 0
            OnChange = MainWindowLinkTypeComboBoxChange
          end
          object MainWindowDisableSystemBorderCheckBox: TCheckBox
            AlignWithMargins = True
            Left = 63
            Top = 34
            Width = 133
            Height = 23
            Margins.Top = 2
            Caption = 'DisableSystemBorder'
            TabOrder = 1
            OnClick = MainWindowDisableSystemBorderCheckBoxClick
          end
        end
      end
    end
    object SchemesTab: TTabSheet
      Caption = 'Schemes'
      ImageIndex = 3
      object SchemeFeaturesGroup: TGroupBox
        AlignWithMargins = True
        Left = 8
        Top = 3
        Width = 554
        Height = 190
        Margins.Left = 8
        Margins.Right = 10
        Margins.Bottom = 2
        Align = alTop
        Caption = 'SchemeFeatures'
        Padding.Top = 4
        Padding.Bottom = 2
        TabOrder = 0
        object SchemeFeatureMissingSchemePanel: TPanel
          Left = 2
          Top = 21
          Width = 550
          Height = 54
          Align = alTop
          AutoSize = True
          BevelOuter = bvNone
          Caption = 'SchemeFeatureMissingSchemePanel'
          ShowCaption = False
          TabOrder = 0
          object SchemeFeatureMissingSchemeHelpLabel: TLabel
            AlignWithMargins = True
            Left = 7
            Top = 3
            Width = 108
            Height = 15
            Margins.Left = 7
            Margins.Right = 7
            Margins.Bottom = 11
            Align = alTop
            Caption = 'MissingSchemeHelp'
            WordWrap = True
          end
          object SchemeFeatureMissingSchemeCheckPanel: TPanel
            AlignWithMargins = True
            Left = 7
            Top = 29
            Width = 536
            Height = 18
            Margins.Left = 7
            Margins.Top = 0
            Margins.Right = 7
            Margins.Bottom = 7
            Align = alTop
            BevelOuter = bvNone
            Caption = 'SchemeFeatureMissingSchemeCheckPanel'
            ShowCaption = False
            TabOrder = 0
            object SchemeFeatureMissingSchemeCheckBox: TCheckBox
              Left = 0
              Top = 0
              Width = 106
              Height = 18
              Margins.Left = 7
              Margins.Right = 7
              Align = alLeft
              Caption = 'MissingScheme'
              TabOrder = 0
              OnClick = SchemeFeatureMissingSchemeCheckBoxClick
            end
          end
        end
        object SchemeFeatureOverlayPanel: TPanel
          Left = 2
          Top = 75
          Width = 550
          Height = 54
          Align = alTop
          AutoSize = True
          BevelOuter = bvNone
          Caption = 'SchemeFeatureOverlayPanel'
          ShowCaption = False
          TabOrder = 1
          object SchemeFeatureOverlayHelpLabel: TLabel
            AlignWithMargins = True
            Left = 7
            Top = 3
            Width = 65
            Height = 15
            Margins.Left = 7
            Margins.Right = 7
            Margins.Bottom = 11
            Align = alTop
            Caption = 'OverlayHelp'
            WordWrap = True
          end
          object SchemeFeatureOverlayCheckPanel: TPanel
            AlignWithMargins = True
            Left = 7
            Top = 29
            Width = 536
            Height = 18
            Margins.Left = 7
            Margins.Top = 0
            Margins.Right = 7
            Margins.Bottom = 7
            Align = alTop
            BevelOuter = bvNone
            Caption = 'SchemeFeatureOverlayCheckPanel'
            ShowCaption = False
            TabOrder = 0
            object SchemeFeatureOverlayCheckBox: TCheckBox
              Left = 0
              Top = 0
              Width = 66
              Height = 18
              Align = alLeft
              Caption = 'Overlay'
              TabOrder = 0
              OnClick = SchemeFeatureOverlayCheckBoxClick
            end
          end
        end
        object SchemeFeatureHiddenSchemePanel: TPanel
          Left = 2
          Top = 129
          Width = 550
          Height = 54
          Align = alTop
          AutoSize = True
          BevelOuter = bvNone
          Caption = 'SchemeFeatureHiddenSchemePanel'
          ShowCaption = False
          TabOrder = 2
          object SchemeFeatureHiddenSchemeHelpLabel: TLabel
            AlignWithMargins = True
            Left = 7
            Top = 3
            Width = 106
            Height = 15
            Margins.Left = 7
            Margins.Right = 7
            Margins.Bottom = 11
            Align = alTop
            Caption = 'HiddenSchemeHelp'
            WordWrap = True
          end
          object SchemeFeatureHiddenSchemeCheckPanel: TPanel
            AlignWithMargins = True
            Left = 7
            Top = 29
            Width = 536
            Height = 18
            Margins.Left = 7
            Margins.Top = 0
            Margins.Right = 7
            Margins.Bottom = 7
            Align = alTop
            BevelOuter = bvNone
            Caption = 'SchemeFeatureHiddenSchemeCheckPanel'
            ShowCaption = False
            TabOrder = 0
            object SchemeFeatureHiddenSchemeCheckBox: TCheckBox
              Left = 0
              Top = 0
              Width = 106
              Height = 18
              Align = alLeft
              Caption = 'HiddenScheme'
              TabOrder = 0
              OnClick = SchemeFeatureHiddenSchemeCheckBoxClick
            end
          end
        end
      end
      object SchemeHotKeyGroup: TGroupBox
        AlignWithMargins = True
        Left = 8
        Top = 198
        Width = 554
        Height = 105
        Margins.Left = 8
        Margins.Right = 10
        Align = alTop
        Caption = 'SchemeHotKey'
        TabOrder = 1
        object SchemeHotKeyPanel: TPanel
          AlignWithMargins = True
          Left = 9
          Top = 21
          Width = 536
          Height = 56
          Margins.Left = 7
          Margins.Top = 4
          Margins.Right = 7
          Margins.Bottom = 4
          Align = alTop
          AutoSize = True
          BevelOuter = bvNone
          Caption = 'SchemeHotKeyPanel'
          ShowCaption = False
          TabOrder = 0
          object SchemeHotKeyHelpLabel: TLabel
            AlignWithMargins = True
            Left = 0
            Top = 3
            Width = 134
            Height = 15
            Margins.Left = 0
            Margins.Right = 7
            Align = alTop
            Caption = 'SchemeHotKeyHelpLabel'
            WordWrap = True
          end
          object SchemeHotKeyActionPanel: TPanel
            AlignWithMargins = True
            Left = 0
            Top = 24
            Width = 533
            Height = 25
            Margins.Left = 0
            Margins.Bottom = 7
            Align = alTop
            BevelOuter = bvNone
            Caption = 'SchemeHotKeyActionPanel'
            ShowCaption = False
            TabOrder = 0
            object SchemeHotKeyLabel: TLabel
              AlignWithMargins = True
              Left = 0
              Top = 5
              Width = 39
              Height = 15
              Margins.Left = 0
              Margins.Top = 5
              Align = alLeft
              Caption = 'HotKey'
              Layout = tlCenter
            end
            object SchemeHotKeyButton: TButton
              AlignWithMargins = True
              Left = 45
              Top = 0
              Width = 75
              Height = 25
              Margins.Top = 0
              Margins.Bottom = 0
              Align = alLeft
              Caption = 'HotKey'
              TabOrder = 0
              OnClick = SchemeHotKeyButtonClick
            end
          end
        end
      end
    end
    object BrightnessTab: TTabSheet
      Margins.Right = 5
      Caption = 'Brightness'
      ImageIndex = 1
      object BrightnessScrollBox: TScrollBox
        Left = 0
        Top = 0
        Width = 572
        Height = 493
        HorzScrollBar.Visible = False
        VertScrollBar.Tracking = True
        Align = alClient
        BevelInner = bvNone
        BevelOuter = bvNone
        BorderStyle = bsNone
        ParentBackground = True
        TabOrder = 0
        object BrightnessSliderGroup: TGroupBox
          AlignWithMargins = True
          Left = 8
          Top = 3
          Width = 554
          Height = 104
          Margins.Left = 8
          Margins.Right = 10
          Align = alTop
          Caption = 'BrightnessSlider'
          Padding.Bottom = 7
          TabOrder = 0
          object BrightnessSliderMonitorNameCheckPanel: TPanel
            AlignWithMargins = True
            Left = 9
            Top = 21
            Width = 536
            Height = 18
            Margins.Left = 7
            Margins.Top = 4
            Margins.Right = 7
            Margins.Bottom = 4
            Align = alTop
            BevelOuter = bvNone
            Caption = 'BrightnessSliderMonitorNameCheckPanel'
            ShowCaption = False
            TabOrder = 0
            object BrightnessSliderMonitorNameCheckBox: TCheckBox
              Left = 0
              Top = 0
              Width = 97
              Height = 18
              Margins.Left = 7
              Margins.Right = 7
              Align = alLeft
              Caption = 'MonitorName'
              TabOrder = 0
              OnClick = BrightnessSliderMonitorNameCheckBoxClick
            end
          end
          object BrightnessSliderPercentCheckPanel: TPanel
            AlignWithMargins = True
            Left = 9
            Top = 47
            Width = 536
            Height = 18
            Margins.Left = 7
            Margins.Top = 4
            Margins.Right = 7
            Margins.Bottom = 4
            Align = alTop
            BevelOuter = bvNone
            Caption = 'BrightnessSliderPercentCheckPanel'
            ShowCaption = False
            TabOrder = 1
            object BrightnessSliderPercentCheckBox: TCheckBox
              Left = 0
              Top = 0
              Width = 97
              Height = 18
              Margins.Left = 7
              Margins.Right = 7
              Align = alLeft
              Caption = 'Percent'
              TabOrder = 0
              OnClick = BrightnessSliderPercentCheckBoxClick
            end
          end
          object ShowBrightnessInTrayHintPanel: TPanel
            AlignWithMargins = True
            Left = 9
            Top = 73
            Width = 536
            Height = 18
            Margins.Left = 7
            Margins.Top = 4
            Margins.Right = 7
            Margins.Bottom = 4
            Align = alTop
            BevelOuter = bvNone
            ShowCaption = False
            TabOrder = 2
            object ShowBrightnessInTrayHintCheckBox: TCheckBox
              Left = 0
              Top = 0
              Width = 161
              Height = 18
              Margins.Left = 7
              Margins.Right = 7
              Align = alLeft
              Caption = 'ShowBrightnessInTrayHint'
              TabOrder = 0
              OnClick = ShowBrightnessInTrayHintCheckBoxClick
            end
          end
        end
        object BrightnessMonitorGroup: TGroupBox
          AlignWithMargins = True
          Left = 8
          Top = 113
          Width = 554
          Height = 44
          Margins.Left = 8
          Margins.Right = 10
          Align = alTop
          Caption = 'Monitor'
          Padding.Bottom = 7
          TabOrder = 1
        end
        object BrightnessFixedGroup: TGroupBox
          AlignWithMargins = True
          Left = 8
          Top = 163
          Width = 554
          Height = 105
          Margins.Left = 8
          Margins.Right = 10
          Align = alTop
          Caption = 'BrightnessFixed'
          Padding.Bottom = 6
          TabOrder = 2
          object BrightnessFixedHelpLabel: TLabel
            AlignWithMargins = True
            Left = 9
            Top = 24
            Width = 136
            Height = 15
            Margins.Left = 7
            Margins.Top = 7
            Margins.Right = 7
            Margins.Bottom = 7
            Align = alTop
            Caption = 'BrightnessFixedHelpLabel'
            WordWrap = True
          end
          object BrightnessFixedCheckPanel: TPanel
            AlignWithMargins = True
            Left = 9
            Top = 50
            Width = 536
            Height = 18
            Margins.Left = 7
            Margins.Top = 4
            Margins.Right = 7
            Margins.Bottom = 7
            Align = alTop
            AutoSize = True
            BevelOuter = bvNone
            Caption = 'BrightnessFixedCheckPanel'
            ShowCaption = False
            TabOrder = 0
            object BrightnessFixedCheckBox: TCheckBox
              Left = 0
              Top = 0
              Width = 536
              Height = 18
              Align = alTop
              Caption = 'FixedBrightness'
              TabOrder = 0
              WordWrap = True
              OnClick = BrightnessFixedCheckBoxClick
            end
          end
        end
        object BrightnessOptionsGroup: TGroupBox
          AlignWithMargins = True
          Left = 8
          Top = 274
          Width = 554
          Height = 89
          Margins.Left = 8
          Margins.Right = 10
          Align = alTop
          Caption = 'BrightnessOptions'
          Padding.Bottom = 7
          TabOrder = 3
          object BrightnessRescanDelayHelpLabel: TLabel
            AlignWithMargins = True
            Left = 8
            Top = 24
            Width = 146
            Height = 15
            Margins.Left = 6
            Margins.Top = 7
            Margins.Right = 7
            Margins.Bottom = 7
            Align = alTop
            Caption = 'BrightnessRescanDelayHelp'
            WordWrap = True
          end
          object BrightnessRescanDelayPanel: TPanel
            AlignWithMargins = True
            Left = 2
            Top = 46
            Width = 550
            Height = 27
            Margins.Left = 0
            Margins.Top = 0
            Margins.Right = 0
            Align = alTop
            BevelOuter = bvNone
            ShowCaption = False
            TabOrder = 0
            object BrightnessRescanDelayLabel: TLabel
              AlignWithMargins = True
              Left = 6
              Top = 6
              Width = 121
              Height = 15
              Margins.Left = 6
              Margins.Top = 6
              Margins.Right = 8
              Align = alLeft
              Anchors = []
              Caption = 'BrightnessRescanDelay'
            end
            object BrightnessRescanDelayUnitsLabel: TLabel
              AlignWithMargins = True
              Left = 213
              Top = 6
              Width = 44
              Height = 15
              Margins.Left = 20
              Margins.Top = 6
              Margins.Right = 8
              Align = alLeft
              Anchors = []
              Caption = 'Seconds'
            end
            object BrightnessRescanDelayEdit: TEdit
              AlignWithMargins = True
              Left = 138
              Top = 3
              Width = 52
              Height = 22
              Margins.Bottom = 2
              Align = alLeft
              Alignment = taCenter
              MaxLength = 3
              NumbersOnly = True
              TabOrder = 0
              Text = '1'
              OnChange = BrightnessRescanDelayEditChange
              OnExit = BrightnessRescanDelayEditExit
            end
            object BrightnessRescanDelayUpDown: TUpDown
              Left = 190
              Top = 3
              Width = 17
              Height = 22
              Associate = BrightnessRescanDelayEdit
              Min = 1
              Max = 50
              Position = 1
              TabOrder = 1
            end
          end
        end
      end
    end
    object AutoUpdateTab: TTabSheet
      Caption = 'AutoUpdate'
      ImageIndex = 2
      object AppCurrentVersionLabel: TLabel
        Left = 8
        Top = 71
        Width = 100
        Height = 15
        Caption = 'AppCurrentVersion'
        Font.Charset = RUSSIAN_CHARSET
        Font.Color = clGray
        Font.Height = -12
        Font.Name = 'Segoe UI'
        Font.Style = []
        ParentFont = False
      end
      object AutoUpdateEnabledCheckBox: TCheckBox
        Left = 8
        Top = 11
        Width = 69
        Height = 17
        Caption = 'Enabled'
        TabOrder = 0
        OnClick = AutoUpdateEnabledCheckBoxClick
      end
      object AutoUpdateCheckButton: TButton
        Left = 7
        Top = 38
        Width = 75
        Height = 25
        Caption = 'Check'
        TabOrder = 1
        OnClick = AutoUpdateCheckButtonClick
      end
    end
    object AboutTab: TTabSheet
      Caption = 'About'
      ImageIndex = 4
      object AboutIconPanel: TPanel
        AlignWithMargins = True
        Left = 3
        Top = 3
        Width = 62
        Height = 487
        Align = alLeft
        AutoSize = True
        BevelOuter = bvNone
        Caption = 'AboutIconPanel'
        Padding.Left = 15
        Padding.Top = 12
        Padding.Right = 15
        Padding.Bottom = 20
        ShowCaption = False
        TabOrder = 0
        object AppImage: TImage
          Left = 15
          Top = 12
          Width = 32
          Height = 455
          Align = alLeft
          AutoSize = True
          ExplicitLeft = 0
          ExplicitTop = 0
          ExplicitHeight = 368
        end
      end
      object AboutPanel: TPanel
        Left = 68
        Top = 0
        Width = 504
        Height = 493
        Align = alClient
        BevelOuter = bvNone
        Caption = 'AppImagePanel'
        Padding.Top = 16
        Padding.Right = 16
        ShowCaption = False
        TabOrder = 1
        object AppNameLabel: TLabel
          Left = 0
          Top = 16
          Width = 68
          Height = 20
          Align = alTop
          Caption = 'AppName'
          Font.Charset = RUSSIAN_CHARSET
          Font.Color = clHotLight
          Font.Height = -15
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object AppVersionLabel: TLabel
          AlignWithMargins = True
          Left = 0
          Top = 42
          Width = 60
          Height = 15
          Margins.Left = 0
          Margins.Top = 6
          Margins.Right = 0
          Align = alTop
          Caption = 'AppVersion'
        end
        object AppAuthorLabel: TLabel
          AlignWithMargins = True
          Left = 0
          Top = 64
          Width = 59
          Height = 15
          Margins.Left = 0
          Margins.Top = 4
          Margins.Right = 0
          Align = alTop
          Caption = 'AppAuthor'
        end
        object AppCopyrightLabel: TLabel
          AlignWithMargins = True
          Left = 0
          Top = 86
          Width = 75
          Height = 15
          Margins.Left = 0
          Margins.Top = 4
          Margins.Right = 0
          Align = alTop
          Caption = 'AppCopyright'
        end
        object LinksGrid: TGridPanel
          AlignWithMargins = True
          Left = 0
          Top = 107
          Width = 485
          Height = 118
          Margins.Left = 0
          Align = alTop
          Alignment = taLeftJustify
          BevelOuter = bvNone
          Caption = 'LinksGrid'
          ColumnCollection = <
            item
              Value = 50.000000000000000000
            end
            item
              Value = 50.000000000000000000
            end>
          ControlCollection = <
            item
              Column = 0
              Control = AppSiteLink
              Row = 0
            end
            item
              Column = 0
              Control = AppHelpLink
              Row = 1
            end
            item
              Column = 1
              Control = AppFeedbackLink
              Row = 0
            end
            item
              Column = 1
              Control = AppDonateLink
              Row = 1
            end
            item
              Column = 0
              Control = AppSchedulerLink
              Row = 2
            end
            item
              Column = 0
              Control = AppChangelog
              Row = 3
            end
            item
              Column = 0
              Control = AppLicense
              Row = 4
            end
            item
              Column = 1
              Control = AppSourceCodeLink
              Row = 2
            end>
          DoubleBuffered = False
          ParentDoubleBuffered = False
          RowCollection = <
            item
              SizeStyle = ssAbsolute
              Value = 23.000000000000000000
            end
            item
              SizeStyle = ssAbsolute
              Value = 23.000000000000000000
            end
            item
              SizeStyle = ssAbsolute
              Value = 23.000000000000000000
            end
            item
              SizeStyle = ssAbsolute
              Value = 23.000000000000000000
            end
            item
              SizeStyle = ssAbsolute
              Value = 23.000000000000000000
            end>
          ShowCaption = False
          TabOrder = 0
          object AppSiteLink: TStaticText
            AlignWithMargins = True
            Left = 0
            Top = 0
            Width = 67
            Height = 19
            Margins.Left = 0
            Margins.Top = 0
            Margins.Right = 0
            Margins.Bottom = 4
            Align = alLeft
            Anchors = []
            Caption = 'AppSiteLink'
            TabOrder = 0
            TabStop = True
            OnClick = AppSiteLinkClick
          end
          object AppHelpLink: TStaticText
            AlignWithMargins = True
            Left = 0
            Top = 23
            Width = 73
            Height = 19
            Margins.Left = 0
            Margins.Top = 0
            Margins.Right = 0
            Margins.Bottom = 4
            Align = alLeft
            Anchors = []
            Caption = 'AppHelpLink'
            TabOrder = 1
            TabStop = True
            OnClick = AppHelpLinkClick
          end
          object AppFeedbackLink: TStaticText
            AlignWithMargins = True
            Left = 242
            Top = 0
            Width = 98
            Height = 19
            Margins.Left = 0
            Margins.Top = 0
            Margins.Right = 0
            Margins.Bottom = 4
            Align = alLeft
            Anchors = []
            Caption = 'AppFeedbackLink'
            TabOrder = 5
            TabStop = True
            OnClick = AppFeedbackLinkClick
          end
          object AppDonateLink: TStaticText
            AlignWithMargins = True
            Left = 242
            Top = 23
            Width = 86
            Height = 19
            Margins.Left = 0
            Margins.Top = 0
            Margins.Right = 0
            Margins.Bottom = 4
            Align = alLeft
            Anchors = []
            Caption = 'AppDonateLink'
            TabOrder = 6
            TabStop = True
            OnClick = AppDonateLinkClick
          end
          object AppSchedulerLink: TStaticText
            AlignWithMargins = True
            Left = 0
            Top = 46
            Width = 100
            Height = 19
            Margins.Left = 0
            Margins.Top = 0
            Margins.Right = 0
            Margins.Bottom = 4
            Align = alLeft
            Anchors = []
            Caption = 'AppSchedulerLink'
            TabOrder = 2
            TabStop = True
            OnClick = AppSchedulerLinkClick
          end
          object AppChangelog: TStaticText
            AlignWithMargins = True
            Left = 0
            Top = 69
            Width = 84
            Height = 19
            Margins.Left = 0
            Margins.Top = 0
            Margins.Right = 0
            Margins.Bottom = 4
            Align = alLeft
            Anchors = []
            Caption = 'AppChangelog'
            TabOrder = 3
            TabStop = True
            OnClick = AppChangelogClick
          end
          object AppLicense: TStaticText
            AlignWithMargins = True
            Left = 0
            Top = 92
            Width = 65
            Height = 19
            Margins.Left = 0
            Margins.Top = 0
            Margins.Right = 0
            Margins.Bottom = 4
            Align = alLeft
            Anchors = []
            Caption = 'AppLicense'
            TabOrder = 4
            OnClick = AppLicenseClick
          end
          object AppSourceCodeLink: TStaticText
            AlignWithMargins = True
            Left = 242
            Top = 46
            Width = 112
            Height = 19
            Margins.Left = 0
            Margins.Top = 0
            Margins.Right = 0
            Margins.Bottom = 4
            Align = alLeft
            Anchors = []
            Caption = 'AppSourceCodeLink'
            TabOrder = 7
            TabStop = True
            OnClick = AppSourceCodeLinkClick
          end
        end
      end
    end
  end
  object MainMenu: TMainMenu
    Left = 24
    Top = 472
    object MainMenuFile: TMenuItem
      Caption = 'File'
      object MainMenuExportConfigToFile: TMenuItem
        Caption = 'ExportConfigToFile'
        OnClick = MainMenuExportConfigToFileClick
      end
      object MainMenuImportConfigFromFile: TMenuItem
        Caption = 'ImportConfigToFile'
        OnClick = MainMenuImportConfigFromFileClick
      end
      object MainMenuClose: TMenuItem
        Caption = 'Close'
        ShortCut = 27
        OnClick = MainMenuCloseClick
      end
    end
  end
  object ExportConfigDialog: TSaveDialog
    DefaultExt = 'reg'
    Filter = 'REG|*.reg|Text|*.txt|All files|*.*'
    Options = [ofOverwritePrompt, ofHideReadOnly, ofEnableSizing]
    Left = 104
    Top = 473
  end
  object ImportConfigDialog: TOpenDialog
    DefaultExt = 'reg'
    Filter = 'REG|*.reg|Text|*.txt|All files|*.*'
    Options = [ofEnableSizing]
    Left = 200
    Top = 473
  end
end
