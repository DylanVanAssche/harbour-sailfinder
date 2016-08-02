# -*- coding: utf-8 -*-
"""
Created on Wed Mar  9 20:25:13 2016

@author: Dylan Van Assche
@title: tinder.py
@description: Python script to connect the QML user interface from Sailfinder to the Tinder servers.
"""

#!/usr/bin/env python
# -*- coding: utf-8 -*-

import pyotherside
import pynder
import requests
import os.path
import os
import time

session = 0
people = 0
pictureURL = 0
personsURL = 0
pictureCounterNumberProfile = 0
pictureCounterNumberPersons = 0
personsCounterNumberPersons = 0
pictureCounterNumberAboutPerson = 0;
likeComplete = 0
matches = 0
currentMatch = 0
savedNumber = 0
matchNumberReceived = 0
dataReady = False
currentSavedMatchNumber = 0
currentSavedPersonNumber = 0

def cover():
    pyotherside.send("goBackCover", True)
    
def reconnecting():
    pyotherside.send("defaultCover", True)
    
# Login functions

def login(url):

    try:
        homeDir = os.path.expanduser("~")
        os.chdir(homeDir + "/.config/")
    
        # Intialise config files with the default values only if we can't find them (user deleted the files, first launch, ...)
        if not os.path.exists("harbour-sailfinder/saved/"):
            os.makedirs("harbour-sailfinder/saved/")
    
        if not os.path.exists("harbour-sailfinder/saved/"):
            os.makedirs("harbour-sailfinder/saved/")
    
        # Search for data.cfg
        if not os.path.isfile("harbour-sailfinder/data.cfg"):
            dataFile = open("harbour-sailfinder/data.cfg", "w")
            dataFile.write("Sailfinder V1.5\n")
            dataFile.write("superlikelimit=0\n")
            dataFile.close()
        else:
            dataFile = open("harbour-sailfinder/data.cfg", "r")
            dataFileContent = dataFile.readlines()
            dataFile.close()
            sailfinderVersion = dataFileContent[0]
    
            if not sailfinderVersion == "Sailfinder V1.5\n":
                dataFile = open("harbour-sailfinder/data.cfg", "w")
                dataFile.write("Sailfinder V1.5\n")
                dataFile.write("superlikelimit=0\n")
                dataFile.close()
    
        # Search for localConfiguration.cfg
        if not os.path.isfile("harbour-sailfinder/localConfiguration.cfg"):
            configFile = open("harbour-sailfinder/localConfiguration.cfg", "w")
            configFile.write("Sailfinder V1.5\n")
            configFile.write("gpsUpdateInterval=" + str(5) + "\n")
            configFile.write("dataUpdateInterval=" + str(0) + "\n")
            configFile.write("hintsState=" + str(1) + "\n")
            configFile.write("showBio=" + str(0) + "\n")
            configFile.close()
        else:
            configFile = open("harbour-sailfinder/localConfiguration.cfg", "r")
            configData = configFile.readlines()
            configFile.close()
            sailfinderVersion = configData[0]
            if not sailfinderVersion == "Sailfinder V1.5\n":
                configFile = open("harbour-sailfinder/localConfiguration.cfg", "w")
                configFile.write("Sailfinder V1.5\n")
                configFile.write("gpsUpdateInterval=" + str(5) + "\n")
                configFile.write("dataUpdateInterval=" + str(0) + "\n")
                configFile.write("hintsState=" + str(1) + "\n")
                configFile.write("showBio=" + str(0) + "\n")
                configFile.close()
        
        # Create a new log file.        
        logFile = open("harbour-sailfinder/session.log", 'w')
        logFile.write(str(time.asctime(time.localtime(time.time()))) + " [SESSION] New Sailfinder session" + "\n")
        logFile.close()

    except:
        pyotherside.send('error', "Sailfinder can't write in his directory ~/.config/harbour-sailfinder")
    
    # Get the URL from QML and convert it to a string.
    url = str(url)

    # Search for acces_token in the URL. That URL is the one from the Facebook login.
    urlContains = "access_token"
    if(url.find(urlContains) > 0):
        try:
            # Split the URL into pieces and make a new URL containing this token to get the user his Facebook ID.
            link, authCode, expireTime = url.split("=")
            authCode, trash = authCode.split("&")
            idAPIURL = "https://graph.facebook.com/me?fields=id&access_token=" + authCode

            # Get the user his Facebook ID trough the Graph API and confirm to QML that we are logged into Facebook.
            userIdRequest = requests.get(idAPIURL)
            pyotherside.send('loginFacebookSuccesfully', True)

            # Now connect to the Tinder servers and confirm it again to QML.
            global session
            session = pynder.Session(userIdRequest.text[7:22], authCode)
            global pictureURL
            pictureURL = list(session.profile.photos)
            pyotherside.send('loginTinderSuccesfully', True)

        except pynder.errors.RequestError:
            logFile = open("harbour-sailfinder/session.log", 'a')
            logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Login failed (Pynder Request Error): " + str(pynder.errors.RequestError.args) + "\n")
            logFile.close()
        except pynder.errors.PynderError:
            logFile = open("harbour-sailfinder/session.log", 'a')
            logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Login failed (Pynder Error): " + str(pynder.errors.PynderError.args) + "\n")
            logFile.close()
        except pynder.errors.InitializationError:
            logFile = open("harbour-sailfinder/session.log", 'a')
            logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Login failed (Initialization Error): " + str(pynder.errors.InitializationError.args) + "\n")
            logFile.close()
        except:
            logFile = open("harbour-sailfinder/session.log", 'a')
            logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Login failed (Unknown Error)\n")
            logFile.close()

