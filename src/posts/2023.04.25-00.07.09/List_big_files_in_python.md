# List big files in python
25/Apr/2023

```py
import os
import sys

ONE_MB=1048576 #bytes
THRESH=ONE_MB*50 # 1MB*N

def get_size_bytes(filename):
    st = os.stat(filename)
    return st.st_size

if len(sys.argv) < 2:
    print(f"usage: {sys.argv[0]} root")
    exit(1)

for currentpath, folders, files in os.walk(sys.argv[1]):
    for file in files:
        full_path = os.path.join(currentpath, file)
        bytes_size = get_size_bytes(full_path)
        if bytes_size > THRESH:
            print(f"{full_path}\t{(bytes_size/ONE_MB):0.1f} mb")

```