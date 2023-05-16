# Dicas:
# https://cknotes.com/pop3-headers-and-attachment-info/
# https://deaksoftware.com.au/articles/using_pop3_in_powershell/


#Dica extraida de https://www.cogmotive.com/blog/powershell-scripts/pop-mailbox-using-powershell
$e_mails_a_baixar_edifrete = 0
$socket = new-object System.Net.Sockets.TcpClient('srvmail.novaalianca.coop.br', 7110)
$stream = $socket.GetStream() 
$writer = new-object System.IO.StreamWriter($stream) 
$buffer = new-object System.Byte[] 1024 
$encoding = new-object System.Text.AsciiEncoding 
start-sleep 1
$resposta = ''
while($stream.DataAvailable){  
	$read = $stream.Read($buffer, 0, 1024)    
	$resposta += ($encoding.GetString($buffer, 0, $read))  
}
write-host $resposta
if ($resposta.ToString().Substring(0, 3) -eq '+OK'){
    write-host 'USER'
    $writer.WriteLine("USER fretesimport") 
    $writer.Flush()
    start-sleep 1
    $resposta = ''
    while($stream.DataAvailable){  
	    $read = $stream.Read($buffer, 0, 1024)    
	    $resposta += ($encoding.GetString($buffer, 0, $read))  
    }
    write-host $resposta
    if ($resposta.ToString().Substring(0, 3) -eq '+OK'){
        write-host 'PASS'
        $writer.WriteLine("PASS Alianca14")
        $writer.Flush()
        start-sleep 1
        $resposta = ''
        while($stream.DataAvailable){  
	        $read = $stream.Read($buffer, 0, 1024)    
	        $resposta += ($encoding.GetString($buffer, 0, $read))  
        }
        write-host $resposta
        if ($resposta.ToString().Substring(0, 3) -eq '+OK'){
            Write-Host 'STAT'
            $writer.WriteLine("STAT")
            $writer.Flush()
            start-sleep 1
            $resposta = ''
            while($stream.DataAvailable){  
	            $read = $stream.Read($buffer, 0, 1024)    
	            $resposta += ($encoding.GetString($buffer, 0, $read))  
            }
            write-host $resposta
            write-host $resposta.split(" ")[1] 'mensagens no servidor'
            if ($resposta.ToString().Substring(0, 3) -eq '+OK'){
                Write-Host 'QUIT'
                $writer.WriteLine("QUIT")
                $writer.Flush()
                start-sleep 1
                $resposta = ''
                while($stream.DataAvailable){  
	                $read = $stream.Read($buffer, 0, 1024)    
	                $resposta += ($encoding.GetString($buffer, 0, $read))  
                }
                write-host $resposta
                if ($resposta.ToString().Substring(0, 3) -eq '+OK'){
                }else{
                    write-host 'Resposta do comando QUIT nao ok'
                }
            }else{
                write-host 'Resposta do comando STAT nao ok'
            }
        }else{
            write-host 'Resposta do comando PASS nao ok'
        }
    }else{
        write-host 'Resposta do comando USER nao ok'
    }
}
else{
    write-host 'Resposta inicial nao OK'
}
# Close the streams 	
$writer.Close() 
$stream.Close() 
