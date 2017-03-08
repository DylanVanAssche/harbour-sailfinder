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
        token_file = filemanager.File("facebook_token", constants.filemanager.extension["TXT"])
        self.token = token_file.read()[0]
        self.user = {}
        self.albums = {}
        self.pictures = {}
        self.schools = {}
        self.jobs = {}
    
    #{u'name': u'John Jansens', u'id': u'135932223489915'}    
    def get_user(self): #OK
        self.user = network.connection.send(constants.facebook.ME + "?access_token=" + self.token, http_type=constants.http.TYPE["GET"], host=constants.facebook.HOST, session=False)
        return self.user
    
    #{u'data': []}
    def get_albums(self): #OK
        self.albums = network.connection.send("/" + self.get_user()["id"] + constants.facebook.ALBUMS + "?access_token=" + self.token, http_type=constants.http.TYPE["GET"], host=constants.facebook.HOST, session=False)
        return self.albums

    def get_pictures(self, album_id): #OK
        self.pictures = network.connection.send("/" + self.get_user()["id"] + constants.facebook.PICTURES + "?access_token=" + self.token, http_type=constants.http.TYPE["GET"], host=constants.facebook.HOST, session=False)
        return self.pictures 
    
    #{u'id': u'135932223489915'}    
    def get_schools(self): #OK
        self.schools = network.connection.send(constants.facebook.SCHOOLS + "&access_token=" + self.token, http_type=constants.http.TYPE["GET"], host=constants.facebook.HOST, session=False)
        return self.schools 
        
    #{u'work': [{u'position': {u'id': u'103113219728224', u'name': u'Chief Executive Officer'}, u'id': u'132865783796559', u'employer': {u'id': u'594445203920155', u'name': u'Self-Employed'}}], u'id': u'135932223489915'}    
    def get_jobs(self): #OK
        self.jobs = network.connection.send(constants.facebook.JOBS + "&access_token=" + self.token, http_type=constants.http.TYPE["GET"], host=constants.facebook.HOST, session=False)
        return self.jobs     
    
graph_api = _GraphAPI()
