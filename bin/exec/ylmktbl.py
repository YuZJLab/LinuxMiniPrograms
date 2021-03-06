#!/usr/bin/env python
# YLMKTBL.py V3
from LMP_Pylib.libisopt import *
from LMP_Pylib.libmktbl import *
from LMP_Pylib.libstr import *

sstr = []
for sysarg in sys.argv[1:]:
	if isopt(sysarg):
		if sysarg == '-h' or sysarg == '--help':
			os.system('yldoc ylmktbl')
			exit(0)
		elif sysarg == '-v' or sysarg == '--version':
			print('Version 3 in Python')
			exit(0)
		else:
			warnh("Option " + sysarg + " invalid")
			exit(1)
	else:
		sstr.append(sysarg)
mktbl(sstr[0])
