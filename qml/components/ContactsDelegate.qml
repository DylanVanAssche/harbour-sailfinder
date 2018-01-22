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

import QtQuick 2.0
import Sailfish.Silica 1.0

ListItem {
    contentHeight: Theme.itemSizeExtraLarge
    highlighted: model.mentioned

    Avatar {
        id: avatar
        anchors { left: parent.left; leftMargin: Theme.horizontalPageMargin; verticalCenter: parent.verticalCenter }
        source: model.avatar
    }

    Label {
        id: name
        anchors {
            left: avatar.right
            leftMargin: Theme.paddingLarge
            top: avatar.top
        }
        font.pixelSize: Theme.fontSizeLarge
        text: model.name
    }

    Label {
        anchors {
            left: avatar.right
            leftMargin: Theme.paddingLarge
            top: name.bottom
            topMargin: Theme.paddingSmall
            right: unreadCounterBackground.left
            rightMargin: Theme.paddingLarge
        }
        font.pixelSize: Theme.fontSizeExtraSmall
        font.italic: true
        truncationMode: TruncationMode.Fade
        text: model.messagesPreview
    }

    Rectangle {
        id: unreadCounterBackground
        width: Math.max(Theme.itemSizeSmall/2, unreadCounter.width)
        height: Theme.itemSizeSmall/2
        anchors { right: parent.right; rightMargin: Theme.horizontalPageMargin; top: avatar.top }
        color: Theme.highlightColor
        radius: width/2
        visible: model.unreadCounter > 0

        Label {
            id: unreadCounter
            anchors.centerIn: parent
            font.bold: true
            text: model.unreadCounter
        }
    }

    Label {
        id: messageStatus
        anchors { right: parent.right; rightMargin: Theme.horizontalPageMargin; bottom: avatar.bottom }
        font.pixelSize: Theme.fontSizeTiny
        font.bold: true
        text: {
            if(model.readMessage && model.receivedMessage) {
                return "✓✓"
            }
            else if(model.receivedMessage) {
                return "✓"
            }
            else {
                return ""
            }
        }
    }
}
