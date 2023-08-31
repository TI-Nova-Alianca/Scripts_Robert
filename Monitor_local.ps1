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
$IPs += 'naweb.novaalianca.coop.br'

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

    # Preciso ter aceso a pasta do arquivo de log
    if ($posso_verificar_protheus -eq 1 -and -not (Test-Path '\\192.168.1.3\c$\Temp'))
    {
        write-host ('Sem acesso a pasta TEMP do ServerProtheus') -ForegroundColor Red
        $posso_verificar_protheus = 0
    }

    # O arquivo de log de monitoramento dos servicos precisa estar atulizado
    $ArqLogMonProheus = '\\192.168.1.3\c$\Temp\Monitora_Protheus.log'
    if ($posso_verificar_protheus -eq 1)
    {
        $IdadeLogProtheus = (new-timespan (Get-ChildItem $ArqLogMonProheus).LastWriteTime).Minutes
        if ($IdadeLogProtheus -ge 3)
        {
            Write-Host ('Ultima gravacao do log de monitoramento do Protheus feita ha ' + $IdadeLogProtheus + ' minutos. Suspeita de problema no agendamento do monitor') -ForegroundColor red
            $posso_verificar_protheus = 0
        }
    }
    
    # Verificar se as portas respondem
    if ($posso_verificar_protheus -eq 1)
    {
      #  $LogProtheus = Get-Content ($ArqLogMonProheus) -last 50 
        $PortasProtheus = @('1290') # master
        $PortasProtheus += '1291' # slave1
        $PortasProtheus += '1292' # slave2
        $PortasProtheus += '1293' # slave3
        $PortasProtheus += '1294' # slave4
        $PortasProtheus += '1295' # slave5
        $PortasProtheus += '1296' # slave6
        $PortasProtheus += '1298' # Externo
        $PortasProtheus += '1299' # Batches
        $PortasProtheus += '1247' # Lojas
        $PortasProtheus += '1280' # Base teste
        $PortasProtheus += '1248' # broker
        $PortasProtheus += '1268' # Schedule
        $PortasProtheus += '1274' # Importador XML
      #  $PortasProtheus += '1276' # WS TotvsPDV
      #  $PortasProtheus += '1277' # WS TotvsPDV base teste
        $PortasProtheus += '1283' # Job CancNFe e cupom
        $PortasProtheus += '1251' # WS Alianca 1
        $PortasProtheus += '1252' # WS Alianca 2
        $PortasProtheus += '1253' # Telnet
        $PortasProtheus += '1260' # Monitor geral
        $PortasProtheus += '1264' # TAF
      #  $PortasProtheus += '1275' # WS Alianca base teste
      #  $PortasProtheus += '1281' # TesteFiscal
      #  $PortasProtheus += '1267' # TAF base teste
      #  $PortasProtheus += '1266' # Retaguarda TotvsPDV base teste
      #  $PortasProtheus += '1272' # Batches base teste
      #  $PortasProtheus += '1277' # WS MntNG base teste
        $PortasProtheus += '1278' # REST Meu Protheus
        $PortasProtheus += '1279' # REST MntNG
      #  $PortasProtheus += '1297' # Retaguarda TotvsPDV

        foreach ($PortaProtheus in $PortasProtheus)
        {
            Write-Host ('Testando conexao com porta ' + $PortaProtheus)
            $teste = Test-NetConnection -ComputerName ServerProtheus -Port $PortaProtheus
            if (-not $teste.TcpTestSucceeded)
            {
                Write-Host ('Protheus porta ' + $PortaProtheus + ' nao responde') -ForegroundColor red
            }
        }
    }
}

Write-Host 'Pressione uma tecla para finalizar'
Read-Host
