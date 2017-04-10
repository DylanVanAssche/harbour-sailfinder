import QtQuick 2.2
import QtQuick.Window 2.0
import Sailfish.Silica 1.0

Item {
    height: Theme.itemSizeExtraLarge
    anchors { top: parent.top; left: parent.left; right: parent.right }

    // Background
    Rectangle {
        anchors { fill: parent }
        z: -1
        color: "black"
        opacity: 0.2
    }

    // Avatar user
    BackgroundItem {
        id: avatar
        width: Theme.iconSizeLarge
        height: width
        anchors { right: parent.right; margins: Theme.paddingLarge; verticalCenter: parent.verticalCenter }
        onClicked: pageStack.push(Qt.resolvedUrl('AboutMatchPage.qml'), { userId: userId, name: name })

        Image {
            width: parent.width
            height: parent.height
            anchors { fill: parent }
            asynchronous: true
            source: (status === Image.Error)? "../resources/images/icon-noimage.png": avatarImage
            fillMode: Image.PreserveAspectCrop

            BusyIndicator {
                anchors { centerIn: parent }
                size: BusyIndicatorSize.Small
                running: (avatar.status === Image.Loading)? true: false
            }
        }
    }

    // Name user & last online
    Column {
        anchors { right: avatar.left; margins: Theme.paddingLarge; verticalCenter: parent.verticalCenter }

        Label {
            anchors { right: parent.right }
            color: Theme.highlightColor
            font.pixelSize: Theme.fontSizeLarge
            text: name
        }

        Label {
            anchors { right: parent.right }
            color: Theme.secondaryColor
            font.pixelSize: Theme.fontSizeTiny
            text: qsTr("Last seen") + ": " + lastSeen
        }
    }
}
