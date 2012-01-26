unit GitHubChooiser;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls,
  dxGDIPlusClasses, Vcl.ExtCtrls;

type
  TGitHubRepositories = class(TFrame)
    cbbGitHubs: TComboBox;
    Label1: TLabel;
    Image1: TImage;
    Label2: TLabel;
    procedure cbbGitHubsChange(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.dfm}

uses MainUnit;

procedure TGitHubRepositories.cbbGitHubsChange(Sender: TObject);
var i:integer;
begin
  i:=cbbGitHubs.ItemIndex;
  MainForm.GitHubRepository:=MainForm.GitHubs[i];
  MainForm.AddToLog('I','Added git: "'+MainForm.GitHubs[i]+'"');
  MainForm.btnNext.Enabled:=True;
end;

end.
