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

Page {
    signal selected(string url, string id)
    Component.onCompleted: api.searchGIF("flirting")

    Connections {
        target: api
        onGifResultsChanged: {
            gridModel.model = api.gifResults
            loading.visible = false
            console.debug("GIF model loaded")
        }
    }

    SilicaFlickable {
        anchors.fill: parent
        contentHeight: column.height

        Column {
            id: column
            width: parent.width

            PageHeader {
                //% "Send GIF"
                title: qsTrId("sailfinder-send-gif")
            }

            Grid {
                id: grid
                width: parent.width
                columns: 3

                Repeater {
                    id: gridModel

                    AnimatedImage {
                        property bool _loadingGif: true

                        width: grid.width / grid.columns
                        height: width
                        source: model.url
                        asynchronous: true
                        onProgressChanged: _loadingGif = (progress < 1.0)

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            onClicked: {
                                selected(model.url, model.id)
                                pageStack.pop()
                            }

                            Rectangle {
                                anchors.fill: parent
                                color: mouseArea.pressed && mouseArea.containsMouse
                                                ? Theme.rgba(Theme.highlightBackgroundColor, Theme.highlightBackgroundOpacity)
                                                : "transparent"
                            }
                        }

                        BusyIndicator {
                            anchors.centerIn: parent
                            size: BusyIndicatorSize.Medium
                            running: Qt.application.active && parent._loadingGif
                        }
                    }
                }
            }
        }
    }

    BusyIndicator {
        id: loading
        size: BusyIndicatorSize.Large
        anchors.centerIn: parent
        visible: true
        running: Qt.application.active && visible
    }
}
