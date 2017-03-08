import QtQuick 2.0
import Sailfish.Silica 1.0
import "js/util.js" as Util

Page {
    id: main
    property bool loading: app.loadingRecs || app.loadingMatches || app.loadingProfile //|| app.loadingSocial
    property bool outOfSuperlikes
    property bool outOfLikes
    property bool outOfUsers
    property bool discovery: true
    property var newLikesIn
    ///property bool loadingSocial: true // Sailfinder V3.X

    Component.onCompleted: Util.init()

    OverlayMessage {
        message: qsTr("Account banned") + " :("
        description: qsTr("Your Facebook account has been banned, create a new Facebook account first to use it with Sailfinder.")
        visible: app.banned
    }

    // Update location on launch
    LocationManager {}

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: mainColumn.height

        PullDownMenu {
            busy: app.loadingRecs || app.loadingMatches || app.loadingProfile //|| app.loadingSocial
            enabled: !app.banned
            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.push(Qt.resolvedUrl("AboutPage.qml"))
            }

            MenuItem {
                text: qsTr("Settings")
                onClicked: pageStack.push(Qt.resolvedUrl("SettingsPage.qml"))
            }
        }

        Column {
            id: mainColumn
            anchors { fill: parent }

            PageHeader {
                id: pageHeader
                opacity: app.banned? 0.25: 1.0
                title: Util.getHeader(swipeview.currentIndex)
            }

            SlideshowView {
                readonly property int _heightPortrait: Screen.height - bar.height - pageHeader.height
                readonly property int _heightLandscape: Screen.width - bar.height - pageHeader.height

                id: swipeview
                itemWidth: width
                itemHeight: height
                height: (app.orientation === Orientation.Portrait) || (app.orientation === Orientation.PortraitInverted)? _heightPortrait: _heightLandscape //PortraitMask gives wrong values in PortraitInverted mode
                clip: true
                enabled: !app.banned
                opacity: enabled? 1.0: 0.25
                anchors { left: parent.left; right: parent.right;}
                model: VisualItemModel {
                    Recommendations {}
                    Matches {}
                    Profile {}
                    //Social {} //Sailfinder V3.X
                }
            }

            NavigationBar { id: bar; enabled: !banned }
        }
    }

    DockedPanel {
        id: popup
        width: parent.width
        height: parent.height/2.5
        modal: true // Only compatible with Sailfish OS 2.0.2.51 and higher
        dock: Dock.Top

        MatchesPopup { id: popupContent; z: 1 }

        //Background
        Rectangle {
            anchors { fill: parent }
            color: "black"
            opacity: 0.75
        }
    }
}