# Get the data update intervals from the saved settings.
def updateInterval():
    try:
        configFile = open("harbour-sailfinder/localConfiguration.cfg", 'r')
        configData = configFile.readlines()
        configFile.close()
        gpsUpdateInterval = str(configData[1])
        dataUpdateInterval = str(configData[2])
        pyotherside.send('getUpdateInterval', dataUpdateInterval[19:22], gpsUpdateInterval[18:20])
        
    except IOError:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime( time.localtime(time.time()) )) + " [ERROR] Get updateInterval failed: Can't read from ~/.config/harbour-sailfinder/localConfiguration.conf (I/O Error)\n")
        logFile.close()
    except:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime( time.localtime(time.time()) )) + " [ERROR] Get updateInterval failed (Unknown Error)\n")
        logFile.close()

# Profile functions for the user.

def loadProfile(pictureNumber, firstPass):
    try:
        pictureNumber = int(pictureNumber)
        global pictureCounterNumberProfile
    
        # Navigate through the array based on the QML commands.
        if pictureNumber == 1 and pictureCounterNumberProfile < (len(pictureURL)-1):
            pictureCounterNumberProfile += 1
    
        elif pictureNumber == 2 and pictureCounterNumberProfile > 0:
            pictureCounterNumberProfile -= 1
    
        elif pictureNumber == 0:
            pictureCounterNumberProfile = 0
    
        # Handle the button navigation.
        if pictureCounterNumberProfile == (len(pictureURL)-1):
            if(len(pictureURL)-1 == 0):
                pyotherside.send('getProfilePictureNavigation', 3)
            else:
                pyotherside.send('getProfilePictureNavigation', 1)
    
        elif pictureCounterNumberProfile == 0 and firstPass == False:
            pyotherside.send('getProfilePictureNavigation', 2)
    
        elif firstPass == False:
            pyotherside.send('getProfilePictureNavigation', 4)
    
        # Get the user name, bio and gender
        if(session.profile.gender == "male"):
            currentIndexGender = 0
        else:
            currentIndexGender = 1
    
        pyotherside.send('getProfileData', session.profile.name, session.profile.bio, currentIndexGender)
    
        # Get the user picture.
        pyotherside.send('getProfilePicture', pictureURL[pictureCounterNumberProfile])
        
    except pynder.errors.RequestError:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Loading profile failed (Pynder Request Error): " + str(pynder.errors.RequestError.args) + "\n")
        logFile.close()
    except pynder.errors.PynderError:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Loading profile failed (Pynder Error): " + str(pynder.errors.PynderError.args) + "\n")
        logFile.close()
    except pynder.errors.InitializationError:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Loading profile failed (Initialization Error): " + str(pynder.errors.InitializationError.args) + "\n")
        logFile.close()
    except:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Loading profile failed (Unknown Error)\n")
        logFile.close()

def updateProfile(bio, gender):
    try:
        session.profile.bio = bio
        if(gender == 1):
            genderName = "male"
        else:
            genderName = "female"
        session.profile.gender = genderName
        loadProfile(0, True)
        
    except pynder.errors.RequestError:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Updating profile failed (Pynder Request Error): " + str(pynder.errors.RequestError.args) + "\n")
        logFile.close()
    except pynder.errors.PynderError:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Updating profile failed (Pynder Error): " + str(pynder.errors.PynderError.args) + "\n")
        logFile.close()
    except pynder.errors.InitializationError:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Updating profile failed (Initialization Error): " + str(pynder.errors.InitializationError.args) + "\n")
        logFile.close()
    except:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Updating profile failed (Unknown Error)\n")
        logFile.close()
        
def uploadPictureProfile():
    session.upload_test()

def updateLocation(latitude, longitude):
    try:
        session.update_location(str(latitude), str(longitude))
        
    except pynder.errors.RequestError:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Updating location failed (Pynder Request Error): " + str(pynder.errors.RequestError.args) + "\n")
        logFile.close()
    except pynder.errors.PynderError:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Updating location failed (Pynder Error): " + str(pynder.errors.PynderError.args) + "\n")
        logFile.close()
    except pynder.errors.InitializationError:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Updating location failed (Initialization Error): " + str(pynder.errors.InitializationError.args) + "\n")
        logFile.close()
    except:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Updating location failed (Unknown Error)" + "\n")
        logFile.close()
        
