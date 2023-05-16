# Script para monitorar alguns logs mais criticos

# Monitor Dell: 1920 * 1200
# Monitor do notebook: 1366 * 768
# baretail           -wp left top width height file
C:\util\baretail.exe -wp 1921 0   1366  250    S:\Protheus12\protheus_data\logs\u_rbatch.log
C:\util\baretail.exe -wp 1921 245 1366  250    S:\Protheus12\protheus_data\logs\ws_alianca.log
C:\util\baretail.exe -wp 1921 500 1366  250    S:\Protheus12\protheus_data\logs\u_mntng.log

#1920+1366
