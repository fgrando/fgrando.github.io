---
layout: post
title:  "List connected USB devices in Windows"
date:   2021-09-10 06:53:27 -0300
categories: template model
author: fgrando
---
{% assign data = "/assets/2021-09-10-06_53_27_List_connected_USB_devices_W10.data/" %}

Windows PowerShell command:
{% highlight powershell %}
Get-PnpDevice -PresentOnly | Where-Object {$_. InstanceId -match '^USB'}
{% endhighlight %}
