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
import re
import robobrowser
from lib import constants, requests, network, giphy

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
    if(network.connection(True)):
        result = session.post(constants.TINDER_HOST + url, data=data)
        
        if(result.status_code == 200 or result.status_code == 204 or result.status_code == 201):
            try:
                return result.status_code, result.json()
            except:
                return result.status_code, True
        else:
            return result.status_code, False
    else:
        return constants.HTTP_NOT_RESPONDING, False
    
def getTinder(url, data): #OK
    #print 'GET'
    if(network.connection(True)):
        result = session.post(constants.TINDER_HOST + url, data=data)
            
        if(result.status_code == 200 or result.status_code == 204 or result.status_code == 201):
            try:
                return result.status_code, result.json()
            except:
                return result.status_code, True
        else:
            return result.status_code, False
    else:
        return constants.HTTP_NOT_RESPONDING, False
    
def deleteTinder(url, data): #OK
    if(network.connection(True)):
        result = session.delete(constants.TINDER_HOST + url, data=data)
        
        if(result.status_code == 200 or result.status_code == 204 or result.status_code == 201):
            try:
                result.status_code, result.json()
            except:
                return result.status_code, True
        else:
            return result.status_code, False
    else:
        return False
        
def putTinder(url, data): #OK
    if(network.connection(True)):
        result = session.put(constants.TINDER_HOST + url, data=data)
            
        if(result.status_code == 200 or result.status_code == 204 or result.status_code == 201):
            try:
                result.status_code, result.json()
            except:
                return result.status_code, True
        else:
            return result.status_code, False
    else:
        return constants.HTTP_NOT_RESPONDING, False
        
def get_access_token(email, password):
    pyotherside.send("DEBUG", "Getting access token...")
    s = robobrowser.RoboBrowser(user_agent=constants.MOBILE_USER_AGENT, parser="lxml")
    s.open(constants.FB_AUTH)
    #submit login form
    f = s.get_form()
    f["pass"] = password
    f["email"] = email
    s.submit_form(f)
    #click the 'ok' button on the dialog informing you that you have already authenticated with the Tinder app
    f = s.get_form()
    if not 'skip_api_login' in s.url: #Detect of we entered the right credentials, if Facebook doesn't redirect us we did something wrong!
        s.submit_form(f, submit=f.submit_fields[''])
        s.submit_form(f, submit=f.submit_fields['__SUBMIT__'])
        #get access token from the html response
        try:
            access_token = re.search(r"access_token=([\w\d]+)", s.response.content.decode()).groups()[0]
            loginFacebook(access_token)
            writeFile('tinder.token', str(access_token), False, True)
            pyotherside.send("DEBUG", "OK, get FB ID, fb_access_token= " + access_token)
        except:
            access_token = ""
            pyotherside.send("login", "Tinder added as trusted, relogin now")
    else:
        pyotherside.send("login", "Email/Password is wrong, try again.")
        
def loginFacebook(access_token): #OK
    global fb_token
    global fb_user_id
    
    fb_token = access_token
    fb_id_API_url = "https://graph.facebook.com/me?fields=id&access_token=" + fb_token
    try:
        fb_user_id = requests.get(fb_id_API_url).json()  
    except requests.exceptions.ConnectionError as error:
        pyotherside.send('loginFacebook', fb_user_id.status_code)
        pyotherside.send('[DEBUG]', 'LOGIN FACEBOOK failed due Python Requests ERROR' + error)
    fb_user_id = fb_user_id['id']
    pyotherside.send("DEBUG", "OK, get Tinder ACCESS token, FB ID: " + fb_user_id)
    loginTinder(fb_user_id, fb_token)

def loginTinder(fb_id, fb_token): #OK
    session.headers.update(constants.HEADERS)
    data = json.dumps({"facebook_id": str(fb_id),"facebook_token": fb_token})
    status_code, login = postTinder('/auth', data)
    evaluate_network(status_code)
    if 'token' not in login:
        pyotherside.send('loginTinder', False)
        #print 'FAIL'
    else:
        tinder_token = login['token']
        session.headers.update({"X-Auth-Token": str(tinder_token)})
        pyotherside.send('login', tinder_token, fb_token)  
        
def read_tinder_token():
    tinder_token = readFile('tinder.token')
    tinder_token = str(tinder_token[0])
    if len(tinder_token) > 5:
        session.headers.update(constants.HEADERS)
        session.headers.update({"X-Auth-Token": tinder_token})
        pyotherside.send('login', "FB long token:", tinder_token)
        
def remove_tinder_token():
    deleteFile('tinder.token')
    
