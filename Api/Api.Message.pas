unit Api.Message;

interface

uses
  WinApi.Messages;

const
  MainWindowName = 'BatteryModeForm';
  MainWindowClass = 'TBatteryModeForm';

  /// <summary>
  ///  Сообщение переключения схемы электропитания.
  /// </summary>
  /// <param name="wParam">
  ///  Тип переключения схемы электропитания.
  ///  Задаётся перечислением TNextSchemeType
  /// </param>
  /// <param name="lParam">
  ///  This parameter is not used.
  /// </param>
  /// <returns>
  ///  Если выполнено успешно, то возвращается
  ///  NextSchemeConfirm = 1
  /// </returns>
  WM_NEXT_SCHEME = WM_USER + 1;
  NextSchemeConfirm = 1;

  CmdNextScheme           = '-Next';
  CmdMaxPowerSavings      = '-Economy';
  CmdTypicalPowerSavings  = '-Typical';
  CmdMinPowerSavings      = '-Performance';

type
  TNextSchemeType = (nstNext,
                     nstMaxPowerSavings,
                     nstTypicalPowerSavings,
                     nstMinPowerSavings);

implementation

end.
