# -*- coding: utf-8 -*-
"""
@title: Sailfinder API constants
@description: Helper file for the API of Sailfinder to connect with the Tinder servers

@author: Dylan Van Assche
"""

TINDER_HOST = "https://api.gotinder.com"
TINDER_IMAGE_HOST = "https://imageupload.gotinder.com"

USER_AGENT = 'Tinder/4.6.1 (iPhone; iOS 9.0.1; Scale/2.00)'

HEADERS = {
    "User-Agent": USER_AGENT,
    "os_version": "90000000001",
    "app-version": "371",
    "platform": "android",  # XXX with ios we run in an error
    "Content-type": "application/json; charset=utf-8"
}

GIPHY_SEARCH_HOST = "http://api.giphy.com/v1/gifs/search?q="
GIPHY_KEY = "&api_key=fBEDuhnVCiP16" # Tinder Giphy API key

HTTP_NOT_RESPONDING = 444
HTTP_OK = 200
HTTP_DENIED = 500
HTTP_NOT_FOUND = 404
HTTP_NOT_FULLFILL = 403

MOBILE_USER_AGENT = "Mozilla/5.0 (Linux; U; en-gb; KFTHWI Build/JDQ39) AppleWebKit/535.19 (KHTML, like Gecko) Silk/3.16 Safari/535.19"
FB_AUTH = "https://www.facebook.com/v2.6/dialog/oauth?redirect_uri=fb464891386855067%3A%2F%2Fauthorize%2F&display=touch&state=%7B%22challenge%22%3A%22IUUkEUqIGud332lfu%252BMJhxL4Wlc%253D%22%2C%220_auth_logger_id%22%3A%2230F06532-A1B9-4B10-BB28-B29956C71AB1%22%2C%22com.facebook.sdk_client_state%22%3Atrue%2C%223_method%22%3A%22sfvc_auth%22%7D&scope=user_birthday%2Cuser_photos%2Cuser_education_history%2Cemail%2Cuser_relationship_details%2Cuser_friends%2Cuser_work_history%2Cuser_likes&response_type=token%2Csigned_request&default_audience=friends&return_scopes=true&auth_type=rerequest&client_id=464891386855067&ret=login&sdk=ios&logger_id=30F06532-A1B9-4B10-BB28-B29956C71AB1&ext=1470840777&hash=AeZqkIcf-NEW6vBd"

