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

import QtQuick 2.6
import Sailfish.Silica 1.0
//import QtFeedback 5.0

// Thanks to:
// https://github.com/QtGram/harbour-sailorgram/blob/0.9/harbour-sailorgram/qml/components/message/input/MessageTextInput.qml
// For circumventing the missing Qt Quick Controls module in Sailfish OS which contains the contentHeight property for QML TextArea

Item {
    property string placeHolderText
    signal send(string text)

    id: messagingBar
    width: parent.width
    // Harbour incompatible: QML Qt Quick Controls isn't allowed
    height: timestamp.y + timestamp.height + Theme.paddingSmall

    // Harbour incompatible, needs a workaround for their to restrictive rules
    /*ThemeEffect {
        id: buttonBuzz
        effect: ThemeEffect.Press
    }*/

    Timer {
        interval: 500
        repeat: true
        running: Qt.application.active
        onTriggered: timestamp.text = new Date().toLocaleTimeString(Qt.locale(), "HH:mm:ss")
    }

    TextArea {
        id: input
        anchors {
            left: parent.left
            right: sendButton.left
            top: parent.top
        }
        color: Theme.primaryColor
        placeholderText: messagingBar.placeHolderText
        EnterKey.enabled: text.length > 0
    }

    IconButton {
        id: sendButton
        anchors {
            right: parent.right
            rightMargin: Theme.horizontalPageMargin
            top: parent.top
        }
        icon.source: "qrc:///images/icon-send.png" + (pressed
                                                      ? Theme.highlightColor
                                                      : Theme.primaryColor)
        icon.scale: Theme.iconSizeSmall/icon.width
        onPressed: {
            //buttonBuzz.play()
            send(input.text)
            input.text = ""
        }
    }

    Label {
        id: timestamp
        anchors {
            top: input.bottom
            topMargin: -input._labelItem.height - 3
            left: input.left
            leftMargin: input.textLeftMargin
            right: input.right
        }

        color: Theme.highlightColor
        font.pixelSize: Theme.fontSizeTiny
    }

    Rectangle {
        z: -1
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: Theme.rgba(Theme.highlightBackgroundColor, 0.3) }
            GradientStop { position: 1.0; color: Theme.rgba(Theme.highlightBackgroundColor, 0.15) }
        }
    }
}
