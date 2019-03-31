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
import "../components"

Page {
    id: welcome

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height
        contentWidth: parent.width

        Column {
            width: parent.width
            spacing: Theme.paddingLarge

            Item {
                width: parent.width
                height: Theme.paddingLarge
            }

            Image {
                width: sourceSize.width
                height: sourceSize.height
                anchors.horizontalCenter: parent.horizontalCenter
                source: "qrc:///images/harbour-sailfinder.png"
            }

            TextLabel {
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: Theme.fontSizeLarge
                text: sfos.appNamePretty
            }

            Item {
                width: parent.width
                height: Theme.paddingLarge
            }

            Button {
                //% "Log in with Facebook"
                text: qsTrId("sailfinder-login-facebook")
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: pageStack.push(Qt.resolvedUrl("../pages/LoginFacebook.qml"))
            }

            Button {
                //% "Log in with phone number"
                text: qsTrId("sailfinder-login-phone")
                anchors.horizontalCenter: parent.horizontalCenter
                onClicked: pageStack.push(Qt.resolvedUrl("../pages/LoginPhone.qml"))
            }
        }
    }
}
