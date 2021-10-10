---
layout: post
title:  "Get datetime info on Windows CLI"
date:   2021-10-10 11:43:01 -0300
categories: template model
author: fgrando
---
{% assign data = "/assets/2021-10-10-11_43_01_Get_datetime_info_on_Windows_CLI.data/" %}

The date and time settings in use can be listed using PowerShell:

{% highlight powershell %}
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
{% endhighlight %}

This info is also available in the GUI executing `Intl.cpl`
