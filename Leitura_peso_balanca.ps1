# Cooperativa Nova Alianca
# Script para ser executado em uma estacao da portaria da matriz, que tenha porta serial comunicando com a balanca.
# Leiura de peso corrente na balanca e grvacao continua no banco de dados.
# Data: 03/02/2020
# Autor: Robert Koch
#
# Historico de alteracoes:
# 11/01/2023 - RObert - Parametrizado timeout para a porta serial (quando estava sem comunicacao, ficava tratado)
#

# Define parametros de conexao com a porta serial.
$port = New-Object System.IO.ports.SerialPort COM2,4800,None,8,two
# Timeout em milissegundos
$port.ReadTimeout = 5000

# Faz conexao com o banco de dados para gravacao do peso lido.
$SQLUser = "brix"
$Password = "Brx2011a" | ConvertTo-SecureString -AsPlainText -Force
$Password.MakeReadOnly()
$cred = New-Object System.Data.SqlClient.SqlCredential($SQLUser,$Password)
$connection = new-object System.Data.SqlClient.SQLConnection("Data Source=serverSQL;Initial Catalog=protheus");
$connection.credential = $cred
$connection.Open();
if ($connection.State -ne 'Open')
{
    Write-Output "Erro de conexao ao banco de dados"
}
else
{
    # Gravacao em loop por tempo indeterminado.
    do
    {
        $port.Open()
        if (-not $port.IsOpen)
        {
            Write-Output 'Erro ao abrir porta serial'
        }
        else
        {
            $DataHora = Get-Date -Format "yyyyMMdd HH:mm:ss"
            Write-Output ('[' + $DataHora + ']Leitura porta serial:')
            $line=$port.ReadLine()
            Write-Output $line
            if ($line.Contains('EL_'))  # Peso estabilizado
            {
                $peso = [int]$line.Substring(1, 6)
            }
            else
            {
                Write-Output 'Peso nao estabilizado na balanca'
                $peso = 0
            }
        }
        $port.Close()
        Write-Output $peso

        # Nao grava quando peso zerado
        if ($peso -ne 0)
        {
            Write-Output 'Gravando peso balanca: '$peso
            $query = 'INSERT INTO VA_PESOS_BALANCA_MATRIZ (PESO) VALUES (' + $peso + ')'
     #       Write-Output $query
            $cmd = new-object System.Data.SqlClient.SqlCommand($query, $connection);
            $exec = $cmd.ExecuteNonQuery()
        }
        
        Start-Sleep (10)
    } while (1 -eq 1)
}
