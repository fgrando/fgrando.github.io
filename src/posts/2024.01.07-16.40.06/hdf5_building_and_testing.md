# hdf5 building and testing
07/Jan/2024

## Windows with MinGW
Let's try to build using MinGW, although not officially supported.

### 1. Create a local workspace folder
`mkdir C:\workspace && cd C:\workspace\hdf5build`

The root dir for our tests is folder `C:\workspace\hdf5build`.

### 2. Get the sources
To this test I got [CMake-hdf5-1.10.9.zip](CMake-hdf5-1.10.9.zip)

Unzip to the workspace folder.

Create another folder called `install` to be the final location of the binaries

### 3. Check your path
MinGW  `mingw32-make`, `gcc` and the other bins should be reachable from the terminal (test this now before proceeding).

So far the dir looks like this
```
C:\workspace\hdf5build>dir
 Volume in drive C has no label.
 Volume Serial Number is 98B5-97B1

 Directory of C:\workspace\hdf5build

07/01/2024  00:40    <DIR>          CMake-hdf5-1.10.9
06/03/2023  22:42        34.826.532 CMake-hdf5-1.10.9.zip
07/01/2024  09:59    <DIR>          install
```
### 4. Starting build...
Enter the code folder: `cd CMake-hdf5-1.10.9`

Create the build folder and cd into it: `mkdir build && cd build`

Run cmake:
```
cmake -G "MinGW Makefiles" -DCMAKE_BUILD_TYPE:STRING=Release -DHDF5_BUILD_FORTRAN:BOOL=OFF -DHDF5_BUILD_JAVA:BOOL=OFF -DCMAKE_INSTALL_PREFIX:PATH=C:\workspace\hdf5build\install\HDF5 DHDF5_ENABLE_SZIP_SUPPORT:BOOL=OFF -DHDF5_ENABLE_Z_LIB_SUPPORT:BOOL=OFF  -DBUILD_TESTING:BOOL=ON -DHDF5_BUILD_TOOLS:BOOL=ON ..\hdf5-1.10.9
```

Run `mingw32-make` to build

Run `mingw32-make test` to build and run the self tests. In my case 3 tests failed... I will install anyway for now
```
99% tests passed, 6 tests failed out of 2071

Total Test time (real) = 259.42 sec

The following tests FAILED:
          2 - H5TEST-testhdf5-base (Failed)
          7 - H5TEST-cache_api (Failed)
         23 - H5TEST-dt_arith (Failed)
         86 - H5TEST-err_compat (Failed)
         87 - H5TEST-error_test (Failed)
        1649 - H5DUMP-tfloatsattrs (Failed)
```

Run `mingw32-make install` to install

Result: [install-MinGW-hdf5-1.10.9.zip](install-MinGW-hdf5-1.10.9.zip)


## Windows with Visual Studio
No need to build, just get prebuilt from the release page https://github.com/HDFGroup/hdf5/releases
