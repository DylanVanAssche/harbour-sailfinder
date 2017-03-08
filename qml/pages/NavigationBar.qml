import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    width: parent.width
    height: Theme.itemSizeSmall*1.2
    opacity: enabled? 1.0: 0.25

    // Current page follower
    Rectangle {
        x: (parent.width/3)*swipeview.currentIndex + Theme.itemSizeSmall*0.5
        color: Theme.highlightBackgroundColor
        width: (iconRow.width/3) - Theme.itemSizeSmall
        height: iconRow.height/12
        radius: iconRow.height/2
        anchors {top: parent.top; topMargin: Theme.itemSizeSmall*0.1}
        z: 1
        Behavior on x {
            NumberAnimation { duration: 150 }
        }
    }

    // Background
    Rectangle {
        anchors { fill: parent }
        opacity: 0.66
        color: "black"
    }
    
    Row {
        id: iconRow
        width: parent.width
        height: parent.height

        NavigationBarDelegate { swipeviewIndex: 0; iconSource: "../resources/images/icon-recs.png"; loading: app.loadingRecs || app.cachingRecs }
        NavigationBarDelegate { swipeviewIndex: 1; iconSource: "../resources/images/icon-matches.png"; loading: app.loadingMatches || app.cachingMatches }
        NavigationBarDelegate { swipeviewIndex: 2; iconSource: "../resources/images/icon-profile.png"; loading: app.loadingProfile || app.cachingProfile }
        //NavigationBarDelegate { swipeviewIndex: 3; iconSource: "../resources/images/icon-social.png"; loading: app.loadingSocial || app.cachingSocial } // Sailfinder V3.X

        /*BackgroundItem {
            width: parent.width/3
            height: parent.height
            onClicked: swipeview.currentIndex = 0

            Image { 
                width: parent.height*0.5
                height: width
                anchors { centerIn: parent }
                z: 2
                source: "../resources/images/icon-recs.png"
                opacity: app.loadingRecs? 0.15: 1.0
                Behavior on opacity { FadeAnimation {} }
            }

            Rectangle {
                anchors { fill: parent }
                color: "black"
                opacity: app.loadingRecs? 1.0: 0.0
                Behavior on opacity { FadeAnimation {} }

                BusyIndicator {
                    anchors { centerIn: parent }
                    size: BusyIndicatorSize.Medium
                    running: app.loadingRecs
                }
            }
        }

        BackgroundItem {
            width: parent.width/3
            height: parent.height
            onClicked: swipeview.currentIndex = 1

            Image {
                width: parent.height*0.5
                height: width
                anchors { centerIn: parent }
                z: 2
                source: "../resources/images/icon-matches.png"
                opacity: app.loadingMatches? 0.15: 1.0
                Behavior on opacity { FadeAnimation {} }
            }

            Rectangle {
                anchors { fill: parent }
                color: "black"
                opacity: app.loadingMatches? 1.0: 0.0
                Behavior on opacity { FadeAnimation {} }

                BusyIndicator {
                    anchors { centerIn: parent }
                    size: BusyIndicatorSize.Medium
                    running: app.loadingMatches
                }
            }
        }

        BackgroundItem {
            width: parent.width/3
            height: parent.height
            onClicked: swipeview.currentIndex = 2

            Image {
                width: parent.height*0.5
                height: width
                anchors { centerIn: parent }
                z: 2
                source: "../resources/images/icon-profile.png"
                opacity: app.loadingProfile? 0.15: 1.0
                Behavior on opacity { FadeAnimation {} }
            }

            Rectangle {
                anchors { fill: parent }
                color: "black"
                opacity: app.loadingProfile? 1.0: 0.0
                Behavior on opacity { FadeAnimation {} }

                BusyIndicator {
                    anchors { centerIn: parent }
                    size: BusyIndicatorSize.Medium
                    running: app.loadingProfile
                }
            }
        }*/

        /*BackgroundItem { // Sailfinder V3.X
            width: parent.width/4
            height: parent.height
            onClicked: swipeview.currentIndex = 3

            Image {
                width: parent.height*0.5
                height: width
                anchors { centerIn: parent }
                z: 2
                source: "../resources/images/icon-social.png"
                opacity: app.loadingSocial? 0.15: 1.0
                Behavior on opacity { FadeAnimation {} }
            }

            Rectangle {
                anchors { fill: parent }
                color: "black"
                opacity: app.loadingSocial? 1.0: 0.0
                Behavior on opacity { FadeAnimation {} }

                BusyIndicator {
                    anchors { centerIn: parent }
                    size: BusyIndicatorSize.Medium
                    running: app.loadingSocial
                }
            }
        }*/
    }
}
