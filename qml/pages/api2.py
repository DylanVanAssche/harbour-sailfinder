# -*- coding: utf-8 -*-
"""
@title: Sailfinder API
@description: API for Sailfinder to connect with the Tinder servers

@author: Dylan Van Assche
"""
import json
import time
import pyotherside
import os
from lib import constants, requests

session = requests.Session() #Tinder session
fb_token = ''
fb_user_id = ''
last_active = ''

def uploadTinder(imageFile, userID): #BROKEN
    #print 'UPLOAD'
    #image = {'media': open('test.jpeg', 'rb')}
    #data = json.dumps({'userId': '56d422d94f10e5db60fe7823'})
    #return session.post('https://imageupload.gotinder.com/image?client_photo_id=ProfilePhoto' + str(int(time.time())*1000), data={'userId': '56d422d94f10e5db60fe7823'}, files={'file': open('test.jpeg', 'rb')})
    pyotherside.send('lol', time.time())
    #session.headers.update(constants.HEADERS)
    #return session.post(constants.TINDER_IMAGE_HOST + '/image?client_photo_id=ProfilePhoto' + str(int(time.time())), data={'userId': '56d422d94f10e5db60fe7823'}, files={'file': open('test.jpeg', 'rb')})

def postTinder(url, data): #OK
    #print 'POST'
    result = session.post(constants.TINDER_HOST + url, json=data)
    if(result.status_code == 200 or result.status_code == 204 or result.status_code == 201):
        try:
            return result.json()
        except:
            return True
    else:
        return False
    
def getTinder(url, data): #OK
    #print 'GET'
    result = session.post(constants.TINDER_HOST + url, data=data)
    if(result.status_code == 200 or result.status_code == 204 or result.status_code == 201):
        try:
            return result.json()
        except:
            return True
    else:
        print (result.status_code)
        return False
    
def deleteTinder(url, data): #OK
    #print 'DELETE'
    result = session.delete(constants.TINDER_HOST + url, data=data)
    
    if(result.status_code == 200 or result.status_code == 204 or result.status_code == 201):
        try:
            result.json()
        except:
            return True
    else:
        return False
    
def putTinder(url, data): #OK
    #print 'PUT'
    result = session.put(constants.TINDER_HOST + url, data=data)
    if(result.status_code == 200 or result.status_code == 204 or result.status_code == 201):
        try:
            result.json()
        except:
            return True
    else:
        return False
        
def loginFacebook(fb_login_url): #OK
    global fb_token
    global fb_user_id
    if(fb_login_url.find("access_token")):
        try:
            link, fb_token, expireTime = fb_login_url.split("=")
            fb_token, trash = fb_token.split("&")
            fb_id_API_url = "https://graph.facebook.com/me?fields=id&access_token=" + fb_token
            fb_user_id = requests.get(fb_id_API_url)
            pyotherside.send('DEBUG', fb_user_id.content)
            pyotherside.send('loginFacebook', str(fb_user_id), fb_token)
        except:
            pyotherside.send('loginFacebook', False)

def loginTinder(fb_id, fb_token): #OK
    session.headers.update(constants.HEADERS)
    data = json.dumps({"facebook_id": str(fb_id),"facebook_token": fb_token}) #"locale":"en" for Tinder V2
    login = postTinder('/auth', data)

    if 'token' not in login:
        pyotherside.send('loginTinder', False)
        print ('FAIL')
    else:
        tinder_token = login['token']
        session.headers.update({"X-Auth-Token": str(tinder_token)})
        pyotherside.send('loginTinder', tinder_token)
        print ('LOGIN OK')
    
def recommendations(): #OK
    data = json.dumps({"limit": 10})
    recommendations = postTinder('/user/recs', data) #?local=en for Tinder V2
    format_recommendations(recommendations)
    
def format_recommendations(recommendations):
    pyotherside.send('recommendations',recommendations['results'])
    
