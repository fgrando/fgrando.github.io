---
layout: post
title:  "console injection"
date:   2022-01-04 22:36:24 -0300
categories: template model
author: fgrando
---
{% assign data = "/assets/2022-01-04-22_36_24_console_injection.data/" %}

Adding binary arguments through stdin:

{% highlight sh %}
 echo -ne "blabla\xde\xad\xbe\xef" | ./ch13 
{% endhighlight %}
