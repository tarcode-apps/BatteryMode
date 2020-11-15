' ZIP.VBS manipulates ZIP file in command line. 
' Usage: CScript.exe ZIP.VBS [-d|-e|-v] ZIPfile [files...] 
'    CScript.exe ZIP.VBS -a archive.zip 1.txt 

Option Explicit 
Dim arg 
Dim optind 

If WScript.Arguments.Count<1 Then 
WScript.Echo "Usage: CScript.exe ZIP.VBS [-d|-e|-v] ZIPfile [files...]" 
WScript.Quit 
End If 
arg=WScript.Arguments(optind) 
Select Case LCase(arg) 
Case "-a","-c" 
optind=optind+1 
Call MakeZIP() 
Case "-d" 
optind=optind+1 
Call DeleteZIP() 
Case "-e" 
optind=optind+1 
Call ExtractZIP() 
Case "-v","-l" 
optind=optind+1 
Call ListZIP() 
Case Else 
If optind=WScript.Arguments.Count-1 Then 
 Call ListZIP() 
Else 
 Call MakeZIP() 
End If 
End Select 
WScript.Quit 

Sub MakeZIP() 
Dim fso 
Dim wShell 
Dim Shell 
Dim n 
Dim ie 
Dim ZIPfile 
Dim ZIPdata:ZIPdata="PK" & Chr(5) & Chr(6) & String(18,0) 
Dim file 
Dim Folder 
Dim FolderItem 
Dim dFolder 
Dim fCount 

If WScript.Arguments.Count<optind+2 Then 
WScript.Echo "Arguments Missing." 
WScript.Quit 
End If 

Set fso=CreateObject("Scripting.FileSystemObject") 
Set wShell=CreateObject("WScript.Shell") 
Set Shell=CreateObject("Shell.Application")  

ZIPfile=fso.GetAbsolutePathName(WScript.Arguments(optind)) 
If UCase(fso.GetExtensionName(ZIPfile))<>"ZIP" Then 
WScript.Echo "Invalid Extension Name -",fso.GetExtensionName(ZIPfile) 
WScript.Quit 
End If 
If Not fso.FileExists(ZIPfile) Then 
fso.CreateTextFile(ZIPfile,False).Write ZIPdata 
End If 
Set dFolder=Shell.NameSpace(ZIPfile)
fCount = 0 
For optind=optind+1 To WScript.Arguments.Count-1 
file=fso.GetAbsolutePathName(WScript.Arguments(optind)) 
Set Folder=Shell.NameSpace(fso.GetParentFolderName(file)) 
Set FolderItem=Folder.ParseName(fso.GetFileName(file)) 
If FolderItem Is Nothing Then 
 WScript.Echo WScript.Arguments(optind),"- Not Found." 
 WScript.Quit 
End If 
dFolder.CopyHere FolderItem, 4+16+2048
fCount = fCount+1
Do While dFolder.Items.Count < fCount
 Wscript.Sleep(10)
Loop 
Next 
End Sub 

Sub ListZIP() 
Dim fso 
Dim Shell 
Dim ZIPfile 
Dim Folder 
Dim FolderItem 
Dim k 
Dim COL:COL=8 
Dim cols 
ReDim cols(COL) 
Dim rows 
Dim j 

If WScript.Arguments.Count<optind+1 Then 
WScript.Echo "Arguments Missing." 
WScript.Quit 
End If 

Set fso=CreateObject("Scripting.FileSystemObject") 
Set Shell=CreateObject("Shell.Application") 
ZIPfile=fso.GetAbsolutePathName(WScript.Arguments(optind)) 
If UCase(fso.GetExtensionName(ZIPfile))<>"ZIP" Then 
WScript.Echo "Invalid Extension Name -",fso.GetExtensionName(ZIPfile) 
WScript.Quit 
End If 
Set Folder=Shell.NameSpace(ZIPfile) 
ReDim rows(Folder.Items.Count) 
For k=0 To COL 
cols(k)=Folder.GetDetailsOf(,k) 
Next 
j=0 
rows(j)=Join(cols,vbTab) 
For Each FolderItem In Folder.Items 
For k=0 To COL 
 Cols(k)=Folder.GetDetailsOf(FolderItem,k) 
Next 
j=j+1 
rows(j)=Join(cols,vbTab) 
Next 
WScript.Echo Join(rows,vbCRLF) 
End Sub 

Sub DeleteZIP() 
Dim fso 
Dim Shell 
Dim ZIPfile 
Dim Folder 
Dim FolderItem 

If WScript.Arguments.Count<optind+2 Then 
WScript.Echo "Arguments Missing." 
WScript.Quit 
End If 

Set fso=CreateObject("Scripting.FileSystemObject") 
Set Shell=CreateObject("Shell.Application") 
ZIPfile=fso.GetAbsolutePathName(WScript.Arguments(optind)) 
If UCase(fso.GetExtensionName(ZIPfile))<>"ZIP" Then 
WScript.Echo "Invalid Extension Name -",fso.GetExtensionName(ZIPfile) 
WScript.Quit 
End If 
Set Folder=Shell.NameSpace(ZIPfile) 
For optind=optind+1 To WScript.Arguments.Count-1 
Set FolderItem=Folder.ParseName(WScript.Arguments(optind)) 
If FolderItem Is Nothing Then 
 WScript.Echo WScript.Arguments(optind),"- Not Found." 
 WScript.Quit 
End If 
' FolderItem.InvokeVerb("delete") 
FolderItem.InvokeVerb("??(&D)") 
Next 
End Sub 

Sub ExtractZIP() 
Dim fso 
Dim Shell 
Dim ZIPfile 
Dim Folder 
Dim FolderItem 
Dim dFolder 

If WScript.Arguments.Count<optind+1 Then 
WScript.Echo "Arguments Missing." 
WScript.Quit 
End If 

Set fso=CreateObject("Scripting.FileSystemObject") 
Set Shell=CreateObject("Shell.Application") 
ZIPfile=fso.GetAbsolutePathName(WScript.Arguments(optind)) 
If UCase(fso.GetExtensionName(ZIPfile))<>"ZIP" Then 
WScript.Echo "Invalid Extension Name -",fso.GetExtensionName(ZIPfile) 
WScript.Quit 
End If 
Set Folder=Shell.NameSpace(ZIPfile) 
Set dFolder=Shell.NameSpace(fso.GetAbsolutePathName("")) 
If WScript.Arguments.Count<optind+2 Then 
dFolder.CopyHere Folder.Items 
Else 
For optind=optind+1 To WScript.Arguments.Count-1 
 Set FolderItem=Folder.ParseName(WScript.Arguments(optind)) 
 If FolderItem Is Nothing Then 
  WScript.Echo WScript.Arguments(optind),"- Not Found." 
  WScript.Quit 
 End If 
 dFolder.CopyHere FolderItem 
Next 
End If 
End Sub 
