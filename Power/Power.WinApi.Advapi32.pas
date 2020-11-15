unit Power.WinApi.Advapi32;

interface

uses
  Winapi.Windows;

const
  SHUTDOWN_FORCE_OTHERS     = $00000001;  // All sessions are forcefully logged off.
                                          // If this flag is not set and users other than the current user are logged on to the computer
                                          // specified by the lpMachineName parameter, this function fails with a
                                          // return value of ERROR_SHUTDOWN_USERS_LOGGED_ON.

  SHUTDOWN_FORCE_SELF       = $00000002;  // Specifies that the originating session is logged off forcefully.
                                          // If this flag is not set, the originating session is shut down interactively,
                                          // so a shutdown is not guaranteed even if the function returns successfully.

  SHUTDOWN_GRACE_OVERRIDE   = $00000020;  // Overrides the grace period so that the computer is shut down immediately.

  SHUTDOWN_HYBRID           = $00000200;  // Beginning with InitiateShutdown running on Windows 8,
                                          // you must include the SHUTDOWN_HYBRID flag with one or more of the flags in this table
                                          // to specify options for the shutdown.
                                          // Beginning with Windows 8, InitiateShutdown always initiate a full system shutdown
                                          // if the SHUTDOWN_HYBRID flag is absent.

  SHUTDOWN_INSTALL_UPDATES  = $00000040;  // The computer installs any updates before starting the shutdown.

  SHUTDOWN_NOREBOOT         = $00000010;  // The computer is shut down but is not powered down or rebooted.

  SHUTDOWN_POWEROFF         = $00000008;  // The computer is shut down and powered down.

  SHUTDOWN_RESTART          = $00000004;  // The computer is shut down and rebooted.

  SHUTDOWN_RESTARTAPPS      = $00000080;  // The system is rebooted using the ExitWindowsEx function with the EWX_RESTARTAPPS flag.
                                          // This restarts any applications that have been registered for restart
                                          // using the RegisterApplicationRestart function.

  SHUTDOWN_DIAGNOSTIC       = $00000400;

{$EXTERNALSYM InitiateShutdown}
function InitiateShutdown(
  lpMachineName: LPTSTR;
  lpMessage: LPTSTR;
  dwGracePeriod: DWORD;
  dwShutdownFlags: DWORD;
  dwReason: DWORD): DWORD; stdcall;

implementation

{$WARN SYMBOL_PLATFORM OFF}
function InitiateShutdown; external advapi32
  {$IFDEF UNICODE}
  name 'InitiateShutdownW'
  {$ELSE}
  name 'InitiateShutdownA'
  {$ENDIF}
  delayed;
{$WARN SYMBOL_PLATFORM ON}

end.
