# Declaracoes de funcoes genericas, a serem importadas como um modulo no PowerShell.
# Autor: Robert Koch
# Data: 30/06/2016

# -----------------------------------------------------------------
# Grava log em arquivo.
# Historico de alteracoes:
# 04/04/2016 - Robert - Cria pasta para logs, caso nao exista.
Function Grava-Log
{
    Param([string]$msg)
    $DataHora = Get-Date -Format yyyyMMdd-HHmmss
    $stack = Get-PSCallStack
    $msg = "[" + $DataHora + "] [" + [Environment]::UserName + "] [" + $stack[1].Location + "] " + $msg
    if ((Test-Path variable:PastaLogs) -and (Test-Path variable:ArqLog))
    {
        if (!(Test-Path -Path $PastaLogs))
        {
        	New-Item -Force -ItemType Directory -Path $PastaLogs
        }
        $msg >> $PastaLogs$ArqLog
    }
    else
    {
        write-output $msg
    }
}



# -----------------------------------------------------------------
# Executa comando em SQL.
# Obtido de: http://stackoverflow.com/questions/8423541/how-do-you-run-a-sql-server-query-from-powershell
# Data: 29/06/2016
#
# Ex.:   invoke-sql -dataSource "192.168.1.4"\MSSQLSERVER -database master -sqlCommand "select top 1 * from sysobjects"
function Invoke-SQL {
    param(
        [string] $dataSource = ".\SQLEXPRESS",
        [string] $database = "MasterData",
        [string] $sqlCommand = $(throw "Please specify a query.")
      )

    $connectionString = "Data Source=$dataSource; " +
            "Integrated Security=SSPI; " +
            "Initial Catalog=$database"

    $connection = new-object system.data.SqlClient.SQLConnection($connectionString)
    $command = new-object system.data.sqlclient.sqlcommand($sqlCommand,$connection)
    $connection.Open()

    $adapter = New-Object System.Data.sqlclient.sqlDataAdapter $command
    $dataset = New-Object System.Data.DataSet
    $adapter.Fill($dataSet) | Out-Null

    $connection.Close()
    $dataSet.Tables

}
