# GCC and __attribute__((packed)) in Linux & Windows
05/Mar/2023

This program gives different outputs in windows and linux, even when compiled with similar same GCC versions.
Fortunately, it is not a bug and just a matter of compiler flags.

```c
#include <stdio.h>
#include <stdint.h>

struct __attribute__((packed)) {
        uint16_t flag:10;
        uint8_t data:6;
} st2Byte;

struct __attribute__((packed)) {
        uint8_t flag:2;
        uint8_t data:6;
} st1Byte;

struct __attribute__((packed)) {
        uint32_t data:16;
        uint16_t flag:8;
        uint16_t view:8;
} st4Byte;


int main(void)
{
    int expected = 2;
    int size = sizeof(st2Byte);
    printf("Expected: %d, got: %d - %s\n", expected, size, (size == expected ? "PASS" : "FAIL"));

    expected = 1;
    size = sizeof(st1Byte);
    printf("Expected: %d, got: %d - %s\n", expected, size, (size == expected ? "PASS" : "FAIL"));

    expected = 4;
    size = sizeof(st4Byte);
    printf("Expected: %d, got: %d - %s\n", expected, size, (size == expected ? "PASS" : "FAIL"));
    return 0;
}
```

| GCC                                      | Output                                                                                |
| ---------------------------------------- | ------------------------------------------------------------------------------------- |
| gcc (Ubuntu 9.3.0-17ubuntu1~20.04) 9.3.0 | Expected: 2, got: 2 - PASS<br>Expected: 1, got: 1 - PASS<br>Expected: 4, got: 4 - PASS|
| gcc (MinGW-W64 x86_64-posix-seh, built by Brecht Sanders) 9.4.0 | Expected: 2, got: 3 - FAIL<br>Expected: 1, got: 1 - PASS<br>Expected: 4, got: 6 - FAIL|

In order to get the same results, we must specify if the struct attribute will be `ms_struct` or `gcc_struct`.

They resulted in different sizes because in Windows the default is `ms_struct`. See [x86 Type Attributes](https://gcc.gnu.org/onlinedocs/gcc-7.4.0/gcc/x86-Type-Attributes.html).
We can achieve the same results using the following flag:

`gcc test.c --mno-ms-bitfields`

| GCC                                      | Output                                                                                |
| ---------------------------------------- | ------------------------------------------------------------------------------------- |
| gcc (Ubuntu 9.3.0-17ubuntu1~20.04) 9.3.0 | Expected: 2, got: 2 - PASS<br>Expected: 1, got: 1 - PASS<br>Expected: 4, got: 4 - PASS|
| gcc (MinGW-W64 x86_64-posix-seh, built by Brecht Sanders) 9.4.0 | Expected: 2, got: 2 - PASS<br>Expected: 1, got: 1 - PASS<br>Expected: 4, got: 4 - PASS|




