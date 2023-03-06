# html diff
07/Mar/2023


```python
import difflib
import sys

fromfile = "A.html"
tofile   = "B.html"
fromlines = open(fromfile, 'U').readlines()
tolines = open(tofile, 'U').readlines()

diff = difflib.HtmlDiff().make_file(fromlines,tolines,fromfile,tofile)

sys.stdout.writelines(diff)
```