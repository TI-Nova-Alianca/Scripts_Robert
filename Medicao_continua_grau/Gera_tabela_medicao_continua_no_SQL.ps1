# Scritp powershell a ser agendado no Windows da estacao do medidor de grau de cada filial
# Executa uma procedure do banco de dados que converte as tabelas diarias da Maseli para uma tabela continua de medicoes de grau
# Autor: Robert Koch
# Data:  24/01/2020
#
# Historico de alteracoes:
# 18/02/2020 - Robert - Importacao das tabelas do Access
# 19/02/2020 - Robert - Passa a filial como parametro para a funcao SP_GERA_TABELA_MEDICAO_CONTINUA do SQL
# 05/02/2021 - Robert - Definido timeout de 5 minutos para a camada de SP_EXPORTA_TABELAS_MEDICOES_CARGAS_PARA_SERVIDOR
# 15/01/2024 - Robert - Pequena melhoria no controle de loops.
#                     - Passa a safra como parametro para a procedure SP_GERA_TABELA_MEDICAO_CONTINUA
# 18/01/2024 - Robert - Incluisa chamada da procedure SP_SINCRONIZA_ZZA
#

$safra = '2024'
$filial = '01'

$continua = 1

# Faz conexao com o banco de dados SQL desta mesma estacao
if ($continua -eq 1)
{
    $SQLUser = "brix.local"
    $Password = "Brx2011a" | ConvertTo-SecureString -AsPlainText -Force
    $Password.MakeReadOnly()
    $cred = New-Object System.Data.SqlClient.SqlCredential($SQLUser,$Password)
    $ConnSQLExpr = new-object System.Data.SqlClient.SQLConnection("Data Source=localhost;Initial Catalog=bl01");
    #$ConnSQLExpr = new-object System.Data.SqlClient.SQLConnection("Data Source=localhost\sqlexpress;Initial Catalog=bl01");
    $ConnSQLExpr.credential = $cred
    $ConnSQLExpr.Open();
    if ($ConnSQLExpr.State -ne 'Open')
    {
        Write-Host "Erro de conexao ao banco de dados SQL Express"
        $continua = 0
    }
}


