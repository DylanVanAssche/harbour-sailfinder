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

    property var hintsEnabled: false
    property var counter: 0

    // Show the hints.
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
                    // Taphint.
                    labelHint.visible = true
                    labelHint.text = "Hold for more info or press to send a message";
                    counter++;
                    break;

                case 1:
                    // Stop the hints.
                    labelHint.text = "Sailfinder hints";
                    labelHint.visible = false;
                    counter++;
                    break;

                default:
                    counter = 0;
                    hintsEnabled = false;
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
                title: qsTr("Matches")
            }

            // Show the user a message.
            ViewPlaceholder {
                id: message
                enabled: true
                text: "Loading matches"
                hintText: "This can take some time..."
            }

            Rectangle {
                width: parent.width;
                height: matchesList.contentHeight;
                anchors.left: parent.left
                color: "transparent"

                // Get all the matches and put them in a list.
                SilicaListView {
                    id: matchesList
                    height: matchesModel.count * 175
                    anchors.fill: parent
                    anchors.leftMargin: Theme.horizontalPageMargin
                    model: matchesModel
                    visible: false
                    delegate: BackgroundItem {
                        id: matchesListBackground
                        width: matchesList.width
                        height: pictureMatch.height

                        Row {
                            spacing: Theme.paddingLarge

                            Image {
                                id: pictureMatch
                                width: Screen.width/3
                                height: Screen.width/3
                                source: model.imageURL
                                onStatusChanged:
                                {
                                    if (status == Image.Error) {
                                        source = "../images/noImage.png"
                                        console.log('ERROR: pictureloading failed')
                                    }
                                }
                            }

                            Label {
                                id: nameMatch
                                color: highlighted ? Theme.highlightColor : Theme.primaryColor
                                text: model.text
                                anchors.verticalCenter: parent.verticalCenter
                                x: Theme.horizontalPageMargin
                            }
                        }
                        onClicked:
                        {
                            pageStack.push(Qt.resolvedUrl(page));
                            python.call('tinder.loadMessages',[index], function(matchNumber) {});
                        }
                        onPressAndHold:
                        {
                            pageStack.push(Qt.resolvedUrl('AboutPersonPage.qml'));
                            python.call('tinder.loadAbout',['match', index], function(aboutType, matchNumber) {});
                        }
                    }
                    VerticalScrollDecorator {}
                }
            }

            // Create a list of all matches. We will fill this list later with Python.
            ListModel {
                id: matchesModel
            }
        }
    }

    InteractionHintLabel {
        id: labelHint
        anchors.bottom: parent.bottom
        visible: false
        text: "Sailfinder hints"
    }

    Python {
        id: python
        Component.onCompleted:
        {
            // Add the Python path to PyOtherSide and import our module 'tinder'.
            addImportPath(Qt.resolvedUrl('.'));
            importModule('tinder', function() {});

            // When Python is ready, load the matches...
            python.call('tinder.loadNewMatches',[], function() {});
            python.call('tinder.loadMatches',[], function() {});
            python.call('tinder.hintsHandler',[2], function() {});

            // Get the matches and put them in a list.
            setHandler('getMatch', function(matchName, matchPicture, matchNumber)
            {
                matchesModel.append({text: matchName, page: "MessagesPage.qml", imageURL: matchPicture, matchNumber: matchNumber, visible: true});
                matchesList.visible = true;
                message.enabled = false;
                if(matchesModel.count == 0)
                {
                    message.enabled = true;
                    message.text = "No matches :(";
                    message.hintText = "Go back and swipe some people!";
                }
            });

            // Get the hintstate from Python.
            setHandler('getHintsStateMatches', function(hintsState)
            {
                if(hintsState) {
                    hintsEnabled = true;
                    hints.start()
                }
                else
                {
                    hints.stop();
                    labelHint.visible = false;
                }
            });

            // Show non-critical errors in the QT console.
            setHandler('error', function(traceback)
            {
                console.log('Python ERROR: ' + traceback)
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
