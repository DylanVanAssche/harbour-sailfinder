# -*- coding: utf-8 -*-
"""
Created on Thu Jan  5 19:14:33 2017

@author: Dylan Van Assche
@title: Constants
@description: All constants used in Sailfinder.
"""

#Python modules
import os

"""
Tinder:
    * HOST -> All Tinder requests
    * IMAGE_HOST -> Upload local pictures
    * USER_AGENT
"""   
class _Tinder(object):
    def __init__(self):
        self.HOST = "https://api.gotinder.com"
        self.IMAGE_UPLOAD_HOST = "https://imageupload.gotinder.com"
        self.IMAGE_HOST = "http://images.gotinder.com"
        self.HEADERS = {"User-Agent": "Tinder/4.6.1 (iPhone; iOS 9.0.1; Scale/2.00)", "os_version": "90000000001", "app-version": "371", "platform": "ios", "Content-type": "application/json; charset=utf-8"}
        #self.HEADERS = {"User-Agent": "Tinder Android Version 4.5.5", "os_version": "23", "app-version": "854", "platform": "android", "Content-type": "application/json; charset=utf-8"}        
        self.RECS_LIMIT = 10
"""
Giphy:
    * HOST -> All Giphy GIF requests
    * SEARCH -> API point to perform search requests
    * KEY -> API key
"""      
class _Giphy(object): #EXAMPLE: https://api.giphy.com/v1/gifs/search?q=keyword&api_key=fBEDuhnVCiP16
    def __init__(self):
        self.HOST = "https://api.giphy.com"
        self.SEARCH = "/v1/gifs/search?q="
        self.TRENDING = "/v1/gifs/trending"
        self.GIF = "/v1/gifs"
        self.KEY = "fBEDuhnVCiP16"

"""
Facebook:
    * HOST -> All Facebook Graph requests
    * KEY -> API key
"""      
class _Facebook(object):
    def __init__(self):
        self.AUTH_HOST = "https://www.facebook.com/v2.6/dialog/oauth?redirect_uri=fb464891386855067%3A%2F%2Fauthorize%2F&display=touch&state=%7B%22challenge%22%3A%22IUUkEUqIGud332lfu%252BMJhxL4Wlc%253D%22%2C%220_auth_logger_id%22%3A%2230F06532-A1B9-4B10-BB28-B29956C71AB1%22%2C%22com.facebook.sdk_client_state%22%3Atrue%2C%223_method%22%3A%22sfvc_auth%22%7D&scope=user_birthday%2Cuser_photos%2Cuser_education_history%2Cemail%2Cuser_relationship_details%2Cuser_friends%2Cuser_work_history%2Cuser_likes&response_type=token%2Csigned_request&default_audience=friends&return_scopes=true&auth_type=rerequest&client_id=464891386855067&ret=login&sdk=ios&logger_id=30F06532-A1B9-4B10-BB28-B29956C71AB1&ext=1470840777&hash=AeZqkIcf-NEW6vBd"
        self.AUTH_USER_AGENT = "Mozilla/5.0 (Linux; U; en-gb; KFTHWI Build/JDQ39) AppleWebKit/535.19 (KHTML, like Gecko) Silk/3.16 Safari/535.19"
        self.HOST = "https://graph.facebook.com/v2.6"
        self.ME = "/me"
        self.ALBUMS = "/albums"
        self.PICTURES = "/photos"
        self.SCHOOLS = "/me?fields=education"
        self.JOBS =  "/me?fields=work"
 
"""
Oauth:
    * HOST -> Facebook iOS login SDK endpoint
    * USER_AGENT -> Mobile user agent
"""          
class _OAuth(object):
    def __init__(self):
        self.HOST = "https://www.facebook.com/v2.6/dialog/oauth?redirect_uri=fb464891386855067%3A%2F%2Fauthorize%2F&display=touch&state=%7B%22challenge%22%3A%22IUUkEUqIGud332lfu%252BMJhxL4Wlc%253D%22%2C%220_auth_logger_id%22%3A%2230F06532-A1B9-4B10-BB28-B29956C71AB1%22%2C%22com.facebook.sdk_client_state%22%3Atrue%2C%223_method%22%3A%22sfvc_auth%22%7D&scope=user_birthday%2Cuser_photos%2Cuser_education_history%2Cemail%2Cuser_relationship_details%2Cuser_friends%2Cuser_work_history%2Cuser_likes&response_type=token%2Csigned_request&default_audience=friends&return_scopes=true&auth_type=rerequest&client_id=464891386855067&ret=login&sdk=ios&logger_id=30F06532-A1B9-4B10-BB28-B29956C71AB1&ext=1470840777&hash=AeZqkIcf-NEW6vBd"
        self.USER_AGENT = "Mozilla/5.0 (Linux; U; en-gb; KFTHWI Build/JDQ39) AppleWebKit/535.19 (KHTML, like Gecko) Silk/3.16 Safari/535.19"

