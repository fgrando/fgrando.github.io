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


{% highlight sh %}
#!/bin/bash
NAME="autorun-exec"
RET=0

already_running() {
        counter=0
        pids=$(pgrep -d " " $NAME)
        for p in $pids; do
                (( counter=counter+1 ))
                echo $counter: running with PID $p
        done
        RET=$counter
}


# Abort if we are running already
already_running
if [ $RET -gt 0 ]; then
        echo Exit: $NAME is already running.
        exit
fi


echo Starting process...
sleep 300
{% endhighlight %}