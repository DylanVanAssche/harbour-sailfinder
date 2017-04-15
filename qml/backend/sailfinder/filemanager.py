# -*- coding: utf-8 -*-
"""
Created on Sat Jan  7 16:54:41 2017

@author: Dylan Van Assche
@title: Filemanager for Sailfinder
@description: Filemanager class which works around the Jolla Store restriction for filepaths.
@test: test/filemanager_test.py
"""

#Sailfinder modules
#import logger
import constants, logger
#Python modules
import os, json, datetime, time, shutil, atexit


"""
File:
    * Read -> Read file
    * Write -> Write file, creates the file if it doesn't exist
    * Delete -> Delete file
"""   
class File(object):
    """
    __init__:
        * Name -> Name of the file without extension
        * Extension -> Extension of the file
        * Working_dir -> Working directory where we want to put the file
        
    DEFAULT ARGUMENTS:
        * Working_dir = XDG_CACHE_HOME -> Caching is necessary all the time
    """   
    def __init__(self, name, extension=constants.filemanager.extension["JSON"], working_dir=constants.filemanager.path["XDG_CACHE_HOME"], create_working_dir=True):
        if not os.path.exists(working_dir) and create_working_dir:
                os.makedirs(working_dir) # Create the dir if it doesn't exist        
        self.name = name
        self.working_dir = working_dir
        self.extension = extension

    """
    Read:
        * Read a file from the working directory with given name
    """       
    def read(self, binary=False):
        if binary:
            return self._execute_file_operation("", constants.filemanager.operation["READ_BINARY"])
        else:
            return self._execute_file_operation("", constants.filemanager.operation["READ"])

    """
    Write:super(self.__class__, self).__init__(name, extension, working_dir) # Import the init function from our super class File
        print "Logfile init complete, you can find the log file under: " + self.working_dir + "/" + self.name + self.extension
        * Write a file from the working directory with given name
    """       
    def write(self, data, binary=False):
        if binary:
            return self._execute_file_operation(data, constants.filemanager.operation["WRITE_BINARY"])
        else:
            return self._execute_file_operation(data, constants.filemanager.operation["WRITE"])
    
    """
    Append:
        * Append data to a file from the working directory with given name
    """       
    def append(self, data, binary=False):
        if binary:
            return self._execute_file_operation(data, constants.filemanager.operation["APPEND_BINARY"])
        else:
            return self._execute_file_operation(data, constants.filemanager.operation["APPEND"])

    """
    Delete:
        * Delete a file from the working directory with given name
    """       
    def delete(self):
        try:
            old_working_dir = os.getcwd()
            os.chdir(self.working_dir)
            os.remove(self.name + self.extension)
            logger.log_to_file.debug("Deleting file: " + self.working_dir + "/" + self.name + self.extension + " OK")
        except (OSError, IOError, FileNotFoundError):
            logger.log_to_file.trace("Deleting file: " + self.working_dir + "/" + self.name + self.extension + " failed")
        finally:
            os.chdir(old_working_dir)

    """
    Exists:
        * Check if a file exists
    """                 
    def exists(self):
        try:
            old_working_dir = os.getcwd()
            os.chdir(self.working_dir)
            exists = os.path.isfile(self.name + self.extension)
            os.chdir(old_working_dir)
            return exists
        except (OSError, IOError):
            logger.log_to_file.debug("Searching for file: " + self.working_dir + "/" + self.name + self.extension + " failed")
            return False
        finally:
            os.chdir(old_working_dir)        

    """
    Aged:
        * Determine if the file is older then a certain time
    """                 
    def aged(self, age=constants.filemanager.age["30_MIN"]):
        try:
            old_working_dir = os.getcwd()
            os.chdir(self.working_dir)
            modified = os.path.getmtime(self.name + self.extension)
            logger.log_to_file.debug("Getting last modified from file: " + self.working_dir + "/" + self.name + self.extension + " OK")
            if time.time() - float(modified) > age:
                return True
            else:
                return False
        except (OSError, IOError):
            logger.log_to_file.error("Getting last modified from file: " + self.working_dir + "/" + self.name + self.extension + " failed")
        finally:
            os.chdir(old_working_dir)
            
    """
    Execute the file operation:
        * Go the the file working directory
        * Check if the file is a JSON file then we need a special module
        * Excute the file operation as given in the variable 'operation'
        * Return data if the operation was a read, in any other case return True when OK or False when FAILED
        * File operations can fail use TRY/EXCEPT
    """          
    def _execute_file_operation(self, data, operation):
        logger.log_to_file.debug("Executing file operation '" + operation + "' on file: '" + self.working_dir + "/" + self.name + self.extension + "'")
        try:
            if not os.path.exists(self.working_dir):
                os.makedirs(self.working_dir) # Create the dir if it doesn't exist
            if self.extension == constants.filemanager.extension["JSON"]:
                with open(self.working_dir + "/" + self.name + self.extension, operation) as myfile:
                    if data and len(data):
                        json.dump(data, myfile, indent=4, sort_keys=True, separators=(',', ':'))
                    else:
                        data_read = json.load(myfile)
                        logger.log_to_file.debug("File read OK")
                        return data_read
            else:
                with open(self.working_dir + "/" + self.name + self.extension, operation) as myfile:
                    if data and len(data):
                        myfile.write(data)
                    else:
                        file_list = []
                        for line in myfile:
                            file_list.append(line)
                        logger.log_to_file.debug("File read OK")
                        return file_list
            logger.log_to_file.debug("File write OK")
            return True
        except (OSError, IOError):
            logger.log_to_file.trace("File operation: '" + operation + "' on file: '" + self.working_dir + "/" + self.name + self.extension + "' failed")
            return False  

