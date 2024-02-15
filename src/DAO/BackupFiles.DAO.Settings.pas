unit BackupFiles.DAO.Settings;

interface

uses
  System.SysUtils,
  System.Classes,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Param,
  FireDAC.Stan.Error,
  FireDAC.DatS,
  FireDAC.Phys.Intf,
  FireDAC.DApt.Intf,
  FireDAC.Stan.Async,
  FireDAC.DApt, Data.DB,
  FireDAC.Comp.DataSet,
  FireDAC.Comp.Client,
  BackupFiles.Controller.Settings;

type
  TdmSettings = class(TDataModule)
    TabConfiguracao: TFDQuery;
    procedure DataModuleCreate(Sender: TObject);
  private
    { Private declarations }
    procedure VerificaCamposBanco;
    procedure VerificaConfiguracao;
  public
    { Public declarations }
  end;

var
  dmSettings: TdmSettings;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}

uses BackupFiles.DAO.Main;

procedure TdmSettings.DataModuleCreate(Sender: TObject);
begin
  VerificaCamposBanco;
  VerificaConfiguracao;
end;

procedure TdmSettings.VerificaCamposBanco;
begin
  DM.VerificaTabela('CONFIGURACAO');
  DM.VerificaCampos('CONFIGURACAO', 'Codigo', 'TEXT(25)');
  DM.VerificaCampos('CONFIGURACAO', 'IniciarComWindows', 'BOOLEAN');
end;

procedure TdmSettings.VerificaConfiguracao;
begin
  TControllerSettings.New.Item;
end;

{$R *.dfm}

end.
