$ordens = 7250160869,7250160870,7300160636,7250160989,7200330908,7350160844,7350160847,7200330911,7200330940,7350160876,7200330978,7200330943,7200330978,7200330977,7350160900,7250160989,7250160908,7250160907,7300160662,5950093241,4500316688

foreach ($o in $ordens)
{
    #write-output $o
    Get-ChildItem -recurse | Select-String -pattern $o  | group path | select name
    #move-item @(Get-ChildItem -recurse | Select-String -pattern $o | group path | select name) .\a\
}
# Get-ChildItem -recurse | Select-String -pattern "7250160869" | group path | select name

move-item C:\temp\reimp_mercador\pd201610270847612.txt C:\temp\reimp_mercador\a
move-item C:\temp\reimp_mercador\pd201610270847613.txt C:\temp\reimp_mercador\a
move-item C:\temp\reimp_mercador\pd201610270847614.txt C:\temp\reimp_mercador\a
move-item C:\temp\reimp_mercador\pd201611170947676.txt C:\temp\reimp_mercador\a
move-item C:\temp\reimp_mercador\pd201611030847629.txt C:\temp\reimp_mercador\a
move-item C:\temp\reimp_mercador\pd201611030847630.txt C:\temp\reimp_mercador\a
move-item C:\temp\reimp_mercador\pd201611030847631.txt C:\temp\reimp_mercador\a
move-item C:\temp\reimp_mercador\pd201611030847632.txt C:\temp\reimp_mercador\a
move-item C:\temp\reimp_mercador\pd201611100947647.txt C:\temp\reimp_mercador\a
move-item C:\temp\reimp_mercador\pd201611100947648.txt C:\temp\reimp_mercador\a
move-item C:\temp\reimp_mercador\pd201611170947674.txt C:\temp\reimp_mercador\a
move-item C:\temp\reimp_mercador\pd201611100947649.txt C:\temp\reimp_mercador\a
move-item C:\temp\reimp_mercador\pd201611170947674.txt C:\temp\reimp_mercador\a
move-item C:\temp\reimp_mercador\pd201611170947673.txt C:\temp\reimp_mercador\a
move-item C:\temp\reimp_mercador\pd201611170947677.txt C:\temp\reimp_mercador\a
move-item C:\temp\reimp_mercador\pd201611170947676.txt C:\temp\reimp_mercador\a
move-item C:\temp\reimp_mercador\pd201611030847634.txt C:\temp\reimp_mercador\a
move-item C:\temp\reimp_mercador\pd201611030847633.txt C:\temp\reimp_mercador\a
move-item C:\temp\reimp_mercador\pd201611030847635.txt C:\temp\reimp_mercador\a
move-item C:\temp\reimp_mercador\pd201610282117617.txt C:\temp\reimp_mercador\a
