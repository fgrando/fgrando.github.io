---
layout: post
title:  "Linux Bash Scripting - .sh"
date:   2022-09-14 22:33:31 -0300
categories: programming bash sh linux
author: fgrando
---
{% assign data = "/assets/2022-09-14-22_33_31_Linux_Bash_Scripting_-_.sh.data/" %}


Useful batch snippets


{% highlight sh %}
#!/bin/bash
ROOTDIR=$PWD

MYARG=$1

fail() {
  echo FAILED
  exit 1
}

if [ -z "$MYARG" ]; then 
  echo Arg is empty
  fail
fi

if [ -d $MYARG ]; then
  echo Arg is a folder
  fail
fi

run_some_command
if [ $? -ne 0 ]; then
  echo Command failed
  fail
fi

exit 0
{% endhighlight %}
