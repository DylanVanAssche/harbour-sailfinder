# -*- coding: utf-8 -*-
"""
Created on Fri Jan  6 20:03:25 2017

@author: Dylan Van Assche
@title: App main
@description: Main Python script for Sailfinder, all the actions are performed from this script.
"""


#Sailfinder module
from sailfinder import tinder, authenticate, cachemanager, sfos, giphy, network

#Python modules

class Connection(object):
    def __init__(self):
        pass
    
    def status(self):
        return network.connection.status()

class Cache(object):
    def __init__(self):
        pass
    
    def clearRecs(self):
        recs = cachemanager.Recommendations()
        recs.clear()
        
    def clearUpdates(self):
        updates = cachemanager.Updates()
        updates.clear()

    def clearMatches(self):
        matches = cachemanager.Matches()
        matches.clear()
        
    def clearProfile(self):
        profile = cachemanager.Profile()
        profile.clear()
        
    def clearAuth(self):
        auth = cachemanager.Authentication()
        auth.clear()
        
    def clearMeta(self):
        meta = cachemanager.Meta()
        meta.clear()
        
    def clearLogger(self):
        logger = cachemanager.Logger()
        logger.clear()

class Account(object):
    def __init__(self):
        pass
    
    def auth(self, email="", password=""):
        if len(email)==0 or len(password)==0:
            fb_token = authenticate.facebook_oauth.login_cache()
            if not fb_token:
                return 0    #FB token expired
        else:
            fb_token = authenticate.facebook_oauth.login_full(email, password)
            if not fb_token:
                return 1    #FB login failed
        tinder_token = authenticate.tinder.login(fb_token)
        if not tinder_token:
            return 2    #Tinder login failed
        result = profile.get(refresh=True)
        if result and "banned" in result:
            return 4    #Phone verification requested
        return 5 # All good!
        
    def verify(self, code):
        result = authenticate.tinder.verify(code)
        if result:
            return True
        return False
        
    def register(self, phone_number):
        result = authenticate.tinder.register(phone_number)
        if result:
            return True
        return False
            
    def logout(self):
        cache.clearAuth()
        cache.clearMatches()
        cache.clearMeta()
        cache.clearProfile()
        cache.clearRecs()
        cache.clearUpdates()
        sfos.asynchronous.notify("returnToLogin", True)
        
    def location(self, latitude, longitude):
        return tinder.profile.ping(latitude, longitude)
        
    def updates(self): #Updates for this account
        return tinder.updates.get()
    
    def meta(self): #Meta data for this account
        return tinder.meta.get()
        
    def delete(self):
        cache.clearAuth()
        cache.clearMatches()
        cache.clearMeta()
        cache.clearProfile()
        cache.clearRecs()
        cache.clearUpdates()
        tinder.profile.delete_account()
        sfos.asynchronous.notify("returnToLogin", True)
    
class Recommendations(object):
    def __init__(self):
        pass
    
    def get(self, size=0):
        return tinder.recs.get(size)
    
    """
    Like a user and return True/False depending on succes
    """    
    def like(self, user_id):
        result = tinder.recs.like(user_id)
        if result:
            return result
        else:
            return False

    """
    Dislike a user and return True/False depending on succes
    """    
    def dislike(self, user_id):
        result = tinder.recs.dislike(user_id)
        if result:
            return True
        else:
            return False
            
    """
    Superlike a user and return True/False depending on succes
    """    
    def superlike(self, user_id):
        result = tinder.recs.superlike(user_id)
        if result is None:
            return 2 #Out of superlikes
        elif result:
            return result #Succes
        else:
            return 0 #Fail

class Profile(object):
    def __init__(self):
        pass
    
    def get(self, refresh=False, size=0):
        return tinder.profile.get(refresh, size)
        
    def set(self, discoverable, age_min, age_max, gender, interested_in, distance, bio):
        return tinder.profile.update(discoverable, age_min, age_max, gender, interested_in, distance, bio)
    
class Matches(object):
    def __init__(self):
        pass
    
    def get(self, size=0):
        return tinder.matches.get(size)
        
    def incremental(self, last_activity_date):
        return tinder.matches.incremental(last_activity_date)
        
    def last_active(self):
        return tinder.matches.last_active()
        
    def about(self, user_id):
        return tinder.matches.about(user_id)
        
    def gifs(self, search_word):
        return giphy.gifs.search(search_word)["data"]
        
    def liked(self):
        return tinder.message.liked()
        
    def like_msg(self, message_id):
        return tinder.message.like(message_id)
    
    def unlike_msg(self, message_id):
        return tinder.message.unlike(message_id)
    
    def send(self, match_id, message, gif=False, gif_id=""):
        return tinder.message.send(match_id, message, gif_id , gif)
        
    def report(self, user_id, reason, explanation=""):
        return tinder.matches.report(user_id, reason, explanation)
        
    def delete(self, match_id): #Delete also the cached data !
        return tinder.matches.unmatch(match_id)

connection = Connection()
cache = Cache()    
account = Account()
profile = Profile()
recs = Recommendations()
matches = Matches()