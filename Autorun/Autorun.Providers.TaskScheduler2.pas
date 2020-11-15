unit Autorun.Providers.TaskScheduler2;

interface

uses
  Winapi.Windows,
  System.SysUtils, System.Variants,
  Helpers.Services, Helpers.Wts,
  Versions.Helpers,
  TaskSchd,
  Autorun;

type
  TTaskScheduler2Provider = class(TInterfacedObject, IAutorunProvider)
  private const
    AdminPostfix = 'Administrator';
  private
    function CheckTaskInTaskScheduler2(Task: IRegisteredTask;
      Options: TAutorunOptions; WithoutPath: Boolean = False): Boolean;
    function PriorityToTaskPriority(Priority: TAutorunPriority): TTaskPriority;
  public
    function Autorun(Options: TAutorunOptions): Boolean;
    function DeleteAutorun(Options: TAutorunOptions): Boolean;
    function IsAutorun(Options: TAutorunOptions): Boolean;
    function IsAvalible: Boolean;
  end;

implementation

{ TTaskScheduler2Provider }

function TTaskScheduler2Provider.Autorun(
  Options: TAutorunOptions): Boolean;
var
  TaskService: ITaskService;
  TaskFolder: ITaskFolder;
  NewTask: ITaskDefinition;
  Trigger: ILogonTrigger;
  UserId, UserName, TaskName: string;
begin
  with Options do
    try
      if (Name = '') or (FileName = '') then Exit(False);
      try
        UserName := GetCurrentSessionUserName;
        UserId := GetCurrentSessionDomainName + PathDelim + UserName;

        TaskName := Name;

        TaskService := CoTaskScheduler.Create;
        TaskService.Connect(Null, Null, Null, Null);
        TaskFolder := TaskService.GetFolder(PathDelim);

        NewTask := TaskService.NewTask(0); // Создали пустую задачу
        NewTask.RegistrationInfo.Description := Description;
        NewTask.RegistrationInfo.Author := Author;
        (NewTask.Actions.Create(taExec) as IExecAction).Path := ExpandUNCFileName(FileName).QuotedString('"');

        Trigger := (NewTask.Triggers.Create(ttLogin) as ILogonTrigger);
        Trigger.Delay := 'PT3S';
        if AllUser then
          Trigger.UserId := ''
         else begin
          Trigger.UserId := UserId;
          TaskName := TaskName + ' ' + UserName;
         end;

        if RestartCount > 0 then begin
          NewTask.Settings.RestartInterval := 'PT1M';
          NewTask.Settings.RestartCount := RestartCount;
        end;

        NewTask.Settings.MultipleInstances := tiIgnoreNew;
        NewTask.Settings.StopIfGoingOnBatteries := False;
        NewTask.Settings.DisallowStartIfOnBatteries := False;
        NewTask.Settings.ExecutionTimeLimit := 'PT0M';

        if (PriorityToTaskPriority(Priority) = tpRealtime) and (not HighestRunLevel) then
          NewTask.Settings.Priority := Integer(tpAboveNormal1)
        else
          NewTask.Settings.Priority := Integer(PriorityToTaskPriority(Priority));

        NewTask.Principal.UserId := UserId;
        if HighestRunLevel then begin
          TaskName := TaskName + ' ' + AdminPostfix;
          NewTask.Principal.RunLevel := trlHighest;
        end;

        Result := TaskFolder.RegisterTaskDefinition(TaskName, NewTask,
                    LONG(tcCreateOrUpdate), Null, Null,
                    tlIneractiveToken, Null) <> nil;
      finally
        NewTask := nil;
        TaskFolder := nil;
        TaskService := nil;
      end;
    except
      Result := False;
    end;
end;

function TTaskScheduler2Provider.DeleteAutorun(
  Options: TAutorunOptions): Boolean;
var
  TaskService: ITaskService;
  TaskFolder: ITaskFolder;
  Tasks: IRegisteredTaskCollection;
  Task: IRegisteredTask;
  i: Integer;
  TaskName: string;
