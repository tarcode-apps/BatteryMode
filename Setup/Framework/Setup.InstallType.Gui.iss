#ifndef _SetupInstallTypeGui
	#define _SetupInstallTypeGui

#include "Setup.Events.iss"
#include "Windows.Api.iss"
#include "Setup.Elevator.iss"
#include "Setup.InstallType.iss"

[Code]

//
// Install Type Framework GUI
//

// !!!!!!!!!!! Init functions !!!!!!!!!!!
// !!!         InstallTypeInit        !!!
// !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

var
	_PagesSkipped: Boolean;

	_WpInstallType: TWizardPage;
	_AllUserRadioButton: TNewRadioButton;
	_JustForMeRadioButton: TNewRadioButton;
	_PortableRadioButton: TNewRadioButton;
	
procedure _InstallTypeGuiOnInitializeWizard; forward; 
function _InstallTypeGuiOnShouldSkipPage(PageID: Integer): Boolean; forward;
procedure _InstallTypeGuiOnCurPageChanged(CurPageID: Integer); forward;
function _InstallTypeGuiOnNextButtonClick(CurPageID: Integer): Boolean; forward;
procedure _InstallTypeGuiOnRegisterPreviousData(PreviousDataKey: Integer); forward;

procedure InstallTypeGuiInit;
begin
	ConnectOnInitializeWizard(@_InstallTypeGuiOnInitializeWizard);     
	ConnectOnShouldSkipPage(@_InstallTypeGuiOnShouldSkipPage);
	ConnectOnCurPageChanged(@_InstallTypeGuiOnCurPageChanged);
	ConnectOnNextButtonClick(@_InstallTypeGuiOnNextButtonClick);
	ConnectOnRegisterPreviousData(@_InstallTypeGuiOnRegisterPreviousData);	
end;

function GetInstallType(): TInstallType;
begin
	if _AllUserRadioButton.Checked then			Result := itAllUser
	else if _JustForMeRadioButton.Checked then	Result := itJustForMe
	else if _PortableRadioButton.Checked then	Result := itPortable
	else Result := itAllUser;
end;

function GetInstallDirectory(): String;
begin
	if ParamExists('/DIR') then
		Result := ExpandConstant('{param:DIR|{pf}\{#InstallFolder}}')
	else
	begin
		case GetInstallType() of
			itAllUser:		Result := ExpandConstant('{pf}');
			itJustForMe:	Result := ExpandConstant('{localappdata}');
			itPortable:		Result := ExpandConstant('{src}');
			else Result := ExpandConstant('{pf}');
		end;
		Result := AddBackslash(Result) + '{#InstallFolder}';
	end;
end;

function IsUninstallable(): Boolean;
begin
	Result := GetInstallType() <> itPortable;
end;

function IsPortableOnly(): Boolean;
begin
	Result := ('{#BitsInstall}' = '64') and not IsWin64(); 
end;

procedure _InstallTypeGuiOnInitializeWizard;
var
	InstallType: TInstallType;
	InstallTypeParam: string;
	AllUserDescLabel: TLabel;
	JustForMeDescLabel: TLabel;
	PortableDescLabel: TLabel;
