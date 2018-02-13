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
import QtGraphicalEffects 1.0

Image {
    signal clicked()

    id: image
    width: Theme.itemSizeLarge
    height: width
    onStatusChanged: {
        if(status == Image.Error) {
            console.warn("Can't load image")
            errorText.visible = true
            loadIndicator.running = false
        }
        else if(status == Image.Ready) {
            errorText.visible = false
            loadIndicator.running = false
        }
        else {
            errorText.visible = false
            loadIndicator.running = Qt.application.active
        }
    }

    layer.enabled: true
    layer.effect: OpacityMask {
        maskSource: Rectangle {
            anchors.centerIn: parent
            width: image.width
            height: image.width
            radius: width/2
        }
    }

    Component.onCompleted: touch.clicked.connect(clicked)

    Label {
        id: errorText
        anchors.centerIn: parent
        visible: false
        font.pixelSize: Theme.fontSizeMedium
        font.bold: true
        //% "Oops!"
        text: qsTrId("sailfinder-oops")
    }

    BusyIndicator {
        id: loadIndicator
        size: BusyIndicatorSize.Medium
        anchors.centerIn: parent
    }

    MouseArea {
        id: touch
        anchors.fill: parent
    }

    Rectangle {
        anchors.fill: parent
        color: Theme.highlightColor
        opacity: 0.33
        visible: touch.pressed
    }
}