"""def like(personID, photoID, content_hash): #Tinder API V2
    data = json.dumps({})
    result = getTinder('/like/' + personID + '?photoId=' + photoID + '&content_hash=' + content_hash, data)
    pyotherside.send('like', result)

def dislike(personID, photoID, content_hash): #Tinder API V2
    data = json.dumps({})
    result = getTinder('/pass/' + personID + '?photoId=' + photoID + '&content_hash=' + content_hash, data)
    pyotherside.send('dislike', result)
    
def superlike(personID, photoID, content_hash): #Tinder API V2
    data = json.dumps({})
    result = getTinder('/like/' + personID +'/super' + '?photoId=' + photoID + '&content_hash=' + content_hash, data)
    pyotherside.send('superlike', result)"""
    
def like(personID,): #Tinder API V1
    data = json.dumps({})
    result = getTinder('/like/' + personID, data)
    pyotherside.send('like', result)

def dislike(personID): #Tinder API V1
    data = json.dumps({})
    result = getTinder('/pass/' + personID, data)
    pyotherside.send('dislike', result)
    
def superlike(personID): #Tinder API V1
    data = json.dumps({})
    result = getTinder('/like/' + personID, data)
    pyotherside.send('superlike', result)
    
def matches(since): #OK
    if(len(since) > 0):
        matches = updates(since)['matches']
    else:
        matches = updates('')['matches']
    return matches
    
def report(userID, causeID): #NEEDS TESTING
    data = json.dumps({"cause": causeID})
    result = postTinder('/report/' + userID, data)
    return result

def profile(): #OK
    data = json.dumps({})
    profile = getTinder('/profile', data)
    pyotherside.send('profile', profile)
    
def update_profile(discoverable, age_min, age_max, gender, gender_filter, distance, bio): #OK
    data = json.dumps({"discoverable" : discoverable, "age_filter_min" : age_min, "age_filter_max" : age_max, "gender": gender, "gender_filter" : gender_filter, "distance_filter" : distance, "bio": bio})
    updated_profile = postTinder('/profile', data)
    pyotherside.send('updated_profile', updated_profile)
    
def delete_account():
    data = json.dumps({})
    result = deleteTinder('/profile', data)
    pyotherside('delete_account', result)

def update_schools(fb_school_id):
    data = json.dumps({"schools": [{"id": fb_school_id}]})
    schools = putTinder('/profile/school', data)
    pyotherside.send('schools', schools)
    
def delete_schools():
    data = json.dumps({})
    schools = deleteTinder('/profile/school', data)
    pyotherside.send('schools', schools)
    
def update_jobs(fb_job_id):
    data = json.dumps({"company": [{"id": fb_job_id}]})
    jobs = putTinder('/profile/job', data)
    pyotherside.send('jobs', jobs)
    
def delete_jobs():
    data = json.dumps({})
    jobs = deleteTinder('/profile/job', data)
    pyotherside.send('jobs', jobs)

def create_username(username): #OK
    data = json.dumps({"username": username})
    result = postTinder('/profile/username', data)
    if(result):
        pyotherside.send('username', 1)
    else:
        pyotherside.send('username', False)
    
def update_username(username): #OK
    data = json.dumps({"username": username})
    result = putTinder('/profile/username', data)
    #{u'error': u'User has already registered a username'}
    #{u'error': u'User has no username to update'}
    if(result):
        pyotherside.send('username', 2)
    else:
        pyotherside.send('username', False)
    
def delete_username(): #OK
    result = deleteTinder('/profile/username', None)
    # {u'error': u'User has no username to remove'}
    if(result):
        pyotherside.send('username', 3)
    else:
        pyotherside.send('username', False)
    
def share_link(tinder_user_id): #OK
    url = postTinder('/user/' + tinder_user_id + '/share', None)
    #pyotherside.send('SHARE LINK HTTP CODE', status_code)
    pyotherside.send('sharelink', url)
    
def updates(since): #OK
    if len(since) > 0:
        data = {"last_activity_date:": since}
        updates = postTinder('/updates', data)
        #print (updates)
        #pyotherside.send('DEBUG', 'Load matches since ' + last_active)
    else:
        data = json.dumps({"last_activity_date:" : ''})
        updates = postTinder('/updates', data)
    return updates
    