def updateSettings(dataUpdateInterval, hintsState, discoverableState, interestedInIndex, minAge, maxAge, searchDistance, gpsUpdateInterval, showBio):
    try:    
        interestedInIndex = int(interestedInIndex)
        dataUpdateInterval = int(dataUpdateInterval)
    
        if interestedInIndex == 0:
            interestedIn = "male"
        elif interestedInIndex == 1:
            interestedIn = "female"
        #else:
            #interestedIn = "both" NOT AVAILABLE IN PYNDER YET
    
        session.profile.discoverable = discoverableState
        session.profile.interested_in = interestedIn
        session.profile.age_filter_min = minAge
        session.profile.age_filter_max = maxAge
        session.profile.distance_filter = round(searchDistance/1.609344,0)
    
        configFile = open("harbour-sailfinder/localConfiguration.cfg", "w")
        configFile.write("Sailfinder V1.5\n")
        configFile.write("gpsUpdateInterval=" + str(int(gpsUpdateInterval)) + "\n")
        configFile.write("dataUpdateInterval=" + str(int(dataUpdateInterval)) + "\n")
        configFile.write("hintsState=" + str(int(hintsState)) + "\n")
        configFile.write("showBio=" + str(int(showBio)) + "\n")
        configFile.close()
     
        configFile = open("harbour-sailfinder/localConfiguration.cfg", 'r')
        configData = configFile.readlines()
        configFile.close()
        gpsUpdateInterval = str(configData[1])
        dataUpdateInterval = str(configData[2])
        pyotherside.send('getUpdateInterval', dataUpdateInterval[19:22], gpsUpdateInterval[18:20])
        loadNewPeople()
        loadPerson(0, 0, True)
        hintsHandler(0)
        
    except pynder.errors.RequestError:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Updating settings failed (Pynder Request Error): " + str(pynder.errors.RequestError.args) + "\n")
        logFile.close()
    except pynder.errors.PynderError:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Updating settings failed (Pynder Error): " + str(pynder.errors.PynderError.args) + "\n")
        logFile.close()
    except pynder.errors.InitializationError:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Updating settings failed (Initialization Error): " + str(pynder.errors.InitializationError.args) + "\n")
        logFile.close()
    except IOError:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Updating settings failed (I/O Error): can't read from ~/.config/harbour-sailfinder/localConfiguration.conf\n")
        logFile.close()
    except:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Updating settings failed (Unknown Error)\n")
        logFile.close()

def getSettings():
    try:
        interestedInValue = list(session.profile.interested_in)
    
        if str(interestedInValue[0]) == "male":
            interestedInIndex = 0
        elif str(interestedInValue[0]) == "female":
            interestedInIndex = 1
        else:
            interestedInIndex = 2
    
        configFile = open("harbour-sailfinder/localConfiguration.cfg", 'r')
        configData = configFile.readlines()
        configFile.close()
        gpsUpdateInterval = str(configData[1])
        dataUpdateInterval = str(configData[2])
        hintsState = str(configData[3])
        hintsState = int(hintsState[11:12])
        showBio = str(configData[4])
        pyotherside.send('getSettings', dataUpdateInterval[19:22], hintsState, session.profile.discoverable, interestedInIndex, session.profile.age_filter_min, session.profile.age_filter_max, session.profile.distance_filter*1.609344, gpsUpdateInterval[18:20], int(showBio[8:9]))
    
    except pynder.errors.RequestError:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Get settings failed (Pynder Request Error): " + str(pynder.errors.RequestError.args) + "\n")
        logFile.close()
    except pynder.errors.PynderError:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Get settings failed (Pynder Error): " + str(pynder.errors.PynderError.args) + "\n")
        logFile.close()
    except pynder.errors.InitializationError:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Get settings failed (Initialization Error): " + str(pynder.errors.InitializationError.args) + "\n")
        logFile.close()
    except IOError:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Get settings failed (I/O Error): can't read from ~/.config/harbour-sailfinder/localConfiguration.conf\n")
        logFile.close()
    except:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Get settings failed (Unknown Error)\n")
        logFile.close()

# Main functions for liking, disliking and superliking.

def loadPerson(pictureNumber, personsNumber, firstPass):
    try:
        global pictureCounterNumberPersons
        global personsCounterNumberPersons
        global pictures
        
