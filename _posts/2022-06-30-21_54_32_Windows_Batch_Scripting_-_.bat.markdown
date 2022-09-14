---
layout: post
title:  "Windows Batch Scripting - .bat"
date:   2022-06-30 21:54:32 -0300
categories: programming batch bat windows win32
author: fgrando
---
{% assign data = "/assets/2022-06-30-21_54_32_Windows_Batch_Scripting_-_.bat.data/" %}

Useful batch snippets


Get the script start directory:
{% highlight batch %}
ECHO Current Directory = %~dp0
ECHO Object Name With Quotations=%0
ECHO Object Name Without Quotes=%~0
ECHO Bat File Drive = %~d0
ECHO Full File Name = %~n0%~x0
ECHO File Name Without Extension = %~n0
ECHO File Extension = %~x0

{% endhighlight %}



Python temporary env
{% highlight batch %}

SET PYENV="%~dp0\tempy"
SET PYTMP"%~dp0\tempy\Scripts\python"
SET PIPTMP"%~dp0\tempy\Scripts\pip"

python -m venv %PYENV%
%PIPTMP% freeze

%PYTMP% -V
{% endhighlight %}

Usual labels for GOTO
{% highlight batch %}
SET STARTDIR="%~dp0"
SET ARG1=%1
SET ARG2=%2

IF "%FOLDER%" == "" (
    ECHO Missing argument.
)

CALL somescript.bat
IF NOT "%ERRORLEVEL%" == "0" (
    ECHO Failed to run command
    GOTO FAIL
)

GOTO END

:END
ECHO Done!
EXIT /B0

:SHOW_USAGE_AND_FAIL
ECHO Usage: %0 <argmument>
GOTO FAIL

:FAIL
ECHO FAILED!
EXIT /B 1

{% endhighlight %}


Kill a task
{% highlight batch %}
FOR /F "TOKENS=1,2,* delims==, " %%a IN ('TASKLIST /FI "WindowTitle -eq %NAME% /NH /FO CSV') DO (
    SET PID_FOUND=%%b
    ECHO Kill %NAME% %%b
    TASKKILL /PID %%b /F
)
{% endhighlight %}


Check if a file exists:
{% highlight batch %}
IF EXIST %filepath% (
    ECHO exists!
) ELSE (
    ECHO not found!
)

IF NOT EXIST %filepath% (
    ECHO not found!
)

IF NOT EXIST "C:\Program Files\7-Zip\7z" (
    WHERE 7z
    IF "%ERRORLEVEL%" == "1" (
        ECHO 7zip not found!
    )
)
{% endhighlight %}



List all files in a directory:
{% highlight batch %}
FOR /F tokens^=* %%i IN ('where .:*')DO (
	ECHO/ Path: %%~dpi ^| Name: %%~nxi
)

FOR /F tokens^=* %%i IN ('where /r %FOLDER% *.txt')DO (
	ECHO/ Path: %%~dpi ^| Name: %%~nxi
)
{% endhighlight %}



Checked mounted drives with subst:
{% highlight batch %}
FOR /F "delims=\" %%i IN ('SUBST')DO (
    IF "%%i" == "X:" (
        ECHO Drive X is already mounted
    )
)

FOR /f tokens^=* %%i in ('where /r %FOLDER% *.txt')DO (
	ECHO/ Path: %%~dpi ^| Name: %%~nxi
)
{% endhighlight %}

