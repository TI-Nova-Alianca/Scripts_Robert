$logfile = 's:\protheus12\bin\appserver_slave2\console.log';
$logstream = [System.IO.File]::Open($logfile, "Open", "Read", "ReadWrite")  # Informa que OS OUTROS processos podem abrir o arquivo para gravacao.
$newstreamreader = New-Object System.IO.StreamReader $logstream
while (($readeachline =$newstreamreader.ReadLine()) -ne $null)
{
    if ($readeachline.Contains('WARNING - THREAD MEMORY UP TO'))
    {
        Write-Host $readeachline
    }
    if ($readeachline.Contains('Used memory average'))
    {
        Write-Host $readeachline
    }
}
$logstream.Dispose()
$newstreamreader.Dispose()