#        metaDict = session.likes_remaining
#        for keys in metaDict:
#            pyotherside.send('META DATA', metaDict[keys])
    
        if session.likes_remaining > 0:
    
            #Get the Tinder profiles to swipe them.
            pictureNumber = int(pictureNumber)
            personsNumber = int(personsNumber)
    
            if personsNumber == 1:
                personsCounterNumberPersons += 1
                if personsCounterNumberPersons > (len(people)-1):
                    loadNewPeople()
                    personsCounterNumberPersons = 0
                    pictureCounterNumberPersons = 0
                    loadPerson(0, 0, True)
    
            if people:
                pictures = list(people[personsCounterNumberPersons].photos)
    
                if pictureNumber == 1 and pictureCounterNumberPersons < (len(pictures)-1):
                    pictureCounterNumberPersons += 1
    
                elif pictureNumber == 2 and pictureCounterNumberPersons > 0:
                    pictureCounterNumberPersons -= 1
    
                elif pictureNumber == 0:
                    pictureCounterNumberPersons = 0
    
                #Handle the button navigation.
                if pictureCounterNumberPersons == (len(pictures)-1):
                    if(len(pictures)-1 == 0):
                        pyotherside.send('getPersonPictureNavigation', 3)
    
                    else:
                        pyotherside.send('getPersonPictureNavigation', 1)
    
                elif pictureCounterNumberPersons == 0 and firstPass == False:
                    pyotherside.send('getPersonPictureNavigation', 2)
    
                elif firstPass == False:
                    pyotherside.send('getPersonPictureNavigation', 4)
                    
                configFile = open("harbour-sailfinder/localConfiguration.cfg", 'r')
                configData = configFile.readlines()
                configFile.close()
                showBio = str(configData[4])
                showBio = int(showBio[8:9])
    
                #Get the all the data about our person.
                pyotherside.send('getDataMain', people[personsCounterNumberPersons].name, people[personsCounterNumberPersons].age, people[personsCounterNumberPersons].gender, round(people[personsCounterNumberPersons].distance_km, 1))
    
                #Get the person picture.
                pyotherside.send('getPersonPicture', pictures[pictureCounterNumberPersons])
                
                #Get the person bio, if enabled.
                if(showBio):
                    pyotherside.send('getBio', people[personsCounterNumberPersons].bio)
    
            else:
                #Reload when persons is empty until loadNewPersons is done...
                pyotherside.send('noUsersNearby', True)
    
        else:
            configFile = open("harbour-sailfinder/localConfiguration.cfg", 'r')
            configData = configFile.readlines()
            configFile.close()
            gpsUpdateInterval = str(configData[1])
            dataUpdateInterval = str(configData[2])
            pyotherside.send('getUpdateInterval', dataUpdateInterval[19:22], gpsUpdateInterval[18:20])
            hours = (session.can_like_in / 3600)
            hours = int(hours)
            minutes = (session.can_like_in / 60) - hours * 60
            minutes = int(minutes)
            timeRemaining = str(hours) + 'h ' + str(minutes) + 'min'
            dataFile = open("harbour-sailfinder/data.cfg", "w")
            dataFile.write("Sailfinder V1.5\n")
            dataFile.write("superlikelimit=0\n")
            dataFile.close()
            pyotherside.send('canLikeIn', timeRemaining)
            
    except pynder.errors.RequestError:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Loading person failed (Pynder Request Error): " + str(pynder.errors.RequestError.args) + "\n")
        logFile.close()
    except pynder.errors.PynderError:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Loading person failed (Pynder Error): " + str(pynder.errors.PynderError.args) + "\n")
        logFile.close()
    except pynder.errors.InitializationError:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Loading person failed (Initialization Error): " + str(pynder.errors.InitializationError.args) + "\n")
        logFile.close()
    except IOError:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Loading person failed (I/O Error): can't read from ~/.config/harbour-sailfinder/data.conf\n")
        logFile.close()
    except:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Loading person failed (Unknown Error)\n")
        logFile.close()

def loadNewPeople():
    try:
        pyotherside.send('loadingNewPeople', True)
        global people
        people = session.nearby_users()
        
    except pynder.errors.RequestError:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Loading new people failed (Pynder Request Error): " + str(pynder.errors.RequestError.args) + "\n")
        logFile.close()
    except pynder.errors.PynderError:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Loading new people failed (Pynder Error): " + str(pynder.errors.PynderError.args) + "\n")
        logFile.close()
    except pynder.errors.InitializationError:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Loading new people failed (Initialization Error): " + str(pynder.errors.InitializationError.args) + "\n")
        logFile.close()
    except:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Loading new people failed (Unknown Error)\n")
        logFile.close()

def hintsHandler(pageNumber):
    try:
        configFile = open("harbour-sailfinder/localConfiguration.cfg", 'r')
        configData = configFile.readlines()
        configFile.close()
        hintsState = str(configData[3])
        hintsState = int(hintsState[11:12])
    
        if(hintsState):
            if(pageNumber == 0):
                pyotherside.send('getHintsStateMain', True)
            elif(pageNumber == 1):
                pyotherside.send('getHintsStateProfile', True)
            elif(pageNumber == 2):
                pyotherside.send('getHintsStateMatches', True)
        else:
            if(pageNumber == 0):
                pyotherside.send('getHintsStateMain', False)
            elif(pageNumber == 1):
                pyotherside.send('getHintsStateProfile', False)
            elif(pageNumber == 2):
                pyotherside.send('getHintsStateMatches', False)
                
    except IOError:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] hintsHandler (I/O Error): can't read from ~/.config/harbour-sailfinder/localConfiguration.conf\n")
        logFile.close()
    except:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] hintsHandler (Unknown Error)\n")
        logFile.close()

def likeDislikeSuperlikePerson(action):
    try:
        global likeComplete
    
        # Determine user action: like, dislike or superLike
        # Dislike
        if action == 1:
            try:
                people[personsCounterNumberPersons].dislike()
                pyotherside.send('getPersonPictureNavigation', 2)
            except:
                logFile = open("harbour-sailfinder/session.log", 'a')
                logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Disliking failed!\n")
                logFile.close()
    
        # Like
        elif action == 2:
            try:
                pyotherside.send('resultAction', people[personsCounterNumberPersons].like())
            except:
                logFile = open("harbour-sailfinder/session.log", 'a')
                logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Liking failed!\n")
                logFile.close()
    
            pyotherside.send('getPersonPictureNavigation', 2)
    
        # Superlike
        elif action == 3:
            try:
                pyotherside.send('resultAction', 3)
                pyotherside.send('resultAction', people[personsCounterNumberPersons].superlike())
                dataFile = open("harbour-sailfinder/data.cfg", "w")
                dataFile.write("Sailfinder V1.5\n")
                dataFile.write("superlikelimit=1\n")
                dataFile.close()
            except:
                try:
                    pyotherside.send('resultAction', 3)
                    pyotherside.send('resultAction', people[personsCounterNumberPersons].like())
                except:
                    logFile = open("harbour-sailfinder/session.log", 'a')
                    logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Out of SuperLikes + liking failed!\n")
                    logFile.close()
            pyotherside.send('getPersonPictureNavigation', 2)
    
        likeComplete = True
        loadPerson(0, 1, likeComplete)
        
    except pynder.errors.RequestError:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Liking/Disliking/Superliking failed (Pynder Request Error): " + str(pynder.errors.RequestError.args) + "\n")
        logFile.close()
    except pynder.errors.PynderError:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Liking/Disliking/Superliking failed (Pynder Error): " + str(pynder.errors.PynderError.args) + "\n")
        logFile.close()
    except pynder.errors.InitializationError:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Liking/Disliking/Superliking failed (Initialization Error): " + str(pynder.errors.InitializationError.args) + "\n")
        logFile.close()
    except:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Liking/Disliking/Superliking failed (Unknown Error)\n")
        logFile.close()

