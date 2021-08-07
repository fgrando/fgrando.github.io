---
layout: post
title:  "Convert all PDFs to TXTs"
date:   2021-08-07 13:30:57 -0300
categories: template model
author: fgrando
---
{% assign data = "/assets/2021-08-07-13_30_57_Convert_all_PDFs_to_TXTs.data/" %}

This is a bat script that converts every PDF file in the current directory to a text file.
It is necessary that [pdf2text][p2tbin] is available in the PATH.


I use [ag][silversearcher] a lot, but unfortunatelly it does not parse PDF files, being unable not search words inside the PDF files. So I convert my PDF files to text and then [ag][silversearcher] can search its contents.


{% highlight bat %}
@echo off
for /r %%i in (*.pdf) do (
	echo %%i
	pdftotext "%%i" "%%i.txt"
)
{% endhighlight %}

[silversearcher]: https://github.com/k-takata/the_silver_searcher-win32
[p2tbin]: https://www.xpdfreader.com/pdftotext-man.html
