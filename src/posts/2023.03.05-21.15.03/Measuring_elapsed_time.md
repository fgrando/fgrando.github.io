# Measuring elapsed time
05/Mar/2023

## Using C++ 11

```cpp
#include <chrono>

std::chrono::steady_clock::time_point begin = std::chrono::steady_clock::now();

cout << "put busy operation here" << endl;

std::chrono::steady_clock::time_point end = std::chrono::steady_clock::now();
std::cout << "elapsed: "
            << std::chrono::duration_cast<std::chrono::nanoseconds> (end - begin).count()
            << " ns" << std::endl;

```
