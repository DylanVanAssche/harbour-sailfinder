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
import QtQuick.Window 2.0;
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.3

Page {
    id: page
    Component.onDestruction:
    {
        python.call('tinder.cover',[], function() {});
    }

    Item {
        id: banner
        height: Theme.itemSizeExtraLarge
        anchors
        {
            top: parent.top
            left: parent.left
            right: parent.right
        }

        Rectangle {
            anchors.fill: parent
            z: -1
            color: "black"
            opacity: 0.15
        }

        Image {
            id: avatar
            width: Theme.iconSizeLarge
            height: width
            anchors
            {
                right: parent.right
                margins: Theme.paddingLarge
                verticalCenter: parent.verticalCenter
            }
            asynchronous: true
            smooth: true
            source: "../images/noImage.png"
            fillMode: Image.PreserveAspectCrop
            antialiasing: true

            Rectangle {
                anchors.fill: parent
                z: -1
                color: "black"
                opacity: 0.35
            }

            MouseArea {
                anchors.fill: parent
                onClicked:
                {
                    pageStack.push(Qt.resolvedUrl('AboutPersonPage.qml'));
                    python.call('tinder.loadAboutMessages',[], function() {});
                }
            }
        }

        Column {
            anchors {
                right: avatar.left
                margins: Theme.paddingLarge
                verticalCenter: parent.verticalCenter
            }

            Label {
                id: nameLabel
                anchors.right: parent.right
                color: Theme.highlightColor
                font {
                    family: Theme.fontFamilyHeading
                    pixelSize: Theme.fontSizeLarge
                }
                text: "Name"
            }

            // Introducing in next version
            /*Label {
                anchors.right: parent.right
                color: Theme.secondaryColor
                font {
                    family: Theme.fontFamilyHeading
                    pixelSize: Theme.fontSizeTiny
                }
                text: qsTr ("last seen ??? hours ago")
            }*/
        }
    }

    SilicaListView {
        id: view
        anchors
        {
            top: banner.bottom
            left: parent.left
            right: parent.right
            bottom: messageBar.top
        }
        rotation: 180
        clip: true
        model: messagesModel
        header: Item {
            height: view.spacing
            anchors
            {
                left: parent.left
                right: parent.right
            }
        }
        footer: Item {
            height: view.spacing
            anchors
            {
                left: parent.left
                right: parent.right
            }
        }
        spacing: Theme.paddingMedium
        Component.onCompleted: positionViewAtIndex(5, ListView.End)
        delegate: Item {
            id: item
            rotation: 180
            height: shadow.height
            anchors
            {
                left: parent.left
                right: parent.right
                margins: view.spacing
            }

            readonly property bool alignRight      : (!model.receivedFrom);
            readonly property int  maxContentWidth : (page.width * 0.85);

            Rectangle {
                id: shadow
                anchors
                {
                    fill: layout
                    margins: -Theme.paddingSmall
                }
                color: "white"
                radius: 3
                opacity: (item.alignRight ? 0.05 : 0.15)
                antialiasing: true
            }

            Column {
                id: layout
                anchors
                {
                    left: (item.alignRight ? parent.left : undefined)
                    right: (!item.alignRight ? parent.right : undefined)
                    margins: -shadow.anchors.margins
                    verticalCenter: parent.verticalCenter
                }

                Text {
                    width: Math.min(page.width*0.8, contentWidth)
                    anchors
                    {
                        left: (item.alignRight ? parent.left : undefined)
                        right: (!item.alignRight ? parent.right : undefined)
                    }
                    color: Theme.primaryColor
                    wrapMode: Text.WrapAtWordBoundaryOrAnywhere
                    font
                    {
                        family: Theme.fontFamilyHeading
                        pixelSize: Theme.fontSizeMedium
                    }
                    text: model.content
                }
            }
        }
    }

    ListModel {
        id: messagesModel
    }

    Row {
        id: messageBar
        anchors
        {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }

        IconButton {
            id: sendMessage
            icon.source: "image://theme/icon-m-message"
            onClicked: {
                messagesModel.insert(0, {receivedFrom: true, content: messagesBox.text});
                python.call('tinder.sendMessage',[messagesBox.text], function(message) {});
                messagesBox.placeholderText = "Message send!";
                messagesBox.text = "";
                messagesBox.focus = true;
                resetPlaceHolderText.start();
            }
        }

        TextArea {
            id: messagesBox
            width: parent.width - sendMessage.width
            placeholderText: qsTr ("Enter message...")
        }
    }

    Python {
        id: python
        Component.onCompleted:
        {
            // Add the Python path to PyOtherSide and import our module 'tinder'.
            addImportPath(Qt.resolvedUrl('.'));
            importModule('tinder', function() {});

            // Get the messages from our match and put them in the messagesModel ListModel.
            setHandler('getMessages', function(received, message) {
                messagesModel.append({receivedFrom: received, content: message});
            });

            setHandler('getMatchData', function(name, picture) {
                nameLabel.text = name;
                avatar.source = picture;
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
