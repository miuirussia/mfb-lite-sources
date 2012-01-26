unit MainUnit;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, rkVistaPanel, rkAeroTabs,
  Vcl.ComCtrls, Vcl.ExtCtrls, dxGDIPlusClasses, TaskBar, System.Win.Registry, System.IniFiles,
  Vcl.Buttons, W7Classes, W7Images;

type
  TMainForm = class(TForm)
    rkAeroTabs1: TrkAeroTabs;
    rkpnlMainPanel: TrkVistaPanel;
    lblInfoText: TLabel;
    pgcMainControl: TPageControl;
    TaskBar1: TTaskBar;
    btnBack: TSpeedButton;
    btnNext: TSpeedButton;
    btnCancel: TSpeedButton;
    W7Image1: TW7Image;
    W7Image2: TW7Image;
    procedure FormCreate(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure CreateStartPage;
    procedure CreateOpenFirmware;
    procedure CreateGitHubPage;
    procedure CreateCompileFirmware;
    procedure CreateAddonsPage;
    procedure CreateFinishPage;
    procedure btnNextClick(Sender: TObject);
    procedure btnBackClick(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure W7Image2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    WorkDir, AddonsDir, FirmwareFile, DataDir, aAppsDir, JavaHome, OTAUpdateServer, GitHubRepository:string;
    AddonsChck:Boolean;
    AddonItegrateScriptList, AddonIntegateList:TStringList;
    PasswordList:TStringList;
    AddonsChecked: array[0..9] of Boolean;
    GitHubs:TStringList;
    procedure AddToLog(State, LogValue:string);
    procedure SetProgress(Progress:Integer; Marquee:boolean=False);
    procedure ShowHelp(HelpIndex:string);
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

uses StartFrame, GitHubChooiser, OpenFirmware, CompileFirmware, AddonFrame, HelpUnit, FinishFrame,
  CryModule;

procedure TMainForm.ShowHelp(HelpIndex: string);
begin
   if FileExists(DataDir+'Help\'+HelpIndex+'.rtf') then begin
   HelpForm.HelpContent.Clear;
   HelpForm.HelpContent.Lines.LoadFromFile(DataDir+'Help\'+HelpIndex+'.rtf');
   HelpForm.Show;
   end else ShowMessage('Для данного раздела ещё не написана справка');
end;

procedure TMainForm.W7Image2Click(Sender: TObject);
begin
  if ParamStr(1)='-google' then
  CryMode.Show;
end;

procedure TMainForm.SetProgress(Progress: Integer; Marquee:boolean=False);
begin
  TaskBar1.ProgressValue:=Progress;
  if Marquee then TaskBar1.ProgressState:=TBPF_INDETERMINATE
  else TaskBar1.ProgressState:=TBPF_NORMAL;
  Application.ProcessMessages;
end;

procedure TMainForm.AddToLog(State, LogValue:string);
var
  Log:TStringList;
begin
  Log:=TStringList.Create;
  Log.Clear;
  if FileExists(WorkDir+'Log.log') then Log.LoadFromFile(WorkDir+'Log.log');
  Log.Add(State+'\ | '+FormatDateTime('dd.MM.yyyy hh.mm.ss', Now)+' | '+LogValue);
  Log.SaveToFile(WorkDir+'Log.log');
end;

procedure TMainForm.btnBackClick(Sender: TObject);
begin
  if (pgcMainControl.ActivePageIndex-1)>=0 then begin
    pgcMainControl.ActivePageIndex:=pgcMainControl.ActivePageIndex-1;
    lblInfoText.Caption:=pgcMainControl.Pages[pgcMainControl.ActivePageIndex].Caption;
  end;
  if (pgcMainControl.ActivePageIndex)>=(pgcMainControl.PageCount-1) then
  btnNext.Caption:='Финиш' else btnNext.Caption:='Далее';
  if pgcMainControl.ActivePageIndex<=0 then btnBack.Enabled:=False
  else btnBack.Enabled:=True;
  btnNext.Enabled:=True;
end;

procedure TMainForm.btnCancelClick(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.CreateStartPage;
var
  TS : TTabsheet;
  frmStartPage:TfrmStartPage;
begin
  TS := TTabSheet.Create(pgcMainControl);
  TS.PageControl := pgcMainControl;
  TS.TabVisible := False;
  frmStartPage:=TfrmStartPage.Create(TS);
  frmStartPage.Parent:= TS;
  TS.Caption:='Начало';
  frmStartPage.Align:= alClient;
end;

procedure TMainForm.CreateGitHubPage;
var
  TS : TTabsheet;
  frmGitPage:TGitHubRepositories;
begin
  TS := TTabSheet.Create(pgcMainControl);
  TS.PageControl := pgcMainControl;
  TS.TabVisible := False;
  frmGitPage:=TGitHubRepositories.Create(TS);
  frmGitPage.Parent:= TS;
  TS.Caption:='Настройка GitHub';
  frmGitPage.cbbGitHubs.Items.LoadFromFile(WorkDir+'Settings\GitHub-names.conf');
  frmGitPage.cbbGitHubs.ItemIndex:=-1;
  if not Assigned(GitHubs) then
  GitHubs:=TStringList.Create;
  GitHubs.Clear;
  GitHubs.LoadFromFile(WorkDir+'Settings\GitHub-gits.conf');
  frmGitPage.Align:= alClient;
end;

procedure TMainForm.CreateOpenFirmware;
var
  TS : TTabsheet;
  frmOpenFirmware:TfrmOpenFirmware;
begin
  TS := TTabSheet.Create(pgcMainControl);
  TS.PageControl := pgcMainControl;
  TS.TabVisible := False;
  frmOpenFirmware:=TfrmOpenFirmware.Create(TS);
  frmOpenFirmware.Parent:= TS;
  TS.Caption:='Открытие прошивки и дополнения';
  frmOpenFirmware.Align:= alClient;
end;

procedure TMainForm.CreateFinishPage;
var
  TS : TTabsheet;
  frmFinishFrame:TfrmFinish;
begin
  TS := TTabSheet.Create(pgcMainControl);
  TS.PageControl := pgcMainControl;
  TS.TabVisible := False;
  frmFinishFrame:=TfrmFinish.Create(TS);
  frmFinishFrame.Parent:= TS;
  TS.Caption:='Готово';
  frmFinishFrame.Align:= alClient;
end;

procedure TMainForm.CreateAddonsPage;
var
  TS : TTabsheet;
  frmAddons:TfrmAddons;
begin
  TS := TTabSheet.Create(pgcMainControl);
  TS.PageControl := pgcMainControl;
  TS.TabVisible := False;
  frmAddons:=TfrmAddons.Create(TS);
  frmAddons.Parent:= TS;
  TS.Caption:='Интеграция дополнений и удаление программ';
  frmAddons.Align:= alClient;
end;

procedure TMainForm.CreateCompileFirmware;
var
  TS : TTabsheet;
  frmCompileFirmware:TfrmCompileFirmware;
begin
  TS := TTabSheet.Create(pgcMainControl);
  TS.PageControl := pgcMainControl;
  TS.TabVisible := False;
  frmCompileFirmware:=TfrmCompileFirmware.Create(TS);
  frmCompileFirmware.Parent:= TS;
  TS.Caption:='Открытие прошивки и дополнения';
  frmCompileFirmware.Align:= alClient;
  frmCompileFirmware.UbuntuProgress1.Align:=alBottom
end;



procedure TMainForm.btnNextClick(Sender: TObject);
var
  frmCompileFirmware:TfrmCompileFirmware;
  frmAddons:TfrmAddons;
  IniFiles:TIniFile;
  FirmwareVersion, ID1, ID2:string;
begin
  btnBack.Repaint;
  btnBack.Refresh;
  if (pgcMainControl.ActivePageIndex+1)<pgcMainControl.PageCount then begin
    pgcMainControl.ActivePageIndex:=pgcMainControl.ActivePageIndex+1;
    lblInfoText.Caption:=pgcMainControl.Pages[pgcMainControl.ActivePageIndex].Caption;
  end else Close;
  btnNext.Enabled:=False;
  if (pgcMainControl.ActivePageIndex)=(pgcMainControl.PageCount-1) then begin
   btnNext.Caption:='Финиш';
   btnNext.Enabled:=True;
  end;
  if pgcMainControl.ActivePageIndex<=0 then btnBack.Enabled:=False
  else btnBack.Enabled:=True;
  if pgcMainControl.Pages[pgcMainControl.ActivePageIndex].Controls[0].Name='frmCompileFirmware' then begin
      frmCompileFirmware:=pgcMainControl.Pages[pgcMainControl.ActivePageIndex].Controls[0] as TfrmCompileFirmware;
      frmCompileFirmware.Memo1.Lines.Clear;
      IniFiles:=TIniFile.Create(MainForm.DataDir+'Language.conf');
      FirmwareVersion:=IniFiles.ReadString('Language','Version','');
      ID1:=IniFiles.ReadString('Language','ID1','ru');
      ID2:=IniFiles.ReadString('Language','ID2','RU');
      IniFiles.Free;
      if FileExists(MainForm.DataDir+'\LanguageFiles_Git\Language.conf') then begin
         IniFiles:=TIniFile.Create(MainForm.DataDir+'\LanguageFiles_Git\Language.conf');
         FirmwareVersion:=IniFiles.ReadString('Language','Version','')+'-git';
         IniFiles.Free;
      end;
      frmCompileFirmware.Memo1.Lines.Add('Прошивка:');
      frmCompileFirmware.Memo1.Lines.Add(#9'Используется перевод для версии: '+ FirmwareVersion+' ('+ID1+'_'+ID2+')');
      frmCompileFirmware.Memo1.Lines.Add(#9'Имя файла прошивки: '+ FirmwareFile);
      if AddonsChck then
      frmCompileFirmware.Memo1.Lines.Add(#9'Папка для дополнений: '+ AddonsDir);
      frmCompileFirmware.Memo1.Lines.Add(#9);
      frmCompileFirmware.Memo1.Lines.Add('Дополнения:');
      if MainForm.AddonsChecked[0] then frmCompileFirmware.Memo1.Lines.Add(#9'CPU Control');
      if MainForm.AddonsChecked[1] then frmCompileFirmware.Memo1.Lines.Add(#9'Дополнения KDG');
      if MainForm.AddonsChecked[2] then frmCompileFirmware.Memo1.Lines.Add(#9'Шрифт Android 4.0');
      if MainForm.AddonsChecked[3] then frmCompileFirmware.Memo1.Lines.Add(#9'Sony Bravia Engine');
      if MainForm.AddonsChecked[4] then frmCompileFirmware.Memo1.Lines.Add(#9'Sony XLoud');
      if MainForm.AddonsChecked[5] then frmCompileFirmware.Memo1.Lines.Add(#9'Тема с дополнительными значками');
      if MainForm.AddonsChecked[6] then frmCompileFirmware.Memo1.Lines.Add(#9'Подготовка к OTA');
      if MainForm.AddonsChecked[7] then frmCompileFirmware.Memo1.Lines.Add(#9'Перевод 4WayReboot');
      if MainForm.AddonsChecked[8] then frmCompileFirmware.Memo1.Lines.Add(#9'MineField mode');
      frmCompileFirmware.Memo1.Lines.Add(#9);
      frmCompileFirmware.Memo1.Lines.Add('Все готово для компиляции!');
      btnNext.Enabled:=False;
      btnBack.Enabled:=False;
  end;
  if pgcMainControl.Pages[pgcMainControl.ActivePageIndex].Controls[0].Name='frmAddons' then begin
      frmAddons:=pgcMainControl.Pages[pgcMainControl.ActivePageIndex].Controls[0] as TfrmAddons;
      if FileExists(WorkDir+'Settings\FilesToDelete.conf') then frmAddons.lstDelete.Items.LoadFromFile(WorkDir+'Settings\FilesToDelete.conf')
      else begin
        ForceDirectories(WorkDir+'Settings');
        frmAddons.lstDelete.Items.Add('AppShare.apk');
        frmAddons.lstDelete.Items.Add('SimpleLiveWallpaper.apk');
        frmAddons.lstDelete.Items.Add('MIUIStats.apk');
        frmAddons.lstDelete.Items.Add('Compass.apk');
        frmAddons.lstDelete.Items.SaveToFile(WorkDir+'Settings\FilesToDelete.conf');
      end;
      btnNext.Enabled:=True;
  end;
end;

procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  GitHubs.Free;
  AddonItegrateScriptList.Free;
  AddonIntegateList.Free;
  PasswordList.Free;
end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  JavaVersion:string;
  Registry:TRegistry;
  i:Integer;
  IniFile:TIniFile;
begin
  IniFile:=TIniFile.Create(WorkDir+'Settings\Settings.conf');
  GitHubRepository:='git://github.com/miuirussia/miui-russian-translation.git';
  OTAUpdateServer:=IniFile.ReadString('Server', 'DownloadServer', 'http://ota.miuirussia.com/OTAS/')+IniFile.ReadString('Server', 'WorkName', 'Noned')+'/update.php';
  //OTAUpdateServer:='http://ota.miuirussia.com/KDG/update.php';
  if CheckWin32Version(5,4) then rkAeroTabs1.ColorBackground := clBlack;
  JavaHome:='Null';
  with TRegistry.Create(KEY_ALL_ACCESS OR KEY_WOW64_64KEY) do
  begin
    try
      RootKey:=HKEY_LOCAL_MACHINE;
      if OpenKey('SOFTWARE\JavaSoft\Java Runtime Environment',False) then
      begin
       JavaVersion:=ReadString('CurrentVersion');
      end;
      CloseKey;
      if OpenKey('SOFTWARE\JavaSoft\Java Runtime Environment\'+JavaVersion,False) then
      begin
          JavaHome:=ReadString('JavaHome');
      end;
      CloseKey;
    finally
      free;
    end;
  end;
  WorkDir:=ExtractFilePath(Application.ExeName);
  DataDir:=IncludeTrailingBackslash(IncludeTrailingBackslash(WorkDir)+'Data');
  aAppsDir:=IncludeTrailingBackslash(IncludeTrailingBackslash(DataDir)+'aApps');
  for i := 0 to 9 do AddonsChecked[i]:=False;
  AddToLog('I', 'WorkDir: '+WorkDir);
  AddToLog('I', 'DataDir: '+DataDir);
  AddToLog('I', 'aAppsDir: '+aAppsDir);
  AddToLog('I', 'JavaHome: '+JavaHome);
  if JavaHome='Null' then begin
    ShowMessage('Failed to initialize JVM. Please reinstall Java');
    Application.Terminate;
    Exit;
  end;
  rkAeroTabs1.Tabs.Clear;
  rkAeroTabs1.Tabs.Add(MainForm.Caption);
  lblInfoText.Caption:='Начало';
  CreateStartPage;
  CreateGitHubPage;
  CreateOpenFirmware;
  CreateAddonsPage;
  CreateCompileFirmware;
  CreateFinishPage;
  pgcMainControl.ActivePageIndex:=0;
  AddonsChck:=False;
  btnBack.Enabled:=False;
  AddonItegrateScriptList:=TStringList.Create;
  AddonIntegateList:=TStringList.Create;
  PasswordList:=TStringList.Create;
  PasswordList.Add({„обавить свои пароли});
end;

procedure TMainForm.Image1Click(Sender: TObject);
begin
  ShowHelp(pgcMainControl.Pages[pgcMainControl.ActivePageIndex].Controls[0].Name);
end;

end.
