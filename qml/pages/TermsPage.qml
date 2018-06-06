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
import Harbour.Sailfinder.SFOS 1.0
import "../components"

Page {
    SFOS {
        id: sfos
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        VerticalScrollDecorator {}

        Column {
            id: column
            width: parent.width
            spacing: Theme.paddingLarge

            //% "Terms of Service"
            PageHeader { title: qsTrId("sailfinder-terms-title") }

            //% "What's %0?"
            SectionHeader { text: qsTrId("sailfinder-what-is").arg(sfos.appNamePretty) }

            TextLabel {
                //% "%0 is an opensource application to have fun on Tinder with your Sailfish OS smartphone!"
                text: qsTrId("sailfinder-what-is-text").arg(sfos.appNamePretty)
            }

            //% "Privacy & licensing"
            SectionHeader { text: qsTrId("sailfinder-privacy-licensing") }

            TextLabel {
                //% "%0 keeps a minimalistic log in /home/nemo/.cache/%1/logging/log.txt for debugging purposes. %0 will never collect any personal information about the user, but this can't be guaranteed from any third-party company used in %0. This application is released under GPLv3. The source code and the license is available in the Github repo of %0. You can delete your %2 account in %0 if you like."
                text: qsTrId("sailfinder-privacy-licensing-text").arg(sfos.appNamePretty).arg(sfos.appName).arg("Tinder")
            }

            //% "Disclaimer"
            SectionHeader { text: qsTrId("sailfinder-disclaimer") }

            TextLabel {
                //% "%0 and it's contributors aren't related to %1 in any way and they can't be hold responsible for anything. You agree automatically with this disclaimer by using the application, contribute to it, ..."
                text: qsTrId("sailfinder-disclaimer-text").arg(sfos.appNamePretty).arg("Tinder")
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                //% "Accept"
                text: qsTrId("sailfinder-accept")
                preferredWidth: Theme.buttonWidthMedium
                onClicked: {
                    temp.readTerms = true
                    pageStack.replace(Qt.resolvedUrl("../pages/FirstPage.qml"))
                }
            }

            Spacer {}
        }
    }
}
