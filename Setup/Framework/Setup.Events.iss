#ifndef _SetupEvents
	#define _SetupEvents

[Code]

//
// Setup events
//

type
	// TInitializeSetupEvent not implemented;

	// Use this event function to make changes to the wizard or wizard pages at startup.
	// You can't use the InitializeSetup event function for this since at the time it is triggered, the wizard form does not yet exist.
	TInitializeWizardEvent = procedure();

	//Called just before Setup terminates. Note that this function is called even if the user exits Setup before anything is installed.
	TDeinitializeSetupEvent = procedure();

	// You can use this event function to perform your own pre-install and post-install tasks.
	//
	// Called with CurStep=ssInstall just before the actual installation starts,
	// with CurStep=ssPostInstall just after the actual installation finishes,
	// and with CurStep=ssDone just before Setup terminates after a successful install.
	TCurStepChangedEvent = procedure(CurStep: TSetupStep);

	// You can use this event function to monitor progress while Setup is extracting files,
	// creating shortcuts, creating INI entries, and creating registry entries.
	TCurInstallProgressChangedEvent = procedure(CurProgress, MaxProgress: Integer);

	// Called when the user clicks the Next button. If you return True, the wizard will move to the next page;
	//if you return False, it will remain on the current page (specified by CurPageID).
	//
	// Note that this function is called on silent installs as well, even though there is no Next button that the user can click.
	// Setup instead simulates "clicks" on the Next button.
	// On a silent install, if your NextButtonClick function returns False prior to installation starting, Setup will exit automatically.
	TNextButtonClickEvent = function(CurPageID: Integer): Boolean;

	// Called when the user clicks the Back button.
	// If you return True, the wizard will move to the previous page;
	// if you return False, it will remain on the current page (specified by CurPageID).
	TBackButtonClickEvent = function(CurPageID: Integer): Boolean;

	// Called when the user clicks the Cancel button or clicks the window's Close button.
	// The Cancel parameter specifies whether normal cancel processing should occur; it defaults to True.
	// The Confirm parameter specifies whether an "Exit Setup?" message box should be displayed; it usually defaults to True.
	// If Cancel is set to False, then the value of Confirm is ignored.
	TCancelButtonClickEvent = procedure(CurPageID: Integer; var Cancel, Confirm: Boolean);

	// The wizard calls this event function to determine whether or not a particular page (specified by PageID) should be shown at all.
	// If you return True, the page will be skipped; if you return False, the page may be shown.
	//
	// Note: This event function isn't called for the wpPreparing, and wpInstalling pages,
	// nor for pages that Setup has already determined should be skipped (for example, wpSelectComponents in an install containing no components).
	TShouldSkipPageEvent = function(PageID: Integer): Boolean;

	// Called after a new wizard page (specified by CurPageID) is shown.
	TCurPageChangedEvent = procedure(CurPageID: Integer);

	// TCheckPasswordEvent not implemented;

	// Return True to instruct Setup to prompt the user to restart the system at the end of a successful installation, False otherwise.
	TNeedRestartEvent = function(): Boolean;

	// TUpdateReadyMemoEvent not implemented;

	// To store user settings entered on custom wizard pages, place a RegisterPreviousData event function in the Pascal script and call SetPreviousData(PreviousDataKey, ...) inside it, once per setting.
	TRegisterPreviousDataEvent = procedure(PreviousDataKey: Integer);

	// TCheckSerialEvent not implemented;

	//TGetCustomSetupExitCodeEvent not implemented;

	//TPrepareToInstallEvent not implemented;

	// To register extra files which Setup should check for being in-use if CloseApplications is set to yes,
	// place a RegisterExtraCloseApplicationsResources event function in the Pascal script
	// and call RegisterExtraCloseApplicationsResource inside it, once per file.
	TRegisterExtraCloseApplicationsResourcesEvent = procedure();

//
// Uninstall events
//

type
	// TInitializeUninstallEvent not implemented;

	// Use this event function to make changes to the progress form at startup.
	// You can't use the InitializeUninstall event function for this since at the time it is triggered, the progress form does not yet exist.
	TInitializeUninstallProgressFormEvent = procedure();

	TDeinitializeUninstallEvent = procedure();
	
	TCurUninstallStepChangedEvent = procedure(CurUninstallStep: TUninstallStep);
	
	// Return True to instruct Uninstall to prompt the user to restart the system at the end of a successful uninstallation, False otherwise.	
	TUninstallNeedRestartEvent = function(): Boolean;



