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

BackgroundItem {
    id: navigationItem
    property string source
    property bool loading

    width: parent.width
    height: parent.height

    Image {
        width: parent.height*0.5
        height: width
        anchors.centerIn: parent
        source: navigationItem.source
        Behavior on opacity { FadeAnimation {} }
    }

    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: navigationItem.loading? 1.0: 0.0
        Behavior on opacity { FadeAnimation {} }

        BusyIndicator {
            anchors.centerIn: parent
            size: BusyIndicatorSize.Medium
            running: navigationItem.loading
        }
    }
}
