# CMake Error

- キャッシュされているビルドディレクトリと異なるディレクトリで`$ cmake ..`を実行
- [CMake error when building OpenCV - CMakeLists not match](https://stackoverflow.com/questions/35784700/cmake-error-when-building-opencv-cmakelists-not-match)

```
$ cmake ..
CMake Error: The current CMakeCache.txt directory ... is different than the directory ... where CMakeCache.txt was created. This may result in binaries being created in the wrong place. If you are not sure, reedit the CMakeCache.txt

CMake Error: The source ... does not match the source ... used to generate cache. Re-run cmake with a different source directory.

$ cd /path/to/<src>
$ rm -rf build
$ mkdir build
$ cd build
$ cmake ..
```
