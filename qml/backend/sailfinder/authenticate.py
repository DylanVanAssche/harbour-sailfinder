# -*- coding: utf-8 -*-
"""
Created on Fri Jan  6 19:02:42 2017

@author: Dylan Van Assche
@title: Authenticate class 
@description: Authenticate class for Sailfinder to login in all the services.
@test: test/authenticate_test.py
"""

#Sailfinder modules
import network, logger, filemanager, constants, sfos, facebook

import robobrowser, re, werkzeug, time, random

class _Tinder(object):
    def __init__(self):
        pass
        
    def login(self, fb_token):
        logger.log_to_file.debug("Requesting Tinder token from server")
        sfos.asynchronous.notify("loginProgress", 66.7)
        self._auth_data = network.connection.send("/auth", {"facebook_token": fb_token})
        sfos.asynchronous.notify("loginProgress", 83.4)
        if self._auth_data:
            auth_file = filemanager.File("auth", constants.filemanager.extension["JSON"], constants.filemanager.path["AUTH"])
            if auth_file.write(self._auth_data):
                sfos.asynchronous.notify("loginProgress", 100.0)
                return self._auth_data["token"]
        return False
    
    def token(self):
        try:
            auth_file = filemanager.File("auth", constants.filemanager.extension["JSON"], constants.filemanager.path["AUTH"])
            auth_data = auth_file.read()
            token =  auth_data["token"]
            logger.log_to_file.debug("Tinder token found in JSON data")
            return token
        except TypeError:   #No token -> bool returned
            logger.log_to_file.warning("Tinder token not found in JSON data")
            return False
        except:
            logger.log_to_file.trace("Tinder token not found in JSON data")
            return False
            
    def register(self, phone_number):
        logger.log_to_file.debug("Registering phone number: " + str(phone_number))
        return network.connection.send("/sendtoken", {"phone_number": str(phone_number)})
        
    def verify(self, code):
        logger.log_to_file.debug("Validating SMS code: " + str(code))
        return network.connection.send("/validate", {"token": str(code)})

class _Facebook(object):
    def __init__(self):
        self.token = False
        
    def login_cache(self):
        logger.log_to_file.debug("Requesting Facebook token from local cache")
        sfos.asynchronous.notify("loginProgress", 0.0)
        logger.log_to_file.debug("Checking for a previous cached valid Facebook token")
        if facebook.graph_api.get_token() and facebook.graph_api.get_user():
            sfos.asynchronous.notify("loginProgress", 25.0)
            self.token = facebook.graph_api.get_token()
            logger.log_to_file.debug("Found a valid cached Facebook token: " + str(self.token))
            sfos.asynchronous.notify("loginProgress", 50.0)
            return self.token
        return False
        
    def login_full(self, email, password):
        logger.log_to_file.debug("Requesting Facebook token from OAuth login system with username & password")
        sfos.asynchronous.notify("loginProgress", 0.0)
        
        #Login screen
        try:
            oauth = robobrowser.RoboBrowser(user_agent=constants.facebook.AUTH_USER_AGENT, parser="html.parser")
            oauth.open(constants.facebook.AUTH_HOST)
            sfos.asynchronous.notify("loginProgress", 16.7)
            credentials = oauth.get_form()
            credentials["pass"] = password
            credentials["email"] = email
            time.sleep(random.random()*1.5) #Fool Facebook security
            sfos.asynchronous.notify("loginProgress", 25.0)
            oauth.submit_form(credentials) 
        except:
            logger.log_to_file.debug("Facebook request failed, check your network connection")
            return False
        
        #Authorise app
        try:  
            confirm = oauth.get_form()
            sfos.asynchronous.notify("loginProgress", 33.4)
            time.sleep(random.random()*1.5) #Fool Facebook security
            oauth.submit_form(confirm, submit=confirm.submit_fields['__CONFIRM__'])
            self.token = re.search(r"access_token=([\w\d]+)", oauth.response.content.decode()).groups()[0]
            sfos.asynchronous.notify("loginProgress", 41.5)
        
        except werkzeug.exceptions.BadRequestKeyError: #Username or password is wrong
            logger.log_to_file.debug("Facebook username/password is wrong")
            return False
    
        #Check token
        if self.token:
            logger.log_to_file.info("Authenticating Facebook OAuth OK")
            token_file = filemanager.File("facebook_token", constants.filemanager.extension["TXT"], constants.filemanager.path["AUTH"])
            if token_file.write(self.token):
                sfos.asynchronous.notify("loginProgress", 50.0)
                return self.token
        logger.log_to_file.error("Can't retrieve Facebook token from login")
        return False

facebook_oauth = _Facebook() 
tinder = _Tinder()