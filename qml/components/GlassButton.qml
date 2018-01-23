/*
*   This file is part of Sailfinder.
*
*   Sailfinder is free software: you can redistribute it and/or modify
*   it under the terms of the GNU General Public License as published by
*   the Free Software Foundation, either version 3 of the License, or
*   (at your option) any later version.
*
*   Sailfinder is distributed in the hope that it will be useful,
*   but WITHOUT ANY WARRANTY; without even the implied warranty of
*   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*   GNU General Public License for more details.
*
*   You should have received a copy of the GNU General Public License
*   along with Sailfinder.  If not, see <http://www.gnu.org/licenses/>.
*/

import QtQuick 2.2
import Sailfish.Silica 1.0

BackgroundItem {
    id: button
    property string link
    property string source
    property string text
    property bool show: true
    property int type

    width: parent.width
    height: Theme.itemSizeLarge
    anchors { left: parent.left; right: parent.right }
    onClicked: Qt.openUrlExternally(link)
    enabled: link.length > 0
    visible: button.text.length && button.show

    Row {
        anchors { left: parent.left; leftMargin: Theme.paddingLarge; right: parent.right; rightMargin: Theme.paddingLarge; verticalCenter: parent.verticalCenter }
        spacing: Theme.paddingMedium

        Image {
            id: logo
            width: Theme.iconSizeMedium
            height: width
            source: button.source
        }

        Label {
            width: parent.width - logo.width
            anchors { verticalCenter: parent.verticalCenter }
            font.pixelSize: Theme.fontSizeMedium
            text: button.text
            truncationMode: TruncationMode.Fade
            visible: button.text.length
        }
    }
}
