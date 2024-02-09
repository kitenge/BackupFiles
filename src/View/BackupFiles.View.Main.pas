unit BackupFiles.View.Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.Edit, BackupFiles.Model.Interfaces,
  BackupFiles.Controller.BackupItem;

type
  TViewMain = class(TForm)
    edtcaminho: TEdit;
    Button1: TButton;
    Button2: TButton;
    Edit1: TEdit;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    FItem: iBackupItem;
    str : string;
  end;

var
  ViewMain: TViewMain;

implementation

{$R *.fmx}

procedure TViewMain.Button1Click(Sender: TObject);
var
  Item: iBackupItem;
begin
  Item := TControllerBackupItem.New.Item;
  Item.Caminho(edtcaminho.Text).Salvar;
  str := Item.Codigo;
  ShowMessage(Item.Caminho);
end;

procedure TViewMain.Button2Click(Sender: TObject);
var
  Item: iBackupItem;
begin
  Item := TControllerBackupItem.New.Item.BuscarDados(Edit1.Text);
  Item.Salvar;
  ShowMessage(Item.Caminho);
end;

end.
