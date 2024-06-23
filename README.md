# CMFramework

GCC C-Make Framework (C/C++)

Welcome to my Framework. A place to help you better manage C/C++ software projects.

Public URL : [https://github.com/Longdao2/CMFramework](https://github.com/Longdao2/CMFramework "Click to connect")

---

# Introduction

CMFramework is a robust and versatile framework designed to streamline the management of C/C++ projects. It offers a comprehensive set of features that enable users to create, delete, import, export, and switch projects to a focused mode effortlessly. In focused mode, key functionalities include cleaning outputs, building projects, executing programs, debugging, running tests, generating test reports, code coverage reports, and static code analysis reports.

Leveraging the simplicity and power of makefile for project management, CMFramework ensures easy setup and maintenance. It integrates advanced algorithms to optimize performance across all tasks requested by the user, making it an indispensable tool for developers seeking efficiency and precision in their project workflows.

---

# Structure

##### 1. Structure of the Framework

- [doc](./doc/ "Click to connect") : stores documents for common use for every project.
- [project](./project/ "Click to connect"): manage all your projects. Note, I have provided a sample project "0" as a foundation for creating other projects. You force not to delete it. If deleted, you will not be able to use any of the features of the framework.
- [tool](./tool/ "Click to connect") : includes common libraries, and tools for creating test reports, ...
- [makefile](./makefile "Click to connect") : this is a file that manages all the backbone features to ensure the framework works. You also cannot customize this file.
- [make.sh](./make.sh "Click to connect") : This file allows you to run make commands for multiple projects at the same time.
- [version.txt](./version.txt "Click to connect") : This file records the current version and version history of the framework.

##### 2. Structure of Project in Framework

Take the example on the sample project "[0](./project/0/ "Click to connect")" provided. Note that you may not edit or delete this project. You need to create a new project and execute on it.

- [doc](./project/0/doc/ "Click to connect") : archives of documents of this project.
- [inc](./project/0/inc/ "Click to connect") : contains project header files.
- [dev](./project/0/dev/ "Click to connect") : contains the source files of the project developed for testing code coverage (.c .c{x}).
- [src](./project/0/src/ "Click to connect") : contains the source files of the project (.c .c{x} .o .s .S).
- [user_cfg.mk](./project/0/user_cfg.mk "Click to connect") : a makefile that allows users to configure paths and set some settings for each specific project.

**NOTE** : .c{x} includes : .cc .cp .cxx .cpp .c++ .CPP .C

---

# Command

##### 1. Note

+ % : project name
+ [%] : project or group name
+ {$} : variable(s) name in MAKE

##### 2. Command

| Command               | Description                                                                                                      |
| --------------------- | ---------------------------------------------------------------------------------------------------------------- |
| make setup            | Initialize (or re-initialize) the framework, clean up all dependencies of all projects                           |
| make info             | Print on the screen some information about the project                                                           |
| make quick (**make**) | **Default** - it's similar : <**make build run**> . Build quickly and run the executable file                    |
| make force            | It's similar : <**make clean build run**> . Clean the output, rebuild, and run the executable file               |
| make clean            | Clean all files in project output and report files in the "**doc**" folder (if any)                              |
| make build            | Used to compile source files into object files, then link them into an executable                                |
| make rebuild          | It's similar : <**make clean build**> . Clean the output and rebuild                                             |
| make run              | Run the executable already in the project                                                                        |
| make debug            | Debug the executable already in the project using GDB                                                            |
| make report           | Generate test or/and CCOV report after running the program (use the "**utest**" library)                         |
| make show_report      | Displays the previously generated report file (if any)                                                           |
| make analyze          | Perform static code analysis using PC-Lint                                                                       |
| make vsinit           | Configure VSCode so that the software links to the correct path                                                  |
| make move.%           | Move to new project (automatically create if it doesn't exist. "**response=Y**" allows creation without asking)  |
| make remove.[%]       | Remove an existing project or group                                                                              |
| make import.[%]       | Import a shared project or group from any CMFramework. "**zip=\<path\>**" will indicate the path to the zip file |
| make export.[%]       | Pack your project or group ready to share (stored in folder "**share**")                                         |
| make list             | Print to the screen the names of files and folders in the project (requires installation of "**tree**")          |
| make print.{$}        | Prints out the values of the variable(s) used inside MAKE files                                                  |

- **bash make.sh \<targets> ::: \<projects\>**
  + This command allows executing targets across multiple projects.
  + The targets of each project will be implemented one after another until the end.

##### 3. For Example

- move

```makefile
make move.hello_world
make move.tests/module1/module1_test_001
# Automatically created if this project is not available (response=Y/N)
make move.new_project response=Y
make move.tmp_project response=N
```

- remove

```makefile
make remove.hello_world  # project
make remove.tests/module1  # group
```

- import

```makefile
make import.new_project zip=C:/documents/test_001.zip  # project
make import.new_group zip=C:/documents/tests.zip  # group
```

- export

```makefile
make export.test_001  # project
make export.tests  # group
```

- print

```makefile
make print.CCOPTS
make print.SRC_DIRS.SRC_FILES.INC_DIRS
```

- bash make.sh \<targets\> ::: \<projects\>

```makefile
# Same [make] for current project
bash make.sh
# Same [make rebuild list] for current project
bash make.sh rebuild list
# Same [make] for test_001, test_002 and test_003
bash make.sh ::: test_001 test_002 test_003
# Same [make force report analyze] for test_001 and test_002
bash make.sh force report analyze ::: test_001 test_002
```

##### 4. Attention

All file paths are not allowed to contain spaces or special characters.

In any project, the project name and each source file name must be unique on every directory level to avoid conflicts when creating output files.

---

# Environment

##### 1. Toolchain GCC (required)

- Reference : [winlibs](https://winlibs.com "Click to connect")
- Download now : [gcc_13.2.0_w32](https://github.com/brechtsanders/winlibs_mingw/releases/download/13.2.0-16.0.6-11.0.0-ucrt-r1/winlibs-i686-posix-dwarf-gcc-13.2.0-llvm-16.0.6-mingw-w64ucrt-11.0.0-r1.zip "Click to connect")
- How to install : Download zip version, extract to any archive folder. Then add the path to "**bin**" and "**i686-w64-mingw32\bin**" to the "**PATH**" environment variable.

##### 2. Cygwin (required)

- Reference : [cygwin](https://www.cygwin.com "Click to connect")
- Download now : [cygwin-x86_64](https://www.cygwin.com/setup-x86_64.exe "Click to connect")
- How to install :
  + Click to open the setup file, select "**Install from Internet**" then click "**Next**" by default.
  + At table "**Select Packages**". View is "**Full**". And enter the following tools in the search box : "**make**", "**cygstart**", "**tree**", "**zip**", "**unzip**".
  + In the "**New**" column, select the latest version for each tool. Then click "**Next**" to install the above tools.
  + Then add the path to "**bin**", "**sbin**" and "**usr\sbin**" to the "**PATH**" environment variable.
  + **NOTE** : If you have Git installed on your PC. Please move Cygwin's paths above Git's paths in Enviroments.
  + Finally, open Cygwin as administrator. Type in "**cygserver-config**" > **Enter** >... Type "**yes**". Wait for the run to finish and restart your PC.

##### 3. Python (optional)

- Attention : If you want to generate **CCOV reports**, you need to install this tool.
- Reference : [python](https://www.python.org/downloads "Click to connect")
- How to install :

  + Download the setup file and install by default.
  + Add the path from the installation directory to the environment's "**PATH**" variable.
  + Run the following command to install **Gcovr** (we are sure version **7.2** is stable):

  ```powershell
  python -m pip install gcovr==7.2
  ```

##### 4. PC-Lint Plus (optional)

- Attention : If you want to generate **static code analysis reports**, you need to install this tool.
- Reference : [pc-lint_plus](https://pclintplus.com/downloads "Click to connect")
- How to install :
  + Download zip version, extract to any archive folder.
  + Then add the path from the installation directory to the environment's "**PATH**" variable.
  + Go [here](https://pclintplus.com/evaluate "Click to connect") to register your license, then add the **lic** file to the installation directory of PC-Lint.
  + **NOTE** : This is a paid tool. We are sure that version **2.2** works stably.

##### 5. VSCode (recommended)

- Reference : [vscode](https://code.visualstudio.com/download "Click to connect")
- How to install :
  + Download the setup file and install by default.
  + Install the following extensions to work more efficiently : "**C/C++**", "**C/C++ Themes**", "**C/C++ Extension Pack**", "**Code Runner**", "**Doxygen Documentation Generator**", "**Gdb Syntax**".
  + Enable Code-runner's "**Run In Terminal**" option in settings if you have it installed.

---

# User Manual

Read more user instructions here : [user_manual](./doc/user_manual.docx)

---

© 2023-2024. Belongs to [Louisvn](https://louisvn.com "Click to connect")

---
