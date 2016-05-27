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
                title: qsTr("It's a match!")
            }

            Label {
                id: noteMatched
                anchors.horizontalCenter: parent.horizontalCenter
                color: Theme.highlightColor
                font.pixelSize: Theme.fontSizeLarge
                text: "You and USER matched!"
            }

            Label {
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    leftMargin: Theme.horizontalPageMargin
                    rightMargin: Theme.horizontalPageMargin
                }
                text: "Send him/her a message or keep swiping."
                font.pixelSize: Theme.fontSizeSmall
            }

            Image {
                id: picturePerson
                width: page.width/2;
                height: page.width/2;
                anchors.horizontalCenter: parent.horizontalCenter
                asynchronous: true
                source: "images/noPicture.png";
                fillMode: Image.PreserveAspectFit
            }

            Row {
                id: buttonRow
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: Theme.paddingLarge

                Button {
                    id: sendMessage
                    text: "Send message"
                    onClicked:
                    {
                        pageStack.replace(Qt.resolvedUrl('MainPage.qml'))
                        pageStack.completeAnimation()
                        pageStack.push(Qt.resolvedUrl('MessagesPage.qml'))
                        pageStack.completeAnimation()
                        python.call('tinder.handlerNewMatch',[3], function() {});
                    }
                }

                Button {
                    id: keepSwiping
                    text: "Swipe further"
                    onClicked:
                    {
                        pageStack.replace(Qt.resolvedUrl('MainPage.qml'))
                        pageStack.completeAnimation()
                        python.call('tinder.handlerNewMatch',[2], function() {});
                    }
                }
            }
        }
    }

    Python {
        id: python
        Component.onCompleted:
        {
            // Add the Python path to PyOtherSide and import our module 'tinder'.
            addImportPath(Qt.resolvedUrl('.'));
            importModule('tinder', function() {});

            // When Python is ready, load the new match...
            python.call('tinder.handlerNewMatch',[1], function(state) {});

            // Get the name and the picture of our new match.
            setHandler('getPersonData', function(name, picture)
            {
                noteMatched.text = 'You and ' + name + ' matched!';
                picturePerson.source = picture;
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
