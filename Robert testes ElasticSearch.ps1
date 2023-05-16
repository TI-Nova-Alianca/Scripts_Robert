# https://www.elastic.co/pt/blog/a-practical-introduction-to-logstash
# https://www.netfxharmonics.com/2015/11/learningelasticps/


# Verifica se o servico estah ativo
# Invoke-RestMethod http://192.168.1.2:9200


<# Cria um novo indice chamado 'robert' versao estendida
$param = @{
    Uri         = "http://192.168.1.2:9200/robert"
    Method      = "put"
}
Invoke-RestMethod @param
#>

# Cria um novo indice chamado 'robert' versao compacta
# Invoke-RestMethod -method 'put' -uri http://192.168.1.2:9200/robert2

<# Insere um documento sem informar ID
$param = @{
    Uri         = "http://192.168.1.2:9200/robert2/elasticsearch"
    Method      = "Post"
    Body        = '{"aplicacao":"teste_local",
                    "usr":"robert.koch",
                    "etiqueta":"200014132",
                    "produto":"0328"
                   }'
    ContentType = "application/json"
}
Invoke-RestMethod @param
#>

<# Cria um novo indice para gravacao de logs em geral.
$param = @{
    Uri         = "http://192.168.1.2:9200/va_logs"
    Method      = "put"
}
Invoke-RestMethod @param
#>

<# Insere um documento com ID=1
$param = @{
    Uri         = "http://192.168.1.2:9200/books/elasticsearch/1"
    Method      = "Post"
    Body        = '{"name":"Elasticsearch Essentials","author":"nome_do_autor", "etiqueta":"200014132", "produto":"0328", "usr":"robert.koch"}'
    ContentType = "application/json"
}
Invoke-RestMethod @param
#>

<# Insere um documento sem informar ID
$param = @{
    Uri         = "http://192.168.1.2:9200/books/elasticsearch"
    Method      = "Post"
    Body        = '{"name":"Elasticsearch Essentials","author":"nome_do_autor", "etiqueta":"200014132", "produto":"0328", "usr":"robert.koch"}'
    ContentType = "application/json"
}
Invoke-RestMethod @param
#>

<#Recupera um documento de ID=1
$param = @{
    Uri         = "http://192.168.1.2:9200/books/elasticsearch/1"
    #Method      = "get"
    #Body        = '{"name":"Elasticsearch Essentials","author":"nome_do_autor"}'
    #ContentType = "application/json"
}
Invoke-RestMethod @param
#>

<#Recupera apenas o atributo 'name' do campo 'source' do documento de ID=1
$param = @{
    Uri         = "http://192.168.1.2:9200/books/elasticsearch/1?_source=name"
    #Method      = "get"
    #Body        = '{"name":"Elasticsearch Essentials","author":"nome_do_autor"}'
    #ContentType = "application/json"
}
Invoke-RestMethod @param
#>

<#Exclui um documento
$param = @{
    Uri         = "http://192.168.1.2:9200/books/elasticsearch/1"
    Method      = "delete"
    #Body        = '{"name":"Elasticsearch Essentials","author":"nome_do_autor"}'
    #ContentType = "application/json"
}
Invoke-RestMethod @param
#>

<# Verifica existencia do documento de ID=1
$param = @{
    Uri         = "http://192.168.1.2:9200/books/elasticsearch/1"
    Method      = "head"
    #Body        = '{"name":"Elasticsearch Essentials","author":"nome_do_autor"}'
    #ContentType = "application/json"
}
Invoke-RestMethod @param
#>

<# Nao consegui testar o analisador.
$param = @{
    Uri         = "http://192.168.1.2:9200/books"
    Method      = "get"
    Body        = '_analyze?analyzer=whitespace&text=testing'
    ContentType = "application/json"
}
Invoke-RestMethod @param
#>

#Recupera um documento com determinado ID
# Invoke-RestMethod -Uri "http://192.168.1.2:9200/robert2/elasticsearch/VEpmbX4BHveaMv5GyUwF"

<#Recupera todos os documentos do indice robert2
$param = @{
    Uri         = "http://192.168.1.2:9200/robert2/_search"
    #Method      = "get"
    #Body        = '{"name":"Elasticsearch Essentials","author":"nome_do_autor"}'
    #ContentType = "application/json"
}
Invoke-RestMethod @param
#>

#Recupera apenas o atributo 'usr' do campo 'source' do documento de ID=VEpmbX4BHveaMv5GyUwF
# Invoke-RestMethod -Uri "http://192.168.1.2:9200/robert2/elasticsearch/VEpmbX4BHveaMv5GyUwF?_source=usr"

<#
$param = @{
    Uri         = "http://192.168.1.2:9200/robert2"
    Method      = "get"
    Body        = '{ "query": { "match_all": {} }, "size": 5000, "from": 0 }'
    ContentType = "application/json"
}
Invoke-RestMethod @param
#>

#elastic = IeIRdnpYht9gI2fxoSYM
#$pair = "$($user):$($pass)"
$pair = "elastic:IeIRdnpYht9gI2fxoSYM"
$encodedCredentials = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($Pair))
$headers = @{ Authorization = "Basic $encodedCredentials" }
$param = @{
    Uri         = "http://192.168.1.2:9200/books/elasticsearch"
    Method      = "Post"
    Body        = '{"name":"Elasticsearch Essentials","author":"nome_do_autor", "etiqueta":"200014132", "produto":"0328", "usr":"robert.koch"}'
    ContentType = "application/json"
}
Invoke-RestMethod @param -Headers $headers


# Verifica se o servico estah ativo.
$pair = "elastic:IeIRdnpYht9gI2fxoSYM"
$encodedCredentials = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($Pair))
$headers = @{ Authorization = "Basic $encodedCredentials" }
$param = @{
    Uri         = "http://192.168.1.2:9200"
    Method      = "Get"
    #Body        = '{"name":"Elasticsearch Essentials","author":"nome_do_autor", "etiqueta":"200014132", "produto":"0328", "usr":"robert.koch"}'
    ContentType = "application/json"
}
Invoke-RestMethod @param -Headers $headers

# Verifica se o servico estah ativo.
$pair = "elastic:IeIRdnpYht9gI2fxoSYM"
$encodedCredentials = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($Pair))
$headers = @{ Authorization = "Basic $encodedCredentials" }
$param = @{
    Uri         = "http://192.168.1.2:9200/_search"
    Method      = "Get"
    #Body        = '{"name":"Elasticsearch Essentials","author":"nome_do_autor", "etiqueta":"200014132", "produto":"0328", "usr":"robert.koch"}'
    ContentType = "application/json"
}
Invoke-RestMethod @param -Headers $headers
