import QtQuick 2.2
import Sailfish.Silica 1.0

Label {
    property string labelText

    anchors { left: parent.left; right: parent.right; leftMargin: Theme.horizontalPageMargin; rightMargin: Theme.horizontalPageMargin }
    font.pixelSize: Theme.fontSizeMedium
    wrapMode: Text.WordWrap
    text: labelText
}
