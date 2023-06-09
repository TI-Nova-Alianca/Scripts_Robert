# Cooperativa Nova Alianca
# Script para impressao de tickets de safra em estacao fora da rede da matriz
# Autor: Robert Koch
# Data:  17/12/2020
# Funcionamento: Acessa ao Protheus via web service, recebe texto do ticket e envia para porta de impressao.
#
# Historico de alteracoes:
#

# Importa arquivos de funcoes via 'dot source' para que as funcoes possam ser usadas aqui.
. C:\Ticket_Safra\Function_Grava-Log.ps1


# Parametros que devem ser ajustados em cada estacao
$CodUsuario = 000210 # Um codigo de usuario valido existente no Protheus. Sugestao ter um para cada estacao.
$Safra = '2021'
$Filial = '09'
$Balanca = 'SP'
#$PortaImpressora = 'c:\temp\etiq.txt'
$PortaImpressora = '\\192.168.2.114\TKDaiana'


Grava-Log('Iniciando execucao')

# Monta token para autenticacao no Protheus
$TokenUsr = $CodUsuario
$TokenUsr = $TokenUsr * $TokenUsr
$TokenUsr += (Get-Date).year - 1000
$TokenUsr += (Get-Date).month * 1000
$TokenUsr = $TokenUsr.ToString()

$uri = "http://namob.novaalianca.coop.br:7982/ws/WS_namob.apw?WSDL" # base QUENTE_Externo (NaMob associados)
$proxy = New-WebServiceProxy -Uri $uri
$proxy.Timeout = 10000  # Tempo em milissegundos.

# Define XML para solicitacao ao web service
$XML = '<WSAlianca>'
$XML +=    '<User>robert.koch</User>'
$XML +=    '<IDAplicacao>ghdf743j689fj4889</IDAplicacao>'  # externo (WS_NaMob)
$XML +=    '<Empresa>01</Empresa><Filial>' + $Filial + '</Filial>'
$XML +=    '<Acao>RetTicketCargaSafra</Acao>'
$XML +=    '<Safra>' + $Safra + '</Safra>'
$XML +=    '<Balanca>' + $Balanca + '</Balanca>'
$XML +=    '<CargaIni>0000</CargaIni>'
$XML +=    '<CargaFim>zzzz</CargaFim>'
$XML +=    '<DataIni>20010101</DataIni>'
$XML +=    '<DataFim>20491231</DataFim>'
$XML += '</WSAlianca>'

# Execucao em loop por tempo indeterminado.
do
{
    # O web service retorna sempre um XML de 2 posicoes, sendo que a primeira
    # pode conter 'OK' ou 'ERRO' e a segunda contem a mensagem de retorno (no caso, o texto do ticket)
    $RetWS = ''
    $RetWS = $proxy.INTEGRAWS($XML)
    if ($RetWS.RESULTADO -ne 'OK')
    {
        Grava-Log('Erro retorno WS: ' + $RetWS.MENSAGENS)
    }
    else
    {
        Grava-Log('Retorno ok: ' + $RetWS.MENSAGENS)
        
        $Ticket = $RetWS.MENSAGENS
        $Ticket = $Ticket.Replace('chr(27)', $([char]27))
        $Ticket = $Ticket.Replace('chr(29)', $([char]27))
        $Ticket = $Ticket.Replace('chr(60)', $([char]60))
        $Ticket = $Ticket.Replace('chr(11)', $([char]11))

        write-output $Ticket

        # Envia o texto do ticket para a porta da impressora
        #$RetWS.MENSAGENS > $PortaImpressora
        $Ticket >> $PortaImpressora
    }
    
    
    #durante testes
    exit
    
    
    # Dorme um pouquinho, por que ninguem eh de ferro...
    Start-Sleep (10)
    
} while (1 -eq 1)

