unit BackupFiles.Model.StorageSettings;

interface

uses
  BackupFiles.Model.Interfaces,
  System.DateUtils, BackupFiles.DAO.StorageSettings;

type
  TStorageSettings = class(TInterfacedObject, iStorageSettings)
  strict private
    function GenerateUniqueCode: string;
  private
    FDiretorio: string;
    FServidor: string;
    FUsuario: string;
    FSenha: string;
    FPorta: integer;
    FCodigo: string;
    FTipoConfiguracao: TTipoConfigStorage;
    { Campos privados }
    function Diretorio(Value: string): iStorageSettings; overload;
    function Diretorio: string; overload;
    function Servidor(Value: string): iStorageSettings; overload;
    function Servidor: string; overload;
    function Usuario(Value: string): iStorageSettings; overload;
    function Usuario: string; overload;
    function Senha(Value: string): iStorageSettings; overload;
    function Senha: string; overload;
    function Porta(Value: integer): iStorageSettings; overload;
    function Porta: integer; overload;
    function Codigo: string;
    function TipoConfiguracao(Value: TTipoConfigStorage)
      : iStorageSettings; overload;
    function TipoConfiguracao: TTipoConfigStorage; overload;
    function BuscarDados(aCodigo: string): iStorageSettings;
    function Salvar: iStorageSettings;
  public
    constructor Create(TipoConfiguracao: TTipoConfigStorage);
    destructor Destroy; override;
    class function New(TipoConfiguracao: TTipoConfigStorage): iStorageSettings;
  end;

implementation

uses
  System.SysUtils;

{ TStorageSettings }

function TStorageSettings.GenerateUniqueCode: string;
var
  GUID: TGUID;
  Timestamp: Int64;
  RandomPart: string;
begin
  // Gera um GUID
  CreateGUID(GUID);
  // Converte o GUID em string e remove os caracteres n�o num�ricos
  Result := GUIDToString(GUID).Replace('{', '').Replace('}', '')
    .Replace('-', '');
  // Pega apenas os primeiros 18 caracteres para deixar espa�o para o resto
  Result := Copy(Result, 1, 18);
  // Gera um timestamp
  Timestamp := DateTimeToUnix(Now, False);
  // Converte o timestamp para string e pega os �ltimos 7 d�gitos
  RandomPart := IntToStr(Timestamp mod 10000000);
  // Assegura que a parte aleat�ria tenha 7 caracteres, preenchendo com '0' se necess�rio
  while Length(RandomPart) < 7 do
    RandomPart := '0' + RandomPart;
  // Combina as partes para formar um c�digo �nico de 25 caracteres
  Result := Copy(Result + RandomPart, 1, 25);
end;

function TStorageSettings.BuscarDados(aCodigo: string): iStorageSettings;
begin
  if (aCodigo.IsEmpty) or (Length(aCodigo) <> 25) then
    raise Exception.Create('C�digo de configura��o inv�lido para busca');

  dmStorageSettings.TabConfiguracaoArmazenamentoFiltrada.Close;
  dmStorageSettings.TabConfiguracaoArmazenamentoFiltrada.ParamByName('codigo')
    .AsString := aCodigo;
  dmStorageSettings.TabConfiguracaoArmazenamentoFiltrada.Open;

  FDiretorio := dmStorageSettings.TabConfiguracaoArmazenamentoFiltrada.
    FieldByName('Diretorio').AsString;
  FServidor := dmStorageSettings.TabConfiguracaoArmazenamentoFiltrada.
    FieldByName('Servidor').AsString;
  FUsuario := dmStorageSettings.TabConfiguracaoArmazenamentoFiltrada.FieldByName
    ('Usuario').AsString;
  FSenha := dmStorageSettings.TabConfiguracaoArmazenamentoFiltrada.FieldByName
    ('Senha').AsString;
  FPorta := dmStorageSettings.TabConfiguracaoArmazenamentoFiltrada.FieldByName
    ('Porta').AsInteger;
  FCodigo := dmStorageSettings.TabConfiguracaoArmazenamentoFiltrada.FieldByName
    ('Codigo').AsString;

  if dmStorageSettings.TabConfiguracaoArmazenamentoFiltrada.FieldByName
    ('TipoConfiguracao').AsString = 'FTP' then
    FTipoConfiguracao := FTP
  else
    FTipoConfiguracao := Local;

  Result := Self;
end;

function TStorageSettings.Codigo: string;
begin
  Result := FCodigo;
end;

constructor TStorageSettings.Create(TipoConfiguracao: TTipoConfigStorage);
begin
  FCodigo := GenerateUniqueCode;
end;

destructor TStorageSettings.Destroy;
begin

  inherited;
end;

function TStorageSettings.Diretorio(Value: string): iStorageSettings;
begin
  if Value = '' then
    raise Exception.Create('O Caminho do diret�rio n�o pode estar em branco');
  if not DirectoryExists(Value) then
    raise Exception.Create('O diret�rio informado n�o existe');
  FDiretorio := Value;
  Result := Self;
end;

function TStorageSettings.Diretorio: string;
begin
  Result := FDiretorio;
end;

class function TStorageSettings.New(TipoConfiguracao: TTipoConfigStorage)
  : iStorageSettings;
begin
  Result := Self.Create(TipoConfiguracao);
end;

function TStorageSettings.Porta(Value: integer): iStorageSettings;
begin
  FPorta := Value;
  Result := Self;
end;

function TStorageSettings.Porta: integer;
begin
  Result := FPorta;
end;

function TStorageSettings.Senha(Value: string): iStorageSettings;
begin
  FSenha := Value;
  Result := Self;
end;

function TStorageSettings.Salvar: iStorageSettings;
begin

end;

function TStorageSettings.Senha: string;
begin
  Result := FSenha;
end;

function TStorageSettings.Servidor: string;
begin
  Result := FServidor;
end;

function TStorageSettings.TipoConfiguracao: TTipoConfigStorage;
begin
  Result := FTipoConfiguracao;
end;

function TStorageSettings.TipoConfiguracao(Value: TTipoConfigStorage)
  : iStorageSettings;
begin
  FTipoConfiguracao := Value;
  Result := Self;
end;

function TStorageSettings.Servidor(Value: string): iStorageSettings;
begin
  if Value = '' then
    raise Exception.Create('Hostname/IP do servidor n�o poder ficar em branco');
  FServidor := Value;
  Result := Self;
end;

function TStorageSettings.Usuario(Value: string): iStorageSettings;
begin
  if Value = '' then
    raise Exception.Create('Usuario do servidor n�o poder ficar em branco');
  FUsuario := Value;
  Result := Self;
end;

function TStorageSettings.Usuario: string;
begin
  Result := FUsuario;
end;

end.
