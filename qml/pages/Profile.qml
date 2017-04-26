import QtQuick 2.0
import Sailfish.Silica 1.0
import "js/profile.js" as Profile

SilicaFlickable {
    width: parent.width; height: parent.height
    contentHeight: profileColumn.height
    Component.onCompleted: Profile.get(true) // Getting profile

    Connections {
        target: swipeview
        onCurrentIndexChanged: {
            if(updateRequired) { // Update profile when user changed something
                Profile.set()
                if(discovery) { // When discovery options are changed, refresh our recs
                    app.refreshRecs()
                }
            }
        }
    }

    Connections {
        target: app
        onCachingProfileChanged: app.profileData? Profile.load(): console.error("[ERROR] Invalid profile data: " + app.profileData)
        onCleanup: Profile.clear()
    }

    VerticalScrollDecorator {}

    RemorsePopup { id: remorse }

    Column {
        id: profileColumn
        width: parent.width
        spacing: Theme.paddingLarge

        ImageGrid { id: avatars }

        Row {
            width: parent.width
            anchors { left: parent.left; right: parent.right; rightMargin: Theme.horizontalPageMargin }
            spacing: Theme.paddingMedium

            TextArea { //Bio max 500 characters
                id: bio
                width: parent.width - Theme.iconSizeSmall - Theme.paddingMedium - Theme.horizontalPageMargin
                label: qsTr("Biography")
                placeholderText: label
                onTextChanged: updateRequired = true
            }

            Image { // Show edit pencil next to bio to show user this field is editable
                anchors { verticalCenter: bio.verticalCenter }
                width: Theme.iconSizeSmall
                height: width
                source: "image://theme/icon-s-edit"
                asynchronous: true
            }
        }

        // Sailfinder V3.X: external accounts support (FB, Instagram, Spotify)
        // Type 0: Facebook images & albums
        /*GlassButtonEdit { buttonLink: "https://www.facebook.com/"; buttonIconSource: "../resources/images/icon-job.png"; buttonIconText: "My job"; editIconSource: "../resources/images/icon-edit.png"; editPageLink: "ExternalAccountsPage.qml"; editPageType: 1; editPageTitle: qsTr("Jobs") }
        GlassButtonEdit { buttonLink: "https://www.facebook.com/"; buttonIconSource: "../resources/images/icon-school.png"; buttonIconText: "My school"; editIconSource: "../resources/images/icon-edit.png"; editPageLink: "ExternalAccountsPage.qml"; editPageType: 2; editPageTitle: qsTr("Schools") }
        GlassButtonEdit { buttonLink: "https://www.instagram.com/"; buttonIconSource: "../resources/images/icon-instagram.png"; buttonIconText: "My instagram"; editIconSource: "../resources/images/icon-edit.png"; editPageLink: "ExternalAccountsPage.qml"; editPageType: 3; editPageTitle: qsTr("Instagram account") }
        GlassButtonEdit { buttonLink: "https://www.spotify.com/"; buttonIconSource: "../resources/images/icon-instagram.png"; buttonIconText: "My instagram"; editIconSource: "../resources/images/icon-edit.png"; editPageLink: "ExternalAccountsPage.qml"; editPageType: 4; editPageTitle: qsTr("Spotify song") }*/

        GlassButton { id: job; iconSource: "../resources/images/icon-job.png"; itemScale: 0.5 }
        GlassButton { id: school; iconSource: "../resources/images/icon-school.png"; itemScale: 0.5 }

        SectionHeader { text: qsTr("Discovery") }
        IconTextSwitch {
            id: discoverable
            text: qsTr("Discoverable")
            icon.source: "../resources/images/icon-recs.png"
            icon.scale: Theme.iconSizeMedium/icon.width // Scale icons according to the screen sizes
            checked: false
            busy: app.loadingRecs || app.cachingRecs
            enabled: !busy
            onCheckedChanged: updateRequired = true
            description: qsTr("Disable discovery to hide your profile for other people. This has no effect on your current matches.")
        }

        Row {
            width: parent.width

            ComboBox {
                id: gender
                width: parent.width / 2
                label: qsTr("My gender")
                enabled: discoverable.checked && discoverable.enabled
                currentIndex: -1
                onCurrentIndexChanged: updateRequired = true

                menu: ContextMenu {
                    MenuItem { text: qsTr("Male") }
                    MenuItem { text: qsTr("Female") }
                }
            }

            ComboBox {
                id: interestedIn
                width: parent.width / 2
                label: qsTr("Interested in")
                enabled: discoverable.checked && discoverable.enabled
                currentIndex: -1
                onCurrentIndexChanged: updateRequired = true

                menu: ContextMenu {
                    MenuItem { text: qsTr("Everyone") }
                    MenuItem { text: qsTr("Male") }
                    MenuItem { text: qsTr("Female") }
                }
            }
        }

        Slider {
            id: minAge
            width: parent.width
            minimumValue: 18
            maximumValue: 100
            value: 0
            stepSize: 1
            enabled: discoverable.checked && discoverable.enabled
            opacity: enabled? 1.0: 0.25
            label: qsTr("Minimum age")
            valueText: sliderValue
            onValueChanged: {
                updateRequired = true
                if(value > maxAge.value)
                {
                    value = maxAge.value
                }
            }
        }

        Slider {
            id: maxAge
            width: parent.width
            minimumValue: 18
            maximumValue: 100
            value: 0
            stepSize: 1
            enabled: discoverable.checked && discoverable.enabled
            opacity: enabled? 1.0: 0.25
            label: qsTr("Maximum age")
            valueText: sliderValue
            onValueChanged: {
                updateRequired = true
                if(value < minAge.value)
                {
                    value = minAge.value
                }
            }
        }

        Slider {
            id: distance
            width: parent.width
            minimumValue: 1
            maximumValue: 160
            value: 0
            onValueChanged: updateRequired = true
            stepSize: 1
            enabled: discoverable.checked && discoverable.enabled
            opacity: enabled? 1.0: 0.25
            label: qsTr("Search radius")
            valueText: sliderValue + " " + qsTr("km")
        }

        Row {
            spacing: Theme.paddingLarge
            width: parent.width
            height: Theme.itemSizeLarge
            anchors { left: parent.left; right: parent.right; leftMargin: Theme.horizontalPageMargin; rightMargin: Theme.horizontalPageMargin }

            Button {
                width: parent.width/2 - parent.spacing/2
                color: "red"
                text: qsTr("Logout")
                enabled: discoverable.enabled
                onClicked: remorse.execute(qsTr("Logging out"), function(){
                    app.cleanup()
                    Profile.logout()
                });
            }

            Button {
                width: parent.width/2 - parent.spacing/2
                color: "red"
                enabled: discoverable.enabled
                text: qsTr("Delete account")
                onClicked: remorse.execute("Deleting account", function(){
                    app.cleanup()
                    Profile.deleteAccount()
                })
            }
        }
    }
}
