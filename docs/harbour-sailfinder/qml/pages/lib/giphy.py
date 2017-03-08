# -*- coding: utf-8 -*-
"""
@title: Giphy API
@description: API for Giphy to fetch GIFs for Sailfinder

@author: Dylan Van Assche
"""

import requests
import constants

def search(search_word):
    try:
        search_word = search_word.replace(" ", "+") #Confirm with the Giphy API
        gifs = requests.get(constants.GIPHY_SEARCH_HOST + search_word + constants.GIPHY_KEY).json()
        return constants.HTTP_OK, gifs
    except:
        return constants.GIPHY_SEARCH_HOST + search_word + constants.GIPHY_KEY, False
