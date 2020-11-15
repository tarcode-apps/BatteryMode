unit Autorun;

interface

uses
  Versions.Info;

type
  // Интерфейсы
  IAutorunProvider = interface;

  TAutorunPriority = (apRealtime,
                     apHigh,
                     apAboveNormal1,
                     apAboveNormal2,
                     apNormal1,
                     apNormal2,
                     apNormal3,
                     apBelowNormal1,
                     apBelowNormal2,
                     apIdleThreadLowest,
                     apIdleThreadIdle);

  TAutorunOptions = class
  private
    FName: string;
    FDescription: string;
    FAuthor: string;
    FFileName: string;
    FAllUser: Boolean;
    FRestartCount: Integer;
    FHighestRunLevel: Boolean;
    FPriority: TAutorunPriority;
  public
    constructor Create;

    property Name: string read FName write FName;
    property Description: string read FDescription write FDescription;
    property Author: string read FAuthor write FAuthor;
    property FileName: string read FFileName write FFileName;
    property AllUser: Boolean read FAllUser write FAllUser;
    property RestartCount: Integer read FRestartCount write FRestartCount;
    property HighestRunLevel: Boolean read FHighestRunLevel write FHighestRunLevel;
    property Priority: TAutorunPriority read FPriority write FPriority;
  end;

  IAutorunProvider = interface
    function Autorun(Options: TAutorunOptions): Boolean;
    function DeleteAutorun(Options: TAutorunOptions): Boolean;
    function IsAutorun(Options: TAutorunOptions): Boolean;
    function IsAvalible: Boolean;
  end;

implementation

{ TAutorunOptions }

constructor TAutorunOptions.Create;
begin
  Name            := TVersionInfo.FileDescription;
  Description     := TVersionInfo.Comments;
  Author          := TVersionInfo.CompanyName;
  FileName        := TVersionInfo.FileName;
  AllUser         := False;
  RestartCount    := 3;
  HighestRunLevel := False;
  Priority        := apNormal3;
end;

end.