begin
  with Options do
    try
      try
        TaskService := CoTaskScheduler.Create;
        TaskService.Connect(Null, Null, Null, Null);
        TaskFolder := TaskService.GetFolder(PathDelim);

        Tasks := TaskFolder.GetTasks(0);
        Result := True;
        for i := 1 to Tasks.Count do
          try
            TaskName := Tasks[i].Name;
            if TaskName.Contains(Name) then begin
              if CheckTaskInTaskScheduler2(Tasks[i], Options, True) then begin
                try
                  TaskFolder.DeleteTask(TaskName, 0);
                  try
                    Task := TaskFolder.GetTask(TaskName);
                  except
                    Task := nil;
                  end;
                  Result := not CheckTaskInTaskScheduler2(Task, Options, True);
                except
                  Result := False;
                end;
              end;
            end;
          except
            Continue;
          end;
      finally
        Task := nil;
        Tasks := nil;
        TaskFolder := nil;
        TaskService := nil;
      end;
    except
      Result := False;
    end;
end;

function TTaskScheduler2Provider.IsAutorun(
  Options: TAutorunOptions): Boolean;
var
  TaskService: ITaskService;
  TaskFolder: ITaskFolder;
  Tasks: IRegisteredTaskCollection;
  Task: IRegisteredTask;
  i: Integer;
  TaskName: string;
begin
  Result := False;
  with Options do
    try
      if (Name = '') or (FileName = '') then Exit(False);
      try
        TaskService := CoTaskScheduler.Create;
        TaskService.Connect(Null, Null, Null, Null);
        TaskFolder := TaskService.GetFolder(PathDelim);

        Tasks := TaskFolder.GetTasks(0);
        for i := 1 to Tasks.Count do
          try
            TaskName := Tasks[i].Name;
            if TaskName.Contains(Name) then begin
              Result := CheckTaskInTaskScheduler2(Tasks[i], Options);
              if Result then Break;
            end;
          except
            Continue;
          end;
      finally
        TaskFolder := nil;
        TaskService := nil;
        Tasks := nil;
        Task := nil;
      end;
    except
      Result := False;
    end;
end;

function TTaskScheduler2Provider.IsAvalible: Boolean;
begin
  Result := IsWindowsVistaOrGreater;

  if Result then
    Result := IsServiceRunning(nil, 'Schedule');
end;

function TTaskScheduler2Provider.CheckTaskInTaskScheduler2(Task: IRegisteredTask;
  Options: TAutorunOptions; WithoutPath: Boolean): Boolean;
var
  Action: IAction;
  Trigger: ITrigger;
  UserId: string;
  UserName: string;
  i: Integer;
  TrigerFound, ActionFound: Boolean;

  function DeQuoted(Str: string): string;
  begin
    Result := Str.DeQuotedString('"');
  end;

  function ExtractUserName(UserId: string): string;
  var
    I: Integer;
  begin
    I := UserId.LastDelimiter(PathDelim);
    Result := UserId.Substring(I + 1);
  end;
begin
  Result := False;

  UserName := GetCurrentSessionUserName;
  UserId := GetCurrentSessionDomainName + PathDelim + UserName;

  if Assigned(Task) then begin
    ActionFound := WithoutPath;
    if not WithoutPath then
      for i := 1 to Task.Definition.Actions.Count do begin
        Action := Task.Definition.Actions[i];
        try
          ActionFound := CompareText(
            ExpandUNCFileName(DeQuoted((Action as IExecAction).Path)),
            ExpandUNCFileName(DeQuoted(Options.FileName))) = 0;
          if ActionFound then Break;
        except
          Continue;
        end;
      end;

    TrigerFound := False;
    for i := 1 to Task.Definition.Triggers.Count do begin
      Trigger := Task.Definition.Triggers[i];
      try
        if Trigger.triggerType = ttLogin then
          TrigerFound := ((Trigger as ILogonTrigger).UserId = '') or
            (ExtractUserName((Trigger as ILogonTrigger).UserId) = UserName);
          if TrigerFound then Break;
      except
        Continue;
      end;
    end;

    Result := ActionFound and TrigerFound;
  end;
end;

function TTaskScheduler2Provider.PriorityToTaskPriority(
  Priority: TAutorunPriority): TTaskPriority;
begin
  case Priority of
    apRealtime:         Result := tpRealtime;
    apHigh:             Result := tpHigh;
    apAboveNormal1:     Result := tpAboveNormal1;
    apAboveNormal2:     Result := tpAboveNormal2;
    apNormal1:          Result := tpNormal1;
    apNormal2:          Result := tpNormal2;
    apNormal3:          Result := tpNormal3;
    apBelowNormal1:     Result := tpBelowNormal1;
    apBelowNormal2:     Result := tpBelowNormal2;
    apIdleThreadLowest: Result := tpIdleThreadLowest;
    apIdleThreadIdle:   Result := tpIdleThreadIdle;
    else Result := tpNormal1;
  end;
end;

end.
