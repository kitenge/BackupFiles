unit BackupFiles.DAO.Main;

interface

uses
  System.SysUtils,
  System.Classes,
  FireDAC.Stan.Intf,
  FireDAC.Stan.Option,
  FireDAC.Stan.Error,
  FireDAC.UI.Intf,
  FireDAC.Phys.Intf,
  FireDAC.Stan.Def,
  FireDAC.Stan.Pool,
  FireDAC.Stan.Async,
  FireDAC.Phys,
  FireDAC.FMXUI.Wait,
  Data.DB,
  FireDAC.Comp.Client,
  FireDAC.Phys.SQLite,
  FireDAC.Phys.SQLiteDef,
  FireDAC.Stan.ExprFuncs,
  FireDAC.Phys.SQLiteWrapper.Stat,
  System.IOUtils;

type
  TDM = class(TDataModule)
    database: TFDConnection;
    procedure DataModuleCreate(Sender: TObject);
  private
    procedure ConectarBanco;
    { Private declarations }
  public
    { Public declarations }
  end;

var
  DM: TDM;

implementation

{%CLASSGROUP 'FMX.Controls.TControl'}
{$R *.dfm}

procedure TDM.DataModuleCreate(Sender: TObject);
begin
  ConectarBanco;
end;

procedure TDM.ConectarBanco;
begin
  if not database.Connected then
    database.Params.database := ExtractFilePath(ParamStr(0)) + 'resources\BackupFiles.db';
  database.Connected := True;
end;

end.
