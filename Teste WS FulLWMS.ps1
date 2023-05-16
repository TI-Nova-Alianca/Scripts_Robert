# Limpa arquivos de log de erro, se possivel
$FileName = "\\192.168.1.3\siga\Protheus12\protheus_data\sigaadv\wserror.log"
if (Test-Path $FileName) {
  Remove-Item $FileName
}
$FileName = "\\192.168.1.3\siga\Protheus12\protheus_data_teste\sigaadv\wserror.log"
if (Test-Path $FileName) {
  Remove-Item $FileName
}
$FileName = "\\192.168.1.3\siga\Protheus12\protheus_data_r23\system\wserror.log"
if (Test-Path $FileName) {
  Remove-Item $FileName
}

$TokenUsr = 000210
$TokenUsr = $TokenUsr * $TokenUsr
$TokenUsr += (Get-Date).year - 1000
$TokenUsr += (Get-Date).month * 1000
$TokenUsr = $TokenUsr.ToString()

$uri = "http://192.168.1.3:7980/ws/WS_ALIANCA.APW?WSDL" # base QUENTE
#$uri = "http://namob.novaalianca.coop.br:7982/ws/WS_namob.apw?WSDL" # base QUENTE_Externo
#$uri = "http://192.168.1.3:7981/ws/WS_ALIANCA.APW?WSDL" # base TESTE
$proxy = New-WebServiceProxy -Uri $uri
$proxy.Timeout = 18000000  # aguarda 18000 segundos. Alguns processos, como o de reestruturação de tabelas, podem demorar.

$XML = '<WSAlianca>'

$XML +=    '<User>robert.koch</User>'
$XML +=    '<IDAplicacao>gg2gj256y5f2c5b89</IDAplicacao>'  # interno (WS_Alianca)
#$XML +=    '<IDAplicacao>ghdf743j689fj4889</IDAplicacao>'  # externo (WS_NaMob)

$XML +=    '<Empresa>01</Empresa><Filial>01</Filial>'

#$XML +=    '<Acao>ExecutaBatch</Acao><Sequencia>104756</Sequencia>' # Mercanet - envia dados  # listas preco: EXECUTE [dbo].[MERCP_CONCORRENTE_INTEGRACOES] 41  --clientes:20
#$XML +=    '<Acao>ExecutaBatch</Acao><Sequencia>nao eh mais esta</Sequencia>' # Mercanet - recebe pedidos
#$XML +=    '<Acao>ExecutaBatch</Acao><Sequencia>104758</Sequencia>' # Mercanet - recebe clientes
#$XML +=    '<Acao>ExecutaBatch</Acao><Sequencia>000002</Sequencia>' # EDI Neogrid - recebe pedidos
#$XML +=    '<Acao>ExecutaBatch</Acao><Sequencia>000003</Sequencia>' # EDI Neogrid - exporta notas
#$XML +=    '<Acao>ExecutaBatch</Acao><Sequencia>000014</Sequencia>' # Recebe EDI conhecimentos de frete
#$XML +=    '<Acao>ExecutaBatch</Acao><Sequencia>096939</Sequencia>' # BatFullW (integracao Protheus x FullWMS)
#$XML +=    '<Acao>ExecutaBatch</Acao><Sequencia>088417</Sequencia>' # Redespacha fila de e-mails                                                                          
#$XML +=    '<Acao>ExecutaBatch</Acao><Sequencia>000057</Sequencia>' # Importa XML de NF-e
#$XML +=    '<Acao>ExecutaBatch</Acao><Sequencia>099888</Sequencia>' # BatDocCanc (e-mail de aviso de doc cancelados)
#$XML +=    '<Acao>ExecutaBatch</Acao><Sequencia>000082</Sequencia>' # Exporta XML via Webservice para Walmart                                                             
#$XML +=    '<Acao>ExecutaBatch</Acao><Sequencia>127451</Sequencia>' # BatLojas filial 13
#$XML +=    '<Acao>ExecutaBatch</Acao><Sequencia>127452</Sequencia>' # BatLojas filial 10
#$XML +=    '<Acao>ExecutaBatch</Acao><Sequencia>127453</Sequencia>' # BatLojas filial 08
#$XML +=    '<Acao>ExecutaBatch</Acao><Sequencia>127454</Sequencia>' # BatLojas filial 03
#$XML +=    '<Acao>ExecutaBatch</Acao><Sequencia>121375</Sequencia>' # Revalida chaves da UF=PE
#$XML +=    '<Acao>ExecutaBatch</Acao><Sequencia>127479</Sequencia>' # U_RecMail
#$XML +=    '<Acao>ExecutaBatch</Acao><Sequencia>099617</Sequencia>' # U_BatUsers
#$XML +=    '<Acao>ExecutaBatch</Acao><Sequencia>103095</Sequencia>' # U_BatMetaF (gera titulos a partir do Metadados)

