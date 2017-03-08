# -*- coding: utf-8 -*-
"""
Created on Wed Feb  8 15:46:56 2017

@author: Dylan Van Assche
@title: Cache class
@description: Cache class for Sailfinder manages the caching of the data
"""

#Sailfinder modules
import filemanager, constants, logger

#Cache objects need to be created first in order to collect the files on that specific time at runtime
class _CacheOperation(object):
    def __init__(self):
        self.cache_dir = filemanager.FileSystem()
        
    def clear(self, extension=constants.filemanager.extension["JSON"], working_dir=constants.filemanager.path["XDG_CACHE_HOME"], keep_latest=False):
        for index, file in enumerate(self.data):
            current_file = filemanager.File(file, extension, working_dir)
            if keep_latest and not current_file.aged(constants.filemanager.age["7_DAYS"]): #Keep latest files
                logger.log_to_file.debug("File " + current_file.working_dir + "/" + current_file.name + " to young to delete")
                break;
            if current_file.exists():
                current_file.delete()
            
class Logger(_CacheOperation):
    def __init__(self):
        logger.log_to_file.debug("LOGGER CACHE", insert_line=True)
        super().__init__()
        self.data = self.cache_dir.list_files(constants.filemanager.path["LOG"])
    
    def clear(self):
        logger.log_to_file.debug("Clearing logger data")
        super().clear(constants.filemanager.extension["LOG"], constants.filemanager.path["LOG"], True)
            
class Recommendations(_CacheOperation):
    def __init__(self):
        logger.log_to_file.debug("RECS CACHE", insert_line=True)
        super().__init__()
        self.data = self.cache_dir.list_files(constants.filemanager.path["RECS"])
        
    def clear(self):
        logger.log_to_file.debug("Clearing recommendations data")
        super().clear(constants.filemanager.extension["JPG"], constants.filemanager.path["RECS"])
        super().clear(constants.filemanager.extension["JSON"], constants.filemanager.path["RECS"])
        
class Updates(_CacheOperation):
    def __init__(self):
        logger.log_to_file.debug("UPDATES CACHE", insert_line=True)
        super().__init__()
        self.data = self.cache_dir.list_files(constants.filemanager.path["UPDATES"])
        
    def clear(self):
        logger.log_to_file.debug("Clearing updates data")
        super().clear(constants.filemanager.extension["JSON"], constants.filemanager.path["UPDATES"])
        
class Matches(_CacheOperation):
    def __init__(self):
        logger.log_to_file.debug("MATCHES CACHE", insert_line=True)
        super().__init__()
        self.data = self.cache_dir.list_files(constants.filemanager.path["MATCHES"])
        
    def clear(self):
        logger.log_to_file.debug("Clearing matches data")
        super().clear(constants.filemanager.extension["JPG"], constants.filemanager.path["MATCHES"])
        
class Profile(_CacheOperation):
    def __init__(self):
        logger.log_to_file.debug("PROFILE CACHE", insert_line=True)
        super().__init__()
        self.data = self.cache_dir.list_files(constants.filemanager.path["PROFILE"])
        
    def clear(self):
        logger.log_to_file.debug("Clearing profile data")
        super().clear(constants.filemanager.extension["JSON"], constants.filemanager.path["PROFILE"])
        super().clear(constants.filemanager.extension["JPG"], constants.filemanager.path["PROFILE"])
        
class Meta(_CacheOperation):
    def __init__(self):
        logger.log_to_file.debug("META CACHE", insert_line=True)
        super().__init__()
        self.data = ["meta"]
        
    def clear(self):
        logger.log_to_file.debug("Clearing meta data")
        super().clear(constants.filemanager.extension["JSON"], constants.filemanager.path["XDG_CACHE_HOME"])

class Authentication(_CacheOperation):
    def __init__(self):
        logger.log_to_file.debug("AUTH CACHE", insert_line=True)
        super().__init__()
        self.data = self.cache_dir.list_files(constants.filemanager.path["AUTH"])
        
    def clear(self):
        logger.log_to_file.debug("Clearing authentication data")
        super().clear(constants.filemanager.extension["TXT"], constants.filemanager.path["AUTH"])
        super().clear(constants.filemanager.extension["JSON"], constants.filemanager.path["AUTH"])