# CMFramework

GCC C-Make Framework (C/C++)

Welcome to my Framework. A place to help you better manage C/C++ software projects.

Public URL : [https://github.com/Longdao2/CMFramework](https://github.com/Longdao2/CMFramework "Click to connect")

---

# Introduction

CMFramework is a robust and versatile framework designed to streamline the management of C/C++ projects. It offers a comprehensive set of features that enable users to create, delete, import, export, and switch projects to a focused mode effortlessly. In focused mode, key functionalities include cleaning outputs, building projects, executing programs, debugging, running tests, generating test reports, code coverage reports, and static code analysis reports.

Leveraging the simplicity and power of makefile for project management, CMFramework ensures easy setup and maintenance. It integrates advanced algorithms to optimize performance across all tasks requested by the user, making it an indispensable tool for developers seeking efficiency and precision in their project workflows.

---

# Command

> **NOTE**
>
> + % : project name
> + [%] : project or group name
> + {$} : variable(s) name in MAKE

| Command                     | Description                                                                                                            |
| --------------------------- | ---------------------------------------------------------------------------------------------------------------------- |
| make setup                  | Initialize (or re-initialize) the framework, clean up all dependencies of all projects                                 |
| make info                   | Print on the screen some information about the project                                                                 |
| make quick (**make**) | **Default** - it's similar : <**make build run**> . Build quickly and run the executable file                                |
| make force                  | It's similar : <**make clean build run**> . Clean the output, rebuild, and run the executable file                     |
| make clean                  | Clean all files in project output and report files in the "**doc**" folder (if any)                                    |
| make build                  | Used to compile source files into object files, then link them into an executable                                      |
| make rebuild                | It's similar : <**make clean build**> . Clean the output and rebuild                                                   |
| make run                    | Run the executable already in the project                                                                              |
| make debug                  | Debug the executable already in the project using GDB                                                                  |
| make report                 | Generate test or/and CCOV report after running the program (use the "**utest**" library)                               |
| make show_report            | Displays the previously generated report file (if any)                                                                 |
| make analyze                | Perform static code analysis using PC-Lint                                                                             |
| make vsinit                 | Configure VSCode so that the software links to the correct path                                                        |
| make move.%                 | Move to new project (automatically create if it doesn't exist. "**response=Y**" allows creation without asking)        |
| make remove.[%]             | Remove an existing project or group                                                                                    |
| make import.[%]             | Import a shared project or group from any CMFramework. "**zip=\<path\>**" will indicate the path to the zip file       |
| make export.[%]             | Pack your project or group ready to share (stored in folder "**share**")                                               |
| make list                   | Print to the screen the names of files and folders in the project (requires installation of "**tree**")                |
| make print.{$}              | Prints out the values of the variable(s) used inside MAKE files                                                        |

- **bash make.sh \<targets> ::: \<projects\>**
  + This command allows executing targets across multiple projects.
  + The targets of each project will be implemented one after another until the end.

> **For example**
>
> - move
>
> ```makefile
> make move.hello_world
> make move.tests/module1/module1_test_001
> # Automatically created if this project is not available (response=Y/N)
> make move.new_project response=Y
> make move.tmp_project response=N
> ```
>
> - remove
>
> ```makefile
> make remove.hello_world  # project
> make remove.tests/module1  # group
> ```
>
> - import
>
> ```makefile
> make import.new_project zip=C:/documents/test_001.zip  # project
> make import.new_group zip=C:/documents/tests.zip  # group
> ```
>
> - export
>
> ```makefile
> make export.test_001  # project
> make export.tests  # group
> ```
>
> - print
>
> ```makefile
> make print.CCOPTS
> make print.SRC_DIRS.SRC_FILES.INC_DIRS
> ```
>
> - bash make.sh \<targets\> ::: \<projects\>
>
> ```makefile
> # Same [make] for current project
> bash make.sh
> # Same [make rebuild list] for current project
> bash make.sh rebuild list
> # Same [make] for test_001, test_002 and test_003
> bash make.sh ::: test_001 test_002 test_003
> # Same [make force report analyze] for test_001 and test_002
> bash make.sh force report analyze ::: test_001 test_002
> ```

---

# Attention

All file paths are not allowed to contain spaces or special characters.

In any project, the project name and each source file name must be unique on every directory level to avoid conflicts when creating output files.

---

© 2023-2024. Belongs to [Louisvn](https://louisvn.com "Click to connect")

---
