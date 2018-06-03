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
    Component.onCompleted: {
        api.getProfile()
        api.getUpdates(temp.lastActivityDate)
    }

    RemorsePopup { id: remorse }

    Timer {
        id: updatesTimer
        interval: 30000
        onTriggered: api.getUpdates(temp.lastActivityDate)
    }
    
    Connections {
        target: swipeView
        onCurrentIndexChanged: {
            if(swipeView.currentIndex != 2 && _hadFocus) {
                console.debug("Flicking to different view, updating profile preferences...")
                _hadFocus = false;
                api.updateProfile(bio.text, ageMin.value, ageMax.value, distanceMax.value, interestedIn.currentIndex, discoverable.checked, optimizer.checked)
            }
            else {
                _hadFocus = true;
            }
        }
    }

    Connections {
        target: Qt.application
        onActiveChanged: {
            if(Qt.application.active) {
                // Fetch immediately when becoming active again
                api.getUpdates(temp.lastActivityDate)
                updatesTimer.restart()
            }
        }
    }

    Connections {
        target: app
        onNetworkStatusChanged: {
            if(app.networkStatus == true) {
                console.debug("Restarting updates timer after network failure")
                // Fetch immediately when becoming online again
                api.getUpdates(temp.lastActivityDate)
                updatesTimer.restart() // After network failure, restart timer
            }
        }
    }
    
    Connections {
        target: api
        onProfileChanged: {
            discoverable.checked = api.profile.discoverable
            optimizer.checked = api.profile.optimizer
            interestedIn.currentIndex = api.profile.interestedIn
            distanceMax.value = api.profile.distanceMax
            ageMax.value = api.profile.ageMax
            ageMin.value = api.profile.ageMin // Order is important otherwise the value will not be updated due our limits implemented in the sliders
            photoList.photoListModel = api.profile.photos
            bio.text = api.profile.bio
            schoolsListView.model = api.profile.schools
            jobsListView.model = api.profile.jobs
            headerChanged(Util.createHeaderProfile(api.profile.name, api.profile.birthDate, api.profile.gender))
            updatesTimer.start()
        }

        onLoggedOut: {
            pageStack.replace(Qt.resolvedUrl("../pages/FirstPage.qml"), { logout: true })
        }

        onPersistentPollIntervalChanged: {
            if(api.persistentPollInterval > 0) {
                updatesTimer.interval = api.persistentPollInterval
            }
            else {
                console.warn("Invalid persitent poll interval received: " + api.persistentPollInterval)
            }
        }

        onUpdatesReady: {
            temp.lastActivityDate = Util.getUTCDate()
            console.debug("Last Activity Date: " + temp.lastActivityDate)
            updatesTimer.restart()
        }
    }

    Column {
        id: column
        width: parent.width
        spacing: Theme.paddingLarge

        PhotoGridLayout {
            id: photoList
            editable: true
            //% "Removing photo"
            onRemoved: remorse.execute(qsTrId("sailfinder-removing-photo"), function() {
                api.removePhoto(photoId)
            });
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

        SilicaListView {
            id: schoolsListView
            width: parent.width
            height: contentHeight
            delegate: SchoolJobDelegate {
                icon: "qrc:///images/icon-school.png"
                name: model.name
                editable: false // Updating schools and jobs not supported yet
            }
        }

        SilicaListView {
            id: jobsListView
            width: parent.width
            height: contentHeight
            delegate: SchoolJobDelegate {
                icon: "qrc:///images/icon-job.png"
                name: model.name
                title: model.title
                editable: false // Updating schools and jobs not supported yet
            }
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

        IconTextSwitch {
            id: optimizer
            //% "Optimizer"
            text: qsTrId("sailfinder-optimizer")
            busy: api.busy
            enabled: !busy
            //% "The photo optimizer will automatically show your best photo's first on your profile."
            description: qsTrId("sailfinder-optimizer-text")
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
            maximumValue: 100
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
            //% "Logging out"
            onClicked: remorse.execute(qsTrId("sailfinder-logging-out"), function() {
                api.logout()
            });
        }

        Spacer {}
    }
}
