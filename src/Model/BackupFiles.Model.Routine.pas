unit BackupFiles.Model.Routine;

interface

uses
  BackupFiles.Controller.Routine,
  BackupFiles.Model.Interfaces,
  System.Generics.Collections,
  BackupFiles.DAO.Routine,
  BackupFiles.Controller.StorageSettings,
  BackupFiles.Controller.BackupItem,
  AbZipper,
  AbArcTyp,
  AbUtils,
  AbZipKit,
  System.IOUtils,
  System.Classes,
  System.SysUtils,
  System.DateUtils;

type
  TRoutine = class(TInterfacedObject, iRoutine)
  strict private
    function GenerateUniqueCode: string;
    procedure AtualizarNoBanco;
    procedure InserirNoBanco;
    procedure BuscaItensRotina;
    procedure SalvarItens;
    procedure IniciarBackupLocal;
    procedure IniciarBackupFTP;
    function VerificarUltimosBackups: Boolean;
    function VerificarNomeArquivo: string;
    function LocalizaCodigoEmZip(const Value: string): Boolean;
    function EncontrarBackupsValidos: TStringList;
    function ExcluirArquivoMaisAntigo(ListaArquivos: TStringList): Boolean;
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
    function IniciarBackup: iRoutine;
  public
    constructor Create;
    destructor Destroy; override;
    class function New: iRoutine;
  end;

implementation

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

procedure TRoutine.AtualizarNoBanco;
begin
  DMRoutine.TabRotinaFiltrada.Close;
  DMRoutine.TabRotinaFiltrada.ParamByName('codigo').AsString := Self.FCodigo;
  DMRoutine.TabRotinaFiltrada.Open;

  DMRoutine.TabRotinaFiltrada.Edit;

  DMRoutine.TabRotinaFiltrada.FieldByName('Horario').AsDateTime :=
    FHorario.GetTime;
  DMRoutine.TabRotinaFiltrada.FieldByName('Total_backup').AsInteger :=
    FTotalBackups;
  DMRoutine.TabRotinaFiltrada.FieldByName('CodigoConfiguracao').AsString :=
    FSettings.Codigo;
  DMRoutine.TabRotinaFiltrada.FieldByName('Codigo').AsString := FCodigo;
  DMRoutine.TabRotinaFiltrada.FieldByName('Descricao').AsString := FDescricao;

  DMRoutine.TabRotinaFiltrada.Post;

  SalvarItens;
end;

procedure TRoutine.SalvarItens;
begin

  for var Item in FItemLista do
  begin
    Item.Salvar;
  end;
end;

procedure TRoutine.BuscaItensRotina;
begin
  DMRoutine.BuscaItensBackup.Close;
  DMRoutine.BuscaItensBackup.ParamByName('codigorotina').AsString := FCodigo;
  DMRoutine.BuscaItensBackup.Open;

  FItemLista.Clear;
  DMRoutine.BuscaItensBackup.First;
  while not DMRoutine.BuscaItensBackup.Eof do
  begin
    FItemLista.Add(TControllerBackupItem.New.Item(FCodigo)
      .BuscarDados(DMRoutine.BuscaItensBackup.FieldByName('Codigo').AsString));

    DMRoutine.BuscaItensBackup.Next;
  end;

end;

function TRoutine.BuscarDados(aCodigo: string): iRoutine;
var
  lCodigoConfig: string;

begin
  if (aCodigo.IsEmpty) or (Length(aCodigo) <> 25) then
    raise Exception.Create('C�digo de item inv�lido para busca');

  DMRoutine.TabRotinaFiltrada.Close;
  DMRoutine.TabRotinaFiltrada.ParamByName('codigo').AsString := aCodigo;
  DMRoutine.TabRotinaFiltrada.Open;

  FDescricao := DMRoutine.TabRotinaFiltrada.FieldByName('Descricao').AsString;
  FHorario := DMRoutine.TabRotinaFiltrada.FieldByName('Horario').AsDateTime;
  FTotalBackups := DMRoutine.TabRotinaFiltrada.FieldByName('Total_Backup')
    .AsInteger;
  lCodigoConfig := DMRoutine.TabRotinaFiltrada.FieldByName
    ('CodigoConfiguracao').AsString;
  FCodigo := DMRoutine.TabRotinaFiltrada.FieldByName('Codigo').AsString;
  FSettings := TControllerStorageSettings.New.BuscarConfiguracao(lCodigoConfig);
  BuscaItensRotina;

  Result := Self;
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

function TRoutine.IniciarBackup: iRoutine;
begin
  if not Assigned(FSettings) then
    raise Exception.Create
      ('N�o � poss�vel iniciar backup sem uma configura��o estabelecida');

  if FSettings.TipoConfiguracao = FTP then
    IniciarBackupFTP
  else
    IniciarBackupLocal;

  Result := Self;
end;

procedure TRoutine.IniciarBackupFTP;
begin

end;

procedure TRoutine.IniciarBackupLocal;
var
  lZipper: TAbZipper;
  ArquivoTemporario: string;
