unit CryModule;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.Masks, Vcl.StdCtrls, FWZipReader, FWZipWriter, FWZipCrypt, System.ZLib,
  UbuntuProgress, Winapi.ShellAPI;

type
  TCryMode = class(TForm)
    Button1: TButton;
    Button2: TButton;
    UbuntuProgress1: TUbuntuProgress;
    procedure Button1Click(Sender: TObject);
    procedure OnProgress(Sender: TObject; const FileName: string; Percent: Byte; TotalPercent: Byte; var Cancel: Boolean);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  CryMode: TCryMode;

implementation

{$R *.dfm}

uses MainUnit;

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

function GetFileNameWOExt(fn:String):String;
begin
  Result := Copy(fn, 1, Length(fn)-Length(ExtractFileExt(fn)));
end;

procedure TCryMode.Button2Click(Sender: TObject);
var
  FoldersToDeCrypt:TStringList;
  DeCryptFile:TFWZipReader;
  i,j:Integer;
begin
  FoldersToDeCrypt:=TStringList.Create;
  FoldersToDeCrypt.Clear;
  FindFiles(MainForm.DataDir+'LanguageFiles\', '*.cryz', FoldersToDeCrypt, False);
  FindFiles(MainForm.DataDir+'PrecompiledFiles\', '*.cryz', FoldersToDeCrypt, False);
  for i := 0 to FoldersToDeCrypt.Count-1 do begin
     DeCryptFile:=TFWZipReader.Create;
     DeCryptFile.OnProgress:=OnProgress;
     DeCryptFile.LoadFromFile(FoldersToDeCrypt[i]);
     DeCryptFile.PasswordList.Clear;
     for j := 0 to MainForm.PasswordList.Count-1 do DeCryptFile.PasswordList.Add(MainForm.PasswordList[j]);
     ForceDirectories(GetFileNameWOExt(FoldersToDeCrypt[i]));
     DeCryptFile.ExtractAll(GetFileNameWOExt(FoldersToDeCrypt[i]));
     DeCryptFile.Free;
     DeleteFile(FoldersToDeCrypt[i]);
  end;
  FoldersToDeCrypt.Free;
end;

procedure TCryMode.OnProgress(Sender: TObject; const FileName: string; Percent: Byte; TotalPercent: Byte; var Cancel: Boolean);
begin
  UbuntuProgress1.Position:=TotalPercent;
  Application.ProcessMessages;
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

procedure TCryMode.Button1Click(Sender: TObject);
var
  FoldersToCrypt:TStringList;
  CryptFile:TFWZipWriter;
  i,j:Integer;
begin
  FoldersToCrypt:=TStringList.Create;
  FoldersToCrypt.Clear;
  FindFolders(MainForm.DataDir+'LanguageFiles', '*', FoldersToCrypt);
  FindFolders(MainForm.DataDir+'PrecompiledFiles', '*', FoldersToCrypt);
  for i := 0 to FoldersToCrypt.Count-1 do begin
     CryptFile:=TFWZipWriter.Create;
     CryptFile.OnProgress:=OnProgress;
     CryptFile.AddFolder('',FoldersToCrypt[i],'*');
     for j := 0 to CryptFile.Count-1 do begin
       CryptFile.Item[j].Password:=MainForm.PasswordList[Random(MainForm.PasswordList.Count-1)];
       MainForm.AddToLog('I', CryptFile.Item[j].FileName+' - '+CryptFile.Item[j].Password);
       CryptFile.Item[j].CompressionLevel:=clMax;
     end;
     CryptFile.BuildZip(GetFileNameWOExt(FoldersToCrypt[i])+'.cryz');
     DelTree(FoldersToCrypt[i]);
     CryptFile.Free;
  end;
  FoldersToCrypt.Free;
end;

end.