# Get more information about a person

def loadAbout(aboutType, number):
    global savedNumber
    currentMatch = number

    if aboutType == 'person':
        # Get our person data... 
        try:
            job = ''
            school = ''  
            try:
                job = people[personsCounterNumberPersons].jobs[0]
                school = people[personsCounterNumberPersons].schools[0]
            except: 
                pass
            for i in range(1, len(people[personsCounterNumberPersons].jobs)):
                job += ',' + people[personsCounterNumberPersons].jobs[i]

            for i in range(1, len(people[personsCounterNumberPersons].schools)):
                school += ',' + people[personsCounterNumberPersons].schools[i]

            pingTime = str(people[personsCounterNumberPersons].ping_time)
            date, time = pingTime.split("T")
            year, month, day = date.split("-")
            pyotherside.send('getDataAbout', 'person',people[personsCounterNumberPersons].name, people[personsCounterNumberPersons].age, people[personsCounterNumberPersons].gender, round(people[personsCounterNumberPersons].distance_km, 1), day, month, year, time[0: len(time)-5], people[personsCounterNumberPersons].bio, people[personsCounterNumberPersons].instagram_username, school, job, '')

            #Get the person pictures.
            for i in range(len(pictures)):
                pyotherside.send('getPictures', i, people[personsCounterNumberPersons].photos[i])
                
        except pynder.errors.RequestError:
            logFile = open("harbour-sailfinder/session.log", 'a')
            logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Loading about person failed (Pynder Request Error): " + str(pynder.errors.RequestError.args) + "\n")
            logFile.close()
        except pynder.errors.PynderError:
            logFile = open("harbour-sailfinder/session.log", 'a')
            logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Loading about person failed (Pynder Error): " + str(pynder.errors.PynderError.args) + "\n")
            logFile.close()
        except pynder.errors.InitializationError:
            logFile = open("harbour-sailfinder/session.log", 'a')
            logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Loading about person failed (Initialization Error): " + str(pynder.errors.InitializationError.args) + "\n")
            logFile.close()
        except:
            logFile = open("harbour-sailfinder/session.log", 'a')
            logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Loading about person failed (Unknown Error)\n")
            logFile.close()

    elif aboutType == 'match':
        # Get our match data...
        try:
            job = ''
            school = ''
            try:
                job = matches[currentMatch].user.jobs[0]
                school = matches[currentMatch].user.schools[0]
            except:
                pass
            for i in range(1, len(matches[currentMatch].user.jobs)):
                job += ',' + matches[currentMatch].user.jobs[i]

            for i in range(1, len(matches[currentMatch].user.schools)):
                school += ',' + matches[currentMatch].user.schools[i]

            pingTime = str(matches[currentMatch].user.ping_time)
            date, time = pingTime.split("T")
            year, month, day = date.split("-")
            pyotherside.send('getDataAbout', 'match', matches[currentMatch].user.name, matches[currentMatch].user.age, matches[currentMatch].user.gender, round(matches[currentMatch].user.distance_km, 1), day, month, year, time[0: len(time)-5], matches[currentMatch].user.bio, matches[currentMatch].user.instagram_username, school, job, number)

            #Get the person pictures.
            for i in range(len(matches[currentMatch].user.photos)):
                pyotherside.send('getPictures', i, matches[currentMatch].user.photos[i])
                
        except pynder.errors.RequestError:
            logFile = open("harbour-sailfinder/session.log", 'a')
            logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Loading about match failed (Pynder Request Error): " + str(pynder.errors.RequestError.args) + "\n")
            logFile.close()
        except pynder.errors.PynderError:
            logFile = open("harbour-sailfinder/session.log", 'a')
            logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Loading about match failed (Pynder Error): " + str(pynder.errors.PynderError.args) + "\n")
            logFile.close()
        except pynder.errors.InitializationError:
            logFile = open("harbour-sailfinder/session.log", 'a')
            logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Loading about match failed (Initialization Error): " + str(pynder.errors.InitializationError.args) + "\n")
            logFile.close()
        except:
            logFile = open("harbour-sailfinder/session.log", 'a')
            logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Loading about match failed (Unknown Error)\n")
            logFile.close()

    elif aboutType == 'saved':
        savedNumber = number - len(matches)
        savedDir = os.listdir("harbour-sailfinder/saved/")
        dataDir = os.listdir("harbour-sailfinder/saved/" + str(savedDir[savedNumber]) + "/")
        name, dateSaved, timeSaved = savedDir[savedNumber].split('_')
        
        dataFile = open("harbour-sailfinder/saved/" + str(savedDir[savedNumber]) + "/" + str(name) + ".data","r")
        data = dataFile.readlines()
        dataFile.close();
        name = data[0]
        age = data[1]
        gender = data[2]   
        distance_km = data[3]
        jobs = data[4]
        schools = data[5]
        instagram_username = data[6]
        if instagram_username[19:len(instagram_username)-1] == 'None':
            instagram_username = ''
        bio = ''
        for i in range(7, len(data)):
            bio += data[i]
        
        # Send it to QML
        pyotherside.send('getDataAbout', 'saved', str(name[5:len(name)-1]), str(age[4:len(age)-1]), str(gender[7:len(gender)-1]), str(distance_km[12:16]), '', '', '', '', str(bio[4:len(bio)-1]), str(instagram_username[19:len(instagram_username)-1]), str(schools[8:len(schools)-1]), str(jobs[5:len(jobs)-1]), str(savedDir[savedNumber]))
        
        # Load the pictures. Safety: in the directory there can be only 6 images + 1 data file (or less images)
        if len(dataDir) <= 7:
            for i in range(0, len(dataDir)-1):
                pyotherside.send('getPictures', i, "file://" + os.getcwd() + "/harbour-sailfinder/saved/" + str(savedDir[savedNumber]) + "/picture" + str(i) + ".jpg")
        
  