"""
HTTP: 
    * TYPE -> Type of HTTP request used by network.send()
    * SUCCESS -> HTTP CODES for a succesfull request
    * REDIRECTION -> HTTP CODES for a redirect request
    * CLIENT_ERROR -> HTTP CODES for a failed request client side
    * SERVER_ERROR -> HTTP CODES for a failed request server side
"""
class _HTTP(object):
    def __init__(self):
        self.TYPE = {"POST":0, "GET":1, "PUT":2, "DELETE": 3}
        self.TEST = {"IPV4": "http://ipv4.jolla.com", "IPV6": "http://ipv6.jolla.com"}
        self.SUCCESS = {"OK":200, "CREATED":201, "NO_CONTENT":204, "RESET_CONTENT":205, "PARTIAL_CONTENT":206, "MULTI_STATUS":207, "ALREADY_REPORTED":208, "IM_USED":226}
        self.REDIRECTION = {"MULTIPLE_CHOICES":300, "MOVED_PERMANENTLY":301, "FOUND":302, "NOT_MODIFIED":304, "PERMANENT_REDIRECT":308}
        self.CLIENT_ERROR = {"BAD_REQUEST":400, "UNAUTHORIZED":401, "PAYMENT_REQUIRED":402, "FORBIDDEN":403, "NOT_FOUND":404, "METHOD_NOT_ALLOWED":405, "NOT_ACCEPTABLE":406, "PROXY_AUTHENTICATION_REQUIRED":407, "REQUEST_TIME_OUT":408, "CONFLICT":409, "GONE":410, "LENGTH_REQUIRED":411, "PRECONDITION_FAILED":412, "PAYLOAD_TO_LARGE":413, "URI_TOO_LONG":414,"UNSUPPORTED_MEDIA_TYPE":415, "RANGE_NOT_STATISFABLE":416, "EXPECTATION_FAILED":417, "MISDIRECTED_REQUEST":421, "UNPROCESSABLE_ENTITY":422, "LOCKED":423, "FAILED_DEPENDENCY":424, "UPGRADE_REQUIRED":426, "PRECONDITION_REQUIRED":428, "TOO_MANY_REQUESTS":429, "REQUEST_HEADER_FIELDS_TOO_LARGE":431, "UNAVAILABLE_FOR_LEGAL_REASONS":451}
        self.SERVER_ERROR = {"INTERNAL_SERVER_ERROR":500, "NOT_IMPLENTED":501, "BAD_GATEWAY":502, "SERVICE_UNAVAILABLE":503, "GATEWAY_TIME_OUT":504, "HTTP_VERSION_NOT_SUPPORTED":505, "VARIANT_ALSO_NEGOTIATES":506, "INSUFFICIENT_STORAGE":507, "LOOP_DETECTED":508, "NOT_EXTENDED":510, "NETWORK_AUTHENTICATION_REQUIRED":511}

"""
FileManager:
    * JSON -> Filemanager how to handle serialized JSON data
    * IMAGE -> Filemanager how to handle image PNG data
"""              
class _FileManager(object):
    def __init__(self):
        self.home = os.path.expanduser("~")
        self.cache_dirs = ["updates", "matches", "social", "logging", "recommendations", "profile"]
        self.config_dirs = ["authentication"]
        self.data_dirs = []
        self.operation = {"READ":"r", "READ_BINARY":"rb", "WRITE":"w", "WRITE_BINARY":"wb", "APPEND":"a", "APPEND_BINARY":"ab", "REMOVE":0, "CREATE":1}
        self.extension = {"JSON":".json", "JPG":".jpg", "TXT":".txt", "CONFIG":".conf", "NONE":"", "LOG":".log", "GIF":".gif"}
        self.path = {"XDG_CONFIG_HOME": self.home + "/.config/harbour-sailfinder", "XDG_DATA_HOME": self.home + "/.local/share/harbour-sailfinder", "XDG_CACHE_HOME": self.home + "/.cache/harbour-sailfinder", "CONNMAN":"/run/state/providers/connman/Internet", "LOG": self.home + "/.cache/harbour-sailfinder/logging", "UPDATES": self.home + "/.cache/harbour-sailfinder/updates", "RECS": self.home + "/.cache/harbour-sailfinder/recommendations", "AUTH": self.home + "/.config/harbour-sailfinder/authentication", "PROFILE": self.home + "/.cache/harbour-sailfinder/profile", "MATCHES": self.home + "/.cache/harbour-sailfinder/matches"}
        #self.path = {"XDG_CONFIG_HOME":"sailfinder/config", "XDG_DATA_HOME":"sailfinder/data", "XDG_CACHE_HOME":"sailfinder/cache", "CONNMAN":"sailfinder/connman-data", "LOG":"sailfinder/cache/logging", "UPDATES":"sailfinder/cache/updates", "RECS": "sailfinder/cache/recommendations", "AUTH": "sailfinder/cache/authentication", "PROFILE": "sailfinder/cache/profile", "MATCHES": "sailfinder/cache/matches"} #Debugging PC
        self.age = {"30_MIN":1800, "60_MIN":3600, "90_MIN":5400, "7_DAYS":604800}

class _Sailfinder():
    def __init__(self):
        self.name = "harbour-sailfinder"
        self.version = "3.0-1"

filemanager = _FileManager()
http = _HTTP()
oauth = _OAuth()
facebook = _Facebook()
giphy = _Giphy()
tinder = _Tinder()
sailfinder = _Sailfinder()
