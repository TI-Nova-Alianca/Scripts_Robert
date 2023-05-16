# Programa:  profile.ps1
# Autor:     Robert Koch
# Data:      03/08/2022
# Descricao: Profile a ser executado a cada inicializacao de instancia do PowerShell
#            O PowerShell faz a chamada em $Home\Documents, mas deixo aqui para
#            concentrar todos os scripts numa mesma pasta.

# Dica para "editar o profile do usuario corrente:" notepad $profile
#
# Exemplo de como fica o profile original:
# try {
#     . ("c:\util\scripts\profile.ps1")
# }
# catch {
#     Write-Warning "Erro ao carregar profiles adicionais" 
# }
# 
# Historico de alteracoes:
#

write-host '[Inicio execucao profile]'

# cria alias para chamar o notepad++
Set-Alias npp  'C:\Program Files (x86)\Notepad++\notepad++.exe'
Set-Alias bt   'C:\util\baretail.exe'
Set-Alias loxx "C:\Program Files\mommos-software\loxx\bin\Loxx.exe"

write-host '[Fim execucao profile]'
write-host ''
