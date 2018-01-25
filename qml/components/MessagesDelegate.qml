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

ListItem {
    contentHeight: column.height + Theme.paddingLarge
    width: parent.width*0.75
    anchors.right: model.authorIsUser? parent.right: undefined // Left is automatically assigned

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

        Label {
            width: parent.width
            anchors {
                left: parent.left
                leftMargin: Theme.paddingMedium
                right: parent.right
                rightMargin: Theme.paddingMedium
            }
            wrapMode: Text.WordWrap
            text: model.message
            color: model.authorIsUser? Theme.primaryColor: "black"
        }

        Label {
            anchors {
                right: parent.right
                rightMargin: Theme.paddingMedium
            }
            font.pixelSize: Theme.fontSizeTiny
            color: model.authorIsUser? Theme.primaryColor: "black"
            text: {
                var timestamp = new Date().toLocaleString(Qt.locale(), "dd/MM/yyyy HH:mm") //model.timestamp.toLocaleString(Qt.locale(), "dd/MM/yyyy HH:mm")
                var status = ""
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
