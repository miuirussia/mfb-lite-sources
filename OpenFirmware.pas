unit OpenFirmware;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, JvBaseDlg,
  JvBrowseFolder, Vcl.ComCtrls, Vcl.CheckLst, System.Masks;

type
  TfrmOpenFirmware = class(TFrame)
    edtFirmwareFile: TEdit;
    btnBrowseFirmware: TButton;
    Label1: TLabel;
    CheckBox1: TCheckBox;
    edtAddonsFolder: TEdit;
    btnBrowseAddon: TButton;
    OpenDialog1: TOpenDialog;
    JvBrowseForFolderDialog1: TJvBrowseForFolderDialog;
    btnRepository: TButton;
    grpGeneralGroup: TGroupBox;
    GroupBox1: TGroupBox;
    CheckListBox1: TCheckListBox;
    Label2: TLabel;
    procedure CheckBox1Click(Sender: TObject);
    procedure btnBrowseFirmwareClick(Sender: TObject);
    procedure edtFirmwareFileChange(Sender: TObject);
    procedure btnBrowseAddonClick(Sender: TObject);
    procedure edtAddonsFolderChange(Sender: TObject);
    procedure CheckListBox1ClickCheck(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

uses MainUnit;

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

procedure TfrmOpenFirmware.btnBrowseAddonClick(Sender: TObject);
begin
  if JvBrowseForFolderDialog1.Execute then edtAddonsFolder.Text:=JvBrowseForFolderDialog1.Directory;
end;

procedure TfrmOpenFirmware.btnBrowseFirmwareClick(Sender: TObject);
begin
  if OpenDialog1.Execute then edtFirmwareFile.Text:=OpenDialog1.FileName;
end;

procedure TfrmOpenFirmware.CheckBox1Click(Sender: TObject);
begin
  if CheckBox1.Checked then begin
    edtAddonsFolder.Enabled:=True;
    btnBrowseAddon.Enabled:=True;
    //btnRepository.Enabled:=True
  end else begin
    edtAddonsFolder.Enabled:=False;
    btnBrowseAddon.Enabled:=False;
    //btnRepository.Enabled:=False;
  end;
  MainForm.AddonsChck:=CheckBox1.Checked;
end;

procedure TfrmOpenFirmware.CheckListBox1ClickCheck(Sender: TObject);
var
  i:Integer;
begin
  MainForm.AddonItegrateScriptList.Clear;
  MainForm.AddonIntegateList.Clear;
  for i := 0 to CheckListBox1.Count-1 do begin
     if CheckListBox1.Checked[i] then begin
       MainForm.AddonItegrateScriptList.Add(CheckListBox1.Items[i]);
       MainForm.AddToLog('I','Addon with integrating script: '+ CheckListBox1.Items[i]);
     end else begin
       MainForm.AddonIntegateList.Add(CheckListBox1.Items[i]);
       MainForm.AddToLog('I','Addon without integrating script: '+ CheckListBox1.Items[i]);
     end;
  end;
end;

procedure TfrmOpenFirmware.edtAddonsFolderChange(Sender: TObject);
var
  i:Integer;
begin
  if DirectoryExists(edtAddonsFolder.Text) then begin
    MainForm.AddonsDir:=edtAddonsFolder.Text;
    FindFiles(edtAddonsFolder.Text, '*.zip', CheckListBox1.Items);
    for i := 0 to CheckListBox1.Count-1 do begin
     if CheckListBox1.Checked[i] then begin
       MainForm.AddonItegrateScriptList.Add(CheckListBox1.Items[i]);
       MainForm.AddToLog('I','Addon with integrating script: '+ CheckListBox1.Items[i]);
     end else begin
       MainForm.AddonIntegateList.Add(CheckListBox1.Items[i]);
       MainForm.AddToLog('I','Addon without integrating script: '+ CheckListBox1.Items[i]);
     end;
    end;
  end;
end;

procedure TfrmOpenFirmware.edtFirmwareFileChange(Sender: TObject);
begin
  if FileExists(edtFirmwareFile.Text) then begin
  MainForm.FirmwareFile:=edtFirmwareFile.Text;
  MainForm.btnNext.Enabled:=True;
  end else MainForm.btnNext.Enabled:=False;
end;

end.