//
// Setup delegates
//
var
	_InitializeWizardDelegate: array of TInitializeWizardEvent;
	_DeinitializeSetupDelegate: array of TDeinitializeSetupEvent;
	_CurStepChangedDelegate: array of TCurStepChangedEvent;
	_CurInstallProgressChangedDelegate: array of TCurInstallProgressChangedEvent;
	_NextButtonClickDelegate: array of TNextButtonClickEvent;
	_BackButtonClickDelegate: array of TBackButtonClickEvent;
	_CancelButtonClickDelegate: array of TCancelButtonClickEvent;
	_ShouldSkipPageDelegate: array of TShouldSkipPageEvent;
	_CurPageChangedDelegate: array of TCurPageChangedEvent;
	_NeedRestartDelegate: array of TNeedRestartEvent;
	_RegisterPreviousDataDelegate: array of TRegisterPreviousDataEvent;
	_RegisterExtraCloseApplicationsResourcesDelegate: array of TRegisterExtraCloseApplicationsResourcesEvent;

//
// Uninstall delegates
//
var
	_InitializeUninstallProgressFormDelegate: array of TInitializeUninstallProgressFormEvent;
	_DeinitializeUninstallDelegate: array of TDeinitializeUninstallEvent;
	_CurUninstallStepChangedDelegate: array of TCurUninstallStepChangedEvent;
	_UninstallNeedRestartDelegate: array of TUninstallNeedRestartEvent;


		
//
// Setup event connectors
//

procedure ConnectOnInitializeWizard(Event: TInitializeWizardEvent);
begin
	SetLength(_InitializeWizardDelegate, Length(_InitializeWizardDelegate) + 1);
	_InitializeWizardDelegate[High(_InitializeWizardDelegate)] := Event;
end;

procedure ConnectOnDeinitializeSetup(Event: TDeinitializeSetupEvent);
begin
	SetLength(_DeinitializeSetupDelegate, Length(_DeinitializeSetupDelegate) + 1);
	_DeinitializeSetupDelegate[High(_DeinitializeSetupDelegate)] := Event;
end;

procedure ConnectOnCurStepChanged(Event: TCurStepChangedEvent);
begin
	SetLength(_CurStepChangedDelegate, Length(_CurStepChangedDelegate) + 1);
	_CurStepChangedDelegate[High(_CurStepChangedDelegate)] := Event;
end;

procedure ConnectOnCurInstallProgressChanged(Event: TCurInstallProgressChangedEvent);
begin
	SetLength(_CurInstallProgressChangedDelegate, Length(_CurInstallProgressChangedDelegate) + 1);
	_CurInstallProgressChangedDelegate[High(_CurInstallProgressChangedDelegate)] := Event;
end;

procedure ConnectOnNextButtonClick(Event: TNextButtonClickEvent);
begin
	SetLength(_NextButtonClickDelegate, Length(_NextButtonClickDelegate) + 1);
	_NextButtonClickDelegate[High(_NextButtonClickDelegate)] := Event;
end;

procedure ConnectOnBackButtonClick(Event: TBackButtonClickEvent);
begin
	SetLength(_BackButtonClickDelegate, Length(_BackButtonClickDelegate) + 1);
	_BackButtonClickDelegate[High(_BackButtonClickDelegate)] := Event;
end;

procedure ConnectOnCancelButtonClick(Event: TCancelButtonClickEvent);
begin
	SetLength(_CancelButtonClickDelegate, Length(_CancelButtonClickDelegate) + 1);
	_CancelButtonClickDelegate[High(_CancelButtonClickDelegate)] := Event;
end;

procedure ConnectOnShouldSkipPage(Event: TShouldSkipPageEvent);
begin
	SetLength(_ShouldSkipPageDelegate, Length(_ShouldSkipPageDelegate) + 1);
	_ShouldSkipPageDelegate[High(_ShouldSkipPageDelegate)] := Event;
end;

procedure ConnectOnCurPageChanged(Event: TCurPageChangedEvent);
begin
	SetLength(_CurPageChangedDelegate, Length(_CurPageChangedDelegate) + 1);
	_CurPageChangedDelegate[High(_CurPageChangedDelegate)] := Event;
end;

procedure ConnectOnNeedRestart(Event: TNeedRestartEvent);
begin
	SetLength(_NeedRestartDelegate, Length(_NeedRestartDelegate) + 1);
	_NeedRestartDelegate[High(_NeedRestartDelegate)] := Event;
