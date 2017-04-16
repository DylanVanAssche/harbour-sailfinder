# -*- coding: utf-8 -*-
"""
Created on Thu Jan  5 19:12:31 2017

@author: Dylan Van Assche
@title: Network class
@description: Network class for Sailfinder to handle all the network requests and connections with ConnMan.
@test: test/network_test.py
"""

#Sailfinder modules
import constants, sfos, logger, authenticate

#Python modules
import requests, time

"""
Connection:
    * Manage and update session
    * Close session on exit
    * Ask ConnMan about our network
    * Send HTTP requests to the services
"""
class _Connection(object):
    """
    Start the Network stack:
        * Check ConnMan network state
        * Start Requests Session when connected and launch the connection dialog when disconnected
    """
    def __init__(self):
        connman_data = sfos.connman.read()
        self._current_network = ""
        
        if connman_data["NetworkState"][0] == "connected":
            self._current_network = connman_data["NetworkType"][0]
            self._session = requests.Session()
            self._session.headers.update(constants.tinder.HEADERS)
            logger.log_to_file.debug("Connected, starting requests session...")
        else:
            sfos.connection_manager.launch_connection_dialog()
            logger.log_to_file.debug("Not connected, launch connection dialog")
        logger.log_to_file.debug("Init Connection class")
    
    """
    Close the Network stack:
        * When exiting, close properly our session
    """    
    def __exit__(self):
        self.session.close()

    """
    Check the connection:
        * Refresh ConnMan network state
        * Create a new session when the 'NetworkType' has been changed (Mobile/WiFi)
        * Return True when connected or False and launch the connection dialog when disconnected when disconnected
    """    
    def status(self, dialog=True):
        connman_data = sfos.connman.read()
        if self._current_network != connman_data["NetworkType"][0]:
            self._session = requests.Session()
            self._session.headers.update(constants.tinder.HEADERS)
            
        if connman_data["NetworkState"][0] == "connected":
            return True
        elif dialog:
            sfos.connection_manager.launch_connection_dialog()
        return False
            
    """
    Update session headers:
        * Add auth token to the session header
    """  
    def update_headers(self, header):
        self._session.headers.update(header)
        
    """
    Send:
        * Check the ConnMan network state, if offline sleep until network is back
        * Check the connection stability
        * Perform a HTTP POST request on our current session
        * Check if the request was accepted and correctly replied by the server
        * Return data when OK or False when request failed, if HTTP 201 or 204 then no JSON content or no content at all is returned, so we return True
    DEFAULT ARGUMENTS:
        * payload = None -> A payload is not always required so default empty dictionary
        * http_type = 0 -> POST is default, GET=1, PUT=2 and DELETE=3
        * session = True -> Reuse the headers
        * host = constants.tinder.HOST -> Most requests are for Tinder
        * files = None -> Files to upload for example images
    """   
    def send(self, url, payload=None, http_type=constants.http.TYPE["POST"], session=True, host=constants.tinder.HOST, files=None, raw=False, wait=True):
        limit_execution = 50
        wait_since = time.clock()
        
        if not self.status(False): #Don't force the user to enable a netwerk connection when checking notifications
            if not wait:
                logger.log_to_file.debug("No connection + waiting is disabled = abort request")
                return False
            else:
                sfos.connection_manager.notify_connection_state(False)
                sfos.connection_manager.launch_connection_dialog()
            
        while(not self.status(False)): #Wait until network is available
            time.sleep(1.0)
            limit_execution += 1
            if limit_execution > 90: #Limit calls to SFOS Connection Manager and logging
                logger.log_to_file.debug("Network unavailable: WiFi and cellular connection deactivated, already waited: " + str(round(time.clock() - wait_since,6)) + "s for a connection")
        else:
            logger.log_to_file.debug("Network available, processing request after waiting: " + str(round(time.clock() - wait_since, 6)) + "s for a connection")
            sfos.connection_manager.notify_connection_state(True)

        if requests.get(constants.http.TEST["IPV4"]).status_code == constants.http.SUCCESS["OK"] or requests.get(constants.http.TEST["IPV6"]).status_code == constants.http.SUCCESS["OK"]: # Check connection
            sfos.connection_manager.notify_connection_state(True)            
            if session:
                logger.log_to_file.debug("Updating Tinder token: " + str(authenticate.tinder.token()))
                if authenticate.tinder.token(): #Check if token is valid
                   self._session.headers.update({"X-Auth-Token": authenticate.tinder.token()})
                if http_type == constants.http.TYPE["POST"]:
                    response = self._session.post(host + url, json=payload, files=files)
                elif http_type == constants.http.TYPE["GET"]:
                    response = self._session.get(host + url, json=payload, files=files)
                elif http_type == constants.http.TYPE["PUT"]:
                    response = self._session.put(host + url, json=payload, files=files)
                elif http_type == constants.http.TYPE["DELETE"]:
                    response = self._session.delete(host + url, json=payload, files=files)
            else:
                if http_type == constants.http.TYPE["POST"]:
                    response = requests.post(host + url, json=payload, files=files)
                elif http_type == constants.http.TYPE["GET"]:
                    response = requests.get(host + url, json=payload, files=files)
                elif http_type == constants.http.TYPE["PUT"]:
                    response = requests.put(host + url, json=payload, files=files)
                elif http_type == constants.http.TYPE["DELETE"]:
                    response = requests.delete(host + url, json=payload, files=files)
            
            if response.status_code in constants.http.SUCCESS.values():
                logger.log_to_file.info("HTTP request " + str(url) + " OK")
                if response.status_code == 201 or response.status_code == 204: #NON JSON
                    logger.log_to_file.debug("HTTP " + list(constants.http.TYPE.keys())[list(constants.http.TYPE.values()).index(http_type)] +" request completed in " + str(response.elapsed.total_seconds()) + "s returned 204 or 201: " + response.text)          
                    return True
                elif raw:
                    logger.log_to_file.debug("HTTP " + list(constants.http.TYPE.keys())[list(constants.http.TYPE.values()).index(http_type)] +" request completed in " + str(response.elapsed.total_seconds()) + "s: raw content")  
                    return response.content
                logger.log_to_file.debug("HTTP " + list(constants.http.TYPE.keys())[list(constants.http.TYPE.values()).index(http_type)] +" request completed in " + str(response.elapsed.total_seconds()) + "s", response.json())          
                return response.json()
            else:
                logger.log_to_file.error("HTTP " + list(constants.http.TYPE.keys())[list(constants.http.TYPE.values()).index(http_type)] + " server returned bad HTTP code: " + str(response.status_code))
                return False
        else:
            logger.log_to_file.error("Network unavailable: ipv4.jolla.com or ipv6.jolla.com unreachable, aborting request")
            sfos.connection_manager.notify_connection_state(False)
            return False

connection = _Connection()
