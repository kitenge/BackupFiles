unit BackupFiles.View.Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Edit, BackupFiles.Controller.BackupItem;

type
  TViewMain = class(TForm)
    Edit1: TEdit;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    FItem: iBackupItem;
  end;

var
  ViewMain: TViewMain;

implementation

{$R *.fmx}

procedure TViewMain.Button1Click(Sender: TObject);
var
  Item: iBackupItem;
begin
  Item := TControllerBackupItem.New.Item.Caminho(Edit1.Text);
  ShowMessage(Item.Caminho);
end;

end.
