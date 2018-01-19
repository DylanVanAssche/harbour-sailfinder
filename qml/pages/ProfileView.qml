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

SilicaFlickable {
    width: parent.width
    height: parent.height
    contentHeight: column.height
    Component.onCompleted: api.getProfile()

    Connections {
        target: api
        onProfileChanged: {
            discoverable.checked = api.profile.discoverable
            interestedIn.currentIndex = api.profile.interestedIn
            distanceMax.value = api.profile.distanceMax
            ageMin.value = api.profile.ageMin
            ageMax.value = api.profile.ageMax
            photoList.photoListModel = api.profile.photos
            bio.text = api.profile.bio
        }
    }

    Column {
        id: column
        width: parent.width
        spacing: Theme.paddingLarge

        PhotoGridLayout {
            id: photoList
        }

        TextArea {
            id: bio
            width: parent.width
        }

        //% "Discovery"
        SectionHeader { text: qsTrId("sailfinder-discovery") }

        IconTextSwitch {
            id: discoverable
            //% "Discoverable"
            text: qsTrId("sailfinder-discoverable")
            icon.source: "qrc:///images/icon-recs.png"
            icon.scale: Theme.iconSizeMedium/icon.width // Scale icons according to the screen sizes
            busy: api.busy
            enabled: !busy
            //% "Disable discovery to hide your profile for other people. This has no effect on your current matches."
            description: qsTrId("sailfinder-discoverable-text")
        }

        ComboBox {
            id: interestedIn
            width: parent.width
            //% "Interested in"
            label: qsTrId("sailfinder-interested-in")
            currentIndex: -1
            menu: ContextMenu {
                //% "Female"
                MenuItem { text: qsTrId("sailfinder-female") }
                //% "Male"
                MenuItem { text: qsTrId("sailfinder-male") }
                //% "Everyone"
                MenuItem { text: qsTrId("sailfinder-everyone") }
            }
        }

        Slider {
            id: ageMin
            width: parent.width
            minimumValue: 18
            maximumValue: 100
            value: 0
            stepSize: 1
            opacity: enabled? 1.0: app.fadeOutValue
            //% "Min age"
            label: qsTrId("sailfinder-min-age")
            valueText: sliderValue
            onValueChanged: {
                if(value > ageMax.value)
                {
                    value = ageMax.value
                }
            }
        }

        Slider {
            id: ageMax
            width: parent.width
            minimumValue: 18
            maximumValue: 100
            value: 0
            stepSize: 1
            opacity: enabled? 1.0: app.fadeOutValue
            //% "Max age"
            label: qsTrId("sailfinder-max-age")
            valueText: sliderValue
            onValueChanged: {
                if(value < ageMin.value)
                {
                    value = ageMin.value
                }
            }
        }

        Slider {
            id: distanceMax
            width: parent.width
            minimumValue: 1
            maximumValue: 160
            value: 0
            stepSize: 1
            opacity: enabled? 1.0: app.fadeOutValue
            //% "Search radius"
            label: qsTrId("sailfinder-search-radius")
            //% "%L0 km"
            valueText: qsTrId("sailfinder-radius-km").arg(value)
        }

        //% "Account"
        SectionHeader { text: qsTrId("sailfinder-account") }

        Button {
            anchors.horizontalCenter: parent.horizontalCenter
            //% "Logout"
            text: qsTrId("sailfinder-logout")
            opacity: enabled? 1.0: app.fadeOutValue
            onClicked: console.debug("Logging out...")
        }
    }
}
