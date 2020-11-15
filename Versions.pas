unit Versions;

interface

type
  TVersion = record
  public
    Major: string;
    Minor: string;
    Release: string;
    Build: string;
    Other: string;

    constructor Create(Version: string);

    function ToString(): string;
    function IsEmpty(): Boolean;
    class function Empty: TVersion; static;

    class operator Equal(const Left, Right: TVersion): Boolean;
    class operator NotEqual(const Left, Right: TVersion): Boolean;
    class operator LessThan(const Left, Right: TVersion): Boolean;
    class operator LessThanOrEqual(const Left, Right: TVersion): Boolean;
    class operator GreaterThan(const Left, Right: TVersion): Boolean;
    class operator GreaterThanOrEqual(const Left, Right: TVersion): Boolean;
    class operator Implicit(const Some: TVersion): string;
    class operator Implicit(const Some: string): TVersion;
  private
    class function CompareNumericStr(const Left, Right: string): Integer; static;
    class function TryCompareStr(const Left, Right: string): Integer; static;
  end;

implementation

uses
  System.SysUtils;

{ TVersion }

constructor TVersion.Create(Version: string);
var
  StringList: TArray<string>;
  Len: Integer;
begin
  StringList := Version.Split(['.'], 5);

  Len := Length(StringList);
  if Len > 0 then Major    := StringList[0] else Major    := string.Empty;
  if Len > 1 then Minor    := StringList[1] else Minor    := string.Empty;
  if Len > 2 then Release  := StringList[2] else Release  := string.Empty;
  if Len > 3 then Build    := StringList[3] else Build    := string.Empty;
  if Len > 4 then Other    := StringList[4] else Other    := string.Empty;
end;

function TVersion.ToString: string;
var
  StringList: TArray<string>;
begin
  try
    if not Major.IsEmpty then   StringList := StringList + [Major];
    if not Minor.IsEmpty then   StringList := StringList + [Minor];
    if not Release.IsEmpty then StringList := StringList + [Release];
    if not Build.IsEmpty then   StringList := StringList + [Build];
    if not Other.IsEmpty then   StringList := StringList + [Other];
    Result := String.Join('.', StringList);
  except
    Result := string.Empty;
  end;
end;

function TVersion.IsEmpty: Boolean;
begin
  Result := Major.IsEmpty and Minor.IsEmpty and Release.IsEmpty and
            Build.IsEmpty and Other.IsEmpty;
end;

class function TVersion.Empty: TVersion;
begin
  Result := '0.0.0.0';
end;

class operator TVersion.Equal(const Left, Right: TVersion): Boolean;
begin
  Result := (TryCompareStr(Left.Major, Right.Major) = 0) and
            (TryCompareStr(Left.Minor, Right.Minor) = 0) and
            (TryCompareStr(Left.Release, Right.Release) = 0) and
            (TryCompareStr(Left.Build, Right.Build) = 0) and
            (TryCompareStr(Left.Other, Right.Other) = 0);
end;

class operator TVersion.NotEqual(const Left, Right: TVersion): Boolean;
begin
  Result := not (Left = Right);
end;

class operator TVersion.LessThan(const Left, Right: TVersion): Boolean;
var
  CmpMajor, CmpMinor, CmpRelease, CmpBuild, CmpOther: Integer;
begin
  CmpMajor := TryCompareStr(Left.Major,   Right.Major);
  CmpMinor := TryCompareStr(Left.Minor,   Right.Minor);
  CmpRelease := TryCompareStr(Left.Release,   Right.Release);
  CmpBuild := TryCompareStr(Left.Build,   Right.Build);
  CmpOther := TryCompareStr(Left.Other,   Right.Other);
  Result :=
    (CmpMajor < 0) or
    ((CmpMajor <= 0) and (CmpMinor < 0)) or
    ((CmpMajor <= 0) and (CmpMinor <= 0) and (CmpRelease < 0)) or
    ((CmpMajor <= 0) and (CmpMinor <= 0) and (CmpRelease <= 0) and (CmpBuild < 0 )) or
    ((CmpMajor <= 0) and (CmpMinor <= 0) and (CmpRelease <= 0) and (CmpBuild <= 0) and (CmpOther < 0));
end;

class operator TVersion.LessThanOrEqual(const Left, Right: TVersion): Boolean;
begin
  Result := (Left < Right) or (Left = Right);
end;

class operator TVersion.GreaterThan(const Left, Right: TVersion): Boolean;
begin
  Result := not (Left <= Right);
end;

class operator TVersion.GreaterThanOrEqual(const Left, Right: TVersion): Boolean;
begin
  Result := not (Left < Right);
end;

class operator TVersion.Implicit(const Some: TVersion): string;
begin
  Result := Some.ToString;
end;

class operator TVersion.Implicit(const Some: string): TVersion;
begin
  Result.Create(Some);
end;

class function TVersion.CompareNumericStr(const Left, Right: string): Integer;
var
  LeftInt, RightInt: Integer;

  function GetInt(Str: string): Integer;
  begin
    if Str.IsEmpty then Result := 0 else Result := Integer.Parse(Str);
  end;
begin
  LeftInt := GetInt(Left);
  RightInt := GetInt(Right);

  if LeftInt > RightInt then Result := 1
  else if LeftInt < RightInt then Result := -1
  else Result := 0;
end;

class function TVersion.TryCompareStr(const Left, Right: string): Integer;
begin
  try
    Result := CompareNumericStr(Left, Right);
  except
    Result := string.CompareOrdinal(Left, Right);
  end;
end;

end.