def recommendations(): #OK
    data = json.dumps({"limit": 10})
    status_code, recommendations = postTinder('/user/recs', data)
    evaluate_network(status_code)
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
    status_code, result = getTinder('/like/' + personID, data)
    evaluate_network(status_code)
    pyotherside.send('like', result)

def dislike(personID): #OK
    data = json.dumps({})
    status_code, result = getTinder('/pass/' + personID, data)
    evaluate_network(status_code)
    pyotherside.send('dislike', result)
    
def superlike(personID): #OK
    data = json.dumps({})
    status_code, result = getTinder('/like/' + personID +'/super', data)
    evaluate_network(status_code)
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
    
def report(userID, causeID): #OK
    data = json.dumps({"cause": causeID})
    status_code, result = postTinder('/report/' + userID, data)
    evaluate_network(status_code)
    pyotherside.send("REPORT_DEBUG", result)
    
def unmatch(matchID): #OK
    data = json.dumps({})
    status_code, result = deleteTinder('/user/matches/' + matchID, data)
    evaluate_network(status_code)
    pyotherside.send('UNMATCH_DEBUG', result)

def profile(): #OK
    data = json.dumps({}) # Get Tinder profile information
    status_code, profile = getTinder('/profile', data)
    evaluate_network(status_code)
    pyotherside.send('profile', profile)
    
    with open('profile/schools.json') as schools_data:
        schools = json.load(schools_data)
    pyotherside.send('schools', schools)
    
    with open('profile/jobs.json') as jobs_data:
        jobs = json.load(jobs_data)
    pyotherside.send('jobs', jobs)
    
def update_profile(discoverable, age_min, age_max, gender, gender_filter, distance, bio): #OK
    data = json.dumps({"discoverable" : discoverable, "age_filter_min" : age_min, "age_filter_max" : age_max, "gender": gender, "gender_filter" : gender_filter, "distance_filter" : distance, "bio": bio})
    status_code, updated_profile = postTinder('/profile', data)
    evaluate_network(status_code)
    pyotherside.send('updated_profile', updated_profile)

def delete_account():
    data = json.dumps({})
    status_code, result = deleteTinder('/profile', data)
    evaluate_network(status_code)
    pyotherside('delete_account', result)

def update_schools(fb_school_id):
    data = json.dumps({"schools": [{"id": 115060918505077}]})
    status_code, schools = putTinder('/profile/school', data)
    evaluate_network(status_code)
    pyotherside.send('DEBUG', schools)
    
def delete_schools():
    data = json.dumps({})
    status_code, schools = deleteTinder('/profile/school', data)
    evaluate_network(status_code)
    pyotherside.send('DEBUG', schools)
    
def update_jobs(fb_job_id):
    data = json.dumps({"company": [{"id": fb_job_id}]})
    status_code, jobs = putTinder('/profile/job', data)
    evaluate_network(status_code)
    pyotherside.send('DEBUG', jobs)
    
def delete_jobs():
    data = json.dumps({})
    status_code, jobs = deleteTinder('/profile/job', data)
    evaluate_network(status_code)
    pyotherside.send('DEBUG', jobs)

def create_username(username): #OK
    data = json.dumps({"username": username})
    status_code, result = postTinder('/profile/username', data)
    evaluate_network(status_code)
    if(result):
        pyotherside.send('username', 1)
    else:
        pyotherside.send('username', False)
    
def update_username(username): #OK
    data = json.dumps({"username": username})
    status_code, result = putTinder('/profile/username', data)
    evaluate_network(status_code)
    #{u'error': u'User has already registered a username'}
    #{u'error': u'User has no username to update'}
    if(result):
        pyotherside.send('username', 2)
    else:
        pyotherside.send('username', False)
    
def delete_username(): #OK
    status_code, result = deleteTinder('/profile/username', None)
    evaluate_network(status_code)
    # {u'error': u'User has no username to remove'}
    if(result):
        pyotherside.send('username', 3)
    else:
        pyotherside.send('username', False)
    
def share_link(tinder_user_id): #OK
    status_code, url = postTinder('/user/' + tinder_user_id + '/share', None)
    evaluate_network(status_code)
    #pyotherside.send('SHARE LINK HTTP CODE', status_code)
    pyotherside.send('sharelink', url)
    
def updates(since): #OK
    if since:
        data = json.dumps({"last_activity_date:" : str(since)})
        status_code, updates = postTinder('/updates', data)
        evaluate_network(status_code)
    else:
        data = json.dumps({"last_activity_date:" : str(since)})
        status_code, updates = postTinder('/updates', data)
        evaluate_network(status_code)
    return updates
    
