# VirtualBox raw hd access
05/Mar/2023

```vboxmanage internalcommands createrawvmdk -filename "my-file.vmdk" -rawdisk \\.\PhysicalDrive<NUMBER_HERE>```

Check the drive number in Disk Management

Example:
```batch
C:\Program Files\Oracle\VirtualBox>vboxmanage internalcommands createrawvmdk -filename "C:/opt/vms/SATA1_CT1000MX500SSD.vmdk" -rawdisk \\.\PhysicalDrive1
RAW host disk access VMDK file C:/opt/vms/SATA1_CT1000MX500SSD.vmdk created successfully.
```
