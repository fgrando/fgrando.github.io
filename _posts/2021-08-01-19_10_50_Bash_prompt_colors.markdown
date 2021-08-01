---
layout: post
title:  "Linux Bash prompt colors"
date:   2021-08-01 19:10:50 -0300
categories: bash linux
author: fgrando
---

{% assign data = "/assets/2021-08-01-19_10_50_Bash_prompt_colors.data/" %}

Set in bash PS1 variable like this:

{% highlight sh %}
export PS1="\e[47m[\t]\e[0m \u@\[\e[0m\]\[\e[01;37m\]\h\[\e[0m\]\[\e[00;37m\]\\$ \w\n\[\e[0m\]"
{% endhighlight %}

Sources:

https://wiki.archlinux.org/index.php/Color_Bash_Prompt

http://bashrcgenerator.com/
