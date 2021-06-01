# fake - **f**ast cm**ake**
A stupid CMake wrapper.
⚠ Still WIP. ⚠

## Behaviour
The script searches for the `CMakeLists.txt` file. If it is not found
the script searches in the `$UP_TRAVERSAL` parent dir(s).

If the file is found, this directory is treated as the projects root
directory.

With this behaviour the script can be called from projects child dir(s).

## Usage
```
================ Help ================
Usage: fake.ps1 <command>
Commands:
    cmake   runs cmake in target dir ($FAKE_CMAKE_FLAGS)
    build   runs cmake --build .\target
    status  prints some status information
    clean   del .\target
    <bin>   executes <bin> in dir 'target' ($FAKE_EXEC_HOST)
    help    show this screen
```

## Powershell Version
The powershell version searches for a script called `fake.conf.ps1` in
the same folder where the `CMakeLists.txt` file is located.  If it is found
it is executed.

This can be used to set some environment variables (or do it manually):
1. `$FAKE_CMAKE_FLAGS`: flags appended to the `cmake ..\.` command
2. `$FAKE_EXEC_HOST`: <bin> are copied to the host and executed remotely

Tip: You can also set `$env:CC=...` with the `fake.conf.ps1` file.

## Bash Version
Analogous to `Powershell Version` with `fake.conf.sh` instead

