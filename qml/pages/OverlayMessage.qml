import QtQuick 2.0
import Sailfish.Silica 1.0

Rectangle {
    width: parent.width - 2*Theme.horizontalPageMargin
    height: parent.height - 2*Theme.horizontalPageMargin
    anchors { centerIn: parent }
    z: 1
    color: Theme.highlightDimmerColor
    opacity: 3*Theme.highlightBackgroundOpacity
    radius: Theme.itemSizeSmall/2

    property string message
    property string description

    Label {
        anchors { centerIn: parent }
        font.pixelSize: Theme.fontSizeHuge
        text: message

        Label {
            anchors { top: parent.bottom; left: parent.left; right: parent.right }
            font.pixelSize: Theme.fontSizeMedium
            visible: text
            wrapMode: Text.WordWrap
            text: description
        }
    }
}
