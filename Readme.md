# ReadMe For YuZJLab LinuxMiniPrograms
## Copyright

These programs are designed to cut down time a bioinformatician spent on doing sys-admin work.

Copyright (C) 2019-2020 YU Zhejian

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program.  If not, see <https://www.gnu.org/licenses/>.

## Please Pay Attention

As we're developing programs mostly under Microsoft Windows, we **DO NOT** pay attention to file permissions. You can execute `git config core.filemode false` to make your own copy of repository ignore them as well.

## Installation

### General Guide
You can now execute `install.sh` to install all the programs for yourself. You can also run this script to change your settings to the defaults.

Detailed code:

```bash
git clone https://github.com/YuZJLab/LinuxMiniPrograms
cd LinuxMiniPrograms
chmod +x install.sh
./install.sh --all
```

### Dependencies

Package manager refers to software such as `apt` on Ubuntu Linux, `CYGWin installer` in CYGWin or  `ports` under FreeBSD.

The entire system needs `git` to be downloaded and installed. If there's no `git`, download a zipped archive from GitHub and use `scp` to transport it to your target machine. `git` can be installed by your package manager or by compiling its source code.

All documentations are written in `asciidoctor`.If you wish to compile them into Groff man, PDF, HTML and YuZJLab Usage, please install the following dependencies:

* `python` (Python3) can be installed by your package manager or `conda`.
* Ruby, at least `ruby-gems`, can be installed by your package manager.
* `Ruby gems` package `asciidoctor` and `asciidoctor-pdf` can be installed by `gem`.

To install all archive utilities in `autozip` series, please install the following packages:

* `zip` and `unzip` can be installed by your package manager or `conda`.
* `unrar` can be installed by your package manager but can be downloaded from https://www.rarlab.com/ in binary form.
* `p7zip` or `p7zip-full` can be installed by your package manager or `conda`.
* `rar` is property software, but can be downloaded from https://www.rarlab.com/ in binary form.
* `bgzip` is a part of `htslib` which is available from https://github.com/samtools/htslib. You may also install `htslib` by your package manager.

## Compatibility

* GNU/Linux distributions: Tested and fully supported.
* BSD and MacOS: Currently, the program does not support BSD and other BSD-based systems (such as MacOS). We're working on this in branch BSD. The source of these problems are due to different syntax of the following programs:

    * `ps` `in bin/pss`. Fixed.
    * `sed` in `install.sh`. Fixed.
    * The colouring support of `more` in programs that support `--more:[more]`. Not and will not be fixed. Please use `--more:cat` to get the right colour.
    * `xz` in `bin/autozip` `bin/autounzip`. Fixed.
    * `tar` in `bin/autozip` `bin/autounzip`. Fixed.
    * `ls` in `bin/pls` `lib/libfindpython` `installer.sh`. Fixed.

* CYGWin and Git Bash: Tested. We provide full support for CYGWin but some of the programs may fail on Git Bash.

    * `ps` in CYGWin's `bin/pss`. Not and will not be fixed. 

* Windows Subsystem of Linux: Have not been tested.

Please read the documents of each program to check if the program supports your system.

## Branches on GitHub

There are two main branches on GitHub: `master` and `NEW`. `master` branch is a stable releasing branch and `NEW` branch is cutting-edge developing branch. Other branches should be considered as unstable.

## Help & Documentation
After installation, you can execute `yldoc --list` to get a complete list of all available documentations and view them by using `yldoc [name]`. You can also find PDF, HTML and other documentation format in corresponding folder.

It is recommended to read the `LMP_basis` to know the basic configurations to Linux Mini Programs.