# Tarefa a ser agendada no Windows de cada estacao

# Busca script na rede para que o mesmo possa sempre ser atualizado dinamicamente.
& \\192.168.1.12\Documentos\Informatica\Suporte\Binarios\Scripts\Script_para_todas_estacoes.ps1

<# O QUE DEVERIA ESTAR NO SCRIPT DA REDE:

if (@(get-process -name *spark*).Length -eq 0)
{
    &"C:\Program Files (x86)\Spark\Spark.exe"
}

#>
