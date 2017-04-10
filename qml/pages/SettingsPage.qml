import QtQuick 2.2
import Sailfish.Silica 1.0

Dialog {

    onAccepted: {
        settings.showBio = bio.checked
        settings.showSchool = school.checked
        settings.showJob = job.checked
        //settings.showFriends = friends.checked
        settings.showInstagram = instagram.checked
        //settings.showSpotify = spotify.checked
        settings.showNotifications = notifications.checked
        settings.refreshInterval = refresh.currentIndex
        settings.imageFormat = imageFormat.currentIndex
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: settingsColumn.height

        VerticalScrollDecorator {}

        Column {
            id: settingsColumn
            width: parent.width
            spacing: Theme.paddingLarge

            DialogHeader { title: qsTr("Settings") }

            SectionHeader { text: qsTr("Recommendations & matches") }
            IconTextSwitch {
                id: bio
                text: qsTr("Biography")
                icon.source: "../resources/images/icon-bio.png"
                icon.scale: Theme.iconSizeMedium/icon.width // Scale icons according to the screen sizes
                checked: settings.showBio
                description: qsTr("Show the biography.")
            }

            IconTextSwitch {
                id: school
                text: qsTr("School")
                icon.source: "../resources/images/icon-school.png"
                icon.scale: Theme.iconSizeMedium/icon.width
                checked: settings.showSchool
                description: qsTr("Show the school and it's link to it's Facebook page.")
            }

            IconTextSwitch {
                id: job
                text: qsTr("Job")
                icon.source: "../resources/images/icon-job.png"
                icon.scale: Theme.iconSizeMedium/icon.width
                checked: settings.showJob
                description: qsTr("Show the job and it's link to it's Facebook page.")
            }

            /*IconTextSwitch {  // Sailfinder V3.X
                id: friends
                text: qsTr("Mutual friends")
                icon.source: "../resources/images/icon-friends.png"
                icon.scale: Theme.iconSizeMedium/icon.width
                checked: settings.showFriends
                description: qsTr("Show mutual Facebook friends between you and the other person")
            }*/

            IconTextSwitch {
                id: instagram
                text: qsTr("Instagram")
                icon.source: "../resources/images/icon-instagram.png"
                icon.scale: Theme.iconSizeMedium/icon.width
                checked: settings.showInstagram
                description: qsTr("Show his/her Instagram account and photos.")
            }

            /*IconTextSwitch { // Sailfinder V3.X
                id: spotify
                text: qsTr("Spotify")
                icon.source: "../resources/images/icon-spotify.png"
                icon.scale: Theme.iconSizeMedium/icon.width
                checked: settings.showSpotify
                description: qsTr("Show his/her favourite song on Spotify.")
            }*/

            SectionHeader { text: "Sailfinder" }

            IconTextSwitch {
                id: notifications
                text: qsTr("Notifications")
                icon.source: "../resources/images/icon-notifications.png"
                icon.scale: Theme.iconSizeMedium/icon.width
                checked: settings.showNotifications
                description: "Sailfinder " + qsTr("will notify you when a new match, message, ... has been received.")
            }

            ComboBox {
                id: refresh
                width: parent.width
                label: qsTr("Refresh interval")
                menu: ContextMenu {
                    MenuItem { text: "Quick" }
                    MenuItem { text: "Normal" }
                    MenuItem { text: "Long" }
                }
                currentIndex: settings.refreshInterval
                description: qsTr("Time between every check for new notifications. This only works when Sailfinder runs on the homescreen.")
            }

            ComboBox {
                id: imageFormat
                width: parent.width
                label: qsTr("Image size")
                menu: ContextMenu {
                    MenuItem { text: "640x640" }
                    MenuItem { text: "320x320" }
                    MenuItem { text: "172x172" }
                    MenuItem { text: "84x84" }
                }
                currentIndex: settings.imageFormat
                description: qsTr("Lowering the image size will lower the data usage of") + " Sailfinder " + qsTr("and improve the loading speed when you're using a slow connection.")
            }
        }
    }
}
