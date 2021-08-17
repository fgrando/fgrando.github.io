---
layout: post
title:  "Developer command prompt"
date:   2021-08-17 16:31:53 -0300
categories: template model
author: fgrando
---
{% assign data = "/assets/2021-08-17-16_31_53_Developer_command_prompt.data/" %}

I needed to run QEMU for a project, but did not want to change my `%PATH%` variable adding the QEMU instalation path just for a temporary thing.

My solution was to create a `qemu-cli.bat` that launches a prompt with `%PATH%`:

{% highlight batch %}
cmd /K set PATH=%PATH%;"C:\Program Files\qemu"
{% endhighlight %}