#$XML +=    '<Acao>ConsultaFechamentoSafraAssoc</Acao><Assoc>003577</Assoc><Loja>01</Loja><Safra>2019</Safra>'
#$XML +=    '<Acao>ConsultaCapitalSocialAssoc</Acao><Assoc>000209</Assoc><Loja>01</Loja>'
#$XML +=    '<Acao>ConsultaExtratoCCAssoc</Acao><Assoc>000161</Assoc><Loja>01</Loja><DataIni>20190101</DataIni><DataFim>20190924</DataFim>'

#$XML +=    '<Acao>RastrearLote</Acao>'
#$XML +=    '<Produto>9901</Produto>'
#$XML +=    '<Lote>12130001</Lote>'

#$XML +=    '<Acao>GravaInspecao</Acao>'
#$XML +=    '<TipoInspecao>NF</TipoInspecao>'
#$XML +=    '<Produto>1592</Produto>'
#$XML +=    '<Lote>000001</Lote>'
#$XML +=    '<NF>001173686</NF>'
#$XML +=    '<Serie>1</Serie>'
#$XML +=    '<Fornecedor>001906</Fornecedor>'
#$XML +=    '<Loja>01</Loja>'
#$XML +=    '<Resultado>A</Resul>'

#$XML +=    '<Acao>RefazSaldoAtual</Acao><Produto>1235</Produto>'

#$XML +=    '<Acao>AtuEstru</Acao><Tabela>ZZ9</Tabela><FiltroAppend></FiltroAppend>'

#$XML +=    '<Acao>OndeSeUsa</Acao><Campo>GLN</Campo>'

#$XML +=    '<Acao>IncluiCliente</Acao>'
#$XML +=    '<Nome>ROBERT</Nome>'
#$XML +=    '<Pessoa>F</Pessoa>'
#$XML +=    '<CGC>75372797053</CGC>'
#$XML +=    '<Tel>981246022</Tel>'
#$XML +=    '<EMail>robert.koch@novaalianca.coop.br</EMail>'
#$XML +=    '<Est>RS</Est>'
#$XML +=    '<Cidade>08201</Cidade>'
#$XML +=    '<Bairro>PEDANCINO</Bairro>'
#$XML +=    '<End>RS 122 KM 87</End>'
#$XML +=    '<CEP>95100000</CEP>'

<#
$XML +=    '<Acao>TransfEstqInsere</Acao>'
$XML +=    '<FilialOrigem>01</FilialOrigem>'
$XML +=    '<FilialDestino>01</FilialDestino>'
$XML +=    '<ProdutoOrigem>4438</ProdutoOrigem>'
$XML +=    '<ProdutoDestino>4438</ProdutoDestino>'
$XML +=    '<AlmoxOrigem>08</AlmoxOrigem>'
$XML +=    '<AlmoxDestino>02</AlmoxDestino>'
$XML +=    '<LoteOrigem>AUTO003656</LoteOrigem>'
$XML +=    '<LoteDestino></LoteDestino>'
$XML +=    '<EnderecoOrigem></EnderecoOrigem>'
$XML +=    '<EnderecoDestino></EnderecoDestino>'
$XML +=    '<QtdSolic>847</QtdSolic>'
$XML +=    '<Motivo>teste impr etiq</Motivo>'
$XML +=    '<OP></OP>'
$XML +=    '<Impressora>02</Impressora>'
#>

#$XML +=    '<Acao>TransfEstqAutoriza</Acao><DocTransf>0000000031</DocTransf>'
#$XML +=    '<Acao>TransfEstqDeleta</Acao><DocTransf>0000000020</DocTransf>'

