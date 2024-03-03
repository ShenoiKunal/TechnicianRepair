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

#Print Disk and Partition Numbers
Write-Output "`nPartition: $partitionNumber `nDisk: $harddiskNumber"

#Create Diskpart Script as a temp file
$diskpartScriptPath = [System.IO.Path]::GetTempFileName()
"list Disk `nsel disk $harddiskNumber `nList part `n sel part $partitionNumber" | Set-Content -Path $diskpartScriptPath


#Run Diskpart with script and capture output
$diskPartOutput = & diskpart /s $diskpartScriptPath

#Print Diskpart Output without breaking formatting
$diskPartOutput | ForEach-Object {
	Write-Output $_
}