begin
	_PagesSkipped := False;
	
	InstallTypeParam := ExpandConstant('{param:InstallType|Auto}');
	if Uppercase(InstallTypeParam) = Uppercase('Auto') then
		InstallType := StringToInstallType(GetPreviousData('InstallType', InstallTypeToString(itAllUser)))
	else
		InstallType := StringToInstallType(InstallTypeParam);
	
	if ParamExists('/Portable') then
		InstallType := itPortable;
		
	if IsPortableOnly then
		InstallType := itPortable;
	
	_WpInstallType := CreateCustomPage(wpLicense, CustomMessage('InstallType'), CustomMessage('InstallTypeDescription'));
	
	_AllUserRadioButton := TNewRadioButton.Create(WizardForm);
	with _AllUserRadioButton do begin
		Parent := _WpInstallType.Surface;
		Enabled := not IsPortableOnly;
		Checked := InstallType = itAllUser;
		Top := ScaleY(16);
		Height := ScaleY(17);
		Width := _WpInstallType.SurfaceWidth;
		Font.Style := [fsBold];
		Font.Size := 9;
		Caption := CustomMessage('AllUserRadioButton');
	end;
	
	AllUserDescLabel := TLabel.Create(WizardForm);
	with AllUserDescLabel do begin
		Parent := _WpInstallType.Surface;
		Enabled := not IsPortableOnly;
		Left := ScaleX(18);
		Top := _AllUserRadioButton.Top + _AllUserRadioButton.Height + ScaleY(6);
		Width := _WpInstallType.SurfaceWidth - Left*2; 
		Height := ScaleY(40);
		AutoSize := False;
		Wordwrap := True;
		Caption := CustomMessage('AllUserDescLabel');
	end;
	
	_JustForMeRadioButton := TNewRadioButton.Create(WizardForm);
	with _JustForMeRadioButton do begin
		Parent := _WpInstallType.Surface;
		Enabled := not IsPortableOnly;
		Checked := InstallType = itJustForMe;
		Top := AllUserDescLabel.Top + AllUserDescLabel.Height + ScaleY(10);
		Height := ScaleY(17);
		Width := _WpInstallType.SurfaceWidth;
		Font.Style := [fsBold];
		Font.Size := 9;
		Caption := CustomMessage('JustForMeRadioButton');
	end;
	
	JustForMeDescLabel := TLabel.Create(WizardForm);
	with JustForMeDescLabel do begin
		Parent := _WpInstallType.Surface;
		Enabled := not IsPortableOnly;
		Left := ScaleX(18);
		Top := _JustForMeRadioButton.Top + _JustForMeRadioButton.Height + ScaleY(6);
		Width := _WpInstallType.SurfaceWidth - Left*2;
		Height := ScaleY(40);
		AutoSize := False;
		Wordwrap := True;
		Caption := CustomMessage('JustForMeDescLabel');
	end;
	
	_PortableRadioButton := TNewRadioButton.Create(WizardForm);
	with _PortableRadioButton do begin
		Parent := _WpInstallType.Surface;
		Checked := InstallType = itPortable;
		Top := JustForMeDescLabel.Top + JustForMeDescLabel.Height + ScaleY(10);
		Height := ScaleY(17);
		Width := _WpInstallType.SurfaceWidth;
		Font.Style := [fsBold];
		Font.Size := 9;
		Caption := CustomMessage('PortableRadioButton');
	end;
	
	PortableDescLabel := TLabel.Create(WizardForm);
	with PortableDescLabel do begin
		Parent := _WpInstallType.Surface;
		Left := ScaleX(18);
		Top := _PortableRadioButton.Top + _PortableRadioButton.Height + ScaleY(6);
		Width := _WpInstallType.SurfaceWidth - Left*2;
		Height := ScaleY(40);
		AutoSize := False;
		Wordwrap := True;
		Caption := CustomMessage('PortableDescLabel');
	end;
end;

function _InstallTypeGuiOnShouldSkipPage(PageID: Integer): Boolean;
begin
	// if we've executed this instance as elevated, skip pages unless we're
	// on the directory selection page
	Result := not _PagesSkipped and IsElevated() and (PageID <> wpSelectDir);
	// if we've reached the directory selection page, set our flag variable
	if not Result then
		_PagesSkipped := True;
	
	if not Result and (PageID = wpSelectProgramGroup) then
	begin
		WizardForm.NoIconsCheck.Checked := not IsUninstallable;
		Result := not IsUninstallable;
	end;
end;

procedure _InstallTypeGuiOnCurPageChanged(CurPageID: Integer);
begin
	if CurPageID = wpSelectDir then
		WizardForm.DirEdit.Text := GetInstallDirectory();
end;

function _InstallTypeGuiOnNextButtonClick(CurPageID: Integer): Boolean;
begin
	Result := True;
	
	// if we are on the directory selection page and we are not running the
	// instance we've manually elevated, then...
	if not IsElevated() and IsWindowsVistaOrGreater and (GetInstallType() = itAllUser) and (CurPageID = _WpInstallType.ID) then
	begin
		if RunElevated([
				ParamAddOrSetValue('/InstallType', InstallTypeToString(GetInstallType())),
				ParamAddOrSetValue('/DIR', GetInstallDirectory())
				], ['/Portable']) then
		begin
			ExitProcess(0);
		end
		else
		begin
			Result := False;
			MsgBox(SetupMessage(msgAdminPrivilegesRequired), mbError, MB_OK);
		end;
	end;
end;

procedure _InstallTypeGuiOnRegisterPreviousData(PreviousDataKey: Integer);
begin
	SetPreviousData(PreviousDataKey, 'InstallType', InstallTypeToString(GetInstallType()));
end;

#endif
