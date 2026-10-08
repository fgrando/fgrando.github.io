# cygwin notes
08/Oct/2026

# Stuck cygwin processes

```bat
:: 1. See what is holding cygwin1.dll
tasklist /m cygwin1.dll

:: 2. Stop Cygwin services, if any are installed
net stop cygserver 2>nul
net stop sshd 2>nul

:: 3. Kill everything using the DLL, including child trees
taskkill /f /t /fi "MODULES eq cygwin1.dll"

:: 4. Confirm nothing is left
tasklist /m cygwin1.dll
```