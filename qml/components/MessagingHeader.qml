import QtQuick 2.2
import Sailfish.Silica 1.0
import "../components"
import "../js/util.js" as Util

Item {
    id: header
    property string name
    property date birthDate
    property int gender
    property string avatar
    property date lastSeen

    anchors { top: parent.top; left: parent.left; right: parent.right }
    height: Theme.itemSizeMedium + Theme.paddingLarge
    
    Label {
        id: title
        anchors {
            right: avatar.left
            rightMargin: Theme.paddingLarge
            top: lastSeen.visible? parent.top: undefined
            topMargin: lastSeen.visible? Theme.paddingLarge: 0
            verticalCenter: lastSeen.visible? undefined: parent.verticalCenter
        }
        font.pixelSize: Theme.fontSizeLarge
        color: Theme.highlightColor
        text: Util.createHeaderMessages(header.name, header.birthDate, header.gender)
    }
    
    Label {
        id: lastSeen
        anchors { top: title.bottom; topMargin: Theme.paddingSmall; right: avatar.left; rightMargin: Theme.paddingLarge }
        visible: text.length > 0
        text: Util.formatDate(lastSeen)
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
