# Script estacao Robert
# Data: 24/12/2022
# Autor: Robert Koch
# Descricao: tarefas repetitivas estacao do Robert
#            Criado inicialmente para executar Spark e copiar objetos do SQL da rede
#
# Historico de alteracoes:
# 30/12/2022 - Robert - Muito lento para testar conteudo dos arquivos de definicoes
#                       de objetos do SQL. Voltei para a funcao XCOPY.
# 24/02/2023 - Robert - XCopy substituido por Get-FileHash (preciso ter mais precisao)
#                     - Remove do C: os arquivos SQL que nao estiverem mais na pasta origem.
# 14/03/2023 - Robert - Testa se encontra a basta base dos objetos SQL no servidor antes de continuar.
# 05/04/2023 - Robert - Criado tratamento para copiar scripts do SrvADM.
# 25/05/2023 - Robert - Verifica se consegue acessar as pastas nos servidores antes de iniciar as comparacoes de arquivos.
#

# ---------------------------------------------------------------------------
# Importa arquivos de funcoes via 'dot source' para que as funcoes possam ser usadas aqui.
. '\\SRVADM\c$\util\Scripts\Function_VA_Log.ps1'
. '\\SRVADM\c$\util\Scripts\Function_VA_Aviso.ps1'

# ---------------------------------------------------------------------------
VA_Log -TipoLog 'info' -MsgLog 'Iniciando execucao'

