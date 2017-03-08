# -*- coding: utf-8 -*-
"""
Created on Thu Jan  5 19:12:31 2017

@author: Dylan Van Assche
@title: Giphy class
@description: Giphy class for Sailfinder to interact with the GIPHY GIF API
@test: test/giphy_test.py
"""

#Sailfinder modules
from sailfinder import constants, network

class _Gifs():
    def __init__(self):
        self.gifs = {}
    
    def search(self, search_word=""):
        search_word = search_word.replace(" ", "+") #Conform with the Giphy API
        self.gifs = network.connection.send(constants.giphy.SEARCH + search_word + "&api_key=" + constants.giphy.KEY, http_type=constants.http.TYPE["GET"], host=constants.giphy.HOST, session=False)
        return self.gifs
    
    def trending(self):
        self.gifs = network.connection.send(constants.giphy.TRENDING + "?api_key=" + constants.giphy.KEY, http_type=constants.http.TYPE["GET"], host=constants.giphy.HOST, session=False)
        return self.gifs    
        
    def get_by_id(self, gif_id):
        gif = network.connection.send(constants.giphy.GIF + "/" + gif_id + "?api_key=" + constants.giphy.KEY, http_type=constants.http.TYPE["GET"], host=constants.giphy.HOST, session=False)
        return gif["data"]
    
gifs = _Gifs()