end;

procedure ConnectOnRegisterPreviousData(Event: TRegisterPreviousDataEvent);
begin
	SetLength(_RegisterPreviousDataDelegate, Length(_RegisterPreviousDataDelegate) + 1);
	_RegisterPreviousDataDelegate[High(_RegisterPreviousDataDelegate)] := Event;
end;

procedure ConnectOnRegisterExtraCloseApplicationsResources(Event: TRegisterExtraCloseApplicationsResourcesEvent);
begin
	SetLength(_RegisterExtraCloseApplicationsResourcesDelegate, Length(_RegisterExtraCloseApplicationsResourcesDelegate) + 1);
	_RegisterExtraCloseApplicationsResourcesDelegate[High(_RegisterExtraCloseApplicationsResourcesDelegate)] := Event;
end;

//
// Uninstall event connectors
//

procedure ConnectOnInitializeUninstallProgressForm(Event: TInitializeUninstallProgressFormEvent);
begin
	SetLength(_InitializeUninstallProgressFormDelegate, Length(_InitializeUninstallProgressFormDelegate) + 1);
	_InitializeUninstallProgressFormDelegate[High(_InitializeUninstallProgressFormDelegate)] := Event;
end;

procedure ConnectOnDeinitializeUninstall(Event: TDeinitializeUninstallEvent);
begin
	SetLength(_DeinitializeUninstallDelegate, Length(_DeinitializeUninstallDelegate) + 1);
	_DeinitializeUninstallDelegate[High(_DeinitializeUninstallDelegate)] := Event;
end;

procedure ConnectOnCurUninstallStepChanged(Event: TCurUninstallStepChangedEvent);
begin
	SetLength(_CurUninstallStepChangedDelegate, Length(_CurUninstallStepChangedDelegate) + 1);
	_CurUninstallStepChangedDelegate[High(_CurUninstallStepChangedDelegate)] := Event;
end;

procedure ConnectOnUninstallNeedRestart(Event: TUninstallNeedRestartEvent);
begin
	SetLength(_UninstallNeedRestartDelegate, Length(_UninstallNeedRestartDelegate) + 1);
	_UninstallNeedRestartDelegate[High(_UninstallNeedRestartDelegate)] := Event;
end;



//
// Setup event functions override
//

// Use this event function to make changes to the wizard or wizard pages at startup.
// You can't use the InitializeSetup event function for this since at the time it is triggered, the wizard form does not yet exist.
procedure InitializeWizard();
var
	I: Integer;
begin
	for I := 0 to High(_InitializeWizardDelegate) do
		_InitializeWizardDelegate[I]();
end;

//Called just before Setup terminates. Note that this function is called even if the user exits Setup before anything is installed.
procedure DeinitializeSetup();
var
	I: Integer;
begin
	for I := 0 to High(_DeinitializeSetupDelegate) do
		_DeinitializeSetupDelegate[I]();
end;

// You can use this event function to perform your own pre-install and post-install tasks.
//
// Called with CurStep=ssInstall just before the actual installation starts,
// with CurStep=ssPostInstall just after the actual installation finishes,
// and with CurStep=ssDone just before Setup terminates after a successful install.
procedure CurStepChanged(CurStep: TSetupStep);
var
	I: Integer;
begin
	for I := 0 to High(_CurStepChangedDelegate) do
		_CurStepChangedDelegate[I](CurStep);
end;

// You can use this event function to monitor progress while Setup is extracting files,
// creating shortcuts, creating INI entries, and creating registry entries.
procedure CurInstallProgressChanged(CurProgress, MaxProgress: Integer);
var
	I: Integer;
begin
	for I := 0 to High(_CurInstallProgressChangedDelegate) do
		_CurInstallProgressChangedDelegate[I](CurProgress, MaxProgress);
end;

// Called when the user clicks the Next button. If you return True, the wizard will move to the next page;
// if you return False, it will remain on the current page (specified by CurPageID).
//
// Note that this function is called on silent installs as well, even though there is no Next button that the user can click.
// Setup instead simulates "clicks" on the Next button.
// On a silent install, if your NextButtonClick function returns False prior to installation starting, Setup will exit automatically.
function NextButtonClick(CurPageID: Integer): Boolean;
var
	I: Integer;
begin
	Result := True;
	for I := 0 to High(_NextButtonClickDelegate) do
	begin
		Result := _NextButtonClickDelegate[I](CurPageID);
		if not Result then Break;
	end;
end;

