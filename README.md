## Modular FFmpeg builder
This builder will create a shared [FFmpeg](http://ffmpeg.org) build with statically linked libraries. It's a multi-file build script, where each library is responsible for its compilation process and its dependencies. The compilation process of a library is defined in its own file. This makes the builder easy to maintain.

### Options
```
-h,  --help               print this help.
-i,  --prefix             installation directory.
-p,  --profile            target os profile, see below.
-l,  --libs               space separated list of libraries to include into FFmpeg [optional].
```

### Profiles

| Profile                               | Toolchain                           |
| :------------------------------------ | :---------------------------------- |
| linux-x86 <br> linux-x86_64           | Linux native                        |
| mac-x86_64                            | OS X native                         |
| mingw-msys-x86 <br> mingw-msys-x86_64 | MSYS MinGW on Windows               |
| mingw-x86 <br> mingw-x86_64           | MinGW, e.g. on Linux                |
| msvc-15-x86 <br> msvc-15-x86_64       | MSYS using Visual Studio on Windows |

For `mingw-msys` and `msvc-15` profiles refer to the [Initial setup of MSYS2](https://github.com/opcodevoid/ffmpeg-builder/wiki/Initial-setup-of-MSYS2) wiki.

### Examples
OS X 64-bit build
```
$ ./ffmpeg-builder -p mac-x86_64 -i /usr/local/ffmpeg -l "opus vpx x264 x265"
```

Windows 64-bit build with [MSYS2](http://msys2.github.io) and [Visual Studio](https://www.visualstudio.com) toolchain.
```
$ ./ffmpeg-builder -p msvc-15-x86_64 -i /usr/local/ffmpeg-win-64 -l "opus vpx"
```

Windows 32-bit build with [Mingw-w64](http://mingw-w64.org) cross compiler on a Unix host.
```
$ ./ffmpeg-builder -p mingw-x86 -i /usr/local/ffmpeg-win-32 -l "opus vpx"
```

### Todos
- [ ] ARM support
- [ ] Add option to create a static build
