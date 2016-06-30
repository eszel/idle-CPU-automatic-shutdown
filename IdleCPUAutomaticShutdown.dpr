program IdleCPUAutomaticShutdown;

uses
  Vcl.Forms,
  uMain in 'uMain.pas' {fmrMain},
  uTotalCpuUsagePct in 'uTotalCpuUsagePct.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'Idle CPU automatic shutdown';
  Application.CreateForm(TfmrMain, fmrMain);
  Application.Run;
end.
