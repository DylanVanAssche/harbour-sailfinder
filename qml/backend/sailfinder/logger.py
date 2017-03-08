# -*- coding: utf-8 -*-
"""
Created on Thu Jan  5 21:30:15 2017

@author: Dylan Van Assche
@title: Logger for Sailfinder
@description: Log all console data to a log file for debugging and other purposes.
"""

#Sailfinder modules
import filemanager, constants
#Python modules
import logging, traceback, json, datetime, platform, sys

"""
LogFile:
    * Create a log file
    * Log the different type of logging levels to the log file when called from across Sailfinder.
"""    
class _FileLogger:
    def __init__(self):
        log_file = filemanager.LogFile()
        logging.basicConfig(format='%(levelname)s:%(message)s', filename=constants.filemanager.path["LOG"] + "/" + log_file.name + log_file.extension,level=logging.DEBUG)
        logging.info("\n" + "-" * 100 + "\n" + " " * 46 + "LOGFILE \n\n   DATE: " + datetime.datetime.utcnow().isoformat() + "\n   NAME: " + constants.sailfinder.name + "\n   VERSION: " + constants.sailfinder.version+ "\n   PLATFORM: " + platform.machine() + "\n" + "-" * 100)
    
    def __exit__(self):
        logging.shutdown()
        sys.exit()
    
    """
    Trace:
        * Generate traceback of last exception
        * Log extra error data with the traceback
    """            
    def trace(self, data="", json_data={}):
        trace_str = str(data)
        try:
            if len(json_data):
                trace_str +=  "\nJSON:\n" + json.dumps(json_data, indent=4, sort_keys=True, separators=(',', ':'))
        except:
            trace_str += str(json_data)
        trace_str += "\nTRACE:\n" + traceback.format_exc()
        logging.error(trace_str)

    """
    Log LVL = ERROR:
        * Log errors
    """         
    def error(self, data="", json_data={}):
        error_str = str(data)
        try:
            if len(json_data):
                error_str +=  "\nJSON:\n" + json.dumps(json_data, indent=4, sort_keys=True, separators=(',', ':'))
        except:
            error_str += str(json_data)
        logging.error(error_str)

    """
    Log LVL = WARNING:
        * Log warnings
    """             
    def warning(self, data="", json_data={}):
        warning_str = str(data)
        try:
            if len(json_data):
                warning_str +=  "\nJSON:\n" +json.dumps(json_data, indent=4, sort_keys=True, separators=(',', ':'))
        except:
            warning_str += str(json_data)
        logging.warning(warning_str)
 
    """
    Log LVL = DEBUG:
        * Log debug data
    """      
    def debug(self, data="", json_data={}, insert_line=False):
        if insert_line:
            debug_str = "\n" + "-" * (len(data) + 12) + "\n"
            debug_str += "|" + " "*5 + str(data) + " "*5 + "|"
            debug_str += "\n" + "-" * (len(data) + 12)
        else:
            debug_str = str(data)
        try:            
            if len(json_data):
                debug_str +=  "\nJSON:\n" +json.dumps(json_data, indent=4, sort_keys=True, separators=(',', ':'))
        except:
            debug_str += str(json_data)
        logging.debug(debug_str)
        
    """
    Log LVL = INFO:
        * Log info data
    """         
    def info(self, data="", json_data={}):
        info_str = str(data)
        try:            
            if len(json_data):
                info_str +=  "\nJSON:\n" + json.dumps(json_data, indent=4, sort_keys=True, separators=(',', ':'))
        except:
            info_str += str(json_data)
        logging.info(info_str)

log_to_file = _FileLogger()