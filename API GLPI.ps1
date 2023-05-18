# Cooperativa Nova Alianca
# Abertura de chamados no GLPI via script
# Autor: Robert Koch
# Data: 12/05/2023
#
# Historico de alteracoes:
#

$tipo_chamado      = 1  # 1=incidente;2=requisicao
$categoria         = 1  # 1=ADS;2=Infra
$nome_requerente   = '?'
$nome_observador   = ''
$nome_tecnico      = 'robert.koch'
$titulo_chamado    = 'Criar tela de consulta (HTML) de OS de manutencao'
$descricao_chamado = 'Sugestao apenas criar link na coluna do numero da OS na tela wpnsolmanutencao'
#$descricao_chamado += 'Executar a procedure SP_VISUALIZA_OS passando a filial e o número da OS, de forma semelhante à leitura de acessos de usuário que temos na tela wpnacessosdousuario'
$prioridade        = 2  # 1=baixa;2=media
$result_abertura_chamado = ''

# Inicio de conexao ao GLPI
$GLPI_api = "https://glpi.novaalianca.coop.br/apirest.php/"

# Abre uma sessao e obtem o token de acesso, que vai ser necessario para as proximas operacoes.
$sessiontoken = ''
$uri = "$($GLPI_api)initSession"
$contenttype = 'application/json'
$apptoken = '2hAI45ZkU4qFhGiII8J6lCYJM1vWKA7Ui8B3mPSF'
$authorization = 'user_token sjydhRqR4xntIyFhmlkZje0QIsv7Ef4y0qzlAp2v'
$headers = @{    
    'App-Token' = $apptoken
    'Authorization' = $authorization
    'Content-Type' = $contenttype
}
$body = @{}
$sessiontoken=(Invoke-RestMethod -Method Get -Headers $headers -Body $body -Uri $uri).session_token
if ($sessiontoken.Length -eq 0)
{
    Write-Error "Nao foi possivel obter token de sessao"
    return
}

# Agora que tenho o token de sessao, insiro-o no cabecalho, por que vou precisar passar ele em todas as operacoes subsequentes.
$headers = @{    
    'App-Token' = $apptoken
    'Authorization' = $authorization
    'Session-Token' = $sessiontoken
    'Content-Type' = $contenttype
}

<#
# Teste: Pesquisa equipamentos
$uri = "$($GLPI_api)search/networkequipment?criteria\[0\]\[link\]\=AND\&criteria\[0\]\[itemtype\]\=networkequipment\&criteria\[0\]\[field\]\=4\&criteria\[0\]\[searchtype\]\=contains\&criteria\[0\]\[value\]\=Commutateur\"
Invoke-RestMethod -Method Get -Headers $headers -Uri $uri
#>

<# pesquisa algumas coisas...
$uri = "$($GLPI_api)search/ITILCategory"
$categorias=Invoke-RestMethod -Method Get -Headers $headers -Uri $uri
$categorias

$uri = "$($GLPI_api)search/location"
$localizacoes=Invoke-RestMethod -Method Get -Headers $headers -Uri $uri
$categorias

#Visualizar os campos disponíveis para itemtype Ticket (royalties para https://gist.github.com/ricardomaia/1b1e6c768d2d666fce1fe299113b05fb)
$uri = "$($GLPI_api)listSearchOptions/Ticket"
$campos_disponiveis_para_ticket=Invoke-RestMethod -Method Get -Headers $headers -Uri $uri
$campos_disponiveis_para_ticket

$uri = "$($GLPI_api)search/Ticket.type"
$tipos_ticket=Invoke-RestMethod -Method Get -Headers $headers -Uri $uri
$tipos_ticket

#>
# Encontra o ID do requerente, observador e tecnico
$ID_requerente = ''
if ($nome_requerente.Length -gt 0)
{
    $uri = "$($GLPI_api)search/User?forcedisplay[0]=2&forcedisplay[1]=1&criteria[1][field]=1&criteria[1][searchtype]=contains&criteria[1][value]="+$nome_requerente
    $usuarios=Invoke-RestMethod -Method Get -Headers $headers -Uri $uri
    if ($usuarios.totalcount -ne 1)
    {
        Write-Error "Nao foi possivel obter ID do requerente"
        return
    }
    $ID_requerente = $usuarios.data.2
}

$ID_observador = ''
if ($nome_observador.Length -gt 0)
{
    $uri = "$($GLPI_api)search/User?forcedisplay[0]=2&forcedisplay[1]=1&criteria[1][field]=1&criteria[1][searchtype]=contains&criteria[1][value]="+$nome_observador
    $usuarios=Invoke-RestMethod -Method Get -Headers $headers -Uri $uri
    if ($usuarios.totalcount -ne 1)
    {
        Write-Error "Nao foi possivel obter ID do observador"
        return
    }
    $ID_observador = $usuarios.data.2
}

$ID_tecnico = ''
if ($nome_tecnico.Length -gt 0)
{
    $uri = "$($GLPI_api)search/User?forcedisplay[0]=2&forcedisplay[1]=1&criteria[1][field]=1&criteria[1][searchtype]=contains&criteria[1][value]="+$nome_tecnico
    $usuarios=Invoke-RestMethod -Method Get -Headers $headers -Uri $uri
    if ($usuarios.totalcount -ne 1)
    {
        Write-Error "Nao foi possivel obter ID do tecnico"
        return
    }
    $ID_tecnico = $usuarios.data.2
}

# Grava novo ticket de chamado
$uri = "$($GLPI_api)Ticket"
$manifest = @{}
$body = @{}

# https://forum.glpi-project.org/viewtopic.php?id=280849
$manifest = @{
        input = @{
            type = $tipo_chamado
            itilcategories_id = $categoria
            name = $titulo_chamado
            content = $descricao_chamado
            urgency = $prioridade
            locations_id = 1 # location_id = 1  # 1=entidade raiz (as subdivisoes ainda nao consegui identificar)
            _users_id_requester = $ID_requerente
            _users_id_observer = $ID_observador
            _users_id_assign = $ID_tecnico
            _disablenotif = "true"
        }
}
$body = $manifest | ConvertTo-Json -Compress    
#$body
$result_abertura_chamado = Invoke-RestMethod -Debug -Verbose -Method Post -Headers $headers -Body $body -Uri $uri

$result_abertura_chamado

# Encerra sessao
$uri = "$($GLPI_api)killSession"
$body = @{}
Invoke-RestMethod -Method Get -Headers $headers -Body $body -Uri $uri


#if ($result_abertura_chamado.id.Length -gt 0)
#{
#    write-host 'https://glpi.novaalianca.coop.br/front/ticket.form.php?id='+$result_abertura_chamado.id
#}