def meta(): #NOT FOUND HTTP 404, LIKES REMAININGS SEE RESPONDS WHEN LIKE/DISLIKE/SUPERLIKE
    data = json.dumps({})
    meta = getTinder('/meta', data)
    #pyotherside.send('meta', meta)
    
def update_location(lat, lon): #OK
    data = json.dumps({"lat": lat, "lon" : lon})
    location = postTinder('/user/ping', data)
    return location
    
def upload_picture(imageFile, userID): #BROKEN HTTP 500
    pictures = uploadTinder(imageFile, userID)
    return pictures
    
def upload_fb_picture(fb_picture_id, ydistance_percent = 0, xdistance_percent = 0, yoffset_percent = 0, xoffset_percent = 0): #OK
    data = json.dumps({"transmit": "fb", "assets": [{"ydistance_percent": ydistance_percent,"id": fb_picture_id,"xoffset_percent": xoffset_percent,"yoffset_percent": yoffset_percent,"xdistance_percent": xdistance_percent}]})
    pictures = postTinder('/media', data)
    return pictures
    
def delete_picture(tinder_picture_id): #OK
    data = json.dumps({"assets": [tinder_picture_id]})
    pictures = deleteTinder('/media', data)
    return pictures
    
def fb_photos():
    fb_photos_API_url = "https://graph.facebook.com/"+ str(fb_user_id) + "/photos?fields=id&access_token=" + fb_token
    fb_photos = requests.get(fb_photos_API_url)
    pyotherside.send('fb_photos', fb_photos)
    
def send_message(message, matchID):
    data = json.dumps({"message": message})
    postTinder('/user/matches/' + matchID, data)
    
def user(personID): # ERROR 404
    data = json.dumps({})
    user = getTinder('/user/'+ personID, data)
    #pyotherside.send('user', user)
    
"""
@title: Sailfinder helper functions
@description: Sailfinder functions to interact with the Sailfinder API & QML

@author: Dylan Van Assche
"""

def writeFile(path, data):
    homeDir = os.path.expanduser("~")
    os.chdir(homeDir + "/.config/harbour-sailfinder")
    File = open(path, 'w')
    File.write(data)
    File.close()
    
def readFile(path):
    homeDir = os.path.expanduser("~")
    os.chdir(homeDir + "/.config/harbour-sailfinder")
    File = open(path, 'w')
    data = File.readlines()
    File.close()
    return data

def people():
    try:
        homeDir = os.path.expanduser("~")
        os.chdir(homeDir + "/.config/harbour-sailfinder")
        cacheFile = open("cache/matches.cache", 'r')
        data = cacheFile.readlines()
        cacheFile.close()
    except:
        matchesData = matches(last_active)
        pyotherside.send('matches', matchesData)
        
def last_activity(last_activity_ISO_format):
    global last_active
    if(len(last_activity_ISO_format)):
        last_active = last_activity_ISO_format
        writeFile('last_active.txt', last_active)
    else:
        try:
            data = readFile('last_active.txt')
            pyotherside.send('last_active', data)
        except:
            pyotherside.send('last_active', '')
    
#loginTinder(548385795271621,'EAAGm0PX4ZCpsBADZArWaRwrPj1yFpa53RRFeOiwA6y0QDHF9uphAmBtsXQfMlWuQase5TZC8Xed9cxvFzLju7JObFfEdNOllhnb2ph4OHIlbSaQKDZBVPpBDURI522eNdKBKZBY4gl6xAurAZB4YskUAuJdf4MJ4ihKgmwe4QJBgZDZD')
#updates("2016-08-19T07:30:45.247Z")
#meta()
#print upload_picture("", "")
#user('57b364701147f8ad0a59af6e')
#print uploadTinder('test.jpeg', '56d422d94f10e5db60fe7823')
#result = recommendations()
#userID = result['results']
#like(userID[0]['_id'])
#dislike(userID[1]['_id'])
#superlike(userID[2]['_id'])
#upload_FB_picture(10200861059845626)
#print delete_username()
#create_username('modulebaan')
#sharelink('56d422d94f10e5db60fe7823') #MY USER ID
#print '-' * 100
#update_username('modulebaanLOL')
#print '-' * 100
#delete_username()
#profile()