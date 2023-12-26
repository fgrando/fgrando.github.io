# List file size in disk
26/Dec/2023

## List all files bigger than size in a given path
```
import os
import sys

def run(path, minsize = 0):
    for root, directories, files in os.walk(path):
        for name in files:
            fullpath = os.path.join(root, name)
            try:
                filesize = os.path.getsize(fullpath)
                if filesize >= minsize:
                    print(f'{filesize:>11} {fullpath}')
            except OSError as e:
                print(f'cannot read {name}: {e}')
            except Exception as e:
                print(f'ignoring {name}: {e}')

if __name__ == '__main__':
    if len(sys.argv) < 2:
        print(f'usage:\n\t{sys.argv[0]} <root path> [minimum size e.g.: 1M]')
        exit(0)

    root = os.path.abspath(sys.argv[1])
    size = 0
    # if the user provided a minimum size, get the value in bytes
    if len(sys.argv) > 2:
        filesize = sys.argv[2]
        if filesize.upper().endswith('K'):
            size = int(filesize.replace('K',''))
            size = size * 1000
        elif filesize.upper().endswith('M'):
            size = int(filesize.replace('M',''))
            size = size * 1000 * 1000
        elif filesize.upper().endswith('G'):
            size = int(filesize.replace('G',''))
            size = size * 1000 * 1000 * 1000
        else:
            try:
                size = int(filesize)
            except Exception as e:
                print(f'failed to convert minimum size: {e}')
                exit(0)

    run(root, size)
```