# Save a person or a match to our phone.          
def save(saveType, indentifier):
    try:
        # Date & time creation avoid conflicts with other names.
        creationTime = time.strftime("%Y-%m-%d_%H:%M:%S", time.gmtime())  
        
        if saveType == 'person':
            name = people[personsCounterNumberPersons].name
            name = strip_non_ascii(name)
            
            # Create a dir to store our data
            if not os.path.exists("harbour-sailfinder/saved/" + str(name) + "_" + str(creationTime) + "/"):
                os.makedirs("harbour-sailfinder/saved/" + str(name) + "_" + str(creationTime) + "/")
                
            # Open the name.data file and write all the information to it.
            personFile = open("harbour-sailfinder/saved/" + str(name) + "_" + str(creationTime) + "/" + str(name) + ".data", "w")
            personFile.write("name=" + name + "\n")
            personFile.write("age=" + str(people[personsCounterNumberPersons].age) + "\n")
            personFile.write("gender=" + str(people[personsCounterNumberPersons].gender) + "\n")
            personFile.write("distance_km=" + str(people[personsCounterNumberPersons].distance_km) + "\n")
            job = str(people[personsCounterNumberPersons].jobs)
            job = job.replace("', '","",len(job))
            job = strip_non_ascii(job)
            personFile.write("jobs=" + str(job[2:len(job)-2]) + "\n")
            school = str(people[personsCounterNumberPersons].schools)
            school = school.replace("', '","",len(school))
            school = strip_non_ascii(school)
            personFile.write("schools=" + str(school[2:len(school)-2]) + "\n")
            personFile.write("instagram_username=" + str(people[personsCounterNumberPersons].instagram_username) + "\n")
            bio = str(people[personsCounterNumberPersons].bio)
            bio = strip_non_ascii(bio)
            personFile.write("bio=" + str(bio) + "\n")
            personFile.close()
            
            # Download the pictures and store them.
            for i in range(0, len(people[personsCounterNumberPersons].photos)):
                pictureFile = open("harbour-sailfinder/saved/" + str(name) + "_" + str(creationTime) + "/" + "picture" + str(i) +".jpg", "wb")
                pictureFile.write(requests.get(str(people[personsCounterNumberPersons].photos[i])).content)
                pictureFile.close()
            
        elif saveType == 'match':
            indentifier = int(indentifier)
            pyotherside.send('DEBUG', indentifier)
            name = matches[indentifier].user.name
            name = strip_non_ascii(name)
            
            # Create a dir to store our data
            if not os.path.exists("harbour-sailfinder/saved/" + str(name) + "_" + str(creationTime) + "/"):
                os.makedirs("harbour-sailfinder/saved/" + str(name) + "_" + str(creationTime) + "/")
                
            # Open the name.data file and write all the information to it.
            personFile = open("harbour-sailfinder/saved/" + str(name) + "_" + str(creationTime) + "/" + str(name) + ".data", "w")
            personFile.write("name=" + name + "\n")
            personFile.write("age=" + str(matches[indentifier].user.age) + "\n")
            personFile.write("gender=" + str(matches[indentifier].user.gender) + "\n")
            personFile.write("distance_km=" + str(matches[indentifier].user.distance_km) + "\n")
            job = str(matches[indentifier].user.jobs)
            job = job.replace("', '","",len(job))
            job = strip_non_ascii(job)
            personFile.write("jobs=" + str(job[2:len(job)-2]) + "\n")
            school = str(matches[indentifier].user.schools)
            school = school.replace("', '","",len(school))
            school = strip_non_ascii(school)
            personFile.write("schools=" + str(school[2:len(school)-2]) + "\n")
            personFile.write("instagram_username=" + str(matches[indentifier].user.instagram_username) + "\n")
            bio = str(matches[indentifier].user.bio)
            bio = strip_non_ascii(bio)
            personFile.write("bio=" + str(bio) + "\n")
            personFile.close()
                    
            # Download the pictures and store them.
            for i in range(0, len(matches[indentifier].user.photos)):
                pictureFile = open("harbour-sailfinder/saved/" + str(name) + "_" + str(creationTime) + "/" + "picture" + str(i) +".jpg", "wb")
                pictureFile.write(requests.get(str(matches[indentifier].user.photos[i])).content)
                pictureFile.close()
            
            # Refresh the matches list
            pyotherside.send('clearList', True)
            
    except IOError:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime( time.localtime(time.time()) )) + " [ERROR] Get updateInterval failed: Can't read from ~/.config/harbour-sailfinder/localConfiguration.conf (I/O Error)\n")
        logFile.close()
    except:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Loading about match failed (Unknown Error)\n")
        logFile.close()

