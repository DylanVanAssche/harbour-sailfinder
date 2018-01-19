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

Item {
    property bool canLike
    property bool canSuperlike
    property bool loaded

    signal liked()
    signal passed()
    signal superliked()

    width: parent.width
    height: Theme.itemSizeHuge

    Row {
        height: parent.height
        anchors.centerIn: parent
        spacing: 3*Theme.paddingLarge

        IconButton {
            anchors { verticalCenter: parent.verticalCenter}
            icon.source: "qrc:///images/dislike.png"
            icon.scale: Theme.iconSizeExtraLarge/icon.width
            enabled: loaded
            onClicked: passed()
        }

        IconButton {
            anchors { verticalCenter: parent.verticalCenter}
            icon.source: "qrc:///images/superlike.png"
            icon.scale: Theme.iconSizeExtraLarge/icon.width
            enabled: loaded && canSuperlike
            onClicked: superliked()
        }

        IconButton {
            anchors { verticalCenter: parent.verticalCenter}
            icon.source: "qrc:///images/like.png"
            icon.scale: Theme.iconSizeExtraLarge/icon.width
            enabled: loaded && canLike
            onClicked: liked()
        }
    }
}
