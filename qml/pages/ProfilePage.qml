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

import QtQuick 2.2
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.3

Page {
    id: page
    Component.onDestruction:
    {
        python.call('tinder.loadPerson',[0, 0, true], function(pictureNumber, personsNumber, firstPass) {});
    }

    property var swipeLeftEnabled: true
    property var swipeRightEnabled: true
    property var hintsEnabled: false
    property var counter: 0

    Timer {
        id: hints
        interval: 1000*5.25
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered:
        {
            if(hintsEnabled)
            {
                switch(counter)
                {
                case 0:
                    labelHint.text = "Swipe through pictures";
                    labelHint.visible = true;
                    counter++;
                    break;
                case 1:
                    labelHint.text = "Sailfinder hints";
                    labelHint.visible = false;
                    counter++;
                    break;
                default:
                    counter = 0;
                    break;
                }
            }
            else
            {
                // Hints are disabled so hide everthing and stop the timer.
                hints.stop();
                labelHint.visible = false;
            }
        }
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            width: page.width
            spacing: Theme.paddingLarge

            PageHeader {
                title: qsTr("Profile")
            }

            PullDownMenu {
                id: pullDownMenu

                MenuItem {
                    id: updateProfilePulleyMenu
                    text: "Update profile"
                    onClicked:
                    {
                        // Open the UpdateProfile page.
                        pageStack.push(Qt.resolvedUrl('UpdateProfilePage.qml'));
                    }
                }
            }

            Rectangle {
                width: Screen.width
                height: Screen.width
                color: "transparent"
                anchors
                {
                    left: parent.left
                    right: parent.right
                    leftMargin: Theme.horizontalPageMargin
                    rightMargin: Theme.horizontalPageMargin
                }

                BusyIndicator {
                    id: loadingPicture
                    running: true
                    size: BusyIndicatorSize.Large
                    anchors.centerIn: parent
                    visible: true
                }

                MouseArea {
                    id: gesturesPicture
                    width: Screen.width
                    height: Screen.width
                    anchors.horizontalCenter: parent.horizontalCenter
                    enabled: true
                    preventStealing: true
                    property point origin

                    Image {
                        id: pictureUser
                        width: parent.width
                        height: parent.height
                        source: "image://theme/icon-l-image"
                        fillMode: Image.PreserveAspectFit
                        visible: false
                        onStatusChanged: {
                            if (status == Image.Error) {
                                source = "image://theme/icon-l-image"
                                console.log('ERROR: pictureloading failed')
                            }
                        }
                    }

                    onPressed: {
                        origin = Qt.point(mouse.x, mouse.y)
                    }

                    onReleased: {
                        if(swipeLeftEnabled) {
                            if (mouse.x - origin.x > 4) {
                                python.call('tinder.loadProfile',[2, false], function(pictureNumber, firstPass) {});
                                loadingPicture.visible = true;
                                pictureUser.visible = false;
                            }
                        }

                        if(swipeRightEnabled) {
                            if (mouse.x - origin.x < -4) {
                                python.call('tinder.loadProfile',[1, false], function(pictureNumber, firstPass) {});
                                loadingPicture.visible = true;
                                pictureUser.visible = false;
                            }
                        }
                    }
                }

                TouchInteractionHint {
                    // 1,75 sec/swipe
                    id: swipeHint
                    direction: TouchInteraction.Left
                    visible: true
                    anchors.centerIn: parent
                    loops: 3
                }
            }

            Row {
                anchors
                {
                    left: parent.left
                    leftMargin: Theme.horizontalPageMargin
                }
                spacing: Theme.paddingMedium

                Label {
                    id: nameUser
                    color: Theme.highlightColor
                    text: ""
                }

                Image {
                    id: genderIcon
                    width: nameUser.height
                    height: nameUser.height
                    source: "../images/male.png"
                    visible: false
                }
            }

            Label {
                id: bioUser
                text: ""
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.WordWrap
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: Theme.horizontalPageMargin
                    rightMargin: Theme.horizontalPageMargin
                }
            }
        }
    }

    InteractionHintLabel {
        id: labelHint
        anchors.bottom: parent.bottom
        visible: true
        text: "Sailfinder hints"
    }

    Python {
        id: python
        Component.onCompleted:
        {
            // Add the Python path to PyOtherSide and import our module 'tinder'.
            addImportPath(Qt.resolvedUrl('.'));
            importModule('tinder', function() {});

            // When Python is ready, load our Tinder profile...
            python.call('tinder.loadProfile',[0, true], function(pictureNumber, firstPass) {});
            python.call('tinder.hintsHandler',[1], function() {});

            // Get the profile data.
            setHandler('getProfileData', function(name, bio, gender)
            {
                nameUser.text = name;
                bioUser.text = bio;
            });

            // Get the profile picture.
            setHandler('getProfilePicture', function(picture)
            {
                pictureUser.source = picture;
                pictureUser.visible = true;
                loadingPicture.visible = false;
            });

            // Activate and deactivate the right swipe directions... This is a workaround for the SlideshowView component who isn't very nice for internet images.
            setHandler('getProfilePictureNavigation', function(state)
            {
                switch(state)
                {
                case 1:
                    swipeLeftEnabled = true;
                    swipeRightEnabled = false;
                    break;

                case 2:
                    swipeLeftEnabled = false;
                    swipeRightEnabled = true;
                    break;

                case 3:
                    swipeLeftEnabled = false;
                    swipeRightEnabled = false;
                    break;

                case 4:
                    swipeLeftEnabled = true;
                    swipeRightEnabled = true;
                    break;
                }
            });

            // Get the hintstate from Python.
            setHandler('getHintsStateProfile', function(hintsState)
            {
                if(hintsState)
                {
                    hintsEnabled = true;
                    hints.start();
                }
                else
                {
                    hintsEnabled = false;
                    swipeHint.visible = false;
                    labelHint.visible = false;
                }
            });

        }

        onError:
        {
            console.log('Python ERROR: ' + traceback);
            Clipboard.text = traceback
            pageStack.completeAnimation();
            pageStack.replace(Qt.resolvedUrl('ErrorPage.qml'));
            pageStack.completeAnimation();
        }

        //DEBUG
        /*onReceived:
        {
            console.log('Python MESSAGE: ' + data);
        }*/
    }
}
