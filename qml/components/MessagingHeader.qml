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

    anchors { top: parent.top; left: parent.left; right: parent.right }
    height: Theme.itemSizeMedium + Theme.paddingLarge
    
    Label {
        id: title
        anchors {
            right: avatar.left
            rightMargin: Theme.paddingLarge
            top: parent.top
            topMargin: Theme.paddingLarge
        }
        font.pixelSize: Theme.fontSizeLarge
        color: Theme.highlightColor
        text: Util.createHeaderMessages(header.name, header.birthDate, header.gender)
    }
    
    Label {
        anchors { top: title.bottom; topMargin: Theme.paddingSmall; right: avatar.left; rightMargin: Theme.paddingLarge }
        text: "online"
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
