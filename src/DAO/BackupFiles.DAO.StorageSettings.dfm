object dmStorageSettings: TdmStorageSettings
  Height = 480
  Width = 659
  object TabConfiguracaoArmazenamento: TFDQuery
    Connection = DM.database
    SQL.Strings = (
      'select * from configuracao_armazenamento')
    Left = 80
    Top = 24
  end
  object TabConfiguracaoArmazenamentoFiltrada: TFDQuery
    Connection = DM.database
    SQL.Strings = (
      
        'select * from configuracao_armazenamento c where c.codigo = :cod' +
        'igo')
    Left = 296
    Top = 24
    ParamData = <
      item
        Name = 'CODIGO'
        ParamType = ptInput
        Value = Null
      end>
  end
end
