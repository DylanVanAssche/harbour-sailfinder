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
import "../components"
import "../js/util.js" as Util

Page {
    id: page

    property string name
    property date birthDate
    property int gender
    property string avatar

    MessagingHeader {
        id: messagingHeader
        name: page.name
        birthDate: page.birthDate
        gender: page.gender
        avatar: page.avatar
    }

    SilicaListView {
        id: messagesListView
        width: parent.width
        model: ListModel {
            ListElement {
                ID: "123456789" // id gives collision
                message: "Sailfish OS is awesome!"
                author: "Jonny Jansens"
                authorIsUser: true
                readMessage: true
                receivedMessage: true
            }

            ListElement {
                ID: "123456789" // id gives collision
                message: "It has awesome ambiences!"
                author: "Dylan Van Assche"
                authorIsUser: false
                readMessage: true
                receivedMessage: true
            }

            ListElement {
                ID: "123456789" // id gives collision
                message: "And nice gestures!"
                author: "Jonny Jansens"
                authorIsUser: true
                readMessage: true
                receivedMessage: true
            }

            ListElement {
                ID: "123456789" // id gives collision
                message: "It's just missing some good messaging apps :-("
                author: "Jonny Jansens"
                authorIsUser: true
                readMessage: true
                receivedMessage: true
            }

            ListElement {
                ID: "123456789" // id gives collision
                message: "But Transponder will change that!"
                author: "Dylan Van Assche"
                authorIsUser: false
                readMessage: true
                receivedMessage: true
            }

            ListElement {
                ID: "123456789" // id gives collision
                message: "Transponder is a plugin based messenger for SFOS"
                author: "Dylan Van Assche"
                authorIsUser: false
                readMessage: true
                receivedMessage: true
            }

            ListElement {
                ID: "123456789" // id gives collision
                message: "Matrix.org, Telegram, IRC, ... as long as their is a Python library for it then Transponder can use it!"
                author: "Dylan Van Assche"
                authorIsUser: false
                readMessage: true
                receivedMessage: true
            }

            ListElement {
                ID: "123456789" // id gives collision
                message: "Oh that's great news!"
                author: "Jonny Jansens"
                readMessage: false
                receivedMessage: true
                authorIsUser: true
            }
        }
        anchors {
            top: messagingHeader.bottom // Conflicts with header property
            topMargin: Theme.paddingMedium
            bottom: bar.top
            bottomMargin: Theme.paddingMedium
            left: parent.left
            leftMargin: Theme.horizontalPageMargin/2
            right: parent.right
            rightMargin: Theme.horizontalPageMargin/2
        }
        clip: true
        spacing: Theme.paddingMedium
        delegate: MessagingDelegate {
            width: ListView.view.width*0.75
        }
        onModelChanged: messagesListView.scrollToBottom()
        Component.onCompleted: messagesListView.scrollToBottom()

        VerticalScrollDecorator {}
    }

    MessagingBar {
        id: bar
        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
        //% "Say hi to %0!"
        placeHolderText: qsTrId("sailfinder-messaging-placeholder").arg(name)
    }

    ViewPlaceholder {
        anchors.centerIn: parent
        enabled: messagesListView.count == 0
        //% "No messages yet :-("
        text: qsTrId("sailfinder-no-messages-text")
        //% "Be the first one to start the conversation!"
        hintText: qsTrId("sailfinder-no-messages-hint")
    }
}
