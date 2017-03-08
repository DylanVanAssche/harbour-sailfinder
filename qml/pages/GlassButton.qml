import QtQuick 2.2
import Sailfish.Silica 1.0

BackgroundItem {
    property string link
    property string iconSource
    property string iconText
    property real itemScale: 1.0
    property bool show: true
    
    width: parent.width
    height: Theme.itemSizeLarge*1.2*itemScale
    anchors { left: parent.left; right: parent.right }
    onClicked: Qt.openUrlExternally(link);
    enabled: link.length
    visible: iconText.length && show

    Row {
        anchors { left: parent.left; leftMargin: Theme.paddingLarge*itemScale; right: parent.right; rightMargin: Theme.paddingLarge*itemScale; verticalCenter: parent.verticalCenter }
        spacing: Theme.paddingMedium

        Image {
            id: logo
            width: Theme.iconSizeLarge
            height: width
            source: iconSource
            scale: itemScale
        }

        Label {
            width: parent.width - logo.width
            anchors { verticalCenter: parent.verticalCenter }
            font.pixelSize: Theme.fontSizeLarge
            text: iconText
            truncationMode: TruncationMode.Fade
            visible: iconText.length
        }
    }
}
