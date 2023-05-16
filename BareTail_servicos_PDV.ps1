#Lado direito da tela
c:\Util\baretail.exe --window-position 0   0   750 380 S:\Protheus12\bin\APSERVER_RETAGUARDA\console.log
c:\Util\baretail.exe --window-position 0   381 750 380 S:\Protheus12\bin\appserver_WS_PDV\console.log

# Lado esquerdo
c:\util\baretail.exe --window-position 751 0   750 252 S:\Protheus12\bin\appserver_retaguarda_PDV_teste\console.log
c:\util\baretail.exe --window-position 751 253 750 252 S:\Protheus12\bin\appserver_WS_PDV_teste\console.log
c:\util\baretail.exe --window-position 751 507 750 252 'C:\totvspdv\Protheus\bin\appserver - PDV\console.log'

#[System.Windows.Forms.Screen]::AllScreens
# https://www.reddit.com/r/PowerShell/comments/jmtxpx/multiple_monitors_identifying_and_manipulating/


# Logs app manutencao
c:\util\baretail.exe --window-position 1361 0   380 252 S:\protheus12\bin\appserver_WS_MntNG\console.log
c:\util\baretail.exe --window-position 1361 381 380 252 S:\Protheus12\protheus_data\logs\u_mntng.log
