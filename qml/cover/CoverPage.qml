/*
  Copyright (C) 2013 Jolla Ltd.
  Contact: Thomas Perl <thomas.perl@jollamobile.com>
  All rights reserved.

  You may use this file under the terms of BSD license as follows:

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are met:
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of the Jolla Ltd nor the
      names of its contributors may be used to endorse or promote products
      derived from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
  WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR
  ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
  (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
  ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.3

CoverBackground {

    property var numberOfMatches: 0

    Column {
        id: column
        anchors.top: parent.top
        anchors.margins: 2*Theme.horizontalPageMargin
        width: parent.width
        spacing: Theme.paddingLarge

        Image {
            id: pictureCover
            width: parent.width - 2*Theme.horizontalPageMargin
            height: parent.width - 2*Theme.horizontalPageMargin
            source: "../images/harbour-sailfinder.png"
            anchors.horizontalCenter: parent.horizontalCenter
            visible: true
            onStatusChanged: {
                if (status == Image.Error) {
                    source = "../images/noImage.png"
                    console.log('ERROR: pictureloading failed')
                }
            }
        }

        Label {
            id: textCover
            anchors.horizontalCenter: parent.horizontalCenter
            truncationMode: TruncationMode.Fade
            text: "Sailfinder"
        }
    }

    CoverActionList {
        id: coverActionMain
        enabled: false

        CoverAction {
            iconSource: "../images/dislike_small.png"
            onTriggered: {
                python.call('tinder.likeDislikeSuperlikePerson',[1], function(action) {});
            }
        }

        CoverAction {
            iconSource: "../images/like_small.png"
            onTriggered: {
                python.call('tinder.likeDislikeSuperlikePerson',[2], function(action) {});
            }
        }
    }

    CoverActionList {
        id: coverActionEdit
        enabled: false

        CoverAction {
            iconSource: "../images/edit_small.png"
            onTriggered: {
                appWindow.activate();
            }
        }
    }

    Python {
        id: python
        Component.onCompleted:
        {
            // Add the Python path (which is different in cover then the rest of the app) to PyOtherSide and import our module 'tinder'.
            addImportPath(Qt.resolvedUrl('../pages'));
            importModule('tinder', function() {});

            // Main cover.
            setHandler('getDataMain', function(name, age, gender, distance)
            {
                textCover.text = name + ' (' + age + ')';
                coverActionMain.enabled = true;
                coverActionEdit.enabled = false;
                state = 1;
            });

            setHandler('getPersonPicture', function(url)
            {
                if(state == 1)
                {
                    pictureCover.source = url;
                }
            });

            // Profile cover.
            setHandler('getProfileData', function(name, bio, genderIndex)
            {
                textCover.text = name;
                coverActionMain.enabled = false;
                coverActionEdit.enabled = false;
                state = 2;
            });

            setHandler('getProfilePicture', function(url)
            {
                if(state == 2)
                {
                    pictureCover.source = url;
                }
            });

            // Matches cover.
            setHandler('getMatch', function(name, picture, numberInList)
            {
                textCover.text = numberInList + 1 + ' matches';
                numberOfMatches = numberInList + 1;
                pictureCover.source = "../images/matches.png";
                coverActionMain.enabled = false;
                coverActionEdit.enabled = false;
                state = 3;
            });

            setHandler('goBackCover', function()
            {
                textCover.text = numberOfMatches + ' matches';
                pictureCover.source = "../images/matches.png";
                coverActionMain.enabled = false;
                coverActionEdit.enabled = false;
                state = 3;
            });

            // Message a match cover.
            setHandler('getMessages', function(received, message) {
                state = 4;
                coverActionMain.enabled = false;
                coverActionEdit.enabled = true;
            });

            setHandler('getMatchData', function(name, picture) {
                if(state == 4)
                {
                    textCover.text = "Send message";
                    pictureCover.source = picture;
                }
            });

            // Settings cover.
            setHandler('getSettings', function(dataUpdateIntervalValue, hintsState, discoveryState, interestedIn, minAge, maxAge, searchDistanceValue, gpsUpdateIntervalValue)
            {
                textCover.text = 'Settings';
                pictureCover.source = "../images/settings.png";
                coverActionMain.enabled = false;
                coverActionEdit.enabled = true;
                state = 5;
            });
        }

        onError:
        {
            appWindow.activate();
            Clipboard.text = traceback
            pageStack.completeAnimation();
            pageStack.replace(Qt.resolvedUrl('../pages/ErrorPage.qml'));
            pageStack.completeAnimation();
            console.log('Python ERROR: ' + traceback);
        }

        //DEBUG
        /*
        onReceived:
        {
            console.log('Python MESSAGE: ' + data);
        }*/
    }
}

