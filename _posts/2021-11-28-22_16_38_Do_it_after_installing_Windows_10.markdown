---
layout: post
title:  "Do it after installing Windows 10"
date:   2021-11-28 22:16:38 -0300
categories: windows10 install
author: fgrando
---

# Free more disk space avoiding hibernation:
Open cmd as administrator;
{% highlight bat %}
powercfg -h off
{% endhighlight %}

# Uninstall bloatware
PowerShell as administrator:
{% highlight ps %}
Get-AppxPackage -AllUsers | Remove-AppxPackage
{% endhighlight %}

Put back the Microsoft store:
{% highlight ps %}
Get-AppxPackage -allusers Microsoft.WindowsStore | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register "$($_.InstallLocation)\AppXManifest.xml"}
{% endhighlight %}

Now it is a good time to install the camera and calculator apps back (from MS store).
As image viewer you can use FastStone [https://www.faststone.org/]

# Configuring updates
Open Group Policy Editor (`gpedit.msc`):
- Computer Configuration -> Administrative Templates -> Windows Components -> Windows Update -> Configure Automatic Updates -> 2 - Notify for download and notify for install.
- Computer Configuration -> Administrative Templates -> Windows Components -> Windows Update -> Turn on Software Notifications -> Enabled.
- Computer Configuration -> Administrative Templates -> Windows Components -> Windows Update -> Allow Automatic Updates immediate installation -> Disabled.
- Computer Configuration -> Administrative Templates -> Windows Components -> Windows Update -> Turn on recommended updates via Automatic Updates -> Enabled.
- Computer Configuration -> Administrative Templates -> Windows Components -> Application compatibility -> Turn off application telemetry.
- Computer Configuration -> Administrative Templates -> Windows Components -> Data collection and preview builds -> Allow telemetry - 0 (security).

# Sources
Special thanks to Dr. Rodrigo Cadore and Dr. Ramon Fernandes for those tips.
