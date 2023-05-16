# ---------------------------------------------------------------------------
# Importa arquivos de funcoes via 'dot source' para que as funcoes possam ser usadas aqui.
. '\\SRVADM\c$\util\Scripts\Function_VA_Log.ps1'
. '\\SRVADM\c$\util\Scripts\Function_VA_Aviso.ps1'

# Processamento em loop por tempo indeterminado.
$contadorDeLoops = 1
do
{
    $StartTime = $(get-date)
    c:\temp\Protheus12\smartclient.exe -m -c=testeFiscal -e=testeFiscal2 -p=u_robert
    $elapsedTime = $(get-date) - $StartTime
    $totalTime = "{0:HH:mm:ss}" -f ([datetime]$elapsedTime.Ticks)
    write-host $totalTime
    VA_Log -TipoLog 'info' -MsgLog ('Iteracao numero ' + $contadorDeLoops + ' finalizada. Aguardando nova execucao...')

    Start-Sleep (30)

#    $StartTime = $(get-date)
#    c:\temp\Protheus12\smartclient.exe -m -c=slave4 -e=ROBERT -p=u_robert
#    $elapsedTime = $(get-date) - $StartTime
#    $totalTime = "{0:HH:mm:ss}" -f ([datetime]$elapsedTime.Ticks)
#    write-host $totalTime
#    VA_Log -TipoLog 'info' -MsgLog ('Iteracao numero ' + $contadorDeLoops + ' finalizada. Aguardando nova execucao...')
#
#    Start-Sleep (30)

    $contadorDeLoops ++
} while (1 -eq 1)
