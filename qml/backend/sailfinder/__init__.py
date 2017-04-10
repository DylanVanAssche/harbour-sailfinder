"""
Created on Fri Jan  6 19:02:42 2017

@author: Dylan Van Assche
@title: Init module
@description: Init Sailfinder module
"""

#Sailfinder modules
import logger, filemanager, constants

#Init our cache directories
for directory in constants.filemanager.cache_dirs:
    current_dir = filemanager.Directory(directory, constants.filemanager.path["XDG_CACHE_HOME"])
    current_dir.create()

#Init our config directories        
for directory in constants.filemanager.config_dirs:
    current_dir = filemanager.Directory(directory, constants.filemanager.path["XDG_CONFIG_HOME"])
    current_dir.create()

#Init our data directories
for directory in constants.filemanager.data_dirs:
    current_dir = filemanager.Directory(directory, constants.filemanager.path["XDG_DATA_HOME"])
    current_dir.create()
    
logger.log_to_file.debug("All directories and files initialized")
