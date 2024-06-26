# Get info for reagentc (WinRE Location)
$FullString = reagentc /info | Select-String partition

#Write-Output "Reagentc Information: $FullString`n"  # Uncomment to debug

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
"List disk `nsel disk $harddiskNumber `nList part `n sel part $partitionNumber" | Set-Content -Path $diskpartScriptPath


#Run Diskpart with script and capture output
$diskPartOutput = & diskpart /s $diskpartScriptPath

#Create regex pattern for Windows Partition #
$winRegexPattern = 'Partition (\d+)\s*Primary'

#Create regex pattern to check for GPT
$gptRegexPattern = 'Disk\s+'+$harddiskNumber+'.*\*'

#Create regex pattern for List Disk Header
$listDiskHeaderPattern = 'Disk\s+###'

#Boolean for GPT
$gpt = "false"

#Print Diskpart Output without breaking formatting
$diskPartOutput | ForEach-Object {
	if ($_ -match $winRegexPattern){
		$winPartitionNumber = $matches[1]
	}
	if ($_ -match $gptRegexPattern){
		$gpt = "true"
		$humanCheckGPT = $_ # May cause false match if drive is DYN, Print to have human confirm
	}
	if ($_ -match $listDiskHeaderPattern){
		$listDiskHeader = $_
	}
	
	#Write-Output $_  # Uncomment to Debug
}

#Print Disk and Partition Numbers
Write-Output "`nRecovery`n______________`nPartition: $partitionNumber `nDisk: $harddiskNumber"

#Print Disk and Partition Numbers
Write-Output "`nWindows`n______________`nPartition: $winPartitionNumber `nDisk: $harddiskNumber"

#Print DiskPart Disk Line to confirm GPT
Write-Output "`n$listDiskHeader`n$humanCheckGPT"

do {
	# Disable Reagentc
	reagentc /disable
		if ($?) {
		    Write-Output "Reagentc disabled"
		    $disableWorked = "succeeded"
		} else {
		    Write-Output "Reagentc disable failed"
		    $disableWorked = "failed"
		}
	
	#Have user confirm action before completing tasks
	Write-Output "`nThis will shrink Partition $winPartitionNumber by 300MB, Delete Partition $partitionNumber, and allocate the space to a new WinRE partition. GPT tested: $gpt"
	Write-Output "`nThe operation to disable reagentc $disableWorked"
	$userInput = Read-Host "Do you want to continue (Y/N)"
	$userInput = $userInput.ToUpper()
	
	if ($userInput -eq 'Y') {
	Write-Output "Proceeding..."
		
		#If Drive is GPT
		if ($gpt -eq "true"){
			# Create new Diskpart Script as temp file
			$diskpartPERFORM = [System.IO.Path]::GetTempFileName()
			"sel disk $harddiskNumber `nList part `nsel part $winPartitionNumber `nshrink desired=300 minimum=300`nsel part $partitionNumber `ndelete partition override `ncreate partition primary id=de94bba4-06d1-4d40-a16a-bfd50179d6ac `ngpt attributes=0x8000000000000001 `nformat quick fs=ntfs label=`"Win RE`"" | Set-Content -Path $diskpartPERFORM
		}
		else { # If Drive is MBR
			# Create new Diskpart Script as temp file
			$diskpartPERFORM = [System.IO.Path]::GetTempFileName()
			"sel disk $harddiskNumber `nList part `nsel part $winPartitionNumber `nshrink desired=300 minimum=300`nsel part $partitionNumber `ndelete partition override `ncreate partition primary id=27 `nformat quick fs=ntfs label=`"Win RE`"" | Set-Content -Path $diskpartPERFORM
		}
		
#		Get-Content -Path $diskpartPERFORM | Write-Output  # Uncomment to debug
		
		$operationOutput =  & diskpart /s $diskpartPERFORM
		
		#Print Diskpart Output without breaking formatting
		$operationOutput | ForEach-Object {
			Write-Output $_  # Uncomment to Debug
		}
		
		break
	}
	elseif ($userInput -eq 'N') {
	Write-Output "Operation aborted by the user"
	reagentc /enable
	exit
	}
	else {
	Write-Output "Invalid input. Please enter 'Y' to continue or 'N' to abort."
	}
}while ($true)

# Enable Reagentc
reagentc /enable