unit BackupFiles.Model.Interfaces;

interface

uses
  System.Generics.Collections;

type
  iBackupItem = interface
    ['{030A2996-BBC7-439F-AD07-FFD4443093AA}']
    function Nome(Value: string): iBackupItem; overload;
    function Nome: string; overload;
    function Caminho(Value: string): iBackupItem; overload;
    function Caminho: string; overload;
    function Tamanho(Value: int64): iBackupItem; overload;
    function Tamanho: int64; overload;
    function UltimaModificacao(Value: TDatetime): iBackupItem; overload;
    function UltimaModificacao: TDatetime; overload;
  end;

  iStorageSettings = interface
    ['{3478CAE7-BBDB-402C-BEDC-DF8A0B1DDAD8}']
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
  end;

  iRoutine = interface
    ['{4D433699-8E61-448D-84BB-DE9E938277A2}']
    function Codigo: string;
    function Horario(Value: TDatetime): iRoutine; overload;
    function Horario: TDatetime; overload;
    function TotalBackupsSalvos(Value: integer): iRoutine; overload;
    function TotalBackupsSalvos: integer; overload;
    function AdicionarItem(Value: iBackupItem): iRoutine;
    function RemoverItem(Value: iBackupItem): iRoutine;
    function ListarItens: TList<iBackupItem>;
    function Configuracao(Value: iStorageSettings): iRoutine; overload;
    function Configuracao: iStorageSettings; overload;
  end;

implementation

end.
