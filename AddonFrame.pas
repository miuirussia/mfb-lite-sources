unit AddonFrame;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TfrmAddons = class(TFrame)
    GroupBox1: TGroupBox;
    chkCPUControl: TCheckBox;
    chkKDGAddons: TCheckBox;
    chkKDGFont: TCheckBox;
    chkSonyBravia: TCheckBox;
    chkSonyXLoud: TCheckBox;
    lstDelete: TListBox;
    btnAdd: TButton;
    btnRemove: TButton;
    chkTheme: TCheckBox;
    chkPrepareOTA: TCheckBox;
    chkTranslate4Way: TCheckBox;
    chkMineField: TCheckBox;
    chkOdexAddon: TCheckBox;
    procedure btnAddClick(Sender: TObject);
    procedure btnRemoveClick(Sender: TObject);
    procedure chkCPUControlClick(Sender: TObject);
    procedure chkMineFieldClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

uses MainUnit;

procedure TfrmAddons.btnAddClick(Sender: TObject);
begin
  lstDelete.Items.Add(InputBox('Program list editor', 'Пожалуйста, Введите приложение, которое будет удаляться при компиляции', 'Supermarket.apk'));
  lstDelete.Items.SaveToFile(MainForm.WorkDir+'Settings\FilesToDelete.conf');
end;

procedure TfrmAddons.btnRemoveClick(Sender: TObject);
begin
  lstDelete.Items.Delete(lstDelete.ItemIndex);
  lstDelete.Items.SaveToFile(MainForm.WorkDir+'Settings\FilesToDelete.conf');
end;

procedure TfrmAddons.chkCPUControlClick(Sender: TObject);
begin
  MainForm.AddonsChecked[0]:=chkCPUControl.Checked;
  MainForm.AddonsChecked[1]:=chkKDGAddons.Checked;
  MainForm.AddonsChecked[2]:=chkKDGFont.Checked;
  MainForm.AddonsChecked[3]:=chkSonyBravia.Checked;
  MainForm.AddonsChecked[4]:=chkSonyXLoud.Checked;
  MainForm.AddonsChecked[5]:=chkTheme.Checked;
  MainForm.AddonsChecked[6]:=chkPrepareOTA.Checked;
  MainForm.AddonsChecked[7]:=chkTranslate4Way.Checked;
  MainForm.AddonsChecked[9]:=chkOdexAddon.Checked;
end;

procedure TfrmAddons.chkMineFieldClick(Sender: TObject);
var
  i:integer;
begin
  if chkMineField.Checked then begin
    for i := 0 to 7 do MainForm.AddonsChecked[i]:=False;
    chkCPUControl.Enabled:=False;
    chkKDGAddons.Enabled:=False;
    chkKDGFont.Enabled:=False;
    chkSonyBravia.Enabled:=False;
    chkSonyXLoud.Enabled:=False;
    chkTheme.Enabled:=False;
    chkPrepareOTA.Enabled:=False;
    chkTranslate4Way.Enabled:=False;
    chkCPUControl.Checked:=False;
    chkKDGAddons.Checked:=False;
    chkKDGFont.Checked:=False;
    chkSonyBravia.Checked:=False;
    chkSonyXLoud.Checked:=False;
    chkTheme.Checked:=False;
    chkPrepareOTA.Checked:=False;
    chkTranslate4Way.Checked:=False;
  end else begin
    chkCPUControl.Enabled:=True;
    chkKDGAddons.Enabled:=True;
    chkKDGFont.Enabled:=True;
    chkSonyBravia.Enabled:=True;
    chkSonyXLoud.Enabled:=True;
    chkTheme.Enabled:=True;
    chkPrepareOTA.Enabled:=True;
    chkTranslate4Way.Enabled:=True;
  end;
  MainForm.AddonsChecked[8]:=chkMineField.Checked;
end;

end.
