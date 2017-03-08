"""
Created on Fri Jan  6 19:02:42 2017

@author: Dylan Van Assche
@title: Init module
@description: Init Sailfinder module, the logger needs to be initialized before anything else is done
"""

import platform, sys

if platform.machine() == "armv7l":
	sys.path.append("./backend/lib/armv7l/")
elif platform.machine() == "i486":
	sys.path.append("./backend/lib/i486/")
else:
	print("[CRITICAL] Platform NOT supported: " + platform.machine())
	sys.exit()

