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
            spacing: Theme.paddingMedium

            //% "About %0 V%1"
            PageHeader { title: qsTrId("sailfinder-version").arg(sfos.appNamePretty).arg(sfos.appVersion) }

            //% "What's %0?"
            SectionHeader { text: qsTrId("sailfinder-what-is").arg(sfos.appNamePretty) }

            TextLabel {
                //% "%0 is an opensource application to have fun on Tinder with your Sailfish OS smartphone!"
                text: qsTrId("sailfinder-what-is-text").arg(sfos.appNamePretty)
            }

            //% "Privacy & licensing"
            SectionHeader { text: qsTrId("sailfinder-privacy-licensing") }

            TextLabel {
                //% "%0 will never collect any personal information about the user, but this can't be guaranteed from any third-party company used in %0. This application is released under GPLv3. The source code and the license is available in the Github repo of %0."
                text: qsTrId("sailfinder-privacy-licensing-text").arg(sfos.appNamePretty)
            }

            //% "Responsibility"
            SectionHeader { text: qsTrId("sailfinder-responsibility") }

            TextLabel {
                //% "%0 and it's developer can't be hold responsible for using %0. %0 and it's developer aren't affilated in any way with Tinder."
                text: qsTrId("sailfinder-responsibility-text").arg(sfos.appNamePretty)
            }

            //% "Developer & source code"
            SectionHeader { text: qsTrId("sailfinder-developer-source") }

            GlassButton {
                link: "https://github.com/dylanvanassche"
                source: "qrc:///images/icon-github.png"
                text: "Dylan Van Assche"
            }

            GlassButton {
                link: "https://paypal.me/minitreintje"
                source: "qrc:///images/icon-paypal.png"
                //% "Donate with %0"
                text: qsTrId("sailfinder-donate-with").arg("PayPal")
            }

            GlassButton {
                link: "https://github.com/dylanvanassche/harbour-sailfinder"
                source: "qrc:///images/icon-code.png"
                //% "Source code"
                text: qsTrId("sailfinder-source")
            }

            //% "Translations"
            SectionHeader { text: qsTrId("sailfinder-translations") }

            TextLabel {
                //% "%0 can be translated into your language but for that we need your help! You can translate this app on %1"
                text: qsTrId("sailfinder-translations-text").arg(sfos.appNamePretty).arg("Transifex:")
            }

            GlassButton {
                link: "https://www.transifex.com/dylanvanassche/harbour-sailfinder"
                source: "qrc:///images/icon-translate.png"
                //% "%0 project"
                text: qsTrId("sailfinder-translations-project").arg("Transifex")
            }

            //% "Powered by"
            SectionHeader { text: qsTrId("sailfinder-powered-by") }

            GlassButton {
                link: "https://fontawesome.io/"
                source: "qrc:///images/icon-fontawesome.png"
                //% "%0 icons"
                text: qsTrId("sailfinder-icons").arg("FontAwesome")
            }

            GlassButton {
                link: "https://be.linkedin.com/in/sam-goedgezelschap-06a516106"
                source: "qrc:///images/icon-linkedin.png"
                text: "Sam Goedgezelschap"
            }
        }
    }
}
