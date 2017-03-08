import QtQuick 2.0
import Sailfish.Silica 1.0

Row {
    width: parent.width
    property string buttonLink
    property string buttonIconSource
    property string buttonIconText
    property string editIconSource
    property string editPageLink
    property int editPageType
    property string editPageTitle

    GlassButton { link: buttonLink; iconSource: buttonIconSource; iconText: buttonIconText; itemScale: 0.5; anchors { left: undefined; right: undefined } width: parent.width - edit.width }

    IconButton {
        id: edit
        anchors { verticalCenter: parent.verticalCenter }
        icon.source: editIconSource
        icon.scale: Theme.iconSizeSmall/icon.width // Scale icons according to the screen sizes
        onClicked: {
            pageStack.push(Qt.resolvedUrl(editPageLink), { dialogTitle: editPageTitle, type: editPageType })
        }
    }
}
