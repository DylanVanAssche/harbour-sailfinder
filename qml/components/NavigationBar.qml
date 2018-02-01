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
    id: bar
    property int currentIndex
    signal newIndex(int index)

    width: parent.width
    height: Theme.itemSizeSmall*1.2

    // Current page follower
    Rectangle {
        x: (parent.width/3)*currentIndex + Theme.itemSizeSmall*0.5
        color: Theme.highlightBackgroundColor
        width: (iconRow.width/3) - Theme.itemSizeSmall
        height: iconRow.height/12
        radius: iconRow.height/2
        anchors { top: parent.top; topMargin: Theme.itemSizeSmall*0.1 }
        z: 1
        Behavior on x { NumberAnimation { duration: 150 } }
    }

    // Background
    Rectangle {
        anchors { fill: parent }
        opacity: 0.66
        color: "black"
    }

    Row {
        id: iconRow
        width: parent.width
        height: parent.height

        NavigationBarDelegate {
            width: parent.width/3
            height: parent.height
            source: "qrc:///images/icon-recs.png"
            onClicked: newIndex(0)
        }

        NavigationBarDelegate {
            width: parent.width/3
            height: parent.height
            source: "qrc:///images/icon-matches.png"
            onClicked: newIndex(1)
        }

        NavigationBarDelegate {
            width: parent.width/3
            height: parent.height
            source: "qrc:///images/icon-profile.png"
            onClicked: newIndex(2)
        }
    }
}
