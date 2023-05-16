$param = @{
    Uri         = "http://192.168.2.228:9100"
    Method      = "Post"
    Body        = `e + '@' + 'teste' + `e + 'w'
    ContentType = "application/json"
}
Invoke-RestMethod @param

https://forum.scriptcase.com.br/t/integracao-com-impressoras-bematech-mp-4200-th/16157