# Processamento em loop por tempo indeterminado.
$contadorDeLoops = 1
do
{

    # Executa Spark, caso ainda nao esteja rodando.
    # Parece que nao funciona por estar rodando sem interface com o ususario.
#    VA_Log -TipoLog 'debug' -MsgLog 'testando spark'
#    if (@(get-process -name *spark*).Length -eq 0)
#    {
#        VA_Log -TipoLog 'debug' -MsgLog 'vou executar spark'
#        &"C:\Program Files (x86)\Spark\Spark.exe"
#    }


    # Copia da rede as definicoes de objetos do SQL, para manter atualizado no Github.
    # Como jah tenho algumas pastas criadas localmente, optei por usar uma lista
	# relacionando a pasta de origem (no servidor) e a pasta destino (local).
    $PastaBaseServidor = "\\serverSQL\C$\Util\Bkp_Objetos_SQL"
    if (!(Test-Path $PastaBaseServidor))
    {
        VA_Log -TipoLog 'erro' -MsgLog ('Pasta base objetos SQL inacessivel: ' + $PastaBaseServidor)
    }
    else
    {
        $PastasBkpServidor = [System.Collections.ArrayList]@()
        $PastasBkpServidor.Add(@('TI',             'TI'))
        $PastasBkpServidor.Add(@('BI_ALIANCA',     'BI_ALIANCA'))
        $PastasBkpServidor.Add(@('BL01',           'BL01'))
        $PastasBkpServidor.Add(@('naweb',          'naweb'))
        $PastasBkpServidor.Add(@('MercanetHML',    'MercanetHML'))
        $PastasBkpServidor.Add(@('Mercanet',       'Mercanet'))
        $PastasBkpServidor.Add(@('protheus',       'protheus'))
        # Este nao vou querer mandar para o GIT. $PastasBkpServidor.Add(@('protheus_teste', 'protheus_teste'))

        foreach ($PastaBkp in $PastasBkpServidor)
        {
        
            VA_Log -TipoLog 'info' -MsgLog ('Verificando pasta ' + $PastaBkp[0] + ' --> ' + $PastaBkp[1])

            $PastaNoServidor = $PastaBaseServidor + "\" + $PastaBkp[0]
            $PastaLocal = "C:\FontesSQL\" + $PastaBkp[1]
            if (!(Test-Path -Path $PastaLocal))
            {
	            New-Item -Force -ItemType Directory -Path $PastaLocal -verbose
            }

            #Nao ficou bom por que os arq. sao sempre mais novos --> # Copia arquivos que forem mais novos na pasta de origem.
            #Nao ficou bom por que os arq. sao sempre mais novos --> xCopy $PastaNoServidor\*.sql $PastaLocal /s /d /f /y

            # Copia arquivos que tiverem conteudo diferente na pasta origem (royalties para https://adamtheautomator.com/get-filehash/)
            foreach($arq in Get-ChildItem $PastaNoServidor\*.sql)
            {
                # Se o arquivo nao existe na pasta destino, nem preciso perder tempo em testar diferencas.
                if (Test-Path ($PastaLocal + '\' + $Arq.Name))
                {
                    VA_Log -TipoLog 'debug' -MsgLog ('Verificando novidades em ' + $Arq.FullName)
                    if ((Get-FileHash $arq.FullName).Hash -ne (Get-FileHash ($PastaLocal + '\' + $Arq.Name)).Hash)
                    {
                        VA_Log -TipoLog 'debug' -MsgLog 'Hash diferente! Copiando arquivo'
                        Copy-Item $arq.FullName $PastaLocal -verbose
                    }
                }
                else
                {
                    VA_Log -TipoLog 'debug' -MsgLog ('Copiando arquivo novo ' + $Arq.FullName)
                    Copy-Item $arq.FullName $PastaLocal -verbose
                }
            }

            # Apaga da pasta destino os arquivos que nao existirem na pasta origem
            VA_Log -TipoLog 'debug' -MsgLog 'Verificando arquivos do SQL que nao existem mais na origem'
            foreach($arq in Get-ChildItem $PastaLocal\*.sql)
            {
                if ((Test-Path ($PastaNoServidor + '\' + $Arq.Name)) -eq $False)
                {
                    VA_Log -TipoLog 'debug' -MsgLog ('Arquivo nao existe na pasta origem: ' + $Arq.Name)
                    Remove-Item $Arq.FullName -verbose
                }
            }
        
        }
    }


    # Copia da rede os scripts do ServerADM, para manter atualizado no Github.
    $PastaNoServidor = "\\192.168.1.12\c$\util\scripts"
    if (!(Test-Path $PastaNoServidor))
    {
        VA_Log -TipoLog 'erro' -MsgLog ('Pasta base scripts inacessivel: ' + $PastaNoServidor)
    }
    else
    {

        $PastaLocal = "C:\util\scripts_SrvADM"
        VA_Log -TipoLog 'info' -MsgLog ('Verificando pasta ' + $PastaNoServidor + ' --> ' + $PastaLocal)
        if (!(Test-Path -Path $PastaLocal))
        {
	        New-Item -Force -ItemType Directory -Path $PastaLocal -verbose
        }
        # Copia arquivos que tiverem conteudo diferente na pasta origem (royalties para https://adamtheautomator.com/get-filehash/)
        foreach($arq in Get-ChildItem $PastaNoServidor\*.ps1)
        {
            # Se o arquivo nao existe na pasta destino, nem preciso perder tempo em testar diferencas.
            if (Test-Path ($PastaLocal + '\' + $Arq.Name))
            {
                VA_Log -TipoLog 'debug' -MsgLog ('Verificando novidades em ' + $Arq.FullName)
                if ((Get-FileHash $arq.FullName).Hash -ne (Get-FileHash ($PastaLocal + '\' + $Arq.Name)).Hash)
                {
                    VA_Log -TipoLog 'debug' -MsgLog 'Hash diferente! Copiando arquivo'
                    Copy-Item $arq.FullName $PastaLocal -verbose
                }
            }
            else
            {
                VA_Log -TipoLog 'debug' -MsgLog ('Copiando arquivo novo ' + $Arq.FullName)
                Copy-Item $arq.FullName $PastaLocal -verbose
            }
        }
        # Apaga da pasta destino os arquivos que nao existirem na pasta origem
        VA_Log -TipoLog 'debug' -MsgLog 'Verificando arquivos do SQL que nao existem mais na origem'
        foreach($arq in Get-ChildItem $PastaLocal\*.sql)
        {
            if ((Test-Path ($PastaNoServidor + '\' + $Arq.Name)) -eq $False)
            {
                VA_Log -TipoLog 'debug' -MsgLog ('Arquivo nao existe na pasta origem: ' + $Arq.Name)
                Remove-Item $Arq.FullName -verbose
            }
        }
    }


    # Copia backups de anotações do CintaNotes do C: para a rede
    VA_Log -TipoLog 'info' -MsgLog ('Iniciando backup CintaNotes')
    $DataHora = Get-Date -Format yyyyMMdd-HHmmss
    $Compactador = "C:\Util\7za.exe"
    $PastaBackups = 'Z:\Informatica\Doc nao tecnicos\Backup_CintaNotes_Robert'
    if (!(Test-Path -Path $PastaBackups))
    {
	    New-Item -Force -ItemType Directory -Path $PastaBackups
    }
    copy-item C:\util\CintaNotes_3_12\backup\*.* $PastaBackups -Verbose -Force
    & $Compactador a -r -tzip $PastaBackups\Scripts c:\util\scripts\*.ps1


    # Backup pasta local fontes Protheus
    VA_Log -TipoLog 'info' -MsgLog ('Iniciando backup FontesProtheus')
    $PastaBackups = 'C:\Backups'
    if (!(Test-Path -Path $PastaBackups))
    {
	    New-Item -Force -ItemType Directory -Path $PastaBackups
    }
    & $Compactador a -r -tzip $PastaBackups\Fontes_locais_Protheus_$DataHora C:\FontesProtheus\FontesProtheus\*.*


    VA_Log -TipoLog 'info' -MsgLog ('Iteracao numero ' + $contadorDeLoops + ' finalizada. Aguardando nova execucao...')
    Start-Sleep (60 * 60) # a cada hora estah mais que bom
    $contadorDeLoops ++
} while (1 -eq 1)

