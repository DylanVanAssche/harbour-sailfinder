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
import QtQuick.Layouts 1.1
import Sailfish.Silica 1.0
//import Nemo.Thumbnailer 1.0

Item {
    property var photoListModel

    width: parent.width
    height: parent.width

    function closeFullScreen() {
        fullScreen.visible = false
    }

    GridLayout {
        id: layout
        anchors.fill: parent // IMPORTANT: Using GridLayout without this will fail!
        columns: 3
        columnSpacing: 0
        rowSpacing: 0

        Repeater {
            id: repeater
            model: photoListModel

            function forceFirstItem() {
                // The 1st picture is always 2x bigger
                itemAt(0).Layout.columnSpan = 2
                itemAt(0).Layout.rowSpan = 2
            }
            Image {
                id: image
                width: Layout.columnSpan*parent.width/parent.columns
                height: Layout.rowSpan*parent.width/parent.columns
                Layout.minimumWidth: width
                Layout.minimumHeight: height
                Layout.preferredWidth: width
                Layout.preferredHeight: height
                Layout.maximumWidth: parent.width
                Layout.maximumHeight: parent.height
                Layout.fillHeight: true
                Layout.fillWidth: true
                sourceSize.width: width
                sourceSize.height: height
                source: model.urlMedium
                asynchronous: true
                opacity: progress
                Behavior on opacity { FadeAnimator {} }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        fullScreen.source = image.source
                        fullScreen.visible = true
                    }
                }

                BusyIndicator {
                    size: BusyIndicatorSize.Medium
                    anchors.centerIn: parent
                    running: Qt.application.active && (image.status == Image.Loading || image.status == Image.Null)
                }

                Label {
                    id: errorText
                    anchors.centerIn: parent
                    visible: image.status == Image.Error
                    //% "Oops!"
                    text: qsTrId("sailfinder-oops")
                }
            }
            onModelChanged: forceFirstItem()
        }
    }

    Image {
        id: fullScreen
        width: parent.width
        height: parent.width
        anchors.centerIn: parent
        z: 1

        MouseArea {
            anchors.fill: parent
            onClicked: fullScreen.visible = false
        }
    }
}
