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

Item {
    anchors.fill: parent

    function populate() {
        if(api.matchesList !== "null") {
            numberOfMatches.text = api.matchesList.numberOfMatches()
            repeater.model = api.matchesList
        }
    }

    Connections {
        target: api
        onMatchesListChanged: populate()
    }

    GridLayout {
        id: layout
        anchors.fill: parent // IMPORTANT: Using GridLayout without this will fail!
        columns: 2
        columnSpacing: 0
        rowSpacing: 0

        Repeater {
            id: repeater

            Image {
                id: image
                width: Layout.columnSpan*parent.width/parent.columns
                height: Layout.rowSpan*parent.width/parent.columns
                fillMode: Image.PreserveAspectCrop
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
                source: model.avatar
                asynchronous: true
                opacity: progress/3 // background
                visible: index < 8 // limit the number of pictures
                Behavior on opacity { FadeAnimator {} }
                onStatusChanged: {
                    if(status == Image.Error) {
                        console.warn("Can't load image for matches cover")
                    }
                }
            }
        }
    }

    Column {
        width: parent.width
        anchors.centerIn: parent

        TextLabel {
            id: numberOfMatches
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: Theme.fontSizeExtraLarge
            font.bold: true
            visible: text.length > 0
        }


        TextLabel {
            horizontalAlignment: Text.AlignHCenter
            font.pixelSize: Theme.fontSizeExtraLarge
            //% "Matches"
            text: qsTrId("sailfinder-matches")
            font.bold: numberOfMatches.text.length == 0 // no matches yet
        }
    }
}
