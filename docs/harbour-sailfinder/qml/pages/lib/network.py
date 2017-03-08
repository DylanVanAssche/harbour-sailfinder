# -*- coding: utf-8 -*-
"""
@title: Sailfinder network manager
@description: Monitors the network status on your Sailfish OS device

@author: Dylan Van Assche
"""

import pyotherside
import os

def connection(python=False):
    os.chdir("/run/state/providers/connman/Internet/") #Connman state DIR
    
    File = open("NetworkState", 'r') # Read network state
    connection_status = File.readlines()
    File.close()
    
    File = open("NetworkType", 'r') # Read network type
    connection_type = File.readlines()
    File.close()
    
    File = open("SignalStrength", 'r') # Read network signal strength
    signal_strength = File.readlines()
    File.close()
    
    File = open("NetworkName", 'r') # Read network name
    connection_name = File.readlines()
    File.close()
    
    homeDir = os.path.expanduser("~")
    os.chdir(homeDir + "/.config/harbour-sailfinder")
    
    # When we call this function from within Python code we only need to return the status of our connection as a boolean
    if(python):
        if(connection_status[0] == "connected"):
            return True
        else:
            return False
    else:
        pyotherside.send('network', connection_status, connection_type, connection_name, signal_strength)
        
def launch_SFOS_connection_dialog():
    os.system("dbus-send --print-reply --type=method_call --dest=com.jolla.lipstick.ConnectionSelector /  com.jolla.lipstick.ConnectionSelectorIf.openConnection string:")
