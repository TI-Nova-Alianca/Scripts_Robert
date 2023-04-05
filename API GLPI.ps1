$GLPI_api = "https://glpi.novaalianca.coop.br/apirest.php/"
<#
# Initialisation de la connexion à glpi
$headersInit = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headersInit.Add("Content-Type", 'application/json')
$headersInit.Add("Authorization", 'user_token dBMXyeY6Kgretf5f2Rq6ADbLj8FTyaEr1xW1aPDE')
$headersInit.Add("App-Token", 'c82OshtljKSd7QA2qb8WT9DCb32F9eangZEktn9u') # à créer dans glpi
$SessionToken = Invoke-RestMethod "$($GLPI_api)initSession" -Method Get -Headers $headersInit
#>
<#
# header utilisé pour les requète après initialisation
$HeadersRequest = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$HeadersRequest.Add("Content-Type", 'application/json')
$HeadersRequest.Add("Session-Token", "$($SessionToken.session_token)")
$HeadersRequest.Add("App-Token", 'c82OshtljKSd7QA2qb8WT9DCb32F9eangZEktn9u')

# première méthode
Invoke-RestMethod "$($GLPI_api)search/networkequipment?criteria\[0\]\[link\]\=AND\&criteria\[0\]\[itemtype\]\=networkequipment\&criteria\[0\]\[field\]\=4\&criteria\[0\]\[searchtype\]\=contains\&criteria\[0\]\[value\]\=Commutateur\" -Method Get -Headers $HeadersRequest
#>


# Abre uma sessao e obtem o tokem de acesso, que vai ser necessario para as proximas operacoes.
$uri = "$($GLPI_api)initSession"
$contenttype = 'application/json'
$apptoken = 'c82OshtljKSd7QA2qb8WT9DCb32F9eangZEktn9u'
$authorization = 'user_token dBMXyeY6Kgretf5f2Rq6ADbLj8FTyaEr1xW1aPDE'
$headers = @{    
    'App-Token' = $apptoken
    'Authorization' = $authorization
    'Content-Type' = $contenttype
}
$sessiontoken=(Invoke-RestMethod -Method Get -Headers $headers -Uri $uri).session_token
$sessiontoken

# Agora que tenho o token, uso-o no cabecalho.
$headers = @{    
    'App-Token' = $apptoken
    'Session-Token' = $sessiontoken
    'Content-Type' = $contenttype
}

<#
# Teste: Pesquisa equipamentos
$uri = "$($GLPI_api)search/networkequipment?criteria\[0\]\[link\]\=AND\&criteria\[0\]\[itemtype\]\=networkequipment\&criteria\[0\]\[field\]\=4\&criteria\[0\]\[searchtype\]\=contains\&criteria\[0\]\[value\]\=Commutateur\"
Invoke-RestMethod -Method Get -Headers $headers -Uri $uri
#>


<#
# Teste incluir documento
$uri = "$($GLPI_api)Document"
$contenttype = 'multipart/form-data'
$manifest = @{}
$body = @{}
$manifest = @{
#    uploadManifest =@{
        input = @{
            name = "Uploaded document"
            _filename = '[file.txt]'    
        }
#    }
    'filename[0]' = "@C:\temp\teste.txt"
}
$body = $manifest | ConvertTo-Json -Compress    
$body
Invoke-RestMethod -Debug -Verbose -Method Post -Headers $headers -Body $body -Uri $uri
#>


<#
# Teste incluir computador
$uri = "$($GLPI_api)Computer"
$contenttype = 'application/json'
$manifest = @{}
$body = @{}
$manifest = @{
        input = @{
            name = "meu computador"
            serial = "12345"
        }
}
$body = $manifest | ConvertTo-Json -Compress    
$body
Invoke-RestMethod -Debug -Verbose -Method Post -Headers $headers -Body $body -Uri $uri
#>


# Teste incluir ticket
$uri = "$($GLPI_api)Ticket"
$contenttype = 'application/json'
$manifest = @{}
$body = @{}
$manifest = @{
        input = @{
            tickets_id = "1"
            name = "chamado via API"
            content = "descricao do chamado novo"
            status = "1"
            urgency = "1"
            _disablenotif = "true"
            requester = "glpi"
        }
}
$body = $manifest | ConvertTo-Json -Compress    
$body
Invoke-RestMethod -Debug -Verbose -Method Post -Headers $headers -Body $body -Uri $uri



<#
# Teste: incluir ticket
$ParametersRequest = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$ParametersRequest.Add("input", "tickets_id 1")
$ParametersRequest.Add("input", "name ticket1")
$ParametersRequest.Add("input", "content descricao")
$ParametersRequest.Add("input", "status 1")
$ParametersRequest.Add("input", "urgency 1")
$ParametersRequest.Add("input", "_disablenotif true")
Invoke-RestMethod "$($GLPI_api)Ticket" -Method Post -Headers $headers -Body $body
#>
