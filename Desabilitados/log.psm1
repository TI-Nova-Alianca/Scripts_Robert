# Implementa geracao de arquivo de log.

$arq = ""

Function Grava
{
    Param([string]$msg)

    if ($arq -eq "")
    {
        Write-Output("[Arquivo para log nao definido] " + $msg)
    }
    else
    {
        $DataHora = Get-Date -Format "yyyyMMdd HH:mm:ss"
    #    $stack = Get-PSCallStack
    #    $msg = "[" + $DataHora + "] [" + [Environment]::UserName + "] [" + $stack[1].Location + "] " + $msg
        $msg = "[" + $DataHora + "] " + $msg
        $msg >> $arq
        Write-Host $msg
    }
}

Export-ModuleMember -Function Grava -Variable arq
