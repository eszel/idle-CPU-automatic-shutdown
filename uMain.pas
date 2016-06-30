unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, uTotalCpuUsagePct, Vcl.ExtCtrls,
  Vcl.StdCtrls, inifiles, Registry, Vcl.Menus, Shellapi;

type
  TfmrMain = class(TForm)
    tmr1: TTimer;
    btnStart: TButton;
    btnStop: TButton;
    lbl1: TLabel;
    lbl2: TLabel;
    mm1: TMainMenu;
    About1: TMenuItem;
    Licence1: TMenuItem;
    Web1: TMenuItem;
    procedure tmr1Timer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure About1Click(Sender: TObject);
    procedure Licence1Click(Sender: TObject);
    procedure Web1Click(Sender: TObject);
  private
    fCount: integer;
    fEnabled:boolean;
    fIni:TRegistryIniFile;
    fOriginalCaption:string;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fmrMain: TfmrMain;

function WindowsExit(RebootParam: Longword): Boolean;

implementation

{$R *.dfm}

procedure TfmrMain.About1Click(Sender: TObject);
begin
  showmessage('Author: Szabados Laszlo, laszlo.szabados@enso.hu');
end;

procedure TfmrMain.btnStartClick(Sender: TObject);
begin
  fEnabled:=true;
  fCount:=0;
  tmr1Timer(self);
end;

procedure TfmrMain.btnStopClick(Sender: TObject);
begin
  fEnabled:=false;
  fCount:=0;
  tmr1Timer(self);
end;

procedure TfmrMain.FormCreate(Sender: TObject);
begin
  fCount:=0;
  fIni:=TRegistryIniFile.Create('Idle CPU automatic shutdown');
  lbl1.Caption:='';
  lbl2.Caption:='';
  fOriginalCaption:=caption;
  tmr1Timer(self);
end;

procedure TfmrMain.Licence1Click(Sender: TObject);
begin
  ShellExecute(0, 'OPEN', PChar('https://creativecommons.org/licenses/by/4.0/'), '', '', SW_SHOWNORMAL);
end;

procedure TfmrMain.tmr1Timer(Sender: TObject);
var
  TotalCPUusagePercentage: Double;
  CPULimit,SecondsToWait:integer;
  s:string;
begin
  CPULimit:=fIni.ReadInteger('settings','limit_of_cpu_usage_percentage',10);
  TotalCPUusagePercentage := GetTotalCpuUsagePct();
  SecondsToWait := fIni.ReadInteger('settings','count_before_shutdown',10);


  if fEnabled then s:='STARTED' else s:='STOPPED';
  caption:=fOriginalCaption+' '+s;

  lbl1.Caption :='PC CPU usage: ' + IntToStr(Round(TotalCPUusagePercentage)) + '% (Limit: '+inttostr(CPULimit)+'%)';
  lbl2.Caption:='IDLE Counter: '+inttostr(fCount)+' of '+inttostr(SecondsToWait)+' sec(s)';

  if not fEnabled then exit;

  if Round(TotalCPUusagePercentage)<CPULimit then
    begin
      inc(fCount);
      if fCount>SecondsToWait then
        begin
          //Shutdown
          WindowsExit(EWX_POWEROFF or EWX_FORCE) ;
          application.Terminate;
        end;
    end
  else
    begin
      fCount:=0;
    end;
end;

procedure TfmrMain.Web1Click(Sender: TObject);
begin
  ShellExecute(0, 'OPEN', PChar('https://github.com/eszel/idle-CPU-automatic-shutdown'), '', '', SW_SHOWNORMAL);
end;

function WindowsExit(RebootParam: Longword): Boolean;
var
   TTokenHd: THandle;
   TTokenPvg: TTokenPrivileges;
   cbtpPrevious: DWORD;
   rTTokenPvg: TTokenPrivileges;
   pcbtpPreviousRequired: DWORD;
   tpResult: Boolean;
const
   SE_SHUTDOWN_NAME = 'SeShutdownPrivilege';
begin
   if Win32Platform = VER_PLATFORM_WIN32_NT then
   begin
     tpResult := OpenProcessToken(GetCurrentProcess(),
       TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY,
       TTokenHd) ;
     if tpResult then
     begin
       tpResult := LookupPrivilegeValue(nil,
                                        SE_SHUTDOWN_NAME,
                                        TTokenPvg.Privileges[0].Luid) ;
       TTokenPvg.PrivilegeCount := 1;
       TTokenPvg.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;
       cbtpPrevious := SizeOf(rTTokenPvg) ;
       pcbtpPreviousRequired := 0;
       if tpResult then
         AdjustTokenPrivileges(TTokenHd,
                                       False,
                                       TTokenPvg,
                                       cbtpPrevious,
                                       rTTokenPvg,
                                       pcbtpPreviousRequired) ;
     end;
   end;
   Result := ExitWindowsEx(RebootParam, 0) ;
end;


end.
