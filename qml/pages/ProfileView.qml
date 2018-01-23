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
import "../js/util.js" as Util

SilicaFlickable {
    property bool _hadFocus
    signal headerChanged(string text)

    width: parent.width
    height: parent.height
    contentHeight: column.height
    Component.onCompleted: api.getProfile()
    
    Connections {
        target: swipeView
        onCurrentIndexChanged: {
            if(swipeView.currentIndex != 2 && _hadFocus) {
                console.debug("Flicking to different view, updating profile preferences...")
                _hadFocus = false;
                api.updateProfile(bio.text, ageMin.value, ageMax.value, distanceMax.value, interestedIn.currentIndex, discoverable.checked)
            }
            else {
                _hadFocus = true;
            }
        }
    }
    
    Connections {
        target: api
        onProfileChanged: {
            discoverable.checked = api.profile.discoverable
            interestedIn.currentIndex = api.profile.interestedIn
            distanceMax.value = api.profile.distanceMax
            ageMax.value = api.profile.ageMax
            ageMin.value = api.profile.ageMin // Order is important otherwise the value will not be updated due our limits implemented in the sliders
            photoList.photoListModel = api.profile.photos
            bio.text = api.profile.bio
            headerChanged(Util.createHeaderProfile(api.profile.name, api.profile.birthDate, api.profile.gender))
        }
        onLoggedOut: {
            pageStack.replace(Qt.resolvedUrl("../pages/FirstPage.qml"), { logout: true })
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
            onTextChanged: {
                console.debug("Length: " + text.length)
                if(text.length > 500) text.remove(500, text.length); // Character limit is 500 characters
            }
            //% "%L0/%L1"
            label: text.length > 0? qsTrId("sailfinder-remaining-characters").arg(text.length).arg(500): ""
            //% "Type your biography here"
            placeholderText: qsTrId("sailfinder-bio-hint")
        }

        //% "Discovery"
        SectionHeader { text: qsTrId("sailfinder-discovery") }

        IconTextSwitch {
            id: discoverable
            //% "Discoverable"
            text: qsTrId("sailfinder-discoverable")
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
                //% "Male"
                MenuItem { text: qsTrId("sailfinder-male") }
                //% "Female"
                MenuItem { text: qsTrId("sailfinder-female") }
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
            onClicked: {
                console.debug("Logging out")
                api.logout()
            }
        }

        Spacer {}
    }
}
