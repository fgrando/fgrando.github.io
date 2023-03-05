# Convert PDF to Text
05/Mar/2023

This is a bat script that converts every PDF file in the current directory to a text file.
It is necessary that [pdf2text][p2tbin] is available in the PATH.


I use [ag][silversearcher] a lot, but unfortunatelly it does not parse PDF files, being unable not search words inside the PDF files. So I convert my PDF files to text and then [ag][silversearcher] can search its contents.


```batch
@echo off
for /r %%i in (*.pdf) do (
	echo %%i
	pdftotext "%%i" "%%i.txt"
)
```

[silversearcher]: https://github.com/k-takata/the_silver_searcher-win32
[p2tbin]: https://www.xpdfreader.com/pdftotext-man.html