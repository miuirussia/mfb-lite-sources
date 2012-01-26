unit CompileFirmware;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, TaskBar,
  UbuntuProgress, FWZipConsts, FWZipReader, FWZipWriter, System.ZLib, System.IniFiles, System.Masks, Winapi.ShellAPI, System.RegularExpressions;

type
  TfrmCompileFirmware = class(TFrame)
    Label1: TLabel;
    Memo1: TMemo;
    Button1: TButton;
    UbuntuProgress1: TUbuntuProgress;
    procedure Button1Click(Sender: TObject);
    function ExecuteCommand(OperationTitle:string; var CommandLine, lWorkingDir:string; WaitShow:Boolean=False):boolean;
    procedure CompileFile(FilePName, DataDir:string);
    procedure ExtractTranslation(From, Dect:string);
    function CheckTranslation(Trn:string):Boolean;
    procedure ExtractAddon(Addon, Dest:string;Integrate:Boolean);
    procedure ExtractPrecompiled(From, Dest:string);
    procedure PatchAndroidPolicy(FileName:string);
    procedure OnDuplicate(Sender:TObject; var Path:string; var Action:TDuplicateAction);
    procedure PatchTranslationUpdate(Path:string);
  private
    { Private declarations }
    procedure OnProgress(Sender: TObject; const FileName: string;
      Percent, TotalPercent: Byte; var Cancel: Boolean);
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

uses MainUnit;

var
  UnixStartDate: TDateTime = 25569.0;

function TfrmCompileFirmware.ExecuteCommand(OperationTitle:string; var CommandLine: string; var lWorkingDir: string; WaitShow:Boolean=False):Boolean;
var
  StartupInfo:TStartupInfo;
  ProcessInfo:TProcessInformation;
  ExitCode:Cardinal;
  TempCmd, TmpWorkDir:PWideChar;
  PointProgress:string;
  t:Integer;
