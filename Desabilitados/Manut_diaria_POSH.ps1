# Tarefa agendada no Windows

Write-host "Processo iniciado em " (Get-Date -Format "yyyyMMdd HH:mm:ss")

$DataHora = Get-Date -Format yyyyMMdd-HHmmss

# Copia backups de anotações do CintaNotes do C: para a rede
$Compactador = "C:\Util\7za.exe"
$PastaBackups = 'Z:\Informatica\Doc nao tecnicos\Backup_CintaNotes_Robert'
if (!(Test-Path -Path $PastaBackups))
{
	New-Item -Force -ItemType Directory -Path $PastaBackups
}
copy-item C:\util\CintaNotes_3_12\backup\*.* $PastaBackups -Verbose -Force

& $Compactador a -r -tzip $PastaBackups\Scripts c:\util\scripts\*.ps1



# Backup pasta local fontes Protheus
$PastaBackups = 'C:\Backups'
if (!(Test-Path -Path $PastaBackups))
{
	New-Item -Force -ItemType Directory -Path $PastaBackups
}
& $Compactador a -r -tzip $PastaBackups\Fontes_locais_Protheus_$DataHora C:\FontesProtheus\FontesProtheus\*.*


Write-host "Processo concluido em " (Get-Date -Format "yyyyMMdd HH:mm:ss")
