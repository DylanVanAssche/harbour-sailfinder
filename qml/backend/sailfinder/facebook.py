# -*- coding: utf-8 -*-
"""
Created on Thu Jan  5 19:12:31 2017

@author: Dylan Van Assche
@title: Facebook class
@description: Facebook class for Sailfinder to interact with the Facebook Graph API
@test: test/facebook_test.py
"""

#Sailfinder modules
from sailfinder import constants, network, filemanager

class _GraphAPI():
    def __init__(self):
        self.token = False
        self.user = {}
        self.albums = {}
        self.pictures = {}
        self.schools = {}
        self.jobs = {}
        
    def get_token(self):
        token_file = filemanager.File("facebook_token", constants.filemanager.extension["TXT"], constants.filemanager.path["AUTH"])
        if token_file.exists():
            self.token = token_file.read()[0]
        return self.token
    
    def get_user(self): #OK
        self.user = network.connection.send(constants.facebook.ME + "?access_token=" + self.token, http_type=constants.http.TYPE["GET"], host=constants.facebook.HOST, session=False)
        if self.user and "error" in self.user:
            return False
        return self.user
    
    def get_albums(self): #OK
        self.albums = network.connection.send("/" + self.get_user()["id"] + constants.facebook.ALBUMS + "?access_token=" + self.token, http_type=constants.http.TYPE["GET"], host=constants.facebook.HOST, session=False)
        if self.user and "error" in self.user:
            return False
        return self.albums

    def get_pictures(self, album_id): #OK
        self.pictures = network.connection.send("/" + self.get_user()["id"] + constants.facebook.PICTURES + "?access_token=" + self.token, http_type=constants.http.TYPE["GET"], host=constants.facebook.HOST, session=False)
        if self.user and "error" in self.user:
            return False
        return self.pictures 
    
    def get_schools(self): #OK
        self.schools = network.connection.send(constants.facebook.SCHOOLS + "&access_token=" + self.token, http_type=constants.http.TYPE["GET"], host=constants.facebook.HOST, session=False)
        if self.user and "error" in self.user:
            return False
        return self.schools 
        
    def get_jobs(self): #OK
        self.jobs = network.connection.send(constants.facebook.JOBS + "&access_token=" + self.token, http_type=constants.http.TYPE["GET"], host=constants.facebook.HOST, session=False)
        if self.user and "error" in self.user:
            return False
        return self.jobs  
    
graph_api = _GraphAPI()