def meta(): #NOT FOUND HTTP 404, LIKES REMAININGS SEE RESPONDS WHEN LIKE/DISLIKE/SUPERLIKE
#    data = json.dumps({})
#    meta = getTinder('/meta', data)
#    return meta
    return 'API deprecated'
    
def update_location(lat, lon): #OK
    data = json.dumps({"lat": lat, "lon" : lon})
    status_code, location = postTinder('/user/ping', data)
    evaluate_network(status_code)
    pyotherside.send('location', True)
    
def upload_picture(imageFile): #BROKEN HTTP 500
    pictures = uploadTinder(imageFile)
    return pictures
    
def upload_fb_picture(fb_picture_id, ydistance_percent = 0, xdistance_percent = 0, yoffset_percent = 0, xoffset_percent = 0): #OK
    data = json.dumps({"transmit": "fb", "assets": [{"ydistance_percent": ydistance_percent,"id": fb_picture_id,"xoffset_percent": xoffset_percent,"yoffset_percent": yoffset_percent,"xdistance_percent": xdistance_percent}]})
    status_code, pictures = postTinder('/media', data)
    evaluate_network(status_code)
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
    status_code, pictures = deleteTinder('/media', data)
    evaluate_network(status_code)
    return pictures
    
def send_message(message, match_id, gif=False, gif_id=""):
    if(gif):
        data = json.dumps({"type": "GIF", "message": message, "gif_id": gif_id})
    else:
        data = json.dumps({"message": message})
    status_code, result = postTinder('/user/matches/' + match_id, data)
    evaluate_network(status_code)
    pyotherside.send('gif', result, gif)
    
def like_message(like, message_id):
    data = json.dumps({})
    tinder_token = readFile('tinder.token')
    tinder_token = str(tinder_token[0])
    if(like): #Uses a different type of request then the rest of the Tinder API
        result = requests.post(constants.TINDER_HOST + '/message/' + message_id + '/like', headers={"User-Agent": constants.USER_AGENT, "os_version": "90000000001", "app-version": "371", "platform": "android", "Content-type":"text/plain", "X-Auth-Token": str(tinder_token)}, data=data) #postTinder('/message/' + message_id + '/like', data) #Like
    else:
        result = requests.delete(constants.TINDER_HOST + '/message/' + message_id + '/like', headers={"User-Agent": constants.USER_AGENT, "os_version": "90000000001", "app-version": "371", "platform": "android", "X-Auth-Token": str(tinder_token)}) #postTinder('/message/' + message_id + '/like', data) #Dislike
    pyotherside.send('message_like', result.status_code)
    
def get_gifs(search_word='Supergirl'):
    gifs = giphy.search(search_word)
    pyotherside.send('gifs', gifs)
    
"""
@title: Sailfinder FB functions
@description: Interact with the Facebook API to download several items for photo upload, ... 

@author: Dylan Van Assche
"""
    
def get_fb_schools():
    fb_schools_API_url = "https://graph.facebook.com/v2.6/me?fields=education&access_token=" + fb_token 
    fb_schools = requests.get(fb_schools_API_url).json()
    fb_schools = json.dumps(fb_schools)
    writeFile('profile/schools.json', fb_schools, False, True)
    
def get_fb_jobs():
    fb_jobs_API_url = "https://graph.facebook.com/v2.6/me?fields=work&access_token=" + fb_token
    fb_jobs = requests.get(fb_jobs_API_url).json()
    fb_jobs = json.dumps(fb_jobs)
    writeFile('profile/jobs.json', fb_jobs, False, True)    
    
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
        
    if not os.path.exists("harbour-sailfinder/profile/"):
        os.makedirs("harbour-sailfinder/profile/")
    
    # Search for settings.cfg -> depends on Sailfinder version
    if not os.path.isfile("harbour-sailfinder/settings/settings.json"):
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
        with open('harbour-sailfinder/settings/settings.json') as settings_data:
            settings = json.load(settings_data)
        version = settings['version']

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
    
    # Search for schools.json    
    if not os.path.isfile("harbour-sailfinder/profile/schools.json"):
        File = open("harbour-sailfinder/profile/schools.json", "w")
        File.write("N/A\n")
        File.close()
    
    # Search for jobs.json    
    if not os.path.isfile("harbour-sailfinder/profile/jobs.json"):
        File = open("harbour-sailfinder/profile/jobs.json", "w")
        File.write("N/A\n")
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
    
def evaluate_network(status_code):
    status_code = int(status_code)
    if(status_code == constants.HTTP_NOT_RESPONDING or status_code == constants.HTTP_DENIED or status_code == constants.HTTP_NOT_FULLFILL):
        pyotherside.send('network_status', status_code)
