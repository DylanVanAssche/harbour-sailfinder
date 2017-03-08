import QtQuick 2.2
import Sailfish.Silica 1.0

Page {
    id: page

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: columnPage.height

        Column {
            id: columnPage
            width: page.width
            spacing: Theme.paddingLarge

            PageHeader {
                title: app.name + ' ' + app.version
            }

            SectionHeader { text: qsTr("What's Sailfinder?") }

            Label {
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: Theme.horizontalPageMargin
                    rightMargin: Theme.horizontalPageMargin
                }
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.WordWrap
                text: qsTr("Sailfinder is an unofficial Tinder client for Sailfish OS. The application is opensource GPLv3 software and based on PyOtherSide.")
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Source code")
                onClicked:
                {
                    Qt.openUrlExternally("https://github.com/modulebaan/harbour-sailfinder")
                }
            }

            SectionHeader { text: qsTr("Privacy policy") }

            Label {
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: Theme.horizontalPageMargin
                    rightMargin: Theme.horizontalPageMargin
                }
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.WordWrap
                text: qsTr("• Sailfinder will NEVER collect any personal information about the user, but I can't guarantee that the third-party companies used in Sailfinder (Tinder, Facebook, MapQuest, ...) won't collect any information.\n \n• Sailfinder NEVER connects to the analytics API of Tinder, which collects data about the usage of the app in the background on Android.")
            }

            SectionHeader { text: qsTr("Support Sailfinder!") }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Donate with Paypal")
                onClicked: {
                    Qt.openUrlExternally("https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=XTDV5P8JQTHT4")
                }
            }

            Label {
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: Theme.horizontalPageMargin
                }
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.WordWrap
                text: qsTr("I put in a lot of time to develop Sailfinder so please buy me a coffee :)")
            }

            SectionHeader { text: qsTr("Other") }

            Label {
                anchors {
                    left: parent.left
                    right: parent.right
                    leftMargin: Theme.horizontalPageMargin
                }
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.WordWrap
                text: qsTr("• Developped by Dylan Van Assche (modulebaan)")
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Modulebaan.tk")
                onClicked:
                {
                    Qt.openUrlExternally("http://modulebaan.tk/sailfish-os/my-apps/")
                }
            }

            Label {
                anchors
                {
                    left: parent.left
                    right: parent.right
                    leftMargin: Theme.horizontalPageMargin
                }
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.WordWrap
                text: qsTr("• Icons by Paomedia")
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Paomedia icons on Github")
                onClicked:
                {
                    Qt.openUrlExternally("https://github.com/paomedia/small-n-flat/")
                }
            }

            Label {
                anchors
                {
                    left: parent.left
                    right: parent.right
                    leftMargin: Theme.horizontalPageMargin
                }
                font.pixelSize: Theme.fontSizeSmall
                wrapMode: Text.WordWrap
                text: qsTr("• Messaging based on 'mitakuuluu-ui-ng' from Thomas Boutroue")
            }

            Button {
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Mitakuuluu-ui-ng on Gitlab")
                onClicked:
                {
                    Qt.openUrlExternally("http://gitlab.unique-conception.org/thebootroo/mitakuuluu-ui-ng")
                }
            }

            // Spacer
            Item {
                height: 20
                width: parent.width
            }
        }
    }
}