# Writing files is only allowed with ASCII code.  
def strip_non_ascii(string):
    try:
        stripped = (c for c in string if 0 < ord(c) < 127)
        return ''.join(stripped)
    except:
        pass
    
def loadSaved():
    
    # list all our saved matches
    saved = os.listdir("harbour-sailfinder/saved/")
   
    for i in range(0,len(saved)):
        try:
            name, dateSaved, timeSaved = saved[i].split('_')
            pyotherside.send('getSaved', name, os.getcwd() + "/harbour-sailfinder/saved/" + str(saved[i]) + "/picture0.jpg", i)
            
        except IOError:
            logFile = open("harbour-sailfinder/session.log", 'a')
            logFile.write(str(time.asctime( time.localtime(time.time()) )) + " [ERROR] Get updateInterval failed: Can't read from ~/.config/harbour-sailfinder/localConfiguration.conf (I/O Error)\n")
            logFile.close()
        except:
            logFile = open("harbour-sailfinder/session.log", 'a')
            logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Failed to load match from loadMatches() (Unknown Error)\n")
            logFile.close()
            
def deleteSaved(dirName):
    try:
        savedDir = os.listdir(os.getcwd() + "/harbour-sailfinder/saved/")
        
        for i in range (len(savedDir)):
            if dirName in savedDir[i]:
                dataDir = os.listdir(os.getcwd() + "/harbour-sailfinder/saved/" + str(savedDir[i]) + "/")
                #Remove all the files
                for j in range(len(dataDir)):
                    os.remove(os.getcwd() + "/harbour-sailfinder/saved/" + str(savedDir[i]) + "/" + str(dataDir[j]))
                    
                #Remove the empty directory    
                os.rmdir(os.getcwd() + "/harbour-sailfinder/saved/" + str(savedDir[i]) + "/")
        
        pyotherside.send('clearList', True)
        
    except IOError:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime( time.localtime(time.time()) )) + " [ERROR] Get updateInterval failed: Can't read from ~/.config/harbour-sailfinder/localConfiguration.conf (I/O Error)\n")
        logFile.close()
    except:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Failed to load match from loadMatches() (Unknown Error)\n")
        logFile.close()
            
# Matches and messaging functions

# When we matched with another user after we liked them we need to show an overlay with the message 'You and USER matched !'.
def handlerNewMatch(state):
    # Get the name and the picture.
    try:
        if state == 1:
            pyotherside.send('getPersonData', people[personsCounterNumberPersons-1].name, people[personsCounterNumberPersons-1].photos[0])
    
    except pynder.errors.RequestError:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] handlerNewMatch() failed to load data (Pynder Request Error): " + str(pynder.errors.RequestError.args) + "\n")
        logFile.close()
    except pynder.errors.PynderError:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] handlerNewMatch() failed to load data (Pynder Error): " + str(pynder.errors.PynderError.args) + "\n")
        logFile.close()
    except pynder.errors.InitializationError:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] handlerNewMatch() failed to load data (Initialization Error): " + str(pynder.errors.InitializationError.args) + "\n")
        logFile.close()
    except:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] handlerNewMatch() failed to load data (Unknown Error)\n")
        logFile.close()

    # Button 1: Keep swiping -> load next person.
    try:
        if state == 2:
            loadPerson(0, 1, True)
            
    except pynder.errors.RequestError:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] handlerNewMatch() failed to load data (Pynder Request Error): " + str(pynder.errors.RequestError.args) + "\n")
        logFile.close()
    except pynder.errors.PynderError:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] handlerNewMatch() failed to load data (Pynder Error): " + str(pynder.errors.PynderError.args) + "\n")
        logFile.close()
    except pynder.errors.InitializationError:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] handlerNewMatch() failed to load data (Initialization Error): " + str(pynder.errors.InitializationError.args) + "\n")
        logFile.close()
    except:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] handlerNewMatch() failed to load data (Unknown Error)\n")
        logFile.close()

    # Button 2: Send message -> Go to the message page.
    try:
        if state == 3:
            loadNewMatches()
            loadMessages(len(matches)-1)
            
    except pynder.errors.RequestError:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] handlerNewMatch() failed to load data (Pynder Request Error): " + str(pynder.errors.RequestError.args) + "\n")
        logFile.close()
    except pynder.errors.PynderError:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] handlerNewMatch() failed to load data (Pynder Error): " + str(pynder.errors.PynderError.args) + "\n")
        logFile.close()
    except pynder.errors.InitializationError:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] handlerNewMatch() failed to load data (Initialization Error): " + str(pynder.errors.InitializationError.args) + "\n")
        logFile.close()
    except:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] handlerNewMatch() failed to load data (Unknown Error)\n")
        logFile.close()