class Directory():
    def __init__(self, name, working_dir):
        self.name = name
        self.working_dir = working_dir
    
    def create(self):
        self._execute_dir_operation(constants.filemanager.operation["CREATE"])
            
    def remove(self):
        self._execute_dir_operation(constants.filemanager.operation["REMOVE"])
        
    def exists(self):
        return os.path.exists(self.working_dir)
        
    def _execute_dir_operation(self, operation):
        logger.log_to_file.debug("Executing dir operation '" + list(constants.filemanager.operation.keys())[list(constants.filemanager.operation.values()).index(operation)] + "' on dir: '" + self.working_dir + "/" + self.name + "'")
        try:
            if operation == constants.filemanager.operation["REMOVE"]:
                if os.path.exists(self.working_dir + "/" + self.name):
                    shutil.rmtree(self.working_dir + "/" + self.name)
                    logger.log_to_file.debug("Removing dir: " + self.working_dir + "/" + self.name + " OK")
                    return True
                logger.log_to_file.error("Removing dir: " + self.working_dir + "/" + self.name + " does not exist")
            elif operation == constants.filemanager.operation["CREATE"]:
                if not os.path.exists(self.working_dir + "/" + self.name):
                    os.makedirs(self.working_dir + "/" + self.name)
                    logger.log_to_file.debug("Creating dir: " + self.working_dir + "/" + self.name + " OK")
                    return True          
                logger.log_to_file.debug("Creating dir: " + self.working_dir + "/" + self.name + " already exist")
            return False
        except (OSError, IOError):
            logger.log_to_file.trace("Directory operation: " + list(constants.filemanager.operation.keys())[list(constants.filemanager.operation.values()).index(operation)] + " on dir: " + self.working_dir + "/" + self.name + " failed")
            return False   
            
class FileSystem():
    def __init__(self):
        pass
    
    def list_files(self, directory, sort=False):
        file_list = []
        try:
            if sort:
                file_list = sorted(filter(os.path.isfile, os.listdir(directory)), key=os.path.getctime) #Sort files in directory by created
                #sfos.asynchronous.notfiy("DEBUG", "LIST FILES SORTED: " + file_list)
            else:
                file_list = os.listdir(directory)
        except (OSError, IOError):
            logger.log_to_file.trace("FileSystem operation: list_files on dir: " + directory + " failed")
            
        for i in range(len(file_list)):
            file_list[i] = os.path.splitext(file_list[i])[0] #Remove file extension
            
        return file_list
           
class LogFile(File):
    def __init__(self, name=datetime.datetime.utcnow().isoformat(), extension=constants.filemanager.extension["LOG"], working_dir=constants.filemanager.path["LOG"]): 
        if not os.path.exists(working_dir):
                os.makedirs(working_dir) # Create the dir if it doesn't exist
        super(self.__class__, self).__init__(name[:len(name)-7], extension, working_dir) # Import the init function from our super class File and remove the milliseconds from the filename
        #pyotherside.send("LOG FILE: " + self.working_dir + "/" + self.name + self.extension) #Send log file location to the terminal