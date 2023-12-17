try {
	Set-ItemProperty -Path "HKLM:\SYSTEM\ControlSet001\Control\CI\Policy" -Name "SkuPolicyRequired" -Value 0 -ErrorAction Stop
	$value = Get-ItemProperty -Path "HKLM:\SYSTEM\ControlSet001\Control\CI\Policy" -Name "SkuPolicyRequired" 
	Write-Host "Registry value for SkuPolicyRequired is now set to:" $value.SkuPolicyRequired
}
catch {
 Write-Host "Error occurred: $_"
}