begin

  lZipper := TAbZipper.Create(nil);
  try
    VerificarUltimosBackups;

    lZipper.FileName := VerificarNomeArquivo;
    lZipper.StoreOptions := [soStripDrive, soStripPath];
    lZipper.OpenArchive(FSettings.Diretorio + lZipper.FileName);
    if FSettings.SenhaDeArquivo <> '' then
      lZipper.Password := FSettings.SenhaDeArquivo;

    ArquivoTemporario := TPath.GetTempPath;
    for var Item in FItemLista do
    begin
      ArquivoTemporario := ArquivoTemporario + ExtractFileName(Item.Caminho);
      TFile.Copy(Item.Caminho, ArquivoTemporario, true);
      lZipper.AddFiles((ArquivoTemporario), 0);
      lZipper.Save;
      TFile.Delete((ArquivoTemporario));
    end;

    lZipper.Save;
    lZipper.CloseArchive;
  finally
    lZipper.Free;
  end;
end;

procedure TRoutine.InserirNoBanco;
begin
  DMRoutine.TabRotina.Insert;

  DMRoutine.TabRotina.FieldByName('Horario').AsDateTime := FHorario.GetTime;
  DMRoutine.TabRotina.FieldByName('Total_Backup').AsInteger := FTotalBackups;
  DMRoutine.TabRotina.FieldByName('CodigoConfiguracao').AsString :=
    FSettings.Codigo;
  DMRoutine.TabRotina.FieldByName('Descricao').AsString := FDescricao;
  DMRoutine.TabRotina.FieldByName('Codigo').AsString := FCodigo;

  DMRoutine.TabRotina.Post;
  SalvarItens;
end;

function TRoutine.ListarItens: TList<iBackupItem>;
begin
  Result := FItemLista;
end;

function TRoutine.LocalizaCodigoEmZip(const Value: string): Boolean;
begin
  Result := Pos(FCodigo, Value) > 0;
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
  // Se Localizar vai editar o registro, se n�o vai inserir
  if not DMRoutine.TabRotina.Active then
    DMRoutine.TabRotina.Open;
  if DMRoutine.TabRotina.Locate('codigo', Self.FCodigo) then
  begin
    AtualizarNoBanco;
  end
  else
  begin
    InserirNoBanco;
  end;
end;

function TRoutine.TotalBackupsSalvos(Value: Integer): iRoutine;
begin
  if Value <= 0 then
    raise Exception.Create
      ('O N�mero de acumulo de backups deve ser superior a zero');
  FTotalBackups := Value;
  Result := Self;
end;

function TRoutine.TotalBackupsSalvos: Integer;
begin
  Result := FTotalBackups;
end;

function TRoutine.VerificarNomeArquivo: string;
var
  BaseNome, NovoNome: string;
  Contador: Integer;
  Existe: Boolean;
begin
  BaseNome := FDescricao + ' - ' + FCodigo + ' - ' +
    FormatDateTime('dd-mm-yy', Now);
  Contador := 0;

  repeat

    Existe := False;
    if Contador = 0 then
      NovoNome := BaseNome + '.zip'
    else
      NovoNome := Format('%s - (%d).zip', [BaseNome, Contador]);
    for var Item in TDirectory.GetFiles(FSettings.Diretorio, '*.zip') do
    begin
      if SameText(ExtractFileName(Item), NovoNome) then
      begin
        Existe := true;
        Break;
      end;
    end;
    if Existe then
      Inc(Contador)
    else
      Break;

  until False;

  Result := NovoNome;
end;

function TRoutine.EncontrarBackupsValidos: TStringList;
var
  Arquivo: string;
begin
  Result := TStringList.Create;
  for Arquivo in TDirectory.GetFiles(FSettings.Diretorio, '*.zip') do
  begin
    if LocalizaCodigoEmZip(Arquivo) then
    begin
      Result.Add(Arquivo);
    end;
  end;
end;

function TRoutine.ExcluirArquivoMaisAntigo(ListaArquivos: TStringList): Boolean;
var
  ArquivoMaisAntigo: string;
  IdadeArquivoMaisAntigo, IdadeArquivoAtual: Integer;
  i: Integer;
begin
  Result := False;
  if ListaArquivos.Count = 0 then
    Exit;

  ArquivoMaisAntigo := ListaArquivos[0];
  IdadeArquivoMaisAntigo := FileAge(ArquivoMaisAntigo);

  for i := 1 to ListaArquivos.Count - 1 do
  begin
    IdadeArquivoAtual := FileAge(ListaArquivos[i]);
    if IdadeArquivoAtual < IdadeArquivoMaisAntigo then
    begin
      ArquivoMaisAntigo := ListaArquivos[i];
      IdadeArquivoMaisAntigo := IdadeArquivoAtual;
    end;
  end;

  Result := DeleteFile(ArquivoMaisAntigo);
end;

function TRoutine.VerificarUltimosBackups: Boolean;
var
  ListaBackupsValidos: TStringList;
begin
  ListaBackupsValidos := EncontrarBackupsValidos;
  try
    Result := ListaBackupsValidos.Count = FTotalBackups;
    if Result then
    begin
      ExcluirArquivoMaisAntigo(ListaBackupsValidos);
    end;
  finally
    ListaBackupsValidos.Free;
  end;
end;

end.
