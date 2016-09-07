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
file_version = 'Sailfinder V2.0'

def uploadTinder(imageFile, userID): #BROKEN
    #print 'UPLOAD'
    image = {'media': open('test.jpeg', 'rb')}
    return session.post('https://imageupload.gotinder.com/image?client_photo_id=ProfilePhoto' + str(int(time.time())*1000), json={'userId': userID}, files={'file': open('test.jpeg', 'rb')})
    #return session.post(constants.TINDER_IMAGE_HOST + '/image?client_photo_id=ProfilePhoto' + str(int(time.time())*1000), data={'userId': '56d422d94f10e5db60fe7823'}, files={'file': open('test.jpeg', 'rb')})

def postTinder(url, data): #OK
    #print 'POST'
    result = session.post(constants.TINDER_HOST + url, data=data)
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
            fb_user_id = requests.get(fb_id_API_url).json()
            fb_user_id = fb_user_id['id']
            pyotherside.send('loginFacebook', str(fb_user_id), fb_token)
        except:
            pyotherside.send('loginFacebook', False)

def loginTinder(fb_id, fb_token): #OK
    session.headers.update(constants.HEADERS)
    data = json.dumps({"facebook_id": str(fb_id),"facebook_token": fb_token})
    login = postTinder('/auth', data)
    if 'token' not in login:
        pyotherside.send('loginTinder', False)
        #print 'FAIL'
    else:
        tinder_token = login['token']
        session.headers.update({"X-Auth-Token": str(tinder_token)})
        writeFile('tinder.token', str(tinder_token), False, True)
        pyotherside.send('loginTinder', tinder_token)
        
def read_tinder_token():
    tinder_token = readFile('tinder.token')
    tinder_token = str(tinder_token[0])
    if len(tinder_token) > 5:
        session.headers.update(constants.HEADERS)
        session.headers.update({"X-Auth-Token": tinder_token})
        pyotherside.send('loginTinder', tinder_token)
    else:
        pyotherside.send('loginTinder', False)
        
def remove_tinder_token():
    deleteFile('tinder.token')
    
def recommendations(): #OK
    data = json.dumps({"limit": 10})
    recommendations = postTinder('/user/recs', data)
    format_recommendations(recommendations)
    
def format_recommendations(recommendations):
    try:
        pyotherside.send('recommendations',recommendations['results'])
    except:
        try:
            pyotherside.send('recommendations',recommendations['message'])
        except:
            pyotherside.send('recommendations',recommendations)
            
def like(personID): #OK
    data = json.dumps({})
    result = getTinder('/like/' + personID, data)
    pyotherside.send('like', result)

def dislike(personID): #OK
    data = json.dumps({})
    result = getTinder('/pass/' + personID, data)
    pyotherside.send('dislike', result)
    
def superlike(personID): #OK
    data = json.dumps({})
    result = getTinder('/like/' + personID +'/super', data)
    try:
        if(result['super_likes']['remaining'] == 0):
            resets_in = result['super_likes']['resets_at']
            writeFile('superlike.txt', str(resets_in) + "\n", False, True)
    except:
        pass
    pyotherside.send('superlike', result)
    
def matches(since): #OK
    if(since):
        matches = updates(since)['matches']
    else:
        matches = updates(False)['matches']
    return matches
    
def report(userID, causeID): #NEEDS TESTING
    data = json.dumps({"cause": causeID})
    result = postTinder('/report/' + userID, data)
    pyotherside.send("REPORT_DEBUG", result)
    
def unmatch(matchID): #NEEDS TESTING
    data = json.dumps({})
    result = deleteTinder('/user/matches/' + matchID, data)
    pyotherside.send('UNMATCH_DEBUG', result)

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
    if since:
        data = json.dumps({"last_activity_date:" : str(since)})
        updates = postTinder('/updates', data)
    else:
        data = json.dumps({"last_activity_date:" : str(since)})
        updates = postTinder('/updates', data)
    return updates
    
