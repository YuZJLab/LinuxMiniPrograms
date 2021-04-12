#!/usr/bin/env python
'''
To test whether a URL is valid.
'''
# VERSION=1.1
import os
import re
import sys

sshstr = re.compile(r"ssh://([^@\s]+@){0,1}([^@:\s]+)(:[0-9]+){0,1}(/[^@:]*)")
httpstr = re.compile(r"http(s){0,1}://([^@:\s]+)(:[0-9]+){0,1}(/[^@:]*)")
gitstr = re.compile(r"git://([^@:\s]+)(:[0-9]+){0,1}(/[^@:]*)")
scpstr = re.compile(r"([^@\s]+@){0,1}([^@:\s]+):(/[^@:]*)")
def main():
    if sshstr.match(sys.argv[1]) or gitstr.match(sys.argv[1]) or \
            scpstr.match(sys.argv[1]) or os.path.isdir(sys.argv[1]):
        sys.exit(0)
    else:
        sys.exit(1)

if __name__ == '__main__':
    main()
