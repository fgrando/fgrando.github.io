# Bash snippets
05/Mar/2023


## Check if the variable is empty
```bash
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
```

## Check running process before starting it again:
```bash
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
```

# Colors
Set in bash PS1 variable like this:

```bash
export PS1="\e[47m[\t]\e[0m \u@\[\e[0m\]\[\e[01;37m\]\h\[\e[0m\]\[\e[00;37m\]\\$ \w\n\[\e[0m\]"
```
Sources:
- https://wiki.archlinux.org/index.php/Color_Bash_Prompt
- http://bashrcgenerator.com/