def meta(): #NOT FOUND HTTP 404, LIKES REMAININGS SEE RESPONDS WHEN LIKE/DISLIKE/SUPERLIKE
#    data = json.dumps({})
#    meta = getTinder('/meta', data)
#    return meta
    return 'API deprecated'
    
def update_location(lat, lon): #OK
    data = json.dumps({"lat": lat, "lon" : lon})
    location = postTinder('/user/ping', data)
    pyotherside.send('location', True)
    
def upload_picture(imageFile): #BROKEN HTTP 500
    pictures = uploadTinder(imageFile)
    return pictures
    
def upload_fb_picture(fb_picture_id, ydistance_percent = 0, xdistance_percent = 0, yoffset_percent = 0, xoffset_percent = 0): #OK
    data = json.dumps({"transmit": "fb", "assets": [{"ydistance_percent": ydistance_percent,"id": fb_picture_id,"xoffset_percent": xoffset_percent,"yoffset_percent": yoffset_percent,"xdistance_percent": xdistance_percent}]})
    pictures = postTinder('/media', data)
    return pictures

def get_fb_albums():
    fb_albums_API_url = "https://graph.facebook.com/v2.6/" + fb_user_id + "/albums?access_token=" + fb_token #EAAGm0PX4ZCpsBAAWDgyqlZAUJiFoHeeOknxuxf5LLz7M97R66tnkE3ZASHubh76HoS1KQxOuFXM1UjqPpYA2bMhIdqBqlW9kxp14tPoSgY9ZABoZA2ZB48USTijQDqhEVYZCZBtkvO5dkYjyQme5SFGTDSDSZCptZAxN4ztqrTPva7WAZDZD "#"https://graph.facebook.com/v2.6/"+ str(548385795271621) + "/albums?access_token=" + fb_token
    fb_albums = requests.get(fb_albums_API_url)
    pyotherside.send('fb_albums', fb_albums.json())

    
def get_fb_pictures(fb_album_id):
    #Get all pictures from our album & parse the JSON code
    fb_photos_API_url = "https://graph.facebook.com/v2.6/" + fb_album_id + "/photos?access_token=" + fb_token #EAAGm0PX4ZCpsBAAWDgyqlZAUJiFoHeeOknxuxf5LLz7M97R66tnkE3ZASHubh76HoS1KQxOuFXM1UjqPpYA2bMhIdqBqlW9kxp14tPoSgY9ZABoZA2ZB48USTijQDqhEVYZCZBtkvO5dkYjyQme5SFGTDSDSZCptZAxN4ztqrTPva7WAZDZD "#"https://graph.facebook.com/v2.6/"+ str(548385795271621) + "/albums?access_token=" + fb_token
    fb_photos = requests.get(fb_photos_API_url).json()
    
    #Parse JSON and get all the urls of those pictures & send them to QML
    for i in range(0, len(fb_photos['data'])):
        fb_photo_id = fb_photos['data'][i]['id']
        fb_photo_API_url = "https://graph.facebook.com/v2.6/" + fb_photo_id + "?fields=source&access_token=" + fb_token
        fb_photo = requests.get(fb_photo_API_url)
        pyotherside.send('fb_photos', fb_photo.json())
    
def delete_picture(tinder_picture_id): #OK
    data = json.dumps({"assets": [tinder_picture_id]})
    pictures = deleteTinder('/media', data)
    return pictures
    
def send_message(message, matchID):
    data = json.dumps({"message": message})
    postTinder('/user/matches/' + matchID, data)

"""
@title: Sailfinder helper functions
@description: Sailfinder functions to interact with the Sailfinder API & QML

@author: Dylan Van Assche
"""

