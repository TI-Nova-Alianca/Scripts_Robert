$ErrorActionPreference = "Continue"  # Mostra o erro, mas continua.

$SQLUser = "consultas"
$Password = "consultas" | ConvertTo-SecureString -AsPlainText -Force
$Password.MakeReadOnly()
$cred = New-Object System.Data.SqlClient.SqlCredential($SQLUser,$Password)
$ConnSQLExpr = new-object System.Data.SqlClient.SQLConnection("Data Source=192.168.1.4;Initial Catalog=protheus");
$ConnSQLExpr.credential = $cred
$ConnSQLExpr.Open();
if ($ConnSQLExpr.State -ne 'Open')
{
    Write-Host "Erro de conexao ao banco de dados SQL"
}
else
{
    do
    {

        $query  =  "select placa from v_wms_entrada order by placa"
        $cmd = new-object System.Data.SqlClient.SqlCommand($query, $ConnSQLExpr);
        $SQLReader = $cmd.ExecuteReader()
        while ($SQLReader.Read())
        {
            write-host 'etiq na view 1: ' + $SQLReader.GetValue(0)
        }
        $SQLReader.Close()

        $query  =  "select placa from v_wms_entrada2 order by placa"
        $cmd = new-object System.Data.SqlClient.SqlCommand($query, $ConnSQLExpr);
        $SQLReader = $cmd.ExecuteReader()
        while ($SQLReader.Read())
        {
            write-host 'etiq na view 2: ' + $SQLReader.GetValue(0)
        }
        $SQLReader.Close()

        Write-host (get-date).ToString('T') 'aguardando nova execucao...'
        Start-Sleep (40)


    } while (1 -eq 1)
}

