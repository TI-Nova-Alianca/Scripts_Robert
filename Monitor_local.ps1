# Script para rodar local no PC do Robert, para monitorar alguns servicos.
# Autor: Robert Koch
# Data: 08/07/2023
#

$posso_verificar_protheus = 0

# Lista de IPs para teste de ping
$IPs = @('192.168.1.12')
$IPs += '192.168.1.4'
$IPs += '192.168.1.3'
#$IPs += '192.168.1.5'
$IPs += '192.168.1.6'
$IPs += '192.168.1.10'
$IPs += '192.168.1.11'
$IPs += '192.168.1.12'
$IPs += '192.168.1.13'
$IPs += 'glpi.novaalianca.coop.br'
$IPs += 'vendas.novaalianca.coop.br'
$IPs += 'glpi.novaalianca.coop.br'

foreach ($IP in $IPs)
{
    if (-not (Test-Connection $IP -Quiet -Count 1))
    {
        write-host ('ERR Ping ' + $IP) -ForegroundColor Red
    }
    else
    {
        write-host ('Ping ' + $IP) -ForegroundColor Green
        if ($IP -eq '192.168.1.3') { $posso_verificar_protheus = 1 }
    }
}

<#

# Verificacoes SQL
if ($continua -eq 1)
{
    $IP = '192.168.1.4'
    if (-not (Test-Connection $IP -Quiet -Count 1))
    {
        write-host ('Ping ' + $IP + ' com erro. Verifique VPN') -ForegroundColor Red
    }
    else
    {
        write-host ('Ping ' + $IP + ' OK') -ForegroundColor Green
    }
}
#>

if ($posso_verificar_protheus -eq 1)
{
    Write-Host 'Verificando Protheus'
<#
    $PortasProtheus = @('1290')
    $PortasProtheus += '1291'
    $PortasProtheus += '1191'
    foreach ($PortaProtheus in $PortasProtheus)
    {
        $teste = Test-NetConnection -ComputerName ServerProtheus -Port $PortaProtheus
        if (-not $teste.TcpTestSucceeded)
        {
            Write-Host ('Protheus porta ' + $PortaProtheus + ' nao responde') -ForegroundColor red
        }
    }
#>
    # Preciso ter aceso a pasta do arquivo de log
    if ($posso_verificar_protheus -eq 1 -and -not (Test-Path '\\192.168.1.3\c$\Temp'))
    {
        write-host ('Sem acesso a pasta TEMP do ServerProtheus') -ForegroundColor Red
        $posso_verificar_protheus = 0
    }

    # O arquivo de log precisa estar atulizado
    $ArqLogMonProheus = '\\192.168.1.3\c$\Temp\Monitora_Protheus.log'
    if ($posso_verificar_protheus -eq 1)
    {
        $IdadeLogProtheus = (new-timespan (Get-ChildItem $ArqLogMonProheus).LastWriteTime).Minutes
        if ($IdadeLogProtheus -ge 2)
        {
            Write-Host ('Ultima gravacao do log de monitoramento do Protheus feita ha ' + $IdadeLogProtheus + ' minutos. Suspeita de servicos parados') -ForegroundColor red
            $posso_verificar_protheus = 0
        }
    }
    
    # Verificar conteudo do arquivo de log
    if ($posso_verificar_protheus -eq 1)
    {
        $LogProtheus = Get-Content ($ArqLogMonProheus) -last 50 
    }
}

