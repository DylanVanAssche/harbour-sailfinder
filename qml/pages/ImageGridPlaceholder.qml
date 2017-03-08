import QtQuick 2.0
import Sailfish.Silica 1.0

Item {
    width: parent.width
    height: width
    opacity: show? 1.0: 0.0
    visible: (opacity==0)? false: true

    Behavior on height { NumberAnimation {} }
    Behavior on opacity { FadeAnimation {} }

    property string head
    property string description
    property bool show: true

    Column {
        width: parent.width
        anchors { centerIn: parent; margins: Theme.horizontalPageMargin}

        Label {
            width: parent.width
            anchors { left: parent.left; right: parent.right }
            font.pixelSize: Theme.fontSizeExtraLarge
            font.bold: true
            horizontalAlignment: TextEdit.AlignHCenter
            wrapMode: Text.Wrap
            text: head
        }

        Label {
            anchors { left: parent.left; right: parent.right; leftMargin: Theme.horizontalPageMargin; rightMargin: Theme.horizontalPageMargin }
            font.pixelSize: Theme.fontSizeMedium
            horizontalAlignment: TextEdit.AlignHCenter
            wrapMode: Text.Wrap
            text: description
        }
    }
}