# Get all the matches of our user from Tinder and send them to QML one-by-one to create a list.
def loadMatches():
    for i in range(0,len(matches)):
        try:
            pictureURLMatch = matches[i].user.photos
            nameMatch = matches[i].user.name
            pyotherside.send('getMatch', nameMatch, pictureURLMatch[0], i)
            
        except pynder.errors.RequestError:
            logFile = open("harbour-sailfinder/session.log", 'a')
            logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Failed to load match from loadMatches() (Pynder Request Error): " + str(pynder.errors.RequestError.args) + "\n")
            logFile.close()
        except pynder.errors.PynderError:
            logFile = open("harbour-sailfinder/session.log", 'a')
            logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Failed to load match from loadMatches() (Pynder Error): " + str(pynder.errors.PynderError.args) + "\n")
            logFile.close()
        except pynder.errors.InitializationError:
            logFile = open("harbour-sailfinder/session.log", 'a')
            logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Failed to load match from loadMatches() (Initialization Error): " + str(pynder.errors.InitializationError.args) + "\n")
            logFile.close()
        except:
            logFile = open("harbour-sailfinder/session.log", 'a')
            logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Failed to load match from loadMatches() (Unknown Error)\n")
            logFile.close()

# Check for new matches after our last refresh.
def loadNewMatches():
    global matches
    try:
        matches = session.matches()
        
    except pynder.errors.RequestError:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Failed to get new matches (Pynder Request Error): " + str(pynder.errors.RequestError.args) + "\n")
        logFile.close()
    except pynder.errors.PynderError:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Failed to get new matches (Pynder Error): " + str(pynder.errors.PynderError.args) + "\n")
        logFile.close()
    except pynder.errors.InitializationError:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Failed to get new matches (Initialization Error): " + str(pynder.errors.InitializationError.args) + "\n")
        logFile.close()
    except:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Failed to get new matches (Unknown Error)\n")
        logFile.close()

def deleteMatch(matchIndex, name):
    try:
        if name == matches[matchIndex].user.name:
            matches[matchIndex].delete()
            pyotherside.send('clearList', True)
        
    except pynder.errors.RequestError:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Failed to delete match (Pynder Request Error): " + str(pynder.errors.RequestError.args) + "\n")
        logFile.close()
    except pynder.errors.PynderError:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Failed to delete match (Pynder Error): " + str(pynder.errors.PynderError.args) + "\n")
        logFile.close()
    except pynder.errors.InitializationError:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Failed to delete match (Initialization Error): " + str(pynder.errors.InitializationError.args) + "\n")
        logFile.close()
    except:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Failed to delete match (Unknown Error)\n")
        logFile.close()

def report(typeUser, cause):
    try:
        cause = int(cause)
        if typeUser == 'person':
            people[personsCounterNumberPersons].report(cause)
        else:
            matches[currentMatch].user.report(cause)
            
    except pynder.errors.RequestError:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Failed to report (Pynder Request Error): " + str(pynder.errors.RequestError.args) + "\n")
        logFile.close()
    except pynder.errors.PynderError:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Failed to report (Pynder Error): " + str(pynder.errors.PynderError.args) + "\n")
        logFile.close()
    except pynder.errors.InitializationError:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Failed to report (Initialization Error): " + str(pynder.errors.InitializationError.args) + "\n")
        logFile.close()
    except:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Failed to report (Unknown Error)\n")
        logFile.close()

# Handle the messages for a match.

def loadAboutMessages():
    loadAbout('match', currentMatch)

def sendMessage(messageText):
    # Get the message from QML and send it to Tinder.
    try:
        messageText = str(messageText)
        matches[currentMatch].message(messageText)
        loadNewMatches()
        
    except pynder.errors.RequestError:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Failed to send message to match (Pynder Request Error): " + str(pynder.errors.RequestError.args) + "\n")
        logFile.close()
    except pynder.errors.PynderError:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Failed to send message to match (Pynder Error): " + str(pynder.errors.PynderError.args) + "\n")
        logFile.close()
    except pynder.errors.InitializationError:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Failed to send message to match (Initialization Error): " + str(pynder.errors.InitializationError.args) + "\n")
        logFile.close()
    except:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Failed to send message to match (Unknown Error)\n")
        logFile.close()

def loadMessages(matchNumber):
    # Get our current match number and save it for sendMessage()
    global currentMatch
    currentMatch = matchNumber

    # Try to get al the messages and send them to QML in reverse order (our listview is 180° rotated to show the last message first).
    try:
        # Reload all the matches to check if we have new messages...
        for msg in range(len(matches[matchNumber].messages)-1, -1, -1):
            # Check from who the message came and put the message on the right side of the screen by using True or False.
            if(matches[matchNumber].messages[msg]._data['from'] == session.profile.id):
                pyotherside.send('getMessages', True, matches[matchNumber].messages[msg].body)
            else:
                pyotherside.send('getMessages', False, matches[matchNumber].messages[msg].body)
        # Send the name and the first photo of our match we're messaging.
        pyotherside.send('getMatchData', matches[matchNumber].user.name, matches[matchNumber].user.photos[0])

    # Something went wrong...
    except pynder.errors.RequestError:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Failed to get messages from match (Pynder Request Error): " + str(pynder.errors.RequestError.args) + "\n")
        logFile.close()
    except pynder.errors.PynderError:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Failed to get messages from match (Pynder Error): " + str(pynder.errors.PynderError.args) + "\n")
        logFile.close()
    except pynder.errors.InitializationError:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Failed to get messages from match (Initialization Error): " + str(pynder.errors.InitializationError.args) + "\n")
        logFile.close()
    except:
        logFile = open("harbour-sailfinder/session.log", 'a')
        logFile.write(str(time.asctime(time.localtime(time.time()))) + " [ERROR] Failed to get messages from match (Unknown Error)\n")
        logFile.close()
