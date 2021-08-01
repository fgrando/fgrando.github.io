---
layout: post
title:  "Getting timestamp"
date:   2020-06-11 17:34:25 -0300
categories: timestamp python bat cpp c
author: fgrando
---
{% assign data = "/assets/2020-06-11-17:34:25_timestamp.data/" %}


Getting timestamp in `python`:

{% highlight python %}
import datetime

now = datetime.datetime.now()
timestamp = now.strftime('%Y-%m-%d_%H:%M:%S'.format(now))
print (timestamp)
{% endhighlight %}


Getting timestamp in `C`:

{% highlight c %}
#include <time.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

int timestamp(char *buff, int len, int precise)
{
        int ret = 0;
        time_t time_now = 0;
        struct tm timeinfo = { 0 };

        time(&time_now);
        localtime_s(&timeinfo, &time_now);
    memset(buff, 0x0, len);

    if (precise)
        {
        ret = _snprintf_s(buff, len, "%04d-%02d-%02d.%02d:%02d:%02d",
                        (timeinfo.tm_year + 1900), (timeinfo.tm_mon + 1), timeinfo.tm_mday,
                        timeinfo.tm_hour, timeinfo.tm_min, timeinfo.tm_sec);
        }
        else
        {
        ret = _snprintf_s(buff, len, "%02d:%02d:%02d",
                        timeinfo.tm_hour, timeinfo.tm_min, timeinfo.tm_sec);
        }
        return ret;
}
{% endhighlight %}


Getting timestamp in `batch`:

{% highlight batch %}
@echo off
SETLOCAL
CALL :GetTimestamp now
echo timestamp = %now%
EXIT /b %ERRORLEVEL%

:GetTimestamp
FOR /F %%A IN ('WMIC OS GET LocalDateTime ^| FINDSTR \.') DO @SET B=%%A
SET y=%B:~0,4%
SET mo=%B:~4,2%
SET d=%B:~6,2%
SET h=%B:~8,2%
SET m=%B:~10,2%
SET s=%B:~12,2%
SET timestamp=%d%-%mo%-%y% %h%:%m%:%s%
SET "%~1=%d%-%timestamp%"
EXIT /B 0
{% endhighlight %}