#$XML +=    '<Acao>IncluiEvento</Acao>'
#$XML +=    '<DataEvento>20190718</DataEvento>'
#$XML +=    '<CodigoEvento>000001</CodigoEvento>'
#$XML +=    '<Texto>teste inclusao evento via WS</Texto>'
#$XML +=    '<PedVenda>000001</PedVenda>'
#$XML +=    '<Cliente>000001</Cliente>'
#$XML +=    '<LojaCliente>01</LojaCliente>'

#$XML += '<Acao>ConsultaDeOrcamentos</Acao><FilialIni>01</FilialIni><FilialFin>16</FilialFin><Ano>2019</Ano><DataInicial>20190101</DataInicial><DataFinal>20190131</DataFinal><Modelo>2020</Modelo><Perfis>8</Perfis>'

<#
$XML += '<Acao>IncluiCargaSafra</Acao><Safra>2020</Safra><Balanca>LB</Balanca><Associado>000161</Associado><Loja>01</Loja>'
$XML += '<SerieNfProdutor>123</SerieNfProdutor><NumeroNfProdutor>134439743</NumeroNfProdutor><ChaveNFPe></ChaveNFPe>'
$XML += '<PlacaVeiculo>abc1x34</PlacaVeiculo><Tombador>1</Tombador><Obs>Teste robert</Obs>'
$XML += '<coletarAmostra>S</coletarAmostra><Senha>1</Senha>'
$XML += '<cadastroViticola1>13386</cadastroViticola1><Variedade1>9901</Variedade1><Embalagem1>G</Embalagem1>'
#>
#$XML += '<Acao>IncluiCargaSafra</Acao><Safra>2020</Safra><Balanca>LB</Balanca><Associado>000161</Associado><Loja>01</Loja><SerieNfProdutor>555</SerieNfProdutor><NumeroNfProdutor>555555555</NumeroNfProdutor><ChaveNFPe></ChaveNFPe><PlacaVeiculo>IQN9223</PlacaVeiculo><Tombador>1</Tombador><Obs>Teste WS para inclusao de carga de uva durante a safra</Obs><coletarAmostra>N</coletarAmostra><cadastroViticola1>04512</cadastroViticola1><Variedade1>9976           </Variedade1><Embalagem1>G</Embalagem1><cadastroViticola2>04513</cadastroViticola2><Variedade2>9976           </Variedade2><Embalagem2>G</Embalagem2>'

#$XML += '<Acao>RetTicketCargaSafra</Acao><Safra>2020</Safra><Balanca>LB</Balanca><Carga>3312</Carga><coletarAmostra>S</coletarAmostra><Senha>15</Senha>'

#$XML +=    '<Acao>MonitorProtheus</Acao>' #<Ambiente>sped</Ambiente><Porta>5060</Porta>'

#$XML +=    '<Acao>LiberacaoGerencialPV</Acao><Filial>01</Filial><Pedido>123456</Pedido>'

$XML += '</WSAlianca>'

# Executa e mostra resultado
$A = ''
$A = $proxy.INTEGRAWS($XML)
$A.RESULTADO
$A.MENSAGENS
#Set-Clipboard -Value $A.MENSAGENS

<#
# Formata XML para melhorar a visualizacao
# String Writer and XML Writer objects to write XML to string
$StringWriter = New-Object System.IO.StringWriter
$XmlWriter = New-Object System.XMl.XmlTextWriter $StringWriter 

# Default = None, change Formatting to Indented
$xmlWriter.Formatting = "indented" 

# Gets or sets how many IndentChars to write for each level in the hierarchy when Formatting is set to Formatting.Indented
$xmlWriter.Indentation = 4#$Indent
    
([xml]$A.MENSAGENS).WriteContentTo($XmlWriter) 
$XmlWriter.Flush();$StringWriter.Flush() 
$StringWriter.ToString()
#>

if ($A.MENSAGENS.Length -gt 20 -and $A.MENSAGENS.Substring(0,17) -eq '<monitorProtheus>')
{
    [xml] $monitor = $A.MENSAGENS
    $monitor.monitorProtheus.sessao | Out-GridView
}
