
# Faz conexao com o banco de dados
$SQLUser = "consultas"
$Password = "consultas" | ConvertTo-SecureString -AsPlainText -Force
$Password.MakeReadOnly()
$cred = New-Object System.Data.SqlClient.SqlCredential($SQLUser,$Password)
$connection = new-object System.Data.SqlClient.SQLConnection("Data Source=serversql;Initial Catalog=BL01");
$connection.credential = $cred
$connection.Open();
if ($connection.State -ne 'Open')
{
    Write-Host "Erro de conexao ao banco de dados"
}
else
{
    # Leitura em loop por tempo indeterminado.
    $contador = 0
    do
    {
        
        # Especifica janela de horario a analisar
        $HoraIni = (get-date).AddMinutes(-10).ToString("yyyyMMdd HH:mm:ss")
        $HoraFim = (get-date).ToString("yyyyMMdd HH:mm:ss")
        #$horaIni = '20200128 17:05:00'
        #$horaFim = '20200128 17:15:00'
        $horaIni
        $horaFim

        # Gera uma CTE para poder fazer uma UNION e ordenar, depois, pelo horario.
        $query  = "WITH C AS ("

        # Leituras das medicoes continuas
        $query +=" SELECT CONVERT(VARCHAR(8), HORA, 108) AS HORARIO"
        $query +=       ",max (CASE WHEN LINHA = 1 AND LINE_STATUS = 'Medida' THEN ROUND(GRAU, 2) ELSE 0 END) AS L1_GRAU_MEDIDA"
        $query +=       ",max (CASE WHEN LINHA = 1 AND LINE_STATUS = 'Espera' THEN ROUND(GRAU, 2) ELSE 0 END) AS L1_GRAU_ESPERA"
        $query +=       ",max (CASE WHEN LINHA = 1 AND LINE_STATUS = 'Hold'   THEN ROUND(GRAU, 2) ELSE 0 END) AS L1_GRAU_HOLD"

        $query +=       ",max (CASE WHEN LINHA = 2 AND LINE_STATUS = 'Medida' THEN ROUND(GRAU, 2) ELSE 0 END) AS L2_GRAU_MEDIDA"
        $query +=       ",max (CASE WHEN LINHA = 2 AND LINE_STATUS = 'Espera' THEN ROUND(GRAU, 2) ELSE 0 END) AS L2_GRAU_ESPERA"
        $query +=       ",max (CASE WHEN LINHA = 2 AND LINE_STATUS = 'Hold'   THEN ROUND(GRAU, 2) ELSE 0 END) AS L2_GRAU_HOLD"

        $query +=       ",max (CASE WHEN LINHA = 3 AND LINE_STATUS = 'Medida' THEN ROUND(GRAU, 2) ELSE 0 END) AS L3_GRAU_MEDIDA"
        $query +=       ",max (CASE WHEN LINHA = 3 AND LINE_STATUS = 'Espera' THEN ROUND(GRAU, 2) ELSE 0 END) AS L3_GRAU_ESPERA"
        $query +=       ",max (CASE WHEN LINHA = 3 AND LINE_STATUS = 'Hold'   THEN ROUND(GRAU, 2) ELSE 0 END) AS L3_GRAU_HOLD"

        $query +=       ",max (CASE WHEN LINHA = 4 AND LINE_STATUS = 'Medida' THEN ROUND(GRAU, 2) ELSE 0 END) AS L4_GRAU_MEDIDA"
        $query +=       ",max (CASE WHEN LINHA = 4 AND LINE_STATUS = 'Espera' THEN ROUND(GRAU, 2) ELSE 0 END) AS L4_GRAU_ESPERA"
        $query +=       ",max (CASE WHEN LINHA = 4 AND LINE_STATUS = 'Hold'   THEN ROUND(GRAU, 2) ELSE 0 END) AS L4_GRAU_HOLD"
        $query +=       ",CONVERT(VARCHAR(8), HORA, 108) AS LABEL"
        $query +=       ",0 AS TOMBADOR_EFETIVO"
        $query +=  " FROM MEDICOES_CONTINUAS"
        $query += " WHERE FILIAL = '01'"
        
        # Usar esta clausula para pegar um horario de teste
        #$query +=  " AND HORA >= dateadd (SECOND, " + $contador.ToString() + ", '20200128 17:05:00')"
        $query +=  " AND HORA between '" + $horaIni + "' AND '" + $horaFim + "'"
        
        # Usar esta clausula para pegar horario atual.
        #$query +=  " AND HORA >= dateadd (MINUTE, -5, CURRENT_TIMESTAMP)"
        
        $query +=  " GROUP BY CONVERT(VARCHAR(8), HORA, 108)"  # Nao quero os milissegundos
        
        $query +=  " UNION ALL"
 
        # Leitura dos horarios de inicio e termino de cada carga
<#
        $query +=  " SELECT substring (CASE WHEN ZZA_STATUS = '3' THEN ZZA_INIST3 ELSE ZZA_INIST2 END, 10, 8), 0,0,0,0,0,0,0,0,0,0,0,0,"
        $query +=  "       CASE WHEN ZZA_STATUS = '3' THEN 'Fim ' + ZZA_CARGA + '\n' + substring (ZZA_NASSOC, 1, 6) + '(' + cast (ZZA_GRAU as varchar (5)) + ')'"
        $query +=  "       ELSE 'Ini ' + ZZA_CARGA + '\n' + substring (ZZA_NASSOC, 1, 6) END as label"
        $query +=  "       ,ZZA_LINHA AS TOMBADOR_EFETIVO"
        $query +=  " FROM protheus.dbo.ZZA010 WHERE D_E_L_E_T_ = '' AND ZZA_FILIAL = '01' AND ZZA_SAFRA = '2020'"
        $query +=  " AND ((ZZA_INIST2 between '" + $HoraIni + "' AND '" + $HoraFim + "') OR (ZZA_INIST3 between '" + $HoraIni + "' AND '" + $HoraFim + "'))"
        #>

        $query +=  " SELECT SUBSTRING (ZZA_INIST2, 10, 8), 0,0,0,0,0,0,0,0,0,0,0,0,"
        $query +=  "       'Ini ' + ZZA_CARGA + '\n' + substring (ZZA_NASSOC, 1, 6) as label"
        $query +=  "       ,ZZA_LINHA AS TOMBADOR"
        $query +=  " FROM protheus.dbo.ZZA010 WHERE D_E_L_E_T_ = '' AND ZZA_FILIAL = '01' AND ZZA_SAFRA = '2020'"
        $query +=  " AND ZZA_INIST2 between '" + $HoraIni + "' AND '" + $HoraFim + "'"
        $query +=  " UNION ALL"
        $query +=  " SELECT substring (ZZA_INIST3, 10, 8), 0,0,0,0,0,0,0,0,0,0,0,0,"
        $query +=  "       'Fim ' + ZZA_CARGA + '\n' + substring (ZZA_NASSOC, 1, 6) + '(' + cast (ZZA_GRAU as varchar (5)) + ')' as label"
        $query +=  "       ,ZZA_LINHA AS TOMBADOR"
        $query +=  " FROM protheus.dbo.ZZA010 WHERE D_E_L_E_T_ = '' AND ZZA_FILIAL = '01' AND ZZA_SAFRA = '2020'"
        $query +=  " AND ZZA_INIST3 between '" + $HoraIni + "' AND '" + $HoraFim + "'"


        $query +=  " )SELECT * FROM C"
        $query +=  " ORDER BY HORARIO"
        write-host $query
        $cmd = new-object System.Data.SqlClient.SqlCommand($query, $connection);
        $SQLReader = $cmd.ExecuteReader()

        # Grava registros retornados pelo SQL numa lista para poder processa-los mais de uma vez.
        $Medicoes = [System.Collections.ArrayList]@()
        while ($SQLReader.Read()) {
            $medicao = @($SQLReader.GetValue(0), $SQLReader.GetValue(1), $SQLReader.GetValue(2), $SQLReader.GetValue(3), $SQLReader.GetValue(4), $SQLReader.GetValue(5), $SQLReader.GetValue(6), $SQLReader.GetValue(7), $SQLReader.GetValue(8), $SQLReader.GetValue(9), $SQLReader.GetValue(10), $SQLReader.GetValue(11), $SQLReader.GetValue(12), $SQLReader.GetValue(13), $SQLReader.GetValue(14))
            $Medicoes.Add($medicao) > $null
        }
        $SQLReader.Close()


	    $htm = '<html>'
	    $htm = $htm + [Environment]::NewLine + '<head>'
	    $htm = $htm + [Environment]::NewLine + '<title>Acompanhamento grau</title>'
	
	    # Configura refresh automatico a cada X segundos
        $htm = $htm + [Environment]::NewLine + '<meta http-equiv="refresh" content="10" />'

	    # Include fusioncharts core library
        $htm = $htm + [Environment]::NewLine + '<script type="text/javascript" src="C:\Temp\fusioncharts-suite-xt\js\fusioncharts.js"></script>'

	    # Include fusion theme #
	    $htm = $htm + [Environment]::NewLine + '<script type="text/javascript" src="C:\Temp\fusioncharts-suite-xt\jsthemes\fusioncharts.theme.fusion.js"></script>'

	    $htm = $htm + [Environment]::NewLine + '<script type="text/javascript">'
	    $htm = $htm + [Environment]::NewLine + 'FusionCharts.ready(function(){'

	    # Cria um grafico para cada linha de descarga
	    $linhaDescarga = 1
	    while ($linhaDescarga -le 3)
        {

		    # Cria grafico
		    $htm = $htm + [Environment]::NewLine + 'var grafico' + $linhaDescarga + ' = new FusionCharts({'
		    $htm = $htm + [Environment]::NewLine + 'type: "msline",'  # Tipo de grafico: Multi Series Line
		    $htm = $htm + [Environment]::NewLine + 'renderAt: "chart-container' + $linhaDescarga + '",'
		    $htm = $htm + [Environment]::NewLine + 'width: +window.innerWidth/2-15, height: +window.innerHeight/2-15,' # Usa funcoes do HTML para buscar o tamanho da area disponivel em tela
		    $htm = $htm + [Environment]::NewLine + 'dataFormat: "json",'
		    $htm = $htm + [Environment]::NewLine + 'legendPosition: "right",'  # Mostrar legenda no lado doreito
		    $htm = $htm + [Environment]::NewLine + 'dataSource: {"chart": {'
		    $htm = $htm + [Environment]::NewLine +    'yAxisName: "Linha ' + $linhaDescarga + ' - grau babo",'
		    $htm = $htm + [Environment]::NewLine +    'theme: "fusion",'
		    $htm = $htm + [Environment]::NewLine +    'yAxisMinValue: 9,'  # Valor minimo do eixo y
		    $htm = $htm + [Environment]::NewLine +    'yAxisMaxValue: 20,'  # Valor maximo do eixo y
		    $htm = $htm + [Environment]::NewLine +    'animation: "0",'  # Para nao dar efeito de lentidao no desenho da linha
		    $htm = $htm + [Environment]::NewLine +    'labelStep: ' + $Medicoes.Count / 20 + ','  # Mostrar rotulo de linha a cada X pontos
		    $htm = $htm + [Environment]::NewLine +    'rotateLabels: "1","slantLabel": "1",'  # Mostrar rotulos inclinadas
		    $htm = $htm + [Environment]::NewLine +    'showValues: "0",'  # Nao mostrar o grau de cada medicao
		    $htm = $htm + [Environment]::NewLine +    'drawAnchors: "1",'  # Nao mostrar 'bolinas' em cada medicao
		    $htm = $htm + [Environment]::NewLine +    'lineThickness: "1",'  # Largura das linhas
		    $htm = $htm + [Environment]::NewLine +    'anchorRadius: "1"},'  # Tamanho das 'bolinas' dos valores

		    # Cada horario de medicao vai ser uma categoria
            $htm = $htm + [Environment]::NewLine + 'categories: ['
            $htm = $htm + [Environment]::NewLine + '   {'
            $htm = $htm + [Environment]::NewLine + '       category: ['
            foreach ($medicao in $Medicoes)
            {
                $label = $medicao[13]
                $tombadorEfetivo = $medicao[14]
                
                # Se for um inicio ou fim de descarga, gera uma linha vertical no grafico.
                if ($label -like 'Ini*')
                {
                    # Se a carga ainda nao finalizou, mostra nos graficos de todos os tombadores. Se jah finalizou, mostra apenas no tombador efetivo.
                    if ($tombadorEfetivo -eq $linhaDescarga)
                    {
                        $htm = $htm + [Environment]::NewLine + '{vLine: true,showOnTop: 1, label: "' + $label + '"},'
                    }
                }
                elseif ($label -like 'Fim*')
                {
                    # Se a carga ainda nao finalizou, mostra nos graficos de todos os tombadores. Se jah finalizou, mostra apenas no tombador efetivo.
                    if ($tombadorEfetivo -eq $linhaDescarga)
                    {
                        $htm = $htm + [Environment]::NewLine + '{vLine: true,showOnTop: 1, labelPosition: 0.87, label: "' + $label + '"},'
                    }
                }
                else
                {
                    $htm = $htm + [Environment]::NewLine + '{label: "' + $label + '"},'
                }
            }
            $htm = $htm + [Environment]::NewLine + ']}],'

            # Um conjunto de dados para cada status
            $htm = $htm + [Environment]::NewLine + 'dataset: [{seriesname: "Medida",color: "#ff0000",data: ['
            foreach ($medicao in $Medicoes)
            {
                $grau = $medicao[1 + ($linhaDescarga - 1) * 3]
#                write-host 'coluna '+ (1 + ($linhaDescarga - 1) * 3)
#                write-host $grau

                if ($grau -le 0)
                {
                    $htm = $htm + [Environment]::NewLine + '{},'
                }
                else
                {
                    $htm = $htm + [Environment]::NewLine + '{value: ' + $grau + '},'
                }

#            $htm = $htm + [Environment]::NewLine + '{' + $(if ($grau -gt 0) {$grau} else {}) + ','

            }
            $htm = $htm + [Environment]::NewLine + ']},{seriesname: "Espera",color: "#00ff00",data: ['
            foreach ($medicao in $Medicoes)
            {
                $grau = $medicao[2 + ($linhaDescarga - 1) * 3]

                if ($grau -le 0)
                {
                    $htm = $htm + [Environment]::NewLine + '{},'
                }
                else
                {
                    $htm = $htm + [Environment]::NewLine + '{value:' + $grau + '},'
                }

#            $htm = $htm + [Environment]::NewLine + '{' + $(if ($grau -gt 0) {$grau} else {}) + ','
            }
            $htm = $htm + [Environment]::NewLine + ']},{seriesname: "Hold",color: "#0000ff",data: ['
            foreach ($medicao in $Medicoes)
            {
                $grau = $medicao[3 + ($linhaDescarga - 1) * 3]

                if ($grau -le 0)
                {
                    $htm = $htm + [Environment]::NewLine + '{},'
                }
                else
                {
                    $htm = $htm + [Environment]::NewLine + '{value:' + $grau + '},'
                }

#            $htm = $htm + [Environment]::NewLine + '{' + $(if ($grau -gt 0) {$grau} else {}) + ','
            }
            $htm = $htm + [Environment]::NewLine + ']}'

            # Finaliza dataset
            $htm = $htm + [Environment]::NewLine + ']'

		    $htm = $htm + [Environment]::NewLine + '}});'
		    $htm = $htm + [Environment]::NewLine + 'grafico' + $linhaDescarga + '.render();'



		    $linhaDescarga = $linhaDescarga + 1
	    }


	    # Finaliza a "FusionCharts.ready(function()"
	    $htm = $htm + [Environment]::NewLine + '});'
	    $htm = $htm + [Environment]::NewLine + '</script>'
	    $htm = $htm + [Environment]::NewLine + '</head>'
	    $htm = $htm + [Environment]::NewLine + '<body>'

	    # Organiza os graficos em uma tabela de 2 linhas x 2 colunas
        $htm = $htm + [Environment]::NewLine + '<table>'
	    $htm = $htm + [Environment]::NewLine + '  <tr>'
	    $htm = $htm + [Environment]::NewLine + '    <td>'
	    $htm = $htm + [Environment]::NewLine + '      <div id="chart-container1">O grafico 1 deve aparecer aqui</div>'
	    $htm = $htm + [Environment]::NewLine + '    </td>'
	    $htm = $htm + [Environment]::NewLine + '    <td>'
	    $htm = $htm + [Environment]::NewLine + '      <div id="chart-container2">O grafico 2 deve aparecer aqui</div>'
	    $htm = $htm + [Environment]::NewLine + '    </td>'
	    $htm = $htm + [Environment]::NewLine + '  </tr>'
	    $htm = $htm + [Environment]::NewLine + '  <tr>'
	    $htm = $htm + [Environment]::NewLine + '    <td>'
	    $htm = $htm + [Environment]::NewLine + '      <div id="chart-container3">O grafico 3 deve aparecer aqui</div>'
	    $htm = $htm + [Environment]::NewLine + '    </td>'
	    $htm = $htm + [Environment]::NewLine + '    <td>'
	    $htm = $htm + [Environment]::NewLine + '      <div id="chart-container4">O grafico 4 deve aparecer aqui</div>'
	    $htm = $htm + [Environment]::NewLine + '    </td>'
	    $htm = $htm + [Environment]::NewLine + '  </tr>'
	    $htm = $htm + [Environment]::NewLine + '</table>'

        $htm | Out-File C:\Temp\grafico_grau\Grafico_grau-GERADO.html

        Write-host (get-date).ToString('T') 'aguardando nova execucao...'
        Start-Sleep (10)
        $contador += 10
    } while (1 -eq 1)
}


