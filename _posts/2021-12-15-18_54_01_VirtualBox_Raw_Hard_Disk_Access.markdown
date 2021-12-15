---
layout: post
title:  "VirtualBox Raw Hard Disk Access"
date:   2021-12-15 18:54:01 -0300
categories: template model
author: fgrando
---
{% assign data = "/assets/2021-12-15-18_54_01_VirtualBox_Raw_Hard_Disk_Access.data/" %}

```vboxmanage internalcommands createrawvmdk -filename "my-file.vmdk" -rawdisk \\.\PhysicalDrive<NUMBER_HERE>```

Check the drive number in Disk Management

Example:
{% highlight bat %}
C:\Program Files\Oracle\VirtualBox>vboxmanage internalcommands createrawvmdk -filename "C:/opt/vms/SATA1_CT1000MX500SSD.vmdk" -rawdisk \\.\PhysicalDrive1
RAW host disk access VMDK file C:/opt/vms/SATA1_CT1000MX500SSD.vmdk created successfully.
{% endhighlight %}

