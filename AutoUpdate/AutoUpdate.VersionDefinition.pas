unit AutoUpdate.VersionDefinition;

interface

uses
  Winapi.Windows, Winapi.ActiveX,
  System.Classes, System.SysUtils,
  System.Generics.Collections, System.Generics.Defaults,
  Xml.xmldom, Xml.XMLIntf, Xml.XMLDoc,
  Versions, Versions.Info;

type
  TFileVersionInfo = record
    MinVersion: TVersion;
    FileName: string;
    FileParams: string;
    FileUrl: string;
    Version: TVersion;
    ChangeLogUrl: string;
    AutoUpdate: Boolean;
  end;

  EVersionNotFoundException = class(Exception);

  TVersionDefinition = class(TList<TFileVersionInfo>)
  private
    function ParseXml(const XmlDoc: IXMLDocument): Boolean;
  public
    constructor Create(const Xml: string); overload;
    constructor Create(const Xml: TStream); overload;

    function IsEmpty(): Boolean;
    function GetCompatibilityFileVersion(Version, SkipVersion: TVersion): TFileVersionInfo;

    function Parse(const Xml: string): Boolean; overload;
    function Parse(const Xml: TStream): Boolean; overload;
  end;

implementation

{ TVersionDefinition }

constructor TVersionDefinition.Create(const Xml: string);
begin
  inherited Create;
  Parse(Xml);
end;

constructor TVersionDefinition.Create(const Xml: TStream);
begin
  inherited Create;
  Parse(Xml);
end;

function TVersionDefinition.GetCompatibilityFileVersion(
  Version, SkipVersion: TVersion): TFileVersionInfo;
var
  Found: Boolean;
  FileVersion: TFileVersionInfo;
begin
  Found := False;

  for FileVersion in Self do begin
    if (FileVersion.MinVersion <= Version) and
       (FileVersion.Version > Version) and
       (FileVersion.Version > SkipVersion) then begin
      Result := FileVersion;
      Found := True;
    end;
  end;

  if not Found then
    raise EVersionNotFoundException.Create('Compatibility file version not found');
end;

function TVersionDefinition.IsEmpty: Boolean;
begin
  Result := Count = 0;
end;

function TVersionDefinition.ParseXml(const XmlDoc: IXMLDocument): Boolean;
  function FixValue(const Value: string): string;
  begin
    Result := AdjustLineBreaks(Value.Trim);
  end;

  function GetNodeText(const Node: IXMLNode): string;
  var
    I: Integer;
  begin
    Result := '';
    Node.XML;
    try
      for I := 0 to Node.ChildNodes.Count - 1 do
        if Node.ChildNodes[I].NodeType = ntText then begin
          Result := FixValue(Node.ChildNodes[I].Text);
          Break;
        end;
    except
      Result := '';
    end;
  end;

  function AdjustBinaryType(const Node: IXMLNode): IXMLNode;
  begin
    if TVersionInfo.BinaryType = SCS_64BIT_BINARY then
      Result := Node.ChildNodes['x64']
    else
      Result := Node.ChildNodes['x86'];
  end;

  function TryGetVersion(const Node: IXMLNode; var Ver: TFileVersionInfo): Boolean;
  begin
    try
      Ver.MinVersion    := GetNodeText(AdjustBinaryType(Node.ChildNodes['MinVersion']));
      Ver.FileName      := GetNodeText(AdjustBinaryType(Node.ChildNodes['FileName']));
      Ver.FileUrl       := GetNodeText(AdjustBinaryType(Node.ChildNodes['FileUrl']));
      Ver.FileParams    := GetNodeText(AdjustBinaryType(Node.ChildNodes['FileParams']));
      Ver.Version       := GetNodeText(AdjustBinaryType(Node.ChildNodes['Version']));
      Ver.ChangeLogUrl  := GetNodeText(AdjustBinaryType(Node.ChildNodes['ChangeLogUrl']));
      if not Boolean.TryToParse(GetNodeText(AdjustBinaryType(Node.ChildNodes['AutoUpdate'])), Ver.AutoUpdate) then
        Ver.AutoUpdate := False;

      Result := not (Ver.FileName.IsEmpty or Ver.FileUrl.IsEmpty or Ver.Version.IsEmpty);
    except
      Result := False;
    end;
  end;

var
  I: Integer;
  FileVersion: TFileVersionInfo;
begin
  XmlDoc.Active := True;
  XmlDoc.Options := XmlDoc.Options + [doAttrNull];

  if Count > 0 then Clear;
  Capacity := XmlDoc.DocumentElement.ChildNodes.Count;

  for I := 0 to XmlDoc.DocumentElement.ChildNodes.Count - 1 do
    if TryGetVersion(XmlDoc.DocumentElement.ChildNodes[i], FileVersion) then
      Add(FileVersion);

  XmlDoc.Active := False;

  Result := Count <> 0;
end;

function TVersionDefinition.Parse(const Xml: string): Boolean;
var
  XmlDoc: IXMLDocument;
begin
  try
    XmlDoc := TXMLDocument.Create(nil);
    try
      XmlDoc.LoadFromXML(Xml);

      Result := ParseXml(XmlDoc);
    finally
      XmlDoc := nil;
    end;
  except
    Result := False;
  end;
end;

function TVersionDefinition.Parse(const Xml: TStream): Boolean;
var
  XmlDoc: IXMLDocument;
begin
  try
    XmlDoc := TXMLDocument.Create(nil);
    try
      XmlDoc.LoadFromStream(Xml);

      Result := ParseXml(XmlDoc);
    finally
      XmlDoc := nil;
    end;
  except
    Result := False;
  end;
end;

end.
