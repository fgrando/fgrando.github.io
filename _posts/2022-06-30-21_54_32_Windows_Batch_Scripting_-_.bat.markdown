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
{% endhighlight %}


List all files in a directory:
{% highlight batch %}
FOR /f tokens^=* %%i in ('where .:*')DO (
	ECHO/ Path: %%~dpi ^| Name: %%~nxi
)

FOR /f tokens^=* %%i in ('where /r %FOLDER% *.txt')DO (
	ECHO/ Path: %%~dpi ^| Name: %%~nxi
)
{% endhighlight %}


