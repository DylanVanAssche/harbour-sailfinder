import QtQuick 2.0
import Sailfish.Silica 1.0

Row {
    anchors { left: parent.left; leftMargin: Theme.horizontalPageMargin; right: parent.right; rightMargin: Theme.horizontalPageMargin}
    spacing: Theme.paddingLarge
    
    Image {
        source: "../resources/images/account-logo.png"
        width: Theme.iconSizeLarge*2
        height: width
    }
    Column {
        anchors.verticalCenter: parent.verticalCenter
        Label {
            text: "Sailfinder"
            font.pixelSize: Theme.fontSizeHuge
            font.bold: true
            color: Theme.secondaryHighlightColor
        }
        
        Label {
            text: qsTr("Account")
            font.pixelSize: Theme.fontSizeLarge
            color: Theme.secondaryHighlightColor
        }
    }
}
