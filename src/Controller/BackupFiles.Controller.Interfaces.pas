unit BackupFiles.Controller.Interfaces;

interface

uses BackupFiles.Model.Interfaces;

type

  iControllerRoutine = interface
    ['{68320D65-C5DA-450E-B1E1-C81CA7F79891}']
    function Item: iRoutine;
  end;

  iControllerStorageSettings = interface
    ['{74BC59B1-D23D-4BF3-9DC2-D7E6D69DAD9F}']
    function Item(TipoConfig: TTipoConfigStorage): iStorageSettings;
    function BuscarConfiguracao(CodigoRotina: string): iStorageSettings;
  end;

  iControllerBackupItem = interface
    ['{E1151506-5D0C-4FD8-A0C9-09C99DF1E15C}']
    function Item(CodigoRotina: string): iBackupItem;
  end;

  iControllerSettings = interface
    ['{F3720301-7513-4019-8564-5660D9D7B19D}']
    function Item: iSettings;
  end;

implementation

end.
