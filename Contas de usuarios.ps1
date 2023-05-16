# Scripts para bloquear e desbloquear contas do A.D.

Enter-PSSession -ComputerName SrvADM

Get-ADUser robert.koch

Disable-ADAccount dwt2

Enable-ADAccount robert.koch

Set-ADAccountPassword -Identity dwt2 -Reset
