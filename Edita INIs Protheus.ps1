
Get-ChildItem s:\protheus12\bin*\appserver* -Recurse -Filter appserver*.ini | Foreach-Object{& 'C:\Program Files (x86)\Notepad++\notepad++.exe' $_.FullName}
#Get-ChildItem s:\protheus12\bin*\appserver* -Recurse -Filter console.log | Foreach-Object{& 'C:\Program Files (x86)\Notepad++\notepad++.exe' $_.FullName}
