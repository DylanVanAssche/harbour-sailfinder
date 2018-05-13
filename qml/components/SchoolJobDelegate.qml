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

import QtQuick 2.0
import Sailfish.Silica 1.0

ListItem {
    property string icon
    property string name
    property string title

    contentHeight: column.height + Theme.paddingLarge
    width: parent.width
    enabled: false

    Column {
        id: column
        anchors {
            left: image.right
            leftMargin: Theme.paddingMedium
            right: parent.right
            rightMargin: Theme.horizontalPageMargin
            verticalCenter: parent.verticalCenter
        }

        TextLabel {
            text: name
        }

        TextLabel {
            text: title
            font.pixelSize: Theme.fontSizeTiny
            font.italic: true
            visible: text.length > 0
        }
    }

    Image {
        id: image
        width: Theme.itemSizeSmall
        height: width
        anchors {
            left: parent.left
            leftMargin: Theme.horizontalPageMargin
            verticalCenter: parent.verticalCenter
        }
        asynchronous: true
        source: icon
    }
}
