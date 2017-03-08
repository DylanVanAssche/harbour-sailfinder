import QtQuick 2.0
import Sailfish.Silica 1.0

Column {
    width: parent.width
    spacing: Theme.paddingLarge

    property string name
    property string avatar

    // Spacer
    Item {
        width: parent.width
        height: Theme.paddingLarge
    }

    Label {
        anchors { horizontalCenter: parent.horizontalCenter }
        font.pixelSize: Theme.fontSizeLarge
        text: qsTr("You just matched with")
    }

    Row {
        anchors { left: parent.left; leftMargin: Theme.horizontalPageMargin; right: parent.right; rightMargin: Theme.horizontalPageMargin }
        width: parent.width
        spacing: Theme.paddingLarge

        Image {
            width: parent.width/2.5
            height: width
            anchors { verticalCenter: parent.verticalCenter }
            source: avatar
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            onStatusChanged: status==Image.Error? source="../resources/images/image-placeholder.png": undefined
        }

        Label {
            width: parent.width - parent.width/2.5 - Theme.horizontalPageMargin
            anchors { verticalCenter: parent.verticalCenter }
            font.pixelSize: Theme.fontSizeExtraLarge
            truncationMode: TruncationMode.Fade
            text: name
        }
    }
}
