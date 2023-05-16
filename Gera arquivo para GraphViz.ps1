GET-PROCESS -name Microsoft.Photos | Stop-Process
GET-PROCESS -name mspaint | Stop-Process
& C:\Util\graphviz-2.38\release\bin\dot.exe -Tjpg C:\util\graphviz-2.38\teste.dot -o C:\util\graphviz-2.38\teste.jpg
start C:\util\graphviz-2.38\teste.jpg
