# Monta array para armazenar resultado.
$arquivos = [System.Collections.ArrayList]@()

get-childitem "s:\protheus12\protheus_data\fontes" -Filter *.pr* | 
Foreach-Object {
    $stream = [System.IO.File]::Open($_.FullName, "Open", "Read", "ReadWrite")  # Informa que OS OUTROS processos podem abrir o arquivo para gravacao.
    $newstreamreader = New-Object System.IO.StreamReader $stream
    while (($readeachline =$newstreamreader.ReadLine()) -ne $null)
    {
        $tipoDePrograma = ''
        $palavrasChave = ''
        $tabelasPrincipais = ''
        $modulos = ''
        if ($readeachline.StartsWith('// #'))
        {
            $readeachline = $readeachline.ToUpper()
            #write-host $readeachline
            if ($readeachline.Contains('// #TIPODEPROGRAMA'))
            {
                $tipoDePrograma = $readeachline.Replace('// #TIPODEPROGRAMA','').Trim().Replace('#','')
            }
            if ($readeachline.Contains('// #PALAVRASCHAVE'))
            {
                $palavrasChave = $readeachline.Replace('// #PALAVRASCHAVE','').Trim().Replace('#','')
            }
            if ($readeachline.Contains('// #TABELASPRINCIPAIS'))
            {
                $tabelasPrincipais = $readeachline.Replace('// #TABELASPRINCIPAIS','').Trim().Replace('#','')
            }
            if ($readeachline.Contains('// #MODULOS'))
            {
                $modulos = $readeachline.Replace('// #MODULOS','').Trim().Replace('#','')
            }

            # Validacoes em cima dos dados lidos
            if ($tipoDePrograma.Length -eq 0)
            {
                Write-Host $_.BaseName 'tipo de programa nao especficado'
            }

            if ($palavrasChave.Length -eq 0)
            {
                Write-Host $_.BaseName 'nenhuma palavra chave definida'
            }

            if ($tabelasPrincipais.Length -eq 0)
            {
                Write-Host $_.BaseName 'nenhuma tabela principal definida'
            }

            if ($modulos.Length -eq 0)
            {
                Write-Host $_.BaseName 'nenhum modulo definido'
            }

            Write-Host $_.BaseName $tipoDePrograma $palavrasChave $tabelasPrincipais $modulos

            $regArq = @($_.BaseName, $tipoDePrograma, $palavrasChave, $tabelasPrincipais, $modulos)
            $arquivos.Add($regArq) > $null

        }
    }
    $stream.Dispose()
    $newstreamreader.Dispose()
}