# Conecta ao banco do BL01
if ($continua -eq 1)
{

    $FilePath = "C:\BL01\BL01.mdb”
    $FilePath = $(resolve-path $FilePath).ProviderPath
    $connAccessBL01 = new-object System.Data.OleDb.OleDbConnection("Provider=Microsoft.ACE.OLEDB.12.0;Data Source=`"$filepath`";Persist Security Info=False;Mode=Read")
    $connAccessBL01.open() 
    if ($connAccessBL01.State -ne 'Open')
    {
        Write-Host "Erro de conexao ao banco Access do BL01"
  # Nao vou bloquear o resto da execucao, por que preciso sincronizar a tabela ZZA --->      $continua = 0
    }
}


# Gravacao em loop por tempo indeterminado.
$contadorDeLoops = 1
do
{

    # Sincroniza a tabela ZZA para poder operar 100% pelo SQL local (ainda em desenvolvimento)
    if ($continua -eq 1)
    {
        $query = 'exec SP_SINCRONIZA_ZZA ''' + $filial + ''', ''' + $safra + ''''
        Write-Host $query
        $cmd = new-object System.Data.SqlClient.SqlCommand($query, $ConnSQLExpr);
        $cmd.CommandTimeout = 60  # Nao deve demorar, mas preciso desta sincronizacao se quiser operar localmente.
        $exec = $cmd.ExecuteNonQuery()
        #write-host $exec
        if ($exec -lt 0)
        {
            write-host 'Retorno: '$exec
            $continua = 0
        }
    }


    # Chama procedure do SQL que converte tabelas diarias geradas pelo BL01 no SQL Express da estacao do
    # grau para uma unica tabela (tambem na estacao) contendo todas as medicoes.
    if ($continua -eq 1)
    {
        $query = 'exec SP_GERA_TABELA_MEDICAO_CONTINUA ''' + $filial + ''', ''' + $safra + ''''
        Write-Host $query
        $cmd = new-object System.Data.SqlClient.SqlCommand($query, $ConnSQLExpr);
        $exec = $cmd.ExecuteNonQuery()
        #write-host $exec
        if ($exec -eq 0)
        {
            write-host 'Retorno: '$exec
            $continua = 0
        }
    }
 
    # Chama procedure do SQL que exporta a tabela de medicoes continuas do SQL Express da estacao do grau para o servidor.
    if ($continua -eq 1)
    {
        $query = 'exec SP_EXPORTA_TABELA_MEDICAO_CONTINUA_PARA_SERVIDOR'
        Write-Host $query
        $cmd = new-object System.Data.SqlClient.SqlCommand($query, $ConnSQLExpr);
        $exec = $cmd.ExecuteNonQuery()
        if ($exec -lt 0)
        {
            write-host 'Retorno: '$exec
            $continua = 0
        }
    }



    # Importa tabelas de medicoes de cargas (originalmente alimentadas no Access pelo programa BL01)
    # para dentro do SQL Express da estacao.
    #
    # Como as tabelas do Access sao atualizadas somente no final da descarga, nao tem necessidade
    # de releituras tao frequentes. Vou ler a cada 5 iteracoes.
#    if ($contadorDeLoops % 5 -eq 0)
    if ($continua -eq 1 -and $contadorDeLoops % 5 -eq 0)
    {
        #
        # Verifica qual a ultima carga importada do Access para o SQL Express
        $query  =  " select max (ZZA_CARGA)"
        $query +=    " from SQL_BL01_TABLE"
        $query +=   " where ZZA_SAFRA  = '" + $safra + "'"
        $query +=     " and ZZA_FILIAL = '" + $filial + "'"
        write-host $query
        $cmd = new-object System.Data.SqlClient.SqlCommand($query, $ConnSQLExpr);
        $SQLReader = $cmd.ExecuteReader()
        if ($SQLReader.Read())
        {
            $ult_carga_lida_do_BL01 = $SQLReader.GetValue(0)
        }
        else
        {
            $ult_carga_lida_do_BL01 = ''
        }
        $SQLReader.Close()
        write-host 'Ultima carga importada do Access para o SQL Express:' $ult_carga_lida_do_BL01
        #
        # Monta lista das cargas do Access que precisam ser importadas para o SQL Express
        $cmd=$connAccessBL01.CreateCommand()
        $cmd.CommandText  = "select top 100 * "
        $cmd.CommandText +=  " from BL01_TABLE"
        $cmd.CommandText += " where ZZA_SAFRA  = '" + $safra  + "'"
        $cmd.CommandText +=   " and ZZA_FILIAL = '" + $filial + "'"
        $cmd.CommandText +=   " and ZZA_CARGA  > '" + $ult_carga_lida_do_BL01 + "'"
        $cmd.CommandText += " order by ZZA_CARGA"
        $AccessReader = $cmd.ExecuteReader()
        $AccesDataTable = New-Object System.Data.Datatable
        $AccesDataTable.Load($AccessReader)
        write-host 'Qt.cargas a importar do Access para o SQL Express:' ($AccesDataTable.Rows).Count
        #
        # Percorre as cargas, importando-as para o SQL Express
        foreach ($carga in $AccesDataTable.Rows)
        {
            write-host 'Importando carga' $carga.ZZA_CARGA 'do Access para o SQL Express'

            # Importa capa da carga
            $SQLInsert  = "insert into SQL_BL01_TABLE (ZZA_FILIAL, ZZA_SAFRA, ZZA_CARGA, ZZA_PRODUT, DATA_VALUE, DATA_NUMBER, LINE_SELECTED, PRODUCT_NAME, PRODUCER_NAME, RESULT, SAMPLES_NUMBER, MEASURE_SCALE, MEASURE_NAME)"
            $SQLInsert += " values ('" + $carga.ZZA_FILIAL + "',"
            $SQLInsert +=          "'" + $carga.ZZA_SAFRA  + "',"
            $SQLInsert +=          "'" + $carga.ZZA_CARGA  + "',"
            $SQLInsert +=          "'" + $carga.ZZA_PRODUT + "',"
            $SQLInsert +=                $carga.DATA_VALUE.ToString('########.########').Replace(',', '.') + ','
            $SQLInsert +=          "'" + $carga.DATA_NUMBER + "',"
            $SQLInsert +=                $carga.LINE_SELECTED.ToString('##') + ','
            $SQLInsert +=          "'" + $carga.PRODUCT_NAME + "',"
            $SQLInsert +=          "'" + $carga.PRODUCER_NAME + "',"
            $SQLInsert +=                $carga.RESULT.ToString('###.##').Replace(',', '.') + ','
            $SQLInsert +=                $carga.SAMPLES_NUMBER.ToString('####') + ','
            $SQLInsert +=                $carga.MEASURE_SCALE.ToString('##') + ','
            $SQLInsert +=          "'" + $carga.MEASURE_NAME + "')"
            #write-host $SQLInsert
            $SQLCmd = New-Object System.Data.SqlClient.SqlCommand($SQLInsert, $ConnSQLExpr)
            $SQLCmd.executenonquery() > $null

            # Percorre os campos de leituras da cargas atual, importando-os para o SQL Express.
            # No Access as medicoes sao guardadas uma em cada campo (maximo 250) de um unico registro.
            $cmd=$connAccessBL01.CreateCommand()
            $cmd.CommandText  = "select * "
            $cmd.CommandText +=  " from BL01_SAMPLES"
            $cmd.CommandText += " where ZZA_SAFRA  = '" + $carga.ZZA_SAFRA  + "'"
            $cmd.CommandText +=   " and ZZA_FILIAL = '" + $carga.ZZA_FILIAL + "'"
            $cmd.CommandText +=   " and ZZA_CARGA  = '" + $carga.ZZA_CARGA  + "'"
            $AccessReader = $cmd.ExecuteReader()
            $AccesDataTable = New-Object System.Data.Datatable
            $AccesDataTable.Load($AccessReader)
            $contadorDeCampos = 1
            while ($contadorDeCampos -le $carga.SAMPLES_NUMBER)
            {
                $campoSample = 'SAMPLE_N' + $contadorDeCampos.ToString('000')
                $medida =  $AccesDataTable.Rows[0].$campoSample
                #write-host $campoSample '=' $medida
                if (($medida.ToString()).length -eq 0)
                {
                    write-host 'cheguei ao final das medicoes desta carga'
                    break
                }

                $SQLInsert  = "insert into SQL_BL01_SAMPLES (ZZA_FILIAL, ZZA_SAFRA, ZZA_CARGA, ZZA_PRODUT, SAMPLE, RESULT)"
                $SQLInsert += " values ('" + $carga.ZZA_FILIAL + "',"
                $SQLInsert +=          "'" + $carga.ZZA_SAFRA  + "',"
                $SQLInsert +=          "'" + $carga.ZZA_CARGA  + "',"
                $SQLInsert +=          "'" + $carga.ZZA_PRODUT + "',"
                $SQLInsert +=                $contadorDeCampos.ToString('###') + ","
                $SQLInsert +=                $medida.ToString('###.##').Replace(',', '.') + ")"
                #write-host $SQLInsert
                $SQLCmd = New-Object System.Data.SqlClient.SqlCommand($SQLInsert, $ConnSQLExpr)
                $SQLCmd.executenonquery() > $null

                $contadorDeCampos ++
            }

        }

        # Chama procedure do SQL que exporta as medicoes de cargas do SQL Express da estacao para o SQL do servidor.
        $query = 'exec SP_EXPORTA_TABELAS_MEDICOES_CARGAS_PARA_SERVIDOR'
        Write-Host $query
        $cmd = new-object System.Data.SqlClient.SqlCommand($query, $ConnSQLExpr);
        $cmd.CommandTimeout = 300  # Pode demorar bastante, por exemplo se ficou tempo sem executar e tem muitas cargas pendentes
        $exec = $cmd.ExecuteNonQuery()
    }

    write-host 'Iteracao ' $contadorDeLoops
    $contadorDeLoops ++
    if ($continua -eq 1)
    {
        Write-host (get-date).ToString('T') 'aguardando nova execucao...'
        Start-Sleep (10)
    }
    else
    {
        Write-Host "Finalizando devido a algum erro no processamento"
    }

} while ($continua -eq 1)