def init_files():
    homeDir = os.path.expanduser("~")
    os.chdir(homeDir + "/.config/")
    if not os.path.exists("harbour-sailfinder/settings/"):
        os.makedirs("harbour-sailfinder/settings/")
    
    # Search for settings.cfg -> depends on Sailfinder version
    if not os.path.isfile("/settings/settings.json"):
        File = open("harbour-sailfinder/settings/settings.json", "w")
        data = {
            'version': file_version,
            'bio': '1',
            'school': '1',
            'job': '1',
            'instagram': '1'
        }
        data = json.dumps(data)
        File.write(data)
        File.close()
    else:
        File = open("harbour-sailfinder/settings/settings.json", "r")
        content = File.readlines()
        File.close()
        version = content['version']

        if not version == file_version:
            File = open("harbour-sailfinder/settings/settings.json", "w")
            data = {
                'version': file_version,
                'bio': '1',
                'school': '1',
                'job': '1',
                'instagram': '1'
            }
            data = json.dumps(data)
            File.write(data)
            File.close()
            
    # Search for tinder.token
    if not os.path.isfile("harbour-sailfinder/tinder.token"):
        File = open("harbour-sailfinder/tinder.token", "w")
        File.write("N/A\n")
        File.close()
        
    # Search for superlikes.txt
    if not os.path.isfile("harbour-sailfinder/superlike.txt"):
        File = open("harbour-sailfinder/superlike.txt", "w")
        File.write("1970-01-01T00:00:00.000Z\n")
        File.close()
        
def writeFile(path, data, version, close): #filepath, data to write, keep version number or not, close file?
    try:
        homeDir = os.path.expanduser("~")
        os.chdir(homeDir + "/.config/harbour-sailfinder")
        File = open(path, 'w')
        if version:
            File.write(file_version +"\n")
        File.write(data)
        if close:
            File.close()
    except:
        return False
    
def readFile(path):
    homeDir = os.path.expanduser("~")
    os.chdir(homeDir + "/.config/harbour-sailfinder")
    File = open(path, 'r')
    data = File.readlines()
    File.close()
    return data
    
def deleteFile(path):
    homeDir = os.path.expanduser("~")
    os.chdir(homeDir + "/.config/harbour-sailfinder")
    os.remove(path)
    
def get_settings():
    homeDir = os.path.expanduser("~")
    os.chdir(homeDir + "/.config/harbour-sailfinder")
    with open('settings/settings.json') as settings_data:
        settings = json.load(settings_data)
    pyotherside.send('settings', settings)
    
def save_settings(bio, school, job, instagram):
    homeDir = os.path.expanduser("~")
    os.chdir(homeDir + "/.config/harbour-sailfinder")
    File = open("settings/settings.json", "w")
    data = {
        'version': file_version,
        'bio': bio,
        'school': school,
        'job': job,
        'instagram': instagram
    }
    data = json.dumps(data)
    File.write(data)
    File.close()
    
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
        writeFile('last_active.txt', last_active, False, True)
    else:
        try:
            data = readFile('last_active.txt')
            pyotherside.send('last_active', data)
        except:
            pyotherside.send('last_active', '')
            
def superlike_available():
    superlike_reset_time = readFile('superlike.txt')
    superlike_reset_time = str(superlike_reset_time[0])
    pyotherside.send('superlike_available', superlike_reset_time)

            
#loginTinder(100003006173920,'EAAGm0PX4ZCpsBAPSkglvNThy2B07aKXDDJvUtJe5B0QxjNXPMBMHeMCJov4F06W1Ts8jRuWeVRayZBCRZBThfZAYTCfoHk9SdXugyBvSo8xjMUAcPFKpy754x3g8XjTq9ZCwZAik97DPPwDzdNIBZAeMA3VGUjJiCu7aXrbKs3BqwZDZD')
#print uploadTinder('test.jpeg', '56d422d94f10e5db60fe7823')
#result = recommendations()
#userID = result['results']
#like(userID[0]['_id'])
#dislike(userID[1]['_id'])
#superlike(userID[2]['_id'])
#upload_FB_picture(10200861059845626)
#print delete_username()
#print create_username('modulebaan')
#print sharelink('56d422d94f10e5db60fe7823') #MY USER ID
#print '-' * 100
#print update_username('modulebaanLOL')
#print '-' * 100
#print delete_username()
