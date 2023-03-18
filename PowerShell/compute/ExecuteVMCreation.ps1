$n = @('web1', 'linux2')
$n | ForEach-Object { New-VirtualMachine -Name $_ -Path (Join-Path -Path E:\hyper-v\virtualMachines\ -ChildPath $_) -switchName "datacenter" -MemoryStartUpBytes 4GB }
$n | ForEach-Object { set-VMConfigurationSettings -VMName $_ -media ubuntu.iso }