begin
  FillChar(StartupInfo, SizeOf(TStartupInfo), #0);
  StartupInfo.dwFlags := STARTF_USESHOWWINDOW or STARTF_FORCEONFEEDBACK;
  StartupInfo.wShowWindow := SW_HIDE;
  TempCmd:=PWideChar(CommandLine);
  TmpWorkDir:=PWideChar(lWorkingDir);
  if not CreateProcess(nil,
                  TempCmd,
                  nil, nil, false, NORMAL_PRIORITY_CLASS, nil,
                  TmpWorkDir, //current dir
                  StartUpInfo, ProcessInfo) then MainForm.AddToLog('E','Programm malformed!')
                else
                while  WaitForSingleObject(ProcessInfo.hProcess, 100) = WAIT_TIMEOUT do begin
                  if WaitShow then begin
                   UbuntuProgress1.Mode:=pmMarquee;
                   MainForm.TaskBar1.ProgressState:=TBPF_INDETERMINATE;
                  end;
                  Application.ProcessMessages;
                end;
  GetExitCodeProcess(ProcessInfo.hProcess, ExitCode);
  if ExitCode<>0 then begin
   MainForm.AddToLog('E','Executing Failed!');
   MainForm.AddToLog('E','ExitCode: '+IntToStr(ExitCode));
   if WaitShow then begin
     UbuntuProgress1.Mode:=pmNormal;
     MainForm.TaskBar1.ProgressState:=TBPF_NORMAL;
   end;
   Result:=False
  end else begin
   MainForm.AddToLog('I',OperationTitle+'...Done!');
   if WaitShow then begin
     UbuntuProgress1.Mode:=pmNormal;
     MainForm.TaskBar1.ProgressState:=TBPF_NORMAL;
   end;
   Result:=True;
  end;
end;

procedure FindFiles(StartFolder, Mask: String; List: TStrings;
ScanSubFolders: Boolean = True);
var
  SearchRec: TSearchRec;
  FindResult: Integer;
begin
  List.BeginUpdate;
  try
    StartFolder:=IncludeTrailingBackslash(StartFolder);
    FindResult:=FindFirst(StartFolder+'*.*', faAnyFile, SearchRec);
try
while FindResult = 0 do with SearchRec do begin
if (Attr and faDirectory)>0 then begin
if ScanSubFolders and (Name<>'.') and (Name<>'..') then
FindFiles(StartFolder+Name, Mask, List, ScanSubFolders);
end else begin
if MatchesMask(Name, Mask) then List.Add(StartFolder+Name);
end;
FindResult:=FindNext(SearchRec);
end;
finally
FindClose(SearchRec);
end;
finally
List.EndUpdate;
end;
end;

procedure FindFolders(StartFolder, Mask: String; List: TStrings;
ScanSubFolders: Boolean = False);
var
  SearchRec: TSearchRec;
  FindResult: Integer;
begin
  List.BeginUpdate;
  try
    StartFolder:=IncludeTrailingBackslash(StartFolder);
    FindResult:=FindFirst(StartFolder+'*', faDirectory, SearchRec);
try
while FindResult = 0 do with SearchRec do begin
if ((SearchRec.Attr and faDirectory) = faDirectory) and
  (Name<>'.') and (Name<>'..') then
begin
  if MatchesMask(Name, Mask) then
  List.Add(StartFolder+Name);
end;
FindResult:=FindNext(SearchRec);
end;
finally
FindClose(SearchRec);
end;
finally
List.EndUpdate;
end;
end;

function GetFileNameWOExt(fn:String):String;
begin
  Result := Copy(fn, 1, Length(fn)-Length(ExtractFileExt(fn)));
end;

function RandomPassword(PLen: Integer): string;
var
  str: string;
begin
  Randomize;
  str := 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
  Result := '';
  repeat
    Result := Result + str[Random(Length(str)) + 1];
  until (Length(Result) = PLen)
end;

procedure SetBuildPropVariable(Filename, Variable, Value:string);
var
   BuildProp:TStringList;
   i:Integer;
   Pattern:string;
   RegExpr:TRegEx;
   Replaced:Boolean;
begin
   BuildProp:=TStringList.Create;
   BuildProp.LoadFromFile(Filename);
   Pattern:=Variable+'=(.*)';
   RegExpr:=TRegEx.Create(Pattern);
   Replaced:=False;
   for i := 0 to BuildProp.Count-1 do begin
     if RegExpr.IsMatch(BuildProp[i]) then begin
       BuildProp[i]:=Variable+'='+Value;
       Replaced:=True;
     end;
   end;
   if not Replaced then BuildProp.Add(Variable+'='+Value);
   BuildProp.SaveToFile(Filename);
end;

function GetBuildPropVariable(Filename, Variable:string):string;
var
   BuildProp:TStringList;
   i:Integer;
   Pattern:string;
   RegExpr:TRegEx;
   M:TMatch;
begin
   BuildProp:=TStringList.Create;
   BuildProp.LoadFromFile(Filename);
   Pattern:=Variable+'=(.*)';
   RegExpr:=TRegEx.Create(Pattern);
   for i := 0 to BuildProp.Count-1 do begin
     if RegExpr.IsMatch(BuildProp[i]) then begin
       M:=RegExpr.Match(BuildProp[i]);
       Result:=M.Groups[1].Value;
     end;
   end;
end;

procedure PCHEExecutor(WorkDir, FileName:string);
const
  endofmethod='.end method';
var
  i, j, rm, orgid, id:Integer;
  Config:TIniFile;
  MTDFile, SmaliFile:TStringList;
  FileN, MethodName, MethodFile:string;
begin
  i:=0;
  j:=0;
  rm:=0;
  orgid:=0;
  id:=0;
  try
  Config:=TIniFile.Create(FileName);
  rm:=Config.ReadInteger('PCH','Count', -1);
  if (rm<>-1) then begin
    for i := 0 to rm-1 do begin
      FileN:=Config.ReadString('PCH.'+IntTostr(i), 'FileName', 'None');
      MethodName:=Config.ReadString('PCH.'+IntTostr(i), 'MethodName', 'None');
      MethodFile:=Config.ReadString('PCH.'+IntTostr(i), 'MethodFile', 'None');
      SmaliFile:=TStringList.Create;
      SmaliFile.LoadFromFile(IncludeTrailingBackslash(WorkDir)+FileN);
      while SmaliFile[orgid]<>MethodName do begin
        orgid:=orgid+1;
        if orgid>SmaliFile.Count-1 then Exit;
      end;
      id:=orgid;
      while SmaliFile[id]<>endofmethod do begin
        SmaliFile.Delete(id);
      end;
      MTDFile:=TStringList.Create;
      MTDFile.LoadFromFile(IncludeTrailingBackslash(ExtractFilePath(FileName))+MethodFile);
      for j := MTDFile.Count-2 downto 0 do begin
        SmaliFile.Insert(orgid, MTDFile[j]);
      end;
      SmaliFile.SaveToFile(IncludeTrailingBackslash(WorkDir)+FileN);
      SmaliFile.Free;
      MTDFile.Free;
      Config.Free;
    end;
  end;
  except
    MainForm.AddToLog('E','PCHE executing error');
    SmaliFile.Free;
    MTDFile.Free;
    Config.Free;
  end;
end;

function ConvertToNormalName(PhoneModel:string):string;
begin
  result:='Unknown: '+PhoneModel;
  if PhoneModel='captivatemtd' then result:='Samsung Captivate';
  if PhoneModel='captivate' then result:='Samsung Captivate';
  if PhoneModel='jordan' then result:='Motorola Defy';
  if PhoneModel='umts_jordan' then result:='Motorola Defy';
  if PhoneModel='bravo' then result:='HTC Desire';
  if PhoneModel='vision' then result:='HTC Desire Z';
  if PhoneModel='ace' then result:='HTC Desire HD';
  if PhoneModel='galaxys' then result:='Samsung Galaxy S';
  if PhoneModel='galaxysmtd' then result:='Samsung Galaxy S';
  if PhoneModel='sholes' then result:='Motorola Milestone';
  if PhoneModel='umts_sholes' then result:='Motorola Milestone';
  if PhoneModel='leo' then result:='HTC HD2';
  if PhoneModel='passion' then result:='Google Nexus One';
  if PhoneModel='crespo' then result:='Google Nexus S';
  if PhoneModel='vibrantmtd' then result:='Samsung Vibrant';
  if PhoneModel='vibrant' then result:='Samsung Vibrant';
  if PhoneModel='p990' then result:='LG Optimus 2X';
  if PhoneModel='p999' then result:='LG Optimus 2X';
  if PhoneModel='inc' then result:='HTC Droid Incredible';
  if PhoneModel='encore' then result:='B&ampN Nook Color';
  if PhoneModel='saga' then result:='HTC Desire S';
  if PhoneModel='vivow' then result:='HTC Droid Incredible 2';
  if PhoneModel='shooter' then result:='HTC EVO 3D';
  if PhoneModel='supersonic' then result:='HTC Evo 4G';
  if PhoneModel='speedy' then result:='HTC Evo Shift 4G';
  if PhoneModel='vivo' then result:='HTC Incredible S';
  if PhoneModel='pyramid' then result:='HTC Sensation';
  if PhoneModel='u8800' then result:='Huawei Ideos U8800';
  if PhoneModel='glacier' then result:='T-Mobile MyTouch 4G';
  if PhoneModel='galaxys2' then result:='Samsung Galaxy S II';
  if PhoneModel='mione_plus' then result:='MI-ONE Plus';
end;

procedure CopyFiles(aDirFrom, aDirTo, aMask: string);
var
  OpStruc: TSHFileOpStruct;
  FromBuf, ToBuf: array [0..128] of Char;
begin
  FillChar(FromBuf, SizeOf(FromBuf), 0);
  FillChar(ToBuf, SizeOf(ToBuf), 0);
  StrPCopy(FromBuf, aDirFrom+aMask);
  StrPCopy(ToBuf, aDirTo);
  try
    with OpStruc do
    begin
      wFunc:= FO_COPY;
      pFrom:= @FromBuf;
      pTo:= @ToBuf;
      fFlags:= FOF_NOCONFIRMATION or FOF_NOCONFIRMMKDIR or FOF_SIMPLEPROGRESS;
      fAnyOperationsAborted:= False;
      hNameMappings:= nil;
      lpszProgressTitle:= 'Copyng files...';
    end;
    SHFileOperation(OpStruc);
    MainForm.AddToLog('I','Building translation for this file...Done!');
  except
    on e:Exception do
      MainForm.AddToLog('E','Error at copying files into '+aDirTo+#13+#13+e.Message);
  end;
end;

function ReplaceStringsInSmali(FileName, FolderToPath, OTAServer:string):Boolean ;
var
  IniFiles:TIniFile;
  SmaliFile:TStringList;
  SearchString, ReplaceString, FilePath:string;
  i:Integer;
begin
//  Result:=False;
  IniFiles:=TIniFile.Create(FileName);
  for i := 1 to IniFiles.ReadInteger('Smali', 'Count', 0) do begin
    SmaliFile:=TStringList.Create;
    SearchString:=IniFiles.ReadString(IntToStr(i),'SearchString','Null');
    ReplaceString:=IniFiles.ReadString(IntToStr(i),'ReplaceString','Null');
    FilePath:=FolderToPath+'\'+IniFiles.ReadString(IntToStr(i),'Path','Null');
    if FileExists(FilePath) then begin
    SmaliFile.LoadFromFile(FilePath);
    ReplaceString:=StringReplace(ReplaceString, '%OTAServer%', OTAServer, [rfReplaceAll]);
    SmaliFile.Text:=StringReplace(SmaliFile.Text, SearchString, ReplaceString, [rfReplaceAll]);
    SmaliFile.SaveToFile(FilePath);
    SmaliFile.Free;
    end;
  end;
  Result:=True;
end;

Function DelTree(DirName : string): Boolean;
var
  SHFileOpStruct : TSHFileOpStruct;
  DirBuf : array [0..255] of char;
begin
  try
   Fillchar(SHFileOpStruct,Sizeof(SHFileOpStruct),0) ;
   FillChar(DirBuf, Sizeof(DirBuf), 0 ) ;
   StrPCopy(DirBuf, DirName) ;
   with SHFileOpStruct do begin
    Wnd := 0;
    pFrom := @DirBuf;
    wFunc := FO_DELETE;
    fFlags := FOF_NOCONFIRMATION;
    fFlags := fFlags or FOF_SILENT;
   end;
    Result := (SHFileOperation(SHFileOpStruct) = 0) ;
   except
    Result := False;
  end;
end;

procedure TfrmCompileFirmware.OnDuplicate(Sender:TObject; var Path:string; var Action:TDuplicateAction);
begin
   MainForm.AddToLog('Dupl', Path);
   Action:=daOverwrite;
end;

procedure TfrmCompileFirmware.ExtractPrecompiled(From: string; Dest: string);
var
  DeCryptFile:TFWZipReader;
  i:Integer;
begin
   //CopyFiles(IncludeTrailingBackslash(MainForm.DataDir+'PrecompiledFiles\'+From), Dest,'*');
  DeCryptFile:=TFWZipReader.Create;
  DeCryptFile.LoadFromFile(MainForm.DataDir+'PrecompiledFiles\'+From+'.cryz');
  DeCryptFile.PasswordList.Clear;
  for i := 0 to MainForm.PasswordList.Count-1 do DeCryptFile.PasswordList.Add(MainForm.PasswordList[i]);
  ForceDirectories(MainForm.WorkDir+'TransltTmp');
  DeCryptFile.ExtractAll(MainForm.WorkDir+'TransltTmp');
  CopyFiles(MainForm.WorkDir+'TransltTmp\',Dest,'*');
  DelTree(MainForm.WorkDir+'TransltTmp');
  DeCryptFile.Free;
end;

procedure WriteWatermarkInstaller(FileName, Packager, Support, Device, Version:string; CompileDate:TDateTime);
var
  UpdaterScript:TStringList;
  ConverterStream:TFileStream;
  ConvertedStream:TFileStream;
  B: Byte;
  i,j,id:Integer;
begin
  UpdaterScript:=TStringList.Create;
  UpdaterScript.LoadFromFile(FileName);
  for i := 0 to 20 do UpdaterScript.Insert(i,'ui_print("");');
  id:=20;
  UpdaterScript.Insert(id,'ui_print("     ___                     ___                ");');
  Inc(id);
  UpdaterScript.Insert(id,'ui_print("    /__/\\       ___         /__/\\       ___     ");');
  Inc(id);
  UpdaterScript.Insert(id,'ui_print("   |  |::\\     /  /\\        \\  \\:\\     /  /\\    ");');
  Inc(id);
  UpdaterScript.Insert(id,'ui_print("   |  |:|:\\   /  /:/         \\  \\:\\   /  /:/    ");');
  Inc(id);
  UpdaterScript.Insert(id,'ui_print(" __|__|:|\\:\\ /__/::\\     ___  \\  \\:\\ /__/::\\    ");');
  Inc(id);
  UpdaterScript.Insert(id,'ui_print("/__/::::| \\:\\\\__\\/\\:\\__ /__/\\  \\__\\:\\\\__\\/\\:\\__ ");');
  Inc(id);
  UpdaterScript.Insert(id,'ui_print("\\  \\:\\~~\\__\\/   \\  \\:\\/\\\\  \\:\\ /  /:/   \\  \\:\\/\\");');
  Inc(id);
  UpdaterScript.Insert(id,'ui_print(" \\  \\:\\          \\__\\::/ \\  \\:\\  /:/     \\__\\::/");');
  Inc(id);
  UpdaterScript.Insert(id,'ui_print("  \\  \\:\\         /__/:/   \\  \\:\\/:/      /__/:/ ");');
  Inc(id);
  UpdaterScript.Insert(id,'ui_print("   \\  \\:\\        \\__\\/     \\  \\::/       \\__\\/  ");');
  Inc(id);
  UpdaterScript.Insert(id,'ui_print("    \\__\\/                   \\__\\/               ");');
  Inc(id);
  UpdaterScript.Insert(id,'ui_print("================================================");');
  Inc(id);
  UpdaterScript.Insert(id,'ui_print("");');
  Inc(id);
  UpdaterScript.Insert(id,'ui_print("             (C) KOJAN Development Group        ");');
  Inc(id);
  UpdaterScript.Insert(id,'ui_print("");');
  Inc(id);
  UpdaterScript.Insert(id,'ui_print("================================================");');
  Inc(id);
  UpdaterScript.Insert(id,'ui_print("            M I U I   E v o l u t i o n         ");');
  Inc(id);
  UpdaterScript.Insert(id,'ui_print(" PACKAGER: '+UpperCase(Packager)+'");');
  Inc(id);
  UpdaterScript.Insert(id,'ui_print(" SUPPORT: '+UpperCase(Support)+'");');
  Inc(id);
  UpdaterScript.Insert(id,'ui_print(" FIRMWARE VERSION: '+Version+'");');
  Inc(id);
  UpdaterScript.Insert(id,'ui_print(" DEVICE: '+UpperCase(Device)+'");');
  Inc(id);
  UpdaterScript.Insert(id,'ui_print(" RELEASE DATE: '+FormatDateTime('dd.mm.yyyy', CompileDate)+'");');
  Inc(id);
  UpdaterScript.Insert(id,'ui_print(" SUPPORT: Only on miuirussia.com");');
  Inc(id);
  UpdaterScript.Insert(id,'ui_print("------------------------------------------------");');
  Inc(id);
  UpdaterScript.Insert(id,'ui_print("");');
  Inc(id);
  UpdaterScript.Insert(id,'ui_print("");');
  Inc(id);
  UpdaterScript.Insert(id,'ui_print("Installing firmware...");');
  Inc(id);
  UpdaterScript.Insert(id,'ui_print("");');
  Inc(id);
  if MainForm.AddonsChecked[9] then begin
    UpdaterScript.Add('ui_print("Optimizing firmware only for you phone...");');
    UpdaterScript.Add('ui_print("Please wait (about 2 min.)");');
    UpdaterScript.Add('ui_print("");');
    UpdaterScript.Add('ui_print("Extracting setup files...");');
    UpdaterScript.Add('package_extract_dir("setup", "/tmp");');
    UpdaterScript.Add('ui_print("");');
    UpdaterScript.Add('ui_print("Setting permissions...");');
    UpdaterScript.Add('set_perm(0, 0, 0777, "/tmp/busybox");');
    UpdaterScript.Add('set_perm(0, 0, 0777, "/tmp/dexopt_wrapper");');
    UpdaterScript.Add('set_perm(0, 0, 0777, "/tmp/optimizer-script.sh");');
    UpdaterScript.Add('set_perm(0, 0, 0777, "/tmp/zip");');
    UpdaterScript.Add('set_perm(0, 0, 0777, "/tmp/zipalign");');
    UpdaterScript.Add('ui_print("");');
    UpdaterScript.Add('ui_print("Starting optimizing...");');
    UpdaterScript.Add('run_program("/sbin/sh","/tmp/optimizer-script.sh");');
    UpdaterScript.Add('set_perm_recursive(0, 0, 0755, 0644, "/system/app");');
    UpdaterScript.Add('set_perm_recursive(0, 0, 0755, 0644, "/system/framework");');
    UpdaterScript.Add('ui_print("");');
  end;
  UpdaterScript.Add('run_program("/sbin/busybox", "mount", "/system");');
  UpdaterScript.Add('run_program("/sbin/busybox", "mount", "/data");');
  UpdaterScript.Add('run_program("/sbin/busybox", "mount", "/sdcard");');
  UpdaterScript.Add('delete_recursive("/data/dalvik-cache");');
  UpdaterScript.Add('delete_recursive("/data/data/com.miui.supermarket");');
  UpdaterScript.Add('delete_recursive("/cache");');
  UpdaterScript.Add('ui_print("Cleaning work...");');
  UpdaterScript.Add('unmount("/system");');
  UpdaterScript.Add('unmount("/data");');
  UpdaterScript.Add('ui_print("================== DONE! =======================");');
  ForceDirectories(MainForm.WorkDir+'Temp');
  UpdaterScript.SaveToFile(MainForm.WorkDir+'Temp\Temp.updaterscript');
  ConverterStream:=TFileStream.Create(MainForm.WorkDir+'Temp\Temp.updaterscript', fmOpenReadWrite);
  ConvertedStream:=TFileStream.Create(MainForm.WorkDir+'Temp\Temp.updaterscript.output', fmCreate);
  while ConverterStream.Position < ConverterStream.Size do begin
  ConverterStream.Read(B,SizeOf(Byte));
  if B<>$0D then begin
    ConvertedStream.Write(B,SizeOf(Byte))
  end;
  end;
  ConvertedStream.Seek(SizeOf(Byte),soFromEnd);
  ConvertedStream.Read(B,SizeOf(B));
  if B <> $0A then
   begin
    B := $0A;
    ConvertedStream.Write(B,SizeOf(Byte));
   end;
  ConverterStream.Free;
  ConvertedStream.Free;
  CopyFile(PChar(MainForm.WorkDir+'Temp\Temp.updaterscript.output'), PChar(Filename), False);
  DelTree(MainForm.WorkDir+'Temp');
end;

procedure AddCommandToScript(FileName, Command:string; Insert:Integer=-1);
var
  UpdaterScript:TStringList;
  ConverterStream:TFileStream;
  ConvertedStream:TFileStream;
  B: Byte;
  i,j:Integer;
begin
  UpdaterScript:=TStringList.Create;
  if FileExists(FileName) then
  UpdaterScript.LoadFromFile(FileName);
  if Insert<>-1 then UpdaterScript.Insert(Insert ,Command)
  else UpdaterScript.Add(Command);
  ForceDirectories(MainForm.WorkDir+'Temp');
  UpdaterScript.SaveToFile(MainForm.WorkDir+'Temp\Temp.updaterscript');
  ConverterStream:=TFileStream.Create(MainForm.WorkDir+'Temp\Temp.updaterscript', fmOpenReadWrite);
  ConvertedStream:=TFileStream.Create(MainForm.WorkDir+'Temp\Temp.updaterscript.output', fmCreate);
  while ConverterStream.Position < ConverterStream.Size do begin
  ConverterStream.Read(B,SizeOf(Byte));
  if B<>$0D then begin
    ConvertedStream.Write(B,SizeOf(Byte))
  end;
  end;
  ConvertedStream.Seek(SizeOf(Byte),soFromEnd);
  ConvertedStream.Read(B,SizeOf(B));
  if B <> $0A then
   begin
    B := $0A;
    ConvertedStream.Write(B,SizeOf(Byte));
   end;
  ConverterStream.Free;
  ConvertedStream.Free;
  CopyFile(PChar(MainForm.WorkDir+'Temp\Temp.updaterscript.output'), PChar(Filename), False);
  DelTree(MainForm.WorkDir+'Temp')
end;

procedure TfrmCompileFirmware.ExtractTranslation(From: string; Dect: string);
var
  DeCryptFile:TFWZipReader;
  i:Integer;
begin
  if FileExists(MainForm.DataDir+'LanguageFiles\'+From+'.cryz') then begin
  DeCryptFile:=TFWZipReader.Create;
  DeCryptFile.LoadFromFile(MainForm.DataDir+'LanguageFiles\'+From+'.cryz');
  DeCryptFile.PasswordList.Clear;
  for i := 0 to MainForm.PasswordList.Count-1 do DeCryptFile.PasswordList.Add(MainForm.PasswordList[i]);
  ForceDirectories(MainForm.WorkDir+'TransltTmp');
  DeCryptFile.ExtractAll(MainForm.WorkDir+'TransltTmp');
  if DirectoryExists(MainForm.DataDir+'LanguageFiles_Git\'+From+'\') then begin
    MainForm.AddToLog('I','Loaded from Github: '+MainForm.DataDir+'LanguageFiles_Git\'+From+'\');
    CopyFiles(MainForm.DataDir+'LanguageFiles_Git\'+From+'\',MainForm.WorkDir+'TransltTmp\','*');
  end;
  CopyFiles(MainForm.WorkDir+'TransltTmp\',Dect,'*');
  DelTree(MainForm.WorkDir+'TransltTmp');
  DeCryptFile.Free;
  end else begin
    ForceDirectories(MainForm.WorkDir+'TransltTmp');
    CopyFiles(MainForm.DataDir+'LanguageFiles_Git\'+From+'\',MainForm.WorkDir+'TransltTmp\','*');
    CopyFiles(MainForm.WorkDir+'TransltTmp\',Dect,'*');
    DelTree(MainForm.WorkDir+'TransltTmp');
  end;
end;

function TfrmCompileFirmware.CheckTranslation(Trn: string):Boolean;
var
  TranslationPath:string;
begin
  Result:=False;
  TranslationPath:=MainForm.DataDir+'LanguageFiles\'+Trn+'.cryz';
  if FileExists(TranslationPath) then Result:=True;
  TranslationPath:=MainForm.DataDir+'LanguageFiles_Git\'+Trn;
  if DirectoryExists(TranslationPath) then Result:=True;
end;

procedure TfrmCompileFirmware.PatchTranslationUpdate(Path:string);
var MainDir:string;
    PatchFile:TStringList;
begin
 //ds
  MainForm.AddToLog('I','Checking avaible patchs...');
  MainDir:=IncludeTrailingBackslash(MainForm.WorkDir+'ApplicationSource\'+Path);
  if Path='Email' then begin
    MainForm.AddToLog('I',Path);
    PatchFile:=TStringList.Create;
    PatchFile.Clear;
    PatchFile.LoadFromFile(MainDir+'res\values\ids.xml');
    PatchFile.Text:=StringReplace(PatchFile.Text, '<item type="id" name="main_content"">false</item>', '', [rfReplaceAll]);
    PatchFile.SaveToFile(MainDir+'res\values\ids.xml');
    PatchFile.Clear;
    PatchFile.LoadFromFile(MainDir+'res\values\public.xml');
    PatchFile.Text:=StringReplace(PatchFile.Text, '<public type="id" name="main_content"" id="0x7f0e0102" />', '', [rfReplaceAll]);
    PatchFile.SaveToFile(MainDir+'res\values\public.xml');
    PatchFile.Clear;
    PatchFile.LoadFromFile(MainDir+'res\values-sw600dp\styles.xml');
    PatchFile.Text:=StringReplace(PatchFile.Text, '>@id/main_content"<', '>@id/main_content<', [rfReplaceAll]);
    PatchFile.SaveToFile(MainDir+'res\values-sw600dp\styles.xml');
    PatchFile.Clear;
    PatchFile.LoadFromFile(MainDir+'res\values-sw800dp\styles.xml');
    PatchFile.Text:=StringReplace(PatchFile.Text, '>@id/main_content"<', '>@id/main_content<', [rfReplaceAll]);
    PatchFile.SaveToFile(MainDir+'res\values-sw800dp\styles.xml');
    PatchFile.Clear;
    PatchFile.Free;
  end;
  if Path='framework-res' then begin
    MainForm.AddToLog('I',Path);
    PatchFile:=TStringList.Create;
    PatchFile.Clear;
    PatchFile.LoadFromFile(MainDir+'res\values\plurals.xml');
    PatchFile.Text:=StringReplace(PatchFile.Text, '<item quantity="other">%d of %d</item>', '<item quantity="other">%1$d of %2$d</item>', [rfReplaceAll]);
    PatchFile.SaveToFile(MainDir+'res\values\plurals.xml');
    PatchFile.Clear;
    PatchFile.Free;
    DelTree(MainDir+'res\values-zh-rCN');
  end;
end;

procedure TfrmCompileFirmware.CompileFile(FilePName: string; DataDir: string);
var
  PrepFileName, PrepFilePath, CmdLine, TranslationDest:string;
  ApkFile:TFWZipWriter;
  OrigApkFile, DestApkFile:TFWZipReader;
  BruteForce:boolean;
begin
  PrepFileName:=ExtractFileName(FilePName);
  MainForm.AddToLog('I', 'FileName initialized = '+PrepFileName);
  PrepFilePath:=ExtractFilePath(FilePName);
  MainForm.AddToLog('I', 'FilePath initialized = '+PrepFilePath);
  if CheckTranslation(PrepFileName) then begin
  ForceDirectories(MainForm.WorkDir+'ApplicationSource\');
  DelTree(MainForm.WorkDir+'ApplicationSource\'+PrepFileName);
  CmdLine:=MainForm.JavaHome+'/bin/java -Xmx1024M -jar apktool.jar d "'+PrepFilePath+PrepFileName+'.apk" "'+MainForm.WorkDir+'ApplicationSource\'+PrepFileName+'"';
  ExecuteCommand('Getting sources from APK', CmdLine, MainForm.aAppsDir);
  ForceDirectories(MainForm.WorkDir+'ApplicationSource\'+PrepFileName+'_Translation\');
  TranslationDest:=MainForm.WorkDir+'ApplicationSource\'+PrepFileName+'_Translation\';
  ExtractTranslation(PrepFileName, TranslationDest);
  CopyFiles(TranslationDest+'Files\', IncludeTrailingBackslash(MainForm.WorkDir+'ApplicationSource\'+PrepFileName), '*');
  if FileExists(TranslationDest+'\Smali.rep') then ReplaceStringsInSmali(TranslationDest+'Smali.rep', MainForm.WorkDir+'ApplicationSource\'+PrepFileName+'\smali', MainForm.OTAUpdateServer);
  if FileExists(TranslationDest+'\Info.pche') then PCHEExecutor(MainForm.WorkDir+'ApplicationSource\'+PrepFileName+'\smali\', TranslationDest+'Info.pche');
  ForceDirectories(MainForm.WorkDir+'CompiledFiles\');
  //if MainForm.AddonsChecked[8] then PatchTranslationUpdate(PrepFileName);
  CmdLine:=MainForm.JavaHome+'/bin/java -Xmx1024M -jar apktool.jar b "'+MainForm.WorkDir+'ApplicationSource\'+PrepFileName+'" "'+MainForm.WorkDir+'CompiledFiles\'+PrepFileName+'.apk"';
  if ExecuteCommand('Compiling sources to APK', CmdLine, MainForm.aAppsDir) then BruteForce:=False else BruteForce:=True;
  DestApkFile:=TFWZipReader.Create;
  DestApkFile.LoadFromFile(PrepFilePath+PrepFileName+'.apk');
  if not BruteForce then begin
  OrigApkFile:=TFWZipReader.Create;
  OrigApkFile.LoadFromFile(MainForm.WorkDir+'CompiledFiles\'+PrepFileName+'.apk');
  ForceDirectories(MainForm.WorkDir+'MergeFiles\'+PrepFileName+'_Dest');
  ForceDirectories(MainForm.WorkDir+'MergeFiles\'+PrepFileName+'_Orig');
  DestApkFile.ExtractAll(MainForm.WorkDir+'MergeFiles\'+PrepFileName+'_Dest');
  OrigApkFile.ExtractAll(MainForm.WorkDir+'MergeFiles\'+PrepFileName+'_Orig');
  OrigApkFile.Free;
  DeleteFile(MainForm.WorkDir+'MergeFiles\'+PrepFileName+'_Orig\AndroidManifest.xml');
  DeleteFile(MainForm.WorkDir+'MergeFiles\'+PrepFileName+'_Dest\classes.dex');
  DeleteFile(MainForm.WorkDir+'MergeFiles\'+PrepFileName+'_Dest\resources.arsc');
  DelTree(MainForm.WorkDir+'MergeFiles\'+PrepFileName+'_Dest\res');
  CopyFiles(MainForm.WorkDir+'MergeFiles\'+PrepFileName+'_Orig\', MainForm.WorkDir+'MergeFiles\'+PrepFileName+'_Dest\', '*');
  CopyFiles(TranslationDest+'\Files\assets\', MainForm.WorkDir+'MergeFiles\'+PrepFileName+'_Dest\assets\','*');
  end else begin
     MainForm.AddToLog('I', 'Using brute-force method...Done!');
     DestApkFile.ExtractAll(MainForm.WorkDir+'MergeFiles\'+PrepFileName+'_Dest');
     CopyFiles(TranslationDest+'\Files\', MainForm.WorkDir+'MergeFiles\'+PrepFileName+'_Dest\','*');
  end;
  DestApkFile.Free;
  ApkFile:=TFWZipWriter.Create;
  ApkFile.AddFolder('',MainForm.WorkDir+'MergeFiles\'+PrepFileName+'_Dest\','*');
  DeleteFile(FilePName+'.apk');
  ApkFile.OnProgress:=OnProgress;
  ApkFile.Comment:='Builded with KDG Builder Core';
  ApkFile.BuildZip(FilePName+'.apk');
  ApkFile.Free;
  MainForm.AddToLog('I', 'Deleting application sources...Done!');
  DelTree(MainForm.WorkDir+'ApplicationSource\');
  DelTree(MainForm.WorkDir+'CompiledFiles\');
  DelTree(MainForm.WorkDir+'MergeFiles\');
  end else MainForm.AddToLog('I', 'Translation not found for '+PrepFileName);
end;

Function GetUserFromWindows: string;
Var
   UserName : string;
   UserNameLen : Dword;
Begin
   UserNameLen := 255;
   SetLength(userName, UserNameLen) ;
   If GetUserName(PChar(UserName), UserNameLen) Then
     Result := Copy(UserName,1,UserNameLen - 1)
   Else
     Result := 'Unknown';
End;

function GetTimeZone:String;
var TIME_ZONE:_TIME_ZONE_INFORMATION;
    i, j:integer;
begin
GetTimeZoneInformation(TIME_ZONE);
i:=TIME_ZONE.Bias div 60;
i:= i * -1;
j:=TIME_ZONE.Bias mod 60;
j:=abs(j);
Result:=inttostr(i);
end;

 function DateTimeToUnix(ConvDate: TDateTime): Longint;
 begin
   //example: DateTimeToUnix(now);
  Result := Round((ConvDate - UnixStartDate) * 86400);
 end;

 function UnixToDateTime(USec: Longint): TDateTime;
 begin
   //Example: UnixToDateTime(1003187418);
  Result := (Usec / 86400) + UnixStartDate;
 end;

 function Translit(s: string): string;
const
  rus: string = '‡·‚„‰Â∏ÊÁËÈÍÎÏÌÓÔÒÚÛÙıˆ˜¯˘¸˚˙˝˛ˇ¿¡¬√ƒ≈®∆«»… ÀÃÕŒœ–—“”‘’÷◊ÿŸ‹€⁄›ﬁﬂ';
  lat: array[1..66] of string = ('a', 'b', 'v', 'g', 'd', 'e', 'yo', 'zh', 'z', 'i', 'y', 'k', 'l', 'm', 'n', 'o', 'p', 'r', 's', 't', 'u', 'f', 'kh', 'ts', 'ch', 'sh', 'shch', '''', 'y', '''', 'e', 'yu', 'ya', 'A', 'B', 'V', 'G', 'D', 'E', 'Yo', 'Zh', 'Z', 'I', 'Y', 'K', 'L', 'M', 'N', 'O', 'P', 'R', 'S', 'T', 'U', 'F', 'Kh', 'Ts', 'Ch', 'Sh', 'Shch', '''', 'Y', '''', 'E', 'Yu', 'Ya');
var
  p, i, l: integer;
begin
  Result := '';
  l := Length(s);
  for i := 1 to l do
  begin
    p := Pos(s[i], rus);
    if p<1 then Result := Result + s[i] else Result := Result + lat[p];
  end;
end;

function GetComputerNetName: string;
var
  buffer: array[0..255] of char;
  size: dword;
begin
  size := 256;
  if GetComputerName(buffer, size) then
    Result := buffer
  else
    Result := ''
end;

procedure TfrmCompileFirmware.PatchAndroidPolicy(FileName:string);
var
  CmdLine:string;
  TranslationFile:TStringList;
  ExtractAPK:TFWZipReader;
  BuildedAPK:TFWZipWriter;
begin
  //p
  ForceDirectories(MainForm.WorkDir+'CreatePolicy');
  CmdLine:=MainForm.JavaHome+'/bin/java -Xmx1024M -jar apktool.jar d "'+FileName+'" "'+MainForm.WorkDir+'CreatePolicy\'+GetFileNameWOExt(ExtractFileName(FileName))+'"';
  ExecuteCommand('Decompiling file', CmdLine, MainForm.aAppsDir);
  if FileExists(MainForm.WorkDir+'CreatePolicy\'+GetFileNameWOExt(ExtractFileName(FileName))+'\smali\com\android\internal\policy\impl\GlobalActions$SinglePressAction.smali') then
  begin
    TranslationFile:=TStringList.Create;
    TranslationFile.LoadFromFile(MainForm.WorkDir+'CreatePolicy\'+GetFileNameWOExt(ExtractFileName(FileName))+'\smali\com\android\internal\policy\impl\GlobalActions$SinglePressAction.smali');
    TranslationFile.Text:=StringReplace(TranslationFile.Text, '"Normal"', '"\u041e\u0431\u044b\u0447\u043d\u0430\u044f"', [rfReplaceAll]);
    TranslationFile.Text:=StringReplace(TranslationFile.Text, '"Hot Boot"', '"\u0411\u044b\u0441\u0442\u0440\u0430\u044f"', [rfReplaceAll]);
    TranslationFile.Text:=StringReplace(TranslationFile.Text, '"Bootloader"', '"\u0412 \u0440\u0435\u0436\u0438\u043c \u0437\u0430\u0433\u0440\u0443\u0437\u0447\u0438\u043a\u0430"', [rfReplaceAll]);
    TranslationFile.Text:=StringReplace(TranslationFile.Text, '"Download"', '"\u0412 \u0440\u0435\u0436\u0438\u043c \u0437\u0430\u0433\u0440\u0443\u0437\u0447\u0438\u043a\u0430"', [rfReplaceAll]);
    TranslationFile.Text:=StringReplace(TranslationFile.Text, '"Recovery"', '"\u0412 \u0440\u0435\u0436\u0438\u043c \u0432\u043e\u0441\u0441\u0442\u0430\u043d\u043e\u0432\u043b\u0435\u043d\u0438\u044f"', [rfReplaceAll]);
    TranslationFile.SaveToFile(MainForm.WorkDir+'CreatePolicy\'+GetFileNameWOExt(ExtractFileName(FileName))+'\smali\com\android\internal\policy\impl\GlobalActions$SinglePressAction.smali');
    TranslationFile.Free;
  end;
  ForceDirectories(MainForm.WorkDir+'CompiledFiles');
  CmdLine:=MainForm.JavaHome+'/bin/java -Xmx1024M -jar apktool.jar b "'+MainForm.WorkDir+'CreatePolicy\'+GetFileNameWOExt(ExtractFileName(FileName))+'" "'+MainForm.WorkDir+'CompiledFiles\'+GetFileNameWOExt(ExtractFileName(FileName))+'.jar"';
  ExecuteCommand('Compiling file', CmdLine, MainForm.aAppsDir);
  ForceDirectories(MainForm.WorkDir+'MergeFiles\Translated');
  ForceDirectories(MainForm.WorkDir+'MergeFiles\Original');
  CmdLine:=MainForm.aAppsDir+'\7za x -aoa -o"'+MainForm.WorkDir+'MergeFiles\Translated" "'+MainForm.WorkDir+'CompiledFiles\'+GetFileNameWOExt(ExtractFileName(FileName))+'.jar'+'"';
  ExecuteCommand('Decomp file', CmdLine, MainForm.aAppsDir);
  CmdLine:=MainForm.aAppsDir+'\7za x -aoa -o"'+MainForm.WorkDir+'MergeFiles\Original" "'+FileName+'"';
  ExecuteCommand('Decomp 2 file', CmdLine, MainForm.aAppsDir);
  DeleteFile(MainForm.WorkDir+'MergeFiles\Original\classes.dex');
  CmdLine:=MainForm.aAppsDir+'\7za a -tzip "'+FileName+'" "'+MainForm.WorkDir+'MergeFiles\Translated\*'+'" -mx9 -r';
  ExecuteCommand('Testing file', CmdLine, MainForm.aAppsDir);
  DelTree(MainForm.WorkDir+'CompiledFiles');
  DelTree(MainForm.WorkDir+'MergeFiles');
  DelTree(MainForm.WorkDir+'CreatePolicy');
end;

procedure TfrmCompileFirmware.Button1Click(Sender: TObject);
var
  FirmwareFile:TFWZipReader;
  BuildFirmwareFile:TFWZipWriter;
  ApkFileList, FrameWorkFile, FilesToDelete:TStringList;
  i:Integer;
  IniFiles, IniFile:TIniFile;
  CmdLine, Publisher, unsignedPath, SignedPath, BoardModel, ID1, ID2, BPFingerprint, BPDescription, Support, PhoneModel, FirmwareVersion, Version:string;
begin
  Button1.Enabled:=False;
  DelTree(MainForm.WorkDir+'Firmware');
  FirmwareFile:=TFWZipReader.Create;
  FirmwareFile.LoadFromFile(MainForm.FirmwareFile);
  ForceDirectories(MainForm.WorkDir+'Firmware');
  FirmwareFile.OnProgress:=OnProgress;
  FirmwareFile.ExtractAll(MainForm.WorkDir+'Firmware');
  FilesToDelete:=TStringList.Create;
  FilesToDelete.LoadFromFile(MainForm.WorkDir+'Settings\FilesToDelete.conf');
  for i := 0 to FilesToDelete.Count-1 do begin
    if FileExists(MainForm.WorkDir+'Firmware\system\app\'+FilesToDelete[i]) then DeleteFile(MainForm.WorkDir+'Firmware\system\app\'+FilesToDelete[i]);
  end;
  FilesToDelete.Free;
  MainForm.TaskBar1.ProgressState:=TBPF_NOPROGRESS;
  UbuntuProgress1.Position:=0;
  IniFiles:=TIniFile.Create(MainForm.DataDir+'Language.conf');
  ID1:=IniFiles.ReadString('Language','ID1','ru');
  ID2:=IniFiles.ReadString('Language','ID2','RU');
  Publisher:=IniFiles.ReadString('Language','Publisher','KDG');
  Support:=IniFiles.ReadString('Language','Support','KOJAN Development Group');
  IniFiles.Free;
  FirmwareVersion:=GetBuildPropVariable(MainForm.WorkDir+'Firmware\system\build.prop', 'ro.build.display.id');
  PhoneModel:=GetBuildPropVariable(MainForm.WorkDir+'Firmware\system\build.prop', 'ro.product.device');
  BoardModel:=GetBuildPropVariable(MainForm.WorkDir+'Firmware\system\build.prop', 'ro.product.board');
  Version:='';
  for i := 1 to Length(FirmwareVersion) do if (FirmwareVersion[i] in ['0'..'9']) or (FirmwareVersion[i] in ['.']) then
  begin
    Version:=Version+FirmwareVersion[i];
    if Version[1]='.' then Delete(Version, 1, 1);
  end;
  if Version='' then  Version:=FirmwareVersion;
  MainForm.AddToLog('I','|          Phone model: '+PhoneModel);
  MainForm.AddToLog('I','|          Board model: '+BoardModel);
  MainForm.AddToLog('I','|     Firmware version: '+Version);
  MainForm.AddToLog('I','|   Firmware publisher: '+Publisher);
  MainForm.AddToLog('I','|     Firmware support: '+Support);
  MainForm.AddToLog('I','|    Firmware language: '+ID1+'_'+ID2);
  MainForm.AddToLog('I','|      Language author: KOJAN Development Group');
  ApkFileList:=TStringList.Create;
  FrameWorkFile:=TStringList.Create;
  ApkFileList.Clear;
  FrameWorkFile.Clear;
  FindFiles(MainForm.WorkDir+'Firmware','*.apk',ApkFileList);
  FindFiles(MainForm.WorkDir+'Firmware','framework-res.apk', FrameWorkFile);
  FindFiles(MainForm.WorkDir+'Firmware','framework-miui-res.apk', FrameWorkFile);
  Version:=Version+'.'+FormatDateTime('dd', Now);
  DelTree(MainForm.DataDir+'LanguageFiles_Git');
  CmdLine:=MainForm.aAppsDir+'git.exe clone '+MainForm.GitHubRepository+' "'+MainForm.DataDir+'LanguageFiles_Git"';
  ExecuteCommand('Checking for new translation from GIT', CmdLine, MainForm.aAppsDir, True);
  if MainForm.AddonsChck then begin
     for i := 0 to MainForm.AddonItegrateScriptList.Count-1 do ExtractAddon(MainForm.AddonItegrateScriptList[i], MainForm.WorkDir+'Firmware', True);
     for i := 0 to MainForm.AddonIntegateList.Count-1 do ExtractAddon(MainForm.AddonIntegateList[i], MainForm.WorkDir+'Firmware', False);
  end;
  if FileExists(MainForm.DataDir+'\LanguageFiles_Git\Language.conf') then begin
         IniFiles:=TIniFile.Create(MainForm.DataDir+'\LanguageFiles_Git\Language.conf');
         Memo1.Lines.Add('œÓÎÛ˜ÂÌ‡ ÌÓ‚‡ˇ ‚ÂÒËˇ Ô‡ÍÂÚ‡ ˇÁ˚Í‡: '+IniFiles.ReadString('Language','Version','')+'-git');
         IniFiles.Free;
  end;
  for i := 0 to FrameWorkFile.Count-1 do begin
    CmdLine:=MainForm.JavaHome+'/bin/java -Xmx1024M -jar apktool.jar if "'+FrameWorkFile[i]+'"';
    ExecuteCommand('Installing framework ['+inttostr(i)+']', CmdLine, MainForm.aAppsDir);
  end;
  if MainForm.AddonsChecked[6] then ExtractPrecompiled('OTA_Update', MainForm.WorkDir+'Firmware\');
  ExtractPrecompiled('FirmwareFolder', MainForm.WorkDir+'Firmware\');
  if not MainForm.AddonsChecked[8] then ExtractPrecompiled('FirmwareFolder_Additional', MainForm.WorkDir+'Firmware\');
  for i := 0 to ApkFileList.Count-1 do begin
    MainForm.AddToLog('F',ExtractFileName(ApkFileList[i]));
    CompileFile(GetFileNameWOExt(ApkFileList[i]), MainForm.DataDir+'LanguageFiles');
    MainForm.SetProgress(Round(((i+1)/ApkFileList.Count)*100));
    UbuntuProgress1.Position:=Round(((i+1)/ApkFileList.Count)*100);
  end;
  WriteWatermarkInstaller(MainForm.WorkDir+'Firmware\META-INF\com\google\android\updater-script', Publisher, Support, PhoneModel, Version, Now);
  DeleteFile(MainForm.WorkDir+'Firmware\META-INF\CERT.RSA');
  DeleteFile(MainForm.WorkDir+'Firmware\META-INF\CERT.SF');
  DeleteFile(MainForm.WorkDir+'Firmware\META-INF\MANIFEST.MF');
  SetBuildPropVariable(MainForm.WorkDir+'Firmware\system\build.prop','ro.product.locale.language', ID1);
  SetBuildPropVariable(MainForm.WorkDir+'Firmware\system\build.prop','ro.product.locale.region', ID2);
  SetBuildPropVariable(MainForm.WorkDir+'Firmware\system\build.prop','ro.build.display.id', 'MIUI '+Version);
  SetBuildPropVariable(MainForm.WorkDir+'Firmware\system\build.prop','persist.sys.timezone','Europe/Moscow');
  if not MainForm.AddonsChecked[8] then begin
  SetBuildPropVariable(MainForm.WorkDir+'Firmware\system\build.prop','dalvik.vm.heapsize','48m');
  SetBuildPropVariable(MainForm.WorkDir+'Firmware\system\build.prop','ro.ext4fs','1');
  SetBuildPropVariable(MainForm.WorkDir+'Firmware\system\build.prop','windowsmgr.max_events_per_sec','60');
  SetBuildPropVariable(MainForm.WorkDir+'Firmware\system\build.prop','ro.telephony.call_ring.multiple','false');
  SetBuildPropVariable(MainForm.WorkDir+'Firmware\system\build.prop','dalvik.vm.verify-bytecode','false');
  if not ((PhoneModel='p990') or (PhoneModel='p999')) then
  SetBuildPropVariable(MainForm.WorkDir+'Firmware\system\build.prop','dalvik.vm.dexopt-flags','v=n,o=v');
  SetBuildPropVariable(MainForm.WorkDir+'Firmware\system\build.prop','ro.vold.umsdirtyratio','20');
  SetBuildPropVariable(MainForm.WorkDir+'Firmware\system\build.prop','dalvik.vm.usemodule','com.kojan.dalvikvm');
  SetBuildPropVariable(MainForm.WorkDir+'Firmware\system\build.prop','ro.kernel.android.checkjni','0');
  SetBuildPropVariable(MainForm.WorkDir+'Firmware\system\build.prop','ro.HOME_APP_MEM','4096');
  SetBuildPropVariable(MainForm.WorkDir+'Firmware\system\build.prop','ro.HOME_APP_ADJ','1');
  SetBuildPropVariable(MainForm.WorkDir+'Firmware\system\build.prop','wifi.supplicant_scan_interval','100');
  SetBuildPropVariable(MainForm.WorkDir+'Firmware\system\build.prop','ro.media.enc.jpeg.quality','100');
  SetBuildPropVariable(MainForm.WorkDir+'Firmware\system\build.prop','ro.telephony.call_ring.delay','0');
  end;
  SetBuildPropVariable(MainForm.WorkDir+'Firmware\system\build.prop','ro.build.type','user');
  SetBuildPropVariable(MainForm.WorkDir+'Firmware\system\build.prop','ro.build.tags','release-keys');
  SetBuildPropVariable(MainForm.WorkDir+'Firmware\system\build.prop','ro.build.date', FormatDateTime('dddddd' , Now)+' '+FormatDateTime('tt' , Now)+' GMT+'+GetTimeZone);
  SetBuildPropVariable(MainForm.WorkDir+'Firmware\system\build.prop','ro.build.version.incremental', Version);
  SetBuildPropVariable(MainForm.WorkDir+'Firmware\system\build.prop','ro.config.ringtone', 'MI.ogg');
  SetBuildPropVariable(MainForm.WorkDir+'Firmware\system\build.prop','ro.config.notification_sound', 'FadeIn.ogg');
  SetBuildPropVariable(MainForm.WorkDir+'Firmware\system\build.prop','ro.config.alarm_alert', 'ClassicAlarm.ogg');
  SetBuildPropVariable(MainForm.WorkDir+'Firmware\system\build.prop','ro.build.user', Translit(LowerCase(GetUserFromWindows)));
  SetBuildPropVariable(MainForm.WorkDir+'Firmware\system\build.prop','ro.build.host', Translit(LowerCase(GetComputerNetName)));
  if MainForm.AddonsChecked[3] then begin
    SetBuildPropVariable(MainForm.WorkDir+'Firmware\system\build.prop','ro.service.swiqi.supported', 'true');
    SetBuildPropVariable(MainForm.WorkDir+'Firmware\system\build.prop','persist.service.swiqi.enable', '1');
  end;
  if MainForm.AddonsChecked[4] then begin
    SetBuildPropVariable(MainForm.WorkDir+'Firmware\system\build.prop','ro.semc.sound_effects_enabled', 'true');
    SetBuildPropVariable(MainForm.WorkDir+'Firmware\system\build.prop','ro.semc.xloud.supported', 'true');
    SetBuildPropVariable(MainForm.WorkDir+'Firmware\system\build.prop','persist.service.xloud.enable', '1');
  end;
  if FileExists(MainForm.WorkDir+'Settings\Firmware.conf') then begin
  IniFile:=TIniFile.Create(MainForm.WorkDir+'Settings\Firmware.conf');
  BPDescription:=IniFile.ReadString('Firmware','Description','0');
  BPFingerprint:=IniFile.ReadString('Firmware','Fingerprint','0');
  if (BPDescription<>'0') and (BPFingerprint<>'0') then begin
    SetBuildPropVariable(MainForm.WorkDir+'Firmware\system\build.prop','ro.build.description',BPDescription);
    SetBuildPropVariable(MainForm.WorkDir+'Firmware\system\build.prop','ro.build.fingerprint',BPFingerprint);
  end;
  IniFile.UpdateFile;
  IniFile.Free;
  end;
  if MainForm.AddonsChecked[0] then ExtractPrecompiled('CPUControl', MainForm.WorkDir+'Firmware\');
  if MainForm.AddonsChecked[1] then ExtractPrecompiled('KDG_Addons', MainForm.WorkDir+'Firmware\');
  if MainForm.AddonsChecked[2] then ExtractPrecompiled('KDG_Font', MainForm.WorkDir+'Firmware\');
  if MainForm.AddonsChecked[3] then ExtractPrecompiled('KDG_Bravia', MainForm.WorkDir+'Firmware\');
  if MainForm.AddonsChecked[4] then ExtractPrecompiled('KDG_XLoud', MainForm.WorkDir+'Firmware\');
  if MainForm.AddonsChecked[5] then ExtractPrecompiled('KDG_Theme', MainForm.WorkDir+'Firmware\');
  if not MainForm.AddonsChecked[8] then if FileExists(MainForm.DataDir+'PrecompiledFiles\Package_'+PhoneModel+'.cryz') then ExtractPrecompiled('Package_'+PhoneModel, MainForm.WorkDir+'Firmware\');
  if MainForm.AddonsChecked[7] then PatchAndroidPolicy(MainForm.WorkDir+'Firmware\system\framework\android.policy.jar');
  if MainForm.AddonsChecked[9] then ExtractPrecompiled('KDG_Odex', MainForm.WorkDir+'Firmware\');

  UnsignedPath:='evolution_'+PhoneModel+'_'+Version;
  BuildFirmwareFile:=TFWZipWriter.Create;
  BuildFirmwareFile.AddFolder('',MainForm.WorkDir+'Firmware','*');
  BuildFirmwareFile.BuildZip(IncludeTrailingBackslash(ExtractFilePath(MainForm.FirmwareFile))+UnSignedPath+'_unsigned.zip');
  BuildFirmwareFile.OnProgress:=OnProgress;
  BuildFirmwareFile.Free;
  SignedPath:=IncludeTrailingBackslash(ExtractFilePath(MainForm.FirmwareFile))+UnSignedPath+'.zip';
  CmdLine:=MainForm.JavaHome+'/bin/java -Xmx512M -jar signapk.jar testkey.x509.pem testkey.pk8 "'+IncludeTrailingBackslash(ExtractFilePath(MainForm.FirmwareFile))+UnSignedPath+'_unsigned.zip'+'" "'+ SignedPath +'"';
  if ExecuteCommand('Signing firmware', CmdLine, MainForm.aAppsDir, True) then DeleteFile(IncludeTrailingBackslash(ExtractFilePath(MainForm.FirmwareFile))+UnSignedPath+'_unsigned.zip');
  MainForm.TaskBar1.ProgressState:=TBPF_NOPROGRESS;
  DelTree(MainForm.WorkDir+'Firmware');
  MainForm.btnNext.Enabled:=True;
  Beep;
end;

procedure MergeKernelInstallScript(KernelNumber ,KernelFileName, FileName:string);
var
  UpdaterScript:TStringList;
  KernelScript:TStringList;
  ConverterStream:TFileStream;
  ConvertedStream:TFileStream;
  B: Byte;
  i:Integer;
begin
  UpdaterScript:=TStringList.Create;
  UpdaterScript.LoadFromFile(FileName);
  KernelScript:=TStringList.Create;
  KernelScript.LoadFromFile(KernelFileName);
  UpdaterScript.Add('ui_print("-----------------------------------------------");');
  UpdaterScript.Add('ui_print("--------- Installing integrated addon: --------");');
  UpdaterScript.Add('ui_print("---------           Warning!           --------");');
  UpdaterScript.Add('ui_print("---------    It may take a long time   --------");');
  UpdaterScript.Add('ui_print("  Addon Name: '+KernelNumber+'");');
  for i := 0 to KernelScript.Count-1 do begin
    UpdaterScript.Add(KernelScript[i]);
  end;
  UpdaterScript.Add('ui_print("----------- End of installing addons ----------");');
  UpdaterScript.Add('ui_print("-----------------------------------------------");');
  ForceDirectories(MainForm.WorkDir+'Temp');
  UpdaterScript.SaveToFile(MainForm.WorkDir+'Temp\Temp.updaterscript');
  ConverterStream:=TFileStream.Create(MainForm.WorkDir+'Temp\Temp.updaterscript', fmOpenReadWrite);
  ConvertedStream:=TFileStream.Create(MainForm.WorkDir+'Temp\Temp.updaterscript.output', fmCreate);
  while ConverterStream.Position < ConverterStream.Size do begin
  ConverterStream.Read(B,SizeOf(Byte));
  if B<>$0D then begin
    ConvertedStream.Write(B,SizeOf(Byte))
  end;
  end;
  ConvertedStream.Seek(SizeOf(Byte),soFromEnd);
  ConvertedStream.Read(B,SizeOf(B));
  if B <> $0A then
   begin
    B := $0A;
    ConvertedStream.Write(B,SizeOf(Byte));
   end;
  ConverterStream.Free;
  ConvertedStream.Free;
  CopyFile(PChar(MainForm.WorkDir+'Temp\Temp.updaterscript.output'), PChar(Filename), False);
  DelTree(MainForm.WorkDir+'Temp');
end;

procedure TfrmCompileFirmware.ExtractAddon(Addon: string; Dest: string; Integrate: Boolean);
var
  ZipFile:TFWZipReader;
begin
 //ghh
  ZipFile:=TFWZipReader.Create;
  ZipFile.LoadFromFile(Addon);
  ForceDirectories(MainForm.WorkDir+'Addon');
  ZipFile.ExtractAll(MainForm.WorkDir+'Addon');
  if Integrate then MergeKernelInstallScript(GetFileNameWOExt(ExtractFileName(Addon)), MainForm.WorkDir+'Addon\META-INF\com\google\android\updater-script', IncludeTrailingBackslash(Dest)+'META-INF\com\google\android\updater-script');
  DelTree(MainForm.WorkDir+'Addon\META-INF');
  CopyFiles(MainForm.WorkDir+'Addon\' ,IncludeTrailingBackslash(Dest), '*');
  DelTree(MainForm.WorkDir+'Addon');
  ZipFile.Free;
end;

procedure TfrmCompileFirmware.OnProgress(Sender: TObject; const FileName: string; Percent: Byte; TotalPercent: Byte; var Cancel: Boolean);
begin
  UbuntuProgress1.Position:=TotalPercent;
  MainForm.TaskBar1.ProgressState:=TBPF_NORMAL;
  MainForm.TaskBar1.ProgressValue:=TotalPercent;
  Application.ProcessMessages;
end;

end.
