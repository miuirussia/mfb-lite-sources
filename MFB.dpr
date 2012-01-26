program MFB;

uses
  Vcl.Forms,
  MainUnit in 'MainUnit.pas' {MainForm},
  StartFrame in 'StartFrame.pas' {frmStartPage: TFrame},
  OpenFirmware in 'OpenFirmware.pas' {frmOpenFirmware: TFrame},
  Vcl.Themes,
  Vcl.Styles,
  CompileFirmware in 'CompileFirmware.pas' {frmCompileFirmware: TFrame},
  FWZipConsts in 'fwzip\FWZipConsts.pas',
  FWZipCrc32 in 'fwzip\FWZipCrc32.pas',
  FWZipCrypt in 'fwzip\FWZipCrypt.pas',
  FWZipReader in 'fwzip\FWZipReader.pas',
  FWZipStream in 'fwzip\FWZipStream.pas',
  FWZipWriter in 'fwzip\FWZipWriter.pas',
  AddonFrame in 'AddonFrame.pas' {frmAddons: TFrame},
  HelpUnit in 'HelpUnit.pas' {HelpForm},
  FinishFrame in 'FinishFrame.pas' {frmFinish: TFrame},
  CryModule in 'CryModule.pas' {CryMode},
  GitHubChooiser in 'GitHubChooiser.pas' {GitHubRepositories: TFrame};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title:='MIUI Firmware Builder';
  Application.CreateForm(TMainForm, MainForm);
  Application.CreateForm(THelpForm, HelpForm);
  Application.CreateForm(TCryMode, CryMode);
  Application.Run;
end.
