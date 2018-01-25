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

Page {
    property string name
    //property int age
    //property int gender

    PageHeader {
        id: messagingHeader
        anchors { top: parent.top; left: parent.left; right: parent.right }
        //% "%0 (%L1) %2"
        title: qsTrId("sailfinder-messages-header").arg("Johnny").arg(25).arg("♂")
    }

    /*SilicaListView {
        id: messagesListView
        width: parent.width
        anchors {
            top: messagingHeader.bottom // conflict with header property
            bottom: bar.top
        }
        delegate: MessagesDelegate {
            width: ListView.view.width
        }

        VerticalScrollDecorator {}

        ViewPlaceholder {
            enabled: messagesListView.count == 0
            //% "No messages yet :-("
            text: qsTrId("sailfinder-no-messages-text")
            //% "Be the first one to start the conversation!"
            hintText: qsTrId("sailfinder-no-messages-hint")
        }
    }*/

    MessagingBar {
        id: bar
        anchors { bottom: parent.bottom; left: parent.left; right: parent.right }
        //% "Say hi to %0!"
        placeHolderText: qsTrId("sailfinder-messaging-placeholder").arg(name)
    }
}
