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

Page {
    id: validatePhone

    Connections {
        target: api
        onAuthenticatedChanged: {
            if(api.authenticated) {
                console.debug("Tinder token successfully retrieved")
                pageStack.replace(Qt.resolvedUrl("../pages/MainPage.qml"))
            }
        }
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height + Theme.paddingLarge
        contentWidth: parent.width

        VerticalScrollDecorator {}

        Column {
            id: column
            width: parent.width - Theme.paddingLarge
            spacing: Theme.paddingLarge

            PageHeader {
                //% "Log in with phone number"
                title: qsTrId("sailfinder-login-phone")
            }

            Label {
                //% "Please enter verification code"
                text: qsTrId("sailfinder-enter-sms-code")
                wrapMode: Text.Wrap
                width: parent.width
                anchors.horizontalCenter: parent.horizontalCenter
            }

            TextField {
                id: code
                width: parent.width
                inputMethodHints: Qt.ImhDialableCharactersOnly
                //% "SMS code"
                label: qsTrId("sailfinder-sms-code")
                placeholderText: label
                placeholderColor: Theme.highlightColor
                color: Theme.highlightColor
                anchors.horizontalCenter: parent.horizontalCenter
                EnterKey.iconSource: "image://theme/icon-m-enter-close"
                EnterKey.onClicked: focus = false
            }

            Button {
                //% "Log in"
                text: qsTrId("sailfinder-log-in")
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: api.authVerifySMS(code.text)
            }
        }
    }
}
