/*
*   This file is part of Sailfinder.
*
*   Sailfinder is free software: you can redistribute it and/or modify
*   it under the terms of the GNU General Public License as published by
*   the Free Software Foundation, either version 3 of the License, or
*   (at your option) any later version.
*
*   Sailfinder is distributed in the hope that it will be useful,
*   but WITHOUT ANY WARRANTY; without even the implied warranty of
*   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*   GNU General Public License for more details.
*
*   You should have received a copy of the GNU General Public License
*   along with Sailfinder.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.2
import Sailfish.Silica 1.0
import "../js/util.js" as Util

ListItem {
    contentHeight: column.height + Theme.paddingLarge
    width: parent.width*0.75
    anchors.right: model.authorIsUser? parent.right: undefined // Left is automatically assigned

    Component.onCompleted: {
        if(Util.validateGiphyURL(model.message)) {
            console.debug("GIF detected")
            messageItemLoader.setSource("GIFMessage.qml", {"source": model.message})
        }
        else {
            messageItemLoader.setSource("TextMessage.qml", {"text": model.message, "color": model.authorIsUser? Theme.primaryColor: "black"})
        }
    }

    Column {
        id: column
        width: parent.width
        spacing: Theme.paddingSmall
        anchors.verticalCenter: parent.verticalCenter

        Label {
            id: author
            anchors {
                left: parent.left
                leftMargin: Theme.paddingMedium
            }
            text: model.author
            font.bold: true
            color: model.authorIsUser? Theme.primaryColor: "black"
        }

        Loader {
            id: messageItemLoader
            width: parent.width
            height: Util.validateGiphyURL(model.message)? Theme.itemSizeHuge: undefined // TextMessage automatically sets the height, GIFMessage does not.
        }

        Label {
            anchors {
                right: parent.right
                rightMargin: Theme.paddingMedium
            }
            font.pixelSize: Theme.fontSizeTiny
            color: model.authorIsUser? Theme.primaryColor: "black"
            visible: text.length > 0
            text: {
                var timestamp = Util.formatDate(model.timestamp)
                var status = "";

                // Status is only needed for our messages, not the other person
                if(model.readMessage && model.receivedMessage && model.authorIsUser) {
                    status = " ✓✓"
                }
                else if(model.receivedMessage && model.authorIsUser) {
                    status = " ✓"
                }
                return timestamp + status
            }
        }
    }

    Rectangle {
        z: -1
        anchors.fill: parent
        color: model.authorIsUser? Theme.secondaryHighlightColor: Theme.primaryColor
        radius: Theme.paddingSmall
    }
}
