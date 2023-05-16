# Cooperativa Nova Alianca
# Abertura de chamados no GLPI via script
# Autor: Robert Koch
# Data: 12/05/2023
#
# Historico de alteracoes:
#

$nome_requerente   = 'ninguem'
$nome_observador   = ''
$nome_tecnico      = 'robert.koch'
$titulo_chamado    = 'APP nao encerra OS com movto em mes fechado'
$descricao_chamado = 'APP nao encerra OS com movto em mes jah fechado no estoque. Ex: OS 035468'
<#$descricao_chamado = '(07:59) Gabriel Boniatti: Bom dia'
$descricao_chamado += '(07:59) Gabriel Boniatti: Estou com problema no lançamento de fretes'
$descricao_chamado += '(08:00) Gabriel Boniatti: depois da contabilização aparece essa mensagem'
$descricao_chamado += '(08:00) Gabriel Boniatti: no conhecimentos saidas'
$descricao_chamado += '(08:01) Robert Koch: bom dia'
$descricao_chamado += '(08:03) Robert Koch: Ele está em final de arquivo, ou seja: procurou alguma coisa e não encontrou'
$descricao_chamado += '(08:03) Robert Koch: Provavelmente vai perder esse conhecimento'
$descricao_chamado += '(08:03) Gabriel Boniatti: eu cancelei e ele voltou'
$descricao_chamado += '(08:04) Gabriel Boniatti: tá ainda lá para importar'
$descricao_chamado += '(08:05) Robert Koch: Tem como lançar algum conhecimento manualmente?'
$descricao_chamado += '(08:05) Robert Koch: Sem ser por essa tela'
$descricao_chamado += '(08:05) Gabriel Boniatti: sim'
$descricao_chamado += '(08:05) Gabriel Boniatti: fiz agora'
$descricao_chamado += '(08:05) Gabriel Boniatti: deu certo, tudo normal'
$descricao_chamado += '(08:07) Robert Koch: Atééé pode ter sido um caso isolado... faz mais 1 teste pfv, tenta com outro arquivo'
$descricao_chamado += '(08:08) Gabriel Boniatti: tá'
$descricao_chamado += '(08:10) Gabriel Boniatti: mesma mensagem'
$descricao_chamado += '(08:16) Robert Koch: Vou tentar verificar'
$descricao_chamado += '(08:17) Gabriel Boniatti: ok'
#>
$prioridade        = 2  # 1=baixa;2=media


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

$ID_requerente
$ID_observador
$ID_tecnico

# Grava novo ticket de chamado
$uri = "$($GLPI_api)Ticket"
$manifest = @{}
$body = @{}

# https://forum.glpi-project.org/viewtopic.php?id=280849
# urgency: 1=baixa
$manifest = @{
        input = @{
            name = $titulo_chamado
            content = $descricao_chamado
            urgency = $prioridade
            _users_id_requester = $ID_requerente
            _users_id_observer = $ID_observador
            _users_id_assign = $ID_tecnico
            _disablenotif = "true"
        }
}
$body = $manifest | ConvertTo-Json -Compress    
$body
Invoke-RestMethod -Debug -Verbose -Method Post -Headers $headers -Body $body -Uri $uri



# Encerra sessao
$uri = "$($GLPI_api)killSession"
$body = @{}
Invoke-RestMethod -Method Get -Headers $headers -Body $body -Uri $uri
