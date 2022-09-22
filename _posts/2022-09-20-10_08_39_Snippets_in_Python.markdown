---
layout: post
title:  "Snippets in Python"
date:   2022-09-20 10:08:39 -0300
categories: python programming
author: fgrando

---
{% assign data = "/assets/2022-09-20-10_08_39_Snippets_in_Python.data/" %}

Running command with timeout in windows:
{% highlight python %}
import sys
import os
import time
import subprocess

def run_command(cmd_line, timeout_s, verbose=False):
  cmd = cmd_line.split()
  result = False
  pid = None
  try:
    p = subprocess.Popen(cmd, start_new_session=True,
                         stdout=subprocess.PIPE,
                         stderr=subprocess.PIPE,
                         shell=True)
    pid = p.pid
    if verbose: print(f'PID "{pid}" for "{cmd_line}" timeout is "{timeout_s}" seconds')
    (out,err) = p.communicate(timeout=timeout_s)
    ret_code = p.returncode
    result = (ret_code == 0)
    if verbose: print(f'out: {out}\nerr: {err}\nret: {ret_code}')
  except subprocess.TimeoutExpired:
    if verbose: print(f'FAIL: Timeout reached. Killing PID {pid}')
    subprocess.call(['taskkill', '/F', '/T', '/PID', str(pid)])
  except Exception as e:
    if verbose: print(f'FAIL: {e}')
  finally:
    return result

cmds = [
    "DIR C:\\",                 # this command works sucessfuly
    "notepad.exe newfile.txt",  # this command triggers the timeout
    "cmdnotfound",              # this command fails
]

for c in cmds:
    print("\nStarting test")
    ret = run_command(c, 5, True)
    if ret:
        print('SUCCESS')
    else:
        print('FAILURE')
{% endhighlight %}



Simple arguments check:
{% highlight python %}
import sys
import os

def show_usage_and_fail():
    print(f'Usage: {sys.argv[0]} <arg1>')
    sys.exit(1)

if len(sys.argv) < 2:
    print(f'Only {len(sys.argv)} arguments provided')
    show_usage_and_fail()

ARG = sys.argv[1]

if not os.path.isfile(ARG):
    print(f'ARG is not a file')
    show_usage_and_fail()

if not os.path.isdir(ARG):
    print(f'ARG is not a folder')
    show_usage_and_fail()
{% endhighlight %}
