unit BackupFiles.Model.Routine;

interface

uses
  BackupFiles.Controller.Routine,
  BackupFiles.Model.Interfaces,
  System.Generics.Collections,
  BackupFiles.DAO.Routine;

type
  TRoutine = class(TInterfacedObject, iRoutine)
  strict private
    function GenerateUniqueCode: string;
    function AtualizarNoBanco: string;
    function InserirNoBanco: string;
  private
    { Campos privados }
    FCodigo: string;
    FDescricao: string;
    FHorario: TDateTime;
    FTotalBackups: Integer;
    FItemLista: TList<iBackupItem>;
    FSettings: iStorageSettings;
    function Codigo: string;
    function Horario(Value: TDateTime): iRoutine; overload;
    function Horario: TDateTime; overload;
    function TotalBackupsSalvos(Value: Integer): iRoutine; overload;
    function TotalBackupsSalvos: Integer; overload;
    function AdicionarItem(Value: iBackupItem): iRoutine;
    function RemoverItem(Value: iBackupItem): iRoutine;
    function ListarItens: TList<iBackupItem>;
    function Configuracao(Value: iStorageSettings): iRoutine; overload;
    function Configuracao: iStorageSettings; overload;
    function Descricao: string; overload;
    function Descricao(Value: string): iRoutine; overload;
    function BuscarDados(aCodigo: string): iRoutine;
    function Salvar: iRoutine;
  public
    constructor Create;
    destructor Destroy; override;
    class function New: iRoutine;
  end;

implementation

uses
  System.SysUtils, System.DateUtils;

function TRoutine.GenerateUniqueCode: string;
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

{ TRoutine }

function TRoutine.AdicionarItem(Value: iBackupItem): iRoutine;
begin
  if FItemLista.IndexOf(Value) = -1 then
    FItemLista.Add(Value)
  else
    raise Exception.Create('O arquivo ' + Value.Nome +
      ' ja foi adicionado a lista');
  Result := Self;
end;

function TRoutine.AtualizarNoBanco: string;
begin
  DMRoutine.TabRotinaFiltrada.Close;
  DMRoutine.TabRotinaFiltrada.ParamByName('codigo').AsString := Self.FCodigo;
  DMRoutine.TabRotinaFiltrada.Open;

  DMRoutine.TabRotinaFiltrada.Edit;
  DMRoutine.TabRotinaFiltrada.FieldByName('Horario').AsDateTime := FHorario.GetTime;
  DMRoutine.TabRotinaFiltrada.FieldByName('Total_backup').AsString := FTotalBackups;
  DMRoutine.TabRotinaFiltrada.FieldByName('CodigoConfiguracao').AsString
    := FSettings;
  DMRoutine.TabRotinaFiltrada.FieldByName('CodigoRotina').AsString :=
    FCodigoRotina;
  DMRoutine.TabRotinaFiltrada.FieldByName('Tamanho').AsInteger
    := FTamanho;
  DMRoutine.TabRotinaFiltrada.FieldByName('Codigo').AsString := FCodigo;
  DMRoutine.TabRotinaFiltrada.FieldByName('id').AsInteger :=
    FCodigoInterno;
  DMRoutine.TabRotinaFiltrada.Post;
end;

function TRoutine.BuscarDados(aCodigo: string): iRoutine;
begin

end;

function TRoutine.Codigo: string;
begin
  Result := FCodigo;
end;

function TRoutine.Configuracao: iStorageSettings;
begin
  Result := FSettings;
end;

function TRoutine.Configuracao(Value: iStorageSettings): iRoutine;
begin
  Result := Self;
  FSettings := Value;
end;

constructor TRoutine.Create;
begin
  inherited;
  FCodigo := GenerateUniqueCode;
  FItemLista := TList<iBackupItem>.Create;
end;

function TRoutine.Descricao(Value: string): iRoutine;
begin
  if Value = '' then
    raise Exception.Create('A Descri��o n�o pode ficar em branco');
  FDescricao := Value;
  Result := Self;
end;

function TRoutine.Descricao: string;
begin
  Result := FDescricao;
end;

destructor TRoutine.Destroy;
begin
  FItemLista.Free;
  inherited;
end;

function TRoutine.Horario: TDateTime;
begin
  Result := FHorario;
end;

function TRoutine.InserirNoBanco: string;
begin

end;

function TRoutine.ListarItens: TList<iBackupItem>;
begin
  Result := FItemLista;
end;

function TRoutine.Horario(Value: TDateTime): iRoutine;
begin
  FHorario := Value;
  Result := Self;
end;

class function TRoutine.New: iRoutine;
begin
  Result := Self.Create;
end;

function TRoutine.RemoverItem(Value: iBackupItem): iRoutine;
var
  lIndex: Integer;
begin
  lIndex := FItemLista.IndexOf(Value);
  if lIndex <> -1 then
    FItemLista.Delete(lIndex);
  Result := Self;
end;

function TRoutine.Salvar: iRoutine;
begin

end;

function TRoutine.TotalBackupsSalvos(Value: Integer): iRoutine;
begin
  if Value <= 0 then
    raise Exception.Create
      ('O N�mero de acumulo de backups deve ser superior a zero');
  FTotalBackups := Value;
end;

function TRoutine.TotalBackupsSalvos: Integer;
begin
  Result := FTotalBackups;
end;

end.
