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

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            width: page.width
            spacing: Theme.paddingLarge

            PageHeader {
                title: qsTr("Saved people")
            }

            ViewPlaceholder {
                id: message
                enabled: true
                text: "Loading saved people"
                hintText: "This can take some time..."
            }

            Label {
                id: savedMatchesHeader
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeSmall
                anchors.right: parent.right
                anchors.rightMargin: Theme.horizontalPageMargin
                text: "Saved matches"
            }

            Rectangle {
                width: parent.width
                height: savedMatchesModel.count * 175
                color: "transparent"

                SilicaListView {
                    id: savedMatchesList;
                    anchors.fill: parent;
                    anchors.leftMargin: Theme.horizontalPageMargin;
                    height: parent.height;
                    model: savedMatchesModel;
                    visible: false;
                    delegate: BackgroundItem {
                        id: savedMatchesListBackground
                        width: savedMatchesList.width;
                        height: pictureSavedMatch.height;

                        Row {
                            spacing: Theme.paddingLarge;

                            Image {
                                id: pictureSavedMatch;
                                source: model.imageURL;
                                width: Screen.width/3;
                                height: Screen.width/3;
                                asynchronous: true;
                                onStatusChanged: {
                                    if (status == Image.Error) {
                                        source = "../images/noImage.png"
                                        console.log('ERROR: pictureloading failed')
                                    }
                                }
                            }

                            Label {
                                id: nameSavedMatch;
                                color: highlighted ? Theme.highlightColor : Theme.primaryColor;
                                text: model.text;
                                anchors.verticalCenter: parent.verticalCenter;
                                x: Theme.horizontalPageMargin;
                            }
                        }
                        onClicked: {
                            pageStack.push(Qt.resolvedUrl("AboutSavedPersonPage.qml"));
                            python.call('tinder.aboutSavedMatch',[index], function() {});
                        }
                    }
                    VerticalScrollDecorator {}

                }
            }

            Label {
                id: savedPeopleHeader
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeSmall
                anchors.right: parent.right
                anchors.rightMargin: Theme.horizontalPageMargin
                text: "Saved people"
            }

            Rectangle {
                width: parent.width
                height: savedPeopleModel.count * 175
                color: "transparent"

                SilicaListView {
                    id: savedPeopleList;
                    anchors.fill: parent;
                    anchors.leftMargin: Theme.horizontalPageMargin;
                    height: parent.height;
                    model: savedPeopleModel;
                    visible: false;
                    delegate: BackgroundItem {
                        id: savedPeopleListBackground
                        width: savedPeopleList.width;
                        height: pictureSavedPerson.height;

                        Row {
                            spacing: Theme.paddingLarge;

                            Image {
                                id: pictureSavedPerson;
                                source: model.imageURL;
                                width: Screen.width/3;
                                height: Screen.width/3;
                                asynchronous: true;
                                onStatusChanged: {
                                    if (status == Image.Error) {
                                        source = "../images/noImage.png"
                                        console.log('ERROR: pictureloading failed')
                                    }
                                }
                            }

                            Label {
                                id: nameSavedPerson;
                                color: highlighted ? Theme.highlightColor : Theme.primaryColor;
                                text: model.text;
                                anchors.verticalCenter: parent.verticalCenter;
                                x: Theme.horizontalPageMargin;
                            }
                        }
                        onClicked: {
                            pageStack.push(Qt.resolvedUrl("AboutSavedPersonPage.qml"));
                            python.call('tinder.aboutSavedPerson',[index], function() {});
                        }
                    }
                    VerticalScrollDecorator {}

                }
            }
        }

        // Create a list of all saved people. We will fill this list later with Python.
        ListModel {
            id: savedPeopleModel;
        }

        ListModel {
            id: savedMatchesModel;
        }
    }

    Python {
        id: python
        Component.onCompleted:
        {
            // Add the Python path to PyOtherSide and import our module 'tinder'.
            addImportPath(Qt.resolvedUrl('.'));
            importModule('tinder', function() {});

            // When Python is ready, load the saved people and matches.
            python.call('tinder.loadSavedPeople',[], function() {});

            // Get all our saved people from Python.
            setHandler('getSavedPeople', function(name, picture, numberOfSavedMatches, numberOfSavedPeople, type)
            {
                // No people saved yet? Show the message.
                if(numberOfSavedMatches == 0 && numberOfSavedPeople == 0)
                {
                    message.enabled = false;
                    message.text = "No people saved yet :("
                    message.hintText = "You can save a person in the about page."
                    savedMatchesHeader.visible = false;
                    savedPeopleHeader.visible = false;
                }
                else
                {
                    // Hide the headers if this category is empty.
                    if(numberOfSavedMatches == 0)
                    {
                        savedMatchesHeader.visible = false;
                    }

                    if(numberOfSavedPeople == 0)
                    {
                        savedPeopleHeader.visible = false;
                    }

                    // Split up the data depending on the oject 'type' in order to add the person to the right list.
                    if(type)
                    {
                        savedMatchesHeader.visible = true;
                        savedMatchesModel.append({text: name, imageURL: picture});
                        savedMatchesList.visible = true;
                    }
                    else
                    {
                        savedPeopleHeader.visible = true;
                        savedPeopleModel.append({text: name, imageURL: picture});
                        savedPeopleList.visible = true;
                    }
                    message.enabled = false;
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
            console.log('python error: ' + traceback);
            Clipboard.text = traceback
            pageStack.completeAnimation();
            pageStack.replace(Qt.resolvedUrl('ErrorPage.qml'));
            pageStack.completeAnimation();
        }

        //DEBUG
        onReceived:
        {
            console.log('got message from python: ' + data);
        }
    }
}
