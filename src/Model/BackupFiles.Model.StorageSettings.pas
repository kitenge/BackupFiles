unit BackupFiles.Model.StorageSettings;

interface

uses
  BackupFiles.Model.Interfaces;

type
  TStorageSettings = class(TInterfacedObject, iStorageSettings)
  private
    FDiretorio: string;
    FServidor: string;
    FUsuario: string;
    FSenha: string;
    FPorta: integer;
    FCodigoRotina: string;
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
    function CodigoRotina(Value: string): iStorageSettings; overload;
    function CodigoRotina: string; overload;
  public
    constructor Create;
    destructor Destroy; override;
    class function New: iStorageSettings;
  end;

implementation

uses
  System.SysUtils;

{ TStorageSettings }

function TStorageSettings.CodigoRotina: string;
begin
  Result := FCodigoRotina;
end;

function TStorageSettings.CodigoRotina(Value: string): iStorageSettings;
begin
  if Value = '' then
    raise Exception.Create('O C�digo da rotina precisa ser informado');
  FCodigoRotina := Value;
end;

constructor TStorageSettings.Create;
begin

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

class function TStorageSettings.New: iStorageSettings;
begin
  Result := Self.Create;
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

function TStorageSettings.Senha: string;
begin
  Result := FSenha;
end;

function TStorageSettings.Servidor: string;
begin
  Result := FServidor;
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
