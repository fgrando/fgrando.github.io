# build windows .exe in linux
07/Mar/2023


```bash
sudo apt-get install mingw-w64

# 32 bits
i686-w64-mingw32-gcc -o main32.exe main.c

# 64 bits
x86_64-w64-mingw32-gcc -o main64.exe main.c
```
