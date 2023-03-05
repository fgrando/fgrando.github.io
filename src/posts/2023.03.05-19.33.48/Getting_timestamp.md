# Getting timestamp
05/Mar/2023

## Getting timestamp in `python`:

```python
import datetime

now = datetime.datetime.now()
timestamp = now.strftime('%Y-%m-%d_%H:%M:%S'.format(now))
print (timestamp)
```

## Getting timestamp in `C`:

```c
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
```


## Getting timestamp in `batch`:

```batch
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
```

## The date and time settings in use can be listed using PowerShell:
```powershell
PS C:\Users\fgrando> (get-culture).DateTimeFormat | fl -property *


AMDesignator                     : AM
Calendar                         : System.Globalization.GregorianCalendar
DateSeparator                    : -
FirstDayOfWeek                   : Sunday
CalendarWeekRule                 : FirstDay
FullDateTimePattern              : dddd, d MMMM, yyyy HH:mm:ss
LongDatePattern                  : dddd, d MMMM, yyyy
LongTimePattern                  : HH:mm:ss
MonthDayPattern                  : MMMM d
PMDesignator                     : PM
RFC1123Pattern                   : ddd, dd MMM yyyy HH':'mm':'ss 'GMT'
ShortDatePattern                 : dd-MMM-yy
ShortTimePattern                 : HH:mm
SortableDateTimePattern          : yyyy'-'MM'-'dd'T'HH':'mm':'ss
TimeSeparator                    : :
UniversalSortableDateTimePattern : yyyy'-'MM'-'dd HH':'mm':'ss'Z'
YearMonthPattern                 : MMMM yyyy
AbbreviatedDayNames              : {Sun, Mon, Tue, Wed...}
ShortestDayNames                 : {Su, Mo, Tu, We...}
DayNames                         : {Sunday, Monday, Tuesday, Wednesday...}
AbbreviatedMonthNames            : {Jan, Feb, Mar, Apr...}
MonthNames                       : {January, February, March, April...}
IsReadOnly                       : False
NativeCalendarName               : Gregorian Calendar
AbbreviatedMonthGenitiveNames    : {Jan, Feb, Mar, Apr...}
MonthGenitiveNames               : {January, February, March, April...}
```

This info is also available in the GUI executing `Intl.cpl`