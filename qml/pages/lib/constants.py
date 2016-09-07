# -*- coding: utf-8 -*-
"""
@title: Sailfinder API constants
@description: Helper file for the API of Sailfinder to connect with the Tinder servers

@author: Dylan Van Assche
"""

TINDER_HOST = "https://api.gotinder.com"
TINDER_IMAGE_HOST = "https://imageupload.gotinder.com"

#USER_AGENT = 'Tinder Android Version 5.3.5'
#
#HEADERS = {
#    "Accept-Language": "en",
#    "platform": "android",
#    "User-Agent": USER_AGENT,
#    "os-version": "23",
#    "app-version": "1630",
#    "Connection": "Keep-Alive",
#    #"Content-Length": "49",
#    "Accept-Encoding": "gzip",
#    "Content-Type": "application/json; charset=utf-8",
#    "Host":"api.gotinder.com",
#}

#HEADERS = {
#    'User-Agent': 'Tinder Android Version 4.5.5',
#    'os_version'      : '23',
#    'platform'        : 'android',
#    'app-version'     : '854',
#    'Accept-Language' : 'en'
#}


USER_AGENT = 'Tinder/4.6.1 (iPhone; iOS 9.0.1; Scale/2.00)'

HEADERS = {
    "User-Agent": USER_AGENT,
    "os_version": "90000000001",
    "app-version": "371",
    "platform": "android",  # XXX with ios we run in an error
    "Content-type": "application/json; charset=utf-8"
}

