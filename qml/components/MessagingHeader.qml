import QtQuick 2.2
import Sailfish.Silica 1.0
import "../components"
import "../js/util.js" as Util

Item {  
    signal clicked()
    property string name
    property date birthDate
    property int gender
    property string avatar
    property date lastSeen
    property int distance

    id: header
    anchors { top: parent.top; left: parent.left; right: parent.right }
    height: Math.max(Theme.itemSizeMedium + Theme.paddingLarge, column.height + Theme.paddingLarge)
    Component.onCompleted: avatar.clicked.connect(clicked)

    Column {
        id: column
        anchors {
            right: avatar.left
            rightMargin: Theme.paddingLarge
            verticalCenter: parent.verticalCenter
        }

        Label {
            anchors.right: parent.right
            font.pixelSize: Theme.fontSizeLarge
            color: Theme.highlightColor
            text: Util.createHeaderMessages(header.name, header.birthDate, header.gender, header.distance)
        }

        Label {
            anchors.right: parent.right
            visible: text.length > 0
            text: Util.formatDate(lastSeen)
            onTextChanged: console.debug("Last seen visible: " + visible)
        }
    }
    
    Avatar {
        id: avatar
        width: Theme.itemSizeMedium
        height: width
        anchors {
            right: parent.right
            rightMargin: Theme.horizontalPageMargin
            verticalCenter: parent.verticalCenter
        }
        source: header.avatar
    }
    
    Rectangle {
        anchors.fill: parent
        z: -1
        gradient: Gradient {
            GradientStop { position: 0.0; color: Theme.rgba(Theme.highlightBackgroundColor, 0.15) }
            GradientStop { position: 1.0; color: Theme.rgba(Theme.highlightBackgroundColor, 0.3) }
        }
    }
}
