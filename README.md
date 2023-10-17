# CMake Modules

Include some modules in CMake.

## Usage

### Common Usage

Normally, the modules can be referred by add to the project module folders and include the needed module.

```bash
git clone --depth 1 https://github.com/msclock/cmake-modules.git cmake/cmake-modules
```

Add to CMAKE_MODULE_PATH and refer the modules.
```cmake
list(APPEND CMAKE_MODULE_PATH cmake/cmake-modules)
include(module/path/without/.cmake/suffix)
```

### Using registry

There presents a cmake registry facilitates the cmake modules to refer. An example is [here](https://github.com/msclock/cpp-scaffold).

## Modules

The modules here are divided into different categories: configuration, build, installation and testing. That means relative modules are applied to relative stages of cmake.

Basically, modules in the repository are collected from opensouces, but maybe modified to enhance generic usage.
