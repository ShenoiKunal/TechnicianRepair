# Get info for reagentc (WinRE Location)
$FullString = reagentc /info | Select-String partition

Write-Output "Reagentc Information: $FullString`n"

# Create pattern for Disk # and Partition #
$regexPattern = 'harddisk(\d+)\\.*partition(\d)\\'

#Check for string pattern match
if ($FullString -match $regexPattern){
	# Extract Numbers
	$partitionNumber = $matches[2]
	$harddiskNumber = $matches[1]
}


#Create Diskpart Script as a temp file
$diskpartScriptPath = [System.IO.Path]::GetTempFileName()
"sel disk $harddiskNumber `nList part `n sel part $partitionNumber" | Set-Content -Path $diskpartScriptPath


#Run Diskpart with script and capture output
$diskPartOutput = & diskpart /s $diskpartScriptPath

#Create regex pattern for Windows Partition #
$winRegexPattern = 'Partition (\d+)\s*Primary'

#Print Diskpart Output without breaking formatting
$diskPartOutput | ForEach-Object {
	if ($_ -match $winRegexPattern){
		$winPartitionNumber = $matches[1]
	}
	Write-Output $_
}

#Print Disk and Partition Numbers
Write-Output "`nRecovery`n______________`nPartition: $partitionNumber `nDisk: $harddiskNumber"

#Print Disk and Partition Numbers
Write-Output "`nWindows`n______________`nPartition: $winPartitionNumber `nDisk: $harddiskNumber"


#Have user confirm action before completing tasks

