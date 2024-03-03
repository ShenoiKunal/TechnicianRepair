# Get info for reagentc (WinRE Location)
$FullString = reagentc /info | Select-String partition

Write-Output "$FullString"

# Create pattern for Disk # and Partition #
$regexPattern = 'harddisk(\d+)\\.*partition(\d)\\'

#Check for string pattern match
if ($FullString -match $regexPattern){
	# Extract Numbers
	$partitionNumber = $matches[2]
	$harddiskNumber = $matches[1]
}

#Print Disk and Partition Numbers
Write-Output "Part: $partitionNumber `nDisk: $harddiskNumber"

#Create Diskpart Script
$diskpartScriptPath = "C:\diskpart_script.txt"
"list Disk `nsel disk $harddiskNumber `nList part `n sel part $partitionNumber" | Set-Content -Path $diskpartScriptPath

#Run Diskpart with script and capture output
$diskPartOutput = & diskpart /s $diskpartScriptPath

Write-Output "$diskPartOutput"