// Called when the user clicks the Back button.
// If you return True, the wizard will move to the previous page;
// if you return False, it will remain on the current page (specified by CurPageID).
function BackButtonClick(CurPageID: Integer): Boolean;
var
	I: Integer;
begin
	Result := True;
	for I := 0 to High(_BackButtonClickDelegate) do
	begin
		Result := _BackButtonClickDelegate[I](CurPageID);
		if not Result then Break;
	end;
end;

// Called when the user clicks the Cancel button or clicks the window's Close button.
// The Cancel parameter specifies whether normal cancel processing should occur; it defaults to True.
// The Confirm parameter specifies whether an "Exit Setup?" message box should be displayed; it usually defaults to True.
// If Cancel is set to False, then the value of Confirm is ignored.
procedure CancelButtonClick(CurPageID: Integer; var Cancel, Confirm: Boolean);
var
	I: Integer;
begin
	for I := 0 to High(_CancelButtonClickDelegate) do
	begin
		_CancelButtonClickDelegate[I](CurPageID, Cancel, Confirm);
		if Cancel then Break;
	end;
end;

// The wizard calls this event function to determine whether or not a particular page (specified by PageID) should be shown at all.
// If you return True, the page will be skipped; if you return False, the page may be shown.
//
// Note: This event function isn't called for the wpPreparing, and wpInstalling pages,
// nor for pages that Setup has already determined should be skipped (for example, wpSelectComponents in an install containing no components).
function ShouldSkipPage(PageID: Integer): Boolean;
var
	I: Integer;
begin
	Result := False;
	for I := 0 to High(_ShouldSkipPageDelegate) do
	begin
		Result := _ShouldSkipPageDelegate[I](PageID);
		if Result then Break;
	end;
end;

// Called after a new wizard page (specified by CurPageID) is shown.
procedure CurPageChanged(CurPageID: Integer);
var
	I: Integer;
begin
	for I := 0 to High(_CurPageChangedDelegate) do
		_CurPageChangedDelegate[I](CurPageID);
end;

// Return True to instruct Setup to prompt the user to restart the system at the end of a successful installation, False otherwise.
function NeedRestart(): Boolean;
var
	I: Integer;
begin
	Result := False;
	for I := 0 to High(_NeedRestartDelegate) do
	begin
		Result := _NeedRestartDelegate[I]();
		if Result then Break;
	end;
end;

// To store user settings entered on custom wizard pages, place a RegisterPreviousData event function in the Pascal script and call SetPreviousData(PreviousDataKey, ...) inside it, once per setting.
procedure RegisterPreviousData(PreviousDataKey: Integer);
var
	I: Integer;
begin
	for I := 0 to High(_RegisterPreviousDataDelegate) do
		_RegisterPreviousDataDelegate[I](PreviousDataKey);
end;

// To register extra files which Setup should check for being in-use if CloseApplications is set to yes,
// place a RegisterExtraCloseApplicationsResources event function in the Pascal script
// and call RegisterExtraCloseApplicationsResource inside it, once per file.
procedure RegisterExtraCloseApplicationsResources;
var
	I: Integer;
begin
	for I := 0 to High(_RegisterExtraCloseApplicationsResourcesDelegate) do
		_RegisterExtraCloseApplicationsResourcesDelegate[I]();
end;

//
// Uninstall event functions override
//

// Use this event function to make changes to the progress form at startup.
// You can't use the InitializeUninstall event function for this since at the time it is triggered, the progress form does not yet exist.
procedure InitializeUninstallProgressForm;
var
	I: Integer;
begin
	for I := 0 to High(_InitializeUninstallProgressFormDelegate) do
		_InitializeUninstallProgressFormDelegate[I]();
end;

procedure DeinitializeUninstall;
var
	I: Integer;
begin
	for I := 0 to High(_DeinitializeUninstallDelegate) do
		_DeinitializeUninstallDelegate[I]();
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
var
	I: Integer;
begin
	for I := 0 to High(_CurUninstallStepChangedDelegate) do
		_CurUninstallStepChangedDelegate[I](CurUninstallStep);
end;

// Return True to instruct Uninstall to prompt the user to restart the system at the end of a successful uninstallation, False otherwise.
function UninstallNeedRestart(): Boolean;
var
	I: Integer;
begin
	Result := False;
	for I := 0 to High(_UninstallNeedRestartDelegate) do
	begin
		Result := _UninstallNeedRestartDelegate[I]();
		if Result then Break;
	end;
end;

#endif
